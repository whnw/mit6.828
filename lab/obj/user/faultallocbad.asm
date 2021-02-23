
obj/user/faultallocbad.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 a0 25 80 00 	movl   $0x8025a0,(%esp)
  80004b:	e8 fc 01 00 00       	call   80024c <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 7a 0b 00 00       	call   800be9 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 c0 25 80 	movl   $0x8025c0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 aa 25 80 00 	movl   $0x8025aa,(%esp)
  800092:	e8 bd 00 00 00       	call   800154 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ec 25 80 	movl   $0x8025ec,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 e6 06 00 00       	call   800799 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 e9 0d 00 00       	call   800eb4 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 3d 0a 00 00       	call   800b1c <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 10             	sub    $0x10,%esp
  8000ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f2:	e8 b4 0a 00 00       	call   800bab <sys_getenvid>
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800103:	c1 e0 07             	shl    $0x7,%eax
  800106:	29 d0                	sub    %edx,%eax
  800108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010d:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 f6                	test   %esi,%esi
  800114:	7e 07                	jle    80011d <libmain+0x39>
		binaryname = argv[0];
  800116:	8b 03                	mov    (%ebx),%eax
  800118:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800121:	89 34 24             	mov    %esi,(%esp)
  800124:	e8 90 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800129:	e8 0a 00 00 00       	call   800138 <exit>
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    
  800135:	00 00                	add    %al,(%eax)
	...

00800138 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80013e:	e8 cc 0f 00 00       	call   80110f <close_all>
	sys_env_destroy(0);
  800143:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014a:	e8 0a 0a 00 00       	call   800b59 <sys_env_destroy>
}
  80014f:	c9                   	leave  
  800150:	c3                   	ret    
  800151:	00 00                	add    %al,(%eax)
	...

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800165:	e8 41 0a 00 00       	call   800bab <sys_getenvid>
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800178:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 18 26 80 00 	movl   $0x802618,(%esp)
  800187:	e8 c0 00 00 00       	call   80024c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	8b 45 10             	mov    0x10(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 50 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  80019b:	c7 04 24 88 2a 80 00 	movl   $0x802a88,(%esp)
  8001a2:	e8 a5 00 00 00       	call   80024c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a7:	cc                   	int3   
  8001a8:	eb fd                	jmp    8001a7 <_panic+0x53>
	...

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 14             	sub    $0x14,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	40                   	inc    %eax
  8001c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c7:	75 19                	jne    8001e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d0:	00 
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 40 09 00 00       	call   800b1c <sys_cputs>
		b->idx = 0;
  8001dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e2:	ff 43 04             	incl   0x4(%ebx)
}
  8001e5:	83 c4 14             	add    $0x14,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fb:	00 00 00 
	b.cnt = 0;
  8001fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800205:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	89 44 24 08          	mov    %eax,0x8(%esp)
  800216:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	c7 04 24 ac 01 80 00 	movl   $0x8001ac,(%esp)
  800227:	e8 82 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800232:	89 44 24 04          	mov    %eax,0x4(%esp)
  800236:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	e8 d8 08 00 00       	call   800b1c <sys_cputs>

	return b.cnt;
}
  800244:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800252:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 87 ff ff ff       	call   8001eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800264:	c9                   	leave  
  800265:	c3                   	ret    
	...

00800268 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 3c             	sub    $0x3c,%esp
  800271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800274:	89 d7                	mov    %edx,%edi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800282:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800285:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800288:	85 c0                	test   %eax,%eax
  80028a:	75 08                	jne    800294 <printnum+0x2c>
  80028c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800292:	77 57                	ja     8002eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800294:	89 74 24 10          	mov    %esi,0x10(%esp)
  800298:	4b                   	dec    %ebx
  800299:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80029d:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b3:	00 
  8002b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c1:	e8 82 20 00 00       	call   802348 <__udivdi3>
  8002c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 89 ff ff ff       	call   800268 <printnum>
  8002df:	eb 0f                	jmp    8002f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	89 34 24             	mov    %esi,(%esp)
  8002e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002eb:	4b                   	dec    %ebx
  8002ec:	85 db                	test   %ebx,%ebx
  8002ee:	7f f1                	jg     8002e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800306:	00 
  800307:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	e8 4f 21 00 00       	call   802468 <__umoddi3>
  800319:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031d:	0f be 80 3b 26 80 00 	movsbl 0x80263b(%eax),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032a:	83 c4 3c             	add    $0x3c,%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800335:	83 fa 01             	cmp    $0x1,%edx
  800338:	7e 0e                	jle    800348 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 02                	mov    (%edx),%eax
  800343:	8b 52 04             	mov    0x4(%edx),%edx
  800346:	eb 22                	jmp    80036a <getuint+0x38>
	else if (lflag)
  800348:	85 d2                	test   %edx,%edx
  80034a:	74 10                	je     80035c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 02                	mov    (%edx),%eax
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	eb 0e                	jmp    80036a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800372:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800375:	8b 10                	mov    (%eax),%edx
  800377:	3b 50 04             	cmp    0x4(%eax),%edx
  80037a:	73 08                	jae    800384 <sprintputch+0x18>
		*b->buf++ = ch;
  80037c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037f:	88 0a                	mov    %cl,(%edx)
  800381:	42                   	inc    %edx
  800382:	89 10                	mov    %edx,(%eax)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800393:	8b 45 10             	mov    0x10(%ebp),%eax
  800396:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	e8 02 00 00 00       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 4c             	sub    $0x4c,%esp
  8003b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8003bd:	eb 12                	jmp    8003d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003bf:	85 c0                	test   %eax,%eax
  8003c1:	0f 84 6b 03 00 00    	je     800732 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d1:	0f b6 06             	movzbl (%esi),%eax
  8003d4:	46                   	inc    %esi
  8003d5:	83 f8 25             	cmp    $0x25,%eax
  8003d8:	75 e5                	jne    8003bf <vprintfmt+0x11>
  8003da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f6:	eb 26                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ff:	eb 1d                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800404:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800408:	eb 14                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80040d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800414:	eb 08                	jmp    80041e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800416:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800419:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	0f b6 06             	movzbl (%esi),%eax
  800421:	8d 56 01             	lea    0x1(%esi),%edx
  800424:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800427:	8a 16                	mov    (%esi),%dl
  800429:	83 ea 23             	sub    $0x23,%edx
  80042c:	80 fa 55             	cmp    $0x55,%dl
  80042f:	0f 87 e1 02 00 00    	ja     800716 <vprintfmt+0x368>
  800435:	0f b6 d2             	movzbl %dl,%edx
  800438:	ff 24 95 80 27 80 00 	jmp    *0x802780(,%edx,4)
  80043f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800442:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800447:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80044e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800451:	8d 50 d0             	lea    -0x30(%eax),%edx
  800454:	83 fa 09             	cmp    $0x9,%edx
  800457:	77 2a                	ja     800483 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800459:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045a:	eb eb                	jmp    800447 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046a:	eb 17                	jmp    800483 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80046c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800470:	78 98                	js     80040a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800475:	eb a7                	jmp    80041e <vprintfmt+0x70>
  800477:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800481:	eb 9b                	jmp    80041e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800483:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800487:	79 95                	jns    80041e <vprintfmt+0x70>
  800489:	eb 8b                	jmp    800416 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048f:	eb 8d                	jmp    80041e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a9:	e9 23 ff ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	79 02                	jns    8004bf <vprintfmt+0x111>
  8004bd:	f7 d8                	neg    %eax
  8004bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c1:	83 f8 10             	cmp    $0x10,%eax
  8004c4:	7f 0b                	jg     8004d1 <vprintfmt+0x123>
  8004c6:	8b 04 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	75 23                	jne    8004f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d5:	c7 44 24 08 53 26 80 	movl   $0x802653,0x8(%esp)
  8004dc:	00 
  8004dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	e8 9a fe ff ff       	call   800386 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ef:	e9 dd fe ff ff       	jmp    8003d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f8:	c7 44 24 08 1d 2a 80 	movl   $0x802a1d,0x8(%esp)
  8004ff:	00 
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	8b 55 08             	mov    0x8(%ebp),%edx
  800507:	89 14 24             	mov    %edx,(%esp)
  80050a:	e8 77 fe ff ff       	call   800386 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800512:	e9 ba fe ff ff       	jmp    8003d1 <vprintfmt+0x23>
  800517:	89 f9                	mov    %edi,%ecx
  800519:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	8b 30                	mov    (%eax),%esi
  80052a:	85 f6                	test   %esi,%esi
  80052c:	75 05                	jne    800533 <vprintfmt+0x185>
				p = "(null)";
  80052e:	be 4c 26 80 00       	mov    $0x80264c,%esi
			if (width > 0 && padc != '-')
  800533:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800537:	0f 8e 84 00 00 00    	jle    8005c1 <vprintfmt+0x213>
  80053d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800541:	74 7e                	je     8005c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800547:	89 34 24             	mov    %esi,(%esp)
  80054a:	e8 8b 02 00 00       	call   8007da <strnlen>
  80054f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800552:	29 c2                	sub    %eax,%edx
  800554:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800557:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80055b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80055e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800561:	89 de                	mov    %ebx,%esi
  800563:	89 d3                	mov    %edx,%ebx
  800565:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	eb 0b                	jmp    800574 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800569:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056d:	89 3c 24             	mov    %edi,(%esp)
  800570:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	4b                   	dec    %ebx
  800574:	85 db                	test   %ebx,%ebx
  800576:	7f f1                	jg     800569 <vprintfmt+0x1bb>
  800578:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057b:	89 f3                	mov    %esi,%ebx
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	79 05                	jns    80058c <vprintfmt+0x1de>
  800587:	b8 00 00 00 00       	mov    $0x0,%eax
  80058c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058f:	29 c2                	sub    %eax,%edx
  800591:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800594:	eb 2b                	jmp    8005c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059a:	74 18                	je     8005b4 <vprintfmt+0x206>
  80059c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80059f:	83 fa 5e             	cmp    $0x5e,%edx
  8005a2:	76 10                	jbe    8005b4 <vprintfmt+0x206>
					putch('?', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	eb 0a                	jmp    8005be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c1:	0f be 06             	movsbl (%esi),%eax
  8005c4:	46                   	inc    %esi
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	74 21                	je     8005ea <vprintfmt+0x23c>
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	78 c9                	js     800596 <vprintfmt+0x1e8>
  8005cd:	4f                   	dec    %edi
  8005ce:	79 c6                	jns    800596 <vprintfmt+0x1e8>
  8005d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d3:	89 de                	mov    %ebx,%esi
  8005d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d8:	eb 18                	jmp    8005f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e7:	4b                   	dec    %ebx
  8005e8:	eb 08                	jmp    8005f2 <vprintfmt+0x244>
  8005ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ed:	89 de                	mov    %ebx,%esi
  8005ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	7f e4                	jg     8005da <vprintfmt+0x22c>
  8005f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005fe:	e9 ce fd ff ff       	jmp    8003d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800603:	83 f9 01             	cmp    $0x1,%ecx
  800606:	7e 10                	jle    800618 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 08             	lea    0x8(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 30                	mov    (%eax),%esi
  800613:	8b 78 04             	mov    0x4(%eax),%edi
  800616:	eb 26                	jmp    80063e <vprintfmt+0x290>
	else if (lflag)
  800618:	85 c9                	test   %ecx,%ecx
  80061a:	74 12                	je     80062e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 30                	mov    (%eax),%esi
  800627:	89 f7                	mov    %esi,%edi
  800629:	c1 ff 1f             	sar    $0x1f,%edi
  80062c:	eb 10                	jmp    80063e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 30                	mov    (%eax),%esi
  800639:	89 f7                	mov    %esi,%edi
  80063b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063e:	85 ff                	test   %edi,%edi
  800640:	78 0a                	js     80064c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 8c 00 00 00       	jmp    8006d8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065a:	f7 de                	neg    %esi
  80065c:	83 d7 00             	adc    $0x0,%edi
  80065f:	f7 df                	neg    %edi
			}
			base = 10;
  800661:	b8 0a 00 00 00       	mov    $0xa,%eax
  800666:	eb 70                	jmp    8006d8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800668:	89 ca                	mov    %ecx,%edx
  80066a:	8d 45 14             	lea    0x14(%ebp),%eax
  80066d:	e8 c0 fc ff ff       	call   800332 <getuint>
  800672:	89 c6                	mov    %eax,%esi
  800674:	89 d7                	mov    %edx,%edi
			base = 10;
  800676:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067b:	eb 5b                	jmp    8006d8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  80067d:	89 ca                	mov    %ecx,%edx
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 ab fc ff ff       	call   800332 <getuint>
  800687:	89 c6                	mov    %eax,%esi
  800689:	89 d7                	mov    %edx,%edi
			base = 8;
  80068b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800690:	eb 46                	jmp    8006d8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800692:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800696:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b7:	8b 30                	mov    (%eax),%esi
  8006b9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c3:	eb 13                	jmp    8006d8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c5:	89 ca                	mov    %ecx,%edx
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ca:	e8 63 fc ff ff       	call   800332 <getuint>
  8006cf:	89 c6                	mov    %eax,%esi
  8006d1:	89 d7                	mov    %edx,%edi
			base = 16;
  8006d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006eb:	89 34 24             	mov    %esi,(%esp)
  8006ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f2:	89 da                	mov    %ebx,%edx
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	e8 6c fb ff ff       	call   800268 <printnum>
			break;
  8006fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ff:	e9 cd fc ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	89 04 24             	mov    %eax,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800711:	e9 bb fc ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800716:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800721:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800724:	eb 01                	jmp    800727 <vprintfmt+0x379>
  800726:	4e                   	dec    %esi
  800727:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80072b:	75 f9                	jne    800726 <vprintfmt+0x378>
  80072d:	e9 9f fc ff ff       	jmp    8003d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800732:	83 c4 4c             	add    $0x4c,%esp
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	5f                   	pop    %edi
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 28             	sub    $0x28,%esp
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800746:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800749:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800757:	85 c0                	test   %eax,%eax
  800759:	74 30                	je     80078b <vsnprintf+0x51>
  80075b:	85 d2                	test   %edx,%edx
  80075d:	7e 33                	jle    800792 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800766:	8b 45 10             	mov    0x10(%ebp),%eax
  800769:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800770:	89 44 24 04          	mov    %eax,0x4(%esp)
  800774:	c7 04 24 6c 03 80 00 	movl   $0x80036c,(%esp)
  80077b:	e8 2e fc ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800780:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800783:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800789:	eb 0c                	jmp    800797 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800790:	eb 05                	jmp    800797 <vsnprintf+0x5d>
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 7b ff ff ff       	call   80073a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    
  8007c1:	00 00                	add    %al,(%eax)
	...

008007c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cf:	eb 01                	jmp    8007d2 <strlen+0xe>
		n++;
  8007d1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d6:	75 f9                	jne    8007d1 <strlen+0xd>
		n++;
	return n;
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e8:	eb 01                	jmp    8007eb <strnlen+0x11>
		n++;
  8007ea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	39 d0                	cmp    %edx,%eax
  8007ed:	74 06                	je     8007f5 <strnlen+0x1b>
  8007ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f3:	75 f5                	jne    8007ea <strnlen+0x10>
		n++;
	return n;
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800801:	ba 00 00 00 00       	mov    $0x0,%edx
  800806:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800809:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80080c:	42                   	inc    %edx
  80080d:	84 c9                	test   %cl,%cl
  80080f:	75 f5                	jne    800806 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800811:	5b                   	pop    %ebx
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081e:	89 1c 24             	mov    %ebx,(%esp)
  800821:	e8 9e ff ff ff       	call   8007c4 <strlen>
	strcpy(dst + len, src);
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
  800829:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082d:	01 d8                	add    %ebx,%eax
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	e8 c0 ff ff ff       	call   8007f7 <strcpy>
	return dst;
}
  800837:	89 d8                	mov    %ebx,%eax
  800839:	83 c4 08             	add    $0x8,%esp
  80083c:	5b                   	pop    %ebx
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800852:	eb 0c                	jmp    800860 <strncpy+0x21>
		*dst++ = *src;
  800854:	8a 1a                	mov    (%edx),%bl
  800856:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800859:	80 3a 01             	cmpb   $0x1,(%edx)
  80085c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085f:	41                   	inc    %ecx
  800860:	39 f1                	cmp    %esi,%ecx
  800862:	75 f0                	jne    800854 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 75 08             	mov    0x8(%ebp),%esi
  800870:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800873:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800876:	85 d2                	test   %edx,%edx
  800878:	75 0a                	jne    800884 <strlcpy+0x1c>
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	eb 1a                	jmp    800898 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087e:	88 18                	mov    %bl,(%eax)
  800880:	40                   	inc    %eax
  800881:	41                   	inc    %ecx
  800882:	eb 02                	jmp    800886 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800884:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800886:	4a                   	dec    %edx
  800887:	74 0a                	je     800893 <strlcpy+0x2b>
  800889:	8a 19                	mov    (%ecx),%bl
  80088b:	84 db                	test   %bl,%bl
  80088d:	75 ef                	jne    80087e <strlcpy+0x16>
  80088f:	89 c2                	mov    %eax,%edx
  800891:	eb 02                	jmp    800895 <strlcpy+0x2d>
  800893:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800895:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800898:	29 f0                	sub    %esi,%eax
}
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a7:	eb 02                	jmp    8008ab <strcmp+0xd>
		p++, q++;
  8008a9:	41                   	inc    %ecx
  8008aa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ab:	8a 01                	mov    (%ecx),%al
  8008ad:	84 c0                	test   %al,%al
  8008af:	74 04                	je     8008b5 <strcmp+0x17>
  8008b1:	3a 02                	cmp    (%edx),%al
  8008b3:	74 f4                	je     8008a9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b5:	0f b6 c0             	movzbl %al,%eax
  8008b8:	0f b6 12             	movzbl (%edx),%edx
  8008bb:	29 d0                	sub    %edx,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008cc:	eb 03                	jmp    8008d1 <strncmp+0x12>
		n--, p++, q++;
  8008ce:	4a                   	dec    %edx
  8008cf:	40                   	inc    %eax
  8008d0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	74 14                	je     8008e9 <strncmp+0x2a>
  8008d5:	8a 18                	mov    (%eax),%bl
  8008d7:	84 db                	test   %bl,%bl
  8008d9:	74 04                	je     8008df <strncmp+0x20>
  8008db:	3a 19                	cmp    (%ecx),%bl
  8008dd:	74 ef                	je     8008ce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 00             	movzbl (%eax),%eax
  8008e2:	0f b6 11             	movzbl (%ecx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
  8008e7:	eb 05                	jmp    8008ee <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fa:	eb 05                	jmp    800901 <strchr+0x10>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	74 0c                	je     80090c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800900:	40                   	inc    %eax
  800901:	8a 10                	mov    (%eax),%dl
  800903:	84 d2                	test   %dl,%dl
  800905:	75 f5                	jne    8008fc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800917:	eb 05                	jmp    80091e <strfind+0x10>
		if (*s == c)
  800919:	38 ca                	cmp    %cl,%dl
  80091b:	74 07                	je     800924 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80091d:	40                   	inc    %eax
  80091e:	8a 10                	mov    (%eax),%dl
  800920:	84 d2                	test   %dl,%dl
  800922:	75 f5                	jne    800919 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 30                	je     800969 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800939:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093f:	75 25                	jne    800966 <memset+0x40>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 20                	jne    800966 <memset+0x40>
		c &= 0xFF;
  800946:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800949:	89 d3                	mov    %edx,%ebx
  80094b:	c1 e3 08             	shl    $0x8,%ebx
  80094e:	89 d6                	mov    %edx,%esi
  800950:	c1 e6 18             	shl    $0x18,%esi
  800953:	89 d0                	mov    %edx,%eax
  800955:	c1 e0 10             	shl    $0x10,%eax
  800958:	09 f0                	or     %esi,%eax
  80095a:	09 d0                	or     %edx,%eax
  80095c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800961:	fc                   	cld    
  800962:	f3 ab                	rep stos %eax,%es:(%edi)
  800964:	eb 03                	jmp    800969 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800966:	fc                   	cld    
  800967:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800969:	89 f8                	mov    %edi,%eax
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097e:	39 c6                	cmp    %eax,%esi
  800980:	73 34                	jae    8009b6 <memmove+0x46>
  800982:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800985:	39 d0                	cmp    %edx,%eax
  800987:	73 2d                	jae    8009b6 <memmove+0x46>
		s += n;
		d += n;
  800989:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	f6 c2 03             	test   $0x3,%dl
  80098f:	75 1b                	jne    8009ac <memmove+0x3c>
  800991:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800997:	75 13                	jne    8009ac <memmove+0x3c>
  800999:	f6 c1 03             	test   $0x3,%cl
  80099c:	75 0e                	jne    8009ac <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099e:	83 ef 04             	sub    $0x4,%edi
  8009a1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009a7:	fd                   	std    
  8009a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009aa:	eb 07                	jmp    8009b3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ac:	4f                   	dec    %edi
  8009ad:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b0:	fd                   	std    
  8009b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b3:	fc                   	cld    
  8009b4:	eb 20                	jmp    8009d6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bc:	75 13                	jne    8009d1 <memmove+0x61>
  8009be:	a8 03                	test   $0x3,%al
  8009c0:	75 0f                	jne    8009d1 <memmove+0x61>
  8009c2:	f6 c1 03             	test   $0x3,%cl
  8009c5:	75 0a                	jne    8009d1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ca:	89 c7                	mov    %eax,%edi
  8009cc:	fc                   	cld    
  8009cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cf:	eb 05                	jmp    8009d6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	fc                   	cld    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	89 04 24             	mov    %eax,(%esp)
  8009f4:	e8 77 ff ff ff       	call   800970 <memmove>
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0f:	eb 16                	jmp    800a27 <memcmp+0x2c>
		if (*s1 != *s2)
  800a11:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a14:	42                   	inc    %edx
  800a15:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a19:	38 c8                	cmp    %cl,%al
  800a1b:	74 0a                	je     800a27 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a1d:	0f b6 c0             	movzbl %al,%eax
  800a20:	0f b6 c9             	movzbl %cl,%ecx
  800a23:	29 c8                	sub    %ecx,%eax
  800a25:	eb 09                	jmp    800a30 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	39 da                	cmp    %ebx,%edx
  800a29:	75 e6                	jne    800a11 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3e:	89 c2                	mov    %eax,%edx
  800a40:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a43:	eb 05                	jmp    800a4a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a45:	38 08                	cmp    %cl,(%eax)
  800a47:	74 05                	je     800a4e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a49:	40                   	inc    %eax
  800a4a:	39 d0                	cmp    %edx,%eax
  800a4c:	72 f7                	jb     800a45 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 55 08             	mov    0x8(%ebp),%edx
  800a59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5c:	eb 01                	jmp    800a5f <strtol+0xf>
		s++;
  800a5e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	8a 02                	mov    (%edx),%al
  800a61:	3c 20                	cmp    $0x20,%al
  800a63:	74 f9                	je     800a5e <strtol+0xe>
  800a65:	3c 09                	cmp    $0x9,%al
  800a67:	74 f5                	je     800a5e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a69:	3c 2b                	cmp    $0x2b,%al
  800a6b:	75 08                	jne    800a75 <strtol+0x25>
		s++;
  800a6d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a73:	eb 13                	jmp    800a88 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a75:	3c 2d                	cmp    $0x2d,%al
  800a77:	75 0a                	jne    800a83 <strtol+0x33>
		s++, neg = 1;
  800a79:	8d 52 01             	lea    0x1(%edx),%edx
  800a7c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a81:	eb 05                	jmp    800a88 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a88:	85 db                	test   %ebx,%ebx
  800a8a:	74 05                	je     800a91 <strtol+0x41>
  800a8c:	83 fb 10             	cmp    $0x10,%ebx
  800a8f:	75 28                	jne    800ab9 <strtol+0x69>
  800a91:	8a 02                	mov    (%edx),%al
  800a93:	3c 30                	cmp    $0x30,%al
  800a95:	75 10                	jne    800aa7 <strtol+0x57>
  800a97:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9b:	75 0a                	jne    800aa7 <strtol+0x57>
		s += 2, base = 16;
  800a9d:	83 c2 02             	add    $0x2,%edx
  800aa0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa5:	eb 12                	jmp    800ab9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aa7:	85 db                	test   %ebx,%ebx
  800aa9:	75 0e                	jne    800ab9 <strtol+0x69>
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 05                	jne    800ab4 <strtol+0x64>
		s++, base = 8;
  800aaf:	42                   	inc    %edx
  800ab0:	b3 08                	mov    $0x8,%bl
  800ab2:	eb 05                	jmp    800ab9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  800abe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac0:	8a 0a                	mov    (%edx),%cl
  800ac2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac5:	80 fb 09             	cmp    $0x9,%bl
  800ac8:	77 08                	ja     800ad2 <strtol+0x82>
			dig = *s - '0';
  800aca:	0f be c9             	movsbl %cl,%ecx
  800acd:	83 e9 30             	sub    $0x30,%ecx
  800ad0:	eb 1e                	jmp    800af0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 08                	ja     800ae2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ada:	0f be c9             	movsbl %cl,%ecx
  800add:	83 e9 57             	sub    $0x57,%ecx
  800ae0:	eb 0e                	jmp    800af0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 12                	ja     800afc <strtol+0xac>
			dig = *s - 'A' + 10;
  800aea:	0f be c9             	movsbl %cl,%ecx
  800aed:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af0:	39 f1                	cmp    %esi,%ecx
  800af2:	7d 0c                	jge    800b00 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af4:	42                   	inc    %edx
  800af5:	0f af c6             	imul   %esi,%eax
  800af8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800afa:	eb c4                	jmp    800ac0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800afc:	89 c1                	mov    %eax,%ecx
  800afe:	eb 02                	jmp    800b02 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b00:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b06:	74 05                	je     800b0d <strtol+0xbd>
		*endptr = (char *) s;
  800b08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b0d:	85 ff                	test   %edi,%edi
  800b0f:	74 04                	je     800b15 <strtol+0xc5>
  800b11:	89 c8                	mov    %ecx,%eax
  800b13:	f7 d8                	neg    %eax
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    
	...

00800b1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	b8 00 00 00 00       	mov    $0x0,%eax
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	89 c3                	mov    %eax,%ebx
  800b2f:	89 c7                	mov    %eax,%edi
  800b31:	89 c6                	mov    %eax,%esi
  800b33:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4a:	89 d1                	mov    %edx,%ecx
  800b4c:	89 d3                	mov    %edx,%ebx
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b67:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	89 cb                	mov    %ecx,%ebx
  800b71:	89 cf                	mov    %ecx,%edi
  800b73:	89 ce                	mov    %ecx,%esi
  800b75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 28                	jle    800ba3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b7f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b86:	00 
  800b87:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  800b8e:	00 
  800b8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b96:	00 
  800b97:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800b9e:	e8 b1 f5 ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba3:	83 c4 2c             	add    $0x2c,%esp
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbb:	89 d1                	mov    %edx,%ecx
  800bbd:	89 d3                	mov    %edx,%ebx
  800bbf:	89 d7                	mov    %edx,%edi
  800bc1:	89 d6                	mov    %edx,%esi
  800bc3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <sys_yield>:

void
sys_yield(void)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf2:	be 00 00 00 00       	mov    $0x0,%esi
  800bf7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 f7                	mov    %esi,%edi
  800c07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7e 28                	jle    800c35 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c11:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c18:	00 
  800c19:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  800c20:	00 
  800c21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c28:	00 
  800c29:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800c30:	e8 1f f5 ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c35:	83 c4 2c             	add    $0x2c,%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 28                	jle    800c88 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c64:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c6b:	00 
  800c6c:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  800c73:	00 
  800c74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7b:	00 
  800c7c:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800c83:	e8 cc f4 ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c88:	83 c4 2c             	add    $0x2c,%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 df                	mov    %ebx,%edi
  800cab:	89 de                	mov    %ebx,%esi
  800cad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7e 28                	jle    800cdb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  800cc6:	00 
  800cc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cce:	00 
  800ccf:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800cd6:	e8 79 f4 ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdb:	83 c4 2c             	add    $0x2c,%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	89 df                	mov    %ebx,%edi
  800cfe:	89 de                	mov    %ebx,%esi
  800d00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7e 28                	jle    800d2e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d11:	00 
  800d12:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  800d19:	00 
  800d1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d21:	00 
  800d22:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800d29:	e8 26 f4 ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d2e:	83 c4 2c             	add    $0x2c,%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d44:	b8 09 00 00 00       	mov    $0x9,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	89 df                	mov    %ebx,%edi
  800d51:	89 de                	mov    %ebx,%esi
  800d53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 28                	jle    800d81 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d64:	00 
  800d65:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  800d6c:	00 
  800d6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d74:	00 
  800d75:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800d7c:	e8 d3 f3 ff ff       	call   800154 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d81:	83 c4 2c             	add    $0x2c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	89 df                	mov    %ebx,%edi
  800da4:	89 de                	mov    %ebx,%esi
  800da6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 28                	jle    800dd4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800db7:	00 
  800db8:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc7:	00 
  800dc8:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800dcf:	e8 80 f3 ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd4:	83 c4 2c             	add    $0x2c,%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	be 00 00 00 00       	mov    $0x0,%esi
  800de7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800def:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 cb                	mov    %ecx,%ebx
  800e17:	89 cf                	mov    %ecx,%edi
  800e19:	89 ce                	mov    %ecx,%esi
  800e1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	7e 28                	jle    800e49 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e25:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  800e34:	00 
  800e35:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3c:	00 
  800e3d:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800e44:	e8 0b f3 ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e49:	83 c4 2c             	add    $0x2c,%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e57:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e61:	89 d1                	mov    %edx,%ecx
  800e63:	89 d3                	mov    %edx,%ebx
  800e65:	89 d7                	mov    %edx,%edi
  800e67:	89 d6                	mov    %edx,%esi
  800e69:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e6b:	5b                   	pop    %ebx
  800e6c:	5e                   	pop    %esi
  800e6d:	5f                   	pop    %edi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e83:	8b 55 08             	mov    0x8(%ebp),%edx
  800e86:	89 df                	mov    %ebx,%edi
  800e88:	89 de                	mov    %ebx,%esi
  800e8a:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 10 00 00 00       	mov    $0x10,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
	...

00800eb4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800eba:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800ec1:	75 30                	jne    800ef3 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  800ec3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800eca:	00 
  800ecb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800ed2:	ee 
  800ed3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eda:	e8 0a fd ff ff       	call   800be9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  800edf:	c7 44 24 04 00 0f 80 	movl   $0x800f00,0x4(%esp)
  800ee6:	00 
  800ee7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eee:	e8 96 fe ff ff       	call   800d89 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    
  800efd:	00 00                	add    %al,(%eax)
	...

00800f00 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f00:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f01:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800f06:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f08:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  800f0b:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  800f0f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  800f13:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  800f16:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  800f18:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  800f1c:	83 c4 08             	add    $0x8,%esp
	popal
  800f1f:	61                   	popa   

	addl $4,%esp 
  800f20:	83 c4 04             	add    $0x4,%esp
	popfl
  800f23:	9d                   	popf   

	popl %esp
  800f24:	5c                   	pop    %esp

	ret
  800f25:	c3                   	ret    
	...

00800f28 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2e:	05 00 00 00 30       	add    $0x30000000,%eax
  800f33:	c1 e8 0c             	shr    $0xc,%eax
}
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	89 04 24             	mov    %eax,(%esp)
  800f44:	e8 df ff ff ff       	call   800f28 <fd2num>
  800f49:	c1 e0 0c             	shl    $0xc,%eax
  800f4c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	53                   	push   %ebx
  800f57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f5a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f5f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f61:	89 c2                	mov    %eax,%edx
  800f63:	c1 ea 16             	shr    $0x16,%edx
  800f66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6d:	f6 c2 01             	test   $0x1,%dl
  800f70:	74 11                	je     800f83 <fd_alloc+0x30>
  800f72:	89 c2                	mov    %eax,%edx
  800f74:	c1 ea 0c             	shr    $0xc,%edx
  800f77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7e:	f6 c2 01             	test   $0x1,%dl
  800f81:	75 09                	jne    800f8c <fd_alloc+0x39>
			*fd_store = fd;
  800f83:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8a:	eb 17                	jmp    800fa3 <fd_alloc+0x50>
  800f8c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f91:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f96:	75 c7                	jne    800f5f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f98:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f9e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fa3:	5b                   	pop    %ebx
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fac:	83 f8 1f             	cmp    $0x1f,%eax
  800faf:	77 36                	ja     800fe7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb1:	c1 e0 0c             	shl    $0xc,%eax
  800fb4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb9:	89 c2                	mov    %eax,%edx
  800fbb:	c1 ea 16             	shr    $0x16,%edx
  800fbe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc5:	f6 c2 01             	test   $0x1,%dl
  800fc8:	74 24                	je     800fee <fd_lookup+0x48>
  800fca:	89 c2                	mov    %eax,%edx
  800fcc:	c1 ea 0c             	shr    $0xc,%edx
  800fcf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd6:	f6 c2 01             	test   $0x1,%dl
  800fd9:	74 1a                	je     800ff5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fde:	89 02                	mov    %eax,(%edx)
	return 0;
  800fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe5:	eb 13                	jmp    800ffa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fec:	eb 0c                	jmp    800ffa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff3:	eb 05                	jmp    800ffa <fd_lookup+0x54>
  800ff5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	53                   	push   %ebx
  801000:	83 ec 14             	sub    $0x14,%esp
  801003:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801006:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801009:	ba 00 00 00 00       	mov    $0x0,%edx
  80100e:	eb 0e                	jmp    80101e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801010:	39 08                	cmp    %ecx,(%eax)
  801012:	75 09                	jne    80101d <dev_lookup+0x21>
			*dev = devtab[i];
  801014:	89 03                	mov    %eax,(%ebx)
			return 0;
  801016:	b8 00 00 00 00       	mov    $0x0,%eax
  80101b:	eb 33                	jmp    801050 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80101d:	42                   	inc    %edx
  80101e:	8b 04 95 f0 29 80 00 	mov    0x8029f0(,%edx,4),%eax
  801025:	85 c0                	test   %eax,%eax
  801027:	75 e7                	jne    801010 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801029:	a1 08 40 80 00       	mov    0x804008,%eax
  80102e:	8b 40 48             	mov    0x48(%eax),%eax
  801031:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801035:	89 44 24 04          	mov    %eax,0x4(%esp)
  801039:	c7 04 24 70 29 80 00 	movl   $0x802970,(%esp)
  801040:	e8 07 f2 ff ff       	call   80024c <cprintf>
	*dev = 0;
  801045:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80104b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801050:	83 c4 14             	add    $0x14,%esp
  801053:	5b                   	pop    %ebx
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
  80105b:	83 ec 30             	sub    $0x30,%esp
  80105e:	8b 75 08             	mov    0x8(%ebp),%esi
  801061:	8a 45 0c             	mov    0xc(%ebp),%al
  801064:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801067:	89 34 24             	mov    %esi,(%esp)
  80106a:	e8 b9 fe ff ff       	call   800f28 <fd2num>
  80106f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801072:	89 54 24 04          	mov    %edx,0x4(%esp)
  801076:	89 04 24             	mov    %eax,(%esp)
  801079:	e8 28 ff ff ff       	call   800fa6 <fd_lookup>
  80107e:	89 c3                	mov    %eax,%ebx
  801080:	85 c0                	test   %eax,%eax
  801082:	78 05                	js     801089 <fd_close+0x33>
	    || fd != fd2)
  801084:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801087:	74 0d                	je     801096 <fd_close+0x40>
		return (must_exist ? r : 0);
  801089:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80108d:	75 46                	jne    8010d5 <fd_close+0x7f>
  80108f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801094:	eb 3f                	jmp    8010d5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801096:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109d:	8b 06                	mov    (%esi),%eax
  80109f:	89 04 24             	mov    %eax,(%esp)
  8010a2:	e8 55 ff ff ff       	call   800ffc <dev_lookup>
  8010a7:	89 c3                	mov    %eax,%ebx
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 18                	js     8010c5 <fd_close+0x6f>
		if (dev->dev_close)
  8010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b0:	8b 40 10             	mov    0x10(%eax),%eax
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	74 09                	je     8010c0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010b7:	89 34 24             	mov    %esi,(%esp)
  8010ba:	ff d0                	call   *%eax
  8010bc:	89 c3                	mov    %eax,%ebx
  8010be:	eb 05                	jmp    8010c5 <fd_close+0x6f>
		else
			r = 0;
  8010c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d0:	e8 bb fb ff ff       	call   800c90 <sys_page_unmap>
	return r;
}
  8010d5:	89 d8                	mov    %ebx,%eax
  8010d7:	83 c4 30             	add    $0x30,%esp
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	89 04 24             	mov    %eax,(%esp)
  8010f1:	e8 b0 fe ff ff       	call   800fa6 <fd_lookup>
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	78 13                	js     80110d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801101:	00 
  801102:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801105:	89 04 24             	mov    %eax,(%esp)
  801108:	e8 49 ff ff ff       	call   801056 <fd_close>
}
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <close_all>:

void
close_all(void)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	53                   	push   %ebx
  801113:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801116:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80111b:	89 1c 24             	mov    %ebx,(%esp)
  80111e:	e8 bb ff ff ff       	call   8010de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801123:	43                   	inc    %ebx
  801124:	83 fb 20             	cmp    $0x20,%ebx
  801127:	75 f2                	jne    80111b <close_all+0xc>
		close(i);
}
  801129:	83 c4 14             	add    $0x14,%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	57                   	push   %edi
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 4c             	sub    $0x4c,%esp
  801138:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80113b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80113e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	89 04 24             	mov    %eax,(%esp)
  801148:	e8 59 fe ff ff       	call   800fa6 <fd_lookup>
  80114d:	89 c3                	mov    %eax,%ebx
  80114f:	85 c0                	test   %eax,%eax
  801151:	0f 88 e3 00 00 00    	js     80123a <dup+0x10b>
		return r;
	close(newfdnum);
  801157:	89 3c 24             	mov    %edi,(%esp)
  80115a:	e8 7f ff ff ff       	call   8010de <close>

	newfd = INDEX2FD(newfdnum);
  80115f:	89 fe                	mov    %edi,%esi
  801161:	c1 e6 0c             	shl    $0xc,%esi
  801164:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80116a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80116d:	89 04 24             	mov    %eax,(%esp)
  801170:	e8 c3 fd ff ff       	call   800f38 <fd2data>
  801175:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801177:	89 34 24             	mov    %esi,(%esp)
  80117a:	e8 b9 fd ff ff       	call   800f38 <fd2data>
  80117f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801182:	89 d8                	mov    %ebx,%eax
  801184:	c1 e8 16             	shr    $0x16,%eax
  801187:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80118e:	a8 01                	test   $0x1,%al
  801190:	74 46                	je     8011d8 <dup+0xa9>
  801192:	89 d8                	mov    %ebx,%eax
  801194:	c1 e8 0c             	shr    $0xc,%eax
  801197:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 35                	je     8011d8 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8011af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c1:	00 
  8011c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011cd:	e8 6b fa ff ff       	call   800c3d <sys_page_map>
  8011d2:	89 c3                	mov    %eax,%ebx
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 3b                	js     801213 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	c1 ea 0c             	shr    $0xc,%edx
  8011e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011f1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011fc:	00 
  8011fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801201:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801208:	e8 30 fa ff ff       	call   800c3d <sys_page_map>
  80120d:	89 c3                	mov    %eax,%ebx
  80120f:	85 c0                	test   %eax,%eax
  801211:	79 25                	jns    801238 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801213:	89 74 24 04          	mov    %esi,0x4(%esp)
  801217:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121e:	e8 6d fa ff ff       	call   800c90 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801223:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801231:	e8 5a fa ff ff       	call   800c90 <sys_page_unmap>
	return r;
  801236:	eb 02                	jmp    80123a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801238:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80123a:	89 d8                	mov    %ebx,%eax
  80123c:	83 c4 4c             	add    $0x4c,%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5f                   	pop    %edi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	53                   	push   %ebx
  801248:	83 ec 24             	sub    $0x24,%esp
  80124b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801251:	89 44 24 04          	mov    %eax,0x4(%esp)
  801255:	89 1c 24             	mov    %ebx,(%esp)
  801258:	e8 49 fd ff ff       	call   800fa6 <fd_lookup>
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 6d                	js     8012ce <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801264:	89 44 24 04          	mov    %eax,0x4(%esp)
  801268:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126b:	8b 00                	mov    (%eax),%eax
  80126d:	89 04 24             	mov    %eax,(%esp)
  801270:	e8 87 fd ff ff       	call   800ffc <dev_lookup>
  801275:	85 c0                	test   %eax,%eax
  801277:	78 55                	js     8012ce <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	8b 50 08             	mov    0x8(%eax),%edx
  80127f:	83 e2 03             	and    $0x3,%edx
  801282:	83 fa 01             	cmp    $0x1,%edx
  801285:	75 23                	jne    8012aa <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801287:	a1 08 40 80 00       	mov    0x804008,%eax
  80128c:	8b 40 48             	mov    0x48(%eax),%eax
  80128f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801293:	89 44 24 04          	mov    %eax,0x4(%esp)
  801297:	c7 04 24 b4 29 80 00 	movl   $0x8029b4,(%esp)
  80129e:	e8 a9 ef ff ff       	call   80024c <cprintf>
		return -E_INVAL;
  8012a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a8:	eb 24                	jmp    8012ce <read+0x8a>
	}
	if (!dev->dev_read)
  8012aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ad:	8b 52 08             	mov    0x8(%edx),%edx
  8012b0:	85 d2                	test   %edx,%edx
  8012b2:	74 15                	je     8012c9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012c2:	89 04 24             	mov    %eax,(%esp)
  8012c5:	ff d2                	call   *%edx
  8012c7:	eb 05                	jmp    8012ce <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012ce:	83 c4 24             	add    $0x24,%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 1c             	sub    $0x1c,%esp
  8012dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012e0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e8:	eb 23                	jmp    80130d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ea:	89 f0                	mov    %esi,%eax
  8012ec:	29 d8                	sub    %ebx,%eax
  8012ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f5:	01 d8                	add    %ebx,%eax
  8012f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fb:	89 3c 24             	mov    %edi,(%esp)
  8012fe:	e8 41 ff ff ff       	call   801244 <read>
		if (m < 0)
  801303:	85 c0                	test   %eax,%eax
  801305:	78 10                	js     801317 <readn+0x43>
			return m;
		if (m == 0)
  801307:	85 c0                	test   %eax,%eax
  801309:	74 0a                	je     801315 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80130b:	01 c3                	add    %eax,%ebx
  80130d:	39 f3                	cmp    %esi,%ebx
  80130f:	72 d9                	jb     8012ea <readn+0x16>
  801311:	89 d8                	mov    %ebx,%eax
  801313:	eb 02                	jmp    801317 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801315:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801317:	83 c4 1c             	add    $0x1c,%esp
  80131a:	5b                   	pop    %ebx
  80131b:	5e                   	pop    %esi
  80131c:	5f                   	pop    %edi
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    

0080131f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	53                   	push   %ebx
  801323:	83 ec 24             	sub    $0x24,%esp
  801326:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801329:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801330:	89 1c 24             	mov    %ebx,(%esp)
  801333:	e8 6e fc ff ff       	call   800fa6 <fd_lookup>
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 68                	js     8013a4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801346:	8b 00                	mov    (%eax),%eax
  801348:	89 04 24             	mov    %eax,(%esp)
  80134b:	e8 ac fc ff ff       	call   800ffc <dev_lookup>
  801350:	85 c0                	test   %eax,%eax
  801352:	78 50                	js     8013a4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801357:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80135b:	75 23                	jne    801380 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80135d:	a1 08 40 80 00       	mov    0x804008,%eax
  801362:	8b 40 48             	mov    0x48(%eax),%eax
  801365:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136d:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  801374:	e8 d3 ee ff ff       	call   80024c <cprintf>
		return -E_INVAL;
  801379:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137e:	eb 24                	jmp    8013a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801380:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801383:	8b 52 0c             	mov    0xc(%edx),%edx
  801386:	85 d2                	test   %edx,%edx
  801388:	74 15                	je     80139f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80138a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80138d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801391:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801394:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801398:	89 04 24             	mov    %eax,(%esp)
  80139b:	ff d2                	call   *%edx
  80139d:	eb 05                	jmp    8013a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80139f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013a4:	83 c4 24             	add    $0x24,%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	e8 e4 fb ff ff       	call   800fa6 <fd_lookup>
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 0e                	js     8013d4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 24             	sub    $0x24,%esp
  8013dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e7:	89 1c 24             	mov    %ebx,(%esp)
  8013ea:	e8 b7 fb ff ff       	call   800fa6 <fd_lookup>
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 61                	js     801454 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fd:	8b 00                	mov    (%eax),%eax
  8013ff:	89 04 24             	mov    %eax,(%esp)
  801402:	e8 f5 fb ff ff       	call   800ffc <dev_lookup>
  801407:	85 c0                	test   %eax,%eax
  801409:	78 49                	js     801454 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801412:	75 23                	jne    801437 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801414:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801419:	8b 40 48             	mov    0x48(%eax),%eax
  80141c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801420:	89 44 24 04          	mov    %eax,0x4(%esp)
  801424:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  80142b:	e8 1c ee ff ff       	call   80024c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801435:	eb 1d                	jmp    801454 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801437:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80143a:	8b 52 18             	mov    0x18(%edx),%edx
  80143d:	85 d2                	test   %edx,%edx
  80143f:	74 0e                	je     80144f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801441:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801444:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801448:	89 04 24             	mov    %eax,(%esp)
  80144b:	ff d2                	call   *%edx
  80144d:	eb 05                	jmp    801454 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80144f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801454:	83 c4 24             	add    $0x24,%esp
  801457:	5b                   	pop    %ebx
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 24             	sub    $0x24,%esp
  801461:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801464:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146b:	8b 45 08             	mov    0x8(%ebp),%eax
  80146e:	89 04 24             	mov    %eax,(%esp)
  801471:	e8 30 fb ff ff       	call   800fa6 <fd_lookup>
  801476:	85 c0                	test   %eax,%eax
  801478:	78 52                	js     8014cc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801481:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801484:	8b 00                	mov    (%eax),%eax
  801486:	89 04 24             	mov    %eax,(%esp)
  801489:	e8 6e fb ff ff       	call   800ffc <dev_lookup>
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 3a                	js     8014cc <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801495:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801499:	74 2c                	je     8014c7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80149b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80149e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014a5:	00 00 00 
	stat->st_isdir = 0;
  8014a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014af:	00 00 00 
	stat->st_dev = dev;
  8014b2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014bf:	89 14 24             	mov    %edx,(%esp)
  8014c2:	ff 50 14             	call   *0x14(%eax)
  8014c5:	eb 05                	jmp    8014cc <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014cc:	83 c4 24             	add    $0x24,%esp
  8014cf:	5b                   	pop    %ebx
  8014d0:	5d                   	pop    %ebp
  8014d1:	c3                   	ret    

008014d2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	56                   	push   %esi
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014e1:	00 
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e5:	89 04 24             	mov    %eax,(%esp)
  8014e8:	e8 2a 02 00 00       	call   801717 <open>
  8014ed:	89 c3                	mov    %eax,%ebx
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 1b                	js     80150e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fa:	89 1c 24             	mov    %ebx,(%esp)
  8014fd:	e8 58 ff ff ff       	call   80145a <fstat>
  801502:	89 c6                	mov    %eax,%esi
	close(fd);
  801504:	89 1c 24             	mov    %ebx,(%esp)
  801507:	e8 d2 fb ff ff       	call   8010de <close>
	return r;
  80150c:	89 f3                	mov    %esi,%ebx
}
  80150e:	89 d8                	mov    %ebx,%eax
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	5b                   	pop    %ebx
  801514:	5e                   	pop    %esi
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    
	...

00801518 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	56                   	push   %esi
  80151c:	53                   	push   %ebx
  80151d:	83 ec 10             	sub    $0x10,%esp
  801520:	89 c3                	mov    %eax,%ebx
  801522:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801524:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80152b:	75 11                	jne    80153e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80152d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801534:	e8 86 0d 00 00       	call   8022bf <ipc_find_env>
  801539:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80153e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801545:	00 
  801546:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80154d:	00 
  80154e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801552:	a1 00 40 80 00       	mov    0x804000,%eax
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 dd 0c 00 00       	call   80223c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80155f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801566:	00 
  801567:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801572:	e8 55 0c 00 00       	call   8021cc <ipc_recv>
}
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801584:	8b 45 08             	mov    0x8(%ebp),%eax
  801587:	8b 40 0c             	mov    0xc(%eax),%eax
  80158a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80158f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801592:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801597:	ba 00 00 00 00       	mov    $0x0,%edx
  80159c:	b8 02 00 00 00       	mov    $0x2,%eax
  8015a1:	e8 72 ff ff ff       	call   801518 <fsipc>
}
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015be:	b8 06 00 00 00       	mov    $0x6,%eax
  8015c3:	e8 50 ff ff ff       	call   801518 <fsipc>
}
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 14             	sub    $0x14,%esp
  8015d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015da:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015df:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8015e9:	e8 2a ff ff ff       	call   801518 <fsipc>
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 2b                	js     80161d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015f2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015f9:	00 
  8015fa:	89 1c 24             	mov    %ebx,(%esp)
  8015fd:	e8 f5 f1 ff ff       	call   8007f7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801602:	a1 80 50 80 00       	mov    0x805080,%eax
  801607:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80160d:	a1 84 50 80 00       	mov    0x805084,%eax
  801612:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801618:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161d:	83 c4 14             	add    $0x14,%esp
  801620:	5b                   	pop    %ebx
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	83 ec 18             	sub    $0x18,%esp
  801629:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80162c:	8b 55 08             	mov    0x8(%ebp),%edx
  80162f:	8b 52 0c             	mov    0xc(%edx),%edx
  801632:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801638:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801644:	76 05                	jbe    80164b <devfile_write+0x28>
  801646:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  80164b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80164f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801652:	89 44 24 04          	mov    %eax,0x4(%esp)
  801656:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80165d:	e8 78 f3 ff ff       	call   8009da <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801662:	ba 00 00 00 00       	mov    $0x0,%edx
  801667:	b8 04 00 00 00       	mov    $0x4,%eax
  80166c:	e8 a7 fe ff ff       	call   801518 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	56                   	push   %esi
  801677:	53                   	push   %ebx
  801678:	83 ec 10             	sub    $0x10,%esp
  80167b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80167e:	8b 45 08             	mov    0x8(%ebp),%eax
  801681:	8b 40 0c             	mov    0xc(%eax),%eax
  801684:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801689:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80168f:	ba 00 00 00 00       	mov    $0x0,%edx
  801694:	b8 03 00 00 00       	mov    $0x3,%eax
  801699:	e8 7a fe ff ff       	call   801518 <fsipc>
  80169e:	89 c3                	mov    %eax,%ebx
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 6a                	js     80170e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016a4:	39 c6                	cmp    %eax,%esi
  8016a6:	73 24                	jae    8016cc <devfile_read+0x59>
  8016a8:	c7 44 24 0c 04 2a 80 	movl   $0x802a04,0xc(%esp)
  8016af:	00 
  8016b0:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  8016b7:	00 
  8016b8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016bf:	00 
  8016c0:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  8016c7:	e8 88 ea ff ff       	call   800154 <_panic>
	assert(r <= PGSIZE);
  8016cc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016d1:	7e 24                	jle    8016f7 <devfile_read+0x84>
  8016d3:	c7 44 24 0c 2b 2a 80 	movl   $0x802a2b,0xc(%esp)
  8016da:	00 
  8016db:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  8016e2:	00 
  8016e3:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016ea:	00 
  8016eb:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  8016f2:	e8 5d ea ff ff       	call   800154 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016fb:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801702:	00 
  801703:	8b 45 0c             	mov    0xc(%ebp),%eax
  801706:	89 04 24             	mov    %eax,(%esp)
  801709:	e8 62 f2 ff ff       	call   800970 <memmove>
	return r;
}
  80170e:	89 d8                	mov    %ebx,%eax
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
  80171c:	83 ec 20             	sub    $0x20,%esp
  80171f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801722:	89 34 24             	mov    %esi,(%esp)
  801725:	e8 9a f0 ff ff       	call   8007c4 <strlen>
  80172a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80172f:	7f 60                	jg     801791 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	89 04 24             	mov    %eax,(%esp)
  801737:	e8 17 f8 ff ff       	call   800f53 <fd_alloc>
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 54                	js     801796 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801742:	89 74 24 04          	mov    %esi,0x4(%esp)
  801746:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80174d:	e8 a5 f0 ff ff       	call   8007f7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801752:	8b 45 0c             	mov    0xc(%ebp),%eax
  801755:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80175a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80175d:	b8 01 00 00 00       	mov    $0x1,%eax
  801762:	e8 b1 fd ff ff       	call   801518 <fsipc>
  801767:	89 c3                	mov    %eax,%ebx
  801769:	85 c0                	test   %eax,%eax
  80176b:	79 15                	jns    801782 <open+0x6b>
		fd_close(fd, 0);
  80176d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801774:	00 
  801775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801778:	89 04 24             	mov    %eax,(%esp)
  80177b:	e8 d6 f8 ff ff       	call   801056 <fd_close>
		return r;
  801780:	eb 14                	jmp    801796 <open+0x7f>
	}

	return fd2num(fd);
  801782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801785:	89 04 24             	mov    %eax,(%esp)
  801788:	e8 9b f7 ff ff       	call   800f28 <fd2num>
  80178d:	89 c3                	mov    %eax,%ebx
  80178f:	eb 05                	jmp    801796 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801791:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801796:	89 d8                	mov    %ebx,%eax
  801798:	83 c4 20             	add    $0x20,%esp
  80179b:	5b                   	pop    %ebx
  80179c:	5e                   	pop    %esi
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8017af:	e8 64 fd ff ff       	call   801518 <fsipc>
}
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    
	...

008017b8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8017be:	c7 44 24 04 37 2a 80 	movl   $0x802a37,0x4(%esp)
  8017c5:	00 
  8017c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c9:	89 04 24             	mov    %eax,(%esp)
  8017cc:	e8 26 f0 ff ff       	call   8007f7 <strcpy>
	return 0;
}
  8017d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d6:	c9                   	leave  
  8017d7:	c3                   	ret    

008017d8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 14             	sub    $0x14,%esp
  8017df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8017e2:	89 1c 24             	mov    %ebx,(%esp)
  8017e5:	e8 1a 0b 00 00       	call   802304 <pageref>
  8017ea:	83 f8 01             	cmp    $0x1,%eax
  8017ed:	75 0d                	jne    8017fc <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8017ef:	8b 43 0c             	mov    0xc(%ebx),%eax
  8017f2:	89 04 24             	mov    %eax,(%esp)
  8017f5:	e8 1f 03 00 00       	call   801b19 <nsipc_close>
  8017fa:	eb 05                	jmp    801801 <devsock_close+0x29>
	else
		return 0;
  8017fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801801:	83 c4 14             	add    $0x14,%esp
  801804:	5b                   	pop    %ebx
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80180d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801814:	00 
  801815:	8b 45 10             	mov    0x10(%ebp),%eax
  801818:	89 44 24 08          	mov    %eax,0x8(%esp)
  80181c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	8b 40 0c             	mov    0xc(%eax),%eax
  801829:	89 04 24             	mov    %eax,(%esp)
  80182c:	e8 e3 03 00 00       	call   801c14 <nsipc_send>
}
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801839:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801840:	00 
  801841:	8b 45 10             	mov    0x10(%ebp),%eax
  801844:	89 44 24 08          	mov    %eax,0x8(%esp)
  801848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	8b 40 0c             	mov    0xc(%eax),%eax
  801855:	89 04 24             	mov    %eax,(%esp)
  801858:	e8 37 03 00 00       	call   801b94 <nsipc_recv>
}
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	83 ec 20             	sub    $0x20,%esp
  801867:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801869:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186c:	89 04 24             	mov    %eax,(%esp)
  80186f:	e8 df f6 ff ff       	call   800f53 <fd_alloc>
  801874:	89 c3                	mov    %eax,%ebx
  801876:	85 c0                	test   %eax,%eax
  801878:	78 21                	js     80189b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80187a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801881:	00 
  801882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801885:	89 44 24 04          	mov    %eax,0x4(%esp)
  801889:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801890:	e8 54 f3 ff ff       	call   800be9 <sys_page_alloc>
  801895:	89 c3                	mov    %eax,%ebx
  801897:	85 c0                	test   %eax,%eax
  801899:	79 0a                	jns    8018a5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80189b:	89 34 24             	mov    %esi,(%esp)
  80189e:	e8 76 02 00 00       	call   801b19 <nsipc_close>
		return r;
  8018a3:	eb 22                	jmp    8018c7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8018a5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ae:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8018ba:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8018bd:	89 04 24             	mov    %eax,(%esp)
  8018c0:	e8 63 f6 ff ff       	call   800f28 <fd2num>
  8018c5:	89 c3                	mov    %eax,%ebx
}
  8018c7:	89 d8                	mov    %ebx,%eax
  8018c9:	83 c4 20             	add    $0x20,%esp
  8018cc:	5b                   	pop    %ebx
  8018cd:	5e                   	pop    %esi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018d6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018dd:	89 04 24             	mov    %eax,(%esp)
  8018e0:	e8 c1 f6 ff ff       	call   800fa6 <fd_lookup>
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	78 17                	js     801900 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f2:	39 10                	cmp    %edx,(%eax)
  8018f4:	75 05                	jne    8018fb <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f9:	eb 05                	jmp    801900 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	e8 c0 ff ff ff       	call   8018d0 <fd2sockid>
  801910:	85 c0                	test   %eax,%eax
  801912:	78 1f                	js     801933 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801914:	8b 55 10             	mov    0x10(%ebp),%edx
  801917:	89 54 24 08          	mov    %edx,0x8(%esp)
  80191b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801922:	89 04 24             	mov    %eax,(%esp)
  801925:	e8 38 01 00 00       	call   801a62 <nsipc_accept>
  80192a:	85 c0                	test   %eax,%eax
  80192c:	78 05                	js     801933 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80192e:	e8 2c ff ff ff       	call   80185f <alloc_sockfd>
}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80193b:	8b 45 08             	mov    0x8(%ebp),%eax
  80193e:	e8 8d ff ff ff       	call   8018d0 <fd2sockid>
  801943:	85 c0                	test   %eax,%eax
  801945:	78 16                	js     80195d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801947:	8b 55 10             	mov    0x10(%ebp),%edx
  80194a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80194e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801951:	89 54 24 04          	mov    %edx,0x4(%esp)
  801955:	89 04 24             	mov    %eax,(%esp)
  801958:	e8 5b 01 00 00       	call   801ab8 <nsipc_bind>
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <shutdown>:

int
shutdown(int s, int how)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801965:	8b 45 08             	mov    0x8(%ebp),%eax
  801968:	e8 63 ff ff ff       	call   8018d0 <fd2sockid>
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 0f                	js     801980 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801971:	8b 55 0c             	mov    0xc(%ebp),%edx
  801974:	89 54 24 04          	mov    %edx,0x4(%esp)
  801978:	89 04 24             	mov    %eax,(%esp)
  80197b:	e8 77 01 00 00       	call   801af7 <nsipc_shutdown>
}
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801988:	8b 45 08             	mov    0x8(%ebp),%eax
  80198b:	e8 40 ff ff ff       	call   8018d0 <fd2sockid>
  801990:	85 c0                	test   %eax,%eax
  801992:	78 16                	js     8019aa <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801994:	8b 55 10             	mov    0x10(%ebp),%edx
  801997:	89 54 24 08          	mov    %edx,0x8(%esp)
  80199b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80199e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019a2:	89 04 24             	mov    %eax,(%esp)
  8019a5:	e8 89 01 00 00       	call   801b33 <nsipc_connect>
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <listen>:

int
listen(int s, int backlog)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b5:	e8 16 ff ff ff       	call   8018d0 <fd2sockid>
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 0f                	js     8019cd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8019be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019c5:	89 04 24             	mov    %eax,(%esp)
  8019c8:	e8 a5 01 00 00       	call   801b72 <nsipc_listen>
}
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	89 04 24             	mov    %eax,(%esp)
  8019e9:	e8 99 02 00 00       	call   801c87 <nsipc_socket>
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 05                	js     8019f7 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8019f2:	e8 68 fe ff ff       	call   80185f <alloc_sockfd>
}
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    
  8019f9:	00 00                	add    %al,(%eax)
	...

008019fc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 14             	sub    $0x14,%esp
  801a03:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a05:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a0c:	75 11                	jne    801a1f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a0e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801a15:	e8 a5 08 00 00       	call   8022bf <ipc_find_env>
  801a1a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a1f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a26:	00 
  801a27:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a2e:	00 
  801a2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a33:	a1 04 40 80 00       	mov    0x804004,%eax
  801a38:	89 04 24             	mov    %eax,(%esp)
  801a3b:	e8 fc 07 00 00       	call   80223c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a40:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a47:	00 
  801a48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a4f:	00 
  801a50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a57:	e8 70 07 00 00       	call   8021cc <ipc_recv>
}
  801a5c:	83 c4 14             	add    $0x14,%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	83 ec 10             	sub    $0x10,%esp
  801a6a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a70:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a75:	8b 06                	mov    (%esi),%eax
  801a77:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a81:	e8 76 ff ff ff       	call   8019fc <nsipc>
  801a86:	89 c3                	mov    %eax,%ebx
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 23                	js     801aaf <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a8c:	a1 10 60 80 00       	mov    0x806010,%eax
  801a91:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a95:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a9c:	00 
  801a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa0:	89 04 24             	mov    %eax,(%esp)
  801aa3:	e8 c8 ee ff ff       	call   800970 <memmove>
		*addrlen = ret->ret_addrlen;
  801aa8:	a1 10 60 80 00       	mov    0x806010,%eax
  801aad:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801aaf:	89 d8                	mov    %ebx,%eax
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	53                   	push   %ebx
  801abc:	83 ec 14             	sub    $0x14,%esp
  801abf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801aca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad5:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801adc:	e8 8f ee ff ff       	call   800970 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ae1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ae7:	b8 02 00 00 00       	mov    $0x2,%eax
  801aec:	e8 0b ff ff ff       	call   8019fc <nsipc>
}
  801af1:	83 c4 14             	add    $0x14,%esp
  801af4:	5b                   	pop    %ebx
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801afd:	8b 45 08             	mov    0x8(%ebp),%eax
  801b00:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b08:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b0d:	b8 03 00 00 00       	mov    $0x3,%eax
  801b12:	e8 e5 fe ff ff       	call   8019fc <nsipc>
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <nsipc_close>:

int
nsipc_close(int s)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b27:	b8 04 00 00 00       	mov    $0x4,%eax
  801b2c:	e8 cb fe ff ff       	call   8019fc <nsipc>
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	53                   	push   %ebx
  801b37:	83 ec 14             	sub    $0x14,%esp
  801b3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b40:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b45:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b50:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801b57:	e8 14 ee ff ff       	call   800970 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b5c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b62:	b8 05 00 00 00       	mov    $0x5,%eax
  801b67:	e8 90 fe ff ff       	call   8019fc <nsipc>
}
  801b6c:	83 c4 14             	add    $0x14,%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b83:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b88:	b8 06 00 00 00       	mov    $0x6,%eax
  801b8d:	e8 6a fe ff ff       	call   8019fc <nsipc>
}
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	83 ec 10             	sub    $0x10,%esp
  801b9c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ba7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bad:	8b 45 14             	mov    0x14(%ebp),%eax
  801bb0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bb5:	b8 07 00 00 00       	mov    $0x7,%eax
  801bba:	e8 3d fe ff ff       	call   8019fc <nsipc>
  801bbf:	89 c3                	mov    %eax,%ebx
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	78 46                	js     801c0b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801bc5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bca:	7f 04                	jg     801bd0 <nsipc_recv+0x3c>
  801bcc:	39 c6                	cmp    %eax,%esi
  801bce:	7d 24                	jge    801bf4 <nsipc_recv+0x60>
  801bd0:	c7 44 24 0c 43 2a 80 	movl   $0x802a43,0xc(%esp)
  801bd7:	00 
  801bd8:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  801bdf:	00 
  801be0:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801be7:	00 
  801be8:	c7 04 24 58 2a 80 00 	movl   $0x802a58,(%esp)
  801bef:	e8 60 e5 ff ff       	call   800154 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bf4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf8:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bff:	00 
  801c00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c03:	89 04 24             	mov    %eax,(%esp)
  801c06:	e8 65 ed ff ff       	call   800970 <memmove>
	}

	return r;
}
  801c0b:	89 d8                	mov    %ebx,%eax
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	5b                   	pop    %ebx
  801c11:	5e                   	pop    %esi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	53                   	push   %ebx
  801c18:	83 ec 14             	sub    $0x14,%esp
  801c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c26:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c2c:	7e 24                	jle    801c52 <nsipc_send+0x3e>
  801c2e:	c7 44 24 0c 64 2a 80 	movl   $0x802a64,0xc(%esp)
  801c35:	00 
  801c36:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  801c3d:	00 
  801c3e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801c45:	00 
  801c46:	c7 04 24 58 2a 80 00 	movl   $0x802a58,(%esp)
  801c4d:	e8 02 e5 ff ff       	call   800154 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801c64:	e8 07 ed ff ff       	call   800970 <memmove>
	nsipcbuf.send.req_size = size;
  801c69:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c6f:	8b 45 14             	mov    0x14(%ebp),%eax
  801c72:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c77:	b8 08 00 00 00       	mov    $0x8,%eax
  801c7c:	e8 7b fd ff ff       	call   8019fc <nsipc>
}
  801c81:	83 c4 14             	add    $0x14,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c98:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ca5:	b8 09 00 00 00       	mov    $0x9,%eax
  801caa:	e8 4d fd ff ff       	call   8019fc <nsipc>
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    
  801cb1:	00 00                	add    %al,(%eax)
	...

00801cb4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	56                   	push   %esi
  801cb8:	53                   	push   %ebx
  801cb9:	83 ec 10             	sub    $0x10,%esp
  801cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	89 04 24             	mov    %eax,(%esp)
  801cc5:	e8 6e f2 ff ff       	call   800f38 <fd2data>
  801cca:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ccc:	c7 44 24 04 70 2a 80 	movl   $0x802a70,0x4(%esp)
  801cd3:	00 
  801cd4:	89 34 24             	mov    %esi,(%esp)
  801cd7:	e8 1b eb ff ff       	call   8007f7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cdc:	8b 43 04             	mov    0x4(%ebx),%eax
  801cdf:	2b 03                	sub    (%ebx),%eax
  801ce1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ce7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801cee:	00 00 00 
	stat->st_dev = &devpipe;
  801cf1:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801cf8:	30 80 00 
	return 0;
}
  801cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 14             	sub    $0x14,%esp
  801d0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d11:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d1c:	e8 6f ef ff ff       	call   800c90 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d21:	89 1c 24             	mov    %ebx,(%esp)
  801d24:	e8 0f f2 ff ff       	call   800f38 <fd2data>
  801d29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d34:	e8 57 ef ff ff       	call   800c90 <sys_page_unmap>
}
  801d39:	83 c4 14             	add    $0x14,%esp
  801d3c:	5b                   	pop    %ebx
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    

00801d3f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	57                   	push   %edi
  801d43:	56                   	push   %esi
  801d44:	53                   	push   %ebx
  801d45:	83 ec 2c             	sub    $0x2c,%esp
  801d48:	89 c7                	mov    %eax,%edi
  801d4a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d4d:	a1 08 40 80 00       	mov    0x804008,%eax
  801d52:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d55:	89 3c 24             	mov    %edi,(%esp)
  801d58:	e8 a7 05 00 00       	call   802304 <pageref>
  801d5d:	89 c6                	mov    %eax,%esi
  801d5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d62:	89 04 24             	mov    %eax,(%esp)
  801d65:	e8 9a 05 00 00       	call   802304 <pageref>
  801d6a:	39 c6                	cmp    %eax,%esi
  801d6c:	0f 94 c0             	sete   %al
  801d6f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d72:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d78:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d7b:	39 cb                	cmp    %ecx,%ebx
  801d7d:	75 08                	jne    801d87 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d7f:	83 c4 2c             	add    $0x2c,%esp
  801d82:	5b                   	pop    %ebx
  801d83:	5e                   	pop    %esi
  801d84:	5f                   	pop    %edi
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d87:	83 f8 01             	cmp    $0x1,%eax
  801d8a:	75 c1                	jne    801d4d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d8c:	8b 42 58             	mov    0x58(%edx),%eax
  801d8f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d96:	00 
  801d97:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d9f:	c7 04 24 77 2a 80 00 	movl   $0x802a77,(%esp)
  801da6:	e8 a1 e4 ff ff       	call   80024c <cprintf>
  801dab:	eb a0                	jmp    801d4d <_pipeisclosed+0xe>

00801dad <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	57                   	push   %edi
  801db1:	56                   	push   %esi
  801db2:	53                   	push   %ebx
  801db3:	83 ec 1c             	sub    $0x1c,%esp
  801db6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801db9:	89 34 24             	mov    %esi,(%esp)
  801dbc:	e8 77 f1 ff ff       	call   800f38 <fd2data>
  801dc1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc3:	bf 00 00 00 00       	mov    $0x0,%edi
  801dc8:	eb 3c                	jmp    801e06 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dca:	89 da                	mov    %ebx,%edx
  801dcc:	89 f0                	mov    %esi,%eax
  801dce:	e8 6c ff ff ff       	call   801d3f <_pipeisclosed>
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	75 38                	jne    801e0f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dd7:	e8 ee ed ff ff       	call   800bca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ddc:	8b 43 04             	mov    0x4(%ebx),%eax
  801ddf:	8b 13                	mov    (%ebx),%edx
  801de1:	83 c2 20             	add    $0x20,%edx
  801de4:	39 d0                	cmp    %edx,%eax
  801de6:	73 e2                	jae    801dca <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801de8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801deb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801dee:	89 c2                	mov    %eax,%edx
  801df0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801df6:	79 05                	jns    801dfd <devpipe_write+0x50>
  801df8:	4a                   	dec    %edx
  801df9:	83 ca e0             	or     $0xffffffe0,%edx
  801dfc:	42                   	inc    %edx
  801dfd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e01:	40                   	inc    %eax
  801e02:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e05:	47                   	inc    %edi
  801e06:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e09:	75 d1                	jne    801ddc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e0b:	89 f8                	mov    %edi,%eax
  801e0d:	eb 05                	jmp    801e14 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e14:	83 c4 1c             	add    $0x1c,%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5f                   	pop    %edi
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    

00801e1c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	57                   	push   %edi
  801e20:	56                   	push   %esi
  801e21:	53                   	push   %ebx
  801e22:	83 ec 1c             	sub    $0x1c,%esp
  801e25:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e28:	89 3c 24             	mov    %edi,(%esp)
  801e2b:	e8 08 f1 ff ff       	call   800f38 <fd2data>
  801e30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e32:	be 00 00 00 00       	mov    $0x0,%esi
  801e37:	eb 3a                	jmp    801e73 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e39:	85 f6                	test   %esi,%esi
  801e3b:	74 04                	je     801e41 <devpipe_read+0x25>
				return i;
  801e3d:	89 f0                	mov    %esi,%eax
  801e3f:	eb 40                	jmp    801e81 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e41:	89 da                	mov    %ebx,%edx
  801e43:	89 f8                	mov    %edi,%eax
  801e45:	e8 f5 fe ff ff       	call   801d3f <_pipeisclosed>
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	75 2e                	jne    801e7c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e4e:	e8 77 ed ff ff       	call   800bca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e53:	8b 03                	mov    (%ebx),%eax
  801e55:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e58:	74 df                	je     801e39 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e5a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e5f:	79 05                	jns    801e66 <devpipe_read+0x4a>
  801e61:	48                   	dec    %eax
  801e62:	83 c8 e0             	or     $0xffffffe0,%eax
  801e65:	40                   	inc    %eax
  801e66:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e70:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e72:	46                   	inc    %esi
  801e73:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e76:	75 db                	jne    801e53 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e78:	89 f0                	mov    %esi,%eax
  801e7a:	eb 05                	jmp    801e81 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e7c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e81:	83 c4 1c             	add    $0x1c,%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5f                   	pop    %edi
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	57                   	push   %edi
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	83 ec 3c             	sub    $0x3c,%esp
  801e92:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e95:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e98:	89 04 24             	mov    %eax,(%esp)
  801e9b:	e8 b3 f0 ff ff       	call   800f53 <fd_alloc>
  801ea0:	89 c3                	mov    %eax,%ebx
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	0f 88 45 01 00 00    	js     801fef <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eaa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eb1:	00 
  801eb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec0:	e8 24 ed ff ff       	call   800be9 <sys_page_alloc>
  801ec5:	89 c3                	mov    %eax,%ebx
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	0f 88 20 01 00 00    	js     801fef <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ecf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ed2:	89 04 24             	mov    %eax,(%esp)
  801ed5:	e8 79 f0 ff ff       	call   800f53 <fd_alloc>
  801eda:	89 c3                	mov    %eax,%ebx
  801edc:	85 c0                	test   %eax,%eax
  801ede:	0f 88 f8 00 00 00    	js     801fdc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eeb:	00 
  801eec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801efa:	e8 ea ec ff ff       	call   800be9 <sys_page_alloc>
  801eff:	89 c3                	mov    %eax,%ebx
  801f01:	85 c0                	test   %eax,%eax
  801f03:	0f 88 d3 00 00 00    	js     801fdc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f0c:	89 04 24             	mov    %eax,(%esp)
  801f0f:	e8 24 f0 ff ff       	call   800f38 <fd2data>
  801f14:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f16:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f1d:	00 
  801f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f29:	e8 bb ec ff ff       	call   800be9 <sys_page_alloc>
  801f2e:	89 c3                	mov    %eax,%ebx
  801f30:	85 c0                	test   %eax,%eax
  801f32:	0f 88 91 00 00 00    	js     801fc9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f3b:	89 04 24             	mov    %eax,(%esp)
  801f3e:	e8 f5 ef ff ff       	call   800f38 <fd2data>
  801f43:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f4a:	00 
  801f4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f56:	00 
  801f57:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f62:	e8 d6 ec ff ff       	call   800c3d <sys_page_map>
  801f67:	89 c3                	mov    %eax,%ebx
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	78 4c                	js     801fb9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f6d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f76:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f7b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f82:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f8b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f90:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f9a:	89 04 24             	mov    %eax,(%esp)
  801f9d:	e8 86 ef ff ff       	call   800f28 <fd2num>
  801fa2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801fa4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fa7:	89 04 24             	mov    %eax,(%esp)
  801faa:	e8 79 ef ff ff       	call   800f28 <fd2num>
  801faf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801fb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fb7:	eb 36                	jmp    801fef <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801fb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc4:	e8 c7 ec ff ff       	call   800c90 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd7:	e8 b4 ec ff ff       	call   800c90 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801fdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fea:	e8 a1 ec ff ff       	call   800c90 <sys_page_unmap>
    err:
	return r;
}
  801fef:	89 d8                	mov    %ebx,%eax
  801ff1:	83 c4 3c             	add    $0x3c,%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802002:	89 44 24 04          	mov    %eax,0x4(%esp)
  802006:	8b 45 08             	mov    0x8(%ebp),%eax
  802009:	89 04 24             	mov    %eax,(%esp)
  80200c:	e8 95 ef ff ff       	call   800fa6 <fd_lookup>
  802011:	85 c0                	test   %eax,%eax
  802013:	78 15                	js     80202a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802018:	89 04 24             	mov    %eax,(%esp)
  80201b:	e8 18 ef ff ff       	call   800f38 <fd2data>
	return _pipeisclosed(fd, p);
  802020:	89 c2                	mov    %eax,%edx
  802022:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802025:	e8 15 fd ff ff       	call   801d3f <_pipeisclosed>
}
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    

0080202c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80202f:	b8 00 00 00 00       	mov    $0x0,%eax
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    

00802036 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80203c:	c7 44 24 04 8f 2a 80 	movl   $0x802a8f,0x4(%esp)
  802043:	00 
  802044:	8b 45 0c             	mov    0xc(%ebp),%eax
  802047:	89 04 24             	mov    %eax,(%esp)
  80204a:	e8 a8 e7 ff ff       	call   8007f7 <strcpy>
	return 0;
}
  80204f:	b8 00 00 00 00       	mov    $0x0,%eax
  802054:	c9                   	leave  
  802055:	c3                   	ret    

00802056 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	57                   	push   %edi
  80205a:	56                   	push   %esi
  80205b:	53                   	push   %ebx
  80205c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802062:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802067:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80206d:	eb 30                	jmp    80209f <devcons_write+0x49>
		m = n - tot;
  80206f:	8b 75 10             	mov    0x10(%ebp),%esi
  802072:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802074:	83 fe 7f             	cmp    $0x7f,%esi
  802077:	76 05                	jbe    80207e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802079:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80207e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802082:	03 45 0c             	add    0xc(%ebp),%eax
  802085:	89 44 24 04          	mov    %eax,0x4(%esp)
  802089:	89 3c 24             	mov    %edi,(%esp)
  80208c:	e8 df e8 ff ff       	call   800970 <memmove>
		sys_cputs(buf, m);
  802091:	89 74 24 04          	mov    %esi,0x4(%esp)
  802095:	89 3c 24             	mov    %edi,(%esp)
  802098:	e8 7f ea ff ff       	call   800b1c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80209d:	01 f3                	add    %esi,%ebx
  80209f:	89 d8                	mov    %ebx,%eax
  8020a1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020a4:	72 c9                	jb     80206f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020a6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020ac:	5b                   	pop    %ebx
  8020ad:	5e                   	pop    %esi
  8020ae:	5f                   	pop    %edi
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    

008020b1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8020b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020bb:	75 07                	jne    8020c4 <devcons_read+0x13>
  8020bd:	eb 25                	jmp    8020e4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020bf:	e8 06 eb ff ff       	call   800bca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020c4:	e8 71 ea ff ff       	call   800b3a <sys_cgetc>
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	74 f2                	je     8020bf <devcons_read+0xe>
  8020cd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8020cf:	85 c0                	test   %eax,%eax
  8020d1:	78 1d                	js     8020f0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020d3:	83 f8 04             	cmp    $0x4,%eax
  8020d6:	74 13                	je     8020eb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8020d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020db:	88 10                	mov    %dl,(%eax)
	return 1;
  8020dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e2:	eb 0c                	jmp    8020f0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8020e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e9:	eb 05                	jmp    8020f0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020eb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020f0:	c9                   	leave  
  8020f1:	c3                   	ret    

008020f2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802105:	00 
  802106:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802109:	89 04 24             	mov    %eax,(%esp)
  80210c:	e8 0b ea ff ff       	call   800b1c <sys_cputs>
}
  802111:	c9                   	leave  
  802112:	c3                   	ret    

00802113 <getchar>:

int
getchar(void)
{
  802113:	55                   	push   %ebp
  802114:	89 e5                	mov    %esp,%ebp
  802116:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802119:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802120:	00 
  802121:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802124:	89 44 24 04          	mov    %eax,0x4(%esp)
  802128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80212f:	e8 10 f1 ff ff       	call   801244 <read>
	if (r < 0)
  802134:	85 c0                	test   %eax,%eax
  802136:	78 0f                	js     802147 <getchar+0x34>
		return r;
	if (r < 1)
  802138:	85 c0                	test   %eax,%eax
  80213a:	7e 06                	jle    802142 <getchar+0x2f>
		return -E_EOF;
	return c;
  80213c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802140:	eb 05                	jmp    802147 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802142:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802147:	c9                   	leave  
  802148:	c3                   	ret    

00802149 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802152:	89 44 24 04          	mov    %eax,0x4(%esp)
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	89 04 24             	mov    %eax,(%esp)
  80215c:	e8 45 ee ff ff       	call   800fa6 <fd_lookup>
  802161:	85 c0                	test   %eax,%eax
  802163:	78 11                	js     802176 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802168:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80216e:	39 10                	cmp    %edx,(%eax)
  802170:	0f 94 c0             	sete   %al
  802173:	0f b6 c0             	movzbl %al,%eax
}
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <opencons>:

int
opencons(void)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80217e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802181:	89 04 24             	mov    %eax,(%esp)
  802184:	e8 ca ed ff ff       	call   800f53 <fd_alloc>
  802189:	85 c0                	test   %eax,%eax
  80218b:	78 3c                	js     8021c9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80218d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802194:	00 
  802195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a3:	e8 41 ea ff ff       	call   800be9 <sys_page_alloc>
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	78 1d                	js     8021c9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021ac:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021c1:	89 04 24             	mov    %eax,(%esp)
  8021c4:	e8 5f ed ff ff       	call   800f28 <fd2num>
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    
	...

008021cc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	56                   	push   %esi
  8021d0:	53                   	push   %ebx
  8021d1:	83 ec 10             	sub    $0x10,%esp
  8021d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8021d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021da:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	74 0a                	je     8021eb <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8021e1:	89 04 24             	mov    %eax,(%esp)
  8021e4:	e8 16 ec ff ff       	call   800dff <sys_ipc_recv>
  8021e9:	eb 0c                	jmp    8021f7 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8021eb:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8021f2:	e8 08 ec ff ff       	call   800dff <sys_ipc_recv>
	}
	if (r < 0)
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	79 16                	jns    802211 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8021fb:	85 db                	test   %ebx,%ebx
  8021fd:	74 06                	je     802205 <ipc_recv+0x39>
  8021ff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802205:	85 f6                	test   %esi,%esi
  802207:	74 2c                	je     802235 <ipc_recv+0x69>
  802209:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80220f:	eb 24                	jmp    802235 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802211:	85 db                	test   %ebx,%ebx
  802213:	74 0a                	je     80221f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802215:	a1 08 40 80 00       	mov    0x804008,%eax
  80221a:	8b 40 74             	mov    0x74(%eax),%eax
  80221d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80221f:	85 f6                	test   %esi,%esi
  802221:	74 0a                	je     80222d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802223:	a1 08 40 80 00       	mov    0x804008,%eax
  802228:	8b 40 78             	mov    0x78(%eax),%eax
  80222b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80222d:	a1 08 40 80 00       	mov    0x804008,%eax
  802232:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802235:	83 c4 10             	add    $0x10,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    

0080223c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	57                   	push   %edi
  802240:	56                   	push   %esi
  802241:	53                   	push   %ebx
  802242:	83 ec 1c             	sub    $0x1c,%esp
  802245:	8b 75 08             	mov    0x8(%ebp),%esi
  802248:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80224b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80224e:	85 db                	test   %ebx,%ebx
  802250:	74 19                	je     80226b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802252:	8b 45 14             	mov    0x14(%ebp),%eax
  802255:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802259:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80225d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802261:	89 34 24             	mov    %esi,(%esp)
  802264:	e8 73 eb ff ff       	call   800ddc <sys_ipc_try_send>
  802269:	eb 1c                	jmp    802287 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80226b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802272:	00 
  802273:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80227a:	ee 
  80227b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80227f:	89 34 24             	mov    %esi,(%esp)
  802282:	e8 55 eb ff ff       	call   800ddc <sys_ipc_try_send>
		}
		if (r == 0)
  802287:	85 c0                	test   %eax,%eax
  802289:	74 2c                	je     8022b7 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80228b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80228e:	74 20                	je     8022b0 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802290:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802294:	c7 44 24 08 9b 2a 80 	movl   $0x802a9b,0x8(%esp)
  80229b:	00 
  80229c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8022a3:	00 
  8022a4:	c7 04 24 ae 2a 80 00 	movl   $0x802aae,(%esp)
  8022ab:	e8 a4 de ff ff       	call   800154 <_panic>
		}
		sys_yield();
  8022b0:	e8 15 e9 ff ff       	call   800bca <sys_yield>
	}
  8022b5:	eb 97                	jmp    80224e <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8022b7:	83 c4 1c             	add    $0x1c,%esp
  8022ba:	5b                   	pop    %ebx
  8022bb:	5e                   	pop    %esi
  8022bc:	5f                   	pop    %edi
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    

008022bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	53                   	push   %ebx
  8022c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8022c6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022cb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8022d2:	89 c2                	mov    %eax,%edx
  8022d4:	c1 e2 07             	shl    $0x7,%edx
  8022d7:	29 ca                	sub    %ecx,%edx
  8022d9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022df:	8b 52 50             	mov    0x50(%edx),%edx
  8022e2:	39 da                	cmp    %ebx,%edx
  8022e4:	75 0f                	jne    8022f5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8022e6:	c1 e0 07             	shl    $0x7,%eax
  8022e9:	29 c8                	sub    %ecx,%eax
  8022eb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022f0:	8b 40 40             	mov    0x40(%eax),%eax
  8022f3:	eb 0c                	jmp    802301 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022f5:	40                   	inc    %eax
  8022f6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022fb:	75 ce                	jne    8022cb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022fd:	66 b8 00 00          	mov    $0x0,%ax
}
  802301:	5b                   	pop    %ebx
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    

00802304 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80230a:	89 c2                	mov    %eax,%edx
  80230c:	c1 ea 16             	shr    $0x16,%edx
  80230f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802316:	f6 c2 01             	test   $0x1,%dl
  802319:	74 1e                	je     802339 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80231b:	c1 e8 0c             	shr    $0xc,%eax
  80231e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802325:	a8 01                	test   $0x1,%al
  802327:	74 17                	je     802340 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802329:	c1 e8 0c             	shr    $0xc,%eax
  80232c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802333:	ef 
  802334:	0f b7 c0             	movzwl %ax,%eax
  802337:	eb 0c                	jmp    802345 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802339:	b8 00 00 00 00       	mov    $0x0,%eax
  80233e:	eb 05                	jmp    802345 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802340:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802345:	5d                   	pop    %ebp
  802346:	c3                   	ret    
	...

00802348 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802348:	55                   	push   %ebp
  802349:	57                   	push   %edi
  80234a:	56                   	push   %esi
  80234b:	83 ec 10             	sub    $0x10,%esp
  80234e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802352:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80235e:	89 cd                	mov    %ecx,%ebp
  802360:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802364:	85 c0                	test   %eax,%eax
  802366:	75 2c                	jne    802394 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802368:	39 f9                	cmp    %edi,%ecx
  80236a:	77 68                	ja     8023d4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80236c:	85 c9                	test   %ecx,%ecx
  80236e:	75 0b                	jne    80237b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802370:	b8 01 00 00 00       	mov    $0x1,%eax
  802375:	31 d2                	xor    %edx,%edx
  802377:	f7 f1                	div    %ecx
  802379:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	89 f8                	mov    %edi,%eax
  80237f:	f7 f1                	div    %ecx
  802381:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802383:	89 f0                	mov    %esi,%eax
  802385:	f7 f1                	div    %ecx
  802387:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802389:	89 f0                	mov    %esi,%eax
  80238b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80238d:	83 c4 10             	add    $0x10,%esp
  802390:	5e                   	pop    %esi
  802391:	5f                   	pop    %edi
  802392:	5d                   	pop    %ebp
  802393:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802394:	39 f8                	cmp    %edi,%eax
  802396:	77 2c                	ja     8023c4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802398:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80239b:	83 f6 1f             	xor    $0x1f,%esi
  80239e:	75 4c                	jne    8023ec <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023a0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023a2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023a7:	72 0a                	jb     8023b3 <__udivdi3+0x6b>
  8023a9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8023ad:	0f 87 ad 00 00 00    	ja     802460 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023b3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023b8:	89 f0                	mov    %esi,%eax
  8023ba:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023bc:	83 c4 10             	add    $0x10,%esp
  8023bf:	5e                   	pop    %esi
  8023c0:	5f                   	pop    %edi
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    
  8023c3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023c4:	31 ff                	xor    %edi,%edi
  8023c6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023c8:	89 f0                	mov    %esi,%eax
  8023ca:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023cc:	83 c4 10             	add    $0x10,%esp
  8023cf:	5e                   	pop    %esi
  8023d0:	5f                   	pop    %edi
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    
  8023d3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023d4:	89 fa                	mov    %edi,%edx
  8023d6:	89 f0                	mov    %esi,%eax
  8023d8:	f7 f1                	div    %ecx
  8023da:	89 c6                	mov    %eax,%esi
  8023dc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023de:	89 f0                	mov    %esi,%eax
  8023e0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023e2:	83 c4 10             	add    $0x10,%esp
  8023e5:	5e                   	pop    %esi
  8023e6:	5f                   	pop    %edi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    
  8023e9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023ec:	89 f1                	mov    %esi,%ecx
  8023ee:	d3 e0                	shl    %cl,%eax
  8023f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023f4:	b8 20 00 00 00       	mov    $0x20,%eax
  8023f9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8023fb:	89 ea                	mov    %ebp,%edx
  8023fd:	88 c1                	mov    %al,%cl
  8023ff:	d3 ea                	shr    %cl,%edx
  802401:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802405:	09 ca                	or     %ecx,%edx
  802407:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80240b:	89 f1                	mov    %esi,%ecx
  80240d:	d3 e5                	shl    %cl,%ebp
  80240f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802413:	89 fd                	mov    %edi,%ebp
  802415:	88 c1                	mov    %al,%cl
  802417:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802419:	89 fa                	mov    %edi,%edx
  80241b:	89 f1                	mov    %esi,%ecx
  80241d:	d3 e2                	shl    %cl,%edx
  80241f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802423:	88 c1                	mov    %al,%cl
  802425:	d3 ef                	shr    %cl,%edi
  802427:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802429:	89 f8                	mov    %edi,%eax
  80242b:	89 ea                	mov    %ebp,%edx
  80242d:	f7 74 24 08          	divl   0x8(%esp)
  802431:	89 d1                	mov    %edx,%ecx
  802433:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802435:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802439:	39 d1                	cmp    %edx,%ecx
  80243b:	72 17                	jb     802454 <__udivdi3+0x10c>
  80243d:	74 09                	je     802448 <__udivdi3+0x100>
  80243f:	89 fe                	mov    %edi,%esi
  802441:	31 ff                	xor    %edi,%edi
  802443:	e9 41 ff ff ff       	jmp    802389 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802448:	8b 54 24 04          	mov    0x4(%esp),%edx
  80244c:	89 f1                	mov    %esi,%ecx
  80244e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802450:	39 c2                	cmp    %eax,%edx
  802452:	73 eb                	jae    80243f <__udivdi3+0xf7>
		{
		  q0--;
  802454:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802457:	31 ff                	xor    %edi,%edi
  802459:	e9 2b ff ff ff       	jmp    802389 <__udivdi3+0x41>
  80245e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802460:	31 f6                	xor    %esi,%esi
  802462:	e9 22 ff ff ff       	jmp    802389 <__udivdi3+0x41>
	...

00802468 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802468:	55                   	push   %ebp
  802469:	57                   	push   %edi
  80246a:	56                   	push   %esi
  80246b:	83 ec 20             	sub    $0x20,%esp
  80246e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802472:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802476:	89 44 24 14          	mov    %eax,0x14(%esp)
  80247a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80247e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802482:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802486:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802488:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80248a:	85 ed                	test   %ebp,%ebp
  80248c:	75 16                	jne    8024a4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80248e:	39 f1                	cmp    %esi,%ecx
  802490:	0f 86 a6 00 00 00    	jbe    80253c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802496:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802498:	89 d0                	mov    %edx,%eax
  80249a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80249c:	83 c4 20             	add    $0x20,%esp
  80249f:	5e                   	pop    %esi
  8024a0:	5f                   	pop    %edi
  8024a1:	5d                   	pop    %ebp
  8024a2:	c3                   	ret    
  8024a3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024a4:	39 f5                	cmp    %esi,%ebp
  8024a6:	0f 87 ac 00 00 00    	ja     802558 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024ac:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8024af:	83 f0 1f             	xor    $0x1f,%eax
  8024b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8024b6:	0f 84 a8 00 00 00    	je     802564 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024bc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024c0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024c2:	bf 20 00 00 00       	mov    $0x20,%edi
  8024c7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8024cb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024cf:	89 f9                	mov    %edi,%ecx
  8024d1:	d3 e8                	shr    %cl,%eax
  8024d3:	09 e8                	or     %ebp,%eax
  8024d5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8024d9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024dd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024e1:	d3 e0                	shl    %cl,%eax
  8024e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8024e7:	89 f2                	mov    %esi,%edx
  8024e9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8024eb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024ef:	d3 e0                	shl    %cl,%eax
  8024f1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8024f5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024f9:	89 f9                	mov    %edi,%ecx
  8024fb:	d3 e8                	shr    %cl,%eax
  8024fd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8024ff:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802501:	89 f2                	mov    %esi,%edx
  802503:	f7 74 24 18          	divl   0x18(%esp)
  802507:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802509:	f7 64 24 0c          	mull   0xc(%esp)
  80250d:	89 c5                	mov    %eax,%ebp
  80250f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802511:	39 d6                	cmp    %edx,%esi
  802513:	72 67                	jb     80257c <__umoddi3+0x114>
  802515:	74 75                	je     80258c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802517:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80251b:	29 e8                	sub    %ebp,%eax
  80251d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80251f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802523:	d3 e8                	shr    %cl,%eax
  802525:	89 f2                	mov    %esi,%edx
  802527:	89 f9                	mov    %edi,%ecx
  802529:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80252b:	09 d0                	or     %edx,%eax
  80252d:	89 f2                	mov    %esi,%edx
  80252f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802533:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802535:	83 c4 20             	add    $0x20,%esp
  802538:	5e                   	pop    %esi
  802539:	5f                   	pop    %edi
  80253a:	5d                   	pop    %ebp
  80253b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80253c:	85 c9                	test   %ecx,%ecx
  80253e:	75 0b                	jne    80254b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802540:	b8 01 00 00 00       	mov    $0x1,%eax
  802545:	31 d2                	xor    %edx,%edx
  802547:	f7 f1                	div    %ecx
  802549:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80254b:	89 f0                	mov    %esi,%eax
  80254d:	31 d2                	xor    %edx,%edx
  80254f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802551:	89 f8                	mov    %edi,%eax
  802553:	e9 3e ff ff ff       	jmp    802496 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802558:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80255a:	83 c4 20             	add    $0x20,%esp
  80255d:	5e                   	pop    %esi
  80255e:	5f                   	pop    %edi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    
  802561:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802564:	39 f5                	cmp    %esi,%ebp
  802566:	72 04                	jb     80256c <__umoddi3+0x104>
  802568:	39 f9                	cmp    %edi,%ecx
  80256a:	77 06                	ja     802572 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80256c:	89 f2                	mov    %esi,%edx
  80256e:	29 cf                	sub    %ecx,%edi
  802570:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802572:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802574:	83 c4 20             	add    $0x20,%esp
  802577:	5e                   	pop    %esi
  802578:	5f                   	pop    %edi
  802579:	5d                   	pop    %ebp
  80257a:	c3                   	ret    
  80257b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80257c:	89 d1                	mov    %edx,%ecx
  80257e:	89 c5                	mov    %eax,%ebp
  802580:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802584:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802588:	eb 8d                	jmp    802517 <__umoddi3+0xaf>
  80258a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80258c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802590:	72 ea                	jb     80257c <__umoddi3+0x114>
  802592:	89 f1                	mov    %esi,%ecx
  802594:	eb 81                	jmp    802517 <__umoddi3+0xaf>
