# Lab1：断，都可以断

对实验报告的要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

#### 练习1：理解内核启动中的程序入口操作

Q：阅读 kern/init/entry.S 内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？tail kern_init 完成了什么操作，目的是什么？

A：entry.S 设置的是操作系统内核的运行环境；可以看到，`kern_entry` 函数是 `.text` 代码段的开头，这个函数里一共有两条语句：

1. `la sp bootstacktop`：将一个内存地址 `bootstacktop` 加载到栈指针寄存器 `sp` 里。
2. `tail kern_init`：尾调用，通过伪指令 `tail` 进入 `kern_init` 初始化函数，也就是说内核运行环境设置结束了，正式进入内核。

在汇编语言中，`tail` 指令通常用于执行函数调用，但与传统的函数调用不同，它是一种尾递归调用，也就是说，在执行 `tail kern_init` 之后，不会再返回到调用 `tail kern_init` 的指令，而是直接跳转到 `kern_init` 函数的开头。这可以有效地减少函数调用的堆栈开销，因为不需要保存调用 `tail kern_init` 的函数的堆栈帧信息。

而 `bootstacktop` 又是什么？往下读，可以看到它是 `.data` 数据段的结束地址，在前面开辟了一块 `KSTACKSIZE` 大小的空间作为内核的栈，因此这是栈顶，即把栈指针寄存器指向了栈顶。

#### 练习2：完善中断处理 （需要编程）

Q：请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。

要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。

A：每秒 100 次时钟中断，触发每次时钟中断后，设置 10ms 后触发下一次时钟中断；每触发 100 次时钟中断，打印一行文字到控制台；定义一个输出次数变量，每打印一行就++，输出 10 行后就关机。

```c
//kern/trap/trap.c
#include <clock.h>
#include <sbi.h>

#define TICK_NUM 100
volatile size_t num = 0;
static void print_ticks() {
    cprintf("%d ticks\n", TICK_NUM);
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
        /* other cases*/
        case IRQ_S_TIMER:
            clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
            if (++ticks % TICK_NUM == 0) {
                print_ticks();
                if (++num == 10)
                  sbi_shutdown();
            }
            break;
        /* other cases*/
    }
}
```

编译执行无误，输出 10 行 "100 ticks" 后关机。

#### 扩展练习 Challenge1：描述与理解中断流程

Q：描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。

A：

1. `mov a0, sp` 的目的是传递参数，将栈寄存器 `sp` 的值（即 trapFrame 结构体的地址）赋给 `a0` 寄存器，后者接下来传参给调用函数 `trap`，以便根据结构体中 CSR 里保存的相关信息进行进一步处理。
2. 处理中断异常的流程：产生——硬件自动设置寄存器，`stvec ` 跳到中断处理程序入口点 `trapentry` —— `SAVE_ALL` 保存所有寄存器到栈顶（实际上就是把一个 trapFrame 结构体放到了栈顶）—— tail 指令进入中断处理函数 `trap`，执行 `trap_dispatch` 函数，把中断异常工作分发给对应的 handler，后者再根据中断或异常的不同类型进行相应处理—— `RESTORE_ALL` 恢复上下文——结束。
3. 寄存器保存在栈中的位置是栈指针 `sp` 加上偏移量确定的，偏移量就是寄存器的编号乘以 `REGBYTES` （一个寄存器占据的空间大小）。
4. 不一定需要，不是所有 CSR 的信息都在中断处理时用得上，就不用保存。 

#### 扩增练习 Challenge2：理解上下文切换机制

Q：在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

A：

1. `csrw sscratch, sp` 是保存原先的栈指针到 `sscratch`（一个特权寄存器）；`csrrw s0, sscratch, x0` 是将 `sscratch` 的值存到通用寄存器 `s0` 中，再将 `sscratch` 置零。这两条操作其实就是为了将原先的栈指针 `sp` 保存在 trapFrame 中，以便中断处理结束后还原。
2. 因为 `stval`、`scause` 保存的数据是中断辅助信息和中断原因，保存这些信息是为了中断处理程序使用，但处理结束后就不需要了，所以不用恢复。

#### 扩展练习 Challenge3：完善异常中断

Q：编程完善在触发一条非法指令异常 mret，在 kern/trap/trap.c 的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

A：在 trap.c 的异常处理函数中找到对应的 case，添加输出语句。注意对用户主动触发的异常，处理函数需要调整程序计数器 epc 以跳过这条指令，要手动将 epc+2。

```c
//kern/trap/trap.c
void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
        /* other cases*/
      case CAUSE_ILLEGAL_INSTUCTION:
        cprintf("Exception type:Illegal instruction\n");
        cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
        tf->epc += 2;
        break;
      case CAUSE_BREAKPOINT:
        cprintf("Exception type: breakpoint\n");
        cprintf("ebreak caught at 0x%016llx\n", tf->epc);
        tf->epc += 2;
        break;
        /* other cases*/
    }
}
```

在时钟中断结束后通过内联汇编加入 `ebreak` 和 `mret` 就可以触发异常，运行输出了正确的异常类型和异常指令触发地址。

#### 实验中重要的知识点

- RISC-V 的中断处理机制、相关寄存器与指令：通过处理时钟中断完整地体验了中断处理的流程。
- 上下文保存与恢复：非常详细地展示了如何在汇编代码中通过 trapFrame 结构体实现寄存器在栈上的保存和恢复，充分理解了上下文切换机制。
- 中断处理程序：阅读 trap.c 代码，理解了中断处理程序如何通过中断异常类别的不同将工作分发给不同处理函数。

#### 实验中没有提及的知识点

- 中断向量表：stvec除了保存中断向量表基址BASE以外，还可以设置两种模式，Vector模式是我们学的那种狭义的中断向量表（即，要根据中断原因跳到不同的中断处理程序pc=BASE+4*cause），但实验里为了简化它设置成了Direct模式，无论什么中断发生都直接跳到BASE，就是实际上只有统一的一个中断处理程序，`stvec` 直接跳到了它的入口点，没有对中断向量表做进一步探索。