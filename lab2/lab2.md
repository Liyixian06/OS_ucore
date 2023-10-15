# Lab2：物理内存和页表

对实验报告的要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

#### 练习1：理解first-fit 连续物理内存分配算法（思考题）

first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合 `kern/mm/default_pmm.c` 中的相关代码，认真分析 default_init，default_init_memmap，default_alloc_pages， default_free_pages 等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 你的first fit算法是否有进一步的改进空间？

首先是每个物理页面的属性结构体 Page，有如下四个成员变量：

- `ref`：映射到此物理页的虚拟页个数；
- `flags`：状态标志，有两个标志位，`PG_Reserved` 表示是否被保留（即是否可用，不可用如内核代码占据的空间），`PG_Property` 表示是否是一段空闲区间的 head（如果为 0，表明此页或者不空闲，或者不是 head）；
- `property`：连续空闲内存块的大小（有多少个页面）；
- `page_link`：链接多个连续空闲内存块的双向链表指针；

注意，只有连续空闲内存块的 head page 才会用到 `property` 和 `page_link`。

`default_pmm.c` 中实现了一个 pmm_manager 类型结构体的函数端口，主要有如下几个函数：

- `default_init`：初始化 pmm_manager 内部的数据结构，包括：
  - 初始化存放空闲页面的链表 free_list（注意，该链表中存放的空闲区间地址应该是递增的）；
  - 将记录可用物理页面数量的变量 nr_free 置零；
  
- `default_init_memmap`：知道了可用的物理页面数目 n 之后，进行更详细的初始化：

  - 页面信息初始化：
    - 对 base 开始的 n 个页面，清空标志和属性信息，引用计数置零；
    - 特别地，只有 base 的 property=n，表示它是 n 个 free block 的 head；
  - 将空闲页面计数 nr_free + n；
  - 将 base 插入 free_list 中：
    - free_list 为空，直接添加；
    - 不为空，遍历 free_list 找到第一个地址大于 base 的 page，将 base 插入到它之前；除非一直遍历到结尾，就将其加到最后；

- `default_alloc_pages`：分配 n 个物理页面：

  - 检查是否有足够的空闲页面用于分配；

  - 从头遍历 free_list，找到第一个 property 足够多的 page；

  - 从 page 中分出所需的页面：

    - 从 free_list 中删除 page，清空属性信息，表示该分区已经被分配；

    - 如果有剩余页面，对剩余页的 head 设置属性信息和 property，将其插入 free_list；

	- nr_free - n，返回已分配的页面；

- `default_free_pages`：释放 base 为起始地址的 n 个物理页面：
  - 重置要释放的所有页面的信息，nr_free + n；

  - 将 base 插入 free_list 中，具体实现同 `default_init_memmap`；

  - 检查 base 在 free_list 的前后元素和它是否相邻，相邻则合并；

- `default_nr_free_pages`：返回可用的物理页面数 nr_free。

算法改进：

有序链表插入在特殊情况下可以优化：对一个刚被释放的内存块，如果它的相邻区间也是空闲的，就可以直接合并，无需进行 O(n) 的链表插入操作。为了判断相邻区间是否空闲，空闲区间的信息还需要在最后一页也保存，这样新释放的空闲块只要检查相邻的两个页面，就能判断相邻区间的状态。

#### 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）

在完成练习一后，参考 kern/mm/default_pmm.c 对 Best Fit 算法的实现，编程实现 Best Fit 页面分配算法，算法的时空复杂度不做要求，能通过测试即可。 请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：

- 你的 Best-Fit 算法是否有进一步的改进空间？

`best_fit_pmm.c` 中实现的函数和 `default_pmm.c` 在功能上完全一致，其中实际上有区别的只有分配算法 `best_fit_alloc_pages`：`dafault_alloc_pages` 实现的 first-fit 算法是在 free_link 中找到第一个大小足够的区间，而 best-fit 则是遍历整个 free_link，不断刷新当前找到的最小连续空闲页面数量（即符合条件的 page->property），遍历结束后，使用这个最小的区间进行物理内存分配。

```c
static struct Page *best_fit_alloc_pages(size_t n) {
  	//前面和 first-fit 相同
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n && p->property < min_size) {
            min_size = p->property;
            page = p;
        }
    }
  	//后面和 first-fit 也相同
}
```

算法改进：

链表查找在特殊情况下可以优化：best-fit 的时间主要耗费在查找最小满足条件的空闲区间上，可以维护一个当前最小连续空闲区间及其页面数的全局变量，每次释放页面的时候都更新；分配页面时如果最小区间的大小足够，就可以直接分配，无需进行 O(n) 的链表查找操作。

#### 扩展练习Challenge1：buddy system（伙伴系统）分配算法（需要编程）

Buddy System 算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是 2 的 n 次幂(Pow(2, n))，即1, 2, 4, 8, 16, 32, 64, 128...

- 参考[伙伴分配器的一个极简实现](http://coolshell.cn/articles/10427.html)， 在 ucore 中实现 buddy system 分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

#### 扩展练习Challenge2：任意大小的内存单元slub分配算法（需要编程）

slub 算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。

- 参考[linux的slub分配算法](http://www.ibm.com/developerworks/cn/linux/l-cn-slub/)，在 ucore 中实现 slub 分配算法。要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

#### 扩展练习Challenge3：硬件的可用物理内存范围的获取方法（思考题）

- 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？

#### 实验中重要的知识点

- 物理内存管理
- 页表的建立和使用
- 页面分配算法

#### 实验中没有提及的知识点

- 虚拟内存管理
- 增加/搜索/删除页面的映射
- 多级页表
