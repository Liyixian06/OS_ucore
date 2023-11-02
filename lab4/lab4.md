# Lab4：进程管理  

对实验报告的要求： 

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

#### 练习1：分配并初始化一个进程控制块（需要编码）
alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

> 【提示】在 alloc_proc 函数的实现中，需要初始化的 proc_struct 结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明 proc_struct 中 `struct context context` 和 `struct trapframe *tf` 成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

`alloc_proc` 函数的实现思路就是创建一个新的进程控制块，然后对所有成员变量进行初始化；根据实验指导书，除了几个成员变量设置特殊值之外，其他成员变量均初始化为0。

```c
//kern/process/proc.c
static struct proc_struct *alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE
    proc->state = PROC_UNINIT; // 设置为初始态
    proc->pid = -1; // pid的未初始化值
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
    proc->tf = NULL;
    proc->cr3 = boot_cr3; //由于是内核线程，共享内核虚拟内存空间，使用内核页目录表的基址
    proc->flags = 0;
    memset(proc->name, 0, PROC_NAME_LEN);

    }
    return proc;
}
```

context 成员变量的含义是线程运行的上下文信息（各个寄存器的状态），根据 `switch_to` 函数，可以知道它在线程之间进行切换的时候，用于保存和恢复线程上下文。

tf 成员变量的作用是在切换线程时，使用的是中断返回的方式，需要构造一个伪造的中断返回现场（即中断帧），这样可以正确地将控制权转交给新的线程。  
因为在 `copy_thread` 函数中将上下文中的 ra 设置为了 `forkret` 函数的入口，所以在 `switch_to` 之后会返回到该函数，最终跳到中断返回函数 `__trapret`，根据 tf 中构造的中断返回地址，切换到新线程。

#### 练习2：为新创建的内核线程分配资源（需要编码）
创建一个内核线程需要分配和设置好很多资源。kernel_thread 函数通过调用do_fork函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们实际需要"fork"的东西就是stack和trapframe。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：

- 调用alloc_proc，首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明 ucore 是否做到给每个新 fork 的线程一个唯一的id？请说明你的分析和理由。

`do_fork` 函数创建了当前内核线程的一个副本，设置新的控制块中的每个成员变量。

```c
//kern/process/proc.c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    //    1. call alloc_proc to allocate a proc_struct
    proc = alloc_proc();
    if(proc==NULL){
        goto fork_out;
    }
    // 将子进程的父节点设为当前进程
    proc->parent = current;
    //    2. call setup_kstack to allocate a kernel stack for child process
    if(setup_kstack(proc)){
        goto bad_fork_cleanup_kstack;
    }
    //    3. call copy_mm to dup OR share mm according clone_flag
    // 由于本实验中内核线程共享虚拟内存空间，因此实际上该函数什么也没做
    if(copy_mm(clone_flags, proc)){
        goto bad_fork_cleanup_proc;
    }
    //    4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc, stack, tf);
    //    5. insert proc_struct into hash_list && proc_list
    bool intr_flag;
    local_intr_save(intr_flag); // 屏蔽中断
    {
        proc->pid = get_pid();
        hash_proc(proc);
        list_add(&proc_list, (proc->list_link));
        nr_process++;
    }
    local_intr_restore(intr_flag); // 恢复中断
    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);
    //    7. set ret vaule using child proc's pid
    ret = proc->pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

ucore 可以给每个新 fork 的进程一个唯一的 id。`do_fork` 中调用了 `get_pid` 函数创建新进程的 pid，该函数中包含了两个静态变量 `last_pid` 和 `next_safe`，这两个变量之间的取值均是没有被使用过的合法 pid；每次调用 `get_pid` 时，除了在该合法区间取一个 pid 分配给新进程，还要维护这个区间，在这两个变量之间已经没有合法取值时，循环检查所有进程的 pid，重新找到一个满足条件的区间，确保 pid 是唯一的。

#### 练习3：编写proc_run 函数（需要编码）
proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
- 禁用中断。你可以使用 `/kern/sync/sync.h` 中定义好的宏 `local_intr_save(x)` 和 `local_intr_restore(x)` 来实现关、开中断。
- 切换当前进程为要运行的进程。
- 切换页表，以便使用新进程的地址空间。`/libs/riscv.h` 中提供了 `lcr3(unsigned int cr3)` 函数，可实现修改CR3寄存器值的功能。
- 实现上下文切换。`/kern/process` 中已经预先编写好了 `switch.S`，其中定义了 `switch_to()` 函数。可实现两个进程的context切换。
- 允许中断。

请回答如下问题：

- 在本实验的执行过程中，创建且运行了几个内核线程？

完成代码编写后，编译并运行代码：make qemu

如果可以得到如附录A所示的显示内容（仅供参考，不是标准答案输出），则基本正确。

`proc_run` 函数的实现如下：

```c
//kern/process/proc.c
void proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3 YOUR CODE
        struct proc_struct *prev = current, *next = proc;
        bool intr_flag;
        local_intr_save(intr_flag); // 关闭中断
        {
            current = proc; // 设置当前进程为要切换到的进程
            load_esp0(next->kstack + KSTACKSIZE); // 设置 tss
            lcr3(next->cr3); // 页表切换
            switch_to(&(prev->context), &(next->context)); // 上下文切换
        }
        local_intr_restore(intr_flag); // 恢复中断
    }
}
```

在本实验执行过程中，一共创建了两个内核线程：  
1. `idleproc`，第0个内核线程，在完成新内核线程的创建和各种初始化工作后，执行 `cpu_idle` 函数，只在CPU空闲时占用其时间，用于调度统一化；
2. `initproc`，第1个内核线程，在本次实验中只用于打印字符串"hello world"。

#### 扩展练习 Challenge：

- 说明语句 `local_intr_save(intr_flag);....local_intr_restore(intr_flag);` 是如何实现开关中断的？

查看在 `sync.h` 中对这两个函数的定义： 

```c
//kern/sync/sync.h
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);
```
`__intr_save` 函数首先检查当前的控制状态，读取 `sstatus` 寄存器里的中断使能位 `SIE`，如果中断被使能，则调用 `intr_disable` 函数将它的值设为1，禁用全部中断，并返回1，否则返回0；  
`local_intr_save` 是一个包装了 `__intr_save` 函数的宏，它将参数x设为 `__intr_save` 的返回值，即中断是否已经被禁用。  
`local_intr_restore` 是一个包装了 `__intr_restore` 函数的宏，后者传入一个参数 flag，如果值为1，就调用 `intr_enable` 函数将中断使能位 `SIE` 设为0，恢复中断。

在实际使用这两条语句时，代码通常如下： 

```c
bool intr_flag;
local_intr_save(intr_flag);
//...
local_intr_restore(intr_flag);
```
定义的布尔变量 `intr_flag` 指示的是中断状态，如果当前的中断是打开的，`local_intr_save` 语句会首先禁用中断，返回时将它置为1，执行完关键代码后，再传入 `local_intr_restore` 语句中，启用中断。

#### 实验中重要的知识点
- 进程控制块用于管理进程（线程）
- 进程的创建和执行
- 进程的切换和基本调度
