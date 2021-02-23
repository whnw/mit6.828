
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 d3 00 00 00       	call   800104 <libmain>
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
  800044:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  80004b:	e8 1c 02 00 00       	call   80026c <cprintf>
	cprintf("we are in handler\n");
  800050:	c7 04 24 ca 25 80 00 	movl   $0x8025ca,(%esp)
  800057:	e8 10 02 00 00       	call   80026c <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80005c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800063:	00 
  800064:	89 d8                	mov    %ebx,%eax
  800066:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80006b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800076:	e8 8e 0b 00 00       	call   800c09 <sys_page_alloc>
  80007b:	85 c0                	test   %eax,%eax
  80007d:	79 24                	jns    8000a3 <handler+0x6f>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800083:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800087:	c7 44 24 08 f4 25 80 	movl   $0x8025f4,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 dd 25 80 00 	movl   $0x8025dd,(%esp)
  80009e:	e8 d1 00 00 00       	call   800174 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a7:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000b6:	00 
  8000b7:	89 1c 24             	mov    %ebx,(%esp)
  8000ba:	e8 fa 06 00 00       	call   8007b9 <snprintf>
}
  8000bf:	83 c4 24             	add    $0x24,%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <umain>:

void
umain(int argc, char **argv)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000cb:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000d2:	e8 fd 0d 00 00       	call   800ed4 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000d7:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000de:	de 
  8000df:	c7 04 24 ef 25 80 00 	movl   $0x8025ef,(%esp)
  8000e6:	e8 81 01 00 00       	call   80026c <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000eb:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000f2:	ca 
  8000f3:	c7 04 24 ef 25 80 00 	movl   $0x8025ef,(%esp)
  8000fa:	e8 6d 01 00 00       	call   80026c <cprintf>
}
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	83 ec 10             	sub    $0x10,%esp
  80010c:	8b 75 08             	mov    0x8(%ebp),%esi
  80010f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800112:	e8 b4 0a 00 00       	call   800bcb <sys_getenvid>
  800117:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800123:	c1 e0 07             	shl    $0x7,%eax
  800126:	29 d0                	sub    %edx,%eax
  800128:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012d:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800132:	85 f6                	test   %esi,%esi
  800134:	7e 07                	jle    80013d <libmain+0x39>
		binaryname = argv[0];
  800136:	8b 03                	mov    (%ebx),%eax
  800138:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800141:	89 34 24             	mov    %esi,(%esp)
  800144:	e8 7c ff ff ff       	call   8000c5 <umain>

	// exit gracefully
	exit();
  800149:	e8 0a 00 00 00       	call   800158 <exit>
}
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    
  800155:	00 00                	add    %al,(%eax)
	...

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80015e:	e8 cc 0f 00 00       	call   80112f <close_all>
	sys_env_destroy(0);
  800163:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80016a:	e8 0a 0a 00 00       	call   800b79 <sys_env_destroy>
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    
  800171:	00 00                	add    %al,(%eax)
	...

00800174 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
  800179:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80017c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800185:	e8 41 0a 00 00       	call   800bcb <sys_getenvid>
  80018a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800191:	8b 55 08             	mov    0x8(%ebp),%edx
  800194:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800198:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a0:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  8001a7:	e8 c0 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b3:	89 04 24             	mov    %eax,(%esp)
  8001b6:	e8 50 00 00 00       	call   80020b <vcprintf>
	cprintf("\n");
  8001bb:	c7 04 24 c8 2a 80 00 	movl   $0x802ac8,(%esp)
  8001c2:	e8 a5 00 00 00       	call   80026c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c7:	cc                   	int3   
  8001c8:	eb fd                	jmp    8001c7 <_panic+0x53>
	...

008001cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	53                   	push   %ebx
  8001d0:	83 ec 14             	sub    $0x14,%esp
  8001d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d6:	8b 03                	mov    (%ebx),%eax
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001df:	40                   	inc    %eax
  8001e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e7:	75 19                	jne    800202 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f0:	00 
  8001f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 40 09 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  8001fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800202:	ff 43 04             	incl   0x4(%ebx)
}
  800205:	83 c4 14             	add    $0x14,%esp
  800208:	5b                   	pop    %ebx
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    

0080020b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800214:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021b:	00 00 00 
	b.cnt = 0;
  80021e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800225:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022f:	8b 45 08             	mov    0x8(%ebp),%eax
  800232:	89 44 24 08          	mov    %eax,0x8(%esp)
  800236:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800240:	c7 04 24 cc 01 80 00 	movl   $0x8001cc,(%esp)
  800247:	e8 82 01 00 00       	call   8003ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800252:	89 44 24 04          	mov    %eax,0x4(%esp)
  800256:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 d8 08 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	8b 45 08             	mov    0x8(%ebp),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	e8 87 ff ff ff       	call   80020b <vcprintf>
	va_end(ap);

	return cnt;
}
  800284:	c9                   	leave  
  800285:	c3                   	ret    
	...

00800288 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 3c             	sub    $0x3c,%esp
  800291:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800294:	89 d7                	mov    %edx,%edi
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80029c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	75 08                	jne    8002b4 <printnum+0x2c>
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b2:	77 57                	ja     80030b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b8:	4b                   	dec    %ebx
  8002b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d3:	00 
  8002d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e1:	e8 82 20 00 00       	call   802368 <__udivdi3>
  8002e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f5:	89 fa                	mov    %edi,%edx
  8002f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fa:	e8 89 ff ff ff       	call   800288 <printnum>
  8002ff:	eb 0f                	jmp    800310 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800305:	89 34 24             	mov    %esi,(%esp)
  800308:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030b:	4b                   	dec    %ebx
  80030c:	85 db                	test   %ebx,%ebx
  80030e:	7f f1                	jg     800301 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800310:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800314:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800318:	8b 45 10             	mov    0x10(%ebp),%eax
  80031b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800326:	00 
  800327:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800330:	89 44 24 04          	mov    %eax,0x4(%esp)
  800334:	e8 4f 21 00 00       	call   802488 <__umoddi3>
  800339:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033d:	0f be 80 6f 26 80 00 	movsbl 0x80266f(%eax),%eax
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80034a:	83 c4 3c             	add    $0x3c,%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800355:	83 fa 01             	cmp    $0x1,%edx
  800358:	7e 0e                	jle    800368 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	8b 52 04             	mov    0x4(%edx),%edx
  800366:	eb 22                	jmp    80038a <getuint+0x38>
	else if (lflag)
  800368:	85 d2                	test   %edx,%edx
  80036a:	74 10                	je     80037c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
  80037a:	eb 0e                	jmp    80038a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800392:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800395:	8b 10                	mov    (%eax),%edx
  800397:	3b 50 04             	cmp    0x4(%eax),%edx
  80039a:	73 08                	jae    8003a4 <sprintputch+0x18>
		*b->buf++ = ch;
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	88 0a                	mov    %cl,(%edx)
  8003a1:	42                   	inc    %edx
  8003a2:	89 10                	mov    %edx,(%eax)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	e8 02 00 00 00       	call   8003ce <vprintfmt>
	va_end(ap);
}
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	57                   	push   %edi
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 4c             	sub    $0x4c,%esp
  8003d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003da:	8b 75 10             	mov    0x10(%ebp),%esi
  8003dd:	eb 12                	jmp    8003f1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	0f 84 6b 03 00 00    	je     800752 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f1:	0f b6 06             	movzbl (%esi),%eax
  8003f4:	46                   	inc    %esi
  8003f5:	83 f8 25             	cmp    $0x25,%eax
  8003f8:	75 e5                	jne    8003df <vprintfmt+0x11>
  8003fa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003fe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800405:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80040a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800411:	b9 00 00 00 00       	mov    $0x0,%ecx
  800416:	eb 26                	jmp    80043e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80041f:	eb 1d                	jmp    80043e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800424:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800428:	eb 14                	jmp    80043e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80042d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800434:	eb 08                	jmp    80043e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800436:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800439:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	0f b6 06             	movzbl (%esi),%eax
  800441:	8d 56 01             	lea    0x1(%esi),%edx
  800444:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800447:	8a 16                	mov    (%esi),%dl
  800449:	83 ea 23             	sub    $0x23,%edx
  80044c:	80 fa 55             	cmp    $0x55,%dl
  80044f:	0f 87 e1 02 00 00    	ja     800736 <vprintfmt+0x368>
  800455:	0f b6 d2             	movzbl %dl,%edx
  800458:	ff 24 95 c0 27 80 00 	jmp    *0x8027c0(,%edx,4)
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800462:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800467:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80046a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80046e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800471:	8d 50 d0             	lea    -0x30(%eax),%edx
  800474:	83 fa 09             	cmp    $0x9,%edx
  800477:	77 2a                	ja     8004a3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800479:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047a:	eb eb                	jmp    800467 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80048a:	eb 17                	jmp    8004a3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80048c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800490:	78 98                	js     80042a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800495:	eb a7                	jmp    80043e <vprintfmt+0x70>
  800497:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004a1:	eb 9b                	jmp    80043e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a7:	79 95                	jns    80043e <vprintfmt+0x70>
  8004a9:	eb 8b                	jmp    800436 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ab:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004af:	eb 8d                	jmp    80043e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 50 04             	lea    0x4(%eax),%edx
  8004b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	89 04 24             	mov    %eax,(%esp)
  8004c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c9:	e9 23 ff ff ff       	jmp    8003f1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 50 04             	lea    0x4(%eax),%edx
  8004d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	79 02                	jns    8004df <vprintfmt+0x111>
  8004dd:	f7 d8                	neg    %eax
  8004df:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e1:	83 f8 10             	cmp    $0x10,%eax
  8004e4:	7f 0b                	jg     8004f1 <vprintfmt+0x123>
  8004e6:	8b 04 85 20 29 80 00 	mov    0x802920(,%eax,4),%eax
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	75 23                	jne    800514 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f5:	c7 44 24 08 87 26 80 	movl   $0x802687,0x8(%esp)
  8004fc:	00 
  8004fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800501:	8b 45 08             	mov    0x8(%ebp),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	e8 9a fe ff ff       	call   8003a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80050f:	e9 dd fe ff ff       	jmp    8003f1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800514:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800518:	c7 44 24 08 5d 2a 80 	movl   $0x802a5d,0x8(%esp)
  80051f:	00 
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	8b 55 08             	mov    0x8(%ebp),%edx
  800527:	89 14 24             	mov    %edx,(%esp)
  80052a:	e8 77 fe ff ff       	call   8003a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800532:	e9 ba fe ff ff       	jmp    8003f1 <vprintfmt+0x23>
  800537:	89 f9                	mov    %edi,%ecx
  800539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 30                	mov    (%eax),%esi
  80054a:	85 f6                	test   %esi,%esi
  80054c:	75 05                	jne    800553 <vprintfmt+0x185>
				p = "(null)";
  80054e:	be 80 26 80 00       	mov    $0x802680,%esi
			if (width > 0 && padc != '-')
  800553:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800557:	0f 8e 84 00 00 00    	jle    8005e1 <vprintfmt+0x213>
  80055d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800561:	74 7e                	je     8005e1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800567:	89 34 24             	mov    %esi,(%esp)
  80056a:	e8 8b 02 00 00       	call   8007fa <strnlen>
  80056f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800572:	29 c2                	sub    %eax,%edx
  800574:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800577:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80057b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80057e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800581:	89 de                	mov    %ebx,%esi
  800583:	89 d3                	mov    %edx,%ebx
  800585:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800587:	eb 0b                	jmp    800594 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800589:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058d:	89 3c 24             	mov    %edi,(%esp)
  800590:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	4b                   	dec    %ebx
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f f1                	jg     800589 <vprintfmt+0x1bb>
  800598:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80059b:	89 f3                	mov    %esi,%ebx
  80059d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	79 05                	jns    8005ac <vprintfmt+0x1de>
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005af:	29 c2                	sub    %eax,%edx
  8005b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b4:	eb 2b                	jmp    8005e1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ba:	74 18                	je     8005d4 <vprintfmt+0x206>
  8005bc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005bf:	83 fa 5e             	cmp    $0x5e,%edx
  8005c2:	76 10                	jbe    8005d4 <vprintfmt+0x206>
					putch('?', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
  8005d2:	eb 0a                	jmp    8005de <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005de:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e1:	0f be 06             	movsbl (%esi),%eax
  8005e4:	46                   	inc    %esi
  8005e5:	85 c0                	test   %eax,%eax
  8005e7:	74 21                	je     80060a <vprintfmt+0x23c>
  8005e9:	85 ff                	test   %edi,%edi
  8005eb:	78 c9                	js     8005b6 <vprintfmt+0x1e8>
  8005ed:	4f                   	dec    %edi
  8005ee:	79 c6                	jns    8005b6 <vprintfmt+0x1e8>
  8005f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f3:	89 de                	mov    %ebx,%esi
  8005f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f8:	eb 18                	jmp    800612 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800605:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800607:	4b                   	dec    %ebx
  800608:	eb 08                	jmp    800612 <vprintfmt+0x244>
  80060a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80060d:	89 de                	mov    %ebx,%esi
  80060f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800612:	85 db                	test   %ebx,%ebx
  800614:	7f e4                	jg     8005fa <vprintfmt+0x22c>
  800616:	89 7d 08             	mov    %edi,0x8(%ebp)
  800619:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061e:	e9 ce fd ff ff       	jmp    8003f1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7e 10                	jle    800638 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 08             	lea    0x8(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 30                	mov    (%eax),%esi
  800633:	8b 78 04             	mov    0x4(%eax),%edi
  800636:	eb 26                	jmp    80065e <vprintfmt+0x290>
	else if (lflag)
  800638:	85 c9                	test   %ecx,%ecx
  80063a:	74 12                	je     80064e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	8b 30                	mov    (%eax),%esi
  800647:	89 f7                	mov    %esi,%edi
  800649:	c1 ff 1f             	sar    $0x1f,%edi
  80064c:	eb 10                	jmp    80065e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 30                	mov    (%eax),%esi
  800659:	89 f7                	mov    %esi,%edi
  80065b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065e:	85 ff                	test   %edi,%edi
  800660:	78 0a                	js     80066c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800662:	b8 0a 00 00 00       	mov    $0xa,%eax
  800667:	e9 8c 00 00 00       	jmp    8006f8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80066c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800670:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800677:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80067a:	f7 de                	neg    %esi
  80067c:	83 d7 00             	adc    $0x0,%edi
  80067f:	f7 df                	neg    %edi
			}
			base = 10;
  800681:	b8 0a 00 00 00       	mov    $0xa,%eax
  800686:	eb 70                	jmp    8006f8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800688:	89 ca                	mov    %ecx,%edx
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 c0 fc ff ff       	call   800352 <getuint>
  800692:	89 c6                	mov    %eax,%esi
  800694:	89 d7                	mov    %edx,%edi
			base = 10;
  800696:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80069b:	eb 5b                	jmp    8006f8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  80069d:	89 ca                	mov    %ecx,%edx
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	e8 ab fc ff ff       	call   800352 <getuint>
  8006a7:	89 c6                	mov    %eax,%esi
  8006a9:	89 d7                	mov    %edx,%edi
			base = 8;
  8006ab:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006b0:	eb 46                	jmp    8006f8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006bd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 50 04             	lea    0x4(%eax),%edx
  8006d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d7:	8b 30                	mov    (%eax),%esi
  8006d9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006de:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e3:	eb 13                	jmp    8006f8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e5:	89 ca                	mov    %ecx,%edx
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 63 fc ff ff       	call   800352 <getuint>
  8006ef:	89 c6                	mov    %eax,%esi
  8006f1:	89 d7                	mov    %edx,%edi
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800700:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800703:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800707:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070b:	89 34 24             	mov    %esi,(%esp)
  80070e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800712:	89 da                	mov    %ebx,%edx
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	e8 6c fb ff ff       	call   800288 <printnum>
			break;
  80071c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80071f:	e9 cd fc ff ff       	jmp    8003f1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800731:	e9 bb fc ff ff       	jmp    8003f1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800736:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800744:	eb 01                	jmp    800747 <vprintfmt+0x379>
  800746:	4e                   	dec    %esi
  800747:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074b:	75 f9                	jne    800746 <vprintfmt+0x378>
  80074d:	e9 9f fc ff ff       	jmp    8003f1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800752:	83 c4 4c             	add    $0x4c,%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 28             	sub    $0x28,%esp
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800766:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800769:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800777:	85 c0                	test   %eax,%eax
  800779:	74 30                	je     8007ab <vsnprintf+0x51>
  80077b:	85 d2                	test   %edx,%edx
  80077d:	7e 33                	jle    8007b2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800786:	8b 45 10             	mov    0x10(%ebp),%eax
  800789:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800790:	89 44 24 04          	mov    %eax,0x4(%esp)
  800794:	c7 04 24 8c 03 80 00 	movl   $0x80038c,(%esp)
  80079b:	e8 2e fc ff ff       	call   8003ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a9:	eb 0c                	jmp    8007b7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b0:	eb 05                	jmp    8007b7 <vsnprintf+0x5d>
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	89 04 24             	mov    %eax,(%esp)
  8007da:	e8 7b ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    
  8007e1:	00 00                	add    %al,(%eax)
	...

008007e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	eb 01                	jmp    8007f2 <strlen+0xe>
		n++;
  8007f1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f6:	75 f9                	jne    8007f1 <strlen+0xd>
		n++;
	return n;
}
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800800:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	eb 01                	jmp    80080b <strnlen+0x11>
		n++;
  80080a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	39 d0                	cmp    %edx,%eax
  80080d:	74 06                	je     800815 <strnlen+0x1b>
  80080f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800813:	75 f5                	jne    80080a <strnlen+0x10>
		n++;
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
  800826:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800829:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80082c:	42                   	inc    %edx
  80082d:	84 c9                	test   %cl,%cl
  80082f:	75 f5                	jne    800826 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800831:	5b                   	pop    %ebx
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083e:	89 1c 24             	mov    %ebx,(%esp)
  800841:	e8 9e ff ff ff       	call   8007e4 <strlen>
	strcpy(dst + len, src);
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084d:	01 d8                	add    %ebx,%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 c0 ff ff ff       	call   800817 <strcpy>
	return dst;
}
  800857:	89 d8                	mov    %ebx,%eax
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800872:	eb 0c                	jmp    800880 <strncpy+0x21>
		*dst++ = *src;
  800874:	8a 1a                	mov    (%edx),%bl
  800876:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800879:	80 3a 01             	cmpb   $0x1,(%edx)
  80087c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087f:	41                   	inc    %ecx
  800880:	39 f1                	cmp    %esi,%ecx
  800882:	75 f0                	jne    800874 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	56                   	push   %esi
  80088c:	53                   	push   %ebx
  80088d:	8b 75 08             	mov    0x8(%ebp),%esi
  800890:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800893:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800896:	85 d2                	test   %edx,%edx
  800898:	75 0a                	jne    8008a4 <strlcpy+0x1c>
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	eb 1a                	jmp    8008b8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089e:	88 18                	mov    %bl,(%eax)
  8008a0:	40                   	inc    %eax
  8008a1:	41                   	inc    %ecx
  8008a2:	eb 02                	jmp    8008a6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008a6:	4a                   	dec    %edx
  8008a7:	74 0a                	je     8008b3 <strlcpy+0x2b>
  8008a9:	8a 19                	mov    (%ecx),%bl
  8008ab:	84 db                	test   %bl,%bl
  8008ad:	75 ef                	jne    80089e <strlcpy+0x16>
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	eb 02                	jmp    8008b5 <strlcpy+0x2d>
  8008b3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b8:	29 f0                	sub    %esi,%eax
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c7:	eb 02                	jmp    8008cb <strcmp+0xd>
		p++, q++;
  8008c9:	41                   	inc    %ecx
  8008ca:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cb:	8a 01                	mov    (%ecx),%al
  8008cd:	84 c0                	test   %al,%al
  8008cf:	74 04                	je     8008d5 <strcmp+0x17>
  8008d1:	3a 02                	cmp    (%edx),%al
  8008d3:	74 f4                	je     8008c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d5:	0f b6 c0             	movzbl %al,%eax
  8008d8:	0f b6 12             	movzbl (%edx),%edx
  8008db:	29 d0                	sub    %edx,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008ec:	eb 03                	jmp    8008f1 <strncmp+0x12>
		n--, p++, q++;
  8008ee:	4a                   	dec    %edx
  8008ef:	40                   	inc    %eax
  8008f0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	74 14                	je     800909 <strncmp+0x2a>
  8008f5:	8a 18                	mov    (%eax),%bl
  8008f7:	84 db                	test   %bl,%bl
  8008f9:	74 04                	je     8008ff <strncmp+0x20>
  8008fb:	3a 19                	cmp    (%ecx),%bl
  8008fd:	74 ef                	je     8008ee <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ff:	0f b6 00             	movzbl (%eax),%eax
  800902:	0f b6 11             	movzbl (%ecx),%edx
  800905:	29 d0                	sub    %edx,%eax
  800907:	eb 05                	jmp    80090e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091a:	eb 05                	jmp    800921 <strchr+0x10>
		if (*s == c)
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 0c                	je     80092c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800920:	40                   	inc    %eax
  800921:	8a 10                	mov    (%eax),%dl
  800923:	84 d2                	test   %dl,%dl
  800925:	75 f5                	jne    80091c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800937:	eb 05                	jmp    80093e <strfind+0x10>
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 07                	je     800944 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80093d:	40                   	inc    %eax
  80093e:	8a 10                	mov    (%eax),%dl
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f5                	jne    800939 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	57                   	push   %edi
  80094a:	56                   	push   %esi
  80094b:	53                   	push   %ebx
  80094c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800955:	85 c9                	test   %ecx,%ecx
  800957:	74 30                	je     800989 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800959:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095f:	75 25                	jne    800986 <memset+0x40>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 20                	jne    800986 <memset+0x40>
		c &= 0xFF;
  800966:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800969:	89 d3                	mov    %edx,%ebx
  80096b:	c1 e3 08             	shl    $0x8,%ebx
  80096e:	89 d6                	mov    %edx,%esi
  800970:	c1 e6 18             	shl    $0x18,%esi
  800973:	89 d0                	mov    %edx,%eax
  800975:	c1 e0 10             	shl    $0x10,%eax
  800978:	09 f0                	or     %esi,%eax
  80097a:	09 d0                	or     %edx,%eax
  80097c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800981:	fc                   	cld    
  800982:	f3 ab                	rep stos %eax,%es:(%edi)
  800984:	eb 03                	jmp    800989 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800986:	fc                   	cld    
  800987:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800989:	89 f8                	mov    %edi,%eax
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099e:	39 c6                	cmp    %eax,%esi
  8009a0:	73 34                	jae    8009d6 <memmove+0x46>
  8009a2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a5:	39 d0                	cmp    %edx,%eax
  8009a7:	73 2d                	jae    8009d6 <memmove+0x46>
		s += n;
		d += n;
  8009a9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	f6 c2 03             	test   $0x3,%dl
  8009af:	75 1b                	jne    8009cc <memmove+0x3c>
  8009b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b7:	75 13                	jne    8009cc <memmove+0x3c>
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 0e                	jne    8009cc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009be:	83 ef 04             	sub    $0x4,%edi
  8009c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb 07                	jmp    8009d3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cc:	4f                   	dec    %edi
  8009cd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d0:	fd                   	std    
  8009d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d3:	fc                   	cld    
  8009d4:	eb 20                	jmp    8009f6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009dc:	75 13                	jne    8009f1 <memmove+0x61>
  8009de:	a8 03                	test   $0x3,%al
  8009e0:	75 0f                	jne    8009f1 <memmove+0x61>
  8009e2:	f6 c1 03             	test   $0x3,%cl
  8009e5:	75 0a                	jne    8009f1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ea:	89 c7                	mov    %eax,%edi
  8009ec:	fc                   	cld    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb 05                	jmp    8009f6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f6:	5e                   	pop    %esi
  8009f7:	5f                   	pop    %edi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a00:	8b 45 10             	mov    0x10(%ebp),%eax
  800a03:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	89 04 24             	mov    %eax,(%esp)
  800a14:	e8 77 ff ff ff       	call   800990 <memmove>
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	eb 16                	jmp    800a47 <memcmp+0x2c>
		if (*s1 != *s2)
  800a31:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a34:	42                   	inc    %edx
  800a35:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a39:	38 c8                	cmp    %cl,%al
  800a3b:	74 0a                	je     800a47 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a3d:	0f b6 c0             	movzbl %al,%eax
  800a40:	0f b6 c9             	movzbl %cl,%ecx
  800a43:	29 c8                	sub    %ecx,%eax
  800a45:	eb 09                	jmp    800a50 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a47:	39 da                	cmp    %ebx,%edx
  800a49:	75 e6                	jne    800a31 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a63:	eb 05                	jmp    800a6a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a65:	38 08                	cmp    %cl,(%eax)
  800a67:	74 05                	je     800a6e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a69:	40                   	inc    %eax
  800a6a:	39 d0                	cmp    %edx,%eax
  800a6c:	72 f7                	jb     800a65 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	eb 01                	jmp    800a7f <strtol+0xf>
		s++;
  800a7e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7f:	8a 02                	mov    (%edx),%al
  800a81:	3c 20                	cmp    $0x20,%al
  800a83:	74 f9                	je     800a7e <strtol+0xe>
  800a85:	3c 09                	cmp    $0x9,%al
  800a87:	74 f5                	je     800a7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a89:	3c 2b                	cmp    $0x2b,%al
  800a8b:	75 08                	jne    800a95 <strtol+0x25>
		s++;
  800a8d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a93:	eb 13                	jmp    800aa8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a95:	3c 2d                	cmp    $0x2d,%al
  800a97:	75 0a                	jne    800aa3 <strtol+0x33>
		s++, neg = 1;
  800a99:	8d 52 01             	lea    0x1(%edx),%edx
  800a9c:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa1:	eb 05                	jmp    800aa8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa8:	85 db                	test   %ebx,%ebx
  800aaa:	74 05                	je     800ab1 <strtol+0x41>
  800aac:	83 fb 10             	cmp    $0x10,%ebx
  800aaf:	75 28                	jne    800ad9 <strtol+0x69>
  800ab1:	8a 02                	mov    (%edx),%al
  800ab3:	3c 30                	cmp    $0x30,%al
  800ab5:	75 10                	jne    800ac7 <strtol+0x57>
  800ab7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abb:	75 0a                	jne    800ac7 <strtol+0x57>
		s += 2, base = 16;
  800abd:	83 c2 02             	add    $0x2,%edx
  800ac0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac5:	eb 12                	jmp    800ad9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac7:	85 db                	test   %ebx,%ebx
  800ac9:	75 0e                	jne    800ad9 <strtol+0x69>
  800acb:	3c 30                	cmp    $0x30,%al
  800acd:	75 05                	jne    800ad4 <strtol+0x64>
		s++, base = 8;
  800acf:	42                   	inc    %edx
  800ad0:	b3 08                	mov    $0x8,%bl
  800ad2:	eb 05                	jmp    800ad9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae0:	8a 0a                	mov    (%edx),%cl
  800ae2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae5:	80 fb 09             	cmp    $0x9,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0x82>
			dig = *s - '0';
  800aea:	0f be c9             	movsbl %cl,%ecx
  800aed:	83 e9 30             	sub    $0x30,%ecx
  800af0:	eb 1e                	jmp    800b10 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 08                	ja     800b02 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afa:	0f be c9             	movsbl %cl,%ecx
  800afd:	83 e9 57             	sub    $0x57,%ecx
  800b00:	eb 0e                	jmp    800b10 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b02:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b05:	80 fb 19             	cmp    $0x19,%bl
  800b08:	77 12                	ja     800b1c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b0a:	0f be c9             	movsbl %cl,%ecx
  800b0d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b10:	39 f1                	cmp    %esi,%ecx
  800b12:	7d 0c                	jge    800b20 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b14:	42                   	inc    %edx
  800b15:	0f af c6             	imul   %esi,%eax
  800b18:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b1a:	eb c4                	jmp    800ae0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1c:	89 c1                	mov    %eax,%ecx
  800b1e:	eb 02                	jmp    800b22 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b20:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b26:	74 05                	je     800b2d <strtol+0xbd>
		*endptr = (char *) s;
  800b28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b2d:	85 ff                	test   %edi,%edi
  800b2f:	74 04                	je     800b35 <strtol+0xc5>
  800b31:	89 c8                	mov    %ecx,%eax
  800b33:	f7 d8                	neg    %eax
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
	...

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	89 c6                	mov    %eax,%esi
  800b53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b87:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 cb                	mov    %ecx,%ebx
  800b91:	89 cf                	mov    %ecx,%edi
  800b93:	89 ce                	mov    %ecx,%esi
  800b95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 28                	jle    800bc3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  800bae:	00 
  800baf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb6:	00 
  800bb7:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800bbe:	e8 b1 f5 ff ff       	call   800174 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc3:	83 c4 2c             	add    $0x2c,%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdb:	89 d1                	mov    %edx,%ecx
  800bdd:	89 d3                	mov    %edx,%ebx
  800bdf:	89 d7                	mov    %edx,%edi
  800be1:	89 d6                	mov    %edx,%esi
  800be3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_yield>:

void
sys_yield(void)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfa:	89 d1                	mov    %edx,%ecx
  800bfc:	89 d3                	mov    %edx,%ebx
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c12:	be 00 00 00 00       	mov    $0x0,%esi
  800c17:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 f7                	mov    %esi,%edi
  800c27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7e 28                	jle    800c55 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c31:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c38:	00 
  800c39:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  800c40:	00 
  800c41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c48:	00 
  800c49:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800c50:	e8 1f f5 ff ff       	call   800174 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c55:	83 c4 2c             	add    $0x2c,%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7e 28                	jle    800ca8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c84:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  800c93:	00 
  800c94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9b:	00 
  800c9c:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800ca3:	e8 cc f4 ff ff       	call   800174 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca8:	83 c4 2c             	add    $0x2c,%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	89 df                	mov    %ebx,%edi
  800ccb:	89 de                	mov    %ebx,%esi
  800ccd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7e 28                	jle    800cfb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cde:	00 
  800cdf:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cee:	00 
  800cef:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800cf6:	e8 79 f4 ff ff       	call   800174 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfb:	83 c4 2c             	add    $0x2c,%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	b8 08 00 00 00       	mov    $0x8,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 28                	jle    800d4e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d31:	00 
  800d32:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  800d39:	00 
  800d3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d41:	00 
  800d42:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800d49:	e8 26 f4 ff ff       	call   800174 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4e:	83 c4 2c             	add    $0x2c,%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d64:	b8 09 00 00 00       	mov    $0x9,%eax
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	89 df                	mov    %ebx,%edi
  800d71:	89 de                	mov    %ebx,%esi
  800d73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d75:	85 c0                	test   %eax,%eax
  800d77:	7e 28                	jle    800da1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d84:	00 
  800d85:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  800d8c:	00 
  800d8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d94:	00 
  800d95:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800d9c:	e8 d3 f3 ff ff       	call   800174 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da1:	83 c4 2c             	add    $0x2c,%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	89 df                	mov    %ebx,%edi
  800dc4:	89 de                	mov    %ebx,%esi
  800dc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 28                	jle    800df4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  800ddf:	00 
  800de0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de7:	00 
  800de8:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800def:	e8 80 f3 ff ff       	call   800174 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df4:	83 c4 2c             	add    $0x2c,%esp
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	be 00 00 00 00       	mov    $0x0,%esi
  800e07:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	89 cb                	mov    %ecx,%ebx
  800e37:	89 cf                	mov    %ecx,%edi
  800e39:	89 ce                	mov    %ecx,%esi
  800e3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	7e 28                	jle    800e69 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e45:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  800e54:	00 
  800e55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5c:	00 
  800e5d:	c7 04 24 a0 29 80 00 	movl   $0x8029a0,(%esp)
  800e64:	e8 0b f3 ff ff       	call   800174 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e69:	83 c4 2c             	add    $0x2c,%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e77:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e81:	89 d1                	mov    %edx,%ecx
  800e83:	89 d3                	mov    %edx,%ebx
  800e85:	89 d7                	mov    %edx,%edi
  800e87:	89 d6                	mov    %edx,%esi
  800e89:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea6:	89 df                	mov    %ebx,%edi
  800ea8:	89 de                	mov    %ebx,%esi
  800eaa:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebc:	b8 10 00 00 00       	mov    $0x10,%eax
  800ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	89 df                	mov    %ebx,%edi
  800ec9:	89 de                	mov    %ebx,%esi
  800ecb:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
	...

00800ed4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800eda:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800ee1:	75 30                	jne    800f13 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  800ee3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800ef2:	ee 
  800ef3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800efa:	e8 0a fd ff ff       	call   800c09 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  800eff:	c7 44 24 04 20 0f 80 	movl   $0x800f20,0x4(%esp)
  800f06:	00 
  800f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0e:	e8 96 fe ff ff       	call   800da9 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    
  800f1d:	00 00                	add    %al,(%eax)
	...

00800f20 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f20:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f21:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800f26:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f28:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  800f2b:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  800f2f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  800f33:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  800f36:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  800f38:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  800f3c:	83 c4 08             	add    $0x8,%esp
	popal
  800f3f:	61                   	popa   

	addl $4,%esp 
  800f40:	83 c4 04             	add    $0x4,%esp
	popfl
  800f43:	9d                   	popf   

	popl %esp
  800f44:	5c                   	pop    %esp

	ret
  800f45:	c3                   	ret    
	...

00800f48 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	05 00 00 00 30       	add    $0x30000000,%eax
  800f53:	c1 e8 0c             	shr    $0xc,%eax
}
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f61:	89 04 24             	mov    %eax,(%esp)
  800f64:	e8 df ff ff ff       	call   800f48 <fd2num>
  800f69:	c1 e0 0c             	shl    $0xc,%eax
  800f6c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	53                   	push   %ebx
  800f77:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f7a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f7f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f81:	89 c2                	mov    %eax,%edx
  800f83:	c1 ea 16             	shr    $0x16,%edx
  800f86:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f8d:	f6 c2 01             	test   $0x1,%dl
  800f90:	74 11                	je     800fa3 <fd_alloc+0x30>
  800f92:	89 c2                	mov    %eax,%edx
  800f94:	c1 ea 0c             	shr    $0xc,%edx
  800f97:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f9e:	f6 c2 01             	test   $0x1,%dl
  800fa1:	75 09                	jne    800fac <fd_alloc+0x39>
			*fd_store = fd;
  800fa3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800faa:	eb 17                	jmp    800fc3 <fd_alloc+0x50>
  800fac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fb1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fb6:	75 c7                	jne    800f7f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fb8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fbe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fc3:	5b                   	pop    %ebx
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fcc:	83 f8 1f             	cmp    $0x1f,%eax
  800fcf:	77 36                	ja     801007 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fd1:	c1 e0 0c             	shl    $0xc,%eax
  800fd4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fd9:	89 c2                	mov    %eax,%edx
  800fdb:	c1 ea 16             	shr    $0x16,%edx
  800fde:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fe5:	f6 c2 01             	test   $0x1,%dl
  800fe8:	74 24                	je     80100e <fd_lookup+0x48>
  800fea:	89 c2                	mov    %eax,%edx
  800fec:	c1 ea 0c             	shr    $0xc,%edx
  800fef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ff6:	f6 c2 01             	test   $0x1,%dl
  800ff9:	74 1a                	je     801015 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ffb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ffe:	89 02                	mov    %eax,(%edx)
	return 0;
  801000:	b8 00 00 00 00       	mov    $0x0,%eax
  801005:	eb 13                	jmp    80101a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801007:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80100c:	eb 0c                	jmp    80101a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80100e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801013:	eb 05                	jmp    80101a <fd_lookup+0x54>
  801015:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	53                   	push   %ebx
  801020:	83 ec 14             	sub    $0x14,%esp
  801023:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801026:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801029:	ba 00 00 00 00       	mov    $0x0,%edx
  80102e:	eb 0e                	jmp    80103e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801030:	39 08                	cmp    %ecx,(%eax)
  801032:	75 09                	jne    80103d <dev_lookup+0x21>
			*dev = devtab[i];
  801034:	89 03                	mov    %eax,(%ebx)
			return 0;
  801036:	b8 00 00 00 00       	mov    $0x0,%eax
  80103b:	eb 33                	jmp    801070 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80103d:	42                   	inc    %edx
  80103e:	8b 04 95 30 2a 80 00 	mov    0x802a30(,%edx,4),%eax
  801045:	85 c0                	test   %eax,%eax
  801047:	75 e7                	jne    801030 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801049:	a1 08 40 80 00       	mov    0x804008,%eax
  80104e:	8b 40 48             	mov    0x48(%eax),%eax
  801051:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801055:	89 44 24 04          	mov    %eax,0x4(%esp)
  801059:	c7 04 24 b0 29 80 00 	movl   $0x8029b0,(%esp)
  801060:	e8 07 f2 ff ff       	call   80026c <cprintf>
	*dev = 0;
  801065:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80106b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801070:	83 c4 14             	add    $0x14,%esp
  801073:	5b                   	pop    %ebx
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	83 ec 30             	sub    $0x30,%esp
  80107e:	8b 75 08             	mov    0x8(%ebp),%esi
  801081:	8a 45 0c             	mov    0xc(%ebp),%al
  801084:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801087:	89 34 24             	mov    %esi,(%esp)
  80108a:	e8 b9 fe ff ff       	call   800f48 <fd2num>
  80108f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801092:	89 54 24 04          	mov    %edx,0x4(%esp)
  801096:	89 04 24             	mov    %eax,(%esp)
  801099:	e8 28 ff ff ff       	call   800fc6 <fd_lookup>
  80109e:	89 c3                	mov    %eax,%ebx
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 05                	js     8010a9 <fd_close+0x33>
	    || fd != fd2)
  8010a4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010a7:	74 0d                	je     8010b6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8010a9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010ad:	75 46                	jne    8010f5 <fd_close+0x7f>
  8010af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b4:	eb 3f                	jmp    8010f5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bd:	8b 06                	mov    (%esi),%eax
  8010bf:	89 04 24             	mov    %eax,(%esp)
  8010c2:	e8 55 ff ff ff       	call   80101c <dev_lookup>
  8010c7:	89 c3                	mov    %eax,%ebx
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	78 18                	js     8010e5 <fd_close+0x6f>
		if (dev->dev_close)
  8010cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d0:	8b 40 10             	mov    0x10(%eax),%eax
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	74 09                	je     8010e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010d7:	89 34 24             	mov    %esi,(%esp)
  8010da:	ff d0                	call   *%eax
  8010dc:	89 c3                	mov    %eax,%ebx
  8010de:	eb 05                	jmp    8010e5 <fd_close+0x6f>
		else
			r = 0;
  8010e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f0:	e8 bb fb ff ff       	call   800cb0 <sys_page_unmap>
	return r;
}
  8010f5:	89 d8                	mov    %ebx,%eax
  8010f7:	83 c4 30             	add    $0x30,%esp
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801104:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801107:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	89 04 24             	mov    %eax,(%esp)
  801111:	e8 b0 fe ff ff       	call   800fc6 <fd_lookup>
  801116:	85 c0                	test   %eax,%eax
  801118:	78 13                	js     80112d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80111a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801121:	00 
  801122:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801125:	89 04 24             	mov    %eax,(%esp)
  801128:	e8 49 ff ff ff       	call   801076 <fd_close>
}
  80112d:	c9                   	leave  
  80112e:	c3                   	ret    

0080112f <close_all>:

void
close_all(void)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	53                   	push   %ebx
  801133:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801136:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80113b:	89 1c 24             	mov    %ebx,(%esp)
  80113e:	e8 bb ff ff ff       	call   8010fe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801143:	43                   	inc    %ebx
  801144:	83 fb 20             	cmp    $0x20,%ebx
  801147:	75 f2                	jne    80113b <close_all+0xc>
		close(i);
}
  801149:	83 c4 14             	add    $0x14,%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
  801155:	83 ec 4c             	sub    $0x4c,%esp
  801158:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80115b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80115e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	89 04 24             	mov    %eax,(%esp)
  801168:	e8 59 fe ff ff       	call   800fc6 <fd_lookup>
  80116d:	89 c3                	mov    %eax,%ebx
  80116f:	85 c0                	test   %eax,%eax
  801171:	0f 88 e3 00 00 00    	js     80125a <dup+0x10b>
		return r;
	close(newfdnum);
  801177:	89 3c 24             	mov    %edi,(%esp)
  80117a:	e8 7f ff ff ff       	call   8010fe <close>

	newfd = INDEX2FD(newfdnum);
  80117f:	89 fe                	mov    %edi,%esi
  801181:	c1 e6 0c             	shl    $0xc,%esi
  801184:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80118a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80118d:	89 04 24             	mov    %eax,(%esp)
  801190:	e8 c3 fd ff ff       	call   800f58 <fd2data>
  801195:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801197:	89 34 24             	mov    %esi,(%esp)
  80119a:	e8 b9 fd ff ff       	call   800f58 <fd2data>
  80119f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011a2:	89 d8                	mov    %ebx,%eax
  8011a4:	c1 e8 16             	shr    $0x16,%eax
  8011a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011ae:	a8 01                	test   $0x1,%al
  8011b0:	74 46                	je     8011f8 <dup+0xa9>
  8011b2:	89 d8                	mov    %ebx,%eax
  8011b4:	c1 e8 0c             	shr    $0xc,%eax
  8011b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011be:	f6 c2 01             	test   $0x1,%dl
  8011c1:	74 35                	je     8011f8 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8011cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e1:	00 
  8011e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ed:	e8 6b fa ff ff       	call   800c5d <sys_page_map>
  8011f2:	89 c3                	mov    %eax,%ebx
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 3b                	js     801233 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	c1 ea 0c             	shr    $0xc,%edx
  801200:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801207:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80120d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801211:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801215:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80121c:	00 
  80121d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801221:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801228:	e8 30 fa ff ff       	call   800c5d <sys_page_map>
  80122d:	89 c3                	mov    %eax,%ebx
  80122f:	85 c0                	test   %eax,%eax
  801231:	79 25                	jns    801258 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801233:	89 74 24 04          	mov    %esi,0x4(%esp)
  801237:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123e:	e8 6d fa ff ff       	call   800cb0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801243:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801251:	e8 5a fa ff ff       	call   800cb0 <sys_page_unmap>
	return r;
  801256:	eb 02                	jmp    80125a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801258:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80125a:	89 d8                	mov    %ebx,%eax
  80125c:	83 c4 4c             	add    $0x4c,%esp
  80125f:	5b                   	pop    %ebx
  801260:	5e                   	pop    %esi
  801261:	5f                   	pop    %edi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 24             	sub    $0x24,%esp
  80126b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801271:	89 44 24 04          	mov    %eax,0x4(%esp)
  801275:	89 1c 24             	mov    %ebx,(%esp)
  801278:	e8 49 fd ff ff       	call   800fc6 <fd_lookup>
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 6d                	js     8012ee <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801281:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801284:	89 44 24 04          	mov    %eax,0x4(%esp)
  801288:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128b:	8b 00                	mov    (%eax),%eax
  80128d:	89 04 24             	mov    %eax,(%esp)
  801290:	e8 87 fd ff ff       	call   80101c <dev_lookup>
  801295:	85 c0                	test   %eax,%eax
  801297:	78 55                	js     8012ee <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129c:	8b 50 08             	mov    0x8(%eax),%edx
  80129f:	83 e2 03             	and    $0x3,%edx
  8012a2:	83 fa 01             	cmp    $0x1,%edx
  8012a5:	75 23                	jne    8012ca <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a7:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ac:	8b 40 48             	mov    0x48(%eax),%eax
  8012af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b7:	c7 04 24 f4 29 80 00 	movl   $0x8029f4,(%esp)
  8012be:	e8 a9 ef ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c8:	eb 24                	jmp    8012ee <read+0x8a>
	}
	if (!dev->dev_read)
  8012ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cd:	8b 52 08             	mov    0x8(%edx),%edx
  8012d0:	85 d2                	test   %edx,%edx
  8012d2:	74 15                	je     8012e9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e2:	89 04 24             	mov    %eax,(%esp)
  8012e5:	ff d2                	call   *%edx
  8012e7:	eb 05                	jmp    8012ee <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012ee:	83 c4 24             	add    $0x24,%esp
  8012f1:	5b                   	pop    %ebx
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    

008012f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	57                   	push   %edi
  8012f8:	56                   	push   %esi
  8012f9:	53                   	push   %ebx
  8012fa:	83 ec 1c             	sub    $0x1c,%esp
  8012fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801300:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801303:	bb 00 00 00 00       	mov    $0x0,%ebx
  801308:	eb 23                	jmp    80132d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80130a:	89 f0                	mov    %esi,%eax
  80130c:	29 d8                	sub    %ebx,%eax
  80130e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801312:	8b 45 0c             	mov    0xc(%ebp),%eax
  801315:	01 d8                	add    %ebx,%eax
  801317:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131b:	89 3c 24             	mov    %edi,(%esp)
  80131e:	e8 41 ff ff ff       	call   801264 <read>
		if (m < 0)
  801323:	85 c0                	test   %eax,%eax
  801325:	78 10                	js     801337 <readn+0x43>
			return m;
		if (m == 0)
  801327:	85 c0                	test   %eax,%eax
  801329:	74 0a                	je     801335 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80132b:	01 c3                	add    %eax,%ebx
  80132d:	39 f3                	cmp    %esi,%ebx
  80132f:	72 d9                	jb     80130a <readn+0x16>
  801331:	89 d8                	mov    %ebx,%eax
  801333:	eb 02                	jmp    801337 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801335:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801337:	83 c4 1c             	add    $0x1c,%esp
  80133a:	5b                   	pop    %ebx
  80133b:	5e                   	pop    %esi
  80133c:	5f                   	pop    %edi
  80133d:	5d                   	pop    %ebp
  80133e:	c3                   	ret    

0080133f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	53                   	push   %ebx
  801343:	83 ec 24             	sub    $0x24,%esp
  801346:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801349:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801350:	89 1c 24             	mov    %ebx,(%esp)
  801353:	e8 6e fc ff ff       	call   800fc6 <fd_lookup>
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 68                	js     8013c4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801363:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801366:	8b 00                	mov    (%eax),%eax
  801368:	89 04 24             	mov    %eax,(%esp)
  80136b:	e8 ac fc ff ff       	call   80101c <dev_lookup>
  801370:	85 c0                	test   %eax,%eax
  801372:	78 50                	js     8013c4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801374:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801377:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80137b:	75 23                	jne    8013a0 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80137d:	a1 08 40 80 00       	mov    0x804008,%eax
  801382:	8b 40 48             	mov    0x48(%eax),%eax
  801385:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138d:	c7 04 24 10 2a 80 00 	movl   $0x802a10,(%esp)
  801394:	e8 d3 ee ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801399:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139e:	eb 24                	jmp    8013c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8013a6:	85 d2                	test   %edx,%edx
  8013a8:	74 15                	je     8013bf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013b8:	89 04 24             	mov    %eax,(%esp)
  8013bb:	ff d2                	call   *%edx
  8013bd:	eb 05                	jmp    8013c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013c4:	83 c4 24             	add    $0x24,%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013da:	89 04 24             	mov    %eax,(%esp)
  8013dd:	e8 e4 fb ff ff       	call   800fc6 <fd_lookup>
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 0e                	js     8013f4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ec:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	53                   	push   %ebx
  8013fa:	83 ec 24             	sub    $0x24,%esp
  8013fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801400:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801403:	89 44 24 04          	mov    %eax,0x4(%esp)
  801407:	89 1c 24             	mov    %ebx,(%esp)
  80140a:	e8 b7 fb ff ff       	call   800fc6 <fd_lookup>
  80140f:	85 c0                	test   %eax,%eax
  801411:	78 61                	js     801474 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801413:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801416:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141d:	8b 00                	mov    (%eax),%eax
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 f5 fb ff ff       	call   80101c <dev_lookup>
  801427:	85 c0                	test   %eax,%eax
  801429:	78 49                	js     801474 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801432:	75 23                	jne    801457 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801434:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801439:	8b 40 48             	mov    0x48(%eax),%eax
  80143c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801440:	89 44 24 04          	mov    %eax,0x4(%esp)
  801444:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  80144b:	e8 1c ee ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801450:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801455:	eb 1d                	jmp    801474 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801457:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80145a:	8b 52 18             	mov    0x18(%edx),%edx
  80145d:	85 d2                	test   %edx,%edx
  80145f:	74 0e                	je     80146f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801461:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801464:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801468:	89 04 24             	mov    %eax,(%esp)
  80146b:	ff d2                	call   *%edx
  80146d:	eb 05                	jmp    801474 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80146f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801474:	83 c4 24             	add    $0x24,%esp
  801477:	5b                   	pop    %ebx
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	53                   	push   %ebx
  80147e:	83 ec 24             	sub    $0x24,%esp
  801481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801484:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801487:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148b:	8b 45 08             	mov    0x8(%ebp),%eax
  80148e:	89 04 24             	mov    %eax,(%esp)
  801491:	e8 30 fb ff ff       	call   800fc6 <fd_lookup>
  801496:	85 c0                	test   %eax,%eax
  801498:	78 52                	js     8014ec <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a4:	8b 00                	mov    (%eax),%eax
  8014a6:	89 04 24             	mov    %eax,(%esp)
  8014a9:	e8 6e fb ff ff       	call   80101c <dev_lookup>
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 3a                	js     8014ec <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8014b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014b9:	74 2c                	je     8014e7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014c5:	00 00 00 
	stat->st_isdir = 0;
  8014c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014cf:	00 00 00 
	stat->st_dev = dev;
  8014d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014df:	89 14 24             	mov    %edx,(%esp)
  8014e2:	ff 50 14             	call   *0x14(%eax)
  8014e5:	eb 05                	jmp    8014ec <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014e7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014ec:	83 c4 24             	add    $0x24,%esp
  8014ef:	5b                   	pop    %ebx
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	56                   	push   %esi
  8014f6:	53                   	push   %ebx
  8014f7:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801501:	00 
  801502:	8b 45 08             	mov    0x8(%ebp),%eax
  801505:	89 04 24             	mov    %eax,(%esp)
  801508:	e8 2a 02 00 00       	call   801737 <open>
  80150d:	89 c3                	mov    %eax,%ebx
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 1b                	js     80152e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801513:	8b 45 0c             	mov    0xc(%ebp),%eax
  801516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151a:	89 1c 24             	mov    %ebx,(%esp)
  80151d:	e8 58 ff ff ff       	call   80147a <fstat>
  801522:	89 c6                	mov    %eax,%esi
	close(fd);
  801524:	89 1c 24             	mov    %ebx,(%esp)
  801527:	e8 d2 fb ff ff       	call   8010fe <close>
	return r;
  80152c:	89 f3                	mov    %esi,%ebx
}
  80152e:	89 d8                	mov    %ebx,%eax
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	5b                   	pop    %ebx
  801534:	5e                   	pop    %esi
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    
	...

00801538 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	56                   	push   %esi
  80153c:	53                   	push   %ebx
  80153d:	83 ec 10             	sub    $0x10,%esp
  801540:	89 c3                	mov    %eax,%ebx
  801542:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801544:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80154b:	75 11                	jne    80155e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80154d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801554:	e8 86 0d 00 00       	call   8022df <ipc_find_env>
  801559:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80155e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801565:	00 
  801566:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80156d:	00 
  80156e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801572:	a1 00 40 80 00       	mov    0x804000,%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 dd 0c 00 00       	call   80225c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80157f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801586:	00 
  801587:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801592:	e8 55 0c 00 00       	call   8021ec <ipc_recv>
}
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5e                   	pop    %esi
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8015c1:	e8 72 ff ff ff       	call   801538 <fsipc>
}
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015de:	b8 06 00 00 00       	mov    $0x6,%eax
  8015e3:	e8 50 ff ff ff       	call   801538 <fsipc>
}
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 14             	sub    $0x14,%esp
  8015f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801604:	b8 05 00 00 00       	mov    $0x5,%eax
  801609:	e8 2a ff ff ff       	call   801538 <fsipc>
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 2b                	js     80163d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801612:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801619:	00 
  80161a:	89 1c 24             	mov    %ebx,(%esp)
  80161d:	e8 f5 f1 ff ff       	call   800817 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801622:	a1 80 50 80 00       	mov    0x805080,%eax
  801627:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80162d:	a1 84 50 80 00       	mov    0x805084,%eax
  801632:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801638:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163d:	83 c4 14             	add    $0x14,%esp
  801640:	5b                   	pop    %ebx
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    

00801643 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	83 ec 18             	sub    $0x18,%esp
  801649:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80164c:	8b 55 08             	mov    0x8(%ebp),%edx
  80164f:	8b 52 0c             	mov    0xc(%edx),%edx
  801652:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801658:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801664:	76 05                	jbe    80166b <devfile_write+0x28>
  801666:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  80166b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80166f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801672:	89 44 24 04          	mov    %eax,0x4(%esp)
  801676:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80167d:	e8 78 f3 ff ff       	call   8009fa <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801682:	ba 00 00 00 00       	mov    $0x0,%edx
  801687:	b8 04 00 00 00       	mov    $0x4,%eax
  80168c:	e8 a7 fe ff ff       	call   801538 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
  801698:	83 ec 10             	sub    $0x10,%esp
  80169b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016a9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016af:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b4:	b8 03 00 00 00       	mov    $0x3,%eax
  8016b9:	e8 7a fe ff ff       	call   801538 <fsipc>
  8016be:	89 c3                	mov    %eax,%ebx
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 6a                	js     80172e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016c4:	39 c6                	cmp    %eax,%esi
  8016c6:	73 24                	jae    8016ec <devfile_read+0x59>
  8016c8:	c7 44 24 0c 44 2a 80 	movl   $0x802a44,0xc(%esp)
  8016cf:	00 
  8016d0:	c7 44 24 08 4b 2a 80 	movl   $0x802a4b,0x8(%esp)
  8016d7:	00 
  8016d8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016df:	00 
  8016e0:	c7 04 24 60 2a 80 00 	movl   $0x802a60,(%esp)
  8016e7:	e8 88 ea ff ff       	call   800174 <_panic>
	assert(r <= PGSIZE);
  8016ec:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016f1:	7e 24                	jle    801717 <devfile_read+0x84>
  8016f3:	c7 44 24 0c 6b 2a 80 	movl   $0x802a6b,0xc(%esp)
  8016fa:	00 
  8016fb:	c7 44 24 08 4b 2a 80 	movl   $0x802a4b,0x8(%esp)
  801702:	00 
  801703:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80170a:	00 
  80170b:	c7 04 24 60 2a 80 00 	movl   $0x802a60,(%esp)
  801712:	e8 5d ea ff ff       	call   800174 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801717:	89 44 24 08          	mov    %eax,0x8(%esp)
  80171b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801722:	00 
  801723:	8b 45 0c             	mov    0xc(%ebp),%eax
  801726:	89 04 24             	mov    %eax,(%esp)
  801729:	e8 62 f2 ff ff       	call   800990 <memmove>
	return r;
}
  80172e:	89 d8                	mov    %ebx,%eax
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	83 ec 20             	sub    $0x20,%esp
  80173f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801742:	89 34 24             	mov    %esi,(%esp)
  801745:	e8 9a f0 ff ff       	call   8007e4 <strlen>
  80174a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80174f:	7f 60                	jg     8017b1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801751:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 17 f8 ff ff       	call   800f73 <fd_alloc>
  80175c:	89 c3                	mov    %eax,%ebx
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 54                	js     8017b6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801762:	89 74 24 04          	mov    %esi,0x4(%esp)
  801766:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80176d:	e8 a5 f0 ff ff       	call   800817 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801772:	8b 45 0c             	mov    0xc(%ebp),%eax
  801775:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80177a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177d:	b8 01 00 00 00       	mov    $0x1,%eax
  801782:	e8 b1 fd ff ff       	call   801538 <fsipc>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	85 c0                	test   %eax,%eax
  80178b:	79 15                	jns    8017a2 <open+0x6b>
		fd_close(fd, 0);
  80178d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801794:	00 
  801795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801798:	89 04 24             	mov    %eax,(%esp)
  80179b:	e8 d6 f8 ff ff       	call   801076 <fd_close>
		return r;
  8017a0:	eb 14                	jmp    8017b6 <open+0x7f>
	}

	return fd2num(fd);
  8017a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a5:	89 04 24             	mov    %eax,(%esp)
  8017a8:	e8 9b f7 ff ff       	call   800f48 <fd2num>
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	eb 05                	jmp    8017b6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017b1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017b6:	89 d8                	mov    %ebx,%eax
  8017b8:	83 c4 20             	add    $0x20,%esp
  8017bb:	5b                   	pop    %ebx
  8017bc:	5e                   	pop    %esi
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ca:	b8 08 00 00 00       	mov    $0x8,%eax
  8017cf:	e8 64 fd ff ff       	call   801538 <fsipc>
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    
	...

008017d8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8017de:	c7 44 24 04 77 2a 80 	movl   $0x802a77,0x4(%esp)
  8017e5:	00 
  8017e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e9:	89 04 24             	mov    %eax,(%esp)
  8017ec:	e8 26 f0 ff ff       	call   800817 <strcpy>
	return 0;
}
  8017f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 14             	sub    $0x14,%esp
  8017ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801802:	89 1c 24             	mov    %ebx,(%esp)
  801805:	e8 1a 0b 00 00       	call   802324 <pageref>
  80180a:	83 f8 01             	cmp    $0x1,%eax
  80180d:	75 0d                	jne    80181c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80180f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801812:	89 04 24             	mov    %eax,(%esp)
  801815:	e8 1f 03 00 00       	call   801b39 <nsipc_close>
  80181a:	eb 05                	jmp    801821 <devsock_close+0x29>
	else
		return 0;
  80181c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801821:	83 c4 14             	add    $0x14,%esp
  801824:	5b                   	pop    %ebx
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80182d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801834:	00 
  801835:	8b 45 10             	mov    0x10(%ebp),%eax
  801838:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	8b 40 0c             	mov    0xc(%eax),%eax
  801849:	89 04 24             	mov    %eax,(%esp)
  80184c:	e8 e3 03 00 00       	call   801c34 <nsipc_send>
}
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801859:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801860:	00 
  801861:	8b 45 10             	mov    0x10(%ebp),%eax
  801864:	89 44 24 08          	mov    %eax,0x8(%esp)
  801868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	8b 40 0c             	mov    0xc(%eax),%eax
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 37 03 00 00       	call   801bb4 <nsipc_recv>
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	83 ec 20             	sub    $0x20,%esp
  801887:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188c:	89 04 24             	mov    %eax,(%esp)
  80188f:	e8 df f6 ff ff       	call   800f73 <fd_alloc>
  801894:	89 c3                	mov    %eax,%ebx
  801896:	85 c0                	test   %eax,%eax
  801898:	78 21                	js     8018bb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80189a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018a1:	00 
  8018a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b0:	e8 54 f3 ff ff       	call   800c09 <sys_page_alloc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	79 0a                	jns    8018c5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8018bb:	89 34 24             	mov    %esi,(%esp)
  8018be:	e8 76 02 00 00       	call   801b39 <nsipc_close>
		return r;
  8018c3:	eb 22                	jmp    8018e7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8018c5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ce:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8018da:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8018dd:	89 04 24             	mov    %eax,(%esp)
  8018e0:	e8 63 f6 ff ff       	call   800f48 <fd2num>
  8018e5:	89 c3                	mov    %eax,%ebx
}
  8018e7:	89 d8                	mov    %ebx,%eax
  8018e9:	83 c4 20             	add    $0x20,%esp
  8018ec:	5b                   	pop    %ebx
  8018ed:	5e                   	pop    %esi
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    

008018f0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018f6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018fd:	89 04 24             	mov    %eax,(%esp)
  801900:	e8 c1 f6 ff ff       	call   800fc6 <fd_lookup>
  801905:	85 c0                	test   %eax,%eax
  801907:	78 17                	js     801920 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801909:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801912:	39 10                	cmp    %edx,(%eax)
  801914:	75 05                	jne    80191b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801916:	8b 40 0c             	mov    0xc(%eax),%eax
  801919:	eb 05                	jmp    801920 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80191b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	e8 c0 ff ff ff       	call   8018f0 <fd2sockid>
  801930:	85 c0                	test   %eax,%eax
  801932:	78 1f                	js     801953 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801934:	8b 55 10             	mov    0x10(%ebp),%edx
  801937:	89 54 24 08          	mov    %edx,0x8(%esp)
  80193b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801942:	89 04 24             	mov    %eax,(%esp)
  801945:	e8 38 01 00 00       	call   801a82 <nsipc_accept>
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 05                	js     801953 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80194e:	e8 2c ff ff ff       	call   80187f <alloc_sockfd>
}
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	e8 8d ff ff ff       	call   8018f0 <fd2sockid>
  801963:	85 c0                	test   %eax,%eax
  801965:	78 16                	js     80197d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801967:	8b 55 10             	mov    0x10(%ebp),%edx
  80196a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80196e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801971:	89 54 24 04          	mov    %edx,0x4(%esp)
  801975:	89 04 24             	mov    %eax,(%esp)
  801978:	e8 5b 01 00 00       	call   801ad8 <nsipc_bind>
}
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <shutdown>:

int
shutdown(int s, int how)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	e8 63 ff ff ff       	call   8018f0 <fd2sockid>
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 0f                	js     8019a0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801991:	8b 55 0c             	mov    0xc(%ebp),%edx
  801994:	89 54 24 04          	mov    %edx,0x4(%esp)
  801998:	89 04 24             	mov    %eax,(%esp)
  80199b:	e8 77 01 00 00       	call   801b17 <nsipc_shutdown>
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	e8 40 ff ff ff       	call   8018f0 <fd2sockid>
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 16                	js     8019ca <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8019b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8019b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019c2:	89 04 24             	mov    %eax,(%esp)
  8019c5:	e8 89 01 00 00       	call   801b53 <nsipc_connect>
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <listen>:

int
listen(int s, int backlog)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d5:	e8 16 ff ff ff       	call   8018f0 <fd2sockid>
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 0f                	js     8019ed <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8019de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019e5:	89 04 24             	mov    %eax,(%esp)
  8019e8:	e8 a5 01 00 00       	call   801b92 <nsipc_listen>
}
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    

008019ef <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	89 04 24             	mov    %eax,(%esp)
  801a09:	e8 99 02 00 00       	call   801ca7 <nsipc_socket>
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 05                	js     801a17 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801a12:	e8 68 fe ff ff       	call   80187f <alloc_sockfd>
}
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    
  801a19:	00 00                	add    %al,(%eax)
	...

00801a1c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 14             	sub    $0x14,%esp
  801a23:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a25:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a2c:	75 11                	jne    801a3f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a2e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801a35:	e8 a5 08 00 00       	call   8022df <ipc_find_env>
  801a3a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a3f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a46:	00 
  801a47:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a4e:	00 
  801a4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a53:	a1 04 40 80 00       	mov    0x804004,%eax
  801a58:	89 04 24             	mov    %eax,(%esp)
  801a5b:	e8 fc 07 00 00       	call   80225c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a67:	00 
  801a68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a6f:	00 
  801a70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a77:	e8 70 07 00 00       	call   8021ec <ipc_recv>
}
  801a7c:	83 c4 14             	add    $0x14,%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	56                   	push   %esi
  801a86:	53                   	push   %ebx
  801a87:	83 ec 10             	sub    $0x10,%esp
  801a8a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a95:	8b 06                	mov    (%esi),%eax
  801a97:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa1:	e8 76 ff ff ff       	call   801a1c <nsipc>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	78 23                	js     801acf <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801aac:	a1 10 60 80 00       	mov    0x806010,%eax
  801ab1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801abc:	00 
  801abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac0:	89 04 24             	mov    %eax,(%esp)
  801ac3:	e8 c8 ee ff ff       	call   800990 <memmove>
		*addrlen = ret->ret_addrlen;
  801ac8:	a1 10 60 80 00       	mov    0x806010,%eax
  801acd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801acf:	89 d8                	mov    %ebx,%eax
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5e                   	pop    %esi
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    

00801ad8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	53                   	push   %ebx
  801adc:	83 ec 14             	sub    $0x14,%esp
  801adf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801aea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af5:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801afc:	e8 8f ee ff ff       	call   800990 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b01:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b07:	b8 02 00 00 00       	mov    $0x2,%eax
  801b0c:	e8 0b ff ff ff       	call   801a1c <nsipc>
}
  801b11:	83 c4 14             	add    $0x14,%esp
  801b14:	5b                   	pop    %ebx
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b28:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b2d:	b8 03 00 00 00       	mov    $0x3,%eax
  801b32:	e8 e5 fe ff ff       	call   801a1c <nsipc>
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <nsipc_close>:

int
nsipc_close(int s)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b42:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b47:	b8 04 00 00 00       	mov    $0x4,%eax
  801b4c:	e8 cb fe ff ff       	call   801a1c <nsipc>
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	53                   	push   %ebx
  801b57:	83 ec 14             	sub    $0x14,%esp
  801b5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b60:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b65:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b70:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801b77:	e8 14 ee ff ff       	call   800990 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b7c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b82:	b8 05 00 00 00       	mov    $0x5,%eax
  801b87:	e8 90 fe ff ff       	call   801a1c <nsipc>
}
  801b8c:	83 c4 14             	add    $0x14,%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5d                   	pop    %ebp
  801b91:	c3                   	ret    

00801b92 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ba8:	b8 06 00 00 00       	mov    $0x6,%eax
  801bad:	e8 6a fe ff ff       	call   801a1c <nsipc>
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	83 ec 10             	sub    $0x10,%esp
  801bbc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bc7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bcd:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bd5:	b8 07 00 00 00       	mov    $0x7,%eax
  801bda:	e8 3d fe ff ff       	call   801a1c <nsipc>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	85 c0                	test   %eax,%eax
  801be3:	78 46                	js     801c2b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801be5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bea:	7f 04                	jg     801bf0 <nsipc_recv+0x3c>
  801bec:	39 c6                	cmp    %eax,%esi
  801bee:	7d 24                	jge    801c14 <nsipc_recv+0x60>
  801bf0:	c7 44 24 0c 83 2a 80 	movl   $0x802a83,0xc(%esp)
  801bf7:	00 
  801bf8:	c7 44 24 08 4b 2a 80 	movl   $0x802a4b,0x8(%esp)
  801bff:	00 
  801c00:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801c07:	00 
  801c08:	c7 04 24 98 2a 80 00 	movl   $0x802a98,(%esp)
  801c0f:	e8 60 e5 ff ff       	call   800174 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c14:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c18:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c1f:	00 
  801c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c23:	89 04 24             	mov    %eax,(%esp)
  801c26:	e8 65 ed ff ff       	call   800990 <memmove>
	}

	return r;
}
  801c2b:	89 d8                	mov    %ebx,%eax
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    

00801c34 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	53                   	push   %ebx
  801c38:	83 ec 14             	sub    $0x14,%esp
  801c3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c41:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c46:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c4c:	7e 24                	jle    801c72 <nsipc_send+0x3e>
  801c4e:	c7 44 24 0c a4 2a 80 	movl   $0x802aa4,0xc(%esp)
  801c55:	00 
  801c56:	c7 44 24 08 4b 2a 80 	movl   $0x802a4b,0x8(%esp)
  801c5d:	00 
  801c5e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801c65:	00 
  801c66:	c7 04 24 98 2a 80 00 	movl   $0x802a98,(%esp)
  801c6d:	e8 02 e5 ff ff       	call   800174 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c72:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801c84:	e8 07 ed ff ff       	call   800990 <memmove>
	nsipcbuf.send.req_size = size;
  801c89:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c8f:	8b 45 14             	mov    0x14(%ebp),%eax
  801c92:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c97:	b8 08 00 00 00       	mov    $0x8,%eax
  801c9c:	e8 7b fd ff ff       	call   801a1c <nsipc>
}
  801ca1:	83 c4 14             	add    $0x14,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cad:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cbd:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  801cca:	e8 4d fd ff ff       	call   801a1c <nsipc>
}
  801ccf:	c9                   	leave  
  801cd0:	c3                   	ret    
  801cd1:	00 00                	add    %al,(%eax)
	...

00801cd4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 10             	sub    $0x10,%esp
  801cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	89 04 24             	mov    %eax,(%esp)
  801ce5:	e8 6e f2 ff ff       	call   800f58 <fd2data>
  801cea:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801cec:	c7 44 24 04 b0 2a 80 	movl   $0x802ab0,0x4(%esp)
  801cf3:	00 
  801cf4:	89 34 24             	mov    %esi,(%esp)
  801cf7:	e8 1b eb ff ff       	call   800817 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cfc:	8b 43 04             	mov    0x4(%ebx),%eax
  801cff:	2b 03                	sub    (%ebx),%eax
  801d01:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801d07:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801d0e:	00 00 00 
	stat->st_dev = &devpipe;
  801d11:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801d18:	30 80 00 
	return 0;
}
  801d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d20:	83 c4 10             	add    $0x10,%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	53                   	push   %ebx
  801d2b:	83 ec 14             	sub    $0x14,%esp
  801d2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d3c:	e8 6f ef ff ff       	call   800cb0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d41:	89 1c 24             	mov    %ebx,(%esp)
  801d44:	e8 0f f2 ff ff       	call   800f58 <fd2data>
  801d49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d54:	e8 57 ef ff ff       	call   800cb0 <sys_page_unmap>
}
  801d59:	83 c4 14             	add    $0x14,%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	57                   	push   %edi
  801d63:	56                   	push   %esi
  801d64:	53                   	push   %ebx
  801d65:	83 ec 2c             	sub    $0x2c,%esp
  801d68:	89 c7                	mov    %eax,%edi
  801d6a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d6d:	a1 08 40 80 00       	mov    0x804008,%eax
  801d72:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d75:	89 3c 24             	mov    %edi,(%esp)
  801d78:	e8 a7 05 00 00       	call   802324 <pageref>
  801d7d:	89 c6                	mov    %eax,%esi
  801d7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d82:	89 04 24             	mov    %eax,(%esp)
  801d85:	e8 9a 05 00 00       	call   802324 <pageref>
  801d8a:	39 c6                	cmp    %eax,%esi
  801d8c:	0f 94 c0             	sete   %al
  801d8f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d92:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d98:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d9b:	39 cb                	cmp    %ecx,%ebx
  801d9d:	75 08                	jne    801da7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d9f:	83 c4 2c             	add    $0x2c,%esp
  801da2:	5b                   	pop    %ebx
  801da3:	5e                   	pop    %esi
  801da4:	5f                   	pop    %edi
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801da7:	83 f8 01             	cmp    $0x1,%eax
  801daa:	75 c1                	jne    801d6d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dac:	8b 42 58             	mov    0x58(%edx),%eax
  801daf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801db6:	00 
  801db7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dbf:	c7 04 24 b7 2a 80 00 	movl   $0x802ab7,(%esp)
  801dc6:	e8 a1 e4 ff ff       	call   80026c <cprintf>
  801dcb:	eb a0                	jmp    801d6d <_pipeisclosed+0xe>

00801dcd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	57                   	push   %edi
  801dd1:	56                   	push   %esi
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 1c             	sub    $0x1c,%esp
  801dd6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dd9:	89 34 24             	mov    %esi,(%esp)
  801ddc:	e8 77 f1 ff ff       	call   800f58 <fd2data>
  801de1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de3:	bf 00 00 00 00       	mov    $0x0,%edi
  801de8:	eb 3c                	jmp    801e26 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dea:	89 da                	mov    %ebx,%edx
  801dec:	89 f0                	mov    %esi,%eax
  801dee:	e8 6c ff ff ff       	call   801d5f <_pipeisclosed>
  801df3:	85 c0                	test   %eax,%eax
  801df5:	75 38                	jne    801e2f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801df7:	e8 ee ed ff ff       	call   800bea <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dfc:	8b 43 04             	mov    0x4(%ebx),%eax
  801dff:	8b 13                	mov    (%ebx),%edx
  801e01:	83 c2 20             	add    $0x20,%edx
  801e04:	39 d0                	cmp    %edx,%eax
  801e06:	73 e2                	jae    801dea <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e0b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801e0e:	89 c2                	mov    %eax,%edx
  801e10:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e16:	79 05                	jns    801e1d <devpipe_write+0x50>
  801e18:	4a                   	dec    %edx
  801e19:	83 ca e0             	or     $0xffffffe0,%edx
  801e1c:	42                   	inc    %edx
  801e1d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e21:	40                   	inc    %eax
  801e22:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e25:	47                   	inc    %edi
  801e26:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e29:	75 d1                	jne    801dfc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e2b:	89 f8                	mov    %edi,%eax
  801e2d:	eb 05                	jmp    801e34 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e34:	83 c4 1c             	add    $0x1c,%esp
  801e37:	5b                   	pop    %ebx
  801e38:	5e                   	pop    %esi
  801e39:	5f                   	pop    %edi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    

00801e3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	57                   	push   %edi
  801e40:	56                   	push   %esi
  801e41:	53                   	push   %ebx
  801e42:	83 ec 1c             	sub    $0x1c,%esp
  801e45:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e48:	89 3c 24             	mov    %edi,(%esp)
  801e4b:	e8 08 f1 ff ff       	call   800f58 <fd2data>
  801e50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e52:	be 00 00 00 00       	mov    $0x0,%esi
  801e57:	eb 3a                	jmp    801e93 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e59:	85 f6                	test   %esi,%esi
  801e5b:	74 04                	je     801e61 <devpipe_read+0x25>
				return i;
  801e5d:	89 f0                	mov    %esi,%eax
  801e5f:	eb 40                	jmp    801ea1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e61:	89 da                	mov    %ebx,%edx
  801e63:	89 f8                	mov    %edi,%eax
  801e65:	e8 f5 fe ff ff       	call   801d5f <_pipeisclosed>
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	75 2e                	jne    801e9c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e6e:	e8 77 ed ff ff       	call   800bea <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e73:	8b 03                	mov    (%ebx),%eax
  801e75:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e78:	74 df                	je     801e59 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e7a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e7f:	79 05                	jns    801e86 <devpipe_read+0x4a>
  801e81:	48                   	dec    %eax
  801e82:	83 c8 e0             	or     $0xffffffe0,%eax
  801e85:	40                   	inc    %eax
  801e86:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e8d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e90:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e92:	46                   	inc    %esi
  801e93:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e96:	75 db                	jne    801e73 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e98:	89 f0                	mov    %esi,%eax
  801e9a:	eb 05                	jmp    801ea1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e9c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ea1:	83 c4 1c             	add    $0x1c,%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5f                   	pop    %edi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	57                   	push   %edi
  801ead:	56                   	push   %esi
  801eae:	53                   	push   %ebx
  801eaf:	83 ec 3c             	sub    $0x3c,%esp
  801eb2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801eb5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801eb8:	89 04 24             	mov    %eax,(%esp)
  801ebb:	e8 b3 f0 ff ff       	call   800f73 <fd_alloc>
  801ec0:	89 c3                	mov    %eax,%ebx
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	0f 88 45 01 00 00    	js     80200f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ed1:	00 
  801ed2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee0:	e8 24 ed ff ff       	call   800c09 <sys_page_alloc>
  801ee5:	89 c3                	mov    %eax,%ebx
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	0f 88 20 01 00 00    	js     80200f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801eef:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ef2:	89 04 24             	mov    %eax,(%esp)
  801ef5:	e8 79 f0 ff ff       	call   800f73 <fd_alloc>
  801efa:	89 c3                	mov    %eax,%ebx
  801efc:	85 c0                	test   %eax,%eax
  801efe:	0f 88 f8 00 00 00    	js     801ffc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f04:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f0b:	00 
  801f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f1a:	e8 ea ec ff ff       	call   800c09 <sys_page_alloc>
  801f1f:	89 c3                	mov    %eax,%ebx
  801f21:	85 c0                	test   %eax,%eax
  801f23:	0f 88 d3 00 00 00    	js     801ffc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2c:	89 04 24             	mov    %eax,(%esp)
  801f2f:	e8 24 f0 ff ff       	call   800f58 <fd2data>
  801f34:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f3d:	00 
  801f3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f49:	e8 bb ec ff ff       	call   800c09 <sys_page_alloc>
  801f4e:	89 c3                	mov    %eax,%ebx
  801f50:	85 c0                	test   %eax,%eax
  801f52:	0f 88 91 00 00 00    	js     801fe9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f5b:	89 04 24             	mov    %eax,(%esp)
  801f5e:	e8 f5 ef ff ff       	call   800f58 <fd2data>
  801f63:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f6a:	00 
  801f6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f76:	00 
  801f77:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f82:	e8 d6 ec ff ff       	call   800c5d <sys_page_map>
  801f87:	89 c3                	mov    %eax,%ebx
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 4c                	js     801fd9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f8d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f96:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f9b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fa2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fab:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fb0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fba:	89 04 24             	mov    %eax,(%esp)
  801fbd:	e8 86 ef ff ff       	call   800f48 <fd2num>
  801fc2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801fc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fc7:	89 04 24             	mov    %eax,(%esp)
  801fca:	e8 79 ef ff ff       	call   800f48 <fd2num>
  801fcf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801fd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fd7:	eb 36                	jmp    80200f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801fd9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe4:	e8 c7 ec ff ff       	call   800cb0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fe9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff7:	e8 b4 ec ff ff       	call   800cb0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802003:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200a:	e8 a1 ec ff ff       	call   800cb0 <sys_page_unmap>
    err:
	return r;
}
  80200f:	89 d8                	mov    %ebx,%eax
  802011:	83 c4 3c             	add    $0x3c,%esp
  802014:	5b                   	pop    %ebx
  802015:	5e                   	pop    %esi
  802016:	5f                   	pop    %edi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80201f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802022:	89 44 24 04          	mov    %eax,0x4(%esp)
  802026:	8b 45 08             	mov    0x8(%ebp),%eax
  802029:	89 04 24             	mov    %eax,(%esp)
  80202c:	e8 95 ef ff ff       	call   800fc6 <fd_lookup>
  802031:	85 c0                	test   %eax,%eax
  802033:	78 15                	js     80204a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802035:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802038:	89 04 24             	mov    %eax,(%esp)
  80203b:	e8 18 ef ff ff       	call   800f58 <fd2data>
	return _pipeisclosed(fd, p);
  802040:	89 c2                	mov    %eax,%edx
  802042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802045:	e8 15 fd ff ff       	call   801d5f <_pipeisclosed>
}
  80204a:	c9                   	leave  
  80204b:	c3                   	ret    

0080204c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80204f:	b8 00 00 00 00       	mov    $0x0,%eax
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    

00802056 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80205c:	c7 44 24 04 cf 2a 80 	movl   $0x802acf,0x4(%esp)
  802063:	00 
  802064:	8b 45 0c             	mov    0xc(%ebp),%eax
  802067:	89 04 24             	mov    %eax,(%esp)
  80206a:	e8 a8 e7 ff ff       	call   800817 <strcpy>
	return 0;
}
  80206f:	b8 00 00 00 00       	mov    $0x0,%eax
  802074:	c9                   	leave  
  802075:	c3                   	ret    

00802076 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	57                   	push   %edi
  80207a:	56                   	push   %esi
  80207b:	53                   	push   %ebx
  80207c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802082:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802087:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80208d:	eb 30                	jmp    8020bf <devcons_write+0x49>
		m = n - tot;
  80208f:	8b 75 10             	mov    0x10(%ebp),%esi
  802092:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802094:	83 fe 7f             	cmp    $0x7f,%esi
  802097:	76 05                	jbe    80209e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802099:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80209e:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020a2:	03 45 0c             	add    0xc(%ebp),%eax
  8020a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a9:	89 3c 24             	mov    %edi,(%esp)
  8020ac:	e8 df e8 ff ff       	call   800990 <memmove>
		sys_cputs(buf, m);
  8020b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020b5:	89 3c 24             	mov    %edi,(%esp)
  8020b8:	e8 7f ea ff ff       	call   800b3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020bd:	01 f3                	add    %esi,%ebx
  8020bf:	89 d8                	mov    %ebx,%eax
  8020c1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020c4:	72 c9                	jb     80208f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020c6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020cc:	5b                   	pop    %ebx
  8020cd:	5e                   	pop    %esi
  8020ce:	5f                   	pop    %edi
  8020cf:	5d                   	pop    %ebp
  8020d0:	c3                   	ret    

008020d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020d1:	55                   	push   %ebp
  8020d2:	89 e5                	mov    %esp,%ebp
  8020d4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8020d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020db:	75 07                	jne    8020e4 <devcons_read+0x13>
  8020dd:	eb 25                	jmp    802104 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020df:	e8 06 eb ff ff       	call   800bea <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020e4:	e8 71 ea ff ff       	call   800b5a <sys_cgetc>
  8020e9:	85 c0                	test   %eax,%eax
  8020eb:	74 f2                	je     8020df <devcons_read+0xe>
  8020ed:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8020ef:	85 c0                	test   %eax,%eax
  8020f1:	78 1d                	js     802110 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020f3:	83 f8 04             	cmp    $0x4,%eax
  8020f6:	74 13                	je     80210b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8020f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fb:	88 10                	mov    %dl,(%eax)
	return 1;
  8020fd:	b8 01 00 00 00       	mov    $0x1,%eax
  802102:	eb 0c                	jmp    802110 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802104:	b8 00 00 00 00       	mov    $0x0,%eax
  802109:	eb 05                	jmp    802110 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80210b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802110:	c9                   	leave  
  802111:	c3                   	ret    

00802112 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802118:	8b 45 08             	mov    0x8(%ebp),%eax
  80211b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80211e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802125:	00 
  802126:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802129:	89 04 24             	mov    %eax,(%esp)
  80212c:	e8 0b ea ff ff       	call   800b3c <sys_cputs>
}
  802131:	c9                   	leave  
  802132:	c3                   	ret    

00802133 <getchar>:

int
getchar(void)
{
  802133:	55                   	push   %ebp
  802134:	89 e5                	mov    %esp,%ebp
  802136:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802139:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802140:	00 
  802141:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802144:	89 44 24 04          	mov    %eax,0x4(%esp)
  802148:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80214f:	e8 10 f1 ff ff       	call   801264 <read>
	if (r < 0)
  802154:	85 c0                	test   %eax,%eax
  802156:	78 0f                	js     802167 <getchar+0x34>
		return r;
	if (r < 1)
  802158:	85 c0                	test   %eax,%eax
  80215a:	7e 06                	jle    802162 <getchar+0x2f>
		return -E_EOF;
	return c;
  80215c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802160:	eb 05                	jmp    802167 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802162:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802167:	c9                   	leave  
  802168:	c3                   	ret    

00802169 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80216f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802172:	89 44 24 04          	mov    %eax,0x4(%esp)
  802176:	8b 45 08             	mov    0x8(%ebp),%eax
  802179:	89 04 24             	mov    %eax,(%esp)
  80217c:	e8 45 ee ff ff       	call   800fc6 <fd_lookup>
  802181:	85 c0                	test   %eax,%eax
  802183:	78 11                	js     802196 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802188:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80218e:	39 10                	cmp    %edx,(%eax)
  802190:	0f 94 c0             	sete   %al
  802193:	0f b6 c0             	movzbl %al,%eax
}
  802196:	c9                   	leave  
  802197:	c3                   	ret    

00802198 <opencons>:

int
opencons(void)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80219e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a1:	89 04 24             	mov    %eax,(%esp)
  8021a4:	e8 ca ed ff ff       	call   800f73 <fd_alloc>
  8021a9:	85 c0                	test   %eax,%eax
  8021ab:	78 3c                	js     8021e9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ad:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021b4:	00 
  8021b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c3:	e8 41 ea ff ff       	call   800c09 <sys_page_alloc>
  8021c8:	85 c0                	test   %eax,%eax
  8021ca:	78 1d                	js     8021e9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021cc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021da:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021e1:	89 04 24             	mov    %eax,(%esp)
  8021e4:	e8 5f ed ff ff       	call   800f48 <fd2num>
}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    
	...

008021ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	56                   	push   %esi
  8021f0:	53                   	push   %ebx
  8021f1:	83 ec 10             	sub    $0x10,%esp
  8021f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8021f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8021fd:	85 c0                	test   %eax,%eax
  8021ff:	74 0a                	je     80220b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802201:	89 04 24             	mov    %eax,(%esp)
  802204:	e8 16 ec ff ff       	call   800e1f <sys_ipc_recv>
  802209:	eb 0c                	jmp    802217 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80220b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802212:	e8 08 ec ff ff       	call   800e1f <sys_ipc_recv>
	}
	if (r < 0)
  802217:	85 c0                	test   %eax,%eax
  802219:	79 16                	jns    802231 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80221b:	85 db                	test   %ebx,%ebx
  80221d:	74 06                	je     802225 <ipc_recv+0x39>
  80221f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802225:	85 f6                	test   %esi,%esi
  802227:	74 2c                	je     802255 <ipc_recv+0x69>
  802229:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80222f:	eb 24                	jmp    802255 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802231:	85 db                	test   %ebx,%ebx
  802233:	74 0a                	je     80223f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802235:	a1 08 40 80 00       	mov    0x804008,%eax
  80223a:	8b 40 74             	mov    0x74(%eax),%eax
  80223d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80223f:	85 f6                	test   %esi,%esi
  802241:	74 0a                	je     80224d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802243:	a1 08 40 80 00       	mov    0x804008,%eax
  802248:	8b 40 78             	mov    0x78(%eax),%eax
  80224b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80224d:	a1 08 40 80 00       	mov    0x804008,%eax
  802252:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802255:	83 c4 10             	add    $0x10,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    

0080225c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	57                   	push   %edi
  802260:	56                   	push   %esi
  802261:	53                   	push   %ebx
  802262:	83 ec 1c             	sub    $0x1c,%esp
  802265:	8b 75 08             	mov    0x8(%ebp),%esi
  802268:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80226b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80226e:	85 db                	test   %ebx,%ebx
  802270:	74 19                	je     80228b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802272:	8b 45 14             	mov    0x14(%ebp),%eax
  802275:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802279:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80227d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802281:	89 34 24             	mov    %esi,(%esp)
  802284:	e8 73 eb ff ff       	call   800dfc <sys_ipc_try_send>
  802289:	eb 1c                	jmp    8022a7 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80228b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802292:	00 
  802293:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80229a:	ee 
  80229b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80229f:	89 34 24             	mov    %esi,(%esp)
  8022a2:	e8 55 eb ff ff       	call   800dfc <sys_ipc_try_send>
		}
		if (r == 0)
  8022a7:	85 c0                	test   %eax,%eax
  8022a9:	74 2c                	je     8022d7 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8022ab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022ae:	74 20                	je     8022d0 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8022b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022b4:	c7 44 24 08 db 2a 80 	movl   $0x802adb,0x8(%esp)
  8022bb:	00 
  8022bc:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8022c3:	00 
  8022c4:	c7 04 24 ee 2a 80 00 	movl   $0x802aee,(%esp)
  8022cb:	e8 a4 de ff ff       	call   800174 <_panic>
		}
		sys_yield();
  8022d0:	e8 15 e9 ff ff       	call   800bea <sys_yield>
	}
  8022d5:	eb 97                	jmp    80226e <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8022d7:	83 c4 1c             	add    $0x1c,%esp
  8022da:	5b                   	pop    %ebx
  8022db:	5e                   	pop    %esi
  8022dc:	5f                   	pop    %edi
  8022dd:	5d                   	pop    %ebp
  8022de:	c3                   	ret    

008022df <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022df:	55                   	push   %ebp
  8022e0:	89 e5                	mov    %esp,%ebp
  8022e2:	53                   	push   %ebx
  8022e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8022e6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022eb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8022f2:	89 c2                	mov    %eax,%edx
  8022f4:	c1 e2 07             	shl    $0x7,%edx
  8022f7:	29 ca                	sub    %ecx,%edx
  8022f9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022ff:	8b 52 50             	mov    0x50(%edx),%edx
  802302:	39 da                	cmp    %ebx,%edx
  802304:	75 0f                	jne    802315 <ipc_find_env+0x36>
			return envs[i].env_id;
  802306:	c1 e0 07             	shl    $0x7,%eax
  802309:	29 c8                	sub    %ecx,%eax
  80230b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802310:	8b 40 40             	mov    0x40(%eax),%eax
  802313:	eb 0c                	jmp    802321 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802315:	40                   	inc    %eax
  802316:	3d 00 04 00 00       	cmp    $0x400,%eax
  80231b:	75 ce                	jne    8022eb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80231d:	66 b8 00 00          	mov    $0x0,%ax
}
  802321:	5b                   	pop    %ebx
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    

00802324 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802324:	55                   	push   %ebp
  802325:	89 e5                	mov    %esp,%ebp
  802327:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80232a:	89 c2                	mov    %eax,%edx
  80232c:	c1 ea 16             	shr    $0x16,%edx
  80232f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802336:	f6 c2 01             	test   $0x1,%dl
  802339:	74 1e                	je     802359 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80233b:	c1 e8 0c             	shr    $0xc,%eax
  80233e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802345:	a8 01                	test   $0x1,%al
  802347:	74 17                	je     802360 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802349:	c1 e8 0c             	shr    $0xc,%eax
  80234c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802353:	ef 
  802354:	0f b7 c0             	movzwl %ax,%eax
  802357:	eb 0c                	jmp    802365 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802359:	b8 00 00 00 00       	mov    $0x0,%eax
  80235e:	eb 05                	jmp    802365 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802360:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802365:	5d                   	pop    %ebp
  802366:	c3                   	ret    
	...

00802368 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802368:	55                   	push   %ebp
  802369:	57                   	push   %edi
  80236a:	56                   	push   %esi
  80236b:	83 ec 10             	sub    $0x10,%esp
  80236e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802372:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80237a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80237e:	89 cd                	mov    %ecx,%ebp
  802380:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802384:	85 c0                	test   %eax,%eax
  802386:	75 2c                	jne    8023b4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802388:	39 f9                	cmp    %edi,%ecx
  80238a:	77 68                	ja     8023f4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80238c:	85 c9                	test   %ecx,%ecx
  80238e:	75 0b                	jne    80239b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802390:	b8 01 00 00 00       	mov    $0x1,%eax
  802395:	31 d2                	xor    %edx,%edx
  802397:	f7 f1                	div    %ecx
  802399:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	89 f8                	mov    %edi,%eax
  80239f:	f7 f1                	div    %ecx
  8023a1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023a3:	89 f0                	mov    %esi,%eax
  8023a5:	f7 f1                	div    %ecx
  8023a7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023a9:	89 f0                	mov    %esi,%eax
  8023ab:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023ad:	83 c4 10             	add    $0x10,%esp
  8023b0:	5e                   	pop    %esi
  8023b1:	5f                   	pop    %edi
  8023b2:	5d                   	pop    %ebp
  8023b3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023b4:	39 f8                	cmp    %edi,%eax
  8023b6:	77 2c                	ja     8023e4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023b8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8023bb:	83 f6 1f             	xor    $0x1f,%esi
  8023be:	75 4c                	jne    80240c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023c0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023c2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023c7:	72 0a                	jb     8023d3 <__udivdi3+0x6b>
  8023c9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8023cd:	0f 87 ad 00 00 00    	ja     802480 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023d3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023d8:	89 f0                	mov    %esi,%eax
  8023da:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023dc:	83 c4 10             	add    $0x10,%esp
  8023df:	5e                   	pop    %esi
  8023e0:	5f                   	pop    %edi
  8023e1:	5d                   	pop    %ebp
  8023e2:	c3                   	ret    
  8023e3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023e4:	31 ff                	xor    %edi,%edi
  8023e6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023e8:	89 f0                	mov    %esi,%eax
  8023ea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023ec:	83 c4 10             	add    $0x10,%esp
  8023ef:	5e                   	pop    %esi
  8023f0:	5f                   	pop    %edi
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    
  8023f3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023f4:	89 fa                	mov    %edi,%edx
  8023f6:	89 f0                	mov    %esi,%eax
  8023f8:	f7 f1                	div    %ecx
  8023fa:	89 c6                	mov    %eax,%esi
  8023fc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023fe:	89 f0                	mov    %esi,%eax
  802400:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802402:	83 c4 10             	add    $0x10,%esp
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    
  802409:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80240c:	89 f1                	mov    %esi,%ecx
  80240e:	d3 e0                	shl    %cl,%eax
  802410:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802414:	b8 20 00 00 00       	mov    $0x20,%eax
  802419:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80241b:	89 ea                	mov    %ebp,%edx
  80241d:	88 c1                	mov    %al,%cl
  80241f:	d3 ea                	shr    %cl,%edx
  802421:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802425:	09 ca                	or     %ecx,%edx
  802427:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80242b:	89 f1                	mov    %esi,%ecx
  80242d:	d3 e5                	shl    %cl,%ebp
  80242f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802433:	89 fd                	mov    %edi,%ebp
  802435:	88 c1                	mov    %al,%cl
  802437:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802439:	89 fa                	mov    %edi,%edx
  80243b:	89 f1                	mov    %esi,%ecx
  80243d:	d3 e2                	shl    %cl,%edx
  80243f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802443:	88 c1                	mov    %al,%cl
  802445:	d3 ef                	shr    %cl,%edi
  802447:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802449:	89 f8                	mov    %edi,%eax
  80244b:	89 ea                	mov    %ebp,%edx
  80244d:	f7 74 24 08          	divl   0x8(%esp)
  802451:	89 d1                	mov    %edx,%ecx
  802453:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802455:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802459:	39 d1                	cmp    %edx,%ecx
  80245b:	72 17                	jb     802474 <__udivdi3+0x10c>
  80245d:	74 09                	je     802468 <__udivdi3+0x100>
  80245f:	89 fe                	mov    %edi,%esi
  802461:	31 ff                	xor    %edi,%edi
  802463:	e9 41 ff ff ff       	jmp    8023a9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802468:	8b 54 24 04          	mov    0x4(%esp),%edx
  80246c:	89 f1                	mov    %esi,%ecx
  80246e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802470:	39 c2                	cmp    %eax,%edx
  802472:	73 eb                	jae    80245f <__udivdi3+0xf7>
		{
		  q0--;
  802474:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802477:	31 ff                	xor    %edi,%edi
  802479:	e9 2b ff ff ff       	jmp    8023a9 <__udivdi3+0x41>
  80247e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802480:	31 f6                	xor    %esi,%esi
  802482:	e9 22 ff ff ff       	jmp    8023a9 <__udivdi3+0x41>
	...

00802488 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802488:	55                   	push   %ebp
  802489:	57                   	push   %edi
  80248a:	56                   	push   %esi
  80248b:	83 ec 20             	sub    $0x20,%esp
  80248e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802492:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802496:	89 44 24 14          	mov    %eax,0x14(%esp)
  80249a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80249e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024a2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8024a6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8024a8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024aa:	85 ed                	test   %ebp,%ebp
  8024ac:	75 16                	jne    8024c4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8024ae:	39 f1                	cmp    %esi,%ecx
  8024b0:	0f 86 a6 00 00 00    	jbe    80255c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024b6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8024b8:	89 d0                	mov    %edx,%eax
  8024ba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024bc:	83 c4 20             	add    $0x20,%esp
  8024bf:	5e                   	pop    %esi
  8024c0:	5f                   	pop    %edi
  8024c1:	5d                   	pop    %ebp
  8024c2:	c3                   	ret    
  8024c3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024c4:	39 f5                	cmp    %esi,%ebp
  8024c6:	0f 87 ac 00 00 00    	ja     802578 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024cc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8024cf:	83 f0 1f             	xor    $0x1f,%eax
  8024d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8024d6:	0f 84 a8 00 00 00    	je     802584 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024dc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024e0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024e2:	bf 20 00 00 00       	mov    $0x20,%edi
  8024e7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8024eb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024ef:	89 f9                	mov    %edi,%ecx
  8024f1:	d3 e8                	shr    %cl,%eax
  8024f3:	09 e8                	or     %ebp,%eax
  8024f5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8024f9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024fd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802501:	d3 e0                	shl    %cl,%eax
  802503:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802507:	89 f2                	mov    %esi,%edx
  802509:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80250b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80250f:	d3 e0                	shl    %cl,%eax
  802511:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802515:	8b 44 24 14          	mov    0x14(%esp),%eax
  802519:	89 f9                	mov    %edi,%ecx
  80251b:	d3 e8                	shr    %cl,%eax
  80251d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80251f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802521:	89 f2                	mov    %esi,%edx
  802523:	f7 74 24 18          	divl   0x18(%esp)
  802527:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802529:	f7 64 24 0c          	mull   0xc(%esp)
  80252d:	89 c5                	mov    %eax,%ebp
  80252f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802531:	39 d6                	cmp    %edx,%esi
  802533:	72 67                	jb     80259c <__umoddi3+0x114>
  802535:	74 75                	je     8025ac <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802537:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80253b:	29 e8                	sub    %ebp,%eax
  80253d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80253f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802543:	d3 e8                	shr    %cl,%eax
  802545:	89 f2                	mov    %esi,%edx
  802547:	89 f9                	mov    %edi,%ecx
  802549:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80254b:	09 d0                	or     %edx,%eax
  80254d:	89 f2                	mov    %esi,%edx
  80254f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802553:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802555:	83 c4 20             	add    $0x20,%esp
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80255c:	85 c9                	test   %ecx,%ecx
  80255e:	75 0b                	jne    80256b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802560:	b8 01 00 00 00       	mov    $0x1,%eax
  802565:	31 d2                	xor    %edx,%edx
  802567:	f7 f1                	div    %ecx
  802569:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80256b:	89 f0                	mov    %esi,%eax
  80256d:	31 d2                	xor    %edx,%edx
  80256f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802571:	89 f8                	mov    %edi,%eax
  802573:	e9 3e ff ff ff       	jmp    8024b6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802578:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80257a:	83 c4 20             	add    $0x20,%esp
  80257d:	5e                   	pop    %esi
  80257e:	5f                   	pop    %edi
  80257f:	5d                   	pop    %ebp
  802580:	c3                   	ret    
  802581:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802584:	39 f5                	cmp    %esi,%ebp
  802586:	72 04                	jb     80258c <__umoddi3+0x104>
  802588:	39 f9                	cmp    %edi,%ecx
  80258a:	77 06                	ja     802592 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80258c:	89 f2                	mov    %esi,%edx
  80258e:	29 cf                	sub    %ecx,%edi
  802590:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802592:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802594:	83 c4 20             	add    $0x20,%esp
  802597:	5e                   	pop    %esi
  802598:	5f                   	pop    %edi
  802599:	5d                   	pop    %ebp
  80259a:	c3                   	ret    
  80259b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80259c:	89 d1                	mov    %edx,%ecx
  80259e:	89 c5                	mov    %eax,%ebp
  8025a0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8025a4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8025a8:	eb 8d                	jmp    802537 <__umoddi3+0xaf>
  8025aa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025ac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8025b0:	72 ea                	jb     80259c <__umoddi3+0x114>
  8025b2:	89 f1                	mov    %esi,%ecx
  8025b4:	eb 81                	jmp    802537 <__umoddi3+0xaf>
