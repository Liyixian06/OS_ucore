
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc0200028:	c020a137          	lui	sp,0xc020a

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000b517          	auipc	a0,0xb
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020b060 <edata>
ffffffffc020003e:	00016617          	auipc	a2,0x16
ffffffffc0200042:	5ca60613          	addi	a2,a2,1482 # ffffffffc0216608 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	451040ef          	jal	ra,ffffffffc0204c9e <memset>

    cons_init();                // init the console
ffffffffc0200052:	50c000ef          	jal	ra,ffffffffc020055e <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	0b258593          	addi	a1,a1,178 # ffffffffc0205108 <etext>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	0ca50513          	addi	a0,a0,202 # ffffffffc0205128 <etext+0x20>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1cc000ef          	jal	ra,ffffffffc0200236 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	070010ef          	jal	ra,ffffffffc02010de <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	560000ef          	jal	ra,ffffffffc02005d2 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5dc000ef          	jal	ra,ffffffffc0200652 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	5b3010ef          	jal	ra,ffffffffc0201e2c <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	0a7040ef          	jal	ra,ffffffffc0204924 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	42e000ef          	jal	ra,ffffffffc02004b0 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	3f2020ef          	jal	ra,ffffffffc0202478 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	47e000ef          	jal	ra,ffffffffc0200508 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	546000ef          	jal	ra,ffffffffc02005d4 <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	287040ef          	jal	ra,ffffffffc0204b18 <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	4c2000ef          	jal	ra,ffffffffc0200560 <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	4a1040ef          	jal	ra,ffffffffc0204d64 <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	46d040ef          	jal	ra,ffffffffc0204d64 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	45c0006f          	j	ffffffffc0200560 <cons_putc>

ffffffffc0200108 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200108:	1141                	addi	sp,sp,-16
ffffffffc020010a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020010c:	48a000ef          	jal	ra,ffffffffc0200596 <cons_getc>
ffffffffc0200110:	dd75                	beqz	a0,ffffffffc020010c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200112:	60a2                	ld	ra,8(sp)
ffffffffc0200114:	0141                	addi	sp,sp,16
ffffffffc0200116:	8082                	ret

ffffffffc0200118 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200118:	715d                	addi	sp,sp,-80
ffffffffc020011a:	e486                	sd	ra,72(sp)
ffffffffc020011c:	e0a2                	sd	s0,64(sp)
ffffffffc020011e:	fc26                	sd	s1,56(sp)
ffffffffc0200120:	f84a                	sd	s2,48(sp)
ffffffffc0200122:	f44e                	sd	s3,40(sp)
ffffffffc0200124:	f052                	sd	s4,32(sp)
ffffffffc0200126:	ec56                	sd	s5,24(sp)
ffffffffc0200128:	e85a                	sd	s6,16(sp)
ffffffffc020012a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020012c:	c901                	beqz	a0,ffffffffc020013c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020012e:	85aa                	mv	a1,a0
ffffffffc0200130:	00005517          	auipc	a0,0x5
ffffffffc0200134:	00050513          	mv	a0,a0
ffffffffc0200138:	f99ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020013c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020013e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200140:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200142:	4aa9                	li	s5,10
ffffffffc0200144:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200146:	0000bb97          	auipc	s7,0xb
ffffffffc020014a:	f1ab8b93          	addi	s7,s7,-230 # ffffffffc020b060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020014e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200152:	fb7ff0ef          	jal	ra,ffffffffc0200108 <getchar>
ffffffffc0200156:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200158:	00054b63          	bltz	a0,ffffffffc020016e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020015c:	00a95b63          	ble	a0,s2,ffffffffc0200172 <readline+0x5a>
ffffffffc0200160:	029a5463          	ble	s1,s4,ffffffffc0200188 <readline+0x70>
        c = getchar();
ffffffffc0200164:	fa5ff0ef          	jal	ra,ffffffffc0200108 <getchar>
ffffffffc0200168:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020016a:	fe0559e3          	bgez	a0,ffffffffc020015c <readline+0x44>
            return NULL;
ffffffffc020016e:	4501                	li	a0,0
ffffffffc0200170:	a099                	j	ffffffffc02001b6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0200172:	03341463          	bne	s0,s3,ffffffffc020019a <readline+0x82>
ffffffffc0200176:	e8b9                	bnez	s1,ffffffffc02001cc <readline+0xb4>
        c = getchar();
ffffffffc0200178:	f91ff0ef          	jal	ra,ffffffffc0200108 <getchar>
ffffffffc020017c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020017e:	fe0548e3          	bltz	a0,ffffffffc020016e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200182:	fea958e3          	ble	a0,s2,ffffffffc0200172 <readline+0x5a>
ffffffffc0200186:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200188:	8522                	mv	a0,s0
ffffffffc020018a:	f7bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc020018e:	009b87b3          	add	a5,s7,s1
ffffffffc0200192:	00878023          	sb	s0,0(a5)
ffffffffc0200196:	2485                	addiw	s1,s1,1
ffffffffc0200198:	bf6d                	j	ffffffffc0200152 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020019a:	01540463          	beq	s0,s5,ffffffffc02001a2 <readline+0x8a>
ffffffffc020019e:	fb641ae3          	bne	s0,s6,ffffffffc0200152 <readline+0x3a>
            cputchar(c);
ffffffffc02001a2:	8522                	mv	a0,s0
ffffffffc02001a4:	f61ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001a8:	0000b517          	auipc	a0,0xb
ffffffffc02001ac:	eb850513          	addi	a0,a0,-328 # ffffffffc020b060 <edata>
ffffffffc02001b0:	94aa                	add	s1,s1,a0
ffffffffc02001b2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001b6:	60a6                	ld	ra,72(sp)
ffffffffc02001b8:	6406                	ld	s0,64(sp)
ffffffffc02001ba:	74e2                	ld	s1,56(sp)
ffffffffc02001bc:	7942                	ld	s2,48(sp)
ffffffffc02001be:	79a2                	ld	s3,40(sp)
ffffffffc02001c0:	7a02                	ld	s4,32(sp)
ffffffffc02001c2:	6ae2                	ld	s5,24(sp)
ffffffffc02001c4:	6b42                	ld	s6,16(sp)
ffffffffc02001c6:	6ba2                	ld	s7,8(sp)
ffffffffc02001c8:	6161                	addi	sp,sp,80
ffffffffc02001ca:	8082                	ret
            cputchar(c);
ffffffffc02001cc:	4521                	li	a0,8
ffffffffc02001ce:	f37ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc02001d2:	34fd                	addiw	s1,s1,-1
ffffffffc02001d4:	bfbd                	j	ffffffffc0200152 <readline+0x3a>

ffffffffc02001d6 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001d6:	00016317          	auipc	t1,0x16
ffffffffc02001da:	29a30313          	addi	t1,t1,666 # ffffffffc0216470 <is_panic>
ffffffffc02001de:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001e2:	715d                	addi	sp,sp,-80
ffffffffc02001e4:	ec06                	sd	ra,24(sp)
ffffffffc02001e6:	e822                	sd	s0,16(sp)
ffffffffc02001e8:	f436                	sd	a3,40(sp)
ffffffffc02001ea:	f83a                	sd	a4,48(sp)
ffffffffc02001ec:	fc3e                	sd	a5,56(sp)
ffffffffc02001ee:	e0c2                	sd	a6,64(sp)
ffffffffc02001f0:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001f2:	02031c63          	bnez	t1,ffffffffc020022a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001f6:	4785                	li	a5,1
ffffffffc02001f8:	8432                	mv	s0,a2
ffffffffc02001fa:	00016717          	auipc	a4,0x16
ffffffffc02001fe:	26f72b23          	sw	a5,630(a4) # ffffffffc0216470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200202:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200204:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200206:	85aa                	mv	a1,a0
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	f3050513          	addi	a0,a0,-208 # ffffffffc0205138 <etext+0x30>
    va_start(ap, fmt);
ffffffffc0200210:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200212:	ebfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200216:	65a2                	ld	a1,8(sp)
ffffffffc0200218:	8522                	mv	a0,s0
ffffffffc020021a:	e97ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020021e:	00006517          	auipc	a0,0x6
ffffffffc0200222:	d4a50513          	addi	a0,a0,-694 # ffffffffc0205f68 <commands+0xd10>
ffffffffc0200226:	eabff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020022a:	3b0000ef          	jal	ra,ffffffffc02005da <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020022e:	4501                	li	a0,0
ffffffffc0200230:	132000ef          	jal	ra,ffffffffc0200362 <kmonitor>
ffffffffc0200234:	bfed                	j	ffffffffc020022e <__panic+0x58>

ffffffffc0200236 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200236:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200238:	00005517          	auipc	a0,0x5
ffffffffc020023c:	f5050513          	addi	a0,a0,-176 # ffffffffc0205188 <etext+0x80>
void print_kerninfo(void) {
ffffffffc0200240:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200242:	e8fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200246:	00000597          	auipc	a1,0x0
ffffffffc020024a:	df058593          	addi	a1,a1,-528 # ffffffffc0200036 <kern_init>
ffffffffc020024e:	00005517          	auipc	a0,0x5
ffffffffc0200252:	f5a50513          	addi	a0,a0,-166 # ffffffffc02051a8 <etext+0xa0>
ffffffffc0200256:	e7bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020025a:	00005597          	auipc	a1,0x5
ffffffffc020025e:	eae58593          	addi	a1,a1,-338 # ffffffffc0205108 <etext>
ffffffffc0200262:	00005517          	auipc	a0,0x5
ffffffffc0200266:	f6650513          	addi	a0,a0,-154 # ffffffffc02051c8 <etext+0xc0>
ffffffffc020026a:	e67ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020026e:	0000b597          	auipc	a1,0xb
ffffffffc0200272:	df258593          	addi	a1,a1,-526 # ffffffffc020b060 <edata>
ffffffffc0200276:	00005517          	auipc	a0,0x5
ffffffffc020027a:	f7250513          	addi	a0,a0,-142 # ffffffffc02051e8 <etext+0xe0>
ffffffffc020027e:	e53ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200282:	00016597          	auipc	a1,0x16
ffffffffc0200286:	38658593          	addi	a1,a1,902 # ffffffffc0216608 <end>
ffffffffc020028a:	00005517          	auipc	a0,0x5
ffffffffc020028e:	f7e50513          	addi	a0,a0,-130 # ffffffffc0205208 <etext+0x100>
ffffffffc0200292:	e3fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200296:	00016597          	auipc	a1,0x16
ffffffffc020029a:	77158593          	addi	a1,a1,1905 # ffffffffc0216a07 <end+0x3ff>
ffffffffc020029e:	00000797          	auipc	a5,0x0
ffffffffc02002a2:	d9878793          	addi	a5,a5,-616 # ffffffffc0200036 <kern_init>
ffffffffc02002a6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002aa:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002ae:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002b4:	95be                	add	a1,a1,a5
ffffffffc02002b6:	85a9                	srai	a1,a1,0xa
ffffffffc02002b8:	00005517          	auipc	a0,0x5
ffffffffc02002bc:	f7050513          	addi	a0,a0,-144 # ffffffffc0205228 <etext+0x120>
}
ffffffffc02002c0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002c2:	e0fff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02002c6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002c6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002c8:	00005617          	auipc	a2,0x5
ffffffffc02002cc:	e9060613          	addi	a2,a2,-368 # ffffffffc0205158 <etext+0x50>
ffffffffc02002d0:	04d00593          	li	a1,77
ffffffffc02002d4:	00005517          	auipc	a0,0x5
ffffffffc02002d8:	e9c50513          	addi	a0,a0,-356 # ffffffffc0205170 <etext+0x68>
void print_stackframe(void) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002de:	ef9ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02002e2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e4:	00005617          	auipc	a2,0x5
ffffffffc02002e8:	05460613          	addi	a2,a2,84 # ffffffffc0205338 <commands+0xe0>
ffffffffc02002ec:	00005597          	auipc	a1,0x5
ffffffffc02002f0:	06c58593          	addi	a1,a1,108 # ffffffffc0205358 <commands+0x100>
ffffffffc02002f4:	00005517          	auipc	a0,0x5
ffffffffc02002f8:	06c50513          	addi	a0,a0,108 # ffffffffc0205360 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002fc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002fe:	dd3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200302:	00005617          	auipc	a2,0x5
ffffffffc0200306:	06e60613          	addi	a2,a2,110 # ffffffffc0205370 <commands+0x118>
ffffffffc020030a:	00005597          	auipc	a1,0x5
ffffffffc020030e:	08e58593          	addi	a1,a1,142 # ffffffffc0205398 <commands+0x140>
ffffffffc0200312:	00005517          	auipc	a0,0x5
ffffffffc0200316:	04e50513          	addi	a0,a0,78 # ffffffffc0205360 <commands+0x108>
ffffffffc020031a:	db7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020031e:	00005617          	auipc	a2,0x5
ffffffffc0200322:	08a60613          	addi	a2,a2,138 # ffffffffc02053a8 <commands+0x150>
ffffffffc0200326:	00005597          	auipc	a1,0x5
ffffffffc020032a:	0a258593          	addi	a1,a1,162 # ffffffffc02053c8 <commands+0x170>
ffffffffc020032e:	00005517          	auipc	a0,0x5
ffffffffc0200332:	03250513          	addi	a0,a0,50 # ffffffffc0205360 <commands+0x108>
ffffffffc0200336:	d9bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	0141                	addi	sp,sp,16
ffffffffc0200340:	8082                	ret

ffffffffc0200342 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
ffffffffc0200344:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200346:	ef1ff0ef          	jal	ra,ffffffffc0200236 <print_kerninfo>
    return 0;
}
ffffffffc020034a:	60a2                	ld	ra,8(sp)
ffffffffc020034c:	4501                	li	a0,0
ffffffffc020034e:	0141                	addi	sp,sp,16
ffffffffc0200350:	8082                	ret

ffffffffc0200352 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200352:	1141                	addi	sp,sp,-16
ffffffffc0200354:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200356:	f71ff0ef          	jal	ra,ffffffffc02002c6 <print_stackframe>
    return 0;
}
ffffffffc020035a:	60a2                	ld	ra,8(sp)
ffffffffc020035c:	4501                	li	a0,0
ffffffffc020035e:	0141                	addi	sp,sp,16
ffffffffc0200360:	8082                	ret

ffffffffc0200362 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200362:	7115                	addi	sp,sp,-224
ffffffffc0200364:	e962                	sd	s8,144(sp)
ffffffffc0200366:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200368:	00005517          	auipc	a0,0x5
ffffffffc020036c:	f3850513          	addi	a0,a0,-200 # ffffffffc02052a0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200370:	ed86                	sd	ra,216(sp)
ffffffffc0200372:	e9a2                	sd	s0,208(sp)
ffffffffc0200374:	e5a6                	sd	s1,200(sp)
ffffffffc0200376:	e1ca                	sd	s2,192(sp)
ffffffffc0200378:	fd4e                	sd	s3,184(sp)
ffffffffc020037a:	f952                	sd	s4,176(sp)
ffffffffc020037c:	f556                	sd	s5,168(sp)
ffffffffc020037e:	f15a                	sd	s6,160(sp)
ffffffffc0200380:	ed5e                	sd	s7,152(sp)
ffffffffc0200382:	e566                	sd	s9,136(sp)
ffffffffc0200384:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200386:	d4bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020038a:	00005517          	auipc	a0,0x5
ffffffffc020038e:	f3e50513          	addi	a0,a0,-194 # ffffffffc02052c8 <commands+0x70>
ffffffffc0200392:	d3fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200396:	000c0563          	beqz	s8,ffffffffc02003a0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020039a:	8562                	mv	a0,s8
ffffffffc020039c:	49e000ef          	jal	ra,ffffffffc020083a <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02003a0:	4501                	li	a0,0
ffffffffc02003a2:	4581                	li	a1,0
ffffffffc02003a4:	4601                	li	a2,0
ffffffffc02003a6:	48a1                	li	a7,8
ffffffffc02003a8:	00000073          	ecall
ffffffffc02003ac:	00005c97          	auipc	s9,0x5
ffffffffc02003b0:	eacc8c93          	addi	s9,s9,-340 # ffffffffc0205258 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b4:	00005997          	auipc	s3,0x5
ffffffffc02003b8:	f3c98993          	addi	s3,s3,-196 # ffffffffc02052f0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003bc:	00005917          	auipc	s2,0x5
ffffffffc02003c0:	f3c90913          	addi	s2,s2,-196 # ffffffffc02052f8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02003c4:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c6:	00005b17          	auipc	s6,0x5
ffffffffc02003ca:	f3ab0b13          	addi	s6,s6,-198 # ffffffffc0205300 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003ce:	00005a97          	auipc	s5,0x5
ffffffffc02003d2:	f8aa8a93          	addi	s5,s5,-118 # ffffffffc0205358 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d6:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003d8:	854e                	mv	a0,s3
ffffffffc02003da:	d3fff0ef          	jal	ra,ffffffffc0200118 <readline>
ffffffffc02003de:	842a                	mv	s0,a0
ffffffffc02003e0:	dd65                	beqz	a0,ffffffffc02003d8 <kmonitor+0x76>
ffffffffc02003e2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003e6:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e8:	c999                	beqz	a1,ffffffffc02003fe <kmonitor+0x9c>
ffffffffc02003ea:	854a                	mv	a0,s2
ffffffffc02003ec:	095040ef          	jal	ra,ffffffffc0204c80 <strchr>
ffffffffc02003f0:	c925                	beqz	a0,ffffffffc0200460 <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc02003f2:	00144583          	lbu	a1,1(s0)
ffffffffc02003f6:	00040023          	sb	zero,0(s0)
ffffffffc02003fa:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003fc:	f5fd                	bnez	a1,ffffffffc02003ea <kmonitor+0x88>
    if (argc == 0) {
ffffffffc02003fe:	dce9                	beqz	s1,ffffffffc02003d8 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200400:	6582                	ld	a1,0(sp)
ffffffffc0200402:	00005d17          	auipc	s10,0x5
ffffffffc0200406:	e56d0d13          	addi	s10,s10,-426 # ffffffffc0205258 <commands>
    if (argc == 0) {
ffffffffc020040a:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020040c:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040e:	0d61                	addi	s10,s10,24
ffffffffc0200410:	047040ef          	jal	ra,ffffffffc0204c56 <strcmp>
ffffffffc0200414:	c919                	beqz	a0,ffffffffc020042a <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200416:	2405                	addiw	s0,s0,1
ffffffffc0200418:	09740463          	beq	s0,s7,ffffffffc02004a0 <kmonitor+0x13e>
ffffffffc020041c:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200420:	6582                	ld	a1,0(sp)
ffffffffc0200422:	0d61                	addi	s10,s10,24
ffffffffc0200424:	033040ef          	jal	ra,ffffffffc0204c56 <strcmp>
ffffffffc0200428:	f57d                	bnez	a0,ffffffffc0200416 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020042a:	00141793          	slli	a5,s0,0x1
ffffffffc020042e:	97a2                	add	a5,a5,s0
ffffffffc0200430:	078e                	slli	a5,a5,0x3
ffffffffc0200432:	97e6                	add	a5,a5,s9
ffffffffc0200434:	6b9c                	ld	a5,16(a5)
ffffffffc0200436:	8662                	mv	a2,s8
ffffffffc0200438:	002c                	addi	a1,sp,8
ffffffffc020043a:	fff4851b          	addiw	a0,s1,-1
ffffffffc020043e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200440:	f8055ce3          	bgez	a0,ffffffffc02003d8 <kmonitor+0x76>
}
ffffffffc0200444:	60ee                	ld	ra,216(sp)
ffffffffc0200446:	644e                	ld	s0,208(sp)
ffffffffc0200448:	64ae                	ld	s1,200(sp)
ffffffffc020044a:	690e                	ld	s2,192(sp)
ffffffffc020044c:	79ea                	ld	s3,184(sp)
ffffffffc020044e:	7a4a                	ld	s4,176(sp)
ffffffffc0200450:	7aaa                	ld	s5,168(sp)
ffffffffc0200452:	7b0a                	ld	s6,160(sp)
ffffffffc0200454:	6bea                	ld	s7,152(sp)
ffffffffc0200456:	6c4a                	ld	s8,144(sp)
ffffffffc0200458:	6caa                	ld	s9,136(sp)
ffffffffc020045a:	6d0a                	ld	s10,128(sp)
ffffffffc020045c:	612d                	addi	sp,sp,224
ffffffffc020045e:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200460:	00044783          	lbu	a5,0(s0)
ffffffffc0200464:	dfc9                	beqz	a5,ffffffffc02003fe <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200466:	03448863          	beq	s1,s4,ffffffffc0200496 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc020046a:	00349793          	slli	a5,s1,0x3
ffffffffc020046e:	0118                	addi	a4,sp,128
ffffffffc0200470:	97ba                	add	a5,a5,a4
ffffffffc0200472:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200476:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020047a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020047c:	e591                	bnez	a1,ffffffffc0200488 <kmonitor+0x126>
ffffffffc020047e:	b749                	j	ffffffffc0200400 <kmonitor+0x9e>
            buf ++;
ffffffffc0200480:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200482:	00044583          	lbu	a1,0(s0)
ffffffffc0200486:	ddad                	beqz	a1,ffffffffc0200400 <kmonitor+0x9e>
ffffffffc0200488:	854a                	mv	a0,s2
ffffffffc020048a:	7f6040ef          	jal	ra,ffffffffc0204c80 <strchr>
ffffffffc020048e:	d96d                	beqz	a0,ffffffffc0200480 <kmonitor+0x11e>
ffffffffc0200490:	00044583          	lbu	a1,0(s0)
ffffffffc0200494:	bf91                	j	ffffffffc02003e8 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200496:	45c1                	li	a1,16
ffffffffc0200498:	855a                	mv	a0,s6
ffffffffc020049a:	c37ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020049e:	b7f1                	j	ffffffffc020046a <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02004a0:	6582                	ld	a1,0(sp)
ffffffffc02004a2:	00005517          	auipc	a0,0x5
ffffffffc02004a6:	e7e50513          	addi	a0,a0,-386 # ffffffffc0205320 <commands+0xc8>
ffffffffc02004aa:	c27ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc02004ae:	b72d                	j	ffffffffc02003d8 <kmonitor+0x76>

ffffffffc02004b0 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004b0:	8082                	ret

ffffffffc02004b2 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004b2:	00253513          	sltiu	a0,a0,2
ffffffffc02004b6:	8082                	ret

ffffffffc02004b8 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004b8:	03800513          	li	a0,56
ffffffffc02004bc:	8082                	ret

ffffffffc02004be <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004be:	0000b797          	auipc	a5,0xb
ffffffffc02004c2:	fa278793          	addi	a5,a5,-94 # ffffffffc020b460 <ide>
ffffffffc02004c6:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ca:	1141                	addi	sp,sp,-16
ffffffffc02004cc:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ce:	95be                	add	a1,a1,a5
ffffffffc02004d0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004d4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004d6:	7da040ef          	jal	ra,ffffffffc0204cb0 <memcpy>
    return 0;
}
ffffffffc02004da:	60a2                	ld	ra,8(sp)
ffffffffc02004dc:	4501                	li	a0,0
ffffffffc02004de:	0141                	addi	sp,sp,16
ffffffffc02004e0:	8082                	ret

ffffffffc02004e2 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004e2:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e4:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004e8:	0000b517          	auipc	a0,0xb
ffffffffc02004ec:	f7850513          	addi	a0,a0,-136 # ffffffffc020b460 <ide>
                   size_t nsecs) {
ffffffffc02004f0:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004f2:	00969613          	slli	a2,a3,0x9
ffffffffc02004f6:	85ba                	mv	a1,a4
ffffffffc02004f8:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004fa:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004fc:	7b4040ef          	jal	ra,ffffffffc0204cb0 <memcpy>
    return 0;
}
ffffffffc0200500:	60a2                	ld	ra,8(sp)
ffffffffc0200502:	4501                	li	a0,0
ffffffffc0200504:	0141                	addi	sp,sp,16
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200508:	67e1                	lui	a5,0x18
ffffffffc020050a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020050e:	00016717          	auipc	a4,0x16
ffffffffc0200512:	f6f73523          	sd	a5,-150(a4) # ffffffffc0216478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200516:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020051a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020051c:	953e                	add	a0,a0,a5
ffffffffc020051e:	4601                	li	a2,0
ffffffffc0200520:	4881                	li	a7,0
ffffffffc0200522:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200526:	02000793          	li	a5,32
ffffffffc020052a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020052e:	00005517          	auipc	a0,0x5
ffffffffc0200532:	eaa50513          	addi	a0,a0,-342 # ffffffffc02053d8 <commands+0x180>
    ticks = 0;
ffffffffc0200536:	00016797          	auipc	a5,0x16
ffffffffc020053a:	fa07b123          	sd	zero,-94(a5) # ffffffffc02164d8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020053e:	b93ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200542 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200542:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200546:	00016797          	auipc	a5,0x16
ffffffffc020054a:	f3278793          	addi	a5,a5,-206 # ffffffffc0216478 <timebase>
ffffffffc020054e:	639c                	ld	a5,0(a5)
ffffffffc0200550:	4581                	li	a1,0
ffffffffc0200552:	4601                	li	a2,0
ffffffffc0200554:	953e                	add	a0,a0,a5
ffffffffc0200556:	4881                	li	a7,0
ffffffffc0200558:	00000073          	ecall
ffffffffc020055c:	8082                	ret

ffffffffc020055e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020055e:	8082                	ret

ffffffffc0200560 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200560:	100027f3          	csrr	a5,sstatus
ffffffffc0200564:	8b89                	andi	a5,a5,2
ffffffffc0200566:	0ff57513          	andi	a0,a0,255
ffffffffc020056a:	e799                	bnez	a5,ffffffffc0200578 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4885                	li	a7,1
ffffffffc0200572:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200576:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200578:	1101                	addi	sp,sp,-32
ffffffffc020057a:	ec06                	sd	ra,24(sp)
ffffffffc020057c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020057e:	05c000ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc0200582:	6522                	ld	a0,8(sp)
ffffffffc0200584:	4581                	li	a1,0
ffffffffc0200586:	4601                	li	a2,0
ffffffffc0200588:	4885                	li	a7,1
ffffffffc020058a:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020058e:	60e2                	ld	ra,24(sp)
ffffffffc0200590:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200592:	0420006f          	j	ffffffffc02005d4 <intr_enable>

ffffffffc0200596 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200596:	100027f3          	csrr	a5,sstatus
ffffffffc020059a:	8b89                	andi	a5,a5,2
ffffffffc020059c:	eb89                	bnez	a5,ffffffffc02005ae <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020059e:	4501                	li	a0,0
ffffffffc02005a0:	4581                	li	a1,0
ffffffffc02005a2:	4601                	li	a2,0
ffffffffc02005a4:	4889                	li	a7,2
ffffffffc02005a6:	00000073          	ecall
ffffffffc02005aa:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005ac:	8082                	ret
int cons_getc(void) {
ffffffffc02005ae:	1101                	addi	sp,sp,-32
ffffffffc02005b0:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005b2:	028000ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4889                	li	a7,2
ffffffffc02005be:	00000073          	ecall
ffffffffc02005c2:	2501                	sext.w	a0,a0
ffffffffc02005c4:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005c6:	00e000ef          	jal	ra,ffffffffc02005d4 <intr_enable>
}
ffffffffc02005ca:	60e2                	ld	ra,24(sp)
ffffffffc02005cc:	6522                	ld	a0,8(sp)
ffffffffc02005ce:	6105                	addi	sp,sp,32
ffffffffc02005d0:	8082                	ret

ffffffffc02005d2 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005d2:	8082                	ret

ffffffffc02005d4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005d8:	8082                	ret

ffffffffc02005da <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005da:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e0:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e4:	1141                	addi	sp,sp,-16
ffffffffc02005e6:	e022                	sd	s0,0(sp)
ffffffffc02005e8:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ea:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ee:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005f0:	11053583          	ld	a1,272(a0)
ffffffffc02005f4:	05500613          	li	a2,85
ffffffffc02005f8:	c399                	beqz	a5,ffffffffc02005fe <pgfault_handler+0x1e>
ffffffffc02005fa:	04b00613          	li	a2,75
ffffffffc02005fe:	11843703          	ld	a4,280(s0)
ffffffffc0200602:	47bd                	li	a5,15
ffffffffc0200604:	05700693          	li	a3,87
ffffffffc0200608:	00f70463          	beq	a4,a5,ffffffffc0200610 <pgfault_handler+0x30>
ffffffffc020060c:	05200693          	li	a3,82
ffffffffc0200610:	00005517          	auipc	a0,0x5
ffffffffc0200614:	13050513          	addi	a0,a0,304 # ffffffffc0205740 <commands+0x4e8>
ffffffffc0200618:	ab9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020061c:	00016797          	auipc	a5,0x16
ffffffffc0200620:	ee478793          	addi	a5,a5,-284 # ffffffffc0216500 <check_mm_struct>
ffffffffc0200624:	6388                	ld	a0,0(a5)
ffffffffc0200626:	c911                	beqz	a0,ffffffffc020063a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200628:	11043603          	ld	a2,272(s0)
ffffffffc020062c:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200630:	6402                	ld	s0,0(sp)
ffffffffc0200632:	60a2                	ld	ra,8(sp)
ffffffffc0200634:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200636:	55d0106f          	j	ffffffffc0202392 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020063a:	00005617          	auipc	a2,0x5
ffffffffc020063e:	12660613          	addi	a2,a2,294 # ffffffffc0205760 <commands+0x508>
ffffffffc0200642:	06500593          	li	a1,101
ffffffffc0200646:	00005517          	auipc	a0,0x5
ffffffffc020064a:	13250513          	addi	a0,a0,306 # ffffffffc0205778 <commands+0x520>
ffffffffc020064e:	b89ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200652 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200652:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200656:	00000797          	auipc	a5,0x0
ffffffffc020065a:	4ee78793          	addi	a5,a5,1262 # ffffffffc0200b44 <__alltraps>
ffffffffc020065e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200662:	000407b7          	lui	a5,0x40
ffffffffc0200666:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020066a:	8082                	ret

ffffffffc020066c <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020066e:	1141                	addi	sp,sp,-16
ffffffffc0200670:	e022                	sd	s0,0(sp)
ffffffffc0200672:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	00005517          	auipc	a0,0x5
ffffffffc0200678:	11c50513          	addi	a0,a0,284 # ffffffffc0205790 <commands+0x538>
void print_regs(struct pushregs *gpr) {
ffffffffc020067c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067e:	a53ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200682:	640c                	ld	a1,8(s0)
ffffffffc0200684:	00005517          	auipc	a0,0x5
ffffffffc0200688:	12450513          	addi	a0,a0,292 # ffffffffc02057a8 <commands+0x550>
ffffffffc020068c:	a45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200690:	680c                	ld	a1,16(s0)
ffffffffc0200692:	00005517          	auipc	a0,0x5
ffffffffc0200696:	12e50513          	addi	a0,a0,302 # ffffffffc02057c0 <commands+0x568>
ffffffffc020069a:	a37ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069e:	6c0c                	ld	a1,24(s0)
ffffffffc02006a0:	00005517          	auipc	a0,0x5
ffffffffc02006a4:	13850513          	addi	a0,a0,312 # ffffffffc02057d8 <commands+0x580>
ffffffffc02006a8:	a29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006ac:	700c                	ld	a1,32(s0)
ffffffffc02006ae:	00005517          	auipc	a0,0x5
ffffffffc02006b2:	14250513          	addi	a0,a0,322 # ffffffffc02057f0 <commands+0x598>
ffffffffc02006b6:	a1bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ba:	740c                	ld	a1,40(s0)
ffffffffc02006bc:	00005517          	auipc	a0,0x5
ffffffffc02006c0:	14c50513          	addi	a0,a0,332 # ffffffffc0205808 <commands+0x5b0>
ffffffffc02006c4:	a0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c8:	780c                	ld	a1,48(s0)
ffffffffc02006ca:	00005517          	auipc	a0,0x5
ffffffffc02006ce:	15650513          	addi	a0,a0,342 # ffffffffc0205820 <commands+0x5c8>
ffffffffc02006d2:	9ffff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d6:	7c0c                	ld	a1,56(s0)
ffffffffc02006d8:	00005517          	auipc	a0,0x5
ffffffffc02006dc:	16050513          	addi	a0,a0,352 # ffffffffc0205838 <commands+0x5e0>
ffffffffc02006e0:	9f1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e4:	602c                	ld	a1,64(s0)
ffffffffc02006e6:	00005517          	auipc	a0,0x5
ffffffffc02006ea:	16a50513          	addi	a0,a0,362 # ffffffffc0205850 <commands+0x5f8>
ffffffffc02006ee:	9e3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006f2:	642c                	ld	a1,72(s0)
ffffffffc02006f4:	00005517          	auipc	a0,0x5
ffffffffc02006f8:	17450513          	addi	a0,a0,372 # ffffffffc0205868 <commands+0x610>
ffffffffc02006fc:	9d5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200700:	682c                	ld	a1,80(s0)
ffffffffc0200702:	00005517          	auipc	a0,0x5
ffffffffc0200706:	17e50513          	addi	a0,a0,382 # ffffffffc0205880 <commands+0x628>
ffffffffc020070a:	9c7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070e:	6c2c                	ld	a1,88(s0)
ffffffffc0200710:	00005517          	auipc	a0,0x5
ffffffffc0200714:	18850513          	addi	a0,a0,392 # ffffffffc0205898 <commands+0x640>
ffffffffc0200718:	9b9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020071c:	702c                	ld	a1,96(s0)
ffffffffc020071e:	00005517          	auipc	a0,0x5
ffffffffc0200722:	19250513          	addi	a0,a0,402 # ffffffffc02058b0 <commands+0x658>
ffffffffc0200726:	9abff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020072a:	742c                	ld	a1,104(s0)
ffffffffc020072c:	00005517          	auipc	a0,0x5
ffffffffc0200730:	19c50513          	addi	a0,a0,412 # ffffffffc02058c8 <commands+0x670>
ffffffffc0200734:	99dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200738:	782c                	ld	a1,112(s0)
ffffffffc020073a:	00005517          	auipc	a0,0x5
ffffffffc020073e:	1a650513          	addi	a0,a0,422 # ffffffffc02058e0 <commands+0x688>
ffffffffc0200742:	98fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200746:	7c2c                	ld	a1,120(s0)
ffffffffc0200748:	00005517          	auipc	a0,0x5
ffffffffc020074c:	1b050513          	addi	a0,a0,432 # ffffffffc02058f8 <commands+0x6a0>
ffffffffc0200750:	981ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200754:	604c                	ld	a1,128(s0)
ffffffffc0200756:	00005517          	auipc	a0,0x5
ffffffffc020075a:	1ba50513          	addi	a0,a0,442 # ffffffffc0205910 <commands+0x6b8>
ffffffffc020075e:	973ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200762:	644c                	ld	a1,136(s0)
ffffffffc0200764:	00005517          	auipc	a0,0x5
ffffffffc0200768:	1c450513          	addi	a0,a0,452 # ffffffffc0205928 <commands+0x6d0>
ffffffffc020076c:	965ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200770:	684c                	ld	a1,144(s0)
ffffffffc0200772:	00005517          	auipc	a0,0x5
ffffffffc0200776:	1ce50513          	addi	a0,a0,462 # ffffffffc0205940 <commands+0x6e8>
ffffffffc020077a:	957ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077e:	6c4c                	ld	a1,152(s0)
ffffffffc0200780:	00005517          	auipc	a0,0x5
ffffffffc0200784:	1d850513          	addi	a0,a0,472 # ffffffffc0205958 <commands+0x700>
ffffffffc0200788:	949ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020078c:	704c                	ld	a1,160(s0)
ffffffffc020078e:	00005517          	auipc	a0,0x5
ffffffffc0200792:	1e250513          	addi	a0,a0,482 # ffffffffc0205970 <commands+0x718>
ffffffffc0200796:	93bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020079a:	744c                	ld	a1,168(s0)
ffffffffc020079c:	00005517          	auipc	a0,0x5
ffffffffc02007a0:	1ec50513          	addi	a0,a0,492 # ffffffffc0205988 <commands+0x730>
ffffffffc02007a4:	92dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a8:	784c                	ld	a1,176(s0)
ffffffffc02007aa:	00005517          	auipc	a0,0x5
ffffffffc02007ae:	1f650513          	addi	a0,a0,502 # ffffffffc02059a0 <commands+0x748>
ffffffffc02007b2:	91fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b6:	7c4c                	ld	a1,184(s0)
ffffffffc02007b8:	00005517          	auipc	a0,0x5
ffffffffc02007bc:	20050513          	addi	a0,a0,512 # ffffffffc02059b8 <commands+0x760>
ffffffffc02007c0:	911ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c4:	606c                	ld	a1,192(s0)
ffffffffc02007c6:	00005517          	auipc	a0,0x5
ffffffffc02007ca:	20a50513          	addi	a0,a0,522 # ffffffffc02059d0 <commands+0x778>
ffffffffc02007ce:	903ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007d2:	646c                	ld	a1,200(s0)
ffffffffc02007d4:	00005517          	auipc	a0,0x5
ffffffffc02007d8:	21450513          	addi	a0,a0,532 # ffffffffc02059e8 <commands+0x790>
ffffffffc02007dc:	8f5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e0:	686c                	ld	a1,208(s0)
ffffffffc02007e2:	00005517          	auipc	a0,0x5
ffffffffc02007e6:	21e50513          	addi	a0,a0,542 # ffffffffc0205a00 <commands+0x7a8>
ffffffffc02007ea:	8e7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ee:	6c6c                	ld	a1,216(s0)
ffffffffc02007f0:	00005517          	auipc	a0,0x5
ffffffffc02007f4:	22850513          	addi	a0,a0,552 # ffffffffc0205a18 <commands+0x7c0>
ffffffffc02007f8:	8d9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007fc:	706c                	ld	a1,224(s0)
ffffffffc02007fe:	00005517          	auipc	a0,0x5
ffffffffc0200802:	23250513          	addi	a0,a0,562 # ffffffffc0205a30 <commands+0x7d8>
ffffffffc0200806:	8cbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020080a:	746c                	ld	a1,232(s0)
ffffffffc020080c:	00005517          	auipc	a0,0x5
ffffffffc0200810:	23c50513          	addi	a0,a0,572 # ffffffffc0205a48 <commands+0x7f0>
ffffffffc0200814:	8bdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200818:	786c                	ld	a1,240(s0)
ffffffffc020081a:	00005517          	auipc	a0,0x5
ffffffffc020081e:	24650513          	addi	a0,a0,582 # ffffffffc0205a60 <commands+0x808>
ffffffffc0200822:	8afff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200826:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200828:	6402                	ld	s0,0(sp)
ffffffffc020082a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	00005517          	auipc	a0,0x5
ffffffffc0200830:	24c50513          	addi	a0,a0,588 # ffffffffc0205a78 <commands+0x820>
}
ffffffffc0200834:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	89bff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020083a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	1141                	addi	sp,sp,-16
ffffffffc020083c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	00005517          	auipc	a0,0x5
ffffffffc0200846:	24e50513          	addi	a0,a0,590 # ffffffffc0205a90 <commands+0x838>
void print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084c:	885ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200850:	8522                	mv	a0,s0
ffffffffc0200852:	e1bff0ef          	jal	ra,ffffffffc020066c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200856:	10043583          	ld	a1,256(s0)
ffffffffc020085a:	00005517          	auipc	a0,0x5
ffffffffc020085e:	24e50513          	addi	a0,a0,590 # ffffffffc0205aa8 <commands+0x850>
ffffffffc0200862:	86fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200866:	10843583          	ld	a1,264(s0)
ffffffffc020086a:	00005517          	auipc	a0,0x5
ffffffffc020086e:	25650513          	addi	a0,a0,598 # ffffffffc0205ac0 <commands+0x868>
ffffffffc0200872:	85fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200876:	11043583          	ld	a1,272(s0)
ffffffffc020087a:	00005517          	auipc	a0,0x5
ffffffffc020087e:	25e50513          	addi	a0,a0,606 # ffffffffc0205ad8 <commands+0x880>
ffffffffc0200882:	84fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200886:	11843583          	ld	a1,280(s0)
}
ffffffffc020088a:	6402                	ld	s0,0(sp)
ffffffffc020088c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	00005517          	auipc	a0,0x5
ffffffffc0200892:	26250513          	addi	a0,a0,610 # ffffffffc0205af0 <commands+0x898>
}
ffffffffc0200896:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200898:	839ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020089c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020089c:	11853783          	ld	a5,280(a0)
ffffffffc02008a0:	577d                	li	a4,-1
ffffffffc02008a2:	8305                	srli	a4,a4,0x1
ffffffffc02008a4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02008a6:	472d                	li	a4,11
ffffffffc02008a8:	06f76f63          	bltu	a4,a5,ffffffffc0200926 <interrupt_handler+0x8a>
ffffffffc02008ac:	00005717          	auipc	a4,0x5
ffffffffc02008b0:	b4870713          	addi	a4,a4,-1208 # ffffffffc02053f4 <commands+0x19c>
ffffffffc02008b4:	078a                	slli	a5,a5,0x2
ffffffffc02008b6:	97ba                	add	a5,a5,a4
ffffffffc02008b8:	439c                	lw	a5,0(a5)
ffffffffc02008ba:	97ba                	add	a5,a5,a4
ffffffffc02008bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	e3250513          	addi	a0,a0,-462 # ffffffffc02056f0 <commands+0x498>
ffffffffc02008c6:	80bff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	e0650513          	addi	a0,a0,-506 # ffffffffc02056d0 <commands+0x478>
ffffffffc02008d2:	ffeff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008d6:	00005517          	auipc	a0,0x5
ffffffffc02008da:	dba50513          	addi	a0,a0,-582 # ffffffffc0205690 <commands+0x438>
ffffffffc02008de:	ff2ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008e2:	00005517          	auipc	a0,0x5
ffffffffc02008e6:	dce50513          	addi	a0,a0,-562 # ffffffffc02056b0 <commands+0x458>
ffffffffc02008ea:	fe6ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008ee:	00005517          	auipc	a0,0x5
ffffffffc02008f2:	e3250513          	addi	a0,a0,-462 # ffffffffc0205720 <commands+0x4c8>
ffffffffc02008f6:	fdaff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008fa:	1141                	addi	sp,sp,-16
ffffffffc02008fc:	e406                	sd	ra,8(sp)
			clock_set_next_event();
ffffffffc02008fe:	c45ff0ef          	jal	ra,ffffffffc0200542 <clock_set_next_event>
			if(++ticks % TICK_NUM == 0){
ffffffffc0200902:	00016797          	auipc	a5,0x16
ffffffffc0200906:	bd678793          	addi	a5,a5,-1066 # ffffffffc02164d8 <ticks>
ffffffffc020090a:	639c                	ld	a5,0(a5)
ffffffffc020090c:	06400713          	li	a4,100
ffffffffc0200910:	0785                	addi	a5,a5,1
ffffffffc0200912:	02e7f733          	remu	a4,a5,a4
ffffffffc0200916:	00016697          	auipc	a3,0x16
ffffffffc020091a:	bcf6b123          	sd	a5,-1086(a3) # ffffffffc02164d8 <ticks>
ffffffffc020091e:	c711                	beqz	a4,ffffffffc020092a <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200920:	60a2                	ld	ra,8(sp)
ffffffffc0200922:	0141                	addi	sp,sp,16
ffffffffc0200924:	8082                	ret
            print_trapframe(tf);
ffffffffc0200926:	f15ff06f          	j	ffffffffc020083a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020092a:	06400593          	li	a1,100
ffffffffc020092e:	00005517          	auipc	a0,0x5
ffffffffc0200932:	de250513          	addi	a0,a0,-542 # ffffffffc0205710 <commands+0x4b8>
ffffffffc0200936:	f9aff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
				if(++num==10){
ffffffffc020093a:	00016797          	auipc	a5,0x16
ffffffffc020093e:	b4678793          	addi	a5,a5,-1210 # ffffffffc0216480 <num>
ffffffffc0200942:	639c                	ld	a5,0(a5)
ffffffffc0200944:	4729                	li	a4,10
ffffffffc0200946:	0785                	addi	a5,a5,1
ffffffffc0200948:	00016697          	auipc	a3,0x16
ffffffffc020094c:	b2f6bc23          	sd	a5,-1224(a3) # ffffffffc0216480 <num>
ffffffffc0200950:	fce798e3          	bne	a5,a4,ffffffffc0200920 <interrupt_handler+0x84>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200954:	4501                	li	a0,0
ffffffffc0200956:	4581                	li	a1,0
ffffffffc0200958:	4601                	li	a2,0
ffffffffc020095a:	48a1                	li	a7,8
ffffffffc020095c:	00000073          	ecall
ffffffffc0200960:	b7c1                	j	ffffffffc0200920 <interrupt_handler+0x84>

ffffffffc0200962 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200962:	11853783          	ld	a5,280(a0)
ffffffffc0200966:	473d                	li	a4,15
ffffffffc0200968:	1af76463          	bltu	a4,a5,ffffffffc0200b10 <exception_handler+0x1ae>
ffffffffc020096c:	00005717          	auipc	a4,0x5
ffffffffc0200970:	ab870713          	addi	a4,a4,-1352 # ffffffffc0205424 <commands+0x1cc>
ffffffffc0200974:	078a                	slli	a5,a5,0x2
ffffffffc0200976:	97ba                	add	a5,a5,a4
ffffffffc0200978:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020097a:	1101                	addi	sp,sp,-32
ffffffffc020097c:	e822                	sd	s0,16(sp)
ffffffffc020097e:	ec06                	sd	ra,24(sp)
ffffffffc0200980:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200982:	97ba                	add	a5,a5,a4
ffffffffc0200984:	842a                	mv	s0,a0
ffffffffc0200986:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200988:	00005517          	auipc	a0,0x5
ffffffffc020098c:	cf050513          	addi	a0,a0,-784 # ffffffffc0205678 <commands+0x420>
ffffffffc0200990:	f40ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200994:	8522                	mv	a0,s0
ffffffffc0200996:	c4bff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc020099a:	84aa                	mv	s1,a0
ffffffffc020099c:	16051c63          	bnez	a0,ffffffffc0200b14 <exception_handler+0x1b2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02009a0:	60e2                	ld	ra,24(sp)
ffffffffc02009a2:	6442                	ld	s0,16(sp)
ffffffffc02009a4:	64a2                	ld	s1,8(sp)
ffffffffc02009a6:	6105                	addi	sp,sp,32
ffffffffc02009a8:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02009aa:	00005517          	auipc	a0,0x5
ffffffffc02009ae:	abe50513          	addi	a0,a0,-1346 # ffffffffc0205468 <commands+0x210>
}
ffffffffc02009b2:	6442                	ld	s0,16(sp)
ffffffffc02009b4:	60e2                	ld	ra,24(sp)
ffffffffc02009b6:	64a2                	ld	s1,8(sp)
ffffffffc02009b8:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02009ba:	f16ff06f          	j	ffffffffc02000d0 <cprintf>
ffffffffc02009be:	00005517          	auipc	a0,0x5
ffffffffc02009c2:	aca50513          	addi	a0,a0,-1334 # ffffffffc0205488 <commands+0x230>
ffffffffc02009c6:	b7f5                	j	ffffffffc02009b2 <exception_handler+0x50>
			cprintf("Exception Type: Illegal instruction\n");
ffffffffc02009c8:	00005517          	auipc	a0,0x5
ffffffffc02009cc:	ae050513          	addi	a0,a0,-1312 # ffffffffc02054a8 <commands+0x250>
ffffffffc02009d0:	f00ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
			cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
ffffffffc02009d4:	10843583          	ld	a1,264(s0)
ffffffffc02009d8:	00005517          	auipc	a0,0x5
ffffffffc02009dc:	af850513          	addi	a0,a0,-1288 # ffffffffc02054d0 <commands+0x278>
ffffffffc02009e0:	ef0ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
			tf->epc += 2;
ffffffffc02009e4:	10843783          	ld	a5,264(s0)
ffffffffc02009e8:	0789                	addi	a5,a5,2
ffffffffc02009ea:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc02009ee:	bf4d                	j	ffffffffc02009a0 <exception_handler+0x3e>
			cprintf("Exception Type: breakpoint\n");
ffffffffc02009f0:	00005517          	auipc	a0,0x5
ffffffffc02009f4:	b1050513          	addi	a0,a0,-1264 # ffffffffc0205500 <commands+0x2a8>
ffffffffc02009f8:	ed8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
			cprintf("ebreak caught at 0x%016llx\n", tf->epc);
ffffffffc02009fc:	10843583          	ld	a1,264(s0)
ffffffffc0200a00:	00005517          	auipc	a0,0x5
ffffffffc0200a04:	b2050513          	addi	a0,a0,-1248 # ffffffffc0205520 <commands+0x2c8>
ffffffffc0200a08:	ec8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
			tf->epc += 2;
ffffffffc0200a0c:	10843783          	ld	a5,264(s0)
ffffffffc0200a10:	0789                	addi	a5,a5,2
ffffffffc0200a12:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200a16:	b769                	j	ffffffffc02009a0 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	b2850513          	addi	a0,a0,-1240 # ffffffffc0205540 <commands+0x2e8>
ffffffffc0200a20:	bf49                	j	ffffffffc02009b2 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200a22:	00005517          	auipc	a0,0x5
ffffffffc0200a26:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0205560 <commands+0x308>
ffffffffc0200a2a:	ea6ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a2e:	8522                	mv	a0,s0
ffffffffc0200a30:	bb1ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a34:	84aa                	mv	s1,a0
ffffffffc0200a36:	d52d                	beqz	a0,ffffffffc02009a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a38:	8522                	mv	a0,s0
ffffffffc0200a3a:	e01ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a3e:	86a6                	mv	a3,s1
ffffffffc0200a40:	00005617          	auipc	a2,0x5
ffffffffc0200a44:	b3860613          	addi	a2,a2,-1224 # ffffffffc0205578 <commands+0x320>
ffffffffc0200a48:	0d400593          	li	a1,212
ffffffffc0200a4c:	00005517          	auipc	a0,0x5
ffffffffc0200a50:	d2c50513          	addi	a0,a0,-724 # ffffffffc0205778 <commands+0x520>
ffffffffc0200a54:	f82ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200a58:	00005517          	auipc	a0,0x5
ffffffffc0200a5c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0205598 <commands+0x340>
ffffffffc0200a60:	bf89                	j	ffffffffc02009b2 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200a62:	00005517          	auipc	a0,0x5
ffffffffc0200a66:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02055b0 <commands+0x358>
ffffffffc0200a6a:	e66ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a6e:	8522                	mv	a0,s0
ffffffffc0200a70:	b71ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a74:	84aa                	mv	s1,a0
ffffffffc0200a76:	f20505e3          	beqz	a0,ffffffffc02009a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a7a:	8522                	mv	a0,s0
ffffffffc0200a7c:	dbfff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a80:	86a6                	mv	a3,s1
ffffffffc0200a82:	00005617          	auipc	a2,0x5
ffffffffc0200a86:	af660613          	addi	a2,a2,-1290 # ffffffffc0205578 <commands+0x320>
ffffffffc0200a8a:	0de00593          	li	a1,222
ffffffffc0200a8e:	00005517          	auipc	a0,0x5
ffffffffc0200a92:	cea50513          	addi	a0,a0,-790 # ffffffffc0205778 <commands+0x520>
ffffffffc0200a96:	f40ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a9a:	00005517          	auipc	a0,0x5
ffffffffc0200a9e:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02055c8 <commands+0x370>
ffffffffc0200aa2:	bf01                	j	ffffffffc02009b2 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200aa4:	00005517          	auipc	a0,0x5
ffffffffc0200aa8:	b4450513          	addi	a0,a0,-1212 # ffffffffc02055e8 <commands+0x390>
ffffffffc0200aac:	b719                	j	ffffffffc02009b2 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aae:	00005517          	auipc	a0,0x5
ffffffffc0200ab2:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0205608 <commands+0x3b0>
ffffffffc0200ab6:	bdf5                	j	ffffffffc02009b2 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ab8:	00005517          	auipc	a0,0x5
ffffffffc0200abc:	b7050513          	addi	a0,a0,-1168 # ffffffffc0205628 <commands+0x3d0>
ffffffffc0200ac0:	bdcd                	j	ffffffffc02009b2 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ac2:	00005517          	auipc	a0,0x5
ffffffffc0200ac6:	b8650513          	addi	a0,a0,-1146 # ffffffffc0205648 <commands+0x3f0>
ffffffffc0200aca:	b5e5                	j	ffffffffc02009b2 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200acc:	00005517          	auipc	a0,0x5
ffffffffc0200ad0:	b9450513          	addi	a0,a0,-1132 # ffffffffc0205660 <commands+0x408>
ffffffffc0200ad4:	dfcff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad8:	8522                	mv	a0,s0
ffffffffc0200ada:	b07ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200ade:	84aa                	mv	s1,a0
ffffffffc0200ae0:	ec0500e3          	beqz	a0,ffffffffc02009a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200ae4:	8522                	mv	a0,s0
ffffffffc0200ae6:	d55ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200aea:	86a6                	mv	a3,s1
ffffffffc0200aec:	00005617          	auipc	a2,0x5
ffffffffc0200af0:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0205578 <commands+0x320>
ffffffffc0200af4:	0f400593          	li	a1,244
ffffffffc0200af8:	00005517          	auipc	a0,0x5
ffffffffc0200afc:	c8050513          	addi	a0,a0,-896 # ffffffffc0205778 <commands+0x520>
ffffffffc0200b00:	ed6ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
}
ffffffffc0200b04:	6442                	ld	s0,16(sp)
ffffffffc0200b06:	60e2                	ld	ra,24(sp)
ffffffffc0200b08:	64a2                	ld	s1,8(sp)
ffffffffc0200b0a:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200b0c:	d2fff06f          	j	ffffffffc020083a <print_trapframe>
ffffffffc0200b10:	d2bff06f          	j	ffffffffc020083a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200b14:	8522                	mv	a0,s0
ffffffffc0200b16:	d25ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b1a:	86a6                	mv	a3,s1
ffffffffc0200b1c:	00005617          	auipc	a2,0x5
ffffffffc0200b20:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0205578 <commands+0x320>
ffffffffc0200b24:	0fb00593          	li	a1,251
ffffffffc0200b28:	00005517          	auipc	a0,0x5
ffffffffc0200b2c:	c5050513          	addi	a0,a0,-944 # ffffffffc0205778 <commands+0x520>
ffffffffc0200b30:	ea6ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200b34 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200b34:	11853783          	ld	a5,280(a0)
ffffffffc0200b38:	0007c463          	bltz	a5,ffffffffc0200b40 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200b3c:	e27ff06f          	j	ffffffffc0200962 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200b40:	d5dff06f          	j	ffffffffc020089c <interrupt_handler>

ffffffffc0200b44 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200b44:	14011073          	csrw	sscratch,sp
ffffffffc0200b48:	712d                	addi	sp,sp,-288
ffffffffc0200b4a:	e406                	sd	ra,8(sp)
ffffffffc0200b4c:	ec0e                	sd	gp,24(sp)
ffffffffc0200b4e:	f012                	sd	tp,32(sp)
ffffffffc0200b50:	f416                	sd	t0,40(sp)
ffffffffc0200b52:	f81a                	sd	t1,48(sp)
ffffffffc0200b54:	fc1e                	sd	t2,56(sp)
ffffffffc0200b56:	e0a2                	sd	s0,64(sp)
ffffffffc0200b58:	e4a6                	sd	s1,72(sp)
ffffffffc0200b5a:	e8aa                	sd	a0,80(sp)
ffffffffc0200b5c:	ecae                	sd	a1,88(sp)
ffffffffc0200b5e:	f0b2                	sd	a2,96(sp)
ffffffffc0200b60:	f4b6                	sd	a3,104(sp)
ffffffffc0200b62:	f8ba                	sd	a4,112(sp)
ffffffffc0200b64:	fcbe                	sd	a5,120(sp)
ffffffffc0200b66:	e142                	sd	a6,128(sp)
ffffffffc0200b68:	e546                	sd	a7,136(sp)
ffffffffc0200b6a:	e94a                	sd	s2,144(sp)
ffffffffc0200b6c:	ed4e                	sd	s3,152(sp)
ffffffffc0200b6e:	f152                	sd	s4,160(sp)
ffffffffc0200b70:	f556                	sd	s5,168(sp)
ffffffffc0200b72:	f95a                	sd	s6,176(sp)
ffffffffc0200b74:	fd5e                	sd	s7,184(sp)
ffffffffc0200b76:	e1e2                	sd	s8,192(sp)
ffffffffc0200b78:	e5e6                	sd	s9,200(sp)
ffffffffc0200b7a:	e9ea                	sd	s10,208(sp)
ffffffffc0200b7c:	edee                	sd	s11,216(sp)
ffffffffc0200b7e:	f1f2                	sd	t3,224(sp)
ffffffffc0200b80:	f5f6                	sd	t4,232(sp)
ffffffffc0200b82:	f9fa                	sd	t5,240(sp)
ffffffffc0200b84:	fdfe                	sd	t6,248(sp)
ffffffffc0200b86:	14002473          	csrr	s0,sscratch
ffffffffc0200b8a:	100024f3          	csrr	s1,sstatus
ffffffffc0200b8e:	14102973          	csrr	s2,sepc
ffffffffc0200b92:	143029f3          	csrr	s3,stval
ffffffffc0200b96:	14202a73          	csrr	s4,scause
ffffffffc0200b9a:	e822                	sd	s0,16(sp)
ffffffffc0200b9c:	e226                	sd	s1,256(sp)
ffffffffc0200b9e:	e64a                	sd	s2,264(sp)
ffffffffc0200ba0:	ea4e                	sd	s3,272(sp)
ffffffffc0200ba2:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ba4:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ba6:	f8fff0ef          	jal	ra,ffffffffc0200b34 <trap>

ffffffffc0200baa <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200baa:	6492                	ld	s1,256(sp)
ffffffffc0200bac:	6932                	ld	s2,264(sp)
ffffffffc0200bae:	10049073          	csrw	sstatus,s1
ffffffffc0200bb2:	14191073          	csrw	sepc,s2
ffffffffc0200bb6:	60a2                	ld	ra,8(sp)
ffffffffc0200bb8:	61e2                	ld	gp,24(sp)
ffffffffc0200bba:	7202                	ld	tp,32(sp)
ffffffffc0200bbc:	72a2                	ld	t0,40(sp)
ffffffffc0200bbe:	7342                	ld	t1,48(sp)
ffffffffc0200bc0:	73e2                	ld	t2,56(sp)
ffffffffc0200bc2:	6406                	ld	s0,64(sp)
ffffffffc0200bc4:	64a6                	ld	s1,72(sp)
ffffffffc0200bc6:	6546                	ld	a0,80(sp)
ffffffffc0200bc8:	65e6                	ld	a1,88(sp)
ffffffffc0200bca:	7606                	ld	a2,96(sp)
ffffffffc0200bcc:	76a6                	ld	a3,104(sp)
ffffffffc0200bce:	7746                	ld	a4,112(sp)
ffffffffc0200bd0:	77e6                	ld	a5,120(sp)
ffffffffc0200bd2:	680a                	ld	a6,128(sp)
ffffffffc0200bd4:	68aa                	ld	a7,136(sp)
ffffffffc0200bd6:	694a                	ld	s2,144(sp)
ffffffffc0200bd8:	69ea                	ld	s3,152(sp)
ffffffffc0200bda:	7a0a                	ld	s4,160(sp)
ffffffffc0200bdc:	7aaa                	ld	s5,168(sp)
ffffffffc0200bde:	7b4a                	ld	s6,176(sp)
ffffffffc0200be0:	7bea                	ld	s7,184(sp)
ffffffffc0200be2:	6c0e                	ld	s8,192(sp)
ffffffffc0200be4:	6cae                	ld	s9,200(sp)
ffffffffc0200be6:	6d4e                	ld	s10,208(sp)
ffffffffc0200be8:	6dee                	ld	s11,216(sp)
ffffffffc0200bea:	7e0e                	ld	t3,224(sp)
ffffffffc0200bec:	7eae                	ld	t4,232(sp)
ffffffffc0200bee:	7f4e                	ld	t5,240(sp)
ffffffffc0200bf0:	7fee                	ld	t6,248(sp)
ffffffffc0200bf2:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200bf4:	10200073          	sret

ffffffffc0200bf8 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200bf8:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200bfa:	bf45                	j	ffffffffc0200baa <__trapret>
	...

ffffffffc0200bfe <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200bfe:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200c00:	00005617          	auipc	a2,0x5
ffffffffc0200c04:	f4860613          	addi	a2,a2,-184 # ffffffffc0205b48 <commands+0x8f0>
ffffffffc0200c08:	06200593          	li	a1,98
ffffffffc0200c0c:	00005517          	auipc	a0,0x5
ffffffffc0200c10:	f5c50513          	addi	a0,a0,-164 # ffffffffc0205b68 <commands+0x910>
pa2page(uintptr_t pa) {
ffffffffc0200c14:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200c16:	dc0ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200c1a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200c1a:	715d                	addi	sp,sp,-80
ffffffffc0200c1c:	e0a2                	sd	s0,64(sp)
ffffffffc0200c1e:	fc26                	sd	s1,56(sp)
ffffffffc0200c20:	f84a                	sd	s2,48(sp)
ffffffffc0200c22:	f44e                	sd	s3,40(sp)
ffffffffc0200c24:	f052                	sd	s4,32(sp)
ffffffffc0200c26:	ec56                	sd	s5,24(sp)
ffffffffc0200c28:	e486                	sd	ra,72(sp)
ffffffffc0200c2a:	842a                	mv	s0,a0
ffffffffc0200c2c:	00016497          	auipc	s1,0x16
ffffffffc0200c30:	8b448493          	addi	s1,s1,-1868 # ffffffffc02164e0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200c34:	4985                	li	s3,1
ffffffffc0200c36:	00016a17          	auipc	s4,0x16
ffffffffc0200c3a:	872a0a13          	addi	s4,s4,-1934 # ffffffffc02164a8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200c3e:	0005091b          	sext.w	s2,a0
ffffffffc0200c42:	00016a97          	auipc	s5,0x16
ffffffffc0200c46:	8bea8a93          	addi	s5,s5,-1858 # ffffffffc0216500 <check_mm_struct>
ffffffffc0200c4a:	a00d                	j	ffffffffc0200c6c <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200c4c:	609c                	ld	a5,0(s1)
ffffffffc0200c4e:	6f9c                	ld	a5,24(a5)
ffffffffc0200c50:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200c52:	4601                	li	a2,0
ffffffffc0200c54:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200c56:	ed0d                	bnez	a0,ffffffffc0200c90 <alloc_pages+0x76>
ffffffffc0200c58:	0289ec63          	bltu	s3,s0,ffffffffc0200c90 <alloc_pages+0x76>
ffffffffc0200c5c:	000a2783          	lw	a5,0(s4)
ffffffffc0200c60:	2781                	sext.w	a5,a5
ffffffffc0200c62:	c79d                	beqz	a5,ffffffffc0200c90 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200c64:	000ab503          	ld	a0,0(s5)
ffffffffc0200c68:	7cf010ef          	jal	ra,ffffffffc0202c36 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c6c:	100027f3          	csrr	a5,sstatus
ffffffffc0200c70:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200c72:	8522                	mv	a0,s0
ffffffffc0200c74:	dfe1                	beqz	a5,ffffffffc0200c4c <alloc_pages+0x32>
        intr_disable();
ffffffffc0200c76:	965ff0ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc0200c7a:	609c                	ld	a5,0(s1)
ffffffffc0200c7c:	8522                	mv	a0,s0
ffffffffc0200c7e:	6f9c                	ld	a5,24(a5)
ffffffffc0200c80:	9782                	jalr	a5
ffffffffc0200c82:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200c84:	951ff0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
ffffffffc0200c88:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200c8a:	4601                	li	a2,0
ffffffffc0200c8c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200c8e:	d569                	beqz	a0,ffffffffc0200c58 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200c90:	60a6                	ld	ra,72(sp)
ffffffffc0200c92:	6406                	ld	s0,64(sp)
ffffffffc0200c94:	74e2                	ld	s1,56(sp)
ffffffffc0200c96:	7942                	ld	s2,48(sp)
ffffffffc0200c98:	79a2                	ld	s3,40(sp)
ffffffffc0200c9a:	7a02                	ld	s4,32(sp)
ffffffffc0200c9c:	6ae2                	ld	s5,24(sp)
ffffffffc0200c9e:	6161                	addi	sp,sp,80
ffffffffc0200ca0:	8082                	ret

ffffffffc0200ca2 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ca2:	100027f3          	csrr	a5,sstatus
ffffffffc0200ca6:	8b89                	andi	a5,a5,2
ffffffffc0200ca8:	eb89                	bnez	a5,ffffffffc0200cba <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200caa:	00016797          	auipc	a5,0x16
ffffffffc0200cae:	83678793          	addi	a5,a5,-1994 # ffffffffc02164e0 <pmm_manager>
ffffffffc0200cb2:	639c                	ld	a5,0(a5)
ffffffffc0200cb4:	0207b303          	ld	t1,32(a5)
ffffffffc0200cb8:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200cba:	1101                	addi	sp,sp,-32
ffffffffc0200cbc:	ec06                	sd	ra,24(sp)
ffffffffc0200cbe:	e822                	sd	s0,16(sp)
ffffffffc0200cc0:	e426                	sd	s1,8(sp)
ffffffffc0200cc2:	842a                	mv	s0,a0
ffffffffc0200cc4:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200cc6:	915ff0ef          	jal	ra,ffffffffc02005da <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200cca:	00016797          	auipc	a5,0x16
ffffffffc0200cce:	81678793          	addi	a5,a5,-2026 # ffffffffc02164e0 <pmm_manager>
ffffffffc0200cd2:	639c                	ld	a5,0(a5)
ffffffffc0200cd4:	85a6                	mv	a1,s1
ffffffffc0200cd6:	8522                	mv	a0,s0
ffffffffc0200cd8:	739c                	ld	a5,32(a5)
ffffffffc0200cda:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200cdc:	6442                	ld	s0,16(sp)
ffffffffc0200cde:	60e2                	ld	ra,24(sp)
ffffffffc0200ce0:	64a2                	ld	s1,8(sp)
ffffffffc0200ce2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200ce4:	8f1ff06f          	j	ffffffffc02005d4 <intr_enable>

ffffffffc0200ce8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ce8:	100027f3          	csrr	a5,sstatus
ffffffffc0200cec:	8b89                	andi	a5,a5,2
ffffffffc0200cee:	eb89                	bnez	a5,ffffffffc0200d00 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200cf0:	00015797          	auipc	a5,0x15
ffffffffc0200cf4:	7f078793          	addi	a5,a5,2032 # ffffffffc02164e0 <pmm_manager>
ffffffffc0200cf8:	639c                	ld	a5,0(a5)
ffffffffc0200cfa:	0287b303          	ld	t1,40(a5)
ffffffffc0200cfe:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200d00:	1141                	addi	sp,sp,-16
ffffffffc0200d02:	e406                	sd	ra,8(sp)
ffffffffc0200d04:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200d06:	8d5ff0ef          	jal	ra,ffffffffc02005da <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200d0a:	00015797          	auipc	a5,0x15
ffffffffc0200d0e:	7d678793          	addi	a5,a5,2006 # ffffffffc02164e0 <pmm_manager>
ffffffffc0200d12:	639c                	ld	a5,0(a5)
ffffffffc0200d14:	779c                	ld	a5,40(a5)
ffffffffc0200d16:	9782                	jalr	a5
ffffffffc0200d18:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200d1a:	8bbff0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200d1e:	8522                	mv	a0,s0
ffffffffc0200d20:	60a2                	ld	ra,8(sp)
ffffffffc0200d22:	6402                	ld	s0,0(sp)
ffffffffc0200d24:	0141                	addi	sp,sp,16
ffffffffc0200d26:	8082                	ret

ffffffffc0200d28 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200d28:	715d                	addi	sp,sp,-80
ffffffffc0200d2a:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200d2c:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200d30:	1ff4f493          	andi	s1,s1,511
ffffffffc0200d34:	048e                	slli	s1,s1,0x3
ffffffffc0200d36:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200d38:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200d3a:	f84a                	sd	s2,48(sp)
ffffffffc0200d3c:	f44e                	sd	s3,40(sp)
ffffffffc0200d3e:	f052                	sd	s4,32(sp)
ffffffffc0200d40:	e486                	sd	ra,72(sp)
ffffffffc0200d42:	e0a2                	sd	s0,64(sp)
ffffffffc0200d44:	ec56                	sd	s5,24(sp)
ffffffffc0200d46:	e85a                	sd	s6,16(sp)
ffffffffc0200d48:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200d4a:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200d4e:	892e                	mv	s2,a1
ffffffffc0200d50:	8a32                	mv	s4,a2
ffffffffc0200d52:	00015997          	auipc	s3,0x15
ffffffffc0200d56:	73e98993          	addi	s3,s3,1854 # ffffffffc0216490 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200d5a:	e3c9                	bnez	a5,ffffffffc0200ddc <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200d5c:	16060163          	beqz	a2,ffffffffc0200ebe <get_pte+0x196>
ffffffffc0200d60:	4505                	li	a0,1
ffffffffc0200d62:	eb9ff0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc0200d66:	842a                	mv	s0,a0
ffffffffc0200d68:	14050b63          	beqz	a0,ffffffffc0200ebe <get_pte+0x196>
    return page - pages + nbase;
ffffffffc0200d6c:	00015b97          	auipc	s7,0x15
ffffffffc0200d70:	78cb8b93          	addi	s7,s7,1932 # ffffffffc02164f8 <pages>
ffffffffc0200d74:	000bb503          	ld	a0,0(s7)
ffffffffc0200d78:	00005797          	auipc	a5,0x5
ffffffffc0200d7c:	d9078793          	addi	a5,a5,-624 # ffffffffc0205b08 <commands+0x8b0>
ffffffffc0200d80:	0007bb03          	ld	s6,0(a5)
ffffffffc0200d84:	40a40533          	sub	a0,s0,a0
ffffffffc0200d88:	850d                	srai	a0,a0,0x3
ffffffffc0200d8a:	03650533          	mul	a0,a0,s6
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200d8e:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d90:	00015997          	auipc	s3,0x15
ffffffffc0200d94:	70098993          	addi	s3,s3,1792 # ffffffffc0216490 <npage>
    return page - pages + nbase;
ffffffffc0200d98:	00080ab7          	lui	s5,0x80
ffffffffc0200d9c:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0200da0:	c01c                	sw	a5,0(s0)
ffffffffc0200da2:	57fd                	li	a5,-1
ffffffffc0200da4:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc0200da6:	9556                	add	a0,a0,s5
ffffffffc0200da8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200daa:	0532                	slli	a0,a0,0xc
ffffffffc0200dac:	16e7f063          	bleu	a4,a5,ffffffffc0200f0c <get_pte+0x1e4>
ffffffffc0200db0:	00015797          	auipc	a5,0x15
ffffffffc0200db4:	73878793          	addi	a5,a5,1848 # ffffffffc02164e8 <va_pa_offset>
ffffffffc0200db8:	639c                	ld	a5,0(a5)
ffffffffc0200dba:	6605                	lui	a2,0x1
ffffffffc0200dbc:	4581                	li	a1,0
ffffffffc0200dbe:	953e                	add	a0,a0,a5
ffffffffc0200dc0:	6df030ef          	jal	ra,ffffffffc0204c9e <memset>
    return page - pages + nbase;
ffffffffc0200dc4:	000bb683          	ld	a3,0(s7)
ffffffffc0200dc8:	40d406b3          	sub	a3,s0,a3
ffffffffc0200dcc:	868d                	srai	a3,a3,0x3
ffffffffc0200dce:	036686b3          	mul	a3,a3,s6
ffffffffc0200dd2:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200dd4:	06aa                	slli	a3,a3,0xa
ffffffffc0200dd6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200dda:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200ddc:	77fd                	lui	a5,0xfffff
ffffffffc0200dde:	068a                	slli	a3,a3,0x2
ffffffffc0200de0:	0009b703          	ld	a4,0(s3)
ffffffffc0200de4:	8efd                	and	a3,a3,a5
ffffffffc0200de6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200dea:	0ce7fc63          	bleu	a4,a5,ffffffffc0200ec2 <get_pte+0x19a>
ffffffffc0200dee:	00015a97          	auipc	s5,0x15
ffffffffc0200df2:	6faa8a93          	addi	s5,s5,1786 # ffffffffc02164e8 <va_pa_offset>
ffffffffc0200df6:	000ab403          	ld	s0,0(s5)
ffffffffc0200dfa:	01595793          	srli	a5,s2,0x15
ffffffffc0200dfe:	1ff7f793          	andi	a5,a5,511
ffffffffc0200e02:	96a2                	add	a3,a3,s0
ffffffffc0200e04:	00379413          	slli	s0,a5,0x3
ffffffffc0200e08:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200e0a:	6014                	ld	a3,0(s0)
ffffffffc0200e0c:	0016f793          	andi	a5,a3,1
ffffffffc0200e10:	ebbd                	bnez	a5,ffffffffc0200e86 <get_pte+0x15e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200e12:	0a0a0663          	beqz	s4,ffffffffc0200ebe <get_pte+0x196>
ffffffffc0200e16:	4505                	li	a0,1
ffffffffc0200e18:	e03ff0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc0200e1c:	84aa                	mv	s1,a0
ffffffffc0200e1e:	c145                	beqz	a0,ffffffffc0200ebe <get_pte+0x196>
    return page - pages + nbase;
ffffffffc0200e20:	00015b97          	auipc	s7,0x15
ffffffffc0200e24:	6d8b8b93          	addi	s7,s7,1752 # ffffffffc02164f8 <pages>
ffffffffc0200e28:	000bb503          	ld	a0,0(s7)
ffffffffc0200e2c:	00005797          	auipc	a5,0x5
ffffffffc0200e30:	cdc78793          	addi	a5,a5,-804 # ffffffffc0205b08 <commands+0x8b0>
ffffffffc0200e34:	0007bb03          	ld	s6,0(a5)
ffffffffc0200e38:	40a48533          	sub	a0,s1,a0
ffffffffc0200e3c:	850d                	srai	a0,a0,0x3
ffffffffc0200e3e:	03650533          	mul	a0,a0,s6
    page->ref = val;
ffffffffc0200e42:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0200e44:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e48:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0200e4c:	c09c                	sw	a5,0(s1)
ffffffffc0200e4e:	57fd                	li	a5,-1
ffffffffc0200e50:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc0200e52:	9552                	add	a0,a0,s4
ffffffffc0200e54:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e56:	0532                	slli	a0,a0,0xc
ffffffffc0200e58:	08e7fd63          	bleu	a4,a5,ffffffffc0200ef2 <get_pte+0x1ca>
ffffffffc0200e5c:	000ab783          	ld	a5,0(s5)
ffffffffc0200e60:	6605                	lui	a2,0x1
ffffffffc0200e62:	4581                	li	a1,0
ffffffffc0200e64:	953e                	add	a0,a0,a5
ffffffffc0200e66:	639030ef          	jal	ra,ffffffffc0204c9e <memset>
    return page - pages + nbase;
ffffffffc0200e6a:	000bb683          	ld	a3,0(s7)
ffffffffc0200e6e:	40d486b3          	sub	a3,s1,a3
ffffffffc0200e72:	868d                	srai	a3,a3,0x3
ffffffffc0200e74:	036686b3          	mul	a3,a3,s6
ffffffffc0200e78:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200e7a:	06aa                	slli	a3,a3,0xa
ffffffffc0200e7c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200e80:	e014                	sd	a3,0(s0)
ffffffffc0200e82:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200e86:	068a                	slli	a3,a3,0x2
ffffffffc0200e88:	757d                	lui	a0,0xfffff
ffffffffc0200e8a:	8ee9                	and	a3,a3,a0
ffffffffc0200e8c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200e90:	04e7f563          	bleu	a4,a5,ffffffffc0200eda <get_pte+0x1b2>
ffffffffc0200e94:	000ab503          	ld	a0,0(s5)
ffffffffc0200e98:	00c95793          	srli	a5,s2,0xc
ffffffffc0200e9c:	1ff7f793          	andi	a5,a5,511
ffffffffc0200ea0:	96aa                	add	a3,a3,a0
ffffffffc0200ea2:	00379513          	slli	a0,a5,0x3
ffffffffc0200ea6:	9536                	add	a0,a0,a3
}
ffffffffc0200ea8:	60a6                	ld	ra,72(sp)
ffffffffc0200eaa:	6406                	ld	s0,64(sp)
ffffffffc0200eac:	74e2                	ld	s1,56(sp)
ffffffffc0200eae:	7942                	ld	s2,48(sp)
ffffffffc0200eb0:	79a2                	ld	s3,40(sp)
ffffffffc0200eb2:	7a02                	ld	s4,32(sp)
ffffffffc0200eb4:	6ae2                	ld	s5,24(sp)
ffffffffc0200eb6:	6b42                	ld	s6,16(sp)
ffffffffc0200eb8:	6ba2                	ld	s7,8(sp)
ffffffffc0200eba:	6161                	addi	sp,sp,80
ffffffffc0200ebc:	8082                	ret
            return NULL;
ffffffffc0200ebe:	4501                	li	a0,0
ffffffffc0200ec0:	b7e5                	j	ffffffffc0200ea8 <get_pte+0x180>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200ec2:	00005617          	auipc	a2,0x5
ffffffffc0200ec6:	c4e60613          	addi	a2,a2,-946 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0200eca:	0e400593          	li	a1,228
ffffffffc0200ece:	00005517          	auipc	a0,0x5
ffffffffc0200ed2:	c6a50513          	addi	a0,a0,-918 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0200ed6:	b00ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200eda:	00005617          	auipc	a2,0x5
ffffffffc0200ede:	c3660613          	addi	a2,a2,-970 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0200ee2:	0ef00593          	li	a1,239
ffffffffc0200ee6:	00005517          	auipc	a0,0x5
ffffffffc0200eea:	c5250513          	addi	a0,a0,-942 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0200eee:	ae8ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200ef2:	86aa                	mv	a3,a0
ffffffffc0200ef4:	00005617          	auipc	a2,0x5
ffffffffc0200ef8:	c1c60613          	addi	a2,a2,-996 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0200efc:	0ec00593          	li	a1,236
ffffffffc0200f00:	00005517          	auipc	a0,0x5
ffffffffc0200f04:	c3850513          	addi	a0,a0,-968 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0200f08:	aceff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200f0c:	86aa                	mv	a3,a0
ffffffffc0200f0e:	00005617          	auipc	a2,0x5
ffffffffc0200f12:	c0260613          	addi	a2,a2,-1022 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0200f16:	0e100593          	li	a1,225
ffffffffc0200f1a:	00005517          	auipc	a0,0x5
ffffffffc0200f1e:	c1e50513          	addi	a0,a0,-994 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0200f22:	ab4ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200f26 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200f26:	1141                	addi	sp,sp,-16
ffffffffc0200f28:	e022                	sd	s0,0(sp)
ffffffffc0200f2a:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200f2c:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200f2e:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200f30:	df9ff0ef          	jal	ra,ffffffffc0200d28 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200f34:	c011                	beqz	s0,ffffffffc0200f38 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200f36:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200f38:	c521                	beqz	a0,ffffffffc0200f80 <get_page+0x5a>
ffffffffc0200f3a:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200f3c:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200f3e:	0017f713          	andi	a4,a5,1
ffffffffc0200f42:	e709                	bnez	a4,ffffffffc0200f4c <get_page+0x26>
}
ffffffffc0200f44:	60a2                	ld	ra,8(sp)
ffffffffc0200f46:	6402                	ld	s0,0(sp)
ffffffffc0200f48:	0141                	addi	sp,sp,16
ffffffffc0200f4a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200f4c:	00015717          	auipc	a4,0x15
ffffffffc0200f50:	54470713          	addi	a4,a4,1348 # ffffffffc0216490 <npage>
ffffffffc0200f54:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f56:	078a                	slli	a5,a5,0x2
ffffffffc0200f58:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f5a:	02e7f863          	bleu	a4,a5,ffffffffc0200f8a <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f5e:	fff80537          	lui	a0,0xfff80
ffffffffc0200f62:	97aa                	add	a5,a5,a0
ffffffffc0200f64:	00015697          	auipc	a3,0x15
ffffffffc0200f68:	59468693          	addi	a3,a3,1428 # ffffffffc02164f8 <pages>
ffffffffc0200f6c:	6288                	ld	a0,0(a3)
ffffffffc0200f6e:	60a2                	ld	ra,8(sp)
ffffffffc0200f70:	6402                	ld	s0,0(sp)
ffffffffc0200f72:	00379713          	slli	a4,a5,0x3
ffffffffc0200f76:	97ba                	add	a5,a5,a4
ffffffffc0200f78:	078e                	slli	a5,a5,0x3
ffffffffc0200f7a:	953e                	add	a0,a0,a5
ffffffffc0200f7c:	0141                	addi	sp,sp,16
ffffffffc0200f7e:	8082                	ret
ffffffffc0200f80:	60a2                	ld	ra,8(sp)
ffffffffc0200f82:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0200f84:	4501                	li	a0,0
}
ffffffffc0200f86:	0141                	addi	sp,sp,16
ffffffffc0200f88:	8082                	ret
ffffffffc0200f8a:	c75ff0ef          	jal	ra,ffffffffc0200bfe <pa2page.part.4>

ffffffffc0200f8e <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200f8e:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200f90:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200f92:	e426                	sd	s1,8(sp)
ffffffffc0200f94:	ec06                	sd	ra,24(sp)
ffffffffc0200f96:	e822                	sd	s0,16(sp)
ffffffffc0200f98:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200f9a:	d8fff0ef          	jal	ra,ffffffffc0200d28 <get_pte>
    if (ptep != NULL) {
ffffffffc0200f9e:	c511                	beqz	a0,ffffffffc0200faa <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200fa0:	611c                	ld	a5,0(a0)
ffffffffc0200fa2:	842a                	mv	s0,a0
ffffffffc0200fa4:	0017f713          	andi	a4,a5,1
ffffffffc0200fa8:	e711                	bnez	a4,ffffffffc0200fb4 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200faa:	60e2                	ld	ra,24(sp)
ffffffffc0200fac:	6442                	ld	s0,16(sp)
ffffffffc0200fae:	64a2                	ld	s1,8(sp)
ffffffffc0200fb0:	6105                	addi	sp,sp,32
ffffffffc0200fb2:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200fb4:	00015717          	auipc	a4,0x15
ffffffffc0200fb8:	4dc70713          	addi	a4,a4,1244 # ffffffffc0216490 <npage>
ffffffffc0200fbc:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200fbe:	078a                	slli	a5,a5,0x2
ffffffffc0200fc0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fc2:	04e7f163          	bleu	a4,a5,ffffffffc0201004 <page_remove+0x76>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fc6:	fff80737          	lui	a4,0xfff80
ffffffffc0200fca:	97ba                	add	a5,a5,a4
ffffffffc0200fcc:	00015717          	auipc	a4,0x15
ffffffffc0200fd0:	52c70713          	addi	a4,a4,1324 # ffffffffc02164f8 <pages>
ffffffffc0200fd4:	6308                	ld	a0,0(a4)
ffffffffc0200fd6:	00379713          	slli	a4,a5,0x3
ffffffffc0200fda:	97ba                	add	a5,a5,a4
ffffffffc0200fdc:	078e                	slli	a5,a5,0x3
ffffffffc0200fde:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200fe0:	411c                	lw	a5,0(a0)
ffffffffc0200fe2:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200fe6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200fe8:	cb11                	beqz	a4,ffffffffc0200ffc <page_remove+0x6e>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200fea:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fee:	12048073          	sfence.vma	s1
}
ffffffffc0200ff2:	60e2                	ld	ra,24(sp)
ffffffffc0200ff4:	6442                	ld	s0,16(sp)
ffffffffc0200ff6:	64a2                	ld	s1,8(sp)
ffffffffc0200ff8:	6105                	addi	sp,sp,32
ffffffffc0200ffa:	8082                	ret
            free_page(page);
ffffffffc0200ffc:	4585                	li	a1,1
ffffffffc0200ffe:	ca5ff0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
ffffffffc0201002:	b7e5                	j	ffffffffc0200fea <page_remove+0x5c>
ffffffffc0201004:	bfbff0ef          	jal	ra,ffffffffc0200bfe <pa2page.part.4>

ffffffffc0201008 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201008:	7179                	addi	sp,sp,-48
ffffffffc020100a:	e44e                	sd	s3,8(sp)
ffffffffc020100c:	89b2                	mv	s3,a2
ffffffffc020100e:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201010:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201012:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201014:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201016:	ec26                	sd	s1,24(sp)
ffffffffc0201018:	f406                	sd	ra,40(sp)
ffffffffc020101a:	e84a                	sd	s2,16(sp)
ffffffffc020101c:	e052                	sd	s4,0(sp)
ffffffffc020101e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201020:	d09ff0ef          	jal	ra,ffffffffc0200d28 <get_pte>
    if (ptep == NULL) {
ffffffffc0201024:	c94d                	beqz	a0,ffffffffc02010d6 <page_insert+0xce>
    page->ref += 1;
ffffffffc0201026:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201028:	611c                	ld	a5,0(a0)
ffffffffc020102a:	892a                	mv	s2,a0
ffffffffc020102c:	0016871b          	addiw	a4,a3,1
ffffffffc0201030:	c018                	sw	a4,0(s0)
ffffffffc0201032:	0017f713          	andi	a4,a5,1
ffffffffc0201036:	e721                	bnez	a4,ffffffffc020107e <page_insert+0x76>
ffffffffc0201038:	00015797          	auipc	a5,0x15
ffffffffc020103c:	4c078793          	addi	a5,a5,1216 # ffffffffc02164f8 <pages>
ffffffffc0201040:	639c                	ld	a5,0(a5)
    return page - pages + nbase;
ffffffffc0201042:	00005717          	auipc	a4,0x5
ffffffffc0201046:	ac670713          	addi	a4,a4,-1338 # ffffffffc0205b08 <commands+0x8b0>
ffffffffc020104a:	40f407b3          	sub	a5,s0,a5
ffffffffc020104e:	6300                	ld	s0,0(a4)
ffffffffc0201050:	878d                	srai	a5,a5,0x3
ffffffffc0201052:	000806b7          	lui	a3,0x80
ffffffffc0201056:	028787b3          	mul	a5,a5,s0
ffffffffc020105a:	97b6                	add	a5,a5,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020105c:	07aa                	slli	a5,a5,0xa
ffffffffc020105e:	8fc5                	or	a5,a5,s1
ffffffffc0201060:	0017e793          	ori	a5,a5,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201064:	00f93023          	sd	a5,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201068:	12098073          	sfence.vma	s3
    return 0;
ffffffffc020106c:	4501                	li	a0,0
}
ffffffffc020106e:	70a2                	ld	ra,40(sp)
ffffffffc0201070:	7402                	ld	s0,32(sp)
ffffffffc0201072:	64e2                	ld	s1,24(sp)
ffffffffc0201074:	6942                	ld	s2,16(sp)
ffffffffc0201076:	69a2                	ld	s3,8(sp)
ffffffffc0201078:	6a02                	ld	s4,0(sp)
ffffffffc020107a:	6145                	addi	sp,sp,48
ffffffffc020107c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020107e:	00015717          	auipc	a4,0x15
ffffffffc0201082:	41270713          	addi	a4,a4,1042 # ffffffffc0216490 <npage>
ffffffffc0201086:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201088:	00279513          	slli	a0,a5,0x2
ffffffffc020108c:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020108e:	04e57663          	bleu	a4,a0,ffffffffc02010da <page_insert+0xd2>
    return &pages[PPN(pa) - nbase];
ffffffffc0201092:	fff807b7          	lui	a5,0xfff80
ffffffffc0201096:	953e                	add	a0,a0,a5
ffffffffc0201098:	00015a17          	auipc	s4,0x15
ffffffffc020109c:	460a0a13          	addi	s4,s4,1120 # ffffffffc02164f8 <pages>
ffffffffc02010a0:	000a3783          	ld	a5,0(s4)
ffffffffc02010a4:	00351713          	slli	a4,a0,0x3
ffffffffc02010a8:	953a                	add	a0,a0,a4
ffffffffc02010aa:	050e                	slli	a0,a0,0x3
ffffffffc02010ac:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc02010ae:	00a40a63          	beq	s0,a0,ffffffffc02010c2 <page_insert+0xba>
    page->ref -= 1;
ffffffffc02010b2:	4118                	lw	a4,0(a0)
ffffffffc02010b4:	fff7069b          	addiw	a3,a4,-1
ffffffffc02010b8:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc02010ba:	c691                	beqz	a3,ffffffffc02010c6 <page_insert+0xbe>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02010bc:	12098073          	sfence.vma	s3
ffffffffc02010c0:	b749                	j	ffffffffc0201042 <page_insert+0x3a>
ffffffffc02010c2:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02010c4:	bfbd                	j	ffffffffc0201042 <page_insert+0x3a>
            free_page(page);
ffffffffc02010c6:	4585                	li	a1,1
ffffffffc02010c8:	bdbff0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
ffffffffc02010cc:	000a3783          	ld	a5,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02010d0:	12098073          	sfence.vma	s3
ffffffffc02010d4:	b7bd                	j	ffffffffc0201042 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02010d6:	5571                	li	a0,-4
ffffffffc02010d8:	bf59                	j	ffffffffc020106e <page_insert+0x66>
ffffffffc02010da:	b25ff0ef          	jal	ra,ffffffffc0200bfe <pa2page.part.4>

ffffffffc02010de <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02010de:	00006797          	auipc	a5,0x6
ffffffffc02010e2:	ce278793          	addi	a5,a5,-798 # ffffffffc0206dc0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010e6:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02010e8:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010ea:	00005517          	auipc	a0,0x5
ffffffffc02010ee:	aa650513          	addi	a0,a0,-1370 # ffffffffc0205b90 <commands+0x938>
void pmm_init(void) {
ffffffffc02010f2:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02010f4:	00015717          	auipc	a4,0x15
ffffffffc02010f8:	3ef73623          	sd	a5,1004(a4) # ffffffffc02164e0 <pmm_manager>
void pmm_init(void) {
ffffffffc02010fc:	e8a2                	sd	s0,80(sp)
ffffffffc02010fe:	e4a6                	sd	s1,72(sp)
ffffffffc0201100:	e0ca                	sd	s2,64(sp)
ffffffffc0201102:	fc4e                	sd	s3,56(sp)
ffffffffc0201104:	f852                	sd	s4,48(sp)
ffffffffc0201106:	f456                	sd	s5,40(sp)
ffffffffc0201108:	f05a                	sd	s6,32(sp)
ffffffffc020110a:	ec5e                	sd	s7,24(sp)
ffffffffc020110c:	e862                	sd	s8,16(sp)
ffffffffc020110e:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201110:	00015417          	auipc	s0,0x15
ffffffffc0201114:	3d040413          	addi	s0,s0,976 # ffffffffc02164e0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201118:	fb9fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc020111c:	601c                	ld	a5,0(s0)
ffffffffc020111e:	00015497          	auipc	s1,0x15
ffffffffc0201122:	37248493          	addi	s1,s1,882 # ffffffffc0216490 <npage>
ffffffffc0201126:	00015917          	auipc	s2,0x15
ffffffffc020112a:	3d290913          	addi	s2,s2,978 # ffffffffc02164f8 <pages>
ffffffffc020112e:	679c                	ld	a5,8(a5)
ffffffffc0201130:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201132:	57f5                	li	a5,-3
ffffffffc0201134:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201136:	00005517          	auipc	a0,0x5
ffffffffc020113a:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205ba8 <commands+0x950>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020113e:	00015717          	auipc	a4,0x15
ffffffffc0201142:	3af73523          	sd	a5,938(a4) # ffffffffc02164e8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201146:	f8bfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020114a:	46c5                	li	a3,17
ffffffffc020114c:	06ee                	slli	a3,a3,0x1b
ffffffffc020114e:	40100613          	li	a2,1025
ffffffffc0201152:	16fd                	addi	a3,a3,-1
ffffffffc0201154:	0656                	slli	a2,a2,0x15
ffffffffc0201156:	07e005b7          	lui	a1,0x7e00
ffffffffc020115a:	00005517          	auipc	a0,0x5
ffffffffc020115e:	a6650513          	addi	a0,a0,-1434 # ffffffffc0205bc0 <commands+0x968>
ffffffffc0201162:	f6ffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201166:	777d                	lui	a4,0xfffff
ffffffffc0201168:	00016797          	auipc	a5,0x16
ffffffffc020116c:	49f78793          	addi	a5,a5,1183 # ffffffffc0217607 <end+0xfff>
ffffffffc0201170:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201172:	00088737          	lui	a4,0x88
ffffffffc0201176:	00015697          	auipc	a3,0x15
ffffffffc020117a:	30e6bd23          	sd	a4,794(a3) # ffffffffc0216490 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020117e:	4581                	li	a1,0
ffffffffc0201180:	00015717          	auipc	a4,0x15
ffffffffc0201184:	36f73c23          	sd	a5,888(a4) # ffffffffc02164f8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201188:	4681                	li	a3,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020118a:	4605                	li	a2,1
ffffffffc020118c:	fff80837          	lui	a6,0xfff80
ffffffffc0201190:	a019                	j	ffffffffc0201196 <pmm_init+0xb8>
ffffffffc0201192:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201196:	97ae                	add	a5,a5,a1
ffffffffc0201198:	07a1                	addi	a5,a5,8
ffffffffc020119a:	40c7b02f          	amoor.d	zero,a2,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020119e:	6098                	ld	a4,0(s1)
ffffffffc02011a0:	0685                	addi	a3,a3,1
ffffffffc02011a2:	04858593          	addi	a1,a1,72 # 7e00048 <BASE_ADDRESS-0xffffffffb83fffb8>
ffffffffc02011a6:	010707b3          	add	a5,a4,a6
ffffffffc02011aa:	fef6e4e3          	bltu	a3,a5,ffffffffc0201192 <pmm_init+0xb4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011ae:	00093503          	ld	a0,0(s2)
ffffffffc02011b2:	00371693          	slli	a3,a4,0x3
ffffffffc02011b6:	96ba                	add	a3,a3,a4
ffffffffc02011b8:	fdc005b7          	lui	a1,0xfdc00
ffffffffc02011bc:	068e                	slli	a3,a3,0x3
ffffffffc02011be:	95aa                	add	a1,a1,a0
ffffffffc02011c0:	96ae                	add	a3,a3,a1
ffffffffc02011c2:	c02007b7          	lui	a5,0xc0200
ffffffffc02011c6:	16f6efe3          	bltu	a3,a5,ffffffffc0201b44 <pmm_init+0xa66>
ffffffffc02011ca:	00015997          	auipc	s3,0x15
ffffffffc02011ce:	31e98993          	addi	s3,s3,798 # ffffffffc02164e8 <va_pa_offset>
ffffffffc02011d2:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02011d6:	47c5                	li	a5,17
ffffffffc02011d8:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011da:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02011dc:	02f6fc63          	bleu	a5,a3,ffffffffc0201214 <pmm_init+0x136>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02011e0:	6585                	lui	a1,0x1
ffffffffc02011e2:	15fd                	addi	a1,a1,-1
ffffffffc02011e4:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02011e6:	00c6d613          	srli	a2,a3,0xc
ffffffffc02011ea:	4ee67d63          	bleu	a4,a2,ffffffffc02016e4 <pmm_init+0x606>
    pmm_manager->init_memmap(base, n);
ffffffffc02011ee:	00043883          	ld	a7,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02011f2:	9642                	add	a2,a2,a6
ffffffffc02011f4:	00361713          	slli	a4,a2,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02011f8:	75fd                	lui	a1,0xfffff
ffffffffc02011fa:	8eed                	and	a3,a3,a1
ffffffffc02011fc:	9732                	add	a4,a4,a2
    pmm_manager->init_memmap(base, n);
ffffffffc02011fe:	0108b603          	ld	a2,16(a7)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201202:	40d786b3          	sub	a3,a5,a3
ffffffffc0201206:	070e                	slli	a4,a4,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201208:	00c6d593          	srli	a1,a3,0xc
ffffffffc020120c:	953a                	add	a0,a0,a4
ffffffffc020120e:	9602                	jalr	a2
ffffffffc0201210:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201214:	00005517          	auipc	a0,0x5
ffffffffc0201218:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0205c10 <commands+0x9b8>
ffffffffc020121c:	eb5fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201220:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201222:	00015417          	auipc	s0,0x15
ffffffffc0201226:	26640413          	addi	s0,s0,614 # ffffffffc0216488 <boot_pgdir>
    pmm_manager->check();
ffffffffc020122a:	7b9c                	ld	a5,48(a5)
ffffffffc020122c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020122e:	00005517          	auipc	a0,0x5
ffffffffc0201232:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0205c28 <commands+0x9d0>
ffffffffc0201236:	e9bfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020123a:	00009697          	auipc	a3,0x9
ffffffffc020123e:	dc668693          	addi	a3,a3,-570 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0201242:	00015797          	auipc	a5,0x15
ffffffffc0201246:	24d7b323          	sd	a3,582(a5) # ffffffffc0216488 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020124a:	c02007b7          	lui	a5,0xc0200
ffffffffc020124e:	7cf6ef63          	bltu	a3,a5,ffffffffc0201a2c <pmm_init+0x94e>
ffffffffc0201252:	0009b783          	ld	a5,0(s3)
ffffffffc0201256:	8e9d                	sub	a3,a3,a5
ffffffffc0201258:	00015797          	auipc	a5,0x15
ffffffffc020125c:	28d7bc23          	sd	a3,664(a5) # ffffffffc02164f0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201260:	a89ff0ef          	jal	ra,ffffffffc0200ce8 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201264:	6098                	ld	a4,0(s1)
ffffffffc0201266:	c80007b7          	lui	a5,0xc8000
ffffffffc020126a:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020126c:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020126e:	76e7ef63          	bltu	a5,a4,ffffffffc02019ec <pmm_init+0x90e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201272:	6008                	ld	a0,0(s0)
ffffffffc0201274:	48050663          	beqz	a0,ffffffffc0201700 <pmm_init+0x622>
ffffffffc0201278:	6785                	lui	a5,0x1
ffffffffc020127a:	17fd                	addi	a5,a5,-1
ffffffffc020127c:	8fe9                	and	a5,a5,a0
ffffffffc020127e:	2781                	sext.w	a5,a5
ffffffffc0201280:	48079063          	bnez	a5,ffffffffc0201700 <pmm_init+0x622>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201284:	4601                	li	a2,0
ffffffffc0201286:	4581                	li	a1,0
ffffffffc0201288:	c9fff0ef          	jal	ra,ffffffffc0200f26 <get_page>
ffffffffc020128c:	08051ce3          	bnez	a0,ffffffffc0201b24 <pmm_init+0xa46>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201290:	4505                	li	a0,1
ffffffffc0201292:	989ff0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc0201296:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201298:	6008                	ld	a0,0(s0)
ffffffffc020129a:	4681                	li	a3,0
ffffffffc020129c:	4601                	li	a2,0
ffffffffc020129e:	85d6                	mv	a1,s5
ffffffffc02012a0:	d69ff0ef          	jal	ra,ffffffffc0201008 <page_insert>
ffffffffc02012a4:	060510e3          	bnez	a0,ffffffffc0201b04 <pmm_init+0xa26>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02012a8:	6008                	ld	a0,0(s0)
ffffffffc02012aa:	4601                	li	a2,0
ffffffffc02012ac:	4581                	li	a1,0
ffffffffc02012ae:	a7bff0ef          	jal	ra,ffffffffc0200d28 <get_pte>
ffffffffc02012b2:	48050363          	beqz	a0,ffffffffc0201738 <pmm_init+0x65a>
    assert(pte2page(*ptep) == p1);
ffffffffc02012b6:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02012b8:	0017f713          	andi	a4,a5,1
ffffffffc02012bc:	46070263          	beqz	a4,ffffffffc0201720 <pmm_init+0x642>
    if (PPN(pa) >= npage) {
ffffffffc02012c0:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02012c2:	078a                	slli	a5,a5,0x2
ffffffffc02012c4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012c6:	40c7ff63          	bleu	a2,a5,ffffffffc02016e4 <pmm_init+0x606>
    return &pages[PPN(pa) - nbase];
ffffffffc02012ca:	fff80737          	lui	a4,0xfff80
ffffffffc02012ce:	97ba                	add	a5,a5,a4
ffffffffc02012d0:	00379713          	slli	a4,a5,0x3
ffffffffc02012d4:	00093683          	ld	a3,0(s2)
ffffffffc02012d8:	97ba                	add	a5,a5,a4
ffffffffc02012da:	078e                	slli	a5,a5,0x3
ffffffffc02012dc:	97b6                	add	a5,a5,a3
ffffffffc02012de:	4cfa9763          	bne	s5,a5,ffffffffc02017ac <pmm_init+0x6ce>
    assert(page_ref(p1) == 1);
ffffffffc02012e2:	000aab83          	lw	s7,0(s5)
ffffffffc02012e6:	4785                	li	a5,1
ffffffffc02012e8:	4afb9263          	bne	s7,a5,ffffffffc020178c <pmm_init+0x6ae>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02012ec:	6008                	ld	a0,0(s0)
ffffffffc02012ee:	76fd                	lui	a3,0xfffff
ffffffffc02012f0:	611c                	ld	a5,0(a0)
ffffffffc02012f2:	078a                	slli	a5,a5,0x2
ffffffffc02012f4:	8ff5                	and	a5,a5,a3
ffffffffc02012f6:	00c7d713          	srli	a4,a5,0xc
ffffffffc02012fa:	46c77c63          	bleu	a2,a4,ffffffffc0201772 <pmm_init+0x694>
ffffffffc02012fe:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201302:	97e2                	add	a5,a5,s8
ffffffffc0201304:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201308:	0b0a                	slli	s6,s6,0x2
ffffffffc020130a:	00db7b33          	and	s6,s6,a3
ffffffffc020130e:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201312:	44c7f363          	bleu	a2,a5,ffffffffc0201758 <pmm_init+0x67a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201316:	4601                	li	a2,0
ffffffffc0201318:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020131a:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020131c:	a0dff0ef          	jal	ra,ffffffffc0200d28 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201320:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201322:	59651563          	bne	a0,s6,ffffffffc02018ac <pmm_init+0x7ce>

    p2 = alloc_page();
ffffffffc0201326:	4505                	li	a0,1
ffffffffc0201328:	8f3ff0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc020132c:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020132e:	6008                	ld	a0,0(s0)
ffffffffc0201330:	46d1                	li	a3,20
ffffffffc0201332:	6605                	lui	a2,0x1
ffffffffc0201334:	85da                	mv	a1,s6
ffffffffc0201336:	cd3ff0ef          	jal	ra,ffffffffc0201008 <page_insert>
ffffffffc020133a:	54051963          	bnez	a0,ffffffffc020188c <pmm_init+0x7ae>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020133e:	6008                	ld	a0,0(s0)
ffffffffc0201340:	4601                	li	a2,0
ffffffffc0201342:	6585                	lui	a1,0x1
ffffffffc0201344:	9e5ff0ef          	jal	ra,ffffffffc0200d28 <get_pte>
ffffffffc0201348:	52050263          	beqz	a0,ffffffffc020186c <pmm_init+0x78e>
    assert(*ptep & PTE_U);
ffffffffc020134c:	611c                	ld	a5,0(a0)
ffffffffc020134e:	0107f713          	andi	a4,a5,16
ffffffffc0201352:	4e070d63          	beqz	a4,ffffffffc020184c <pmm_init+0x76e>
    assert(*ptep & PTE_W);
ffffffffc0201356:	8b91                	andi	a5,a5,4
ffffffffc0201358:	4c078a63          	beqz	a5,ffffffffc020182c <pmm_init+0x74e>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020135c:	6008                	ld	a0,0(s0)
ffffffffc020135e:	611c                	ld	a5,0(a0)
ffffffffc0201360:	8bc1                	andi	a5,a5,16
ffffffffc0201362:	4a078563          	beqz	a5,ffffffffc020180c <pmm_init+0x72e>
    assert(page_ref(p2) == 1);
ffffffffc0201366:	000b2783          	lw	a5,0(s6)
ffffffffc020136a:	49779163          	bne	a5,s7,ffffffffc02017ec <pmm_init+0x70e>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020136e:	4681                	li	a3,0
ffffffffc0201370:	6605                	lui	a2,0x1
ffffffffc0201372:	85d6                	mv	a1,s5
ffffffffc0201374:	c95ff0ef          	jal	ra,ffffffffc0201008 <page_insert>
ffffffffc0201378:	44051a63          	bnez	a0,ffffffffc02017cc <pmm_init+0x6ee>
    assert(page_ref(p1) == 2);
ffffffffc020137c:	000aa703          	lw	a4,0(s5)
ffffffffc0201380:	4789                	li	a5,2
ffffffffc0201382:	62f71563          	bne	a4,a5,ffffffffc02019ac <pmm_init+0x8ce>
    assert(page_ref(p2) == 0);
ffffffffc0201386:	000b2783          	lw	a5,0(s6)
ffffffffc020138a:	60079163          	bnez	a5,ffffffffc020198c <pmm_init+0x8ae>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020138e:	6008                	ld	a0,0(s0)
ffffffffc0201390:	4601                	li	a2,0
ffffffffc0201392:	6585                	lui	a1,0x1
ffffffffc0201394:	995ff0ef          	jal	ra,ffffffffc0200d28 <get_pte>
ffffffffc0201398:	5c050a63          	beqz	a0,ffffffffc020196c <pmm_init+0x88e>
    assert(pte2page(*ptep) == p1);
ffffffffc020139c:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020139e:	0016f793          	andi	a5,a3,1
ffffffffc02013a2:	36078f63          	beqz	a5,ffffffffc0201720 <pmm_init+0x642>
    if (PPN(pa) >= npage) {
ffffffffc02013a6:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02013a8:	00269793          	slli	a5,a3,0x2
ffffffffc02013ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013ae:	32e7fb63          	bleu	a4,a5,ffffffffc02016e4 <pmm_init+0x606>
    return &pages[PPN(pa) - nbase];
ffffffffc02013b2:	fff80737          	lui	a4,0xfff80
ffffffffc02013b6:	97ba                	add	a5,a5,a4
ffffffffc02013b8:	00379713          	slli	a4,a5,0x3
ffffffffc02013bc:	00093603          	ld	a2,0(s2)
ffffffffc02013c0:	97ba                	add	a5,a5,a4
ffffffffc02013c2:	078e                	slli	a5,a5,0x3
ffffffffc02013c4:	97b2                	add	a5,a5,a2
ffffffffc02013c6:	58fa9363          	bne	s5,a5,ffffffffc020194c <pmm_init+0x86e>
    assert((*ptep & PTE_U) == 0);
ffffffffc02013ca:	8ac1                	andi	a3,a3,16
ffffffffc02013cc:	56069063          	bnez	a3,ffffffffc020192c <pmm_init+0x84e>

    page_remove(boot_pgdir, 0x0);
ffffffffc02013d0:	6008                	ld	a0,0(s0)
ffffffffc02013d2:	4581                	li	a1,0
ffffffffc02013d4:	bbbff0ef          	jal	ra,ffffffffc0200f8e <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02013d8:	000aa703          	lw	a4,0(s5)
ffffffffc02013dc:	4785                	li	a5,1
ffffffffc02013de:	52f71763          	bne	a4,a5,ffffffffc020190c <pmm_init+0x82e>
    assert(page_ref(p2) == 0);
ffffffffc02013e2:	000b2783          	lw	a5,0(s6)
ffffffffc02013e6:	50079363          	bnez	a5,ffffffffc02018ec <pmm_init+0x80e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02013ea:	6008                	ld	a0,0(s0)
ffffffffc02013ec:	6585                	lui	a1,0x1
ffffffffc02013ee:	ba1ff0ef          	jal	ra,ffffffffc0200f8e <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02013f2:	000aa783          	lw	a5,0(s5)
ffffffffc02013f6:	4c079b63          	bnez	a5,ffffffffc02018cc <pmm_init+0x7ee>
    assert(page_ref(p2) == 0);
ffffffffc02013fa:	000b2783          	lw	a5,0(s6)
ffffffffc02013fe:	6e079363          	bnez	a5,ffffffffc0201ae4 <pmm_init+0xa06>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201402:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201406:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201408:	000b3783          	ld	a5,0(s6)
ffffffffc020140c:	078a                	slli	a5,a5,0x2
ffffffffc020140e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201410:	2cb7fa63          	bleu	a1,a5,ffffffffc02016e4 <pmm_init+0x606>
    return &pages[PPN(pa) - nbase];
ffffffffc0201414:	fff80737          	lui	a4,0xfff80
ffffffffc0201418:	973e                	add	a4,a4,a5
ffffffffc020141a:	00371793          	slli	a5,a4,0x3
ffffffffc020141e:	00093603          	ld	a2,0(s2)
ffffffffc0201422:	97ba                	add	a5,a5,a4
ffffffffc0201424:	078e                	slli	a5,a5,0x3
ffffffffc0201426:	00f60733          	add	a4,a2,a5
ffffffffc020142a:	4314                	lw	a3,0(a4)
ffffffffc020142c:	4705                	li	a4,1
ffffffffc020142e:	68e69b63          	bne	a3,a4,ffffffffc0201ac4 <pmm_init+0x9e6>
    return page - pages + nbase;
ffffffffc0201432:	00004a97          	auipc	s5,0x4
ffffffffc0201436:	6d6a8a93          	addi	s5,s5,1750 # ffffffffc0205b08 <commands+0x8b0>
ffffffffc020143a:	000ab703          	ld	a4,0(s5)
ffffffffc020143e:	4037d693          	srai	a3,a5,0x3
ffffffffc0201442:	00080bb7          	lui	s7,0x80
ffffffffc0201446:	02e686b3          	mul	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020144a:	577d                	li	a4,-1
ffffffffc020144c:	8331                	srli	a4,a4,0xc
    return page - pages + nbase;
ffffffffc020144e:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0201450:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201452:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201454:	28b77a63          	bleu	a1,a4,ffffffffc02016e8 <pmm_init+0x60a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201458:	0009b783          	ld	a5,0(s3)
ffffffffc020145c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020145e:	629c                	ld	a5,0(a3)
ffffffffc0201460:	078a                	slli	a5,a5,0x2
ffffffffc0201462:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201464:	28b7f063          	bleu	a1,a5,ffffffffc02016e4 <pmm_init+0x606>
    return &pages[PPN(pa) - nbase];
ffffffffc0201468:	417787b3          	sub	a5,a5,s7
ffffffffc020146c:	00379513          	slli	a0,a5,0x3
ffffffffc0201470:	97aa                	add	a5,a5,a0
ffffffffc0201472:	00379513          	slli	a0,a5,0x3
ffffffffc0201476:	9532                	add	a0,a0,a2
ffffffffc0201478:	4585                	li	a1,1
ffffffffc020147a:	829ff0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020147e:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201482:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201484:	050a                	slli	a0,a0,0x2
ffffffffc0201486:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201488:	24f57e63          	bleu	a5,a0,ffffffffc02016e4 <pmm_init+0x606>
    return &pages[PPN(pa) - nbase];
ffffffffc020148c:	417507b3          	sub	a5,a0,s7
ffffffffc0201490:	00379513          	slli	a0,a5,0x3
ffffffffc0201494:	00093703          	ld	a4,0(s2)
ffffffffc0201498:	953e                	add	a0,a0,a5
ffffffffc020149a:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc020149c:	4585                	li	a1,1
ffffffffc020149e:	953a                	add	a0,a0,a4
ffffffffc02014a0:	803ff0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02014a4:	601c                	ld	a5,0(s0)
ffffffffc02014a6:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02014aa:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02014ae:	83bff0ef          	jal	ra,ffffffffc0200ce8 <nr_free_pages>
ffffffffc02014b2:	50aa1d63          	bne	s4,a0,ffffffffc02019cc <pmm_init+0x8ee>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02014b6:	00005517          	auipc	a0,0x5
ffffffffc02014ba:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0205f50 <commands+0xcf8>
ffffffffc02014be:	c13fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02014c2:	827ff0ef          	jal	ra,ffffffffc0200ce8 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02014c6:	6098                	ld	a4,0(s1)
ffffffffc02014c8:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02014cc:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02014ce:	00c71693          	slli	a3,a4,0xc
ffffffffc02014d2:	1ad7fa63          	bleu	a3,a5,ffffffffc0201686 <pmm_init+0x5a8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02014d6:	83b1                	srli	a5,a5,0xc
ffffffffc02014d8:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02014da:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02014de:	1ce7f663          	bleu	a4,a5,ffffffffc02016aa <pmm_init+0x5cc>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02014e2:	7c7d                	lui	s8,0xfffff
ffffffffc02014e4:	6b85                	lui	s7,0x1
ffffffffc02014e6:	a029                	j	ffffffffc02014f0 <pmm_init+0x412>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02014e8:	00ca5713          	srli	a4,s4,0xc
ffffffffc02014ec:	1af77f63          	bleu	a5,a4,ffffffffc02016aa <pmm_init+0x5cc>
ffffffffc02014f0:	0009b583          	ld	a1,0(s3)
ffffffffc02014f4:	4601                	li	a2,0
ffffffffc02014f6:	95d2                	add	a1,a1,s4
ffffffffc02014f8:	831ff0ef          	jal	ra,ffffffffc0200d28 <get_pte>
ffffffffc02014fc:	18050763          	beqz	a0,ffffffffc020168a <pmm_init+0x5ac>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201500:	611c                	ld	a5,0(a0)
ffffffffc0201502:	078a                	slli	a5,a5,0x2
ffffffffc0201504:	0187f7b3          	and	a5,a5,s8
ffffffffc0201508:	1b479e63          	bne	a5,s4,ffffffffc02016c4 <pmm_init+0x5e6>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020150c:	609c                	ld	a5,0(s1)
ffffffffc020150e:	9a5e                	add	s4,s4,s7
ffffffffc0201510:	6008                	ld	a0,0(s0)
ffffffffc0201512:	00c79713          	slli	a4,a5,0xc
ffffffffc0201516:	fcea69e3          	bltu	s4,a4,ffffffffc02014e8 <pmm_init+0x40a>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc020151a:	611c                	ld	a5,0(a0)
ffffffffc020151c:	4e079863          	bnez	a5,ffffffffc0201a0c <pmm_init+0x92e>

    struct Page *p;
    p = alloc_page();
ffffffffc0201520:	4505                	li	a0,1
ffffffffc0201522:	ef8ff0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc0201526:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201528:	6008                	ld	a0,0(s0)
ffffffffc020152a:	4699                	li	a3,6
ffffffffc020152c:	10000613          	li	a2,256
ffffffffc0201530:	85d2                	mv	a1,s4
ffffffffc0201532:	ad7ff0ef          	jal	ra,ffffffffc0201008 <page_insert>
ffffffffc0201536:	56051763          	bnez	a0,ffffffffc0201aa4 <pmm_init+0x9c6>
    assert(page_ref(p) == 1);
ffffffffc020153a:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc020153e:	4785                	li	a5,1
ffffffffc0201540:	54f71263          	bne	a4,a5,ffffffffc0201a84 <pmm_init+0x9a6>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201544:	6008                	ld	a0,0(s0)
ffffffffc0201546:	6b85                	lui	s7,0x1
ffffffffc0201548:	4699                	li	a3,6
ffffffffc020154a:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc020154e:	85d2                	mv	a1,s4
ffffffffc0201550:	ab9ff0ef          	jal	ra,ffffffffc0201008 <page_insert>
ffffffffc0201554:	50051863          	bnez	a0,ffffffffc0201a64 <pmm_init+0x986>
    assert(page_ref(p) == 2);
ffffffffc0201558:	000a2703          	lw	a4,0(s4)
ffffffffc020155c:	4789                	li	a5,2
ffffffffc020155e:	4ef71363          	bne	a4,a5,ffffffffc0201a44 <pmm_init+0x966>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201562:	00005597          	auipc	a1,0x5
ffffffffc0201566:	b2658593          	addi	a1,a1,-1242 # ffffffffc0206088 <commands+0xe30>
ffffffffc020156a:	10000513          	li	a0,256
ffffffffc020156e:	6d6030ef          	jal	ra,ffffffffc0204c44 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201572:	100b8593          	addi	a1,s7,256
ffffffffc0201576:	10000513          	li	a0,256
ffffffffc020157a:	6dc030ef          	jal	ra,ffffffffc0204c56 <strcmp>
ffffffffc020157e:	60051f63          	bnez	a0,ffffffffc0201b9c <pmm_init+0xabe>
    return page - pages + nbase;
ffffffffc0201582:	00093683          	ld	a3,0(s2)
ffffffffc0201586:	000abc83          	ld	s9,0(s5)
ffffffffc020158a:	00080c37          	lui	s8,0x80
ffffffffc020158e:	40da06b3          	sub	a3,s4,a3
ffffffffc0201592:	868d                	srai	a3,a3,0x3
ffffffffc0201594:	039686b3          	mul	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0201598:	5afd                	li	s5,-1
ffffffffc020159a:	609c                	ld	a5,0(s1)
ffffffffc020159c:	00cada93          	srli	s5,s5,0xc
    return page - pages + nbase;
ffffffffc02015a0:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc02015a2:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02015a6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02015a8:	14f77063          	bleu	a5,a4,ffffffffc02016e8 <pmm_init+0x60a>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02015ac:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02015b0:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02015b4:	96be                	add	a3,a3,a5
ffffffffc02015b6:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde8af8>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02015ba:	646030ef          	jal	ra,ffffffffc0204c00 <strlen>
ffffffffc02015be:	5a051f63          	bnez	a0,ffffffffc0201b7c <pmm_init+0xa9e>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02015c2:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02015c6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02015c8:	000bb783          	ld	a5,0(s7)
ffffffffc02015cc:	078a                	slli	a5,a5,0x2
ffffffffc02015ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015d0:	10e7fa63          	bleu	a4,a5,ffffffffc02016e4 <pmm_init+0x606>
    return &pages[PPN(pa) - nbase];
ffffffffc02015d4:	418787b3          	sub	a5,a5,s8
ffffffffc02015d8:	00379693          	slli	a3,a5,0x3
    return page - pages + nbase;
ffffffffc02015dc:	96be                	add	a3,a3,a5
ffffffffc02015de:	039686b3          	mul	a3,a3,s9
ffffffffc02015e2:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc02015e4:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02015e8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02015ea:	0eeaff63          	bleu	a4,s5,ffffffffc02016e8 <pmm_init+0x60a>
ffffffffc02015ee:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02015f2:	4585                	li	a1,1
ffffffffc02015f4:	8552                	mv	a0,s4
ffffffffc02015f6:	99b6                	add	s3,s3,a3
ffffffffc02015f8:	eaaff0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02015fc:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201600:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201602:	078a                	slli	a5,a5,0x2
ffffffffc0201604:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201606:	0ce7ff63          	bleu	a4,a5,ffffffffc02016e4 <pmm_init+0x606>
    return &pages[PPN(pa) - nbase];
ffffffffc020160a:	fff809b7          	lui	s3,0xfff80
ffffffffc020160e:	97ce                	add	a5,a5,s3
ffffffffc0201610:	00379513          	slli	a0,a5,0x3
ffffffffc0201614:	00093703          	ld	a4,0(s2)
ffffffffc0201618:	97aa                	add	a5,a5,a0
ffffffffc020161a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020161e:	953a                	add	a0,a0,a4
ffffffffc0201620:	4585                	li	a1,1
ffffffffc0201622:	e80ff0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201626:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020162a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020162c:	050a                	slli	a0,a0,0x2
ffffffffc020162e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201630:	0af57a63          	bleu	a5,a0,ffffffffc02016e4 <pmm_init+0x606>
    return &pages[PPN(pa) - nbase];
ffffffffc0201634:	013507b3          	add	a5,a0,s3
ffffffffc0201638:	00379513          	slli	a0,a5,0x3
ffffffffc020163c:	00093703          	ld	a4,0(s2)
ffffffffc0201640:	953e                	add	a0,a0,a5
ffffffffc0201642:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201644:	4585                	li	a1,1
ffffffffc0201646:	953a                	add	a0,a0,a4
ffffffffc0201648:	e5aff0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020164c:	601c                	ld	a5,0(s0)
ffffffffc020164e:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201652:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201656:	e92ff0ef          	jal	ra,ffffffffc0200ce8 <nr_free_pages>
ffffffffc020165a:	50ab1163          	bne	s6,a0,ffffffffc0201b5c <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020165e:	00005517          	auipc	a0,0x5
ffffffffc0201662:	aa250513          	addi	a0,a0,-1374 # ffffffffc0206100 <commands+0xea8>
ffffffffc0201666:	a6bfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc020166a:	6446                	ld	s0,80(sp)
ffffffffc020166c:	60e6                	ld	ra,88(sp)
ffffffffc020166e:	64a6                	ld	s1,72(sp)
ffffffffc0201670:	6906                	ld	s2,64(sp)
ffffffffc0201672:	79e2                	ld	s3,56(sp)
ffffffffc0201674:	7a42                	ld	s4,48(sp)
ffffffffc0201676:	7aa2                	ld	s5,40(sp)
ffffffffc0201678:	7b02                	ld	s6,32(sp)
ffffffffc020167a:	6be2                	ld	s7,24(sp)
ffffffffc020167c:	6c42                	ld	s8,16(sp)
ffffffffc020167e:	6ca2                	ld	s9,8(sp)
ffffffffc0201680:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0201682:	1df0106f          	j	ffffffffc0203060 <kmalloc_init>
ffffffffc0201686:	6008                	ld	a0,0(s0)
ffffffffc0201688:	bd49                	j	ffffffffc020151a <pmm_init+0x43c>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020168a:	00005697          	auipc	a3,0x5
ffffffffc020168e:	8e668693          	addi	a3,a3,-1818 # ffffffffc0205f70 <commands+0xd18>
ffffffffc0201692:	00004617          	auipc	a2,0x4
ffffffffc0201696:	5d660613          	addi	a2,a2,1494 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020169a:	19d00593          	li	a1,413
ffffffffc020169e:	00004517          	auipc	a0,0x4
ffffffffc02016a2:	49a50513          	addi	a0,a0,1178 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02016a6:	b31fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc02016aa:	86d2                	mv	a3,s4
ffffffffc02016ac:	00004617          	auipc	a2,0x4
ffffffffc02016b0:	46460613          	addi	a2,a2,1124 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc02016b4:	19d00593          	li	a1,413
ffffffffc02016b8:	00004517          	auipc	a0,0x4
ffffffffc02016bc:	48050513          	addi	a0,a0,1152 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02016c0:	b17fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02016c4:	00005697          	auipc	a3,0x5
ffffffffc02016c8:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0205fb0 <commands+0xd58>
ffffffffc02016cc:	00004617          	auipc	a2,0x4
ffffffffc02016d0:	59c60613          	addi	a2,a2,1436 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02016d4:	19e00593          	li	a1,414
ffffffffc02016d8:	00004517          	auipc	a0,0x4
ffffffffc02016dc:	46050513          	addi	a0,a0,1120 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02016e0:	af7fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc02016e4:	d1aff0ef          	jal	ra,ffffffffc0200bfe <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc02016e8:	00004617          	auipc	a2,0x4
ffffffffc02016ec:	42860613          	addi	a2,a2,1064 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc02016f0:	06900593          	li	a1,105
ffffffffc02016f4:	00004517          	auipc	a0,0x4
ffffffffc02016f8:	47450513          	addi	a0,a0,1140 # ffffffffc0205b68 <commands+0x910>
ffffffffc02016fc:	adbfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201700:	00004697          	auipc	a3,0x4
ffffffffc0201704:	58068693          	addi	a3,a3,1408 # ffffffffc0205c80 <commands+0xa28>
ffffffffc0201708:	00004617          	auipc	a2,0x4
ffffffffc020170c:	56060613          	addi	a2,a2,1376 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201710:	16100593          	li	a1,353
ffffffffc0201714:	00004517          	auipc	a0,0x4
ffffffffc0201718:	42450513          	addi	a0,a0,1060 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc020171c:	abbfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201720:	00004617          	auipc	a2,0x4
ffffffffc0201724:	62060613          	addi	a2,a2,1568 # ffffffffc0205d40 <commands+0xae8>
ffffffffc0201728:	07400593          	li	a1,116
ffffffffc020172c:	00004517          	auipc	a0,0x4
ffffffffc0201730:	43c50513          	addi	a0,a0,1084 # ffffffffc0205b68 <commands+0x910>
ffffffffc0201734:	aa3fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201738:	00004697          	auipc	a3,0x4
ffffffffc020173c:	5d868693          	addi	a3,a3,1496 # ffffffffc0205d10 <commands+0xab8>
ffffffffc0201740:	00004617          	auipc	a2,0x4
ffffffffc0201744:	52860613          	addi	a2,a2,1320 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201748:	16900593          	li	a1,361
ffffffffc020174c:	00004517          	auipc	a0,0x4
ffffffffc0201750:	3ec50513          	addi	a0,a0,1004 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201754:	a83fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201758:	86da                	mv	a3,s6
ffffffffc020175a:	00004617          	auipc	a2,0x4
ffffffffc020175e:	3b660613          	addi	a2,a2,950 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0201762:	16e00593          	li	a1,366
ffffffffc0201766:	00004517          	auipc	a0,0x4
ffffffffc020176a:	3d250513          	addi	a0,a0,978 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc020176e:	a69fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201772:	86be                	mv	a3,a5
ffffffffc0201774:	00004617          	auipc	a2,0x4
ffffffffc0201778:	39c60613          	addi	a2,a2,924 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc020177c:	16d00593          	li	a1,365
ffffffffc0201780:	00004517          	auipc	a0,0x4
ffffffffc0201784:	3b850513          	addi	a0,a0,952 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201788:	a4ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020178c:	00004697          	auipc	a3,0x4
ffffffffc0201790:	5f468693          	addi	a3,a3,1524 # ffffffffc0205d80 <commands+0xb28>
ffffffffc0201794:	00004617          	auipc	a2,0x4
ffffffffc0201798:	4d460613          	addi	a2,a2,1236 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020179c:	16b00593          	li	a1,363
ffffffffc02017a0:	00004517          	auipc	a0,0x4
ffffffffc02017a4:	39850513          	addi	a0,a0,920 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02017a8:	a2ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02017ac:	00004697          	auipc	a3,0x4
ffffffffc02017b0:	5bc68693          	addi	a3,a3,1468 # ffffffffc0205d68 <commands+0xb10>
ffffffffc02017b4:	00004617          	auipc	a2,0x4
ffffffffc02017b8:	4b460613          	addi	a2,a2,1204 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02017bc:	16a00593          	li	a1,362
ffffffffc02017c0:	00004517          	auipc	a0,0x4
ffffffffc02017c4:	37850513          	addi	a0,a0,888 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02017c8:	a0ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02017cc:	00004697          	auipc	a3,0x4
ffffffffc02017d0:	6ac68693          	addi	a3,a3,1708 # ffffffffc0205e78 <commands+0xc20>
ffffffffc02017d4:	00004617          	auipc	a2,0x4
ffffffffc02017d8:	49460613          	addi	a2,a2,1172 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02017dc:	17900593          	li	a1,377
ffffffffc02017e0:	00004517          	auipc	a0,0x4
ffffffffc02017e4:	35850513          	addi	a0,a0,856 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02017e8:	9effe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02017ec:	00004697          	auipc	a3,0x4
ffffffffc02017f0:	67468693          	addi	a3,a3,1652 # ffffffffc0205e60 <commands+0xc08>
ffffffffc02017f4:	00004617          	auipc	a2,0x4
ffffffffc02017f8:	47460613          	addi	a2,a2,1140 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02017fc:	17700593          	li	a1,375
ffffffffc0201800:	00004517          	auipc	a0,0x4
ffffffffc0201804:	33850513          	addi	a0,a0,824 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201808:	9cffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020180c:	00004697          	auipc	a3,0x4
ffffffffc0201810:	63c68693          	addi	a3,a3,1596 # ffffffffc0205e48 <commands+0xbf0>
ffffffffc0201814:	00004617          	auipc	a2,0x4
ffffffffc0201818:	45460613          	addi	a2,a2,1108 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020181c:	17600593          	li	a1,374
ffffffffc0201820:	00004517          	auipc	a0,0x4
ffffffffc0201824:	31850513          	addi	a0,a0,792 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201828:	9affe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020182c:	00004697          	auipc	a3,0x4
ffffffffc0201830:	60c68693          	addi	a3,a3,1548 # ffffffffc0205e38 <commands+0xbe0>
ffffffffc0201834:	00004617          	auipc	a2,0x4
ffffffffc0201838:	43460613          	addi	a2,a2,1076 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020183c:	17500593          	li	a1,373
ffffffffc0201840:	00004517          	auipc	a0,0x4
ffffffffc0201844:	2f850513          	addi	a0,a0,760 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201848:	98ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020184c:	00004697          	auipc	a3,0x4
ffffffffc0201850:	5dc68693          	addi	a3,a3,1500 # ffffffffc0205e28 <commands+0xbd0>
ffffffffc0201854:	00004617          	auipc	a2,0x4
ffffffffc0201858:	41460613          	addi	a2,a2,1044 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020185c:	17400593          	li	a1,372
ffffffffc0201860:	00004517          	auipc	a0,0x4
ffffffffc0201864:	2d850513          	addi	a0,a0,728 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201868:	96ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020186c:	00004697          	auipc	a3,0x4
ffffffffc0201870:	58c68693          	addi	a3,a3,1420 # ffffffffc0205df8 <commands+0xba0>
ffffffffc0201874:	00004617          	auipc	a2,0x4
ffffffffc0201878:	3f460613          	addi	a2,a2,1012 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020187c:	17300593          	li	a1,371
ffffffffc0201880:	00004517          	auipc	a0,0x4
ffffffffc0201884:	2b850513          	addi	a0,a0,696 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201888:	94ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020188c:	00004697          	auipc	a3,0x4
ffffffffc0201890:	53468693          	addi	a3,a3,1332 # ffffffffc0205dc0 <commands+0xb68>
ffffffffc0201894:	00004617          	auipc	a2,0x4
ffffffffc0201898:	3d460613          	addi	a2,a2,980 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020189c:	17200593          	li	a1,370
ffffffffc02018a0:	00004517          	auipc	a0,0x4
ffffffffc02018a4:	29850513          	addi	a0,a0,664 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02018a8:	92ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018ac:	00004697          	auipc	a3,0x4
ffffffffc02018b0:	4ec68693          	addi	a3,a3,1260 # ffffffffc0205d98 <commands+0xb40>
ffffffffc02018b4:	00004617          	auipc	a2,0x4
ffffffffc02018b8:	3b460613          	addi	a2,a2,948 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02018bc:	16f00593          	li	a1,367
ffffffffc02018c0:	00004517          	auipc	a0,0x4
ffffffffc02018c4:	27850513          	addi	a0,a0,632 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02018c8:	90ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02018cc:	00004697          	auipc	a3,0x4
ffffffffc02018d0:	62468693          	addi	a3,a3,1572 # ffffffffc0205ef0 <commands+0xc98>
ffffffffc02018d4:	00004617          	auipc	a2,0x4
ffffffffc02018d8:	39460613          	addi	a2,a2,916 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02018dc:	18500593          	li	a1,389
ffffffffc02018e0:	00004517          	auipc	a0,0x4
ffffffffc02018e4:	25850513          	addi	a0,a0,600 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02018e8:	8effe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02018ec:	00004697          	auipc	a3,0x4
ffffffffc02018f0:	5d468693          	addi	a3,a3,1492 # ffffffffc0205ec0 <commands+0xc68>
ffffffffc02018f4:	00004617          	auipc	a2,0x4
ffffffffc02018f8:	37460613          	addi	a2,a2,884 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02018fc:	18200593          	li	a1,386
ffffffffc0201900:	00004517          	auipc	a0,0x4
ffffffffc0201904:	23850513          	addi	a0,a0,568 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201908:	8cffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020190c:	00004697          	auipc	a3,0x4
ffffffffc0201910:	47468693          	addi	a3,a3,1140 # ffffffffc0205d80 <commands+0xb28>
ffffffffc0201914:	00004617          	auipc	a2,0x4
ffffffffc0201918:	35460613          	addi	a2,a2,852 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020191c:	18100593          	li	a1,385
ffffffffc0201920:	00004517          	auipc	a0,0x4
ffffffffc0201924:	21850513          	addi	a0,a0,536 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201928:	8affe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020192c:	00004697          	auipc	a3,0x4
ffffffffc0201930:	5ac68693          	addi	a3,a3,1452 # ffffffffc0205ed8 <commands+0xc80>
ffffffffc0201934:	00004617          	auipc	a2,0x4
ffffffffc0201938:	33460613          	addi	a2,a2,820 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020193c:	17e00593          	li	a1,382
ffffffffc0201940:	00004517          	auipc	a0,0x4
ffffffffc0201944:	1f850513          	addi	a0,a0,504 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201948:	88ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020194c:	00004697          	auipc	a3,0x4
ffffffffc0201950:	41c68693          	addi	a3,a3,1052 # ffffffffc0205d68 <commands+0xb10>
ffffffffc0201954:	00004617          	auipc	a2,0x4
ffffffffc0201958:	31460613          	addi	a2,a2,788 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020195c:	17d00593          	li	a1,381
ffffffffc0201960:	00004517          	auipc	a0,0x4
ffffffffc0201964:	1d850513          	addi	a0,a0,472 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201968:	86ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020196c:	00004697          	auipc	a3,0x4
ffffffffc0201970:	48c68693          	addi	a3,a3,1164 # ffffffffc0205df8 <commands+0xba0>
ffffffffc0201974:	00004617          	auipc	a2,0x4
ffffffffc0201978:	2f460613          	addi	a2,a2,756 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020197c:	17c00593          	li	a1,380
ffffffffc0201980:	00004517          	auipc	a0,0x4
ffffffffc0201984:	1b850513          	addi	a0,a0,440 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201988:	84ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020198c:	00004697          	auipc	a3,0x4
ffffffffc0201990:	53468693          	addi	a3,a3,1332 # ffffffffc0205ec0 <commands+0xc68>
ffffffffc0201994:	00004617          	auipc	a2,0x4
ffffffffc0201998:	2d460613          	addi	a2,a2,724 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020199c:	17b00593          	li	a1,379
ffffffffc02019a0:	00004517          	auipc	a0,0x4
ffffffffc02019a4:	19850513          	addi	a0,a0,408 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02019a8:	82ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02019ac:	00004697          	auipc	a3,0x4
ffffffffc02019b0:	4fc68693          	addi	a3,a3,1276 # ffffffffc0205ea8 <commands+0xc50>
ffffffffc02019b4:	00004617          	auipc	a2,0x4
ffffffffc02019b8:	2b460613          	addi	a2,a2,692 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02019bc:	17a00593          	li	a1,378
ffffffffc02019c0:	00004517          	auipc	a0,0x4
ffffffffc02019c4:	17850513          	addi	a0,a0,376 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02019c8:	80ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02019cc:	00004697          	auipc	a3,0x4
ffffffffc02019d0:	56468693          	addi	a3,a3,1380 # ffffffffc0205f30 <commands+0xcd8>
ffffffffc02019d4:	00004617          	auipc	a2,0x4
ffffffffc02019d8:	29460613          	addi	a2,a2,660 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02019dc:	19000593          	li	a1,400
ffffffffc02019e0:	00004517          	auipc	a0,0x4
ffffffffc02019e4:	15850513          	addi	a0,a0,344 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc02019e8:	feefe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02019ec:	00004697          	auipc	a3,0x4
ffffffffc02019f0:	25c68693          	addi	a3,a3,604 # ffffffffc0205c48 <commands+0x9f0>
ffffffffc02019f4:	00004617          	auipc	a2,0x4
ffffffffc02019f8:	27460613          	addi	a2,a2,628 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02019fc:	16000593          	li	a1,352
ffffffffc0201a00:	00004517          	auipc	a0,0x4
ffffffffc0201a04:	13850513          	addi	a0,a0,312 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201a08:	fcefe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201a0c:	00004697          	auipc	a3,0x4
ffffffffc0201a10:	5bc68693          	addi	a3,a3,1468 # ffffffffc0205fc8 <commands+0xd70>
ffffffffc0201a14:	00004617          	auipc	a2,0x4
ffffffffc0201a18:	25460613          	addi	a2,a2,596 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201a1c:	1a100593          	li	a1,417
ffffffffc0201a20:	00004517          	auipc	a0,0x4
ffffffffc0201a24:	11850513          	addi	a0,a0,280 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201a28:	faefe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201a2c:	00004617          	auipc	a2,0x4
ffffffffc0201a30:	1bc60613          	addi	a2,a2,444 # ffffffffc0205be8 <commands+0x990>
ffffffffc0201a34:	0c300593          	li	a1,195
ffffffffc0201a38:	00004517          	auipc	a0,0x4
ffffffffc0201a3c:	10050513          	addi	a0,a0,256 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201a40:	f96fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201a44:	00004697          	auipc	a3,0x4
ffffffffc0201a48:	62c68693          	addi	a3,a3,1580 # ffffffffc0206070 <commands+0xe18>
ffffffffc0201a4c:	00004617          	auipc	a2,0x4
ffffffffc0201a50:	21c60613          	addi	a2,a2,540 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201a54:	1a800593          	li	a1,424
ffffffffc0201a58:	00004517          	auipc	a0,0x4
ffffffffc0201a5c:	0e050513          	addi	a0,a0,224 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201a60:	f76fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201a64:	00004697          	auipc	a3,0x4
ffffffffc0201a68:	5cc68693          	addi	a3,a3,1484 # ffffffffc0206030 <commands+0xdd8>
ffffffffc0201a6c:	00004617          	auipc	a2,0x4
ffffffffc0201a70:	1fc60613          	addi	a2,a2,508 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201a74:	1a700593          	li	a1,423
ffffffffc0201a78:	00004517          	auipc	a0,0x4
ffffffffc0201a7c:	0c050513          	addi	a0,a0,192 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201a80:	f56fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201a84:	00004697          	auipc	a3,0x4
ffffffffc0201a88:	59468693          	addi	a3,a3,1428 # ffffffffc0206018 <commands+0xdc0>
ffffffffc0201a8c:	00004617          	auipc	a2,0x4
ffffffffc0201a90:	1dc60613          	addi	a2,a2,476 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201a94:	1a600593          	li	a1,422
ffffffffc0201a98:	00004517          	auipc	a0,0x4
ffffffffc0201a9c:	0a050513          	addi	a0,a0,160 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201aa0:	f36fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201aa4:	00004697          	auipc	a3,0x4
ffffffffc0201aa8:	53c68693          	addi	a3,a3,1340 # ffffffffc0205fe0 <commands+0xd88>
ffffffffc0201aac:	00004617          	auipc	a2,0x4
ffffffffc0201ab0:	1bc60613          	addi	a2,a2,444 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201ab4:	1a500593          	li	a1,421
ffffffffc0201ab8:	00004517          	auipc	a0,0x4
ffffffffc0201abc:	08050513          	addi	a0,a0,128 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201ac0:	f16fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201ac4:	00004697          	auipc	a3,0x4
ffffffffc0201ac8:	44468693          	addi	a3,a3,1092 # ffffffffc0205f08 <commands+0xcb0>
ffffffffc0201acc:	00004617          	auipc	a2,0x4
ffffffffc0201ad0:	19c60613          	addi	a2,a2,412 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201ad4:	18800593          	li	a1,392
ffffffffc0201ad8:	00004517          	auipc	a0,0x4
ffffffffc0201adc:	06050513          	addi	a0,a0,96 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201ae0:	ef6fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201ae4:	00004697          	auipc	a3,0x4
ffffffffc0201ae8:	3dc68693          	addi	a3,a3,988 # ffffffffc0205ec0 <commands+0xc68>
ffffffffc0201aec:	00004617          	auipc	a2,0x4
ffffffffc0201af0:	17c60613          	addi	a2,a2,380 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201af4:	18600593          	li	a1,390
ffffffffc0201af8:	00004517          	auipc	a0,0x4
ffffffffc0201afc:	04050513          	addi	a0,a0,64 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201b00:	ed6fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201b04:	00004697          	auipc	a3,0x4
ffffffffc0201b08:	1dc68693          	addi	a3,a3,476 # ffffffffc0205ce0 <commands+0xa88>
ffffffffc0201b0c:	00004617          	auipc	a2,0x4
ffffffffc0201b10:	15c60613          	addi	a2,a2,348 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201b14:	16600593          	li	a1,358
ffffffffc0201b18:	00004517          	auipc	a0,0x4
ffffffffc0201b1c:	02050513          	addi	a0,a0,32 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201b20:	eb6fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201b24:	00004697          	auipc	a3,0x4
ffffffffc0201b28:	19468693          	addi	a3,a3,404 # ffffffffc0205cb8 <commands+0xa60>
ffffffffc0201b2c:	00004617          	auipc	a2,0x4
ffffffffc0201b30:	13c60613          	addi	a2,a2,316 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201b34:	16200593          	li	a1,354
ffffffffc0201b38:	00004517          	auipc	a0,0x4
ffffffffc0201b3c:	00050513          	mv	a0,a0
ffffffffc0201b40:	e96fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201b44:	00004617          	auipc	a2,0x4
ffffffffc0201b48:	0a460613          	addi	a2,a2,164 # ffffffffc0205be8 <commands+0x990>
ffffffffc0201b4c:	07f00593          	li	a1,127
ffffffffc0201b50:	00004517          	auipc	a0,0x4
ffffffffc0201b54:	fe850513          	addi	a0,a0,-24 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201b58:	e7efe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201b5c:	00004697          	auipc	a3,0x4
ffffffffc0201b60:	3d468693          	addi	a3,a3,980 # ffffffffc0205f30 <commands+0xcd8>
ffffffffc0201b64:	00004617          	auipc	a2,0x4
ffffffffc0201b68:	10460613          	addi	a2,a2,260 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201b6c:	1b800593          	li	a1,440
ffffffffc0201b70:	00004517          	auipc	a0,0x4
ffffffffc0201b74:	fc850513          	addi	a0,a0,-56 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201b78:	e5efe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b7c:	00004697          	auipc	a3,0x4
ffffffffc0201b80:	55c68693          	addi	a3,a3,1372 # ffffffffc02060d8 <commands+0xe80>
ffffffffc0201b84:	00004617          	auipc	a2,0x4
ffffffffc0201b88:	0e460613          	addi	a2,a2,228 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201b8c:	1af00593          	li	a1,431
ffffffffc0201b90:	00004517          	auipc	a0,0x4
ffffffffc0201b94:	fa850513          	addi	a0,a0,-88 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201b98:	e3efe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201b9c:	00004697          	auipc	a3,0x4
ffffffffc0201ba0:	50468693          	addi	a3,a3,1284 # ffffffffc02060a0 <commands+0xe48>
ffffffffc0201ba4:	00004617          	auipc	a2,0x4
ffffffffc0201ba8:	0c460613          	addi	a2,a2,196 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201bac:	1ac00593          	li	a1,428
ffffffffc0201bb0:	00004517          	auipc	a0,0x4
ffffffffc0201bb4:	f8850513          	addi	a0,a0,-120 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201bb8:	e1efe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201bbc <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201bbc:	12058073          	sfence.vma	a1
}
ffffffffc0201bc0:	8082                	ret

ffffffffc0201bc2 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201bc2:	7179                	addi	sp,sp,-48
ffffffffc0201bc4:	e84a                	sd	s2,16(sp)
ffffffffc0201bc6:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201bc8:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201bca:	f022                	sd	s0,32(sp)
ffffffffc0201bcc:	ec26                	sd	s1,24(sp)
ffffffffc0201bce:	e44e                	sd	s3,8(sp)
ffffffffc0201bd0:	f406                	sd	ra,40(sp)
ffffffffc0201bd2:	84ae                	mv	s1,a1
ffffffffc0201bd4:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201bd6:	844ff0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc0201bda:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201bdc:	cd19                	beqz	a0,ffffffffc0201bfa <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201bde:	85aa                	mv	a1,a0
ffffffffc0201be0:	86ce                	mv	a3,s3
ffffffffc0201be2:	8626                	mv	a2,s1
ffffffffc0201be4:	854a                	mv	a0,s2
ffffffffc0201be6:	c22ff0ef          	jal	ra,ffffffffc0201008 <page_insert>
ffffffffc0201bea:	ed39                	bnez	a0,ffffffffc0201c48 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0201bec:	00015797          	auipc	a5,0x15
ffffffffc0201bf0:	8bc78793          	addi	a5,a5,-1860 # ffffffffc02164a8 <swap_init_ok>
ffffffffc0201bf4:	439c                	lw	a5,0(a5)
ffffffffc0201bf6:	2781                	sext.w	a5,a5
ffffffffc0201bf8:	eb89                	bnez	a5,ffffffffc0201c0a <pgdir_alloc_page+0x48>
}
ffffffffc0201bfa:	8522                	mv	a0,s0
ffffffffc0201bfc:	70a2                	ld	ra,40(sp)
ffffffffc0201bfe:	7402                	ld	s0,32(sp)
ffffffffc0201c00:	64e2                	ld	s1,24(sp)
ffffffffc0201c02:	6942                	ld	s2,16(sp)
ffffffffc0201c04:	69a2                	ld	s3,8(sp)
ffffffffc0201c06:	6145                	addi	sp,sp,48
ffffffffc0201c08:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201c0a:	00015797          	auipc	a5,0x15
ffffffffc0201c0e:	8f678793          	addi	a5,a5,-1802 # ffffffffc0216500 <check_mm_struct>
ffffffffc0201c12:	6388                	ld	a0,0(a5)
ffffffffc0201c14:	4681                	li	a3,0
ffffffffc0201c16:	8622                	mv	a2,s0
ffffffffc0201c18:	85a6                	mv	a1,s1
ffffffffc0201c1a:	00c010ef          	jal	ra,ffffffffc0202c26 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201c1e:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201c20:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0201c22:	4785                	li	a5,1
ffffffffc0201c24:	fcf70be3          	beq	a4,a5,ffffffffc0201bfa <pgdir_alloc_page+0x38>
ffffffffc0201c28:	00004697          	auipc	a3,0x4
ffffffffc0201c2c:	f5068693          	addi	a3,a3,-176 # ffffffffc0205b78 <commands+0x920>
ffffffffc0201c30:	00004617          	auipc	a2,0x4
ffffffffc0201c34:	03860613          	addi	a2,a2,56 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201c38:	14800593          	li	a1,328
ffffffffc0201c3c:	00004517          	auipc	a0,0x4
ffffffffc0201c40:	efc50513          	addi	a0,a0,-260 # ffffffffc0205b38 <commands+0x8e0>
ffffffffc0201c44:	d92fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
            free_page(page);
ffffffffc0201c48:	8522                	mv	a0,s0
ffffffffc0201c4a:	4585                	li	a1,1
ffffffffc0201c4c:	856ff0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
            return NULL;
ffffffffc0201c50:	4401                	li	s0,0
ffffffffc0201c52:	b765                	j	ffffffffc0201bfa <pgdir_alloc_page+0x38>

ffffffffc0201c54 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201c54:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201c56:	00004697          	auipc	a3,0x4
ffffffffc0201c5a:	4ca68693          	addi	a3,a3,1226 # ffffffffc0206120 <commands+0xec8>
ffffffffc0201c5e:	00004617          	auipc	a2,0x4
ffffffffc0201c62:	00a60613          	addi	a2,a2,10 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201c66:	07e00593          	li	a1,126
ffffffffc0201c6a:	00004517          	auipc	a0,0x4
ffffffffc0201c6e:	4d650513          	addi	a0,a0,1238 # ffffffffc0206140 <commands+0xee8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201c72:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201c74:	d62fe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201c78 <mm_create>:
mm_create(void) {
ffffffffc0201c78:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201c7a:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201c7e:	e022                	sd	s0,0(sp)
ffffffffc0201c80:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201c82:	3fe010ef          	jal	ra,ffffffffc0203080 <kmalloc>
ffffffffc0201c86:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201c88:	c115                	beqz	a0,ffffffffc0201cac <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201c8a:	00015797          	auipc	a5,0x15
ffffffffc0201c8e:	81e78793          	addi	a5,a5,-2018 # ffffffffc02164a8 <swap_init_ok>
ffffffffc0201c92:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201c94:	e408                	sd	a0,8(s0)
ffffffffc0201c96:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201c98:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201c9c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201ca0:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201ca4:	2781                	sext.w	a5,a5
ffffffffc0201ca6:	eb81                	bnez	a5,ffffffffc0201cb6 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0201ca8:	02053423          	sd	zero,40(a0)
}
ffffffffc0201cac:	8522                	mv	a0,s0
ffffffffc0201cae:	60a2                	ld	ra,8(sp)
ffffffffc0201cb0:	6402                	ld	s0,0(sp)
ffffffffc0201cb2:	0141                	addi	sp,sp,16
ffffffffc0201cb4:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201cb6:	761000ef          	jal	ra,ffffffffc0202c16 <swap_init_mm>
}
ffffffffc0201cba:	8522                	mv	a0,s0
ffffffffc0201cbc:	60a2                	ld	ra,8(sp)
ffffffffc0201cbe:	6402                	ld	s0,0(sp)
ffffffffc0201cc0:	0141                	addi	sp,sp,16
ffffffffc0201cc2:	8082                	ret

ffffffffc0201cc4 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201cc4:	1101                	addi	sp,sp,-32
ffffffffc0201cc6:	e04a                	sd	s2,0(sp)
ffffffffc0201cc8:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201cca:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201cce:	e822                	sd	s0,16(sp)
ffffffffc0201cd0:	e426                	sd	s1,8(sp)
ffffffffc0201cd2:	ec06                	sd	ra,24(sp)
ffffffffc0201cd4:	84ae                	mv	s1,a1
ffffffffc0201cd6:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201cd8:	3a8010ef          	jal	ra,ffffffffc0203080 <kmalloc>
    if (vma != NULL) {
ffffffffc0201cdc:	c509                	beqz	a0,ffffffffc0201ce6 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201cde:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201ce2:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201ce4:	cd00                	sw	s0,24(a0)
}
ffffffffc0201ce6:	60e2                	ld	ra,24(sp)
ffffffffc0201ce8:	6442                	ld	s0,16(sp)
ffffffffc0201cea:	64a2                	ld	s1,8(sp)
ffffffffc0201cec:	6902                	ld	s2,0(sp)
ffffffffc0201cee:	6105                	addi	sp,sp,32
ffffffffc0201cf0:	8082                	ret

ffffffffc0201cf2 <find_vma>:
    if (mm != NULL) {
ffffffffc0201cf2:	c51d                	beqz	a0,ffffffffc0201d20 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0201cf4:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201cf6:	c781                	beqz	a5,ffffffffc0201cfe <find_vma+0xc>
ffffffffc0201cf8:	6798                	ld	a4,8(a5)
ffffffffc0201cfa:	02e5f663          	bleu	a4,a1,ffffffffc0201d26 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0201cfe:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201d00:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201d02:	00f50f63          	beq	a0,a5,ffffffffc0201d20 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201d06:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201d0a:	fee5ebe3          	bltu	a1,a4,ffffffffc0201d00 <find_vma+0xe>
ffffffffc0201d0e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201d12:	fee5f7e3          	bleu	a4,a1,ffffffffc0201d00 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0201d16:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0201d18:	c781                	beqz	a5,ffffffffc0201d20 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0201d1a:	e91c                	sd	a5,16(a0)
}
ffffffffc0201d1c:	853e                	mv	a0,a5
ffffffffc0201d1e:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0201d20:	4781                	li	a5,0
}
ffffffffc0201d22:	853e                	mv	a0,a5
ffffffffc0201d24:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201d26:	6b98                	ld	a4,16(a5)
ffffffffc0201d28:	fce5fbe3          	bleu	a4,a1,ffffffffc0201cfe <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0201d2c:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0201d2e:	b7fd                	j	ffffffffc0201d1c <find_vma+0x2a>

ffffffffc0201d30 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201d30:	6590                	ld	a2,8(a1)
ffffffffc0201d32:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201d36:	1141                	addi	sp,sp,-16
ffffffffc0201d38:	e406                	sd	ra,8(sp)
ffffffffc0201d3a:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201d3c:	01066863          	bltu	a2,a6,ffffffffc0201d4c <insert_vma_struct+0x1c>
ffffffffc0201d40:	a8b9                	j	ffffffffc0201d9e <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201d42:	fe87b683          	ld	a3,-24(a5)
ffffffffc0201d46:	04d66763          	bltu	a2,a3,ffffffffc0201d94 <insert_vma_struct+0x64>
ffffffffc0201d4a:	873e                	mv	a4,a5
ffffffffc0201d4c:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0201d4e:	fef51ae3          	bne	a0,a5,ffffffffc0201d42 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201d52:	02a70463          	beq	a4,a0,ffffffffc0201d7a <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201d56:	ff073683          	ld	a3,-16(a4) # fffffffffff7fff0 <end+0x3fd699e8>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201d5a:	fe873883          	ld	a7,-24(a4)
ffffffffc0201d5e:	08d8f063          	bleu	a3,a7,ffffffffc0201dde <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201d62:	04d66e63          	bltu	a2,a3,ffffffffc0201dbe <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0201d66:	00f50a63          	beq	a0,a5,ffffffffc0201d7a <insert_vma_struct+0x4a>
ffffffffc0201d6a:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201d6e:	0506e863          	bltu	a3,a6,ffffffffc0201dbe <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0201d72:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201d76:	02c6f263          	bleu	a2,a3,ffffffffc0201d9a <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201d7a:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0201d7c:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201d7e:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201d82:	e390                	sd	a2,0(a5)
ffffffffc0201d84:	e710                	sd	a2,8(a4)
}
ffffffffc0201d86:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201d88:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201d8a:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0201d8c:	2685                	addiw	a3,a3,1
ffffffffc0201d8e:	d114                	sw	a3,32(a0)
}
ffffffffc0201d90:	0141                	addi	sp,sp,16
ffffffffc0201d92:	8082                	ret
    if (le_prev != list) {
ffffffffc0201d94:	fca711e3          	bne	a4,a0,ffffffffc0201d56 <insert_vma_struct+0x26>
ffffffffc0201d98:	bfd9                	j	ffffffffc0201d6e <insert_vma_struct+0x3e>
ffffffffc0201d9a:	ebbff0ef          	jal	ra,ffffffffc0201c54 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201d9e:	00004697          	auipc	a3,0x4
ffffffffc0201da2:	45268693          	addi	a3,a3,1106 # ffffffffc02061f0 <commands+0xf98>
ffffffffc0201da6:	00004617          	auipc	a2,0x4
ffffffffc0201daa:	ec260613          	addi	a2,a2,-318 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201dae:	08500593          	li	a1,133
ffffffffc0201db2:	00004517          	auipc	a0,0x4
ffffffffc0201db6:	38e50513          	addi	a0,a0,910 # ffffffffc0206140 <commands+0xee8>
ffffffffc0201dba:	c1cfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201dbe:	00004697          	auipc	a3,0x4
ffffffffc0201dc2:	47268693          	addi	a3,a3,1138 # ffffffffc0206230 <commands+0xfd8>
ffffffffc0201dc6:	00004617          	auipc	a2,0x4
ffffffffc0201dca:	ea260613          	addi	a2,a2,-350 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201dce:	07d00593          	li	a1,125
ffffffffc0201dd2:	00004517          	auipc	a0,0x4
ffffffffc0201dd6:	36e50513          	addi	a0,a0,878 # ffffffffc0206140 <commands+0xee8>
ffffffffc0201dda:	bfcfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201dde:	00004697          	auipc	a3,0x4
ffffffffc0201de2:	43268693          	addi	a3,a3,1074 # ffffffffc0206210 <commands+0xfb8>
ffffffffc0201de6:	00004617          	auipc	a2,0x4
ffffffffc0201dea:	e8260613          	addi	a2,a2,-382 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201dee:	07c00593          	li	a1,124
ffffffffc0201df2:	00004517          	auipc	a0,0x4
ffffffffc0201df6:	34e50513          	addi	a0,a0,846 # ffffffffc0206140 <commands+0xee8>
ffffffffc0201dfa:	bdcfe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201dfe <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201dfe:	1141                	addi	sp,sp,-16
ffffffffc0201e00:	e022                	sd	s0,0(sp)
ffffffffc0201e02:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201e04:	6508                	ld	a0,8(a0)
ffffffffc0201e06:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201e08:	00a40c63          	beq	s0,a0,ffffffffc0201e20 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201e0c:	6118                	ld	a4,0(a0)
ffffffffc0201e0e:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0201e10:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201e12:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201e14:	e398                	sd	a4,0(a5)
ffffffffc0201e16:	326010ef          	jal	ra,ffffffffc020313c <kfree>
    return listelm->next;
ffffffffc0201e1a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201e1c:	fea418e3          	bne	s0,a0,ffffffffc0201e0c <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0201e20:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201e22:	6402                	ld	s0,0(sp)
ffffffffc0201e24:	60a2                	ld	ra,8(sp)
ffffffffc0201e26:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0201e28:	3140106f          	j	ffffffffc020313c <kfree>

ffffffffc0201e2c <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201e2c:	7139                	addi	sp,sp,-64
ffffffffc0201e2e:	f822                	sd	s0,48(sp)
ffffffffc0201e30:	f426                	sd	s1,40(sp)
ffffffffc0201e32:	fc06                	sd	ra,56(sp)
ffffffffc0201e34:	f04a                	sd	s2,32(sp)
ffffffffc0201e36:	ec4e                	sd	s3,24(sp)
ffffffffc0201e38:	e852                	sd	s4,16(sp)
ffffffffc0201e3a:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0201e3c:	e3dff0ef          	jal	ra,ffffffffc0201c78 <mm_create>
    assert(mm != NULL);
ffffffffc0201e40:	842a                	mv	s0,a0
ffffffffc0201e42:	03200493          	li	s1,50
ffffffffc0201e46:	e919                	bnez	a0,ffffffffc0201e5c <vmm_init+0x30>
ffffffffc0201e48:	a98d                	j	ffffffffc02022ba <vmm_init+0x48e>
        vma->vm_start = vm_start;
ffffffffc0201e4a:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201e4c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201e4e:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201e52:	14ed                	addi	s1,s1,-5
ffffffffc0201e54:	8522                	mv	a0,s0
ffffffffc0201e56:	edbff0ef          	jal	ra,ffffffffc0201d30 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201e5a:	c88d                	beqz	s1,ffffffffc0201e8c <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201e5c:	03000513          	li	a0,48
ffffffffc0201e60:	220010ef          	jal	ra,ffffffffc0203080 <kmalloc>
ffffffffc0201e64:	85aa                	mv	a1,a0
ffffffffc0201e66:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201e6a:	f165                	bnez	a0,ffffffffc0201e4a <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0201e6c:	00004697          	auipc	a3,0x4
ffffffffc0201e70:	60c68693          	addi	a3,a3,1548 # ffffffffc0206478 <commands+0x1220>
ffffffffc0201e74:	00004617          	auipc	a2,0x4
ffffffffc0201e78:	df460613          	addi	a2,a2,-524 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201e7c:	0c900593          	li	a1,201
ffffffffc0201e80:	00004517          	auipc	a0,0x4
ffffffffc0201e84:	2c050513          	addi	a0,a0,704 # ffffffffc0206140 <commands+0xee8>
ffffffffc0201e88:	b4efe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201e8c:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201e90:	1f900913          	li	s2,505
ffffffffc0201e94:	a819                	j	ffffffffc0201eaa <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201e96:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201e98:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201e9a:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201e9e:	0495                	addi	s1,s1,5
ffffffffc0201ea0:	8522                	mv	a0,s0
ffffffffc0201ea2:	e8fff0ef          	jal	ra,ffffffffc0201d30 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201ea6:	03248a63          	beq	s1,s2,ffffffffc0201eda <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201eaa:	03000513          	li	a0,48
ffffffffc0201eae:	1d2010ef          	jal	ra,ffffffffc0203080 <kmalloc>
ffffffffc0201eb2:	85aa                	mv	a1,a0
ffffffffc0201eb4:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201eb8:	fd79                	bnez	a0,ffffffffc0201e96 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0201eba:	00004697          	auipc	a3,0x4
ffffffffc0201ebe:	5be68693          	addi	a3,a3,1470 # ffffffffc0206478 <commands+0x1220>
ffffffffc0201ec2:	00004617          	auipc	a2,0x4
ffffffffc0201ec6:	da660613          	addi	a2,a2,-602 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201eca:	0cf00593          	li	a1,207
ffffffffc0201ece:	00004517          	auipc	a0,0x4
ffffffffc0201ed2:	27250513          	addi	a0,a0,626 # ffffffffc0206140 <commands+0xee8>
ffffffffc0201ed6:	b00fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0201eda:	6418                	ld	a4,8(s0)
ffffffffc0201edc:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0201ede:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201ee2:	30e40063          	beq	s0,a4,ffffffffc02021e2 <vmm_init+0x3b6>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201ee6:	fe873603          	ld	a2,-24(a4)
ffffffffc0201eea:	ffe78693          	addi	a3,a5,-2
ffffffffc0201eee:	26d61a63          	bne	a2,a3,ffffffffc0202162 <vmm_init+0x336>
ffffffffc0201ef2:	ff073683          	ld	a3,-16(a4)
ffffffffc0201ef6:	26f69663          	bne	a3,a5,ffffffffc0202162 <vmm_init+0x336>
ffffffffc0201efa:	0795                	addi	a5,a5,5
ffffffffc0201efc:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0201efe:	feb792e3          	bne	a5,a1,ffffffffc0201ee2 <vmm_init+0xb6>
ffffffffc0201f02:	491d                	li	s2,7
ffffffffc0201f04:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201f06:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201f0a:	85a6                	mv	a1,s1
ffffffffc0201f0c:	8522                	mv	a0,s0
ffffffffc0201f0e:	de5ff0ef          	jal	ra,ffffffffc0201cf2 <find_vma>
ffffffffc0201f12:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0201f14:	32050763          	beqz	a0,ffffffffc0202242 <vmm_init+0x416>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201f18:	00148593          	addi	a1,s1,1
ffffffffc0201f1c:	8522                	mv	a0,s0
ffffffffc0201f1e:	dd5ff0ef          	jal	ra,ffffffffc0201cf2 <find_vma>
ffffffffc0201f22:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0201f24:	2e050f63          	beqz	a0,ffffffffc0202222 <vmm_init+0x3f6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201f28:	85ca                	mv	a1,s2
ffffffffc0201f2a:	8522                	mv	a0,s0
ffffffffc0201f2c:	dc7ff0ef          	jal	ra,ffffffffc0201cf2 <find_vma>
        assert(vma3 == NULL);
ffffffffc0201f30:	2c051963          	bnez	a0,ffffffffc0202202 <vmm_init+0x3d6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201f34:	00348593          	addi	a1,s1,3
ffffffffc0201f38:	8522                	mv	a0,s0
ffffffffc0201f3a:	db9ff0ef          	jal	ra,ffffffffc0201cf2 <find_vma>
        assert(vma4 == NULL);
ffffffffc0201f3e:	34051263          	bnez	a0,ffffffffc0202282 <vmm_init+0x456>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201f42:	00448593          	addi	a1,s1,4
ffffffffc0201f46:	8522                	mv	a0,s0
ffffffffc0201f48:	dabff0ef          	jal	ra,ffffffffc0201cf2 <find_vma>
        assert(vma5 == NULL);
ffffffffc0201f4c:	30051b63          	bnez	a0,ffffffffc0202262 <vmm_init+0x436>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201f50:	008a3783          	ld	a5,8(s4)
ffffffffc0201f54:	22979763          	bne	a5,s1,ffffffffc0202182 <vmm_init+0x356>
ffffffffc0201f58:	010a3783          	ld	a5,16(s4)
ffffffffc0201f5c:	23279363          	bne	a5,s2,ffffffffc0202182 <vmm_init+0x356>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201f60:	0089b783          	ld	a5,8(s3) # fffffffffff80008 <end+0x3fd69a00>
ffffffffc0201f64:	22979f63          	bne	a5,s1,ffffffffc02021a2 <vmm_init+0x376>
ffffffffc0201f68:	0109b783          	ld	a5,16(s3)
ffffffffc0201f6c:	23279b63          	bne	a5,s2,ffffffffc02021a2 <vmm_init+0x376>
ffffffffc0201f70:	0495                	addi	s1,s1,5
ffffffffc0201f72:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201f74:	f9549be3          	bne	s1,s5,ffffffffc0201f0a <vmm_init+0xde>
ffffffffc0201f78:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201f7a:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201f7c:	85a6                	mv	a1,s1
ffffffffc0201f7e:	8522                	mv	a0,s0
ffffffffc0201f80:	d73ff0ef          	jal	ra,ffffffffc0201cf2 <find_vma>
ffffffffc0201f84:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201f88:	c90d                	beqz	a0,ffffffffc0201fba <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201f8a:	6914                	ld	a3,16(a0)
ffffffffc0201f8c:	6510                	ld	a2,8(a0)
ffffffffc0201f8e:	00004517          	auipc	a0,0x4
ffffffffc0201f92:	3d250513          	addi	a0,a0,978 # ffffffffc0206360 <commands+0x1108>
ffffffffc0201f96:	93afe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201f9a:	00004697          	auipc	a3,0x4
ffffffffc0201f9e:	3ee68693          	addi	a3,a3,1006 # ffffffffc0206388 <commands+0x1130>
ffffffffc0201fa2:	00004617          	auipc	a2,0x4
ffffffffc0201fa6:	cc660613          	addi	a2,a2,-826 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0201faa:	0f100593          	li	a1,241
ffffffffc0201fae:	00004517          	auipc	a0,0x4
ffffffffc0201fb2:	19250513          	addi	a0,a0,402 # ffffffffc0206140 <commands+0xee8>
ffffffffc0201fb6:	a20fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0201fba:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0201fbc:	fd2490e3          	bne	s1,s2,ffffffffc0201f7c <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0201fc0:	8522                	mv	a0,s0
ffffffffc0201fc2:	e3dff0ef          	jal	ra,ffffffffc0201dfe <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201fc6:	00004517          	auipc	a0,0x4
ffffffffc0201fca:	3da50513          	addi	a0,a0,986 # ffffffffc02063a0 <commands+0x1148>
ffffffffc0201fce:	902fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201fd2:	d17fe0ef          	jal	ra,ffffffffc0200ce8 <nr_free_pages>
ffffffffc0201fd6:	8a2a                	mv	s4,a0

    check_mm_struct = mm_create();
ffffffffc0201fd8:	ca1ff0ef          	jal	ra,ffffffffc0201c78 <mm_create>
ffffffffc0201fdc:	00014797          	auipc	a5,0x14
ffffffffc0201fe0:	52a7b223          	sd	a0,1316(a5) # ffffffffc0216500 <check_mm_struct>
ffffffffc0201fe4:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0201fe6:	38050663          	beqz	a0,ffffffffc0202372 <vmm_init+0x546>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201fea:	00014797          	auipc	a5,0x14
ffffffffc0201fee:	49e78793          	addi	a5,a5,1182 # ffffffffc0216488 <boot_pgdir>
ffffffffc0201ff2:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0201ff6:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201ffa:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0201ffe:	2e079e63          	bnez	a5,ffffffffc02022fa <vmm_init+0x4ce>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202002:	03000513          	li	a0,48
ffffffffc0202006:	07a010ef          	jal	ra,ffffffffc0203080 <kmalloc>
ffffffffc020200a:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc020200c:	1a050b63          	beqz	a0,ffffffffc02021c2 <vmm_init+0x396>
        vma->vm_end = vm_end;
ffffffffc0202010:	002007b7          	lui	a5,0x200
ffffffffc0202014:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0202016:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202018:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020201a:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc020201c:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc020201e:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202022:	d0fff0ef          	jal	ra,ffffffffc0201d30 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202026:	10000593          	li	a1,256
ffffffffc020202a:	8526                	mv	a0,s1
ffffffffc020202c:	cc7ff0ef          	jal	ra,ffffffffc0201cf2 <find_vma>
ffffffffc0202030:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0202034:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202038:	2ea41163          	bne	s0,a0,ffffffffc020231a <vmm_init+0x4ee>
        *(char *)(addr + i) = i;
ffffffffc020203c:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0202040:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0202042:	fee79de3          	bne	a5,a4,ffffffffc020203c <vmm_init+0x210>
        sum += i;
ffffffffc0202046:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0202048:	10000793          	li	a5,256
        sum += i;
ffffffffc020204c:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202050:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202054:	0007c683          	lbu	a3,0(a5)
ffffffffc0202058:	0785                	addi	a5,a5,1
ffffffffc020205a:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020205c:	fec79ce3          	bne	a5,a2,ffffffffc0202054 <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0202060:	2e071963          	bnez	a4,ffffffffc0202352 <vmm_init+0x526>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202064:	00093683          	ld	a3,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202068:	00014a97          	auipc	s5,0x14
ffffffffc020206c:	428a8a93          	addi	s5,s5,1064 # ffffffffc0216490 <npage>
ffffffffc0202070:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202074:	068a                	slli	a3,a3,0x2
ffffffffc0202076:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202078:	22e6f563          	bleu	a4,a3,ffffffffc02022a2 <vmm_init+0x476>
    return &pages[PPN(pa) - nbase];
ffffffffc020207c:	00005797          	auipc	a5,0x5
ffffffffc0202080:	1e478793          	addi	a5,a5,484 # ffffffffc0207260 <nbase>
ffffffffc0202084:	0007b983          	ld	s3,0(a5)
ffffffffc0202088:	413687b3          	sub	a5,a3,s3
ffffffffc020208c:	00379693          	slli	a3,a5,0x3
ffffffffc0202090:	96be                	add	a3,a3,a5
    return page - pages + nbase;
ffffffffc0202092:	00004797          	auipc	a5,0x4
ffffffffc0202096:	a7678793          	addi	a5,a5,-1418 # ffffffffc0205b08 <commands+0x8b0>
ffffffffc020209a:	639c                	ld	a5,0(a5)
    return &pages[PPN(pa) - nbase];
ffffffffc020209c:	068e                	slli	a3,a3,0x3
    return page - pages + nbase;
ffffffffc020209e:	868d                	srai	a3,a3,0x3
ffffffffc02020a0:	02f686b3          	mul	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02020a4:	57fd                	li	a5,-1
ffffffffc02020a6:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc02020a8:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc02020aa:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02020ac:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02020ae:	28e7f663          	bleu	a4,a5,ffffffffc020233a <vmm_init+0x50e>
ffffffffc02020b2:	00014797          	auipc	a5,0x14
ffffffffc02020b6:	43678793          	addi	a5,a5,1078 # ffffffffc02164e8 <va_pa_offset>
ffffffffc02020ba:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02020bc:	4581                	li	a1,0
ffffffffc02020be:	854a                	mv	a0,s2
ffffffffc02020c0:	9436                	add	s0,s0,a3
ffffffffc02020c2:	ecdfe0ef          	jal	ra,ffffffffc0200f8e <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02020c6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02020c8:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020cc:	078a                	slli	a5,a5,0x2
ffffffffc02020ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020d0:	1ce7f963          	bleu	a4,a5,ffffffffc02022a2 <vmm_init+0x476>
    return &pages[PPN(pa) - nbase];
ffffffffc02020d4:	413787b3          	sub	a5,a5,s3
ffffffffc02020d8:	00014417          	auipc	s0,0x14
ffffffffc02020dc:	42040413          	addi	s0,s0,1056 # ffffffffc02164f8 <pages>
ffffffffc02020e0:	00379713          	slli	a4,a5,0x3
ffffffffc02020e4:	6008                	ld	a0,0(s0)
ffffffffc02020e6:	97ba                	add	a5,a5,a4
ffffffffc02020e8:	078e                	slli	a5,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc02020ea:	953e                	add	a0,a0,a5
ffffffffc02020ec:	4585                	li	a1,1
ffffffffc02020ee:	bb5fe0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02020f2:	00093503          	ld	a0,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02020f6:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020fa:	050a                	slli	a0,a0,0x2
ffffffffc02020fc:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020fe:	1af57263          	bleu	a5,a0,ffffffffc02022a2 <vmm_init+0x476>
    return &pages[PPN(pa) - nbase];
ffffffffc0202102:	413509b3          	sub	s3,a0,s3
ffffffffc0202106:	00399793          	slli	a5,s3,0x3
ffffffffc020210a:	6008                	ld	a0,0(s0)
ffffffffc020210c:	99be                	add	s3,s3,a5
ffffffffc020210e:	098e                	slli	s3,s3,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202110:	4585                	li	a1,1
ffffffffc0202112:	954e                	add	a0,a0,s3
ffffffffc0202114:	b8ffe0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    pgdir[0] = 0;
ffffffffc0202118:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc020211c:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0202120:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0202124:	8526                	mv	a0,s1
ffffffffc0202126:	cd9ff0ef          	jal	ra,ffffffffc0201dfe <mm_destroy>
    check_mm_struct = NULL;
ffffffffc020212a:	00014797          	auipc	a5,0x14
ffffffffc020212e:	3c07bb23          	sd	zero,982(a5) # ffffffffc0216500 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202132:	bb7fe0ef          	jal	ra,ffffffffc0200ce8 <nr_free_pages>
ffffffffc0202136:	1aaa1263          	bne	s4,a0,ffffffffc02022da <vmm_init+0x4ae>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020213a:	00004517          	auipc	a0,0x4
ffffffffc020213e:	30650513          	addi	a0,a0,774 # ffffffffc0206440 <commands+0x11e8>
ffffffffc0202142:	f8ffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202146:	7442                	ld	s0,48(sp)
ffffffffc0202148:	70e2                	ld	ra,56(sp)
ffffffffc020214a:	74a2                	ld	s1,40(sp)
ffffffffc020214c:	7902                	ld	s2,32(sp)
ffffffffc020214e:	69e2                	ld	s3,24(sp)
ffffffffc0202150:	6a42                	ld	s4,16(sp)
ffffffffc0202152:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202154:	00004517          	auipc	a0,0x4
ffffffffc0202158:	30c50513          	addi	a0,a0,780 # ffffffffc0206460 <commands+0x1208>
}
ffffffffc020215c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020215e:	f73fd06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202162:	00004697          	auipc	a3,0x4
ffffffffc0202166:	11668693          	addi	a3,a3,278 # ffffffffc0206278 <commands+0x1020>
ffffffffc020216a:	00004617          	auipc	a2,0x4
ffffffffc020216e:	afe60613          	addi	a2,a2,-1282 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202172:	0d800593          	li	a1,216
ffffffffc0202176:	00004517          	auipc	a0,0x4
ffffffffc020217a:	fca50513          	addi	a0,a0,-54 # ffffffffc0206140 <commands+0xee8>
ffffffffc020217e:	858fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202182:	00004697          	auipc	a3,0x4
ffffffffc0202186:	17e68693          	addi	a3,a3,382 # ffffffffc0206300 <commands+0x10a8>
ffffffffc020218a:	00004617          	auipc	a2,0x4
ffffffffc020218e:	ade60613          	addi	a2,a2,-1314 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202192:	0e800593          	li	a1,232
ffffffffc0202196:	00004517          	auipc	a0,0x4
ffffffffc020219a:	faa50513          	addi	a0,a0,-86 # ffffffffc0206140 <commands+0xee8>
ffffffffc020219e:	838fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02021a2:	00004697          	auipc	a3,0x4
ffffffffc02021a6:	18e68693          	addi	a3,a3,398 # ffffffffc0206330 <commands+0x10d8>
ffffffffc02021aa:	00004617          	auipc	a2,0x4
ffffffffc02021ae:	abe60613          	addi	a2,a2,-1346 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02021b2:	0e900593          	li	a1,233
ffffffffc02021b6:	00004517          	auipc	a0,0x4
ffffffffc02021ba:	f8a50513          	addi	a0,a0,-118 # ffffffffc0206140 <commands+0xee8>
ffffffffc02021be:	818fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(vma != NULL);
ffffffffc02021c2:	00004697          	auipc	a3,0x4
ffffffffc02021c6:	2b668693          	addi	a3,a3,694 # ffffffffc0206478 <commands+0x1220>
ffffffffc02021ca:	00004617          	auipc	a2,0x4
ffffffffc02021ce:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02021d2:	10800593          	li	a1,264
ffffffffc02021d6:	00004517          	auipc	a0,0x4
ffffffffc02021da:	f6a50513          	addi	a0,a0,-150 # ffffffffc0206140 <commands+0xee8>
ffffffffc02021de:	ff9fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02021e2:	00004697          	auipc	a3,0x4
ffffffffc02021e6:	07e68693          	addi	a3,a3,126 # ffffffffc0206260 <commands+0x1008>
ffffffffc02021ea:	00004617          	auipc	a2,0x4
ffffffffc02021ee:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02021f2:	0d600593          	li	a1,214
ffffffffc02021f6:	00004517          	auipc	a0,0x4
ffffffffc02021fa:	f4a50513          	addi	a0,a0,-182 # ffffffffc0206140 <commands+0xee8>
ffffffffc02021fe:	fd9fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma3 == NULL);
ffffffffc0202202:	00004697          	auipc	a3,0x4
ffffffffc0202206:	0ce68693          	addi	a3,a3,206 # ffffffffc02062d0 <commands+0x1078>
ffffffffc020220a:	00004617          	auipc	a2,0x4
ffffffffc020220e:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202212:	0e200593          	li	a1,226
ffffffffc0202216:	00004517          	auipc	a0,0x4
ffffffffc020221a:	f2a50513          	addi	a0,a0,-214 # ffffffffc0206140 <commands+0xee8>
ffffffffc020221e:	fb9fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma2 != NULL);
ffffffffc0202222:	00004697          	auipc	a3,0x4
ffffffffc0202226:	09e68693          	addi	a3,a3,158 # ffffffffc02062c0 <commands+0x1068>
ffffffffc020222a:	00004617          	auipc	a2,0x4
ffffffffc020222e:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202232:	0e000593          	li	a1,224
ffffffffc0202236:	00004517          	auipc	a0,0x4
ffffffffc020223a:	f0a50513          	addi	a0,a0,-246 # ffffffffc0206140 <commands+0xee8>
ffffffffc020223e:	f99fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma1 != NULL);
ffffffffc0202242:	00004697          	auipc	a3,0x4
ffffffffc0202246:	06e68693          	addi	a3,a3,110 # ffffffffc02062b0 <commands+0x1058>
ffffffffc020224a:	00004617          	auipc	a2,0x4
ffffffffc020224e:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202252:	0de00593          	li	a1,222
ffffffffc0202256:	00004517          	auipc	a0,0x4
ffffffffc020225a:	eea50513          	addi	a0,a0,-278 # ffffffffc0206140 <commands+0xee8>
ffffffffc020225e:	f79fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma5 == NULL);
ffffffffc0202262:	00004697          	auipc	a3,0x4
ffffffffc0202266:	08e68693          	addi	a3,a3,142 # ffffffffc02062f0 <commands+0x1098>
ffffffffc020226a:	00004617          	auipc	a2,0x4
ffffffffc020226e:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202272:	0e600593          	li	a1,230
ffffffffc0202276:	00004517          	auipc	a0,0x4
ffffffffc020227a:	eca50513          	addi	a0,a0,-310 # ffffffffc0206140 <commands+0xee8>
ffffffffc020227e:	f59fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma4 == NULL);
ffffffffc0202282:	00004697          	auipc	a3,0x4
ffffffffc0202286:	05e68693          	addi	a3,a3,94 # ffffffffc02062e0 <commands+0x1088>
ffffffffc020228a:	00004617          	auipc	a2,0x4
ffffffffc020228e:	9de60613          	addi	a2,a2,-1570 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202292:	0e400593          	li	a1,228
ffffffffc0202296:	00004517          	auipc	a0,0x4
ffffffffc020229a:	eaa50513          	addi	a0,a0,-342 # ffffffffc0206140 <commands+0xee8>
ffffffffc020229e:	f39fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02022a2:	00004617          	auipc	a2,0x4
ffffffffc02022a6:	8a660613          	addi	a2,a2,-1882 # ffffffffc0205b48 <commands+0x8f0>
ffffffffc02022aa:	06200593          	li	a1,98
ffffffffc02022ae:	00004517          	auipc	a0,0x4
ffffffffc02022b2:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0205b68 <commands+0x910>
ffffffffc02022b6:	f21fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(mm != NULL);
ffffffffc02022ba:	00004697          	auipc	a3,0x4
ffffffffc02022be:	f9668693          	addi	a3,a3,-106 # ffffffffc0206250 <commands+0xff8>
ffffffffc02022c2:	00004617          	auipc	a2,0x4
ffffffffc02022c6:	9a660613          	addi	a2,a2,-1626 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02022ca:	0c200593          	li	a1,194
ffffffffc02022ce:	00004517          	auipc	a0,0x4
ffffffffc02022d2:	e7250513          	addi	a0,a0,-398 # ffffffffc0206140 <commands+0xee8>
ffffffffc02022d6:	f01fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02022da:	00004697          	auipc	a3,0x4
ffffffffc02022de:	13e68693          	addi	a3,a3,318 # ffffffffc0206418 <commands+0x11c0>
ffffffffc02022e2:	00004617          	auipc	a2,0x4
ffffffffc02022e6:	98660613          	addi	a2,a2,-1658 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02022ea:	12400593          	li	a1,292
ffffffffc02022ee:	00004517          	auipc	a0,0x4
ffffffffc02022f2:	e5250513          	addi	a0,a0,-430 # ffffffffc0206140 <commands+0xee8>
ffffffffc02022f6:	ee1fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02022fa:	00004697          	auipc	a3,0x4
ffffffffc02022fe:	0de68693          	addi	a3,a3,222 # ffffffffc02063d8 <commands+0x1180>
ffffffffc0202302:	00004617          	auipc	a2,0x4
ffffffffc0202306:	96660613          	addi	a2,a2,-1690 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020230a:	10500593          	li	a1,261
ffffffffc020230e:	00004517          	auipc	a0,0x4
ffffffffc0202312:	e3250513          	addi	a0,a0,-462 # ffffffffc0206140 <commands+0xee8>
ffffffffc0202316:	ec1fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020231a:	00004697          	auipc	a3,0x4
ffffffffc020231e:	0ce68693          	addi	a3,a3,206 # ffffffffc02063e8 <commands+0x1190>
ffffffffc0202322:	00004617          	auipc	a2,0x4
ffffffffc0202326:	94660613          	addi	a2,a2,-1722 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020232a:	10d00593          	li	a1,269
ffffffffc020232e:	00004517          	auipc	a0,0x4
ffffffffc0202332:	e1250513          	addi	a0,a0,-494 # ffffffffc0206140 <commands+0xee8>
ffffffffc0202336:	ea1fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc020233a:	00003617          	auipc	a2,0x3
ffffffffc020233e:	7d660613          	addi	a2,a2,2006 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0202342:	06900593          	li	a1,105
ffffffffc0202346:	00004517          	auipc	a0,0x4
ffffffffc020234a:	82250513          	addi	a0,a0,-2014 # ffffffffc0205b68 <commands+0x910>
ffffffffc020234e:	e89fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(sum == 0);
ffffffffc0202352:	00004697          	auipc	a3,0x4
ffffffffc0202356:	0b668693          	addi	a3,a3,182 # ffffffffc0206408 <commands+0x11b0>
ffffffffc020235a:	00004617          	auipc	a2,0x4
ffffffffc020235e:	90e60613          	addi	a2,a2,-1778 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202362:	11700593          	li	a1,279
ffffffffc0202366:	00004517          	auipc	a0,0x4
ffffffffc020236a:	dda50513          	addi	a0,a0,-550 # ffffffffc0206140 <commands+0xee8>
ffffffffc020236e:	e69fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202372:	00004697          	auipc	a3,0x4
ffffffffc0202376:	04e68693          	addi	a3,a3,78 # ffffffffc02063c0 <commands+0x1168>
ffffffffc020237a:	00004617          	auipc	a2,0x4
ffffffffc020237e:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202382:	10100593          	li	a1,257
ffffffffc0202386:	00004517          	auipc	a0,0x4
ffffffffc020238a:	dba50513          	addi	a0,a0,-582 # ffffffffc0206140 <commands+0xee8>
ffffffffc020238e:	e49fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202392 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202392:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202394:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202396:	f022                	sd	s0,32(sp)
ffffffffc0202398:	ec26                	sd	s1,24(sp)
ffffffffc020239a:	f406                	sd	ra,40(sp)
ffffffffc020239c:	e84a                	sd	s2,16(sp)
ffffffffc020239e:	8432                	mv	s0,a2
ffffffffc02023a0:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02023a2:	951ff0ef          	jal	ra,ffffffffc0201cf2 <find_vma>

    pgfault_num++;
ffffffffc02023a6:	00014797          	auipc	a5,0x14
ffffffffc02023aa:	0f278793          	addi	a5,a5,242 # ffffffffc0216498 <pgfault_num>
ffffffffc02023ae:	439c                	lw	a5,0(a5)
ffffffffc02023b0:	2785                	addiw	a5,a5,1
ffffffffc02023b2:	00014717          	auipc	a4,0x14
ffffffffc02023b6:	0ef72323          	sw	a5,230(a4) # ffffffffc0216498 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02023ba:	c551                	beqz	a0,ffffffffc0202446 <do_pgfault+0xb4>
ffffffffc02023bc:	651c                	ld	a5,8(a0)
ffffffffc02023be:	08f46463          	bltu	s0,a5,ffffffffc0202446 <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02023c2:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02023c4:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02023c6:	8b89                	andi	a5,a5,2
ffffffffc02023c8:	efb1                	bnez	a5,ffffffffc0202424 <do_pgfault+0x92>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02023ca:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02023cc:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02023ce:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02023d0:	85a2                	mv	a1,s0
ffffffffc02023d2:	4605                	li	a2,1
ffffffffc02023d4:	955fe0ef          	jal	ra,ffffffffc0200d28 <get_pte>
ffffffffc02023d8:	c941                	beqz	a0,ffffffffc0202468 <do_pgfault+0xd6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02023da:	610c                	ld	a1,0(a0)
ffffffffc02023dc:	c5b1                	beqz	a1,ffffffffc0202428 <do_pgfault+0x96>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02023de:	00014797          	auipc	a5,0x14
ffffffffc02023e2:	0ca78793          	addi	a5,a5,202 # ffffffffc02164a8 <swap_init_ok>
ffffffffc02023e6:	439c                	lw	a5,0(a5)
ffffffffc02023e8:	2781                	sext.w	a5,a5
ffffffffc02023ea:	c7bd                	beqz	a5,ffffffffc0202458 <do_pgfault+0xc6>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc02023ec:	85a2                	mv	a1,s0
ffffffffc02023ee:	0030                	addi	a2,sp,8
ffffffffc02023f0:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02023f2:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc02023f4:	157000ef          	jal	ra,ffffffffc0202d4a <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc02023f8:	65a2                	ld	a1,8(sp)
ffffffffc02023fa:	6c88                	ld	a0,24(s1)
ffffffffc02023fc:	86ca                	mv	a3,s2
ffffffffc02023fe:	8622                	mv	a2,s0
ffffffffc0202400:	c09fe0ef          	jal	ra,ffffffffc0201008 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0202404:	6622                	ld	a2,8(sp)
ffffffffc0202406:	4685                	li	a3,1
ffffffffc0202408:	85a2                	mv	a1,s0
ffffffffc020240a:	8526                	mv	a0,s1
ffffffffc020240c:	01b000ef          	jal	ra,ffffffffc0202c26 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0202410:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0202412:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0202414:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc0202416:	70a2                	ld	ra,40(sp)
ffffffffc0202418:	7402                	ld	s0,32(sp)
ffffffffc020241a:	64e2                	ld	s1,24(sp)
ffffffffc020241c:	6942                	ld	s2,16(sp)
ffffffffc020241e:	853e                	mv	a0,a5
ffffffffc0202420:	6145                	addi	sp,sp,48
ffffffffc0202422:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0202424:	495d                	li	s2,23
ffffffffc0202426:	b755                	j	ffffffffc02023ca <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202428:	6c88                	ld	a0,24(s1)
ffffffffc020242a:	864a                	mv	a2,s2
ffffffffc020242c:	85a2                	mv	a1,s0
ffffffffc020242e:	f94ff0ef          	jal	ra,ffffffffc0201bc2 <pgdir_alloc_page>
   ret = 0;
ffffffffc0202432:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202434:	f16d                	bnez	a0,ffffffffc0202416 <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202436:	00004517          	auipc	a0,0x4
ffffffffc020243a:	d6a50513          	addi	a0,a0,-662 # ffffffffc02061a0 <commands+0xf48>
ffffffffc020243e:	c93fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202442:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202444:	bfc9                	j	ffffffffc0202416 <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202446:	85a2                	mv	a1,s0
ffffffffc0202448:	00004517          	auipc	a0,0x4
ffffffffc020244c:	d0850513          	addi	a0,a0,-760 # ffffffffc0206150 <commands+0xef8>
ffffffffc0202450:	c81fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202454:	57f5                	li	a5,-3
        goto failed;
ffffffffc0202456:	b7c1                	j	ffffffffc0202416 <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202458:	00004517          	auipc	a0,0x4
ffffffffc020245c:	d7050513          	addi	a0,a0,-656 # ffffffffc02061c8 <commands+0xf70>
ffffffffc0202460:	c71fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202464:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202466:	bf45                	j	ffffffffc0202416 <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202468:	00004517          	auipc	a0,0x4
ffffffffc020246c:	d1850513          	addi	a0,a0,-744 # ffffffffc0206180 <commands+0xf28>
ffffffffc0202470:	c61fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202474:	57f1                	li	a5,-4
        goto failed;
ffffffffc0202476:	b745                	j	ffffffffc0202416 <do_pgfault+0x84>

ffffffffc0202478 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202478:	7135                	addi	sp,sp,-160
ffffffffc020247a:	ed06                	sd	ra,152(sp)
ffffffffc020247c:	e922                	sd	s0,144(sp)
ffffffffc020247e:	e526                	sd	s1,136(sp)
ffffffffc0202480:	e14a                	sd	s2,128(sp)
ffffffffc0202482:	fcce                	sd	s3,120(sp)
ffffffffc0202484:	f8d2                	sd	s4,112(sp)
ffffffffc0202486:	f4d6                	sd	s5,104(sp)
ffffffffc0202488:	f0da                	sd	s6,96(sp)
ffffffffc020248a:	ecde                	sd	s7,88(sp)
ffffffffc020248c:	e8e2                	sd	s8,80(sp)
ffffffffc020248e:	e4e6                	sd	s9,72(sp)
ffffffffc0202490:	e0ea                	sd	s10,64(sp)
ffffffffc0202492:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202494:	52f010ef          	jal	ra,ffffffffc02041c2 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202498:	00014797          	auipc	a5,0x14
ffffffffc020249c:	0f878793          	addi	a5,a5,248 # ffffffffc0216590 <max_swap_offset>
ffffffffc02024a0:	6394                	ld	a3,0(a5)
ffffffffc02024a2:	010007b7          	lui	a5,0x1000
ffffffffc02024a6:	17e1                	addi	a5,a5,-8
ffffffffc02024a8:	ff968713          	addi	a4,a3,-7
ffffffffc02024ac:	4ce7ed63          	bltu	a5,a4,ffffffffc0202986 <swap_init+0x50e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc02024b0:	00009797          	auipc	a5,0x9
ffffffffc02024b4:	b6078793          	addi	a5,a5,-1184 # ffffffffc020b010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02024b8:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02024ba:	00014697          	auipc	a3,0x14
ffffffffc02024be:	fef6b323          	sd	a5,-26(a3) # ffffffffc02164a0 <sm>
     int r = sm->init();
ffffffffc02024c2:	9702                	jalr	a4
ffffffffc02024c4:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02024c6:	c10d                	beqz	a0,ffffffffc02024e8 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02024c8:	60ea                	ld	ra,152(sp)
ffffffffc02024ca:	644a                	ld	s0,144(sp)
ffffffffc02024cc:	8556                	mv	a0,s5
ffffffffc02024ce:	64aa                	ld	s1,136(sp)
ffffffffc02024d0:	690a                	ld	s2,128(sp)
ffffffffc02024d2:	79e6                	ld	s3,120(sp)
ffffffffc02024d4:	7a46                	ld	s4,112(sp)
ffffffffc02024d6:	7aa6                	ld	s5,104(sp)
ffffffffc02024d8:	7b06                	ld	s6,96(sp)
ffffffffc02024da:	6be6                	ld	s7,88(sp)
ffffffffc02024dc:	6c46                	ld	s8,80(sp)
ffffffffc02024de:	6ca6                	ld	s9,72(sp)
ffffffffc02024e0:	6d06                	ld	s10,64(sp)
ffffffffc02024e2:	7de2                	ld	s11,56(sp)
ffffffffc02024e4:	610d                	addi	sp,sp,160
ffffffffc02024e6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02024e8:	00014797          	auipc	a5,0x14
ffffffffc02024ec:	fb878793          	addi	a5,a5,-72 # ffffffffc02164a0 <sm>
ffffffffc02024f0:	639c                	ld	a5,0(a5)
ffffffffc02024f2:	00004517          	auipc	a0,0x4
ffffffffc02024f6:	01650513          	addi	a0,a0,22 # ffffffffc0206508 <commands+0x12b0>
ffffffffc02024fa:	00014417          	auipc	s0,0x14
ffffffffc02024fe:	0e640413          	addi	s0,s0,230 # ffffffffc02165e0 <free_area>
ffffffffc0202502:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202504:	4785                	li	a5,1
ffffffffc0202506:	00014717          	auipc	a4,0x14
ffffffffc020250a:	faf72123          	sw	a5,-94(a4) # ffffffffc02164a8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020250e:	bc3fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202512:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202514:	38878d63          	beq	a5,s0,ffffffffc02028ae <swap_init+0x436>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202518:	fe87b703          	ld	a4,-24(a5)
ffffffffc020251c:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020251e:	8b05                	andi	a4,a4,1
ffffffffc0202520:	38070b63          	beqz	a4,ffffffffc02028b6 <swap_init+0x43e>
     int ret, count = 0, total = 0, i;
ffffffffc0202524:	4481                	li	s1,0
ffffffffc0202526:	4901                	li	s2,0
ffffffffc0202528:	a031                	j	ffffffffc0202534 <swap_init+0xbc>
ffffffffc020252a:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc020252e:	8b09                	andi	a4,a4,2
ffffffffc0202530:	38070363          	beqz	a4,ffffffffc02028b6 <swap_init+0x43e>
        count ++, total += p->property;
ffffffffc0202534:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202538:	679c                	ld	a5,8(a5)
ffffffffc020253a:	2905                	addiw	s2,s2,1
ffffffffc020253c:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020253e:	fe8796e3          	bne	a5,s0,ffffffffc020252a <swap_init+0xb2>
ffffffffc0202542:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202544:	fa4fe0ef          	jal	ra,ffffffffc0200ce8 <nr_free_pages>
ffffffffc0202548:	6b351763          	bne	a0,s3,ffffffffc0202bf6 <swap_init+0x77e>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020254c:	8626                	mv	a2,s1
ffffffffc020254e:	85ca                	mv	a1,s2
ffffffffc0202550:	00004517          	auipc	a0,0x4
ffffffffc0202554:	00050513          	mv	a0,a0
ffffffffc0202558:	b79fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020255c:	f1cff0ef          	jal	ra,ffffffffc0201c78 <mm_create>
ffffffffc0202560:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202562:	62050a63          	beqz	a0,ffffffffc0202b96 <swap_init+0x71e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202566:	00014797          	auipc	a5,0x14
ffffffffc020256a:	f9a78793          	addi	a5,a5,-102 # ffffffffc0216500 <check_mm_struct>
ffffffffc020256e:	639c                	ld	a5,0(a5)
ffffffffc0202570:	64079363          	bnez	a5,ffffffffc0202bb6 <swap_init+0x73e>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202574:	00014797          	auipc	a5,0x14
ffffffffc0202578:	f1478793          	addi	a5,a5,-236 # ffffffffc0216488 <boot_pgdir>
ffffffffc020257c:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202580:	00014797          	auipc	a5,0x14
ffffffffc0202584:	f8a7b023          	sd	a0,-128(a5) # ffffffffc0216500 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202588:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020258c:	01653c23          	sd	s6,24(a0) # ffffffffc0206568 <commands+0x1310>
     assert(pgdir[0] == 0);
ffffffffc0202590:	50079763          	bnez	a5,ffffffffc0202a9e <swap_init+0x626>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202594:	6599                	lui	a1,0x6
ffffffffc0202596:	460d                	li	a2,3
ffffffffc0202598:	6505                	lui	a0,0x1
ffffffffc020259a:	f2aff0ef          	jal	ra,ffffffffc0201cc4 <vma_create>
ffffffffc020259e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02025a0:	50050f63          	beqz	a0,ffffffffc0202abe <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc02025a4:	855e                	mv	a0,s7
ffffffffc02025a6:	f8aff0ef          	jal	ra,ffffffffc0201d30 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02025aa:	00004517          	auipc	a0,0x4
ffffffffc02025ae:	fe650513          	addi	a0,a0,-26 # ffffffffc0206590 <commands+0x1338>
ffffffffc02025b2:	b1ffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02025b6:	018bb503          	ld	a0,24(s7)
ffffffffc02025ba:	4605                	li	a2,1
ffffffffc02025bc:	6585                	lui	a1,0x1
ffffffffc02025be:	f6afe0ef          	jal	ra,ffffffffc0200d28 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02025c2:	50050e63          	beqz	a0,ffffffffc0202ade <swap_init+0x666>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02025c6:	00004517          	auipc	a0,0x4
ffffffffc02025ca:	01a50513          	addi	a0,a0,26 # ffffffffc02065e0 <commands+0x1388>
ffffffffc02025ce:	00014997          	auipc	s3,0x14
ffffffffc02025d2:	f3a98993          	addi	s3,s3,-198 # ffffffffc0216508 <check_rp>
ffffffffc02025d6:	afbfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02025da:	00014a17          	auipc	s4,0x14
ffffffffc02025de:	f4ea0a13          	addi	s4,s4,-178 # ffffffffc0216528 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02025e2:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02025e4:	4505                	li	a0,1
ffffffffc02025e6:	e34fe0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02025ea:	00ac3023          	sd	a0,0(s8) # 80000 <BASE_ADDRESS-0xffffffffc0180000>
          assert(check_rp[i] != NULL );
ffffffffc02025ee:	34050c63          	beqz	a0,ffffffffc0202946 <swap_init+0x4ce>
ffffffffc02025f2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02025f4:	8b89                	andi	a5,a5,2
ffffffffc02025f6:	32079863          	bnez	a5,ffffffffc0202926 <swap_init+0x4ae>
ffffffffc02025fa:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02025fc:	ff4c14e3          	bne	s8,s4,ffffffffc02025e4 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202600:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202602:	00014c17          	auipc	s8,0x14
ffffffffc0202606:	f06c0c13          	addi	s8,s8,-250 # ffffffffc0216508 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020260a:	ec3e                	sd	a5,24(sp)
ffffffffc020260c:	641c                	ld	a5,8(s0)
ffffffffc020260e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202610:	481c                	lw	a5,16(s0)
ffffffffc0202612:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202614:	00014797          	auipc	a5,0x14
ffffffffc0202618:	fc87ba23          	sd	s0,-44(a5) # ffffffffc02165e8 <free_area+0x8>
ffffffffc020261c:	00014797          	auipc	a5,0x14
ffffffffc0202620:	fc87b223          	sd	s0,-60(a5) # ffffffffc02165e0 <free_area>
     nr_free = 0;
ffffffffc0202624:	00014797          	auipc	a5,0x14
ffffffffc0202628:	fc07a623          	sw	zero,-52(a5) # ffffffffc02165f0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020262c:	000c3503          	ld	a0,0(s8)
ffffffffc0202630:	4585                	li	a1,1
ffffffffc0202632:	0c21                	addi	s8,s8,8
ffffffffc0202634:	e6efe0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202638:	ff4c1ae3          	bne	s8,s4,ffffffffc020262c <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020263c:	01042c03          	lw	s8,16(s0)
ffffffffc0202640:	4791                	li	a5,4
ffffffffc0202642:	52fc1a63          	bne	s8,a5,ffffffffc0202b76 <swap_init+0x6fe>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202646:	00004517          	auipc	a0,0x4
ffffffffc020264a:	02250513          	addi	a0,a0,34 # ffffffffc0206668 <commands+0x1410>
ffffffffc020264e:	a83fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202652:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202654:	00014797          	auipc	a5,0x14
ffffffffc0202658:	e407a223          	sw	zero,-444(a5) # ffffffffc0216498 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020265c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc020265e:	00014797          	auipc	a5,0x14
ffffffffc0202662:	e3a78793          	addi	a5,a5,-454 # ffffffffc0216498 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202666:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc020266a:	4398                	lw	a4,0(a5)
ffffffffc020266c:	4585                	li	a1,1
ffffffffc020266e:	2701                	sext.w	a4,a4
ffffffffc0202670:	3ab71763          	bne	a4,a1,ffffffffc0202a1e <swap_init+0x5a6>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202674:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202678:	4394                	lw	a3,0(a5)
ffffffffc020267a:	2681                	sext.w	a3,a3
ffffffffc020267c:	3ce69163          	bne	a3,a4,ffffffffc0202a3e <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202680:	6689                	lui	a3,0x2
ffffffffc0202682:	462d                	li	a2,11
ffffffffc0202684:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202688:	4398                	lw	a4,0(a5)
ffffffffc020268a:	4589                	li	a1,2
ffffffffc020268c:	2701                	sext.w	a4,a4
ffffffffc020268e:	30b71863          	bne	a4,a1,ffffffffc020299e <swap_init+0x526>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202692:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202696:	4394                	lw	a3,0(a5)
ffffffffc0202698:	2681                	sext.w	a3,a3
ffffffffc020269a:	32e69263          	bne	a3,a4,ffffffffc02029be <swap_init+0x546>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020269e:	668d                	lui	a3,0x3
ffffffffc02026a0:	4631                	li	a2,12
ffffffffc02026a2:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02026a6:	4398                	lw	a4,0(a5)
ffffffffc02026a8:	458d                	li	a1,3
ffffffffc02026aa:	2701                	sext.w	a4,a4
ffffffffc02026ac:	32b71963          	bne	a4,a1,ffffffffc02029de <swap_init+0x566>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02026b0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02026b4:	4394                	lw	a3,0(a5)
ffffffffc02026b6:	2681                	sext.w	a3,a3
ffffffffc02026b8:	34e69363          	bne	a3,a4,ffffffffc02029fe <swap_init+0x586>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026bc:	6691                	lui	a3,0x4
ffffffffc02026be:	4635                	li	a2,13
ffffffffc02026c0:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc02026c4:	4398                	lw	a4,0(a5)
ffffffffc02026c6:	2701                	sext.w	a4,a4
ffffffffc02026c8:	39871b63          	bne	a4,s8,ffffffffc0202a5e <swap_init+0x5e6>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02026cc:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02026d0:	439c                	lw	a5,0(a5)
ffffffffc02026d2:	2781                	sext.w	a5,a5
ffffffffc02026d4:	3ae79563          	bne	a5,a4,ffffffffc0202a7e <swap_init+0x606>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02026d8:	481c                	lw	a5,16(s0)
ffffffffc02026da:	42079263          	bnez	a5,ffffffffc0202afe <swap_init+0x686>
ffffffffc02026de:	00014797          	auipc	a5,0x14
ffffffffc02026e2:	e4a78793          	addi	a5,a5,-438 # ffffffffc0216528 <swap_in_seq_no>
ffffffffc02026e6:	00014717          	auipc	a4,0x14
ffffffffc02026ea:	e6a70713          	addi	a4,a4,-406 # ffffffffc0216550 <swap_out_seq_no>
ffffffffc02026ee:	00014617          	auipc	a2,0x14
ffffffffc02026f2:	e6260613          	addi	a2,a2,-414 # ffffffffc0216550 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02026f6:	56fd                	li	a3,-1
ffffffffc02026f8:	c394                	sw	a3,0(a5)
ffffffffc02026fa:	c314                	sw	a3,0(a4)
ffffffffc02026fc:	0791                	addi	a5,a5,4
ffffffffc02026fe:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202700:	fef61ce3          	bne	a2,a5,ffffffffc02026f8 <swap_init+0x280>
ffffffffc0202704:	00014817          	auipc	a6,0x14
ffffffffc0202708:	eac80813          	addi	a6,a6,-340 # ffffffffc02165b0 <check_ptep>
ffffffffc020270c:	00014897          	auipc	a7,0x14
ffffffffc0202710:	dfc88893          	addi	a7,a7,-516 # ffffffffc0216508 <check_rp>
ffffffffc0202714:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202716:	00014c97          	auipc	s9,0x14
ffffffffc020271a:	d7ac8c93          	addi	s9,s9,-646 # ffffffffc0216490 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020271e:	00005d97          	auipc	s11,0x5
ffffffffc0202722:	b42d8d93          	addi	s11,s11,-1214 # ffffffffc0207260 <nbase>
ffffffffc0202726:	00014c17          	auipc	s8,0x14
ffffffffc020272a:	dd2c0c13          	addi	s8,s8,-558 # ffffffffc02164f8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020272e:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202732:	4601                	li	a2,0
ffffffffc0202734:	85ea                	mv	a1,s10
ffffffffc0202736:	855a                	mv	a0,s6
ffffffffc0202738:	e846                	sd	a7,16(sp)
         check_ptep[i]=0;
ffffffffc020273a:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020273c:	decfe0ef          	jal	ra,ffffffffc0200d28 <get_pte>
ffffffffc0202740:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202742:	68c2                	ld	a7,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202744:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202748:	20050f63          	beqz	a0,ffffffffc0202966 <swap_init+0x4ee>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020274c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020274e:	0017f713          	andi	a4,a5,1
ffffffffc0202752:	1a070e63          	beqz	a4,ffffffffc020290e <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0202756:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020275a:	078a                	slli	a5,a5,0x2
ffffffffc020275c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020275e:	16e7fc63          	bleu	a4,a5,ffffffffc02028d6 <swap_init+0x45e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202762:	000db703          	ld	a4,0(s11)
ffffffffc0202766:	000c3603          	ld	a2,0(s8)
ffffffffc020276a:	0008b583          	ld	a1,0(a7)
ffffffffc020276e:	8f99                	sub	a5,a5,a4
ffffffffc0202770:	e43a                	sd	a4,8(sp)
ffffffffc0202772:	00379713          	slli	a4,a5,0x3
ffffffffc0202776:	97ba                	add	a5,a5,a4
ffffffffc0202778:	078e                	slli	a5,a5,0x3
ffffffffc020277a:	97b2                	add	a5,a5,a2
ffffffffc020277c:	16f59963          	bne	a1,a5,ffffffffc02028ee <swap_init+0x476>
ffffffffc0202780:	6785                	lui	a5,0x1
ffffffffc0202782:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202784:	6795                	lui	a5,0x5
ffffffffc0202786:	0821                	addi	a6,a6,8
ffffffffc0202788:	08a1                	addi	a7,a7,8
ffffffffc020278a:	fafd12e3          	bne	s10,a5,ffffffffc020272e <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020278e:	00004517          	auipc	a0,0x4
ffffffffc0202792:	f9250513          	addi	a0,a0,-110 # ffffffffc0206720 <commands+0x14c8>
ffffffffc0202796:	93bfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc020279a:	00014797          	auipc	a5,0x14
ffffffffc020279e:	d0678793          	addi	a5,a5,-762 # ffffffffc02164a0 <sm>
ffffffffc02027a2:	639c                	ld	a5,0(a5)
ffffffffc02027a4:	7f9c                	ld	a5,56(a5)
ffffffffc02027a6:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02027a8:	42051763          	bnez	a0,ffffffffc0202bd6 <swap_init+0x75e>

     nr_free = nr_free_store;
ffffffffc02027ac:	77a2                	ld	a5,40(sp)
ffffffffc02027ae:	00014717          	auipc	a4,0x14
ffffffffc02027b2:	e4f72123          	sw	a5,-446(a4) # ffffffffc02165f0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02027b6:	67e2                	ld	a5,24(sp)
ffffffffc02027b8:	00014717          	auipc	a4,0x14
ffffffffc02027bc:	e2f73423          	sd	a5,-472(a4) # ffffffffc02165e0 <free_area>
ffffffffc02027c0:	7782                	ld	a5,32(sp)
ffffffffc02027c2:	00014717          	auipc	a4,0x14
ffffffffc02027c6:	e2f73323          	sd	a5,-474(a4) # ffffffffc02165e8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02027ca:	0009b503          	ld	a0,0(s3)
ffffffffc02027ce:	4585                	li	a1,1
ffffffffc02027d0:	09a1                	addi	s3,s3,8
ffffffffc02027d2:	cd0fe0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02027d6:	ff499ae3          	bne	s3,s4,ffffffffc02027ca <swap_init+0x352>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc02027da:	855e                	mv	a0,s7
ffffffffc02027dc:	e22ff0ef          	jal	ra,ffffffffc0201dfe <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02027e0:	00014797          	auipc	a5,0x14
ffffffffc02027e4:	ca878793          	addi	a5,a5,-856 # ffffffffc0216488 <boot_pgdir>
ffffffffc02027e8:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02027ea:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02027ee:	6394                	ld	a3,0(a5)
ffffffffc02027f0:	068a                	slli	a3,a3,0x2
ffffffffc02027f2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027f4:	0ee6f163          	bleu	a4,a3,ffffffffc02028d6 <swap_init+0x45e>
    return &pages[PPN(pa) - nbase];
ffffffffc02027f8:	6622                	ld	a2,8(sp)
ffffffffc02027fa:	000c3503          	ld	a0,0(s8)
ffffffffc02027fe:	40c687b3          	sub	a5,a3,a2
ffffffffc0202802:	00379693          	slli	a3,a5,0x3
ffffffffc0202806:	96be                	add	a3,a3,a5
    return page - pages + nbase;
ffffffffc0202808:	00003797          	auipc	a5,0x3
ffffffffc020280c:	30078793          	addi	a5,a5,768 # ffffffffc0205b08 <commands+0x8b0>
ffffffffc0202810:	639c                	ld	a5,0(a5)
    return &pages[PPN(pa) - nbase];
ffffffffc0202812:	068e                	slli	a3,a3,0x3
    return page - pages + nbase;
ffffffffc0202814:	868d                	srai	a3,a3,0x3
ffffffffc0202816:	02f686b3          	mul	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020281a:	57fd                	li	a5,-1
ffffffffc020281c:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc020281e:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202820:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202822:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202824:	2ee7fd63          	bleu	a4,a5,ffffffffc0202b1e <swap_init+0x6a6>
     free_page(pde2page(pd0[0]));
ffffffffc0202828:	00014797          	auipc	a5,0x14
ffffffffc020282c:	cc078793          	addi	a5,a5,-832 # ffffffffc02164e8 <va_pa_offset>
ffffffffc0202830:	639c                	ld	a5,0(a5)
ffffffffc0202832:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202834:	629c                	ld	a5,0(a3)
ffffffffc0202836:	078a                	slli	a5,a5,0x2
ffffffffc0202838:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020283a:	08e7fe63          	bleu	a4,a5,ffffffffc02028d6 <swap_init+0x45e>
    return &pages[PPN(pa) - nbase];
ffffffffc020283e:	69a2                	ld	s3,8(sp)
ffffffffc0202840:	4585                	li	a1,1
ffffffffc0202842:	413787b3          	sub	a5,a5,s3
ffffffffc0202846:	00379713          	slli	a4,a5,0x3
ffffffffc020284a:	97ba                	add	a5,a5,a4
ffffffffc020284c:	078e                	slli	a5,a5,0x3
ffffffffc020284e:	953e                	add	a0,a0,a5
ffffffffc0202850:	c52fe0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202854:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202858:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc020285c:	078a                	slli	a5,a5,0x2
ffffffffc020285e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202860:	06e7fb63          	bleu	a4,a5,ffffffffc02028d6 <swap_init+0x45e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202864:	413787b3          	sub	a5,a5,s3
ffffffffc0202868:	00379713          	slli	a4,a5,0x3
ffffffffc020286c:	000c3503          	ld	a0,0(s8)
ffffffffc0202870:	97ba                	add	a5,a5,a4
ffffffffc0202872:	078e                	slli	a5,a5,0x3
     free_page(pde2page(pd1[0]));
ffffffffc0202874:	4585                	li	a1,1
ffffffffc0202876:	953e                	add	a0,a0,a5
ffffffffc0202878:	c2afe0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
     pgdir[0] = 0;
ffffffffc020287c:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202880:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202884:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202886:	00878963          	beq	a5,s0,ffffffffc0202898 <swap_init+0x420>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020288a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020288e:	679c                	ld	a5,8(a5)
ffffffffc0202890:	397d                	addiw	s2,s2,-1
ffffffffc0202892:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202894:	fe879be3          	bne	a5,s0,ffffffffc020288a <swap_init+0x412>
     }
     assert(count==0);
ffffffffc0202898:	28091f63          	bnez	s2,ffffffffc0202b36 <swap_init+0x6be>
     assert(total==0);
ffffffffc020289c:	2a049d63          	bnez	s1,ffffffffc0202b56 <swap_init+0x6de>

     cprintf("check_swap() succeeded!\n");
ffffffffc02028a0:	00004517          	auipc	a0,0x4
ffffffffc02028a4:	ed050513          	addi	a0,a0,-304 # ffffffffc0206770 <commands+0x1518>
ffffffffc02028a8:	829fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02028ac:	b931                	j	ffffffffc02024c8 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc02028ae:	4481                	li	s1,0
ffffffffc02028b0:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028b2:	4981                	li	s3,0
ffffffffc02028b4:	b941                	j	ffffffffc0202544 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02028b6:	00004697          	auipc	a3,0x4
ffffffffc02028ba:	c6a68693          	addi	a3,a3,-918 # ffffffffc0206520 <commands+0x12c8>
ffffffffc02028be:	00003617          	auipc	a2,0x3
ffffffffc02028c2:	3aa60613          	addi	a2,a2,938 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02028c6:	0bd00593          	li	a1,189
ffffffffc02028ca:	00004517          	auipc	a0,0x4
ffffffffc02028ce:	c2e50513          	addi	a0,a0,-978 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc02028d2:	905fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02028d6:	00003617          	auipc	a2,0x3
ffffffffc02028da:	27260613          	addi	a2,a2,626 # ffffffffc0205b48 <commands+0x8f0>
ffffffffc02028de:	06200593          	li	a1,98
ffffffffc02028e2:	00003517          	auipc	a0,0x3
ffffffffc02028e6:	28650513          	addi	a0,a0,646 # ffffffffc0205b68 <commands+0x910>
ffffffffc02028ea:	8edfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02028ee:	00004697          	auipc	a3,0x4
ffffffffc02028f2:	e0a68693          	addi	a3,a3,-502 # ffffffffc02066f8 <commands+0x14a0>
ffffffffc02028f6:	00003617          	auipc	a2,0x3
ffffffffc02028fa:	37260613          	addi	a2,a2,882 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02028fe:	0fd00593          	li	a1,253
ffffffffc0202902:	00004517          	auipc	a0,0x4
ffffffffc0202906:	bf650513          	addi	a0,a0,-1034 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc020290a:	8cdfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020290e:	00003617          	auipc	a2,0x3
ffffffffc0202912:	43260613          	addi	a2,a2,1074 # ffffffffc0205d40 <commands+0xae8>
ffffffffc0202916:	07400593          	li	a1,116
ffffffffc020291a:	00003517          	auipc	a0,0x3
ffffffffc020291e:	24e50513          	addi	a0,a0,590 # ffffffffc0205b68 <commands+0x910>
ffffffffc0202922:	8b5fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202926:	00004697          	auipc	a3,0x4
ffffffffc020292a:	cfa68693          	addi	a3,a3,-774 # ffffffffc0206620 <commands+0x13c8>
ffffffffc020292e:	00003617          	auipc	a2,0x3
ffffffffc0202932:	33a60613          	addi	a2,a2,826 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202936:	0de00593          	li	a1,222
ffffffffc020293a:	00004517          	auipc	a0,0x4
ffffffffc020293e:	bbe50513          	addi	a0,a0,-1090 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202942:	895fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202946:	00004697          	auipc	a3,0x4
ffffffffc020294a:	cc268693          	addi	a3,a3,-830 # ffffffffc0206608 <commands+0x13b0>
ffffffffc020294e:	00003617          	auipc	a2,0x3
ffffffffc0202952:	31a60613          	addi	a2,a2,794 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202956:	0dd00593          	li	a1,221
ffffffffc020295a:	00004517          	auipc	a0,0x4
ffffffffc020295e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202962:	875fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202966:	00004697          	auipc	a3,0x4
ffffffffc020296a:	d7a68693          	addi	a3,a3,-646 # ffffffffc02066e0 <commands+0x1488>
ffffffffc020296e:	00003617          	auipc	a2,0x3
ffffffffc0202972:	2fa60613          	addi	a2,a2,762 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202976:	0fc00593          	li	a1,252
ffffffffc020297a:	00004517          	auipc	a0,0x4
ffffffffc020297e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202982:	855fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202986:	00004617          	auipc	a2,0x4
ffffffffc020298a:	b5260613          	addi	a2,a2,-1198 # ffffffffc02064d8 <commands+0x1280>
ffffffffc020298e:	02a00593          	li	a1,42
ffffffffc0202992:	00004517          	auipc	a0,0x4
ffffffffc0202996:	b6650513          	addi	a0,a0,-1178 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc020299a:	83dfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==2);
ffffffffc020299e:	00004697          	auipc	a3,0x4
ffffffffc02029a2:	d0268693          	addi	a3,a3,-766 # ffffffffc02066a0 <commands+0x1448>
ffffffffc02029a6:	00003617          	auipc	a2,0x3
ffffffffc02029aa:	2c260613          	addi	a2,a2,706 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02029ae:	09800593          	li	a1,152
ffffffffc02029b2:	00004517          	auipc	a0,0x4
ffffffffc02029b6:	b4650513          	addi	a0,a0,-1210 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc02029ba:	81dfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==2);
ffffffffc02029be:	00004697          	auipc	a3,0x4
ffffffffc02029c2:	ce268693          	addi	a3,a3,-798 # ffffffffc02066a0 <commands+0x1448>
ffffffffc02029c6:	00003617          	auipc	a2,0x3
ffffffffc02029ca:	2a260613          	addi	a2,a2,674 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02029ce:	09a00593          	li	a1,154
ffffffffc02029d2:	00004517          	auipc	a0,0x4
ffffffffc02029d6:	b2650513          	addi	a0,a0,-1242 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc02029da:	ffcfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==3);
ffffffffc02029de:	00004697          	auipc	a3,0x4
ffffffffc02029e2:	cd268693          	addi	a3,a3,-814 # ffffffffc02066b0 <commands+0x1458>
ffffffffc02029e6:	00003617          	auipc	a2,0x3
ffffffffc02029ea:	28260613          	addi	a2,a2,642 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02029ee:	09c00593          	li	a1,156
ffffffffc02029f2:	00004517          	auipc	a0,0x4
ffffffffc02029f6:	b0650513          	addi	a0,a0,-1274 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc02029fa:	fdcfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==3);
ffffffffc02029fe:	00004697          	auipc	a3,0x4
ffffffffc0202a02:	cb268693          	addi	a3,a3,-846 # ffffffffc02066b0 <commands+0x1458>
ffffffffc0202a06:	00003617          	auipc	a2,0x3
ffffffffc0202a0a:	26260613          	addi	a2,a2,610 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202a0e:	09e00593          	li	a1,158
ffffffffc0202a12:	00004517          	auipc	a0,0x4
ffffffffc0202a16:	ae650513          	addi	a0,a0,-1306 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202a1a:	fbcfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==1);
ffffffffc0202a1e:	00004697          	auipc	a3,0x4
ffffffffc0202a22:	c7268693          	addi	a3,a3,-910 # ffffffffc0206690 <commands+0x1438>
ffffffffc0202a26:	00003617          	auipc	a2,0x3
ffffffffc0202a2a:	24260613          	addi	a2,a2,578 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202a2e:	09400593          	li	a1,148
ffffffffc0202a32:	00004517          	auipc	a0,0x4
ffffffffc0202a36:	ac650513          	addi	a0,a0,-1338 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202a3a:	f9cfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==1);
ffffffffc0202a3e:	00004697          	auipc	a3,0x4
ffffffffc0202a42:	c5268693          	addi	a3,a3,-942 # ffffffffc0206690 <commands+0x1438>
ffffffffc0202a46:	00003617          	auipc	a2,0x3
ffffffffc0202a4a:	22260613          	addi	a2,a2,546 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202a4e:	09600593          	li	a1,150
ffffffffc0202a52:	00004517          	auipc	a0,0x4
ffffffffc0202a56:	aa650513          	addi	a0,a0,-1370 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202a5a:	f7cfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==4);
ffffffffc0202a5e:	00004697          	auipc	a3,0x4
ffffffffc0202a62:	c6268693          	addi	a3,a3,-926 # ffffffffc02066c0 <commands+0x1468>
ffffffffc0202a66:	00003617          	auipc	a2,0x3
ffffffffc0202a6a:	20260613          	addi	a2,a2,514 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202a6e:	0a000593          	li	a1,160
ffffffffc0202a72:	00004517          	auipc	a0,0x4
ffffffffc0202a76:	a8650513          	addi	a0,a0,-1402 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202a7a:	f5cfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==4);
ffffffffc0202a7e:	00004697          	auipc	a3,0x4
ffffffffc0202a82:	c4268693          	addi	a3,a3,-958 # ffffffffc02066c0 <commands+0x1468>
ffffffffc0202a86:	00003617          	auipc	a2,0x3
ffffffffc0202a8a:	1e260613          	addi	a2,a2,482 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202a8e:	0a200593          	li	a1,162
ffffffffc0202a92:	00004517          	auipc	a0,0x4
ffffffffc0202a96:	a6650513          	addi	a0,a0,-1434 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202a9a:	f3cfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202a9e:	00004697          	auipc	a3,0x4
ffffffffc0202aa2:	93a68693          	addi	a3,a3,-1734 # ffffffffc02063d8 <commands+0x1180>
ffffffffc0202aa6:	00003617          	auipc	a2,0x3
ffffffffc0202aaa:	1c260613          	addi	a2,a2,450 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202aae:	0cd00593          	li	a1,205
ffffffffc0202ab2:	00004517          	auipc	a0,0x4
ffffffffc0202ab6:	a4650513          	addi	a0,a0,-1466 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202aba:	f1cfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(vma != NULL);
ffffffffc0202abe:	00004697          	auipc	a3,0x4
ffffffffc0202ac2:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0206478 <commands+0x1220>
ffffffffc0202ac6:	00003617          	auipc	a2,0x3
ffffffffc0202aca:	1a260613          	addi	a2,a2,418 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202ace:	0d000593          	li	a1,208
ffffffffc0202ad2:	00004517          	auipc	a0,0x4
ffffffffc0202ad6:	a2650513          	addi	a0,a0,-1498 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202ada:	efcfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202ade:	00004697          	auipc	a3,0x4
ffffffffc0202ae2:	aea68693          	addi	a3,a3,-1302 # ffffffffc02065c8 <commands+0x1370>
ffffffffc0202ae6:	00003617          	auipc	a2,0x3
ffffffffc0202aea:	18260613          	addi	a2,a2,386 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202aee:	0d800593          	li	a1,216
ffffffffc0202af2:	00004517          	auipc	a0,0x4
ffffffffc0202af6:	a0650513          	addi	a0,a0,-1530 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202afa:	edcfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert( nr_free == 0);         
ffffffffc0202afe:	00004697          	auipc	a3,0x4
ffffffffc0202b02:	bd268693          	addi	a3,a3,-1070 # ffffffffc02066d0 <commands+0x1478>
ffffffffc0202b06:	00003617          	auipc	a2,0x3
ffffffffc0202b0a:	16260613          	addi	a2,a2,354 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202b0e:	0f400593          	li	a1,244
ffffffffc0202b12:	00004517          	auipc	a0,0x4
ffffffffc0202b16:	9e650513          	addi	a0,a0,-1562 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202b1a:	ebcfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202b1e:	00003617          	auipc	a2,0x3
ffffffffc0202b22:	ff260613          	addi	a2,a2,-14 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0202b26:	06900593          	li	a1,105
ffffffffc0202b2a:	00003517          	auipc	a0,0x3
ffffffffc0202b2e:	03e50513          	addi	a0,a0,62 # ffffffffc0205b68 <commands+0x910>
ffffffffc0202b32:	ea4fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(count==0);
ffffffffc0202b36:	00004697          	auipc	a3,0x4
ffffffffc0202b3a:	c1a68693          	addi	a3,a3,-998 # ffffffffc0206750 <commands+0x14f8>
ffffffffc0202b3e:	00003617          	auipc	a2,0x3
ffffffffc0202b42:	12a60613          	addi	a2,a2,298 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202b46:	11c00593          	li	a1,284
ffffffffc0202b4a:	00004517          	auipc	a0,0x4
ffffffffc0202b4e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202b52:	e84fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(total==0);
ffffffffc0202b56:	00004697          	auipc	a3,0x4
ffffffffc0202b5a:	c0a68693          	addi	a3,a3,-1014 # ffffffffc0206760 <commands+0x1508>
ffffffffc0202b5e:	00003617          	auipc	a2,0x3
ffffffffc0202b62:	10a60613          	addi	a2,a2,266 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202b66:	11d00593          	li	a1,285
ffffffffc0202b6a:	00004517          	auipc	a0,0x4
ffffffffc0202b6e:	98e50513          	addi	a0,a0,-1650 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202b72:	e64fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202b76:	00004697          	auipc	a3,0x4
ffffffffc0202b7a:	aca68693          	addi	a3,a3,-1334 # ffffffffc0206640 <commands+0x13e8>
ffffffffc0202b7e:	00003617          	auipc	a2,0x3
ffffffffc0202b82:	0ea60613          	addi	a2,a2,234 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202b86:	0eb00593          	li	a1,235
ffffffffc0202b8a:	00004517          	auipc	a0,0x4
ffffffffc0202b8e:	96e50513          	addi	a0,a0,-1682 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202b92:	e44fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(mm != NULL);
ffffffffc0202b96:	00003697          	auipc	a3,0x3
ffffffffc0202b9a:	6ba68693          	addi	a3,a3,1722 # ffffffffc0206250 <commands+0xff8>
ffffffffc0202b9e:	00003617          	auipc	a2,0x3
ffffffffc0202ba2:	0ca60613          	addi	a2,a2,202 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202ba6:	0c500593          	li	a1,197
ffffffffc0202baa:	00004517          	auipc	a0,0x4
ffffffffc0202bae:	94e50513          	addi	a0,a0,-1714 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202bb2:	e24fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202bb6:	00004697          	auipc	a3,0x4
ffffffffc0202bba:	9c268693          	addi	a3,a3,-1598 # ffffffffc0206578 <commands+0x1320>
ffffffffc0202bbe:	00003617          	auipc	a2,0x3
ffffffffc0202bc2:	0aa60613          	addi	a2,a2,170 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202bc6:	0c800593          	li	a1,200
ffffffffc0202bca:	00004517          	auipc	a0,0x4
ffffffffc0202bce:	92e50513          	addi	a0,a0,-1746 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202bd2:	e04fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(ret==0);
ffffffffc0202bd6:	00004697          	auipc	a3,0x4
ffffffffc0202bda:	b7268693          	addi	a3,a3,-1166 # ffffffffc0206748 <commands+0x14f0>
ffffffffc0202bde:	00003617          	auipc	a2,0x3
ffffffffc0202be2:	08a60613          	addi	a2,a2,138 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202be6:	10300593          	li	a1,259
ffffffffc0202bea:	00004517          	auipc	a0,0x4
ffffffffc0202bee:	90e50513          	addi	a0,a0,-1778 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202bf2:	de4fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202bf6:	00004697          	auipc	a3,0x4
ffffffffc0202bfa:	93a68693          	addi	a3,a3,-1734 # ffffffffc0206530 <commands+0x12d8>
ffffffffc0202bfe:	00003617          	auipc	a2,0x3
ffffffffc0202c02:	06a60613          	addi	a2,a2,106 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202c06:	0c000593          	li	a1,192
ffffffffc0202c0a:	00004517          	auipc	a0,0x4
ffffffffc0202c0e:	8ee50513          	addi	a0,a0,-1810 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202c12:	dc4fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202c16 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202c16:	00014797          	auipc	a5,0x14
ffffffffc0202c1a:	88a78793          	addi	a5,a5,-1910 # ffffffffc02164a0 <sm>
ffffffffc0202c1e:	639c                	ld	a5,0(a5)
ffffffffc0202c20:	0107b303          	ld	t1,16(a5)
ffffffffc0202c24:	8302                	jr	t1

ffffffffc0202c26 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202c26:	00014797          	auipc	a5,0x14
ffffffffc0202c2a:	87a78793          	addi	a5,a5,-1926 # ffffffffc02164a0 <sm>
ffffffffc0202c2e:	639c                	ld	a5,0(a5)
ffffffffc0202c30:	0207b303          	ld	t1,32(a5)
ffffffffc0202c34:	8302                	jr	t1

ffffffffc0202c36 <swap_out>:
{
ffffffffc0202c36:	711d                	addi	sp,sp,-96
ffffffffc0202c38:	ec86                	sd	ra,88(sp)
ffffffffc0202c3a:	e8a2                	sd	s0,80(sp)
ffffffffc0202c3c:	e4a6                	sd	s1,72(sp)
ffffffffc0202c3e:	e0ca                	sd	s2,64(sp)
ffffffffc0202c40:	fc4e                	sd	s3,56(sp)
ffffffffc0202c42:	f852                	sd	s4,48(sp)
ffffffffc0202c44:	f456                	sd	s5,40(sp)
ffffffffc0202c46:	f05a                	sd	s6,32(sp)
ffffffffc0202c48:	ec5e                	sd	s7,24(sp)
ffffffffc0202c4a:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202c4c:	cde9                	beqz	a1,ffffffffc0202d26 <swap_out+0xf0>
ffffffffc0202c4e:	8ab2                	mv	s5,a2
ffffffffc0202c50:	892a                	mv	s2,a0
ffffffffc0202c52:	8a2e                	mv	s4,a1
ffffffffc0202c54:	4401                	li	s0,0
ffffffffc0202c56:	00014997          	auipc	s3,0x14
ffffffffc0202c5a:	84a98993          	addi	s3,s3,-1974 # ffffffffc02164a0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202c5e:	00004b17          	auipc	s6,0x4
ffffffffc0202c62:	b92b0b13          	addi	s6,s6,-1134 # ffffffffc02067f0 <commands+0x1598>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202c66:	00004b97          	auipc	s7,0x4
ffffffffc0202c6a:	b72b8b93          	addi	s7,s7,-1166 # ffffffffc02067d8 <commands+0x1580>
ffffffffc0202c6e:	a825                	j	ffffffffc0202ca6 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202c70:	67a2                	ld	a5,8(sp)
ffffffffc0202c72:	8626                	mv	a2,s1
ffffffffc0202c74:	85a2                	mv	a1,s0
ffffffffc0202c76:	63b4                	ld	a3,64(a5)
ffffffffc0202c78:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202c7a:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202c7c:	82b1                	srli	a3,a3,0xc
ffffffffc0202c7e:	0685                	addi	a3,a3,1
ffffffffc0202c80:	c50fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202c84:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202c86:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202c88:	613c                	ld	a5,64(a0)
ffffffffc0202c8a:	83b1                	srli	a5,a5,0xc
ffffffffc0202c8c:	0785                	addi	a5,a5,1
ffffffffc0202c8e:	07a2                	slli	a5,a5,0x8
ffffffffc0202c90:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202c94:	80efe0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202c98:	01893503          	ld	a0,24(s2)
ffffffffc0202c9c:	85a6                	mv	a1,s1
ffffffffc0202c9e:	f1ffe0ef          	jal	ra,ffffffffc0201bbc <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202ca2:	048a0d63          	beq	s4,s0,ffffffffc0202cfc <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202ca6:	0009b783          	ld	a5,0(s3)
ffffffffc0202caa:	8656                	mv	a2,s5
ffffffffc0202cac:	002c                	addi	a1,sp,8
ffffffffc0202cae:	7b9c                	ld	a5,48(a5)
ffffffffc0202cb0:	854a                	mv	a0,s2
ffffffffc0202cb2:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202cb4:	e12d                	bnez	a0,ffffffffc0202d16 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202cb6:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202cb8:	01893503          	ld	a0,24(s2)
ffffffffc0202cbc:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202cbe:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202cc0:	85a6                	mv	a1,s1
ffffffffc0202cc2:	866fe0ef          	jal	ra,ffffffffc0200d28 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202cc6:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202cc8:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202cca:	8b85                	andi	a5,a5,1
ffffffffc0202ccc:	cfb9                	beqz	a5,ffffffffc0202d2a <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202cce:	65a2                	ld	a1,8(sp)
ffffffffc0202cd0:	61bc                	ld	a5,64(a1)
ffffffffc0202cd2:	83b1                	srli	a5,a5,0xc
ffffffffc0202cd4:	00178513          	addi	a0,a5,1
ffffffffc0202cd8:	0522                	slli	a0,a0,0x8
ffffffffc0202cda:	5c6010ef          	jal	ra,ffffffffc02042a0 <swapfs_write>
ffffffffc0202cde:	d949                	beqz	a0,ffffffffc0202c70 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202ce0:	855e                	mv	a0,s7
ffffffffc0202ce2:	beefd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202ce6:	0009b783          	ld	a5,0(s3)
ffffffffc0202cea:	6622                	ld	a2,8(sp)
ffffffffc0202cec:	4681                	li	a3,0
ffffffffc0202cee:	739c                	ld	a5,32(a5)
ffffffffc0202cf0:	85a6                	mv	a1,s1
ffffffffc0202cf2:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202cf4:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202cf6:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202cf8:	fa8a17e3          	bne	s4,s0,ffffffffc0202ca6 <swap_out+0x70>
}
ffffffffc0202cfc:	8522                	mv	a0,s0
ffffffffc0202cfe:	60e6                	ld	ra,88(sp)
ffffffffc0202d00:	6446                	ld	s0,80(sp)
ffffffffc0202d02:	64a6                	ld	s1,72(sp)
ffffffffc0202d04:	6906                	ld	s2,64(sp)
ffffffffc0202d06:	79e2                	ld	s3,56(sp)
ffffffffc0202d08:	7a42                	ld	s4,48(sp)
ffffffffc0202d0a:	7aa2                	ld	s5,40(sp)
ffffffffc0202d0c:	7b02                	ld	s6,32(sp)
ffffffffc0202d0e:	6be2                	ld	s7,24(sp)
ffffffffc0202d10:	6c42                	ld	s8,16(sp)
ffffffffc0202d12:	6125                	addi	sp,sp,96
ffffffffc0202d14:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202d16:	85a2                	mv	a1,s0
ffffffffc0202d18:	00004517          	auipc	a0,0x4
ffffffffc0202d1c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0206790 <commands+0x1538>
ffffffffc0202d20:	bb0fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0202d24:	bfe1                	j	ffffffffc0202cfc <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202d26:	4401                	li	s0,0
ffffffffc0202d28:	bfd1                	j	ffffffffc0202cfc <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202d2a:	00004697          	auipc	a3,0x4
ffffffffc0202d2e:	a9668693          	addi	a3,a3,-1386 # ffffffffc02067c0 <commands+0x1568>
ffffffffc0202d32:	00003617          	auipc	a2,0x3
ffffffffc0202d36:	f3660613          	addi	a2,a2,-202 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202d3a:	06900593          	li	a1,105
ffffffffc0202d3e:	00003517          	auipc	a0,0x3
ffffffffc0202d42:	7ba50513          	addi	a0,a0,1978 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202d46:	c90fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202d4a <swap_in>:
{
ffffffffc0202d4a:	7179                	addi	sp,sp,-48
ffffffffc0202d4c:	e84a                	sd	s2,16(sp)
ffffffffc0202d4e:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202d50:	4505                	li	a0,1
{
ffffffffc0202d52:	ec26                	sd	s1,24(sp)
ffffffffc0202d54:	e44e                	sd	s3,8(sp)
ffffffffc0202d56:	f406                	sd	ra,40(sp)
ffffffffc0202d58:	f022                	sd	s0,32(sp)
ffffffffc0202d5a:	84ae                	mv	s1,a1
ffffffffc0202d5c:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202d5e:	ebdfd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
     assert(result!=NULL);
ffffffffc0202d62:	c129                	beqz	a0,ffffffffc0202da4 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202d64:	842a                	mv	s0,a0
ffffffffc0202d66:	01893503          	ld	a0,24(s2)
ffffffffc0202d6a:	4601                	li	a2,0
ffffffffc0202d6c:	85a6                	mv	a1,s1
ffffffffc0202d6e:	fbbfd0ef          	jal	ra,ffffffffc0200d28 <get_pte>
ffffffffc0202d72:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202d74:	6108                	ld	a0,0(a0)
ffffffffc0202d76:	85a2                	mv	a1,s0
ffffffffc0202d78:	482010ef          	jal	ra,ffffffffc02041fa <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202d7c:	00093583          	ld	a1,0(s2)
ffffffffc0202d80:	8626                	mv	a2,s1
ffffffffc0202d82:	00003517          	auipc	a0,0x3
ffffffffc0202d86:	71650513          	addi	a0,a0,1814 # ffffffffc0206498 <commands+0x1240>
ffffffffc0202d8a:	81a1                	srli	a1,a1,0x8
ffffffffc0202d8c:	b44fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202d90:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202d92:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202d96:	7402                	ld	s0,32(sp)
ffffffffc0202d98:	64e2                	ld	s1,24(sp)
ffffffffc0202d9a:	6942                	ld	s2,16(sp)
ffffffffc0202d9c:	69a2                	ld	s3,8(sp)
ffffffffc0202d9e:	4501                	li	a0,0
ffffffffc0202da0:	6145                	addi	sp,sp,48
ffffffffc0202da2:	8082                	ret
     assert(result!=NULL);
ffffffffc0202da4:	00003697          	auipc	a3,0x3
ffffffffc0202da8:	6e468693          	addi	a3,a3,1764 # ffffffffc0206488 <commands+0x1230>
ffffffffc0202dac:	00003617          	auipc	a2,0x3
ffffffffc0202db0:	ebc60613          	addi	a2,a2,-324 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0202db4:	07f00593          	li	a1,127
ffffffffc0202db8:	00003517          	auipc	a0,0x3
ffffffffc0202dbc:	74050513          	addi	a0,a0,1856 # ffffffffc02064f8 <commands+0x12a0>
ffffffffc0202dc0:	c16fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202dc4 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0202dc4:	c125                	beqz	a0,ffffffffc0202e24 <slob_free+0x60>
		return;

	if (size)
ffffffffc0202dc6:	e1a5                	bnez	a1,ffffffffc0202e26 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202dc8:	100027f3          	csrr	a5,sstatus
ffffffffc0202dcc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202dce:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202dd0:	e3bd                	bnez	a5,ffffffffc0202e36 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202dd2:	00008797          	auipc	a5,0x8
ffffffffc0202dd6:	27e78793          	addi	a5,a5,638 # ffffffffc020b050 <slobfree>
ffffffffc0202dda:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202ddc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202dde:	00a7fa63          	bleu	a0,a5,ffffffffc0202df2 <slob_free+0x2e>
ffffffffc0202de2:	00e56c63          	bltu	a0,a4,ffffffffc0202dfa <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202de6:	00e7fa63          	bleu	a4,a5,ffffffffc0202dfa <slob_free+0x36>
    return 0;
ffffffffc0202dea:	87ba                	mv	a5,a4
ffffffffc0202dec:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202dee:	fea7eae3          	bltu	a5,a0,ffffffffc0202de2 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202df2:	fee7ece3          	bltu	a5,a4,ffffffffc0202dea <slob_free+0x26>
ffffffffc0202df6:	fee57ae3          	bleu	a4,a0,ffffffffc0202dea <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0202dfa:	4110                	lw	a2,0(a0)
ffffffffc0202dfc:	00461693          	slli	a3,a2,0x4
ffffffffc0202e00:	96aa                	add	a3,a3,a0
ffffffffc0202e02:	08d70b63          	beq	a4,a3,ffffffffc0202e98 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0202e06:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0202e08:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202e0a:	00469713          	slli	a4,a3,0x4
ffffffffc0202e0e:	973e                	add	a4,a4,a5
ffffffffc0202e10:	08e50f63          	beq	a0,a4,ffffffffc0202eae <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0202e14:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0202e16:	00008717          	auipc	a4,0x8
ffffffffc0202e1a:	22f73d23          	sd	a5,570(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc0202e1e:	c199                	beqz	a1,ffffffffc0202e24 <slob_free+0x60>
        intr_enable();
ffffffffc0202e20:	fb4fd06f          	j	ffffffffc02005d4 <intr_enable>
ffffffffc0202e24:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0202e26:	05bd                	addi	a1,a1,15
ffffffffc0202e28:	8191                	srli	a1,a1,0x4
ffffffffc0202e2a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e2c:	100027f3          	csrr	a5,sstatus
ffffffffc0202e30:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202e32:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e34:	dfd9                	beqz	a5,ffffffffc0202dd2 <slob_free+0xe>
{
ffffffffc0202e36:	1101                	addi	sp,sp,-32
ffffffffc0202e38:	e42a                	sd	a0,8(sp)
ffffffffc0202e3a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0202e3c:	f9efd0ef          	jal	ra,ffffffffc02005da <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202e40:	00008797          	auipc	a5,0x8
ffffffffc0202e44:	21078793          	addi	a5,a5,528 # ffffffffc020b050 <slobfree>
ffffffffc0202e48:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0202e4a:	6522                	ld	a0,8(sp)
ffffffffc0202e4c:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202e4e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202e50:	00a7fa63          	bleu	a0,a5,ffffffffc0202e64 <slob_free+0xa0>
ffffffffc0202e54:	00e56c63          	bltu	a0,a4,ffffffffc0202e6c <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202e58:	00e7fa63          	bleu	a4,a5,ffffffffc0202e6c <slob_free+0xa8>
    return 0;
ffffffffc0202e5c:	87ba                	mv	a5,a4
ffffffffc0202e5e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202e60:	fea7eae3          	bltu	a5,a0,ffffffffc0202e54 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202e64:	fee7ece3          	bltu	a5,a4,ffffffffc0202e5c <slob_free+0x98>
ffffffffc0202e68:	fee57ae3          	bleu	a4,a0,ffffffffc0202e5c <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0202e6c:	4110                	lw	a2,0(a0)
ffffffffc0202e6e:	00461693          	slli	a3,a2,0x4
ffffffffc0202e72:	96aa                	add	a3,a3,a0
ffffffffc0202e74:	04d70763          	beq	a4,a3,ffffffffc0202ec2 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0202e78:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202e7a:	4394                	lw	a3,0(a5)
ffffffffc0202e7c:	00469713          	slli	a4,a3,0x4
ffffffffc0202e80:	973e                	add	a4,a4,a5
ffffffffc0202e82:	04e50663          	beq	a0,a4,ffffffffc0202ece <slob_free+0x10a>
		cur->next = b;
ffffffffc0202e86:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0202e88:	00008717          	auipc	a4,0x8
ffffffffc0202e8c:	1cf73423          	sd	a5,456(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc0202e90:	e58d                	bnez	a1,ffffffffc0202eba <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0202e92:	60e2                	ld	ra,24(sp)
ffffffffc0202e94:	6105                	addi	sp,sp,32
ffffffffc0202e96:	8082                	ret
		b->units += cur->next->units;
ffffffffc0202e98:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202e9a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202e9c:	9e35                	addw	a2,a2,a3
ffffffffc0202e9e:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0202ea0:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202ea2:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202ea4:	00469713          	slli	a4,a3,0x4
ffffffffc0202ea8:	973e                	add	a4,a4,a5
ffffffffc0202eaa:	f6e515e3          	bne	a0,a4,ffffffffc0202e14 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0202eae:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0202eb0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202eb2:	9eb9                	addw	a3,a3,a4
ffffffffc0202eb4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202eb6:	e790                	sd	a2,8(a5)
ffffffffc0202eb8:	bfb9                	j	ffffffffc0202e16 <slob_free+0x52>
}
ffffffffc0202eba:	60e2                	ld	ra,24(sp)
ffffffffc0202ebc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202ebe:	f16fd06f          	j	ffffffffc02005d4 <intr_enable>
		b->units += cur->next->units;
ffffffffc0202ec2:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202ec4:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202ec6:	9e35                	addw	a2,a2,a3
ffffffffc0202ec8:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0202eca:	e518                	sd	a4,8(a0)
ffffffffc0202ecc:	b77d                	j	ffffffffc0202e7a <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0202ece:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0202ed0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202ed2:	9eb9                	addw	a3,a3,a4
ffffffffc0202ed4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202ed6:	e790                	sd	a2,8(a5)
ffffffffc0202ed8:	bf45                	j	ffffffffc0202e88 <slob_free+0xc4>

ffffffffc0202eda <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202eda:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202edc:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202ede:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202ee2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202ee4:	d37fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
  if(!page)
ffffffffc0202ee8:	c931                	beqz	a0,ffffffffc0202f3c <__slob_get_free_pages.isra.0+0x62>
    return page - pages + nbase;
ffffffffc0202eea:	00013797          	auipc	a5,0x13
ffffffffc0202eee:	60e78793          	addi	a5,a5,1550 # ffffffffc02164f8 <pages>
ffffffffc0202ef2:	6394                	ld	a3,0(a5)
ffffffffc0202ef4:	00003797          	auipc	a5,0x3
ffffffffc0202ef8:	c1478793          	addi	a5,a5,-1004 # ffffffffc0205b08 <commands+0x8b0>
    return KADDR(page2pa(page));
ffffffffc0202efc:	00013717          	auipc	a4,0x13
ffffffffc0202f00:	59470713          	addi	a4,a4,1428 # ffffffffc0216490 <npage>
    return page - pages + nbase;
ffffffffc0202f04:	40d506b3          	sub	a3,a0,a3
ffffffffc0202f08:	6388                	ld	a0,0(a5)
ffffffffc0202f0a:	868d                	srai	a3,a3,0x3
ffffffffc0202f0c:	00004797          	auipc	a5,0x4
ffffffffc0202f10:	35478793          	addi	a5,a5,852 # ffffffffc0207260 <nbase>
ffffffffc0202f14:	02a686b3          	mul	a3,a3,a0
ffffffffc0202f18:	6388                	ld	a0,0(a5)
    return KADDR(page2pa(page));
ffffffffc0202f1a:	6318                	ld	a4,0(a4)
ffffffffc0202f1c:	57fd                	li	a5,-1
ffffffffc0202f1e:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc0202f20:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0202f22:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f24:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202f26:	00e7ff63          	bleu	a4,a5,ffffffffc0202f44 <__slob_get_free_pages.isra.0+0x6a>
ffffffffc0202f2a:	00013797          	auipc	a5,0x13
ffffffffc0202f2e:	5be78793          	addi	a5,a5,1470 # ffffffffc02164e8 <va_pa_offset>
ffffffffc0202f32:	6388                	ld	a0,0(a5)
}
ffffffffc0202f34:	60a2                	ld	ra,8(sp)
ffffffffc0202f36:	9536                	add	a0,a0,a3
ffffffffc0202f38:	0141                	addi	sp,sp,16
ffffffffc0202f3a:	8082                	ret
ffffffffc0202f3c:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0202f3e:	4501                	li	a0,0
}
ffffffffc0202f40:	0141                	addi	sp,sp,16
ffffffffc0202f42:	8082                	ret
ffffffffc0202f44:	00003617          	auipc	a2,0x3
ffffffffc0202f48:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0202f4c:	06900593          	li	a1,105
ffffffffc0202f50:	00003517          	auipc	a0,0x3
ffffffffc0202f54:	c1850513          	addi	a0,a0,-1000 # ffffffffc0205b68 <commands+0x910>
ffffffffc0202f58:	a7efd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202f5c <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0202f5c:	7179                	addi	sp,sp,-48
ffffffffc0202f5e:	f406                	sd	ra,40(sp)
ffffffffc0202f60:	f022                	sd	s0,32(sp)
ffffffffc0202f62:	ec26                	sd	s1,24(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202f64:	01050713          	addi	a4,a0,16
ffffffffc0202f68:	6785                	lui	a5,0x1
ffffffffc0202f6a:	0cf77b63          	bleu	a5,a4,ffffffffc0203040 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0202f6e:	00f50413          	addi	s0,a0,15
ffffffffc0202f72:	8011                	srli	s0,s0,0x4
ffffffffc0202f74:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202f76:	10002673          	csrr	a2,sstatus
ffffffffc0202f7a:	8a09                	andi	a2,a2,2
ffffffffc0202f7c:	ea5d                	bnez	a2,ffffffffc0203032 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0202f7e:	00008497          	auipc	s1,0x8
ffffffffc0202f82:	0d248493          	addi	s1,s1,210 # ffffffffc020b050 <slobfree>
ffffffffc0202f86:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202f88:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202f8a:	4398                	lw	a4,0(a5)
ffffffffc0202f8c:	0a875763          	ble	s0,a4,ffffffffc020303a <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0202f90:	00f68a63          	beq	a3,a5,ffffffffc0202fa4 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202f94:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202f96:	4118                	lw	a4,0(a0)
ffffffffc0202f98:	02875763          	ble	s0,a4,ffffffffc0202fc6 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0202f9c:	6094                	ld	a3,0(s1)
ffffffffc0202f9e:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0202fa0:	fef69ae3          	bne	a3,a5,ffffffffc0202f94 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0202fa4:	ea39                	bnez	a2,ffffffffc0202ffa <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202fa6:	4501                	li	a0,0
ffffffffc0202fa8:	f33ff0ef          	jal	ra,ffffffffc0202eda <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0202fac:	cd29                	beqz	a0,ffffffffc0203006 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0202fae:	6585                	lui	a1,0x1
ffffffffc0202fb0:	e15ff0ef          	jal	ra,ffffffffc0202dc4 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202fb4:	10002673          	csrr	a2,sstatus
ffffffffc0202fb8:	8a09                	andi	a2,a2,2
ffffffffc0202fba:	ea1d                	bnez	a2,ffffffffc0202ff0 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0202fbc:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202fbe:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202fc0:	4118                	lw	a4,0(a0)
ffffffffc0202fc2:	fc874de3          	blt	a4,s0,ffffffffc0202f9c <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0202fc6:	04e40663          	beq	s0,a4,ffffffffc0203012 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0202fca:	00441693          	slli	a3,s0,0x4
ffffffffc0202fce:	96aa                	add	a3,a3,a0
ffffffffc0202fd0:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202fd2:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0202fd4:	9f01                	subw	a4,a4,s0
ffffffffc0202fd6:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202fd8:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0202fda:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0202fdc:	00008717          	auipc	a4,0x8
ffffffffc0202fe0:	06f73a23          	sd	a5,116(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc0202fe4:	ee15                	bnez	a2,ffffffffc0203020 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0202fe6:	70a2                	ld	ra,40(sp)
ffffffffc0202fe8:	7402                	ld	s0,32(sp)
ffffffffc0202fea:	64e2                	ld	s1,24(sp)
ffffffffc0202fec:	6145                	addi	sp,sp,48
ffffffffc0202fee:	8082                	ret
        intr_disable();
ffffffffc0202ff0:	deafd0ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc0202ff4:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0202ff6:	609c                	ld	a5,0(s1)
ffffffffc0202ff8:	b7d9                	j	ffffffffc0202fbe <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0202ffa:	ddafd0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202ffe:	4501                	li	a0,0
ffffffffc0203000:	edbff0ef          	jal	ra,ffffffffc0202eda <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0203004:	f54d                	bnez	a0,ffffffffc0202fae <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0203006:	70a2                	ld	ra,40(sp)
ffffffffc0203008:	7402                	ld	s0,32(sp)
ffffffffc020300a:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc020300c:	4501                	li	a0,0
}
ffffffffc020300e:	6145                	addi	sp,sp,48
ffffffffc0203010:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0203012:	6518                	ld	a4,8(a0)
ffffffffc0203014:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0203016:	00008717          	auipc	a4,0x8
ffffffffc020301a:	02f73d23          	sd	a5,58(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc020301e:	d661                	beqz	a2,ffffffffc0202fe6 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0203020:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0203022:	db2fd0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
}
ffffffffc0203026:	70a2                	ld	ra,40(sp)
ffffffffc0203028:	7402                	ld	s0,32(sp)
ffffffffc020302a:	6522                	ld	a0,8(sp)
ffffffffc020302c:	64e2                	ld	s1,24(sp)
ffffffffc020302e:	6145                	addi	sp,sp,48
ffffffffc0203030:	8082                	ret
        intr_disable();
ffffffffc0203032:	da8fd0ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc0203036:	4605                	li	a2,1
ffffffffc0203038:	b799                	j	ffffffffc0202f7e <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020303a:	853e                	mv	a0,a5
ffffffffc020303c:	87b6                	mv	a5,a3
ffffffffc020303e:	b761                	j	ffffffffc0202fc6 <slob_alloc.isra.1.constprop.3+0x6a>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203040:	00004697          	auipc	a3,0x4
ffffffffc0203044:	81068693          	addi	a3,a3,-2032 # ffffffffc0206850 <commands+0x15f8>
ffffffffc0203048:	00003617          	auipc	a2,0x3
ffffffffc020304c:	c2060613          	addi	a2,a2,-992 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203050:	06300593          	li	a1,99
ffffffffc0203054:	00004517          	auipc	a0,0x4
ffffffffc0203058:	81c50513          	addi	a0,a0,-2020 # ffffffffc0206870 <commands+0x1618>
ffffffffc020305c:	97afd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203060 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0203060:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0203062:	00004517          	auipc	a0,0x4
ffffffffc0203066:	82650513          	addi	a0,a0,-2010 # ffffffffc0206888 <commands+0x1630>
kmalloc_init(void) {
ffffffffc020306a:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc020306c:	864fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0203070:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203072:	00003517          	auipc	a0,0x3
ffffffffc0203076:	7be50513          	addi	a0,a0,1982 # ffffffffc0206830 <commands+0x15d8>
}
ffffffffc020307a:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc020307c:	854fd06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0203080 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0203080:	1101                	addi	sp,sp,-32
ffffffffc0203082:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203084:	6905                	lui	s2,0x1
{
ffffffffc0203086:	e822                	sd	s0,16(sp)
ffffffffc0203088:	ec06                	sd	ra,24(sp)
ffffffffc020308a:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020308c:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0203090:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203092:	04a7fc63          	bleu	a0,a5,ffffffffc02030ea <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0203096:	4561                	li	a0,24
ffffffffc0203098:	ec5ff0ef          	jal	ra,ffffffffc0202f5c <slob_alloc.isra.1.constprop.3>
ffffffffc020309c:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc020309e:	cd21                	beqz	a0,ffffffffc02030f6 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02030a0:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02030a4:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02030a6:	00f95763          	ble	a5,s2,ffffffffc02030b4 <kmalloc+0x34>
ffffffffc02030aa:	6705                	lui	a4,0x1
ffffffffc02030ac:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02030ae:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02030b0:	fef74ee3          	blt	a4,a5,ffffffffc02030ac <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02030b4:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02030b6:	e25ff0ef          	jal	ra,ffffffffc0202eda <__slob_get_free_pages.isra.0>
ffffffffc02030ba:	e488                	sd	a0,8(s1)
ffffffffc02030bc:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02030be:	c935                	beqz	a0,ffffffffc0203132 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02030c0:	100027f3          	csrr	a5,sstatus
ffffffffc02030c4:	8b89                	andi	a5,a5,2
ffffffffc02030c6:	e3a1                	bnez	a5,ffffffffc0203106 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc02030c8:	00013797          	auipc	a5,0x13
ffffffffc02030cc:	3e878793          	addi	a5,a5,1000 # ffffffffc02164b0 <bigblocks>
ffffffffc02030d0:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02030d2:	00013717          	auipc	a4,0x13
ffffffffc02030d6:	3c973f23          	sd	s1,990(a4) # ffffffffc02164b0 <bigblocks>
		bb->next = bigblocks;
ffffffffc02030da:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc02030dc:	8522                	mv	a0,s0
ffffffffc02030de:	60e2                	ld	ra,24(sp)
ffffffffc02030e0:	6442                	ld	s0,16(sp)
ffffffffc02030e2:	64a2                	ld	s1,8(sp)
ffffffffc02030e4:	6902                	ld	s2,0(sp)
ffffffffc02030e6:	6105                	addi	sp,sp,32
ffffffffc02030e8:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02030ea:	0541                	addi	a0,a0,16
ffffffffc02030ec:	e71ff0ef          	jal	ra,ffffffffc0202f5c <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc02030f0:	01050413          	addi	s0,a0,16
ffffffffc02030f4:	f565                	bnez	a0,ffffffffc02030dc <kmalloc+0x5c>
ffffffffc02030f6:	4401                	li	s0,0
}
ffffffffc02030f8:	8522                	mv	a0,s0
ffffffffc02030fa:	60e2                	ld	ra,24(sp)
ffffffffc02030fc:	6442                	ld	s0,16(sp)
ffffffffc02030fe:	64a2                	ld	s1,8(sp)
ffffffffc0203100:	6902                	ld	s2,0(sp)
ffffffffc0203102:	6105                	addi	sp,sp,32
ffffffffc0203104:	8082                	ret
        intr_disable();
ffffffffc0203106:	cd4fd0ef          	jal	ra,ffffffffc02005da <intr_disable>
		bb->next = bigblocks;
ffffffffc020310a:	00013797          	auipc	a5,0x13
ffffffffc020310e:	3a678793          	addi	a5,a5,934 # ffffffffc02164b0 <bigblocks>
ffffffffc0203112:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203114:	00013717          	auipc	a4,0x13
ffffffffc0203118:	38973e23          	sd	s1,924(a4) # ffffffffc02164b0 <bigblocks>
		bb->next = bigblocks;
ffffffffc020311c:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc020311e:	cb6fd0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
ffffffffc0203122:	6480                	ld	s0,8(s1)
}
ffffffffc0203124:	60e2                	ld	ra,24(sp)
ffffffffc0203126:	64a2                	ld	s1,8(sp)
ffffffffc0203128:	8522                	mv	a0,s0
ffffffffc020312a:	6442                	ld	s0,16(sp)
ffffffffc020312c:	6902                	ld	s2,0(sp)
ffffffffc020312e:	6105                	addi	sp,sp,32
ffffffffc0203130:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0203132:	45e1                	li	a1,24
ffffffffc0203134:	8526                	mv	a0,s1
ffffffffc0203136:	c8fff0ef          	jal	ra,ffffffffc0202dc4 <slob_free>
  return __kmalloc(size, 0);
ffffffffc020313a:	b74d                	j	ffffffffc02030dc <kmalloc+0x5c>

ffffffffc020313c <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc020313c:	0e050663          	beqz	a0,ffffffffc0203228 <kfree+0xec>
{
ffffffffc0203140:	1101                	addi	sp,sp,-32
ffffffffc0203142:	e426                	sd	s1,8(sp)
ffffffffc0203144:	ec06                	sd	ra,24(sp)
ffffffffc0203146:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0203148:	03451793          	slli	a5,a0,0x34
ffffffffc020314c:	84aa                	mv	s1,a0
ffffffffc020314e:	eb8d                	bnez	a5,ffffffffc0203180 <kfree+0x44>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203150:	100027f3          	csrr	a5,sstatus
ffffffffc0203154:	8b89                	andi	a5,a5,2
ffffffffc0203156:	e3c5                	bnez	a5,ffffffffc02031f6 <kfree+0xba>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203158:	00013797          	auipc	a5,0x13
ffffffffc020315c:	35878793          	addi	a5,a5,856 # ffffffffc02164b0 <bigblocks>
ffffffffc0203160:	6394                	ld	a3,0(a5)
ffffffffc0203162:	ce99                	beqz	a3,ffffffffc0203180 <kfree+0x44>
			if (bb->pages == block) {
ffffffffc0203164:	669c                	ld	a5,8(a3)
ffffffffc0203166:	6a80                	ld	s0,16(a3)
ffffffffc0203168:	0cf50163          	beq	a0,a5,ffffffffc020322a <kfree+0xee>
    return 0;
ffffffffc020316c:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020316e:	c801                	beqz	s0,ffffffffc020317e <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0203170:	6418                	ld	a4,8(s0)
ffffffffc0203172:	681c                	ld	a5,16(s0)
ffffffffc0203174:	00970f63          	beq	a4,s1,ffffffffc0203192 <kfree+0x56>
ffffffffc0203178:	86a2                	mv	a3,s0
ffffffffc020317a:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020317c:	f875                	bnez	s0,ffffffffc0203170 <kfree+0x34>
    if (flag) {
ffffffffc020317e:	ea51                	bnez	a2,ffffffffc0203212 <kfree+0xd6>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0203180:	6442                	ld	s0,16(sp)
ffffffffc0203182:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203184:	ff048513          	addi	a0,s1,-16
}
ffffffffc0203188:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020318a:	4581                	li	a1,0
}
ffffffffc020318c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020318e:	c37ff06f          	j	ffffffffc0202dc4 <slob_free>
				*last = bb->next;
ffffffffc0203192:	ea9c                	sd	a5,16(a3)
ffffffffc0203194:	e659                	bnez	a2,ffffffffc0203222 <kfree+0xe6>
    return pa2page(PADDR(kva));
ffffffffc0203196:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc020319a:	4018                	lw	a4,0(s0)
ffffffffc020319c:	08f4ed63          	bltu	s1,a5,ffffffffc0203236 <kfree+0xfa>
ffffffffc02031a0:	00013797          	auipc	a5,0x13
ffffffffc02031a4:	34878793          	addi	a5,a5,840 # ffffffffc02164e8 <va_pa_offset>
ffffffffc02031a8:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02031aa:	00013797          	auipc	a5,0x13
ffffffffc02031ae:	2e678793          	addi	a5,a5,742 # ffffffffc0216490 <npage>
ffffffffc02031b2:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02031b4:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc02031b6:	80b1                	srli	s1,s1,0xc
ffffffffc02031b8:	08f4fc63          	bleu	a5,s1,ffffffffc0203250 <kfree+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc02031bc:	00004797          	auipc	a5,0x4
ffffffffc02031c0:	0a478793          	addi	a5,a5,164 # ffffffffc0207260 <nbase>
ffffffffc02031c4:	639c                	ld	a5,0(a5)
ffffffffc02031c6:	00013697          	auipc	a3,0x13
ffffffffc02031ca:	33268693          	addi	a3,a3,818 # ffffffffc02164f8 <pages>
ffffffffc02031ce:	6288                	ld	a0,0(a3)
ffffffffc02031d0:	8c9d                	sub	s1,s1,a5
ffffffffc02031d2:	00349793          	slli	a5,s1,0x3
ffffffffc02031d6:	94be                	add	s1,s1,a5
ffffffffc02031d8:	048e                	slli	s1,s1,0x3
  free_pages(kva2page(kva), 1 << order);
ffffffffc02031da:	4585                	li	a1,1
ffffffffc02031dc:	9526                	add	a0,a0,s1
ffffffffc02031de:	00e595bb          	sllw	a1,a1,a4
ffffffffc02031e2:	ac1fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02031e6:	8522                	mv	a0,s0
}
ffffffffc02031e8:	6442                	ld	s0,16(sp)
ffffffffc02031ea:	60e2                	ld	ra,24(sp)
ffffffffc02031ec:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02031ee:	45e1                	li	a1,24
}
ffffffffc02031f0:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02031f2:	bd3ff06f          	j	ffffffffc0202dc4 <slob_free>
        intr_disable();
ffffffffc02031f6:	be4fd0ef          	jal	ra,ffffffffc02005da <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02031fa:	00013797          	auipc	a5,0x13
ffffffffc02031fe:	2b678793          	addi	a5,a5,694 # ffffffffc02164b0 <bigblocks>
ffffffffc0203202:	6394                	ld	a3,0(a5)
ffffffffc0203204:	c699                	beqz	a3,ffffffffc0203212 <kfree+0xd6>
			if (bb->pages == block) {
ffffffffc0203206:	669c                	ld	a5,8(a3)
ffffffffc0203208:	6a80                	ld	s0,16(a3)
ffffffffc020320a:	00f48763          	beq	s1,a5,ffffffffc0203218 <kfree+0xdc>
        return 1;
ffffffffc020320e:	4605                	li	a2,1
ffffffffc0203210:	bfb9                	j	ffffffffc020316e <kfree+0x32>
        intr_enable();
ffffffffc0203212:	bc2fd0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
ffffffffc0203216:	b7ad                	j	ffffffffc0203180 <kfree+0x44>
				*last = bb->next;
ffffffffc0203218:	00013797          	auipc	a5,0x13
ffffffffc020321c:	2887bc23          	sd	s0,664(a5) # ffffffffc02164b0 <bigblocks>
ffffffffc0203220:	8436                	mv	s0,a3
ffffffffc0203222:	bb2fd0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
ffffffffc0203226:	bf85                	j	ffffffffc0203196 <kfree+0x5a>
ffffffffc0203228:	8082                	ret
ffffffffc020322a:	00013797          	auipc	a5,0x13
ffffffffc020322e:	2887b323          	sd	s0,646(a5) # ffffffffc02164b0 <bigblocks>
ffffffffc0203232:	8436                	mv	s0,a3
ffffffffc0203234:	b78d                	j	ffffffffc0203196 <kfree+0x5a>
    return pa2page(PADDR(kva));
ffffffffc0203236:	86a6                	mv	a3,s1
ffffffffc0203238:	00003617          	auipc	a2,0x3
ffffffffc020323c:	9b060613          	addi	a2,a2,-1616 # ffffffffc0205be8 <commands+0x990>
ffffffffc0203240:	06e00593          	li	a1,110
ffffffffc0203244:	00003517          	auipc	a0,0x3
ffffffffc0203248:	92450513          	addi	a0,a0,-1756 # ffffffffc0205b68 <commands+0x910>
ffffffffc020324c:	f8bfc0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203250:	00003617          	auipc	a2,0x3
ffffffffc0203254:	8f860613          	addi	a2,a2,-1800 # ffffffffc0205b48 <commands+0x8f0>
ffffffffc0203258:	06200593          	li	a1,98
ffffffffc020325c:	00003517          	auipc	a0,0x3
ffffffffc0203260:	90c50513          	addi	a0,a0,-1780 # ffffffffc0205b68 <commands+0x910>
ffffffffc0203264:	f73fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203268 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203268:	00013797          	auipc	a5,0x13
ffffffffc020326c:	36878793          	addi	a5,a5,872 # ffffffffc02165d0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203270:	f51c                	sd	a5,40(a0)
ffffffffc0203272:	e79c                	sd	a5,8(a5)
ffffffffc0203274:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203276:	4501                	li	a0,0
ffffffffc0203278:	8082                	ret

ffffffffc020327a <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc020327a:	4501                	li	a0,0
ffffffffc020327c:	8082                	ret

ffffffffc020327e <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020327e:	4501                	li	a0,0
ffffffffc0203280:	8082                	ret

ffffffffc0203282 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203282:	4501                	li	a0,0
ffffffffc0203284:	8082                	ret

ffffffffc0203286 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203286:	711d                	addi	sp,sp,-96
ffffffffc0203288:	fc4e                	sd	s3,56(sp)
ffffffffc020328a:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020328c:	00003517          	auipc	a0,0x3
ffffffffc0203290:	61450513          	addi	a0,a0,1556 # ffffffffc02068a0 <commands+0x1648>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203294:	698d                	lui	s3,0x3
ffffffffc0203296:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203298:	e8a2                	sd	s0,80(sp)
ffffffffc020329a:	e4a6                	sd	s1,72(sp)
ffffffffc020329c:	ec86                	sd	ra,88(sp)
ffffffffc020329e:	e0ca                	sd	s2,64(sp)
ffffffffc02032a0:	f456                	sd	s5,40(sp)
ffffffffc02032a2:	f05a                	sd	s6,32(sp)
ffffffffc02032a4:	ec5e                	sd	s7,24(sp)
ffffffffc02032a6:	e862                	sd	s8,16(sp)
ffffffffc02032a8:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02032aa:	00013417          	auipc	s0,0x13
ffffffffc02032ae:	1ee40413          	addi	s0,s0,494 # ffffffffc0216498 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02032b2:	e1ffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02032b6:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02032ba:	4004                	lw	s1,0(s0)
ffffffffc02032bc:	4791                	li	a5,4
ffffffffc02032be:	2481                	sext.w	s1,s1
ffffffffc02032c0:	14f49963          	bne	s1,a5,ffffffffc0203412 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02032c4:	00003517          	auipc	a0,0x3
ffffffffc02032c8:	61c50513          	addi	a0,a0,1564 # ffffffffc02068e0 <commands+0x1688>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02032cc:	6a85                	lui	s5,0x1
ffffffffc02032ce:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02032d0:	e01fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02032d4:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02032d8:	00042903          	lw	s2,0(s0)
ffffffffc02032dc:	2901                	sext.w	s2,s2
ffffffffc02032de:	2a991a63          	bne	s2,s1,ffffffffc0203592 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02032e2:	00003517          	auipc	a0,0x3
ffffffffc02032e6:	62650513          	addi	a0,a0,1574 # ffffffffc0206908 <commands+0x16b0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02032ea:	6b91                	lui	s7,0x4
ffffffffc02032ec:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02032ee:	de3fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02032f2:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02032f6:	4004                	lw	s1,0(s0)
ffffffffc02032f8:	2481                	sext.w	s1,s1
ffffffffc02032fa:	27249c63          	bne	s1,s2,ffffffffc0203572 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02032fe:	00003517          	auipc	a0,0x3
ffffffffc0203302:	63250513          	addi	a0,a0,1586 # ffffffffc0206930 <commands+0x16d8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203306:	6909                	lui	s2,0x2
ffffffffc0203308:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020330a:	dc7fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020330e:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203312:	401c                	lw	a5,0(s0)
ffffffffc0203314:	2781                	sext.w	a5,a5
ffffffffc0203316:	22979e63          	bne	a5,s1,ffffffffc0203552 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020331a:	00003517          	auipc	a0,0x3
ffffffffc020331e:	63e50513          	addi	a0,a0,1598 # ffffffffc0206958 <commands+0x1700>
ffffffffc0203322:	daffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203326:	6795                	lui	a5,0x5
ffffffffc0203328:	4739                	li	a4,14
ffffffffc020332a:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020332e:	4004                	lw	s1,0(s0)
ffffffffc0203330:	4795                	li	a5,5
ffffffffc0203332:	2481                	sext.w	s1,s1
ffffffffc0203334:	1ef49f63          	bne	s1,a5,ffffffffc0203532 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203338:	00003517          	auipc	a0,0x3
ffffffffc020333c:	5f850513          	addi	a0,a0,1528 # ffffffffc0206930 <commands+0x16d8>
ffffffffc0203340:	d91fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203344:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203348:	401c                	lw	a5,0(s0)
ffffffffc020334a:	2781                	sext.w	a5,a5
ffffffffc020334c:	1c979363          	bne	a5,s1,ffffffffc0203512 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203350:	00003517          	auipc	a0,0x3
ffffffffc0203354:	59050513          	addi	a0,a0,1424 # ffffffffc02068e0 <commands+0x1688>
ffffffffc0203358:	d79fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020335c:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203360:	401c                	lw	a5,0(s0)
ffffffffc0203362:	4719                	li	a4,6
ffffffffc0203364:	2781                	sext.w	a5,a5
ffffffffc0203366:	18e79663          	bne	a5,a4,ffffffffc02034f2 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020336a:	00003517          	auipc	a0,0x3
ffffffffc020336e:	5c650513          	addi	a0,a0,1478 # ffffffffc0206930 <commands+0x16d8>
ffffffffc0203372:	d5ffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203376:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc020337a:	401c                	lw	a5,0(s0)
ffffffffc020337c:	471d                	li	a4,7
ffffffffc020337e:	2781                	sext.w	a5,a5
ffffffffc0203380:	14e79963          	bne	a5,a4,ffffffffc02034d2 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203384:	00003517          	auipc	a0,0x3
ffffffffc0203388:	51c50513          	addi	a0,a0,1308 # ffffffffc02068a0 <commands+0x1648>
ffffffffc020338c:	d45fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203390:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203394:	401c                	lw	a5,0(s0)
ffffffffc0203396:	4721                	li	a4,8
ffffffffc0203398:	2781                	sext.w	a5,a5
ffffffffc020339a:	10e79c63          	bne	a5,a4,ffffffffc02034b2 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020339e:	00003517          	auipc	a0,0x3
ffffffffc02033a2:	56a50513          	addi	a0,a0,1386 # ffffffffc0206908 <commands+0x16b0>
ffffffffc02033a6:	d2bfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02033aa:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02033ae:	401c                	lw	a5,0(s0)
ffffffffc02033b0:	4725                	li	a4,9
ffffffffc02033b2:	2781                	sext.w	a5,a5
ffffffffc02033b4:	0ce79f63          	bne	a5,a4,ffffffffc0203492 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02033b8:	00003517          	auipc	a0,0x3
ffffffffc02033bc:	5a050513          	addi	a0,a0,1440 # ffffffffc0206958 <commands+0x1700>
ffffffffc02033c0:	d11fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02033c4:	6795                	lui	a5,0x5
ffffffffc02033c6:	4739                	li	a4,14
ffffffffc02033c8:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc02033cc:	4004                	lw	s1,0(s0)
ffffffffc02033ce:	47a9                	li	a5,10
ffffffffc02033d0:	2481                	sext.w	s1,s1
ffffffffc02033d2:	0af49063          	bne	s1,a5,ffffffffc0203472 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02033d6:	00003517          	auipc	a0,0x3
ffffffffc02033da:	50a50513          	addi	a0,a0,1290 # ffffffffc02068e0 <commands+0x1688>
ffffffffc02033de:	cf3fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02033e2:	6785                	lui	a5,0x1
ffffffffc02033e4:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02033e8:	06979563          	bne	a5,s1,ffffffffc0203452 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc02033ec:	401c                	lw	a5,0(s0)
ffffffffc02033ee:	472d                	li	a4,11
ffffffffc02033f0:	2781                	sext.w	a5,a5
ffffffffc02033f2:	04e79063          	bne	a5,a4,ffffffffc0203432 <_fifo_check_swap+0x1ac>
}
ffffffffc02033f6:	60e6                	ld	ra,88(sp)
ffffffffc02033f8:	6446                	ld	s0,80(sp)
ffffffffc02033fa:	64a6                	ld	s1,72(sp)
ffffffffc02033fc:	6906                	ld	s2,64(sp)
ffffffffc02033fe:	79e2                	ld	s3,56(sp)
ffffffffc0203400:	7a42                	ld	s4,48(sp)
ffffffffc0203402:	7aa2                	ld	s5,40(sp)
ffffffffc0203404:	7b02                	ld	s6,32(sp)
ffffffffc0203406:	6be2                	ld	s7,24(sp)
ffffffffc0203408:	6c42                	ld	s8,16(sp)
ffffffffc020340a:	6ca2                	ld	s9,8(sp)
ffffffffc020340c:	4501                	li	a0,0
ffffffffc020340e:	6125                	addi	sp,sp,96
ffffffffc0203410:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203412:	00003697          	auipc	a3,0x3
ffffffffc0203416:	2ae68693          	addi	a3,a3,686 # ffffffffc02066c0 <commands+0x1468>
ffffffffc020341a:	00003617          	auipc	a2,0x3
ffffffffc020341e:	84e60613          	addi	a2,a2,-1970 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203422:	05100593          	li	a1,81
ffffffffc0203426:	00003517          	auipc	a0,0x3
ffffffffc020342a:	4a250513          	addi	a0,a0,1186 # ffffffffc02068c8 <commands+0x1670>
ffffffffc020342e:	da9fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==11);
ffffffffc0203432:	00003697          	auipc	a3,0x3
ffffffffc0203436:	5d668693          	addi	a3,a3,1494 # ffffffffc0206a08 <commands+0x17b0>
ffffffffc020343a:	00003617          	auipc	a2,0x3
ffffffffc020343e:	82e60613          	addi	a2,a2,-2002 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203442:	07300593          	li	a1,115
ffffffffc0203446:	00003517          	auipc	a0,0x3
ffffffffc020344a:	48250513          	addi	a0,a0,1154 # ffffffffc02068c8 <commands+0x1670>
ffffffffc020344e:	d89fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203452:	00003697          	auipc	a3,0x3
ffffffffc0203456:	58e68693          	addi	a3,a3,1422 # ffffffffc02069e0 <commands+0x1788>
ffffffffc020345a:	00003617          	auipc	a2,0x3
ffffffffc020345e:	80e60613          	addi	a2,a2,-2034 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203462:	07100593          	li	a1,113
ffffffffc0203466:	00003517          	auipc	a0,0x3
ffffffffc020346a:	46250513          	addi	a0,a0,1122 # ffffffffc02068c8 <commands+0x1670>
ffffffffc020346e:	d69fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==10);
ffffffffc0203472:	00003697          	auipc	a3,0x3
ffffffffc0203476:	55e68693          	addi	a3,a3,1374 # ffffffffc02069d0 <commands+0x1778>
ffffffffc020347a:	00002617          	auipc	a2,0x2
ffffffffc020347e:	7ee60613          	addi	a2,a2,2030 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203482:	06f00593          	li	a1,111
ffffffffc0203486:	00003517          	auipc	a0,0x3
ffffffffc020348a:	44250513          	addi	a0,a0,1090 # ffffffffc02068c8 <commands+0x1670>
ffffffffc020348e:	d49fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==9);
ffffffffc0203492:	00003697          	auipc	a3,0x3
ffffffffc0203496:	52e68693          	addi	a3,a3,1326 # ffffffffc02069c0 <commands+0x1768>
ffffffffc020349a:	00002617          	auipc	a2,0x2
ffffffffc020349e:	7ce60613          	addi	a2,a2,1998 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02034a2:	06c00593          	li	a1,108
ffffffffc02034a6:	00003517          	auipc	a0,0x3
ffffffffc02034aa:	42250513          	addi	a0,a0,1058 # ffffffffc02068c8 <commands+0x1670>
ffffffffc02034ae:	d29fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==8);
ffffffffc02034b2:	00003697          	auipc	a3,0x3
ffffffffc02034b6:	4fe68693          	addi	a3,a3,1278 # ffffffffc02069b0 <commands+0x1758>
ffffffffc02034ba:	00002617          	auipc	a2,0x2
ffffffffc02034be:	7ae60613          	addi	a2,a2,1966 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02034c2:	06900593          	li	a1,105
ffffffffc02034c6:	00003517          	auipc	a0,0x3
ffffffffc02034ca:	40250513          	addi	a0,a0,1026 # ffffffffc02068c8 <commands+0x1670>
ffffffffc02034ce:	d09fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==7);
ffffffffc02034d2:	00003697          	auipc	a3,0x3
ffffffffc02034d6:	4ce68693          	addi	a3,a3,1230 # ffffffffc02069a0 <commands+0x1748>
ffffffffc02034da:	00002617          	auipc	a2,0x2
ffffffffc02034de:	78e60613          	addi	a2,a2,1934 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02034e2:	06600593          	li	a1,102
ffffffffc02034e6:	00003517          	auipc	a0,0x3
ffffffffc02034ea:	3e250513          	addi	a0,a0,994 # ffffffffc02068c8 <commands+0x1670>
ffffffffc02034ee:	ce9fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==6);
ffffffffc02034f2:	00003697          	auipc	a3,0x3
ffffffffc02034f6:	49e68693          	addi	a3,a3,1182 # ffffffffc0206990 <commands+0x1738>
ffffffffc02034fa:	00002617          	auipc	a2,0x2
ffffffffc02034fe:	76e60613          	addi	a2,a2,1902 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203502:	06300593          	li	a1,99
ffffffffc0203506:	00003517          	auipc	a0,0x3
ffffffffc020350a:	3c250513          	addi	a0,a0,962 # ffffffffc02068c8 <commands+0x1670>
ffffffffc020350e:	cc9fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==5);
ffffffffc0203512:	00003697          	auipc	a3,0x3
ffffffffc0203516:	46e68693          	addi	a3,a3,1134 # ffffffffc0206980 <commands+0x1728>
ffffffffc020351a:	00002617          	auipc	a2,0x2
ffffffffc020351e:	74e60613          	addi	a2,a2,1870 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203522:	06000593          	li	a1,96
ffffffffc0203526:	00003517          	auipc	a0,0x3
ffffffffc020352a:	3a250513          	addi	a0,a0,930 # ffffffffc02068c8 <commands+0x1670>
ffffffffc020352e:	ca9fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==5);
ffffffffc0203532:	00003697          	auipc	a3,0x3
ffffffffc0203536:	44e68693          	addi	a3,a3,1102 # ffffffffc0206980 <commands+0x1728>
ffffffffc020353a:	00002617          	auipc	a2,0x2
ffffffffc020353e:	72e60613          	addi	a2,a2,1838 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203542:	05d00593          	li	a1,93
ffffffffc0203546:	00003517          	auipc	a0,0x3
ffffffffc020354a:	38250513          	addi	a0,a0,898 # ffffffffc02068c8 <commands+0x1670>
ffffffffc020354e:	c89fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==4);
ffffffffc0203552:	00003697          	auipc	a3,0x3
ffffffffc0203556:	16e68693          	addi	a3,a3,366 # ffffffffc02066c0 <commands+0x1468>
ffffffffc020355a:	00002617          	auipc	a2,0x2
ffffffffc020355e:	70e60613          	addi	a2,a2,1806 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203562:	05a00593          	li	a1,90
ffffffffc0203566:	00003517          	auipc	a0,0x3
ffffffffc020356a:	36250513          	addi	a0,a0,866 # ffffffffc02068c8 <commands+0x1670>
ffffffffc020356e:	c69fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==4);
ffffffffc0203572:	00003697          	auipc	a3,0x3
ffffffffc0203576:	14e68693          	addi	a3,a3,334 # ffffffffc02066c0 <commands+0x1468>
ffffffffc020357a:	00002617          	auipc	a2,0x2
ffffffffc020357e:	6ee60613          	addi	a2,a2,1774 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203582:	05700593          	li	a1,87
ffffffffc0203586:	00003517          	auipc	a0,0x3
ffffffffc020358a:	34250513          	addi	a0,a0,834 # ffffffffc02068c8 <commands+0x1670>
ffffffffc020358e:	c49fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==4);
ffffffffc0203592:	00003697          	auipc	a3,0x3
ffffffffc0203596:	12e68693          	addi	a3,a3,302 # ffffffffc02066c0 <commands+0x1468>
ffffffffc020359a:	00002617          	auipc	a2,0x2
ffffffffc020359e:	6ce60613          	addi	a2,a2,1742 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02035a2:	05400593          	li	a1,84
ffffffffc02035a6:	00003517          	auipc	a0,0x3
ffffffffc02035aa:	32250513          	addi	a0,a0,802 # ffffffffc02068c8 <commands+0x1670>
ffffffffc02035ae:	c29fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02035b2 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02035b2:	751c                	ld	a5,40(a0)
{
ffffffffc02035b4:	1141                	addi	sp,sp,-16
ffffffffc02035b6:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02035b8:	cf91                	beqz	a5,ffffffffc02035d4 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02035ba:	ee0d                	bnez	a2,ffffffffc02035f4 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02035bc:	679c                	ld	a5,8(a5)
}
ffffffffc02035be:	60a2                	ld	ra,8(sp)
ffffffffc02035c0:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02035c2:	6394                	ld	a3,0(a5)
ffffffffc02035c4:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02035c6:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc02035ca:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02035cc:	e314                	sd	a3,0(a4)
ffffffffc02035ce:	e19c                	sd	a5,0(a1)
}
ffffffffc02035d0:	0141                	addi	sp,sp,16
ffffffffc02035d2:	8082                	ret
         assert(head != NULL);
ffffffffc02035d4:	00003697          	auipc	a3,0x3
ffffffffc02035d8:	46468693          	addi	a3,a3,1124 # ffffffffc0206a38 <commands+0x17e0>
ffffffffc02035dc:	00002617          	auipc	a2,0x2
ffffffffc02035e0:	68c60613          	addi	a2,a2,1676 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02035e4:	04100593          	li	a1,65
ffffffffc02035e8:	00003517          	auipc	a0,0x3
ffffffffc02035ec:	2e050513          	addi	a0,a0,736 # ffffffffc02068c8 <commands+0x1670>
ffffffffc02035f0:	be7fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(in_tick==0);
ffffffffc02035f4:	00003697          	auipc	a3,0x3
ffffffffc02035f8:	45468693          	addi	a3,a3,1108 # ffffffffc0206a48 <commands+0x17f0>
ffffffffc02035fc:	00002617          	auipc	a2,0x2
ffffffffc0203600:	66c60613          	addi	a2,a2,1644 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203604:	04200593          	li	a1,66
ffffffffc0203608:	00003517          	auipc	a0,0x3
ffffffffc020360c:	2c050513          	addi	a0,a0,704 # ffffffffc02068c8 <commands+0x1670>
ffffffffc0203610:	bc7fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203614 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203614:	03060713          	addi	a4,a2,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203618:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020361a:	cb09                	beqz	a4,ffffffffc020362c <_fifo_map_swappable+0x18>
ffffffffc020361c:	cb81                	beqz	a5,ffffffffc020362c <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020361e:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203620:	e398                	sd	a4,0(a5)
}
ffffffffc0203622:	4501                	li	a0,0
ffffffffc0203624:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203626:	fe1c                	sd	a5,56(a2)
    elm->prev = prev;
ffffffffc0203628:	fa14                	sd	a3,48(a2)
ffffffffc020362a:	8082                	ret
{
ffffffffc020362c:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc020362e:	00003697          	auipc	a3,0x3
ffffffffc0203632:	3ea68693          	addi	a3,a3,1002 # ffffffffc0206a18 <commands+0x17c0>
ffffffffc0203636:	00002617          	auipc	a2,0x2
ffffffffc020363a:	63260613          	addi	a2,a2,1586 # ffffffffc0205c68 <commands+0xa10>
ffffffffc020363e:	03200593          	li	a1,50
ffffffffc0203642:	00003517          	auipc	a0,0x3
ffffffffc0203646:	28650513          	addi	a0,a0,646 # ffffffffc02068c8 <commands+0x1670>
{
ffffffffc020364a:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020364c:	b8bfc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203650 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203650:	00013797          	auipc	a5,0x13
ffffffffc0203654:	f9078793          	addi	a5,a5,-112 # ffffffffc02165e0 <free_area>
ffffffffc0203658:	e79c                	sd	a5,8(a5)
ffffffffc020365a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020365c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203660:	8082                	ret

ffffffffc0203662 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203662:	00013517          	auipc	a0,0x13
ffffffffc0203666:	f8e56503          	lwu	a0,-114(a0) # ffffffffc02165f0 <free_area+0x10>
ffffffffc020366a:	8082                	ret

ffffffffc020366c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020366c:	715d                	addi	sp,sp,-80
ffffffffc020366e:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0203670:	00013917          	auipc	s2,0x13
ffffffffc0203674:	f7090913          	addi	s2,s2,-144 # ffffffffc02165e0 <free_area>
ffffffffc0203678:	00893783          	ld	a5,8(s2)
ffffffffc020367c:	e486                	sd	ra,72(sp)
ffffffffc020367e:	e0a2                	sd	s0,64(sp)
ffffffffc0203680:	fc26                	sd	s1,56(sp)
ffffffffc0203682:	f44e                	sd	s3,40(sp)
ffffffffc0203684:	f052                	sd	s4,32(sp)
ffffffffc0203686:	ec56                	sd	s5,24(sp)
ffffffffc0203688:	e85a                	sd	s6,16(sp)
ffffffffc020368a:	e45e                	sd	s7,8(sp)
ffffffffc020368c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020368e:	31278f63          	beq	a5,s2,ffffffffc02039ac <default_check+0x340>
ffffffffc0203692:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203696:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203698:	8b05                	andi	a4,a4,1
ffffffffc020369a:	30070d63          	beqz	a4,ffffffffc02039b4 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc020369e:	4401                	li	s0,0
ffffffffc02036a0:	4481                	li	s1,0
ffffffffc02036a2:	a031                	j	ffffffffc02036ae <default_check+0x42>
ffffffffc02036a4:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc02036a8:	8b09                	andi	a4,a4,2
ffffffffc02036aa:	30070563          	beqz	a4,ffffffffc02039b4 <default_check+0x348>
        count ++, total += p->property;
ffffffffc02036ae:	ff87a703          	lw	a4,-8(a5)
ffffffffc02036b2:	679c                	ld	a5,8(a5)
ffffffffc02036b4:	2485                	addiw	s1,s1,1
ffffffffc02036b6:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02036b8:	ff2796e3          	bne	a5,s2,ffffffffc02036a4 <default_check+0x38>
ffffffffc02036bc:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc02036be:	e2afd0ef          	jal	ra,ffffffffc0200ce8 <nr_free_pages>
ffffffffc02036c2:	75351963          	bne	a0,s3,ffffffffc0203e14 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02036c6:	4505                	li	a0,1
ffffffffc02036c8:	d52fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02036cc:	8a2a                	mv	s4,a0
ffffffffc02036ce:	48050363          	beqz	a0,ffffffffc0203b54 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02036d2:	4505                	li	a0,1
ffffffffc02036d4:	d46fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02036d8:	89aa                	mv	s3,a0
ffffffffc02036da:	74050d63          	beqz	a0,ffffffffc0203e34 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02036de:	4505                	li	a0,1
ffffffffc02036e0:	d3afd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02036e4:	8aaa                	mv	s5,a0
ffffffffc02036e6:	4e050763          	beqz	a0,ffffffffc0203bd4 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02036ea:	2f3a0563          	beq	s4,s3,ffffffffc02039d4 <default_check+0x368>
ffffffffc02036ee:	2eaa0363          	beq	s4,a0,ffffffffc02039d4 <default_check+0x368>
ffffffffc02036f2:	2ea98163          	beq	s3,a0,ffffffffc02039d4 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02036f6:	000a2783          	lw	a5,0(s4)
ffffffffc02036fa:	2e079d63          	bnez	a5,ffffffffc02039f4 <default_check+0x388>
ffffffffc02036fe:	0009a783          	lw	a5,0(s3)
ffffffffc0203702:	2e079963          	bnez	a5,ffffffffc02039f4 <default_check+0x388>
ffffffffc0203706:	411c                	lw	a5,0(a0)
ffffffffc0203708:	2e079663          	bnez	a5,ffffffffc02039f4 <default_check+0x388>
    return page - pages + nbase;
ffffffffc020370c:	00013797          	auipc	a5,0x13
ffffffffc0203710:	dec78793          	addi	a5,a5,-532 # ffffffffc02164f8 <pages>
ffffffffc0203714:	639c                	ld	a5,0(a5)
ffffffffc0203716:	00002717          	auipc	a4,0x2
ffffffffc020371a:	3f270713          	addi	a4,a4,1010 # ffffffffc0205b08 <commands+0x8b0>
ffffffffc020371e:	630c                	ld	a1,0(a4)
ffffffffc0203720:	40fa0733          	sub	a4,s4,a5
ffffffffc0203724:	870d                	srai	a4,a4,0x3
ffffffffc0203726:	02b70733          	mul	a4,a4,a1
ffffffffc020372a:	00004697          	auipc	a3,0x4
ffffffffc020372e:	b3668693          	addi	a3,a3,-1226 # ffffffffc0207260 <nbase>
ffffffffc0203732:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203734:	00013697          	auipc	a3,0x13
ffffffffc0203738:	d5c68693          	addi	a3,a3,-676 # ffffffffc0216490 <npage>
ffffffffc020373c:	6294                	ld	a3,0(a3)
ffffffffc020373e:	06b2                	slli	a3,a3,0xc
ffffffffc0203740:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203742:	0732                	slli	a4,a4,0xc
ffffffffc0203744:	2cd77863          	bleu	a3,a4,ffffffffc0203a14 <default_check+0x3a8>
    return page - pages + nbase;
ffffffffc0203748:	40f98733          	sub	a4,s3,a5
ffffffffc020374c:	870d                	srai	a4,a4,0x3
ffffffffc020374e:	02b70733          	mul	a4,a4,a1
ffffffffc0203752:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203754:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203756:	4ed77f63          	bleu	a3,a4,ffffffffc0203c54 <default_check+0x5e8>
    return page - pages + nbase;
ffffffffc020375a:	40f507b3          	sub	a5,a0,a5
ffffffffc020375e:	878d                	srai	a5,a5,0x3
ffffffffc0203760:	02b787b3          	mul	a5,a5,a1
ffffffffc0203764:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203766:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203768:	34d7f663          	bleu	a3,a5,ffffffffc0203ab4 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc020376c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020376e:	00093c03          	ld	s8,0(s2)
ffffffffc0203772:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0203776:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc020377a:	00013797          	auipc	a5,0x13
ffffffffc020377e:	e727b723          	sd	s2,-402(a5) # ffffffffc02165e8 <free_area+0x8>
ffffffffc0203782:	00013797          	auipc	a5,0x13
ffffffffc0203786:	e527bf23          	sd	s2,-418(a5) # ffffffffc02165e0 <free_area>
    nr_free = 0;
ffffffffc020378a:	00013797          	auipc	a5,0x13
ffffffffc020378e:	e607a323          	sw	zero,-410(a5) # ffffffffc02165f0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0203792:	c88fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc0203796:	2e051f63          	bnez	a0,ffffffffc0203a94 <default_check+0x428>
    free_page(p0);
ffffffffc020379a:	4585                	li	a1,1
ffffffffc020379c:	8552                	mv	a0,s4
ffffffffc020379e:	d04fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    free_page(p1);
ffffffffc02037a2:	4585                	li	a1,1
ffffffffc02037a4:	854e                	mv	a0,s3
ffffffffc02037a6:	cfcfd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    free_page(p2);
ffffffffc02037aa:	4585                	li	a1,1
ffffffffc02037ac:	8556                	mv	a0,s5
ffffffffc02037ae:	cf4fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    assert(nr_free == 3);
ffffffffc02037b2:	01092703          	lw	a4,16(s2)
ffffffffc02037b6:	478d                	li	a5,3
ffffffffc02037b8:	2af71e63          	bne	a4,a5,ffffffffc0203a74 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02037bc:	4505                	li	a0,1
ffffffffc02037be:	c5cfd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02037c2:	89aa                	mv	s3,a0
ffffffffc02037c4:	28050863          	beqz	a0,ffffffffc0203a54 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02037c8:	4505                	li	a0,1
ffffffffc02037ca:	c50fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02037ce:	8aaa                	mv	s5,a0
ffffffffc02037d0:	3e050263          	beqz	a0,ffffffffc0203bb4 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02037d4:	4505                	li	a0,1
ffffffffc02037d6:	c44fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02037da:	8a2a                	mv	s4,a0
ffffffffc02037dc:	3a050c63          	beqz	a0,ffffffffc0203b94 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc02037e0:	4505                	li	a0,1
ffffffffc02037e2:	c38fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02037e6:	38051763          	bnez	a0,ffffffffc0203b74 <default_check+0x508>
    free_page(p0);
ffffffffc02037ea:	4585                	li	a1,1
ffffffffc02037ec:	854e                	mv	a0,s3
ffffffffc02037ee:	cb4fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02037f2:	00893783          	ld	a5,8(s2)
ffffffffc02037f6:	23278f63          	beq	a5,s2,ffffffffc0203a34 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc02037fa:	4505                	li	a0,1
ffffffffc02037fc:	c1efd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc0203800:	32a99a63          	bne	s3,a0,ffffffffc0203b34 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0203804:	4505                	li	a0,1
ffffffffc0203806:	c14fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc020380a:	30051563          	bnez	a0,ffffffffc0203b14 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc020380e:	01092783          	lw	a5,16(s2)
ffffffffc0203812:	2e079163          	bnez	a5,ffffffffc0203af4 <default_check+0x488>
    free_page(p);
ffffffffc0203816:	854e                	mv	a0,s3
ffffffffc0203818:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020381a:	00013797          	auipc	a5,0x13
ffffffffc020381e:	dd87b323          	sd	s8,-570(a5) # ffffffffc02165e0 <free_area>
ffffffffc0203822:	00013797          	auipc	a5,0x13
ffffffffc0203826:	dd77b323          	sd	s7,-570(a5) # ffffffffc02165e8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020382a:	00013797          	auipc	a5,0x13
ffffffffc020382e:	dd67a323          	sw	s6,-570(a5) # ffffffffc02165f0 <free_area+0x10>
    free_page(p);
ffffffffc0203832:	c70fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    free_page(p1);
ffffffffc0203836:	4585                	li	a1,1
ffffffffc0203838:	8556                	mv	a0,s5
ffffffffc020383a:	c68fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    free_page(p2);
ffffffffc020383e:	4585                	li	a1,1
ffffffffc0203840:	8552                	mv	a0,s4
ffffffffc0203842:	c60fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0203846:	4515                	li	a0,5
ffffffffc0203848:	bd2fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc020384c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020384e:	28050363          	beqz	a0,ffffffffc0203ad4 <default_check+0x468>
ffffffffc0203852:	651c                	ld	a5,8(a0)
ffffffffc0203854:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0203856:	8b85                	andi	a5,a5,1
ffffffffc0203858:	54079e63          	bnez	a5,ffffffffc0203db4 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020385c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020385e:	00093b03          	ld	s6,0(s2)
ffffffffc0203862:	00893a83          	ld	s5,8(s2)
ffffffffc0203866:	00013797          	auipc	a5,0x13
ffffffffc020386a:	d727bd23          	sd	s2,-646(a5) # ffffffffc02165e0 <free_area>
ffffffffc020386e:	00013797          	auipc	a5,0x13
ffffffffc0203872:	d727bd23          	sd	s2,-646(a5) # ffffffffc02165e8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0203876:	ba4fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc020387a:	50051d63          	bnez	a0,ffffffffc0203d94 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020387e:	09098a13          	addi	s4,s3,144
ffffffffc0203882:	8552                	mv	a0,s4
ffffffffc0203884:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0203886:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020388a:	00013797          	auipc	a5,0x13
ffffffffc020388e:	d607a323          	sw	zero,-666(a5) # ffffffffc02165f0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0203892:	c10fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0203896:	4511                	li	a0,4
ffffffffc0203898:	b82fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc020389c:	4c051c63          	bnez	a0,ffffffffc0203d74 <default_check+0x708>
ffffffffc02038a0:	0989b783          	ld	a5,152(s3)
ffffffffc02038a4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02038a6:	8b85                	andi	a5,a5,1
ffffffffc02038a8:	4a078663          	beqz	a5,ffffffffc0203d54 <default_check+0x6e8>
ffffffffc02038ac:	0a89a703          	lw	a4,168(s3)
ffffffffc02038b0:	478d                	li	a5,3
ffffffffc02038b2:	4af71163          	bne	a4,a5,ffffffffc0203d54 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02038b6:	450d                	li	a0,3
ffffffffc02038b8:	b62fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02038bc:	8c2a                	mv	s8,a0
ffffffffc02038be:	46050b63          	beqz	a0,ffffffffc0203d34 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc02038c2:	4505                	li	a0,1
ffffffffc02038c4:	b56fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc02038c8:	44051663          	bnez	a0,ffffffffc0203d14 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc02038cc:	438a1463          	bne	s4,s8,ffffffffc0203cf4 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02038d0:	4585                	li	a1,1
ffffffffc02038d2:	854e                	mv	a0,s3
ffffffffc02038d4:	bcefd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    free_pages(p1, 3);
ffffffffc02038d8:	458d                	li	a1,3
ffffffffc02038da:	8552                	mv	a0,s4
ffffffffc02038dc:	bc6fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
ffffffffc02038e0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02038e4:	04898c13          	addi	s8,s3,72
ffffffffc02038e8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02038ea:	8b85                	andi	a5,a5,1
ffffffffc02038ec:	3e078463          	beqz	a5,ffffffffc0203cd4 <default_check+0x668>
ffffffffc02038f0:	0189a703          	lw	a4,24(s3)
ffffffffc02038f4:	4785                	li	a5,1
ffffffffc02038f6:	3cf71f63          	bne	a4,a5,ffffffffc0203cd4 <default_check+0x668>
ffffffffc02038fa:	008a3783          	ld	a5,8(s4)
ffffffffc02038fe:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203900:	8b85                	andi	a5,a5,1
ffffffffc0203902:	3a078963          	beqz	a5,ffffffffc0203cb4 <default_check+0x648>
ffffffffc0203906:	018a2703          	lw	a4,24(s4)
ffffffffc020390a:	478d                	li	a5,3
ffffffffc020390c:	3af71463          	bne	a4,a5,ffffffffc0203cb4 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203910:	4505                	li	a0,1
ffffffffc0203912:	b08fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc0203916:	36a99f63          	bne	s3,a0,ffffffffc0203c94 <default_check+0x628>
    free_page(p0);
ffffffffc020391a:	4585                	li	a1,1
ffffffffc020391c:	b86fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203920:	4509                	li	a0,2
ffffffffc0203922:	af8fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc0203926:	34aa1763          	bne	s4,a0,ffffffffc0203c74 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc020392a:	4589                	li	a1,2
ffffffffc020392c:	b76fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    free_page(p2);
ffffffffc0203930:	4585                	li	a1,1
ffffffffc0203932:	8562                	mv	a0,s8
ffffffffc0203934:	b6efd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203938:	4515                	li	a0,5
ffffffffc020393a:	ae0fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc020393e:	89aa                	mv	s3,a0
ffffffffc0203940:	48050a63          	beqz	a0,ffffffffc0203dd4 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0203944:	4505                	li	a0,1
ffffffffc0203946:	ad4fd0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
ffffffffc020394a:	2e051563          	bnez	a0,ffffffffc0203c34 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc020394e:	01092783          	lw	a5,16(s2)
ffffffffc0203952:	2c079163          	bnez	a5,ffffffffc0203c14 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0203956:	4595                	li	a1,5
ffffffffc0203958:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020395a:	00013797          	auipc	a5,0x13
ffffffffc020395e:	c977ab23          	sw	s7,-874(a5) # ffffffffc02165f0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0203962:	00013797          	auipc	a5,0x13
ffffffffc0203966:	c767bf23          	sd	s6,-898(a5) # ffffffffc02165e0 <free_area>
ffffffffc020396a:	00013797          	auipc	a5,0x13
ffffffffc020396e:	c757bf23          	sd	s5,-898(a5) # ffffffffc02165e8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0203972:	b30fd0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    return listelm->next;
ffffffffc0203976:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020397a:	01278963          	beq	a5,s2,ffffffffc020398c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020397e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203982:	679c                	ld	a5,8(a5)
ffffffffc0203984:	34fd                	addiw	s1,s1,-1
ffffffffc0203986:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203988:	ff279be3          	bne	a5,s2,ffffffffc020397e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc020398c:	26049463          	bnez	s1,ffffffffc0203bf4 <default_check+0x588>
    assert(total == 0);
ffffffffc0203990:	46041263          	bnez	s0,ffffffffc0203df4 <default_check+0x788>
}
ffffffffc0203994:	60a6                	ld	ra,72(sp)
ffffffffc0203996:	6406                	ld	s0,64(sp)
ffffffffc0203998:	74e2                	ld	s1,56(sp)
ffffffffc020399a:	7942                	ld	s2,48(sp)
ffffffffc020399c:	79a2                	ld	s3,40(sp)
ffffffffc020399e:	7a02                	ld	s4,32(sp)
ffffffffc02039a0:	6ae2                	ld	s5,24(sp)
ffffffffc02039a2:	6b42                	ld	s6,16(sp)
ffffffffc02039a4:	6ba2                	ld	s7,8(sp)
ffffffffc02039a6:	6c02                	ld	s8,0(sp)
ffffffffc02039a8:	6161                	addi	sp,sp,80
ffffffffc02039aa:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02039ac:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02039ae:	4401                	li	s0,0
ffffffffc02039b0:	4481                	li	s1,0
ffffffffc02039b2:	b331                	j	ffffffffc02036be <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02039b4:	00003697          	auipc	a3,0x3
ffffffffc02039b8:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0206520 <commands+0x12c8>
ffffffffc02039bc:	00002617          	auipc	a2,0x2
ffffffffc02039c0:	2ac60613          	addi	a2,a2,684 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02039c4:	0f000593          	li	a1,240
ffffffffc02039c8:	00003517          	auipc	a0,0x3
ffffffffc02039cc:	0a850513          	addi	a0,a0,168 # ffffffffc0206a70 <commands+0x1818>
ffffffffc02039d0:	807fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02039d4:	00003697          	auipc	a3,0x3
ffffffffc02039d8:	11468693          	addi	a3,a3,276 # ffffffffc0206ae8 <commands+0x1890>
ffffffffc02039dc:	00002617          	auipc	a2,0x2
ffffffffc02039e0:	28c60613          	addi	a2,a2,652 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02039e4:	0bd00593          	li	a1,189
ffffffffc02039e8:	00003517          	auipc	a0,0x3
ffffffffc02039ec:	08850513          	addi	a0,a0,136 # ffffffffc0206a70 <commands+0x1818>
ffffffffc02039f0:	fe6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02039f4:	00003697          	auipc	a3,0x3
ffffffffc02039f8:	11c68693          	addi	a3,a3,284 # ffffffffc0206b10 <commands+0x18b8>
ffffffffc02039fc:	00002617          	auipc	a2,0x2
ffffffffc0203a00:	26c60613          	addi	a2,a2,620 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203a04:	0be00593          	li	a1,190
ffffffffc0203a08:	00003517          	auipc	a0,0x3
ffffffffc0203a0c:	06850513          	addi	a0,a0,104 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203a10:	fc6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203a14:	00003697          	auipc	a3,0x3
ffffffffc0203a18:	13c68693          	addi	a3,a3,316 # ffffffffc0206b50 <commands+0x18f8>
ffffffffc0203a1c:	00002617          	auipc	a2,0x2
ffffffffc0203a20:	24c60613          	addi	a2,a2,588 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203a24:	0c000593          	li	a1,192
ffffffffc0203a28:	00003517          	auipc	a0,0x3
ffffffffc0203a2c:	04850513          	addi	a0,a0,72 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203a30:	fa6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0203a34:	00003697          	auipc	a3,0x3
ffffffffc0203a38:	1a468693          	addi	a3,a3,420 # ffffffffc0206bd8 <commands+0x1980>
ffffffffc0203a3c:	00002617          	auipc	a2,0x2
ffffffffc0203a40:	22c60613          	addi	a2,a2,556 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203a44:	0d900593          	li	a1,217
ffffffffc0203a48:	00003517          	auipc	a0,0x3
ffffffffc0203a4c:	02850513          	addi	a0,a0,40 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203a50:	f86fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203a54:	00003697          	auipc	a3,0x3
ffffffffc0203a58:	03468693          	addi	a3,a3,52 # ffffffffc0206a88 <commands+0x1830>
ffffffffc0203a5c:	00002617          	auipc	a2,0x2
ffffffffc0203a60:	20c60613          	addi	a2,a2,524 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203a64:	0d200593          	li	a1,210
ffffffffc0203a68:	00003517          	auipc	a0,0x3
ffffffffc0203a6c:	00850513          	addi	a0,a0,8 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203a70:	f66fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free == 3);
ffffffffc0203a74:	00003697          	auipc	a3,0x3
ffffffffc0203a78:	15468693          	addi	a3,a3,340 # ffffffffc0206bc8 <commands+0x1970>
ffffffffc0203a7c:	00002617          	auipc	a2,0x2
ffffffffc0203a80:	1ec60613          	addi	a2,a2,492 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203a84:	0d000593          	li	a1,208
ffffffffc0203a88:	00003517          	auipc	a0,0x3
ffffffffc0203a8c:	fe850513          	addi	a0,a0,-24 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203a90:	f46fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203a94:	00003697          	auipc	a3,0x3
ffffffffc0203a98:	11c68693          	addi	a3,a3,284 # ffffffffc0206bb0 <commands+0x1958>
ffffffffc0203a9c:	00002617          	auipc	a2,0x2
ffffffffc0203aa0:	1cc60613          	addi	a2,a2,460 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203aa4:	0cb00593          	li	a1,203
ffffffffc0203aa8:	00003517          	auipc	a0,0x3
ffffffffc0203aac:	fc850513          	addi	a0,a0,-56 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203ab0:	f26fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203ab4:	00003697          	auipc	a3,0x3
ffffffffc0203ab8:	0dc68693          	addi	a3,a3,220 # ffffffffc0206b90 <commands+0x1938>
ffffffffc0203abc:	00002617          	auipc	a2,0x2
ffffffffc0203ac0:	1ac60613          	addi	a2,a2,428 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203ac4:	0c200593          	li	a1,194
ffffffffc0203ac8:	00003517          	auipc	a0,0x3
ffffffffc0203acc:	fa850513          	addi	a0,a0,-88 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203ad0:	f06fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(p0 != NULL);
ffffffffc0203ad4:	00003697          	auipc	a3,0x3
ffffffffc0203ad8:	13c68693          	addi	a3,a3,316 # ffffffffc0206c10 <commands+0x19b8>
ffffffffc0203adc:	00002617          	auipc	a2,0x2
ffffffffc0203ae0:	18c60613          	addi	a2,a2,396 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203ae4:	0f800593          	li	a1,248
ffffffffc0203ae8:	00003517          	auipc	a0,0x3
ffffffffc0203aec:	f8850513          	addi	a0,a0,-120 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203af0:	ee6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free == 0);
ffffffffc0203af4:	00003697          	auipc	a3,0x3
ffffffffc0203af8:	bdc68693          	addi	a3,a3,-1060 # ffffffffc02066d0 <commands+0x1478>
ffffffffc0203afc:	00002617          	auipc	a2,0x2
ffffffffc0203b00:	16c60613          	addi	a2,a2,364 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203b04:	0df00593          	li	a1,223
ffffffffc0203b08:	00003517          	auipc	a0,0x3
ffffffffc0203b0c:	f6850513          	addi	a0,a0,-152 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203b10:	ec6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203b14:	00003697          	auipc	a3,0x3
ffffffffc0203b18:	09c68693          	addi	a3,a3,156 # ffffffffc0206bb0 <commands+0x1958>
ffffffffc0203b1c:	00002617          	auipc	a2,0x2
ffffffffc0203b20:	14c60613          	addi	a2,a2,332 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203b24:	0dd00593          	li	a1,221
ffffffffc0203b28:	00003517          	auipc	a0,0x3
ffffffffc0203b2c:	f4850513          	addi	a0,a0,-184 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203b30:	ea6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0203b34:	00003697          	auipc	a3,0x3
ffffffffc0203b38:	0bc68693          	addi	a3,a3,188 # ffffffffc0206bf0 <commands+0x1998>
ffffffffc0203b3c:	00002617          	auipc	a2,0x2
ffffffffc0203b40:	12c60613          	addi	a2,a2,300 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203b44:	0dc00593          	li	a1,220
ffffffffc0203b48:	00003517          	auipc	a0,0x3
ffffffffc0203b4c:	f2850513          	addi	a0,a0,-216 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203b50:	e86fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203b54:	00003697          	auipc	a3,0x3
ffffffffc0203b58:	f3468693          	addi	a3,a3,-204 # ffffffffc0206a88 <commands+0x1830>
ffffffffc0203b5c:	00002617          	auipc	a2,0x2
ffffffffc0203b60:	10c60613          	addi	a2,a2,268 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203b64:	0b900593          	li	a1,185
ffffffffc0203b68:	00003517          	auipc	a0,0x3
ffffffffc0203b6c:	f0850513          	addi	a0,a0,-248 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203b70:	e66fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203b74:	00003697          	auipc	a3,0x3
ffffffffc0203b78:	03c68693          	addi	a3,a3,60 # ffffffffc0206bb0 <commands+0x1958>
ffffffffc0203b7c:	00002617          	auipc	a2,0x2
ffffffffc0203b80:	0ec60613          	addi	a2,a2,236 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203b84:	0d600593          	li	a1,214
ffffffffc0203b88:	00003517          	auipc	a0,0x3
ffffffffc0203b8c:	ee850513          	addi	a0,a0,-280 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203b90:	e46fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203b94:	00003697          	auipc	a3,0x3
ffffffffc0203b98:	f3468693          	addi	a3,a3,-204 # ffffffffc0206ac8 <commands+0x1870>
ffffffffc0203b9c:	00002617          	auipc	a2,0x2
ffffffffc0203ba0:	0cc60613          	addi	a2,a2,204 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203ba4:	0d400593          	li	a1,212
ffffffffc0203ba8:	00003517          	auipc	a0,0x3
ffffffffc0203bac:	ec850513          	addi	a0,a0,-312 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203bb0:	e26fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203bb4:	00003697          	auipc	a3,0x3
ffffffffc0203bb8:	ef468693          	addi	a3,a3,-268 # ffffffffc0206aa8 <commands+0x1850>
ffffffffc0203bbc:	00002617          	auipc	a2,0x2
ffffffffc0203bc0:	0ac60613          	addi	a2,a2,172 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203bc4:	0d300593          	li	a1,211
ffffffffc0203bc8:	00003517          	auipc	a0,0x3
ffffffffc0203bcc:	ea850513          	addi	a0,a0,-344 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203bd0:	e06fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203bd4:	00003697          	auipc	a3,0x3
ffffffffc0203bd8:	ef468693          	addi	a3,a3,-268 # ffffffffc0206ac8 <commands+0x1870>
ffffffffc0203bdc:	00002617          	auipc	a2,0x2
ffffffffc0203be0:	08c60613          	addi	a2,a2,140 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203be4:	0bb00593          	li	a1,187
ffffffffc0203be8:	00003517          	auipc	a0,0x3
ffffffffc0203bec:	e8850513          	addi	a0,a0,-376 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203bf0:	de6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(count == 0);
ffffffffc0203bf4:	00003697          	auipc	a3,0x3
ffffffffc0203bf8:	16c68693          	addi	a3,a3,364 # ffffffffc0206d60 <commands+0x1b08>
ffffffffc0203bfc:	00002617          	auipc	a2,0x2
ffffffffc0203c00:	06c60613          	addi	a2,a2,108 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203c04:	12500593          	li	a1,293
ffffffffc0203c08:	00003517          	auipc	a0,0x3
ffffffffc0203c0c:	e6850513          	addi	a0,a0,-408 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203c10:	dc6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free == 0);
ffffffffc0203c14:	00003697          	auipc	a3,0x3
ffffffffc0203c18:	abc68693          	addi	a3,a3,-1348 # ffffffffc02066d0 <commands+0x1478>
ffffffffc0203c1c:	00002617          	auipc	a2,0x2
ffffffffc0203c20:	04c60613          	addi	a2,a2,76 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203c24:	11a00593          	li	a1,282
ffffffffc0203c28:	00003517          	auipc	a0,0x3
ffffffffc0203c2c:	e4850513          	addi	a0,a0,-440 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203c30:	da6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203c34:	00003697          	auipc	a3,0x3
ffffffffc0203c38:	f7c68693          	addi	a3,a3,-132 # ffffffffc0206bb0 <commands+0x1958>
ffffffffc0203c3c:	00002617          	auipc	a2,0x2
ffffffffc0203c40:	02c60613          	addi	a2,a2,44 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203c44:	11800593          	li	a1,280
ffffffffc0203c48:	00003517          	auipc	a0,0x3
ffffffffc0203c4c:	e2850513          	addi	a0,a0,-472 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203c50:	d86fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203c54:	00003697          	auipc	a3,0x3
ffffffffc0203c58:	f1c68693          	addi	a3,a3,-228 # ffffffffc0206b70 <commands+0x1918>
ffffffffc0203c5c:	00002617          	auipc	a2,0x2
ffffffffc0203c60:	00c60613          	addi	a2,a2,12 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203c64:	0c100593          	li	a1,193
ffffffffc0203c68:	00003517          	auipc	a0,0x3
ffffffffc0203c6c:	e0850513          	addi	a0,a0,-504 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203c70:	d66fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203c74:	00003697          	auipc	a3,0x3
ffffffffc0203c78:	0ac68693          	addi	a3,a3,172 # ffffffffc0206d20 <commands+0x1ac8>
ffffffffc0203c7c:	00002617          	auipc	a2,0x2
ffffffffc0203c80:	fec60613          	addi	a2,a2,-20 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203c84:	11200593          	li	a1,274
ffffffffc0203c88:	00003517          	auipc	a0,0x3
ffffffffc0203c8c:	de850513          	addi	a0,a0,-536 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203c90:	d46fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203c94:	00003697          	auipc	a3,0x3
ffffffffc0203c98:	06c68693          	addi	a3,a3,108 # ffffffffc0206d00 <commands+0x1aa8>
ffffffffc0203c9c:	00002617          	auipc	a2,0x2
ffffffffc0203ca0:	fcc60613          	addi	a2,a2,-52 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203ca4:	11000593          	li	a1,272
ffffffffc0203ca8:	00003517          	auipc	a0,0x3
ffffffffc0203cac:	dc850513          	addi	a0,a0,-568 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203cb0:	d26fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203cb4:	00003697          	auipc	a3,0x3
ffffffffc0203cb8:	02468693          	addi	a3,a3,36 # ffffffffc0206cd8 <commands+0x1a80>
ffffffffc0203cbc:	00002617          	auipc	a2,0x2
ffffffffc0203cc0:	fac60613          	addi	a2,a2,-84 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203cc4:	10e00593          	li	a1,270
ffffffffc0203cc8:	00003517          	auipc	a0,0x3
ffffffffc0203ccc:	da850513          	addi	a0,a0,-600 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203cd0:	d06fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203cd4:	00003697          	auipc	a3,0x3
ffffffffc0203cd8:	fdc68693          	addi	a3,a3,-36 # ffffffffc0206cb0 <commands+0x1a58>
ffffffffc0203cdc:	00002617          	auipc	a2,0x2
ffffffffc0203ce0:	f8c60613          	addi	a2,a2,-116 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203ce4:	10d00593          	li	a1,269
ffffffffc0203ce8:	00003517          	auipc	a0,0x3
ffffffffc0203cec:	d8850513          	addi	a0,a0,-632 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203cf0:	ce6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203cf4:	00003697          	auipc	a3,0x3
ffffffffc0203cf8:	fac68693          	addi	a3,a3,-84 # ffffffffc0206ca0 <commands+0x1a48>
ffffffffc0203cfc:	00002617          	auipc	a2,0x2
ffffffffc0203d00:	f6c60613          	addi	a2,a2,-148 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203d04:	10800593          	li	a1,264
ffffffffc0203d08:	00003517          	auipc	a0,0x3
ffffffffc0203d0c:	d6850513          	addi	a0,a0,-664 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203d10:	cc6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203d14:	00003697          	auipc	a3,0x3
ffffffffc0203d18:	e9c68693          	addi	a3,a3,-356 # ffffffffc0206bb0 <commands+0x1958>
ffffffffc0203d1c:	00002617          	auipc	a2,0x2
ffffffffc0203d20:	f4c60613          	addi	a2,a2,-180 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203d24:	10700593          	li	a1,263
ffffffffc0203d28:	00003517          	auipc	a0,0x3
ffffffffc0203d2c:	d4850513          	addi	a0,a0,-696 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203d30:	ca6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203d34:	00003697          	auipc	a3,0x3
ffffffffc0203d38:	f4c68693          	addi	a3,a3,-180 # ffffffffc0206c80 <commands+0x1a28>
ffffffffc0203d3c:	00002617          	auipc	a2,0x2
ffffffffc0203d40:	f2c60613          	addi	a2,a2,-212 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203d44:	10600593          	li	a1,262
ffffffffc0203d48:	00003517          	auipc	a0,0x3
ffffffffc0203d4c:	d2850513          	addi	a0,a0,-728 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203d50:	c86fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203d54:	00003697          	auipc	a3,0x3
ffffffffc0203d58:	efc68693          	addi	a3,a3,-260 # ffffffffc0206c50 <commands+0x19f8>
ffffffffc0203d5c:	00002617          	auipc	a2,0x2
ffffffffc0203d60:	f0c60613          	addi	a2,a2,-244 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203d64:	10500593          	li	a1,261
ffffffffc0203d68:	00003517          	auipc	a0,0x3
ffffffffc0203d6c:	d0850513          	addi	a0,a0,-760 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203d70:	c66fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203d74:	00003697          	auipc	a3,0x3
ffffffffc0203d78:	ec468693          	addi	a3,a3,-316 # ffffffffc0206c38 <commands+0x19e0>
ffffffffc0203d7c:	00002617          	auipc	a2,0x2
ffffffffc0203d80:	eec60613          	addi	a2,a2,-276 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203d84:	10400593          	li	a1,260
ffffffffc0203d88:	00003517          	auipc	a0,0x3
ffffffffc0203d8c:	ce850513          	addi	a0,a0,-792 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203d90:	c46fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203d94:	00003697          	auipc	a3,0x3
ffffffffc0203d98:	e1c68693          	addi	a3,a3,-484 # ffffffffc0206bb0 <commands+0x1958>
ffffffffc0203d9c:	00002617          	auipc	a2,0x2
ffffffffc0203da0:	ecc60613          	addi	a2,a2,-308 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203da4:	0fe00593          	li	a1,254
ffffffffc0203da8:	00003517          	auipc	a0,0x3
ffffffffc0203dac:	cc850513          	addi	a0,a0,-824 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203db0:	c26fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203db4:	00003697          	auipc	a3,0x3
ffffffffc0203db8:	e6c68693          	addi	a3,a3,-404 # ffffffffc0206c20 <commands+0x19c8>
ffffffffc0203dbc:	00002617          	auipc	a2,0x2
ffffffffc0203dc0:	eac60613          	addi	a2,a2,-340 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203dc4:	0f900593          	li	a1,249
ffffffffc0203dc8:	00003517          	auipc	a0,0x3
ffffffffc0203dcc:	ca850513          	addi	a0,a0,-856 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203dd0:	c06fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203dd4:	00003697          	auipc	a3,0x3
ffffffffc0203dd8:	f6c68693          	addi	a3,a3,-148 # ffffffffc0206d40 <commands+0x1ae8>
ffffffffc0203ddc:	00002617          	auipc	a2,0x2
ffffffffc0203de0:	e8c60613          	addi	a2,a2,-372 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203de4:	11700593          	li	a1,279
ffffffffc0203de8:	00003517          	auipc	a0,0x3
ffffffffc0203dec:	c8850513          	addi	a0,a0,-888 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203df0:	be6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(total == 0);
ffffffffc0203df4:	00003697          	auipc	a3,0x3
ffffffffc0203df8:	f7c68693          	addi	a3,a3,-132 # ffffffffc0206d70 <commands+0x1b18>
ffffffffc0203dfc:	00002617          	auipc	a2,0x2
ffffffffc0203e00:	e6c60613          	addi	a2,a2,-404 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203e04:	12600593          	li	a1,294
ffffffffc0203e08:	00003517          	auipc	a0,0x3
ffffffffc0203e0c:	c6850513          	addi	a0,a0,-920 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203e10:	bc6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203e14:	00002697          	auipc	a3,0x2
ffffffffc0203e18:	71c68693          	addi	a3,a3,1820 # ffffffffc0206530 <commands+0x12d8>
ffffffffc0203e1c:	00002617          	auipc	a2,0x2
ffffffffc0203e20:	e4c60613          	addi	a2,a2,-436 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203e24:	0f300593          	li	a1,243
ffffffffc0203e28:	00003517          	auipc	a0,0x3
ffffffffc0203e2c:	c4850513          	addi	a0,a0,-952 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203e30:	ba6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203e34:	00003697          	auipc	a3,0x3
ffffffffc0203e38:	c7468693          	addi	a3,a3,-908 # ffffffffc0206aa8 <commands+0x1850>
ffffffffc0203e3c:	00002617          	auipc	a2,0x2
ffffffffc0203e40:	e2c60613          	addi	a2,a2,-468 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203e44:	0ba00593          	li	a1,186
ffffffffc0203e48:	00003517          	auipc	a0,0x3
ffffffffc0203e4c:	c2850513          	addi	a0,a0,-984 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203e50:	b86fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203e54 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203e54:	1141                	addi	sp,sp,-16
ffffffffc0203e56:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203e58:	18058063          	beqz	a1,ffffffffc0203fd8 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0203e5c:	00359693          	slli	a3,a1,0x3
ffffffffc0203e60:	96ae                	add	a3,a3,a1
ffffffffc0203e62:	068e                	slli	a3,a3,0x3
ffffffffc0203e64:	96aa                	add	a3,a3,a0
ffffffffc0203e66:	02d50d63          	beq	a0,a3,ffffffffc0203ea0 <default_free_pages+0x4c>
ffffffffc0203e6a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203e6c:	8b85                	andi	a5,a5,1
ffffffffc0203e6e:	14079563          	bnez	a5,ffffffffc0203fb8 <default_free_pages+0x164>
ffffffffc0203e72:	651c                	ld	a5,8(a0)
ffffffffc0203e74:	8385                	srli	a5,a5,0x1
ffffffffc0203e76:	8b85                	andi	a5,a5,1
ffffffffc0203e78:	14079063          	bnez	a5,ffffffffc0203fb8 <default_free_pages+0x164>
ffffffffc0203e7c:	87aa                	mv	a5,a0
ffffffffc0203e7e:	a809                	j	ffffffffc0203e90 <default_free_pages+0x3c>
ffffffffc0203e80:	6798                	ld	a4,8(a5)
ffffffffc0203e82:	8b05                	andi	a4,a4,1
ffffffffc0203e84:	12071a63          	bnez	a4,ffffffffc0203fb8 <default_free_pages+0x164>
ffffffffc0203e88:	6798                	ld	a4,8(a5)
ffffffffc0203e8a:	8b09                	andi	a4,a4,2
ffffffffc0203e8c:	12071663          	bnez	a4,ffffffffc0203fb8 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0203e90:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203e94:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203e98:	04878793          	addi	a5,a5,72
ffffffffc0203e9c:	fed792e3          	bne	a5,a3,ffffffffc0203e80 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0203ea0:	2581                	sext.w	a1,a1
ffffffffc0203ea2:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0203ea4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203ea8:	4789                	li	a5,2
ffffffffc0203eaa:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203eae:	00012697          	auipc	a3,0x12
ffffffffc0203eb2:	73268693          	addi	a3,a3,1842 # ffffffffc02165e0 <free_area>
ffffffffc0203eb6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203eb8:	669c                	ld	a5,8(a3)
ffffffffc0203eba:	9db9                	addw	a1,a1,a4
ffffffffc0203ebc:	00012717          	auipc	a4,0x12
ffffffffc0203ec0:	72b72a23          	sw	a1,1844(a4) # ffffffffc02165f0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203ec4:	08d78f63          	beq	a5,a3,ffffffffc0203f62 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0203ec8:	fe078713          	addi	a4,a5,-32
ffffffffc0203ecc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203ece:	4801                	li	a6,0
ffffffffc0203ed0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0203ed4:	00e56a63          	bltu	a0,a4,ffffffffc0203ee8 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0203ed8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203eda:	02d70563          	beq	a4,a3,ffffffffc0203f04 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203ede:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203ee0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0203ee4:	fee57ae3          	bleu	a4,a0,ffffffffc0203ed8 <default_free_pages+0x84>
ffffffffc0203ee8:	00080663          	beqz	a6,ffffffffc0203ef4 <default_free_pages+0xa0>
ffffffffc0203eec:	00012817          	auipc	a6,0x12
ffffffffc0203ef0:	6eb83a23          	sd	a1,1780(a6) # ffffffffc02165e0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203ef4:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203ef6:	e390                	sd	a2,0(a5)
ffffffffc0203ef8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0203efa:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203efc:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc0203efe:	02d59163          	bne	a1,a3,ffffffffc0203f20 <default_free_pages+0xcc>
ffffffffc0203f02:	a091                	j	ffffffffc0203f46 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0203f04:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203f06:	f514                	sd	a3,40(a0)
ffffffffc0203f08:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203f0a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0203f0c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203f0e:	00d70563          	beq	a4,a3,ffffffffc0203f18 <default_free_pages+0xc4>
ffffffffc0203f12:	4805                	li	a6,1
ffffffffc0203f14:	87ba                	mv	a5,a4
ffffffffc0203f16:	b7e9                	j	ffffffffc0203ee0 <default_free_pages+0x8c>
ffffffffc0203f18:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0203f1a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0203f1c:	02d78163          	beq	a5,a3,ffffffffc0203f3e <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0203f20:	ff85a803          	lw	a6,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0203f24:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0203f28:	02081713          	slli	a4,a6,0x20
ffffffffc0203f2c:	9301                	srli	a4,a4,0x20
ffffffffc0203f2e:	00371793          	slli	a5,a4,0x3
ffffffffc0203f32:	97ba                	add	a5,a5,a4
ffffffffc0203f34:	078e                	slli	a5,a5,0x3
ffffffffc0203f36:	97b2                	add	a5,a5,a2
ffffffffc0203f38:	02f50e63          	beq	a0,a5,ffffffffc0203f74 <default_free_pages+0x120>
ffffffffc0203f3c:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc0203f3e:	fe078713          	addi	a4,a5,-32
ffffffffc0203f42:	00d78d63          	beq	a5,a3,ffffffffc0203f5c <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0203f46:	4d0c                	lw	a1,24(a0)
ffffffffc0203f48:	02059613          	slli	a2,a1,0x20
ffffffffc0203f4c:	9201                	srli	a2,a2,0x20
ffffffffc0203f4e:	00361693          	slli	a3,a2,0x3
ffffffffc0203f52:	96b2                	add	a3,a3,a2
ffffffffc0203f54:	068e                	slli	a3,a3,0x3
ffffffffc0203f56:	96aa                	add	a3,a3,a0
ffffffffc0203f58:	04d70063          	beq	a4,a3,ffffffffc0203f98 <default_free_pages+0x144>
}
ffffffffc0203f5c:	60a2                	ld	ra,8(sp)
ffffffffc0203f5e:	0141                	addi	sp,sp,16
ffffffffc0203f60:	8082                	ret
ffffffffc0203f62:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203f64:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0203f68:	e398                	sd	a4,0(a5)
ffffffffc0203f6a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203f6c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203f6e:	f11c                	sd	a5,32(a0)
}
ffffffffc0203f70:	0141                	addi	sp,sp,16
ffffffffc0203f72:	8082                	ret
            p->property += base->property;
ffffffffc0203f74:	4d1c                	lw	a5,24(a0)
ffffffffc0203f76:	0107883b          	addw	a6,a5,a6
ffffffffc0203f7a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203f7e:	57f5                	li	a5,-3
ffffffffc0203f80:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f84:	02053803          	ld	a6,32(a0)
ffffffffc0203f88:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc0203f8a:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203f8c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0203f90:	659c                	ld	a5,8(a1)
ffffffffc0203f92:	01073023          	sd	a6,0(a4)
ffffffffc0203f96:	b765                	j	ffffffffc0203f3e <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0203f98:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203f9c:	fe878693          	addi	a3,a5,-24
ffffffffc0203fa0:	9db9                	addw	a1,a1,a4
ffffffffc0203fa2:	cd0c                	sw	a1,24(a0)
ffffffffc0203fa4:	5775                	li	a4,-3
ffffffffc0203fa6:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203faa:	6398                	ld	a4,0(a5)
ffffffffc0203fac:	679c                	ld	a5,8(a5)
}
ffffffffc0203fae:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203fb0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203fb2:	e398                	sd	a4,0(a5)
ffffffffc0203fb4:	0141                	addi	sp,sp,16
ffffffffc0203fb6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203fb8:	00003697          	auipc	a3,0x3
ffffffffc0203fbc:	dc868693          	addi	a3,a3,-568 # ffffffffc0206d80 <commands+0x1b28>
ffffffffc0203fc0:	00002617          	auipc	a2,0x2
ffffffffc0203fc4:	ca860613          	addi	a2,a2,-856 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203fc8:	08300593          	li	a1,131
ffffffffc0203fcc:	00003517          	auipc	a0,0x3
ffffffffc0203fd0:	aa450513          	addi	a0,a0,-1372 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203fd4:	a02fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(n > 0);
ffffffffc0203fd8:	00003697          	auipc	a3,0x3
ffffffffc0203fdc:	dd068693          	addi	a3,a3,-560 # ffffffffc0206da8 <commands+0x1b50>
ffffffffc0203fe0:	00002617          	auipc	a2,0x2
ffffffffc0203fe4:	c8860613          	addi	a2,a2,-888 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0203fe8:	08000593          	li	a1,128
ffffffffc0203fec:	00003517          	auipc	a0,0x3
ffffffffc0203ff0:	a8450513          	addi	a0,a0,-1404 # ffffffffc0206a70 <commands+0x1818>
ffffffffc0203ff4:	9e2fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203ff8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203ff8:	cd51                	beqz	a0,ffffffffc0204094 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc0203ffa:	00012597          	auipc	a1,0x12
ffffffffc0203ffe:	5e658593          	addi	a1,a1,1510 # ffffffffc02165e0 <free_area>
ffffffffc0204002:	0105a803          	lw	a6,16(a1)
ffffffffc0204006:	862a                	mv	a2,a0
ffffffffc0204008:	02081793          	slli	a5,a6,0x20
ffffffffc020400c:	9381                	srli	a5,a5,0x20
ffffffffc020400e:	00a7ee63          	bltu	a5,a0,ffffffffc020402a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0204012:	87ae                	mv	a5,a1
ffffffffc0204014:	a801                	j	ffffffffc0204024 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0204016:	ff87a703          	lw	a4,-8(a5)
ffffffffc020401a:	02071693          	slli	a3,a4,0x20
ffffffffc020401e:	9281                	srli	a3,a3,0x20
ffffffffc0204020:	00c6f763          	bleu	a2,a3,ffffffffc020402e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0204024:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204026:	feb798e3          	bne	a5,a1,ffffffffc0204016 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020402a:	4501                	li	a0,0
}
ffffffffc020402c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020402e:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0204032:	dd6d                	beqz	a0,ffffffffc020402c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0204034:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204038:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020403c:	00060e1b          	sext.w	t3,a2
ffffffffc0204040:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0204044:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0204048:	02d67b63          	bleu	a3,a2,ffffffffc020407e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020404c:	00361693          	slli	a3,a2,0x3
ffffffffc0204050:	96b2                	add	a3,a3,a2
ffffffffc0204052:	068e                	slli	a3,a3,0x3
ffffffffc0204054:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0204056:	41c7073b          	subw	a4,a4,t3
ffffffffc020405a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020405c:	00868613          	addi	a2,a3,8
ffffffffc0204060:	4709                	li	a4,2
ffffffffc0204062:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204066:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020406a:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020406e:	0105a803          	lw	a6,16(a1)
ffffffffc0204072:	e310                	sd	a2,0(a4)
ffffffffc0204074:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0204078:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020407a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020407e:	41c8083b          	subw	a6,a6,t3
ffffffffc0204082:	00012717          	auipc	a4,0x12
ffffffffc0204086:	57072723          	sw	a6,1390(a4) # ffffffffc02165f0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020408a:	5775                	li	a4,-3
ffffffffc020408c:	17a1                	addi	a5,a5,-24
ffffffffc020408e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0204092:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0204094:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0204096:	00003697          	auipc	a3,0x3
ffffffffc020409a:	d1268693          	addi	a3,a3,-750 # ffffffffc0206da8 <commands+0x1b50>
ffffffffc020409e:	00002617          	auipc	a2,0x2
ffffffffc02040a2:	bca60613          	addi	a2,a2,-1078 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02040a6:	06200593          	li	a1,98
ffffffffc02040aa:	00003517          	auipc	a0,0x3
ffffffffc02040ae:	9c650513          	addi	a0,a0,-1594 # ffffffffc0206a70 <commands+0x1818>
default_alloc_pages(size_t n) {
ffffffffc02040b2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02040b4:	922fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02040b8 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02040b8:	1141                	addi	sp,sp,-16
ffffffffc02040ba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02040bc:	c1fd                	beqz	a1,ffffffffc02041a2 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02040be:	00359693          	slli	a3,a1,0x3
ffffffffc02040c2:	96ae                	add	a3,a3,a1
ffffffffc02040c4:	068e                	slli	a3,a3,0x3
ffffffffc02040c6:	96aa                	add	a3,a3,a0
ffffffffc02040c8:	02d50463          	beq	a0,a3,ffffffffc02040f0 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02040cc:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02040ce:	87aa                	mv	a5,a0
ffffffffc02040d0:	8b05                	andi	a4,a4,1
ffffffffc02040d2:	e709                	bnez	a4,ffffffffc02040dc <default_init_memmap+0x24>
ffffffffc02040d4:	a07d                	j	ffffffffc0204182 <default_init_memmap+0xca>
ffffffffc02040d6:	6798                	ld	a4,8(a5)
ffffffffc02040d8:	8b05                	andi	a4,a4,1
ffffffffc02040da:	c745                	beqz	a4,ffffffffc0204182 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02040dc:	0007ac23          	sw	zero,24(a5)
ffffffffc02040e0:	0007b423          	sd	zero,8(a5)
ffffffffc02040e4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02040e8:	04878793          	addi	a5,a5,72
ffffffffc02040ec:	fed795e3          	bne	a5,a3,ffffffffc02040d6 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02040f0:	2581                	sext.w	a1,a1
ffffffffc02040f2:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02040f4:	4789                	li	a5,2
ffffffffc02040f6:	00850713          	addi	a4,a0,8
ffffffffc02040fa:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02040fe:	00012697          	auipc	a3,0x12
ffffffffc0204102:	4e268693          	addi	a3,a3,1250 # ffffffffc02165e0 <free_area>
ffffffffc0204106:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204108:	669c                	ld	a5,8(a3)
ffffffffc020410a:	9db9                	addw	a1,a1,a4
ffffffffc020410c:	00012717          	auipc	a4,0x12
ffffffffc0204110:	4eb72223          	sw	a1,1252(a4) # ffffffffc02165f0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204114:	04d78a63          	beq	a5,a3,ffffffffc0204168 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0204118:	fe078713          	addi	a4,a5,-32
ffffffffc020411c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020411e:	4801                	li	a6,0
ffffffffc0204120:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0204124:	00e56a63          	bltu	a0,a4,ffffffffc0204138 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0204128:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020412a:	02d70563          	beq	a4,a3,ffffffffc0204154 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020412e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204130:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0204134:	fee57ae3          	bleu	a4,a0,ffffffffc0204128 <default_init_memmap+0x70>
ffffffffc0204138:	00080663          	beqz	a6,ffffffffc0204144 <default_init_memmap+0x8c>
ffffffffc020413c:	00012717          	auipc	a4,0x12
ffffffffc0204140:	4ab73223          	sd	a1,1188(a4) # ffffffffc02165e0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204144:	6398                	ld	a4,0(a5)
}
ffffffffc0204146:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204148:	e390                	sd	a2,0(a5)
ffffffffc020414a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020414c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020414e:	f118                	sd	a4,32(a0)
ffffffffc0204150:	0141                	addi	sp,sp,16
ffffffffc0204152:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204154:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204156:	f514                	sd	a3,40(a0)
ffffffffc0204158:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020415a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020415c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020415e:	00d70e63          	beq	a4,a3,ffffffffc020417a <default_init_memmap+0xc2>
ffffffffc0204162:	4805                	li	a6,1
ffffffffc0204164:	87ba                	mv	a5,a4
ffffffffc0204166:	b7e9                	j	ffffffffc0204130 <default_init_memmap+0x78>
}
ffffffffc0204168:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020416a:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020416e:	e398                	sd	a4,0(a5)
ffffffffc0204170:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204172:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0204174:	f11c                	sd	a5,32(a0)
}
ffffffffc0204176:	0141                	addi	sp,sp,16
ffffffffc0204178:	8082                	ret
ffffffffc020417a:	60a2                	ld	ra,8(sp)
ffffffffc020417c:	e290                	sd	a2,0(a3)
ffffffffc020417e:	0141                	addi	sp,sp,16
ffffffffc0204180:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204182:	00003697          	auipc	a3,0x3
ffffffffc0204186:	c2e68693          	addi	a3,a3,-978 # ffffffffc0206db0 <commands+0x1b58>
ffffffffc020418a:	00002617          	auipc	a2,0x2
ffffffffc020418e:	ade60613          	addi	a2,a2,-1314 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0204192:	04900593          	li	a1,73
ffffffffc0204196:	00003517          	auipc	a0,0x3
ffffffffc020419a:	8da50513          	addi	a0,a0,-1830 # ffffffffc0206a70 <commands+0x1818>
ffffffffc020419e:	838fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(n > 0);
ffffffffc02041a2:	00003697          	auipc	a3,0x3
ffffffffc02041a6:	c0668693          	addi	a3,a3,-1018 # ffffffffc0206da8 <commands+0x1b50>
ffffffffc02041aa:	00002617          	auipc	a2,0x2
ffffffffc02041ae:	abe60613          	addi	a2,a2,-1346 # ffffffffc0205c68 <commands+0xa10>
ffffffffc02041b2:	04600593          	li	a1,70
ffffffffc02041b6:	00003517          	auipc	a0,0x3
ffffffffc02041ba:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0206a70 <commands+0x1818>
ffffffffc02041be:	818fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02041c2 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc02041c2:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02041c4:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc02041c6:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02041c8:	aeafc0ef          	jal	ra,ffffffffc02004b2 <ide_device_valid>
ffffffffc02041cc:	cd01                	beqz	a0,ffffffffc02041e4 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02041ce:	4505                	li	a0,1
ffffffffc02041d0:	ae8fc0ef          	jal	ra,ffffffffc02004b8 <ide_device_size>
}
ffffffffc02041d4:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02041d6:	810d                	srli	a0,a0,0x3
ffffffffc02041d8:	00012797          	auipc	a5,0x12
ffffffffc02041dc:	3aa7bc23          	sd	a0,952(a5) # ffffffffc0216590 <max_swap_offset>
}
ffffffffc02041e0:	0141                	addi	sp,sp,16
ffffffffc02041e2:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc02041e4:	00003617          	auipc	a2,0x3
ffffffffc02041e8:	c2c60613          	addi	a2,a2,-980 # ffffffffc0206e10 <default_pmm_manager+0x50>
ffffffffc02041ec:	45b5                	li	a1,13
ffffffffc02041ee:	00003517          	auipc	a0,0x3
ffffffffc02041f2:	c4250513          	addi	a0,a0,-958 # ffffffffc0206e30 <default_pmm_manager+0x70>
ffffffffc02041f6:	fe1fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02041fa <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc02041fa:	1141                	addi	sp,sp,-16
ffffffffc02041fc:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041fe:	00855793          	srli	a5,a0,0x8
ffffffffc0204202:	c7b5                	beqz	a5,ffffffffc020426e <swapfs_read+0x74>
ffffffffc0204204:	00012717          	auipc	a4,0x12
ffffffffc0204208:	38c70713          	addi	a4,a4,908 # ffffffffc0216590 <max_swap_offset>
ffffffffc020420c:	6318                	ld	a4,0(a4)
ffffffffc020420e:	06e7f063          	bleu	a4,a5,ffffffffc020426e <swapfs_read+0x74>
    return page - pages + nbase;
ffffffffc0204212:	00012717          	auipc	a4,0x12
ffffffffc0204216:	2e670713          	addi	a4,a4,742 # ffffffffc02164f8 <pages>
ffffffffc020421a:	6310                	ld	a2,0(a4)
ffffffffc020421c:	00002717          	auipc	a4,0x2
ffffffffc0204220:	8ec70713          	addi	a4,a4,-1812 # ffffffffc0205b08 <commands+0x8b0>
ffffffffc0204224:	00003697          	auipc	a3,0x3
ffffffffc0204228:	03c68693          	addi	a3,a3,60 # ffffffffc0207260 <nbase>
ffffffffc020422c:	40c58633          	sub	a2,a1,a2
ffffffffc0204230:	630c                	ld	a1,0(a4)
ffffffffc0204232:	860d                	srai	a2,a2,0x3
    return KADDR(page2pa(page));
ffffffffc0204234:	00012717          	auipc	a4,0x12
ffffffffc0204238:	25c70713          	addi	a4,a4,604 # ffffffffc0216490 <npage>
    return page - pages + nbase;
ffffffffc020423c:	02b60633          	mul	a2,a2,a1
ffffffffc0204240:	0037959b          	slliw	a1,a5,0x3
ffffffffc0204244:	629c                	ld	a5,0(a3)
    return KADDR(page2pa(page));
ffffffffc0204246:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204248:	963e                	add	a2,a2,a5
    return KADDR(page2pa(page));
ffffffffc020424a:	57fd                	li	a5,-1
ffffffffc020424c:	83b1                	srli	a5,a5,0xc
ffffffffc020424e:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0204250:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204252:	02e7fa63          	bleu	a4,a5,ffffffffc0204286 <swapfs_read+0x8c>
ffffffffc0204256:	00012797          	auipc	a5,0x12
ffffffffc020425a:	29278793          	addi	a5,a5,658 # ffffffffc02164e8 <va_pa_offset>
ffffffffc020425e:	639c                	ld	a5,0(a5)
}
ffffffffc0204260:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204262:	46a1                	li	a3,8
ffffffffc0204264:	963e                	add	a2,a2,a5
ffffffffc0204266:	4505                	li	a0,1
}
ffffffffc0204268:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020426a:	a54fc06f          	j	ffffffffc02004be <ide_read_secs>
ffffffffc020426e:	86aa                	mv	a3,a0
ffffffffc0204270:	00003617          	auipc	a2,0x3
ffffffffc0204274:	bd860613          	addi	a2,a2,-1064 # ffffffffc0206e48 <default_pmm_manager+0x88>
ffffffffc0204278:	45d1                	li	a1,20
ffffffffc020427a:	00003517          	auipc	a0,0x3
ffffffffc020427e:	bb650513          	addi	a0,a0,-1098 # ffffffffc0206e30 <default_pmm_manager+0x70>
ffffffffc0204282:	f55fb0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0204286:	86b2                	mv	a3,a2
ffffffffc0204288:	06900593          	li	a1,105
ffffffffc020428c:	00002617          	auipc	a2,0x2
ffffffffc0204290:	88460613          	addi	a2,a2,-1916 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0204294:	00002517          	auipc	a0,0x2
ffffffffc0204298:	8d450513          	addi	a0,a0,-1836 # ffffffffc0205b68 <commands+0x910>
ffffffffc020429c:	f3bfb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02042a0 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc02042a0:	1141                	addi	sp,sp,-16
ffffffffc02042a2:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02042a4:	00855793          	srli	a5,a0,0x8
ffffffffc02042a8:	c7b5                	beqz	a5,ffffffffc0204314 <swapfs_write+0x74>
ffffffffc02042aa:	00012717          	auipc	a4,0x12
ffffffffc02042ae:	2e670713          	addi	a4,a4,742 # ffffffffc0216590 <max_swap_offset>
ffffffffc02042b2:	6318                	ld	a4,0(a4)
ffffffffc02042b4:	06e7f063          	bleu	a4,a5,ffffffffc0204314 <swapfs_write+0x74>
    return page - pages + nbase;
ffffffffc02042b8:	00012717          	auipc	a4,0x12
ffffffffc02042bc:	24070713          	addi	a4,a4,576 # ffffffffc02164f8 <pages>
ffffffffc02042c0:	6310                	ld	a2,0(a4)
ffffffffc02042c2:	00002717          	auipc	a4,0x2
ffffffffc02042c6:	84670713          	addi	a4,a4,-1978 # ffffffffc0205b08 <commands+0x8b0>
ffffffffc02042ca:	00003697          	auipc	a3,0x3
ffffffffc02042ce:	f9668693          	addi	a3,a3,-106 # ffffffffc0207260 <nbase>
ffffffffc02042d2:	40c58633          	sub	a2,a1,a2
ffffffffc02042d6:	630c                	ld	a1,0(a4)
ffffffffc02042d8:	860d                	srai	a2,a2,0x3
    return KADDR(page2pa(page));
ffffffffc02042da:	00012717          	auipc	a4,0x12
ffffffffc02042de:	1b670713          	addi	a4,a4,438 # ffffffffc0216490 <npage>
    return page - pages + nbase;
ffffffffc02042e2:	02b60633          	mul	a2,a2,a1
ffffffffc02042e6:	0037959b          	slliw	a1,a5,0x3
ffffffffc02042ea:	629c                	ld	a5,0(a3)
    return KADDR(page2pa(page));
ffffffffc02042ec:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02042ee:	963e                	add	a2,a2,a5
    return KADDR(page2pa(page));
ffffffffc02042f0:	57fd                	li	a5,-1
ffffffffc02042f2:	83b1                	srli	a5,a5,0xc
ffffffffc02042f4:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02042f6:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02042f8:	02e7fa63          	bleu	a4,a5,ffffffffc020432c <swapfs_write+0x8c>
ffffffffc02042fc:	00012797          	auipc	a5,0x12
ffffffffc0204300:	1ec78793          	addi	a5,a5,492 # ffffffffc02164e8 <va_pa_offset>
ffffffffc0204304:	639c                	ld	a5,0(a5)
}
ffffffffc0204306:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204308:	46a1                	li	a3,8
ffffffffc020430a:	963e                	add	a2,a2,a5
ffffffffc020430c:	4505                	li	a0,1
}
ffffffffc020430e:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204310:	9d2fc06f          	j	ffffffffc02004e2 <ide_write_secs>
ffffffffc0204314:	86aa                	mv	a3,a0
ffffffffc0204316:	00003617          	auipc	a2,0x3
ffffffffc020431a:	b3260613          	addi	a2,a2,-1230 # ffffffffc0206e48 <default_pmm_manager+0x88>
ffffffffc020431e:	45e5                	li	a1,25
ffffffffc0204320:	00003517          	auipc	a0,0x3
ffffffffc0204324:	b1050513          	addi	a0,a0,-1264 # ffffffffc0206e30 <default_pmm_manager+0x70>
ffffffffc0204328:	eaffb0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc020432c:	86b2                	mv	a3,a2
ffffffffc020432e:	06900593          	li	a1,105
ffffffffc0204332:	00001617          	auipc	a2,0x1
ffffffffc0204336:	7de60613          	addi	a2,a2,2014 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc020433a:	00002517          	auipc	a0,0x2
ffffffffc020433e:	82e50513          	addi	a0,a0,-2002 # ffffffffc0205b68 <commands+0x910>
ffffffffc0204342:	e95fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0204346 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204346:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204348:	9402                	jalr	s0

	jal do_exit
ffffffffc020434a:	5be000ef          	jal	ra,ffffffffc0204908 <do_exit>

ffffffffc020434e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020434e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204352:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204356:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204358:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020435a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020435e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204362:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204366:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020436a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020436e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204372:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204376:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020437a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020437e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204382:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204386:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020438a:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020438c:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020438e:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204392:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204396:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020439a:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020439e:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02043a2:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02043a6:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02043aa:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02043ae:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02043b2:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02043b6:	8082                	ret

ffffffffc02043b8 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc02043b8:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02043ba:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc02043be:	e022                	sd	s0,0(sp)
ffffffffc02043c0:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02043c2:	cbffe0ef          	jal	ra,ffffffffc0203080 <kmalloc>
ffffffffc02043c6:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02043c8:	c529                	beqz	a0,ffffffffc0204412 <alloc_proc+0x5a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state = PROC_UNINIT;
ffffffffc02043ca:	57fd                	li	a5,-1
ffffffffc02043cc:	1782                	slli	a5,a5,0x20
ffffffffc02043ce:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02043d0:	07000613          	li	a2,112
ffffffffc02043d4:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc02043d6:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc02043da:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc02043de:	00052c23          	sw	zero,24(a0)
    proc->parent = NULL;
ffffffffc02043e2:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc02043e6:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02043ea:	03050513          	addi	a0,a0,48
ffffffffc02043ee:	0b1000ef          	jal	ra,ffffffffc0204c9e <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc02043f2:	00012797          	auipc	a5,0x12
ffffffffc02043f6:	0fe78793          	addi	a5,a5,254 # ffffffffc02164f0 <boot_cr3>
ffffffffc02043fa:	639c                	ld	a5,0(a5)
    proc->tf = NULL;
ffffffffc02043fc:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;
ffffffffc0204400:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204404:	f45c                	sd	a5,168(s0)
    memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204406:	463d                	li	a2,15
ffffffffc0204408:	4581                	li	a1,0
ffffffffc020440a:	0b440513          	addi	a0,s0,180
ffffffffc020440e:	091000ef          	jal	ra,ffffffffc0204c9e <memset>

    }
    return proc;
}
ffffffffc0204412:	8522                	mv	a0,s0
ffffffffc0204414:	60a2                	ld	ra,8(sp)
ffffffffc0204416:	6402                	ld	s0,0(sp)
ffffffffc0204418:	0141                	addi	sp,sp,16
ffffffffc020441a:	8082                	ret

ffffffffc020441c <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc020441c:	00012797          	auipc	a5,0x12
ffffffffc0204420:	09c78793          	addi	a5,a5,156 # ffffffffc02164b8 <current>
ffffffffc0204424:	639c                	ld	a5,0(a5)
ffffffffc0204426:	73c8                	ld	a0,160(a5)
ffffffffc0204428:	fd0fc06f          	j	ffffffffc0200bf8 <forkrets>

ffffffffc020442c <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020442c:	1101                	addi	sp,sp,-32
ffffffffc020442e:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204430:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204434:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204436:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204438:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020443a:	8522                	mv	a0,s0
ffffffffc020443c:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020443e:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204440:	05f000ef          	jal	ra,ffffffffc0204c9e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204444:	8522                	mv	a0,s0
}
ffffffffc0204446:	6442                	ld	s0,16(sp)
ffffffffc0204448:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020444a:	85a6                	mv	a1,s1
}
ffffffffc020444c:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020444e:	463d                	li	a2,15
}
ffffffffc0204450:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204452:	05f0006f          	j	ffffffffc0204cb0 <memcpy>

ffffffffc0204456 <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc0204456:	1101                	addi	sp,sp,-32
ffffffffc0204458:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc020445a:	00012417          	auipc	s0,0x12
ffffffffc020445e:	00640413          	addi	s0,s0,6 # ffffffffc0216460 <name.1566>
get_proc_name(struct proc_struct *proc) {
ffffffffc0204462:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204464:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc0204466:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc0204468:	4581                	li	a1,0
ffffffffc020446a:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc020446c:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc020446e:	031000ef          	jal	ra,ffffffffc0204c9e <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204472:	8522                	mv	a0,s0
}
ffffffffc0204474:	6442                	ld	s0,16(sp)
ffffffffc0204476:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204478:	0b448593          	addi	a1,s1,180
}
ffffffffc020447c:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020447e:	463d                	li	a2,15
}
ffffffffc0204480:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204482:	02f0006f          	j	ffffffffc0204cb0 <memcpy>

ffffffffc0204486 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204486:	00012797          	auipc	a5,0x12
ffffffffc020448a:	03278793          	addi	a5,a5,50 # ffffffffc02164b8 <current>
ffffffffc020448e:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc0204490:	1101                	addi	sp,sp,-32
ffffffffc0204492:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204494:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc0204496:	e822                	sd	s0,16(sp)
ffffffffc0204498:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020449a:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc020449c:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020449e:	fb9ff0ef          	jal	ra,ffffffffc0204456 <get_proc_name>
ffffffffc02044a2:	862a                	mv	a2,a0
ffffffffc02044a4:	85a6                	mv	a1,s1
ffffffffc02044a6:	00003517          	auipc	a0,0x3
ffffffffc02044aa:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0206eb0 <default_pmm_manager+0xf0>
ffffffffc02044ae:	c23fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02044b2:	85a2                	mv	a1,s0
ffffffffc02044b4:	00003517          	auipc	a0,0x3
ffffffffc02044b8:	a2450513          	addi	a0,a0,-1500 # ffffffffc0206ed8 <default_pmm_manager+0x118>
ffffffffc02044bc:	c15fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02044c0:	00003517          	auipc	a0,0x3
ffffffffc02044c4:	a2850513          	addi	a0,a0,-1496 # ffffffffc0206ee8 <default_pmm_manager+0x128>
ffffffffc02044c8:	c09fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc02044cc:	60e2                	ld	ra,24(sp)
ffffffffc02044ce:	6442                	ld	s0,16(sp)
ffffffffc02044d0:	64a2                	ld	s1,8(sp)
ffffffffc02044d2:	4501                	li	a0,0
ffffffffc02044d4:	6105                	addi	sp,sp,32
ffffffffc02044d6:	8082                	ret

ffffffffc02044d8 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc02044d8:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc02044da:	00012797          	auipc	a5,0x12
ffffffffc02044de:	fde78793          	addi	a5,a5,-34 # ffffffffc02164b8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc02044e2:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc02044e4:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc02044e6:	ec06                	sd	ra,24(sp)
ffffffffc02044e8:	e822                	sd	s0,16(sp)
ffffffffc02044ea:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc02044ec:	02a48c63          	beq	s1,a0,ffffffffc0204524 <proc_run+0x4c>
ffffffffc02044f0:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02044f2:	100027f3          	csrr	a5,sstatus
ffffffffc02044f6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02044f8:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02044fa:	e3b1                	bnez	a5,ffffffffc020453e <proc_run+0x66>
            lcr3(next->cr3);
ffffffffc02044fc:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc02044fe:	00012717          	auipc	a4,0x12
ffffffffc0204502:	fa873d23          	sd	s0,-70(a4) # ffffffffc02164b8 <current>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204506:	80000737          	lui	a4,0x80000
ffffffffc020450a:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc020450e:	8fd9                	or	a5,a5,a4
ffffffffc0204510:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204514:	03040593          	addi	a1,s0,48
ffffffffc0204518:	03048513          	addi	a0,s1,48
ffffffffc020451c:	e33ff0ef          	jal	ra,ffffffffc020434e <switch_to>
    if (flag) {
ffffffffc0204520:	00091863          	bnez	s2,ffffffffc0204530 <proc_run+0x58>
}
ffffffffc0204524:	60e2                	ld	ra,24(sp)
ffffffffc0204526:	6442                	ld	s0,16(sp)
ffffffffc0204528:	64a2                	ld	s1,8(sp)
ffffffffc020452a:	6902                	ld	s2,0(sp)
ffffffffc020452c:	6105                	addi	sp,sp,32
ffffffffc020452e:	8082                	ret
ffffffffc0204530:	6442                	ld	s0,16(sp)
ffffffffc0204532:	60e2                	ld	ra,24(sp)
ffffffffc0204534:	64a2                	ld	s1,8(sp)
ffffffffc0204536:	6902                	ld	s2,0(sp)
ffffffffc0204538:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020453a:	89afc06f          	j	ffffffffc02005d4 <intr_enable>
        intr_disable();
ffffffffc020453e:	89cfc0ef          	jal	ra,ffffffffc02005da <intr_disable>
        return 1;
ffffffffc0204542:	4905                	li	s2,1
ffffffffc0204544:	bf65                	j	ffffffffc02044fc <proc_run+0x24>

ffffffffc0204546 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204546:	0005071b          	sext.w	a4,a0
ffffffffc020454a:	6789                	lui	a5,0x2
ffffffffc020454c:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204550:	17f9                	addi	a5,a5,-2
ffffffffc0204552:	04d7e063          	bltu	a5,a3,ffffffffc0204592 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204556:	1141                	addi	sp,sp,-16
ffffffffc0204558:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020455a:	45a9                	li	a1,10
ffffffffc020455c:	842a                	mv	s0,a0
ffffffffc020455e:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204560:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204562:	38f000ef          	jal	ra,ffffffffc02050f0 <hash32>
ffffffffc0204566:	02051693          	slli	a3,a0,0x20
ffffffffc020456a:	82f1                	srli	a3,a3,0x1c
ffffffffc020456c:	0000e517          	auipc	a0,0xe
ffffffffc0204570:	ef450513          	addi	a0,a0,-268 # ffffffffc0212460 <hash_list>
ffffffffc0204574:	96aa                	add	a3,a3,a0
ffffffffc0204576:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204578:	a029                	j	ffffffffc0204582 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc020457a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc020457e:	00870c63          	beq	a4,s0,ffffffffc0204596 <find_proc+0x50>
    return listelm->next;
ffffffffc0204582:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204584:	fef69be3          	bne	a3,a5,ffffffffc020457a <find_proc+0x34>
}
ffffffffc0204588:	60a2                	ld	ra,8(sp)
ffffffffc020458a:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020458c:	4501                	li	a0,0
}
ffffffffc020458e:	0141                	addi	sp,sp,16
ffffffffc0204590:	8082                	ret
    return NULL;
ffffffffc0204592:	4501                	li	a0,0
}
ffffffffc0204594:	8082                	ret
ffffffffc0204596:	60a2                	ld	ra,8(sp)
ffffffffc0204598:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020459a:	f2878513          	addi	a0,a5,-216
}
ffffffffc020459e:	0141                	addi	sp,sp,16
ffffffffc02045a0:	8082                	ret

ffffffffc02045a2 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02045a2:	7179                	addi	sp,sp,-48
ffffffffc02045a4:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02045a6:	00012917          	auipc	s2,0x12
ffffffffc02045aa:	f2a90913          	addi	s2,s2,-214 # ffffffffc02164d0 <nr_process>
ffffffffc02045ae:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02045b2:	f406                	sd	ra,40(sp)
ffffffffc02045b4:	f022                	sd	s0,32(sp)
ffffffffc02045b6:	ec26                	sd	s1,24(sp)
ffffffffc02045b8:	e44e                	sd	s3,8(sp)
ffffffffc02045ba:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02045bc:	6785                	lui	a5,0x1
ffffffffc02045be:	28f75563          	ble	a5,a4,ffffffffc0204848 <do_fork+0x2a6>
ffffffffc02045c2:	89ae                	mv	s3,a1
ffffffffc02045c4:	84b2                	mv	s1,a2
    proc = alloc_proc();
ffffffffc02045c6:	df3ff0ef          	jal	ra,ffffffffc02043b8 <alloc_proc>
ffffffffc02045ca:	842a                	mv	s0,a0
    if(proc==NULL){
ffffffffc02045cc:	28050063          	beqz	a0,ffffffffc020484c <do_fork+0x2aa>
    proc->parent = current;
ffffffffc02045d0:	00012a17          	auipc	s4,0x12
ffffffffc02045d4:	ee8a0a13          	addi	s4,s4,-280 # ffffffffc02164b8 <current>
ffffffffc02045d8:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02045dc:	4509                	li	a0,2
    proc->parent = current;
ffffffffc02045de:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02045e0:	e3afc0ef          	jal	ra,ffffffffc0200c1a <alloc_pages>
    if (page != NULL) {
ffffffffc02045e4:	20050663          	beqz	a0,ffffffffc02047f0 <do_fork+0x24e>
    return page - pages + nbase;
ffffffffc02045e8:	00012797          	auipc	a5,0x12
ffffffffc02045ec:	f1078793          	addi	a5,a5,-240 # ffffffffc02164f8 <pages>
ffffffffc02045f0:	6394                	ld	a3,0(a5)
ffffffffc02045f2:	00001797          	auipc	a5,0x1
ffffffffc02045f6:	51678793          	addi	a5,a5,1302 # ffffffffc0205b08 <commands+0x8b0>
    return KADDR(page2pa(page));
ffffffffc02045fa:	00012717          	auipc	a4,0x12
ffffffffc02045fe:	e9670713          	addi	a4,a4,-362 # ffffffffc0216490 <npage>
    return page - pages + nbase;
ffffffffc0204602:	40d506b3          	sub	a3,a0,a3
ffffffffc0204606:	6388                	ld	a0,0(a5)
ffffffffc0204608:	868d                	srai	a3,a3,0x3
ffffffffc020460a:	00003797          	auipc	a5,0x3
ffffffffc020460e:	c5678793          	addi	a5,a5,-938 # ffffffffc0207260 <nbase>
ffffffffc0204612:	02a686b3          	mul	a3,a3,a0
ffffffffc0204616:	6388                	ld	a0,0(a5)
    return KADDR(page2pa(page));
ffffffffc0204618:	6318                	ld	a4,0(a4)
ffffffffc020461a:	57fd                	li	a5,-1
ffffffffc020461c:	83b1                	srli	a5,a5,0xc
    return page - pages + nbase;
ffffffffc020461e:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204620:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204622:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204624:	24e7f663          	bleu	a4,a5,ffffffffc0204870 <do_fork+0x2ce>
    assert(current->mm == NULL);
ffffffffc0204628:	000a3783          	ld	a5,0(s4)
ffffffffc020462c:	00012717          	auipc	a4,0x12
ffffffffc0204630:	ebc70713          	addi	a4,a4,-324 # ffffffffc02164e8 <va_pa_offset>
ffffffffc0204634:	6318                	ld	a4,0(a4)
ffffffffc0204636:	779c                	ld	a5,40(a5)
ffffffffc0204638:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020463a:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc020463c:	20079a63          	bnez	a5,ffffffffc0204850 <do_fork+0x2ae>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204640:	6789                	lui	a5,0x2
ffffffffc0204642:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc0204646:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204648:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020464a:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc020464c:	87b6                	mv	a5,a3
ffffffffc020464e:	12048893          	addi	a7,s1,288
ffffffffc0204652:	00063803          	ld	a6,0(a2)
ffffffffc0204656:	6608                	ld	a0,8(a2)
ffffffffc0204658:	6a0c                	ld	a1,16(a2)
ffffffffc020465a:	6e18                	ld	a4,24(a2)
ffffffffc020465c:	0107b023          	sd	a6,0(a5)
ffffffffc0204660:	e788                	sd	a0,8(a5)
ffffffffc0204662:	eb8c                	sd	a1,16(a5)
ffffffffc0204664:	ef98                	sd	a4,24(a5)
ffffffffc0204666:	02060613          	addi	a2,a2,32
ffffffffc020466a:	02078793          	addi	a5,a5,32
ffffffffc020466e:	ff1612e3          	bne	a2,a7,ffffffffc0204652 <do_fork+0xb0>
    proc->tf->gpr.a0 = 0;
ffffffffc0204672:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204676:	10098e63          	beqz	s3,ffffffffc0204792 <do_fork+0x1f0>
ffffffffc020467a:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020467e:	00000797          	auipc	a5,0x0
ffffffffc0204682:	d9e78793          	addi	a5,a5,-610 # ffffffffc020441c <forkret>
ffffffffc0204686:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204688:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020468a:	100027f3          	csrr	a5,sstatus
ffffffffc020468e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204690:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204692:	10079f63          	bnez	a5,ffffffffc02047b0 <do_fork+0x20e>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204696:	00007797          	auipc	a5,0x7
ffffffffc020469a:	9c278793          	addi	a5,a5,-1598 # ffffffffc020b058 <last_pid.1576>
ffffffffc020469e:	439c                	lw	a5,0(a5)
ffffffffc02046a0:	6709                	lui	a4,0x2
ffffffffc02046a2:	0017851b          	addiw	a0,a5,1
ffffffffc02046a6:	00007697          	auipc	a3,0x7
ffffffffc02046aa:	9aa6a923          	sw	a0,-1614(a3) # ffffffffc020b058 <last_pid.1576>
ffffffffc02046ae:	12e55263          	ble	a4,a0,ffffffffc02047d2 <do_fork+0x230>
    if (last_pid >= next_safe) {
ffffffffc02046b2:	00007797          	auipc	a5,0x7
ffffffffc02046b6:	9aa78793          	addi	a5,a5,-1622 # ffffffffc020b05c <next_safe.1575>
ffffffffc02046ba:	439c                	lw	a5,0(a5)
ffffffffc02046bc:	00012497          	auipc	s1,0x12
ffffffffc02046c0:	f3c48493          	addi	s1,s1,-196 # ffffffffc02165f8 <proc_list>
ffffffffc02046c4:	06f54063          	blt	a0,a5,ffffffffc0204724 <do_fork+0x182>
        next_safe = MAX_PID;
ffffffffc02046c8:	6789                	lui	a5,0x2
ffffffffc02046ca:	00007717          	auipc	a4,0x7
ffffffffc02046ce:	98f72923          	sw	a5,-1646(a4) # ffffffffc020b05c <next_safe.1575>
ffffffffc02046d2:	4581                	li	a1,0
ffffffffc02046d4:	87aa                	mv	a5,a0
ffffffffc02046d6:	00012497          	auipc	s1,0x12
ffffffffc02046da:	f2248493          	addi	s1,s1,-222 # ffffffffc02165f8 <proc_list>
    repeat:
ffffffffc02046de:	6889                	lui	a7,0x2
ffffffffc02046e0:	882e                	mv	a6,a1
ffffffffc02046e2:	6609                	lui	a2,0x2
        le = list;
ffffffffc02046e4:	00012697          	auipc	a3,0x12
ffffffffc02046e8:	f1468693          	addi	a3,a3,-236 # ffffffffc02165f8 <proc_list>
ffffffffc02046ec:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc02046ee:	00968f63          	beq	a3,s1,ffffffffc020470c <do_fork+0x16a>
            if (proc->pid == last_pid) {
ffffffffc02046f2:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02046f6:	08e78963          	beq	a5,a4,ffffffffc0204788 <do_fork+0x1e6>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02046fa:	fee7d9e3          	ble	a4,a5,ffffffffc02046ec <do_fork+0x14a>
ffffffffc02046fe:	fec757e3          	ble	a2,a4,ffffffffc02046ec <do_fork+0x14a>
ffffffffc0204702:	6694                	ld	a3,8(a3)
ffffffffc0204704:	863a                	mv	a2,a4
ffffffffc0204706:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0204708:	fe9695e3          	bne	a3,s1,ffffffffc02046f2 <do_fork+0x150>
ffffffffc020470c:	c591                	beqz	a1,ffffffffc0204718 <do_fork+0x176>
ffffffffc020470e:	00007717          	auipc	a4,0x7
ffffffffc0204712:	94f72523          	sw	a5,-1718(a4) # ffffffffc020b058 <last_pid.1576>
ffffffffc0204716:	853e                	mv	a0,a5
ffffffffc0204718:	00080663          	beqz	a6,ffffffffc0204724 <do_fork+0x182>
ffffffffc020471c:	00007797          	auipc	a5,0x7
ffffffffc0204720:	94c7a023          	sw	a2,-1728(a5) # ffffffffc020b05c <next_safe.1575>
        proc->pid = get_pid();
ffffffffc0204724:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204726:	45a9                	li	a1,10
ffffffffc0204728:	2501                	sext.w	a0,a0
ffffffffc020472a:	1c7000ef          	jal	ra,ffffffffc02050f0 <hash32>
ffffffffc020472e:	1502                	slli	a0,a0,0x20
ffffffffc0204730:	0000e797          	auipc	a5,0xe
ffffffffc0204734:	d3078793          	addi	a5,a5,-720 # ffffffffc0212460 <hash_list>
ffffffffc0204738:	8171                	srli	a0,a0,0x1c
ffffffffc020473a:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020473c:	6510                	ld	a2,8(a0)
ffffffffc020473e:	0d840793          	addi	a5,s0,216
ffffffffc0204742:	6494                	ld	a3,8(s1)
        nr_process++;
ffffffffc0204744:	00092703          	lw	a4,0(s2)
    prev->next = next->prev = elm;
ffffffffc0204748:	e21c                	sd	a5,0(a2)
ffffffffc020474a:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc020474c:	f070                	sd	a2,224(s0)
        list_add(&proc_list, &(proc->list_link));
ffffffffc020474e:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc0204752:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204754:	e29c                	sd	a5,0(a3)
        nr_process++;
ffffffffc0204756:	2705                	addiw	a4,a4,1
ffffffffc0204758:	00012617          	auipc	a2,0x12
ffffffffc020475c:	eaf63423          	sd	a5,-344(a2) # ffffffffc0216600 <proc_list+0x8>
    elm->next = next;
ffffffffc0204760:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc0204762:	e464                	sd	s1,200(s0)
ffffffffc0204764:	00012797          	auipc	a5,0x12
ffffffffc0204768:	d6e7a623          	sw	a4,-660(a5) # ffffffffc02164d0 <nr_process>
    if (flag) {
ffffffffc020476c:	06099a63          	bnez	s3,ffffffffc02047e0 <do_fork+0x23e>
    wakeup_proc(proc);
ffffffffc0204770:	8522                	mv	a0,s0
ffffffffc0204772:	3c2000ef          	jal	ra,ffffffffc0204b34 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204776:	4048                	lw	a0,4(s0)
}
ffffffffc0204778:	70a2                	ld	ra,40(sp)
ffffffffc020477a:	7402                	ld	s0,32(sp)
ffffffffc020477c:	64e2                	ld	s1,24(sp)
ffffffffc020477e:	6942                	ld	s2,16(sp)
ffffffffc0204780:	69a2                	ld	s3,8(sp)
ffffffffc0204782:	6a02                	ld	s4,0(sp)
ffffffffc0204784:	6145                	addi	sp,sp,48
ffffffffc0204786:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0204788:	2785                	addiw	a5,a5,1
ffffffffc020478a:	04c7de63          	ble	a2,a5,ffffffffc02047e6 <do_fork+0x244>
ffffffffc020478e:	4585                	li	a1,1
ffffffffc0204790:	bfb1                	j	ffffffffc02046ec <do_fork+0x14a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204792:	89b6                	mv	s3,a3
ffffffffc0204794:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204798:	00000797          	auipc	a5,0x0
ffffffffc020479c:	c8478793          	addi	a5,a5,-892 # ffffffffc020441c <forkret>
ffffffffc02047a0:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02047a2:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02047a4:	100027f3          	csrr	a5,sstatus
ffffffffc02047a8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02047aa:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02047ac:	ee0785e3          	beqz	a5,ffffffffc0204696 <do_fork+0xf4>
        intr_disable();
ffffffffc02047b0:	e2bfb0ef          	jal	ra,ffffffffc02005da <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc02047b4:	00007797          	auipc	a5,0x7
ffffffffc02047b8:	8a478793          	addi	a5,a5,-1884 # ffffffffc020b058 <last_pid.1576>
ffffffffc02047bc:	439c                	lw	a5,0(a5)
ffffffffc02047be:	6709                	lui	a4,0x2
        return 1;
ffffffffc02047c0:	4985                	li	s3,1
ffffffffc02047c2:	0017851b          	addiw	a0,a5,1
ffffffffc02047c6:	00007697          	auipc	a3,0x7
ffffffffc02047ca:	88a6a923          	sw	a0,-1902(a3) # ffffffffc020b058 <last_pid.1576>
ffffffffc02047ce:	eee542e3          	blt	a0,a4,ffffffffc02046b2 <do_fork+0x110>
        last_pid = 1;
ffffffffc02047d2:	4785                	li	a5,1
ffffffffc02047d4:	00007717          	auipc	a4,0x7
ffffffffc02047d8:	88f72223          	sw	a5,-1916(a4) # ffffffffc020b058 <last_pid.1576>
ffffffffc02047dc:	4505                	li	a0,1
ffffffffc02047de:	b5ed                	j	ffffffffc02046c8 <do_fork+0x126>
        intr_enable();
ffffffffc02047e0:	df5fb0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
ffffffffc02047e4:	b771                	j	ffffffffc0204770 <do_fork+0x1ce>
                    if (last_pid >= MAX_PID) {
ffffffffc02047e6:	0117c363          	blt	a5,a7,ffffffffc02047ec <do_fork+0x24a>
                        last_pid = 1;
ffffffffc02047ea:	4785                	li	a5,1
                    goto repeat;
ffffffffc02047ec:	4585                	li	a1,1
ffffffffc02047ee:	bdcd                	j	ffffffffc02046e0 <do_fork+0x13e>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02047f0:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02047f2:	c02007b7          	lui	a5,0xc0200
ffffffffc02047f6:	0af6e563          	bltu	a3,a5,ffffffffc02048a0 <do_fork+0x2fe>
ffffffffc02047fa:	00012797          	auipc	a5,0x12
ffffffffc02047fe:	cee78793          	addi	a5,a5,-786 # ffffffffc02164e8 <va_pa_offset>
ffffffffc0204802:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204804:	00012717          	auipc	a4,0x12
ffffffffc0204808:	c8c70713          	addi	a4,a4,-884 # ffffffffc0216490 <npage>
ffffffffc020480c:	6318                	ld	a4,0(a4)
    return pa2page(PADDR(kva));
ffffffffc020480e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0204812:	83b1                	srli	a5,a5,0xc
ffffffffc0204814:	06e7fa63          	bleu	a4,a5,ffffffffc0204888 <do_fork+0x2e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0204818:	00003717          	auipc	a4,0x3
ffffffffc020481c:	a4870713          	addi	a4,a4,-1464 # ffffffffc0207260 <nbase>
ffffffffc0204820:	6318                	ld	a4,0(a4)
ffffffffc0204822:	00012697          	auipc	a3,0x12
ffffffffc0204826:	cd668693          	addi	a3,a3,-810 # ffffffffc02164f8 <pages>
ffffffffc020482a:	6288                	ld	a0,0(a3)
ffffffffc020482c:	8f99                	sub	a5,a5,a4
ffffffffc020482e:	00379713          	slli	a4,a5,0x3
ffffffffc0204832:	97ba                	add	a5,a5,a4
ffffffffc0204834:	078e                	slli	a5,a5,0x3
ffffffffc0204836:	953e                	add	a0,a0,a5
ffffffffc0204838:	4589                	li	a1,2
ffffffffc020483a:	c68fc0ef          	jal	ra,ffffffffc0200ca2 <free_pages>
    kfree(proc);
ffffffffc020483e:	8522                	mv	a0,s0
ffffffffc0204840:	8fdfe0ef          	jal	ra,ffffffffc020313c <kfree>
    ret = -E_NO_MEM;
ffffffffc0204844:	5571                	li	a0,-4
    goto fork_out;
ffffffffc0204846:	bf0d                	j	ffffffffc0204778 <do_fork+0x1d6>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204848:	556d                	li	a0,-5
ffffffffc020484a:	b73d                	j	ffffffffc0204778 <do_fork+0x1d6>
    ret = -E_NO_MEM;
ffffffffc020484c:	5571                	li	a0,-4
ffffffffc020484e:	b72d                	j	ffffffffc0204778 <do_fork+0x1d6>
    assert(current->mm == NULL);
ffffffffc0204850:	00002697          	auipc	a3,0x2
ffffffffc0204854:	63068693          	addi	a3,a3,1584 # ffffffffc0206e80 <default_pmm_manager+0xc0>
ffffffffc0204858:	00001617          	auipc	a2,0x1
ffffffffc020485c:	41060613          	addi	a2,a2,1040 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0204860:	10600593          	li	a1,262
ffffffffc0204864:	00002517          	auipc	a0,0x2
ffffffffc0204868:	63450513          	addi	a0,a0,1588 # ffffffffc0206e98 <default_pmm_manager+0xd8>
ffffffffc020486c:	96bfb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204870:	00001617          	auipc	a2,0x1
ffffffffc0204874:	2a060613          	addi	a2,a2,672 # ffffffffc0205b10 <commands+0x8b8>
ffffffffc0204878:	06900593          	li	a1,105
ffffffffc020487c:	00001517          	auipc	a0,0x1
ffffffffc0204880:	2ec50513          	addi	a0,a0,748 # ffffffffc0205b68 <commands+0x910>
ffffffffc0204884:	953fb0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204888:	00001617          	auipc	a2,0x1
ffffffffc020488c:	2c060613          	addi	a2,a2,704 # ffffffffc0205b48 <commands+0x8f0>
ffffffffc0204890:	06200593          	li	a1,98
ffffffffc0204894:	00001517          	auipc	a0,0x1
ffffffffc0204898:	2d450513          	addi	a0,a0,724 # ffffffffc0205b68 <commands+0x910>
ffffffffc020489c:	93bfb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02048a0:	00001617          	auipc	a2,0x1
ffffffffc02048a4:	34860613          	addi	a2,a2,840 # ffffffffc0205be8 <commands+0x990>
ffffffffc02048a8:	06e00593          	li	a1,110
ffffffffc02048ac:	00001517          	auipc	a0,0x1
ffffffffc02048b0:	2bc50513          	addi	a0,a0,700 # ffffffffc0205b68 <commands+0x910>
ffffffffc02048b4:	923fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02048b8 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02048b8:	7129                	addi	sp,sp,-320
ffffffffc02048ba:	fa22                	sd	s0,304(sp)
ffffffffc02048bc:	f626                	sd	s1,296(sp)
ffffffffc02048be:	f24a                	sd	s2,288(sp)
ffffffffc02048c0:	84ae                	mv	s1,a1
ffffffffc02048c2:	892a                	mv	s2,a0
ffffffffc02048c4:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02048c6:	4581                	li	a1,0
ffffffffc02048c8:	12000613          	li	a2,288
ffffffffc02048cc:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02048ce:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02048d0:	3ce000ef          	jal	ra,ffffffffc0204c9e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02048d4:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02048d6:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02048d8:	100027f3          	csrr	a5,sstatus
ffffffffc02048dc:	edd7f793          	andi	a5,a5,-291
ffffffffc02048e0:	1207e793          	ori	a5,a5,288
ffffffffc02048e4:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02048e6:	860a                	mv	a2,sp
ffffffffc02048e8:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02048ec:	00000797          	auipc	a5,0x0
ffffffffc02048f0:	a5a78793          	addi	a5,a5,-1446 # ffffffffc0204346 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02048f4:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02048f6:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02048f8:	cabff0ef          	jal	ra,ffffffffc02045a2 <do_fork>
}
ffffffffc02048fc:	70f2                	ld	ra,312(sp)
ffffffffc02048fe:	7452                	ld	s0,304(sp)
ffffffffc0204900:	74b2                	ld	s1,296(sp)
ffffffffc0204902:	7912                	ld	s2,288(sp)
ffffffffc0204904:	6131                	addi	sp,sp,320
ffffffffc0204906:	8082                	ret

ffffffffc0204908 <do_exit>:
do_exit(int error_code) {
ffffffffc0204908:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc020490a:	00002617          	auipc	a2,0x2
ffffffffc020490e:	55e60613          	addi	a2,a2,1374 # ffffffffc0206e68 <default_pmm_manager+0xa8>
ffffffffc0204912:	16900593          	li	a1,361
ffffffffc0204916:	00002517          	auipc	a0,0x2
ffffffffc020491a:	58250513          	addi	a0,a0,1410 # ffffffffc0206e98 <default_pmm_manager+0xd8>
do_exit(int error_code) {
ffffffffc020491e:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0204920:	8b7fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0204924 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0204924:	00012797          	auipc	a5,0x12
ffffffffc0204928:	cd478793          	addi	a5,a5,-812 # ffffffffc02165f8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc020492c:	1101                	addi	sp,sp,-32
ffffffffc020492e:	00012717          	auipc	a4,0x12
ffffffffc0204932:	ccf73923          	sd	a5,-814(a4) # ffffffffc0216600 <proc_list+0x8>
ffffffffc0204936:	00012717          	auipc	a4,0x12
ffffffffc020493a:	ccf73123          	sd	a5,-830(a4) # ffffffffc02165f8 <proc_list>
ffffffffc020493e:	ec06                	sd	ra,24(sp)
ffffffffc0204940:	e822                	sd	s0,16(sp)
ffffffffc0204942:	e426                	sd	s1,8(sp)
ffffffffc0204944:	e04a                	sd	s2,0(sp)
ffffffffc0204946:	0000e797          	auipc	a5,0xe
ffffffffc020494a:	b1a78793          	addi	a5,a5,-1254 # ffffffffc0212460 <hash_list>
ffffffffc020494e:	00012717          	auipc	a4,0x12
ffffffffc0204952:	b1270713          	addi	a4,a4,-1262 # ffffffffc0216460 <name.1566>
ffffffffc0204956:	e79c                	sd	a5,8(a5)
ffffffffc0204958:	e39c                	sd	a5,0(a5)
ffffffffc020495a:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc020495c:	fee79de3          	bne	a5,a4,ffffffffc0204956 <proc_init+0x32>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204960:	a59ff0ef          	jal	ra,ffffffffc02043b8 <alloc_proc>
ffffffffc0204964:	00012797          	auipc	a5,0x12
ffffffffc0204968:	b4a7be23          	sd	a0,-1188(a5) # ffffffffc02164c0 <idleproc>
ffffffffc020496c:	00012417          	auipc	s0,0x12
ffffffffc0204970:	b5440413          	addi	s0,s0,-1196 # ffffffffc02164c0 <idleproc>
ffffffffc0204974:	12050a63          	beqz	a0,ffffffffc0204aa8 <proc_init+0x184>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204978:	07000513          	li	a0,112
ffffffffc020497c:	f04fe0ef          	jal	ra,ffffffffc0203080 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204980:	07000613          	li	a2,112
ffffffffc0204984:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204986:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204988:	316000ef          	jal	ra,ffffffffc0204c9e <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020498c:	6008                	ld	a0,0(s0)
ffffffffc020498e:	85a6                	mv	a1,s1
ffffffffc0204990:	07000613          	li	a2,112
ffffffffc0204994:	03050513          	addi	a0,a0,48
ffffffffc0204998:	330000ef          	jal	ra,ffffffffc0204cc8 <memcmp>
ffffffffc020499c:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020499e:	453d                	li	a0,15
ffffffffc02049a0:	ee0fe0ef          	jal	ra,ffffffffc0203080 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02049a4:	463d                	li	a2,15
ffffffffc02049a6:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02049a8:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02049aa:	2f4000ef          	jal	ra,ffffffffc0204c9e <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02049ae:	6008                	ld	a0,0(s0)
ffffffffc02049b0:	463d                	li	a2,15
ffffffffc02049b2:	85a6                	mv	a1,s1
ffffffffc02049b4:	0b450513          	addi	a0,a0,180
ffffffffc02049b8:	310000ef          	jal	ra,ffffffffc0204cc8 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02049bc:	601c                	ld	a5,0(s0)
ffffffffc02049be:	00012717          	auipc	a4,0x12
ffffffffc02049c2:	b3270713          	addi	a4,a4,-1230 # ffffffffc02164f0 <boot_cr3>
ffffffffc02049c6:	6318                	ld	a4,0(a4)
ffffffffc02049c8:	77d4                	ld	a3,168(a5)
ffffffffc02049ca:	08e68e63          	beq	a3,a4,ffffffffc0204a66 <proc_init+0x142>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02049ce:	4709                	li	a4,2
ffffffffc02049d0:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02049d2:	00003717          	auipc	a4,0x3
ffffffffc02049d6:	62e70713          	addi	a4,a4,1582 # ffffffffc0208000 <bootstack>
ffffffffc02049da:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc02049dc:	4705                	li	a4,1
ffffffffc02049de:	cf98                	sw	a4,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc02049e0:	00002597          	auipc	a1,0x2
ffffffffc02049e4:	55858593          	addi	a1,a1,1368 # ffffffffc0206f38 <default_pmm_manager+0x178>
ffffffffc02049e8:	853e                	mv	a0,a5
ffffffffc02049ea:	a43ff0ef          	jal	ra,ffffffffc020442c <set_proc_name>
    nr_process ++;
ffffffffc02049ee:	00012797          	auipc	a5,0x12
ffffffffc02049f2:	ae278793          	addi	a5,a5,-1310 # ffffffffc02164d0 <nr_process>
ffffffffc02049f6:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc02049f8:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02049fa:	4601                	li	a2,0
    nr_process ++;
ffffffffc02049fc:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02049fe:	00002597          	auipc	a1,0x2
ffffffffc0204a02:	54258593          	addi	a1,a1,1346 # ffffffffc0206f40 <default_pmm_manager+0x180>
ffffffffc0204a06:	00000517          	auipc	a0,0x0
ffffffffc0204a0a:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204486 <init_main>
    nr_process ++;
ffffffffc0204a0e:	00012697          	auipc	a3,0x12
ffffffffc0204a12:	acf6a123          	sw	a5,-1342(a3) # ffffffffc02164d0 <nr_process>
    current = idleproc;
ffffffffc0204a16:	00012797          	auipc	a5,0x12
ffffffffc0204a1a:	aae7b123          	sd	a4,-1374(a5) # ffffffffc02164b8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204a1e:	e9bff0ef          	jal	ra,ffffffffc02048b8 <kernel_thread>
    if (pid <= 0) {
ffffffffc0204a22:	0ca05f63          	blez	a0,ffffffffc0204b00 <proc_init+0x1dc>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204a26:	b21ff0ef          	jal	ra,ffffffffc0204546 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0204a2a:	00002597          	auipc	a1,0x2
ffffffffc0204a2e:	54658593          	addi	a1,a1,1350 # ffffffffc0206f70 <default_pmm_manager+0x1b0>
    initproc = find_proc(pid);
ffffffffc0204a32:	00012797          	auipc	a5,0x12
ffffffffc0204a36:	a8a7bb23          	sd	a0,-1386(a5) # ffffffffc02164c8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0204a3a:	9f3ff0ef          	jal	ra,ffffffffc020442c <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204a3e:	601c                	ld	a5,0(s0)
ffffffffc0204a40:	c3c5                	beqz	a5,ffffffffc0204ae0 <proc_init+0x1bc>
ffffffffc0204a42:	43dc                	lw	a5,4(a5)
ffffffffc0204a44:	efd1                	bnez	a5,ffffffffc0204ae0 <proc_init+0x1bc>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204a46:	00012797          	auipc	a5,0x12
ffffffffc0204a4a:	a8278793          	addi	a5,a5,-1406 # ffffffffc02164c8 <initproc>
ffffffffc0204a4e:	639c                	ld	a5,0(a5)
ffffffffc0204a50:	cba5                	beqz	a5,ffffffffc0204ac0 <proc_init+0x19c>
ffffffffc0204a52:	43d8                	lw	a4,4(a5)
ffffffffc0204a54:	4785                	li	a5,1
ffffffffc0204a56:	06f71563          	bne	a4,a5,ffffffffc0204ac0 <proc_init+0x19c>
}
ffffffffc0204a5a:	60e2                	ld	ra,24(sp)
ffffffffc0204a5c:	6442                	ld	s0,16(sp)
ffffffffc0204a5e:	64a2                	ld	s1,8(sp)
ffffffffc0204a60:	6902                	ld	s2,0(sp)
ffffffffc0204a62:	6105                	addi	sp,sp,32
ffffffffc0204a64:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204a66:	73d8                	ld	a4,160(a5)
ffffffffc0204a68:	f33d                	bnez	a4,ffffffffc02049ce <proc_init+0xaa>
ffffffffc0204a6a:	f60912e3          	bnez	s2,ffffffffc02049ce <proc_init+0xaa>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204a6e:	6394                	ld	a3,0(a5)
ffffffffc0204a70:	577d                	li	a4,-1
ffffffffc0204a72:	1702                	slli	a4,a4,0x20
ffffffffc0204a74:	f4e69de3          	bne	a3,a4,ffffffffc02049ce <proc_init+0xaa>
ffffffffc0204a78:	4798                	lw	a4,8(a5)
ffffffffc0204a7a:	fb31                	bnez	a4,ffffffffc02049ce <proc_init+0xaa>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204a7c:	6b98                	ld	a4,16(a5)
ffffffffc0204a7e:	fb21                	bnez	a4,ffffffffc02049ce <proc_init+0xaa>
ffffffffc0204a80:	4f98                	lw	a4,24(a5)
ffffffffc0204a82:	2701                	sext.w	a4,a4
ffffffffc0204a84:	f729                	bnez	a4,ffffffffc02049ce <proc_init+0xaa>
ffffffffc0204a86:	7398                	ld	a4,32(a5)
ffffffffc0204a88:	f339                	bnez	a4,ffffffffc02049ce <proc_init+0xaa>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204a8a:	7798                	ld	a4,40(a5)
ffffffffc0204a8c:	f329                	bnez	a4,ffffffffc02049ce <proc_init+0xaa>
ffffffffc0204a8e:	0b07a703          	lw	a4,176(a5)
ffffffffc0204a92:	8f49                	or	a4,a4,a0
ffffffffc0204a94:	2701                	sext.w	a4,a4
ffffffffc0204a96:	ff05                	bnez	a4,ffffffffc02049ce <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204a98:	00002517          	auipc	a0,0x2
ffffffffc0204a9c:	48850513          	addi	a0,a0,1160 # ffffffffc0206f20 <default_pmm_manager+0x160>
ffffffffc0204aa0:	e30fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204aa4:	601c                	ld	a5,0(s0)
ffffffffc0204aa6:	b725                	j	ffffffffc02049ce <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc0204aa8:	00002617          	auipc	a2,0x2
ffffffffc0204aac:	46060613          	addi	a2,a2,1120 # ffffffffc0206f08 <default_pmm_manager+0x148>
ffffffffc0204ab0:	18100593          	li	a1,385
ffffffffc0204ab4:	00002517          	auipc	a0,0x2
ffffffffc0204ab8:	3e450513          	addi	a0,a0,996 # ffffffffc0206e98 <default_pmm_manager+0xd8>
ffffffffc0204abc:	f1afb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204ac0:	00002697          	auipc	a3,0x2
ffffffffc0204ac4:	4e068693          	addi	a3,a3,1248 # ffffffffc0206fa0 <default_pmm_manager+0x1e0>
ffffffffc0204ac8:	00001617          	auipc	a2,0x1
ffffffffc0204acc:	1a060613          	addi	a2,a2,416 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0204ad0:	1a800593          	li	a1,424
ffffffffc0204ad4:	00002517          	auipc	a0,0x2
ffffffffc0204ad8:	3c450513          	addi	a0,a0,964 # ffffffffc0206e98 <default_pmm_manager+0xd8>
ffffffffc0204adc:	efafb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204ae0:	00002697          	auipc	a3,0x2
ffffffffc0204ae4:	49868693          	addi	a3,a3,1176 # ffffffffc0206f78 <default_pmm_manager+0x1b8>
ffffffffc0204ae8:	00001617          	auipc	a2,0x1
ffffffffc0204aec:	18060613          	addi	a2,a2,384 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0204af0:	1a700593          	li	a1,423
ffffffffc0204af4:	00002517          	auipc	a0,0x2
ffffffffc0204af8:	3a450513          	addi	a0,a0,932 # ffffffffc0206e98 <default_pmm_manager+0xd8>
ffffffffc0204afc:	edafb0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("create init_main failed.\n");
ffffffffc0204b00:	00002617          	auipc	a2,0x2
ffffffffc0204b04:	45060613          	addi	a2,a2,1104 # ffffffffc0206f50 <default_pmm_manager+0x190>
ffffffffc0204b08:	1a100593          	li	a1,417
ffffffffc0204b0c:	00002517          	auipc	a0,0x2
ffffffffc0204b10:	38c50513          	addi	a0,a0,908 # ffffffffc0206e98 <default_pmm_manager+0xd8>
ffffffffc0204b14:	ec2fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0204b18 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204b18:	1141                	addi	sp,sp,-16
ffffffffc0204b1a:	e022                	sd	s0,0(sp)
ffffffffc0204b1c:	e406                	sd	ra,8(sp)
ffffffffc0204b1e:	00012417          	auipc	s0,0x12
ffffffffc0204b22:	99a40413          	addi	s0,s0,-1638 # ffffffffc02164b8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204b26:	6018                	ld	a4,0(s0)
ffffffffc0204b28:	4f1c                	lw	a5,24(a4)
ffffffffc0204b2a:	2781                	sext.w	a5,a5
ffffffffc0204b2c:	dff5                	beqz	a5,ffffffffc0204b28 <cpu_idle+0x10>
            schedule();
ffffffffc0204b2e:	038000ef          	jal	ra,ffffffffc0204b66 <schedule>
ffffffffc0204b32:	bfd5                	j	ffffffffc0204b26 <cpu_idle+0xe>

ffffffffc0204b34 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204b34:	411c                	lw	a5,0(a0)
ffffffffc0204b36:	4705                	li	a4,1
ffffffffc0204b38:	37f9                	addiw	a5,a5,-2
ffffffffc0204b3a:	00f77563          	bleu	a5,a4,ffffffffc0204b44 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204b3e:	4789                	li	a5,2
ffffffffc0204b40:	c11c                	sw	a5,0(a0)
ffffffffc0204b42:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204b44:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204b46:	00002697          	auipc	a3,0x2
ffffffffc0204b4a:	48268693          	addi	a3,a3,1154 # ffffffffc0206fc8 <default_pmm_manager+0x208>
ffffffffc0204b4e:	00001617          	auipc	a2,0x1
ffffffffc0204b52:	11a60613          	addi	a2,a2,282 # ffffffffc0205c68 <commands+0xa10>
ffffffffc0204b56:	45a5                	li	a1,9
ffffffffc0204b58:	00002517          	auipc	a0,0x2
ffffffffc0204b5c:	4b050513          	addi	a0,a0,1200 # ffffffffc0207008 <default_pmm_manager+0x248>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204b60:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204b62:	e74fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0204b66 <schedule>:
}

void
schedule(void) {
ffffffffc0204b66:	1141                	addi	sp,sp,-16
ffffffffc0204b68:	e406                	sd	ra,8(sp)
ffffffffc0204b6a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204b6c:	100027f3          	csrr	a5,sstatus
ffffffffc0204b70:	8b89                	andi	a5,a5,2
ffffffffc0204b72:	4401                	li	s0,0
ffffffffc0204b74:	e3d1                	bnez	a5,ffffffffc0204bf8 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204b76:	00012797          	auipc	a5,0x12
ffffffffc0204b7a:	94278793          	addi	a5,a5,-1726 # ffffffffc02164b8 <current>
ffffffffc0204b7e:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204b82:	00012797          	auipc	a5,0x12
ffffffffc0204b86:	93e78793          	addi	a5,a5,-1730 # ffffffffc02164c0 <idleproc>
ffffffffc0204b8a:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0204b8c:	0008ac23          	sw	zero,24(a7) # 2018 <BASE_ADDRESS-0xffffffffc01fdfe8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204b90:	04a88e63          	beq	a7,a0,ffffffffc0204bec <schedule+0x86>
ffffffffc0204b94:	0c888693          	addi	a3,a7,200
ffffffffc0204b98:	00012617          	auipc	a2,0x12
ffffffffc0204b9c:	a6060613          	addi	a2,a2,-1440 # ffffffffc02165f8 <proc_list>
        le = last;
ffffffffc0204ba0:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204ba2:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204ba4:	4809                	li	a6,2
    return listelm->next;
ffffffffc0204ba6:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204ba8:	00c78863          	beq	a5,a2,ffffffffc0204bb8 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204bac:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204bb0:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204bb4:	01070463          	beq	a4,a6,ffffffffc0204bbc <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204bb8:	fef697e3          	bne	a3,a5,ffffffffc0204ba6 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204bbc:	c589                	beqz	a1,ffffffffc0204bc6 <schedule+0x60>
ffffffffc0204bbe:	4198                	lw	a4,0(a1)
ffffffffc0204bc0:	4789                	li	a5,2
ffffffffc0204bc2:	00f70e63          	beq	a4,a5,ffffffffc0204bde <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204bc6:	451c                	lw	a5,8(a0)
ffffffffc0204bc8:	2785                	addiw	a5,a5,1
ffffffffc0204bca:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0204bcc:	00a88463          	beq	a7,a0,ffffffffc0204bd4 <schedule+0x6e>
            proc_run(next);
ffffffffc0204bd0:	909ff0ef          	jal	ra,ffffffffc02044d8 <proc_run>
    if (flag) {
ffffffffc0204bd4:	e419                	bnez	s0,ffffffffc0204be2 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204bd6:	60a2                	ld	ra,8(sp)
ffffffffc0204bd8:	6402                	ld	s0,0(sp)
ffffffffc0204bda:	0141                	addi	sp,sp,16
ffffffffc0204bdc:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204bde:	852e                	mv	a0,a1
ffffffffc0204be0:	b7dd                	j	ffffffffc0204bc6 <schedule+0x60>
}
ffffffffc0204be2:	6402                	ld	s0,0(sp)
ffffffffc0204be4:	60a2                	ld	ra,8(sp)
ffffffffc0204be6:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204be8:	9edfb06f          	j	ffffffffc02005d4 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204bec:	00012617          	auipc	a2,0x12
ffffffffc0204bf0:	a0c60613          	addi	a2,a2,-1524 # ffffffffc02165f8 <proc_list>
ffffffffc0204bf4:	86b2                	mv	a3,a2
ffffffffc0204bf6:	b76d                	j	ffffffffc0204ba0 <schedule+0x3a>
        intr_disable();
ffffffffc0204bf8:	9e3fb0ef          	jal	ra,ffffffffc02005da <intr_disable>
        return 1;
ffffffffc0204bfc:	4405                	li	s0,1
ffffffffc0204bfe:	bfa5                	j	ffffffffc0204b76 <schedule+0x10>

ffffffffc0204c00 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204c00:	00054783          	lbu	a5,0(a0)
ffffffffc0204c04:	cb91                	beqz	a5,ffffffffc0204c18 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204c06:	4781                	li	a5,0
        cnt ++;
ffffffffc0204c08:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204c0a:	00f50733          	add	a4,a0,a5
ffffffffc0204c0e:	00074703          	lbu	a4,0(a4)
ffffffffc0204c12:	fb7d                	bnez	a4,ffffffffc0204c08 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204c14:	853e                	mv	a0,a5
ffffffffc0204c16:	8082                	ret
    size_t cnt = 0;
ffffffffc0204c18:	4781                	li	a5,0
}
ffffffffc0204c1a:	853e                	mv	a0,a5
ffffffffc0204c1c:	8082                	ret

ffffffffc0204c1e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204c1e:	c185                	beqz	a1,ffffffffc0204c3e <strnlen+0x20>
ffffffffc0204c20:	00054783          	lbu	a5,0(a0)
ffffffffc0204c24:	cf89                	beqz	a5,ffffffffc0204c3e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204c26:	4781                	li	a5,0
ffffffffc0204c28:	a021                	j	ffffffffc0204c30 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204c2a:	00074703          	lbu	a4,0(a4)
ffffffffc0204c2e:	c711                	beqz	a4,ffffffffc0204c3a <strnlen+0x1c>
        cnt ++;
ffffffffc0204c30:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204c32:	00f50733          	add	a4,a0,a5
ffffffffc0204c36:	fef59ae3          	bne	a1,a5,ffffffffc0204c2a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204c3a:	853e                	mv	a0,a5
ffffffffc0204c3c:	8082                	ret
    size_t cnt = 0;
ffffffffc0204c3e:	4781                	li	a5,0
}
ffffffffc0204c40:	853e                	mv	a0,a5
ffffffffc0204c42:	8082                	ret

ffffffffc0204c44 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204c44:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204c46:	0585                	addi	a1,a1,1
ffffffffc0204c48:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204c4c:	0785                	addi	a5,a5,1
ffffffffc0204c4e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204c52:	fb75                	bnez	a4,ffffffffc0204c46 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204c54:	8082                	ret

ffffffffc0204c56 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204c56:	00054783          	lbu	a5,0(a0)
ffffffffc0204c5a:	0005c703          	lbu	a4,0(a1)
ffffffffc0204c5e:	cb91                	beqz	a5,ffffffffc0204c72 <strcmp+0x1c>
ffffffffc0204c60:	00e79c63          	bne	a5,a4,ffffffffc0204c78 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204c64:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204c66:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204c6a:	0585                	addi	a1,a1,1
ffffffffc0204c6c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204c70:	fbe5                	bnez	a5,ffffffffc0204c60 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204c72:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204c74:	9d19                	subw	a0,a0,a4
ffffffffc0204c76:	8082                	ret
ffffffffc0204c78:	0007851b          	sext.w	a0,a5
ffffffffc0204c7c:	9d19                	subw	a0,a0,a4
ffffffffc0204c7e:	8082                	ret

ffffffffc0204c80 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204c80:	00054783          	lbu	a5,0(a0)
ffffffffc0204c84:	cb91                	beqz	a5,ffffffffc0204c98 <strchr+0x18>
        if (*s == c) {
ffffffffc0204c86:	00b79563          	bne	a5,a1,ffffffffc0204c90 <strchr+0x10>
ffffffffc0204c8a:	a809                	j	ffffffffc0204c9c <strchr+0x1c>
ffffffffc0204c8c:	00b78763          	beq	a5,a1,ffffffffc0204c9a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204c90:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204c92:	00054783          	lbu	a5,0(a0)
ffffffffc0204c96:	fbfd                	bnez	a5,ffffffffc0204c8c <strchr+0xc>
    }
    return NULL;
ffffffffc0204c98:	4501                	li	a0,0
}
ffffffffc0204c9a:	8082                	ret
ffffffffc0204c9c:	8082                	ret

ffffffffc0204c9e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204c9e:	ca01                	beqz	a2,ffffffffc0204cae <memset+0x10>
ffffffffc0204ca0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204ca2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204ca4:	0785                	addi	a5,a5,1
ffffffffc0204ca6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204caa:	fec79de3          	bne	a5,a2,ffffffffc0204ca4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204cae:	8082                	ret

ffffffffc0204cb0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204cb0:	ca19                	beqz	a2,ffffffffc0204cc6 <memcpy+0x16>
ffffffffc0204cb2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204cb4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204cb6:	0585                	addi	a1,a1,1
ffffffffc0204cb8:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204cbc:	0785                	addi	a5,a5,1
ffffffffc0204cbe:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204cc2:	fec59ae3          	bne	a1,a2,ffffffffc0204cb6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204cc6:	8082                	ret

ffffffffc0204cc8 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204cc8:	c21d                	beqz	a2,ffffffffc0204cee <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204cca:	00054783          	lbu	a5,0(a0)
ffffffffc0204cce:	0005c703          	lbu	a4,0(a1)
ffffffffc0204cd2:	962a                	add	a2,a2,a0
ffffffffc0204cd4:	00f70963          	beq	a4,a5,ffffffffc0204ce6 <memcmp+0x1e>
ffffffffc0204cd8:	a829                	j	ffffffffc0204cf2 <memcmp+0x2a>
ffffffffc0204cda:	00054783          	lbu	a5,0(a0)
ffffffffc0204cde:	0005c703          	lbu	a4,0(a1)
ffffffffc0204ce2:	00e79863          	bne	a5,a4,ffffffffc0204cf2 <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204ce6:	0505                	addi	a0,a0,1
ffffffffc0204ce8:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204cea:	fea618e3          	bne	a2,a0,ffffffffc0204cda <memcmp+0x12>
    }
    return 0;
ffffffffc0204cee:	4501                	li	a0,0
}
ffffffffc0204cf0:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204cf2:	40e7853b          	subw	a0,a5,a4
ffffffffc0204cf6:	8082                	ret

ffffffffc0204cf8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204cf8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204cfc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204cfe:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204d02:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204d04:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204d08:	f022                	sd	s0,32(sp)
ffffffffc0204d0a:	ec26                	sd	s1,24(sp)
ffffffffc0204d0c:	e84a                	sd	s2,16(sp)
ffffffffc0204d0e:	f406                	sd	ra,40(sp)
ffffffffc0204d10:	e44e                	sd	s3,8(sp)
ffffffffc0204d12:	84aa                	mv	s1,a0
ffffffffc0204d14:	892e                	mv	s2,a1
ffffffffc0204d16:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204d1a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204d1c:	03067e63          	bleu	a6,a2,ffffffffc0204d58 <printnum+0x60>
ffffffffc0204d20:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204d22:	00805763          	blez	s0,ffffffffc0204d30 <printnum+0x38>
ffffffffc0204d26:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204d28:	85ca                	mv	a1,s2
ffffffffc0204d2a:	854e                	mv	a0,s3
ffffffffc0204d2c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204d2e:	fc65                	bnez	s0,ffffffffc0204d26 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204d30:	1a02                	slli	s4,s4,0x20
ffffffffc0204d32:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204d36:	00002797          	auipc	a5,0x2
ffffffffc0204d3a:	47a78793          	addi	a5,a5,1146 # ffffffffc02071b0 <error_string+0x38>
ffffffffc0204d3e:	9a3e                	add	s4,s4,a5
}
ffffffffc0204d40:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204d42:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204d46:	70a2                	ld	ra,40(sp)
ffffffffc0204d48:	69a2                	ld	s3,8(sp)
ffffffffc0204d4a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204d4c:	85ca                	mv	a1,s2
ffffffffc0204d4e:	8326                	mv	t1,s1
}
ffffffffc0204d50:	6942                	ld	s2,16(sp)
ffffffffc0204d52:	64e2                	ld	s1,24(sp)
ffffffffc0204d54:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204d56:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204d58:	03065633          	divu	a2,a2,a6
ffffffffc0204d5c:	8722                	mv	a4,s0
ffffffffc0204d5e:	f9bff0ef          	jal	ra,ffffffffc0204cf8 <printnum>
ffffffffc0204d62:	b7f9                	j	ffffffffc0204d30 <printnum+0x38>

ffffffffc0204d64 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204d64:	7119                	addi	sp,sp,-128
ffffffffc0204d66:	f4a6                	sd	s1,104(sp)
ffffffffc0204d68:	f0ca                	sd	s2,96(sp)
ffffffffc0204d6a:	e8d2                	sd	s4,80(sp)
ffffffffc0204d6c:	e4d6                	sd	s5,72(sp)
ffffffffc0204d6e:	e0da                	sd	s6,64(sp)
ffffffffc0204d70:	fc5e                	sd	s7,56(sp)
ffffffffc0204d72:	f862                	sd	s8,48(sp)
ffffffffc0204d74:	f06a                	sd	s10,32(sp)
ffffffffc0204d76:	fc86                	sd	ra,120(sp)
ffffffffc0204d78:	f8a2                	sd	s0,112(sp)
ffffffffc0204d7a:	ecce                	sd	s3,88(sp)
ffffffffc0204d7c:	f466                	sd	s9,40(sp)
ffffffffc0204d7e:	ec6e                	sd	s11,24(sp)
ffffffffc0204d80:	892a                	mv	s2,a0
ffffffffc0204d82:	84ae                	mv	s1,a1
ffffffffc0204d84:	8d32                	mv	s10,a2
ffffffffc0204d86:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204d88:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d8a:	00002a17          	auipc	s4,0x2
ffffffffc0204d8e:	296a0a13          	addi	s4,s4,662 # ffffffffc0207020 <default_pmm_manager+0x260>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204d92:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204d96:	00002c17          	auipc	s8,0x2
ffffffffc0204d9a:	3e2c0c13          	addi	s8,s8,994 # ffffffffc0207178 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204d9e:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204da2:	02500793          	li	a5,37
ffffffffc0204da6:	001d0413          	addi	s0,s10,1
ffffffffc0204daa:	00f50e63          	beq	a0,a5,ffffffffc0204dc6 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204dae:	c521                	beqz	a0,ffffffffc0204df6 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204db0:	02500993          	li	s3,37
ffffffffc0204db4:	a011                	j	ffffffffc0204db8 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204db6:	c121                	beqz	a0,ffffffffc0204df6 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204db8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204dba:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204dbc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204dbe:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204dc2:	ff351ae3          	bne	a0,s3,ffffffffc0204db6 <vprintfmt+0x52>
ffffffffc0204dc6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204dca:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204dce:	4981                	li	s3,0
ffffffffc0204dd0:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204dd2:	5cfd                	li	s9,-1
ffffffffc0204dd4:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204dd6:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204dda:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ddc:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204de0:	0ff6f693          	andi	a3,a3,255
ffffffffc0204de4:	00140d13          	addi	s10,s0,1
ffffffffc0204de8:	20d5e563          	bltu	a1,a3,ffffffffc0204ff2 <vprintfmt+0x28e>
ffffffffc0204dec:	068a                	slli	a3,a3,0x2
ffffffffc0204dee:	96d2                	add	a3,a3,s4
ffffffffc0204df0:	4294                	lw	a3,0(a3)
ffffffffc0204df2:	96d2                	add	a3,a3,s4
ffffffffc0204df4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204df6:	70e6                	ld	ra,120(sp)
ffffffffc0204df8:	7446                	ld	s0,112(sp)
ffffffffc0204dfa:	74a6                	ld	s1,104(sp)
ffffffffc0204dfc:	7906                	ld	s2,96(sp)
ffffffffc0204dfe:	69e6                	ld	s3,88(sp)
ffffffffc0204e00:	6a46                	ld	s4,80(sp)
ffffffffc0204e02:	6aa6                	ld	s5,72(sp)
ffffffffc0204e04:	6b06                	ld	s6,64(sp)
ffffffffc0204e06:	7be2                	ld	s7,56(sp)
ffffffffc0204e08:	7c42                	ld	s8,48(sp)
ffffffffc0204e0a:	7ca2                	ld	s9,40(sp)
ffffffffc0204e0c:	7d02                	ld	s10,32(sp)
ffffffffc0204e0e:	6de2                	ld	s11,24(sp)
ffffffffc0204e10:	6109                	addi	sp,sp,128
ffffffffc0204e12:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204e14:	4705                	li	a4,1
ffffffffc0204e16:	008a8593          	addi	a1,s5,8
ffffffffc0204e1a:	01074463          	blt	a4,a6,ffffffffc0204e22 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0204e1e:	26080363          	beqz	a6,ffffffffc0205084 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0204e22:	000ab603          	ld	a2,0(s5)
ffffffffc0204e26:	46c1                	li	a3,16
ffffffffc0204e28:	8aae                	mv	s5,a1
ffffffffc0204e2a:	a06d                	j	ffffffffc0204ed4 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0204e2c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204e30:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204e32:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204e34:	b765                	j	ffffffffc0204ddc <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0204e36:	000aa503          	lw	a0,0(s5)
ffffffffc0204e3a:	85a6                	mv	a1,s1
ffffffffc0204e3c:	0aa1                	addi	s5,s5,8
ffffffffc0204e3e:	9902                	jalr	s2
            break;
ffffffffc0204e40:	bfb9                	j	ffffffffc0204d9e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204e42:	4705                	li	a4,1
ffffffffc0204e44:	008a8993          	addi	s3,s5,8
ffffffffc0204e48:	01074463          	blt	a4,a6,ffffffffc0204e50 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0204e4c:	22080463          	beqz	a6,ffffffffc0205074 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0204e50:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204e54:	24044463          	bltz	s0,ffffffffc020509c <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0204e58:	8622                	mv	a2,s0
ffffffffc0204e5a:	8ace                	mv	s5,s3
ffffffffc0204e5c:	46a9                	li	a3,10
ffffffffc0204e5e:	a89d                	j	ffffffffc0204ed4 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0204e60:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204e64:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204e66:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204e68:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204e6c:	8fb5                	xor	a5,a5,a3
ffffffffc0204e6e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204e72:	1ad74363          	blt	a4,a3,ffffffffc0205018 <vprintfmt+0x2b4>
ffffffffc0204e76:	00369793          	slli	a5,a3,0x3
ffffffffc0204e7a:	97e2                	add	a5,a5,s8
ffffffffc0204e7c:	639c                	ld	a5,0(a5)
ffffffffc0204e7e:	18078d63          	beqz	a5,ffffffffc0205018 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204e82:	86be                	mv	a3,a5
ffffffffc0204e84:	00000617          	auipc	a2,0x0
ffffffffc0204e88:	2ac60613          	addi	a2,a2,684 # ffffffffc0205130 <etext+0x28>
ffffffffc0204e8c:	85a6                	mv	a1,s1
ffffffffc0204e8e:	854a                	mv	a0,s2
ffffffffc0204e90:	240000ef          	jal	ra,ffffffffc02050d0 <printfmt>
ffffffffc0204e94:	b729                	j	ffffffffc0204d9e <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204e96:	00144603          	lbu	a2,1(s0)
ffffffffc0204e9a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204e9c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204e9e:	bf3d                	j	ffffffffc0204ddc <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204ea0:	4705                	li	a4,1
ffffffffc0204ea2:	008a8593          	addi	a1,s5,8
ffffffffc0204ea6:	01074463          	blt	a4,a6,ffffffffc0204eae <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204eaa:	1e080263          	beqz	a6,ffffffffc020508e <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204eae:	000ab603          	ld	a2,0(s5)
ffffffffc0204eb2:	46a1                	li	a3,8
ffffffffc0204eb4:	8aae                	mv	s5,a1
ffffffffc0204eb6:	a839                	j	ffffffffc0204ed4 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204eb8:	03000513          	li	a0,48
ffffffffc0204ebc:	85a6                	mv	a1,s1
ffffffffc0204ebe:	e03e                	sd	a5,0(sp)
ffffffffc0204ec0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204ec2:	85a6                	mv	a1,s1
ffffffffc0204ec4:	07800513          	li	a0,120
ffffffffc0204ec8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204eca:	0aa1                	addi	s5,s5,8
ffffffffc0204ecc:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204ed0:	6782                	ld	a5,0(sp)
ffffffffc0204ed2:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204ed4:	876e                	mv	a4,s11
ffffffffc0204ed6:	85a6                	mv	a1,s1
ffffffffc0204ed8:	854a                	mv	a0,s2
ffffffffc0204eda:	e1fff0ef          	jal	ra,ffffffffc0204cf8 <printnum>
            break;
ffffffffc0204ede:	b5c1                	j	ffffffffc0204d9e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204ee0:	000ab603          	ld	a2,0(s5)
ffffffffc0204ee4:	0aa1                	addi	s5,s5,8
ffffffffc0204ee6:	1c060663          	beqz	a2,ffffffffc02050b2 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204eea:	00160413          	addi	s0,a2,1
ffffffffc0204eee:	17b05c63          	blez	s11,ffffffffc0205066 <vprintfmt+0x302>
ffffffffc0204ef2:	02d00593          	li	a1,45
ffffffffc0204ef6:	14b79263          	bne	a5,a1,ffffffffc020503a <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204efa:	00064783          	lbu	a5,0(a2)
ffffffffc0204efe:	0007851b          	sext.w	a0,a5
ffffffffc0204f02:	c905                	beqz	a0,ffffffffc0204f32 <vprintfmt+0x1ce>
ffffffffc0204f04:	000cc563          	bltz	s9,ffffffffc0204f0e <vprintfmt+0x1aa>
ffffffffc0204f08:	3cfd                	addiw	s9,s9,-1
ffffffffc0204f0a:	036c8263          	beq	s9,s6,ffffffffc0204f2e <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204f0e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204f10:	18098463          	beqz	s3,ffffffffc0205098 <vprintfmt+0x334>
ffffffffc0204f14:	3781                	addiw	a5,a5,-32
ffffffffc0204f16:	18fbf163          	bleu	a5,s7,ffffffffc0205098 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204f1a:	03f00513          	li	a0,63
ffffffffc0204f1e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204f20:	0405                	addi	s0,s0,1
ffffffffc0204f22:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204f26:	3dfd                	addiw	s11,s11,-1
ffffffffc0204f28:	0007851b          	sext.w	a0,a5
ffffffffc0204f2c:	fd61                	bnez	a0,ffffffffc0204f04 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204f2e:	e7b058e3          	blez	s11,ffffffffc0204d9e <vprintfmt+0x3a>
ffffffffc0204f32:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204f34:	85a6                	mv	a1,s1
ffffffffc0204f36:	02000513          	li	a0,32
ffffffffc0204f3a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204f3c:	e60d81e3          	beqz	s11,ffffffffc0204d9e <vprintfmt+0x3a>
ffffffffc0204f40:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204f42:	85a6                	mv	a1,s1
ffffffffc0204f44:	02000513          	li	a0,32
ffffffffc0204f48:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204f4a:	fe0d94e3          	bnez	s11,ffffffffc0204f32 <vprintfmt+0x1ce>
ffffffffc0204f4e:	bd81                	j	ffffffffc0204d9e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204f50:	4705                	li	a4,1
ffffffffc0204f52:	008a8593          	addi	a1,s5,8
ffffffffc0204f56:	01074463          	blt	a4,a6,ffffffffc0204f5e <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204f5a:	12080063          	beqz	a6,ffffffffc020507a <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204f5e:	000ab603          	ld	a2,0(s5)
ffffffffc0204f62:	46a9                	li	a3,10
ffffffffc0204f64:	8aae                	mv	s5,a1
ffffffffc0204f66:	b7bd                	j	ffffffffc0204ed4 <vprintfmt+0x170>
ffffffffc0204f68:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204f6c:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204f70:	846a                	mv	s0,s10
ffffffffc0204f72:	b5ad                	j	ffffffffc0204ddc <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204f74:	85a6                	mv	a1,s1
ffffffffc0204f76:	02500513          	li	a0,37
ffffffffc0204f7a:	9902                	jalr	s2
            break;
ffffffffc0204f7c:	b50d                	j	ffffffffc0204d9e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204f7e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204f82:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204f86:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204f88:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204f8a:	e40dd9e3          	bgez	s11,ffffffffc0204ddc <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204f8e:	8de6                	mv	s11,s9
ffffffffc0204f90:	5cfd                	li	s9,-1
ffffffffc0204f92:	b5a9                	j	ffffffffc0204ddc <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204f94:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204f98:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204f9c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204f9e:	bd3d                	j	ffffffffc0204ddc <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204fa0:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204fa4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204fa8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204faa:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204fae:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204fb2:	fcd56ce3          	bltu	a0,a3,ffffffffc0204f8a <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204fb6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204fb8:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204fbc:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204fc0:	0196873b          	addw	a4,a3,s9
ffffffffc0204fc4:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204fc8:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204fcc:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204fd0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204fd4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204fd8:	fcd57fe3          	bleu	a3,a0,ffffffffc0204fb6 <vprintfmt+0x252>
ffffffffc0204fdc:	b77d                	j	ffffffffc0204f8a <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204fde:	fffdc693          	not	a3,s11
ffffffffc0204fe2:	96fd                	srai	a3,a3,0x3f
ffffffffc0204fe4:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204fe8:	00144603          	lbu	a2,1(s0)
ffffffffc0204fec:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204fee:	846a                	mv	s0,s10
ffffffffc0204ff0:	b3f5                	j	ffffffffc0204ddc <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204ff2:	85a6                	mv	a1,s1
ffffffffc0204ff4:	02500513          	li	a0,37
ffffffffc0204ff8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204ffa:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204ffe:	02500793          	li	a5,37
ffffffffc0205002:	8d22                	mv	s10,s0
ffffffffc0205004:	d8f70de3          	beq	a4,a5,ffffffffc0204d9e <vprintfmt+0x3a>
ffffffffc0205008:	02500713          	li	a4,37
ffffffffc020500c:	1d7d                	addi	s10,s10,-1
ffffffffc020500e:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0205012:	fee79de3          	bne	a5,a4,ffffffffc020500c <vprintfmt+0x2a8>
ffffffffc0205016:	b361                	j	ffffffffc0204d9e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205018:	00002617          	auipc	a2,0x2
ffffffffc020501c:	23860613          	addi	a2,a2,568 # ffffffffc0207250 <error_string+0xd8>
ffffffffc0205020:	85a6                	mv	a1,s1
ffffffffc0205022:	854a                	mv	a0,s2
ffffffffc0205024:	0ac000ef          	jal	ra,ffffffffc02050d0 <printfmt>
ffffffffc0205028:	bb9d                	j	ffffffffc0204d9e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020502a:	00002617          	auipc	a2,0x2
ffffffffc020502e:	21e60613          	addi	a2,a2,542 # ffffffffc0207248 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0205032:	00002417          	auipc	s0,0x2
ffffffffc0205036:	21740413          	addi	s0,s0,535 # ffffffffc0207249 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020503a:	8532                	mv	a0,a2
ffffffffc020503c:	85e6                	mv	a1,s9
ffffffffc020503e:	e032                	sd	a2,0(sp)
ffffffffc0205040:	e43e                	sd	a5,8(sp)
ffffffffc0205042:	bddff0ef          	jal	ra,ffffffffc0204c1e <strnlen>
ffffffffc0205046:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020504a:	6602                	ld	a2,0(sp)
ffffffffc020504c:	01b05d63          	blez	s11,ffffffffc0205066 <vprintfmt+0x302>
ffffffffc0205050:	67a2                	ld	a5,8(sp)
ffffffffc0205052:	2781                	sext.w	a5,a5
ffffffffc0205054:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0205056:	6522                	ld	a0,8(sp)
ffffffffc0205058:	85a6                	mv	a1,s1
ffffffffc020505a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020505c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020505e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205060:	6602                	ld	a2,0(sp)
ffffffffc0205062:	fe0d9ae3          	bnez	s11,ffffffffc0205056 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205066:	00064783          	lbu	a5,0(a2)
ffffffffc020506a:	0007851b          	sext.w	a0,a5
ffffffffc020506e:	e8051be3          	bnez	a0,ffffffffc0204f04 <vprintfmt+0x1a0>
ffffffffc0205072:	b335                	j	ffffffffc0204d9e <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0205074:	000aa403          	lw	s0,0(s5)
ffffffffc0205078:	bbf1                	j	ffffffffc0204e54 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020507a:	000ae603          	lwu	a2,0(s5)
ffffffffc020507e:	46a9                	li	a3,10
ffffffffc0205080:	8aae                	mv	s5,a1
ffffffffc0205082:	bd89                	j	ffffffffc0204ed4 <vprintfmt+0x170>
ffffffffc0205084:	000ae603          	lwu	a2,0(s5)
ffffffffc0205088:	46c1                	li	a3,16
ffffffffc020508a:	8aae                	mv	s5,a1
ffffffffc020508c:	b5a1                	j	ffffffffc0204ed4 <vprintfmt+0x170>
ffffffffc020508e:	000ae603          	lwu	a2,0(s5)
ffffffffc0205092:	46a1                	li	a3,8
ffffffffc0205094:	8aae                	mv	s5,a1
ffffffffc0205096:	bd3d                	j	ffffffffc0204ed4 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0205098:	9902                	jalr	s2
ffffffffc020509a:	b559                	j	ffffffffc0204f20 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020509c:	85a6                	mv	a1,s1
ffffffffc020509e:	02d00513          	li	a0,45
ffffffffc02050a2:	e03e                	sd	a5,0(sp)
ffffffffc02050a4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02050a6:	8ace                	mv	s5,s3
ffffffffc02050a8:	40800633          	neg	a2,s0
ffffffffc02050ac:	46a9                	li	a3,10
ffffffffc02050ae:	6782                	ld	a5,0(sp)
ffffffffc02050b0:	b515                	j	ffffffffc0204ed4 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02050b2:	01b05663          	blez	s11,ffffffffc02050be <vprintfmt+0x35a>
ffffffffc02050b6:	02d00693          	li	a3,45
ffffffffc02050ba:	f6d798e3          	bne	a5,a3,ffffffffc020502a <vprintfmt+0x2c6>
ffffffffc02050be:	00002417          	auipc	s0,0x2
ffffffffc02050c2:	18b40413          	addi	s0,s0,395 # ffffffffc0207249 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02050c6:	02800513          	li	a0,40
ffffffffc02050ca:	02800793          	li	a5,40
ffffffffc02050ce:	bd1d                	j	ffffffffc0204f04 <vprintfmt+0x1a0>

ffffffffc02050d0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02050d0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02050d2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02050d6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02050d8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02050da:	ec06                	sd	ra,24(sp)
ffffffffc02050dc:	f83a                	sd	a4,48(sp)
ffffffffc02050de:	fc3e                	sd	a5,56(sp)
ffffffffc02050e0:	e0c2                	sd	a6,64(sp)
ffffffffc02050e2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02050e4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02050e6:	c7fff0ef          	jal	ra,ffffffffc0204d64 <vprintfmt>
}
ffffffffc02050ea:	60e2                	ld	ra,24(sp)
ffffffffc02050ec:	6161                	addi	sp,sp,80
ffffffffc02050ee:	8082                	ret

ffffffffc02050f0 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02050f0:	9e3707b7          	lui	a5,0x9e370
ffffffffc02050f4:	2785                	addiw	a5,a5,1
ffffffffc02050f6:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02050fa:	02000793          	li	a5,32
ffffffffc02050fe:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0205102:	00b5553b          	srlw	a0,a0,a1
ffffffffc0205106:	8082                	ret
