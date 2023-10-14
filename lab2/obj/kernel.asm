
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206018 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	44260613          	addi	a2,a2,1090 # ffffffffc0206480 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	600010ef          	jal	ra,ffffffffc020164e <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0201b88 <etext>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	13c000ef          	jal	ra,ffffffffc020019e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	12b000ef          	jal	ra,ffffffffc0200994 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	622010ef          	jal	ra,ffffffffc02016cc <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	5ee010ef          	jal	ra,ffffffffc02016cc <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013e:	00006317          	auipc	t1,0x6
ffffffffc0200142:	2da30313          	addi	t1,t1,730 # ffffffffc0206418 <is_panic>
ffffffffc0200146:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020014a:	715d                	addi	sp,sp,-80
ffffffffc020014c:	ec06                	sd	ra,24(sp)
ffffffffc020014e:	e822                	sd	s0,16(sp)
ffffffffc0200150:	f436                	sd	a3,40(sp)
ffffffffc0200152:	f83a                	sd	a4,48(sp)
ffffffffc0200154:	fc3e                	sd	a5,56(sp)
ffffffffc0200156:	e0c2                	sd	a6,64(sp)
ffffffffc0200158:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020015a:	02031c63          	bnez	t1,ffffffffc0200192 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015e:	4785                	li	a5,1
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	00006717          	auipc	a4,0x6
ffffffffc0200166:	2af72b23          	sw	a5,694(a4) # ffffffffc0206418 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016a:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020016c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00002517          	auipc	a0,0x2
ffffffffc0200174:	a3850513          	addi	a0,a0,-1480 # ffffffffc0201ba8 <etext+0x20>
    va_start(ap, fmt);
ffffffffc0200178:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017a:	f3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020017e:	65a2                	ld	a1,8(sp)
ffffffffc0200180:	8522                	mv	a0,s0
ffffffffc0200182:	f15ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc0200186:	00002517          	auipc	a0,0x2
ffffffffc020018a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0201cc0 <etext+0x138>
ffffffffc020018e:	f29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200192:	2d2000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200196:	4501                	li	a0,0
ffffffffc0200198:	132000ef          	jal	ra,ffffffffc02002ca <kmonitor>
ffffffffc020019c:	bfed                	j	ffffffffc0200196 <__panic+0x58>

ffffffffc020019e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001a0:	00002517          	auipc	a0,0x2
ffffffffc02001a4:	a5850513          	addi	a0,a0,-1448 # ffffffffc0201bf8 <etext+0x70>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8858593          	addi	a1,a1,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	00002517          	auipc	a0,0x2
ffffffffc02001ba:	a6250513          	addi	a0,a0,-1438 # ffffffffc0201c18 <etext+0x90>
ffffffffc02001be:	ef9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00002597          	auipc	a1,0x2
ffffffffc02001c6:	9c658593          	addi	a1,a1,-1594 # ffffffffc0201b88 <etext>
ffffffffc02001ca:	00002517          	auipc	a0,0x2
ffffffffc02001ce:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0201c38 <etext+0xb0>
ffffffffc02001d2:	ee5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00006597          	auipc	a1,0x6
ffffffffc02001da:	e4258593          	addi	a1,a1,-446 # ffffffffc0206018 <edata>
ffffffffc02001de:	00002517          	auipc	a0,0x2
ffffffffc02001e2:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0201c58 <etext+0xd0>
ffffffffc02001e6:	ed1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00006597          	auipc	a1,0x6
ffffffffc02001ee:	29658593          	addi	a1,a1,662 # ffffffffc0206480 <end>
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	a8650513          	addi	a0,a0,-1402 # ffffffffc0201c78 <etext+0xf0>
ffffffffc02001fa:	ebdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001fe:	00006597          	auipc	a1,0x6
ffffffffc0200202:	68158593          	addi	a1,a1,1665 # ffffffffc020687f <end+0x3ff>
ffffffffc0200206:	00000797          	auipc	a5,0x0
ffffffffc020020a:	e3078793          	addi	a5,a5,-464 # ffffffffc0200036 <kern_init>
ffffffffc020020e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200212:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200218:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021c:	95be                	add	a1,a1,a5
ffffffffc020021e:	85a9                	srai	a1,a1,0xa
ffffffffc0200220:	00002517          	auipc	a0,0x2
ffffffffc0200224:	a7850513          	addi	a0,a0,-1416 # ffffffffc0201c98 <etext+0x110>
}
ffffffffc0200228:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020022a:	e8dff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020022e <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020022e:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200230:	00002617          	auipc	a2,0x2
ffffffffc0200234:	99860613          	addi	a2,a2,-1640 # ffffffffc0201bc8 <etext+0x40>
ffffffffc0200238:	04e00593          	li	a1,78
ffffffffc020023c:	00002517          	auipc	a0,0x2
ffffffffc0200240:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201be0 <etext+0x58>
void print_stackframe(void) {
ffffffffc0200244:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200246:	ef9ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020024a <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020024c:	00002617          	auipc	a2,0x2
ffffffffc0200250:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0201da8 <commands+0xe0>
ffffffffc0200254:	00002597          	auipc	a1,0x2
ffffffffc0200258:	b7458593          	addi	a1,a1,-1164 # ffffffffc0201dc8 <commands+0x100>
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	b7450513          	addi	a0,a0,-1164 # ffffffffc0201dd0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200266:	e51ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020026a:	00002617          	auipc	a2,0x2
ffffffffc020026e:	b7660613          	addi	a2,a2,-1162 # ffffffffc0201de0 <commands+0x118>
ffffffffc0200272:	00002597          	auipc	a1,0x2
ffffffffc0200276:	b9658593          	addi	a1,a1,-1130 # ffffffffc0201e08 <commands+0x140>
ffffffffc020027a:	00002517          	auipc	a0,0x2
ffffffffc020027e:	b5650513          	addi	a0,a0,-1194 # ffffffffc0201dd0 <commands+0x108>
ffffffffc0200282:	e35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200286:	00002617          	auipc	a2,0x2
ffffffffc020028a:	b9260613          	addi	a2,a2,-1134 # ffffffffc0201e18 <commands+0x150>
ffffffffc020028e:	00002597          	auipc	a1,0x2
ffffffffc0200292:	baa58593          	addi	a1,a1,-1110 # ffffffffc0201e38 <commands+0x170>
ffffffffc0200296:	00002517          	auipc	a0,0x2
ffffffffc020029a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0201dd0 <commands+0x108>
ffffffffc020029e:	e19ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc02002a2:	60a2                	ld	ra,8(sp)
ffffffffc02002a4:	4501                	li	a0,0
ffffffffc02002a6:	0141                	addi	sp,sp,16
ffffffffc02002a8:	8082                	ret

ffffffffc02002aa <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002aa:	1141                	addi	sp,sp,-16
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ae:	ef1ff0ef          	jal	ra,ffffffffc020019e <print_kerninfo>
    return 0;
}
ffffffffc02002b2:	60a2                	ld	ra,8(sp)
ffffffffc02002b4:	4501                	li	a0,0
ffffffffc02002b6:	0141                	addi	sp,sp,16
ffffffffc02002b8:	8082                	ret

ffffffffc02002ba <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ba:	1141                	addi	sp,sp,-16
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002be:	f71ff0ef          	jal	ra,ffffffffc020022e <print_stackframe>
    return 0;
}
ffffffffc02002c2:	60a2                	ld	ra,8(sp)
ffffffffc02002c4:	4501                	li	a0,0
ffffffffc02002c6:	0141                	addi	sp,sp,16
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002ca:	7115                	addi	sp,sp,-224
ffffffffc02002cc:	e962                	sd	s8,144(sp)
ffffffffc02002ce:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002d0:	00002517          	auipc	a0,0x2
ffffffffc02002d4:	a4050513          	addi	a0,a0,-1472 # ffffffffc0201d10 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002d8:	ed86                	sd	ra,216(sp)
ffffffffc02002da:	e9a2                	sd	s0,208(sp)
ffffffffc02002dc:	e5a6                	sd	s1,200(sp)
ffffffffc02002de:	e1ca                	sd	s2,192(sp)
ffffffffc02002e0:	fd4e                	sd	s3,184(sp)
ffffffffc02002e2:	f952                	sd	s4,176(sp)
ffffffffc02002e4:	f556                	sd	s5,168(sp)
ffffffffc02002e6:	f15a                	sd	s6,160(sp)
ffffffffc02002e8:	ed5e                	sd	s7,152(sp)
ffffffffc02002ea:	e566                	sd	s9,136(sp)
ffffffffc02002ec:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ee:	dc9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002f2:	00002517          	auipc	a0,0x2
ffffffffc02002f6:	a4650513          	addi	a0,a0,-1466 # ffffffffc0201d38 <commands+0x70>
ffffffffc02002fa:	dbdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fe:	000c0563          	beqz	s8,ffffffffc0200308 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200302:	8562                	mv	a0,s8
ffffffffc0200304:	346000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc0200308:	00002c97          	auipc	s9,0x2
ffffffffc020030c:	9c0c8c93          	addi	s9,s9,-1600 # ffffffffc0201cc8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200310:	00002997          	auipc	s3,0x2
ffffffffc0200314:	a5098993          	addi	s3,s3,-1456 # ffffffffc0201d60 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00002917          	auipc	s2,0x2
ffffffffc020031c:	a5090913          	addi	s2,s2,-1456 # ffffffffc0201d68 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200320:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200322:	00002b17          	auipc	s6,0x2
ffffffffc0200326:	a4eb0b13          	addi	s6,s6,-1458 # ffffffffc0201d70 <commands+0xa8>
    if (argc == 0) {
ffffffffc020032a:	00002a97          	auipc	s5,0x2
ffffffffc020032e:	a9ea8a93          	addi	s5,s5,-1378 # ffffffffc0201dc8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200332:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200334:	854e                	mv	a0,s3
ffffffffc0200336:	722010ef          	jal	ra,ffffffffc0201a58 <readline>
ffffffffc020033a:	842a                	mv	s0,a0
ffffffffc020033c:	dd65                	beqz	a0,ffffffffc0200334 <kmonitor+0x6a>
ffffffffc020033e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200342:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	c999                	beqz	a1,ffffffffc020035a <kmonitor+0x90>
ffffffffc0200346:	854a                	mv	a0,s2
ffffffffc0200348:	2e8010ef          	jal	ra,ffffffffc0201630 <strchr>
ffffffffc020034c:	c925                	beqz	a0,ffffffffc02003bc <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc020034e:	00144583          	lbu	a1,1(s0)
ffffffffc0200352:	00040023          	sb	zero,0(s0)
ffffffffc0200356:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200358:	f5fd                	bnez	a1,ffffffffc0200346 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020035a:	dce9                	beqz	s1,ffffffffc0200334 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	6582                	ld	a1,0(sp)
ffffffffc020035e:	00002d17          	auipc	s10,0x2
ffffffffc0200362:	96ad0d13          	addi	s10,s10,-1686 # ffffffffc0201cc8 <commands>
    if (argc == 0) {
ffffffffc0200366:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200368:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
ffffffffc020036c:	29a010ef          	jal	ra,ffffffffc0201606 <strcmp>
ffffffffc0200370:	c919                	beqz	a0,ffffffffc0200386 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	2405                	addiw	s0,s0,1
ffffffffc0200374:	09740463          	beq	s0,s7,ffffffffc02003fc <kmonitor+0x132>
ffffffffc0200378:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	6582                	ld	a1,0(sp)
ffffffffc020037e:	0d61                	addi	s10,s10,24
ffffffffc0200380:	286010ef          	jal	ra,ffffffffc0201606 <strcmp>
ffffffffc0200384:	f57d                	bnez	a0,ffffffffc0200372 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200386:	00141793          	slli	a5,s0,0x1
ffffffffc020038a:	97a2                	add	a5,a5,s0
ffffffffc020038c:	078e                	slli	a5,a5,0x3
ffffffffc020038e:	97e6                	add	a5,a5,s9
ffffffffc0200390:	6b9c                	ld	a5,16(a5)
ffffffffc0200392:	8662                	mv	a2,s8
ffffffffc0200394:	002c                	addi	a1,sp,8
ffffffffc0200396:	fff4851b          	addiw	a0,s1,-1
ffffffffc020039a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020039c:	f8055ce3          	bgez	a0,ffffffffc0200334 <kmonitor+0x6a>
}
ffffffffc02003a0:	60ee                	ld	ra,216(sp)
ffffffffc02003a2:	644e                	ld	s0,208(sp)
ffffffffc02003a4:	64ae                	ld	s1,200(sp)
ffffffffc02003a6:	690e                	ld	s2,192(sp)
ffffffffc02003a8:	79ea                	ld	s3,184(sp)
ffffffffc02003aa:	7a4a                	ld	s4,176(sp)
ffffffffc02003ac:	7aaa                	ld	s5,168(sp)
ffffffffc02003ae:	7b0a                	ld	s6,160(sp)
ffffffffc02003b0:	6bea                	ld	s7,152(sp)
ffffffffc02003b2:	6c4a                	ld	s8,144(sp)
ffffffffc02003b4:	6caa                	ld	s9,136(sp)
ffffffffc02003b6:	6d0a                	ld	s10,128(sp)
ffffffffc02003b8:	612d                	addi	sp,sp,224
ffffffffc02003ba:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003bc:	00044783          	lbu	a5,0(s0)
ffffffffc02003c0:	dfc9                	beqz	a5,ffffffffc020035a <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02003c2:	03448863          	beq	s1,s4,ffffffffc02003f2 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02003c6:	00349793          	slli	a5,s1,0x3
ffffffffc02003ca:	0118                	addi	a4,sp,128
ffffffffc02003cc:	97ba                	add	a5,a5,a4
ffffffffc02003ce:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d6:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d8:	e591                	bnez	a1,ffffffffc02003e4 <kmonitor+0x11a>
ffffffffc02003da:	b749                	j	ffffffffc020035c <kmonitor+0x92>
            buf ++;
ffffffffc02003dc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003de:	00044583          	lbu	a1,0(s0)
ffffffffc02003e2:	ddad                	beqz	a1,ffffffffc020035c <kmonitor+0x92>
ffffffffc02003e4:	854a                	mv	a0,s2
ffffffffc02003e6:	24a010ef          	jal	ra,ffffffffc0201630 <strchr>
ffffffffc02003ea:	d96d                	beqz	a0,ffffffffc02003dc <kmonitor+0x112>
ffffffffc02003ec:	00044583          	lbu	a1,0(s0)
ffffffffc02003f0:	bf91                	j	ffffffffc0200344 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003f2:	45c1                	li	a1,16
ffffffffc02003f4:	855a                	mv	a0,s6
ffffffffc02003f6:	cc1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003fa:	b7f1                	j	ffffffffc02003c6 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003fc:	6582                	ld	a1,0(sp)
ffffffffc02003fe:	00002517          	auipc	a0,0x2
ffffffffc0200402:	99250513          	addi	a0,a0,-1646 # ffffffffc0201d90 <commands+0xc8>
ffffffffc0200406:	cb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc020040a:	b72d                	j	ffffffffc0200334 <kmonitor+0x6a>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	70e010ef          	jal	ra,ffffffffc0201b32 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007bb23          	sd	zero,22(a5) # ffffffffc0206440 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	a1650513          	addi	a0,a0,-1514 # ffffffffc0201e48 <commands+0x180>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	6e60106f          	j	ffffffffc0201b32 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	6c00106f          	j	ffffffffc0201b16 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	6f40106f          	j	ffffffffc0201b4e <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	3a678793          	addi	a5,a5,934 # ffffffffc0200814 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0201fe0 <commands+0x318>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	b6450513          	addi	a0,a0,-1180 # ffffffffc0201ff8 <commands+0x330>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0202010 <commands+0x348>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	b7850513          	addi	a0,a0,-1160 # ffffffffc0202028 <commands+0x360>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	b8250513          	addi	a0,a0,-1150 # ffffffffc0202040 <commands+0x378>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0202058 <commands+0x390>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	b9650513          	addi	a0,a0,-1130 # ffffffffc0202070 <commands+0x3a8>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	ba050513          	addi	a0,a0,-1120 # ffffffffc0202088 <commands+0x3c0>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	baa50513          	addi	a0,a0,-1110 # ffffffffc02020a0 <commands+0x3d8>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	bb450513          	addi	a0,a0,-1100 # ffffffffc02020b8 <commands+0x3f0>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	bbe50513          	addi	a0,a0,-1090 # ffffffffc02020d0 <commands+0x408>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	bc850513          	addi	a0,a0,-1080 # ffffffffc02020e8 <commands+0x420>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	bd250513          	addi	a0,a0,-1070 # ffffffffc0202100 <commands+0x438>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0202118 <commands+0x450>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	be650513          	addi	a0,a0,-1050 # ffffffffc0202130 <commands+0x468>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0202148 <commands+0x480>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0202160 <commands+0x498>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	c0450513          	addi	a0,a0,-1020 # ffffffffc0202178 <commands+0x4b0>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0202190 <commands+0x4c8>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	c1850513          	addi	a0,a0,-1000 # ffffffffc02021a8 <commands+0x4e0>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	c2250513          	addi	a0,a0,-990 # ffffffffc02021c0 <commands+0x4f8>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	c2c50513          	addi	a0,a0,-980 # ffffffffc02021d8 <commands+0x510>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	c3650513          	addi	a0,a0,-970 # ffffffffc02021f0 <commands+0x528>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	c4050513          	addi	a0,a0,-960 # ffffffffc0202208 <commands+0x540>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	c4a50513          	addi	a0,a0,-950 # ffffffffc0202220 <commands+0x558>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	c5450513          	addi	a0,a0,-940 # ffffffffc0202238 <commands+0x570>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	c5e50513          	addi	a0,a0,-930 # ffffffffc0202250 <commands+0x588>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	c6850513          	addi	a0,a0,-920 # ffffffffc0202268 <commands+0x5a0>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	c7250513          	addi	a0,a0,-910 # ffffffffc0202280 <commands+0x5b8>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	c7c50513          	addi	a0,a0,-900 # ffffffffc0202298 <commands+0x5d0>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	c8650513          	addi	a0,a0,-890 # ffffffffc02022b0 <commands+0x5e8>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	c8c50513          	addi	a0,a0,-884 # ffffffffc02022c8 <commands+0x600>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	c8e50513          	addi	a0,a0,-882 # ffffffffc02022e0 <commands+0x618>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	c8e50513          	addi	a0,a0,-882 # ffffffffc02022f8 <commands+0x630>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	c9650513          	addi	a0,a0,-874 # ffffffffc0202310 <commands+0x648>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	c9e50513          	addi	a0,a0,-866 # ffffffffc0202328 <commands+0x660>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	ca250513          	addi	a0,a0,-862 # ffffffffc0202340 <commands+0x678>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	06f76f63          	bltu	a4,a5,ffffffffc0200736 <interrupt_handler+0x8a>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	7a870713          	addi	a4,a4,1960 # ffffffffc0201e64 <commands+0x19c>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00002517          	auipc	a0,0x2
ffffffffc02006d2:	8c250513          	addi	a0,a0,-1854 # ffffffffc0201f90 <commands+0x2c8>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00002517          	auipc	a0,0x2
ffffffffc02006de:	89650513          	addi	a0,a0,-1898 # ffffffffc0201f70 <commands+0x2a8>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00002517          	auipc	a0,0x2
ffffffffc02006ea:	84a50513          	addi	a0,a0,-1974 # ffffffffc0201f30 <commands+0x268>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02006f2:	00002517          	auipc	a0,0x2
ffffffffc02006f6:	85e50513          	addi	a0,a0,-1954 # ffffffffc0201f50 <commands+0x288>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02006fe:	00002517          	auipc	a0,0x2
ffffffffc0200702:	8c250513          	addi	a0,a0,-1854 # ffffffffc0201fc0 <commands+0x2f8>
ffffffffc0200706:	9b1ff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020070a:	1141                	addi	sp,sp,-16
ffffffffc020070c:	e406                	sd	ra,8(sp)
			clock_set_next_event();
ffffffffc020070e:	d33ff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
			if(++ticks % TICK_NUM == 0){
ffffffffc0200712:	00006797          	auipc	a5,0x6
ffffffffc0200716:	d2e78793          	addi	a5,a5,-722 # ffffffffc0206440 <ticks>
ffffffffc020071a:	639c                	ld	a5,0(a5)
ffffffffc020071c:	06400713          	li	a4,100
ffffffffc0200720:	0785                	addi	a5,a5,1
ffffffffc0200722:	02e7f733          	remu	a4,a5,a4
ffffffffc0200726:	00006697          	auipc	a3,0x6
ffffffffc020072a:	d0f6bd23          	sd	a5,-742(a3) # ffffffffc0206440 <ticks>
ffffffffc020072e:	c711                	beqz	a4,ffffffffc020073a <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200730:	60a2                	ld	ra,8(sp)
ffffffffc0200732:	0141                	addi	sp,sp,16
ffffffffc0200734:	8082                	ret
            print_trapframe(tf);
ffffffffc0200736:	f15ff06f          	j	ffffffffc020064a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073a:	06400593          	li	a1,100
ffffffffc020073e:	00002517          	auipc	a0,0x2
ffffffffc0200742:	87250513          	addi	a0,a0,-1934 # ffffffffc0201fb0 <commands+0x2e8>
ffffffffc0200746:	971ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
				if(++num==10){
ffffffffc020074a:	00006797          	auipc	a5,0x6
ffffffffc020074e:	cd678793          	addi	a5,a5,-810 # ffffffffc0206420 <num>
ffffffffc0200752:	639c                	ld	a5,0(a5)
ffffffffc0200754:	4729                	li	a4,10
ffffffffc0200756:	0785                	addi	a5,a5,1
ffffffffc0200758:	00006697          	auipc	a3,0x6
ffffffffc020075c:	ccf6b423          	sd	a5,-824(a3) # ffffffffc0206420 <num>
ffffffffc0200760:	fce798e3          	bne	a5,a4,ffffffffc0200730 <interrupt_handler+0x84>
}
ffffffffc0200764:	60a2                	ld	ra,8(sp)
ffffffffc0200766:	0141                	addi	sp,sp,16
					sbi_shutdown();
ffffffffc0200768:	4040106f          	j	ffffffffc0201b6c <sbi_shutdown>

ffffffffc020076c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc020076c:	11853783          	ld	a5,280(a0)
ffffffffc0200770:	472d                	li	a4,11
ffffffffc0200772:	02f76863          	bltu	a4,a5,ffffffffc02007a2 <exception_handler+0x36>
ffffffffc0200776:	4705                	li	a4,1
ffffffffc0200778:	00f71733          	sll	a4,a4,a5
ffffffffc020077c:	6785                	lui	a5,0x1
ffffffffc020077e:	17cd                	addi	a5,a5,-13
ffffffffc0200780:	8ff9                	and	a5,a5,a4
ffffffffc0200782:	ef99                	bnez	a5,ffffffffc02007a0 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
ffffffffc0200784:	1141                	addi	sp,sp,-16
ffffffffc0200786:	e022                	sd	s0,0(sp)
ffffffffc0200788:	e406                	sd	ra,8(sp)
ffffffffc020078a:	00877793          	andi	a5,a4,8
ffffffffc020078e:	842a                	mv	s0,a0
ffffffffc0200790:	e3b1                	bnez	a5,ffffffffc02007d4 <exception_handler+0x68>
ffffffffc0200792:	8b11                	andi	a4,a4,4
ffffffffc0200794:	eb09                	bnez	a4,ffffffffc02007a6 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200796:	6402                	ld	s0,0(sp)
ffffffffc0200798:	60a2                	ld	ra,8(sp)
ffffffffc020079a:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc020079c:	eafff06f          	j	ffffffffc020064a <print_trapframe>
ffffffffc02007a0:	8082                	ret
ffffffffc02007a2:	ea9ff06f          	j	ffffffffc020064a <print_trapframe>
			cprintf("Exception Type: Illegal instruction\n");
ffffffffc02007a6:	00001517          	auipc	a0,0x1
ffffffffc02007aa:	6f250513          	addi	a0,a0,1778 # ffffffffc0201e98 <commands+0x1d0>
ffffffffc02007ae:	909ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
			cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
ffffffffc02007b2:	10843583          	ld	a1,264(s0)
ffffffffc02007b6:	00001517          	auipc	a0,0x1
ffffffffc02007ba:	70a50513          	addi	a0,a0,1802 # ffffffffc0201ec0 <commands+0x1f8>
ffffffffc02007be:	8f9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
			tf->epc += 2;
ffffffffc02007c2:	10843783          	ld	a5,264(s0)
}
ffffffffc02007c6:	60a2                	ld	ra,8(sp)
			tf->epc += 2;
ffffffffc02007c8:	0789                	addi	a5,a5,2
ffffffffc02007ca:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007ce:	6402                	ld	s0,0(sp)
ffffffffc02007d0:	0141                	addi	sp,sp,16
ffffffffc02007d2:	8082                	ret
			cprintf("Exception Type: breakpoint\n");
ffffffffc02007d4:	00001517          	auipc	a0,0x1
ffffffffc02007d8:	71c50513          	addi	a0,a0,1820 # ffffffffc0201ef0 <commands+0x228>
ffffffffc02007dc:	8dbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
			cprintf("ebreak caught at 0x%016llx\n", tf->epc);
ffffffffc02007e0:	10843583          	ld	a1,264(s0)
ffffffffc02007e4:	00001517          	auipc	a0,0x1
ffffffffc02007e8:	72c50513          	addi	a0,a0,1836 # ffffffffc0201f10 <commands+0x248>
ffffffffc02007ec:	8cbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
			tf->epc += 2;
ffffffffc02007f0:	10843783          	ld	a5,264(s0)
}
ffffffffc02007f4:	60a2                	ld	ra,8(sp)
			tf->epc += 2;
ffffffffc02007f6:	0789                	addi	a5,a5,2
ffffffffc02007f8:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007fc:	6402                	ld	s0,0(sp)
ffffffffc02007fe:	0141                	addi	sp,sp,16
ffffffffc0200800:	8082                	ret

ffffffffc0200802 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200802:	11853783          	ld	a5,280(a0)
ffffffffc0200806:	0007c463          	bltz	a5,ffffffffc020080e <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc020080a:	f63ff06f          	j	ffffffffc020076c <exception_handler>
        interrupt_handler(tf);
ffffffffc020080e:	e9fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200814 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200814:	14011073          	csrw	sscratch,sp
ffffffffc0200818:	712d                	addi	sp,sp,-288
ffffffffc020081a:	e002                	sd	zero,0(sp)
ffffffffc020081c:	e406                	sd	ra,8(sp)
ffffffffc020081e:	ec0e                	sd	gp,24(sp)
ffffffffc0200820:	f012                	sd	tp,32(sp)
ffffffffc0200822:	f416                	sd	t0,40(sp)
ffffffffc0200824:	f81a                	sd	t1,48(sp)
ffffffffc0200826:	fc1e                	sd	t2,56(sp)
ffffffffc0200828:	e0a2                	sd	s0,64(sp)
ffffffffc020082a:	e4a6                	sd	s1,72(sp)
ffffffffc020082c:	e8aa                	sd	a0,80(sp)
ffffffffc020082e:	ecae                	sd	a1,88(sp)
ffffffffc0200830:	f0b2                	sd	a2,96(sp)
ffffffffc0200832:	f4b6                	sd	a3,104(sp)
ffffffffc0200834:	f8ba                	sd	a4,112(sp)
ffffffffc0200836:	fcbe                	sd	a5,120(sp)
ffffffffc0200838:	e142                	sd	a6,128(sp)
ffffffffc020083a:	e546                	sd	a7,136(sp)
ffffffffc020083c:	e94a                	sd	s2,144(sp)
ffffffffc020083e:	ed4e                	sd	s3,152(sp)
ffffffffc0200840:	f152                	sd	s4,160(sp)
ffffffffc0200842:	f556                	sd	s5,168(sp)
ffffffffc0200844:	f95a                	sd	s6,176(sp)
ffffffffc0200846:	fd5e                	sd	s7,184(sp)
ffffffffc0200848:	e1e2                	sd	s8,192(sp)
ffffffffc020084a:	e5e6                	sd	s9,200(sp)
ffffffffc020084c:	e9ea                	sd	s10,208(sp)
ffffffffc020084e:	edee                	sd	s11,216(sp)
ffffffffc0200850:	f1f2                	sd	t3,224(sp)
ffffffffc0200852:	f5f6                	sd	t4,232(sp)
ffffffffc0200854:	f9fa                	sd	t5,240(sp)
ffffffffc0200856:	fdfe                	sd	t6,248(sp)
ffffffffc0200858:	14001473          	csrrw	s0,sscratch,zero
ffffffffc020085c:	100024f3          	csrr	s1,sstatus
ffffffffc0200860:	14102973          	csrr	s2,sepc
ffffffffc0200864:	143029f3          	csrr	s3,stval
ffffffffc0200868:	14202a73          	csrr	s4,scause
ffffffffc020086c:	e822                	sd	s0,16(sp)
ffffffffc020086e:	e226                	sd	s1,256(sp)
ffffffffc0200870:	e64a                	sd	s2,264(sp)
ffffffffc0200872:	ea4e                	sd	s3,272(sp)
ffffffffc0200874:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200876:	850a                	mv	a0,sp
    jal trap
ffffffffc0200878:	f8bff0ef          	jal	ra,ffffffffc0200802 <trap>

ffffffffc020087c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc020087c:	6492                	ld	s1,256(sp)
ffffffffc020087e:	6932                	ld	s2,264(sp)
ffffffffc0200880:	10049073          	csrw	sstatus,s1
ffffffffc0200884:	14191073          	csrw	sepc,s2
ffffffffc0200888:	60a2                	ld	ra,8(sp)
ffffffffc020088a:	61e2                	ld	gp,24(sp)
ffffffffc020088c:	7202                	ld	tp,32(sp)
ffffffffc020088e:	72a2                	ld	t0,40(sp)
ffffffffc0200890:	7342                	ld	t1,48(sp)
ffffffffc0200892:	73e2                	ld	t2,56(sp)
ffffffffc0200894:	6406                	ld	s0,64(sp)
ffffffffc0200896:	64a6                	ld	s1,72(sp)
ffffffffc0200898:	6546                	ld	a0,80(sp)
ffffffffc020089a:	65e6                	ld	a1,88(sp)
ffffffffc020089c:	7606                	ld	a2,96(sp)
ffffffffc020089e:	76a6                	ld	a3,104(sp)
ffffffffc02008a0:	7746                	ld	a4,112(sp)
ffffffffc02008a2:	77e6                	ld	a5,120(sp)
ffffffffc02008a4:	680a                	ld	a6,128(sp)
ffffffffc02008a6:	68aa                	ld	a7,136(sp)
ffffffffc02008a8:	694a                	ld	s2,144(sp)
ffffffffc02008aa:	69ea                	ld	s3,152(sp)
ffffffffc02008ac:	7a0a                	ld	s4,160(sp)
ffffffffc02008ae:	7aaa                	ld	s5,168(sp)
ffffffffc02008b0:	7b4a                	ld	s6,176(sp)
ffffffffc02008b2:	7bea                	ld	s7,184(sp)
ffffffffc02008b4:	6c0e                	ld	s8,192(sp)
ffffffffc02008b6:	6cae                	ld	s9,200(sp)
ffffffffc02008b8:	6d4e                	ld	s10,208(sp)
ffffffffc02008ba:	6dee                	ld	s11,216(sp)
ffffffffc02008bc:	7e0e                	ld	t3,224(sp)
ffffffffc02008be:	7eae                	ld	t4,232(sp)
ffffffffc02008c0:	7f4e                	ld	t5,240(sp)
ffffffffc02008c2:	7fee                	ld	t6,248(sp)
ffffffffc02008c4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02008c6:	10200073          	sret

ffffffffc02008ca <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008ca:	100027f3          	csrr	a5,sstatus
ffffffffc02008ce:	8b89                	andi	a5,a5,2
ffffffffc02008d0:	eb89                	bnez	a5,ffffffffc02008e2 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02008d2:	00006797          	auipc	a5,0x6
ffffffffc02008d6:	b7e78793          	addi	a5,a5,-1154 # ffffffffc0206450 <pmm_manager>
ffffffffc02008da:	639c                	ld	a5,0(a5)
ffffffffc02008dc:	0187b303          	ld	t1,24(a5)
ffffffffc02008e0:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02008e2:	1141                	addi	sp,sp,-16
ffffffffc02008e4:	e406                	sd	ra,8(sp)
ffffffffc02008e6:	e022                	sd	s0,0(sp)
ffffffffc02008e8:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02008ea:	b7bff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02008ee:	00006797          	auipc	a5,0x6
ffffffffc02008f2:	b6278793          	addi	a5,a5,-1182 # ffffffffc0206450 <pmm_manager>
ffffffffc02008f6:	639c                	ld	a5,0(a5)
ffffffffc02008f8:	8522                	mv	a0,s0
ffffffffc02008fa:	6f9c                	ld	a5,24(a5)
ffffffffc02008fc:	9782                	jalr	a5
ffffffffc02008fe:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200900:	b5fff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200904:	8522                	mv	a0,s0
ffffffffc0200906:	60a2                	ld	ra,8(sp)
ffffffffc0200908:	6402                	ld	s0,0(sp)
ffffffffc020090a:	0141                	addi	sp,sp,16
ffffffffc020090c:	8082                	ret

ffffffffc020090e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020090e:	100027f3          	csrr	a5,sstatus
ffffffffc0200912:	8b89                	andi	a5,a5,2
ffffffffc0200914:	eb89                	bnez	a5,ffffffffc0200926 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200916:	00006797          	auipc	a5,0x6
ffffffffc020091a:	b3a78793          	addi	a5,a5,-1222 # ffffffffc0206450 <pmm_manager>
ffffffffc020091e:	639c                	ld	a5,0(a5)
ffffffffc0200920:	0207b303          	ld	t1,32(a5)
ffffffffc0200924:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200926:	1101                	addi	sp,sp,-32
ffffffffc0200928:	ec06                	sd	ra,24(sp)
ffffffffc020092a:	e822                	sd	s0,16(sp)
ffffffffc020092c:	e426                	sd	s1,8(sp)
ffffffffc020092e:	842a                	mv	s0,a0
ffffffffc0200930:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200932:	b33ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200936:	00006797          	auipc	a5,0x6
ffffffffc020093a:	b1a78793          	addi	a5,a5,-1254 # ffffffffc0206450 <pmm_manager>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	85a6                	mv	a1,s1
ffffffffc0200942:	8522                	mv	a0,s0
ffffffffc0200944:	739c                	ld	a5,32(a5)
ffffffffc0200946:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200948:	6442                	ld	s0,16(sp)
ffffffffc020094a:	60e2                	ld	ra,24(sp)
ffffffffc020094c:	64a2                	ld	s1,8(sp)
ffffffffc020094e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200950:	b0fff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0200954 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200954:	100027f3          	csrr	a5,sstatus
ffffffffc0200958:	8b89                	andi	a5,a5,2
ffffffffc020095a:	eb89                	bnez	a5,ffffffffc020096c <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020095c:	00006797          	auipc	a5,0x6
ffffffffc0200960:	af478793          	addi	a5,a5,-1292 # ffffffffc0206450 <pmm_manager>
ffffffffc0200964:	639c                	ld	a5,0(a5)
ffffffffc0200966:	0287b303          	ld	t1,40(a5)
ffffffffc020096a:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc020096c:	1141                	addi	sp,sp,-16
ffffffffc020096e:	e406                	sd	ra,8(sp)
ffffffffc0200970:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200972:	af3ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200976:	00006797          	auipc	a5,0x6
ffffffffc020097a:	ada78793          	addi	a5,a5,-1318 # ffffffffc0206450 <pmm_manager>
ffffffffc020097e:	639c                	ld	a5,0(a5)
ffffffffc0200980:	779c                	ld	a5,40(a5)
ffffffffc0200982:	9782                	jalr	a5
ffffffffc0200984:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200986:	ad9ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020098a:	8522                	mv	a0,s0
ffffffffc020098c:	60a2                	ld	ra,8(sp)
ffffffffc020098e:	6402                	ld	s0,0(sp)
ffffffffc0200990:	0141                	addi	sp,sp,16
ffffffffc0200992:	8082                	ret

ffffffffc0200994 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200994:	00002797          	auipc	a5,0x2
ffffffffc0200998:	e2478793          	addi	a5,a5,-476 # ffffffffc02027b8 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020099c:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020099e:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02009a0:	00002517          	auipc	a0,0x2
ffffffffc02009a4:	9b850513          	addi	a0,a0,-1608 # ffffffffc0202358 <commands+0x690>
void pmm_init(void) {
ffffffffc02009a8:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02009aa:	00006717          	auipc	a4,0x6
ffffffffc02009ae:	aaf73323          	sd	a5,-1370(a4) # ffffffffc0206450 <pmm_manager>
void pmm_init(void) {
ffffffffc02009b2:	e822                	sd	s0,16(sp)
ffffffffc02009b4:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02009b6:	00006417          	auipc	s0,0x6
ffffffffc02009ba:	a9a40413          	addi	s0,s0,-1382 # ffffffffc0206450 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02009be:	ef8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02009c2:	601c                	ld	a5,0(s0)
ffffffffc02009c4:	679c                	ld	a5,8(a5)
ffffffffc02009c6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02009c8:	57f5                	li	a5,-3
ffffffffc02009ca:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02009cc:	00002517          	auipc	a0,0x2
ffffffffc02009d0:	9a450513          	addi	a0,a0,-1628 # ffffffffc0202370 <commands+0x6a8>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02009d4:	00006717          	auipc	a4,0x6
ffffffffc02009d8:	a8f73223          	sd	a5,-1404(a4) # ffffffffc0206458 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02009dc:	edaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02009e0:	46c5                	li	a3,17
ffffffffc02009e2:	06ee                	slli	a3,a3,0x1b
ffffffffc02009e4:	40100613          	li	a2,1025
ffffffffc02009e8:	16fd                	addi	a3,a3,-1
ffffffffc02009ea:	0656                	slli	a2,a2,0x15
ffffffffc02009ec:	07e005b7          	lui	a1,0x7e00
ffffffffc02009f0:	00002517          	auipc	a0,0x2
ffffffffc02009f4:	99850513          	addi	a0,a0,-1640 # ffffffffc0202388 <commands+0x6c0>
ffffffffc02009f8:	ebeff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02009fc:	777d                	lui	a4,0xfffff
ffffffffc02009fe:	00007797          	auipc	a5,0x7
ffffffffc0200a02:	a8178793          	addi	a5,a5,-1407 # ffffffffc020747f <end+0xfff>
ffffffffc0200a06:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200a08:	00088737          	lui	a4,0x88
ffffffffc0200a0c:	00006697          	auipc	a3,0x6
ffffffffc0200a10:	a0e6be23          	sd	a4,-1508(a3) # ffffffffc0206428 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200a14:	4601                	li	a2,0
ffffffffc0200a16:	00006717          	auipc	a4,0x6
ffffffffc0200a1a:	a4f73523          	sd	a5,-1462(a4) # ffffffffc0206460 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200a1e:	4681                	li	a3,0
ffffffffc0200a20:	00006897          	auipc	a7,0x6
ffffffffc0200a24:	a0888893          	addi	a7,a7,-1528 # ffffffffc0206428 <npage>
ffffffffc0200a28:	00006597          	auipc	a1,0x6
ffffffffc0200a2c:	a3858593          	addi	a1,a1,-1480 # ffffffffc0206460 <pages>
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a30:	4805                	li	a6,1
ffffffffc0200a32:	fff80537          	lui	a0,0xfff80
ffffffffc0200a36:	a011                	j	ffffffffc0200a3a <pmm_init+0xa6>
ffffffffc0200a38:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200a3a:	97b2                	add	a5,a5,a2
ffffffffc0200a3c:	07a1                	addi	a5,a5,8
ffffffffc0200a3e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200a42:	0008b703          	ld	a4,0(a7)
ffffffffc0200a46:	0685                	addi	a3,a3,1
ffffffffc0200a48:	02860613          	addi	a2,a2,40
ffffffffc0200a4c:	00a707b3          	add	a5,a4,a0
ffffffffc0200a50:	fef6e4e3          	bltu	a3,a5,ffffffffc0200a38 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a54:	6190                	ld	a2,0(a1)
ffffffffc0200a56:	00271793          	slli	a5,a4,0x2
ffffffffc0200a5a:	97ba                	add	a5,a5,a4
ffffffffc0200a5c:	fec006b7          	lui	a3,0xfec00
ffffffffc0200a60:	078e                	slli	a5,a5,0x3
ffffffffc0200a62:	96b2                	add	a3,a3,a2
ffffffffc0200a64:	96be                	add	a3,a3,a5
ffffffffc0200a66:	c02007b7          	lui	a5,0xc0200
ffffffffc0200a6a:	08f6e863          	bltu	a3,a5,ffffffffc0200afa <pmm_init+0x166>
ffffffffc0200a6e:	00006497          	auipc	s1,0x6
ffffffffc0200a72:	9ea48493          	addi	s1,s1,-1558 # ffffffffc0206458 <va_pa_offset>
ffffffffc0200a76:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0200a78:	45c5                	li	a1,17
ffffffffc0200a7a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a7c:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0200a7e:	04b6e963          	bltu	a3,a1,ffffffffc0200ad0 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200a82:	601c                	ld	a5,0(s0)
ffffffffc0200a84:	7b9c                	ld	a5,48(a5)
ffffffffc0200a86:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200a88:	00002517          	auipc	a0,0x2
ffffffffc0200a8c:	99850513          	addi	a0,a0,-1640 # ffffffffc0202420 <commands+0x758>
ffffffffc0200a90:	e26ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200a94:	00004697          	auipc	a3,0x4
ffffffffc0200a98:	56c68693          	addi	a3,a3,1388 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200a9c:	00006797          	auipc	a5,0x6
ffffffffc0200aa0:	98d7ba23          	sd	a3,-1644(a5) # ffffffffc0206430 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200aa4:	c02007b7          	lui	a5,0xc0200
ffffffffc0200aa8:	06f6e563          	bltu	a3,a5,ffffffffc0200b12 <pmm_init+0x17e>
ffffffffc0200aac:	609c                	ld	a5,0(s1)
}
ffffffffc0200aae:	6442                	ld	s0,16(sp)
ffffffffc0200ab0:	60e2                	ld	ra,24(sp)
ffffffffc0200ab2:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ab4:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ab6:	8e9d                	sub	a3,a3,a5
ffffffffc0200ab8:	00006797          	auipc	a5,0x6
ffffffffc0200abc:	98d7b823          	sd	a3,-1648(a5) # ffffffffc0206448 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ac0:	00002517          	auipc	a0,0x2
ffffffffc0200ac4:	98050513          	addi	a0,a0,-1664 # ffffffffc0202440 <commands+0x778>
ffffffffc0200ac8:	8636                	mv	a2,a3
}
ffffffffc0200aca:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200acc:	deaff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200ad0:	6785                	lui	a5,0x1
ffffffffc0200ad2:	17fd                	addi	a5,a5,-1
ffffffffc0200ad4:	96be                	add	a3,a3,a5
ffffffffc0200ad6:	77fd                	lui	a5,0xfffff
ffffffffc0200ad8:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200ada:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200ade:	04e7f663          	bleu	a4,a5,ffffffffc0200b2a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200ae2:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200ae4:	97aa                	add	a5,a5,a0
ffffffffc0200ae6:	00279513          	slli	a0,a5,0x2
ffffffffc0200aea:	953e                	add	a0,a0,a5
ffffffffc0200aec:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200aee:	8d95                	sub	a1,a1,a3
ffffffffc0200af0:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200af2:	81b1                	srli	a1,a1,0xc
ffffffffc0200af4:	9532                	add	a0,a0,a2
ffffffffc0200af6:	9782                	jalr	a5
ffffffffc0200af8:	b769                	j	ffffffffc0200a82 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200afa:	00002617          	auipc	a2,0x2
ffffffffc0200afe:	8be60613          	addi	a2,a2,-1858 # ffffffffc02023b8 <commands+0x6f0>
ffffffffc0200b02:	06f00593          	li	a1,111
ffffffffc0200b06:	00002517          	auipc	a0,0x2
ffffffffc0200b0a:	8da50513          	addi	a0,a0,-1830 # ffffffffc02023e0 <commands+0x718>
ffffffffc0200b0e:	e30ff0ef          	jal	ra,ffffffffc020013e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200b12:	00002617          	auipc	a2,0x2
ffffffffc0200b16:	8a660613          	addi	a2,a2,-1882 # ffffffffc02023b8 <commands+0x6f0>
ffffffffc0200b1a:	08a00593          	li	a1,138
ffffffffc0200b1e:	00002517          	auipc	a0,0x2
ffffffffc0200b22:	8c250513          	addi	a0,a0,-1854 # ffffffffc02023e0 <commands+0x718>
ffffffffc0200b26:	e18ff0ef          	jal	ra,ffffffffc020013e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200b2a:	00002617          	auipc	a2,0x2
ffffffffc0200b2e:	8c660613          	addi	a2,a2,-1850 # ffffffffc02023f0 <commands+0x728>
ffffffffc0200b32:	06b00593          	li	a1,107
ffffffffc0200b36:	00002517          	auipc	a0,0x2
ffffffffc0200b3a:	8da50513          	addi	a0,a0,-1830 # ffffffffc0202410 <commands+0x748>
ffffffffc0200b3e:	e00ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200b42 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b42:	00006797          	auipc	a5,0x6
ffffffffc0200b46:	92678793          	addi	a5,a5,-1754 # ffffffffc0206468 <free_area>
ffffffffc0200b4a:	e79c                	sd	a5,8(a5)
ffffffffc0200b4c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b4e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b52:	8082                	ret

ffffffffc0200b54 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b54:	00006517          	auipc	a0,0x6
ffffffffc0200b58:	92456503          	lwu	a0,-1756(a0) # ffffffffc0206478 <free_area+0x10>
ffffffffc0200b5c:	8082                	ret

ffffffffc0200b5e <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200b5e:	715d                	addi	sp,sp,-80
ffffffffc0200b60:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b62:	00006917          	auipc	s2,0x6
ffffffffc0200b66:	90690913          	addi	s2,s2,-1786 # ffffffffc0206468 <free_area>
ffffffffc0200b6a:	00893783          	ld	a5,8(s2)
ffffffffc0200b6e:	e486                	sd	ra,72(sp)
ffffffffc0200b70:	e0a2                	sd	s0,64(sp)
ffffffffc0200b72:	fc26                	sd	s1,56(sp)
ffffffffc0200b74:	f44e                	sd	s3,40(sp)
ffffffffc0200b76:	f052                	sd	s4,32(sp)
ffffffffc0200b78:	ec56                	sd	s5,24(sp)
ffffffffc0200b7a:	e85a                	sd	s6,16(sp)
ffffffffc0200b7c:	e45e                	sd	s7,8(sp)
ffffffffc0200b7e:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b80:	2d278363          	beq	a5,s2,ffffffffc0200e46 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b84:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200b88:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b8a:	8b05                	andi	a4,a4,1
ffffffffc0200b8c:	2c070163          	beqz	a4,ffffffffc0200e4e <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200b90:	4401                	li	s0,0
ffffffffc0200b92:	4481                	li	s1,0
ffffffffc0200b94:	a031                	j	ffffffffc0200ba0 <best_fit_check+0x42>
ffffffffc0200b96:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200b9a:	8b09                	andi	a4,a4,2
ffffffffc0200b9c:	2a070963          	beqz	a4,ffffffffc0200e4e <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200ba0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ba4:	679c                	ld	a5,8(a5)
ffffffffc0200ba6:	2485                	addiw	s1,s1,1
ffffffffc0200ba8:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200baa:	ff2796e3          	bne	a5,s2,ffffffffc0200b96 <best_fit_check+0x38>
ffffffffc0200bae:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200bb0:	da5ff0ef          	jal	ra,ffffffffc0200954 <nr_free_pages>
ffffffffc0200bb4:	37351d63          	bne	a0,s3,ffffffffc0200f2e <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bb8:	4505                	li	a0,1
ffffffffc0200bba:	d11ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200bbe:	8a2a                	mv	s4,a0
ffffffffc0200bc0:	3a050763          	beqz	a0,ffffffffc0200f6e <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bc4:	4505                	li	a0,1
ffffffffc0200bc6:	d05ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200bca:	89aa                	mv	s3,a0
ffffffffc0200bcc:	38050163          	beqz	a0,ffffffffc0200f4e <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bd0:	4505                	li	a0,1
ffffffffc0200bd2:	cf9ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200bd6:	8aaa                	mv	s5,a0
ffffffffc0200bd8:	30050b63          	beqz	a0,ffffffffc0200eee <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bdc:	293a0963          	beq	s4,s3,ffffffffc0200e6e <best_fit_check+0x310>
ffffffffc0200be0:	28aa0763          	beq	s4,a0,ffffffffc0200e6e <best_fit_check+0x310>
ffffffffc0200be4:	28a98563          	beq	s3,a0,ffffffffc0200e6e <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200be8:	000a2783          	lw	a5,0(s4)
ffffffffc0200bec:	2a079163          	bnez	a5,ffffffffc0200e8e <best_fit_check+0x330>
ffffffffc0200bf0:	0009a783          	lw	a5,0(s3)
ffffffffc0200bf4:	28079d63          	bnez	a5,ffffffffc0200e8e <best_fit_check+0x330>
ffffffffc0200bf8:	411c                	lw	a5,0(a0)
ffffffffc0200bfa:	28079a63          	bnez	a5,ffffffffc0200e8e <best_fit_check+0x330>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bfe:	00006797          	auipc	a5,0x6
ffffffffc0200c02:	86278793          	addi	a5,a5,-1950 # ffffffffc0206460 <pages>
ffffffffc0200c06:	639c                	ld	a5,0(a5)
ffffffffc0200c08:	00002717          	auipc	a4,0x2
ffffffffc0200c0c:	87870713          	addi	a4,a4,-1928 # ffffffffc0202480 <commands+0x7b8>
ffffffffc0200c10:	630c                	ld	a1,0(a4)
ffffffffc0200c12:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c16:	870d                	srai	a4,a4,0x3
ffffffffc0200c18:	02b70733          	mul	a4,a4,a1
ffffffffc0200c1c:	00002697          	auipc	a3,0x2
ffffffffc0200c20:	e3468693          	addi	a3,a3,-460 # ffffffffc0202a50 <nbase>
ffffffffc0200c24:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c26:	00006697          	auipc	a3,0x6
ffffffffc0200c2a:	80268693          	addi	a3,a3,-2046 # ffffffffc0206428 <npage>
ffffffffc0200c2e:	6294                	ld	a3,0(a3)
ffffffffc0200c30:	06b2                	slli	a3,a3,0xc
ffffffffc0200c32:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c34:	0732                	slli	a4,a4,0xc
ffffffffc0200c36:	26d77c63          	bleu	a3,a4,ffffffffc0200eae <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c3a:	40f98733          	sub	a4,s3,a5
ffffffffc0200c3e:	870d                	srai	a4,a4,0x3
ffffffffc0200c40:	02b70733          	mul	a4,a4,a1
ffffffffc0200c44:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c46:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c48:	42d77363          	bleu	a3,a4,ffffffffc020106e <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c4c:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c50:	878d                	srai	a5,a5,0x3
ffffffffc0200c52:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c56:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c58:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c5a:	3ed7fa63          	bleu	a3,a5,ffffffffc020104e <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200c5e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c60:	00093c03          	ld	s8,0(s2)
ffffffffc0200c64:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c68:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c6c:	00006797          	auipc	a5,0x6
ffffffffc0200c70:	8127b223          	sd	s2,-2044(a5) # ffffffffc0206470 <free_area+0x8>
ffffffffc0200c74:	00005797          	auipc	a5,0x5
ffffffffc0200c78:	7f27ba23          	sd	s2,2036(a5) # ffffffffc0206468 <free_area>
    nr_free = 0;
ffffffffc0200c7c:	00005797          	auipc	a5,0x5
ffffffffc0200c80:	7e07ae23          	sw	zero,2044(a5) # ffffffffc0206478 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c84:	c47ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200c88:	3a051363          	bnez	a0,ffffffffc020102e <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200c8c:	4585                	li	a1,1
ffffffffc0200c8e:	8552                	mv	a0,s4
ffffffffc0200c90:	c7fff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_page(p1);
ffffffffc0200c94:	4585                	li	a1,1
ffffffffc0200c96:	854e                	mv	a0,s3
ffffffffc0200c98:	c77ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_page(p2);
ffffffffc0200c9c:	4585                	li	a1,1
ffffffffc0200c9e:	8556                	mv	a0,s5
ffffffffc0200ca0:	c6fff0ef          	jal	ra,ffffffffc020090e <free_pages>
    assert(nr_free == 3);
ffffffffc0200ca4:	01092703          	lw	a4,16(s2)
ffffffffc0200ca8:	478d                	li	a5,3
ffffffffc0200caa:	36f71263          	bne	a4,a5,ffffffffc020100e <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cae:	4505                	li	a0,1
ffffffffc0200cb0:	c1bff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200cb4:	89aa                	mv	s3,a0
ffffffffc0200cb6:	32050c63          	beqz	a0,ffffffffc0200fee <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cba:	4505                	li	a0,1
ffffffffc0200cbc:	c0fff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200cc0:	8aaa                	mv	s5,a0
ffffffffc0200cc2:	30050663          	beqz	a0,ffffffffc0200fce <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cc6:	4505                	li	a0,1
ffffffffc0200cc8:	c03ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200ccc:	8a2a                	mv	s4,a0
ffffffffc0200cce:	2e050063          	beqz	a0,ffffffffc0200fae <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200cd2:	4505                	li	a0,1
ffffffffc0200cd4:	bf7ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200cd8:	2a051b63          	bnez	a0,ffffffffc0200f8e <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200cdc:	4585                	li	a1,1
ffffffffc0200cde:	854e                	mv	a0,s3
ffffffffc0200ce0:	c2fff0ef          	jal	ra,ffffffffc020090e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ce4:	00893783          	ld	a5,8(s2)
ffffffffc0200ce8:	1f278363          	beq	a5,s2,ffffffffc0200ece <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200cec:	4505                	li	a0,1
ffffffffc0200cee:	bddff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200cf2:	54a99e63          	bne	s3,a0,ffffffffc020124e <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200cf6:	4505                	li	a0,1
ffffffffc0200cf8:	bd3ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200cfc:	52051963          	bnez	a0,ffffffffc020122e <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200d00:	01092783          	lw	a5,16(s2)
ffffffffc0200d04:	50079563          	bnez	a5,ffffffffc020120e <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200d08:	854e                	mv	a0,s3
ffffffffc0200d0a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d0c:	00005797          	auipc	a5,0x5
ffffffffc0200d10:	7587be23          	sd	s8,1884(a5) # ffffffffc0206468 <free_area>
ffffffffc0200d14:	00005797          	auipc	a5,0x5
ffffffffc0200d18:	7577be23          	sd	s7,1884(a5) # ffffffffc0206470 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d1c:	00005797          	auipc	a5,0x5
ffffffffc0200d20:	7567ae23          	sw	s6,1884(a5) # ffffffffc0206478 <free_area+0x10>
    free_page(p);
ffffffffc0200d24:	bebff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_page(p1);
ffffffffc0200d28:	4585                	li	a1,1
ffffffffc0200d2a:	8556                	mv	a0,s5
ffffffffc0200d2c:	be3ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_page(p2);
ffffffffc0200d30:	4585                	li	a1,1
ffffffffc0200d32:	8552                	mv	a0,s4
ffffffffc0200d34:	bdbff0ef          	jal	ra,ffffffffc020090e <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d38:	4515                	li	a0,5
ffffffffc0200d3a:	b91ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200d3e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d40:	4a050763          	beqz	a0,ffffffffc02011ee <best_fit_check+0x690>
ffffffffc0200d44:	651c                	ld	a5,8(a0)
ffffffffc0200d46:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d48:	8b85                	andi	a5,a5,1
ffffffffc0200d4a:	48079263          	bnez	a5,ffffffffc02011ce <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d4e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d50:	00093b03          	ld	s6,0(s2)
ffffffffc0200d54:	00893a83          	ld	s5,8(s2)
ffffffffc0200d58:	00005797          	auipc	a5,0x5
ffffffffc0200d5c:	7127b823          	sd	s2,1808(a5) # ffffffffc0206468 <free_area>
ffffffffc0200d60:	00005797          	auipc	a5,0x5
ffffffffc0200d64:	7127b823          	sd	s2,1808(a5) # ffffffffc0206470 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d68:	b63ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200d6c:	44051163          	bnez	a0,ffffffffc02011ae <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200d70:	4589                	li	a1,2
ffffffffc0200d72:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200d76:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200d7a:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200d7e:	00005797          	auipc	a5,0x5
ffffffffc0200d82:	6e07ad23          	sw	zero,1786(a5) # ffffffffc0206478 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200d86:	b89ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200d8a:	8562                	mv	a0,s8
ffffffffc0200d8c:	4585                	li	a1,1
ffffffffc0200d8e:	b81ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d92:	4511                	li	a0,4
ffffffffc0200d94:	b37ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200d98:	3e051b63          	bnez	a0,ffffffffc020118e <best_fit_check+0x630>
ffffffffc0200d9c:	0309b783          	ld	a5,48(s3)
ffffffffc0200da0:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200da2:	8b85                	andi	a5,a5,1
ffffffffc0200da4:	3c078563          	beqz	a5,ffffffffc020116e <best_fit_check+0x610>
ffffffffc0200da8:	0389a703          	lw	a4,56(s3)
ffffffffc0200dac:	4789                	li	a5,2
ffffffffc0200dae:	3cf71063          	bne	a4,a5,ffffffffc020116e <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200db2:	4505                	li	a0,1
ffffffffc0200db4:	b17ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200db8:	8a2a                	mv	s4,a0
ffffffffc0200dba:	38050a63          	beqz	a0,ffffffffc020114e <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200dbe:	4509                	li	a0,2
ffffffffc0200dc0:	b0bff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200dc4:	36050563          	beqz	a0,ffffffffc020112e <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200dc8:	354c1363          	bne	s8,s4,ffffffffc020110e <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200dcc:	854e                	mv	a0,s3
ffffffffc0200dce:	4595                	li	a1,5
ffffffffc0200dd0:	b3fff0ef          	jal	ra,ffffffffc020090e <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200dd4:	4515                	li	a0,5
ffffffffc0200dd6:	af5ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200dda:	89aa                	mv	s3,a0
ffffffffc0200ddc:	30050963          	beqz	a0,ffffffffc02010ee <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200de0:	4505                	li	a0,1
ffffffffc0200de2:	ae9ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200de6:	2e051463          	bnez	a0,ffffffffc02010ce <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200dea:	01092783          	lw	a5,16(s2)
ffffffffc0200dee:	2c079063          	bnez	a5,ffffffffc02010ae <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200df2:	4595                	li	a1,5
ffffffffc0200df4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200df6:	00005797          	auipc	a5,0x5
ffffffffc0200dfa:	6977a123          	sw	s7,1666(a5) # ffffffffc0206478 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200dfe:	00005797          	auipc	a5,0x5
ffffffffc0200e02:	6767b523          	sd	s6,1642(a5) # ffffffffc0206468 <free_area>
ffffffffc0200e06:	00005797          	auipc	a5,0x5
ffffffffc0200e0a:	6757b523          	sd	s5,1642(a5) # ffffffffc0206470 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e0e:	b01ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    return listelm->next;
ffffffffc0200e12:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e16:	01278963          	beq	a5,s2,ffffffffc0200e28 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e1a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e1e:	679c                	ld	a5,8(a5)
ffffffffc0200e20:	34fd                	addiw	s1,s1,-1
ffffffffc0200e22:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e24:	ff279be3          	bne	a5,s2,ffffffffc0200e1a <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200e28:	26049363          	bnez	s1,ffffffffc020108e <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200e2c:	e06d                	bnez	s0,ffffffffc0200f0e <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200e2e:	60a6                	ld	ra,72(sp)
ffffffffc0200e30:	6406                	ld	s0,64(sp)
ffffffffc0200e32:	74e2                	ld	s1,56(sp)
ffffffffc0200e34:	7942                	ld	s2,48(sp)
ffffffffc0200e36:	79a2                	ld	s3,40(sp)
ffffffffc0200e38:	7a02                	ld	s4,32(sp)
ffffffffc0200e3a:	6ae2                	ld	s5,24(sp)
ffffffffc0200e3c:	6b42                	ld	s6,16(sp)
ffffffffc0200e3e:	6ba2                	ld	s7,8(sp)
ffffffffc0200e40:	6c02                	ld	s8,0(sp)
ffffffffc0200e42:	6161                	addi	sp,sp,80
ffffffffc0200e44:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e46:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e48:	4401                	li	s0,0
ffffffffc0200e4a:	4481                	li	s1,0
ffffffffc0200e4c:	b395                	j	ffffffffc0200bb0 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e4e:	00001697          	auipc	a3,0x1
ffffffffc0200e52:	63a68693          	addi	a3,a3,1594 # ffffffffc0202488 <commands+0x7c0>
ffffffffc0200e56:	00001617          	auipc	a2,0x1
ffffffffc0200e5a:	64260613          	addi	a2,a2,1602 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200e5e:	10d00593          	li	a1,269
ffffffffc0200e62:	00001517          	auipc	a0,0x1
ffffffffc0200e66:	64e50513          	addi	a0,a0,1614 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200e6a:	ad4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e6e:	00001697          	auipc	a3,0x1
ffffffffc0200e72:	6da68693          	addi	a3,a3,1754 # ffffffffc0202548 <commands+0x880>
ffffffffc0200e76:	00001617          	auipc	a2,0x1
ffffffffc0200e7a:	62260613          	addi	a2,a2,1570 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200e7e:	0d900593          	li	a1,217
ffffffffc0200e82:	00001517          	auipc	a0,0x1
ffffffffc0200e86:	62e50513          	addi	a0,a0,1582 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200e8a:	ab4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e8e:	00001697          	auipc	a3,0x1
ffffffffc0200e92:	6e268693          	addi	a3,a3,1762 # ffffffffc0202570 <commands+0x8a8>
ffffffffc0200e96:	00001617          	auipc	a2,0x1
ffffffffc0200e9a:	60260613          	addi	a2,a2,1538 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200e9e:	0da00593          	li	a1,218
ffffffffc0200ea2:	00001517          	auipc	a0,0x1
ffffffffc0200ea6:	60e50513          	addi	a0,a0,1550 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200eaa:	a94ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eae:	00001697          	auipc	a3,0x1
ffffffffc0200eb2:	70268693          	addi	a3,a3,1794 # ffffffffc02025b0 <commands+0x8e8>
ffffffffc0200eb6:	00001617          	auipc	a2,0x1
ffffffffc0200eba:	5e260613          	addi	a2,a2,1506 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200ebe:	0dc00593          	li	a1,220
ffffffffc0200ec2:	00001517          	auipc	a0,0x1
ffffffffc0200ec6:	5ee50513          	addi	a0,a0,1518 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200eca:	a74ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ece:	00001697          	auipc	a3,0x1
ffffffffc0200ed2:	76a68693          	addi	a3,a3,1898 # ffffffffc0202638 <commands+0x970>
ffffffffc0200ed6:	00001617          	auipc	a2,0x1
ffffffffc0200eda:	5c260613          	addi	a2,a2,1474 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200ede:	0f500593          	li	a1,245
ffffffffc0200ee2:	00001517          	auipc	a0,0x1
ffffffffc0200ee6:	5ce50513          	addi	a0,a0,1486 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200eea:	a54ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200eee:	00001697          	auipc	a3,0x1
ffffffffc0200ef2:	63a68693          	addi	a3,a3,1594 # ffffffffc0202528 <commands+0x860>
ffffffffc0200ef6:	00001617          	auipc	a2,0x1
ffffffffc0200efa:	5a260613          	addi	a2,a2,1442 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200efe:	0d700593          	li	a1,215
ffffffffc0200f02:	00001517          	auipc	a0,0x1
ffffffffc0200f06:	5ae50513          	addi	a0,a0,1454 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200f0a:	a34ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == 0);
ffffffffc0200f0e:	00002697          	auipc	a3,0x2
ffffffffc0200f12:	85a68693          	addi	a3,a3,-1958 # ffffffffc0202768 <commands+0xaa0>
ffffffffc0200f16:	00001617          	auipc	a2,0x1
ffffffffc0200f1a:	58260613          	addi	a2,a2,1410 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200f1e:	14f00593          	li	a1,335
ffffffffc0200f22:	00001517          	auipc	a0,0x1
ffffffffc0200f26:	58e50513          	addi	a0,a0,1422 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200f2a:	a14ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == nr_free_pages());
ffffffffc0200f2e:	00001697          	auipc	a3,0x1
ffffffffc0200f32:	59a68693          	addi	a3,a3,1434 # ffffffffc02024c8 <commands+0x800>
ffffffffc0200f36:	00001617          	auipc	a2,0x1
ffffffffc0200f3a:	56260613          	addi	a2,a2,1378 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200f3e:	11000593          	li	a1,272
ffffffffc0200f42:	00001517          	auipc	a0,0x1
ffffffffc0200f46:	56e50513          	addi	a0,a0,1390 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200f4a:	9f4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f4e:	00001697          	auipc	a3,0x1
ffffffffc0200f52:	5ba68693          	addi	a3,a3,1466 # ffffffffc0202508 <commands+0x840>
ffffffffc0200f56:	00001617          	auipc	a2,0x1
ffffffffc0200f5a:	54260613          	addi	a2,a2,1346 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200f5e:	0d600593          	li	a1,214
ffffffffc0200f62:	00001517          	auipc	a0,0x1
ffffffffc0200f66:	54e50513          	addi	a0,a0,1358 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200f6a:	9d4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f6e:	00001697          	auipc	a3,0x1
ffffffffc0200f72:	57a68693          	addi	a3,a3,1402 # ffffffffc02024e8 <commands+0x820>
ffffffffc0200f76:	00001617          	auipc	a2,0x1
ffffffffc0200f7a:	52260613          	addi	a2,a2,1314 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200f7e:	0d500593          	li	a1,213
ffffffffc0200f82:	00001517          	auipc	a0,0x1
ffffffffc0200f86:	52e50513          	addi	a0,a0,1326 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200f8a:	9b4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f8e:	00001697          	auipc	a3,0x1
ffffffffc0200f92:	68268693          	addi	a3,a3,1666 # ffffffffc0202610 <commands+0x948>
ffffffffc0200f96:	00001617          	auipc	a2,0x1
ffffffffc0200f9a:	50260613          	addi	a2,a2,1282 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200f9e:	0f200593          	li	a1,242
ffffffffc0200fa2:	00001517          	auipc	a0,0x1
ffffffffc0200fa6:	50e50513          	addi	a0,a0,1294 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200faa:	994ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fae:	00001697          	auipc	a3,0x1
ffffffffc0200fb2:	57a68693          	addi	a3,a3,1402 # ffffffffc0202528 <commands+0x860>
ffffffffc0200fb6:	00001617          	auipc	a2,0x1
ffffffffc0200fba:	4e260613          	addi	a2,a2,1250 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200fbe:	0f000593          	li	a1,240
ffffffffc0200fc2:	00001517          	auipc	a0,0x1
ffffffffc0200fc6:	4ee50513          	addi	a0,a0,1262 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200fca:	974ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fce:	00001697          	auipc	a3,0x1
ffffffffc0200fd2:	53a68693          	addi	a3,a3,1338 # ffffffffc0202508 <commands+0x840>
ffffffffc0200fd6:	00001617          	auipc	a2,0x1
ffffffffc0200fda:	4c260613          	addi	a2,a2,1218 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200fde:	0ef00593          	li	a1,239
ffffffffc0200fe2:	00001517          	auipc	a0,0x1
ffffffffc0200fe6:	4ce50513          	addi	a0,a0,1230 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc0200fea:	954ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fee:	00001697          	auipc	a3,0x1
ffffffffc0200ff2:	4fa68693          	addi	a3,a3,1274 # ffffffffc02024e8 <commands+0x820>
ffffffffc0200ff6:	00001617          	auipc	a2,0x1
ffffffffc0200ffa:	4a260613          	addi	a2,a2,1186 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0200ffe:	0ee00593          	li	a1,238
ffffffffc0201002:	00001517          	auipc	a0,0x1
ffffffffc0201006:	4ae50513          	addi	a0,a0,1198 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020100a:	934ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 3);
ffffffffc020100e:	00001697          	auipc	a3,0x1
ffffffffc0201012:	61a68693          	addi	a3,a3,1562 # ffffffffc0202628 <commands+0x960>
ffffffffc0201016:	00001617          	auipc	a2,0x1
ffffffffc020101a:	48260613          	addi	a2,a2,1154 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020101e:	0ec00593          	li	a1,236
ffffffffc0201022:	00001517          	auipc	a0,0x1
ffffffffc0201026:	48e50513          	addi	a0,a0,1166 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020102a:	914ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020102e:	00001697          	auipc	a3,0x1
ffffffffc0201032:	5e268693          	addi	a3,a3,1506 # ffffffffc0202610 <commands+0x948>
ffffffffc0201036:	00001617          	auipc	a2,0x1
ffffffffc020103a:	46260613          	addi	a2,a2,1122 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020103e:	0e700593          	li	a1,231
ffffffffc0201042:	00001517          	auipc	a0,0x1
ffffffffc0201046:	46e50513          	addi	a0,a0,1134 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020104a:	8f4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020104e:	00001697          	auipc	a3,0x1
ffffffffc0201052:	5a268693          	addi	a3,a3,1442 # ffffffffc02025f0 <commands+0x928>
ffffffffc0201056:	00001617          	auipc	a2,0x1
ffffffffc020105a:	44260613          	addi	a2,a2,1090 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020105e:	0de00593          	li	a1,222
ffffffffc0201062:	00001517          	auipc	a0,0x1
ffffffffc0201066:	44e50513          	addi	a0,a0,1102 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020106a:	8d4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020106e:	00001697          	auipc	a3,0x1
ffffffffc0201072:	56268693          	addi	a3,a3,1378 # ffffffffc02025d0 <commands+0x908>
ffffffffc0201076:	00001617          	auipc	a2,0x1
ffffffffc020107a:	42260613          	addi	a2,a2,1058 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020107e:	0dd00593          	li	a1,221
ffffffffc0201082:	00001517          	auipc	a0,0x1
ffffffffc0201086:	42e50513          	addi	a0,a0,1070 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020108a:	8b4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(count == 0);
ffffffffc020108e:	00001697          	auipc	a3,0x1
ffffffffc0201092:	6ca68693          	addi	a3,a3,1738 # ffffffffc0202758 <commands+0xa90>
ffffffffc0201096:	00001617          	auipc	a2,0x1
ffffffffc020109a:	40260613          	addi	a2,a2,1026 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020109e:	14e00593          	li	a1,334
ffffffffc02010a2:	00001517          	auipc	a0,0x1
ffffffffc02010a6:	40e50513          	addi	a0,a0,1038 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc02010aa:	894ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 0);
ffffffffc02010ae:	00001697          	auipc	a3,0x1
ffffffffc02010b2:	5c268693          	addi	a3,a3,1474 # ffffffffc0202670 <commands+0x9a8>
ffffffffc02010b6:	00001617          	auipc	a2,0x1
ffffffffc02010ba:	3e260613          	addi	a2,a2,994 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02010be:	14300593          	li	a1,323
ffffffffc02010c2:	00001517          	auipc	a0,0x1
ffffffffc02010c6:	3ee50513          	addi	a0,a0,1006 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc02010ca:	874ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010ce:	00001697          	auipc	a3,0x1
ffffffffc02010d2:	54268693          	addi	a3,a3,1346 # ffffffffc0202610 <commands+0x948>
ffffffffc02010d6:	00001617          	auipc	a2,0x1
ffffffffc02010da:	3c260613          	addi	a2,a2,962 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02010de:	13d00593          	li	a1,317
ffffffffc02010e2:	00001517          	auipc	a0,0x1
ffffffffc02010e6:	3ce50513          	addi	a0,a0,974 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc02010ea:	854ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02010ee:	00001697          	auipc	a3,0x1
ffffffffc02010f2:	64a68693          	addi	a3,a3,1610 # ffffffffc0202738 <commands+0xa70>
ffffffffc02010f6:	00001617          	auipc	a2,0x1
ffffffffc02010fa:	3a260613          	addi	a2,a2,930 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02010fe:	13c00593          	li	a1,316
ffffffffc0201102:	00001517          	auipc	a0,0x1
ffffffffc0201106:	3ae50513          	addi	a0,a0,942 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020110a:	834ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 + 4 == p1);
ffffffffc020110e:	00001697          	auipc	a3,0x1
ffffffffc0201112:	61a68693          	addi	a3,a3,1562 # ffffffffc0202728 <commands+0xa60>
ffffffffc0201116:	00001617          	auipc	a2,0x1
ffffffffc020111a:	38260613          	addi	a2,a2,898 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020111e:	13400593          	li	a1,308
ffffffffc0201122:	00001517          	auipc	a0,0x1
ffffffffc0201126:	38e50513          	addi	a0,a0,910 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020112a:	814ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc020112e:	00001697          	auipc	a3,0x1
ffffffffc0201132:	5e268693          	addi	a3,a3,1506 # ffffffffc0202710 <commands+0xa48>
ffffffffc0201136:	00001617          	auipc	a2,0x1
ffffffffc020113a:	36260613          	addi	a2,a2,866 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020113e:	13300593          	li	a1,307
ffffffffc0201142:	00001517          	auipc	a0,0x1
ffffffffc0201146:	36e50513          	addi	a0,a0,878 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020114a:	ff5fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020114e:	00001697          	auipc	a3,0x1
ffffffffc0201152:	5a268693          	addi	a3,a3,1442 # ffffffffc02026f0 <commands+0xa28>
ffffffffc0201156:	00001617          	auipc	a2,0x1
ffffffffc020115a:	34260613          	addi	a2,a2,834 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020115e:	13200593          	li	a1,306
ffffffffc0201162:	00001517          	auipc	a0,0x1
ffffffffc0201166:	34e50513          	addi	a0,a0,846 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020116a:	fd5fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc020116e:	00001697          	auipc	a3,0x1
ffffffffc0201172:	55268693          	addi	a3,a3,1362 # ffffffffc02026c0 <commands+0x9f8>
ffffffffc0201176:	00001617          	auipc	a2,0x1
ffffffffc020117a:	32260613          	addi	a2,a2,802 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020117e:	13000593          	li	a1,304
ffffffffc0201182:	00001517          	auipc	a0,0x1
ffffffffc0201186:	32e50513          	addi	a0,a0,814 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020118a:	fb5fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020118e:	00001697          	auipc	a3,0x1
ffffffffc0201192:	51a68693          	addi	a3,a3,1306 # ffffffffc02026a8 <commands+0x9e0>
ffffffffc0201196:	00001617          	auipc	a2,0x1
ffffffffc020119a:	30260613          	addi	a2,a2,770 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020119e:	12f00593          	li	a1,303
ffffffffc02011a2:	00001517          	auipc	a0,0x1
ffffffffc02011a6:	30e50513          	addi	a0,a0,782 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc02011aa:	f95fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011ae:	00001697          	auipc	a3,0x1
ffffffffc02011b2:	46268693          	addi	a3,a3,1122 # ffffffffc0202610 <commands+0x948>
ffffffffc02011b6:	00001617          	auipc	a2,0x1
ffffffffc02011ba:	2e260613          	addi	a2,a2,738 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02011be:	12300593          	li	a1,291
ffffffffc02011c2:	00001517          	auipc	a0,0x1
ffffffffc02011c6:	2ee50513          	addi	a0,a0,750 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc02011ca:	f75fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!PageProperty(p0));
ffffffffc02011ce:	00001697          	auipc	a3,0x1
ffffffffc02011d2:	4c268693          	addi	a3,a3,1218 # ffffffffc0202690 <commands+0x9c8>
ffffffffc02011d6:	00001617          	auipc	a2,0x1
ffffffffc02011da:	2c260613          	addi	a2,a2,706 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02011de:	11a00593          	li	a1,282
ffffffffc02011e2:	00001517          	auipc	a0,0x1
ffffffffc02011e6:	2ce50513          	addi	a0,a0,718 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc02011ea:	f55fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 != NULL);
ffffffffc02011ee:	00001697          	auipc	a3,0x1
ffffffffc02011f2:	49268693          	addi	a3,a3,1170 # ffffffffc0202680 <commands+0x9b8>
ffffffffc02011f6:	00001617          	auipc	a2,0x1
ffffffffc02011fa:	2a260613          	addi	a2,a2,674 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02011fe:	11900593          	li	a1,281
ffffffffc0201202:	00001517          	auipc	a0,0x1
ffffffffc0201206:	2ae50513          	addi	a0,a0,686 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020120a:	f35fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 0);
ffffffffc020120e:	00001697          	auipc	a3,0x1
ffffffffc0201212:	46268693          	addi	a3,a3,1122 # ffffffffc0202670 <commands+0x9a8>
ffffffffc0201216:	00001617          	auipc	a2,0x1
ffffffffc020121a:	28260613          	addi	a2,a2,642 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020121e:	0fb00593          	li	a1,251
ffffffffc0201222:	00001517          	auipc	a0,0x1
ffffffffc0201226:	28e50513          	addi	a0,a0,654 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020122a:	f15fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020122e:	00001697          	auipc	a3,0x1
ffffffffc0201232:	3e268693          	addi	a3,a3,994 # ffffffffc0202610 <commands+0x948>
ffffffffc0201236:	00001617          	auipc	a2,0x1
ffffffffc020123a:	26260613          	addi	a2,a2,610 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020123e:	0f900593          	li	a1,249
ffffffffc0201242:	00001517          	auipc	a0,0x1
ffffffffc0201246:	26e50513          	addi	a0,a0,622 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020124a:	ef5fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020124e:	00001697          	auipc	a3,0x1
ffffffffc0201252:	40268693          	addi	a3,a3,1026 # ffffffffc0202650 <commands+0x988>
ffffffffc0201256:	00001617          	auipc	a2,0x1
ffffffffc020125a:	24260613          	addi	a2,a2,578 # ffffffffc0202498 <commands+0x7d0>
ffffffffc020125e:	0f800593          	li	a1,248
ffffffffc0201262:	00001517          	auipc	a0,0x1
ffffffffc0201266:	24e50513          	addi	a0,a0,590 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020126a:	ed5fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020126e <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc020126e:	1141                	addi	sp,sp,-16
ffffffffc0201270:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201272:	18058063          	beqz	a1,ffffffffc02013f2 <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0201276:	00259693          	slli	a3,a1,0x2
ffffffffc020127a:	96ae                	add	a3,a3,a1
ffffffffc020127c:	068e                	slli	a3,a3,0x3
ffffffffc020127e:	96aa                	add	a3,a3,a0
ffffffffc0201280:	02d50d63          	beq	a0,a3,ffffffffc02012ba <best_fit_free_pages+0x4c>
ffffffffc0201284:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201286:	8b85                	andi	a5,a5,1
ffffffffc0201288:	14079563          	bnez	a5,ffffffffc02013d2 <best_fit_free_pages+0x164>
ffffffffc020128c:	651c                	ld	a5,8(a0)
ffffffffc020128e:	8385                	srli	a5,a5,0x1
ffffffffc0201290:	8b85                	andi	a5,a5,1
ffffffffc0201292:	14079063          	bnez	a5,ffffffffc02013d2 <best_fit_free_pages+0x164>
ffffffffc0201296:	87aa                	mv	a5,a0
ffffffffc0201298:	a809                	j	ffffffffc02012aa <best_fit_free_pages+0x3c>
ffffffffc020129a:	6798                	ld	a4,8(a5)
ffffffffc020129c:	8b05                	andi	a4,a4,1
ffffffffc020129e:	12071a63          	bnez	a4,ffffffffc02013d2 <best_fit_free_pages+0x164>
ffffffffc02012a2:	6798                	ld	a4,8(a5)
ffffffffc02012a4:	8b09                	andi	a4,a4,2
ffffffffc02012a6:	12071663          	bnez	a4,ffffffffc02013d2 <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc02012aa:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012ae:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012b2:	02878793          	addi	a5,a5,40
ffffffffc02012b6:	fed792e3          	bne	a5,a3,ffffffffc020129a <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc02012ba:	2581                	sext.w	a1,a1
ffffffffc02012bc:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02012be:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012c2:	4789                	li	a5,2
ffffffffc02012c4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012c8:	00005697          	auipc	a3,0x5
ffffffffc02012cc:	1a068693          	addi	a3,a3,416 # ffffffffc0206468 <free_area>
ffffffffc02012d0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012d2:	669c                	ld	a5,8(a3)
ffffffffc02012d4:	9db9                	addw	a1,a1,a4
ffffffffc02012d6:	00005717          	auipc	a4,0x5
ffffffffc02012da:	1ab72123          	sw	a1,418(a4) # ffffffffc0206478 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02012de:	08d78f63          	beq	a5,a3,ffffffffc020137c <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02012e2:	fe878713          	addi	a4,a5,-24
ffffffffc02012e6:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012e8:	4801                	li	a6,0
ffffffffc02012ea:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02012ee:	00e56a63          	bltu	a0,a4,ffffffffc0201302 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc02012f2:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012f4:	02d70563          	beq	a4,a3,ffffffffc020131e <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02012f8:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012fa:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02012fe:	fee57ae3          	bleu	a4,a0,ffffffffc02012f2 <best_fit_free_pages+0x84>
ffffffffc0201302:	00080663          	beqz	a6,ffffffffc020130e <best_fit_free_pages+0xa0>
ffffffffc0201306:	00005817          	auipc	a6,0x5
ffffffffc020130a:	16b83123          	sd	a1,354(a6) # ffffffffc0206468 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020130e:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201310:	e390                	sd	a2,0(a5)
ffffffffc0201312:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201314:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201316:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201318:	02d59163          	bne	a1,a3,ffffffffc020133a <best_fit_free_pages+0xcc>
ffffffffc020131c:	a091                	j	ffffffffc0201360 <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc020131e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201320:	f114                	sd	a3,32(a0)
ffffffffc0201322:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201324:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201326:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201328:	00d70563          	beq	a4,a3,ffffffffc0201332 <best_fit_free_pages+0xc4>
ffffffffc020132c:	4805                	li	a6,1
ffffffffc020132e:	87ba                	mv	a5,a4
ffffffffc0201330:	b7e9                	j	ffffffffc02012fa <best_fit_free_pages+0x8c>
ffffffffc0201332:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201334:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201336:	02d78163          	beq	a5,a3,ffffffffc0201358 <best_fit_free_pages+0xea>
        if (p + p->property == base){
ffffffffc020133a:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc020133e:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base){
ffffffffc0201342:	02081713          	slli	a4,a6,0x20
ffffffffc0201346:	9301                	srli	a4,a4,0x20
ffffffffc0201348:	00271793          	slli	a5,a4,0x2
ffffffffc020134c:	97ba                	add	a5,a5,a4
ffffffffc020134e:	078e                	slli	a5,a5,0x3
ffffffffc0201350:	97b2                	add	a5,a5,a2
ffffffffc0201352:	02f50e63          	beq	a0,a5,ffffffffc020138e <best_fit_free_pages+0x120>
ffffffffc0201356:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201358:	fe878713          	addi	a4,a5,-24
ffffffffc020135c:	00d78d63          	beq	a5,a3,ffffffffc0201376 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201360:	490c                	lw	a1,16(a0)
ffffffffc0201362:	02059613          	slli	a2,a1,0x20
ffffffffc0201366:	9201                	srli	a2,a2,0x20
ffffffffc0201368:	00261693          	slli	a3,a2,0x2
ffffffffc020136c:	96b2                	add	a3,a3,a2
ffffffffc020136e:	068e                	slli	a3,a3,0x3
ffffffffc0201370:	96aa                	add	a3,a3,a0
ffffffffc0201372:	04d70063          	beq	a4,a3,ffffffffc02013b2 <best_fit_free_pages+0x144>
}
ffffffffc0201376:	60a2                	ld	ra,8(sp)
ffffffffc0201378:	0141                	addi	sp,sp,16
ffffffffc020137a:	8082                	ret
ffffffffc020137c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020137e:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201382:	e398                	sd	a4,0(a5)
ffffffffc0201384:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201386:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201388:	ed1c                	sd	a5,24(a0)
}
ffffffffc020138a:	0141                	addi	sp,sp,16
ffffffffc020138c:	8082                	ret
            p->property += base->property;
ffffffffc020138e:	491c                	lw	a5,16(a0)
ffffffffc0201390:	0107883b          	addw	a6,a5,a6
ffffffffc0201394:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201398:	57f5                	li	a5,-3
ffffffffc020139a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020139e:	01853803          	ld	a6,24(a0)
ffffffffc02013a2:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc02013a4:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02013a6:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02013aa:	659c                	ld	a5,8(a1)
ffffffffc02013ac:	01073023          	sd	a6,0(a4)
ffffffffc02013b0:	b765                	j	ffffffffc0201358 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc02013b2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013b6:	ff078693          	addi	a3,a5,-16
ffffffffc02013ba:	9db9                	addw	a1,a1,a4
ffffffffc02013bc:	c90c                	sw	a1,16(a0)
ffffffffc02013be:	5775                	li	a4,-3
ffffffffc02013c0:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013c4:	6398                	ld	a4,0(a5)
ffffffffc02013c6:	679c                	ld	a5,8(a5)
}
ffffffffc02013c8:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013ca:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02013cc:	e398                	sd	a4,0(a5)
ffffffffc02013ce:	0141                	addi	sp,sp,16
ffffffffc02013d0:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013d2:	00001697          	auipc	a3,0x1
ffffffffc02013d6:	3a668693          	addi	a3,a3,934 # ffffffffc0202778 <commands+0xab0>
ffffffffc02013da:	00001617          	auipc	a2,0x1
ffffffffc02013de:	0be60613          	addi	a2,a2,190 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02013e2:	09400593          	li	a1,148
ffffffffc02013e6:	00001517          	auipc	a0,0x1
ffffffffc02013ea:	0ca50513          	addi	a0,a0,202 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc02013ee:	d51fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc02013f2:	00001697          	auipc	a3,0x1
ffffffffc02013f6:	3ae68693          	addi	a3,a3,942 # ffffffffc02027a0 <commands+0xad8>
ffffffffc02013fa:	00001617          	auipc	a2,0x1
ffffffffc02013fe:	09e60613          	addi	a2,a2,158 # ffffffffc0202498 <commands+0x7d0>
ffffffffc0201402:	09100593          	li	a1,145
ffffffffc0201406:	00001517          	auipc	a0,0x1
ffffffffc020140a:	0aa50513          	addi	a0,a0,170 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc020140e:	d31fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0201412 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0201412:	c145                	beqz	a0,ffffffffc02014b2 <best_fit_alloc_pages+0xa0>
    if (n > nr_free) {
ffffffffc0201414:	00005617          	auipc	a2,0x5
ffffffffc0201418:	05460613          	addi	a2,a2,84 # ffffffffc0206468 <free_area>
ffffffffc020141c:	01062803          	lw	a6,16(a2)
ffffffffc0201420:	86aa                	mv	a3,a0
ffffffffc0201422:	02081793          	slli	a5,a6,0x20
ffffffffc0201426:	9381                	srli	a5,a5,0x20
ffffffffc0201428:	08a7e363          	bltu	a5,a0,ffffffffc02014ae <best_fit_alloc_pages+0x9c>
    size_t best_size = ~(size_t)0;
ffffffffc020142c:	55fd                	li	a1,-1
    list_entry_t *le = &free_list;
ffffffffc020142e:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc0201430:	4501                	li	a0,0
    return listelm->next;
ffffffffc0201432:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201434:	00c78e63          	beq	a5,a2,ffffffffc0201450 <best_fit_alloc_pages+0x3e>
        if (p->property >= n && p->property < best_size) {
ffffffffc0201438:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020143c:	fed76be3          	bltu	a4,a3,ffffffffc0201432 <best_fit_alloc_pages+0x20>
ffffffffc0201440:	feb779e3          	bleu	a1,a4,ffffffffc0201432 <best_fit_alloc_pages+0x20>
        struct Page *p = le2page(le, page_link);
ffffffffc0201444:	fe878513          	addi	a0,a5,-24
ffffffffc0201448:	679c                	ld	a5,8(a5)
ffffffffc020144a:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020144c:	fec796e3          	bne	a5,a2,ffffffffc0201438 <best_fit_alloc_pages+0x26>
    if (page != NULL) {
ffffffffc0201450:	c125                	beqz	a0,ffffffffc02014b0 <best_fit_alloc_pages+0x9e>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201452:	7118                	ld	a4,32(a0)
    return listelm->prev;
ffffffffc0201454:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0201456:	490c                	lw	a1,16(a0)
ffffffffc0201458:	0006889b          	sext.w	a7,a3
    prev->next = next;
ffffffffc020145c:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc020145e:	e310                	sd	a2,0(a4)
ffffffffc0201460:	02059713          	slli	a4,a1,0x20
ffffffffc0201464:	9301                	srli	a4,a4,0x20
ffffffffc0201466:	02e6f863          	bleu	a4,a3,ffffffffc0201496 <best_fit_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020146a:	00269713          	slli	a4,a3,0x2
ffffffffc020146e:	9736                	add	a4,a4,a3
ffffffffc0201470:	070e                	slli	a4,a4,0x3
ffffffffc0201472:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201474:	411585bb          	subw	a1,a1,a7
ffffffffc0201478:	cb0c                	sw	a1,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020147a:	4689                	li	a3,2
ffffffffc020147c:	00870593          	addi	a1,a4,8
ffffffffc0201480:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201484:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc0201486:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc020148a:	0107a803          	lw	a6,16(a5)
ffffffffc020148e:	e28c                	sd	a1,0(a3)
ffffffffc0201490:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc0201492:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201494:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc0201496:	4118083b          	subw	a6,a6,a7
ffffffffc020149a:	00005797          	auipc	a5,0x5
ffffffffc020149e:	fd07af23          	sw	a6,-34(a5) # ffffffffc0206478 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02014a2:	57f5                	li	a5,-3
ffffffffc02014a4:	00850713          	addi	a4,a0,8
ffffffffc02014a8:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc02014ac:	8082                	ret
        return NULL;
ffffffffc02014ae:	4501                	li	a0,0
}
ffffffffc02014b0:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02014b2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014b4:	00001697          	auipc	a3,0x1
ffffffffc02014b8:	2ec68693          	addi	a3,a3,748 # ffffffffc02027a0 <commands+0xad8>
ffffffffc02014bc:	00001617          	auipc	a2,0x1
ffffffffc02014c0:	fdc60613          	addi	a2,a2,-36 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02014c4:	06b00593          	li	a1,107
ffffffffc02014c8:	00001517          	auipc	a0,0x1
ffffffffc02014cc:	fe850513          	addi	a0,a0,-24 # ffffffffc02024b0 <commands+0x7e8>
best_fit_alloc_pages(size_t n) {
ffffffffc02014d0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014d2:	c6dfe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02014d6 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02014d6:	1141                	addi	sp,sp,-16
ffffffffc02014d8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014da:	c1fd                	beqz	a1,ffffffffc02015c0 <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02014dc:	00259693          	slli	a3,a1,0x2
ffffffffc02014e0:	96ae                	add	a3,a3,a1
ffffffffc02014e2:	068e                	slli	a3,a3,0x3
ffffffffc02014e4:	96aa                	add	a3,a3,a0
ffffffffc02014e6:	02d50463          	beq	a0,a3,ffffffffc020150e <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014ea:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02014ec:	87aa                	mv	a5,a0
ffffffffc02014ee:	8b05                	andi	a4,a4,1
ffffffffc02014f0:	e709                	bnez	a4,ffffffffc02014fa <best_fit_init_memmap+0x24>
ffffffffc02014f2:	a07d                	j	ffffffffc02015a0 <best_fit_init_memmap+0xca>
ffffffffc02014f4:	6798                	ld	a4,8(a5)
ffffffffc02014f6:	8b05                	andi	a4,a4,1
ffffffffc02014f8:	c745                	beqz	a4,ffffffffc02015a0 <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02014fa:	0007a823          	sw	zero,16(a5)
ffffffffc02014fe:	0007b423          	sd	zero,8(a5)
ffffffffc0201502:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201506:	02878793          	addi	a5,a5,40
ffffffffc020150a:	fed795e3          	bne	a5,a3,ffffffffc02014f4 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc020150e:	2581                	sext.w	a1,a1
ffffffffc0201510:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201512:	4789                	li	a5,2
ffffffffc0201514:	00850713          	addi	a4,a0,8
ffffffffc0201518:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020151c:	00005697          	auipc	a3,0x5
ffffffffc0201520:	f4c68693          	addi	a3,a3,-180 # ffffffffc0206468 <free_area>
ffffffffc0201524:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201526:	669c                	ld	a5,8(a3)
ffffffffc0201528:	9db9                	addw	a1,a1,a4
ffffffffc020152a:	00005717          	auipc	a4,0x5
ffffffffc020152e:	f4b72723          	sw	a1,-178(a4) # ffffffffc0206478 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201532:	04d78a63          	beq	a5,a3,ffffffffc0201586 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201536:	fe878713          	addi	a4,a5,-24
ffffffffc020153a:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020153c:	4801                	li	a6,0
ffffffffc020153e:	01850613          	addi	a2,a0,24
            if (base < page){
ffffffffc0201542:	00e56a63          	bltu	a0,a4,ffffffffc0201556 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc0201546:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list){
ffffffffc0201548:	02d70563          	beq	a4,a3,ffffffffc0201572 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020154c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020154e:	fe878713          	addi	a4,a5,-24
            if (base < page){
ffffffffc0201552:	fee57ae3          	bleu	a4,a0,ffffffffc0201546 <best_fit_init_memmap+0x70>
ffffffffc0201556:	00080663          	beqz	a6,ffffffffc0201562 <best_fit_init_memmap+0x8c>
ffffffffc020155a:	00005717          	auipc	a4,0x5
ffffffffc020155e:	f0b73723          	sd	a1,-242(a4) # ffffffffc0206468 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201562:	6398                	ld	a4,0(a5)
}
ffffffffc0201564:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201566:	e390                	sd	a2,0(a5)
ffffffffc0201568:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020156a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020156c:	ed18                	sd	a4,24(a0)
ffffffffc020156e:	0141                	addi	sp,sp,16
ffffffffc0201570:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201572:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201574:	f114                	sd	a3,32(a0)
ffffffffc0201576:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201578:	ed1c                	sd	a5,24(a0)
            	list_add(le, &(base->page_link));
ffffffffc020157a:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020157c:	00d70e63          	beq	a4,a3,ffffffffc0201598 <best_fit_init_memmap+0xc2>
ffffffffc0201580:	4805                	li	a6,1
ffffffffc0201582:	87ba                	mv	a5,a4
ffffffffc0201584:	b7e9                	j	ffffffffc020154e <best_fit_init_memmap+0x78>
}
ffffffffc0201586:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201588:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020158c:	e398                	sd	a4,0(a5)
ffffffffc020158e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201590:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201592:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201594:	0141                	addi	sp,sp,16
ffffffffc0201596:	8082                	ret
ffffffffc0201598:	60a2                	ld	ra,8(sp)
ffffffffc020159a:	e290                	sd	a2,0(a3)
ffffffffc020159c:	0141                	addi	sp,sp,16
ffffffffc020159e:	8082                	ret
        assert(PageReserved(p));
ffffffffc02015a0:	00001697          	auipc	a3,0x1
ffffffffc02015a4:	20868693          	addi	a3,a3,520 # ffffffffc02027a8 <commands+0xae0>
ffffffffc02015a8:	00001617          	auipc	a2,0x1
ffffffffc02015ac:	ef060613          	addi	a2,a2,-272 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02015b0:	04a00593          	li	a1,74
ffffffffc02015b4:	00001517          	auipc	a0,0x1
ffffffffc02015b8:	efc50513          	addi	a0,a0,-260 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc02015bc:	b83fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc02015c0:	00001697          	auipc	a3,0x1
ffffffffc02015c4:	1e068693          	addi	a3,a3,480 # ffffffffc02027a0 <commands+0xad8>
ffffffffc02015c8:	00001617          	auipc	a2,0x1
ffffffffc02015cc:	ed060613          	addi	a2,a2,-304 # ffffffffc0202498 <commands+0x7d0>
ffffffffc02015d0:	04700593          	li	a1,71
ffffffffc02015d4:	00001517          	auipc	a0,0x1
ffffffffc02015d8:	edc50513          	addi	a0,a0,-292 # ffffffffc02024b0 <commands+0x7e8>
ffffffffc02015dc:	b63fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02015e0 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015e0:	c185                	beqz	a1,ffffffffc0201600 <strnlen+0x20>
ffffffffc02015e2:	00054783          	lbu	a5,0(a0)
ffffffffc02015e6:	cf89                	beqz	a5,ffffffffc0201600 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02015e8:	4781                	li	a5,0
ffffffffc02015ea:	a021                	j	ffffffffc02015f2 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015ec:	00074703          	lbu	a4,0(a4)
ffffffffc02015f0:	c711                	beqz	a4,ffffffffc02015fc <strnlen+0x1c>
        cnt ++;
ffffffffc02015f2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015f4:	00f50733          	add	a4,a0,a5
ffffffffc02015f8:	fef59ae3          	bne	a1,a5,ffffffffc02015ec <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02015fc:	853e                	mv	a0,a5
ffffffffc02015fe:	8082                	ret
    size_t cnt = 0;
ffffffffc0201600:	4781                	li	a5,0
}
ffffffffc0201602:	853e                	mv	a0,a5
ffffffffc0201604:	8082                	ret

ffffffffc0201606 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201606:	00054783          	lbu	a5,0(a0)
ffffffffc020160a:	0005c703          	lbu	a4,0(a1)
ffffffffc020160e:	cb91                	beqz	a5,ffffffffc0201622 <strcmp+0x1c>
ffffffffc0201610:	00e79c63          	bne	a5,a4,ffffffffc0201628 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201614:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201616:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020161a:	0585                	addi	a1,a1,1
ffffffffc020161c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201620:	fbe5                	bnez	a5,ffffffffc0201610 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201622:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201624:	9d19                	subw	a0,a0,a4
ffffffffc0201626:	8082                	ret
ffffffffc0201628:	0007851b          	sext.w	a0,a5
ffffffffc020162c:	9d19                	subw	a0,a0,a4
ffffffffc020162e:	8082                	ret

ffffffffc0201630 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201630:	00054783          	lbu	a5,0(a0)
ffffffffc0201634:	cb91                	beqz	a5,ffffffffc0201648 <strchr+0x18>
        if (*s == c) {
ffffffffc0201636:	00b79563          	bne	a5,a1,ffffffffc0201640 <strchr+0x10>
ffffffffc020163a:	a809                	j	ffffffffc020164c <strchr+0x1c>
ffffffffc020163c:	00b78763          	beq	a5,a1,ffffffffc020164a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201640:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201642:	00054783          	lbu	a5,0(a0)
ffffffffc0201646:	fbfd                	bnez	a5,ffffffffc020163c <strchr+0xc>
    }
    return NULL;
ffffffffc0201648:	4501                	li	a0,0
}
ffffffffc020164a:	8082                	ret
ffffffffc020164c:	8082                	ret

ffffffffc020164e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020164e:	ca01                	beqz	a2,ffffffffc020165e <memset+0x10>
ffffffffc0201650:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201652:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201654:	0785                	addi	a5,a5,1
ffffffffc0201656:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020165a:	fec79de3          	bne	a5,a2,ffffffffc0201654 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020165e:	8082                	ret

ffffffffc0201660 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201660:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201664:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201666:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020166a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020166c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201670:	f022                	sd	s0,32(sp)
ffffffffc0201672:	ec26                	sd	s1,24(sp)
ffffffffc0201674:	e84a                	sd	s2,16(sp)
ffffffffc0201676:	f406                	sd	ra,40(sp)
ffffffffc0201678:	e44e                	sd	s3,8(sp)
ffffffffc020167a:	84aa                	mv	s1,a0
ffffffffc020167c:	892e                	mv	s2,a1
ffffffffc020167e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201682:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201684:	03067e63          	bleu	a6,a2,ffffffffc02016c0 <printnum+0x60>
ffffffffc0201688:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020168a:	00805763          	blez	s0,ffffffffc0201698 <printnum+0x38>
ffffffffc020168e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201690:	85ca                	mv	a1,s2
ffffffffc0201692:	854e                	mv	a0,s3
ffffffffc0201694:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201696:	fc65                	bnez	s0,ffffffffc020168e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201698:	1a02                	slli	s4,s4,0x20
ffffffffc020169a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020169e:	00001797          	auipc	a5,0x1
ffffffffc02016a2:	2fa78793          	addi	a5,a5,762 # ffffffffc0202998 <error_string+0x38>
ffffffffc02016a6:	9a3e                	add	s4,s4,a5
}
ffffffffc02016a8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016aa:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02016ae:	70a2                	ld	ra,40(sp)
ffffffffc02016b0:	69a2                	ld	s3,8(sp)
ffffffffc02016b2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016b4:	85ca                	mv	a1,s2
ffffffffc02016b6:	8326                	mv	t1,s1
}
ffffffffc02016b8:	6942                	ld	s2,16(sp)
ffffffffc02016ba:	64e2                	ld	s1,24(sp)
ffffffffc02016bc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016be:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02016c0:	03065633          	divu	a2,a2,a6
ffffffffc02016c4:	8722                	mv	a4,s0
ffffffffc02016c6:	f9bff0ef          	jal	ra,ffffffffc0201660 <printnum>
ffffffffc02016ca:	b7f9                	j	ffffffffc0201698 <printnum+0x38>

ffffffffc02016cc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02016cc:	7119                	addi	sp,sp,-128
ffffffffc02016ce:	f4a6                	sd	s1,104(sp)
ffffffffc02016d0:	f0ca                	sd	s2,96(sp)
ffffffffc02016d2:	e8d2                	sd	s4,80(sp)
ffffffffc02016d4:	e4d6                	sd	s5,72(sp)
ffffffffc02016d6:	e0da                	sd	s6,64(sp)
ffffffffc02016d8:	fc5e                	sd	s7,56(sp)
ffffffffc02016da:	f862                	sd	s8,48(sp)
ffffffffc02016dc:	f06a                	sd	s10,32(sp)
ffffffffc02016de:	fc86                	sd	ra,120(sp)
ffffffffc02016e0:	f8a2                	sd	s0,112(sp)
ffffffffc02016e2:	ecce                	sd	s3,88(sp)
ffffffffc02016e4:	f466                	sd	s9,40(sp)
ffffffffc02016e6:	ec6e                	sd	s11,24(sp)
ffffffffc02016e8:	892a                	mv	s2,a0
ffffffffc02016ea:	84ae                	mv	s1,a1
ffffffffc02016ec:	8d32                	mv	s10,a2
ffffffffc02016ee:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02016f0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f2:	00001a17          	auipc	s4,0x1
ffffffffc02016f6:	116a0a13          	addi	s4,s4,278 # ffffffffc0202808 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016fa:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016fe:	00001c17          	auipc	s8,0x1
ffffffffc0201702:	262c0c13          	addi	s8,s8,610 # ffffffffc0202960 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201706:	000d4503          	lbu	a0,0(s10)
ffffffffc020170a:	02500793          	li	a5,37
ffffffffc020170e:	001d0413          	addi	s0,s10,1
ffffffffc0201712:	00f50e63          	beq	a0,a5,ffffffffc020172e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201716:	c521                	beqz	a0,ffffffffc020175e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201718:	02500993          	li	s3,37
ffffffffc020171c:	a011                	j	ffffffffc0201720 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020171e:	c121                	beqz	a0,ffffffffc020175e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201720:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201722:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201724:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201726:	fff44503          	lbu	a0,-1(s0)
ffffffffc020172a:	ff351ae3          	bne	a0,s3,ffffffffc020171e <vprintfmt+0x52>
ffffffffc020172e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201732:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201736:	4981                	li	s3,0
ffffffffc0201738:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020173a:	5cfd                	li	s9,-1
ffffffffc020173c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020173e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201742:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201744:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201748:	0ff6f693          	andi	a3,a3,255
ffffffffc020174c:	00140d13          	addi	s10,s0,1
ffffffffc0201750:	20d5e563          	bltu	a1,a3,ffffffffc020195a <vprintfmt+0x28e>
ffffffffc0201754:	068a                	slli	a3,a3,0x2
ffffffffc0201756:	96d2                	add	a3,a3,s4
ffffffffc0201758:	4294                	lw	a3,0(a3)
ffffffffc020175a:	96d2                	add	a3,a3,s4
ffffffffc020175c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020175e:	70e6                	ld	ra,120(sp)
ffffffffc0201760:	7446                	ld	s0,112(sp)
ffffffffc0201762:	74a6                	ld	s1,104(sp)
ffffffffc0201764:	7906                	ld	s2,96(sp)
ffffffffc0201766:	69e6                	ld	s3,88(sp)
ffffffffc0201768:	6a46                	ld	s4,80(sp)
ffffffffc020176a:	6aa6                	ld	s5,72(sp)
ffffffffc020176c:	6b06                	ld	s6,64(sp)
ffffffffc020176e:	7be2                	ld	s7,56(sp)
ffffffffc0201770:	7c42                	ld	s8,48(sp)
ffffffffc0201772:	7ca2                	ld	s9,40(sp)
ffffffffc0201774:	7d02                	ld	s10,32(sp)
ffffffffc0201776:	6de2                	ld	s11,24(sp)
ffffffffc0201778:	6109                	addi	sp,sp,128
ffffffffc020177a:	8082                	ret
    if (lflag >= 2) {
ffffffffc020177c:	4705                	li	a4,1
ffffffffc020177e:	008a8593          	addi	a1,s5,8
ffffffffc0201782:	01074463          	blt	a4,a6,ffffffffc020178a <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201786:	26080363          	beqz	a6,ffffffffc02019ec <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020178a:	000ab603          	ld	a2,0(s5)
ffffffffc020178e:	46c1                	li	a3,16
ffffffffc0201790:	8aae                	mv	s5,a1
ffffffffc0201792:	a06d                	j	ffffffffc020183c <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201794:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201798:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020179a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020179c:	b765                	j	ffffffffc0201744 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020179e:	000aa503          	lw	a0,0(s5)
ffffffffc02017a2:	85a6                	mv	a1,s1
ffffffffc02017a4:	0aa1                	addi	s5,s5,8
ffffffffc02017a6:	9902                	jalr	s2
            break;
ffffffffc02017a8:	bfb9                	j	ffffffffc0201706 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017aa:	4705                	li	a4,1
ffffffffc02017ac:	008a8993          	addi	s3,s5,8
ffffffffc02017b0:	01074463          	blt	a4,a6,ffffffffc02017b8 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02017b4:	22080463          	beqz	a6,ffffffffc02019dc <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02017b8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02017bc:	24044463          	bltz	s0,ffffffffc0201a04 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02017c0:	8622                	mv	a2,s0
ffffffffc02017c2:	8ace                	mv	s5,s3
ffffffffc02017c4:	46a9                	li	a3,10
ffffffffc02017c6:	a89d                	j	ffffffffc020183c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02017c8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017cc:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02017ce:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02017d0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02017d4:	8fb5                	xor	a5,a5,a3
ffffffffc02017d6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017da:	1ad74363          	blt	a4,a3,ffffffffc0201980 <vprintfmt+0x2b4>
ffffffffc02017de:	00369793          	slli	a5,a3,0x3
ffffffffc02017e2:	97e2                	add	a5,a5,s8
ffffffffc02017e4:	639c                	ld	a5,0(a5)
ffffffffc02017e6:	18078d63          	beqz	a5,ffffffffc0201980 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02017ea:	86be                	mv	a3,a5
ffffffffc02017ec:	00001617          	auipc	a2,0x1
ffffffffc02017f0:	25c60613          	addi	a2,a2,604 # ffffffffc0202a48 <error_string+0xe8>
ffffffffc02017f4:	85a6                	mv	a1,s1
ffffffffc02017f6:	854a                	mv	a0,s2
ffffffffc02017f8:	240000ef          	jal	ra,ffffffffc0201a38 <printfmt>
ffffffffc02017fc:	b729                	j	ffffffffc0201706 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02017fe:	00144603          	lbu	a2,1(s0)
ffffffffc0201802:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201804:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201806:	bf3d                	j	ffffffffc0201744 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201808:	4705                	li	a4,1
ffffffffc020180a:	008a8593          	addi	a1,s5,8
ffffffffc020180e:	01074463          	blt	a4,a6,ffffffffc0201816 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201812:	1e080263          	beqz	a6,ffffffffc02019f6 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201816:	000ab603          	ld	a2,0(s5)
ffffffffc020181a:	46a1                	li	a3,8
ffffffffc020181c:	8aae                	mv	s5,a1
ffffffffc020181e:	a839                	j	ffffffffc020183c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201820:	03000513          	li	a0,48
ffffffffc0201824:	85a6                	mv	a1,s1
ffffffffc0201826:	e03e                	sd	a5,0(sp)
ffffffffc0201828:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020182a:	85a6                	mv	a1,s1
ffffffffc020182c:	07800513          	li	a0,120
ffffffffc0201830:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201832:	0aa1                	addi	s5,s5,8
ffffffffc0201834:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201838:	6782                	ld	a5,0(sp)
ffffffffc020183a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020183c:	876e                	mv	a4,s11
ffffffffc020183e:	85a6                	mv	a1,s1
ffffffffc0201840:	854a                	mv	a0,s2
ffffffffc0201842:	e1fff0ef          	jal	ra,ffffffffc0201660 <printnum>
            break;
ffffffffc0201846:	b5c1                	j	ffffffffc0201706 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201848:	000ab603          	ld	a2,0(s5)
ffffffffc020184c:	0aa1                	addi	s5,s5,8
ffffffffc020184e:	1c060663          	beqz	a2,ffffffffc0201a1a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201852:	00160413          	addi	s0,a2,1
ffffffffc0201856:	17b05c63          	blez	s11,ffffffffc02019ce <vprintfmt+0x302>
ffffffffc020185a:	02d00593          	li	a1,45
ffffffffc020185e:	14b79263          	bne	a5,a1,ffffffffc02019a2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201862:	00064783          	lbu	a5,0(a2)
ffffffffc0201866:	0007851b          	sext.w	a0,a5
ffffffffc020186a:	c905                	beqz	a0,ffffffffc020189a <vprintfmt+0x1ce>
ffffffffc020186c:	000cc563          	bltz	s9,ffffffffc0201876 <vprintfmt+0x1aa>
ffffffffc0201870:	3cfd                	addiw	s9,s9,-1
ffffffffc0201872:	036c8263          	beq	s9,s6,ffffffffc0201896 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201876:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201878:	18098463          	beqz	s3,ffffffffc0201a00 <vprintfmt+0x334>
ffffffffc020187c:	3781                	addiw	a5,a5,-32
ffffffffc020187e:	18fbf163          	bleu	a5,s7,ffffffffc0201a00 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201882:	03f00513          	li	a0,63
ffffffffc0201886:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201888:	0405                	addi	s0,s0,1
ffffffffc020188a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020188e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201890:	0007851b          	sext.w	a0,a5
ffffffffc0201894:	fd61                	bnez	a0,ffffffffc020186c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201896:	e7b058e3          	blez	s11,ffffffffc0201706 <vprintfmt+0x3a>
ffffffffc020189a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020189c:	85a6                	mv	a1,s1
ffffffffc020189e:	02000513          	li	a0,32
ffffffffc02018a2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018a4:	e60d81e3          	beqz	s11,ffffffffc0201706 <vprintfmt+0x3a>
ffffffffc02018a8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018aa:	85a6                	mv	a1,s1
ffffffffc02018ac:	02000513          	li	a0,32
ffffffffc02018b0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018b2:	fe0d94e3          	bnez	s11,ffffffffc020189a <vprintfmt+0x1ce>
ffffffffc02018b6:	bd81                	j	ffffffffc0201706 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02018b8:	4705                	li	a4,1
ffffffffc02018ba:	008a8593          	addi	a1,s5,8
ffffffffc02018be:	01074463          	blt	a4,a6,ffffffffc02018c6 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02018c2:	12080063          	beqz	a6,ffffffffc02019e2 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02018c6:	000ab603          	ld	a2,0(s5)
ffffffffc02018ca:	46a9                	li	a3,10
ffffffffc02018cc:	8aae                	mv	s5,a1
ffffffffc02018ce:	b7bd                	j	ffffffffc020183c <vprintfmt+0x170>
ffffffffc02018d0:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02018d4:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018d8:	846a                	mv	s0,s10
ffffffffc02018da:	b5ad                	j	ffffffffc0201744 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02018dc:	85a6                	mv	a1,s1
ffffffffc02018de:	02500513          	li	a0,37
ffffffffc02018e2:	9902                	jalr	s2
            break;
ffffffffc02018e4:	b50d                	j	ffffffffc0201706 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02018e6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02018ea:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02018ee:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018f0:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02018f2:	e40dd9e3          	bgez	s11,ffffffffc0201744 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02018f6:	8de6                	mv	s11,s9
ffffffffc02018f8:	5cfd                	li	s9,-1
ffffffffc02018fa:	b5a9                	j	ffffffffc0201744 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02018fc:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201900:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201904:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201906:	bd3d                	j	ffffffffc0201744 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201908:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020190c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201910:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201912:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201916:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020191a:	fcd56ce3          	bltu	a0,a3,ffffffffc02018f2 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020191e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201920:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201924:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201928:	0196873b          	addw	a4,a3,s9
ffffffffc020192c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201930:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201934:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201938:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020193c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201940:	fcd57fe3          	bleu	a3,a0,ffffffffc020191e <vprintfmt+0x252>
ffffffffc0201944:	b77d                	j	ffffffffc02018f2 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201946:	fffdc693          	not	a3,s11
ffffffffc020194a:	96fd                	srai	a3,a3,0x3f
ffffffffc020194c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201950:	00144603          	lbu	a2,1(s0)
ffffffffc0201954:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201956:	846a                	mv	s0,s10
ffffffffc0201958:	b3f5                	j	ffffffffc0201744 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020195a:	85a6                	mv	a1,s1
ffffffffc020195c:	02500513          	li	a0,37
ffffffffc0201960:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201962:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201966:	02500793          	li	a5,37
ffffffffc020196a:	8d22                	mv	s10,s0
ffffffffc020196c:	d8f70de3          	beq	a4,a5,ffffffffc0201706 <vprintfmt+0x3a>
ffffffffc0201970:	02500713          	li	a4,37
ffffffffc0201974:	1d7d                	addi	s10,s10,-1
ffffffffc0201976:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020197a:	fee79de3          	bne	a5,a4,ffffffffc0201974 <vprintfmt+0x2a8>
ffffffffc020197e:	b361                	j	ffffffffc0201706 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201980:	00001617          	auipc	a2,0x1
ffffffffc0201984:	0b860613          	addi	a2,a2,184 # ffffffffc0202a38 <error_string+0xd8>
ffffffffc0201988:	85a6                	mv	a1,s1
ffffffffc020198a:	854a                	mv	a0,s2
ffffffffc020198c:	0ac000ef          	jal	ra,ffffffffc0201a38 <printfmt>
ffffffffc0201990:	bb9d                	j	ffffffffc0201706 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201992:	00001617          	auipc	a2,0x1
ffffffffc0201996:	09e60613          	addi	a2,a2,158 # ffffffffc0202a30 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020199a:	00001417          	auipc	s0,0x1
ffffffffc020199e:	09740413          	addi	s0,s0,151 # ffffffffc0202a31 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019a2:	8532                	mv	a0,a2
ffffffffc02019a4:	85e6                	mv	a1,s9
ffffffffc02019a6:	e032                	sd	a2,0(sp)
ffffffffc02019a8:	e43e                	sd	a5,8(sp)
ffffffffc02019aa:	c37ff0ef          	jal	ra,ffffffffc02015e0 <strnlen>
ffffffffc02019ae:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02019b2:	6602                	ld	a2,0(sp)
ffffffffc02019b4:	01b05d63          	blez	s11,ffffffffc02019ce <vprintfmt+0x302>
ffffffffc02019b8:	67a2                	ld	a5,8(sp)
ffffffffc02019ba:	2781                	sext.w	a5,a5
ffffffffc02019bc:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02019be:	6522                	ld	a0,8(sp)
ffffffffc02019c0:	85a6                	mv	a1,s1
ffffffffc02019c2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019c4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02019c6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019c8:	6602                	ld	a2,0(sp)
ffffffffc02019ca:	fe0d9ae3          	bnez	s11,ffffffffc02019be <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019ce:	00064783          	lbu	a5,0(a2)
ffffffffc02019d2:	0007851b          	sext.w	a0,a5
ffffffffc02019d6:	e8051be3          	bnez	a0,ffffffffc020186c <vprintfmt+0x1a0>
ffffffffc02019da:	b335                	j	ffffffffc0201706 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02019dc:	000aa403          	lw	s0,0(s5)
ffffffffc02019e0:	bbf1                	j	ffffffffc02017bc <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02019e2:	000ae603          	lwu	a2,0(s5)
ffffffffc02019e6:	46a9                	li	a3,10
ffffffffc02019e8:	8aae                	mv	s5,a1
ffffffffc02019ea:	bd89                	j	ffffffffc020183c <vprintfmt+0x170>
ffffffffc02019ec:	000ae603          	lwu	a2,0(s5)
ffffffffc02019f0:	46c1                	li	a3,16
ffffffffc02019f2:	8aae                	mv	s5,a1
ffffffffc02019f4:	b5a1                	j	ffffffffc020183c <vprintfmt+0x170>
ffffffffc02019f6:	000ae603          	lwu	a2,0(s5)
ffffffffc02019fa:	46a1                	li	a3,8
ffffffffc02019fc:	8aae                	mv	s5,a1
ffffffffc02019fe:	bd3d                	j	ffffffffc020183c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201a00:	9902                	jalr	s2
ffffffffc0201a02:	b559                	j	ffffffffc0201888 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201a04:	85a6                	mv	a1,s1
ffffffffc0201a06:	02d00513          	li	a0,45
ffffffffc0201a0a:	e03e                	sd	a5,0(sp)
ffffffffc0201a0c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201a0e:	8ace                	mv	s5,s3
ffffffffc0201a10:	40800633          	neg	a2,s0
ffffffffc0201a14:	46a9                	li	a3,10
ffffffffc0201a16:	6782                	ld	a5,0(sp)
ffffffffc0201a18:	b515                	j	ffffffffc020183c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201a1a:	01b05663          	blez	s11,ffffffffc0201a26 <vprintfmt+0x35a>
ffffffffc0201a1e:	02d00693          	li	a3,45
ffffffffc0201a22:	f6d798e3          	bne	a5,a3,ffffffffc0201992 <vprintfmt+0x2c6>
ffffffffc0201a26:	00001417          	auipc	s0,0x1
ffffffffc0201a2a:	00b40413          	addi	s0,s0,11 # ffffffffc0202a31 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a2e:	02800513          	li	a0,40
ffffffffc0201a32:	02800793          	li	a5,40
ffffffffc0201a36:	bd1d                	j	ffffffffc020186c <vprintfmt+0x1a0>

ffffffffc0201a38 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a38:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201a3a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a3e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a40:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a42:	ec06                	sd	ra,24(sp)
ffffffffc0201a44:	f83a                	sd	a4,48(sp)
ffffffffc0201a46:	fc3e                	sd	a5,56(sp)
ffffffffc0201a48:	e0c2                	sd	a6,64(sp)
ffffffffc0201a4a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a4c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a4e:	c7fff0ef          	jal	ra,ffffffffc02016cc <vprintfmt>
}
ffffffffc0201a52:	60e2                	ld	ra,24(sp)
ffffffffc0201a54:	6161                	addi	sp,sp,80
ffffffffc0201a56:	8082                	ret

ffffffffc0201a58 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a58:	715d                	addi	sp,sp,-80
ffffffffc0201a5a:	e486                	sd	ra,72(sp)
ffffffffc0201a5c:	e0a2                	sd	s0,64(sp)
ffffffffc0201a5e:	fc26                	sd	s1,56(sp)
ffffffffc0201a60:	f84a                	sd	s2,48(sp)
ffffffffc0201a62:	f44e                	sd	s3,40(sp)
ffffffffc0201a64:	f052                	sd	s4,32(sp)
ffffffffc0201a66:	ec56                	sd	s5,24(sp)
ffffffffc0201a68:	e85a                	sd	s6,16(sp)
ffffffffc0201a6a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201a6c:	c901                	beqz	a0,ffffffffc0201a7c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201a6e:	85aa                	mv	a1,a0
ffffffffc0201a70:	00001517          	auipc	a0,0x1
ffffffffc0201a74:	fd850513          	addi	a0,a0,-40 # ffffffffc0202a48 <error_string+0xe8>
ffffffffc0201a78:	e3efe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201a7c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a7e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201a80:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201a82:	4aa9                	li	s5,10
ffffffffc0201a84:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201a86:	00004b97          	auipc	s7,0x4
ffffffffc0201a8a:	592b8b93          	addi	s7,s7,1426 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a8e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201a92:	e9cfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a96:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a98:	00054b63          	bltz	a0,ffffffffc0201aae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a9c:	00a95b63          	ble	a0,s2,ffffffffc0201ab2 <readline+0x5a>
ffffffffc0201aa0:	029a5463          	ble	s1,s4,ffffffffc0201ac8 <readline+0x70>
        c = getchar();
ffffffffc0201aa4:	e8afe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201aa8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201aaa:	fe0559e3          	bgez	a0,ffffffffc0201a9c <readline+0x44>
            return NULL;
ffffffffc0201aae:	4501                	li	a0,0
ffffffffc0201ab0:	a099                	j	ffffffffc0201af6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201ab2:	03341463          	bne	s0,s3,ffffffffc0201ada <readline+0x82>
ffffffffc0201ab6:	e8b9                	bnez	s1,ffffffffc0201b0c <readline+0xb4>
        c = getchar();
ffffffffc0201ab8:	e76fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201abc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201abe:	fe0548e3          	bltz	a0,ffffffffc0201aae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ac2:	fea958e3          	ble	a0,s2,ffffffffc0201ab2 <readline+0x5a>
ffffffffc0201ac6:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201ac8:	8522                	mv	a0,s0
ffffffffc0201aca:	e20fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201ace:	009b87b3          	add	a5,s7,s1
ffffffffc0201ad2:	00878023          	sb	s0,0(a5)
ffffffffc0201ad6:	2485                	addiw	s1,s1,1
ffffffffc0201ad8:	bf6d                	j	ffffffffc0201a92 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201ada:	01540463          	beq	s0,s5,ffffffffc0201ae2 <readline+0x8a>
ffffffffc0201ade:	fb641ae3          	bne	s0,s6,ffffffffc0201a92 <readline+0x3a>
            cputchar(c);
ffffffffc0201ae2:	8522                	mv	a0,s0
ffffffffc0201ae4:	e06fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201ae8:	00004517          	auipc	a0,0x4
ffffffffc0201aec:	53050513          	addi	a0,a0,1328 # ffffffffc0206018 <edata>
ffffffffc0201af0:	94aa                	add	s1,s1,a0
ffffffffc0201af2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201af6:	60a6                	ld	ra,72(sp)
ffffffffc0201af8:	6406                	ld	s0,64(sp)
ffffffffc0201afa:	74e2                	ld	s1,56(sp)
ffffffffc0201afc:	7942                	ld	s2,48(sp)
ffffffffc0201afe:	79a2                	ld	s3,40(sp)
ffffffffc0201b00:	7a02                	ld	s4,32(sp)
ffffffffc0201b02:	6ae2                	ld	s5,24(sp)
ffffffffc0201b04:	6b42                	ld	s6,16(sp)
ffffffffc0201b06:	6ba2                	ld	s7,8(sp)
ffffffffc0201b08:	6161                	addi	sp,sp,80
ffffffffc0201b0a:	8082                	ret
            cputchar(c);
ffffffffc0201b0c:	4521                	li	a0,8
ffffffffc0201b0e:	ddcfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201b12:	34fd                	addiw	s1,s1,-1
ffffffffc0201b14:	bfbd                	j	ffffffffc0201a92 <readline+0x3a>

ffffffffc0201b16 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201b16:	00004797          	auipc	a5,0x4
ffffffffc0201b1a:	4f278793          	addi	a5,a5,1266 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201b1e:	6398                	ld	a4,0(a5)
ffffffffc0201b20:	4781                	li	a5,0
ffffffffc0201b22:	88ba                	mv	a7,a4
ffffffffc0201b24:	852a                	mv	a0,a0
ffffffffc0201b26:	85be                	mv	a1,a5
ffffffffc0201b28:	863e                	mv	a2,a5
ffffffffc0201b2a:	00000073          	ecall
ffffffffc0201b2e:	87aa                	mv	a5,a0
}
ffffffffc0201b30:	8082                	ret

ffffffffc0201b32 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201b32:	00005797          	auipc	a5,0x5
ffffffffc0201b36:	90678793          	addi	a5,a5,-1786 # ffffffffc0206438 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201b3a:	6398                	ld	a4,0(a5)
ffffffffc0201b3c:	4781                	li	a5,0
ffffffffc0201b3e:	88ba                	mv	a7,a4
ffffffffc0201b40:	852a                	mv	a0,a0
ffffffffc0201b42:	85be                	mv	a1,a5
ffffffffc0201b44:	863e                	mv	a2,a5
ffffffffc0201b46:	00000073          	ecall
ffffffffc0201b4a:	87aa                	mv	a5,a0
}
ffffffffc0201b4c:	8082                	ret

ffffffffc0201b4e <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b4e:	00004797          	auipc	a5,0x4
ffffffffc0201b52:	4b278793          	addi	a5,a5,1202 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201b56:	639c                	ld	a5,0(a5)
ffffffffc0201b58:	4501                	li	a0,0
ffffffffc0201b5a:	88be                	mv	a7,a5
ffffffffc0201b5c:	852a                	mv	a0,a0
ffffffffc0201b5e:	85aa                	mv	a1,a0
ffffffffc0201b60:	862a                	mv	a2,a0
ffffffffc0201b62:	00000073          	ecall
ffffffffc0201b66:	852a                	mv	a0,a0
}
ffffffffc0201b68:	2501                	sext.w	a0,a0
ffffffffc0201b6a:	8082                	ret

ffffffffc0201b6c <sbi_shutdown>:

void sbi_shutdown(void){
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201b6c:	00004797          	auipc	a5,0x4
ffffffffc0201b70:	4a478793          	addi	a5,a5,1188 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201b74:	6398                	ld	a4,0(a5)
ffffffffc0201b76:	4781                	li	a5,0
ffffffffc0201b78:	88ba                	mv	a7,a4
ffffffffc0201b7a:	853e                	mv	a0,a5
ffffffffc0201b7c:	85be                	mv	a1,a5
ffffffffc0201b7e:	863e                	mv	a2,a5
ffffffffc0201b80:	00000073          	ecall
ffffffffc0201b84:	87aa                	mv	a5,a0
}
ffffffffc0201b86:	8082                	ret
