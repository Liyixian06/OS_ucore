
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	fb250513          	addi	a0,a0,-78 # ffffffffc02a0fe8 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	53a60613          	addi	a2,a2,1338 # ffffffffc02ac578 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	1d0060ef          	jal	ra,ffffffffc020621e <memset>
    cons_init();                // init the console
ffffffffc0200052:	58e000ef          	jal	ra,ffffffffc02005e0 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	60258593          	addi	a1,a1,1538 # ffffffffc0206658 <etext>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	61a50513          	addi	a0,a0,1562 # ffffffffc0206678 <etext+0x20>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	25a000ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	61e010ef          	jal	ra,ffffffffc020168c <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e2000ef          	jal	ra,ffffffffc0200654 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	72a020ef          	jal	ra,ffffffffc02027a4 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	5ab050ef          	jal	ra,ffffffffc0205e28 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4b0000ef          	jal	ra,ffffffffc0200532 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	5df020ef          	jal	ra,ffffffffc0202e64 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	500000ef          	jal	ra,ffffffffc020058a <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c8000ef          	jal	ra,ffffffffc0200656 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	6e3050ef          	jal	ra,ffffffffc0205f74 <cpu_idle>

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
ffffffffc020009e:	544000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
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
ffffffffc02000c4:	1f0060ef          	jal	ra,ffffffffc02062b4 <vprintfmt>
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
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02000f8:	1bc060ef          	jal	ra,ffffffffc02062b4 <vprintfmt>
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
ffffffffc0200104:	4de0006f          	j	ffffffffc02005e2 <cons_putc>

ffffffffc0200108 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200108:	1101                	addi	sp,sp,-32
ffffffffc020010a:	e822                	sd	s0,16(sp)
ffffffffc020010c:	ec06                	sd	ra,24(sp)
ffffffffc020010e:	e426                	sd	s1,8(sp)
ffffffffc0200110:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200112:	00054503          	lbu	a0,0(a0)
ffffffffc0200116:	c51d                	beqz	a0,ffffffffc0200144 <cputs+0x3c>
ffffffffc0200118:	0405                	addi	s0,s0,1
ffffffffc020011a:	4485                	li	s1,1
ffffffffc020011c:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011e:	4c4000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012c:	f96d                	bnez	a0,ffffffffc020011e <cputs+0x16>
ffffffffc020012e:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200132:	4529                	li	a0,10
ffffffffc0200134:	4ae000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200138:	8522                	mv	a0,s0
ffffffffc020013a:	60e2                	ld	ra,24(sp)
ffffffffc020013c:	6442                	ld	s0,16(sp)
ffffffffc020013e:	64a2                	ld	s1,8(sp)
ffffffffc0200140:	6105                	addi	sp,sp,32
ffffffffc0200142:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200144:	4405                	li	s0,1
ffffffffc0200146:	b7f5                	j	ffffffffc0200132 <cputs+0x2a>

ffffffffc0200148 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200148:	1141                	addi	sp,sp,-16
ffffffffc020014a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020014c:	4cc000ef          	jal	ra,ffffffffc0200618 <cons_getc>
ffffffffc0200150:	dd75                	beqz	a0,ffffffffc020014c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200152:	60a2                	ld	ra,8(sp)
ffffffffc0200154:	0141                	addi	sp,sp,16
ffffffffc0200156:	8082                	ret

ffffffffc0200158 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200158:	715d                	addi	sp,sp,-80
ffffffffc020015a:	e486                	sd	ra,72(sp)
ffffffffc020015c:	e0a2                	sd	s0,64(sp)
ffffffffc020015e:	fc26                	sd	s1,56(sp)
ffffffffc0200160:	f84a                	sd	s2,48(sp)
ffffffffc0200162:	f44e                	sd	s3,40(sp)
ffffffffc0200164:	f052                	sd	s4,32(sp)
ffffffffc0200166:	ec56                	sd	s5,24(sp)
ffffffffc0200168:	e85a                	sd	s6,16(sp)
ffffffffc020016a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020016c:	c901                	beqz	a0,ffffffffc020017c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00006517          	auipc	a0,0x6
ffffffffc0200174:	51050513          	addi	a0,a0,1296 # ffffffffc0206680 <etext+0x28>
ffffffffc0200178:	f59ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020017c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020017e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200180:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200182:	4aa9                	li	s5,10
ffffffffc0200184:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200186:	000a1b97          	auipc	s7,0xa1
ffffffffc020018a:	e62b8b93          	addi	s7,s7,-414 # ffffffffc02a0fe8 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200192:	fb7ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc0200196:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200198:	00054b63          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019c:	00a95b63          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001a0:	029a5463          	ble	s1,s4,ffffffffc02001c8 <readline+0x70>
        c = getchar();
ffffffffc02001a4:	fa5ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001a8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001aa:	fe0559e3          	bgez	a0,ffffffffc020019c <readline+0x44>
            return NULL;
ffffffffc02001ae:	4501                	li	a0,0
ffffffffc02001b0:	a099                	j	ffffffffc02001f6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02001b2:	03341463          	bne	s0,s3,ffffffffc02001da <readline+0x82>
ffffffffc02001b6:	e8b9                	bnez	s1,ffffffffc020020c <readline+0xb4>
        c = getchar();
ffffffffc02001b8:	f91ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001bc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001be:	fe0548e3          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001c2:	fea958e3          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001c6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001c8:	8522                	mv	a0,s0
ffffffffc02001ca:	f3bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc02001ce:	009b87b3          	add	a5,s7,s1
ffffffffc02001d2:	00878023          	sb	s0,0(a5)
ffffffffc02001d6:	2485                	addiw	s1,s1,1
ffffffffc02001d8:	bf6d                	j	ffffffffc0200192 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02001da:	01540463          	beq	s0,s5,ffffffffc02001e2 <readline+0x8a>
ffffffffc02001de:	fb641ae3          	bne	s0,s6,ffffffffc0200192 <readline+0x3a>
            cputchar(c);
ffffffffc02001e2:	8522                	mv	a0,s0
ffffffffc02001e4:	f21ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001e8:	000a1517          	auipc	a0,0xa1
ffffffffc02001ec:	e0050513          	addi	a0,a0,-512 # ffffffffc02a0fe8 <edata>
ffffffffc02001f0:	94aa                	add	s1,s1,a0
ffffffffc02001f2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001f6:	60a6                	ld	ra,72(sp)
ffffffffc02001f8:	6406                	ld	s0,64(sp)
ffffffffc02001fa:	74e2                	ld	s1,56(sp)
ffffffffc02001fc:	7942                	ld	s2,48(sp)
ffffffffc02001fe:	79a2                	ld	s3,40(sp)
ffffffffc0200200:	7a02                	ld	s4,32(sp)
ffffffffc0200202:	6ae2                	ld	s5,24(sp)
ffffffffc0200204:	6b42                	ld	s6,16(sp)
ffffffffc0200206:	6ba2                	ld	s7,8(sp)
ffffffffc0200208:	6161                	addi	sp,sp,80
ffffffffc020020a:	8082                	ret
            cputchar(c);
ffffffffc020020c:	4521                	li	a0,8
ffffffffc020020e:	ef7ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc0200212:	34fd                	addiw	s1,s1,-1
ffffffffc0200214:	bfbd                	j	ffffffffc0200192 <readline+0x3a>

ffffffffc0200216 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200216:	000ac317          	auipc	t1,0xac
ffffffffc020021a:	1d230313          	addi	t1,t1,466 # ffffffffc02ac3e8 <is_panic>
ffffffffc020021e:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200222:	715d                	addi	sp,sp,-80
ffffffffc0200224:	ec06                	sd	ra,24(sp)
ffffffffc0200226:	e822                	sd	s0,16(sp)
ffffffffc0200228:	f436                	sd	a3,40(sp)
ffffffffc020022a:	f83a                	sd	a4,48(sp)
ffffffffc020022c:	fc3e                	sd	a5,56(sp)
ffffffffc020022e:	e0c2                	sd	a6,64(sp)
ffffffffc0200230:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200232:	02031c63          	bnez	t1,ffffffffc020026a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200236:	4785                	li	a5,1
ffffffffc0200238:	8432                	mv	s0,a2
ffffffffc020023a:	000ac717          	auipc	a4,0xac
ffffffffc020023e:	1af73723          	sd	a5,430(a4) # ffffffffc02ac3e8 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200242:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200244:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200246:	85aa                	mv	a1,a0
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	44050513          	addi	a0,a0,1088 # ffffffffc0206688 <etext+0x30>
    va_start(ap, fmt);
ffffffffc0200250:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200252:	e7fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200256:	65a2                	ld	a1,8(sp)
ffffffffc0200258:	8522                	mv	a0,s0
ffffffffc020025a:	e57ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025e:	00007517          	auipc	a0,0x7
ffffffffc0200262:	27250513          	addi	a0,a0,626 # ffffffffc02074d0 <commands+0xd08>
ffffffffc0200266:	e6bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020026a:	4501                	li	a0,0
ffffffffc020026c:	4581                	li	a1,0
ffffffffc020026e:	4601                	li	a2,0
ffffffffc0200270:	48a1                	li	a7,8
ffffffffc0200272:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200276:	3e6000ef          	jal	ra,ffffffffc020065c <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020027a:	4501                	li	a0,0
ffffffffc020027c:	174000ef          	jal	ra,ffffffffc02003f0 <kmonitor>
ffffffffc0200280:	bfed                	j	ffffffffc020027a <__panic+0x64>

ffffffffc0200282 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200282:	715d                	addi	sp,sp,-80
ffffffffc0200284:	e822                	sd	s0,16(sp)
ffffffffc0200286:	fc3e                	sd	a5,56(sp)
ffffffffc0200288:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc020028a:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028c:	862e                	mv	a2,a1
ffffffffc020028e:	85aa                	mv	a1,a0
ffffffffc0200290:	00006517          	auipc	a0,0x6
ffffffffc0200294:	41850513          	addi	a0,a0,1048 # ffffffffc02066a8 <etext+0x50>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200298:	ec06                	sd	ra,24(sp)
ffffffffc020029a:	f436                	sd	a3,40(sp)
ffffffffc020029c:	f83a                	sd	a4,48(sp)
ffffffffc020029e:	e0c2                	sd	a6,64(sp)
ffffffffc02002a0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a2:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a4:	e2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002a8:	65a2                	ld	a1,8(sp)
ffffffffc02002aa:	8522                	mv	a0,s0
ffffffffc02002ac:	e05ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc02002b0:	00007517          	auipc	a0,0x7
ffffffffc02002b4:	22050513          	addi	a0,a0,544 # ffffffffc02074d0 <commands+0xd08>
ffffffffc02002b8:	e19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);
}
ffffffffc02002bc:	60e2                	ld	ra,24(sp)
ffffffffc02002be:	6442                	ld	s0,16(sp)
ffffffffc02002c0:	6161                	addi	sp,sp,80
ffffffffc02002c2:	8082                	ret

ffffffffc02002c4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002c4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002c6:	00006517          	auipc	a0,0x6
ffffffffc02002ca:	43250513          	addi	a0,a0,1074 # ffffffffc02066f8 <etext+0xa0>
void print_kerninfo(void) {
ffffffffc02002ce:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d0:	e01ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d4:	00000597          	auipc	a1,0x0
ffffffffc02002d8:	d6258593          	addi	a1,a1,-670 # ffffffffc0200036 <kern_init>
ffffffffc02002dc:	00006517          	auipc	a0,0x6
ffffffffc02002e0:	43c50513          	addi	a0,a0,1084 # ffffffffc0206718 <etext+0xc0>
ffffffffc02002e4:	dedff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e8:	00006597          	auipc	a1,0x6
ffffffffc02002ec:	37058593          	addi	a1,a1,880 # ffffffffc0206658 <etext>
ffffffffc02002f0:	00006517          	auipc	a0,0x6
ffffffffc02002f4:	44850513          	addi	a0,a0,1096 # ffffffffc0206738 <etext+0xe0>
ffffffffc02002f8:	dd9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fc:	000a1597          	auipc	a1,0xa1
ffffffffc0200300:	cec58593          	addi	a1,a1,-788 # ffffffffc02a0fe8 <edata>
ffffffffc0200304:	00006517          	auipc	a0,0x6
ffffffffc0200308:	45450513          	addi	a0,a0,1108 # ffffffffc0206758 <etext+0x100>
ffffffffc020030c:	dc5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200310:	000ac597          	auipc	a1,0xac
ffffffffc0200314:	26858593          	addi	a1,a1,616 # ffffffffc02ac578 <end>
ffffffffc0200318:	00006517          	auipc	a0,0x6
ffffffffc020031c:	46050513          	addi	a0,a0,1120 # ffffffffc0206778 <etext+0x120>
ffffffffc0200320:	db1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200324:	000ac597          	auipc	a1,0xac
ffffffffc0200328:	65358593          	addi	a1,a1,1619 # ffffffffc02ac977 <end+0x3ff>
ffffffffc020032c:	00000797          	auipc	a5,0x0
ffffffffc0200330:	d0a78793          	addi	a5,a5,-758 # ffffffffc0200036 <kern_init>
ffffffffc0200334:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200338:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020033c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200342:	95be                	add	a1,a1,a5
ffffffffc0200344:	85a9                	srai	a1,a1,0xa
ffffffffc0200346:	00006517          	auipc	a0,0x6
ffffffffc020034a:	45250513          	addi	a0,a0,1106 # ffffffffc0206798 <etext+0x140>
}
ffffffffc020034e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200350:	d81ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200354 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200354:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200356:	00006617          	auipc	a2,0x6
ffffffffc020035a:	37260613          	addi	a2,a2,882 # ffffffffc02066c8 <etext+0x70>
ffffffffc020035e:	04d00593          	li	a1,77
ffffffffc0200362:	00006517          	auipc	a0,0x6
ffffffffc0200366:	37e50513          	addi	a0,a0,894 # ffffffffc02066e0 <etext+0x88>
void print_stackframe(void) {
ffffffffc020036a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020036c:	eabff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200370 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200370:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200372:	00006617          	auipc	a2,0x6
ffffffffc0200376:	53660613          	addi	a2,a2,1334 # ffffffffc02068a8 <commands+0xe0>
ffffffffc020037a:	00006597          	auipc	a1,0x6
ffffffffc020037e:	54e58593          	addi	a1,a1,1358 # ffffffffc02068c8 <commands+0x100>
ffffffffc0200382:	00006517          	auipc	a0,0x6
ffffffffc0200386:	54e50513          	addi	a0,a0,1358 # ffffffffc02068d0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020038a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020038c:	d45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200390:	00006617          	auipc	a2,0x6
ffffffffc0200394:	55060613          	addi	a2,a2,1360 # ffffffffc02068e0 <commands+0x118>
ffffffffc0200398:	00006597          	auipc	a1,0x6
ffffffffc020039c:	57058593          	addi	a1,a1,1392 # ffffffffc0206908 <commands+0x140>
ffffffffc02003a0:	00006517          	auipc	a0,0x6
ffffffffc02003a4:	53050513          	addi	a0,a0,1328 # ffffffffc02068d0 <commands+0x108>
ffffffffc02003a8:	d29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003ac:	00006617          	auipc	a2,0x6
ffffffffc02003b0:	56c60613          	addi	a2,a2,1388 # ffffffffc0206918 <commands+0x150>
ffffffffc02003b4:	00006597          	auipc	a1,0x6
ffffffffc02003b8:	58458593          	addi	a1,a1,1412 # ffffffffc0206938 <commands+0x170>
ffffffffc02003bc:	00006517          	auipc	a0,0x6
ffffffffc02003c0:	51450513          	addi	a0,a0,1300 # ffffffffc02068d0 <commands+0x108>
ffffffffc02003c4:	d0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc02003c8:	60a2                	ld	ra,8(sp)
ffffffffc02003ca:	4501                	li	a0,0
ffffffffc02003cc:	0141                	addi	sp,sp,16
ffffffffc02003ce:	8082                	ret

ffffffffc02003d0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003d0:	1141                	addi	sp,sp,-16
ffffffffc02003d2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d4:	ef1ff0ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>
    return 0;
}
ffffffffc02003d8:	60a2                	ld	ra,8(sp)
ffffffffc02003da:	4501                	li	a0,0
ffffffffc02003dc:	0141                	addi	sp,sp,16
ffffffffc02003de:	8082                	ret

ffffffffc02003e0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003e0:	1141                	addi	sp,sp,-16
ffffffffc02003e2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e4:	f71ff0ef          	jal	ra,ffffffffc0200354 <print_stackframe>
    return 0;
}
ffffffffc02003e8:	60a2                	ld	ra,8(sp)
ffffffffc02003ea:	4501                	li	a0,0
ffffffffc02003ec:	0141                	addi	sp,sp,16
ffffffffc02003ee:	8082                	ret

ffffffffc02003f0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003f0:	7115                	addi	sp,sp,-224
ffffffffc02003f2:	e962                	sd	s8,144(sp)
ffffffffc02003f4:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f6:	00006517          	auipc	a0,0x6
ffffffffc02003fa:	41a50513          	addi	a0,a0,1050 # ffffffffc0206810 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02003fe:	ed86                	sd	ra,216(sp)
ffffffffc0200400:	e9a2                	sd	s0,208(sp)
ffffffffc0200402:	e5a6                	sd	s1,200(sp)
ffffffffc0200404:	e1ca                	sd	s2,192(sp)
ffffffffc0200406:	fd4e                	sd	s3,184(sp)
ffffffffc0200408:	f952                	sd	s4,176(sp)
ffffffffc020040a:	f556                	sd	s5,168(sp)
ffffffffc020040c:	f15a                	sd	s6,160(sp)
ffffffffc020040e:	ed5e                	sd	s7,152(sp)
ffffffffc0200410:	e566                	sd	s9,136(sp)
ffffffffc0200412:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200414:	cbdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200418:	00006517          	auipc	a0,0x6
ffffffffc020041c:	42050513          	addi	a0,a0,1056 # ffffffffc0206838 <commands+0x70>
ffffffffc0200420:	cb1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200424:	000c0563          	beqz	s8,ffffffffc020042e <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200428:	8562                	mv	a0,s8
ffffffffc020042a:	420000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc020042e:	00006c97          	auipc	s9,0x6
ffffffffc0200432:	39ac8c93          	addi	s9,s9,922 # ffffffffc02067c8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200436:	00006997          	auipc	s3,0x6
ffffffffc020043a:	42a98993          	addi	s3,s3,1066 # ffffffffc0206860 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043e:	00006917          	auipc	s2,0x6
ffffffffc0200442:	42a90913          	addi	s2,s2,1066 # ffffffffc0206868 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200446:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200448:	00006b17          	auipc	s6,0x6
ffffffffc020044c:	428b0b13          	addi	s6,s6,1064 # ffffffffc0206870 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200450:	00006a97          	auipc	s5,0x6
ffffffffc0200454:	478a8a93          	addi	s5,s5,1144 # ffffffffc02068c8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200458:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020045a:	854e                	mv	a0,s3
ffffffffc020045c:	cfdff0ef          	jal	ra,ffffffffc0200158 <readline>
ffffffffc0200460:	842a                	mv	s0,a0
ffffffffc0200462:	dd65                	beqz	a0,ffffffffc020045a <kmonitor+0x6a>
ffffffffc0200464:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200468:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020046a:	c999                	beqz	a1,ffffffffc0200480 <kmonitor+0x90>
ffffffffc020046c:	854a                	mv	a0,s2
ffffffffc020046e:	593050ef          	jal	ra,ffffffffc0206200 <strchr>
ffffffffc0200472:	c925                	beqz	a0,ffffffffc02004e2 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200474:	00144583          	lbu	a1,1(s0)
ffffffffc0200478:	00040023          	sb	zero,0(s0)
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047e:	f5fd                	bnez	a1,ffffffffc020046c <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200480:	dce9                	beqz	s1,ffffffffc020045a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	6582                	ld	a1,0(sp)
ffffffffc0200484:	00006d17          	auipc	s10,0x6
ffffffffc0200488:	344d0d13          	addi	s10,s10,836 # ffffffffc02067c8 <commands>
    if (argc == 0) {
ffffffffc020048c:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048e:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200490:	0d61                	addi	s10,s10,24
ffffffffc0200492:	545050ef          	jal	ra,ffffffffc02061d6 <strcmp>
ffffffffc0200496:	c919                	beqz	a0,ffffffffc02004ac <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200498:	2405                	addiw	s0,s0,1
ffffffffc020049a:	09740463          	beq	s0,s7,ffffffffc0200522 <kmonitor+0x132>
ffffffffc020049e:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02004a2:	6582                	ld	a1,0(sp)
ffffffffc02004a4:	0d61                	addi	s10,s10,24
ffffffffc02004a6:	531050ef          	jal	ra,ffffffffc02061d6 <strcmp>
ffffffffc02004aa:	f57d                	bnez	a0,ffffffffc0200498 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004ac:	00141793          	slli	a5,s0,0x1
ffffffffc02004b0:	97a2                	add	a5,a5,s0
ffffffffc02004b2:	078e                	slli	a5,a5,0x3
ffffffffc02004b4:	97e6                	add	a5,a5,s9
ffffffffc02004b6:	6b9c                	ld	a5,16(a5)
ffffffffc02004b8:	8662                	mv	a2,s8
ffffffffc02004ba:	002c                	addi	a1,sp,8
ffffffffc02004bc:	fff4851b          	addiw	a0,s1,-1
ffffffffc02004c0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004c2:	f8055ce3          	bgez	a0,ffffffffc020045a <kmonitor+0x6a>
}
ffffffffc02004c6:	60ee                	ld	ra,216(sp)
ffffffffc02004c8:	644e                	ld	s0,208(sp)
ffffffffc02004ca:	64ae                	ld	s1,200(sp)
ffffffffc02004cc:	690e                	ld	s2,192(sp)
ffffffffc02004ce:	79ea                	ld	s3,184(sp)
ffffffffc02004d0:	7a4a                	ld	s4,176(sp)
ffffffffc02004d2:	7aaa                	ld	s5,168(sp)
ffffffffc02004d4:	7b0a                	ld	s6,160(sp)
ffffffffc02004d6:	6bea                	ld	s7,152(sp)
ffffffffc02004d8:	6c4a                	ld	s8,144(sp)
ffffffffc02004da:	6caa                	ld	s9,136(sp)
ffffffffc02004dc:	6d0a                	ld	s10,128(sp)
ffffffffc02004de:	612d                	addi	sp,sp,224
ffffffffc02004e0:	8082                	ret
        if (*buf == '\0') {
ffffffffc02004e2:	00044783          	lbu	a5,0(s0)
ffffffffc02004e6:	dfc9                	beqz	a5,ffffffffc0200480 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02004e8:	03448863          	beq	s1,s4,ffffffffc0200518 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02004ec:	00349793          	slli	a5,s1,0x3
ffffffffc02004f0:	0118                	addi	a4,sp,128
ffffffffc02004f2:	97ba                	add	a5,a5,a4
ffffffffc02004f4:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f8:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004fc:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fe:	e591                	bnez	a1,ffffffffc020050a <kmonitor+0x11a>
ffffffffc0200500:	b749                	j	ffffffffc0200482 <kmonitor+0x92>
            buf ++;
ffffffffc0200502:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	ddad                	beqz	a1,ffffffffc0200482 <kmonitor+0x92>
ffffffffc020050a:	854a                	mv	a0,s2
ffffffffc020050c:	4f5050ef          	jal	ra,ffffffffc0206200 <strchr>
ffffffffc0200510:	d96d                	beqz	a0,ffffffffc0200502 <kmonitor+0x112>
ffffffffc0200512:	00044583          	lbu	a1,0(s0)
ffffffffc0200516:	bf91                	j	ffffffffc020046a <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200518:	45c1                	li	a1,16
ffffffffc020051a:	855a                	mv	a0,s6
ffffffffc020051c:	bb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200520:	b7f1                	j	ffffffffc02004ec <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200522:	6582                	ld	a1,0(sp)
ffffffffc0200524:	00006517          	auipc	a0,0x6
ffffffffc0200528:	36c50513          	addi	a0,a0,876 # ffffffffc0206890 <commands+0xc8>
ffffffffc020052c:	ba5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc0200530:	b72d                	j	ffffffffc020045a <kmonitor+0x6a>

ffffffffc0200532 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200534:	00253513          	sltiu	a0,a0,2
ffffffffc0200538:	8082                	ret

ffffffffc020053a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020053a:	03800513          	li	a0,56
ffffffffc020053e:	8082                	ret

ffffffffc0200540 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200540:	000a1797          	auipc	a5,0xa1
ffffffffc0200544:	ea878793          	addi	a5,a5,-344 # ffffffffc02a13e8 <ide>
ffffffffc0200548:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020054c:	1141                	addi	sp,sp,-16
ffffffffc020054e:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200550:	95be                	add	a1,a1,a5
ffffffffc0200552:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200556:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200558:	4d9050ef          	jal	ra,ffffffffc0206230 <memcpy>
    return 0;
}
ffffffffc020055c:	60a2                	ld	ra,8(sp)
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	0141                	addi	sp,sp,16
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200564:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200566:	0095979b          	slliw	a5,a1,0x9
ffffffffc020056a:	000a1517          	auipc	a0,0xa1
ffffffffc020056e:	e7e50513          	addi	a0,a0,-386 # ffffffffc02a13e8 <ide>
                   size_t nsecs) {
ffffffffc0200572:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200574:	00969613          	slli	a2,a3,0x9
ffffffffc0200578:	85ba                	mv	a1,a4
ffffffffc020057a:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020057c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020057e:	4b3050ef          	jal	ra,ffffffffc0206230 <memcpy>
    return 0;
}
ffffffffc0200582:	60a2                	ld	ra,8(sp)
ffffffffc0200584:	4501                	li	a0,0
ffffffffc0200586:	0141                	addi	sp,sp,16
ffffffffc0200588:	8082                	ret

ffffffffc020058a <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020058a:	67e1                	lui	a5,0x18
ffffffffc020058c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc28>
ffffffffc0200590:	000ac717          	auipc	a4,0xac
ffffffffc0200594:	e6f73023          	sd	a5,-416(a4) # ffffffffc02ac3f0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200598:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020059c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020059e:	953e                	add	a0,a0,a5
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4881                	li	a7,0
ffffffffc02005a4:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02005a8:	02000793          	li	a5,32
ffffffffc02005ac:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b0:	00006517          	auipc	a0,0x6
ffffffffc02005b4:	39850513          	addi	a0,a0,920 # ffffffffc0206948 <commands+0x180>
    ticks = 0;
ffffffffc02005b8:	000ac797          	auipc	a5,0xac
ffffffffc02005bc:	e807b823          	sd	zero,-368(a5) # ffffffffc02ac448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005c0:	b11ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02005c4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005c4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005c8:	000ac797          	auipc	a5,0xac
ffffffffc02005cc:	e2878793          	addi	a5,a5,-472 # ffffffffc02ac3f0 <timebase>
ffffffffc02005d0:	639c                	ld	a5,0(a5)
ffffffffc02005d2:	4581                	li	a1,0
ffffffffc02005d4:	4601                	li	a2,0
ffffffffc02005d6:	953e                	add	a0,a0,a5
ffffffffc02005d8:	4881                	li	a7,0
ffffffffc02005da:	00000073          	ecall
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005e0:	8082                	ret

ffffffffc02005e2 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005e2:	100027f3          	csrr	a5,sstatus
ffffffffc02005e6:	8b89                	andi	a5,a5,2
ffffffffc02005e8:	0ff57513          	andi	a0,a0,255
ffffffffc02005ec:	e799                	bnez	a5,ffffffffc02005fa <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005ee:	4581                	li	a1,0
ffffffffc02005f0:	4601                	li	a2,0
ffffffffc02005f2:	4885                	li	a7,1
ffffffffc02005f4:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005f8:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005fa:	1101                	addi	sp,sp,-32
ffffffffc02005fc:	ec06                	sd	ra,24(sp)
ffffffffc02005fe:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200600:	05c000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200604:	6522                	ld	a0,8(sp)
ffffffffc0200606:	4581                	li	a1,0
ffffffffc0200608:	4601                	li	a2,0
ffffffffc020060a:	4885                	li	a7,1
ffffffffc020060c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200610:	60e2                	ld	ra,24(sp)
ffffffffc0200612:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200614:	0420006f          	j	ffffffffc0200656 <intr_enable>

ffffffffc0200618 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200618:	100027f3          	csrr	a5,sstatus
ffffffffc020061c:	8b89                	andi	a5,a5,2
ffffffffc020061e:	eb89                	bnez	a5,ffffffffc0200630 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	4581                	li	a1,0
ffffffffc0200624:	4601                	li	a2,0
ffffffffc0200626:	4889                	li	a7,2
ffffffffc0200628:	00000073          	ecall
ffffffffc020062c:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020062e:	8082                	ret
int cons_getc(void) {
ffffffffc0200630:	1101                	addi	sp,sp,-32
ffffffffc0200632:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200634:	028000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200638:	4501                	li	a0,0
ffffffffc020063a:	4581                	li	a1,0
ffffffffc020063c:	4601                	li	a2,0
ffffffffc020063e:	4889                	li	a7,2
ffffffffc0200640:	00000073          	ecall
ffffffffc0200644:	2501                	sext.w	a0,a0
ffffffffc0200646:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200648:	00e000ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc020064c:	60e2                	ld	ra,24(sp)
ffffffffc020064e:	6522                	ld	a0,8(sp)
ffffffffc0200650:	6105                	addi	sp,sp,32
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200654:	8082                	ret

ffffffffc0200656 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200656:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020065a:	8082                	ret

ffffffffc020065c <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065c:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	6b278793          	addi	a5,a5,1714 # ffffffffc0200d18 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	66c50513          	addi	a0,a0,1644 # ffffffffc0206cf0 <commands+0x528>
void print_regs(struct pushregs *gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	a43ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	67450513          	addi	a0,a0,1652 # ffffffffc0206d08 <commands+0x540>
ffffffffc020069c:	a35ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	67e50513          	addi	a0,a0,1662 # ffffffffc0206d20 <commands+0x558>
ffffffffc02006aa:	a27ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	68850513          	addi	a0,a0,1672 # ffffffffc0206d38 <commands+0x570>
ffffffffc02006b8:	a19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	69250513          	addi	a0,a0,1682 # ffffffffc0206d50 <commands+0x588>
ffffffffc02006c6:	a0bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	69c50513          	addi	a0,a0,1692 # ffffffffc0206d68 <commands+0x5a0>
ffffffffc02006d4:	9fdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	6a650513          	addi	a0,a0,1702 # ffffffffc0206d80 <commands+0x5b8>
ffffffffc02006e2:	9efff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	6b050513          	addi	a0,a0,1712 # ffffffffc0206d98 <commands+0x5d0>
ffffffffc02006f0:	9e1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	6ba50513          	addi	a0,a0,1722 # ffffffffc0206db0 <commands+0x5e8>
ffffffffc02006fe:	9d3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	6c450513          	addi	a0,a0,1732 # ffffffffc0206dc8 <commands+0x600>
ffffffffc020070c:	9c5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	6ce50513          	addi	a0,a0,1742 # ffffffffc0206de0 <commands+0x618>
ffffffffc020071a:	9b7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	6d850513          	addi	a0,a0,1752 # ffffffffc0206df8 <commands+0x630>
ffffffffc0200728:	9a9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	6e250513          	addi	a0,a0,1762 # ffffffffc0206e10 <commands+0x648>
ffffffffc0200736:	99bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	6ec50513          	addi	a0,a0,1772 # ffffffffc0206e28 <commands+0x660>
ffffffffc0200744:	98dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	6f650513          	addi	a0,a0,1782 # ffffffffc0206e40 <commands+0x678>
ffffffffc0200752:	97fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	70050513          	addi	a0,a0,1792 # ffffffffc0206e58 <commands+0x690>
ffffffffc0200760:	971ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	70a50513          	addi	a0,a0,1802 # ffffffffc0206e70 <commands+0x6a8>
ffffffffc020076e:	963ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	71450513          	addi	a0,a0,1812 # ffffffffc0206e88 <commands+0x6c0>
ffffffffc020077c:	955ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	71e50513          	addi	a0,a0,1822 # ffffffffc0206ea0 <commands+0x6d8>
ffffffffc020078a:	947ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	72850513          	addi	a0,a0,1832 # ffffffffc0206eb8 <commands+0x6f0>
ffffffffc0200798:	939ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	73250513          	addi	a0,a0,1842 # ffffffffc0206ed0 <commands+0x708>
ffffffffc02007a6:	92bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	73c50513          	addi	a0,a0,1852 # ffffffffc0206ee8 <commands+0x720>
ffffffffc02007b4:	91dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	74650513          	addi	a0,a0,1862 # ffffffffc0206f00 <commands+0x738>
ffffffffc02007c2:	90fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	75050513          	addi	a0,a0,1872 # ffffffffc0206f18 <commands+0x750>
ffffffffc02007d0:	901ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	75a50513          	addi	a0,a0,1882 # ffffffffc0206f30 <commands+0x768>
ffffffffc02007de:	8f3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	76450513          	addi	a0,a0,1892 # ffffffffc0206f48 <commands+0x780>
ffffffffc02007ec:	8e5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	76e50513          	addi	a0,a0,1902 # ffffffffc0206f60 <commands+0x798>
ffffffffc02007fa:	8d7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00006517          	auipc	a0,0x6
ffffffffc0200804:	77850513          	addi	a0,a0,1912 # ffffffffc0206f78 <commands+0x7b0>
ffffffffc0200808:	8c9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00006517          	auipc	a0,0x6
ffffffffc0200812:	78250513          	addi	a0,a0,1922 # ffffffffc0206f90 <commands+0x7c8>
ffffffffc0200816:	8bbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	78c50513          	addi	a0,a0,1932 # ffffffffc0206fa8 <commands+0x7e0>
ffffffffc0200824:	8adff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00006517          	auipc	a0,0x6
ffffffffc020082e:	79650513          	addi	a0,a0,1942 # ffffffffc0206fc0 <commands+0x7f8>
ffffffffc0200832:	89fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	79c50513          	addi	a0,a0,1948 # ffffffffc0206fd8 <commands+0x810>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	88bff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020084a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	79e50513          	addi	a0,a0,1950 # ffffffffc0206ff0 <commands+0x828>
void print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	875ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00006517          	auipc	a0,0x6
ffffffffc020086e:	79e50513          	addi	a0,a0,1950 # ffffffffc0207008 <commands+0x840>
ffffffffc0200872:	85fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	7a650513          	addi	a0,a0,1958 # ffffffffc0207020 <commands+0x858>
ffffffffc0200882:	84fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	7ae50513          	addi	a0,a0,1966 # ffffffffc0207038 <commands+0x870>
ffffffffc0200892:	83fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00006517          	auipc	a0,0x6
ffffffffc02008a2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0207048 <commands+0x880>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	829ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02008ac <pgfault_handler>:
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	bc048493          	addi	s1,s1,-1088 # ffffffffc02ac470 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	38a50513          	addi	a0,a0,906 # ffffffffc0206c70 <commands+0x4a8>
ffffffffc02008ee:	fe2ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	b3278793          	addi	a5,a5,-1230 # ffffffffc02ac428 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	b3078793          	addi	a5,a5,-1232 # ffffffffc02ac430 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	3cc0206f          	j	ffffffffc0202cea <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	af278793          	addi	a5,a5,-1294 # ffffffffc02ac428 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	3960206f          	j	ffffffffc0202cea <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	33868693          	addi	a3,a3,824 # ffffffffc0206c90 <commands+0x4c8>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	34860613          	addi	a2,a2,840 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0200968:	06d00593          	li	a1,109
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	35450513          	addi	a0,a0,852 # ffffffffc0206cc0 <commands+0x4f8>
ffffffffc0200974:	8a3ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	2ce50513          	addi	a0,a0,718 # ffffffffc0206c70 <commands+0x4a8>
ffffffffc02009aa:	f26ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	32a60613          	addi	a2,a2,810 # ffffffffc0206cd8 <commands+0x510>
ffffffffc02009b6:	07400593          	li	a1,116
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	30650513          	addi	a0,a0,774 # ffffffffc0206cc0 <commands+0x4f8>
ffffffffc02009c2:	855ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	f8870713          	addi	a4,a4,-120 # ffffffffc0206964 <commands+0x19c>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	24250513          	addi	a0,a0,578 # ffffffffc0206c30 <commands+0x468>
ffffffffc02009f6:	edaff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	21650513          	addi	a0,a0,534 # ffffffffc0206c10 <commands+0x448>
ffffffffc0200a02:	eceff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	1ca50513          	addi	a0,a0,458 # ffffffffc0206bd0 <commands+0x408>
ffffffffc0200a0e:	ec2ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	1de50513          	addi	a0,a0,478 # ffffffffc0206bf0 <commands+0x428>
ffffffffc0200a1a:	eb6ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	23250513          	addi	a0,a0,562 # ffffffffc0206c50 <commands+0x488>
ffffffffc0200a26:	eaaff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b97ff0ef          	jal	ra,ffffffffc02005c4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	a1678793          	addi	a5,a5,-1514 # ffffffffc02ac448 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	a0f6b123          	sd	a5,-1534(a3) # ffffffffc02ac448 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	9d878793          	addi	a5,a5,-1576 # ffffffffc02ac428 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1ef76b63          	bltu	a4,a5,ffffffffc0200c66 <exception_handler+0x1fc>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	f2070713          	addi	a4,a4,-224 # ffffffffc0206994 <commands+0x1cc>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	09850513          	addi	a0,a0,152 # ffffffffc0206b28 <commands+0x360>
ffffffffc0200a98:	e38ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	6520506f          	j	ffffffffc0206100 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	09650513          	addi	a0,a0,150 # ffffffffc0206b48 <commands+0x380>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	e0eff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	0a250513          	addi	a0,a0,162 # ffffffffc0206b68 <commands+0x3a0>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	0b850513          	addi	a0,a0,184 # ffffffffc0206b88 <commands+0x3c0>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	0c650513          	addi	a0,a0,198 # ffffffffc0206ba0 <commands+0x3d8>
ffffffffc0200ae2:	deeff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	16051e63          	bnez	a0,ffffffffc0200c6a <exception_handler+0x200>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	0bc50513          	addi	a0,a0,188 # ffffffffc0206bb8 <commands+0x3f0>
ffffffffc0200b04:	dccff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	fbe60613          	addi	a2,a2,-66 # ffffffffc0206ad8 <commands+0x310>
ffffffffc0200b22:	10900593          	li	a1,265
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	19a50513          	addi	a0,a0,410 # ffffffffc0206cc0 <commands+0x4f8>
ffffffffc0200b2e:	ee8ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	ea650513          	addi	a0,a0,-346 # ffffffffc02069d8 <commands+0x210>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	ebc50513          	addi	a0,a0,-324 # ffffffffc02069f8 <commands+0x230>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
		cprintf("Exception Type: Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	ed250513          	addi	a0,a0,-302 # ffffffffc0206a18 <commands+0x250>
ffffffffc0200b4e:	d82ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
		cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
ffffffffc0200b52:	10843583          	ld	a1,264(s0)
ffffffffc0200b56:	00006517          	auipc	a0,0x6
ffffffffc0200b5a:	eea50513          	addi	a0,a0,-278 # ffffffffc0206a40 <commands+0x278>
ffffffffc0200b5e:	d72ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
		tf->epc += 2;
ffffffffc0200b62:	10843783          	ld	a5,264(s0)
ffffffffc0200b66:	0789                	addi	a5,a5,2
ffffffffc0200b68:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200b6c:	b759                	j	ffffffffc0200af2 <exception_handler+0x88>
            cprintf("Breakpoint\n");
ffffffffc0200b6e:	00006517          	auipc	a0,0x6
ffffffffc0200b72:	f0250513          	addi	a0,a0,-254 # ffffffffc0206a70 <commands+0x2a8>
ffffffffc0200b76:	d5aff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b7a:	6458                	ld	a4,136(s0)
ffffffffc0200b7c:	47a9                	li	a5,10
ffffffffc0200b7e:	0af70263          	beq	a4,a5,ffffffffc0200c22 <exception_handler+0x1b8>
			cprintf("ebreak caught at 0x%016llx\n", tf->epc);
ffffffffc0200b82:	10843583          	ld	a1,264(s0)
ffffffffc0200b86:	00006517          	auipc	a0,0x6
ffffffffc0200b8a:	efa50513          	addi	a0,a0,-262 # ffffffffc0206a80 <commands+0x2b8>
ffffffffc0200b8e:	d42ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
			tf->epc += 2;
ffffffffc0200b92:	10843783          	ld	a5,264(s0)
ffffffffc0200b96:	0789                	addi	a5,a5,2
ffffffffc0200b98:	10f43423          	sd	a5,264(s0)
ffffffffc0200b9c:	bf99                	j	ffffffffc0200af2 <exception_handler+0x88>
            cprintf("Load address misaligned\n");
ffffffffc0200b9e:	00006517          	auipc	a0,0x6
ffffffffc0200ba2:	f0250513          	addi	a0,a0,-254 # ffffffffc0206aa0 <commands+0x2d8>
ffffffffc0200ba6:	bf11                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200ba8:	00006517          	auipc	a0,0x6
ffffffffc0200bac:	f1850513          	addi	a0,a0,-232 # ffffffffc0206ac0 <commands+0x2f8>
ffffffffc0200bb0:	d20ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb4:	8522                	mv	a0,s0
ffffffffc0200bb6:	cf7ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bba:	84aa                	mv	s1,a0
ffffffffc0200bbc:	d91d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbe:	8522                	mv	a0,s0
ffffffffc0200bc0:	c8bff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc4:	86a6                	mv	a3,s1
ffffffffc0200bc6:	00006617          	auipc	a2,0x6
ffffffffc0200bca:	f1260613          	addi	a2,a2,-238 # ffffffffc0206ad8 <commands+0x310>
ffffffffc0200bce:	0de00593          	li	a1,222
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	0ee50513          	addi	a0,a0,238 # ffffffffc0206cc0 <commands+0x4f8>
ffffffffc0200bda:	e3cff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bde:	00006517          	auipc	a0,0x6
ffffffffc0200be2:	f3250513          	addi	a0,a0,-206 # ffffffffc0206b10 <commands+0x348>
ffffffffc0200be6:	ceaff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bea:	8522                	mv	a0,s0
ffffffffc0200bec:	cc1ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bf0:	84aa                	mv	s1,a0
ffffffffc0200bf2:	f00500e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bf6:	8522                	mv	a0,s0
ffffffffc0200bf8:	c53ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bfc:	86a6                	mv	a3,s1
ffffffffc0200bfe:	00006617          	auipc	a2,0x6
ffffffffc0200c02:	eda60613          	addi	a2,a2,-294 # ffffffffc0206ad8 <commands+0x310>
ffffffffc0200c06:	0e800593          	li	a1,232
ffffffffc0200c0a:	00006517          	auipc	a0,0x6
ffffffffc0200c0e:	0b650513          	addi	a0,a0,182 # ffffffffc0206cc0 <commands+0x4f8>
ffffffffc0200c12:	e04ff0ef          	jal	ra,ffffffffc0200216 <__panic>
}
ffffffffc0200c16:	6442                	ld	s0,16(sp)
ffffffffc0200c18:	60e2                	ld	ra,24(sp)
ffffffffc0200c1a:	64a2                	ld	s1,8(sp)
ffffffffc0200c1c:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c1e:	c2dff06f          	j	ffffffffc020084a <print_trapframe>
                tf->epc += 4;
ffffffffc0200c22:	10843783          	ld	a5,264(s0)
ffffffffc0200c26:	0791                	addi	a5,a5,4
ffffffffc0200c28:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200c2c:	4d4050ef          	jal	ra,ffffffffc0206100 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200c30:	000ab797          	auipc	a5,0xab
ffffffffc0200c34:	7f878793          	addi	a5,a5,2040 # ffffffffc02ac428 <current>
ffffffffc0200c38:	639c                	ld	a5,0(a5)
ffffffffc0200c3a:	8522                	mv	a0,s0
}
ffffffffc0200c3c:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200c3e:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200c40:	60e2                	ld	ra,24(sp)
ffffffffc0200c42:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200c44:	6589                	lui	a1,0x2
ffffffffc0200c46:	95be                	add	a1,a1,a5
}
ffffffffc0200c48:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200c4a:	19c0006f          	j	ffffffffc0200de6 <kernel_execve_ret>
            panic("AMO address misaligned\n");
ffffffffc0200c4e:	00006617          	auipc	a2,0x6
ffffffffc0200c52:	eaa60613          	addi	a2,a2,-342 # ffffffffc0206af8 <commands+0x330>
ffffffffc0200c56:	0e200593          	li	a1,226
ffffffffc0200c5a:	00006517          	auipc	a0,0x6
ffffffffc0200c5e:	06650513          	addi	a0,a0,102 # ffffffffc0206cc0 <commands+0x4f8>
ffffffffc0200c62:	db4ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200c66:	be5ff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c6a:	8522                	mv	a0,s0
ffffffffc0200c6c:	bdfff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c70:	86a6                	mv	a3,s1
ffffffffc0200c72:	00006617          	auipc	a2,0x6
ffffffffc0200c76:	e6660613          	addi	a2,a2,-410 # ffffffffc0206ad8 <commands+0x310>
ffffffffc0200c7a:	10200593          	li	a1,258
ffffffffc0200c7e:	00006517          	auipc	a0,0x6
ffffffffc0200c82:	04250513          	addi	a0,a0,66 # ffffffffc0206cc0 <commands+0x4f8>
ffffffffc0200c86:	d90ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200c8a <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c8a:	1101                	addi	sp,sp,-32
ffffffffc0200c8c:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c8e:	000ab417          	auipc	s0,0xab
ffffffffc0200c92:	79a40413          	addi	s0,s0,1946 # ffffffffc02ac428 <current>
ffffffffc0200c96:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c98:	ec06                	sd	ra,24(sp)
ffffffffc0200c9a:	e426                	sd	s1,8(sp)
ffffffffc0200c9c:	e04a                	sd	s2,0(sp)
ffffffffc0200c9e:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200ca2:	cf1d                	beqz	a4,ffffffffc0200ce0 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200ca4:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200ca8:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200cac:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200cae:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200cb2:	0206c463          	bltz	a3,ffffffffc0200cda <trap+0x50>
        exception_handler(tf);
ffffffffc0200cb6:	db5ff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200cba:	601c                	ld	a5,0(s0)
ffffffffc0200cbc:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200cc0:	e499                	bnez	s1,ffffffffc0200cce <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200cc2:	0b07a703          	lw	a4,176(a5)
ffffffffc0200cc6:	8b05                	andi	a4,a4,1
ffffffffc0200cc8:	e339                	bnez	a4,ffffffffc0200d0e <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200cca:	6f9c                	ld	a5,24(a5)
ffffffffc0200ccc:	eb95                	bnez	a5,ffffffffc0200d00 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200cce:	60e2                	ld	ra,24(sp)
ffffffffc0200cd0:	6442                	ld	s0,16(sp)
ffffffffc0200cd2:	64a2                	ld	s1,8(sp)
ffffffffc0200cd4:	6902                	ld	s2,0(sp)
ffffffffc0200cd6:	6105                	addi	sp,sp,32
ffffffffc0200cd8:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200cda:	cf3ff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200cde:	bff1                	j	ffffffffc0200cba <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ce0:	0006c963          	bltz	a3,ffffffffc0200cf2 <trap+0x68>
}
ffffffffc0200ce4:	6442                	ld	s0,16(sp)
ffffffffc0200ce6:	60e2                	ld	ra,24(sp)
ffffffffc0200ce8:	64a2                	ld	s1,8(sp)
ffffffffc0200cea:	6902                	ld	s2,0(sp)
ffffffffc0200cec:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cee:	d7dff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cf2:	6442                	ld	s0,16(sp)
ffffffffc0200cf4:	60e2                	ld	ra,24(sp)
ffffffffc0200cf6:	64a2                	ld	s1,8(sp)
ffffffffc0200cf8:	6902                	ld	s2,0(sp)
ffffffffc0200cfa:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cfc:	cd1ff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200d00:	6442                	ld	s0,16(sp)
ffffffffc0200d02:	60e2                	ld	ra,24(sp)
ffffffffc0200d04:	64a2                	ld	s1,8(sp)
ffffffffc0200d06:	6902                	ld	s2,0(sp)
ffffffffc0200d08:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200d0a:	3000506f          	j	ffffffffc020600a <schedule>
                do_exit(-E_KILLED);
ffffffffc0200d0e:	555d                	li	a0,-9
ffffffffc0200d10:	762040ef          	jal	ra,ffffffffc0205472 <do_exit>
ffffffffc0200d14:	601c                	ld	a5,0(s0)
ffffffffc0200d16:	bf55                	j	ffffffffc0200cca <trap+0x40>

ffffffffc0200d18 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200d18:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200d1c:	00011463          	bnez	sp,ffffffffc0200d24 <__alltraps+0xc>
ffffffffc0200d20:	14002173          	csrr	sp,sscratch
ffffffffc0200d24:	712d                	addi	sp,sp,-288
ffffffffc0200d26:	e002                	sd	zero,0(sp)
ffffffffc0200d28:	e406                	sd	ra,8(sp)
ffffffffc0200d2a:	ec0e                	sd	gp,24(sp)
ffffffffc0200d2c:	f012                	sd	tp,32(sp)
ffffffffc0200d2e:	f416                	sd	t0,40(sp)
ffffffffc0200d30:	f81a                	sd	t1,48(sp)
ffffffffc0200d32:	fc1e                	sd	t2,56(sp)
ffffffffc0200d34:	e0a2                	sd	s0,64(sp)
ffffffffc0200d36:	e4a6                	sd	s1,72(sp)
ffffffffc0200d38:	e8aa                	sd	a0,80(sp)
ffffffffc0200d3a:	ecae                	sd	a1,88(sp)
ffffffffc0200d3c:	f0b2                	sd	a2,96(sp)
ffffffffc0200d3e:	f4b6                	sd	a3,104(sp)
ffffffffc0200d40:	f8ba                	sd	a4,112(sp)
ffffffffc0200d42:	fcbe                	sd	a5,120(sp)
ffffffffc0200d44:	e142                	sd	a6,128(sp)
ffffffffc0200d46:	e546                	sd	a7,136(sp)
ffffffffc0200d48:	e94a                	sd	s2,144(sp)
ffffffffc0200d4a:	ed4e                	sd	s3,152(sp)
ffffffffc0200d4c:	f152                	sd	s4,160(sp)
ffffffffc0200d4e:	f556                	sd	s5,168(sp)
ffffffffc0200d50:	f95a                	sd	s6,176(sp)
ffffffffc0200d52:	fd5e                	sd	s7,184(sp)
ffffffffc0200d54:	e1e2                	sd	s8,192(sp)
ffffffffc0200d56:	e5e6                	sd	s9,200(sp)
ffffffffc0200d58:	e9ea                	sd	s10,208(sp)
ffffffffc0200d5a:	edee                	sd	s11,216(sp)
ffffffffc0200d5c:	f1f2                	sd	t3,224(sp)
ffffffffc0200d5e:	f5f6                	sd	t4,232(sp)
ffffffffc0200d60:	f9fa                	sd	t5,240(sp)
ffffffffc0200d62:	fdfe                	sd	t6,248(sp)
ffffffffc0200d64:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d68:	100024f3          	csrr	s1,sstatus
ffffffffc0200d6c:	14102973          	csrr	s2,sepc
ffffffffc0200d70:	143029f3          	csrr	s3,stval
ffffffffc0200d74:	14202a73          	csrr	s4,scause
ffffffffc0200d78:	e822                	sd	s0,16(sp)
ffffffffc0200d7a:	e226                	sd	s1,256(sp)
ffffffffc0200d7c:	e64a                	sd	s2,264(sp)
ffffffffc0200d7e:	ea4e                	sd	s3,272(sp)
ffffffffc0200d80:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d82:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d84:	f07ff0ef          	jal	ra,ffffffffc0200c8a <trap>

ffffffffc0200d88 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d88:	6492                	ld	s1,256(sp)
ffffffffc0200d8a:	6932                	ld	s2,264(sp)
ffffffffc0200d8c:	1004f413          	andi	s0,s1,256
ffffffffc0200d90:	e401                	bnez	s0,ffffffffc0200d98 <__trapret+0x10>
ffffffffc0200d92:	1200                	addi	s0,sp,288
ffffffffc0200d94:	14041073          	csrw	sscratch,s0
ffffffffc0200d98:	10049073          	csrw	sstatus,s1
ffffffffc0200d9c:	14191073          	csrw	sepc,s2
ffffffffc0200da0:	60a2                	ld	ra,8(sp)
ffffffffc0200da2:	61e2                	ld	gp,24(sp)
ffffffffc0200da4:	7202                	ld	tp,32(sp)
ffffffffc0200da6:	72a2                	ld	t0,40(sp)
ffffffffc0200da8:	7342                	ld	t1,48(sp)
ffffffffc0200daa:	73e2                	ld	t2,56(sp)
ffffffffc0200dac:	6406                	ld	s0,64(sp)
ffffffffc0200dae:	64a6                	ld	s1,72(sp)
ffffffffc0200db0:	6546                	ld	a0,80(sp)
ffffffffc0200db2:	65e6                	ld	a1,88(sp)
ffffffffc0200db4:	7606                	ld	a2,96(sp)
ffffffffc0200db6:	76a6                	ld	a3,104(sp)
ffffffffc0200db8:	7746                	ld	a4,112(sp)
ffffffffc0200dba:	77e6                	ld	a5,120(sp)
ffffffffc0200dbc:	680a                	ld	a6,128(sp)
ffffffffc0200dbe:	68aa                	ld	a7,136(sp)
ffffffffc0200dc0:	694a                	ld	s2,144(sp)
ffffffffc0200dc2:	69ea                	ld	s3,152(sp)
ffffffffc0200dc4:	7a0a                	ld	s4,160(sp)
ffffffffc0200dc6:	7aaa                	ld	s5,168(sp)
ffffffffc0200dc8:	7b4a                	ld	s6,176(sp)
ffffffffc0200dca:	7bea                	ld	s7,184(sp)
ffffffffc0200dcc:	6c0e                	ld	s8,192(sp)
ffffffffc0200dce:	6cae                	ld	s9,200(sp)
ffffffffc0200dd0:	6d4e                	ld	s10,208(sp)
ffffffffc0200dd2:	6dee                	ld	s11,216(sp)
ffffffffc0200dd4:	7e0e                	ld	t3,224(sp)
ffffffffc0200dd6:	7eae                	ld	t4,232(sp)
ffffffffc0200dd8:	7f4e                	ld	t5,240(sp)
ffffffffc0200dda:	7fee                	ld	t6,248(sp)
ffffffffc0200ddc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200dde:	10200073          	sret

ffffffffc0200de2 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200de2:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200de4:	b755                	j	ffffffffc0200d88 <__trapret>

ffffffffc0200de6 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200de6:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200dea:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200dee:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200df2:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200df6:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dfa:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dfe:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200e02:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200e06:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200e0a:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200e0c:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200e0e:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200e10:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200e12:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200e14:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200e16:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200e18:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200e1a:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200e1c:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200e1e:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200e20:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200e22:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200e24:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200e26:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200e28:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200e2a:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200e2c:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200e2e:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200e30:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200e32:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200e34:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200e36:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e38:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e3a:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e3c:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e3e:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e40:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e42:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e44:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e46:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e48:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e4a:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e4c:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e4e:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e50:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e52:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e54:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e56:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e58:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e5a:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e5c:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e5e:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e60:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e62:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e64:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e66:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e68:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e6a:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e6c:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e6e:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e70:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e72:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e74:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e76:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e78:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e7a:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e7c:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e7e:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e80:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e82:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e84:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e86:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e88:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e8a:	812e                	mv	sp,a1
ffffffffc0200e8c:	bdf5                	j	ffffffffc0200d88 <__trapret>

ffffffffc0200e8e <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e8e:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e90:	00006617          	auipc	a2,0x6
ffffffffc0200e94:	23860613          	addi	a2,a2,568 # ffffffffc02070c8 <commands+0x900>
ffffffffc0200e98:	06200593          	li	a1,98
ffffffffc0200e9c:	00006517          	auipc	a0,0x6
ffffffffc0200ea0:	24c50513          	addi	a0,a0,588 # ffffffffc02070e8 <commands+0x920>
pa2page(uintptr_t pa) {
ffffffffc0200ea4:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200ea6:	b70ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200eaa <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200eaa:	715d                	addi	sp,sp,-80
ffffffffc0200eac:	e0a2                	sd	s0,64(sp)
ffffffffc0200eae:	fc26                	sd	s1,56(sp)
ffffffffc0200eb0:	f84a                	sd	s2,48(sp)
ffffffffc0200eb2:	f44e                	sd	s3,40(sp)
ffffffffc0200eb4:	f052                	sd	s4,32(sp)
ffffffffc0200eb6:	ec56                	sd	s5,24(sp)
ffffffffc0200eb8:	e486                	sd	ra,72(sp)
ffffffffc0200eba:	842a                	mv	s0,a0
ffffffffc0200ebc:	000ab497          	auipc	s1,0xab
ffffffffc0200ec0:	59448493          	addi	s1,s1,1428 # ffffffffc02ac450 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ec4:	4985                	li	s3,1
ffffffffc0200ec6:	000aba17          	auipc	s4,0xab
ffffffffc0200eca:	552a0a13          	addi	s4,s4,1362 # ffffffffc02ac418 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ece:	0005091b          	sext.w	s2,a0
ffffffffc0200ed2:	000aba97          	auipc	s5,0xab
ffffffffc0200ed6:	59ea8a93          	addi	s5,s5,1438 # ffffffffc02ac470 <check_mm_struct>
ffffffffc0200eda:	a00d                	j	ffffffffc0200efc <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200edc:	609c                	ld	a5,0(s1)
ffffffffc0200ede:	6f9c                	ld	a5,24(a5)
ffffffffc0200ee0:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ee2:	4601                	li	a2,0
ffffffffc0200ee4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ee6:	ed0d                	bnez	a0,ffffffffc0200f20 <alloc_pages+0x76>
ffffffffc0200ee8:	0289ec63          	bltu	s3,s0,ffffffffc0200f20 <alloc_pages+0x76>
ffffffffc0200eec:	000a2783          	lw	a5,0(s4)
ffffffffc0200ef0:	2781                	sext.w	a5,a5
ffffffffc0200ef2:	c79d                	beqz	a5,ffffffffc0200f20 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ef4:	000ab503          	ld	a0,0(s5)
ffffffffc0200ef8:	70c020ef          	jal	ra,ffffffffc0203604 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200efc:	100027f3          	csrr	a5,sstatus
ffffffffc0200f00:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200f02:	8522                	mv	a0,s0
ffffffffc0200f04:	dfe1                	beqz	a5,ffffffffc0200edc <alloc_pages+0x32>
        intr_disable();
ffffffffc0200f06:	f56ff0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200f0a:	609c                	ld	a5,0(s1)
ffffffffc0200f0c:	8522                	mv	a0,s0
ffffffffc0200f0e:	6f9c                	ld	a5,24(a5)
ffffffffc0200f10:	9782                	jalr	a5
ffffffffc0200f12:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200f14:	f42ff0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0200f18:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200f1a:	4601                	li	a2,0
ffffffffc0200f1c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200f1e:	d569                	beqz	a0,ffffffffc0200ee8 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200f20:	60a6                	ld	ra,72(sp)
ffffffffc0200f22:	6406                	ld	s0,64(sp)
ffffffffc0200f24:	74e2                	ld	s1,56(sp)
ffffffffc0200f26:	7942                	ld	s2,48(sp)
ffffffffc0200f28:	79a2                	ld	s3,40(sp)
ffffffffc0200f2a:	7a02                	ld	s4,32(sp)
ffffffffc0200f2c:	6ae2                	ld	s5,24(sp)
ffffffffc0200f2e:	6161                	addi	sp,sp,80
ffffffffc0200f30:	8082                	ret

ffffffffc0200f32 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f32:	100027f3          	csrr	a5,sstatus
ffffffffc0200f36:	8b89                	andi	a5,a5,2
ffffffffc0200f38:	eb89                	bnez	a5,ffffffffc0200f4a <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200f3a:	000ab797          	auipc	a5,0xab
ffffffffc0200f3e:	51678793          	addi	a5,a5,1302 # ffffffffc02ac450 <pmm_manager>
ffffffffc0200f42:	639c                	ld	a5,0(a5)
ffffffffc0200f44:	0207b303          	ld	t1,32(a5)
ffffffffc0200f48:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f4a:	1101                	addi	sp,sp,-32
ffffffffc0200f4c:	ec06                	sd	ra,24(sp)
ffffffffc0200f4e:	e822                	sd	s0,16(sp)
ffffffffc0200f50:	e426                	sd	s1,8(sp)
ffffffffc0200f52:	842a                	mv	s0,a0
ffffffffc0200f54:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f56:	f06ff0ef          	jal	ra,ffffffffc020065c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f5a:	000ab797          	auipc	a5,0xab
ffffffffc0200f5e:	4f678793          	addi	a5,a5,1270 # ffffffffc02ac450 <pmm_manager>
ffffffffc0200f62:	639c                	ld	a5,0(a5)
ffffffffc0200f64:	85a6                	mv	a1,s1
ffffffffc0200f66:	8522                	mv	a0,s0
ffffffffc0200f68:	739c                	ld	a5,32(a5)
ffffffffc0200f6a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f6c:	6442                	ld	s0,16(sp)
ffffffffc0200f6e:	60e2                	ld	ra,24(sp)
ffffffffc0200f70:	64a2                	ld	s1,8(sp)
ffffffffc0200f72:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f74:	ee2ff06f          	j	ffffffffc0200656 <intr_enable>

ffffffffc0200f78 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f78:	100027f3          	csrr	a5,sstatus
ffffffffc0200f7c:	8b89                	andi	a5,a5,2
ffffffffc0200f7e:	eb89                	bnez	a5,ffffffffc0200f90 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f80:	000ab797          	auipc	a5,0xab
ffffffffc0200f84:	4d078793          	addi	a5,a5,1232 # ffffffffc02ac450 <pmm_manager>
ffffffffc0200f88:	639c                	ld	a5,0(a5)
ffffffffc0200f8a:	0287b303          	ld	t1,40(a5)
ffffffffc0200f8e:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200f90:	1141                	addi	sp,sp,-16
ffffffffc0200f92:	e406                	sd	ra,8(sp)
ffffffffc0200f94:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f96:	ec6ff0ef          	jal	ra,ffffffffc020065c <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f9a:	000ab797          	auipc	a5,0xab
ffffffffc0200f9e:	4b678793          	addi	a5,a5,1206 # ffffffffc02ac450 <pmm_manager>
ffffffffc0200fa2:	639c                	ld	a5,0(a5)
ffffffffc0200fa4:	779c                	ld	a5,40(a5)
ffffffffc0200fa6:	9782                	jalr	a5
ffffffffc0200fa8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200faa:	eacff0ef          	jal	ra,ffffffffc0200656 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200fae:	8522                	mv	a0,s0
ffffffffc0200fb0:	60a2                	ld	ra,8(sp)
ffffffffc0200fb2:	6402                	ld	s0,0(sp)
ffffffffc0200fb4:	0141                	addi	sp,sp,16
ffffffffc0200fb6:	8082                	ret

ffffffffc0200fb8 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200fb8:	7139                	addi	sp,sp,-64
ffffffffc0200fba:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200fbc:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200fc0:	1ff4f493          	andi	s1,s1,511
ffffffffc0200fc4:	048e                	slli	s1,s1,0x3
ffffffffc0200fc6:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200fc8:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200fca:	f04a                	sd	s2,32(sp)
ffffffffc0200fcc:	ec4e                	sd	s3,24(sp)
ffffffffc0200fce:	e852                	sd	s4,16(sp)
ffffffffc0200fd0:	fc06                	sd	ra,56(sp)
ffffffffc0200fd2:	f822                	sd	s0,48(sp)
ffffffffc0200fd4:	e456                	sd	s5,8(sp)
ffffffffc0200fd6:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200fd8:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200fdc:	892e                	mv	s2,a1
ffffffffc0200fde:	8a32                	mv	s4,a2
ffffffffc0200fe0:	000ab997          	auipc	s3,0xab
ffffffffc0200fe4:	42098993          	addi	s3,s3,1056 # ffffffffc02ac400 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200fe8:	e7bd                	bnez	a5,ffffffffc0201056 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200fea:	12060c63          	beqz	a2,ffffffffc0201122 <get_pte+0x16a>
ffffffffc0200fee:	4505                	li	a0,1
ffffffffc0200ff0:	ebbff0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0200ff4:	842a                	mv	s0,a0
ffffffffc0200ff6:	12050663          	beqz	a0,ffffffffc0201122 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200ffa:	000abb17          	auipc	s6,0xab
ffffffffc0200ffe:	46eb0b13          	addi	s6,s6,1134 # ffffffffc02ac468 <pages>
ffffffffc0201002:	000b3503          	ld	a0,0(s6)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201006:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201008:	000ab997          	auipc	s3,0xab
ffffffffc020100c:	3f898993          	addi	s3,s3,1016 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc0201010:	40a40533          	sub	a0,s0,a0
ffffffffc0201014:	00080ab7          	lui	s5,0x80
ffffffffc0201018:	8519                	srai	a0,a0,0x6
ffffffffc020101a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020101e:	c01c                	sw	a5,0(s0)
ffffffffc0201020:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201022:	9556                	add	a0,a0,s5
ffffffffc0201024:	83b1                	srli	a5,a5,0xc
ffffffffc0201026:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201028:	0532                	slli	a0,a0,0xc
ffffffffc020102a:	14e7f363          	bleu	a4,a5,ffffffffc0201170 <get_pte+0x1b8>
ffffffffc020102e:	000ab797          	auipc	a5,0xab
ffffffffc0201032:	42a78793          	addi	a5,a5,1066 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0201036:	639c                	ld	a5,0(a5)
ffffffffc0201038:	6605                	lui	a2,0x1
ffffffffc020103a:	4581                	li	a1,0
ffffffffc020103c:	953e                	add	a0,a0,a5
ffffffffc020103e:	1e0050ef          	jal	ra,ffffffffc020621e <memset>
    return page - pages + nbase;
ffffffffc0201042:	000b3683          	ld	a3,0(s6)
ffffffffc0201046:	40d406b3          	sub	a3,s0,a3
ffffffffc020104a:	8699                	srai	a3,a3,0x6
ffffffffc020104c:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020104e:	06aa                	slli	a3,a3,0xa
ffffffffc0201050:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201054:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201056:	77fd                	lui	a5,0xfffff
ffffffffc0201058:	068a                	slli	a3,a3,0x2
ffffffffc020105a:	0009b703          	ld	a4,0(s3)
ffffffffc020105e:	8efd                	and	a3,a3,a5
ffffffffc0201060:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201064:	0ce7f163          	bleu	a4,a5,ffffffffc0201126 <get_pte+0x16e>
ffffffffc0201068:	000aba97          	auipc	s5,0xab
ffffffffc020106c:	3f0a8a93          	addi	s5,s5,1008 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0201070:	000ab403          	ld	s0,0(s5)
ffffffffc0201074:	01595793          	srli	a5,s2,0x15
ffffffffc0201078:	1ff7f793          	andi	a5,a5,511
ffffffffc020107c:	96a2                	add	a3,a3,s0
ffffffffc020107e:	00379413          	slli	s0,a5,0x3
ffffffffc0201082:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201084:	6014                	ld	a3,0(s0)
ffffffffc0201086:	0016f793          	andi	a5,a3,1
ffffffffc020108a:	e3ad                	bnez	a5,ffffffffc02010ec <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020108c:	080a0b63          	beqz	s4,ffffffffc0201122 <get_pte+0x16a>
ffffffffc0201090:	4505                	li	a0,1
ffffffffc0201092:	e19ff0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0201096:	84aa                	mv	s1,a0
ffffffffc0201098:	c549                	beqz	a0,ffffffffc0201122 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020109a:	000abb17          	auipc	s6,0xab
ffffffffc020109e:	3ceb0b13          	addi	s6,s6,974 # ffffffffc02ac468 <pages>
ffffffffc02010a2:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc02010a6:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc02010a8:	00080a37          	lui	s4,0x80
ffffffffc02010ac:	40a48533          	sub	a0,s1,a0
ffffffffc02010b0:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02010b2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc02010b6:	c09c                	sw	a5,0(s1)
ffffffffc02010b8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02010ba:	9552                	add	a0,a0,s4
ffffffffc02010bc:	83b1                	srli	a5,a5,0xc
ffffffffc02010be:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02010c0:	0532                	slli	a0,a0,0xc
ffffffffc02010c2:	08e7fa63          	bleu	a4,a5,ffffffffc0201156 <get_pte+0x19e>
ffffffffc02010c6:	000ab783          	ld	a5,0(s5)
ffffffffc02010ca:	6605                	lui	a2,0x1
ffffffffc02010cc:	4581                	li	a1,0
ffffffffc02010ce:	953e                	add	a0,a0,a5
ffffffffc02010d0:	14e050ef          	jal	ra,ffffffffc020621e <memset>
    return page - pages + nbase;
ffffffffc02010d4:	000b3683          	ld	a3,0(s6)
ffffffffc02010d8:	40d486b3          	sub	a3,s1,a3
ffffffffc02010dc:	8699                	srai	a3,a3,0x6
ffffffffc02010de:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02010e0:	06aa                	slli	a3,a3,0xa
ffffffffc02010e2:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02010e6:	e014                	sd	a3,0(s0)
ffffffffc02010e8:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010ec:	068a                	slli	a3,a3,0x2
ffffffffc02010ee:	757d                	lui	a0,0xfffff
ffffffffc02010f0:	8ee9                	and	a3,a3,a0
ffffffffc02010f2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010f6:	04e7f463          	bleu	a4,a5,ffffffffc020113e <get_pte+0x186>
ffffffffc02010fa:	000ab503          	ld	a0,0(s5)
ffffffffc02010fe:	00c95793          	srli	a5,s2,0xc
ffffffffc0201102:	1ff7f793          	andi	a5,a5,511
ffffffffc0201106:	96aa                	add	a3,a3,a0
ffffffffc0201108:	00379513          	slli	a0,a5,0x3
ffffffffc020110c:	9536                	add	a0,a0,a3
}
ffffffffc020110e:	70e2                	ld	ra,56(sp)
ffffffffc0201110:	7442                	ld	s0,48(sp)
ffffffffc0201112:	74a2                	ld	s1,40(sp)
ffffffffc0201114:	7902                	ld	s2,32(sp)
ffffffffc0201116:	69e2                	ld	s3,24(sp)
ffffffffc0201118:	6a42                	ld	s4,16(sp)
ffffffffc020111a:	6aa2                	ld	s5,8(sp)
ffffffffc020111c:	6b02                	ld	s6,0(sp)
ffffffffc020111e:	6121                	addi	sp,sp,64
ffffffffc0201120:	8082                	ret
            return NULL;
ffffffffc0201122:	4501                	li	a0,0
ffffffffc0201124:	b7ed                	j	ffffffffc020110e <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201126:	00006617          	auipc	a2,0x6
ffffffffc020112a:	f6a60613          	addi	a2,a2,-150 # ffffffffc0207090 <commands+0x8c8>
ffffffffc020112e:	0e300593          	li	a1,227
ffffffffc0201132:	00006517          	auipc	a0,0x6
ffffffffc0201136:	f8650513          	addi	a0,a0,-122 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc020113a:	8dcff0ef          	jal	ra,ffffffffc0200216 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020113e:	00006617          	auipc	a2,0x6
ffffffffc0201142:	f5260613          	addi	a2,a2,-174 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0201146:	0ee00593          	li	a1,238
ffffffffc020114a:	00006517          	auipc	a0,0x6
ffffffffc020114e:	f6e50513          	addi	a0,a0,-146 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201152:	8c4ff0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201156:	86aa                	mv	a3,a0
ffffffffc0201158:	00006617          	auipc	a2,0x6
ffffffffc020115c:	f3860613          	addi	a2,a2,-200 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0201160:	0eb00593          	li	a1,235
ffffffffc0201164:	00006517          	auipc	a0,0x6
ffffffffc0201168:	f5450513          	addi	a0,a0,-172 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc020116c:	8aaff0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201170:	86aa                	mv	a3,a0
ffffffffc0201172:	00006617          	auipc	a2,0x6
ffffffffc0201176:	f1e60613          	addi	a2,a2,-226 # ffffffffc0207090 <commands+0x8c8>
ffffffffc020117a:	0df00593          	li	a1,223
ffffffffc020117e:	00006517          	auipc	a0,0x6
ffffffffc0201182:	f3a50513          	addi	a0,a0,-198 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201186:	890ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020118a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020118a:	1141                	addi	sp,sp,-16
ffffffffc020118c:	e022                	sd	s0,0(sp)
ffffffffc020118e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201190:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201192:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201194:	e25ff0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201198:	c011                	beqz	s0,ffffffffc020119c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020119a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020119c:	c129                	beqz	a0,ffffffffc02011de <get_page+0x54>
ffffffffc020119e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02011a0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02011a2:	0017f713          	andi	a4,a5,1
ffffffffc02011a6:	e709                	bnez	a4,ffffffffc02011b0 <get_page+0x26>
}
ffffffffc02011a8:	60a2                	ld	ra,8(sp)
ffffffffc02011aa:	6402                	ld	s0,0(sp)
ffffffffc02011ac:	0141                	addi	sp,sp,16
ffffffffc02011ae:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02011b0:	000ab717          	auipc	a4,0xab
ffffffffc02011b4:	25070713          	addi	a4,a4,592 # ffffffffc02ac400 <npage>
ffffffffc02011b8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02011ba:	078a                	slli	a5,a5,0x2
ffffffffc02011bc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02011be:	02e7f563          	bleu	a4,a5,ffffffffc02011e8 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02011c2:	000ab717          	auipc	a4,0xab
ffffffffc02011c6:	2a670713          	addi	a4,a4,678 # ffffffffc02ac468 <pages>
ffffffffc02011ca:	6308                	ld	a0,0(a4)
ffffffffc02011cc:	60a2                	ld	ra,8(sp)
ffffffffc02011ce:	6402                	ld	s0,0(sp)
ffffffffc02011d0:	fff80737          	lui	a4,0xfff80
ffffffffc02011d4:	97ba                	add	a5,a5,a4
ffffffffc02011d6:	079a                	slli	a5,a5,0x6
ffffffffc02011d8:	953e                	add	a0,a0,a5
ffffffffc02011da:	0141                	addi	sp,sp,16
ffffffffc02011dc:	8082                	ret
ffffffffc02011de:	60a2                	ld	ra,8(sp)
ffffffffc02011e0:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02011e2:	4501                	li	a0,0
}
ffffffffc02011e4:	0141                	addi	sp,sp,16
ffffffffc02011e6:	8082                	ret
ffffffffc02011e8:	ca7ff0ef          	jal	ra,ffffffffc0200e8e <pa2page.part.4>

ffffffffc02011ec <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02011ec:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011ee:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02011f2:	ec86                	sd	ra,88(sp)
ffffffffc02011f4:	e8a2                	sd	s0,80(sp)
ffffffffc02011f6:	e4a6                	sd	s1,72(sp)
ffffffffc02011f8:	e0ca                	sd	s2,64(sp)
ffffffffc02011fa:	fc4e                	sd	s3,56(sp)
ffffffffc02011fc:	f852                	sd	s4,48(sp)
ffffffffc02011fe:	f456                	sd	s5,40(sp)
ffffffffc0201200:	f05a                	sd	s6,32(sp)
ffffffffc0201202:	ec5e                	sd	s7,24(sp)
ffffffffc0201204:	e862                	sd	s8,16(sp)
ffffffffc0201206:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201208:	03479713          	slli	a4,a5,0x34
ffffffffc020120c:	eb71                	bnez	a4,ffffffffc02012e0 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc020120e:	002007b7          	lui	a5,0x200
ffffffffc0201212:	842e                	mv	s0,a1
ffffffffc0201214:	0af5e663          	bltu	a1,a5,ffffffffc02012c0 <unmap_range+0xd4>
ffffffffc0201218:	8932                	mv	s2,a2
ffffffffc020121a:	0ac5f363          	bleu	a2,a1,ffffffffc02012c0 <unmap_range+0xd4>
ffffffffc020121e:	4785                	li	a5,1
ffffffffc0201220:	07fe                	slli	a5,a5,0x1f
ffffffffc0201222:	08c7ef63          	bltu	a5,a2,ffffffffc02012c0 <unmap_range+0xd4>
ffffffffc0201226:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0201228:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020122a:	000abc97          	auipc	s9,0xab
ffffffffc020122e:	1d6c8c93          	addi	s9,s9,470 # ffffffffc02ac400 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201232:	000abc17          	auipc	s8,0xab
ffffffffc0201236:	236c0c13          	addi	s8,s8,566 # ffffffffc02ac468 <pages>
ffffffffc020123a:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020123e:	00200b37          	lui	s6,0x200
ffffffffc0201242:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0201246:	4601                	li	a2,0
ffffffffc0201248:	85a2                	mv	a1,s0
ffffffffc020124a:	854e                	mv	a0,s3
ffffffffc020124c:	d6dff0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc0201250:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0201252:	cd21                	beqz	a0,ffffffffc02012aa <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc0201254:	611c                	ld	a5,0(a0)
ffffffffc0201256:	e38d                	bnez	a5,ffffffffc0201278 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0201258:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020125a:	ff2466e3          	bltu	s0,s2,ffffffffc0201246 <unmap_range+0x5a>
}
ffffffffc020125e:	60e6                	ld	ra,88(sp)
ffffffffc0201260:	6446                	ld	s0,80(sp)
ffffffffc0201262:	64a6                	ld	s1,72(sp)
ffffffffc0201264:	6906                	ld	s2,64(sp)
ffffffffc0201266:	79e2                	ld	s3,56(sp)
ffffffffc0201268:	7a42                	ld	s4,48(sp)
ffffffffc020126a:	7aa2                	ld	s5,40(sp)
ffffffffc020126c:	7b02                	ld	s6,32(sp)
ffffffffc020126e:	6be2                	ld	s7,24(sp)
ffffffffc0201270:	6c42                	ld	s8,16(sp)
ffffffffc0201272:	6ca2                	ld	s9,8(sp)
ffffffffc0201274:	6125                	addi	sp,sp,96
ffffffffc0201276:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201278:	0017f713          	andi	a4,a5,1
ffffffffc020127c:	df71                	beqz	a4,ffffffffc0201258 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc020127e:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201282:	078a                	slli	a5,a5,0x2
ffffffffc0201284:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201286:	06e7fd63          	bleu	a4,a5,ffffffffc0201300 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc020128a:	000c3503          	ld	a0,0(s8)
ffffffffc020128e:	97de                	add	a5,a5,s7
ffffffffc0201290:	079a                	slli	a5,a5,0x6
ffffffffc0201292:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201294:	411c                	lw	a5,0(a0)
ffffffffc0201296:	fff7871b          	addiw	a4,a5,-1
ffffffffc020129a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020129c:	cf11                	beqz	a4,ffffffffc02012b8 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020129e:	0004b023          	sd	zero,0(s1)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02012a2:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02012a6:	9452                	add	s0,s0,s4
ffffffffc02012a8:	bf4d                	j	ffffffffc020125a <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02012aa:	945a                	add	s0,s0,s6
ffffffffc02012ac:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02012b0:	d45d                	beqz	s0,ffffffffc020125e <unmap_range+0x72>
ffffffffc02012b2:	f9246ae3          	bltu	s0,s2,ffffffffc0201246 <unmap_range+0x5a>
ffffffffc02012b6:	b765                	j	ffffffffc020125e <unmap_range+0x72>
            free_page(page);
ffffffffc02012b8:	4585                	li	a1,1
ffffffffc02012ba:	c79ff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
ffffffffc02012be:	b7c5                	j	ffffffffc020129e <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc02012c0:	00006697          	auipc	a3,0x6
ffffffffc02012c4:	3f868693          	addi	a3,a3,1016 # ffffffffc02076b8 <commands+0xef0>
ffffffffc02012c8:	00006617          	auipc	a2,0x6
ffffffffc02012cc:	9e060613          	addi	a2,a2,-1568 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02012d0:	11000593          	li	a1,272
ffffffffc02012d4:	00006517          	auipc	a0,0x6
ffffffffc02012d8:	de450513          	addi	a0,a0,-540 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc02012dc:	f3bfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012e0:	00006697          	auipc	a3,0x6
ffffffffc02012e4:	3a868693          	addi	a3,a3,936 # ffffffffc0207688 <commands+0xec0>
ffffffffc02012e8:	00006617          	auipc	a2,0x6
ffffffffc02012ec:	9c060613          	addi	a2,a2,-1600 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02012f0:	10f00593          	li	a1,271
ffffffffc02012f4:	00006517          	auipc	a0,0x6
ffffffffc02012f8:	dc450513          	addi	a0,a0,-572 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc02012fc:	f1bfe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0201300:	b8fff0ef          	jal	ra,ffffffffc0200e8e <pa2page.part.4>

ffffffffc0201304 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201304:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201306:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020130a:	fc86                	sd	ra,120(sp)
ffffffffc020130c:	f8a2                	sd	s0,112(sp)
ffffffffc020130e:	f4a6                	sd	s1,104(sp)
ffffffffc0201310:	f0ca                	sd	s2,96(sp)
ffffffffc0201312:	ecce                	sd	s3,88(sp)
ffffffffc0201314:	e8d2                	sd	s4,80(sp)
ffffffffc0201316:	e4d6                	sd	s5,72(sp)
ffffffffc0201318:	e0da                	sd	s6,64(sp)
ffffffffc020131a:	fc5e                	sd	s7,56(sp)
ffffffffc020131c:	f862                	sd	s8,48(sp)
ffffffffc020131e:	f466                	sd	s9,40(sp)
ffffffffc0201320:	f06a                	sd	s10,32(sp)
ffffffffc0201322:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201324:	03479713          	slli	a4,a5,0x34
ffffffffc0201328:	1c071163          	bnez	a4,ffffffffc02014ea <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc020132c:	002007b7          	lui	a5,0x200
ffffffffc0201330:	20f5e563          	bltu	a1,a5,ffffffffc020153a <exit_range+0x236>
ffffffffc0201334:	8b32                	mv	s6,a2
ffffffffc0201336:	20c5f263          	bleu	a2,a1,ffffffffc020153a <exit_range+0x236>
ffffffffc020133a:	4785                	li	a5,1
ffffffffc020133c:	07fe                	slli	a5,a5,0x1f
ffffffffc020133e:	1ec7ee63          	bltu	a5,a2,ffffffffc020153a <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0201342:	c00009b7          	lui	s3,0xc0000
ffffffffc0201346:	400007b7          	lui	a5,0x40000
ffffffffc020134a:	0135f9b3          	and	s3,a1,s3
ffffffffc020134e:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0201350:	c0000337          	lui	t1,0xc0000
ffffffffc0201354:	00698933          	add	s2,s3,t1
ffffffffc0201358:	01e95913          	srli	s2,s2,0x1e
ffffffffc020135c:	1ff97913          	andi	s2,s2,511
ffffffffc0201360:	8e2a                	mv	t3,a0
ffffffffc0201362:	090e                	slli	s2,s2,0x3
ffffffffc0201364:	9972                	add	s2,s2,t3
ffffffffc0201366:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020136a:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc020136e:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0201370:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201374:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc0201376:	000abd17          	auipc	s10,0xab
ffffffffc020137a:	08ad0d13          	addi	s10,s10,138 # ffffffffc02ac400 <npage>
    return KADDR(page2pa(page));
ffffffffc020137e:	00cddd93          	srli	s11,s11,0xc
ffffffffc0201382:	000ab717          	auipc	a4,0xab
ffffffffc0201386:	0d670713          	addi	a4,a4,214 # ffffffffc02ac458 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc020138a:	000abe97          	auipc	t4,0xab
ffffffffc020138e:	0dee8e93          	addi	t4,t4,222 # ffffffffc02ac468 <pages>
        if (pde1&PTE_V){
ffffffffc0201392:	e79d                	bnez	a5,ffffffffc02013c0 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0201394:	12098963          	beqz	s3,ffffffffc02014c6 <exit_range+0x1c2>
ffffffffc0201398:	400007b7          	lui	a5,0x40000
ffffffffc020139c:	84ce                	mv	s1,s3
ffffffffc020139e:	97ce                	add	a5,a5,s3
ffffffffc02013a0:	1369f363          	bleu	s6,s3,ffffffffc02014c6 <exit_range+0x1c2>
ffffffffc02013a4:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02013a6:	00698933          	add	s2,s3,t1
ffffffffc02013aa:	01e95913          	srli	s2,s2,0x1e
ffffffffc02013ae:	1ff97913          	andi	s2,s2,511
ffffffffc02013b2:	090e                	slli	s2,s2,0x3
ffffffffc02013b4:	9972                	add	s2,s2,t3
ffffffffc02013b6:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc02013ba:	001bf793          	andi	a5,s7,1
ffffffffc02013be:	dbf9                	beqz	a5,ffffffffc0201394 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc02013c0:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013c4:	0b8a                	slli	s7,s7,0x2
ffffffffc02013c6:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013ca:	14fbfc63          	bleu	a5,s7,ffffffffc0201522 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013ce:	fff80ab7          	lui	s5,0xfff80
ffffffffc02013d2:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc02013d4:	000806b7          	lui	a3,0x80
ffffffffc02013d8:	96d6                	add	a3,a3,s5
ffffffffc02013da:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc02013de:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc02013e2:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc02013e4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013e6:	12f67263          	bleu	a5,a2,ffffffffc020150a <exit_range+0x206>
ffffffffc02013ea:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc02013ee:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc02013f0:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc02013f4:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc02013f6:	00080837          	lui	a6,0x80
ffffffffc02013fa:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02013fc:	00200c37          	lui	s8,0x200
ffffffffc0201400:	a801                	j	ffffffffc0201410 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc0201402:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0201404:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201406:	c0d9                	beqz	s1,ffffffffc020148c <exit_range+0x188>
ffffffffc0201408:	0934f263          	bleu	s3,s1,ffffffffc020148c <exit_range+0x188>
ffffffffc020140c:	0d64fc63          	bleu	s6,s1,ffffffffc02014e4 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0201410:	0154d413          	srli	s0,s1,0x15
ffffffffc0201414:	1ff47413          	andi	s0,s0,511
ffffffffc0201418:	040e                	slli	s0,s0,0x3
ffffffffc020141a:	9452                	add	s0,s0,s4
ffffffffc020141c:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc020141e:	0017f693          	andi	a3,a5,1
ffffffffc0201422:	d2e5                	beqz	a3,ffffffffc0201402 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc0201424:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201428:	00279513          	slli	a0,a5,0x2
ffffffffc020142c:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020142e:	0eb57a63          	bleu	a1,a0,ffffffffc0201522 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201432:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc0201434:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc0201438:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc020143c:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020143e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201440:	0cb7f563          	bleu	a1,a5,ffffffffc020150a <exit_range+0x206>
ffffffffc0201444:	631c                	ld	a5,0(a4)
ffffffffc0201446:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0201448:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc020144c:	629c                	ld	a5,0(a3)
ffffffffc020144e:	8b85                	andi	a5,a5,1
ffffffffc0201450:	fbd5                	bnez	a5,ffffffffc0201404 <exit_range+0x100>
ffffffffc0201452:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0201454:	fed59ce3          	bne	a1,a3,ffffffffc020144c <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0201458:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc020145c:	4585                	li	a1,1
ffffffffc020145e:	e072                	sd	t3,0(sp)
ffffffffc0201460:	953e                	add	a0,a0,a5
ffffffffc0201462:	ad1ff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
                d0start += PTSIZE;
ffffffffc0201466:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201468:	00043023          	sd	zero,0(s0)
ffffffffc020146c:	000abe97          	auipc	t4,0xab
ffffffffc0201470:	ffce8e93          	addi	t4,t4,-4 # ffffffffc02ac468 <pages>
ffffffffc0201474:	6e02                	ld	t3,0(sp)
ffffffffc0201476:	c0000337          	lui	t1,0xc0000
ffffffffc020147a:	fff808b7          	lui	a7,0xfff80
ffffffffc020147e:	00080837          	lui	a6,0x80
ffffffffc0201482:	000ab717          	auipc	a4,0xab
ffffffffc0201486:	fd670713          	addi	a4,a4,-42 # ffffffffc02ac458 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020148a:	fcbd                	bnez	s1,ffffffffc0201408 <exit_range+0x104>
            if (free_pd0) {
ffffffffc020148c:	f00c84e3          	beqz	s9,ffffffffc0201394 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201490:	000d3783          	ld	a5,0(s10)
ffffffffc0201494:	e072                	sd	t3,0(sp)
ffffffffc0201496:	08fbf663          	bleu	a5,s7,ffffffffc0201522 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020149a:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc020149e:	67a2                	ld	a5,8(sp)
ffffffffc02014a0:	4585                	li	a1,1
ffffffffc02014a2:	953e                	add	a0,a0,a5
ffffffffc02014a4:	a8fff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02014a8:	00093023          	sd	zero,0(s2)
ffffffffc02014ac:	000ab717          	auipc	a4,0xab
ffffffffc02014b0:	fac70713          	addi	a4,a4,-84 # ffffffffc02ac458 <va_pa_offset>
ffffffffc02014b4:	c0000337          	lui	t1,0xc0000
ffffffffc02014b8:	6e02                	ld	t3,0(sp)
ffffffffc02014ba:	000abe97          	auipc	t4,0xab
ffffffffc02014be:	faee8e93          	addi	t4,t4,-82 # ffffffffc02ac468 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc02014c2:	ec099be3          	bnez	s3,ffffffffc0201398 <exit_range+0x94>
}
ffffffffc02014c6:	70e6                	ld	ra,120(sp)
ffffffffc02014c8:	7446                	ld	s0,112(sp)
ffffffffc02014ca:	74a6                	ld	s1,104(sp)
ffffffffc02014cc:	7906                	ld	s2,96(sp)
ffffffffc02014ce:	69e6                	ld	s3,88(sp)
ffffffffc02014d0:	6a46                	ld	s4,80(sp)
ffffffffc02014d2:	6aa6                	ld	s5,72(sp)
ffffffffc02014d4:	6b06                	ld	s6,64(sp)
ffffffffc02014d6:	7be2                	ld	s7,56(sp)
ffffffffc02014d8:	7c42                	ld	s8,48(sp)
ffffffffc02014da:	7ca2                	ld	s9,40(sp)
ffffffffc02014dc:	7d02                	ld	s10,32(sp)
ffffffffc02014de:	6de2                	ld	s11,24(sp)
ffffffffc02014e0:	6109                	addi	sp,sp,128
ffffffffc02014e2:	8082                	ret
            if (free_pd0) {
ffffffffc02014e4:	ea0c8ae3          	beqz	s9,ffffffffc0201398 <exit_range+0x94>
ffffffffc02014e8:	b765                	j	ffffffffc0201490 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02014ea:	00006697          	auipc	a3,0x6
ffffffffc02014ee:	19e68693          	addi	a3,a3,414 # ffffffffc0207688 <commands+0xec0>
ffffffffc02014f2:	00005617          	auipc	a2,0x5
ffffffffc02014f6:	7b660613          	addi	a2,a2,1974 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02014fa:	12000593          	li	a1,288
ffffffffc02014fe:	00006517          	auipc	a0,0x6
ffffffffc0201502:	bba50513          	addi	a0,a0,-1094 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201506:	d11fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc020150a:	00006617          	auipc	a2,0x6
ffffffffc020150e:	b8660613          	addi	a2,a2,-1146 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0201512:	06900593          	li	a1,105
ffffffffc0201516:	00006517          	auipc	a0,0x6
ffffffffc020151a:	bd250513          	addi	a0,a0,-1070 # ffffffffc02070e8 <commands+0x920>
ffffffffc020151e:	cf9fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201522:	00006617          	auipc	a2,0x6
ffffffffc0201526:	ba660613          	addi	a2,a2,-1114 # ffffffffc02070c8 <commands+0x900>
ffffffffc020152a:	06200593          	li	a1,98
ffffffffc020152e:	00006517          	auipc	a0,0x6
ffffffffc0201532:	bba50513          	addi	a0,a0,-1094 # ffffffffc02070e8 <commands+0x920>
ffffffffc0201536:	ce1fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020153a:	00006697          	auipc	a3,0x6
ffffffffc020153e:	17e68693          	addi	a3,a3,382 # ffffffffc02076b8 <commands+0xef0>
ffffffffc0201542:	00005617          	auipc	a2,0x5
ffffffffc0201546:	76660613          	addi	a2,a2,1894 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020154a:	12100593          	li	a1,289
ffffffffc020154e:	00006517          	auipc	a0,0x6
ffffffffc0201552:	b6a50513          	addi	a0,a0,-1174 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201556:	cc1fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020155a <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020155a:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020155c:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020155e:	e426                	sd	s1,8(sp)
ffffffffc0201560:	ec06                	sd	ra,24(sp)
ffffffffc0201562:	e822                	sd	s0,16(sp)
ffffffffc0201564:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201566:	a53ff0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
    if (ptep != NULL) {
ffffffffc020156a:	c511                	beqz	a0,ffffffffc0201576 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020156c:	611c                	ld	a5,0(a0)
ffffffffc020156e:	842a                	mv	s0,a0
ffffffffc0201570:	0017f713          	andi	a4,a5,1
ffffffffc0201574:	e711                	bnez	a4,ffffffffc0201580 <page_remove+0x26>
}
ffffffffc0201576:	60e2                	ld	ra,24(sp)
ffffffffc0201578:	6442                	ld	s0,16(sp)
ffffffffc020157a:	64a2                	ld	s1,8(sp)
ffffffffc020157c:	6105                	addi	sp,sp,32
ffffffffc020157e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201580:	000ab717          	auipc	a4,0xab
ffffffffc0201584:	e8070713          	addi	a4,a4,-384 # ffffffffc02ac400 <npage>
ffffffffc0201588:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020158a:	078a                	slli	a5,a5,0x2
ffffffffc020158c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020158e:	02e7fe63          	bleu	a4,a5,ffffffffc02015ca <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201592:	000ab717          	auipc	a4,0xab
ffffffffc0201596:	ed670713          	addi	a4,a4,-298 # ffffffffc02ac468 <pages>
ffffffffc020159a:	6308                	ld	a0,0(a4)
ffffffffc020159c:	fff80737          	lui	a4,0xfff80
ffffffffc02015a0:	97ba                	add	a5,a5,a4
ffffffffc02015a2:	079a                	slli	a5,a5,0x6
ffffffffc02015a4:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02015a6:	411c                	lw	a5,0(a0)
ffffffffc02015a8:	fff7871b          	addiw	a4,a5,-1
ffffffffc02015ac:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02015ae:	cb11                	beqz	a4,ffffffffc02015c2 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02015b0:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02015b4:	12048073          	sfence.vma	s1
}
ffffffffc02015b8:	60e2                	ld	ra,24(sp)
ffffffffc02015ba:	6442                	ld	s0,16(sp)
ffffffffc02015bc:	64a2                	ld	s1,8(sp)
ffffffffc02015be:	6105                	addi	sp,sp,32
ffffffffc02015c0:	8082                	ret
            free_page(page);
ffffffffc02015c2:	4585                	li	a1,1
ffffffffc02015c4:	96fff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
ffffffffc02015c8:	b7e5                	j	ffffffffc02015b0 <page_remove+0x56>
ffffffffc02015ca:	8c5ff0ef          	jal	ra,ffffffffc0200e8e <pa2page.part.4>

ffffffffc02015ce <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02015ce:	7179                	addi	sp,sp,-48
ffffffffc02015d0:	e44e                	sd	s3,8(sp)
ffffffffc02015d2:	89b2                	mv	s3,a2
ffffffffc02015d4:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015d6:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02015d8:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015da:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02015dc:	ec26                	sd	s1,24(sp)
ffffffffc02015de:	f406                	sd	ra,40(sp)
ffffffffc02015e0:	e84a                	sd	s2,16(sp)
ffffffffc02015e2:	e052                	sd	s4,0(sp)
ffffffffc02015e4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015e6:	9d3ff0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
    if (ptep == NULL) {
ffffffffc02015ea:	cd49                	beqz	a0,ffffffffc0201684 <page_insert+0xb6>
    page->ref += 1;
ffffffffc02015ec:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02015ee:	611c                	ld	a5,0(a0)
ffffffffc02015f0:	892a                	mv	s2,a0
ffffffffc02015f2:	0016871b          	addiw	a4,a3,1
ffffffffc02015f6:	c018                	sw	a4,0(s0)
ffffffffc02015f8:	0017f713          	andi	a4,a5,1
ffffffffc02015fc:	ef05                	bnez	a4,ffffffffc0201634 <page_insert+0x66>
ffffffffc02015fe:	000ab797          	auipc	a5,0xab
ffffffffc0201602:	e6a78793          	addi	a5,a5,-406 # ffffffffc02ac468 <pages>
ffffffffc0201606:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0201608:	8c19                	sub	s0,s0,a4
ffffffffc020160a:	000806b7          	lui	a3,0x80
ffffffffc020160e:	8419                	srai	s0,s0,0x6
ffffffffc0201610:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201612:	042a                	slli	s0,s0,0xa
ffffffffc0201614:	8c45                	or	s0,s0,s1
ffffffffc0201616:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020161a:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020161e:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0201622:	4501                	li	a0,0
}
ffffffffc0201624:	70a2                	ld	ra,40(sp)
ffffffffc0201626:	7402                	ld	s0,32(sp)
ffffffffc0201628:	64e2                	ld	s1,24(sp)
ffffffffc020162a:	6942                	ld	s2,16(sp)
ffffffffc020162c:	69a2                	ld	s3,8(sp)
ffffffffc020162e:	6a02                	ld	s4,0(sp)
ffffffffc0201630:	6145                	addi	sp,sp,48
ffffffffc0201632:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201634:	000ab717          	auipc	a4,0xab
ffffffffc0201638:	dcc70713          	addi	a4,a4,-564 # ffffffffc02ac400 <npage>
ffffffffc020163c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020163e:	078a                	slli	a5,a5,0x2
ffffffffc0201640:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201642:	04e7f363          	bleu	a4,a5,ffffffffc0201688 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201646:	000aba17          	auipc	s4,0xab
ffffffffc020164a:	e22a0a13          	addi	s4,s4,-478 # ffffffffc02ac468 <pages>
ffffffffc020164e:	000a3703          	ld	a4,0(s4)
ffffffffc0201652:	fff80537          	lui	a0,0xfff80
ffffffffc0201656:	953e                	add	a0,a0,a5
ffffffffc0201658:	051a                	slli	a0,a0,0x6
ffffffffc020165a:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc020165c:	00a40a63          	beq	s0,a0,ffffffffc0201670 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201660:	411c                	lw	a5,0(a0)
ffffffffc0201662:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201666:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0201668:	c691                	beqz	a3,ffffffffc0201674 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020166a:	12098073          	sfence.vma	s3
ffffffffc020166e:	bf69                	j	ffffffffc0201608 <page_insert+0x3a>
ffffffffc0201670:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201672:	bf59                	j	ffffffffc0201608 <page_insert+0x3a>
            free_page(page);
ffffffffc0201674:	4585                	li	a1,1
ffffffffc0201676:	8bdff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
ffffffffc020167a:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020167e:	12098073          	sfence.vma	s3
ffffffffc0201682:	b759                	j	ffffffffc0201608 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201684:	5571                	li	a0,-4
ffffffffc0201686:	bf79                	j	ffffffffc0201624 <page_insert+0x56>
ffffffffc0201688:	807ff0ef          	jal	ra,ffffffffc0200e8e <pa2page.part.4>

ffffffffc020168c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020168c:	00007797          	auipc	a5,0x7
ffffffffc0201690:	d3c78793          	addi	a5,a5,-708 # ffffffffc02083c8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201694:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201696:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201698:	00006517          	auipc	a0,0x6
ffffffffc020169c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0207110 <commands+0x948>
void pmm_init(void) {
ffffffffc02016a0:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02016a2:	000ab717          	auipc	a4,0xab
ffffffffc02016a6:	daf73723          	sd	a5,-594(a4) # ffffffffc02ac450 <pmm_manager>
void pmm_init(void) {
ffffffffc02016aa:	e0a2                	sd	s0,64(sp)
ffffffffc02016ac:	fc26                	sd	s1,56(sp)
ffffffffc02016ae:	f84a                	sd	s2,48(sp)
ffffffffc02016b0:	f44e                	sd	s3,40(sp)
ffffffffc02016b2:	f052                	sd	s4,32(sp)
ffffffffc02016b4:	ec56                	sd	s5,24(sp)
ffffffffc02016b6:	e85a                	sd	s6,16(sp)
ffffffffc02016b8:	e45e                	sd	s7,8(sp)
ffffffffc02016ba:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02016bc:	000ab417          	auipc	s0,0xab
ffffffffc02016c0:	d9440413          	addi	s0,s0,-620 # ffffffffc02ac450 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02016c4:	a0dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc02016c8:	601c                	ld	a5,0(s0)
ffffffffc02016ca:	000ab497          	auipc	s1,0xab
ffffffffc02016ce:	d3648493          	addi	s1,s1,-714 # ffffffffc02ac400 <npage>
ffffffffc02016d2:	000ab917          	auipc	s2,0xab
ffffffffc02016d6:	d9690913          	addi	s2,s2,-618 # ffffffffc02ac468 <pages>
ffffffffc02016da:	679c                	ld	a5,8(a5)
ffffffffc02016dc:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02016de:	57f5                	li	a5,-3
ffffffffc02016e0:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02016e2:	00006517          	auipc	a0,0x6
ffffffffc02016e6:	a4650513          	addi	a0,a0,-1466 # ffffffffc0207128 <commands+0x960>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02016ea:	000ab717          	auipc	a4,0xab
ffffffffc02016ee:	d6f73723          	sd	a5,-658(a4) # ffffffffc02ac458 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02016f2:	9dffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02016f6:	46c5                	li	a3,17
ffffffffc02016f8:	06ee                	slli	a3,a3,0x1b
ffffffffc02016fa:	40100613          	li	a2,1025
ffffffffc02016fe:	16fd                	addi	a3,a3,-1
ffffffffc0201700:	0656                	slli	a2,a2,0x15
ffffffffc0201702:	07e005b7          	lui	a1,0x7e00
ffffffffc0201706:	00006517          	auipc	a0,0x6
ffffffffc020170a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0207140 <commands+0x978>
ffffffffc020170e:	9c3fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201712:	777d                	lui	a4,0xfffff
ffffffffc0201714:	000ac797          	auipc	a5,0xac
ffffffffc0201718:	e6378793          	addi	a5,a5,-413 # ffffffffc02ad577 <end+0xfff>
ffffffffc020171c:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020171e:	00088737          	lui	a4,0x88
ffffffffc0201722:	000ab697          	auipc	a3,0xab
ffffffffc0201726:	cce6bf23          	sd	a4,-802(a3) # ffffffffc02ac400 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020172a:	000ab717          	auipc	a4,0xab
ffffffffc020172e:	d2f73f23          	sd	a5,-706(a4) # ffffffffc02ac468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201732:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201734:	4685                	li	a3,1
ffffffffc0201736:	fff80837          	lui	a6,0xfff80
ffffffffc020173a:	a019                	j	ffffffffc0201740 <pmm_init+0xb4>
ffffffffc020173c:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201740:	00671613          	slli	a2,a4,0x6
ffffffffc0201744:	97b2                	add	a5,a5,a2
ffffffffc0201746:	07a1                	addi	a5,a5,8
ffffffffc0201748:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020174c:	6090                	ld	a2,0(s1)
ffffffffc020174e:	0705                	addi	a4,a4,1
ffffffffc0201750:	010607b3          	add	a5,a2,a6
ffffffffc0201754:	fef764e3          	bltu	a4,a5,ffffffffc020173c <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201758:	00093503          	ld	a0,0(s2)
ffffffffc020175c:	fe0007b7          	lui	a5,0xfe000
ffffffffc0201760:	00661693          	slli	a3,a2,0x6
ffffffffc0201764:	97aa                	add	a5,a5,a0
ffffffffc0201766:	96be                	add	a3,a3,a5
ffffffffc0201768:	c02007b7          	lui	a5,0xc0200
ffffffffc020176c:	7af6ed63          	bltu	a3,a5,ffffffffc0201f26 <pmm_init+0x89a>
ffffffffc0201770:	000ab997          	auipc	s3,0xab
ffffffffc0201774:	ce898993          	addi	s3,s3,-792 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0201778:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020177c:	47c5                	li	a5,17
ffffffffc020177e:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201780:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0201782:	02f6f763          	bleu	a5,a3,ffffffffc02017b0 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201786:	6585                	lui	a1,0x1
ffffffffc0201788:	15fd                	addi	a1,a1,-1
ffffffffc020178a:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc020178c:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201790:	48c77a63          	bleu	a2,a4,ffffffffc0201c24 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0201794:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201796:	75fd                	lui	a1,0xfffff
ffffffffc0201798:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020179a:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc020179c:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020179e:	40d786b3          	sub	a3,a5,a3
ffffffffc02017a2:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02017a4:	00c6d593          	srli	a1,a3,0xc
ffffffffc02017a8:	953a                	add	a0,a0,a4
ffffffffc02017aa:	9602                	jalr	a2
ffffffffc02017ac:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02017b0:	00006517          	auipc	a0,0x6
ffffffffc02017b4:	9e050513          	addi	a0,a0,-1568 # ffffffffc0207190 <commands+0x9c8>
ffffffffc02017b8:	919fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02017bc:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02017be:	000ab417          	auipc	s0,0xab
ffffffffc02017c2:	c3a40413          	addi	s0,s0,-966 # ffffffffc02ac3f8 <boot_pgdir>
    pmm_manager->check();
ffffffffc02017c6:	7b9c                	ld	a5,48(a5)
ffffffffc02017c8:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02017ca:	00006517          	auipc	a0,0x6
ffffffffc02017ce:	9de50513          	addi	a0,a0,-1570 # ffffffffc02071a8 <commands+0x9e0>
ffffffffc02017d2:	8fffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02017d6:	0000a697          	auipc	a3,0xa
ffffffffc02017da:	82a68693          	addi	a3,a3,-2006 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02017de:	000ab797          	auipc	a5,0xab
ffffffffc02017e2:	c0d7bd23          	sd	a3,-998(a5) # ffffffffc02ac3f8 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02017e6:	c02007b7          	lui	a5,0xc0200
ffffffffc02017ea:	10f6eae3          	bltu	a3,a5,ffffffffc02020fe <pmm_init+0xa72>
ffffffffc02017ee:	0009b783          	ld	a5,0(s3)
ffffffffc02017f2:	8e9d                	sub	a3,a3,a5
ffffffffc02017f4:	000ab797          	auipc	a5,0xab
ffffffffc02017f8:	c6d7b623          	sd	a3,-916(a5) # ffffffffc02ac460 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02017fc:	f7cff0ef          	jal	ra,ffffffffc0200f78 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201800:	6098                	ld	a4,0(s1)
ffffffffc0201802:	c80007b7          	lui	a5,0xc8000
ffffffffc0201806:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201808:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020180a:	0ce7eae3          	bltu	a5,a4,ffffffffc02020de <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020180e:	6008                	ld	a0,0(s0)
ffffffffc0201810:	44050463          	beqz	a0,ffffffffc0201c58 <pmm_init+0x5cc>
ffffffffc0201814:	6785                	lui	a5,0x1
ffffffffc0201816:	17fd                	addi	a5,a5,-1
ffffffffc0201818:	8fe9                	and	a5,a5,a0
ffffffffc020181a:	2781                	sext.w	a5,a5
ffffffffc020181c:	42079e63          	bnez	a5,ffffffffc0201c58 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201820:	4601                	li	a2,0
ffffffffc0201822:	4581                	li	a1,0
ffffffffc0201824:	967ff0ef          	jal	ra,ffffffffc020118a <get_page>
ffffffffc0201828:	78051b63          	bnez	a0,ffffffffc0201fbe <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020182c:	4505                	li	a0,1
ffffffffc020182e:	e7cff0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0201832:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201834:	6008                	ld	a0,0(s0)
ffffffffc0201836:	4681                	li	a3,0
ffffffffc0201838:	4601                	li	a2,0
ffffffffc020183a:	85d6                	mv	a1,s5
ffffffffc020183c:	d93ff0ef          	jal	ra,ffffffffc02015ce <page_insert>
ffffffffc0201840:	7a051f63          	bnez	a0,ffffffffc0201ffe <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201844:	6008                	ld	a0,0(s0)
ffffffffc0201846:	4601                	li	a2,0
ffffffffc0201848:	4581                	li	a1,0
ffffffffc020184a:	f6eff0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc020184e:	78050863          	beqz	a0,ffffffffc0201fde <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc0201852:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201854:	0017f713          	andi	a4,a5,1
ffffffffc0201858:	3e070463          	beqz	a4,ffffffffc0201c40 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc020185c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020185e:	078a                	slli	a5,a5,0x2
ffffffffc0201860:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201862:	3ce7f163          	bleu	a4,a5,ffffffffc0201c24 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201866:	00093683          	ld	a3,0(s2)
ffffffffc020186a:	fff80637          	lui	a2,0xfff80
ffffffffc020186e:	97b2                	add	a5,a5,a2
ffffffffc0201870:	079a                	slli	a5,a5,0x6
ffffffffc0201872:	97b6                	add	a5,a5,a3
ffffffffc0201874:	72fa9563          	bne	s5,a5,ffffffffc0201f9e <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0201878:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc020187c:	4785                	li	a5,1
ffffffffc020187e:	70fb9063          	bne	s7,a5,ffffffffc0201f7e <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201882:	6008                	ld	a0,0(s0)
ffffffffc0201884:	76fd                	lui	a3,0xfffff
ffffffffc0201886:	611c                	ld	a5,0(a0)
ffffffffc0201888:	078a                	slli	a5,a5,0x2
ffffffffc020188a:	8ff5                	and	a5,a5,a3
ffffffffc020188c:	00c7d613          	srli	a2,a5,0xc
ffffffffc0201890:	66e67e63          	bleu	a4,a2,ffffffffc0201f0c <pmm_init+0x880>
ffffffffc0201894:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201898:	97e2                	add	a5,a5,s8
ffffffffc020189a:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc020189e:	0b0a                	slli	s6,s6,0x2
ffffffffc02018a0:	00db7b33          	and	s6,s6,a3
ffffffffc02018a4:	00cb5793          	srli	a5,s6,0xc
ffffffffc02018a8:	56e7f863          	bleu	a4,a5,ffffffffc0201e18 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018ac:	4601                	li	a2,0
ffffffffc02018ae:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018b0:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018b2:	f06ff0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018b6:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018b8:	55651063          	bne	a0,s6,ffffffffc0201df8 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc02018bc:	4505                	li	a0,1
ffffffffc02018be:	decff0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02018c2:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02018c4:	6008                	ld	a0,0(s0)
ffffffffc02018c6:	46d1                	li	a3,20
ffffffffc02018c8:	6605                	lui	a2,0x1
ffffffffc02018ca:	85da                	mv	a1,s6
ffffffffc02018cc:	d03ff0ef          	jal	ra,ffffffffc02015ce <page_insert>
ffffffffc02018d0:	50051463          	bnez	a0,ffffffffc0201dd8 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02018d4:	6008                	ld	a0,0(s0)
ffffffffc02018d6:	4601                	li	a2,0
ffffffffc02018d8:	6585                	lui	a1,0x1
ffffffffc02018da:	edeff0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc02018de:	4c050d63          	beqz	a0,ffffffffc0201db8 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc02018e2:	611c                	ld	a5,0(a0)
ffffffffc02018e4:	0107f713          	andi	a4,a5,16
ffffffffc02018e8:	4a070863          	beqz	a4,ffffffffc0201d98 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc02018ec:	8b91                	andi	a5,a5,4
ffffffffc02018ee:	48078563          	beqz	a5,ffffffffc0201d78 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02018f2:	6008                	ld	a0,0(s0)
ffffffffc02018f4:	611c                	ld	a5,0(a0)
ffffffffc02018f6:	8bc1                	andi	a5,a5,16
ffffffffc02018f8:	46078063          	beqz	a5,ffffffffc0201d58 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02018fc:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5588>
ffffffffc0201900:	43779c63          	bne	a5,s7,ffffffffc0201d38 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201904:	4681                	li	a3,0
ffffffffc0201906:	6605                	lui	a2,0x1
ffffffffc0201908:	85d6                	mv	a1,s5
ffffffffc020190a:	cc5ff0ef          	jal	ra,ffffffffc02015ce <page_insert>
ffffffffc020190e:	40051563          	bnez	a0,ffffffffc0201d18 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc0201912:	000aa703          	lw	a4,0(s5)
ffffffffc0201916:	4789                	li	a5,2
ffffffffc0201918:	3ef71063          	bne	a4,a5,ffffffffc0201cf8 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc020191c:	000b2783          	lw	a5,0(s6)
ffffffffc0201920:	3a079c63          	bnez	a5,ffffffffc0201cd8 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201924:	6008                	ld	a0,0(s0)
ffffffffc0201926:	4601                	li	a2,0
ffffffffc0201928:	6585                	lui	a1,0x1
ffffffffc020192a:	e8eff0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc020192e:	38050563          	beqz	a0,ffffffffc0201cb8 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc0201932:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201934:	00177793          	andi	a5,a4,1
ffffffffc0201938:	30078463          	beqz	a5,ffffffffc0201c40 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc020193c:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020193e:	00271793          	slli	a5,a4,0x2
ffffffffc0201942:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201944:	2ed7f063          	bleu	a3,a5,ffffffffc0201c24 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201948:	00093683          	ld	a3,0(s2)
ffffffffc020194c:	fff80637          	lui	a2,0xfff80
ffffffffc0201950:	97b2                	add	a5,a5,a2
ffffffffc0201952:	079a                	slli	a5,a5,0x6
ffffffffc0201954:	97b6                	add	a5,a5,a3
ffffffffc0201956:	32fa9163          	bne	s5,a5,ffffffffc0201c78 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc020195a:	8b41                	andi	a4,a4,16
ffffffffc020195c:	70071163          	bnez	a4,ffffffffc020205e <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201960:	6008                	ld	a0,0(s0)
ffffffffc0201962:	4581                	li	a1,0
ffffffffc0201964:	bf7ff0ef          	jal	ra,ffffffffc020155a <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201968:	000aa703          	lw	a4,0(s5)
ffffffffc020196c:	4785                	li	a5,1
ffffffffc020196e:	6cf71863          	bne	a4,a5,ffffffffc020203e <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc0201972:	000b2783          	lw	a5,0(s6)
ffffffffc0201976:	6a079463          	bnez	a5,ffffffffc020201e <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020197a:	6008                	ld	a0,0(s0)
ffffffffc020197c:	6585                	lui	a1,0x1
ffffffffc020197e:	bddff0ef          	jal	ra,ffffffffc020155a <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201982:	000aa783          	lw	a5,0(s5)
ffffffffc0201986:	50079363          	bnez	a5,ffffffffc0201e8c <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc020198a:	000b2783          	lw	a5,0(s6)
ffffffffc020198e:	4c079f63          	bnez	a5,ffffffffc0201e6c <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201992:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201996:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201998:	000ab783          	ld	a5,0(s5)
ffffffffc020199c:	078a                	slli	a5,a5,0x2
ffffffffc020199e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019a0:	28c7f263          	bleu	a2,a5,ffffffffc0201c24 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02019a4:	fff80737          	lui	a4,0xfff80
ffffffffc02019a8:	00093503          	ld	a0,0(s2)
ffffffffc02019ac:	97ba                	add	a5,a5,a4
ffffffffc02019ae:	079a                	slli	a5,a5,0x6
ffffffffc02019b0:	00f50733          	add	a4,a0,a5
ffffffffc02019b4:	4314                	lw	a3,0(a4)
ffffffffc02019b6:	4705                	li	a4,1
ffffffffc02019b8:	48e69a63          	bne	a3,a4,ffffffffc0201e4c <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc02019bc:	8799                	srai	a5,a5,0x6
ffffffffc02019be:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc02019c2:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc02019c4:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02019c6:	8331                	srli	a4,a4,0xc
ffffffffc02019c8:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02019ca:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02019cc:	46c77363          	bleu	a2,a4,ffffffffc0201e32 <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02019d0:	0009b683          	ld	a3,0(s3)
ffffffffc02019d4:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc02019d6:	639c                	ld	a5,0(a5)
ffffffffc02019d8:	078a                	slli	a5,a5,0x2
ffffffffc02019da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019dc:	24c7f463          	bleu	a2,a5,ffffffffc0201c24 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02019e0:	416787b3          	sub	a5,a5,s6
ffffffffc02019e4:	079a                	slli	a5,a5,0x6
ffffffffc02019e6:	953e                	add	a0,a0,a5
ffffffffc02019e8:	4585                	li	a1,1
ffffffffc02019ea:	d48ff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02019ee:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc02019f2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02019f4:	078a                	slli	a5,a5,0x2
ffffffffc02019f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019f8:	22e7f663          	bleu	a4,a5,ffffffffc0201c24 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02019fc:	00093503          	ld	a0,0(s2)
ffffffffc0201a00:	416787b3          	sub	a5,a5,s6
ffffffffc0201a04:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201a06:	953e                	add	a0,a0,a5
ffffffffc0201a08:	4585                	li	a1,1
ffffffffc0201a0a:	d28ff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201a0e:	601c                	ld	a5,0(s0)
ffffffffc0201a10:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201a14:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201a18:	d60ff0ef          	jal	ra,ffffffffc0200f78 <nr_free_pages>
ffffffffc0201a1c:	68aa1163          	bne	s4,a0,ffffffffc020209e <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201a20:	00006517          	auipc	a0,0x6
ffffffffc0201a24:	a9850513          	addi	a0,a0,-1384 # ffffffffc02074b8 <commands+0xcf0>
ffffffffc0201a28:	ea8fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201a2c:	d4cff0ef          	jal	ra,ffffffffc0200f78 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a30:	6098                	ld	a4,0(s1)
ffffffffc0201a32:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201a36:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a38:	00c71693          	slli	a3,a4,0xc
ffffffffc0201a3c:	18d7f563          	bleu	a3,a5,ffffffffc0201bc6 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a40:	83b1                	srli	a5,a5,0xc
ffffffffc0201a42:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a44:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a48:	1ae7f163          	bleu	a4,a5,ffffffffc0201bea <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a4c:	7bfd                	lui	s7,0xfffff
ffffffffc0201a4e:	6b05                	lui	s6,0x1
ffffffffc0201a50:	a029                	j	ffffffffc0201a5a <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a52:	00cad713          	srli	a4,s5,0xc
ffffffffc0201a56:	18f77a63          	bleu	a5,a4,ffffffffc0201bea <pmm_init+0x55e>
ffffffffc0201a5a:	0009b583          	ld	a1,0(s3)
ffffffffc0201a5e:	4601                	li	a2,0
ffffffffc0201a60:	95d6                	add	a1,a1,s5
ffffffffc0201a62:	d56ff0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc0201a66:	16050263          	beqz	a0,ffffffffc0201bca <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a6a:	611c                	ld	a5,0(a0)
ffffffffc0201a6c:	078a                	slli	a5,a5,0x2
ffffffffc0201a6e:	0177f7b3          	and	a5,a5,s7
ffffffffc0201a72:	19579963          	bne	a5,s5,ffffffffc0201c04 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a76:	609c                	ld	a5,0(s1)
ffffffffc0201a78:	9ada                	add	s5,s5,s6
ffffffffc0201a7a:	6008                	ld	a0,0(s0)
ffffffffc0201a7c:	00c79713          	slli	a4,a5,0xc
ffffffffc0201a80:	fceae9e3          	bltu	s5,a4,ffffffffc0201a52 <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201a84:	611c                	ld	a5,0(a0)
ffffffffc0201a86:	62079c63          	bnez	a5,ffffffffc02020be <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0201a8a:	4505                	li	a0,1
ffffffffc0201a8c:	c1eff0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0201a90:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a92:	6008                	ld	a0,0(s0)
ffffffffc0201a94:	4699                	li	a3,6
ffffffffc0201a96:	10000613          	li	a2,256
ffffffffc0201a9a:	85d6                	mv	a1,s5
ffffffffc0201a9c:	b33ff0ef          	jal	ra,ffffffffc02015ce <page_insert>
ffffffffc0201aa0:	1e051c63          	bnez	a0,ffffffffc0201c98 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0201aa4:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201aa8:	4785                	li	a5,1
ffffffffc0201aaa:	44f71163          	bne	a4,a5,ffffffffc0201eec <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201aae:	6008                	ld	a0,0(s0)
ffffffffc0201ab0:	6b05                	lui	s6,0x1
ffffffffc0201ab2:	4699                	li	a3,6
ffffffffc0201ab4:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8470>
ffffffffc0201ab8:	85d6                	mv	a1,s5
ffffffffc0201aba:	b15ff0ef          	jal	ra,ffffffffc02015ce <page_insert>
ffffffffc0201abe:	40051763          	bnez	a0,ffffffffc0201ecc <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0201ac2:	000aa703          	lw	a4,0(s5)
ffffffffc0201ac6:	4789                	li	a5,2
ffffffffc0201ac8:	3ef71263          	bne	a4,a5,ffffffffc0201eac <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201acc:	00006597          	auipc	a1,0x6
ffffffffc0201ad0:	b2458593          	addi	a1,a1,-1244 # ffffffffc02075f0 <commands+0xe28>
ffffffffc0201ad4:	10000513          	li	a0,256
ffffffffc0201ad8:	6ec040ef          	jal	ra,ffffffffc02061c4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201adc:	100b0593          	addi	a1,s6,256
ffffffffc0201ae0:	10000513          	li	a0,256
ffffffffc0201ae4:	6f2040ef          	jal	ra,ffffffffc02061d6 <strcmp>
ffffffffc0201ae8:	44051b63          	bnez	a0,ffffffffc0201f3e <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0201aec:	00093683          	ld	a3,0(s2)
ffffffffc0201af0:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201af4:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201af6:	40da86b3          	sub	a3,s5,a3
ffffffffc0201afa:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201afc:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201afe:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201b00:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201b04:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b08:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b0a:	10f77f63          	bleu	a5,a4,ffffffffc0201c28 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201b0e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b12:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201b16:	96be                	add	a3,a3,a5
ffffffffc0201b18:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52b88>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b1c:	664040ef          	jal	ra,ffffffffc0206180 <strlen>
ffffffffc0201b20:	54051f63          	bnez	a0,ffffffffc020207e <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201b24:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201b28:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b2a:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52a88>
ffffffffc0201b2e:	068a                	slli	a3,a3,0x2
ffffffffc0201b30:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b32:	0ef6f963          	bleu	a5,a3,ffffffffc0201c24 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0201b36:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b3a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b3c:	0efb7663          	bleu	a5,s6,ffffffffc0201c28 <pmm_init+0x59c>
ffffffffc0201b40:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201b44:	4585                	li	a1,1
ffffffffc0201b46:	8556                	mv	a0,s5
ffffffffc0201b48:	99b6                	add	s3,s3,a3
ffffffffc0201b4a:	be8ff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b4e:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201b52:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b54:	078a                	slli	a5,a5,0x2
ffffffffc0201b56:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b58:	0ce7f663          	bleu	a4,a5,ffffffffc0201c24 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b5c:	00093503          	ld	a0,0(s2)
ffffffffc0201b60:	fff809b7          	lui	s3,0xfff80
ffffffffc0201b64:	97ce                	add	a5,a5,s3
ffffffffc0201b66:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201b68:	953e                	add	a0,a0,a5
ffffffffc0201b6a:	4585                	li	a1,1
ffffffffc0201b6c:	bc6ff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b70:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201b74:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b76:	078a                	slli	a5,a5,0x2
ffffffffc0201b78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b7a:	0ae7f563          	bleu	a4,a5,ffffffffc0201c24 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b7e:	00093503          	ld	a0,0(s2)
ffffffffc0201b82:	97ce                	add	a5,a5,s3
ffffffffc0201b84:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201b86:	953e                	add	a0,a0,a5
ffffffffc0201b88:	4585                	li	a1,1
ffffffffc0201b8a:	ba8ff0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201b8e:	601c                	ld	a5,0(s0)
ffffffffc0201b90:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201b94:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201b98:	be0ff0ef          	jal	ra,ffffffffc0200f78 <nr_free_pages>
ffffffffc0201b9c:	3caa1163          	bne	s4,a0,ffffffffc0201f5e <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201ba0:	00006517          	auipc	a0,0x6
ffffffffc0201ba4:	ac850513          	addi	a0,a0,-1336 # ffffffffc0207668 <commands+0xea0>
ffffffffc0201ba8:	d28fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201bac:	6406                	ld	s0,64(sp)
ffffffffc0201bae:	60a6                	ld	ra,72(sp)
ffffffffc0201bb0:	74e2                	ld	s1,56(sp)
ffffffffc0201bb2:	7942                	ld	s2,48(sp)
ffffffffc0201bb4:	79a2                	ld	s3,40(sp)
ffffffffc0201bb6:	7a02                	ld	s4,32(sp)
ffffffffc0201bb8:	6ae2                	ld	s5,24(sp)
ffffffffc0201bba:	6b42                	ld	s6,16(sp)
ffffffffc0201bbc:	6ba2                	ld	s7,8(sp)
ffffffffc0201bbe:	6c02                	ld	s8,0(sp)
ffffffffc0201bc0:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0201bc2:	65f0106f          	j	ffffffffc0203a20 <kmalloc_init>
ffffffffc0201bc6:	6008                	ld	a0,0(s0)
ffffffffc0201bc8:	bd75                	j	ffffffffc0201a84 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201bca:	00006697          	auipc	a3,0x6
ffffffffc0201bce:	90e68693          	addi	a3,a3,-1778 # ffffffffc02074d8 <commands+0xd10>
ffffffffc0201bd2:	00005617          	auipc	a2,0x5
ffffffffc0201bd6:	0d660613          	addi	a2,a2,214 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201bda:	22900593          	li	a1,553
ffffffffc0201bde:	00005517          	auipc	a0,0x5
ffffffffc0201be2:	4da50513          	addi	a0,a0,1242 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201be6:	e30fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0201bea:	86d6                	mv	a3,s5
ffffffffc0201bec:	00005617          	auipc	a2,0x5
ffffffffc0201bf0:	4a460613          	addi	a2,a2,1188 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0201bf4:	22900593          	li	a1,553
ffffffffc0201bf8:	00005517          	auipc	a0,0x5
ffffffffc0201bfc:	4c050513          	addi	a0,a0,1216 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201c00:	e16fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201c04:	00006697          	auipc	a3,0x6
ffffffffc0201c08:	91468693          	addi	a3,a3,-1772 # ffffffffc0207518 <commands+0xd50>
ffffffffc0201c0c:	00005617          	auipc	a2,0x5
ffffffffc0201c10:	09c60613          	addi	a2,a2,156 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201c14:	22a00593          	li	a1,554
ffffffffc0201c18:	00005517          	auipc	a0,0x5
ffffffffc0201c1c:	4a050513          	addi	a0,a0,1184 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201c20:	df6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0201c24:	a6aff0ef          	jal	ra,ffffffffc0200e8e <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0201c28:	00005617          	auipc	a2,0x5
ffffffffc0201c2c:	46860613          	addi	a2,a2,1128 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0201c30:	06900593          	li	a1,105
ffffffffc0201c34:	00005517          	auipc	a0,0x5
ffffffffc0201c38:	4b450513          	addi	a0,a0,1204 # ffffffffc02070e8 <commands+0x920>
ffffffffc0201c3c:	ddafe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201c40:	00005617          	auipc	a2,0x5
ffffffffc0201c44:	66860613          	addi	a2,a2,1640 # ffffffffc02072a8 <commands+0xae0>
ffffffffc0201c48:	07400593          	li	a1,116
ffffffffc0201c4c:	00005517          	auipc	a0,0x5
ffffffffc0201c50:	49c50513          	addi	a0,a0,1180 # ffffffffc02070e8 <commands+0x920>
ffffffffc0201c54:	dc2fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c58:	00005697          	auipc	a3,0x5
ffffffffc0201c5c:	59068693          	addi	a3,a3,1424 # ffffffffc02071e8 <commands+0xa20>
ffffffffc0201c60:	00005617          	auipc	a2,0x5
ffffffffc0201c64:	04860613          	addi	a2,a2,72 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201c68:	1ed00593          	li	a1,493
ffffffffc0201c6c:	00005517          	auipc	a0,0x5
ffffffffc0201c70:	44c50513          	addi	a0,a0,1100 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201c74:	da2fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c78:	00005697          	auipc	a3,0x5
ffffffffc0201c7c:	65868693          	addi	a3,a3,1624 # ffffffffc02072d0 <commands+0xb08>
ffffffffc0201c80:	00005617          	auipc	a2,0x5
ffffffffc0201c84:	02860613          	addi	a2,a2,40 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201c88:	20900593          	li	a1,521
ffffffffc0201c8c:	00005517          	auipc	a0,0x5
ffffffffc0201c90:	42c50513          	addi	a0,a0,1068 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201c94:	d82fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201c98:	00006697          	auipc	a3,0x6
ffffffffc0201c9c:	8b068693          	addi	a3,a3,-1872 # ffffffffc0207548 <commands+0xd80>
ffffffffc0201ca0:	00005617          	auipc	a2,0x5
ffffffffc0201ca4:	00860613          	addi	a2,a2,8 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201ca8:	23200593          	li	a1,562
ffffffffc0201cac:	00005517          	auipc	a0,0x5
ffffffffc0201cb0:	40c50513          	addi	a0,a0,1036 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201cb4:	d62fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201cb8:	00005697          	auipc	a3,0x5
ffffffffc0201cbc:	6a868693          	addi	a3,a3,1704 # ffffffffc0207360 <commands+0xb98>
ffffffffc0201cc0:	00005617          	auipc	a2,0x5
ffffffffc0201cc4:	fe860613          	addi	a2,a2,-24 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201cc8:	20800593          	li	a1,520
ffffffffc0201ccc:	00005517          	auipc	a0,0x5
ffffffffc0201cd0:	3ec50513          	addi	a0,a0,1004 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201cd4:	d42fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201cd8:	00005697          	auipc	a3,0x5
ffffffffc0201cdc:	75068693          	addi	a3,a3,1872 # ffffffffc0207428 <commands+0xc60>
ffffffffc0201ce0:	00005617          	auipc	a2,0x5
ffffffffc0201ce4:	fc860613          	addi	a2,a2,-56 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201ce8:	20700593          	li	a1,519
ffffffffc0201cec:	00005517          	auipc	a0,0x5
ffffffffc0201cf0:	3cc50513          	addi	a0,a0,972 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201cf4:	d22fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201cf8:	00005697          	auipc	a3,0x5
ffffffffc0201cfc:	71868693          	addi	a3,a3,1816 # ffffffffc0207410 <commands+0xc48>
ffffffffc0201d00:	00005617          	auipc	a2,0x5
ffffffffc0201d04:	fa860613          	addi	a2,a2,-88 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201d08:	20600593          	li	a1,518
ffffffffc0201d0c:	00005517          	auipc	a0,0x5
ffffffffc0201d10:	3ac50513          	addi	a0,a0,940 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201d14:	d02fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d18:	00005697          	auipc	a3,0x5
ffffffffc0201d1c:	6c868693          	addi	a3,a3,1736 # ffffffffc02073e0 <commands+0xc18>
ffffffffc0201d20:	00005617          	auipc	a2,0x5
ffffffffc0201d24:	f8860613          	addi	a2,a2,-120 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201d28:	20500593          	li	a1,517
ffffffffc0201d2c:	00005517          	auipc	a0,0x5
ffffffffc0201d30:	38c50513          	addi	a0,a0,908 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201d34:	ce2fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201d38:	00005697          	auipc	a3,0x5
ffffffffc0201d3c:	69068693          	addi	a3,a3,1680 # ffffffffc02073c8 <commands+0xc00>
ffffffffc0201d40:	00005617          	auipc	a2,0x5
ffffffffc0201d44:	f6860613          	addi	a2,a2,-152 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201d48:	20300593          	li	a1,515
ffffffffc0201d4c:	00005517          	auipc	a0,0x5
ffffffffc0201d50:	36c50513          	addi	a0,a0,876 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201d54:	cc2fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d58:	00005697          	auipc	a3,0x5
ffffffffc0201d5c:	65868693          	addi	a3,a3,1624 # ffffffffc02073b0 <commands+0xbe8>
ffffffffc0201d60:	00005617          	auipc	a2,0x5
ffffffffc0201d64:	f4860613          	addi	a2,a2,-184 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201d68:	20200593          	li	a1,514
ffffffffc0201d6c:	00005517          	auipc	a0,0x5
ffffffffc0201d70:	34c50513          	addi	a0,a0,844 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201d74:	ca2fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201d78:	00005697          	auipc	a3,0x5
ffffffffc0201d7c:	62868693          	addi	a3,a3,1576 # ffffffffc02073a0 <commands+0xbd8>
ffffffffc0201d80:	00005617          	auipc	a2,0x5
ffffffffc0201d84:	f2860613          	addi	a2,a2,-216 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201d88:	20100593          	li	a1,513
ffffffffc0201d8c:	00005517          	auipc	a0,0x5
ffffffffc0201d90:	32c50513          	addi	a0,a0,812 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201d94:	c82fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201d98:	00005697          	auipc	a3,0x5
ffffffffc0201d9c:	5f868693          	addi	a3,a3,1528 # ffffffffc0207390 <commands+0xbc8>
ffffffffc0201da0:	00005617          	auipc	a2,0x5
ffffffffc0201da4:	f0860613          	addi	a2,a2,-248 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201da8:	20000593          	li	a1,512
ffffffffc0201dac:	00005517          	auipc	a0,0x5
ffffffffc0201db0:	30c50513          	addi	a0,a0,780 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201db4:	c62fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201db8:	00005697          	auipc	a3,0x5
ffffffffc0201dbc:	5a868693          	addi	a3,a3,1448 # ffffffffc0207360 <commands+0xb98>
ffffffffc0201dc0:	00005617          	auipc	a2,0x5
ffffffffc0201dc4:	ee860613          	addi	a2,a2,-280 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201dc8:	1ff00593          	li	a1,511
ffffffffc0201dcc:	00005517          	auipc	a0,0x5
ffffffffc0201dd0:	2ec50513          	addi	a0,a0,748 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201dd4:	c42fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201dd8:	00005697          	auipc	a3,0x5
ffffffffc0201ddc:	55068693          	addi	a3,a3,1360 # ffffffffc0207328 <commands+0xb60>
ffffffffc0201de0:	00005617          	auipc	a2,0x5
ffffffffc0201de4:	ec860613          	addi	a2,a2,-312 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201de8:	1fe00593          	li	a1,510
ffffffffc0201dec:	00005517          	auipc	a0,0x5
ffffffffc0201df0:	2cc50513          	addi	a0,a0,716 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201df4:	c22fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201df8:	00005697          	auipc	a3,0x5
ffffffffc0201dfc:	50868693          	addi	a3,a3,1288 # ffffffffc0207300 <commands+0xb38>
ffffffffc0201e00:	00005617          	auipc	a2,0x5
ffffffffc0201e04:	ea860613          	addi	a2,a2,-344 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201e08:	1fb00593          	li	a1,507
ffffffffc0201e0c:	00005517          	auipc	a0,0x5
ffffffffc0201e10:	2ac50513          	addi	a0,a0,684 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201e14:	c02fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201e18:	86da                	mv	a3,s6
ffffffffc0201e1a:	00005617          	auipc	a2,0x5
ffffffffc0201e1e:	27660613          	addi	a2,a2,630 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0201e22:	1fa00593          	li	a1,506
ffffffffc0201e26:	00005517          	auipc	a0,0x5
ffffffffc0201e2a:	29250513          	addi	a0,a0,658 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201e2e:	be8fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201e32:	86be                	mv	a3,a5
ffffffffc0201e34:	00005617          	auipc	a2,0x5
ffffffffc0201e38:	25c60613          	addi	a2,a2,604 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0201e3c:	06900593          	li	a1,105
ffffffffc0201e40:	00005517          	auipc	a0,0x5
ffffffffc0201e44:	2a850513          	addi	a0,a0,680 # ffffffffc02070e8 <commands+0x920>
ffffffffc0201e48:	bcefe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e4c:	00005697          	auipc	a3,0x5
ffffffffc0201e50:	62468693          	addi	a3,a3,1572 # ffffffffc0207470 <commands+0xca8>
ffffffffc0201e54:	00005617          	auipc	a2,0x5
ffffffffc0201e58:	e5460613          	addi	a2,a2,-428 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201e5c:	21400593          	li	a1,532
ffffffffc0201e60:	00005517          	auipc	a0,0x5
ffffffffc0201e64:	25850513          	addi	a0,a0,600 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201e68:	baefe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201e6c:	00005697          	auipc	a3,0x5
ffffffffc0201e70:	5bc68693          	addi	a3,a3,1468 # ffffffffc0207428 <commands+0xc60>
ffffffffc0201e74:	00005617          	auipc	a2,0x5
ffffffffc0201e78:	e3460613          	addi	a2,a2,-460 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201e7c:	21200593          	li	a1,530
ffffffffc0201e80:	00005517          	auipc	a0,0x5
ffffffffc0201e84:	23850513          	addi	a0,a0,568 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201e88:	b8efe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201e8c:	00005697          	auipc	a3,0x5
ffffffffc0201e90:	5cc68693          	addi	a3,a3,1484 # ffffffffc0207458 <commands+0xc90>
ffffffffc0201e94:	00005617          	auipc	a2,0x5
ffffffffc0201e98:	e1460613          	addi	a2,a2,-492 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201e9c:	21100593          	li	a1,529
ffffffffc0201ea0:	00005517          	auipc	a0,0x5
ffffffffc0201ea4:	21850513          	addi	a0,a0,536 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201ea8:	b6efe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201eac:	00005697          	auipc	a3,0x5
ffffffffc0201eb0:	72c68693          	addi	a3,a3,1836 # ffffffffc02075d8 <commands+0xe10>
ffffffffc0201eb4:	00005617          	auipc	a2,0x5
ffffffffc0201eb8:	df460613          	addi	a2,a2,-524 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201ebc:	23500593          	li	a1,565
ffffffffc0201ec0:	00005517          	auipc	a0,0x5
ffffffffc0201ec4:	1f850513          	addi	a0,a0,504 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201ec8:	b4efe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201ecc:	00005697          	auipc	a3,0x5
ffffffffc0201ed0:	6cc68693          	addi	a3,a3,1740 # ffffffffc0207598 <commands+0xdd0>
ffffffffc0201ed4:	00005617          	auipc	a2,0x5
ffffffffc0201ed8:	dd460613          	addi	a2,a2,-556 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201edc:	23400593          	li	a1,564
ffffffffc0201ee0:	00005517          	auipc	a0,0x5
ffffffffc0201ee4:	1d850513          	addi	a0,a0,472 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201ee8:	b2efe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201eec:	00005697          	auipc	a3,0x5
ffffffffc0201ef0:	69468693          	addi	a3,a3,1684 # ffffffffc0207580 <commands+0xdb8>
ffffffffc0201ef4:	00005617          	auipc	a2,0x5
ffffffffc0201ef8:	db460613          	addi	a2,a2,-588 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201efc:	23300593          	li	a1,563
ffffffffc0201f00:	00005517          	auipc	a0,0x5
ffffffffc0201f04:	1b850513          	addi	a0,a0,440 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201f08:	b0efe0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201f0c:	86be                	mv	a3,a5
ffffffffc0201f0e:	00005617          	auipc	a2,0x5
ffffffffc0201f12:	18260613          	addi	a2,a2,386 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0201f16:	1f900593          	li	a1,505
ffffffffc0201f1a:	00005517          	auipc	a0,0x5
ffffffffc0201f1e:	19e50513          	addi	a0,a0,414 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201f22:	af4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201f26:	00005617          	auipc	a2,0x5
ffffffffc0201f2a:	24260613          	addi	a2,a2,578 # ffffffffc0207168 <commands+0x9a0>
ffffffffc0201f2e:	07f00593          	li	a1,127
ffffffffc0201f32:	00005517          	auipc	a0,0x5
ffffffffc0201f36:	18650513          	addi	a0,a0,390 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201f3a:	adcfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f3e:	00005697          	auipc	a3,0x5
ffffffffc0201f42:	6ca68693          	addi	a3,a3,1738 # ffffffffc0207608 <commands+0xe40>
ffffffffc0201f46:	00005617          	auipc	a2,0x5
ffffffffc0201f4a:	d6260613          	addi	a2,a2,-670 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201f4e:	23900593          	li	a1,569
ffffffffc0201f52:	00005517          	auipc	a0,0x5
ffffffffc0201f56:	16650513          	addi	a0,a0,358 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201f5a:	abcfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201f5e:	00005697          	auipc	a3,0x5
ffffffffc0201f62:	53a68693          	addi	a3,a3,1338 # ffffffffc0207498 <commands+0xcd0>
ffffffffc0201f66:	00005617          	auipc	a2,0x5
ffffffffc0201f6a:	d4260613          	addi	a2,a2,-702 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201f6e:	24500593          	li	a1,581
ffffffffc0201f72:	00005517          	auipc	a0,0x5
ffffffffc0201f76:	14650513          	addi	a0,a0,326 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201f7a:	a9cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201f7e:	00005697          	auipc	a3,0x5
ffffffffc0201f82:	36a68693          	addi	a3,a3,874 # ffffffffc02072e8 <commands+0xb20>
ffffffffc0201f86:	00005617          	auipc	a2,0x5
ffffffffc0201f8a:	d2260613          	addi	a2,a2,-734 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201f8e:	1f700593          	li	a1,503
ffffffffc0201f92:	00005517          	auipc	a0,0x5
ffffffffc0201f96:	12650513          	addi	a0,a0,294 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201f9a:	a7cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201f9e:	00005697          	auipc	a3,0x5
ffffffffc0201fa2:	33268693          	addi	a3,a3,818 # ffffffffc02072d0 <commands+0xb08>
ffffffffc0201fa6:	00005617          	auipc	a2,0x5
ffffffffc0201faa:	d0260613          	addi	a2,a2,-766 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201fae:	1f600593          	li	a1,502
ffffffffc0201fb2:	00005517          	auipc	a0,0x5
ffffffffc0201fb6:	10650513          	addi	a0,a0,262 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201fba:	a5cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201fbe:	00005697          	auipc	a3,0x5
ffffffffc0201fc2:	26268693          	addi	a3,a3,610 # ffffffffc0207220 <commands+0xa58>
ffffffffc0201fc6:	00005617          	auipc	a2,0x5
ffffffffc0201fca:	ce260613          	addi	a2,a2,-798 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201fce:	1ee00593          	li	a1,494
ffffffffc0201fd2:	00005517          	auipc	a0,0x5
ffffffffc0201fd6:	0e650513          	addi	a0,a0,230 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201fda:	a3cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201fde:	00005697          	auipc	a3,0x5
ffffffffc0201fe2:	29a68693          	addi	a3,a3,666 # ffffffffc0207278 <commands+0xab0>
ffffffffc0201fe6:	00005617          	auipc	a2,0x5
ffffffffc0201fea:	cc260613          	addi	a2,a2,-830 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0201fee:	1f500593          	li	a1,501
ffffffffc0201ff2:	00005517          	auipc	a0,0x5
ffffffffc0201ff6:	0c650513          	addi	a0,a0,198 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0201ffa:	a1cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201ffe:	00005697          	auipc	a3,0x5
ffffffffc0202002:	24a68693          	addi	a3,a3,586 # ffffffffc0207248 <commands+0xa80>
ffffffffc0202006:	00005617          	auipc	a2,0x5
ffffffffc020200a:	ca260613          	addi	a2,a2,-862 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020200e:	1f200593          	li	a1,498
ffffffffc0202012:	00005517          	auipc	a0,0x5
ffffffffc0202016:	0a650513          	addi	a0,a0,166 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc020201a:	9fcfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020201e:	00005697          	auipc	a3,0x5
ffffffffc0202022:	40a68693          	addi	a3,a3,1034 # ffffffffc0207428 <commands+0xc60>
ffffffffc0202026:	00005617          	auipc	a2,0x5
ffffffffc020202a:	c8260613          	addi	a2,a2,-894 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020202e:	20e00593          	li	a1,526
ffffffffc0202032:	00005517          	auipc	a0,0x5
ffffffffc0202036:	08650513          	addi	a0,a0,134 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc020203a:	9dcfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020203e:	00005697          	auipc	a3,0x5
ffffffffc0202042:	2aa68693          	addi	a3,a3,682 # ffffffffc02072e8 <commands+0xb20>
ffffffffc0202046:	00005617          	auipc	a2,0x5
ffffffffc020204a:	c6260613          	addi	a2,a2,-926 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020204e:	20d00593          	li	a1,525
ffffffffc0202052:	00005517          	auipc	a0,0x5
ffffffffc0202056:	06650513          	addi	a0,a0,102 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc020205a:	9bcfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020205e:	00005697          	auipc	a3,0x5
ffffffffc0202062:	3e268693          	addi	a3,a3,994 # ffffffffc0207440 <commands+0xc78>
ffffffffc0202066:	00005617          	auipc	a2,0x5
ffffffffc020206a:	c4260613          	addi	a2,a2,-958 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020206e:	20a00593          	li	a1,522
ffffffffc0202072:	00005517          	auipc	a0,0x5
ffffffffc0202076:	04650513          	addi	a0,a0,70 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc020207a:	99cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020207e:	00005697          	auipc	a3,0x5
ffffffffc0202082:	5c268693          	addi	a3,a3,1474 # ffffffffc0207640 <commands+0xe78>
ffffffffc0202086:	00005617          	auipc	a2,0x5
ffffffffc020208a:	c2260613          	addi	a2,a2,-990 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020208e:	23c00593          	li	a1,572
ffffffffc0202092:	00005517          	auipc	a0,0x5
ffffffffc0202096:	02650513          	addi	a0,a0,38 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc020209a:	97cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020209e:	00005697          	auipc	a3,0x5
ffffffffc02020a2:	3fa68693          	addi	a3,a3,1018 # ffffffffc0207498 <commands+0xcd0>
ffffffffc02020a6:	00005617          	auipc	a2,0x5
ffffffffc02020aa:	c0260613          	addi	a2,a2,-1022 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02020ae:	21c00593          	li	a1,540
ffffffffc02020b2:	00005517          	auipc	a0,0x5
ffffffffc02020b6:	00650513          	addi	a0,a0,6 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc02020ba:	95cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02020be:	00005697          	auipc	a3,0x5
ffffffffc02020c2:	47268693          	addi	a3,a3,1138 # ffffffffc0207530 <commands+0xd68>
ffffffffc02020c6:	00005617          	auipc	a2,0x5
ffffffffc02020ca:	be260613          	addi	a2,a2,-1054 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02020ce:	22e00593          	li	a1,558
ffffffffc02020d2:	00005517          	auipc	a0,0x5
ffffffffc02020d6:	fe650513          	addi	a0,a0,-26 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc02020da:	93cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02020de:	00005697          	auipc	a3,0x5
ffffffffc02020e2:	0ea68693          	addi	a3,a3,234 # ffffffffc02071c8 <commands+0xa00>
ffffffffc02020e6:	00005617          	auipc	a2,0x5
ffffffffc02020ea:	bc260613          	addi	a2,a2,-1086 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02020ee:	1ec00593          	li	a1,492
ffffffffc02020f2:	00005517          	auipc	a0,0x5
ffffffffc02020f6:	fc650513          	addi	a0,a0,-58 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc02020fa:	91cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02020fe:	00005617          	auipc	a2,0x5
ffffffffc0202102:	06a60613          	addi	a2,a2,106 # ffffffffc0207168 <commands+0x9a0>
ffffffffc0202106:	0c100593          	li	a1,193
ffffffffc020210a:	00005517          	auipc	a0,0x5
ffffffffc020210e:	fae50513          	addi	a0,a0,-82 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0202112:	904fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202116 <copy_range>:
               bool share) {
ffffffffc0202116:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202118:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc020211c:	f486                	sd	ra,104(sp)
ffffffffc020211e:	f0a2                	sd	s0,96(sp)
ffffffffc0202120:	eca6                	sd	s1,88(sp)
ffffffffc0202122:	e8ca                	sd	s2,80(sp)
ffffffffc0202124:	e4ce                	sd	s3,72(sp)
ffffffffc0202126:	e0d2                	sd	s4,64(sp)
ffffffffc0202128:	fc56                	sd	s5,56(sp)
ffffffffc020212a:	f85a                	sd	s6,48(sp)
ffffffffc020212c:	f45e                	sd	s7,40(sp)
ffffffffc020212e:	f062                	sd	s8,32(sp)
ffffffffc0202130:	ec66                	sd	s9,24(sp)
ffffffffc0202132:	e86a                	sd	s10,16(sp)
ffffffffc0202134:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202136:	03479713          	slli	a4,a5,0x34
ffffffffc020213a:	1e071863          	bnez	a4,ffffffffc020232a <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc020213e:	002007b7          	lui	a5,0x200
ffffffffc0202142:	8432                	mv	s0,a2
ffffffffc0202144:	16f66b63          	bltu	a2,a5,ffffffffc02022ba <copy_range+0x1a4>
ffffffffc0202148:	84b6                	mv	s1,a3
ffffffffc020214a:	16d67863          	bleu	a3,a2,ffffffffc02022ba <copy_range+0x1a4>
ffffffffc020214e:	4785                	li	a5,1
ffffffffc0202150:	07fe                	slli	a5,a5,0x1f
ffffffffc0202152:	16d7e463          	bltu	a5,a3,ffffffffc02022ba <copy_range+0x1a4>
ffffffffc0202156:	5a7d                	li	s4,-1
ffffffffc0202158:	8aaa                	mv	s5,a0
ffffffffc020215a:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc020215c:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc020215e:	000aac17          	auipc	s8,0xaa
ffffffffc0202162:	2a2c0c13          	addi	s8,s8,674 # ffffffffc02ac400 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202166:	000aab97          	auipc	s7,0xaa
ffffffffc020216a:	302b8b93          	addi	s7,s7,770 # ffffffffc02ac468 <pages>
    return page - pages + nbase;
ffffffffc020216e:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0202172:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0202176:	4601                	li	a2,0
ffffffffc0202178:	85a2                	mv	a1,s0
ffffffffc020217a:	854a                	mv	a0,s2
ffffffffc020217c:	e3dfe0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc0202180:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc0202182:	c17d                	beqz	a0,ffffffffc0202268 <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc0202184:	611c                	ld	a5,0(a0)
ffffffffc0202186:	8b85                	andi	a5,a5,1
ffffffffc0202188:	e785                	bnez	a5,ffffffffc02021b0 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc020218a:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc020218c:	fe9465e3          	bltu	s0,s1,ffffffffc0202176 <copy_range+0x60>
    return 0;
ffffffffc0202190:	4501                	li	a0,0
}
ffffffffc0202192:	70a6                	ld	ra,104(sp)
ffffffffc0202194:	7406                	ld	s0,96(sp)
ffffffffc0202196:	64e6                	ld	s1,88(sp)
ffffffffc0202198:	6946                	ld	s2,80(sp)
ffffffffc020219a:	69a6                	ld	s3,72(sp)
ffffffffc020219c:	6a06                	ld	s4,64(sp)
ffffffffc020219e:	7ae2                	ld	s5,56(sp)
ffffffffc02021a0:	7b42                	ld	s6,48(sp)
ffffffffc02021a2:	7ba2                	ld	s7,40(sp)
ffffffffc02021a4:	7c02                	ld	s8,32(sp)
ffffffffc02021a6:	6ce2                	ld	s9,24(sp)
ffffffffc02021a8:	6d42                	ld	s10,16(sp)
ffffffffc02021aa:	6da2                	ld	s11,8(sp)
ffffffffc02021ac:	6165                	addi	sp,sp,112
ffffffffc02021ae:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02021b0:	4605                	li	a2,1
ffffffffc02021b2:	85a2                	mv	a1,s0
ffffffffc02021b4:	8556                	mv	a0,s5
ffffffffc02021b6:	e03fe0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc02021ba:	c169                	beqz	a0,ffffffffc020227c <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02021bc:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc02021c0:	0017f713          	andi	a4,a5,1
ffffffffc02021c4:	01f7fc93          	andi	s9,a5,31
ffffffffc02021c8:	14070563          	beqz	a4,ffffffffc0202312 <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc02021cc:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021d0:	078a                	slli	a5,a5,0x2
ffffffffc02021d2:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021d6:	12d77263          	bleu	a3,a4,ffffffffc02022fa <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc02021da:	000bb783          	ld	a5,0(s7)
ffffffffc02021de:	fff806b7          	lui	a3,0xfff80
ffffffffc02021e2:	9736                	add	a4,a4,a3
ffffffffc02021e4:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc02021e6:	4505                	li	a0,1
ffffffffc02021e8:	00e78db3          	add	s11,a5,a4
ffffffffc02021ec:	cbffe0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02021f0:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02021f2:	0a0d8463          	beqz	s11,ffffffffc020229a <copy_range+0x184>
            assert(npage != NULL);
ffffffffc02021f6:	c175                	beqz	a0,ffffffffc02022da <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc02021f8:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc02021fc:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0202200:	40ed86b3          	sub	a3,s11,a4
ffffffffc0202204:	8699                	srai	a3,a3,0x6
ffffffffc0202206:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0202208:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc020220c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020220e:	06c7fa63          	bleu	a2,a5,ffffffffc0202282 <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc0202212:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc0202216:	000aa717          	auipc	a4,0xaa
ffffffffc020221a:	24270713          	addi	a4,a4,578 # ffffffffc02ac458 <va_pa_offset>
ffffffffc020221e:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0202220:	8799                	srai	a5,a5,0x6
ffffffffc0202222:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0202224:	0147f733          	and	a4,a5,s4
ffffffffc0202228:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020222c:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020222e:	04c77963          	bleu	a2,a4,ffffffffc0202280 <copy_range+0x16a>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE); // parent 的物理页复制给 child
ffffffffc0202232:	6605                	lui	a2,0x1
ffffffffc0202234:	953e                	add	a0,a0,a5
ffffffffc0202236:	7fb030ef          	jal	ra,ffffffffc0206230 <memcpy>
            ret = page_insert(to, npage, start, perm); // 建立 child 的物理页和虚拟页的映射关系
ffffffffc020223a:	86e6                	mv	a3,s9
ffffffffc020223c:	8622                	mv	a2,s0
ffffffffc020223e:	85ea                	mv	a1,s10
ffffffffc0202240:	8556                	mv	a0,s5
ffffffffc0202242:	b8cff0ef          	jal	ra,ffffffffc02015ce <page_insert>
            assert(ret == 0);
ffffffffc0202246:	d131                	beqz	a0,ffffffffc020218a <copy_range+0x74>
ffffffffc0202248:	00005697          	auipc	a3,0x5
ffffffffc020224c:	e3868693          	addi	a3,a3,-456 # ffffffffc0207080 <commands+0x8b8>
ffffffffc0202250:	00005617          	auipc	a2,0x5
ffffffffc0202254:	a5860613          	addi	a2,a2,-1448 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202258:	18c00593          	li	a1,396
ffffffffc020225c:	00005517          	auipc	a0,0x5
ffffffffc0202260:	e5c50513          	addi	a0,a0,-420 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0202264:	fb3fd0ef          	jal	ra,ffffffffc0200216 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202268:	002007b7          	lui	a5,0x200
ffffffffc020226c:	943e                	add	s0,s0,a5
ffffffffc020226e:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202272:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc0202274:	dc11                	beqz	s0,ffffffffc0202190 <copy_range+0x7a>
ffffffffc0202276:	f09460e3          	bltu	s0,s1,ffffffffc0202176 <copy_range+0x60>
ffffffffc020227a:	bf19                	j	ffffffffc0202190 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc020227c:	5571                	li	a0,-4
ffffffffc020227e:	bf11                	j	ffffffffc0202192 <copy_range+0x7c>
ffffffffc0202280:	86be                	mv	a3,a5
ffffffffc0202282:	00005617          	auipc	a2,0x5
ffffffffc0202286:	e0e60613          	addi	a2,a2,-498 # ffffffffc0207090 <commands+0x8c8>
ffffffffc020228a:	06900593          	li	a1,105
ffffffffc020228e:	00005517          	auipc	a0,0x5
ffffffffc0202292:	e5a50513          	addi	a0,a0,-422 # ffffffffc02070e8 <commands+0x920>
ffffffffc0202296:	f81fd0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(page != NULL);
ffffffffc020229a:	00005697          	auipc	a3,0x5
ffffffffc020229e:	dc668693          	addi	a3,a3,-570 # ffffffffc0207060 <commands+0x898>
ffffffffc02022a2:	00005617          	auipc	a2,0x5
ffffffffc02022a6:	a0660613          	addi	a2,a2,-1530 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02022aa:	17200593          	li	a1,370
ffffffffc02022ae:	00005517          	auipc	a0,0x5
ffffffffc02022b2:	e0a50513          	addi	a0,a0,-502 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc02022b6:	f61fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02022ba:	00005697          	auipc	a3,0x5
ffffffffc02022be:	3fe68693          	addi	a3,a3,1022 # ffffffffc02076b8 <commands+0xef0>
ffffffffc02022c2:	00005617          	auipc	a2,0x5
ffffffffc02022c6:	9e660613          	addi	a2,a2,-1562 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02022ca:	15e00593          	li	a1,350
ffffffffc02022ce:	00005517          	auipc	a0,0x5
ffffffffc02022d2:	dea50513          	addi	a0,a0,-534 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc02022d6:	f41fd0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(npage != NULL);
ffffffffc02022da:	00005697          	auipc	a3,0x5
ffffffffc02022de:	d9668693          	addi	a3,a3,-618 # ffffffffc0207070 <commands+0x8a8>
ffffffffc02022e2:	00005617          	auipc	a2,0x5
ffffffffc02022e6:	9c660613          	addi	a2,a2,-1594 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02022ea:	17300593          	li	a1,371
ffffffffc02022ee:	00005517          	auipc	a0,0x5
ffffffffc02022f2:	dca50513          	addi	a0,a0,-566 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc02022f6:	f21fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02022fa:	00005617          	auipc	a2,0x5
ffffffffc02022fe:	dce60613          	addi	a2,a2,-562 # ffffffffc02070c8 <commands+0x900>
ffffffffc0202302:	06200593          	li	a1,98
ffffffffc0202306:	00005517          	auipc	a0,0x5
ffffffffc020230a:	de250513          	addi	a0,a0,-542 # ffffffffc02070e8 <commands+0x920>
ffffffffc020230e:	f09fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202312:	00005617          	auipc	a2,0x5
ffffffffc0202316:	f9660613          	addi	a2,a2,-106 # ffffffffc02072a8 <commands+0xae0>
ffffffffc020231a:	07400593          	li	a1,116
ffffffffc020231e:	00005517          	auipc	a0,0x5
ffffffffc0202322:	dca50513          	addi	a0,a0,-566 # ffffffffc02070e8 <commands+0x920>
ffffffffc0202326:	ef1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020232a:	00005697          	auipc	a3,0x5
ffffffffc020232e:	35e68693          	addi	a3,a3,862 # ffffffffc0207688 <commands+0xec0>
ffffffffc0202332:	00005617          	auipc	a2,0x5
ffffffffc0202336:	97660613          	addi	a2,a2,-1674 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020233a:	15d00593          	li	a1,349
ffffffffc020233e:	00005517          	auipc	a0,0x5
ffffffffc0202342:	d7a50513          	addi	a0,a0,-646 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc0202346:	ed1fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020234a <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020234a:	12058073          	sfence.vma	a1
}
ffffffffc020234e:	8082                	ret

ffffffffc0202350 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202350:	7179                	addi	sp,sp,-48
ffffffffc0202352:	e84a                	sd	s2,16(sp)
ffffffffc0202354:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202356:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202358:	f022                	sd	s0,32(sp)
ffffffffc020235a:	ec26                	sd	s1,24(sp)
ffffffffc020235c:	e44e                	sd	s3,8(sp)
ffffffffc020235e:	f406                	sd	ra,40(sp)
ffffffffc0202360:	84ae                	mv	s1,a1
ffffffffc0202362:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202364:	b47fe0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0202368:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020236a:	cd1d                	beqz	a0,ffffffffc02023a8 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020236c:	85aa                	mv	a1,a0
ffffffffc020236e:	86ce                	mv	a3,s3
ffffffffc0202370:	8626                	mv	a2,s1
ffffffffc0202372:	854a                	mv	a0,s2
ffffffffc0202374:	a5aff0ef          	jal	ra,ffffffffc02015ce <page_insert>
ffffffffc0202378:	e121                	bnez	a0,ffffffffc02023b8 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc020237a:	000aa797          	auipc	a5,0xaa
ffffffffc020237e:	09e78793          	addi	a5,a5,158 # ffffffffc02ac418 <swap_init_ok>
ffffffffc0202382:	439c                	lw	a5,0(a5)
ffffffffc0202384:	2781                	sext.w	a5,a5
ffffffffc0202386:	c38d                	beqz	a5,ffffffffc02023a8 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0202388:	000aa797          	auipc	a5,0xaa
ffffffffc020238c:	0e878793          	addi	a5,a5,232 # ffffffffc02ac470 <check_mm_struct>
ffffffffc0202390:	6388                	ld	a0,0(a5)
ffffffffc0202392:	c919                	beqz	a0,ffffffffc02023a8 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202394:	4681                	li	a3,0
ffffffffc0202396:	8622                	mv	a2,s0
ffffffffc0202398:	85a6                	mv	a1,s1
ffffffffc020239a:	25a010ef          	jal	ra,ffffffffc02035f4 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc020239e:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02023a0:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02023a2:	4785                	li	a5,1
ffffffffc02023a4:	02f71063          	bne	a4,a5,ffffffffc02023c4 <pgdir_alloc_page+0x74>
}
ffffffffc02023a8:	8522                	mv	a0,s0
ffffffffc02023aa:	70a2                	ld	ra,40(sp)
ffffffffc02023ac:	7402                	ld	s0,32(sp)
ffffffffc02023ae:	64e2                	ld	s1,24(sp)
ffffffffc02023b0:	6942                	ld	s2,16(sp)
ffffffffc02023b2:	69a2                	ld	s3,8(sp)
ffffffffc02023b4:	6145                	addi	sp,sp,48
ffffffffc02023b6:	8082                	ret
            free_page(page);
ffffffffc02023b8:	8522                	mv	a0,s0
ffffffffc02023ba:	4585                	li	a1,1
ffffffffc02023bc:	b77fe0ef          	jal	ra,ffffffffc0200f32 <free_pages>
            return NULL;
ffffffffc02023c0:	4401                	li	s0,0
ffffffffc02023c2:	b7dd                	j	ffffffffc02023a8 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc02023c4:	00005697          	auipc	a3,0x5
ffffffffc02023c8:	d3468693          	addi	a3,a3,-716 # ffffffffc02070f8 <commands+0x930>
ffffffffc02023cc:	00005617          	auipc	a2,0x5
ffffffffc02023d0:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02023d4:	1cd00593          	li	a1,461
ffffffffc02023d8:	00005517          	auipc	a0,0x5
ffffffffc02023dc:	ce050513          	addi	a0,a0,-800 # ffffffffc02070b8 <commands+0x8f0>
ffffffffc02023e0:	e37fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02023e4 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02023e4:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02023e6:	00005697          	auipc	a3,0x5
ffffffffc02023ea:	2ea68693          	addi	a3,a3,746 # ffffffffc02076d0 <commands+0xf08>
ffffffffc02023ee:	00005617          	auipc	a2,0x5
ffffffffc02023f2:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02023f6:	06d00593          	li	a1,109
ffffffffc02023fa:	00005517          	auipc	a0,0x5
ffffffffc02023fe:	2f650513          	addi	a0,a0,758 # ffffffffc02076f0 <commands+0xf28>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0202402:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0202404:	e13fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202408 <mm_create>:
mm_create(void) {
ffffffffc0202408:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020240a:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020240e:	e022                	sd	s0,0(sp)
ffffffffc0202410:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202412:	632010ef          	jal	ra,ffffffffc0203a44 <kmalloc>
ffffffffc0202416:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0202418:	c515                	beqz	a0,ffffffffc0202444 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020241a:	000aa797          	auipc	a5,0xaa
ffffffffc020241e:	ffe78793          	addi	a5,a5,-2 # ffffffffc02ac418 <swap_init_ok>
ffffffffc0202422:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0202424:	e408                	sd	a0,8(s0)
ffffffffc0202426:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0202428:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020242c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0202430:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202434:	2781                	sext.w	a5,a5
ffffffffc0202436:	ef81                	bnez	a5,ffffffffc020244e <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0202438:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc020243c:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0202440:	02043c23          	sd	zero,56(s0)
}
ffffffffc0202444:	8522                	mv	a0,s0
ffffffffc0202446:	60a2                	ld	ra,8(sp)
ffffffffc0202448:	6402                	ld	s0,0(sp)
ffffffffc020244a:	0141                	addi	sp,sp,16
ffffffffc020244c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020244e:	196010ef          	jal	ra,ffffffffc02035e4 <swap_init_mm>
ffffffffc0202452:	b7ed                	j	ffffffffc020243c <mm_create+0x34>

ffffffffc0202454 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0202454:	1101                	addi	sp,sp,-32
ffffffffc0202456:	e04a                	sd	s2,0(sp)
ffffffffc0202458:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020245a:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020245e:	e822                	sd	s0,16(sp)
ffffffffc0202460:	e426                	sd	s1,8(sp)
ffffffffc0202462:	ec06                	sd	ra,24(sp)
ffffffffc0202464:	84ae                	mv	s1,a1
ffffffffc0202466:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202468:	5dc010ef          	jal	ra,ffffffffc0203a44 <kmalloc>
    if (vma != NULL) {
ffffffffc020246c:	c509                	beqz	a0,ffffffffc0202476 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020246e:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202472:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202474:	cd00                	sw	s0,24(a0)
}
ffffffffc0202476:	60e2                	ld	ra,24(sp)
ffffffffc0202478:	6442                	ld	s0,16(sp)
ffffffffc020247a:	64a2                	ld	s1,8(sp)
ffffffffc020247c:	6902                	ld	s2,0(sp)
ffffffffc020247e:	6105                	addi	sp,sp,32
ffffffffc0202480:	8082                	ret

ffffffffc0202482 <find_vma>:
    if (mm != NULL) {
ffffffffc0202482:	c51d                	beqz	a0,ffffffffc02024b0 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0202484:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202486:	c781                	beqz	a5,ffffffffc020248e <find_vma+0xc>
ffffffffc0202488:	6798                	ld	a4,8(a5)
ffffffffc020248a:	02e5f663          	bleu	a4,a1,ffffffffc02024b6 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020248e:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0202490:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0202492:	00f50f63          	beq	a0,a5,ffffffffc02024b0 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0202496:	fe87b703          	ld	a4,-24(a5)
ffffffffc020249a:	fee5ebe3          	bltu	a1,a4,ffffffffc0202490 <find_vma+0xe>
ffffffffc020249e:	ff07b703          	ld	a4,-16(a5)
ffffffffc02024a2:	fee5f7e3          	bleu	a4,a1,ffffffffc0202490 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02024a6:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02024a8:	c781                	beqz	a5,ffffffffc02024b0 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02024aa:	e91c                	sd	a5,16(a0)
}
ffffffffc02024ac:	853e                	mv	a0,a5
ffffffffc02024ae:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02024b0:	4781                	li	a5,0
}
ffffffffc02024b2:	853e                	mv	a0,a5
ffffffffc02024b4:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02024b6:	6b98                	ld	a4,16(a5)
ffffffffc02024b8:	fce5fbe3          	bleu	a4,a1,ffffffffc020248e <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02024bc:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02024be:	b7fd                	j	ffffffffc02024ac <find_vma+0x2a>

ffffffffc02024c0 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02024c0:	6590                	ld	a2,8(a1)
ffffffffc02024c2:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02024c6:	1141                	addi	sp,sp,-16
ffffffffc02024c8:	e406                	sd	ra,8(sp)
ffffffffc02024ca:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02024cc:	01066863          	bltu	a2,a6,ffffffffc02024dc <insert_vma_struct+0x1c>
ffffffffc02024d0:	a8b9                	j	ffffffffc020252e <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02024d2:	fe87b683          	ld	a3,-24(a5)
ffffffffc02024d6:	04d66763          	bltu	a2,a3,ffffffffc0202524 <insert_vma_struct+0x64>
ffffffffc02024da:	873e                	mv	a4,a5
ffffffffc02024dc:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02024de:	fef51ae3          	bne	a0,a5,ffffffffc02024d2 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02024e2:	02a70463          	beq	a4,a0,ffffffffc020250a <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02024e6:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02024ea:	fe873883          	ld	a7,-24(a4)
ffffffffc02024ee:	08d8f063          	bleu	a3,a7,ffffffffc020256e <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02024f2:	04d66e63          	bltu	a2,a3,ffffffffc020254e <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02024f6:	00f50a63          	beq	a0,a5,ffffffffc020250a <insert_vma_struct+0x4a>
ffffffffc02024fa:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02024fe:	0506e863          	bltu	a3,a6,ffffffffc020254e <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0202502:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202506:	02c6f263          	bleu	a2,a3,ffffffffc020252a <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020250a:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc020250c:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020250e:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0202512:	e390                	sd	a2,0(a5)
ffffffffc0202514:	e710                	sd	a2,8(a4)
}
ffffffffc0202516:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202518:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020251a:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc020251c:	2685                	addiw	a3,a3,1
ffffffffc020251e:	d114                	sw	a3,32(a0)
}
ffffffffc0202520:	0141                	addi	sp,sp,16
ffffffffc0202522:	8082                	ret
    if (le_prev != list) {
ffffffffc0202524:	fca711e3          	bne	a4,a0,ffffffffc02024e6 <insert_vma_struct+0x26>
ffffffffc0202528:	bfd9                	j	ffffffffc02024fe <insert_vma_struct+0x3e>
ffffffffc020252a:	ebbff0ef          	jal	ra,ffffffffc02023e4 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020252e:	00005697          	auipc	a3,0x5
ffffffffc0202532:	2b268693          	addi	a3,a3,690 # ffffffffc02077e0 <commands+0x1018>
ffffffffc0202536:	00004617          	auipc	a2,0x4
ffffffffc020253a:	77260613          	addi	a2,a2,1906 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020253e:	07400593          	li	a1,116
ffffffffc0202542:	00005517          	auipc	a0,0x5
ffffffffc0202546:	1ae50513          	addi	a0,a0,430 # ffffffffc02076f0 <commands+0xf28>
ffffffffc020254a:	ccdfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020254e:	00005697          	auipc	a3,0x5
ffffffffc0202552:	2d268693          	addi	a3,a3,722 # ffffffffc0207820 <commands+0x1058>
ffffffffc0202556:	00004617          	auipc	a2,0x4
ffffffffc020255a:	75260613          	addi	a2,a2,1874 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020255e:	06c00593          	li	a1,108
ffffffffc0202562:	00005517          	auipc	a0,0x5
ffffffffc0202566:	18e50513          	addi	a0,a0,398 # ffffffffc02076f0 <commands+0xf28>
ffffffffc020256a:	cadfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020256e:	00005697          	auipc	a3,0x5
ffffffffc0202572:	29268693          	addi	a3,a3,658 # ffffffffc0207800 <commands+0x1038>
ffffffffc0202576:	00004617          	auipc	a2,0x4
ffffffffc020257a:	73260613          	addi	a2,a2,1842 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020257e:	06b00593          	li	a1,107
ffffffffc0202582:	00005517          	auipc	a0,0x5
ffffffffc0202586:	16e50513          	addi	a0,a0,366 # ffffffffc02076f0 <commands+0xf28>
ffffffffc020258a:	c8dfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020258e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020258e:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0202590:	1141                	addi	sp,sp,-16
ffffffffc0202592:	e406                	sd	ra,8(sp)
ffffffffc0202594:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202596:	e78d                	bnez	a5,ffffffffc02025c0 <mm_destroy+0x32>
ffffffffc0202598:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020259a:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020259c:	00a40c63          	beq	s0,a0,ffffffffc02025b4 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02025a0:	6118                	ld	a4,0(a0)
ffffffffc02025a2:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02025a4:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02025a6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02025a8:	e398                	sd	a4,0(a5)
ffffffffc02025aa:	556010ef          	jal	ra,ffffffffc0203b00 <kfree>
    return listelm->next;
ffffffffc02025ae:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02025b0:	fea418e3          	bne	s0,a0,ffffffffc02025a0 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02025b4:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02025b6:	6402                	ld	s0,0(sp)
ffffffffc02025b8:	60a2                	ld	ra,8(sp)
ffffffffc02025ba:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02025bc:	5440106f          	j	ffffffffc0203b00 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02025c0:	00005697          	auipc	a3,0x5
ffffffffc02025c4:	28068693          	addi	a3,a3,640 # ffffffffc0207840 <commands+0x1078>
ffffffffc02025c8:	00004617          	auipc	a2,0x4
ffffffffc02025cc:	6e060613          	addi	a2,a2,1760 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02025d0:	09400593          	li	a1,148
ffffffffc02025d4:	00005517          	auipc	a0,0x5
ffffffffc02025d8:	11c50513          	addi	a0,a0,284 # ffffffffc02076f0 <commands+0xf28>
ffffffffc02025dc:	c3bfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02025e0 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025e0:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02025e2:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025e4:	17fd                	addi	a5,a5,-1
ffffffffc02025e6:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02025e8:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025ea:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02025ee:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025f0:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02025f2:	fc06                	sd	ra,56(sp)
ffffffffc02025f4:	f04a                	sd	s2,32(sp)
ffffffffc02025f6:	ec4e                	sd	s3,24(sp)
ffffffffc02025f8:	e852                	sd	s4,16(sp)
ffffffffc02025fa:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025fc:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc0202600:	002007b7          	lui	a5,0x200
ffffffffc0202604:	01047433          	and	s0,s0,a6
ffffffffc0202608:	06f4e363          	bltu	s1,a5,ffffffffc020266e <mm_map+0x8e>
ffffffffc020260c:	0684f163          	bleu	s0,s1,ffffffffc020266e <mm_map+0x8e>
ffffffffc0202610:	4785                	li	a5,1
ffffffffc0202612:	07fe                	slli	a5,a5,0x1f
ffffffffc0202614:	0487ed63          	bltu	a5,s0,ffffffffc020266e <mm_map+0x8e>
ffffffffc0202618:	89aa                	mv	s3,a0
ffffffffc020261a:	8a3a                	mv	s4,a4
ffffffffc020261c:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc020261e:	c931                	beqz	a0,ffffffffc0202672 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0202620:	85a6                	mv	a1,s1
ffffffffc0202622:	e61ff0ef          	jal	ra,ffffffffc0202482 <find_vma>
ffffffffc0202626:	c501                	beqz	a0,ffffffffc020262e <mm_map+0x4e>
ffffffffc0202628:	651c                	ld	a5,8(a0)
ffffffffc020262a:	0487e263          	bltu	a5,s0,ffffffffc020266e <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020262e:	03000513          	li	a0,48
ffffffffc0202632:	412010ef          	jal	ra,ffffffffc0203a44 <kmalloc>
ffffffffc0202636:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202638:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc020263a:	02090163          	beqz	s2,ffffffffc020265c <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020263e:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0202640:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0202644:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202648:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc020264c:	85ca                	mv	a1,s2
ffffffffc020264e:	e73ff0ef          	jal	ra,ffffffffc02024c0 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0202652:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0202654:	000a0463          	beqz	s4,ffffffffc020265c <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0202658:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020265c:	70e2                	ld	ra,56(sp)
ffffffffc020265e:	7442                	ld	s0,48(sp)
ffffffffc0202660:	74a2                	ld	s1,40(sp)
ffffffffc0202662:	7902                	ld	s2,32(sp)
ffffffffc0202664:	69e2                	ld	s3,24(sp)
ffffffffc0202666:	6a42                	ld	s4,16(sp)
ffffffffc0202668:	6aa2                	ld	s5,8(sp)
ffffffffc020266a:	6121                	addi	sp,sp,64
ffffffffc020266c:	8082                	ret
        return -E_INVAL;
ffffffffc020266e:	5575                	li	a0,-3
ffffffffc0202670:	b7f5                	j	ffffffffc020265c <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0202672:	00005697          	auipc	a3,0x5
ffffffffc0202676:	1e668693          	addi	a3,a3,486 # ffffffffc0207858 <commands+0x1090>
ffffffffc020267a:	00004617          	auipc	a2,0x4
ffffffffc020267e:	62e60613          	addi	a2,a2,1582 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202682:	0a700593          	li	a1,167
ffffffffc0202686:	00005517          	auipc	a0,0x5
ffffffffc020268a:	06a50513          	addi	a0,a0,106 # ffffffffc02076f0 <commands+0xf28>
ffffffffc020268e:	b89fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202692 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0202692:	7139                	addi	sp,sp,-64
ffffffffc0202694:	fc06                	sd	ra,56(sp)
ffffffffc0202696:	f822                	sd	s0,48(sp)
ffffffffc0202698:	f426                	sd	s1,40(sp)
ffffffffc020269a:	f04a                	sd	s2,32(sp)
ffffffffc020269c:	ec4e                	sd	s3,24(sp)
ffffffffc020269e:	e852                	sd	s4,16(sp)
ffffffffc02026a0:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02026a2:	c535                	beqz	a0,ffffffffc020270e <dup_mmap+0x7c>
ffffffffc02026a4:	892a                	mv	s2,a0
ffffffffc02026a6:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02026a8:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02026aa:	e59d                	bnez	a1,ffffffffc02026d8 <dup_mmap+0x46>
ffffffffc02026ac:	a08d                	j	ffffffffc020270e <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02026ae:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc02026b0:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5590>
        insert_vma_struct(to, nvma);
ffffffffc02026b4:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc02026b6:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc02026ba:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc02026be:	e03ff0ef          	jal	ra,ffffffffc02024c0 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02026c2:	ff043683          	ld	a3,-16(s0)
ffffffffc02026c6:	fe843603          	ld	a2,-24(s0)
ffffffffc02026ca:	6c8c                	ld	a1,24(s1)
ffffffffc02026cc:	01893503          	ld	a0,24(s2)
ffffffffc02026d0:	4701                	li	a4,0
ffffffffc02026d2:	a45ff0ef          	jal	ra,ffffffffc0202116 <copy_range>
ffffffffc02026d6:	e105                	bnez	a0,ffffffffc02026f6 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc02026d8:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02026da:	02848863          	beq	s1,s0,ffffffffc020270a <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02026de:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02026e2:	fe843a83          	ld	s5,-24(s0)
ffffffffc02026e6:	ff043a03          	ld	s4,-16(s0)
ffffffffc02026ea:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02026ee:	356010ef          	jal	ra,ffffffffc0203a44 <kmalloc>
ffffffffc02026f2:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02026f4:	fd4d                	bnez	a0,ffffffffc02026ae <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02026f6:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02026f8:	70e2                	ld	ra,56(sp)
ffffffffc02026fa:	7442                	ld	s0,48(sp)
ffffffffc02026fc:	74a2                	ld	s1,40(sp)
ffffffffc02026fe:	7902                	ld	s2,32(sp)
ffffffffc0202700:	69e2                	ld	s3,24(sp)
ffffffffc0202702:	6a42                	ld	s4,16(sp)
ffffffffc0202704:	6aa2                	ld	s5,8(sp)
ffffffffc0202706:	6121                	addi	sp,sp,64
ffffffffc0202708:	8082                	ret
    return 0;
ffffffffc020270a:	4501                	li	a0,0
ffffffffc020270c:	b7f5                	j	ffffffffc02026f8 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc020270e:	00005697          	auipc	a3,0x5
ffffffffc0202712:	09268693          	addi	a3,a3,146 # ffffffffc02077a0 <commands+0xfd8>
ffffffffc0202716:	00004617          	auipc	a2,0x4
ffffffffc020271a:	59260613          	addi	a2,a2,1426 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020271e:	0c000593          	li	a1,192
ffffffffc0202722:	00005517          	auipc	a0,0x5
ffffffffc0202726:	fce50513          	addi	a0,a0,-50 # ffffffffc02076f0 <commands+0xf28>
ffffffffc020272a:	aedfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020272e <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc020272e:	1101                	addi	sp,sp,-32
ffffffffc0202730:	ec06                	sd	ra,24(sp)
ffffffffc0202732:	e822                	sd	s0,16(sp)
ffffffffc0202734:	e426                	sd	s1,8(sp)
ffffffffc0202736:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202738:	c531                	beqz	a0,ffffffffc0202784 <exit_mmap+0x56>
ffffffffc020273a:	591c                	lw	a5,48(a0)
ffffffffc020273c:	84aa                	mv	s1,a0
ffffffffc020273e:	e3b9                	bnez	a5,ffffffffc0202784 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202740:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0202742:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0202746:	02850663          	beq	a0,s0,ffffffffc0202772 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020274a:	ff043603          	ld	a2,-16(s0)
ffffffffc020274e:	fe843583          	ld	a1,-24(s0)
ffffffffc0202752:	854a                	mv	a0,s2
ffffffffc0202754:	a99fe0ef          	jal	ra,ffffffffc02011ec <unmap_range>
ffffffffc0202758:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020275a:	fe8498e3          	bne	s1,s0,ffffffffc020274a <exit_mmap+0x1c>
ffffffffc020275e:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0202760:	00848c63          	beq	s1,s0,ffffffffc0202778 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202764:	ff043603          	ld	a2,-16(s0)
ffffffffc0202768:	fe843583          	ld	a1,-24(s0)
ffffffffc020276c:	854a                	mv	a0,s2
ffffffffc020276e:	b97fe0ef          	jal	ra,ffffffffc0201304 <exit_range>
ffffffffc0202772:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202774:	fe8498e3          	bne	s1,s0,ffffffffc0202764 <exit_mmap+0x36>
    }
}
ffffffffc0202778:	60e2                	ld	ra,24(sp)
ffffffffc020277a:	6442                	ld	s0,16(sp)
ffffffffc020277c:	64a2                	ld	s1,8(sp)
ffffffffc020277e:	6902                	ld	s2,0(sp)
ffffffffc0202780:	6105                	addi	sp,sp,32
ffffffffc0202782:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202784:	00005697          	auipc	a3,0x5
ffffffffc0202788:	03c68693          	addi	a3,a3,60 # ffffffffc02077c0 <commands+0xff8>
ffffffffc020278c:	00004617          	auipc	a2,0x4
ffffffffc0202790:	51c60613          	addi	a2,a2,1308 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202794:	0d600593          	li	a1,214
ffffffffc0202798:	00005517          	auipc	a0,0x5
ffffffffc020279c:	f5850513          	addi	a0,a0,-168 # ffffffffc02076f0 <commands+0xf28>
ffffffffc02027a0:	a77fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02027a4 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02027a4:	7139                	addi	sp,sp,-64
ffffffffc02027a6:	f822                	sd	s0,48(sp)
ffffffffc02027a8:	f426                	sd	s1,40(sp)
ffffffffc02027aa:	fc06                	sd	ra,56(sp)
ffffffffc02027ac:	f04a                	sd	s2,32(sp)
ffffffffc02027ae:	ec4e                	sd	s3,24(sp)
ffffffffc02027b0:	e852                	sd	s4,16(sp)
ffffffffc02027b2:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02027b4:	c55ff0ef          	jal	ra,ffffffffc0202408 <mm_create>
    assert(mm != NULL);
ffffffffc02027b8:	842a                	mv	s0,a0
ffffffffc02027ba:	03200493          	li	s1,50
ffffffffc02027be:	e919                	bnez	a0,ffffffffc02027d4 <vmm_init+0x30>
ffffffffc02027c0:	a989                	j	ffffffffc0202c12 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc02027c2:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02027c4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02027c6:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02027ca:	14ed                	addi	s1,s1,-5
ffffffffc02027cc:	8522                	mv	a0,s0
ffffffffc02027ce:	cf3ff0ef          	jal	ra,ffffffffc02024c0 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02027d2:	c88d                	beqz	s1,ffffffffc0202804 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02027d4:	03000513          	li	a0,48
ffffffffc02027d8:	26c010ef          	jal	ra,ffffffffc0203a44 <kmalloc>
ffffffffc02027dc:	85aa                	mv	a1,a0
ffffffffc02027de:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02027e2:	f165                	bnez	a0,ffffffffc02027c2 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02027e4:	00005697          	auipc	a3,0x5
ffffffffc02027e8:	29c68693          	addi	a3,a3,668 # ffffffffc0207a80 <commands+0x12b8>
ffffffffc02027ec:	00004617          	auipc	a2,0x4
ffffffffc02027f0:	4bc60613          	addi	a2,a2,1212 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02027f4:	11300593          	li	a1,275
ffffffffc02027f8:	00005517          	auipc	a0,0x5
ffffffffc02027fc:	ef850513          	addi	a0,a0,-264 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202800:	a17fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0202804:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202808:	1f900913          	li	s2,505
ffffffffc020280c:	a819                	j	ffffffffc0202822 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc020280e:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202810:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202812:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202816:	0495                	addi	s1,s1,5
ffffffffc0202818:	8522                	mv	a0,s0
ffffffffc020281a:	ca7ff0ef          	jal	ra,ffffffffc02024c0 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020281e:	03248a63          	beq	s1,s2,ffffffffc0202852 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202822:	03000513          	li	a0,48
ffffffffc0202826:	21e010ef          	jal	ra,ffffffffc0203a44 <kmalloc>
ffffffffc020282a:	85aa                	mv	a1,a0
ffffffffc020282c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0202830:	fd79                	bnez	a0,ffffffffc020280e <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0202832:	00005697          	auipc	a3,0x5
ffffffffc0202836:	24e68693          	addi	a3,a3,590 # ffffffffc0207a80 <commands+0x12b8>
ffffffffc020283a:	00004617          	auipc	a2,0x4
ffffffffc020283e:	46e60613          	addi	a2,a2,1134 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202842:	11900593          	li	a1,281
ffffffffc0202846:	00005517          	auipc	a0,0x5
ffffffffc020284a:	eaa50513          	addi	a0,a0,-342 # ffffffffc02076f0 <commands+0xf28>
ffffffffc020284e:	9c9fd0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0202852:	6418                	ld	a4,8(s0)
ffffffffc0202854:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0202856:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020285a:	2ee40063          	beq	s0,a4,ffffffffc0202b3a <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020285e:	fe873603          	ld	a2,-24(a4)
ffffffffc0202862:	ffe78693          	addi	a3,a5,-2
ffffffffc0202866:	24d61a63          	bne	a2,a3,ffffffffc0202aba <vmm_init+0x316>
ffffffffc020286a:	ff073683          	ld	a3,-16(a4)
ffffffffc020286e:	24f69663          	bne	a3,a5,ffffffffc0202aba <vmm_init+0x316>
ffffffffc0202872:	0795                	addi	a5,a5,5
ffffffffc0202874:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0202876:	feb792e3          	bne	a5,a1,ffffffffc020285a <vmm_init+0xb6>
ffffffffc020287a:	491d                	li	s2,7
ffffffffc020287c:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020287e:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202882:	85a6                	mv	a1,s1
ffffffffc0202884:	8522                	mv	a0,s0
ffffffffc0202886:	bfdff0ef          	jal	ra,ffffffffc0202482 <find_vma>
ffffffffc020288a:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020288c:	30050763          	beqz	a0,ffffffffc0202b9a <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202890:	00148593          	addi	a1,s1,1
ffffffffc0202894:	8522                	mv	a0,s0
ffffffffc0202896:	bedff0ef          	jal	ra,ffffffffc0202482 <find_vma>
ffffffffc020289a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020289c:	2c050f63          	beqz	a0,ffffffffc0202b7a <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02028a0:	85ca                	mv	a1,s2
ffffffffc02028a2:	8522                	mv	a0,s0
ffffffffc02028a4:	bdfff0ef          	jal	ra,ffffffffc0202482 <find_vma>
        assert(vma3 == NULL);
ffffffffc02028a8:	2a051963          	bnez	a0,ffffffffc0202b5a <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02028ac:	00348593          	addi	a1,s1,3
ffffffffc02028b0:	8522                	mv	a0,s0
ffffffffc02028b2:	bd1ff0ef          	jal	ra,ffffffffc0202482 <find_vma>
        assert(vma4 == NULL);
ffffffffc02028b6:	32051263          	bnez	a0,ffffffffc0202bda <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02028ba:	00448593          	addi	a1,s1,4
ffffffffc02028be:	8522                	mv	a0,s0
ffffffffc02028c0:	bc3ff0ef          	jal	ra,ffffffffc0202482 <find_vma>
        assert(vma5 == NULL);
ffffffffc02028c4:	2e051b63          	bnez	a0,ffffffffc0202bba <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02028c8:	008a3783          	ld	a5,8(s4)
ffffffffc02028cc:	20979763          	bne	a5,s1,ffffffffc0202ada <vmm_init+0x336>
ffffffffc02028d0:	010a3783          	ld	a5,16(s4)
ffffffffc02028d4:	21279363          	bne	a5,s2,ffffffffc0202ada <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02028d8:	0089b783          	ld	a5,8(s3) # 1008 <_binary_obj___user_faultread_out_size-0x8568>
ffffffffc02028dc:	20979f63          	bne	a5,s1,ffffffffc0202afa <vmm_init+0x356>
ffffffffc02028e0:	0109b783          	ld	a5,16(s3)
ffffffffc02028e4:	21279b63          	bne	a5,s2,ffffffffc0202afa <vmm_init+0x356>
ffffffffc02028e8:	0495                	addi	s1,s1,5
ffffffffc02028ea:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02028ec:	f9549be3          	bne	s1,s5,ffffffffc0202882 <vmm_init+0xde>
ffffffffc02028f0:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02028f2:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02028f4:	85a6                	mv	a1,s1
ffffffffc02028f6:	8522                	mv	a0,s0
ffffffffc02028f8:	b8bff0ef          	jal	ra,ffffffffc0202482 <find_vma>
ffffffffc02028fc:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0202900:	c90d                	beqz	a0,ffffffffc0202932 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202902:	6914                	ld	a3,16(a0)
ffffffffc0202904:	6510                	ld	a2,8(a0)
ffffffffc0202906:	00005517          	auipc	a0,0x5
ffffffffc020290a:	06250513          	addi	a0,a0,98 # ffffffffc0207968 <commands+0x11a0>
ffffffffc020290e:	fc2fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202912:	00005697          	auipc	a3,0x5
ffffffffc0202916:	07e68693          	addi	a3,a3,126 # ffffffffc0207990 <commands+0x11c8>
ffffffffc020291a:	00004617          	auipc	a2,0x4
ffffffffc020291e:	38e60613          	addi	a2,a2,910 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202922:	13b00593          	li	a1,315
ffffffffc0202926:	00005517          	auipc	a0,0x5
ffffffffc020292a:	dca50513          	addi	a0,a0,-566 # ffffffffc02076f0 <commands+0xf28>
ffffffffc020292e:	8e9fd0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0202932:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0202934:	fd2490e3          	bne	s1,s2,ffffffffc02028f4 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202938:	8522                	mv	a0,s0
ffffffffc020293a:	c55ff0ef          	jal	ra,ffffffffc020258e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020293e:	00005517          	auipc	a0,0x5
ffffffffc0202942:	06a50513          	addi	a0,a0,106 # ffffffffc02079a8 <commands+0x11e0>
ffffffffc0202946:	f8afd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020294a:	e2efe0ef          	jal	ra,ffffffffc0200f78 <nr_free_pages>
ffffffffc020294e:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0202950:	ab9ff0ef          	jal	ra,ffffffffc0202408 <mm_create>
ffffffffc0202954:	000aa797          	auipc	a5,0xaa
ffffffffc0202958:	b0a7be23          	sd	a0,-1252(a5) # ffffffffc02ac470 <check_mm_struct>
ffffffffc020295c:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020295e:	36050663          	beqz	a0,ffffffffc0202cca <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202962:	000aa797          	auipc	a5,0xaa
ffffffffc0202966:	a9678793          	addi	a5,a5,-1386 # ffffffffc02ac3f8 <boot_pgdir>
ffffffffc020296a:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020296e:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202972:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202976:	2c079e63          	bnez	a5,ffffffffc0202c52 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020297a:	03000513          	li	a0,48
ffffffffc020297e:	0c6010ef          	jal	ra,ffffffffc0203a44 <kmalloc>
ffffffffc0202982:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0202984:	18050b63          	beqz	a0,ffffffffc0202b1a <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0202988:	002007b7          	lui	a5,0x200
ffffffffc020298c:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020298e:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202990:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202992:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202994:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0202996:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020299a:	b27ff0ef          	jal	ra,ffffffffc02024c0 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020299e:	10000593          	li	a1,256
ffffffffc02029a2:	8526                	mv	a0,s1
ffffffffc02029a4:	adfff0ef          	jal	ra,ffffffffc0202482 <find_vma>
ffffffffc02029a8:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02029ac:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02029b0:	2ca41163          	bne	s0,a0,ffffffffc0202c72 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc02029b4:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5588>
        sum += i;
ffffffffc02029b8:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02029ba:	fee79de3          	bne	a5,a4,ffffffffc02029b4 <vmm_init+0x210>
        sum += i;
ffffffffc02029be:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02029c0:	10000793          	li	a5,256
        sum += i;
ffffffffc02029c4:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x821a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02029c8:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02029cc:	0007c683          	lbu	a3,0(a5)
ffffffffc02029d0:	0785                	addi	a5,a5,1
ffffffffc02029d2:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02029d4:	fec79ce3          	bne	a5,a2,ffffffffc02029cc <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc02029d8:	2c071963          	bnez	a4,ffffffffc0202caa <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc02029dc:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02029e0:	000aaa97          	auipc	s5,0xaa
ffffffffc02029e4:	a20a8a93          	addi	s5,s5,-1504 # ffffffffc02ac400 <npage>
ffffffffc02029e8:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029ec:	078a                	slli	a5,a5,0x2
ffffffffc02029ee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029f0:	20e7f563          	bleu	a4,a5,ffffffffc0202bfa <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02029f4:	00006697          	auipc	a3,0x6
ffffffffc02029f8:	39c68693          	addi	a3,a3,924 # ffffffffc0208d90 <nbase>
ffffffffc02029fc:	0006ba03          	ld	s4,0(a3)
ffffffffc0202a00:	414786b3          	sub	a3,a5,s4
ffffffffc0202a04:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202a06:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a08:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202a0a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0202a0c:	83b1                	srli	a5,a5,0xc
ffffffffc0202a0e:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a10:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a12:	28e7f063          	bleu	a4,a5,ffffffffc0202c92 <vmm_init+0x4ee>
ffffffffc0202a16:	000aa797          	auipc	a5,0xaa
ffffffffc0202a1a:	a4278793          	addi	a5,a5,-1470 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0202a1e:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202a20:	4581                	li	a1,0
ffffffffc0202a22:	854a                	mv	a0,s2
ffffffffc0202a24:	9436                	add	s0,s0,a3
ffffffffc0202a26:	b35fe0ef          	jal	ra,ffffffffc020155a <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a2a:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a2c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a30:	078a                	slli	a5,a5,0x2
ffffffffc0202a32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a34:	1ce7f363          	bleu	a4,a5,ffffffffc0202bfa <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a38:	000aa417          	auipc	s0,0xaa
ffffffffc0202a3c:	a3040413          	addi	s0,s0,-1488 # ffffffffc02ac468 <pages>
ffffffffc0202a40:	6008                	ld	a0,0(s0)
ffffffffc0202a42:	414787b3          	sub	a5,a5,s4
ffffffffc0202a46:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202a48:	953e                	add	a0,a0,a5
ffffffffc0202a4a:	4585                	li	a1,1
ffffffffc0202a4c:	ce6fe0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a50:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a54:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a58:	078a                	slli	a5,a5,0x2
ffffffffc0202a5a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a5c:	18e7ff63          	bleu	a4,a5,ffffffffc0202bfa <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a60:	6008                	ld	a0,0(s0)
ffffffffc0202a62:	414787b3          	sub	a5,a5,s4
ffffffffc0202a66:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202a68:	4585                	li	a1,1
ffffffffc0202a6a:	953e                	add	a0,a0,a5
ffffffffc0202a6c:	cc6fe0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    pgdir[0] = 0;
ffffffffc0202a70:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0202a74:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0202a78:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0202a7c:	8526                	mv	a0,s1
ffffffffc0202a7e:	b11ff0ef          	jal	ra,ffffffffc020258e <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202a82:	000aa797          	auipc	a5,0xaa
ffffffffc0202a86:	9e07b723          	sd	zero,-1554(a5) # ffffffffc02ac470 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202a8a:	ceefe0ef          	jal	ra,ffffffffc0200f78 <nr_free_pages>
ffffffffc0202a8e:	1aa99263          	bne	s3,a0,ffffffffc0202c32 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202a92:	00005517          	auipc	a0,0x5
ffffffffc0202a96:	fb650513          	addi	a0,a0,-74 # ffffffffc0207a48 <commands+0x1280>
ffffffffc0202a9a:	e36fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202a9e:	7442                	ld	s0,48(sp)
ffffffffc0202aa0:	70e2                	ld	ra,56(sp)
ffffffffc0202aa2:	74a2                	ld	s1,40(sp)
ffffffffc0202aa4:	7902                	ld	s2,32(sp)
ffffffffc0202aa6:	69e2                	ld	s3,24(sp)
ffffffffc0202aa8:	6a42                	ld	s4,16(sp)
ffffffffc0202aaa:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202aac:	00005517          	auipc	a0,0x5
ffffffffc0202ab0:	fbc50513          	addi	a0,a0,-68 # ffffffffc0207a68 <commands+0x12a0>
}
ffffffffc0202ab4:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202ab6:	e1afd06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202aba:	00005697          	auipc	a3,0x5
ffffffffc0202abe:	dc668693          	addi	a3,a3,-570 # ffffffffc0207880 <commands+0x10b8>
ffffffffc0202ac2:	00004617          	auipc	a2,0x4
ffffffffc0202ac6:	1e660613          	addi	a2,a2,486 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202aca:	12200593          	li	a1,290
ffffffffc0202ace:	00005517          	auipc	a0,0x5
ffffffffc0202ad2:	c2250513          	addi	a0,a0,-990 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202ad6:	f40fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202ada:	00005697          	auipc	a3,0x5
ffffffffc0202ade:	e2e68693          	addi	a3,a3,-466 # ffffffffc0207908 <commands+0x1140>
ffffffffc0202ae2:	00004617          	auipc	a2,0x4
ffffffffc0202ae6:	1c660613          	addi	a2,a2,454 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202aea:	13200593          	li	a1,306
ffffffffc0202aee:	00005517          	auipc	a0,0x5
ffffffffc0202af2:	c0250513          	addi	a0,a0,-1022 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202af6:	f20fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202afa:	00005697          	auipc	a3,0x5
ffffffffc0202afe:	e3e68693          	addi	a3,a3,-450 # ffffffffc0207938 <commands+0x1170>
ffffffffc0202b02:	00004617          	auipc	a2,0x4
ffffffffc0202b06:	1a660613          	addi	a2,a2,422 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202b0a:	13300593          	li	a1,307
ffffffffc0202b0e:	00005517          	auipc	a0,0x5
ffffffffc0202b12:	be250513          	addi	a0,a0,-1054 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202b16:	f00fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(vma != NULL);
ffffffffc0202b1a:	00005697          	auipc	a3,0x5
ffffffffc0202b1e:	f6668693          	addi	a3,a3,-154 # ffffffffc0207a80 <commands+0x12b8>
ffffffffc0202b22:	00004617          	auipc	a2,0x4
ffffffffc0202b26:	18660613          	addi	a2,a2,390 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202b2a:	15200593          	li	a1,338
ffffffffc0202b2e:	00005517          	auipc	a0,0x5
ffffffffc0202b32:	bc250513          	addi	a0,a0,-1086 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202b36:	ee0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202b3a:	00005697          	auipc	a3,0x5
ffffffffc0202b3e:	d2e68693          	addi	a3,a3,-722 # ffffffffc0207868 <commands+0x10a0>
ffffffffc0202b42:	00004617          	auipc	a2,0x4
ffffffffc0202b46:	16660613          	addi	a2,a2,358 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202b4a:	12000593          	li	a1,288
ffffffffc0202b4e:	00005517          	auipc	a0,0x5
ffffffffc0202b52:	ba250513          	addi	a0,a0,-1118 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202b56:	ec0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma3 == NULL);
ffffffffc0202b5a:	00005697          	auipc	a3,0x5
ffffffffc0202b5e:	d7e68693          	addi	a3,a3,-642 # ffffffffc02078d8 <commands+0x1110>
ffffffffc0202b62:	00004617          	auipc	a2,0x4
ffffffffc0202b66:	14660613          	addi	a2,a2,326 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202b6a:	12c00593          	li	a1,300
ffffffffc0202b6e:	00005517          	auipc	a0,0x5
ffffffffc0202b72:	b8250513          	addi	a0,a0,-1150 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202b76:	ea0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2 != NULL);
ffffffffc0202b7a:	00005697          	auipc	a3,0x5
ffffffffc0202b7e:	d4e68693          	addi	a3,a3,-690 # ffffffffc02078c8 <commands+0x1100>
ffffffffc0202b82:	00004617          	auipc	a2,0x4
ffffffffc0202b86:	12660613          	addi	a2,a2,294 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202b8a:	12a00593          	li	a1,298
ffffffffc0202b8e:	00005517          	auipc	a0,0x5
ffffffffc0202b92:	b6250513          	addi	a0,a0,-1182 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202b96:	e80fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1 != NULL);
ffffffffc0202b9a:	00005697          	auipc	a3,0x5
ffffffffc0202b9e:	d1e68693          	addi	a3,a3,-738 # ffffffffc02078b8 <commands+0x10f0>
ffffffffc0202ba2:	00004617          	auipc	a2,0x4
ffffffffc0202ba6:	10660613          	addi	a2,a2,262 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202baa:	12800593          	li	a1,296
ffffffffc0202bae:	00005517          	auipc	a0,0x5
ffffffffc0202bb2:	b4250513          	addi	a0,a0,-1214 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202bb6:	e60fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma5 == NULL);
ffffffffc0202bba:	00005697          	auipc	a3,0x5
ffffffffc0202bbe:	d3e68693          	addi	a3,a3,-706 # ffffffffc02078f8 <commands+0x1130>
ffffffffc0202bc2:	00004617          	auipc	a2,0x4
ffffffffc0202bc6:	0e660613          	addi	a2,a2,230 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202bca:	13000593          	li	a1,304
ffffffffc0202bce:	00005517          	auipc	a0,0x5
ffffffffc0202bd2:	b2250513          	addi	a0,a0,-1246 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202bd6:	e40fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma4 == NULL);
ffffffffc0202bda:	00005697          	auipc	a3,0x5
ffffffffc0202bde:	d0e68693          	addi	a3,a3,-754 # ffffffffc02078e8 <commands+0x1120>
ffffffffc0202be2:	00004617          	auipc	a2,0x4
ffffffffc0202be6:	0c660613          	addi	a2,a2,198 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202bea:	12e00593          	li	a1,302
ffffffffc0202bee:	00005517          	auipc	a0,0x5
ffffffffc0202bf2:	b0250513          	addi	a0,a0,-1278 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202bf6:	e20fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202bfa:	00004617          	auipc	a2,0x4
ffffffffc0202bfe:	4ce60613          	addi	a2,a2,1230 # ffffffffc02070c8 <commands+0x900>
ffffffffc0202c02:	06200593          	li	a1,98
ffffffffc0202c06:	00004517          	auipc	a0,0x4
ffffffffc0202c0a:	4e250513          	addi	a0,a0,1250 # ffffffffc02070e8 <commands+0x920>
ffffffffc0202c0e:	e08fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(mm != NULL);
ffffffffc0202c12:	00005697          	auipc	a3,0x5
ffffffffc0202c16:	c4668693          	addi	a3,a3,-954 # ffffffffc0207858 <commands+0x1090>
ffffffffc0202c1a:	00004617          	auipc	a2,0x4
ffffffffc0202c1e:	08e60613          	addi	a2,a2,142 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202c22:	10c00593          	li	a1,268
ffffffffc0202c26:	00005517          	auipc	a0,0x5
ffffffffc0202c2a:	aca50513          	addi	a0,a0,-1334 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202c2e:	de8fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202c32:	00005697          	auipc	a3,0x5
ffffffffc0202c36:	dee68693          	addi	a3,a3,-530 # ffffffffc0207a20 <commands+0x1258>
ffffffffc0202c3a:	00004617          	auipc	a2,0x4
ffffffffc0202c3e:	06e60613          	addi	a2,a2,110 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202c42:	17000593          	li	a1,368
ffffffffc0202c46:	00005517          	auipc	a0,0x5
ffffffffc0202c4a:	aaa50513          	addi	a0,a0,-1366 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202c4e:	dc8fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202c52:	00005697          	auipc	a3,0x5
ffffffffc0202c56:	d8e68693          	addi	a3,a3,-626 # ffffffffc02079e0 <commands+0x1218>
ffffffffc0202c5a:	00004617          	auipc	a2,0x4
ffffffffc0202c5e:	04e60613          	addi	a2,a2,78 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202c62:	14f00593          	li	a1,335
ffffffffc0202c66:	00005517          	auipc	a0,0x5
ffffffffc0202c6a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202c6e:	da8fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202c72:	00005697          	auipc	a3,0x5
ffffffffc0202c76:	d7e68693          	addi	a3,a3,-642 # ffffffffc02079f0 <commands+0x1228>
ffffffffc0202c7a:	00004617          	auipc	a2,0x4
ffffffffc0202c7e:	02e60613          	addi	a2,a2,46 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202c82:	15700593          	li	a1,343
ffffffffc0202c86:	00005517          	auipc	a0,0x5
ffffffffc0202c8a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202c8e:	d88fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202c92:	00004617          	auipc	a2,0x4
ffffffffc0202c96:	3fe60613          	addi	a2,a2,1022 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0202c9a:	06900593          	li	a1,105
ffffffffc0202c9e:	00004517          	auipc	a0,0x4
ffffffffc0202ca2:	44a50513          	addi	a0,a0,1098 # ffffffffc02070e8 <commands+0x920>
ffffffffc0202ca6:	d70fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(sum == 0);
ffffffffc0202caa:	00005697          	auipc	a3,0x5
ffffffffc0202cae:	d6668693          	addi	a3,a3,-666 # ffffffffc0207a10 <commands+0x1248>
ffffffffc0202cb2:	00004617          	auipc	a2,0x4
ffffffffc0202cb6:	ff660613          	addi	a2,a2,-10 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202cba:	16300593          	li	a1,355
ffffffffc0202cbe:	00005517          	auipc	a0,0x5
ffffffffc0202cc2:	a3250513          	addi	a0,a0,-1486 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202cc6:	d50fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202cca:	00005697          	auipc	a3,0x5
ffffffffc0202cce:	cfe68693          	addi	a3,a3,-770 # ffffffffc02079c8 <commands+0x1200>
ffffffffc0202cd2:	00004617          	auipc	a2,0x4
ffffffffc0202cd6:	fd660613          	addi	a2,a2,-42 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0202cda:	14b00593          	li	a1,331
ffffffffc0202cde:	00005517          	auipc	a0,0x5
ffffffffc0202ce2:	a1250513          	addi	a0,a0,-1518 # ffffffffc02076f0 <commands+0xf28>
ffffffffc0202ce6:	d30fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202cea <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202cea:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202cec:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202cee:	f022                	sd	s0,32(sp)
ffffffffc0202cf0:	ec26                	sd	s1,24(sp)
ffffffffc0202cf2:	f406                	sd	ra,40(sp)
ffffffffc0202cf4:	e84a                	sd	s2,16(sp)
ffffffffc0202cf6:	8432                	mv	s0,a2
ffffffffc0202cf8:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202cfa:	f88ff0ef          	jal	ra,ffffffffc0202482 <find_vma>

    pgfault_num++;
ffffffffc0202cfe:	000a9797          	auipc	a5,0xa9
ffffffffc0202d02:	70a78793          	addi	a5,a5,1802 # ffffffffc02ac408 <pgfault_num>
ffffffffc0202d06:	439c                	lw	a5,0(a5)
ffffffffc0202d08:	2785                	addiw	a5,a5,1
ffffffffc0202d0a:	000a9717          	auipc	a4,0xa9
ffffffffc0202d0e:	6ef72f23          	sw	a5,1790(a4) # ffffffffc02ac408 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202d12:	c551                	beqz	a0,ffffffffc0202d9e <do_pgfault+0xb4>
ffffffffc0202d14:	651c                	ld	a5,8(a0)
ffffffffc0202d16:	08f46463          	bltu	s0,a5,ffffffffc0202d9e <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202d1a:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0202d1c:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202d1e:	8b89                	andi	a5,a5,2
ffffffffc0202d20:	efb1                	bnez	a5,ffffffffc0202d7c <do_pgfault+0x92>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202d22:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202d24:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202d26:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202d28:	85a2                	mv	a1,s0
ffffffffc0202d2a:	4605                	li	a2,1
ffffffffc0202d2c:	a8cfe0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc0202d30:	c941                	beqz	a0,ffffffffc0202dc0 <do_pgfault+0xd6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0202d32:	610c                	ld	a1,0(a0)
ffffffffc0202d34:	c5b1                	beqz	a1,ffffffffc0202d80 <do_pgfault+0x96>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202d36:	000a9797          	auipc	a5,0xa9
ffffffffc0202d3a:	6e278793          	addi	a5,a5,1762 # ffffffffc02ac418 <swap_init_ok>
ffffffffc0202d3e:	439c                	lw	a5,0(a5)
ffffffffc0202d40:	2781                	sext.w	a5,a5
ffffffffc0202d42:	c7bd                	beqz	a5,ffffffffc0202db0 <do_pgfault+0xc6>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc0202d44:	85a2                	mv	a1,s0
ffffffffc0202d46:	0030                	addi	a2,sp,8
ffffffffc0202d48:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0202d4a:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0202d4c:	1cd000ef          	jal	ra,ffffffffc0203718 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0202d50:	65a2                	ld	a1,8(sp)
ffffffffc0202d52:	6c88                	ld	a0,24(s1)
ffffffffc0202d54:	86ca                	mv	a3,s2
ffffffffc0202d56:	8622                	mv	a2,s0
ffffffffc0202d58:	877fe0ef          	jal	ra,ffffffffc02015ce <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0202d5c:	6622                	ld	a2,8(sp)
ffffffffc0202d5e:	4685                	li	a3,1
ffffffffc0202d60:	85a2                	mv	a1,s0
ffffffffc0202d62:	8526                	mv	a0,s1
ffffffffc0202d64:	091000ef          	jal	ra,ffffffffc02035f4 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0202d68:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0202d6a:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0202d6c:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc0202d6e:	70a2                	ld	ra,40(sp)
ffffffffc0202d70:	7402                	ld	s0,32(sp)
ffffffffc0202d72:	64e2                	ld	s1,24(sp)
ffffffffc0202d74:	6942                	ld	s2,16(sp)
ffffffffc0202d76:	853e                	mv	a0,a5
ffffffffc0202d78:	6145                	addi	sp,sp,48
ffffffffc0202d7a:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0202d7c:	495d                	li	s2,23
ffffffffc0202d7e:	b755                	j	ffffffffc0202d22 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202d80:	6c88                	ld	a0,24(s1)
ffffffffc0202d82:	864a                	mv	a2,s2
ffffffffc0202d84:	85a2                	mv	a1,s0
ffffffffc0202d86:	dcaff0ef          	jal	ra,ffffffffc0202350 <pgdir_alloc_page>
   ret = 0;
ffffffffc0202d8a:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202d8c:	f16d                	bnez	a0,ffffffffc0202d6e <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202d8e:	00005517          	auipc	a0,0x5
ffffffffc0202d92:	9c250513          	addi	a0,a0,-1598 # ffffffffc0207750 <commands+0xf88>
ffffffffc0202d96:	b3afd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d9a:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202d9c:	bfc9                	j	ffffffffc0202d6e <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202d9e:	85a2                	mv	a1,s0
ffffffffc0202da0:	00005517          	auipc	a0,0x5
ffffffffc0202da4:	96050513          	addi	a0,a0,-1696 # ffffffffc0207700 <commands+0xf38>
ffffffffc0202da8:	b28fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202dac:	57f5                	li	a5,-3
        goto failed;
ffffffffc0202dae:	b7c1                	j	ffffffffc0202d6e <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202db0:	00005517          	auipc	a0,0x5
ffffffffc0202db4:	9c850513          	addi	a0,a0,-1592 # ffffffffc0207778 <commands+0xfb0>
ffffffffc0202db8:	b18fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202dbc:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202dbe:	bf45                	j	ffffffffc0202d6e <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202dc0:	00005517          	auipc	a0,0x5
ffffffffc0202dc4:	97050513          	addi	a0,a0,-1680 # ffffffffc0207730 <commands+0xf68>
ffffffffc0202dc8:	b08fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202dcc:	57f1                	li	a5,-4
        goto failed;
ffffffffc0202dce:	b745                	j	ffffffffc0202d6e <do_pgfault+0x84>

ffffffffc0202dd0 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0202dd0:	7179                	addi	sp,sp,-48
ffffffffc0202dd2:	f022                	sd	s0,32(sp)
ffffffffc0202dd4:	f406                	sd	ra,40(sp)
ffffffffc0202dd6:	ec26                	sd	s1,24(sp)
ffffffffc0202dd8:	e84a                	sd	s2,16(sp)
ffffffffc0202dda:	e44e                	sd	s3,8(sp)
ffffffffc0202ddc:	e052                	sd	s4,0(sp)
ffffffffc0202dde:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0202de0:	c135                	beqz	a0,ffffffffc0202e44 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0202de2:	002007b7          	lui	a5,0x200
ffffffffc0202de6:	04f5e663          	bltu	a1,a5,ffffffffc0202e32 <user_mem_check+0x62>
ffffffffc0202dea:	00c584b3          	add	s1,a1,a2
ffffffffc0202dee:	0495f263          	bleu	s1,a1,ffffffffc0202e32 <user_mem_check+0x62>
ffffffffc0202df2:	4785                	li	a5,1
ffffffffc0202df4:	07fe                	slli	a5,a5,0x1f
ffffffffc0202df6:	0297ee63          	bltu	a5,s1,ffffffffc0202e32 <user_mem_check+0x62>
ffffffffc0202dfa:	892a                	mv	s2,a0
ffffffffc0202dfc:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202dfe:	6a05                	lui	s4,0x1
ffffffffc0202e00:	a821                	j	ffffffffc0202e18 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202e02:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202e06:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202e08:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202e0a:	c685                	beqz	a3,ffffffffc0202e32 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202e0c:	c399                	beqz	a5,ffffffffc0202e12 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202e0e:	02e46263          	bltu	s0,a4,ffffffffc0202e32 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0202e12:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0202e14:	04947663          	bleu	s1,s0,ffffffffc0202e60 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0202e18:	85a2                	mv	a1,s0
ffffffffc0202e1a:	854a                	mv	a0,s2
ffffffffc0202e1c:	e66ff0ef          	jal	ra,ffffffffc0202482 <find_vma>
ffffffffc0202e20:	c909                	beqz	a0,ffffffffc0202e32 <user_mem_check+0x62>
ffffffffc0202e22:	6518                	ld	a4,8(a0)
ffffffffc0202e24:	00e46763          	bltu	s0,a4,ffffffffc0202e32 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202e28:	4d1c                	lw	a5,24(a0)
ffffffffc0202e2a:	fc099ce3          	bnez	s3,ffffffffc0202e02 <user_mem_check+0x32>
ffffffffc0202e2e:	8b85                	andi	a5,a5,1
ffffffffc0202e30:	f3ed                	bnez	a5,ffffffffc0202e12 <user_mem_check+0x42>
            return 0;
ffffffffc0202e32:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0202e34:	70a2                	ld	ra,40(sp)
ffffffffc0202e36:	7402                	ld	s0,32(sp)
ffffffffc0202e38:	64e2                	ld	s1,24(sp)
ffffffffc0202e3a:	6942                	ld	s2,16(sp)
ffffffffc0202e3c:	69a2                	ld	s3,8(sp)
ffffffffc0202e3e:	6a02                	ld	s4,0(sp)
ffffffffc0202e40:	6145                	addi	sp,sp,48
ffffffffc0202e42:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0202e44:	c02007b7          	lui	a5,0xc0200
ffffffffc0202e48:	4501                	li	a0,0
ffffffffc0202e4a:	fef5e5e3          	bltu	a1,a5,ffffffffc0202e34 <user_mem_check+0x64>
ffffffffc0202e4e:	962e                	add	a2,a2,a1
ffffffffc0202e50:	fec5f2e3          	bleu	a2,a1,ffffffffc0202e34 <user_mem_check+0x64>
ffffffffc0202e54:	c8000537          	lui	a0,0xc8000
ffffffffc0202e58:	0505                	addi	a0,a0,1
ffffffffc0202e5a:	00a63533          	sltu	a0,a2,a0
ffffffffc0202e5e:	bfd9                	j	ffffffffc0202e34 <user_mem_check+0x64>
        return 1;
ffffffffc0202e60:	4505                	li	a0,1
ffffffffc0202e62:	bfc9                	j	ffffffffc0202e34 <user_mem_check+0x64>

ffffffffc0202e64 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202e64:	7135                	addi	sp,sp,-160
ffffffffc0202e66:	ed06                	sd	ra,152(sp)
ffffffffc0202e68:	e922                	sd	s0,144(sp)
ffffffffc0202e6a:	e526                	sd	s1,136(sp)
ffffffffc0202e6c:	e14a                	sd	s2,128(sp)
ffffffffc0202e6e:	fcce                	sd	s3,120(sp)
ffffffffc0202e70:	f8d2                	sd	s4,112(sp)
ffffffffc0202e72:	f4d6                	sd	s5,104(sp)
ffffffffc0202e74:	f0da                	sd	s6,96(sp)
ffffffffc0202e76:	ecde                	sd	s7,88(sp)
ffffffffc0202e78:	e8e2                	sd	s8,80(sp)
ffffffffc0202e7a:	e4e6                	sd	s9,72(sp)
ffffffffc0202e7c:	e0ea                	sd	s10,64(sp)
ffffffffc0202e7e:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202e80:	4db010ef          	jal	ra,ffffffffc0204b5a <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202e84:	000a9797          	auipc	a5,0xa9
ffffffffc0202e88:	67c78793          	addi	a5,a5,1660 # ffffffffc02ac500 <max_swap_offset>
ffffffffc0202e8c:	6394                	ld	a3,0(a5)
ffffffffc0202e8e:	010007b7          	lui	a5,0x1000
ffffffffc0202e92:	17e1                	addi	a5,a5,-8
ffffffffc0202e94:	ff968713          	addi	a4,a3,-7
ffffffffc0202e98:	4ae7ee63          	bltu	a5,a4,ffffffffc0203354 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0202e9c:	0009e797          	auipc	a5,0x9e
ffffffffc0202ea0:	0fc78793          	addi	a5,a5,252 # ffffffffc02a0f98 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202ea4:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202ea6:	000a9697          	auipc	a3,0xa9
ffffffffc0202eaa:	56f6b523          	sd	a5,1386(a3) # ffffffffc02ac410 <sm>
     int r = sm->init();
ffffffffc0202eae:	9702                	jalr	a4
ffffffffc0202eb0:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202eb2:	c10d                	beqz	a0,ffffffffc0202ed4 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202eb4:	60ea                	ld	ra,152(sp)
ffffffffc0202eb6:	644a                	ld	s0,144(sp)
ffffffffc0202eb8:	8556                	mv	a0,s5
ffffffffc0202eba:	64aa                	ld	s1,136(sp)
ffffffffc0202ebc:	690a                	ld	s2,128(sp)
ffffffffc0202ebe:	79e6                	ld	s3,120(sp)
ffffffffc0202ec0:	7a46                	ld	s4,112(sp)
ffffffffc0202ec2:	7aa6                	ld	s5,104(sp)
ffffffffc0202ec4:	7b06                	ld	s6,96(sp)
ffffffffc0202ec6:	6be6                	ld	s7,88(sp)
ffffffffc0202ec8:	6c46                	ld	s8,80(sp)
ffffffffc0202eca:	6ca6                	ld	s9,72(sp)
ffffffffc0202ecc:	6d06                	ld	s10,64(sp)
ffffffffc0202ece:	7de2                	ld	s11,56(sp)
ffffffffc0202ed0:	610d                	addi	sp,sp,160
ffffffffc0202ed2:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202ed4:	000a9797          	auipc	a5,0xa9
ffffffffc0202ed8:	53c78793          	addi	a5,a5,1340 # ffffffffc02ac410 <sm>
ffffffffc0202edc:	639c                	ld	a5,0(a5)
ffffffffc0202ede:	00005517          	auipc	a0,0x5
ffffffffc0202ee2:	c3250513          	addi	a0,a0,-974 # ffffffffc0207b10 <commands+0x1348>
ffffffffc0202ee6:	000a9417          	auipc	s0,0xa9
ffffffffc0202eea:	66a40413          	addi	s0,s0,1642 # ffffffffc02ac550 <free_area>
ffffffffc0202eee:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202ef0:	4785                	li	a5,1
ffffffffc0202ef2:	000a9717          	auipc	a4,0xa9
ffffffffc0202ef6:	52f72323          	sw	a5,1318(a4) # ffffffffc02ac418 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202efa:	9d6fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202efe:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f00:	36878e63          	beq	a5,s0,ffffffffc020327c <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202f04:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202f08:	8305                	srli	a4,a4,0x1
ffffffffc0202f0a:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202f0c:	36070c63          	beqz	a4,ffffffffc0203284 <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0202f10:	4481                	li	s1,0
ffffffffc0202f12:	4901                	li	s2,0
ffffffffc0202f14:	a031                	j	ffffffffc0202f20 <swap_init+0xbc>
ffffffffc0202f16:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202f1a:	8b09                	andi	a4,a4,2
ffffffffc0202f1c:	36070463          	beqz	a4,ffffffffc0203284 <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0202f20:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f24:	679c                	ld	a5,8(a5)
ffffffffc0202f26:	2905                	addiw	s2,s2,1
ffffffffc0202f28:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f2a:	fe8796e3          	bne	a5,s0,ffffffffc0202f16 <swap_init+0xb2>
ffffffffc0202f2e:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202f30:	848fe0ef          	jal	ra,ffffffffc0200f78 <nr_free_pages>
ffffffffc0202f34:	69351863          	bne	a0,s3,ffffffffc02035c4 <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202f38:	8626                	mv	a2,s1
ffffffffc0202f3a:	85ca                	mv	a1,s2
ffffffffc0202f3c:	00005517          	auipc	a0,0x5
ffffffffc0202f40:	c1c50513          	addi	a0,a0,-996 # ffffffffc0207b58 <commands+0x1390>
ffffffffc0202f44:	98cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202f48:	cc0ff0ef          	jal	ra,ffffffffc0202408 <mm_create>
ffffffffc0202f4c:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202f4e:	60050b63          	beqz	a0,ffffffffc0203564 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202f52:	000a9797          	auipc	a5,0xa9
ffffffffc0202f56:	51e78793          	addi	a5,a5,1310 # ffffffffc02ac470 <check_mm_struct>
ffffffffc0202f5a:	639c                	ld	a5,0(a5)
ffffffffc0202f5c:	62079463          	bnez	a5,ffffffffc0203584 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202f60:	000a9797          	auipc	a5,0xa9
ffffffffc0202f64:	49878793          	addi	a5,a5,1176 # ffffffffc02ac3f8 <boot_pgdir>
ffffffffc0202f68:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202f6c:	000a9797          	auipc	a5,0xa9
ffffffffc0202f70:	50a7b223          	sd	a0,1284(a5) # ffffffffc02ac470 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202f74:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x75588>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202f78:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202f7c:	4e079863          	bnez	a5,ffffffffc020346c <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202f80:	6599                	lui	a1,0x6
ffffffffc0202f82:	460d                	li	a2,3
ffffffffc0202f84:	6505                	lui	a0,0x1
ffffffffc0202f86:	cceff0ef          	jal	ra,ffffffffc0202454 <vma_create>
ffffffffc0202f8a:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202f8c:	50050063          	beqz	a0,ffffffffc020348c <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0202f90:	855e                	mv	a0,s7
ffffffffc0202f92:	d2eff0ef          	jal	ra,ffffffffc02024c0 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202f96:	00005517          	auipc	a0,0x5
ffffffffc0202f9a:	c0250513          	addi	a0,a0,-1022 # ffffffffc0207b98 <commands+0x13d0>
ffffffffc0202f9e:	932fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202fa2:	018bb503          	ld	a0,24(s7)
ffffffffc0202fa6:	4605                	li	a2,1
ffffffffc0202fa8:	6585                	lui	a1,0x1
ffffffffc0202faa:	80efe0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202fae:	4e050f63          	beqz	a0,ffffffffc02034ac <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202fb2:	00005517          	auipc	a0,0x5
ffffffffc0202fb6:	c3650513          	addi	a0,a0,-970 # ffffffffc0207be8 <commands+0x1420>
ffffffffc0202fba:	000a9997          	auipc	s3,0xa9
ffffffffc0202fbe:	4be98993          	addi	s3,s3,1214 # ffffffffc02ac478 <check_rp>
ffffffffc0202fc2:	90efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202fc6:	000a9a17          	auipc	s4,0xa9
ffffffffc0202fca:	4d2a0a13          	addi	s4,s4,1234 # ffffffffc02ac498 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202fce:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202fd0:	4505                	li	a0,1
ffffffffc0202fd2:	ed9fd0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0202fd6:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202fda:	32050d63          	beqz	a0,ffffffffc0203314 <swap_init+0x4b0>
ffffffffc0202fde:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202fe0:	8b89                	andi	a5,a5,2
ffffffffc0202fe2:	30079963          	bnez	a5,ffffffffc02032f4 <swap_init+0x490>
ffffffffc0202fe6:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202fe8:	ff4c14e3          	bne	s8,s4,ffffffffc0202fd0 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202fec:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202fee:	000a9c17          	auipc	s8,0xa9
ffffffffc0202ff2:	48ac0c13          	addi	s8,s8,1162 # ffffffffc02ac478 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202ff6:	ec3e                	sd	a5,24(sp)
ffffffffc0202ff8:	641c                	ld	a5,8(s0)
ffffffffc0202ffa:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202ffc:	481c                	lw	a5,16(s0)
ffffffffc0202ffe:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203000:	000a9797          	auipc	a5,0xa9
ffffffffc0203004:	5487bc23          	sd	s0,1368(a5) # ffffffffc02ac558 <free_area+0x8>
ffffffffc0203008:	000a9797          	auipc	a5,0xa9
ffffffffc020300c:	5487b423          	sd	s0,1352(a5) # ffffffffc02ac550 <free_area>
     nr_free = 0;
ffffffffc0203010:	000a9797          	auipc	a5,0xa9
ffffffffc0203014:	5407a823          	sw	zero,1360(a5) # ffffffffc02ac560 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203018:	000c3503          	ld	a0,0(s8)
ffffffffc020301c:	4585                	li	a1,1
ffffffffc020301e:	0c21                	addi	s8,s8,8
ffffffffc0203020:	f13fd0ef          	jal	ra,ffffffffc0200f32 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203024:	ff4c1ae3          	bne	s8,s4,ffffffffc0203018 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203028:	01042c03          	lw	s8,16(s0)
ffffffffc020302c:	4791                	li	a5,4
ffffffffc020302e:	50fc1b63          	bne	s8,a5,ffffffffc0203544 <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203032:	00005517          	auipc	a0,0x5
ffffffffc0203036:	c3e50513          	addi	a0,a0,-962 # ffffffffc0207c70 <commands+0x14a8>
ffffffffc020303a:	896fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020303e:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203040:	000a9797          	auipc	a5,0xa9
ffffffffc0203044:	3c07a423          	sw	zero,968(a5) # ffffffffc02ac408 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203048:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc020304a:	000a9797          	auipc	a5,0xa9
ffffffffc020304e:	3be78793          	addi	a5,a5,958 # ffffffffc02ac408 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203052:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
     assert(pgfault_num==1);
ffffffffc0203056:	4398                	lw	a4,0(a5)
ffffffffc0203058:	4585                	li	a1,1
ffffffffc020305a:	2701                	sext.w	a4,a4
ffffffffc020305c:	38b71863          	bne	a4,a1,ffffffffc02033ec <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203060:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0203064:	4394                	lw	a3,0(a5)
ffffffffc0203066:	2681                	sext.w	a3,a3
ffffffffc0203068:	3ae69263          	bne	a3,a4,ffffffffc020340c <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020306c:	6689                	lui	a3,0x2
ffffffffc020306e:	462d                	li	a2,11
ffffffffc0203070:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
     assert(pgfault_num==2);
ffffffffc0203074:	4398                	lw	a4,0(a5)
ffffffffc0203076:	4589                	li	a1,2
ffffffffc0203078:	2701                	sext.w	a4,a4
ffffffffc020307a:	2eb71963          	bne	a4,a1,ffffffffc020336c <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020307e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0203082:	4394                	lw	a3,0(a5)
ffffffffc0203084:	2681                	sext.w	a3,a3
ffffffffc0203086:	30e69363          	bne	a3,a4,ffffffffc020338c <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020308a:	668d                	lui	a3,0x3
ffffffffc020308c:	4631                	li	a2,12
ffffffffc020308e:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
     assert(pgfault_num==3);
ffffffffc0203092:	4398                	lw	a4,0(a5)
ffffffffc0203094:	458d                	li	a1,3
ffffffffc0203096:	2701                	sext.w	a4,a4
ffffffffc0203098:	30b71a63          	bne	a4,a1,ffffffffc02033ac <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020309c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02030a0:	4394                	lw	a3,0(a5)
ffffffffc02030a2:	2681                	sext.w	a3,a3
ffffffffc02030a4:	32e69463          	bne	a3,a4,ffffffffc02033cc <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02030a8:	6691                	lui	a3,0x4
ffffffffc02030aa:	4635                	li	a2,13
ffffffffc02030ac:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
     assert(pgfault_num==4);
ffffffffc02030b0:	4398                	lw	a4,0(a5)
ffffffffc02030b2:	2701                	sext.w	a4,a4
ffffffffc02030b4:	37871c63          	bne	a4,s8,ffffffffc020342c <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02030b8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02030bc:	439c                	lw	a5,0(a5)
ffffffffc02030be:	2781                	sext.w	a5,a5
ffffffffc02030c0:	38e79663          	bne	a5,a4,ffffffffc020344c <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02030c4:	481c                	lw	a5,16(s0)
ffffffffc02030c6:	40079363          	bnez	a5,ffffffffc02034cc <swap_init+0x668>
ffffffffc02030ca:	000a9797          	auipc	a5,0xa9
ffffffffc02030ce:	3ce78793          	addi	a5,a5,974 # ffffffffc02ac498 <swap_in_seq_no>
ffffffffc02030d2:	000a9717          	auipc	a4,0xa9
ffffffffc02030d6:	3ee70713          	addi	a4,a4,1006 # ffffffffc02ac4c0 <swap_out_seq_no>
ffffffffc02030da:	000a9617          	auipc	a2,0xa9
ffffffffc02030de:	3e660613          	addi	a2,a2,998 # ffffffffc02ac4c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02030e2:	56fd                	li	a3,-1
ffffffffc02030e4:	c394                	sw	a3,0(a5)
ffffffffc02030e6:	c314                	sw	a3,0(a4)
ffffffffc02030e8:	0791                	addi	a5,a5,4
ffffffffc02030ea:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02030ec:	fef61ce3          	bne	a2,a5,ffffffffc02030e4 <swap_init+0x280>
ffffffffc02030f0:	000a9697          	auipc	a3,0xa9
ffffffffc02030f4:	43068693          	addi	a3,a3,1072 # ffffffffc02ac520 <check_ptep>
ffffffffc02030f8:	000a9817          	auipc	a6,0xa9
ffffffffc02030fc:	38080813          	addi	a6,a6,896 # ffffffffc02ac478 <check_rp>
ffffffffc0203100:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203102:	000a9c97          	auipc	s9,0xa9
ffffffffc0203106:	2fec8c93          	addi	s9,s9,766 # ffffffffc02ac400 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020310a:	00006d97          	auipc	s11,0x6
ffffffffc020310e:	c86d8d93          	addi	s11,s11,-890 # ffffffffc0208d90 <nbase>
ffffffffc0203112:	000a9c17          	auipc	s8,0xa9
ffffffffc0203116:	356c0c13          	addi	s8,s8,854 # ffffffffc02ac468 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020311a:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020311e:	4601                	li	a2,0
ffffffffc0203120:	85ea                	mv	a1,s10
ffffffffc0203122:	855a                	mv	a0,s6
ffffffffc0203124:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0203126:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203128:	e91fd0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc020312c:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc020312e:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203130:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0203132:	20050163          	beqz	a0,ffffffffc0203334 <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203136:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203138:	0017f613          	andi	a2,a5,1
ffffffffc020313c:	1a060063          	beqz	a2,ffffffffc02032dc <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203140:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203144:	078a                	slli	a5,a5,0x2
ffffffffc0203146:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203148:	14c7fe63          	bleu	a2,a5,ffffffffc02032a4 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020314c:	000db703          	ld	a4,0(s11)
ffffffffc0203150:	000c3603          	ld	a2,0(s8)
ffffffffc0203154:	00083583          	ld	a1,0(a6)
ffffffffc0203158:	8f99                	sub	a5,a5,a4
ffffffffc020315a:	079a                	slli	a5,a5,0x6
ffffffffc020315c:	e43a                	sd	a4,8(sp)
ffffffffc020315e:	97b2                	add	a5,a5,a2
ffffffffc0203160:	14f59e63          	bne	a1,a5,ffffffffc02032bc <swap_init+0x458>
ffffffffc0203164:	6785                	lui	a5,0x1
ffffffffc0203166:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203168:	6795                	lui	a5,0x5
ffffffffc020316a:	06a1                	addi	a3,a3,8
ffffffffc020316c:	0821                	addi	a6,a6,8
ffffffffc020316e:	fafd16e3          	bne	s10,a5,ffffffffc020311a <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203172:	00005517          	auipc	a0,0x5
ffffffffc0203176:	bb650513          	addi	a0,a0,-1098 # ffffffffc0207d28 <commands+0x1560>
ffffffffc020317a:	f57fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc020317e:	000a9797          	auipc	a5,0xa9
ffffffffc0203182:	29278793          	addi	a5,a5,658 # ffffffffc02ac410 <sm>
ffffffffc0203186:	639c                	ld	a5,0(a5)
ffffffffc0203188:	7f9c                	ld	a5,56(a5)
ffffffffc020318a:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc020318c:	40051c63          	bnez	a0,ffffffffc02035a4 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0203190:	77a2                	ld	a5,40(sp)
ffffffffc0203192:	000a9717          	auipc	a4,0xa9
ffffffffc0203196:	3cf72723          	sw	a5,974(a4) # ffffffffc02ac560 <free_area+0x10>
     free_list = free_list_store;
ffffffffc020319a:	67e2                	ld	a5,24(sp)
ffffffffc020319c:	000a9717          	auipc	a4,0xa9
ffffffffc02031a0:	3af73a23          	sd	a5,948(a4) # ffffffffc02ac550 <free_area>
ffffffffc02031a4:	7782                	ld	a5,32(sp)
ffffffffc02031a6:	000a9717          	auipc	a4,0xa9
ffffffffc02031aa:	3af73923          	sd	a5,946(a4) # ffffffffc02ac558 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02031ae:	0009b503          	ld	a0,0(s3)
ffffffffc02031b2:	4585                	li	a1,1
ffffffffc02031b4:	09a1                	addi	s3,s3,8
ffffffffc02031b6:	d7dfd0ef          	jal	ra,ffffffffc0200f32 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02031ba:	ff499ae3          	bne	s3,s4,ffffffffc02031ae <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02031be:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02031c2:	855e                	mv	a0,s7
ffffffffc02031c4:	bcaff0ef          	jal	ra,ffffffffc020258e <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02031c8:	000a9797          	auipc	a5,0xa9
ffffffffc02031cc:	23078793          	addi	a5,a5,560 # ffffffffc02ac3f8 <boot_pgdir>
ffffffffc02031d0:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02031d2:	000a9697          	auipc	a3,0xa9
ffffffffc02031d6:	2806bf23          	sd	zero,670(a3) # ffffffffc02ac470 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02031da:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031de:	6394                	ld	a3,0(a5)
ffffffffc02031e0:	068a                	slli	a3,a3,0x2
ffffffffc02031e2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031e4:	0ce6f063          	bleu	a4,a3,ffffffffc02032a4 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02031e8:	67a2                	ld	a5,8(sp)
ffffffffc02031ea:	000c3503          	ld	a0,0(s8)
ffffffffc02031ee:	8e9d                	sub	a3,a3,a5
ffffffffc02031f0:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02031f2:	8699                	srai	a3,a3,0x6
ffffffffc02031f4:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02031f6:	57fd                	li	a5,-1
ffffffffc02031f8:	83b1                	srli	a5,a5,0xc
ffffffffc02031fa:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02031fc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031fe:	2ee7f763          	bleu	a4,a5,ffffffffc02034ec <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0203202:	000a9797          	auipc	a5,0xa9
ffffffffc0203206:	25678793          	addi	a5,a5,598 # ffffffffc02ac458 <va_pa_offset>
ffffffffc020320a:	639c                	ld	a5,0(a5)
ffffffffc020320c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020320e:	629c                	ld	a5,0(a3)
ffffffffc0203210:	078a                	slli	a5,a5,0x2
ffffffffc0203212:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203214:	08e7f863          	bleu	a4,a5,ffffffffc02032a4 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203218:	69a2                	ld	s3,8(sp)
ffffffffc020321a:	4585                	li	a1,1
ffffffffc020321c:	413787b3          	sub	a5,a5,s3
ffffffffc0203220:	079a                	slli	a5,a5,0x6
ffffffffc0203222:	953e                	add	a0,a0,a5
ffffffffc0203224:	d0ffd0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203228:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020322c:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203230:	078a                	slli	a5,a5,0x2
ffffffffc0203232:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203234:	06e7f863          	bleu	a4,a5,ffffffffc02032a4 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203238:	000c3503          	ld	a0,0(s8)
ffffffffc020323c:	413787b3          	sub	a5,a5,s3
ffffffffc0203240:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203242:	4585                	li	a1,1
ffffffffc0203244:	953e                	add	a0,a0,a5
ffffffffc0203246:	cedfd0ef          	jal	ra,ffffffffc0200f32 <free_pages>
     pgdir[0] = 0;
ffffffffc020324a:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020324e:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203252:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203254:	00878963          	beq	a5,s0,ffffffffc0203266 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203258:	ff87a703          	lw	a4,-8(a5)
ffffffffc020325c:	679c                	ld	a5,8(a5)
ffffffffc020325e:	397d                	addiw	s2,s2,-1
ffffffffc0203260:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203262:	fe879be3          	bne	a5,s0,ffffffffc0203258 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0203266:	28091f63          	bnez	s2,ffffffffc0203504 <swap_init+0x6a0>
     assert(total==0);
ffffffffc020326a:	2a049d63          	bnez	s1,ffffffffc0203524 <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc020326e:	00005517          	auipc	a0,0x5
ffffffffc0203272:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0207d78 <commands+0x15b0>
ffffffffc0203276:	e5bfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020327a:	b92d                	j	ffffffffc0202eb4 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc020327c:	4481                	li	s1,0
ffffffffc020327e:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203280:	4981                	li	s3,0
ffffffffc0203282:	b17d                	j	ffffffffc0202f30 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0203284:	00005697          	auipc	a3,0x5
ffffffffc0203288:	8a468693          	addi	a3,a3,-1884 # ffffffffc0207b28 <commands+0x1360>
ffffffffc020328c:	00004617          	auipc	a2,0x4
ffffffffc0203290:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203294:	0bc00593          	li	a1,188
ffffffffc0203298:	00005517          	auipc	a0,0x5
ffffffffc020329c:	86850513          	addi	a0,a0,-1944 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02032a0:	f77fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02032a4:	00004617          	auipc	a2,0x4
ffffffffc02032a8:	e2460613          	addi	a2,a2,-476 # ffffffffc02070c8 <commands+0x900>
ffffffffc02032ac:	06200593          	li	a1,98
ffffffffc02032b0:	00004517          	auipc	a0,0x4
ffffffffc02032b4:	e3850513          	addi	a0,a0,-456 # ffffffffc02070e8 <commands+0x920>
ffffffffc02032b8:	f5ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02032bc:	00005697          	auipc	a3,0x5
ffffffffc02032c0:	a4468693          	addi	a3,a3,-1468 # ffffffffc0207d00 <commands+0x1538>
ffffffffc02032c4:	00004617          	auipc	a2,0x4
ffffffffc02032c8:	9e460613          	addi	a2,a2,-1564 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02032cc:	0fc00593          	li	a1,252
ffffffffc02032d0:	00005517          	auipc	a0,0x5
ffffffffc02032d4:	83050513          	addi	a0,a0,-2000 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02032d8:	f3ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032dc:	00004617          	auipc	a2,0x4
ffffffffc02032e0:	fcc60613          	addi	a2,a2,-52 # ffffffffc02072a8 <commands+0xae0>
ffffffffc02032e4:	07400593          	li	a1,116
ffffffffc02032e8:	00004517          	auipc	a0,0x4
ffffffffc02032ec:	e0050513          	addi	a0,a0,-512 # ffffffffc02070e8 <commands+0x920>
ffffffffc02032f0:	f27fc0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02032f4:	00005697          	auipc	a3,0x5
ffffffffc02032f8:	93468693          	addi	a3,a3,-1740 # ffffffffc0207c28 <commands+0x1460>
ffffffffc02032fc:	00004617          	auipc	a2,0x4
ffffffffc0203300:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203304:	0dd00593          	li	a1,221
ffffffffc0203308:	00004517          	auipc	a0,0x4
ffffffffc020330c:	7f850513          	addi	a0,a0,2040 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203310:	f07fc0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203314:	00005697          	auipc	a3,0x5
ffffffffc0203318:	8fc68693          	addi	a3,a3,-1796 # ffffffffc0207c10 <commands+0x1448>
ffffffffc020331c:	00004617          	auipc	a2,0x4
ffffffffc0203320:	98c60613          	addi	a2,a2,-1652 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203324:	0dc00593          	li	a1,220
ffffffffc0203328:	00004517          	auipc	a0,0x4
ffffffffc020332c:	7d850513          	addi	a0,a0,2008 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203330:	ee7fc0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203334:	00005697          	auipc	a3,0x5
ffffffffc0203338:	9b468693          	addi	a3,a3,-1612 # ffffffffc0207ce8 <commands+0x1520>
ffffffffc020333c:	00004617          	auipc	a2,0x4
ffffffffc0203340:	96c60613          	addi	a2,a2,-1684 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203344:	0fb00593          	li	a1,251
ffffffffc0203348:	00004517          	auipc	a0,0x4
ffffffffc020334c:	7b850513          	addi	a0,a0,1976 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203350:	ec7fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203354:	00004617          	auipc	a2,0x4
ffffffffc0203358:	78c60613          	addi	a2,a2,1932 # ffffffffc0207ae0 <commands+0x1318>
ffffffffc020335c:	02800593          	li	a1,40
ffffffffc0203360:	00004517          	auipc	a0,0x4
ffffffffc0203364:	7a050513          	addi	a0,a0,1952 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203368:	eaffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc020336c:	00005697          	auipc	a3,0x5
ffffffffc0203370:	93c68693          	addi	a3,a3,-1732 # ffffffffc0207ca8 <commands+0x14e0>
ffffffffc0203374:	00004617          	auipc	a2,0x4
ffffffffc0203378:	93460613          	addi	a2,a2,-1740 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020337c:	09700593          	li	a1,151
ffffffffc0203380:	00004517          	auipc	a0,0x4
ffffffffc0203384:	78050513          	addi	a0,a0,1920 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203388:	e8ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc020338c:	00005697          	auipc	a3,0x5
ffffffffc0203390:	91c68693          	addi	a3,a3,-1764 # ffffffffc0207ca8 <commands+0x14e0>
ffffffffc0203394:	00004617          	auipc	a2,0x4
ffffffffc0203398:	91460613          	addi	a2,a2,-1772 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020339c:	09900593          	li	a1,153
ffffffffc02033a0:	00004517          	auipc	a0,0x4
ffffffffc02033a4:	76050513          	addi	a0,a0,1888 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02033a8:	e6ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc02033ac:	00005697          	auipc	a3,0x5
ffffffffc02033b0:	90c68693          	addi	a3,a3,-1780 # ffffffffc0207cb8 <commands+0x14f0>
ffffffffc02033b4:	00004617          	auipc	a2,0x4
ffffffffc02033b8:	8f460613          	addi	a2,a2,-1804 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02033bc:	09b00593          	li	a1,155
ffffffffc02033c0:	00004517          	auipc	a0,0x4
ffffffffc02033c4:	74050513          	addi	a0,a0,1856 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02033c8:	e4ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc02033cc:	00005697          	auipc	a3,0x5
ffffffffc02033d0:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0207cb8 <commands+0x14f0>
ffffffffc02033d4:	00004617          	auipc	a2,0x4
ffffffffc02033d8:	8d460613          	addi	a2,a2,-1836 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02033dc:	09d00593          	li	a1,157
ffffffffc02033e0:	00004517          	auipc	a0,0x4
ffffffffc02033e4:	72050513          	addi	a0,a0,1824 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02033e8:	e2ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc02033ec:	00005697          	auipc	a3,0x5
ffffffffc02033f0:	8ac68693          	addi	a3,a3,-1876 # ffffffffc0207c98 <commands+0x14d0>
ffffffffc02033f4:	00004617          	auipc	a2,0x4
ffffffffc02033f8:	8b460613          	addi	a2,a2,-1868 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02033fc:	09300593          	li	a1,147
ffffffffc0203400:	00004517          	auipc	a0,0x4
ffffffffc0203404:	70050513          	addi	a0,a0,1792 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203408:	e0ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc020340c:	00005697          	auipc	a3,0x5
ffffffffc0203410:	88c68693          	addi	a3,a3,-1908 # ffffffffc0207c98 <commands+0x14d0>
ffffffffc0203414:	00004617          	auipc	a2,0x4
ffffffffc0203418:	89460613          	addi	a2,a2,-1900 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020341c:	09500593          	li	a1,149
ffffffffc0203420:	00004517          	auipc	a0,0x4
ffffffffc0203424:	6e050513          	addi	a0,a0,1760 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203428:	deffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc020342c:	00005697          	auipc	a3,0x5
ffffffffc0203430:	89c68693          	addi	a3,a3,-1892 # ffffffffc0207cc8 <commands+0x1500>
ffffffffc0203434:	00004617          	auipc	a2,0x4
ffffffffc0203438:	87460613          	addi	a2,a2,-1932 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020343c:	09f00593          	li	a1,159
ffffffffc0203440:	00004517          	auipc	a0,0x4
ffffffffc0203444:	6c050513          	addi	a0,a0,1728 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203448:	dcffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc020344c:	00005697          	auipc	a3,0x5
ffffffffc0203450:	87c68693          	addi	a3,a3,-1924 # ffffffffc0207cc8 <commands+0x1500>
ffffffffc0203454:	00004617          	auipc	a2,0x4
ffffffffc0203458:	85460613          	addi	a2,a2,-1964 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020345c:	0a100593          	li	a1,161
ffffffffc0203460:	00004517          	auipc	a0,0x4
ffffffffc0203464:	6a050513          	addi	a0,a0,1696 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203468:	daffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgdir[0] == 0);
ffffffffc020346c:	00004697          	auipc	a3,0x4
ffffffffc0203470:	57468693          	addi	a3,a3,1396 # ffffffffc02079e0 <commands+0x1218>
ffffffffc0203474:	00004617          	auipc	a2,0x4
ffffffffc0203478:	83460613          	addi	a2,a2,-1996 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020347c:	0cc00593          	li	a1,204
ffffffffc0203480:	00004517          	auipc	a0,0x4
ffffffffc0203484:	68050513          	addi	a0,a0,1664 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203488:	d8ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(vma != NULL);
ffffffffc020348c:	00004697          	auipc	a3,0x4
ffffffffc0203490:	5f468693          	addi	a3,a3,1524 # ffffffffc0207a80 <commands+0x12b8>
ffffffffc0203494:	00004617          	auipc	a2,0x4
ffffffffc0203498:	81460613          	addi	a2,a2,-2028 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020349c:	0cf00593          	li	a1,207
ffffffffc02034a0:	00004517          	auipc	a0,0x4
ffffffffc02034a4:	66050513          	addi	a0,a0,1632 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02034a8:	d6ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02034ac:	00004697          	auipc	a3,0x4
ffffffffc02034b0:	72468693          	addi	a3,a3,1828 # ffffffffc0207bd0 <commands+0x1408>
ffffffffc02034b4:	00003617          	auipc	a2,0x3
ffffffffc02034b8:	7f460613          	addi	a2,a2,2036 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02034bc:	0d700593          	li	a1,215
ffffffffc02034c0:	00004517          	auipc	a0,0x4
ffffffffc02034c4:	64050513          	addi	a0,a0,1600 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02034c8:	d4ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert( nr_free == 0);         
ffffffffc02034cc:	00005697          	auipc	a3,0x5
ffffffffc02034d0:	80c68693          	addi	a3,a3,-2036 # ffffffffc0207cd8 <commands+0x1510>
ffffffffc02034d4:	00003617          	auipc	a2,0x3
ffffffffc02034d8:	7d460613          	addi	a2,a2,2004 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02034dc:	0f300593          	li	a1,243
ffffffffc02034e0:	00004517          	auipc	a0,0x4
ffffffffc02034e4:	62050513          	addi	a0,a0,1568 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02034e8:	d2ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc02034ec:	00004617          	auipc	a2,0x4
ffffffffc02034f0:	ba460613          	addi	a2,a2,-1116 # ffffffffc0207090 <commands+0x8c8>
ffffffffc02034f4:	06900593          	li	a1,105
ffffffffc02034f8:	00004517          	auipc	a0,0x4
ffffffffc02034fc:	bf050513          	addi	a0,a0,-1040 # ffffffffc02070e8 <commands+0x920>
ffffffffc0203500:	d17fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(count==0);
ffffffffc0203504:	00005697          	auipc	a3,0x5
ffffffffc0203508:	85468693          	addi	a3,a3,-1964 # ffffffffc0207d58 <commands+0x1590>
ffffffffc020350c:	00003617          	auipc	a2,0x3
ffffffffc0203510:	79c60613          	addi	a2,a2,1948 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203514:	11d00593          	li	a1,285
ffffffffc0203518:	00004517          	auipc	a0,0x4
ffffffffc020351c:	5e850513          	addi	a0,a0,1512 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203520:	cf7fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total==0);
ffffffffc0203524:	00005697          	auipc	a3,0x5
ffffffffc0203528:	84468693          	addi	a3,a3,-1980 # ffffffffc0207d68 <commands+0x15a0>
ffffffffc020352c:	00003617          	auipc	a2,0x3
ffffffffc0203530:	77c60613          	addi	a2,a2,1916 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203534:	11e00593          	li	a1,286
ffffffffc0203538:	00004517          	auipc	a0,0x4
ffffffffc020353c:	5c850513          	addi	a0,a0,1480 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203540:	cd7fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203544:	00004697          	auipc	a3,0x4
ffffffffc0203548:	70468693          	addi	a3,a3,1796 # ffffffffc0207c48 <commands+0x1480>
ffffffffc020354c:	00003617          	auipc	a2,0x3
ffffffffc0203550:	75c60613          	addi	a2,a2,1884 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203554:	0ea00593          	li	a1,234
ffffffffc0203558:	00004517          	auipc	a0,0x4
ffffffffc020355c:	5a850513          	addi	a0,a0,1448 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203560:	cb7fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(mm != NULL);
ffffffffc0203564:	00004697          	auipc	a3,0x4
ffffffffc0203568:	2f468693          	addi	a3,a3,756 # ffffffffc0207858 <commands+0x1090>
ffffffffc020356c:	00003617          	auipc	a2,0x3
ffffffffc0203570:	73c60613          	addi	a2,a2,1852 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203574:	0c400593          	li	a1,196
ffffffffc0203578:	00004517          	auipc	a0,0x4
ffffffffc020357c:	58850513          	addi	a0,a0,1416 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203580:	c97fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203584:	00004697          	auipc	a3,0x4
ffffffffc0203588:	5fc68693          	addi	a3,a3,1532 # ffffffffc0207b80 <commands+0x13b8>
ffffffffc020358c:	00003617          	auipc	a2,0x3
ffffffffc0203590:	71c60613          	addi	a2,a2,1820 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203594:	0c700593          	li	a1,199
ffffffffc0203598:	00004517          	auipc	a0,0x4
ffffffffc020359c:	56850513          	addi	a0,a0,1384 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02035a0:	c77fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(ret==0);
ffffffffc02035a4:	00004697          	auipc	a3,0x4
ffffffffc02035a8:	7ac68693          	addi	a3,a3,1964 # ffffffffc0207d50 <commands+0x1588>
ffffffffc02035ac:	00003617          	auipc	a2,0x3
ffffffffc02035b0:	6fc60613          	addi	a2,a2,1788 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02035b4:	10200593          	li	a1,258
ffffffffc02035b8:	00004517          	auipc	a0,0x4
ffffffffc02035bc:	54850513          	addi	a0,a0,1352 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02035c0:	c57fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total == nr_free_pages());
ffffffffc02035c4:	00004697          	auipc	a3,0x4
ffffffffc02035c8:	57468693          	addi	a3,a3,1396 # ffffffffc0207b38 <commands+0x1370>
ffffffffc02035cc:	00003617          	auipc	a2,0x3
ffffffffc02035d0:	6dc60613          	addi	a2,a2,1756 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02035d4:	0bf00593          	li	a1,191
ffffffffc02035d8:	00004517          	auipc	a0,0x4
ffffffffc02035dc:	52850513          	addi	a0,a0,1320 # ffffffffc0207b00 <commands+0x1338>
ffffffffc02035e0:	c37fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02035e4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02035e4:	000a9797          	auipc	a5,0xa9
ffffffffc02035e8:	e2c78793          	addi	a5,a5,-468 # ffffffffc02ac410 <sm>
ffffffffc02035ec:	639c                	ld	a5,0(a5)
ffffffffc02035ee:	0107b303          	ld	t1,16(a5)
ffffffffc02035f2:	8302                	jr	t1

ffffffffc02035f4 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02035f4:	000a9797          	auipc	a5,0xa9
ffffffffc02035f8:	e1c78793          	addi	a5,a5,-484 # ffffffffc02ac410 <sm>
ffffffffc02035fc:	639c                	ld	a5,0(a5)
ffffffffc02035fe:	0207b303          	ld	t1,32(a5)
ffffffffc0203602:	8302                	jr	t1

ffffffffc0203604 <swap_out>:
{
ffffffffc0203604:	711d                	addi	sp,sp,-96
ffffffffc0203606:	ec86                	sd	ra,88(sp)
ffffffffc0203608:	e8a2                	sd	s0,80(sp)
ffffffffc020360a:	e4a6                	sd	s1,72(sp)
ffffffffc020360c:	e0ca                	sd	s2,64(sp)
ffffffffc020360e:	fc4e                	sd	s3,56(sp)
ffffffffc0203610:	f852                	sd	s4,48(sp)
ffffffffc0203612:	f456                	sd	s5,40(sp)
ffffffffc0203614:	f05a                	sd	s6,32(sp)
ffffffffc0203616:	ec5e                	sd	s7,24(sp)
ffffffffc0203618:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc020361a:	cde9                	beqz	a1,ffffffffc02036f4 <swap_out+0xf0>
ffffffffc020361c:	8ab2                	mv	s5,a2
ffffffffc020361e:	892a                	mv	s2,a0
ffffffffc0203620:	8a2e                	mv	s4,a1
ffffffffc0203622:	4401                	li	s0,0
ffffffffc0203624:	000a9997          	auipc	s3,0xa9
ffffffffc0203628:	dec98993          	addi	s3,s3,-532 # ffffffffc02ac410 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020362c:	00004b17          	auipc	s6,0x4
ffffffffc0203630:	7ccb0b13          	addi	s6,s6,1996 # ffffffffc0207df8 <commands+0x1630>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203634:	00004b97          	auipc	s7,0x4
ffffffffc0203638:	7acb8b93          	addi	s7,s7,1964 # ffffffffc0207de0 <commands+0x1618>
ffffffffc020363c:	a825                	j	ffffffffc0203674 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020363e:	67a2                	ld	a5,8(sp)
ffffffffc0203640:	8626                	mv	a2,s1
ffffffffc0203642:	85a2                	mv	a1,s0
ffffffffc0203644:	7f94                	ld	a3,56(a5)
ffffffffc0203646:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203648:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020364a:	82b1                	srli	a3,a3,0xc
ffffffffc020364c:	0685                	addi	a3,a3,1
ffffffffc020364e:	a83fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203652:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203654:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203656:	7d1c                	ld	a5,56(a0)
ffffffffc0203658:	83b1                	srli	a5,a5,0xc
ffffffffc020365a:	0785                	addi	a5,a5,1
ffffffffc020365c:	07a2                	slli	a5,a5,0x8
ffffffffc020365e:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203662:	8d1fd0ef          	jal	ra,ffffffffc0200f32 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203666:	01893503          	ld	a0,24(s2)
ffffffffc020366a:	85a6                	mv	a1,s1
ffffffffc020366c:	cdffe0ef          	jal	ra,ffffffffc020234a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203670:	048a0d63          	beq	s4,s0,ffffffffc02036ca <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203674:	0009b783          	ld	a5,0(s3)
ffffffffc0203678:	8656                	mv	a2,s5
ffffffffc020367a:	002c                	addi	a1,sp,8
ffffffffc020367c:	7b9c                	ld	a5,48(a5)
ffffffffc020367e:	854a                	mv	a0,s2
ffffffffc0203680:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203682:	e12d                	bnez	a0,ffffffffc02036e4 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203684:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203686:	01893503          	ld	a0,24(s2)
ffffffffc020368a:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020368c:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020368e:	85a6                	mv	a1,s1
ffffffffc0203690:	929fd0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203694:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203696:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203698:	8b85                	andi	a5,a5,1
ffffffffc020369a:	cfb9                	beqz	a5,ffffffffc02036f8 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020369c:	65a2                	ld	a1,8(sp)
ffffffffc020369e:	7d9c                	ld	a5,56(a1)
ffffffffc02036a0:	83b1                	srli	a5,a5,0xc
ffffffffc02036a2:	00178513          	addi	a0,a5,1
ffffffffc02036a6:	0522                	slli	a0,a0,0x8
ffffffffc02036a8:	582010ef          	jal	ra,ffffffffc0204c2a <swapfs_write>
ffffffffc02036ac:	d949                	beqz	a0,ffffffffc020363e <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02036ae:	855e                	mv	a0,s7
ffffffffc02036b0:	a21fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02036b4:	0009b783          	ld	a5,0(s3)
ffffffffc02036b8:	6622                	ld	a2,8(sp)
ffffffffc02036ba:	4681                	li	a3,0
ffffffffc02036bc:	739c                	ld	a5,32(a5)
ffffffffc02036be:	85a6                	mv	a1,s1
ffffffffc02036c0:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02036c2:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02036c4:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02036c6:	fa8a17e3          	bne	s4,s0,ffffffffc0203674 <swap_out+0x70>
}
ffffffffc02036ca:	8522                	mv	a0,s0
ffffffffc02036cc:	60e6                	ld	ra,88(sp)
ffffffffc02036ce:	6446                	ld	s0,80(sp)
ffffffffc02036d0:	64a6                	ld	s1,72(sp)
ffffffffc02036d2:	6906                	ld	s2,64(sp)
ffffffffc02036d4:	79e2                	ld	s3,56(sp)
ffffffffc02036d6:	7a42                	ld	s4,48(sp)
ffffffffc02036d8:	7aa2                	ld	s5,40(sp)
ffffffffc02036da:	7b02                	ld	s6,32(sp)
ffffffffc02036dc:	6be2                	ld	s7,24(sp)
ffffffffc02036de:	6c42                	ld	s8,16(sp)
ffffffffc02036e0:	6125                	addi	sp,sp,96
ffffffffc02036e2:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02036e4:	85a2                	mv	a1,s0
ffffffffc02036e6:	00004517          	auipc	a0,0x4
ffffffffc02036ea:	6b250513          	addi	a0,a0,1714 # ffffffffc0207d98 <commands+0x15d0>
ffffffffc02036ee:	9e3fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc02036f2:	bfe1                	j	ffffffffc02036ca <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02036f4:	4401                	li	s0,0
ffffffffc02036f6:	bfd1                	j	ffffffffc02036ca <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02036f8:	00004697          	auipc	a3,0x4
ffffffffc02036fc:	6d068693          	addi	a3,a3,1744 # ffffffffc0207dc8 <commands+0x1600>
ffffffffc0203700:	00003617          	auipc	a2,0x3
ffffffffc0203704:	5a860613          	addi	a2,a2,1448 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203708:	06800593          	li	a1,104
ffffffffc020370c:	00004517          	auipc	a0,0x4
ffffffffc0203710:	3f450513          	addi	a0,a0,1012 # ffffffffc0207b00 <commands+0x1338>
ffffffffc0203714:	b03fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203718 <swap_in>:
{
ffffffffc0203718:	7179                	addi	sp,sp,-48
ffffffffc020371a:	e84a                	sd	s2,16(sp)
ffffffffc020371c:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc020371e:	4505                	li	a0,1
{
ffffffffc0203720:	ec26                	sd	s1,24(sp)
ffffffffc0203722:	e44e                	sd	s3,8(sp)
ffffffffc0203724:	f406                	sd	ra,40(sp)
ffffffffc0203726:	f022                	sd	s0,32(sp)
ffffffffc0203728:	84ae                	mv	s1,a1
ffffffffc020372a:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc020372c:	f7efd0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
     assert(result!=NULL);
ffffffffc0203730:	c129                	beqz	a0,ffffffffc0203772 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203732:	842a                	mv	s0,a0
ffffffffc0203734:	01893503          	ld	a0,24(s2)
ffffffffc0203738:	4601                	li	a2,0
ffffffffc020373a:	85a6                	mv	a1,s1
ffffffffc020373c:	87dfd0ef          	jal	ra,ffffffffc0200fb8 <get_pte>
ffffffffc0203740:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203742:	6108                	ld	a0,0(a0)
ffffffffc0203744:	85a2                	mv	a1,s0
ffffffffc0203746:	44c010ef          	jal	ra,ffffffffc0204b92 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc020374a:	00093583          	ld	a1,0(s2)
ffffffffc020374e:	8626                	mv	a2,s1
ffffffffc0203750:	00004517          	auipc	a0,0x4
ffffffffc0203754:	35050513          	addi	a0,a0,848 # ffffffffc0207aa0 <commands+0x12d8>
ffffffffc0203758:	81a1                	srli	a1,a1,0x8
ffffffffc020375a:	977fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc020375e:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203760:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203764:	7402                	ld	s0,32(sp)
ffffffffc0203766:	64e2                	ld	s1,24(sp)
ffffffffc0203768:	6942                	ld	s2,16(sp)
ffffffffc020376a:	69a2                	ld	s3,8(sp)
ffffffffc020376c:	4501                	li	a0,0
ffffffffc020376e:	6145                	addi	sp,sp,48
ffffffffc0203770:	8082                	ret
     assert(result!=NULL);
ffffffffc0203772:	00004697          	auipc	a3,0x4
ffffffffc0203776:	31e68693          	addi	a3,a3,798 # ffffffffc0207a90 <commands+0x12c8>
ffffffffc020377a:	00003617          	auipc	a2,0x3
ffffffffc020377e:	52e60613          	addi	a2,a2,1326 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203782:	07e00593          	li	a1,126
ffffffffc0203786:	00004517          	auipc	a0,0x4
ffffffffc020378a:	37a50513          	addi	a0,a0,890 # ffffffffc0207b00 <commands+0x1338>
ffffffffc020378e:	a89fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203792 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0203792:	c125                	beqz	a0,ffffffffc02037f2 <slob_free+0x60>
		return;

	if (size)
ffffffffc0203794:	e1a5                	bnez	a1,ffffffffc02037f4 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203796:	100027f3          	csrr	a5,sstatus
ffffffffc020379a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020379c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020379e:	e3bd                	bnez	a5,ffffffffc0203804 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02037a0:	0009e797          	auipc	a5,0x9e
ffffffffc02037a4:	83878793          	addi	a5,a5,-1992 # ffffffffc02a0fd8 <slobfree>
ffffffffc02037a8:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02037aa:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02037ac:	00a7fa63          	bleu	a0,a5,ffffffffc02037c0 <slob_free+0x2e>
ffffffffc02037b0:	00e56c63          	bltu	a0,a4,ffffffffc02037c8 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02037b4:	00e7fa63          	bleu	a4,a5,ffffffffc02037c8 <slob_free+0x36>
    return 0;
ffffffffc02037b8:	87ba                	mv	a5,a4
ffffffffc02037ba:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02037bc:	fea7eae3          	bltu	a5,a0,ffffffffc02037b0 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02037c0:	fee7ece3          	bltu	a5,a4,ffffffffc02037b8 <slob_free+0x26>
ffffffffc02037c4:	fee57ae3          	bleu	a4,a0,ffffffffc02037b8 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02037c8:	4110                	lw	a2,0(a0)
ffffffffc02037ca:	00461693          	slli	a3,a2,0x4
ffffffffc02037ce:	96aa                	add	a3,a3,a0
ffffffffc02037d0:	08d70b63          	beq	a4,a3,ffffffffc0203866 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02037d4:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02037d6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02037d8:	00469713          	slli	a4,a3,0x4
ffffffffc02037dc:	973e                	add	a4,a4,a5
ffffffffc02037de:	08e50f63          	beq	a0,a4,ffffffffc020387c <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02037e2:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02037e4:	0009d717          	auipc	a4,0x9d
ffffffffc02037e8:	7ef73a23          	sd	a5,2036(a4) # ffffffffc02a0fd8 <slobfree>
    if (flag) {
ffffffffc02037ec:	c199                	beqz	a1,ffffffffc02037f2 <slob_free+0x60>
        intr_enable();
ffffffffc02037ee:	e69fc06f          	j	ffffffffc0200656 <intr_enable>
ffffffffc02037f2:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02037f4:	05bd                	addi	a1,a1,15
ffffffffc02037f6:	8191                	srli	a1,a1,0x4
ffffffffc02037f8:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02037fa:	100027f3          	csrr	a5,sstatus
ffffffffc02037fe:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203800:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203802:	dfd9                	beqz	a5,ffffffffc02037a0 <slob_free+0xe>
{
ffffffffc0203804:	1101                	addi	sp,sp,-32
ffffffffc0203806:	e42a                	sd	a0,8(sp)
ffffffffc0203808:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020380a:	e53fc0ef          	jal	ra,ffffffffc020065c <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020380e:	0009d797          	auipc	a5,0x9d
ffffffffc0203812:	7ca78793          	addi	a5,a5,1994 # ffffffffc02a0fd8 <slobfree>
ffffffffc0203816:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0203818:	6522                	ld	a0,8(sp)
ffffffffc020381a:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020381c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020381e:	00a7fa63          	bleu	a0,a5,ffffffffc0203832 <slob_free+0xa0>
ffffffffc0203822:	00e56c63          	bltu	a0,a4,ffffffffc020383a <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203826:	00e7fa63          	bleu	a4,a5,ffffffffc020383a <slob_free+0xa8>
    return 0;
ffffffffc020382a:	87ba                	mv	a5,a4
ffffffffc020382c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020382e:	fea7eae3          	bltu	a5,a0,ffffffffc0203822 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203832:	fee7ece3          	bltu	a5,a4,ffffffffc020382a <slob_free+0x98>
ffffffffc0203836:	fee57ae3          	bleu	a4,a0,ffffffffc020382a <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc020383a:	4110                	lw	a2,0(a0)
ffffffffc020383c:	00461693          	slli	a3,a2,0x4
ffffffffc0203840:	96aa                	add	a3,a3,a0
ffffffffc0203842:	04d70763          	beq	a4,a3,ffffffffc0203890 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0203846:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0203848:	4394                	lw	a3,0(a5)
ffffffffc020384a:	00469713          	slli	a4,a3,0x4
ffffffffc020384e:	973e                	add	a4,a4,a5
ffffffffc0203850:	04e50663          	beq	a0,a4,ffffffffc020389c <slob_free+0x10a>
		cur->next = b;
ffffffffc0203854:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0203856:	0009d717          	auipc	a4,0x9d
ffffffffc020385a:	78f73123          	sd	a5,1922(a4) # ffffffffc02a0fd8 <slobfree>
    if (flag) {
ffffffffc020385e:	e58d                	bnez	a1,ffffffffc0203888 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0203860:	60e2                	ld	ra,24(sp)
ffffffffc0203862:	6105                	addi	sp,sp,32
ffffffffc0203864:	8082                	ret
		b->units += cur->next->units;
ffffffffc0203866:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0203868:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020386a:	9e35                	addw	a2,a2,a3
ffffffffc020386c:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc020386e:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0203870:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0203872:	00469713          	slli	a4,a3,0x4
ffffffffc0203876:	973e                	add	a4,a4,a5
ffffffffc0203878:	f6e515e3          	bne	a0,a4,ffffffffc02037e2 <slob_free+0x50>
		cur->units += b->units;
ffffffffc020387c:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020387e:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0203880:	9eb9                	addw	a3,a3,a4
ffffffffc0203882:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0203884:	e790                	sd	a2,8(a5)
ffffffffc0203886:	bfb9                	j	ffffffffc02037e4 <slob_free+0x52>
}
ffffffffc0203888:	60e2                	ld	ra,24(sp)
ffffffffc020388a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020388c:	dcbfc06f          	j	ffffffffc0200656 <intr_enable>
		b->units += cur->next->units;
ffffffffc0203890:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0203892:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0203894:	9e35                	addw	a2,a2,a3
ffffffffc0203896:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0203898:	e518                	sd	a4,8(a0)
ffffffffc020389a:	b77d                	j	ffffffffc0203848 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc020389c:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020389e:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02038a0:	9eb9                	addw	a3,a3,a4
ffffffffc02038a2:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02038a4:	e790                	sd	a2,8(a5)
ffffffffc02038a6:	bf45                	j	ffffffffc0203856 <slob_free+0xc4>

ffffffffc02038a8 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02038a8:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02038aa:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02038ac:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02038b0:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02038b2:	df8fd0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
  if(!page)
ffffffffc02038b6:	c139                	beqz	a0,ffffffffc02038fc <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc02038b8:	000a9797          	auipc	a5,0xa9
ffffffffc02038bc:	bb078793          	addi	a5,a5,-1104 # ffffffffc02ac468 <pages>
ffffffffc02038c0:	6394                	ld	a3,0(a5)
ffffffffc02038c2:	00005797          	auipc	a5,0x5
ffffffffc02038c6:	4ce78793          	addi	a5,a5,1230 # ffffffffc0208d90 <nbase>
    return KADDR(page2pa(page));
ffffffffc02038ca:	000a9717          	auipc	a4,0xa9
ffffffffc02038ce:	b3670713          	addi	a4,a4,-1226 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc02038d2:	40d506b3          	sub	a3,a0,a3
ffffffffc02038d6:	6388                	ld	a0,0(a5)
ffffffffc02038d8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02038da:	57fd                	li	a5,-1
ffffffffc02038dc:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02038de:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc02038e0:	83b1                	srli	a5,a5,0xc
ffffffffc02038e2:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02038e4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02038e6:	00e7ff63          	bleu	a4,a5,ffffffffc0203904 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc02038ea:	000a9797          	auipc	a5,0xa9
ffffffffc02038ee:	b6e78793          	addi	a5,a5,-1170 # ffffffffc02ac458 <va_pa_offset>
ffffffffc02038f2:	6388                	ld	a0,0(a5)
}
ffffffffc02038f4:	60a2                	ld	ra,8(sp)
ffffffffc02038f6:	9536                	add	a0,a0,a3
ffffffffc02038f8:	0141                	addi	sp,sp,16
ffffffffc02038fa:	8082                	ret
ffffffffc02038fc:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc02038fe:	4501                	li	a0,0
}
ffffffffc0203900:	0141                	addi	sp,sp,16
ffffffffc0203902:	8082                	ret
ffffffffc0203904:	00003617          	auipc	a2,0x3
ffffffffc0203908:	78c60613          	addi	a2,a2,1932 # ffffffffc0207090 <commands+0x8c8>
ffffffffc020390c:	06900593          	li	a1,105
ffffffffc0203910:	00003517          	auipc	a0,0x3
ffffffffc0203914:	7d850513          	addi	a0,a0,2008 # ffffffffc02070e8 <commands+0x920>
ffffffffc0203918:	8fffc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020391c <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc020391c:	7179                	addi	sp,sp,-48
ffffffffc020391e:	f406                	sd	ra,40(sp)
ffffffffc0203920:	f022                	sd	s0,32(sp)
ffffffffc0203922:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203924:	01050713          	addi	a4,a0,16
ffffffffc0203928:	6785                	lui	a5,0x1
ffffffffc020392a:	0cf77b63          	bleu	a5,a4,ffffffffc0203a00 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc020392e:	00f50413          	addi	s0,a0,15
ffffffffc0203932:	8011                	srli	s0,s0,0x4
ffffffffc0203934:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203936:	10002673          	csrr	a2,sstatus
ffffffffc020393a:	8a09                	andi	a2,a2,2
ffffffffc020393c:	ea5d                	bnez	a2,ffffffffc02039f2 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc020393e:	0009d497          	auipc	s1,0x9d
ffffffffc0203942:	69a48493          	addi	s1,s1,1690 # ffffffffc02a0fd8 <slobfree>
ffffffffc0203946:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203948:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020394a:	4398                	lw	a4,0(a5)
ffffffffc020394c:	0a875763          	ble	s0,a4,ffffffffc02039fa <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0203950:	00f68a63          	beq	a3,a5,ffffffffc0203964 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203954:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203956:	4118                	lw	a4,0(a0)
ffffffffc0203958:	02875763          	ble	s0,a4,ffffffffc0203986 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc020395c:	6094                	ld	a3,0(s1)
ffffffffc020395e:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0203960:	fef69ae3          	bne	a3,a5,ffffffffc0203954 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0203964:	ea39                	bnez	a2,ffffffffc02039ba <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0203966:	4501                	li	a0,0
ffffffffc0203968:	f41ff0ef          	jal	ra,ffffffffc02038a8 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc020396c:	cd29                	beqz	a0,ffffffffc02039c6 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc020396e:	6585                	lui	a1,0x1
ffffffffc0203970:	e23ff0ef          	jal	ra,ffffffffc0203792 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203974:	10002673          	csrr	a2,sstatus
ffffffffc0203978:	8a09                	andi	a2,a2,2
ffffffffc020397a:	ea1d                	bnez	a2,ffffffffc02039b0 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc020397c:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020397e:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203980:	4118                	lw	a4,0(a0)
ffffffffc0203982:	fc874de3          	blt	a4,s0,ffffffffc020395c <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0203986:	04e40663          	beq	s0,a4,ffffffffc02039d2 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc020398a:	00441693          	slli	a3,s0,0x4
ffffffffc020398e:	96aa                	add	a3,a3,a0
ffffffffc0203990:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0203992:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0203994:	9f01                	subw	a4,a4,s0
ffffffffc0203996:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0203998:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020399a:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc020399c:	0009d717          	auipc	a4,0x9d
ffffffffc02039a0:	62f73e23          	sd	a5,1596(a4) # ffffffffc02a0fd8 <slobfree>
    if (flag) {
ffffffffc02039a4:	ee15                	bnez	a2,ffffffffc02039e0 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc02039a6:	70a2                	ld	ra,40(sp)
ffffffffc02039a8:	7402                	ld	s0,32(sp)
ffffffffc02039aa:	64e2                	ld	s1,24(sp)
ffffffffc02039ac:	6145                	addi	sp,sp,48
ffffffffc02039ae:	8082                	ret
        intr_disable();
ffffffffc02039b0:	cadfc0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc02039b4:	4605                	li	a2,1
			cur = slobfree;
ffffffffc02039b6:	609c                	ld	a5,0(s1)
ffffffffc02039b8:	b7d9                	j	ffffffffc020397e <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc02039ba:	c9dfc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02039be:	4501                	li	a0,0
ffffffffc02039c0:	ee9ff0ef          	jal	ra,ffffffffc02038a8 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02039c4:	f54d                	bnez	a0,ffffffffc020396e <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc02039c6:	70a2                	ld	ra,40(sp)
ffffffffc02039c8:	7402                	ld	s0,32(sp)
ffffffffc02039ca:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc02039cc:	4501                	li	a0,0
}
ffffffffc02039ce:	6145                	addi	sp,sp,48
ffffffffc02039d0:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02039d2:	6518                	ld	a4,8(a0)
ffffffffc02039d4:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc02039d6:	0009d717          	auipc	a4,0x9d
ffffffffc02039da:	60f73123          	sd	a5,1538(a4) # ffffffffc02a0fd8 <slobfree>
    if (flag) {
ffffffffc02039de:	d661                	beqz	a2,ffffffffc02039a6 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc02039e0:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02039e2:	c75fc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc02039e6:	70a2                	ld	ra,40(sp)
ffffffffc02039e8:	7402                	ld	s0,32(sp)
ffffffffc02039ea:	6522                	ld	a0,8(sp)
ffffffffc02039ec:	64e2                	ld	s1,24(sp)
ffffffffc02039ee:	6145                	addi	sp,sp,48
ffffffffc02039f0:	8082                	ret
        intr_disable();
ffffffffc02039f2:	c6bfc0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc02039f6:	4605                	li	a2,1
ffffffffc02039f8:	b799                	j	ffffffffc020393e <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02039fa:	853e                	mv	a0,a5
ffffffffc02039fc:	87b6                	mv	a5,a3
ffffffffc02039fe:	b761                	j	ffffffffc0203986 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203a00:	00004697          	auipc	a3,0x4
ffffffffc0203a04:	45868693          	addi	a3,a3,1112 # ffffffffc0207e58 <commands+0x1690>
ffffffffc0203a08:	00003617          	auipc	a2,0x3
ffffffffc0203a0c:	2a060613          	addi	a2,a2,672 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203a10:	06400593          	li	a1,100
ffffffffc0203a14:	00004517          	auipc	a0,0x4
ffffffffc0203a18:	46450513          	addi	a0,a0,1124 # ffffffffc0207e78 <commands+0x16b0>
ffffffffc0203a1c:	ffafc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203a20 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0203a20:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0203a22:	00004517          	auipc	a0,0x4
ffffffffc0203a26:	46e50513          	addi	a0,a0,1134 # ffffffffc0207e90 <commands+0x16c8>
kmalloc_init(void) {
ffffffffc0203a2a:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0203a2c:	ea4fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0203a30:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203a32:	00004517          	auipc	a0,0x4
ffffffffc0203a36:	40650513          	addi	a0,a0,1030 # ffffffffc0207e38 <commands+0x1670>
}
ffffffffc0203a3a:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203a3c:	e94fc06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0203a40 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0203a40:	4501                	li	a0,0
ffffffffc0203a42:	8082                	ret

ffffffffc0203a44 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0203a44:	1101                	addi	sp,sp,-32
ffffffffc0203a46:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203a48:	6905                	lui	s2,0x1
{
ffffffffc0203a4a:	e822                	sd	s0,16(sp)
ffffffffc0203a4c:	ec06                	sd	ra,24(sp)
ffffffffc0203a4e:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203a50:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8581>
{
ffffffffc0203a54:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203a56:	04a7fc63          	bleu	a0,a5,ffffffffc0203aae <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0203a5a:	4561                	li	a0,24
ffffffffc0203a5c:	ec1ff0ef          	jal	ra,ffffffffc020391c <slob_alloc.isra.1.constprop.3>
ffffffffc0203a60:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0203a62:	cd21                	beqz	a0,ffffffffc0203aba <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0203a64:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0203a68:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203a6a:	00f95763          	ble	a5,s2,ffffffffc0203a78 <kmalloc+0x34>
ffffffffc0203a6e:	6705                	lui	a4,0x1
ffffffffc0203a70:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0203a72:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203a74:	fef74ee3          	blt	a4,a5,ffffffffc0203a70 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0203a78:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0203a7a:	e2fff0ef          	jal	ra,ffffffffc02038a8 <__slob_get_free_pages.isra.0>
ffffffffc0203a7e:	e488                	sd	a0,8(s1)
ffffffffc0203a80:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0203a82:	c935                	beqz	a0,ffffffffc0203af6 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203a84:	100027f3          	csrr	a5,sstatus
ffffffffc0203a88:	8b89                	andi	a5,a5,2
ffffffffc0203a8a:	e3a1                	bnez	a5,ffffffffc0203aca <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0203a8c:	000a9797          	auipc	a5,0xa9
ffffffffc0203a90:	99478793          	addi	a5,a5,-1644 # ffffffffc02ac420 <bigblocks>
ffffffffc0203a94:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203a96:	000a9717          	auipc	a4,0xa9
ffffffffc0203a9a:	98973523          	sd	s1,-1654(a4) # ffffffffc02ac420 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203a9e:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0203aa0:	8522                	mv	a0,s0
ffffffffc0203aa2:	60e2                	ld	ra,24(sp)
ffffffffc0203aa4:	6442                	ld	s0,16(sp)
ffffffffc0203aa6:	64a2                	ld	s1,8(sp)
ffffffffc0203aa8:	6902                	ld	s2,0(sp)
ffffffffc0203aaa:	6105                	addi	sp,sp,32
ffffffffc0203aac:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0203aae:	0541                	addi	a0,a0,16
ffffffffc0203ab0:	e6dff0ef          	jal	ra,ffffffffc020391c <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0203ab4:	01050413          	addi	s0,a0,16
ffffffffc0203ab8:	f565                	bnez	a0,ffffffffc0203aa0 <kmalloc+0x5c>
ffffffffc0203aba:	4401                	li	s0,0
}
ffffffffc0203abc:	8522                	mv	a0,s0
ffffffffc0203abe:	60e2                	ld	ra,24(sp)
ffffffffc0203ac0:	6442                	ld	s0,16(sp)
ffffffffc0203ac2:	64a2                	ld	s1,8(sp)
ffffffffc0203ac4:	6902                	ld	s2,0(sp)
ffffffffc0203ac6:	6105                	addi	sp,sp,32
ffffffffc0203ac8:	8082                	ret
        intr_disable();
ffffffffc0203aca:	b93fc0ef          	jal	ra,ffffffffc020065c <intr_disable>
		bb->next = bigblocks;
ffffffffc0203ace:	000a9797          	auipc	a5,0xa9
ffffffffc0203ad2:	95278793          	addi	a5,a5,-1710 # ffffffffc02ac420 <bigblocks>
ffffffffc0203ad6:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203ad8:	000a9717          	auipc	a4,0xa9
ffffffffc0203adc:	94973423          	sd	s1,-1720(a4) # ffffffffc02ac420 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203ae0:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0203ae2:	b75fc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203ae6:	6480                	ld	s0,8(s1)
}
ffffffffc0203ae8:	60e2                	ld	ra,24(sp)
ffffffffc0203aea:	64a2                	ld	s1,8(sp)
ffffffffc0203aec:	8522                	mv	a0,s0
ffffffffc0203aee:	6442                	ld	s0,16(sp)
ffffffffc0203af0:	6902                	ld	s2,0(sp)
ffffffffc0203af2:	6105                	addi	sp,sp,32
ffffffffc0203af4:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0203af6:	45e1                	li	a1,24
ffffffffc0203af8:	8526                	mv	a0,s1
ffffffffc0203afa:	c99ff0ef          	jal	ra,ffffffffc0203792 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0203afe:	b74d                	j	ffffffffc0203aa0 <kmalloc+0x5c>

ffffffffc0203b00 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0203b00:	c175                	beqz	a0,ffffffffc0203be4 <kfree+0xe4>
{
ffffffffc0203b02:	1101                	addi	sp,sp,-32
ffffffffc0203b04:	e426                	sd	s1,8(sp)
ffffffffc0203b06:	ec06                	sd	ra,24(sp)
ffffffffc0203b08:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0203b0a:	03451793          	slli	a5,a0,0x34
ffffffffc0203b0e:	84aa                	mv	s1,a0
ffffffffc0203b10:	eb8d                	bnez	a5,ffffffffc0203b42 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203b12:	100027f3          	csrr	a5,sstatus
ffffffffc0203b16:	8b89                	andi	a5,a5,2
ffffffffc0203b18:	efc9                	bnez	a5,ffffffffc0203bb2 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203b1a:	000a9797          	auipc	a5,0xa9
ffffffffc0203b1e:	90678793          	addi	a5,a5,-1786 # ffffffffc02ac420 <bigblocks>
ffffffffc0203b22:	6394                	ld	a3,0(a5)
ffffffffc0203b24:	ce99                	beqz	a3,ffffffffc0203b42 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0203b26:	669c                	ld	a5,8(a3)
ffffffffc0203b28:	6a80                	ld	s0,16(a3)
ffffffffc0203b2a:	0af50e63          	beq	a0,a5,ffffffffc0203be6 <kfree+0xe6>
    return 0;
ffffffffc0203b2e:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203b30:	c801                	beqz	s0,ffffffffc0203b40 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0203b32:	6418                	ld	a4,8(s0)
ffffffffc0203b34:	681c                	ld	a5,16(s0)
ffffffffc0203b36:	00970f63          	beq	a4,s1,ffffffffc0203b54 <kfree+0x54>
ffffffffc0203b3a:	86a2                	mv	a3,s0
ffffffffc0203b3c:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203b3e:	f875                	bnez	s0,ffffffffc0203b32 <kfree+0x32>
    if (flag) {
ffffffffc0203b40:	e659                	bnez	a2,ffffffffc0203bce <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0203b42:	6442                	ld	s0,16(sp)
ffffffffc0203b44:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203b46:	ff048513          	addi	a0,s1,-16
}
ffffffffc0203b4a:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203b4c:	4581                	li	a1,0
}
ffffffffc0203b4e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203b50:	c43ff06f          	j	ffffffffc0203792 <slob_free>
				*last = bb->next;
ffffffffc0203b54:	ea9c                	sd	a5,16(a3)
ffffffffc0203b56:	e641                	bnez	a2,ffffffffc0203bde <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0203b58:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0203b5c:	4018                	lw	a4,0(s0)
ffffffffc0203b5e:	08f4ea63          	bltu	s1,a5,ffffffffc0203bf2 <kfree+0xf2>
ffffffffc0203b62:	000a9797          	auipc	a5,0xa9
ffffffffc0203b66:	8f678793          	addi	a5,a5,-1802 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0203b6a:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203b6c:	000a9797          	auipc	a5,0xa9
ffffffffc0203b70:	89478793          	addi	a5,a5,-1900 # ffffffffc02ac400 <npage>
ffffffffc0203b74:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0203b76:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0203b78:	80b1                	srli	s1,s1,0xc
ffffffffc0203b7a:	08f4f963          	bleu	a5,s1,ffffffffc0203c0c <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b7e:	00005797          	auipc	a5,0x5
ffffffffc0203b82:	21278793          	addi	a5,a5,530 # ffffffffc0208d90 <nbase>
ffffffffc0203b86:	639c                	ld	a5,0(a5)
ffffffffc0203b88:	000a9697          	auipc	a3,0xa9
ffffffffc0203b8c:	8e068693          	addi	a3,a3,-1824 # ffffffffc02ac468 <pages>
ffffffffc0203b90:	6288                	ld	a0,0(a3)
ffffffffc0203b92:	8c9d                	sub	s1,s1,a5
ffffffffc0203b94:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0203b96:	4585                	li	a1,1
ffffffffc0203b98:	9526                	add	a0,a0,s1
ffffffffc0203b9a:	00e595bb          	sllw	a1,a1,a4
ffffffffc0203b9e:	b94fd0ef          	jal	ra,ffffffffc0200f32 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203ba2:	8522                	mv	a0,s0
}
ffffffffc0203ba4:	6442                	ld	s0,16(sp)
ffffffffc0203ba6:	60e2                	ld	ra,24(sp)
ffffffffc0203ba8:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203baa:	45e1                	li	a1,24
}
ffffffffc0203bac:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203bae:	be5ff06f          	j	ffffffffc0203792 <slob_free>
        intr_disable();
ffffffffc0203bb2:	aabfc0ef          	jal	ra,ffffffffc020065c <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203bb6:	000a9797          	auipc	a5,0xa9
ffffffffc0203bba:	86a78793          	addi	a5,a5,-1942 # ffffffffc02ac420 <bigblocks>
ffffffffc0203bbe:	6394                	ld	a3,0(a5)
ffffffffc0203bc0:	c699                	beqz	a3,ffffffffc0203bce <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0203bc2:	669c                	ld	a5,8(a3)
ffffffffc0203bc4:	6a80                	ld	s0,16(a3)
ffffffffc0203bc6:	00f48763          	beq	s1,a5,ffffffffc0203bd4 <kfree+0xd4>
        return 1;
ffffffffc0203bca:	4605                	li	a2,1
ffffffffc0203bcc:	b795                	j	ffffffffc0203b30 <kfree+0x30>
        intr_enable();
ffffffffc0203bce:	a89fc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203bd2:	bf85                	j	ffffffffc0203b42 <kfree+0x42>
				*last = bb->next;
ffffffffc0203bd4:	000a9797          	auipc	a5,0xa9
ffffffffc0203bd8:	8487b623          	sd	s0,-1972(a5) # ffffffffc02ac420 <bigblocks>
ffffffffc0203bdc:	8436                	mv	s0,a3
ffffffffc0203bde:	a79fc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203be2:	bf9d                	j	ffffffffc0203b58 <kfree+0x58>
ffffffffc0203be4:	8082                	ret
ffffffffc0203be6:	000a9797          	auipc	a5,0xa9
ffffffffc0203bea:	8287bd23          	sd	s0,-1990(a5) # ffffffffc02ac420 <bigblocks>
ffffffffc0203bee:	8436                	mv	s0,a3
ffffffffc0203bf0:	b7a5                	j	ffffffffc0203b58 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0203bf2:	86a6                	mv	a3,s1
ffffffffc0203bf4:	00003617          	auipc	a2,0x3
ffffffffc0203bf8:	57460613          	addi	a2,a2,1396 # ffffffffc0207168 <commands+0x9a0>
ffffffffc0203bfc:	06e00593          	li	a1,110
ffffffffc0203c00:	00003517          	auipc	a0,0x3
ffffffffc0203c04:	4e850513          	addi	a0,a0,1256 # ffffffffc02070e8 <commands+0x920>
ffffffffc0203c08:	e0efc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203c0c:	00003617          	auipc	a2,0x3
ffffffffc0203c10:	4bc60613          	addi	a2,a2,1212 # ffffffffc02070c8 <commands+0x900>
ffffffffc0203c14:	06200593          	li	a1,98
ffffffffc0203c18:	00003517          	auipc	a0,0x3
ffffffffc0203c1c:	4d050513          	addi	a0,a0,1232 # ffffffffc02070e8 <commands+0x920>
ffffffffc0203c20:	df6fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203c24 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203c24:	000a9797          	auipc	a5,0xa9
ffffffffc0203c28:	91c78793          	addi	a5,a5,-1764 # ffffffffc02ac540 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203c2c:	f51c                	sd	a5,40(a0)
ffffffffc0203c2e:	e79c                	sd	a5,8(a5)
ffffffffc0203c30:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203c32:	4501                	li	a0,0
ffffffffc0203c34:	8082                	ret

ffffffffc0203c36 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203c36:	4501                	li	a0,0
ffffffffc0203c38:	8082                	ret

ffffffffc0203c3a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203c3a:	4501                	li	a0,0
ffffffffc0203c3c:	8082                	ret

ffffffffc0203c3e <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203c3e:	4501                	li	a0,0
ffffffffc0203c40:	8082                	ret

ffffffffc0203c42 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203c42:	711d                	addi	sp,sp,-96
ffffffffc0203c44:	fc4e                	sd	s3,56(sp)
ffffffffc0203c46:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c48:	00004517          	auipc	a0,0x4
ffffffffc0203c4c:	26050513          	addi	a0,a0,608 # ffffffffc0207ea8 <commands+0x16e0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c50:	698d                	lui	s3,0x3
ffffffffc0203c52:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203c54:	e8a2                	sd	s0,80(sp)
ffffffffc0203c56:	e4a6                	sd	s1,72(sp)
ffffffffc0203c58:	ec86                	sd	ra,88(sp)
ffffffffc0203c5a:	e0ca                	sd	s2,64(sp)
ffffffffc0203c5c:	f456                	sd	s5,40(sp)
ffffffffc0203c5e:	f05a                	sd	s6,32(sp)
ffffffffc0203c60:	ec5e                	sd	s7,24(sp)
ffffffffc0203c62:	e862                	sd	s8,16(sp)
ffffffffc0203c64:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203c66:	000a8417          	auipc	s0,0xa8
ffffffffc0203c6a:	7a240413          	addi	s0,s0,1954 # ffffffffc02ac408 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c6e:	c62fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c72:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
    assert(pgfault_num==4);
ffffffffc0203c76:	4004                	lw	s1,0(s0)
ffffffffc0203c78:	4791                	li	a5,4
ffffffffc0203c7a:	2481                	sext.w	s1,s1
ffffffffc0203c7c:	14f49963          	bne	s1,a5,ffffffffc0203dce <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c80:	00004517          	auipc	a0,0x4
ffffffffc0203c84:	26850513          	addi	a0,a0,616 # ffffffffc0207ee8 <commands+0x1720>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c88:	6a85                	lui	s5,0x1
ffffffffc0203c8a:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c8c:	c44fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c90:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
    assert(pgfault_num==4);
ffffffffc0203c94:	00042903          	lw	s2,0(s0)
ffffffffc0203c98:	2901                	sext.w	s2,s2
ffffffffc0203c9a:	2a991a63          	bne	s2,s1,ffffffffc0203f4e <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c9e:	00004517          	auipc	a0,0x4
ffffffffc0203ca2:	27250513          	addi	a0,a0,626 # ffffffffc0207f10 <commands+0x1748>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ca6:	6b91                	lui	s7,0x4
ffffffffc0203ca8:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203caa:	c26fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203cae:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
    assert(pgfault_num==4);
ffffffffc0203cb2:	4004                	lw	s1,0(s0)
ffffffffc0203cb4:	2481                	sext.w	s1,s1
ffffffffc0203cb6:	27249c63          	bne	s1,s2,ffffffffc0203f2e <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cba:	00004517          	auipc	a0,0x4
ffffffffc0203cbe:	27e50513          	addi	a0,a0,638 # ffffffffc0207f38 <commands+0x1770>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cc2:	6909                	lui	s2,0x2
ffffffffc0203cc4:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cc6:	c0afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cca:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
    assert(pgfault_num==4);
ffffffffc0203cce:	401c                	lw	a5,0(s0)
ffffffffc0203cd0:	2781                	sext.w	a5,a5
ffffffffc0203cd2:	22979e63          	bne	a5,s1,ffffffffc0203f0e <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203cd6:	00004517          	auipc	a0,0x4
ffffffffc0203cda:	28a50513          	addi	a0,a0,650 # ffffffffc0207f60 <commands+0x1798>
ffffffffc0203cde:	bf2fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203ce2:	6795                	lui	a5,0x5
ffffffffc0203ce4:	4739                	li	a4,14
ffffffffc0203ce6:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==5);
ffffffffc0203cea:	4004                	lw	s1,0(s0)
ffffffffc0203cec:	4795                	li	a5,5
ffffffffc0203cee:	2481                	sext.w	s1,s1
ffffffffc0203cf0:	1ef49f63          	bne	s1,a5,ffffffffc0203eee <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cf4:	00004517          	auipc	a0,0x4
ffffffffc0203cf8:	24450513          	addi	a0,a0,580 # ffffffffc0207f38 <commands+0x1770>
ffffffffc0203cfc:	bd4fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d00:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203d04:	401c                	lw	a5,0(s0)
ffffffffc0203d06:	2781                	sext.w	a5,a5
ffffffffc0203d08:	1c979363          	bne	a5,s1,ffffffffc0203ece <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d0c:	00004517          	auipc	a0,0x4
ffffffffc0203d10:	1dc50513          	addi	a0,a0,476 # ffffffffc0207ee8 <commands+0x1720>
ffffffffc0203d14:	bbcfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d18:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203d1c:	401c                	lw	a5,0(s0)
ffffffffc0203d1e:	4719                	li	a4,6
ffffffffc0203d20:	2781                	sext.w	a5,a5
ffffffffc0203d22:	18e79663          	bne	a5,a4,ffffffffc0203eae <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d26:	00004517          	auipc	a0,0x4
ffffffffc0203d2a:	21250513          	addi	a0,a0,530 # ffffffffc0207f38 <commands+0x1770>
ffffffffc0203d2e:	ba2fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d32:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203d36:	401c                	lw	a5,0(s0)
ffffffffc0203d38:	471d                	li	a4,7
ffffffffc0203d3a:	2781                	sext.w	a5,a5
ffffffffc0203d3c:	14e79963          	bne	a5,a4,ffffffffc0203e8e <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d40:	00004517          	auipc	a0,0x4
ffffffffc0203d44:	16850513          	addi	a0,a0,360 # ffffffffc0207ea8 <commands+0x16e0>
ffffffffc0203d48:	b88fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d4c:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203d50:	401c                	lw	a5,0(s0)
ffffffffc0203d52:	4721                	li	a4,8
ffffffffc0203d54:	2781                	sext.w	a5,a5
ffffffffc0203d56:	10e79c63          	bne	a5,a4,ffffffffc0203e6e <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d5a:	00004517          	auipc	a0,0x4
ffffffffc0203d5e:	1b650513          	addi	a0,a0,438 # ffffffffc0207f10 <commands+0x1748>
ffffffffc0203d62:	b6efc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d66:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203d6a:	401c                	lw	a5,0(s0)
ffffffffc0203d6c:	4725                	li	a4,9
ffffffffc0203d6e:	2781                	sext.w	a5,a5
ffffffffc0203d70:	0ce79f63          	bne	a5,a4,ffffffffc0203e4e <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d74:	00004517          	auipc	a0,0x4
ffffffffc0203d78:	1ec50513          	addi	a0,a0,492 # ffffffffc0207f60 <commands+0x1798>
ffffffffc0203d7c:	b54fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d80:	6795                	lui	a5,0x5
ffffffffc0203d82:	4739                	li	a4,14
ffffffffc0203d84:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==10);
ffffffffc0203d88:	4004                	lw	s1,0(s0)
ffffffffc0203d8a:	47a9                	li	a5,10
ffffffffc0203d8c:	2481                	sext.w	s1,s1
ffffffffc0203d8e:	0af49063          	bne	s1,a5,ffffffffc0203e2e <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d92:	00004517          	auipc	a0,0x4
ffffffffc0203d96:	15650513          	addi	a0,a0,342 # ffffffffc0207ee8 <commands+0x1720>
ffffffffc0203d9a:	b36fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d9e:	6785                	lui	a5,0x1
ffffffffc0203da0:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0203da4:	06979563          	bne	a5,s1,ffffffffc0203e0e <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203da8:	401c                	lw	a5,0(s0)
ffffffffc0203daa:	472d                	li	a4,11
ffffffffc0203dac:	2781                	sext.w	a5,a5
ffffffffc0203dae:	04e79063          	bne	a5,a4,ffffffffc0203dee <_fifo_check_swap+0x1ac>
}
ffffffffc0203db2:	60e6                	ld	ra,88(sp)
ffffffffc0203db4:	6446                	ld	s0,80(sp)
ffffffffc0203db6:	64a6                	ld	s1,72(sp)
ffffffffc0203db8:	6906                	ld	s2,64(sp)
ffffffffc0203dba:	79e2                	ld	s3,56(sp)
ffffffffc0203dbc:	7a42                	ld	s4,48(sp)
ffffffffc0203dbe:	7aa2                	ld	s5,40(sp)
ffffffffc0203dc0:	7b02                	ld	s6,32(sp)
ffffffffc0203dc2:	6be2                	ld	s7,24(sp)
ffffffffc0203dc4:	6c42                	ld	s8,16(sp)
ffffffffc0203dc6:	6ca2                	ld	s9,8(sp)
ffffffffc0203dc8:	4501                	li	a0,0
ffffffffc0203dca:	6125                	addi	sp,sp,96
ffffffffc0203dcc:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203dce:	00004697          	auipc	a3,0x4
ffffffffc0203dd2:	efa68693          	addi	a3,a3,-262 # ffffffffc0207cc8 <commands+0x1500>
ffffffffc0203dd6:	00003617          	auipc	a2,0x3
ffffffffc0203dda:	ed260613          	addi	a2,a2,-302 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203dde:	05100593          	li	a1,81
ffffffffc0203de2:	00004517          	auipc	a0,0x4
ffffffffc0203de6:	0ee50513          	addi	a0,a0,238 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203dea:	c2cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==11);
ffffffffc0203dee:	00004697          	auipc	a3,0x4
ffffffffc0203df2:	22268693          	addi	a3,a3,546 # ffffffffc0208010 <commands+0x1848>
ffffffffc0203df6:	00003617          	auipc	a2,0x3
ffffffffc0203dfa:	eb260613          	addi	a2,a2,-334 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203dfe:	07300593          	li	a1,115
ffffffffc0203e02:	00004517          	auipc	a0,0x4
ffffffffc0203e06:	0ce50513          	addi	a0,a0,206 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203e0a:	c0cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e0e:	00004697          	auipc	a3,0x4
ffffffffc0203e12:	1da68693          	addi	a3,a3,474 # ffffffffc0207fe8 <commands+0x1820>
ffffffffc0203e16:	00003617          	auipc	a2,0x3
ffffffffc0203e1a:	e9260613          	addi	a2,a2,-366 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203e1e:	07100593          	li	a1,113
ffffffffc0203e22:	00004517          	auipc	a0,0x4
ffffffffc0203e26:	0ae50513          	addi	a0,a0,174 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203e2a:	becfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==10);
ffffffffc0203e2e:	00004697          	auipc	a3,0x4
ffffffffc0203e32:	1aa68693          	addi	a3,a3,426 # ffffffffc0207fd8 <commands+0x1810>
ffffffffc0203e36:	00003617          	auipc	a2,0x3
ffffffffc0203e3a:	e7260613          	addi	a2,a2,-398 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203e3e:	06f00593          	li	a1,111
ffffffffc0203e42:	00004517          	auipc	a0,0x4
ffffffffc0203e46:	08e50513          	addi	a0,a0,142 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203e4a:	bccfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==9);
ffffffffc0203e4e:	00004697          	auipc	a3,0x4
ffffffffc0203e52:	17a68693          	addi	a3,a3,378 # ffffffffc0207fc8 <commands+0x1800>
ffffffffc0203e56:	00003617          	auipc	a2,0x3
ffffffffc0203e5a:	e5260613          	addi	a2,a2,-430 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203e5e:	06c00593          	li	a1,108
ffffffffc0203e62:	00004517          	auipc	a0,0x4
ffffffffc0203e66:	06e50513          	addi	a0,a0,110 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203e6a:	bacfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==8);
ffffffffc0203e6e:	00004697          	auipc	a3,0x4
ffffffffc0203e72:	14a68693          	addi	a3,a3,330 # ffffffffc0207fb8 <commands+0x17f0>
ffffffffc0203e76:	00003617          	auipc	a2,0x3
ffffffffc0203e7a:	e3260613          	addi	a2,a2,-462 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203e7e:	06900593          	li	a1,105
ffffffffc0203e82:	00004517          	auipc	a0,0x4
ffffffffc0203e86:	04e50513          	addi	a0,a0,78 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203e8a:	b8cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==7);
ffffffffc0203e8e:	00004697          	auipc	a3,0x4
ffffffffc0203e92:	11a68693          	addi	a3,a3,282 # ffffffffc0207fa8 <commands+0x17e0>
ffffffffc0203e96:	00003617          	auipc	a2,0x3
ffffffffc0203e9a:	e1260613          	addi	a2,a2,-494 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203e9e:	06600593          	li	a1,102
ffffffffc0203ea2:	00004517          	auipc	a0,0x4
ffffffffc0203ea6:	02e50513          	addi	a0,a0,46 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203eaa:	b6cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==6);
ffffffffc0203eae:	00004697          	auipc	a3,0x4
ffffffffc0203eb2:	0ea68693          	addi	a3,a3,234 # ffffffffc0207f98 <commands+0x17d0>
ffffffffc0203eb6:	00003617          	auipc	a2,0x3
ffffffffc0203eba:	df260613          	addi	a2,a2,-526 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203ebe:	06300593          	li	a1,99
ffffffffc0203ec2:	00004517          	auipc	a0,0x4
ffffffffc0203ec6:	00e50513          	addi	a0,a0,14 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203eca:	b4cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ece:	00004697          	auipc	a3,0x4
ffffffffc0203ed2:	0ba68693          	addi	a3,a3,186 # ffffffffc0207f88 <commands+0x17c0>
ffffffffc0203ed6:	00003617          	auipc	a2,0x3
ffffffffc0203eda:	dd260613          	addi	a2,a2,-558 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203ede:	06000593          	li	a1,96
ffffffffc0203ee2:	00004517          	auipc	a0,0x4
ffffffffc0203ee6:	fee50513          	addi	a0,a0,-18 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203eea:	b2cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc0203eee:	00004697          	auipc	a3,0x4
ffffffffc0203ef2:	09a68693          	addi	a3,a3,154 # ffffffffc0207f88 <commands+0x17c0>
ffffffffc0203ef6:	00003617          	auipc	a2,0x3
ffffffffc0203efa:	db260613          	addi	a2,a2,-590 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203efe:	05d00593          	li	a1,93
ffffffffc0203f02:	00004517          	auipc	a0,0x4
ffffffffc0203f06:	fce50513          	addi	a0,a0,-50 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203f0a:	b0cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f0e:	00004697          	auipc	a3,0x4
ffffffffc0203f12:	dba68693          	addi	a3,a3,-582 # ffffffffc0207cc8 <commands+0x1500>
ffffffffc0203f16:	00003617          	auipc	a2,0x3
ffffffffc0203f1a:	d9260613          	addi	a2,a2,-622 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203f1e:	05a00593          	li	a1,90
ffffffffc0203f22:	00004517          	auipc	a0,0x4
ffffffffc0203f26:	fae50513          	addi	a0,a0,-82 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203f2a:	aecfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f2e:	00004697          	auipc	a3,0x4
ffffffffc0203f32:	d9a68693          	addi	a3,a3,-614 # ffffffffc0207cc8 <commands+0x1500>
ffffffffc0203f36:	00003617          	auipc	a2,0x3
ffffffffc0203f3a:	d7260613          	addi	a2,a2,-654 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203f3e:	05700593          	li	a1,87
ffffffffc0203f42:	00004517          	auipc	a0,0x4
ffffffffc0203f46:	f8e50513          	addi	a0,a0,-114 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203f4a:	accfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f4e:	00004697          	auipc	a3,0x4
ffffffffc0203f52:	d7a68693          	addi	a3,a3,-646 # ffffffffc0207cc8 <commands+0x1500>
ffffffffc0203f56:	00003617          	auipc	a2,0x3
ffffffffc0203f5a:	d5260613          	addi	a2,a2,-686 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203f5e:	05400593          	li	a1,84
ffffffffc0203f62:	00004517          	auipc	a0,0x4
ffffffffc0203f66:	f6e50513          	addi	a0,a0,-146 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203f6a:	aacfc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203f6e <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f6e:	751c                	ld	a5,40(a0)
{
ffffffffc0203f70:	1141                	addi	sp,sp,-16
ffffffffc0203f72:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203f74:	cf91                	beqz	a5,ffffffffc0203f90 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203f76:	ee0d                	bnez	a2,ffffffffc0203fb0 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203f78:	679c                	ld	a5,8(a5)
}
ffffffffc0203f7a:	60a2                	ld	ra,8(sp)
ffffffffc0203f7c:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f7e:	6394                	ld	a3,0(a5)
ffffffffc0203f80:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203f82:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203f86:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203f88:	e314                	sd	a3,0(a4)
ffffffffc0203f8a:	e19c                	sd	a5,0(a1)
}
ffffffffc0203f8c:	0141                	addi	sp,sp,16
ffffffffc0203f8e:	8082                	ret
         assert(head != NULL);
ffffffffc0203f90:	00004697          	auipc	a3,0x4
ffffffffc0203f94:	0b068693          	addi	a3,a3,176 # ffffffffc0208040 <commands+0x1878>
ffffffffc0203f98:	00003617          	auipc	a2,0x3
ffffffffc0203f9c:	d1060613          	addi	a2,a2,-752 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203fa0:	04100593          	li	a1,65
ffffffffc0203fa4:	00004517          	auipc	a0,0x4
ffffffffc0203fa8:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203fac:	a6afc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(in_tick==0);
ffffffffc0203fb0:	00004697          	auipc	a3,0x4
ffffffffc0203fb4:	0a068693          	addi	a3,a3,160 # ffffffffc0208050 <commands+0x1888>
ffffffffc0203fb8:	00003617          	auipc	a2,0x3
ffffffffc0203fbc:	cf060613          	addi	a2,a2,-784 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203fc0:	04200593          	li	a1,66
ffffffffc0203fc4:	00004517          	auipc	a0,0x4
ffffffffc0203fc8:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207ed0 <commands+0x1708>
ffffffffc0203fcc:	a4afc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203fd0 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203fd0:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203fd4:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203fd6:	cb09                	beqz	a4,ffffffffc0203fe8 <_fifo_map_swappable+0x18>
ffffffffc0203fd8:	cb81                	beqz	a5,ffffffffc0203fe8 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203fda:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203fdc:	e398                	sd	a4,0(a5)
}
ffffffffc0203fde:	4501                	li	a0,0
ffffffffc0203fe0:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203fe2:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203fe4:	f614                	sd	a3,40(a2)
ffffffffc0203fe6:	8082                	ret
{
ffffffffc0203fe8:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203fea:	00004697          	auipc	a3,0x4
ffffffffc0203fee:	03668693          	addi	a3,a3,54 # ffffffffc0208020 <commands+0x1858>
ffffffffc0203ff2:	00003617          	auipc	a2,0x3
ffffffffc0203ff6:	cb660613          	addi	a2,a2,-842 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0203ffa:	03200593          	li	a1,50
ffffffffc0203ffe:	00004517          	auipc	a0,0x4
ffffffffc0204002:	ed250513          	addi	a0,a0,-302 # ffffffffc0207ed0 <commands+0x1708>
{
ffffffffc0204006:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0204008:	a0efc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020400c <default_init>:
    elm->prev = elm->next = elm;
ffffffffc020400c:	000a8797          	auipc	a5,0xa8
ffffffffc0204010:	54478793          	addi	a5,a5,1348 # ffffffffc02ac550 <free_area>
ffffffffc0204014:	e79c                	sd	a5,8(a5)
ffffffffc0204016:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0204018:	0007a823          	sw	zero,16(a5)
}
ffffffffc020401c:	8082                	ret

ffffffffc020401e <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020401e:	000a8517          	auipc	a0,0xa8
ffffffffc0204022:	54256503          	lwu	a0,1346(a0) # ffffffffc02ac560 <free_area+0x10>
ffffffffc0204026:	8082                	ret

ffffffffc0204028 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0204028:	715d                	addi	sp,sp,-80
ffffffffc020402a:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc020402c:	000a8917          	auipc	s2,0xa8
ffffffffc0204030:	52490913          	addi	s2,s2,1316 # ffffffffc02ac550 <free_area>
ffffffffc0204034:	00893783          	ld	a5,8(s2)
ffffffffc0204038:	e486                	sd	ra,72(sp)
ffffffffc020403a:	e0a2                	sd	s0,64(sp)
ffffffffc020403c:	fc26                	sd	s1,56(sp)
ffffffffc020403e:	f44e                	sd	s3,40(sp)
ffffffffc0204040:	f052                	sd	s4,32(sp)
ffffffffc0204042:	ec56                	sd	s5,24(sp)
ffffffffc0204044:	e85a                	sd	s6,16(sp)
ffffffffc0204046:	e45e                	sd	s7,8(sp)
ffffffffc0204048:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020404a:	31278463          	beq	a5,s2,ffffffffc0204352 <default_check+0x32a>
ffffffffc020404e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204052:	8305                	srli	a4,a4,0x1
ffffffffc0204054:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0204056:	30070263          	beqz	a4,ffffffffc020435a <default_check+0x332>
    int count = 0, total = 0;
ffffffffc020405a:	4401                	li	s0,0
ffffffffc020405c:	4481                	li	s1,0
ffffffffc020405e:	a031                	j	ffffffffc020406a <default_check+0x42>
ffffffffc0204060:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0204064:	8b09                	andi	a4,a4,2
ffffffffc0204066:	2e070a63          	beqz	a4,ffffffffc020435a <default_check+0x332>
        count ++, total += p->property;
ffffffffc020406a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020406e:	679c                	ld	a5,8(a5)
ffffffffc0204070:	2485                	addiw	s1,s1,1
ffffffffc0204072:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204074:	ff2796e3          	bne	a5,s2,ffffffffc0204060 <default_check+0x38>
ffffffffc0204078:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc020407a:	efffc0ef          	jal	ra,ffffffffc0200f78 <nr_free_pages>
ffffffffc020407e:	73351e63          	bne	a0,s3,ffffffffc02047ba <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204082:	4505                	li	a0,1
ffffffffc0204084:	e27fc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0204088:	8a2a                	mv	s4,a0
ffffffffc020408a:	46050863          	beqz	a0,ffffffffc02044fa <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020408e:	4505                	li	a0,1
ffffffffc0204090:	e1bfc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0204094:	89aa                	mv	s3,a0
ffffffffc0204096:	74050263          	beqz	a0,ffffffffc02047da <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020409a:	4505                	li	a0,1
ffffffffc020409c:	e0ffc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02040a0:	8aaa                	mv	s5,a0
ffffffffc02040a2:	4c050c63          	beqz	a0,ffffffffc020457a <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02040a6:	2d3a0a63          	beq	s4,s3,ffffffffc020437a <default_check+0x352>
ffffffffc02040aa:	2caa0863          	beq	s4,a0,ffffffffc020437a <default_check+0x352>
ffffffffc02040ae:	2ca98663          	beq	s3,a0,ffffffffc020437a <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02040b2:	000a2783          	lw	a5,0(s4)
ffffffffc02040b6:	2e079263          	bnez	a5,ffffffffc020439a <default_check+0x372>
ffffffffc02040ba:	0009a783          	lw	a5,0(s3)
ffffffffc02040be:	2c079e63          	bnez	a5,ffffffffc020439a <default_check+0x372>
ffffffffc02040c2:	411c                	lw	a5,0(a0)
ffffffffc02040c4:	2c079b63          	bnez	a5,ffffffffc020439a <default_check+0x372>
    return page - pages + nbase;
ffffffffc02040c8:	000a8797          	auipc	a5,0xa8
ffffffffc02040cc:	3a078793          	addi	a5,a5,928 # ffffffffc02ac468 <pages>
ffffffffc02040d0:	639c                	ld	a5,0(a5)
ffffffffc02040d2:	00005717          	auipc	a4,0x5
ffffffffc02040d6:	cbe70713          	addi	a4,a4,-834 # ffffffffc0208d90 <nbase>
ffffffffc02040da:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02040dc:	000a8717          	auipc	a4,0xa8
ffffffffc02040e0:	32470713          	addi	a4,a4,804 # ffffffffc02ac400 <npage>
ffffffffc02040e4:	6314                	ld	a3,0(a4)
ffffffffc02040e6:	40fa0733          	sub	a4,s4,a5
ffffffffc02040ea:	8719                	srai	a4,a4,0x6
ffffffffc02040ec:	9732                	add	a4,a4,a2
ffffffffc02040ee:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02040f0:	0732                	slli	a4,a4,0xc
ffffffffc02040f2:	2cd77463          	bleu	a3,a4,ffffffffc02043ba <default_check+0x392>
    return page - pages + nbase;
ffffffffc02040f6:	40f98733          	sub	a4,s3,a5
ffffffffc02040fa:	8719                	srai	a4,a4,0x6
ffffffffc02040fc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02040fe:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0204100:	4ed77d63          	bleu	a3,a4,ffffffffc02045fa <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0204104:	40f507b3          	sub	a5,a0,a5
ffffffffc0204108:	8799                	srai	a5,a5,0x6
ffffffffc020410a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020410c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020410e:	34d7f663          	bleu	a3,a5,ffffffffc020445a <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0204112:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0204114:	00093c03          	ld	s8,0(s2)
ffffffffc0204118:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc020411c:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0204120:	000a8797          	auipc	a5,0xa8
ffffffffc0204124:	4327bc23          	sd	s2,1080(a5) # ffffffffc02ac558 <free_area+0x8>
ffffffffc0204128:	000a8797          	auipc	a5,0xa8
ffffffffc020412c:	4327b423          	sd	s2,1064(a5) # ffffffffc02ac550 <free_area>
    nr_free = 0;
ffffffffc0204130:	000a8797          	auipc	a5,0xa8
ffffffffc0204134:	4207a823          	sw	zero,1072(a5) # ffffffffc02ac560 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0204138:	d73fc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc020413c:	2e051f63          	bnez	a0,ffffffffc020443a <default_check+0x412>
    free_page(p0);
ffffffffc0204140:	4585                	li	a1,1
ffffffffc0204142:	8552                	mv	a0,s4
ffffffffc0204144:	deffc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    free_page(p1);
ffffffffc0204148:	4585                	li	a1,1
ffffffffc020414a:	854e                	mv	a0,s3
ffffffffc020414c:	de7fc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    free_page(p2);
ffffffffc0204150:	4585                	li	a1,1
ffffffffc0204152:	8556                	mv	a0,s5
ffffffffc0204154:	ddffc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    assert(nr_free == 3);
ffffffffc0204158:	01092703          	lw	a4,16(s2)
ffffffffc020415c:	478d                	li	a5,3
ffffffffc020415e:	2af71e63          	bne	a4,a5,ffffffffc020441a <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204162:	4505                	li	a0,1
ffffffffc0204164:	d47fc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0204168:	89aa                	mv	s3,a0
ffffffffc020416a:	28050863          	beqz	a0,ffffffffc02043fa <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020416e:	4505                	li	a0,1
ffffffffc0204170:	d3bfc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0204174:	8aaa                	mv	s5,a0
ffffffffc0204176:	3e050263          	beqz	a0,ffffffffc020455a <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020417a:	4505                	li	a0,1
ffffffffc020417c:	d2ffc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0204180:	8a2a                	mv	s4,a0
ffffffffc0204182:	3a050c63          	beqz	a0,ffffffffc020453a <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0204186:	4505                	li	a0,1
ffffffffc0204188:	d23fc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc020418c:	38051763          	bnez	a0,ffffffffc020451a <default_check+0x4f2>
    free_page(p0);
ffffffffc0204190:	4585                	li	a1,1
ffffffffc0204192:	854e                	mv	a0,s3
ffffffffc0204194:	d9ffc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0204198:	00893783          	ld	a5,8(s2)
ffffffffc020419c:	23278f63          	beq	a5,s2,ffffffffc02043da <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc02041a0:	4505                	li	a0,1
ffffffffc02041a2:	d09fc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02041a6:	32a99a63          	bne	s3,a0,ffffffffc02044da <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc02041aa:	4505                	li	a0,1
ffffffffc02041ac:	cfffc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02041b0:	30051563          	bnez	a0,ffffffffc02044ba <default_check+0x492>
    assert(nr_free == 0);
ffffffffc02041b4:	01092783          	lw	a5,16(s2)
ffffffffc02041b8:	2e079163          	bnez	a5,ffffffffc020449a <default_check+0x472>
    free_page(p);
ffffffffc02041bc:	854e                	mv	a0,s3
ffffffffc02041be:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02041c0:	000a8797          	auipc	a5,0xa8
ffffffffc02041c4:	3987b823          	sd	s8,912(a5) # ffffffffc02ac550 <free_area>
ffffffffc02041c8:	000a8797          	auipc	a5,0xa8
ffffffffc02041cc:	3977b823          	sd	s7,912(a5) # ffffffffc02ac558 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc02041d0:	000a8797          	auipc	a5,0xa8
ffffffffc02041d4:	3967a823          	sw	s6,912(a5) # ffffffffc02ac560 <free_area+0x10>
    free_page(p);
ffffffffc02041d8:	d5bfc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    free_page(p1);
ffffffffc02041dc:	4585                	li	a1,1
ffffffffc02041de:	8556                	mv	a0,s5
ffffffffc02041e0:	d53fc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    free_page(p2);
ffffffffc02041e4:	4585                	li	a1,1
ffffffffc02041e6:	8552                	mv	a0,s4
ffffffffc02041e8:	d4bfc0ef          	jal	ra,ffffffffc0200f32 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02041ec:	4515                	li	a0,5
ffffffffc02041ee:	cbdfc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02041f2:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02041f4:	28050363          	beqz	a0,ffffffffc020447a <default_check+0x452>
ffffffffc02041f8:	651c                	ld	a5,8(a0)
ffffffffc02041fa:	8385                	srli	a5,a5,0x1
ffffffffc02041fc:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02041fe:	54079e63          	bnez	a5,ffffffffc020475a <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0204202:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0204204:	00093b03          	ld	s6,0(s2)
ffffffffc0204208:	00893a83          	ld	s5,8(s2)
ffffffffc020420c:	000a8797          	auipc	a5,0xa8
ffffffffc0204210:	3527b223          	sd	s2,836(a5) # ffffffffc02ac550 <free_area>
ffffffffc0204214:	000a8797          	auipc	a5,0xa8
ffffffffc0204218:	3527b223          	sd	s2,836(a5) # ffffffffc02ac558 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc020421c:	c8ffc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0204220:	50051d63          	bnez	a0,ffffffffc020473a <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0204224:	08098a13          	addi	s4,s3,128
ffffffffc0204228:	8552                	mv	a0,s4
ffffffffc020422a:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020422c:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0204230:	000a8797          	auipc	a5,0xa8
ffffffffc0204234:	3207a823          	sw	zero,816(a5) # ffffffffc02ac560 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0204238:	cfbfc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020423c:	4511                	li	a0,4
ffffffffc020423e:	c6dfc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0204242:	4c051c63          	bnez	a0,ffffffffc020471a <default_check+0x6f2>
ffffffffc0204246:	0889b783          	ld	a5,136(s3)
ffffffffc020424a:	8385                	srli	a5,a5,0x1
ffffffffc020424c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020424e:	4a078663          	beqz	a5,ffffffffc02046fa <default_check+0x6d2>
ffffffffc0204252:	0909a703          	lw	a4,144(s3)
ffffffffc0204256:	478d                	li	a5,3
ffffffffc0204258:	4af71163          	bne	a4,a5,ffffffffc02046fa <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020425c:	450d                	li	a0,3
ffffffffc020425e:	c4dfc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0204262:	8c2a                	mv	s8,a0
ffffffffc0204264:	46050b63          	beqz	a0,ffffffffc02046da <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0204268:	4505                	li	a0,1
ffffffffc020426a:	c41fc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc020426e:	44051663          	bnez	a0,ffffffffc02046ba <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0204272:	438a1463          	bne	s4,s8,ffffffffc020469a <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0204276:	4585                	li	a1,1
ffffffffc0204278:	854e                	mv	a0,s3
ffffffffc020427a:	cb9fc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    free_pages(p1, 3);
ffffffffc020427e:	458d                	li	a1,3
ffffffffc0204280:	8552                	mv	a0,s4
ffffffffc0204282:	cb1fc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
ffffffffc0204286:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020428a:	04098c13          	addi	s8,s3,64
ffffffffc020428e:	8385                	srli	a5,a5,0x1
ffffffffc0204290:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204292:	3e078463          	beqz	a5,ffffffffc020467a <default_check+0x652>
ffffffffc0204296:	0109a703          	lw	a4,16(s3)
ffffffffc020429a:	4785                	li	a5,1
ffffffffc020429c:	3cf71f63          	bne	a4,a5,ffffffffc020467a <default_check+0x652>
ffffffffc02042a0:	008a3783          	ld	a5,8(s4)
ffffffffc02042a4:	8385                	srli	a5,a5,0x1
ffffffffc02042a6:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02042a8:	3a078963          	beqz	a5,ffffffffc020465a <default_check+0x632>
ffffffffc02042ac:	010a2703          	lw	a4,16(s4)
ffffffffc02042b0:	478d                	li	a5,3
ffffffffc02042b2:	3af71463          	bne	a4,a5,ffffffffc020465a <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02042b6:	4505                	li	a0,1
ffffffffc02042b8:	bf3fc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02042bc:	36a99f63          	bne	s3,a0,ffffffffc020463a <default_check+0x612>
    free_page(p0);
ffffffffc02042c0:	4585                	li	a1,1
ffffffffc02042c2:	c71fc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02042c6:	4509                	li	a0,2
ffffffffc02042c8:	be3fc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02042cc:	34aa1763          	bne	s4,a0,ffffffffc020461a <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc02042d0:	4589                	li	a1,2
ffffffffc02042d2:	c61fc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    free_page(p2);
ffffffffc02042d6:	4585                	li	a1,1
ffffffffc02042d8:	8562                	mv	a0,s8
ffffffffc02042da:	c59fc0ef          	jal	ra,ffffffffc0200f32 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02042de:	4515                	li	a0,5
ffffffffc02042e0:	bcbfc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02042e4:	89aa                	mv	s3,a0
ffffffffc02042e6:	48050a63          	beqz	a0,ffffffffc020477a <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc02042ea:	4505                	li	a0,1
ffffffffc02042ec:	bbffc0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc02042f0:	2e051563          	bnez	a0,ffffffffc02045da <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc02042f4:	01092783          	lw	a5,16(s2)
ffffffffc02042f8:	2c079163          	bnez	a5,ffffffffc02045ba <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02042fc:	4595                	li	a1,5
ffffffffc02042fe:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0204300:	000a8797          	auipc	a5,0xa8
ffffffffc0204304:	2777a023          	sw	s7,608(a5) # ffffffffc02ac560 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0204308:	000a8797          	auipc	a5,0xa8
ffffffffc020430c:	2567b423          	sd	s6,584(a5) # ffffffffc02ac550 <free_area>
ffffffffc0204310:	000a8797          	auipc	a5,0xa8
ffffffffc0204314:	2557b423          	sd	s5,584(a5) # ffffffffc02ac558 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0204318:	c1bfc0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    return listelm->next;
ffffffffc020431c:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204320:	01278963          	beq	a5,s2,ffffffffc0204332 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0204324:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204328:	679c                	ld	a5,8(a5)
ffffffffc020432a:	34fd                	addiw	s1,s1,-1
ffffffffc020432c:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020432e:	ff279be3          	bne	a5,s2,ffffffffc0204324 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0204332:	26049463          	bnez	s1,ffffffffc020459a <default_check+0x572>
    assert(total == 0);
ffffffffc0204336:	46041263          	bnez	s0,ffffffffc020479a <default_check+0x772>
}
ffffffffc020433a:	60a6                	ld	ra,72(sp)
ffffffffc020433c:	6406                	ld	s0,64(sp)
ffffffffc020433e:	74e2                	ld	s1,56(sp)
ffffffffc0204340:	7942                	ld	s2,48(sp)
ffffffffc0204342:	79a2                	ld	s3,40(sp)
ffffffffc0204344:	7a02                	ld	s4,32(sp)
ffffffffc0204346:	6ae2                	ld	s5,24(sp)
ffffffffc0204348:	6b42                	ld	s6,16(sp)
ffffffffc020434a:	6ba2                	ld	s7,8(sp)
ffffffffc020434c:	6c02                	ld	s8,0(sp)
ffffffffc020434e:	6161                	addi	sp,sp,80
ffffffffc0204350:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204352:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0204354:	4401                	li	s0,0
ffffffffc0204356:	4481                	li	s1,0
ffffffffc0204358:	b30d                	j	ffffffffc020407a <default_check+0x52>
        assert(PageProperty(p));
ffffffffc020435a:	00003697          	auipc	a3,0x3
ffffffffc020435e:	7ce68693          	addi	a3,a3,1998 # ffffffffc0207b28 <commands+0x1360>
ffffffffc0204362:	00003617          	auipc	a2,0x3
ffffffffc0204366:	94660613          	addi	a2,a2,-1722 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020436a:	0f000593          	li	a1,240
ffffffffc020436e:	00004517          	auipc	a0,0x4
ffffffffc0204372:	d0a50513          	addi	a0,a0,-758 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204376:	ea1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020437a:	00004697          	auipc	a3,0x4
ffffffffc020437e:	d7668693          	addi	a3,a3,-650 # ffffffffc02080f0 <commands+0x1928>
ffffffffc0204382:	00003617          	auipc	a2,0x3
ffffffffc0204386:	92660613          	addi	a2,a2,-1754 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020438a:	0bd00593          	li	a1,189
ffffffffc020438e:	00004517          	auipc	a0,0x4
ffffffffc0204392:	cea50513          	addi	a0,a0,-790 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204396:	e81fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020439a:	00004697          	auipc	a3,0x4
ffffffffc020439e:	d7e68693          	addi	a3,a3,-642 # ffffffffc0208118 <commands+0x1950>
ffffffffc02043a2:	00003617          	auipc	a2,0x3
ffffffffc02043a6:	90660613          	addi	a2,a2,-1786 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02043aa:	0be00593          	li	a1,190
ffffffffc02043ae:	00004517          	auipc	a0,0x4
ffffffffc02043b2:	cca50513          	addi	a0,a0,-822 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02043b6:	e61fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02043ba:	00004697          	auipc	a3,0x4
ffffffffc02043be:	d9e68693          	addi	a3,a3,-610 # ffffffffc0208158 <commands+0x1990>
ffffffffc02043c2:	00003617          	auipc	a2,0x3
ffffffffc02043c6:	8e660613          	addi	a2,a2,-1818 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02043ca:	0c000593          	li	a1,192
ffffffffc02043ce:	00004517          	auipc	a0,0x4
ffffffffc02043d2:	caa50513          	addi	a0,a0,-854 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02043d6:	e41fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02043da:	00004697          	auipc	a3,0x4
ffffffffc02043de:	e0668693          	addi	a3,a3,-506 # ffffffffc02081e0 <commands+0x1a18>
ffffffffc02043e2:	00003617          	auipc	a2,0x3
ffffffffc02043e6:	8c660613          	addi	a2,a2,-1850 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02043ea:	0d900593          	li	a1,217
ffffffffc02043ee:	00004517          	auipc	a0,0x4
ffffffffc02043f2:	c8a50513          	addi	a0,a0,-886 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02043f6:	e21fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02043fa:	00004697          	auipc	a3,0x4
ffffffffc02043fe:	c9668693          	addi	a3,a3,-874 # ffffffffc0208090 <commands+0x18c8>
ffffffffc0204402:	00003617          	auipc	a2,0x3
ffffffffc0204406:	8a660613          	addi	a2,a2,-1882 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020440a:	0d200593          	li	a1,210
ffffffffc020440e:	00004517          	auipc	a0,0x4
ffffffffc0204412:	c6a50513          	addi	a0,a0,-918 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204416:	e01fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 3);
ffffffffc020441a:	00004697          	auipc	a3,0x4
ffffffffc020441e:	db668693          	addi	a3,a3,-586 # ffffffffc02081d0 <commands+0x1a08>
ffffffffc0204422:	00003617          	auipc	a2,0x3
ffffffffc0204426:	88660613          	addi	a2,a2,-1914 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020442a:	0d000593          	li	a1,208
ffffffffc020442e:	00004517          	auipc	a0,0x4
ffffffffc0204432:	c4a50513          	addi	a0,a0,-950 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204436:	de1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020443a:	00004697          	auipc	a3,0x4
ffffffffc020443e:	d7e68693          	addi	a3,a3,-642 # ffffffffc02081b8 <commands+0x19f0>
ffffffffc0204442:	00003617          	auipc	a2,0x3
ffffffffc0204446:	86660613          	addi	a2,a2,-1946 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020444a:	0cb00593          	li	a1,203
ffffffffc020444e:	00004517          	auipc	a0,0x4
ffffffffc0204452:	c2a50513          	addi	a0,a0,-982 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204456:	dc1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020445a:	00004697          	auipc	a3,0x4
ffffffffc020445e:	d3e68693          	addi	a3,a3,-706 # ffffffffc0208198 <commands+0x19d0>
ffffffffc0204462:	00003617          	auipc	a2,0x3
ffffffffc0204466:	84660613          	addi	a2,a2,-1978 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020446a:	0c200593          	li	a1,194
ffffffffc020446e:	00004517          	auipc	a0,0x4
ffffffffc0204472:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204476:	da1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != NULL);
ffffffffc020447a:	00004697          	auipc	a3,0x4
ffffffffc020447e:	d9e68693          	addi	a3,a3,-610 # ffffffffc0208218 <commands+0x1a50>
ffffffffc0204482:	00003617          	auipc	a2,0x3
ffffffffc0204486:	82660613          	addi	a2,a2,-2010 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020448a:	0f800593          	li	a1,248
ffffffffc020448e:	00004517          	auipc	a0,0x4
ffffffffc0204492:	bea50513          	addi	a0,a0,-1046 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204496:	d81fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc020449a:	00004697          	auipc	a3,0x4
ffffffffc020449e:	83e68693          	addi	a3,a3,-1986 # ffffffffc0207cd8 <commands+0x1510>
ffffffffc02044a2:	00003617          	auipc	a2,0x3
ffffffffc02044a6:	80660613          	addi	a2,a2,-2042 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02044aa:	0df00593          	li	a1,223
ffffffffc02044ae:	00004517          	auipc	a0,0x4
ffffffffc02044b2:	bca50513          	addi	a0,a0,-1078 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02044b6:	d61fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02044ba:	00004697          	auipc	a3,0x4
ffffffffc02044be:	cfe68693          	addi	a3,a3,-770 # ffffffffc02081b8 <commands+0x19f0>
ffffffffc02044c2:	00002617          	auipc	a2,0x2
ffffffffc02044c6:	7e660613          	addi	a2,a2,2022 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02044ca:	0dd00593          	li	a1,221
ffffffffc02044ce:	00004517          	auipc	a0,0x4
ffffffffc02044d2:	baa50513          	addi	a0,a0,-1110 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02044d6:	d41fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02044da:	00004697          	auipc	a3,0x4
ffffffffc02044de:	d1e68693          	addi	a3,a3,-738 # ffffffffc02081f8 <commands+0x1a30>
ffffffffc02044e2:	00002617          	auipc	a2,0x2
ffffffffc02044e6:	7c660613          	addi	a2,a2,1990 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02044ea:	0dc00593          	li	a1,220
ffffffffc02044ee:	00004517          	auipc	a0,0x4
ffffffffc02044f2:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02044f6:	d21fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02044fa:	00004697          	auipc	a3,0x4
ffffffffc02044fe:	b9668693          	addi	a3,a3,-1130 # ffffffffc0208090 <commands+0x18c8>
ffffffffc0204502:	00002617          	auipc	a2,0x2
ffffffffc0204506:	7a660613          	addi	a2,a2,1958 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020450a:	0b900593          	li	a1,185
ffffffffc020450e:	00004517          	auipc	a0,0x4
ffffffffc0204512:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204516:	d01fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020451a:	00004697          	auipc	a3,0x4
ffffffffc020451e:	c9e68693          	addi	a3,a3,-866 # ffffffffc02081b8 <commands+0x19f0>
ffffffffc0204522:	00002617          	auipc	a2,0x2
ffffffffc0204526:	78660613          	addi	a2,a2,1926 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020452a:	0d600593          	li	a1,214
ffffffffc020452e:	00004517          	auipc	a0,0x4
ffffffffc0204532:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204536:	ce1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020453a:	00004697          	auipc	a3,0x4
ffffffffc020453e:	b9668693          	addi	a3,a3,-1130 # ffffffffc02080d0 <commands+0x1908>
ffffffffc0204542:	00002617          	auipc	a2,0x2
ffffffffc0204546:	76660613          	addi	a2,a2,1894 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020454a:	0d400593          	li	a1,212
ffffffffc020454e:	00004517          	auipc	a0,0x4
ffffffffc0204552:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204556:	cc1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020455a:	00004697          	auipc	a3,0x4
ffffffffc020455e:	b5668693          	addi	a3,a3,-1194 # ffffffffc02080b0 <commands+0x18e8>
ffffffffc0204562:	00002617          	auipc	a2,0x2
ffffffffc0204566:	74660613          	addi	a2,a2,1862 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020456a:	0d300593          	li	a1,211
ffffffffc020456e:	00004517          	auipc	a0,0x4
ffffffffc0204572:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204576:	ca1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020457a:	00004697          	auipc	a3,0x4
ffffffffc020457e:	b5668693          	addi	a3,a3,-1194 # ffffffffc02080d0 <commands+0x1908>
ffffffffc0204582:	00002617          	auipc	a2,0x2
ffffffffc0204586:	72660613          	addi	a2,a2,1830 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020458a:	0bb00593          	li	a1,187
ffffffffc020458e:	00004517          	auipc	a0,0x4
ffffffffc0204592:	aea50513          	addi	a0,a0,-1302 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204596:	c81fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(count == 0);
ffffffffc020459a:	00004697          	auipc	a3,0x4
ffffffffc020459e:	dce68693          	addi	a3,a3,-562 # ffffffffc0208368 <commands+0x1ba0>
ffffffffc02045a2:	00002617          	auipc	a2,0x2
ffffffffc02045a6:	70660613          	addi	a2,a2,1798 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02045aa:	12500593          	li	a1,293
ffffffffc02045ae:	00004517          	auipc	a0,0x4
ffffffffc02045b2:	aca50513          	addi	a0,a0,-1334 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02045b6:	c61fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc02045ba:	00003697          	auipc	a3,0x3
ffffffffc02045be:	71e68693          	addi	a3,a3,1822 # ffffffffc0207cd8 <commands+0x1510>
ffffffffc02045c2:	00002617          	auipc	a2,0x2
ffffffffc02045c6:	6e660613          	addi	a2,a2,1766 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02045ca:	11a00593          	li	a1,282
ffffffffc02045ce:	00004517          	auipc	a0,0x4
ffffffffc02045d2:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02045d6:	c41fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02045da:	00004697          	auipc	a3,0x4
ffffffffc02045de:	bde68693          	addi	a3,a3,-1058 # ffffffffc02081b8 <commands+0x19f0>
ffffffffc02045e2:	00002617          	auipc	a2,0x2
ffffffffc02045e6:	6c660613          	addi	a2,a2,1734 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02045ea:	11800593          	li	a1,280
ffffffffc02045ee:	00004517          	auipc	a0,0x4
ffffffffc02045f2:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02045f6:	c21fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02045fa:	00004697          	auipc	a3,0x4
ffffffffc02045fe:	b7e68693          	addi	a3,a3,-1154 # ffffffffc0208178 <commands+0x19b0>
ffffffffc0204602:	00002617          	auipc	a2,0x2
ffffffffc0204606:	6a660613          	addi	a2,a2,1702 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020460a:	0c100593          	li	a1,193
ffffffffc020460e:	00004517          	auipc	a0,0x4
ffffffffc0204612:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204616:	c01fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020461a:	00004697          	auipc	a3,0x4
ffffffffc020461e:	d0e68693          	addi	a3,a3,-754 # ffffffffc0208328 <commands+0x1b60>
ffffffffc0204622:	00002617          	auipc	a2,0x2
ffffffffc0204626:	68660613          	addi	a2,a2,1670 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020462a:	11200593          	li	a1,274
ffffffffc020462e:	00004517          	auipc	a0,0x4
ffffffffc0204632:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204636:	be1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020463a:	00004697          	auipc	a3,0x4
ffffffffc020463e:	cce68693          	addi	a3,a3,-818 # ffffffffc0208308 <commands+0x1b40>
ffffffffc0204642:	00002617          	auipc	a2,0x2
ffffffffc0204646:	66660613          	addi	a2,a2,1638 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020464a:	11000593          	li	a1,272
ffffffffc020464e:	00004517          	auipc	a0,0x4
ffffffffc0204652:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204656:	bc1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020465a:	00004697          	auipc	a3,0x4
ffffffffc020465e:	c8668693          	addi	a3,a3,-890 # ffffffffc02082e0 <commands+0x1b18>
ffffffffc0204662:	00002617          	auipc	a2,0x2
ffffffffc0204666:	64660613          	addi	a2,a2,1606 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020466a:	10e00593          	li	a1,270
ffffffffc020466e:	00004517          	auipc	a0,0x4
ffffffffc0204672:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204676:	ba1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020467a:	00004697          	auipc	a3,0x4
ffffffffc020467e:	c3e68693          	addi	a3,a3,-962 # ffffffffc02082b8 <commands+0x1af0>
ffffffffc0204682:	00002617          	auipc	a2,0x2
ffffffffc0204686:	62660613          	addi	a2,a2,1574 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020468a:	10d00593          	li	a1,269
ffffffffc020468e:	00004517          	auipc	a0,0x4
ffffffffc0204692:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204696:	b81fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020469a:	00004697          	auipc	a3,0x4
ffffffffc020469e:	c0e68693          	addi	a3,a3,-1010 # ffffffffc02082a8 <commands+0x1ae0>
ffffffffc02046a2:	00002617          	auipc	a2,0x2
ffffffffc02046a6:	60660613          	addi	a2,a2,1542 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02046aa:	10800593          	li	a1,264
ffffffffc02046ae:	00004517          	auipc	a0,0x4
ffffffffc02046b2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02046b6:	b61fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02046ba:	00004697          	auipc	a3,0x4
ffffffffc02046be:	afe68693          	addi	a3,a3,-1282 # ffffffffc02081b8 <commands+0x19f0>
ffffffffc02046c2:	00002617          	auipc	a2,0x2
ffffffffc02046c6:	5e660613          	addi	a2,a2,1510 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02046ca:	10700593          	li	a1,263
ffffffffc02046ce:	00004517          	auipc	a0,0x4
ffffffffc02046d2:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02046d6:	b41fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02046da:	00004697          	auipc	a3,0x4
ffffffffc02046de:	bae68693          	addi	a3,a3,-1106 # ffffffffc0208288 <commands+0x1ac0>
ffffffffc02046e2:	00002617          	auipc	a2,0x2
ffffffffc02046e6:	5c660613          	addi	a2,a2,1478 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02046ea:	10600593          	li	a1,262
ffffffffc02046ee:	00004517          	auipc	a0,0x4
ffffffffc02046f2:	98a50513          	addi	a0,a0,-1654 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02046f6:	b21fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02046fa:	00004697          	auipc	a3,0x4
ffffffffc02046fe:	b5e68693          	addi	a3,a3,-1186 # ffffffffc0208258 <commands+0x1a90>
ffffffffc0204702:	00002617          	auipc	a2,0x2
ffffffffc0204706:	5a660613          	addi	a2,a2,1446 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020470a:	10500593          	li	a1,261
ffffffffc020470e:	00004517          	auipc	a0,0x4
ffffffffc0204712:	96a50513          	addi	a0,a0,-1686 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204716:	b01fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020471a:	00004697          	auipc	a3,0x4
ffffffffc020471e:	b2668693          	addi	a3,a3,-1242 # ffffffffc0208240 <commands+0x1a78>
ffffffffc0204722:	00002617          	auipc	a2,0x2
ffffffffc0204726:	58660613          	addi	a2,a2,1414 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020472a:	10400593          	li	a1,260
ffffffffc020472e:	00004517          	auipc	a0,0x4
ffffffffc0204732:	94a50513          	addi	a0,a0,-1718 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204736:	ae1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020473a:	00004697          	auipc	a3,0x4
ffffffffc020473e:	a7e68693          	addi	a3,a3,-1410 # ffffffffc02081b8 <commands+0x19f0>
ffffffffc0204742:	00002617          	auipc	a2,0x2
ffffffffc0204746:	56660613          	addi	a2,a2,1382 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020474a:	0fe00593          	li	a1,254
ffffffffc020474e:	00004517          	auipc	a0,0x4
ffffffffc0204752:	92a50513          	addi	a0,a0,-1750 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204756:	ac1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!PageProperty(p0));
ffffffffc020475a:	00004697          	auipc	a3,0x4
ffffffffc020475e:	ace68693          	addi	a3,a3,-1330 # ffffffffc0208228 <commands+0x1a60>
ffffffffc0204762:	00002617          	auipc	a2,0x2
ffffffffc0204766:	54660613          	addi	a2,a2,1350 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020476a:	0f900593          	li	a1,249
ffffffffc020476e:	00004517          	auipc	a0,0x4
ffffffffc0204772:	90a50513          	addi	a0,a0,-1782 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204776:	aa1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020477a:	00004697          	auipc	a3,0x4
ffffffffc020477e:	bce68693          	addi	a3,a3,-1074 # ffffffffc0208348 <commands+0x1b80>
ffffffffc0204782:	00002617          	auipc	a2,0x2
ffffffffc0204786:	52660613          	addi	a2,a2,1318 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020478a:	11700593          	li	a1,279
ffffffffc020478e:	00004517          	auipc	a0,0x4
ffffffffc0204792:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204796:	a81fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == 0);
ffffffffc020479a:	00004697          	auipc	a3,0x4
ffffffffc020479e:	bde68693          	addi	a3,a3,-1058 # ffffffffc0208378 <commands+0x1bb0>
ffffffffc02047a2:	00002617          	auipc	a2,0x2
ffffffffc02047a6:	50660613          	addi	a2,a2,1286 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02047aa:	12600593          	li	a1,294
ffffffffc02047ae:	00004517          	auipc	a0,0x4
ffffffffc02047b2:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02047b6:	a61fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == nr_free_pages());
ffffffffc02047ba:	00003697          	auipc	a3,0x3
ffffffffc02047be:	37e68693          	addi	a3,a3,894 # ffffffffc0207b38 <commands+0x1370>
ffffffffc02047c2:	00002617          	auipc	a2,0x2
ffffffffc02047c6:	4e660613          	addi	a2,a2,1254 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02047ca:	0f300593          	li	a1,243
ffffffffc02047ce:	00004517          	auipc	a0,0x4
ffffffffc02047d2:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02047d6:	a41fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02047da:	00004697          	auipc	a3,0x4
ffffffffc02047de:	8d668693          	addi	a3,a3,-1834 # ffffffffc02080b0 <commands+0x18e8>
ffffffffc02047e2:	00002617          	auipc	a2,0x2
ffffffffc02047e6:	4c660613          	addi	a2,a2,1222 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc02047ea:	0ba00593          	li	a1,186
ffffffffc02047ee:	00004517          	auipc	a0,0x4
ffffffffc02047f2:	88a50513          	addi	a0,a0,-1910 # ffffffffc0208078 <commands+0x18b0>
ffffffffc02047f6:	a21fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02047fa <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02047fa:	1141                	addi	sp,sp,-16
ffffffffc02047fc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02047fe:	16058e63          	beqz	a1,ffffffffc020497a <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0204802:	00659693          	slli	a3,a1,0x6
ffffffffc0204806:	96aa                	add	a3,a3,a0
ffffffffc0204808:	02d50d63          	beq	a0,a3,ffffffffc0204842 <default_free_pages+0x48>
ffffffffc020480c:	651c                	ld	a5,8(a0)
ffffffffc020480e:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0204810:	14079563          	bnez	a5,ffffffffc020495a <default_free_pages+0x160>
ffffffffc0204814:	651c                	ld	a5,8(a0)
ffffffffc0204816:	8385                	srli	a5,a5,0x1
ffffffffc0204818:	8b85                	andi	a5,a5,1
ffffffffc020481a:	14079063          	bnez	a5,ffffffffc020495a <default_free_pages+0x160>
ffffffffc020481e:	87aa                	mv	a5,a0
ffffffffc0204820:	a809                	j	ffffffffc0204832 <default_free_pages+0x38>
ffffffffc0204822:	6798                	ld	a4,8(a5)
ffffffffc0204824:	8b05                	andi	a4,a4,1
ffffffffc0204826:	12071a63          	bnez	a4,ffffffffc020495a <default_free_pages+0x160>
ffffffffc020482a:	6798                	ld	a4,8(a5)
ffffffffc020482c:	8b09                	andi	a4,a4,2
ffffffffc020482e:	12071663          	bnez	a4,ffffffffc020495a <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0204832:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0204836:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020483a:	04078793          	addi	a5,a5,64
ffffffffc020483e:	fed792e3          	bne	a5,a3,ffffffffc0204822 <default_free_pages+0x28>
    base->property = n;
ffffffffc0204842:	2581                	sext.w	a1,a1
ffffffffc0204844:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0204846:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020484a:	4789                	li	a5,2
ffffffffc020484c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0204850:	000a8697          	auipc	a3,0xa8
ffffffffc0204854:	d0068693          	addi	a3,a3,-768 # ffffffffc02ac550 <free_area>
ffffffffc0204858:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020485a:	669c                	ld	a5,8(a3)
ffffffffc020485c:	9db9                	addw	a1,a1,a4
ffffffffc020485e:	000a8717          	auipc	a4,0xa8
ffffffffc0204862:	d0b72123          	sw	a1,-766(a4) # ffffffffc02ac560 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204866:	0cd78163          	beq	a5,a3,ffffffffc0204928 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc020486a:	fe878713          	addi	a4,a5,-24
ffffffffc020486e:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204870:	4801                	li	a6,0
ffffffffc0204872:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204876:	00e56a63          	bltu	a0,a4,ffffffffc020488a <default_free_pages+0x90>
    return listelm->next;
ffffffffc020487a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020487c:	04d70f63          	beq	a4,a3,ffffffffc02048da <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204880:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204882:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204886:	fee57ae3          	bleu	a4,a0,ffffffffc020487a <default_free_pages+0x80>
ffffffffc020488a:	00080663          	beqz	a6,ffffffffc0204896 <default_free_pages+0x9c>
ffffffffc020488e:	000a8817          	auipc	a6,0xa8
ffffffffc0204892:	ccb83123          	sd	a1,-830(a6) # ffffffffc02ac550 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204896:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204898:	e390                	sd	a2,0(a5)
ffffffffc020489a:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020489c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020489e:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02048a0:	06d58a63          	beq	a1,a3,ffffffffc0204914 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02048a4:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x8578>
        p = le2page(le, page_link);
ffffffffc02048a8:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02048ac:	02061793          	slli	a5,a2,0x20
ffffffffc02048b0:	83e9                	srli	a5,a5,0x1a
ffffffffc02048b2:	97ba                	add	a5,a5,a4
ffffffffc02048b4:	04f51b63          	bne	a0,a5,ffffffffc020490a <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02048b8:	491c                	lw	a5,16(a0)
ffffffffc02048ba:	9e3d                	addw	a2,a2,a5
ffffffffc02048bc:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02048c0:	57f5                	li	a5,-3
ffffffffc02048c2:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02048c6:	01853803          	ld	a6,24(a0)
ffffffffc02048ca:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02048cc:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc02048ce:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02048d2:	659c                	ld	a5,8(a1)
ffffffffc02048d4:	01063023          	sd	a6,0(a2)
ffffffffc02048d8:	a815                	j	ffffffffc020490c <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc02048da:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02048dc:	f114                	sd	a3,32(a0)
ffffffffc02048de:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02048e0:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02048e2:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02048e4:	00d70563          	beq	a4,a3,ffffffffc02048ee <default_free_pages+0xf4>
ffffffffc02048e8:	4805                	li	a6,1
ffffffffc02048ea:	87ba                	mv	a5,a4
ffffffffc02048ec:	bf59                	j	ffffffffc0204882 <default_free_pages+0x88>
ffffffffc02048ee:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02048f0:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02048f2:	00d78d63          	beq	a5,a3,ffffffffc020490c <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02048f6:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02048fa:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02048fe:	02061793          	slli	a5,a2,0x20
ffffffffc0204902:	83e9                	srli	a5,a5,0x1a
ffffffffc0204904:	97ba                	add	a5,a5,a4
ffffffffc0204906:	faf509e3          	beq	a0,a5,ffffffffc02048b8 <default_free_pages+0xbe>
ffffffffc020490a:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020490c:	fe878713          	addi	a4,a5,-24
ffffffffc0204910:	00d78963          	beq	a5,a3,ffffffffc0204922 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0204914:	4910                	lw	a2,16(a0)
ffffffffc0204916:	02061693          	slli	a3,a2,0x20
ffffffffc020491a:	82e9                	srli	a3,a3,0x1a
ffffffffc020491c:	96aa                	add	a3,a3,a0
ffffffffc020491e:	00d70e63          	beq	a4,a3,ffffffffc020493a <default_free_pages+0x140>
}
ffffffffc0204922:	60a2                	ld	ra,8(sp)
ffffffffc0204924:	0141                	addi	sp,sp,16
ffffffffc0204926:	8082                	ret
ffffffffc0204928:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020492a:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020492e:	e398                	sd	a4,0(a5)
ffffffffc0204930:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204932:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204934:	ed1c                	sd	a5,24(a0)
}
ffffffffc0204936:	0141                	addi	sp,sp,16
ffffffffc0204938:	8082                	ret
            base->property += p->property;
ffffffffc020493a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020493e:	ff078693          	addi	a3,a5,-16
ffffffffc0204942:	9e39                	addw	a2,a2,a4
ffffffffc0204944:	c910                	sw	a2,16(a0)
ffffffffc0204946:	5775                	li	a4,-3
ffffffffc0204948:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020494c:	6398                	ld	a4,0(a5)
ffffffffc020494e:	679c                	ld	a5,8(a5)
}
ffffffffc0204950:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0204952:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204954:	e398                	sd	a4,0(a5)
ffffffffc0204956:	0141                	addi	sp,sp,16
ffffffffc0204958:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020495a:	00004697          	auipc	a3,0x4
ffffffffc020495e:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0208388 <commands+0x1bc0>
ffffffffc0204962:	00002617          	auipc	a2,0x2
ffffffffc0204966:	34660613          	addi	a2,a2,838 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020496a:	08300593          	li	a1,131
ffffffffc020496e:	00003517          	auipc	a0,0x3
ffffffffc0204972:	70a50513          	addi	a0,a0,1802 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204976:	8a1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc020497a:	00004697          	auipc	a3,0x4
ffffffffc020497e:	a3668693          	addi	a3,a3,-1482 # ffffffffc02083b0 <commands+0x1be8>
ffffffffc0204982:	00002617          	auipc	a2,0x2
ffffffffc0204986:	32660613          	addi	a2,a2,806 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc020498a:	08000593          	li	a1,128
ffffffffc020498e:	00003517          	auipc	a0,0x3
ffffffffc0204992:	6ea50513          	addi	a0,a0,1770 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204996:	881fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020499a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020499a:	c959                	beqz	a0,ffffffffc0204a30 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020499c:	000a8597          	auipc	a1,0xa8
ffffffffc02049a0:	bb458593          	addi	a1,a1,-1100 # ffffffffc02ac550 <free_area>
ffffffffc02049a4:	0105a803          	lw	a6,16(a1)
ffffffffc02049a8:	862a                	mv	a2,a0
ffffffffc02049aa:	02081793          	slli	a5,a6,0x20
ffffffffc02049ae:	9381                	srli	a5,a5,0x20
ffffffffc02049b0:	00a7ee63          	bltu	a5,a0,ffffffffc02049cc <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02049b4:	87ae                	mv	a5,a1
ffffffffc02049b6:	a801                	j	ffffffffc02049c6 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02049b8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02049bc:	02071693          	slli	a3,a4,0x20
ffffffffc02049c0:	9281                	srli	a3,a3,0x20
ffffffffc02049c2:	00c6f763          	bleu	a2,a3,ffffffffc02049d0 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02049c6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02049c8:	feb798e3          	bne	a5,a1,ffffffffc02049b8 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02049cc:	4501                	li	a0,0
}
ffffffffc02049ce:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02049d0:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc02049d4:	dd6d                	beqz	a0,ffffffffc02049ce <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02049d6:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02049da:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02049de:	00060e1b          	sext.w	t3,a2
ffffffffc02049e2:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fcd3a90>
    next->prev = prev;
ffffffffc02049e6:	01133023          	sd	a7,0(t1) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff5588>
        if (page->property > n) {
ffffffffc02049ea:	02d67863          	bleu	a3,a2,ffffffffc0204a1a <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc02049ee:	061a                	slli	a2,a2,0x6
ffffffffc02049f0:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc02049f2:	41c7073b          	subw	a4,a4,t3
ffffffffc02049f6:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02049f8:	00860693          	addi	a3,a2,8
ffffffffc02049fc:	4709                	li	a4,2
ffffffffc02049fe:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204a02:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0204a06:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0204a0a:	0105a803          	lw	a6,16(a1)
ffffffffc0204a0e:	e314                	sd	a3,0(a4)
ffffffffc0204a10:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0204a14:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0204a16:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0204a1a:	41c8083b          	subw	a6,a6,t3
ffffffffc0204a1e:	000a8717          	auipc	a4,0xa8
ffffffffc0204a22:	b5072123          	sw	a6,-1214(a4) # ffffffffc02ac560 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204a26:	5775                	li	a4,-3
ffffffffc0204a28:	17c1                	addi	a5,a5,-16
ffffffffc0204a2a:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0204a2e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0204a30:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0204a32:	00004697          	auipc	a3,0x4
ffffffffc0204a36:	97e68693          	addi	a3,a3,-1666 # ffffffffc02083b0 <commands+0x1be8>
ffffffffc0204a3a:	00002617          	auipc	a2,0x2
ffffffffc0204a3e:	26e60613          	addi	a2,a2,622 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0204a42:	06200593          	li	a1,98
ffffffffc0204a46:	00003517          	auipc	a0,0x3
ffffffffc0204a4a:	63250513          	addi	a0,a0,1586 # ffffffffc0208078 <commands+0x18b0>
default_alloc_pages(size_t n) {
ffffffffc0204a4e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a50:	fc6fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204a54 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0204a54:	1141                	addi	sp,sp,-16
ffffffffc0204a56:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a58:	c1ed                	beqz	a1,ffffffffc0204b3a <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0204a5a:	00659693          	slli	a3,a1,0x6
ffffffffc0204a5e:	96aa                	add	a3,a3,a0
ffffffffc0204a60:	02d50463          	beq	a0,a3,ffffffffc0204a88 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0204a64:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0204a66:	87aa                	mv	a5,a0
ffffffffc0204a68:	8b05                	andi	a4,a4,1
ffffffffc0204a6a:	e709                	bnez	a4,ffffffffc0204a74 <default_init_memmap+0x20>
ffffffffc0204a6c:	a07d                	j	ffffffffc0204b1a <default_init_memmap+0xc6>
ffffffffc0204a6e:	6798                	ld	a4,8(a5)
ffffffffc0204a70:	8b05                	andi	a4,a4,1
ffffffffc0204a72:	c745                	beqz	a4,ffffffffc0204b1a <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0204a74:	0007a823          	sw	zero,16(a5)
ffffffffc0204a78:	0007b423          	sd	zero,8(a5)
ffffffffc0204a7c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204a80:	04078793          	addi	a5,a5,64
ffffffffc0204a84:	fed795e3          	bne	a5,a3,ffffffffc0204a6e <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0204a88:	2581                	sext.w	a1,a1
ffffffffc0204a8a:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204a8c:	4789                	li	a5,2
ffffffffc0204a8e:	00850713          	addi	a4,a0,8
ffffffffc0204a92:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0204a96:	000a8697          	auipc	a3,0xa8
ffffffffc0204a9a:	aba68693          	addi	a3,a3,-1350 # ffffffffc02ac550 <free_area>
ffffffffc0204a9e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204aa0:	669c                	ld	a5,8(a3)
ffffffffc0204aa2:	9db9                	addw	a1,a1,a4
ffffffffc0204aa4:	000a8717          	auipc	a4,0xa8
ffffffffc0204aa8:	aab72e23          	sw	a1,-1348(a4) # ffffffffc02ac560 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204aac:	04d78a63          	beq	a5,a3,ffffffffc0204b00 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0204ab0:	fe878713          	addi	a4,a5,-24
ffffffffc0204ab4:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204ab6:	4801                	li	a6,0
ffffffffc0204ab8:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204abc:	00e56a63          	bltu	a0,a4,ffffffffc0204ad0 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0204ac0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204ac2:	02d70563          	beq	a4,a3,ffffffffc0204aec <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204ac6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204ac8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204acc:	fee57ae3          	bleu	a4,a0,ffffffffc0204ac0 <default_init_memmap+0x6c>
ffffffffc0204ad0:	00080663          	beqz	a6,ffffffffc0204adc <default_init_memmap+0x88>
ffffffffc0204ad4:	000a8717          	auipc	a4,0xa8
ffffffffc0204ad8:	a6b73e23          	sd	a1,-1412(a4) # ffffffffc02ac550 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204adc:	6398                	ld	a4,0(a5)
}
ffffffffc0204ade:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204ae0:	e390                	sd	a2,0(a5)
ffffffffc0204ae2:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204ae4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204ae6:	ed18                	sd	a4,24(a0)
ffffffffc0204ae8:	0141                	addi	sp,sp,16
ffffffffc0204aea:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204aec:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204aee:	f114                	sd	a3,32(a0)
ffffffffc0204af0:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204af2:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0204af4:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204af6:	00d70e63          	beq	a4,a3,ffffffffc0204b12 <default_init_memmap+0xbe>
ffffffffc0204afa:	4805                	li	a6,1
ffffffffc0204afc:	87ba                	mv	a5,a4
ffffffffc0204afe:	b7e9                	j	ffffffffc0204ac8 <default_init_memmap+0x74>
}
ffffffffc0204b00:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0204b02:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0204b06:	e398                	sd	a4,0(a5)
ffffffffc0204b08:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204b0a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204b0c:	ed1c                	sd	a5,24(a0)
}
ffffffffc0204b0e:	0141                	addi	sp,sp,16
ffffffffc0204b10:	8082                	ret
ffffffffc0204b12:	60a2                	ld	ra,8(sp)
ffffffffc0204b14:	e290                	sd	a2,0(a3)
ffffffffc0204b16:	0141                	addi	sp,sp,16
ffffffffc0204b18:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204b1a:	00004697          	auipc	a3,0x4
ffffffffc0204b1e:	89e68693          	addi	a3,a3,-1890 # ffffffffc02083b8 <commands+0x1bf0>
ffffffffc0204b22:	00002617          	auipc	a2,0x2
ffffffffc0204b26:	18660613          	addi	a2,a2,390 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0204b2a:	04900593          	li	a1,73
ffffffffc0204b2e:	00003517          	auipc	a0,0x3
ffffffffc0204b32:	54a50513          	addi	a0,a0,1354 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204b36:	ee0fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc0204b3a:	00004697          	auipc	a3,0x4
ffffffffc0204b3e:	87668693          	addi	a3,a3,-1930 # ffffffffc02083b0 <commands+0x1be8>
ffffffffc0204b42:	00002617          	auipc	a2,0x2
ffffffffc0204b46:	16660613          	addi	a2,a2,358 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0204b4a:	04600593          	li	a1,70
ffffffffc0204b4e:	00003517          	auipc	a0,0x3
ffffffffc0204b52:	52a50513          	addi	a0,a0,1322 # ffffffffc0208078 <commands+0x18b0>
ffffffffc0204b56:	ec0fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b5a <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b5a:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b5c:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b5e:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b60:	9d5fb0ef          	jal	ra,ffffffffc0200534 <ide_device_valid>
ffffffffc0204b64:	cd01                	beqz	a0,ffffffffc0204b7c <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b66:	4505                	li	a0,1
ffffffffc0204b68:	9d3fb0ef          	jal	ra,ffffffffc020053a <ide_device_size>
}
ffffffffc0204b6c:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b6e:	810d                	srli	a0,a0,0x3
ffffffffc0204b70:	000a8797          	auipc	a5,0xa8
ffffffffc0204b74:	98a7b823          	sd	a0,-1648(a5) # ffffffffc02ac500 <max_swap_offset>
}
ffffffffc0204b78:	0141                	addi	sp,sp,16
ffffffffc0204b7a:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b7c:	00004617          	auipc	a2,0x4
ffffffffc0204b80:	89c60613          	addi	a2,a2,-1892 # ffffffffc0208418 <default_pmm_manager+0x50>
ffffffffc0204b84:	45b5                	li	a1,13
ffffffffc0204b86:	00004517          	auipc	a0,0x4
ffffffffc0204b8a:	8b250513          	addi	a0,a0,-1870 # ffffffffc0208438 <default_pmm_manager+0x70>
ffffffffc0204b8e:	e88fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b92 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b92:	1141                	addi	sp,sp,-16
ffffffffc0204b94:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b96:	00855793          	srli	a5,a0,0x8
ffffffffc0204b9a:	cfb9                	beqz	a5,ffffffffc0204bf8 <swapfs_read+0x66>
ffffffffc0204b9c:	000a8717          	auipc	a4,0xa8
ffffffffc0204ba0:	96470713          	addi	a4,a4,-1692 # ffffffffc02ac500 <max_swap_offset>
ffffffffc0204ba4:	6318                	ld	a4,0(a4)
ffffffffc0204ba6:	04e7f963          	bleu	a4,a5,ffffffffc0204bf8 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204baa:	000a8717          	auipc	a4,0xa8
ffffffffc0204bae:	8be70713          	addi	a4,a4,-1858 # ffffffffc02ac468 <pages>
ffffffffc0204bb2:	6310                	ld	a2,0(a4)
ffffffffc0204bb4:	00004717          	auipc	a4,0x4
ffffffffc0204bb8:	1dc70713          	addi	a4,a4,476 # ffffffffc0208d90 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204bbc:	000a8697          	auipc	a3,0xa8
ffffffffc0204bc0:	84468693          	addi	a3,a3,-1980 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc0204bc4:	40c58633          	sub	a2,a1,a2
ffffffffc0204bc8:	630c                	ld	a1,0(a4)
ffffffffc0204bca:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204bcc:	577d                	li	a4,-1
ffffffffc0204bce:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204bd0:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204bd2:	8331                	srli	a4,a4,0xc
ffffffffc0204bd4:	8f71                	and	a4,a4,a2
ffffffffc0204bd6:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bda:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bdc:	02d77a63          	bleu	a3,a4,ffffffffc0204c10 <swapfs_read+0x7e>
ffffffffc0204be0:	000a8797          	auipc	a5,0xa8
ffffffffc0204be4:	87878793          	addi	a5,a5,-1928 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0204be8:	639c                	ld	a5,0(a5)
}
ffffffffc0204bea:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bec:	46a1                	li	a3,8
ffffffffc0204bee:	963e                	add	a2,a2,a5
ffffffffc0204bf0:	4505                	li	a0,1
}
ffffffffc0204bf2:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bf4:	94dfb06f          	j	ffffffffc0200540 <ide_read_secs>
ffffffffc0204bf8:	86aa                	mv	a3,a0
ffffffffc0204bfa:	00004617          	auipc	a2,0x4
ffffffffc0204bfe:	85660613          	addi	a2,a2,-1962 # ffffffffc0208450 <default_pmm_manager+0x88>
ffffffffc0204c02:	45d1                	li	a1,20
ffffffffc0204c04:	00004517          	auipc	a0,0x4
ffffffffc0204c08:	83450513          	addi	a0,a0,-1996 # ffffffffc0208438 <default_pmm_manager+0x70>
ffffffffc0204c0c:	e0afb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204c10:	86b2                	mv	a3,a2
ffffffffc0204c12:	06900593          	li	a1,105
ffffffffc0204c16:	00002617          	auipc	a2,0x2
ffffffffc0204c1a:	47a60613          	addi	a2,a2,1146 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0204c1e:	00002517          	auipc	a0,0x2
ffffffffc0204c22:	4ca50513          	addi	a0,a0,1226 # ffffffffc02070e8 <commands+0x920>
ffffffffc0204c26:	df0fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204c2a <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c2a:	1141                	addi	sp,sp,-16
ffffffffc0204c2c:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c2e:	00855793          	srli	a5,a0,0x8
ffffffffc0204c32:	cfb9                	beqz	a5,ffffffffc0204c90 <swapfs_write+0x66>
ffffffffc0204c34:	000a8717          	auipc	a4,0xa8
ffffffffc0204c38:	8cc70713          	addi	a4,a4,-1844 # ffffffffc02ac500 <max_swap_offset>
ffffffffc0204c3c:	6318                	ld	a4,0(a4)
ffffffffc0204c3e:	04e7f963          	bleu	a4,a5,ffffffffc0204c90 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204c42:	000a8717          	auipc	a4,0xa8
ffffffffc0204c46:	82670713          	addi	a4,a4,-2010 # ffffffffc02ac468 <pages>
ffffffffc0204c4a:	6310                	ld	a2,0(a4)
ffffffffc0204c4c:	00004717          	auipc	a4,0x4
ffffffffc0204c50:	14470713          	addi	a4,a4,324 # ffffffffc0208d90 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c54:	000a7697          	auipc	a3,0xa7
ffffffffc0204c58:	7ac68693          	addi	a3,a3,1964 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc0204c5c:	40c58633          	sub	a2,a1,a2
ffffffffc0204c60:	630c                	ld	a1,0(a4)
ffffffffc0204c62:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c64:	577d                	li	a4,-1
ffffffffc0204c66:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c68:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c6a:	8331                	srli	a4,a4,0xc
ffffffffc0204c6c:	8f71                	and	a4,a4,a2
ffffffffc0204c6e:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c72:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c74:	02d77a63          	bleu	a3,a4,ffffffffc0204ca8 <swapfs_write+0x7e>
ffffffffc0204c78:	000a7797          	auipc	a5,0xa7
ffffffffc0204c7c:	7e078793          	addi	a5,a5,2016 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0204c80:	639c                	ld	a5,0(a5)
}
ffffffffc0204c82:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c84:	46a1                	li	a3,8
ffffffffc0204c86:	963e                	add	a2,a2,a5
ffffffffc0204c88:	4505                	li	a0,1
}
ffffffffc0204c8a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c8c:	8d9fb06f          	j	ffffffffc0200564 <ide_write_secs>
ffffffffc0204c90:	86aa                	mv	a3,a0
ffffffffc0204c92:	00003617          	auipc	a2,0x3
ffffffffc0204c96:	7be60613          	addi	a2,a2,1982 # ffffffffc0208450 <default_pmm_manager+0x88>
ffffffffc0204c9a:	45e5                	li	a1,25
ffffffffc0204c9c:	00003517          	auipc	a0,0x3
ffffffffc0204ca0:	79c50513          	addi	a0,a0,1948 # ffffffffc0208438 <default_pmm_manager+0x70>
ffffffffc0204ca4:	d72fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204ca8:	86b2                	mv	a3,a2
ffffffffc0204caa:	06900593          	li	a1,105
ffffffffc0204cae:	00002617          	auipc	a2,0x2
ffffffffc0204cb2:	3e260613          	addi	a2,a2,994 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0204cb6:	00002517          	auipc	a0,0x2
ffffffffc0204cba:	43250513          	addi	a0,a0,1074 # ffffffffc02070e8 <commands+0x920>
ffffffffc0204cbe:	d58fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204cc2 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204cc2:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204cc4:	9402                	jalr	s0

	jal do_exit
ffffffffc0204cc6:	7ac000ef          	jal	ra,ffffffffc0205472 <do_exit>

ffffffffc0204cca <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204cca:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204cce:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204cd2:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204cd4:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204cd6:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204cda:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204cde:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204ce2:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204ce6:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204cea:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204cee:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204cf2:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204cf6:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204cfa:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204cfe:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204d02:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204d06:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204d08:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204d0a:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204d0e:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204d12:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204d16:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204d1a:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204d1e:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204d22:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204d26:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204d2a:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204d2e:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204d32:	8082                	ret

ffffffffc0204d34 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d34:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d36:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d3a:	e022                	sd	s0,0(sp)
ffffffffc0204d3c:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d3e:	d07fe0ef          	jal	ra,ffffffffc0203a44 <kmalloc>
ffffffffc0204d42:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204d44:	cd29                	beqz	a0,ffffffffc0204d9e <alloc_proc+0x6a>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->state = PROC_UNINIT;
ffffffffc0204d46:	57fd                	li	a5,-1
ffffffffc0204d48:	1782                	slli	a5,a5,0x20
ffffffffc0204d4a:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d4c:	07000613          	li	a2,112
ffffffffc0204d50:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc0204d52:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204d56:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204d5a:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204d5e:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204d62:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d66:	03050513          	addi	a0,a0,48
ffffffffc0204d6a:	4b4010ef          	jal	ra,ffffffffc020621e <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204d6e:	000a7797          	auipc	a5,0xa7
ffffffffc0204d72:	6f278793          	addi	a5,a5,1778 # ffffffffc02ac460 <boot_cr3>
ffffffffc0204d76:	639c                	ld	a5,0(a5)
    proc->tf = NULL;
ffffffffc0204d78:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;
ffffffffc0204d7c:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204d80:	f45c                	sd	a5,168(s0)
    memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204d82:	463d                	li	a2,15
ffffffffc0204d84:	4581                	li	a1,0
ffffffffc0204d86:	0b440513          	addi	a0,s0,180
ffffffffc0204d8a:	494010ef          	jal	ra,ffffffffc020621e <memset>
    proc->wait_state = 0;
ffffffffc0204d8e:	0e042623          	sw	zero,236(s0)
    proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204d92:	10043023          	sd	zero,256(s0)
ffffffffc0204d96:	0e043c23          	sd	zero,248(s0)
ffffffffc0204d9a:	0e043823          	sd	zero,240(s0)
    
    }
    return proc;
}
ffffffffc0204d9e:	8522                	mv	a0,s0
ffffffffc0204da0:	60a2                	ld	ra,8(sp)
ffffffffc0204da2:	6402                	ld	s0,0(sp)
ffffffffc0204da4:	0141                	addi	sp,sp,16
ffffffffc0204da6:	8082                	ret

ffffffffc0204da8 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204da8:	000a7797          	auipc	a5,0xa7
ffffffffc0204dac:	68078793          	addi	a5,a5,1664 # ffffffffc02ac428 <current>
ffffffffc0204db0:	639c                	ld	a5,0(a5)
ffffffffc0204db2:	73c8                	ld	a0,160(a5)
ffffffffc0204db4:	82efc06f          	j	ffffffffc0200de2 <forkrets>

ffffffffc0204db8 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204db8:	000a7797          	auipc	a5,0xa7
ffffffffc0204dbc:	67078793          	addi	a5,a5,1648 # ffffffffc02ac428 <current>
ffffffffc0204dc0:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204dc2:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dc4:	00004617          	auipc	a2,0x4
ffffffffc0204dc8:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0208860 <default_pmm_manager+0x498>
ffffffffc0204dcc:	43cc                	lw	a1,4(a5)
ffffffffc0204dce:	00004517          	auipc	a0,0x4
ffffffffc0204dd2:	aa250513          	addi	a0,a0,-1374 # ffffffffc0208870 <default_pmm_manager+0x4a8>
user_main(void *arg) {
ffffffffc0204dd6:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dd8:	af8fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204ddc:	00004797          	auipc	a5,0x4
ffffffffc0204de0:	a8478793          	addi	a5,a5,-1404 # ffffffffc0208860 <default_pmm_manager+0x498>
ffffffffc0204de4:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204de8:	4f470713          	addi	a4,a4,1268 # a2d8 <_binary_obj___user_forktest_out_size>
ffffffffc0204dec:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204dee:	853e                	mv	a0,a5
ffffffffc0204df0:	00092717          	auipc	a4,0x92
ffffffffc0204df4:	ec070713          	addi	a4,a4,-320 # ffffffffc0296cb0 <_binary_obj___user_forktest_out_start>
ffffffffc0204df8:	f03a                	sd	a4,32(sp)
ffffffffc0204dfa:	f43e                	sd	a5,40(sp)
ffffffffc0204dfc:	e802                	sd	zero,16(sp)
ffffffffc0204dfe:	382010ef          	jal	ra,ffffffffc0206180 <strlen>
ffffffffc0204e02:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204e04:	4511                	li	a0,4
ffffffffc0204e06:	55a2                	lw	a1,40(sp)
ffffffffc0204e08:	4662                	lw	a2,24(sp)
ffffffffc0204e0a:	5682                	lw	a3,32(sp)
ffffffffc0204e0c:	4722                	lw	a4,8(sp)
ffffffffc0204e0e:	48a9                	li	a7,10
ffffffffc0204e10:	9002                	ebreak
ffffffffc0204e12:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204e14:	65c2                	ld	a1,16(sp)
ffffffffc0204e16:	00004517          	auipc	a0,0x4
ffffffffc0204e1a:	a8250513          	addi	a0,a0,-1406 # ffffffffc0208898 <default_pmm_manager+0x4d0>
ffffffffc0204e1e:	ab2fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204e22:	00004617          	auipc	a2,0x4
ffffffffc0204e26:	a8660613          	addi	a2,a2,-1402 # ffffffffc02088a8 <default_pmm_manager+0x4e0>
ffffffffc0204e2a:	34c00593          	li	a1,844
ffffffffc0204e2e:	00004517          	auipc	a0,0x4
ffffffffc0204e32:	a9a50513          	addi	a0,a0,-1382 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0204e36:	be0fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204e3a <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e3a:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204e3c:	1141                	addi	sp,sp,-16
ffffffffc0204e3e:	e406                	sd	ra,8(sp)
ffffffffc0204e40:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e44:	04f6e263          	bltu	a3,a5,ffffffffc0204e88 <put_pgdir+0x4e>
ffffffffc0204e48:	000a7797          	auipc	a5,0xa7
ffffffffc0204e4c:	61078793          	addi	a5,a5,1552 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0204e50:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204e52:	000a7797          	auipc	a5,0xa7
ffffffffc0204e56:	5ae78793          	addi	a5,a5,1454 # ffffffffc02ac400 <npage>
ffffffffc0204e5a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204e5c:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e5e:	82b1                	srli	a3,a3,0xc
ffffffffc0204e60:	04f6f063          	bleu	a5,a3,ffffffffc0204ea0 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e64:	00004797          	auipc	a5,0x4
ffffffffc0204e68:	f2c78793          	addi	a5,a5,-212 # ffffffffc0208d90 <nbase>
ffffffffc0204e6c:	639c                	ld	a5,0(a5)
ffffffffc0204e6e:	000a7717          	auipc	a4,0xa7
ffffffffc0204e72:	5fa70713          	addi	a4,a4,1530 # ffffffffc02ac468 <pages>
ffffffffc0204e76:	6308                	ld	a0,0(a4)
}
ffffffffc0204e78:	60a2                	ld	ra,8(sp)
ffffffffc0204e7a:	8e9d                	sub	a3,a3,a5
ffffffffc0204e7c:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e7e:	4585                	li	a1,1
ffffffffc0204e80:	9536                	add	a0,a0,a3
}
ffffffffc0204e82:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e84:	8aefc06f          	j	ffffffffc0200f32 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e88:	00002617          	auipc	a2,0x2
ffffffffc0204e8c:	2e060613          	addi	a2,a2,736 # ffffffffc0207168 <commands+0x9a0>
ffffffffc0204e90:	06e00593          	li	a1,110
ffffffffc0204e94:	00002517          	auipc	a0,0x2
ffffffffc0204e98:	25450513          	addi	a0,a0,596 # ffffffffc02070e8 <commands+0x920>
ffffffffc0204e9c:	b7afb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204ea0:	00002617          	auipc	a2,0x2
ffffffffc0204ea4:	22860613          	addi	a2,a2,552 # ffffffffc02070c8 <commands+0x900>
ffffffffc0204ea8:	06200593          	li	a1,98
ffffffffc0204eac:	00002517          	auipc	a0,0x2
ffffffffc0204eb0:	23c50513          	addi	a0,a0,572 # ffffffffc02070e8 <commands+0x920>
ffffffffc0204eb4:	b62fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204eb8 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204eb8:	1101                	addi	sp,sp,-32
ffffffffc0204eba:	e426                	sd	s1,8(sp)
ffffffffc0204ebc:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204ebe:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204ec0:	ec06                	sd	ra,24(sp)
ffffffffc0204ec2:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204ec4:	fe7fb0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
ffffffffc0204ec8:	c125                	beqz	a0,ffffffffc0204f28 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204eca:	000a7797          	auipc	a5,0xa7
ffffffffc0204ece:	59e78793          	addi	a5,a5,1438 # ffffffffc02ac468 <pages>
ffffffffc0204ed2:	6394                	ld	a3,0(a5)
ffffffffc0204ed4:	00004797          	auipc	a5,0x4
ffffffffc0204ed8:	ebc78793          	addi	a5,a5,-324 # ffffffffc0208d90 <nbase>
ffffffffc0204edc:	6380                	ld	s0,0(a5)
ffffffffc0204ede:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204ee2:	000a7717          	auipc	a4,0xa7
ffffffffc0204ee6:	51e70713          	addi	a4,a4,1310 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc0204eea:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204eec:	57fd                	li	a5,-1
ffffffffc0204eee:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204ef0:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204ef2:	83b1                	srli	a5,a5,0xc
ffffffffc0204ef4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ef6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ef8:	02e7fa63          	bleu	a4,a5,ffffffffc0204f2c <setup_pgdir+0x74>
ffffffffc0204efc:	000a7797          	auipc	a5,0xa7
ffffffffc0204f00:	55c78793          	addi	a5,a5,1372 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0204f04:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204f06:	000a7797          	auipc	a5,0xa7
ffffffffc0204f0a:	4f278793          	addi	a5,a5,1266 # ffffffffc02ac3f8 <boot_pgdir>
ffffffffc0204f0e:	638c                	ld	a1,0(a5)
ffffffffc0204f10:	9436                	add	s0,s0,a3
ffffffffc0204f12:	6605                	lui	a2,0x1
ffffffffc0204f14:	8522                	mv	a0,s0
ffffffffc0204f16:	31a010ef          	jal	ra,ffffffffc0206230 <memcpy>
    return 0;
ffffffffc0204f1a:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204f1c:	ec80                	sd	s0,24(s1)
}
ffffffffc0204f1e:	60e2                	ld	ra,24(sp)
ffffffffc0204f20:	6442                	ld	s0,16(sp)
ffffffffc0204f22:	64a2                	ld	s1,8(sp)
ffffffffc0204f24:	6105                	addi	sp,sp,32
ffffffffc0204f26:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204f28:	5571                	li	a0,-4
ffffffffc0204f2a:	bfd5                	j	ffffffffc0204f1e <setup_pgdir+0x66>
ffffffffc0204f2c:	00002617          	auipc	a2,0x2
ffffffffc0204f30:	16460613          	addi	a2,a2,356 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0204f34:	06900593          	li	a1,105
ffffffffc0204f38:	00002517          	auipc	a0,0x2
ffffffffc0204f3c:	1b050513          	addi	a0,a0,432 # ffffffffc02070e8 <commands+0x920>
ffffffffc0204f40:	ad6fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204f44 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f44:	1101                	addi	sp,sp,-32
ffffffffc0204f46:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f48:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f4c:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f4e:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f50:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f52:	8522                	mv	a0,s0
ffffffffc0204f54:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f56:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f58:	2c6010ef          	jal	ra,ffffffffc020621e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f5c:	8522                	mv	a0,s0
}
ffffffffc0204f5e:	6442                	ld	s0,16(sp)
ffffffffc0204f60:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f62:	85a6                	mv	a1,s1
}
ffffffffc0204f64:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f66:	463d                	li	a2,15
}
ffffffffc0204f68:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f6a:	2c60106f          	j	ffffffffc0206230 <memcpy>

ffffffffc0204f6e <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204f6e:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204f70:	000a7797          	auipc	a5,0xa7
ffffffffc0204f74:	4b878793          	addi	a5,a5,1208 # ffffffffc02ac428 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f78:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204f7a:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204f7c:	ec06                	sd	ra,24(sp)
ffffffffc0204f7e:	e822                	sd	s0,16(sp)
ffffffffc0204f80:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204f82:	02a48b63          	beq	s1,a0,ffffffffc0204fb8 <proc_run+0x4a>
ffffffffc0204f86:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f88:	100027f3          	csrr	a5,sstatus
ffffffffc0204f8c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f8e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f90:	e3a9                	bnez	a5,ffffffffc0204fd2 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f92:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204f94:	000a7717          	auipc	a4,0xa7
ffffffffc0204f98:	48873a23          	sd	s0,1172(a4) # ffffffffc02ac428 <current>
ffffffffc0204f9c:	577d                	li	a4,-1
ffffffffc0204f9e:	177e                	slli	a4,a4,0x3f
ffffffffc0204fa0:	83b1                	srli	a5,a5,0xc
ffffffffc0204fa2:	8fd9                	or	a5,a5,a4
ffffffffc0204fa4:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204fa8:	03040593          	addi	a1,s0,48
ffffffffc0204fac:	03048513          	addi	a0,s1,48
ffffffffc0204fb0:	d1bff0ef          	jal	ra,ffffffffc0204cca <switch_to>
    if (flag) {
ffffffffc0204fb4:	00091863          	bnez	s2,ffffffffc0204fc4 <proc_run+0x56>
}
ffffffffc0204fb8:	60e2                	ld	ra,24(sp)
ffffffffc0204fba:	6442                	ld	s0,16(sp)
ffffffffc0204fbc:	64a2                	ld	s1,8(sp)
ffffffffc0204fbe:	6902                	ld	s2,0(sp)
ffffffffc0204fc0:	6105                	addi	sp,sp,32
ffffffffc0204fc2:	8082                	ret
ffffffffc0204fc4:	6442                	ld	s0,16(sp)
ffffffffc0204fc6:	60e2                	ld	ra,24(sp)
ffffffffc0204fc8:	64a2                	ld	s1,8(sp)
ffffffffc0204fca:	6902                	ld	s2,0(sp)
ffffffffc0204fcc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204fce:	e88fb06f          	j	ffffffffc0200656 <intr_enable>
        intr_disable();
ffffffffc0204fd2:	e8afb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0204fd6:	4905                	li	s2,1
ffffffffc0204fd8:	bf6d                	j	ffffffffc0204f92 <proc_run+0x24>

ffffffffc0204fda <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204fda:	0005071b          	sext.w	a4,a0
ffffffffc0204fde:	6789                	lui	a5,0x2
ffffffffc0204fe0:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204fe4:	17f9                	addi	a5,a5,-2
ffffffffc0204fe6:	04d7e063          	bltu	a5,a3,ffffffffc0205026 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204fea:	1141                	addi	sp,sp,-16
ffffffffc0204fec:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fee:	45a9                	li	a1,10
ffffffffc0204ff0:	842a                	mv	s0,a0
ffffffffc0204ff2:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204ff4:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204ff6:	64a010ef          	jal	ra,ffffffffc0206640 <hash32>
ffffffffc0204ffa:	02051693          	slli	a3,a0,0x20
ffffffffc0204ffe:	82f1                	srli	a3,a3,0x1c
ffffffffc0205000:	000a3517          	auipc	a0,0xa3
ffffffffc0205004:	3e850513          	addi	a0,a0,1000 # ffffffffc02a83e8 <hash_list>
ffffffffc0205008:	96aa                	add	a3,a3,a0
ffffffffc020500a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020500c:	a029                	j	ffffffffc0205016 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc020500e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7644>
ffffffffc0205012:	00870c63          	beq	a4,s0,ffffffffc020502a <find_proc+0x50>
    return listelm->next;
ffffffffc0205016:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205018:	fef69be3          	bne	a3,a5,ffffffffc020500e <find_proc+0x34>
}
ffffffffc020501c:	60a2                	ld	ra,8(sp)
ffffffffc020501e:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0205020:	4501                	li	a0,0
}
ffffffffc0205022:	0141                	addi	sp,sp,16
ffffffffc0205024:	8082                	ret
    return NULL;
ffffffffc0205026:	4501                	li	a0,0
}
ffffffffc0205028:	8082                	ret
ffffffffc020502a:	60a2                	ld	ra,8(sp)
ffffffffc020502c:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020502e:	f2878513          	addi	a0,a5,-216
}
ffffffffc0205032:	0141                	addi	sp,sp,16
ffffffffc0205034:	8082                	ret

ffffffffc0205036 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205036:	715d                	addi	sp,sp,-80
ffffffffc0205038:	f84a                	sd	s2,48(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020503a:	000a7917          	auipc	s2,0xa7
ffffffffc020503e:	40690913          	addi	s2,s2,1030 # ffffffffc02ac440 <nr_process>
ffffffffc0205042:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205046:	e486                	sd	ra,72(sp)
ffffffffc0205048:	e0a2                	sd	s0,64(sp)
ffffffffc020504a:	fc26                	sd	s1,56(sp)
ffffffffc020504c:	f44e                	sd	s3,40(sp)
ffffffffc020504e:	f052                	sd	s4,32(sp)
ffffffffc0205050:	ec56                	sd	s5,24(sp)
ffffffffc0205052:	e85a                	sd	s6,16(sp)
ffffffffc0205054:	e45e                	sd	s7,8(sp)
ffffffffc0205056:	e062                	sd	s8,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205058:	6785                	lui	a5,0x1
ffffffffc020505a:	32f75563          	ble	a5,a4,ffffffffc0205384 <do_fork+0x34e>
ffffffffc020505e:	8aaa                	mv	s5,a0
ffffffffc0205060:	89ae                	mv	s3,a1
ffffffffc0205062:	84b2                	mv	s1,a2
    proc = alloc_proc();
ffffffffc0205064:	cd1ff0ef          	jal	ra,ffffffffc0204d34 <alloc_proc>
ffffffffc0205068:	842a                	mv	s0,a0
    if(proc==NULL){
ffffffffc020506a:	2a050a63          	beqz	a0,ffffffffc020531e <do_fork+0x2e8>
    proc->parent = current;
ffffffffc020506e:	000a7a17          	auipc	s4,0xa7
ffffffffc0205072:	3baa0a13          	addi	s4,s4,954 # ffffffffc02ac428 <current>
ffffffffc0205076:	000a3783          	ld	a5,0(s4)
    assert(current->wait_state == 0);
ffffffffc020507a:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8484>
    proc->parent = current;
ffffffffc020507e:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0205080:	30071463          	bnez	a4,ffffffffc0205388 <do_fork+0x352>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205084:	4509                	li	a0,2
ffffffffc0205086:	e25fb0ef          	jal	ra,ffffffffc0200eaa <alloc_pages>
    if (page != NULL) {
ffffffffc020508a:	2a050863          	beqz	a0,ffffffffc020533a <do_fork+0x304>
    return page - pages + nbase;
ffffffffc020508e:	000a7797          	auipc	a5,0xa7
ffffffffc0205092:	3da78793          	addi	a5,a5,986 # ffffffffc02ac468 <pages>
ffffffffc0205096:	6394                	ld	a3,0(a5)
ffffffffc0205098:	00004797          	auipc	a5,0x4
ffffffffc020509c:	cf878793          	addi	a5,a5,-776 # ffffffffc0208d90 <nbase>
    return KADDR(page2pa(page));
ffffffffc02050a0:	000a7717          	auipc	a4,0xa7
ffffffffc02050a4:	36070713          	addi	a4,a4,864 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc02050a8:	40d506b3          	sub	a3,a0,a3
ffffffffc02050ac:	6388                	ld	a0,0(a5)
ffffffffc02050ae:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02050b0:	57fd                	li	a5,-1
ffffffffc02050b2:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02050b4:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc02050b6:	83b1                	srli	a5,a5,0xc
ffffffffc02050b8:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02050ba:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02050bc:	2ee7f663          	bleu	a4,a5,ffffffffc02053a8 <do_fork+0x372>
ffffffffc02050c0:	000a7b17          	auipc	s6,0xa7
ffffffffc02050c4:	398b0b13          	addi	s6,s6,920 # ffffffffc02ac458 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02050c8:	000a3703          	ld	a4,0(s4)
ffffffffc02050cc:	000b3783          	ld	a5,0(s6)
ffffffffc02050d0:	02873a03          	ld	s4,40(a4)
ffffffffc02050d4:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02050d6:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc02050d8:	020a0863          	beqz	s4,ffffffffc0205108 <do_fork+0xd2>
    if (clone_flags & CLONE_VM) {
ffffffffc02050dc:	100afa93          	andi	s5,s5,256
ffffffffc02050e0:	1e0a8163          	beqz	s5,ffffffffc02052c2 <do_fork+0x28c>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc02050e4:	030a2703          	lw	a4,48(s4)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050e8:	018a3783          	ld	a5,24(s4)
ffffffffc02050ec:	c02006b7          	lui	a3,0xc0200
ffffffffc02050f0:	2705                	addiw	a4,a4,1
ffffffffc02050f2:	02ea2823          	sw	a4,48(s4)
    proc->mm = mm;
ffffffffc02050f6:	03443423          	sd	s4,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050fa:	2cd7e363          	bltu	a5,a3,ffffffffc02053c0 <do_fork+0x38a>
ffffffffc02050fe:	000b3703          	ld	a4,0(s6)
ffffffffc0205102:	6814                	ld	a3,16(s0)
ffffffffc0205104:	8f99                	sub	a5,a5,a4
ffffffffc0205106:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205108:	6789                	lui	a5,0x2
ffffffffc020510a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>
ffffffffc020510e:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0205110:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205112:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205114:	87b6                	mv	a5,a3
ffffffffc0205116:	12048893          	addi	a7,s1,288
ffffffffc020511a:	00063803          	ld	a6,0(a2)
ffffffffc020511e:	6608                	ld	a0,8(a2)
ffffffffc0205120:	6a0c                	ld	a1,16(a2)
ffffffffc0205122:	6e18                	ld	a4,24(a2)
ffffffffc0205124:	0107b023          	sd	a6,0(a5)
ffffffffc0205128:	e788                	sd	a0,8(a5)
ffffffffc020512a:	eb8c                	sd	a1,16(a5)
ffffffffc020512c:	ef98                	sd	a4,24(a5)
ffffffffc020512e:	02060613          	addi	a2,a2,32
ffffffffc0205132:	02078793          	addi	a5,a5,32
ffffffffc0205136:	ff1612e3          	bne	a2,a7,ffffffffc020511a <do_fork+0xe4>
    proc->tf->gpr.a0 = 0;
ffffffffc020513a:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020513e:	12098b63          	beqz	s3,ffffffffc0205274 <do_fork+0x23e>
ffffffffc0205142:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205146:	00000797          	auipc	a5,0x0
ffffffffc020514a:	c6278793          	addi	a5,a5,-926 # ffffffffc0204da8 <forkret>
ffffffffc020514e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205150:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205152:	100027f3          	csrr	a5,sstatus
ffffffffc0205156:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205158:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020515a:	12079c63          	bnez	a5,ffffffffc0205292 <do_fork+0x25c>
    if (++ last_pid >= MAX_PID) {
ffffffffc020515e:	0009c797          	auipc	a5,0x9c
ffffffffc0205162:	e8278793          	addi	a5,a5,-382 # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc0205166:	439c                	lw	a5,0(a5)
ffffffffc0205168:	6709                	lui	a4,0x2
ffffffffc020516a:	0017851b          	addiw	a0,a5,1
ffffffffc020516e:	0009c697          	auipc	a3,0x9c
ffffffffc0205172:	e6a6a923          	sw	a0,-398(a3) # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc0205176:	12e55f63          	ble	a4,a0,ffffffffc02052b4 <do_fork+0x27e>
    if (last_pid >= next_safe) {
ffffffffc020517a:	0009c797          	auipc	a5,0x9c
ffffffffc020517e:	e6a78793          	addi	a5,a5,-406 # ffffffffc02a0fe4 <next_safe.1690>
ffffffffc0205182:	439c                	lw	a5,0(a5)
ffffffffc0205184:	000a7497          	auipc	s1,0xa7
ffffffffc0205188:	3e448493          	addi	s1,s1,996 # ffffffffc02ac568 <proc_list>
ffffffffc020518c:	06f54063          	blt	a0,a5,ffffffffc02051ec <do_fork+0x1b6>
        next_safe = MAX_PID;
ffffffffc0205190:	6789                	lui	a5,0x2
ffffffffc0205192:	0009c717          	auipc	a4,0x9c
ffffffffc0205196:	e4f72923          	sw	a5,-430(a4) # ffffffffc02a0fe4 <next_safe.1690>
ffffffffc020519a:	4581                	li	a1,0
ffffffffc020519c:	87aa                	mv	a5,a0
ffffffffc020519e:	000a7497          	auipc	s1,0xa7
ffffffffc02051a2:	3ca48493          	addi	s1,s1,970 # ffffffffc02ac568 <proc_list>
    repeat:
ffffffffc02051a6:	6889                	lui	a7,0x2
ffffffffc02051a8:	882e                	mv	a6,a1
ffffffffc02051aa:	6609                	lui	a2,0x2
        le = list;
ffffffffc02051ac:	000a7697          	auipc	a3,0xa7
ffffffffc02051b0:	3bc68693          	addi	a3,a3,956 # ffffffffc02ac568 <proc_list>
ffffffffc02051b4:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc02051b6:	00968f63          	beq	a3,s1,ffffffffc02051d4 <do_fork+0x19e>
            if (proc->pid == last_pid) {
ffffffffc02051ba:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02051be:	0ae78663          	beq	a5,a4,ffffffffc020526a <do_fork+0x234>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02051c2:	fee7d9e3          	ble	a4,a5,ffffffffc02051b4 <do_fork+0x17e>
ffffffffc02051c6:	fec757e3          	ble	a2,a4,ffffffffc02051b4 <do_fork+0x17e>
ffffffffc02051ca:	6694                	ld	a3,8(a3)
ffffffffc02051cc:	863a                	mv	a2,a4
ffffffffc02051ce:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc02051d0:	fe9695e3          	bne	a3,s1,ffffffffc02051ba <do_fork+0x184>
ffffffffc02051d4:	c591                	beqz	a1,ffffffffc02051e0 <do_fork+0x1aa>
ffffffffc02051d6:	0009c717          	auipc	a4,0x9c
ffffffffc02051da:	e0f72523          	sw	a5,-502(a4) # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc02051de:	853e                	mv	a0,a5
ffffffffc02051e0:	00080663          	beqz	a6,ffffffffc02051ec <do_fork+0x1b6>
ffffffffc02051e4:	0009c797          	auipc	a5,0x9c
ffffffffc02051e8:	e0c7a023          	sw	a2,-512(a5) # ffffffffc02a0fe4 <next_safe.1690>
        proc->pid = get_pid();
ffffffffc02051ec:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051ee:	45a9                	li	a1,10
ffffffffc02051f0:	2501                	sext.w	a0,a0
ffffffffc02051f2:	44e010ef          	jal	ra,ffffffffc0206640 <hash32>
ffffffffc02051f6:	1502                	slli	a0,a0,0x20
ffffffffc02051f8:	000a3797          	auipc	a5,0xa3
ffffffffc02051fc:	1f078793          	addi	a5,a5,496 # ffffffffc02a83e8 <hash_list>
ffffffffc0205200:	8171                	srli	a0,a0,0x1c
ffffffffc0205202:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205204:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205206:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205208:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020520c:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020520e:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205210:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205212:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205214:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0205218:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020521a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020521c:	e21c                	sd	a5,0(a2)
ffffffffc020521e:	000a7597          	auipc	a1,0xa7
ffffffffc0205222:	34f5b923          	sd	a5,850(a1) # ffffffffc02ac570 <proc_list+0x8>
    elm->next = next;
ffffffffc0205226:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0205228:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc020522a:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020522e:	10e43023          	sd	a4,256(s0)
ffffffffc0205232:	c311                	beqz	a4,ffffffffc0205236 <do_fork+0x200>
        proc->optr->yptr = proc;
ffffffffc0205234:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc0205236:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc020523a:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc020523c:	2785                	addiw	a5,a5,1
ffffffffc020523e:	000a7717          	auipc	a4,0xa7
ffffffffc0205242:	20f72123          	sw	a5,514(a4) # ffffffffc02ac440 <nr_process>
    if (flag) {
ffffffffc0205246:	0c099e63          	bnez	s3,ffffffffc0205322 <do_fork+0x2ec>
    wakeup_proc(proc);
ffffffffc020524a:	8522                	mv	a0,s0
ffffffffc020524c:	543000ef          	jal	ra,ffffffffc0205f8e <wakeup_proc>
    ret = proc->pid;
ffffffffc0205250:	4048                	lw	a0,4(s0)
}
ffffffffc0205252:	60a6                	ld	ra,72(sp)
ffffffffc0205254:	6406                	ld	s0,64(sp)
ffffffffc0205256:	74e2                	ld	s1,56(sp)
ffffffffc0205258:	7942                	ld	s2,48(sp)
ffffffffc020525a:	79a2                	ld	s3,40(sp)
ffffffffc020525c:	7a02                	ld	s4,32(sp)
ffffffffc020525e:	6ae2                	ld	s5,24(sp)
ffffffffc0205260:	6b42                	ld	s6,16(sp)
ffffffffc0205262:	6ba2                	ld	s7,8(sp)
ffffffffc0205264:	6c02                	ld	s8,0(sp)
ffffffffc0205266:	6161                	addi	sp,sp,80
ffffffffc0205268:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc020526a:	2785                	addiw	a5,a5,1
ffffffffc020526c:	0ac7de63          	ble	a2,a5,ffffffffc0205328 <do_fork+0x2f2>
ffffffffc0205270:	4585                	li	a1,1
ffffffffc0205272:	b789                	j	ffffffffc02051b4 <do_fork+0x17e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205274:	89b6                	mv	s3,a3
ffffffffc0205276:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020527a:	00000797          	auipc	a5,0x0
ffffffffc020527e:	b2e78793          	addi	a5,a5,-1234 # ffffffffc0204da8 <forkret>
ffffffffc0205282:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205284:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205286:	100027f3          	csrr	a5,sstatus
ffffffffc020528a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020528c:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020528e:	ec0788e3          	beqz	a5,ffffffffc020515e <do_fork+0x128>
        intr_disable();
ffffffffc0205292:	bcafb0ef          	jal	ra,ffffffffc020065c <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205296:	0009c797          	auipc	a5,0x9c
ffffffffc020529a:	d4a78793          	addi	a5,a5,-694 # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc020529e:	439c                	lw	a5,0(a5)
ffffffffc02052a0:	6709                	lui	a4,0x2
        return 1;
ffffffffc02052a2:	4985                	li	s3,1
ffffffffc02052a4:	0017851b          	addiw	a0,a5,1
ffffffffc02052a8:	0009c697          	auipc	a3,0x9c
ffffffffc02052ac:	d2a6ac23          	sw	a0,-712(a3) # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc02052b0:	ece545e3          	blt	a0,a4,ffffffffc020517a <do_fork+0x144>
        last_pid = 1;
ffffffffc02052b4:	4785                	li	a5,1
ffffffffc02052b6:	0009c717          	auipc	a4,0x9c
ffffffffc02052ba:	d2f72523          	sw	a5,-726(a4) # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc02052be:	4505                	li	a0,1
ffffffffc02052c0:	bdc1                	j	ffffffffc0205190 <do_fork+0x15a>
    if ((mm = mm_create()) == NULL) {
ffffffffc02052c2:	946fd0ef          	jal	ra,ffffffffc0202408 <mm_create>
ffffffffc02052c6:	8c2a                	mv	s8,a0
ffffffffc02052c8:	c921                	beqz	a0,ffffffffc0205318 <do_fork+0x2e2>
    if (setup_pgdir(mm) != 0) {
ffffffffc02052ca:	befff0ef          	jal	ra,ffffffffc0204eb8 <setup_pgdir>
ffffffffc02052ce:	e135                	bnez	a0,ffffffffc0205332 <do_fork+0x2fc>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02052d0:	038a0a93          	addi	s5,s4,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02052d4:	4785                	li	a5,1
ffffffffc02052d6:	40fab7af          	amoor.d	a5,a5,(s5)
ffffffffc02052da:	8b85                	andi	a5,a5,1
ffffffffc02052dc:	4b85                	li	s7,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02052de:	c799                	beqz	a5,ffffffffc02052ec <do_fork+0x2b6>
        schedule();
ffffffffc02052e0:	52b000ef          	jal	ra,ffffffffc020600a <schedule>
ffffffffc02052e4:	417ab7af          	amoor.d	a5,s7,(s5)
ffffffffc02052e8:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc02052ea:	fbfd                	bnez	a5,ffffffffc02052e0 <do_fork+0x2aa>
        ret = dup_mmap(mm, oldmm);
ffffffffc02052ec:	85d2                	mv	a1,s4
ffffffffc02052ee:	8562                	mv	a0,s8
ffffffffc02052f0:	ba2fd0ef          	jal	ra,ffffffffc0202692 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02052f4:	57f9                	li	a5,-2
ffffffffc02052f6:	60fab7af          	amoand.d	a5,a5,(s5)
ffffffffc02052fa:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02052fc:	0c078f63          	beqz	a5,ffffffffc02053da <do_fork+0x3a4>
    if (ret != 0) {
ffffffffc0205300:	8a62                	mv	s4,s8
ffffffffc0205302:	de0501e3          	beqz	a0,ffffffffc02050e4 <do_fork+0xae>
    exit_mmap(mm);
ffffffffc0205306:	8562                	mv	a0,s8
ffffffffc0205308:	c26fd0ef          	jal	ra,ffffffffc020272e <exit_mmap>
    put_pgdir(mm);
ffffffffc020530c:	8562                	mv	a0,s8
ffffffffc020530e:	b2dff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
    mm_destroy(mm);
ffffffffc0205312:	8562                	mv	a0,s8
ffffffffc0205314:	a7afd0ef          	jal	ra,ffffffffc020258e <mm_destroy>
    kfree(proc);
ffffffffc0205318:	8522                	mv	a0,s0
ffffffffc020531a:	fe6fe0ef          	jal	ra,ffffffffc0203b00 <kfree>
    ret = -E_NO_MEM;
ffffffffc020531e:	5571                	li	a0,-4
    return ret;
ffffffffc0205320:	bf0d                	j	ffffffffc0205252 <do_fork+0x21c>
        intr_enable();
ffffffffc0205322:	b34fb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0205326:	b715                	j	ffffffffc020524a <do_fork+0x214>
                    if (last_pid >= MAX_PID) {
ffffffffc0205328:	0117c363          	blt	a5,a7,ffffffffc020532e <do_fork+0x2f8>
                        last_pid = 1;
ffffffffc020532c:	4785                	li	a5,1
                    goto repeat;
ffffffffc020532e:	4585                	li	a1,1
ffffffffc0205330:	bda5                	j	ffffffffc02051a8 <do_fork+0x172>
    mm_destroy(mm);
ffffffffc0205332:	8562                	mv	a0,s8
ffffffffc0205334:	a5afd0ef          	jal	ra,ffffffffc020258e <mm_destroy>
ffffffffc0205338:	b7c5                	j	ffffffffc0205318 <do_fork+0x2e2>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020533a:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020533c:	c02007b7          	lui	a5,0xc0200
ffffffffc0205340:	0cf6e563          	bltu	a3,a5,ffffffffc020540a <do_fork+0x3d4>
ffffffffc0205344:	000a7797          	auipc	a5,0xa7
ffffffffc0205348:	11478793          	addi	a5,a5,276 # ffffffffc02ac458 <va_pa_offset>
ffffffffc020534c:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020534e:	000a7717          	auipc	a4,0xa7
ffffffffc0205352:	0b270713          	addi	a4,a4,178 # ffffffffc02ac400 <npage>
ffffffffc0205356:	6318                	ld	a4,0(a4)
    return pa2page(PADDR(kva));
ffffffffc0205358:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020535c:	83b1                	srli	a5,a5,0xc
ffffffffc020535e:	08e7fa63          	bleu	a4,a5,ffffffffc02053f2 <do_fork+0x3bc>
    return &pages[PPN(pa) - nbase];
ffffffffc0205362:	00004717          	auipc	a4,0x4
ffffffffc0205366:	a2e70713          	addi	a4,a4,-1490 # ffffffffc0208d90 <nbase>
ffffffffc020536a:	6318                	ld	a4,0(a4)
ffffffffc020536c:	000a7697          	auipc	a3,0xa7
ffffffffc0205370:	0fc68693          	addi	a3,a3,252 # ffffffffc02ac468 <pages>
ffffffffc0205374:	6288                	ld	a0,0(a3)
ffffffffc0205376:	8f99                	sub	a5,a5,a4
ffffffffc0205378:	079a                	slli	a5,a5,0x6
ffffffffc020537a:	4589                	li	a1,2
ffffffffc020537c:	953e                	add	a0,a0,a5
ffffffffc020537e:	bb5fb0ef          	jal	ra,ffffffffc0200f32 <free_pages>
ffffffffc0205382:	bf59                	j	ffffffffc0205318 <do_fork+0x2e2>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205384:	556d                	li	a0,-5
ffffffffc0205386:	b5f1                	j	ffffffffc0205252 <do_fork+0x21c>
    assert(current->wait_state == 0);
ffffffffc0205388:	00003697          	auipc	a3,0x3
ffffffffc020538c:	2b068693          	addi	a3,a3,688 # ffffffffc0208638 <default_pmm_manager+0x270>
ffffffffc0205390:	00002617          	auipc	a2,0x2
ffffffffc0205394:	91860613          	addi	a2,a2,-1768 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205398:	1a300593          	li	a1,419
ffffffffc020539c:	00003517          	auipc	a0,0x3
ffffffffc02053a0:	52c50513          	addi	a0,a0,1324 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc02053a4:	e73fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc02053a8:	00002617          	auipc	a2,0x2
ffffffffc02053ac:	ce860613          	addi	a2,a2,-792 # ffffffffc0207090 <commands+0x8c8>
ffffffffc02053b0:	06900593          	li	a1,105
ffffffffc02053b4:	00002517          	auipc	a0,0x2
ffffffffc02053b8:	d3450513          	addi	a0,a0,-716 # ffffffffc02070e8 <commands+0x920>
ffffffffc02053bc:	e5bfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02053c0:	86be                	mv	a3,a5
ffffffffc02053c2:	00002617          	auipc	a2,0x2
ffffffffc02053c6:	da660613          	addi	a2,a2,-602 # ffffffffc0207168 <commands+0x9a0>
ffffffffc02053ca:	16400593          	li	a1,356
ffffffffc02053ce:	00003517          	auipc	a0,0x3
ffffffffc02053d2:	4fa50513          	addi	a0,a0,1274 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc02053d6:	e41fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("Unlock failed.\n");
ffffffffc02053da:	00003617          	auipc	a2,0x3
ffffffffc02053de:	27e60613          	addi	a2,a2,638 # ffffffffc0208658 <default_pmm_manager+0x290>
ffffffffc02053e2:	03100593          	li	a1,49
ffffffffc02053e6:	00003517          	auipc	a0,0x3
ffffffffc02053ea:	28250513          	addi	a0,a0,642 # ffffffffc0208668 <default_pmm_manager+0x2a0>
ffffffffc02053ee:	e29fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02053f2:	00002617          	auipc	a2,0x2
ffffffffc02053f6:	cd660613          	addi	a2,a2,-810 # ffffffffc02070c8 <commands+0x900>
ffffffffc02053fa:	06200593          	li	a1,98
ffffffffc02053fe:	00002517          	auipc	a0,0x2
ffffffffc0205402:	cea50513          	addi	a0,a0,-790 # ffffffffc02070e8 <commands+0x920>
ffffffffc0205406:	e11fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020540a:	00002617          	auipc	a2,0x2
ffffffffc020540e:	d5e60613          	addi	a2,a2,-674 # ffffffffc0207168 <commands+0x9a0>
ffffffffc0205412:	06e00593          	li	a1,110
ffffffffc0205416:	00002517          	auipc	a0,0x2
ffffffffc020541a:	cd250513          	addi	a0,a0,-814 # ffffffffc02070e8 <commands+0x920>
ffffffffc020541e:	df9fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205422 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205422:	7129                	addi	sp,sp,-320
ffffffffc0205424:	fa22                	sd	s0,304(sp)
ffffffffc0205426:	f626                	sd	s1,296(sp)
ffffffffc0205428:	f24a                	sd	s2,288(sp)
ffffffffc020542a:	84ae                	mv	s1,a1
ffffffffc020542c:	892a                	mv	s2,a0
ffffffffc020542e:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205430:	4581                	li	a1,0
ffffffffc0205432:	12000613          	li	a2,288
ffffffffc0205436:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205438:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020543a:	5e5000ef          	jal	ra,ffffffffc020621e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020543e:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205440:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205442:	100027f3          	csrr	a5,sstatus
ffffffffc0205446:	edd7f793          	andi	a5,a5,-291
ffffffffc020544a:	1207e793          	ori	a5,a5,288
ffffffffc020544e:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205450:	860a                	mv	a2,sp
ffffffffc0205452:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205456:	00000797          	auipc	a5,0x0
ffffffffc020545a:	86c78793          	addi	a5,a5,-1940 # ffffffffc0204cc2 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020545e:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205460:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205462:	bd5ff0ef          	jal	ra,ffffffffc0205036 <do_fork>
}
ffffffffc0205466:	70f2                	ld	ra,312(sp)
ffffffffc0205468:	7452                	ld	s0,304(sp)
ffffffffc020546a:	74b2                	ld	s1,296(sp)
ffffffffc020546c:	7912                	ld	s2,288(sp)
ffffffffc020546e:	6131                	addi	sp,sp,320
ffffffffc0205470:	8082                	ret

ffffffffc0205472 <do_exit>:
do_exit(int error_code) {
ffffffffc0205472:	7179                	addi	sp,sp,-48
ffffffffc0205474:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc0205476:	000a7717          	auipc	a4,0xa7
ffffffffc020547a:	fba70713          	addi	a4,a4,-70 # ffffffffc02ac430 <idleproc>
ffffffffc020547e:	000a7917          	auipc	s2,0xa7
ffffffffc0205482:	faa90913          	addi	s2,s2,-86 # ffffffffc02ac428 <current>
ffffffffc0205486:	00093783          	ld	a5,0(s2)
ffffffffc020548a:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc020548c:	f406                	sd	ra,40(sp)
ffffffffc020548e:	f022                	sd	s0,32(sp)
ffffffffc0205490:	ec26                	sd	s1,24(sp)
ffffffffc0205492:	e44e                	sd	s3,8(sp)
ffffffffc0205494:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205496:	0ce78c63          	beq	a5,a4,ffffffffc020556e <do_exit+0xfc>
    if (current == initproc) {
ffffffffc020549a:	000a7417          	auipc	s0,0xa7
ffffffffc020549e:	f9e40413          	addi	s0,s0,-98 # ffffffffc02ac438 <initproc>
ffffffffc02054a2:	6018                	ld	a4,0(s0)
ffffffffc02054a4:	0ee78b63          	beq	a5,a4,ffffffffc020559a <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc02054a8:	7784                	ld	s1,40(a5)
ffffffffc02054aa:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc02054ac:	c48d                	beqz	s1,ffffffffc02054d6 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc02054ae:	000a7797          	auipc	a5,0xa7
ffffffffc02054b2:	fb278793          	addi	a5,a5,-78 # ffffffffc02ac460 <boot_cr3>
ffffffffc02054b6:	639c                	ld	a5,0(a5)
ffffffffc02054b8:	577d                	li	a4,-1
ffffffffc02054ba:	177e                	slli	a4,a4,0x3f
ffffffffc02054bc:	83b1                	srli	a5,a5,0xc
ffffffffc02054be:	8fd9                	or	a5,a5,a4
ffffffffc02054c0:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02054c4:	589c                	lw	a5,48(s1)
ffffffffc02054c6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02054ca:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc02054cc:	cf4d                	beqz	a4,ffffffffc0205586 <do_exit+0x114>
        current->mm = NULL;
ffffffffc02054ce:	00093783          	ld	a5,0(s2)
ffffffffc02054d2:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02054d6:	00093783          	ld	a5,0(s2)
ffffffffc02054da:	470d                	li	a4,3
ffffffffc02054dc:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02054de:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02054e2:	100027f3          	csrr	a5,sstatus
ffffffffc02054e6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02054e8:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02054ea:	e7e1                	bnez	a5,ffffffffc02055b2 <do_exit+0x140>
        proc = current->parent;
ffffffffc02054ec:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054f0:	800007b7          	lui	a5,0x80000
ffffffffc02054f4:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02054f6:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054f8:	0ec52703          	lw	a4,236(a0)
ffffffffc02054fc:	0af70f63          	beq	a4,a5,ffffffffc02055ba <do_exit+0x148>
ffffffffc0205500:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205504:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205508:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020550a:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc020550c:	7afc                	ld	a5,240(a3)
ffffffffc020550e:	cb95                	beqz	a5,ffffffffc0205542 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205510:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5688>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205514:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0205516:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205518:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020551a:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020551e:	10e7b023          	sd	a4,256(a5)
ffffffffc0205522:	c311                	beqz	a4,ffffffffc0205526 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc0205524:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205526:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205528:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020552a:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020552c:	fe9710e3          	bne	a4,s1,ffffffffc020550c <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205530:	0ec52783          	lw	a5,236(a0)
ffffffffc0205534:	fd379ce3          	bne	a5,s3,ffffffffc020550c <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205538:	257000ef          	jal	ra,ffffffffc0205f8e <wakeup_proc>
ffffffffc020553c:	00093683          	ld	a3,0(s2)
ffffffffc0205540:	b7f1                	j	ffffffffc020550c <do_exit+0x9a>
    if (flag) {
ffffffffc0205542:	020a1363          	bnez	s4,ffffffffc0205568 <do_exit+0xf6>
    schedule();
ffffffffc0205546:	2c5000ef          	jal	ra,ffffffffc020600a <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020554a:	00093783          	ld	a5,0(s2)
ffffffffc020554e:	00003617          	auipc	a2,0x3
ffffffffc0205552:	0ca60613          	addi	a2,a2,202 # ffffffffc0208618 <default_pmm_manager+0x250>
ffffffffc0205556:	20300593          	li	a1,515
ffffffffc020555a:	43d4                	lw	a3,4(a5)
ffffffffc020555c:	00003517          	auipc	a0,0x3
ffffffffc0205560:	36c50513          	addi	a0,a0,876 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205564:	cb3fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_enable();
ffffffffc0205568:	8eefb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc020556c:	bfe9                	j	ffffffffc0205546 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc020556e:	00003617          	auipc	a2,0x3
ffffffffc0205572:	08a60613          	addi	a2,a2,138 # ffffffffc02085f8 <default_pmm_manager+0x230>
ffffffffc0205576:	1d700593          	li	a1,471
ffffffffc020557a:	00003517          	auipc	a0,0x3
ffffffffc020557e:	34e50513          	addi	a0,a0,846 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205582:	c95fa0ef          	jal	ra,ffffffffc0200216 <__panic>
            exit_mmap(mm);
ffffffffc0205586:	8526                	mv	a0,s1
ffffffffc0205588:	9a6fd0ef          	jal	ra,ffffffffc020272e <exit_mmap>
            put_pgdir(mm);
ffffffffc020558c:	8526                	mv	a0,s1
ffffffffc020558e:	8adff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
            mm_destroy(mm);
ffffffffc0205592:	8526                	mv	a0,s1
ffffffffc0205594:	ffbfc0ef          	jal	ra,ffffffffc020258e <mm_destroy>
ffffffffc0205598:	bf1d                	j	ffffffffc02054ce <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc020559a:	00003617          	auipc	a2,0x3
ffffffffc020559e:	06e60613          	addi	a2,a2,110 # ffffffffc0208608 <default_pmm_manager+0x240>
ffffffffc02055a2:	1da00593          	li	a1,474
ffffffffc02055a6:	00003517          	auipc	a0,0x3
ffffffffc02055aa:	32250513          	addi	a0,a0,802 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc02055ae:	c69fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_disable();
ffffffffc02055b2:	8aafb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc02055b6:	4a05                	li	s4,1
ffffffffc02055b8:	bf15                	j	ffffffffc02054ec <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc02055ba:	1d5000ef          	jal	ra,ffffffffc0205f8e <wakeup_proc>
ffffffffc02055be:	b789                	j	ffffffffc0205500 <do_exit+0x8e>

ffffffffc02055c0 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc02055c0:	7139                	addi	sp,sp,-64
ffffffffc02055c2:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc02055c4:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc02055c8:	f426                	sd	s1,40(sp)
ffffffffc02055ca:	f04a                	sd	s2,32(sp)
ffffffffc02055cc:	ec4e                	sd	s3,24(sp)
ffffffffc02055ce:	e456                	sd	s5,8(sp)
ffffffffc02055d0:	e05a                	sd	s6,0(sp)
ffffffffc02055d2:	fc06                	sd	ra,56(sp)
ffffffffc02055d4:	f822                	sd	s0,48(sp)
ffffffffc02055d6:	89aa                	mv	s3,a0
ffffffffc02055d8:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc02055da:	000a7917          	auipc	s2,0xa7
ffffffffc02055de:	e4e90913          	addi	s2,s2,-434 # ffffffffc02ac428 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055e2:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc02055e4:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc02055e6:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc02055e8:	02098f63          	beqz	s3,ffffffffc0205626 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc02055ec:	854e                	mv	a0,s3
ffffffffc02055ee:	9edff0ef          	jal	ra,ffffffffc0204fda <find_proc>
ffffffffc02055f2:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc02055f4:	12050063          	beqz	a0,ffffffffc0205714 <do_wait.part.1+0x154>
ffffffffc02055f8:	00093703          	ld	a4,0(s2)
ffffffffc02055fc:	711c                	ld	a5,32(a0)
ffffffffc02055fe:	10e79b63          	bne	a5,a4,ffffffffc0205714 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205602:	411c                	lw	a5,0(a0)
ffffffffc0205604:	02978c63          	beq	a5,s1,ffffffffc020563c <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205608:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc020560c:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205610:	1fb000ef          	jal	ra,ffffffffc020600a <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205614:	00093783          	ld	a5,0(s2)
ffffffffc0205618:	0b07a783          	lw	a5,176(a5)
ffffffffc020561c:	8b85                	andi	a5,a5,1
ffffffffc020561e:	d7e9                	beqz	a5,ffffffffc02055e8 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205620:	555d                	li	a0,-9
ffffffffc0205622:	e51ff0ef          	jal	ra,ffffffffc0205472 <do_exit>
        proc = current->cptr;
ffffffffc0205626:	00093703          	ld	a4,0(s2)
ffffffffc020562a:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020562c:	e409                	bnez	s0,ffffffffc0205636 <do_wait.part.1+0x76>
ffffffffc020562e:	a0dd                	j	ffffffffc0205714 <do_wait.part.1+0x154>
ffffffffc0205630:	10043403          	ld	s0,256(s0)
ffffffffc0205634:	d871                	beqz	s0,ffffffffc0205608 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205636:	401c                	lw	a5,0(s0)
ffffffffc0205638:	fe979ce3          	bne	a5,s1,ffffffffc0205630 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc020563c:	000a7797          	auipc	a5,0xa7
ffffffffc0205640:	df478793          	addi	a5,a5,-524 # ffffffffc02ac430 <idleproc>
ffffffffc0205644:	639c                	ld	a5,0(a5)
ffffffffc0205646:	0c878d63          	beq	a5,s0,ffffffffc0205720 <do_wait.part.1+0x160>
ffffffffc020564a:	000a7797          	auipc	a5,0xa7
ffffffffc020564e:	dee78793          	addi	a5,a5,-530 # ffffffffc02ac438 <initproc>
ffffffffc0205652:	639c                	ld	a5,0(a5)
ffffffffc0205654:	0cf40663          	beq	s0,a5,ffffffffc0205720 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc0205658:	000b0663          	beqz	s6,ffffffffc0205664 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc020565c:	0e842783          	lw	a5,232(s0)
ffffffffc0205660:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205664:	100027f3          	csrr	a5,sstatus
ffffffffc0205668:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020566a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020566c:	e7d5                	bnez	a5,ffffffffc0205718 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc020566e:	6c70                	ld	a2,216(s0)
ffffffffc0205670:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205672:	10043703          	ld	a4,256(s0)
ffffffffc0205676:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205678:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020567a:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020567c:	6470                	ld	a2,200(s0)
ffffffffc020567e:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205680:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205682:	e290                	sd	a2,0(a3)
ffffffffc0205684:	c319                	beqz	a4,ffffffffc020568a <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205686:	ff7c                	sd	a5,248(a4)
ffffffffc0205688:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc020568a:	c3d1                	beqz	a5,ffffffffc020570e <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc020568c:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205690:	000a7797          	auipc	a5,0xa7
ffffffffc0205694:	db078793          	addi	a5,a5,-592 # ffffffffc02ac440 <nr_process>
ffffffffc0205698:	439c                	lw	a5,0(a5)
ffffffffc020569a:	37fd                	addiw	a5,a5,-1
ffffffffc020569c:	000a7717          	auipc	a4,0xa7
ffffffffc02056a0:	daf72223          	sw	a5,-604(a4) # ffffffffc02ac440 <nr_process>
    if (flag) {
ffffffffc02056a4:	e1b5                	bnez	a1,ffffffffc0205708 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02056a6:	6814                	ld	a3,16(s0)
ffffffffc02056a8:	c02007b7          	lui	a5,0xc0200
ffffffffc02056ac:	0af6e263          	bltu	a3,a5,ffffffffc0205750 <do_wait.part.1+0x190>
ffffffffc02056b0:	000a7797          	auipc	a5,0xa7
ffffffffc02056b4:	da878793          	addi	a5,a5,-600 # ffffffffc02ac458 <va_pa_offset>
ffffffffc02056b8:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02056ba:	000a7797          	auipc	a5,0xa7
ffffffffc02056be:	d4678793          	addi	a5,a5,-698 # ffffffffc02ac400 <npage>
ffffffffc02056c2:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02056c4:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02056c6:	82b1                	srli	a3,a3,0xc
ffffffffc02056c8:	06f6f863          	bleu	a5,a3,ffffffffc0205738 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc02056cc:	00003797          	auipc	a5,0x3
ffffffffc02056d0:	6c478793          	addi	a5,a5,1732 # ffffffffc0208d90 <nbase>
ffffffffc02056d4:	639c                	ld	a5,0(a5)
ffffffffc02056d6:	000a7717          	auipc	a4,0xa7
ffffffffc02056da:	d9270713          	addi	a4,a4,-622 # ffffffffc02ac468 <pages>
ffffffffc02056de:	6308                	ld	a0,0(a4)
ffffffffc02056e0:	8e9d                	sub	a3,a3,a5
ffffffffc02056e2:	069a                	slli	a3,a3,0x6
ffffffffc02056e4:	9536                	add	a0,a0,a3
ffffffffc02056e6:	4589                	li	a1,2
ffffffffc02056e8:	84bfb0ef          	jal	ra,ffffffffc0200f32 <free_pages>
    kfree(proc);
ffffffffc02056ec:	8522                	mv	a0,s0
ffffffffc02056ee:	c12fe0ef          	jal	ra,ffffffffc0203b00 <kfree>
    return 0;
ffffffffc02056f2:	4501                	li	a0,0
}
ffffffffc02056f4:	70e2                	ld	ra,56(sp)
ffffffffc02056f6:	7442                	ld	s0,48(sp)
ffffffffc02056f8:	74a2                	ld	s1,40(sp)
ffffffffc02056fa:	7902                	ld	s2,32(sp)
ffffffffc02056fc:	69e2                	ld	s3,24(sp)
ffffffffc02056fe:	6a42                	ld	s4,16(sp)
ffffffffc0205700:	6aa2                	ld	s5,8(sp)
ffffffffc0205702:	6b02                	ld	s6,0(sp)
ffffffffc0205704:	6121                	addi	sp,sp,64
ffffffffc0205706:	8082                	ret
        intr_enable();
ffffffffc0205708:	f4ffa0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc020570c:	bf69                	j	ffffffffc02056a6 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc020570e:	701c                	ld	a5,32(s0)
ffffffffc0205710:	fbf8                	sd	a4,240(a5)
ffffffffc0205712:	bfbd                	j	ffffffffc0205690 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205714:	5579                	li	a0,-2
ffffffffc0205716:	bff9                	j	ffffffffc02056f4 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0205718:	f45fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc020571c:	4585                	li	a1,1
ffffffffc020571e:	bf81                	j	ffffffffc020566e <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205720:	00003617          	auipc	a2,0x3
ffffffffc0205724:	f6060613          	addi	a2,a2,-160 # ffffffffc0208680 <default_pmm_manager+0x2b8>
ffffffffc0205728:	2fa00593          	li	a1,762
ffffffffc020572c:	00003517          	auipc	a0,0x3
ffffffffc0205730:	19c50513          	addi	a0,a0,412 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205734:	ae3fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205738:	00002617          	auipc	a2,0x2
ffffffffc020573c:	99060613          	addi	a2,a2,-1648 # ffffffffc02070c8 <commands+0x900>
ffffffffc0205740:	06200593          	li	a1,98
ffffffffc0205744:	00002517          	auipc	a0,0x2
ffffffffc0205748:	9a450513          	addi	a0,a0,-1628 # ffffffffc02070e8 <commands+0x920>
ffffffffc020574c:	acbfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205750:	00002617          	auipc	a2,0x2
ffffffffc0205754:	a1860613          	addi	a2,a2,-1512 # ffffffffc0207168 <commands+0x9a0>
ffffffffc0205758:	06e00593          	li	a1,110
ffffffffc020575c:	00002517          	auipc	a0,0x2
ffffffffc0205760:	98c50513          	addi	a0,a0,-1652 # ffffffffc02070e8 <commands+0x920>
ffffffffc0205764:	ab3fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205768 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205768:	1141                	addi	sp,sp,-16
ffffffffc020576a:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020576c:	80dfb0ef          	jal	ra,ffffffffc0200f78 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205770:	ad0fe0ef          	jal	ra,ffffffffc0203a40 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205774:	4601                	li	a2,0
ffffffffc0205776:	4581                	li	a1,0
ffffffffc0205778:	fffff517          	auipc	a0,0xfffff
ffffffffc020577c:	64050513          	addi	a0,a0,1600 # ffffffffc0204db8 <user_main>
ffffffffc0205780:	ca3ff0ef          	jal	ra,ffffffffc0205422 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205784:	00a04563          	bgtz	a0,ffffffffc020578e <init_main+0x26>
ffffffffc0205788:	a841                	j	ffffffffc0205818 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc020578a:	081000ef          	jal	ra,ffffffffc020600a <schedule>
    if (code_store != NULL) {
ffffffffc020578e:	4581                	li	a1,0
ffffffffc0205790:	4501                	li	a0,0
ffffffffc0205792:	e2fff0ef          	jal	ra,ffffffffc02055c0 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205796:	d975                	beqz	a0,ffffffffc020578a <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205798:	00003517          	auipc	a0,0x3
ffffffffc020579c:	f2850513          	addi	a0,a0,-216 # ffffffffc02086c0 <default_pmm_manager+0x2f8>
ffffffffc02057a0:	931fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02057a4:	000a7797          	auipc	a5,0xa7
ffffffffc02057a8:	c9478793          	addi	a5,a5,-876 # ffffffffc02ac438 <initproc>
ffffffffc02057ac:	639c                	ld	a5,0(a5)
ffffffffc02057ae:	7bf8                	ld	a4,240(a5)
ffffffffc02057b0:	e721                	bnez	a4,ffffffffc02057f8 <init_main+0x90>
ffffffffc02057b2:	7ff8                	ld	a4,248(a5)
ffffffffc02057b4:	e331                	bnez	a4,ffffffffc02057f8 <init_main+0x90>
ffffffffc02057b6:	1007b703          	ld	a4,256(a5)
ffffffffc02057ba:	ef1d                	bnez	a4,ffffffffc02057f8 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc02057bc:	000a7717          	auipc	a4,0xa7
ffffffffc02057c0:	c8470713          	addi	a4,a4,-892 # ffffffffc02ac440 <nr_process>
ffffffffc02057c4:	4314                	lw	a3,0(a4)
ffffffffc02057c6:	4709                	li	a4,2
ffffffffc02057c8:	0ae69463          	bne	a3,a4,ffffffffc0205870 <init_main+0x108>
    return listelm->next;
ffffffffc02057cc:	000a7697          	auipc	a3,0xa7
ffffffffc02057d0:	d9c68693          	addi	a3,a3,-612 # ffffffffc02ac568 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057d4:	6698                	ld	a4,8(a3)
ffffffffc02057d6:	0c878793          	addi	a5,a5,200
ffffffffc02057da:	06f71b63          	bne	a4,a5,ffffffffc0205850 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057de:	629c                	ld	a5,0(a3)
ffffffffc02057e0:	04f71863          	bne	a4,a5,ffffffffc0205830 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc02057e4:	00003517          	auipc	a0,0x3
ffffffffc02057e8:	fc450513          	addi	a0,a0,-60 # ffffffffc02087a8 <default_pmm_manager+0x3e0>
ffffffffc02057ec:	8e5fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc02057f0:	60a2                	ld	ra,8(sp)
ffffffffc02057f2:	4501                	li	a0,0
ffffffffc02057f4:	0141                	addi	sp,sp,16
ffffffffc02057f6:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02057f8:	00003697          	auipc	a3,0x3
ffffffffc02057fc:	ef068693          	addi	a3,a3,-272 # ffffffffc02086e8 <default_pmm_manager+0x320>
ffffffffc0205800:	00001617          	auipc	a2,0x1
ffffffffc0205804:	4a860613          	addi	a2,a2,1192 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205808:	35f00593          	li	a1,863
ffffffffc020580c:	00003517          	auipc	a0,0x3
ffffffffc0205810:	0bc50513          	addi	a0,a0,188 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205814:	a03fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205818:	00003617          	auipc	a2,0x3
ffffffffc020581c:	e8860613          	addi	a2,a2,-376 # ffffffffc02086a0 <default_pmm_manager+0x2d8>
ffffffffc0205820:	35700593          	li	a1,855
ffffffffc0205824:	00003517          	auipc	a0,0x3
ffffffffc0205828:	0a450513          	addi	a0,a0,164 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc020582c:	9ebfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205830:	00003697          	auipc	a3,0x3
ffffffffc0205834:	f4868693          	addi	a3,a3,-184 # ffffffffc0208778 <default_pmm_manager+0x3b0>
ffffffffc0205838:	00001617          	auipc	a2,0x1
ffffffffc020583c:	47060613          	addi	a2,a2,1136 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205840:	36200593          	li	a1,866
ffffffffc0205844:	00003517          	auipc	a0,0x3
ffffffffc0205848:	08450513          	addi	a0,a0,132 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc020584c:	9cbfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205850:	00003697          	auipc	a3,0x3
ffffffffc0205854:	ef868693          	addi	a3,a3,-264 # ffffffffc0208748 <default_pmm_manager+0x380>
ffffffffc0205858:	00001617          	auipc	a2,0x1
ffffffffc020585c:	45060613          	addi	a2,a2,1104 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205860:	36100593          	li	a1,865
ffffffffc0205864:	00003517          	auipc	a0,0x3
ffffffffc0205868:	06450513          	addi	a0,a0,100 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc020586c:	9abfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_process == 2);
ffffffffc0205870:	00003697          	auipc	a3,0x3
ffffffffc0205874:	ec868693          	addi	a3,a3,-312 # ffffffffc0208738 <default_pmm_manager+0x370>
ffffffffc0205878:	00001617          	auipc	a2,0x1
ffffffffc020587c:	43060613          	addi	a2,a2,1072 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205880:	36000593          	li	a1,864
ffffffffc0205884:	00003517          	auipc	a0,0x3
ffffffffc0205888:	04450513          	addi	a0,a0,68 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc020588c:	98bfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205890 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205890:	7135                	addi	sp,sp,-160
ffffffffc0205892:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205894:	000a7a17          	auipc	s4,0xa7
ffffffffc0205898:	b94a0a13          	addi	s4,s4,-1132 # ffffffffc02ac428 <current>
ffffffffc020589c:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058a0:	e14a                	sd	s2,128(sp)
ffffffffc02058a2:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02058a4:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058a8:	fcce                	sd	s3,120(sp)
ffffffffc02058aa:	f0da                	sd	s6,96(sp)
ffffffffc02058ac:	89aa                	mv	s3,a0
ffffffffc02058ae:	842e                	mv	s0,a1
ffffffffc02058b0:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02058b2:	4681                	li	a3,0
ffffffffc02058b4:	862e                	mv	a2,a1
ffffffffc02058b6:	85aa                	mv	a1,a0
ffffffffc02058b8:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058ba:	ed06                	sd	ra,152(sp)
ffffffffc02058bc:	e526                	sd	s1,136(sp)
ffffffffc02058be:	f4d6                	sd	s5,104(sp)
ffffffffc02058c0:	ecde                	sd	s7,88(sp)
ffffffffc02058c2:	e8e2                	sd	s8,80(sp)
ffffffffc02058c4:	e4e6                	sd	s9,72(sp)
ffffffffc02058c6:	e0ea                	sd	s10,64(sp)
ffffffffc02058c8:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02058ca:	d06fd0ef          	jal	ra,ffffffffc0202dd0 <user_mem_check>
ffffffffc02058ce:	40050463          	beqz	a0,ffffffffc0205cd6 <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02058d2:	4641                	li	a2,16
ffffffffc02058d4:	4581                	li	a1,0
ffffffffc02058d6:	1008                	addi	a0,sp,32
ffffffffc02058d8:	147000ef          	jal	ra,ffffffffc020621e <memset>
    memcpy(local_name, name, len);
ffffffffc02058dc:	47bd                	li	a5,15
ffffffffc02058de:	8622                	mv	a2,s0
ffffffffc02058e0:	0687ee63          	bltu	a5,s0,ffffffffc020595c <do_execve+0xcc>
ffffffffc02058e4:	85ce                	mv	a1,s3
ffffffffc02058e6:	1008                	addi	a0,sp,32
ffffffffc02058e8:	149000ef          	jal	ra,ffffffffc0206230 <memcpy>
    if (mm != NULL) {
ffffffffc02058ec:	06090f63          	beqz	s2,ffffffffc020596a <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc02058f0:	00002517          	auipc	a0,0x2
ffffffffc02058f4:	f6850513          	addi	a0,a0,-152 # ffffffffc0207858 <commands+0x1090>
ffffffffc02058f8:	811fa0ef          	jal	ra,ffffffffc0200108 <cputs>
        lcr3(boot_cr3);
ffffffffc02058fc:	000a7797          	auipc	a5,0xa7
ffffffffc0205900:	b6478793          	addi	a5,a5,-1180 # ffffffffc02ac460 <boot_cr3>
ffffffffc0205904:	639c                	ld	a5,0(a5)
ffffffffc0205906:	577d                	li	a4,-1
ffffffffc0205908:	177e                	slli	a4,a4,0x3f
ffffffffc020590a:	83b1                	srli	a5,a5,0xc
ffffffffc020590c:	8fd9                	or	a5,a5,a4
ffffffffc020590e:	18079073          	csrw	satp,a5
ffffffffc0205912:	03092783          	lw	a5,48(s2)
ffffffffc0205916:	fff7871b          	addiw	a4,a5,-1
ffffffffc020591a:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc020591e:	28070b63          	beqz	a4,ffffffffc0205bb4 <do_execve+0x324>
        current->mm = NULL;
ffffffffc0205922:	000a3783          	ld	a5,0(s4)
ffffffffc0205926:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc020592a:	adffc0ef          	jal	ra,ffffffffc0202408 <mm_create>
ffffffffc020592e:	892a                	mv	s2,a0
ffffffffc0205930:	c135                	beqz	a0,ffffffffc0205994 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205932:	d86ff0ef          	jal	ra,ffffffffc0204eb8 <setup_pgdir>
ffffffffc0205936:	e931                	bnez	a0,ffffffffc020598a <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205938:	000b2703          	lw	a4,0(s6)
ffffffffc020593c:	464c47b7          	lui	a5,0x464c4
ffffffffc0205940:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9b07>
ffffffffc0205944:	04f70a63          	beq	a4,a5,ffffffffc0205998 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205948:	854a                	mv	a0,s2
ffffffffc020594a:	cf0ff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
    mm_destroy(mm);
ffffffffc020594e:	854a                	mv	a0,s2
ffffffffc0205950:	c3ffc0ef          	jal	ra,ffffffffc020258e <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205954:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0205956:	854e                	mv	a0,s3
ffffffffc0205958:	b1bff0ef          	jal	ra,ffffffffc0205472 <do_exit>
    memcpy(local_name, name, len);
ffffffffc020595c:	463d                	li	a2,15
ffffffffc020595e:	85ce                	mv	a1,s3
ffffffffc0205960:	1008                	addi	a0,sp,32
ffffffffc0205962:	0cf000ef          	jal	ra,ffffffffc0206230 <memcpy>
    if (mm != NULL) {
ffffffffc0205966:	f80915e3          	bnez	s2,ffffffffc02058f0 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc020596a:	000a3783          	ld	a5,0(s4)
ffffffffc020596e:	779c                	ld	a5,40(a5)
ffffffffc0205970:	dfcd                	beqz	a5,ffffffffc020592a <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205972:	00003617          	auipc	a2,0x3
ffffffffc0205976:	afe60613          	addi	a2,a2,-1282 # ffffffffc0208470 <default_pmm_manager+0xa8>
ffffffffc020597a:	20d00593          	li	a1,525
ffffffffc020597e:	00003517          	auipc	a0,0x3
ffffffffc0205982:	f4a50513          	addi	a0,a0,-182 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205986:	891fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    mm_destroy(mm);
ffffffffc020598a:	854a                	mv	a0,s2
ffffffffc020598c:	c03fc0ef          	jal	ra,ffffffffc020258e <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205990:	59f1                	li	s3,-4
ffffffffc0205992:	b7d1                	j	ffffffffc0205956 <do_execve+0xc6>
ffffffffc0205994:	59f1                	li	s3,-4
ffffffffc0205996:	b7c1                	j	ffffffffc0205956 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205998:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020599c:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059a0:	00371793          	slli	a5,a4,0x3
ffffffffc02059a4:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02059a6:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059a8:	078e                	slli	a5,a5,0x3
ffffffffc02059aa:	97a2                	add	a5,a5,s0
ffffffffc02059ac:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02059ae:	02f47b63          	bleu	a5,s0,ffffffffc02059e4 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc02059b2:	5bfd                	li	s7,-1
ffffffffc02059b4:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc02059b8:	000a7d97          	auipc	s11,0xa7
ffffffffc02059bc:	ab0d8d93          	addi	s11,s11,-1360 # ffffffffc02ac468 <pages>
ffffffffc02059c0:	00003d17          	auipc	s10,0x3
ffffffffc02059c4:	3d0d0d13          	addi	s10,s10,976 # ffffffffc0208d90 <nbase>
    return KADDR(page2pa(page));
ffffffffc02059c8:	e43e                	sd	a5,8(sp)
ffffffffc02059ca:	000a7c97          	auipc	s9,0xa7
ffffffffc02059ce:	a36c8c93          	addi	s9,s9,-1482 # ffffffffc02ac400 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02059d2:	4018                	lw	a4,0(s0)
ffffffffc02059d4:	4785                	li	a5,1
ffffffffc02059d6:	0ef70d63          	beq	a4,a5,ffffffffc0205ad0 <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc02059da:	67e2                	ld	a5,24(sp)
ffffffffc02059dc:	03840413          	addi	s0,s0,56
ffffffffc02059e0:	fef469e3          	bltu	s0,a5,ffffffffc02059d2 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02059e4:	4701                	li	a4,0
ffffffffc02059e6:	46ad                	li	a3,11
ffffffffc02059e8:	00100637          	lui	a2,0x100
ffffffffc02059ec:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02059f0:	854a                	mv	a0,s2
ffffffffc02059f2:	beffc0ef          	jal	ra,ffffffffc02025e0 <mm_map>
ffffffffc02059f6:	89aa                	mv	s3,a0
ffffffffc02059f8:	1a051463          	bnez	a0,ffffffffc0205ba0 <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02059fc:	01893503          	ld	a0,24(s2)
ffffffffc0205a00:	467d                	li	a2,31
ffffffffc0205a02:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205a06:	94bfc0ef          	jal	ra,ffffffffc0202350 <pgdir_alloc_page>
ffffffffc0205a0a:	36050263          	beqz	a0,ffffffffc0205d6e <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a0e:	01893503          	ld	a0,24(s2)
ffffffffc0205a12:	467d                	li	a2,31
ffffffffc0205a14:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205a18:	939fc0ef          	jal	ra,ffffffffc0202350 <pgdir_alloc_page>
ffffffffc0205a1c:	32050963          	beqz	a0,ffffffffc0205d4e <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a20:	01893503          	ld	a0,24(s2)
ffffffffc0205a24:	467d                	li	a2,31
ffffffffc0205a26:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205a2a:	927fc0ef          	jal	ra,ffffffffc0202350 <pgdir_alloc_page>
ffffffffc0205a2e:	30050063          	beqz	a0,ffffffffc0205d2e <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a32:	01893503          	ld	a0,24(s2)
ffffffffc0205a36:	467d                	li	a2,31
ffffffffc0205a38:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205a3c:	915fc0ef          	jal	ra,ffffffffc0202350 <pgdir_alloc_page>
ffffffffc0205a40:	2c050763          	beqz	a0,ffffffffc0205d0e <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc0205a44:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205a48:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a4c:	01893683          	ld	a3,24(s2)
ffffffffc0205a50:	2785                	addiw	a5,a5,1
ffffffffc0205a52:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205a56:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55b0>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a5a:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a5e:	28f6ec63          	bltu	a3,a5,ffffffffc0205cf6 <do_execve+0x466>
ffffffffc0205a62:	000a7797          	auipc	a5,0xa7
ffffffffc0205a66:	9f678793          	addi	a5,a5,-1546 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0205a6a:	639c                	ld	a5,0(a5)
ffffffffc0205a6c:	577d                	li	a4,-1
ffffffffc0205a6e:	177e                	slli	a4,a4,0x3f
ffffffffc0205a70:	8e9d                	sub	a3,a3,a5
ffffffffc0205a72:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a76:	f654                	sd	a3,168(a2)
ffffffffc0205a78:	8fd9                	or	a5,a5,a4
ffffffffc0205a7a:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a7e:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a80:	4581                	li	a1,0
ffffffffc0205a82:	12000613          	li	a2,288
ffffffffc0205a86:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a88:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a8c:	792000ef          	jal	ra,ffffffffc020621e <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a90:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a94:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205a96:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a9a:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a9e:	07fe                	slli	a5,a5,0x1f
ffffffffc0205aa0:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205aa2:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205aa6:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205aaa:	100c                	addi	a1,sp,32
ffffffffc0205aac:	c98ff0ef          	jal	ra,ffffffffc0204f44 <set_proc_name>
}
ffffffffc0205ab0:	60ea                	ld	ra,152(sp)
ffffffffc0205ab2:	644a                	ld	s0,144(sp)
ffffffffc0205ab4:	854e                	mv	a0,s3
ffffffffc0205ab6:	64aa                	ld	s1,136(sp)
ffffffffc0205ab8:	690a                	ld	s2,128(sp)
ffffffffc0205aba:	79e6                	ld	s3,120(sp)
ffffffffc0205abc:	7a46                	ld	s4,112(sp)
ffffffffc0205abe:	7aa6                	ld	s5,104(sp)
ffffffffc0205ac0:	7b06                	ld	s6,96(sp)
ffffffffc0205ac2:	6be6                	ld	s7,88(sp)
ffffffffc0205ac4:	6c46                	ld	s8,80(sp)
ffffffffc0205ac6:	6ca6                	ld	s9,72(sp)
ffffffffc0205ac8:	6d06                	ld	s10,64(sp)
ffffffffc0205aca:	7de2                	ld	s11,56(sp)
ffffffffc0205acc:	610d                	addi	sp,sp,160
ffffffffc0205ace:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205ad0:	7410                	ld	a2,40(s0)
ffffffffc0205ad2:	701c                	ld	a5,32(s0)
ffffffffc0205ad4:	20f66363          	bltu	a2,a5,ffffffffc0205cda <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205ad8:	405c                	lw	a5,4(s0)
ffffffffc0205ada:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ade:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205ae2:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ae4:	0e071263          	bnez	a4,ffffffffc0205bc8 <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205ae8:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205aea:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205aec:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205aee:	c789                	beqz	a5,ffffffffc0205af8 <do_execve+0x268>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205af0:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205af2:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205af6:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205af8:	0026f793          	andi	a5,a3,2
ffffffffc0205afc:	efe1                	bnez	a5,ffffffffc0205bd4 <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205afe:	0046f793          	andi	a5,a3,4
ffffffffc0205b02:	c789                	beqz	a5,ffffffffc0205b0c <do_execve+0x27c>
ffffffffc0205b04:	6782                	ld	a5,0(sp)
ffffffffc0205b06:	0087e793          	ori	a5,a5,8
ffffffffc0205b0a:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205b0c:	680c                	ld	a1,16(s0)
ffffffffc0205b0e:	4701                	li	a4,0
ffffffffc0205b10:	854a                	mv	a0,s2
ffffffffc0205b12:	acffc0ef          	jal	ra,ffffffffc02025e0 <mm_map>
ffffffffc0205b16:	89aa                	mv	s3,a0
ffffffffc0205b18:	e541                	bnez	a0,ffffffffc0205ba0 <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b1a:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b1e:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b22:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b26:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b28:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b2a:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b2c:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205b30:	053bef63          	bltu	s7,s3,ffffffffc0205b8e <do_execve+0x2fe>
ffffffffc0205b34:	aa79                	j	ffffffffc0205cd2 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b36:	6785                	lui	a5,0x1
ffffffffc0205b38:	418b8533          	sub	a0,s7,s8
ffffffffc0205b3c:	9c3e                	add	s8,s8,a5
ffffffffc0205b3e:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205b42:	0189f463          	bleu	s8,s3,ffffffffc0205b4a <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205b46:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205b4a:	000db683          	ld	a3,0(s11)
ffffffffc0205b4e:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b52:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b54:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b58:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b5a:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b5e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b60:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b64:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b66:	16c5fc63          	bleu	a2,a1,ffffffffc0205cde <do_execve+0x44e>
ffffffffc0205b6a:	000a7797          	auipc	a5,0xa7
ffffffffc0205b6e:	8ee78793          	addi	a5,a5,-1810 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0205b72:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b76:	85d6                	mv	a1,s5
ffffffffc0205b78:	8642                	mv	a2,a6
ffffffffc0205b7a:	96c6                	add	a3,a3,a7
ffffffffc0205b7c:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b7e:	9bc2                	add	s7,s7,a6
ffffffffc0205b80:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b82:	6ae000ef          	jal	ra,ffffffffc0206230 <memcpy>
            start += size, from += size;
ffffffffc0205b86:	6842                	ld	a6,16(sp)
ffffffffc0205b88:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205b8a:	053bf863          	bleu	s3,s7,ffffffffc0205bda <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b8e:	01893503          	ld	a0,24(s2)
ffffffffc0205b92:	6602                	ld	a2,0(sp)
ffffffffc0205b94:	85e2                	mv	a1,s8
ffffffffc0205b96:	fbafc0ef          	jal	ra,ffffffffc0202350 <pgdir_alloc_page>
ffffffffc0205b9a:	84aa                	mv	s1,a0
ffffffffc0205b9c:	fd49                	bnez	a0,ffffffffc0205b36 <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205b9e:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205ba0:	854a                	mv	a0,s2
ffffffffc0205ba2:	b8dfc0ef          	jal	ra,ffffffffc020272e <exit_mmap>
    put_pgdir(mm);
ffffffffc0205ba6:	854a                	mv	a0,s2
ffffffffc0205ba8:	a92ff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
    mm_destroy(mm);
ffffffffc0205bac:	854a                	mv	a0,s2
ffffffffc0205bae:	9e1fc0ef          	jal	ra,ffffffffc020258e <mm_destroy>
    return ret;
ffffffffc0205bb2:	b355                	j	ffffffffc0205956 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205bb4:	854a                	mv	a0,s2
ffffffffc0205bb6:	b79fc0ef          	jal	ra,ffffffffc020272e <exit_mmap>
            put_pgdir(mm);
ffffffffc0205bba:	854a                	mv	a0,s2
ffffffffc0205bbc:	a7eff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
            mm_destroy(mm);
ffffffffc0205bc0:	854a                	mv	a0,s2
ffffffffc0205bc2:	9cdfc0ef          	jal	ra,ffffffffc020258e <mm_destroy>
ffffffffc0205bc6:	bbb1                	j	ffffffffc0205922 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bc8:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bcc:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bce:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bd0:	f20790e3          	bnez	a5,ffffffffc0205af0 <do_execve+0x260>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205bd4:	47dd                	li	a5,23
ffffffffc0205bd6:	e03e                	sd	a5,0(sp)
ffffffffc0205bd8:	b71d                	j	ffffffffc0205afe <do_execve+0x26e>
ffffffffc0205bda:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205bde:	7414                	ld	a3,40(s0)
ffffffffc0205be0:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205be2:	098bf163          	bleu	s8,s7,ffffffffc0205c64 <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205be6:	df798ae3          	beq	s3,s7,ffffffffc02059da <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205bea:	6505                	lui	a0,0x1
ffffffffc0205bec:	955e                	add	a0,a0,s7
ffffffffc0205bee:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205bf2:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205bf6:	0d89fb63          	bleu	s8,s3,ffffffffc0205ccc <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205bfa:	000db683          	ld	a3,0(s11)
ffffffffc0205bfe:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c02:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c04:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c08:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c0a:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205c0e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205c10:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c14:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c16:	0cc5f463          	bleu	a2,a1,ffffffffc0205cde <do_execve+0x44e>
ffffffffc0205c1a:	000a7617          	auipc	a2,0xa7
ffffffffc0205c1e:	83e60613          	addi	a2,a2,-1986 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0205c22:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c26:	4581                	li	a1,0
ffffffffc0205c28:	8656                	mv	a2,s5
ffffffffc0205c2a:	96c2                	add	a3,a3,a6
ffffffffc0205c2c:	9536                	add	a0,a0,a3
ffffffffc0205c2e:	5f0000ef          	jal	ra,ffffffffc020621e <memset>
            start += size;
ffffffffc0205c32:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205c36:	0389f463          	bleu	s8,s3,ffffffffc0205c5e <do_execve+0x3ce>
ffffffffc0205c3a:	dae980e3          	beq	s3,a4,ffffffffc02059da <do_execve+0x14a>
ffffffffc0205c3e:	00003697          	auipc	a3,0x3
ffffffffc0205c42:	85a68693          	addi	a3,a3,-1958 # ffffffffc0208498 <default_pmm_manager+0xd0>
ffffffffc0205c46:	00001617          	auipc	a2,0x1
ffffffffc0205c4a:	06260613          	addi	a2,a2,98 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205c4e:	26200593          	li	a1,610
ffffffffc0205c52:	00003517          	auipc	a0,0x3
ffffffffc0205c56:	c7650513          	addi	a0,a0,-906 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205c5a:	dbcfa0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0205c5e:	ff8710e3          	bne	a4,s8,ffffffffc0205c3e <do_execve+0x3ae>
ffffffffc0205c62:	8be2                	mv	s7,s8
ffffffffc0205c64:	000a6a97          	auipc	s5,0xa6
ffffffffc0205c68:	7f4a8a93          	addi	s5,s5,2036 # ffffffffc02ac458 <va_pa_offset>
        while (start < end) {
ffffffffc0205c6c:	053be763          	bltu	s7,s3,ffffffffc0205cba <do_execve+0x42a>
ffffffffc0205c70:	b3ad                	j	ffffffffc02059da <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c72:	6785                	lui	a5,0x1
ffffffffc0205c74:	418b8533          	sub	a0,s7,s8
ffffffffc0205c78:	9c3e                	add	s8,s8,a5
ffffffffc0205c7a:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205c7e:	0189f463          	bleu	s8,s3,ffffffffc0205c86 <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205c82:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c86:	000db683          	ld	a3,0(s11)
ffffffffc0205c8a:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c8e:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c90:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c94:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c96:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c9a:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c9c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ca0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ca2:	02b87e63          	bleu	a1,a6,ffffffffc0205cde <do_execve+0x44e>
ffffffffc0205ca6:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205caa:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205cac:	4581                	li	a1,0
ffffffffc0205cae:	96c2                	add	a3,a3,a6
ffffffffc0205cb0:	9536                	add	a0,a0,a3
ffffffffc0205cb2:	56c000ef          	jal	ra,ffffffffc020621e <memset>
        while (start < end) {
ffffffffc0205cb6:	d33bf2e3          	bleu	s3,s7,ffffffffc02059da <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205cba:	01893503          	ld	a0,24(s2)
ffffffffc0205cbe:	6602                	ld	a2,0(sp)
ffffffffc0205cc0:	85e2                	mv	a1,s8
ffffffffc0205cc2:	e8efc0ef          	jal	ra,ffffffffc0202350 <pgdir_alloc_page>
ffffffffc0205cc6:	84aa                	mv	s1,a0
ffffffffc0205cc8:	f54d                	bnez	a0,ffffffffc0205c72 <do_execve+0x3e2>
ffffffffc0205cca:	bdd1                	j	ffffffffc0205b9e <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205ccc:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205cd0:	b72d                	j	ffffffffc0205bfa <do_execve+0x36a>
        while (start < end) {
ffffffffc0205cd2:	89de                	mv	s3,s7
ffffffffc0205cd4:	b729                	j	ffffffffc0205bde <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205cd6:	59f5                	li	s3,-3
ffffffffc0205cd8:	bbe1                	j	ffffffffc0205ab0 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205cda:	59e1                	li	s3,-8
ffffffffc0205cdc:	b5d1                	j	ffffffffc0205ba0 <do_execve+0x310>
ffffffffc0205cde:	00001617          	auipc	a2,0x1
ffffffffc0205ce2:	3b260613          	addi	a2,a2,946 # ffffffffc0207090 <commands+0x8c8>
ffffffffc0205ce6:	06900593          	li	a1,105
ffffffffc0205cea:	00001517          	auipc	a0,0x1
ffffffffc0205cee:	3fe50513          	addi	a0,a0,1022 # ffffffffc02070e8 <commands+0x920>
ffffffffc0205cf2:	d24fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205cf6:	00001617          	auipc	a2,0x1
ffffffffc0205cfa:	47260613          	addi	a2,a2,1138 # ffffffffc0207168 <commands+0x9a0>
ffffffffc0205cfe:	27d00593          	li	a1,637
ffffffffc0205d02:	00003517          	auipc	a0,0x3
ffffffffc0205d06:	bc650513          	addi	a0,a0,-1082 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205d0a:	d0cfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d0e:	00003697          	auipc	a3,0x3
ffffffffc0205d12:	8a268693          	addi	a3,a3,-1886 # ffffffffc02085b0 <default_pmm_manager+0x1e8>
ffffffffc0205d16:	00001617          	auipc	a2,0x1
ffffffffc0205d1a:	f9260613          	addi	a2,a2,-110 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205d1e:	27800593          	li	a1,632
ffffffffc0205d22:	00003517          	auipc	a0,0x3
ffffffffc0205d26:	ba650513          	addi	a0,a0,-1114 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205d2a:	cecfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d2e:	00003697          	auipc	a3,0x3
ffffffffc0205d32:	83a68693          	addi	a3,a3,-1990 # ffffffffc0208568 <default_pmm_manager+0x1a0>
ffffffffc0205d36:	00001617          	auipc	a2,0x1
ffffffffc0205d3a:	f7260613          	addi	a2,a2,-142 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205d3e:	27700593          	li	a1,631
ffffffffc0205d42:	00003517          	auipc	a0,0x3
ffffffffc0205d46:	b8650513          	addi	a0,a0,-1146 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205d4a:	cccfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d4e:	00002697          	auipc	a3,0x2
ffffffffc0205d52:	7d268693          	addi	a3,a3,2002 # ffffffffc0208520 <default_pmm_manager+0x158>
ffffffffc0205d56:	00001617          	auipc	a2,0x1
ffffffffc0205d5a:	f5260613          	addi	a2,a2,-174 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205d5e:	27600593          	li	a1,630
ffffffffc0205d62:	00003517          	auipc	a0,0x3
ffffffffc0205d66:	b6650513          	addi	a0,a0,-1178 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205d6a:	cacfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205d6e:	00002697          	auipc	a3,0x2
ffffffffc0205d72:	76a68693          	addi	a3,a3,1898 # ffffffffc02084d8 <default_pmm_manager+0x110>
ffffffffc0205d76:	00001617          	auipc	a2,0x1
ffffffffc0205d7a:	f3260613          	addi	a2,a2,-206 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205d7e:	27500593          	li	a1,629
ffffffffc0205d82:	00003517          	auipc	a0,0x3
ffffffffc0205d86:	b4650513          	addi	a0,a0,-1210 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205d8a:	c8cfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205d8e <do_yield>:
    current->need_resched = 1;
ffffffffc0205d8e:	000a6797          	auipc	a5,0xa6
ffffffffc0205d92:	69a78793          	addi	a5,a5,1690 # ffffffffc02ac428 <current>
ffffffffc0205d96:	639c                	ld	a5,0(a5)
ffffffffc0205d98:	4705                	li	a4,1
}
ffffffffc0205d9a:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d9c:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d9e:	8082                	ret

ffffffffc0205da0 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205da0:	1101                	addi	sp,sp,-32
ffffffffc0205da2:	e822                	sd	s0,16(sp)
ffffffffc0205da4:	e426                	sd	s1,8(sp)
ffffffffc0205da6:	ec06                	sd	ra,24(sp)
ffffffffc0205da8:	842e                	mv	s0,a1
ffffffffc0205daa:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205dac:	cd81                	beqz	a1,ffffffffc0205dc4 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205dae:	000a6797          	auipc	a5,0xa6
ffffffffc0205db2:	67a78793          	addi	a5,a5,1658 # ffffffffc02ac428 <current>
ffffffffc0205db6:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205db8:	4685                	li	a3,1
ffffffffc0205dba:	4611                	li	a2,4
ffffffffc0205dbc:	7788                	ld	a0,40(a5)
ffffffffc0205dbe:	812fd0ef          	jal	ra,ffffffffc0202dd0 <user_mem_check>
ffffffffc0205dc2:	c909                	beqz	a0,ffffffffc0205dd4 <do_wait+0x34>
ffffffffc0205dc4:	85a2                	mv	a1,s0
}
ffffffffc0205dc6:	6442                	ld	s0,16(sp)
ffffffffc0205dc8:	60e2                	ld	ra,24(sp)
ffffffffc0205dca:	8526                	mv	a0,s1
ffffffffc0205dcc:	64a2                	ld	s1,8(sp)
ffffffffc0205dce:	6105                	addi	sp,sp,32
ffffffffc0205dd0:	ff0ff06f          	j	ffffffffc02055c0 <do_wait.part.1>
ffffffffc0205dd4:	60e2                	ld	ra,24(sp)
ffffffffc0205dd6:	6442                	ld	s0,16(sp)
ffffffffc0205dd8:	64a2                	ld	s1,8(sp)
ffffffffc0205dda:	5575                	li	a0,-3
ffffffffc0205ddc:	6105                	addi	sp,sp,32
ffffffffc0205dde:	8082                	ret

ffffffffc0205de0 <do_kill>:
do_kill(int pid) {
ffffffffc0205de0:	1141                	addi	sp,sp,-16
ffffffffc0205de2:	e406                	sd	ra,8(sp)
ffffffffc0205de4:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205de6:	9f4ff0ef          	jal	ra,ffffffffc0204fda <find_proc>
ffffffffc0205dea:	cd0d                	beqz	a0,ffffffffc0205e24 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205dec:	0b052703          	lw	a4,176(a0)
ffffffffc0205df0:	00177693          	andi	a3,a4,1
ffffffffc0205df4:	e695                	bnez	a3,ffffffffc0205e20 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205df6:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205dfa:	00176713          	ori	a4,a4,1
ffffffffc0205dfe:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205e02:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e04:	0006c763          	bltz	a3,ffffffffc0205e12 <do_kill+0x32>
}
ffffffffc0205e08:	8522                	mv	a0,s0
ffffffffc0205e0a:	60a2                	ld	ra,8(sp)
ffffffffc0205e0c:	6402                	ld	s0,0(sp)
ffffffffc0205e0e:	0141                	addi	sp,sp,16
ffffffffc0205e10:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205e12:	17c000ef          	jal	ra,ffffffffc0205f8e <wakeup_proc>
}
ffffffffc0205e16:	8522                	mv	a0,s0
ffffffffc0205e18:	60a2                	ld	ra,8(sp)
ffffffffc0205e1a:	6402                	ld	s0,0(sp)
ffffffffc0205e1c:	0141                	addi	sp,sp,16
ffffffffc0205e1e:	8082                	ret
        return -E_KILLED;
ffffffffc0205e20:	545d                	li	s0,-9
ffffffffc0205e22:	b7dd                	j	ffffffffc0205e08 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205e24:	5475                	li	s0,-3
ffffffffc0205e26:	b7cd                	j	ffffffffc0205e08 <do_kill+0x28>

ffffffffc0205e28 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205e28:	000a6797          	auipc	a5,0xa6
ffffffffc0205e2c:	74078793          	addi	a5,a5,1856 # ffffffffc02ac568 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205e30:	1101                	addi	sp,sp,-32
ffffffffc0205e32:	000a6717          	auipc	a4,0xa6
ffffffffc0205e36:	72f73f23          	sd	a5,1854(a4) # ffffffffc02ac570 <proc_list+0x8>
ffffffffc0205e3a:	000a6717          	auipc	a4,0xa6
ffffffffc0205e3e:	72f73723          	sd	a5,1838(a4) # ffffffffc02ac568 <proc_list>
ffffffffc0205e42:	ec06                	sd	ra,24(sp)
ffffffffc0205e44:	e822                	sd	s0,16(sp)
ffffffffc0205e46:	e426                	sd	s1,8(sp)
ffffffffc0205e48:	000a2797          	auipc	a5,0xa2
ffffffffc0205e4c:	5a078793          	addi	a5,a5,1440 # ffffffffc02a83e8 <hash_list>
ffffffffc0205e50:	000a6717          	auipc	a4,0xa6
ffffffffc0205e54:	59870713          	addi	a4,a4,1432 # ffffffffc02ac3e8 <is_panic>
ffffffffc0205e58:	e79c                	sd	a5,8(a5)
ffffffffc0205e5a:	e39c                	sd	a5,0(a5)
ffffffffc0205e5c:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205e5e:	fee79de3          	bne	a5,a4,ffffffffc0205e58 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205e62:	ed3fe0ef          	jal	ra,ffffffffc0204d34 <alloc_proc>
ffffffffc0205e66:	000a6717          	auipc	a4,0xa6
ffffffffc0205e6a:	5ca73523          	sd	a0,1482(a4) # ffffffffc02ac430 <idleproc>
ffffffffc0205e6e:	000a6497          	auipc	s1,0xa6
ffffffffc0205e72:	5c248493          	addi	s1,s1,1474 # ffffffffc02ac430 <idleproc>
ffffffffc0205e76:	c559                	beqz	a0,ffffffffc0205f04 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e78:	4709                	li	a4,2
ffffffffc0205e7a:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205e7c:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e7e:	00003717          	auipc	a4,0x3
ffffffffc0205e82:	18270713          	addi	a4,a4,386 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e86:	00003597          	auipc	a1,0x3
ffffffffc0205e8a:	95a58593          	addi	a1,a1,-1702 # ffffffffc02087e0 <default_pmm_manager+0x418>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e8e:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e90:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e92:	8b2ff0ef          	jal	ra,ffffffffc0204f44 <set_proc_name>
    nr_process ++;
ffffffffc0205e96:	000a6797          	auipc	a5,0xa6
ffffffffc0205e9a:	5aa78793          	addi	a5,a5,1450 # ffffffffc02ac440 <nr_process>
ffffffffc0205e9e:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205ea0:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ea2:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205ea4:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ea6:	4581                	li	a1,0
ffffffffc0205ea8:	00000517          	auipc	a0,0x0
ffffffffc0205eac:	8c050513          	addi	a0,a0,-1856 # ffffffffc0205768 <init_main>
    nr_process ++;
ffffffffc0205eb0:	000a6697          	auipc	a3,0xa6
ffffffffc0205eb4:	58f6a823          	sw	a5,1424(a3) # ffffffffc02ac440 <nr_process>
    current = idleproc;
ffffffffc0205eb8:	000a6797          	auipc	a5,0xa6
ffffffffc0205ebc:	56e7b823          	sd	a4,1392(a5) # ffffffffc02ac428 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ec0:	d62ff0ef          	jal	ra,ffffffffc0205422 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205ec4:	08a05c63          	blez	a0,ffffffffc0205f5c <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205ec8:	912ff0ef          	jal	ra,ffffffffc0204fda <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205ecc:	00003597          	auipc	a1,0x3
ffffffffc0205ed0:	93c58593          	addi	a1,a1,-1732 # ffffffffc0208808 <default_pmm_manager+0x440>
    initproc = find_proc(pid);
ffffffffc0205ed4:	000a6797          	auipc	a5,0xa6
ffffffffc0205ed8:	56a7b223          	sd	a0,1380(a5) # ffffffffc02ac438 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205edc:	868ff0ef          	jal	ra,ffffffffc0204f44 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ee0:	609c                	ld	a5,0(s1)
ffffffffc0205ee2:	cfa9                	beqz	a5,ffffffffc0205f3c <proc_init+0x114>
ffffffffc0205ee4:	43dc                	lw	a5,4(a5)
ffffffffc0205ee6:	ebb9                	bnez	a5,ffffffffc0205f3c <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ee8:	000a6797          	auipc	a5,0xa6
ffffffffc0205eec:	55078793          	addi	a5,a5,1360 # ffffffffc02ac438 <initproc>
ffffffffc0205ef0:	639c                	ld	a5,0(a5)
ffffffffc0205ef2:	c78d                	beqz	a5,ffffffffc0205f1c <proc_init+0xf4>
ffffffffc0205ef4:	43dc                	lw	a5,4(a5)
ffffffffc0205ef6:	02879363          	bne	a5,s0,ffffffffc0205f1c <proc_init+0xf4>
}
ffffffffc0205efa:	60e2                	ld	ra,24(sp)
ffffffffc0205efc:	6442                	ld	s0,16(sp)
ffffffffc0205efe:	64a2                	ld	s1,8(sp)
ffffffffc0205f00:	6105                	addi	sp,sp,32
ffffffffc0205f02:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205f04:	00003617          	auipc	a2,0x3
ffffffffc0205f08:	8c460613          	addi	a2,a2,-1852 # ffffffffc02087c8 <default_pmm_manager+0x400>
ffffffffc0205f0c:	37400593          	li	a1,884
ffffffffc0205f10:	00003517          	auipc	a0,0x3
ffffffffc0205f14:	9b850513          	addi	a0,a0,-1608 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205f18:	afefa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f1c:	00003697          	auipc	a3,0x3
ffffffffc0205f20:	91c68693          	addi	a3,a3,-1764 # ffffffffc0208838 <default_pmm_manager+0x470>
ffffffffc0205f24:	00001617          	auipc	a2,0x1
ffffffffc0205f28:	d8460613          	addi	a2,a2,-636 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205f2c:	38900593          	li	a1,905
ffffffffc0205f30:	00003517          	auipc	a0,0x3
ffffffffc0205f34:	99850513          	addi	a0,a0,-1640 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205f38:	adefa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f3c:	00003697          	auipc	a3,0x3
ffffffffc0205f40:	8d468693          	addi	a3,a3,-1836 # ffffffffc0208810 <default_pmm_manager+0x448>
ffffffffc0205f44:	00001617          	auipc	a2,0x1
ffffffffc0205f48:	d6460613          	addi	a2,a2,-668 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205f4c:	38800593          	li	a1,904
ffffffffc0205f50:	00003517          	auipc	a0,0x3
ffffffffc0205f54:	97850513          	addi	a0,a0,-1672 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205f58:	abefa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205f5c:	00003617          	auipc	a2,0x3
ffffffffc0205f60:	88c60613          	addi	a2,a2,-1908 # ffffffffc02087e8 <default_pmm_manager+0x420>
ffffffffc0205f64:	38200593          	li	a1,898
ffffffffc0205f68:	00003517          	auipc	a0,0x3
ffffffffc0205f6c:	96050513          	addi	a0,a0,-1696 # ffffffffc02088c8 <default_pmm_manager+0x500>
ffffffffc0205f70:	aa6fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205f74 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f74:	1141                	addi	sp,sp,-16
ffffffffc0205f76:	e022                	sd	s0,0(sp)
ffffffffc0205f78:	e406                	sd	ra,8(sp)
ffffffffc0205f7a:	000a6417          	auipc	s0,0xa6
ffffffffc0205f7e:	4ae40413          	addi	s0,s0,1198 # ffffffffc02ac428 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f82:	6018                	ld	a4,0(s0)
ffffffffc0205f84:	6f1c                	ld	a5,24(a4)
ffffffffc0205f86:	dffd                	beqz	a5,ffffffffc0205f84 <cpu_idle+0x10>
            schedule();
ffffffffc0205f88:	082000ef          	jal	ra,ffffffffc020600a <schedule>
ffffffffc0205f8c:	bfdd                	j	ffffffffc0205f82 <cpu_idle+0xe>

ffffffffc0205f8e <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f8e:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f90:	1101                	addi	sp,sp,-32
ffffffffc0205f92:	ec06                	sd	ra,24(sp)
ffffffffc0205f94:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f96:	478d                	li	a5,3
ffffffffc0205f98:	04f70a63          	beq	a4,a5,ffffffffc0205fec <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f9c:	100027f3          	csrr	a5,sstatus
ffffffffc0205fa0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205fa2:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fa4:	ef8d                	bnez	a5,ffffffffc0205fde <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205fa6:	4789                	li	a5,2
ffffffffc0205fa8:	00f70f63          	beq	a4,a5,ffffffffc0205fc6 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205fac:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205fae:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205fb2:	e409                	bnez	s0,ffffffffc0205fbc <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205fb4:	60e2                	ld	ra,24(sp)
ffffffffc0205fb6:	6442                	ld	s0,16(sp)
ffffffffc0205fb8:	6105                	addi	sp,sp,32
ffffffffc0205fba:	8082                	ret
ffffffffc0205fbc:	6442                	ld	s0,16(sp)
ffffffffc0205fbe:	60e2                	ld	ra,24(sp)
ffffffffc0205fc0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205fc2:	e94fa06f          	j	ffffffffc0200656 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205fc6:	00003617          	auipc	a2,0x3
ffffffffc0205fca:	95260613          	addi	a2,a2,-1710 # ffffffffc0208918 <default_pmm_manager+0x550>
ffffffffc0205fce:	45c9                	li	a1,18
ffffffffc0205fd0:	00003517          	auipc	a0,0x3
ffffffffc0205fd4:	93050513          	addi	a0,a0,-1744 # ffffffffc0208900 <default_pmm_manager+0x538>
ffffffffc0205fd8:	aaafa0ef          	jal	ra,ffffffffc0200282 <__warn>
ffffffffc0205fdc:	bfd9                	j	ffffffffc0205fb2 <wakeup_proc+0x24>
ffffffffc0205fde:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205fe0:	e7cfa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0205fe4:	6522                	ld	a0,8(sp)
ffffffffc0205fe6:	4405                	li	s0,1
ffffffffc0205fe8:	4118                	lw	a4,0(a0)
ffffffffc0205fea:	bf75                	j	ffffffffc0205fa6 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205fec:	00003697          	auipc	a3,0x3
ffffffffc0205ff0:	8f468693          	addi	a3,a3,-1804 # ffffffffc02088e0 <default_pmm_manager+0x518>
ffffffffc0205ff4:	00001617          	auipc	a2,0x1
ffffffffc0205ff8:	cb460613          	addi	a2,a2,-844 # ffffffffc0206ca8 <commands+0x4e0>
ffffffffc0205ffc:	45a5                	li	a1,9
ffffffffc0205ffe:	00003517          	auipc	a0,0x3
ffffffffc0206002:	90250513          	addi	a0,a0,-1790 # ffffffffc0208900 <default_pmm_manager+0x538>
ffffffffc0206006:	a10fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020600a <schedule>:

void
schedule(void) {
ffffffffc020600a:	1141                	addi	sp,sp,-16
ffffffffc020600c:	e406                	sd	ra,8(sp)
ffffffffc020600e:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206010:	100027f3          	csrr	a5,sstatus
ffffffffc0206014:	8b89                	andi	a5,a5,2
ffffffffc0206016:	4401                	li	s0,0
ffffffffc0206018:	e3d1                	bnez	a5,ffffffffc020609c <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020601a:	000a6797          	auipc	a5,0xa6
ffffffffc020601e:	40e78793          	addi	a5,a5,1038 # ffffffffc02ac428 <current>
ffffffffc0206022:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206026:	000a6797          	auipc	a5,0xa6
ffffffffc020602a:	40a78793          	addi	a5,a5,1034 # ffffffffc02ac430 <idleproc>
ffffffffc020602e:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0206030:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7558>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206034:	04a88e63          	beq	a7,a0,ffffffffc0206090 <schedule+0x86>
ffffffffc0206038:	0c888693          	addi	a3,a7,200
ffffffffc020603c:	000a6617          	auipc	a2,0xa6
ffffffffc0206040:	52c60613          	addi	a2,a2,1324 # ffffffffc02ac568 <proc_list>
        le = last;
ffffffffc0206044:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206046:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206048:	4809                	li	a6,2
    return listelm->next;
ffffffffc020604a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020604c:	00c78863          	beq	a5,a2,ffffffffc020605c <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206050:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206054:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206058:	01070463          	beq	a4,a6,ffffffffc0206060 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc020605c:	fef697e3          	bne	a3,a5,ffffffffc020604a <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206060:	c589                	beqz	a1,ffffffffc020606a <schedule+0x60>
ffffffffc0206062:	4198                	lw	a4,0(a1)
ffffffffc0206064:	4789                	li	a5,2
ffffffffc0206066:	00f70e63          	beq	a4,a5,ffffffffc0206082 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020606a:	451c                	lw	a5,8(a0)
ffffffffc020606c:	2785                	addiw	a5,a5,1
ffffffffc020606e:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206070:	00a88463          	beq	a7,a0,ffffffffc0206078 <schedule+0x6e>
            proc_run(next);
ffffffffc0206074:	efbfe0ef          	jal	ra,ffffffffc0204f6e <proc_run>
    if (flag) {
ffffffffc0206078:	e419                	bnez	s0,ffffffffc0206086 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020607a:	60a2                	ld	ra,8(sp)
ffffffffc020607c:	6402                	ld	s0,0(sp)
ffffffffc020607e:	0141                	addi	sp,sp,16
ffffffffc0206080:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206082:	852e                	mv	a0,a1
ffffffffc0206084:	b7dd                	j	ffffffffc020606a <schedule+0x60>
}
ffffffffc0206086:	6402                	ld	s0,0(sp)
ffffffffc0206088:	60a2                	ld	ra,8(sp)
ffffffffc020608a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020608c:	dcafa06f          	j	ffffffffc0200656 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206090:	000a6617          	auipc	a2,0xa6
ffffffffc0206094:	4d860613          	addi	a2,a2,1240 # ffffffffc02ac568 <proc_list>
ffffffffc0206098:	86b2                	mv	a3,a2
ffffffffc020609a:	b76d                	j	ffffffffc0206044 <schedule+0x3a>
        intr_disable();
ffffffffc020609c:	dc0fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc02060a0:	4405                	li	s0,1
ffffffffc02060a2:	bfa5                	j	ffffffffc020601a <schedule+0x10>

ffffffffc02060a4 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02060a4:	000a6797          	auipc	a5,0xa6
ffffffffc02060a8:	38478793          	addi	a5,a5,900 # ffffffffc02ac428 <current>
ffffffffc02060ac:	639c                	ld	a5,0(a5)
}
ffffffffc02060ae:	43c8                	lw	a0,4(a5)
ffffffffc02060b0:	8082                	ret

ffffffffc02060b2 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02060b2:	4501                	li	a0,0
ffffffffc02060b4:	8082                	ret

ffffffffc02060b6 <sys_putc>:
    cputchar(c);
ffffffffc02060b6:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02060b8:	1141                	addi	sp,sp,-16
ffffffffc02060ba:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02060bc:	848fa0ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc02060c0:	60a2                	ld	ra,8(sp)
ffffffffc02060c2:	4501                	li	a0,0
ffffffffc02060c4:	0141                	addi	sp,sp,16
ffffffffc02060c6:	8082                	ret

ffffffffc02060c8 <sys_kill>:
    return do_kill(pid);
ffffffffc02060c8:	4108                	lw	a0,0(a0)
ffffffffc02060ca:	d17ff06f          	j	ffffffffc0205de0 <do_kill>

ffffffffc02060ce <sys_yield>:
    return do_yield();
ffffffffc02060ce:	cc1ff06f          	j	ffffffffc0205d8e <do_yield>

ffffffffc02060d2 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02060d2:	6d14                	ld	a3,24(a0)
ffffffffc02060d4:	6910                	ld	a2,16(a0)
ffffffffc02060d6:	650c                	ld	a1,8(a0)
ffffffffc02060d8:	6108                	ld	a0,0(a0)
ffffffffc02060da:	fb6ff06f          	j	ffffffffc0205890 <do_execve>

ffffffffc02060de <sys_wait>:
    return do_wait(pid, store);
ffffffffc02060de:	650c                	ld	a1,8(a0)
ffffffffc02060e0:	4108                	lw	a0,0(a0)
ffffffffc02060e2:	cbfff06f          	j	ffffffffc0205da0 <do_wait>

ffffffffc02060e6 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02060e6:	000a6797          	auipc	a5,0xa6
ffffffffc02060ea:	34278793          	addi	a5,a5,834 # ffffffffc02ac428 <current>
ffffffffc02060ee:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc02060f0:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02060f2:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02060f4:	6a0c                	ld	a1,16(a2)
ffffffffc02060f6:	f41fe06f          	j	ffffffffc0205036 <do_fork>

ffffffffc02060fa <sys_exit>:
    return do_exit(error_code);
ffffffffc02060fa:	4108                	lw	a0,0(a0)
ffffffffc02060fc:	b76ff06f          	j	ffffffffc0205472 <do_exit>

ffffffffc0206100 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206100:	715d                	addi	sp,sp,-80
ffffffffc0206102:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206104:	000a6497          	auipc	s1,0xa6
ffffffffc0206108:	32448493          	addi	s1,s1,804 # ffffffffc02ac428 <current>
ffffffffc020610c:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc020610e:	e0a2                	sd	s0,64(sp)
ffffffffc0206110:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206112:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206114:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206116:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0206118:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020611c:	0327ee63          	bltu	a5,s2,ffffffffc0206158 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206120:	00391713          	slli	a4,s2,0x3
ffffffffc0206124:	00003797          	auipc	a5,0x3
ffffffffc0206128:	85c78793          	addi	a5,a5,-1956 # ffffffffc0208980 <syscalls>
ffffffffc020612c:	97ba                	add	a5,a5,a4
ffffffffc020612e:	639c                	ld	a5,0(a5)
ffffffffc0206130:	c785                	beqz	a5,ffffffffc0206158 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206132:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206134:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206136:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206138:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020613a:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc020613c:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc020613e:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206140:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206142:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206144:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206146:	0028                	addi	a0,sp,8
ffffffffc0206148:	9782                	jalr	a5
ffffffffc020614a:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc020614c:	60a6                	ld	ra,72(sp)
ffffffffc020614e:	6406                	ld	s0,64(sp)
ffffffffc0206150:	74e2                	ld	s1,56(sp)
ffffffffc0206152:	7942                	ld	s2,48(sp)
ffffffffc0206154:	6161                	addi	sp,sp,80
ffffffffc0206156:	8082                	ret
    print_trapframe(tf);
ffffffffc0206158:	8522                	mv	a0,s0
ffffffffc020615a:	ef0fa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020615e:	609c                	ld	a5,0(s1)
ffffffffc0206160:	86ca                	mv	a3,s2
ffffffffc0206162:	00002617          	auipc	a2,0x2
ffffffffc0206166:	7d660613          	addi	a2,a2,2006 # ffffffffc0208938 <default_pmm_manager+0x570>
ffffffffc020616a:	43d8                	lw	a4,4(a5)
ffffffffc020616c:	06300593          	li	a1,99
ffffffffc0206170:	0b478793          	addi	a5,a5,180
ffffffffc0206174:	00002517          	auipc	a0,0x2
ffffffffc0206178:	7f450513          	addi	a0,a0,2036 # ffffffffc0208968 <default_pmm_manager+0x5a0>
ffffffffc020617c:	89afa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0206180 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206180:	00054783          	lbu	a5,0(a0)
ffffffffc0206184:	cb91                	beqz	a5,ffffffffc0206198 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0206186:	4781                	li	a5,0
        cnt ++;
ffffffffc0206188:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020618a:	00f50733          	add	a4,a0,a5
ffffffffc020618e:	00074703          	lbu	a4,0(a4)
ffffffffc0206192:	fb7d                	bnez	a4,ffffffffc0206188 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206194:	853e                	mv	a0,a5
ffffffffc0206196:	8082                	ret
    size_t cnt = 0;
ffffffffc0206198:	4781                	li	a5,0
}
ffffffffc020619a:	853e                	mv	a0,a5
ffffffffc020619c:	8082                	ret

ffffffffc020619e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020619e:	c185                	beqz	a1,ffffffffc02061be <strnlen+0x20>
ffffffffc02061a0:	00054783          	lbu	a5,0(a0)
ffffffffc02061a4:	cf89                	beqz	a5,ffffffffc02061be <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02061a6:	4781                	li	a5,0
ffffffffc02061a8:	a021                	j	ffffffffc02061b0 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02061aa:	00074703          	lbu	a4,0(a4)
ffffffffc02061ae:	c711                	beqz	a4,ffffffffc02061ba <strnlen+0x1c>
        cnt ++;
ffffffffc02061b0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02061b2:	00f50733          	add	a4,a0,a5
ffffffffc02061b6:	fef59ae3          	bne	a1,a5,ffffffffc02061aa <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02061ba:	853e                	mv	a0,a5
ffffffffc02061bc:	8082                	ret
    size_t cnt = 0;
ffffffffc02061be:	4781                	li	a5,0
}
ffffffffc02061c0:	853e                	mv	a0,a5
ffffffffc02061c2:	8082                	ret

ffffffffc02061c4 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02061c4:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02061c6:	0585                	addi	a1,a1,1
ffffffffc02061c8:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02061cc:	0785                	addi	a5,a5,1
ffffffffc02061ce:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02061d2:	fb75                	bnez	a4,ffffffffc02061c6 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02061d4:	8082                	ret

ffffffffc02061d6 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061d6:	00054783          	lbu	a5,0(a0)
ffffffffc02061da:	0005c703          	lbu	a4,0(a1)
ffffffffc02061de:	cb91                	beqz	a5,ffffffffc02061f2 <strcmp+0x1c>
ffffffffc02061e0:	00e79c63          	bne	a5,a4,ffffffffc02061f8 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02061e4:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061e6:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02061ea:	0585                	addi	a1,a1,1
ffffffffc02061ec:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061f0:	fbe5                	bnez	a5,ffffffffc02061e0 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02061f2:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02061f4:	9d19                	subw	a0,a0,a4
ffffffffc02061f6:	8082                	ret
ffffffffc02061f8:	0007851b          	sext.w	a0,a5
ffffffffc02061fc:	9d19                	subw	a0,a0,a4
ffffffffc02061fe:	8082                	ret

ffffffffc0206200 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206200:	00054783          	lbu	a5,0(a0)
ffffffffc0206204:	cb91                	beqz	a5,ffffffffc0206218 <strchr+0x18>
        if (*s == c) {
ffffffffc0206206:	00b79563          	bne	a5,a1,ffffffffc0206210 <strchr+0x10>
ffffffffc020620a:	a809                	j	ffffffffc020621c <strchr+0x1c>
ffffffffc020620c:	00b78763          	beq	a5,a1,ffffffffc020621a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0206210:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206212:	00054783          	lbu	a5,0(a0)
ffffffffc0206216:	fbfd                	bnez	a5,ffffffffc020620c <strchr+0xc>
    }
    return NULL;
ffffffffc0206218:	4501                	li	a0,0
}
ffffffffc020621a:	8082                	ret
ffffffffc020621c:	8082                	ret

ffffffffc020621e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020621e:	ca01                	beqz	a2,ffffffffc020622e <memset+0x10>
ffffffffc0206220:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206222:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206224:	0785                	addi	a5,a5,1
ffffffffc0206226:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020622a:	fec79de3          	bne	a5,a2,ffffffffc0206224 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020622e:	8082                	ret

ffffffffc0206230 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206230:	ca19                	beqz	a2,ffffffffc0206246 <memcpy+0x16>
ffffffffc0206232:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206234:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206236:	0585                	addi	a1,a1,1
ffffffffc0206238:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020623c:	0785                	addi	a5,a5,1
ffffffffc020623e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206242:	fec59ae3          	bne	a1,a2,ffffffffc0206236 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206246:	8082                	ret

ffffffffc0206248 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206248:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020624c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020624e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206252:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206254:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206258:	f022                	sd	s0,32(sp)
ffffffffc020625a:	ec26                	sd	s1,24(sp)
ffffffffc020625c:	e84a                	sd	s2,16(sp)
ffffffffc020625e:	f406                	sd	ra,40(sp)
ffffffffc0206260:	e44e                	sd	s3,8(sp)
ffffffffc0206262:	84aa                	mv	s1,a0
ffffffffc0206264:	892e                	mv	s2,a1
ffffffffc0206266:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020626a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020626c:	03067e63          	bleu	a6,a2,ffffffffc02062a8 <printnum+0x60>
ffffffffc0206270:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206272:	00805763          	blez	s0,ffffffffc0206280 <printnum+0x38>
ffffffffc0206276:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206278:	85ca                	mv	a1,s2
ffffffffc020627a:	854e                	mv	a0,s3
ffffffffc020627c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020627e:	fc65                	bnez	s0,ffffffffc0206276 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206280:	1a02                	slli	s4,s4,0x20
ffffffffc0206282:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206286:	00003797          	auipc	a5,0x3
ffffffffc020628a:	a1a78793          	addi	a5,a5,-1510 # ffffffffc0208ca0 <error_string+0xc8>
ffffffffc020628e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206290:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206292:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206296:	70a2                	ld	ra,40(sp)
ffffffffc0206298:	69a2                	ld	s3,8(sp)
ffffffffc020629a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020629c:	85ca                	mv	a1,s2
ffffffffc020629e:	8326                	mv	t1,s1
}
ffffffffc02062a0:	6942                	ld	s2,16(sp)
ffffffffc02062a2:	64e2                	ld	s1,24(sp)
ffffffffc02062a4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062a6:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02062a8:	03065633          	divu	a2,a2,a6
ffffffffc02062ac:	8722                	mv	a4,s0
ffffffffc02062ae:	f9bff0ef          	jal	ra,ffffffffc0206248 <printnum>
ffffffffc02062b2:	b7f9                	j	ffffffffc0206280 <printnum+0x38>

ffffffffc02062b4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02062b4:	7119                	addi	sp,sp,-128
ffffffffc02062b6:	f4a6                	sd	s1,104(sp)
ffffffffc02062b8:	f0ca                	sd	s2,96(sp)
ffffffffc02062ba:	e8d2                	sd	s4,80(sp)
ffffffffc02062bc:	e4d6                	sd	s5,72(sp)
ffffffffc02062be:	e0da                	sd	s6,64(sp)
ffffffffc02062c0:	fc5e                	sd	s7,56(sp)
ffffffffc02062c2:	f862                	sd	s8,48(sp)
ffffffffc02062c4:	f06a                	sd	s10,32(sp)
ffffffffc02062c6:	fc86                	sd	ra,120(sp)
ffffffffc02062c8:	f8a2                	sd	s0,112(sp)
ffffffffc02062ca:	ecce                	sd	s3,88(sp)
ffffffffc02062cc:	f466                	sd	s9,40(sp)
ffffffffc02062ce:	ec6e                	sd	s11,24(sp)
ffffffffc02062d0:	892a                	mv	s2,a0
ffffffffc02062d2:	84ae                	mv	s1,a1
ffffffffc02062d4:	8d32                	mv	s10,a2
ffffffffc02062d6:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02062d8:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062da:	00002a17          	auipc	s4,0x2
ffffffffc02062de:	7a6a0a13          	addi	s4,s4,1958 # ffffffffc0208a80 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02062e2:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062e6:	00003c17          	auipc	s8,0x3
ffffffffc02062ea:	8f2c0c13          	addi	s8,s8,-1806 # ffffffffc0208bd8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062ee:	000d4503          	lbu	a0,0(s10)
ffffffffc02062f2:	02500793          	li	a5,37
ffffffffc02062f6:	001d0413          	addi	s0,s10,1
ffffffffc02062fa:	00f50e63          	beq	a0,a5,ffffffffc0206316 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02062fe:	c521                	beqz	a0,ffffffffc0206346 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206300:	02500993          	li	s3,37
ffffffffc0206304:	a011                	j	ffffffffc0206308 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0206306:	c121                	beqz	a0,ffffffffc0206346 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0206308:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020630a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020630c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020630e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206312:	ff351ae3          	bne	a0,s3,ffffffffc0206306 <vprintfmt+0x52>
ffffffffc0206316:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020631a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020631e:	4981                	li	s3,0
ffffffffc0206320:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0206322:	5cfd                	li	s9,-1
ffffffffc0206324:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206326:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020632a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020632c:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0206330:	0ff6f693          	andi	a3,a3,255
ffffffffc0206334:	00140d13          	addi	s10,s0,1
ffffffffc0206338:	20d5e563          	bltu	a1,a3,ffffffffc0206542 <vprintfmt+0x28e>
ffffffffc020633c:	068a                	slli	a3,a3,0x2
ffffffffc020633e:	96d2                	add	a3,a3,s4
ffffffffc0206340:	4294                	lw	a3,0(a3)
ffffffffc0206342:	96d2                	add	a3,a3,s4
ffffffffc0206344:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206346:	70e6                	ld	ra,120(sp)
ffffffffc0206348:	7446                	ld	s0,112(sp)
ffffffffc020634a:	74a6                	ld	s1,104(sp)
ffffffffc020634c:	7906                	ld	s2,96(sp)
ffffffffc020634e:	69e6                	ld	s3,88(sp)
ffffffffc0206350:	6a46                	ld	s4,80(sp)
ffffffffc0206352:	6aa6                	ld	s5,72(sp)
ffffffffc0206354:	6b06                	ld	s6,64(sp)
ffffffffc0206356:	7be2                	ld	s7,56(sp)
ffffffffc0206358:	7c42                	ld	s8,48(sp)
ffffffffc020635a:	7ca2                	ld	s9,40(sp)
ffffffffc020635c:	7d02                	ld	s10,32(sp)
ffffffffc020635e:	6de2                	ld	s11,24(sp)
ffffffffc0206360:	6109                	addi	sp,sp,128
ffffffffc0206362:	8082                	ret
    if (lflag >= 2) {
ffffffffc0206364:	4705                	li	a4,1
ffffffffc0206366:	008a8593          	addi	a1,s5,8
ffffffffc020636a:	01074463          	blt	a4,a6,ffffffffc0206372 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020636e:	26080363          	beqz	a6,ffffffffc02065d4 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0206372:	000ab603          	ld	a2,0(s5)
ffffffffc0206376:	46c1                	li	a3,16
ffffffffc0206378:	8aae                	mv	s5,a1
ffffffffc020637a:	a06d                	j	ffffffffc0206424 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020637c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206380:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206382:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206384:	b765                	j	ffffffffc020632c <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0206386:	000aa503          	lw	a0,0(s5)
ffffffffc020638a:	85a6                	mv	a1,s1
ffffffffc020638c:	0aa1                	addi	s5,s5,8
ffffffffc020638e:	9902                	jalr	s2
            break;
ffffffffc0206390:	bfb9                	j	ffffffffc02062ee <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206392:	4705                	li	a4,1
ffffffffc0206394:	008a8993          	addi	s3,s5,8
ffffffffc0206398:	01074463          	blt	a4,a6,ffffffffc02063a0 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020639c:	22080463          	beqz	a6,ffffffffc02065c4 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02063a0:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02063a4:	24044463          	bltz	s0,ffffffffc02065ec <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02063a8:	8622                	mv	a2,s0
ffffffffc02063aa:	8ace                	mv	s5,s3
ffffffffc02063ac:	46a9                	li	a3,10
ffffffffc02063ae:	a89d                	j	ffffffffc0206424 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02063b0:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02063b4:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02063b6:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02063b8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02063bc:	8fb5                	xor	a5,a5,a3
ffffffffc02063be:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02063c2:	1ad74363          	blt	a4,a3,ffffffffc0206568 <vprintfmt+0x2b4>
ffffffffc02063c6:	00369793          	slli	a5,a3,0x3
ffffffffc02063ca:	97e2                	add	a5,a5,s8
ffffffffc02063cc:	639c                	ld	a5,0(a5)
ffffffffc02063ce:	18078d63          	beqz	a5,ffffffffc0206568 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02063d2:	86be                	mv	a3,a5
ffffffffc02063d4:	00000617          	auipc	a2,0x0
ffffffffc02063d8:	2ac60613          	addi	a2,a2,684 # ffffffffc0206680 <etext+0x28>
ffffffffc02063dc:	85a6                	mv	a1,s1
ffffffffc02063de:	854a                	mv	a0,s2
ffffffffc02063e0:	240000ef          	jal	ra,ffffffffc0206620 <printfmt>
ffffffffc02063e4:	b729                	j	ffffffffc02062ee <vprintfmt+0x3a>
            lflag ++;
ffffffffc02063e6:	00144603          	lbu	a2,1(s0)
ffffffffc02063ea:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063ec:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063ee:	bf3d                	j	ffffffffc020632c <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02063f0:	4705                	li	a4,1
ffffffffc02063f2:	008a8593          	addi	a1,s5,8
ffffffffc02063f6:	01074463          	blt	a4,a6,ffffffffc02063fe <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02063fa:	1e080263          	beqz	a6,ffffffffc02065de <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02063fe:	000ab603          	ld	a2,0(s5)
ffffffffc0206402:	46a1                	li	a3,8
ffffffffc0206404:	8aae                	mv	s5,a1
ffffffffc0206406:	a839                	j	ffffffffc0206424 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0206408:	03000513          	li	a0,48
ffffffffc020640c:	85a6                	mv	a1,s1
ffffffffc020640e:	e03e                	sd	a5,0(sp)
ffffffffc0206410:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206412:	85a6                	mv	a1,s1
ffffffffc0206414:	07800513          	li	a0,120
ffffffffc0206418:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020641a:	0aa1                	addi	s5,s5,8
ffffffffc020641c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0206420:	6782                	ld	a5,0(sp)
ffffffffc0206422:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206424:	876e                	mv	a4,s11
ffffffffc0206426:	85a6                	mv	a1,s1
ffffffffc0206428:	854a                	mv	a0,s2
ffffffffc020642a:	e1fff0ef          	jal	ra,ffffffffc0206248 <printnum>
            break;
ffffffffc020642e:	b5c1                	j	ffffffffc02062ee <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206430:	000ab603          	ld	a2,0(s5)
ffffffffc0206434:	0aa1                	addi	s5,s5,8
ffffffffc0206436:	1c060663          	beqz	a2,ffffffffc0206602 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020643a:	00160413          	addi	s0,a2,1
ffffffffc020643e:	17b05c63          	blez	s11,ffffffffc02065b6 <vprintfmt+0x302>
ffffffffc0206442:	02d00593          	li	a1,45
ffffffffc0206446:	14b79263          	bne	a5,a1,ffffffffc020658a <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020644a:	00064783          	lbu	a5,0(a2)
ffffffffc020644e:	0007851b          	sext.w	a0,a5
ffffffffc0206452:	c905                	beqz	a0,ffffffffc0206482 <vprintfmt+0x1ce>
ffffffffc0206454:	000cc563          	bltz	s9,ffffffffc020645e <vprintfmt+0x1aa>
ffffffffc0206458:	3cfd                	addiw	s9,s9,-1
ffffffffc020645a:	036c8263          	beq	s9,s6,ffffffffc020647e <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020645e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206460:	18098463          	beqz	s3,ffffffffc02065e8 <vprintfmt+0x334>
ffffffffc0206464:	3781                	addiw	a5,a5,-32
ffffffffc0206466:	18fbf163          	bleu	a5,s7,ffffffffc02065e8 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020646a:	03f00513          	li	a0,63
ffffffffc020646e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206470:	0405                	addi	s0,s0,1
ffffffffc0206472:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206476:	3dfd                	addiw	s11,s11,-1
ffffffffc0206478:	0007851b          	sext.w	a0,a5
ffffffffc020647c:	fd61                	bnez	a0,ffffffffc0206454 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020647e:	e7b058e3          	blez	s11,ffffffffc02062ee <vprintfmt+0x3a>
ffffffffc0206482:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206484:	85a6                	mv	a1,s1
ffffffffc0206486:	02000513          	li	a0,32
ffffffffc020648a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020648c:	e60d81e3          	beqz	s11,ffffffffc02062ee <vprintfmt+0x3a>
ffffffffc0206490:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206492:	85a6                	mv	a1,s1
ffffffffc0206494:	02000513          	li	a0,32
ffffffffc0206498:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020649a:	fe0d94e3          	bnez	s11,ffffffffc0206482 <vprintfmt+0x1ce>
ffffffffc020649e:	bd81                	j	ffffffffc02062ee <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02064a0:	4705                	li	a4,1
ffffffffc02064a2:	008a8593          	addi	a1,s5,8
ffffffffc02064a6:	01074463          	blt	a4,a6,ffffffffc02064ae <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02064aa:	12080063          	beqz	a6,ffffffffc02065ca <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02064ae:	000ab603          	ld	a2,0(s5)
ffffffffc02064b2:	46a9                	li	a3,10
ffffffffc02064b4:	8aae                	mv	s5,a1
ffffffffc02064b6:	b7bd                	j	ffffffffc0206424 <vprintfmt+0x170>
ffffffffc02064b8:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02064bc:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064c0:	846a                	mv	s0,s10
ffffffffc02064c2:	b5ad                	j	ffffffffc020632c <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02064c4:	85a6                	mv	a1,s1
ffffffffc02064c6:	02500513          	li	a0,37
ffffffffc02064ca:	9902                	jalr	s2
            break;
ffffffffc02064cc:	b50d                	j	ffffffffc02062ee <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02064ce:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02064d2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02064d6:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064d8:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02064da:	e40dd9e3          	bgez	s11,ffffffffc020632c <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02064de:	8de6                	mv	s11,s9
ffffffffc02064e0:	5cfd                	li	s9,-1
ffffffffc02064e2:	b5a9                	j	ffffffffc020632c <vprintfmt+0x78>
            goto reswitch;
ffffffffc02064e4:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02064e8:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064ec:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064ee:	bd3d                	j	ffffffffc020632c <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02064f0:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02064f4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064f8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02064fa:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02064fe:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206502:	fcd56ce3          	bltu	a0,a3,ffffffffc02064da <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0206506:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206508:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020650c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206510:	0196873b          	addw	a4,a3,s9
ffffffffc0206514:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206518:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020651c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0206520:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0206524:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206528:	fcd57fe3          	bleu	a3,a0,ffffffffc0206506 <vprintfmt+0x252>
ffffffffc020652c:	b77d                	j	ffffffffc02064da <vprintfmt+0x226>
            if (width < 0)
ffffffffc020652e:	fffdc693          	not	a3,s11
ffffffffc0206532:	96fd                	srai	a3,a3,0x3f
ffffffffc0206534:	00ddfdb3          	and	s11,s11,a3
ffffffffc0206538:	00144603          	lbu	a2,1(s0)
ffffffffc020653c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020653e:	846a                	mv	s0,s10
ffffffffc0206540:	b3f5                	j	ffffffffc020632c <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0206542:	85a6                	mv	a1,s1
ffffffffc0206544:	02500513          	li	a0,37
ffffffffc0206548:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020654a:	fff44703          	lbu	a4,-1(s0)
ffffffffc020654e:	02500793          	li	a5,37
ffffffffc0206552:	8d22                	mv	s10,s0
ffffffffc0206554:	d8f70de3          	beq	a4,a5,ffffffffc02062ee <vprintfmt+0x3a>
ffffffffc0206558:	02500713          	li	a4,37
ffffffffc020655c:	1d7d                	addi	s10,s10,-1
ffffffffc020655e:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206562:	fee79de3          	bne	a5,a4,ffffffffc020655c <vprintfmt+0x2a8>
ffffffffc0206566:	b361                	j	ffffffffc02062ee <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206568:	00003617          	auipc	a2,0x3
ffffffffc020656c:	81860613          	addi	a2,a2,-2024 # ffffffffc0208d80 <error_string+0x1a8>
ffffffffc0206570:	85a6                	mv	a1,s1
ffffffffc0206572:	854a                	mv	a0,s2
ffffffffc0206574:	0ac000ef          	jal	ra,ffffffffc0206620 <printfmt>
ffffffffc0206578:	bb9d                	j	ffffffffc02062ee <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020657a:	00002617          	auipc	a2,0x2
ffffffffc020657e:	7fe60613          	addi	a2,a2,2046 # ffffffffc0208d78 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206582:	00002417          	auipc	s0,0x2
ffffffffc0206586:	7f740413          	addi	s0,s0,2039 # ffffffffc0208d79 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020658a:	8532                	mv	a0,a2
ffffffffc020658c:	85e6                	mv	a1,s9
ffffffffc020658e:	e032                	sd	a2,0(sp)
ffffffffc0206590:	e43e                	sd	a5,8(sp)
ffffffffc0206592:	c0dff0ef          	jal	ra,ffffffffc020619e <strnlen>
ffffffffc0206596:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020659a:	6602                	ld	a2,0(sp)
ffffffffc020659c:	01b05d63          	blez	s11,ffffffffc02065b6 <vprintfmt+0x302>
ffffffffc02065a0:	67a2                	ld	a5,8(sp)
ffffffffc02065a2:	2781                	sext.w	a5,a5
ffffffffc02065a4:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02065a6:	6522                	ld	a0,8(sp)
ffffffffc02065a8:	85a6                	mv	a1,s1
ffffffffc02065aa:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02065ac:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02065ae:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02065b0:	6602                	ld	a2,0(sp)
ffffffffc02065b2:	fe0d9ae3          	bnez	s11,ffffffffc02065a6 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065b6:	00064783          	lbu	a5,0(a2)
ffffffffc02065ba:	0007851b          	sext.w	a0,a5
ffffffffc02065be:	e8051be3          	bnez	a0,ffffffffc0206454 <vprintfmt+0x1a0>
ffffffffc02065c2:	b335                	j	ffffffffc02062ee <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02065c4:	000aa403          	lw	s0,0(s5)
ffffffffc02065c8:	bbf1                	j	ffffffffc02063a4 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02065ca:	000ae603          	lwu	a2,0(s5)
ffffffffc02065ce:	46a9                	li	a3,10
ffffffffc02065d0:	8aae                	mv	s5,a1
ffffffffc02065d2:	bd89                	j	ffffffffc0206424 <vprintfmt+0x170>
ffffffffc02065d4:	000ae603          	lwu	a2,0(s5)
ffffffffc02065d8:	46c1                	li	a3,16
ffffffffc02065da:	8aae                	mv	s5,a1
ffffffffc02065dc:	b5a1                	j	ffffffffc0206424 <vprintfmt+0x170>
ffffffffc02065de:	000ae603          	lwu	a2,0(s5)
ffffffffc02065e2:	46a1                	li	a3,8
ffffffffc02065e4:	8aae                	mv	s5,a1
ffffffffc02065e6:	bd3d                	j	ffffffffc0206424 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02065e8:	9902                	jalr	s2
ffffffffc02065ea:	b559                	j	ffffffffc0206470 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02065ec:	85a6                	mv	a1,s1
ffffffffc02065ee:	02d00513          	li	a0,45
ffffffffc02065f2:	e03e                	sd	a5,0(sp)
ffffffffc02065f4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02065f6:	8ace                	mv	s5,s3
ffffffffc02065f8:	40800633          	neg	a2,s0
ffffffffc02065fc:	46a9                	li	a3,10
ffffffffc02065fe:	6782                	ld	a5,0(sp)
ffffffffc0206600:	b515                	j	ffffffffc0206424 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0206602:	01b05663          	blez	s11,ffffffffc020660e <vprintfmt+0x35a>
ffffffffc0206606:	02d00693          	li	a3,45
ffffffffc020660a:	f6d798e3          	bne	a5,a3,ffffffffc020657a <vprintfmt+0x2c6>
ffffffffc020660e:	00002417          	auipc	s0,0x2
ffffffffc0206612:	76b40413          	addi	s0,s0,1899 # ffffffffc0208d79 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206616:	02800513          	li	a0,40
ffffffffc020661a:	02800793          	li	a5,40
ffffffffc020661e:	bd1d                	j	ffffffffc0206454 <vprintfmt+0x1a0>

ffffffffc0206620 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206620:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206622:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206626:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206628:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020662a:	ec06                	sd	ra,24(sp)
ffffffffc020662c:	f83a                	sd	a4,48(sp)
ffffffffc020662e:	fc3e                	sd	a5,56(sp)
ffffffffc0206630:	e0c2                	sd	a6,64(sp)
ffffffffc0206632:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206634:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206636:	c7fff0ef          	jal	ra,ffffffffc02062b4 <vprintfmt>
}
ffffffffc020663a:	60e2                	ld	ra,24(sp)
ffffffffc020663c:	6161                	addi	sp,sp,80
ffffffffc020663e:	8082                	ret

ffffffffc0206640 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206640:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206644:	2785                	addiw	a5,a5,1
ffffffffc0206646:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc020664a:	02000793          	li	a5,32
ffffffffc020664e:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0206652:	00b5553b          	srlw	a0,a0,a1
ffffffffc0206656:	8082                	ret
