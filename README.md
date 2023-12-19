# Operating System
## uCore on RISC-V step by step

- lab0 & lab0.5 - bootloader, kernel
- lab1 - trap
  - libs/sbi.c, kern/trap/trap.c
- lab2 - physical memory, page tables
  - kern/mm/best\_fit\_pmm.c
- lab3 - page fault, virtual memory, page replacement
  - kern/mm/vmm.c, swap_clock.c
- lab4 - kernel thread management
  - kern/process/proc.c
- lab5 - user process
  - kern/process/proc.c, kern/mm/pmm.c
- lab6 - process scheduling
  - kern/schedule/default\_sched_stride.c
- lab8 - file system
  - kern/fs/sfs/sfs_inode.c, kern/process/proc.c
