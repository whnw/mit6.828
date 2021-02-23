
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 8f 01 00 00       	call   8001c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  800043:	8d 5d e7             	lea    -0x19(%ebp),%ebx
  800046:	eb 7f                	jmp    8000c7 <num+0x93>
		if (bol) {
  800048:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004f:	74 25                	je     800076 <num+0x42>
			printf("%5d ", ++line);
  800051:	a1 00 40 80 00       	mov    0x804000,%eax
  800056:	40                   	inc    %eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800060:	c7 04 24 40 27 80 00 	movl   $0x802740,(%esp)
  800067:	e8 c9 18 00 00       	call   801935 <printf>
			bol = 0;
  80006c:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800073:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  800076:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80007d:	00 
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800089:	e8 f9 12 00 00       	call   801387 <write>
  80008e:	83 f8 01             	cmp    $0x1,%eax
  800091:	74 24                	je     8000b7 <num+0x83>
			panic("write error copying %s: %e", s, r);
  800093:	89 44 24 10          	mov    %eax,0x10(%esp)
  800097:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80009b:	c7 44 24 08 45 27 80 	movl   $0x802745,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000aa:	00 
  8000ab:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  8000b2:	e8 79 01 00 00       	call   800230 <_panic>
		if (c == '\n')
  8000b7:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8000bb:	75 0a                	jne    8000c7 <num+0x93>
			bol = 1;
  8000bd:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c4:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000ce:	00 
  8000cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d3:	89 34 24             	mov    %esi,(%esp)
  8000d6:	e8 d1 11 00 00       	call   8012ac <read>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	0f 8f 65 ff ff ff    	jg     800048 <num+0x14>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	79 24                	jns    80010b <num+0xd7>
		panic("error reading %s: %e", s, n);
  8000e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000ef:	c7 44 24 08 6b 27 80 	movl   $0x80276b,0x8(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8000fe:	00 
  8000ff:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  800106:	e8 25 01 00 00       	call   800230 <_panic>
}
  80010b:	83 c4 3c             	add    $0x3c,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <umain>:

void
umain(int argc, char **argv)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 3c             	sub    $0x3c,%esp
	int f, i;

	binaryname = "num";
  80011c:	c7 05 04 30 80 00 80 	movl   $0x802780,0x803004
  800123:	27 80 00 
	if (argc == 1)
  800126:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80012a:	74 0d                	je     800139 <umain+0x26>
	if (n < 0)
		panic("error reading %s: %e", s, n);
}

void
umain(int argc, char **argv)
  80012c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80012f:	83 c3 04             	add    $0x4,%ebx
  800132:	bf 01 00 00 00       	mov    $0x1,%edi
  800137:	eb 74                	jmp    8001ad <umain+0x9a>
{
	int f, i;

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
  800139:	c7 44 24 04 84 27 80 	movl   $0x802784,0x4(%esp)
  800140:	00 
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <num>
  80014d:	eb 63                	jmp    8001b2 <umain+0x9f>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80014f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800159:	00 
  80015a:	8b 03                	mov    (%ebx),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 1b 16 00 00       	call   80177f <open>
  800164:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800166:	85 c0                	test   %eax,%eax
  800168:	79 29                	jns    800193 <umain+0x80>
				panic("can't open %s: %e", argv[i], f);
  80016a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80016e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800171:	8b 02                	mov    (%edx),%eax
  800173:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800177:	c7 44 24 08 8c 27 80 	movl   $0x80278c,0x8(%esp)
  80017e:	00 
  80017f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800186:	00 
  800187:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  80018e:	e8 9d 00 00 00       	call   800230 <_panic>
			else {
				num(f, argv[i]);
  800193:	8b 03                	mov    (%ebx),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	89 34 24             	mov    %esi,(%esp)
  80019c:	e8 93 fe ff ff       	call   800034 <num>
				close(f);
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 9d 0f 00 00       	call   801146 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8001a9:	47                   	inc    %edi
  8001aa:	83 c3 04             	add    $0x4,%ebx
  8001ad:	3b 7d 08             	cmp    0x8(%ebp),%edi
  8001b0:	7c 9d                	jl     80014f <umain+0x3c>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  8001b2:	e8 5d 00 00 00       	call   800214 <exit>
}
  8001b7:	83 c4 3c             	add    $0x3c,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5f                   	pop    %edi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    
	...

008001c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 10             	sub    $0x10,%esp
  8001c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ce:	e8 b4 0a 00 00       	call   800c87 <sys_getenvid>
  8001d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001df:	c1 e0 07             	shl    $0x7,%eax
  8001e2:	29 d0                	sub    %edx,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 0c 40 80 00       	mov    %eax,0x80400c


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 f6                	test   %esi,%esi
  8001f0:	7e 07                	jle    8001f9 <libmain+0x39>
		binaryname = argv[0];
  8001f2:	8b 03                	mov    (%ebx),%eax
  8001f4:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001fd:	89 34 24             	mov    %esi,(%esp)
  800200:	e8 0e ff ff ff       	call   800113 <umain>

	// exit gracefully
	exit();
  800205:	e8 0a 00 00 00       	call   800214 <exit>
}
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    
  800211:	00 00                	add    %al,(%eax)
	...

00800214 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80021a:	e8 58 0f 00 00       	call   801177 <close_all>
	sys_env_destroy(0);
  80021f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800226:	e8 0a 0a 00 00       	call   800c35 <sys_env_destroy>
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    
  80022d:	00 00                	add    %al,(%eax)
	...

00800230 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800238:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023b:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800241:	e8 41 0a 00 00       	call   800c87 <sys_getenvid>
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 54 24 10          	mov    %edx,0x10(%esp)
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	c7 04 24 a8 27 80 00 	movl   $0x8027a8,(%esp)
  800263:	e8 c0 00 00 00       	call   800328 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800268:	89 74 24 04          	mov    %esi,0x4(%esp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 50 00 00 00       	call   8002c7 <vcprintf>
	cprintf("\n");
  800277:	c7 04 24 08 2c 80 00 	movl   $0x802c08,(%esp)
  80027e:	e8 a5 00 00 00       	call   800328 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800283:	cc                   	int3   
  800284:	eb fd                	jmp    800283 <_panic+0x53>
	...

00800288 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	53                   	push   %ebx
  80028c:	83 ec 14             	sub    $0x14,%esp
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800292:	8b 03                	mov    (%ebx),%eax
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029b:	40                   	inc    %eax
  80029c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a3:	75 19                	jne    8002be <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002ac:	00 
  8002ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 40 09 00 00       	call   800bf8 <sys_cputs>
		b->idx = 0;
  8002b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002be:	ff 43 04             	incl   0x4(%ebx)
}
  8002c1:	83 c4 14             	add    $0x14,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d7:	00 00 00 
	b.cnt = 0;
  8002da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fc:	c7 04 24 88 02 80 00 	movl   $0x800288,(%esp)
  800303:	e8 82 01 00 00       	call   80048a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800308:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80030e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800312:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 d8 08 00 00       	call   800bf8 <sys_cputs>

	return b.cnt;
}
  800320:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 87 ff ff ff       	call   8002c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    
	...

00800344 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 3c             	sub    $0x3c,%esp
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	89 d7                	mov    %edx,%edi
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800361:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800364:	85 c0                	test   %eax,%eax
  800366:	75 08                	jne    800370 <printnum+0x2c>
  800368:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036e:	77 57                	ja     8003c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800370:	89 74 24 10          	mov    %esi,0x10(%esp)
  800374:	4b                   	dec    %ebx
  800375:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800379:	8b 45 10             	mov    0x10(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800384:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800388:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038f:	00 
  800390:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	e8 46 21 00 00       	call   8024e8 <__udivdi3>
  8003a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b1:	89 fa                	mov    %edi,%edx
  8003b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b6:	e8 89 ff ff ff       	call   800344 <printnum>
  8003bb:	eb 0f                	jmp    8003cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c1:	89 34 24             	mov    %esi,(%esp)
  8003c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c7:	4b                   	dec    %ebx
  8003c8:	85 db                	test   %ebx,%ebx
  8003ca:	7f f1                	jg     8003bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e2:	00 
  8003e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e6:	89 04 24             	mov    %eax,(%esp)
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	e8 13 22 00 00       	call   802608 <__umoddi3>
  8003f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f9:	0f be 80 cb 27 80 00 	movsbl 0x8027cb(%eax),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800406:	83 c4 3c             	add    $0x3c,%esp
  800409:	5b                   	pop    %ebx
  80040a:	5e                   	pop    %esi
  80040b:	5f                   	pop    %edi
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800411:	83 fa 01             	cmp    $0x1,%edx
  800414:	7e 0e                	jle    800424 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800416:	8b 10                	mov    (%eax),%edx
  800418:	8d 4a 08             	lea    0x8(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 02                	mov    (%edx),%eax
  80041f:	8b 52 04             	mov    0x4(%edx),%edx
  800422:	eb 22                	jmp    800446 <getuint+0x38>
	else if (lflag)
  800424:	85 d2                	test   %edx,%edx
  800426:	74 10                	je     800438 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800428:	8b 10                	mov    (%eax),%edx
  80042a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042d:	89 08                	mov    %ecx,(%eax)
  80042f:	8b 02                	mov    (%edx),%eax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	eb 0e                	jmp    800446 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800438:	8b 10                	mov    (%eax),%edx
  80043a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043d:	89 08                	mov    %ecx,(%eax)
  80043f:	8b 02                	mov    (%edx),%eax
  800441:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800451:	8b 10                	mov    (%eax),%edx
  800453:	3b 50 04             	cmp    0x4(%eax),%edx
  800456:	73 08                	jae    800460 <sprintputch+0x18>
		*b->buf++ = ch;
  800458:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045b:	88 0a                	mov    %cl,(%edx)
  80045d:	42                   	inc    %edx
  80045e:	89 10                	mov    %edx,(%eax)
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80046b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046f:	8b 45 10             	mov    0x10(%ebp),%eax
  800472:	89 44 24 08          	mov    %eax,0x8(%esp)
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 02 00 00 00       	call   80048a <vprintfmt>
	va_end(ap);
}
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	57                   	push   %edi
  80048e:	56                   	push   %esi
  80048f:	53                   	push   %ebx
  800490:	83 ec 4c             	sub    $0x4c,%esp
  800493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800496:	8b 75 10             	mov    0x10(%ebp),%esi
  800499:	eb 12                	jmp    8004ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80049b:	85 c0                	test   %eax,%eax
  80049d:	0f 84 6b 03 00 00    	je     80080e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ad:	0f b6 06             	movzbl (%esi),%eax
  8004b0:	46                   	inc    %esi
  8004b1:	83 f8 25             	cmp    $0x25,%eax
  8004b4:	75 e5                	jne    80049b <vprintfmt+0x11>
  8004b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d2:	eb 26                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004db:	eb 1d                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004e4:	eb 14                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	0f b6 06             	movzbl (%esi),%eax
  8004fd:	8d 56 01             	lea    0x1(%esi),%edx
  800500:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800503:	8a 16                	mov    (%esi),%dl
  800505:	83 ea 23             	sub    $0x23,%edx
  800508:	80 fa 55             	cmp    $0x55,%dl
  80050b:	0f 87 e1 02 00 00    	ja     8007f2 <vprintfmt+0x368>
  800511:	0f b6 d2             	movzbl %dl,%edx
  800514:	ff 24 95 00 29 80 00 	jmp    *0x802900(,%edx,4)
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800523:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800526:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80052a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80052d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800530:	83 fa 09             	cmp    $0x9,%edx
  800533:	77 2a                	ja     80055f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800535:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800536:	eb eb                	jmp    800523 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800546:	eb 17                	jmp    80055f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800548:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054c:	78 98                	js     8004e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800551:	eb a7                	jmp    8004fa <vprintfmt+0x70>
  800553:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800556:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80055d:	eb 9b                	jmp    8004fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80055f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800563:	79 95                	jns    8004fa <vprintfmt+0x70>
  800565:	eb 8b                	jmp    8004f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800567:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056b:	eb 8d                	jmp    8004fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800585:	e9 23 ff ff ff       	jmp    8004ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 50 04             	lea    0x4(%eax),%edx
  800590:	89 55 14             	mov    %edx,0x14(%ebp)
  800593:	8b 00                	mov    (%eax),%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	79 02                	jns    80059b <vprintfmt+0x111>
  800599:	f7 d8                	neg    %eax
  80059b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059d:	83 f8 10             	cmp    $0x10,%eax
  8005a0:	7f 0b                	jg     8005ad <vprintfmt+0x123>
  8005a2:	8b 04 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	75 23                	jne    8005d0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b1:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  8005b8:	00 
  8005b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	e8 9a fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005cb:	e9 dd fe ff ff       	jmp    8004ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d4:	c7 44 24 08 9d 2b 80 	movl   $0x802b9d,0x8(%esp)
  8005db:	00 
  8005dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e3:	89 14 24             	mov    %edx,(%esp)
  8005e6:	e8 77 fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ee:	e9 ba fe ff ff       	jmp    8004ad <vprintfmt+0x23>
  8005f3:	89 f9                	mov    %edi,%ecx
  8005f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 30                	mov    (%eax),%esi
  800606:	85 f6                	test   %esi,%esi
  800608:	75 05                	jne    80060f <vprintfmt+0x185>
				p = "(null)";
  80060a:	be dc 27 80 00       	mov    $0x8027dc,%esi
			if (width > 0 && padc != '-')
  80060f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800613:	0f 8e 84 00 00 00    	jle    80069d <vprintfmt+0x213>
  800619:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80061d:	74 7e                	je     80069d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	e8 8b 02 00 00       	call   8008b6 <strnlen>
  80062b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062e:	29 c2                	sub    %eax,%edx
  800630:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800633:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800637:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80063a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80063d:	89 de                	mov    %ebx,%esi
  80063f:	89 d3                	mov    %edx,%ebx
  800641:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	eb 0b                	jmp    800650 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800645:	89 74 24 04          	mov    %esi,0x4(%esp)
  800649:	89 3c 24             	mov    %edi,(%esp)
  80064c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064f:	4b                   	dec    %ebx
  800650:	85 db                	test   %ebx,%ebx
  800652:	7f f1                	jg     800645 <vprintfmt+0x1bb>
  800654:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800657:	89 f3                	mov    %esi,%ebx
  800659:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80065c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	79 05                	jns    800668 <vprintfmt+0x1de>
  800663:	b8 00 00 00 00       	mov    $0x0,%eax
  800668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066b:	29 c2                	sub    %eax,%edx
  80066d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800670:	eb 2b                	jmp    80069d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800672:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800676:	74 18                	je     800690 <vprintfmt+0x206>
  800678:	8d 50 e0             	lea    -0x20(%eax),%edx
  80067b:	83 fa 5e             	cmp    $0x5e,%edx
  80067e:	76 10                	jbe    800690 <vprintfmt+0x206>
					putch('?', putdat);
  800680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800684:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
  80068e:	eb 0a                	jmp    80069a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	ff 4d e4             	decl   -0x1c(%ebp)
  80069d:	0f be 06             	movsbl (%esi),%eax
  8006a0:	46                   	inc    %esi
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 21                	je     8006c6 <vprintfmt+0x23c>
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	78 c9                	js     800672 <vprintfmt+0x1e8>
  8006a9:	4f                   	dec    %edi
  8006aa:	79 c6                	jns    800672 <vprintfmt+0x1e8>
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006af:	89 de                	mov    %ebx,%esi
  8006b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b4:	eb 18                	jmp    8006ce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c3:	4b                   	dec    %ebx
  8006c4:	eb 08                	jmp    8006ce <vprintfmt+0x244>
  8006c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c9:	89 de                	mov    %ebx,%esi
  8006cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ce:	85 db                	test   %ebx,%ebx
  8006d0:	7f e4                	jg     8006b6 <vprintfmt+0x22c>
  8006d2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006da:	e9 ce fd ff ff       	jmp    8004ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7e 10                	jle    8006f4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 08             	lea    0x8(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 30                	mov    (%eax),%esi
  8006ef:	8b 78 04             	mov    0x4(%eax),%edi
  8006f2:	eb 26                	jmp    80071a <vprintfmt+0x290>
	else if (lflag)
  8006f4:	85 c9                	test   %ecx,%ecx
  8006f6:	74 12                	je     80070a <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 30                	mov    (%eax),%esi
  800703:	89 f7                	mov    %esi,%edi
  800705:	c1 ff 1f             	sar    $0x1f,%edi
  800708:	eb 10                	jmp    80071a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 30                	mov    (%eax),%esi
  800715:	89 f7                	mov    %esi,%edi
  800717:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071a:	85 ff                	test   %edi,%edi
  80071c:	78 0a                	js     800728 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800723:	e9 8c 00 00 00       	jmp    8007b4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800728:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800733:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800736:	f7 de                	neg    %esi
  800738:	83 d7 00             	adc    $0x0,%edi
  80073b:	f7 df                	neg    %edi
			}
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800742:	eb 70                	jmp    8007b4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 c0 fc ff ff       	call   80040e <getuint>
  80074e:	89 c6                	mov    %eax,%esi
  800750:	89 d7                	mov    %edx,%edi
			base = 10;
  800752:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800757:	eb 5b                	jmp    8007b4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800759:	89 ca                	mov    %ecx,%edx
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 ab fc ff ff       	call   80040e <getuint>
  800763:	89 c6                	mov    %eax,%esi
  800765:	89 d7                	mov    %edx,%edi
			base = 8;
  800767:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80076c:	eb 46                	jmp    8007b4 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80076e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800772:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800779:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 50 04             	lea    0x4(%eax),%edx
  800790:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800793:	8b 30                	mov    (%eax),%esi
  800795:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80079a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80079f:	eb 13                	jmp    8007b4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a1:	89 ca                	mov    %ecx,%edx
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 63 fc ff ff       	call   80040e <getuint>
  8007ab:	89 c6                	mov    %eax,%esi
  8007ad:	89 d7                	mov    %edx,%edi
			base = 16;
  8007af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007b8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c7:	89 34 24             	mov    %esi,(%esp)
  8007ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ce:	89 da                	mov    %ebx,%edx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	e8 6c fb ff ff       	call   800344 <printnum>
			break;
  8007d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007db:	e9 cd fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ed:	e9 bb fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007fd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800800:	eb 01                	jmp    800803 <vprintfmt+0x379>
  800802:	4e                   	dec    %esi
  800803:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800807:	75 f9                	jne    800802 <vprintfmt+0x378>
  800809:	e9 9f fc ff ff       	jmp    8004ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80080e:	83 c4 4c             	add    $0x4c,%esp
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5f                   	pop    %edi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 28             	sub    $0x28,%esp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800822:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800825:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800829:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800833:	85 c0                	test   %eax,%eax
  800835:	74 30                	je     800867 <vsnprintf+0x51>
  800837:	85 d2                	test   %edx,%edx
  800839:	7e 33                	jle    80086e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	c7 04 24 48 04 80 00 	movl   $0x800448,(%esp)
  800857:	e8 2e fc ff ff       	call   80048a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800865:	eb 0c                	jmp    800873 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800867:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086c:	eb 05                	jmp    800873 <vsnprintf+0x5d>
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800882:	8b 45 10             	mov    0x10(%ebp),%eax
  800885:	89 44 24 08          	mov    %eax,0x8(%esp)
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 7b ff ff ff       	call   800816 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    
  80089d:	00 00                	add    %al,(%eax)
	...

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	eb 01                	jmp    8008ae <strlen+0xe>
		n++;
  8008ad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b2:	75 f9                	jne    8008ad <strlen+0xd>
		n++;
	return n;
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb 01                	jmp    8008c7 <strnlen+0x11>
		n++;
  8008c6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c7:	39 d0                	cmp    %edx,%eax
  8008c9:	74 06                	je     8008d1 <strnlen+0x1b>
  8008cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cf:	75 f5                	jne    8008c6 <strnlen+0x10>
		n++;
	return n;
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008e5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e8:	42                   	inc    %edx
  8008e9:	84 c9                	test   %cl,%cl
  8008eb:	75 f5                	jne    8008e2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ed:	5b                   	pop    %ebx
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fa:	89 1c 24             	mov    %ebx,(%esp)
  8008fd:	e8 9e ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
  800905:	89 54 24 04          	mov    %edx,0x4(%esp)
  800909:	01 d8                	add    %ebx,%eax
  80090b:	89 04 24             	mov    %eax,(%esp)
  80090e:	e8 c0 ff ff ff       	call   8008d3 <strcpy>
	return dst;
}
  800913:	89 d8                	mov    %ebx,%eax
  800915:	83 c4 08             	add    $0x8,%esp
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800929:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092e:	eb 0c                	jmp    80093c <strncpy+0x21>
		*dst++ = *src;
  800930:	8a 1a                	mov    (%edx),%bl
  800932:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800935:	80 3a 01             	cmpb   $0x1,(%edx)
  800938:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093b:	41                   	inc    %ecx
  80093c:	39 f1                	cmp    %esi,%ecx
  80093e:	75 f0                	jne    800930 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 75 08             	mov    0x8(%ebp),%esi
  80094c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800952:	85 d2                	test   %edx,%edx
  800954:	75 0a                	jne    800960 <strlcpy+0x1c>
  800956:	89 f0                	mov    %esi,%eax
  800958:	eb 1a                	jmp    800974 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095a:	88 18                	mov    %bl,(%eax)
  80095c:	40                   	inc    %eax
  80095d:	41                   	inc    %ecx
  80095e:	eb 02                	jmp    800962 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800960:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800962:	4a                   	dec    %edx
  800963:	74 0a                	je     80096f <strlcpy+0x2b>
  800965:	8a 19                	mov    (%ecx),%bl
  800967:	84 db                	test   %bl,%bl
  800969:	75 ef                	jne    80095a <strlcpy+0x16>
  80096b:	89 c2                	mov    %eax,%edx
  80096d:	eb 02                	jmp    800971 <strlcpy+0x2d>
  80096f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800971:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800974:	29 f0                	sub    %esi,%eax
}
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800983:	eb 02                	jmp    800987 <strcmp+0xd>
		p++, q++;
  800985:	41                   	inc    %ecx
  800986:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800987:	8a 01                	mov    (%ecx),%al
  800989:	84 c0                	test   %al,%al
  80098b:	74 04                	je     800991 <strcmp+0x17>
  80098d:	3a 02                	cmp    (%edx),%al
  80098f:	74 f4                	je     800985 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 12             	movzbl (%edx),%edx
  800997:	29 d0                	sub    %edx,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009a8:	eb 03                	jmp    8009ad <strncmp+0x12>
		n--, p++, q++;
  8009aa:	4a                   	dec    %edx
  8009ab:	40                   	inc    %eax
  8009ac:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ad:	85 d2                	test   %edx,%edx
  8009af:	74 14                	je     8009c5 <strncmp+0x2a>
  8009b1:	8a 18                	mov    (%eax),%bl
  8009b3:	84 db                	test   %bl,%bl
  8009b5:	74 04                	je     8009bb <strncmp+0x20>
  8009b7:	3a 19                	cmp    (%ecx),%bl
  8009b9:	74 ef                	je     8009aa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	0f b6 00             	movzbl (%eax),%eax
  8009be:	0f b6 11             	movzbl (%ecx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
  8009c3:	eb 05                	jmp    8009ca <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009d6:	eb 05                	jmp    8009dd <strchr+0x10>
		if (*s == c)
  8009d8:	38 ca                	cmp    %cl,%dl
  8009da:	74 0c                	je     8009e8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009dc:	40                   	inc    %eax
  8009dd:	8a 10                	mov    (%eax),%dl
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	75 f5                	jne    8009d8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f3:	eb 05                	jmp    8009fa <strfind+0x10>
		if (*s == c)
  8009f5:	38 ca                	cmp    %cl,%dl
  8009f7:	74 07                	je     800a00 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f9:	40                   	inc    %eax
  8009fa:	8a 10                	mov    (%eax),%dl
  8009fc:	84 d2                	test   %dl,%dl
  8009fe:	75 f5                	jne    8009f5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 30                	je     800a45 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 25                	jne    800a42 <memset+0x40>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 20                	jne    800a42 <memset+0x40>
		c &= 0xFF;
  800a22:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a25:	89 d3                	mov    %edx,%ebx
  800a27:	c1 e3 08             	shl    $0x8,%ebx
  800a2a:	89 d6                	mov    %edx,%esi
  800a2c:	c1 e6 18             	shl    $0x18,%esi
  800a2f:	89 d0                	mov    %edx,%eax
  800a31:	c1 e0 10             	shl    $0x10,%eax
  800a34:	09 f0                	or     %esi,%eax
  800a36:	09 d0                	or     %edx,%eax
  800a38:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a3d:	fc                   	cld    
  800a3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a40:	eb 03                	jmp    800a45 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a42:	fc                   	cld    
  800a43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a45:	89 f8                	mov    %edi,%eax
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5a:	39 c6                	cmp    %eax,%esi
  800a5c:	73 34                	jae    800a92 <memmove+0x46>
  800a5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a61:	39 d0                	cmp    %edx,%eax
  800a63:	73 2d                	jae    800a92 <memmove+0x46>
		s += n;
		d += n;
  800a65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a68:	f6 c2 03             	test   $0x3,%dl
  800a6b:	75 1b                	jne    800a88 <memmove+0x3c>
  800a6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a73:	75 13                	jne    800a88 <memmove+0x3c>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 0e                	jne    800a88 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7a:	83 ef 04             	sub    $0x4,%edi
  800a7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a80:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a83:	fd                   	std    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb 07                	jmp    800a8f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a88:	4f                   	dec    %edi
  800a89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8c:	fd                   	std    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8f:	fc                   	cld    
  800a90:	eb 20                	jmp    800ab2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a98:	75 13                	jne    800aad <memmove+0x61>
  800a9a:	a8 03                	test   $0x3,%al
  800a9c:	75 0f                	jne    800aad <memmove+0x61>
  800a9e:	f6 c1 03             	test   $0x3,%cl
  800aa1:	75 0a                	jne    800aad <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aab:	eb 05                	jmp    800ab2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aad:	89 c7                	mov    %eax,%edi
  800aaf:	fc                   	cld    
  800ab0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	89 04 24             	mov    %eax,(%esp)
  800ad0:	e8 77 ff ff ff       	call   800a4c <memmove>
}
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	eb 16                	jmp    800b03 <memcmp+0x2c>
		if (*s1 != *s2)
  800aed:	8a 04 17             	mov    (%edi,%edx,1),%al
  800af0:	42                   	inc    %edx
  800af1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800af5:	38 c8                	cmp    %cl,%al
  800af7:	74 0a                	je     800b03 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 c9             	movzbl %cl,%ecx
  800aff:	29 c8                	sub    %ecx,%eax
  800b01:	eb 09                	jmp    800b0c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b03:	39 da                	cmp    %ebx,%edx
  800b05:	75 e6                	jne    800aed <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1a:	89 c2                	mov    %eax,%edx
  800b1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1f:	eb 05                	jmp    800b26 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b21:	38 08                	cmp    %cl,(%eax)
  800b23:	74 05                	je     800b2a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b25:	40                   	inc    %eax
  800b26:	39 d0                	cmp    %edx,%eax
  800b28:	72 f7                	jb     800b21 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b38:	eb 01                	jmp    800b3b <strtol+0xf>
		s++;
  800b3a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3b:	8a 02                	mov    (%edx),%al
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 f9                	je     800b3a <strtol+0xe>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	74 f5                	je     800b3a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b45:	3c 2b                	cmp    $0x2b,%al
  800b47:	75 08                	jne    800b51 <strtol+0x25>
		s++;
  800b49:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4f:	eb 13                	jmp    800b64 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b51:	3c 2d                	cmp    $0x2d,%al
  800b53:	75 0a                	jne    800b5f <strtol+0x33>
		s++, neg = 1;
  800b55:	8d 52 01             	lea    0x1(%edx),%edx
  800b58:	bf 01 00 00 00       	mov    $0x1,%edi
  800b5d:	eb 05                	jmp    800b64 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	85 db                	test   %ebx,%ebx
  800b66:	74 05                	je     800b6d <strtol+0x41>
  800b68:	83 fb 10             	cmp    $0x10,%ebx
  800b6b:	75 28                	jne    800b95 <strtol+0x69>
  800b6d:	8a 02                	mov    (%edx),%al
  800b6f:	3c 30                	cmp    $0x30,%al
  800b71:	75 10                	jne    800b83 <strtol+0x57>
  800b73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b77:	75 0a                	jne    800b83 <strtol+0x57>
		s += 2, base = 16;
  800b79:	83 c2 02             	add    $0x2,%edx
  800b7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b81:	eb 12                	jmp    800b95 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b83:	85 db                	test   %ebx,%ebx
  800b85:	75 0e                	jne    800b95 <strtol+0x69>
  800b87:	3c 30                	cmp    $0x30,%al
  800b89:	75 05                	jne    800b90 <strtol+0x64>
		s++, base = 8;
  800b8b:	42                   	inc    %edx
  800b8c:	b3 08                	mov    $0x8,%bl
  800b8e:	eb 05                	jmp    800b95 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b90:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9c:	8a 0a                	mov    (%edx),%cl
  800b9e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba1:	80 fb 09             	cmp    $0x9,%bl
  800ba4:	77 08                	ja     800bae <strtol+0x82>
			dig = *s - '0';
  800ba6:	0f be c9             	movsbl %cl,%ecx
  800ba9:	83 e9 30             	sub    $0x30,%ecx
  800bac:	eb 1e                	jmp    800bcc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0x92>
			dig = *s - 'a' + 10;
  800bb6:	0f be c9             	movsbl %cl,%ecx
  800bb9:	83 e9 57             	sub    $0x57,%ecx
  800bbc:	eb 0e                	jmp    800bcc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bc1:	80 fb 19             	cmp    $0x19,%bl
  800bc4:	77 12                	ja     800bd8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bc6:	0f be c9             	movsbl %cl,%ecx
  800bc9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcc:	39 f1                	cmp    %esi,%ecx
  800bce:	7d 0c                	jge    800bdc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bd0:	42                   	inc    %edx
  800bd1:	0f af c6             	imul   %esi,%eax
  800bd4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bd6:	eb c4                	jmp    800b9c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bd8:	89 c1                	mov    %eax,%ecx
  800bda:	eb 02                	jmp    800bde <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be2:	74 05                	je     800be9 <strtol+0xbd>
		*endptr = (char *) s;
  800be4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be9:	85 ff                	test   %edi,%edi
  800beb:	74 04                	je     800bf1 <strtol+0xc5>
  800bed:	89 c8                	mov    %ecx,%eax
  800bef:	f7 d8                	neg    %eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
	...

00800bf8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 c3                	mov    %eax,%ebx
  800c0b:	89 c7                	mov    %eax,%edi
  800c0d:	89 c6                	mov    %eax,%esi
  800c0f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c21:	b8 01 00 00 00       	mov    $0x1,%eax
  800c26:	89 d1                	mov    %edx,%ecx
  800c28:	89 d3                	mov    %edx,%ebx
  800c2a:	89 d7                	mov    %edx,%edi
  800c2c:	89 d6                	mov    %edx,%esi
  800c2e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c43:	b8 03 00 00 00       	mov    $0x3,%eax
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	89 cb                	mov    %ecx,%ebx
  800c4d:	89 cf                	mov    %ecx,%edi
  800c4f:	89 ce                	mov    %ecx,%esi
  800c51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 28                	jle    800c7f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c62:	00 
  800c63:	c7 44 24 08 c3 2a 80 	movl   $0x802ac3,0x8(%esp)
  800c6a:	00 
  800c6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c72:	00 
  800c73:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800c7a:	e8 b1 f5 ff ff       	call   800230 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7f:	83 c4 2c             	add    $0x2c,%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 02 00 00 00       	mov    $0x2,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_yield>:

void
sys_yield(void)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	89 d7                	mov    %edx,%edi
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	be 00 00 00 00       	mov    $0x0,%esi
  800cd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 f7                	mov    %esi,%edi
  800ce3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 28                	jle    800d11 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ced:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 08 c3 2a 80 	movl   $0x802ac3,0x8(%esp)
  800cfc:	00 
  800cfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d04:	00 
  800d05:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800d0c:	e8 1f f5 ff ff       	call   800230 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d11:	83 c4 2c             	add    $0x2c,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	b8 05 00 00 00       	mov    $0x5,%eax
  800d27:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7e 28                	jle    800d64 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d40:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d47:	00 
  800d48:	c7 44 24 08 c3 2a 80 	movl   $0x802ac3,0x8(%esp)
  800d4f:	00 
  800d50:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d57:	00 
  800d58:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800d5f:	e8 cc f4 ff ff       	call   800230 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d64:	83 c4 2c             	add    $0x2c,%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 28                	jle    800db7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d93:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 08 c3 2a 80 	movl   $0x802ac3,0x8(%esp)
  800da2:	00 
  800da3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800daa:	00 
  800dab:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800db2:	e8 79 f4 ff ff       	call   800230 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db7:	83 c4 2c             	add    $0x2c,%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 28                	jle    800e0a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ded:	00 
  800dee:	c7 44 24 08 c3 2a 80 	movl   $0x802ac3,0x8(%esp)
  800df5:	00 
  800df6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfd:	00 
  800dfe:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800e05:	e8 26 f4 ff ff       	call   800230 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0a:	83 c4 2c             	add    $0x2c,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e20:	b8 09 00 00 00       	mov    $0x9,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 df                	mov    %ebx,%edi
  800e2d:	89 de                	mov    %ebx,%esi
  800e2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 28                	jle    800e5d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e39:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e40:	00 
  800e41:	c7 44 24 08 c3 2a 80 	movl   $0x802ac3,0x8(%esp)
  800e48:	00 
  800e49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e50:	00 
  800e51:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800e58:	e8 d3 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5d:	83 c4 2c             	add    $0x2c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e84:	85 c0                	test   %eax,%eax
  800e86:	7e 28                	jle    800eb0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e93:	00 
  800e94:	c7 44 24 08 c3 2a 80 	movl   $0x802ac3,0x8(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea3:	00 
  800ea4:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800eab:	e8 80 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb0:	83 c4 2c             	add    $0x2c,%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	be 00 00 00 00       	mov    $0x0,%esi
  800ec3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ece:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	89 cb                	mov    %ecx,%ebx
  800ef3:	89 cf                	mov    %ecx,%edi
  800ef5:	89 ce                	mov    %ecx,%esi
  800ef7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	7e 28                	jle    800f25 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f01:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f08:	00 
  800f09:	c7 44 24 08 c3 2a 80 	movl   $0x802ac3,0x8(%esp)
  800f10:	00 
  800f11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f18:	00 
  800f19:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800f20:	e8 0b f3 ff ff       	call   800230 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f25:	83 c4 2c             	add    $0x2c,%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f33:	ba 00 00 00 00       	mov    $0x0,%edx
  800f38:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f3d:	89 d1                	mov    %edx,%ecx
  800f3f:	89 d3                	mov    %edx,%ebx
  800f41:	89 d7                	mov    %edx,%edi
  800f43:	89 d6                	mov    %edx,%esi
  800f45:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f57:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	89 df                	mov    %ebx,%edi
  800f64:	89 de                	mov    %ebx,%esi
  800f66:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f78:	b8 10 00 00 00       	mov    $0x10,%eax
  800f7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 df                	mov    %ebx,%edi
  800f85:	89 de                	mov    %ebx,%esi
  800f87:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    
	...

00800f90 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	05 00 00 00 30       	add    $0x30000000,%eax
  800f9b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa9:	89 04 24             	mov    %eax,(%esp)
  800fac:	e8 df ff ff ff       	call   800f90 <fd2num>
  800fb1:	c1 e0 0c             	shl    $0xc,%eax
  800fb4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	53                   	push   %ebx
  800fbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fc2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fc7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fc9:	89 c2                	mov    %eax,%edx
  800fcb:	c1 ea 16             	shr    $0x16,%edx
  800fce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fd5:	f6 c2 01             	test   $0x1,%dl
  800fd8:	74 11                	je     800feb <fd_alloc+0x30>
  800fda:	89 c2                	mov    %eax,%edx
  800fdc:	c1 ea 0c             	shr    $0xc,%edx
  800fdf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe6:	f6 c2 01             	test   $0x1,%dl
  800fe9:	75 09                	jne    800ff4 <fd_alloc+0x39>
			*fd_store = fd;
  800feb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800fed:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff2:	eb 17                	jmp    80100b <fd_alloc+0x50>
  800ff4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ff9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ffe:	75 c7                	jne    800fc7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801000:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801006:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80100b:	5b                   	pop    %ebx
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801014:	83 f8 1f             	cmp    $0x1f,%eax
  801017:	77 36                	ja     80104f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801019:	c1 e0 0c             	shl    $0xc,%eax
  80101c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801021:	89 c2                	mov    %eax,%edx
  801023:	c1 ea 16             	shr    $0x16,%edx
  801026:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80102d:	f6 c2 01             	test   $0x1,%dl
  801030:	74 24                	je     801056 <fd_lookup+0x48>
  801032:	89 c2                	mov    %eax,%edx
  801034:	c1 ea 0c             	shr    $0xc,%edx
  801037:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80103e:	f6 c2 01             	test   $0x1,%dl
  801041:	74 1a                	je     80105d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801043:	8b 55 0c             	mov    0xc(%ebp),%edx
  801046:	89 02                	mov    %eax,(%edx)
	return 0;
  801048:	b8 00 00 00 00       	mov    $0x0,%eax
  80104d:	eb 13                	jmp    801062 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80104f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801054:	eb 0c                	jmp    801062 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801056:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80105b:	eb 05                	jmp    801062 <fd_lookup+0x54>
  80105d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	53                   	push   %ebx
  801068:	83 ec 14             	sub    $0x14,%esp
  80106b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801071:	ba 00 00 00 00       	mov    $0x0,%edx
  801076:	eb 0e                	jmp    801086 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801078:	39 08                	cmp    %ecx,(%eax)
  80107a:	75 09                	jne    801085 <dev_lookup+0x21>
			*dev = devtab[i];
  80107c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
  801083:	eb 33                	jmp    8010b8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801085:	42                   	inc    %edx
  801086:	8b 04 95 70 2b 80 00 	mov    0x802b70(,%edx,4),%eax
  80108d:	85 c0                	test   %eax,%eax
  80108f:	75 e7                	jne    801078 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801091:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801096:	8b 40 48             	mov    0x48(%eax),%eax
  801099:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80109d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a1:	c7 04 24 f0 2a 80 00 	movl   $0x802af0,(%esp)
  8010a8:	e8 7b f2 ff ff       	call   800328 <cprintf>
	*dev = 0;
  8010ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010b8:	83 c4 14             	add    $0x14,%esp
  8010bb:	5b                   	pop    %ebx
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 30             	sub    $0x30,%esp
  8010c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8010c9:	8a 45 0c             	mov    0xc(%ebp),%al
  8010cc:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010cf:	89 34 24             	mov    %esi,(%esp)
  8010d2:	e8 b9 fe ff ff       	call   800f90 <fd2num>
  8010d7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010de:	89 04 24             	mov    %eax,(%esp)
  8010e1:	e8 28 ff ff ff       	call   80100e <fd_lookup>
  8010e6:	89 c3                	mov    %eax,%ebx
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	78 05                	js     8010f1 <fd_close+0x33>
	    || fd != fd2)
  8010ec:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010ef:	74 0d                	je     8010fe <fd_close+0x40>
		return (must_exist ? r : 0);
  8010f1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010f5:	75 46                	jne    80113d <fd_close+0x7f>
  8010f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fc:	eb 3f                	jmp    80113d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801101:	89 44 24 04          	mov    %eax,0x4(%esp)
  801105:	8b 06                	mov    (%esi),%eax
  801107:	89 04 24             	mov    %eax,(%esp)
  80110a:	e8 55 ff ff ff       	call   801064 <dev_lookup>
  80110f:	89 c3                	mov    %eax,%ebx
  801111:	85 c0                	test   %eax,%eax
  801113:	78 18                	js     80112d <fd_close+0x6f>
		if (dev->dev_close)
  801115:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801118:	8b 40 10             	mov    0x10(%eax),%eax
  80111b:	85 c0                	test   %eax,%eax
  80111d:	74 09                	je     801128 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80111f:	89 34 24             	mov    %esi,(%esp)
  801122:	ff d0                	call   *%eax
  801124:	89 c3                	mov    %eax,%ebx
  801126:	eb 05                	jmp    80112d <fd_close+0x6f>
		else
			r = 0;
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80112d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801138:	e8 2f fc ff ff       	call   800d6c <sys_page_unmap>
	return r;
}
  80113d:	89 d8                	mov    %ebx,%eax
  80113f:	83 c4 30             	add    $0x30,%esp
  801142:	5b                   	pop    %ebx
  801143:	5e                   	pop    %esi
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	89 04 24             	mov    %eax,(%esp)
  801159:	e8 b0 fe ff ff       	call   80100e <fd_lookup>
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 13                	js     801175 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801162:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801169:	00 
  80116a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116d:	89 04 24             	mov    %eax,(%esp)
  801170:	e8 49 ff ff ff       	call   8010be <fd_close>
}
  801175:	c9                   	leave  
  801176:	c3                   	ret    

00801177 <close_all>:

void
close_all(void)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	53                   	push   %ebx
  80117b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80117e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801183:	89 1c 24             	mov    %ebx,(%esp)
  801186:	e8 bb ff ff ff       	call   801146 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80118b:	43                   	inc    %ebx
  80118c:	83 fb 20             	cmp    $0x20,%ebx
  80118f:	75 f2                	jne    801183 <close_all+0xc>
		close(i);
}
  801191:	83 c4 14             	add    $0x14,%esp
  801194:	5b                   	pop    %ebx
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 4c             	sub    $0x4c,%esp
  8011a0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ad:	89 04 24             	mov    %eax,(%esp)
  8011b0:	e8 59 fe ff ff       	call   80100e <fd_lookup>
  8011b5:	89 c3                	mov    %eax,%ebx
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	0f 88 e3 00 00 00    	js     8012a2 <dup+0x10b>
		return r;
	close(newfdnum);
  8011bf:	89 3c 24             	mov    %edi,(%esp)
  8011c2:	e8 7f ff ff ff       	call   801146 <close>

	newfd = INDEX2FD(newfdnum);
  8011c7:	89 fe                	mov    %edi,%esi
  8011c9:	c1 e6 0c             	shl    $0xc,%esi
  8011cc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8011d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d5:	89 04 24             	mov    %eax,(%esp)
  8011d8:	e8 c3 fd ff ff       	call   800fa0 <fd2data>
  8011dd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011df:	89 34 24             	mov    %esi,(%esp)
  8011e2:	e8 b9 fd ff ff       	call   800fa0 <fd2data>
  8011e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011ea:	89 d8                	mov    %ebx,%eax
  8011ec:	c1 e8 16             	shr    $0x16,%eax
  8011ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f6:	a8 01                	test   $0x1,%al
  8011f8:	74 46                	je     801240 <dup+0xa9>
  8011fa:	89 d8                	mov    %ebx,%eax
  8011fc:	c1 e8 0c             	shr    $0xc,%eax
  8011ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 35                	je     801240 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80120b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801212:	25 07 0e 00 00       	and    $0xe07,%eax
  801217:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80121e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801222:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801229:	00 
  80122a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80122e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801235:	e8 df fa ff ff       	call   800d19 <sys_page_map>
  80123a:	89 c3                	mov    %eax,%ebx
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 3b                	js     80127b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801240:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801243:	89 c2                	mov    %eax,%edx
  801245:	c1 ea 0c             	shr    $0xc,%edx
  801248:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801255:	89 54 24 10          	mov    %edx,0x10(%esp)
  801259:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80125d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801264:	00 
  801265:	89 44 24 04          	mov    %eax,0x4(%esp)
  801269:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801270:	e8 a4 fa ff ff       	call   800d19 <sys_page_map>
  801275:	89 c3                	mov    %eax,%ebx
  801277:	85 c0                	test   %eax,%eax
  801279:	79 25                	jns    8012a0 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80127b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80127f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801286:	e8 e1 fa ff ff       	call   800d6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80128b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80128e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801292:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801299:	e8 ce fa ff ff       	call   800d6c <sys_page_unmap>
	return r;
  80129e:	eb 02                	jmp    8012a2 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8012a0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012a2:	89 d8                	mov    %ebx,%eax
  8012a4:	83 c4 4c             	add    $0x4c,%esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5f                   	pop    %edi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 24             	sub    $0x24,%esp
  8012b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bd:	89 1c 24             	mov    %ebx,(%esp)
  8012c0:	e8 49 fd ff ff       	call   80100e <fd_lookup>
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 6d                	js     801336 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	8b 00                	mov    (%eax),%eax
  8012d5:	89 04 24             	mov    %eax,(%esp)
  8012d8:	e8 87 fd ff ff       	call   801064 <dev_lookup>
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 55                	js     801336 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e4:	8b 50 08             	mov    0x8(%eax),%edx
  8012e7:	83 e2 03             	and    $0x3,%edx
  8012ea:	83 fa 01             	cmp    $0x1,%edx
  8012ed:	75 23                	jne    801312 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ef:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012f4:	8b 40 48             	mov    0x48(%eax),%eax
  8012f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ff:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  801306:	e8 1d f0 ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  80130b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801310:	eb 24                	jmp    801336 <read+0x8a>
	}
	if (!dev->dev_read)
  801312:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801315:	8b 52 08             	mov    0x8(%edx),%edx
  801318:	85 d2                	test   %edx,%edx
  80131a:	74 15                	je     801331 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80131c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80131f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801326:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80132a:	89 04 24             	mov    %eax,(%esp)
  80132d:	ff d2                	call   *%edx
  80132f:	eb 05                	jmp    801336 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801331:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801336:	83 c4 24             	add    $0x24,%esp
  801339:	5b                   	pop    %ebx
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	57                   	push   %edi
  801340:	56                   	push   %esi
  801341:	53                   	push   %ebx
  801342:	83 ec 1c             	sub    $0x1c,%esp
  801345:	8b 7d 08             	mov    0x8(%ebp),%edi
  801348:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80134b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801350:	eb 23                	jmp    801375 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801352:	89 f0                	mov    %esi,%eax
  801354:	29 d8                	sub    %ebx,%eax
  801356:	89 44 24 08          	mov    %eax,0x8(%esp)
  80135a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135d:	01 d8                	add    %ebx,%eax
  80135f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801363:	89 3c 24             	mov    %edi,(%esp)
  801366:	e8 41 ff ff ff       	call   8012ac <read>
		if (m < 0)
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 10                	js     80137f <readn+0x43>
			return m;
		if (m == 0)
  80136f:	85 c0                	test   %eax,%eax
  801371:	74 0a                	je     80137d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801373:	01 c3                	add    %eax,%ebx
  801375:	39 f3                	cmp    %esi,%ebx
  801377:	72 d9                	jb     801352 <readn+0x16>
  801379:	89 d8                	mov    %ebx,%eax
  80137b:	eb 02                	jmp    80137f <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80137d:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80137f:	83 c4 1c             	add    $0x1c,%esp
  801382:	5b                   	pop    %ebx
  801383:	5e                   	pop    %esi
  801384:	5f                   	pop    %edi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	53                   	push   %ebx
  80138b:	83 ec 24             	sub    $0x24,%esp
  80138e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801391:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801394:	89 44 24 04          	mov    %eax,0x4(%esp)
  801398:	89 1c 24             	mov    %ebx,(%esp)
  80139b:	e8 6e fc ff ff       	call   80100e <fd_lookup>
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 68                	js     80140c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ae:	8b 00                	mov    (%eax),%eax
  8013b0:	89 04 24             	mov    %eax,(%esp)
  8013b3:	e8 ac fc ff ff       	call   801064 <dev_lookup>
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 50                	js     80140c <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c3:	75 23                	jne    8013e8 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013ca:	8b 40 48             	mov    0x48(%eax),%eax
  8013cd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d5:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8013dc:	e8 47 ef ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  8013e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e6:	eb 24                	jmp    80140c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ee:	85 d2                	test   %edx,%edx
  8013f0:	74 15                	je     801407 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013f5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801400:	89 04 24             	mov    %eax,(%esp)
  801403:	ff d2                	call   *%edx
  801405:	eb 05                	jmp    80140c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801407:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80140c:	83 c4 24             	add    $0x24,%esp
  80140f:	5b                   	pop    %ebx
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <seek>:

int
seek(int fdnum, off_t offset)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801418:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80141b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141f:	8b 45 08             	mov    0x8(%ebp),%eax
  801422:	89 04 24             	mov    %eax,(%esp)
  801425:	e8 e4 fb ff ff       	call   80100e <fd_lookup>
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 0e                	js     80143c <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80142e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801431:	8b 55 0c             	mov    0xc(%ebp),%edx
  801434:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801437:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	53                   	push   %ebx
  801442:	83 ec 24             	sub    $0x24,%esp
  801445:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801448:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144f:	89 1c 24             	mov    %ebx,(%esp)
  801452:	e8 b7 fb ff ff       	call   80100e <fd_lookup>
  801457:	85 c0                	test   %eax,%eax
  801459:	78 61                	js     8014bc <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801462:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801465:	8b 00                	mov    (%eax),%eax
  801467:	89 04 24             	mov    %eax,(%esp)
  80146a:	e8 f5 fb ff ff       	call   801064 <dev_lookup>
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 49                	js     8014bc <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801473:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801476:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80147a:	75 23                	jne    80149f <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80147c:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801481:	8b 40 48             	mov    0x48(%eax),%eax
  801484:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148c:	c7 04 24 10 2b 80 00 	movl   $0x802b10,(%esp)
  801493:	e8 90 ee ff ff       	call   800328 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801498:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149d:	eb 1d                	jmp    8014bc <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80149f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a2:	8b 52 18             	mov    0x18(%edx),%edx
  8014a5:	85 d2                	test   %edx,%edx
  8014a7:	74 0e                	je     8014b7 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014b0:	89 04 24             	mov    %eax,(%esp)
  8014b3:	ff d2                	call   *%edx
  8014b5:	eb 05                	jmp    8014bc <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014bc:	83 c4 24             	add    $0x24,%esp
  8014bf:	5b                   	pop    %ebx
  8014c0:	5d                   	pop    %ebp
  8014c1:	c3                   	ret    

008014c2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	53                   	push   %ebx
  8014c6:	83 ec 24             	sub    $0x24,%esp
  8014c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d6:	89 04 24             	mov    %eax,(%esp)
  8014d9:	e8 30 fb ff ff       	call   80100e <fd_lookup>
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 52                	js     801534 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ec:	8b 00                	mov    (%eax),%eax
  8014ee:	89 04 24             	mov    %eax,(%esp)
  8014f1:	e8 6e fb ff ff       	call   801064 <dev_lookup>
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 3a                	js     801534 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8014fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801501:	74 2c                	je     80152f <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801503:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801506:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80150d:	00 00 00 
	stat->st_isdir = 0;
  801510:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801517:	00 00 00 
	stat->st_dev = dev;
  80151a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801524:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801527:	89 14 24             	mov    %edx,(%esp)
  80152a:	ff 50 14             	call   *0x14(%eax)
  80152d:	eb 05                	jmp    801534 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80152f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801534:	83 c4 24             	add    $0x24,%esp
  801537:	5b                   	pop    %ebx
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    

0080153a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	56                   	push   %esi
  80153e:	53                   	push   %ebx
  80153f:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801542:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801549:	00 
  80154a:	8b 45 08             	mov    0x8(%ebp),%eax
  80154d:	89 04 24             	mov    %eax,(%esp)
  801550:	e8 2a 02 00 00       	call   80177f <open>
  801555:	89 c3                	mov    %eax,%ebx
  801557:	85 c0                	test   %eax,%eax
  801559:	78 1b                	js     801576 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80155b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801562:	89 1c 24             	mov    %ebx,(%esp)
  801565:	e8 58 ff ff ff       	call   8014c2 <fstat>
  80156a:	89 c6                	mov    %eax,%esi
	close(fd);
  80156c:	89 1c 24             	mov    %ebx,(%esp)
  80156f:	e8 d2 fb ff ff       	call   801146 <close>
	return r;
  801574:	89 f3                	mov    %esi,%ebx
}
  801576:	89 d8                	mov    %ebx,%eax
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	5b                   	pop    %ebx
  80157c:	5e                   	pop    %esi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    
	...

00801580 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	83 ec 10             	sub    $0x10,%esp
  801588:	89 c3                	mov    %eax,%ebx
  80158a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80158c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801593:	75 11                	jne    8015a6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801595:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80159c:	e8 be 0e 00 00       	call   80245f <ipc_find_env>
  8015a1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015a6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015ad:	00 
  8015ae:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015b5:	00 
  8015b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8015bf:	89 04 24             	mov    %eax,(%esp)
  8015c2:	e8 15 0e 00 00       	call   8023dc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015ce:	00 
  8015cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015da:	e8 8d 0d 00 00       	call   80236c <ipc_recv>
}
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    

008015e6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801604:	b8 02 00 00 00       	mov    $0x2,%eax
  801609:	e8 72 ff ff ff       	call   801580 <fsipc>
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801616:	8b 45 08             	mov    0x8(%ebp),%eax
  801619:	8b 40 0c             	mov    0xc(%eax),%eax
  80161c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801621:	ba 00 00 00 00       	mov    $0x0,%edx
  801626:	b8 06 00 00 00       	mov    $0x6,%eax
  80162b:	e8 50 ff ff ff       	call   801580 <fsipc>
}
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	53                   	push   %ebx
  801636:	83 ec 14             	sub    $0x14,%esp
  801639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80163c:	8b 45 08             	mov    0x8(%ebp),%eax
  80163f:	8b 40 0c             	mov    0xc(%eax),%eax
  801642:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801647:	ba 00 00 00 00       	mov    $0x0,%edx
  80164c:	b8 05 00 00 00       	mov    $0x5,%eax
  801651:	e8 2a ff ff ff       	call   801580 <fsipc>
  801656:	85 c0                	test   %eax,%eax
  801658:	78 2b                	js     801685 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80165a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801661:	00 
  801662:	89 1c 24             	mov    %ebx,(%esp)
  801665:	e8 69 f2 ff ff       	call   8008d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80166a:	a1 80 50 80 00       	mov    0x805080,%eax
  80166f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801675:	a1 84 50 80 00       	mov    0x805084,%eax
  80167a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801680:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801685:	83 c4 14             	add    $0x14,%esp
  801688:	5b                   	pop    %ebx
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 18             	sub    $0x18,%esp
  801691:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801694:	8b 55 08             	mov    0x8(%ebp),%edx
  801697:	8b 52 0c             	mov    0xc(%edx),%edx
  80169a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016a0:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016ac:	76 05                	jbe    8016b3 <devfile_write+0x28>
  8016ae:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8016b3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016be:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8016c5:	e8 ec f3 ff ff       	call   800ab6 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8016ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cf:	b8 04 00 00 00       	mov    $0x4,%eax
  8016d4:	e8 a7 fe ff ff       	call   801580 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 10             	sub    $0x10,%esp
  8016e3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016f1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fc:	b8 03 00 00 00       	mov    $0x3,%eax
  801701:	e8 7a fe ff ff       	call   801580 <fsipc>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 6a                	js     801776 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80170c:	39 c6                	cmp    %eax,%esi
  80170e:	73 24                	jae    801734 <devfile_read+0x59>
  801710:	c7 44 24 0c 84 2b 80 	movl   $0x802b84,0xc(%esp)
  801717:	00 
  801718:	c7 44 24 08 8b 2b 80 	movl   $0x802b8b,0x8(%esp)
  80171f:	00 
  801720:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801727:	00 
  801728:	c7 04 24 a0 2b 80 00 	movl   $0x802ba0,(%esp)
  80172f:	e8 fc ea ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  801734:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801739:	7e 24                	jle    80175f <devfile_read+0x84>
  80173b:	c7 44 24 0c ab 2b 80 	movl   $0x802bab,0xc(%esp)
  801742:	00 
  801743:	c7 44 24 08 8b 2b 80 	movl   $0x802b8b,0x8(%esp)
  80174a:	00 
  80174b:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801752:	00 
  801753:	c7 04 24 a0 2b 80 00 	movl   $0x802ba0,(%esp)
  80175a:	e8 d1 ea ff ff       	call   800230 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80175f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801763:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80176a:	00 
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 d6 f2 ff ff       	call   800a4c <memmove>
	return r;
}
  801776:	89 d8                	mov    %ebx,%eax
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
  801784:	83 ec 20             	sub    $0x20,%esp
  801787:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80178a:	89 34 24             	mov    %esi,(%esp)
  80178d:	e8 0e f1 ff ff       	call   8008a0 <strlen>
  801792:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801797:	7f 60                	jg     8017f9 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801799:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179c:	89 04 24             	mov    %eax,(%esp)
  80179f:	e8 17 f8 ff ff       	call   800fbb <fd_alloc>
  8017a4:	89 c3                	mov    %eax,%ebx
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 54                	js     8017fe <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ae:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8017b5:	e8 19 f1 ff ff       	call   8008d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ca:	e8 b1 fd ff ff       	call   801580 <fsipc>
  8017cf:	89 c3                	mov    %eax,%ebx
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	79 15                	jns    8017ea <open+0x6b>
		fd_close(fd, 0);
  8017d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017dc:	00 
  8017dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e0:	89 04 24             	mov    %eax,(%esp)
  8017e3:	e8 d6 f8 ff ff       	call   8010be <fd_close>
		return r;
  8017e8:	eb 14                	jmp    8017fe <open+0x7f>
	}

	return fd2num(fd);
  8017ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ed:	89 04 24             	mov    %eax,(%esp)
  8017f0:	e8 9b f7 ff ff       	call   800f90 <fd2num>
  8017f5:	89 c3                	mov    %eax,%ebx
  8017f7:	eb 05                	jmp    8017fe <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017f9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017fe:	89 d8                	mov    %ebx,%eax
  801800:	83 c4 20             	add    $0x20,%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80180d:	ba 00 00 00 00       	mov    $0x0,%edx
  801812:	b8 08 00 00 00       	mov    $0x8,%eax
  801817:	e8 64 fd ff ff       	call   801580 <fsipc>
}
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    
	...

00801820 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 14             	sub    $0x14,%esp
  801827:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801829:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80182d:	7e 32                	jle    801861 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80182f:	8b 40 04             	mov    0x4(%eax),%eax
  801832:	89 44 24 08          	mov    %eax,0x8(%esp)
  801836:	8d 43 10             	lea    0x10(%ebx),%eax
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	8b 03                	mov    (%ebx),%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 40 fb ff ff       	call   801387 <write>
		if (result > 0)
  801847:	85 c0                	test   %eax,%eax
  801849:	7e 03                	jle    80184e <writebuf+0x2e>
			b->result += result;
  80184b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80184e:	39 43 04             	cmp    %eax,0x4(%ebx)
  801851:	74 0e                	je     801861 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801853:	89 c2                	mov    %eax,%edx
  801855:	85 c0                	test   %eax,%eax
  801857:	7e 05                	jle    80185e <writebuf+0x3e>
  801859:	ba 00 00 00 00       	mov    $0x0,%edx
  80185e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801861:	83 c4 14             	add    $0x14,%esp
  801864:	5b                   	pop    %ebx
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <putch>:

static void
putch(int ch, void *thunk)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801871:	8b 43 04             	mov    0x4(%ebx),%eax
  801874:	8b 55 08             	mov    0x8(%ebp),%edx
  801877:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80187b:	40                   	inc    %eax
  80187c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80187f:	3d 00 01 00 00       	cmp    $0x100,%eax
  801884:	75 0e                	jne    801894 <putch+0x2d>
		writebuf(b);
  801886:	89 d8                	mov    %ebx,%eax
  801888:	e8 93 ff ff ff       	call   801820 <writebuf>
		b->idx = 0;
  80188d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801894:	83 c4 04             	add    $0x4,%esp
  801897:	5b                   	pop    %ebx
  801898:	5d                   	pop    %ebp
  801899:	c3                   	ret    

0080189a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8018a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a6:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018ac:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018b3:	00 00 00 
	b.result = 0;
  8018b6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018bd:	00 00 00 
	b.error = 1;
  8018c0:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018c7:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8018cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	c7 04 24 67 18 80 00 	movl   $0x801867,(%esp)
  8018e9:	e8 9c eb ff ff       	call   80048a <vprintfmt>
	if (b.idx > 0)
  8018ee:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018f5:	7e 0b                	jle    801902 <vfprintf+0x68>
		writebuf(&b);
  8018f7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018fd:	e8 1e ff ff ff       	call   801820 <writebuf>

	return (b.result ? b.result : b.error);
  801902:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801908:	85 c0                	test   %eax,%eax
  80190a:	75 06                	jne    801912 <vfprintf+0x78>
  80190c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80191a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80191d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801921:	8b 45 0c             	mov    0xc(%ebp),%eax
  801924:	89 44 24 04          	mov    %eax,0x4(%esp)
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	89 04 24             	mov    %eax,(%esp)
  80192e:	e8 67 ff ff ff       	call   80189a <vfprintf>
	va_end(ap);

	return cnt;
}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <printf>:

int
printf(const char *fmt, ...)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80193b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80193e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	89 44 24 04          	mov    %eax,0x4(%esp)
  801949:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801950:	e8 45 ff ff ff       	call   80189a <vfprintf>
	va_end(ap);

	return cnt;
}
  801955:	c9                   	leave  
  801956:	c3                   	ret    
	...

00801958 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  80195e:	c7 44 24 04 b7 2b 80 	movl   $0x802bb7,0x4(%esp)
  801965:	00 
  801966:	8b 45 0c             	mov    0xc(%ebp),%eax
  801969:	89 04 24             	mov    %eax,(%esp)
  80196c:	e8 62 ef ff ff       	call   8008d3 <strcpy>
	return 0;
}
  801971:	b8 00 00 00 00       	mov    $0x0,%eax
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	53                   	push   %ebx
  80197c:	83 ec 14             	sub    $0x14,%esp
  80197f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801982:	89 1c 24             	mov    %ebx,(%esp)
  801985:	e8 1a 0b 00 00       	call   8024a4 <pageref>
  80198a:	83 f8 01             	cmp    $0x1,%eax
  80198d:	75 0d                	jne    80199c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80198f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801992:	89 04 24             	mov    %eax,(%esp)
  801995:	e8 1f 03 00 00       	call   801cb9 <nsipc_close>
  80199a:	eb 05                	jmp    8019a1 <devsock_close+0x29>
	else
		return 0;
  80199c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a1:	83 c4 14             	add    $0x14,%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5d                   	pop    %ebp
  8019a6:	c3                   	ret    

008019a7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019ad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019b4:	00 
  8019b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 e3 03 00 00       	call   801db4 <nsipc_send>
}
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019d9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019e0:	00 
  8019e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f5:	89 04 24             	mov    %eax,(%esp)
  8019f8:	e8 37 03 00 00       	call   801d34 <nsipc_recv>
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	56                   	push   %esi
  801a03:	53                   	push   %ebx
  801a04:	83 ec 20             	sub    $0x20,%esp
  801a07:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0c:	89 04 24             	mov    %eax,(%esp)
  801a0f:	e8 a7 f5 ff ff       	call   800fbb <fd_alloc>
  801a14:	89 c3                	mov    %eax,%ebx
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 21                	js     801a3b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a1a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a21:	00 
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a30:	e8 90 f2 ff ff       	call   800cc5 <sys_page_alloc>
  801a35:	89 c3                	mov    %eax,%ebx
  801a37:	85 c0                	test   %eax,%eax
  801a39:	79 0a                	jns    801a45 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801a3b:	89 34 24             	mov    %esi,(%esp)
  801a3e:	e8 76 02 00 00       	call   801cb9 <nsipc_close>
		return r;
  801a43:	eb 22                	jmp    801a67 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a45:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a53:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a5a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a5d:	89 04 24             	mov    %eax,(%esp)
  801a60:	e8 2b f5 ff ff       	call   800f90 <fd2num>
  801a65:	89 c3                	mov    %eax,%ebx
}
  801a67:	89 d8                	mov    %ebx,%eax
  801a69:	83 c4 20             	add    $0x20,%esp
  801a6c:	5b                   	pop    %ebx
  801a6d:	5e                   	pop    %esi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a76:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a79:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a7d:	89 04 24             	mov    %eax,(%esp)
  801a80:	e8 89 f5 ff ff       	call   80100e <fd_lookup>
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 17                	js     801aa0 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a92:	39 10                	cmp    %edx,(%eax)
  801a94:	75 05                	jne    801a9b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a96:	8b 40 0c             	mov    0xc(%eax),%eax
  801a99:	eb 05                	jmp    801aa0 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a9b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801aa0:	c9                   	leave  
  801aa1:	c3                   	ret    

00801aa2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801aab:	e8 c0 ff ff ff       	call   801a70 <fd2sockid>
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 1f                	js     801ad3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ab4:	8b 55 10             	mov    0x10(%ebp),%edx
  801ab7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801abb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801abe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 38 01 00 00       	call   801c02 <nsipc_accept>
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 05                	js     801ad3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801ace:	e8 2c ff ff ff       	call   8019ff <alloc_sockfd>
}
  801ad3:	c9                   	leave  
  801ad4:	c3                   	ret    

00801ad5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801adb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ade:	e8 8d ff ff ff       	call   801a70 <fd2sockid>
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	78 16                	js     801afd <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801ae7:	8b 55 10             	mov    0x10(%ebp),%edx
  801aea:	89 54 24 08          	mov    %edx,0x8(%esp)
  801aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  801af1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801af5:	89 04 24             	mov    %eax,(%esp)
  801af8:	e8 5b 01 00 00       	call   801c58 <nsipc_bind>
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <shutdown>:

int
shutdown(int s, int how)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b05:	8b 45 08             	mov    0x8(%ebp),%eax
  801b08:	e8 63 ff ff ff       	call   801a70 <fd2sockid>
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 0f                	js     801b20 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b11:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b14:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b18:	89 04 24             	mov    %eax,(%esp)
  801b1b:	e8 77 01 00 00       	call   801c97 <nsipc_shutdown>
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	e8 40 ff ff ff       	call   801a70 <fd2sockid>
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 16                	js     801b4a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801b34:	8b 55 10             	mov    0x10(%ebp),%edx
  801b37:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b42:	89 04 24             	mov    %eax,(%esp)
  801b45:	e8 89 01 00 00       	call   801cd3 <nsipc_connect>
}
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <listen>:

int
listen(int s, int backlog)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b52:	8b 45 08             	mov    0x8(%ebp),%eax
  801b55:	e8 16 ff ff ff       	call   801a70 <fd2sockid>
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	78 0f                	js     801b6d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b65:	89 04 24             	mov    %eax,(%esp)
  801b68:	e8 a5 01 00 00       	call   801d12 <nsipc_listen>
}
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    

00801b6f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b75:	8b 45 10             	mov    0x10(%ebp),%eax
  801b78:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b83:	8b 45 08             	mov    0x8(%ebp),%eax
  801b86:	89 04 24             	mov    %eax,(%esp)
  801b89:	e8 99 02 00 00       	call   801e27 <nsipc_socket>
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 05                	js     801b97 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801b92:	e8 68 fe ff ff       	call   8019ff <alloc_sockfd>
}
  801b97:	c9                   	leave  
  801b98:	c3                   	ret    
  801b99:	00 00                	add    %al,(%eax)
	...

00801b9c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 14             	sub    $0x14,%esp
  801ba3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba5:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801bac:	75 11                	jne    801bbf <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bae:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801bb5:	e8 a5 08 00 00       	call   80245f <ipc_find_env>
  801bba:	a3 08 40 80 00       	mov    %eax,0x804008
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bbf:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bc6:	00 
  801bc7:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801bce:	00 
  801bcf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bd3:	a1 08 40 80 00       	mov    0x804008,%eax
  801bd8:	89 04 24             	mov    %eax,(%esp)
  801bdb:	e8 fc 07 00 00       	call   8023dc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801be0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801be7:	00 
  801be8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bef:	00 
  801bf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf7:	e8 70 07 00 00       	call   80236c <ipc_recv>
}
  801bfc:	83 c4 14             	add    $0x14,%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	56                   	push   %esi
  801c06:	53                   	push   %ebx
  801c07:	83 ec 10             	sub    $0x10,%esp
  801c0a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c15:	8b 06                	mov    (%esi),%eax
  801c17:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801c21:	e8 76 ff ff ff       	call   801b9c <nsipc>
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	78 23                	js     801c4f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c2c:	a1 10 60 80 00       	mov    0x806010,%eax
  801c31:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c35:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c3c:	00 
  801c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c40:	89 04 24             	mov    %eax,(%esp)
  801c43:	e8 04 ee ff ff       	call   800a4c <memmove>
		*addrlen = ret->ret_addrlen;
  801c48:	a1 10 60 80 00       	mov    0x806010,%eax
  801c4d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801c4f:	89 d8                	mov    %ebx,%eax
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	53                   	push   %ebx
  801c5c:	83 ec 14             	sub    $0x14,%esp
  801c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c62:	8b 45 08             	mov    0x8(%ebp),%eax
  801c65:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c6a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c75:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801c7c:	e8 cb ed ff ff       	call   800a4c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c81:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c87:	b8 02 00 00 00       	mov    $0x2,%eax
  801c8c:	e8 0b ff ff ff       	call   801b9c <nsipc>
}
  801c91:	83 c4 14             	add    $0x14,%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cad:	b8 03 00 00 00       	mov    $0x3,%eax
  801cb2:	e8 e5 fe ff ff       	call   801b9c <nsipc>
}
  801cb7:	c9                   	leave  
  801cb8:	c3                   	ret    

00801cb9 <nsipc_close>:

int
nsipc_close(int s)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cc7:	b8 04 00 00 00       	mov    $0x4,%eax
  801ccc:	e8 cb fe ff ff       	call   801b9c <nsipc>
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	53                   	push   %ebx
  801cd7:	83 ec 14             	sub    $0x14,%esp
  801cda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ce5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf0:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801cf7:	e8 50 ed ff ff       	call   800a4c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cfc:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d02:	b8 05 00 00 00       	mov    $0x5,%eax
  801d07:	e8 90 fe ff ff       	call   801b9c <nsipc>
}
  801d0c:	83 c4 14             	add    $0x14,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d18:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d23:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d28:	b8 06 00 00 00       	mov    $0x6,%eax
  801d2d:	e8 6a fe ff ff       	call   801b9c <nsipc>
}
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	56                   	push   %esi
  801d38:	53                   	push   %ebx
  801d39:	83 ec 10             	sub    $0x10,%esp
  801d3c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d47:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d4d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d50:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d55:	b8 07 00 00 00       	mov    $0x7,%eax
  801d5a:	e8 3d fe ff ff       	call   801b9c <nsipc>
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 46                	js     801dab <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801d65:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d6a:	7f 04                	jg     801d70 <nsipc_recv+0x3c>
  801d6c:	39 c6                	cmp    %eax,%esi
  801d6e:	7d 24                	jge    801d94 <nsipc_recv+0x60>
  801d70:	c7 44 24 0c c3 2b 80 	movl   $0x802bc3,0xc(%esp)
  801d77:	00 
  801d78:	c7 44 24 08 8b 2b 80 	movl   $0x802b8b,0x8(%esp)
  801d7f:	00 
  801d80:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801d87:	00 
  801d88:	c7 04 24 d8 2b 80 00 	movl   $0x802bd8,(%esp)
  801d8f:	e8 9c e4 ff ff       	call   800230 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d94:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d98:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d9f:	00 
  801da0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da3:	89 04 24             	mov    %eax,(%esp)
  801da6:	e8 a1 ec ff ff       	call   800a4c <memmove>
	}

	return r;
}
  801dab:	89 d8                	mov    %ebx,%eax
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	53                   	push   %ebx
  801db8:	83 ec 14             	sub    $0x14,%esp
  801dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dc6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dcc:	7e 24                	jle    801df2 <nsipc_send+0x3e>
  801dce:	c7 44 24 0c e4 2b 80 	movl   $0x802be4,0xc(%esp)
  801dd5:	00 
  801dd6:	c7 44 24 08 8b 2b 80 	movl   $0x802b8b,0x8(%esp)
  801ddd:	00 
  801dde:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801de5:	00 
  801de6:	c7 04 24 d8 2b 80 00 	movl   $0x802bd8,(%esp)
  801ded:	e8 3e e4 ff ff       	call   800230 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801df2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfd:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e04:	e8 43 ec ff ff       	call   800a4c <memmove>
	nsipcbuf.send.req_size = size;
  801e09:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e0f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e12:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e17:	b8 08 00 00 00       	mov    $0x8,%eax
  801e1c:	e8 7b fd ff ff       	call   801b9c <nsipc>
}
  801e21:	83 c4 14             	add    $0x14,%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    

00801e27 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e30:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e38:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e3d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e40:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e45:	b8 09 00 00 00       	mov    $0x9,%eax
  801e4a:	e8 4d fd ff ff       	call   801b9c <nsipc>
}
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    
  801e51:	00 00                	add    %al,(%eax)
	...

00801e54 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	56                   	push   %esi
  801e58:	53                   	push   %ebx
  801e59:	83 ec 10             	sub    $0x10,%esp
  801e5c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e62:	89 04 24             	mov    %eax,(%esp)
  801e65:	e8 36 f1 ff ff       	call   800fa0 <fd2data>
  801e6a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e6c:	c7 44 24 04 f0 2b 80 	movl   $0x802bf0,0x4(%esp)
  801e73:	00 
  801e74:	89 34 24             	mov    %esi,(%esp)
  801e77:	e8 57 ea ff ff       	call   8008d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e7f:	2b 03                	sub    (%ebx),%eax
  801e81:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e87:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e8e:	00 00 00 
	stat->st_dev = &devpipe;
  801e91:	c7 86 88 00 00 00 40 	movl   $0x803040,0x88(%esi)
  801e98:	30 80 00 
	return 0;
}
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	53                   	push   %ebx
  801eab:	83 ec 14             	sub    $0x14,%esp
  801eae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebc:	e8 ab ee ff ff       	call   800d6c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ec1:	89 1c 24             	mov    %ebx,(%esp)
  801ec4:	e8 d7 f0 ff ff       	call   800fa0 <fd2data>
  801ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed4:	e8 93 ee ff ff       	call   800d6c <sys_page_unmap>
}
  801ed9:	83 c4 14             	add    $0x14,%esp
  801edc:	5b                   	pop    %ebx
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	57                   	push   %edi
  801ee3:	56                   	push   %esi
  801ee4:	53                   	push   %ebx
  801ee5:	83 ec 2c             	sub    $0x2c,%esp
  801ee8:	89 c7                	mov    %eax,%edi
  801eea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801eed:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801ef2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ef5:	89 3c 24             	mov    %edi,(%esp)
  801ef8:	e8 a7 05 00 00       	call   8024a4 <pageref>
  801efd:	89 c6                	mov    %eax,%esi
  801eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f02:	89 04 24             	mov    %eax,(%esp)
  801f05:	e8 9a 05 00 00       	call   8024a4 <pageref>
  801f0a:	39 c6                	cmp    %eax,%esi
  801f0c:	0f 94 c0             	sete   %al
  801f0f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f12:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801f18:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f1b:	39 cb                	cmp    %ecx,%ebx
  801f1d:	75 08                	jne    801f27 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f1f:	83 c4 2c             	add    $0x2c,%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5f                   	pop    %edi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f27:	83 f8 01             	cmp    $0x1,%eax
  801f2a:	75 c1                	jne    801eed <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f2c:	8b 42 58             	mov    0x58(%edx),%eax
  801f2f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801f36:	00 
  801f37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f3f:	c7 04 24 f7 2b 80 00 	movl   $0x802bf7,(%esp)
  801f46:	e8 dd e3 ff ff       	call   800328 <cprintf>
  801f4b:	eb a0                	jmp    801eed <_pipeisclosed+0xe>

00801f4d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	57                   	push   %edi
  801f51:	56                   	push   %esi
  801f52:	53                   	push   %ebx
  801f53:	83 ec 1c             	sub    $0x1c,%esp
  801f56:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f59:	89 34 24             	mov    %esi,(%esp)
  801f5c:	e8 3f f0 ff ff       	call   800fa0 <fd2data>
  801f61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f63:	bf 00 00 00 00       	mov    $0x0,%edi
  801f68:	eb 3c                	jmp    801fa6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f6a:	89 da                	mov    %ebx,%edx
  801f6c:	89 f0                	mov    %esi,%eax
  801f6e:	e8 6c ff ff ff       	call   801edf <_pipeisclosed>
  801f73:	85 c0                	test   %eax,%eax
  801f75:	75 38                	jne    801faf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f77:	e8 2a ed ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f7f:	8b 13                	mov    (%ebx),%edx
  801f81:	83 c2 20             	add    $0x20,%edx
  801f84:	39 d0                	cmp    %edx,%eax
  801f86:	73 e2                	jae    801f6a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f8e:	89 c2                	mov    %eax,%edx
  801f90:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f96:	79 05                	jns    801f9d <devpipe_write+0x50>
  801f98:	4a                   	dec    %edx
  801f99:	83 ca e0             	or     $0xffffffe0,%edx
  801f9c:	42                   	inc    %edx
  801f9d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fa1:	40                   	inc    %eax
  801fa2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa5:	47                   	inc    %edi
  801fa6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fa9:	75 d1                	jne    801f7c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fab:	89 f8                	mov    %edi,%eax
  801fad:	eb 05                	jmp    801fb4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801faf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fb4:	83 c4 1c             	add    $0x1c,%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5f                   	pop    %edi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    

00801fbc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	57                   	push   %edi
  801fc0:	56                   	push   %esi
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 1c             	sub    $0x1c,%esp
  801fc5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fc8:	89 3c 24             	mov    %edi,(%esp)
  801fcb:	e8 d0 ef ff ff       	call   800fa0 <fd2data>
  801fd0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd2:	be 00 00 00 00       	mov    $0x0,%esi
  801fd7:	eb 3a                	jmp    802013 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fd9:	85 f6                	test   %esi,%esi
  801fdb:	74 04                	je     801fe1 <devpipe_read+0x25>
				return i;
  801fdd:	89 f0                	mov    %esi,%eax
  801fdf:	eb 40                	jmp    802021 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fe1:	89 da                	mov    %ebx,%edx
  801fe3:	89 f8                	mov    %edi,%eax
  801fe5:	e8 f5 fe ff ff       	call   801edf <_pipeisclosed>
  801fea:	85 c0                	test   %eax,%eax
  801fec:	75 2e                	jne    80201c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fee:	e8 b3 ec ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ff3:	8b 03                	mov    (%ebx),%eax
  801ff5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ff8:	74 df                	je     801fd9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ffa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801fff:	79 05                	jns    802006 <devpipe_read+0x4a>
  802001:	48                   	dec    %eax
  802002:	83 c8 e0             	or     $0xffffffe0,%eax
  802005:	40                   	inc    %eax
  802006:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80200a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802010:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802012:	46                   	inc    %esi
  802013:	3b 75 10             	cmp    0x10(%ebp),%esi
  802016:	75 db                	jne    801ff3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802018:	89 f0                	mov    %esi,%eax
  80201a:	eb 05                	jmp    802021 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80201c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802021:	83 c4 1c             	add    $0x1c,%esp
  802024:	5b                   	pop    %ebx
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	57                   	push   %edi
  80202d:	56                   	push   %esi
  80202e:	53                   	push   %ebx
  80202f:	83 ec 3c             	sub    $0x3c,%esp
  802032:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802035:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802038:	89 04 24             	mov    %eax,(%esp)
  80203b:	e8 7b ef ff ff       	call   800fbb <fd_alloc>
  802040:	89 c3                	mov    %eax,%ebx
  802042:	85 c0                	test   %eax,%eax
  802044:	0f 88 45 01 00 00    	js     80218f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802051:	00 
  802052:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802055:	89 44 24 04          	mov    %eax,0x4(%esp)
  802059:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802060:	e8 60 ec ff ff       	call   800cc5 <sys_page_alloc>
  802065:	89 c3                	mov    %eax,%ebx
  802067:	85 c0                	test   %eax,%eax
  802069:	0f 88 20 01 00 00    	js     80218f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80206f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802072:	89 04 24             	mov    %eax,(%esp)
  802075:	e8 41 ef ff ff       	call   800fbb <fd_alloc>
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	85 c0                	test   %eax,%eax
  80207e:	0f 88 f8 00 00 00    	js     80217c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802084:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80208b:	00 
  80208c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80208f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802093:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209a:	e8 26 ec ff ff       	call   800cc5 <sys_page_alloc>
  80209f:	89 c3                	mov    %eax,%ebx
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	0f 88 d3 00 00 00    	js     80217c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ac:	89 04 24             	mov    %eax,(%esp)
  8020af:	e8 ec ee ff ff       	call   800fa0 <fd2data>
  8020b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020bd:	00 
  8020be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c9:	e8 f7 eb ff ff       	call   800cc5 <sys_page_alloc>
  8020ce:	89 c3                	mov    %eax,%ebx
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	0f 88 91 00 00 00    	js     802169 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020db:	89 04 24             	mov    %eax,(%esp)
  8020de:	e8 bd ee ff ff       	call   800fa0 <fd2data>
  8020e3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8020ea:	00 
  8020eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020f6:	00 
  8020f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802102:	e8 12 ec ff ff       	call   800d19 <sys_page_map>
  802107:	89 c3                	mov    %eax,%ebx
  802109:	85 c0                	test   %eax,%eax
  80210b:	78 4c                	js     802159 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80210d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802116:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802118:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80211b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802122:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802128:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80212b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80212d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802130:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80213a:	89 04 24             	mov    %eax,(%esp)
  80213d:	e8 4e ee ff ff       	call   800f90 <fd2num>
  802142:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802144:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802147:	89 04 24             	mov    %eax,(%esp)
  80214a:	e8 41 ee ff ff       	call   800f90 <fd2num>
  80214f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802152:	bb 00 00 00 00       	mov    $0x0,%ebx
  802157:	eb 36                	jmp    80218f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802159:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802164:	e8 03 ec ff ff       	call   800d6c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802169:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80216c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802177:	e8 f0 eb ff ff       	call   800d6c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80217c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80217f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802183:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80218a:	e8 dd eb ff ff       	call   800d6c <sys_page_unmap>
    err:
	return r;
}
  80218f:	89 d8                	mov    %ebx,%eax
  802191:	83 c4 3c             	add    $0x3c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    

00802199 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	89 04 24             	mov    %eax,(%esp)
  8021ac:	e8 5d ee ff ff       	call   80100e <fd_lookup>
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	78 15                	js     8021ca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b8:	89 04 24             	mov    %eax,(%esp)
  8021bb:	e8 e0 ed ff ff       	call   800fa0 <fd2data>
	return _pipeisclosed(fd, p);
  8021c0:	89 c2                	mov    %eax,%edx
  8021c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c5:	e8 15 fd ff ff       	call   801edf <_pipeisclosed>
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8021dc:	c7 44 24 04 0f 2c 80 	movl   $0x802c0f,0x4(%esp)
  8021e3:	00 
  8021e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e7:	89 04 24             	mov    %eax,(%esp)
  8021ea:	e8 e4 e6 ff ff       	call   8008d3 <strcpy>
	return 0;
}
  8021ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f4:	c9                   	leave  
  8021f5:	c3                   	ret    

008021f6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
  8021f9:	57                   	push   %edi
  8021fa:	56                   	push   %esi
  8021fb:	53                   	push   %ebx
  8021fc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802202:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802207:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80220d:	eb 30                	jmp    80223f <devcons_write+0x49>
		m = n - tot;
  80220f:	8b 75 10             	mov    0x10(%ebp),%esi
  802212:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802214:	83 fe 7f             	cmp    $0x7f,%esi
  802217:	76 05                	jbe    80221e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802219:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80221e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802222:	03 45 0c             	add    0xc(%ebp),%eax
  802225:	89 44 24 04          	mov    %eax,0x4(%esp)
  802229:	89 3c 24             	mov    %edi,(%esp)
  80222c:	e8 1b e8 ff ff       	call   800a4c <memmove>
		sys_cputs(buf, m);
  802231:	89 74 24 04          	mov    %esi,0x4(%esp)
  802235:	89 3c 24             	mov    %edi,(%esp)
  802238:	e8 bb e9 ff ff       	call   800bf8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80223d:	01 f3                	add    %esi,%ebx
  80223f:	89 d8                	mov    %ebx,%eax
  802241:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802244:	72 c9                	jb     80220f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802246:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80224c:	5b                   	pop    %ebx
  80224d:	5e                   	pop    %esi
  80224e:	5f                   	pop    %edi
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    

00802251 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802251:	55                   	push   %ebp
  802252:	89 e5                	mov    %esp,%ebp
  802254:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802257:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80225b:	75 07                	jne    802264 <devcons_read+0x13>
  80225d:	eb 25                	jmp    802284 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80225f:	e8 42 ea ff ff       	call   800ca6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802264:	e8 ad e9 ff ff       	call   800c16 <sys_cgetc>
  802269:	85 c0                	test   %eax,%eax
  80226b:	74 f2                	je     80225f <devcons_read+0xe>
  80226d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80226f:	85 c0                	test   %eax,%eax
  802271:	78 1d                	js     802290 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802273:	83 f8 04             	cmp    $0x4,%eax
  802276:	74 13                	je     80228b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80227b:	88 10                	mov    %dl,(%eax)
	return 1;
  80227d:	b8 01 00 00 00       	mov    $0x1,%eax
  802282:	eb 0c                	jmp    802290 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802284:	b8 00 00 00 00       	mov    $0x0,%eax
  802289:	eb 05                	jmp    802290 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80228b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802298:	8b 45 08             	mov    0x8(%ebp),%eax
  80229b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80229e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8022a5:	00 
  8022a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a9:	89 04 24             	mov    %eax,(%esp)
  8022ac:	e8 47 e9 ff ff       	call   800bf8 <sys_cputs>
}
  8022b1:	c9                   	leave  
  8022b2:	c3                   	ret    

008022b3 <getchar>:

int
getchar(void)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8022c0:	00 
  8022c1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022cf:	e8 d8 ef ff ff       	call   8012ac <read>
	if (r < 0)
  8022d4:	85 c0                	test   %eax,%eax
  8022d6:	78 0f                	js     8022e7 <getchar+0x34>
		return r;
	if (r < 1)
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	7e 06                	jle    8022e2 <getchar+0x2f>
		return -E_EOF;
	return c;
  8022dc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022e0:	eb 05                	jmp    8022e7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022e2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022e7:	c9                   	leave  
  8022e8:	c3                   	ret    

008022e9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f9:	89 04 24             	mov    %eax,(%esp)
  8022fc:	e8 0d ed ff ff       	call   80100e <fd_lookup>
  802301:	85 c0                	test   %eax,%eax
  802303:	78 11                	js     802316 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802305:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802308:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80230e:	39 10                	cmp    %edx,(%eax)
  802310:	0f 94 c0             	sete   %al
  802313:	0f b6 c0             	movzbl %al,%eax
}
  802316:	c9                   	leave  
  802317:	c3                   	ret    

00802318 <opencons>:

int
opencons(void)
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80231e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802321:	89 04 24             	mov    %eax,(%esp)
  802324:	e8 92 ec ff ff       	call   800fbb <fd_alloc>
  802329:	85 c0                	test   %eax,%eax
  80232b:	78 3c                	js     802369 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80232d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802334:	00 
  802335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802343:	e8 7d e9 ff ff       	call   800cc5 <sys_page_alloc>
  802348:	85 c0                	test   %eax,%eax
  80234a:	78 1d                	js     802369 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80234c:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802355:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802361:	89 04 24             	mov    %eax,(%esp)
  802364:	e8 27 ec ff ff       	call   800f90 <fd2num>
}
  802369:	c9                   	leave  
  80236a:	c3                   	ret    
	...

0080236c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	56                   	push   %esi
  802370:	53                   	push   %ebx
  802371:	83 ec 10             	sub    $0x10,%esp
  802374:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802377:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  80237d:	85 c0                	test   %eax,%eax
  80237f:	74 0a                	je     80238b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802381:	89 04 24             	mov    %eax,(%esp)
  802384:	e8 52 eb ff ff       	call   800edb <sys_ipc_recv>
  802389:	eb 0c                	jmp    802397 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80238b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802392:	e8 44 eb ff ff       	call   800edb <sys_ipc_recv>
	}
	if (r < 0)
  802397:	85 c0                	test   %eax,%eax
  802399:	79 16                	jns    8023b1 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80239b:	85 db                	test   %ebx,%ebx
  80239d:	74 06                	je     8023a5 <ipc_recv+0x39>
  80239f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8023a5:	85 f6                	test   %esi,%esi
  8023a7:	74 2c                	je     8023d5 <ipc_recv+0x69>
  8023a9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8023af:	eb 24                	jmp    8023d5 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8023b1:	85 db                	test   %ebx,%ebx
  8023b3:	74 0a                	je     8023bf <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8023b5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023ba:	8b 40 74             	mov    0x74(%eax),%eax
  8023bd:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8023bf:	85 f6                	test   %esi,%esi
  8023c1:	74 0a                	je     8023cd <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8023c3:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023c8:	8b 40 78             	mov    0x78(%eax),%eax
  8023cb:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8023cd:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023d2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8023d5:	83 c4 10             	add    $0x10,%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    

008023dc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023dc:	55                   	push   %ebp
  8023dd:	89 e5                	mov    %esp,%ebp
  8023df:	57                   	push   %edi
  8023e0:	56                   	push   %esi
  8023e1:	53                   	push   %ebx
  8023e2:	83 ec 1c             	sub    $0x1c,%esp
  8023e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8023e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8023ee:	85 db                	test   %ebx,%ebx
  8023f0:	74 19                	je     80240b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8023f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8023f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802401:	89 34 24             	mov    %esi,(%esp)
  802404:	e8 af ea ff ff       	call   800eb8 <sys_ipc_try_send>
  802409:	eb 1c                	jmp    802427 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80240b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802412:	00 
  802413:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80241a:	ee 
  80241b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80241f:	89 34 24             	mov    %esi,(%esp)
  802422:	e8 91 ea ff ff       	call   800eb8 <sys_ipc_try_send>
		}
		if (r == 0)
  802427:	85 c0                	test   %eax,%eax
  802429:	74 2c                	je     802457 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80242b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80242e:	74 20                	je     802450 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802430:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802434:	c7 44 24 08 1b 2c 80 	movl   $0x802c1b,0x8(%esp)
  80243b:	00 
  80243c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802443:	00 
  802444:	c7 04 24 2e 2c 80 00 	movl   $0x802c2e,(%esp)
  80244b:	e8 e0 dd ff ff       	call   800230 <_panic>
		}
		sys_yield();
  802450:	e8 51 e8 ff ff       	call   800ca6 <sys_yield>
	}
  802455:	eb 97                	jmp    8023ee <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802457:	83 c4 1c             	add    $0x1c,%esp
  80245a:	5b                   	pop    %ebx
  80245b:	5e                   	pop    %esi
  80245c:	5f                   	pop    %edi
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    

0080245f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	53                   	push   %ebx
  802463:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802466:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80246b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802472:	89 c2                	mov    %eax,%edx
  802474:	c1 e2 07             	shl    $0x7,%edx
  802477:	29 ca                	sub    %ecx,%edx
  802479:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80247f:	8b 52 50             	mov    0x50(%edx),%edx
  802482:	39 da                	cmp    %ebx,%edx
  802484:	75 0f                	jne    802495 <ipc_find_env+0x36>
			return envs[i].env_id;
  802486:	c1 e0 07             	shl    $0x7,%eax
  802489:	29 c8                	sub    %ecx,%eax
  80248b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802490:	8b 40 40             	mov    0x40(%eax),%eax
  802493:	eb 0c                	jmp    8024a1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802495:	40                   	inc    %eax
  802496:	3d 00 04 00 00       	cmp    $0x400,%eax
  80249b:	75 ce                	jne    80246b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80249d:	66 b8 00 00          	mov    $0x0,%ax
}
  8024a1:	5b                   	pop    %ebx
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    

008024a4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024aa:	89 c2                	mov    %eax,%edx
  8024ac:	c1 ea 16             	shr    $0x16,%edx
  8024af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024b6:	f6 c2 01             	test   $0x1,%dl
  8024b9:	74 1e                	je     8024d9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024bb:	c1 e8 0c             	shr    $0xc,%eax
  8024be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024c5:	a8 01                	test   $0x1,%al
  8024c7:	74 17                	je     8024e0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024c9:	c1 e8 0c             	shr    $0xc,%eax
  8024cc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8024d3:	ef 
  8024d4:	0f b7 c0             	movzwl %ax,%eax
  8024d7:	eb 0c                	jmp    8024e5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8024d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8024de:	eb 05                	jmp    8024e5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8024e0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8024e5:	5d                   	pop    %ebp
  8024e6:	c3                   	ret    
	...

008024e8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8024e8:	55                   	push   %ebp
  8024e9:	57                   	push   %edi
  8024ea:	56                   	push   %esi
  8024eb:	83 ec 10             	sub    $0x10,%esp
  8024ee:	8b 74 24 20          	mov    0x20(%esp),%esi
  8024f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024fa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8024fe:	89 cd                	mov    %ecx,%ebp
  802500:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802504:	85 c0                	test   %eax,%eax
  802506:	75 2c                	jne    802534 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802508:	39 f9                	cmp    %edi,%ecx
  80250a:	77 68                	ja     802574 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80250c:	85 c9                	test   %ecx,%ecx
  80250e:	75 0b                	jne    80251b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802510:	b8 01 00 00 00       	mov    $0x1,%eax
  802515:	31 d2                	xor    %edx,%edx
  802517:	f7 f1                	div    %ecx
  802519:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	89 f8                	mov    %edi,%eax
  80251f:	f7 f1                	div    %ecx
  802521:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802523:	89 f0                	mov    %esi,%eax
  802525:	f7 f1                	div    %ecx
  802527:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802529:	89 f0                	mov    %esi,%eax
  80252b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80252d:	83 c4 10             	add    $0x10,%esp
  802530:	5e                   	pop    %esi
  802531:	5f                   	pop    %edi
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802534:	39 f8                	cmp    %edi,%eax
  802536:	77 2c                	ja     802564 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802538:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80253b:	83 f6 1f             	xor    $0x1f,%esi
  80253e:	75 4c                	jne    80258c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802540:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802542:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802547:	72 0a                	jb     802553 <__udivdi3+0x6b>
  802549:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80254d:	0f 87 ad 00 00 00    	ja     802600 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802553:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802558:	89 f0                	mov    %esi,%eax
  80255a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80255c:	83 c4 10             	add    $0x10,%esp
  80255f:	5e                   	pop    %esi
  802560:	5f                   	pop    %edi
  802561:	5d                   	pop    %ebp
  802562:	c3                   	ret    
  802563:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802564:	31 ff                	xor    %edi,%edi
  802566:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802568:	89 f0                	mov    %esi,%eax
  80256a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80256c:	83 c4 10             	add    $0x10,%esp
  80256f:	5e                   	pop    %esi
  802570:	5f                   	pop    %edi
  802571:	5d                   	pop    %ebp
  802572:	c3                   	ret    
  802573:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802574:	89 fa                	mov    %edi,%edx
  802576:	89 f0                	mov    %esi,%eax
  802578:	f7 f1                	div    %ecx
  80257a:	89 c6                	mov    %eax,%esi
  80257c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80257e:	89 f0                	mov    %esi,%eax
  802580:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802582:	83 c4 10             	add    $0x10,%esp
  802585:	5e                   	pop    %esi
  802586:	5f                   	pop    %edi
  802587:	5d                   	pop    %ebp
  802588:	c3                   	ret    
  802589:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80258c:	89 f1                	mov    %esi,%ecx
  80258e:	d3 e0                	shl    %cl,%eax
  802590:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802594:	b8 20 00 00 00       	mov    $0x20,%eax
  802599:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80259b:	89 ea                	mov    %ebp,%edx
  80259d:	88 c1                	mov    %al,%cl
  80259f:	d3 ea                	shr    %cl,%edx
  8025a1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8025a5:	09 ca                	or     %ecx,%edx
  8025a7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8025ab:	89 f1                	mov    %esi,%ecx
  8025ad:	d3 e5                	shl    %cl,%ebp
  8025af:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8025b3:	89 fd                	mov    %edi,%ebp
  8025b5:	88 c1                	mov    %al,%cl
  8025b7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8025b9:	89 fa                	mov    %edi,%edx
  8025bb:	89 f1                	mov    %esi,%ecx
  8025bd:	d3 e2                	shl    %cl,%edx
  8025bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025c3:	88 c1                	mov    %al,%cl
  8025c5:	d3 ef                	shr    %cl,%edi
  8025c7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025c9:	89 f8                	mov    %edi,%eax
  8025cb:	89 ea                	mov    %ebp,%edx
  8025cd:	f7 74 24 08          	divl   0x8(%esp)
  8025d1:	89 d1                	mov    %edx,%ecx
  8025d3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8025d5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025d9:	39 d1                	cmp    %edx,%ecx
  8025db:	72 17                	jb     8025f4 <__udivdi3+0x10c>
  8025dd:	74 09                	je     8025e8 <__udivdi3+0x100>
  8025df:	89 fe                	mov    %edi,%esi
  8025e1:	31 ff                	xor    %edi,%edi
  8025e3:	e9 41 ff ff ff       	jmp    802529 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8025e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025ec:	89 f1                	mov    %esi,%ecx
  8025ee:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025f0:	39 c2                	cmp    %eax,%edx
  8025f2:	73 eb                	jae    8025df <__udivdi3+0xf7>
		{
		  q0--;
  8025f4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025f7:	31 ff                	xor    %edi,%edi
  8025f9:	e9 2b ff ff ff       	jmp    802529 <__udivdi3+0x41>
  8025fe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802600:	31 f6                	xor    %esi,%esi
  802602:	e9 22 ff ff ff       	jmp    802529 <__udivdi3+0x41>
	...

00802608 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802608:	55                   	push   %ebp
  802609:	57                   	push   %edi
  80260a:	56                   	push   %esi
  80260b:	83 ec 20             	sub    $0x20,%esp
  80260e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802612:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802616:	89 44 24 14          	mov    %eax,0x14(%esp)
  80261a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80261e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802622:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802626:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802628:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80262a:	85 ed                	test   %ebp,%ebp
  80262c:	75 16                	jne    802644 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80262e:	39 f1                	cmp    %esi,%ecx
  802630:	0f 86 a6 00 00 00    	jbe    8026dc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802636:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802638:	89 d0                	mov    %edx,%eax
  80263a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80263c:	83 c4 20             	add    $0x20,%esp
  80263f:	5e                   	pop    %esi
  802640:	5f                   	pop    %edi
  802641:	5d                   	pop    %ebp
  802642:	c3                   	ret    
  802643:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802644:	39 f5                	cmp    %esi,%ebp
  802646:	0f 87 ac 00 00 00    	ja     8026f8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80264c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80264f:	83 f0 1f             	xor    $0x1f,%eax
  802652:	89 44 24 10          	mov    %eax,0x10(%esp)
  802656:	0f 84 a8 00 00 00    	je     802704 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80265c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802660:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802662:	bf 20 00 00 00       	mov    $0x20,%edi
  802667:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80266b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80266f:	89 f9                	mov    %edi,%ecx
  802671:	d3 e8                	shr    %cl,%eax
  802673:	09 e8                	or     %ebp,%eax
  802675:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802679:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80267d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802681:	d3 e0                	shl    %cl,%eax
  802683:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802687:	89 f2                	mov    %esi,%edx
  802689:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80268b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80268f:	d3 e0                	shl    %cl,%eax
  802691:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802695:	8b 44 24 14          	mov    0x14(%esp),%eax
  802699:	89 f9                	mov    %edi,%ecx
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80269f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8026a1:	89 f2                	mov    %esi,%edx
  8026a3:	f7 74 24 18          	divl   0x18(%esp)
  8026a7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8026a9:	f7 64 24 0c          	mull   0xc(%esp)
  8026ad:	89 c5                	mov    %eax,%ebp
  8026af:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026b1:	39 d6                	cmp    %edx,%esi
  8026b3:	72 67                	jb     80271c <__umoddi3+0x114>
  8026b5:	74 75                	je     80272c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8026b7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8026bb:	29 e8                	sub    %ebp,%eax
  8026bd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8026bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026c3:	d3 e8                	shr    %cl,%eax
  8026c5:	89 f2                	mov    %esi,%edx
  8026c7:	89 f9                	mov    %edi,%ecx
  8026c9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8026cb:	09 d0                	or     %edx,%eax
  8026cd:	89 f2                	mov    %esi,%edx
  8026cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026d3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026d5:	83 c4 20             	add    $0x20,%esp
  8026d8:	5e                   	pop    %esi
  8026d9:	5f                   	pop    %edi
  8026da:	5d                   	pop    %ebp
  8026db:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026dc:	85 c9                	test   %ecx,%ecx
  8026de:	75 0b                	jne    8026eb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8026e5:	31 d2                	xor    %edx,%edx
  8026e7:	f7 f1                	div    %ecx
  8026e9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8026eb:	89 f0                	mov    %esi,%eax
  8026ed:	31 d2                	xor    %edx,%edx
  8026ef:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026f1:	89 f8                	mov    %edi,%eax
  8026f3:	e9 3e ff ff ff       	jmp    802636 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8026f8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026fa:	83 c4 20             	add    $0x20,%esp
  8026fd:	5e                   	pop    %esi
  8026fe:	5f                   	pop    %edi
  8026ff:	5d                   	pop    %ebp
  802700:	c3                   	ret    
  802701:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802704:	39 f5                	cmp    %esi,%ebp
  802706:	72 04                	jb     80270c <__umoddi3+0x104>
  802708:	39 f9                	cmp    %edi,%ecx
  80270a:	77 06                	ja     802712 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80270c:	89 f2                	mov    %esi,%edx
  80270e:	29 cf                	sub    %ecx,%edi
  802710:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802712:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802714:	83 c4 20             	add    $0x20,%esp
  802717:	5e                   	pop    %esi
  802718:	5f                   	pop    %edi
  802719:	5d                   	pop    %ebp
  80271a:	c3                   	ret    
  80271b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80271c:	89 d1                	mov    %edx,%ecx
  80271e:	89 c5                	mov    %eax,%ebp
  802720:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802724:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802728:	eb 8d                	jmp    8026b7 <__umoddi3+0xaf>
  80272a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80272c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802730:	72 ea                	jb     80271c <__umoddi3+0x114>
  802732:	89 f1                	mov    %esi,%ecx
  802734:	eb 81                	jmp    8026b7 <__umoddi3+0xaf>
