
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 a0 12 00       	mov    $0x12a000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 a0 12 f0       	mov    $0xf012a000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 90 1e 2e f0 00 	cmpl   $0x0,0xf02e1e90
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 90 1e 2e f0    	mov    %esi,0xf02e1e90

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 98 63 00 00       	call   f01063fc <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 00 77 10 f0 	movl   $0xf0107700,(%esp)
f010007d:	e8 08 3e 00 00       	call   f0103e8a <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 c9 3d 00 00       	call   f0103e57 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 f7 88 10 f0 	movl   $0xf01088f7,(%esp)
f0100095:	e8 f0 3d 00 00       	call   f0103e8a <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 e9 08 00 00       	call   f010098f <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 6b 77 10 f0 	movl   $0xf010776b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 15 63 00 00       	call   f01063fc <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 77 77 10 f0 	movl   $0xf0107777,(%esp)
f01000f2:	e8 93 3d 00 00       	call   f0103e8a <cprintf>

	lapic_init();
f01000f7:	e8 1b 63 00 00       	call   f0106417 <lapic_init>
	env_init_percpu();
f01000fc:	e8 bd 35 00 00       	call   f01036be <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 9e 3d 00 00       	call   f0103ea4 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 f1 62 00 00       	call   f01063fc <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 20 2e f0    	add    $0xf02e2020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 a0 c4 12 f0 	movl   $0xf012c4a0,(%esp)
f0100124:	e8 fa 65 00 00       	call   f0106723 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();

	sched_yield();
f0100129:	e8 c4 49 00 00       	call   f0104af2 <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100135:	e8 5f 05 00 00       	call   f0100699 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010013a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100141:	00 
f0100142:	c7 04 24 8d 77 10 f0 	movl   $0xf010778d,(%esp)
f0100149:	e8 3c 3d 00 00       	call   f0103e8a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010014e:	e8 71 12 00 00       	call   f01013c4 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100153:	e8 90 35 00 00       	call   f01036e8 <env_init>
	trap_init();
f0100158:	e8 b5 3e 00 00       	call   f0104012 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010015d:	e8 a2 5f 00 00       	call   f0106104 <mp_init>
	lapic_init();
f0100162:	e8 b0 62 00 00       	call   f0106417 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100167:	e8 64 3c 00 00       	call   f0103dd0 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f010016c:	e8 e7 72 00 00       	call   f0107458 <time_init>
	pci_init();
f0100171:	e8 b3 72 00 00       	call   f0107429 <pci_init>
f0100176:	c7 04 24 a0 c4 12 f0 	movl   $0xf012c4a0,(%esp)
f010017d:	e8 a1 65 00 00       	call   f0106723 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100182:	83 3d 98 1e 2e f0 07 	cmpl   $0x7,0xf02e1e98
f0100189:	77 24                	ja     f01001af <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010018b:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100192:	00 
f0100193:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f010019a:	f0 
f010019b:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
f01001a2:	00 
f01001a3:	c7 04 24 6b 77 10 f0 	movl   $0xf010776b,(%esp)
f01001aa:	e8 91 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001af:	b8 2e 60 10 f0       	mov    $0xf010602e,%eax
f01001b4:	2d b4 5f 10 f0       	sub    $0xf0105fb4,%eax
f01001b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001bd:	c7 44 24 04 b4 5f 10 	movl   $0xf0105fb4,0x4(%esp)
f01001c4:	f0 
f01001c5:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001cc:	e8 37 5c 00 00       	call   f0105e08 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001d1:	bb 20 20 2e f0       	mov    $0xf02e2020,%ebx
f01001d6:	eb 6f                	jmp    f0100247 <i386_init+0x119>
		if (c == cpus + cpunum())  // We've started already.
f01001d8:	e8 1f 62 00 00       	call   f01063fc <cpunum>
f01001dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001e4:	29 c2                	sub    %eax,%edx
f01001e6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001e9:	8d 04 85 20 20 2e f0 	lea    -0xfd1dfe0(,%eax,4),%eax
f01001f0:	39 c3                	cmp    %eax,%ebx
f01001f2:	74 50                	je     f0100244 <i386_init+0x116>

static void boot_aps(void);


void
i386_init(void)
f01001f4:	89 d8                	mov    %ebx,%eax
f01001f6:	2d 20 20 2e f0       	sub    $0xf02e2020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001fb:	c1 f8 02             	sar    $0x2,%eax
f01001fe:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0100201:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f0100204:	89 d1                	mov    %edx,%ecx
f0100206:	c1 e1 05             	shl    $0x5,%ecx
f0100209:	29 d1                	sub    %edx,%ecx
f010020b:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f010020e:	89 d1                	mov    %edx,%ecx
f0100210:	c1 e1 0e             	shl    $0xe,%ecx
f0100213:	29 d1                	sub    %edx,%ecx
f0100215:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100218:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f010021c:	c1 e0 0f             	shl    $0xf,%eax
f010021f:	05 00 30 2e f0       	add    $0xf02e3000,%eax
f0100224:	a3 94 1e 2e f0       	mov    %eax,0xf02e1e94
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100229:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100230:	00 
f0100231:	0f b6 03             	movzbl (%ebx),%eax
f0100234:	89 04 24             	mov    %eax,(%esp)
f0100237:	e8 9d 63 00 00       	call   f01065d9 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010023c:	8b 43 04             	mov    0x4(%ebx),%eax
f010023f:	83 f8 01             	cmp    $0x1,%eax
f0100242:	75 f8                	jne    f010023c <i386_init+0x10e>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100244:	83 c3 74             	add    $0x74,%ebx
f0100247:	a1 c4 23 2e f0       	mov    0xf02e23c4,%eax
f010024c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100253:	29 c2                	sub    %eax,%edx
f0100255:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100258:	8d 04 85 20 20 2e f0 	lea    -0xfd1dfe0(,%eax,4),%eax
f010025f:	39 c3                	cmp    %eax,%ebx
f0100261:	0f 82 71 ff ff ff    	jb     f01001d8 <i386_init+0xaa>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100267:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010026e:	00 
f010026f:	c7 04 24 7c a2 1e f0 	movl   $0xf01ea27c,(%esp)
f0100276:	e8 37 36 00 00       	call   f01038b2 <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f010027b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0100282:	00 
f0100283:	c7 04 24 24 af 25 f0 	movl   $0xf025af24,(%esp)
f010028a:	e8 23 36 00 00       	call   f01038b2 <env_create>
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010028f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100296:	00 
f0100297:	c7 04 24 89 90 21 f0 	movl   $0xf0219089,(%esp)
f010029e:	e8 0f 36 00 00       	call   f01038b2 <env_create>
	ENV_CREATE(user_icode, ENV_TYPE_USER);
	
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01002a3:	e8 98 03 00 00       	call   f0100640 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01002a8:	e8 45 48 00 00       	call   f0104af2 <sched_yield>

f01002ad <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002ad:	55                   	push   %ebp
f01002ae:	89 e5                	mov    %esp,%ebp
f01002b0:	53                   	push   %ebx
f01002b1:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002b4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002be:	8b 45 08             	mov    0x8(%ebp),%eax
f01002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002c5:	c7 04 24 a8 77 10 f0 	movl   $0xf01077a8,(%esp)
f01002cc:	e8 b9 3b 00 00       	call   f0103e8a <cprintf>
	vcprintf(fmt, ap);
f01002d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002d5:	8b 45 10             	mov    0x10(%ebp),%eax
f01002d8:	89 04 24             	mov    %eax,(%esp)
f01002db:	e8 77 3b 00 00       	call   f0103e57 <vcprintf>
	cprintf("\n");
f01002e0:	c7 04 24 f7 88 10 f0 	movl   $0xf01088f7,(%esp)
f01002e7:	e8 9e 3b 00 00       	call   f0103e8a <cprintf>
	va_end(ap);
}
f01002ec:	83 c4 14             	add    $0x14,%esp
f01002ef:	5b                   	pop    %ebx
f01002f0:	5d                   	pop    %ebp
f01002f1:	c3                   	ret    
	...

f01002f4 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002f4:	55                   	push   %ebp
f01002f5:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f7:	ba 84 00 00 00       	mov    $0x84,%edx
f01002fc:	ec                   	in     (%dx),%al
f01002fd:	ec                   	in     (%dx),%al
f01002fe:	ec                   	in     (%dx),%al
f01002ff:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100300:	5d                   	pop    %ebp
f0100301:	c3                   	ret    

f0100302 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100302:	55                   	push   %ebp
f0100303:	89 e5                	mov    %esp,%ebp
f0100305:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010030a:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010030b:	a8 01                	test   $0x1,%al
f010030d:	74 08                	je     f0100317 <serial_proc_data+0x15>
f010030f:	b2 f8                	mov    $0xf8,%dl
f0100311:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100312:	0f b6 c0             	movzbl %al,%eax
f0100315:	eb 05                	jmp    f010031c <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010031c:	5d                   	pop    %ebp
f010031d:	c3                   	ret    

f010031e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010031e:	55                   	push   %ebp
f010031f:	89 e5                	mov    %esp,%ebp
f0100321:	53                   	push   %ebx
f0100322:	83 ec 04             	sub    $0x4,%esp
f0100325:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100327:	eb 29                	jmp    f0100352 <cons_intr+0x34>
		if (c == 0)
f0100329:	85 c0                	test   %eax,%eax
f010032b:	74 25                	je     f0100352 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f010032d:	8b 15 24 12 2e f0    	mov    0xf02e1224,%edx
f0100333:	88 82 20 10 2e f0    	mov    %al,-0xfd1efe0(%edx)
f0100339:	8d 42 01             	lea    0x1(%edx),%eax
f010033c:	a3 24 12 2e f0       	mov    %eax,0xf02e1224
		if (cons.wpos == CONSBUFSIZE)
f0100341:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100346:	75 0a                	jne    f0100352 <cons_intr+0x34>
			cons.wpos = 0;
f0100348:	c7 05 24 12 2e f0 00 	movl   $0x0,0xf02e1224
f010034f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100352:	ff d3                	call   *%ebx
f0100354:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100357:	75 d0                	jne    f0100329 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100359:	83 c4 04             	add    $0x4,%esp
f010035c:	5b                   	pop    %ebx
f010035d:	5d                   	pop    %ebp
f010035e:	c3                   	ret    

f010035f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035f:	55                   	push   %ebp
f0100360:	89 e5                	mov    %esp,%ebp
f0100362:	57                   	push   %edi
f0100363:	56                   	push   %esi
f0100364:	53                   	push   %ebx
f0100365:	83 ec 2c             	sub    $0x2c,%esp
f0100368:	89 c6                	mov    %eax,%esi
f010036a:	bb 01 32 00 00       	mov    $0x3201,%ebx
f010036f:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100374:	eb 05                	jmp    f010037b <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100376:	e8 79 ff ff ff       	call   f01002f4 <delay>
f010037b:	89 fa                	mov    %edi,%edx
f010037d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010037e:	a8 20                	test   $0x20,%al
f0100380:	75 03                	jne    f0100385 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100382:	4b                   	dec    %ebx
f0100383:	75 f1                	jne    f0100376 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100385:	89 f2                	mov    %esi,%edx
f0100387:	89 f0                	mov    %esi,%eax
f0100389:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010038c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100391:	ee                   	out    %al,(%dx)
f0100392:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100397:	bf 79 03 00 00       	mov    $0x379,%edi
f010039c:	eb 05                	jmp    f01003a3 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f010039e:	e8 51 ff ff ff       	call   f01002f4 <delay>
f01003a3:	89 fa                	mov    %edi,%edx
f01003a5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a6:	84 c0                	test   %al,%al
f01003a8:	78 03                	js     f01003ad <cons_putc+0x4e>
f01003aa:	4b                   	dec    %ebx
f01003ab:	75 f1                	jne    f010039e <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ad:	ba 78 03 00 00       	mov    $0x378,%edx
f01003b2:	8a 45 e7             	mov    -0x19(%ebp),%al
f01003b5:	ee                   	out    %al,(%dx)
f01003b6:	b2 7a                	mov    $0x7a,%dl
f01003b8:	b0 0d                	mov    $0xd,%al
f01003ba:	ee                   	out    %al,(%dx)
f01003bb:	b0 08                	mov    $0x8,%al
f01003bd:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003be:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003c4:	75 06                	jne    f01003cc <cons_putc+0x6d>
		c |= 0x0700;
f01003c6:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003cc:	89 f0                	mov    %esi,%eax
f01003ce:	25 ff 00 00 00       	and    $0xff,%eax
f01003d3:	83 f8 09             	cmp    $0x9,%eax
f01003d6:	74 78                	je     f0100450 <cons_putc+0xf1>
f01003d8:	83 f8 09             	cmp    $0x9,%eax
f01003db:	7f 0b                	jg     f01003e8 <cons_putc+0x89>
f01003dd:	83 f8 08             	cmp    $0x8,%eax
f01003e0:	0f 85 9e 00 00 00    	jne    f0100484 <cons_putc+0x125>
f01003e6:	eb 10                	jmp    f01003f8 <cons_putc+0x99>
f01003e8:	83 f8 0a             	cmp    $0xa,%eax
f01003eb:	74 39                	je     f0100426 <cons_putc+0xc7>
f01003ed:	83 f8 0d             	cmp    $0xd,%eax
f01003f0:	0f 85 8e 00 00 00    	jne    f0100484 <cons_putc+0x125>
f01003f6:	eb 36                	jmp    f010042e <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f01003f8:	66 a1 34 12 2e f0    	mov    0xf02e1234,%ax
f01003fe:	66 85 c0             	test   %ax,%ax
f0100401:	0f 84 e2 00 00 00    	je     f01004e9 <cons_putc+0x18a>
			crt_pos--;
f0100407:	48                   	dec    %eax
f0100408:	66 a3 34 12 2e f0    	mov    %ax,0xf02e1234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010040e:	0f b7 c0             	movzwl %ax,%eax
f0100411:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100417:	83 ce 20             	or     $0x20,%esi
f010041a:	8b 15 30 12 2e f0    	mov    0xf02e1230,%edx
f0100420:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100424:	eb 78                	jmp    f010049e <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100426:	66 83 05 34 12 2e f0 	addw   $0x50,0xf02e1234
f010042d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010042e:	66 8b 0d 34 12 2e f0 	mov    0xf02e1234,%cx
f0100435:	bb 50 00 00 00       	mov    $0x50,%ebx
f010043a:	89 c8                	mov    %ecx,%eax
f010043c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100441:	66 f7 f3             	div    %bx
f0100444:	66 29 d1             	sub    %dx,%cx
f0100447:	66 89 0d 34 12 2e f0 	mov    %cx,0xf02e1234
f010044e:	eb 4e                	jmp    f010049e <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f0100450:	b8 20 00 00 00       	mov    $0x20,%eax
f0100455:	e8 05 ff ff ff       	call   f010035f <cons_putc>
		cons_putc(' ');
f010045a:	b8 20 00 00 00       	mov    $0x20,%eax
f010045f:	e8 fb fe ff ff       	call   f010035f <cons_putc>
		cons_putc(' ');
f0100464:	b8 20 00 00 00       	mov    $0x20,%eax
f0100469:	e8 f1 fe ff ff       	call   f010035f <cons_putc>
		cons_putc(' ');
f010046e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100473:	e8 e7 fe ff ff       	call   f010035f <cons_putc>
		cons_putc(' ');
f0100478:	b8 20 00 00 00       	mov    $0x20,%eax
f010047d:	e8 dd fe ff ff       	call   f010035f <cons_putc>
f0100482:	eb 1a                	jmp    f010049e <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100484:	66 a1 34 12 2e f0    	mov    0xf02e1234,%ax
f010048a:	0f b7 c8             	movzwl %ax,%ecx
f010048d:	8b 15 30 12 2e f0    	mov    0xf02e1230,%edx
f0100493:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100497:	40                   	inc    %eax
f0100498:	66 a3 34 12 2e f0    	mov    %ax,0xf02e1234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010049e:	66 81 3d 34 12 2e f0 	cmpw   $0x7cf,0xf02e1234
f01004a5:	cf 07 
f01004a7:	76 40                	jbe    f01004e9 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004a9:	a1 30 12 2e f0       	mov    0xf02e1230,%eax
f01004ae:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004b5:	00 
f01004b6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004bc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004c0:	89 04 24             	mov    %eax,(%esp)
f01004c3:	e8 40 59 00 00       	call   f0105e08 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004c8:	8b 15 30 12 2e f0    	mov    0xf02e1230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004ce:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004d3:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004d9:	40                   	inc    %eax
f01004da:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004df:	75 f2                	jne    f01004d3 <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004e1:	66 83 2d 34 12 2e f0 	subw   $0x50,0xf02e1234
f01004e8:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004e9:	8b 0d 2c 12 2e f0    	mov    0xf02e122c,%ecx
f01004ef:	b0 0e                	mov    $0xe,%al
f01004f1:	89 ca                	mov    %ecx,%edx
f01004f3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004f4:	66 8b 35 34 12 2e f0 	mov    0xf02e1234,%si
f01004fb:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004fe:	89 f0                	mov    %esi,%eax
f0100500:	66 c1 e8 08          	shr    $0x8,%ax
f0100504:	89 da                	mov    %ebx,%edx
f0100506:	ee                   	out    %al,(%dx)
f0100507:	b0 0f                	mov    $0xf,%al
f0100509:	89 ca                	mov    %ecx,%edx
f010050b:	ee                   	out    %al,(%dx)
f010050c:	89 f0                	mov    %esi,%eax
f010050e:	89 da                	mov    %ebx,%edx
f0100510:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100511:	83 c4 2c             	add    $0x2c,%esp
f0100514:	5b                   	pop    %ebx
f0100515:	5e                   	pop    %esi
f0100516:	5f                   	pop    %edi
f0100517:	5d                   	pop    %ebp
f0100518:	c3                   	ret    

f0100519 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100519:	55                   	push   %ebp
f010051a:	89 e5                	mov    %esp,%ebp
f010051c:	53                   	push   %ebx
f010051d:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100520:	ba 64 00 00 00       	mov    $0x64,%edx
f0100525:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100526:	0f b6 c0             	movzbl %al,%eax
f0100529:	a8 01                	test   $0x1,%al
f010052b:	0f 84 e0 00 00 00    	je     f0100611 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100531:	a8 20                	test   $0x20,%al
f0100533:	0f 85 df 00 00 00    	jne    f0100618 <kbd_proc_data+0xff>
f0100539:	b2 60                	mov    $0x60,%dl
f010053b:	ec                   	in     (%dx),%al
f010053c:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010053e:	3c e0                	cmp    $0xe0,%al
f0100540:	75 11                	jne    f0100553 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f0100542:	83 0d 28 12 2e f0 40 	orl    $0x40,0xf02e1228
		return 0;
f0100549:	bb 00 00 00 00       	mov    $0x0,%ebx
f010054e:	e9 ca 00 00 00       	jmp    f010061d <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f0100553:	84 c0                	test   %al,%al
f0100555:	79 33                	jns    f010058a <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100557:	8b 0d 28 12 2e f0    	mov    0xf02e1228,%ecx
f010055d:	f6 c1 40             	test   $0x40,%cl
f0100560:	75 05                	jne    f0100567 <kbd_proc_data+0x4e>
f0100562:	88 c2                	mov    %al,%dl
f0100564:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100567:	0f b6 d2             	movzbl %dl,%edx
f010056a:	8a 82 00 78 10 f0    	mov    -0xfef8800(%edx),%al
f0100570:	83 c8 40             	or     $0x40,%eax
f0100573:	0f b6 c0             	movzbl %al,%eax
f0100576:	f7 d0                	not    %eax
f0100578:	21 c1                	and    %eax,%ecx
f010057a:	89 0d 28 12 2e f0    	mov    %ecx,0xf02e1228
		return 0;
f0100580:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100585:	e9 93 00 00 00       	jmp    f010061d <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f010058a:	8b 0d 28 12 2e f0    	mov    0xf02e1228,%ecx
f0100590:	f6 c1 40             	test   $0x40,%cl
f0100593:	74 0e                	je     f01005a3 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100595:	88 c2                	mov    %al,%dl
f0100597:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010059a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010059d:	89 0d 28 12 2e f0    	mov    %ecx,0xf02e1228
	}

	shift |= shiftcode[data];
f01005a3:	0f b6 d2             	movzbl %dl,%edx
f01005a6:	0f b6 82 00 78 10 f0 	movzbl -0xfef8800(%edx),%eax
f01005ad:	0b 05 28 12 2e f0    	or     0xf02e1228,%eax
	shift ^= togglecode[data];
f01005b3:	0f b6 8a 00 79 10 f0 	movzbl -0xfef8700(%edx),%ecx
f01005ba:	31 c8                	xor    %ecx,%eax
f01005bc:	a3 28 12 2e f0       	mov    %eax,0xf02e1228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005c1:	89 c1                	mov    %eax,%ecx
f01005c3:	83 e1 03             	and    $0x3,%ecx
f01005c6:	8b 0c 8d 00 7a 10 f0 	mov    -0xfef8600(,%ecx,4),%ecx
f01005cd:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005d1:	a8 08                	test   $0x8,%al
f01005d3:	74 18                	je     f01005ed <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f01005d5:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005d8:	83 fa 19             	cmp    $0x19,%edx
f01005db:	77 05                	ja     f01005e2 <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f01005dd:	83 eb 20             	sub    $0x20,%ebx
f01005e0:	eb 0b                	jmp    f01005ed <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f01005e2:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005e5:	83 fa 19             	cmp    $0x19,%edx
f01005e8:	77 03                	ja     f01005ed <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f01005ea:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005ed:	f7 d0                	not    %eax
f01005ef:	a8 06                	test   $0x6,%al
f01005f1:	75 2a                	jne    f010061d <kbd_proc_data+0x104>
f01005f3:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005f9:	75 22                	jne    f010061d <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01005fb:	c7 04 24 c2 77 10 f0 	movl   $0xf01077c2,(%esp)
f0100602:	e8 83 38 00 00       	call   f0103e8a <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100607:	ba 92 00 00 00       	mov    $0x92,%edx
f010060c:	b0 03                	mov    $0x3,%al
f010060e:	ee                   	out    %al,(%dx)
f010060f:	eb 0c                	jmp    f010061d <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100611:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100616:	eb 05                	jmp    f010061d <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100618:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010061d:	89 d8                	mov    %ebx,%eax
f010061f:	83 c4 14             	add    $0x14,%esp
f0100622:	5b                   	pop    %ebx
f0100623:	5d                   	pop    %ebp
f0100624:	c3                   	ret    

f0100625 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010062b:	80 3d 00 10 2e f0 00 	cmpb   $0x0,0xf02e1000
f0100632:	74 0a                	je     f010063e <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100634:	b8 02 03 10 f0       	mov    $0xf0100302,%eax
f0100639:	e8 e0 fc ff ff       	call   f010031e <cons_intr>
}
f010063e:	c9                   	leave  
f010063f:	c3                   	ret    

f0100640 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100646:	b8 19 05 10 f0       	mov    $0xf0100519,%eax
f010064b:	e8 ce fc ff ff       	call   f010031e <cons_intr>
}
f0100650:	c9                   	leave  
f0100651:	c3                   	ret    

f0100652 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100652:	55                   	push   %ebp
f0100653:	89 e5                	mov    %esp,%ebp
f0100655:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100658:	e8 c8 ff ff ff       	call   f0100625 <serial_intr>
	kbd_intr();
f010065d:	e8 de ff ff ff       	call   f0100640 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100662:	8b 15 20 12 2e f0    	mov    0xf02e1220,%edx
f0100668:	3b 15 24 12 2e f0    	cmp    0xf02e1224,%edx
f010066e:	74 22                	je     f0100692 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100670:	0f b6 82 20 10 2e f0 	movzbl -0xfd1efe0(%edx),%eax
f0100677:	42                   	inc    %edx
f0100678:	89 15 20 12 2e f0    	mov    %edx,0xf02e1220
		if (cons.rpos == CONSBUFSIZE)
f010067e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100684:	75 11                	jne    f0100697 <cons_getc+0x45>
			cons.rpos = 0;
f0100686:	c7 05 20 12 2e f0 00 	movl   $0x0,0xf02e1220
f010068d:	00 00 00 
f0100690:	eb 05                	jmp    f0100697 <cons_getc+0x45>
		return c;
	}
	return 0;
f0100692:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100697:	c9                   	leave  
f0100698:	c3                   	ret    

f0100699 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100699:	55                   	push   %ebp
f010069a:	89 e5                	mov    %esp,%ebp
f010069c:	57                   	push   %edi
f010069d:	56                   	push   %esi
f010069e:	53                   	push   %ebx
f010069f:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006a2:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01006a9:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006b0:	5a a5 
	if (*cp != 0xA55A) {
f01006b2:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01006b8:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006bc:	74 11                	je     f01006cf <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006be:	c7 05 2c 12 2e f0 b4 	movl   $0x3b4,0xf02e122c
f01006c5:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006c8:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006cd:	eb 16                	jmp    f01006e5 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006cf:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006d6:	c7 05 2c 12 2e f0 d4 	movl   $0x3d4,0xf02e122c
f01006dd:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006e0:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006e5:	8b 0d 2c 12 2e f0    	mov    0xf02e122c,%ecx
f01006eb:	b0 0e                	mov    $0xe,%al
f01006ed:	89 ca                	mov    %ecx,%edx
f01006ef:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006f0:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f3:	89 da                	mov    %ebx,%edx
f01006f5:	ec                   	in     (%dx),%al
f01006f6:	0f b6 f8             	movzbl %al,%edi
f01006f9:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006fc:	b0 0f                	mov    $0xf,%al
f01006fe:	89 ca                	mov    %ecx,%edx
f0100700:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100701:	89 da                	mov    %ebx,%edx
f0100703:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100704:	89 35 30 12 2e f0    	mov    %esi,0xf02e1230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010070a:	0f b6 d8             	movzbl %al,%ebx
f010070d:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010070f:	66 89 3d 34 12 2e f0 	mov    %di,0xf02e1234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100716:	e8 25 ff ff ff       	call   f0100640 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f010071b:	0f b7 05 a8 c3 12 f0 	movzwl 0xf012c3a8,%eax
f0100722:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100727:	89 04 24             	mov    %eax,(%esp)
f010072a:	e8 2d 36 00 00       	call   f0103d5c <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010072f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100734:	b0 00                	mov    $0x0,%al
f0100736:	89 da                	mov    %ebx,%edx
f0100738:	ee                   	out    %al,(%dx)
f0100739:	b2 fb                	mov    $0xfb,%dl
f010073b:	b0 80                	mov    $0x80,%al
f010073d:	ee                   	out    %al,(%dx)
f010073e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100743:	b0 0c                	mov    $0xc,%al
f0100745:	89 ca                	mov    %ecx,%edx
f0100747:	ee                   	out    %al,(%dx)
f0100748:	b2 f9                	mov    $0xf9,%dl
f010074a:	b0 00                	mov    $0x0,%al
f010074c:	ee                   	out    %al,(%dx)
f010074d:	b2 fb                	mov    $0xfb,%dl
f010074f:	b0 03                	mov    $0x3,%al
f0100751:	ee                   	out    %al,(%dx)
f0100752:	b2 fc                	mov    $0xfc,%dl
f0100754:	b0 00                	mov    $0x0,%al
f0100756:	ee                   	out    %al,(%dx)
f0100757:	b2 f9                	mov    $0xf9,%dl
f0100759:	b0 01                	mov    $0x1,%al
f010075b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010075c:	b2 fd                	mov    $0xfd,%dl
f010075e:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010075f:	3c ff                	cmp    $0xff,%al
f0100761:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100765:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100768:	a2 00 10 2e f0       	mov    %al,0xf02e1000
f010076d:	89 da                	mov    %ebx,%edx
f010076f:	ec                   	in     (%dx),%al
f0100770:	89 ca                	mov    %ecx,%edx
f0100772:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100773:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100777:	74 1d                	je     f0100796 <cons_init+0xfd>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100779:	0f b7 05 a8 c3 12 f0 	movzwl 0xf012c3a8,%eax
f0100780:	25 ef ff 00 00       	and    $0xffef,%eax
f0100785:	89 04 24             	mov    %eax,(%esp)
f0100788:	e8 cf 35 00 00       	call   f0103d5c <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010078d:	80 3d 00 10 2e f0 00 	cmpb   $0x0,0xf02e1000
f0100794:	75 0c                	jne    f01007a2 <cons_init+0x109>
		cprintf("Serial port does not exist!\n");
f0100796:	c7 04 24 ce 77 10 f0 	movl   $0xf01077ce,(%esp)
f010079d:	e8 e8 36 00 00       	call   f0103e8a <cprintf>
}
f01007a2:	83 c4 2c             	add    $0x2c,%esp
f01007a5:	5b                   	pop    %ebx
f01007a6:	5e                   	pop    %esi
f01007a7:	5f                   	pop    %edi
f01007a8:	5d                   	pop    %ebp
f01007a9:	c3                   	ret    

f01007aa <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007aa:	55                   	push   %ebp
f01007ab:	89 e5                	mov    %esp,%ebp
f01007ad:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01007b3:	e8 a7 fb ff ff       	call   f010035f <cons_putc>
}
f01007b8:	c9                   	leave  
f01007b9:	c3                   	ret    

f01007ba <getchar>:

int
getchar(void)
{
f01007ba:	55                   	push   %ebp
f01007bb:	89 e5                	mov    %esp,%ebp
f01007bd:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007c0:	e8 8d fe ff ff       	call   f0100652 <cons_getc>
f01007c5:	85 c0                	test   %eax,%eax
f01007c7:	74 f7                	je     f01007c0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007c9:	c9                   	leave  
f01007ca:	c3                   	ret    

f01007cb <iscons>:

int
iscons(int fdnum)
{
f01007cb:	55                   	push   %ebp
f01007cc:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007ce:	b8 01 00 00 00       	mov    $0x1,%eax
f01007d3:	5d                   	pop    %ebp
f01007d4:	c3                   	ret    
f01007d5:	00 00                	add    %al,(%eax)
	...

f01007d8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007d8:	55                   	push   %ebp
f01007d9:	89 e5                	mov    %esp,%ebp
f01007db:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007de:	c7 04 24 10 7a 10 f0 	movl   $0xf0107a10,(%esp)
f01007e5:	e8 a0 36 00 00       	call   f0103e8a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ea:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007f1:	00 
f01007f2:	c7 04 24 e8 7a 10 f0 	movl   $0xf0107ae8,(%esp)
f01007f9:	e8 8c 36 00 00       	call   f0103e8a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007fe:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100805:	00 
f0100806:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010080d:	f0 
f010080e:	c7 04 24 10 7b 10 f0 	movl   $0xf0107b10,(%esp)
f0100815:	e8 70 36 00 00       	call   f0103e8a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081a:	c7 44 24 08 fe 76 10 	movl   $0x1076fe,0x8(%esp)
f0100821:	00 
f0100822:	c7 44 24 04 fe 76 10 	movl   $0xf01076fe,0x4(%esp)
f0100829:	f0 
f010082a:	c7 04 24 34 7b 10 f0 	movl   $0xf0107b34,(%esp)
f0100831:	e8 54 36 00 00       	call   f0103e8a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100836:	c7 44 24 08 00 10 2e 	movl   $0x2e1000,0x8(%esp)
f010083d:	00 
f010083e:	c7 44 24 04 00 10 2e 	movl   $0xf02e1000,0x4(%esp)
f0100845:	f0 
f0100846:	c7 04 24 58 7b 10 f0 	movl   $0xf0107b58,(%esp)
f010084d:	e8 38 36 00 00       	call   f0103e8a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100852:	c7 44 24 08 14 30 32 	movl   $0x323014,0x8(%esp)
f0100859:	00 
f010085a:	c7 44 24 04 14 30 32 	movl   $0xf0323014,0x4(%esp)
f0100861:	f0 
f0100862:	c7 04 24 7c 7b 10 f0 	movl   $0xf0107b7c,(%esp)
f0100869:	e8 1c 36 00 00       	call   f0103e8a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010086e:	b8 13 34 32 f0       	mov    $0xf0323413,%eax
f0100873:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100878:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087d:	89 c2                	mov    %eax,%edx
f010087f:	85 c0                	test   %eax,%eax
f0100881:	79 06                	jns    f0100889 <mon_kerninfo+0xb1>
f0100883:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100889:	c1 fa 0a             	sar    $0xa,%edx
f010088c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100890:	c7 04 24 a0 7b 10 f0 	movl   $0xf0107ba0,(%esp)
f0100897:	e8 ee 35 00 00       	call   f0103e8a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010089c:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a1:	c9                   	leave  
f01008a2:	c3                   	ret    

f01008a3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008a3:	55                   	push   %ebp
f01008a4:	89 e5                	mov    %esp,%ebp
f01008a6:	53                   	push   %ebx
f01008a7:	83 ec 14             	sub    $0x14,%esp
f01008aa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008af:	8b 83 44 7c 10 f0    	mov    -0xfef83bc(%ebx),%eax
f01008b5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008b9:	8b 83 40 7c 10 f0    	mov    -0xfef83c0(%ebx),%eax
f01008bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c3:	c7 04 24 29 7a 10 f0 	movl   $0xf0107a29,(%esp)
f01008ca:	e8 bb 35 00 00       	call   f0103e8a <cprintf>
f01008cf:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01008d2:	83 fb 24             	cmp    $0x24,%ebx
f01008d5:	75 d8                	jne    f01008af <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01008dc:	83 c4 14             	add    $0x14,%esp
f01008df:	5b                   	pop    %ebx
f01008e0:	5d                   	pop    %ebp
f01008e1:	c3                   	ret    

f01008e2 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008e2:	55                   	push   %ebp
f01008e3:	89 e5                	mov    %esp,%ebp
f01008e5:	57                   	push   %edi
f01008e6:	56                   	push   %esi
f01008e7:	53                   	push   %ebx
f01008e8:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
	uint32_t *ebp;
	ebp=(uint32_t*)read_ebp();
f01008eb:	89 eb                	mov    %ebp,%ebx
		for(int i=0; i<5; ++i){
			cprintf("%08x ",*(ebp+2+i));	
		}		
		cprintf("\n");
		struct Eipdebuginfo info;
		debuginfo_eip((uintptr_t)(*(ebp+1)), &info);
f01008ed:	8d 7d d0             	lea    -0x30(%ebp),%edi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t *ebp;
	ebp=(uint32_t*)read_ebp();
	while(ebp!=0){
f01008f0:	e9 85 00 00 00       	jmp    f010097a <mon_backtrace+0x98>
		cprintf("ebp %08x eip %08x  args ", ebp, *(ebp+1));			
f01008f5:	8b 43 04             	mov    0x4(%ebx),%eax
f01008f8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100900:	c7 04 24 32 7a 10 f0 	movl   $0xf0107a32,(%esp)
f0100907:	e8 7e 35 00 00       	call   f0103e8a <cprintf>
		for(int i=0; i<5; ++i){
f010090c:	be 00 00 00 00       	mov    $0x0,%esi
			cprintf("%08x ",*(ebp+2+i));	
f0100911:	8b 44 b3 08          	mov    0x8(%ebx,%esi,4),%eax
f0100915:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100919:	c7 04 24 4b 7a 10 f0 	movl   $0xf0107a4b,(%esp)
f0100920:	e8 65 35 00 00       	call   f0103e8a <cprintf>
	// Your code here.
	uint32_t *ebp;
	ebp=(uint32_t*)read_ebp();
	while(ebp!=0){
		cprintf("ebp %08x eip %08x  args ", ebp, *(ebp+1));			
		for(int i=0; i<5; ++i){
f0100925:	46                   	inc    %esi
f0100926:	83 fe 05             	cmp    $0x5,%esi
f0100929:	75 e6                	jne    f0100911 <mon_backtrace+0x2f>
			cprintf("%08x ",*(ebp+2+i));	
		}		
		cprintf("\n");
f010092b:	c7 04 24 f7 88 10 f0 	movl   $0xf01088f7,(%esp)
f0100932:	e8 53 35 00 00       	call   f0103e8a <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip((uintptr_t)(*(ebp+1)), &info);
f0100937:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010093b:	8b 43 04             	mov    0x4(%ebx),%eax
f010093e:	89 04 24             	mov    %eax,(%esp)
f0100941:	e8 7f 4a 00 00       	call   f01053c5 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen,
f0100946:	8b 43 04             	mov    0x4(%ebx),%eax
f0100949:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010094c:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100950:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100953:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100957:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010095a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010095e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100961:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100965:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100968:	89 44 24 04          	mov    %eax,0x4(%esp)
f010096c:	c7 04 24 51 7a 10 f0 	movl   $0xf0107a51,(%esp)
f0100973:	e8 12 35 00 00       	call   f0103e8a <cprintf>
				info.eip_fn_name, *(ebp+1) - info.eip_fn_addr);
		ebp=(uint32_t*)(*ebp);
f0100978:	8b 1b                	mov    (%ebx),%ebx
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t *ebp;
	ebp=(uint32_t*)read_ebp();
	while(ebp!=0){
f010097a:	85 db                	test   %ebx,%ebx
f010097c:	0f 85 73 ff ff ff    	jne    f01008f5 <mon_backtrace+0x13>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen,
				info.eip_fn_name, *(ebp+1) - info.eip_fn_addr);
		ebp=(uint32_t*)(*ebp);
	}
	return 0;
}
f0100982:	b8 00 00 00 00       	mov    $0x0,%eax
f0100987:	83 c4 4c             	add    $0x4c,%esp
f010098a:	5b                   	pop    %ebx
f010098b:	5e                   	pop    %esi
f010098c:	5f                   	pop    %edi
f010098d:	5d                   	pop    %ebp
f010098e:	c3                   	ret    

f010098f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010098f:	55                   	push   %ebp
f0100990:	89 e5                	mov    %esp,%ebp
f0100992:	57                   	push   %edi
f0100993:	56                   	push   %esi
f0100994:	53                   	push   %ebx
f0100995:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100998:	c7 04 24 cc 7b 10 f0 	movl   $0xf0107bcc,(%esp)
f010099f:	e8 e6 34 00 00       	call   f0103e8a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009a4:	c7 04 24 f0 7b 10 f0 	movl   $0xf0107bf0,(%esp)
f01009ab:	e8 da 34 00 00       	call   f0103e8a <cprintf>

	if (tf != NULL)
f01009b0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009b4:	74 0b                	je     f01009c1 <monitor+0x32>
		print_trapframe(tf);
f01009b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01009b9:	89 04 24             	mov    %eax,(%esp)
f01009bc:	e8 9a 37 00 00       	call   f010415b <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01009c1:	c7 04 24 62 7a 10 f0 	movl   $0xf0107a62,(%esp)
f01009c8:	e8 b7 51 00 00       	call   f0105b84 <readline>
f01009cd:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009cf:	85 c0                	test   %eax,%eax
f01009d1:	74 ee                	je     f01009c1 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009d3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009da:	be 00 00 00 00       	mov    $0x0,%esi
f01009df:	eb 04                	jmp    f01009e5 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009e1:	c6 03 00             	movb   $0x0,(%ebx)
f01009e4:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009e5:	8a 03                	mov    (%ebx),%al
f01009e7:	84 c0                	test   %al,%al
f01009e9:	74 5e                	je     f0100a49 <monitor+0xba>
f01009eb:	0f be c0             	movsbl %al,%eax
f01009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f2:	c7 04 24 66 7a 10 f0 	movl   $0xf0107a66,(%esp)
f01009f9:	e8 8b 53 00 00       	call   f0105d89 <strchr>
f01009fe:	85 c0                	test   %eax,%eax
f0100a00:	75 df                	jne    f01009e1 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100a02:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a05:	74 42                	je     f0100a49 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a07:	83 fe 0f             	cmp    $0xf,%esi
f0100a0a:	75 16                	jne    f0100a22 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a0c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a13:	00 
f0100a14:	c7 04 24 6b 7a 10 f0 	movl   $0xf0107a6b,(%esp)
f0100a1b:	e8 6a 34 00 00       	call   f0103e8a <cprintf>
f0100a20:	eb 9f                	jmp    f01009c1 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a22:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a26:	46                   	inc    %esi
f0100a27:	eb 01                	jmp    f0100a2a <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a29:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a2a:	8a 03                	mov    (%ebx),%al
f0100a2c:	84 c0                	test   %al,%al
f0100a2e:	74 b5                	je     f01009e5 <monitor+0x56>
f0100a30:	0f be c0             	movsbl %al,%eax
f0100a33:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a37:	c7 04 24 66 7a 10 f0 	movl   $0xf0107a66,(%esp)
f0100a3e:	e8 46 53 00 00       	call   f0105d89 <strchr>
f0100a43:	85 c0                	test   %eax,%eax
f0100a45:	74 e2                	je     f0100a29 <monitor+0x9a>
f0100a47:	eb 9c                	jmp    f01009e5 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100a49:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a50:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a51:	85 f6                	test   %esi,%esi
f0100a53:	0f 84 68 ff ff ff    	je     f01009c1 <monitor+0x32>
f0100a59:	bb 40 7c 10 f0       	mov    $0xf0107c40,%ebx
f0100a5e:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a63:	8b 03                	mov    (%ebx),%eax
f0100a65:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a69:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a6c:	89 04 24             	mov    %eax,(%esp)
f0100a6f:	e8 c2 52 00 00       	call   f0105d36 <strcmp>
f0100a74:	85 c0                	test   %eax,%eax
f0100a76:	75 24                	jne    f0100a9c <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100a78:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100a7b:	8b 55 08             	mov    0x8(%ebp),%edx
f0100a7e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a82:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a85:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a89:	89 34 24             	mov    %esi,(%esp)
f0100a8c:	ff 14 85 48 7c 10 f0 	call   *-0xfef83b8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a93:	85 c0                	test   %eax,%eax
f0100a95:	78 26                	js     f0100abd <monitor+0x12e>
f0100a97:	e9 25 ff ff ff       	jmp    f01009c1 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a9c:	47                   	inc    %edi
f0100a9d:	83 c3 0c             	add    $0xc,%ebx
f0100aa0:	83 ff 03             	cmp    $0x3,%edi
f0100aa3:	75 be                	jne    f0100a63 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aa5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aac:	c7 04 24 88 7a 10 f0 	movl   $0xf0107a88,(%esp)
f0100ab3:	e8 d2 33 00 00       	call   f0103e8a <cprintf>
f0100ab8:	e9 04 ff ff ff       	jmp    f01009c1 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100abd:	83 c4 5c             	add    $0x5c,%esp
f0100ac0:	5b                   	pop    %ebx
f0100ac1:	5e                   	pop    %esi
f0100ac2:	5f                   	pop    %edi
f0100ac3:	5d                   	pop    %ebp
f0100ac4:	c3                   	ret    
f0100ac5:	00 00                	add    %al,(%eax)
	...

f0100ac8 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ac8:	55                   	push   %ebp
f0100ac9:	89 e5                	mov    %esp,%ebp
f0100acb:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ace:	89 d1                	mov    %edx,%ecx
f0100ad0:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ad3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ad6:	a8 01                	test   $0x1,%al
f0100ad8:	74 4d                	je     f0100b27 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ada:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100adf:	89 c1                	mov    %eax,%ecx
f0100ae1:	c1 e9 0c             	shr    $0xc,%ecx
f0100ae4:	3b 0d 98 1e 2e f0    	cmp    0xf02e1e98,%ecx
f0100aea:	72 20                	jb     f0100b0c <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100af0:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0100af7:	f0 
f0100af8:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0100aff:	00 
f0100b00:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100b07:	e8 34 f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b0c:	c1 ea 0c             	shr    $0xc,%edx
f0100b0f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b15:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b1c:	a8 01                	test   $0x1,%al
f0100b1e:	74 0e                	je     f0100b2e <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b25:	eb 0c                	jmp    f0100b33 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b2c:	eb 05                	jmp    f0100b33 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100b2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100b33:	c9                   	leave  
f0100b34:	c3                   	ret    

f0100b35 <boot_alloc>:
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100b35:	55                   	push   %ebp
f0100b36:	89 e5                	mov    %esp,%ebp
f0100b38:	53                   	push   %ebx
f0100b39:	83 ec 14             	sub    $0x14,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b3c:	83 3d 3c 12 2e f0 00 	cmpl   $0x0,0xf02e123c
f0100b43:	75 11                	jne    f0100b56 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b45:	ba 13 40 32 f0       	mov    $0xf0324013,%edx
f0100b4a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b50:	89 15 3c 12 2e f0    	mov    %edx,0xf02e123c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n + (uint32_t)nextfree < (uint32_t)nextfree){
f0100b56:	8b 1d 3c 12 2e f0    	mov    0xf02e123c,%ebx
f0100b5c:	8d 14 18             	lea    (%eax,%ebx,1),%edx
f0100b5f:	39 d3                	cmp    %edx,%ebx
f0100b61:	76 1c                	jbe    f0100b7f <boot_alloc+0x4a>
		panic("out of memory!\n");
f0100b63:	c7 44 24 08 d1 85 10 	movl   $0xf01085d1,0x8(%esp)
f0100b6a:	f0 
f0100b6b:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0100b72:	00 
f0100b73:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100b7a:	e8 c1 f4 ff ff       	call   f0100040 <_panic>
	}else if (n == 0){
f0100b7f:	85 c0                	test   %eax,%eax
f0100b81:	74 12                	je     f0100b95 <boot_alloc+0x60>
		result = nextfree;
	}else{
		result = nextfree;
		nextfree = ROUNDUP((char *)(n + (uint32_t)nextfree), PGSIZE);
f0100b83:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100b89:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b8f:	89 15 3c 12 2e f0    	mov    %edx,0xf02e123c
	}
	
	cprintf("boot alloc %u bytes\n", (uint32_t)ROUNDUP((char *)n, PGSIZE));
f0100b95:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ba3:	c7 04 24 e1 85 10 f0 	movl   $0xf01085e1,(%esp)
f0100baa:	e8 db 32 00 00       	call   f0103e8a <cprintf>
	return result;
}
f0100baf:	89 d8                	mov    %ebx,%eax
f0100bb1:	83 c4 14             	add    $0x14,%esp
f0100bb4:	5b                   	pop    %ebx
f0100bb5:	5d                   	pop    %ebp
f0100bb6:	c3                   	ret    

f0100bb7 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100bb7:	55                   	push   %ebp
f0100bb8:	89 e5                	mov    %esp,%ebp
f0100bba:	56                   	push   %esi
f0100bbb:	53                   	push   %ebx
f0100bbc:	83 ec 10             	sub    $0x10,%esp
f0100bbf:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100bc1:	89 04 24             	mov    %eax,(%esp)
f0100bc4:	e8 6b 31 00 00       	call   f0103d34 <mc146818_read>
f0100bc9:	89 c6                	mov    %eax,%esi
f0100bcb:	43                   	inc    %ebx
f0100bcc:	89 1c 24             	mov    %ebx,(%esp)
f0100bcf:	e8 60 31 00 00       	call   f0103d34 <mc146818_read>
f0100bd4:	c1 e0 08             	shl    $0x8,%eax
f0100bd7:	09 f0                	or     %esi,%eax
}
f0100bd9:	83 c4 10             	add    $0x10,%esp
f0100bdc:	5b                   	pop    %ebx
f0100bdd:	5e                   	pop    %esi
f0100bde:	5d                   	pop    %ebp
f0100bdf:	c3                   	ret    

f0100be0 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100be0:	55                   	push   %ebp
f0100be1:	89 e5                	mov    %esp,%ebp
f0100be3:	57                   	push   %edi
f0100be4:	56                   	push   %esi
f0100be5:	53                   	push   %ebx
f0100be6:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100be9:	3c 01                	cmp    $0x1,%al
f0100beb:	19 f6                	sbb    %esi,%esi
f0100bed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100bf3:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100bf4:	8b 15 40 12 2e f0    	mov    0xf02e1240,%edx
f0100bfa:	85 d2                	test   %edx,%edx
f0100bfc:	75 1c                	jne    f0100c1a <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100bfe:	c7 44 24 08 64 7c 10 	movl   $0xf0107c64,0x8(%esp)
f0100c05:	f0 
f0100c06:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f0100c0d:	00 
f0100c0e:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100c15:	e8 26 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100c1a:	84 c0                	test   %al,%al
f0100c1c:	74 4b                	je     f0100c69 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c1e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100c21:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c24:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100c27:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c2a:	89 d0                	mov    %edx,%eax
f0100c2c:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0100c32:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c35:	c1 e8 16             	shr    $0x16,%eax
f0100c38:	39 c6                	cmp    %eax,%esi
f0100c3a:	0f 96 c0             	setbe  %al
f0100c3d:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100c40:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100c44:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c46:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c4a:	8b 12                	mov    (%edx),%edx
f0100c4c:	85 d2                	test   %edx,%edx
f0100c4e:	75 da                	jne    f0100c2a <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c50:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c59:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100c5f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c61:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c64:	a3 40 12 2e f0       	mov    %eax,0xf02e1240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c69:	8b 1d 40 12 2e f0    	mov    0xf02e1240,%ebx
f0100c6f:	eb 63                	jmp    f0100cd4 <check_page_free_list+0xf4>
f0100c71:	89 d8                	mov    %ebx,%eax
f0100c73:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0100c79:	c1 f8 03             	sar    $0x3,%eax
f0100c7c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c7f:	89 c2                	mov    %eax,%edx
f0100c81:	c1 ea 16             	shr    $0x16,%edx
f0100c84:	39 d6                	cmp    %edx,%esi
f0100c86:	76 4a                	jbe    f0100cd2 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c88:	89 c2                	mov    %eax,%edx
f0100c8a:	c1 ea 0c             	shr    $0xc,%edx
f0100c8d:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f0100c93:	72 20                	jb     f0100cb5 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c95:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c99:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0100ca0:	f0 
f0100ca1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ca8:	00 
f0100ca9:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0100cb0:	e8 8b f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100cb5:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100cbc:	00 
f0100cbd:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100cc4:	00 
	return (void *)(pa + KERNBASE);
f0100cc5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cca:	89 04 24             	mov    %eax,(%esp)
f0100ccd:	e8 ec 50 00 00       	call   f0105dbe <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cd2:	8b 1b                	mov    (%ebx),%ebx
f0100cd4:	85 db                	test   %ebx,%ebx
f0100cd6:	75 99                	jne    f0100c71 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100cd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cdd:	e8 53 fe ff ff       	call   f0100b35 <boot_alloc>
f0100ce2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce5:	8b 15 40 12 2e f0    	mov    0xf02e1240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ceb:	8b 0d a0 1e 2e f0    	mov    0xf02e1ea0,%ecx
		assert(pp < pages + npages);
f0100cf1:	a1 98 1e 2e f0       	mov    0xf02e1e98,%eax
f0100cf6:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100cf9:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100cfc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cff:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d02:	be 00 00 00 00       	mov    $0x0,%esi
f0100d07:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d0a:	e9 c4 01 00 00       	jmp    f0100ed3 <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d0f:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100d12:	73 24                	jae    f0100d38 <check_page_free_list+0x158>
f0100d14:	c7 44 24 0c 04 86 10 	movl   $0xf0108604,0xc(%esp)
f0100d1b:	f0 
f0100d1c:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100d23:	f0 
f0100d24:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0100d2b:	00 
f0100d2c:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100d33:	e8 08 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d38:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d3b:	72 24                	jb     f0100d61 <check_page_free_list+0x181>
f0100d3d:	c7 44 24 0c 25 86 10 	movl   $0xf0108625,0xc(%esp)
f0100d44:	f0 
f0100d45:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100d4c:	f0 
f0100d4d:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f0100d54:	00 
f0100d55:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100d5c:	e8 df f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d61:	89 d0                	mov    %edx,%eax
f0100d63:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d66:	a8 07                	test   $0x7,%al
f0100d68:	74 24                	je     f0100d8e <check_page_free_list+0x1ae>
f0100d6a:	c7 44 24 0c 88 7c 10 	movl   $0xf0107c88,0xc(%esp)
f0100d71:	f0 
f0100d72:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100d79:	f0 
f0100d7a:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f0100d81:	00 
f0100d82:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100d89:	e8 b2 f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d8e:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d91:	c1 e0 0c             	shl    $0xc,%eax
f0100d94:	75 24                	jne    f0100dba <check_page_free_list+0x1da>
f0100d96:	c7 44 24 0c 39 86 10 	movl   $0xf0108639,0xc(%esp)
f0100d9d:	f0 
f0100d9e:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100da5:	f0 
f0100da6:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0100dad:	00 
f0100dae:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100db5:	e8 86 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dba:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dbf:	75 24                	jne    f0100de5 <check_page_free_list+0x205>
f0100dc1:	c7 44 24 0c 4a 86 10 	movl   $0xf010864a,0xc(%esp)
f0100dc8:	f0 
f0100dc9:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100dd0:	f0 
f0100dd1:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0100dd8:	00 
f0100dd9:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100de0:	e8 5b f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100de5:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100dea:	75 24                	jne    f0100e10 <check_page_free_list+0x230>
f0100dec:	c7 44 24 0c bc 7c 10 	movl   $0xf0107cbc,0xc(%esp)
f0100df3:	f0 
f0100df4:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100dfb:	f0 
f0100dfc:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f0100e03:	00 
f0100e04:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100e0b:	e8 30 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e10:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e15:	75 24                	jne    f0100e3b <check_page_free_list+0x25b>
f0100e17:	c7 44 24 0c 63 86 10 	movl   $0xf0108663,0xc(%esp)
f0100e1e:	f0 
f0100e1f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100e26:	f0 
f0100e27:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f0100e2e:	00 
f0100e2f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100e36:	e8 05 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e3b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e40:	76 59                	jbe    f0100e9b <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e42:	89 c1                	mov    %eax,%ecx
f0100e44:	c1 e9 0c             	shr    $0xc,%ecx
f0100e47:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100e4a:	77 20                	ja     f0100e6c <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e50:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0100e57:	f0 
f0100e58:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100e5f:	00 
f0100e60:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0100e67:	e8 d4 f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100e6c:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e72:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100e75:	76 24                	jbe    f0100e9b <check_page_free_list+0x2bb>
f0100e77:	c7 44 24 0c e0 7c 10 	movl   $0xf0107ce0,0xc(%esp)
f0100e7e:	f0 
f0100e7f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100e86:	f0 
f0100e87:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f0100e8e:	00 
f0100e8f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100e96:	e8 a5 f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e9b:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ea0:	75 24                	jne    f0100ec6 <check_page_free_list+0x2e6>
f0100ea2:	c7 44 24 0c 7d 86 10 	movl   $0xf010867d,0xc(%esp)
f0100ea9:	f0 
f0100eaa:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100eb1:	f0 
f0100eb2:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0100eb9:	00 
f0100eba:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100ec1:	e8 7a f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100ec6:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ecb:	77 03                	ja     f0100ed0 <check_page_free_list+0x2f0>
			++nfree_basemem;
f0100ecd:	46                   	inc    %esi
f0100ece:	eb 01                	jmp    f0100ed1 <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f0100ed0:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ed1:	8b 12                	mov    (%edx),%edx
f0100ed3:	85 d2                	test   %edx,%edx
f0100ed5:	0f 85 34 fe ff ff    	jne    f0100d0f <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100edb:	85 f6                	test   %esi,%esi
f0100edd:	7f 24                	jg     f0100f03 <check_page_free_list+0x323>
f0100edf:	c7 44 24 0c 9a 86 10 	movl   $0xf010869a,0xc(%esp)
f0100ee6:	f0 
f0100ee7:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100eee:	f0 
f0100eef:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0100ef6:	00 
f0100ef7:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100efe:	e8 3d f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f03:	85 db                	test   %ebx,%ebx
f0100f05:	7f 24                	jg     f0100f2b <check_page_free_list+0x34b>
f0100f07:	c7 44 24 0c ac 86 10 	movl   $0xf01086ac,0xc(%esp)
f0100f0e:	f0 
f0100f0f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0100f16:	f0 
f0100f17:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0100f1e:	00 
f0100f1f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100f26:	e8 15 f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100f2b:	c7 04 24 28 7d 10 f0 	movl   $0xf0107d28,(%esp)
f0100f32:	e8 53 2f 00 00       	call   f0103e8a <cprintf>
}
f0100f37:	83 c4 4c             	add    $0x4c,%esp
f0100f3a:	5b                   	pop    %ebx
f0100f3b:	5e                   	pop    %esi
f0100f3c:	5f                   	pop    %edi
f0100f3d:	5d                   	pop    %ebp
f0100f3e:	c3                   	ret    

f0100f3f <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f3f:	55                   	push   %ebp
f0100f40:	89 e5                	mov    %esp,%ebp
f0100f42:	57                   	push   %edi
f0100f43:	56                   	push   %esi
f0100f44:	53                   	push   %ebx
f0100f45:	83 ec 2c             	sub    $0x2c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t next=(size_t)boot_alloc(0);
f0100f48:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f4d:	e8 e3 fb ff ff       	call   f0100b35 <boot_alloc>
f0100f52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0; i < npages; i++) {
		if ((i == 0) || (i == MPENTRY_PADDR/PGSIZE) || 
			(i >= npages_basemem && i < (PADDR((void*)next)/PGSIZE)))
f0100f55:	8b 3d 38 12 2e f0    	mov    0xf02e1238,%edi
static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0100f5b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100f61:	c1 ea 0c             	shr    $0xc,%edx
f0100f64:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f67:	8b 35 40 12 2e f0    	mov    0xf02e1240,%esi
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t next=(size_t)boot_alloc(0);
	for (i = 0; i < npages; i++) {
f0100f6d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f72:	eb 61                	jmp    f0100fd5 <page_init+0x96>
		if ((i == 0) || (i == MPENTRY_PADDR/PGSIZE) || 
f0100f74:	85 d2                	test   %edx,%edx
f0100f76:	74 5c                	je     f0100fd4 <page_init+0x95>
f0100f78:	83 fa 07             	cmp    $0x7,%edx
f0100f7b:	74 57                	je     f0100fd4 <page_init+0x95>
f0100f7d:	39 fa                	cmp    %edi,%edx
f0100f7f:	72 34                	jb     f0100fb5 <page_init+0x76>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f81:	81 7d e4 ff ff ff ef 	cmpl   $0xefffffff,-0x1c(%ebp)
f0100f88:	77 26                	ja     f0100fb0 <page_init+0x71>
f0100f8a:	89 35 40 12 2e f0    	mov    %esi,0xf02e1240
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f94:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0100f9b:	f0 
f0100f9c:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f0100fa3:	00 
f0100fa4:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0100fab:	e8 90 f0 ff ff       	call   f0100040 <_panic>
			(i >= npages_basemem && i < (PADDR((void*)next)/PGSIZE)))
f0100fb0:	3b 55 e0             	cmp    -0x20(%ebp),%edx
f0100fb3:	72 1f                	jb     f0100fd4 <page_init+0x95>
			continue;
		pages[i].pp_ref = 0;
f0100fb5:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100fbc:	89 cb                	mov    %ecx,%ebx
f0100fbe:	03 1d a0 1e 2e f0    	add    0xf02e1ea0,%ebx
f0100fc4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f0100fca:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f0100fcc:	89 ce                	mov    %ecx,%esi
f0100fce:	03 35 a0 1e 2e f0    	add    0xf02e1ea0,%esi
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t next=(size_t)boot_alloc(0);
	for (i = 0; i < npages; i++) {
f0100fd4:	42                   	inc    %edx
f0100fd5:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f0100fdb:	72 97                	jb     f0100f74 <page_init+0x35>
f0100fdd:	89 35 40 12 2e f0    	mov    %esi,0xf02e1240
			continue;
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100fe3:	83 c4 2c             	add    $0x2c,%esp
f0100fe6:	5b                   	pop    %ebx
f0100fe7:	5e                   	pop    %esi
f0100fe8:	5f                   	pop    %edi
f0100fe9:	5d                   	pop    %ebp
f0100fea:	c3                   	ret    

f0100feb <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100feb:	55                   	push   %ebp
f0100fec:	89 e5                	mov    %esp,%ebp
f0100fee:	53                   	push   %ebx
f0100fef:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo *result = NULL;
	if(page_free_list != NULL){
f0100ff2:	8b 1d 40 12 2e f0    	mov    0xf02e1240,%ebx
f0100ff8:	85 db                	test   %ebx,%ebx
f0100ffa:	74 6b                	je     f0101067 <page_alloc+0x7c>
		result = page_free_list;
		page_free_list = result->pp_link;
f0100ffc:	8b 03                	mov    (%ebx),%eax
f0100ffe:	a3 40 12 2e f0       	mov    %eax,0xf02e1240
		result->pp_link = NULL;
f0101003:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO){
f0101009:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010100d:	74 58                	je     f0101067 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010100f:	89 d8                	mov    %ebx,%eax
f0101011:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0101017:	c1 f8 03             	sar    $0x3,%eax
f010101a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010101d:	89 c2                	mov    %eax,%edx
f010101f:	c1 ea 0c             	shr    $0xc,%edx
f0101022:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f0101028:	72 20                	jb     f010104a <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010102a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010102e:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0101035:	f0 
f0101036:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010103d:	00 
f010103e:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0101045:	e8 f6 ef ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f010104a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101051:	00 
f0101052:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101059:	00 
	return (void *)(pa + KERNBASE);
f010105a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010105f:	89 04 24             	mov    %eax,(%esp)
f0101062:	e8 57 4d 00 00       	call   f0105dbe <memset>
		}
	}
	
	return result;
}
f0101067:	89 d8                	mov    %ebx,%eax
f0101069:	83 c4 14             	add    $0x14,%esp
f010106c:	5b                   	pop    %ebx
f010106d:	5d                   	pop    %ebp
f010106e:	c3                   	ret    

f010106f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010106f:	55                   	push   %ebp
f0101070:	89 e5                	mov    %esp,%ebp
f0101072:	83 ec 18             	sub    $0x18,%esp
f0101075:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL){
f0101078:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010107d:	75 05                	jne    f0101084 <page_free+0x15>
f010107f:	83 38 00             	cmpl   $0x0,(%eax)
f0101082:	74 1c                	je     f01010a0 <page_free+0x31>
		panic("page_free(), pp->pp_ref is nonzero or pp->pp_link is not NULL\n");
f0101084:	c7 44 24 08 4c 7d 10 	movl   $0xf0107d4c,0x8(%esp)
f010108b:	f0 
f010108c:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f0101093:	00 
f0101094:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010109b:	e8 a0 ef ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f01010a0:	8b 15 40 12 2e f0    	mov    0xf02e1240,%edx
f01010a6:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01010a8:	a3 40 12 2e f0       	mov    %eax,0xf02e1240
}
f01010ad:	c9                   	leave  
f01010ae:	c3                   	ret    

f01010af <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01010af:	55                   	push   %ebp
f01010b0:	89 e5                	mov    %esp,%ebp
f01010b2:	83 ec 18             	sub    $0x18,%esp
f01010b5:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01010b8:	8b 50 04             	mov    0x4(%eax),%edx
f01010bb:	4a                   	dec    %edx
f01010bc:	66 89 50 04          	mov    %dx,0x4(%eax)
f01010c0:	66 85 d2             	test   %dx,%dx
f01010c3:	75 08                	jne    f01010cd <page_decref+0x1e>
		page_free(pp);
f01010c5:	89 04 24             	mov    %eax,(%esp)
f01010c8:	e8 a2 ff ff ff       	call   f010106f <page_free>
}
f01010cd:	c9                   	leave  
f01010ce:	c3                   	ret    

f01010cf <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010cf:	55                   	push   %ebp
f01010d0:	89 e5                	mov    %esp,%ebp
f01010d2:	56                   	push   %esi
f01010d3:	53                   	push   %ebx
f01010d4:	83 ec 10             	sub    $0x10,%esp
f01010d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
		pte_t *ret;
	pde_t *pde = &pgdir[PDX(va)];
f01010da:	89 f3                	mov    %esi,%ebx
f01010dc:	c1 eb 16             	shr    $0x16,%ebx
f01010df:	c1 e3 02             	shl    $0x2,%ebx
f01010e2:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pde & PTE_P))
f01010e5:	f6 03 01             	testb  $0x1,(%ebx)
f01010e8:	75 2b                	jne    f0101115 <pgdir_walk+0x46>
	{
		if (create)
f01010ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010ee:	74 6b                	je     f010115b <pgdir_walk+0x8c>
		{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
f01010f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01010f7:	e8 ef fe ff ff       	call   f0100feb <page_alloc>
			if (page == NULL)
f01010fc:	85 c0                	test   %eax,%eax
f01010fe:	74 62                	je     f0101162 <pgdir_walk+0x93>
				return NULL;
			page->pp_ref++;
f0101100:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101104:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f010110a:	c1 f8 03             	sar    $0x3,%eax
f010110d:	c1 e0 0c             	shl    $0xc,%eax
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f0101110:	83 c8 07             	or     $0x7,%eax
f0101113:	89 03                	mov    %eax,(%ebx)
		}else{
			return NULL;
		}
	}
	ret = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(va);
f0101115:	8b 03                	mov    (%ebx),%eax
f0101117:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010111c:	89 c2                	mov    %eax,%edx
f010111e:	c1 ea 0c             	shr    $0xc,%edx
f0101121:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f0101127:	72 20                	jb     f0101149 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101129:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010112d:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0101134:	f0 
f0101135:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f010113c:	00 
f010113d:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101144:	e8 f7 ee ff ff       	call   f0100040 <_panic>
f0101149:	c1 ee 0a             	shr    $0xa,%esi
f010114c:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101152:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax

	return ret;
f0101159:	eb 0c                	jmp    f0101167 <pgdir_walk+0x98>
			if (page == NULL)
				return NULL;
			page->pp_ref++;
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
		}else{
			return NULL;
f010115b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101160:	eb 05                	jmp    f0101167 <pgdir_walk+0x98>
	{
		if (create)
		{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
			if (page == NULL)
				return NULL;
f0101162:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}
	ret = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(va);

	return ret;
}
f0101167:	83 c4 10             	add    $0x10,%esp
f010116a:	5b                   	pop    %ebx
f010116b:	5e                   	pop    %esi
f010116c:	5d                   	pop    %ebp
f010116d:	c3                   	ret    

f010116e <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010116e:	55                   	push   %ebp
f010116f:	89 e5                	mov    %esp,%ebp
f0101171:	57                   	push   %edi
f0101172:	56                   	push   %esi
f0101173:	53                   	push   %ebx
f0101174:	83 ec 2c             	sub    $0x2c,%esp
f0101177:	89 c6                	mov    %eax,%esi
f0101179:	89 d7                	mov    %edx,%edi
f010117b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	for (size_t i = 0; i * PGSIZE < size; ++i)
f010117e:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		*pte = (pa + i * PGSIZE) | perm | PTE_P;
f0101183:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101186:	83 c8 01             	or     $0x1,%eax
f0101189:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	for (size_t i = 0; i * PGSIZE < size; ++i)
f010118c:	eb 27                	jmp    f01011b5 <boot_map_region+0x47>
	{
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
f010118e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101195:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101196:	8d 04 3b             	lea    (%ebx,%edi,1),%eax
{
	// Fill this function in
	for (size_t i = 0; i * PGSIZE < size; ++i)
	{
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
f0101199:	89 44 24 04          	mov    %eax,0x4(%esp)
f010119d:	89 34 24             	mov    %esi,(%esp)
f01011a0:	e8 2a ff ff ff       	call   f01010cf <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01011a5:	8b 55 08             	mov    0x8(%ebp),%edx
f01011a8:	01 da                	add    %ebx,%edx
{
	// Fill this function in
	for (size_t i = 0; i * PGSIZE < size; ++i)
	{
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		*pte = (pa + i * PGSIZE) | perm | PTE_P;
f01011aa:	0b 55 e0             	or     -0x20(%ebp),%edx
f01011ad:	89 10                	mov    %edx,(%eax)
f01011af:	81 c3 00 10 00 00    	add    $0x1000,%ebx
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	for (size_t i = 0; i * PGSIZE < size; ++i)
f01011b5:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01011b8:	77 d4                	ja     f010118e <boot_map_region+0x20>
	{
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		*pte = (pa + i * PGSIZE) | perm | PTE_P;
	}
}
f01011ba:	83 c4 2c             	add    $0x2c,%esp
f01011bd:	5b                   	pop    %ebx
f01011be:	5e                   	pop    %esi
f01011bf:	5f                   	pop    %edi
f01011c0:	5d                   	pop    %ebp
f01011c1:	c3                   	ret    

f01011c2 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011c2:	55                   	push   %ebp
f01011c3:	89 e5                	mov    %esp,%ebp
f01011c5:	53                   	push   %ebx
f01011c6:	83 ec 14             	sub    $0x14,%esp
f01011c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, false);
f01011cc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01011d3:	00 
f01011d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011db:	8b 45 08             	mov    0x8(%ebp),%eax
f01011de:	89 04 24             	mov    %eax,(%esp)
f01011e1:	e8 e9 fe ff ff       	call   f01010cf <pgdir_walk>
	if ((pte == NULL) || !((*pte) & PTE_P))
f01011e6:	85 c0                	test   %eax,%eax
f01011e8:	74 3f                	je     f0101229 <page_lookup+0x67>
f01011ea:	f6 00 01             	testb  $0x1,(%eax)
f01011ed:	74 41                	je     f0101230 <page_lookup+0x6e>
	{
		return NULL;
	}
	if (pte_store != NULL)
f01011ef:	85 db                	test   %ebx,%ebx
f01011f1:	74 02                	je     f01011f5 <page_lookup+0x33>
		*pte_store = pte;
f01011f3:	89 03                	mov    %eax,(%ebx)
	// cprintf("lookup va %x, pte %x, *pte %x\n", va, pte, *pte);
	return pa2page(PTE_ADDR(*pte));
f01011f5:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011f7:	c1 e8 0c             	shr    $0xc,%eax
f01011fa:	3b 05 98 1e 2e f0    	cmp    0xf02e1e98,%eax
f0101200:	72 1c                	jb     f010121e <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0101202:	c7 44 24 08 8c 7d 10 	movl   $0xf0107d8c,0x8(%esp)
f0101209:	f0 
f010120a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101211:	00 
f0101212:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0101219:	e8 22 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010121e:	c1 e0 03             	shl    $0x3,%eax
f0101221:	03 05 a0 1e 2e f0    	add    0xf02e1ea0,%eax
f0101227:	eb 0c                	jmp    f0101235 <page_lookup+0x73>
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, false);
	if ((pte == NULL) || !((*pte) & PTE_P))
	{
		return NULL;
f0101229:	b8 00 00 00 00       	mov    $0x0,%eax
f010122e:	eb 05                	jmp    f0101235 <page_lookup+0x73>
f0101230:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	if (pte_store != NULL)
		*pte_store = pte;
	// cprintf("lookup va %x, pte %x, *pte %x\n", va, pte, *pte);
	return pa2page(PTE_ADDR(*pte));
}
f0101235:	83 c4 14             	add    $0x14,%esp
f0101238:	5b                   	pop    %ebx
f0101239:	5d                   	pop    %ebp
f010123a:	c3                   	ret    

f010123b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010123b:	55                   	push   %ebp
f010123c:	89 e5                	mov    %esp,%ebp
f010123e:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101241:	e8 b6 51 00 00       	call   f01063fc <cpunum>
f0101246:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010124d:	29 c2                	sub    %eax,%edx
f010124f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101252:	83 3c 85 28 20 2e f0 	cmpl   $0x0,-0xfd1dfd8(,%eax,4)
f0101259:	00 
f010125a:	74 20                	je     f010127c <tlb_invalidate+0x41>
f010125c:	e8 9b 51 00 00       	call   f01063fc <cpunum>
f0101261:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101268:	29 c2                	sub    %eax,%edx
f010126a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010126d:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0101274:	8b 55 08             	mov    0x8(%ebp),%edx
f0101277:	39 50 60             	cmp    %edx,0x60(%eax)
f010127a:	75 06                	jne    f0101282 <tlb_invalidate+0x47>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010127c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010127f:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101282:	c9                   	leave  
f0101283:	c3                   	ret    

f0101284 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101284:	55                   	push   %ebp
f0101285:	89 e5                	mov    %esp,%ebp
f0101287:	56                   	push   %esi
f0101288:	53                   	push   %ebx
f0101289:	83 ec 20             	sub    $0x20,%esp
f010128c:	8b 75 08             	mov    0x8(%ebp),%esi
f010128f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte = NULL;
f0101292:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f0101299:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010129c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012a4:	89 34 24             	mov    %esi,(%esp)
f01012a7:	e8 16 ff ff ff       	call   f01011c2 <page_lookup>
	if (pte)
f01012ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01012b0:	74 1d                	je     f01012cf <page_remove+0x4b>
	{
		page_decref(page);
f01012b2:	89 04 24             	mov    %eax,(%esp)
f01012b5:	e8 f5 fd ff ff       	call   f01010af <page_decref>
		*pte = 0;
f01012ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f01012c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012c7:	89 34 24             	mov    %esi,(%esp)
f01012ca:	e8 6c ff ff ff       	call   f010123b <tlb_invalidate>
	}
}
f01012cf:	83 c4 20             	add    $0x20,%esp
f01012d2:	5b                   	pop    %ebx
f01012d3:	5e                   	pop    %esi
f01012d4:	5d                   	pop    %ebp
f01012d5:	c3                   	ret    

f01012d6 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01012d6:	55                   	push   %ebp
f01012d7:	89 e5                	mov    %esp,%ebp
f01012d9:	57                   	push   %edi
f01012da:	56                   	push   %esi
f01012db:	53                   	push   %ebx
f01012dc:	83 ec 1c             	sub    $0x1c,%esp
f01012df:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012e2:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, true);
f01012e5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012ec:	00 
f01012ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01012f4:	89 04 24             	mov    %eax,(%esp)
f01012f7:	e8 d3 fd ff ff       	call   f01010cf <pgdir_walk>
f01012fc:	89 c3                	mov    %eax,%ebx
	if (pte == NULL)
f01012fe:	85 c0                	test   %eax,%eax
f0101300:	74 39                	je     f010133b <page_insert+0x65>
		return -E_NO_MEM;
	pp->pp_ref++;
f0101302:	66 ff 46 04          	incw   0x4(%esi)
	if ((*pte) & PTE_P)
f0101306:	f6 00 01             	testb  $0x1,(%eax)
f0101309:	74 0f                	je     f010131a <page_insert+0x44>
	{
		page_remove(pgdir, va);
f010130b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010130f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101312:	89 04 24             	mov    %eax,(%esp)
f0101315:	e8 6a ff ff ff       	call   f0101284 <page_remove>
	}
	*pte = page2pa(pp) | perm | PTE_P;
f010131a:	8b 55 14             	mov    0x14(%ebp),%edx
f010131d:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101320:	2b 35 a0 1e 2e f0    	sub    0xf02e1ea0,%esi
f0101326:	c1 fe 03             	sar    $0x3,%esi
f0101329:	89 f0                	mov    %esi,%eax
f010132b:	c1 e0 0c             	shl    $0xc,%eax
f010132e:	89 d6                	mov    %edx,%esi
f0101330:	09 c6                	or     %eax,%esi
f0101332:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101334:	b8 00 00 00 00       	mov    $0x0,%eax
f0101339:	eb 05                	jmp    f0101340 <page_insert+0x6a>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, true);
	if (pte == NULL)
		return -E_NO_MEM;
f010133b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	{
		page_remove(pgdir, va);
	}
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0101340:	83 c4 1c             	add    $0x1c,%esp
f0101343:	5b                   	pop    %ebx
f0101344:	5e                   	pop    %esi
f0101345:	5f                   	pop    %edi
f0101346:	5d                   	pop    %ebp
f0101347:	c3                   	ret    

f0101348 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101348:	55                   	push   %ebp
f0101349:	89 e5                	mov    %esp,%ebp
f010134b:	56                   	push   %esi
f010134c:	53                   	push   %ebx
f010134d:	83 ec 10             	sub    $0x10,%esp
f0101350:	8b 45 08             	mov    0x8(%ebp),%eax
	    uintptr_t result = base;
	    base += map_size;
	    return (void *)result;
	*/
	
	uintptr_t ret = base;
f0101353:	8b 1d 00 c3 12 f0    	mov    0xf012c300,%ebx
	uint32_t low=ROUNDDOWN(pa,PGSIZE), high=ROUNDUP(pa+size,PGSIZE);
f0101359:	89 c2                	mov    %eax,%edx
f010135b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101361:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
f0101367:	03 75 0c             	add    0xc(%ebp),%esi
f010136a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (MMIOLIM  < base + high - low)
f0101370:	89 d9                	mov    %ebx,%ecx
f0101372:	29 d1                	sub    %edx,%ecx
f0101374:	01 f1                	add    %esi,%ecx
f0101376:	81 f9 00 00 c0 ef    	cmp    $0xefc00000,%ecx
f010137c:	76 1c                	jbe    f010139a <mmio_map_region+0x52>
	{
		panic("overflow MMIIOLIM\n");
f010137e:	c7 44 24 08 bd 86 10 	movl   $0xf01086bd,0x8(%esp)
f0101385:	f0 
f0101386:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
f010138d:	00 
f010138e:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101395:	e8 a6 ec ff ff       	call   f0100040 <_panic>
	}
	int perm = PTE_PCD | PTE_PWT | PTE_W | PTE_P;
	boot_map_region(kern_pgdir, base, high-low, pa, perm);
f010139a:	29 d6                	sub    %edx,%esi
f010139c:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
f01013a3:	00 
f01013a4:	89 04 24             	mov    %eax,(%esp)
f01013a7:	89 f1                	mov    %esi,%ecx
f01013a9:	89 da                	mov    %ebx,%edx
f01013ab:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f01013b0:	e8 b9 fd ff ff       	call   f010116e <boot_map_region>
	base += high-low;
f01013b5:	01 35 00 c3 12 f0    	add    %esi,0xf012c300
	return (void*)ret;
	
	// panic("mmio_map_region not implemented");
}
f01013bb:	89 d8                	mov    %ebx,%eax
f01013bd:	83 c4 10             	add    $0x10,%esp
f01013c0:	5b                   	pop    %ebx
f01013c1:	5e                   	pop    %esi
f01013c2:	5d                   	pop    %ebp
f01013c3:	c3                   	ret    

f01013c4 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01013c4:	55                   	push   %ebp
f01013c5:	89 e5                	mov    %esp,%ebp
f01013c7:	57                   	push   %edi
f01013c8:	56                   	push   %esi
f01013c9:	53                   	push   %ebx
f01013ca:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01013cd:	b8 15 00 00 00       	mov    $0x15,%eax
f01013d2:	e8 e0 f7 ff ff       	call   f0100bb7 <nvram_read>
f01013d7:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01013d9:	b8 17 00 00 00       	mov    $0x17,%eax
f01013de:	e8 d4 f7 ff ff       	call   f0100bb7 <nvram_read>
f01013e3:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013e5:	b8 34 00 00 00       	mov    $0x34,%eax
f01013ea:	e8 c8 f7 ff ff       	call   f0100bb7 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01013ef:	c1 e0 06             	shl    $0x6,%eax
f01013f2:	74 08                	je     f01013fc <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f01013f4:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f01013fa:	eb 0e                	jmp    f010140a <mem_init+0x46>
	else if (extmem)
f01013fc:	85 f6                	test   %esi,%esi
f01013fe:	74 08                	je     f0101408 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0101400:	81 c6 00 04 00 00    	add    $0x400,%esi
f0101406:	eb 02                	jmp    f010140a <mem_init+0x46>
	else
		totalmem = basemem;
f0101408:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f010140a:	89 f0                	mov    %esi,%eax
f010140c:	c1 e8 02             	shr    $0x2,%eax
f010140f:	a3 98 1e 2e f0       	mov    %eax,0xf02e1e98
	npages_basemem = basemem / (PGSIZE / 1024);
f0101414:	89 d8                	mov    %ebx,%eax
f0101416:	c1 e8 02             	shr    $0x2,%eax
f0101419:	a3 38 12 2e f0       	mov    %eax,0xf02e1238

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010141e:	89 f0                	mov    %esi,%eax
f0101420:	29 d8                	sub    %ebx,%eax
f0101422:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101426:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010142a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010142e:	c7 04 24 ac 7d 10 f0 	movl   $0xf0107dac,(%esp)
f0101435:	e8 50 2a 00 00       	call   f0103e8a <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010143a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010143f:	e8 f1 f6 ff ff       	call   f0100b35 <boot_alloc>
f0101444:	a3 9c 1e 2e f0       	mov    %eax,0xf02e1e9c
	memset(kern_pgdir, 0, PGSIZE);
f0101449:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101450:	00 
f0101451:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101458:	00 
f0101459:	89 04 24             	mov    %eax,(%esp)
f010145c:	e8 5d 49 00 00       	call   f0105dbe <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101461:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101466:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010146b:	77 20                	ja     f010148d <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010146d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101471:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0101478:	f0 
f0101479:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
f0101480:	00 
f0101481:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101488:	e8 b3 eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010148d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101493:	83 ca 05             	or     $0x5,%edx
f0101496:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	cprintf("struct PageInfo size: %u\n", sizeof(struct PageInfo));
f010149c:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
f01014a3:	00 
f01014a4:	c7 04 24 d0 86 10 f0 	movl   $0xf01086d0,(%esp)
f01014ab:	e8 da 29 00 00       	call   f0103e8a <cprintf>
	pages = (struct PageInfo*) boot_alloc(sizeof(struct PageInfo) * npages);
f01014b0:	a1 98 1e 2e f0       	mov    0xf02e1e98,%eax
f01014b5:	c1 e0 03             	shl    $0x3,%eax
f01014b8:	e8 78 f6 ff ff       	call   f0100b35 <boot_alloc>
f01014bd:	a3 a0 1e 2e f0       	mov    %eax,0xf02e1ea0
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f01014c2:	8b 15 98 1e 2e f0    	mov    0xf02e1e98,%edx
f01014c8:	c1 e2 03             	shl    $0x3,%edx
f01014cb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01014cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014d6:	00 
f01014d7:	89 04 24             	mov    %eax,(%esp)
f01014da:	e8 df 48 00 00       	call   f0105dbe <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(sizeof(struct Env) * NENV);
f01014df:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01014e4:	e8 4c f6 ff ff       	call   f0100b35 <boot_alloc>
f01014e9:	a3 48 12 2e f0       	mov    %eax,0xf02e1248
	memset(envs, 0, sizeof(struct Env) * NENV);
f01014ee:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f01014f5:	00 
f01014f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014fd:	00 
f01014fe:	89 04 24             	mov    %eax,(%esp)
f0101501:	e8 b8 48 00 00       	call   f0105dbe <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101506:	e8 34 fa ff ff       	call   f0100f3f <page_init>

	check_page_free_list(1);
f010150b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101510:	e8 cb f6 ff ff       	call   f0100be0 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101515:	83 3d a0 1e 2e f0 00 	cmpl   $0x0,0xf02e1ea0
f010151c:	75 1c                	jne    f010153a <mem_init+0x176>
		panic("'pages' is a null pointer!");
f010151e:	c7 44 24 08 ea 86 10 	movl   $0xf01086ea,0x8(%esp)
f0101525:	f0 
f0101526:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f010152d:	00 
f010152e:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101535:	e8 06 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010153a:	a1 40 12 2e f0       	mov    0xf02e1240,%eax
f010153f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101544:	eb 03                	jmp    f0101549 <mem_init+0x185>
		++nfree;
f0101546:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101547:	8b 00                	mov    (%eax),%eax
f0101549:	85 c0                	test   %eax,%eax
f010154b:	75 f9                	jne    f0101546 <mem_init+0x182>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010154d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101554:	e8 92 fa ff ff       	call   f0100feb <page_alloc>
f0101559:	89 c6                	mov    %eax,%esi
f010155b:	85 c0                	test   %eax,%eax
f010155d:	75 24                	jne    f0101583 <mem_init+0x1bf>
f010155f:	c7 44 24 0c 05 87 10 	movl   $0xf0108705,0xc(%esp)
f0101566:	f0 
f0101567:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010156e:	f0 
f010156f:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0101576:	00 
f0101577:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010157e:	e8 bd ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101583:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010158a:	e8 5c fa ff ff       	call   f0100feb <page_alloc>
f010158f:	89 c7                	mov    %eax,%edi
f0101591:	85 c0                	test   %eax,%eax
f0101593:	75 24                	jne    f01015b9 <mem_init+0x1f5>
f0101595:	c7 44 24 0c 1b 87 10 	movl   $0xf010871b,0xc(%esp)
f010159c:	f0 
f010159d:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01015a4:	f0 
f01015a5:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f01015ac:	00 
f01015ad:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01015b4:	e8 87 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01015b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015c0:	e8 26 fa ff ff       	call   f0100feb <page_alloc>
f01015c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015c8:	85 c0                	test   %eax,%eax
f01015ca:	75 24                	jne    f01015f0 <mem_init+0x22c>
f01015cc:	c7 44 24 0c 31 87 10 	movl   $0xf0108731,0xc(%esp)
f01015d3:	f0 
f01015d4:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01015db:	f0 
f01015dc:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f01015e3:	00 
f01015e4:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01015eb:	e8 50 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015f0:	39 fe                	cmp    %edi,%esi
f01015f2:	75 24                	jne    f0101618 <mem_init+0x254>
f01015f4:	c7 44 24 0c 47 87 10 	movl   $0xf0108747,0xc(%esp)
f01015fb:	f0 
f01015fc:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101603:	f0 
f0101604:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f010160b:	00 
f010160c:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101613:	e8 28 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101618:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010161b:	74 05                	je     f0101622 <mem_init+0x25e>
f010161d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101620:	75 24                	jne    f0101646 <mem_init+0x282>
f0101622:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f0101629:	f0 
f010162a:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101631:	f0 
f0101632:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101639:	00 
f010163a:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101641:	e8 fa e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101646:	8b 15 a0 1e 2e f0    	mov    0xf02e1ea0,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010164c:	a1 98 1e 2e f0       	mov    0xf02e1e98,%eax
f0101651:	c1 e0 0c             	shl    $0xc,%eax
f0101654:	89 f1                	mov    %esi,%ecx
f0101656:	29 d1                	sub    %edx,%ecx
f0101658:	c1 f9 03             	sar    $0x3,%ecx
f010165b:	c1 e1 0c             	shl    $0xc,%ecx
f010165e:	39 c1                	cmp    %eax,%ecx
f0101660:	72 24                	jb     f0101686 <mem_init+0x2c2>
f0101662:	c7 44 24 0c 59 87 10 	movl   $0xf0108759,0xc(%esp)
f0101669:	f0 
f010166a:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101671:	f0 
f0101672:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101679:	00 
f010167a:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101681:	e8 ba e9 ff ff       	call   f0100040 <_panic>
f0101686:	89 f9                	mov    %edi,%ecx
f0101688:	29 d1                	sub    %edx,%ecx
f010168a:	c1 f9 03             	sar    $0x3,%ecx
f010168d:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101690:	39 c8                	cmp    %ecx,%eax
f0101692:	77 24                	ja     f01016b8 <mem_init+0x2f4>
f0101694:	c7 44 24 0c 76 87 10 	movl   $0xf0108776,0xc(%esp)
f010169b:	f0 
f010169c:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01016a3:	f0 
f01016a4:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f01016ab:	00 
f01016ac:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01016b3:	e8 88 e9 ff ff       	call   f0100040 <_panic>
f01016b8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01016bb:	29 d1                	sub    %edx,%ecx
f01016bd:	89 ca                	mov    %ecx,%edx
f01016bf:	c1 fa 03             	sar    $0x3,%edx
f01016c2:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01016c5:	39 d0                	cmp    %edx,%eax
f01016c7:	77 24                	ja     f01016ed <mem_init+0x329>
f01016c9:	c7 44 24 0c 93 87 10 	movl   $0xf0108793,0xc(%esp)
f01016d0:	f0 
f01016d1:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01016d8:	f0 
f01016d9:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f01016e0:	00 
f01016e1:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01016e8:	e8 53 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016ed:	a1 40 12 2e f0       	mov    0xf02e1240,%eax
f01016f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016f5:	c7 05 40 12 2e f0 00 	movl   $0x0,0xf02e1240
f01016fc:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101706:	e8 e0 f8 ff ff       	call   f0100feb <page_alloc>
f010170b:	85 c0                	test   %eax,%eax
f010170d:	74 24                	je     f0101733 <mem_init+0x36f>
f010170f:	c7 44 24 0c b0 87 10 	movl   $0xf01087b0,0xc(%esp)
f0101716:	f0 
f0101717:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010171e:	f0 
f010171f:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0101726:	00 
f0101727:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010172e:	e8 0d e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101733:	89 34 24             	mov    %esi,(%esp)
f0101736:	e8 34 f9 ff ff       	call   f010106f <page_free>
	page_free(pp1);
f010173b:	89 3c 24             	mov    %edi,(%esp)
f010173e:	e8 2c f9 ff ff       	call   f010106f <page_free>
	page_free(pp2);
f0101743:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101746:	89 04 24             	mov    %eax,(%esp)
f0101749:	e8 21 f9 ff ff       	call   f010106f <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010174e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101755:	e8 91 f8 ff ff       	call   f0100feb <page_alloc>
f010175a:	89 c6                	mov    %eax,%esi
f010175c:	85 c0                	test   %eax,%eax
f010175e:	75 24                	jne    f0101784 <mem_init+0x3c0>
f0101760:	c7 44 24 0c 05 87 10 	movl   $0xf0108705,0xc(%esp)
f0101767:	f0 
f0101768:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010176f:	f0 
f0101770:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101777:	00 
f0101778:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010177f:	e8 bc e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101784:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010178b:	e8 5b f8 ff ff       	call   f0100feb <page_alloc>
f0101790:	89 c7                	mov    %eax,%edi
f0101792:	85 c0                	test   %eax,%eax
f0101794:	75 24                	jne    f01017ba <mem_init+0x3f6>
f0101796:	c7 44 24 0c 1b 87 10 	movl   $0xf010871b,0xc(%esp)
f010179d:	f0 
f010179e:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01017a5:	f0 
f01017a6:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f01017ad:	00 
f01017ae:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01017b5:	e8 86 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017c1:	e8 25 f8 ff ff       	call   f0100feb <page_alloc>
f01017c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017c9:	85 c0                	test   %eax,%eax
f01017cb:	75 24                	jne    f01017f1 <mem_init+0x42d>
f01017cd:	c7 44 24 0c 31 87 10 	movl   $0xf0108731,0xc(%esp)
f01017d4:	f0 
f01017d5:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01017dc:	f0 
f01017dd:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f01017e4:	00 
f01017e5:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01017ec:	e8 4f e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017f1:	39 fe                	cmp    %edi,%esi
f01017f3:	75 24                	jne    f0101819 <mem_init+0x455>
f01017f5:	c7 44 24 0c 47 87 10 	movl   $0xf0108747,0xc(%esp)
f01017fc:	f0 
f01017fd:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101804:	f0 
f0101805:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f010180c:	00 
f010180d:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101814:	e8 27 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101819:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010181c:	74 05                	je     f0101823 <mem_init+0x45f>
f010181e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101821:	75 24                	jne    f0101847 <mem_init+0x483>
f0101823:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f010182a:	f0 
f010182b:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101832:	f0 
f0101833:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f010183a:	00 
f010183b:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101842:	e8 f9 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101847:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010184e:	e8 98 f7 ff ff       	call   f0100feb <page_alloc>
f0101853:	85 c0                	test   %eax,%eax
f0101855:	74 24                	je     f010187b <mem_init+0x4b7>
f0101857:	c7 44 24 0c b0 87 10 	movl   $0xf01087b0,0xc(%esp)
f010185e:	f0 
f010185f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101866:	f0 
f0101867:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f010186e:	00 
f010186f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101876:	e8 c5 e7 ff ff       	call   f0100040 <_panic>
f010187b:	89 f0                	mov    %esi,%eax
f010187d:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0101883:	c1 f8 03             	sar    $0x3,%eax
f0101886:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101889:	89 c2                	mov    %eax,%edx
f010188b:	c1 ea 0c             	shr    $0xc,%edx
f010188e:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f0101894:	72 20                	jb     f01018b6 <mem_init+0x4f2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101896:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010189a:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f01018a1:	f0 
f01018a2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01018a9:	00 
f01018aa:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f01018b1:	e8 8a e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018b6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018bd:	00 
f01018be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01018c5:	00 
	return (void *)(pa + KERNBASE);
f01018c6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018cb:	89 04 24             	mov    %eax,(%esp)
f01018ce:	e8 eb 44 00 00       	call   f0105dbe <memset>
	page_free(pp0);
f01018d3:	89 34 24             	mov    %esi,(%esp)
f01018d6:	e8 94 f7 ff ff       	call   f010106f <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018e2:	e8 04 f7 ff ff       	call   f0100feb <page_alloc>
f01018e7:	85 c0                	test   %eax,%eax
f01018e9:	75 24                	jne    f010190f <mem_init+0x54b>
f01018eb:	c7 44 24 0c bf 87 10 	movl   $0xf01087bf,0xc(%esp)
f01018f2:	f0 
f01018f3:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01018fa:	f0 
f01018fb:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101902:	00 
f0101903:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010190a:	e8 31 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010190f:	39 c6                	cmp    %eax,%esi
f0101911:	74 24                	je     f0101937 <mem_init+0x573>
f0101913:	c7 44 24 0c dd 87 10 	movl   $0xf01087dd,0xc(%esp)
f010191a:	f0 
f010191b:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101922:	f0 
f0101923:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f010192a:	00 
f010192b:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101932:	e8 09 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101937:	89 f2                	mov    %esi,%edx
f0101939:	2b 15 a0 1e 2e f0    	sub    0xf02e1ea0,%edx
f010193f:	c1 fa 03             	sar    $0x3,%edx
f0101942:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101945:	89 d0                	mov    %edx,%eax
f0101947:	c1 e8 0c             	shr    $0xc,%eax
f010194a:	3b 05 98 1e 2e f0    	cmp    0xf02e1e98,%eax
f0101950:	72 20                	jb     f0101972 <mem_init+0x5ae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101952:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101956:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f010195d:	f0 
f010195e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101965:	00 
f0101966:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f010196d:	e8 ce e6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101972:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101978:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010197e:	80 38 00             	cmpb   $0x0,(%eax)
f0101981:	74 24                	je     f01019a7 <mem_init+0x5e3>
f0101983:	c7 44 24 0c ed 87 10 	movl   $0xf01087ed,0xc(%esp)
f010198a:	f0 
f010198b:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101992:	f0 
f0101993:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f010199a:	00 
f010199b:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01019a2:	e8 99 e6 ff ff       	call   f0100040 <_panic>
f01019a7:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01019a8:	39 d0                	cmp    %edx,%eax
f01019aa:	75 d2                	jne    f010197e <mem_init+0x5ba>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01019ac:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01019af:	89 15 40 12 2e f0    	mov    %edx,0xf02e1240

	// free the pages we took
	page_free(pp0);
f01019b5:	89 34 24             	mov    %esi,(%esp)
f01019b8:	e8 b2 f6 ff ff       	call   f010106f <page_free>
	page_free(pp1);
f01019bd:	89 3c 24             	mov    %edi,(%esp)
f01019c0:	e8 aa f6 ff ff       	call   f010106f <page_free>
	page_free(pp2);
f01019c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019c8:	89 04 24             	mov    %eax,(%esp)
f01019cb:	e8 9f f6 ff ff       	call   f010106f <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019d0:	a1 40 12 2e f0       	mov    0xf02e1240,%eax
f01019d5:	eb 03                	jmp    f01019da <mem_init+0x616>
		--nfree;
f01019d7:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019d8:	8b 00                	mov    (%eax),%eax
f01019da:	85 c0                	test   %eax,%eax
f01019dc:	75 f9                	jne    f01019d7 <mem_init+0x613>
		--nfree;
	assert(nfree == 0);
f01019de:	85 db                	test   %ebx,%ebx
f01019e0:	74 24                	je     f0101a06 <mem_init+0x642>
f01019e2:	c7 44 24 0c f7 87 10 	movl   $0xf01087f7,0xc(%esp)
f01019e9:	f0 
f01019ea:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01019f1:	f0 
f01019f2:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f01019f9:	00 
f01019fa:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101a01:	e8 3a e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a06:	c7 04 24 08 7e 10 f0 	movl   $0xf0107e08,(%esp)
f0101a0d:	e8 78 24 00 00       	call   f0103e8a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a19:	e8 cd f5 ff ff       	call   f0100feb <page_alloc>
f0101a1e:	89 c7                	mov    %eax,%edi
f0101a20:	85 c0                	test   %eax,%eax
f0101a22:	75 24                	jne    f0101a48 <mem_init+0x684>
f0101a24:	c7 44 24 0c 05 87 10 	movl   $0xf0108705,0xc(%esp)
f0101a2b:	f0 
f0101a2c:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101a33:	f0 
f0101a34:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101a3b:	00 
f0101a3c:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101a43:	e8 f8 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a4f:	e8 97 f5 ff ff       	call   f0100feb <page_alloc>
f0101a54:	89 c6                	mov    %eax,%esi
f0101a56:	85 c0                	test   %eax,%eax
f0101a58:	75 24                	jne    f0101a7e <mem_init+0x6ba>
f0101a5a:	c7 44 24 0c 1b 87 10 	movl   $0xf010871b,0xc(%esp)
f0101a61:	f0 
f0101a62:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101a69:	f0 
f0101a6a:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101a71:	00 
f0101a72:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101a79:	e8 c2 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a85:	e8 61 f5 ff ff       	call   f0100feb <page_alloc>
f0101a8a:	89 c3                	mov    %eax,%ebx
f0101a8c:	85 c0                	test   %eax,%eax
f0101a8e:	75 24                	jne    f0101ab4 <mem_init+0x6f0>
f0101a90:	c7 44 24 0c 31 87 10 	movl   $0xf0108731,0xc(%esp)
f0101a97:	f0 
f0101a98:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101a9f:	f0 
f0101aa0:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101aa7:	00 
f0101aa8:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101aaf:	e8 8c e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ab4:	39 f7                	cmp    %esi,%edi
f0101ab6:	75 24                	jne    f0101adc <mem_init+0x718>
f0101ab8:	c7 44 24 0c 47 87 10 	movl   $0xf0108747,0xc(%esp)
f0101abf:	f0 
f0101ac0:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101ac7:	f0 
f0101ac8:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101acf:	00 
f0101ad0:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101ad7:	e8 64 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101adc:	39 c6                	cmp    %eax,%esi
f0101ade:	74 04                	je     f0101ae4 <mem_init+0x720>
f0101ae0:	39 c7                	cmp    %eax,%edi
f0101ae2:	75 24                	jne    f0101b08 <mem_init+0x744>
f0101ae4:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f0101aeb:	f0 
f0101aec:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101af3:	f0 
f0101af4:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101afb:	00 
f0101afc:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101b03:	e8 38 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b08:	8b 15 40 12 2e f0    	mov    0xf02e1240,%edx
f0101b0e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101b11:	c7 05 40 12 2e f0 00 	movl   $0x0,0xf02e1240
f0101b18:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b22:	e8 c4 f4 ff ff       	call   f0100feb <page_alloc>
f0101b27:	85 c0                	test   %eax,%eax
f0101b29:	74 24                	je     f0101b4f <mem_init+0x78b>
f0101b2b:	c7 44 24 0c b0 87 10 	movl   $0xf01087b0,0xc(%esp)
f0101b32:	f0 
f0101b33:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101b3a:	f0 
f0101b3b:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0101b42:	00 
f0101b43:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101b4a:	e8 f1 e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b52:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b5d:	00 
f0101b5e:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0101b63:	89 04 24             	mov    %eax,(%esp)
f0101b66:	e8 57 f6 ff ff       	call   f01011c2 <page_lookup>
f0101b6b:	85 c0                	test   %eax,%eax
f0101b6d:	74 24                	je     f0101b93 <mem_init+0x7cf>
f0101b6f:	c7 44 24 0c 28 7e 10 	movl   $0xf0107e28,0xc(%esp)
f0101b76:	f0 
f0101b77:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101b7e:	f0 
f0101b7f:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101b86:	00 
f0101b87:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101b8e:	e8 ad e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b93:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b9a:	00 
f0101b9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ba2:	00 
f0101ba3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ba7:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0101bac:	89 04 24             	mov    %eax,(%esp)
f0101baf:	e8 22 f7 ff ff       	call   f01012d6 <page_insert>
f0101bb4:	85 c0                	test   %eax,%eax
f0101bb6:	78 24                	js     f0101bdc <mem_init+0x818>
f0101bb8:	c7 44 24 0c 60 7e 10 	movl   $0xf0107e60,0xc(%esp)
f0101bbf:	f0 
f0101bc0:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101bc7:	f0 
f0101bc8:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101bcf:	00 
f0101bd0:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101bd7:	e8 64 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101bdc:	89 3c 24             	mov    %edi,(%esp)
f0101bdf:	e8 8b f4 ff ff       	call   f010106f <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101be4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101beb:	00 
f0101bec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101bf3:	00 
f0101bf4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101bf8:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0101bfd:	89 04 24             	mov    %eax,(%esp)
f0101c00:	e8 d1 f6 ff ff       	call   f01012d6 <page_insert>
f0101c05:	85 c0                	test   %eax,%eax
f0101c07:	74 24                	je     f0101c2d <mem_init+0x869>
f0101c09:	c7 44 24 0c 90 7e 10 	movl   $0xf0107e90,0xc(%esp)
f0101c10:	f0 
f0101c11:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101c18:	f0 
f0101c19:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101c20:	00 
f0101c21:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101c28:	e8 13 e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c2d:	8b 0d 9c 1e 2e f0    	mov    0xf02e1e9c,%ecx
f0101c33:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c36:	a1 a0 1e 2e f0       	mov    0xf02e1ea0,%eax
f0101c3b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c3e:	8b 11                	mov    (%ecx),%edx
f0101c40:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c46:	89 f8                	mov    %edi,%eax
f0101c48:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101c4b:	c1 f8 03             	sar    $0x3,%eax
f0101c4e:	c1 e0 0c             	shl    $0xc,%eax
f0101c51:	39 c2                	cmp    %eax,%edx
f0101c53:	74 24                	je     f0101c79 <mem_init+0x8b5>
f0101c55:	c7 44 24 0c c0 7e 10 	movl   $0xf0107ec0,0xc(%esp)
f0101c5c:	f0 
f0101c5d:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101c64:	f0 
f0101c65:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0101c6c:	00 
f0101c6d:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101c74:	e8 c7 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c79:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c81:	e8 42 ee ff ff       	call   f0100ac8 <check_va2pa>
f0101c86:	89 f2                	mov    %esi,%edx
f0101c88:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101c8b:	c1 fa 03             	sar    $0x3,%edx
f0101c8e:	c1 e2 0c             	shl    $0xc,%edx
f0101c91:	39 d0                	cmp    %edx,%eax
f0101c93:	74 24                	je     f0101cb9 <mem_init+0x8f5>
f0101c95:	c7 44 24 0c e8 7e 10 	movl   $0xf0107ee8,0xc(%esp)
f0101c9c:	f0 
f0101c9d:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101ca4:	f0 
f0101ca5:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0101cac:	00 
f0101cad:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101cb4:	e8 87 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101cb9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cbe:	74 24                	je     f0101ce4 <mem_init+0x920>
f0101cc0:	c7 44 24 0c 02 88 10 	movl   $0xf0108802,0xc(%esp)
f0101cc7:	f0 
f0101cc8:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101ccf:	f0 
f0101cd0:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101cd7:	00 
f0101cd8:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101cdf:	e8 5c e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ce4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ce9:	74 24                	je     f0101d0f <mem_init+0x94b>
f0101ceb:	c7 44 24 0c 13 88 10 	movl   $0xf0108813,0xc(%esp)
f0101cf2:	f0 
f0101cf3:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101cfa:	f0 
f0101cfb:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0101d02:	00 
f0101d03:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101d0a:	e8 31 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d0f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d16:	00 
f0101d17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d1e:	00 
f0101d1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d23:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101d26:	89 14 24             	mov    %edx,(%esp)
f0101d29:	e8 a8 f5 ff ff       	call   f01012d6 <page_insert>
f0101d2e:	85 c0                	test   %eax,%eax
f0101d30:	74 24                	je     f0101d56 <mem_init+0x992>
f0101d32:	c7 44 24 0c 18 7f 10 	movl   $0xf0107f18,0xc(%esp)
f0101d39:	f0 
f0101d3a:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101d41:	f0 
f0101d42:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0101d49:	00 
f0101d4a:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101d51:	e8 ea e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d56:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d5b:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0101d60:	e8 63 ed ff ff       	call   f0100ac8 <check_va2pa>
f0101d65:	89 da                	mov    %ebx,%edx
f0101d67:	2b 15 a0 1e 2e f0    	sub    0xf02e1ea0,%edx
f0101d6d:	c1 fa 03             	sar    $0x3,%edx
f0101d70:	c1 e2 0c             	shl    $0xc,%edx
f0101d73:	39 d0                	cmp    %edx,%eax
f0101d75:	74 24                	je     f0101d9b <mem_init+0x9d7>
f0101d77:	c7 44 24 0c 54 7f 10 	movl   $0xf0107f54,0xc(%esp)
f0101d7e:	f0 
f0101d7f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101d86:	f0 
f0101d87:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0101d8e:	00 
f0101d8f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101d96:	e8 a5 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d9b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101da0:	74 24                	je     f0101dc6 <mem_init+0xa02>
f0101da2:	c7 44 24 0c 24 88 10 	movl   $0xf0108824,0xc(%esp)
f0101da9:	f0 
f0101daa:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101db1:	f0 
f0101db2:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0101db9:	00 
f0101dba:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101dc1:	e8 7a e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101dc6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101dcd:	e8 19 f2 ff ff       	call   f0100feb <page_alloc>
f0101dd2:	85 c0                	test   %eax,%eax
f0101dd4:	74 24                	je     f0101dfa <mem_init+0xa36>
f0101dd6:	c7 44 24 0c b0 87 10 	movl   $0xf01087b0,0xc(%esp)
f0101ddd:	f0 
f0101dde:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101de5:	f0 
f0101de6:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101ded:	00 
f0101dee:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101df5:	e8 46 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dfa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e01:	00 
f0101e02:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e09:	00 
f0101e0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e0e:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0101e13:	89 04 24             	mov    %eax,(%esp)
f0101e16:	e8 bb f4 ff ff       	call   f01012d6 <page_insert>
f0101e1b:	85 c0                	test   %eax,%eax
f0101e1d:	74 24                	je     f0101e43 <mem_init+0xa7f>
f0101e1f:	c7 44 24 0c 18 7f 10 	movl   $0xf0107f18,0xc(%esp)
f0101e26:	f0 
f0101e27:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101e2e:	f0 
f0101e2f:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0101e36:	00 
f0101e37:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101e3e:	e8 fd e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e43:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e48:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0101e4d:	e8 76 ec ff ff       	call   f0100ac8 <check_va2pa>
f0101e52:	89 da                	mov    %ebx,%edx
f0101e54:	2b 15 a0 1e 2e f0    	sub    0xf02e1ea0,%edx
f0101e5a:	c1 fa 03             	sar    $0x3,%edx
f0101e5d:	c1 e2 0c             	shl    $0xc,%edx
f0101e60:	39 d0                	cmp    %edx,%eax
f0101e62:	74 24                	je     f0101e88 <mem_init+0xac4>
f0101e64:	c7 44 24 0c 54 7f 10 	movl   $0xf0107f54,0xc(%esp)
f0101e6b:	f0 
f0101e6c:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101e73:	f0 
f0101e74:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0101e7b:	00 
f0101e7c:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101e83:	e8 b8 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e88:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e8d:	74 24                	je     f0101eb3 <mem_init+0xaef>
f0101e8f:	c7 44 24 0c 24 88 10 	movl   $0xf0108824,0xc(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101e9e:	f0 
f0101e9f:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101ea6:	00 
f0101ea7:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101eae:	e8 8d e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101eb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101eba:	e8 2c f1 ff ff       	call   f0100feb <page_alloc>
f0101ebf:	85 c0                	test   %eax,%eax
f0101ec1:	74 24                	je     f0101ee7 <mem_init+0xb23>
f0101ec3:	c7 44 24 0c b0 87 10 	movl   $0xf01087b0,0xc(%esp)
f0101eca:	f0 
f0101ecb:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101ed2:	f0 
f0101ed3:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0101eda:	00 
f0101edb:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101ee2:	e8 59 e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ee7:	8b 15 9c 1e 2e f0    	mov    0xf02e1e9c,%edx
f0101eed:	8b 02                	mov    (%edx),%eax
f0101eef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ef4:	89 c1                	mov    %eax,%ecx
f0101ef6:	c1 e9 0c             	shr    $0xc,%ecx
f0101ef9:	3b 0d 98 1e 2e f0    	cmp    0xf02e1e98,%ecx
f0101eff:	72 20                	jb     f0101f21 <mem_init+0xb5d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f01:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f05:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0101f0c:	f0 
f0101f0d:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0101f14:	00 
f0101f15:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101f1c:	e8 1f e1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101f21:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f29:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f30:	00 
f0101f31:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f38:	00 
f0101f39:	89 14 24             	mov    %edx,(%esp)
f0101f3c:	e8 8e f1 ff ff       	call   f01010cf <pgdir_walk>
f0101f41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f44:	83 c2 04             	add    $0x4,%edx
f0101f47:	39 d0                	cmp    %edx,%eax
f0101f49:	74 24                	je     f0101f6f <mem_init+0xbab>
f0101f4b:	c7 44 24 0c 84 7f 10 	movl   $0xf0107f84,0xc(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101f5a:	f0 
f0101f5b:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101f62:	00 
f0101f63:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101f6a:	e8 d1 e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f6f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101f76:	00 
f0101f77:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f7e:	00 
f0101f7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f83:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0101f88:	89 04 24             	mov    %eax,(%esp)
f0101f8b:	e8 46 f3 ff ff       	call   f01012d6 <page_insert>
f0101f90:	85 c0                	test   %eax,%eax
f0101f92:	74 24                	je     f0101fb8 <mem_init+0xbf4>
f0101f94:	c7 44 24 0c c4 7f 10 	movl   $0xf0107fc4,0xc(%esp)
f0101f9b:	f0 
f0101f9c:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101fa3:	f0 
f0101fa4:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101fab:	00 
f0101fac:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101fb3:	e8 88 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fb8:	8b 0d 9c 1e 2e f0    	mov    0xf02e1e9c,%ecx
f0101fbe:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101fc1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fc6:	89 c8                	mov    %ecx,%eax
f0101fc8:	e8 fb ea ff ff       	call   f0100ac8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fcd:	89 da                	mov    %ebx,%edx
f0101fcf:	2b 15 a0 1e 2e f0    	sub    0xf02e1ea0,%edx
f0101fd5:	c1 fa 03             	sar    $0x3,%edx
f0101fd8:	c1 e2 0c             	shl    $0xc,%edx
f0101fdb:	39 d0                	cmp    %edx,%eax
f0101fdd:	74 24                	je     f0102003 <mem_init+0xc3f>
f0101fdf:	c7 44 24 0c 54 7f 10 	movl   $0xf0107f54,0xc(%esp)
f0101fe6:	f0 
f0101fe7:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0101fee:	f0 
f0101fef:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0101ff6:	00 
f0101ff7:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0101ffe:	e8 3d e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102003:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102008:	74 24                	je     f010202e <mem_init+0xc6a>
f010200a:	c7 44 24 0c 24 88 10 	movl   $0xf0108824,0xc(%esp)
f0102011:	f0 
f0102012:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102019:	f0 
f010201a:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102021:	00 
f0102022:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102029:	e8 12 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010202e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102035:	00 
f0102036:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010203d:	00 
f010203e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102041:	89 04 24             	mov    %eax,(%esp)
f0102044:	e8 86 f0 ff ff       	call   f01010cf <pgdir_walk>
f0102049:	f6 00 04             	testb  $0x4,(%eax)
f010204c:	75 24                	jne    f0102072 <mem_init+0xcae>
f010204e:	c7 44 24 0c 04 80 10 	movl   $0xf0108004,0xc(%esp)
f0102055:	f0 
f0102056:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010205d:	f0 
f010205e:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102065:	00 
f0102066:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010206d:	e8 ce df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102072:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102077:	f6 00 04             	testb  $0x4,(%eax)
f010207a:	75 24                	jne    f01020a0 <mem_init+0xcdc>
f010207c:	c7 44 24 0c 35 88 10 	movl   $0xf0108835,0xc(%esp)
f0102083:	f0 
f0102084:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010208b:	f0 
f010208c:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102093:	00 
f0102094:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010209b:	e8 a0 df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020a0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020a7:	00 
f01020a8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020af:	00 
f01020b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020b4:	89 04 24             	mov    %eax,(%esp)
f01020b7:	e8 1a f2 ff ff       	call   f01012d6 <page_insert>
f01020bc:	85 c0                	test   %eax,%eax
f01020be:	74 24                	je     f01020e4 <mem_init+0xd20>
f01020c0:	c7 44 24 0c 18 7f 10 	movl   $0xf0107f18,0xc(%esp)
f01020c7:	f0 
f01020c8:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01020cf:	f0 
f01020d0:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01020d7:	00 
f01020d8:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01020df:	e8 5c df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020eb:	00 
f01020ec:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020f3:	00 
f01020f4:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f01020f9:	89 04 24             	mov    %eax,(%esp)
f01020fc:	e8 ce ef ff ff       	call   f01010cf <pgdir_walk>
f0102101:	f6 00 02             	testb  $0x2,(%eax)
f0102104:	75 24                	jne    f010212a <mem_init+0xd66>
f0102106:	c7 44 24 0c 38 80 10 	movl   $0xf0108038,0xc(%esp)
f010210d:	f0 
f010210e:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102115:	f0 
f0102116:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f010211d:	00 
f010211e:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102125:	e8 16 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010212a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102131:	00 
f0102132:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102139:	00 
f010213a:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f010213f:	89 04 24             	mov    %eax,(%esp)
f0102142:	e8 88 ef ff ff       	call   f01010cf <pgdir_walk>
f0102147:	f6 00 04             	testb  $0x4,(%eax)
f010214a:	74 24                	je     f0102170 <mem_init+0xdac>
f010214c:	c7 44 24 0c 6c 80 10 	movl   $0xf010806c,0xc(%esp)
f0102153:	f0 
f0102154:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010215b:	f0 
f010215c:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102163:	00 
f0102164:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010216b:	e8 d0 de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102170:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102177:	00 
f0102178:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010217f:	00 
f0102180:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102184:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102189:	89 04 24             	mov    %eax,(%esp)
f010218c:	e8 45 f1 ff ff       	call   f01012d6 <page_insert>
f0102191:	85 c0                	test   %eax,%eax
f0102193:	78 24                	js     f01021b9 <mem_init+0xdf5>
f0102195:	c7 44 24 0c a4 80 10 	movl   $0xf01080a4,0xc(%esp)
f010219c:	f0 
f010219d:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01021a4:	f0 
f01021a5:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f01021ac:	00 
f01021ad:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01021b4:	e8 87 de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021b9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021c0:	00 
f01021c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021c8:	00 
f01021c9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021cd:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f01021d2:	89 04 24             	mov    %eax,(%esp)
f01021d5:	e8 fc f0 ff ff       	call   f01012d6 <page_insert>
f01021da:	85 c0                	test   %eax,%eax
f01021dc:	74 24                	je     f0102202 <mem_init+0xe3e>
f01021de:	c7 44 24 0c dc 80 10 	movl   $0xf01080dc,0xc(%esp)
f01021e5:	f0 
f01021e6:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01021ed:	f0 
f01021ee:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f01021f5:	00 
f01021f6:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01021fd:	e8 3e de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102202:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102209:	00 
f010220a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102211:	00 
f0102212:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102217:	89 04 24             	mov    %eax,(%esp)
f010221a:	e8 b0 ee ff ff       	call   f01010cf <pgdir_walk>
f010221f:	f6 00 04             	testb  $0x4,(%eax)
f0102222:	74 24                	je     f0102248 <mem_init+0xe84>
f0102224:	c7 44 24 0c 6c 80 10 	movl   $0xf010806c,0xc(%esp)
f010222b:	f0 
f010222c:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102233:	f0 
f0102234:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f010223b:	00 
f010223c:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102243:	e8 f8 dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102248:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f010224d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102250:	ba 00 00 00 00       	mov    $0x0,%edx
f0102255:	e8 6e e8 ff ff       	call   f0100ac8 <check_va2pa>
f010225a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010225d:	89 f0                	mov    %esi,%eax
f010225f:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0102265:	c1 f8 03             	sar    $0x3,%eax
f0102268:	c1 e0 0c             	shl    $0xc,%eax
f010226b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010226e:	74 24                	je     f0102294 <mem_init+0xed0>
f0102270:	c7 44 24 0c 18 81 10 	movl   $0xf0108118,0xc(%esp)
f0102277:	f0 
f0102278:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010227f:	f0 
f0102280:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102287:	00 
f0102288:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010228f:	e8 ac dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102294:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102299:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010229c:	e8 27 e8 ff ff       	call   f0100ac8 <check_va2pa>
f01022a1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01022a4:	74 24                	je     f01022ca <mem_init+0xf06>
f01022a6:	c7 44 24 0c 44 81 10 	movl   $0xf0108144,0xc(%esp)
f01022ad:	f0 
f01022ae:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01022b5:	f0 
f01022b6:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f01022bd:	00 
f01022be:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01022c5:	e8 76 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01022ca:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f01022cf:	74 24                	je     f01022f5 <mem_init+0xf31>
f01022d1:	c7 44 24 0c 4b 88 10 	movl   $0xf010884b,0xc(%esp)
f01022d8:	f0 
f01022d9:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01022e0:	f0 
f01022e1:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f01022e8:	00 
f01022e9:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01022f0:	e8 4b dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022f5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022fa:	74 24                	je     f0102320 <mem_init+0xf5c>
f01022fc:	c7 44 24 0c 5c 88 10 	movl   $0xf010885c,0xc(%esp)
f0102303:	f0 
f0102304:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010230b:	f0 
f010230c:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102313:	00 
f0102314:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010231b:	e8 20 dd ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102327:	e8 bf ec ff ff       	call   f0100feb <page_alloc>
f010232c:	85 c0                	test   %eax,%eax
f010232e:	74 04                	je     f0102334 <mem_init+0xf70>
f0102330:	39 c3                	cmp    %eax,%ebx
f0102332:	74 24                	je     f0102358 <mem_init+0xf94>
f0102334:	c7 44 24 0c 74 81 10 	movl   $0xf0108174,0xc(%esp)
f010233b:	f0 
f010233c:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102343:	f0 
f0102344:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f010234b:	00 
f010234c:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102353:	e8 e8 dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102358:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010235f:	00 
f0102360:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102365:	89 04 24             	mov    %eax,(%esp)
f0102368:	e8 17 ef ff ff       	call   f0101284 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010236d:	8b 15 9c 1e 2e f0    	mov    0xf02e1e9c,%edx
f0102373:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102376:	ba 00 00 00 00       	mov    $0x0,%edx
f010237b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010237e:	e8 45 e7 ff ff       	call   f0100ac8 <check_va2pa>
f0102383:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102386:	74 24                	je     f01023ac <mem_init+0xfe8>
f0102388:	c7 44 24 0c 98 81 10 	movl   $0xf0108198,0xc(%esp)
f010238f:	f0 
f0102390:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102397:	f0 
f0102398:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010239f:	00 
f01023a0:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01023a7:	e8 94 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023ac:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023b4:	e8 0f e7 ff ff       	call   f0100ac8 <check_va2pa>
f01023b9:	89 f2                	mov    %esi,%edx
f01023bb:	2b 15 a0 1e 2e f0    	sub    0xf02e1ea0,%edx
f01023c1:	c1 fa 03             	sar    $0x3,%edx
f01023c4:	c1 e2 0c             	shl    $0xc,%edx
f01023c7:	39 d0                	cmp    %edx,%eax
f01023c9:	74 24                	je     f01023ef <mem_init+0x102b>
f01023cb:	c7 44 24 0c 44 81 10 	movl   $0xf0108144,0xc(%esp)
f01023d2:	f0 
f01023d3:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01023da:	f0 
f01023db:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f01023e2:	00 
f01023e3:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01023ea:	e8 51 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01023ef:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023f4:	74 24                	je     f010241a <mem_init+0x1056>
f01023f6:	c7 44 24 0c 02 88 10 	movl   $0xf0108802,0xc(%esp)
f01023fd:	f0 
f01023fe:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102405:	f0 
f0102406:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f010240d:	00 
f010240e:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102415:	e8 26 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010241a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010241f:	74 24                	je     f0102445 <mem_init+0x1081>
f0102421:	c7 44 24 0c 5c 88 10 	movl   $0xf010885c,0xc(%esp)
f0102428:	f0 
f0102429:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102430:	f0 
f0102431:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f0102438:	00 
f0102439:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102440:	e8 fb db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102445:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010244c:	00 
f010244d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102454:	00 
f0102455:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102459:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010245c:	89 0c 24             	mov    %ecx,(%esp)
f010245f:	e8 72 ee ff ff       	call   f01012d6 <page_insert>
f0102464:	85 c0                	test   %eax,%eax
f0102466:	74 24                	je     f010248c <mem_init+0x10c8>
f0102468:	c7 44 24 0c bc 81 10 	movl   $0xf01081bc,0xc(%esp)
f010246f:	f0 
f0102470:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102477:	f0 
f0102478:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f010247f:	00 
f0102480:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102487:	e8 b4 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010248c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102491:	75 24                	jne    f01024b7 <mem_init+0x10f3>
f0102493:	c7 44 24 0c 6d 88 10 	movl   $0xf010886d,0xc(%esp)
f010249a:	f0 
f010249b:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01024a2:	f0 
f01024a3:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f01024aa:	00 
f01024ab:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01024b2:	e8 89 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01024b7:	83 3e 00             	cmpl   $0x0,(%esi)
f01024ba:	74 24                	je     f01024e0 <mem_init+0x111c>
f01024bc:	c7 44 24 0c 79 88 10 	movl   $0xf0108879,0xc(%esp)
f01024c3:	f0 
f01024c4:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01024cb:	f0 
f01024cc:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f01024d3:	00 
f01024d4:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01024db:	e8 60 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01024e0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024e7:	00 
f01024e8:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f01024ed:	89 04 24             	mov    %eax,(%esp)
f01024f0:	e8 8f ed ff ff       	call   f0101284 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024f5:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f01024fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0102502:	e8 c1 e5 ff ff       	call   f0100ac8 <check_va2pa>
f0102507:	83 f8 ff             	cmp    $0xffffffff,%eax
f010250a:	74 24                	je     f0102530 <mem_init+0x116c>
f010250c:	c7 44 24 0c 98 81 10 	movl   $0xf0108198,0xc(%esp)
f0102513:	f0 
f0102514:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010251b:	f0 
f010251c:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102523:	00 
f0102524:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010252b:	e8 10 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102530:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102535:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102538:	e8 8b e5 ff ff       	call   f0100ac8 <check_va2pa>
f010253d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102540:	74 24                	je     f0102566 <mem_init+0x11a2>
f0102542:	c7 44 24 0c f4 81 10 	movl   $0xf01081f4,0xc(%esp)
f0102549:	f0 
f010254a:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102551:	f0 
f0102552:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102559:	00 
f010255a:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102561:	e8 da da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102566:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010256b:	74 24                	je     f0102591 <mem_init+0x11cd>
f010256d:	c7 44 24 0c 8e 88 10 	movl   $0xf010888e,0xc(%esp)
f0102574:	f0 
f0102575:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010257c:	f0 
f010257d:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f0102584:	00 
f0102585:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010258c:	e8 af da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102591:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102596:	74 24                	je     f01025bc <mem_init+0x11f8>
f0102598:	c7 44 24 0c 5c 88 10 	movl   $0xf010885c,0xc(%esp)
f010259f:	f0 
f01025a0:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01025a7:	f0 
f01025a8:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f01025af:	00 
f01025b0:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01025b7:	e8 84 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01025bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025c3:	e8 23 ea ff ff       	call   f0100feb <page_alloc>
f01025c8:	85 c0                	test   %eax,%eax
f01025ca:	74 04                	je     f01025d0 <mem_init+0x120c>
f01025cc:	39 c6                	cmp    %eax,%esi
f01025ce:	74 24                	je     f01025f4 <mem_init+0x1230>
f01025d0:	c7 44 24 0c 1c 82 10 	movl   $0xf010821c,0xc(%esp)
f01025d7:	f0 
f01025d8:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01025df:	f0 
f01025e0:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f01025e7:	00 
f01025e8:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01025ef:	e8 4c da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01025f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025fb:	e8 eb e9 ff ff       	call   f0100feb <page_alloc>
f0102600:	85 c0                	test   %eax,%eax
f0102602:	74 24                	je     f0102628 <mem_init+0x1264>
f0102604:	c7 44 24 0c b0 87 10 	movl   $0xf01087b0,0xc(%esp)
f010260b:	f0 
f010260c:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102613:	f0 
f0102614:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f010261b:	00 
f010261c:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102623:	e8 18 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102628:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f010262d:	8b 08                	mov    (%eax),%ecx
f010262f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102635:	89 fa                	mov    %edi,%edx
f0102637:	2b 15 a0 1e 2e f0    	sub    0xf02e1ea0,%edx
f010263d:	c1 fa 03             	sar    $0x3,%edx
f0102640:	c1 e2 0c             	shl    $0xc,%edx
f0102643:	39 d1                	cmp    %edx,%ecx
f0102645:	74 24                	je     f010266b <mem_init+0x12a7>
f0102647:	c7 44 24 0c c0 7e 10 	movl   $0xf0107ec0,0xc(%esp)
f010264e:	f0 
f010264f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102656:	f0 
f0102657:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f010265e:	00 
f010265f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102666:	e8 d5 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010266b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102671:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102676:	74 24                	je     f010269c <mem_init+0x12d8>
f0102678:	c7 44 24 0c 13 88 10 	movl   $0xf0108813,0xc(%esp)
f010267f:	f0 
f0102680:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102687:	f0 
f0102688:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f010268f:	00 
f0102690:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102697:	e8 a4 d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010269c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01026a2:	89 3c 24             	mov    %edi,(%esp)
f01026a5:	e8 c5 e9 ff ff       	call   f010106f <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01026aa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01026b1:	00 
f01026b2:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01026b9:	00 
f01026ba:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f01026bf:	89 04 24             	mov    %eax,(%esp)
f01026c2:	e8 08 ea ff ff       	call   f01010cf <pgdir_walk>
f01026c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01026ca:	8b 0d 9c 1e 2e f0    	mov    0xf02e1e9c,%ecx
f01026d0:	8b 51 04             	mov    0x4(%ecx),%edx
f01026d3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026d9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026dc:	8b 15 98 1e 2e f0    	mov    0xf02e1e98,%edx
f01026e2:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01026e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01026e8:	c1 ea 0c             	shr    $0xc,%edx
f01026eb:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01026ee:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01026f1:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f01026f4:	72 23                	jb     f0102719 <mem_init+0x1355>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026f6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01026f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01026fd:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0102704:	f0 
f0102705:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f010270c:	00 
f010270d:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102714:	e8 27 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102719:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010271c:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102722:	39 d0                	cmp    %edx,%eax
f0102724:	74 24                	je     f010274a <mem_init+0x1386>
f0102726:	c7 44 24 0c 9f 88 10 	movl   $0xf010889f,0xc(%esp)
f010272d:	f0 
f010272e:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102735:	f0 
f0102736:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f010273d:	00 
f010273e:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102745:	e8 f6 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010274a:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102751:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102757:	89 f8                	mov    %edi,%eax
f0102759:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f010275f:	c1 f8 03             	sar    $0x3,%eax
f0102762:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102765:	89 c1                	mov    %eax,%ecx
f0102767:	c1 e9 0c             	shr    $0xc,%ecx
f010276a:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010276d:	77 20                	ja     f010278f <mem_init+0x13cb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010276f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102773:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f010277a:	f0 
f010277b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102782:	00 
f0102783:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f010278a:	e8 b1 d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010278f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102796:	00 
f0102797:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010279e:	00 
	return (void *)(pa + KERNBASE);
f010279f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027a4:	89 04 24             	mov    %eax,(%esp)
f01027a7:	e8 12 36 00 00       	call   f0105dbe <memset>
	page_free(pp0);
f01027ac:	89 3c 24             	mov    %edi,(%esp)
f01027af:	e8 bb e8 ff ff       	call   f010106f <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01027b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027bb:	00 
f01027bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01027c3:	00 
f01027c4:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f01027c9:	89 04 24             	mov    %eax,(%esp)
f01027cc:	e8 fe e8 ff ff       	call   f01010cf <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027d1:	89 fa                	mov    %edi,%edx
f01027d3:	2b 15 a0 1e 2e f0    	sub    0xf02e1ea0,%edx
f01027d9:	c1 fa 03             	sar    $0x3,%edx
f01027dc:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027df:	89 d0                	mov    %edx,%eax
f01027e1:	c1 e8 0c             	shr    $0xc,%eax
f01027e4:	3b 05 98 1e 2e f0    	cmp    0xf02e1e98,%eax
f01027ea:	72 20                	jb     f010280c <mem_init+0x1448>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01027f0:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f01027f7:	f0 
f01027f8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027ff:	00 
f0102800:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0102807:	e8 34 d8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010280c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102812:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102815:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010281b:	f6 00 01             	testb  $0x1,(%eax)
f010281e:	74 24                	je     f0102844 <mem_init+0x1480>
f0102820:	c7 44 24 0c b7 88 10 	movl   $0xf01088b7,0xc(%esp)
f0102827:	f0 
f0102828:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010282f:	f0 
f0102830:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102837:	00 
f0102838:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010283f:	e8 fc d7 ff ff       	call   f0100040 <_panic>
f0102844:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102847:	39 d0                	cmp    %edx,%eax
f0102849:	75 d0                	jne    f010281b <mem_init+0x1457>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010284b:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102850:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102856:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f010285c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010285f:	89 0d 40 12 2e f0    	mov    %ecx,0xf02e1240

	// free the pages we took
	page_free(pp0);
f0102865:	89 3c 24             	mov    %edi,(%esp)
f0102868:	e8 02 e8 ff ff       	call   f010106f <page_free>
	page_free(pp1);
f010286d:	89 34 24             	mov    %esi,(%esp)
f0102870:	e8 fa e7 ff ff       	call   f010106f <page_free>
	page_free(pp2);
f0102875:	89 1c 24             	mov    %ebx,(%esp)
f0102878:	e8 f2 e7 ff ff       	call   f010106f <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010287d:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102884:	00 
f0102885:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010288c:	e8 b7 ea ff ff       	call   f0101348 <mmio_map_region>
f0102891:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102893:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010289a:	00 
f010289b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028a2:	e8 a1 ea ff ff       	call   f0101348 <mmio_map_region>
f01028a7:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01028a9:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01028af:	76 0d                	jbe    f01028be <mem_init+0x14fa>
f01028b1:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f01028b7:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01028bc:	76 24                	jbe    f01028e2 <mem_init+0x151e>
f01028be:	c7 44 24 0c 40 82 10 	movl   $0xf0108240,0xc(%esp)
f01028c5:	f0 
f01028c6:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01028cd:	f0 
f01028ce:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f01028d5:	00 
f01028d6:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01028dd:	e8 5e d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01028e2:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01028e8:	76 0e                	jbe    f01028f8 <mem_init+0x1534>
f01028ea:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f01028f0:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01028f6:	76 24                	jbe    f010291c <mem_init+0x1558>
f01028f8:	c7 44 24 0c 68 82 10 	movl   $0xf0108268,0xc(%esp)
f01028ff:	f0 
f0102900:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102907:	f0 
f0102908:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f010290f:	00 
f0102910:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102917:	e8 24 d7 ff ff       	call   f0100040 <_panic>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010291c:	89 da                	mov    %ebx,%edx
f010291e:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102920:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102926:	74 24                	je     f010294c <mem_init+0x1588>
f0102928:	c7 44 24 0c 90 82 10 	movl   $0xf0108290,0xc(%esp)
f010292f:	f0 
f0102930:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102937:	f0 
f0102938:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f010293f:	00 
f0102940:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102947:	e8 f4 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010294c:	39 c6                	cmp    %eax,%esi
f010294e:	73 24                	jae    f0102974 <mem_init+0x15b0>
f0102950:	c7 44 24 0c ce 88 10 	movl   $0xf01088ce,0xc(%esp)
f0102957:	f0 
f0102958:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010295f:	f0 
f0102960:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f0102967:	00 
f0102968:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010296f:	e8 cc d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102974:	8b 3d 9c 1e 2e f0    	mov    0xf02e1e9c,%edi
f010297a:	89 da                	mov    %ebx,%edx
f010297c:	89 f8                	mov    %edi,%eax
f010297e:	e8 45 e1 ff ff       	call   f0100ac8 <check_va2pa>
f0102983:	85 c0                	test   %eax,%eax
f0102985:	74 24                	je     f01029ab <mem_init+0x15e7>
f0102987:	c7 44 24 0c b8 82 10 	movl   $0xf01082b8,0xc(%esp)
f010298e:	f0 
f010298f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102996:	f0 
f0102997:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f010299e:	00 
f010299f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01029a6:	e8 95 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029ab:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01029b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029b4:	89 c2                	mov    %eax,%edx
f01029b6:	89 f8                	mov    %edi,%eax
f01029b8:	e8 0b e1 ff ff       	call   f0100ac8 <check_va2pa>
f01029bd:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029c2:	74 24                	je     f01029e8 <mem_init+0x1624>
f01029c4:	c7 44 24 0c dc 82 10 	movl   $0xf01082dc,0xc(%esp)
f01029cb:	f0 
f01029cc:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01029d3:	f0 
f01029d4:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f01029db:	00 
f01029dc:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01029e3:	e8 58 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01029e8:	89 f2                	mov    %esi,%edx
f01029ea:	89 f8                	mov    %edi,%eax
f01029ec:	e8 d7 e0 ff ff       	call   f0100ac8 <check_va2pa>
f01029f1:	85 c0                	test   %eax,%eax
f01029f3:	74 24                	je     f0102a19 <mem_init+0x1655>
f01029f5:	c7 44 24 0c 0c 83 10 	movl   $0xf010830c,0xc(%esp)
f01029fc:	f0 
f01029fd:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102a04:	f0 
f0102a05:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f0102a0c:	00 
f0102a0d:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102a14:	e8 27 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a19:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a1f:	89 f8                	mov    %edi,%eax
f0102a21:	e8 a2 e0 ff ff       	call   f0100ac8 <check_va2pa>
f0102a26:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a29:	74 24                	je     f0102a4f <mem_init+0x168b>
f0102a2b:	c7 44 24 0c 30 83 10 	movl   $0xf0108330,0xc(%esp)
f0102a32:	f0 
f0102a33:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102a3a:	f0 
f0102a3b:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102a42:	00 
f0102a43:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102a4a:	e8 f1 d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a56:	00 
f0102a57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a5b:	89 3c 24             	mov    %edi,(%esp)
f0102a5e:	e8 6c e6 ff ff       	call   f01010cf <pgdir_walk>
f0102a63:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a66:	75 24                	jne    f0102a8c <mem_init+0x16c8>
f0102a68:	c7 44 24 0c 5c 83 10 	movl   $0xf010835c,0xc(%esp)
f0102a6f:	f0 
f0102a70:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102a77:	f0 
f0102a78:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f0102a7f:	00 
f0102a80:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102a87:	e8 b4 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a8c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a93:	00 
f0102a94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a98:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102a9d:	89 04 24             	mov    %eax,(%esp)
f0102aa0:	e8 2a e6 ff ff       	call   f01010cf <pgdir_walk>
f0102aa5:	f6 00 04             	testb  $0x4,(%eax)
f0102aa8:	74 24                	je     f0102ace <mem_init+0x170a>
f0102aaa:	c7 44 24 0c a0 83 10 	movl   $0xf01083a0,0xc(%esp)
f0102ab1:	f0 
f0102ab2:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102ab9:	f0 
f0102aba:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0102ac1:	00 
f0102ac2:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102ac9:	e8 72 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102ace:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ad5:	00 
f0102ad6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ada:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102adf:	89 04 24             	mov    %eax,(%esp)
f0102ae2:	e8 e8 e5 ff ff       	call   f01010cf <pgdir_walk>
f0102ae7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102aed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102af4:	00 
f0102af5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102af8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102afc:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102b01:	89 04 24             	mov    %eax,(%esp)
f0102b04:	e8 c6 e5 ff ff       	call   f01010cf <pgdir_walk>
f0102b09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102b0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b16:	00 
f0102b17:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b1b:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102b20:	89 04 24             	mov    %eax,(%esp)
f0102b23:	e8 a7 e5 ff ff       	call   f01010cf <pgdir_walk>
f0102b28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102b2e:	c7 04 24 e0 88 10 f0 	movl   $0xf01088e0,(%esp)
f0102b35:	e8 50 13 00 00       	call   f0103e8a <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102b3a:	a1 a0 1e 2e f0       	mov    0xf02e1ea0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b3f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b44:	77 20                	ja     f0102b66 <mem_init+0x17a2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b46:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b4a:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0102b51:	f0 
f0102b52:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f0102b59:	00 
f0102b5a:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102b61:	e8 da d4 ff ff       	call   f0100040 <_panic>
f0102b66:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102b6d:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b6e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b73:	89 04 24             	mov    %eax,(%esp)
f0102b76:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102b7b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b80:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102b85:	e8 e4 e5 ff ff       	call   f010116e <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f0102b8a:	a1 48 12 2e f0       	mov    0xf02e1248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b8f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b94:	77 20                	ja     f0102bb6 <mem_init+0x17f2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b96:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b9a:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0102ba1:	f0 
f0102ba2:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f0102ba9:	00 
f0102baa:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102bb1:	e8 8a d4 ff ff       	call   f0100040 <_panic>
f0102bb6:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102bbd:	00 
	return (physaddr_t)kva - KERNBASE;
f0102bbe:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bc3:	89 04 24             	mov    %eax,(%esp)
f0102bc6:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102bcb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102bd0:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102bd5:	e8 94 e5 ff ff       	call   f010116e <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bda:	b8 00 20 12 f0       	mov    $0xf0122000,%eax
f0102bdf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102be4:	77 20                	ja     f0102c06 <mem_init+0x1842>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102be6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bea:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0102bf1:	f0 
f0102bf2:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
f0102bf9:	00 
f0102bfa:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102c01:	e8 3a d4 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102c06:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c0d:	00 
f0102c0e:	c7 04 24 00 20 12 00 	movl   $0x122000,(%esp)
f0102c15:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c1a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102c1f:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102c24:	e8 45 e5 ff ff       	call   f010116e <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE + 1, 0, PTE_W);
f0102c29:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c30:	00 
f0102c31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c38:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102c3d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102c42:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102c47:	e8 22 e5 ff ff       	call   f010116e <boot_map_region>
f0102c4c:	c7 45 cc 00 30 2e f0 	movl   $0xf02e3000,-0x34(%ebp)
f0102c53:	bb 00 30 2e f0       	mov    $0xf02e3000,%ebx
f0102c58:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c5d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102c63:	77 20                	ja     f0102c85 <mem_init+0x18c1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c65:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102c69:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0102c70:	f0 
f0102c71:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
f0102c78:	00 
f0102c79:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102c80:	e8 bb d3 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	int perm = PTE_P | PTE_W;
	for (uint32_t i = 0; i < NCPU; ++i)
	{
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), perm);
f0102c85:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c8c:	00 
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102c8d:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	// LAB 4: Your code here:
	int perm = PTE_P | PTE_W;
	for (uint32_t i = 0; i < NCPU; ++i)
	{
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), perm);
f0102c93:	89 04 24             	mov    %eax,(%esp)
f0102c96:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c9b:	89 f2                	mov    %esi,%edx
f0102c9d:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0102ca2:	e8 c7 e4 ff ff       	call   f010116e <boot_map_region>
f0102ca7:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102cad:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int perm = PTE_P | PTE_W;
	for (uint32_t i = 0; i < NCPU; ++i)
f0102cb3:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102cb9:	75 a2                	jne    f0102c5d <mem_init+0x1899>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102cbb:	8b 1d 9c 1e 2e f0    	mov    0xf02e1e9c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102cc1:	8b 0d 98 1e 2e f0    	mov    0xf02e1e98,%ecx
f0102cc7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102cca:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102cd1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102cd7:	be 00 00 00 00       	mov    $0x0,%esi
f0102cdc:	eb 70                	jmp    f0102d4e <mem_init+0x198a>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cde:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102ce4:	89 d8                	mov    %ebx,%eax
f0102ce6:	e8 dd dd ff ff       	call   f0100ac8 <check_va2pa>
f0102ceb:	8b 15 a0 1e 2e f0    	mov    0xf02e1ea0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cf1:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102cf7:	77 20                	ja     f0102d19 <mem_init+0x1955>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cf9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cfd:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0102d04:	f0 
f0102d05:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102d0c:	00 
f0102d0d:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102d14:	e8 27 d3 ff ff       	call   f0100040 <_panic>
f0102d19:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d20:	39 d0                	cmp    %edx,%eax
f0102d22:	74 24                	je     f0102d48 <mem_init+0x1984>
f0102d24:	c7 44 24 0c d4 83 10 	movl   $0xf01083d4,0xc(%esp)
f0102d2b:	f0 
f0102d2c:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102d33:	f0 
f0102d34:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102d3b:	00 
f0102d3c:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102d43:	e8 f8 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d48:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d4e:	39 f7                	cmp    %esi,%edi
f0102d50:	77 8c                	ja     f0102cde <mem_init+0x191a>
f0102d52:	be 00 00 00 00       	mov    $0x0,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d57:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102d5d:	89 d8                	mov    %ebx,%eax
f0102d5f:	e8 64 dd ff ff       	call   f0100ac8 <check_va2pa>
f0102d64:	8b 15 48 12 2e f0    	mov    0xf02e1248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d6a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d70:	77 20                	ja     f0102d92 <mem_init+0x19ce>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d72:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d76:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0102d7d:	f0 
f0102d7e:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0102d85:	00 
f0102d86:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102d8d:	e8 ae d2 ff ff       	call   f0100040 <_panic>
f0102d92:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d99:	39 d0                	cmp    %edx,%eax
f0102d9b:	74 24                	je     f0102dc1 <mem_init+0x19fd>
f0102d9d:	c7 44 24 0c 08 84 10 	movl   $0xf0108408,0xc(%esp)
f0102da4:	f0 
f0102da5:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102dac:	f0 
f0102dad:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0102db4:	00 
f0102db5:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102dbc:	e8 7f d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102dc1:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102dc7:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102dcd:	75 88                	jne    f0102d57 <mem_init+0x1993>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102dcf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102dd2:	c1 e7 0c             	shl    $0xc,%edi
f0102dd5:	be 00 00 00 00       	mov    $0x0,%esi
f0102dda:	eb 3b                	jmp    f0102e17 <mem_init+0x1a53>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ddc:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102de2:	89 d8                	mov    %ebx,%eax
f0102de4:	e8 df dc ff ff       	call   f0100ac8 <check_va2pa>
f0102de9:	39 c6                	cmp    %eax,%esi
f0102deb:	74 24                	je     f0102e11 <mem_init+0x1a4d>
f0102ded:	c7 44 24 0c 3c 84 10 	movl   $0xf010843c,0xc(%esp)
f0102df4:	f0 
f0102df5:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102dfc:	f0 
f0102dfd:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0102e04:	00 
f0102e05:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102e0c:	e8 2f d2 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e11:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e17:	39 fe                	cmp    %edi,%esi
f0102e19:	72 c1                	jb     f0102ddc <mem_init+0x1a18>
f0102e1b:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102e20:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e23:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e26:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e29:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e2f:	89 c6                	mov    %eax,%esi
f0102e31:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102e37:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0102e3d:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e40:	89 da                	mov    %ebx,%edx
f0102e42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e45:	e8 7e dc ff ff       	call   f0100ac8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e4a:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e51:	77 23                	ja     f0102e76 <mem_init+0x1ab2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e53:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e56:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102e5a:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0102e61:	f0 
f0102e62:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0102e69:	00 
f0102e6a:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102e71:	e8 ca d1 ff ff       	call   f0100040 <_panic>
f0102e76:	39 f0                	cmp    %esi,%eax
f0102e78:	74 24                	je     f0102e9e <mem_init+0x1ada>
f0102e7a:	c7 44 24 0c 64 84 10 	movl   $0xf0108464,0xc(%esp)
f0102e81:	f0 
f0102e82:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102e89:	f0 
f0102e8a:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0102e91:	00 
f0102e92:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102e99:	e8 a2 d1 ff ff       	call   f0100040 <_panic>
f0102e9e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ea4:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102eaa:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102ead:	0f 85 5e 05 00 00    	jne    f0103411 <mem_init+0x204d>
f0102eb3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102eb8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ebb:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102ebe:	89 f0                	mov    %esi,%eax
f0102ec0:	e8 03 dc ff ff       	call   f0100ac8 <check_va2pa>
f0102ec5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ec8:	74 24                	je     f0102eee <mem_init+0x1b2a>
f0102eca:	c7 44 24 0c ac 84 10 	movl   $0xf01084ac,0xc(%esp)
f0102ed1:	f0 
f0102ed2:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102ed9:	f0 
f0102eda:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102ee1:	00 
f0102ee2:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102ee9:	e8 52 d1 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102eee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ef4:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102efa:	75 bf                	jne    f0102ebb <mem_init+0x1af7>
f0102efc:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102f02:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102f09:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102f0f:	0f 85 0e ff ff ff    	jne    f0102e23 <mem_init+0x1a5f>
f0102f15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f18:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102f1d:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102f23:	83 fa 04             	cmp    $0x4,%edx
f0102f26:	77 2e                	ja     f0102f56 <mem_init+0x1b92>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102f28:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102f2c:	0f 85 aa 00 00 00    	jne    f0102fdc <mem_init+0x1c18>
f0102f32:	c7 44 24 0c f9 88 10 	movl   $0xf01088f9,0xc(%esp)
f0102f39:	f0 
f0102f3a:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102f41:	f0 
f0102f42:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0102f49:	00 
f0102f4a:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102f51:	e8 ea d0 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102f56:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102f5b:	76 55                	jbe    f0102fb2 <mem_init+0x1bee>
				assert(pgdir[i] & PTE_P);
f0102f5d:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102f60:	f6 c2 01             	test   $0x1,%dl
f0102f63:	75 24                	jne    f0102f89 <mem_init+0x1bc5>
f0102f65:	c7 44 24 0c f9 88 10 	movl   $0xf01088f9,0xc(%esp)
f0102f6c:	f0 
f0102f6d:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102f74:	f0 
f0102f75:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0102f7c:	00 
f0102f7d:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102f84:	e8 b7 d0 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102f89:	f6 c2 02             	test   $0x2,%dl
f0102f8c:	75 4e                	jne    f0102fdc <mem_init+0x1c18>
f0102f8e:	c7 44 24 0c 0a 89 10 	movl   $0xf010890a,0xc(%esp)
f0102f95:	f0 
f0102f96:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102f9d:	f0 
f0102f9e:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0102fa5:	00 
f0102fa6:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102fad:	e8 8e d0 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102fb2:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102fb6:	74 24                	je     f0102fdc <mem_init+0x1c18>
f0102fb8:	c7 44 24 0c 1b 89 10 	movl   $0xf010891b,0xc(%esp)
f0102fbf:	f0 
f0102fc0:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0102fc7:	f0 
f0102fc8:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0102fcf:	00 
f0102fd0:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0102fd7:	e8 64 d0 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102fdc:	40                   	inc    %eax
f0102fdd:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102fe2:	0f 85 35 ff ff ff    	jne    f0102f1d <mem_init+0x1b59>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102fe8:	c7 04 24 d0 84 10 f0 	movl   $0xf01084d0,(%esp)
f0102fef:	e8 96 0e 00 00       	call   f0103e8a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102ff4:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ff9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ffe:	77 20                	ja     f0103020 <mem_init+0x1c5c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103000:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103004:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f010300b:	f0 
f010300c:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
f0103013:	00 
f0103014:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010301b:	e8 20 d0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103020:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103025:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103028:	b8 00 00 00 00       	mov    $0x0,%eax
f010302d:	e8 ae db ff ff       	call   f0100be0 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0103032:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103035:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010303a:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010303d:	0f 22 c0             	mov    %eax,%cr0

static inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	asm volatile("movl %%cr4,%0" : "=r" (cr4));
f0103040:	0f 20 e0             	mov    %cr4,%eax
	lcr0(cr0);

	uint32_t cr4 = rcr4();
	cr4 |= CR4_PSE;
f0103043:	83 c8 10             	or     $0x10,%eax
}

static inline void
lcr4(uint32_t val)
{
	asm volatile("movl %0,%%cr4" : : "r" (val));
f0103046:	0f 22 e0             	mov    %eax,%cr4
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103050:	e8 96 df ff ff       	call   f0100feb <page_alloc>
f0103055:	89 c6                	mov    %eax,%esi
f0103057:	85 c0                	test   %eax,%eax
f0103059:	75 24                	jne    f010307f <mem_init+0x1cbb>
f010305b:	c7 44 24 0c 05 87 10 	movl   $0xf0108705,0xc(%esp)
f0103062:	f0 
f0103063:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010306a:	f0 
f010306b:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0103072:	00 
f0103073:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010307a:	e8 c1 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010307f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103086:	e8 60 df ff ff       	call   f0100feb <page_alloc>
f010308b:	89 c7                	mov    %eax,%edi
f010308d:	85 c0                	test   %eax,%eax
f010308f:	75 24                	jne    f01030b5 <mem_init+0x1cf1>
f0103091:	c7 44 24 0c 1b 87 10 	movl   $0xf010871b,0xc(%esp)
f0103098:	f0 
f0103099:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01030a0:	f0 
f01030a1:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f01030a8:	00 
f01030a9:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01030b0:	e8 8b cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01030b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030bc:	e8 2a df ff ff       	call   f0100feb <page_alloc>
f01030c1:	89 c3                	mov    %eax,%ebx
f01030c3:	85 c0                	test   %eax,%eax
f01030c5:	75 24                	jne    f01030eb <mem_init+0x1d27>
f01030c7:	c7 44 24 0c 31 87 10 	movl   $0xf0108731,0xc(%esp)
f01030ce:	f0 
f01030cf:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01030d6:	f0 
f01030d7:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f01030de:	00 
f01030df:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01030e6:	e8 55 cf ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01030eb:	89 34 24             	mov    %esi,(%esp)
f01030ee:	e8 7c df ff ff       	call   f010106f <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01030f3:	89 f8                	mov    %edi,%eax
f01030f5:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f01030fb:	c1 f8 03             	sar    $0x3,%eax
f01030fe:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103101:	89 c2                	mov    %eax,%edx
f0103103:	c1 ea 0c             	shr    $0xc,%edx
f0103106:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f010310c:	72 20                	jb     f010312e <mem_init+0x1d6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010310e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103112:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0103119:	f0 
f010311a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103121:	00 
f0103122:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0103129:	e8 12 cf ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010312e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103135:	00 
f0103136:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010313d:	00 
	return (void *)(pa + KERNBASE);
f010313e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103143:	89 04 24             	mov    %eax,(%esp)
f0103146:	e8 73 2c 00 00       	call   f0105dbe <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010314b:	89 d8                	mov    %ebx,%eax
f010314d:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0103153:	c1 f8 03             	sar    $0x3,%eax
f0103156:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103159:	89 c2                	mov    %eax,%edx
f010315b:	c1 ea 0c             	shr    $0xc,%edx
f010315e:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f0103164:	72 20                	jb     f0103186 <mem_init+0x1dc2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103166:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010316a:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0103171:	f0 
f0103172:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103179:	00 
f010317a:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0103181:	e8 ba ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103186:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010318d:	00 
f010318e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103195:	00 
	return (void *)(pa + KERNBASE);
f0103196:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010319b:	89 04 24             	mov    %eax,(%esp)
f010319e:	e8 1b 2c 00 00       	call   f0105dbe <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031a3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01031aa:	00 
f01031ab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031b2:	00 
f01031b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01031b7:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f01031bc:	89 04 24             	mov    %eax,(%esp)
f01031bf:	e8 12 e1 ff ff       	call   f01012d6 <page_insert>
	assert(pp1->pp_ref == 1);
f01031c4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01031c9:	74 24                	je     f01031ef <mem_init+0x1e2b>
f01031cb:	c7 44 24 0c 02 88 10 	movl   $0xf0108802,0xc(%esp)
f01031d2:	f0 
f01031d3:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01031da:	f0 
f01031db:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f01031e2:	00 
f01031e3:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01031ea:	e8 51 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01031ef:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01031f6:	01 01 01 
f01031f9:	74 24                	je     f010321f <mem_init+0x1e5b>
f01031fb:	c7 44 24 0c f0 84 10 	movl   $0xf01084f0,0xc(%esp)
f0103202:	f0 
f0103203:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010320a:	f0 
f010320b:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f0103212:	00 
f0103213:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010321a:	e8 21 ce ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010321f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103226:	00 
f0103227:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010322e:	00 
f010322f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103233:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0103238:	89 04 24             	mov    %eax,(%esp)
f010323b:	e8 96 e0 ff ff       	call   f01012d6 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103240:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103247:	02 02 02 
f010324a:	74 24                	je     f0103270 <mem_init+0x1eac>
f010324c:	c7 44 24 0c 14 85 10 	movl   $0xf0108514,0xc(%esp)
f0103253:	f0 
f0103254:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f010325b:	f0 
f010325c:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0103263:	00 
f0103264:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f010326b:	e8 d0 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103270:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103275:	74 24                	je     f010329b <mem_init+0x1ed7>
f0103277:	c7 44 24 0c 24 88 10 	movl   $0xf0108824,0xc(%esp)
f010327e:	f0 
f010327f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0103286:	f0 
f0103287:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f010328e:	00 
f010328f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0103296:	e8 a5 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010329b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01032a0:	74 24                	je     f01032c6 <mem_init+0x1f02>
f01032a2:	c7 44 24 0c 8e 88 10 	movl   $0xf010888e,0xc(%esp)
f01032a9:	f0 
f01032aa:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01032b1:	f0 
f01032b2:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f01032b9:	00 
f01032ba:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01032c1:	e8 7a cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01032c6:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01032cd:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01032d0:	89 d8                	mov    %ebx,%eax
f01032d2:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f01032d8:	c1 f8 03             	sar    $0x3,%eax
f01032db:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032de:	89 c2                	mov    %eax,%edx
f01032e0:	c1 ea 0c             	shr    $0xc,%edx
f01032e3:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f01032e9:	72 20                	jb     f010330b <mem_init+0x1f47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032ef:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f01032f6:	f0 
f01032f7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01032fe:	00 
f01032ff:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0103306:	e8 35 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010330b:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103312:	03 03 03 
f0103315:	74 24                	je     f010333b <mem_init+0x1f77>
f0103317:	c7 44 24 0c 38 85 10 	movl   $0xf0108538,0xc(%esp)
f010331e:	f0 
f010331f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0103326:	f0 
f0103327:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f010332e:	00 
f010332f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0103336:	e8 05 cd ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010333b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103342:	00 
f0103343:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0103348:	89 04 24             	mov    %eax,(%esp)
f010334b:	e8 34 df ff ff       	call   f0101284 <page_remove>
	assert(pp2->pp_ref == 0);
f0103350:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103355:	74 24                	je     f010337b <mem_init+0x1fb7>
f0103357:	c7 44 24 0c 5c 88 10 	movl   $0xf010885c,0xc(%esp)
f010335e:	f0 
f010335f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0103366:	f0 
f0103367:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
f010336e:	00 
f010336f:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f0103376:	e8 c5 cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010337b:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0103380:	8b 08                	mov    (%eax),%ecx
f0103382:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103388:	89 f2                	mov    %esi,%edx
f010338a:	2b 15 a0 1e 2e f0    	sub    0xf02e1ea0,%edx
f0103390:	c1 fa 03             	sar    $0x3,%edx
f0103393:	c1 e2 0c             	shl    $0xc,%edx
f0103396:	39 d1                	cmp    %edx,%ecx
f0103398:	74 24                	je     f01033be <mem_init+0x1ffa>
f010339a:	c7 44 24 0c c0 7e 10 	movl   $0xf0107ec0,0xc(%esp)
f01033a1:	f0 
f01033a2:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01033a9:	f0 
f01033aa:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f01033b1:	00 
f01033b2:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01033b9:	e8 82 cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01033be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01033c4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01033c9:	74 24                	je     f01033ef <mem_init+0x202b>
f01033cb:	c7 44 24 0c 13 88 10 	movl   $0xf0108813,0xc(%esp)
f01033d2:	f0 
f01033d3:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01033da:	f0 
f01033db:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f01033e2:	00 
f01033e3:	c7 04 24 c5 85 10 f0 	movl   $0xf01085c5,(%esp)
f01033ea:	e8 51 cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01033ef:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01033f5:	89 34 24             	mov    %esi,(%esp)
f01033f8:	e8 72 dc ff ff       	call   f010106f <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01033fd:	c7 04 24 64 85 10 f0 	movl   $0xf0108564,(%esp)
f0103404:	e8 81 0a 00 00       	call   f0103e8a <cprintf>
	uint32_t cr4 = rcr4();
	cr4 |= CR4_PSE;
	lcr4(cr4);
	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103409:	83 c4 3c             	add    $0x3c,%esp
f010340c:	5b                   	pop    %ebx
f010340d:	5e                   	pop    %esi
f010340e:	5f                   	pop    %edi
f010340f:	5d                   	pop    %ebp
f0103410:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103411:	89 da                	mov    %ebx,%edx
f0103413:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103416:	e8 ad d6 ff ff       	call   f0100ac8 <check_va2pa>
f010341b:	e9 56 fa ff ff       	jmp    f0102e76 <mem_init+0x1ab2>

f0103420 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103420:	55                   	push   %ebp
f0103421:	89 e5                	mov    %esp,%ebp
f0103423:	57                   	push   %edi
f0103424:	56                   	push   %esi
f0103425:	53                   	push   %ebx
f0103426:	83 ec 2c             	sub    $0x2c,%esp
f0103429:	8b 75 08             	mov    0x8(%ebp),%esi
f010342c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
	uint32_t low = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t high = (uint32_t)ROUNDUP(va + len, PGSIZE);
f010342f:	89 d8                	mov    %ebx,%eax
f0103431:	03 45 10             	add    0x10(%ebp),%eax
f0103434:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103439:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010343e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t *pte = pgdir_walk(env->env_pgdir, va, 0);
f0103441:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103448:	00 
f0103449:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010344d:	8b 46 60             	mov    0x60(%esi),%eax
f0103450:	89 04 24             	mov    %eax,(%esp)
f0103453:	e8 77 dc ff ff       	call   f01010cf <pgdir_walk>
	uintptr_t a = (uintptr_t)va;
	if ( a >= ULIM || !pte || ((*pte) & perm) != perm){
f0103458:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010345e:	77 0f                	ja     f010346f <user_mem_check+0x4f>
f0103460:	85 c0                	test   %eax,%eax
f0103462:	74 0b                	je     f010346f <user_mem_check+0x4f>
f0103464:	8b 7d 14             	mov    0x14(%ebp),%edi
f0103467:	8b 00                	mov    (%eax),%eax
f0103469:	21 f8                	and    %edi,%eax
f010346b:	39 c7                	cmp    %eax,%edi
f010346d:	74 0d                	je     f010347c <user_mem_check+0x5c>
		user_mem_check_addr = a;
f010346f:	89 1d 44 12 2e f0    	mov    %ebx,0xf02e1244
		return -E_FAULT;
f0103475:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010347a:	eb 63                	jmp    f01034df <user_mem_check+0xbf>
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uint32_t low = (uint32_t)ROUNDDOWN(va, PGSIZE);
f010347c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ( a >= ULIM || !pte || ((*pte) & perm) != perm){
		user_mem_check_addr = a;
		return -E_FAULT;
	}
	
	for (uint32_t i = low + PGSIZE; i < high; i += PGSIZE)
f0103482:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103488:	eb 4b                	jmp    f01034d5 <user_mem_check+0xb5>
	{
		if (i >= ULIM)
f010348a:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103490:	76 0d                	jbe    f010349f <user_mem_check+0x7f>
		{
			user_mem_check_addr = i;
f0103492:	89 1d 44 12 2e f0    	mov    %ebx,0xf02e1244
			return -E_FAULT;
f0103498:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010349d:	eb 40                	jmp    f01034df <user_mem_check+0xbf>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)i, 0);
f010349f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034a6:	00 
f01034a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034ab:	8b 46 60             	mov    0x60(%esi),%eax
f01034ae:	89 04 24             	mov    %eax,(%esp)
f01034b1:	e8 19 dc ff ff       	call   f01010cf <pgdir_walk>
		if (!pte || ((*pte) & perm) != perm)
f01034b6:	85 c0                	test   %eax,%eax
f01034b8:	74 08                	je     f01034c2 <user_mem_check+0xa2>
f01034ba:	8b 00                	mov    (%eax),%eax
f01034bc:	21 f8                	and    %edi,%eax
f01034be:	39 c7                	cmp    %eax,%edi
f01034c0:	74 0d                	je     f01034cf <user_mem_check+0xaf>
		{
			user_mem_check_addr = i;
f01034c2:	89 1d 44 12 2e f0    	mov    %ebx,0xf02e1244
			return -E_FAULT;
f01034c8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034cd:	eb 10                	jmp    f01034df <user_mem_check+0xbf>
	if ( a >= ULIM || !pte || ((*pte) & perm) != perm){
		user_mem_check_addr = a;
		return -E_FAULT;
	}
	
	for (uint32_t i = low + PGSIZE; i < high; i += PGSIZE)
f01034cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034d5:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01034d8:	72 b0                	jb     f010348a <user_mem_check+0x6a>
		{
			user_mem_check_addr = i;
			return -E_FAULT;
		}
	}
	return 0;
f01034da:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034df:	83 c4 2c             	add    $0x2c,%esp
f01034e2:	5b                   	pop    %ebx
f01034e3:	5e                   	pop    %esi
f01034e4:	5f                   	pop    %edi
f01034e5:	5d                   	pop    %ebp
f01034e6:	c3                   	ret    

f01034e7 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01034e7:	55                   	push   %ebp
f01034e8:	89 e5                	mov    %esp,%ebp
f01034ea:	53                   	push   %ebx
f01034eb:	83 ec 14             	sub    $0x14,%esp
f01034ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01034f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01034f4:	83 c8 04             	or     $0x4,%eax
f01034f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034fb:	8b 45 10             	mov    0x10(%ebp),%eax
f01034fe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103502:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103505:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103509:	89 1c 24             	mov    %ebx,(%esp)
f010350c:	e8 0f ff ff ff       	call   f0103420 <user_mem_check>
f0103511:	85 c0                	test   %eax,%eax
f0103513:	79 24                	jns    f0103539 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103515:	a1 44 12 2e f0       	mov    0xf02e1244,%eax
f010351a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010351e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103521:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103525:	c7 04 24 90 85 10 f0 	movl   $0xf0108590,(%esp)
f010352c:	e8 59 09 00 00       	call   f0103e8a <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103531:	89 1c 24             	mov    %ebx,(%esp)
f0103534:	e8 79 06 00 00       	call   f0103bb2 <env_destroy>
	}
}
f0103539:	83 c4 14             	add    $0x14,%esp
f010353c:	5b                   	pop    %ebx
f010353d:	5d                   	pop    %ebp
f010353e:	c3                   	ret    
	...

f0103540 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103540:	55                   	push   %ebp
f0103541:	89 e5                	mov    %esp,%ebp
f0103543:	57                   	push   %edi
f0103544:	56                   	push   %esi
f0103545:	53                   	push   %ebx
f0103546:	83 ec 2c             	sub    $0x2c,%esp
f0103549:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uint32_t low = ROUNDDOWN((uint32_t)va, PGSIZE);
	uint32_t high = ROUNDUP((uint32_t)va + len, PGSIZE);
f010354b:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103552:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103557:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	struct PageInfo *p;
	uint32_t perm = PTE_P | PTE_U | PTE_W;
	for (size_t i = low; i < high; i += PGSIZE)
f010355a:	89 d6                	mov    %edx,%esi
f010355c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0103562:	e9 80 00 00 00       	jmp    f01035e7 <region_alloc+0xa7>
	{
		if (!(p = page_alloc(0)))
f0103567:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010356e:	e8 78 da ff ff       	call   f0100feb <page_alloc>
f0103573:	89 c3                	mov    %eax,%ebx
f0103575:	85 c0                	test   %eax,%eax
f0103577:	75 1c                	jne    f0103595 <region_alloc+0x55>
		{
			panic("region_alloc, out of memory\n");
f0103579:	c7 44 24 08 29 89 10 	movl   $0xf0108929,0x8(%esp)
f0103580:	f0 
f0103581:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0103588:	00 
f0103589:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f0103590:	e8 ab ca ff ff       	call   f0100040 <_panic>
		}
		p->pp_ref++;
f0103595:	66 ff 40 04          	incw   0x4(%eax)
		pte_t *pte = pgdir_walk(e->env_pgdir, (void*)i, 1);
f0103599:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01035a0:	00 
f01035a1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035a5:	8b 47 60             	mov    0x60(%edi),%eax
f01035a8:	89 04 24             	mov    %eax,(%esp)
f01035ab:	e8 1f db ff ff       	call   f01010cf <pgdir_walk>
		if (!pte)
f01035b0:	85 c0                	test   %eax,%eax
f01035b2:	75 1c                	jne    f01035d0 <region_alloc+0x90>
		{
			panic("region_alloc, out of memory\n");
f01035b4:	c7 44 24 08 29 89 10 	movl   $0xf0108929,0x8(%esp)
f01035bb:	f0 
f01035bc:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
f01035c3:	00 
f01035c4:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f01035cb:	e8 70 ca ff ff       	call   f0100040 <_panic>
f01035d0:	2b 1d a0 1e 2e f0    	sub    0xf02e1ea0,%ebx
f01035d6:	c1 fb 03             	sar    $0x3,%ebx
f01035d9:	c1 e3 0c             	shl    $0xc,%ebx
		}
		*pte = page2pa(p) | perm;
f01035dc:	83 cb 07             	or     $0x7,%ebx
f01035df:	89 18                	mov    %ebx,(%eax)
	//   (Watch out for corner-cases!)
	uint32_t low = ROUNDDOWN((uint32_t)va, PGSIZE);
	uint32_t high = ROUNDUP((uint32_t)va + len, PGSIZE);
	struct PageInfo *p;
	uint32_t perm = PTE_P | PTE_U | PTE_W;
	for (size_t i = low; i < high; i += PGSIZE)
f01035e1:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01035e7:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01035ea:	0f 82 77 ff ff ff    	jb     f0103567 <region_alloc+0x27>
		{
			panic("region_alloc, out of memory\n");
		}
		*pte = page2pa(p) | perm;
	}
}
f01035f0:	83 c4 2c             	add    $0x2c,%esp
f01035f3:	5b                   	pop    %ebx
f01035f4:	5e                   	pop    %esi
f01035f5:	5f                   	pop    %edi
f01035f6:	5d                   	pop    %ebp
f01035f7:	c3                   	ret    

f01035f8 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01035f8:	55                   	push   %ebp
f01035f9:	89 e5                	mov    %esp,%ebp
f01035fb:	57                   	push   %edi
f01035fc:	56                   	push   %esi
f01035fd:	53                   	push   %ebx
f01035fe:	83 ec 0c             	sub    $0xc,%esp
f0103601:	8b 45 08             	mov    0x8(%ebp),%eax
f0103604:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103607:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010360a:	85 c0                	test   %eax,%eax
f010360c:	75 24                	jne    f0103632 <envid2env+0x3a>
		*env_store = curenv;
f010360e:	e8 e9 2d 00 00       	call   f01063fc <cpunum>
f0103613:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010361a:	29 c2                	sub    %eax,%edx
f010361c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010361f:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0103626:	89 06                	mov    %eax,(%esi)
		return 0;
f0103628:	b8 00 00 00 00       	mov    $0x0,%eax
f010362d:	e9 84 00 00 00       	jmp    f01036b6 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103632:	89 c3                	mov    %eax,%ebx
f0103634:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010363a:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0103641:	c1 e3 07             	shl    $0x7,%ebx
f0103644:	29 cb                	sub    %ecx,%ebx
f0103646:	03 1d 48 12 2e f0    	add    0xf02e1248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010364c:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103650:	74 05                	je     f0103657 <envid2env+0x5f>
f0103652:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103655:	74 0d                	je     f0103664 <envid2env+0x6c>
		*env_store = 0;
f0103657:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f010365d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103662:	eb 52                	jmp    f01036b6 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103664:	84 d2                	test   %dl,%dl
f0103666:	74 47                	je     f01036af <envid2env+0xb7>
f0103668:	e8 8f 2d 00 00       	call   f01063fc <cpunum>
f010366d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103674:	29 c2                	sub    %eax,%edx
f0103676:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103679:	39 1c 85 28 20 2e f0 	cmp    %ebx,-0xfd1dfd8(,%eax,4)
f0103680:	74 2d                	je     f01036af <envid2env+0xb7>
f0103682:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103685:	e8 72 2d 00 00       	call   f01063fc <cpunum>
f010368a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103691:	29 c2                	sub    %eax,%edx
f0103693:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103696:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f010369d:	3b 78 48             	cmp    0x48(%eax),%edi
f01036a0:	74 0d                	je     f01036af <envid2env+0xb7>
		*env_store = 0;
f01036a2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036a8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036ad:	eb 07                	jmp    f01036b6 <envid2env+0xbe>
	}

	*env_store = e;
f01036af:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01036b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036b6:	83 c4 0c             	add    $0xc,%esp
f01036b9:	5b                   	pop    %ebx
f01036ba:	5e                   	pop    %esi
f01036bb:	5f                   	pop    %edi
f01036bc:	5d                   	pop    %ebp
f01036bd:	c3                   	ret    

f01036be <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036be:	55                   	push   %ebp
f01036bf:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01036c1:	b8 20 c3 12 f0       	mov    $0xf012c320,%eax
f01036c6:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01036c9:	b8 23 00 00 00       	mov    $0x23,%eax
f01036ce:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01036d0:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01036d2:	b0 10                	mov    $0x10,%al
f01036d4:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01036d6:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01036d8:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01036da:	ea e1 36 10 f0 08 00 	ljmp   $0x8,$0xf01036e1
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01036e1:	b0 00                	mov    $0x0,%al
f01036e3:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01036e6:	5d                   	pop    %ebp
f01036e7:	c3                   	ret    

f01036e8 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01036e8:	55                   	push   %ebp
f01036e9:	89 e5                	mov    %esp,%ebp
f01036eb:	b8 00 00 00 00       	mov    $0x0,%eax
	// Set up envs array
	// LAB 3: Your code here.
	struct Env **r = &env_free_list;
f01036f0:	b9 4c 12 2e f0       	mov    $0xf02e124c,%ecx

	for (uint32_t i = 0; i < NENV; ++i)
	{
		envs[i].env_id = 0;
f01036f5:	89 c2                	mov    %eax,%edx
f01036f7:	03 15 48 12 2e f0    	add    0xf02e1248,%edx
f01036fd:	c7 42 48 00 00 00 00 	movl   $0x0,0x48(%edx)
		*r = &envs[i];
f0103704:	89 11                	mov    %edx,(%ecx)
		r = &envs[i].env_link;
f0103706:	89 c1                	mov    %eax,%ecx
f0103708:	03 0d 48 12 2e f0    	add    0xf02e1248,%ecx
f010370e:	83 c1 44             	add    $0x44,%ecx
f0103711:	83 c0 7c             	add    $0x7c,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	struct Env **r = &env_free_list;

	for (uint32_t i = 0; i < NENV; ++i)
f0103714:	3d 00 f0 01 00       	cmp    $0x1f000,%eax
f0103719:	75 da                	jne    f01036f5 <env_init+0xd>
		envs[i].env_id = 0;
		*r = &envs[i];
		r = &envs[i].env_link;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010371b:	e8 9e ff ff ff       	call   f01036be <env_init_percpu>
}
f0103720:	5d                   	pop    %ebp
f0103721:	c3                   	ret    

f0103722 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103722:	55                   	push   %ebp
f0103723:	89 e5                	mov    %esp,%ebp
f0103725:	56                   	push   %esi
f0103726:	53                   	push   %ebx
f0103727:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010372a:	8b 1d 4c 12 2e f0    	mov    0xf02e124c,%ebx
f0103730:	85 db                	test   %ebx,%ebx
f0103732:	0f 84 67 01 00 00    	je     f010389f <env_alloc+0x17d>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103738:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010373f:	e8 a7 d8 ff ff       	call   f0100feb <page_alloc>
f0103744:	85 c0                	test   %eax,%eax
f0103746:	0f 84 5a 01 00 00    	je     f01038a6 <env_alloc+0x184>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f010374c:	66 ff 40 04          	incw   0x4(%eax)
f0103750:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0103756:	c1 f8 03             	sar    $0x3,%eax
f0103759:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010375c:	89 c2                	mov    %eax,%edx
f010375e:	c1 ea 0c             	shr    $0xc,%edx
f0103761:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f0103767:	72 20                	jb     f0103789 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103769:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010376d:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0103774:	f0 
f0103775:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010377c:	00 
f010377d:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0103784:	e8 b7 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103789:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f010378e:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(page2kva(p), kern_pgdir, PGSIZE);
f0103791:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103798:	00 
f0103799:	8b 15 9c 1e 2e f0    	mov    0xf02e1e9c,%edx
f010379f:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037a3:	89 04 24             	mov    %eax,(%esp)
f01037a6:	e8 c7 26 00 00       	call   f0105e72 <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037ab:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037ae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037b3:	77 20                	ja     f01037d5 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037b9:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f01037c0:	f0 
f01037c1:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
f01037c8:	00 
f01037c9:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f01037d0:	e8 6b c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037d5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01037db:	83 ca 05             	or     $0x5,%edx
f01037de:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01037e4:	8b 43 48             	mov    0x48(%ebx),%eax
f01037e7:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01037ec:	89 c1                	mov    %eax,%ecx
f01037ee:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f01037f4:	7f 05                	jg     f01037fb <env_alloc+0xd9>
		generation = 1 << ENVGENSHIFT;
f01037f6:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f01037fb:	89 d8                	mov    %ebx,%eax
f01037fd:	2b 05 48 12 2e f0    	sub    0xf02e1248,%eax
f0103803:	c1 f8 02             	sar    $0x2,%eax
f0103806:	89 c6                	mov    %eax,%esi
f0103808:	c1 e6 05             	shl    $0x5,%esi
f010380b:	89 c2                	mov    %eax,%edx
f010380d:	c1 e2 0a             	shl    $0xa,%edx
f0103810:	01 f2                	add    %esi,%edx
f0103812:	01 c2                	add    %eax,%edx
f0103814:	89 d6                	mov    %edx,%esi
f0103816:	c1 e6 0f             	shl    $0xf,%esi
f0103819:	01 f2                	add    %esi,%edx
f010381b:	c1 e2 05             	shl    $0x5,%edx
f010381e:	01 d0                	add    %edx,%eax
f0103820:	f7 d8                	neg    %eax
f0103822:	09 c1                	or     %eax,%ecx
f0103824:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103827:	8b 45 0c             	mov    0xc(%ebp),%eax
f010382a:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010382d:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103834:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010383b:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103842:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103849:	00 
f010384a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103851:	00 
f0103852:	89 1c 24             	mov    %ebx,(%esp)
f0103855:	e8 64 25 00 00       	call   f0105dbe <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010385a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103860:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103866:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010386c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103873:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103879:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103880:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103887:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010388b:	8b 43 44             	mov    0x44(%ebx),%eax
f010388e:	a3 4c 12 2e f0       	mov    %eax,0xf02e124c
	*newenv_store = e;
f0103893:	8b 45 08             	mov    0x8(%ebp),%eax
f0103896:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103898:	b8 00 00 00 00       	mov    $0x0,%eax
f010389d:	eb 0c                	jmp    f01038ab <env_alloc+0x189>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010389f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038a4:	eb 05                	jmp    f01038ab <env_alloc+0x189>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01038a6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01038ab:	83 c4 10             	add    $0x10,%esp
f01038ae:	5b                   	pop    %ebx
f01038af:	5e                   	pop    %esi
f01038b0:	5d                   	pop    %ebp
f01038b1:	c3                   	ret    

f01038b2 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01038b2:	55                   	push   %ebp
f01038b3:	89 e5                	mov    %esp,%ebp
f01038b5:	57                   	push   %edi
f01038b6:	56                   	push   %esi
f01038b7:	53                   	push   %ebx
f01038b8:	83 ec 3c             	sub    $0x3c,%esp
f01038bb:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	env_alloc(&env, 0);
f01038be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038c5:	00 
f01038c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01038c9:	89 04 24             	mov    %eax,(%esp)
f01038cc:	e8 51 fe ff ff       	call   f0103722 <env_alloc>
	load_icode(env, binary);
f01038d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
	ph = (struct Proghdr *)(binary + elf->e_phoff);
f01038d7:	89 fb                	mov    %edi,%ebx
f01038d9:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f01038dc:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01038e0:	c1 e6 05             	shl    $0x5,%esi
f01038e3:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f01038e5:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038e8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038ed:	77 20                	ja     f010390f <env_create+0x5d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038f3:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f01038fa:	f0 
f01038fb:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f0103902:	00 
f0103903:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f010390a:	e8 31 c7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010390f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103914:	0f 22 d8             	mov    %eax,%cr3
f0103917:	eb 50                	jmp    f0103969 <env_create+0xb7>
	for (; ph < eph; ph++)
	{
		if (ph->p_type == ELF_PROG_LOAD)
f0103919:	83 3b 01             	cmpl   $0x1,(%ebx)
f010391c:	75 48                	jne    f0103966 <env_create+0xb4>
		{
			region_alloc(e, (void*)(ph->p_va), ph->p_memsz);
f010391e:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103921:	8b 53 08             	mov    0x8(%ebx),%edx
f0103924:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103927:	e8 14 fc ff ff       	call   f0103540 <region_alloc>
			memcpy((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010392c:	8b 43 10             	mov    0x10(%ebx),%eax
f010392f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103933:	89 f8                	mov    %edi,%eax
f0103935:	03 43 04             	add    0x4(%ebx),%eax
f0103938:	89 44 24 04          	mov    %eax,0x4(%esp)
f010393c:	8b 43 08             	mov    0x8(%ebx),%eax
f010393f:	89 04 24             	mov    %eax,(%esp)
f0103942:	e8 2b 25 00 00       	call   f0105e72 <memcpy>
			memset((void*)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103947:	8b 43 10             	mov    0x10(%ebx),%eax
f010394a:	8b 53 14             	mov    0x14(%ebx),%edx
f010394d:	29 c2                	sub    %eax,%edx
f010394f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103953:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010395a:	00 
f010395b:	03 43 08             	add    0x8(%ebx),%eax
f010395e:	89 04 24             	mov    %eax,(%esp)
f0103961:	e8 58 24 00 00       	call   f0105dbe <memset>
	struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
	ph = (struct Proghdr *)(binary + elf->e_phoff);
	eph = ph + elf->e_phnum;
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++)
f0103966:	83 c3 20             	add    $0x20,%ebx
f0103969:	39 de                	cmp    %ebx,%esi
f010396b:	77 ac                	ja     f0103919 <env_create+0x67>
			memcpy((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
			memset((void*)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
		}
	}

	e->env_tf.tf_eip = (uintptr_t)elf->e_entry;
f010396d:	8b 47 18             	mov    0x18(%edi),%eax
f0103970:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103973:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f0103976:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010397b:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103980:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103983:	e8 b8 fb ff ff       	call   f0103540 <region_alloc>

	lcr3(PADDR(kern_pgdir));
f0103988:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010398d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103992:	77 20                	ja     f01039b4 <env_create+0x102>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103994:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103998:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f010399f:	f0 
f01039a0:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
f01039a7:	00 
f01039a8:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f01039af:	e8 8c c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039b4:	05 00 00 00 10       	add    $0x10000000,%eax
f01039b9:	0f 22 d8             	mov    %eax,%cr3
{
	// LAB 3: Your code here.
	struct Env *env;
	env_alloc(&env, 0);
	load_icode(env, binary);
	env->env_type = type;
f01039bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039bf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01039c2:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if (type == ENV_TYPE_FS){
f01039c5:	83 fa 01             	cmp    $0x1,%edx
f01039c8:	75 07                	jne    f01039d1 <env_create+0x11f>
		env->env_tf.tf_eflags |= FL_IOPL_3;
f01039ca:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f01039d1:	83 c4 3c             	add    $0x3c,%esp
f01039d4:	5b                   	pop    %ebx
f01039d5:	5e                   	pop    %esi
f01039d6:	5f                   	pop    %edi
f01039d7:	5d                   	pop    %ebp
f01039d8:	c3                   	ret    

f01039d9 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01039d9:	55                   	push   %ebp
f01039da:	89 e5                	mov    %esp,%ebp
f01039dc:	57                   	push   %edi
f01039dd:	56                   	push   %esi
f01039de:	53                   	push   %ebx
f01039df:	83 ec 2c             	sub    $0x2c,%esp
f01039e2:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01039e5:	e8 12 2a 00 00       	call   f01063fc <cpunum>
f01039ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01039f1:	29 c2                	sub    %eax,%edx
f01039f3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01039f6:	39 3c 85 28 20 2e f0 	cmp    %edi,-0xfd1dfd8(,%eax,4)
f01039fd:	75 3d                	jne    f0103a3c <env_free+0x63>
		lcr3(PADDR(kern_pgdir));
f01039ff:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a04:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a09:	77 20                	ja     f0103a2b <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a0f:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0103a16:	f0 
f0103a17:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
f0103a1e:	00 
f0103a1f:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f0103a26:	e8 15 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a2b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a30:	0f 22 d8             	mov    %eax,%cr3
f0103a33:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103a3a:	eb 07                	jmp    f0103a43 <env_free+0x6a>
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a3c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103a43:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a46:	c1 e0 02             	shl    $0x2,%eax
f0103a49:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103a4c:	8b 47 60             	mov    0x60(%edi),%eax
f0103a4f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a52:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103a55:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103a5b:	0f 84 b6 00 00 00    	je     f0103b17 <env_free+0x13e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103a61:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a67:	89 f0                	mov    %esi,%eax
f0103a69:	c1 e8 0c             	shr    $0xc,%eax
f0103a6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a6f:	3b 05 98 1e 2e f0    	cmp    0xf02e1e98,%eax
f0103a75:	72 20                	jb     f0103a97 <env_free+0xbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a77:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103a7b:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0103a82:	f0 
f0103a83:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
f0103a8a:	00 
f0103a8b:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f0103a92:	e8 a9 c5 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a97:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103a9a:	c1 e2 16             	shl    $0x16,%edx
f0103a9d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103aa0:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103aa5:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103aac:	01 
f0103aad:	74 17                	je     f0103ac6 <env_free+0xed>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103aaf:	89 d8                	mov    %ebx,%eax
f0103ab1:	c1 e0 0c             	shl    $0xc,%eax
f0103ab4:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103abb:	8b 47 60             	mov    0x60(%edi),%eax
f0103abe:	89 04 24             	mov    %eax,(%esp)
f0103ac1:	e8 be d7 ff ff       	call   f0101284 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ac6:	43                   	inc    %ebx
f0103ac7:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103acd:	75 d6                	jne    f0103aa5 <env_free+0xcc>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103acf:	8b 47 60             	mov    0x60(%edi),%eax
f0103ad2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ad5:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103adc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103adf:	3b 05 98 1e 2e f0    	cmp    0xf02e1e98,%eax
f0103ae5:	72 1c                	jb     f0103b03 <env_free+0x12a>
		panic("pa2page called with invalid pa");
f0103ae7:	c7 44 24 08 8c 7d 10 	movl   $0xf0107d8c,0x8(%esp)
f0103aee:	f0 
f0103aef:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103af6:	00 
f0103af7:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0103afe:	e8 3d c5 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103b03:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b06:	c1 e0 03             	shl    $0x3,%eax
f0103b09:	03 05 a0 1e 2e f0    	add    0xf02e1ea0,%eax
		page_decref(pa2page(pa));
f0103b0f:	89 04 24             	mov    %eax,(%esp)
f0103b12:	e8 98 d5 ff ff       	call   f01010af <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b17:	ff 45 e0             	incl   -0x20(%ebp)
f0103b1a:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103b21:	0f 85 1c ff ff ff    	jne    f0103a43 <env_free+0x6a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103b27:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b2a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b2f:	77 20                	ja     f0103b51 <env_free+0x178>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b31:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b35:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0103b3c:	f0 
f0103b3d:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f0103b44:	00 
f0103b45:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f0103b4c:	e8 ef c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103b51:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103b58:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b5d:	c1 e8 0c             	shr    $0xc,%eax
f0103b60:	3b 05 98 1e 2e f0    	cmp    0xf02e1e98,%eax
f0103b66:	72 1c                	jb     f0103b84 <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f0103b68:	c7 44 24 08 8c 7d 10 	movl   $0xf0107d8c,0x8(%esp)
f0103b6f:	f0 
f0103b70:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b77:	00 
f0103b78:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0103b7f:	e8 bc c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103b84:	c1 e0 03             	shl    $0x3,%eax
f0103b87:	03 05 a0 1e 2e f0    	add    0xf02e1ea0,%eax
	page_decref(pa2page(pa));
f0103b8d:	89 04 24             	mov    %eax,(%esp)
f0103b90:	e8 1a d5 ff ff       	call   f01010af <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103b95:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103b9c:	a1 4c 12 2e f0       	mov    0xf02e124c,%eax
f0103ba1:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103ba4:	89 3d 4c 12 2e f0    	mov    %edi,0xf02e124c
}
f0103baa:	83 c4 2c             	add    $0x2c,%esp
f0103bad:	5b                   	pop    %ebx
f0103bae:	5e                   	pop    %esi
f0103baf:	5f                   	pop    %edi
f0103bb0:	5d                   	pop    %ebp
f0103bb1:	c3                   	ret    

f0103bb2 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103bb2:	55                   	push   %ebp
f0103bb3:	89 e5                	mov    %esp,%ebp
f0103bb5:	53                   	push   %ebx
f0103bb6:	83 ec 14             	sub    $0x14,%esp
f0103bb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103bbc:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103bc0:	75 23                	jne    f0103be5 <env_destroy+0x33>
f0103bc2:	e8 35 28 00 00       	call   f01063fc <cpunum>
f0103bc7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bce:	29 c2                	sub    %eax,%edx
f0103bd0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bd3:	39 1c 85 28 20 2e f0 	cmp    %ebx,-0xfd1dfd8(,%eax,4)
f0103bda:	74 09                	je     f0103be5 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103bdc:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103be3:	eb 39                	jmp    f0103c1e <env_destroy+0x6c>
	}

	env_free(e);
f0103be5:	89 1c 24             	mov    %ebx,(%esp)
f0103be8:	e8 ec fd ff ff       	call   f01039d9 <env_free>

	if (curenv == e) {
f0103bed:	e8 0a 28 00 00       	call   f01063fc <cpunum>
f0103bf2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bf9:	29 c2                	sub    %eax,%edx
f0103bfb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bfe:	39 1c 85 28 20 2e f0 	cmp    %ebx,-0xfd1dfd8(,%eax,4)
f0103c05:	75 17                	jne    f0103c1e <env_destroy+0x6c>
		curenv = NULL;
f0103c07:	e8 f0 27 00 00       	call   f01063fc <cpunum>
f0103c0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c0f:	c7 80 28 20 2e f0 00 	movl   $0x0,-0xfd1dfd8(%eax)
f0103c16:	00 00 00 
		sched_yield();
f0103c19:	e8 d4 0e 00 00       	call   f0104af2 <sched_yield>
	}
}
f0103c1e:	83 c4 14             	add    $0x14,%esp
f0103c21:	5b                   	pop    %ebx
f0103c22:	5d                   	pop    %ebp
f0103c23:	c3                   	ret    

f0103c24 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103c24:	55                   	push   %ebp
f0103c25:	89 e5                	mov    %esp,%ebp
f0103c27:	53                   	push   %ebx
f0103c28:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103c2b:	e8 cc 27 00 00       	call   f01063fc <cpunum>
f0103c30:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c37:	29 c2                	sub    %eax,%edx
f0103c39:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c3c:	8b 1c 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%ebx
f0103c43:	e8 b4 27 00 00       	call   f01063fc <cpunum>
f0103c48:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103c4b:	8b 65 08             	mov    0x8(%ebp),%esp
f0103c4e:	61                   	popa   
f0103c4f:	07                   	pop    %es
f0103c50:	1f                   	pop    %ds
f0103c51:	83 c4 08             	add    $0x8,%esp
f0103c54:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103c55:	c7 44 24 08 51 89 10 	movl   $0xf0108951,0x8(%esp)
f0103c5c:	f0 
f0103c5d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
f0103c64:	00 
f0103c65:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f0103c6c:	e8 cf c3 ff ff       	call   f0100040 <_panic>

f0103c71 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c71:	55                   	push   %ebp
f0103c72:	89 e5                	mov    %esp,%ebp
f0103c74:	53                   	push   %ebx
f0103c75:	83 ec 14             	sub    $0x14,%esp
f0103c78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103c7b:	e8 7c 27 00 00       	call   f01063fc <cpunum>
f0103c80:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c87:	29 c2                	sub    %eax,%edx
f0103c89:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c8c:	83 3c 85 28 20 2e f0 	cmpl   $0x0,-0xfd1dfd8(,%eax,4)
f0103c93:	00 
f0103c94:	74 33                	je     f0103cc9 <env_run+0x58>
f0103c96:	e8 61 27 00 00       	call   f01063fc <cpunum>
f0103c9b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ca2:	29 c2                	sub    %eax,%edx
f0103ca4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ca7:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0103cae:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103cb2:	75 15                	jne    f0103cc9 <env_run+0x58>
	{
		curenv->env_status = ENV_RUNNABLE;
f0103cb4:	e8 43 27 00 00       	call   f01063fc <cpunum>
f0103cb9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbc:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f0103cc2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;
f0103cc9:	e8 2e 27 00 00       	call   f01063fc <cpunum>
f0103cce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cd5:	29 c2                	sub    %eax,%edx
f0103cd7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cda:	89 1c 85 28 20 2e f0 	mov    %ebx,-0xfd1dfd8(,%eax,4)
	e->env_status = ENV_RUNNING;
f0103ce1:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103ce8:	ff 43 58             	incl   0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f0103ceb:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cf3:	77 20                	ja     f0103d15 <env_run+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cf5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cf9:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0103d00:	f0 
f0103d01:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
f0103d08:	00 
f0103d09:	c7 04 24 46 89 10 f0 	movl   $0xf0108946,(%esp)
f0103d10:	e8 2b c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d15:	05 00 00 00 10       	add    $0x10000000,%eax
f0103d1a:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103d1d:	c7 04 24 a0 c4 12 f0 	movl   $0xf012c4a0,(%esp)
f0103d24:	e8 9d 2a 00 00       	call   f01067c6 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103d29:	f3 90                	pause  

	unlock_kernel();

	env_pop_tf(&e->env_tf);
f0103d2b:	89 1c 24             	mov    %ebx,(%esp)
f0103d2e:	e8 f1 fe ff ff       	call   f0103c24 <env_pop_tf>
	...

f0103d34 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103d34:	55                   	push   %ebp
f0103d35:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d37:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d3f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103d40:	b2 71                	mov    $0x71,%dl
f0103d42:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103d43:	0f b6 c0             	movzbl %al,%eax
}
f0103d46:	5d                   	pop    %ebp
f0103d47:	c3                   	ret    

f0103d48 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103d48:	55                   	push   %ebp
f0103d49:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d4b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d50:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d53:	ee                   	out    %al,(%dx)
f0103d54:	b2 71                	mov    $0x71,%dl
f0103d56:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d59:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103d5a:	5d                   	pop    %ebp
f0103d5b:	c3                   	ret    

f0103d5c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103d5c:	55                   	push   %ebp
f0103d5d:	89 e5                	mov    %esp,%ebp
f0103d5f:	56                   	push   %esi
f0103d60:	53                   	push   %ebx
f0103d61:	83 ec 10             	sub    $0x10,%esp
f0103d64:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d67:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103d69:	66 a3 a8 c3 12 f0    	mov    %ax,0xf012c3a8
	if (!didinit)
f0103d6f:	80 3d 50 12 2e f0 00 	cmpb   $0x0,0xf02e1250
f0103d76:	74 51                	je     f0103dc9 <irq_setmask_8259A+0x6d>
f0103d78:	ba 21 00 00 00       	mov    $0x21,%edx
f0103d7d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103d7e:	89 f0                	mov    %esi,%eax
f0103d80:	66 c1 e8 08          	shr    $0x8,%ax
f0103d84:	b2 a1                	mov    $0xa1,%dl
f0103d86:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103d87:	c7 04 24 5d 89 10 f0 	movl   $0xf010895d,(%esp)
f0103d8e:	e8 f7 00 00 00       	call   f0103e8a <cprintf>
	for (i = 0; i < 16; i++)
f0103d93:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103d98:	0f b7 f6             	movzwl %si,%esi
f0103d9b:	f7 d6                	not    %esi
f0103d9d:	89 f0                	mov    %esi,%eax
f0103d9f:	88 d9                	mov    %bl,%cl
f0103da1:	d3 f8                	sar    %cl,%eax
f0103da3:	a8 01                	test   $0x1,%al
f0103da5:	74 10                	je     f0103db7 <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f0103da7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103dab:	c7 04 24 27 8e 10 f0 	movl   $0xf0108e27,(%esp)
f0103db2:	e8 d3 00 00 00       	call   f0103e8a <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103db7:	43                   	inc    %ebx
f0103db8:	83 fb 10             	cmp    $0x10,%ebx
f0103dbb:	75 e0                	jne    f0103d9d <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103dbd:	c7 04 24 f7 88 10 f0 	movl   $0xf01088f7,(%esp)
f0103dc4:	e8 c1 00 00 00       	call   f0103e8a <cprintf>
}
f0103dc9:	83 c4 10             	add    $0x10,%esp
f0103dcc:	5b                   	pop    %ebx
f0103dcd:	5e                   	pop    %esi
f0103dce:	5d                   	pop    %ebp
f0103dcf:	c3                   	ret    

f0103dd0 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103dd0:	55                   	push   %ebp
f0103dd1:	89 e5                	mov    %esp,%ebp
f0103dd3:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103dd6:	c6 05 50 12 2e f0 01 	movb   $0x1,0xf02e1250
f0103ddd:	ba 21 00 00 00       	mov    $0x21,%edx
f0103de2:	b0 ff                	mov    $0xff,%al
f0103de4:	ee                   	out    %al,(%dx)
f0103de5:	b2 a1                	mov    $0xa1,%dl
f0103de7:	ee                   	out    %al,(%dx)
f0103de8:	b2 20                	mov    $0x20,%dl
f0103dea:	b0 11                	mov    $0x11,%al
f0103dec:	ee                   	out    %al,(%dx)
f0103ded:	b2 21                	mov    $0x21,%dl
f0103def:	b0 20                	mov    $0x20,%al
f0103df1:	ee                   	out    %al,(%dx)
f0103df2:	b0 04                	mov    $0x4,%al
f0103df4:	ee                   	out    %al,(%dx)
f0103df5:	b0 03                	mov    $0x3,%al
f0103df7:	ee                   	out    %al,(%dx)
f0103df8:	b2 a0                	mov    $0xa0,%dl
f0103dfa:	b0 11                	mov    $0x11,%al
f0103dfc:	ee                   	out    %al,(%dx)
f0103dfd:	b2 a1                	mov    $0xa1,%dl
f0103dff:	b0 28                	mov    $0x28,%al
f0103e01:	ee                   	out    %al,(%dx)
f0103e02:	b0 02                	mov    $0x2,%al
f0103e04:	ee                   	out    %al,(%dx)
f0103e05:	b0 01                	mov    $0x1,%al
f0103e07:	ee                   	out    %al,(%dx)
f0103e08:	b2 20                	mov    $0x20,%dl
f0103e0a:	b0 68                	mov    $0x68,%al
f0103e0c:	ee                   	out    %al,(%dx)
f0103e0d:	b0 0a                	mov    $0xa,%al
f0103e0f:	ee                   	out    %al,(%dx)
f0103e10:	b2 a0                	mov    $0xa0,%dl
f0103e12:	b0 68                	mov    $0x68,%al
f0103e14:	ee                   	out    %al,(%dx)
f0103e15:	b0 0a                	mov    $0xa,%al
f0103e17:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103e18:	66 a1 a8 c3 12 f0    	mov    0xf012c3a8,%ax
f0103e1e:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103e22:	74 0b                	je     f0103e2f <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0103e24:	0f b7 c0             	movzwl %ax,%eax
f0103e27:	89 04 24             	mov    %eax,(%esp)
f0103e2a:	e8 2d ff ff ff       	call   f0103d5c <irq_setmask_8259A>
}
f0103e2f:	c9                   	leave  
f0103e30:	c3                   	ret    

f0103e31 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0103e31:	55                   	push   %ebp
f0103e32:	89 e5                	mov    %esp,%ebp
f0103e34:	ba 20 00 00 00       	mov    $0x20,%edx
f0103e39:	b0 20                	mov    $0x20,%al
f0103e3b:	ee                   	out    %al,(%dx)
f0103e3c:	b2 a0                	mov    $0xa0,%dl
f0103e3e:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0103e3f:	5d                   	pop    %ebp
f0103e40:	c3                   	ret    
f0103e41:	00 00                	add    %al,(%eax)
	...

f0103e44 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103e44:	55                   	push   %ebp
f0103e45:	89 e5                	mov    %esp,%ebp
f0103e47:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103e4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e4d:	89 04 24             	mov    %eax,(%esp)
f0103e50:	e8 55 c9 ff ff       	call   f01007aa <cputchar>
	*cnt++;
}
f0103e55:	c9                   	leave  
f0103e56:	c3                   	ret    

f0103e57 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103e57:	55                   	push   %ebp
f0103e58:	89 e5                	mov    %esp,%ebp
f0103e5a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103e5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103e64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e67:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e6e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103e75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e79:	c7 04 24 44 3e 10 f0 	movl   $0xf0103e44,(%esp)
f0103e80:	e8 e9 18 00 00       	call   f010576e <vprintfmt>
	return cnt;
}
f0103e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e88:	c9                   	leave  
f0103e89:	c3                   	ret    

f0103e8a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103e8a:	55                   	push   %ebp
f0103e8b:	89 e5                	mov    %esp,%ebp
f0103e8d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103e90:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103e93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e97:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e9a:	89 04 24             	mov    %eax,(%esp)
f0103e9d:	e8 b5 ff ff ff       	call   f0103e57 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ea2:	c9                   	leave  
f0103ea3:	c3                   	ret    

f0103ea4 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103ea4:	55                   	push   %ebp
f0103ea5:	89 e5                	mov    %esp,%ebp
f0103ea7:	57                   	push   %edi
f0103ea8:	56                   	push   %esi
f0103ea9:	53                   	push   %ebx
f0103eaa:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - thiscpu->cpu_id * (KSTKSIZE + KSTKGAP);
f0103ead:	e8 4a 25 00 00       	call   f01063fc <cpunum>
f0103eb2:	89 c3                	mov    %eax,%ebx
f0103eb4:	e8 43 25 00 00       	call   f01063fc <cpunum>
f0103eb9:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0103ec0:	29 da                	sub    %ebx,%edx
f0103ec2:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0103ec5:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0103ecc:	29 c1                	sub    %eax,%ecx
f0103ece:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0103ed1:	0f b6 04 85 20 20 2e 	movzbl -0xfd1dfe0(,%eax,4),%eax
f0103ed8:	f0 
f0103ed9:	f7 d8                	neg    %eax
f0103edb:	c1 e0 10             	shl    $0x10,%eax
f0103ede:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103ee3:	89 04 95 30 20 2e f0 	mov    %eax,-0xfd1dfd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103eea:	e8 0d 25 00 00       	call   f01063fc <cpunum>
f0103eef:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ef6:	29 c2                	sub    %eax,%edx
f0103ef8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103efb:	66 c7 04 85 34 20 2e 	movw   $0x10,-0xfd1dfcc(,%eax,4)
f0103f02:	f0 10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103f05:	e8 f2 24 00 00       	call   f01063fc <cpunum>
f0103f0a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f11:	29 c2                	sub    %eax,%edx
f0103f13:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f16:	66 c7 04 85 92 20 2e 	movw   $0x68,-0xfd1df6e(,%eax,4)
f0103f1d:	f0 68 00 

	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t)(&thiscpu->cpu_ts),
f0103f20:	e8 d7 24 00 00       	call   f01063fc <cpunum>
f0103f25:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f2c:	29 c2                	sub    %eax,%edx
f0103f2e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f31:	0f b6 1c 85 20 20 2e 	movzbl -0xfd1dfe0(,%eax,4),%ebx
f0103f38:	f0 
f0103f39:	83 c3 05             	add    $0x5,%ebx
f0103f3c:	e8 bb 24 00 00       	call   f01063fc <cpunum>
f0103f41:	89 c6                	mov    %eax,%esi
f0103f43:	e8 b4 24 00 00       	call   f01063fc <cpunum>
f0103f48:	89 c7                	mov    %eax,%edi
f0103f4a:	e8 ad 24 00 00       	call   f01063fc <cpunum>
f0103f4f:	66 c7 04 dd 40 c3 12 	movw   $0x67,-0xfed3cc0(,%ebx,8)
f0103f56:	f0 67 00 
f0103f59:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0103f60:	29 f2                	sub    %esi,%edx
f0103f62:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103f65:	8d 14 95 2c 20 2e f0 	lea    -0xfd1dfd4(,%edx,4),%edx
f0103f6c:	66 89 14 dd 42 c3 12 	mov    %dx,-0xfed3cbe(,%ebx,8)
f0103f73:	f0 
f0103f74:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103f7b:	29 fa                	sub    %edi,%edx
f0103f7d:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103f80:	8d 14 95 2c 20 2e f0 	lea    -0xfd1dfd4(,%edx,4),%edx
f0103f87:	c1 ea 10             	shr    $0x10,%edx
f0103f8a:	88 14 dd 44 c3 12 f0 	mov    %dl,-0xfed3cbc(,%ebx,8)
f0103f91:	c6 04 dd 45 c3 12 f0 	movb   $0x99,-0xfed3cbb(,%ebx,8)
f0103f98:	99 
f0103f99:	c6 04 dd 46 c3 12 f0 	movb   $0x40,-0xfed3cba(,%ebx,8)
f0103fa0:	40 
f0103fa1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fa8:	29 c2                	sub    %eax,%edx
f0103faa:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fad:	8d 04 85 2c 20 2e f0 	lea    -0xfd1dfd4(,%eax,4),%eax
f0103fb4:	c1 e8 18             	shr    $0x18,%eax
f0103fb7:	88 04 dd 47 c3 12 f0 	mov    %al,-0xfed3cb9(,%ebx,8)
												sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0103fbe:	e8 39 24 00 00       	call   f01063fc <cpunum>
f0103fc3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fca:	29 c2                	sub    %eax,%edx
f0103fcc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fcf:	0f b6 04 85 20 20 2e 	movzbl -0xfd1dfe0(,%eax,4),%eax
f0103fd6:	f0 
f0103fd7:	80 24 c5 6d c3 12 f0 	andb   $0xef,-0xfed3c93(,%eax,8)
f0103fde:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	// thiscpu->cpu_ts.ts_ss0 = GD_TSS0;
	// ltr(thiscpu->cpu_ts.ts_ss0);
	ltr(GD_TSS0 + (thiscpu->cpu_id << 3));
f0103fdf:	e8 18 24 00 00       	call   f01063fc <cpunum>
f0103fe4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103feb:	29 c2                	sub    %eax,%edx
f0103fed:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ff0:	0f b6 04 85 20 20 2e 	movzbl -0xfd1dfe0(,%eax,4),%eax
f0103ff7:	f0 
f0103ff8:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103fff:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0104002:	b8 ac c3 12 f0       	mov    $0xf012c3ac,%eax
f0104007:	0f 01 18             	lidtl  (%eax)
	// Load the IDT
	lidt(&idt_pd);
}
f010400a:	83 c4 0c             	add    $0xc,%esp
f010400d:	5b                   	pop    %ebx
f010400e:	5e                   	pop    %esi
f010400f:	5f                   	pop    %edi
f0104010:	5d                   	pop    %ebp
f0104011:	c3                   	ret    

f0104012 <trap_init>:
}


void
trap_init(void)
{
f0104012:	55                   	push   %ebp
f0104013:	89 e5                	mov    %esp,%ebp
f0104015:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	for (int i = 0; i < 52; ++i)
f0104018:	b8 00 00 00 00       	mov    $0x0,%eax
	{
		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f010401d:	8b 14 85 b4 c3 12 f0 	mov    -0xfed3c4c(,%eax,4),%edx
f0104024:	66 89 14 c5 60 12 2e 	mov    %dx,-0xfd1eda0(,%eax,8)
f010402b:	f0 
f010402c:	66 c7 04 c5 62 12 2e 	movw   $0x8,-0xfd1ed9e(,%eax,8)
f0104033:	f0 08 00 
f0104036:	c6 04 c5 64 12 2e f0 	movb   $0x0,-0xfd1ed9c(,%eax,8)
f010403d:	00 
f010403e:	c6 04 c5 65 12 2e f0 	movb   $0x8e,-0xfd1ed9b(,%eax,8)
f0104045:	8e 
f0104046:	c1 ea 10             	shr    $0x10,%edx
f0104049:	66 89 14 c5 66 12 2e 	mov    %dx,-0xfd1ed9a(,%eax,8)
f0104050:	f0 
trap_init(void)
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	for (int i = 0; i < 52; ++i)
f0104051:	40                   	inc    %eax
f0104052:	83 f8 34             	cmp    $0x34,%eax
f0104055:	75 c6                	jne    f010401d <trap_init+0xb>
		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
	}
	//for (int i = 32; i < 52; ++i){
	//	SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
	//}
	SETGATE(idt[T_SYSCALL], 0, GD_KT, vectors[T_SYSCALL], 3);	
f0104057:	a1 74 c4 12 f0       	mov    0xf012c474,%eax
f010405c:	66 a3 e0 13 2e f0    	mov    %ax,0xf02e13e0
f0104062:	66 c7 05 e2 13 2e f0 	movw   $0x8,0xf02e13e2
f0104069:	08 00 
f010406b:	c6 05 e4 13 2e f0 00 	movb   $0x0,0xf02e13e4
f0104072:	c6 05 e5 13 2e f0 ee 	movb   $0xee,0xf02e13e5
f0104079:	c1 e8 10             	shr    $0x10,%eax
f010407c:	66 a3 e6 13 2e f0    	mov    %ax,0xf02e13e6
	SETGATE(idt[T_BRKPT], 0, GD_KT, vectors[T_BRKPT], 3);
f0104082:	a1 c0 c3 12 f0       	mov    0xf012c3c0,%eax
f0104087:	66 a3 78 12 2e f0    	mov    %ax,0xf02e1278
f010408d:	66 c7 05 7a 12 2e f0 	movw   $0x8,0xf02e127a
f0104094:	08 00 
f0104096:	c6 05 7c 12 2e f0 00 	movb   $0x0,0xf02e127c
f010409d:	c6 05 7d 12 2e f0 ee 	movb   $0xee,0xf02e127d
f01040a4:	c1 e8 10             	shr    $0x10,%eax
f01040a7:	66 a3 7e 12 2e f0    	mov    %ax,0xf02e127e
	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, irq_14_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, irq_15_handler, 0);
	*/
	
	// Per-CPU setup 
	trap_init_percpu();
f01040ad:	e8 f2 fd ff ff       	call   f0103ea4 <trap_init_percpu>
}
f01040b2:	c9                   	leave  
f01040b3:	c3                   	ret    

f01040b4 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01040b4:	55                   	push   %ebp
f01040b5:	89 e5                	mov    %esp,%ebp
f01040b7:	53                   	push   %ebx
f01040b8:	83 ec 14             	sub    $0x14,%esp
f01040bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01040be:	8b 03                	mov    (%ebx),%eax
f01040c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040c4:	c7 04 24 71 89 10 f0 	movl   $0xf0108971,(%esp)
f01040cb:	e8 ba fd ff ff       	call   f0103e8a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01040d0:	8b 43 04             	mov    0x4(%ebx),%eax
f01040d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040d7:	c7 04 24 80 89 10 f0 	movl   $0xf0108980,(%esp)
f01040de:	e8 a7 fd ff ff       	call   f0103e8a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01040e3:	8b 43 08             	mov    0x8(%ebx),%eax
f01040e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040ea:	c7 04 24 8f 89 10 f0 	movl   $0xf010898f,(%esp)
f01040f1:	e8 94 fd ff ff       	call   f0103e8a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01040f6:	8b 43 0c             	mov    0xc(%ebx),%eax
f01040f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040fd:	c7 04 24 9e 89 10 f0 	movl   $0xf010899e,(%esp)
f0104104:	e8 81 fd ff ff       	call   f0103e8a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104109:	8b 43 10             	mov    0x10(%ebx),%eax
f010410c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104110:	c7 04 24 ad 89 10 f0 	movl   $0xf01089ad,(%esp)
f0104117:	e8 6e fd ff ff       	call   f0103e8a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010411c:	8b 43 14             	mov    0x14(%ebx),%eax
f010411f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104123:	c7 04 24 bc 89 10 f0 	movl   $0xf01089bc,(%esp)
f010412a:	e8 5b fd ff ff       	call   f0103e8a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010412f:	8b 43 18             	mov    0x18(%ebx),%eax
f0104132:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104136:	c7 04 24 cb 89 10 f0 	movl   $0xf01089cb,(%esp)
f010413d:	e8 48 fd ff ff       	call   f0103e8a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104142:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104145:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104149:	c7 04 24 da 89 10 f0 	movl   $0xf01089da,(%esp)
f0104150:	e8 35 fd ff ff       	call   f0103e8a <cprintf>
}
f0104155:	83 c4 14             	add    $0x14,%esp
f0104158:	5b                   	pop    %ebx
f0104159:	5d                   	pop    %ebp
f010415a:	c3                   	ret    

f010415b <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010415b:	55                   	push   %ebp
f010415c:	89 e5                	mov    %esp,%ebp
f010415e:	53                   	push   %ebx
f010415f:	83 ec 14             	sub    $0x14,%esp
f0104162:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104165:	e8 92 22 00 00       	call   f01063fc <cpunum>
f010416a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010416e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104172:	c7 04 24 3e 8a 10 f0 	movl   $0xf0108a3e,(%esp)
f0104179:	e8 0c fd ff ff       	call   f0103e8a <cprintf>
	print_regs(&tf->tf_regs);
f010417e:	89 1c 24             	mov    %ebx,(%esp)
f0104181:	e8 2e ff ff ff       	call   f01040b4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104186:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010418a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010418e:	c7 04 24 5c 8a 10 f0 	movl   $0xf0108a5c,(%esp)
f0104195:	e8 f0 fc ff ff       	call   f0103e8a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010419a:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010419e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041a2:	c7 04 24 6f 8a 10 f0 	movl   $0xf0108a6f,(%esp)
f01041a9:	e8 dc fc ff ff       	call   f0103e8a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01041ae:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01041b1:	83 f8 13             	cmp    $0x13,%eax
f01041b4:	77 09                	ja     f01041bf <print_trapframe+0x64>
		return excnames[trapno];
f01041b6:	8b 14 85 00 8d 10 f0 	mov    -0xfef7300(,%eax,4),%edx
f01041bd:	eb 20                	jmp    f01041df <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01041bf:	83 f8 30             	cmp    $0x30,%eax
f01041c2:	74 0f                	je     f01041d3 <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01041c4:	8d 50 e0             	lea    -0x20(%eax),%edx
f01041c7:	83 fa 0f             	cmp    $0xf,%edx
f01041ca:	77 0e                	ja     f01041da <print_trapframe+0x7f>
		return "Hardware Interrupt";
f01041cc:	ba f5 89 10 f0       	mov    $0xf01089f5,%edx
f01041d1:	eb 0c                	jmp    f01041df <print_trapframe+0x84>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01041d3:	ba e9 89 10 f0       	mov    $0xf01089e9,%edx
f01041d8:	eb 05                	jmp    f01041df <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01041da:	ba 08 8a 10 f0       	mov    $0xf0108a08,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01041df:	89 54 24 08          	mov    %edx,0x8(%esp)
f01041e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041e7:	c7 04 24 82 8a 10 f0 	movl   $0xf0108a82,(%esp)
f01041ee:	e8 97 fc ff ff       	call   f0103e8a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01041f3:	3b 1d 60 1a 2e f0    	cmp    0xf02e1a60,%ebx
f01041f9:	75 19                	jne    f0104214 <print_trapframe+0xb9>
f01041fb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01041ff:	75 13                	jne    f0104214 <print_trapframe+0xb9>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104201:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104204:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104208:	c7 04 24 94 8a 10 f0 	movl   $0xf0108a94,(%esp)
f010420f:	e8 76 fc ff ff       	call   f0103e8a <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104214:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104217:	89 44 24 04          	mov    %eax,0x4(%esp)
f010421b:	c7 04 24 a3 8a 10 f0 	movl   $0xf0108aa3,(%esp)
f0104222:	e8 63 fc ff ff       	call   f0103e8a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104227:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010422b:	75 4d                	jne    f010427a <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010422d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104230:	a8 01                	test   $0x1,%al
f0104232:	74 07                	je     f010423b <print_trapframe+0xe0>
f0104234:	b9 17 8a 10 f0       	mov    $0xf0108a17,%ecx
f0104239:	eb 05                	jmp    f0104240 <print_trapframe+0xe5>
f010423b:	b9 22 8a 10 f0       	mov    $0xf0108a22,%ecx
f0104240:	a8 02                	test   $0x2,%al
f0104242:	74 07                	je     f010424b <print_trapframe+0xf0>
f0104244:	ba 2e 8a 10 f0       	mov    $0xf0108a2e,%edx
f0104249:	eb 05                	jmp    f0104250 <print_trapframe+0xf5>
f010424b:	ba 34 8a 10 f0       	mov    $0xf0108a34,%edx
f0104250:	a8 04                	test   $0x4,%al
f0104252:	74 07                	je     f010425b <print_trapframe+0x100>
f0104254:	b8 39 8a 10 f0       	mov    $0xf0108a39,%eax
f0104259:	eb 05                	jmp    f0104260 <print_trapframe+0x105>
f010425b:	b8 92 8b 10 f0       	mov    $0xf0108b92,%eax
f0104260:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104264:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104268:	89 44 24 04          	mov    %eax,0x4(%esp)
f010426c:	c7 04 24 b1 8a 10 f0 	movl   $0xf0108ab1,(%esp)
f0104273:	e8 12 fc ff ff       	call   f0103e8a <cprintf>
f0104278:	eb 0c                	jmp    f0104286 <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010427a:	c7 04 24 f7 88 10 f0 	movl   $0xf01088f7,(%esp)
f0104281:	e8 04 fc ff ff       	call   f0103e8a <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104286:	8b 43 30             	mov    0x30(%ebx),%eax
f0104289:	89 44 24 04          	mov    %eax,0x4(%esp)
f010428d:	c7 04 24 c0 8a 10 f0 	movl   $0xf0108ac0,(%esp)
f0104294:	e8 f1 fb ff ff       	call   f0103e8a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104299:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010429d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042a1:	c7 04 24 cf 8a 10 f0 	movl   $0xf0108acf,(%esp)
f01042a8:	e8 dd fb ff ff       	call   f0103e8a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01042ad:	8b 43 38             	mov    0x38(%ebx),%eax
f01042b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042b4:	c7 04 24 e2 8a 10 f0 	movl   $0xf0108ae2,(%esp)
f01042bb:	e8 ca fb ff ff       	call   f0103e8a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01042c0:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01042c4:	74 27                	je     f01042ed <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01042c6:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01042c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042cd:	c7 04 24 f1 8a 10 f0 	movl   $0xf0108af1,(%esp)
f01042d4:	e8 b1 fb ff ff       	call   f0103e8a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01042d9:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01042dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042e1:	c7 04 24 00 8b 10 f0 	movl   $0xf0108b00,(%esp)
f01042e8:	e8 9d fb ff ff       	call   f0103e8a <cprintf>
	}
}
f01042ed:	83 c4 14             	add    $0x14,%esp
f01042f0:	5b                   	pop    %ebx
f01042f1:	5d                   	pop    %ebp
f01042f2:	c3                   	ret    

f01042f3 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01042f3:	55                   	push   %ebp
f01042f4:	89 e5                	mov    %esp,%ebp
f01042f6:	57                   	push   %edi
f01042f7:	56                   	push   %esi
f01042f8:	53                   	push   %ebx
f01042f9:	83 ec 2c             	sub    $0x2c,%esp
f01042fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01042ff:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) != 3)
f0104302:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104306:	83 e0 03             	and    $0x3,%eax
f0104309:	83 f8 03             	cmp    $0x3,%eax
f010430c:	74 1c                	je     f010432a <page_fault_handler+0x37>
	{
		panic("kernel page fault\n");
f010430e:	c7 44 24 08 13 8b 10 	movl   $0xf0108b13,0x8(%esp)
f0104315:	f0 
f0104316:	c7 44 24 04 a6 01 00 	movl   $0x1a6,0x4(%esp)
f010431d:	00 
f010431e:	c7 04 24 26 8b 10 f0 	movl   $0xf0108b26,(%esp)
f0104325:	e8 16 bd ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall)
f010432a:	e8 cd 20 00 00       	call   f01063fc <cpunum>
f010432f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104336:	29 c2                	sub    %eax,%edx
f0104338:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010433b:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0104342:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104346:	0f 84 e1 00 00 00    	je     f010442d <page_fault_handler+0x13a>
	{
		// cprintf("!!!!we are here, not null\n");
		struct UTrapframe *utf;
		if (!(tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE))
f010434c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010434f:	05 00 10 40 11       	add    $0x11401000,%eax
		{	
			// cprintf("first fault\n");
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f0104354:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall)
	{
		// cprintf("!!!!we are here, not null\n");
		struct UTrapframe *utf;
		if (!(tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE))
f010435b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0104360:	77 15                	ja     f0104377 <page_fault_handler+0x84>
			// cprintf("first fault\n");
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		}
		else
		{
			cprintf("recursive fault\n");
f0104362:	c7 04 24 32 8b 10 f0 	movl   $0xf0108b32,(%esp)
f0104369:	e8 1c fb ff ff       	call   f0103e8a <cprintf>
			utf = (struct UTrapframe *)(tf->tf_esp - 4 - sizeof(struct UTrapframe));
f010436e:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104371:	83 e8 38             	sub    $0x38,%eax
f0104374:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		}
		user_mem_assert(curenv, utf, sizeof(struct UTrapframe), PTE_W);
f0104377:	e8 80 20 00 00       	call   f01063fc <cpunum>
f010437c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104383:	00 
f0104384:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f010438b:	00 
f010438c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010438f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104393:	6b c0 74             	imul   $0x74,%eax,%eax
f0104396:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f010439c:	89 04 24             	mov    %eax,(%esp)
f010439f:	e8 43 f1 ff ff       	call   f01034e7 <user_mem_assert>
		
		// cprintf("fault addr %x\n",fault_va);
		utf->utf_fault_va = fault_va;
f01043a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043a7:	89 30                	mov    %esi,(%eax)
		utf->utf_err = tf->tf_err;
f01043a9:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01043ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01043af:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs = tf->tf_regs;
f01043b2:	89 d7                	mov    %edx,%edi
f01043b4:	83 c7 08             	add    $0x8,%edi
f01043b7:	89 de                	mov    %ebx,%esi
f01043b9:	b8 20 00 00 00       	mov    $0x20,%eax
f01043be:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01043c4:	74 03                	je     f01043c9 <page_fault_handler+0xd6>
f01043c6:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01043c7:	b0 1f                	mov    $0x1f,%al
f01043c9:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01043cf:	74 05                	je     f01043d6 <page_fault_handler+0xe3>
f01043d1:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01043d3:	83 e8 02             	sub    $0x2,%eax
f01043d6:	89 c1                	mov    %eax,%ecx
f01043d8:	c1 e9 02             	shr    $0x2,%ecx
f01043db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01043dd:	a8 02                	test   $0x2,%al
f01043df:	74 02                	je     f01043e3 <page_fault_handler+0xf0>
f01043e1:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01043e3:	a8 01                	test   $0x1,%al
f01043e5:	74 01                	je     f01043e8 <page_fault_handler+0xf5>
f01043e7:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_eflags = tf->tf_eflags;
f01043e8:	8b 43 38             	mov    0x38(%ebx),%eax
f01043eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01043ee:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01043f1:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01043f4:	89 42 30             	mov    %eax,0x30(%edx)
		utf->utf_eip = tf->tf_eip;
f01043f7:	8b 43 30             	mov    0x30(%ebx),%eax
f01043fa:	89 42 28             	mov    %eax,0x28(%edx)

		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f01043fd:	e8 fa 1f 00 00       	call   f01063fc <cpunum>
f0104402:	6b c0 74             	imul   $0x74,%eax,%eax
f0104405:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f010440b:	8b 40 64             	mov    0x64(%eax),%eax
f010440e:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uint32_t)utf;
f0104411:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104414:	89 43 3c             	mov    %eax,0x3c(%ebx)
		env_run(curenv);
f0104417:	e8 e0 1f 00 00       	call   f01063fc <cpunum>
f010441c:	6b c0 74             	imul   $0x74,%eax,%eax
f010441f:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f0104425:	89 04 24             	mov    %eax,(%esp)
f0104428:	e8 44 f8 ff ff       	call   f0103c71 <env_run>
	}
	// cprintf("!!!!!!!!!!!!!!!!!!!!!null\n");
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010442d:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104430:	e8 c7 1f 00 00       	call   f01063fc <cpunum>
		tf->tf_esp = (uint32_t)utf;
		env_run(curenv);
	}
	// cprintf("!!!!!!!!!!!!!!!!!!!!!null\n");
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104435:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104439:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f010443d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104444:	29 c2                	sub    %eax,%edx
f0104446:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104449:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
		tf->tf_esp = (uint32_t)utf;
		env_run(curenv);
	}
	// cprintf("!!!!!!!!!!!!!!!!!!!!!null\n");
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104450:	8b 40 48             	mov    0x48(%eax),%eax
f0104453:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104457:	c7 04 24 dc 8c 10 f0 	movl   $0xf0108cdc,(%esp)
f010445e:	e8 27 fa ff ff       	call   f0103e8a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104463:	89 1c 24             	mov    %ebx,(%esp)
f0104466:	e8 f0 fc ff ff       	call   f010415b <print_trapframe>
	env_destroy(curenv);
f010446b:	e8 8c 1f 00 00       	call   f01063fc <cpunum>
f0104470:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104477:	29 c2                	sub    %eax,%edx
f0104479:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010447c:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0104483:	89 04 24             	mov    %eax,(%esp)
f0104486:	e8 27 f7 ff ff       	call   f0103bb2 <env_destroy>
}
f010448b:	83 c4 2c             	add    $0x2c,%esp
f010448e:	5b                   	pop    %ebx
f010448f:	5e                   	pop    %esi
f0104490:	5f                   	pop    %edi
f0104491:	5d                   	pop    %ebp
f0104492:	c3                   	ret    

f0104493 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104493:	55                   	push   %ebp
f0104494:	89 e5                	mov    %esp,%ebp
f0104496:	57                   	push   %edi
f0104497:	56                   	push   %esi
f0104498:	83 ec 20             	sub    $0x20,%esp
f010449b:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010449e:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010449f:	83 3d 90 1e 2e f0 00 	cmpl   $0x0,0xf02e1e90
f01044a6:	74 01                	je     f01044a9 <trap+0x16>
		asm volatile("hlt");
f01044a8:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01044a9:	e8 4e 1f 00 00       	call   f01063fc <cpunum>
f01044ae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044b5:	29 c2                	sub    %eax,%edx
f01044b7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044ba:	8d 14 85 20 20 2e f0 	lea    -0xfd1dfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01044c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01044c6:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01044ca:	83 f8 02             	cmp    $0x2,%eax
f01044cd:	75 0c                	jne    f01044db <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01044cf:	c7 04 24 a0 c4 12 f0 	movl   $0xf012c4a0,(%esp)
f01044d6:	e8 48 22 00 00       	call   f0106723 <spin_lock>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01044db:	9c                   	pushf  
f01044dc:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	// asm volatile("cli":::);
	assert(!(read_eflags() & FL_IF));
f01044dd:	f6 c4 02             	test   $0x2,%ah
f01044e0:	74 24                	je     f0104506 <trap+0x73>
f01044e2:	c7 44 24 0c 43 8b 10 	movl   $0xf0108b43,0xc(%esp)
f01044e9:	f0 
f01044ea:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f01044f1:	f0 
f01044f2:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
f01044f9:	00 
f01044fa:	c7 04 24 26 8b 10 f0 	movl   $0xf0108b26,(%esp)
f0104501:	e8 3a bb ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104506:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010450a:	83 e0 03             	and    $0x3,%eax
f010450d:	83 f8 03             	cmp    $0x3,%eax
f0104510:	0f 85 a7 00 00 00    	jne    f01045bd <trap+0x12a>
f0104516:	c7 04 24 a0 c4 12 f0 	movl   $0xf012c4a0,(%esp)
f010451d:	e8 01 22 00 00       	call   f0106723 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104522:	e8 d5 1e 00 00       	call   f01063fc <cpunum>
f0104527:	6b c0 74             	imul   $0x74,%eax,%eax
f010452a:	83 b8 28 20 2e f0 00 	cmpl   $0x0,-0xfd1dfd8(%eax)
f0104531:	75 24                	jne    f0104557 <trap+0xc4>
f0104533:	c7 44 24 0c 5c 8b 10 	movl   $0xf0108b5c,0xc(%esp)
f010453a:	f0 
f010453b:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0104542:	f0 
f0104543:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f010454a:	00 
f010454b:	c7 04 24 26 8b 10 f0 	movl   $0xf0108b26,(%esp)
f0104552:	e8 e9 ba ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104557:	e8 a0 1e 00 00       	call   f01063fc <cpunum>
f010455c:	6b c0 74             	imul   $0x74,%eax,%eax
f010455f:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f0104565:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104569:	75 2d                	jne    f0104598 <trap+0x105>
			env_free(curenv);
f010456b:	e8 8c 1e 00 00       	call   f01063fc <cpunum>
f0104570:	6b c0 74             	imul   $0x74,%eax,%eax
f0104573:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f0104579:	89 04 24             	mov    %eax,(%esp)
f010457c:	e8 58 f4 ff ff       	call   f01039d9 <env_free>
			curenv = NULL;
f0104581:	e8 76 1e 00 00       	call   f01063fc <cpunum>
f0104586:	6b c0 74             	imul   $0x74,%eax,%eax
f0104589:	c7 80 28 20 2e f0 00 	movl   $0x0,-0xfd1dfd8(%eax)
f0104590:	00 00 00 
			sched_yield();
f0104593:	e8 5a 05 00 00       	call   f0104af2 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104598:	e8 5f 1e 00 00       	call   f01063fc <cpunum>
f010459d:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a0:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f01045a6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01045ab:	89 c7                	mov    %eax,%edi
f01045ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01045af:	e8 48 1e 00 00       	call   f01063fc <cpunum>
f01045b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b7:	8b b0 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01045bd:	89 35 60 1a 2e f0    	mov    %esi,0xf02e1a60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT)
f01045c3:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01045c7:	75 08                	jne    f01045d1 <trap+0x13e>
	{
		page_fault_handler(tf);
f01045c9:	89 34 24             	mov    %esi,(%esp)
f01045cc:	e8 22 fd ff ff       	call   f01042f3 <page_fault_handler>
	}
	
	if (tf->tf_trapno == T_BRKPT)
f01045d1:	83 7e 28 03          	cmpl   $0x3,0x28(%esi)
f01045d5:	75 08                	jne    f01045df <trap+0x14c>
	{
		monitor(tf);
f01045d7:	89 34 24             	mov    %esi,(%esp)
f01045da:	e8 b0 c3 ff ff       	call   f010098f <monitor>
	}
	
	if (tf->tf_trapno == T_SYSCALL)
f01045df:	8b 46 28             	mov    0x28(%esi),%eax
f01045e2:	83 f8 30             	cmp    $0x30,%eax
f01045e5:	75 35                	jne    f010461c <trap+0x189>
	{
		int ret = syscall(tf->tf_regs.reg_eax, 
f01045e7:	8b 46 04             	mov    0x4(%esi),%eax
f01045ea:	89 44 24 14          	mov    %eax,0x14(%esp)
f01045ee:	8b 06                	mov    (%esi),%eax
f01045f0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01045f4:	8b 46 10             	mov    0x10(%esi),%eax
f01045f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045fb:	8b 46 18             	mov    0x18(%esi),%eax
f01045fe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104602:	8b 46 14             	mov    0x14(%esi),%eax
f0104605:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104609:	8b 46 1c             	mov    0x1c(%esi),%eax
f010460c:	89 04 24             	mov    %eax,(%esp)
f010460f:	e8 d0 05 00 00       	call   f0104be4 <syscall>
				tf->tf_regs.reg_edx, 
				tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, 
				tf->tf_regs.reg_edi, 
				tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax=ret;
f0104614:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104617:	e9 91 00 00 00       	jmp    f01046ad <trap+0x21a>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010461c:	83 f8 27             	cmp    $0x27,%eax
f010461f:	75 16                	jne    f0104637 <trap+0x1a4>
		cprintf("Spurious interrupt on irq 7\n");
f0104621:	c7 04 24 63 8b 10 f0 	movl   $0xf0108b63,(%esp)
f0104628:	e8 5d f8 ff ff       	call   f0103e8a <cprintf>
		print_trapframe(tf);
f010462d:	89 34 24             	mov    %esi,(%esp)
f0104630:	e8 26 fb ff ff       	call   f010415b <print_trapframe>
f0104635:	eb 76                	jmp    f01046ad <trap+0x21a>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0104637:	83 f8 20             	cmp    $0x20,%eax
f010463a:	75 18                	jne    f0104654 <trap+0x1c1>
		if (cpunum() == 0)
f010463c:	e8 bb 1d 00 00       	call   f01063fc <cpunum>
f0104641:	85 c0                	test   %eax,%eax
f0104643:	75 05                	jne    f010464a <trap+0x1b7>
		{
			time_tick();
f0104645:	e8 1d 2e 00 00       	call   f0107467 <time_tick>
		}
		lapic_eoi();
f010464a:	e8 6d 1f 00 00       	call   f01065bc <lapic_eoi>
		sched_yield();
f010464f:	e8 9e 04 00 00       	call   f0104af2 <sched_yield>
	// LAB 6: Your code here.


	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
f0104654:	83 f8 21             	cmp    $0x21,%eax
f0104657:	75 07                	jne    f0104660 <trap+0x1cd>
	{
		kbd_intr();
f0104659:	e8 e2 bf ff ff       	call   f0100640 <kbd_intr>
f010465e:	eb 4d                	jmp    f01046ad <trap+0x21a>
		return;
	}

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL)
f0104660:	83 f8 24             	cmp    $0x24,%eax
f0104663:	75 07                	jne    f010466c <trap+0x1d9>
	{
		serial_intr();
f0104665:	e8 bb bf ff ff       	call   f0100625 <serial_intr>
f010466a:	eb 41                	jmp    f01046ad <trap+0x21a>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010466c:	89 34 24             	mov    %esi,(%esp)
f010466f:	e8 e7 fa ff ff       	call   f010415b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104674:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104679:	75 1c                	jne    f0104697 <trap+0x204>
		panic("unhandled trap in kernel");
f010467b:	c7 44 24 08 80 8b 10 	movl   $0xf0108b80,0x8(%esp)
f0104682:	f0 
f0104683:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f010468a:	00 
f010468b:	c7 04 24 26 8b 10 f0 	movl   $0xf0108b26,(%esp)
f0104692:	e8 a9 b9 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104697:	e8 60 1d 00 00       	call   f01063fc <cpunum>
f010469c:	6b c0 74             	imul   $0x74,%eax,%eax
f010469f:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f01046a5:	89 04 24             	mov    %eax,(%esp)
f01046a8:	e8 05 f5 ff ff       	call   f0103bb2 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01046ad:	e8 4a 1d 00 00       	call   f01063fc <cpunum>
f01046b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b5:	83 b8 28 20 2e f0 00 	cmpl   $0x0,-0xfd1dfd8(%eax)
f01046bc:	74 2a                	je     f01046e8 <trap+0x255>
f01046be:	e8 39 1d 00 00       	call   f01063fc <cpunum>
f01046c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c6:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f01046cc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01046d0:	75 16                	jne    f01046e8 <trap+0x255>
		env_run(curenv);
f01046d2:	e8 25 1d 00 00       	call   f01063fc <cpunum>
f01046d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01046da:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f01046e0:	89 04 24             	mov    %eax,(%esp)
f01046e3:	e8 89 f5 ff ff       	call   f0103c71 <env_run>
	else
		sched_yield();
f01046e8:	e8 05 04 00 00       	call   f0104af2 <sched_yield>
f01046ed:	00 00                	add    %al,(%eax)
	...

f01046f0 <vector0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(vector0,0)
f01046f0:	6a 00                	push   $0x0
f01046f2:	6a 00                	push   $0x0
f01046f4:	e9 f3 02 00 00       	jmp    f01049ec <_alltraps>
f01046f9:	90                   	nop

f01046fa <vector1>:
TRAPHANDLER_NOEC(vector1,1)
f01046fa:	6a 00                	push   $0x0
f01046fc:	6a 01                	push   $0x1
f01046fe:	e9 e9 02 00 00       	jmp    f01049ec <_alltraps>
f0104703:	90                   	nop

f0104704 <vector2>:
TRAPHANDLER_NOEC(vector2,2)
f0104704:	6a 00                	push   $0x0
f0104706:	6a 02                	push   $0x2
f0104708:	e9 df 02 00 00       	jmp    f01049ec <_alltraps>
f010470d:	90                   	nop

f010470e <vector3>:
TRAPHANDLER_NOEC(vector3,3)
f010470e:	6a 00                	push   $0x0
f0104710:	6a 03                	push   $0x3
f0104712:	e9 d5 02 00 00       	jmp    f01049ec <_alltraps>
f0104717:	90                   	nop

f0104718 <vector4>:
TRAPHANDLER_NOEC(vector4,4)
f0104718:	6a 00                	push   $0x0
f010471a:	6a 04                	push   $0x4
f010471c:	e9 cb 02 00 00       	jmp    f01049ec <_alltraps>
f0104721:	90                   	nop

f0104722 <vector5>:
TRAPHANDLER_NOEC(vector5,5)
f0104722:	6a 00                	push   $0x0
f0104724:	6a 05                	push   $0x5
f0104726:	e9 c1 02 00 00       	jmp    f01049ec <_alltraps>
f010472b:	90                   	nop

f010472c <vector6>:
TRAPHANDLER_NOEC(vector6,6)
f010472c:	6a 00                	push   $0x0
f010472e:	6a 06                	push   $0x6
f0104730:	e9 b7 02 00 00       	jmp    f01049ec <_alltraps>
f0104735:	90                   	nop

f0104736 <vector7>:
TRAPHANDLER_NOEC(vector7,7)
f0104736:	6a 00                	push   $0x0
f0104738:	6a 07                	push   $0x7
f010473a:	e9 ad 02 00 00       	jmp    f01049ec <_alltraps>
f010473f:	90                   	nop

f0104740 <vector8>:
TRAPHANDLER(vector8,8)
f0104740:	6a 08                	push   $0x8
f0104742:	e9 a5 02 00 00       	jmp    f01049ec <_alltraps>
f0104747:	90                   	nop

f0104748 <vector9>:
TRAPHANDLER_NOEC(vector9,9)
f0104748:	6a 00                	push   $0x0
f010474a:	6a 09                	push   $0x9
f010474c:	e9 9b 02 00 00       	jmp    f01049ec <_alltraps>
f0104751:	90                   	nop

f0104752 <vector10>:
TRAPHANDLER(vector10,10)
f0104752:	6a 0a                	push   $0xa
f0104754:	e9 93 02 00 00       	jmp    f01049ec <_alltraps>
f0104759:	90                   	nop

f010475a <vector11>:
TRAPHANDLER(vector11,11)
f010475a:	6a 0b                	push   $0xb
f010475c:	e9 8b 02 00 00       	jmp    f01049ec <_alltraps>
f0104761:	90                   	nop

f0104762 <vector12>:
TRAPHANDLER(vector12,12)
f0104762:	6a 0c                	push   $0xc
f0104764:	e9 83 02 00 00       	jmp    f01049ec <_alltraps>
f0104769:	90                   	nop

f010476a <vector13>:
TRAPHANDLER(vector13,13)
f010476a:	6a 0d                	push   $0xd
f010476c:	e9 7b 02 00 00       	jmp    f01049ec <_alltraps>
f0104771:	90                   	nop

f0104772 <vector14>:
TRAPHANDLER(vector14,14)
f0104772:	6a 0e                	push   $0xe
f0104774:	e9 73 02 00 00       	jmp    f01049ec <_alltraps>
f0104779:	90                   	nop

f010477a <vector15>:
TRAPHANDLER_NOEC(vector15,15)
f010477a:	6a 00                	push   $0x0
f010477c:	6a 0f                	push   $0xf
f010477e:	e9 69 02 00 00       	jmp    f01049ec <_alltraps>
f0104783:	90                   	nop

f0104784 <vector16>:
TRAPHANDLER_NOEC(vector16,16)
f0104784:	6a 00                	push   $0x0
f0104786:	6a 10                	push   $0x10
f0104788:	e9 5f 02 00 00       	jmp    f01049ec <_alltraps>
f010478d:	90                   	nop

f010478e <vector17>:
TRAPHANDLER(vector17,17)
f010478e:	6a 11                	push   $0x11
f0104790:	e9 57 02 00 00       	jmp    f01049ec <_alltraps>
f0104795:	90                   	nop

f0104796 <vector18>:
TRAPHANDLER_NOEC(vector18,18)
f0104796:	6a 00                	push   $0x0
f0104798:	6a 12                	push   $0x12
f010479a:	e9 4d 02 00 00       	jmp    f01049ec <_alltraps>
f010479f:	90                   	nop

f01047a0 <vector19>:
TRAPHANDLER_NOEC(vector19,19)
f01047a0:	6a 00                	push   $0x0
f01047a2:	6a 13                	push   $0x13
f01047a4:	e9 43 02 00 00       	jmp    f01049ec <_alltraps>
f01047a9:	90                   	nop

f01047aa <vector20>:
TRAPHANDLER_NOEC(vector20,20)
f01047aa:	6a 00                	push   $0x0
f01047ac:	6a 14                	push   $0x14
f01047ae:	e9 39 02 00 00       	jmp    f01049ec <_alltraps>
f01047b3:	90                   	nop

f01047b4 <vector21>:
TRAPHANDLER_NOEC(vector21,21)
f01047b4:	6a 00                	push   $0x0
f01047b6:	6a 15                	push   $0x15
f01047b8:	e9 2f 02 00 00       	jmp    f01049ec <_alltraps>
f01047bd:	90                   	nop

f01047be <vector22>:
TRAPHANDLER_NOEC(vector22,22)
f01047be:	6a 00                	push   $0x0
f01047c0:	6a 16                	push   $0x16
f01047c2:	e9 25 02 00 00       	jmp    f01049ec <_alltraps>
f01047c7:	90                   	nop

f01047c8 <vector23>:
TRAPHANDLER_NOEC(vector23,23)
f01047c8:	6a 00                	push   $0x0
f01047ca:	6a 17                	push   $0x17
f01047cc:	e9 1b 02 00 00       	jmp    f01049ec <_alltraps>
f01047d1:	90                   	nop

f01047d2 <vector24>:
TRAPHANDLER_NOEC(vector24,24)
f01047d2:	6a 00                	push   $0x0
f01047d4:	6a 18                	push   $0x18
f01047d6:	e9 11 02 00 00       	jmp    f01049ec <_alltraps>
f01047db:	90                   	nop

f01047dc <vector25>:
TRAPHANDLER_NOEC(vector25,25)
f01047dc:	6a 00                	push   $0x0
f01047de:	6a 19                	push   $0x19
f01047e0:	e9 07 02 00 00       	jmp    f01049ec <_alltraps>
f01047e5:	90                   	nop

f01047e6 <vector26>:
TRAPHANDLER_NOEC(vector26,26)
f01047e6:	6a 00                	push   $0x0
f01047e8:	6a 1a                	push   $0x1a
f01047ea:	e9 fd 01 00 00       	jmp    f01049ec <_alltraps>
f01047ef:	90                   	nop

f01047f0 <vector27>:
TRAPHANDLER_NOEC(vector27,27)
f01047f0:	6a 00                	push   $0x0
f01047f2:	6a 1b                	push   $0x1b
f01047f4:	e9 f3 01 00 00       	jmp    f01049ec <_alltraps>
f01047f9:	90                   	nop

f01047fa <vector28>:
TRAPHANDLER_NOEC(vector28,28)
f01047fa:	6a 00                	push   $0x0
f01047fc:	6a 1c                	push   $0x1c
f01047fe:	e9 e9 01 00 00       	jmp    f01049ec <_alltraps>
f0104803:	90                   	nop

f0104804 <vector29>:
TRAPHANDLER_NOEC(vector29,29)
f0104804:	6a 00                	push   $0x0
f0104806:	6a 1d                	push   $0x1d
f0104808:	e9 df 01 00 00       	jmp    f01049ec <_alltraps>
f010480d:	90                   	nop

f010480e <vector30>:
TRAPHANDLER_NOEC(vector30,30)
f010480e:	6a 00                	push   $0x0
f0104810:	6a 1e                	push   $0x1e
f0104812:	e9 d5 01 00 00       	jmp    f01049ec <_alltraps>
f0104817:	90                   	nop

f0104818 <vector31>:
TRAPHANDLER_NOEC(vector31,31)
f0104818:	6a 00                	push   $0x0
f010481a:	6a 1f                	push   $0x1f
f010481c:	e9 cb 01 00 00       	jmp    f01049ec <_alltraps>
f0104821:	90                   	nop

f0104822 <vector32>:
TRAPHANDLER_NOEC(vector32,32)
f0104822:	6a 00                	push   $0x0
f0104824:	6a 20                	push   $0x20
f0104826:	e9 c1 01 00 00       	jmp    f01049ec <_alltraps>
f010482b:	90                   	nop

f010482c <vector33>:
TRAPHANDLER_NOEC(vector33,33)
f010482c:	6a 00                	push   $0x0
f010482e:	6a 21                	push   $0x21
f0104830:	e9 b7 01 00 00       	jmp    f01049ec <_alltraps>
f0104835:	90                   	nop

f0104836 <vector34>:
TRAPHANDLER_NOEC(vector34,34)
f0104836:	6a 00                	push   $0x0
f0104838:	6a 22                	push   $0x22
f010483a:	e9 ad 01 00 00       	jmp    f01049ec <_alltraps>
f010483f:	90                   	nop

f0104840 <vector35>:
TRAPHANDLER_NOEC(vector35,35)
f0104840:	6a 00                	push   $0x0
f0104842:	6a 23                	push   $0x23
f0104844:	e9 a3 01 00 00       	jmp    f01049ec <_alltraps>
f0104849:	90                   	nop

f010484a <vector36>:
TRAPHANDLER_NOEC(vector36,36)
f010484a:	6a 00                	push   $0x0
f010484c:	6a 24                	push   $0x24
f010484e:	e9 99 01 00 00       	jmp    f01049ec <_alltraps>
f0104853:	90                   	nop

f0104854 <vector37>:
TRAPHANDLER_NOEC(vector37,37)
f0104854:	6a 00                	push   $0x0
f0104856:	6a 25                	push   $0x25
f0104858:	e9 8f 01 00 00       	jmp    f01049ec <_alltraps>
f010485d:	90                   	nop

f010485e <vector38>:
TRAPHANDLER_NOEC(vector38,38)
f010485e:	6a 00                	push   $0x0
f0104860:	6a 26                	push   $0x26
f0104862:	e9 85 01 00 00       	jmp    f01049ec <_alltraps>
f0104867:	90                   	nop

f0104868 <vector39>:
TRAPHANDLER_NOEC(vector39,39)
f0104868:	6a 00                	push   $0x0
f010486a:	6a 27                	push   $0x27
f010486c:	e9 7b 01 00 00       	jmp    f01049ec <_alltraps>
f0104871:	90                   	nop

f0104872 <vector40>:
TRAPHANDLER_NOEC(vector40,40)
f0104872:	6a 00                	push   $0x0
f0104874:	6a 28                	push   $0x28
f0104876:	e9 71 01 00 00       	jmp    f01049ec <_alltraps>
f010487b:	90                   	nop

f010487c <vector41>:
TRAPHANDLER_NOEC(vector41,41)
f010487c:	6a 00                	push   $0x0
f010487e:	6a 29                	push   $0x29
f0104880:	e9 67 01 00 00       	jmp    f01049ec <_alltraps>
f0104885:	90                   	nop

f0104886 <vector42>:
TRAPHANDLER_NOEC(vector42,42)
f0104886:	6a 00                	push   $0x0
f0104888:	6a 2a                	push   $0x2a
f010488a:	e9 5d 01 00 00       	jmp    f01049ec <_alltraps>
f010488f:	90                   	nop

f0104890 <vector43>:
TRAPHANDLER_NOEC(vector43,43)
f0104890:	6a 00                	push   $0x0
f0104892:	6a 2b                	push   $0x2b
f0104894:	e9 53 01 00 00       	jmp    f01049ec <_alltraps>
f0104899:	90                   	nop

f010489a <vector44>:
TRAPHANDLER_NOEC(vector44,44)
f010489a:	6a 00                	push   $0x0
f010489c:	6a 2c                	push   $0x2c
f010489e:	e9 49 01 00 00       	jmp    f01049ec <_alltraps>
f01048a3:	90                   	nop

f01048a4 <vector45>:
TRAPHANDLER_NOEC(vector45,45)
f01048a4:	6a 00                	push   $0x0
f01048a6:	6a 2d                	push   $0x2d
f01048a8:	e9 3f 01 00 00       	jmp    f01049ec <_alltraps>
f01048ad:	90                   	nop

f01048ae <vector46>:
TRAPHANDLER_NOEC(vector46,46)
f01048ae:	6a 00                	push   $0x0
f01048b0:	6a 2e                	push   $0x2e
f01048b2:	e9 35 01 00 00       	jmp    f01049ec <_alltraps>
f01048b7:	90                   	nop

f01048b8 <vector47>:
TRAPHANDLER_NOEC(vector47,47)
f01048b8:	6a 00                	push   $0x0
f01048ba:	6a 2f                	push   $0x2f
f01048bc:	e9 2b 01 00 00       	jmp    f01049ec <_alltraps>
f01048c1:	90                   	nop

f01048c2 <vector48>:
TRAPHANDLER_NOEC(vector48,48)
f01048c2:	6a 00                	push   $0x0
f01048c4:	6a 30                	push   $0x30
f01048c6:	e9 21 01 00 00       	jmp    f01049ec <_alltraps>
f01048cb:	90                   	nop

f01048cc <vector49>:
TRAPHANDLER_NOEC(vector49,49)
f01048cc:	6a 00                	push   $0x0
f01048ce:	6a 31                	push   $0x31
f01048d0:	e9 17 01 00 00       	jmp    f01049ec <_alltraps>
f01048d5:	90                   	nop

f01048d6 <vector50>:
TRAPHANDLER_NOEC(vector50,50)
f01048d6:	6a 00                	push   $0x0
f01048d8:	6a 32                	push   $0x32
f01048da:	e9 0d 01 00 00       	jmp    f01049ec <_alltraps>
f01048df:	90                   	nop

f01048e0 <vector51>:
TRAPHANDLER_NOEC(vector51,51)
f01048e0:	6a 00                	push   $0x0
f01048e2:	6a 33                	push   $0x33
f01048e4:	e9 03 01 00 00       	jmp    f01049ec <_alltraps>
f01048e9:	90                   	nop

f01048ea <vector52>:
TRAPHANDLER_NOEC(vector52,52)
f01048ea:	6a 00                	push   $0x0
f01048ec:	6a 34                	push   $0x34
f01048ee:	e9 f9 00 00 00       	jmp    f01049ec <_alltraps>
f01048f3:	90                   	nop

f01048f4 <divide_error_handler>:


TRAPHANDLER_NOEC(divide_error_handler, T_DIVIDE)
f01048f4:	6a 00                	push   $0x0
f01048f6:	6a 00                	push   $0x0
f01048f8:	e9 ef 00 00 00       	jmp    f01049ec <_alltraps>
f01048fd:	90                   	nop

f01048fe <debug_exception_handler>:
TRAPHANDLER_NOEC(debug_exception_handler, T_DEBUG)
f01048fe:	6a 00                	push   $0x0
f0104900:	6a 01                	push   $0x1
f0104902:	e9 e5 00 00 00       	jmp    f01049ec <_alltraps>
f0104907:	90                   	nop

f0104908 <non_maskable_interrupt_handler>:
TRAPHANDLER_NOEC(non_maskable_interrupt_handler, T_NMI)
f0104908:	6a 00                	push   $0x0
f010490a:	6a 02                	push   $0x2
f010490c:	e9 db 00 00 00       	jmp    f01049ec <_alltraps>
f0104911:	90                   	nop

f0104912 <breakpoint_handler>:
TRAPHANDLER_NOEC(breakpoint_handler, T_BRKPT)
f0104912:	6a 00                	push   $0x0
f0104914:	6a 03                	push   $0x3
f0104916:	e9 d1 00 00 00       	jmp    f01049ec <_alltraps>
f010491b:	90                   	nop

f010491c <overflow_handler>:
TRAPHANDLER_NOEC(overflow_handler, T_OFLOW)
f010491c:	6a 00                	push   $0x0
f010491e:	6a 04                	push   $0x4
f0104920:	e9 c7 00 00 00       	jmp    f01049ec <_alltraps>
f0104925:	90                   	nop

f0104926 <bounds_check_handler>:
TRAPHANDLER_NOEC(bounds_check_handler, T_BOUND)
f0104926:	6a 00                	push   $0x0
f0104928:	6a 05                	push   $0x5
f010492a:	e9 bd 00 00 00       	jmp    f01049ec <_alltraps>
f010492f:	90                   	nop

f0104930 <invalid_opcode_handler>:
TRAPHANDLER_NOEC(invalid_opcode_handler, T_ILLOP)
f0104930:	6a 00                	push   $0x0
f0104932:	6a 06                	push   $0x6
f0104934:	e9 b3 00 00 00       	jmp    f01049ec <_alltraps>
f0104939:	90                   	nop

f010493a <device_not_available_handler>:
TRAPHANDLER_NOEC(device_not_available_handler, T_DEVICE)
f010493a:	6a 00                	push   $0x0
f010493c:	6a 07                	push   $0x7
f010493e:	e9 a9 00 00 00       	jmp    f01049ec <_alltraps>
f0104943:	90                   	nop

f0104944 <double_fault_handler>:
TRAPHANDLER(double_fault_handler, T_DBLFLT)
f0104944:	6a 08                	push   $0x8
f0104946:	e9 a1 00 00 00       	jmp    f01049ec <_alltraps>
f010494b:	90                   	nop

f010494c <invalid_tss_handler>:
TRAPHANDLER(invalid_tss_handler, T_TSS)
f010494c:	6a 0a                	push   $0xa
f010494e:	e9 99 00 00 00       	jmp    f01049ec <_alltraps>
f0104953:	90                   	nop

f0104954 <segment_not_present_handler>:
TRAPHANDLER(segment_not_present_handler, T_SEGNP)
f0104954:	6a 0b                	push   $0xb
f0104956:	e9 91 00 00 00       	jmp    f01049ec <_alltraps>
f010495b:	90                   	nop

f010495c <stack_exception_handler>:
TRAPHANDLER(stack_exception_handler, T_STACK)
f010495c:	6a 0c                	push   $0xc
f010495e:	e9 89 00 00 00       	jmp    f01049ec <_alltraps>
f0104963:	90                   	nop

f0104964 <general_protection_fault_handler>:
TRAPHANDLER(general_protection_fault_handler, T_GPFLT)
f0104964:	6a 0d                	push   $0xd
f0104966:	e9 81 00 00 00       	jmp    f01049ec <_alltraps>
f010496b:	90                   	nop

f010496c <pagefault_handler>:
TRAPHANDLER(pagefault_handler, T_PGFLT)
f010496c:	6a 0e                	push   $0xe
f010496e:	eb 7c                	jmp    f01049ec <_alltraps>

f0104970 <floating_point_error_handler>:
TRAPHANDLER_NOEC(floating_point_error_handler, T_FPERR)
f0104970:	6a 00                	push   $0x0
f0104972:	6a 10                	push   $0x10
f0104974:	eb 76                	jmp    f01049ec <_alltraps>

f0104976 <alignment_check_handler>:
TRAPHANDLER(alignment_check_handler, T_ALIGN)
f0104976:	6a 11                	push   $0x11
f0104978:	eb 72                	jmp    f01049ec <_alltraps>

f010497a <machine_check_handler>:
TRAPHANDLER_NOEC(machine_check_handler, T_MCHK)
f010497a:	6a 00                	push   $0x0
f010497c:	6a 12                	push   $0x12
f010497e:	eb 6c                	jmp    f01049ec <_alltraps>

f0104980 <simd_floating_point_error_handler>:
TRAPHANDLER_NOEC(simd_floating_point_error_handler, T_SIMDERR)
f0104980:	6a 00                	push   $0x0
f0104982:	6a 13                	push   $0x13
f0104984:	eb 66                	jmp    f01049ec <_alltraps>

f0104986 <system_call>:
TRAPHANDLER_NOEC(system_call, T_SYSCALL)
f0104986:	6a 00                	push   $0x0
f0104988:	6a 30                	push   $0x30
f010498a:	eb 60                	jmp    f01049ec <_alltraps>

f010498c <irq_0_handler>:

TRAPHANDLER_NOEC(irq_0_handler,  IRQ_OFFSET + 0);
f010498c:	6a 00                	push   $0x0
f010498e:	6a 20                	push   $0x20
f0104990:	eb 5a                	jmp    f01049ec <_alltraps>

f0104992 <irq_1_handler>:
TRAPHANDLER_NOEC(irq_1_handler,  IRQ_OFFSET + 1);
f0104992:	6a 00                	push   $0x0
f0104994:	6a 21                	push   $0x21
f0104996:	eb 54                	jmp    f01049ec <_alltraps>

f0104998 <irq_2_handler>:
TRAPHANDLER_NOEC(irq_2_handler,  IRQ_OFFSET + 2);
f0104998:	6a 00                	push   $0x0
f010499a:	6a 22                	push   $0x22
f010499c:	eb 4e                	jmp    f01049ec <_alltraps>

f010499e <irq_3_handler>:
TRAPHANDLER_NOEC(irq_3_handler,  IRQ_OFFSET + 3);
f010499e:	6a 00                	push   $0x0
f01049a0:	6a 23                	push   $0x23
f01049a2:	eb 48                	jmp    f01049ec <_alltraps>

f01049a4 <irq_4_handler>:
TRAPHANDLER_NOEC(irq_4_handler,  IRQ_OFFSET + 4);
f01049a4:	6a 00                	push   $0x0
f01049a6:	6a 24                	push   $0x24
f01049a8:	eb 42                	jmp    f01049ec <_alltraps>

f01049aa <irq_5_handler>:
TRAPHANDLER_NOEC(irq_5_handler,  IRQ_OFFSET + 5);
f01049aa:	6a 00                	push   $0x0
f01049ac:	6a 25                	push   $0x25
f01049ae:	eb 3c                	jmp    f01049ec <_alltraps>

f01049b0 <irq_6_handler>:
TRAPHANDLER_NOEC(irq_6_handler,  IRQ_OFFSET + 6);
f01049b0:	6a 00                	push   $0x0
f01049b2:	6a 26                	push   $0x26
f01049b4:	eb 36                	jmp    f01049ec <_alltraps>

f01049b6 <irq_7_handler>:
TRAPHANDLER_NOEC(irq_7_handler,  IRQ_OFFSET + 7);
f01049b6:	6a 00                	push   $0x0
f01049b8:	6a 27                	push   $0x27
f01049ba:	eb 30                	jmp    f01049ec <_alltraps>

f01049bc <irq_8_handler>:
TRAPHANDLER_NOEC(irq_8_handler,  IRQ_OFFSET + 8);
f01049bc:	6a 00                	push   $0x0
f01049be:	6a 28                	push   $0x28
f01049c0:	eb 2a                	jmp    f01049ec <_alltraps>

f01049c2 <irq_9_handler>:
TRAPHANDLER_NOEC(irq_9_handler,  IRQ_OFFSET + 9);
f01049c2:	6a 00                	push   $0x0
f01049c4:	6a 29                	push   $0x29
f01049c6:	eb 24                	jmp    f01049ec <_alltraps>

f01049c8 <irq_10_handler>:
TRAPHANDLER_NOEC(irq_10_handler, IRQ_OFFSET + 10);
f01049c8:	6a 00                	push   $0x0
f01049ca:	6a 2a                	push   $0x2a
f01049cc:	eb 1e                	jmp    f01049ec <_alltraps>

f01049ce <irq_11_handler>:
TRAPHANDLER_NOEC(irq_11_handler, IRQ_OFFSET + 11);
f01049ce:	6a 00                	push   $0x0
f01049d0:	6a 2b                	push   $0x2b
f01049d2:	eb 18                	jmp    f01049ec <_alltraps>

f01049d4 <irq_12_handler>:
TRAPHANDLER_NOEC(irq_12_handler, IRQ_OFFSET + 12);
f01049d4:	6a 00                	push   $0x0
f01049d6:	6a 2c                	push   $0x2c
f01049d8:	eb 12                	jmp    f01049ec <_alltraps>

f01049da <irq_13_handler>:
TRAPHANDLER_NOEC(irq_13_handler, IRQ_OFFSET + 13);
f01049da:	6a 00                	push   $0x0
f01049dc:	6a 2d                	push   $0x2d
f01049de:	eb 0c                	jmp    f01049ec <_alltraps>

f01049e0 <irq_14_handler>:
TRAPHANDLER_NOEC(irq_14_handler, IRQ_OFFSET + 14);
f01049e0:	6a 00                	push   $0x0
f01049e2:	6a 2e                	push   $0x2e
f01049e4:	eb 06                	jmp    f01049ec <_alltraps>

f01049e6 <irq_15_handler>:
TRAPHANDLER_NOEC(irq_15_handler, IRQ_OFFSET + 15);
f01049e6:	6a 00                	push   $0x0
f01049e8:	6a 2f                	push   $0x2f
f01049ea:	eb 00                	jmp    f01049ec <_alltraps>

f01049ec <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds; 
f01049ec:	1e                   	push   %ds
	pushl %es; 
f01049ed:	06                   	push   %es

	pushal
f01049ee:	60                   	pusha  

	movl $GD_KD, %eax;
f01049ef:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds;
f01049f4:	8e d8                	mov    %eax,%ds
	movw %ax, %es;
f01049f6:	8e c0                	mov    %eax,%es

	pushl %esp;
f01049f8:	54                   	push   %esp
	call trap 
f01049f9:	e8 95 fa ff ff       	call   f0104493 <trap>
	...

f0104a00 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104a00:	55                   	push   %ebp
f0104a01:	89 e5                	mov    %esp,%ebp
f0104a03:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104a06:	8b 15 48 12 2e f0    	mov    0xf02e1248,%edx
f0104a0c:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104a0f:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104a14:	8b 0a                	mov    (%edx),%ecx
f0104a16:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104a17:	83 f9 02             	cmp    $0x2,%ecx
f0104a1a:	76 0d                	jbe    f0104a29 <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104a1c:	40                   	inc    %eax
f0104a1d:	83 c2 7c             	add    $0x7c,%edx
f0104a20:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a25:	75 ed                	jne    f0104a14 <sched_halt+0x14>
f0104a27:	eb 07                	jmp    f0104a30 <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104a29:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a2e:	75 1a                	jne    f0104a4a <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0104a30:	c7 04 24 50 8d 10 f0 	movl   $0xf0108d50,(%esp)
f0104a37:	e8 4e f4 ff ff       	call   f0103e8a <cprintf>
		while (1)
			monitor(NULL);
f0104a3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104a43:	e8 47 bf ff ff       	call   f010098f <monitor>
f0104a48:	eb f2                	jmp    f0104a3c <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104a4a:	e8 ad 19 00 00       	call   f01063fc <cpunum>
f0104a4f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a56:	29 c2                	sub    %eax,%edx
f0104a58:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a5b:	c7 04 85 28 20 2e f0 	movl   $0x0,-0xfd1dfd8(,%eax,4)
f0104a62:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104a66:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104a6b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104a70:	77 20                	ja     f0104a92 <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104a72:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a76:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0104a7d:	f0 
f0104a7e:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0104a85:	00 
f0104a86:	c7 04 24 79 8d 10 f0 	movl   $0xf0108d79,(%esp)
f0104a8d:	e8 ae b5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104a92:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104a97:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104a9a:	e8 5d 19 00 00       	call   f01063fc <cpunum>
f0104a9f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104aa6:	29 c2                	sub    %eax,%edx
f0104aa8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104aab:	8d 14 85 20 20 2e f0 	lea    -0xfd1dfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104ab2:	b8 02 00 00 00       	mov    $0x2,%eax
f0104ab7:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104abb:	c7 04 24 a0 c4 12 f0 	movl   $0xf012c4a0,(%esp)
f0104ac2:	e8 ff 1c 00 00       	call   f01067c6 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104ac7:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104ac9:	e8 2e 19 00 00       	call   f01063fc <cpunum>
f0104ace:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ad5:	29 c2                	sub    %eax,%edx
f0104ad7:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104ada:	8b 04 85 30 20 2e f0 	mov    -0xfd1dfd0(,%eax,4),%eax
f0104ae1:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ae6:	89 c4                	mov    %eax,%esp
f0104ae8:	6a 00                	push   $0x0
f0104aea:	6a 00                	push   $0x0
f0104aec:	fb                   	sti    
f0104aed:	f4                   	hlt    
f0104aee:	eb fd                	jmp    f0104aed <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104af0:	c9                   	leave  
f0104af1:	c3                   	ret    

f0104af2 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104af2:	55                   	push   %ebp
f0104af3:	89 e5                	mov    %esp,%ebp
f0104af5:	56                   	push   %esi
f0104af6:	53                   	push   %ebx
f0104af7:	83 ec 10             	sub    $0x10,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int cur = 0;
	if (curenv)
f0104afa:	e8 fd 18 00 00       	call   f01063fc <cpunum>
f0104aff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b06:	29 c2                	sub    %eax,%edx
f0104b08:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b0b:	83 3c 85 28 20 2e f0 	cmpl   $0x0,-0xfd1dfd8(,%eax,4)
f0104b12:	00 
f0104b13:	74 23                	je     f0104b38 <sched_yield+0x46>
		cur = ENVX(curenv->env_id);
f0104b15:	e8 e2 18 00 00       	call   f01063fc <cpunum>
f0104b1a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b21:	29 c2                	sub    %eax,%edx
f0104b23:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b26:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0104b2d:	8b 48 48             	mov    0x48(%eax),%ecx
f0104b30:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0104b36:	eb 05                	jmp    f0104b3d <sched_yield+0x4b>
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int cur = 0;
f0104b38:	b9 00 00 00 00       	mov    $0x0,%ecx
	if (curenv)
		cur = ENVX(curenv->env_id);
	for (int i = 0; i < NENV; ++i)
	{
		int id = (cur + i + 1) % NENV;
		if (envs[id].env_status == ENV_RUNNABLE)
f0104b3d:	8b 1d 48 12 2e f0    	mov    0xf02e1248,%ebx

	// LAB 4: Your code here.
	int cur = 0;
	if (curenv)
		cur = ENVX(curenv->env_id);
	for (int i = 0; i < NENV; ++i)
f0104b43:	ba 00 00 00 00       	mov    $0x0,%edx

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f0104b48:	41                   	inc    %ecx
f0104b49:	8d 04 11             	lea    (%ecx,%edx,1),%eax
	int cur = 0;
	if (curenv)
		cur = ENVX(curenv->env_id);
	for (int i = 0; i < NENV; ++i)
	{
		int id = (cur + i + 1) % NENV;
f0104b4c:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104b51:	79 07                	jns    f0104b5a <sched_yield+0x68>
f0104b53:	48                   	dec    %eax
f0104b54:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104b59:	40                   	inc    %eax
		if (envs[id].env_status == ENV_RUNNABLE)
f0104b5a:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f0104b61:	c1 e0 07             	shl    $0x7,%eax
f0104b64:	29 f0                	sub    %esi,%eax
f0104b66:	01 d8                	add    %ebx,%eax
f0104b68:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104b6c:	75 08                	jne    f0104b76 <sched_yield+0x84>
		{
			env_run(&envs[id]);
f0104b6e:	89 04 24             	mov    %eax,(%esp)
f0104b71:	e8 fb f0 ff ff       	call   f0103c71 <env_run>

	// LAB 4: Your code here.
	int cur = 0;
	if (curenv)
		cur = ENVX(curenv->env_id);
	for (int i = 0; i < NENV; ++i)
f0104b76:	42                   	inc    %edx
f0104b77:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104b7d:	75 ca                	jne    f0104b49 <sched_yield+0x57>
		if (envs[id].env_status == ENV_RUNNABLE)
		{
			env_run(&envs[id]);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING){
f0104b7f:	e8 78 18 00 00       	call   f01063fc <cpunum>
f0104b84:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b8b:	29 c2                	sub    %eax,%edx
f0104b8d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b90:	83 3c 85 28 20 2e f0 	cmpl   $0x0,-0xfd1dfd8(,%eax,4)
f0104b97:	00 
f0104b98:	74 3e                	je     f0104bd8 <sched_yield+0xe6>
f0104b9a:	e8 5d 18 00 00       	call   f01063fc <cpunum>
f0104b9f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ba6:	29 c2                	sub    %eax,%edx
f0104ba8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bab:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0104bb2:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104bb6:	75 20                	jne    f0104bd8 <sched_yield+0xe6>
		env_run(curenv);
f0104bb8:	e8 3f 18 00 00       	call   f01063fc <cpunum>
f0104bbd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104bc4:	29 c2                	sub    %eax,%edx
f0104bc6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bc9:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0104bd0:	89 04 24             	mov    %eax,(%esp)
f0104bd3:	e8 99 f0 ff ff       	call   f0103c71 <env_run>
	}
	// sched_halt never returns
	sched_halt();
f0104bd8:	e8 23 fe ff ff       	call   f0104a00 <sched_halt>
}
f0104bdd:	83 c4 10             	add    $0x10,%esp
f0104be0:	5b                   	pop    %ebx
f0104be1:	5e                   	pop    %esi
f0104be2:	5d                   	pop    %ebp
f0104be3:	c3                   	ret    

f0104be4 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104be4:	55                   	push   %ebp
f0104be5:	89 e5                	mov    %esp,%ebp
f0104be7:	57                   	push   %edi
f0104be8:	56                   	push   %esi
f0104be9:	53                   	push   %ebx
f0104bea:	83 ec 2c             	sub    $0x2c,%esp
f0104bed:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bf0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104bf3:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104bf6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0104bf9:	83 f8 10             	cmp    $0x10,%eax
f0104bfc:	0f 87 8a 06 00 00    	ja     f010528c <syscall+0x6a8>
f0104c02:	ff 24 85 bc 8d 10 f0 	jmp    *-0xfef7244(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, PTE_P | PTE_U);
f0104c09:	e8 ee 17 00 00       	call   f01063fc <cpunum>
f0104c0e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0104c15:	00 
f0104c16:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104c1a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104c1e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c25:	29 c2                	sub    %eax,%edx
f0104c27:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c2a:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0104c31:	89 04 24             	mov    %eax,(%esp)
f0104c34:	e8 ae e8 ff ff       	call   f01034e7 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104c39:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104c3d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c41:	c7 04 24 86 8d 10 f0 	movl   $0xf0108d86,(%esp)
f0104c48:	e8 3d f2 ff ff       	call   f0103e8a <cprintf>
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs: sys_cputs((char*)a1,a2); return 0;
f0104c4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c52:	e9 41 06 00 00       	jmp    f0105298 <syscall+0x6b4>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104c57:	e8 f6 b9 ff ff       	call   f0100652 <cons_getc>

	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs: sys_cputs((char*)a1,a2); return 0;
		case SYS_cgetc: return sys_cgetc();
f0104c5c:	e9 37 06 00 00       	jmp    f0105298 <syscall+0x6b4>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104c61:	e8 96 17 00 00       	call   f01063fc <cpunum>
f0104c66:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c6d:	29 c2                	sub    %eax,%edx
f0104c6f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c72:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0104c79:	8b 40 48             	mov    0x48(%eax),%eax
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs: sys_cputs((char*)a1,a2); return 0;
		case SYS_cgetc: return sys_cgetc();
		case SYS_getenvid: return sys_getenvid();
f0104c7c:	e9 17 06 00 00       	jmp    f0105298 <syscall+0x6b4>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c81:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104c88:	00 
f0104c89:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c90:	89 34 24             	mov    %esi,(%esp)
f0104c93:	e8 60 e9 ff ff       	call   f01035f8 <envid2env>
f0104c98:	85 c0                	test   %eax,%eax
f0104c9a:	0f 88 f8 05 00 00    	js     f0105298 <syscall+0x6b4>
		return r;
	env_destroy(e);
f0104ca0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ca3:	89 04 24             	mov    %eax,(%esp)
f0104ca6:	e8 07 ef ff ff       	call   f0103bb2 <env_destroy>
	return 0;
f0104cab:	b8 00 00 00 00       	mov    $0x0,%eax

	switch (syscallno) {
		case SYS_cputs: sys_cputs((char*)a1,a2); return 0;
		case SYS_cgetc: return sys_cgetc();
		case SYS_getenvid: return sys_getenvid();
		case SYS_env_destroy: return sys_env_destroy(a1);
f0104cb0:	e9 e3 05 00 00       	jmp    f0105298 <syscall+0x6b4>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104cb5:	e8 38 fe ff ff       	call   f0104af2 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *child;
	if (env_alloc(&child, curenv->env_id) < 0)
f0104cba:	e8 3d 17 00 00       	call   f01063fc <cpunum>
f0104cbf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cc6:	29 c2                	sub    %eax,%edx
f0104cc8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ccb:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0104cd2:	8b 40 48             	mov    0x48(%eax),%eax
f0104cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cd9:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104cdc:	89 04 24             	mov    %eax,(%esp)
f0104cdf:	e8 3e ea ff ff       	call   f0103722 <env_alloc>
f0104ce4:	85 c0                	test   %eax,%eax
f0104ce6:	78 4b                	js     f0104d33 <syscall+0x14f>
		return -E_NO_FREE_ENV;
	child->env_status = ENV_NOT_RUNNABLE;
f0104ce8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ceb:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy(&child->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
f0104cf2:	e8 05 17 00 00       	call   f01063fc <cpunum>
f0104cf7:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104cfe:	00 
f0104cff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d06:	29 c2                	sub    %eax,%edx
f0104d08:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d0b:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f0104d12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d16:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d19:	89 04 24             	mov    %eax,(%esp)
f0104d1c:	e8 51 11 00 00       	call   f0105e72 <memcpy>
	child->env_tf.tf_regs.reg_eax = 0;
f0104d21:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d24:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return child->env_id;
f0104d2b:	8b 40 48             	mov    0x48(%eax),%eax
f0104d2e:	e9 65 05 00 00       	jmp    f0105298 <syscall+0x6b4>
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *child;
	if (env_alloc(&child, curenv->env_id) < 0)
		return -E_NO_FREE_ENV;
f0104d33:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
		case SYS_cputs: sys_cputs((char*)a1,a2); return 0;
		case SYS_cgetc: return sys_cgetc();
		case SYS_getenvid: return sys_getenvid();
		case SYS_env_destroy: return sys_env_destroy(a1);
		case SYS_yield: sys_yield(); return 0;
		case SYS_exofork: return sys_exofork();
f0104d38:	e9 5b 05 00 00       	jmp    f0105298 <syscall+0x6b4>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *cur;
	if (envid2env(envid, &cur, 1) < 0)
f0104d3d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d44:	00 
f0104d45:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104d48:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d4c:	89 34 24             	mov    %esi,(%esp)
f0104d4f:	e8 a4 e8 ff ff       	call   f01035f8 <envid2env>
f0104d54:	85 c0                	test   %eax,%eax
f0104d56:	78 1a                	js     f0104d72 <syscall+0x18e>
	{
		return -E_BAD_ENV;
	}
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f0104d58:	83 ff 02             	cmp    $0x2,%edi
f0104d5b:	74 05                	je     f0104d62 <syscall+0x17e>
f0104d5d:	83 ff 04             	cmp    $0x4,%edi
f0104d60:	75 1a                	jne    f0104d7c <syscall+0x198>
	{
		return -E_INVAL;
	}
	cur->env_status = status;
f0104d62:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d65:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0104d68:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d6d:	e9 26 05 00 00       	jmp    f0105298 <syscall+0x6b4>

	// LAB 4: Your code here.
	struct Env *cur;
	if (envid2env(envid, &cur, 1) < 0)
	{
		return -E_BAD_ENV;
f0104d72:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104d77:	e9 1c 05 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
	{
		return -E_INVAL;
f0104d7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_cgetc: return sys_cgetc();
		case SYS_getenvid: return sys_getenvid();
		case SYS_env_destroy: return sys_env_destroy(a1);
		case SYS_yield: sys_yield(); return 0;
		case SYS_exofork: return sys_exofork();
		case SYS_env_set_status: return sys_env_set_status(a1,a2);
f0104d81:	e9 12 05 00 00       	jmp    f0105298 <syscall+0x6b4>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env *cur;
	if (envid2env(envid, &cur, 1) < 0)
f0104d86:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d8d:	00 
f0104d8e:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104d91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d95:	89 34 24             	mov    %esi,(%esp)
f0104d98:	e8 5b e8 ff ff       	call   f01035f8 <envid2env>
f0104d9d:	85 c0                	test   %eax,%eax
f0104d9f:	78 5c                	js     f0104dfd <syscall+0x219>
	{
		return -E_BAD_ENV;
	}
	if ((uintptr_t)va >= UTOP)
f0104da1:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104da7:	77 5e                	ja     f0104e07 <syscall+0x223>
	{
		return -E_INVAL;
	}
	int must_perm = PTE_U | PTE_P;
	if ((perm & must_perm) != must_perm || (perm & ~PTE_SYSCALL))
f0104da9:	89 d8                	mov    %ebx,%eax
f0104dab:	83 e0 05             	and    $0x5,%eax
f0104dae:	83 f8 05             	cmp    $0x5,%eax
f0104db1:	75 5e                	jne    f0104e11 <syscall+0x22d>
f0104db3:	f7 c3 f8 f1 ff ff    	test   $0xfffff1f8,%ebx
f0104db9:	75 60                	jne    f0104e1b <syscall+0x237>
	{
		return -E_INVAL;
	}
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0104dbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104dc2:	e8 24 c2 ff ff       	call   f0100feb <page_alloc>
f0104dc7:	89 c6                	mov    %eax,%esi
	if (!page)
f0104dc9:	85 c0                	test   %eax,%eax
f0104dcb:	74 58                	je     f0104e25 <syscall+0x241>
	{
		return -E_NO_MEM;
	}
	if (page_insert(cur->env_pgdir, page, va, perm) < 0)
f0104dcd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104dd1:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dd9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ddc:	8b 40 60             	mov    0x60(%eax),%eax
f0104ddf:	89 04 24             	mov    %eax,(%esp)
f0104de2:	e8 ef c4 ff ff       	call   f01012d6 <page_insert>
f0104de7:	85 c0                	test   %eax,%eax
f0104de9:	79 44                	jns    f0104e2f <syscall+0x24b>
	{
		page_free(page);
f0104deb:	89 34 24             	mov    %esi,(%esp)
f0104dee:	e8 7c c2 ff ff       	call   f010106f <page_free>
		return -E_NO_MEM;
f0104df3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104df8:	e9 9b 04 00 00       	jmp    f0105298 <syscall+0x6b4>

	// LAB 4: Your code here.
	struct Env *cur;
	if (envid2env(envid, &cur, 1) < 0)
	{
		return -E_BAD_ENV;
f0104dfd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e02:	e9 91 04 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	if ((uintptr_t)va >= UTOP)
	{
		return -E_INVAL;
f0104e07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e0c:	e9 87 04 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	int must_perm = PTE_U | PTE_P;
	if ((perm & must_perm) != must_perm || (perm & ~PTE_SYSCALL))
	{
		return -E_INVAL;
f0104e11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e16:	e9 7d 04 00 00       	jmp    f0105298 <syscall+0x6b4>
f0104e1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e20:	e9 73 04 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
	if (!page)
	{
		return -E_NO_MEM;
f0104e25:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104e2a:	e9 69 04 00 00       	jmp    f0105298 <syscall+0x6b4>
	{
		page_free(page);
		return -E_NO_MEM;
	}

	return 0;
f0104e2f:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_getenvid: return sys_getenvid();
		case SYS_env_destroy: return sys_env_destroy(a1);
		case SYS_yield: sys_yield(); return 0;
		case SYS_exofork: return sys_exofork();
		case SYS_env_set_status: return sys_env_set_status(a1,a2);
		case SYS_page_alloc: return sys_page_alloc(a1,(void*)a2,a3);
f0104e34:	e9 5f 04 00 00       	jmp    f0105298 <syscall+0x6b4>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *src, *dst;
	if (envid2env(srcenvid, &src, 1) < 0 || envid2env(dstenvid, &dst, 1) < 0)
f0104e39:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e40:	00 
f0104e41:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e48:	89 34 24             	mov    %esi,(%esp)
f0104e4b:	e8 a8 e7 ff ff       	call   f01035f8 <envid2env>
f0104e50:	85 c0                	test   %eax,%eax
f0104e52:	0f 88 ba 00 00 00    	js     f0104f12 <syscall+0x32e>
f0104e58:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e5f:	00 
f0104e60:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104e63:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e67:	89 1c 24             	mov    %ebx,(%esp)
f0104e6a:	e8 89 e7 ff ff       	call   f01035f8 <envid2env>
f0104e6f:	85 c0                	test   %eax,%eax
f0104e71:	0f 88 a5 00 00 00    	js     f0104f1c <syscall+0x338>
	{
		return -E_BAD_ENV;
	}
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP ||
f0104e77:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104e7d:	0f 87 a3 00 00 00    	ja     f0104f26 <syscall+0x342>
f0104e83:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104e8a:	0f 87 a0 00 00 00    	ja     f0104f30 <syscall+0x34c>
	return receive(va, len);
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
f0104e90:	8b 45 18             	mov    0x18(%ebp),%eax
f0104e93:	09 f8                	or     %edi,%eax
	if (envid2env(srcenvid, &src, 1) < 0 || envid2env(dstenvid, &dst, 1) < 0)
	{
		return -E_BAD_ENV;
	}
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP ||
		(uintptr_t)srcva % PGSIZE || (uintptr_t)dstva % PGSIZE)
f0104e95:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104e9a:	0f 85 9a 00 00 00    	jne    f0104f3a <syscall+0x356>
	{
		return -E_INVAL;
	}
	int must_perm = PTE_U | PTE_P;
	if ((perm & must_perm) != must_perm || (perm & ~PTE_SYSCALL))
f0104ea0:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104ea3:	83 e0 05             	and    $0x5,%eax
f0104ea6:	83 f8 05             	cmp    $0x5,%eax
f0104ea9:	0f 85 95 00 00 00    	jne    f0104f44 <syscall+0x360>
f0104eaf:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104eb6:	0f 85 92 00 00 00    	jne    f0104f4e <syscall+0x36a>
	{
		return -E_INVAL;
	}
	pte_t *pte;
	struct PageInfo *page;
	if (!(page = page_lookup(src->env_pgdir, srcva, &pte)))
f0104ebc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ebf:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ec3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104ec7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104eca:	8b 40 60             	mov    0x60(%eax),%eax
f0104ecd:	89 04 24             	mov    %eax,(%esp)
f0104ed0:	e8 ed c2 ff ff       	call   f01011c2 <page_lookup>
f0104ed5:	85 c0                	test   %eax,%eax
f0104ed7:	74 7f                	je     f0104f58 <syscall+0x374>
	{
		return -E_INVAL;
	}
	if ((perm & PTE_W) && ((*pte) & PTE_W) != PTE_W)
f0104ed9:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104edd:	74 08                	je     f0104ee7 <syscall+0x303>
f0104edf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ee2:	f6 02 02             	testb  $0x2,(%edx)
f0104ee5:	74 7b                	je     f0104f62 <syscall+0x37e>
	{
		return -E_INVAL;
	}
	if(page_insert(dst->env_pgdir,page,dstva,perm)<0){
f0104ee7:	8b 75 1c             	mov    0x1c(%ebp),%esi
f0104eea:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104eee:	8b 75 18             	mov    0x18(%ebp),%esi
f0104ef1:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104efc:	8b 40 60             	mov    0x60(%eax),%eax
f0104eff:	89 04 24             	mov    %eax,(%esp)
f0104f02:	e8 cf c3 ff ff       	call   f01012d6 <page_insert>
		return -E_NO_MEM;
f0104f07:	c1 f8 1f             	sar    $0x1f,%eax
f0104f0a:	83 e0 fc             	and    $0xfffffffc,%eax
f0104f0d:	e9 86 03 00 00       	jmp    f0105298 <syscall+0x6b4>

	// LAB 4: Your code here.
	struct Env *src, *dst;
	if (envid2env(srcenvid, &src, 1) < 0 || envid2env(dstenvid, &dst, 1) < 0)
	{
		return -E_BAD_ENV;
f0104f12:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f17:	e9 7c 03 00 00       	jmp    f0105298 <syscall+0x6b4>
f0104f1c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f21:	e9 72 03 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP ||
		(uintptr_t)srcva % PGSIZE || (uintptr_t)dstva % PGSIZE)
	{
		return -E_INVAL;
f0104f26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f2b:	e9 68 03 00 00       	jmp    f0105298 <syscall+0x6b4>
f0104f30:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f35:	e9 5e 03 00 00       	jmp    f0105298 <syscall+0x6b4>
f0104f3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f3f:	e9 54 03 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	int must_perm = PTE_U | PTE_P;
	if ((perm & must_perm) != must_perm || (perm & ~PTE_SYSCALL))
	{
		return -E_INVAL;
f0104f44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f49:	e9 4a 03 00 00       	jmp    f0105298 <syscall+0x6b4>
f0104f4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f53:	e9 40 03 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	pte_t *pte;
	struct PageInfo *page;
	if (!(page = page_lookup(src->env_pgdir, srcva, &pte)))
	{
		return -E_INVAL;
f0104f58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f5d:	e9 36 03 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	if ((perm & PTE_W) && ((*pte) & PTE_W) != PTE_W)
	{
		return -E_INVAL;
f0104f62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f67:	e9 2c 03 00 00       	jmp    f0105298 <syscall+0x6b4>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *cur;
	if (envid2env(envid, &cur, 1) < 0)
f0104f6c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f73:	00 
f0104f74:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f7b:	89 34 24             	mov    %esi,(%esp)
f0104f7e:	e8 75 e6 ff ff       	call   f01035f8 <envid2env>
f0104f83:	85 c0                	test   %eax,%eax
f0104f85:	78 2c                	js     f0104fb3 <syscall+0x3cf>
	{
		return -E_BAD_ENV;
	}
	if((uintptr_t)va >= UTOP || (uintptr_t)va %PGSIZE){
f0104f87:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104f8d:	77 2e                	ja     f0104fbd <syscall+0x3d9>
f0104f8f:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104f95:	75 30                	jne    f0104fc7 <syscall+0x3e3>
		return -E_INVAL;
	}
	page_remove(cur->env_pgdir,va);
f0104f97:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104f9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f9e:	8b 40 60             	mov    0x60(%eax),%eax
f0104fa1:	89 04 24             	mov    %eax,(%esp)
f0104fa4:	e8 db c2 ff ff       	call   f0101284 <page_remove>

	return 0;
f0104fa9:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fae:	e9 e5 02 00 00       	jmp    f0105298 <syscall+0x6b4>

	// LAB 4: Your code here.
	struct Env *cur;
	if (envid2env(envid, &cur, 1) < 0)
	{
		return -E_BAD_ENV;
f0104fb3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104fb8:	e9 db 02 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	if((uintptr_t)va >= UTOP || (uintptr_t)va %PGSIZE){
		return -E_INVAL;
f0104fbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104fc2:	e9 d1 02 00 00       	jmp    f0105298 <syscall+0x6b4>
f0104fc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_yield: sys_yield(); return 0;
		case SYS_exofork: return sys_exofork();
		case SYS_env_set_status: return sys_env_set_status(a1,a2);
		case SYS_page_alloc: return sys_page_alloc(a1,(void*)a2,a3);
		case SYS_page_map: return sys_page_map(a1,(void*)a2,a3,(void*)a4,a5);
		case SYS_page_unmap: return sys_page_unmap(a1,(void*)a2);
f0104fcc:	e9 c7 02 00 00       	jmp    f0105298 <syscall+0x6b4>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *cur;
	if(envid2env(envid,&cur,1)<0){
f0104fd1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104fd8:	00 
f0104fd9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fe0:	89 34 24             	mov    %esi,(%esp)
f0104fe3:	e8 10 e6 ff ff       	call   f01035f8 <envid2env>
f0104fe8:	85 c0                	test   %eax,%eax
f0104fea:	78 10                	js     f0104ffc <syscall+0x418>
		return -E_BAD_ENV;
	}
	cur->env_pgfault_upcall=func;
f0104fec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fef:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0104ff2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ff7:	e9 9c 02 00 00       	jmp    f0105298 <syscall+0x6b4>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *cur;
	if(envid2env(envid,&cur,1)<0){
		return -E_BAD_ENV;
f0104ffc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		case SYS_exofork: return sys_exofork();
		case SYS_env_set_status: return sys_env_set_status(a1,a2);
		case SYS_page_alloc: return sys_page_alloc(a1,(void*)a2,a3);
		case SYS_page_map: return sys_page_map(a1,(void*)a2,a3,(void*)a4,a5);
		case SYS_page_unmap: return sys_page_unmap(a1,(void*)a2);
		case SYS_env_set_pgfault_upcall: return sys_env_set_pgfault_upcall(a1,(void*)a2);
f0105001:	e9 92 02 00 00       	jmp    f0105298 <syscall+0x6b4>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	uintptr_t va = (uintptr_t)dstva;
	if (va < UTOP && va % PGSIZE)
f0105006:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f010500c:	77 0c                	ja     f010501a <syscall+0x436>
f010500e:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0105014:	0f 85 79 02 00 00    	jne    f0105293 <syscall+0x6af>
	{
		return -E_INVAL;
	}
	curenv->env_ipc_recving = 1;
f010501a:	e8 dd 13 00 00       	call   f01063fc <cpunum>
f010501f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105022:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f0105028:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f010502c:	e8 cb 13 00 00       	call   f01063fc <cpunum>
f0105031:	6b c0 74             	imul   $0x74,%eax,%eax
f0105034:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f010503a:	89 70 6c             	mov    %esi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f010503d:	e8 ba 13 00 00       	call   f01063fc <cpunum>
f0105042:	6b c0 74             	imul   $0x74,%eax,%eax
f0105045:	8b 80 28 20 2e f0    	mov    -0xfd1dfd8(%eax),%eax
f010504b:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0105052:	e8 9b fa ff ff       	call   f0104af2 <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env *cur;
	uintptr_t va = (uintptr_t)srcva;
	if (envid2env(envid, &cur, 0) < 0)
f0105057:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010505e:	00 
f010505f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105062:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105066:	89 34 24             	mov    %esi,(%esp)
f0105069:	e8 8a e5 ff ff       	call   f01035f8 <envid2env>
f010506e:	85 c0                	test   %eax,%eax
f0105070:	0f 88 07 01 00 00    	js     f010517d <syscall+0x599>
	{
		return -E_BAD_ENV;
	}
	if (!cur->env_ipc_recving)
f0105076:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105079:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010507d:	0f 84 04 01 00 00    	je     f0105187 <syscall+0x5a3>
	if (va < UTOP && va % PGSIZE)
	{
		-E_INVAL;
	}
	int must_perm = PTE_U | PTE_P;
	if (va < UTOP && ((perm & must_perm) != must_perm || (perm & ~PTE_SYSCALL)))
f0105083:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105089:	77 53                	ja     f01050de <syscall+0x4fa>
f010508b:	8b 45 18             	mov    0x18(%ebp),%eax
f010508e:	83 e0 05             	and    $0x5,%eax
f0105091:	83 f8 05             	cmp    $0x5,%eax
f0105094:	0f 85 f7 00 00 00    	jne    f0105191 <syscall+0x5ad>
f010509a:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f01050a1:	0f 85 f4 00 00 00    	jne    f010519b <syscall+0x5b7>
	{
		return -E_INVAL;
	}
	pte_t *pte;
	struct PageInfo *page = 0;
	if (va < UTOP && !(page = page_lookup(curenv->env_pgdir, srcva, &pte)))
f01050a7:	e8 50 13 00 00       	call   f01063fc <cpunum>
f01050ac:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01050af:	89 54 24 08          	mov    %edx,0x8(%esp)
f01050b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01050b7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01050be:	29 c2                	sub    %eax,%edx
f01050c0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01050c3:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f01050ca:	8b 40 60             	mov    0x60(%eax),%eax
f01050cd:	89 04 24             	mov    %eax,(%esp)
f01050d0:	e8 ed c0 ff ff       	call   f01011c2 <page_lookup>
f01050d5:	85 c0                	test   %eax,%eax
f01050d7:	75 0a                	jne    f01050e3 <syscall+0x4ff>
f01050d9:	e9 c7 00 00 00       	jmp    f01051a5 <syscall+0x5c1>
	if (va < UTOP && ((perm & must_perm) != must_perm || (perm & ~PTE_SYSCALL)))
	{
		return -E_INVAL;
	}
	pte_t *pte;
	struct PageInfo *page = 0;
f01050de:	b8 00 00 00 00       	mov    $0x0,%eax
	if (va < UTOP && !(page = page_lookup(curenv->env_pgdir, srcva, &pte)))
	{
		return -E_INVAL;
	}
	if ((perm & PTE_W) && !(*pte & PTE_W))
f01050e3:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01050e7:	74 0c                	je     f01050f5 <syscall+0x511>
f01050e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01050ec:	f6 02 02             	testb  $0x2,(%edx)
f01050ef:	0f 84 ba 00 00 00    	je     f01051af <syscall+0x5cb>
	{
		return -E_INVAL;
	}
	bool tp = (va < UTOP && (uintptr_t)(cur->env_ipc_dstva)< UTOP);
f01050f5:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01050fb:	77 35                	ja     f0105132 <syscall+0x54e>
f01050fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105100:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105103:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0105109:	77 27                	ja     f0105132 <syscall+0x54e>
	if (tp)
	{
		if (page_insert(cur->env_pgdir, page, cur->env_ipc_dstva, perm) < 0)
f010510b:	8b 5d 18             	mov    0x18(%ebp),%ebx
f010510e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105112:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105116:	89 44 24 04          	mov    %eax,0x4(%esp)
f010511a:	8b 42 60             	mov    0x60(%edx),%eax
f010511d:	89 04 24             	mov    %eax,(%esp)
f0105120:	e8 b1 c1 ff ff       	call   f01012d6 <page_insert>
f0105125:	85 c0                	test   %eax,%eax
f0105127:	0f 89 73 01 00 00    	jns    f01052a0 <syscall+0x6bc>
f010512d:	e9 87 00 00 00       	jmp    f01051b9 <syscall+0x5d5>
		{
			return -E_NO_MEM;
		}
	}
	cur->env_ipc_from = curenv->env_id;
f0105132:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105135:	e8 c2 12 00 00       	call   f01063fc <cpunum>
f010513a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105141:	29 c2                	sub    %eax,%edx
f0105143:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105146:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f010514d:	8b 40 48             	mov    0x48(%eax),%eax
f0105150:	89 43 74             	mov    %eax,0x74(%ebx)
	cur->env_ipc_perm = tp ? perm : 0;
f0105153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105156:	bb 00 00 00 00       	mov    $0x0,%ebx
f010515b:	89 58 78             	mov    %ebx,0x78(%eax)
	cur->env_ipc_recving = 0;
f010515e:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	cur->env_ipc_value = value;
f0105162:	89 78 70             	mov    %edi,0x70(%eax)
	cur->env_status = ENV_RUNNABLE;
f0105165:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	cur->env_tf.tf_regs.reg_eax = 0;
f010516c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0105173:	b8 00 00 00 00       	mov    $0x0,%eax
f0105178:	e9 1b 01 00 00       	jmp    f0105298 <syscall+0x6b4>
	// LAB 4: Your code here.
	struct Env *cur;
	uintptr_t va = (uintptr_t)srcva;
	if (envid2env(envid, &cur, 0) < 0)
	{
		return -E_BAD_ENV;
f010517d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105182:	e9 11 01 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	if (!cur->env_ipc_recving)
	{
		return -E_IPC_NOT_RECV;
f0105187:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f010518c:	e9 07 01 00 00       	jmp    f0105298 <syscall+0x6b4>
		-E_INVAL;
	}
	int must_perm = PTE_U | PTE_P;
	if (va < UTOP && ((perm & must_perm) != must_perm || (perm & ~PTE_SYSCALL)))
	{
		return -E_INVAL;
f0105191:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105196:	e9 fd 00 00 00       	jmp    f0105298 <syscall+0x6b4>
f010519b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051a0:	e9 f3 00 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	pte_t *pte;
	struct PageInfo *page = 0;
	if (va < UTOP && !(page = page_lookup(curenv->env_pgdir, srcva, &pte)))
	{
		return -E_INVAL;
f01051a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051aa:	e9 e9 00 00 00       	jmp    f0105298 <syscall+0x6b4>
	}
	if ((perm & PTE_W) && !(*pte & PTE_W))
	{
		return -E_INVAL;
f01051af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051b4:	e9 df 00 00 00       	jmp    f0105298 <syscall+0x6b4>
	bool tp = (va < UTOP && (uintptr_t)(cur->env_ipc_dstva)< UTOP);
	if (tp)
	{
		if (page_insert(cur->env_pgdir, page, cur->env_ipc_dstva, perm) < 0)
		{
			return -E_NO_MEM;
f01051b9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		case SYS_page_alloc: return sys_page_alloc(a1,(void*)a2,a3);
		case SYS_page_map: return sys_page_map(a1,(void*)a2,a3,(void*)a4,a5);
		case SYS_page_unmap: return sys_page_unmap(a1,(void*)a2);
		case SYS_env_set_pgfault_upcall: return sys_env_set_pgfault_upcall(a1,(void*)a2);
		case SYS_ipc_recv: return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send: return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f01051be:	e9 d5 00 00 00       	jmp    f0105298 <syscall+0x6b4>
	// Remember to check whether the user has supplied us with a good
	// address!
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01051c3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051ca:	00 
f01051cb:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01051ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051d2:	89 34 24             	mov    %esi,(%esp)
f01051d5:	e8 1e e4 ff ff       	call   f01035f8 <envid2env>
f01051da:	85 c0                	test   %eax,%eax
f01051dc:	0f 88 b6 00 00 00    	js     f0105298 <syscall+0x6b4>
		case SYS_page_map: return sys_page_map(a1,(void*)a2,a3,(void*)a4,a5);
		case SYS_page_unmap: return sys_page_unmap(a1,(void*)a2);
		case SYS_env_set_pgfault_upcall: return sys_env_set_pgfault_upcall(a1,(void*)a2);
		case SYS_ipc_recv: return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send: return sys_ipc_try_send(a1, a2, (void *)a3, a4);
		case SYS_env_set_trapframe: return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f01051e2:	89 fe                	mov    %edi,%esi
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (!tf)
f01051e4:	85 ff                	test   %edi,%edi
f01051e6:	75 1c                	jne    f0105204 <syscall+0x620>
	{
		panic("sys_env_set_trapframe, tf NULL");
f01051e8:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f01051ef:	f0 
f01051f0:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
f01051f7:	00 
f01051f8:	c7 04 24 8b 8d 10 f0 	movl   $0xf0108d8b,(%esp)
f01051ff:	e8 3c ae ff ff       	call   f0100040 <_panic>
	}
	e->env_tf = *tf;
f0105204:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105207:	b9 11 00 00 00       	mov    $0x11,%ecx
f010520c:	89 c7                	mov    %eax,%edi
f010520e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	
	e->env_tf.tf_eflags |= FL_IF;
f0105210:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105213:	8b 50 38             	mov    0x38(%eax),%edx
f0105216:	80 ce 02             	or     $0x2,%dh
	e->env_tf.tf_eflags &= ~FL_IOPL_MASK;
f0105219:	80 e6 cf             	and    $0xcf,%dh
f010521c:	89 50 38             	mov    %edx,0x38(%eax)
	
	return 0;
f010521f:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_page_map: return sys_page_map(a1,(void*)a2,a3,(void*)a4,a5);
		case SYS_page_unmap: return sys_page_unmap(a1,(void*)a2);
		case SYS_env_set_pgfault_upcall: return sys_env_set_pgfault_upcall(a1,(void*)a2);
		case SYS_ipc_recv: return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send: return sys_ipc_try_send(a1, a2, (void *)a3, a4);
		case SYS_env_set_trapframe: return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f0105224:	eb 72                	jmp    f0105298 <syscall+0x6b4>
// Return the current time.
static int
sys_time_msec(void)
{
	// LAB 6: Your code here.
	return time_msec();
f0105226:	e8 74 22 00 00       	call   f010749f <time_msec>
		case SYS_page_unmap: return sys_page_unmap(a1,(void*)a2);
		case SYS_env_set_pgfault_upcall: return sys_env_set_pgfault_upcall(a1,(void*)a2);
		case SYS_ipc_recv: return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send: return sys_ipc_try_send(a1, a2, (void *)a3, a4);
		case SYS_env_set_trapframe: return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
		case SYS_time_msec: return sys_time_msec();
f010522b:	eb 6b                	jmp    f0105298 <syscall+0x6b4>
}


static int 
sys_e1000_transmit(void *va, uint32_t len){
	if ((uintptr_t)va >= UTOP || !va)
f010522d:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105233:	77 12                	ja     f0105247 <syscall+0x663>
f0105235:	85 f6                	test   %esi,%esi
f0105237:	74 15                	je     f010524e <syscall+0x66a>
	{
		return -E_INVAL;
	}
	return transmit((char*)va,len);
f0105239:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010523d:	89 34 24             	mov    %esi,(%esp)
f0105240:	e8 8c 1a 00 00       	call   f0106cd1 <transmit>
f0105245:	eb 51                	jmp    f0105298 <syscall+0x6b4>

static int 
sys_e1000_transmit(void *va, uint32_t len){
	if ((uintptr_t)va >= UTOP || !va)
	{
		return -E_INVAL;
f0105247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010524c:	eb 4a                	jmp    f0105298 <syscall+0x6b4>
f010524e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_env_set_pgfault_upcall: return sys_env_set_pgfault_upcall(a1,(void*)a2);
		case SYS_ipc_recv: return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send: return sys_ipc_try_send(a1, a2, (void *)a3, a4);
		case SYS_env_set_trapframe: return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
		case SYS_time_msec: return sys_time_msec();
		case SYS_e1000_transmit: return sys_e1000_transmit((void*)a1,a2);
f0105253:	eb 43                	jmp    f0105298 <syscall+0x6b4>
}
	
static int
sys_e1000_receive(void *va, uint32_t *len)
{
	if ((uintptr_t)va >= UTOP || (uintptr_t)len >= UTOP || !va)
f0105255:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f010525b:	77 1a                	ja     f0105277 <syscall+0x693>
f010525d:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105263:	77 19                	ja     f010527e <syscall+0x69a>
f0105265:	85 f6                	test   %esi,%esi
f0105267:	74 1c                	je     f0105285 <syscall+0x6a1>
	{
		return -E_INVAL;
	}
	return receive(va, len);
f0105269:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010526d:	89 34 24             	mov    %esi,(%esp)
f0105270:	e8 09 1b 00 00       	call   f0106d7e <receive>
f0105275:	eb 21                	jmp    f0105298 <syscall+0x6b4>
static int
sys_e1000_receive(void *va, uint32_t *len)
{
	if ((uintptr_t)va >= UTOP || (uintptr_t)len >= UTOP || !va)
	{
		return -E_INVAL;
f0105277:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010527c:	eb 1a                	jmp    f0105298 <syscall+0x6b4>
f010527e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105283:	eb 13                	jmp    f0105298 <syscall+0x6b4>
f0105285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_ipc_recv: return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send: return sys_ipc_try_send(a1, a2, (void *)a3, a4);
		case SYS_env_set_trapframe: return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
		case SYS_time_msec: return sys_time_msec();
		case SYS_e1000_transmit: return sys_e1000_transmit((void*)a1,a2);
		case SYS_e1000_receive: return sys_e1000_receive((void*)a1,(uint32_t*)a2);
f010528a:	eb 0c                	jmp    f0105298 <syscall+0x6b4>
	default:
		return -E_INVAL;
f010528c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105291:	eb 05                	jmp    f0105298 <syscall+0x6b4>
		case SYS_env_set_status: return sys_env_set_status(a1,a2);
		case SYS_page_alloc: return sys_page_alloc(a1,(void*)a2,a3);
		case SYS_page_map: return sys_page_map(a1,(void*)a2,a3,(void*)a4,a5);
		case SYS_page_unmap: return sys_page_unmap(a1,(void*)a2);
		case SYS_env_set_pgfault_upcall: return sys_env_set_pgfault_upcall(a1,(void*)a2);
		case SYS_ipc_recv: return sys_ipc_recv((void *)a1);
f0105293:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_e1000_transmit: return sys_e1000_transmit((void*)a1,a2);
		case SYS_e1000_receive: return sys_e1000_receive((void*)a1,(uint32_t*)a2);
	default:
		return -E_INVAL;
	}
}
f0105298:	83 c4 2c             	add    $0x2c,%esp
f010529b:	5b                   	pop    %ebx
f010529c:	5e                   	pop    %esi
f010529d:	5f                   	pop    %edi
f010529e:	5d                   	pop    %ebp
f010529f:	c3                   	ret    
		if (page_insert(cur->env_pgdir, page, cur->env_ipc_dstva, perm) < 0)
		{
			return -E_NO_MEM;
		}
	}
	cur->env_ipc_from = curenv->env_id;
f01052a0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01052a3:	e8 54 11 00 00       	call   f01063fc <cpunum>
f01052a8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01052af:	29 c2                	sub    %eax,%edx
f01052b1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052b4:	8b 04 85 28 20 2e f0 	mov    -0xfd1dfd8(,%eax,4),%eax
f01052bb:	8b 40 48             	mov    0x48(%eax),%eax
f01052be:	89 46 74             	mov    %eax,0x74(%esi)
	cur->env_ipc_perm = tp ? perm : 0;
f01052c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052c4:	e9 92 fe ff ff       	jmp    f010515b <syscall+0x577>
f01052c9:	00 00                	add    %al,(%eax)
	...

f01052cc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01052cc:	55                   	push   %ebp
f01052cd:	89 e5                	mov    %esp,%ebp
f01052cf:	57                   	push   %edi
f01052d0:	56                   	push   %esi
f01052d1:	53                   	push   %ebx
f01052d2:	83 ec 14             	sub    $0x14,%esp
f01052d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01052d8:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01052db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01052de:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01052e1:	8b 1a                	mov    (%edx),%ebx
f01052e3:	8b 01                	mov    (%ecx),%eax
f01052e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01052e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f01052ef:	e9 83 00 00 00       	jmp    f0105377 <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f01052f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01052f7:	01 d8                	add    %ebx,%eax
f01052f9:	89 c7                	mov    %eax,%edi
f01052fb:	c1 ef 1f             	shr    $0x1f,%edi
f01052fe:	01 c7                	add    %eax,%edi
f0105300:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105302:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105305:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105308:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010530c:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010530e:	eb 01                	jmp    f0105311 <stab_binsearch+0x45>
			m--;
f0105310:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105311:	39 c3                	cmp    %eax,%ebx
f0105313:	7f 1e                	jg     f0105333 <stab_binsearch+0x67>
f0105315:	0f b6 0a             	movzbl (%edx),%ecx
f0105318:	83 ea 0c             	sub    $0xc,%edx
f010531b:	39 f1                	cmp    %esi,%ecx
f010531d:	75 f1                	jne    f0105310 <stab_binsearch+0x44>
f010531f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105322:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105325:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105328:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010532c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010532f:	76 18                	jbe    f0105349 <stab_binsearch+0x7d>
f0105331:	eb 05                	jmp    f0105338 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105333:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105336:	eb 3f                	jmp    f0105377 <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105338:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010533b:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010533d:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105340:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105347:	eb 2e                	jmp    f0105377 <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105349:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010534c:	73 15                	jae    f0105363 <stab_binsearch+0x97>
			*region_right = m - 1;
f010534e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105351:	49                   	dec    %ecx
f0105352:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105355:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105358:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010535a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105361:	eb 14                	jmp    f0105377 <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105363:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105366:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105369:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f010536b:	ff 45 0c             	incl   0xc(%ebp)
f010536e:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105370:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105377:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010537a:	0f 8e 74 ff ff ff    	jle    f01052f4 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105380:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105384:	75 0d                	jne    f0105393 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0105386:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105389:	8b 02                	mov    (%edx),%eax
f010538b:	48                   	dec    %eax
f010538c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010538f:	89 01                	mov    %eax,(%ecx)
f0105391:	eb 2a                	jmp    f01053bd <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105393:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105396:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105398:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010539b:	8b 0a                	mov    (%edx),%ecx
f010539d:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01053a0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01053a3:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01053a7:	eb 01                	jmp    f01053aa <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01053a9:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01053aa:	39 c8                	cmp    %ecx,%eax
f01053ac:	7e 0a                	jle    f01053b8 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f01053ae:	0f b6 1a             	movzbl (%edx),%ebx
f01053b1:	83 ea 0c             	sub    $0xc,%edx
f01053b4:	39 f3                	cmp    %esi,%ebx
f01053b6:	75 f1                	jne    f01053a9 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f01053b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01053bb:	89 02                	mov    %eax,(%edx)
	}
}
f01053bd:	83 c4 14             	add    $0x14,%esp
f01053c0:	5b                   	pop    %ebx
f01053c1:	5e                   	pop    %esi
f01053c2:	5f                   	pop    %edi
f01053c3:	5d                   	pop    %ebp
f01053c4:	c3                   	ret    

f01053c5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01053c5:	55                   	push   %ebp
f01053c6:	89 e5                	mov    %esp,%ebp
f01053c8:	57                   	push   %edi
f01053c9:	56                   	push   %esi
f01053ca:	53                   	push   %ebx
f01053cb:	83 ec 5c             	sub    $0x5c,%esp
f01053ce:	8b 75 08             	mov    0x8(%ebp),%esi
f01053d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01053d4:	c7 03 00 8e 10 f0    	movl   $0xf0108e00,(%ebx)
	info->eip_line = 0;
f01053da:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01053e1:	c7 43 08 00 8e 10 f0 	movl   $0xf0108e00,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01053e8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01053ef:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01053f2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01053f9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01053ff:	77 22                	ja     f0105423 <debuginfo_eip+0x5e>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0105401:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0105407:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010540a:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010540f:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0105415:	89 7d bc             	mov    %edi,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105418:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f010541e:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0105421:	eb 1a                	jmp    f010543d <debuginfo_eip+0x78>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105423:	c7 45 c0 c4 1a 12 f0 	movl   $0xf0121ac4,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010542a:	c7 45 bc d9 64 11 f0 	movl   $0xf01164d9,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105431:	b8 d8 64 11 f0       	mov    $0xf01164d8,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105436:	c7 45 c4 d4 96 10 f0 	movl   $0xf01096d4,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010543d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105440:	39 7d bc             	cmp    %edi,-0x44(%ebp)
f0105443:	0f 83 8b 01 00 00    	jae    f01055d4 <debuginfo_eip+0x20f>
f0105449:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010544d:	0f 85 88 01 00 00    	jne    f01055db <debuginfo_eip+0x216>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105453:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010545a:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f010545d:	c1 f8 02             	sar    $0x2,%eax
f0105460:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0105463:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105466:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105469:	89 d1                	mov    %edx,%ecx
f010546b:	c1 e1 08             	shl    $0x8,%ecx
f010546e:	01 ca                	add    %ecx,%edx
f0105470:	89 d1                	mov    %edx,%ecx
f0105472:	c1 e1 10             	shl    $0x10,%ecx
f0105475:	01 ca                	add    %ecx,%edx
f0105477:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f010547b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010547e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105482:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105489:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010548c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010548f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105492:	e8 35 fe ff ff       	call   f01052cc <stab_binsearch>
	if (lfile == 0)
f0105497:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010549a:	85 c0                	test   %eax,%eax
f010549c:	0f 84 40 01 00 00    	je     f01055e2 <debuginfo_eip+0x21d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01054a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01054a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01054ab:	89 74 24 04          	mov    %esi,0x4(%esp)
f01054af:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01054b6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01054b9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01054bc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01054bf:	e8 08 fe ff ff       	call   f01052cc <stab_binsearch>

	if (lfun <= rfun) {
f01054c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01054c7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01054ca:	39 d0                	cmp    %edx,%eax
f01054cc:	7f 32                	jg     f0105500 <debuginfo_eip+0x13b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01054ce:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01054d1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01054d4:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01054d7:	8b 39                	mov    (%ecx),%edi
f01054d9:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01054dc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01054df:	2b 7d bc             	sub    -0x44(%ebp),%edi
f01054e2:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01054e5:	73 09                	jae    f01054f0 <debuginfo_eip+0x12b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01054e7:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01054ea:	03 7d bc             	add    -0x44(%ebp),%edi
f01054ed:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01054f0:	8b 49 08             	mov    0x8(%ecx),%ecx
f01054f3:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01054f6:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01054f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01054fb:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01054fe:	eb 0f                	jmp    f010550f <debuginfo_eip+0x14a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105500:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105503:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105506:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105509:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010550c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010550f:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105516:	00 
f0105517:	8b 43 08             	mov    0x8(%ebx),%eax
f010551a:	89 04 24             	mov    %eax,(%esp)
f010551d:	e8 84 08 00 00       	call   f0105da6 <strfind>
f0105522:	2b 43 08             	sub    0x8(%ebx),%eax
f0105525:	89 43 0c             	mov    %eax,0xc(%ebx)

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105528:	89 74 24 04          	mov    %esi,0x4(%esp)
f010552c:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105533:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105536:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105539:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010553c:	e8 8b fd ff ff       	call   f01052cc <stab_binsearch>
	
	if(lline <= rline){
f0105541:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105544:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0105547:	0f 8f 9c 00 00 00    	jg     f01055e9 <debuginfo_eip+0x224>
		info->eip_line=stabs[rline].n_desc;
f010554d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105550:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105553:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0105558:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010555b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010555e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105561:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105564:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f0105568:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010556b:	eb 04                	jmp    f0105571 <debuginfo_eip+0x1ac>
f010556d:	48                   	dec    %eax
f010556e:	83 ea 0c             	sub    $0xc,%edx
f0105571:	89 c7                	mov    %eax,%edi
f0105573:	39 c6                	cmp    %eax,%esi
f0105575:	7f 25                	jg     f010559c <debuginfo_eip+0x1d7>
	       && stabs[lline].n_type != N_SOL
f0105577:	8a 4a fc             	mov    -0x4(%edx),%cl
f010557a:	80 f9 84             	cmp    $0x84,%cl
f010557d:	0f 84 81 00 00 00    	je     f0105604 <debuginfo_eip+0x23f>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105583:	80 f9 64             	cmp    $0x64,%cl
f0105586:	75 e5                	jne    f010556d <debuginfo_eip+0x1a8>
f0105588:	83 3a 00             	cmpl   $0x0,(%edx)
f010558b:	74 e0                	je     f010556d <debuginfo_eip+0x1a8>
f010558d:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105590:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105593:	eb 75                	jmp    f010560a <debuginfo_eip+0x245>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105595:	03 45 bc             	add    -0x44(%ebp),%eax
f0105598:	89 03                	mov    %eax,(%ebx)
f010559a:	eb 03                	jmp    f010559f <debuginfo_eip+0x1da>
f010559c:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010559f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01055a2:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01055a5:	39 f2                	cmp    %esi,%edx
f01055a7:	7d 47                	jge    f01055f0 <debuginfo_eip+0x22b>
		for (lline = lfun + 1;
f01055a9:	42                   	inc    %edx
f01055aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01055ad:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055af:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01055b2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01055b5:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01055b9:	eb 03                	jmp    f01055be <debuginfo_eip+0x1f9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01055bb:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01055be:	39 f0                	cmp    %esi,%eax
f01055c0:	7d 35                	jge    f01055f7 <debuginfo_eip+0x232>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055c2:	8a 0a                	mov    (%edx),%cl
f01055c4:	40                   	inc    %eax
f01055c5:	83 c2 0c             	add    $0xc,%edx
f01055c8:	80 f9 a0             	cmp    $0xa0,%cl
f01055cb:	74 ee                	je     f01055bb <debuginfo_eip+0x1f6>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01055cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01055d2:	eb 28                	jmp    f01055fc <debuginfo_eip+0x237>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01055d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055d9:	eb 21                	jmp    f01055fc <debuginfo_eip+0x237>
f01055db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055e0:	eb 1a                	jmp    f01055fc <debuginfo_eip+0x237>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01055e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055e7:	eb 13                	jmp    f01055fc <debuginfo_eip+0x237>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	
	if(lline <= rline){
		info->eip_line=stabs[rline].n_desc;
	}else{
		return -1;
f01055e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055ee:	eb 0c                	jmp    f01055fc <debuginfo_eip+0x237>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01055f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01055f5:	eb 05                	jmp    f01055fc <debuginfo_eip+0x237>
f01055f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055fc:	83 c4 5c             	add    $0x5c,%esp
f01055ff:	5b                   	pop    %ebx
f0105600:	5e                   	pop    %esi
f0105601:	5f                   	pop    %edi
f0105602:	5d                   	pop    %ebp
f0105603:	c3                   	ret    
f0105604:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105607:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010560a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010560d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105610:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0105613:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105616:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105619:	39 d0                	cmp    %edx,%eax
f010561b:	0f 82 74 ff ff ff    	jb     f0105595 <debuginfo_eip+0x1d0>
f0105621:	e9 79 ff ff ff       	jmp    f010559f <debuginfo_eip+0x1da>
	...

f0105628 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105628:	55                   	push   %ebp
f0105629:	89 e5                	mov    %esp,%ebp
f010562b:	57                   	push   %edi
f010562c:	56                   	push   %esi
f010562d:	53                   	push   %ebx
f010562e:	83 ec 3c             	sub    $0x3c,%esp
f0105631:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105634:	89 d7                	mov    %edx,%edi
f0105636:	8b 45 08             	mov    0x8(%ebp),%eax
f0105639:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010563c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010563f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105642:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105645:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105648:	85 c0                	test   %eax,%eax
f010564a:	75 08                	jne    f0105654 <printnum+0x2c>
f010564c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010564f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105652:	77 57                	ja     f01056ab <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105654:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105658:	4b                   	dec    %ebx
f0105659:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010565d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105660:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105664:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105668:	8b 74 24 0c          	mov    0xc(%esp),%esi
f010566c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105673:	00 
f0105674:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105677:	89 04 24             	mov    %eax,(%esp)
f010567a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010567d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105681:	e8 2a 1e 00 00       	call   f01074b0 <__udivdi3>
f0105686:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010568a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010568e:	89 04 24             	mov    %eax,(%esp)
f0105691:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105695:	89 fa                	mov    %edi,%edx
f0105697:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010569a:	e8 89 ff ff ff       	call   f0105628 <printnum>
f010569f:	eb 0f                	jmp    f01056b0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01056a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056a5:	89 34 24             	mov    %esi,(%esp)
f01056a8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01056ab:	4b                   	dec    %ebx
f01056ac:	85 db                	test   %ebx,%ebx
f01056ae:	7f f1                	jg     f01056a1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01056b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056b4:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01056b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01056bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01056bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01056c6:	00 
f01056c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01056ca:	89 04 24             	mov    %eax,(%esp)
f01056cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056d4:	e8 f7 1e 00 00       	call   f01075d0 <__umoddi3>
f01056d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056dd:	0f be 80 0a 8e 10 f0 	movsbl -0xfef71f6(%eax),%eax
f01056e4:	89 04 24             	mov    %eax,(%esp)
f01056e7:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01056ea:	83 c4 3c             	add    $0x3c,%esp
f01056ed:	5b                   	pop    %ebx
f01056ee:	5e                   	pop    %esi
f01056ef:	5f                   	pop    %edi
f01056f0:	5d                   	pop    %ebp
f01056f1:	c3                   	ret    

f01056f2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01056f2:	55                   	push   %ebp
f01056f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01056f5:	83 fa 01             	cmp    $0x1,%edx
f01056f8:	7e 0e                	jle    f0105708 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01056fa:	8b 10                	mov    (%eax),%edx
f01056fc:	8d 4a 08             	lea    0x8(%edx),%ecx
f01056ff:	89 08                	mov    %ecx,(%eax)
f0105701:	8b 02                	mov    (%edx),%eax
f0105703:	8b 52 04             	mov    0x4(%edx),%edx
f0105706:	eb 22                	jmp    f010572a <getuint+0x38>
	else if (lflag)
f0105708:	85 d2                	test   %edx,%edx
f010570a:	74 10                	je     f010571c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010570c:	8b 10                	mov    (%eax),%edx
f010570e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105711:	89 08                	mov    %ecx,(%eax)
f0105713:	8b 02                	mov    (%edx),%eax
f0105715:	ba 00 00 00 00       	mov    $0x0,%edx
f010571a:	eb 0e                	jmp    f010572a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010571c:	8b 10                	mov    (%eax),%edx
f010571e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105721:	89 08                	mov    %ecx,(%eax)
f0105723:	8b 02                	mov    (%edx),%eax
f0105725:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010572a:	5d                   	pop    %ebp
f010572b:	c3                   	ret    

f010572c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010572c:	55                   	push   %ebp
f010572d:	89 e5                	mov    %esp,%ebp
f010572f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105732:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105735:	8b 10                	mov    (%eax),%edx
f0105737:	3b 50 04             	cmp    0x4(%eax),%edx
f010573a:	73 08                	jae    f0105744 <sprintputch+0x18>
		*b->buf++ = ch;
f010573c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010573f:	88 0a                	mov    %cl,(%edx)
f0105741:	42                   	inc    %edx
f0105742:	89 10                	mov    %edx,(%eax)
}
f0105744:	5d                   	pop    %ebp
f0105745:	c3                   	ret    

f0105746 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105746:	55                   	push   %ebp
f0105747:	89 e5                	mov    %esp,%ebp
f0105749:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010574c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010574f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105753:	8b 45 10             	mov    0x10(%ebp),%eax
f0105756:	89 44 24 08          	mov    %eax,0x8(%esp)
f010575a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010575d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105761:	8b 45 08             	mov    0x8(%ebp),%eax
f0105764:	89 04 24             	mov    %eax,(%esp)
f0105767:	e8 02 00 00 00       	call   f010576e <vprintfmt>
	va_end(ap);
}
f010576c:	c9                   	leave  
f010576d:	c3                   	ret    

f010576e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010576e:	55                   	push   %ebp
f010576f:	89 e5                	mov    %esp,%ebp
f0105771:	57                   	push   %edi
f0105772:	56                   	push   %esi
f0105773:	53                   	push   %ebx
f0105774:	83 ec 4c             	sub    $0x4c,%esp
f0105777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010577a:	8b 75 10             	mov    0x10(%ebp),%esi
f010577d:	eb 12                	jmp    f0105791 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010577f:	85 c0                	test   %eax,%eax
f0105781:	0f 84 6b 03 00 00    	je     f0105af2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0105787:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010578b:	89 04 24             	mov    %eax,(%esp)
f010578e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105791:	0f b6 06             	movzbl (%esi),%eax
f0105794:	46                   	inc    %esi
f0105795:	83 f8 25             	cmp    $0x25,%eax
f0105798:	75 e5                	jne    f010577f <vprintfmt+0x11>
f010579a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f010579e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01057a5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01057aa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01057b1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057b6:	eb 26                	jmp    f01057de <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057b8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01057bb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01057bf:	eb 1d                	jmp    f01057de <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01057c4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01057c8:	eb 14                	jmp    f01057de <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01057cd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01057d4:	eb 08                	jmp    f01057de <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01057d6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01057d9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057de:	0f b6 06             	movzbl (%esi),%eax
f01057e1:	8d 56 01             	lea    0x1(%esi),%edx
f01057e4:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01057e7:	8a 16                	mov    (%esi),%dl
f01057e9:	83 ea 23             	sub    $0x23,%edx
f01057ec:	80 fa 55             	cmp    $0x55,%dl
f01057ef:	0f 87 e1 02 00 00    	ja     f0105ad6 <vprintfmt+0x368>
f01057f5:	0f b6 d2             	movzbl %dl,%edx
f01057f8:	ff 24 95 40 8f 10 f0 	jmp    *-0xfef70c0(,%edx,4)
f01057ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105802:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105807:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010580a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010580e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105811:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105814:	83 fa 09             	cmp    $0x9,%edx
f0105817:	77 2a                	ja     f0105843 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105819:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010581a:	eb eb                	jmp    f0105807 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010581c:	8b 45 14             	mov    0x14(%ebp),%eax
f010581f:	8d 50 04             	lea    0x4(%eax),%edx
f0105822:	89 55 14             	mov    %edx,0x14(%ebp)
f0105825:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105827:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010582a:	eb 17                	jmp    f0105843 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f010582c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105830:	78 98                	js     f01057ca <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105832:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105835:	eb a7                	jmp    f01057de <vprintfmt+0x70>
f0105837:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010583a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105841:	eb 9b                	jmp    f01057de <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105843:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105847:	79 95                	jns    f01057de <vprintfmt+0x70>
f0105849:	eb 8b                	jmp    f01057d6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010584b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010584c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010584f:	eb 8d                	jmp    f01057de <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105851:	8b 45 14             	mov    0x14(%ebp),%eax
f0105854:	8d 50 04             	lea    0x4(%eax),%edx
f0105857:	89 55 14             	mov    %edx,0x14(%ebp)
f010585a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010585e:	8b 00                	mov    (%eax),%eax
f0105860:	89 04 24             	mov    %eax,(%esp)
f0105863:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105866:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105869:	e9 23 ff ff ff       	jmp    f0105791 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010586e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105871:	8d 50 04             	lea    0x4(%eax),%edx
f0105874:	89 55 14             	mov    %edx,0x14(%ebp)
f0105877:	8b 00                	mov    (%eax),%eax
f0105879:	85 c0                	test   %eax,%eax
f010587b:	79 02                	jns    f010587f <vprintfmt+0x111>
f010587d:	f7 d8                	neg    %eax
f010587f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105881:	83 f8 10             	cmp    $0x10,%eax
f0105884:	7f 0b                	jg     f0105891 <vprintfmt+0x123>
f0105886:	8b 04 85 a0 90 10 f0 	mov    -0xfef6f60(,%eax,4),%eax
f010588d:	85 c0                	test   %eax,%eax
f010588f:	75 23                	jne    f01058b4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0105891:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105895:	c7 44 24 08 22 8e 10 	movl   $0xf0108e22,0x8(%esp)
f010589c:	f0 
f010589d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01058a4:	89 04 24             	mov    %eax,(%esp)
f01058a7:	e8 9a fe ff ff       	call   f0105746 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01058af:	e9 dd fe ff ff       	jmp    f0105791 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01058b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01058b8:	c7 44 24 08 22 86 10 	movl   $0xf0108622,0x8(%esp)
f01058bf:	f0 
f01058c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058c4:	8b 55 08             	mov    0x8(%ebp),%edx
f01058c7:	89 14 24             	mov    %edx,(%esp)
f01058ca:	e8 77 fe ff ff       	call   f0105746 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01058d2:	e9 ba fe ff ff       	jmp    f0105791 <vprintfmt+0x23>
f01058d7:	89 f9                	mov    %edi,%ecx
f01058d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01058df:	8b 45 14             	mov    0x14(%ebp),%eax
f01058e2:	8d 50 04             	lea    0x4(%eax),%edx
f01058e5:	89 55 14             	mov    %edx,0x14(%ebp)
f01058e8:	8b 30                	mov    (%eax),%esi
f01058ea:	85 f6                	test   %esi,%esi
f01058ec:	75 05                	jne    f01058f3 <vprintfmt+0x185>
				p = "(null)";
f01058ee:	be 1b 8e 10 f0       	mov    $0xf0108e1b,%esi
			if (width > 0 && padc != '-')
f01058f3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01058f7:	0f 8e 84 00 00 00    	jle    f0105981 <vprintfmt+0x213>
f01058fd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105901:	74 7e                	je     f0105981 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105903:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105907:	89 34 24             	mov    %esi,(%esp)
f010590a:	e8 63 03 00 00       	call   f0105c72 <strnlen>
f010590f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105912:	29 c2                	sub    %eax,%edx
f0105914:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105917:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010591b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010591e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105921:	89 de                	mov    %ebx,%esi
f0105923:	89 d3                	mov    %edx,%ebx
f0105925:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105927:	eb 0b                	jmp    f0105934 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105929:	89 74 24 04          	mov    %esi,0x4(%esp)
f010592d:	89 3c 24             	mov    %edi,(%esp)
f0105930:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105933:	4b                   	dec    %ebx
f0105934:	85 db                	test   %ebx,%ebx
f0105936:	7f f1                	jg     f0105929 <vprintfmt+0x1bb>
f0105938:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010593b:	89 f3                	mov    %esi,%ebx
f010593d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105940:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105943:	85 c0                	test   %eax,%eax
f0105945:	79 05                	jns    f010594c <vprintfmt+0x1de>
f0105947:	b8 00 00 00 00       	mov    $0x0,%eax
f010594c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010594f:	29 c2                	sub    %eax,%edx
f0105951:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105954:	eb 2b                	jmp    f0105981 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105956:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010595a:	74 18                	je     f0105974 <vprintfmt+0x206>
f010595c:	8d 50 e0             	lea    -0x20(%eax),%edx
f010595f:	83 fa 5e             	cmp    $0x5e,%edx
f0105962:	76 10                	jbe    f0105974 <vprintfmt+0x206>
					putch('?', putdat);
f0105964:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105968:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010596f:	ff 55 08             	call   *0x8(%ebp)
f0105972:	eb 0a                	jmp    f010597e <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105974:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105978:	89 04 24             	mov    %eax,(%esp)
f010597b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010597e:	ff 4d e4             	decl   -0x1c(%ebp)
f0105981:	0f be 06             	movsbl (%esi),%eax
f0105984:	46                   	inc    %esi
f0105985:	85 c0                	test   %eax,%eax
f0105987:	74 21                	je     f01059aa <vprintfmt+0x23c>
f0105989:	85 ff                	test   %edi,%edi
f010598b:	78 c9                	js     f0105956 <vprintfmt+0x1e8>
f010598d:	4f                   	dec    %edi
f010598e:	79 c6                	jns    f0105956 <vprintfmt+0x1e8>
f0105990:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105993:	89 de                	mov    %ebx,%esi
f0105995:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105998:	eb 18                	jmp    f01059b2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010599a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010599e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01059a5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01059a7:	4b                   	dec    %ebx
f01059a8:	eb 08                	jmp    f01059b2 <vprintfmt+0x244>
f01059aa:	8b 7d 08             	mov    0x8(%ebp),%edi
f01059ad:	89 de                	mov    %ebx,%esi
f01059af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01059b2:	85 db                	test   %ebx,%ebx
f01059b4:	7f e4                	jg     f010599a <vprintfmt+0x22c>
f01059b6:	89 7d 08             	mov    %edi,0x8(%ebp)
f01059b9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01059be:	e9 ce fd ff ff       	jmp    f0105791 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01059c3:	83 f9 01             	cmp    $0x1,%ecx
f01059c6:	7e 10                	jle    f01059d8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f01059c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01059cb:	8d 50 08             	lea    0x8(%eax),%edx
f01059ce:	89 55 14             	mov    %edx,0x14(%ebp)
f01059d1:	8b 30                	mov    (%eax),%esi
f01059d3:	8b 78 04             	mov    0x4(%eax),%edi
f01059d6:	eb 26                	jmp    f01059fe <vprintfmt+0x290>
	else if (lflag)
f01059d8:	85 c9                	test   %ecx,%ecx
f01059da:	74 12                	je     f01059ee <vprintfmt+0x280>
		return va_arg(*ap, long);
f01059dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01059df:	8d 50 04             	lea    0x4(%eax),%edx
f01059e2:	89 55 14             	mov    %edx,0x14(%ebp)
f01059e5:	8b 30                	mov    (%eax),%esi
f01059e7:	89 f7                	mov    %esi,%edi
f01059e9:	c1 ff 1f             	sar    $0x1f,%edi
f01059ec:	eb 10                	jmp    f01059fe <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f01059ee:	8b 45 14             	mov    0x14(%ebp),%eax
f01059f1:	8d 50 04             	lea    0x4(%eax),%edx
f01059f4:	89 55 14             	mov    %edx,0x14(%ebp)
f01059f7:	8b 30                	mov    (%eax),%esi
f01059f9:	89 f7                	mov    %esi,%edi
f01059fb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01059fe:	85 ff                	test   %edi,%edi
f0105a00:	78 0a                	js     f0105a0c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105a02:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a07:	e9 8c 00 00 00       	jmp    f0105a98 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105a0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a10:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105a17:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105a1a:	f7 de                	neg    %esi
f0105a1c:	83 d7 00             	adc    $0x0,%edi
f0105a1f:	f7 df                	neg    %edi
			}
			base = 10;
f0105a21:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a26:	eb 70                	jmp    f0105a98 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105a28:	89 ca                	mov    %ecx,%edx
f0105a2a:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a2d:	e8 c0 fc ff ff       	call   f01056f2 <getuint>
f0105a32:	89 c6                	mov    %eax,%esi
f0105a34:	89 d7                	mov    %edx,%edi
			base = 10;
f0105a36:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105a3b:	eb 5b                	jmp    f0105a98 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
f0105a3d:	89 ca                	mov    %ecx,%edx
f0105a3f:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a42:	e8 ab fc ff ff       	call   f01056f2 <getuint>
f0105a47:	89 c6                	mov    %eax,%esi
f0105a49:	89 d7                	mov    %edx,%edi
			base = 8;
f0105a4b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105a50:	eb 46                	jmp    f0105a98 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
f0105a52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a56:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105a5d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105a60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a64:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105a6b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105a6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a71:	8d 50 04             	lea    0x4(%eax),%edx
f0105a74:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105a77:	8b 30                	mov    (%eax),%esi
f0105a79:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105a7e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105a83:	eb 13                	jmp    f0105a98 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105a85:	89 ca                	mov    %ecx,%edx
f0105a87:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a8a:	e8 63 fc ff ff       	call   f01056f2 <getuint>
f0105a8f:	89 c6                	mov    %eax,%esi
f0105a91:	89 d7                	mov    %edx,%edi
			base = 16;
f0105a93:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105a98:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105a9c:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105aa0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105aa3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105aab:	89 34 24             	mov    %esi,(%esp)
f0105aae:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ab2:	89 da                	mov    %ebx,%edx
f0105ab4:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ab7:	e8 6c fb ff ff       	call   f0105628 <printnum>
			break;
f0105abc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105abf:	e9 cd fc ff ff       	jmp    f0105791 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105ac4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ac8:	89 04 24             	mov    %eax,(%esp)
f0105acb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ace:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105ad1:	e9 bb fc ff ff       	jmp    f0105791 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105ad6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ada:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105ae1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105ae4:	eb 01                	jmp    f0105ae7 <vprintfmt+0x379>
f0105ae6:	4e                   	dec    %esi
f0105ae7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105aeb:	75 f9                	jne    f0105ae6 <vprintfmt+0x378>
f0105aed:	e9 9f fc ff ff       	jmp    f0105791 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105af2:	83 c4 4c             	add    $0x4c,%esp
f0105af5:	5b                   	pop    %ebx
f0105af6:	5e                   	pop    %esi
f0105af7:	5f                   	pop    %edi
f0105af8:	5d                   	pop    %ebp
f0105af9:	c3                   	ret    

f0105afa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105afa:	55                   	push   %ebp
f0105afb:	89 e5                	mov    %esp,%ebp
f0105afd:	83 ec 28             	sub    $0x28,%esp
f0105b00:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b03:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105b06:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b09:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105b0d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105b10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105b17:	85 c0                	test   %eax,%eax
f0105b19:	74 30                	je     f0105b4b <vsnprintf+0x51>
f0105b1b:	85 d2                	test   %edx,%edx
f0105b1d:	7e 33                	jle    f0105b52 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105b1f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b22:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b26:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b29:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b2d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105b30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b34:	c7 04 24 2c 57 10 f0 	movl   $0xf010572c,(%esp)
f0105b3b:	e8 2e fc ff ff       	call   f010576e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105b43:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105b49:	eb 0c                	jmp    f0105b57 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105b4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105b50:	eb 05                	jmp    f0105b57 <vsnprintf+0x5d>
f0105b52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105b57:	c9                   	leave  
f0105b58:	c3                   	ret    

f0105b59 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105b59:	55                   	push   %ebp
f0105b5a:	89 e5                	mov    %esp,%ebp
f0105b5c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105b5f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105b62:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b66:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b69:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b74:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b77:	89 04 24             	mov    %eax,(%esp)
f0105b7a:	e8 7b ff ff ff       	call   f0105afa <vsnprintf>
	va_end(ap);

	return rc;
}
f0105b7f:	c9                   	leave  
f0105b80:	c3                   	ret    
f0105b81:	00 00                	add    %al,(%eax)
	...

f0105b84 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105b84:	55                   	push   %ebp
f0105b85:	89 e5                	mov    %esp,%ebp
f0105b87:	57                   	push   %edi
f0105b88:	56                   	push   %esi
f0105b89:	53                   	push   %ebx
f0105b8a:	83 ec 1c             	sub    $0x1c,%esp
f0105b8d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105b90:	85 c0                	test   %eax,%eax
f0105b92:	74 10                	je     f0105ba4 <readline+0x20>
		cprintf("%s", prompt);
f0105b94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b98:	c7 04 24 22 86 10 f0 	movl   $0xf0108622,(%esp)
f0105b9f:	e8 e6 e2 ff ff       	call   f0103e8a <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105ba4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105bab:	e8 1b ac ff ff       	call   f01007cb <iscons>
f0105bb0:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105bb2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105bb7:	e8 fe ab ff ff       	call   f01007ba <getchar>
f0105bbc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105bbe:	85 c0                	test   %eax,%eax
f0105bc0:	79 20                	jns    f0105be2 <readline+0x5e>
			if (c != -E_EOF)
f0105bc2:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105bc5:	0f 84 82 00 00 00    	je     f0105c4d <readline+0xc9>
				cprintf("read error: %e\n", c);
f0105bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bcf:	c7 04 24 03 91 10 f0 	movl   $0xf0109103,(%esp)
f0105bd6:	e8 af e2 ff ff       	call   f0103e8a <cprintf>
			return NULL;
f0105bdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105be0:	eb 70                	jmp    f0105c52 <readline+0xce>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105be2:	83 f8 08             	cmp    $0x8,%eax
f0105be5:	74 05                	je     f0105bec <readline+0x68>
f0105be7:	83 f8 7f             	cmp    $0x7f,%eax
f0105bea:	75 17                	jne    f0105c03 <readline+0x7f>
f0105bec:	85 f6                	test   %esi,%esi
f0105bee:	7e 13                	jle    f0105c03 <readline+0x7f>
			if (echoing)
f0105bf0:	85 ff                	test   %edi,%edi
f0105bf2:	74 0c                	je     f0105c00 <readline+0x7c>
				cputchar('\b');
f0105bf4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105bfb:	e8 aa ab ff ff       	call   f01007aa <cputchar>
			i--;
f0105c00:	4e                   	dec    %esi
f0105c01:	eb b4                	jmp    f0105bb7 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105c03:	83 fb 1f             	cmp    $0x1f,%ebx
f0105c06:	7e 1d                	jle    f0105c25 <readline+0xa1>
f0105c08:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105c0e:	7f 15                	jg     f0105c25 <readline+0xa1>
			if (echoing)
f0105c10:	85 ff                	test   %edi,%edi
f0105c12:	74 08                	je     f0105c1c <readline+0x98>
				cputchar(c);
f0105c14:	89 1c 24             	mov    %ebx,(%esp)
f0105c17:	e8 8e ab ff ff       	call   f01007aa <cputchar>
			buf[i++] = c;
f0105c1c:	88 9e 80 1a 2e f0    	mov    %bl,-0xfd1e580(%esi)
f0105c22:	46                   	inc    %esi
f0105c23:	eb 92                	jmp    f0105bb7 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105c25:	83 fb 0a             	cmp    $0xa,%ebx
f0105c28:	74 05                	je     f0105c2f <readline+0xab>
f0105c2a:	83 fb 0d             	cmp    $0xd,%ebx
f0105c2d:	75 88                	jne    f0105bb7 <readline+0x33>
			if (echoing)
f0105c2f:	85 ff                	test   %edi,%edi
f0105c31:	74 0c                	je     f0105c3f <readline+0xbb>
				cputchar('\n');
f0105c33:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105c3a:	e8 6b ab ff ff       	call   f01007aa <cputchar>
			buf[i] = 0;
f0105c3f:	c6 86 80 1a 2e f0 00 	movb   $0x0,-0xfd1e580(%esi)
			return buf;
f0105c46:	b8 80 1a 2e f0       	mov    $0xf02e1a80,%eax
f0105c4b:	eb 05                	jmp    f0105c52 <readline+0xce>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105c4d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105c52:	83 c4 1c             	add    $0x1c,%esp
f0105c55:	5b                   	pop    %ebx
f0105c56:	5e                   	pop    %esi
f0105c57:	5f                   	pop    %edi
f0105c58:	5d                   	pop    %ebp
f0105c59:	c3                   	ret    
	...

f0105c5c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105c5c:	55                   	push   %ebp
f0105c5d:	89 e5                	mov    %esp,%ebp
f0105c5f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c62:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c67:	eb 01                	jmp    f0105c6a <strlen+0xe>
		n++;
f0105c69:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c6a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105c6e:	75 f9                	jne    f0105c69 <strlen+0xd>
		n++;
	return n;
}
f0105c70:	5d                   	pop    %ebp
f0105c71:	c3                   	ret    

f0105c72 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105c72:	55                   	push   %ebp
f0105c73:	89 e5                	mov    %esp,%ebp
f0105c75:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105c78:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c80:	eb 01                	jmp    f0105c83 <strnlen+0x11>
		n++;
f0105c82:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c83:	39 d0                	cmp    %edx,%eax
f0105c85:	74 06                	je     f0105c8d <strnlen+0x1b>
f0105c87:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105c8b:	75 f5                	jne    f0105c82 <strnlen+0x10>
		n++;
	return n;
}
f0105c8d:	5d                   	pop    %ebp
f0105c8e:	c3                   	ret    

f0105c8f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105c8f:	55                   	push   %ebp
f0105c90:	89 e5                	mov    %esp,%ebp
f0105c92:	53                   	push   %ebx
f0105c93:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105c99:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c9e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105ca1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105ca4:	42                   	inc    %edx
f0105ca5:	84 c9                	test   %cl,%cl
f0105ca7:	75 f5                	jne    f0105c9e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105ca9:	5b                   	pop    %ebx
f0105caa:	5d                   	pop    %ebp
f0105cab:	c3                   	ret    

f0105cac <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105cac:	55                   	push   %ebp
f0105cad:	89 e5                	mov    %esp,%ebp
f0105caf:	53                   	push   %ebx
f0105cb0:	83 ec 08             	sub    $0x8,%esp
f0105cb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105cb6:	89 1c 24             	mov    %ebx,(%esp)
f0105cb9:	e8 9e ff ff ff       	call   f0105c5c <strlen>
	strcpy(dst + len, src);
f0105cbe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cc1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105cc5:	01 d8                	add    %ebx,%eax
f0105cc7:	89 04 24             	mov    %eax,(%esp)
f0105cca:	e8 c0 ff ff ff       	call   f0105c8f <strcpy>
	return dst;
}
f0105ccf:	89 d8                	mov    %ebx,%eax
f0105cd1:	83 c4 08             	add    $0x8,%esp
f0105cd4:	5b                   	pop    %ebx
f0105cd5:	5d                   	pop    %ebp
f0105cd6:	c3                   	ret    

f0105cd7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105cd7:	55                   	push   %ebp
f0105cd8:	89 e5                	mov    %esp,%ebp
f0105cda:	56                   	push   %esi
f0105cdb:	53                   	push   %ebx
f0105cdc:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cdf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ce2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105ce5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105cea:	eb 0c                	jmp    f0105cf8 <strncpy+0x21>
		*dst++ = *src;
f0105cec:	8a 1a                	mov    (%edx),%bl
f0105cee:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105cf1:	80 3a 01             	cmpb   $0x1,(%edx)
f0105cf4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105cf7:	41                   	inc    %ecx
f0105cf8:	39 f1                	cmp    %esi,%ecx
f0105cfa:	75 f0                	jne    f0105cec <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105cfc:	5b                   	pop    %ebx
f0105cfd:	5e                   	pop    %esi
f0105cfe:	5d                   	pop    %ebp
f0105cff:	c3                   	ret    

f0105d00 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105d00:	55                   	push   %ebp
f0105d01:	89 e5                	mov    %esp,%ebp
f0105d03:	56                   	push   %esi
f0105d04:	53                   	push   %ebx
f0105d05:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105d0b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d0e:	85 d2                	test   %edx,%edx
f0105d10:	75 0a                	jne    f0105d1c <strlcpy+0x1c>
f0105d12:	89 f0                	mov    %esi,%eax
f0105d14:	eb 1a                	jmp    f0105d30 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105d16:	88 18                	mov    %bl,(%eax)
f0105d18:	40                   	inc    %eax
f0105d19:	41                   	inc    %ecx
f0105d1a:	eb 02                	jmp    f0105d1e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d1c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0105d1e:	4a                   	dec    %edx
f0105d1f:	74 0a                	je     f0105d2b <strlcpy+0x2b>
f0105d21:	8a 19                	mov    (%ecx),%bl
f0105d23:	84 db                	test   %bl,%bl
f0105d25:	75 ef                	jne    f0105d16 <strlcpy+0x16>
f0105d27:	89 c2                	mov    %eax,%edx
f0105d29:	eb 02                	jmp    f0105d2d <strlcpy+0x2d>
f0105d2b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105d2d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105d30:	29 f0                	sub    %esi,%eax
}
f0105d32:	5b                   	pop    %ebx
f0105d33:	5e                   	pop    %esi
f0105d34:	5d                   	pop    %ebp
f0105d35:	c3                   	ret    

f0105d36 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105d36:	55                   	push   %ebp
f0105d37:	89 e5                	mov    %esp,%ebp
f0105d39:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105d3f:	eb 02                	jmp    f0105d43 <strcmp+0xd>
		p++, q++;
f0105d41:	41                   	inc    %ecx
f0105d42:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105d43:	8a 01                	mov    (%ecx),%al
f0105d45:	84 c0                	test   %al,%al
f0105d47:	74 04                	je     f0105d4d <strcmp+0x17>
f0105d49:	3a 02                	cmp    (%edx),%al
f0105d4b:	74 f4                	je     f0105d41 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d4d:	0f b6 c0             	movzbl %al,%eax
f0105d50:	0f b6 12             	movzbl (%edx),%edx
f0105d53:	29 d0                	sub    %edx,%eax
}
f0105d55:	5d                   	pop    %ebp
f0105d56:	c3                   	ret    

f0105d57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105d57:	55                   	push   %ebp
f0105d58:	89 e5                	mov    %esp,%ebp
f0105d5a:	53                   	push   %ebx
f0105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105d61:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0105d64:	eb 03                	jmp    f0105d69 <strncmp+0x12>
		n--, p++, q++;
f0105d66:	4a                   	dec    %edx
f0105d67:	40                   	inc    %eax
f0105d68:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105d69:	85 d2                	test   %edx,%edx
f0105d6b:	74 14                	je     f0105d81 <strncmp+0x2a>
f0105d6d:	8a 18                	mov    (%eax),%bl
f0105d6f:	84 db                	test   %bl,%bl
f0105d71:	74 04                	je     f0105d77 <strncmp+0x20>
f0105d73:	3a 19                	cmp    (%ecx),%bl
f0105d75:	74 ef                	je     f0105d66 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d77:	0f b6 00             	movzbl (%eax),%eax
f0105d7a:	0f b6 11             	movzbl (%ecx),%edx
f0105d7d:	29 d0                	sub    %edx,%eax
f0105d7f:	eb 05                	jmp    f0105d86 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105d81:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105d86:	5b                   	pop    %ebx
f0105d87:	5d                   	pop    %ebp
f0105d88:	c3                   	ret    

f0105d89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105d89:	55                   	push   %ebp
f0105d8a:	89 e5                	mov    %esp,%ebp
f0105d8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d8f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105d92:	eb 05                	jmp    f0105d99 <strchr+0x10>
		if (*s == c)
f0105d94:	38 ca                	cmp    %cl,%dl
f0105d96:	74 0c                	je     f0105da4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105d98:	40                   	inc    %eax
f0105d99:	8a 10                	mov    (%eax),%dl
f0105d9b:	84 d2                	test   %dl,%dl
f0105d9d:	75 f5                	jne    f0105d94 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0105d9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105da4:	5d                   	pop    %ebp
f0105da5:	c3                   	ret    

f0105da6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105da6:	55                   	push   %ebp
f0105da7:	89 e5                	mov    %esp,%ebp
f0105da9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dac:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105daf:	eb 05                	jmp    f0105db6 <strfind+0x10>
		if (*s == c)
f0105db1:	38 ca                	cmp    %cl,%dl
f0105db3:	74 07                	je     f0105dbc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105db5:	40                   	inc    %eax
f0105db6:	8a 10                	mov    (%eax),%dl
f0105db8:	84 d2                	test   %dl,%dl
f0105dba:	75 f5                	jne    f0105db1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0105dbc:	5d                   	pop    %ebp
f0105dbd:	c3                   	ret    

f0105dbe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105dbe:	55                   	push   %ebp
f0105dbf:	89 e5                	mov    %esp,%ebp
f0105dc1:	57                   	push   %edi
f0105dc2:	56                   	push   %esi
f0105dc3:	53                   	push   %ebx
f0105dc4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105dca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105dcd:	85 c9                	test   %ecx,%ecx
f0105dcf:	74 30                	je     f0105e01 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105dd1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105dd7:	75 25                	jne    f0105dfe <memset+0x40>
f0105dd9:	f6 c1 03             	test   $0x3,%cl
f0105ddc:	75 20                	jne    f0105dfe <memset+0x40>
		c &= 0xFF;
f0105dde:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105de1:	89 d3                	mov    %edx,%ebx
f0105de3:	c1 e3 08             	shl    $0x8,%ebx
f0105de6:	89 d6                	mov    %edx,%esi
f0105de8:	c1 e6 18             	shl    $0x18,%esi
f0105deb:	89 d0                	mov    %edx,%eax
f0105ded:	c1 e0 10             	shl    $0x10,%eax
f0105df0:	09 f0                	or     %esi,%eax
f0105df2:	09 d0                	or     %edx,%eax
f0105df4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105df6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105df9:	fc                   	cld    
f0105dfa:	f3 ab                	rep stos %eax,%es:(%edi)
f0105dfc:	eb 03                	jmp    f0105e01 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105dfe:	fc                   	cld    
f0105dff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105e01:	89 f8                	mov    %edi,%eax
f0105e03:	5b                   	pop    %ebx
f0105e04:	5e                   	pop    %esi
f0105e05:	5f                   	pop    %edi
f0105e06:	5d                   	pop    %ebp
f0105e07:	c3                   	ret    

f0105e08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105e08:	55                   	push   %ebp
f0105e09:	89 e5                	mov    %esp,%ebp
f0105e0b:	57                   	push   %edi
f0105e0c:	56                   	push   %esi
f0105e0d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e10:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105e16:	39 c6                	cmp    %eax,%esi
f0105e18:	73 34                	jae    f0105e4e <memmove+0x46>
f0105e1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105e1d:	39 d0                	cmp    %edx,%eax
f0105e1f:	73 2d                	jae    f0105e4e <memmove+0x46>
		s += n;
		d += n;
f0105e21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e24:	f6 c2 03             	test   $0x3,%dl
f0105e27:	75 1b                	jne    f0105e44 <memmove+0x3c>
f0105e29:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105e2f:	75 13                	jne    f0105e44 <memmove+0x3c>
f0105e31:	f6 c1 03             	test   $0x3,%cl
f0105e34:	75 0e                	jne    f0105e44 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105e36:	83 ef 04             	sub    $0x4,%edi
f0105e39:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105e3c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105e3f:	fd                   	std    
f0105e40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e42:	eb 07                	jmp    f0105e4b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105e44:	4f                   	dec    %edi
f0105e45:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105e48:	fd                   	std    
f0105e49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105e4b:	fc                   	cld    
f0105e4c:	eb 20                	jmp    f0105e6e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105e54:	75 13                	jne    f0105e69 <memmove+0x61>
f0105e56:	a8 03                	test   $0x3,%al
f0105e58:	75 0f                	jne    f0105e69 <memmove+0x61>
f0105e5a:	f6 c1 03             	test   $0x3,%cl
f0105e5d:	75 0a                	jne    f0105e69 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105e5f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105e62:	89 c7                	mov    %eax,%edi
f0105e64:	fc                   	cld    
f0105e65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e67:	eb 05                	jmp    f0105e6e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105e69:	89 c7                	mov    %eax,%edi
f0105e6b:	fc                   	cld    
f0105e6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105e6e:	5e                   	pop    %esi
f0105e6f:	5f                   	pop    %edi
f0105e70:	5d                   	pop    %ebp
f0105e71:	c3                   	ret    

f0105e72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105e72:	55                   	push   %ebp
f0105e73:	89 e5                	mov    %esp,%ebp
f0105e75:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105e78:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e7b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e86:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e89:	89 04 24             	mov    %eax,(%esp)
f0105e8c:	e8 77 ff ff ff       	call   f0105e08 <memmove>
}
f0105e91:	c9                   	leave  
f0105e92:	c3                   	ret    

f0105e93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105e93:	55                   	push   %ebp
f0105e94:	89 e5                	mov    %esp,%ebp
f0105e96:	57                   	push   %edi
f0105e97:	56                   	push   %esi
f0105e98:	53                   	push   %ebx
f0105e99:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105e9c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ea2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ea7:	eb 16                	jmp    f0105ebf <memcmp+0x2c>
		if (*s1 != *s2)
f0105ea9:	8a 04 17             	mov    (%edi,%edx,1),%al
f0105eac:	42                   	inc    %edx
f0105ead:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0105eb1:	38 c8                	cmp    %cl,%al
f0105eb3:	74 0a                	je     f0105ebf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0105eb5:	0f b6 c0             	movzbl %al,%eax
f0105eb8:	0f b6 c9             	movzbl %cl,%ecx
f0105ebb:	29 c8                	sub    %ecx,%eax
f0105ebd:	eb 09                	jmp    f0105ec8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ebf:	39 da                	cmp    %ebx,%edx
f0105ec1:	75 e6                	jne    f0105ea9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105ec3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ec8:	5b                   	pop    %ebx
f0105ec9:	5e                   	pop    %esi
f0105eca:	5f                   	pop    %edi
f0105ecb:	5d                   	pop    %ebp
f0105ecc:	c3                   	ret    

f0105ecd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105ecd:	55                   	push   %ebp
f0105ece:	89 e5                	mov    %esp,%ebp
f0105ed0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ed3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105ed6:	89 c2                	mov    %eax,%edx
f0105ed8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105edb:	eb 05                	jmp    f0105ee2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105edd:	38 08                	cmp    %cl,(%eax)
f0105edf:	74 05                	je     f0105ee6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105ee1:	40                   	inc    %eax
f0105ee2:	39 d0                	cmp    %edx,%eax
f0105ee4:	72 f7                	jb     f0105edd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105ee6:	5d                   	pop    %ebp
f0105ee7:	c3                   	ret    

f0105ee8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105ee8:	55                   	push   %ebp
f0105ee9:	89 e5                	mov    %esp,%ebp
f0105eeb:	57                   	push   %edi
f0105eec:	56                   	push   %esi
f0105eed:	53                   	push   %ebx
f0105eee:	8b 55 08             	mov    0x8(%ebp),%edx
f0105ef1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105ef4:	eb 01                	jmp    f0105ef7 <strtol+0xf>
		s++;
f0105ef6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105ef7:	8a 02                	mov    (%edx),%al
f0105ef9:	3c 20                	cmp    $0x20,%al
f0105efb:	74 f9                	je     f0105ef6 <strtol+0xe>
f0105efd:	3c 09                	cmp    $0x9,%al
f0105eff:	74 f5                	je     f0105ef6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105f01:	3c 2b                	cmp    $0x2b,%al
f0105f03:	75 08                	jne    f0105f0d <strtol+0x25>
		s++;
f0105f05:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105f06:	bf 00 00 00 00       	mov    $0x0,%edi
f0105f0b:	eb 13                	jmp    f0105f20 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105f0d:	3c 2d                	cmp    $0x2d,%al
f0105f0f:	75 0a                	jne    f0105f1b <strtol+0x33>
		s++, neg = 1;
f0105f11:	8d 52 01             	lea    0x1(%edx),%edx
f0105f14:	bf 01 00 00 00       	mov    $0x1,%edi
f0105f19:	eb 05                	jmp    f0105f20 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105f1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105f20:	85 db                	test   %ebx,%ebx
f0105f22:	74 05                	je     f0105f29 <strtol+0x41>
f0105f24:	83 fb 10             	cmp    $0x10,%ebx
f0105f27:	75 28                	jne    f0105f51 <strtol+0x69>
f0105f29:	8a 02                	mov    (%edx),%al
f0105f2b:	3c 30                	cmp    $0x30,%al
f0105f2d:	75 10                	jne    f0105f3f <strtol+0x57>
f0105f2f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105f33:	75 0a                	jne    f0105f3f <strtol+0x57>
		s += 2, base = 16;
f0105f35:	83 c2 02             	add    $0x2,%edx
f0105f38:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105f3d:	eb 12                	jmp    f0105f51 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0105f3f:	85 db                	test   %ebx,%ebx
f0105f41:	75 0e                	jne    f0105f51 <strtol+0x69>
f0105f43:	3c 30                	cmp    $0x30,%al
f0105f45:	75 05                	jne    f0105f4c <strtol+0x64>
		s++, base = 8;
f0105f47:	42                   	inc    %edx
f0105f48:	b3 08                	mov    $0x8,%bl
f0105f4a:	eb 05                	jmp    f0105f51 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0105f4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105f51:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105f58:	8a 0a                	mov    (%edx),%cl
f0105f5a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105f5d:	80 fb 09             	cmp    $0x9,%bl
f0105f60:	77 08                	ja     f0105f6a <strtol+0x82>
			dig = *s - '0';
f0105f62:	0f be c9             	movsbl %cl,%ecx
f0105f65:	83 e9 30             	sub    $0x30,%ecx
f0105f68:	eb 1e                	jmp    f0105f88 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0105f6a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105f6d:	80 fb 19             	cmp    $0x19,%bl
f0105f70:	77 08                	ja     f0105f7a <strtol+0x92>
			dig = *s - 'a' + 10;
f0105f72:	0f be c9             	movsbl %cl,%ecx
f0105f75:	83 e9 57             	sub    $0x57,%ecx
f0105f78:	eb 0e                	jmp    f0105f88 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0105f7a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105f7d:	80 fb 19             	cmp    $0x19,%bl
f0105f80:	77 12                	ja     f0105f94 <strtol+0xac>
			dig = *s - 'A' + 10;
f0105f82:	0f be c9             	movsbl %cl,%ecx
f0105f85:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105f88:	39 f1                	cmp    %esi,%ecx
f0105f8a:	7d 0c                	jge    f0105f98 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0105f8c:	42                   	inc    %edx
f0105f8d:	0f af c6             	imul   %esi,%eax
f0105f90:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0105f92:	eb c4                	jmp    f0105f58 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105f94:	89 c1                	mov    %eax,%ecx
f0105f96:	eb 02                	jmp    f0105f9a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105f98:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105f9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105f9e:	74 05                	je     f0105fa5 <strtol+0xbd>
		*endptr = (char *) s;
f0105fa0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105fa3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105fa5:	85 ff                	test   %edi,%edi
f0105fa7:	74 04                	je     f0105fad <strtol+0xc5>
f0105fa9:	89 c8                	mov    %ecx,%eax
f0105fab:	f7 d8                	neg    %eax
}
f0105fad:	5b                   	pop    %ebx
f0105fae:	5e                   	pop    %esi
f0105faf:	5f                   	pop    %edi
f0105fb0:	5d                   	pop    %ebp
f0105fb1:	c3                   	ret    
	...

f0105fb4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105fb4:	fa                   	cli    

	xorw    %ax, %ax
f0105fb5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105fb7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105fb9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105fbb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105fbd:	0f 01 16             	lgdtl  (%esi)
f0105fc0:	74 70                	je     f0106032 <sum+0x2>
	movl    %cr0, %eax
f0105fc2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105fc5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105fc9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105fcc:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105fd2:	08 00                	or     %al,(%eax)

f0105fd4 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105fd4:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105fd8:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105fda:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105fdc:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105fde:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105fe2:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105fe4:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105fe6:	b8 00 a0 12 00       	mov    $0x12a000,%eax
	movl    %eax, %cr3
f0105feb:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105fee:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105ff1:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105ff6:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105ff9:	8b 25 94 1e 2e f0    	mov    0xf02e1e94,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105fff:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106004:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106009:	ff d0                	call   *%eax

f010600b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010600b:	eb fe                	jmp    f010600b <spin>
f010600d:	8d 76 00             	lea    0x0(%esi),%esi

f0106010 <gdt>:
	...
f0106018:	ff                   	(bad)  
f0106019:	ff 00                	incl   (%eax)
f010601b:	00 00                	add    %al,(%eax)
f010601d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106024:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106028 <gdtdesc>:
f0106028:	17                   	pop    %ss
f0106029:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010602e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010602e:	90                   	nop
	...

f0106030 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106030:	55                   	push   %ebp
f0106031:	89 e5                	mov    %esp,%ebp
f0106033:	56                   	push   %esi
f0106034:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106035:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f010603a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010603f:	eb 07                	jmp    f0106048 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f0106041:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106045:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106047:	41                   	inc    %ecx
f0106048:	39 d1                	cmp    %edx,%ecx
f010604a:	7c f5                	jl     f0106041 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f010604c:	88 d8                	mov    %bl,%al
f010604e:	5b                   	pop    %ebx
f010604f:	5e                   	pop    %esi
f0106050:	5d                   	pop    %ebp
f0106051:	c3                   	ret    

f0106052 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106052:	55                   	push   %ebp
f0106053:	89 e5                	mov    %esp,%ebp
f0106055:	56                   	push   %esi
f0106056:	53                   	push   %ebx
f0106057:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010605a:	8b 0d 98 1e 2e f0    	mov    0xf02e1e98,%ecx
f0106060:	89 c3                	mov    %eax,%ebx
f0106062:	c1 eb 0c             	shr    $0xc,%ebx
f0106065:	39 cb                	cmp    %ecx,%ebx
f0106067:	72 20                	jb     f0106089 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106069:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010606d:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0106074:	f0 
f0106075:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010607c:	00 
f010607d:	c7 04 24 a1 92 10 f0 	movl   $0xf01092a1,(%esp)
f0106084:	e8 b7 9f ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106089:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010608c:	89 f2                	mov    %esi,%edx
f010608e:	c1 ea 0c             	shr    $0xc,%edx
f0106091:	39 d1                	cmp    %edx,%ecx
f0106093:	77 20                	ja     f01060b5 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106095:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106099:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f01060a0:	f0 
f01060a1:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01060a8:	00 
f01060a9:	c7 04 24 a1 92 10 f0 	movl   $0xf01092a1,(%esp)
f01060b0:	e8 8b 9f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01060b5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01060bb:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01060c1:	eb 2f                	jmp    f01060f2 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01060c3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01060ca:	00 
f01060cb:	c7 44 24 04 b1 92 10 	movl   $0xf01092b1,0x4(%esp)
f01060d2:	f0 
f01060d3:	89 1c 24             	mov    %ebx,(%esp)
f01060d6:	e8 b8 fd ff ff       	call   f0105e93 <memcmp>
f01060db:	85 c0                	test   %eax,%eax
f01060dd:	75 10                	jne    f01060ef <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f01060df:	ba 10 00 00 00       	mov    $0x10,%edx
f01060e4:	89 d8                	mov    %ebx,%eax
f01060e6:	e8 45 ff ff ff       	call   f0106030 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01060eb:	84 c0                	test   %al,%al
f01060ed:	74 0c                	je     f01060fb <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01060ef:	83 c3 10             	add    $0x10,%ebx
f01060f2:	39 f3                	cmp    %esi,%ebx
f01060f4:	72 cd                	jb     f01060c3 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01060f6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01060fb:	89 d8                	mov    %ebx,%eax
f01060fd:	83 c4 10             	add    $0x10,%esp
f0106100:	5b                   	pop    %ebx
f0106101:	5e                   	pop    %esi
f0106102:	5d                   	pop    %ebp
f0106103:	c3                   	ret    

f0106104 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106104:	55                   	push   %ebp
f0106105:	89 e5                	mov    %esp,%ebp
f0106107:	57                   	push   %edi
f0106108:	56                   	push   %esi
f0106109:	53                   	push   %ebx
f010610a:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010610d:	c7 05 c0 23 2e f0 20 	movl   $0xf02e2020,0xf02e23c0
f0106114:	20 2e f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106117:	83 3d 98 1e 2e f0 00 	cmpl   $0x0,0xf02e1e98
f010611e:	75 24                	jne    f0106144 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106120:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106127:	00 
f0106128:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f010612f:	f0 
f0106130:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106137:	00 
f0106138:	c7 04 24 a1 92 10 f0 	movl   $0xf01092a1,(%esp)
f010613f:	e8 fc 9e ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106144:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010614b:	85 c0                	test   %eax,%eax
f010614d:	74 16                	je     f0106165 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010614f:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106152:	ba 00 04 00 00       	mov    $0x400,%edx
f0106157:	e8 f6 fe ff ff       	call   f0106052 <mpsearch1>
f010615c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010615f:	85 c0                	test   %eax,%eax
f0106161:	75 3c                	jne    f010619f <mp_init+0x9b>
f0106163:	eb 20                	jmp    f0106185 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106165:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010616c:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010616f:	2d 00 04 00 00       	sub    $0x400,%eax
f0106174:	ba 00 04 00 00       	mov    $0x400,%edx
f0106179:	e8 d4 fe ff ff       	call   f0106052 <mpsearch1>
f010617e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106181:	85 c0                	test   %eax,%eax
f0106183:	75 1a                	jne    f010619f <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106185:	ba 00 00 01 00       	mov    $0x10000,%edx
f010618a:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010618f:	e8 be fe ff ff       	call   f0106052 <mpsearch1>
f0106194:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106197:	85 c0                	test   %eax,%eax
f0106199:	0f 84 3d 02 00 00    	je     f01063dc <mp_init+0x2d8>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010619f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01061a2:	8b 58 04             	mov    0x4(%eax),%ebx
f01061a5:	85 db                	test   %ebx,%ebx
f01061a7:	74 06                	je     f01061af <mp_init+0xab>
f01061a9:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01061ad:	74 11                	je     f01061c0 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01061af:	c7 04 24 14 91 10 f0 	movl   $0xf0109114,(%esp)
f01061b6:	e8 cf dc ff ff       	call   f0103e8a <cprintf>
f01061bb:	e9 1c 02 00 00       	jmp    f01063dc <mp_init+0x2d8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01061c0:	89 d8                	mov    %ebx,%eax
f01061c2:	c1 e8 0c             	shr    $0xc,%eax
f01061c5:	3b 05 98 1e 2e f0    	cmp    0xf02e1e98,%eax
f01061cb:	72 20                	jb     f01061ed <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01061d1:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f01061d8:	f0 
f01061d9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01061e0:	00 
f01061e1:	c7 04 24 a1 92 10 f0 	movl   $0xf01092a1,(%esp)
f01061e8:	e8 53 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01061ed:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01061f3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01061fa:	00 
f01061fb:	c7 44 24 04 b6 92 10 	movl   $0xf01092b6,0x4(%esp)
f0106202:	f0 
f0106203:	89 1c 24             	mov    %ebx,(%esp)
f0106206:	e8 88 fc ff ff       	call   f0105e93 <memcmp>
f010620b:	85 c0                	test   %eax,%eax
f010620d:	74 11                	je     f0106220 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010620f:	c7 04 24 44 91 10 f0 	movl   $0xf0109144,(%esp)
f0106216:	e8 6f dc ff ff       	call   f0103e8a <cprintf>
f010621b:	e9 bc 01 00 00       	jmp    f01063dc <mp_init+0x2d8>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106220:	66 8b 73 04          	mov    0x4(%ebx),%si
f0106224:	0f b7 d6             	movzwl %si,%edx
f0106227:	89 d8                	mov    %ebx,%eax
f0106229:	e8 02 fe ff ff       	call   f0106030 <sum>
f010622e:	84 c0                	test   %al,%al
f0106230:	74 11                	je     f0106243 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106232:	c7 04 24 78 91 10 f0 	movl   $0xf0109178,(%esp)
f0106239:	e8 4c dc ff ff       	call   f0103e8a <cprintf>
f010623e:	e9 99 01 00 00       	jmp    f01063dc <mp_init+0x2d8>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106243:	8a 43 06             	mov    0x6(%ebx),%al
f0106246:	3c 01                	cmp    $0x1,%al
f0106248:	74 1c                	je     f0106266 <mp_init+0x162>
f010624a:	3c 04                	cmp    $0x4,%al
f010624c:	74 18                	je     f0106266 <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010624e:	0f b6 c0             	movzbl %al,%eax
f0106251:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106255:	c7 04 24 9c 91 10 f0 	movl   $0xf010919c,(%esp)
f010625c:	e8 29 dc ff ff       	call   f0103e8a <cprintf>
f0106261:	e9 76 01 00 00       	jmp    f01063dc <mp_init+0x2d8>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106266:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f010626a:	0f b7 f6             	movzwl %si,%esi
f010626d:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0106270:	e8 bb fd ff ff       	call   f0106030 <sum>
f0106275:	02 43 2a             	add    0x2a(%ebx),%al
f0106278:	84 c0                	test   %al,%al
f010627a:	74 11                	je     f010628d <mp_init+0x189>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010627c:	c7 04 24 bc 91 10 f0 	movl   $0xf01091bc,(%esp)
f0106283:	e8 02 dc ff ff       	call   f0103e8a <cprintf>
f0106288:	e9 4f 01 00 00       	jmp    f01063dc <mp_init+0x2d8>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010628d:	85 db                	test   %ebx,%ebx
f010628f:	0f 84 47 01 00 00    	je     f01063dc <mp_init+0x2d8>
		return;
	ismp = 1;
f0106295:	c7 05 00 20 2e f0 01 	movl   $0x1,0xf02e2000
f010629c:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010629f:	8b 43 24             	mov    0x24(%ebx),%eax
f01062a2:	a3 00 30 32 f0       	mov    %eax,0xf0323000
	cprintf("!!!!!lapic phyaddr %08x\n",lapicaddr);
f01062a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062ab:	c7 04 24 bb 92 10 f0 	movl   $0xf01092bb,(%esp)
f01062b2:	e8 d3 db ff ff       	call   f0103e8a <cprintf>

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062b7:	8d 73 2c             	lea    0x2c(%ebx),%esi
f01062ba:	bf 00 00 00 00       	mov    $0x0,%edi
f01062bf:	e9 94 00 00 00       	jmp    f0106358 <mp_init+0x254>
		switch (*p) {
f01062c4:	8a 06                	mov    (%esi),%al
f01062c6:	84 c0                	test   %al,%al
f01062c8:	74 06                	je     f01062d0 <mp_init+0x1cc>
f01062ca:	3c 04                	cmp    $0x4,%al
f01062cc:	77 68                	ja     f0106336 <mp_init+0x232>
f01062ce:	eb 61                	jmp    f0106331 <mp_init+0x22d>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01062d0:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01062d4:	74 1d                	je     f01062f3 <mp_init+0x1ef>
				bootcpu = &cpus[ncpu];
f01062d6:	a1 c4 23 2e f0       	mov    0xf02e23c4,%eax
f01062db:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01062e2:	29 c2                	sub    %eax,%edx
f01062e4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01062e7:	8d 04 85 20 20 2e f0 	lea    -0xfd1dfe0(,%eax,4),%eax
f01062ee:	a3 c0 23 2e f0       	mov    %eax,0xf02e23c0
			if (ncpu < NCPU) {
f01062f3:	a1 c4 23 2e f0       	mov    0xf02e23c4,%eax
f01062f8:	83 f8 07             	cmp    $0x7,%eax
f01062fb:	7f 1b                	jg     f0106318 <mp_init+0x214>
				cpus[ncpu].cpu_id = ncpu;
f01062fd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106304:	29 c2                	sub    %eax,%edx
f0106306:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106309:	88 04 95 20 20 2e f0 	mov    %al,-0xfd1dfe0(,%edx,4)
				ncpu++;
f0106310:	40                   	inc    %eax
f0106311:	a3 c4 23 2e f0       	mov    %eax,0xf02e23c4
f0106316:	eb 14                	jmp    f010632c <mp_init+0x228>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106318:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010631c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106320:	c7 04 24 ec 91 10 f0 	movl   $0xf01091ec,(%esp)
f0106327:	e8 5e db ff ff       	call   f0103e8a <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010632c:	83 c6 14             	add    $0x14,%esi
			continue;
f010632f:	eb 26                	jmp    f0106357 <mp_init+0x253>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106331:	83 c6 08             	add    $0x8,%esi
			continue;
f0106334:	eb 21                	jmp    f0106357 <mp_init+0x253>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106336:	0f b6 c0             	movzbl %al,%eax
f0106339:	89 44 24 04          	mov    %eax,0x4(%esp)
f010633d:	c7 04 24 14 92 10 f0 	movl   $0xf0109214,(%esp)
f0106344:	e8 41 db ff ff       	call   f0103e8a <cprintf>
			ismp = 0;
f0106349:	c7 05 00 20 2e f0 00 	movl   $0x0,0xf02e2000
f0106350:	00 00 00 
			i = conf->entry;
f0106353:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;
	cprintf("!!!!!lapic phyaddr %08x\n",lapicaddr);

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106357:	47                   	inc    %edi
f0106358:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010635c:	39 c7                	cmp    %eax,%edi
f010635e:	0f 82 60 ff ff ff    	jb     f01062c4 <mp_init+0x1c0>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106364:	a1 c0 23 2e f0       	mov    0xf02e23c0,%eax
f0106369:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106370:	83 3d 00 20 2e f0 00 	cmpl   $0x0,0xf02e2000
f0106377:	75 22                	jne    f010639b <mp_init+0x297>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106379:	c7 05 c4 23 2e f0 01 	movl   $0x1,0xf02e23c4
f0106380:	00 00 00 
		lapicaddr = 0;
f0106383:	c7 05 00 30 32 f0 00 	movl   $0x0,0xf0323000
f010638a:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010638d:	c7 04 24 34 92 10 f0 	movl   $0xf0109234,(%esp)
f0106394:	e8 f1 da ff ff       	call   f0103e8a <cprintf>
		return;
f0106399:	eb 41                	jmp    f01063dc <mp_init+0x2d8>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010639b:	8b 15 c4 23 2e f0    	mov    0xf02e23c4,%edx
f01063a1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01063a5:	0f b6 00             	movzbl (%eax),%eax
f01063a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063ac:	c7 04 24 d4 92 10 f0 	movl   $0xf01092d4,(%esp)
f01063b3:	e8 d2 da ff ff       	call   f0103e8a <cprintf>

	if (mp->imcrp) {
f01063b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063bb:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01063bf:	74 1b                	je     f01063dc <mp_init+0x2d8>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01063c1:	c7 04 24 60 92 10 f0 	movl   $0xf0109260,(%esp)
f01063c8:	e8 bd da ff ff       	call   f0103e8a <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01063cd:	ba 22 00 00 00       	mov    $0x22,%edx
f01063d2:	b0 70                	mov    $0x70,%al
f01063d4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01063d5:	b2 23                	mov    $0x23,%dl
f01063d7:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01063d8:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01063db:	ee                   	out    %al,(%dx)
	}
}
f01063dc:	83 c4 2c             	add    $0x2c,%esp
f01063df:	5b                   	pop    %ebx
f01063e0:	5e                   	pop    %esi
f01063e1:	5f                   	pop    %edi
f01063e2:	5d                   	pop    %ebp
f01063e3:	c3                   	ret    

f01063e4 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01063e4:	55                   	push   %ebp
f01063e5:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01063e7:	c1 e0 02             	shl    $0x2,%eax
f01063ea:	03 05 04 30 32 f0    	add    0xf0323004,%eax
f01063f0:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01063f2:	a1 04 30 32 f0       	mov    0xf0323004,%eax
f01063f7:	8b 40 20             	mov    0x20(%eax),%eax
}
f01063fa:	5d                   	pop    %ebp
f01063fb:	c3                   	ret    

f01063fc <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01063fc:	55                   	push   %ebp
f01063fd:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01063ff:	a1 04 30 32 f0       	mov    0xf0323004,%eax
f0106404:	85 c0                	test   %eax,%eax
f0106406:	74 08                	je     f0106410 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106408:	8b 40 20             	mov    0x20(%eax),%eax
f010640b:	c1 e8 18             	shr    $0x18,%eax
f010640e:	eb 05                	jmp    f0106415 <cpunum+0x19>
	return 0;
f0106410:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106415:	5d                   	pop    %ebp
f0106416:	c3                   	ret    

f0106417 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106417:	55                   	push   %ebp
f0106418:	89 e5                	mov    %esp,%ebp
f010641a:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f010641d:	a1 00 30 32 f0       	mov    0xf0323000,%eax
f0106422:	85 c0                	test   %eax,%eax
f0106424:	0f 84 90 01 00 00    	je     f01065ba <lapic_init+0x1a3>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f010642a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106431:	00 
f0106432:	89 04 24             	mov    %eax,(%esp)
f0106435:	e8 0e af ff ff       	call   f0101348 <mmio_map_region>
f010643a:	a3 04 30 32 f0       	mov    %eax,0xf0323004
	// cprintf("=====lapic vaddr %08x\n",(uint32_t)lapic);
	cprintf("=======\n");
f010643f:	c7 04 24 f1 92 10 f0 	movl   $0xf01092f1,(%esp)
f0106446:	e8 3f da ff ff       	call   f0103e8a <cprintf>
	pte_t *pte = pgdir_walk(kern_pgdir, (void *) lapic, 0);
f010644b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106452:	00 
f0106453:	a1 04 30 32 f0       	mov    0xf0323004,%eax
f0106458:	89 44 24 04          	mov    %eax,0x4(%esp)
f010645c:	a1 9c 1e 2e f0       	mov    0xf02e1e9c,%eax
f0106461:	89 04 24             	mov    %eax,(%esp)
f0106464:	e8 66 ac ff ff       	call   f01010cf <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) {
f0106469:	85 c0                	test   %eax,%eax
f010646b:	74 06                	je     f0106473 <lapic_init+0x5c>
f010646d:	8b 00                	mov    (%eax),%eax
f010646f:	a8 01                	test   $0x1,%al
f0106471:	75 17                	jne    f010648a <lapic_init+0x73>
            cprintf("va: %08x not mapped\n", lapic);
f0106473:	a1 04 30 32 f0       	mov    0xf0323004,%eax
f0106478:	89 44 24 04          	mov    %eax,0x4(%esp)
f010647c:	c7 04 24 fa 92 10 f0 	movl   $0xf01092fa,(%esp)
f0106483:	e8 02 da ff ff       	call   f0103e8a <cprintf>
f0106488:	eb 1e                	jmp    f01064a8 <lapic_init+0x91>
        } else {
            cprintf("va: %08x, pa: %08x\n", lapic, PTE_ADDR(*pte));
f010648a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010648f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106493:	a1 04 30 32 f0       	mov    0xf0323004,%eax
f0106498:	89 44 24 04          	mov    %eax,0x4(%esp)
f010649c:	c7 04 24 0f 93 10 f0 	movl   $0xf010930f,(%esp)
f01064a3:	e8 e2 d9 ff ff       	call   f0103e8a <cprintf>
        }

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01064a8:	ba 27 01 00 00       	mov    $0x127,%edx
f01064ad:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01064b2:	e8 2d ff ff ff       	call   f01063e4 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01064b7:	ba 0b 00 00 00       	mov    $0xb,%edx
f01064bc:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01064c1:	e8 1e ff ff ff       	call   f01063e4 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01064c6:	ba 20 00 02 00       	mov    $0x20020,%edx
f01064cb:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01064d0:	e8 0f ff ff ff       	call   f01063e4 <lapicw>
	lapicw(TICR, 10000000); 
f01064d5:	ba 80 96 98 00       	mov    $0x989680,%edx
f01064da:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01064df:	e8 00 ff ff ff       	call   f01063e4 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01064e4:	e8 13 ff ff ff       	call   f01063fc <cpunum>
f01064e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01064f0:	29 c2                	sub    %eax,%edx
f01064f2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01064f5:	8d 04 85 20 20 2e f0 	lea    -0xfd1dfe0(,%eax,4),%eax
f01064fc:	39 05 c0 23 2e f0    	cmp    %eax,0xf02e23c0
f0106502:	74 0f                	je     f0106513 <lapic_init+0xfc>
		lapicw(LINT0, MASKED);
f0106504:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106509:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010650e:	e8 d1 fe ff ff       	call   f01063e4 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106513:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106518:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010651d:	e8 c2 fe ff ff       	call   f01063e4 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106522:	a1 04 30 32 f0       	mov    0xf0323004,%eax
f0106527:	8b 40 30             	mov    0x30(%eax),%eax
f010652a:	c1 e8 10             	shr    $0x10,%eax
f010652d:	3c 03                	cmp    $0x3,%al
f010652f:	76 0f                	jbe    f0106540 <lapic_init+0x129>
		lapicw(PCINT, MASKED);
f0106531:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106536:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010653b:	e8 a4 fe ff ff       	call   f01063e4 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106540:	ba 33 00 00 00       	mov    $0x33,%edx
f0106545:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010654a:	e8 95 fe ff ff       	call   f01063e4 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010654f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106554:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106559:	e8 86 fe ff ff       	call   f01063e4 <lapicw>
	lapicw(ESR, 0);
f010655e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106563:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106568:	e8 77 fe ff ff       	call   f01063e4 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010656d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106572:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106577:	e8 68 fe ff ff       	call   f01063e4 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010657c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106581:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106586:	e8 59 fe ff ff       	call   f01063e4 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010658b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106590:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106595:	e8 4a fe ff ff       	call   f01063e4 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010659a:	8b 15 04 30 32 f0    	mov    0xf0323004,%edx
f01065a0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065a6:	f6 c4 10             	test   $0x10,%ah
f01065a9:	75 f5                	jne    f01065a0 <lapic_init+0x189>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01065ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01065b0:	b8 20 00 00 00       	mov    $0x20,%eax
f01065b5:	e8 2a fe ff ff       	call   f01063e4 <lapicw>
}
f01065ba:	c9                   	leave  
f01065bb:	c3                   	ret    

f01065bc <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01065bc:	55                   	push   %ebp
f01065bd:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01065bf:	83 3d 04 30 32 f0 00 	cmpl   $0x0,0xf0323004
f01065c6:	74 0f                	je     f01065d7 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01065c8:	ba 00 00 00 00       	mov    $0x0,%edx
f01065cd:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01065d2:	e8 0d fe ff ff       	call   f01063e4 <lapicw>
}
f01065d7:	5d                   	pop    %ebp
f01065d8:	c3                   	ret    

f01065d9 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01065d9:	55                   	push   %ebp
f01065da:	89 e5                	mov    %esp,%ebp
f01065dc:	56                   	push   %esi
f01065dd:	53                   	push   %ebx
f01065de:	83 ec 10             	sub    $0x10,%esp
f01065e1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01065e4:	8a 5d 08             	mov    0x8(%ebp),%bl
f01065e7:	ba 70 00 00 00       	mov    $0x70,%edx
f01065ec:	b0 0f                	mov    $0xf,%al
f01065ee:	ee                   	out    %al,(%dx)
f01065ef:	b2 71                	mov    $0x71,%dl
f01065f1:	b0 0a                	mov    $0xa,%al
f01065f3:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01065f4:	83 3d 98 1e 2e f0 00 	cmpl   $0x0,0xf02e1e98
f01065fb:	75 24                	jne    f0106621 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065fd:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106604:	00 
f0106605:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f010660c:	f0 
f010660d:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
f0106614:	00 
f0106615:	c7 04 24 23 93 10 f0 	movl   $0xf0109323,(%esp)
f010661c:	e8 1f 9a ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106621:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106628:	00 00 
	wrv[1] = addr >> 4;
f010662a:	89 f0                	mov    %esi,%eax
f010662c:	c1 e8 04             	shr    $0x4,%eax
f010662f:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106635:	c1 e3 18             	shl    $0x18,%ebx
f0106638:	89 da                	mov    %ebx,%edx
f010663a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010663f:	e8 a0 fd ff ff       	call   f01063e4 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106644:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106649:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010664e:	e8 91 fd ff ff       	call   f01063e4 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106653:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106658:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010665d:	e8 82 fd ff ff       	call   f01063e4 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106662:	c1 ee 0c             	shr    $0xc,%esi
f0106665:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010666b:	89 da                	mov    %ebx,%edx
f010666d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106672:	e8 6d fd ff ff       	call   f01063e4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106677:	89 f2                	mov    %esi,%edx
f0106679:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010667e:	e8 61 fd ff ff       	call   f01063e4 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106683:	89 da                	mov    %ebx,%edx
f0106685:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010668a:	e8 55 fd ff ff       	call   f01063e4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010668f:	89 f2                	mov    %esi,%edx
f0106691:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106696:	e8 49 fd ff ff       	call   f01063e4 <lapicw>
		microdelay(200);
	}
}
f010669b:	83 c4 10             	add    $0x10,%esp
f010669e:	5b                   	pop    %ebx
f010669f:	5e                   	pop    %esi
f01066a0:	5d                   	pop    %ebp
f01066a1:	c3                   	ret    

f01066a2 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01066a2:	55                   	push   %ebp
f01066a3:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01066a5:	8b 55 08             	mov    0x8(%ebp),%edx
f01066a8:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01066ae:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066b3:	e8 2c fd ff ff       	call   f01063e4 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01066b8:	8b 15 04 30 32 f0    	mov    0xf0323004,%edx
f01066be:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01066c4:	f6 c4 10             	test   $0x10,%ah
f01066c7:	75 f5                	jne    f01066be <lapic_ipi+0x1c>
		;
}
f01066c9:	5d                   	pop    %ebp
f01066ca:	c3                   	ret    
	...

f01066cc <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01066cc:	55                   	push   %ebp
f01066cd:	89 e5                	mov    %esp,%ebp
f01066cf:	53                   	push   %ebx
f01066d0:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01066d3:	83 38 00             	cmpl   $0x0,(%eax)
f01066d6:	74 25                	je     f01066fd <holding+0x31>
f01066d8:	8b 58 08             	mov    0x8(%eax),%ebx
f01066db:	e8 1c fd ff ff       	call   f01063fc <cpunum>
f01066e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01066e7:	29 c2                	sub    %eax,%edx
f01066e9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01066ec:	8d 04 85 20 20 2e f0 	lea    -0xfd1dfe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01066f3:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01066f5:	0f 94 c0             	sete   %al
f01066f8:	0f b6 c0             	movzbl %al,%eax
f01066fb:	eb 05                	jmp    f0106702 <holding+0x36>
f01066fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106702:	83 c4 04             	add    $0x4,%esp
f0106705:	5b                   	pop    %ebx
f0106706:	5d                   	pop    %ebp
f0106707:	c3                   	ret    

f0106708 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106708:	55                   	push   %ebp
f0106709:	89 e5                	mov    %esp,%ebp
f010670b:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010670e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106714:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106717:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010671a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106721:	5d                   	pop    %ebp
f0106722:	c3                   	ret    

f0106723 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106723:	55                   	push   %ebp
f0106724:	89 e5                	mov    %esp,%ebp
f0106726:	53                   	push   %ebx
f0106727:	83 ec 24             	sub    $0x24,%esp
f010672a:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010672d:	89 d8                	mov    %ebx,%eax
f010672f:	e8 98 ff ff ff       	call   f01066cc <holding>
f0106734:	85 c0                	test   %eax,%eax
f0106736:	74 30                	je     f0106768 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106738:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010673b:	e8 bc fc ff ff       	call   f01063fc <cpunum>
f0106740:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106744:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106748:	c7 44 24 08 30 93 10 	movl   $0xf0109330,0x8(%esp)
f010674f:	f0 
f0106750:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106757:	00 
f0106758:	c7 04 24 92 93 10 f0 	movl   $0xf0109392,(%esp)
f010675f:	e8 dc 98 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106764:	f3 90                	pause  
f0106766:	eb 05                	jmp    f010676d <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106768:	ba 01 00 00 00       	mov    $0x1,%edx
f010676d:	89 d0                	mov    %edx,%eax
f010676f:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106772:	85 c0                	test   %eax,%eax
f0106774:	75 ee                	jne    f0106764 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106776:	e8 81 fc ff ff       	call   f01063fc <cpunum>
f010677b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106782:	29 c2                	sub    %eax,%edx
f0106784:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106787:	8d 04 85 20 20 2e f0 	lea    -0xfd1dfe0(,%eax,4),%eax
f010678e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106791:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106794:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106796:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010679b:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01067a1:	76 10                	jbe    f01067b3 <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01067a3:	8b 4a 04             	mov    0x4(%edx),%ecx
f01067a6:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01067a9:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01067ab:	40                   	inc    %eax
f01067ac:	83 f8 0a             	cmp    $0xa,%eax
f01067af:	75 ea                	jne    f010679b <spin_lock+0x78>
f01067b1:	eb 0d                	jmp    f01067c0 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01067b3:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01067ba:	40                   	inc    %eax
f01067bb:	83 f8 09             	cmp    $0x9,%eax
f01067be:	7e f3                	jle    f01067b3 <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01067c0:	83 c4 24             	add    $0x24,%esp
f01067c3:	5b                   	pop    %ebx
f01067c4:	5d                   	pop    %ebp
f01067c5:	c3                   	ret    

f01067c6 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01067c6:	55                   	push   %ebp
f01067c7:	89 e5                	mov    %esp,%ebp
f01067c9:	57                   	push   %edi
f01067ca:	56                   	push   %esi
f01067cb:	53                   	push   %ebx
f01067cc:	83 ec 7c             	sub    $0x7c,%esp
f01067cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01067d2:	89 d8                	mov    %ebx,%eax
f01067d4:	e8 f3 fe ff ff       	call   f01066cc <holding>
f01067d9:	85 c0                	test   %eax,%eax
f01067db:	0f 85 d3 00 00 00    	jne    f01068b4 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01067e1:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01067e8:	00 
f01067e9:	8d 43 0c             	lea    0xc(%ebx),%eax
f01067ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067f0:	8d 75 a8             	lea    -0x58(%ebp),%esi
f01067f3:	89 34 24             	mov    %esi,(%esp)
f01067f6:	e8 0d f6 ff ff       	call   f0105e08 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01067fb:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01067fe:	0f b6 38             	movzbl (%eax),%edi
f0106801:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106804:	e8 f3 fb ff ff       	call   f01063fc <cpunum>
f0106809:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010680d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106811:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106815:	c7 04 24 5c 93 10 f0 	movl   $0xf010935c,(%esp)
f010681c:	e8 69 d6 ff ff       	call   f0103e8a <cprintf>
f0106821:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106823:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106826:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106829:	89 c7                	mov    %eax,%edi
f010682b:	eb 63                	jmp    f0106890 <spin_unlock+0xca>
f010682d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106831:	89 04 24             	mov    %eax,(%esp)
f0106834:	e8 8c eb ff ff       	call   f01053c5 <debuginfo_eip>
f0106839:	85 c0                	test   %eax,%eax
f010683b:	78 39                	js     f0106876 <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010683d:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010683f:	89 c2                	mov    %eax,%edx
f0106841:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106844:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106848:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010684b:	89 54 24 14          	mov    %edx,0x14(%esp)
f010684f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106852:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106856:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106859:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010685d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106860:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106864:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106868:	c7 04 24 a2 93 10 f0 	movl   $0xf01093a2,(%esp)
f010686f:	e8 16 d6 ff ff       	call   f0103e8a <cprintf>
f0106874:	eb 12                	jmp    f0106888 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106876:	8b 06                	mov    (%esi),%eax
f0106878:	89 44 24 04          	mov    %eax,0x4(%esp)
f010687c:	c7 04 24 b9 93 10 f0 	movl   $0xf01093b9,(%esp)
f0106883:	e8 02 d6 ff ff       	call   f0103e8a <cprintf>
f0106888:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010688b:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f010688e:	74 08                	je     f0106898 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106890:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106892:	8b 03                	mov    (%ebx),%eax
f0106894:	85 c0                	test   %eax,%eax
f0106896:	75 95                	jne    f010682d <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106898:	c7 44 24 08 c1 93 10 	movl   $0xf01093c1,0x8(%esp)
f010689f:	f0 
f01068a0:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01068a7:	00 
f01068a8:	c7 04 24 92 93 10 f0 	movl   $0xf0109392,(%esp)
f01068af:	e8 8c 97 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01068b4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01068bb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f01068c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01068c7:	f0 87 03             	lock xchg %eax,(%ebx)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01068ca:	83 c4 7c             	add    $0x7c,%esp
f01068cd:	5b                   	pop    %ebx
f01068ce:	5e                   	pop    %esi
f01068cf:	5f                   	pop    %edi
f01068d0:	5d                   	pop    %ebp
f01068d1:	c3                   	ret    
	...

f01068d4 <e1000_transmit_init>:
	// transmit(packet, len);	
	
	return 0;
}

void e1000_transmit_init(){
f01068d4:	55                   	push   %ebp
f01068d5:	89 e5                	mov    %esp,%ebp
f01068d7:	53                   	push   %ebx
f01068d8:	83 ec 14             	sub    $0x14,%esp
	struct PageInfo *page;
	page = page_alloc(ALLOC_ZERO);
f01068db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01068e2:	e8 04 a7 ff ff       	call   f0100feb <page_alloc>
	if (!page)
f01068e7:	85 c0                	test   %eax,%eax
f01068e9:	75 1c                	jne    f0106907 <e1000_transmit_init+0x33>
	{
		panic("e1000_attach, page_alloc error");
f01068eb:	c7 44 24 08 dc 93 10 	movl   $0xf01093dc,0x8(%esp)
f01068f2:	f0 
f01068f3:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
f01068fa:	00 
f01068fb:	c7 04 24 47 94 10 f0 	movl   $0xf0109447,(%esp)
f0106902:	e8 39 97 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0106907:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f010690d:	c1 f8 03             	sar    $0x3,%eax
f0106910:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106913:	89 c2                	mov    %eax,%edx
f0106915:	c1 ea 0c             	shr    $0xc,%edx
f0106918:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f010691e:	72 20                	jb     f0106940 <e1000_transmit_init+0x6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106920:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106924:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f010692b:	f0 
f010692c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0106933:	00 
f0106934:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f010693b:	e8 00 97 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106940:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0106945:	a3 08 30 32 f0       	mov    %eax,0xf0323008
	}
	tx_ring = (struct tx_desc *)page2kva(page);
f010694a:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (uint32_t i = 0; i < RING_SIZE; ++i)
	{
		page = page_alloc(ALLOC_ZERO);
f010694f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106956:	e8 90 a6 ff ff       	call   f0100feb <page_alloc>
		if (!page)
f010695b:	85 c0                	test   %eax,%eax
f010695d:	75 1c                	jne    f010697b <e1000_transmit_init+0xa7>
		{
		    	panic("e1000_attach, page_alloc error");
f010695f:	c7 44 24 08 dc 93 10 	movl   $0xf01093dc,0x8(%esp)
f0106966:	f0 
f0106967:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
f010696e:	00 
f010696f:	c7 04 24 47 94 10 f0 	movl   $0xf0109447,(%esp)
f0106976:	e8 c5 96 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010697b:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0106981:	c1 f8 03             	sar    $0x3,%eax
f0106984:	c1 e0 0c             	shl    $0xc,%eax
		}
		tx_ring[i].addr = page2pa(page);
f0106987:	8b 15 08 30 32 f0    	mov    0xf0323008,%edx
f010698d:	89 04 1a             	mov    %eax,(%edx,%ebx,1)
f0106990:	c7 44 1a 04 00 00 00 	movl   $0x0,0x4(%edx,%ebx,1)
f0106997:	00 
		tx_ring[i].status |= E1000_TX_DESC_STATUS_DD; 
f0106998:	89 d8                	mov    %ebx,%eax
f010699a:	03 05 08 30 32 f0    	add    0xf0323008,%eax
f01069a0:	80 48 0c 01          	orb    $0x1,0xc(%eax)
		tx_ring[i].cmd = 0;
f01069a4:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
f01069a8:	83 c3 10             	add    $0x10,%ebx
	if (!page)
	{
		panic("e1000_attach, page_alloc error");
	}
	tx_ring = (struct tx_desc *)page2kva(page);
	for (uint32_t i = 0; i < RING_SIZE; ++i)
f01069ab:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01069b1:	75 9c                	jne    f010694f <e1000_transmit_init+0x7b>
		tx_ring[i].addr = page2pa(page);
		tx_ring[i].status |= E1000_TX_DESC_STATUS_DD; 
		tx_ring[i].cmd = 0;
	}
	
	e1000[E1000_TDBAL] = PADDR((void*)tx_ring); // (uint32_t)tx_ring;
f01069b3:	a1 10 30 32 f0       	mov    0xf0323010,%eax
f01069b8:	8b 15 08 30 32 f0    	mov    0xf0323008,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01069be:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01069c4:	77 20                	ja     f01069e6 <e1000_transmit_init+0x112>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01069c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01069ca:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f01069d1:	f0 
f01069d2:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01069d9:	00 
f01069da:	c7 04 24 47 94 10 f0 	movl   $0xf0109447,(%esp)
f01069e1:	e8 5a 96 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01069e6:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01069ec:	89 90 00 38 00 00    	mov    %edx,0x3800(%eax)
	e1000[E1000_TDBAH] = 0;
f01069f2:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f01069f9:	00 00 00 
	e1000[E1000_TDLEN] = sizeof(struct tx_desc) * RING_SIZE;
f01069fc:	c7 80 08 38 00 00 00 	movl   $0x400,0x3808(%eax)
f0106a03:	04 00 00 
	e1000[E1000_TDH] = 0;
f0106a06:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f0106a0d:	00 00 00 
	e1000[E1000_TDT] = 0;
f0106a10:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f0106a17:	00 00 00 

	e1000[E1000_TCTL] = 0;
f0106a1a:	c7 80 00 04 00 00 00 	movl   $0x0,0x400(%eax)
f0106a21:	00 00 00 
	e1000[E1000_TCTL] |= E1000_TCTL_EN;
f0106a24:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106a2a:	83 ca 02             	or     $0x2,%edx
f0106a2d:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	e1000[E1000_TCTL] |= E1000_TCTL_PSP;
f0106a33:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106a39:	83 ca 08             	or     $0x8,%edx
f0106a3c:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	e1000[E1000_TCTL] |= (0x10 << 4);
f0106a42:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106a48:	80 ce 01             	or     $0x1,%dh
f0106a4b:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	e1000[E1000_TCTL] |= (0x40 << 12);
f0106a51:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106a57:	81 ca 00 00 04 00    	or     $0x40000,%edx
f0106a5d:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)

	e1000[E1000_TIPG] = 0;
f0106a63:	c7 80 10 04 00 00 00 	movl   $0x0,0x410(%eax)
f0106a6a:	00 00 00 
	e1000[E1000_TIPG] |= 10;
f0106a6d:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0106a73:	83 ca 0a             	or     $0xa,%edx
f0106a76:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
	e1000[E1000_TIPG] |= (4 << 10);
f0106a7c:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0106a82:	80 ce 10             	or     $0x10,%dh
f0106a85:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
	e1000[E1000_TIPG] |= (6 << 20);
f0106a8b:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0106a91:	81 ca 00 00 60 00    	or     $0x600000,%edx
f0106a97:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
}
f0106a9d:	83 c4 14             	add    $0x14,%esp
f0106aa0:	5b                   	pop    %ebx
f0106aa1:	5d                   	pop    %ebp
f0106aa2:	c3                   	ret    

f0106aa3 <e1000_receive_init>:

void e1000_receive_init(){
f0106aa3:	55                   	push   %ebp
f0106aa4:	89 e5                	mov    %esp,%ebp
f0106aa6:	53                   	push   %ebx
f0106aa7:	83 ec 14             	sub    $0x14,%esp
    e1000[E1000_RAL]=0x12005452;  // 52:54:00:12
f0106aaa:	a1 10 30 32 f0       	mov    0xf0323010,%eax
f0106aaf:	c7 80 00 54 00 00 52 	movl   $0x12005452,0x5400(%eax)
f0106ab6:	54 00 12 
    e1000[E1000_RAH]=0x00005634;  // 34:56;
f0106ab9:	c7 80 04 54 00 00 34 	movl   $0x5634,0x5404(%eax)
f0106ac0:	56 00 00 
    e1000[E1000_RAH]|=E1000_RAH_AV;
f0106ac3:	8b 90 04 54 00 00    	mov    0x5404(%eax),%edx
f0106ac9:	81 ca 00 00 00 80    	or     $0x80000000,%edx
f0106acf:	89 90 04 54 00 00    	mov    %edx,0x5404(%eax)
    struct PageInfo *page;
    page = page_alloc(ALLOC_ZERO);
f0106ad5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106adc:	e8 0a a5 ff ff       	call   f0100feb <page_alloc>
    if (!page)
f0106ae1:	85 c0                	test   %eax,%eax
f0106ae3:	75 1c                	jne    f0106b01 <e1000_receive_init+0x5e>
    {
        panic("e1000_attach, page_alloc error");
f0106ae5:	c7 44 24 08 dc 93 10 	movl   $0xf01093dc,0x8(%esp)
f0106aec:	f0 
f0106aed:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
f0106af4:	00 
f0106af5:	c7 04 24 47 94 10 f0 	movl   $0xf0109447,(%esp)
f0106afc:	e8 3f 95 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0106b01:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0106b07:	c1 f8 03             	sar    $0x3,%eax
f0106b0a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106b0d:	89 c2                	mov    %eax,%edx
f0106b0f:	c1 ea 0c             	shr    $0xc,%edx
f0106b12:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f0106b18:	72 20                	jb     f0106b3a <e1000_receive_init+0x97>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106b1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106b1e:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0106b25:	f0 
f0106b26:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0106b2d:	00 
f0106b2e:	c7 04 24 f6 85 10 f0 	movl   $0xf01085f6,(%esp)
f0106b35:	e8 06 95 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106b3a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0106b3f:	a3 0c 30 32 f0       	mov    %eax,0xf032300c
    }
    rx_ring = (struct rx_desc *)page2kva(page);
f0106b44:	bb 00 00 00 00       	mov    $0x0,%ebx
    for (uint32_t i = 0; i < RECEIVE_RING_SIZE; ++i)
    {
        page = page_alloc(ALLOC_ZERO);
f0106b49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106b50:	e8 96 a4 ff ff       	call   f0100feb <page_alloc>
        if (!page)
f0106b55:	85 c0                	test   %eax,%eax
f0106b57:	75 1c                	jne    f0106b75 <e1000_receive_init+0xd2>
        {
            panic("e1000_receive_init, page_alloc error");
f0106b59:	c7 44 24 08 fc 93 10 	movl   $0xf01093fc,0x8(%esp)
f0106b60:	f0 
f0106b61:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
f0106b68:	00 
f0106b69:	c7 04 24 47 94 10 f0 	movl   $0xf0109447,(%esp)
f0106b70:	e8 cb 94 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0106b75:	2b 05 a0 1e 2e f0    	sub    0xf02e1ea0,%eax
f0106b7b:	c1 f8 03             	sar    $0x3,%eax
f0106b7e:	c1 e0 0c             	shl    $0xc,%eax
        }
        rx_ring[i].addr = page2pa(page);
f0106b81:	8b 15 0c 30 32 f0    	mov    0xf032300c,%edx
f0106b87:	89 04 1a             	mov    %eax,(%edx,%ebx,1)
f0106b8a:	c7 44 1a 04 00 00 00 	movl   $0x0,0x4(%edx,%ebx,1)
f0106b91:	00 
        rx_ring[i].status = 0; // |= E1000_TX_DESC_STATUS_DD;
f0106b92:	a1 0c 30 32 f0       	mov    0xf032300c,%eax
f0106b97:	c6 44 18 0c 00       	movb   $0x0,0xc(%eax,%ebx,1)
f0106b9c:	83 c3 10             	add    $0x10,%ebx
    if (!page)
    {
        panic("e1000_attach, page_alloc error");
    }
    rx_ring = (struct rx_desc *)page2kva(page);
    for (uint32_t i = 0; i < RECEIVE_RING_SIZE; ++i)
f0106b9f:	81 fb 00 08 00 00    	cmp    $0x800,%ebx
f0106ba5:	75 a2                	jne    f0106b49 <e1000_receive_init+0xa6>
            panic("e1000_receive_init, page_alloc error");
        }
        rx_ring[i].addr = page2pa(page);
        rx_ring[i].status = 0; // |= E1000_TX_DESC_STATUS_DD;
    }
    e1000[E1000_RDBAL] = PADDR((void*)rx_ring);
f0106ba7:	a1 10 30 32 f0       	mov    0xf0323010,%eax
f0106bac:	8b 15 0c 30 32 f0    	mov    0xf032300c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0106bb2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106bb8:	77 20                	ja     f0106bda <e1000_receive_init+0x137>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106bba:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106bbe:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0106bc5:	f0 
f0106bc6:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
f0106bcd:	00 
f0106bce:	c7 04 24 47 94 10 f0 	movl   $0xf0109447,(%esp)
f0106bd5:	e8 66 94 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0106bda:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0106be0:	89 90 00 28 00 00    	mov    %edx,0x2800(%eax)
    e1000[E1000_RDBAH] = 0;
f0106be6:	c7 80 04 28 00 00 00 	movl   $0x0,0x2804(%eax)
f0106bed:	00 00 00 
    e1000[E1000_RDLEN] = sizeof(struct rx_desc) * RECEIVE_RING_SIZE;
f0106bf0:	c7 80 08 28 00 00 00 	movl   $0x800,0x2808(%eax)
f0106bf7:	08 00 00 
    e1000[E1000_RDH]=0;
f0106bfa:	c7 80 10 28 00 00 00 	movl   $0x0,0x2810(%eax)
f0106c01:	00 00 00 
    e1000[E1000_RDT]=RECEIVE_RING_SIZE - 1;
f0106c04:	c7 80 18 28 00 00 7f 	movl   $0x7f,0x2818(%eax)
f0106c0b:	00 00 00 

    e1000[E1000_RCTL]=0;
f0106c0e:	c7 80 00 01 00 00 00 	movl   $0x0,0x100(%eax)
f0106c15:	00 00 00 
    e1000[E1000_RCTL]|=E1000_RCTL_SZ_2048;
f0106c18:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0106c1e:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
    e1000[E1000_RCTL]|=E1000_RCTL_BAM;
f0106c24:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0106c2a:	80 ce 80             	or     $0x80,%dh
f0106c2d:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
    e1000[E1000_RCTL]|=E1000_RCTL_LBM_NO;
f0106c33:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0106c39:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
    e1000[E1000_RCTL]|=E1000_RCTL_SECRC;
f0106c3f:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0106c45:	81 ca 00 00 00 04    	or     $0x4000000,%edx
f0106c4b:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
    e1000[E1000_RCTL]|=E1000_RCTL_EN;
f0106c51:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0106c57:	83 ca 02             	or     $0x2,%edx
f0106c5a:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
}
f0106c60:	83 c4 14             	add    $0x14,%esp
f0106c63:	5b                   	pop    %ebx
f0106c64:	5d                   	pop    %ebp
f0106c65:	c3                   	ret    

f0106c66 <e1000_attach>:
volatile uint32_t *e1000;
struct tx_desc *tx_ring;
struct rx_desc *rx_ring;


int e1000_attach(struct pci_func *pcif){
f0106c66:	55                   	push   %ebp
f0106c67:	89 e5                	mov    %esp,%ebp
f0106c69:	53                   	push   %ebx
f0106c6a:	83 ec 14             	sub    $0x14,%esp
f0106c6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif);
f0106c70:	89 1c 24             	mov    %ebx,(%esp)
f0106c73:	e8 4d 06 00 00       	call   f01072c5 <pci_func_enable>
	cprintf("reg_base[0]: %08x, reg_size[0]:%d\n",pcif->reg_base[0],pcif->reg_size[0]);
f0106c78:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0106c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106c7f:	8b 43 14             	mov    0x14(%ebx),%eax
f0106c82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c86:	c7 04 24 24 94 10 f0 	movl   $0xf0109424,(%esp)
f0106c8d:	e8 f8 d1 ff ff       	call   f0103e8a <cprintf>
	e1000=mmio_map_region(pcif->reg_base[0],pcif->reg_size[0]);
f0106c92:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0106c95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c99:	8b 43 14             	mov    0x14(%ebx),%eax
f0106c9c:	89 04 24             	mov    %eax,(%esp)
f0106c9f:	e8 a4 a6 ff ff       	call   f0101348 <mmio_map_region>
f0106ca4:	a3 10 30 32 f0       	mov    %eax,0xf0323010
    	cprintf("status %08x\n",e1000[E1000_STATUS]);
f0106ca9:	8b 40 08             	mov    0x8(%eax),%eax
f0106cac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cb0:	c7 04 24 54 94 10 f0 	movl   $0xf0109454,(%esp)
f0106cb7:	e8 ce d1 ff ff       	call   f0103e8a <cprintf>
    	
    	e1000_transmit_init();
f0106cbc:	e8 13 fc ff ff       	call   f01068d4 <e1000_transmit_init>

	e1000_receive_init();
f0106cc1:	e8 dd fd ff ff       	call   f0106aa3 <e1000_receive_init>
	uint32_t len = 11;
	
	// transmit(packet, len);	
	
	return 0;
}
f0106cc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0106ccb:	83 c4 14             	add    $0x14,%esp
f0106cce:	5b                   	pop    %ebx
f0106ccf:	5d                   	pop    %ebp
f0106cd0:	c3                   	ret    

f0106cd1 <transmit>:
    e1000[E1000_RCTL]|=E1000_RCTL_SECRC;
    e1000[E1000_RCTL]|=E1000_RCTL_EN;
}

int transmit(char *packet, uint32_t len)
{
f0106cd1:	55                   	push   %ebp
f0106cd2:	89 e5                	mov    %esp,%ebp
f0106cd4:	57                   	push   %edi
f0106cd5:	56                   	push   %esi
f0106cd6:	53                   	push   %ebx
f0106cd7:	83 ec 1c             	sub    $0x1c,%esp
f0106cda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    uint32_t idx = e1000[E1000_TDT] % RING_SIZE;
f0106cdd:	a1 10 30 32 f0       	mov    0xf0323010,%eax
f0106ce2:	8b b8 18 38 00 00    	mov    0x3818(%eax),%edi
f0106ce8:	83 e7 3f             	and    $0x3f,%edi
    //STATUS, DD bit:0
    //CMD, RS bit:3, EOP bit:0
    // cprintf("$$$$$$$$$$$$ 1 %d\n",idx);
    if (tx_ring[idx].status & E1000_TX_DESC_STATUS_DD)
f0106ceb:	89 fe                	mov    %edi,%esi
f0106ced:	c1 e6 04             	shl    $0x4,%esi
f0106cf0:	89 f0                	mov    %esi,%eax
f0106cf2:	03 05 08 30 32 f0    	add    0xf0323008,%eax
f0106cf8:	8a 50 0c             	mov    0xc(%eax),%dl
f0106cfb:	f6 c2 01             	test   $0x1,%dl
f0106cfe:	74 71                	je     f0106d71 <transmit+0xa0>
    {
    	// cprintf("$$$$$$$$$$$$ 2 %d\n",idx);
        tx_ring[idx].status &= ~E1000_TX_DESC_STATUS_DD;
f0106d00:	83 e2 fe             	and    $0xfffffffe,%edx
f0106d03:	88 50 0c             	mov    %dl,0xc(%eax)
        void *va = KADDR(tx_ring[idx].addr);
f0106d06:	8b 00                	mov    (%eax),%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106d08:	89 c2                	mov    %eax,%edx
f0106d0a:	c1 ea 0c             	shr    $0xc,%edx
f0106d0d:	3b 15 98 1e 2e f0    	cmp    0xf02e1e98,%edx
f0106d13:	72 20                	jb     f0106d35 <transmit+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106d15:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106d19:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0106d20:	f0 
f0106d21:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0106d28:	00 
f0106d29:	c7 04 24 47 94 10 f0 	movl   $0xf0109447,(%esp)
f0106d30:	e8 0b 93 ff ff       	call   f0100040 <_panic>
        memcpy(va, packet, len);
f0106d35:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106d39:	8b 55 08             	mov    0x8(%ebp),%edx
f0106d3c:	89 54 24 04          	mov    %edx,0x4(%esp)
	return (void *)(pa + KERNBASE);
f0106d40:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0106d45:	89 04 24             	mov    %eax,(%esp)
f0106d48:	e8 25 f1 ff ff       	call   f0105e72 <memcpy>
        tx_ring[idx].length = len;
f0106d4d:	03 35 08 30 32 f0    	add    0xf0323008,%esi
f0106d53:	66 89 5e 08          	mov    %bx,0x8(%esi)
        tx_ring[idx].cmd |= (E1000_TX_DESC_CMD_EOP | E1000_TX_DESC_CMD_RS);
f0106d57:	80 4e 0b 09          	orb    $0x9,0xb(%esi)
        e1000[E1000_TDT] = (idx + 1) % RING_SIZE;
f0106d5b:	47                   	inc    %edi
f0106d5c:	83 e7 3f             	and    $0x3f,%edi
f0106d5f:	a1 10 30 32 f0       	mov    0xf0323010,%eax
f0106d64:	89 b8 18 38 00 00    	mov    %edi,0x3818(%eax)
        return 0;
f0106d6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0106d6f:	eb 05                	jmp    f0106d76 <transmit+0xa5>
    }
    // cprintf("$$$$$$$$$$$$ 3 %d\n",idx);
    return -E_NET_NO_DES;
f0106d71:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
}
f0106d76:	83 c4 1c             	add    $0x1c,%esp
f0106d79:	5b                   	pop    %ebx
f0106d7a:	5e                   	pop    %esi
f0106d7b:	5f                   	pop    %edi
f0106d7c:	5d                   	pop    %ebp
f0106d7d:	c3                   	ret    

f0106d7e <receive>:

int receive(char *packet, uint32_t *len)
{
f0106d7e:	55                   	push   %ebp
f0106d7f:	89 e5                	mov    %esp,%ebp
f0106d81:	83 ec 18             	sub    $0x18,%esp
    static uint32_t idx = 0; 
    // uint32_t idx = e1000[E1000_RDT];
    if (rx_ring[idx].status & E1000_RX_DESC_STATUS_DD)
f0106d84:	a1 80 1e 2e f0       	mov    0xf02e1e80,%eax
f0106d89:	c1 e0 04             	shl    $0x4,%eax
f0106d8c:	03 05 0c 30 32 f0    	add    0xf032300c,%eax
f0106d92:	8a 50 0c             	mov    0xc(%eax),%dl
f0106d95:	f6 c2 01             	test   $0x1,%dl
f0106d98:	0f 84 aa 00 00 00    	je     f0106e48 <receive+0xca>
    {
        rx_ring[idx].status &= (~E1000_RX_DESC_STATUS_DD & ~E1000_RX_DESC_STATUS_EOP);
f0106d9e:	83 e2 fc             	and    $0xfffffffc,%edx
f0106da1:	88 50 0c             	mov    %dl,0xc(%eax)
        void *va = KADDR(rx_ring[idx].addr);
f0106da4:	8b 10                	mov    (%eax),%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106da6:	89 d1                	mov    %edx,%ecx
f0106da8:	c1 e9 0c             	shr    $0xc,%ecx
f0106dab:	3b 0d 98 1e 2e f0    	cmp    0xf02e1e98,%ecx
f0106db1:	72 20                	jb     f0106dd3 <receive+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106db3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106db7:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0106dbe:	f0 
f0106dbf:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
f0106dc6:	00 
f0106dc7:	c7 04 24 47 94 10 f0 	movl   $0xf0109447,(%esp)
f0106dce:	e8 6d 92 ff ff       	call   f0100040 <_panic>
        memcpy(packet, va, rx_ring[idx].length);
f0106dd3:	0f b7 40 08          	movzwl 0x8(%eax),%eax
f0106dd7:	89 44 24 08          	mov    %eax,0x8(%esp)
	return (void *)(pa + KERNBASE);
f0106ddb:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0106de1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106de5:	8b 45 08             	mov    0x8(%ebp),%eax
f0106de8:	89 04 24             	mov    %eax,(%esp)
f0106deb:	e8 82 f0 ff ff       	call   f0105e72 <memcpy>
        *len = rx_ring[idx].length;
f0106df0:	a1 80 1e 2e f0       	mov    0xf02e1e80,%eax
f0106df5:	89 c2                	mov    %eax,%edx
f0106df7:	c1 e2 04             	shl    $0x4,%edx
f0106dfa:	03 15 0c 30 32 f0    	add    0xf032300c,%edx
f0106e00:	0f b7 4a 08          	movzwl 0x8(%edx),%ecx
f0106e04:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106e07:	89 0a                	mov    %ecx,(%edx)
	cprintf("rdt: %d, rdh: %d, idx %d\n", e1000[E1000_RDT], e1000[E1000_RDH], idx);
f0106e09:	8b 15 10 30 32 f0    	mov    0xf0323010,%edx
f0106e0f:	8b 8a 10 28 00 00    	mov    0x2810(%edx),%ecx
f0106e15:	8b 92 18 28 00 00    	mov    0x2818(%edx),%edx
f0106e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106e1f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106e23:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106e27:	c7 04 24 61 94 10 f0 	movl   $0xf0109461,(%esp)
f0106e2e:	e8 57 d0 ff ff       	call   f0103e8a <cprintf>
        idx = (idx + 1) % RECEIVE_RING_SIZE;
f0106e33:	a1 80 1e 2e f0       	mov    0xf02e1e80,%eax
f0106e38:	40                   	inc    %eax
f0106e39:	83 e0 7f             	and    $0x7f,%eax
f0106e3c:	a3 80 1e 2e f0       	mov    %eax,0xf02e1e80
        // e1000[E1000_RDT] = (idx + 1) % RECEIVE_RING_SIZE;
	return 0;
f0106e41:	b8 00 00 00 00       	mov    $0x0,%eax
f0106e46:	eb 05                	jmp    f0106e4d <receive+0xcf>
    }
    // cprintf("why why\n");
    return -E_NET_NO_DES;
f0106e48:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
}
f0106e4d:	c9                   	leave  
f0106e4e:	c3                   	ret    
	...

f0106e50 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0106e50:	55                   	push   %ebp
f0106e51:	89 e5                	mov    %esp,%ebp
f0106e53:	57                   	push   %edi
f0106e54:	56                   	push   %esi
f0106e55:	53                   	push   %ebx
f0106e56:	83 ec 3c             	sub    $0x3c,%esp
f0106e59:	89 c7                	mov    %eax,%edi
f0106e5b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				cprintf("pci_attach_match: attaching "
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
f0106e5e:	89 cb                	mov    %ecx,%ebx
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0106e60:	eb 41                	jmp    f0106ea3 <pci_attach_match+0x53>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0106e62:	39 3b                	cmp    %edi,(%ebx)
f0106e64:	75 3a                	jne    f0106ea0 <pci_attach_match+0x50>
f0106e66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106e69:	39 56 04             	cmp    %edx,0x4(%esi)
f0106e6c:	75 32                	jne    f0106ea0 <pci_attach_match+0x50>
			int r = list[i].attachfn(pcif);
f0106e6e:	8b 55 08             	mov    0x8(%ebp),%edx
f0106e71:	89 14 24             	mov    %edx,(%esp)
f0106e74:	ff d0                	call   *%eax
			if (r > 0)
f0106e76:	85 c0                	test   %eax,%eax
f0106e78:	7f 32                	jg     f0106eac <pci_attach_match+0x5c>
				return r;
			if (r < 0)
f0106e7a:	85 c0                	test   %eax,%eax
f0106e7c:	79 22                	jns    f0106ea0 <pci_attach_match+0x50>
				cprintf("pci_attach_match: attaching "
f0106e7e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106e82:	8b 46 08             	mov    0x8(%esi),%eax
f0106e85:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106e89:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106e8c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106e90:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106e94:	c7 04 24 7c 94 10 f0 	movl   $0xf010947c,(%esp)
f0106e9b:	e8 ea cf ff ff       	call   f0103e8a <cprintf>
f0106ea0:	83 c3 0c             	add    $0xc,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
	outl(pci_conf1_data_ioport, v);
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
f0106ea3:	89 de                	mov    %ebx,%esi
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0106ea5:	8b 43 08             	mov    0x8(%ebx),%eax
f0106ea8:	85 c0                	test   %eax,%eax
f0106eaa:	75 b6                	jne    f0106e62 <pci_attach_match+0x12>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0106eac:	83 c4 3c             	add    $0x3c,%esp
f0106eaf:	5b                   	pop    %ebx
f0106eb0:	5e                   	pop    %esi
f0106eb1:	5f                   	pop    %edi
f0106eb2:	5d                   	pop    %ebp
f0106eb3:	c3                   	ret    

f0106eb4 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f0106eb4:	55                   	push   %ebp
f0106eb5:	89 e5                	mov    %esp,%ebp
f0106eb7:	53                   	push   %ebx
f0106eb8:	83 ec 14             	sub    $0x14,%esp
f0106ebb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f0106ebe:	3d ff 00 00 00       	cmp    $0xff,%eax
f0106ec3:	76 24                	jbe    f0106ee9 <pci_conf1_set_addr+0x35>
f0106ec5:	c7 44 24 0c d4 95 10 	movl   $0xf01095d4,0xc(%esp)
f0106ecc:	f0 
f0106ecd:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0106ed4:	f0 
f0106ed5:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0106edc:	00 
f0106edd:	c7 04 24 de 95 10 f0 	movl   $0xf01095de,(%esp)
f0106ee4:	e8 57 91 ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f0106ee9:	83 fa 1f             	cmp    $0x1f,%edx
f0106eec:	76 24                	jbe    f0106f12 <pci_conf1_set_addr+0x5e>
f0106eee:	c7 44 24 0c e9 95 10 	movl   $0xf01095e9,0xc(%esp)
f0106ef5:	f0 
f0106ef6:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0106efd:	f0 
f0106efe:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
f0106f05:	00 
f0106f06:	c7 04 24 de 95 10 f0 	movl   $0xf01095de,(%esp)
f0106f0d:	e8 2e 91 ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0106f12:	83 f9 07             	cmp    $0x7,%ecx
f0106f15:	76 24                	jbe    f0106f3b <pci_conf1_set_addr+0x87>
f0106f17:	c7 44 24 0c f2 95 10 	movl   $0xf01095f2,0xc(%esp)
f0106f1e:	f0 
f0106f1f:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0106f26:	f0 
f0106f27:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
f0106f2e:	00 
f0106f2f:	c7 04 24 de 95 10 f0 	movl   $0xf01095de,(%esp)
f0106f36:	e8 05 91 ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f0106f3b:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0106f41:	76 24                	jbe    f0106f67 <pci_conf1_set_addr+0xb3>
f0106f43:	c7 44 24 0c fb 95 10 	movl   $0xf01095fb,0xc(%esp)
f0106f4a:	f0 
f0106f4b:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0106f52:	f0 
f0106f53:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
f0106f5a:	00 
f0106f5b:	c7 04 24 de 95 10 f0 	movl   $0xf01095de,(%esp)
f0106f62:	e8 d9 90 ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f0106f67:	f6 c3 03             	test   $0x3,%bl
f0106f6a:	74 24                	je     f0106f90 <pci_conf1_set_addr+0xdc>
f0106f6c:	c7 44 24 0c 08 96 10 	movl   $0xf0109608,0xc(%esp)
f0106f73:	f0 
f0106f74:	c7 44 24 08 10 86 10 	movl   $0xf0108610,0x8(%esp)
f0106f7b:	f0 
f0106f7c:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
f0106f83:	00 
f0106f84:	c7 04 24 de 95 10 f0 	movl   $0xf01095de,(%esp)
f0106f8b:	e8 b0 90 ff ff       	call   f0100040 <_panic>

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
f0106f90:	c1 e0 10             	shl    $0x10,%eax
f0106f93:	0d 00 00 00 80       	or     $0x80000000,%eax
f0106f98:	c1 e2 0b             	shl    $0xb,%edx
f0106f9b:	09 d0                	or     %edx,%eax
f0106f9d:	09 d8                	or     %ebx,%eax
f0106f9f:	c1 e1 08             	shl    $0x8,%ecx
	assert(dev < 32);
	assert(func < 8);
	assert(offset < 256);
	assert((offset & 0x3) == 0);

	uint32_t v = (1 << 31) |		// config-space
f0106fa2:	09 c8                	or     %ecx,%eax
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106fa4:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0106fa9:	ef                   	out    %eax,(%dx)
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0106faa:	83 c4 14             	add    $0x14,%esp
f0106fad:	5b                   	pop    %ebx
f0106fae:	5d                   	pop    %ebp
f0106faf:	c3                   	ret    

f0106fb0 <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f0106fb0:	55                   	push   %ebp
f0106fb1:	89 e5                	mov    %esp,%ebp
f0106fb3:	53                   	push   %ebx
f0106fb4:	83 ec 14             	sub    $0x14,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106fb7:	8b 48 08             	mov    0x8(%eax),%ecx
f0106fba:	8b 58 04             	mov    0x4(%eax),%ebx
f0106fbd:	8b 00                	mov    (%eax),%eax
f0106fbf:	8b 40 04             	mov    0x4(%eax),%eax
f0106fc2:	89 14 24             	mov    %edx,(%esp)
f0106fc5:	89 da                	mov    %ebx,%edx
f0106fc7:	e8 e8 fe ff ff       	call   f0106eb4 <pci_conf1_set_addr>

static inline uint32_t
inl(int port)
{
	uint32_t data;
	asm volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0106fcc:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106fd1:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f0106fd2:	83 c4 14             	add    $0x14,%esp
f0106fd5:	5b                   	pop    %ebx
f0106fd6:	5d                   	pop    %ebp
f0106fd7:	c3                   	ret    

f0106fd8 <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f0106fd8:	55                   	push   %ebp
f0106fd9:	89 e5                	mov    %esp,%ebp
f0106fdb:	57                   	push   %edi
f0106fdc:	56                   	push   %esi
f0106fdd:	53                   	push   %ebx
f0106fde:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
f0106fe4:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f0106fe6:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f0106fed:	00 
f0106fee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0106ff5:	00 
f0106ff6:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106ff9:	89 04 24             	mov    %eax,(%esp)
f0106ffc:	e8 bd ed ff ff       	call   f0105dbe <memset>
	df.bus = bus;
f0107001:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0107004:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f010700b:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
f0107012:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0107015:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0107018:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
			continue;

		totaldev++;

		struct pci_func f = df;
f010701e:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f0107024:	89 85 00 ff ff ff    	mov    %eax,-0x100(%ebp)
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f010702a:	ba 0c 00 00 00       	mov    $0xc,%edx
f010702f:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0107032:	e8 79 ff ff ff       	call   f0106fb0 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f0107037:	89 c2                	mov    %eax,%edx
f0107039:	c1 ea 10             	shr    $0x10,%edx
f010703c:	83 e2 7f             	and    $0x7f,%edx
f010703f:	83 fa 01             	cmp    $0x1,%edx
f0107042:	0f 87 66 01 00 00    	ja     f01071ae <pci_scan_bus+0x1d6>
			continue;

		totaldev++;
f0107048:	ff 85 f8 fe ff ff    	incl   -0x108(%ebp)

		struct pci_func f = df;
f010704e:	b9 12 00 00 00       	mov    $0x12,%ecx
f0107053:	8b bd 00 ff ff ff    	mov    -0x100(%ebp),%edi
f0107059:	8b b5 04 ff ff ff    	mov    -0xfc(%ebp),%esi
f010705f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0107061:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f0107068:	00 00 00 
f010706b:	25 00 00 80 00       	and    $0x800000,%eax
f0107070:	89 85 fc fe ff ff    	mov    %eax,-0x104(%ebp)
		     f.func++) {
			struct pci_func af = f;
f0107076:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f010707c:	e9 12 01 00 00       	jmp    f0107193 <pci_scan_bus+0x1bb>
		     f.func++) {
			struct pci_func af = f;
f0107081:	b9 12 00 00 00       	mov    $0x12,%ecx
f0107086:	89 df                	mov    %ebx,%edi
f0107088:	8b b5 00 ff ff ff    	mov    -0x100(%ebp),%esi
f010708e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f0107090:	ba 00 00 00 00       	mov    $0x0,%edx
f0107095:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f010709b:	e8 10 ff ff ff       	call   f0106fb0 <pci_conf_read>
f01070a0:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f01070a6:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01070aa:	0f 84 dd 00 00 00    	je     f010718d <pci_scan_bus+0x1b5>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f01070b0:	ba 3c 00 00 00       	mov    $0x3c,%edx
f01070b5:	89 d8                	mov    %ebx,%eax
f01070b7:	e8 f4 fe ff ff       	call   f0106fb0 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f01070bc:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f01070bf:	ba 08 00 00 00       	mov    $0x8,%edx
f01070c4:	89 d8                	mov    %ebx,%eax
f01070c6:	e8 e5 fe ff ff       	call   f0106fb0 <pci_conf_read>
f01070cb:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f01070d1:	89 c2                	mov    %eax,%edx
f01070d3:	c1 ea 18             	shr    $0x18,%edx
f01070d6:	83 fa 06             	cmp    $0x6,%edx
f01070d9:	77 09                	ja     f01070e4 <pci_scan_bus+0x10c>
		class = pci_class[PCI_CLASS(f->dev_class)];
f01070db:	8b 34 95 90 96 10 f0 	mov    -0xfef6970(,%edx,4),%esi
f01070e2:	eb 05                	jmp    f01070e9 <pci_scan_bus+0x111>
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f01070e4:	be 1c 96 10 f0       	mov    $0xf010961c,%esi
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01070e9:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01070ef:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f01070f3:	89 7c 24 24          	mov    %edi,0x24(%esp)
f01070f7:	89 74 24 20          	mov    %esi,0x20(%esp)
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
		PCI_CLASS(f->dev_class), PCI_SUBCLASS(f->dev_class), class,
f01070fb:	c1 e8 10             	shr    $0x10,%eax
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01070fe:	25 ff 00 00 00       	and    $0xff,%eax
f0107103:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0107107:	89 54 24 18          	mov    %edx,0x18(%esp)
f010710b:	89 c8                	mov    %ecx,%eax
f010710d:	c1 e8 10             	shr    $0x10,%eax
f0107110:	89 44 24 14          	mov    %eax,0x14(%esp)
f0107114:	81 e1 ff ff 00 00    	and    $0xffff,%ecx
f010711a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010711e:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
f0107124:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107128:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f010712e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107132:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0107138:	8b 40 04             	mov    0x4(%eax),%eax
f010713b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010713f:	c7 04 24 a8 94 10 f0 	movl   $0xf01094a8,(%esp)
f0107146:	e8 3f cd ff ff       	call   f0103e8a <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f010714b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
f0107151:	89 c2                	mov    %eax,%edx
f0107153:	c1 ea 10             	shr    $0x10,%edx

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0107156:	81 e2 ff 00 00 00    	and    $0xff,%edx
f010715c:	c1 e8 18             	shr    $0x18,%eax
			af.irq_line = PCI_INTERRUPT_LINE(intr);

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
			if (pci_show_devs)
				pci_print_func(&af);
			pci_attach(&af);
f010715f:	89 1c 24             	mov    %ebx,(%esp)

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0107162:	b9 ec c4 12 f0       	mov    $0xf012c4ec,%ecx
f0107167:	e8 e4 fc ff ff       	call   f0106e50 <pci_attach_match>
}

static int
pci_attach(struct pci_func *f)
{
	return
f010716c:	85 c0                	test   %eax,%eax
f010716e:	75 1d                	jne    f010718d <pci_scan_bus+0x1b5>
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f0107170:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0107176:	89 c2                	mov    %eax,%edx
f0107178:	c1 ea 10             	shr    $0x10,%edx
f010717b:	25 ff ff 00 00       	and    $0xffff,%eax
			af.irq_line = PCI_INTERRUPT_LINE(intr);

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
			if (pci_show_devs)
				pci_print_func(&af);
			pci_attach(&af);
f0107180:	89 1c 24             	mov    %ebx,(%esp)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0107183:	b9 d4 c4 12 f0       	mov    $0xf012c4d4,%ecx
f0107188:	e8 c3 fc ff ff       	call   f0106e50 <pci_attach_match>

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f010718d:	ff 85 18 ff ff ff    	incl   -0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0107193:	83 bd fc fe ff ff 01 	cmpl   $0x1,-0x104(%ebp)
f010719a:	19 c0                	sbb    %eax,%eax
f010719c:	83 e0 f9             	and    $0xfffffff9,%eax
f010719f:	83 c0 08             	add    $0x8,%eax
f01071a2:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f01071a8:	0f 87 d3 fe ff ff    	ja     f0107081 <pci_scan_bus+0xa9>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01071ae:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01071b1:	40                   	inc    %eax
f01071b2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01071b5:	83 f8 1f             	cmp    $0x1f,%eax
f01071b8:	0f 86 6c fe ff ff    	jbe    f010702a <pci_scan_bus+0x52>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f01071be:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
f01071c4:	81 c4 2c 01 00 00    	add    $0x12c,%esp
f01071ca:	5b                   	pop    %ebx
f01071cb:	5e                   	pop    %esi
f01071cc:	5f                   	pop    %edi
f01071cd:	5d                   	pop    %ebp
f01071ce:	c3                   	ret    

f01071cf <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f01071cf:	55                   	push   %ebp
f01071d0:	89 e5                	mov    %esp,%ebp
f01071d2:	57                   	push   %edi
f01071d3:	56                   	push   %esi
f01071d4:	53                   	push   %ebx
f01071d5:	83 ec 3c             	sub    $0x3c,%esp
f01071d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f01071db:	ba 1c 00 00 00       	mov    $0x1c,%edx
f01071e0:	89 d8                	mov    %ebx,%eax
f01071e2:	e8 c9 fd ff ff       	call   f0106fb0 <pci_conf_read>
f01071e7:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f01071e9:	ba 18 00 00 00       	mov    $0x18,%edx
f01071ee:	89 d8                	mov    %ebx,%eax
f01071f0:	e8 bb fd ff ff       	call   f0106fb0 <pci_conf_read>
f01071f5:	89 c6                	mov    %eax,%esi

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f01071f7:	83 e7 0f             	and    $0xf,%edi
f01071fa:	83 ff 01             	cmp    $0x1,%edi
f01071fd:	75 2a                	jne    f0107229 <pci_bridge_attach+0x5a>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f01071ff:	8b 43 08             	mov    0x8(%ebx),%eax
f0107202:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107206:	8b 43 04             	mov    0x4(%ebx),%eax
f0107209:	89 44 24 08          	mov    %eax,0x8(%esp)
			pcif->bus->busno, pcif->dev, pcif->func);
f010720d:	8b 03                	mov    (%ebx),%eax
{
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f010720f:	8b 40 04             	mov    0x4(%eax),%eax
f0107212:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107216:	c7 04 24 e4 94 10 f0 	movl   $0xf01094e4,(%esp)
f010721d:	e8 68 cc ff ff       	call   f0103e8a <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f0107222:	b8 00 00 00 00       	mov    $0x0,%eax
f0107227:	eb 66                	jmp    f010728f <pci_bridge_attach+0xc0>
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0107229:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f0107230:	00 
f0107231:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0107238:	00 
f0107239:	8d 7d e0             	lea    -0x20(%ebp),%edi
f010723c:	89 3c 24             	mov    %edi,(%esp)
f010723f:	e8 7a eb ff ff       	call   f0105dbe <memset>
	nbus.parent_bridge = pcif;
f0107244:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0107247:	89 f2                	mov    %esi,%edx
f0107249:	0f b6 c6             	movzbl %dh,%eax
f010724c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);
f010724f:	c1 ee 10             	shr    $0x10,%esi
	memset(&nbus, 0, sizeof(nbus));
	nbus.parent_bridge = pcif;
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0107252:	81 e6 ff 00 00 00    	and    $0xff,%esi
f0107258:	89 74 24 14          	mov    %esi,0x14(%esp)
f010725c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107260:	8b 43 08             	mov    0x8(%ebx),%eax
f0107263:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107267:	8b 43 04             	mov    0x4(%ebx),%eax
f010726a:	89 44 24 08          	mov    %eax,0x8(%esp)
			pcif->bus->busno, pcif->dev, pcif->func,
f010726e:	8b 03                	mov    (%ebx),%eax
	memset(&nbus, 0, sizeof(nbus));
	nbus.parent_bridge = pcif;
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0107270:	8b 40 04             	mov    0x4(%eax),%eax
f0107273:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107277:	c7 04 24 18 95 10 f0 	movl   $0xf0109518,(%esp)
f010727e:	e8 07 cc ff ff       	call   f0103e8a <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f0107283:	89 f8                	mov    %edi,%eax
f0107285:	e8 4e fd ff ff       	call   f0106fd8 <pci_scan_bus>
	return 1;
f010728a:	b8 01 00 00 00       	mov    $0x1,%eax
}
f010728f:	83 c4 3c             	add    $0x3c,%esp
f0107292:	5b                   	pop    %ebx
f0107293:	5e                   	pop    %esi
f0107294:	5f                   	pop    %edi
f0107295:	5d                   	pop    %ebp
f0107296:	c3                   	ret    

f0107297 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f0107297:	55                   	push   %ebp
f0107298:	89 e5                	mov    %esp,%ebp
f010729a:	56                   	push   %esi
f010729b:	53                   	push   %ebx
f010729c:	83 ec 10             	sub    $0x10,%esp
f010729f:	89 ce                	mov    %ecx,%esi
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01072a1:	8b 48 08             	mov    0x8(%eax),%ecx
f01072a4:	8b 58 04             	mov    0x4(%eax),%ebx
f01072a7:	8b 00                	mov    (%eax),%eax
f01072a9:	8b 40 04             	mov    0x4(%eax),%eax
f01072ac:	89 14 24             	mov    %edx,(%esp)
f01072af:	89 da                	mov    %ebx,%edx
f01072b1:	e8 fe fb ff ff       	call   f0106eb4 <pci_conf1_set_addr>
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01072b6:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01072bb:	89 f0                	mov    %esi,%eax
f01072bd:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f01072be:	83 c4 10             	add    $0x10,%esp
f01072c1:	5b                   	pop    %ebx
f01072c2:	5e                   	pop    %esi
f01072c3:	5d                   	pop    %ebp
f01072c4:	c3                   	ret    

f01072c5 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f01072c5:	55                   	push   %ebp
f01072c6:	89 e5                	mov    %esp,%ebp
f01072c8:	57                   	push   %edi
f01072c9:	56                   	push   %esi
f01072ca:	53                   	push   %ebx
f01072cb:	83 ec 4c             	sub    $0x4c,%esp
f01072ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f01072d1:	b9 07 00 00 00       	mov    $0x7,%ecx
f01072d6:	ba 04 00 00 00       	mov    $0x4,%edx
f01072db:	89 d8                	mov    %ebx,%eax
f01072dd:	e8 b5 ff ff ff       	call   f0107297 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f01072e2:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f01072e7:	89 f2                	mov    %esi,%edx
f01072e9:	89 d8                	mov    %ebx,%eax
f01072eb:	e8 c0 fc ff ff       	call   f0106fb0 <pci_conf_read>
f01072f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f01072f3:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f01072f8:	89 f2                	mov    %esi,%edx
f01072fa:	89 d8                	mov    %ebx,%eax
f01072fc:	e8 96 ff ff ff       	call   f0107297 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0107301:	89 f2                	mov    %esi,%edx
f0107303:	89 d8                	mov    %ebx,%eax
f0107305:	e8 a6 fc ff ff       	call   f0106fb0 <pci_conf_read>

		if (rv == 0)
f010730a:	85 c0                	test   %eax,%eax
f010730c:	0f 84 c7 00 00 00    	je     f01073d9 <pci_func_enable+0x114>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0107312:	8d 56 f0             	lea    -0x10(%esi),%edx
f0107315:	c1 ea 02             	shr    $0x2,%edx
f0107318:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f010731b:	a8 01                	test   $0x1,%al
f010731d:	75 2c                	jne    f010734b <pci_func_enable+0x86>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f010731f:	89 c2                	mov    %eax,%edx
f0107321:	83 e2 06             	and    $0x6,%edx
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0107324:	83 fa 04             	cmp    $0x4,%edx
f0107327:	0f 94 c2             	sete   %dl
f010732a:	0f b6 d2             	movzbl %dl,%edx
f010732d:	8d 3c 95 04 00 00 00 	lea    0x4(,%edx,4),%edi
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
				bar_width = 8;

			size = PCI_MAPREG_MEM_SIZE(rv);
f0107334:	83 e0 f0             	and    $0xfffffff0,%eax
f0107337:	89 c2                	mov    %eax,%edx
f0107339:	f7 da                	neg    %edx
f010733b:	21 d0                	and    %edx,%eax
f010733d:	89 45 dc             	mov    %eax,-0x24(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0107340:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107343:	83 e0 f0             	and    $0xfffffff0,%eax
f0107346:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0107349:	eb 1a                	jmp    f0107365 <pci_func_enable+0xa0>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f010734b:	83 e0 fc             	and    $0xfffffffc,%eax
f010734e:	89 c2                	mov    %eax,%edx
f0107350:	f7 da                	neg    %edx
f0107352:	21 d0                	and    %edx,%eax
f0107354:	89 45 dc             	mov    %eax,-0x24(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f0107357:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010735a:	83 e2 fc             	and    $0xfffffffc,%edx
f010735d:	89 55 d8             	mov    %edx,-0x28(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0107360:	bf 04 00 00 00       	mov    $0x4,%edi
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f0107365:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0107368:	89 f2                	mov    %esi,%edx
f010736a:	89 d8                	mov    %ebx,%eax
f010736c:	e8 26 ff ff ff       	call   f0107297 <pci_conf_write>
		f->reg_base[regnum] = base;
f0107371:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107374:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107377:	89 54 83 14          	mov    %edx,0x14(%ebx,%eax,4)
		f->reg_size[regnum] = size;
f010737b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010737e:	89 54 83 2c          	mov    %edx,0x2c(%ebx,%eax,4)

		if (size && !base)
f0107382:	85 d2                	test   %edx,%edx
f0107384:	74 58                	je     f01073de <pci_func_enable+0x119>
f0107386:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010738a:	75 52                	jne    f01073de <pci_func_enable+0x119>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f010738c:	8b 43 0c             	mov    0xc(%ebx),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f010738f:	89 54 24 20          	mov    %edx,0x20(%esp)
f0107393:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
f010739a:	00 
f010739b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010739e:	89 54 24 18          	mov    %edx,0x18(%esp)
f01073a2:	89 c2                	mov    %eax,%edx
f01073a4:	c1 ea 10             	shr    $0x10,%edx
f01073a7:	89 54 24 14          	mov    %edx,0x14(%esp)
f01073ab:	25 ff ff 00 00       	and    $0xffff,%eax
f01073b0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01073b4:	8b 43 08             	mov    0x8(%ebx),%eax
f01073b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01073bb:	8b 43 04             	mov    0x4(%ebx),%eax
f01073be:	89 44 24 08          	mov    %eax,0x8(%esp)
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
f01073c2:	8b 03                	mov    (%ebx),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f01073c4:	8b 40 04             	mov    0x4(%eax),%eax
f01073c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01073cb:	c7 04 24 48 95 10 f0 	movl   $0xf0109548,(%esp)
f01073d2:	e8 b3 ca ff ff       	call   f0103e8a <cprintf>
f01073d7:	eb 05                	jmp    f01073de <pci_func_enable+0x119>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f01073d9:	bf 04 00 00 00       	mov    $0x4,%edi
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f01073de:	01 fe                	add    %edi,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f01073e0:	83 fe 27             	cmp    $0x27,%esi
f01073e3:	0f 86 fe fe ff ff    	jbe    f01072e7 <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f01073e9:	8b 43 0c             	mov    0xc(%ebx),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f01073ec:	89 c2                	mov    %eax,%edx
f01073ee:	c1 ea 10             	shr    $0x10,%edx
f01073f1:	89 54 24 14          	mov    %edx,0x14(%esp)
f01073f5:	25 ff ff 00 00       	and    $0xffff,%eax
f01073fa:	89 44 24 10          	mov    %eax,0x10(%esp)
f01073fe:	8b 43 08             	mov    0x8(%ebx),%eax
f0107401:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107405:	8b 43 04             	mov    0x4(%ebx),%eax
f0107408:	89 44 24 08          	mov    %eax,0x8(%esp)
		f->bus->busno, f->dev, f->func,
f010740c:	8b 03                	mov    (%ebx),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f010740e:	8b 40 04             	mov    0x4(%eax),%eax
f0107411:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107415:	c7 04 24 a4 95 10 f0 	movl   $0xf01095a4,(%esp)
f010741c:	e8 69 ca ff ff       	call   f0103e8a <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0107421:	83 c4 4c             	add    $0x4c,%esp
f0107424:	5b                   	pop    %ebx
f0107425:	5e                   	pop    %esi
f0107426:	5f                   	pop    %edi
f0107427:	5d                   	pop    %ebp
f0107428:	c3                   	ret    

f0107429 <pci_init>:

int
pci_init(void)
{
f0107429:	55                   	push   %ebp
f010742a:	89 e5                	mov    %esp,%ebp
f010742c:	83 ec 18             	sub    $0x18,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f010742f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f0107436:	00 
f0107437:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010743e:	00 
f010743f:	c7 04 24 84 1e 2e f0 	movl   $0xf02e1e84,(%esp)
f0107446:	e8 73 e9 ff ff       	call   f0105dbe <memset>

	return pci_scan_bus(&root_bus);
f010744b:	b8 84 1e 2e f0       	mov    $0xf02e1e84,%eax
f0107450:	e8 83 fb ff ff       	call   f0106fd8 <pci_scan_bus>
}
f0107455:	c9                   	leave  
f0107456:	c3                   	ret    
	...

f0107458 <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f0107458:	55                   	push   %ebp
f0107459:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f010745b:	c7 05 8c 1e 2e f0 00 	movl   $0x0,0xf02e1e8c
f0107462:	00 00 00 
}
f0107465:	5d                   	pop    %ebp
f0107466:	c3                   	ret    

f0107467 <time_tick>:

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f0107467:	55                   	push   %ebp
f0107468:	89 e5                	mov    %esp,%ebp
f010746a:	83 ec 18             	sub    $0x18,%esp
	ticks++;
f010746d:	a1 8c 1e 2e f0       	mov    0xf02e1e8c,%eax
f0107472:	40                   	inc    %eax
f0107473:	a3 8c 1e 2e f0       	mov    %eax,0xf02e1e8c
	if (ticks * 10 < ticks)
f0107478:	8d 14 80             	lea    (%eax,%eax,4),%edx
f010747b:	d1 e2                	shl    %edx
f010747d:	39 d0                	cmp    %edx,%eax
f010747f:	76 1c                	jbe    f010749d <time_tick+0x36>
		panic("time_tick: time overflowed");
f0107481:	c7 44 24 08 ac 96 10 	movl   $0xf01096ac,0x8(%esp)
f0107488:	f0 
f0107489:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
f0107490:	00 
f0107491:	c7 04 24 c7 96 10 f0 	movl   $0xf01096c7,(%esp)
f0107498:	e8 a3 8b ff ff       	call   f0100040 <_panic>
}
f010749d:	c9                   	leave  
f010749e:	c3                   	ret    

f010749f <time_msec>:

unsigned int
time_msec(void)
{
f010749f:	55                   	push   %ebp
f01074a0:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f01074a2:	a1 8c 1e 2e f0       	mov    0xf02e1e8c,%eax
f01074a7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01074aa:	d1 e0                	shl    %eax
}
f01074ac:	5d                   	pop    %ebp
f01074ad:	c3                   	ret    
	...

f01074b0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01074b0:	55                   	push   %ebp
f01074b1:	57                   	push   %edi
f01074b2:	56                   	push   %esi
f01074b3:	83 ec 10             	sub    $0x10,%esp
f01074b6:	8b 74 24 20          	mov    0x20(%esp),%esi
f01074ba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01074be:	89 74 24 04          	mov    %esi,0x4(%esp)
f01074c2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f01074c6:	89 cd                	mov    %ecx,%ebp
f01074c8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01074cc:	85 c0                	test   %eax,%eax
f01074ce:	75 2c                	jne    f01074fc <__udivdi3+0x4c>
    {
      if (d0 > n1)
f01074d0:	39 f9                	cmp    %edi,%ecx
f01074d2:	77 68                	ja     f010753c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01074d4:	85 c9                	test   %ecx,%ecx
f01074d6:	75 0b                	jne    f01074e3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01074d8:	b8 01 00 00 00       	mov    $0x1,%eax
f01074dd:	31 d2                	xor    %edx,%edx
f01074df:	f7 f1                	div    %ecx
f01074e1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01074e3:	31 d2                	xor    %edx,%edx
f01074e5:	89 f8                	mov    %edi,%eax
f01074e7:	f7 f1                	div    %ecx
f01074e9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01074eb:	89 f0                	mov    %esi,%eax
f01074ed:	f7 f1                	div    %ecx
f01074ef:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01074f1:	89 f0                	mov    %esi,%eax
f01074f3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01074f5:	83 c4 10             	add    $0x10,%esp
f01074f8:	5e                   	pop    %esi
f01074f9:	5f                   	pop    %edi
f01074fa:	5d                   	pop    %ebp
f01074fb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01074fc:	39 f8                	cmp    %edi,%eax
f01074fe:	77 2c                	ja     f010752c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0107500:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0107503:	83 f6 1f             	xor    $0x1f,%esi
f0107506:	75 4c                	jne    f0107554 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0107508:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010750a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010750f:	72 0a                	jb     f010751b <__udivdi3+0x6b>
f0107511:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0107515:	0f 87 ad 00 00 00    	ja     f01075c8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010751b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0107520:	89 f0                	mov    %esi,%eax
f0107522:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0107524:	83 c4 10             	add    $0x10,%esp
f0107527:	5e                   	pop    %esi
f0107528:	5f                   	pop    %edi
f0107529:	5d                   	pop    %ebp
f010752a:	c3                   	ret    
f010752b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010752c:	31 ff                	xor    %edi,%edi
f010752e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0107530:	89 f0                	mov    %esi,%eax
f0107532:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0107534:	83 c4 10             	add    $0x10,%esp
f0107537:	5e                   	pop    %esi
f0107538:	5f                   	pop    %edi
f0107539:	5d                   	pop    %ebp
f010753a:	c3                   	ret    
f010753b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010753c:	89 fa                	mov    %edi,%edx
f010753e:	89 f0                	mov    %esi,%eax
f0107540:	f7 f1                	div    %ecx
f0107542:	89 c6                	mov    %eax,%esi
f0107544:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0107546:	89 f0                	mov    %esi,%eax
f0107548:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010754a:	83 c4 10             	add    $0x10,%esp
f010754d:	5e                   	pop    %esi
f010754e:	5f                   	pop    %edi
f010754f:	5d                   	pop    %ebp
f0107550:	c3                   	ret    
f0107551:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0107554:	89 f1                	mov    %esi,%ecx
f0107556:	d3 e0                	shl    %cl,%eax
f0107558:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010755c:	b8 20 00 00 00       	mov    $0x20,%eax
f0107561:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0107563:	89 ea                	mov    %ebp,%edx
f0107565:	88 c1                	mov    %al,%cl
f0107567:	d3 ea                	shr    %cl,%edx
f0107569:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f010756d:	09 ca                	or     %ecx,%edx
f010756f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f0107573:	89 f1                	mov    %esi,%ecx
f0107575:	d3 e5                	shl    %cl,%ebp
f0107577:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f010757b:	89 fd                	mov    %edi,%ebp
f010757d:	88 c1                	mov    %al,%cl
f010757f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f0107581:	89 fa                	mov    %edi,%edx
f0107583:	89 f1                	mov    %esi,%ecx
f0107585:	d3 e2                	shl    %cl,%edx
f0107587:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010758b:	88 c1                	mov    %al,%cl
f010758d:	d3 ef                	shr    %cl,%edi
f010758f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0107591:	89 f8                	mov    %edi,%eax
f0107593:	89 ea                	mov    %ebp,%edx
f0107595:	f7 74 24 08          	divl   0x8(%esp)
f0107599:	89 d1                	mov    %edx,%ecx
f010759b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f010759d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01075a1:	39 d1                	cmp    %edx,%ecx
f01075a3:	72 17                	jb     f01075bc <__udivdi3+0x10c>
f01075a5:	74 09                	je     f01075b0 <__udivdi3+0x100>
f01075a7:	89 fe                	mov    %edi,%esi
f01075a9:	31 ff                	xor    %edi,%edi
f01075ab:	e9 41 ff ff ff       	jmp    f01074f1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01075b0:	8b 54 24 04          	mov    0x4(%esp),%edx
f01075b4:	89 f1                	mov    %esi,%ecx
f01075b6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01075b8:	39 c2                	cmp    %eax,%edx
f01075ba:	73 eb                	jae    f01075a7 <__udivdi3+0xf7>
		{
		  q0--;
f01075bc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01075bf:	31 ff                	xor    %edi,%edi
f01075c1:	e9 2b ff ff ff       	jmp    f01074f1 <__udivdi3+0x41>
f01075c6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01075c8:	31 f6                	xor    %esi,%esi
f01075ca:	e9 22 ff ff ff       	jmp    f01074f1 <__udivdi3+0x41>
	...

f01075d0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01075d0:	55                   	push   %ebp
f01075d1:	57                   	push   %edi
f01075d2:	56                   	push   %esi
f01075d3:	83 ec 20             	sub    $0x20,%esp
f01075d6:	8b 44 24 30          	mov    0x30(%esp),%eax
f01075da:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01075de:	89 44 24 14          	mov    %eax,0x14(%esp)
f01075e2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f01075e6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01075ea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f01075ee:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f01075f0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01075f2:	85 ed                	test   %ebp,%ebp
f01075f4:	75 16                	jne    f010760c <__umoddi3+0x3c>
    {
      if (d0 > n1)
f01075f6:	39 f1                	cmp    %esi,%ecx
f01075f8:	0f 86 a6 00 00 00    	jbe    f01076a4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01075fe:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0107600:	89 d0                	mov    %edx,%eax
f0107602:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0107604:	83 c4 20             	add    $0x20,%esp
f0107607:	5e                   	pop    %esi
f0107608:	5f                   	pop    %edi
f0107609:	5d                   	pop    %ebp
f010760a:	c3                   	ret    
f010760b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010760c:	39 f5                	cmp    %esi,%ebp
f010760e:	0f 87 ac 00 00 00    	ja     f01076c0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0107614:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0107617:	83 f0 1f             	xor    $0x1f,%eax
f010761a:	89 44 24 10          	mov    %eax,0x10(%esp)
f010761e:	0f 84 a8 00 00 00    	je     f01076cc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0107624:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0107628:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010762a:	bf 20 00 00 00       	mov    $0x20,%edi
f010762f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0107633:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0107637:	89 f9                	mov    %edi,%ecx
f0107639:	d3 e8                	shr    %cl,%eax
f010763b:	09 e8                	or     %ebp,%eax
f010763d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0107641:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0107645:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0107649:	d3 e0                	shl    %cl,%eax
f010764b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010764f:	89 f2                	mov    %esi,%edx
f0107651:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0107653:	8b 44 24 14          	mov    0x14(%esp),%eax
f0107657:	d3 e0                	shl    %cl,%eax
f0107659:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010765d:	8b 44 24 14          	mov    0x14(%esp),%eax
f0107661:	89 f9                	mov    %edi,%ecx
f0107663:	d3 e8                	shr    %cl,%eax
f0107665:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0107667:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0107669:	89 f2                	mov    %esi,%edx
f010766b:	f7 74 24 18          	divl   0x18(%esp)
f010766f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0107671:	f7 64 24 0c          	mull   0xc(%esp)
f0107675:	89 c5                	mov    %eax,%ebp
f0107677:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0107679:	39 d6                	cmp    %edx,%esi
f010767b:	72 67                	jb     f01076e4 <__umoddi3+0x114>
f010767d:	74 75                	je     f01076f4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f010767f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0107683:	29 e8                	sub    %ebp,%eax
f0107685:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0107687:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010768b:	d3 e8                	shr    %cl,%eax
f010768d:	89 f2                	mov    %esi,%edx
f010768f:	89 f9                	mov    %edi,%ecx
f0107691:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0107693:	09 d0                	or     %edx,%eax
f0107695:	89 f2                	mov    %esi,%edx
f0107697:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010769b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010769d:	83 c4 20             	add    $0x20,%esp
f01076a0:	5e                   	pop    %esi
f01076a1:	5f                   	pop    %edi
f01076a2:	5d                   	pop    %ebp
f01076a3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01076a4:	85 c9                	test   %ecx,%ecx
f01076a6:	75 0b                	jne    f01076b3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01076a8:	b8 01 00 00 00       	mov    $0x1,%eax
f01076ad:	31 d2                	xor    %edx,%edx
f01076af:	f7 f1                	div    %ecx
f01076b1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01076b3:	89 f0                	mov    %esi,%eax
f01076b5:	31 d2                	xor    %edx,%edx
f01076b7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01076b9:	89 f8                	mov    %edi,%eax
f01076bb:	e9 3e ff ff ff       	jmp    f01075fe <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01076c0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01076c2:	83 c4 20             	add    $0x20,%esp
f01076c5:	5e                   	pop    %esi
f01076c6:	5f                   	pop    %edi
f01076c7:	5d                   	pop    %ebp
f01076c8:	c3                   	ret    
f01076c9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01076cc:	39 f5                	cmp    %esi,%ebp
f01076ce:	72 04                	jb     f01076d4 <__umoddi3+0x104>
f01076d0:	39 f9                	cmp    %edi,%ecx
f01076d2:	77 06                	ja     f01076da <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01076d4:	89 f2                	mov    %esi,%edx
f01076d6:	29 cf                	sub    %ecx,%edi
f01076d8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f01076da:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01076dc:	83 c4 20             	add    $0x20,%esp
f01076df:	5e                   	pop    %esi
f01076e0:	5f                   	pop    %edi
f01076e1:	5d                   	pop    %ebp
f01076e2:	c3                   	ret    
f01076e3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01076e4:	89 d1                	mov    %edx,%ecx
f01076e6:	89 c5                	mov    %eax,%ebp
f01076e8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f01076ec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f01076f0:	eb 8d                	jmp    f010767f <__umoddi3+0xaf>
f01076f2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01076f4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f01076f8:	72 ea                	jb     f01076e4 <__umoddi3+0x114>
f01076fa:	89 f1                	mov    %esi,%ecx
f01076fc:	eb 81                	jmp    f010767f <__umoddi3+0xaf>
