# Lab3：缺页异常和页面置换

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

#### 练习1：理解基于FIFO的页面替换算法（思考题）
描述 FIFO 页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将 FIFO 页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）
 - 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响，删去后会导致输出结果不同的函数（例如 assert）而不是 cprintf 这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

1. 在页面换入的过程中，首先检查访问异常的地址是否属于某个 vma 表示的合法虚拟地址，然后调用 swap.c 中的换入函数 `swap_in`：分配一个内存页，然后查找/创建对应的页表项，找到硬盘地址，将数据从硬盘读入这个内存页。
   1. 分配内存页通过 pmm.c 中函数 `alloc_pages` 作为接口，调用 lab2 定义的 pmm_manager 的同名成员函数（以默认的 first-fit 为例，从空闲页块链表中找到第一个适合大小的空闲页块，然后进行分配）；
   2. 查找/创建页表项时调用 pmm.c 中函数 `get_pte`，通过虚拟地址首先找到对应的 Giga Page，然后往下一级一级查找页表，不存在就创建，最后找到页表项的地址；
   3. 数据读入内存页时调用 kern/fs/swapfs.c 中函数 `swapfs_read`，将内存页转换为物理地址，传入 `ide_read_secs` 函数，将硬盘数据读到这个物理地址上。

2. 调用 pmm.c 中的 `page_insert` 函数将虚拟地址映射到物理地址，在页表项中设置要映射的物理地址及权限位，然后刷新 TLB。
3. 以 swap.c 中函数 `swap_map_swappable` 函数为接口，调用 swap_manager_fifo 的成员函数 `_fifo_map_swappable`，将内存页插入到可用页面链表 pra_list_head 的末尾，设置该页可以换出。
4. 换出时，采用的是消极换出策略，在调用 `alloc_pages` 函数获取空闲页面时，如果发现无法从物理内存页分配器获得空闲页，就会进一步调用 swap.c 中换出函数 `swap_out` 换出某个页面：选择要换出的页面，通过虚拟地址在页表项中找到物理页，将其写入硬盘，释放该页面。
   1. 查询需要被换出的页面时，以 `swap_out_victim` 为接口调用 swap_manager_fifo 的成员函数 `_fifo_swap_out_victim`，从可用页面链表 pra_list_head 找到最早访问的页面，将其从链表中删除并返回；
      1. 在 pra_list_head 中找到的是代表最早访问页面的 list_entry_t* 指针，将其转换为内存页要通过 memlayout.h 中的 `le2page` 函数，通过从该指针减去它在 Page 结构体中的偏移量，推导出整个结构体的指针；
   2. 通过页面虚拟地址查找其物理地址时，也要查找其页表项，和换入过程类似，也使用了 `get_pte` 函数；
   3. 数据写入硬盘时调用 kern/fs/swapfs.c 中函数 `swapfs_write`，将内存页转换为物理地址，传入 `ide_write_secs` 函数，将这个物理地址的页面大小的数据读进硬盘；
   4. 最后以 `tlb_invalidate` 函数为接口，调用 pmm.h 中内联函数 `flush_tlb`，直接使用 RISC-V 在 S 模式下的特权指令 sfence.vma 刷新 TLB。

#### 练习2：深入理解不同分页模式的工作原理（思考题）
get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。
 - get_pte() 函数中有两段形式类似的代码， 结合 sv32，sv39，sv48 的异同，解释这两段代码为什么如此相像。

这两段类似的代码用于处理虚拟地址到页表项的映射，确保页表的层次结构正确，它们很相像，是因为它们用于不同级别的页表；`pdep1` 是虚拟地址的一级页表项指针，`pdep2` 是二级页表项指针，虽然层次结构有区别，但逻辑完全一致，都是通过虚拟地址在上级页表找到对应偏移，检查下级页表是否存在（`PTE_V` 标志位是否置位），若不存在则分配一个新页面并创建相应的页表，因此代码结构也非常相似。

类似地，sv32，sv39，sv48 是 RISC-V 的几种不同分页机制，数字代表虚拟地址的位数；它们都使用了多级页表的映射方式，虚拟地址的结构也是一样的，都是 N 级页号 + 偏移，区别只在于级数不同，以及每级页号和偏移的位数不同。

 - 目前 get_pte() 函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

目前为止，这种写法是合理的，因为在代码当前实现的功能中，查找不到页表项时接下来一定要分配，这么写可以简化代码逻辑、减少函数调用，确保查找失败时不会留下未初始化的页表项；尽管分配页表项的两段代码非常类似，理论上可以通过拆分进行复用，但当前的页表结构还比较简单，没有必要单独写一个函数。

#### 练习3：给未被映射的地址映射上物理页（需要编程）
补充完成 do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制结构所指定的页表，而不是内核的页表。
请在实验报告中简要说明你的设计实现过程。

在 do_pgfault 的已有代码中，已经查找/创建了未被映射的虚拟地址的页表项 ptep；接下来要首先分配一个物理页，将硬盘地址读入该物理页，建立一个虚拟地址到物理地址的映射，最后设置该页面可交换。

```c
//kern/mm/vmm.c
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
  //other codes
  ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
  if (*ptep == 0) {
  	//...
  } else {
    if (swap_init_ok) {
      struct Page *page = NULL;
      //(1）According to the mm AND addr, try to load the content of right disk page into the memory which page managed.
      swap_in(mm, addr, &page);
      //(2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr
      page_insert(mm->pgdir, page, addr, perm);
      //(3) make the page swappable.
      swap_map_swappable(mm, addr, page, 1);
      page->pra_vaddr = addr;
    } else {
      cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
      goto failed;
    }
  }
  //other codes
}
```

回答如下问题：

 - 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对 ucore 实现页替换算法的潜在用处。

表项中 PTE_A 表示内存页是否被访问过，PTE_D 表示内存页是否被修改过，借助这两个标志位，可以实现 Enhanced Clock 页替换算法。

 - 如果 ucore 的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

硬件将访问异常的地址和异常原因保存在 csr 中，触发 Page Fault 异常，将上述参数通过 trapframe 传给异常处理函数 `pgfault_handler`。

- 数据结构 Page 的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是什么？

Page 结构体的 pra_vaddr 字段用于描述页面对应的虚拟地址，就包含了页目录项和页表项在上级页表中的虚拟页号。

#### 练习4：补充完成Clock页替换算法（需要编程）
通过之前的练习，相信大家对 FIFO 的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock 页替换算法（mm/swap_clock.c）。
请在实验报告中简要说明你的设计实现过程。请回答如下问题：

 - 比较 Clock 页替换算法和 FIFO 算法的不同。

Clock 页替换算法相比 FIFO，后者只关心页面加载进内存的先后顺序，前者还考虑了页面的访问情况，跳过了被访问过（即访问位为1）的页，跳过时将其访问位置0。

设计 Clock 页替换算法时，关键的两个函数是 `_clock_map_swappable` 和  `_clock_swap_out_victim`，前者用于记录页访问情况，后者用于选择需要被换出的页；维护一个环形链表，存储所有可交换的页面，将元素插入到链表末尾。

具体实现如下：

```c
//kern/mm/swap_clock.c
list_entry_t pra_list_head, *curr_ptr;

static int _clock_init_mm(struct mm_struct *mm)
{     
     // 初始化pra_list_head为空链表
     list_init(&pra_list_head);
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     curr_ptr = &pra_list_head;
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv = &pra_list_head;
     //cprintf(" mm->sm_priv %x in clock_init_mm\n",mm->sm_priv);
     return 0;
}

// 将最近被用到的页面添加到页面链表的末尾
static int _clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
 
    assert(entry != NULL && curr_ptr != NULL);
    // 将页面page插入到页面链表pra_list_head的末尾
    list_add(head, entry);
    // 将页面的visited标志置为1，表示该页面已被访问
    page->visited = 1;
    return 0;
}

// 查询哪个页面需要被换出
static int _clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
     assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
    while (1) {
        // 查找最早未被访问的页面
        list_entry_t* entry = list_prev(head);
        // 获取当前页面对应的Page结构指针
        struct Page* page = le2page(entry, pra_page_link);
        if(entry == head){
        	*ptr_page = NULL;
        	break;
        }
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        if(page->visited == 0){
        	cprintf("curr_ptr %p\n", curr_ptr);
        	list_del(entry);
        	*ptr_page = le2page(entry, pra_page_link);
        	break;
        }
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        else{
        	page->visited = 0;
        	curr_ptr = entry;
        	entry = list_prev(entry);
        }
    }
    return 0;
}
```

#### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）
如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

好处：

1. 地址映射更直接、简单，不需要经过多级页表的跳跃，因此可以提高内存访问的性能；
2. 减少需要维护的页表项数量和开销，节省了页表的存储空间，简化内存管理。

坏处：

1. 大部分进程并不需要那么多虚拟地址空间，但“一个大页”会映射全部的虚拟地址空间，造成内存浪费；
2. 无法精细控制内存利用，容易导致大量无法使用的内存碎片。

#### 扩展练习 Challenge：实现不考虑实现开销和效率的 LRU 页替换算法（需要编程）
challenge 部分不是必做部分，不过在正确最后会酌情加分。需写出有详细的设计、分析和测试的实验报告。完成出色的可获得适当加分。

#### 实验中重要的知识点

- 多级页表实现的虚拟内存管理
- 处理缺页异常
- 页面置换机制和算法
