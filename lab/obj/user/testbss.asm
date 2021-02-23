
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  800041:	e8 1e 02 00 00       	call   800264 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 bb 25 80 	movl   $0x8025bb,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 d8 25 80 00 	movl   $0x8025d8,(%esp)
  800070:	e8 f7 00 00 00       	call   80016c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	40                   	inc    %eax
  800076:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007b:	75 ce                	jne    80004b <umain+0x17>
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800082:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800089:	40                   	inc    %eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 f1                	jne    800082 <umain+0x4e>
  800091:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800096:	39 04 85 20 40 80 00 	cmp    %eax,0x804020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 d8 25 80 00 	movl   $0x8025d8,(%esp)
  8000ba:	e8 ad 00 00 00       	call   80016c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000bf:	40                   	inc    %eax
  8000c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c5:	75 cf                	jne    800096 <umain+0x62>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000c7:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  8000ce:	e8 91 01 00 00       	call   800264 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 e7 25 80 	movl   $0x8025e7,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 d8 25 80 00 	movl   $0x8025d8,(%esp)
  8000f4:	e8 73 00 00 00       	call   80016c <_panic>
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 10             	sub    $0x10,%esp
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010a:	e8 b4 0a 00 00       	call   800bc3 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011b:	c1 e0 07             	shl    $0x7,%eax
  80011e:	29 d0                	sub    %edx,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	a3 20 40 c0 00       	mov    %eax,0xc04020


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012a:	85 f6                	test   %esi,%esi
  80012c:	7e 07                	jle    800135 <libmain+0x39>
		binaryname = argv[0];
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800135:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 f3 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800141:	e8 0a 00 00 00       	call   800150 <exit>
}
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800156:	e8 58 0f 00 00       	call   8010b3 <close_all>
	sys_env_destroy(0);
  80015b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800162:	e8 0a 0a 00 00       	call   800b71 <sys_env_destroy>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
	...

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800174:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800177:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80017d:	e8 41 0a 00 00       	call   800bc3 <sys_getenvid>
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	89 54 24 10          	mov    %edx,0x10(%esp)
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800190:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 08 26 80 00 	movl   $0x802608,(%esp)
  80019f:	e8 c0 00 00 00       	call   800264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 50 00 00 00       	call   800203 <vcprintf>
	cprintf("\n");
  8001b3:	c7 04 24 d6 25 80 00 	movl   $0x8025d6,(%esp)
  8001ba:	e8 a5 00 00 00       	call   800264 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x53>
	...

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 14             	sub    $0x14,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 03                	mov    (%ebx),%eax
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d7:	40                   	inc    %eax
  8001d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001df:	75 19                	jne    8001fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e8:	00 
  8001e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 40 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  8001f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fa:	ff 43 04             	incl   0x4(%ebx)
}
  8001fd:	83 c4 14             	add    $0x14,%esp
  800200:	5b                   	pop    %ebx
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800213:	00 00 00 
	b.cnt = 0;
  800216:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800220:	8b 45 0c             	mov    0xc(%ebp),%eax
  800223:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	c7 04 24 c4 01 80 00 	movl   $0x8001c4,(%esp)
  80023f:	e8 82 01 00 00       	call   8003c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800244:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 d8 08 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	8b 45 08             	mov    0x8(%ebp),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 87 ff ff ff       	call   800203 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	75 08                	jne    8002ac <printnum+0x2c>
  8002a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002aa:	77 57                	ja     800303 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b0:	4b                   	dec    %ebx
  8002b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cb:	00 
  8002cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	e8 0e 20 00 00       	call   8022ec <__udivdi3>
  8002de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e6:	89 04 24             	mov    %eax,(%esp)
  8002e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ed:	89 fa                	mov    %edi,%edx
  8002ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f2:	e8 89 ff ff ff       	call   800280 <printnum>
  8002f7:	eb 0f                	jmp    800308 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fd:	89 34 24             	mov    %esi,(%esp)
  800300:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800303:	4b                   	dec    %ebx
  800304:	85 db                	test   %ebx,%ebx
  800306:	7f f1                	jg     8002f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800310:	8b 45 10             	mov    0x10(%ebp),%eax
  800313:	89 44 24 08          	mov    %eax,0x8(%esp)
  800317:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031e:	00 
  80031f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032c:	e8 db 20 00 00       	call   80240c <__umoddi3>
  800331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800335:	0f be 80 2b 26 80 00 	movsbl 0x80262b(%eax),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800342:	83 c4 3c             	add    $0x3c,%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034d:	83 fa 01             	cmp    $0x1,%edx
  800350:	7e 0e                	jle    800360 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 08             	lea    0x8(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	8b 52 04             	mov    0x4(%edx),%edx
  80035e:	eb 22                	jmp    800382 <getuint+0x38>
	else if (lflag)
  800360:	85 d2                	test   %edx,%edx
  800362:	74 10                	je     800374 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	eb 0e                	jmp    800382 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 04             	lea    0x4(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	3b 50 04             	cmp    0x4(%eax),%edx
  800392:	73 08                	jae    80039c <sprintputch+0x18>
		*b->buf++ = ch;
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 0a                	mov    %cl,(%edx)
  800399:	42                   	inc    %edx
  80039a:	89 10                	mov    %edx,(%eax)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 02 00 00 00       	call   8003c6 <vprintfmt>
	va_end(ap);
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	57                   	push   %edi
  8003ca:	56                   	push   %esi
  8003cb:	53                   	push   %ebx
  8003cc:	83 ec 4c             	sub    $0x4c,%esp
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 6b 03 00 00    	je     80074a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e3:	89 04 24             	mov    %eax,(%esp)
  8003e6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 06             	movzbl (%esi),%eax
  8003ec:	46                   	inc    %esi
  8003ed:	83 f8 25             	cmp    $0x25,%eax
  8003f0:	75 e5                	jne    8003d7 <vprintfmt+0x11>
  8003f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800402:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	eb 26                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800413:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800417:	eb 1d                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800420:	eb 14                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800425:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042c:	eb 08                	jmp    800436 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800431:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	0f b6 06             	movzbl (%esi),%eax
  800439:	8d 56 01             	lea    0x1(%esi),%edx
  80043c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043f:	8a 16                	mov    (%esi),%dl
  800441:	83 ea 23             	sub    $0x23,%edx
  800444:	80 fa 55             	cmp    $0x55,%dl
  800447:	0f 87 e1 02 00 00    	ja     80072e <vprintfmt+0x368>
  80044d:	0f b6 d2             	movzbl %dl,%edx
  800450:	ff 24 95 60 27 80 00 	jmp    *0x802760(,%edx,4)
  800457:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800462:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800466:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800469:	8d 50 d0             	lea    -0x30(%eax),%edx
  80046c:	83 fa 09             	cmp    $0x9,%edx
  80046f:	77 2a                	ja     80049b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800471:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800472:	eb eb                	jmp    80045f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800482:	eb 17                	jmp    80049b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800484:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800488:	78 98                	js     800422 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80048d:	eb a7                	jmp    800436 <vprintfmt+0x70>
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800492:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800499:	eb 9b                	jmp    800436 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049f:	79 95                	jns    800436 <vprintfmt+0x70>
  8004a1:	eb 8b                	jmp    80042e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a7:	eb 8d                	jmp    800436 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b6:	8b 00                	mov    (%eax),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 23 ff ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	79 02                	jns    8004d7 <vprintfmt+0x111>
  8004d5:	f7 d8                	neg    %eax
  8004d7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d9:	83 f8 10             	cmp    $0x10,%eax
  8004dc:	7f 0b                	jg     8004e9 <vprintfmt+0x123>
  8004de:	8b 04 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%eax
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	75 23                	jne    80050c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ed:	c7 44 24 08 43 26 80 	movl   $0x802643,0x8(%esp)
  8004f4:	00 
  8004f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	e8 9a fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800507:	e9 dd fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80050c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800510:	c7 44 24 08 fd 29 80 	movl   $0x8029fd,0x8(%esp)
  800517:	00 
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	8b 55 08             	mov    0x8(%ebp),%edx
  80051f:	89 14 24             	mov    %edx,(%esp)
  800522:	e8 77 fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052a:	e9 ba fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
  80052f:	89 f9                	mov    %edi,%ecx
  800531:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800534:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 30                	mov    (%eax),%esi
  800542:	85 f6                	test   %esi,%esi
  800544:	75 05                	jne    80054b <vprintfmt+0x185>
				p = "(null)";
  800546:	be 3c 26 80 00       	mov    $0x80263c,%esi
			if (width > 0 && padc != '-')
  80054b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054f:	0f 8e 84 00 00 00    	jle    8005d9 <vprintfmt+0x213>
  800555:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800559:	74 7e                	je     8005d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055f:	89 34 24             	mov    %esi,(%esp)
  800562:	e8 8b 02 00 00       	call   8007f2 <strnlen>
  800567:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056a:	29 c2                	sub    %eax,%edx
  80056c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80056f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800573:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800576:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800579:	89 de                	mov    %ebx,%esi
  80057b:	89 d3                	mov    %edx,%ebx
  80057d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	eb 0b                	jmp    80058c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800581:	89 74 24 04          	mov    %esi,0x4(%esp)
  800585:	89 3c 24             	mov    %edi,(%esp)
  800588:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	4b                   	dec    %ebx
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f f1                	jg     800581 <vprintfmt+0x1bb>
  800590:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800593:	89 f3                	mov    %esi,%ebx
  800595:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059b:	85 c0                	test   %eax,%eax
  80059d:	79 05                	jns    8005a4 <vprintfmt+0x1de>
  80059f:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a7:	29 c2                	sub    %eax,%edx
  8005a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ac:	eb 2b                	jmp    8005d9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b2:	74 18                	je     8005cc <vprintfmt+0x206>
  8005b4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b7:	83 fa 5e             	cmp    $0x5e,%edx
  8005ba:	76 10                	jbe    8005cc <vprintfmt+0x206>
					putch('?', putdat);
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
  8005ca:	eb 0a                	jmp    8005d6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d9:	0f be 06             	movsbl (%esi),%eax
  8005dc:	46                   	inc    %esi
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	74 21                	je     800602 <vprintfmt+0x23c>
  8005e1:	85 ff                	test   %edi,%edi
  8005e3:	78 c9                	js     8005ae <vprintfmt+0x1e8>
  8005e5:	4f                   	dec    %edi
  8005e6:	79 c6                	jns    8005ae <vprintfmt+0x1e8>
  8005e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005eb:	89 de                	mov    %ebx,%esi
  8005ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f0:	eb 18                	jmp    80060a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ff:	4b                   	dec    %ebx
  800600:	eb 08                	jmp    80060a <vprintfmt+0x244>
  800602:	8b 7d 08             	mov    0x8(%ebp),%edi
  800605:	89 de                	mov    %ebx,%esi
  800607:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060a:	85 db                	test   %ebx,%ebx
  80060c:	7f e4                	jg     8005f2 <vprintfmt+0x22c>
  80060e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800611:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800616:	e9 ce fd ff ff       	jmp    8003e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061b:	83 f9 01             	cmp    $0x1,%ecx
  80061e:	7e 10                	jle    800630 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 08             	lea    0x8(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	8b 78 04             	mov    0x4(%eax),%edi
  80062e:	eb 26                	jmp    800656 <vprintfmt+0x290>
	else if (lflag)
  800630:	85 c9                	test   %ecx,%ecx
  800632:	74 12                	je     800646 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 30                	mov    (%eax),%esi
  80063f:	89 f7                	mov    %esi,%edi
  800641:	c1 ff 1f             	sar    $0x1f,%edi
  800644:	eb 10                	jmp    800656 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 30                	mov    (%eax),%esi
  800651:	89 f7                	mov    %esi,%edi
  800653:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800656:	85 ff                	test   %edi,%edi
  800658:	78 0a                	js     800664 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065f:	e9 8c 00 00 00       	jmp    8006f0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800672:	f7 de                	neg    %esi
  800674:	83 d7 00             	adc    $0x0,%edi
  800677:	f7 df                	neg    %edi
			}
			base = 10;
  800679:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067e:	eb 70                	jmp    8006f0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	89 ca                	mov    %ecx,%edx
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 c0 fc ff ff       	call   80034a <getuint>
  80068a:	89 c6                	mov    %eax,%esi
  80068c:	89 d7                	mov    %edx,%edi
			base = 10;
  80068e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800693:	eb 5b                	jmp    8006f0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800695:	89 ca                	mov    %ecx,%edx
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 ab fc ff ff       	call   80034a <getuint>
  80069f:	89 c6                	mov    %eax,%esi
  8006a1:	89 d7                	mov    %edx,%edi
			base = 8;
  8006a3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006a8:	eb 46                	jmp    8006f0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 30                	mov    (%eax),%esi
  8006d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006db:	eb 13                	jmp    8006f0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	89 ca                	mov    %ecx,%edx
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	e8 63 fc ff ff       	call   80034a <getuint>
  8006e7:	89 c6                	mov    %eax,%esi
  8006e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800703:	89 34 24             	mov    %esi,(%esp)
  800706:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070a:	89 da                	mov    %ebx,%edx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	e8 6c fb ff ff       	call   800280 <printnum>
			break;
  800714:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800717:	e9 cd fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 bb fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	eb 01                	jmp    80073f <vprintfmt+0x379>
  80073e:	4e                   	dec    %esi
  80073f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800743:	75 f9                	jne    80073e <vprintfmt+0x378>
  800745:	e9 9f fc ff ff       	jmp    8003e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	83 c4 4c             	add    $0x4c,%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 28             	sub    $0x28,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 30                	je     8007a3 <vsnprintf+0x51>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 33                	jle    8007aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800793:	e8 2e fc ff ff       	call   8003c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	eb 0c                	jmp    8007af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a8:	eb 05                	jmp    8007af <vsnprintf+0x5d>
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007be:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 7b ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
  8007d9:	00 00                	add    %al,(%eax)
	...

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 01                	jmp    8007ea <strlen+0xe>
		n++;
  8007e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f9                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 01                	jmp    800803 <strnlen+0x11>
		n++;
  800802:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1b>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f5                	jne    800802 <strnlen+0x10>
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
  80081e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800821:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800824:	42                   	inc    %edx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 f5                	jne    80081e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800829:	5b                   	pop    %ebx
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	89 1c 24             	mov    %ebx,(%esp)
  800839:	e8 9e ff ff ff       	call   8007dc <strlen>
	strcpy(dst + len, src);
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	89 54 24 04          	mov    %edx,0x4(%esp)
  800845:	01 d8                	add    %ebx,%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 c0 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086a:	eb 0c                	jmp    800878 <strncpy+0x21>
		*dst++ = *src;
  80086c:	8a 1a                	mov    (%edx),%bl
  80086e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 3a 01             	cmpb   $0x1,(%edx)
  800874:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	41                   	inc    %ecx
  800878:	39 f1                	cmp    %esi,%ecx
  80087a:	75 f0                	jne    80086c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	75 0a                	jne    80089c <strlcpy+0x1c>
  800892:	89 f0                	mov    %esi,%eax
  800894:	eb 1a                	jmp    8008b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800896:	88 18                	mov    %bl,(%eax)
  800898:	40                   	inc    %eax
  800899:	41                   	inc    %ecx
  80089a:	eb 02                	jmp    80089e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089e:	4a                   	dec    %edx
  80089f:	74 0a                	je     8008ab <strlcpy+0x2b>
  8008a1:	8a 19                	mov    (%ecx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strlcpy+0x16>
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	eb 02                	jmp    8008ad <strlcpy+0x2d>
  8008ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b0:	29 f0                	sub    %esi,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bf:	eb 02                	jmp    8008c3 <strcmp+0xd>
		p++, q++;
  8008c1:	41                   	inc    %ecx
  8008c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c3:	8a 01                	mov    (%ecx),%al
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x17>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 f4                	je     8008c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e4:	eb 03                	jmp    8008e9 <strncmp+0x12>
		n--, p++, q++;
  8008e6:	4a                   	dec    %edx
  8008e7:	40                   	inc    %eax
  8008e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 14                	je     800901 <strncmp+0x2a>
  8008ed:	8a 18                	mov    (%eax),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	74 04                	je     8008f7 <strncmp+0x20>
  8008f3:	3a 19                	cmp    (%ecx),%bl
  8008f5:	74 ef                	je     8008e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 00             	movzbl (%eax),%eax
  8008fa:	0f b6 11             	movzbl (%ecx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
  8008ff:	eb 05                	jmp    800906 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	eb 05                	jmp    800919 <strchr+0x10>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 0c                	je     800924 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800918:	40                   	inc    %eax
  800919:	8a 10                	mov    (%eax),%dl
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f5                	jne    800914 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092f:	eb 05                	jmp    800936 <strfind+0x10>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 07                	je     80093c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800935:	40                   	inc    %eax
  800936:	8a 10                	mov    (%eax),%dl
  800938:	84 d2                	test   %dl,%dl
  80093a:	75 f5                	jne    800931 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 7d 08             	mov    0x8(%ebp),%edi
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 30                	je     800981 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 25                	jne    80097e <memset+0x40>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 20                	jne    80097e <memset+0x40>
		c &= 0xFF;
  80095e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 18             	shl    $0x18,%esi
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 10             	shl    $0x10,%eax
  800970:	09 f0                	or     %esi,%eax
  800972:	09 d0                	or     %edx,%eax
  800974:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800976:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800979:	fc                   	cld    
  80097a:	f3 ab                	rep stos %eax,%es:(%edi)
  80097c:	eb 03                	jmp    800981 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097e:	fc                   	cld    
  80097f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800981:	89 f8                	mov    %edi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 34                	jae    8009ce <memmove+0x46>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	73 2d                	jae    8009ce <memmove+0x46>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c2 03             	test   $0x3,%dl
  8009a7:	75 1b                	jne    8009c4 <memmove+0x3c>
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 13                	jne    8009c4 <memmove+0x3c>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0e                	jne    8009c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 07                	jmp    8009cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c4:	4f                   	dec    %edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 20                	jmp    8009ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d4:	75 13                	jne    8009e9 <memmove+0x61>
  8009d6:	a8 03                	test   $0x3,%al
  8009d8:	75 0f                	jne    8009e9 <memmove+0x61>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0a                	jne    8009e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 05                	jmp    8009ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 04 24             	mov    %eax,(%esp)
  800a0c:	e8 77 ff ff ff       	call   800988 <memmove>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	eb 16                	jmp    800a3f <memcmp+0x2c>
		if (*s1 != *s2)
  800a29:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a2c:	42                   	inc    %edx
  800a2d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a31:	38 c8                	cmp    %cl,%al
  800a33:	74 0a                	je     800a3f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 c9             	movzbl %cl,%ecx
  800a3b:	29 c8                	sub    %ecx,%eax
  800a3d:	eb 09                	jmp    800a48 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	75 e6                	jne    800a29 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5b:	eb 05                	jmp    800a62 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	74 05                	je     800a66 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a61:	40                   	inc    %eax
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	72 f7                	jb     800a5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	eb 01                	jmp    800a77 <strtol+0xf>
		s++;
  800a76:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	8a 02                	mov    (%edx),%al
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f9                	je     800a76 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f5                	je     800a76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	75 08                	jne    800a8d <strtol+0x25>
		s++;
  800a85:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 13                	jmp    800aa0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 0a                	jne    800a9b <strtol+0x33>
		s++, neg = 1;
  800a91:	8d 52 01             	lea    0x1(%edx),%edx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi
  800a99:	eb 05                	jmp    800aa0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	74 05                	je     800aa9 <strtol+0x41>
  800aa4:	83 fb 10             	cmp    $0x10,%ebx
  800aa7:	75 28                	jne    800ad1 <strtol+0x69>
  800aa9:	8a 02                	mov    (%edx),%al
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 10                	jne    800abf <strtol+0x57>
  800aaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab3:	75 0a                	jne    800abf <strtol+0x57>
		s += 2, base = 16;
  800ab5:	83 c2 02             	add    $0x2,%edx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb 12                	jmp    800ad1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 0e                	jne    800ad1 <strtol+0x69>
  800ac3:	3c 30                	cmp    $0x30,%al
  800ac5:	75 05                	jne    800acc <strtol+0x64>
		s++, base = 8;
  800ac7:	42                   	inc    %edx
  800ac8:	b3 08                	mov    $0x8,%bl
  800aca:	eb 05                	jmp    800ad1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad8:	8a 0a                	mov    (%edx),%cl
  800ada:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800add:	80 fb 09             	cmp    $0x9,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x82>
			dig = *s - '0';
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 30             	sub    $0x30,%ecx
  800ae8:	eb 1e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 08                	ja     800afa <strtol+0x92>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 12                	ja     800b14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b08:	39 f1                	cmp    %esi,%ecx
  800b0a:	7d 0c                	jge    800b18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b0c:	42                   	inc    %edx
  800b0d:	0f af c6             	imul   %esi,%eax
  800b10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b12:	eb c4                	jmp    800ad8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	89 c1                	mov    %eax,%ecx
  800b16:	eb 02                	jmp    800b1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1e:	74 05                	je     800b25 <strtol+0xbd>
		*endptr = (char *) s;
  800b20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b25:	85 ff                	test   %edi,%edi
  800b27:	74 04                	je     800b2d <strtol+0xc5>
  800b29:	89 c8                	mov    %ecx,%eax
  800b2b:	f7 d8                	neg    %eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
	...

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7e 28                	jle    800bbb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9e:	00 
  800b9f:	c7 44 24 08 23 29 80 	movl   $0x802923,0x8(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bae:	00 
  800baf:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800bb6:	e8 b1 f5 ff ff       	call   80016c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbb:	83 c4 2c             	add    $0x2c,%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_yield>:

void
sys_yield(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	be 00 00 00 00       	mov    $0x0,%esi
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 f7                	mov    %esi,%edi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 23 29 80 	movl   $0x802923,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800c48:	e8 1f f5 ff ff       	call   80016c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c63:	8b 75 18             	mov    0x18(%ebp),%esi
  800c66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 28                	jle    800ca0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c83:	00 
  800c84:	c7 44 24 08 23 29 80 	movl   $0x802923,0x8(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c93:	00 
  800c94:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800c9b:	e8 cc f4 ff ff       	call   80016c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca0:	83 c4 2c             	add    $0x2c,%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 28                	jle    800cf3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 08 23 29 80 	movl   $0x802923,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800cee:	e8 79 f4 ff ff       	call   80016c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	83 c4 2c             	add    $0x2c,%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d09:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 df                	mov    %ebx,%edi
  800d16:	89 de                	mov    %ebx,%esi
  800d18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 28                	jle    800d46 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d22:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d29:	00 
  800d2a:	c7 44 24 08 23 29 80 	movl   $0x802923,0x8(%esp)
  800d31:	00 
  800d32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d39:	00 
  800d3a:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800d41:	e8 26 f4 ff ff       	call   80016c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d46:	83 c4 2c             	add    $0x2c,%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 23 29 80 	movl   $0x802923,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800d94:	e8 d3 f3 ff ff       	call   80016c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 df                	mov    %ebx,%edi
  800dbc:	89 de                	mov    %ebx,%esi
  800dbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 28                	jle    800dec <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 23 29 80 	movl   $0x802923,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800de7:	e8 80 f3 ff ff       	call   80016c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dec:	83 c4 2c             	add    $0x2c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	be 00 00 00 00       	mov    $0x0,%esi
  800dff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 cb                	mov    %ecx,%ebx
  800e2f:	89 cf                	mov    %ecx,%edi
  800e31:	89 ce                	mov    %ecx,%esi
  800e33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 23 29 80 	movl   $0x802923,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  800e5c:	e8 0b f3 ff ff       	call   80016c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e74:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e79:	89 d1                	mov    %edx,%ecx
  800e7b:	89 d3                	mov    %edx,%ebx
  800e7d:	89 d7                	mov    %edx,%edi
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e93:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	89 df                	mov    %ebx,%edi
  800ea0:	89 de                	mov    %ebx,%esi
  800ea2:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb4:	b8 10 00 00 00       	mov    $0x10,%eax
  800eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 df                	mov    %ebx,%edi
  800ec1:	89 de                	mov    %ebx,%esi
  800ec3:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    
	...

00800ecc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed7:	c1 e8 0c             	shr    $0xc,%eax
}
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	89 04 24             	mov    %eax,(%esp)
  800ee8:	e8 df ff ff ff       	call   800ecc <fd2num>
  800eed:	c1 e0 0c             	shl    $0xc,%eax
  800ef0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	53                   	push   %ebx
  800efb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800efe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f03:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f05:	89 c2                	mov    %eax,%edx
  800f07:	c1 ea 16             	shr    $0x16,%edx
  800f0a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f11:	f6 c2 01             	test   $0x1,%dl
  800f14:	74 11                	je     800f27 <fd_alloc+0x30>
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	c1 ea 0c             	shr    $0xc,%edx
  800f1b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f22:	f6 c2 01             	test   $0x1,%dl
  800f25:	75 09                	jne    800f30 <fd_alloc+0x39>
			*fd_store = fd;
  800f27:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	eb 17                	jmp    800f47 <fd_alloc+0x50>
  800f30:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f35:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f3a:	75 c7                	jne    800f03 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f3c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f42:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f47:	5b                   	pop    %ebx
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f50:	83 f8 1f             	cmp    $0x1f,%eax
  800f53:	77 36                	ja     800f8b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f55:	c1 e0 0c             	shl    $0xc,%eax
  800f58:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f5d:	89 c2                	mov    %eax,%edx
  800f5f:	c1 ea 16             	shr    $0x16,%edx
  800f62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f69:	f6 c2 01             	test   $0x1,%dl
  800f6c:	74 24                	je     800f92 <fd_lookup+0x48>
  800f6e:	89 c2                	mov    %eax,%edx
  800f70:	c1 ea 0c             	shr    $0xc,%edx
  800f73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7a:	f6 c2 01             	test   $0x1,%dl
  800f7d:	74 1a                	je     800f99 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f82:	89 02                	mov    %eax,(%edx)
	return 0;
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
  800f89:	eb 13                	jmp    800f9e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f90:	eb 0c                	jmp    800f9e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f97:	eb 05                	jmp    800f9e <fd_lookup+0x54>
  800f99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 14             	sub    $0x14,%esp
  800fa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800faa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fad:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb2:	eb 0e                	jmp    800fc2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fb4:	39 08                	cmp    %ecx,(%eax)
  800fb6:	75 09                	jne    800fc1 <dev_lookup+0x21>
			*dev = devtab[i];
  800fb8:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fba:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbf:	eb 33                	jmp    800ff4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc1:	42                   	inc    %edx
  800fc2:	8b 04 95 d0 29 80 00 	mov    0x8029d0(,%edx,4),%eax
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	75 e7                	jne    800fb4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fcd:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800fd2:	8b 40 48             	mov    0x48(%eax),%eax
  800fd5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fdd:	c7 04 24 50 29 80 00 	movl   $0x802950,(%esp)
  800fe4:	e8 7b f2 ff ff       	call   800264 <cprintf>
	*dev = 0;
  800fe9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ff4:	83 c4 14             	add    $0x14,%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	56                   	push   %esi
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 30             	sub    $0x30,%esp
  801002:	8b 75 08             	mov    0x8(%ebp),%esi
  801005:	8a 45 0c             	mov    0xc(%ebp),%al
  801008:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80100b:	89 34 24             	mov    %esi,(%esp)
  80100e:	e8 b9 fe ff ff       	call   800ecc <fd2num>
  801013:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801016:	89 54 24 04          	mov    %edx,0x4(%esp)
  80101a:	89 04 24             	mov    %eax,(%esp)
  80101d:	e8 28 ff ff ff       	call   800f4a <fd_lookup>
  801022:	89 c3                	mov    %eax,%ebx
  801024:	85 c0                	test   %eax,%eax
  801026:	78 05                	js     80102d <fd_close+0x33>
	    || fd != fd2)
  801028:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80102b:	74 0d                	je     80103a <fd_close+0x40>
		return (must_exist ? r : 0);
  80102d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801031:	75 46                	jne    801079 <fd_close+0x7f>
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
  801038:	eb 3f                	jmp    801079 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80103a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80103d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801041:	8b 06                	mov    (%esi),%eax
  801043:	89 04 24             	mov    %eax,(%esp)
  801046:	e8 55 ff ff ff       	call   800fa0 <dev_lookup>
  80104b:	89 c3                	mov    %eax,%ebx
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 18                	js     801069 <fd_close+0x6f>
		if (dev->dev_close)
  801051:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801054:	8b 40 10             	mov    0x10(%eax),%eax
  801057:	85 c0                	test   %eax,%eax
  801059:	74 09                	je     801064 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80105b:	89 34 24             	mov    %esi,(%esp)
  80105e:	ff d0                	call   *%eax
  801060:	89 c3                	mov    %eax,%ebx
  801062:	eb 05                	jmp    801069 <fd_close+0x6f>
		else
			r = 0;
  801064:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801069:	89 74 24 04          	mov    %esi,0x4(%esp)
  80106d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801074:	e8 2f fc ff ff       	call   800ca8 <sys_page_unmap>
	return r;
}
  801079:	89 d8                	mov    %ebx,%eax
  80107b:	83 c4 30             	add    $0x30,%esp
  80107e:	5b                   	pop    %ebx
  80107f:	5e                   	pop    %esi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801088:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108f:	8b 45 08             	mov    0x8(%ebp),%eax
  801092:	89 04 24             	mov    %eax,(%esp)
  801095:	e8 b0 fe ff ff       	call   800f4a <fd_lookup>
  80109a:	85 c0                	test   %eax,%eax
  80109c:	78 13                	js     8010b1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80109e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a5:	00 
  8010a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a9:	89 04 24             	mov    %eax,(%esp)
  8010ac:	e8 49 ff ff ff       	call   800ffa <fd_close>
}
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    

008010b3 <close_all>:

void
close_all(void)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010bf:	89 1c 24             	mov    %ebx,(%esp)
  8010c2:	e8 bb ff ff ff       	call   801082 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c7:	43                   	inc    %ebx
  8010c8:	83 fb 20             	cmp    $0x20,%ebx
  8010cb:	75 f2                	jne    8010bf <close_all+0xc>
		close(i);
}
  8010cd:	83 c4 14             	add    $0x14,%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 4c             	sub    $0x4c,%esp
  8010dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	89 04 24             	mov    %eax,(%esp)
  8010ec:	e8 59 fe ff ff       	call   800f4a <fd_lookup>
  8010f1:	89 c3                	mov    %eax,%ebx
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	0f 88 e3 00 00 00    	js     8011de <dup+0x10b>
		return r;
	close(newfdnum);
  8010fb:	89 3c 24             	mov    %edi,(%esp)
  8010fe:	e8 7f ff ff ff       	call   801082 <close>

	newfd = INDEX2FD(newfdnum);
  801103:	89 fe                	mov    %edi,%esi
  801105:	c1 e6 0c             	shl    $0xc,%esi
  801108:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80110e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801111:	89 04 24             	mov    %eax,(%esp)
  801114:	e8 c3 fd ff ff       	call   800edc <fd2data>
  801119:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80111b:	89 34 24             	mov    %esi,(%esp)
  80111e:	e8 b9 fd ff ff       	call   800edc <fd2data>
  801123:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801126:	89 d8                	mov    %ebx,%eax
  801128:	c1 e8 16             	shr    $0x16,%eax
  80112b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801132:	a8 01                	test   $0x1,%al
  801134:	74 46                	je     80117c <dup+0xa9>
  801136:	89 d8                	mov    %ebx,%eax
  801138:	c1 e8 0c             	shr    $0xc,%eax
  80113b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801142:	f6 c2 01             	test   $0x1,%dl
  801145:	74 35                	je     80117c <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801147:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114e:	25 07 0e 00 00       	and    $0xe07,%eax
  801153:	89 44 24 10          	mov    %eax,0x10(%esp)
  801157:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80115a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801165:	00 
  801166:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80116a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801171:	e8 df fa ff ff       	call   800c55 <sys_page_map>
  801176:	89 c3                	mov    %eax,%ebx
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 3b                	js     8011b7 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80117c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80117f:	89 c2                	mov    %eax,%edx
  801181:	c1 ea 0c             	shr    $0xc,%edx
  801184:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801191:	89 54 24 10          	mov    %edx,0x10(%esp)
  801195:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801199:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a0:	00 
  8011a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ac:	e8 a4 fa ff ff       	call   800c55 <sys_page_map>
  8011b1:	89 c3                	mov    %eax,%ebx
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	79 25                	jns    8011dc <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c2:	e8 e1 fa ff ff       	call   800ca8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d5:	e8 ce fa ff ff       	call   800ca8 <sys_page_unmap>
	return r;
  8011da:	eb 02                	jmp    8011de <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011dc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011de:	89 d8                	mov    %ebx,%eax
  8011e0:	83 c4 4c             	add    $0x4c,%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 24             	sub    $0x24,%esp
  8011ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f9:	89 1c 24             	mov    %ebx,(%esp)
  8011fc:	e8 49 fd ff ff       	call   800f4a <fd_lookup>
  801201:	85 c0                	test   %eax,%eax
  801203:	78 6d                	js     801272 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801205:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120f:	8b 00                	mov    (%eax),%eax
  801211:	89 04 24             	mov    %eax,(%esp)
  801214:	e8 87 fd ff ff       	call   800fa0 <dev_lookup>
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 55                	js     801272 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80121d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801220:	8b 50 08             	mov    0x8(%eax),%edx
  801223:	83 e2 03             	and    $0x3,%edx
  801226:	83 fa 01             	cmp    $0x1,%edx
  801229:	75 23                	jne    80124e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80122b:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
  801233:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123b:	c7 04 24 94 29 80 00 	movl   $0x802994,(%esp)
  801242:	e8 1d f0 ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124c:	eb 24                	jmp    801272 <read+0x8a>
	}
	if (!dev->dev_read)
  80124e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801251:	8b 52 08             	mov    0x8(%edx),%edx
  801254:	85 d2                	test   %edx,%edx
  801256:	74 15                	je     80126d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801258:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80125b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80125f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801262:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801266:	89 04 24             	mov    %eax,(%esp)
  801269:	ff d2                	call   *%edx
  80126b:	eb 05                	jmp    801272 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80126d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801272:	83 c4 24             	add    $0x24,%esp
  801275:	5b                   	pop    %ebx
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	57                   	push   %edi
  80127c:	56                   	push   %esi
  80127d:	53                   	push   %ebx
  80127e:	83 ec 1c             	sub    $0x1c,%esp
  801281:	8b 7d 08             	mov    0x8(%ebp),%edi
  801284:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801287:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128c:	eb 23                	jmp    8012b1 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80128e:	89 f0                	mov    %esi,%eax
  801290:	29 d8                	sub    %ebx,%eax
  801292:	89 44 24 08          	mov    %eax,0x8(%esp)
  801296:	8b 45 0c             	mov    0xc(%ebp),%eax
  801299:	01 d8                	add    %ebx,%eax
  80129b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129f:	89 3c 24             	mov    %edi,(%esp)
  8012a2:	e8 41 ff ff ff       	call   8011e8 <read>
		if (m < 0)
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 10                	js     8012bb <readn+0x43>
			return m;
		if (m == 0)
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	74 0a                	je     8012b9 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012af:	01 c3                	add    %eax,%ebx
  8012b1:	39 f3                	cmp    %esi,%ebx
  8012b3:	72 d9                	jb     80128e <readn+0x16>
  8012b5:	89 d8                	mov    %ebx,%eax
  8012b7:	eb 02                	jmp    8012bb <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012b9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012bb:	83 c4 1c             	add    $0x1c,%esp
  8012be:	5b                   	pop    %ebx
  8012bf:	5e                   	pop    %esi
  8012c0:	5f                   	pop    %edi
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 24             	sub    $0x24,%esp
  8012ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d4:	89 1c 24             	mov    %ebx,(%esp)
  8012d7:	e8 6e fc ff ff       	call   800f4a <fd_lookup>
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 68                	js     801348 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	8b 00                	mov    (%eax),%eax
  8012ec:	89 04 24             	mov    %eax,(%esp)
  8012ef:	e8 ac fc ff ff       	call   800fa0 <dev_lookup>
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 50                	js     801348 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ff:	75 23                	jne    801324 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801301:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801306:	8b 40 48             	mov    0x48(%eax),%eax
  801309:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	c7 04 24 b0 29 80 00 	movl   $0x8029b0,(%esp)
  801318:	e8 47 ef ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  80131d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801322:	eb 24                	jmp    801348 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801324:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801327:	8b 52 0c             	mov    0xc(%edx),%edx
  80132a:	85 d2                	test   %edx,%edx
  80132c:	74 15                	je     801343 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80132e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801331:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801335:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801338:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80133c:	89 04 24             	mov    %eax,(%esp)
  80133f:	ff d2                	call   *%edx
  801341:	eb 05                	jmp    801348 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801343:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801348:	83 c4 24             	add    $0x24,%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <seek>:

int
seek(int fdnum, off_t offset)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801354:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	89 04 24             	mov    %eax,(%esp)
  801361:	e8 e4 fb ff ff       	call   800f4a <fd_lookup>
  801366:	85 c0                	test   %eax,%eax
  801368:	78 0e                	js     801378 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80136a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80136d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801370:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801373:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801378:	c9                   	leave  
  801379:	c3                   	ret    

0080137a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	53                   	push   %ebx
  80137e:	83 ec 24             	sub    $0x24,%esp
  801381:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801384:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801387:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138b:	89 1c 24             	mov    %ebx,(%esp)
  80138e:	e8 b7 fb ff ff       	call   800f4a <fd_lookup>
  801393:	85 c0                	test   %eax,%eax
  801395:	78 61                	js     8013f8 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a1:	8b 00                	mov    (%eax),%eax
  8013a3:	89 04 24             	mov    %eax,(%esp)
  8013a6:	e8 f5 fb ff ff       	call   800fa0 <dev_lookup>
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 49                	js     8013f8 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b6:	75 23                	jne    8013db <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013b8:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013bd:	8b 40 48             	mov    0x48(%eax),%eax
  8013c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	c7 04 24 70 29 80 00 	movl   $0x802970,(%esp)
  8013cf:	e8 90 ee ff ff       	call   800264 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d9:	eb 1d                	jmp    8013f8 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8013db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013de:	8b 52 18             	mov    0x18(%edx),%edx
  8013e1:	85 d2                	test   %edx,%edx
  8013e3:	74 0e                	je     8013f3 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ec:	89 04 24             	mov    %eax,(%esp)
  8013ef:	ff d2                	call   *%edx
  8013f1:	eb 05                	jmp    8013f8 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013f8:	83 c4 24             	add    $0x24,%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	53                   	push   %ebx
  801402:	83 ec 24             	sub    $0x24,%esp
  801405:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801408:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	e8 30 fb ff ff       	call   800f4a <fd_lookup>
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 52                	js     801470 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801421:	89 44 24 04          	mov    %eax,0x4(%esp)
  801425:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801428:	8b 00                	mov    (%eax),%eax
  80142a:	89 04 24             	mov    %eax,(%esp)
  80142d:	e8 6e fb ff ff       	call   800fa0 <dev_lookup>
  801432:	85 c0                	test   %eax,%eax
  801434:	78 3a                	js     801470 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801439:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80143d:	74 2c                	je     80146b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80143f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801442:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801449:	00 00 00 
	stat->st_isdir = 0;
  80144c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801453:	00 00 00 
	stat->st_dev = dev;
  801456:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80145c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801460:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801463:	89 14 24             	mov    %edx,(%esp)
  801466:	ff 50 14             	call   *0x14(%eax)
  801469:	eb 05                	jmp    801470 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80146b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801470:	83 c4 24             	add    $0x24,%esp
  801473:	5b                   	pop    %ebx
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80147e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801485:	00 
  801486:	8b 45 08             	mov    0x8(%ebp),%eax
  801489:	89 04 24             	mov    %eax,(%esp)
  80148c:	e8 2a 02 00 00       	call   8016bb <open>
  801491:	89 c3                	mov    %eax,%ebx
  801493:	85 c0                	test   %eax,%eax
  801495:	78 1b                	js     8014b2 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801497:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149e:	89 1c 24             	mov    %ebx,(%esp)
  8014a1:	e8 58 ff ff ff       	call   8013fe <fstat>
  8014a6:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a8:	89 1c 24             	mov    %ebx,(%esp)
  8014ab:	e8 d2 fb ff ff       	call   801082 <close>
	return r;
  8014b0:	89 f3                	mov    %esi,%ebx
}
  8014b2:	89 d8                	mov    %ebx,%eax
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    
	...

008014bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 10             	sub    $0x10,%esp
  8014c4:	89 c3                	mov    %eax,%ebx
  8014c6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014c8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014cf:	75 11                	jne    8014e2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014d8:	e8 86 0d 00 00       	call   802263 <ipc_find_env>
  8014dd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014e2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014e9:	00 
  8014ea:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  8014f1:	00 
  8014f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f6:	a1 00 40 80 00       	mov    0x804000,%eax
  8014fb:	89 04 24             	mov    %eax,(%esp)
  8014fe:	e8 dd 0c 00 00       	call   8021e0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801503:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80150a:	00 
  80150b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801516:	e8 55 0c 00 00       	call   802170 <ipc_recv>
}
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5e                   	pop    %esi
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801528:	8b 45 08             	mov    0x8(%ebp),%eax
  80152b:	8b 40 0c             	mov    0xc(%eax),%eax
  80152e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801533:	8b 45 0c             	mov    0xc(%ebp),%eax
  801536:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 02 00 00 00       	mov    $0x2,%eax
  801545:	e8 72 ff ff ff       	call   8014bc <fsipc>
}
  80154a:	c9                   	leave  
  80154b:	c3                   	ret    

0080154c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801552:	8b 45 08             	mov    0x8(%ebp),%eax
  801555:	8b 40 0c             	mov    0xc(%eax),%eax
  801558:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  80155d:	ba 00 00 00 00       	mov    $0x0,%edx
  801562:	b8 06 00 00 00       	mov    $0x6,%eax
  801567:	e8 50 ff ff ff       	call   8014bc <fsipc>
}
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    

0080156e <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	53                   	push   %ebx
  801572:	83 ec 14             	sub    $0x14,%esp
  801575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801578:	8b 45 08             	mov    0x8(%ebp),%eax
  80157b:	8b 40 0c             	mov    0xc(%eax),%eax
  80157e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801583:	ba 00 00 00 00       	mov    $0x0,%edx
  801588:	b8 05 00 00 00       	mov    $0x5,%eax
  80158d:	e8 2a ff ff ff       	call   8014bc <fsipc>
  801592:	85 c0                	test   %eax,%eax
  801594:	78 2b                	js     8015c1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801596:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  80159d:	00 
  80159e:	89 1c 24             	mov    %ebx,(%esp)
  8015a1:	e8 69 f2 ff ff       	call   80080f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015a6:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8015ab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015b1:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8015b6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c1:	83 c4 14             	add    $0x14,%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 18             	sub    $0x18,%esp
  8015cd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d6:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  8015dc:	a3 04 50 c0 00       	mov    %eax,0xc05004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015e8:	76 05                	jbe    8015ef <devfile_write+0x28>
  8015ea:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8015ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fa:	c7 04 24 08 50 c0 00 	movl   $0xc05008,(%esp)
  801601:	e8 ec f3 ff ff       	call   8009f2 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801606:	ba 00 00 00 00       	mov    $0x0,%edx
  80160b:	b8 04 00 00 00       	mov    $0x4,%eax
  801610:	e8 a7 fe ff ff       	call   8014bc <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	56                   	push   %esi
  80161b:	53                   	push   %ebx
  80161c:	83 ec 10             	sub    $0x10,%esp
  80161f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801622:	8b 45 08             	mov    0x8(%ebp),%eax
  801625:	8b 40 0c             	mov    0xc(%eax),%eax
  801628:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  80162d:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801633:	ba 00 00 00 00       	mov    $0x0,%edx
  801638:	b8 03 00 00 00       	mov    $0x3,%eax
  80163d:	e8 7a fe ff ff       	call   8014bc <fsipc>
  801642:	89 c3                	mov    %eax,%ebx
  801644:	85 c0                	test   %eax,%eax
  801646:	78 6a                	js     8016b2 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801648:	39 c6                	cmp    %eax,%esi
  80164a:	73 24                	jae    801670 <devfile_read+0x59>
  80164c:	c7 44 24 0c e4 29 80 	movl   $0x8029e4,0xc(%esp)
  801653:	00 
  801654:	c7 44 24 08 eb 29 80 	movl   $0x8029eb,0x8(%esp)
  80165b:	00 
  80165c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801663:	00 
  801664:	c7 04 24 00 2a 80 00 	movl   $0x802a00,(%esp)
  80166b:	e8 fc ea ff ff       	call   80016c <_panic>
	assert(r <= PGSIZE);
  801670:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801675:	7e 24                	jle    80169b <devfile_read+0x84>
  801677:	c7 44 24 0c 0b 2a 80 	movl   $0x802a0b,0xc(%esp)
  80167e:	00 
  80167f:	c7 44 24 08 eb 29 80 	movl   $0x8029eb,0x8(%esp)
  801686:	00 
  801687:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80168e:	00 
  80168f:	c7 04 24 00 2a 80 00 	movl   $0x802a00,(%esp)
  801696:	e8 d1 ea ff ff       	call   80016c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80169b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80169f:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  8016a6:	00 
  8016a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016aa:	89 04 24             	mov    %eax,(%esp)
  8016ad:	e8 d6 f2 ff ff       	call   800988 <memmove>
	return r;
}
  8016b2:	89 d8                	mov    %ebx,%eax
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	56                   	push   %esi
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 20             	sub    $0x20,%esp
  8016c3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016c6:	89 34 24             	mov    %esi,(%esp)
  8016c9:	e8 0e f1 ff ff       	call   8007dc <strlen>
  8016ce:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d3:	7f 60                	jg     801735 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d8:	89 04 24             	mov    %eax,(%esp)
  8016db:	e8 17 f8 ff ff       	call   800ef7 <fd_alloc>
  8016e0:	89 c3                	mov    %eax,%ebx
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 54                	js     80173a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ea:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  8016f1:	e8 19 f1 ff ff       	call   80080f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f9:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801701:	b8 01 00 00 00       	mov    $0x1,%eax
  801706:	e8 b1 fd ff ff       	call   8014bc <fsipc>
  80170b:	89 c3                	mov    %eax,%ebx
  80170d:	85 c0                	test   %eax,%eax
  80170f:	79 15                	jns    801726 <open+0x6b>
		fd_close(fd, 0);
  801711:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801718:	00 
  801719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171c:	89 04 24             	mov    %eax,(%esp)
  80171f:	e8 d6 f8 ff ff       	call   800ffa <fd_close>
		return r;
  801724:	eb 14                	jmp    80173a <open+0x7f>
	}

	return fd2num(fd);
  801726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801729:	89 04 24             	mov    %eax,(%esp)
  80172c:	e8 9b f7 ff ff       	call   800ecc <fd2num>
  801731:	89 c3                	mov    %eax,%ebx
  801733:	eb 05                	jmp    80173a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801735:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80173a:	89 d8                	mov    %ebx,%eax
  80173c:	83 c4 20             	add    $0x20,%esp
  80173f:	5b                   	pop    %ebx
  801740:	5e                   	pop    %esi
  801741:	5d                   	pop    %ebp
  801742:	c3                   	ret    

00801743 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	b8 08 00 00 00       	mov    $0x8,%eax
  801753:	e8 64 fd ff ff       	call   8014bc <fsipc>
}
  801758:	c9                   	leave  
  801759:	c3                   	ret    
	...

0080175c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801762:	c7 44 24 04 17 2a 80 	movl   $0x802a17,0x4(%esp)
  801769:	00 
  80176a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176d:	89 04 24             	mov    %eax,(%esp)
  801770:	e8 9a f0 ff ff       	call   80080f <strcpy>
	return 0;
}
  801775:	b8 00 00 00 00       	mov    $0x0,%eax
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	83 ec 14             	sub    $0x14,%esp
  801783:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801786:	89 1c 24             	mov    %ebx,(%esp)
  801789:	e8 1a 0b 00 00       	call   8022a8 <pageref>
  80178e:	83 f8 01             	cmp    $0x1,%eax
  801791:	75 0d                	jne    8017a0 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801793:	8b 43 0c             	mov    0xc(%ebx),%eax
  801796:	89 04 24             	mov    %eax,(%esp)
  801799:	e8 1f 03 00 00       	call   801abd <nsipc_close>
  80179e:	eb 05                	jmp    8017a5 <devsock_close+0x29>
	else
		return 0;
  8017a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a5:	83 c4 14             	add    $0x14,%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017b8:	00 
  8017b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cd:	89 04 24             	mov    %eax,(%esp)
  8017d0:	e8 e3 03 00 00       	call   801bb8 <nsipc_send>
}
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017e4:	00 
  8017e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f9:	89 04 24             	mov    %eax,(%esp)
  8017fc:	e8 37 03 00 00       	call   801b38 <nsipc_recv>
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	56                   	push   %esi
  801807:	53                   	push   %ebx
  801808:	83 ec 20             	sub    $0x20,%esp
  80180b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80180d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801810:	89 04 24             	mov    %eax,(%esp)
  801813:	e8 df f6 ff ff       	call   800ef7 <fd_alloc>
  801818:	89 c3                	mov    %eax,%ebx
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 21                	js     80183f <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80181e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801825:	00 
  801826:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801834:	e8 c8 f3 ff ff       	call   800c01 <sys_page_alloc>
  801839:	89 c3                	mov    %eax,%ebx
  80183b:	85 c0                	test   %eax,%eax
  80183d:	79 0a                	jns    801849 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80183f:	89 34 24             	mov    %esi,(%esp)
  801842:	e8 76 02 00 00       	call   801abd <nsipc_close>
		return r;
  801847:	eb 22                	jmp    80186b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801849:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80184f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801852:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801857:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80185e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801861:	89 04 24             	mov    %eax,(%esp)
  801864:	e8 63 f6 ff ff       	call   800ecc <fd2num>
  801869:	89 c3                	mov    %eax,%ebx
}
  80186b:	89 d8                	mov    %ebx,%eax
  80186d:	83 c4 20             	add    $0x20,%esp
  801870:	5b                   	pop    %ebx
  801871:	5e                   	pop    %esi
  801872:	5d                   	pop    %ebp
  801873:	c3                   	ret    

00801874 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80187a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80187d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801881:	89 04 24             	mov    %eax,(%esp)
  801884:	e8 c1 f6 ff ff       	call   800f4a <fd_lookup>
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 17                	js     8018a4 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80188d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801890:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801896:	39 10                	cmp    %edx,(%eax)
  801898:	75 05                	jne    80189f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80189a:	8b 40 0c             	mov    0xc(%eax),%eax
  80189d:	eb 05                	jmp    8018a4 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80189f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	e8 c0 ff ff ff       	call   801874 <fd2sockid>
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 1f                	js     8018d7 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018b8:	8b 55 10             	mov    0x10(%ebp),%edx
  8018bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018c6:	89 04 24             	mov    %eax,(%esp)
  8018c9:	e8 38 01 00 00       	call   801a06 <nsipc_accept>
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 05                	js     8018d7 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8018d2:	e8 2c ff ff ff       	call   801803 <alloc_sockfd>
}
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018df:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e2:	e8 8d ff ff ff       	call   801874 <fd2sockid>
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 16                	js     801901 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8018eb:	8b 55 10             	mov    0x10(%ebp),%edx
  8018ee:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018f9:	89 04 24             	mov    %eax,(%esp)
  8018fc:	e8 5b 01 00 00       	call   801a5c <nsipc_bind>
}
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <shutdown>:

int
shutdown(int s, int how)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801909:	8b 45 08             	mov    0x8(%ebp),%eax
  80190c:	e8 63 ff ff ff       	call   801874 <fd2sockid>
  801911:	85 c0                	test   %eax,%eax
  801913:	78 0f                	js     801924 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801915:	8b 55 0c             	mov    0xc(%ebp),%edx
  801918:	89 54 24 04          	mov    %edx,0x4(%esp)
  80191c:	89 04 24             	mov    %eax,(%esp)
  80191f:	e8 77 01 00 00       	call   801a9b <nsipc_shutdown>
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	e8 40 ff ff ff       	call   801874 <fd2sockid>
  801934:	85 c0                	test   %eax,%eax
  801936:	78 16                	js     80194e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801938:	8b 55 10             	mov    0x10(%ebp),%edx
  80193b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80193f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801942:	89 54 24 04          	mov    %edx,0x4(%esp)
  801946:	89 04 24             	mov    %eax,(%esp)
  801949:	e8 89 01 00 00       	call   801ad7 <nsipc_connect>
}
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <listen>:

int
listen(int s, int backlog)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	e8 16 ff ff ff       	call   801874 <fd2sockid>
  80195e:	85 c0                	test   %eax,%eax
  801960:	78 0f                	js     801971 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801962:	8b 55 0c             	mov    0xc(%ebp),%edx
  801965:	89 54 24 04          	mov    %edx,0x4(%esp)
  801969:	89 04 24             	mov    %eax,(%esp)
  80196c:	e8 a5 01 00 00       	call   801b16 <nsipc_listen>
}
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801979:	8b 45 10             	mov    0x10(%ebp),%eax
  80197c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801980:	8b 45 0c             	mov    0xc(%ebp),%eax
  801983:	89 44 24 04          	mov    %eax,0x4(%esp)
  801987:	8b 45 08             	mov    0x8(%ebp),%eax
  80198a:	89 04 24             	mov    %eax,(%esp)
  80198d:	e8 99 02 00 00       	call   801c2b <nsipc_socket>
  801992:	85 c0                	test   %eax,%eax
  801994:	78 05                	js     80199b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801996:	e8 68 fe ff ff       	call   801803 <alloc_sockfd>
}
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    
  80199d:	00 00                	add    %al,(%eax)
	...

008019a0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	53                   	push   %ebx
  8019a4:	83 ec 14             	sub    $0x14,%esp
  8019a7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019a9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019b0:	75 11                	jne    8019c3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019b2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8019b9:	e8 a5 08 00 00       	call   802263 <ipc_find_env>
  8019be:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019c3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019ca:	00 
  8019cb:	c7 44 24 08 00 60 c0 	movl   $0xc06000,0x8(%esp)
  8019d2:	00 
  8019d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8019dc:	89 04 24             	mov    %eax,(%esp)
  8019df:	e8 fc 07 00 00       	call   8021e0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019eb:	00 
  8019ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019f3:	00 
  8019f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fb:	e8 70 07 00 00       	call   802170 <ipc_recv>
}
  801a00:	83 c4 14             	add    $0x14,%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 10             	sub    $0x10,%esp
  801a0e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a19:	8b 06                	mov    (%esi),%eax
  801a1b:	a3 04 60 c0 00       	mov    %eax,0xc06004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a20:	b8 01 00 00 00       	mov    $0x1,%eax
  801a25:	e8 76 ff ff ff       	call   8019a0 <nsipc>
  801a2a:	89 c3                	mov    %eax,%ebx
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 23                	js     801a53 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a30:	a1 10 60 c0 00       	mov    0xc06010,%eax
  801a35:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a39:	c7 44 24 04 00 60 c0 	movl   $0xc06000,0x4(%esp)
  801a40:	00 
  801a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a44:	89 04 24             	mov    %eax,(%esp)
  801a47:	e8 3c ef ff ff       	call   800988 <memmove>
		*addrlen = ret->ret_addrlen;
  801a4c:	a1 10 60 c0 00       	mov    0xc06010,%eax
  801a51:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801a53:	89 d8                	mov    %ebx,%eax
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 14             	sub    $0x14,%esp
  801a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a66:	8b 45 08             	mov    0x8(%ebp),%eax
  801a69:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a79:	c7 04 24 04 60 c0 00 	movl   $0xc06004,(%esp)
  801a80:	e8 03 ef ff ff       	call   800988 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a85:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  801a8b:	b8 02 00 00 00       	mov    $0x2,%eax
  801a90:	e8 0b ff ff ff       	call   8019a0 <nsipc>
}
  801a95:	83 c4 14             	add    $0x14,%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa4:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  801aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aac:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  801ab1:	b8 03 00 00 00       	mov    $0x3,%eax
  801ab6:	e8 e5 fe ff ff       	call   8019a0 <nsipc>
}
  801abb:	c9                   	leave  
  801abc:	c3                   	ret    

00801abd <nsipc_close>:

int
nsipc_close(int s)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  801acb:	b8 04 00 00 00       	mov    $0x4,%eax
  801ad0:	e8 cb fe ff ff       	call   8019a0 <nsipc>
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	53                   	push   %ebx
  801adb:	83 ec 14             	sub    $0x14,%esp
  801ade:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ae9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af4:	c7 04 24 04 60 c0 00 	movl   $0xc06004,(%esp)
  801afb:	e8 88 ee ff ff       	call   800988 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b00:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  801b06:	b8 05 00 00 00       	mov    $0x5,%eax
  801b0b:	e8 90 fe ff ff       	call   8019a0 <nsipc>
}
  801b10:	83 c4 14             	add    $0x14,%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  801b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b27:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  801b2c:	b8 06 00 00 00       	mov    $0x6,%eax
  801b31:	e8 6a fe ff ff       	call   8019a0 <nsipc>
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	56                   	push   %esi
  801b3c:	53                   	push   %ebx
  801b3d:	83 ec 10             	sub    $0x10,%esp
  801b40:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
  801b46:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  801b4b:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  801b51:	8b 45 14             	mov    0x14(%ebp),%eax
  801b54:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b59:	b8 07 00 00 00       	mov    $0x7,%eax
  801b5e:	e8 3d fe ff ff       	call   8019a0 <nsipc>
  801b63:	89 c3                	mov    %eax,%ebx
  801b65:	85 c0                	test   %eax,%eax
  801b67:	78 46                	js     801baf <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801b69:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b6e:	7f 04                	jg     801b74 <nsipc_recv+0x3c>
  801b70:	39 c6                	cmp    %eax,%esi
  801b72:	7d 24                	jge    801b98 <nsipc_recv+0x60>
  801b74:	c7 44 24 0c 23 2a 80 	movl   $0x802a23,0xc(%esp)
  801b7b:	00 
  801b7c:	c7 44 24 08 eb 29 80 	movl   $0x8029eb,0x8(%esp)
  801b83:	00 
  801b84:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801b8b:	00 
  801b8c:	c7 04 24 38 2a 80 00 	movl   $0x802a38,(%esp)
  801b93:	e8 d4 e5 ff ff       	call   80016c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b98:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b9c:	c7 44 24 04 00 60 c0 	movl   $0xc06000,0x4(%esp)
  801ba3:	00 
  801ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba7:	89 04 24             	mov    %eax,(%esp)
  801baa:	e8 d9 ed ff ff       	call   800988 <memmove>
	}

	return r;
}
  801baf:	89 d8                	mov    %ebx,%eax
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 14             	sub    $0x14,%esp
  801bbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc5:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  801bca:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801bd0:	7e 24                	jle    801bf6 <nsipc_send+0x3e>
  801bd2:	c7 44 24 0c 44 2a 80 	movl   $0x802a44,0xc(%esp)
  801bd9:	00 
  801bda:	c7 44 24 08 eb 29 80 	movl   $0x8029eb,0x8(%esp)
  801be1:	00 
  801be2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801be9:	00 
  801bea:	c7 04 24 38 2a 80 00 	movl   $0x802a38,(%esp)
  801bf1:	e8 76 e5 ff ff       	call   80016c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801bf6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c01:	c7 04 24 0c 60 c0 00 	movl   $0xc0600c,(%esp)
  801c08:	e8 7b ed ff ff       	call   800988 <memmove>
	nsipcbuf.send.req_size = size;
  801c0d:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801c13:	8b 45 14             	mov    0x14(%ebp),%eax
  801c16:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801c1b:	b8 08 00 00 00       	mov    $0x8,%eax
  801c20:	e8 7b fd ff ff       	call   8019a0 <nsipc>
}
  801c25:	83 c4 14             	add    $0x14,%esp
  801c28:	5b                   	pop    %ebx
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c31:	8b 45 08             	mov    0x8(%ebp),%eax
  801c34:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801c39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3c:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801c41:	8b 45 10             	mov    0x10(%ebp),%eax
  801c44:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801c49:	b8 09 00 00 00       	mov    $0x9,%eax
  801c4e:	e8 4d fd ff ff       	call   8019a0 <nsipc>
}
  801c53:	c9                   	leave  
  801c54:	c3                   	ret    
  801c55:	00 00                	add    %al,(%eax)
	...

00801c58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	56                   	push   %esi
  801c5c:	53                   	push   %ebx
  801c5d:	83 ec 10             	sub    $0x10,%esp
  801c60:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	89 04 24             	mov    %eax,(%esp)
  801c69:	e8 6e f2 ff ff       	call   800edc <fd2data>
  801c6e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c70:	c7 44 24 04 50 2a 80 	movl   $0x802a50,0x4(%esp)
  801c77:	00 
  801c78:	89 34 24             	mov    %esi,(%esp)
  801c7b:	e8 8f eb ff ff       	call   80080f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c80:	8b 43 04             	mov    0x4(%ebx),%eax
  801c83:	2b 03                	sub    (%ebx),%eax
  801c85:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c8b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c92:	00 00 00 
	stat->st_dev = &devpipe;
  801c95:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801c9c:	30 80 00 
	return 0;
}
  801c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	5b                   	pop    %ebx
  801ca8:	5e                   	pop    %esi
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	53                   	push   %ebx
  801caf:	83 ec 14             	sub    $0x14,%esp
  801cb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc0:	e8 e3 ef ff ff       	call   800ca8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cc5:	89 1c 24             	mov    %ebx,(%esp)
  801cc8:	e8 0f f2 ff ff       	call   800edc <fd2data>
  801ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd8:	e8 cb ef ff ff       	call   800ca8 <sys_page_unmap>
}
  801cdd:	83 c4 14             	add    $0x14,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	57                   	push   %edi
  801ce7:	56                   	push   %esi
  801ce8:	53                   	push   %ebx
  801ce9:	83 ec 2c             	sub    $0x2c,%esp
  801cec:	89 c7                	mov    %eax,%edi
  801cee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cf1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801cf6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cf9:	89 3c 24             	mov    %edi,(%esp)
  801cfc:	e8 a7 05 00 00       	call   8022a8 <pageref>
  801d01:	89 c6                	mov    %eax,%esi
  801d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d06:	89 04 24             	mov    %eax,(%esp)
  801d09:	e8 9a 05 00 00       	call   8022a8 <pageref>
  801d0e:	39 c6                	cmp    %eax,%esi
  801d10:	0f 94 c0             	sete   %al
  801d13:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d16:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801d1c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d1f:	39 cb                	cmp    %ecx,%ebx
  801d21:	75 08                	jne    801d2b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d23:	83 c4 2c             	add    $0x2c,%esp
  801d26:	5b                   	pop    %ebx
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d2b:	83 f8 01             	cmp    $0x1,%eax
  801d2e:	75 c1                	jne    801cf1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d30:	8b 42 58             	mov    0x58(%edx),%eax
  801d33:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d3a:	00 
  801d3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d43:	c7 04 24 57 2a 80 00 	movl   $0x802a57,(%esp)
  801d4a:	e8 15 e5 ff ff       	call   800264 <cprintf>
  801d4f:	eb a0                	jmp    801cf1 <_pipeisclosed+0xe>

00801d51 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	57                   	push   %edi
  801d55:	56                   	push   %esi
  801d56:	53                   	push   %ebx
  801d57:	83 ec 1c             	sub    $0x1c,%esp
  801d5a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d5d:	89 34 24             	mov    %esi,(%esp)
  801d60:	e8 77 f1 ff ff       	call   800edc <fd2data>
  801d65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d67:	bf 00 00 00 00       	mov    $0x0,%edi
  801d6c:	eb 3c                	jmp    801daa <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d6e:	89 da                	mov    %ebx,%edx
  801d70:	89 f0                	mov    %esi,%eax
  801d72:	e8 6c ff ff ff       	call   801ce3 <_pipeisclosed>
  801d77:	85 c0                	test   %eax,%eax
  801d79:	75 38                	jne    801db3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d7b:	e8 62 ee ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d80:	8b 43 04             	mov    0x4(%ebx),%eax
  801d83:	8b 13                	mov    (%ebx),%edx
  801d85:	83 c2 20             	add    $0x20,%edx
  801d88:	39 d0                	cmp    %edx,%eax
  801d8a:	73 e2                	jae    801d6e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d92:	89 c2                	mov    %eax,%edx
  801d94:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d9a:	79 05                	jns    801da1 <devpipe_write+0x50>
  801d9c:	4a                   	dec    %edx
  801d9d:	83 ca e0             	or     $0xffffffe0,%edx
  801da0:	42                   	inc    %edx
  801da1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801da5:	40                   	inc    %eax
  801da6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da9:	47                   	inc    %edi
  801daa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dad:	75 d1                	jne    801d80 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801daf:	89 f8                	mov    %edi,%eax
  801db1:	eb 05                	jmp    801db8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801db3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801db8:	83 c4 1c             	add    $0x1c,%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5f                   	pop    %edi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	57                   	push   %edi
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	83 ec 1c             	sub    $0x1c,%esp
  801dc9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dcc:	89 3c 24             	mov    %edi,(%esp)
  801dcf:	e8 08 f1 ff ff       	call   800edc <fd2data>
  801dd4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd6:	be 00 00 00 00       	mov    $0x0,%esi
  801ddb:	eb 3a                	jmp    801e17 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ddd:	85 f6                	test   %esi,%esi
  801ddf:	74 04                	je     801de5 <devpipe_read+0x25>
				return i;
  801de1:	89 f0                	mov    %esi,%eax
  801de3:	eb 40                	jmp    801e25 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801de5:	89 da                	mov    %ebx,%edx
  801de7:	89 f8                	mov    %edi,%eax
  801de9:	e8 f5 fe ff ff       	call   801ce3 <_pipeisclosed>
  801dee:	85 c0                	test   %eax,%eax
  801df0:	75 2e                	jne    801e20 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801df2:	e8 eb ed ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801df7:	8b 03                	mov    (%ebx),%eax
  801df9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dfc:	74 df                	je     801ddd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dfe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e03:	79 05                	jns    801e0a <devpipe_read+0x4a>
  801e05:	48                   	dec    %eax
  801e06:	83 c8 e0             	or     $0xffffffe0,%eax
  801e09:	40                   	inc    %eax
  801e0a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e11:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e14:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e16:	46                   	inc    %esi
  801e17:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e1a:	75 db                	jne    801df7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e1c:	89 f0                	mov    %esi,%eax
  801e1e:	eb 05                	jmp    801e25 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	57                   	push   %edi
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
  801e33:	83 ec 3c             	sub    $0x3c,%esp
  801e36:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e3c:	89 04 24             	mov    %eax,(%esp)
  801e3f:	e8 b3 f0 ff ff       	call   800ef7 <fd_alloc>
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	85 c0                	test   %eax,%eax
  801e48:	0f 88 45 01 00 00    	js     801f93 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e55:	00 
  801e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e64:	e8 98 ed ff ff       	call   800c01 <sys_page_alloc>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	0f 88 20 01 00 00    	js     801f93 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e73:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e76:	89 04 24             	mov    %eax,(%esp)
  801e79:	e8 79 f0 ff ff       	call   800ef7 <fd_alloc>
  801e7e:	89 c3                	mov    %eax,%ebx
  801e80:	85 c0                	test   %eax,%eax
  801e82:	0f 88 f8 00 00 00    	js     801f80 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e88:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e8f:	00 
  801e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9e:	e8 5e ed ff ff       	call   800c01 <sys_page_alloc>
  801ea3:	89 c3                	mov    %eax,%ebx
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	0f 88 d3 00 00 00    	js     801f80 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eb0:	89 04 24             	mov    %eax,(%esp)
  801eb3:	e8 24 f0 ff ff       	call   800edc <fd2data>
  801eb8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec1:	00 
  801ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecd:	e8 2f ed ff ff       	call   800c01 <sys_page_alloc>
  801ed2:	89 c3                	mov    %eax,%ebx
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	0f 88 91 00 00 00    	js     801f6d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801edc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801edf:	89 04 24             	mov    %eax,(%esp)
  801ee2:	e8 f5 ef ff ff       	call   800edc <fd2data>
  801ee7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801eee:	00 
  801eef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ef3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801efa:	00 
  801efb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f06:	e8 4a ed ff ff       	call   800c55 <sys_page_map>
  801f0b:	89 c3                	mov    %eax,%ebx
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	78 4c                	js     801f5d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f11:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f26:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f3e:	89 04 24             	mov    %eax,(%esp)
  801f41:	e8 86 ef ff ff       	call   800ecc <fd2num>
  801f46:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f4b:	89 04 24             	mov    %eax,(%esp)
  801f4e:	e8 79 ef ff ff       	call   800ecc <fd2num>
  801f53:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f56:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f5b:	eb 36                	jmp    801f93 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f5d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f68:	e8 3b ed ff ff       	call   800ca8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f7b:	e8 28 ed ff ff       	call   800ca8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8e:	e8 15 ed ff ff       	call   800ca8 <sys_page_unmap>
    err:
	return r;
}
  801f93:	89 d8                	mov    %ebx,%eax
  801f95:	83 c4 3c             	add    $0x3c,%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801faa:	8b 45 08             	mov    0x8(%ebp),%eax
  801fad:	89 04 24             	mov    %eax,(%esp)
  801fb0:	e8 95 ef ff ff       	call   800f4a <fd_lookup>
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	78 15                	js     801fce <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbc:	89 04 24             	mov    %eax,(%esp)
  801fbf:	e8 18 ef ff ff       	call   800edc <fd2data>
	return _pipeisclosed(fd, p);
  801fc4:	89 c2                	mov    %eax,%edx
  801fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc9:	e8 15 fd ff ff       	call   801ce3 <_pipeisclosed>
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fe0:	c7 44 24 04 6f 2a 80 	movl   $0x802a6f,0x4(%esp)
  801fe7:	00 
  801fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801feb:	89 04 24             	mov    %eax,(%esp)
  801fee:	e8 1c e8 ff ff       	call   80080f <strcpy>
	return 0;
}
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    

00801ffa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	57                   	push   %edi
  801ffe:	56                   	push   %esi
  801fff:	53                   	push   %ebx
  802000:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802006:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80200b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802011:	eb 30                	jmp    802043 <devcons_write+0x49>
		m = n - tot;
  802013:	8b 75 10             	mov    0x10(%ebp),%esi
  802016:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802018:	83 fe 7f             	cmp    $0x7f,%esi
  80201b:	76 05                	jbe    802022 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80201d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802022:	89 74 24 08          	mov    %esi,0x8(%esp)
  802026:	03 45 0c             	add    0xc(%ebp),%eax
  802029:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202d:	89 3c 24             	mov    %edi,(%esp)
  802030:	e8 53 e9 ff ff       	call   800988 <memmove>
		sys_cputs(buf, m);
  802035:	89 74 24 04          	mov    %esi,0x4(%esp)
  802039:	89 3c 24             	mov    %edi,(%esp)
  80203c:	e8 f3 ea ff ff       	call   800b34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802041:	01 f3                	add    %esi,%ebx
  802043:	89 d8                	mov    %ebx,%eax
  802045:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802048:	72 c9                	jb     802013 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80204a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    

00802055 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802055:	55                   	push   %ebp
  802056:	89 e5                	mov    %esp,%ebp
  802058:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80205b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80205f:	75 07                	jne    802068 <devcons_read+0x13>
  802061:	eb 25                	jmp    802088 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802063:	e8 7a eb ff ff       	call   800be2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802068:	e8 e5 ea ff ff       	call   800b52 <sys_cgetc>
  80206d:	85 c0                	test   %eax,%eax
  80206f:	74 f2                	je     802063 <devcons_read+0xe>
  802071:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802073:	85 c0                	test   %eax,%eax
  802075:	78 1d                	js     802094 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802077:	83 f8 04             	cmp    $0x4,%eax
  80207a:	74 13                	je     80208f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80207c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207f:	88 10                	mov    %dl,(%eax)
	return 1;
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	eb 0c                	jmp    802094 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802088:	b8 00 00 00 00       	mov    $0x0,%eax
  80208d:	eb 05                	jmp    802094 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80208f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    

00802096 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80209c:	8b 45 08             	mov    0x8(%ebp),%eax
  80209f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020a9:	00 
  8020aa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ad:	89 04 24             	mov    %eax,(%esp)
  8020b0:	e8 7f ea ff ff       	call   800b34 <sys_cputs>
}
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    

008020b7 <getchar>:

int
getchar(void)
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020c4:	00 
  8020c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d3:	e8 10 f1 ff ff       	call   8011e8 <read>
	if (r < 0)
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	78 0f                	js     8020eb <getchar+0x34>
		return r;
	if (r < 1)
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	7e 06                	jle    8020e6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020e4:	eb 05                	jmp    8020eb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020eb:	c9                   	leave  
  8020ec:	c3                   	ret    

008020ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fd:	89 04 24             	mov    %eax,(%esp)
  802100:	e8 45 ee ff ff       	call   800f4a <fd_lookup>
  802105:	85 c0                	test   %eax,%eax
  802107:	78 11                	js     80211a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802109:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802112:	39 10                	cmp    %edx,(%eax)
  802114:	0f 94 c0             	sete   %al
  802117:	0f b6 c0             	movzbl %al,%eax
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <opencons>:

int
opencons(void)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802125:	89 04 24             	mov    %eax,(%esp)
  802128:	e8 ca ed ff ff       	call   800ef7 <fd_alloc>
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 3c                	js     80216d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802131:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802138:	00 
  802139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802147:	e8 b5 ea ff ff       	call   800c01 <sys_page_alloc>
  80214c:	85 c0                	test   %eax,%eax
  80214e:	78 1d                	js     80216d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802150:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802159:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80215b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802165:	89 04 24             	mov    %eax,(%esp)
  802168:	e8 5f ed ff ff       	call   800ecc <fd2num>
}
  80216d:	c9                   	leave  
  80216e:	c3                   	ret    
	...

00802170 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	56                   	push   %esi
  802174:	53                   	push   %ebx
  802175:	83 ec 10             	sub    $0x10,%esp
  802178:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80217b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802181:	85 c0                	test   %eax,%eax
  802183:	74 0a                	je     80218f <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802185:	89 04 24             	mov    %eax,(%esp)
  802188:	e8 8a ec ff ff       	call   800e17 <sys_ipc_recv>
  80218d:	eb 0c                	jmp    80219b <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80218f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802196:	e8 7c ec ff ff       	call   800e17 <sys_ipc_recv>
	}
	if (r < 0)
  80219b:	85 c0                	test   %eax,%eax
  80219d:	79 16                	jns    8021b5 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80219f:	85 db                	test   %ebx,%ebx
  8021a1:	74 06                	je     8021a9 <ipc_recv+0x39>
  8021a3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8021a9:	85 f6                	test   %esi,%esi
  8021ab:	74 2c                	je     8021d9 <ipc_recv+0x69>
  8021ad:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8021b3:	eb 24                	jmp    8021d9 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8021b5:	85 db                	test   %ebx,%ebx
  8021b7:	74 0a                	je     8021c3 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8021b9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8021be:	8b 40 74             	mov    0x74(%eax),%eax
  8021c1:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8021c3:	85 f6                	test   %esi,%esi
  8021c5:	74 0a                	je     8021d1 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8021c7:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8021cc:	8b 40 78             	mov    0x78(%eax),%eax
  8021cf:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8021d1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8021d6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8021d9:	83 c4 10             	add    $0x10,%esp
  8021dc:	5b                   	pop    %ebx
  8021dd:	5e                   	pop    %esi
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    

008021e0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	57                   	push   %edi
  8021e4:	56                   	push   %esi
  8021e5:	53                   	push   %ebx
  8021e6:	83 ec 1c             	sub    $0x1c,%esp
  8021e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8021ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8021f2:	85 db                	test   %ebx,%ebx
  8021f4:	74 19                	je     80220f <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8021f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8021f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802201:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802205:	89 34 24             	mov    %esi,(%esp)
  802208:	e8 e7 eb ff ff       	call   800df4 <sys_ipc_try_send>
  80220d:	eb 1c                	jmp    80222b <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80220f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802216:	00 
  802217:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80221e:	ee 
  80221f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802223:	89 34 24             	mov    %esi,(%esp)
  802226:	e8 c9 eb ff ff       	call   800df4 <sys_ipc_try_send>
		}
		if (r == 0)
  80222b:	85 c0                	test   %eax,%eax
  80222d:	74 2c                	je     80225b <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80222f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802232:	74 20                	je     802254 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802234:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802238:	c7 44 24 08 7b 2a 80 	movl   $0x802a7b,0x8(%esp)
  80223f:	00 
  802240:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802247:	00 
  802248:	c7 04 24 8e 2a 80 00 	movl   $0x802a8e,(%esp)
  80224f:	e8 18 df ff ff       	call   80016c <_panic>
		}
		sys_yield();
  802254:	e8 89 e9 ff ff       	call   800be2 <sys_yield>
	}
  802259:	eb 97                	jmp    8021f2 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80225b:	83 c4 1c             	add    $0x1c,%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5e                   	pop    %esi
  802260:	5f                   	pop    %edi
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    

00802263 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	53                   	push   %ebx
  802267:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80226a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80226f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802276:	89 c2                	mov    %eax,%edx
  802278:	c1 e2 07             	shl    $0x7,%edx
  80227b:	29 ca                	sub    %ecx,%edx
  80227d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802283:	8b 52 50             	mov    0x50(%edx),%edx
  802286:	39 da                	cmp    %ebx,%edx
  802288:	75 0f                	jne    802299 <ipc_find_env+0x36>
			return envs[i].env_id;
  80228a:	c1 e0 07             	shl    $0x7,%eax
  80228d:	29 c8                	sub    %ecx,%eax
  80228f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802294:	8b 40 40             	mov    0x40(%eax),%eax
  802297:	eb 0c                	jmp    8022a5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802299:	40                   	inc    %eax
  80229a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80229f:	75 ce                	jne    80226f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022a1:	66 b8 00 00          	mov    $0x0,%ax
}
  8022a5:	5b                   	pop    %ebx
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    

008022a8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022ae:	89 c2                	mov    %eax,%edx
  8022b0:	c1 ea 16             	shr    $0x16,%edx
  8022b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022ba:	f6 c2 01             	test   $0x1,%dl
  8022bd:	74 1e                	je     8022dd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022bf:	c1 e8 0c             	shr    $0xc,%eax
  8022c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022c9:	a8 01                	test   $0x1,%al
  8022cb:	74 17                	je     8022e4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022cd:	c1 e8 0c             	shr    $0xc,%eax
  8022d0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022d7:	ef 
  8022d8:	0f b7 c0             	movzwl %ax,%eax
  8022db:	eb 0c                	jmp    8022e9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e2:	eb 05                	jmp    8022e9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022e4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022e9:	5d                   	pop    %ebp
  8022ea:	c3                   	ret    
	...

008022ec <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8022ec:	55                   	push   %ebp
  8022ed:	57                   	push   %edi
  8022ee:	56                   	push   %esi
  8022ef:	83 ec 10             	sub    $0x10,%esp
  8022f2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022f6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fe:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802302:	89 cd                	mov    %ecx,%ebp
  802304:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802308:	85 c0                	test   %eax,%eax
  80230a:	75 2c                	jne    802338 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80230c:	39 f9                	cmp    %edi,%ecx
  80230e:	77 68                	ja     802378 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802310:	85 c9                	test   %ecx,%ecx
  802312:	75 0b                	jne    80231f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802314:	b8 01 00 00 00       	mov    $0x1,%eax
  802319:	31 d2                	xor    %edx,%edx
  80231b:	f7 f1                	div    %ecx
  80231d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80231f:	31 d2                	xor    %edx,%edx
  802321:	89 f8                	mov    %edi,%eax
  802323:	f7 f1                	div    %ecx
  802325:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802327:	89 f0                	mov    %esi,%eax
  802329:	f7 f1                	div    %ecx
  80232b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80232d:	89 f0                	mov    %esi,%eax
  80232f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802331:	83 c4 10             	add    $0x10,%esp
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802338:	39 f8                	cmp    %edi,%eax
  80233a:	77 2c                	ja     802368 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80233c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80233f:	83 f6 1f             	xor    $0x1f,%esi
  802342:	75 4c                	jne    802390 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802344:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802346:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80234b:	72 0a                	jb     802357 <__udivdi3+0x6b>
  80234d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802351:	0f 87 ad 00 00 00    	ja     802404 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802357:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80235c:	89 f0                	mov    %esi,%eax
  80235e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802360:	83 c4 10             	add    $0x10,%esp
  802363:	5e                   	pop    %esi
  802364:	5f                   	pop    %edi
  802365:	5d                   	pop    %ebp
  802366:	c3                   	ret    
  802367:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802368:	31 ff                	xor    %edi,%edi
  80236a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80236c:	89 f0                	mov    %esi,%eax
  80236e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802370:	83 c4 10             	add    $0x10,%esp
  802373:	5e                   	pop    %esi
  802374:	5f                   	pop    %edi
  802375:	5d                   	pop    %ebp
  802376:	c3                   	ret    
  802377:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802378:	89 fa                	mov    %edi,%edx
  80237a:	89 f0                	mov    %esi,%eax
  80237c:	f7 f1                	div    %ecx
  80237e:	89 c6                	mov    %eax,%esi
  802380:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802382:	89 f0                	mov    %esi,%eax
  802384:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802386:	83 c4 10             	add    $0x10,%esp
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802390:	89 f1                	mov    %esi,%ecx
  802392:	d3 e0                	shl    %cl,%eax
  802394:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802398:	b8 20 00 00 00       	mov    $0x20,%eax
  80239d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80239f:	89 ea                	mov    %ebp,%edx
  8023a1:	88 c1                	mov    %al,%cl
  8023a3:	d3 ea                	shr    %cl,%edx
  8023a5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023a9:	09 ca                	or     %ecx,%edx
  8023ab:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8023af:	89 f1                	mov    %esi,%ecx
  8023b1:	d3 e5                	shl    %cl,%ebp
  8023b3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8023b7:	89 fd                	mov    %edi,%ebp
  8023b9:	88 c1                	mov    %al,%cl
  8023bb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8023bd:	89 fa                	mov    %edi,%edx
  8023bf:	89 f1                	mov    %esi,%ecx
  8023c1:	d3 e2                	shl    %cl,%edx
  8023c3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023c7:	88 c1                	mov    %al,%cl
  8023c9:	d3 ef                	shr    %cl,%edi
  8023cb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023cd:	89 f8                	mov    %edi,%eax
  8023cf:	89 ea                	mov    %ebp,%edx
  8023d1:	f7 74 24 08          	divl   0x8(%esp)
  8023d5:	89 d1                	mov    %edx,%ecx
  8023d7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8023d9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023dd:	39 d1                	cmp    %edx,%ecx
  8023df:	72 17                	jb     8023f8 <__udivdi3+0x10c>
  8023e1:	74 09                	je     8023ec <__udivdi3+0x100>
  8023e3:	89 fe                	mov    %edi,%esi
  8023e5:	31 ff                	xor    %edi,%edi
  8023e7:	e9 41 ff ff ff       	jmp    80232d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8023ec:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023f0:	89 f1                	mov    %esi,%ecx
  8023f2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023f4:	39 c2                	cmp    %eax,%edx
  8023f6:	73 eb                	jae    8023e3 <__udivdi3+0xf7>
		{
		  q0--;
  8023f8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023fb:	31 ff                	xor    %edi,%edi
  8023fd:	e9 2b ff ff ff       	jmp    80232d <__udivdi3+0x41>
  802402:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802404:	31 f6                	xor    %esi,%esi
  802406:	e9 22 ff ff ff       	jmp    80232d <__udivdi3+0x41>
	...

0080240c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80240c:	55                   	push   %ebp
  80240d:	57                   	push   %edi
  80240e:	56                   	push   %esi
  80240f:	83 ec 20             	sub    $0x20,%esp
  802412:	8b 44 24 30          	mov    0x30(%esp),%eax
  802416:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80241a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80241e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802422:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802426:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80242a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80242c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80242e:	85 ed                	test   %ebp,%ebp
  802430:	75 16                	jne    802448 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802432:	39 f1                	cmp    %esi,%ecx
  802434:	0f 86 a6 00 00 00    	jbe    8024e0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80243a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80243c:	89 d0                	mov    %edx,%eax
  80243e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802440:	83 c4 20             	add    $0x20,%esp
  802443:	5e                   	pop    %esi
  802444:	5f                   	pop    %edi
  802445:	5d                   	pop    %ebp
  802446:	c3                   	ret    
  802447:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802448:	39 f5                	cmp    %esi,%ebp
  80244a:	0f 87 ac 00 00 00    	ja     8024fc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802450:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802453:	83 f0 1f             	xor    $0x1f,%eax
  802456:	89 44 24 10          	mov    %eax,0x10(%esp)
  80245a:	0f 84 a8 00 00 00    	je     802508 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802460:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802464:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802466:	bf 20 00 00 00       	mov    $0x20,%edi
  80246b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80246f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802473:	89 f9                	mov    %edi,%ecx
  802475:	d3 e8                	shr    %cl,%eax
  802477:	09 e8                	or     %ebp,%eax
  802479:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80247d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802481:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802485:	d3 e0                	shl    %cl,%eax
  802487:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80248b:	89 f2                	mov    %esi,%edx
  80248d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80248f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802493:	d3 e0                	shl    %cl,%eax
  802495:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802499:	8b 44 24 14          	mov    0x14(%esp),%eax
  80249d:	89 f9                	mov    %edi,%ecx
  80249f:	d3 e8                	shr    %cl,%eax
  8024a1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8024a3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024a5:	89 f2                	mov    %esi,%edx
  8024a7:	f7 74 24 18          	divl   0x18(%esp)
  8024ab:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8024ad:	f7 64 24 0c          	mull   0xc(%esp)
  8024b1:	89 c5                	mov    %eax,%ebp
  8024b3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024b5:	39 d6                	cmp    %edx,%esi
  8024b7:	72 67                	jb     802520 <__umoddi3+0x114>
  8024b9:	74 75                	je     802530 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8024bb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024bf:	29 e8                	sub    %ebp,%eax
  8024c1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8024c3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024c7:	d3 e8                	shr    %cl,%eax
  8024c9:	89 f2                	mov    %esi,%edx
  8024cb:	89 f9                	mov    %edi,%ecx
  8024cd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8024cf:	09 d0                	or     %edx,%eax
  8024d1:	89 f2                	mov    %esi,%edx
  8024d3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024d7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024d9:	83 c4 20             	add    $0x20,%esp
  8024dc:	5e                   	pop    %esi
  8024dd:	5f                   	pop    %edi
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024e0:	85 c9                	test   %ecx,%ecx
  8024e2:	75 0b                	jne    8024ef <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e9:	31 d2                	xor    %edx,%edx
  8024eb:	f7 f1                	div    %ecx
  8024ed:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024ef:	89 f0                	mov    %esi,%eax
  8024f1:	31 d2                	xor    %edx,%edx
  8024f3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024f5:	89 f8                	mov    %edi,%eax
  8024f7:	e9 3e ff ff ff       	jmp    80243a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8024fc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024fe:	83 c4 20             	add    $0x20,%esp
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    
  802505:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802508:	39 f5                	cmp    %esi,%ebp
  80250a:	72 04                	jb     802510 <__umoddi3+0x104>
  80250c:	39 f9                	cmp    %edi,%ecx
  80250e:	77 06                	ja     802516 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802510:	89 f2                	mov    %esi,%edx
  802512:	29 cf                	sub    %ecx,%edi
  802514:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802516:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802518:	83 c4 20             	add    $0x20,%esp
  80251b:	5e                   	pop    %esi
  80251c:	5f                   	pop    %edi
  80251d:	5d                   	pop    %ebp
  80251e:	c3                   	ret    
  80251f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802520:	89 d1                	mov    %edx,%ecx
  802522:	89 c5                	mov    %eax,%ebp
  802524:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802528:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80252c:	eb 8d                	jmp    8024bb <__umoddi3+0xaf>
  80252e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802530:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802534:	72 ea                	jb     802520 <__umoddi3+0x114>
  802536:	89 f1                	mov    %esi,%ecx
  802538:	eb 81                	jmp    8024bb <__umoddi3+0xaf>
