
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 2b 01 00 00       	call   80015c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 40 80 00 20 	movl   $0x802c20,0x804000
  800046:	2c 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 26 2c 80 00 	movl   $0x802c26,(%esp)
  800050:	e8 6f 02 00 00       	call   8002c4 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 35 2c 80 00 	movl   $0x802c35,(%esp)
  80005c:	e8 63 02 00 00       	call   8002c4 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 48 2c 80 00 	movl   $0x802c48,(%esp)
  800070:	e8 a6 16 00 00       	call   80171b <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 4e 2c 80 	movl   $0x802c4e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 64 2c 80 00 	movl   $0x802c64,(%esp)
  800096:	e8 31 01 00 00       	call   8001cc <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 71 2c 80 00 	movl   $0x802c71,(%esp)
  8000a2:	e8 1d 02 00 00       	call   8002c4 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 d9 0a 00 00       	call   800b94 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 79 11 00 00       	call   801248 <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 84 2c 80 00 	movl   $0x802c84,(%esp)
  8000da:	e8 e5 01 00 00       	call   8002c4 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 fb 0f 00 00       	call   8010e2 <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 98 2c 80 00 	movl   $0x802c98,(%esp)
  8000ee:	e8 d1 01 00 00       	call   8002c4 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c ac 2c 80 	movl   $0x802cac,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 b5 2c 80 	movl   $0x802cb5,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 bf 2c 80 	movl   $0x802cbf,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 be 2c 80 00 	movl   $0x802cbe,(%esp)
  80011a:	e8 9d 1c 00 00       	call   801dbc <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 c4 2c 80 	movl   $0x802cc4,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 64 2c 80 00 	movl   $0x802c64,(%esp)
  80013e:	e8 89 00 00 00       	call   8001cc <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 db 2c 80 00 	movl   $0x802cdb,(%esp)
  80014a:	e8 75 01 00 00       	call   8002c4 <cprintf>
}
  80014f:	81 c4 30 02 00 00    	add    $0x230,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 10             	sub    $0x10,%esp
  800164:	8b 75 08             	mov    0x8(%ebp),%esi
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80016a:	e8 b4 0a 00 00       	call   800c23 <sys_getenvid>
  80016f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800174:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80017b:	c1 e0 07             	shl    $0x7,%eax
  80017e:	29 d0                	sub    %edx,%eax
  800180:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800185:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80018a:	85 f6                	test   %esi,%esi
  80018c:	7e 07                	jle    800195 <libmain+0x39>
		binaryname = argv[0];
  80018e:	8b 03                	mov    (%ebx),%eax
  800190:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800195:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800199:	89 34 24             	mov    %esi,(%esp)
  80019c:	e8 93 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001a1:	e8 0a 00 00 00       	call   8001b0 <exit>
}
  8001a6:	83 c4 10             	add    $0x10,%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    
  8001ad:	00 00                	add    %al,(%eax)
	...

008001b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001b6:	e8 58 0f 00 00       	call   801113 <close_all>
	sys_env_destroy(0);
  8001bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001c2:	e8 0a 0a 00 00       	call   800bd1 <sys_env_destroy>
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    
  8001c9:	00 00                	add    %al,(%eax)
	...

008001cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001d4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d7:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001dd:	e8 41 0a 00 00       	call   800c23 <sys_getenvid>
  8001e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f8:	c7 04 24 f8 2c 80 00 	movl   $0x802cf8,(%esp)
  8001ff:	e8 c0 00 00 00       	call   8002c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800204:	89 74 24 04          	mov    %esi,0x4(%esp)
  800208:	8b 45 10             	mov    0x10(%ebp),%eax
  80020b:	89 04 24             	mov    %eax,(%esp)
  80020e:	e8 50 00 00 00       	call   800263 <vcprintf>
	cprintf("\n");
  800213:	c7 04 24 15 32 80 00 	movl   $0x803215,(%esp)
  80021a:	e8 a5 00 00 00       	call   8002c4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021f:	cc                   	int3   
  800220:	eb fd                	jmp    80021f <_panic+0x53>
	...

00800224 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	83 ec 14             	sub    $0x14,%esp
  80022b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022e:	8b 03                	mov    (%ebx),%eax
  800230:	8b 55 08             	mov    0x8(%ebp),%edx
  800233:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800237:	40                   	inc    %eax
  800238:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80023a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023f:	75 19                	jne    80025a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800241:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800248:	00 
  800249:	8d 43 08             	lea    0x8(%ebx),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 40 09 00 00       	call   800b94 <sys_cputs>
		b->idx = 0;
  800254:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80025a:	ff 43 04             	incl   0x4(%ebx)
}
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	5b                   	pop    %ebx
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80026c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800273:	00 00 00 
	b.cnt = 0;
  800276:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800294:	89 44 24 04          	mov    %eax,0x4(%esp)
  800298:	c7 04 24 24 02 80 00 	movl   $0x800224,(%esp)
  80029f:	e8 82 01 00 00       	call   800426 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 d8 08 00 00       	call   800b94 <sys_cputs>

	return b.cnt;
}
  8002bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 87 ff ff ff       	call   800263 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    
	...

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 3c             	sub    $0x3c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800300:	85 c0                	test   %eax,%eax
  800302:	75 08                	jne    80030c <printnum+0x2c>
  800304:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800307:	39 45 10             	cmp    %eax,0x10(%ebp)
  80030a:	77 57                	ja     800363 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800310:	4b                   	dec    %ebx
  800311:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800315:	8b 45 10             	mov    0x10(%ebp),%eax
  800318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800320:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800324:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032b:	00 
  80032c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	e8 7e 26 00 00       	call   8029bc <__udivdi3>
  80033e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800342:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800346:	89 04 24             	mov    %eax,(%esp)
  800349:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034d:	89 fa                	mov    %edi,%edx
  80034f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800352:	e8 89 ff ff ff       	call   8002e0 <printnum>
  800357:	eb 0f                	jmp    800368 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800359:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035d:	89 34 24             	mov    %esi,(%esp)
  800360:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800363:	4b                   	dec    %ebx
  800364:	85 db                	test   %ebx,%ebx
  800366:	7f f1                	jg     800359 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800368:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800370:	8b 45 10             	mov    0x10(%ebp),%eax
  800373:	89 44 24 08          	mov    %eax,0x8(%esp)
  800377:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037e:	00 
  80037f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800382:	89 04 24             	mov    %eax,(%esp)
  800385:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038c:	e8 4b 27 00 00       	call   802adc <__umoddi3>
  800391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800395:	0f be 80 1b 2d 80 00 	movsbl 0x802d1b(%eax),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003a2:	83 c4 3c             	add    $0x3c,%esp
  8003a5:	5b                   	pop    %ebx
  8003a6:	5e                   	pop    %esi
  8003a7:	5f                   	pop    %edi
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ad:	83 fa 01             	cmp    $0x1,%edx
  8003b0:	7e 0e                	jle    8003c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	8b 52 04             	mov    0x4(%edx),%edx
  8003be:	eb 22                	jmp    8003e2 <getuint+0x38>
	else if (lflag)
  8003c0:	85 d2                	test   %edx,%edx
  8003c2:	74 10                	je     8003d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c4:	8b 10                	mov    (%eax),%edx
  8003c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c9:	89 08                	mov    %ecx,(%eax)
  8003cb:	8b 02                	mov    (%edx),%eax
  8003cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d2:	eb 0e                	jmp    8003e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d4:	8b 10                	mov    (%eax),%edx
  8003d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d9:	89 08                	mov    %ecx,(%eax)
  8003db:	8b 02                	mov    (%edx),%eax
  8003dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ea:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f2:	73 08                	jae    8003fc <sprintputch+0x18>
		*b->buf++ = ch;
  8003f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f7:	88 0a                	mov    %cl,(%edx)
  8003f9:	42                   	inc    %edx
  8003fa:	89 10                	mov    %edx,(%eax)
}
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    

008003fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800407:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040b:	8b 45 10             	mov    0x10(%ebp),%eax
  80040e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800412:	8b 45 0c             	mov    0xc(%ebp),%eax
  800415:	89 44 24 04          	mov    %eax,0x4(%esp)
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	e8 02 00 00 00       	call   800426 <vprintfmt>
	va_end(ap);
}
  800424:	c9                   	leave  
  800425:	c3                   	ret    

00800426 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	57                   	push   %edi
  80042a:	56                   	push   %esi
  80042b:	53                   	push   %ebx
  80042c:	83 ec 4c             	sub    $0x4c,%esp
  80042f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800432:	8b 75 10             	mov    0x10(%ebp),%esi
  800435:	eb 12                	jmp    800449 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800437:	85 c0                	test   %eax,%eax
  800439:	0f 84 6b 03 00 00    	je     8007aa <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80043f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	0f b6 06             	movzbl (%esi),%eax
  80044c:	46                   	inc    %esi
  80044d:	83 f8 25             	cmp    $0x25,%eax
  800450:	75 e5                	jne    800437 <vprintfmt+0x11>
  800452:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800456:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80045d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800462:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800469:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046e:	eb 26                	jmp    800496 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800473:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800477:	eb 1d                	jmp    800496 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80047c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800480:	eb 14                	jmp    800496 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800485:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80048c:	eb 08                	jmp    800496 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80048e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800491:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	0f b6 06             	movzbl (%esi),%eax
  800499:	8d 56 01             	lea    0x1(%esi),%edx
  80049c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80049f:	8a 16                	mov    (%esi),%dl
  8004a1:	83 ea 23             	sub    $0x23,%edx
  8004a4:	80 fa 55             	cmp    $0x55,%dl
  8004a7:	0f 87 e1 02 00 00    	ja     80078e <vprintfmt+0x368>
  8004ad:	0f b6 d2             	movzbl %dl,%edx
  8004b0:	ff 24 95 60 2e 80 00 	jmp    *0x802e60(,%edx,4)
  8004b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ba:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004bf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004c2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004c6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004cc:	83 fa 09             	cmp    $0x9,%edx
  8004cf:	77 2a                	ja     8004fb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d2:	eb eb                	jmp    8004bf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e2:	eb 17                	jmp    8004fb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e8:	78 98                	js     800482 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ed:	eb a7                	jmp    800496 <vprintfmt+0x70>
  8004ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004f9:	eb 9b                	jmp    800496 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ff:	79 95                	jns    800496 <vprintfmt+0x70>
  800501:	eb 8b                	jmp    80048e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800503:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800507:	eb 8d                	jmp    800496 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 04 24             	mov    %eax,(%esp)
  80051b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800521:	e9 23 ff ff ff       	jmp    800449 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 50 04             	lea    0x4(%eax),%edx
  80052c:	89 55 14             	mov    %edx,0x14(%ebp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	85 c0                	test   %eax,%eax
  800533:	79 02                	jns    800537 <vprintfmt+0x111>
  800535:	f7 d8                	neg    %eax
  800537:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800539:	83 f8 10             	cmp    $0x10,%eax
  80053c:	7f 0b                	jg     800549 <vprintfmt+0x123>
  80053e:	8b 04 85 c0 2f 80 00 	mov    0x802fc0(,%eax,4),%eax
  800545:	85 c0                	test   %eax,%eax
  800547:	75 23                	jne    80056c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800549:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054d:	c7 44 24 08 33 2d 80 	movl   $0x802d33,0x8(%esp)
  800554:	00 
  800555:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	e8 9a fe ff ff       	call   8003fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800567:	e9 dd fe ff ff       	jmp    800449 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80056c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800570:	c7 44 24 08 f9 30 80 	movl   $0x8030f9,0x8(%esp)
  800577:	00 
  800578:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057c:	8b 55 08             	mov    0x8(%ebp),%edx
  80057f:	89 14 24             	mov    %edx,(%esp)
  800582:	e8 77 fe ff ff       	call   8003fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80058a:	e9 ba fe ff ff       	jmp    800449 <vprintfmt+0x23>
  80058f:	89 f9                	mov    %edi,%ecx
  800591:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800594:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 50 04             	lea    0x4(%eax),%edx
  80059d:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a0:	8b 30                	mov    (%eax),%esi
  8005a2:	85 f6                	test   %esi,%esi
  8005a4:	75 05                	jne    8005ab <vprintfmt+0x185>
				p = "(null)";
  8005a6:	be 2c 2d 80 00       	mov    $0x802d2c,%esi
			if (width > 0 && padc != '-')
  8005ab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005af:	0f 8e 84 00 00 00    	jle    800639 <vprintfmt+0x213>
  8005b5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005b9:	74 7e                	je     800639 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005bf:	89 34 24             	mov    %esi,(%esp)
  8005c2:	e8 8b 02 00 00       	call   800852 <strnlen>
  8005c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ca:	29 c2                	sub    %eax,%edx
  8005cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005cf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005d3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005d6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005d9:	89 de                	mov    %ebx,%esi
  8005db:	89 d3                	mov    %edx,%ebx
  8005dd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	eb 0b                	jmp    8005ec <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e5:	89 3c 24             	mov    %edi,(%esp)
  8005e8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005eb:	4b                   	dec    %ebx
  8005ec:	85 db                	test   %ebx,%ebx
  8005ee:	7f f1                	jg     8005e1 <vprintfmt+0x1bb>
  8005f0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f3:	89 f3                	mov    %esi,%ebx
  8005f5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	79 05                	jns    800604 <vprintfmt+0x1de>
  8005ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800604:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800607:	29 c2                	sub    %eax,%edx
  800609:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80060c:	eb 2b                	jmp    800639 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800612:	74 18                	je     80062c <vprintfmt+0x206>
  800614:	8d 50 e0             	lea    -0x20(%eax),%edx
  800617:	83 fa 5e             	cmp    $0x5e,%edx
  80061a:	76 10                	jbe    80062c <vprintfmt+0x206>
					putch('?', putdat);
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
  80062a:	eb 0a                	jmp    800636 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80062c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800636:	ff 4d e4             	decl   -0x1c(%ebp)
  800639:	0f be 06             	movsbl (%esi),%eax
  80063c:	46                   	inc    %esi
  80063d:	85 c0                	test   %eax,%eax
  80063f:	74 21                	je     800662 <vprintfmt+0x23c>
  800641:	85 ff                	test   %edi,%edi
  800643:	78 c9                	js     80060e <vprintfmt+0x1e8>
  800645:	4f                   	dec    %edi
  800646:	79 c6                	jns    80060e <vprintfmt+0x1e8>
  800648:	8b 7d 08             	mov    0x8(%ebp),%edi
  80064b:	89 de                	mov    %ebx,%esi
  80064d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800650:	eb 18                	jmp    80066a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800652:	89 74 24 04          	mov    %esi,0x4(%esp)
  800656:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80065d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065f:	4b                   	dec    %ebx
  800660:	eb 08                	jmp    80066a <vprintfmt+0x244>
  800662:	8b 7d 08             	mov    0x8(%ebp),%edi
  800665:	89 de                	mov    %ebx,%esi
  800667:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80066a:	85 db                	test   %ebx,%ebx
  80066c:	7f e4                	jg     800652 <vprintfmt+0x22c>
  80066e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800671:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	e9 ce fd ff ff       	jmp    800449 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067b:	83 f9 01             	cmp    $0x1,%ecx
  80067e:	7e 10                	jle    800690 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 08             	lea    0x8(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 30                	mov    (%eax),%esi
  80068b:	8b 78 04             	mov    0x4(%eax),%edi
  80068e:	eb 26                	jmp    8006b6 <vprintfmt+0x290>
	else if (lflag)
  800690:	85 c9                	test   %ecx,%ecx
  800692:	74 12                	je     8006a6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 30                	mov    (%eax),%esi
  80069f:	89 f7                	mov    %esi,%edi
  8006a1:	c1 ff 1f             	sar    $0x1f,%edi
  8006a4:	eb 10                	jmp    8006b6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 30                	mov    (%eax),%esi
  8006b1:	89 f7                	mov    %esi,%edi
  8006b3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b6:	85 ff                	test   %edi,%edi
  8006b8:	78 0a                	js     8006c4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bf:	e9 8c 00 00 00       	jmp    800750 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006d2:	f7 de                	neg    %esi
  8006d4:	83 d7 00             	adc    $0x0,%edi
  8006d7:	f7 df                	neg    %edi
			}
			base = 10;
  8006d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006de:	eb 70                	jmp    800750 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e0:	89 ca                	mov    %ecx,%edx
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e5:	e8 c0 fc ff ff       	call   8003aa <getuint>
  8006ea:	89 c6                	mov    %eax,%esi
  8006ec:	89 d7                	mov    %edx,%edi
			base = 10;
  8006ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006f3:	eb 5b                	jmp    800750 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8006f5:	89 ca                	mov    %ecx,%edx
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	e8 ab fc ff ff       	call   8003aa <getuint>
  8006ff:	89 c6                	mov    %eax,%esi
  800701:	89 d7                	mov    %edx,%edi
			base = 8;
  800703:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800708:	eb 46                	jmp    800750 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80070a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800715:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800718:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072f:	8b 30                	mov    (%eax),%esi
  800731:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800736:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80073b:	eb 13                	jmp    800750 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073d:	89 ca                	mov    %ecx,%edx
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
  800742:	e8 63 fc ff ff       	call   8003aa <getuint>
  800747:	89 c6                	mov    %eax,%esi
  800749:	89 d7                	mov    %edx,%edi
			base = 16;
  80074b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800750:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800754:	89 54 24 10          	mov    %edx,0x10(%esp)
  800758:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80075b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80075f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800763:	89 34 24             	mov    %esi,(%esp)
  800766:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076a:	89 da                	mov    %ebx,%edx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	e8 6c fb ff ff       	call   8002e0 <printnum>
			break;
  800774:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800777:	e9 cd fc ff ff       	jmp    800449 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800789:	e9 bb fc ff ff       	jmp    800449 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800792:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800799:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079c:	eb 01                	jmp    80079f <vprintfmt+0x379>
  80079e:	4e                   	dec    %esi
  80079f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007a3:	75 f9                	jne    80079e <vprintfmt+0x378>
  8007a5:	e9 9f fc ff ff       	jmp    800449 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007aa:	83 c4 4c             	add    $0x4c,%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 28             	sub    $0x28,%esp
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	74 30                	je     800803 <vsnprintf+0x51>
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	7e 33                	jle    80080a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007de:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ec:	c7 04 24 e4 03 80 00 	movl   $0x8003e4,(%esp)
  8007f3:	e8 2e fc ff ff       	call   800426 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800801:	eb 0c                	jmp    80080f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800808:	eb 05                	jmp    80080f <vsnprintf+0x5d>
  80080a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80080f:	c9                   	leave  
  800810:	c3                   	ret    

00800811 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800817:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081e:	8b 45 10             	mov    0x10(%ebp),%eax
  800821:	89 44 24 08          	mov    %eax,0x8(%esp)
  800825:	8b 45 0c             	mov    0xc(%ebp),%eax
  800828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	e8 7b ff ff ff       	call   8007b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800837:	c9                   	leave  
  800838:	c3                   	ret    
  800839:	00 00                	add    %al,(%eax)
	...

0080083c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
  800847:	eb 01                	jmp    80084a <strlen+0xe>
		n++;
  800849:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084e:	75 f9                	jne    800849 <strlen+0xd>
		n++;
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
  800860:	eb 01                	jmp    800863 <strnlen+0x11>
		n++;
  800862:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800863:	39 d0                	cmp    %edx,%eax
  800865:	74 06                	je     80086d <strnlen+0x1b>
  800867:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086b:	75 f5                	jne    800862 <strnlen+0x10>
		n++;
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800879:	ba 00 00 00 00       	mov    $0x0,%edx
  80087e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800881:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800884:	42                   	inc    %edx
  800885:	84 c9                	test   %cl,%cl
  800887:	75 f5                	jne    80087e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800889:	5b                   	pop    %ebx
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	53                   	push   %ebx
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800896:	89 1c 24             	mov    %ebx,(%esp)
  800899:	e8 9e ff ff ff       	call   80083c <strlen>
	strcpy(dst + len, src);
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a5:	01 d8                	add    %ebx,%eax
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	e8 c0 ff ff ff       	call   80086f <strcpy>
	return dst;
}
  8008af:	89 d8                	mov    %ebx,%eax
  8008b1:	83 c4 08             	add    $0x8,%esp
  8008b4:	5b                   	pop    %ebx
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	56                   	push   %esi
  8008bb:	53                   	push   %ebx
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ca:	eb 0c                	jmp    8008d8 <strncpy+0x21>
		*dst++ = *src;
  8008cc:	8a 1a                	mov    (%edx),%bl
  8008ce:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d1:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d7:	41                   	inc    %ecx
  8008d8:	39 f1                	cmp    %esi,%ecx
  8008da:	75 f0                	jne    8008cc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008eb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ee:	85 d2                	test   %edx,%edx
  8008f0:	75 0a                	jne    8008fc <strlcpy+0x1c>
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	eb 1a                	jmp    800910 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f6:	88 18                	mov    %bl,(%eax)
  8008f8:	40                   	inc    %eax
  8008f9:	41                   	inc    %ecx
  8008fa:	eb 02                	jmp    8008fe <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008fc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008fe:	4a                   	dec    %edx
  8008ff:	74 0a                	je     80090b <strlcpy+0x2b>
  800901:	8a 19                	mov    (%ecx),%bl
  800903:	84 db                	test   %bl,%bl
  800905:	75 ef                	jne    8008f6 <strlcpy+0x16>
  800907:	89 c2                	mov    %eax,%edx
  800909:	eb 02                	jmp    80090d <strlcpy+0x2d>
  80090b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80090d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800910:	29 f0                	sub    %esi,%eax
}
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091f:	eb 02                	jmp    800923 <strcmp+0xd>
		p++, q++;
  800921:	41                   	inc    %ecx
  800922:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800923:	8a 01                	mov    (%ecx),%al
  800925:	84 c0                	test   %al,%al
  800927:	74 04                	je     80092d <strcmp+0x17>
  800929:	3a 02                	cmp    (%edx),%al
  80092b:	74 f4                	je     800921 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092d:	0f b6 c0             	movzbl %al,%eax
  800930:	0f b6 12             	movzbl (%edx),%edx
  800933:	29 d0                	sub    %edx,%eax
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800941:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800944:	eb 03                	jmp    800949 <strncmp+0x12>
		n--, p++, q++;
  800946:	4a                   	dec    %edx
  800947:	40                   	inc    %eax
  800948:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800949:	85 d2                	test   %edx,%edx
  80094b:	74 14                	je     800961 <strncmp+0x2a>
  80094d:	8a 18                	mov    (%eax),%bl
  80094f:	84 db                	test   %bl,%bl
  800951:	74 04                	je     800957 <strncmp+0x20>
  800953:	3a 19                	cmp    (%ecx),%bl
  800955:	74 ef                	je     800946 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800957:	0f b6 00             	movzbl (%eax),%eax
  80095a:	0f b6 11             	movzbl (%ecx),%edx
  80095d:	29 d0                	sub    %edx,%eax
  80095f:	eb 05                	jmp    800966 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800966:	5b                   	pop    %ebx
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800972:	eb 05                	jmp    800979 <strchr+0x10>
		if (*s == c)
  800974:	38 ca                	cmp    %cl,%dl
  800976:	74 0c                	je     800984 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800978:	40                   	inc    %eax
  800979:	8a 10                	mov    (%eax),%dl
  80097b:	84 d2                	test   %dl,%dl
  80097d:	75 f5                	jne    800974 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80097f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80098f:	eb 05                	jmp    800996 <strfind+0x10>
		if (*s == c)
  800991:	38 ca                	cmp    %cl,%dl
  800993:	74 07                	je     80099c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800995:	40                   	inc    %eax
  800996:	8a 10                	mov    (%eax),%dl
  800998:	84 d2                	test   %dl,%dl
  80099a:	75 f5                	jne    800991 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ad:	85 c9                	test   %ecx,%ecx
  8009af:	74 30                	je     8009e1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b7:	75 25                	jne    8009de <memset+0x40>
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 20                	jne    8009de <memset+0x40>
		c &= 0xFF;
  8009be:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c1:	89 d3                	mov    %edx,%ebx
  8009c3:	c1 e3 08             	shl    $0x8,%ebx
  8009c6:	89 d6                	mov    %edx,%esi
  8009c8:	c1 e6 18             	shl    $0x18,%esi
  8009cb:	89 d0                	mov    %edx,%eax
  8009cd:	c1 e0 10             	shl    $0x10,%eax
  8009d0:	09 f0                	or     %esi,%eax
  8009d2:	09 d0                	or     %edx,%eax
  8009d4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d9:	fc                   	cld    
  8009da:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dc:	eb 03                	jmp    8009e1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009de:	fc                   	cld    
  8009df:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e1:	89 f8                	mov    %edi,%eax
  8009e3:	5b                   	pop    %ebx
  8009e4:	5e                   	pop    %esi
  8009e5:	5f                   	pop    %edi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f6:	39 c6                	cmp    %eax,%esi
  8009f8:	73 34                	jae    800a2e <memmove+0x46>
  8009fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	73 2d                	jae    800a2e <memmove+0x46>
		s += n;
		d += n;
  800a01:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a04:	f6 c2 03             	test   $0x3,%dl
  800a07:	75 1b                	jne    800a24 <memmove+0x3c>
  800a09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0f:	75 13                	jne    800a24 <memmove+0x3c>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 0e                	jne    800a24 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a16:	83 ef 04             	sub    $0x4,%edi
  800a19:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a1f:	fd                   	std    
  800a20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a22:	eb 07                	jmp    800a2b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a24:	4f                   	dec    %edi
  800a25:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a28:	fd                   	std    
  800a29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2b:	fc                   	cld    
  800a2c:	eb 20                	jmp    800a4e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a34:	75 13                	jne    800a49 <memmove+0x61>
  800a36:	a8 03                	test   $0x3,%al
  800a38:	75 0f                	jne    800a49 <memmove+0x61>
  800a3a:	f6 c1 03             	test   $0x3,%cl
  800a3d:	75 0a                	jne    800a49 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a42:	89 c7                	mov    %eax,%edi
  800a44:	fc                   	cld    
  800a45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a47:	eb 05                	jmp    800a4e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a49:	89 c7                	mov    %eax,%edi
  800a4b:	fc                   	cld    
  800a4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a58:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	89 04 24             	mov    %eax,(%esp)
  800a6c:	e8 77 ff ff ff       	call   8009e8 <memmove>
}
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a82:	ba 00 00 00 00       	mov    $0x0,%edx
  800a87:	eb 16                	jmp    800a9f <memcmp+0x2c>
		if (*s1 != *s2)
  800a89:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a8c:	42                   	inc    %edx
  800a8d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a91:	38 c8                	cmp    %cl,%al
  800a93:	74 0a                	je     800a9f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a95:	0f b6 c0             	movzbl %al,%eax
  800a98:	0f b6 c9             	movzbl %cl,%ecx
  800a9b:	29 c8                	sub    %ecx,%eax
  800a9d:	eb 09                	jmp    800aa8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9f:	39 da                	cmp    %ebx,%edx
  800aa1:	75 e6                	jne    800a89 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab6:	89 c2                	mov    %eax,%edx
  800ab8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800abb:	eb 05                	jmp    800ac2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abd:	38 08                	cmp    %cl,(%eax)
  800abf:	74 05                	je     800ac6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac1:	40                   	inc    %eax
  800ac2:	39 d0                	cmp    %edx,%eax
  800ac4:	72 f7                	jb     800abd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad4:	eb 01                	jmp    800ad7 <strtol+0xf>
		s++;
  800ad6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad7:	8a 02                	mov    (%edx),%al
  800ad9:	3c 20                	cmp    $0x20,%al
  800adb:	74 f9                	je     800ad6 <strtol+0xe>
  800add:	3c 09                	cmp    $0x9,%al
  800adf:	74 f5                	je     800ad6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae1:	3c 2b                	cmp    $0x2b,%al
  800ae3:	75 08                	jne    800aed <strtol+0x25>
		s++;
  800ae5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae6:	bf 00 00 00 00       	mov    $0x0,%edi
  800aeb:	eb 13                	jmp    800b00 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aed:	3c 2d                	cmp    $0x2d,%al
  800aef:	75 0a                	jne    800afb <strtol+0x33>
		s++, neg = 1;
  800af1:	8d 52 01             	lea    0x1(%edx),%edx
  800af4:	bf 01 00 00 00       	mov    $0x1,%edi
  800af9:	eb 05                	jmp    800b00 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b00:	85 db                	test   %ebx,%ebx
  800b02:	74 05                	je     800b09 <strtol+0x41>
  800b04:	83 fb 10             	cmp    $0x10,%ebx
  800b07:	75 28                	jne    800b31 <strtol+0x69>
  800b09:	8a 02                	mov    (%edx),%al
  800b0b:	3c 30                	cmp    $0x30,%al
  800b0d:	75 10                	jne    800b1f <strtol+0x57>
  800b0f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b13:	75 0a                	jne    800b1f <strtol+0x57>
		s += 2, base = 16;
  800b15:	83 c2 02             	add    $0x2,%edx
  800b18:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1d:	eb 12                	jmp    800b31 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b1f:	85 db                	test   %ebx,%ebx
  800b21:	75 0e                	jne    800b31 <strtol+0x69>
  800b23:	3c 30                	cmp    $0x30,%al
  800b25:	75 05                	jne    800b2c <strtol+0x64>
		s++, base = 8;
  800b27:	42                   	inc    %edx
  800b28:	b3 08                	mov    $0x8,%bl
  800b2a:	eb 05                	jmp    800b31 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b38:	8a 0a                	mov    (%edx),%cl
  800b3a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b3d:	80 fb 09             	cmp    $0x9,%bl
  800b40:	77 08                	ja     800b4a <strtol+0x82>
			dig = *s - '0';
  800b42:	0f be c9             	movsbl %cl,%ecx
  800b45:	83 e9 30             	sub    $0x30,%ecx
  800b48:	eb 1e                	jmp    800b68 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b4a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b4d:	80 fb 19             	cmp    $0x19,%bl
  800b50:	77 08                	ja     800b5a <strtol+0x92>
			dig = *s - 'a' + 10;
  800b52:	0f be c9             	movsbl %cl,%ecx
  800b55:	83 e9 57             	sub    $0x57,%ecx
  800b58:	eb 0e                	jmp    800b68 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b5a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b5d:	80 fb 19             	cmp    $0x19,%bl
  800b60:	77 12                	ja     800b74 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b62:	0f be c9             	movsbl %cl,%ecx
  800b65:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b68:	39 f1                	cmp    %esi,%ecx
  800b6a:	7d 0c                	jge    800b78 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b6c:	42                   	inc    %edx
  800b6d:	0f af c6             	imul   %esi,%eax
  800b70:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b72:	eb c4                	jmp    800b38 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b74:	89 c1                	mov    %eax,%ecx
  800b76:	eb 02                	jmp    800b7a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b78:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7e:	74 05                	je     800b85 <strtol+0xbd>
		*endptr = (char *) s;
  800b80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b83:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b85:	85 ff                	test   %edi,%edi
  800b87:	74 04                	je     800b8d <strtol+0xc5>
  800b89:	89 c8                	mov    %ecx,%eax
  800b8b:	f7 d8                	neg    %eax
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    
	...

00800b94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	89 c3                	mov    %eax,%ebx
  800ba7:	89 c7                	mov    %eax,%edi
  800ba9:	89 c6                	mov    %eax,%esi
  800bab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 cb                	mov    %ecx,%ebx
  800be9:	89 cf                	mov    %ecx,%edi
  800beb:	89 ce                	mov    %ecx,%esi
  800bed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7e 28                	jle    800c1b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bfe:	00 
  800bff:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800c06:	00 
  800c07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0e:	00 
  800c0f:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800c16:	e8 b1 f5 ff ff       	call   8001cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1b:	83 c4 2c             	add    $0x2c,%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c33:	89 d1                	mov    %edx,%ecx
  800c35:	89 d3                	mov    %edx,%ebx
  800c37:	89 d7                	mov    %edx,%edi
  800c39:	89 d6                	mov    %edx,%esi
  800c3b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_yield>:

void
sys_yield(void)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c52:	89 d1                	mov    %edx,%ecx
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	89 d7                	mov    %edx,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	be 00 00 00 00       	mov    $0x0,%esi
  800c6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 f7                	mov    %esi,%edi
  800c7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 28                	jle    800cad <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c89:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c90:	00 
  800c91:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800c98:	00 
  800c99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca0:	00 
  800ca1:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800ca8:	e8 1f f5 ff ff       	call   8001cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cad:	83 c4 2c             	add    $0x2c,%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc3:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 28                	jle    800d00 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800ceb:	00 
  800cec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf3:	00 
  800cf4:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800cfb:	e8 cc f4 ff ff       	call   8001cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d00:	83 c4 2c             	add    $0x2c,%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 28                	jle    800d53 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d36:	00 
  800d37:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d46:	00 
  800d47:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800d4e:	e8 79 f4 ff ff       	call   8001cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d53:	83 c4 2c             	add    $0x2c,%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7e 28                	jle    800da6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d82:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d89:	00 
  800d8a:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800d91:	00 
  800d92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d99:	00 
  800d9a:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800da1:	e8 26 f4 ff ff       	call   8001cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da6:	83 c4 2c             	add    $0x2c,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 28                	jle    800df9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800de4:	00 
  800de5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dec:	00 
  800ded:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800df4:	e8 d3 f3 ff ff       	call   8001cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df9:	83 c4 2c             	add    $0x2c,%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 28                	jle    800e4c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e28:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e2f:	00 
  800e30:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800e37:	00 
  800e38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3f:	00 
  800e40:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800e47:	e8 80 f3 ff ff       	call   8001cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4c:	83 c4 2c             	add    $0x2c,%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	be 00 00 00 00       	mov    $0x0,%esi
  800e5f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e70:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	89 cb                	mov    %ecx,%ebx
  800e8f:	89 cf                	mov    %ecx,%edi
  800e91:	89 ce                	mov    %ecx,%esi
  800e93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e95:	85 c0                	test   %eax,%eax
  800e97:	7e 28                	jle    800ec1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800eac:	00 
  800ead:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb4:	00 
  800eb5:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800ebc:	e8 0b f3 ff ff       	call   8001cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec1:	83 c4 2c             	add    $0x2c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ed9:	89 d1                	mov    %edx,%ecx
  800edb:	89 d3                	mov    %edx,%ebx
  800edd:	89 d7                	mov    %edx,%edi
  800edf:	89 d6                	mov    %edx,%esi
  800ee1:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	57                   	push   %edi
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 df                	mov    %ebx,%edi
  800f00:	89 de                	mov    %ebx,%esi
  800f02:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f14:	b8 10 00 00 00       	mov    $0x10,%eax
  800f19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	89 df                	mov    %ebx,%edi
  800f21:	89 de                	mov    %ebx,%esi
  800f23:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
	...

00800f2c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	05 00 00 00 30       	add    $0x30000000,%eax
  800f37:	c1 e8 0c             	shr    $0xc,%eax
}
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
  800f45:	89 04 24             	mov    %eax,(%esp)
  800f48:	e8 df ff ff ff       	call   800f2c <fd2num>
  800f4d:	c1 e0 0c             	shl    $0xc,%eax
  800f50:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	53                   	push   %ebx
  800f5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f5e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f63:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f65:	89 c2                	mov    %eax,%edx
  800f67:	c1 ea 16             	shr    $0x16,%edx
  800f6a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f71:	f6 c2 01             	test   $0x1,%dl
  800f74:	74 11                	je     800f87 <fd_alloc+0x30>
  800f76:	89 c2                	mov    %eax,%edx
  800f78:	c1 ea 0c             	shr    $0xc,%edx
  800f7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f82:	f6 c2 01             	test   $0x1,%dl
  800f85:	75 09                	jne    800f90 <fd_alloc+0x39>
			*fd_store = fd;
  800f87:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8e:	eb 17                	jmp    800fa7 <fd_alloc+0x50>
  800f90:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f95:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f9a:	75 c7                	jne    800f63 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f9c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fa2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fa7:	5b                   	pop    %ebx
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fb0:	83 f8 1f             	cmp    $0x1f,%eax
  800fb3:	77 36                	ja     800feb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb5:	c1 e0 0c             	shl    $0xc,%eax
  800fb8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fbd:	89 c2                	mov    %eax,%edx
  800fbf:	c1 ea 16             	shr    $0x16,%edx
  800fc2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc9:	f6 c2 01             	test   $0x1,%dl
  800fcc:	74 24                	je     800ff2 <fd_lookup+0x48>
  800fce:	89 c2                	mov    %eax,%edx
  800fd0:	c1 ea 0c             	shr    $0xc,%edx
  800fd3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fda:	f6 c2 01             	test   $0x1,%dl
  800fdd:	74 1a                	je     800ff9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fdf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe2:	89 02                	mov    %eax,(%edx)
	return 0;
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe9:	eb 13                	jmp    800ffe <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800feb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff0:	eb 0c                	jmp    800ffe <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ff2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff7:	eb 05                	jmp    800ffe <fd_lookup+0x54>
  800ff9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	53                   	push   %ebx
  801004:	83 ec 14             	sub    $0x14,%esp
  801007:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80100d:	ba 00 00 00 00       	mov    $0x0,%edx
  801012:	eb 0e                	jmp    801022 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801014:	39 08                	cmp    %ecx,(%eax)
  801016:	75 09                	jne    801021 <dev_lookup+0x21>
			*dev = devtab[i];
  801018:	89 03                	mov    %eax,(%ebx)
			return 0;
  80101a:	b8 00 00 00 00       	mov    $0x0,%eax
  80101f:	eb 33                	jmp    801054 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801021:	42                   	inc    %edx
  801022:	8b 04 95 cc 30 80 00 	mov    0x8030cc(,%edx,4),%eax
  801029:	85 c0                	test   %eax,%eax
  80102b:	75 e7                	jne    801014 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80102d:	a1 08 50 80 00       	mov    0x805008,%eax
  801032:	8b 40 48             	mov    0x48(%eax),%eax
  801035:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801039:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103d:	c7 04 24 50 30 80 00 	movl   $0x803050,(%esp)
  801044:	e8 7b f2 ff ff       	call   8002c4 <cprintf>
	*dev = 0;
  801049:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80104f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801054:	83 c4 14             	add    $0x14,%esp
  801057:	5b                   	pop    %ebx
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	56                   	push   %esi
  80105e:	53                   	push   %ebx
  80105f:	83 ec 30             	sub    $0x30,%esp
  801062:	8b 75 08             	mov    0x8(%ebp),%esi
  801065:	8a 45 0c             	mov    0xc(%ebp),%al
  801068:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80106b:	89 34 24             	mov    %esi,(%esp)
  80106e:	e8 b9 fe ff ff       	call   800f2c <fd2num>
  801073:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80107a:	89 04 24             	mov    %eax,(%esp)
  80107d:	e8 28 ff ff ff       	call   800faa <fd_lookup>
  801082:	89 c3                	mov    %eax,%ebx
  801084:	85 c0                	test   %eax,%eax
  801086:	78 05                	js     80108d <fd_close+0x33>
	    || fd != fd2)
  801088:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80108b:	74 0d                	je     80109a <fd_close+0x40>
		return (must_exist ? r : 0);
  80108d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801091:	75 46                	jne    8010d9 <fd_close+0x7f>
  801093:	bb 00 00 00 00       	mov    $0x0,%ebx
  801098:	eb 3f                	jmp    8010d9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80109a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80109d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a1:	8b 06                	mov    (%esi),%eax
  8010a3:	89 04 24             	mov    %eax,(%esp)
  8010a6:	e8 55 ff ff ff       	call   801000 <dev_lookup>
  8010ab:	89 c3                	mov    %eax,%ebx
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	78 18                	js     8010c9 <fd_close+0x6f>
		if (dev->dev_close)
  8010b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b4:	8b 40 10             	mov    0x10(%eax),%eax
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	74 09                	je     8010c4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010bb:	89 34 24             	mov    %esi,(%esp)
  8010be:	ff d0                	call   *%eax
  8010c0:	89 c3                	mov    %eax,%ebx
  8010c2:	eb 05                	jmp    8010c9 <fd_close+0x6f>
		else
			r = 0;
  8010c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d4:	e8 2f fc ff ff       	call   800d08 <sys_page_unmap>
	return r;
}
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	83 c4 30             	add    $0x30,%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f2:	89 04 24             	mov    %eax,(%esp)
  8010f5:	e8 b0 fe ff ff       	call   800faa <fd_lookup>
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	78 13                	js     801111 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801105:	00 
  801106:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801109:	89 04 24             	mov    %eax,(%esp)
  80110c:	e8 49 ff ff ff       	call   80105a <fd_close>
}
  801111:	c9                   	leave  
  801112:	c3                   	ret    

00801113 <close_all>:

void
close_all(void)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	53                   	push   %ebx
  801117:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80111a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80111f:	89 1c 24             	mov    %ebx,(%esp)
  801122:	e8 bb ff ff ff       	call   8010e2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801127:	43                   	inc    %ebx
  801128:	83 fb 20             	cmp    $0x20,%ebx
  80112b:	75 f2                	jne    80111f <close_all+0xc>
		close(i);
}
  80112d:	83 c4 14             	add    $0x14,%esp
  801130:	5b                   	pop    %ebx
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 4c             	sub    $0x4c,%esp
  80113c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80113f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801142:	89 44 24 04          	mov    %eax,0x4(%esp)
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
  801149:	89 04 24             	mov    %eax,(%esp)
  80114c:	e8 59 fe ff ff       	call   800faa <fd_lookup>
  801151:	89 c3                	mov    %eax,%ebx
  801153:	85 c0                	test   %eax,%eax
  801155:	0f 88 e3 00 00 00    	js     80123e <dup+0x10b>
		return r;
	close(newfdnum);
  80115b:	89 3c 24             	mov    %edi,(%esp)
  80115e:	e8 7f ff ff ff       	call   8010e2 <close>

	newfd = INDEX2FD(newfdnum);
  801163:	89 fe                	mov    %edi,%esi
  801165:	c1 e6 0c             	shl    $0xc,%esi
  801168:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80116e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801171:	89 04 24             	mov    %eax,(%esp)
  801174:	e8 c3 fd ff ff       	call   800f3c <fd2data>
  801179:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80117b:	89 34 24             	mov    %esi,(%esp)
  80117e:	e8 b9 fd ff ff       	call   800f3c <fd2data>
  801183:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801186:	89 d8                	mov    %ebx,%eax
  801188:	c1 e8 16             	shr    $0x16,%eax
  80118b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801192:	a8 01                	test   $0x1,%al
  801194:	74 46                	je     8011dc <dup+0xa9>
  801196:	89 d8                	mov    %ebx,%eax
  801198:	c1 e8 0c             	shr    $0xc,%eax
  80119b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011a2:	f6 c2 01             	test   $0x1,%dl
  8011a5:	74 35                	je     8011dc <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011be:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c5:	00 
  8011c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d1:	e8 df fa ff ff       	call   800cb5 <sys_page_map>
  8011d6:	89 c3                	mov    %eax,%ebx
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 3b                	js     801217 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	c1 ea 0c             	shr    $0xc,%edx
  8011e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011eb:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801200:	00 
  801201:	89 44 24 04          	mov    %eax,0x4(%esp)
  801205:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120c:	e8 a4 fa ff ff       	call   800cb5 <sys_page_map>
  801211:	89 c3                	mov    %eax,%ebx
  801213:	85 c0                	test   %eax,%eax
  801215:	79 25                	jns    80123c <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801217:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801222:	e8 e1 fa ff ff       	call   800d08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801227:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80122a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801235:	e8 ce fa ff ff       	call   800d08 <sys_page_unmap>
	return r;
  80123a:	eb 02                	jmp    80123e <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80123c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80123e:	89 d8                	mov    %ebx,%eax
  801240:	83 c4 4c             	add    $0x4c,%esp
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	53                   	push   %ebx
  80124c:	83 ec 24             	sub    $0x24,%esp
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801252:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801255:	89 44 24 04          	mov    %eax,0x4(%esp)
  801259:	89 1c 24             	mov    %ebx,(%esp)
  80125c:	e8 49 fd ff ff       	call   800faa <fd_lookup>
  801261:	85 c0                	test   %eax,%eax
  801263:	78 6d                	js     8012d2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801265:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126f:	8b 00                	mov    (%eax),%eax
  801271:	89 04 24             	mov    %eax,(%esp)
  801274:	e8 87 fd ff ff       	call   801000 <dev_lookup>
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 55                	js     8012d2 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80127d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801280:	8b 50 08             	mov    0x8(%eax),%edx
  801283:	83 e2 03             	and    $0x3,%edx
  801286:	83 fa 01             	cmp    $0x1,%edx
  801289:	75 23                	jne    8012ae <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80128b:	a1 08 50 80 00       	mov    0x805008,%eax
  801290:	8b 40 48             	mov    0x48(%eax),%eax
  801293:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129b:	c7 04 24 91 30 80 00 	movl   $0x803091,(%esp)
  8012a2:	e8 1d f0 ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ac:	eb 24                	jmp    8012d2 <read+0x8a>
	}
	if (!dev->dev_read)
  8012ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b1:	8b 52 08             	mov    0x8(%edx),%edx
  8012b4:	85 d2                	test   %edx,%edx
  8012b6:	74 15                	je     8012cd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012c6:	89 04 24             	mov    %eax,(%esp)
  8012c9:	ff d2                	call   *%edx
  8012cb:	eb 05                	jmp    8012d2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012d2:	83 c4 24             	add    $0x24,%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	57                   	push   %edi
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 1c             	sub    $0x1c,%esp
  8012e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012e4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ec:	eb 23                	jmp    801311 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ee:	89 f0                	mov    %esi,%eax
  8012f0:	29 d8                	sub    %ebx,%eax
  8012f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f9:	01 d8                	add    %ebx,%eax
  8012fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ff:	89 3c 24             	mov    %edi,(%esp)
  801302:	e8 41 ff ff ff       	call   801248 <read>
		if (m < 0)
  801307:	85 c0                	test   %eax,%eax
  801309:	78 10                	js     80131b <readn+0x43>
			return m;
		if (m == 0)
  80130b:	85 c0                	test   %eax,%eax
  80130d:	74 0a                	je     801319 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80130f:	01 c3                	add    %eax,%ebx
  801311:	39 f3                	cmp    %esi,%ebx
  801313:	72 d9                	jb     8012ee <readn+0x16>
  801315:	89 d8                	mov    %ebx,%eax
  801317:	eb 02                	jmp    80131b <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801319:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80131b:	83 c4 1c             	add    $0x1c,%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	53                   	push   %ebx
  801327:	83 ec 24             	sub    $0x24,%esp
  80132a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801330:	89 44 24 04          	mov    %eax,0x4(%esp)
  801334:	89 1c 24             	mov    %ebx,(%esp)
  801337:	e8 6e fc ff ff       	call   800faa <fd_lookup>
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 68                	js     8013a8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801343:	89 44 24 04          	mov    %eax,0x4(%esp)
  801347:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134a:	8b 00                	mov    (%eax),%eax
  80134c:	89 04 24             	mov    %eax,(%esp)
  80134f:	e8 ac fc ff ff       	call   801000 <dev_lookup>
  801354:	85 c0                	test   %eax,%eax
  801356:	78 50                	js     8013a8 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801358:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80135f:	75 23                	jne    801384 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801361:	a1 08 50 80 00       	mov    0x805008,%eax
  801366:	8b 40 48             	mov    0x48(%eax),%eax
  801369:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80136d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801371:	c7 04 24 ad 30 80 00 	movl   $0x8030ad,(%esp)
  801378:	e8 47 ef ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  80137d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801382:	eb 24                	jmp    8013a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801384:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801387:	8b 52 0c             	mov    0xc(%edx),%edx
  80138a:	85 d2                	test   %edx,%edx
  80138c:	74 15                	je     8013a3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80138e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801391:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801395:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801398:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80139c:	89 04 24             	mov    %eax,(%esp)
  80139f:	ff d2                	call   *%edx
  8013a1:	eb 05                	jmp    8013a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013a8:	83 c4 24             	add    $0x24,%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <seek>:

int
seek(int fdnum, off_t offset)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	89 04 24             	mov    %eax,(%esp)
  8013c1:	e8 e4 fb ff ff       	call   800faa <fd_lookup>
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 0e                	js     8013d8 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d8:	c9                   	leave  
  8013d9:	c3                   	ret    

008013da <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 24             	sub    $0x24,%esp
  8013e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013eb:	89 1c 24             	mov    %ebx,(%esp)
  8013ee:	e8 b7 fb ff ff       	call   800faa <fd_lookup>
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 61                	js     801458 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801401:	8b 00                	mov    (%eax),%eax
  801403:	89 04 24             	mov    %eax,(%esp)
  801406:	e8 f5 fb ff ff       	call   801000 <dev_lookup>
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 49                	js     801458 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801412:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801416:	75 23                	jne    80143b <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801418:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80141d:	8b 40 48             	mov    0x48(%eax),%eax
  801420:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801424:	89 44 24 04          	mov    %eax,0x4(%esp)
  801428:	c7 04 24 70 30 80 00 	movl   $0x803070,(%esp)
  80142f:	e8 90 ee ff ff       	call   8002c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801439:	eb 1d                	jmp    801458 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80143b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80143e:	8b 52 18             	mov    0x18(%edx),%edx
  801441:	85 d2                	test   %edx,%edx
  801443:	74 0e                	je     801453 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801445:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801448:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80144c:	89 04 24             	mov    %eax,(%esp)
  80144f:	ff d2                	call   *%edx
  801451:	eb 05                	jmp    801458 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801453:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801458:	83 c4 24             	add    $0x24,%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	53                   	push   %ebx
  801462:	83 ec 24             	sub    $0x24,%esp
  801465:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801468:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	89 04 24             	mov    %eax,(%esp)
  801475:	e8 30 fb ff ff       	call   800faa <fd_lookup>
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 52                	js     8014d0 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801481:	89 44 24 04          	mov    %eax,0x4(%esp)
  801485:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801488:	8b 00                	mov    (%eax),%eax
  80148a:	89 04 24             	mov    %eax,(%esp)
  80148d:	e8 6e fb ff ff       	call   801000 <dev_lookup>
  801492:	85 c0                	test   %eax,%eax
  801494:	78 3a                	js     8014d0 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801496:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801499:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80149d:	74 2c                	je     8014cb <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80149f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014a2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014a9:	00 00 00 
	stat->st_isdir = 0;
  8014ac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014b3:	00 00 00 
	stat->st_dev = dev;
  8014b6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c3:	89 14 24             	mov    %edx,(%esp)
  8014c6:	ff 50 14             	call   *0x14(%eax)
  8014c9:	eb 05                	jmp    8014d0 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014d0:	83 c4 24             	add    $0x24,%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	56                   	push   %esi
  8014da:	53                   	push   %ebx
  8014db:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014e5:	00 
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	89 04 24             	mov    %eax,(%esp)
  8014ec:	e8 2a 02 00 00       	call   80171b <open>
  8014f1:	89 c3                	mov    %eax,%ebx
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 1b                	js     801512 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fe:	89 1c 24             	mov    %ebx,(%esp)
  801501:	e8 58 ff ff ff       	call   80145e <fstat>
  801506:	89 c6                	mov    %eax,%esi
	close(fd);
  801508:	89 1c 24             	mov    %ebx,(%esp)
  80150b:	e8 d2 fb ff ff       	call   8010e2 <close>
	return r;
  801510:	89 f3                	mov    %esi,%ebx
}
  801512:	89 d8                	mov    %ebx,%eax
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	5b                   	pop    %ebx
  801518:	5e                   	pop    %esi
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    
	...

0080151c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
  801521:	83 ec 10             	sub    $0x10,%esp
  801524:	89 c3                	mov    %eax,%ebx
  801526:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801528:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80152f:	75 11                	jne    801542 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801531:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801538:	e8 f6 13 00 00       	call   802933 <ipc_find_env>
  80153d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801542:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801549:	00 
  80154a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801551:	00 
  801552:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801556:	a1 00 50 80 00       	mov    0x805000,%eax
  80155b:	89 04 24             	mov    %eax,(%esp)
  80155e:	e8 4d 13 00 00       	call   8028b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801563:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80156a:	00 
  80156b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801576:	e8 c5 12 00 00       	call   802840 <ipc_recv>
}
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5e                   	pop    %esi
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801588:	8b 45 08             	mov    0x8(%ebp),%eax
  80158b:	8b 40 0c             	mov    0xc(%eax),%eax
  80158e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801593:	8b 45 0c             	mov    0xc(%ebp),%eax
  801596:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80159b:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8015a5:	e8 72 ff ff ff       	call   80151c <fsipc>
}
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b8:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8015bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8015c7:	e8 50 ff ff ff       	call   80151c <fsipc>
}
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 14             	sub    $0x14,%esp
  8015d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015db:	8b 40 0c             	mov    0xc(%eax),%eax
  8015de:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ed:	e8 2a ff ff ff       	call   80151c <fsipc>
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 2b                	js     801621 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015f6:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8015fd:	00 
  8015fe:	89 1c 24             	mov    %ebx,(%esp)
  801601:	e8 69 f2 ff ff       	call   80086f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801606:	a1 80 60 80 00       	mov    0x806080,%eax
  80160b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801611:	a1 84 60 80 00       	mov    0x806084,%eax
  801616:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80161c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801621:	83 c4 14             	add    $0x14,%esp
  801624:	5b                   	pop    %ebx
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 18             	sub    $0x18,%esp
  80162d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801630:	8b 55 08             	mov    0x8(%ebp),%edx
  801633:	8b 52 0c             	mov    0xc(%edx),%edx
  801636:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  80163c:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801641:	89 c2                	mov    %eax,%edx
  801643:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801648:	76 05                	jbe    80164f <devfile_write+0x28>
  80164a:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  80164f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801653:	8b 45 0c             	mov    0xc(%ebp),%eax
  801656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165a:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801661:	e8 ec f3 ff ff       	call   800a52 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801666:	ba 00 00 00 00       	mov    $0x0,%edx
  80166b:	b8 04 00 00 00       	mov    $0x4,%eax
  801670:	e8 a7 fe ff ff       	call   80151c <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	56                   	push   %esi
  80167b:	53                   	push   %ebx
  80167c:	83 ec 10             	sub    $0x10,%esp
  80167f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801682:	8b 45 08             	mov    0x8(%ebp),%eax
  801685:	8b 40 0c             	mov    0xc(%eax),%eax
  801688:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80168d:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801693:	ba 00 00 00 00       	mov    $0x0,%edx
  801698:	b8 03 00 00 00       	mov    $0x3,%eax
  80169d:	e8 7a fe ff ff       	call   80151c <fsipc>
  8016a2:	89 c3                	mov    %eax,%ebx
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 6a                	js     801712 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016a8:	39 c6                	cmp    %eax,%esi
  8016aa:	73 24                	jae    8016d0 <devfile_read+0x59>
  8016ac:	c7 44 24 0c e0 30 80 	movl   $0x8030e0,0xc(%esp)
  8016b3:	00 
  8016b4:	c7 44 24 08 e7 30 80 	movl   $0x8030e7,0x8(%esp)
  8016bb:	00 
  8016bc:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016c3:	00 
  8016c4:	c7 04 24 fc 30 80 00 	movl   $0x8030fc,(%esp)
  8016cb:	e8 fc ea ff ff       	call   8001cc <_panic>
	assert(r <= PGSIZE);
  8016d0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016d5:	7e 24                	jle    8016fb <devfile_read+0x84>
  8016d7:	c7 44 24 0c 07 31 80 	movl   $0x803107,0xc(%esp)
  8016de:	00 
  8016df:	c7 44 24 08 e7 30 80 	movl   $0x8030e7,0x8(%esp)
  8016e6:	00 
  8016e7:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016ee:	00 
  8016ef:	c7 04 24 fc 30 80 00 	movl   $0x8030fc,(%esp)
  8016f6:	e8 d1 ea ff ff       	call   8001cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ff:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801706:	00 
  801707:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170a:	89 04 24             	mov    %eax,(%esp)
  80170d:	e8 d6 f2 ff ff       	call   8009e8 <memmove>
	return r;
}
  801712:	89 d8                	mov    %ebx,%eax
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	5b                   	pop    %ebx
  801718:	5e                   	pop    %esi
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	56                   	push   %esi
  80171f:	53                   	push   %ebx
  801720:	83 ec 20             	sub    $0x20,%esp
  801723:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801726:	89 34 24             	mov    %esi,(%esp)
  801729:	e8 0e f1 ff ff       	call   80083c <strlen>
  80172e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801733:	7f 60                	jg     801795 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801738:	89 04 24             	mov    %eax,(%esp)
  80173b:	e8 17 f8 ff ff       	call   800f57 <fd_alloc>
  801740:	89 c3                	mov    %eax,%ebx
  801742:	85 c0                	test   %eax,%eax
  801744:	78 54                	js     80179a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801746:	89 74 24 04          	mov    %esi,0x4(%esp)
  80174a:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801751:	e8 19 f1 ff ff       	call   80086f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801756:	8b 45 0c             	mov    0xc(%ebp),%eax
  801759:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80175e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801761:	b8 01 00 00 00       	mov    $0x1,%eax
  801766:	e8 b1 fd ff ff       	call   80151c <fsipc>
  80176b:	89 c3                	mov    %eax,%ebx
  80176d:	85 c0                	test   %eax,%eax
  80176f:	79 15                	jns    801786 <open+0x6b>
		fd_close(fd, 0);
  801771:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801778:	00 
  801779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177c:	89 04 24             	mov    %eax,(%esp)
  80177f:	e8 d6 f8 ff ff       	call   80105a <fd_close>
		return r;
  801784:	eb 14                	jmp    80179a <open+0x7f>
	}

	return fd2num(fd);
  801786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801789:	89 04 24             	mov    %eax,(%esp)
  80178c:	e8 9b f7 ff ff       	call   800f2c <fd2num>
  801791:	89 c3                	mov    %eax,%ebx
  801793:	eb 05                	jmp    80179a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801795:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80179a:	89 d8                	mov    %ebx,%eax
  80179c:	83 c4 20             	add    $0x20,%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8017b3:	e8 64 fd ff ff       	call   80151c <fsipc>
}
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    
	...

008017bc <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	57                   	push   %edi
  8017c0:	56                   	push   %esi
  8017c1:	53                   	push   %ebx
  8017c2:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8017c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017cf:	00 
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	89 04 24             	mov    %eax,(%esp)
  8017d6:	e8 40 ff ff ff       	call   80171b <open>
  8017db:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	0f 88 a9 05 00 00    	js     801d92 <spawn+0x5d6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8017e9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8017f0:	00 
  8017f1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8017f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fb:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801801:	89 04 24             	mov    %eax,(%esp)
  801804:	e8 cf fa ff ff       	call   8012d8 <readn>
  801809:	3d 00 02 00 00       	cmp    $0x200,%eax
  80180e:	75 0c                	jne    80181c <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801810:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801817:	45 4c 46 
  80181a:	74 3b                	je     801857 <spawn+0x9b>
		close(fd);
  80181c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801822:	89 04 24             	mov    %eax,(%esp)
  801825:	e8 b8 f8 ff ff       	call   8010e2 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80182a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801831:	46 
  801832:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183c:	c7 04 24 13 31 80 00 	movl   $0x803113,(%esp)
  801843:	e8 7c ea ff ff       	call   8002c4 <cprintf>
		return -E_NOT_EXEC;
  801848:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  80184f:	ff ff ff 
  801852:	e9 47 05 00 00       	jmp    801d9e <spawn+0x5e2>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801857:	ba 07 00 00 00       	mov    $0x7,%edx
  80185c:	89 d0                	mov    %edx,%eax
  80185e:	cd 30                	int    $0x30
  801860:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801866:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80186c:	85 c0                	test   %eax,%eax
  80186e:	0f 88 2a 05 00 00    	js     801d9e <spawn+0x5e2>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801874:	25 ff 03 00 00       	and    $0x3ff,%eax
  801879:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801880:	c1 e0 07             	shl    $0x7,%eax
  801883:	29 d0                	sub    %edx,%eax
  801885:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  80188b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801891:	b9 11 00 00 00       	mov    $0x11,%ecx
  801896:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801898:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80189e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018a4:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8018a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018b1:	eb 0d                	jmp    8018c0 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8018b3:	89 04 24             	mov    %eax,(%esp)
  8018b6:	e8 81 ef ff ff       	call   80083c <strlen>
  8018bb:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018bf:	46                   	inc    %esi
  8018c0:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8018c2:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018c9:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	75 e3                	jne    8018b3 <spawn+0xf7>
  8018d0:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  8018d6:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8018dc:	bf 00 10 40 00       	mov    $0x401000,%edi
  8018e1:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8018e3:	89 f8                	mov    %edi,%eax
  8018e5:	83 e0 fc             	and    $0xfffffffc,%eax
  8018e8:	f7 d2                	not    %edx
  8018ea:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8018ed:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8018f3:	89 d0                	mov    %edx,%eax
  8018f5:	83 e8 08             	sub    $0x8,%eax
  8018f8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8018fd:	0f 86 ac 04 00 00    	jbe    801daf <spawn+0x5f3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801903:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80190a:	00 
  80190b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801912:	00 
  801913:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191a:	e8 42 f3 ff ff       	call   800c61 <sys_page_alloc>
  80191f:	85 c0                	test   %eax,%eax
  801921:	0f 88 8d 04 00 00    	js     801db4 <spawn+0x5f8>
  801927:	bb 00 00 00 00       	mov    $0x0,%ebx
  80192c:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801932:	8b 75 0c             	mov    0xc(%ebp),%esi
  801935:	eb 2e                	jmp    801965 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801937:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80193d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801943:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801946:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194d:	89 3c 24             	mov    %edi,(%esp)
  801950:	e8 1a ef ff ff       	call   80086f <strcpy>
		string_store += strlen(argv[i]) + 1;
  801955:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801958:	89 04 24             	mov    %eax,(%esp)
  80195b:	e8 dc ee ff ff       	call   80083c <strlen>
  801960:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801964:	43                   	inc    %ebx
  801965:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80196b:	7c ca                	jl     801937 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80196d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801973:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801979:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801980:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801986:	74 24                	je     8019ac <spawn+0x1f0>
  801988:	c7 44 24 0c 9c 31 80 	movl   $0x80319c,0xc(%esp)
  80198f:	00 
  801990:	c7 44 24 08 e7 30 80 	movl   $0x8030e7,0x8(%esp)
  801997:	00 
  801998:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  80199f:	00 
  8019a0:	c7 04 24 2d 31 80 00 	movl   $0x80312d,(%esp)
  8019a7:	e8 20 e8 ff ff       	call   8001cc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8019ac:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8019b2:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8019b7:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8019bd:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8019c0:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019c6:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8019c9:	89 d0                	mov    %edx,%eax
  8019cb:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8019d0:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8019d6:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019dd:	00 
  8019de:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8019e5:	ee 
  8019e6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8019ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019f7:	00 
  8019f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ff:	e8 b1 f2 ff ff       	call   800cb5 <sys_page_map>
  801a04:	89 c3                	mov    %eax,%ebx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 1a                	js     801a24 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a0a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a11:	00 
  801a12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a19:	e8 ea f2 ff ff       	call   800d08 <sys_page_unmap>
  801a1e:	89 c3                	mov    %eax,%ebx
  801a20:	85 c0                	test   %eax,%eax
  801a22:	79 1f                	jns    801a43 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a24:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a2b:	00 
  801a2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a33:	e8 d0 f2 ff ff       	call   800d08 <sys_page_unmap>
	return r;
  801a38:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a3e:	e9 5b 03 00 00       	jmp    801d9e <spawn+0x5e2>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801a43:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801a49:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801a4f:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a55:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801a5c:	00 00 00 
  801a5f:	e9 bb 01 00 00       	jmp    801c1f <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801a64:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a6a:	83 38 01             	cmpl   $0x1,(%eax)
  801a6d:	0f 85 9f 01 00 00    	jne    801c12 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a73:	89 c2                	mov    %eax,%edx
  801a75:	8b 40 18             	mov    0x18(%eax),%eax
  801a78:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801a7b:	83 f8 01             	cmp    $0x1,%eax
  801a7e:	19 c0                	sbb    %eax,%eax
  801a80:	83 e0 fe             	and    $0xfffffffe,%eax
  801a83:	83 c0 07             	add    $0x7,%eax
  801a86:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a8c:	8b 52 04             	mov    0x4(%edx),%edx
  801a8f:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801a95:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a9b:	8b 40 10             	mov    0x10(%eax),%eax
  801a9e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801aa4:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801aaa:	8b 52 14             	mov    0x14(%edx),%edx
  801aad:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801ab3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ab9:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801abc:	89 f8                	mov    %edi,%eax
  801abe:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ac3:	74 16                	je     801adb <spawn+0x31f>
		va -= i;
  801ac5:	29 c7                	sub    %eax,%edi
		memsz += i;
  801ac7:	01 c2                	add    %eax,%edx
  801ac9:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801acf:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801ad5:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801adb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae0:	e9 1f 01 00 00       	jmp    801c04 <spawn+0x448>
		if (i >= filesz) {
  801ae5:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  801aeb:	72 2b                	jb     801b18 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801aed:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801af3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801af7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801afb:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b01:	89 04 24             	mov    %eax,(%esp)
  801b04:	e8 58 f1 ff ff       	call   800c61 <sys_page_alloc>
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	0f 89 e7 00 00 00    	jns    801bf8 <spawn+0x43c>
  801b11:	89 c6                	mov    %eax,%esi
  801b13:	e9 56 02 00 00       	jmp    801d6e <spawn+0x5b2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b18:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b1f:	00 
  801b20:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b27:	00 
  801b28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2f:	e8 2d f1 ff ff       	call   800c61 <sys_page_alloc>
  801b34:	85 c0                	test   %eax,%eax
  801b36:	0f 88 28 02 00 00    	js     801d64 <spawn+0x5a8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b3c:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801b42:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b48:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b4e:	89 04 24             	mov    %eax,(%esp)
  801b51:	e8 58 f8 ff ff       	call   8013ae <seek>
  801b56:	85 c0                	test   %eax,%eax
  801b58:	0f 88 0a 02 00 00    	js     801d68 <spawn+0x5ac>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b5e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b64:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b66:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b6b:	76 05                	jbe    801b72 <spawn+0x3b6>
  801b6d:	b8 00 10 00 00       	mov    $0x1000,%eax
  801b72:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b76:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b7d:	00 
  801b7e:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b84:	89 04 24             	mov    %eax,(%esp)
  801b87:	e8 4c f7 ff ff       	call   8012d8 <readn>
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	0f 88 d8 01 00 00    	js     801d6c <spawn+0x5b0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b94:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801b9a:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b9e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ba2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ba8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bac:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bb3:	00 
  801bb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbb:	e8 f5 f0 ff ff       	call   800cb5 <sys_page_map>
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	79 20                	jns    801be4 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801bc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bc8:	c7 44 24 08 39 31 80 	movl   $0x803139,0x8(%esp)
  801bcf:	00 
  801bd0:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801bd7:	00 
  801bd8:	c7 04 24 2d 31 80 00 	movl   $0x80312d,(%esp)
  801bdf:	e8 e8 e5 ff ff       	call   8001cc <_panic>
			sys_page_unmap(0, UTEMP);
  801be4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801beb:	00 
  801bec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf3:	e8 10 f1 ff ff       	call   800d08 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bf8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801bfe:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801c04:	89 de                	mov    %ebx,%esi
  801c06:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801c0c:	0f 82 d3 fe ff ff    	jb     801ae5 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c12:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801c18:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801c1f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c26:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801c2c:	0f 8c 32 fe ff ff    	jl     801a64 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c32:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801c38:	89 04 24             	mov    %eax,(%esp)
  801c3b:	e8 a2 f4 ff ff       	call   8010e2 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  801c40:	be 00 00 00 00       	mov    $0x0,%esi
  801c45:	eb 0c                	jmp    801c53 <spawn+0x497>
	{
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  801c47:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801c4d:	0f 84 91 00 00 00    	je     801ce4 <spawn+0x528>
  801c53:	89 f0                	mov    %esi,%eax
  801c55:	c1 e8 16             	shr    $0x16,%eax
  801c58:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c5f:	a8 01                	test   $0x1,%al
  801c61:	74 6f                	je     801cd2 <spawn+0x516>
  801c63:	89 f0                	mov    %esi,%eax
  801c65:	c1 e8 0c             	shr    $0xc,%eax
  801c68:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c6f:	f6 c2 01             	test   $0x1,%dl
  801c72:	74 5e                	je     801cd2 <spawn+0x516>
		{
			continue;
		}
		if ((uvpt[PGNUM(addr)] & PTE_SHARE))
  801c74:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c7b:	f6 c6 04             	test   $0x4,%dh
  801c7e:	74 52                	je     801cd2 <spawn+0x516>
		{
			if ((e = sys_page_map(0, (void *)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  801c80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c87:	25 07 0e 00 00       	and    $0xe07,%eax
  801c8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c90:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c94:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca9:	e8 07 f0 ff ff       	call   800cb5 <sys_page_map>
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	79 20                	jns    801cd2 <spawn+0x516>
			{
				panic("duppage error: %e", e);
  801cb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cb6:	c7 44 24 08 56 31 80 	movl   $0x803156,0x8(%esp)
  801cbd:	00 
  801cbe:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  801cc5:	00 
  801cc6:	c7 04 24 2d 31 80 00 	movl   $0x80312d,(%esp)
  801ccd:	e8 fa e4 ff ff       	call   8001cc <_panic>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  801cd2:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cd8:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  801cde:	0f 85 63 ff ff ff    	jne    801c47 <spawn+0x48b>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ce4:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ceb:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801cee:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cfe:	89 04 24             	mov    %eax,(%esp)
  801d01:	e8 a8 f0 ff ff       	call   800dae <sys_env_set_trapframe>
  801d06:	85 c0                	test   %eax,%eax
  801d08:	79 20                	jns    801d2a <spawn+0x56e>
		panic("sys_env_set_trapframe: %e", r);
  801d0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0e:	c7 44 24 08 68 31 80 	movl   $0x803168,0x8(%esp)
  801d15:	00 
  801d16:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801d1d:	00 
  801d1e:	c7 04 24 2d 31 80 00 	movl   $0x80312d,(%esp)
  801d25:	e8 a2 e4 ff ff       	call   8001cc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d2a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801d31:	00 
  801d32:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d38:	89 04 24             	mov    %eax,(%esp)
  801d3b:	e8 1b f0 ff ff       	call   800d5b <sys_env_set_status>
  801d40:	85 c0                	test   %eax,%eax
  801d42:	79 5a                	jns    801d9e <spawn+0x5e2>
		panic("sys_env_set_status: %e", r);
  801d44:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d48:	c7 44 24 08 82 31 80 	movl   $0x803182,0x8(%esp)
  801d4f:	00 
  801d50:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801d57:	00 
  801d58:	c7 04 24 2d 31 80 00 	movl   $0x80312d,(%esp)
  801d5f:	e8 68 e4 ff ff       	call   8001cc <_panic>
  801d64:	89 c6                	mov    %eax,%esi
  801d66:	eb 06                	jmp    801d6e <spawn+0x5b2>
  801d68:	89 c6                	mov    %eax,%esi
  801d6a:	eb 02                	jmp    801d6e <spawn+0x5b2>
  801d6c:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801d6e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d74:	89 04 24             	mov    %eax,(%esp)
  801d77:	e8 55 ee ff ff       	call   800bd1 <sys_env_destroy>
	close(fd);
  801d7c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d82:	89 04 24             	mov    %eax,(%esp)
  801d85:	e8 58 f3 ff ff       	call   8010e2 <close>
	return r;
  801d8a:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  801d90:	eb 0c                	jmp    801d9e <spawn+0x5e2>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d92:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d98:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d9e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801da4:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801daa:	5b                   	pop    %ebx
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801daf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801db4:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801dba:	eb e2                	jmp    801d9e <spawn+0x5e2>

00801dbc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	57                   	push   %edi
  801dc0:	56                   	push   %esi
  801dc1:	53                   	push   %ebx
  801dc2:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801dc5:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801dc8:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dcd:	eb 03                	jmp    801dd2 <spawnl+0x16>
		argc++;
  801dcf:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dd0:	89 d0                	mov    %edx,%eax
  801dd2:	8d 50 04             	lea    0x4(%eax),%edx
  801dd5:	83 38 00             	cmpl   $0x0,(%eax)
  801dd8:	75 f5                	jne    801dcf <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801dda:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801de1:	83 e0 f0             	and    $0xfffffff0,%eax
  801de4:	29 c4                	sub    %eax,%esp
  801de6:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801dea:	83 e7 f0             	and    $0xfffffff0,%edi
  801ded:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801def:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df2:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801df4:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801dfb:	00 

	va_start(vl, arg0);
  801dfc:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801dff:	b8 00 00 00 00       	mov    $0x0,%eax
  801e04:	eb 09                	jmp    801e0f <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801e06:	40                   	inc    %eax
  801e07:	8b 1a                	mov    (%edx),%ebx
  801e09:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801e0c:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e0f:	39 c8                	cmp    %ecx,%eax
  801e11:	75 f3                	jne    801e06 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e13:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e17:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1a:	89 04 24             	mov    %eax,(%esp)
  801e1d:	e8 9a f9 ff ff       	call   8017bc <spawn>
}
  801e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e25:	5b                   	pop    %ebx
  801e26:	5e                   	pop    %esi
  801e27:	5f                   	pop    %edi
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    
	...

00801e2c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801e32:	c7 44 24 04 c4 31 80 	movl   $0x8031c4,0x4(%esp)
  801e39:	00 
  801e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3d:	89 04 24             	mov    %eax,(%esp)
  801e40:	e8 2a ea ff ff       	call   80086f <strcpy>
	return 0;
}
  801e45:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	53                   	push   %ebx
  801e50:	83 ec 14             	sub    $0x14,%esp
  801e53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e56:	89 1c 24             	mov    %ebx,(%esp)
  801e59:	e8 1a 0b 00 00       	call   802978 <pageref>
  801e5e:	83 f8 01             	cmp    $0x1,%eax
  801e61:	75 0d                	jne    801e70 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801e63:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e66:	89 04 24             	mov    %eax,(%esp)
  801e69:	e8 1f 03 00 00       	call   80218d <nsipc_close>
  801e6e:	eb 05                	jmp    801e75 <devsock_close+0x29>
	else
		return 0;
  801e70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e75:	83 c4 14             	add    $0x14,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5d                   	pop    %ebp
  801e7a:	c3                   	ret    

00801e7b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e81:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e88:	00 
  801e89:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e9d:	89 04 24             	mov    %eax,(%esp)
  801ea0:	e8 e3 03 00 00       	call   802288 <nsipc_send>
}
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ead:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801eb4:	00 
  801eb5:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ec9:	89 04 24             	mov    %eax,(%esp)
  801ecc:	e8 37 03 00 00       	call   802208 <nsipc_recv>
}
  801ed1:	c9                   	leave  
  801ed2:	c3                   	ret    

00801ed3 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	83 ec 20             	sub    $0x20,%esp
  801edb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801edd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee0:	89 04 24             	mov    %eax,(%esp)
  801ee3:	e8 6f f0 ff ff       	call   800f57 <fd_alloc>
  801ee8:	89 c3                	mov    %eax,%ebx
  801eea:	85 c0                	test   %eax,%eax
  801eec:	78 21                	js     801f0f <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801eee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ef5:	00 
  801ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f04:	e8 58 ed ff ff       	call   800c61 <sys_page_alloc>
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	79 0a                	jns    801f19 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801f0f:	89 34 24             	mov    %esi,(%esp)
  801f12:	e8 76 02 00 00       	call   80218d <nsipc_close>
		return r;
  801f17:	eb 22                	jmp    801f3b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f19:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f22:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f27:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f2e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f31:	89 04 24             	mov    %eax,(%esp)
  801f34:	e8 f3 ef ff ff       	call   800f2c <fd2num>
  801f39:	89 c3                	mov    %eax,%ebx
}
  801f3b:	89 d8                	mov    %ebx,%eax
  801f3d:	83 c4 20             	add    $0x20,%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f4a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f51:	89 04 24             	mov    %eax,(%esp)
  801f54:	e8 51 f0 ff ff       	call   800faa <fd_lookup>
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 17                	js     801f74 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f60:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801f66:	39 10                	cmp    %edx,(%eax)
  801f68:	75 05                	jne    801f6f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801f6d:	eb 05                	jmp    801f74 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f6f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f74:	c9                   	leave  
  801f75:	c3                   	ret    

00801f76 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7f:	e8 c0 ff ff ff       	call   801f44 <fd2sockid>
  801f84:	85 c0                	test   %eax,%eax
  801f86:	78 1f                	js     801fa7 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f88:	8b 55 10             	mov    0x10(%ebp),%edx
  801f8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f92:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f96:	89 04 24             	mov    %eax,(%esp)
  801f99:	e8 38 01 00 00       	call   8020d6 <nsipc_accept>
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	78 05                	js     801fa7 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801fa2:	e8 2c ff ff ff       	call   801ed3 <alloc_sockfd>
}
  801fa7:	c9                   	leave  
  801fa8:	c3                   	ret    

00801fa9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801faf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb2:	e8 8d ff ff ff       	call   801f44 <fd2sockid>
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	78 16                	js     801fd1 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801fbb:	8b 55 10             	mov    0x10(%ebp),%edx
  801fbe:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fc5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fc9:	89 04 24             	mov    %eax,(%esp)
  801fcc:	e8 5b 01 00 00       	call   80212c <nsipc_bind>
}
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    

00801fd3 <shutdown>:

int
shutdown(int s, int how)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdc:	e8 63 ff ff ff       	call   801f44 <fd2sockid>
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	78 0f                	js     801ff4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801fe5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fec:	89 04 24             	mov    %eax,(%esp)
  801fef:	e8 77 01 00 00       	call   80216b <nsipc_shutdown>
}
  801ff4:	c9                   	leave  
  801ff5:	c3                   	ret    

00801ff6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fff:	e8 40 ff ff ff       	call   801f44 <fd2sockid>
  802004:	85 c0                	test   %eax,%eax
  802006:	78 16                	js     80201e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802008:	8b 55 10             	mov    0x10(%ebp),%edx
  80200b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80200f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802012:	89 54 24 04          	mov    %edx,0x4(%esp)
  802016:	89 04 24             	mov    %eax,(%esp)
  802019:	e8 89 01 00 00       	call   8021a7 <nsipc_connect>
}
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <listen>:

int
listen(int s, int backlog)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802026:	8b 45 08             	mov    0x8(%ebp),%eax
  802029:	e8 16 ff ff ff       	call   801f44 <fd2sockid>
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 0f                	js     802041 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802032:	8b 55 0c             	mov    0xc(%ebp),%edx
  802035:	89 54 24 04          	mov    %edx,0x4(%esp)
  802039:	89 04 24             	mov    %eax,(%esp)
  80203c:	e8 a5 01 00 00       	call   8021e6 <nsipc_listen>
}
  802041:	c9                   	leave  
  802042:	c3                   	ret    

00802043 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802043:	55                   	push   %ebp
  802044:	89 e5                	mov    %esp,%ebp
  802046:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802049:	8b 45 10             	mov    0x10(%ebp),%eax
  80204c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802050:	8b 45 0c             	mov    0xc(%ebp),%eax
  802053:	89 44 24 04          	mov    %eax,0x4(%esp)
  802057:	8b 45 08             	mov    0x8(%ebp),%eax
  80205a:	89 04 24             	mov    %eax,(%esp)
  80205d:	e8 99 02 00 00       	call   8022fb <nsipc_socket>
  802062:	85 c0                	test   %eax,%eax
  802064:	78 05                	js     80206b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802066:	e8 68 fe ff ff       	call   801ed3 <alloc_sockfd>
}
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    
  80206d:	00 00                	add    %al,(%eax)
	...

00802070 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	53                   	push   %ebx
  802074:	83 ec 14             	sub    $0x14,%esp
  802077:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802079:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802080:	75 11                	jne    802093 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802082:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802089:	e8 a5 08 00 00       	call   802933 <ipc_find_env>
  80208e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802093:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80209a:	00 
  80209b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8020a2:	00 
  8020a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020a7:	a1 04 50 80 00       	mov    0x805004,%eax
  8020ac:	89 04 24             	mov    %eax,(%esp)
  8020af:	e8 fc 07 00 00       	call   8028b0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020bb:	00 
  8020bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020c3:	00 
  8020c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020cb:	e8 70 07 00 00       	call   802840 <ipc_recv>
}
  8020d0:	83 c4 14             	add    $0x14,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5d                   	pop    %ebp
  8020d5:	c3                   	ret    

008020d6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	56                   	push   %esi
  8020da:	53                   	push   %ebx
  8020db:	83 ec 10             	sub    $0x10,%esp
  8020de:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020e9:	8b 06                	mov    (%esi),%eax
  8020eb:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8020f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f5:	e8 76 ff ff ff       	call   802070 <nsipc>
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	78 23                	js     802123 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802100:	a1 10 70 80 00       	mov    0x807010,%eax
  802105:	89 44 24 08          	mov    %eax,0x8(%esp)
  802109:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802110:	00 
  802111:	8b 45 0c             	mov    0xc(%ebp),%eax
  802114:	89 04 24             	mov    %eax,(%esp)
  802117:	e8 cc e8 ff ff       	call   8009e8 <memmove>
		*addrlen = ret->ret_addrlen;
  80211c:	a1 10 70 80 00       	mov    0x807010,%eax
  802121:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802123:	89 d8                	mov    %ebx,%eax
  802125:	83 c4 10             	add    $0x10,%esp
  802128:	5b                   	pop    %ebx
  802129:	5e                   	pop    %esi
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    

0080212c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	53                   	push   %ebx
  802130:	83 ec 14             	sub    $0x14,%esp
  802133:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802136:	8b 45 08             	mov    0x8(%ebp),%eax
  802139:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80213e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802142:	8b 45 0c             	mov    0xc(%ebp),%eax
  802145:	89 44 24 04          	mov    %eax,0x4(%esp)
  802149:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802150:	e8 93 e8 ff ff       	call   8009e8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802155:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80215b:	b8 02 00 00 00       	mov    $0x2,%eax
  802160:	e8 0b ff ff ff       	call   802070 <nsipc>
}
  802165:	83 c4 14             	add    $0x14,%esp
  802168:	5b                   	pop    %ebx
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    

0080216b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802171:	8b 45 08             	mov    0x8(%ebp),%eax
  802174:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802181:	b8 03 00 00 00       	mov    $0x3,%eax
  802186:	e8 e5 fe ff ff       	call   802070 <nsipc>
}
  80218b:	c9                   	leave  
  80218c:	c3                   	ret    

0080218d <nsipc_close>:

int
nsipc_close(int s)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
  802190:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802193:	8b 45 08             	mov    0x8(%ebp),%eax
  802196:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80219b:	b8 04 00 00 00       	mov    $0x4,%eax
  8021a0:	e8 cb fe ff ff       	call   802070 <nsipc>
}
  8021a5:	c9                   	leave  
  8021a6:	c3                   	ret    

008021a7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	53                   	push   %ebx
  8021ab:	83 ec 14             	sub    $0x14,%esp
  8021ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8021b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b4:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8021b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c4:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8021cb:	e8 18 e8 ff ff       	call   8009e8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8021d0:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8021d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8021db:	e8 90 fe ff ff       	call   802070 <nsipc>
}
  8021e0:	83 c4 14             	add    $0x14,%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5d                   	pop    %ebp
  8021e5:	c3                   	ret    

008021e6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8021f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8021fc:	b8 06 00 00 00       	mov    $0x6,%eax
  802201:	e8 6a fe ff ff       	call   802070 <nsipc>
}
  802206:	c9                   	leave  
  802207:	c3                   	ret    

00802208 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	56                   	push   %esi
  80220c:	53                   	push   %ebx
  80220d:	83 ec 10             	sub    $0x10,%esp
  802210:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802213:	8b 45 08             	mov    0x8(%ebp),%eax
  802216:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80221b:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802221:	8b 45 14             	mov    0x14(%ebp),%eax
  802224:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802229:	b8 07 00 00 00       	mov    $0x7,%eax
  80222e:	e8 3d fe ff ff       	call   802070 <nsipc>
  802233:	89 c3                	mov    %eax,%ebx
  802235:	85 c0                	test   %eax,%eax
  802237:	78 46                	js     80227f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802239:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80223e:	7f 04                	jg     802244 <nsipc_recv+0x3c>
  802240:	39 c6                	cmp    %eax,%esi
  802242:	7d 24                	jge    802268 <nsipc_recv+0x60>
  802244:	c7 44 24 0c d0 31 80 	movl   $0x8031d0,0xc(%esp)
  80224b:	00 
  80224c:	c7 44 24 08 e7 30 80 	movl   $0x8030e7,0x8(%esp)
  802253:	00 
  802254:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80225b:	00 
  80225c:	c7 04 24 e5 31 80 00 	movl   $0x8031e5,(%esp)
  802263:	e8 64 df ff ff       	call   8001cc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802268:	89 44 24 08          	mov    %eax,0x8(%esp)
  80226c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802273:	00 
  802274:	8b 45 0c             	mov    0xc(%ebp),%eax
  802277:	89 04 24             	mov    %eax,(%esp)
  80227a:	e8 69 e7 ff ff       	call   8009e8 <memmove>
	}

	return r;
}
  80227f:	89 d8                	mov    %ebx,%eax
  802281:	83 c4 10             	add    $0x10,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	53                   	push   %ebx
  80228c:	83 ec 14             	sub    $0x14,%esp
  80228f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802292:	8b 45 08             	mov    0x8(%ebp),%eax
  802295:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80229a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022a0:	7e 24                	jle    8022c6 <nsipc_send+0x3e>
  8022a2:	c7 44 24 0c f1 31 80 	movl   $0x8031f1,0xc(%esp)
  8022a9:	00 
  8022aa:	c7 44 24 08 e7 30 80 	movl   $0x8030e7,0x8(%esp)
  8022b1:	00 
  8022b2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8022b9:	00 
  8022ba:	c7 04 24 e5 31 80 00 	movl   $0x8031e5,(%esp)
  8022c1:	e8 06 df ff ff       	call   8001cc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d1:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8022d8:	e8 0b e7 ff ff       	call   8009e8 <memmove>
	nsipcbuf.send.req_size = size;
  8022dd:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8022e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8022e6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8022eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8022f0:	e8 7b fd ff ff       	call   802070 <nsipc>
}
  8022f5:	83 c4 14             	add    $0x14,%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5d                   	pop    %ebp
  8022fa:	c3                   	ret    

008022fb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802301:	8b 45 08             	mov    0x8(%ebp),%eax
  802304:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802309:	8b 45 0c             	mov    0xc(%ebp),%eax
  80230c:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802311:	8b 45 10             	mov    0x10(%ebp),%eax
  802314:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802319:	b8 09 00 00 00       	mov    $0x9,%eax
  80231e:	e8 4d fd ff ff       	call   802070 <nsipc>
}
  802323:	c9                   	leave  
  802324:	c3                   	ret    
  802325:	00 00                	add    %al,(%eax)
	...

00802328 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	56                   	push   %esi
  80232c:	53                   	push   %ebx
  80232d:	83 ec 10             	sub    $0x10,%esp
  802330:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802333:	8b 45 08             	mov    0x8(%ebp),%eax
  802336:	89 04 24             	mov    %eax,(%esp)
  802339:	e8 fe eb ff ff       	call   800f3c <fd2data>
  80233e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802340:	c7 44 24 04 fd 31 80 	movl   $0x8031fd,0x4(%esp)
  802347:	00 
  802348:	89 34 24             	mov    %esi,(%esp)
  80234b:	e8 1f e5 ff ff       	call   80086f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802350:	8b 43 04             	mov    0x4(%ebx),%eax
  802353:	2b 03                	sub    (%ebx),%eax
  802355:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80235b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802362:	00 00 00 
	stat->st_dev = &devpipe;
  802365:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  80236c:	40 80 00 
	return 0;
}
  80236f:	b8 00 00 00 00       	mov    $0x0,%eax
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	5b                   	pop    %ebx
  802378:	5e                   	pop    %esi
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    

0080237b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80237b:	55                   	push   %ebp
  80237c:	89 e5                	mov    %esp,%ebp
  80237e:	53                   	push   %ebx
  80237f:	83 ec 14             	sub    $0x14,%esp
  802382:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802385:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802389:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802390:	e8 73 e9 ff ff       	call   800d08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802395:	89 1c 24             	mov    %ebx,(%esp)
  802398:	e8 9f eb ff ff       	call   800f3c <fd2data>
  80239d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a8:	e8 5b e9 ff ff       	call   800d08 <sys_page_unmap>
}
  8023ad:	83 c4 14             	add    $0x14,%esp
  8023b0:	5b                   	pop    %ebx
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    

008023b3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023b3:	55                   	push   %ebp
  8023b4:	89 e5                	mov    %esp,%ebp
  8023b6:	57                   	push   %edi
  8023b7:	56                   	push   %esi
  8023b8:	53                   	push   %ebx
  8023b9:	83 ec 2c             	sub    $0x2c,%esp
  8023bc:	89 c7                	mov    %eax,%edi
  8023be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023c1:	a1 08 50 80 00       	mov    0x805008,%eax
  8023c6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8023c9:	89 3c 24             	mov    %edi,(%esp)
  8023cc:	e8 a7 05 00 00       	call   802978 <pageref>
  8023d1:	89 c6                	mov    %eax,%esi
  8023d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023d6:	89 04 24             	mov    %eax,(%esp)
  8023d9:	e8 9a 05 00 00       	call   802978 <pageref>
  8023de:	39 c6                	cmp    %eax,%esi
  8023e0:	0f 94 c0             	sete   %al
  8023e3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8023e6:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8023ec:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8023ef:	39 cb                	cmp    %ecx,%ebx
  8023f1:	75 08                	jne    8023fb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8023f3:	83 c4 2c             	add    $0x2c,%esp
  8023f6:	5b                   	pop    %ebx
  8023f7:	5e                   	pop    %esi
  8023f8:	5f                   	pop    %edi
  8023f9:	5d                   	pop    %ebp
  8023fa:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8023fb:	83 f8 01             	cmp    $0x1,%eax
  8023fe:	75 c1                	jne    8023c1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802400:	8b 42 58             	mov    0x58(%edx),%eax
  802403:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80240a:	00 
  80240b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80240f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802413:	c7 04 24 04 32 80 00 	movl   $0x803204,(%esp)
  80241a:	e8 a5 de ff ff       	call   8002c4 <cprintf>
  80241f:	eb a0                	jmp    8023c1 <_pipeisclosed+0xe>

00802421 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802421:	55                   	push   %ebp
  802422:	89 e5                	mov    %esp,%ebp
  802424:	57                   	push   %edi
  802425:	56                   	push   %esi
  802426:	53                   	push   %ebx
  802427:	83 ec 1c             	sub    $0x1c,%esp
  80242a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80242d:	89 34 24             	mov    %esi,(%esp)
  802430:	e8 07 eb ff ff       	call   800f3c <fd2data>
  802435:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802437:	bf 00 00 00 00       	mov    $0x0,%edi
  80243c:	eb 3c                	jmp    80247a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80243e:	89 da                	mov    %ebx,%edx
  802440:	89 f0                	mov    %esi,%eax
  802442:	e8 6c ff ff ff       	call   8023b3 <_pipeisclosed>
  802447:	85 c0                	test   %eax,%eax
  802449:	75 38                	jne    802483 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80244b:	e8 f2 e7 ff ff       	call   800c42 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802450:	8b 43 04             	mov    0x4(%ebx),%eax
  802453:	8b 13                	mov    (%ebx),%edx
  802455:	83 c2 20             	add    $0x20,%edx
  802458:	39 d0                	cmp    %edx,%eax
  80245a:	73 e2                	jae    80243e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80245c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80245f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802462:	89 c2                	mov    %eax,%edx
  802464:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80246a:	79 05                	jns    802471 <devpipe_write+0x50>
  80246c:	4a                   	dec    %edx
  80246d:	83 ca e0             	or     $0xffffffe0,%edx
  802470:	42                   	inc    %edx
  802471:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802475:	40                   	inc    %eax
  802476:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802479:	47                   	inc    %edi
  80247a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80247d:	75 d1                	jne    802450 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80247f:	89 f8                	mov    %edi,%eax
  802481:	eb 05                	jmp    802488 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802483:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802488:	83 c4 1c             	add    $0x1c,%esp
  80248b:	5b                   	pop    %ebx
  80248c:	5e                   	pop    %esi
  80248d:	5f                   	pop    %edi
  80248e:	5d                   	pop    %ebp
  80248f:	c3                   	ret    

00802490 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	57                   	push   %edi
  802494:	56                   	push   %esi
  802495:	53                   	push   %ebx
  802496:	83 ec 1c             	sub    $0x1c,%esp
  802499:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80249c:	89 3c 24             	mov    %edi,(%esp)
  80249f:	e8 98 ea ff ff       	call   800f3c <fd2data>
  8024a4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024a6:	be 00 00 00 00       	mov    $0x0,%esi
  8024ab:	eb 3a                	jmp    8024e7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024ad:	85 f6                	test   %esi,%esi
  8024af:	74 04                	je     8024b5 <devpipe_read+0x25>
				return i;
  8024b1:	89 f0                	mov    %esi,%eax
  8024b3:	eb 40                	jmp    8024f5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024b5:	89 da                	mov    %ebx,%edx
  8024b7:	89 f8                	mov    %edi,%eax
  8024b9:	e8 f5 fe ff ff       	call   8023b3 <_pipeisclosed>
  8024be:	85 c0                	test   %eax,%eax
  8024c0:	75 2e                	jne    8024f0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8024c2:	e8 7b e7 ff ff       	call   800c42 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8024c7:	8b 03                	mov    (%ebx),%eax
  8024c9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8024cc:	74 df                	je     8024ad <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8024ce:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8024d3:	79 05                	jns    8024da <devpipe_read+0x4a>
  8024d5:	48                   	dec    %eax
  8024d6:	83 c8 e0             	or     $0xffffffe0,%eax
  8024d9:	40                   	inc    %eax
  8024da:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8024de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024e1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8024e4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024e6:	46                   	inc    %esi
  8024e7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024ea:	75 db                	jne    8024c7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8024ec:	89 f0                	mov    %esi,%eax
  8024ee:	eb 05                	jmp    8024f5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024f0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8024f5:	83 c4 1c             	add    $0x1c,%esp
  8024f8:	5b                   	pop    %ebx
  8024f9:	5e                   	pop    %esi
  8024fa:	5f                   	pop    %edi
  8024fb:	5d                   	pop    %ebp
  8024fc:	c3                   	ret    

008024fd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8024fd:	55                   	push   %ebp
  8024fe:	89 e5                	mov    %esp,%ebp
  802500:	57                   	push   %edi
  802501:	56                   	push   %esi
  802502:	53                   	push   %ebx
  802503:	83 ec 3c             	sub    $0x3c,%esp
  802506:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802509:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80250c:	89 04 24             	mov    %eax,(%esp)
  80250f:	e8 43 ea ff ff       	call   800f57 <fd_alloc>
  802514:	89 c3                	mov    %eax,%ebx
  802516:	85 c0                	test   %eax,%eax
  802518:	0f 88 45 01 00 00    	js     802663 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80251e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802525:	00 
  802526:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80252d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802534:	e8 28 e7 ff ff       	call   800c61 <sys_page_alloc>
  802539:	89 c3                	mov    %eax,%ebx
  80253b:	85 c0                	test   %eax,%eax
  80253d:	0f 88 20 01 00 00    	js     802663 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802543:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802546:	89 04 24             	mov    %eax,(%esp)
  802549:	e8 09 ea ff ff       	call   800f57 <fd_alloc>
  80254e:	89 c3                	mov    %eax,%ebx
  802550:	85 c0                	test   %eax,%eax
  802552:	0f 88 f8 00 00 00    	js     802650 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802558:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80255f:	00 
  802560:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802563:	89 44 24 04          	mov    %eax,0x4(%esp)
  802567:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80256e:	e8 ee e6 ff ff       	call   800c61 <sys_page_alloc>
  802573:	89 c3                	mov    %eax,%ebx
  802575:	85 c0                	test   %eax,%eax
  802577:	0f 88 d3 00 00 00    	js     802650 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80257d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802580:	89 04 24             	mov    %eax,(%esp)
  802583:	e8 b4 e9 ff ff       	call   800f3c <fd2data>
  802588:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80258a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802591:	00 
  802592:	89 44 24 04          	mov    %eax,0x4(%esp)
  802596:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80259d:	e8 bf e6 ff ff       	call   800c61 <sys_page_alloc>
  8025a2:	89 c3                	mov    %eax,%ebx
  8025a4:	85 c0                	test   %eax,%eax
  8025a6:	0f 88 91 00 00 00    	js     80263d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025af:	89 04 24             	mov    %eax,(%esp)
  8025b2:	e8 85 e9 ff ff       	call   800f3c <fd2data>
  8025b7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8025be:	00 
  8025bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8025ca:	00 
  8025cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025d6:	e8 da e6 ff ff       	call   800cb5 <sys_page_map>
  8025db:	89 c3                	mov    %eax,%ebx
  8025dd:	85 c0                	test   %eax,%eax
  8025df:	78 4c                	js     80262d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025e1:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8025e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025ea:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8025f6:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8025fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025ff:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802601:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802604:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80260b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80260e:	89 04 24             	mov    %eax,(%esp)
  802611:	e8 16 e9 ff ff       	call   800f2c <fd2num>
  802616:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802618:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80261b:	89 04 24             	mov    %eax,(%esp)
  80261e:	e8 09 e9 ff ff       	call   800f2c <fd2num>
  802623:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802626:	bb 00 00 00 00       	mov    $0x0,%ebx
  80262b:	eb 36                	jmp    802663 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80262d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802631:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802638:	e8 cb e6 ff ff       	call   800d08 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80263d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802640:	89 44 24 04          	mov    %eax,0x4(%esp)
  802644:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80264b:	e8 b8 e6 ff ff       	call   800d08 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802653:	89 44 24 04          	mov    %eax,0x4(%esp)
  802657:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80265e:	e8 a5 e6 ff ff       	call   800d08 <sys_page_unmap>
    err:
	return r;
}
  802663:	89 d8                	mov    %ebx,%eax
  802665:	83 c4 3c             	add    $0x3c,%esp
  802668:	5b                   	pop    %ebx
  802669:	5e                   	pop    %esi
  80266a:	5f                   	pop    %edi
  80266b:	5d                   	pop    %ebp
  80266c:	c3                   	ret    

0080266d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80266d:	55                   	push   %ebp
  80266e:	89 e5                	mov    %esp,%ebp
  802670:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802673:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802676:	89 44 24 04          	mov    %eax,0x4(%esp)
  80267a:	8b 45 08             	mov    0x8(%ebp),%eax
  80267d:	89 04 24             	mov    %eax,(%esp)
  802680:	e8 25 e9 ff ff       	call   800faa <fd_lookup>
  802685:	85 c0                	test   %eax,%eax
  802687:	78 15                	js     80269e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80268c:	89 04 24             	mov    %eax,(%esp)
  80268f:	e8 a8 e8 ff ff       	call   800f3c <fd2data>
	return _pipeisclosed(fd, p);
  802694:	89 c2                	mov    %eax,%edx
  802696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802699:	e8 15 fd ff ff       	call   8023b3 <_pipeisclosed>
}
  80269e:	c9                   	leave  
  80269f:	c3                   	ret    

008026a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8026a0:	55                   	push   %ebp
  8026a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8026a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8026a8:	5d                   	pop    %ebp
  8026a9:	c3                   	ret    

008026aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8026aa:	55                   	push   %ebp
  8026ab:	89 e5                	mov    %esp,%ebp
  8026ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8026b0:	c7 44 24 04 1c 32 80 	movl   $0x80321c,0x4(%esp)
  8026b7:	00 
  8026b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026bb:	89 04 24             	mov    %eax,(%esp)
  8026be:	e8 ac e1 ff ff       	call   80086f <strcpy>
	return 0;
}
  8026c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8026c8:	c9                   	leave  
  8026c9:	c3                   	ret    

008026ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026ca:	55                   	push   %ebp
  8026cb:	89 e5                	mov    %esp,%ebp
  8026cd:	57                   	push   %edi
  8026ce:	56                   	push   %esi
  8026cf:	53                   	push   %ebx
  8026d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8026db:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026e1:	eb 30                	jmp    802713 <devcons_write+0x49>
		m = n - tot;
  8026e3:	8b 75 10             	mov    0x10(%ebp),%esi
  8026e6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8026e8:	83 fe 7f             	cmp    $0x7f,%esi
  8026eb:	76 05                	jbe    8026f2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8026ed:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8026f2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8026f6:	03 45 0c             	add    0xc(%ebp),%eax
  8026f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026fd:	89 3c 24             	mov    %edi,(%esp)
  802700:	e8 e3 e2 ff ff       	call   8009e8 <memmove>
		sys_cputs(buf, m);
  802705:	89 74 24 04          	mov    %esi,0x4(%esp)
  802709:	89 3c 24             	mov    %edi,(%esp)
  80270c:	e8 83 e4 ff ff       	call   800b94 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802711:	01 f3                	add    %esi,%ebx
  802713:	89 d8                	mov    %ebx,%eax
  802715:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802718:	72 c9                	jb     8026e3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80271a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802720:	5b                   	pop    %ebx
  802721:	5e                   	pop    %esi
  802722:	5f                   	pop    %edi
  802723:	5d                   	pop    %ebp
  802724:	c3                   	ret    

00802725 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802725:	55                   	push   %ebp
  802726:	89 e5                	mov    %esp,%ebp
  802728:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80272b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80272f:	75 07                	jne    802738 <devcons_read+0x13>
  802731:	eb 25                	jmp    802758 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802733:	e8 0a e5 ff ff       	call   800c42 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802738:	e8 75 e4 ff ff       	call   800bb2 <sys_cgetc>
  80273d:	85 c0                	test   %eax,%eax
  80273f:	74 f2                	je     802733 <devcons_read+0xe>
  802741:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802743:	85 c0                	test   %eax,%eax
  802745:	78 1d                	js     802764 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802747:	83 f8 04             	cmp    $0x4,%eax
  80274a:	74 13                	je     80275f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80274c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80274f:	88 10                	mov    %dl,(%eax)
	return 1;
  802751:	b8 01 00 00 00       	mov    $0x1,%eax
  802756:	eb 0c                	jmp    802764 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802758:	b8 00 00 00 00       	mov    $0x0,%eax
  80275d:	eb 05                	jmp    802764 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80275f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802764:	c9                   	leave  
  802765:	c3                   	ret    

00802766 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802766:	55                   	push   %ebp
  802767:	89 e5                	mov    %esp,%ebp
  802769:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80276c:	8b 45 08             	mov    0x8(%ebp),%eax
  80276f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802772:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802779:	00 
  80277a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80277d:	89 04 24             	mov    %eax,(%esp)
  802780:	e8 0f e4 ff ff       	call   800b94 <sys_cputs>
}
  802785:	c9                   	leave  
  802786:	c3                   	ret    

00802787 <getchar>:

int
getchar(void)
{
  802787:	55                   	push   %ebp
  802788:	89 e5                	mov    %esp,%ebp
  80278a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80278d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802794:	00 
  802795:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80279c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027a3:	e8 a0 ea ff ff       	call   801248 <read>
	if (r < 0)
  8027a8:	85 c0                	test   %eax,%eax
  8027aa:	78 0f                	js     8027bb <getchar+0x34>
		return r;
	if (r < 1)
  8027ac:	85 c0                	test   %eax,%eax
  8027ae:	7e 06                	jle    8027b6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8027b0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8027b4:	eb 05                	jmp    8027bb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8027b6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8027bb:	c9                   	leave  
  8027bc:	c3                   	ret    

008027bd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8027bd:	55                   	push   %ebp
  8027be:	89 e5                	mov    %esp,%ebp
  8027c0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8027cd:	89 04 24             	mov    %eax,(%esp)
  8027d0:	e8 d5 e7 ff ff       	call   800faa <fd_lookup>
  8027d5:	85 c0                	test   %eax,%eax
  8027d7:	78 11                	js     8027ea <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8027d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027dc:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8027e2:	39 10                	cmp    %edx,(%eax)
  8027e4:	0f 94 c0             	sete   %al
  8027e7:	0f b6 c0             	movzbl %al,%eax
}
  8027ea:	c9                   	leave  
  8027eb:	c3                   	ret    

008027ec <opencons>:

int
opencons(void)
{
  8027ec:	55                   	push   %ebp
  8027ed:	89 e5                	mov    %esp,%ebp
  8027ef:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8027f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027f5:	89 04 24             	mov    %eax,(%esp)
  8027f8:	e8 5a e7 ff ff       	call   800f57 <fd_alloc>
  8027fd:	85 c0                	test   %eax,%eax
  8027ff:	78 3c                	js     80283d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802801:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802808:	00 
  802809:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80280c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802810:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802817:	e8 45 e4 ff ff       	call   800c61 <sys_page_alloc>
  80281c:	85 c0                	test   %eax,%eax
  80281e:	78 1d                	js     80283d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802820:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802826:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802829:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80282b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80282e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802835:	89 04 24             	mov    %eax,(%esp)
  802838:	e8 ef e6 ff ff       	call   800f2c <fd2num>
}
  80283d:	c9                   	leave  
  80283e:	c3                   	ret    
	...

00802840 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802840:	55                   	push   %ebp
  802841:	89 e5                	mov    %esp,%ebp
  802843:	56                   	push   %esi
  802844:	53                   	push   %ebx
  802845:	83 ec 10             	sub    $0x10,%esp
  802848:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80284b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80284e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802851:	85 c0                	test   %eax,%eax
  802853:	74 0a                	je     80285f <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802855:	89 04 24             	mov    %eax,(%esp)
  802858:	e8 1a e6 ff ff       	call   800e77 <sys_ipc_recv>
  80285d:	eb 0c                	jmp    80286b <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80285f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802866:	e8 0c e6 ff ff       	call   800e77 <sys_ipc_recv>
	}
	if (r < 0)
  80286b:	85 c0                	test   %eax,%eax
  80286d:	79 16                	jns    802885 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80286f:	85 db                	test   %ebx,%ebx
  802871:	74 06                	je     802879 <ipc_recv+0x39>
  802873:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802879:	85 f6                	test   %esi,%esi
  80287b:	74 2c                	je     8028a9 <ipc_recv+0x69>
  80287d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802883:	eb 24                	jmp    8028a9 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802885:	85 db                	test   %ebx,%ebx
  802887:	74 0a                	je     802893 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802889:	a1 08 50 80 00       	mov    0x805008,%eax
  80288e:	8b 40 74             	mov    0x74(%eax),%eax
  802891:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802893:	85 f6                	test   %esi,%esi
  802895:	74 0a                	je     8028a1 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802897:	a1 08 50 80 00       	mov    0x805008,%eax
  80289c:	8b 40 78             	mov    0x78(%eax),%eax
  80289f:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8028a1:	a1 08 50 80 00       	mov    0x805008,%eax
  8028a6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8028a9:	83 c4 10             	add    $0x10,%esp
  8028ac:	5b                   	pop    %ebx
  8028ad:	5e                   	pop    %esi
  8028ae:	5d                   	pop    %ebp
  8028af:	c3                   	ret    

008028b0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028b0:	55                   	push   %ebp
  8028b1:	89 e5                	mov    %esp,%ebp
  8028b3:	57                   	push   %edi
  8028b4:	56                   	push   %esi
  8028b5:	53                   	push   %ebx
  8028b6:	83 ec 1c             	sub    $0x1c,%esp
  8028b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8028bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8028bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8028c2:	85 db                	test   %ebx,%ebx
  8028c4:	74 19                	je     8028df <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8028c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8028c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028cd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028d5:	89 34 24             	mov    %esi,(%esp)
  8028d8:	e8 77 e5 ff ff       	call   800e54 <sys_ipc_try_send>
  8028dd:	eb 1c                	jmp    8028fb <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8028df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8028e6:	00 
  8028e7:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8028ee:	ee 
  8028ef:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028f3:	89 34 24             	mov    %esi,(%esp)
  8028f6:	e8 59 e5 ff ff       	call   800e54 <sys_ipc_try_send>
		}
		if (r == 0)
  8028fb:	85 c0                	test   %eax,%eax
  8028fd:	74 2c                	je     80292b <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8028ff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802902:	74 20                	je     802924 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802904:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802908:	c7 44 24 08 28 32 80 	movl   $0x803228,0x8(%esp)
  80290f:	00 
  802910:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802917:	00 
  802918:	c7 04 24 3b 32 80 00 	movl   $0x80323b,(%esp)
  80291f:	e8 a8 d8 ff ff       	call   8001cc <_panic>
		}
		sys_yield();
  802924:	e8 19 e3 ff ff       	call   800c42 <sys_yield>
	}
  802929:	eb 97                	jmp    8028c2 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80292b:	83 c4 1c             	add    $0x1c,%esp
  80292e:	5b                   	pop    %ebx
  80292f:	5e                   	pop    %esi
  802930:	5f                   	pop    %edi
  802931:	5d                   	pop    %ebp
  802932:	c3                   	ret    

00802933 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802933:	55                   	push   %ebp
  802934:	89 e5                	mov    %esp,%ebp
  802936:	53                   	push   %ebx
  802937:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80293a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80293f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802946:	89 c2                	mov    %eax,%edx
  802948:	c1 e2 07             	shl    $0x7,%edx
  80294b:	29 ca                	sub    %ecx,%edx
  80294d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802953:	8b 52 50             	mov    0x50(%edx),%edx
  802956:	39 da                	cmp    %ebx,%edx
  802958:	75 0f                	jne    802969 <ipc_find_env+0x36>
			return envs[i].env_id;
  80295a:	c1 e0 07             	shl    $0x7,%eax
  80295d:	29 c8                	sub    %ecx,%eax
  80295f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802964:	8b 40 40             	mov    0x40(%eax),%eax
  802967:	eb 0c                	jmp    802975 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802969:	40                   	inc    %eax
  80296a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80296f:	75 ce                	jne    80293f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802971:	66 b8 00 00          	mov    $0x0,%ax
}
  802975:	5b                   	pop    %ebx
  802976:	5d                   	pop    %ebp
  802977:	c3                   	ret    

00802978 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802978:	55                   	push   %ebp
  802979:	89 e5                	mov    %esp,%ebp
  80297b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80297e:	89 c2                	mov    %eax,%edx
  802980:	c1 ea 16             	shr    $0x16,%edx
  802983:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80298a:	f6 c2 01             	test   $0x1,%dl
  80298d:	74 1e                	je     8029ad <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80298f:	c1 e8 0c             	shr    $0xc,%eax
  802992:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802999:	a8 01                	test   $0x1,%al
  80299b:	74 17                	je     8029b4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80299d:	c1 e8 0c             	shr    $0xc,%eax
  8029a0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8029a7:	ef 
  8029a8:	0f b7 c0             	movzwl %ax,%eax
  8029ab:	eb 0c                	jmp    8029b9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8029ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8029b2:	eb 05                	jmp    8029b9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8029b4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8029b9:	5d                   	pop    %ebp
  8029ba:	c3                   	ret    
	...

008029bc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8029bc:	55                   	push   %ebp
  8029bd:	57                   	push   %edi
  8029be:	56                   	push   %esi
  8029bf:	83 ec 10             	sub    $0x10,%esp
  8029c2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8029c6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8029ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029ce:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8029d2:	89 cd                	mov    %ecx,%ebp
  8029d4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8029d8:	85 c0                	test   %eax,%eax
  8029da:	75 2c                	jne    802a08 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8029dc:	39 f9                	cmp    %edi,%ecx
  8029de:	77 68                	ja     802a48 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8029e0:	85 c9                	test   %ecx,%ecx
  8029e2:	75 0b                	jne    8029ef <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8029e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8029e9:	31 d2                	xor    %edx,%edx
  8029eb:	f7 f1                	div    %ecx
  8029ed:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8029ef:	31 d2                	xor    %edx,%edx
  8029f1:	89 f8                	mov    %edi,%eax
  8029f3:	f7 f1                	div    %ecx
  8029f5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029f7:	89 f0                	mov    %esi,%eax
  8029f9:	f7 f1                	div    %ecx
  8029fb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029fd:	89 f0                	mov    %esi,%eax
  8029ff:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a01:	83 c4 10             	add    $0x10,%esp
  802a04:	5e                   	pop    %esi
  802a05:	5f                   	pop    %edi
  802a06:	5d                   	pop    %ebp
  802a07:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a08:	39 f8                	cmp    %edi,%eax
  802a0a:	77 2c                	ja     802a38 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a0c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802a0f:	83 f6 1f             	xor    $0x1f,%esi
  802a12:	75 4c                	jne    802a60 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a14:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a16:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a1b:	72 0a                	jb     802a27 <__udivdi3+0x6b>
  802a1d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802a21:	0f 87 ad 00 00 00    	ja     802ad4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a27:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a2c:	89 f0                	mov    %esi,%eax
  802a2e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a30:	83 c4 10             	add    $0x10,%esp
  802a33:	5e                   	pop    %esi
  802a34:	5f                   	pop    %edi
  802a35:	5d                   	pop    %ebp
  802a36:	c3                   	ret    
  802a37:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a38:	31 ff                	xor    %edi,%edi
  802a3a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a3c:	89 f0                	mov    %esi,%eax
  802a3e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a40:	83 c4 10             	add    $0x10,%esp
  802a43:	5e                   	pop    %esi
  802a44:	5f                   	pop    %edi
  802a45:	5d                   	pop    %ebp
  802a46:	c3                   	ret    
  802a47:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a48:	89 fa                	mov    %edi,%edx
  802a4a:	89 f0                	mov    %esi,%eax
  802a4c:	f7 f1                	div    %ecx
  802a4e:	89 c6                	mov    %eax,%esi
  802a50:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a52:	89 f0                	mov    %esi,%eax
  802a54:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a56:	83 c4 10             	add    $0x10,%esp
  802a59:	5e                   	pop    %esi
  802a5a:	5f                   	pop    %edi
  802a5b:	5d                   	pop    %ebp
  802a5c:	c3                   	ret    
  802a5d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a60:	89 f1                	mov    %esi,%ecx
  802a62:	d3 e0                	shl    %cl,%eax
  802a64:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a68:	b8 20 00 00 00       	mov    $0x20,%eax
  802a6d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802a6f:	89 ea                	mov    %ebp,%edx
  802a71:	88 c1                	mov    %al,%cl
  802a73:	d3 ea                	shr    %cl,%edx
  802a75:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802a79:	09 ca                	or     %ecx,%edx
  802a7b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802a7f:	89 f1                	mov    %esi,%ecx
  802a81:	d3 e5                	shl    %cl,%ebp
  802a83:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802a87:	89 fd                	mov    %edi,%ebp
  802a89:	88 c1                	mov    %al,%cl
  802a8b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802a8d:	89 fa                	mov    %edi,%edx
  802a8f:	89 f1                	mov    %esi,%ecx
  802a91:	d3 e2                	shl    %cl,%edx
  802a93:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a97:	88 c1                	mov    %al,%cl
  802a99:	d3 ef                	shr    %cl,%edi
  802a9b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a9d:	89 f8                	mov    %edi,%eax
  802a9f:	89 ea                	mov    %ebp,%edx
  802aa1:	f7 74 24 08          	divl   0x8(%esp)
  802aa5:	89 d1                	mov    %edx,%ecx
  802aa7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802aa9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802aad:	39 d1                	cmp    %edx,%ecx
  802aaf:	72 17                	jb     802ac8 <__udivdi3+0x10c>
  802ab1:	74 09                	je     802abc <__udivdi3+0x100>
  802ab3:	89 fe                	mov    %edi,%esi
  802ab5:	31 ff                	xor    %edi,%edi
  802ab7:	e9 41 ff ff ff       	jmp    8029fd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802abc:	8b 54 24 04          	mov    0x4(%esp),%edx
  802ac0:	89 f1                	mov    %esi,%ecx
  802ac2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ac4:	39 c2                	cmp    %eax,%edx
  802ac6:	73 eb                	jae    802ab3 <__udivdi3+0xf7>
		{
		  q0--;
  802ac8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802acb:	31 ff                	xor    %edi,%edi
  802acd:	e9 2b ff ff ff       	jmp    8029fd <__udivdi3+0x41>
  802ad2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802ad4:	31 f6                	xor    %esi,%esi
  802ad6:	e9 22 ff ff ff       	jmp    8029fd <__udivdi3+0x41>
	...

00802adc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802adc:	55                   	push   %ebp
  802add:	57                   	push   %edi
  802ade:	56                   	push   %esi
  802adf:	83 ec 20             	sub    $0x20,%esp
  802ae2:	8b 44 24 30          	mov    0x30(%esp),%eax
  802ae6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802aea:	89 44 24 14          	mov    %eax,0x14(%esp)
  802aee:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802af2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802af6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802afa:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802afc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802afe:	85 ed                	test   %ebp,%ebp
  802b00:	75 16                	jne    802b18 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802b02:	39 f1                	cmp    %esi,%ecx
  802b04:	0f 86 a6 00 00 00    	jbe    802bb0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b0a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802b0c:	89 d0                	mov    %edx,%eax
  802b0e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b10:	83 c4 20             	add    $0x20,%esp
  802b13:	5e                   	pop    %esi
  802b14:	5f                   	pop    %edi
  802b15:	5d                   	pop    %ebp
  802b16:	c3                   	ret    
  802b17:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b18:	39 f5                	cmp    %esi,%ebp
  802b1a:	0f 87 ac 00 00 00    	ja     802bcc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802b20:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802b23:	83 f0 1f             	xor    $0x1f,%eax
  802b26:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b2a:	0f 84 a8 00 00 00    	je     802bd8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802b30:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b34:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802b36:	bf 20 00 00 00       	mov    $0x20,%edi
  802b3b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802b3f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b43:	89 f9                	mov    %edi,%ecx
  802b45:	d3 e8                	shr    %cl,%eax
  802b47:	09 e8                	or     %ebp,%eax
  802b49:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802b4d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b51:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b55:	d3 e0                	shl    %cl,%eax
  802b57:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b5b:	89 f2                	mov    %esi,%edx
  802b5d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802b5f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b63:	d3 e0                	shl    %cl,%eax
  802b65:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b69:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b6d:	89 f9                	mov    %edi,%ecx
  802b6f:	d3 e8                	shr    %cl,%eax
  802b71:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802b73:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802b75:	89 f2                	mov    %esi,%edx
  802b77:	f7 74 24 18          	divl   0x18(%esp)
  802b7b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802b7d:	f7 64 24 0c          	mull   0xc(%esp)
  802b81:	89 c5                	mov    %eax,%ebp
  802b83:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b85:	39 d6                	cmp    %edx,%esi
  802b87:	72 67                	jb     802bf0 <__umoddi3+0x114>
  802b89:	74 75                	je     802c00 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802b8b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802b8f:	29 e8                	sub    %ebp,%eax
  802b91:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802b93:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b97:	d3 e8                	shr    %cl,%eax
  802b99:	89 f2                	mov    %esi,%edx
  802b9b:	89 f9                	mov    %edi,%ecx
  802b9d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802b9f:	09 d0                	or     %edx,%eax
  802ba1:	89 f2                	mov    %esi,%edx
  802ba3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ba7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ba9:	83 c4 20             	add    $0x20,%esp
  802bac:	5e                   	pop    %esi
  802bad:	5f                   	pop    %edi
  802bae:	5d                   	pop    %ebp
  802baf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802bb0:	85 c9                	test   %ecx,%ecx
  802bb2:	75 0b                	jne    802bbf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802bb4:	b8 01 00 00 00       	mov    $0x1,%eax
  802bb9:	31 d2                	xor    %edx,%edx
  802bbb:	f7 f1                	div    %ecx
  802bbd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802bbf:	89 f0                	mov    %esi,%eax
  802bc1:	31 d2                	xor    %edx,%edx
  802bc3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802bc5:	89 f8                	mov    %edi,%eax
  802bc7:	e9 3e ff ff ff       	jmp    802b0a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802bcc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bce:	83 c4 20             	add    $0x20,%esp
  802bd1:	5e                   	pop    %esi
  802bd2:	5f                   	pop    %edi
  802bd3:	5d                   	pop    %ebp
  802bd4:	c3                   	ret    
  802bd5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802bd8:	39 f5                	cmp    %esi,%ebp
  802bda:	72 04                	jb     802be0 <__umoddi3+0x104>
  802bdc:	39 f9                	cmp    %edi,%ecx
  802bde:	77 06                	ja     802be6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802be0:	89 f2                	mov    %esi,%edx
  802be2:	29 cf                	sub    %ecx,%edi
  802be4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802be6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802be8:	83 c4 20             	add    $0x20,%esp
  802beb:	5e                   	pop    %esi
  802bec:	5f                   	pop    %edi
  802bed:	5d                   	pop    %ebp
  802bee:	c3                   	ret    
  802bef:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802bf0:	89 d1                	mov    %edx,%ecx
  802bf2:	89 c5                	mov    %eax,%ebp
  802bf4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802bf8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802bfc:	eb 8d                	jmp    802b8b <__umoddi3+0xaf>
  802bfe:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c00:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802c04:	72 ea                	jb     802bf0 <__umoddi3+0x114>
  802c06:	89 f1                	mov    %esi,%ecx
  802c08:	eb 81                	jmp    802b8b <__umoddi3+0xaf>
