# Lab8：文件系统

对实验报告的要求： 

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的 OS 原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为 OS 原理中很重要，但在实验中没有对应上的知识点

#### 练习0：填写已有实验

本实验依赖实验2/3/4/5/6/7。请把你做的实验2/3/4/5/6/7的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”/“LAB5”/“LAB6” /“LAB7”的注释相应部分。并确保编译通过。注意：为了能够正确执行lab8的测试应用程序，可能需对已完成的实验2/3/4/5/6/7的代码进行进一步改进。

proc.c 中，在 proc_struct 结构中加入了一个 file_struct，需要在 `alloc_proc` 时加上对它的初始化，就是加上一行：

```c
proc->filesp = NULL;
```

#### 练习1：完成读文件操作的实现（需要编码）

首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，填写在 kern/fs/sfs/sfs_inode.c 中 的 `sfs_io_nolock()` 函数，实现读文件中数据的代码。

`sfs_io_nolock` 函数实现的是 SFS 层中文件的读写操作，将文件内容从磁盘读入内存或将内存中的内容写回磁盘。函数中需要完成操作如下：

1. 计算一些辅助变量（实际读写的结束位置 `endpos`、起始块号 `blkno`、需要读写的块数 `nblks`），并处理一些特殊情况（如越界），根据传入的写标志选择操作函数 `sfs_buf_op, sfs_block_op`；
2. 接着进行实际操作，先处理起始的没有对齐到块的部分，再以块为单位循环处理中间的部分，最后处理末尾剩余的部分。
3. 每部分中都调用 `sfs_bmap_load_nolock` 函数获取 inode 编号，并调用  `sfs_buf_op, sfs_block_op` 函数完成实际的读写操作（中间部分调用 `sfs_block_op`，起始和末尾部分调用 `sfs_buf_op`），调整相关变量。
4. 完成后，如果结束位置超过了文件原来的大小（写文件时会出现这种情况，读文件时不会出现这种情况），则调整文件大小，并设置 dirty 变量。

其中 第 1 步和第 4 步都已经在 ucore 中实现，这里只需要实现第 2-3 步。

```c
static int sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf,
off_t offset, size_t *alenp, bool write) {
  	// ...

  	// 读写第一部分的数据（起始偏移量不是块对齐，先读写偏移量对应块的剩余内容）
    if((blkoff = offset % SFS_BLKSIZE) != 0) { 
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset); // 第一个数据块的大小
        if((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) { // 内存文件索引对应 block 的编号 ino
            goto out;
        }
        if((ret = sfs_buf_op(sfs, buf, size, ino, blkoff))!=0){
            goto out;
        }
        alen += size;
        buf += size;
        if (nblks == 0) {
            goto out;
        }
        blkno++;
        nblks--;
    }
    
    // 读写中间的数据
    while (nblks != 0){
    	if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_block_op(sfs, buf, ino, nblks)) != 0) {
            goto out;
        }
	alen += SFS_BLKSIZE;
	buf += SFS_BLKSIZE;
	blkno++;
	nblks--;
    }

    // 读写第三部分的数据（结束位置不是块对齐，读写结束位置对应块的剩余内容）
    if ((size = endpos % SFS_BLKSIZE) != 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino))!=0){
            goto out;
        }
        if((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0){
            goto out;
        }
        alen += size;
    }
  	
  	//...
}
```

#### 练习2：完成基于文件系统的执行程序机制的实现（需要编码）

改写 proc.c 中的 `load_icode` 函数和其他相关函数，实现基于文件系统的执行程序机制。执行：make qemu。如果能看看到sh用户程序的执行界面，则基本成功了。如果在sh用户界面上可以执行”ls”,”hello”等其他放置在 sfs 文件系统中的其他执行程序，则可以认为本实验基本成功。

可以在 lab5 的基础上修改，区别主要在于读 ELF 文件变成通过其 file descriptor 调用 `load_icode_read` 函数从磁盘上读，而不是获取它在内存中的位置；`load_icode` 传入的参数分别是 ELF 的 `fd`、参数个数 `argc` 和参数 `kargv[]`。

此处只说明在 lab5 基础上修改的部分：

1. 调用 `load_icode_read` 函数，从磁盘上读出 ELF 文件的 elf-header。

```c
struct elfhdr __elf, *elf = &__elf;
    if((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0))!=0){
        goto bad_elf_cleanup_pgdir;
    }
```

2. 根据 elf-header 中的信息，循环读取每个段的 header。

```c
struct proghdr __ph, *ph = &__ph;
for(phnum = 0; phnum < elf->e_phnum; phnum++){
        off_t phoff = elf->e_phoff + sizeof(struct proghdr)*phnum;
        if((ret = load_icode_read(fd, ph, sizeof(struct proghdr), phoff))!=0){
            goto bad_cleanup_mmap;
        }
  			//...
}
sysfile_close(fd); // 关闭文件，之后的操作里已经不需要读它了
```

3. 设置用户栈：这里要处理传入用户栈的参数，计算所有参数大小，把参数取出来放在栈上，再动态计算当前用户栈顶。

```c
		uint32_t argv_size = 0, i;
		// 计算所有参数加起来的长度
    for(i = 0; i < argc; i++){
        argv_size += strnlen(kargv[i], EXEC_MAX_ARG_LEN+1) +1;
    }

    uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
    char** uargv = (char**)(stacktop - argc * sizeof(char*));

		// 把所有参数取出来，放在用户栈上
    argv_size = 0;
    for(i = 0; i < argc; i++){
        uargv[i] = strcpy((char*)(stacktop + argv_size), kargv[i]);
        argv_size += strnlen(kargv[i], EXEC_MAX_ARG_LEN+1) +1;
    }

		// 计算当前的用户栈顶
    stacktop = (uintptr_t)uargv - sizeof(int);
    *(int*)stacktop = argc;
```

4. 在设置中断帧时，把栈顶位置设为上一步计算出的栈顶，而不是 `USTACKTOP`。

```c
tf->gpr.sp = stacktop;
```

#### 扩展练习 Challenge1：完成基于“UNIX的PIPE机制”的设计方案

如果要在 ucore 里加入 UNIX 的管道（Pipe)机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的 C 语言 struct 定义。在网络上查找相关的 Linux 资料和实现，请在实验报告中给出设计实现”UNIX的PIPE机制“的概要设计方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

Linux 内核中的 pipe 使用 16 个内存页的环形缓冲区存储数据，通过读指针和写指针来记录读操作和写操作位置；读写数据时，从读/写指针所指的位置开始读写，并将指针向前移动。

读取数据时，需要考虑缓冲区是否为空，若空则等待；写入数据时，也要考虑缓冲区是否已满，若满则等待。

使用 `pipe_inode_info` 管理 pipe，定义其数据结构如下：

```c
struct pipe_inode_info {
    wait_queue_head_t wait; // 等待队列，存储正在等待管道可读或者可写的进程
    unsigned int nrbufs, // 未读数据占用了缓冲区的多少个内存页
    unsigned int curbuf; // 当前正在读取缓冲区的哪个内存页
  	unsigned int readers; // 正在读取管道的进程数
    unsigned int writers; // 正在写入管道的进程数
    unsigned int waiting_writers; // 等待管道可写的进程数
    struct inode *inode; // 管道的 inode 对象
    struct pipe_buffer bufs[16]; // 环形缓冲区
};
```

环形缓冲区由 16 个 `pipe_buffer` 对象组成，一个占用一个内存页，其结构如下：

```c
struct pipe_buffer {
    struct page *page; // 占用的内存页
    unsigned int offset; // 如果进程正在读取当前内存页的数据，那么 offset 指向正在读取当前内存页的偏移
    unsigned int len; // 当前内存页拥有未读数据的长度
};
```

定义管道操作的接口如下：

```c
int read_pipe(struct pipe_inode_info* pipe, char* buf, int count)
int write_pipe(struct pipe_inode_info* pipe, char* buf, int count)
```

读数据时，`pipe_inode_info` 中的 `curbuf` 字段表示应该从缓冲区中的哪个 `pipe_buffer` 中读数据；`pipe_buffer` 的 `offset` 字段表示要从内存页的哪个位置开始读取数据。随着数据读入，相应地移动 `offset`、减少 `len`；直到 `len == 0`，当前内存页已经读完，再移动 `curbuf`。

写数据时，这里并没有直接定义写指针，而是通过读指针 + 未读数据长度计算出写指针的位置。如果上次写操作写入的 `pipe_buffer` 还有空闲的空间，就将数据写入，增加 `len` 字段的值；反之，就新申请一个内存页，把数据保存到新内存页中，增加 `pipe_inode_info` 的 `nrbufs` 字段的值。

同步互斥问题的处理上，读进程进行时，写进程进入等待状态；读进程结束后，唤醒写进程，反之亦然。其中只有多个读进程可以同时进行，其他的都需要阻塞。

#### 扩展练习 Challenge2：完成基于“UNIX的软连接和硬连接机制”的设计方案

如果要在 ucore 里加入 UNIX 的软连接和硬连接机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的 C 语言 struct 定义。在网络上查找相关的 Linux 资料和实现，请在实验报告中给出设计实现”UNIX 的软连接和硬连接机制“的概要设计方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）
