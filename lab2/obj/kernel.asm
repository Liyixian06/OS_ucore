
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
ffffffffc020004e:	606010ef          	jal	ra,ffffffffc0201654 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0201b90 <etext+0x2>
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
ffffffffc02000aa:	628010ef          	jal	ra,ffffffffc02016d2 <vprintfmt>
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
ffffffffc02000de:	5f4010ef          	jal	ra,ffffffffc02016d2 <vprintfmt>
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
ffffffffc0200174:	a4050513          	addi	a0,a0,-1472 # ffffffffc0201bb0 <etext+0x22>
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
ffffffffc020018a:	b4250513          	addi	a0,a0,-1214 # ffffffffc0201cc8 <etext+0x13a>
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
ffffffffc02001a4:	a6050513          	addi	a0,a0,-1440 # ffffffffc0201c00 <etext+0x72>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8858593          	addi	a1,a1,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	00002517          	auipc	a0,0x2
ffffffffc02001ba:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0201c20 <etext+0x92>
ffffffffc02001be:	ef9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00002597          	auipc	a1,0x2
ffffffffc02001c6:	9cc58593          	addi	a1,a1,-1588 # ffffffffc0201b8e <etext>
ffffffffc02001ca:	00002517          	auipc	a0,0x2
ffffffffc02001ce:	a7650513          	addi	a0,a0,-1418 # ffffffffc0201c40 <etext+0xb2>
ffffffffc02001d2:	ee5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00006597          	auipc	a1,0x6
ffffffffc02001da:	e4258593          	addi	a1,a1,-446 # ffffffffc0206018 <edata>
ffffffffc02001de:	00002517          	auipc	a0,0x2
ffffffffc02001e2:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201c60 <etext+0xd2>
ffffffffc02001e6:	ed1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00006597          	auipc	a1,0x6
ffffffffc02001ee:	29658593          	addi	a1,a1,662 # ffffffffc0206480 <end>
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0201c80 <etext+0xf2>
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
ffffffffc0200224:	a8050513          	addi	a0,a0,-1408 # ffffffffc0201ca0 <etext+0x112>
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
ffffffffc0200234:	9a060613          	addi	a2,a2,-1632 # ffffffffc0201bd0 <etext+0x42>
ffffffffc0200238:	04e00593          	li	a1,78
ffffffffc020023c:	00002517          	auipc	a0,0x2
ffffffffc0200240:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0201be8 <etext+0x5a>
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
ffffffffc0200250:	b6460613          	addi	a2,a2,-1180 # ffffffffc0201db0 <commands+0xe0>
ffffffffc0200254:	00002597          	auipc	a1,0x2
ffffffffc0200258:	b7c58593          	addi	a1,a1,-1156 # ffffffffc0201dd0 <commands+0x100>
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0201dd8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200266:	e51ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020026a:	00002617          	auipc	a2,0x2
ffffffffc020026e:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0201de8 <commands+0x118>
ffffffffc0200272:	00002597          	auipc	a1,0x2
ffffffffc0200276:	b9e58593          	addi	a1,a1,-1122 # ffffffffc0201e10 <commands+0x140>
ffffffffc020027a:	00002517          	auipc	a0,0x2
ffffffffc020027e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0201dd8 <commands+0x108>
ffffffffc0200282:	e35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200286:	00002617          	auipc	a2,0x2
ffffffffc020028a:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0201e20 <commands+0x150>
ffffffffc020028e:	00002597          	auipc	a1,0x2
ffffffffc0200292:	bb258593          	addi	a1,a1,-1102 # ffffffffc0201e40 <commands+0x170>
ffffffffc0200296:	00002517          	auipc	a0,0x2
ffffffffc020029a:	b4250513          	addi	a0,a0,-1214 # ffffffffc0201dd8 <commands+0x108>
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
ffffffffc02002d4:	a4850513          	addi	a0,a0,-1464 # ffffffffc0201d18 <commands+0x48>
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
ffffffffc02002f6:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0201d40 <commands+0x70>
ffffffffc02002fa:	dbdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fe:	000c0563          	beqz	s8,ffffffffc0200308 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200302:	8562                	mv	a0,s8
ffffffffc0200304:	346000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc0200308:	00002c97          	auipc	s9,0x2
ffffffffc020030c:	9c8c8c93          	addi	s9,s9,-1592 # ffffffffc0201cd0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200310:	00002997          	auipc	s3,0x2
ffffffffc0200314:	a5898993          	addi	s3,s3,-1448 # ffffffffc0201d68 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00002917          	auipc	s2,0x2
ffffffffc020031c:	a5890913          	addi	s2,s2,-1448 # ffffffffc0201d70 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200320:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200322:	00002b17          	auipc	s6,0x2
ffffffffc0200326:	a56b0b13          	addi	s6,s6,-1450 # ffffffffc0201d78 <commands+0xa8>
    if (argc == 0) {
ffffffffc020032a:	00002a97          	auipc	s5,0x2
ffffffffc020032e:	aa6a8a93          	addi	s5,s5,-1370 # ffffffffc0201dd0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200332:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200334:	854e                	mv	a0,s3
ffffffffc0200336:	728010ef          	jal	ra,ffffffffc0201a5e <readline>
ffffffffc020033a:	842a                	mv	s0,a0
ffffffffc020033c:	dd65                	beqz	a0,ffffffffc0200334 <kmonitor+0x6a>
ffffffffc020033e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200342:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	c999                	beqz	a1,ffffffffc020035a <kmonitor+0x90>
ffffffffc0200346:	854a                	mv	a0,s2
ffffffffc0200348:	2ee010ef          	jal	ra,ffffffffc0201636 <strchr>
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
ffffffffc0200362:	972d0d13          	addi	s10,s10,-1678 # ffffffffc0201cd0 <commands>
    if (argc == 0) {
ffffffffc0200366:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200368:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
ffffffffc020036c:	2a0010ef          	jal	ra,ffffffffc020160c <strcmp>
ffffffffc0200370:	c919                	beqz	a0,ffffffffc0200386 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	2405                	addiw	s0,s0,1
ffffffffc0200374:	09740463          	beq	s0,s7,ffffffffc02003fc <kmonitor+0x132>
ffffffffc0200378:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	6582                	ld	a1,0(sp)
ffffffffc020037e:	0d61                	addi	s10,s10,24
ffffffffc0200380:	28c010ef          	jal	ra,ffffffffc020160c <strcmp>
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
ffffffffc02003e6:	250010ef          	jal	ra,ffffffffc0201636 <strchr>
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
ffffffffc0200402:	99a50513          	addi	a0,a0,-1638 # ffffffffc0201d98 <commands+0xc8>
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
ffffffffc0200424:	714010ef          	jal	ra,ffffffffc0201b38 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007bb23          	sd	zero,22(a5) # ffffffffc0206440 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201e50 <commands+0x180>
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
ffffffffc020044c:	6ec0106f          	j	ffffffffc0201b38 <sbi_set_timer>

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
ffffffffc0200456:	6c60106f          	j	ffffffffc0201b1c <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	6fa0106f          	j	ffffffffc0201b54 <sbi_console_getchar>

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
ffffffffc0200488:	b6450513          	addi	a0,a0,-1180 # ffffffffc0201fe8 <commands+0x318>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0202000 <commands+0x330>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	b7650513          	addi	a0,a0,-1162 # ffffffffc0202018 <commands+0x348>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	b8050513          	addi	a0,a0,-1152 # ffffffffc0202030 <commands+0x360>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0202048 <commands+0x378>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	b9450513          	addi	a0,a0,-1132 # ffffffffc0202060 <commands+0x390>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0202078 <commands+0x3a8>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	ba850513          	addi	a0,a0,-1112 # ffffffffc0202090 <commands+0x3c0>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	bb250513          	addi	a0,a0,-1102 # ffffffffc02020a8 <commands+0x3d8>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	bbc50513          	addi	a0,a0,-1092 # ffffffffc02020c0 <commands+0x3f0>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	bc650513          	addi	a0,a0,-1082 # ffffffffc02020d8 <commands+0x408>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	bd050513          	addi	a0,a0,-1072 # ffffffffc02020f0 <commands+0x420>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	bda50513          	addi	a0,a0,-1062 # ffffffffc0202108 <commands+0x438>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	be450513          	addi	a0,a0,-1052 # ffffffffc0202120 <commands+0x450>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0202138 <commands+0x468>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0202150 <commands+0x480>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	c0250513          	addi	a0,a0,-1022 # ffffffffc0202168 <commands+0x498>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0202180 <commands+0x4b0>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	c1650513          	addi	a0,a0,-1002 # ffffffffc0202198 <commands+0x4c8>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	c2050513          	addi	a0,a0,-992 # ffffffffc02021b0 <commands+0x4e0>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	c2a50513          	addi	a0,a0,-982 # ffffffffc02021c8 <commands+0x4f8>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	c3450513          	addi	a0,a0,-972 # ffffffffc02021e0 <commands+0x510>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	c3e50513          	addi	a0,a0,-962 # ffffffffc02021f8 <commands+0x528>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	c4850513          	addi	a0,a0,-952 # ffffffffc0202210 <commands+0x540>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	c5250513          	addi	a0,a0,-942 # ffffffffc0202228 <commands+0x558>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	c5c50513          	addi	a0,a0,-932 # ffffffffc0202240 <commands+0x570>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	c6650513          	addi	a0,a0,-922 # ffffffffc0202258 <commands+0x588>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	c7050513          	addi	a0,a0,-912 # ffffffffc0202270 <commands+0x5a0>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	c7a50513          	addi	a0,a0,-902 # ffffffffc0202288 <commands+0x5b8>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	c8450513          	addi	a0,a0,-892 # ffffffffc02022a0 <commands+0x5d0>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	c8e50513          	addi	a0,a0,-882 # ffffffffc02022b8 <commands+0x5e8>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	c9450513          	addi	a0,a0,-876 # ffffffffc02022d0 <commands+0x600>
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
ffffffffc0200656:	c9650513          	addi	a0,a0,-874 # ffffffffc02022e8 <commands+0x618>
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
ffffffffc020066e:	c9650513          	addi	a0,a0,-874 # ffffffffc0202300 <commands+0x630>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	c9e50513          	addi	a0,a0,-866 # ffffffffc0202318 <commands+0x648>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	ca650513          	addi	a0,a0,-858 # ffffffffc0202330 <commands+0x660>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	caa50513          	addi	a0,a0,-854 # ffffffffc0202348 <commands+0x678>
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
ffffffffc02006c0:	7b070713          	addi	a4,a4,1968 # ffffffffc0201e6c <commands+0x19c>
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
ffffffffc02006d2:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201f98 <commands+0x2c8>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00002517          	auipc	a0,0x2
ffffffffc02006de:	89e50513          	addi	a0,a0,-1890 # ffffffffc0201f78 <commands+0x2a8>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00002517          	auipc	a0,0x2
ffffffffc02006ea:	85250513          	addi	a0,a0,-1966 # ffffffffc0201f38 <commands+0x268>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02006f2:	00002517          	auipc	a0,0x2
ffffffffc02006f6:	86650513          	addi	a0,a0,-1946 # ffffffffc0201f58 <commands+0x288>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02006fe:	00002517          	auipc	a0,0x2
ffffffffc0200702:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201fc8 <commands+0x2f8>
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
ffffffffc0200742:	87a50513          	addi	a0,a0,-1926 # ffffffffc0201fb8 <commands+0x2e8>
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
ffffffffc0200768:	40a0106f          	j	ffffffffc0201b72 <sbi_shutdown>

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
ffffffffc02007aa:	6fa50513          	addi	a0,a0,1786 # ffffffffc0201ea0 <commands+0x1d0>
ffffffffc02007ae:	909ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
			cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
ffffffffc02007b2:	10843583          	ld	a1,264(s0)
ffffffffc02007b6:	00001517          	auipc	a0,0x1
ffffffffc02007ba:	71250513          	addi	a0,a0,1810 # ffffffffc0201ec8 <commands+0x1f8>
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
ffffffffc02007d8:	72450513          	addi	a0,a0,1828 # ffffffffc0201ef8 <commands+0x228>
ffffffffc02007dc:	8dbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
			cprintf("ebreak caught at 0x%016llx\n", tf->epc);
ffffffffc02007e0:	10843583          	ld	a1,264(s0)
ffffffffc02007e4:	00001517          	auipc	a0,0x1
ffffffffc02007e8:	73450513          	addi	a0,a0,1844 # ffffffffc0201f18 <commands+0x248>
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
ffffffffc0200998:	e2c78793          	addi	a5,a5,-468 # ffffffffc02027c0 <best_fit_pmm_manager>
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
ffffffffc02009a4:	9c050513          	addi	a0,a0,-1600 # ffffffffc0202360 <commands+0x690>
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
ffffffffc02009d0:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0202378 <commands+0x6a8>
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
ffffffffc02009f4:	9a050513          	addi	a0,a0,-1632 # ffffffffc0202390 <commands+0x6c0>
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
ffffffffc0200a8c:	9a050513          	addi	a0,a0,-1632 # ffffffffc0202428 <commands+0x758>
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
ffffffffc0200ac4:	98850513          	addi	a0,a0,-1656 # ffffffffc0202448 <commands+0x778>
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
ffffffffc0200afe:	8c660613          	addi	a2,a2,-1850 # ffffffffc02023c0 <commands+0x6f0>
ffffffffc0200b02:	06f00593          	li	a1,111
ffffffffc0200b06:	00002517          	auipc	a0,0x2
ffffffffc0200b0a:	8e250513          	addi	a0,a0,-1822 # ffffffffc02023e8 <commands+0x718>
ffffffffc0200b0e:	e30ff0ef          	jal	ra,ffffffffc020013e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200b12:	00002617          	auipc	a2,0x2
ffffffffc0200b16:	8ae60613          	addi	a2,a2,-1874 # ffffffffc02023c0 <commands+0x6f0>
ffffffffc0200b1a:	08a00593          	li	a1,138
ffffffffc0200b1e:	00002517          	auipc	a0,0x2
ffffffffc0200b22:	8ca50513          	addi	a0,a0,-1846 # ffffffffc02023e8 <commands+0x718>
ffffffffc0200b26:	e18ff0ef          	jal	ra,ffffffffc020013e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200b2a:	00002617          	auipc	a2,0x2
ffffffffc0200b2e:	8ce60613          	addi	a2,a2,-1842 # ffffffffc02023f8 <commands+0x728>
ffffffffc0200b32:	06b00593          	li	a1,107
ffffffffc0200b36:	00002517          	auipc	a0,0x2
ffffffffc0200b3a:	8e250513          	addi	a0,a0,-1822 # ffffffffc0202418 <commands+0x748>
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

ffffffffc0200b5e <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200b5e:	c15d                	beqz	a0,ffffffffc0200c04 <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc0200b60:	00006617          	auipc	a2,0x6
ffffffffc0200b64:	90860613          	addi	a2,a2,-1784 # ffffffffc0206468 <free_area>
ffffffffc0200b68:	01062803          	lw	a6,16(a2)
ffffffffc0200b6c:	86aa                	mv	a3,a0
ffffffffc0200b6e:	02081793          	slli	a5,a6,0x20
ffffffffc0200b72:	9381                	srli	a5,a5,0x20
ffffffffc0200b74:	08a7e663          	bltu	a5,a0,ffffffffc0200c00 <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;
ffffffffc0200b78:	0018059b          	addiw	a1,a6,1
ffffffffc0200b7c:	1582                	slli	a1,a1,0x20
ffffffffc0200b7e:	9181                	srli	a1,a1,0x20
    list_entry_t *le = &free_list;
ffffffffc0200b80:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc0200b82:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b84:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b86:	00c78e63          	beq	a5,a2,ffffffffc0200ba2 <best_fit_alloc_pages+0x44>
        if (p->property >= n && p->property < min_size) {
ffffffffc0200b8a:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200b8e:	fed76be3          	bltu	a4,a3,ffffffffc0200b84 <best_fit_alloc_pages+0x26>
ffffffffc0200b92:	feb779e3          	bleu	a1,a4,ffffffffc0200b84 <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc0200b96:	fe878513          	addi	a0,a5,-24
ffffffffc0200b9a:	679c                	ld	a5,8(a5)
ffffffffc0200b9c:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b9e:	fec796e3          	bne	a5,a2,ffffffffc0200b8a <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc0200ba2:	c125                	beqz	a0,ffffffffc0200c02 <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ba4:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200ba6:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0200ba8:	490c                	lw	a1,16(a0)
ffffffffc0200baa:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200bae:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0200bb0:	e310                	sd	a2,0(a4)
ffffffffc0200bb2:	02059713          	slli	a4,a1,0x20
ffffffffc0200bb6:	9301                	srli	a4,a4,0x20
ffffffffc0200bb8:	02e6f863          	bleu	a4,a3,ffffffffc0200be8 <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc0200bbc:	00269713          	slli	a4,a3,0x2
ffffffffc0200bc0:	9736                	add	a4,a4,a3
ffffffffc0200bc2:	070e                	slli	a4,a4,0x3
ffffffffc0200bc4:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0200bc6:	411585bb          	subw	a1,a1,a7
ffffffffc0200bca:	cb0c                	sw	a1,16(a4)
ffffffffc0200bcc:	4689                	li	a3,2
ffffffffc0200bce:	00870593          	addi	a1,a4,8
ffffffffc0200bd2:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200bd6:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc0200bd8:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc0200bdc:	0107a803          	lw	a6,16(a5)
ffffffffc0200be0:	e28c                	sd	a1,0(a3)
ffffffffc0200be2:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc0200be4:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0200be6:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc0200be8:	4118083b          	subw	a6,a6,a7
ffffffffc0200bec:	00006797          	auipc	a5,0x6
ffffffffc0200bf0:	8907a623          	sw	a6,-1908(a5) # ffffffffc0206478 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200bf4:	57f5                	li	a5,-3
ffffffffc0200bf6:	00850713          	addi	a4,a0,8
ffffffffc0200bfa:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc0200bfe:	8082                	ret
        return NULL;
ffffffffc0200c00:	4501                	li	a0,0
}
ffffffffc0200c02:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200c04:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200c06:	00002697          	auipc	a3,0x2
ffffffffc0200c0a:	88268693          	addi	a3,a3,-1918 # ffffffffc0202488 <commands+0x7b8>
ffffffffc0200c0e:	00002617          	auipc	a2,0x2
ffffffffc0200c12:	88260613          	addi	a2,a2,-1918 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0200c16:	06b00593          	li	a1,107
ffffffffc0200c1a:	00002517          	auipc	a0,0x2
ffffffffc0200c1e:	88e50513          	addi	a0,a0,-1906 # ffffffffc02024a8 <commands+0x7d8>
best_fit_alloc_pages(size_t n) {
ffffffffc0200c22:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200c24:	d1aff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200c28 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200c28:	715d                	addi	sp,sp,-80
ffffffffc0200c2a:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0200c2c:	00006917          	auipc	s2,0x6
ffffffffc0200c30:	83c90913          	addi	s2,s2,-1988 # ffffffffc0206468 <free_area>
ffffffffc0200c34:	00893783          	ld	a5,8(s2)
ffffffffc0200c38:	e486                	sd	ra,72(sp)
ffffffffc0200c3a:	e0a2                	sd	s0,64(sp)
ffffffffc0200c3c:	fc26                	sd	s1,56(sp)
ffffffffc0200c3e:	f44e                	sd	s3,40(sp)
ffffffffc0200c40:	f052                	sd	s4,32(sp)
ffffffffc0200c42:	ec56                	sd	s5,24(sp)
ffffffffc0200c44:	e85a                	sd	s6,16(sp)
ffffffffc0200c46:	e45e                	sd	s7,8(sp)
ffffffffc0200c48:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c4a:	2d278363          	beq	a5,s2,ffffffffc0200f10 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c4e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c52:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200c54:	8b05                	andi	a4,a4,1
ffffffffc0200c56:	2c070163          	beqz	a4,ffffffffc0200f18 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200c5a:	4401                	li	s0,0
ffffffffc0200c5c:	4481                	li	s1,0
ffffffffc0200c5e:	a031                	j	ffffffffc0200c6a <best_fit_check+0x42>
ffffffffc0200c60:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200c64:	8b09                	andi	a4,a4,2
ffffffffc0200c66:	2a070963          	beqz	a4,ffffffffc0200f18 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200c6a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c6e:	679c                	ld	a5,8(a5)
ffffffffc0200c70:	2485                	addiw	s1,s1,1
ffffffffc0200c72:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c74:	ff2796e3          	bne	a5,s2,ffffffffc0200c60 <best_fit_check+0x38>
ffffffffc0200c78:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200c7a:	cdbff0ef          	jal	ra,ffffffffc0200954 <nr_free_pages>
ffffffffc0200c7e:	37351d63          	bne	a0,s3,ffffffffc0200ff8 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c82:	4505                	li	a0,1
ffffffffc0200c84:	c47ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200c88:	8a2a                	mv	s4,a0
ffffffffc0200c8a:	3a050763          	beqz	a0,ffffffffc0201038 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c8e:	4505                	li	a0,1
ffffffffc0200c90:	c3bff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200c94:	89aa                	mv	s3,a0
ffffffffc0200c96:	38050163          	beqz	a0,ffffffffc0201018 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c9a:	4505                	li	a0,1
ffffffffc0200c9c:	c2fff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200ca0:	8aaa                	mv	s5,a0
ffffffffc0200ca2:	30050b63          	beqz	a0,ffffffffc0200fb8 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ca6:	293a0963          	beq	s4,s3,ffffffffc0200f38 <best_fit_check+0x310>
ffffffffc0200caa:	28aa0763          	beq	s4,a0,ffffffffc0200f38 <best_fit_check+0x310>
ffffffffc0200cae:	28a98563          	beq	s3,a0,ffffffffc0200f38 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200cb2:	000a2783          	lw	a5,0(s4)
ffffffffc0200cb6:	2a079163          	bnez	a5,ffffffffc0200f58 <best_fit_check+0x330>
ffffffffc0200cba:	0009a783          	lw	a5,0(s3)
ffffffffc0200cbe:	28079d63          	bnez	a5,ffffffffc0200f58 <best_fit_check+0x330>
ffffffffc0200cc2:	411c                	lw	a5,0(a0)
ffffffffc0200cc4:	28079a63          	bnez	a5,ffffffffc0200f58 <best_fit_check+0x330>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cc8:	00005797          	auipc	a5,0x5
ffffffffc0200ccc:	79878793          	addi	a5,a5,1944 # ffffffffc0206460 <pages>
ffffffffc0200cd0:	639c                	ld	a5,0(a5)
ffffffffc0200cd2:	00001717          	auipc	a4,0x1
ffffffffc0200cd6:	7ee70713          	addi	a4,a4,2030 # ffffffffc02024c0 <commands+0x7f0>
ffffffffc0200cda:	630c                	ld	a1,0(a4)
ffffffffc0200cdc:	40fa0733          	sub	a4,s4,a5
ffffffffc0200ce0:	870d                	srai	a4,a4,0x3
ffffffffc0200ce2:	02b70733          	mul	a4,a4,a1
ffffffffc0200ce6:	00002697          	auipc	a3,0x2
ffffffffc0200cea:	d7268693          	addi	a3,a3,-654 # ffffffffc0202a58 <nbase>
ffffffffc0200cee:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200cf0:	00005697          	auipc	a3,0x5
ffffffffc0200cf4:	73868693          	addi	a3,a3,1848 # ffffffffc0206428 <npage>
ffffffffc0200cf8:	6294                	ld	a3,0(a3)
ffffffffc0200cfa:	06b2                	slli	a3,a3,0xc
ffffffffc0200cfc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cfe:	0732                	slli	a4,a4,0xc
ffffffffc0200d00:	26d77c63          	bleu	a3,a4,ffffffffc0200f78 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d04:	40f98733          	sub	a4,s3,a5
ffffffffc0200d08:	870d                	srai	a4,a4,0x3
ffffffffc0200d0a:	02b70733          	mul	a4,a4,a1
ffffffffc0200d0e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d10:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200d12:	42d77363          	bleu	a3,a4,ffffffffc0201138 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d16:	40f507b3          	sub	a5,a0,a5
ffffffffc0200d1a:	878d                	srai	a5,a5,0x3
ffffffffc0200d1c:	02b787b3          	mul	a5,a5,a1
ffffffffc0200d20:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d22:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d24:	3ed7fa63          	bleu	a3,a5,ffffffffc0201118 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200d28:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d2a:	00093c03          	ld	s8,0(s2)
ffffffffc0200d2e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200d32:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200d36:	00005797          	auipc	a5,0x5
ffffffffc0200d3a:	7327bd23          	sd	s2,1850(a5) # ffffffffc0206470 <free_area+0x8>
ffffffffc0200d3e:	00005797          	auipc	a5,0x5
ffffffffc0200d42:	7327b523          	sd	s2,1834(a5) # ffffffffc0206468 <free_area>
    nr_free = 0;
ffffffffc0200d46:	00005797          	auipc	a5,0x5
ffffffffc0200d4a:	7207a923          	sw	zero,1842(a5) # ffffffffc0206478 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200d4e:	b7dff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200d52:	3a051363          	bnez	a0,ffffffffc02010f8 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200d56:	4585                	li	a1,1
ffffffffc0200d58:	8552                	mv	a0,s4
ffffffffc0200d5a:	bb5ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_page(p1);
ffffffffc0200d5e:	4585                	li	a1,1
ffffffffc0200d60:	854e                	mv	a0,s3
ffffffffc0200d62:	badff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_page(p2);
ffffffffc0200d66:	4585                	li	a1,1
ffffffffc0200d68:	8556                	mv	a0,s5
ffffffffc0200d6a:	ba5ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    assert(nr_free == 3);
ffffffffc0200d6e:	01092703          	lw	a4,16(s2)
ffffffffc0200d72:	478d                	li	a5,3
ffffffffc0200d74:	36f71263          	bne	a4,a5,ffffffffc02010d8 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d78:	4505                	li	a0,1
ffffffffc0200d7a:	b51ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200d7e:	89aa                	mv	s3,a0
ffffffffc0200d80:	32050c63          	beqz	a0,ffffffffc02010b8 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d84:	4505                	li	a0,1
ffffffffc0200d86:	b45ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200d8a:	8aaa                	mv	s5,a0
ffffffffc0200d8c:	30050663          	beqz	a0,ffffffffc0201098 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d90:	4505                	li	a0,1
ffffffffc0200d92:	b39ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200d96:	8a2a                	mv	s4,a0
ffffffffc0200d98:	2e050063          	beqz	a0,ffffffffc0201078 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200d9c:	4505                	li	a0,1
ffffffffc0200d9e:	b2dff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200da2:	2a051b63          	bnez	a0,ffffffffc0201058 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200da6:	4585                	li	a1,1
ffffffffc0200da8:	854e                	mv	a0,s3
ffffffffc0200daa:	b65ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200dae:	00893783          	ld	a5,8(s2)
ffffffffc0200db2:	1f278363          	beq	a5,s2,ffffffffc0200f98 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200db6:	4505                	li	a0,1
ffffffffc0200db8:	b13ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200dbc:	54a99e63          	bne	s3,a0,ffffffffc0201318 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200dc0:	4505                	li	a0,1
ffffffffc0200dc2:	b09ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200dc6:	52051963          	bnez	a0,ffffffffc02012f8 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200dca:	01092783          	lw	a5,16(s2)
ffffffffc0200dce:	50079563          	bnez	a5,ffffffffc02012d8 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200dd2:	854e                	mv	a0,s3
ffffffffc0200dd4:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200dd6:	00005797          	auipc	a5,0x5
ffffffffc0200dda:	6987b923          	sd	s8,1682(a5) # ffffffffc0206468 <free_area>
ffffffffc0200dde:	00005797          	auipc	a5,0x5
ffffffffc0200de2:	6977b923          	sd	s7,1682(a5) # ffffffffc0206470 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200de6:	00005797          	auipc	a5,0x5
ffffffffc0200dea:	6967a923          	sw	s6,1682(a5) # ffffffffc0206478 <free_area+0x10>
    free_page(p);
ffffffffc0200dee:	b21ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_page(p1);
ffffffffc0200df2:	4585                	li	a1,1
ffffffffc0200df4:	8556                	mv	a0,s5
ffffffffc0200df6:	b19ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_page(p2);
ffffffffc0200dfa:	4585                	li	a1,1
ffffffffc0200dfc:	8552                	mv	a0,s4
ffffffffc0200dfe:	b11ff0ef          	jal	ra,ffffffffc020090e <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200e02:	4515                	li	a0,5
ffffffffc0200e04:	ac7ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200e08:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200e0a:	4a050763          	beqz	a0,ffffffffc02012b8 <best_fit_check+0x690>
ffffffffc0200e0e:	651c                	ld	a5,8(a0)
ffffffffc0200e10:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200e12:	8b85                	andi	a5,a5,1
ffffffffc0200e14:	48079263          	bnez	a5,ffffffffc0201298 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200e18:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200e1a:	00093b03          	ld	s6,0(s2)
ffffffffc0200e1e:	00893a83          	ld	s5,8(s2)
ffffffffc0200e22:	00005797          	auipc	a5,0x5
ffffffffc0200e26:	6527b323          	sd	s2,1606(a5) # ffffffffc0206468 <free_area>
ffffffffc0200e2a:	00005797          	auipc	a5,0x5
ffffffffc0200e2e:	6527b323          	sd	s2,1606(a5) # ffffffffc0206470 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200e32:	a99ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200e36:	44051163          	bnez	a0,ffffffffc0201278 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200e3a:	4589                	li	a1,2
ffffffffc0200e3c:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200e40:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200e44:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200e48:	00005797          	auipc	a5,0x5
ffffffffc0200e4c:	6207a823          	sw	zero,1584(a5) # ffffffffc0206478 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200e50:	abfff0ef          	jal	ra,ffffffffc020090e <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200e54:	8562                	mv	a0,s8
ffffffffc0200e56:	4585                	li	a1,1
ffffffffc0200e58:	ab7ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200e5c:	4511                	li	a0,4
ffffffffc0200e5e:	a6dff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200e62:	3e051b63          	bnez	a0,ffffffffc0201258 <best_fit_check+0x630>
ffffffffc0200e66:	0309b783          	ld	a5,48(s3)
ffffffffc0200e6a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200e6c:	8b85                	andi	a5,a5,1
ffffffffc0200e6e:	3c078563          	beqz	a5,ffffffffc0201238 <best_fit_check+0x610>
ffffffffc0200e72:	0389a703          	lw	a4,56(s3)
ffffffffc0200e76:	4789                	li	a5,2
ffffffffc0200e78:	3cf71063          	bne	a4,a5,ffffffffc0201238 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200e7c:	4505                	li	a0,1
ffffffffc0200e7e:	a4dff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200e82:	8a2a                	mv	s4,a0
ffffffffc0200e84:	38050a63          	beqz	a0,ffffffffc0201218 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200e88:	4509                	li	a0,2
ffffffffc0200e8a:	a41ff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200e8e:	36050563          	beqz	a0,ffffffffc02011f8 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200e92:	354c1363          	bne	s8,s4,ffffffffc02011d8 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200e96:	854e                	mv	a0,s3
ffffffffc0200e98:	4595                	li	a1,5
ffffffffc0200e9a:	a75ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e9e:	4515                	li	a0,5
ffffffffc0200ea0:	a2bff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200ea4:	89aa                	mv	s3,a0
ffffffffc0200ea6:	30050963          	beqz	a0,ffffffffc02011b8 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200eaa:	4505                	li	a0,1
ffffffffc0200eac:	a1fff0ef          	jal	ra,ffffffffc02008ca <alloc_pages>
ffffffffc0200eb0:	2e051463          	bnez	a0,ffffffffc0201198 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200eb4:	01092783          	lw	a5,16(s2)
ffffffffc0200eb8:	2c079063          	bnez	a5,ffffffffc0201178 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200ebc:	4595                	li	a1,5
ffffffffc0200ebe:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200ec0:	00005797          	auipc	a5,0x5
ffffffffc0200ec4:	5b77ac23          	sw	s7,1464(a5) # ffffffffc0206478 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200ec8:	00005797          	auipc	a5,0x5
ffffffffc0200ecc:	5b67b023          	sd	s6,1440(a5) # ffffffffc0206468 <free_area>
ffffffffc0200ed0:	00005797          	auipc	a5,0x5
ffffffffc0200ed4:	5b57b023          	sd	s5,1440(a5) # ffffffffc0206470 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200ed8:	a37ff0ef          	jal	ra,ffffffffc020090e <free_pages>
    return listelm->next;
ffffffffc0200edc:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ee0:	01278963          	beq	a5,s2,ffffffffc0200ef2 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200ee4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ee8:	679c                	ld	a5,8(a5)
ffffffffc0200eea:	34fd                	addiw	s1,s1,-1
ffffffffc0200eec:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200eee:	ff279be3          	bne	a5,s2,ffffffffc0200ee4 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200ef2:	26049363          	bnez	s1,ffffffffc0201158 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200ef6:	e06d                	bnez	s0,ffffffffc0200fd8 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200ef8:	60a6                	ld	ra,72(sp)
ffffffffc0200efa:	6406                	ld	s0,64(sp)
ffffffffc0200efc:	74e2                	ld	s1,56(sp)
ffffffffc0200efe:	7942                	ld	s2,48(sp)
ffffffffc0200f00:	79a2                	ld	s3,40(sp)
ffffffffc0200f02:	7a02                	ld	s4,32(sp)
ffffffffc0200f04:	6ae2                	ld	s5,24(sp)
ffffffffc0200f06:	6b42                	ld	s6,16(sp)
ffffffffc0200f08:	6ba2                	ld	s7,8(sp)
ffffffffc0200f0a:	6c02                	ld	s8,0(sp)
ffffffffc0200f0c:	6161                	addi	sp,sp,80
ffffffffc0200f0e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f10:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200f12:	4401                	li	s0,0
ffffffffc0200f14:	4481                	li	s1,0
ffffffffc0200f16:	b395                	j	ffffffffc0200c7a <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200f18:	00001697          	auipc	a3,0x1
ffffffffc0200f1c:	5b068693          	addi	a3,a3,1456 # ffffffffc02024c8 <commands+0x7f8>
ffffffffc0200f20:	00001617          	auipc	a2,0x1
ffffffffc0200f24:	57060613          	addi	a2,a2,1392 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0200f28:	10c00593          	li	a1,268
ffffffffc0200f2c:	00001517          	auipc	a0,0x1
ffffffffc0200f30:	57c50513          	addi	a0,a0,1404 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0200f34:	a0aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f38:	00001697          	auipc	a3,0x1
ffffffffc0200f3c:	62068693          	addi	a3,a3,1568 # ffffffffc0202558 <commands+0x888>
ffffffffc0200f40:	00001617          	auipc	a2,0x1
ffffffffc0200f44:	55060613          	addi	a2,a2,1360 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0200f48:	0d800593          	li	a1,216
ffffffffc0200f4c:	00001517          	auipc	a0,0x1
ffffffffc0200f50:	55c50513          	addi	a0,a0,1372 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0200f54:	9eaff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f58:	00001697          	auipc	a3,0x1
ffffffffc0200f5c:	62868693          	addi	a3,a3,1576 # ffffffffc0202580 <commands+0x8b0>
ffffffffc0200f60:	00001617          	auipc	a2,0x1
ffffffffc0200f64:	53060613          	addi	a2,a2,1328 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0200f68:	0d900593          	li	a1,217
ffffffffc0200f6c:	00001517          	auipc	a0,0x1
ffffffffc0200f70:	53c50513          	addi	a0,a0,1340 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0200f74:	9caff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f78:	00001697          	auipc	a3,0x1
ffffffffc0200f7c:	64868693          	addi	a3,a3,1608 # ffffffffc02025c0 <commands+0x8f0>
ffffffffc0200f80:	00001617          	auipc	a2,0x1
ffffffffc0200f84:	51060613          	addi	a2,a2,1296 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0200f88:	0db00593          	li	a1,219
ffffffffc0200f8c:	00001517          	auipc	a0,0x1
ffffffffc0200f90:	51c50513          	addi	a0,a0,1308 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0200f94:	9aaff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f98:	00001697          	auipc	a3,0x1
ffffffffc0200f9c:	6b068693          	addi	a3,a3,1712 # ffffffffc0202648 <commands+0x978>
ffffffffc0200fa0:	00001617          	auipc	a2,0x1
ffffffffc0200fa4:	4f060613          	addi	a2,a2,1264 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0200fa8:	0f400593          	li	a1,244
ffffffffc0200fac:	00001517          	auipc	a0,0x1
ffffffffc0200fb0:	4fc50513          	addi	a0,a0,1276 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0200fb4:	98aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fb8:	00001697          	auipc	a3,0x1
ffffffffc0200fbc:	58068693          	addi	a3,a3,1408 # ffffffffc0202538 <commands+0x868>
ffffffffc0200fc0:	00001617          	auipc	a2,0x1
ffffffffc0200fc4:	4d060613          	addi	a2,a2,1232 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0200fc8:	0d600593          	li	a1,214
ffffffffc0200fcc:	00001517          	auipc	a0,0x1
ffffffffc0200fd0:	4dc50513          	addi	a0,a0,1244 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0200fd4:	96aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == 0);
ffffffffc0200fd8:	00001697          	auipc	a3,0x1
ffffffffc0200fdc:	7a068693          	addi	a3,a3,1952 # ffffffffc0202778 <commands+0xaa8>
ffffffffc0200fe0:	00001617          	auipc	a2,0x1
ffffffffc0200fe4:	4b060613          	addi	a2,a2,1200 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0200fe8:	14e00593          	li	a1,334
ffffffffc0200fec:	00001517          	auipc	a0,0x1
ffffffffc0200ff0:	4bc50513          	addi	a0,a0,1212 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0200ff4:	94aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == nr_free_pages());
ffffffffc0200ff8:	00001697          	auipc	a3,0x1
ffffffffc0200ffc:	4e068693          	addi	a3,a3,1248 # ffffffffc02024d8 <commands+0x808>
ffffffffc0201000:	00001617          	auipc	a2,0x1
ffffffffc0201004:	49060613          	addi	a2,a2,1168 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201008:	10f00593          	li	a1,271
ffffffffc020100c:	00001517          	auipc	a0,0x1
ffffffffc0201010:	49c50513          	addi	a0,a0,1180 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201014:	92aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201018:	00001697          	auipc	a3,0x1
ffffffffc020101c:	50068693          	addi	a3,a3,1280 # ffffffffc0202518 <commands+0x848>
ffffffffc0201020:	00001617          	auipc	a2,0x1
ffffffffc0201024:	47060613          	addi	a2,a2,1136 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201028:	0d500593          	li	a1,213
ffffffffc020102c:	00001517          	auipc	a0,0x1
ffffffffc0201030:	47c50513          	addi	a0,a0,1148 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201034:	90aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201038:	00001697          	auipc	a3,0x1
ffffffffc020103c:	4c068693          	addi	a3,a3,1216 # ffffffffc02024f8 <commands+0x828>
ffffffffc0201040:	00001617          	auipc	a2,0x1
ffffffffc0201044:	45060613          	addi	a2,a2,1104 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201048:	0d400593          	li	a1,212
ffffffffc020104c:	00001517          	auipc	a0,0x1
ffffffffc0201050:	45c50513          	addi	a0,a0,1116 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201054:	8eaff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201058:	00001697          	auipc	a3,0x1
ffffffffc020105c:	5c868693          	addi	a3,a3,1480 # ffffffffc0202620 <commands+0x950>
ffffffffc0201060:	00001617          	auipc	a2,0x1
ffffffffc0201064:	43060613          	addi	a2,a2,1072 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201068:	0f100593          	li	a1,241
ffffffffc020106c:	00001517          	auipc	a0,0x1
ffffffffc0201070:	43c50513          	addi	a0,a0,1084 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201074:	8caff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201078:	00001697          	auipc	a3,0x1
ffffffffc020107c:	4c068693          	addi	a3,a3,1216 # ffffffffc0202538 <commands+0x868>
ffffffffc0201080:	00001617          	auipc	a2,0x1
ffffffffc0201084:	41060613          	addi	a2,a2,1040 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201088:	0ef00593          	li	a1,239
ffffffffc020108c:	00001517          	auipc	a0,0x1
ffffffffc0201090:	41c50513          	addi	a0,a0,1052 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201094:	8aaff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201098:	00001697          	auipc	a3,0x1
ffffffffc020109c:	48068693          	addi	a3,a3,1152 # ffffffffc0202518 <commands+0x848>
ffffffffc02010a0:	00001617          	auipc	a2,0x1
ffffffffc02010a4:	3f060613          	addi	a2,a2,1008 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02010a8:	0ee00593          	li	a1,238
ffffffffc02010ac:	00001517          	auipc	a0,0x1
ffffffffc02010b0:	3fc50513          	addi	a0,a0,1020 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02010b4:	88aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010b8:	00001697          	auipc	a3,0x1
ffffffffc02010bc:	44068693          	addi	a3,a3,1088 # ffffffffc02024f8 <commands+0x828>
ffffffffc02010c0:	00001617          	auipc	a2,0x1
ffffffffc02010c4:	3d060613          	addi	a2,a2,976 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02010c8:	0ed00593          	li	a1,237
ffffffffc02010cc:	00001517          	auipc	a0,0x1
ffffffffc02010d0:	3dc50513          	addi	a0,a0,988 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02010d4:	86aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 3);
ffffffffc02010d8:	00001697          	auipc	a3,0x1
ffffffffc02010dc:	56068693          	addi	a3,a3,1376 # ffffffffc0202638 <commands+0x968>
ffffffffc02010e0:	00001617          	auipc	a2,0x1
ffffffffc02010e4:	3b060613          	addi	a2,a2,944 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02010e8:	0eb00593          	li	a1,235
ffffffffc02010ec:	00001517          	auipc	a0,0x1
ffffffffc02010f0:	3bc50513          	addi	a0,a0,956 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02010f4:	84aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010f8:	00001697          	auipc	a3,0x1
ffffffffc02010fc:	52868693          	addi	a3,a3,1320 # ffffffffc0202620 <commands+0x950>
ffffffffc0201100:	00001617          	auipc	a2,0x1
ffffffffc0201104:	39060613          	addi	a2,a2,912 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201108:	0e600593          	li	a1,230
ffffffffc020110c:	00001517          	auipc	a0,0x1
ffffffffc0201110:	39c50513          	addi	a0,a0,924 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201114:	82aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201118:	00001697          	auipc	a3,0x1
ffffffffc020111c:	4e868693          	addi	a3,a3,1256 # ffffffffc0202600 <commands+0x930>
ffffffffc0201120:	00001617          	auipc	a2,0x1
ffffffffc0201124:	37060613          	addi	a2,a2,880 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201128:	0dd00593          	li	a1,221
ffffffffc020112c:	00001517          	auipc	a0,0x1
ffffffffc0201130:	37c50513          	addi	a0,a0,892 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201134:	80aff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201138:	00001697          	auipc	a3,0x1
ffffffffc020113c:	4a868693          	addi	a3,a3,1192 # ffffffffc02025e0 <commands+0x910>
ffffffffc0201140:	00001617          	auipc	a2,0x1
ffffffffc0201144:	35060613          	addi	a2,a2,848 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201148:	0dc00593          	li	a1,220
ffffffffc020114c:	00001517          	auipc	a0,0x1
ffffffffc0201150:	35c50513          	addi	a0,a0,860 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201154:	febfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(count == 0);
ffffffffc0201158:	00001697          	auipc	a3,0x1
ffffffffc020115c:	61068693          	addi	a3,a3,1552 # ffffffffc0202768 <commands+0xa98>
ffffffffc0201160:	00001617          	auipc	a2,0x1
ffffffffc0201164:	33060613          	addi	a2,a2,816 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201168:	14d00593          	li	a1,333
ffffffffc020116c:	00001517          	auipc	a0,0x1
ffffffffc0201170:	33c50513          	addi	a0,a0,828 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201174:	fcbfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 0);
ffffffffc0201178:	00001697          	auipc	a3,0x1
ffffffffc020117c:	50868693          	addi	a3,a3,1288 # ffffffffc0202680 <commands+0x9b0>
ffffffffc0201180:	00001617          	auipc	a2,0x1
ffffffffc0201184:	31060613          	addi	a2,a2,784 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201188:	14200593          	li	a1,322
ffffffffc020118c:	00001517          	auipc	a0,0x1
ffffffffc0201190:	31c50513          	addi	a0,a0,796 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201194:	fabfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201198:	00001697          	auipc	a3,0x1
ffffffffc020119c:	48868693          	addi	a3,a3,1160 # ffffffffc0202620 <commands+0x950>
ffffffffc02011a0:	00001617          	auipc	a2,0x1
ffffffffc02011a4:	2f060613          	addi	a2,a2,752 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02011a8:	13c00593          	li	a1,316
ffffffffc02011ac:	00001517          	auipc	a0,0x1
ffffffffc02011b0:	2fc50513          	addi	a0,a0,764 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02011b4:	f8bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011b8:	00001697          	auipc	a3,0x1
ffffffffc02011bc:	59068693          	addi	a3,a3,1424 # ffffffffc0202748 <commands+0xa78>
ffffffffc02011c0:	00001617          	auipc	a2,0x1
ffffffffc02011c4:	2d060613          	addi	a2,a2,720 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02011c8:	13b00593          	li	a1,315
ffffffffc02011cc:	00001517          	auipc	a0,0x1
ffffffffc02011d0:	2dc50513          	addi	a0,a0,732 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02011d4:	f6bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 + 4 == p1);
ffffffffc02011d8:	00001697          	auipc	a3,0x1
ffffffffc02011dc:	56068693          	addi	a3,a3,1376 # ffffffffc0202738 <commands+0xa68>
ffffffffc02011e0:	00001617          	auipc	a2,0x1
ffffffffc02011e4:	2b060613          	addi	a2,a2,688 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02011e8:	13300593          	li	a1,307
ffffffffc02011ec:	00001517          	auipc	a0,0x1
ffffffffc02011f0:	2bc50513          	addi	a0,a0,700 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02011f4:	f4bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc02011f8:	00001697          	auipc	a3,0x1
ffffffffc02011fc:	52868693          	addi	a3,a3,1320 # ffffffffc0202720 <commands+0xa50>
ffffffffc0201200:	00001617          	auipc	a2,0x1
ffffffffc0201204:	29060613          	addi	a2,a2,656 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201208:	13200593          	li	a1,306
ffffffffc020120c:	00001517          	auipc	a0,0x1
ffffffffc0201210:	29c50513          	addi	a0,a0,668 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201214:	f2bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0201218:	00001697          	auipc	a3,0x1
ffffffffc020121c:	4e868693          	addi	a3,a3,1256 # ffffffffc0202700 <commands+0xa30>
ffffffffc0201220:	00001617          	auipc	a2,0x1
ffffffffc0201224:	27060613          	addi	a2,a2,624 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201228:	13100593          	li	a1,305
ffffffffc020122c:	00001517          	auipc	a0,0x1
ffffffffc0201230:	27c50513          	addi	a0,a0,636 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201234:	f0bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0201238:	00001697          	auipc	a3,0x1
ffffffffc020123c:	49868693          	addi	a3,a3,1176 # ffffffffc02026d0 <commands+0xa00>
ffffffffc0201240:	00001617          	auipc	a2,0x1
ffffffffc0201244:	25060613          	addi	a2,a2,592 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201248:	12f00593          	li	a1,303
ffffffffc020124c:	00001517          	auipc	a0,0x1
ffffffffc0201250:	25c50513          	addi	a0,a0,604 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201254:	eebfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201258:	00001697          	auipc	a3,0x1
ffffffffc020125c:	46068693          	addi	a3,a3,1120 # ffffffffc02026b8 <commands+0x9e8>
ffffffffc0201260:	00001617          	auipc	a2,0x1
ffffffffc0201264:	23060613          	addi	a2,a2,560 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201268:	12e00593          	li	a1,302
ffffffffc020126c:	00001517          	auipc	a0,0x1
ffffffffc0201270:	23c50513          	addi	a0,a0,572 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201274:	ecbfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201278:	00001697          	auipc	a3,0x1
ffffffffc020127c:	3a868693          	addi	a3,a3,936 # ffffffffc0202620 <commands+0x950>
ffffffffc0201280:	00001617          	auipc	a2,0x1
ffffffffc0201284:	21060613          	addi	a2,a2,528 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201288:	12200593          	li	a1,290
ffffffffc020128c:	00001517          	auipc	a0,0x1
ffffffffc0201290:	21c50513          	addi	a0,a0,540 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201294:	eabfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!PageProperty(p0));
ffffffffc0201298:	00001697          	auipc	a3,0x1
ffffffffc020129c:	40868693          	addi	a3,a3,1032 # ffffffffc02026a0 <commands+0x9d0>
ffffffffc02012a0:	00001617          	auipc	a2,0x1
ffffffffc02012a4:	1f060613          	addi	a2,a2,496 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02012a8:	11900593          	li	a1,281
ffffffffc02012ac:	00001517          	auipc	a0,0x1
ffffffffc02012b0:	1fc50513          	addi	a0,a0,508 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02012b4:	e8bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 != NULL);
ffffffffc02012b8:	00001697          	auipc	a3,0x1
ffffffffc02012bc:	3d868693          	addi	a3,a3,984 # ffffffffc0202690 <commands+0x9c0>
ffffffffc02012c0:	00001617          	auipc	a2,0x1
ffffffffc02012c4:	1d060613          	addi	a2,a2,464 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02012c8:	11800593          	li	a1,280
ffffffffc02012cc:	00001517          	auipc	a0,0x1
ffffffffc02012d0:	1dc50513          	addi	a0,a0,476 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02012d4:	e6bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 0);
ffffffffc02012d8:	00001697          	auipc	a3,0x1
ffffffffc02012dc:	3a868693          	addi	a3,a3,936 # ffffffffc0202680 <commands+0x9b0>
ffffffffc02012e0:	00001617          	auipc	a2,0x1
ffffffffc02012e4:	1b060613          	addi	a2,a2,432 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02012e8:	0fa00593          	li	a1,250
ffffffffc02012ec:	00001517          	auipc	a0,0x1
ffffffffc02012f0:	1bc50513          	addi	a0,a0,444 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02012f4:	e4bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012f8:	00001697          	auipc	a3,0x1
ffffffffc02012fc:	32868693          	addi	a3,a3,808 # ffffffffc0202620 <commands+0x950>
ffffffffc0201300:	00001617          	auipc	a2,0x1
ffffffffc0201304:	19060613          	addi	a2,a2,400 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201308:	0f800593          	li	a1,248
ffffffffc020130c:	00001517          	auipc	a0,0x1
ffffffffc0201310:	19c50513          	addi	a0,a0,412 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201314:	e2bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201318:	00001697          	auipc	a3,0x1
ffffffffc020131c:	34868693          	addi	a3,a3,840 # ffffffffc0202660 <commands+0x990>
ffffffffc0201320:	00001617          	auipc	a2,0x1
ffffffffc0201324:	17060613          	addi	a2,a2,368 # ffffffffc0202490 <commands+0x7c0>
ffffffffc0201328:	0f700593          	li	a1,247
ffffffffc020132c:	00001517          	auipc	a0,0x1
ffffffffc0201330:	17c50513          	addi	a0,a0,380 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc0201334:	e0bfe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0201338 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201338:	1141                	addi	sp,sp,-16
ffffffffc020133a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020133c:	18058063          	beqz	a1,ffffffffc02014bc <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0201340:	00259693          	slli	a3,a1,0x2
ffffffffc0201344:	96ae                	add	a3,a3,a1
ffffffffc0201346:	068e                	slli	a3,a3,0x3
ffffffffc0201348:	96aa                	add	a3,a3,a0
ffffffffc020134a:	02d50d63          	beq	a0,a3,ffffffffc0201384 <best_fit_free_pages+0x4c>
ffffffffc020134e:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201350:	8b85                	andi	a5,a5,1
ffffffffc0201352:	14079563          	bnez	a5,ffffffffc020149c <best_fit_free_pages+0x164>
ffffffffc0201356:	651c                	ld	a5,8(a0)
ffffffffc0201358:	8385                	srli	a5,a5,0x1
ffffffffc020135a:	8b85                	andi	a5,a5,1
ffffffffc020135c:	14079063          	bnez	a5,ffffffffc020149c <best_fit_free_pages+0x164>
ffffffffc0201360:	87aa                	mv	a5,a0
ffffffffc0201362:	a809                	j	ffffffffc0201374 <best_fit_free_pages+0x3c>
ffffffffc0201364:	6798                	ld	a4,8(a5)
ffffffffc0201366:	8b05                	andi	a4,a4,1
ffffffffc0201368:	12071a63          	bnez	a4,ffffffffc020149c <best_fit_free_pages+0x164>
ffffffffc020136c:	6798                	ld	a4,8(a5)
ffffffffc020136e:	8b09                	andi	a4,a4,2
ffffffffc0201370:	12071663          	bnez	a4,ffffffffc020149c <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc0201374:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201378:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020137c:	02878793          	addi	a5,a5,40
ffffffffc0201380:	fed792e3          	bne	a5,a3,ffffffffc0201364 <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc0201384:	2581                	sext.w	a1,a1
ffffffffc0201386:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201388:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020138c:	4789                	li	a5,2
ffffffffc020138e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201392:	00005697          	auipc	a3,0x5
ffffffffc0201396:	0d668693          	addi	a3,a3,214 # ffffffffc0206468 <free_area>
ffffffffc020139a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020139c:	669c                	ld	a5,8(a3)
ffffffffc020139e:	9db9                	addw	a1,a1,a4
ffffffffc02013a0:	00005717          	auipc	a4,0x5
ffffffffc02013a4:	0cb72c23          	sw	a1,216(a4) # ffffffffc0206478 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02013a8:	08d78f63          	beq	a5,a3,ffffffffc0201446 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02013ac:	fe878713          	addi	a4,a5,-24
ffffffffc02013b0:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013b2:	4801                	li	a6,0
ffffffffc02013b4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02013b8:	00e56a63          	bltu	a0,a4,ffffffffc02013cc <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc02013bc:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013be:	02d70563          	beq	a4,a3,ffffffffc02013e8 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013c2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013c4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02013c8:	fee57ae3          	bleu	a4,a0,ffffffffc02013bc <best_fit_free_pages+0x84>
ffffffffc02013cc:	00080663          	beqz	a6,ffffffffc02013d8 <best_fit_free_pages+0xa0>
ffffffffc02013d0:	00005817          	auipc	a6,0x5
ffffffffc02013d4:	08b83c23          	sd	a1,152(a6) # ffffffffc0206468 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013d8:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02013da:	e390                	sd	a2,0(a5)
ffffffffc02013dc:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02013de:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013e0:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02013e2:	02d59163          	bne	a1,a3,ffffffffc0201404 <best_fit_free_pages+0xcc>
ffffffffc02013e6:	a091                	j	ffffffffc020142a <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02013e8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013ea:	f114                	sd	a3,32(a0)
ffffffffc02013ec:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013ee:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02013f0:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013f2:	00d70563          	beq	a4,a3,ffffffffc02013fc <best_fit_free_pages+0xc4>
ffffffffc02013f6:	4805                	li	a6,1
ffffffffc02013f8:	87ba                	mv	a5,a4
ffffffffc02013fa:	b7e9                	j	ffffffffc02013c4 <best_fit_free_pages+0x8c>
ffffffffc02013fc:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013fe:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201400:	02d78163          	beq	a5,a3,ffffffffc0201422 <best_fit_free_pages+0xea>
        if (p + p->property == base){
ffffffffc0201404:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201408:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base){
ffffffffc020140c:	02081713          	slli	a4,a6,0x20
ffffffffc0201410:	9301                	srli	a4,a4,0x20
ffffffffc0201412:	00271793          	slli	a5,a4,0x2
ffffffffc0201416:	97ba                	add	a5,a5,a4
ffffffffc0201418:	078e                	slli	a5,a5,0x3
ffffffffc020141a:	97b2                	add	a5,a5,a2
ffffffffc020141c:	02f50e63          	beq	a0,a5,ffffffffc0201458 <best_fit_free_pages+0x120>
ffffffffc0201420:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201422:	fe878713          	addi	a4,a5,-24
ffffffffc0201426:	00d78d63          	beq	a5,a3,ffffffffc0201440 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc020142a:	490c                	lw	a1,16(a0)
ffffffffc020142c:	02059613          	slli	a2,a1,0x20
ffffffffc0201430:	9201                	srli	a2,a2,0x20
ffffffffc0201432:	00261693          	slli	a3,a2,0x2
ffffffffc0201436:	96b2                	add	a3,a3,a2
ffffffffc0201438:	068e                	slli	a3,a3,0x3
ffffffffc020143a:	96aa                	add	a3,a3,a0
ffffffffc020143c:	04d70063          	beq	a4,a3,ffffffffc020147c <best_fit_free_pages+0x144>
}
ffffffffc0201440:	60a2                	ld	ra,8(sp)
ffffffffc0201442:	0141                	addi	sp,sp,16
ffffffffc0201444:	8082                	ret
ffffffffc0201446:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201448:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020144c:	e398                	sd	a4,0(a5)
ffffffffc020144e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201450:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201452:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201454:	0141                	addi	sp,sp,16
ffffffffc0201456:	8082                	ret
            p->property += base->property;
ffffffffc0201458:	491c                	lw	a5,16(a0)
ffffffffc020145a:	0107883b          	addw	a6,a5,a6
ffffffffc020145e:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201462:	57f5                	li	a5,-3
ffffffffc0201464:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201468:	01853803          	ld	a6,24(a0)
ffffffffc020146c:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc020146e:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0201470:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201474:	659c                	ld	a5,8(a1)
ffffffffc0201476:	01073023          	sd	a6,0(a4)
ffffffffc020147a:	b765                	j	ffffffffc0201422 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc020147c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201480:	ff078693          	addi	a3,a5,-16
ffffffffc0201484:	9db9                	addw	a1,a1,a4
ffffffffc0201486:	c90c                	sw	a1,16(a0)
ffffffffc0201488:	5775                	li	a4,-3
ffffffffc020148a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020148e:	6398                	ld	a4,0(a5)
ffffffffc0201490:	679c                	ld	a5,8(a5)
}
ffffffffc0201492:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201494:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201496:	e398                	sd	a4,0(a5)
ffffffffc0201498:	0141                	addi	sp,sp,16
ffffffffc020149a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020149c:	00001697          	auipc	a3,0x1
ffffffffc02014a0:	2ec68693          	addi	a3,a3,748 # ffffffffc0202788 <commands+0xab8>
ffffffffc02014a4:	00001617          	auipc	a2,0x1
ffffffffc02014a8:	fec60613          	addi	a2,a2,-20 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02014ac:	09300593          	li	a1,147
ffffffffc02014b0:	00001517          	auipc	a0,0x1
ffffffffc02014b4:	ff850513          	addi	a0,a0,-8 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02014b8:	c87fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc02014bc:	00001697          	auipc	a3,0x1
ffffffffc02014c0:	fcc68693          	addi	a3,a3,-52 # ffffffffc0202488 <commands+0x7b8>
ffffffffc02014c4:	00001617          	auipc	a2,0x1
ffffffffc02014c8:	fcc60613          	addi	a2,a2,-52 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02014cc:	09000593          	li	a1,144
ffffffffc02014d0:	00001517          	auipc	a0,0x1
ffffffffc02014d4:	fd850513          	addi	a0,a0,-40 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02014d8:	c67fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02014dc <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02014dc:	1141                	addi	sp,sp,-16
ffffffffc02014de:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014e0:	c1fd                	beqz	a1,ffffffffc02015c6 <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02014e2:	00259693          	slli	a3,a1,0x2
ffffffffc02014e6:	96ae                	add	a3,a3,a1
ffffffffc02014e8:	068e                	slli	a3,a3,0x3
ffffffffc02014ea:	96aa                	add	a3,a3,a0
ffffffffc02014ec:	02d50463          	beq	a0,a3,ffffffffc0201514 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014f0:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02014f2:	87aa                	mv	a5,a0
ffffffffc02014f4:	8b05                	andi	a4,a4,1
ffffffffc02014f6:	e709                	bnez	a4,ffffffffc0201500 <best_fit_init_memmap+0x24>
ffffffffc02014f8:	a07d                	j	ffffffffc02015a6 <best_fit_init_memmap+0xca>
ffffffffc02014fa:	6798                	ld	a4,8(a5)
ffffffffc02014fc:	8b05                	andi	a4,a4,1
ffffffffc02014fe:	c745                	beqz	a4,ffffffffc02015a6 <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0201500:	0007a823          	sw	zero,16(a5)
ffffffffc0201504:	0007b423          	sd	zero,8(a5)
ffffffffc0201508:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020150c:	02878793          	addi	a5,a5,40
ffffffffc0201510:	fed795e3          	bne	a5,a3,ffffffffc02014fa <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc0201514:	2581                	sext.w	a1,a1
ffffffffc0201516:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201518:	4789                	li	a5,2
ffffffffc020151a:	00850713          	addi	a4,a0,8
ffffffffc020151e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201522:	00005697          	auipc	a3,0x5
ffffffffc0201526:	f4668693          	addi	a3,a3,-186 # ffffffffc0206468 <free_area>
ffffffffc020152a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020152c:	669c                	ld	a5,8(a3)
ffffffffc020152e:	9db9                	addw	a1,a1,a4
ffffffffc0201530:	00005717          	auipc	a4,0x5
ffffffffc0201534:	f4b72423          	sw	a1,-184(a4) # ffffffffc0206478 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201538:	04d78a63          	beq	a5,a3,ffffffffc020158c <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc020153c:	fe878713          	addi	a4,a5,-24
ffffffffc0201540:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201542:	4801                	li	a6,0
ffffffffc0201544:	01850613          	addi	a2,a0,24
            if (base < page){
ffffffffc0201548:	00e56a63          	bltu	a0,a4,ffffffffc020155c <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc020154c:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list){
ffffffffc020154e:	02d70563          	beq	a4,a3,ffffffffc0201578 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201552:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201554:	fe878713          	addi	a4,a5,-24
            if (base < page){
ffffffffc0201558:	fee57ae3          	bleu	a4,a0,ffffffffc020154c <best_fit_init_memmap+0x70>
ffffffffc020155c:	00080663          	beqz	a6,ffffffffc0201568 <best_fit_init_memmap+0x8c>
ffffffffc0201560:	00005717          	auipc	a4,0x5
ffffffffc0201564:	f0b73423          	sd	a1,-248(a4) # ffffffffc0206468 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201568:	6398                	ld	a4,0(a5)
}
ffffffffc020156a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020156c:	e390                	sd	a2,0(a5)
ffffffffc020156e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201570:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201572:	ed18                	sd	a4,24(a0)
ffffffffc0201574:	0141                	addi	sp,sp,16
ffffffffc0201576:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201578:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020157a:	f114                	sd	a3,32(a0)
ffffffffc020157c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020157e:	ed1c                	sd	a5,24(a0)
            	list_add(le, &(base->page_link));
ffffffffc0201580:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201582:	00d70e63          	beq	a4,a3,ffffffffc020159e <best_fit_init_memmap+0xc2>
ffffffffc0201586:	4805                	li	a6,1
ffffffffc0201588:	87ba                	mv	a5,a4
ffffffffc020158a:	b7e9                	j	ffffffffc0201554 <best_fit_init_memmap+0x78>
}
ffffffffc020158c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020158e:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201592:	e398                	sd	a4,0(a5)
ffffffffc0201594:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201596:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201598:	ed1c                	sd	a5,24(a0)
}
ffffffffc020159a:	0141                	addi	sp,sp,16
ffffffffc020159c:	8082                	ret
ffffffffc020159e:	60a2                	ld	ra,8(sp)
ffffffffc02015a0:	e290                	sd	a2,0(a3)
ffffffffc02015a2:	0141                	addi	sp,sp,16
ffffffffc02015a4:	8082                	ret
        assert(PageReserved(p));
ffffffffc02015a6:	00001697          	auipc	a3,0x1
ffffffffc02015aa:	20a68693          	addi	a3,a3,522 # ffffffffc02027b0 <commands+0xae0>
ffffffffc02015ae:	00001617          	auipc	a2,0x1
ffffffffc02015b2:	ee260613          	addi	a2,a2,-286 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02015b6:	04a00593          	li	a1,74
ffffffffc02015ba:	00001517          	auipc	a0,0x1
ffffffffc02015be:	eee50513          	addi	a0,a0,-274 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02015c2:	b7dfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc02015c6:	00001697          	auipc	a3,0x1
ffffffffc02015ca:	ec268693          	addi	a3,a3,-318 # ffffffffc0202488 <commands+0x7b8>
ffffffffc02015ce:	00001617          	auipc	a2,0x1
ffffffffc02015d2:	ec260613          	addi	a2,a2,-318 # ffffffffc0202490 <commands+0x7c0>
ffffffffc02015d6:	04700593          	li	a1,71
ffffffffc02015da:	00001517          	auipc	a0,0x1
ffffffffc02015de:	ece50513          	addi	a0,a0,-306 # ffffffffc02024a8 <commands+0x7d8>
ffffffffc02015e2:	b5dfe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02015e6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015e6:	c185                	beqz	a1,ffffffffc0201606 <strnlen+0x20>
ffffffffc02015e8:	00054783          	lbu	a5,0(a0)
ffffffffc02015ec:	cf89                	beqz	a5,ffffffffc0201606 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02015ee:	4781                	li	a5,0
ffffffffc02015f0:	a021                	j	ffffffffc02015f8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015f2:	00074703          	lbu	a4,0(a4)
ffffffffc02015f6:	c711                	beqz	a4,ffffffffc0201602 <strnlen+0x1c>
        cnt ++;
ffffffffc02015f8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015fa:	00f50733          	add	a4,a0,a5
ffffffffc02015fe:	fef59ae3          	bne	a1,a5,ffffffffc02015f2 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201602:	853e                	mv	a0,a5
ffffffffc0201604:	8082                	ret
    size_t cnt = 0;
ffffffffc0201606:	4781                	li	a5,0
}
ffffffffc0201608:	853e                	mv	a0,a5
ffffffffc020160a:	8082                	ret

ffffffffc020160c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020160c:	00054783          	lbu	a5,0(a0)
ffffffffc0201610:	0005c703          	lbu	a4,0(a1)
ffffffffc0201614:	cb91                	beqz	a5,ffffffffc0201628 <strcmp+0x1c>
ffffffffc0201616:	00e79c63          	bne	a5,a4,ffffffffc020162e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020161a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020161c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201620:	0585                	addi	a1,a1,1
ffffffffc0201622:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201626:	fbe5                	bnez	a5,ffffffffc0201616 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201628:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020162a:	9d19                	subw	a0,a0,a4
ffffffffc020162c:	8082                	ret
ffffffffc020162e:	0007851b          	sext.w	a0,a5
ffffffffc0201632:	9d19                	subw	a0,a0,a4
ffffffffc0201634:	8082                	ret

ffffffffc0201636 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201636:	00054783          	lbu	a5,0(a0)
ffffffffc020163a:	cb91                	beqz	a5,ffffffffc020164e <strchr+0x18>
        if (*s == c) {
ffffffffc020163c:	00b79563          	bne	a5,a1,ffffffffc0201646 <strchr+0x10>
ffffffffc0201640:	a809                	j	ffffffffc0201652 <strchr+0x1c>
ffffffffc0201642:	00b78763          	beq	a5,a1,ffffffffc0201650 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201646:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201648:	00054783          	lbu	a5,0(a0)
ffffffffc020164c:	fbfd                	bnez	a5,ffffffffc0201642 <strchr+0xc>
    }
    return NULL;
ffffffffc020164e:	4501                	li	a0,0
}
ffffffffc0201650:	8082                	ret
ffffffffc0201652:	8082                	ret

ffffffffc0201654 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201654:	ca01                	beqz	a2,ffffffffc0201664 <memset+0x10>
ffffffffc0201656:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201658:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020165a:	0785                	addi	a5,a5,1
ffffffffc020165c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201660:	fec79de3          	bne	a5,a2,ffffffffc020165a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201664:	8082                	ret

ffffffffc0201666 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201666:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020166a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020166c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201670:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201672:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201676:	f022                	sd	s0,32(sp)
ffffffffc0201678:	ec26                	sd	s1,24(sp)
ffffffffc020167a:	e84a                	sd	s2,16(sp)
ffffffffc020167c:	f406                	sd	ra,40(sp)
ffffffffc020167e:	e44e                	sd	s3,8(sp)
ffffffffc0201680:	84aa                	mv	s1,a0
ffffffffc0201682:	892e                	mv	s2,a1
ffffffffc0201684:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201688:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020168a:	03067e63          	bleu	a6,a2,ffffffffc02016c6 <printnum+0x60>
ffffffffc020168e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201690:	00805763          	blez	s0,ffffffffc020169e <printnum+0x38>
ffffffffc0201694:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201696:	85ca                	mv	a1,s2
ffffffffc0201698:	854e                	mv	a0,s3
ffffffffc020169a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020169c:	fc65                	bnez	s0,ffffffffc0201694 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020169e:	1a02                	slli	s4,s4,0x20
ffffffffc02016a0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02016a4:	00001797          	auipc	a5,0x1
ffffffffc02016a8:	2fc78793          	addi	a5,a5,764 # ffffffffc02029a0 <error_string+0x38>
ffffffffc02016ac:	9a3e                	add	s4,s4,a5
}
ffffffffc02016ae:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016b0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02016b4:	70a2                	ld	ra,40(sp)
ffffffffc02016b6:	69a2                	ld	s3,8(sp)
ffffffffc02016b8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016ba:	85ca                	mv	a1,s2
ffffffffc02016bc:	8326                	mv	t1,s1
}
ffffffffc02016be:	6942                	ld	s2,16(sp)
ffffffffc02016c0:	64e2                	ld	s1,24(sp)
ffffffffc02016c2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016c4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02016c6:	03065633          	divu	a2,a2,a6
ffffffffc02016ca:	8722                	mv	a4,s0
ffffffffc02016cc:	f9bff0ef          	jal	ra,ffffffffc0201666 <printnum>
ffffffffc02016d0:	b7f9                	j	ffffffffc020169e <printnum+0x38>

ffffffffc02016d2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02016d2:	7119                	addi	sp,sp,-128
ffffffffc02016d4:	f4a6                	sd	s1,104(sp)
ffffffffc02016d6:	f0ca                	sd	s2,96(sp)
ffffffffc02016d8:	e8d2                	sd	s4,80(sp)
ffffffffc02016da:	e4d6                	sd	s5,72(sp)
ffffffffc02016dc:	e0da                	sd	s6,64(sp)
ffffffffc02016de:	fc5e                	sd	s7,56(sp)
ffffffffc02016e0:	f862                	sd	s8,48(sp)
ffffffffc02016e2:	f06a                	sd	s10,32(sp)
ffffffffc02016e4:	fc86                	sd	ra,120(sp)
ffffffffc02016e6:	f8a2                	sd	s0,112(sp)
ffffffffc02016e8:	ecce                	sd	s3,88(sp)
ffffffffc02016ea:	f466                	sd	s9,40(sp)
ffffffffc02016ec:	ec6e                	sd	s11,24(sp)
ffffffffc02016ee:	892a                	mv	s2,a0
ffffffffc02016f0:	84ae                	mv	s1,a1
ffffffffc02016f2:	8d32                	mv	s10,a2
ffffffffc02016f4:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02016f6:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f8:	00001a17          	auipc	s4,0x1
ffffffffc02016fc:	118a0a13          	addi	s4,s4,280 # ffffffffc0202810 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201700:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201704:	00001c17          	auipc	s8,0x1
ffffffffc0201708:	264c0c13          	addi	s8,s8,612 # ffffffffc0202968 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020170c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201710:	02500793          	li	a5,37
ffffffffc0201714:	001d0413          	addi	s0,s10,1
ffffffffc0201718:	00f50e63          	beq	a0,a5,ffffffffc0201734 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020171c:	c521                	beqz	a0,ffffffffc0201764 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020171e:	02500993          	li	s3,37
ffffffffc0201722:	a011                	j	ffffffffc0201726 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201724:	c121                	beqz	a0,ffffffffc0201764 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201726:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201728:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020172a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020172c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201730:	ff351ae3          	bne	a0,s3,ffffffffc0201724 <vprintfmt+0x52>
ffffffffc0201734:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201738:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020173c:	4981                	li	s3,0
ffffffffc020173e:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201740:	5cfd                	li	s9,-1
ffffffffc0201742:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201744:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201748:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020174a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020174e:	0ff6f693          	andi	a3,a3,255
ffffffffc0201752:	00140d13          	addi	s10,s0,1
ffffffffc0201756:	20d5e563          	bltu	a1,a3,ffffffffc0201960 <vprintfmt+0x28e>
ffffffffc020175a:	068a                	slli	a3,a3,0x2
ffffffffc020175c:	96d2                	add	a3,a3,s4
ffffffffc020175e:	4294                	lw	a3,0(a3)
ffffffffc0201760:	96d2                	add	a3,a3,s4
ffffffffc0201762:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201764:	70e6                	ld	ra,120(sp)
ffffffffc0201766:	7446                	ld	s0,112(sp)
ffffffffc0201768:	74a6                	ld	s1,104(sp)
ffffffffc020176a:	7906                	ld	s2,96(sp)
ffffffffc020176c:	69e6                	ld	s3,88(sp)
ffffffffc020176e:	6a46                	ld	s4,80(sp)
ffffffffc0201770:	6aa6                	ld	s5,72(sp)
ffffffffc0201772:	6b06                	ld	s6,64(sp)
ffffffffc0201774:	7be2                	ld	s7,56(sp)
ffffffffc0201776:	7c42                	ld	s8,48(sp)
ffffffffc0201778:	7ca2                	ld	s9,40(sp)
ffffffffc020177a:	7d02                	ld	s10,32(sp)
ffffffffc020177c:	6de2                	ld	s11,24(sp)
ffffffffc020177e:	6109                	addi	sp,sp,128
ffffffffc0201780:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201782:	4705                	li	a4,1
ffffffffc0201784:	008a8593          	addi	a1,s5,8
ffffffffc0201788:	01074463          	blt	a4,a6,ffffffffc0201790 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020178c:	26080363          	beqz	a6,ffffffffc02019f2 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201790:	000ab603          	ld	a2,0(s5)
ffffffffc0201794:	46c1                	li	a3,16
ffffffffc0201796:	8aae                	mv	s5,a1
ffffffffc0201798:	a06d                	j	ffffffffc0201842 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020179a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020179e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017a0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017a2:	b765                	j	ffffffffc020174a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02017a4:	000aa503          	lw	a0,0(s5)
ffffffffc02017a8:	85a6                	mv	a1,s1
ffffffffc02017aa:	0aa1                	addi	s5,s5,8
ffffffffc02017ac:	9902                	jalr	s2
            break;
ffffffffc02017ae:	bfb9                	j	ffffffffc020170c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017b0:	4705                	li	a4,1
ffffffffc02017b2:	008a8993          	addi	s3,s5,8
ffffffffc02017b6:	01074463          	blt	a4,a6,ffffffffc02017be <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02017ba:	22080463          	beqz	a6,ffffffffc02019e2 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02017be:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02017c2:	24044463          	bltz	s0,ffffffffc0201a0a <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02017c6:	8622                	mv	a2,s0
ffffffffc02017c8:	8ace                	mv	s5,s3
ffffffffc02017ca:	46a9                	li	a3,10
ffffffffc02017cc:	a89d                	j	ffffffffc0201842 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02017ce:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017d2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02017d4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02017d6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02017da:	8fb5                	xor	a5,a5,a3
ffffffffc02017dc:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017e0:	1ad74363          	blt	a4,a3,ffffffffc0201986 <vprintfmt+0x2b4>
ffffffffc02017e4:	00369793          	slli	a5,a3,0x3
ffffffffc02017e8:	97e2                	add	a5,a5,s8
ffffffffc02017ea:	639c                	ld	a5,0(a5)
ffffffffc02017ec:	18078d63          	beqz	a5,ffffffffc0201986 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02017f0:	86be                	mv	a3,a5
ffffffffc02017f2:	00001617          	auipc	a2,0x1
ffffffffc02017f6:	25e60613          	addi	a2,a2,606 # ffffffffc0202a50 <error_string+0xe8>
ffffffffc02017fa:	85a6                	mv	a1,s1
ffffffffc02017fc:	854a                	mv	a0,s2
ffffffffc02017fe:	240000ef          	jal	ra,ffffffffc0201a3e <printfmt>
ffffffffc0201802:	b729                	j	ffffffffc020170c <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201804:	00144603          	lbu	a2,1(s0)
ffffffffc0201808:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020180a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020180c:	bf3d                	j	ffffffffc020174a <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020180e:	4705                	li	a4,1
ffffffffc0201810:	008a8593          	addi	a1,s5,8
ffffffffc0201814:	01074463          	blt	a4,a6,ffffffffc020181c <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201818:	1e080263          	beqz	a6,ffffffffc02019fc <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020181c:	000ab603          	ld	a2,0(s5)
ffffffffc0201820:	46a1                	li	a3,8
ffffffffc0201822:	8aae                	mv	s5,a1
ffffffffc0201824:	a839                	j	ffffffffc0201842 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201826:	03000513          	li	a0,48
ffffffffc020182a:	85a6                	mv	a1,s1
ffffffffc020182c:	e03e                	sd	a5,0(sp)
ffffffffc020182e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201830:	85a6                	mv	a1,s1
ffffffffc0201832:	07800513          	li	a0,120
ffffffffc0201836:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201838:	0aa1                	addi	s5,s5,8
ffffffffc020183a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020183e:	6782                	ld	a5,0(sp)
ffffffffc0201840:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201842:	876e                	mv	a4,s11
ffffffffc0201844:	85a6                	mv	a1,s1
ffffffffc0201846:	854a                	mv	a0,s2
ffffffffc0201848:	e1fff0ef          	jal	ra,ffffffffc0201666 <printnum>
            break;
ffffffffc020184c:	b5c1                	j	ffffffffc020170c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020184e:	000ab603          	ld	a2,0(s5)
ffffffffc0201852:	0aa1                	addi	s5,s5,8
ffffffffc0201854:	1c060663          	beqz	a2,ffffffffc0201a20 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201858:	00160413          	addi	s0,a2,1
ffffffffc020185c:	17b05c63          	blez	s11,ffffffffc02019d4 <vprintfmt+0x302>
ffffffffc0201860:	02d00593          	li	a1,45
ffffffffc0201864:	14b79263          	bne	a5,a1,ffffffffc02019a8 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201868:	00064783          	lbu	a5,0(a2)
ffffffffc020186c:	0007851b          	sext.w	a0,a5
ffffffffc0201870:	c905                	beqz	a0,ffffffffc02018a0 <vprintfmt+0x1ce>
ffffffffc0201872:	000cc563          	bltz	s9,ffffffffc020187c <vprintfmt+0x1aa>
ffffffffc0201876:	3cfd                	addiw	s9,s9,-1
ffffffffc0201878:	036c8263          	beq	s9,s6,ffffffffc020189c <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020187c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020187e:	18098463          	beqz	s3,ffffffffc0201a06 <vprintfmt+0x334>
ffffffffc0201882:	3781                	addiw	a5,a5,-32
ffffffffc0201884:	18fbf163          	bleu	a5,s7,ffffffffc0201a06 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201888:	03f00513          	li	a0,63
ffffffffc020188c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020188e:	0405                	addi	s0,s0,1
ffffffffc0201890:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201894:	3dfd                	addiw	s11,s11,-1
ffffffffc0201896:	0007851b          	sext.w	a0,a5
ffffffffc020189a:	fd61                	bnez	a0,ffffffffc0201872 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020189c:	e7b058e3          	blez	s11,ffffffffc020170c <vprintfmt+0x3a>
ffffffffc02018a0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018a2:	85a6                	mv	a1,s1
ffffffffc02018a4:	02000513          	li	a0,32
ffffffffc02018a8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018aa:	e60d81e3          	beqz	s11,ffffffffc020170c <vprintfmt+0x3a>
ffffffffc02018ae:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018b0:	85a6                	mv	a1,s1
ffffffffc02018b2:	02000513          	li	a0,32
ffffffffc02018b6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018b8:	fe0d94e3          	bnez	s11,ffffffffc02018a0 <vprintfmt+0x1ce>
ffffffffc02018bc:	bd81                	j	ffffffffc020170c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02018be:	4705                	li	a4,1
ffffffffc02018c0:	008a8593          	addi	a1,s5,8
ffffffffc02018c4:	01074463          	blt	a4,a6,ffffffffc02018cc <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02018c8:	12080063          	beqz	a6,ffffffffc02019e8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02018cc:	000ab603          	ld	a2,0(s5)
ffffffffc02018d0:	46a9                	li	a3,10
ffffffffc02018d2:	8aae                	mv	s5,a1
ffffffffc02018d4:	b7bd                	j	ffffffffc0201842 <vprintfmt+0x170>
ffffffffc02018d6:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02018da:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018de:	846a                	mv	s0,s10
ffffffffc02018e0:	b5ad                	j	ffffffffc020174a <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02018e2:	85a6                	mv	a1,s1
ffffffffc02018e4:	02500513          	li	a0,37
ffffffffc02018e8:	9902                	jalr	s2
            break;
ffffffffc02018ea:	b50d                	j	ffffffffc020170c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02018ec:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02018f0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02018f4:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018f6:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02018f8:	e40dd9e3          	bgez	s11,ffffffffc020174a <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02018fc:	8de6                	mv	s11,s9
ffffffffc02018fe:	5cfd                	li	s9,-1
ffffffffc0201900:	b5a9                	j	ffffffffc020174a <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201902:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201906:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020190a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020190c:	bd3d                	j	ffffffffc020174a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020190e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201912:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201916:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201918:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020191c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201920:	fcd56ce3          	bltu	a0,a3,ffffffffc02018f8 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201924:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201926:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020192a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020192e:	0196873b          	addw	a4,a3,s9
ffffffffc0201932:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201936:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020193a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020193e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201942:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201946:	fcd57fe3          	bleu	a3,a0,ffffffffc0201924 <vprintfmt+0x252>
ffffffffc020194a:	b77d                	j	ffffffffc02018f8 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020194c:	fffdc693          	not	a3,s11
ffffffffc0201950:	96fd                	srai	a3,a3,0x3f
ffffffffc0201952:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201956:	00144603          	lbu	a2,1(s0)
ffffffffc020195a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020195c:	846a                	mv	s0,s10
ffffffffc020195e:	b3f5                	j	ffffffffc020174a <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201960:	85a6                	mv	a1,s1
ffffffffc0201962:	02500513          	li	a0,37
ffffffffc0201966:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201968:	fff44703          	lbu	a4,-1(s0)
ffffffffc020196c:	02500793          	li	a5,37
ffffffffc0201970:	8d22                	mv	s10,s0
ffffffffc0201972:	d8f70de3          	beq	a4,a5,ffffffffc020170c <vprintfmt+0x3a>
ffffffffc0201976:	02500713          	li	a4,37
ffffffffc020197a:	1d7d                	addi	s10,s10,-1
ffffffffc020197c:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201980:	fee79de3          	bne	a5,a4,ffffffffc020197a <vprintfmt+0x2a8>
ffffffffc0201984:	b361                	j	ffffffffc020170c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201986:	00001617          	auipc	a2,0x1
ffffffffc020198a:	0ba60613          	addi	a2,a2,186 # ffffffffc0202a40 <error_string+0xd8>
ffffffffc020198e:	85a6                	mv	a1,s1
ffffffffc0201990:	854a                	mv	a0,s2
ffffffffc0201992:	0ac000ef          	jal	ra,ffffffffc0201a3e <printfmt>
ffffffffc0201996:	bb9d                	j	ffffffffc020170c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201998:	00001617          	auipc	a2,0x1
ffffffffc020199c:	0a060613          	addi	a2,a2,160 # ffffffffc0202a38 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02019a0:	00001417          	auipc	s0,0x1
ffffffffc02019a4:	09940413          	addi	s0,s0,153 # ffffffffc0202a39 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019a8:	8532                	mv	a0,a2
ffffffffc02019aa:	85e6                	mv	a1,s9
ffffffffc02019ac:	e032                	sd	a2,0(sp)
ffffffffc02019ae:	e43e                	sd	a5,8(sp)
ffffffffc02019b0:	c37ff0ef          	jal	ra,ffffffffc02015e6 <strnlen>
ffffffffc02019b4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02019b8:	6602                	ld	a2,0(sp)
ffffffffc02019ba:	01b05d63          	blez	s11,ffffffffc02019d4 <vprintfmt+0x302>
ffffffffc02019be:	67a2                	ld	a5,8(sp)
ffffffffc02019c0:	2781                	sext.w	a5,a5
ffffffffc02019c2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02019c4:	6522                	ld	a0,8(sp)
ffffffffc02019c6:	85a6                	mv	a1,s1
ffffffffc02019c8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019ca:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02019cc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019ce:	6602                	ld	a2,0(sp)
ffffffffc02019d0:	fe0d9ae3          	bnez	s11,ffffffffc02019c4 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019d4:	00064783          	lbu	a5,0(a2)
ffffffffc02019d8:	0007851b          	sext.w	a0,a5
ffffffffc02019dc:	e8051be3          	bnez	a0,ffffffffc0201872 <vprintfmt+0x1a0>
ffffffffc02019e0:	b335                	j	ffffffffc020170c <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02019e2:	000aa403          	lw	s0,0(s5)
ffffffffc02019e6:	bbf1                	j	ffffffffc02017c2 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02019e8:	000ae603          	lwu	a2,0(s5)
ffffffffc02019ec:	46a9                	li	a3,10
ffffffffc02019ee:	8aae                	mv	s5,a1
ffffffffc02019f0:	bd89                	j	ffffffffc0201842 <vprintfmt+0x170>
ffffffffc02019f2:	000ae603          	lwu	a2,0(s5)
ffffffffc02019f6:	46c1                	li	a3,16
ffffffffc02019f8:	8aae                	mv	s5,a1
ffffffffc02019fa:	b5a1                	j	ffffffffc0201842 <vprintfmt+0x170>
ffffffffc02019fc:	000ae603          	lwu	a2,0(s5)
ffffffffc0201a00:	46a1                	li	a3,8
ffffffffc0201a02:	8aae                	mv	s5,a1
ffffffffc0201a04:	bd3d                	j	ffffffffc0201842 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201a06:	9902                	jalr	s2
ffffffffc0201a08:	b559                	j	ffffffffc020188e <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201a0a:	85a6                	mv	a1,s1
ffffffffc0201a0c:	02d00513          	li	a0,45
ffffffffc0201a10:	e03e                	sd	a5,0(sp)
ffffffffc0201a12:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201a14:	8ace                	mv	s5,s3
ffffffffc0201a16:	40800633          	neg	a2,s0
ffffffffc0201a1a:	46a9                	li	a3,10
ffffffffc0201a1c:	6782                	ld	a5,0(sp)
ffffffffc0201a1e:	b515                	j	ffffffffc0201842 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201a20:	01b05663          	blez	s11,ffffffffc0201a2c <vprintfmt+0x35a>
ffffffffc0201a24:	02d00693          	li	a3,45
ffffffffc0201a28:	f6d798e3          	bne	a5,a3,ffffffffc0201998 <vprintfmt+0x2c6>
ffffffffc0201a2c:	00001417          	auipc	s0,0x1
ffffffffc0201a30:	00d40413          	addi	s0,s0,13 # ffffffffc0202a39 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a34:	02800513          	li	a0,40
ffffffffc0201a38:	02800793          	li	a5,40
ffffffffc0201a3c:	bd1d                	j	ffffffffc0201872 <vprintfmt+0x1a0>

ffffffffc0201a3e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a3e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201a40:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a44:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a46:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a48:	ec06                	sd	ra,24(sp)
ffffffffc0201a4a:	f83a                	sd	a4,48(sp)
ffffffffc0201a4c:	fc3e                	sd	a5,56(sp)
ffffffffc0201a4e:	e0c2                	sd	a6,64(sp)
ffffffffc0201a50:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a52:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a54:	c7fff0ef          	jal	ra,ffffffffc02016d2 <vprintfmt>
}
ffffffffc0201a58:	60e2                	ld	ra,24(sp)
ffffffffc0201a5a:	6161                	addi	sp,sp,80
ffffffffc0201a5c:	8082                	ret

ffffffffc0201a5e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a5e:	715d                	addi	sp,sp,-80
ffffffffc0201a60:	e486                	sd	ra,72(sp)
ffffffffc0201a62:	e0a2                	sd	s0,64(sp)
ffffffffc0201a64:	fc26                	sd	s1,56(sp)
ffffffffc0201a66:	f84a                	sd	s2,48(sp)
ffffffffc0201a68:	f44e                	sd	s3,40(sp)
ffffffffc0201a6a:	f052                	sd	s4,32(sp)
ffffffffc0201a6c:	ec56                	sd	s5,24(sp)
ffffffffc0201a6e:	e85a                	sd	s6,16(sp)
ffffffffc0201a70:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201a72:	c901                	beqz	a0,ffffffffc0201a82 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201a74:	85aa                	mv	a1,a0
ffffffffc0201a76:	00001517          	auipc	a0,0x1
ffffffffc0201a7a:	fda50513          	addi	a0,a0,-38 # ffffffffc0202a50 <error_string+0xe8>
ffffffffc0201a7e:	e38fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201a82:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a84:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201a86:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201a88:	4aa9                	li	s5,10
ffffffffc0201a8a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201a8c:	00004b97          	auipc	s7,0x4
ffffffffc0201a90:	58cb8b93          	addi	s7,s7,1420 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a94:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201a98:	e96fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a9c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a9e:	00054b63          	bltz	a0,ffffffffc0201ab4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201aa2:	00a95b63          	ble	a0,s2,ffffffffc0201ab8 <readline+0x5a>
ffffffffc0201aa6:	029a5463          	ble	s1,s4,ffffffffc0201ace <readline+0x70>
        c = getchar();
ffffffffc0201aaa:	e84fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201aae:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201ab0:	fe0559e3          	bgez	a0,ffffffffc0201aa2 <readline+0x44>
            return NULL;
ffffffffc0201ab4:	4501                	li	a0,0
ffffffffc0201ab6:	a099                	j	ffffffffc0201afc <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201ab8:	03341463          	bne	s0,s3,ffffffffc0201ae0 <readline+0x82>
ffffffffc0201abc:	e8b9                	bnez	s1,ffffffffc0201b12 <readline+0xb4>
        c = getchar();
ffffffffc0201abe:	e70fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201ac2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201ac4:	fe0548e3          	bltz	a0,ffffffffc0201ab4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ac8:	fea958e3          	ble	a0,s2,ffffffffc0201ab8 <readline+0x5a>
ffffffffc0201acc:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201ace:	8522                	mv	a0,s0
ffffffffc0201ad0:	e1afe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201ad4:	009b87b3          	add	a5,s7,s1
ffffffffc0201ad8:	00878023          	sb	s0,0(a5)
ffffffffc0201adc:	2485                	addiw	s1,s1,1
ffffffffc0201ade:	bf6d                	j	ffffffffc0201a98 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201ae0:	01540463          	beq	s0,s5,ffffffffc0201ae8 <readline+0x8a>
ffffffffc0201ae4:	fb641ae3          	bne	s0,s6,ffffffffc0201a98 <readline+0x3a>
            cputchar(c);
ffffffffc0201ae8:	8522                	mv	a0,s0
ffffffffc0201aea:	e00fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201aee:	00004517          	auipc	a0,0x4
ffffffffc0201af2:	52a50513          	addi	a0,a0,1322 # ffffffffc0206018 <edata>
ffffffffc0201af6:	94aa                	add	s1,s1,a0
ffffffffc0201af8:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201afc:	60a6                	ld	ra,72(sp)
ffffffffc0201afe:	6406                	ld	s0,64(sp)
ffffffffc0201b00:	74e2                	ld	s1,56(sp)
ffffffffc0201b02:	7942                	ld	s2,48(sp)
ffffffffc0201b04:	79a2                	ld	s3,40(sp)
ffffffffc0201b06:	7a02                	ld	s4,32(sp)
ffffffffc0201b08:	6ae2                	ld	s5,24(sp)
ffffffffc0201b0a:	6b42                	ld	s6,16(sp)
ffffffffc0201b0c:	6ba2                	ld	s7,8(sp)
ffffffffc0201b0e:	6161                	addi	sp,sp,80
ffffffffc0201b10:	8082                	ret
            cputchar(c);
ffffffffc0201b12:	4521                	li	a0,8
ffffffffc0201b14:	dd6fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201b18:	34fd                	addiw	s1,s1,-1
ffffffffc0201b1a:	bfbd                	j	ffffffffc0201a98 <readline+0x3a>

ffffffffc0201b1c <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201b1c:	00004797          	auipc	a5,0x4
ffffffffc0201b20:	4ec78793          	addi	a5,a5,1260 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201b24:	6398                	ld	a4,0(a5)
ffffffffc0201b26:	4781                	li	a5,0
ffffffffc0201b28:	88ba                	mv	a7,a4
ffffffffc0201b2a:	852a                	mv	a0,a0
ffffffffc0201b2c:	85be                	mv	a1,a5
ffffffffc0201b2e:	863e                	mv	a2,a5
ffffffffc0201b30:	00000073          	ecall
ffffffffc0201b34:	87aa                	mv	a5,a0
}
ffffffffc0201b36:	8082                	ret

ffffffffc0201b38 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201b38:	00005797          	auipc	a5,0x5
ffffffffc0201b3c:	90078793          	addi	a5,a5,-1792 # ffffffffc0206438 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201b40:	6398                	ld	a4,0(a5)
ffffffffc0201b42:	4781                	li	a5,0
ffffffffc0201b44:	88ba                	mv	a7,a4
ffffffffc0201b46:	852a                	mv	a0,a0
ffffffffc0201b48:	85be                	mv	a1,a5
ffffffffc0201b4a:	863e                	mv	a2,a5
ffffffffc0201b4c:	00000073          	ecall
ffffffffc0201b50:	87aa                	mv	a5,a0
}
ffffffffc0201b52:	8082                	ret

ffffffffc0201b54 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b54:	00004797          	auipc	a5,0x4
ffffffffc0201b58:	4ac78793          	addi	a5,a5,1196 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201b5c:	639c                	ld	a5,0(a5)
ffffffffc0201b5e:	4501                	li	a0,0
ffffffffc0201b60:	88be                	mv	a7,a5
ffffffffc0201b62:	852a                	mv	a0,a0
ffffffffc0201b64:	85aa                	mv	a1,a0
ffffffffc0201b66:	862a                	mv	a2,a0
ffffffffc0201b68:	00000073          	ecall
ffffffffc0201b6c:	852a                	mv	a0,a0
}
ffffffffc0201b6e:	2501                	sext.w	a0,a0
ffffffffc0201b70:	8082                	ret

ffffffffc0201b72 <sbi_shutdown>:

void sbi_shutdown(void){
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201b72:	00004797          	auipc	a5,0x4
ffffffffc0201b76:	49e78793          	addi	a5,a5,1182 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201b7a:	6398                	ld	a4,0(a5)
ffffffffc0201b7c:	4781                	li	a5,0
ffffffffc0201b7e:	88ba                	mv	a7,a4
ffffffffc0201b80:	853e                	mv	a0,a5
ffffffffc0201b82:	85be                	mv	a1,a5
ffffffffc0201b84:	863e                	mv	a2,a5
ffffffffc0201b86:	00000073          	ecall
ffffffffc0201b8a:	87aa                	mv	a5,a0
}
ffffffffc0201b8c:	8082                	ret
