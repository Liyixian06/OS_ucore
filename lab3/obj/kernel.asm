
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56a60613          	addi	a2,a2,1386 # ffffffffc02115a8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	5f5030ef          	jal	ra,ffffffffc0203e42 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2d658593          	addi	a1,a1,726 # ffffffffc0204328 <etext+0x6>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	2ee50513          	addi	a0,a0,750 # ffffffffc0204348 <etext+0x26>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	100000ef          	jal	ra,ffffffffc0200166 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	79b000ef          	jal	ra,ffffffffc0201004 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	669010ef          	jal	ra,ffffffffc0201eda <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	35e000ef          	jal	ra,ffffffffc02003d4 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	472020ef          	jal	ra,ffffffffc02024ec <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	3ae000ef          	jal	ra,ffffffffc020042c <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	3f6000ef          	jal	ra,ffffffffc0200482 <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	627030ef          	jal	ra,ffffffffc0203ed8 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	5f3030ef          	jal	ra,ffffffffc0203ed8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3900006f          	j	ffffffffc0200482 <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	3be000ef          	jal	ra,ffffffffc02004b8 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200106:	00011317          	auipc	t1,0x11
ffffffffc020010a:	33a30313          	addi	t1,t1,826 # ffffffffc0211440 <is_panic>
ffffffffc020010e:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200112:	715d                	addi	sp,sp,-80
ffffffffc0200114:	ec06                	sd	ra,24(sp)
ffffffffc0200116:	e822                	sd	s0,16(sp)
ffffffffc0200118:	f436                	sd	a3,40(sp)
ffffffffc020011a:	f83a                	sd	a4,48(sp)
ffffffffc020011c:	fc3e                	sd	a5,56(sp)
ffffffffc020011e:	e0c2                	sd	a6,64(sp)
ffffffffc0200120:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200122:	02031c63          	bnez	t1,ffffffffc020015a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200126:	4785                	li	a5,1
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	00011717          	auipc	a4,0x11
ffffffffc020012e:	30f72b23          	sw	a5,790(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200132:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200134:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200136:	85aa                	mv	a1,a0
ffffffffc0200138:	00004517          	auipc	a0,0x4
ffffffffc020013c:	21850513          	addi	a0,a0,536 # ffffffffc0204350 <etext+0x2e>
    va_start(ap, fmt);
ffffffffc0200140:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200142:	f7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200146:	65a2                	ld	a1,8(sp)
ffffffffc0200148:	8522                	mv	a0,s0
ffffffffc020014a:	f55ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc020014e:	00005517          	auipc	a0,0x5
ffffffffc0200152:	08250513          	addi	a0,a0,130 # ffffffffc02051d0 <commands+0xd60>
ffffffffc0200156:	f69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020015a:	3a0000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020015e:	4501                	li	a0,0
ffffffffc0200160:	132000ef          	jal	ra,ffffffffc0200292 <kmonitor>
ffffffffc0200164:	bfed                	j	ffffffffc020015e <__panic+0x58>

ffffffffc0200166 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200166:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200168:	00004517          	auipc	a0,0x4
ffffffffc020016c:	23850513          	addi	a0,a0,568 # ffffffffc02043a0 <etext+0x7e>
void print_kerninfo(void) {
ffffffffc0200170:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200172:	f4dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200176:	00000597          	auipc	a1,0x0
ffffffffc020017a:	ec058593          	addi	a1,a1,-320 # ffffffffc0200036 <kern_init>
ffffffffc020017e:	00004517          	auipc	a0,0x4
ffffffffc0200182:	24250513          	addi	a0,a0,578 # ffffffffc02043c0 <etext+0x9e>
ffffffffc0200186:	f39ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020018a:	00004597          	auipc	a1,0x4
ffffffffc020018e:	19858593          	addi	a1,a1,408 # ffffffffc0204322 <etext>
ffffffffc0200192:	00004517          	auipc	a0,0x4
ffffffffc0200196:	24e50513          	addi	a0,a0,590 # ffffffffc02043e0 <etext+0xbe>
ffffffffc020019a:	f25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020019e:	0000a597          	auipc	a1,0xa
ffffffffc02001a2:	ea258593          	addi	a1,a1,-350 # ffffffffc020a040 <edata>
ffffffffc02001a6:	00004517          	auipc	a0,0x4
ffffffffc02001aa:	25a50513          	addi	a0,a0,602 # ffffffffc0204400 <etext+0xde>
ffffffffc02001ae:	f11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001b2:	00011597          	auipc	a1,0x11
ffffffffc02001b6:	3f658593          	addi	a1,a1,1014 # ffffffffc02115a8 <end>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	26650513          	addi	a0,a0,614 # ffffffffc0204420 <etext+0xfe>
ffffffffc02001c2:	efdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c6:	00011597          	auipc	a1,0x11
ffffffffc02001ca:	7e158593          	addi	a1,a1,2017 # ffffffffc02119a7 <end+0x3ff>
ffffffffc02001ce:	00000797          	auipc	a5,0x0
ffffffffc02001d2:	e6878793          	addi	a5,a5,-408 # ffffffffc0200036 <kern_init>
ffffffffc02001d6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001da:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001de:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001e0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e4:	95be                	add	a1,a1,a5
ffffffffc02001e6:	85a9                	srai	a1,a1,0xa
ffffffffc02001e8:	00004517          	auipc	a0,0x4
ffffffffc02001ec:	25850513          	addi	a0,a0,600 # ffffffffc0204440 <etext+0x11e>
}
ffffffffc02001f0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f2:	ecdff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02001f6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f6:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001f8:	00004617          	auipc	a2,0x4
ffffffffc02001fc:	17860613          	addi	a2,a2,376 # ffffffffc0204370 <etext+0x4e>
ffffffffc0200200:	04e00593          	li	a1,78
ffffffffc0200204:	00004517          	auipc	a0,0x4
ffffffffc0200208:	18450513          	addi	a0,a0,388 # ffffffffc0204388 <etext+0x66>
void print_stackframe(void) {
ffffffffc020020c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020e:	ef9ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200212 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200214:	00004617          	auipc	a2,0x4
ffffffffc0200218:	33460613          	addi	a2,a2,820 # ffffffffc0204548 <commands+0xd8>
ffffffffc020021c:	00004597          	auipc	a1,0x4
ffffffffc0200220:	34c58593          	addi	a1,a1,844 # ffffffffc0204568 <commands+0xf8>
ffffffffc0200224:	00004517          	auipc	a0,0x4
ffffffffc0200228:	34c50513          	addi	a0,a0,844 # ffffffffc0204570 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020022c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020022e:	e91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200232:	00004617          	auipc	a2,0x4
ffffffffc0200236:	34e60613          	addi	a2,a2,846 # ffffffffc0204580 <commands+0x110>
ffffffffc020023a:	00004597          	auipc	a1,0x4
ffffffffc020023e:	36e58593          	addi	a1,a1,878 # ffffffffc02045a8 <commands+0x138>
ffffffffc0200242:	00004517          	auipc	a0,0x4
ffffffffc0200246:	32e50513          	addi	a0,a0,814 # ffffffffc0204570 <commands+0x100>
ffffffffc020024a:	e75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020024e:	00004617          	auipc	a2,0x4
ffffffffc0200252:	36a60613          	addi	a2,a2,874 # ffffffffc02045b8 <commands+0x148>
ffffffffc0200256:	00004597          	auipc	a1,0x4
ffffffffc020025a:	38258593          	addi	a1,a1,898 # ffffffffc02045d8 <commands+0x168>
ffffffffc020025e:	00004517          	auipc	a0,0x4
ffffffffc0200262:	31250513          	addi	a0,a0,786 # ffffffffc0204570 <commands+0x100>
ffffffffc0200266:	e59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020026a:	60a2                	ld	ra,8(sp)
ffffffffc020026c:	4501                	li	a0,0
ffffffffc020026e:	0141                	addi	sp,sp,16
ffffffffc0200270:	8082                	ret

ffffffffc0200272 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
ffffffffc0200274:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200276:	ef1ff0ef          	jal	ra,ffffffffc0200166 <print_kerninfo>
    return 0;
}
ffffffffc020027a:	60a2                	ld	ra,8(sp)
ffffffffc020027c:	4501                	li	a0,0
ffffffffc020027e:	0141                	addi	sp,sp,16
ffffffffc0200280:	8082                	ret

ffffffffc0200282 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
ffffffffc0200284:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200286:	f71ff0ef          	jal	ra,ffffffffc02001f6 <print_stackframe>
    return 0;
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
ffffffffc020028c:	4501                	li	a0,0
ffffffffc020028e:	0141                	addi	sp,sp,16
ffffffffc0200290:	8082                	ret

ffffffffc0200292 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200292:	7115                	addi	sp,sp,-224
ffffffffc0200294:	e962                	sd	s8,144(sp)
ffffffffc0200296:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200298:	00004517          	auipc	a0,0x4
ffffffffc020029c:	22050513          	addi	a0,a0,544 # ffffffffc02044b8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002a0:	ed86                	sd	ra,216(sp)
ffffffffc02002a2:	e9a2                	sd	s0,208(sp)
ffffffffc02002a4:	e5a6                	sd	s1,200(sp)
ffffffffc02002a6:	e1ca                	sd	s2,192(sp)
ffffffffc02002a8:	fd4e                	sd	s3,184(sp)
ffffffffc02002aa:	f952                	sd	s4,176(sp)
ffffffffc02002ac:	f556                	sd	s5,168(sp)
ffffffffc02002ae:	f15a                	sd	s6,160(sp)
ffffffffc02002b0:	ed5e                	sd	s7,152(sp)
ffffffffc02002b2:	e566                	sd	s9,136(sp)
ffffffffc02002b4:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002b6:	e09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002ba:	00004517          	auipc	a0,0x4
ffffffffc02002be:	22650513          	addi	a0,a0,550 # ffffffffc02044e0 <commands+0x70>
ffffffffc02002c2:	dfdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc02002c6:	000c0563          	beqz	s8,ffffffffc02002d0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ca:	8562                	mv	a0,s8
ffffffffc02002cc:	492000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc02002d0:	00004c97          	auipc	s9,0x4
ffffffffc02002d4:	1a0c8c93          	addi	s9,s9,416 # ffffffffc0204470 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002d8:	00005997          	auipc	s3,0x5
ffffffffc02002dc:	6f898993          	addi	s3,s3,1784 # ffffffffc02059d0 <commands+0x1560>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	00004917          	auipc	s2,0x4
ffffffffc02002e4:	22890913          	addi	s2,s2,552 # ffffffffc0204508 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc02002e8:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ea:	00004b17          	auipc	s6,0x4
ffffffffc02002ee:	226b0b13          	addi	s6,s6,550 # ffffffffc0204510 <commands+0xa0>
    if (argc == 0) {
ffffffffc02002f2:	00004a97          	auipc	s5,0x4
ffffffffc02002f6:	276a8a93          	addi	s5,s5,630 # ffffffffc0204568 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002fc:	854e                	mv	a0,s3
ffffffffc02002fe:	767030ef          	jal	ra,ffffffffc0204264 <readline>
ffffffffc0200302:	842a                	mv	s0,a0
ffffffffc0200304:	dd65                	beqz	a0,ffffffffc02002fc <kmonitor+0x6a>
ffffffffc0200306:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020030a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	c999                	beqz	a1,ffffffffc0200322 <kmonitor+0x90>
ffffffffc020030e:	854a                	mv	a0,s2
ffffffffc0200310:	315030ef          	jal	ra,ffffffffc0203e24 <strchr>
ffffffffc0200314:	c925                	beqz	a0,ffffffffc0200384 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200316:	00144583          	lbu	a1,1(s0)
ffffffffc020031a:	00040023          	sb	zero,0(s0)
ffffffffc020031e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200320:	f5fd                	bnez	a1,ffffffffc020030e <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200322:	dce9                	beqz	s1,ffffffffc02002fc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	6582                	ld	a1,0(sp)
ffffffffc0200326:	00004d17          	auipc	s10,0x4
ffffffffc020032a:	14ad0d13          	addi	s10,s10,330 # ffffffffc0204470 <commands>
    if (argc == 0) {
ffffffffc020032e:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200330:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200332:	0d61                	addi	s10,s10,24
ffffffffc0200334:	2c7030ef          	jal	ra,ffffffffc0203dfa <strcmp>
ffffffffc0200338:	c919                	beqz	a0,ffffffffc020034e <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020033a:	2405                	addiw	s0,s0,1
ffffffffc020033c:	09740463          	beq	s0,s7,ffffffffc02003c4 <kmonitor+0x132>
ffffffffc0200340:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200344:	6582                	ld	a1,0(sp)
ffffffffc0200346:	0d61                	addi	s10,s10,24
ffffffffc0200348:	2b3030ef          	jal	ra,ffffffffc0203dfa <strcmp>
ffffffffc020034c:	f57d                	bnez	a0,ffffffffc020033a <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020034e:	00141793          	slli	a5,s0,0x1
ffffffffc0200352:	97a2                	add	a5,a5,s0
ffffffffc0200354:	078e                	slli	a5,a5,0x3
ffffffffc0200356:	97e6                	add	a5,a5,s9
ffffffffc0200358:	6b9c                	ld	a5,16(a5)
ffffffffc020035a:	8662                	mv	a2,s8
ffffffffc020035c:	002c                	addi	a1,sp,8
ffffffffc020035e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200362:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200364:	f8055ce3          	bgez	a0,ffffffffc02002fc <kmonitor+0x6a>
}
ffffffffc0200368:	60ee                	ld	ra,216(sp)
ffffffffc020036a:	644e                	ld	s0,208(sp)
ffffffffc020036c:	64ae                	ld	s1,200(sp)
ffffffffc020036e:	690e                	ld	s2,192(sp)
ffffffffc0200370:	79ea                	ld	s3,184(sp)
ffffffffc0200372:	7a4a                	ld	s4,176(sp)
ffffffffc0200374:	7aaa                	ld	s5,168(sp)
ffffffffc0200376:	7b0a                	ld	s6,160(sp)
ffffffffc0200378:	6bea                	ld	s7,152(sp)
ffffffffc020037a:	6c4a                	ld	s8,144(sp)
ffffffffc020037c:	6caa                	ld	s9,136(sp)
ffffffffc020037e:	6d0a                	ld	s10,128(sp)
ffffffffc0200380:	612d                	addi	sp,sp,224
ffffffffc0200382:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200384:	00044783          	lbu	a5,0(s0)
ffffffffc0200388:	dfc9                	beqz	a5,ffffffffc0200322 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020038a:	03448863          	beq	s1,s4,ffffffffc02003ba <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020038e:	00349793          	slli	a5,s1,0x3
ffffffffc0200392:	0118                	addi	a4,sp,128
ffffffffc0200394:	97ba                	add	a5,a5,a4
ffffffffc0200396:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020039e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a0:	e591                	bnez	a1,ffffffffc02003ac <kmonitor+0x11a>
ffffffffc02003a2:	b749                	j	ffffffffc0200324 <kmonitor+0x92>
            buf ++;
ffffffffc02003a4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a6:	00044583          	lbu	a1,0(s0)
ffffffffc02003aa:	ddad                	beqz	a1,ffffffffc0200324 <kmonitor+0x92>
ffffffffc02003ac:	854a                	mv	a0,s2
ffffffffc02003ae:	277030ef          	jal	ra,ffffffffc0203e24 <strchr>
ffffffffc02003b2:	d96d                	beqz	a0,ffffffffc02003a4 <kmonitor+0x112>
ffffffffc02003b4:	00044583          	lbu	a1,0(s0)
ffffffffc02003b8:	bf91                	j	ffffffffc020030c <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ba:	45c1                	li	a1,16
ffffffffc02003bc:	855a                	mv	a0,s6
ffffffffc02003be:	d01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003c2:	b7f1                	j	ffffffffc020038e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c4:	6582                	ld	a1,0(sp)
ffffffffc02003c6:	00004517          	auipc	a0,0x4
ffffffffc02003ca:	16a50513          	addi	a0,a0,362 # ffffffffc0204530 <commands+0xc0>
ffffffffc02003ce:	cf1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc02003d2:	b72d                	j	ffffffffc02002fc <kmonitor+0x6a>

ffffffffc02003d4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d4:	8082                	ret

ffffffffc02003d6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d6:	00253513          	sltiu	a0,a0,2
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003dc:	03800513          	li	a0,56
ffffffffc02003e0:	8082                	ret

ffffffffc02003e2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003e2:	0000a797          	auipc	a5,0xa
ffffffffc02003e6:	c5e78793          	addi	a5,a5,-930 # ffffffffc020a040 <edata>
ffffffffc02003ea:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ee:	1141                	addi	sp,sp,-16
ffffffffc02003f0:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f2:	95be                	add	a1,a1,a5
ffffffffc02003f4:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f8:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003fa:	25b030ef          	jal	ra,ffffffffc0203e54 <memcpy>
    return 0;
}
ffffffffc02003fe:	60a2                	ld	ra,8(sp)
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	0141                	addi	sp,sp,16
ffffffffc0200404:	8082                	ret

ffffffffc0200406 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200406:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200408:	0095979b          	slliw	a5,a1,0x9
ffffffffc020040c:	0000a517          	auipc	a0,0xa
ffffffffc0200410:	c3450513          	addi	a0,a0,-972 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc0200414:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200416:	00969613          	slli	a2,a3,0x9
ffffffffc020041a:	85ba                	mv	a1,a4
ffffffffc020041c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020041e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200420:	235030ef          	jal	ra,ffffffffc0203e54 <memcpy>
    return 0;
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	4501                	li	a0,0
ffffffffc0200428:	0141                	addi	sp,sp,16
ffffffffc020042a:	8082                	ret

ffffffffc020042c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020042c:	67e1                	lui	a5,0x18
ffffffffc020042e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200432:	00011717          	auipc	a4,0x11
ffffffffc0200436:	00f73b23          	sd	a5,22(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020043e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200440:	953e                	add	a0,a0,a5
ffffffffc0200442:	4601                	li	a2,0
ffffffffc0200444:	4881                	li	a7,0
ffffffffc0200446:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020044a:	02000793          	li	a5,32
ffffffffc020044e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200452:	00004517          	auipc	a0,0x4
ffffffffc0200456:	19650513          	addi	a0,a0,406 # ffffffffc02045e8 <commands+0x178>
    ticks = 0;
ffffffffc020045a:	00011797          	auipc	a5,0x11
ffffffffc020045e:	0207b323          	sd	zero,38(a5) # ffffffffc0211480 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200462:	c5dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200466 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200466:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020046a:	00011797          	auipc	a5,0x11
ffffffffc020046e:	fde78793          	addi	a5,a5,-34 # ffffffffc0211448 <timebase>
ffffffffc0200472:	639c                	ld	a5,0(a5)
ffffffffc0200474:	4581                	li	a1,0
ffffffffc0200476:	4601                	li	a2,0
ffffffffc0200478:	953e                	add	a0,a0,a5
ffffffffc020047a:	4881                	li	a7,0
ffffffffc020047c:	00000073          	ecall
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200482:	100027f3          	csrr	a5,sstatus
ffffffffc0200486:	8b89                	andi	a5,a5,2
ffffffffc0200488:	0ff57513          	andi	a0,a0,255
ffffffffc020048c:	e799                	bnez	a5,ffffffffc020049a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020048e:	4581                	li	a1,0
ffffffffc0200490:	4601                	li	a2,0
ffffffffc0200492:	4885                	li	a7,1
ffffffffc0200494:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200498:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020049a:	1101                	addi	sp,sp,-32
ffffffffc020049c:	ec06                	sd	ra,24(sp)
ffffffffc020049e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02004a0:	05a000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004a4:	6522                	ld	a0,8(sp)
ffffffffc02004a6:	4581                	li	a1,0
ffffffffc02004a8:	4601                	li	a2,0
ffffffffc02004aa:	4885                	li	a7,1
ffffffffc02004ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004b0:	60e2                	ld	ra,24(sp)
ffffffffc02004b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004b4:	0400006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc02004b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004b8:	100027f3          	csrr	a5,sstatus
ffffffffc02004bc:	8b89                	andi	a5,a5,2
ffffffffc02004be:	eb89                	bnez	a5,ffffffffc02004d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004c0:	4501                	li	a0,0
ffffffffc02004c2:	4581                	li	a1,0
ffffffffc02004c4:	4601                	li	a2,0
ffffffffc02004c6:	4889                	li	a7,2
ffffffffc02004c8:	00000073          	ecall
ffffffffc02004cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004ce:	8082                	ret
int cons_getc(void) {
ffffffffc02004d0:	1101                	addi	sp,sp,-32
ffffffffc02004d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004d4:	026000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	4889                	li	a7,2
ffffffffc02004e0:	00000073          	ecall
ffffffffc02004e4:	2501                	sext.w	a0,a0
ffffffffc02004e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004e8:	00c000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc02004ec:	60e2                	ld	ra,24(sp)
ffffffffc02004ee:	6522                	ld	a0,8(sp)
ffffffffc02004f0:	6105                	addi	sp,sp,32
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	42050513          	addi	a0,a0,1056 # ffffffffc0204950 <commands+0x4e0>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	f6c78793          	addi	a5,a5,-148 # ffffffffc02114a8 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	6c30106f          	j	ffffffffc0202418 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	41660613          	addi	a2,a2,1046 # ffffffffc0204970 <commands+0x500>
ffffffffc0200562:	07900593          	li	a1,121
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	42250513          	addi	a0,a0,1058 # ffffffffc0204988 <commands+0x518>
ffffffffc020056e:	b99ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	4fa78793          	addi	a5,a5,1274 # ffffffffc0200a70 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	40850513          	addi	a0,a0,1032 # ffffffffc02049a0 <commands+0x530>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	41050513          	addi	a0,a0,1040 # ffffffffc02049b8 <commands+0x548>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	41a50513          	addi	a0,a0,1050 # ffffffffc02049d0 <commands+0x560>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	42450513          	addi	a0,a0,1060 # ffffffffc02049e8 <commands+0x578>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	42e50513          	addi	a0,a0,1070 # ffffffffc0204a00 <commands+0x590>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	43850513          	addi	a0,a0,1080 # ffffffffc0204a18 <commands+0x5a8>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	44250513          	addi	a0,a0,1090 # ffffffffc0204a30 <commands+0x5c0>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	44c50513          	addi	a0,a0,1100 # ffffffffc0204a48 <commands+0x5d8>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	45650513          	addi	a0,a0,1110 # ffffffffc0204a60 <commands+0x5f0>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	46050513          	addi	a0,a0,1120 # ffffffffc0204a78 <commands+0x608>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	46a50513          	addi	a0,a0,1130 # ffffffffc0204a90 <commands+0x620>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	47450513          	addi	a0,a0,1140 # ffffffffc0204aa8 <commands+0x638>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	47e50513          	addi	a0,a0,1150 # ffffffffc0204ac0 <commands+0x650>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	48850513          	addi	a0,a0,1160 # ffffffffc0204ad8 <commands+0x668>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	49250513          	addi	a0,a0,1170 # ffffffffc0204af0 <commands+0x680>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	49c50513          	addi	a0,a0,1180 # ffffffffc0204b08 <commands+0x698>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	4a650513          	addi	a0,a0,1190 # ffffffffc0204b20 <commands+0x6b0>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	4b050513          	addi	a0,a0,1200 # ffffffffc0204b38 <commands+0x6c8>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	4ba50513          	addi	a0,a0,1210 # ffffffffc0204b50 <commands+0x6e0>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	4c450513          	addi	a0,a0,1220 # ffffffffc0204b68 <commands+0x6f8>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	4ce50513          	addi	a0,a0,1230 # ffffffffc0204b80 <commands+0x710>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	4d850513          	addi	a0,a0,1240 # ffffffffc0204b98 <commands+0x728>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	4e250513          	addi	a0,a0,1250 # ffffffffc0204bb0 <commands+0x740>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204bc8 <commands+0x758>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	4f650513          	addi	a0,a0,1270 # ffffffffc0204be0 <commands+0x770>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	50050513          	addi	a0,a0,1280 # ffffffffc0204bf8 <commands+0x788>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	50a50513          	addi	a0,a0,1290 # ffffffffc0204c10 <commands+0x7a0>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	51450513          	addi	a0,a0,1300 # ffffffffc0204c28 <commands+0x7b8>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	51e50513          	addi	a0,a0,1310 # ffffffffc0204c40 <commands+0x7d0>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	52850513          	addi	a0,a0,1320 # ffffffffc0204c58 <commands+0x7e8>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	53250513          	addi	a0,a0,1330 # ffffffffc0204c70 <commands+0x800>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	53850513          	addi	a0,a0,1336 # ffffffffc0204c88 <commands+0x818>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	53a50513          	addi	a0,a0,1338 # ffffffffc0204ca0 <commands+0x830>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	53a50513          	addi	a0,a0,1338 # ffffffffc0204cb8 <commands+0x848>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	54250513          	addi	a0,a0,1346 # ffffffffc0204cd0 <commands+0x860>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	54a50513          	addi	a0,a0,1354 # ffffffffc0204ce8 <commands+0x878>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	54e50513          	addi	a0,a0,1358 # ffffffffc0204d00 <commands+0x890>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	e3470713          	addi	a4,a4,-460 # ffffffffc0204604 <commands+0x194>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	11e50513          	addi	a0,a0,286 # ffffffffc0204900 <commands+0x490>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	0f250513          	addi	a0,a0,242 # ffffffffc02048e0 <commands+0x470>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	0a650513          	addi	a0,a0,166 # ffffffffc02048a0 <commands+0x430>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	0ba50513          	addi	a0,a0,186 # ffffffffc02048c0 <commands+0x450>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	11e50513          	addi	a0,a0,286 # ffffffffc0204930 <commands+0x4c0>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
			clock_set_next_event();
ffffffffc0200822:	c45ff0ef          	jal	ra,ffffffffc0200466 <clock_set_next_event>
			if(++ticks % TICK_NUM == 0){
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c5a78793          	addi	a5,a5,-934 # ffffffffc0211480 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c4f6b323          	sd	a5,-954(a3) # ffffffffc0211480 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020084e:	06400593          	li	a1,100
ffffffffc0200852:	00004517          	auipc	a0,0x4
ffffffffc0200856:	0ce50513          	addi	a0,a0,206 # ffffffffc0204920 <commands+0x4b0>
ffffffffc020085a:	865ff0ef          	jal	ra,ffffffffc02000be <cprintf>
				if(++num==10){
ffffffffc020085e:	00011797          	auipc	a5,0x11
ffffffffc0200862:	bf278793          	addi	a5,a5,-1038 # ffffffffc0211450 <num>
ffffffffc0200866:	639c                	ld	a5,0(a5)
ffffffffc0200868:	4729                	li	a4,10
ffffffffc020086a:	0785                	addi	a5,a5,1
ffffffffc020086c:	00011697          	auipc	a3,0x11
ffffffffc0200870:	bef6b223          	sd	a5,-1052(a3) # ffffffffc0211450 <num>
ffffffffc0200874:	fce798e3          	bne	a5,a4,ffffffffc0200844 <interrupt_handler+0x84>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200878:	4501                	li	a0,0
ffffffffc020087a:	4581                	li	a1,0
ffffffffc020087c:	4601                	li	a2,0
ffffffffc020087e:	48a1                	li	a7,8
ffffffffc0200880:	00000073          	ecall
ffffffffc0200884:	b7c1                	j	ffffffffc0200844 <interrupt_handler+0x84>

ffffffffc0200886 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200886:	11853783          	ld	a5,280(a0)
ffffffffc020088a:	473d                	li	a4,15
ffffffffc020088c:	1af76463          	bltu	a4,a5,ffffffffc0200a34 <exception_handler+0x1ae>
ffffffffc0200890:	00004717          	auipc	a4,0x4
ffffffffc0200894:	da470713          	addi	a4,a4,-604 # ffffffffc0204634 <commands+0x1c4>
ffffffffc0200898:	078a                	slli	a5,a5,0x2
ffffffffc020089a:	97ba                	add	a5,a5,a4
ffffffffc020089c:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020089e:	1101                	addi	sp,sp,-32
ffffffffc02008a0:	e822                	sd	s0,16(sp)
ffffffffc02008a2:	ec06                	sd	ra,24(sp)
ffffffffc02008a4:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc02008a6:	97ba                	add	a5,a5,a4
ffffffffc02008a8:	842a                	mv	s0,a0
ffffffffc02008aa:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc02008ac:	00004517          	auipc	a0,0x4
ffffffffc02008b0:	fdc50513          	addi	a0,a0,-36 # ffffffffc0204888 <commands+0x418>
ffffffffc02008b4:	80bff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008b8:	8522                	mv	a0,s0
ffffffffc02008ba:	c47ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008be:	84aa                	mv	s1,a0
ffffffffc02008c0:	16051c63          	bnez	a0,ffffffffc0200a38 <exception_handler+0x1b2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008c4:	60e2                	ld	ra,24(sp)
ffffffffc02008c6:	6442                	ld	s0,16(sp)
ffffffffc02008c8:	64a2                	ld	s1,8(sp)
ffffffffc02008ca:	6105                	addi	sp,sp,32
ffffffffc02008cc:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008ce:	00004517          	auipc	a0,0x4
ffffffffc02008d2:	daa50513          	addi	a0,a0,-598 # ffffffffc0204678 <commands+0x208>
}
ffffffffc02008d6:	6442                	ld	s0,16(sp)
ffffffffc02008d8:	60e2                	ld	ra,24(sp)
ffffffffc02008da:	64a2                	ld	s1,8(sp)
ffffffffc02008dc:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008de:	fe0ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008e2:	00004517          	auipc	a0,0x4
ffffffffc02008e6:	db650513          	addi	a0,a0,-586 # ffffffffc0204698 <commands+0x228>
ffffffffc02008ea:	b7f5                	j	ffffffffc02008d6 <exception_handler+0x50>
			cprintf("Exception Type: Illegal instruction\n");
ffffffffc02008ec:	00004517          	auipc	a0,0x4
ffffffffc02008f0:	dcc50513          	addi	a0,a0,-564 # ffffffffc02046b8 <commands+0x248>
ffffffffc02008f4:	fcaff0ef          	jal	ra,ffffffffc02000be <cprintf>
			cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
ffffffffc02008f8:	10843583          	ld	a1,264(s0)
ffffffffc02008fc:	00004517          	auipc	a0,0x4
ffffffffc0200900:	de450513          	addi	a0,a0,-540 # ffffffffc02046e0 <commands+0x270>
ffffffffc0200904:	fbaff0ef          	jal	ra,ffffffffc02000be <cprintf>
			tf->epc += 2;
ffffffffc0200908:	10843783          	ld	a5,264(s0)
ffffffffc020090c:	0789                	addi	a5,a5,2
ffffffffc020090e:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200912:	bf4d                	j	ffffffffc02008c4 <exception_handler+0x3e>
			cprintf("Exception Type: breakpoint\n");
ffffffffc0200914:	00004517          	auipc	a0,0x4
ffffffffc0200918:	dfc50513          	addi	a0,a0,-516 # ffffffffc0204710 <commands+0x2a0>
ffffffffc020091c:	fa2ff0ef          	jal	ra,ffffffffc02000be <cprintf>
			cprintf("ebreak caught at 0x%016llx\n", tf->epc);
ffffffffc0200920:	10843583          	ld	a1,264(s0)
ffffffffc0200924:	00004517          	auipc	a0,0x4
ffffffffc0200928:	e0c50513          	addi	a0,a0,-500 # ffffffffc0204730 <commands+0x2c0>
ffffffffc020092c:	f92ff0ef          	jal	ra,ffffffffc02000be <cprintf>
			tf->epc += 2;
ffffffffc0200930:	10843783          	ld	a5,264(s0)
ffffffffc0200934:	0789                	addi	a5,a5,2
ffffffffc0200936:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc020093a:	b769                	j	ffffffffc02008c4 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc020093c:	00004517          	auipc	a0,0x4
ffffffffc0200940:	e1450513          	addi	a0,a0,-492 # ffffffffc0204750 <commands+0x2e0>
ffffffffc0200944:	bf49                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200946:	00004517          	auipc	a0,0x4
ffffffffc020094a:	e2a50513          	addi	a0,a0,-470 # ffffffffc0204770 <commands+0x300>
ffffffffc020094e:	f70ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200952:	8522                	mv	a0,s0
ffffffffc0200954:	badff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200958:	84aa                	mv	s1,a0
ffffffffc020095a:	d52d                	beqz	a0,ffffffffc02008c4 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020095c:	8522                	mv	a0,s0
ffffffffc020095e:	e01ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200962:	86a6                	mv	a3,s1
ffffffffc0200964:	00004617          	auipc	a2,0x4
ffffffffc0200968:	e2460613          	addi	a2,a2,-476 # ffffffffc0204788 <commands+0x318>
ffffffffc020096c:	0e900593          	li	a1,233
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	01850513          	addi	a0,a0,24 # ffffffffc0204988 <commands+0x518>
ffffffffc0200978:	f8eff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020097c:	00004517          	auipc	a0,0x4
ffffffffc0200980:	e2c50513          	addi	a0,a0,-468 # ffffffffc02047a8 <commands+0x338>
ffffffffc0200984:	bf89                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200986:	00004517          	auipc	a0,0x4
ffffffffc020098a:	e3a50513          	addi	a0,a0,-454 # ffffffffc02047c0 <commands+0x350>
ffffffffc020098e:	f30ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200992:	8522                	mv	a0,s0
ffffffffc0200994:	b6dff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200998:	84aa                	mv	s1,a0
ffffffffc020099a:	f20505e3          	beqz	a0,ffffffffc02008c4 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020099e:	8522                	mv	a0,s0
ffffffffc02009a0:	dbfff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009a4:	86a6                	mv	a3,s1
ffffffffc02009a6:	00004617          	auipc	a2,0x4
ffffffffc02009aa:	de260613          	addi	a2,a2,-542 # ffffffffc0204788 <commands+0x318>
ffffffffc02009ae:	0f300593          	li	a1,243
ffffffffc02009b2:	00004517          	auipc	a0,0x4
ffffffffc02009b6:	fd650513          	addi	a0,a0,-42 # ffffffffc0204988 <commands+0x518>
ffffffffc02009ba:	f4cff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc02009be:	00004517          	auipc	a0,0x4
ffffffffc02009c2:	e1a50513          	addi	a0,a0,-486 # ffffffffc02047d8 <commands+0x368>
ffffffffc02009c6:	bf01                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	e3050513          	addi	a0,a0,-464 # ffffffffc02047f8 <commands+0x388>
ffffffffc02009d0:	b719                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc02009d2:	00004517          	auipc	a0,0x4
ffffffffc02009d6:	e4650513          	addi	a0,a0,-442 # ffffffffc0204818 <commands+0x3a8>
ffffffffc02009da:	bdf5                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009dc:	00004517          	auipc	a0,0x4
ffffffffc02009e0:	e5c50513          	addi	a0,a0,-420 # ffffffffc0204838 <commands+0x3c8>
ffffffffc02009e4:	bdcd                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009e6:	00004517          	auipc	a0,0x4
ffffffffc02009ea:	e7250513          	addi	a0,a0,-398 # ffffffffc0204858 <commands+0x3e8>
ffffffffc02009ee:	b5e5                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009f0:	00004517          	auipc	a0,0x4
ffffffffc02009f4:	e8050513          	addi	a0,a0,-384 # ffffffffc0204870 <commands+0x400>
ffffffffc02009f8:	ec6ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009fc:	8522                	mv	a0,s0
ffffffffc02009fe:	b03ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200a02:	84aa                	mv	s1,a0
ffffffffc0200a04:	ec0500e3          	beqz	a0,ffffffffc02008c4 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a08:	8522                	mv	a0,s0
ffffffffc0200a0a:	d55ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a0e:	86a6                	mv	a3,s1
ffffffffc0200a10:	00004617          	auipc	a2,0x4
ffffffffc0200a14:	d7860613          	addi	a2,a2,-648 # ffffffffc0204788 <commands+0x318>
ffffffffc0200a18:	10900593          	li	a1,265
ffffffffc0200a1c:	00004517          	auipc	a0,0x4
ffffffffc0200a20:	f6c50513          	addi	a0,a0,-148 # ffffffffc0204988 <commands+0x518>
ffffffffc0200a24:	ee2ff0ef          	jal	ra,ffffffffc0200106 <__panic>
}
ffffffffc0200a28:	6442                	ld	s0,16(sp)
ffffffffc0200a2a:	60e2                	ld	ra,24(sp)
ffffffffc0200a2c:	64a2                	ld	s1,8(sp)
ffffffffc0200a2e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a30:	d2fff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc0200a34:	d2bff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a38:	8522                	mv	a0,s0
ffffffffc0200a3a:	d25ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a3e:	86a6                	mv	a3,s1
ffffffffc0200a40:	00004617          	auipc	a2,0x4
ffffffffc0200a44:	d4860613          	addi	a2,a2,-696 # ffffffffc0204788 <commands+0x318>
ffffffffc0200a48:	11000593          	li	a1,272
ffffffffc0200a4c:	00004517          	auipc	a0,0x4
ffffffffc0200a50:	f3c50513          	addi	a0,a0,-196 # ffffffffc0204988 <commands+0x518>
ffffffffc0200a54:	eb2ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200a58 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a58:	11853783          	ld	a5,280(a0)
ffffffffc0200a5c:	0007c463          	bltz	a5,ffffffffc0200a64 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a60:	e27ff06f          	j	ffffffffc0200886 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a64:	d5dff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a70 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a70:	14011073          	csrw	sscratch,sp
ffffffffc0200a74:	712d                	addi	sp,sp,-288
ffffffffc0200a76:	e406                	sd	ra,8(sp)
ffffffffc0200a78:	ec0e                	sd	gp,24(sp)
ffffffffc0200a7a:	f012                	sd	tp,32(sp)
ffffffffc0200a7c:	f416                	sd	t0,40(sp)
ffffffffc0200a7e:	f81a                	sd	t1,48(sp)
ffffffffc0200a80:	fc1e                	sd	t2,56(sp)
ffffffffc0200a82:	e0a2                	sd	s0,64(sp)
ffffffffc0200a84:	e4a6                	sd	s1,72(sp)
ffffffffc0200a86:	e8aa                	sd	a0,80(sp)
ffffffffc0200a88:	ecae                	sd	a1,88(sp)
ffffffffc0200a8a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a8c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a8e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a90:	fcbe                	sd	a5,120(sp)
ffffffffc0200a92:	e142                	sd	a6,128(sp)
ffffffffc0200a94:	e546                	sd	a7,136(sp)
ffffffffc0200a96:	e94a                	sd	s2,144(sp)
ffffffffc0200a98:	ed4e                	sd	s3,152(sp)
ffffffffc0200a9a:	f152                	sd	s4,160(sp)
ffffffffc0200a9c:	f556                	sd	s5,168(sp)
ffffffffc0200a9e:	f95a                	sd	s6,176(sp)
ffffffffc0200aa0:	fd5e                	sd	s7,184(sp)
ffffffffc0200aa2:	e1e2                	sd	s8,192(sp)
ffffffffc0200aa4:	e5e6                	sd	s9,200(sp)
ffffffffc0200aa6:	e9ea                	sd	s10,208(sp)
ffffffffc0200aa8:	edee                	sd	s11,216(sp)
ffffffffc0200aaa:	f1f2                	sd	t3,224(sp)
ffffffffc0200aac:	f5f6                	sd	t4,232(sp)
ffffffffc0200aae:	f9fa                	sd	t5,240(sp)
ffffffffc0200ab0:	fdfe                	sd	t6,248(sp)
ffffffffc0200ab2:	14002473          	csrr	s0,sscratch
ffffffffc0200ab6:	100024f3          	csrr	s1,sstatus
ffffffffc0200aba:	14102973          	csrr	s2,sepc
ffffffffc0200abe:	143029f3          	csrr	s3,stval
ffffffffc0200ac2:	14202a73          	csrr	s4,scause
ffffffffc0200ac6:	e822                	sd	s0,16(sp)
ffffffffc0200ac8:	e226                	sd	s1,256(sp)
ffffffffc0200aca:	e64a                	sd	s2,264(sp)
ffffffffc0200acc:	ea4e                	sd	s3,272(sp)
ffffffffc0200ace:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ad0:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ad2:	f87ff0ef          	jal	ra,ffffffffc0200a58 <trap>

ffffffffc0200ad6 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ad6:	6492                	ld	s1,256(sp)
ffffffffc0200ad8:	6932                	ld	s2,264(sp)
ffffffffc0200ada:	10049073          	csrw	sstatus,s1
ffffffffc0200ade:	14191073          	csrw	sepc,s2
ffffffffc0200ae2:	60a2                	ld	ra,8(sp)
ffffffffc0200ae4:	61e2                	ld	gp,24(sp)
ffffffffc0200ae6:	7202                	ld	tp,32(sp)
ffffffffc0200ae8:	72a2                	ld	t0,40(sp)
ffffffffc0200aea:	7342                	ld	t1,48(sp)
ffffffffc0200aec:	73e2                	ld	t2,56(sp)
ffffffffc0200aee:	6406                	ld	s0,64(sp)
ffffffffc0200af0:	64a6                	ld	s1,72(sp)
ffffffffc0200af2:	6546                	ld	a0,80(sp)
ffffffffc0200af4:	65e6                	ld	a1,88(sp)
ffffffffc0200af6:	7606                	ld	a2,96(sp)
ffffffffc0200af8:	76a6                	ld	a3,104(sp)
ffffffffc0200afa:	7746                	ld	a4,112(sp)
ffffffffc0200afc:	77e6                	ld	a5,120(sp)
ffffffffc0200afe:	680a                	ld	a6,128(sp)
ffffffffc0200b00:	68aa                	ld	a7,136(sp)
ffffffffc0200b02:	694a                	ld	s2,144(sp)
ffffffffc0200b04:	69ea                	ld	s3,152(sp)
ffffffffc0200b06:	7a0a                	ld	s4,160(sp)
ffffffffc0200b08:	7aaa                	ld	s5,168(sp)
ffffffffc0200b0a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b0c:	7bea                	ld	s7,184(sp)
ffffffffc0200b0e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b10:	6cae                	ld	s9,200(sp)
ffffffffc0200b12:	6d4e                	ld	s10,208(sp)
ffffffffc0200b14:	6dee                	ld	s11,216(sp)
ffffffffc0200b16:	7e0e                	ld	t3,224(sp)
ffffffffc0200b18:	7eae                	ld	t4,232(sp)
ffffffffc0200b1a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b1c:	7fee                	ld	t6,248(sp)
ffffffffc0200b1e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200b20:	10200073          	sret
	...

ffffffffc0200b30 <pa2page.part.4>:

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200b30:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200b32:	00004617          	auipc	a2,0x4
ffffffffc0200b36:	26660613          	addi	a2,a2,614 # ffffffffc0204d98 <commands+0x928>
ffffffffc0200b3a:	06500593          	li	a1,101
ffffffffc0200b3e:	00004517          	auipc	a0,0x4
ffffffffc0200b42:	27a50513          	addi	a0,a0,634 # ffffffffc0204db8 <commands+0x948>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200b46:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200b48:	dbeff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200b4c <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200b4c:	715d                	addi	sp,sp,-80
ffffffffc0200b4e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b50:	fc26                	sd	s1,56(sp)
ffffffffc0200b52:	f84a                	sd	s2,48(sp)
ffffffffc0200b54:	f44e                	sd	s3,40(sp)
ffffffffc0200b56:	f052                	sd	s4,32(sp)
ffffffffc0200b58:	ec56                	sd	s5,24(sp)
ffffffffc0200b5a:	e486                	sd	ra,72(sp)
ffffffffc0200b5c:	842a                	mv	s0,a0
ffffffffc0200b5e:	00011497          	auipc	s1,0x11
ffffffffc0200b62:	92a48493          	addi	s1,s1,-1750 # ffffffffc0211488 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b66:	4985                	li	s3,1
ffffffffc0200b68:	00011a17          	auipc	s4,0x11
ffffffffc0200b6c:	910a0a13          	addi	s4,s4,-1776 # ffffffffc0211478 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b70:	0005091b          	sext.w	s2,a0
ffffffffc0200b74:	00011a97          	auipc	s5,0x11
ffffffffc0200b78:	934a8a93          	addi	s5,s5,-1740 # ffffffffc02114a8 <check_mm_struct>
ffffffffc0200b7c:	a00d                	j	ffffffffc0200b9e <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200b7e:	609c                	ld	a5,0(s1)
ffffffffc0200b80:	6f9c                	ld	a5,24(a5)
ffffffffc0200b82:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b84:	4601                	li	a2,0
ffffffffc0200b86:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b88:	ed0d                	bnez	a0,ffffffffc0200bc2 <alloc_pages+0x76>
ffffffffc0200b8a:	0289ec63          	bltu	s3,s0,ffffffffc0200bc2 <alloc_pages+0x76>
ffffffffc0200b8e:	000a2783          	lw	a5,0(s4)
ffffffffc0200b92:	2781                	sext.w	a5,a5
ffffffffc0200b94:	c79d                	beqz	a5,ffffffffc0200bc2 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b96:	000ab503          	ld	a0,0(s5)
ffffffffc0200b9a:	012020ef          	jal	ra,ffffffffc0202bac <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b9e:	100027f3          	csrr	a5,sstatus
ffffffffc0200ba2:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200ba4:	8522                	mv	a0,s0
ffffffffc0200ba6:	dfe1                	beqz	a5,ffffffffc0200b7e <alloc_pages+0x32>
        intr_disable();
ffffffffc0200ba8:	953ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200bac:	609c                	ld	a5,0(s1)
ffffffffc0200bae:	8522                	mv	a0,s0
ffffffffc0200bb0:	6f9c                	ld	a5,24(a5)
ffffffffc0200bb2:	9782                	jalr	a5
ffffffffc0200bb4:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200bb6:	93fff0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc0200bba:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bbc:	4601                	li	a2,0
ffffffffc0200bbe:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200bc0:	d569                	beqz	a0,ffffffffc0200b8a <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200bc2:	60a6                	ld	ra,72(sp)
ffffffffc0200bc4:	6406                	ld	s0,64(sp)
ffffffffc0200bc6:	74e2                	ld	s1,56(sp)
ffffffffc0200bc8:	7942                	ld	s2,48(sp)
ffffffffc0200bca:	79a2                	ld	s3,40(sp)
ffffffffc0200bcc:	7a02                	ld	s4,32(sp)
ffffffffc0200bce:	6ae2                	ld	s5,24(sp)
ffffffffc0200bd0:	6161                	addi	sp,sp,80
ffffffffc0200bd2:	8082                	ret

ffffffffc0200bd4 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200bd4:	100027f3          	csrr	a5,sstatus
ffffffffc0200bd8:	8b89                	andi	a5,a5,2
ffffffffc0200bda:	eb89                	bnez	a5,ffffffffc0200bec <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0200bdc:	00011797          	auipc	a5,0x11
ffffffffc0200be0:	8ac78793          	addi	a5,a5,-1876 # ffffffffc0211488 <pmm_manager>
ffffffffc0200be4:	639c                	ld	a5,0(a5)
ffffffffc0200be6:	0207b303          	ld	t1,32(a5)
ffffffffc0200bea:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200bec:	1101                	addi	sp,sp,-32
ffffffffc0200bee:	ec06                	sd	ra,24(sp)
ffffffffc0200bf0:	e822                	sd	s0,16(sp)
ffffffffc0200bf2:	e426                	sd	s1,8(sp)
ffffffffc0200bf4:	842a                	mv	s0,a0
ffffffffc0200bf6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200bf8:	903ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200bfc:	00011797          	auipc	a5,0x11
ffffffffc0200c00:	88c78793          	addi	a5,a5,-1908 # ffffffffc0211488 <pmm_manager>
ffffffffc0200c04:	639c                	ld	a5,0(a5)
ffffffffc0200c06:	85a6                	mv	a1,s1
ffffffffc0200c08:	8522                	mv	a0,s0
ffffffffc0200c0a:	739c                	ld	a5,32(a5)
ffffffffc0200c0c:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0200c0e:	6442                	ld	s0,16(sp)
ffffffffc0200c10:	60e2                	ld	ra,24(sp)
ffffffffc0200c12:	64a2                	ld	s1,8(sp)
ffffffffc0200c14:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200c16:	8dfff06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0200c1a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c1a:	100027f3          	csrr	a5,sstatus
ffffffffc0200c1e:	8b89                	andi	a5,a5,2
ffffffffc0200c20:	eb89                	bnez	a5,ffffffffc0200c32 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200c22:	00011797          	auipc	a5,0x11
ffffffffc0200c26:	86678793          	addi	a5,a5,-1946 # ffffffffc0211488 <pmm_manager>
ffffffffc0200c2a:	639c                	ld	a5,0(a5)
ffffffffc0200c2c:	0287b303          	ld	t1,40(a5)
ffffffffc0200c30:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200c32:	1141                	addi	sp,sp,-16
ffffffffc0200c34:	e406                	sd	ra,8(sp)
ffffffffc0200c36:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200c38:	8c3ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200c3c:	00011797          	auipc	a5,0x11
ffffffffc0200c40:	84c78793          	addi	a5,a5,-1972 # ffffffffc0211488 <pmm_manager>
ffffffffc0200c44:	639c                	ld	a5,0(a5)
ffffffffc0200c46:	779c                	ld	a5,40(a5)
ffffffffc0200c48:	9782                	jalr	a5
ffffffffc0200c4a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200c4c:	8a9ff0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200c50:	8522                	mv	a0,s0
ffffffffc0200c52:	60a2                	ld	ra,8(sp)
ffffffffc0200c54:	6402                	ld	s0,0(sp)
ffffffffc0200c56:	0141                	addi	sp,sp,16
ffffffffc0200c58:	8082                	ret

ffffffffc0200c5a <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c5a:	715d                	addi	sp,sp,-80
ffffffffc0200c5c:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200c5e:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200c62:	1ff4f493          	andi	s1,s1,511
ffffffffc0200c66:	048e                	slli	s1,s1,0x3
ffffffffc0200c68:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c6a:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c6c:	f84a                	sd	s2,48(sp)
ffffffffc0200c6e:	f44e                	sd	s3,40(sp)
ffffffffc0200c70:	f052                	sd	s4,32(sp)
ffffffffc0200c72:	e486                	sd	ra,72(sp)
ffffffffc0200c74:	e0a2                	sd	s0,64(sp)
ffffffffc0200c76:	ec56                	sd	s5,24(sp)
ffffffffc0200c78:	e85a                	sd	s6,16(sp)
ffffffffc0200c7a:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c7c:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c80:	892e                	mv	s2,a1
ffffffffc0200c82:	8a32                	mv	s4,a2
ffffffffc0200c84:	00010997          	auipc	s3,0x10
ffffffffc0200c88:	7dc98993          	addi	s3,s3,2012 # ffffffffc0211460 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c8c:	e3c9                	bnez	a5,ffffffffc0200d0e <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200c8e:	16060163          	beqz	a2,ffffffffc0200df0 <get_pte+0x196>
ffffffffc0200c92:	4505                	li	a0,1
ffffffffc0200c94:	eb9ff0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0200c98:	842a                	mv	s0,a0
ffffffffc0200c9a:	14050b63          	beqz	a0,ffffffffc0200df0 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c9e:	00011b97          	auipc	s7,0x11
ffffffffc0200ca2:	802b8b93          	addi	s7,s7,-2046 # ffffffffc02114a0 <pages>
ffffffffc0200ca6:	000bb503          	ld	a0,0(s7)
ffffffffc0200caa:	00004797          	auipc	a5,0x4
ffffffffc0200cae:	06e78793          	addi	a5,a5,110 # ffffffffc0204d18 <commands+0x8a8>
ffffffffc0200cb2:	0007bb03          	ld	s6,0(a5)
ffffffffc0200cb6:	40a40533          	sub	a0,s0,a0
ffffffffc0200cba:	850d                	srai	a0,a0,0x3
ffffffffc0200cbc:	03650533          	mul	a0,a0,s6
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200cc0:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200cc2:	00010997          	auipc	s3,0x10
ffffffffc0200cc6:	79e98993          	addi	s3,s3,1950 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cca:	00080ab7          	lui	s5,0x80
ffffffffc0200cce:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200cd2:	c01c                	sw	a5,0(s0)
ffffffffc0200cd4:	57fd                	li	a5,-1
ffffffffc0200cd6:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cd8:	9556                	add	a0,a0,s5
ffffffffc0200cda:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cdc:	0532                	slli	a0,a0,0xc
ffffffffc0200cde:	16e7f063          	bleu	a4,a5,ffffffffc0200e3e <get_pte+0x1e4>
ffffffffc0200ce2:	00010797          	auipc	a5,0x10
ffffffffc0200ce6:	7ae78793          	addi	a5,a5,1966 # ffffffffc0211490 <va_pa_offset>
ffffffffc0200cea:	639c                	ld	a5,0(a5)
ffffffffc0200cec:	6605                	lui	a2,0x1
ffffffffc0200cee:	4581                	li	a1,0
ffffffffc0200cf0:	953e                	add	a0,a0,a5
ffffffffc0200cf2:	150030ef          	jal	ra,ffffffffc0203e42 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cf6:	000bb683          	ld	a3,0(s7)
ffffffffc0200cfa:	40d406b3          	sub	a3,s0,a3
ffffffffc0200cfe:	868d                	srai	a3,a3,0x3
ffffffffc0200d00:	036686b3          	mul	a3,a3,s6
ffffffffc0200d04:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d06:	06aa                	slli	a3,a3,0xa
ffffffffc0200d08:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d0c:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d0e:	77fd                	lui	a5,0xfffff
ffffffffc0200d10:	068a                	slli	a3,a3,0x2
ffffffffc0200d12:	0009b703          	ld	a4,0(s3)
ffffffffc0200d16:	8efd                	and	a3,a3,a5
ffffffffc0200d18:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d1c:	0ce7fc63          	bleu	a4,a5,ffffffffc0200df4 <get_pte+0x19a>
ffffffffc0200d20:	00010a97          	auipc	s5,0x10
ffffffffc0200d24:	770a8a93          	addi	s5,s5,1904 # ffffffffc0211490 <va_pa_offset>
ffffffffc0200d28:	000ab403          	ld	s0,0(s5)
ffffffffc0200d2c:	01595793          	srli	a5,s2,0x15
ffffffffc0200d30:	1ff7f793          	andi	a5,a5,511
ffffffffc0200d34:	96a2                	add	a3,a3,s0
ffffffffc0200d36:	00379413          	slli	s0,a5,0x3
ffffffffc0200d3a:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200d3c:	6014                	ld	a3,0(s0)
ffffffffc0200d3e:	0016f793          	andi	a5,a3,1
ffffffffc0200d42:	ebbd                	bnez	a5,ffffffffc0200db8 <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200d44:	0a0a0663          	beqz	s4,ffffffffc0200df0 <get_pte+0x196>
ffffffffc0200d48:	4505                	li	a0,1
ffffffffc0200d4a:	e03ff0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0200d4e:	84aa                	mv	s1,a0
ffffffffc0200d50:	c145                	beqz	a0,ffffffffc0200df0 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d52:	00010b97          	auipc	s7,0x10
ffffffffc0200d56:	74eb8b93          	addi	s7,s7,1870 # ffffffffc02114a0 <pages>
ffffffffc0200d5a:	000bb503          	ld	a0,0(s7)
ffffffffc0200d5e:	00004797          	auipc	a5,0x4
ffffffffc0200d62:	fba78793          	addi	a5,a5,-70 # ffffffffc0204d18 <commands+0x8a8>
ffffffffc0200d66:	0007bb03          	ld	s6,0(a5)
ffffffffc0200d6a:	40a48533          	sub	a0,s1,a0
ffffffffc0200d6e:	850d                	srai	a0,a0,0x3
ffffffffc0200d70:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d74:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d76:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d7a:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d7e:	c09c                	sw	a5,0(s1)
ffffffffc0200d80:	57fd                	li	a5,-1
ffffffffc0200d82:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d84:	9552                	add	a0,a0,s4
ffffffffc0200d86:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d88:	0532                	slli	a0,a0,0xc
ffffffffc0200d8a:	08e7fd63          	bleu	a4,a5,ffffffffc0200e24 <get_pte+0x1ca>
ffffffffc0200d8e:	000ab783          	ld	a5,0(s5)
ffffffffc0200d92:	6605                	lui	a2,0x1
ffffffffc0200d94:	4581                	li	a1,0
ffffffffc0200d96:	953e                	add	a0,a0,a5
ffffffffc0200d98:	0aa030ef          	jal	ra,ffffffffc0203e42 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d9c:	000bb683          	ld	a3,0(s7)
ffffffffc0200da0:	40d486b3          	sub	a3,s1,a3
ffffffffc0200da4:	868d                	srai	a3,a3,0x3
ffffffffc0200da6:	036686b3          	mul	a3,a3,s6
ffffffffc0200daa:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200dac:	06aa                	slli	a3,a3,0xa
ffffffffc0200dae:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200db2:	e014                	sd	a3,0(s0)
ffffffffc0200db4:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200db8:	068a                	slli	a3,a3,0x2
ffffffffc0200dba:	757d                	lui	a0,0xfffff
ffffffffc0200dbc:	8ee9                	and	a3,a3,a0
ffffffffc0200dbe:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200dc2:	04e7f563          	bleu	a4,a5,ffffffffc0200e0c <get_pte+0x1b2>
ffffffffc0200dc6:	000ab503          	ld	a0,0(s5)
ffffffffc0200dca:	00c95793          	srli	a5,s2,0xc
ffffffffc0200dce:	1ff7f793          	andi	a5,a5,511
ffffffffc0200dd2:	96aa                	add	a3,a3,a0
ffffffffc0200dd4:	00379513          	slli	a0,a5,0x3
ffffffffc0200dd8:	9536                	add	a0,a0,a3
}
ffffffffc0200dda:	60a6                	ld	ra,72(sp)
ffffffffc0200ddc:	6406                	ld	s0,64(sp)
ffffffffc0200dde:	74e2                	ld	s1,56(sp)
ffffffffc0200de0:	7942                	ld	s2,48(sp)
ffffffffc0200de2:	79a2                	ld	s3,40(sp)
ffffffffc0200de4:	7a02                	ld	s4,32(sp)
ffffffffc0200de6:	6ae2                	ld	s5,24(sp)
ffffffffc0200de8:	6b42                	ld	s6,16(sp)
ffffffffc0200dea:	6ba2                	ld	s7,8(sp)
ffffffffc0200dec:	6161                	addi	sp,sp,80
ffffffffc0200dee:	8082                	ret
            return NULL;
ffffffffc0200df0:	4501                	li	a0,0
ffffffffc0200df2:	b7e5                	j	ffffffffc0200dda <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200df4:	00004617          	auipc	a2,0x4
ffffffffc0200df8:	f2c60613          	addi	a2,a2,-212 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc0200dfc:	10400593          	li	a1,260
ffffffffc0200e00:	00004517          	auipc	a0,0x4
ffffffffc0200e04:	f4850513          	addi	a0,a0,-184 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0200e08:	afeff0ef          	jal	ra,ffffffffc0200106 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200e0c:	00004617          	auipc	a2,0x4
ffffffffc0200e10:	f1460613          	addi	a2,a2,-236 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc0200e14:	11100593          	li	a1,273
ffffffffc0200e18:	00004517          	auipc	a0,0x4
ffffffffc0200e1c:	f3050513          	addi	a0,a0,-208 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0200e20:	ae6ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e24:	86aa                	mv	a3,a0
ffffffffc0200e26:	00004617          	auipc	a2,0x4
ffffffffc0200e2a:	efa60613          	addi	a2,a2,-262 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc0200e2e:	10d00593          	li	a1,269
ffffffffc0200e32:	00004517          	auipc	a0,0x4
ffffffffc0200e36:	f1650513          	addi	a0,a0,-234 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0200e3a:	accff0ef          	jal	ra,ffffffffc0200106 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e3e:	86aa                	mv	a3,a0
ffffffffc0200e40:	00004617          	auipc	a2,0x4
ffffffffc0200e44:	ee060613          	addi	a2,a2,-288 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc0200e48:	10100593          	li	a1,257
ffffffffc0200e4c:	00004517          	auipc	a0,0x4
ffffffffc0200e50:	efc50513          	addi	a0,a0,-260 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0200e54:	ab2ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200e58 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e58:	1141                	addi	sp,sp,-16
ffffffffc0200e5a:	e022                	sd	s0,0(sp)
ffffffffc0200e5c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e5e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e60:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e62:	df9ff0ef          	jal	ra,ffffffffc0200c5a <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200e66:	c011                	beqz	s0,ffffffffc0200e6a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200e68:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e6a:	c521                	beqz	a0,ffffffffc0200eb2 <get_page+0x5a>
ffffffffc0200e6c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200e6e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e70:	0017f713          	andi	a4,a5,1
ffffffffc0200e74:	e709                	bnez	a4,ffffffffc0200e7e <get_page+0x26>
}
ffffffffc0200e76:	60a2                	ld	ra,8(sp)
ffffffffc0200e78:	6402                	ld	s0,0(sp)
ffffffffc0200e7a:	0141                	addi	sp,sp,16
ffffffffc0200e7c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200e7e:	00010717          	auipc	a4,0x10
ffffffffc0200e82:	5e270713          	addi	a4,a4,1506 # ffffffffc0211460 <npage>
ffffffffc0200e86:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e88:	078a                	slli	a5,a5,0x2
ffffffffc0200e8a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e8c:	02e7f863          	bleu	a4,a5,ffffffffc0200ebc <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e90:	fff80537          	lui	a0,0xfff80
ffffffffc0200e94:	97aa                	add	a5,a5,a0
ffffffffc0200e96:	00010697          	auipc	a3,0x10
ffffffffc0200e9a:	60a68693          	addi	a3,a3,1546 # ffffffffc02114a0 <pages>
ffffffffc0200e9e:	6288                	ld	a0,0(a3)
ffffffffc0200ea0:	60a2                	ld	ra,8(sp)
ffffffffc0200ea2:	6402                	ld	s0,0(sp)
ffffffffc0200ea4:	00379713          	slli	a4,a5,0x3
ffffffffc0200ea8:	97ba                	add	a5,a5,a4
ffffffffc0200eaa:	078e                	slli	a5,a5,0x3
ffffffffc0200eac:	953e                	add	a0,a0,a5
ffffffffc0200eae:	0141                	addi	sp,sp,16
ffffffffc0200eb0:	8082                	ret
ffffffffc0200eb2:	60a2                	ld	ra,8(sp)
ffffffffc0200eb4:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0200eb6:	4501                	li	a0,0
}
ffffffffc0200eb8:	0141                	addi	sp,sp,16
ffffffffc0200eba:	8082                	ret
ffffffffc0200ebc:	c75ff0ef          	jal	ra,ffffffffc0200b30 <pa2page.part.4>

ffffffffc0200ec0 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ec0:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ec2:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ec4:	e406                	sd	ra,8(sp)
ffffffffc0200ec6:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ec8:	d93ff0ef          	jal	ra,ffffffffc0200c5a <get_pte>
    if (ptep != NULL) {
ffffffffc0200ecc:	c511                	beqz	a0,ffffffffc0200ed8 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200ece:	611c                	ld	a5,0(a0)
ffffffffc0200ed0:	842a                	mv	s0,a0
ffffffffc0200ed2:	0017f713          	andi	a4,a5,1
ffffffffc0200ed6:	e709                	bnez	a4,ffffffffc0200ee0 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200ed8:	60a2                	ld	ra,8(sp)
ffffffffc0200eda:	6402                	ld	s0,0(sp)
ffffffffc0200edc:	0141                	addi	sp,sp,16
ffffffffc0200ede:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200ee0:	00010717          	auipc	a4,0x10
ffffffffc0200ee4:	58070713          	addi	a4,a4,1408 # ffffffffc0211460 <npage>
ffffffffc0200ee8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200eea:	078a                	slli	a5,a5,0x2
ffffffffc0200eec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200eee:	04e7f063          	bleu	a4,a5,ffffffffc0200f2e <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ef2:	fff80737          	lui	a4,0xfff80
ffffffffc0200ef6:	97ba                	add	a5,a5,a4
ffffffffc0200ef8:	00010717          	auipc	a4,0x10
ffffffffc0200efc:	5a870713          	addi	a4,a4,1448 # ffffffffc02114a0 <pages>
ffffffffc0200f00:	6308                	ld	a0,0(a4)
ffffffffc0200f02:	00379713          	slli	a4,a5,0x3
ffffffffc0200f06:	97ba                	add	a5,a5,a4
ffffffffc0200f08:	078e                	slli	a5,a5,0x3
ffffffffc0200f0a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200f0c:	411c                	lw	a5,0(a0)
ffffffffc0200f0e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f12:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200f14:	cb09                	beqz	a4,ffffffffc0200f26 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f16:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f1a:	12000073          	sfence.vma
}
ffffffffc0200f1e:	60a2                	ld	ra,8(sp)
ffffffffc0200f20:	6402                	ld	s0,0(sp)
ffffffffc0200f22:	0141                	addi	sp,sp,16
ffffffffc0200f24:	8082                	ret
            free_page(page);
ffffffffc0200f26:	4585                	li	a1,1
ffffffffc0200f28:	cadff0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
ffffffffc0200f2c:	b7ed                	j	ffffffffc0200f16 <page_remove+0x56>
ffffffffc0200f2e:	c03ff0ef          	jal	ra,ffffffffc0200b30 <pa2page.part.4>

ffffffffc0200f32 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f32:	7179                	addi	sp,sp,-48
ffffffffc0200f34:	87b2                	mv	a5,a2
ffffffffc0200f36:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f38:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f3a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f3c:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f3e:	ec26                	sd	s1,24(sp)
ffffffffc0200f40:	f406                	sd	ra,40(sp)
ffffffffc0200f42:	e84a                	sd	s2,16(sp)
ffffffffc0200f44:	e44e                	sd	s3,8(sp)
ffffffffc0200f46:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f48:	d13ff0ef          	jal	ra,ffffffffc0200c5a <get_pte>
    if (ptep == NULL) {
ffffffffc0200f4c:	c945                	beqz	a0,ffffffffc0200ffc <page_insert+0xca>
    page->ref += 1;
ffffffffc0200f4e:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0200f50:	611c                	ld	a5,0(a0)
ffffffffc0200f52:	892a                	mv	s2,a0
ffffffffc0200f54:	0016871b          	addiw	a4,a3,1
ffffffffc0200f58:	c018                	sw	a4,0(s0)
ffffffffc0200f5a:	0017f713          	andi	a4,a5,1
ffffffffc0200f5e:	e339                	bnez	a4,ffffffffc0200fa4 <page_insert+0x72>
ffffffffc0200f60:	00010797          	auipc	a5,0x10
ffffffffc0200f64:	54078793          	addi	a5,a5,1344 # ffffffffc02114a0 <pages>
ffffffffc0200f68:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200f6a:	00004717          	auipc	a4,0x4
ffffffffc0200f6e:	dae70713          	addi	a4,a4,-594 # ffffffffc0204d18 <commands+0x8a8>
ffffffffc0200f72:	40f407b3          	sub	a5,s0,a5
ffffffffc0200f76:	6300                	ld	s0,0(a4)
ffffffffc0200f78:	878d                	srai	a5,a5,0x3
ffffffffc0200f7a:	000806b7          	lui	a3,0x80
ffffffffc0200f7e:	028787b3          	mul	a5,a5,s0
ffffffffc0200f82:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f84:	07aa                	slli	a5,a5,0xa
ffffffffc0200f86:	8fc5                	or	a5,a5,s1
ffffffffc0200f88:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f8c:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f90:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0200f94:	4501                	li	a0,0
}
ffffffffc0200f96:	70a2                	ld	ra,40(sp)
ffffffffc0200f98:	7402                	ld	s0,32(sp)
ffffffffc0200f9a:	64e2                	ld	s1,24(sp)
ffffffffc0200f9c:	6942                	ld	s2,16(sp)
ffffffffc0200f9e:	69a2                	ld	s3,8(sp)
ffffffffc0200fa0:	6145                	addi	sp,sp,48
ffffffffc0200fa2:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200fa4:	00010717          	auipc	a4,0x10
ffffffffc0200fa8:	4bc70713          	addi	a4,a4,1212 # ffffffffc0211460 <npage>
ffffffffc0200fac:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200fae:	00279513          	slli	a0,a5,0x2
ffffffffc0200fb2:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fb4:	04e57663          	bleu	a4,a0,ffffffffc0201000 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fb8:	fff807b7          	lui	a5,0xfff80
ffffffffc0200fbc:	953e                	add	a0,a0,a5
ffffffffc0200fbe:	00010997          	auipc	s3,0x10
ffffffffc0200fc2:	4e298993          	addi	s3,s3,1250 # ffffffffc02114a0 <pages>
ffffffffc0200fc6:	0009b783          	ld	a5,0(s3)
ffffffffc0200fca:	00351713          	slli	a4,a0,0x3
ffffffffc0200fce:	953a                	add	a0,a0,a4
ffffffffc0200fd0:	050e                	slli	a0,a0,0x3
ffffffffc0200fd2:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0200fd4:	00a40e63          	beq	s0,a0,ffffffffc0200ff0 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0200fd8:	411c                	lw	a5,0(a0)
ffffffffc0200fda:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200fde:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200fe0:	cb11                	beqz	a4,ffffffffc0200ff4 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200fe2:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200fe6:	12000073          	sfence.vma
ffffffffc0200fea:	0009b783          	ld	a5,0(s3)
ffffffffc0200fee:	bfb5                	j	ffffffffc0200f6a <page_insert+0x38>
    page->ref -= 1;
ffffffffc0200ff0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200ff2:	bfa5                	j	ffffffffc0200f6a <page_insert+0x38>
            free_page(page);
ffffffffc0200ff4:	4585                	li	a1,1
ffffffffc0200ff6:	bdfff0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
ffffffffc0200ffa:	b7e5                	j	ffffffffc0200fe2 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0200ffc:	5571                	li	a0,-4
ffffffffc0200ffe:	bf61                	j	ffffffffc0200f96 <page_insert+0x64>
ffffffffc0201000:	b31ff0ef          	jal	ra,ffffffffc0200b30 <pa2page.part.4>

ffffffffc0201004 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201004:	00005797          	auipc	a5,0x5
ffffffffc0201008:	dc478793          	addi	a5,a5,-572 # ffffffffc0205dc8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020100c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020100e:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201010:	00004517          	auipc	a0,0x4
ffffffffc0201014:	dd050513          	addi	a0,a0,-560 # ffffffffc0204de0 <commands+0x970>
void pmm_init(void) {
ffffffffc0201018:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020101a:	00010717          	auipc	a4,0x10
ffffffffc020101e:	46f73723          	sd	a5,1134(a4) # ffffffffc0211488 <pmm_manager>
void pmm_init(void) {
ffffffffc0201022:	e8a2                	sd	s0,80(sp)
ffffffffc0201024:	e4a6                	sd	s1,72(sp)
ffffffffc0201026:	e0ca                	sd	s2,64(sp)
ffffffffc0201028:	fc4e                	sd	s3,56(sp)
ffffffffc020102a:	f852                	sd	s4,48(sp)
ffffffffc020102c:	f456                	sd	s5,40(sp)
ffffffffc020102e:	f05a                	sd	s6,32(sp)
ffffffffc0201030:	ec5e                	sd	s7,24(sp)
ffffffffc0201032:	e862                	sd	s8,16(sp)
ffffffffc0201034:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201036:	00010417          	auipc	s0,0x10
ffffffffc020103a:	45240413          	addi	s0,s0,1106 # ffffffffc0211488 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020103e:	880ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201042:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201044:	49c5                	li	s3,17
ffffffffc0201046:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc020104a:	679c                	ld	a5,8(a5)
ffffffffc020104c:	00010497          	auipc	s1,0x10
ffffffffc0201050:	41448493          	addi	s1,s1,1044 # ffffffffc0211460 <npage>
ffffffffc0201054:	00010917          	auipc	s2,0x10
ffffffffc0201058:	44c90913          	addi	s2,s2,1100 # ffffffffc02114a0 <pages>
ffffffffc020105c:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020105e:	57f5                	li	a5,-3
ffffffffc0201060:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201062:	07e006b7          	lui	a3,0x7e00
ffffffffc0201066:	01b99613          	slli	a2,s3,0x1b
ffffffffc020106a:	015a1593          	slli	a1,s4,0x15
ffffffffc020106e:	00004517          	auipc	a0,0x4
ffffffffc0201072:	d8a50513          	addi	a0,a0,-630 # ffffffffc0204df8 <commands+0x988>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201076:	00010717          	auipc	a4,0x10
ffffffffc020107a:	40f73d23          	sd	a5,1050(a4) # ffffffffc0211490 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020107e:	840ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201082:	00004517          	auipc	a0,0x4
ffffffffc0201086:	da650513          	addi	a0,a0,-602 # ffffffffc0204e28 <commands+0x9b8>
ffffffffc020108a:	834ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020108e:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201092:	16fd                	addi	a3,a3,-1
ffffffffc0201094:	015a1613          	slli	a2,s4,0x15
ffffffffc0201098:	07e005b7          	lui	a1,0x7e00
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	da450513          	addi	a0,a0,-604 # ffffffffc0204e40 <commands+0x9d0>
ffffffffc02010a4:	81aff0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010a8:	777d                	lui	a4,0xfffff
ffffffffc02010aa:	00011797          	auipc	a5,0x11
ffffffffc02010ae:	4fd78793          	addi	a5,a5,1277 # ffffffffc02125a7 <end+0xfff>
ffffffffc02010b2:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02010b4:	00088737          	lui	a4,0x88
ffffffffc02010b8:	00010697          	auipc	a3,0x10
ffffffffc02010bc:	3ae6b423          	sd	a4,936(a3) # ffffffffc0211460 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010c0:	00010717          	auipc	a4,0x10
ffffffffc02010c4:	3ef73023          	sd	a5,992(a4) # ffffffffc02114a0 <pages>
ffffffffc02010c8:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010ca:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010cc:	4585                	li	a1,1
ffffffffc02010ce:	fff80637          	lui	a2,0xfff80
ffffffffc02010d2:	a019                	j	ffffffffc02010d8 <pmm_init+0xd4>
ffffffffc02010d4:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02010d8:	97b6                	add	a5,a5,a3
ffffffffc02010da:	07a1                	addi	a5,a5,8
ffffffffc02010dc:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010e0:	609c                	ld	a5,0(s1)
ffffffffc02010e2:	0705                	addi	a4,a4,1
ffffffffc02010e4:	04868693          	addi	a3,a3,72
ffffffffc02010e8:	00c78533          	add	a0,a5,a2
ffffffffc02010ec:	fea764e3          	bltu	a4,a0,ffffffffc02010d4 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010f0:	00093503          	ld	a0,0(s2)
ffffffffc02010f4:	00379693          	slli	a3,a5,0x3
ffffffffc02010f8:	96be                	add	a3,a3,a5
ffffffffc02010fa:	fdc00737          	lui	a4,0xfdc00
ffffffffc02010fe:	972a                	add	a4,a4,a0
ffffffffc0201100:	068e                	slli	a3,a3,0x3
ffffffffc0201102:	96ba                	add	a3,a3,a4
ffffffffc0201104:	c0200737          	lui	a4,0xc0200
ffffffffc0201108:	58e6ea63          	bltu	a3,a4,ffffffffc020169c <pmm_init+0x698>
ffffffffc020110c:	00010997          	auipc	s3,0x10
ffffffffc0201110:	38498993          	addi	s3,s3,900 # ffffffffc0211490 <va_pa_offset>
ffffffffc0201114:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201118:	45c5                	li	a1,17
ffffffffc020111a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020111c:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020111e:	44b6ef63          	bltu	a3,a1,ffffffffc020157c <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201122:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201124:	00010417          	auipc	s0,0x10
ffffffffc0201128:	33440413          	addi	s0,s0,820 # ffffffffc0211458 <boot_pgdir>
    pmm_manager->check();
ffffffffc020112c:	7b9c                	ld	a5,48(a5)
ffffffffc020112e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201130:	00004517          	auipc	a0,0x4
ffffffffc0201134:	d6050513          	addi	a0,a0,-672 # ffffffffc0204e90 <commands+0xa20>
ffffffffc0201138:	f87fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020113c:	00008697          	auipc	a3,0x8
ffffffffc0201140:	ec468693          	addi	a3,a3,-316 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201144:	00010797          	auipc	a5,0x10
ffffffffc0201148:	30d7ba23          	sd	a3,788(a5) # ffffffffc0211458 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020114c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201150:	0ef6ece3          	bltu	a3,a5,ffffffffc0201a48 <pmm_init+0xa44>
ffffffffc0201154:	0009b783          	ld	a5,0(s3)
ffffffffc0201158:	8e9d                	sub	a3,a3,a5
ffffffffc020115a:	00010797          	auipc	a5,0x10
ffffffffc020115e:	32d7bf23          	sd	a3,830(a5) # ffffffffc0211498 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201162:	ab9ff0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201166:	6098                	ld	a4,0(s1)
ffffffffc0201168:	c80007b7          	lui	a5,0xc8000
ffffffffc020116c:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020116e:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201170:	0ae7ece3          	bltu	a5,a4,ffffffffc0201a28 <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201174:	6008                	ld	a0,0(s0)
ffffffffc0201176:	4c050363          	beqz	a0,ffffffffc020163c <pmm_init+0x638>
ffffffffc020117a:	6785                	lui	a5,0x1
ffffffffc020117c:	17fd                	addi	a5,a5,-1
ffffffffc020117e:	8fe9                	and	a5,a5,a0
ffffffffc0201180:	2781                	sext.w	a5,a5
ffffffffc0201182:	4a079d63          	bnez	a5,ffffffffc020163c <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201186:	4601                	li	a2,0
ffffffffc0201188:	4581                	li	a1,0
ffffffffc020118a:	ccfff0ef          	jal	ra,ffffffffc0200e58 <get_page>
ffffffffc020118e:	4c051763          	bnez	a0,ffffffffc020165c <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201192:	4505                	li	a0,1
ffffffffc0201194:	9b9ff0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0201198:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020119a:	6008                	ld	a0,0(s0)
ffffffffc020119c:	4681                	li	a3,0
ffffffffc020119e:	4601                	li	a2,0
ffffffffc02011a0:	85d6                	mv	a1,s5
ffffffffc02011a2:	d91ff0ef          	jal	ra,ffffffffc0200f32 <page_insert>
ffffffffc02011a6:	52051763          	bnez	a0,ffffffffc02016d4 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02011aa:	6008                	ld	a0,0(s0)
ffffffffc02011ac:	4601                	li	a2,0
ffffffffc02011ae:	4581                	li	a1,0
ffffffffc02011b0:	aabff0ef          	jal	ra,ffffffffc0200c5a <get_pte>
ffffffffc02011b4:	50050063          	beqz	a0,ffffffffc02016b4 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc02011b8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02011ba:	0017f713          	andi	a4,a5,1
ffffffffc02011be:	46070363          	beqz	a4,ffffffffc0201624 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc02011c2:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02011c4:	078a                	slli	a5,a5,0x2
ffffffffc02011c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02011c8:	44c7f063          	bleu	a2,a5,ffffffffc0201608 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02011cc:	fff80737          	lui	a4,0xfff80
ffffffffc02011d0:	97ba                	add	a5,a5,a4
ffffffffc02011d2:	00379713          	slli	a4,a5,0x3
ffffffffc02011d6:	00093683          	ld	a3,0(s2)
ffffffffc02011da:	97ba                	add	a5,a5,a4
ffffffffc02011dc:	078e                	slli	a5,a5,0x3
ffffffffc02011de:	97b6                	add	a5,a5,a3
ffffffffc02011e0:	5efa9463          	bne	s5,a5,ffffffffc02017c8 <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc02011e4:	000aab83          	lw	s7,0(s5)
ffffffffc02011e8:	4785                	li	a5,1
ffffffffc02011ea:	5afb9f63          	bne	s7,a5,ffffffffc02017a8 <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02011ee:	6008                	ld	a0,0(s0)
ffffffffc02011f0:	76fd                	lui	a3,0xfffff
ffffffffc02011f2:	611c                	ld	a5,0(a0)
ffffffffc02011f4:	078a                	slli	a5,a5,0x2
ffffffffc02011f6:	8ff5                	and	a5,a5,a3
ffffffffc02011f8:	00c7d713          	srli	a4,a5,0xc
ffffffffc02011fc:	58c77963          	bleu	a2,a4,ffffffffc020178e <pmm_init+0x78a>
ffffffffc0201200:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201204:	97e2                	add	a5,a5,s8
ffffffffc0201206:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc020120a:	0b0a                	slli	s6,s6,0x2
ffffffffc020120c:	00db7b33          	and	s6,s6,a3
ffffffffc0201210:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201214:	56c7f063          	bleu	a2,a5,ffffffffc0201774 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201218:	4601                	li	a2,0
ffffffffc020121a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020121c:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020121e:	a3dff0ef          	jal	ra,ffffffffc0200c5a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201222:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201224:	53651863          	bne	a0,s6,ffffffffc0201754 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201228:	4505                	li	a0,1
ffffffffc020122a:	923ff0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc020122e:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201230:	6008                	ld	a0,0(s0)
ffffffffc0201232:	46d1                	li	a3,20
ffffffffc0201234:	6605                	lui	a2,0x1
ffffffffc0201236:	85da                	mv	a1,s6
ffffffffc0201238:	cfbff0ef          	jal	ra,ffffffffc0200f32 <page_insert>
ffffffffc020123c:	4e051c63          	bnez	a0,ffffffffc0201734 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201240:	6008                	ld	a0,0(s0)
ffffffffc0201242:	4601                	li	a2,0
ffffffffc0201244:	6585                	lui	a1,0x1
ffffffffc0201246:	a15ff0ef          	jal	ra,ffffffffc0200c5a <get_pte>
ffffffffc020124a:	4c050563          	beqz	a0,ffffffffc0201714 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc020124e:	611c                	ld	a5,0(a0)
ffffffffc0201250:	0107f713          	andi	a4,a5,16
ffffffffc0201254:	4a070063          	beqz	a4,ffffffffc02016f4 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201258:	8b91                	andi	a5,a5,4
ffffffffc020125a:	66078763          	beqz	a5,ffffffffc02018c8 <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020125e:	6008                	ld	a0,0(s0)
ffffffffc0201260:	611c                	ld	a5,0(a0)
ffffffffc0201262:	8bc1                	andi	a5,a5,16
ffffffffc0201264:	64078263          	beqz	a5,ffffffffc02018a8 <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201268:	000b2783          	lw	a5,0(s6)
ffffffffc020126c:	61779e63          	bne	a5,s7,ffffffffc0201888 <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201270:	4681                	li	a3,0
ffffffffc0201272:	6605                	lui	a2,0x1
ffffffffc0201274:	85d6                	mv	a1,s5
ffffffffc0201276:	cbdff0ef          	jal	ra,ffffffffc0200f32 <page_insert>
ffffffffc020127a:	5e051763          	bnez	a0,ffffffffc0201868 <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc020127e:	000aa703          	lw	a4,0(s5)
ffffffffc0201282:	4789                	li	a5,2
ffffffffc0201284:	5cf71263          	bne	a4,a5,ffffffffc0201848 <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201288:	000b2783          	lw	a5,0(s6)
ffffffffc020128c:	58079e63          	bnez	a5,ffffffffc0201828 <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201290:	6008                	ld	a0,0(s0)
ffffffffc0201292:	4601                	li	a2,0
ffffffffc0201294:	6585                	lui	a1,0x1
ffffffffc0201296:	9c5ff0ef          	jal	ra,ffffffffc0200c5a <get_pte>
ffffffffc020129a:	56050763          	beqz	a0,ffffffffc0201808 <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc020129e:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02012a0:	0016f793          	andi	a5,a3,1
ffffffffc02012a4:	38078063          	beqz	a5,ffffffffc0201624 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc02012a8:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02012aa:	00269793          	slli	a5,a3,0x2
ffffffffc02012ae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012b0:	34e7fc63          	bleu	a4,a5,ffffffffc0201608 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02012b4:	fff80737          	lui	a4,0xfff80
ffffffffc02012b8:	97ba                	add	a5,a5,a4
ffffffffc02012ba:	00379713          	slli	a4,a5,0x3
ffffffffc02012be:	00093603          	ld	a2,0(s2)
ffffffffc02012c2:	97ba                	add	a5,a5,a4
ffffffffc02012c4:	078e                	slli	a5,a5,0x3
ffffffffc02012c6:	97b2                	add	a5,a5,a2
ffffffffc02012c8:	52fa9063          	bne	s5,a5,ffffffffc02017e8 <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc02012cc:	8ac1                	andi	a3,a3,16
ffffffffc02012ce:	6e069d63          	bnez	a3,ffffffffc02019c8 <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc02012d2:	6008                	ld	a0,0(s0)
ffffffffc02012d4:	4581                	li	a1,0
ffffffffc02012d6:	bebff0ef          	jal	ra,ffffffffc0200ec0 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02012da:	000aa703          	lw	a4,0(s5)
ffffffffc02012de:	4785                	li	a5,1
ffffffffc02012e0:	6cf71463          	bne	a4,a5,ffffffffc02019a8 <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc02012e4:	000b2783          	lw	a5,0(s6)
ffffffffc02012e8:	6a079063          	bnez	a5,ffffffffc0201988 <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02012ec:	6008                	ld	a0,0(s0)
ffffffffc02012ee:	6585                	lui	a1,0x1
ffffffffc02012f0:	bd1ff0ef          	jal	ra,ffffffffc0200ec0 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02012f4:	000aa783          	lw	a5,0(s5)
ffffffffc02012f8:	66079863          	bnez	a5,ffffffffc0201968 <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc02012fc:	000b2783          	lw	a5,0(s6)
ffffffffc0201300:	70079463          	bnez	a5,ffffffffc0201a08 <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201304:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201308:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020130a:	000b3783          	ld	a5,0(s6)
ffffffffc020130e:	078a                	slli	a5,a5,0x2
ffffffffc0201310:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201312:	2eb7fb63          	bleu	a1,a5,ffffffffc0201608 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201316:	fff80737          	lui	a4,0xfff80
ffffffffc020131a:	973e                	add	a4,a4,a5
ffffffffc020131c:	00371793          	slli	a5,a4,0x3
ffffffffc0201320:	00093603          	ld	a2,0(s2)
ffffffffc0201324:	97ba                	add	a5,a5,a4
ffffffffc0201326:	078e                	slli	a5,a5,0x3
ffffffffc0201328:	00f60733          	add	a4,a2,a5
ffffffffc020132c:	4314                	lw	a3,0(a4)
ffffffffc020132e:	4705                	li	a4,1
ffffffffc0201330:	6ae69c63          	bne	a3,a4,ffffffffc02019e8 <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201334:	00004a97          	auipc	s5,0x4
ffffffffc0201338:	9e4a8a93          	addi	s5,s5,-1564 # ffffffffc0204d18 <commands+0x8a8>
ffffffffc020133c:	000ab703          	ld	a4,0(s5)
ffffffffc0201340:	4037d693          	srai	a3,a5,0x3
ffffffffc0201344:	00080bb7          	lui	s7,0x80
ffffffffc0201348:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020134c:	577d                	li	a4,-1
ffffffffc020134e:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201350:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201352:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201354:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201356:	2ab77b63          	bleu	a1,a4,ffffffffc020160c <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020135a:	0009b783          	ld	a5,0(s3)
ffffffffc020135e:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201360:	629c                	ld	a5,0(a3)
ffffffffc0201362:	078a                	slli	a5,a5,0x2
ffffffffc0201364:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201366:	2ab7f163          	bleu	a1,a5,ffffffffc0201608 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020136a:	417787b3          	sub	a5,a5,s7
ffffffffc020136e:	00379513          	slli	a0,a5,0x3
ffffffffc0201372:	97aa                	add	a5,a5,a0
ffffffffc0201374:	00379513          	slli	a0,a5,0x3
ffffffffc0201378:	9532                	add	a0,a0,a2
ffffffffc020137a:	4585                	li	a1,1
ffffffffc020137c:	859ff0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201380:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201384:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201386:	050a                	slli	a0,a0,0x2
ffffffffc0201388:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020138a:	26f57f63          	bleu	a5,a0,ffffffffc0201608 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020138e:	417507b3          	sub	a5,a0,s7
ffffffffc0201392:	00379513          	slli	a0,a5,0x3
ffffffffc0201396:	00093703          	ld	a4,0(s2)
ffffffffc020139a:	953e                	add	a0,a0,a5
ffffffffc020139c:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc020139e:	4585                	li	a1,1
ffffffffc02013a0:	953a                	add	a0,a0,a4
ffffffffc02013a2:	833ff0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02013a6:	601c                	ld	a5,0(s0)
ffffffffc02013a8:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc02013ac:	86fff0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
ffffffffc02013b0:	2caa1663          	bne	s4,a0,ffffffffc020167c <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02013b4:	00004517          	auipc	a0,0x4
ffffffffc02013b8:	e0450513          	addi	a0,a0,-508 # ffffffffc02051b8 <commands+0xd48>
ffffffffc02013bc:	d03fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02013c0:	85bff0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013c4:	6098                	ld	a4,0(s1)
ffffffffc02013c6:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02013ca:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013cc:	00c71693          	slli	a3,a4,0xc
ffffffffc02013d0:	1cd7fd63          	bleu	a3,a5,ffffffffc02015aa <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013d4:	83b1                	srli	a5,a5,0xc
ffffffffc02013d6:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013d8:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013dc:	1ce7f963          	bleu	a4,a5,ffffffffc02015ae <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013e0:	7c7d                	lui	s8,0xfffff
ffffffffc02013e2:	6b85                	lui	s7,0x1
ffffffffc02013e4:	a029                	j	ffffffffc02013ee <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013e6:	00ca5713          	srli	a4,s4,0xc
ffffffffc02013ea:	1cf77263          	bleu	a5,a4,ffffffffc02015ae <pmm_init+0x5aa>
ffffffffc02013ee:	0009b583          	ld	a1,0(s3)
ffffffffc02013f2:	4601                	li	a2,0
ffffffffc02013f4:	95d2                	add	a1,a1,s4
ffffffffc02013f6:	865ff0ef          	jal	ra,ffffffffc0200c5a <get_pte>
ffffffffc02013fa:	1c050763          	beqz	a0,ffffffffc02015c8 <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013fe:	611c                	ld	a5,0(a0)
ffffffffc0201400:	078a                	slli	a5,a5,0x2
ffffffffc0201402:	0187f7b3          	and	a5,a5,s8
ffffffffc0201406:	1f479163          	bne	a5,s4,ffffffffc02015e8 <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020140a:	609c                	ld	a5,0(s1)
ffffffffc020140c:	9a5e                	add	s4,s4,s7
ffffffffc020140e:	6008                	ld	a0,0(s0)
ffffffffc0201410:	00c79713          	slli	a4,a5,0xc
ffffffffc0201414:	fcea69e3          	bltu	s4,a4,ffffffffc02013e6 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201418:	611c                	ld	a5,0(a0)
ffffffffc020141a:	6a079363          	bnez	a5,ffffffffc0201ac0 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc020141e:	4505                	li	a0,1
ffffffffc0201420:	f2cff0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0201424:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201426:	6008                	ld	a0,0(s0)
ffffffffc0201428:	4699                	li	a3,6
ffffffffc020142a:	10000613          	li	a2,256
ffffffffc020142e:	85d2                	mv	a1,s4
ffffffffc0201430:	b03ff0ef          	jal	ra,ffffffffc0200f32 <page_insert>
ffffffffc0201434:	66051663          	bnez	a0,ffffffffc0201aa0 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201438:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc020143c:	4785                	li	a5,1
ffffffffc020143e:	64f71163          	bne	a4,a5,ffffffffc0201a80 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201442:	6008                	ld	a0,0(s0)
ffffffffc0201444:	6b85                	lui	s7,0x1
ffffffffc0201446:	4699                	li	a3,6
ffffffffc0201448:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc020144c:	85d2                	mv	a1,s4
ffffffffc020144e:	ae5ff0ef          	jal	ra,ffffffffc0200f32 <page_insert>
ffffffffc0201452:	60051763          	bnez	a0,ffffffffc0201a60 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201456:	000a2703          	lw	a4,0(s4)
ffffffffc020145a:	4789                	li	a5,2
ffffffffc020145c:	4ef71663          	bne	a4,a5,ffffffffc0201948 <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201460:	00004597          	auipc	a1,0x4
ffffffffc0201464:	e9058593          	addi	a1,a1,-368 # ffffffffc02052f0 <commands+0xe80>
ffffffffc0201468:	10000513          	li	a0,256
ffffffffc020146c:	17d020ef          	jal	ra,ffffffffc0203de8 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201470:	100b8593          	addi	a1,s7,256
ffffffffc0201474:	10000513          	li	a0,256
ffffffffc0201478:	183020ef          	jal	ra,ffffffffc0203dfa <strcmp>
ffffffffc020147c:	4a051663          	bnez	a0,ffffffffc0201928 <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201480:	00093683          	ld	a3,0(s2)
ffffffffc0201484:	000abc83          	ld	s9,0(s5)
ffffffffc0201488:	00080c37          	lui	s8,0x80
ffffffffc020148c:	40da06b3          	sub	a3,s4,a3
ffffffffc0201490:	868d                	srai	a3,a3,0x3
ffffffffc0201492:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201496:	5afd                	li	s5,-1
ffffffffc0201498:	609c                	ld	a5,0(s1)
ffffffffc020149a:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020149e:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014a0:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02014a4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014a6:	16f77363          	bleu	a5,a4,ffffffffc020160c <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02014aa:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02014ae:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02014b2:	96be                	add	a3,a3,a5
ffffffffc02014b4:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb58>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02014b8:	0ed020ef          	jal	ra,ffffffffc0203da4 <strlen>
ffffffffc02014bc:	44051663          	bnez	a0,ffffffffc0201908 <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02014c0:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02014c4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014c6:	000bb783          	ld	a5,0(s7)
ffffffffc02014ca:	078a                	slli	a5,a5,0x2
ffffffffc02014cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014ce:	12e7fd63          	bleu	a4,a5,ffffffffc0201608 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02014d2:	418787b3          	sub	a5,a5,s8
ffffffffc02014d6:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02014da:	96be                	add	a3,a3,a5
ffffffffc02014dc:	039686b3          	mul	a3,a3,s9
ffffffffc02014e0:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014e2:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02014e6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014e8:	12eaf263          	bleu	a4,s5,ffffffffc020160c <pmm_init+0x608>
ffffffffc02014ec:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02014f0:	4585                	li	a1,1
ffffffffc02014f2:	8552                	mv	a0,s4
ffffffffc02014f4:	99b6                	add	s3,s3,a3
ffffffffc02014f6:	edeff0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014fa:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02014fe:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201500:	078a                	slli	a5,a5,0x2
ffffffffc0201502:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201504:	10e7f263          	bleu	a4,a5,ffffffffc0201608 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201508:	fff809b7          	lui	s3,0xfff80
ffffffffc020150c:	97ce                	add	a5,a5,s3
ffffffffc020150e:	00379513          	slli	a0,a5,0x3
ffffffffc0201512:	00093703          	ld	a4,0(s2)
ffffffffc0201516:	97aa                	add	a5,a5,a0
ffffffffc0201518:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020151c:	953a                	add	a0,a0,a4
ffffffffc020151e:	4585                	li	a1,1
ffffffffc0201520:	eb4ff0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201524:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201528:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020152a:	050a                	slli	a0,a0,0x2
ffffffffc020152c:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020152e:	0cf57d63          	bleu	a5,a0,ffffffffc0201608 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201532:	013507b3          	add	a5,a0,s3
ffffffffc0201536:	00379513          	slli	a0,a5,0x3
ffffffffc020153a:	00093703          	ld	a4,0(s2)
ffffffffc020153e:	953e                	add	a0,a0,a5
ffffffffc0201540:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201542:	4585                	li	a1,1
ffffffffc0201544:	953a                	add	a0,a0,a4
ffffffffc0201546:	e8eff0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020154a:	601c                	ld	a5,0(s0)
ffffffffc020154c:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0201550:	ecaff0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
ffffffffc0201554:	38ab1a63          	bne	s6,a0,ffffffffc02018e8 <pmm_init+0x8e4>
}
ffffffffc0201558:	6446                	ld	s0,80(sp)
ffffffffc020155a:	60e6                	ld	ra,88(sp)
ffffffffc020155c:	64a6                	ld	s1,72(sp)
ffffffffc020155e:	6906                	ld	s2,64(sp)
ffffffffc0201560:	79e2                	ld	s3,56(sp)
ffffffffc0201562:	7a42                	ld	s4,48(sp)
ffffffffc0201564:	7aa2                	ld	s5,40(sp)
ffffffffc0201566:	7b02                	ld	s6,32(sp)
ffffffffc0201568:	6be2                	ld	s7,24(sp)
ffffffffc020156a:	6c42                	ld	s8,16(sp)
ffffffffc020156c:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020156e:	00004517          	auipc	a0,0x4
ffffffffc0201572:	dfa50513          	addi	a0,a0,-518 # ffffffffc0205368 <commands+0xef8>
}
ffffffffc0201576:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201578:	b47fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020157c:	6705                	lui	a4,0x1
ffffffffc020157e:	177d                	addi	a4,a4,-1
ffffffffc0201580:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0201582:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201586:	08f77163          	bleu	a5,a4,ffffffffc0201608 <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc020158a:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc020158e:	9732                	add	a4,a4,a2
ffffffffc0201590:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201594:	767d                	lui	a2,0xfffff
ffffffffc0201596:	8ef1                	and	a3,a3,a2
ffffffffc0201598:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020159a:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020159e:	8d95                	sub	a1,a1,a3
ffffffffc02015a0:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02015a2:	81b1                	srli	a1,a1,0xc
ffffffffc02015a4:	953e                	add	a0,a0,a5
ffffffffc02015a6:	9702                	jalr	a4
ffffffffc02015a8:	bead                	j	ffffffffc0201122 <pmm_init+0x11e>
ffffffffc02015aa:	6008                	ld	a0,0(s0)
ffffffffc02015ac:	b5b5                	j	ffffffffc0201418 <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02015ae:	86d2                	mv	a3,s4
ffffffffc02015b0:	00003617          	auipc	a2,0x3
ffffffffc02015b4:	77060613          	addi	a2,a2,1904 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc02015b8:	1cf00593          	li	a1,463
ffffffffc02015bc:	00003517          	auipc	a0,0x3
ffffffffc02015c0:	78c50513          	addi	a0,a0,1932 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02015c4:	b43fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc02015c8:	00004697          	auipc	a3,0x4
ffffffffc02015cc:	c1068693          	addi	a3,a3,-1008 # ffffffffc02051d8 <commands+0xd68>
ffffffffc02015d0:	00004617          	auipc	a2,0x4
ffffffffc02015d4:	90060613          	addi	a2,a2,-1792 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02015d8:	1cf00593          	li	a1,463
ffffffffc02015dc:	00003517          	auipc	a0,0x3
ffffffffc02015e0:	76c50513          	addi	a0,a0,1900 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02015e4:	b23fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02015e8:	00004697          	auipc	a3,0x4
ffffffffc02015ec:	c3068693          	addi	a3,a3,-976 # ffffffffc0205218 <commands+0xda8>
ffffffffc02015f0:	00004617          	auipc	a2,0x4
ffffffffc02015f4:	8e060613          	addi	a2,a2,-1824 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02015f8:	1d000593          	li	a1,464
ffffffffc02015fc:	00003517          	auipc	a0,0x3
ffffffffc0201600:	74c50513          	addi	a0,a0,1868 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201604:	b03fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201608:	d28ff0ef          	jal	ra,ffffffffc0200b30 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020160c:	00003617          	auipc	a2,0x3
ffffffffc0201610:	71460613          	addi	a2,a2,1812 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc0201614:	06a00593          	li	a1,106
ffffffffc0201618:	00003517          	auipc	a0,0x3
ffffffffc020161c:	7a050513          	addi	a0,a0,1952 # ffffffffc0204db8 <commands+0x948>
ffffffffc0201620:	ae7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201624:	00004617          	auipc	a2,0x4
ffffffffc0201628:	98460613          	addi	a2,a2,-1660 # ffffffffc0204fa8 <commands+0xb38>
ffffffffc020162c:	07000593          	li	a1,112
ffffffffc0201630:	00003517          	auipc	a0,0x3
ffffffffc0201634:	78850513          	addi	a0,a0,1928 # ffffffffc0204db8 <commands+0x948>
ffffffffc0201638:	acffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020163c:	00004697          	auipc	a3,0x4
ffffffffc0201640:	8ac68693          	addi	a3,a3,-1876 # ffffffffc0204ee8 <commands+0xa78>
ffffffffc0201644:	00004617          	auipc	a2,0x4
ffffffffc0201648:	88c60613          	addi	a2,a2,-1908 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020164c:	19500593          	li	a1,405
ffffffffc0201650:	00003517          	auipc	a0,0x3
ffffffffc0201654:	6f850513          	addi	a0,a0,1784 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201658:	aaffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020165c:	00004697          	auipc	a3,0x4
ffffffffc0201660:	8c468693          	addi	a3,a3,-1852 # ffffffffc0204f20 <commands+0xab0>
ffffffffc0201664:	00004617          	auipc	a2,0x4
ffffffffc0201668:	86c60613          	addi	a2,a2,-1940 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020166c:	19600593          	li	a1,406
ffffffffc0201670:	00003517          	auipc	a0,0x3
ffffffffc0201674:	6d850513          	addi	a0,a0,1752 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201678:	a8ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020167c:	00004697          	auipc	a3,0x4
ffffffffc0201680:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0205198 <commands+0xd28>
ffffffffc0201684:	00004617          	auipc	a2,0x4
ffffffffc0201688:	84c60613          	addi	a2,a2,-1972 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020168c:	1c200593          	li	a1,450
ffffffffc0201690:	00003517          	auipc	a0,0x3
ffffffffc0201694:	6b850513          	addi	a0,a0,1720 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201698:	a6ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020169c:	00003617          	auipc	a2,0x3
ffffffffc02016a0:	7cc60613          	addi	a2,a2,1996 # ffffffffc0204e68 <commands+0x9f8>
ffffffffc02016a4:	07900593          	li	a1,121
ffffffffc02016a8:	00003517          	auipc	a0,0x3
ffffffffc02016ac:	6a050513          	addi	a0,a0,1696 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02016b0:	a57fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02016b4:	00004697          	auipc	a3,0x4
ffffffffc02016b8:	8c468693          	addi	a3,a3,-1852 # ffffffffc0204f78 <commands+0xb08>
ffffffffc02016bc:	00004617          	auipc	a2,0x4
ffffffffc02016c0:	81460613          	addi	a2,a2,-2028 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02016c4:	19c00593          	li	a1,412
ffffffffc02016c8:	00003517          	auipc	a0,0x3
ffffffffc02016cc:	68050513          	addi	a0,a0,1664 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02016d0:	a37fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02016d4:	00004697          	auipc	a3,0x4
ffffffffc02016d8:	87468693          	addi	a3,a3,-1932 # ffffffffc0204f48 <commands+0xad8>
ffffffffc02016dc:	00003617          	auipc	a2,0x3
ffffffffc02016e0:	7f460613          	addi	a2,a2,2036 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02016e4:	19a00593          	li	a1,410
ffffffffc02016e8:	00003517          	auipc	a0,0x3
ffffffffc02016ec:	66050513          	addi	a0,a0,1632 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02016f0:	a17fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02016f4:	00004697          	auipc	a3,0x4
ffffffffc02016f8:	99c68693          	addi	a3,a3,-1636 # ffffffffc0205090 <commands+0xc20>
ffffffffc02016fc:	00003617          	auipc	a2,0x3
ffffffffc0201700:	7d460613          	addi	a2,a2,2004 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201704:	1a700593          	li	a1,423
ffffffffc0201708:	00003517          	auipc	a0,0x3
ffffffffc020170c:	64050513          	addi	a0,a0,1600 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201710:	9f7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201714:	00004697          	auipc	a3,0x4
ffffffffc0201718:	94c68693          	addi	a3,a3,-1716 # ffffffffc0205060 <commands+0xbf0>
ffffffffc020171c:	00003617          	auipc	a2,0x3
ffffffffc0201720:	7b460613          	addi	a2,a2,1972 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201724:	1a600593          	li	a1,422
ffffffffc0201728:	00003517          	auipc	a0,0x3
ffffffffc020172c:	62050513          	addi	a0,a0,1568 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201730:	9d7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201734:	00004697          	auipc	a3,0x4
ffffffffc0201738:	8f468693          	addi	a3,a3,-1804 # ffffffffc0205028 <commands+0xbb8>
ffffffffc020173c:	00003617          	auipc	a2,0x3
ffffffffc0201740:	79460613          	addi	a2,a2,1940 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201744:	1a500593          	li	a1,421
ffffffffc0201748:	00003517          	auipc	a0,0x3
ffffffffc020174c:	60050513          	addi	a0,a0,1536 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201750:	9b7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201754:	00004697          	auipc	a3,0x4
ffffffffc0201758:	8ac68693          	addi	a3,a3,-1876 # ffffffffc0205000 <commands+0xb90>
ffffffffc020175c:	00003617          	auipc	a2,0x3
ffffffffc0201760:	77460613          	addi	a2,a2,1908 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201764:	1a200593          	li	a1,418
ffffffffc0201768:	00003517          	auipc	a0,0x3
ffffffffc020176c:	5e050513          	addi	a0,a0,1504 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201770:	997fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201774:	86da                	mv	a3,s6
ffffffffc0201776:	00003617          	auipc	a2,0x3
ffffffffc020177a:	5aa60613          	addi	a2,a2,1450 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc020177e:	1a100593          	li	a1,417
ffffffffc0201782:	00003517          	auipc	a0,0x3
ffffffffc0201786:	5c650513          	addi	a0,a0,1478 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc020178a:	97dfe0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020178e:	86be                	mv	a3,a5
ffffffffc0201790:	00003617          	auipc	a2,0x3
ffffffffc0201794:	59060613          	addi	a2,a2,1424 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc0201798:	1a000593          	li	a1,416
ffffffffc020179c:	00003517          	auipc	a0,0x3
ffffffffc02017a0:	5ac50513          	addi	a0,a0,1452 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02017a4:	963fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02017a8:	00004697          	auipc	a3,0x4
ffffffffc02017ac:	84068693          	addi	a3,a3,-1984 # ffffffffc0204fe8 <commands+0xb78>
ffffffffc02017b0:	00003617          	auipc	a2,0x3
ffffffffc02017b4:	72060613          	addi	a2,a2,1824 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02017b8:	19e00593          	li	a1,414
ffffffffc02017bc:	00003517          	auipc	a0,0x3
ffffffffc02017c0:	58c50513          	addi	a0,a0,1420 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02017c4:	943fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02017c8:	00004697          	auipc	a3,0x4
ffffffffc02017cc:	80868693          	addi	a3,a3,-2040 # ffffffffc0204fd0 <commands+0xb60>
ffffffffc02017d0:	00003617          	auipc	a2,0x3
ffffffffc02017d4:	70060613          	addi	a2,a2,1792 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02017d8:	19d00593          	li	a1,413
ffffffffc02017dc:	00003517          	auipc	a0,0x3
ffffffffc02017e0:	56c50513          	addi	a0,a0,1388 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02017e4:	923fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02017e8:	00003697          	auipc	a3,0x3
ffffffffc02017ec:	7e868693          	addi	a3,a3,2024 # ffffffffc0204fd0 <commands+0xb60>
ffffffffc02017f0:	00003617          	auipc	a2,0x3
ffffffffc02017f4:	6e060613          	addi	a2,a2,1760 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02017f8:	1b000593          	li	a1,432
ffffffffc02017fc:	00003517          	auipc	a0,0x3
ffffffffc0201800:	54c50513          	addi	a0,a0,1356 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201804:	903fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201808:	00004697          	auipc	a3,0x4
ffffffffc020180c:	85868693          	addi	a3,a3,-1960 # ffffffffc0205060 <commands+0xbf0>
ffffffffc0201810:	00003617          	auipc	a2,0x3
ffffffffc0201814:	6c060613          	addi	a2,a2,1728 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201818:	1af00593          	li	a1,431
ffffffffc020181c:	00003517          	auipc	a0,0x3
ffffffffc0201820:	52c50513          	addi	a0,a0,1324 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201824:	8e3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201828:	00004697          	auipc	a3,0x4
ffffffffc020182c:	90068693          	addi	a3,a3,-1792 # ffffffffc0205128 <commands+0xcb8>
ffffffffc0201830:	00003617          	auipc	a2,0x3
ffffffffc0201834:	6a060613          	addi	a2,a2,1696 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201838:	1ae00593          	li	a1,430
ffffffffc020183c:	00003517          	auipc	a0,0x3
ffffffffc0201840:	50c50513          	addi	a0,a0,1292 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201844:	8c3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201848:	00004697          	auipc	a3,0x4
ffffffffc020184c:	8c868693          	addi	a3,a3,-1848 # ffffffffc0205110 <commands+0xca0>
ffffffffc0201850:	00003617          	auipc	a2,0x3
ffffffffc0201854:	68060613          	addi	a2,a2,1664 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201858:	1ad00593          	li	a1,429
ffffffffc020185c:	00003517          	auipc	a0,0x3
ffffffffc0201860:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201864:	8a3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201868:	00004697          	auipc	a3,0x4
ffffffffc020186c:	87868693          	addi	a3,a3,-1928 # ffffffffc02050e0 <commands+0xc70>
ffffffffc0201870:	00003617          	auipc	a2,0x3
ffffffffc0201874:	66060613          	addi	a2,a2,1632 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201878:	1ac00593          	li	a1,428
ffffffffc020187c:	00003517          	auipc	a0,0x3
ffffffffc0201880:	4cc50513          	addi	a0,a0,1228 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201884:	883fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201888:	00004697          	auipc	a3,0x4
ffffffffc020188c:	84068693          	addi	a3,a3,-1984 # ffffffffc02050c8 <commands+0xc58>
ffffffffc0201890:	00003617          	auipc	a2,0x3
ffffffffc0201894:	64060613          	addi	a2,a2,1600 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201898:	1aa00593          	li	a1,426
ffffffffc020189c:	00003517          	auipc	a0,0x3
ffffffffc02018a0:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02018a4:	863fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02018a8:	00004697          	auipc	a3,0x4
ffffffffc02018ac:	80868693          	addi	a3,a3,-2040 # ffffffffc02050b0 <commands+0xc40>
ffffffffc02018b0:	00003617          	auipc	a2,0x3
ffffffffc02018b4:	62060613          	addi	a2,a2,1568 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02018b8:	1a900593          	li	a1,425
ffffffffc02018bc:	00003517          	auipc	a0,0x3
ffffffffc02018c0:	48c50513          	addi	a0,a0,1164 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02018c4:	843fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02018c8:	00003697          	auipc	a3,0x3
ffffffffc02018cc:	7d868693          	addi	a3,a3,2008 # ffffffffc02050a0 <commands+0xc30>
ffffffffc02018d0:	00003617          	auipc	a2,0x3
ffffffffc02018d4:	60060613          	addi	a2,a2,1536 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02018d8:	1a800593          	li	a1,424
ffffffffc02018dc:	00003517          	auipc	a0,0x3
ffffffffc02018e0:	46c50513          	addi	a0,a0,1132 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02018e4:	823fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02018e8:	00004697          	auipc	a3,0x4
ffffffffc02018ec:	8b068693          	addi	a3,a3,-1872 # ffffffffc0205198 <commands+0xd28>
ffffffffc02018f0:	00003617          	auipc	a2,0x3
ffffffffc02018f4:	5e060613          	addi	a2,a2,1504 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02018f8:	1ea00593          	li	a1,490
ffffffffc02018fc:	00003517          	auipc	a0,0x3
ffffffffc0201900:	44c50513          	addi	a0,a0,1100 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201904:	803fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201908:	00004697          	auipc	a3,0x4
ffffffffc020190c:	a3868693          	addi	a3,a3,-1480 # ffffffffc0205340 <commands+0xed0>
ffffffffc0201910:	00003617          	auipc	a2,0x3
ffffffffc0201914:	5c060613          	addi	a2,a2,1472 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201918:	1e200593          	li	a1,482
ffffffffc020191c:	00003517          	auipc	a0,0x3
ffffffffc0201920:	42c50513          	addi	a0,a0,1068 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201924:	fe2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201928:	00004697          	auipc	a3,0x4
ffffffffc020192c:	9e068693          	addi	a3,a3,-1568 # ffffffffc0205308 <commands+0xe98>
ffffffffc0201930:	00003617          	auipc	a2,0x3
ffffffffc0201934:	5a060613          	addi	a2,a2,1440 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201938:	1df00593          	li	a1,479
ffffffffc020193c:	00003517          	auipc	a0,0x3
ffffffffc0201940:	40c50513          	addi	a0,a0,1036 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201944:	fc2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201948:	00004697          	auipc	a3,0x4
ffffffffc020194c:	99068693          	addi	a3,a3,-1648 # ffffffffc02052d8 <commands+0xe68>
ffffffffc0201950:	00003617          	auipc	a2,0x3
ffffffffc0201954:	58060613          	addi	a2,a2,1408 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201958:	1db00593          	li	a1,475
ffffffffc020195c:	00003517          	auipc	a0,0x3
ffffffffc0201960:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201964:	fa2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201968:	00003697          	auipc	a3,0x3
ffffffffc020196c:	7f068693          	addi	a3,a3,2032 # ffffffffc0205158 <commands+0xce8>
ffffffffc0201970:	00003617          	auipc	a2,0x3
ffffffffc0201974:	56060613          	addi	a2,a2,1376 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201978:	1b800593          	li	a1,440
ffffffffc020197c:	00003517          	auipc	a0,0x3
ffffffffc0201980:	3cc50513          	addi	a0,a0,972 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201984:	f82fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201988:	00003697          	auipc	a3,0x3
ffffffffc020198c:	7a068693          	addi	a3,a3,1952 # ffffffffc0205128 <commands+0xcb8>
ffffffffc0201990:	00003617          	auipc	a2,0x3
ffffffffc0201994:	54060613          	addi	a2,a2,1344 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201998:	1b500593          	li	a1,437
ffffffffc020199c:	00003517          	auipc	a0,0x3
ffffffffc02019a0:	3ac50513          	addi	a0,a0,940 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02019a4:	f62fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02019a8:	00003697          	auipc	a3,0x3
ffffffffc02019ac:	64068693          	addi	a3,a3,1600 # ffffffffc0204fe8 <commands+0xb78>
ffffffffc02019b0:	00003617          	auipc	a2,0x3
ffffffffc02019b4:	52060613          	addi	a2,a2,1312 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02019b8:	1b400593          	li	a1,436
ffffffffc02019bc:	00003517          	auipc	a0,0x3
ffffffffc02019c0:	38c50513          	addi	a0,a0,908 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02019c4:	f42fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02019c8:	00003697          	auipc	a3,0x3
ffffffffc02019cc:	77868693          	addi	a3,a3,1912 # ffffffffc0205140 <commands+0xcd0>
ffffffffc02019d0:	00003617          	auipc	a2,0x3
ffffffffc02019d4:	50060613          	addi	a2,a2,1280 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02019d8:	1b100593          	li	a1,433
ffffffffc02019dc:	00003517          	auipc	a0,0x3
ffffffffc02019e0:	36c50513          	addi	a0,a0,876 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc02019e4:	f22fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02019e8:	00003697          	auipc	a3,0x3
ffffffffc02019ec:	78868693          	addi	a3,a3,1928 # ffffffffc0205170 <commands+0xd00>
ffffffffc02019f0:	00003617          	auipc	a2,0x3
ffffffffc02019f4:	4e060613          	addi	a2,a2,1248 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02019f8:	1bb00593          	li	a1,443
ffffffffc02019fc:	00003517          	auipc	a0,0x3
ffffffffc0201a00:	34c50513          	addi	a0,a0,844 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201a04:	f02fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201a08:	00003697          	auipc	a3,0x3
ffffffffc0201a0c:	72068693          	addi	a3,a3,1824 # ffffffffc0205128 <commands+0xcb8>
ffffffffc0201a10:	00003617          	auipc	a2,0x3
ffffffffc0201a14:	4c060613          	addi	a2,a2,1216 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201a18:	1b900593          	li	a1,441
ffffffffc0201a1c:	00003517          	auipc	a0,0x3
ffffffffc0201a20:	32c50513          	addi	a0,a0,812 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201a24:	ee2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201a28:	00003697          	auipc	a3,0x3
ffffffffc0201a2c:	48868693          	addi	a3,a3,1160 # ffffffffc0204eb0 <commands+0xa40>
ffffffffc0201a30:	00003617          	auipc	a2,0x3
ffffffffc0201a34:	4a060613          	addi	a2,a2,1184 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201a38:	19400593          	li	a1,404
ffffffffc0201a3c:	00003517          	auipc	a0,0x3
ffffffffc0201a40:	30c50513          	addi	a0,a0,780 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201a44:	ec2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201a48:	00003617          	auipc	a2,0x3
ffffffffc0201a4c:	42060613          	addi	a2,a2,1056 # ffffffffc0204e68 <commands+0x9f8>
ffffffffc0201a50:	0bf00593          	li	a1,191
ffffffffc0201a54:	00003517          	auipc	a0,0x3
ffffffffc0201a58:	2f450513          	addi	a0,a0,756 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201a5c:	eaafe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201a60:	00004697          	auipc	a3,0x4
ffffffffc0201a64:	83868693          	addi	a3,a3,-1992 # ffffffffc0205298 <commands+0xe28>
ffffffffc0201a68:	00003617          	auipc	a2,0x3
ffffffffc0201a6c:	46860613          	addi	a2,a2,1128 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201a70:	1da00593          	li	a1,474
ffffffffc0201a74:	00003517          	auipc	a0,0x3
ffffffffc0201a78:	2d450513          	addi	a0,a0,724 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201a7c:	e8afe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201a80:	00004697          	auipc	a3,0x4
ffffffffc0201a84:	80068693          	addi	a3,a3,-2048 # ffffffffc0205280 <commands+0xe10>
ffffffffc0201a88:	00003617          	auipc	a2,0x3
ffffffffc0201a8c:	44860613          	addi	a2,a2,1096 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201a90:	1d900593          	li	a1,473
ffffffffc0201a94:	00003517          	auipc	a0,0x3
ffffffffc0201a98:	2b450513          	addi	a0,a0,692 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201a9c:	e6afe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201aa0:	00003697          	auipc	a3,0x3
ffffffffc0201aa4:	7a868693          	addi	a3,a3,1960 # ffffffffc0205248 <commands+0xdd8>
ffffffffc0201aa8:	00003617          	auipc	a2,0x3
ffffffffc0201aac:	42860613          	addi	a2,a2,1064 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201ab0:	1d800593          	li	a1,472
ffffffffc0201ab4:	00003517          	auipc	a0,0x3
ffffffffc0201ab8:	29450513          	addi	a0,a0,660 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201abc:	e4afe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201ac0:	00003697          	auipc	a3,0x3
ffffffffc0201ac4:	77068693          	addi	a3,a3,1904 # ffffffffc0205230 <commands+0xdc0>
ffffffffc0201ac8:	00003617          	auipc	a2,0x3
ffffffffc0201acc:	40860613          	addi	a2,a2,1032 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201ad0:	1d400593          	li	a1,468
ffffffffc0201ad4:	00003517          	auipc	a0,0x3
ffffffffc0201ad8:	27450513          	addi	a0,a0,628 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201adc:	e2afe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201ae0 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201ae0:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0201ae4:	8082                	ret

ffffffffc0201ae6 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201ae6:	7179                	addi	sp,sp,-48
ffffffffc0201ae8:	e84a                	sd	s2,16(sp)
ffffffffc0201aea:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201aec:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201aee:	f022                	sd	s0,32(sp)
ffffffffc0201af0:	ec26                	sd	s1,24(sp)
ffffffffc0201af2:	e44e                	sd	s3,8(sp)
ffffffffc0201af4:	f406                	sd	ra,40(sp)
ffffffffc0201af6:	84ae                	mv	s1,a1
ffffffffc0201af8:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201afa:	852ff0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0201afe:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201b00:	cd19                	beqz	a0,ffffffffc0201b1e <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201b02:	85aa                	mv	a1,a0
ffffffffc0201b04:	86ce                	mv	a3,s3
ffffffffc0201b06:	8626                	mv	a2,s1
ffffffffc0201b08:	854a                	mv	a0,s2
ffffffffc0201b0a:	c28ff0ef          	jal	ra,ffffffffc0200f32 <page_insert>
ffffffffc0201b0e:	ed39                	bnez	a0,ffffffffc0201b6c <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0201b10:	00010797          	auipc	a5,0x10
ffffffffc0201b14:	96878793          	addi	a5,a5,-1688 # ffffffffc0211478 <swap_init_ok>
ffffffffc0201b18:	439c                	lw	a5,0(a5)
ffffffffc0201b1a:	2781                	sext.w	a5,a5
ffffffffc0201b1c:	eb89                	bnez	a5,ffffffffc0201b2e <pgdir_alloc_page+0x48>
}
ffffffffc0201b1e:	8522                	mv	a0,s0
ffffffffc0201b20:	70a2                	ld	ra,40(sp)
ffffffffc0201b22:	7402                	ld	s0,32(sp)
ffffffffc0201b24:	64e2                	ld	s1,24(sp)
ffffffffc0201b26:	6942                	ld	s2,16(sp)
ffffffffc0201b28:	69a2                	ld	s3,8(sp)
ffffffffc0201b2a:	6145                	addi	sp,sp,48
ffffffffc0201b2c:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201b2e:	00010797          	auipc	a5,0x10
ffffffffc0201b32:	97a78793          	addi	a5,a5,-1670 # ffffffffc02114a8 <check_mm_struct>
ffffffffc0201b36:	6388                	ld	a0,0(a5)
ffffffffc0201b38:	4681                	li	a3,0
ffffffffc0201b3a:	8622                	mv	a2,s0
ffffffffc0201b3c:	85a6                	mv	a1,s1
ffffffffc0201b3e:	05e010ef          	jal	ra,ffffffffc0202b9c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201b42:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201b44:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0201b46:	4785                	li	a5,1
ffffffffc0201b48:	fcf70be3          	beq	a4,a5,ffffffffc0201b1e <pgdir_alloc_page+0x38>
ffffffffc0201b4c:	00003697          	auipc	a3,0x3
ffffffffc0201b50:	27c68693          	addi	a3,a3,636 # ffffffffc0204dc8 <commands+0x958>
ffffffffc0201b54:	00003617          	auipc	a2,0x3
ffffffffc0201b58:	37c60613          	addi	a2,a2,892 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201b5c:	17c00593          	li	a1,380
ffffffffc0201b60:	00003517          	auipc	a0,0x3
ffffffffc0201b64:	1e850513          	addi	a0,a0,488 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201b68:	d9efe0ef          	jal	ra,ffffffffc0200106 <__panic>
            free_page(page);
ffffffffc0201b6c:	8522                	mv	a0,s0
ffffffffc0201b6e:	4585                	li	a1,1
ffffffffc0201b70:	864ff0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
            return NULL;
ffffffffc0201b74:	4401                	li	s0,0
ffffffffc0201b76:	b765                	j	ffffffffc0201b1e <pgdir_alloc_page+0x38>

ffffffffc0201b78 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0201b78:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201b7a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0201b7c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201b7e:	fff50713          	addi	a4,a0,-1
ffffffffc0201b82:	17f9                	addi	a5,a5,-2
ffffffffc0201b84:	04e7ee63          	bltu	a5,a4,ffffffffc0201be0 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201b88:	6785                	lui	a5,0x1
ffffffffc0201b8a:	17fd                	addi	a5,a5,-1
ffffffffc0201b8c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0201b8e:	8131                	srli	a0,a0,0xc
ffffffffc0201b90:	fbdfe0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
    assert(base != NULL);
ffffffffc0201b94:	c159                	beqz	a0,ffffffffc0201c1a <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b96:	00010797          	auipc	a5,0x10
ffffffffc0201b9a:	90a78793          	addi	a5,a5,-1782 # ffffffffc02114a0 <pages>
ffffffffc0201b9e:	639c                	ld	a5,0(a5)
ffffffffc0201ba0:	8d1d                	sub	a0,a0,a5
ffffffffc0201ba2:	00003797          	auipc	a5,0x3
ffffffffc0201ba6:	17678793          	addi	a5,a5,374 # ffffffffc0204d18 <commands+0x8a8>
ffffffffc0201baa:	6394                	ld	a3,0(a5)
ffffffffc0201bac:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201bae:	00010797          	auipc	a5,0x10
ffffffffc0201bb2:	8b278793          	addi	a5,a5,-1870 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201bb6:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201bba:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201bbc:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201bc0:	57fd                	li	a5,-1
ffffffffc0201bc2:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201bc4:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201bc6:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bc8:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201bca:	02e7fb63          	bleu	a4,a5,ffffffffc0201c00 <kmalloc+0x88>
ffffffffc0201bce:	00010797          	auipc	a5,0x10
ffffffffc0201bd2:	8c278793          	addi	a5,a5,-1854 # ffffffffc0211490 <va_pa_offset>
ffffffffc0201bd6:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0201bd8:	60a2                	ld	ra,8(sp)
ffffffffc0201bda:	953e                	add	a0,a0,a5
ffffffffc0201bdc:	0141                	addi	sp,sp,16
ffffffffc0201bde:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201be0:	00003697          	auipc	a3,0x3
ffffffffc0201be4:	18868693          	addi	a3,a3,392 # ffffffffc0204d68 <commands+0x8f8>
ffffffffc0201be8:	00003617          	auipc	a2,0x3
ffffffffc0201bec:	2e860613          	addi	a2,a2,744 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201bf0:	1f200593          	li	a1,498
ffffffffc0201bf4:	00003517          	auipc	a0,0x3
ffffffffc0201bf8:	15450513          	addi	a0,a0,340 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201bfc:	d0afe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201c00:	86aa                	mv	a3,a0
ffffffffc0201c02:	00003617          	auipc	a2,0x3
ffffffffc0201c06:	11e60613          	addi	a2,a2,286 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc0201c0a:	06a00593          	li	a1,106
ffffffffc0201c0e:	00003517          	auipc	a0,0x3
ffffffffc0201c12:	1aa50513          	addi	a0,a0,426 # ffffffffc0204db8 <commands+0x948>
ffffffffc0201c16:	cf0fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(base != NULL);
ffffffffc0201c1a:	00003697          	auipc	a3,0x3
ffffffffc0201c1e:	16e68693          	addi	a3,a3,366 # ffffffffc0204d88 <commands+0x918>
ffffffffc0201c22:	00003617          	auipc	a2,0x3
ffffffffc0201c26:	2ae60613          	addi	a2,a2,686 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201c2a:	1f500593          	li	a1,501
ffffffffc0201c2e:	00003517          	auipc	a0,0x3
ffffffffc0201c32:	11a50513          	addi	a0,a0,282 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201c36:	cd0fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201c3a <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0201c3a:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201c3c:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0201c3e:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201c40:	fff58713          	addi	a4,a1,-1
ffffffffc0201c44:	17f9                	addi	a5,a5,-2
ffffffffc0201c46:	04e7eb63          	bltu	a5,a4,ffffffffc0201c9c <kfree+0x62>
    assert(ptr != NULL);
ffffffffc0201c4a:	c941                	beqz	a0,ffffffffc0201cda <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201c4c:	6785                	lui	a5,0x1
ffffffffc0201c4e:	17fd                	addi	a5,a5,-1
ffffffffc0201c50:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201c52:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c56:	81b1                	srli	a1,a1,0xc
ffffffffc0201c58:	06f56463          	bltu	a0,a5,ffffffffc0201cc0 <kfree+0x86>
ffffffffc0201c5c:	00010797          	auipc	a5,0x10
ffffffffc0201c60:	83478793          	addi	a5,a5,-1996 # ffffffffc0211490 <va_pa_offset>
ffffffffc0201c64:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201c66:	0000f717          	auipc	a4,0xf
ffffffffc0201c6a:	7fa70713          	addi	a4,a4,2042 # ffffffffc0211460 <npage>
ffffffffc0201c6e:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201c70:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0201c74:	83b1                	srli	a5,a5,0xc
ffffffffc0201c76:	04e7f363          	bleu	a4,a5,ffffffffc0201cbc <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c7a:	fff80537          	lui	a0,0xfff80
ffffffffc0201c7e:	97aa                	add	a5,a5,a0
ffffffffc0201c80:	00010697          	auipc	a3,0x10
ffffffffc0201c84:	82068693          	addi	a3,a3,-2016 # ffffffffc02114a0 <pages>
ffffffffc0201c88:	6288                	ld	a0,0(a3)
ffffffffc0201c8a:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0201c8e:	60a2                	ld	ra,8(sp)
ffffffffc0201c90:	97ba                	add	a5,a5,a4
ffffffffc0201c92:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0201c94:	953e                	add	a0,a0,a5
}
ffffffffc0201c96:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc0201c98:	f3dfe06f          	j	ffffffffc0200bd4 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201c9c:	00003697          	auipc	a3,0x3
ffffffffc0201ca0:	0cc68693          	addi	a3,a3,204 # ffffffffc0204d68 <commands+0x8f8>
ffffffffc0201ca4:	00003617          	auipc	a2,0x3
ffffffffc0201ca8:	22c60613          	addi	a2,a2,556 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201cac:	1fb00593          	li	a1,507
ffffffffc0201cb0:	00003517          	auipc	a0,0x3
ffffffffc0201cb4:	09850513          	addi	a0,a0,152 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201cb8:	c4efe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201cbc:	e75fe0ef          	jal	ra,ffffffffc0200b30 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201cc0:	86aa                	mv	a3,a0
ffffffffc0201cc2:	00003617          	auipc	a2,0x3
ffffffffc0201cc6:	1a660613          	addi	a2,a2,422 # ffffffffc0204e68 <commands+0x9f8>
ffffffffc0201cca:	06c00593          	li	a1,108
ffffffffc0201cce:	00003517          	auipc	a0,0x3
ffffffffc0201cd2:	0ea50513          	addi	a0,a0,234 # ffffffffc0204db8 <commands+0x948>
ffffffffc0201cd6:	c30fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(ptr != NULL);
ffffffffc0201cda:	00003697          	auipc	a3,0x3
ffffffffc0201cde:	07e68693          	addi	a3,a3,126 # ffffffffc0204d58 <commands+0x8e8>
ffffffffc0201ce2:	00003617          	auipc	a2,0x3
ffffffffc0201ce6:	1ee60613          	addi	a2,a2,494 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201cea:	1fc00593          	li	a1,508
ffffffffc0201cee:	00003517          	auipc	a0,0x3
ffffffffc0201cf2:	05a50513          	addi	a0,a0,90 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc0201cf6:	c10fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201cfa <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201cfa:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201cfc:	00003697          	auipc	a3,0x3
ffffffffc0201d00:	68c68693          	addi	a3,a3,1676 # ffffffffc0205388 <commands+0xf18>
ffffffffc0201d04:	00003617          	auipc	a2,0x3
ffffffffc0201d08:	1cc60613          	addi	a2,a2,460 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201d0c:	07d00593          	li	a1,125
ffffffffc0201d10:	00003517          	auipc	a0,0x3
ffffffffc0201d14:	69850513          	addi	a0,a0,1688 # ffffffffc02053a8 <commands+0xf38>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201d18:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201d1a:	becfe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201d1e <mm_create>:
mm_create(void) {
ffffffffc0201d1e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201d20:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201d24:	e022                	sd	s0,0(sp)
ffffffffc0201d26:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201d28:	e51ff0ef          	jal	ra,ffffffffc0201b78 <kmalloc>
ffffffffc0201d2c:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201d2e:	c115                	beqz	a0,ffffffffc0201d52 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201d30:	0000f797          	auipc	a5,0xf
ffffffffc0201d34:	74878793          	addi	a5,a5,1864 # ffffffffc0211478 <swap_init_ok>
ffffffffc0201d38:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201d3a:	e408                	sd	a0,8(s0)
ffffffffc0201d3c:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201d3e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201d42:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201d46:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201d4a:	2781                	sext.w	a5,a5
ffffffffc0201d4c:	eb81                	bnez	a5,ffffffffc0201d5c <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0201d4e:	02053423          	sd	zero,40(a0)
}
ffffffffc0201d52:	8522                	mv	a0,s0
ffffffffc0201d54:	60a2                	ld	ra,8(sp)
ffffffffc0201d56:	6402                	ld	s0,0(sp)
ffffffffc0201d58:	0141                	addi	sp,sp,16
ffffffffc0201d5a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201d5c:	631000ef          	jal	ra,ffffffffc0202b8c <swap_init_mm>
}
ffffffffc0201d60:	8522                	mv	a0,s0
ffffffffc0201d62:	60a2                	ld	ra,8(sp)
ffffffffc0201d64:	6402                	ld	s0,0(sp)
ffffffffc0201d66:	0141                	addi	sp,sp,16
ffffffffc0201d68:	8082                	ret

ffffffffc0201d6a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201d6a:	1101                	addi	sp,sp,-32
ffffffffc0201d6c:	e04a                	sd	s2,0(sp)
ffffffffc0201d6e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d70:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201d74:	e822                	sd	s0,16(sp)
ffffffffc0201d76:	e426                	sd	s1,8(sp)
ffffffffc0201d78:	ec06                	sd	ra,24(sp)
ffffffffc0201d7a:	84ae                	mv	s1,a1
ffffffffc0201d7c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d7e:	dfbff0ef          	jal	ra,ffffffffc0201b78 <kmalloc>
    if (vma != NULL) {
ffffffffc0201d82:	c509                	beqz	a0,ffffffffc0201d8c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201d84:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201d88:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201d8a:	ed00                	sd	s0,24(a0)
}
ffffffffc0201d8c:	60e2                	ld	ra,24(sp)
ffffffffc0201d8e:	6442                	ld	s0,16(sp)
ffffffffc0201d90:	64a2                	ld	s1,8(sp)
ffffffffc0201d92:	6902                	ld	s2,0(sp)
ffffffffc0201d94:	6105                	addi	sp,sp,32
ffffffffc0201d96:	8082                	ret

ffffffffc0201d98 <find_vma>:
    if (mm != NULL) {
ffffffffc0201d98:	c51d                	beqz	a0,ffffffffc0201dc6 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0201d9a:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201d9c:	c781                	beqz	a5,ffffffffc0201da4 <find_vma+0xc>
ffffffffc0201d9e:	6798                	ld	a4,8(a5)
ffffffffc0201da0:	02e5f663          	bleu	a4,a1,ffffffffc0201dcc <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0201da4:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201da6:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201da8:	00f50f63          	beq	a0,a5,ffffffffc0201dc6 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201dac:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201db0:	fee5ebe3          	bltu	a1,a4,ffffffffc0201da6 <find_vma+0xe>
ffffffffc0201db4:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201db8:	fee5f7e3          	bleu	a4,a1,ffffffffc0201da6 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0201dbc:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0201dbe:	c781                	beqz	a5,ffffffffc0201dc6 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0201dc0:	e91c                	sd	a5,16(a0)
}
ffffffffc0201dc2:	853e                	mv	a0,a5
ffffffffc0201dc4:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0201dc6:	4781                	li	a5,0
}
ffffffffc0201dc8:	853e                	mv	a0,a5
ffffffffc0201dca:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201dcc:	6b98                	ld	a4,16(a5)
ffffffffc0201dce:	fce5fbe3          	bleu	a4,a1,ffffffffc0201da4 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0201dd2:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0201dd4:	b7fd                	j	ffffffffc0201dc2 <find_vma+0x2a>

ffffffffc0201dd6 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201dd6:	6590                	ld	a2,8(a1)
ffffffffc0201dd8:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201ddc:	1141                	addi	sp,sp,-16
ffffffffc0201dde:	e406                	sd	ra,8(sp)
ffffffffc0201de0:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201de2:	01066863          	bltu	a2,a6,ffffffffc0201df2 <insert_vma_struct+0x1c>
ffffffffc0201de6:	a8b9                	j	ffffffffc0201e44 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201de8:	fe87b683          	ld	a3,-24(a5)
ffffffffc0201dec:	04d66763          	bltu	a2,a3,ffffffffc0201e3a <insert_vma_struct+0x64>
ffffffffc0201df0:	873e                	mv	a4,a5
ffffffffc0201df2:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0201df4:	fef51ae3          	bne	a0,a5,ffffffffc0201de8 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201df8:	02a70463          	beq	a4,a0,ffffffffc0201e20 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201dfc:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201e00:	fe873883          	ld	a7,-24(a4)
ffffffffc0201e04:	08d8f063          	bleu	a3,a7,ffffffffc0201e84 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201e08:	04d66e63          	bltu	a2,a3,ffffffffc0201e64 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0201e0c:	00f50a63          	beq	a0,a5,ffffffffc0201e20 <insert_vma_struct+0x4a>
ffffffffc0201e10:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201e14:	0506e863          	bltu	a3,a6,ffffffffc0201e64 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0201e18:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201e1c:	02c6f263          	bleu	a2,a3,ffffffffc0201e40 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201e20:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0201e22:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201e24:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201e28:	e390                	sd	a2,0(a5)
ffffffffc0201e2a:	e710                	sd	a2,8(a4)
}
ffffffffc0201e2c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201e2e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201e30:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0201e32:	2685                	addiw	a3,a3,1
ffffffffc0201e34:	d114                	sw	a3,32(a0)
}
ffffffffc0201e36:	0141                	addi	sp,sp,16
ffffffffc0201e38:	8082                	ret
    if (le_prev != list) {
ffffffffc0201e3a:	fca711e3          	bne	a4,a0,ffffffffc0201dfc <insert_vma_struct+0x26>
ffffffffc0201e3e:	bfd9                	j	ffffffffc0201e14 <insert_vma_struct+0x3e>
ffffffffc0201e40:	ebbff0ef          	jal	ra,ffffffffc0201cfa <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201e44:	00003697          	auipc	a3,0x3
ffffffffc0201e48:	5f468693          	addi	a3,a3,1524 # ffffffffc0205438 <commands+0xfc8>
ffffffffc0201e4c:	00003617          	auipc	a2,0x3
ffffffffc0201e50:	08460613          	addi	a2,a2,132 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201e54:	08400593          	li	a1,132
ffffffffc0201e58:	00003517          	auipc	a0,0x3
ffffffffc0201e5c:	55050513          	addi	a0,a0,1360 # ffffffffc02053a8 <commands+0xf38>
ffffffffc0201e60:	aa6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201e64:	00003697          	auipc	a3,0x3
ffffffffc0201e68:	61468693          	addi	a3,a3,1556 # ffffffffc0205478 <commands+0x1008>
ffffffffc0201e6c:	00003617          	auipc	a2,0x3
ffffffffc0201e70:	06460613          	addi	a2,a2,100 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201e74:	07c00593          	li	a1,124
ffffffffc0201e78:	00003517          	auipc	a0,0x3
ffffffffc0201e7c:	53050513          	addi	a0,a0,1328 # ffffffffc02053a8 <commands+0xf38>
ffffffffc0201e80:	a86fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201e84:	00003697          	auipc	a3,0x3
ffffffffc0201e88:	5d468693          	addi	a3,a3,1492 # ffffffffc0205458 <commands+0xfe8>
ffffffffc0201e8c:	00003617          	auipc	a2,0x3
ffffffffc0201e90:	04460613          	addi	a2,a2,68 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201e94:	07b00593          	li	a1,123
ffffffffc0201e98:	00003517          	auipc	a0,0x3
ffffffffc0201e9c:	51050513          	addi	a0,a0,1296 # ffffffffc02053a8 <commands+0xf38>
ffffffffc0201ea0:	a66fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201ea4 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201ea4:	1141                	addi	sp,sp,-16
ffffffffc0201ea6:	e022                	sd	s0,0(sp)
ffffffffc0201ea8:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201eaa:	6508                	ld	a0,8(a0)
ffffffffc0201eac:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201eae:	00a40e63          	beq	s0,a0,ffffffffc0201eca <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201eb2:	6118                	ld	a4,0(a0)
ffffffffc0201eb4:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0201eb6:	03000593          	li	a1,48
ffffffffc0201eba:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201ebc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201ebe:	e398                	sd	a4,0(a5)
ffffffffc0201ec0:	d7bff0ef          	jal	ra,ffffffffc0201c3a <kfree>
    return listelm->next;
ffffffffc0201ec4:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201ec6:	fea416e3          	bne	s0,a0,ffffffffc0201eb2 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201eca:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201ecc:	6402                	ld	s0,0(sp)
ffffffffc0201ece:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201ed0:	03000593          	li	a1,48
}
ffffffffc0201ed4:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201ed6:	d65ff06f          	j	ffffffffc0201c3a <kfree>

ffffffffc0201eda <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201eda:	715d                	addi	sp,sp,-80
ffffffffc0201edc:	e486                	sd	ra,72(sp)
ffffffffc0201ede:	e0a2                	sd	s0,64(sp)
ffffffffc0201ee0:	fc26                	sd	s1,56(sp)
ffffffffc0201ee2:	f84a                	sd	s2,48(sp)
ffffffffc0201ee4:	f052                	sd	s4,32(sp)
ffffffffc0201ee6:	f44e                	sd	s3,40(sp)
ffffffffc0201ee8:	ec56                	sd	s5,24(sp)
ffffffffc0201eea:	e85a                	sd	s6,16(sp)
ffffffffc0201eec:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201eee:	d2dfe0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
ffffffffc0201ef2:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201ef4:	d27fe0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
ffffffffc0201ef8:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0201efa:	e25ff0ef          	jal	ra,ffffffffc0201d1e <mm_create>
    assert(mm != NULL);
ffffffffc0201efe:	842a                	mv	s0,a0
ffffffffc0201f00:	03200493          	li	s1,50
ffffffffc0201f04:	e919                	bnez	a0,ffffffffc0201f1a <vmm_init+0x40>
ffffffffc0201f06:	aeed                	j	ffffffffc0202300 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0201f08:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201f0a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201f0c:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201f10:	14ed                	addi	s1,s1,-5
ffffffffc0201f12:	8522                	mv	a0,s0
ffffffffc0201f14:	ec3ff0ef          	jal	ra,ffffffffc0201dd6 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201f18:	c88d                	beqz	s1,ffffffffc0201f4a <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201f1a:	03000513          	li	a0,48
ffffffffc0201f1e:	c5bff0ef          	jal	ra,ffffffffc0201b78 <kmalloc>
ffffffffc0201f22:	85aa                	mv	a1,a0
ffffffffc0201f24:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201f28:	f165                	bnez	a0,ffffffffc0201f08 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0201f2a:	00003697          	auipc	a3,0x3
ffffffffc0201f2e:	79668693          	addi	a3,a3,1942 # ffffffffc02056c0 <commands+0x1250>
ffffffffc0201f32:	00003617          	auipc	a2,0x3
ffffffffc0201f36:	f9e60613          	addi	a2,a2,-98 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201f3a:	0ce00593          	li	a1,206
ffffffffc0201f3e:	00003517          	auipc	a0,0x3
ffffffffc0201f42:	46a50513          	addi	a0,a0,1130 # ffffffffc02053a8 <commands+0xf38>
ffffffffc0201f46:	9c0fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201f4a:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201f4e:	1f900993          	li	s3,505
ffffffffc0201f52:	a819                	j	ffffffffc0201f68 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0201f54:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201f56:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201f58:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201f5c:	0495                	addi	s1,s1,5
ffffffffc0201f5e:	8522                	mv	a0,s0
ffffffffc0201f60:	e77ff0ef          	jal	ra,ffffffffc0201dd6 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201f64:	03348a63          	beq	s1,s3,ffffffffc0201f98 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201f68:	03000513          	li	a0,48
ffffffffc0201f6c:	c0dff0ef          	jal	ra,ffffffffc0201b78 <kmalloc>
ffffffffc0201f70:	85aa                	mv	a1,a0
ffffffffc0201f72:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201f76:	fd79                	bnez	a0,ffffffffc0201f54 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0201f78:	00003697          	auipc	a3,0x3
ffffffffc0201f7c:	74868693          	addi	a3,a3,1864 # ffffffffc02056c0 <commands+0x1250>
ffffffffc0201f80:	00003617          	auipc	a2,0x3
ffffffffc0201f84:	f5060613          	addi	a2,a2,-176 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0201f88:	0d400593          	li	a1,212
ffffffffc0201f8c:	00003517          	auipc	a0,0x3
ffffffffc0201f90:	41c50513          	addi	a0,a0,1052 # ffffffffc02053a8 <commands+0xf38>
ffffffffc0201f94:	972fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201f98:	6418                	ld	a4,8(s0)
ffffffffc0201f9a:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0201f9c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201fa0:	2ae40063          	beq	s0,a4,ffffffffc0202240 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201fa4:	fe873603          	ld	a2,-24(a4)
ffffffffc0201fa8:	ffe78693          	addi	a3,a5,-2
ffffffffc0201fac:	20d61a63          	bne	a2,a3,ffffffffc02021c0 <vmm_init+0x2e6>
ffffffffc0201fb0:	ff073683          	ld	a3,-16(a4)
ffffffffc0201fb4:	20d79663          	bne	a5,a3,ffffffffc02021c0 <vmm_init+0x2e6>
ffffffffc0201fb8:	0795                	addi	a5,a5,5
ffffffffc0201fba:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0201fbc:	feb792e3          	bne	a5,a1,ffffffffc0201fa0 <vmm_init+0xc6>
ffffffffc0201fc0:	499d                	li	s3,7
ffffffffc0201fc2:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201fc4:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201fc8:	85a6                	mv	a1,s1
ffffffffc0201fca:	8522                	mv	a0,s0
ffffffffc0201fcc:	dcdff0ef          	jal	ra,ffffffffc0201d98 <find_vma>
ffffffffc0201fd0:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0201fd2:	2e050763          	beqz	a0,ffffffffc02022c0 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201fd6:	00148593          	addi	a1,s1,1
ffffffffc0201fda:	8522                	mv	a0,s0
ffffffffc0201fdc:	dbdff0ef          	jal	ra,ffffffffc0201d98 <find_vma>
ffffffffc0201fe0:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0201fe2:	2a050f63          	beqz	a0,ffffffffc02022a0 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201fe6:	85ce                	mv	a1,s3
ffffffffc0201fe8:	8522                	mv	a0,s0
ffffffffc0201fea:	dafff0ef          	jal	ra,ffffffffc0201d98 <find_vma>
        assert(vma3 == NULL);
ffffffffc0201fee:	28051963          	bnez	a0,ffffffffc0202280 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201ff2:	00348593          	addi	a1,s1,3
ffffffffc0201ff6:	8522                	mv	a0,s0
ffffffffc0201ff8:	da1ff0ef          	jal	ra,ffffffffc0201d98 <find_vma>
        assert(vma4 == NULL);
ffffffffc0201ffc:	26051263          	bnez	a0,ffffffffc0202260 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202000:	00448593          	addi	a1,s1,4
ffffffffc0202004:	8522                	mv	a0,s0
ffffffffc0202006:	d93ff0ef          	jal	ra,ffffffffc0201d98 <find_vma>
        assert(vma5 == NULL);
ffffffffc020200a:	2c051b63          	bnez	a0,ffffffffc02022e0 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020200e:	008b3783          	ld	a5,8(s6)
ffffffffc0202012:	1c979763          	bne	a5,s1,ffffffffc02021e0 <vmm_init+0x306>
ffffffffc0202016:	010b3783          	ld	a5,16(s6)
ffffffffc020201a:	1d379363          	bne	a5,s3,ffffffffc02021e0 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020201e:	008ab783          	ld	a5,8(s5)
ffffffffc0202022:	1c979f63          	bne	a5,s1,ffffffffc0202200 <vmm_init+0x326>
ffffffffc0202026:	010ab783          	ld	a5,16(s5)
ffffffffc020202a:	1d379b63          	bne	a5,s3,ffffffffc0202200 <vmm_init+0x326>
ffffffffc020202e:	0495                	addi	s1,s1,5
ffffffffc0202030:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202032:	f9749be3          	bne	s1,s7,ffffffffc0201fc8 <vmm_init+0xee>
ffffffffc0202036:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202038:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020203a:	85a6                	mv	a1,s1
ffffffffc020203c:	8522                	mv	a0,s0
ffffffffc020203e:	d5bff0ef          	jal	ra,ffffffffc0201d98 <find_vma>
ffffffffc0202042:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0202046:	c90d                	beqz	a0,ffffffffc0202078 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202048:	6914                	ld	a3,16(a0)
ffffffffc020204a:	6510                	ld	a2,8(a0)
ffffffffc020204c:	00003517          	auipc	a0,0x3
ffffffffc0202050:	55c50513          	addi	a0,a0,1372 # ffffffffc02055a8 <commands+0x1138>
ffffffffc0202054:	86afe0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202058:	00003697          	auipc	a3,0x3
ffffffffc020205c:	57868693          	addi	a3,a3,1400 # ffffffffc02055d0 <commands+0x1160>
ffffffffc0202060:	00003617          	auipc	a2,0x3
ffffffffc0202064:	e7060613          	addi	a2,a2,-400 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202068:	0f600593          	li	a1,246
ffffffffc020206c:	00003517          	auipc	a0,0x3
ffffffffc0202070:	33c50513          	addi	a0,a0,828 # ffffffffc02053a8 <commands+0xf38>
ffffffffc0202074:	892fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0202078:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020207a:	fd3490e3          	bne	s1,s3,ffffffffc020203a <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc020207e:	8522                	mv	a0,s0
ffffffffc0202080:	e25ff0ef          	jal	ra,ffffffffc0201ea4 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202084:	b97fe0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
ffffffffc0202088:	28aa1c63          	bne	s4,a0,ffffffffc0202320 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020208c:	00003517          	auipc	a0,0x3
ffffffffc0202090:	58450513          	addi	a0,a0,1412 # ffffffffc0205610 <commands+0x11a0>
ffffffffc0202094:	82afe0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202098:	b83fe0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
ffffffffc020209c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020209e:	c81ff0ef          	jal	ra,ffffffffc0201d1e <mm_create>
ffffffffc02020a2:	0000f797          	auipc	a5,0xf
ffffffffc02020a6:	40a7b323          	sd	a0,1030(a5) # ffffffffc02114a8 <check_mm_struct>
ffffffffc02020aa:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc02020ac:	2a050a63          	beqz	a0,ffffffffc0202360 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02020b0:	0000f797          	auipc	a5,0xf
ffffffffc02020b4:	3a878793          	addi	a5,a5,936 # ffffffffc0211458 <boot_pgdir>
ffffffffc02020b8:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02020ba:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02020bc:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02020be:	32079d63          	bnez	a5,ffffffffc02023f8 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02020c2:	03000513          	li	a0,48
ffffffffc02020c6:	ab3ff0ef          	jal	ra,ffffffffc0201b78 <kmalloc>
ffffffffc02020ca:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02020cc:	14050a63          	beqz	a0,ffffffffc0202220 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc02020d0:	002007b7          	lui	a5,0x200
ffffffffc02020d4:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02020d8:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02020da:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02020dc:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02020e0:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02020e2:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02020e6:	cf1ff0ef          	jal	ra,ffffffffc0201dd6 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02020ea:	10000593          	li	a1,256
ffffffffc02020ee:	8522                	mv	a0,s0
ffffffffc02020f0:	ca9ff0ef          	jal	ra,ffffffffc0201d98 <find_vma>
ffffffffc02020f4:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02020f8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02020fc:	2aaa1263          	bne	s4,a0,ffffffffc02023a0 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0202100:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0202104:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0202106:	fee79de3          	bne	a5,a4,ffffffffc0202100 <vmm_init+0x226>
        sum += i;
ffffffffc020210a:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020210c:	10000793          	li	a5,256
        sum += i;
ffffffffc0202110:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202114:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202118:	0007c683          	lbu	a3,0(a5)
ffffffffc020211c:	0785                	addi	a5,a5,1
ffffffffc020211e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202120:	fec79ce3          	bne	a5,a2,ffffffffc0202118 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0202124:	2a071a63          	bnez	a4,ffffffffc02023d8 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202128:	4581                	li	a1,0
ffffffffc020212a:	8526                	mv	a0,s1
ffffffffc020212c:	d95fe0ef          	jal	ra,ffffffffc0200ec0 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202130:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0202132:	0000f717          	auipc	a4,0xf
ffffffffc0202136:	32e70713          	addi	a4,a4,814 # ffffffffc0211460 <npage>
ffffffffc020213a:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc020213c:	078a                	slli	a5,a5,0x2
ffffffffc020213e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202140:	28e7f063          	bleu	a4,a5,ffffffffc02023c0 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202144:	00004717          	auipc	a4,0x4
ffffffffc0202148:	04470713          	addi	a4,a4,68 # ffffffffc0206188 <nbase>
ffffffffc020214c:	6318                	ld	a4,0(a4)
ffffffffc020214e:	0000f697          	auipc	a3,0xf
ffffffffc0202152:	35268693          	addi	a3,a3,850 # ffffffffc02114a0 <pages>
ffffffffc0202156:	6288                	ld	a0,0(a3)
ffffffffc0202158:	8f99                	sub	a5,a5,a4
ffffffffc020215a:	00379713          	slli	a4,a5,0x3
ffffffffc020215e:	97ba                	add	a5,a5,a4
ffffffffc0202160:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0202162:	953e                	add	a0,a0,a5
ffffffffc0202164:	4585                	li	a1,1
ffffffffc0202166:	a6ffe0ef          	jal	ra,ffffffffc0200bd4 <free_pages>

    pgdir[0] = 0;
ffffffffc020216a:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020216e:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0202170:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0202174:	d31ff0ef          	jal	ra,ffffffffc0201ea4 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0202178:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc020217a:	0000f797          	auipc	a5,0xf
ffffffffc020217e:	3207b723          	sd	zero,814(a5) # ffffffffc02114a8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202182:	a99fe0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
ffffffffc0202186:	1aa99d63          	bne	s3,a0,ffffffffc0202340 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020218a:	00003517          	auipc	a0,0x3
ffffffffc020218e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0205688 <commands+0x1218>
ffffffffc0202192:	f2dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202196:	a85fe0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020219a:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020219c:	1ea91263          	bne	s2,a0,ffffffffc0202380 <vmm_init+0x4a6>
}
ffffffffc02021a0:	6406                	ld	s0,64(sp)
ffffffffc02021a2:	60a6                	ld	ra,72(sp)
ffffffffc02021a4:	74e2                	ld	s1,56(sp)
ffffffffc02021a6:	7942                	ld	s2,48(sp)
ffffffffc02021a8:	79a2                	ld	s3,40(sp)
ffffffffc02021aa:	7a02                	ld	s4,32(sp)
ffffffffc02021ac:	6ae2                	ld	s5,24(sp)
ffffffffc02021ae:	6b42                	ld	s6,16(sp)
ffffffffc02021b0:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02021b2:	00003517          	auipc	a0,0x3
ffffffffc02021b6:	4f650513          	addi	a0,a0,1270 # ffffffffc02056a8 <commands+0x1238>
}
ffffffffc02021ba:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02021bc:	f03fd06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02021c0:	00003697          	auipc	a3,0x3
ffffffffc02021c4:	30068693          	addi	a3,a3,768 # ffffffffc02054c0 <commands+0x1050>
ffffffffc02021c8:	00003617          	auipc	a2,0x3
ffffffffc02021cc:	d0860613          	addi	a2,a2,-760 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02021d0:	0dd00593          	li	a1,221
ffffffffc02021d4:	00003517          	auipc	a0,0x3
ffffffffc02021d8:	1d450513          	addi	a0,a0,468 # ffffffffc02053a8 <commands+0xf38>
ffffffffc02021dc:	f2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02021e0:	00003697          	auipc	a3,0x3
ffffffffc02021e4:	36868693          	addi	a3,a3,872 # ffffffffc0205548 <commands+0x10d8>
ffffffffc02021e8:	00003617          	auipc	a2,0x3
ffffffffc02021ec:	ce860613          	addi	a2,a2,-792 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02021f0:	0ed00593          	li	a1,237
ffffffffc02021f4:	00003517          	auipc	a0,0x3
ffffffffc02021f8:	1b450513          	addi	a0,a0,436 # ffffffffc02053a8 <commands+0xf38>
ffffffffc02021fc:	f0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202200:	00003697          	auipc	a3,0x3
ffffffffc0202204:	37868693          	addi	a3,a3,888 # ffffffffc0205578 <commands+0x1108>
ffffffffc0202208:	00003617          	auipc	a2,0x3
ffffffffc020220c:	cc860613          	addi	a2,a2,-824 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202210:	0ee00593          	li	a1,238
ffffffffc0202214:	00003517          	auipc	a0,0x3
ffffffffc0202218:	19450513          	addi	a0,a0,404 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020221c:	eebfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(vma != NULL);
ffffffffc0202220:	00003697          	auipc	a3,0x3
ffffffffc0202224:	4a068693          	addi	a3,a3,1184 # ffffffffc02056c0 <commands+0x1250>
ffffffffc0202228:	00003617          	auipc	a2,0x3
ffffffffc020222c:	ca860613          	addi	a2,a2,-856 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202230:	11100593          	li	a1,273
ffffffffc0202234:	00003517          	auipc	a0,0x3
ffffffffc0202238:	17450513          	addi	a0,a0,372 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020223c:	ecbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202240:	00003697          	auipc	a3,0x3
ffffffffc0202244:	26868693          	addi	a3,a3,616 # ffffffffc02054a8 <commands+0x1038>
ffffffffc0202248:	00003617          	auipc	a2,0x3
ffffffffc020224c:	c8860613          	addi	a2,a2,-888 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202250:	0db00593          	li	a1,219
ffffffffc0202254:	00003517          	auipc	a0,0x3
ffffffffc0202258:	15450513          	addi	a0,a0,340 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020225c:	eabfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma4 == NULL);
ffffffffc0202260:	00003697          	auipc	a3,0x3
ffffffffc0202264:	2c868693          	addi	a3,a3,712 # ffffffffc0205528 <commands+0x10b8>
ffffffffc0202268:	00003617          	auipc	a2,0x3
ffffffffc020226c:	c6860613          	addi	a2,a2,-920 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202270:	0e900593          	li	a1,233
ffffffffc0202274:	00003517          	auipc	a0,0x3
ffffffffc0202278:	13450513          	addi	a0,a0,308 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020227c:	e8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma3 == NULL);
ffffffffc0202280:	00003697          	auipc	a3,0x3
ffffffffc0202284:	29868693          	addi	a3,a3,664 # ffffffffc0205518 <commands+0x10a8>
ffffffffc0202288:	00003617          	auipc	a2,0x3
ffffffffc020228c:	c4860613          	addi	a2,a2,-952 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202290:	0e700593          	li	a1,231
ffffffffc0202294:	00003517          	auipc	a0,0x3
ffffffffc0202298:	11450513          	addi	a0,a0,276 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020229c:	e6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2 != NULL);
ffffffffc02022a0:	00003697          	auipc	a3,0x3
ffffffffc02022a4:	26868693          	addi	a3,a3,616 # ffffffffc0205508 <commands+0x1098>
ffffffffc02022a8:	00003617          	auipc	a2,0x3
ffffffffc02022ac:	c2860613          	addi	a2,a2,-984 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02022b0:	0e500593          	li	a1,229
ffffffffc02022b4:	00003517          	auipc	a0,0x3
ffffffffc02022b8:	0f450513          	addi	a0,a0,244 # ffffffffc02053a8 <commands+0xf38>
ffffffffc02022bc:	e4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1 != NULL);
ffffffffc02022c0:	00003697          	auipc	a3,0x3
ffffffffc02022c4:	23868693          	addi	a3,a3,568 # ffffffffc02054f8 <commands+0x1088>
ffffffffc02022c8:	00003617          	auipc	a2,0x3
ffffffffc02022cc:	c0860613          	addi	a2,a2,-1016 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02022d0:	0e300593          	li	a1,227
ffffffffc02022d4:	00003517          	auipc	a0,0x3
ffffffffc02022d8:	0d450513          	addi	a0,a0,212 # ffffffffc02053a8 <commands+0xf38>
ffffffffc02022dc:	e2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma5 == NULL);
ffffffffc02022e0:	00003697          	auipc	a3,0x3
ffffffffc02022e4:	25868693          	addi	a3,a3,600 # ffffffffc0205538 <commands+0x10c8>
ffffffffc02022e8:	00003617          	auipc	a2,0x3
ffffffffc02022ec:	be860613          	addi	a2,a2,-1048 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02022f0:	0eb00593          	li	a1,235
ffffffffc02022f4:	00003517          	auipc	a0,0x3
ffffffffc02022f8:	0b450513          	addi	a0,a0,180 # ffffffffc02053a8 <commands+0xf38>
ffffffffc02022fc:	e0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(mm != NULL);
ffffffffc0202300:	00003697          	auipc	a3,0x3
ffffffffc0202304:	19868693          	addi	a3,a3,408 # ffffffffc0205498 <commands+0x1028>
ffffffffc0202308:	00003617          	auipc	a2,0x3
ffffffffc020230c:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202310:	0c700593          	li	a1,199
ffffffffc0202314:	00003517          	auipc	a0,0x3
ffffffffc0202318:	09450513          	addi	a0,a0,148 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020231c:	debfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202320:	00003697          	auipc	a3,0x3
ffffffffc0202324:	2c868693          	addi	a3,a3,712 # ffffffffc02055e8 <commands+0x1178>
ffffffffc0202328:	00003617          	auipc	a2,0x3
ffffffffc020232c:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202330:	0fb00593          	li	a1,251
ffffffffc0202334:	00003517          	auipc	a0,0x3
ffffffffc0202338:	07450513          	addi	a0,a0,116 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020233c:	dcbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202340:	00003697          	auipc	a3,0x3
ffffffffc0202344:	2a868693          	addi	a3,a3,680 # ffffffffc02055e8 <commands+0x1178>
ffffffffc0202348:	00003617          	auipc	a2,0x3
ffffffffc020234c:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202350:	12e00593          	li	a1,302
ffffffffc0202354:	00003517          	auipc	a0,0x3
ffffffffc0202358:	05450513          	addi	a0,a0,84 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020235c:	dabfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202360:	00003697          	auipc	a3,0x3
ffffffffc0202364:	2d068693          	addi	a3,a3,720 # ffffffffc0205630 <commands+0x11c0>
ffffffffc0202368:	00003617          	auipc	a2,0x3
ffffffffc020236c:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202370:	10a00593          	li	a1,266
ffffffffc0202374:	00003517          	auipc	a0,0x3
ffffffffc0202378:	03450513          	addi	a0,a0,52 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020237c:	d8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202380:	00003697          	auipc	a3,0x3
ffffffffc0202384:	26868693          	addi	a3,a3,616 # ffffffffc02055e8 <commands+0x1178>
ffffffffc0202388:	00003617          	auipc	a2,0x3
ffffffffc020238c:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202390:	0bd00593          	li	a1,189
ffffffffc0202394:	00003517          	auipc	a0,0x3
ffffffffc0202398:	01450513          	addi	a0,a0,20 # ffffffffc02053a8 <commands+0xf38>
ffffffffc020239c:	d6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02023a0:	00003697          	auipc	a3,0x3
ffffffffc02023a4:	2b868693          	addi	a3,a3,696 # ffffffffc0205658 <commands+0x11e8>
ffffffffc02023a8:	00003617          	auipc	a2,0x3
ffffffffc02023ac:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02023b0:	11600593          	li	a1,278
ffffffffc02023b4:	00003517          	auipc	a0,0x3
ffffffffc02023b8:	ff450513          	addi	a0,a0,-12 # ffffffffc02053a8 <commands+0xf38>
ffffffffc02023bc:	d4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02023c0:	00003617          	auipc	a2,0x3
ffffffffc02023c4:	9d860613          	addi	a2,a2,-1576 # ffffffffc0204d98 <commands+0x928>
ffffffffc02023c8:	06500593          	li	a1,101
ffffffffc02023cc:	00003517          	auipc	a0,0x3
ffffffffc02023d0:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0204db8 <commands+0x948>
ffffffffc02023d4:	d33fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(sum == 0);
ffffffffc02023d8:	00003697          	auipc	a3,0x3
ffffffffc02023dc:	2a068693          	addi	a3,a3,672 # ffffffffc0205678 <commands+0x1208>
ffffffffc02023e0:	00003617          	auipc	a2,0x3
ffffffffc02023e4:	af060613          	addi	a2,a2,-1296 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02023e8:	12000593          	li	a1,288
ffffffffc02023ec:	00003517          	auipc	a0,0x3
ffffffffc02023f0:	fbc50513          	addi	a0,a0,-68 # ffffffffc02053a8 <commands+0xf38>
ffffffffc02023f4:	d13fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02023f8:	00003697          	auipc	a3,0x3
ffffffffc02023fc:	25068693          	addi	a3,a3,592 # ffffffffc0205648 <commands+0x11d8>
ffffffffc0202400:	00003617          	auipc	a2,0x3
ffffffffc0202404:	ad060613          	addi	a2,a2,-1328 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202408:	10d00593          	li	a1,269
ffffffffc020240c:	00003517          	auipc	a0,0x3
ffffffffc0202410:	f9c50513          	addi	a0,a0,-100 # ffffffffc02053a8 <commands+0xf38>
ffffffffc0202414:	cf3fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202418 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202418:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020241a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020241c:	f022                	sd	s0,32(sp)
ffffffffc020241e:	ec26                	sd	s1,24(sp)
ffffffffc0202420:	f406                	sd	ra,40(sp)
ffffffffc0202422:	e84a                	sd	s2,16(sp)
ffffffffc0202424:	8432                	mv	s0,a2
ffffffffc0202426:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202428:	971ff0ef          	jal	ra,ffffffffc0201d98 <find_vma>

    pgfault_num++;
ffffffffc020242c:	0000f797          	auipc	a5,0xf
ffffffffc0202430:	03c78793          	addi	a5,a5,60 # ffffffffc0211468 <pgfault_num>
ffffffffc0202434:	439c                	lw	a5,0(a5)
ffffffffc0202436:	2785                	addiw	a5,a5,1
ffffffffc0202438:	0000f717          	auipc	a4,0xf
ffffffffc020243c:	02f72823          	sw	a5,48(a4) # ffffffffc0211468 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202440:	c549                	beqz	a0,ffffffffc02024ca <do_pgfault+0xb2>
ffffffffc0202442:	651c                	ld	a5,8(a0)
ffffffffc0202444:	08f46363          	bltu	s0,a5,ffffffffc02024ca <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202448:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020244a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020244c:	8b89                	andi	a5,a5,2
ffffffffc020244e:	efa9                	bnez	a5,ffffffffc02024a8 <do_pgfault+0x90>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202450:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0202452:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202454:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0202456:	85a2                	mv	a1,s0
ffffffffc0202458:	4605                	li	a2,1
ffffffffc020245a:	801fe0ef          	jal	ra,ffffffffc0200c5a <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc020245e:	610c                	ld	a1,0(a0)
ffffffffc0202460:	c5b1                	beqz	a1,ffffffffc02024ac <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202462:	0000f797          	auipc	a5,0xf
ffffffffc0202466:	01678793          	addi	a5,a5,22 # ffffffffc0211478 <swap_init_ok>
ffffffffc020246a:	439c                	lw	a5,0(a5)
ffffffffc020246c:	2781                	sext.w	a5,a5
ffffffffc020246e:	c7bd                	beqz	a5,ffffffffc02024dc <do_pgfault+0xc4>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc0202470:	85a2                	mv	a1,s0
ffffffffc0202472:	0030                	addi	a2,sp,8
ffffffffc0202474:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0202476:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0202478:	049000ef          	jal	ra,ffffffffc0202cc0 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc020247c:	65a2                	ld	a1,8(sp)
ffffffffc020247e:	6c88                	ld	a0,24(s1)
ffffffffc0202480:	86ca                	mv	a3,s2
ffffffffc0202482:	8622                	mv	a2,s0
ffffffffc0202484:	aaffe0ef          	jal	ra,ffffffffc0200f32 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0202488:	6622                	ld	a2,8(sp)
ffffffffc020248a:	4685                	li	a3,1
ffffffffc020248c:	85a2                	mv	a1,s0
ffffffffc020248e:	8526                	mv	a0,s1
ffffffffc0202490:	70c000ef          	jal	ra,ffffffffc0202b9c <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0202494:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0202496:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0202498:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc020249a:	70a2                	ld	ra,40(sp)
ffffffffc020249c:	7402                	ld	s0,32(sp)
ffffffffc020249e:	64e2                	ld	s1,24(sp)
ffffffffc02024a0:	6942                	ld	s2,16(sp)
ffffffffc02024a2:	853e                	mv	a0,a5
ffffffffc02024a4:	6145                	addi	sp,sp,48
ffffffffc02024a6:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc02024a8:	4959                	li	s2,22
ffffffffc02024aa:	b75d                	j	ffffffffc0202450 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02024ac:	6c88                	ld	a0,24(s1)
ffffffffc02024ae:	864a                	mv	a2,s2
ffffffffc02024b0:	85a2                	mv	a1,s0
ffffffffc02024b2:	e34ff0ef          	jal	ra,ffffffffc0201ae6 <pgdir_alloc_page>
   ret = 0;
ffffffffc02024b6:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02024b8:	f16d                	bnez	a0,ffffffffc020249a <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02024ba:	00003517          	auipc	a0,0x3
ffffffffc02024be:	f2e50513          	addi	a0,a0,-210 # ffffffffc02053e8 <commands+0xf78>
ffffffffc02024c2:	bfdfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc02024c6:	57f1                	li	a5,-4
            goto failed;
ffffffffc02024c8:	bfc9                	j	ffffffffc020249a <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02024ca:	85a2                	mv	a1,s0
ffffffffc02024cc:	00003517          	auipc	a0,0x3
ffffffffc02024d0:	eec50513          	addi	a0,a0,-276 # ffffffffc02053b8 <commands+0xf48>
ffffffffc02024d4:	bebfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc02024d8:	57f5                	li	a5,-3
        goto failed;
ffffffffc02024da:	b7c1                	j	ffffffffc020249a <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02024dc:	00003517          	auipc	a0,0x3
ffffffffc02024e0:	f3450513          	addi	a0,a0,-204 # ffffffffc0205410 <commands+0xfa0>
ffffffffc02024e4:	bdbfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc02024e8:	57f1                	li	a5,-4
            goto failed;
ffffffffc02024ea:	bf45                	j	ffffffffc020249a <do_pgfault+0x82>

ffffffffc02024ec <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02024ec:	7135                	addi	sp,sp,-160
ffffffffc02024ee:	ed06                	sd	ra,152(sp)
ffffffffc02024f0:	e922                	sd	s0,144(sp)
ffffffffc02024f2:	e526                	sd	s1,136(sp)
ffffffffc02024f4:	e14a                	sd	s2,128(sp)
ffffffffc02024f6:	fcce                	sd	s3,120(sp)
ffffffffc02024f8:	f8d2                	sd	s4,112(sp)
ffffffffc02024fa:	f4d6                	sd	s5,104(sp)
ffffffffc02024fc:	f0da                	sd	s6,96(sp)
ffffffffc02024fe:	ecde                	sd	s7,88(sp)
ffffffffc0202500:	e8e2                	sd	s8,80(sp)
ffffffffc0202502:	e4e6                	sd	s9,72(sp)
ffffffffc0202504:	e0ea                	sd	s10,64(sp)
ffffffffc0202506:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202508:	718010ef          	jal	ra,ffffffffc0203c20 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020250c:	0000f797          	auipc	a5,0xf
ffffffffc0202510:	02c78793          	addi	a5,a5,44 # ffffffffc0211538 <max_swap_offset>
ffffffffc0202514:	6394                	ld	a3,0(a5)
ffffffffc0202516:	010007b7          	lui	a5,0x1000
ffffffffc020251a:	17e1                	addi	a5,a5,-8
ffffffffc020251c:	ff968713          	addi	a4,a3,-7
ffffffffc0202520:	42e7ea63          	bltu	a5,a4,ffffffffc0202954 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use clock Page Replacement Algorithm
ffffffffc0202524:	00008797          	auipc	a5,0x8
ffffffffc0202528:	adc78793          	addi	a5,a5,-1316 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc020252c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use clock Page Replacement Algorithm
ffffffffc020252e:	0000f697          	auipc	a3,0xf
ffffffffc0202532:	f4f6b123          	sd	a5,-190(a3) # ffffffffc0211470 <sm>
     int r = sm->init();
ffffffffc0202536:	9702                	jalr	a4
ffffffffc0202538:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020253a:	c10d                	beqz	a0,ffffffffc020255c <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020253c:	60ea                	ld	ra,152(sp)
ffffffffc020253e:	644a                	ld	s0,144(sp)
ffffffffc0202540:	855a                	mv	a0,s6
ffffffffc0202542:	64aa                	ld	s1,136(sp)
ffffffffc0202544:	690a                	ld	s2,128(sp)
ffffffffc0202546:	79e6                	ld	s3,120(sp)
ffffffffc0202548:	7a46                	ld	s4,112(sp)
ffffffffc020254a:	7aa6                	ld	s5,104(sp)
ffffffffc020254c:	7b06                	ld	s6,96(sp)
ffffffffc020254e:	6be6                	ld	s7,88(sp)
ffffffffc0202550:	6c46                	ld	s8,80(sp)
ffffffffc0202552:	6ca6                	ld	s9,72(sp)
ffffffffc0202554:	6d06                	ld	s10,64(sp)
ffffffffc0202556:	7de2                	ld	s11,56(sp)
ffffffffc0202558:	610d                	addi	sp,sp,160
ffffffffc020255a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020255c:	0000f797          	auipc	a5,0xf
ffffffffc0202560:	f1478793          	addi	a5,a5,-236 # ffffffffc0211470 <sm>
ffffffffc0202564:	639c                	ld	a5,0(a5)
ffffffffc0202566:	00003517          	auipc	a0,0x3
ffffffffc020256a:	1ea50513          	addi	a0,a0,490 # ffffffffc0205750 <commands+0x12e0>
ffffffffc020256e:	0000f417          	auipc	s0,0xf
ffffffffc0202572:	01a40413          	addi	s0,s0,26 # ffffffffc0211588 <free_area>
ffffffffc0202576:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202578:	4785                	li	a5,1
ffffffffc020257a:	0000f717          	auipc	a4,0xf
ffffffffc020257e:	eef72f23          	sw	a5,-258(a4) # ffffffffc0211478 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202582:	b3dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202586:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202588:	2e878a63          	beq	a5,s0,ffffffffc020287c <swap_init+0x390>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020258c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202590:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202592:	8b05                	andi	a4,a4,1
ffffffffc0202594:	2e070863          	beqz	a4,ffffffffc0202884 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc0202598:	4481                	li	s1,0
ffffffffc020259a:	4901                	li	s2,0
ffffffffc020259c:	a031                	j	ffffffffc02025a8 <swap_init+0xbc>
ffffffffc020259e:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc02025a2:	8b09                	andi	a4,a4,2
ffffffffc02025a4:	2e070063          	beqz	a4,ffffffffc0202884 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc02025a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02025ac:	679c                	ld	a5,8(a5)
ffffffffc02025ae:	2905                	addiw	s2,s2,1
ffffffffc02025b0:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02025b2:	fe8796e3          	bne	a5,s0,ffffffffc020259e <swap_init+0xb2>
ffffffffc02025b6:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02025b8:	e62fe0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
ffffffffc02025bc:	5b351863          	bne	a0,s3,ffffffffc0202b6c <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02025c0:	8626                	mv	a2,s1
ffffffffc02025c2:	85ca                	mv	a1,s2
ffffffffc02025c4:	00003517          	auipc	a0,0x3
ffffffffc02025c8:	1d450513          	addi	a0,a0,468 # ffffffffc0205798 <commands+0x1328>
ffffffffc02025cc:	af3fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02025d0:	f4eff0ef          	jal	ra,ffffffffc0201d1e <mm_create>
ffffffffc02025d4:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02025d6:	50050b63          	beqz	a0,ffffffffc0202aec <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02025da:	0000f797          	auipc	a5,0xf
ffffffffc02025de:	ece78793          	addi	a5,a5,-306 # ffffffffc02114a8 <check_mm_struct>
ffffffffc02025e2:	639c                	ld	a5,0(a5)
ffffffffc02025e4:	52079463          	bnez	a5,ffffffffc0202b0c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02025e8:	0000f797          	auipc	a5,0xf
ffffffffc02025ec:	e7078793          	addi	a5,a5,-400 # ffffffffc0211458 <boot_pgdir>
ffffffffc02025f0:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc02025f2:	0000f797          	auipc	a5,0xf
ffffffffc02025f6:	eaa7bb23          	sd	a0,-330(a5) # ffffffffc02114a8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02025fa:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02025fc:	ec3a                	sd	a4,24(sp)
ffffffffc02025fe:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202600:	52079663          	bnez	a5,ffffffffc0202b2c <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202604:	6599                	lui	a1,0x6
ffffffffc0202606:	460d                	li	a2,3
ffffffffc0202608:	6505                	lui	a0,0x1
ffffffffc020260a:	f60ff0ef          	jal	ra,ffffffffc0201d6a <vma_create>
ffffffffc020260e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202610:	52050e63          	beqz	a0,ffffffffc0202b4c <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202614:	855e                	mv	a0,s7
ffffffffc0202616:	fc0ff0ef          	jal	ra,ffffffffc0201dd6 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020261a:	00003517          	auipc	a0,0x3
ffffffffc020261e:	1be50513          	addi	a0,a0,446 # ffffffffc02057d8 <commands+0x1368>
ffffffffc0202622:	a9dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202626:	018bb503          	ld	a0,24(s7)
ffffffffc020262a:	4605                	li	a2,1
ffffffffc020262c:	6585                	lui	a1,0x1
ffffffffc020262e:	e2cfe0ef          	jal	ra,ffffffffc0200c5a <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202632:	40050d63          	beqz	a0,ffffffffc0202a4c <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202636:	00003517          	auipc	a0,0x3
ffffffffc020263a:	1f250513          	addi	a0,a0,498 # ffffffffc0205828 <commands+0x13b8>
ffffffffc020263e:	0000fa17          	auipc	s4,0xf
ffffffffc0202642:	e72a0a13          	addi	s4,s4,-398 # ffffffffc02114b0 <check_rp>
ffffffffc0202646:	a79fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020264a:	0000fa97          	auipc	s5,0xf
ffffffffc020264e:	e86a8a93          	addi	s5,s5,-378 # ffffffffc02114d0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202652:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202654:	4505                	li	a0,1
ffffffffc0202656:	cf6fe0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc020265a:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea58>
          assert(check_rp[i] != NULL );
ffffffffc020265e:	2a050b63          	beqz	a0,ffffffffc0202914 <swap_init+0x428>
ffffffffc0202662:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202664:	8b89                	andi	a5,a5,2
ffffffffc0202666:	28079763          	bnez	a5,ffffffffc02028f4 <swap_init+0x408>
ffffffffc020266a:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020266c:	ff5994e3          	bne	s3,s5,ffffffffc0202654 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202670:	601c                	ld	a5,0(s0)
ffffffffc0202672:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202676:	0000fd17          	auipc	s10,0xf
ffffffffc020267a:	e3ad0d13          	addi	s10,s10,-454 # ffffffffc02114b0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020267e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202680:	481c                	lw	a5,16(s0)
ffffffffc0202682:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202684:	0000f797          	auipc	a5,0xf
ffffffffc0202688:	f087b623          	sd	s0,-244(a5) # ffffffffc0211590 <free_area+0x8>
ffffffffc020268c:	0000f797          	auipc	a5,0xf
ffffffffc0202690:	ee87be23          	sd	s0,-260(a5) # ffffffffc0211588 <free_area>
     nr_free = 0;
ffffffffc0202694:	0000f797          	auipc	a5,0xf
ffffffffc0202698:	f007a223          	sw	zero,-252(a5) # ffffffffc0211598 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020269c:	000d3503          	ld	a0,0(s10)
ffffffffc02026a0:	4585                	li	a1,1
ffffffffc02026a2:	0d21                	addi	s10,s10,8
ffffffffc02026a4:	d30fe0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02026a8:	ff5d1ae3          	bne	s10,s5,ffffffffc020269c <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02026ac:	01042d03          	lw	s10,16(s0)
ffffffffc02026b0:	4791                	li	a5,4
ffffffffc02026b2:	36fd1d63          	bne	s10,a5,ffffffffc0202a2c <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02026b6:	00003517          	auipc	a0,0x3
ffffffffc02026ba:	1fa50513          	addi	a0,a0,506 # ffffffffc02058b0 <commands+0x1440>
ffffffffc02026be:	a01fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02026c2:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02026c4:	0000f797          	auipc	a5,0xf
ffffffffc02026c8:	da07a223          	sw	zero,-604(a5) # ffffffffc0211468 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02026cc:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02026ce:	0000f797          	auipc	a5,0xf
ffffffffc02026d2:	d9a78793          	addi	a5,a5,-614 # ffffffffc0211468 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02026d6:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02026da:	4398                	lw	a4,0(a5)
ffffffffc02026dc:	4585                	li	a1,1
ffffffffc02026de:	2701                	sext.w	a4,a4
ffffffffc02026e0:	30b71663          	bne	a4,a1,ffffffffc02029ec <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02026e4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02026e8:	4394                	lw	a3,0(a5)
ffffffffc02026ea:	2681                	sext.w	a3,a3
ffffffffc02026ec:	32e69063          	bne	a3,a4,ffffffffc0202a0c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02026f0:	6689                	lui	a3,0x2
ffffffffc02026f2:	462d                	li	a2,11
ffffffffc02026f4:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02026f8:	4398                	lw	a4,0(a5)
ffffffffc02026fa:	4589                	li	a1,2
ffffffffc02026fc:	2701                	sext.w	a4,a4
ffffffffc02026fe:	26b71763          	bne	a4,a1,ffffffffc020296c <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202702:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202706:	4394                	lw	a3,0(a5)
ffffffffc0202708:	2681                	sext.w	a3,a3
ffffffffc020270a:	28e69163          	bne	a3,a4,ffffffffc020298c <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020270e:	668d                	lui	a3,0x3
ffffffffc0202710:	4631                	li	a2,12
ffffffffc0202712:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202716:	4398                	lw	a4,0(a5)
ffffffffc0202718:	458d                	li	a1,3
ffffffffc020271a:	2701                	sext.w	a4,a4
ffffffffc020271c:	28b71863          	bne	a4,a1,ffffffffc02029ac <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202720:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202724:	4394                	lw	a3,0(a5)
ffffffffc0202726:	2681                	sext.w	a3,a3
ffffffffc0202728:	2ae69263          	bne	a3,a4,ffffffffc02029cc <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020272c:	6691                	lui	a3,0x4
ffffffffc020272e:	4635                	li	a2,13
ffffffffc0202730:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202734:	4398                	lw	a4,0(a5)
ffffffffc0202736:	2701                	sext.w	a4,a4
ffffffffc0202738:	33a71a63          	bne	a4,s10,ffffffffc0202a6c <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc020273c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202740:	439c                	lw	a5,0(a5)
ffffffffc0202742:	2781                	sext.w	a5,a5
ffffffffc0202744:	34e79463          	bne	a5,a4,ffffffffc0202a8c <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202748:	481c                	lw	a5,16(s0)
ffffffffc020274a:	36079163          	bnez	a5,ffffffffc0202aac <swap_init+0x5c0>
ffffffffc020274e:	0000f797          	auipc	a5,0xf
ffffffffc0202752:	d8278793          	addi	a5,a5,-638 # ffffffffc02114d0 <swap_in_seq_no>
ffffffffc0202756:	0000f717          	auipc	a4,0xf
ffffffffc020275a:	da270713          	addi	a4,a4,-606 # ffffffffc02114f8 <swap_out_seq_no>
ffffffffc020275e:	0000f617          	auipc	a2,0xf
ffffffffc0202762:	d9a60613          	addi	a2,a2,-614 # ffffffffc02114f8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202766:	56fd                	li	a3,-1
ffffffffc0202768:	c394                	sw	a3,0(a5)
ffffffffc020276a:	c314                	sw	a3,0(a4)
ffffffffc020276c:	0791                	addi	a5,a5,4
ffffffffc020276e:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202770:	fec79ce3          	bne	a5,a2,ffffffffc0202768 <swap_init+0x27c>
ffffffffc0202774:	0000f697          	auipc	a3,0xf
ffffffffc0202778:	de468693          	addi	a3,a3,-540 # ffffffffc0211558 <check_ptep>
ffffffffc020277c:	0000f817          	auipc	a6,0xf
ffffffffc0202780:	d3480813          	addi	a6,a6,-716 # ffffffffc02114b0 <check_rp>
ffffffffc0202784:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202786:	0000fc97          	auipc	s9,0xf
ffffffffc020278a:	cdac8c93          	addi	s9,s9,-806 # ffffffffc0211460 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020278e:	0000fd97          	auipc	s11,0xf
ffffffffc0202792:	d12d8d93          	addi	s11,s11,-750 # ffffffffc02114a0 <pages>
ffffffffc0202796:	00004d17          	auipc	s10,0x4
ffffffffc020279a:	9f2d0d13          	addi	s10,s10,-1550 # ffffffffc0206188 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020279e:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc02027a0:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02027a4:	4601                	li	a2,0
ffffffffc02027a6:	85e2                	mv	a1,s8
ffffffffc02027a8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc02027aa:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02027ac:	caefe0ef          	jal	ra,ffffffffc0200c5a <get_pte>
ffffffffc02027b0:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02027b2:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02027b4:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc02027b6:	16050f63          	beqz	a0,ffffffffc0202934 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02027ba:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027bc:	0017f613          	andi	a2,a5,1
ffffffffc02027c0:	10060263          	beqz	a2,ffffffffc02028c4 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc02027c4:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027c8:	078a                	slli	a5,a5,0x2
ffffffffc02027ca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027cc:	10c7f863          	bleu	a2,a5,ffffffffc02028dc <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02027d0:	000d3603          	ld	a2,0(s10)
ffffffffc02027d4:	000db583          	ld	a1,0(s11)
ffffffffc02027d8:	00083503          	ld	a0,0(a6)
ffffffffc02027dc:	8f91                	sub	a5,a5,a2
ffffffffc02027de:	00379613          	slli	a2,a5,0x3
ffffffffc02027e2:	97b2                	add	a5,a5,a2
ffffffffc02027e4:	078e                	slli	a5,a5,0x3
ffffffffc02027e6:	97ae                	add	a5,a5,a1
ffffffffc02027e8:	0af51e63          	bne	a0,a5,ffffffffc02028a4 <swap_init+0x3b8>
ffffffffc02027ec:	6785                	lui	a5,0x1
ffffffffc02027ee:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02027f0:	6795                	lui	a5,0x5
ffffffffc02027f2:	06a1                	addi	a3,a3,8
ffffffffc02027f4:	0821                	addi	a6,a6,8
ffffffffc02027f6:	fafc14e3          	bne	s8,a5,ffffffffc020279e <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02027fa:	00003517          	auipc	a0,0x3
ffffffffc02027fe:	16e50513          	addi	a0,a0,366 # ffffffffc0205968 <commands+0x14f8>
ffffffffc0202802:	8bdfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202806:	0000f797          	auipc	a5,0xf
ffffffffc020280a:	c6a78793          	addi	a5,a5,-918 # ffffffffc0211470 <sm>
ffffffffc020280e:	639c                	ld	a5,0(a5)
ffffffffc0202810:	7f9c                	ld	a5,56(a5)
ffffffffc0202812:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202814:	2a051c63          	bnez	a0,ffffffffc0202acc <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202818:	000a3503          	ld	a0,0(s4)
ffffffffc020281c:	4585                	li	a1,1
ffffffffc020281e:	0a21                	addi	s4,s4,8
ffffffffc0202820:	bb4fe0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202824:	ff5a1ae3          	bne	s4,s5,ffffffffc0202818 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202828:	855e                	mv	a0,s7
ffffffffc020282a:	e7aff0ef          	jal	ra,ffffffffc0201ea4 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc020282e:	77a2                	ld	a5,40(sp)
ffffffffc0202830:	0000f717          	auipc	a4,0xf
ffffffffc0202834:	d6f72423          	sw	a5,-664(a4) # ffffffffc0211598 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202838:	7782                	ld	a5,32(sp)
ffffffffc020283a:	0000f717          	auipc	a4,0xf
ffffffffc020283e:	d4f73723          	sd	a5,-690(a4) # ffffffffc0211588 <free_area>
ffffffffc0202842:	0000f797          	auipc	a5,0xf
ffffffffc0202846:	d537b723          	sd	s3,-690(a5) # ffffffffc0211590 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020284a:	00898a63          	beq	s3,s0,ffffffffc020285e <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020284e:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202852:	0089b983          	ld	s3,8(s3)
ffffffffc0202856:	397d                	addiw	s2,s2,-1
ffffffffc0202858:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc020285a:	fe899ae3          	bne	s3,s0,ffffffffc020284e <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc020285e:	8626                	mv	a2,s1
ffffffffc0202860:	85ca                	mv	a1,s2
ffffffffc0202862:	00003517          	auipc	a0,0x3
ffffffffc0202866:	13650513          	addi	a0,a0,310 # ffffffffc0205998 <commands+0x1528>
ffffffffc020286a:	855fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc020286e:	00003517          	auipc	a0,0x3
ffffffffc0202872:	14a50513          	addi	a0,a0,330 # ffffffffc02059b8 <commands+0x1548>
ffffffffc0202876:	849fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020287a:	b1c9                	j	ffffffffc020253c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc020287c:	4481                	li	s1,0
ffffffffc020287e:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202880:	4981                	li	s3,0
ffffffffc0202882:	bb1d                	j	ffffffffc02025b8 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202884:	00003697          	auipc	a3,0x3
ffffffffc0202888:	ee468693          	addi	a3,a3,-284 # ffffffffc0205768 <commands+0x12f8>
ffffffffc020288c:	00002617          	auipc	a2,0x2
ffffffffc0202890:	64460613          	addi	a2,a2,1604 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202894:	0ba00593          	li	a1,186
ffffffffc0202898:	00003517          	auipc	a0,0x3
ffffffffc020289c:	ea850513          	addi	a0,a0,-344 # ffffffffc0205740 <commands+0x12d0>
ffffffffc02028a0:	867fd0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02028a4:	00003697          	auipc	a3,0x3
ffffffffc02028a8:	09c68693          	addi	a3,a3,156 # ffffffffc0205940 <commands+0x14d0>
ffffffffc02028ac:	00002617          	auipc	a2,0x2
ffffffffc02028b0:	62460613          	addi	a2,a2,1572 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02028b4:	0fa00593          	li	a1,250
ffffffffc02028b8:	00003517          	auipc	a0,0x3
ffffffffc02028bc:	e8850513          	addi	a0,a0,-376 # ffffffffc0205740 <commands+0x12d0>
ffffffffc02028c0:	847fd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02028c4:	00002617          	auipc	a2,0x2
ffffffffc02028c8:	6e460613          	addi	a2,a2,1764 # ffffffffc0204fa8 <commands+0xb38>
ffffffffc02028cc:	07000593          	li	a1,112
ffffffffc02028d0:	00002517          	auipc	a0,0x2
ffffffffc02028d4:	4e850513          	addi	a0,a0,1256 # ffffffffc0204db8 <commands+0x948>
ffffffffc02028d8:	82ffd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02028dc:	00002617          	auipc	a2,0x2
ffffffffc02028e0:	4bc60613          	addi	a2,a2,1212 # ffffffffc0204d98 <commands+0x928>
ffffffffc02028e4:	06500593          	li	a1,101
ffffffffc02028e8:	00002517          	auipc	a0,0x2
ffffffffc02028ec:	4d050513          	addi	a0,a0,1232 # ffffffffc0204db8 <commands+0x948>
ffffffffc02028f0:	817fd0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02028f4:	00003697          	auipc	a3,0x3
ffffffffc02028f8:	f7468693          	addi	a3,a3,-140 # ffffffffc0205868 <commands+0x13f8>
ffffffffc02028fc:	00002617          	auipc	a2,0x2
ffffffffc0202900:	5d460613          	addi	a2,a2,1492 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202904:	0db00593          	li	a1,219
ffffffffc0202908:	00003517          	auipc	a0,0x3
ffffffffc020290c:	e3850513          	addi	a0,a0,-456 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202910:	ff6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202914:	00003697          	auipc	a3,0x3
ffffffffc0202918:	f3c68693          	addi	a3,a3,-196 # ffffffffc0205850 <commands+0x13e0>
ffffffffc020291c:	00002617          	auipc	a2,0x2
ffffffffc0202920:	5b460613          	addi	a2,a2,1460 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202924:	0da00593          	li	a1,218
ffffffffc0202928:	00003517          	auipc	a0,0x3
ffffffffc020292c:	e1850513          	addi	a0,a0,-488 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202930:	fd6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202934:	00003697          	auipc	a3,0x3
ffffffffc0202938:	ff468693          	addi	a3,a3,-12 # ffffffffc0205928 <commands+0x14b8>
ffffffffc020293c:	00002617          	auipc	a2,0x2
ffffffffc0202940:	59460613          	addi	a2,a2,1428 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202944:	0f900593          	li	a1,249
ffffffffc0202948:	00003517          	auipc	a0,0x3
ffffffffc020294c:	df850513          	addi	a0,a0,-520 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202950:	fb6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202954:	00003617          	auipc	a2,0x3
ffffffffc0202958:	dcc60613          	addi	a2,a2,-564 # ffffffffc0205720 <commands+0x12b0>
ffffffffc020295c:	02700593          	li	a1,39
ffffffffc0202960:	00003517          	auipc	a0,0x3
ffffffffc0202964:	de050513          	addi	a0,a0,-544 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202968:	f9efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc020296c:	00003697          	auipc	a3,0x3
ffffffffc0202970:	f7c68693          	addi	a3,a3,-132 # ffffffffc02058e8 <commands+0x1478>
ffffffffc0202974:	00002617          	auipc	a2,0x2
ffffffffc0202978:	55c60613          	addi	a2,a2,1372 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020297c:	09500593          	li	a1,149
ffffffffc0202980:	00003517          	auipc	a0,0x3
ffffffffc0202984:	dc050513          	addi	a0,a0,-576 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202988:	f7efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc020298c:	00003697          	auipc	a3,0x3
ffffffffc0202990:	f5c68693          	addi	a3,a3,-164 # ffffffffc02058e8 <commands+0x1478>
ffffffffc0202994:	00002617          	auipc	a2,0x2
ffffffffc0202998:	53c60613          	addi	a2,a2,1340 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020299c:	09700593          	li	a1,151
ffffffffc02029a0:	00003517          	auipc	a0,0x3
ffffffffc02029a4:	da050513          	addi	a0,a0,-608 # ffffffffc0205740 <commands+0x12d0>
ffffffffc02029a8:	f5efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc02029ac:	00003697          	auipc	a3,0x3
ffffffffc02029b0:	f4c68693          	addi	a3,a3,-180 # ffffffffc02058f8 <commands+0x1488>
ffffffffc02029b4:	00002617          	auipc	a2,0x2
ffffffffc02029b8:	51c60613          	addi	a2,a2,1308 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02029bc:	09900593          	li	a1,153
ffffffffc02029c0:	00003517          	auipc	a0,0x3
ffffffffc02029c4:	d8050513          	addi	a0,a0,-640 # ffffffffc0205740 <commands+0x12d0>
ffffffffc02029c8:	f3efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc02029cc:	00003697          	auipc	a3,0x3
ffffffffc02029d0:	f2c68693          	addi	a3,a3,-212 # ffffffffc02058f8 <commands+0x1488>
ffffffffc02029d4:	00002617          	auipc	a2,0x2
ffffffffc02029d8:	4fc60613          	addi	a2,a2,1276 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02029dc:	09b00593          	li	a1,155
ffffffffc02029e0:	00003517          	auipc	a0,0x3
ffffffffc02029e4:	d6050513          	addi	a0,a0,-672 # ffffffffc0205740 <commands+0x12d0>
ffffffffc02029e8:	f1efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc02029ec:	00003697          	auipc	a3,0x3
ffffffffc02029f0:	eec68693          	addi	a3,a3,-276 # ffffffffc02058d8 <commands+0x1468>
ffffffffc02029f4:	00002617          	auipc	a2,0x2
ffffffffc02029f8:	4dc60613          	addi	a2,a2,1244 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02029fc:	09100593          	li	a1,145
ffffffffc0202a00:	00003517          	auipc	a0,0x3
ffffffffc0202a04:	d4050513          	addi	a0,a0,-704 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202a08:	efefd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc0202a0c:	00003697          	auipc	a3,0x3
ffffffffc0202a10:	ecc68693          	addi	a3,a3,-308 # ffffffffc02058d8 <commands+0x1468>
ffffffffc0202a14:	00002617          	auipc	a2,0x2
ffffffffc0202a18:	4bc60613          	addi	a2,a2,1212 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202a1c:	09300593          	li	a1,147
ffffffffc0202a20:	00003517          	auipc	a0,0x3
ffffffffc0202a24:	d2050513          	addi	a0,a0,-736 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202a28:	edefd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202a2c:	00003697          	auipc	a3,0x3
ffffffffc0202a30:	e5c68693          	addi	a3,a3,-420 # ffffffffc0205888 <commands+0x1418>
ffffffffc0202a34:	00002617          	auipc	a2,0x2
ffffffffc0202a38:	49c60613          	addi	a2,a2,1180 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202a3c:	0e800593          	li	a1,232
ffffffffc0202a40:	00003517          	auipc	a0,0x3
ffffffffc0202a44:	d0050513          	addi	a0,a0,-768 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202a48:	ebefd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202a4c:	00003697          	auipc	a3,0x3
ffffffffc0202a50:	dc468693          	addi	a3,a3,-572 # ffffffffc0205810 <commands+0x13a0>
ffffffffc0202a54:	00002617          	auipc	a2,0x2
ffffffffc0202a58:	47c60613          	addi	a2,a2,1148 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202a5c:	0d500593          	li	a1,213
ffffffffc0202a60:	00003517          	auipc	a0,0x3
ffffffffc0202a64:	ce050513          	addi	a0,a0,-800 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202a68:	e9efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0202a6c:	00003697          	auipc	a3,0x3
ffffffffc0202a70:	e9c68693          	addi	a3,a3,-356 # ffffffffc0205908 <commands+0x1498>
ffffffffc0202a74:	00002617          	auipc	a2,0x2
ffffffffc0202a78:	45c60613          	addi	a2,a2,1116 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202a7c:	09d00593          	li	a1,157
ffffffffc0202a80:	00003517          	auipc	a0,0x3
ffffffffc0202a84:	cc050513          	addi	a0,a0,-832 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202a88:	e7efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0202a8c:	00003697          	auipc	a3,0x3
ffffffffc0202a90:	e7c68693          	addi	a3,a3,-388 # ffffffffc0205908 <commands+0x1498>
ffffffffc0202a94:	00002617          	auipc	a2,0x2
ffffffffc0202a98:	43c60613          	addi	a2,a2,1084 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202a9c:	09f00593          	li	a1,159
ffffffffc0202aa0:	00003517          	auipc	a0,0x3
ffffffffc0202aa4:	ca050513          	addi	a0,a0,-864 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202aa8:	e5efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert( nr_free == 0);         
ffffffffc0202aac:	00003697          	auipc	a3,0x3
ffffffffc0202ab0:	e6c68693          	addi	a3,a3,-404 # ffffffffc0205918 <commands+0x14a8>
ffffffffc0202ab4:	00002617          	auipc	a2,0x2
ffffffffc0202ab8:	41c60613          	addi	a2,a2,1052 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202abc:	0f100593          	li	a1,241
ffffffffc0202ac0:	00003517          	auipc	a0,0x3
ffffffffc0202ac4:	c8050513          	addi	a0,a0,-896 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202ac8:	e3efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(ret==0);
ffffffffc0202acc:	00003697          	auipc	a3,0x3
ffffffffc0202ad0:	ec468693          	addi	a3,a3,-316 # ffffffffc0205990 <commands+0x1520>
ffffffffc0202ad4:	00002617          	auipc	a2,0x2
ffffffffc0202ad8:	3fc60613          	addi	a2,a2,1020 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202adc:	10000593          	li	a1,256
ffffffffc0202ae0:	00003517          	auipc	a0,0x3
ffffffffc0202ae4:	c6050513          	addi	a0,a0,-928 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202ae8:	e1efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(mm != NULL);
ffffffffc0202aec:	00003697          	auipc	a3,0x3
ffffffffc0202af0:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0205498 <commands+0x1028>
ffffffffc0202af4:	00002617          	auipc	a2,0x2
ffffffffc0202af8:	3dc60613          	addi	a2,a2,988 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202afc:	0c200593          	li	a1,194
ffffffffc0202b00:	00003517          	auipc	a0,0x3
ffffffffc0202b04:	c4050513          	addi	a0,a0,-960 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202b08:	dfefd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202b0c:	00003697          	auipc	a3,0x3
ffffffffc0202b10:	cb468693          	addi	a3,a3,-844 # ffffffffc02057c0 <commands+0x1350>
ffffffffc0202b14:	00002617          	auipc	a2,0x2
ffffffffc0202b18:	3bc60613          	addi	a2,a2,956 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202b1c:	0c500593          	li	a1,197
ffffffffc0202b20:	00003517          	auipc	a0,0x3
ffffffffc0202b24:	c2050513          	addi	a0,a0,-992 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202b28:	ddefd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202b2c:	00003697          	auipc	a3,0x3
ffffffffc0202b30:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0205648 <commands+0x11d8>
ffffffffc0202b34:	00002617          	auipc	a2,0x2
ffffffffc0202b38:	39c60613          	addi	a2,a2,924 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202b3c:	0ca00593          	li	a1,202
ffffffffc0202b40:	00003517          	auipc	a0,0x3
ffffffffc0202b44:	c0050513          	addi	a0,a0,-1024 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202b48:	dbefd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(vma != NULL);
ffffffffc0202b4c:	00003697          	auipc	a3,0x3
ffffffffc0202b50:	b7468693          	addi	a3,a3,-1164 # ffffffffc02056c0 <commands+0x1250>
ffffffffc0202b54:	00002617          	auipc	a2,0x2
ffffffffc0202b58:	37c60613          	addi	a2,a2,892 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202b5c:	0cd00593          	li	a1,205
ffffffffc0202b60:	00003517          	auipc	a0,0x3
ffffffffc0202b64:	be050513          	addi	a0,a0,-1056 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202b68:	d9efd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202b6c:	00003697          	auipc	a3,0x3
ffffffffc0202b70:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0205778 <commands+0x1308>
ffffffffc0202b74:	00002617          	auipc	a2,0x2
ffffffffc0202b78:	35c60613          	addi	a2,a2,860 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202b7c:	0bd00593          	li	a1,189
ffffffffc0202b80:	00003517          	auipc	a0,0x3
ffffffffc0202b84:	bc050513          	addi	a0,a0,-1088 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202b88:	d7efd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202b8c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202b8c:	0000f797          	auipc	a5,0xf
ffffffffc0202b90:	8e478793          	addi	a5,a5,-1820 # ffffffffc0211470 <sm>
ffffffffc0202b94:	639c                	ld	a5,0(a5)
ffffffffc0202b96:	0107b303          	ld	t1,16(a5)
ffffffffc0202b9a:	8302                	jr	t1

ffffffffc0202b9c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202b9c:	0000f797          	auipc	a5,0xf
ffffffffc0202ba0:	8d478793          	addi	a5,a5,-1836 # ffffffffc0211470 <sm>
ffffffffc0202ba4:	639c                	ld	a5,0(a5)
ffffffffc0202ba6:	0207b303          	ld	t1,32(a5)
ffffffffc0202baa:	8302                	jr	t1

ffffffffc0202bac <swap_out>:
{
ffffffffc0202bac:	711d                	addi	sp,sp,-96
ffffffffc0202bae:	ec86                	sd	ra,88(sp)
ffffffffc0202bb0:	e8a2                	sd	s0,80(sp)
ffffffffc0202bb2:	e4a6                	sd	s1,72(sp)
ffffffffc0202bb4:	e0ca                	sd	s2,64(sp)
ffffffffc0202bb6:	fc4e                	sd	s3,56(sp)
ffffffffc0202bb8:	f852                	sd	s4,48(sp)
ffffffffc0202bba:	f456                	sd	s5,40(sp)
ffffffffc0202bbc:	f05a                	sd	s6,32(sp)
ffffffffc0202bbe:	ec5e                	sd	s7,24(sp)
ffffffffc0202bc0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202bc2:	cde9                	beqz	a1,ffffffffc0202c9c <swap_out+0xf0>
ffffffffc0202bc4:	8ab2                	mv	s5,a2
ffffffffc0202bc6:	892a                	mv	s2,a0
ffffffffc0202bc8:	8a2e                	mv	s4,a1
ffffffffc0202bca:	4401                	li	s0,0
ffffffffc0202bcc:	0000f997          	auipc	s3,0xf
ffffffffc0202bd0:	8a498993          	addi	s3,s3,-1884 # ffffffffc0211470 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202bd4:	00003b17          	auipc	s6,0x3
ffffffffc0202bd8:	e64b0b13          	addi	s6,s6,-412 # ffffffffc0205a38 <commands+0x15c8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202bdc:	00003b97          	auipc	s7,0x3
ffffffffc0202be0:	e44b8b93          	addi	s7,s7,-444 # ffffffffc0205a20 <commands+0x15b0>
ffffffffc0202be4:	a825                	j	ffffffffc0202c1c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202be6:	67a2                	ld	a5,8(sp)
ffffffffc0202be8:	8626                	mv	a2,s1
ffffffffc0202bea:	85a2                	mv	a1,s0
ffffffffc0202bec:	63b4                	ld	a3,64(a5)
ffffffffc0202bee:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202bf0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202bf2:	82b1                	srli	a3,a3,0xc
ffffffffc0202bf4:	0685                	addi	a3,a3,1
ffffffffc0202bf6:	cc8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202bfa:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202bfc:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202bfe:	613c                	ld	a5,64(a0)
ffffffffc0202c00:	83b1                	srli	a5,a5,0xc
ffffffffc0202c02:	0785                	addi	a5,a5,1
ffffffffc0202c04:	07a2                	slli	a5,a5,0x8
ffffffffc0202c06:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202c0a:	fcbfd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202c0e:	01893503          	ld	a0,24(s2)
ffffffffc0202c12:	85a6                	mv	a1,s1
ffffffffc0202c14:	ecdfe0ef          	jal	ra,ffffffffc0201ae0 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202c18:	048a0d63          	beq	s4,s0,ffffffffc0202c72 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202c1c:	0009b783          	ld	a5,0(s3)
ffffffffc0202c20:	8656                	mv	a2,s5
ffffffffc0202c22:	002c                	addi	a1,sp,8
ffffffffc0202c24:	7b9c                	ld	a5,48(a5)
ffffffffc0202c26:	854a                	mv	a0,s2
ffffffffc0202c28:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202c2a:	e12d                	bnez	a0,ffffffffc0202c8c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202c2c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202c2e:	01893503          	ld	a0,24(s2)
ffffffffc0202c32:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202c34:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202c36:	85a6                	mv	a1,s1
ffffffffc0202c38:	822fe0ef          	jal	ra,ffffffffc0200c5a <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202c3c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202c3e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202c40:	8b85                	andi	a5,a5,1
ffffffffc0202c42:	cfb9                	beqz	a5,ffffffffc0202ca0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202c44:	65a2                	ld	a1,8(sp)
ffffffffc0202c46:	61bc                	ld	a5,64(a1)
ffffffffc0202c48:	83b1                	srli	a5,a5,0xc
ffffffffc0202c4a:	00178513          	addi	a0,a5,1
ffffffffc0202c4e:	0522                	slli	a0,a0,0x8
ffffffffc0202c50:	0ae010ef          	jal	ra,ffffffffc0203cfe <swapfs_write>
ffffffffc0202c54:	d949                	beqz	a0,ffffffffc0202be6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202c56:	855e                	mv	a0,s7
ffffffffc0202c58:	c66fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202c5c:	0009b783          	ld	a5,0(s3)
ffffffffc0202c60:	6622                	ld	a2,8(sp)
ffffffffc0202c62:	4681                	li	a3,0
ffffffffc0202c64:	739c                	ld	a5,32(a5)
ffffffffc0202c66:	85a6                	mv	a1,s1
ffffffffc0202c68:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202c6a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202c6c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202c6e:	fa8a17e3          	bne	s4,s0,ffffffffc0202c1c <swap_out+0x70>
}
ffffffffc0202c72:	8522                	mv	a0,s0
ffffffffc0202c74:	60e6                	ld	ra,88(sp)
ffffffffc0202c76:	6446                	ld	s0,80(sp)
ffffffffc0202c78:	64a6                	ld	s1,72(sp)
ffffffffc0202c7a:	6906                	ld	s2,64(sp)
ffffffffc0202c7c:	79e2                	ld	s3,56(sp)
ffffffffc0202c7e:	7a42                	ld	s4,48(sp)
ffffffffc0202c80:	7aa2                	ld	s5,40(sp)
ffffffffc0202c82:	7b02                	ld	s6,32(sp)
ffffffffc0202c84:	6be2                	ld	s7,24(sp)
ffffffffc0202c86:	6c42                	ld	s8,16(sp)
ffffffffc0202c88:	6125                	addi	sp,sp,96
ffffffffc0202c8a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202c8c:	85a2                	mv	a1,s0
ffffffffc0202c8e:	00003517          	auipc	a0,0x3
ffffffffc0202c92:	d4a50513          	addi	a0,a0,-694 # ffffffffc02059d8 <commands+0x1568>
ffffffffc0202c96:	c28fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202c9a:	bfe1                	j	ffffffffc0202c72 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202c9c:	4401                	li	s0,0
ffffffffc0202c9e:	bfd1                	j	ffffffffc0202c72 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202ca0:	00003697          	auipc	a3,0x3
ffffffffc0202ca4:	d6868693          	addi	a3,a3,-664 # ffffffffc0205a08 <commands+0x1598>
ffffffffc0202ca8:	00002617          	auipc	a2,0x2
ffffffffc0202cac:	22860613          	addi	a2,a2,552 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202cb0:	06600593          	li	a1,102
ffffffffc0202cb4:	00003517          	auipc	a0,0x3
ffffffffc0202cb8:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202cbc:	c4afd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202cc0 <swap_in>:
{
ffffffffc0202cc0:	7179                	addi	sp,sp,-48
ffffffffc0202cc2:	e84a                	sd	s2,16(sp)
ffffffffc0202cc4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202cc6:	4505                	li	a0,1
{
ffffffffc0202cc8:	ec26                	sd	s1,24(sp)
ffffffffc0202cca:	e44e                	sd	s3,8(sp)
ffffffffc0202ccc:	f406                	sd	ra,40(sp)
ffffffffc0202cce:	f022                	sd	s0,32(sp)
ffffffffc0202cd0:	84ae                	mv	s1,a1
ffffffffc0202cd2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202cd4:	e79fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
     assert(result!=NULL);
ffffffffc0202cd8:	c129                	beqz	a0,ffffffffc0202d1a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202cda:	842a                	mv	s0,a0
ffffffffc0202cdc:	01893503          	ld	a0,24(s2)
ffffffffc0202ce0:	4601                	li	a2,0
ffffffffc0202ce2:	85a6                	mv	a1,s1
ffffffffc0202ce4:	f77fd0ef          	jal	ra,ffffffffc0200c5a <get_pte>
ffffffffc0202ce8:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202cea:	6108                	ld	a0,0(a0)
ffffffffc0202cec:	85a2                	mv	a1,s0
ffffffffc0202cee:	76b000ef          	jal	ra,ffffffffc0203c58 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202cf2:	00093583          	ld	a1,0(s2)
ffffffffc0202cf6:	8626                	mv	a2,s1
ffffffffc0202cf8:	00003517          	auipc	a0,0x3
ffffffffc0202cfc:	9e850513          	addi	a0,a0,-1560 # ffffffffc02056e0 <commands+0x1270>
ffffffffc0202d00:	81a1                	srli	a1,a1,0x8
ffffffffc0202d02:	bbcfd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0202d06:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202d08:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202d0c:	7402                	ld	s0,32(sp)
ffffffffc0202d0e:	64e2                	ld	s1,24(sp)
ffffffffc0202d10:	6942                	ld	s2,16(sp)
ffffffffc0202d12:	69a2                	ld	s3,8(sp)
ffffffffc0202d14:	4501                	li	a0,0
ffffffffc0202d16:	6145                	addi	sp,sp,48
ffffffffc0202d18:	8082                	ret
     assert(result!=NULL);
ffffffffc0202d1a:	00003697          	auipc	a3,0x3
ffffffffc0202d1e:	9b668693          	addi	a3,a3,-1610 # ffffffffc02056d0 <commands+0x1260>
ffffffffc0202d22:	00002617          	auipc	a2,0x2
ffffffffc0202d26:	1ae60613          	addi	a2,a2,430 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0202d2a:	07c00593          	li	a1,124
ffffffffc0202d2e:	00003517          	auipc	a0,0x3
ffffffffc0202d32:	a1250513          	addi	a0,a0,-1518 # ffffffffc0205740 <commands+0x12d0>
ffffffffc0202d36:	bd0fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202d3a <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202d3a:	0000f797          	auipc	a5,0xf
ffffffffc0202d3e:	84e78793          	addi	a5,a5,-1970 # ffffffffc0211588 <free_area>
ffffffffc0202d42:	e79c                	sd	a5,8(a5)
ffffffffc0202d44:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202d46:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202d4a:	8082                	ret

ffffffffc0202d4c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202d4c:	0000f517          	auipc	a0,0xf
ffffffffc0202d50:	84c56503          	lwu	a0,-1972(a0) # ffffffffc0211598 <free_area+0x10>
ffffffffc0202d54:	8082                	ret

ffffffffc0202d56 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202d56:	715d                	addi	sp,sp,-80
ffffffffc0202d58:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0202d5a:	0000f917          	auipc	s2,0xf
ffffffffc0202d5e:	82e90913          	addi	s2,s2,-2002 # ffffffffc0211588 <free_area>
ffffffffc0202d62:	00893783          	ld	a5,8(s2)
ffffffffc0202d66:	e486                	sd	ra,72(sp)
ffffffffc0202d68:	e0a2                	sd	s0,64(sp)
ffffffffc0202d6a:	fc26                	sd	s1,56(sp)
ffffffffc0202d6c:	f44e                	sd	s3,40(sp)
ffffffffc0202d6e:	f052                	sd	s4,32(sp)
ffffffffc0202d70:	ec56                	sd	s5,24(sp)
ffffffffc0202d72:	e85a                	sd	s6,16(sp)
ffffffffc0202d74:	e45e                	sd	s7,8(sp)
ffffffffc0202d76:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d78:	31278f63          	beq	a5,s2,ffffffffc0203096 <default_check+0x340>
ffffffffc0202d7c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202d80:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202d82:	8b05                	andi	a4,a4,1
ffffffffc0202d84:	30070d63          	beqz	a4,ffffffffc020309e <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0202d88:	4401                	li	s0,0
ffffffffc0202d8a:	4481                	li	s1,0
ffffffffc0202d8c:	a031                	j	ffffffffc0202d98 <default_check+0x42>
ffffffffc0202d8e:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202d92:	8b09                	andi	a4,a4,2
ffffffffc0202d94:	30070563          	beqz	a4,ffffffffc020309e <default_check+0x348>
        count ++, total += p->property;
ffffffffc0202d98:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202d9c:	679c                	ld	a5,8(a5)
ffffffffc0202d9e:	2485                	addiw	s1,s1,1
ffffffffc0202da0:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202da2:	ff2796e3          	bne	a5,s2,ffffffffc0202d8e <default_check+0x38>
ffffffffc0202da6:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0202da8:	e73fd0ef          	jal	ra,ffffffffc0200c1a <nr_free_pages>
ffffffffc0202dac:	75351963          	bne	a0,s3,ffffffffc02034fe <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202db0:	4505                	li	a0,1
ffffffffc0202db2:	d9bfd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202db6:	8a2a                	mv	s4,a0
ffffffffc0202db8:	48050363          	beqz	a0,ffffffffc020323e <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202dbc:	4505                	li	a0,1
ffffffffc0202dbe:	d8ffd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202dc2:	89aa                	mv	s3,a0
ffffffffc0202dc4:	74050d63          	beqz	a0,ffffffffc020351e <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202dc8:	4505                	li	a0,1
ffffffffc0202dca:	d83fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202dce:	8aaa                	mv	s5,a0
ffffffffc0202dd0:	4e050763          	beqz	a0,ffffffffc02032be <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202dd4:	2f3a0563          	beq	s4,s3,ffffffffc02030be <default_check+0x368>
ffffffffc0202dd8:	2eaa0363          	beq	s4,a0,ffffffffc02030be <default_check+0x368>
ffffffffc0202ddc:	2ea98163          	beq	s3,a0,ffffffffc02030be <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202de0:	000a2783          	lw	a5,0(s4)
ffffffffc0202de4:	2e079d63          	bnez	a5,ffffffffc02030de <default_check+0x388>
ffffffffc0202de8:	0009a783          	lw	a5,0(s3)
ffffffffc0202dec:	2e079963          	bnez	a5,ffffffffc02030de <default_check+0x388>
ffffffffc0202df0:	411c                	lw	a5,0(a0)
ffffffffc0202df2:	2e079663          	bnez	a5,ffffffffc02030de <default_check+0x388>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202df6:	0000e797          	auipc	a5,0xe
ffffffffc0202dfa:	6aa78793          	addi	a5,a5,1706 # ffffffffc02114a0 <pages>
ffffffffc0202dfe:	639c                	ld	a5,0(a5)
ffffffffc0202e00:	00002717          	auipc	a4,0x2
ffffffffc0202e04:	f1870713          	addi	a4,a4,-232 # ffffffffc0204d18 <commands+0x8a8>
ffffffffc0202e08:	630c                	ld	a1,0(a4)
ffffffffc0202e0a:	40fa0733          	sub	a4,s4,a5
ffffffffc0202e0e:	870d                	srai	a4,a4,0x3
ffffffffc0202e10:	02b70733          	mul	a4,a4,a1
ffffffffc0202e14:	00003697          	auipc	a3,0x3
ffffffffc0202e18:	37468693          	addi	a3,a3,884 # ffffffffc0206188 <nbase>
ffffffffc0202e1c:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202e1e:	0000e697          	auipc	a3,0xe
ffffffffc0202e22:	64268693          	addi	a3,a3,1602 # ffffffffc0211460 <npage>
ffffffffc0202e26:	6294                	ld	a3,0(a3)
ffffffffc0202e28:	06b2                	slli	a3,a3,0xc
ffffffffc0202e2a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e2c:	0732                	slli	a4,a4,0xc
ffffffffc0202e2e:	2cd77863          	bleu	a3,a4,ffffffffc02030fe <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e32:	40f98733          	sub	a4,s3,a5
ffffffffc0202e36:	870d                	srai	a4,a4,0x3
ffffffffc0202e38:	02b70733          	mul	a4,a4,a1
ffffffffc0202e3c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e3e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202e40:	4ed77f63          	bleu	a3,a4,ffffffffc020333e <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e44:	40f507b3          	sub	a5,a0,a5
ffffffffc0202e48:	878d                	srai	a5,a5,0x3
ffffffffc0202e4a:	02b787b3          	mul	a5,a5,a1
ffffffffc0202e4e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e50:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202e52:	34d7f663          	bleu	a3,a5,ffffffffc020319e <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0202e56:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202e58:	00093c03          	ld	s8,0(s2)
ffffffffc0202e5c:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0202e60:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0202e64:	0000e797          	auipc	a5,0xe
ffffffffc0202e68:	7327b623          	sd	s2,1836(a5) # ffffffffc0211590 <free_area+0x8>
ffffffffc0202e6c:	0000e797          	auipc	a5,0xe
ffffffffc0202e70:	7127be23          	sd	s2,1820(a5) # ffffffffc0211588 <free_area>
    nr_free = 0;
ffffffffc0202e74:	0000e797          	auipc	a5,0xe
ffffffffc0202e78:	7207a223          	sw	zero,1828(a5) # ffffffffc0211598 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202e7c:	cd1fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202e80:	2e051f63          	bnez	a0,ffffffffc020317e <default_check+0x428>
    free_page(p0);
ffffffffc0202e84:	4585                	li	a1,1
ffffffffc0202e86:	8552                	mv	a0,s4
ffffffffc0202e88:	d4dfd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    free_page(p1);
ffffffffc0202e8c:	4585                	li	a1,1
ffffffffc0202e8e:	854e                	mv	a0,s3
ffffffffc0202e90:	d45fd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    free_page(p2);
ffffffffc0202e94:	4585                	li	a1,1
ffffffffc0202e96:	8556                	mv	a0,s5
ffffffffc0202e98:	d3dfd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    assert(nr_free == 3);
ffffffffc0202e9c:	01092703          	lw	a4,16(s2)
ffffffffc0202ea0:	478d                	li	a5,3
ffffffffc0202ea2:	2af71e63          	bne	a4,a5,ffffffffc020315e <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202ea6:	4505                	li	a0,1
ffffffffc0202ea8:	ca5fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202eac:	89aa                	mv	s3,a0
ffffffffc0202eae:	28050863          	beqz	a0,ffffffffc020313e <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202eb2:	4505                	li	a0,1
ffffffffc0202eb4:	c99fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202eb8:	8aaa                	mv	s5,a0
ffffffffc0202eba:	3e050263          	beqz	a0,ffffffffc020329e <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202ebe:	4505                	li	a0,1
ffffffffc0202ec0:	c8dfd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202ec4:	8a2a                	mv	s4,a0
ffffffffc0202ec6:	3a050c63          	beqz	a0,ffffffffc020327e <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0202eca:	4505                	li	a0,1
ffffffffc0202ecc:	c81fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202ed0:	38051763          	bnez	a0,ffffffffc020325e <default_check+0x508>
    free_page(p0);
ffffffffc0202ed4:	4585                	li	a1,1
ffffffffc0202ed6:	854e                	mv	a0,s3
ffffffffc0202ed8:	cfdfd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202edc:	00893783          	ld	a5,8(s2)
ffffffffc0202ee0:	23278f63          	beq	a5,s2,ffffffffc020311e <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0202ee4:	4505                	li	a0,1
ffffffffc0202ee6:	c67fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202eea:	32a99a63          	bne	s3,a0,ffffffffc020321e <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0202eee:	4505                	li	a0,1
ffffffffc0202ef0:	c5dfd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202ef4:	30051563          	bnez	a0,ffffffffc02031fe <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0202ef8:	01092783          	lw	a5,16(s2)
ffffffffc0202efc:	2e079163          	bnez	a5,ffffffffc02031de <default_check+0x488>
    free_page(p);
ffffffffc0202f00:	854e                	mv	a0,s3
ffffffffc0202f02:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202f04:	0000e797          	auipc	a5,0xe
ffffffffc0202f08:	6987b223          	sd	s8,1668(a5) # ffffffffc0211588 <free_area>
ffffffffc0202f0c:	0000e797          	auipc	a5,0xe
ffffffffc0202f10:	6977b223          	sd	s7,1668(a5) # ffffffffc0211590 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0202f14:	0000e797          	auipc	a5,0xe
ffffffffc0202f18:	6967a223          	sw	s6,1668(a5) # ffffffffc0211598 <free_area+0x10>
    free_page(p);
ffffffffc0202f1c:	cb9fd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    free_page(p1);
ffffffffc0202f20:	4585                	li	a1,1
ffffffffc0202f22:	8556                	mv	a0,s5
ffffffffc0202f24:	cb1fd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    free_page(p2);
ffffffffc0202f28:	4585                	li	a1,1
ffffffffc0202f2a:	8552                	mv	a0,s4
ffffffffc0202f2c:	ca9fd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202f30:	4515                	li	a0,5
ffffffffc0202f32:	c1bfd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202f36:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202f38:	28050363          	beqz	a0,ffffffffc02031be <default_check+0x468>
ffffffffc0202f3c:	651c                	ld	a5,8(a0)
ffffffffc0202f3e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202f40:	8b85                	andi	a5,a5,1
ffffffffc0202f42:	54079e63          	bnez	a5,ffffffffc020349e <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202f46:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202f48:	00093b03          	ld	s6,0(s2)
ffffffffc0202f4c:	00893a83          	ld	s5,8(s2)
ffffffffc0202f50:	0000e797          	auipc	a5,0xe
ffffffffc0202f54:	6327bc23          	sd	s2,1592(a5) # ffffffffc0211588 <free_area>
ffffffffc0202f58:	0000e797          	auipc	a5,0xe
ffffffffc0202f5c:	6327bc23          	sd	s2,1592(a5) # ffffffffc0211590 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0202f60:	bedfd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202f64:	50051d63          	bnez	a0,ffffffffc020347e <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202f68:	09098a13          	addi	s4,s3,144
ffffffffc0202f6c:	8552                	mv	a0,s4
ffffffffc0202f6e:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202f70:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0202f74:	0000e797          	auipc	a5,0xe
ffffffffc0202f78:	6207a223          	sw	zero,1572(a5) # ffffffffc0211598 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202f7c:	c59fd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202f80:	4511                	li	a0,4
ffffffffc0202f82:	bcbfd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202f86:	4c051c63          	bnez	a0,ffffffffc020345e <default_check+0x708>
ffffffffc0202f8a:	0989b783          	ld	a5,152(s3)
ffffffffc0202f8e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202f90:	8b85                	andi	a5,a5,1
ffffffffc0202f92:	4a078663          	beqz	a5,ffffffffc020343e <default_check+0x6e8>
ffffffffc0202f96:	0a89a703          	lw	a4,168(s3)
ffffffffc0202f9a:	478d                	li	a5,3
ffffffffc0202f9c:	4af71163          	bne	a4,a5,ffffffffc020343e <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202fa0:	450d                	li	a0,3
ffffffffc0202fa2:	babfd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202fa6:	8c2a                	mv	s8,a0
ffffffffc0202fa8:	46050b63          	beqz	a0,ffffffffc020341e <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0202fac:	4505                	li	a0,1
ffffffffc0202fae:	b9ffd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0202fb2:	44051663          	bnez	a0,ffffffffc02033fe <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0202fb6:	438a1463          	bne	s4,s8,ffffffffc02033de <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202fba:	4585                	li	a1,1
ffffffffc0202fbc:	854e                	mv	a0,s3
ffffffffc0202fbe:	c17fd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    free_pages(p1, 3);
ffffffffc0202fc2:	458d                	li	a1,3
ffffffffc0202fc4:	8552                	mv	a0,s4
ffffffffc0202fc6:	c0ffd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
ffffffffc0202fca:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202fce:	04898c13          	addi	s8,s3,72
ffffffffc0202fd2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202fd4:	8b85                	andi	a5,a5,1
ffffffffc0202fd6:	3e078463          	beqz	a5,ffffffffc02033be <default_check+0x668>
ffffffffc0202fda:	0189a703          	lw	a4,24(s3)
ffffffffc0202fde:	4785                	li	a5,1
ffffffffc0202fe0:	3cf71f63          	bne	a4,a5,ffffffffc02033be <default_check+0x668>
ffffffffc0202fe4:	008a3783          	ld	a5,8(s4)
ffffffffc0202fe8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202fea:	8b85                	andi	a5,a5,1
ffffffffc0202fec:	3a078963          	beqz	a5,ffffffffc020339e <default_check+0x648>
ffffffffc0202ff0:	018a2703          	lw	a4,24(s4)
ffffffffc0202ff4:	478d                	li	a5,3
ffffffffc0202ff6:	3af71463          	bne	a4,a5,ffffffffc020339e <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202ffa:	4505                	li	a0,1
ffffffffc0202ffc:	b51fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0203000:	36a99f63          	bne	s3,a0,ffffffffc020337e <default_check+0x628>
    free_page(p0);
ffffffffc0203004:	4585                	li	a1,1
ffffffffc0203006:	bcffd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020300a:	4509                	li	a0,2
ffffffffc020300c:	b41fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0203010:	34aa1763          	bne	s4,a0,ffffffffc020335e <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0203014:	4589                	li	a1,2
ffffffffc0203016:	bbffd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    free_page(p2);
ffffffffc020301a:	4585                	li	a1,1
ffffffffc020301c:	8562                	mv	a0,s8
ffffffffc020301e:	bb7fd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203022:	4515                	li	a0,5
ffffffffc0203024:	b29fd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0203028:	89aa                	mv	s3,a0
ffffffffc020302a:	48050a63          	beqz	a0,ffffffffc02034be <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc020302e:	4505                	li	a0,1
ffffffffc0203030:	b1dfd0ef          	jal	ra,ffffffffc0200b4c <alloc_pages>
ffffffffc0203034:	2e051563          	bnez	a0,ffffffffc020331e <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0203038:	01092783          	lw	a5,16(s2)
ffffffffc020303c:	2c079163          	bnez	a5,ffffffffc02032fe <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0203040:	4595                	li	a1,5
ffffffffc0203042:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0203044:	0000e797          	auipc	a5,0xe
ffffffffc0203048:	5577aa23          	sw	s7,1364(a5) # ffffffffc0211598 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020304c:	0000e797          	auipc	a5,0xe
ffffffffc0203050:	5367be23          	sd	s6,1340(a5) # ffffffffc0211588 <free_area>
ffffffffc0203054:	0000e797          	auipc	a5,0xe
ffffffffc0203058:	5357be23          	sd	s5,1340(a5) # ffffffffc0211590 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc020305c:	b79fd0ef          	jal	ra,ffffffffc0200bd4 <free_pages>
    return listelm->next;
ffffffffc0203060:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203064:	01278963          	beq	a5,s2,ffffffffc0203076 <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0203068:	ff87a703          	lw	a4,-8(a5)
ffffffffc020306c:	679c                	ld	a5,8(a5)
ffffffffc020306e:	34fd                	addiw	s1,s1,-1
ffffffffc0203070:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203072:	ff279be3          	bne	a5,s2,ffffffffc0203068 <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0203076:	26049463          	bnez	s1,ffffffffc02032de <default_check+0x588>
    assert(total == 0);
ffffffffc020307a:	46041263          	bnez	s0,ffffffffc02034de <default_check+0x788>
}
ffffffffc020307e:	60a6                	ld	ra,72(sp)
ffffffffc0203080:	6406                	ld	s0,64(sp)
ffffffffc0203082:	74e2                	ld	s1,56(sp)
ffffffffc0203084:	7942                	ld	s2,48(sp)
ffffffffc0203086:	79a2                	ld	s3,40(sp)
ffffffffc0203088:	7a02                	ld	s4,32(sp)
ffffffffc020308a:	6ae2                	ld	s5,24(sp)
ffffffffc020308c:	6b42                	ld	s6,16(sp)
ffffffffc020308e:	6ba2                	ld	s7,8(sp)
ffffffffc0203090:	6c02                	ld	s8,0(sp)
ffffffffc0203092:	6161                	addi	sp,sp,80
ffffffffc0203094:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203096:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0203098:	4401                	li	s0,0
ffffffffc020309a:	4481                	li	s1,0
ffffffffc020309c:	b331                	j	ffffffffc0202da8 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc020309e:	00002697          	auipc	a3,0x2
ffffffffc02030a2:	6ca68693          	addi	a3,a3,1738 # ffffffffc0205768 <commands+0x12f8>
ffffffffc02030a6:	00002617          	auipc	a2,0x2
ffffffffc02030aa:	e2a60613          	addi	a2,a2,-470 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02030ae:	0f000593          	li	a1,240
ffffffffc02030b2:	00003517          	auipc	a0,0x3
ffffffffc02030b6:	9c650513          	addi	a0,a0,-1594 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02030ba:	84cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02030be:	00003697          	auipc	a3,0x3
ffffffffc02030c2:	a3268693          	addi	a3,a3,-1486 # ffffffffc0205af0 <commands+0x1680>
ffffffffc02030c6:	00002617          	auipc	a2,0x2
ffffffffc02030ca:	e0a60613          	addi	a2,a2,-502 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02030ce:	0bd00593          	li	a1,189
ffffffffc02030d2:	00003517          	auipc	a0,0x3
ffffffffc02030d6:	9a650513          	addi	a0,a0,-1626 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02030da:	82cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02030de:	00003697          	auipc	a3,0x3
ffffffffc02030e2:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0205b18 <commands+0x16a8>
ffffffffc02030e6:	00002617          	auipc	a2,0x2
ffffffffc02030ea:	dea60613          	addi	a2,a2,-534 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02030ee:	0be00593          	li	a1,190
ffffffffc02030f2:	00003517          	auipc	a0,0x3
ffffffffc02030f6:	98650513          	addi	a0,a0,-1658 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02030fa:	80cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02030fe:	00003697          	auipc	a3,0x3
ffffffffc0203102:	a5a68693          	addi	a3,a3,-1446 # ffffffffc0205b58 <commands+0x16e8>
ffffffffc0203106:	00002617          	auipc	a2,0x2
ffffffffc020310a:	dca60613          	addi	a2,a2,-566 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020310e:	0c000593          	li	a1,192
ffffffffc0203112:	00003517          	auipc	a0,0x3
ffffffffc0203116:	96650513          	addi	a0,a0,-1690 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020311a:	fedfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020311e:	00003697          	auipc	a3,0x3
ffffffffc0203122:	ac268693          	addi	a3,a3,-1342 # ffffffffc0205be0 <commands+0x1770>
ffffffffc0203126:	00002617          	auipc	a2,0x2
ffffffffc020312a:	daa60613          	addi	a2,a2,-598 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020312e:	0d900593          	li	a1,217
ffffffffc0203132:	00003517          	auipc	a0,0x3
ffffffffc0203136:	94650513          	addi	a0,a0,-1722 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020313a:	fcdfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020313e:	00003697          	auipc	a3,0x3
ffffffffc0203142:	95268693          	addi	a3,a3,-1710 # ffffffffc0205a90 <commands+0x1620>
ffffffffc0203146:	00002617          	auipc	a2,0x2
ffffffffc020314a:	d8a60613          	addi	a2,a2,-630 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020314e:	0d200593          	li	a1,210
ffffffffc0203152:	00003517          	auipc	a0,0x3
ffffffffc0203156:	92650513          	addi	a0,a0,-1754 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020315a:	fadfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 3);
ffffffffc020315e:	00003697          	auipc	a3,0x3
ffffffffc0203162:	a7268693          	addi	a3,a3,-1422 # ffffffffc0205bd0 <commands+0x1760>
ffffffffc0203166:	00002617          	auipc	a2,0x2
ffffffffc020316a:	d6a60613          	addi	a2,a2,-662 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020316e:	0d000593          	li	a1,208
ffffffffc0203172:	00003517          	auipc	a0,0x3
ffffffffc0203176:	90650513          	addi	a0,a0,-1786 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020317a:	f8dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020317e:	00003697          	auipc	a3,0x3
ffffffffc0203182:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0205bb8 <commands+0x1748>
ffffffffc0203186:	00002617          	auipc	a2,0x2
ffffffffc020318a:	d4a60613          	addi	a2,a2,-694 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020318e:	0cb00593          	li	a1,203
ffffffffc0203192:	00003517          	auipc	a0,0x3
ffffffffc0203196:	8e650513          	addi	a0,a0,-1818 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020319a:	f6dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020319e:	00003697          	auipc	a3,0x3
ffffffffc02031a2:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0205b98 <commands+0x1728>
ffffffffc02031a6:	00002617          	auipc	a2,0x2
ffffffffc02031aa:	d2a60613          	addi	a2,a2,-726 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02031ae:	0c200593          	li	a1,194
ffffffffc02031b2:	00003517          	auipc	a0,0x3
ffffffffc02031b6:	8c650513          	addi	a0,a0,-1850 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02031ba:	f4dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != NULL);
ffffffffc02031be:	00003697          	auipc	a3,0x3
ffffffffc02031c2:	a5a68693          	addi	a3,a3,-1446 # ffffffffc0205c18 <commands+0x17a8>
ffffffffc02031c6:	00002617          	auipc	a2,0x2
ffffffffc02031ca:	d0a60613          	addi	a2,a2,-758 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02031ce:	0f800593          	li	a1,248
ffffffffc02031d2:	00003517          	auipc	a0,0x3
ffffffffc02031d6:	8a650513          	addi	a0,a0,-1882 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02031da:	f2dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc02031de:	00002697          	auipc	a3,0x2
ffffffffc02031e2:	73a68693          	addi	a3,a3,1850 # ffffffffc0205918 <commands+0x14a8>
ffffffffc02031e6:	00002617          	auipc	a2,0x2
ffffffffc02031ea:	cea60613          	addi	a2,a2,-790 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02031ee:	0df00593          	li	a1,223
ffffffffc02031f2:	00003517          	auipc	a0,0x3
ffffffffc02031f6:	88650513          	addi	a0,a0,-1914 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02031fa:	f0dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02031fe:	00003697          	auipc	a3,0x3
ffffffffc0203202:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0205bb8 <commands+0x1748>
ffffffffc0203206:	00002617          	auipc	a2,0x2
ffffffffc020320a:	cca60613          	addi	a2,a2,-822 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020320e:	0dd00593          	li	a1,221
ffffffffc0203212:	00003517          	auipc	a0,0x3
ffffffffc0203216:	86650513          	addi	a0,a0,-1946 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020321a:	eedfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020321e:	00003697          	auipc	a3,0x3
ffffffffc0203222:	9da68693          	addi	a3,a3,-1574 # ffffffffc0205bf8 <commands+0x1788>
ffffffffc0203226:	00002617          	auipc	a2,0x2
ffffffffc020322a:	caa60613          	addi	a2,a2,-854 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020322e:	0dc00593          	li	a1,220
ffffffffc0203232:	00003517          	auipc	a0,0x3
ffffffffc0203236:	84650513          	addi	a0,a0,-1978 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020323a:	ecdfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020323e:	00003697          	auipc	a3,0x3
ffffffffc0203242:	85268693          	addi	a3,a3,-1966 # ffffffffc0205a90 <commands+0x1620>
ffffffffc0203246:	00002617          	auipc	a2,0x2
ffffffffc020324a:	c8a60613          	addi	a2,a2,-886 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020324e:	0b900593          	li	a1,185
ffffffffc0203252:	00003517          	auipc	a0,0x3
ffffffffc0203256:	82650513          	addi	a0,a0,-2010 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020325a:	eadfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020325e:	00003697          	auipc	a3,0x3
ffffffffc0203262:	95a68693          	addi	a3,a3,-1702 # ffffffffc0205bb8 <commands+0x1748>
ffffffffc0203266:	00002617          	auipc	a2,0x2
ffffffffc020326a:	c6a60613          	addi	a2,a2,-918 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020326e:	0d600593          	li	a1,214
ffffffffc0203272:	00003517          	auipc	a0,0x3
ffffffffc0203276:	80650513          	addi	a0,a0,-2042 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020327a:	e8dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020327e:	00003697          	auipc	a3,0x3
ffffffffc0203282:	85268693          	addi	a3,a3,-1966 # ffffffffc0205ad0 <commands+0x1660>
ffffffffc0203286:	00002617          	auipc	a2,0x2
ffffffffc020328a:	c4a60613          	addi	a2,a2,-950 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020328e:	0d400593          	li	a1,212
ffffffffc0203292:	00002517          	auipc	a0,0x2
ffffffffc0203296:	7e650513          	addi	a0,a0,2022 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020329a:	e6dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020329e:	00003697          	auipc	a3,0x3
ffffffffc02032a2:	81268693          	addi	a3,a3,-2030 # ffffffffc0205ab0 <commands+0x1640>
ffffffffc02032a6:	00002617          	auipc	a2,0x2
ffffffffc02032aa:	c2a60613          	addi	a2,a2,-982 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02032ae:	0d300593          	li	a1,211
ffffffffc02032b2:	00002517          	auipc	a0,0x2
ffffffffc02032b6:	7c650513          	addi	a0,a0,1990 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02032ba:	e4dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02032be:	00003697          	auipc	a3,0x3
ffffffffc02032c2:	81268693          	addi	a3,a3,-2030 # ffffffffc0205ad0 <commands+0x1660>
ffffffffc02032c6:	00002617          	auipc	a2,0x2
ffffffffc02032ca:	c0a60613          	addi	a2,a2,-1014 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02032ce:	0bb00593          	li	a1,187
ffffffffc02032d2:	00002517          	auipc	a0,0x2
ffffffffc02032d6:	7a650513          	addi	a0,a0,1958 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02032da:	e2dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(count == 0);
ffffffffc02032de:	00003697          	auipc	a3,0x3
ffffffffc02032e2:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0205d68 <commands+0x18f8>
ffffffffc02032e6:	00002617          	auipc	a2,0x2
ffffffffc02032ea:	bea60613          	addi	a2,a2,-1046 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02032ee:	12500593          	li	a1,293
ffffffffc02032f2:	00002517          	auipc	a0,0x2
ffffffffc02032f6:	78650513          	addi	a0,a0,1926 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02032fa:	e0dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc02032fe:	00002697          	auipc	a3,0x2
ffffffffc0203302:	61a68693          	addi	a3,a3,1562 # ffffffffc0205918 <commands+0x14a8>
ffffffffc0203306:	00002617          	auipc	a2,0x2
ffffffffc020330a:	bca60613          	addi	a2,a2,-1078 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020330e:	11a00593          	li	a1,282
ffffffffc0203312:	00002517          	auipc	a0,0x2
ffffffffc0203316:	76650513          	addi	a0,a0,1894 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020331a:	dedfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020331e:	00003697          	auipc	a3,0x3
ffffffffc0203322:	89a68693          	addi	a3,a3,-1894 # ffffffffc0205bb8 <commands+0x1748>
ffffffffc0203326:	00002617          	auipc	a2,0x2
ffffffffc020332a:	baa60613          	addi	a2,a2,-1110 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020332e:	11800593          	li	a1,280
ffffffffc0203332:	00002517          	auipc	a0,0x2
ffffffffc0203336:	74650513          	addi	a0,a0,1862 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020333a:	dcdfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020333e:	00003697          	auipc	a3,0x3
ffffffffc0203342:	83a68693          	addi	a3,a3,-1990 # ffffffffc0205b78 <commands+0x1708>
ffffffffc0203346:	00002617          	auipc	a2,0x2
ffffffffc020334a:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020334e:	0c100593          	li	a1,193
ffffffffc0203352:	00002517          	auipc	a0,0x2
ffffffffc0203356:	72650513          	addi	a0,a0,1830 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020335a:	dadfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020335e:	00003697          	auipc	a3,0x3
ffffffffc0203362:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0205d28 <commands+0x18b8>
ffffffffc0203366:	00002617          	auipc	a2,0x2
ffffffffc020336a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020336e:	11200593          	li	a1,274
ffffffffc0203372:	00002517          	auipc	a0,0x2
ffffffffc0203376:	70650513          	addi	a0,a0,1798 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020337a:	d8dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020337e:	00003697          	auipc	a3,0x3
ffffffffc0203382:	98a68693          	addi	a3,a3,-1654 # ffffffffc0205d08 <commands+0x1898>
ffffffffc0203386:	00002617          	auipc	a2,0x2
ffffffffc020338a:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020338e:	11000593          	li	a1,272
ffffffffc0203392:	00002517          	auipc	a0,0x2
ffffffffc0203396:	6e650513          	addi	a0,a0,1766 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020339a:	d6dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020339e:	00003697          	auipc	a3,0x3
ffffffffc02033a2:	94268693          	addi	a3,a3,-1726 # ffffffffc0205ce0 <commands+0x1870>
ffffffffc02033a6:	00002617          	auipc	a2,0x2
ffffffffc02033aa:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02033ae:	10e00593          	li	a1,270
ffffffffc02033b2:	00002517          	auipc	a0,0x2
ffffffffc02033b6:	6c650513          	addi	a0,a0,1734 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02033ba:	d4dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02033be:	00003697          	auipc	a3,0x3
ffffffffc02033c2:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0205cb8 <commands+0x1848>
ffffffffc02033c6:	00002617          	auipc	a2,0x2
ffffffffc02033ca:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02033ce:	10d00593          	li	a1,269
ffffffffc02033d2:	00002517          	auipc	a0,0x2
ffffffffc02033d6:	6a650513          	addi	a0,a0,1702 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02033da:	d2dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02033de:	00003697          	auipc	a3,0x3
ffffffffc02033e2:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0205ca8 <commands+0x1838>
ffffffffc02033e6:	00002617          	auipc	a2,0x2
ffffffffc02033ea:	aea60613          	addi	a2,a2,-1302 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02033ee:	10800593          	li	a1,264
ffffffffc02033f2:	00002517          	auipc	a0,0x2
ffffffffc02033f6:	68650513          	addi	a0,a0,1670 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02033fa:	d0dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02033fe:	00002697          	auipc	a3,0x2
ffffffffc0203402:	7ba68693          	addi	a3,a3,1978 # ffffffffc0205bb8 <commands+0x1748>
ffffffffc0203406:	00002617          	auipc	a2,0x2
ffffffffc020340a:	aca60613          	addi	a2,a2,-1334 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020340e:	10700593          	li	a1,263
ffffffffc0203412:	00002517          	auipc	a0,0x2
ffffffffc0203416:	66650513          	addi	a0,a0,1638 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020341a:	cedfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020341e:	00003697          	auipc	a3,0x3
ffffffffc0203422:	86a68693          	addi	a3,a3,-1942 # ffffffffc0205c88 <commands+0x1818>
ffffffffc0203426:	00002617          	auipc	a2,0x2
ffffffffc020342a:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020342e:	10600593          	li	a1,262
ffffffffc0203432:	00002517          	auipc	a0,0x2
ffffffffc0203436:	64650513          	addi	a0,a0,1606 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020343a:	ccdfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020343e:	00003697          	auipc	a3,0x3
ffffffffc0203442:	81a68693          	addi	a3,a3,-2022 # ffffffffc0205c58 <commands+0x17e8>
ffffffffc0203446:	00002617          	auipc	a2,0x2
ffffffffc020344a:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020344e:	10500593          	li	a1,261
ffffffffc0203452:	00002517          	auipc	a0,0x2
ffffffffc0203456:	62650513          	addi	a0,a0,1574 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020345a:	cadfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020345e:	00002697          	auipc	a3,0x2
ffffffffc0203462:	7e268693          	addi	a3,a3,2018 # ffffffffc0205c40 <commands+0x17d0>
ffffffffc0203466:	00002617          	auipc	a2,0x2
ffffffffc020346a:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020346e:	10400593          	li	a1,260
ffffffffc0203472:	00002517          	auipc	a0,0x2
ffffffffc0203476:	60650513          	addi	a0,a0,1542 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020347a:	c8dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020347e:	00002697          	auipc	a3,0x2
ffffffffc0203482:	73a68693          	addi	a3,a3,1850 # ffffffffc0205bb8 <commands+0x1748>
ffffffffc0203486:	00002617          	auipc	a2,0x2
ffffffffc020348a:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020348e:	0fe00593          	li	a1,254
ffffffffc0203492:	00002517          	auipc	a0,0x2
ffffffffc0203496:	5e650513          	addi	a0,a0,1510 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020349a:	c6dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!PageProperty(p0));
ffffffffc020349e:	00002697          	auipc	a3,0x2
ffffffffc02034a2:	78a68693          	addi	a3,a3,1930 # ffffffffc0205c28 <commands+0x17b8>
ffffffffc02034a6:	00002617          	auipc	a2,0x2
ffffffffc02034aa:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02034ae:	0f900593          	li	a1,249
ffffffffc02034b2:	00002517          	auipc	a0,0x2
ffffffffc02034b6:	5c650513          	addi	a0,a0,1478 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02034ba:	c4dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02034be:	00003697          	auipc	a3,0x3
ffffffffc02034c2:	88a68693          	addi	a3,a3,-1910 # ffffffffc0205d48 <commands+0x18d8>
ffffffffc02034c6:	00002617          	auipc	a2,0x2
ffffffffc02034ca:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02034ce:	11700593          	li	a1,279
ffffffffc02034d2:	00002517          	auipc	a0,0x2
ffffffffc02034d6:	5a650513          	addi	a0,a0,1446 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02034da:	c2dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == 0);
ffffffffc02034de:	00003697          	auipc	a3,0x3
ffffffffc02034e2:	89a68693          	addi	a3,a3,-1894 # ffffffffc0205d78 <commands+0x1908>
ffffffffc02034e6:	00002617          	auipc	a2,0x2
ffffffffc02034ea:	9ea60613          	addi	a2,a2,-1558 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02034ee:	12600593          	li	a1,294
ffffffffc02034f2:	00002517          	auipc	a0,0x2
ffffffffc02034f6:	58650513          	addi	a0,a0,1414 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02034fa:	c0dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == nr_free_pages());
ffffffffc02034fe:	00002697          	auipc	a3,0x2
ffffffffc0203502:	27a68693          	addi	a3,a3,634 # ffffffffc0205778 <commands+0x1308>
ffffffffc0203506:	00002617          	auipc	a2,0x2
ffffffffc020350a:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020350e:	0f300593          	li	a1,243
ffffffffc0203512:	00002517          	auipc	a0,0x2
ffffffffc0203516:	56650513          	addi	a0,a0,1382 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020351a:	bedfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020351e:	00002697          	auipc	a3,0x2
ffffffffc0203522:	59268693          	addi	a3,a3,1426 # ffffffffc0205ab0 <commands+0x1640>
ffffffffc0203526:	00002617          	auipc	a2,0x2
ffffffffc020352a:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020352e:	0ba00593          	li	a1,186
ffffffffc0203532:	00002517          	auipc	a0,0x2
ffffffffc0203536:	54650513          	addi	a0,a0,1350 # ffffffffc0205a78 <commands+0x1608>
ffffffffc020353a:	bcdfc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc020353e <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020353e:	1141                	addi	sp,sp,-16
ffffffffc0203540:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203542:	18058063          	beqz	a1,ffffffffc02036c2 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0203546:	00359693          	slli	a3,a1,0x3
ffffffffc020354a:	96ae                	add	a3,a3,a1
ffffffffc020354c:	068e                	slli	a3,a3,0x3
ffffffffc020354e:	96aa                	add	a3,a3,a0
ffffffffc0203550:	02d50d63          	beq	a0,a3,ffffffffc020358a <default_free_pages+0x4c>
ffffffffc0203554:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203556:	8b85                	andi	a5,a5,1
ffffffffc0203558:	14079563          	bnez	a5,ffffffffc02036a2 <default_free_pages+0x164>
ffffffffc020355c:	651c                	ld	a5,8(a0)
ffffffffc020355e:	8385                	srli	a5,a5,0x1
ffffffffc0203560:	8b85                	andi	a5,a5,1
ffffffffc0203562:	14079063          	bnez	a5,ffffffffc02036a2 <default_free_pages+0x164>
ffffffffc0203566:	87aa                	mv	a5,a0
ffffffffc0203568:	a809                	j	ffffffffc020357a <default_free_pages+0x3c>
ffffffffc020356a:	6798                	ld	a4,8(a5)
ffffffffc020356c:	8b05                	andi	a4,a4,1
ffffffffc020356e:	12071a63          	bnez	a4,ffffffffc02036a2 <default_free_pages+0x164>
ffffffffc0203572:	6798                	ld	a4,8(a5)
ffffffffc0203574:	8b09                	andi	a4,a4,2
ffffffffc0203576:	12071663          	bnez	a4,ffffffffc02036a2 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc020357a:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020357e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203582:	04878793          	addi	a5,a5,72
ffffffffc0203586:	fed792e3          	bne	a5,a3,ffffffffc020356a <default_free_pages+0x2c>
    base->property = n;
ffffffffc020358a:	2581                	sext.w	a1,a1
ffffffffc020358c:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc020358e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203592:	4789                	li	a5,2
ffffffffc0203594:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203598:	0000e697          	auipc	a3,0xe
ffffffffc020359c:	ff068693          	addi	a3,a3,-16 # ffffffffc0211588 <free_area>
ffffffffc02035a0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02035a2:	669c                	ld	a5,8(a3)
ffffffffc02035a4:	9db9                	addw	a1,a1,a4
ffffffffc02035a6:	0000e717          	auipc	a4,0xe
ffffffffc02035aa:	feb72923          	sw	a1,-14(a4) # ffffffffc0211598 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02035ae:	08d78f63          	beq	a5,a3,ffffffffc020364c <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02035b2:	fe078713          	addi	a4,a5,-32
ffffffffc02035b6:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02035b8:	4801                	li	a6,0
ffffffffc02035ba:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02035be:	00e56a63          	bltu	a0,a4,ffffffffc02035d2 <default_free_pages+0x94>
    return listelm->next;
ffffffffc02035c2:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02035c4:	02d70563          	beq	a4,a3,ffffffffc02035ee <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02035c8:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02035ca:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02035ce:	fee57ae3          	bleu	a4,a0,ffffffffc02035c2 <default_free_pages+0x84>
ffffffffc02035d2:	00080663          	beqz	a6,ffffffffc02035de <default_free_pages+0xa0>
ffffffffc02035d6:	0000e817          	auipc	a6,0xe
ffffffffc02035da:	fab83923          	sd	a1,-78(a6) # ffffffffc0211588 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02035de:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02035e0:	e390                	sd	a2,0(a5)
ffffffffc02035e2:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02035e4:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02035e6:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02035e8:	02d59163          	bne	a1,a3,ffffffffc020360a <default_free_pages+0xcc>
ffffffffc02035ec:	a091                	j	ffffffffc0203630 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02035ee:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02035f0:	f514                	sd	a3,40(a0)
ffffffffc02035f2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02035f4:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02035f6:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02035f8:	00d70563          	beq	a4,a3,ffffffffc0203602 <default_free_pages+0xc4>
ffffffffc02035fc:	4805                	li	a6,1
ffffffffc02035fe:	87ba                	mv	a5,a4
ffffffffc0203600:	b7e9                	j	ffffffffc02035ca <default_free_pages+0x8c>
ffffffffc0203602:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0203604:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0203606:	02d78163          	beq	a5,a3,ffffffffc0203628 <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc020360a:	ff85a803          	lw	a6,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc020360e:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0203612:	02081713          	slli	a4,a6,0x20
ffffffffc0203616:	9301                	srli	a4,a4,0x20
ffffffffc0203618:	00371793          	slli	a5,a4,0x3
ffffffffc020361c:	97ba                	add	a5,a5,a4
ffffffffc020361e:	078e                	slli	a5,a5,0x3
ffffffffc0203620:	97b2                	add	a5,a5,a2
ffffffffc0203622:	02f50e63          	beq	a0,a5,ffffffffc020365e <default_free_pages+0x120>
ffffffffc0203626:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc0203628:	fe078713          	addi	a4,a5,-32
ffffffffc020362c:	00d78d63          	beq	a5,a3,ffffffffc0203646 <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0203630:	4d0c                	lw	a1,24(a0)
ffffffffc0203632:	02059613          	slli	a2,a1,0x20
ffffffffc0203636:	9201                	srli	a2,a2,0x20
ffffffffc0203638:	00361693          	slli	a3,a2,0x3
ffffffffc020363c:	96b2                	add	a3,a3,a2
ffffffffc020363e:	068e                	slli	a3,a3,0x3
ffffffffc0203640:	96aa                	add	a3,a3,a0
ffffffffc0203642:	04d70063          	beq	a4,a3,ffffffffc0203682 <default_free_pages+0x144>
}
ffffffffc0203646:	60a2                	ld	ra,8(sp)
ffffffffc0203648:	0141                	addi	sp,sp,16
ffffffffc020364a:	8082                	ret
ffffffffc020364c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020364e:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0203652:	e398                	sd	a4,0(a5)
ffffffffc0203654:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203656:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203658:	f11c                	sd	a5,32(a0)
}
ffffffffc020365a:	0141                	addi	sp,sp,16
ffffffffc020365c:	8082                	ret
            p->property += base->property;
ffffffffc020365e:	4d1c                	lw	a5,24(a0)
ffffffffc0203660:	0107883b          	addw	a6,a5,a6
ffffffffc0203664:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203668:	57f5                	li	a5,-3
ffffffffc020366a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020366e:	02053803          	ld	a6,32(a0)
ffffffffc0203672:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc0203674:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203676:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020367a:	659c                	ld	a5,8(a1)
ffffffffc020367c:	01073023          	sd	a6,0(a4)
ffffffffc0203680:	b765                	j	ffffffffc0203628 <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0203682:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203686:	fe878693          	addi	a3,a5,-24
ffffffffc020368a:	9db9                	addw	a1,a1,a4
ffffffffc020368c:	cd0c                	sw	a1,24(a0)
ffffffffc020368e:	5775                	li	a4,-3
ffffffffc0203690:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203694:	6398                	ld	a4,0(a5)
ffffffffc0203696:	679c                	ld	a5,8(a5)
}
ffffffffc0203698:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020369a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020369c:	e398                	sd	a4,0(a5)
ffffffffc020369e:	0141                	addi	sp,sp,16
ffffffffc02036a0:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02036a2:	00002697          	auipc	a3,0x2
ffffffffc02036a6:	6e668693          	addi	a3,a3,1766 # ffffffffc0205d88 <commands+0x1918>
ffffffffc02036aa:	00002617          	auipc	a2,0x2
ffffffffc02036ae:	82660613          	addi	a2,a2,-2010 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02036b2:	08300593          	li	a1,131
ffffffffc02036b6:	00002517          	auipc	a0,0x2
ffffffffc02036ba:	3c250513          	addi	a0,a0,962 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02036be:	a49fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc02036c2:	00002697          	auipc	a3,0x2
ffffffffc02036c6:	6ee68693          	addi	a3,a3,1774 # ffffffffc0205db0 <commands+0x1940>
ffffffffc02036ca:	00002617          	auipc	a2,0x2
ffffffffc02036ce:	80660613          	addi	a2,a2,-2042 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02036d2:	08000593          	li	a1,128
ffffffffc02036d6:	00002517          	auipc	a0,0x2
ffffffffc02036da:	3a250513          	addi	a0,a0,930 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02036de:	a29fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02036e2 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02036e2:	cd51                	beqz	a0,ffffffffc020377e <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02036e4:	0000e597          	auipc	a1,0xe
ffffffffc02036e8:	ea458593          	addi	a1,a1,-348 # ffffffffc0211588 <free_area>
ffffffffc02036ec:	0105a803          	lw	a6,16(a1)
ffffffffc02036f0:	862a                	mv	a2,a0
ffffffffc02036f2:	02081793          	slli	a5,a6,0x20
ffffffffc02036f6:	9381                	srli	a5,a5,0x20
ffffffffc02036f8:	00a7ee63          	bltu	a5,a0,ffffffffc0203714 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02036fc:	87ae                	mv	a5,a1
ffffffffc02036fe:	a801                	j	ffffffffc020370e <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203700:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203704:	02071693          	slli	a3,a4,0x20
ffffffffc0203708:	9281                	srli	a3,a3,0x20
ffffffffc020370a:	00c6f763          	bleu	a2,a3,ffffffffc0203718 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020370e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203710:	feb798e3          	bne	a5,a1,ffffffffc0203700 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203714:	4501                	li	a0,0
}
ffffffffc0203716:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0203718:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc020371c:	dd6d                	beqz	a0,ffffffffc0203716 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc020371e:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203722:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0203726:	00060e1b          	sext.w	t3,a2
ffffffffc020372a:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020372e:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203732:	02d67b63          	bleu	a3,a2,ffffffffc0203768 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0203736:	00361693          	slli	a3,a2,0x3
ffffffffc020373a:	96b2                	add	a3,a3,a2
ffffffffc020373c:	068e                	slli	a3,a3,0x3
ffffffffc020373e:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0203740:	41c7073b          	subw	a4,a4,t3
ffffffffc0203744:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203746:	00868613          	addi	a2,a3,8
ffffffffc020374a:	4709                	li	a4,2
ffffffffc020374c:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203750:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203754:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc0203758:	0105a803          	lw	a6,16(a1)
ffffffffc020375c:	e310                	sd	a2,0(a4)
ffffffffc020375e:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203762:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0203764:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc0203768:	41c8083b          	subw	a6,a6,t3
ffffffffc020376c:	0000e717          	auipc	a4,0xe
ffffffffc0203770:	e3072623          	sw	a6,-468(a4) # ffffffffc0211598 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203774:	5775                	li	a4,-3
ffffffffc0203776:	17a1                	addi	a5,a5,-24
ffffffffc0203778:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020377c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020377e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203780:	00002697          	auipc	a3,0x2
ffffffffc0203784:	63068693          	addi	a3,a3,1584 # ffffffffc0205db0 <commands+0x1940>
ffffffffc0203788:	00001617          	auipc	a2,0x1
ffffffffc020378c:	74860613          	addi	a2,a2,1864 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203790:	06200593          	li	a1,98
ffffffffc0203794:	00002517          	auipc	a0,0x2
ffffffffc0203798:	2e450513          	addi	a0,a0,740 # ffffffffc0205a78 <commands+0x1608>
default_alloc_pages(size_t n) {
ffffffffc020379c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020379e:	969fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02037a2 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02037a2:	1141                	addi	sp,sp,-16
ffffffffc02037a4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02037a6:	c1fd                	beqz	a1,ffffffffc020388c <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02037a8:	00359693          	slli	a3,a1,0x3
ffffffffc02037ac:	96ae                	add	a3,a3,a1
ffffffffc02037ae:	068e                	slli	a3,a3,0x3
ffffffffc02037b0:	96aa                	add	a3,a3,a0
ffffffffc02037b2:	02d50463          	beq	a0,a3,ffffffffc02037da <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02037b6:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02037b8:	87aa                	mv	a5,a0
ffffffffc02037ba:	8b05                	andi	a4,a4,1
ffffffffc02037bc:	e709                	bnez	a4,ffffffffc02037c6 <default_init_memmap+0x24>
ffffffffc02037be:	a07d                	j	ffffffffc020386c <default_init_memmap+0xca>
ffffffffc02037c0:	6798                	ld	a4,8(a5)
ffffffffc02037c2:	8b05                	andi	a4,a4,1
ffffffffc02037c4:	c745                	beqz	a4,ffffffffc020386c <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02037c6:	0007ac23          	sw	zero,24(a5)
ffffffffc02037ca:	0007b423          	sd	zero,8(a5)
ffffffffc02037ce:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02037d2:	04878793          	addi	a5,a5,72
ffffffffc02037d6:	fed795e3          	bne	a5,a3,ffffffffc02037c0 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02037da:	2581                	sext.w	a1,a1
ffffffffc02037dc:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02037de:	4789                	li	a5,2
ffffffffc02037e0:	00850713          	addi	a4,a0,8
ffffffffc02037e4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02037e8:	0000e697          	auipc	a3,0xe
ffffffffc02037ec:	da068693          	addi	a3,a3,-608 # ffffffffc0211588 <free_area>
ffffffffc02037f0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02037f2:	669c                	ld	a5,8(a3)
ffffffffc02037f4:	9db9                	addw	a1,a1,a4
ffffffffc02037f6:	0000e717          	auipc	a4,0xe
ffffffffc02037fa:	dab72123          	sw	a1,-606(a4) # ffffffffc0211598 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02037fe:	04d78a63          	beq	a5,a3,ffffffffc0203852 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0203802:	fe078713          	addi	a4,a5,-32
ffffffffc0203806:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203808:	4801                	li	a6,0
ffffffffc020380a:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc020380e:	00e56a63          	bltu	a0,a4,ffffffffc0203822 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0203812:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203814:	02d70563          	beq	a4,a3,ffffffffc020383e <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203818:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020381a:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020381e:	fee57ae3          	bleu	a4,a0,ffffffffc0203812 <default_init_memmap+0x70>
ffffffffc0203822:	00080663          	beqz	a6,ffffffffc020382e <default_init_memmap+0x8c>
ffffffffc0203826:	0000e717          	auipc	a4,0xe
ffffffffc020382a:	d6b73123          	sd	a1,-670(a4) # ffffffffc0211588 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020382e:	6398                	ld	a4,0(a5)
}
ffffffffc0203830:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203832:	e390                	sd	a2,0(a5)
ffffffffc0203834:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203836:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203838:	f118                	sd	a4,32(a0)
ffffffffc020383a:	0141                	addi	sp,sp,16
ffffffffc020383c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020383e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203840:	f514                	sd	a3,40(a0)
ffffffffc0203842:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203844:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0203846:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203848:	00d70e63          	beq	a4,a3,ffffffffc0203864 <default_init_memmap+0xc2>
ffffffffc020384c:	4805                	li	a6,1
ffffffffc020384e:	87ba                	mv	a5,a4
ffffffffc0203850:	b7e9                	j	ffffffffc020381a <default_init_memmap+0x78>
}
ffffffffc0203852:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203854:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0203858:	e398                	sd	a4,0(a5)
ffffffffc020385a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020385c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020385e:	f11c                	sd	a5,32(a0)
}
ffffffffc0203860:	0141                	addi	sp,sp,16
ffffffffc0203862:	8082                	ret
ffffffffc0203864:	60a2                	ld	ra,8(sp)
ffffffffc0203866:	e290                	sd	a2,0(a3)
ffffffffc0203868:	0141                	addi	sp,sp,16
ffffffffc020386a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020386c:	00002697          	auipc	a3,0x2
ffffffffc0203870:	54c68693          	addi	a3,a3,1356 # ffffffffc0205db8 <commands+0x1948>
ffffffffc0203874:	00001617          	auipc	a2,0x1
ffffffffc0203878:	65c60613          	addi	a2,a2,1628 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020387c:	04900593          	li	a1,73
ffffffffc0203880:	00002517          	auipc	a0,0x2
ffffffffc0203884:	1f850513          	addi	a0,a0,504 # ffffffffc0205a78 <commands+0x1608>
ffffffffc0203888:	87ffc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc020388c:	00002697          	auipc	a3,0x2
ffffffffc0203890:	52468693          	addi	a3,a3,1316 # ffffffffc0205db0 <commands+0x1940>
ffffffffc0203894:	00001617          	auipc	a2,0x1
ffffffffc0203898:	63c60613          	addi	a2,a2,1596 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020389c:	04600593          	li	a1,70
ffffffffc02038a0:	00002517          	auipc	a0,0x2
ffffffffc02038a4:	1d850513          	addi	a0,a0,472 # ffffffffc0205a78 <commands+0x1608>
ffffffffc02038a8:	85ffc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02038ac <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02038ac:	0000e797          	auipc	a5,0xe
ffffffffc02038b0:	ccc78793          	addi	a5,a5,-820 # ffffffffc0211578 <pra_list_head>
     // 初始化pra_list_head为空链表
     list_init(&pra_list_head);
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     curr_ptr = &pra_list_head;
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv = &pra_list_head;
ffffffffc02038b4:	f51c                	sd	a5,40(a0)
ffffffffc02038b6:	e79c                	sd	a5,8(a5)
ffffffffc02038b8:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc02038ba:	0000e717          	auipc	a4,0xe
ffffffffc02038be:	cef73323          	sd	a5,-794(a4) # ffffffffc02115a0 <curr_ptr>
     //cprintf(" mm->sm_priv %x in clock_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02038c2:	4501                	li	a0,0
ffffffffc02038c4:	8082                	ret

ffffffffc02038c6 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02038c6:	4501                	li	a0,0
ffffffffc02038c8:	8082                	ret

ffffffffc02038ca <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02038ca:	4501                	li	a0,0
ffffffffc02038cc:	8082                	ret

ffffffffc02038ce <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02038ce:	4501                	li	a0,0
ffffffffc02038d0:	8082                	ret

ffffffffc02038d2 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02038d2:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02038d4:	678d                	lui	a5,0x3
ffffffffc02038d6:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02038d8:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02038da:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02038de:	0000e797          	auipc	a5,0xe
ffffffffc02038e2:	b8a78793          	addi	a5,a5,-1142 # ffffffffc0211468 <pgfault_num>
ffffffffc02038e6:	4398                	lw	a4,0(a5)
ffffffffc02038e8:	4691                	li	a3,4
ffffffffc02038ea:	2701                	sext.w	a4,a4
ffffffffc02038ec:	08d71f63          	bne	a4,a3,ffffffffc020398a <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02038f0:	6685                	lui	a3,0x1
ffffffffc02038f2:	4629                	li	a2,10
ffffffffc02038f4:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02038f8:	4394                	lw	a3,0(a5)
ffffffffc02038fa:	2681                	sext.w	a3,a3
ffffffffc02038fc:	20e69763          	bne	a3,a4,ffffffffc0203b0a <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203900:	6711                	lui	a4,0x4
ffffffffc0203902:	4635                	li	a2,13
ffffffffc0203904:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203908:	4398                	lw	a4,0(a5)
ffffffffc020390a:	2701                	sext.w	a4,a4
ffffffffc020390c:	1cd71f63          	bne	a4,a3,ffffffffc0203aea <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203910:	6689                	lui	a3,0x2
ffffffffc0203912:	462d                	li	a2,11
ffffffffc0203914:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203918:	4394                	lw	a3,0(a5)
ffffffffc020391a:	2681                	sext.w	a3,a3
ffffffffc020391c:	1ae69763          	bne	a3,a4,ffffffffc0203aca <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203920:	6715                	lui	a4,0x5
ffffffffc0203922:	46b9                	li	a3,14
ffffffffc0203924:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203928:	4398                	lw	a4,0(a5)
ffffffffc020392a:	4695                	li	a3,5
ffffffffc020392c:	2701                	sext.w	a4,a4
ffffffffc020392e:	16d71e63          	bne	a4,a3,ffffffffc0203aaa <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0203932:	4394                	lw	a3,0(a5)
ffffffffc0203934:	2681                	sext.w	a3,a3
ffffffffc0203936:	14e69a63          	bne	a3,a4,ffffffffc0203a8a <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc020393a:	4398                	lw	a4,0(a5)
ffffffffc020393c:	2701                	sext.w	a4,a4
ffffffffc020393e:	12d71663          	bne	a4,a3,ffffffffc0203a6a <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0203942:	4394                	lw	a3,0(a5)
ffffffffc0203944:	2681                	sext.w	a3,a3
ffffffffc0203946:	10e69263          	bne	a3,a4,ffffffffc0203a4a <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc020394a:	4398                	lw	a4,0(a5)
ffffffffc020394c:	2701                	sext.w	a4,a4
ffffffffc020394e:	0cd71e63          	bne	a4,a3,ffffffffc0203a2a <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0203952:	4394                	lw	a3,0(a5)
ffffffffc0203954:	2681                	sext.w	a3,a3
ffffffffc0203956:	0ae69a63          	bne	a3,a4,ffffffffc0203a0a <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020395a:	6715                	lui	a4,0x5
ffffffffc020395c:	46b9                	li	a3,14
ffffffffc020395e:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203962:	4398                	lw	a4,0(a5)
ffffffffc0203964:	4695                	li	a3,5
ffffffffc0203966:	2701                	sext.w	a4,a4
ffffffffc0203968:	08d71163          	bne	a4,a3,ffffffffc02039ea <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020396c:	6705                	lui	a4,0x1
ffffffffc020396e:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203972:	4729                	li	a4,10
ffffffffc0203974:	04e69b63          	bne	a3,a4,ffffffffc02039ca <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc0203978:	439c                	lw	a5,0(a5)
ffffffffc020397a:	4719                	li	a4,6
ffffffffc020397c:	2781                	sext.w	a5,a5
ffffffffc020397e:	02e79663          	bne	a5,a4,ffffffffc02039aa <_clock_check_swap+0xd8>
}
ffffffffc0203982:	60a2                	ld	ra,8(sp)
ffffffffc0203984:	4501                	li	a0,0
ffffffffc0203986:	0141                	addi	sp,sp,16
ffffffffc0203988:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020398a:	00002697          	auipc	a3,0x2
ffffffffc020398e:	f7e68693          	addi	a3,a3,-130 # ffffffffc0205908 <commands+0x1498>
ffffffffc0203992:	00001617          	auipc	a2,0x1
ffffffffc0203996:	53e60613          	addi	a2,a2,1342 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc020399a:	08300593          	li	a1,131
ffffffffc020399e:	00002517          	auipc	a0,0x2
ffffffffc02039a2:	47a50513          	addi	a0,a0,1146 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc02039a6:	f60fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==6);
ffffffffc02039aa:	00002697          	auipc	a3,0x2
ffffffffc02039ae:	4be68693          	addi	a3,a3,1214 # ffffffffc0205e68 <default_pmm_manager+0xa0>
ffffffffc02039b2:	00001617          	auipc	a2,0x1
ffffffffc02039b6:	51e60613          	addi	a2,a2,1310 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02039ba:	09a00593          	li	a1,154
ffffffffc02039be:	00002517          	auipc	a0,0x2
ffffffffc02039c2:	45a50513          	addi	a0,a0,1114 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc02039c6:	f40fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02039ca:	00002697          	auipc	a3,0x2
ffffffffc02039ce:	47668693          	addi	a3,a3,1142 # ffffffffc0205e40 <default_pmm_manager+0x78>
ffffffffc02039d2:	00001617          	auipc	a2,0x1
ffffffffc02039d6:	4fe60613          	addi	a2,a2,1278 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02039da:	09800593          	li	a1,152
ffffffffc02039de:	00002517          	auipc	a0,0x2
ffffffffc02039e2:	43a50513          	addi	a0,a0,1082 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc02039e6:	f20fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc02039ea:	00002697          	auipc	a3,0x2
ffffffffc02039ee:	44668693          	addi	a3,a3,1094 # ffffffffc0205e30 <default_pmm_manager+0x68>
ffffffffc02039f2:	00001617          	auipc	a2,0x1
ffffffffc02039f6:	4de60613          	addi	a2,a2,1246 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc02039fa:	09700593          	li	a1,151
ffffffffc02039fe:	00002517          	auipc	a0,0x2
ffffffffc0203a02:	41a50513          	addi	a0,a0,1050 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203a06:	f00fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a0a:	00002697          	auipc	a3,0x2
ffffffffc0203a0e:	42668693          	addi	a3,a3,1062 # ffffffffc0205e30 <default_pmm_manager+0x68>
ffffffffc0203a12:	00001617          	auipc	a2,0x1
ffffffffc0203a16:	4be60613          	addi	a2,a2,1214 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203a1a:	09500593          	li	a1,149
ffffffffc0203a1e:	00002517          	auipc	a0,0x2
ffffffffc0203a22:	3fa50513          	addi	a0,a0,1018 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203a26:	ee0fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a2a:	00002697          	auipc	a3,0x2
ffffffffc0203a2e:	40668693          	addi	a3,a3,1030 # ffffffffc0205e30 <default_pmm_manager+0x68>
ffffffffc0203a32:	00001617          	auipc	a2,0x1
ffffffffc0203a36:	49e60613          	addi	a2,a2,1182 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203a3a:	09300593          	li	a1,147
ffffffffc0203a3e:	00002517          	auipc	a0,0x2
ffffffffc0203a42:	3da50513          	addi	a0,a0,986 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203a46:	ec0fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a4a:	00002697          	auipc	a3,0x2
ffffffffc0203a4e:	3e668693          	addi	a3,a3,998 # ffffffffc0205e30 <default_pmm_manager+0x68>
ffffffffc0203a52:	00001617          	auipc	a2,0x1
ffffffffc0203a56:	47e60613          	addi	a2,a2,1150 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203a5a:	09100593          	li	a1,145
ffffffffc0203a5e:	00002517          	auipc	a0,0x2
ffffffffc0203a62:	3ba50513          	addi	a0,a0,954 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203a66:	ea0fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a6a:	00002697          	auipc	a3,0x2
ffffffffc0203a6e:	3c668693          	addi	a3,a3,966 # ffffffffc0205e30 <default_pmm_manager+0x68>
ffffffffc0203a72:	00001617          	auipc	a2,0x1
ffffffffc0203a76:	45e60613          	addi	a2,a2,1118 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203a7a:	08f00593          	li	a1,143
ffffffffc0203a7e:	00002517          	auipc	a0,0x2
ffffffffc0203a82:	39a50513          	addi	a0,a0,922 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203a86:	e80fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a8a:	00002697          	auipc	a3,0x2
ffffffffc0203a8e:	3a668693          	addi	a3,a3,934 # ffffffffc0205e30 <default_pmm_manager+0x68>
ffffffffc0203a92:	00001617          	auipc	a2,0x1
ffffffffc0203a96:	43e60613          	addi	a2,a2,1086 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203a9a:	08d00593          	li	a1,141
ffffffffc0203a9e:	00002517          	auipc	a0,0x2
ffffffffc0203aa2:	37a50513          	addi	a0,a0,890 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203aa6:	e60fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203aaa:	00002697          	auipc	a3,0x2
ffffffffc0203aae:	38668693          	addi	a3,a3,902 # ffffffffc0205e30 <default_pmm_manager+0x68>
ffffffffc0203ab2:	00001617          	auipc	a2,0x1
ffffffffc0203ab6:	41e60613          	addi	a2,a2,1054 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203aba:	08b00593          	li	a1,139
ffffffffc0203abe:	00002517          	auipc	a0,0x2
ffffffffc0203ac2:	35a50513          	addi	a0,a0,858 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203ac6:	e40fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0203aca:	00002697          	auipc	a3,0x2
ffffffffc0203ace:	e3e68693          	addi	a3,a3,-450 # ffffffffc0205908 <commands+0x1498>
ffffffffc0203ad2:	00001617          	auipc	a2,0x1
ffffffffc0203ad6:	3fe60613          	addi	a2,a2,1022 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203ada:	08900593          	li	a1,137
ffffffffc0203ade:	00002517          	auipc	a0,0x2
ffffffffc0203ae2:	33a50513          	addi	a0,a0,826 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203ae6:	e20fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0203aea:	00002697          	auipc	a3,0x2
ffffffffc0203aee:	e1e68693          	addi	a3,a3,-482 # ffffffffc0205908 <commands+0x1498>
ffffffffc0203af2:	00001617          	auipc	a2,0x1
ffffffffc0203af6:	3de60613          	addi	a2,a2,990 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203afa:	08700593          	li	a1,135
ffffffffc0203afe:	00002517          	auipc	a0,0x2
ffffffffc0203b02:	31a50513          	addi	a0,a0,794 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203b06:	e00fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0203b0a:	00002697          	auipc	a3,0x2
ffffffffc0203b0e:	dfe68693          	addi	a3,a3,-514 # ffffffffc0205908 <commands+0x1498>
ffffffffc0203b12:	00001617          	auipc	a2,0x1
ffffffffc0203b16:	3be60613          	addi	a2,a2,958 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203b1a:	08500593          	li	a1,133
ffffffffc0203b1e:	00002517          	auipc	a0,0x2
ffffffffc0203b22:	2fa50513          	addi	a0,a0,762 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203b26:	de0fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203b2a <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203b2a:	03060793          	addi	a5,a2,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203b2e:	7518                	ld	a4,40(a0)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203b30:	c385                	beqz	a5,ffffffffc0203b50 <_clock_map_swappable+0x26>
ffffffffc0203b32:	0000e697          	auipc	a3,0xe
ffffffffc0203b36:	a6e68693          	addi	a3,a3,-1426 # ffffffffc02115a0 <curr_ptr>
ffffffffc0203b3a:	6294                	ld	a3,0(a3)
ffffffffc0203b3c:	ca91                	beqz	a3,ffffffffc0203b50 <_clock_map_swappable+0x26>
    __list_add(elm, listelm, listelm->next);
ffffffffc0203b3e:	6714                	ld	a3,8(a4)
}
ffffffffc0203b40:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0203b42:	e29c                	sd	a5,0(a3)
ffffffffc0203b44:	e71c                	sd	a5,8(a4)
    page->visited = 1;
ffffffffc0203b46:	4785                	li	a5,1
    elm->next = next;
ffffffffc0203b48:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0203b4a:	fa18                	sd	a4,48(a2)
ffffffffc0203b4c:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203b4e:	8082                	ret
{
ffffffffc0203b50:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203b52:	00002697          	auipc	a3,0x2
ffffffffc0203b56:	32668693          	addi	a3,a3,806 # ffffffffc0205e78 <default_pmm_manager+0xb0>
ffffffffc0203b5a:	00001617          	auipc	a2,0x1
ffffffffc0203b5e:	37660613          	addi	a2,a2,886 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203b62:	03200593          	li	a1,50
ffffffffc0203b66:	00002517          	auipc	a0,0x2
ffffffffc0203b6a:	2b250513          	addi	a0,a0,690 # ffffffffc0205e18 <default_pmm_manager+0x50>
{
ffffffffc0203b6e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203b70:	d96fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203b74 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203b74:	751c                	ld	a5,40(a0)
{
ffffffffc0203b76:	1101                	addi	sp,sp,-32
ffffffffc0203b78:	ec06                	sd	ra,24(sp)
ffffffffc0203b7a:	e822                	sd	s0,16(sp)
ffffffffc0203b7c:	e426                	sd	s1,8(sp)
     assert(head != NULL);
ffffffffc0203b7e:	c3ad                	beqz	a5,ffffffffc0203be0 <_clock_swap_out_victim+0x6c>
     assert(in_tick==0);
ffffffffc0203b80:	e241                	bnez	a2,ffffffffc0203c00 <_clock_swap_out_victim+0x8c>
    return listelm->prev;
ffffffffc0203b82:	6380                	ld	s0,0(a5)
ffffffffc0203b84:	84ae                	mv	s1,a1
        if(entry == head){
ffffffffc0203b86:	02878f63          	beq	a5,s0,ffffffffc0203bc4 <_clock_swap_out_victim+0x50>
        if(page->visited == 0){
ffffffffc0203b8a:	fe043783          	ld	a5,-32(s0)
ffffffffc0203b8e:	c3b9                	beqz	a5,ffffffffc0203bd4 <_clock_swap_out_victim+0x60>
ffffffffc0203b90:	fe043023          	sd	zero,-32(s0)
ffffffffc0203b94:	0000e797          	auipc	a5,0xe
ffffffffc0203b98:	a087b623          	sd	s0,-1524(a5) # ffffffffc02115a0 <curr_ptr>
ffffffffc0203b9c:	85a2                	mv	a1,s0
        	cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc0203b9e:	00002517          	auipc	a0,0x2
ffffffffc0203ba2:	32250513          	addi	a0,a0,802 # ffffffffc0205ec0 <default_pmm_manager+0xf8>
ffffffffc0203ba6:	d18fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203baa:	6018                	ld	a4,0(s0)
ffffffffc0203bac:	641c                	ld	a5,8(s0)
        struct Page* page = le2page(entry, pra_page_link);
ffffffffc0203bae:	fd040413          	addi	s0,s0,-48
}
ffffffffc0203bb2:	60e2                	ld	ra,24(sp)
    prev->next = next;
ffffffffc0203bb4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203bb6:	e398                	sd	a4,0(a5)
        	*ptr_page = le2page(entry, pra_page_link);
ffffffffc0203bb8:	e080                	sd	s0,0(s1)
}
ffffffffc0203bba:	6442                	ld	s0,16(sp)
ffffffffc0203bbc:	64a2                	ld	s1,8(sp)
ffffffffc0203bbe:	4501                	li	a0,0
ffffffffc0203bc0:	6105                	addi	sp,sp,32
ffffffffc0203bc2:	8082                	ret
ffffffffc0203bc4:	60e2                	ld	ra,24(sp)
ffffffffc0203bc6:	6442                	ld	s0,16(sp)
        	*ptr_page = NULL;
ffffffffc0203bc8:	0005b023          	sd	zero,0(a1)
}
ffffffffc0203bcc:	64a2                	ld	s1,8(sp)
ffffffffc0203bce:	4501                	li	a0,0
ffffffffc0203bd0:	6105                	addi	sp,sp,32
ffffffffc0203bd2:	8082                	ret
ffffffffc0203bd4:	0000e797          	auipc	a5,0xe
ffffffffc0203bd8:	9cc78793          	addi	a5,a5,-1588 # ffffffffc02115a0 <curr_ptr>
ffffffffc0203bdc:	638c                	ld	a1,0(a5)
ffffffffc0203bde:	b7c1                	j	ffffffffc0203b9e <_clock_swap_out_victim+0x2a>
     assert(head != NULL);
ffffffffc0203be0:	00002697          	auipc	a3,0x2
ffffffffc0203be4:	2c068693          	addi	a3,a3,704 # ffffffffc0205ea0 <default_pmm_manager+0xd8>
ffffffffc0203be8:	00001617          	auipc	a2,0x1
ffffffffc0203bec:	2e860613          	addi	a2,a2,744 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203bf0:	04000593          	li	a1,64
ffffffffc0203bf4:	00002517          	auipc	a0,0x2
ffffffffc0203bf8:	22450513          	addi	a0,a0,548 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203bfc:	d0afc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(in_tick==0);
ffffffffc0203c00:	00002697          	auipc	a3,0x2
ffffffffc0203c04:	2b068693          	addi	a3,a3,688 # ffffffffc0205eb0 <default_pmm_manager+0xe8>
ffffffffc0203c08:	00001617          	auipc	a2,0x1
ffffffffc0203c0c:	2c860613          	addi	a2,a2,712 # ffffffffc0204ed0 <commands+0xa60>
ffffffffc0203c10:	04100593          	li	a1,65
ffffffffc0203c14:	00002517          	auipc	a0,0x2
ffffffffc0203c18:	20450513          	addi	a0,a0,516 # ffffffffc0205e18 <default_pmm_manager+0x50>
ffffffffc0203c1c:	ceafc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203c20 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c20:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c22:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c24:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c26:	fb0fc0ef          	jal	ra,ffffffffc02003d6 <ide_device_valid>
ffffffffc0203c2a:	cd01                	beqz	a0,ffffffffc0203c42 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c2c:	4505                	li	a0,1
ffffffffc0203c2e:	faefc0ef          	jal	ra,ffffffffc02003dc <ide_device_size>
}
ffffffffc0203c32:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c34:	810d                	srli	a0,a0,0x3
ffffffffc0203c36:	0000e797          	auipc	a5,0xe
ffffffffc0203c3a:	90a7b123          	sd	a0,-1790(a5) # ffffffffc0211538 <max_swap_offset>
}
ffffffffc0203c3e:	0141                	addi	sp,sp,16
ffffffffc0203c40:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c42:	00002617          	auipc	a2,0x2
ffffffffc0203c46:	2a660613          	addi	a2,a2,678 # ffffffffc0205ee8 <default_pmm_manager+0x120>
ffffffffc0203c4a:	45b5                	li	a1,13
ffffffffc0203c4c:	00002517          	auipc	a0,0x2
ffffffffc0203c50:	2bc50513          	addi	a0,a0,700 # ffffffffc0205f08 <default_pmm_manager+0x140>
ffffffffc0203c54:	cb2fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203c58 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c58:	1141                	addi	sp,sp,-16
ffffffffc0203c5a:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c5c:	00855793          	srli	a5,a0,0x8
ffffffffc0203c60:	c7b5                	beqz	a5,ffffffffc0203ccc <swapfs_read+0x74>
ffffffffc0203c62:	0000e717          	auipc	a4,0xe
ffffffffc0203c66:	8d670713          	addi	a4,a4,-1834 # ffffffffc0211538 <max_swap_offset>
ffffffffc0203c6a:	6318                	ld	a4,0(a4)
ffffffffc0203c6c:	06e7f063          	bleu	a4,a5,ffffffffc0203ccc <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c70:	0000e717          	auipc	a4,0xe
ffffffffc0203c74:	83070713          	addi	a4,a4,-2000 # ffffffffc02114a0 <pages>
ffffffffc0203c78:	6310                	ld	a2,0(a4)
ffffffffc0203c7a:	00001717          	auipc	a4,0x1
ffffffffc0203c7e:	09e70713          	addi	a4,a4,158 # ffffffffc0204d18 <commands+0x8a8>
ffffffffc0203c82:	00002697          	auipc	a3,0x2
ffffffffc0203c86:	50668693          	addi	a3,a3,1286 # ffffffffc0206188 <nbase>
ffffffffc0203c8a:	40c58633          	sub	a2,a1,a2
ffffffffc0203c8e:	630c                	ld	a1,0(a4)
ffffffffc0203c90:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c92:	0000d717          	auipc	a4,0xd
ffffffffc0203c96:	7ce70713          	addi	a4,a4,1998 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c9a:	02b60633          	mul	a2,a2,a1
ffffffffc0203c9e:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ca2:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ca4:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ca6:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ca8:	57fd                	li	a5,-1
ffffffffc0203caa:	83b1                	srli	a5,a5,0xc
ffffffffc0203cac:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cae:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cb0:	02e7fa63          	bleu	a4,a5,ffffffffc0203ce4 <swapfs_read+0x8c>
ffffffffc0203cb4:	0000d797          	auipc	a5,0xd
ffffffffc0203cb8:	7dc78793          	addi	a5,a5,2012 # ffffffffc0211490 <va_pa_offset>
ffffffffc0203cbc:	639c                	ld	a5,0(a5)
}
ffffffffc0203cbe:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cc0:	46a1                	li	a3,8
ffffffffc0203cc2:	963e                	add	a2,a2,a5
ffffffffc0203cc4:	4505                	li	a0,1
}
ffffffffc0203cc6:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cc8:	f1afc06f          	j	ffffffffc02003e2 <ide_read_secs>
ffffffffc0203ccc:	86aa                	mv	a3,a0
ffffffffc0203cce:	00002617          	auipc	a2,0x2
ffffffffc0203cd2:	25260613          	addi	a2,a2,594 # ffffffffc0205f20 <default_pmm_manager+0x158>
ffffffffc0203cd6:	45d1                	li	a1,20
ffffffffc0203cd8:	00002517          	auipc	a0,0x2
ffffffffc0203cdc:	23050513          	addi	a0,a0,560 # ffffffffc0205f08 <default_pmm_manager+0x140>
ffffffffc0203ce0:	c26fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203ce4:	86b2                	mv	a3,a2
ffffffffc0203ce6:	06a00593          	li	a1,106
ffffffffc0203cea:	00001617          	auipc	a2,0x1
ffffffffc0203cee:	03660613          	addi	a2,a2,54 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc0203cf2:	00001517          	auipc	a0,0x1
ffffffffc0203cf6:	0c650513          	addi	a0,a0,198 # ffffffffc0204db8 <commands+0x948>
ffffffffc0203cfa:	c0cfc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203cfe <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203cfe:	1141                	addi	sp,sp,-16
ffffffffc0203d00:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d02:	00855793          	srli	a5,a0,0x8
ffffffffc0203d06:	c7b5                	beqz	a5,ffffffffc0203d72 <swapfs_write+0x74>
ffffffffc0203d08:	0000e717          	auipc	a4,0xe
ffffffffc0203d0c:	83070713          	addi	a4,a4,-2000 # ffffffffc0211538 <max_swap_offset>
ffffffffc0203d10:	6318                	ld	a4,0(a4)
ffffffffc0203d12:	06e7f063          	bleu	a4,a5,ffffffffc0203d72 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d16:	0000d717          	auipc	a4,0xd
ffffffffc0203d1a:	78a70713          	addi	a4,a4,1930 # ffffffffc02114a0 <pages>
ffffffffc0203d1e:	6310                	ld	a2,0(a4)
ffffffffc0203d20:	00001717          	auipc	a4,0x1
ffffffffc0203d24:	ff870713          	addi	a4,a4,-8 # ffffffffc0204d18 <commands+0x8a8>
ffffffffc0203d28:	00002697          	auipc	a3,0x2
ffffffffc0203d2c:	46068693          	addi	a3,a3,1120 # ffffffffc0206188 <nbase>
ffffffffc0203d30:	40c58633          	sub	a2,a1,a2
ffffffffc0203d34:	630c                	ld	a1,0(a4)
ffffffffc0203d36:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d38:	0000d717          	auipc	a4,0xd
ffffffffc0203d3c:	72870713          	addi	a4,a4,1832 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d40:	02b60633          	mul	a2,a2,a1
ffffffffc0203d44:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d48:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d4a:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d4c:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d4e:	57fd                	li	a5,-1
ffffffffc0203d50:	83b1                	srli	a5,a5,0xc
ffffffffc0203d52:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d54:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d56:	02e7fa63          	bleu	a4,a5,ffffffffc0203d8a <swapfs_write+0x8c>
ffffffffc0203d5a:	0000d797          	auipc	a5,0xd
ffffffffc0203d5e:	73678793          	addi	a5,a5,1846 # ffffffffc0211490 <va_pa_offset>
ffffffffc0203d62:	639c                	ld	a5,0(a5)
}
ffffffffc0203d64:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d66:	46a1                	li	a3,8
ffffffffc0203d68:	963e                	add	a2,a2,a5
ffffffffc0203d6a:	4505                	li	a0,1
}
ffffffffc0203d6c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d6e:	e98fc06f          	j	ffffffffc0200406 <ide_write_secs>
ffffffffc0203d72:	86aa                	mv	a3,a0
ffffffffc0203d74:	00002617          	auipc	a2,0x2
ffffffffc0203d78:	1ac60613          	addi	a2,a2,428 # ffffffffc0205f20 <default_pmm_manager+0x158>
ffffffffc0203d7c:	45e5                	li	a1,25
ffffffffc0203d7e:	00002517          	auipc	a0,0x2
ffffffffc0203d82:	18a50513          	addi	a0,a0,394 # ffffffffc0205f08 <default_pmm_manager+0x140>
ffffffffc0203d86:	b80fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203d8a:	86b2                	mv	a3,a2
ffffffffc0203d8c:	06a00593          	li	a1,106
ffffffffc0203d90:	00001617          	auipc	a2,0x1
ffffffffc0203d94:	f9060613          	addi	a2,a2,-112 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc0203d98:	00001517          	auipc	a0,0x1
ffffffffc0203d9c:	02050513          	addi	a0,a0,32 # ffffffffc0204db8 <commands+0x948>
ffffffffc0203da0:	b66fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203da4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203da4:	00054783          	lbu	a5,0(a0)
ffffffffc0203da8:	cb91                	beqz	a5,ffffffffc0203dbc <strlen+0x18>
    size_t cnt = 0;
ffffffffc0203daa:	4781                	li	a5,0
        cnt ++;
ffffffffc0203dac:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0203dae:	00f50733          	add	a4,a0,a5
ffffffffc0203db2:	00074703          	lbu	a4,0(a4)
ffffffffc0203db6:	fb7d                	bnez	a4,ffffffffc0203dac <strlen+0x8>
    }
    return cnt;
}
ffffffffc0203db8:	853e                	mv	a0,a5
ffffffffc0203dba:	8082                	ret
    size_t cnt = 0;
ffffffffc0203dbc:	4781                	li	a5,0
}
ffffffffc0203dbe:	853e                	mv	a0,a5
ffffffffc0203dc0:	8082                	ret

ffffffffc0203dc2 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203dc2:	c185                	beqz	a1,ffffffffc0203de2 <strnlen+0x20>
ffffffffc0203dc4:	00054783          	lbu	a5,0(a0)
ffffffffc0203dc8:	cf89                	beqz	a5,ffffffffc0203de2 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0203dca:	4781                	li	a5,0
ffffffffc0203dcc:	a021                	j	ffffffffc0203dd4 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203dce:	00074703          	lbu	a4,0(a4)
ffffffffc0203dd2:	c711                	beqz	a4,ffffffffc0203dde <strnlen+0x1c>
        cnt ++;
ffffffffc0203dd4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203dd6:	00f50733          	add	a4,a0,a5
ffffffffc0203dda:	fef59ae3          	bne	a1,a5,ffffffffc0203dce <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0203dde:	853e                	mv	a0,a5
ffffffffc0203de0:	8082                	ret
    size_t cnt = 0;
ffffffffc0203de2:	4781                	li	a5,0
}
ffffffffc0203de4:	853e                	mv	a0,a5
ffffffffc0203de6:	8082                	ret

ffffffffc0203de8 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203de8:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203dea:	0585                	addi	a1,a1,1
ffffffffc0203dec:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203df0:	0785                	addi	a5,a5,1
ffffffffc0203df2:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203df6:	fb75                	bnez	a4,ffffffffc0203dea <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203df8:	8082                	ret

ffffffffc0203dfa <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203dfa:	00054783          	lbu	a5,0(a0)
ffffffffc0203dfe:	0005c703          	lbu	a4,0(a1)
ffffffffc0203e02:	cb91                	beqz	a5,ffffffffc0203e16 <strcmp+0x1c>
ffffffffc0203e04:	00e79c63          	bne	a5,a4,ffffffffc0203e1c <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0203e08:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e0a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0203e0e:	0585                	addi	a1,a1,1
ffffffffc0203e10:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e14:	fbe5                	bnez	a5,ffffffffc0203e04 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203e16:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203e18:	9d19                	subw	a0,a0,a4
ffffffffc0203e1a:	8082                	ret
ffffffffc0203e1c:	0007851b          	sext.w	a0,a5
ffffffffc0203e20:	9d19                	subw	a0,a0,a4
ffffffffc0203e22:	8082                	ret

ffffffffc0203e24 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203e24:	00054783          	lbu	a5,0(a0)
ffffffffc0203e28:	cb91                	beqz	a5,ffffffffc0203e3c <strchr+0x18>
        if (*s == c) {
ffffffffc0203e2a:	00b79563          	bne	a5,a1,ffffffffc0203e34 <strchr+0x10>
ffffffffc0203e2e:	a809                	j	ffffffffc0203e40 <strchr+0x1c>
ffffffffc0203e30:	00b78763          	beq	a5,a1,ffffffffc0203e3e <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0203e34:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203e36:	00054783          	lbu	a5,0(a0)
ffffffffc0203e3a:	fbfd                	bnez	a5,ffffffffc0203e30 <strchr+0xc>
    }
    return NULL;
ffffffffc0203e3c:	4501                	li	a0,0
}
ffffffffc0203e3e:	8082                	ret
ffffffffc0203e40:	8082                	ret

ffffffffc0203e42 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203e42:	ca01                	beqz	a2,ffffffffc0203e52 <memset+0x10>
ffffffffc0203e44:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203e46:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203e48:	0785                	addi	a5,a5,1
ffffffffc0203e4a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203e4e:	fec79de3          	bne	a5,a2,ffffffffc0203e48 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203e52:	8082                	ret

ffffffffc0203e54 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203e54:	ca19                	beqz	a2,ffffffffc0203e6a <memcpy+0x16>
ffffffffc0203e56:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203e58:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203e5a:	0585                	addi	a1,a1,1
ffffffffc0203e5c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203e60:	0785                	addi	a5,a5,1
ffffffffc0203e62:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203e66:	fec59ae3          	bne	a1,a2,ffffffffc0203e5a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203e6a:	8082                	ret

ffffffffc0203e6c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203e6c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e70:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203e72:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e76:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203e78:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e7c:	f022                	sd	s0,32(sp)
ffffffffc0203e7e:	ec26                	sd	s1,24(sp)
ffffffffc0203e80:	e84a                	sd	s2,16(sp)
ffffffffc0203e82:	f406                	sd	ra,40(sp)
ffffffffc0203e84:	e44e                	sd	s3,8(sp)
ffffffffc0203e86:	84aa                	mv	s1,a0
ffffffffc0203e88:	892e                	mv	s2,a1
ffffffffc0203e8a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203e8e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203e90:	03067e63          	bleu	a6,a2,ffffffffc0203ecc <printnum+0x60>
ffffffffc0203e94:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e96:	00805763          	blez	s0,ffffffffc0203ea4 <printnum+0x38>
ffffffffc0203e9a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203e9c:	85ca                	mv	a1,s2
ffffffffc0203e9e:	854e                	mv	a0,s3
ffffffffc0203ea0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203ea2:	fc65                	bnez	s0,ffffffffc0203e9a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ea4:	1a02                	slli	s4,s4,0x20
ffffffffc0203ea6:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203eaa:	00002797          	auipc	a5,0x2
ffffffffc0203eae:	22678793          	addi	a5,a5,550 # ffffffffc02060d0 <error_string+0x38>
ffffffffc0203eb2:	9a3e                	add	s4,s4,a5
}
ffffffffc0203eb4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203eb6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203eba:	70a2                	ld	ra,40(sp)
ffffffffc0203ebc:	69a2                	ld	s3,8(sp)
ffffffffc0203ebe:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ec0:	85ca                	mv	a1,s2
ffffffffc0203ec2:	8326                	mv	t1,s1
}
ffffffffc0203ec4:	6942                	ld	s2,16(sp)
ffffffffc0203ec6:	64e2                	ld	s1,24(sp)
ffffffffc0203ec8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203eca:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203ecc:	03065633          	divu	a2,a2,a6
ffffffffc0203ed0:	8722                	mv	a4,s0
ffffffffc0203ed2:	f9bff0ef          	jal	ra,ffffffffc0203e6c <printnum>
ffffffffc0203ed6:	b7f9                	j	ffffffffc0203ea4 <printnum+0x38>

ffffffffc0203ed8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203ed8:	7119                	addi	sp,sp,-128
ffffffffc0203eda:	f4a6                	sd	s1,104(sp)
ffffffffc0203edc:	f0ca                	sd	s2,96(sp)
ffffffffc0203ede:	e8d2                	sd	s4,80(sp)
ffffffffc0203ee0:	e4d6                	sd	s5,72(sp)
ffffffffc0203ee2:	e0da                	sd	s6,64(sp)
ffffffffc0203ee4:	fc5e                	sd	s7,56(sp)
ffffffffc0203ee6:	f862                	sd	s8,48(sp)
ffffffffc0203ee8:	f06a                	sd	s10,32(sp)
ffffffffc0203eea:	fc86                	sd	ra,120(sp)
ffffffffc0203eec:	f8a2                	sd	s0,112(sp)
ffffffffc0203eee:	ecce                	sd	s3,88(sp)
ffffffffc0203ef0:	f466                	sd	s9,40(sp)
ffffffffc0203ef2:	ec6e                	sd	s11,24(sp)
ffffffffc0203ef4:	892a                	mv	s2,a0
ffffffffc0203ef6:	84ae                	mv	s1,a1
ffffffffc0203ef8:	8d32                	mv	s10,a2
ffffffffc0203efa:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203efc:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203efe:	00002a17          	auipc	s4,0x2
ffffffffc0203f02:	042a0a13          	addi	s4,s4,66 # ffffffffc0205f40 <default_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203f06:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f0a:	00002c17          	auipc	s8,0x2
ffffffffc0203f0e:	18ec0c13          	addi	s8,s8,398 # ffffffffc0206098 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f12:	000d4503          	lbu	a0,0(s10)
ffffffffc0203f16:	02500793          	li	a5,37
ffffffffc0203f1a:	001d0413          	addi	s0,s10,1
ffffffffc0203f1e:	00f50e63          	beq	a0,a5,ffffffffc0203f3a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203f22:	c521                	beqz	a0,ffffffffc0203f6a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f24:	02500993          	li	s3,37
ffffffffc0203f28:	a011                	j	ffffffffc0203f2c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203f2a:	c121                	beqz	a0,ffffffffc0203f6a <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203f2c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f2e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203f30:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f32:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203f36:	ff351ae3          	bne	a0,s3,ffffffffc0203f2a <vprintfmt+0x52>
ffffffffc0203f3a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203f3e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203f42:	4981                	li	s3,0
ffffffffc0203f44:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203f46:	5cfd                	li	s9,-1
ffffffffc0203f48:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f4a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203f4e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f50:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203f54:	0ff6f693          	andi	a3,a3,255
ffffffffc0203f58:	00140d13          	addi	s10,s0,1
ffffffffc0203f5c:	20d5e563          	bltu	a1,a3,ffffffffc0204166 <vprintfmt+0x28e>
ffffffffc0203f60:	068a                	slli	a3,a3,0x2
ffffffffc0203f62:	96d2                	add	a3,a3,s4
ffffffffc0203f64:	4294                	lw	a3,0(a3)
ffffffffc0203f66:	96d2                	add	a3,a3,s4
ffffffffc0203f68:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203f6a:	70e6                	ld	ra,120(sp)
ffffffffc0203f6c:	7446                	ld	s0,112(sp)
ffffffffc0203f6e:	74a6                	ld	s1,104(sp)
ffffffffc0203f70:	7906                	ld	s2,96(sp)
ffffffffc0203f72:	69e6                	ld	s3,88(sp)
ffffffffc0203f74:	6a46                	ld	s4,80(sp)
ffffffffc0203f76:	6aa6                	ld	s5,72(sp)
ffffffffc0203f78:	6b06                	ld	s6,64(sp)
ffffffffc0203f7a:	7be2                	ld	s7,56(sp)
ffffffffc0203f7c:	7c42                	ld	s8,48(sp)
ffffffffc0203f7e:	7ca2                	ld	s9,40(sp)
ffffffffc0203f80:	7d02                	ld	s10,32(sp)
ffffffffc0203f82:	6de2                	ld	s11,24(sp)
ffffffffc0203f84:	6109                	addi	sp,sp,128
ffffffffc0203f86:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203f88:	4705                	li	a4,1
ffffffffc0203f8a:	008a8593          	addi	a1,s5,8
ffffffffc0203f8e:	01074463          	blt	a4,a6,ffffffffc0203f96 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203f92:	26080363          	beqz	a6,ffffffffc02041f8 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203f96:	000ab603          	ld	a2,0(s5)
ffffffffc0203f9a:	46c1                	li	a3,16
ffffffffc0203f9c:	8aae                	mv	s5,a1
ffffffffc0203f9e:	a06d                	j	ffffffffc0204048 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203fa0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203fa4:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fa6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203fa8:	b765                	j	ffffffffc0203f50 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203faa:	000aa503          	lw	a0,0(s5)
ffffffffc0203fae:	85a6                	mv	a1,s1
ffffffffc0203fb0:	0aa1                	addi	s5,s5,8
ffffffffc0203fb2:	9902                	jalr	s2
            break;
ffffffffc0203fb4:	bfb9                	j	ffffffffc0203f12 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203fb6:	4705                	li	a4,1
ffffffffc0203fb8:	008a8993          	addi	s3,s5,8
ffffffffc0203fbc:	01074463          	blt	a4,a6,ffffffffc0203fc4 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203fc0:	22080463          	beqz	a6,ffffffffc02041e8 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203fc4:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203fc8:	24044463          	bltz	s0,ffffffffc0204210 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203fcc:	8622                	mv	a2,s0
ffffffffc0203fce:	8ace                	mv	s5,s3
ffffffffc0203fd0:	46a9                	li	a3,10
ffffffffc0203fd2:	a89d                	j	ffffffffc0204048 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203fd4:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fd8:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203fda:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203fdc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203fe0:	8fb5                	xor	a5,a5,a3
ffffffffc0203fe2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fe6:	1ad74363          	blt	a4,a3,ffffffffc020418c <vprintfmt+0x2b4>
ffffffffc0203fea:	00369793          	slli	a5,a3,0x3
ffffffffc0203fee:	97e2                	add	a5,a5,s8
ffffffffc0203ff0:	639c                	ld	a5,0(a5)
ffffffffc0203ff2:	18078d63          	beqz	a5,ffffffffc020418c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203ff6:	86be                	mv	a3,a5
ffffffffc0203ff8:	00002617          	auipc	a2,0x2
ffffffffc0203ffc:	18860613          	addi	a2,a2,392 # ffffffffc0206180 <error_string+0xe8>
ffffffffc0204000:	85a6                	mv	a1,s1
ffffffffc0204002:	854a                	mv	a0,s2
ffffffffc0204004:	240000ef          	jal	ra,ffffffffc0204244 <printfmt>
ffffffffc0204008:	b729                	j	ffffffffc0203f12 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020400a:	00144603          	lbu	a2,1(s0)
ffffffffc020400e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204010:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204012:	bf3d                	j	ffffffffc0203f50 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204014:	4705                	li	a4,1
ffffffffc0204016:	008a8593          	addi	a1,s5,8
ffffffffc020401a:	01074463          	blt	a4,a6,ffffffffc0204022 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020401e:	1e080263          	beqz	a6,ffffffffc0204202 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204022:	000ab603          	ld	a2,0(s5)
ffffffffc0204026:	46a1                	li	a3,8
ffffffffc0204028:	8aae                	mv	s5,a1
ffffffffc020402a:	a839                	j	ffffffffc0204048 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020402c:	03000513          	li	a0,48
ffffffffc0204030:	85a6                	mv	a1,s1
ffffffffc0204032:	e03e                	sd	a5,0(sp)
ffffffffc0204034:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204036:	85a6                	mv	a1,s1
ffffffffc0204038:	07800513          	li	a0,120
ffffffffc020403c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020403e:	0aa1                	addi	s5,s5,8
ffffffffc0204040:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204044:	6782                	ld	a5,0(sp)
ffffffffc0204046:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204048:	876e                	mv	a4,s11
ffffffffc020404a:	85a6                	mv	a1,s1
ffffffffc020404c:	854a                	mv	a0,s2
ffffffffc020404e:	e1fff0ef          	jal	ra,ffffffffc0203e6c <printnum>
            break;
ffffffffc0204052:	b5c1                	j	ffffffffc0203f12 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204054:	000ab603          	ld	a2,0(s5)
ffffffffc0204058:	0aa1                	addi	s5,s5,8
ffffffffc020405a:	1c060663          	beqz	a2,ffffffffc0204226 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020405e:	00160413          	addi	s0,a2,1
ffffffffc0204062:	17b05c63          	blez	s11,ffffffffc02041da <vprintfmt+0x302>
ffffffffc0204066:	02d00593          	li	a1,45
ffffffffc020406a:	14b79263          	bne	a5,a1,ffffffffc02041ae <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020406e:	00064783          	lbu	a5,0(a2)
ffffffffc0204072:	0007851b          	sext.w	a0,a5
ffffffffc0204076:	c905                	beqz	a0,ffffffffc02040a6 <vprintfmt+0x1ce>
ffffffffc0204078:	000cc563          	bltz	s9,ffffffffc0204082 <vprintfmt+0x1aa>
ffffffffc020407c:	3cfd                	addiw	s9,s9,-1
ffffffffc020407e:	036c8263          	beq	s9,s6,ffffffffc02040a2 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204082:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204084:	18098463          	beqz	s3,ffffffffc020420c <vprintfmt+0x334>
ffffffffc0204088:	3781                	addiw	a5,a5,-32
ffffffffc020408a:	18fbf163          	bleu	a5,s7,ffffffffc020420c <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020408e:	03f00513          	li	a0,63
ffffffffc0204092:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204094:	0405                	addi	s0,s0,1
ffffffffc0204096:	fff44783          	lbu	a5,-1(s0)
ffffffffc020409a:	3dfd                	addiw	s11,s11,-1
ffffffffc020409c:	0007851b          	sext.w	a0,a5
ffffffffc02040a0:	fd61                	bnez	a0,ffffffffc0204078 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02040a2:	e7b058e3          	blez	s11,ffffffffc0203f12 <vprintfmt+0x3a>
ffffffffc02040a6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02040a8:	85a6                	mv	a1,s1
ffffffffc02040aa:	02000513          	li	a0,32
ffffffffc02040ae:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02040b0:	e60d81e3          	beqz	s11,ffffffffc0203f12 <vprintfmt+0x3a>
ffffffffc02040b4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02040b6:	85a6                	mv	a1,s1
ffffffffc02040b8:	02000513          	li	a0,32
ffffffffc02040bc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02040be:	fe0d94e3          	bnez	s11,ffffffffc02040a6 <vprintfmt+0x1ce>
ffffffffc02040c2:	bd81                	j	ffffffffc0203f12 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02040c4:	4705                	li	a4,1
ffffffffc02040c6:	008a8593          	addi	a1,s5,8
ffffffffc02040ca:	01074463          	blt	a4,a6,ffffffffc02040d2 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02040ce:	12080063          	beqz	a6,ffffffffc02041ee <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02040d2:	000ab603          	ld	a2,0(s5)
ffffffffc02040d6:	46a9                	li	a3,10
ffffffffc02040d8:	8aae                	mv	s5,a1
ffffffffc02040da:	b7bd                	j	ffffffffc0204048 <vprintfmt+0x170>
ffffffffc02040dc:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02040e0:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040e4:	846a                	mv	s0,s10
ffffffffc02040e6:	b5ad                	j	ffffffffc0203f50 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02040e8:	85a6                	mv	a1,s1
ffffffffc02040ea:	02500513          	li	a0,37
ffffffffc02040ee:	9902                	jalr	s2
            break;
ffffffffc02040f0:	b50d                	j	ffffffffc0203f12 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02040f2:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02040f6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02040fa:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040fc:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02040fe:	e40dd9e3          	bgez	s11,ffffffffc0203f50 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204102:	8de6                	mv	s11,s9
ffffffffc0204104:	5cfd                	li	s9,-1
ffffffffc0204106:	b5a9                	j	ffffffffc0203f50 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204108:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020410c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204110:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204112:	bd3d                	j	ffffffffc0203f50 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204114:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204118:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020411c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020411e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204122:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204126:	fcd56ce3          	bltu	a0,a3,ffffffffc02040fe <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020412a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020412c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204130:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204134:	0196873b          	addw	a4,a3,s9
ffffffffc0204138:	0017171b          	slliw	a4,a4,0x1
ffffffffc020413c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204140:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204144:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204148:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020414c:	fcd57fe3          	bleu	a3,a0,ffffffffc020412a <vprintfmt+0x252>
ffffffffc0204150:	b77d                	j	ffffffffc02040fe <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204152:	fffdc693          	not	a3,s11
ffffffffc0204156:	96fd                	srai	a3,a3,0x3f
ffffffffc0204158:	00ddfdb3          	and	s11,s11,a3
ffffffffc020415c:	00144603          	lbu	a2,1(s0)
ffffffffc0204160:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204162:	846a                	mv	s0,s10
ffffffffc0204164:	b3f5                	j	ffffffffc0203f50 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204166:	85a6                	mv	a1,s1
ffffffffc0204168:	02500513          	li	a0,37
ffffffffc020416c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020416e:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204172:	02500793          	li	a5,37
ffffffffc0204176:	8d22                	mv	s10,s0
ffffffffc0204178:	d8f70de3          	beq	a4,a5,ffffffffc0203f12 <vprintfmt+0x3a>
ffffffffc020417c:	02500713          	li	a4,37
ffffffffc0204180:	1d7d                	addi	s10,s10,-1
ffffffffc0204182:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204186:	fee79de3          	bne	a5,a4,ffffffffc0204180 <vprintfmt+0x2a8>
ffffffffc020418a:	b361                	j	ffffffffc0203f12 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020418c:	00002617          	auipc	a2,0x2
ffffffffc0204190:	fe460613          	addi	a2,a2,-28 # ffffffffc0206170 <error_string+0xd8>
ffffffffc0204194:	85a6                	mv	a1,s1
ffffffffc0204196:	854a                	mv	a0,s2
ffffffffc0204198:	0ac000ef          	jal	ra,ffffffffc0204244 <printfmt>
ffffffffc020419c:	bb9d                	j	ffffffffc0203f12 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020419e:	00002617          	auipc	a2,0x2
ffffffffc02041a2:	fca60613          	addi	a2,a2,-54 # ffffffffc0206168 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02041a6:	00002417          	auipc	s0,0x2
ffffffffc02041aa:	fc340413          	addi	s0,s0,-61 # ffffffffc0206169 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041ae:	8532                	mv	a0,a2
ffffffffc02041b0:	85e6                	mv	a1,s9
ffffffffc02041b2:	e032                	sd	a2,0(sp)
ffffffffc02041b4:	e43e                	sd	a5,8(sp)
ffffffffc02041b6:	c0dff0ef          	jal	ra,ffffffffc0203dc2 <strnlen>
ffffffffc02041ba:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02041be:	6602                	ld	a2,0(sp)
ffffffffc02041c0:	01b05d63          	blez	s11,ffffffffc02041da <vprintfmt+0x302>
ffffffffc02041c4:	67a2                	ld	a5,8(sp)
ffffffffc02041c6:	2781                	sext.w	a5,a5
ffffffffc02041c8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02041ca:	6522                	ld	a0,8(sp)
ffffffffc02041cc:	85a6                	mv	a1,s1
ffffffffc02041ce:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041d0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02041d2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041d4:	6602                	ld	a2,0(sp)
ffffffffc02041d6:	fe0d9ae3          	bnez	s11,ffffffffc02041ca <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041da:	00064783          	lbu	a5,0(a2)
ffffffffc02041de:	0007851b          	sext.w	a0,a5
ffffffffc02041e2:	e8051be3          	bnez	a0,ffffffffc0204078 <vprintfmt+0x1a0>
ffffffffc02041e6:	b335                	j	ffffffffc0203f12 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02041e8:	000aa403          	lw	s0,0(s5)
ffffffffc02041ec:	bbf1                	j	ffffffffc0203fc8 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02041ee:	000ae603          	lwu	a2,0(s5)
ffffffffc02041f2:	46a9                	li	a3,10
ffffffffc02041f4:	8aae                	mv	s5,a1
ffffffffc02041f6:	bd89                	j	ffffffffc0204048 <vprintfmt+0x170>
ffffffffc02041f8:	000ae603          	lwu	a2,0(s5)
ffffffffc02041fc:	46c1                	li	a3,16
ffffffffc02041fe:	8aae                	mv	s5,a1
ffffffffc0204200:	b5a1                	j	ffffffffc0204048 <vprintfmt+0x170>
ffffffffc0204202:	000ae603          	lwu	a2,0(s5)
ffffffffc0204206:	46a1                	li	a3,8
ffffffffc0204208:	8aae                	mv	s5,a1
ffffffffc020420a:	bd3d                	j	ffffffffc0204048 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020420c:	9902                	jalr	s2
ffffffffc020420e:	b559                	j	ffffffffc0204094 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204210:	85a6                	mv	a1,s1
ffffffffc0204212:	02d00513          	li	a0,45
ffffffffc0204216:	e03e                	sd	a5,0(sp)
ffffffffc0204218:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020421a:	8ace                	mv	s5,s3
ffffffffc020421c:	40800633          	neg	a2,s0
ffffffffc0204220:	46a9                	li	a3,10
ffffffffc0204222:	6782                	ld	a5,0(sp)
ffffffffc0204224:	b515                	j	ffffffffc0204048 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204226:	01b05663          	blez	s11,ffffffffc0204232 <vprintfmt+0x35a>
ffffffffc020422a:	02d00693          	li	a3,45
ffffffffc020422e:	f6d798e3          	bne	a5,a3,ffffffffc020419e <vprintfmt+0x2c6>
ffffffffc0204232:	00002417          	auipc	s0,0x2
ffffffffc0204236:	f3740413          	addi	s0,s0,-201 # ffffffffc0206169 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020423a:	02800513          	li	a0,40
ffffffffc020423e:	02800793          	li	a5,40
ffffffffc0204242:	bd1d                	j	ffffffffc0204078 <vprintfmt+0x1a0>

ffffffffc0204244 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204244:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204246:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020424a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020424c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020424e:	ec06                	sd	ra,24(sp)
ffffffffc0204250:	f83a                	sd	a4,48(sp)
ffffffffc0204252:	fc3e                	sd	a5,56(sp)
ffffffffc0204254:	e0c2                	sd	a6,64(sp)
ffffffffc0204256:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204258:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020425a:	c7fff0ef          	jal	ra,ffffffffc0203ed8 <vprintfmt>
}
ffffffffc020425e:	60e2                	ld	ra,24(sp)
ffffffffc0204260:	6161                	addi	sp,sp,80
ffffffffc0204262:	8082                	ret

ffffffffc0204264 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204264:	715d                	addi	sp,sp,-80
ffffffffc0204266:	e486                	sd	ra,72(sp)
ffffffffc0204268:	e0a2                	sd	s0,64(sp)
ffffffffc020426a:	fc26                	sd	s1,56(sp)
ffffffffc020426c:	f84a                	sd	s2,48(sp)
ffffffffc020426e:	f44e                	sd	s3,40(sp)
ffffffffc0204270:	f052                	sd	s4,32(sp)
ffffffffc0204272:	ec56                	sd	s5,24(sp)
ffffffffc0204274:	e85a                	sd	s6,16(sp)
ffffffffc0204276:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0204278:	c901                	beqz	a0,ffffffffc0204288 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020427a:	85aa                	mv	a1,a0
ffffffffc020427c:	00002517          	auipc	a0,0x2
ffffffffc0204280:	f0450513          	addi	a0,a0,-252 # ffffffffc0206180 <error_string+0xe8>
ffffffffc0204284:	e3bfb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc0204288:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020428a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020428c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020428e:	4aa9                	li	s5,10
ffffffffc0204290:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204292:	0000db97          	auipc	s7,0xd
ffffffffc0204296:	daeb8b93          	addi	s7,s7,-594 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020429a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020429e:	e59fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02042a2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02042a4:	00054b63          	bltz	a0,ffffffffc02042ba <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042a8:	00a95b63          	ble	a0,s2,ffffffffc02042be <readline+0x5a>
ffffffffc02042ac:	029a5463          	ble	s1,s4,ffffffffc02042d4 <readline+0x70>
        c = getchar();
ffffffffc02042b0:	e47fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02042b4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02042b6:	fe0559e3          	bgez	a0,ffffffffc02042a8 <readline+0x44>
            return NULL;
ffffffffc02042ba:	4501                	li	a0,0
ffffffffc02042bc:	a099                	j	ffffffffc0204302 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02042be:	03341463          	bne	s0,s3,ffffffffc02042e6 <readline+0x82>
ffffffffc02042c2:	e8b9                	bnez	s1,ffffffffc0204318 <readline+0xb4>
        c = getchar();
ffffffffc02042c4:	e33fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02042c8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02042ca:	fe0548e3          	bltz	a0,ffffffffc02042ba <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042ce:	fea958e3          	ble	a0,s2,ffffffffc02042be <readline+0x5a>
ffffffffc02042d2:	4481                	li	s1,0
            cputchar(c);
ffffffffc02042d4:	8522                	mv	a0,s0
ffffffffc02042d6:	e1dfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc02042da:	009b87b3          	add	a5,s7,s1
ffffffffc02042de:	00878023          	sb	s0,0(a5)
ffffffffc02042e2:	2485                	addiw	s1,s1,1
ffffffffc02042e4:	bf6d                	j	ffffffffc020429e <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02042e6:	01540463          	beq	s0,s5,ffffffffc02042ee <readline+0x8a>
ffffffffc02042ea:	fb641ae3          	bne	s0,s6,ffffffffc020429e <readline+0x3a>
            cputchar(c);
ffffffffc02042ee:	8522                	mv	a0,s0
ffffffffc02042f0:	e03fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc02042f4:	0000d517          	auipc	a0,0xd
ffffffffc02042f8:	d4c50513          	addi	a0,a0,-692 # ffffffffc0211040 <buf>
ffffffffc02042fc:	94aa                	add	s1,s1,a0
ffffffffc02042fe:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204302:	60a6                	ld	ra,72(sp)
ffffffffc0204304:	6406                	ld	s0,64(sp)
ffffffffc0204306:	74e2                	ld	s1,56(sp)
ffffffffc0204308:	7942                	ld	s2,48(sp)
ffffffffc020430a:	79a2                	ld	s3,40(sp)
ffffffffc020430c:	7a02                	ld	s4,32(sp)
ffffffffc020430e:	6ae2                	ld	s5,24(sp)
ffffffffc0204310:	6b42                	ld	s6,16(sp)
ffffffffc0204312:	6ba2                	ld	s7,8(sp)
ffffffffc0204314:	6161                	addi	sp,sp,80
ffffffffc0204316:	8082                	ret
            cputchar(c);
ffffffffc0204318:	4521                	li	a0,8
ffffffffc020431a:	dd9fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc020431e:	34fd                	addiw	s1,s1,-1
ffffffffc0204320:	bfbd                	j	ffffffffc020429e <readline+0x3a>
