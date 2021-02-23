
obj/user/spawnfaultio.debug:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 08 50 80 00       	mov    0x805008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 60 2b 80 00 	movl   $0x802b60,(%esp)
  80004d:	e8 aa 01 00 00       	call   8001fc <cprintf>
	if ((r = spawnl("faultio", "faultio", 0)) < 0)
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 7e 2b 80 	movl   $0x802b7e,0x4(%esp)
  800061:	00 
  800062:	c7 04 24 7e 2b 80 00 	movl   $0x802b7e,(%esp)
  800069:	e8 86 1c 00 00       	call   801cf4 <spawnl>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 20                	jns    800092 <umain+0x5e>
		panic("spawn(faultio) failed: %e", r);
  800072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800076:	c7 44 24 08 86 2b 80 	movl   $0x802b86,0x8(%esp)
  80007d:	00 
  80007e:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 a0 2b 80 00 	movl   $0x802ba0,(%esp)
  80008d:	e8 72 00 00 00       	call   800104 <_panic>
}
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	56                   	push   %esi
  800098:	53                   	push   %ebx
  800099:	83 ec 10             	sub    $0x10,%esp
  80009c:	8b 75 08             	mov    0x8(%ebp),%esi
  80009f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a2:	e8 b4 0a 00 00       	call   800b5b <sys_getenvid>
  8000a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000b3:	c1 e0 07             	shl    $0x7,%eax
  8000b6:	29 d0                	sub    %edx,%eax
  8000b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000bd:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c2:	85 f6                	test   %esi,%esi
  8000c4:	7e 07                	jle    8000cd <libmain+0x39>
		binaryname = argv[0];
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 5b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d9:	e8 0a 00 00 00       	call   8000e8 <exit>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    
  8000e5:	00 00                	add    %al,(%eax)
	...

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ee:	e8 58 0f 00 00       	call   80104b <close_all>
	sys_env_destroy(0);
  8000f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fa:	e8 0a 0a 00 00       	call   800b09 <sys_env_destroy>
}
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80010c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80010f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800115:	e8 41 0a 00 00       	call   800b5b <sys_getenvid>
  80011a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80011d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800128:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 c0 2b 80 00 	movl   $0x802bc0,(%esp)
  800137:	e8 c0 00 00 00       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800140:	8b 45 10             	mov    0x10(%ebp),%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 50 00 00 00       	call   80019b <vcprintf>
	cprintf("\n");
  80014b:	c7 04 24 d5 30 80 00 	movl   $0x8030d5,(%esp)
  800152:	e8 a5 00 00 00       	call   8001fc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800157:	cc                   	int3   
  800158:	eb fd                	jmp    800157 <_panic+0x53>
	...

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 14             	sub    $0x14,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016f:	40                   	inc    %eax
  800170:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800172:	3d ff 00 00 00       	cmp    $0xff,%eax
  800177:	75 19                	jne    800192 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800179:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800180:	00 
  800181:	8d 43 08             	lea    0x8(%ebx),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 40 09 00 00       	call   800acc <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800192:	ff 43 04             	incl   0x4(%ebx)
}
  800195:	83 c4 14             	add    $0x14,%esp
  800198:	5b                   	pop    %ebx
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 5c 01 80 00 	movl   $0x80015c,(%esp)
  8001d7:	e8 82 01 00 00       	call   80035e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001dc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 d8 08 00 00       	call   800acc <sys_cputs>

	return b.cnt;
}
  8001f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	89 44 24 04          	mov    %eax,0x4(%esp)
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	89 04 24             	mov    %eax,(%esp)
  80020f:	e8 87 ff ff ff       	call   80019b <vcprintf>
	va_end(ap);

	return cnt;
}
  800214:	c9                   	leave  
  800215:	c3                   	ret    
	...

00800218 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 3c             	sub    $0x3c,%esp
  800221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800224:	89 d7                	mov    %edx,%edi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800235:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	85 c0                	test   %eax,%eax
  80023a:	75 08                	jne    800244 <printnum+0x2c>
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 57                	ja     80029b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	89 74 24 10          	mov    %esi,0x10(%esp)
  800248:	4b                   	dec    %ebx
  800249:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024d:	8b 45 10             	mov    0x10(%ebp),%eax
  800250:	89 44 24 08          	mov    %eax,0x8(%esp)
  800254:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800258:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80025c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800263:	00 
  800264:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	e8 7e 26 00 00       	call   8028f4 <__udivdi3>
  800276:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	89 54 24 04          	mov    %edx,0x4(%esp)
  800285:	89 fa                	mov    %edi,%edx
  800287:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028a:	e8 89 ff ff ff       	call   800218 <printnum>
  80028f:	eb 0f                	jmp    8002a0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800291:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800295:	89 34 24             	mov    %esi,(%esp)
  800298:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	4b                   	dec    %ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7f f1                	jg     800291 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b6:	00 
  8002b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	e8 4b 27 00 00       	call   802a14 <__umoddi3>
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cd:	0f be 80 e3 2b 80 00 	movsbl 0x802be3(%eax),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002da:	83 c4 3c             	add    $0x3c,%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 22                	jmp    80031a <getuint+0x38>
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	74 10                	je     80030c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb 0e                	jmp    80031a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800322:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800325:	8b 10                	mov    (%eax),%edx
  800327:	3b 50 04             	cmp    0x4(%eax),%edx
  80032a:	73 08                	jae    800334 <sprintputch+0x18>
		*b->buf++ = ch;
  80032c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032f:	88 0a                	mov    %cl,(%edx)
  800331:	42                   	inc    %edx
  800332:	89 10                	mov    %edx,(%eax)
}
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80033c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800343:	8b 45 10             	mov    0x10(%ebp),%eax
  800346:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 02 00 00 00       	call   80035e <vprintfmt>
	va_end(ap);
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    

0080035e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
  800364:	83 ec 4c             	sub    $0x4c,%esp
  800367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036a:	8b 75 10             	mov    0x10(%ebp),%esi
  80036d:	eb 12                	jmp    800381 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036f:	85 c0                	test   %eax,%eax
  800371:	0f 84 6b 03 00 00    	je     8006e2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800377:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800381:	0f b6 06             	movzbl (%esi),%eax
  800384:	46                   	inc    %esi
  800385:	83 f8 25             	cmp    $0x25,%eax
  800388:	75 e5                	jne    80036f <vprintfmt+0x11>
  80038a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80038e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800395:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80039a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a6:	eb 26                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ab:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003af:	eb 1d                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003b8:	eb 14                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c4:	eb 08                	jmp    8003ce <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	0f b6 06             	movzbl (%esi),%eax
  8003d1:	8d 56 01             	lea    0x1(%esi),%edx
  8003d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003d7:	8a 16                	mov    (%esi),%dl
  8003d9:	83 ea 23             	sub    $0x23,%edx
  8003dc:	80 fa 55             	cmp    $0x55,%dl
  8003df:	0f 87 e1 02 00 00    	ja     8006c6 <vprintfmt+0x368>
  8003e5:	0f b6 d2             	movzbl %dl,%edx
  8003e8:	ff 24 95 20 2d 80 00 	jmp    *0x802d20(,%edx,4)
  8003ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003f2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003fa:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003fe:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800401:	8d 50 d0             	lea    -0x30(%eax),%edx
  800404:	83 fa 09             	cmp    $0x9,%edx
  800407:	77 2a                	ja     800433 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040a:	eb eb                	jmp    8003f7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041a:	eb 17                	jmp    800433 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80041c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800420:	78 98                	js     8003ba <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800425:	eb a7                	jmp    8003ce <vprintfmt+0x70>
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800431:	eb 9b                	jmp    8003ce <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800433:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800437:	79 95                	jns    8003ce <vprintfmt+0x70>
  800439:	eb 8b                	jmp    8003c6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043f:	eb 8d                	jmp    8003ce <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800459:	e9 23 ff ff ff       	jmp    800381 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	85 c0                	test   %eax,%eax
  80046b:	79 02                	jns    80046f <vprintfmt+0x111>
  80046d:	f7 d8                	neg    %eax
  80046f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800471:	83 f8 10             	cmp    $0x10,%eax
  800474:	7f 0b                	jg     800481 <vprintfmt+0x123>
  800476:	8b 04 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%eax
  80047d:	85 c0                	test   %eax,%eax
  80047f:	75 23                	jne    8004a4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800481:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800485:	c7 44 24 08 fb 2b 80 	movl   $0x802bfb,0x8(%esp)
  80048c:	00 
  80048d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 9a fe ff ff       	call   800336 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049f:	e9 dd fe ff ff       	jmp    800381 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a8:	c7 44 24 08 b9 2f 80 	movl   $0x802fb9,0x8(%esp)
  8004af:	00 
  8004b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b7:	89 14 24             	mov    %edx,(%esp)
  8004ba:	e8 77 fe ff ff       	call   800336 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c2:	e9 ba fe ff ff       	jmp    800381 <vprintfmt+0x23>
  8004c7:	89 f9                	mov    %edi,%ecx
  8004c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 30                	mov    (%eax),%esi
  8004da:	85 f6                	test   %esi,%esi
  8004dc:	75 05                	jne    8004e3 <vprintfmt+0x185>
				p = "(null)";
  8004de:	be f4 2b 80 00       	mov    $0x802bf4,%esi
			if (width > 0 && padc != '-')
  8004e3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e7:	0f 8e 84 00 00 00    	jle    800571 <vprintfmt+0x213>
  8004ed:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f1:	74 7e                	je     800571 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f7:	89 34 24             	mov    %esi,(%esp)
  8004fa:	e8 8b 02 00 00       	call   80078a <strnlen>
  8004ff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800502:	29 c2                	sub    %eax,%edx
  800504:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800507:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80050b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80050e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800511:	89 de                	mov    %ebx,%esi
  800513:	89 d3                	mov    %edx,%ebx
  800515:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800517:	eb 0b                	jmp    800524 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800519:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051d:	89 3c 24             	mov    %edi,(%esp)
  800520:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	4b                   	dec    %ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f f1                	jg     800519 <vprintfmt+0x1bb>
  800528:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80052b:	89 f3                	mov    %esi,%ebx
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800533:	85 c0                	test   %eax,%eax
  800535:	79 05                	jns    80053c <vprintfmt+0x1de>
  800537:	b8 00 00 00 00       	mov    $0x0,%eax
  80053c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80053f:	29 c2                	sub    %eax,%edx
  800541:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800544:	eb 2b                	jmp    800571 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800546:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054a:	74 18                	je     800564 <vprintfmt+0x206>
  80054c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80054f:	83 fa 5e             	cmp    $0x5e,%edx
  800552:	76 10                	jbe    800564 <vprintfmt+0x206>
					putch('?', putdat);
  800554:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800558:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055f:	ff 55 08             	call   *0x8(%ebp)
  800562:	eb 0a                	jmp    80056e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	ff 4d e4             	decl   -0x1c(%ebp)
  800571:	0f be 06             	movsbl (%esi),%eax
  800574:	46                   	inc    %esi
  800575:	85 c0                	test   %eax,%eax
  800577:	74 21                	je     80059a <vprintfmt+0x23c>
  800579:	85 ff                	test   %edi,%edi
  80057b:	78 c9                	js     800546 <vprintfmt+0x1e8>
  80057d:	4f                   	dec    %edi
  80057e:	79 c6                	jns    800546 <vprintfmt+0x1e8>
  800580:	8b 7d 08             	mov    0x8(%ebp),%edi
  800583:	89 de                	mov    %ebx,%esi
  800585:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800588:	eb 18                	jmp    8005a2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800595:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	4b                   	dec    %ebx
  800598:	eb 08                	jmp    8005a2 <vprintfmt+0x244>
  80059a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059d:	89 de                	mov    %ebx,%esi
  80059f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a2:	85 db                	test   %ebx,%ebx
  8005a4:	7f e4                	jg     80058a <vprintfmt+0x22c>
  8005a6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005a9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ae:	e9 ce fd ff ff       	jmp    800381 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b3:	83 f9 01             	cmp    $0x1,%ecx
  8005b6:	7e 10                	jle    8005c8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 08             	lea    0x8(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 30                	mov    (%eax),%esi
  8005c3:	8b 78 04             	mov    0x4(%eax),%edi
  8005c6:	eb 26                	jmp    8005ee <vprintfmt+0x290>
	else if (lflag)
  8005c8:	85 c9                	test   %ecx,%ecx
  8005ca:	74 12                	je     8005de <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 30                	mov    (%eax),%esi
  8005d7:	89 f7                	mov    %esi,%edi
  8005d9:	c1 ff 1f             	sar    $0x1f,%edi
  8005dc:	eb 10                	jmp    8005ee <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 30                	mov    (%eax),%esi
  8005e9:	89 f7                	mov    %esi,%edi
  8005eb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ee:	85 ff                	test   %edi,%edi
  8005f0:	78 0a                	js     8005fc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	e9 8c 00 00 00       	jmp    800688 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800600:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800607:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060a:	f7 de                	neg    %esi
  80060c:	83 d7 00             	adc    $0x0,%edi
  80060f:	f7 df                	neg    %edi
			}
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
  800616:	eb 70                	jmp    800688 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800618:	89 ca                	mov    %ecx,%edx
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 c0 fc ff ff       	call   8002e2 <getuint>
  800622:	89 c6                	mov    %eax,%esi
  800624:	89 d7                	mov    %edx,%edi
			base = 10;
  800626:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80062b:	eb 5b                	jmp    800688 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  80062d:	89 ca                	mov    %ecx,%edx
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 ab fc ff ff       	call   8002e2 <getuint>
  800637:	89 c6                	mov    %eax,%esi
  800639:	89 d7                	mov    %edx,%edi
			base = 8;
  80063b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800640:	eb 46                	jmp    800688 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800642:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800646:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800667:	8b 30                	mov    (%eax),%esi
  800669:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800673:	eb 13                	jmp    800688 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800675:	89 ca                	mov    %ecx,%edx
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 63 fc ff ff       	call   8002e2 <getuint>
  80067f:	89 c6                	mov    %eax,%esi
  800681:	89 d7                	mov    %edx,%edi
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80068c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800690:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800693:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800697:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069b:	89 34 24             	mov    %esi,(%esp)
  80069e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a2:	89 da                	mov    %ebx,%edx
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	e8 6c fb ff ff       	call   800218 <printnum>
			break;
  8006ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006af:	e9 cd fc ff ff       	jmp    800381 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	89 04 24             	mov    %eax,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c1:	e9 bb fc ff ff       	jmp    800381 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ca:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d4:	eb 01                	jmp    8006d7 <vprintfmt+0x379>
  8006d6:	4e                   	dec    %esi
  8006d7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006db:	75 f9                	jne    8006d6 <vprintfmt+0x378>
  8006dd:	e9 9f fc ff ff       	jmp    800381 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006e2:	83 c4 4c             	add    $0x4c,%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5e                   	pop    %esi
  8006e7:	5f                   	pop    %edi
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 28             	sub    $0x28,%esp
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800700:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800707:	85 c0                	test   %eax,%eax
  800709:	74 30                	je     80073b <vsnprintf+0x51>
  80070b:	85 d2                	test   %edx,%edx
  80070d:	7e 33                	jle    800742 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800716:	8b 45 10             	mov    0x10(%ebp),%eax
  800719:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800720:	89 44 24 04          	mov    %eax,0x4(%esp)
  800724:	c7 04 24 1c 03 80 00 	movl   $0x80031c,(%esp)
  80072b:	e8 2e fc ff ff       	call   80035e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800730:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800733:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	eb 0c                	jmp    800747 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800740:	eb 05                	jmp    800747 <vsnprintf+0x5d>
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800752:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800756:	8b 45 10             	mov    0x10(%ebp),%eax
  800759:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	e8 7b ff ff ff       	call   8006ea <vsnprintf>
	va_end(ap);

	return rc;
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    
  800771:	00 00                	add    %al,(%eax)
	...

00800774 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	eb 01                	jmp    800782 <strlen+0xe>
		n++;
  800781:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f9                	jne    800781 <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800790:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	b8 00 00 00 00       	mov    $0x0,%eax
  800798:	eb 01                	jmp    80079b <strnlen+0x11>
		n++;
  80079a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	39 d0                	cmp    %edx,%eax
  80079d:	74 06                	je     8007a5 <strnlen+0x1b>
  80079f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a3:	75 f5                	jne    80079a <strnlen+0x10>
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007b9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007bc:	42                   	inc    %edx
  8007bd:	84 c9                	test   %cl,%cl
  8007bf:	75 f5                	jne    8007b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c1:	5b                   	pop    %ebx
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ce:	89 1c 24             	mov    %ebx,(%esp)
  8007d1:	e8 9e ff ff ff       	call   800774 <strlen>
	strcpy(dst + len, src);
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007dd:	01 d8                	add    %ebx,%eax
  8007df:	89 04 24             	mov    %eax,(%esp)
  8007e2:	e8 c0 ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	83 c4 08             	add    $0x8,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800802:	eb 0c                	jmp    800810 <strncpy+0x21>
		*dst++ = *src;
  800804:	8a 1a                	mov    (%edx),%bl
  800806:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800809:	80 3a 01             	cmpb   $0x1,(%edx)
  80080c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080f:	41                   	inc    %ecx
  800810:	39 f1                	cmp    %esi,%ecx
  800812:	75 f0                	jne    800804 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 75 08             	mov    0x8(%ebp),%esi
  800820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800823:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800826:	85 d2                	test   %edx,%edx
  800828:	75 0a                	jne    800834 <strlcpy+0x1c>
  80082a:	89 f0                	mov    %esi,%eax
  80082c:	eb 1a                	jmp    800848 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082e:	88 18                	mov    %bl,(%eax)
  800830:	40                   	inc    %eax
  800831:	41                   	inc    %ecx
  800832:	eb 02                	jmp    800836 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800836:	4a                   	dec    %edx
  800837:	74 0a                	je     800843 <strlcpy+0x2b>
  800839:	8a 19                	mov    (%ecx),%bl
  80083b:	84 db                	test   %bl,%bl
  80083d:	75 ef                	jne    80082e <strlcpy+0x16>
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 02                	jmp    800845 <strlcpy+0x2d>
  800843:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800845:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800848:	29 f0                	sub    %esi,%eax
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800857:	eb 02                	jmp    80085b <strcmp+0xd>
		p++, q++;
  800859:	41                   	inc    %ecx
  80085a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085b:	8a 01                	mov    (%ecx),%al
  80085d:	84 c0                	test   %al,%al
  80085f:	74 04                	je     800865 <strcmp+0x17>
  800861:	3a 02                	cmp    (%edx),%al
  800863:	74 f4                	je     800859 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 c0             	movzbl %al,%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80087c:	eb 03                	jmp    800881 <strncmp+0x12>
		n--, p++, q++;
  80087e:	4a                   	dec    %edx
  80087f:	40                   	inc    %eax
  800880:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800881:	85 d2                	test   %edx,%edx
  800883:	74 14                	je     800899 <strncmp+0x2a>
  800885:	8a 18                	mov    (%eax),%bl
  800887:	84 db                	test   %bl,%bl
  800889:	74 04                	je     80088f <strncmp+0x20>
  80088b:	3a 19                	cmp    (%ecx),%bl
  80088d:	74 ef                	je     80087e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 11             	movzbl (%ecx),%edx
  800895:	29 d0                	sub    %edx,%eax
  800897:	eb 05                	jmp    80089e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008aa:	eb 05                	jmp    8008b1 <strchr+0x10>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 0c                	je     8008bc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b0:	40                   	inc    %eax
  8008b1:	8a 10                	mov    (%eax),%dl
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	75 f5                	jne    8008ac <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c7:	eb 05                	jmp    8008ce <strfind+0x10>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 07                	je     8008d4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008cd:	40                   	inc    %eax
  8008ce:	8a 10                	mov    (%eax),%dl
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f5                	jne    8008c9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 30                	je     800919 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 25                	jne    800916 <memset+0x40>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 20                	jne    800916 <memset+0x40>
		c &= 0xFF;
  8008f6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f9:	89 d3                	mov    %edx,%ebx
  8008fb:	c1 e3 08             	shl    $0x8,%ebx
  8008fe:	89 d6                	mov    %edx,%esi
  800900:	c1 e6 18             	shl    $0x18,%esi
  800903:	89 d0                	mov    %edx,%eax
  800905:	c1 e0 10             	shl    $0x10,%eax
  800908:	09 f0                	or     %esi,%eax
  80090a:	09 d0                	or     %edx,%eax
  80090c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800911:	fc                   	cld    
  800912:	f3 ab                	rep stos %eax,%es:(%edi)
  800914:	eb 03                	jmp    800919 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800916:	fc                   	cld    
  800917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800919:	89 f8                	mov    %edi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	57                   	push   %edi
  800924:	56                   	push   %esi
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092e:	39 c6                	cmp    %eax,%esi
  800930:	73 34                	jae    800966 <memmove+0x46>
  800932:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800935:	39 d0                	cmp    %edx,%eax
  800937:	73 2d                	jae    800966 <memmove+0x46>
		s += n;
		d += n;
  800939:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	f6 c2 03             	test   $0x3,%dl
  80093f:	75 1b                	jne    80095c <memmove+0x3c>
  800941:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800947:	75 13                	jne    80095c <memmove+0x3c>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 0e                	jne    80095c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094e:	83 ef 04             	sub    $0x4,%edi
  800951:	8d 72 fc             	lea    -0x4(%edx),%esi
  800954:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800957:	fd                   	std    
  800958:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095a:	eb 07                	jmp    800963 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095c:	4f                   	dec    %edi
  80095d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800960:	fd                   	std    
  800961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800963:	fc                   	cld    
  800964:	eb 20                	jmp    800986 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096c:	75 13                	jne    800981 <memmove+0x61>
  80096e:	a8 03                	test   $0x3,%al
  800970:	75 0f                	jne    800981 <memmove+0x61>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0a                	jne    800981 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800977:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097a:	89 c7                	mov    %eax,%edi
  80097c:	fc                   	cld    
  80097d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097f:	eb 05                	jmp    800986 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800990:	8b 45 10             	mov    0x10(%ebp),%eax
  800993:	89 44 24 08          	mov    %eax,0x8(%esp)
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	89 04 24             	mov    %eax,(%esp)
  8009a4:	e8 77 ff ff ff       	call   800920 <memmove>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	eb 16                	jmp    8009d7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009c4:	42                   	inc    %edx
  8009c5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009c9:	38 c8                	cmp    %cl,%al
  8009cb:	74 0a                	je     8009d7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009cd:	0f b6 c0             	movzbl %al,%eax
  8009d0:	0f b6 c9             	movzbl %cl,%ecx
  8009d3:	29 c8                	sub    %ecx,%eax
  8009d5:	eb 09                	jmp    8009e0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d7:	39 da                	cmp    %ebx,%edx
  8009d9:	75 e6                	jne    8009c1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ee:	89 c2                	mov    %eax,%edx
  8009f0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f3:	eb 05                	jmp    8009fa <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	38 08                	cmp    %cl,(%eax)
  8009f7:	74 05                	je     8009fe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	40                   	inc    %eax
  8009fa:	39 d0                	cmp    %edx,%eax
  8009fc:	72 f7                	jb     8009f5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 55 08             	mov    0x8(%ebp),%edx
  800a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	eb 01                	jmp    800a0f <strtol+0xf>
		s++;
  800a0e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	8a 02                	mov    (%edx),%al
  800a11:	3c 20                	cmp    $0x20,%al
  800a13:	74 f9                	je     800a0e <strtol+0xe>
  800a15:	3c 09                	cmp    $0x9,%al
  800a17:	74 f5                	je     800a0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a19:	3c 2b                	cmp    $0x2b,%al
  800a1b:	75 08                	jne    800a25 <strtol+0x25>
		s++;
  800a1d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a23:	eb 13                	jmp    800a38 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a25:	3c 2d                	cmp    $0x2d,%al
  800a27:	75 0a                	jne    800a33 <strtol+0x33>
		s++, neg = 1;
  800a29:	8d 52 01             	lea    0x1(%edx),%edx
  800a2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a31:	eb 05                	jmp    800a38 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	74 05                	je     800a41 <strtol+0x41>
  800a3c:	83 fb 10             	cmp    $0x10,%ebx
  800a3f:	75 28                	jne    800a69 <strtol+0x69>
  800a41:	8a 02                	mov    (%edx),%al
  800a43:	3c 30                	cmp    $0x30,%al
  800a45:	75 10                	jne    800a57 <strtol+0x57>
  800a47:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4b:	75 0a                	jne    800a57 <strtol+0x57>
		s += 2, base = 16;
  800a4d:	83 c2 02             	add    $0x2,%edx
  800a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a55:	eb 12                	jmp    800a69 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a57:	85 db                	test   %ebx,%ebx
  800a59:	75 0e                	jne    800a69 <strtol+0x69>
  800a5b:	3c 30                	cmp    $0x30,%al
  800a5d:	75 05                	jne    800a64 <strtol+0x64>
		s++, base = 8;
  800a5f:	42                   	inc    %edx
  800a60:	b3 08                	mov    $0x8,%bl
  800a62:	eb 05                	jmp    800a69 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a64:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a70:	8a 0a                	mov    (%edx),%cl
  800a72:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a75:	80 fb 09             	cmp    $0x9,%bl
  800a78:	77 08                	ja     800a82 <strtol+0x82>
			dig = *s - '0';
  800a7a:	0f be c9             	movsbl %cl,%ecx
  800a7d:	83 e9 30             	sub    $0x30,%ecx
  800a80:	eb 1e                	jmp    800aa0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a82:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 08                	ja     800a92 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a8a:	0f be c9             	movsbl %cl,%ecx
  800a8d:	83 e9 57             	sub    $0x57,%ecx
  800a90:	eb 0e                	jmp    800aa0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a92:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a95:	80 fb 19             	cmp    $0x19,%bl
  800a98:	77 12                	ja     800aac <strtol+0xac>
			dig = *s - 'A' + 10;
  800a9a:	0f be c9             	movsbl %cl,%ecx
  800a9d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa0:	39 f1                	cmp    %esi,%ecx
  800aa2:	7d 0c                	jge    800ab0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aa4:	42                   	inc    %edx
  800aa5:	0f af c6             	imul   %esi,%eax
  800aa8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aaa:	eb c4                	jmp    800a70 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aac:	89 c1                	mov    %eax,%ecx
  800aae:	eb 02                	jmp    800ab2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab6:	74 05                	je     800abd <strtol+0xbd>
		*endptr = (char *) s;
  800ab8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800abd:	85 ff                	test   %edi,%edi
  800abf:	74 04                	je     800ac5 <strtol+0xc5>
  800ac1:	89 c8                	mov    %ecx,%eax
  800ac3:	f7 d8                	neg    %eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    
	...

00800acc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	89 c6                	mov    %eax,%esi
  800ae3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cgetc>:

int
sys_cgetc(void)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b17:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	89 cb                	mov    %ecx,%ebx
  800b21:	89 cf                	mov    %ecx,%edi
  800b23:	89 ce                	mov    %ecx,%esi
  800b25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 28                	jle    800b53 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b2f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b36:	00 
  800b37:	c7 44 24 08 e3 2e 80 	movl   $0x802ee3,0x8(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b46:	00 
  800b47:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800b4e:	e8 b1 f5 ff ff       	call   800104 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b53:	83 c4 2c             	add    $0x2c,%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_yield>:

void
sys_yield(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	be 00 00 00 00       	mov    $0x0,%esi
  800ba7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	89 f7                	mov    %esi,%edi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 28                	jle    800be5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bc8:	00 
  800bc9:	c7 44 24 08 e3 2e 80 	movl   $0x802ee3,0x8(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd8:	00 
  800bd9:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800be0:	e8 1f f5 ff ff       	call   800104 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be5:	83 c4 2c             	add    $0x2c,%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7e 28                	jle    800c38 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 08 e3 2e 80 	movl   $0x802ee3,0x8(%esp)
  800c23:	00 
  800c24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2b:	00 
  800c2c:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800c33:	e8 cc f4 ff ff       	call   800104 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c38:	83 c4 2c             	add    $0x2c,%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 28                	jle    800c8b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c67:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 08 e3 2e 80 	movl   $0x802ee3,0x8(%esp)
  800c76:	00 
  800c77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7e:	00 
  800c7f:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800c86:	e8 79 f4 ff ff       	call   800104 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8b:	83 c4 2c             	add    $0x2c,%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 28                	jle    800cde <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc1:	00 
  800cc2:	c7 44 24 08 e3 2e 80 	movl   $0x802ee3,0x8(%esp)
  800cc9:	00 
  800cca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd1:	00 
  800cd2:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800cd9:	e8 26 f4 ff ff       	call   800104 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cde:	83 c4 2c             	add    $0x2c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 df                	mov    %ebx,%edi
  800d01:	89 de                	mov    %ebx,%esi
  800d03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 28                	jle    800d31 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d14:	00 
  800d15:	c7 44 24 08 e3 2e 80 	movl   $0x802ee3,0x8(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d24:	00 
  800d25:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800d2c:	e8 d3 f3 ff ff       	call   800104 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d31:	83 c4 2c             	add    $0x2c,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	89 df                	mov    %ebx,%edi
  800d54:	89 de                	mov    %ebx,%esi
  800d56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7e 28                	jle    800d84 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d60:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d67:	00 
  800d68:	c7 44 24 08 e3 2e 80 	movl   $0x802ee3,0x8(%esp)
  800d6f:	00 
  800d70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d77:	00 
  800d78:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800d7f:	e8 80 f3 ff ff       	call   800104 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d84:	83 c4 2c             	add    $0x2c,%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	be 00 00 00 00       	mov    $0x0,%esi
  800d97:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	89 cb                	mov    %ecx,%ebx
  800dc7:	89 cf                	mov    %ecx,%edi
  800dc9:	89 ce                	mov    %ecx,%esi
  800dcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 28                	jle    800df9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 08 e3 2e 80 	movl   $0x802ee3,0x8(%esp)
  800de4:	00 
  800de5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dec:	00 
  800ded:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800df4:	e8 0b f3 ff ff       	call   800104 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df9:	83 c4 2c             	add    $0x2c,%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e11:	89 d1                	mov    %edx,%ecx
  800e13:	89 d3                	mov    %edx,%ebx
  800e15:	89 d7                	mov    %edx,%edi
  800e17:	89 d6                	mov    %edx,%esi
  800e19:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	89 df                	mov    %ebx,%edi
  800e38:	89 de                	mov    %ebx,%esi
  800e3a:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4c:	b8 10 00 00 00       	mov    $0x10,%eax
  800e51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e54:	8b 55 08             	mov    0x8(%ebp),%edx
  800e57:	89 df                	mov    %ebx,%edi
  800e59:	89 de                	mov    %ebx,%esi
  800e5b:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
	...

00800e64 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7d:	89 04 24             	mov    %eax,(%esp)
  800e80:	e8 df ff ff ff       	call   800e64 <fd2num>
  800e85:	c1 e0 0c             	shl    $0xc,%eax
  800e88:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	53                   	push   %ebx
  800e93:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e96:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e9b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e9d:	89 c2                	mov    %eax,%edx
  800e9f:	c1 ea 16             	shr    $0x16,%edx
  800ea2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea9:	f6 c2 01             	test   $0x1,%dl
  800eac:	74 11                	je     800ebf <fd_alloc+0x30>
  800eae:	89 c2                	mov    %eax,%edx
  800eb0:	c1 ea 0c             	shr    $0xc,%edx
  800eb3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eba:	f6 c2 01             	test   $0x1,%dl
  800ebd:	75 09                	jne    800ec8 <fd_alloc+0x39>
			*fd_store = fd;
  800ebf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	eb 17                	jmp    800edf <fd_alloc+0x50>
  800ec8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ecd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ed2:	75 c7                	jne    800e9b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ed4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800eda:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800edf:	5b                   	pop    %ebx
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee8:	83 f8 1f             	cmp    $0x1f,%eax
  800eeb:	77 36                	ja     800f23 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eed:	c1 e0 0c             	shl    $0xc,%eax
  800ef0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ef5:	89 c2                	mov    %eax,%edx
  800ef7:	c1 ea 16             	shr    $0x16,%edx
  800efa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f01:	f6 c2 01             	test   $0x1,%dl
  800f04:	74 24                	je     800f2a <fd_lookup+0x48>
  800f06:	89 c2                	mov    %eax,%edx
  800f08:	c1 ea 0c             	shr    $0xc,%edx
  800f0b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f12:	f6 c2 01             	test   $0x1,%dl
  800f15:	74 1a                	je     800f31 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f21:	eb 13                	jmp    800f36 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f28:	eb 0c                	jmp    800f36 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f2f:	eb 05                	jmp    800f36 <fd_lookup+0x54>
  800f31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	53                   	push   %ebx
  800f3c:	83 ec 14             	sub    $0x14,%esp
  800f3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800f45:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4a:	eb 0e                	jmp    800f5a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800f4c:	39 08                	cmp    %ecx,(%eax)
  800f4e:	75 09                	jne    800f59 <dev_lookup+0x21>
			*dev = devtab[i];
  800f50:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f52:	b8 00 00 00 00       	mov    $0x0,%eax
  800f57:	eb 33                	jmp    800f8c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f59:	42                   	inc    %edx
  800f5a:	8b 04 95 8c 2f 80 00 	mov    0x802f8c(,%edx,4),%eax
  800f61:	85 c0                	test   %eax,%eax
  800f63:	75 e7                	jne    800f4c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f65:	a1 08 50 80 00       	mov    0x805008,%eax
  800f6a:	8b 40 48             	mov    0x48(%eax),%eax
  800f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f75:	c7 04 24 10 2f 80 00 	movl   $0x802f10,(%esp)
  800f7c:	e8 7b f2 ff ff       	call   8001fc <cprintf>
	*dev = 0;
  800f81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f8c:	83 c4 14             	add    $0x14,%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	56                   	push   %esi
  800f96:	53                   	push   %ebx
  800f97:	83 ec 30             	sub    $0x30,%esp
  800f9a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f9d:	8a 45 0c             	mov    0xc(%ebp),%al
  800fa0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fa3:	89 34 24             	mov    %esi,(%esp)
  800fa6:	e8 b9 fe ff ff       	call   800e64 <fd2num>
  800fab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fae:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fb2:	89 04 24             	mov    %eax,(%esp)
  800fb5:	e8 28 ff ff ff       	call   800ee2 <fd_lookup>
  800fba:	89 c3                	mov    %eax,%ebx
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 05                	js     800fc5 <fd_close+0x33>
	    || fd != fd2)
  800fc0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fc3:	74 0d                	je     800fd2 <fd_close+0x40>
		return (must_exist ? r : 0);
  800fc5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fc9:	75 46                	jne    801011 <fd_close+0x7f>
  800fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd0:	eb 3f                	jmp    801011 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fd2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd9:	8b 06                	mov    (%esi),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 55 ff ff ff       	call   800f38 <dev_lookup>
  800fe3:	89 c3                	mov    %eax,%ebx
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 18                	js     801001 <fd_close+0x6f>
		if (dev->dev_close)
  800fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fec:	8b 40 10             	mov    0x10(%eax),%eax
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	74 09                	je     800ffc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ff3:	89 34 24             	mov    %esi,(%esp)
  800ff6:	ff d0                	call   *%eax
  800ff8:	89 c3                	mov    %eax,%ebx
  800ffa:	eb 05                	jmp    801001 <fd_close+0x6f>
		else
			r = 0;
  800ffc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801001:	89 74 24 04          	mov    %esi,0x4(%esp)
  801005:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100c:	e8 2f fc ff ff       	call   800c40 <sys_page_unmap>
	return r;
}
  801011:	89 d8                	mov    %ebx,%eax
  801013:	83 c4 30             	add    $0x30,%esp
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801020:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801023:	89 44 24 04          	mov    %eax,0x4(%esp)
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
  80102a:	89 04 24             	mov    %eax,(%esp)
  80102d:	e8 b0 fe ff ff       	call   800ee2 <fd_lookup>
  801032:	85 c0                	test   %eax,%eax
  801034:	78 13                	js     801049 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801036:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80103d:	00 
  80103e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801041:	89 04 24             	mov    %eax,(%esp)
  801044:	e8 49 ff ff ff       	call   800f92 <fd_close>
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <close_all>:

void
close_all(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	53                   	push   %ebx
  80104f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801052:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801057:	89 1c 24             	mov    %ebx,(%esp)
  80105a:	e8 bb ff ff ff       	call   80101a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80105f:	43                   	inc    %ebx
  801060:	83 fb 20             	cmp    $0x20,%ebx
  801063:	75 f2                	jne    801057 <close_all+0xc>
		close(i);
}
  801065:	83 c4 14             	add    $0x14,%esp
  801068:	5b                   	pop    %ebx
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 4c             	sub    $0x4c,%esp
  801074:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801077:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80107a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107e:	8b 45 08             	mov    0x8(%ebp),%eax
  801081:	89 04 24             	mov    %eax,(%esp)
  801084:	e8 59 fe ff ff       	call   800ee2 <fd_lookup>
  801089:	89 c3                	mov    %eax,%ebx
  80108b:	85 c0                	test   %eax,%eax
  80108d:	0f 88 e3 00 00 00    	js     801176 <dup+0x10b>
		return r;
	close(newfdnum);
  801093:	89 3c 24             	mov    %edi,(%esp)
  801096:	e8 7f ff ff ff       	call   80101a <close>

	newfd = INDEX2FD(newfdnum);
  80109b:	89 fe                	mov    %edi,%esi
  80109d:	c1 e6 0c             	shl    $0xc,%esi
  8010a0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a9:	89 04 24             	mov    %eax,(%esp)
  8010ac:	e8 c3 fd ff ff       	call   800e74 <fd2data>
  8010b1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010b3:	89 34 24             	mov    %esi,(%esp)
  8010b6:	e8 b9 fd ff ff       	call   800e74 <fd2data>
  8010bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010be:	89 d8                	mov    %ebx,%eax
  8010c0:	c1 e8 16             	shr    $0x16,%eax
  8010c3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ca:	a8 01                	test   $0x1,%al
  8010cc:	74 46                	je     801114 <dup+0xa9>
  8010ce:	89 d8                	mov    %ebx,%eax
  8010d0:	c1 e8 0c             	shr    $0xc,%eax
  8010d3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010da:	f6 c2 01             	test   $0x1,%dl
  8010dd:	74 35                	je     801114 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010fd:	00 
  8010fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801102:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801109:	e8 df fa ff ff       	call   800bed <sys_page_map>
  80110e:	89 c3                	mov    %eax,%ebx
  801110:	85 c0                	test   %eax,%eax
  801112:	78 3b                	js     80114f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801114:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801117:	89 c2                	mov    %eax,%edx
  801119:	c1 ea 0c             	shr    $0xc,%edx
  80111c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801123:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801129:	89 54 24 10          	mov    %edx,0x10(%esp)
  80112d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801131:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801138:	00 
  801139:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801144:	e8 a4 fa ff ff       	call   800bed <sys_page_map>
  801149:	89 c3                	mov    %eax,%ebx
  80114b:	85 c0                	test   %eax,%eax
  80114d:	79 25                	jns    801174 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80114f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80115a:	e8 e1 fa ff ff       	call   800c40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801162:	89 44 24 04          	mov    %eax,0x4(%esp)
  801166:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116d:	e8 ce fa ff ff       	call   800c40 <sys_page_unmap>
	return r;
  801172:	eb 02                	jmp    801176 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801174:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801176:	89 d8                	mov    %ebx,%eax
  801178:	83 c4 4c             	add    $0x4c,%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 24             	sub    $0x24,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801191:	89 1c 24             	mov    %ebx,(%esp)
  801194:	e8 49 fd ff ff       	call   800ee2 <fd_lookup>
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 6d                	js     80120a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a7:	8b 00                	mov    (%eax),%eax
  8011a9:	89 04 24             	mov    %eax,(%esp)
  8011ac:	e8 87 fd ff ff       	call   800f38 <dev_lookup>
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 55                	js     80120a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b8:	8b 50 08             	mov    0x8(%eax),%edx
  8011bb:	83 e2 03             	and    $0x3,%edx
  8011be:	83 fa 01             	cmp    $0x1,%edx
  8011c1:	75 23                	jne    8011e6 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c3:	a1 08 50 80 00       	mov    0x805008,%eax
  8011c8:	8b 40 48             	mov    0x48(%eax),%eax
  8011cb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d3:	c7 04 24 51 2f 80 00 	movl   $0x802f51,(%esp)
  8011da:	e8 1d f0 ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  8011df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e4:	eb 24                	jmp    80120a <read+0x8a>
	}
	if (!dev->dev_read)
  8011e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e9:	8b 52 08             	mov    0x8(%edx),%edx
  8011ec:	85 d2                	test   %edx,%edx
  8011ee:	74 15                	je     801205 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011fe:	89 04 24             	mov    %eax,(%esp)
  801201:	ff d2                	call   *%edx
  801203:	eb 05                	jmp    80120a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801205:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80120a:	83 c4 24             	add    $0x24,%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 1c             	sub    $0x1c,%esp
  801219:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80121f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801224:	eb 23                	jmp    801249 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801226:	89 f0                	mov    %esi,%eax
  801228:	29 d8                	sub    %ebx,%eax
  80122a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80122e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801231:	01 d8                	add    %ebx,%eax
  801233:	89 44 24 04          	mov    %eax,0x4(%esp)
  801237:	89 3c 24             	mov    %edi,(%esp)
  80123a:	e8 41 ff ff ff       	call   801180 <read>
		if (m < 0)
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 10                	js     801253 <readn+0x43>
			return m;
		if (m == 0)
  801243:	85 c0                	test   %eax,%eax
  801245:	74 0a                	je     801251 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801247:	01 c3                	add    %eax,%ebx
  801249:	39 f3                	cmp    %esi,%ebx
  80124b:	72 d9                	jb     801226 <readn+0x16>
  80124d:	89 d8                	mov    %ebx,%eax
  80124f:	eb 02                	jmp    801253 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801251:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801253:	83 c4 1c             	add    $0x1c,%esp
  801256:	5b                   	pop    %ebx
  801257:	5e                   	pop    %esi
  801258:	5f                   	pop    %edi
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	53                   	push   %ebx
  80125f:	83 ec 24             	sub    $0x24,%esp
  801262:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801265:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126c:	89 1c 24             	mov    %ebx,(%esp)
  80126f:	e8 6e fc ff ff       	call   800ee2 <fd_lookup>
  801274:	85 c0                	test   %eax,%eax
  801276:	78 68                	js     8012e0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801282:	8b 00                	mov    (%eax),%eax
  801284:	89 04 24             	mov    %eax,(%esp)
  801287:	e8 ac fc ff ff       	call   800f38 <dev_lookup>
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 50                	js     8012e0 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801293:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801297:	75 23                	jne    8012bc <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801299:	a1 08 50 80 00       	mov    0x805008,%eax
  80129e:	8b 40 48             	mov    0x48(%eax),%eax
  8012a1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a9:	c7 04 24 6d 2f 80 00 	movl   $0x802f6d,(%esp)
  8012b0:	e8 47 ef ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  8012b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ba:	eb 24                	jmp    8012e0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8012c2:	85 d2                	test   %edx,%edx
  8012c4:	74 15                	je     8012db <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012d4:	89 04 24             	mov    %eax,(%esp)
  8012d7:	ff d2                	call   *%edx
  8012d9:	eb 05                	jmp    8012e0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012e0:	83 c4 24             	add    $0x24,%esp
  8012e3:	5b                   	pop    %ebx
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	89 04 24             	mov    %eax,(%esp)
  8012f9:	e8 e4 fb ff ff       	call   800ee2 <fd_lookup>
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 0e                	js     801310 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801302:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801305:	8b 55 0c             	mov    0xc(%ebp),%edx
  801308:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	53                   	push   %ebx
  801316:	83 ec 24             	sub    $0x24,%esp
  801319:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801323:	89 1c 24             	mov    %ebx,(%esp)
  801326:	e8 b7 fb ff ff       	call   800ee2 <fd_lookup>
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 61                	js     801390 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801332:	89 44 24 04          	mov    %eax,0x4(%esp)
  801336:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801339:	8b 00                	mov    (%eax),%eax
  80133b:	89 04 24             	mov    %eax,(%esp)
  80133e:	e8 f5 fb ff ff       	call   800f38 <dev_lookup>
  801343:	85 c0                	test   %eax,%eax
  801345:	78 49                	js     801390 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801347:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80134e:	75 23                	jne    801373 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801350:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801355:	8b 40 48             	mov    0x48(%eax),%eax
  801358:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80135c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801360:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  801367:	e8 90 ee ff ff       	call   8001fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80136c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801371:	eb 1d                	jmp    801390 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801373:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801376:	8b 52 18             	mov    0x18(%edx),%edx
  801379:	85 d2                	test   %edx,%edx
  80137b:	74 0e                	je     80138b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80137d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801380:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801384:	89 04 24             	mov    %eax,(%esp)
  801387:	ff d2                	call   *%edx
  801389:	eb 05                	jmp    801390 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80138b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801390:	83 c4 24             	add    $0x24,%esp
  801393:	5b                   	pop    %ebx
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	53                   	push   %ebx
  80139a:	83 ec 24             	sub    $0x24,%esp
  80139d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013aa:	89 04 24             	mov    %eax,(%esp)
  8013ad:	e8 30 fb ff ff       	call   800ee2 <fd_lookup>
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 52                	js     801408 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c0:	8b 00                	mov    (%eax),%eax
  8013c2:	89 04 24             	mov    %eax,(%esp)
  8013c5:	e8 6e fb ff ff       	call   800f38 <dev_lookup>
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 3a                	js     801408 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8013ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013d5:	74 2c                	je     801403 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013da:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e1:	00 00 00 
	stat->st_isdir = 0;
  8013e4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013eb:	00 00 00 
	stat->st_dev = dev;
  8013ee:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fb:	89 14 24             	mov    %edx,(%esp)
  8013fe:	ff 50 14             	call   *0x14(%eax)
  801401:	eb 05                	jmp    801408 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801403:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801408:	83 c4 24             	add    $0x24,%esp
  80140b:	5b                   	pop    %ebx
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	56                   	push   %esi
  801412:	53                   	push   %ebx
  801413:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801416:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80141d:	00 
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	89 04 24             	mov    %eax,(%esp)
  801424:	e8 2a 02 00 00       	call   801653 <open>
  801429:	89 c3                	mov    %eax,%ebx
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 1b                	js     80144a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80142f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801432:	89 44 24 04          	mov    %eax,0x4(%esp)
  801436:	89 1c 24             	mov    %ebx,(%esp)
  801439:	e8 58 ff ff ff       	call   801396 <fstat>
  80143e:	89 c6                	mov    %eax,%esi
	close(fd);
  801440:	89 1c 24             	mov    %ebx,(%esp)
  801443:	e8 d2 fb ff ff       	call   80101a <close>
	return r;
  801448:	89 f3                	mov    %esi,%ebx
}
  80144a:	89 d8                	mov    %ebx,%eax
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    
	...

00801454 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	56                   	push   %esi
  801458:	53                   	push   %ebx
  801459:	83 ec 10             	sub    $0x10,%esp
  80145c:	89 c3                	mov    %eax,%ebx
  80145e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801460:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801467:	75 11                	jne    80147a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801469:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801470:	e8 f6 13 00 00       	call   80286b <ipc_find_env>
  801475:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80147a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801481:	00 
  801482:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801489:	00 
  80148a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80148e:	a1 00 50 80 00       	mov    0x805000,%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 4d 13 00 00       	call   8027e8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80149b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014a2:	00 
  8014a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ae:	e8 c5 12 00 00       	call   802778 <ipc_recv>
}
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    

008014ba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8014cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ce:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d8:	b8 02 00 00 00       	mov    $0x2,%eax
  8014dd:	e8 72 ff ff ff       	call   801454 <fsipc>
}
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f0:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ff:	e8 50 ff ff ff       	call   801454 <fsipc>
}
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	53                   	push   %ebx
  80150a:	83 ec 14             	sub    $0x14,%esp
  80150d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801510:	8b 45 08             	mov    0x8(%ebp),%eax
  801513:	8b 40 0c             	mov    0xc(%eax),%eax
  801516:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80151b:	ba 00 00 00 00       	mov    $0x0,%edx
  801520:	b8 05 00 00 00       	mov    $0x5,%eax
  801525:	e8 2a ff ff ff       	call   801454 <fsipc>
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 2b                	js     801559 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80152e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801535:	00 
  801536:	89 1c 24             	mov    %ebx,(%esp)
  801539:	e8 69 f2 ff ff       	call   8007a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80153e:	a1 80 60 80 00       	mov    0x806080,%eax
  801543:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801549:	a1 84 60 80 00       	mov    0x806084,%eax
  80154e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801554:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801559:	83 c4 14             	add    $0x14,%esp
  80155c:	5b                   	pop    %ebx
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    

0080155f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	83 ec 18             	sub    $0x18,%esp
  801565:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801568:	8b 55 08             	mov    0x8(%ebp),%edx
  80156b:	8b 52 0c             	mov    0xc(%edx),%edx
  80156e:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801574:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801579:	89 c2                	mov    %eax,%edx
  80157b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801580:	76 05                	jbe    801587 <devfile_write+0x28>
  801582:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801587:	89 54 24 08          	mov    %edx,0x8(%esp)
  80158b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801592:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801599:	e8 ec f3 ff ff       	call   80098a <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80159e:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a8:	e8 a7 fe ff ff       	call   801454 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	56                   	push   %esi
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 10             	sub    $0x10,%esp
  8015b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8015c5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8015d5:	e8 7a fe ff ff       	call   801454 <fsipc>
  8015da:	89 c3                	mov    %eax,%ebx
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 6a                	js     80164a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8015e0:	39 c6                	cmp    %eax,%esi
  8015e2:	73 24                	jae    801608 <devfile_read+0x59>
  8015e4:	c7 44 24 0c a0 2f 80 	movl   $0x802fa0,0xc(%esp)
  8015eb:	00 
  8015ec:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  8015f3:	00 
  8015f4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8015fb:	00 
  8015fc:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  801603:	e8 fc ea ff ff       	call   800104 <_panic>
	assert(r <= PGSIZE);
  801608:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80160d:	7e 24                	jle    801633 <devfile_read+0x84>
  80160f:	c7 44 24 0c c7 2f 80 	movl   $0x802fc7,0xc(%esp)
  801616:	00 
  801617:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  80161e:	00 
  80161f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801626:	00 
  801627:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  80162e:	e8 d1 ea ff ff       	call   800104 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801633:	89 44 24 08          	mov    %eax,0x8(%esp)
  801637:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80163e:	00 
  80163f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801642:	89 04 24             	mov    %eax,(%esp)
  801645:	e8 d6 f2 ff ff       	call   800920 <memmove>
	return r;
}
  80164a:	89 d8                	mov    %ebx,%eax
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	56                   	push   %esi
  801657:	53                   	push   %ebx
  801658:	83 ec 20             	sub    $0x20,%esp
  80165b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80165e:	89 34 24             	mov    %esi,(%esp)
  801661:	e8 0e f1 ff ff       	call   800774 <strlen>
  801666:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80166b:	7f 60                	jg     8016cd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80166d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801670:	89 04 24             	mov    %eax,(%esp)
  801673:	e8 17 f8 ff ff       	call   800e8f <fd_alloc>
  801678:	89 c3                	mov    %eax,%ebx
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 54                	js     8016d2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80167e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801682:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801689:	e8 19 f1 ff ff       	call   8007a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80168e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801691:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801696:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801699:	b8 01 00 00 00       	mov    $0x1,%eax
  80169e:	e8 b1 fd ff ff       	call   801454 <fsipc>
  8016a3:	89 c3                	mov    %eax,%ebx
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	79 15                	jns    8016be <open+0x6b>
		fd_close(fd, 0);
  8016a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016b0:	00 
  8016b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b4:	89 04 24             	mov    %eax,(%esp)
  8016b7:	e8 d6 f8 ff ff       	call   800f92 <fd_close>
		return r;
  8016bc:	eb 14                	jmp    8016d2 <open+0x7f>
	}

	return fd2num(fd);
  8016be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c1:	89 04 24             	mov    %eax,(%esp)
  8016c4:	e8 9b f7 ff ff       	call   800e64 <fd2num>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	eb 05                	jmp    8016d2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016cd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016d2:	89 d8                	mov    %ebx,%eax
  8016d4:	83 c4 20             	add    $0x20,%esp
  8016d7:	5b                   	pop    %ebx
  8016d8:	5e                   	pop    %esi
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8016eb:	e8 64 fd ff ff       	call   801454 <fsipc>
}
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    
	...

008016f4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	57                   	push   %edi
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801700:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801707:	00 
  801708:	8b 45 08             	mov    0x8(%ebp),%eax
  80170b:	89 04 24             	mov    %eax,(%esp)
  80170e:	e8 40 ff ff ff       	call   801653 <open>
  801713:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801719:	85 c0                	test   %eax,%eax
  80171b:	0f 88 a9 05 00 00    	js     801cca <spawn+0x5d6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801721:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801728:	00 
  801729:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80172f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801733:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801739:	89 04 24             	mov    %eax,(%esp)
  80173c:	e8 cf fa ff ff       	call   801210 <readn>
  801741:	3d 00 02 00 00       	cmp    $0x200,%eax
  801746:	75 0c                	jne    801754 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801748:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80174f:	45 4c 46 
  801752:	74 3b                	je     80178f <spawn+0x9b>
		close(fd);
  801754:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80175a:	89 04 24             	mov    %eax,(%esp)
  80175d:	e8 b8 f8 ff ff       	call   80101a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801762:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801769:	46 
  80176a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801770:	89 44 24 04          	mov    %eax,0x4(%esp)
  801774:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  80177b:	e8 7c ea ff ff       	call   8001fc <cprintf>
		return -E_NOT_EXEC;
  801780:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  801787:	ff ff ff 
  80178a:	e9 47 05 00 00       	jmp    801cd6 <spawn+0x5e2>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80178f:	ba 07 00 00 00       	mov    $0x7,%edx
  801794:	89 d0                	mov    %edx,%eax
  801796:	cd 30                	int    $0x30
  801798:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80179e:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	0f 88 2a 05 00 00    	js     801cd6 <spawn+0x5e2>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8017ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8017b8:	c1 e0 07             	shl    $0x7,%eax
  8017bb:	29 d0                	sub    %edx,%eax
  8017bd:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  8017c3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8017c9:	b9 11 00 00 00       	mov    $0x11,%ecx
  8017ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8017d0:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8017d6:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8017dc:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8017e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8017e9:	eb 0d                	jmp    8017f8 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8017eb:	89 04 24             	mov    %eax,(%esp)
  8017ee:	e8 81 ef ff ff       	call   800774 <strlen>
  8017f3:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8017f7:	46                   	inc    %esi
  8017f8:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8017fa:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801801:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801804:	85 c0                	test   %eax,%eax
  801806:	75 e3                	jne    8017eb <spawn+0xf7>
  801808:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80180e:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801814:	bf 00 10 40 00       	mov    $0x401000,%edi
  801819:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80181b:	89 f8                	mov    %edi,%eax
  80181d:	83 e0 fc             	and    $0xfffffffc,%eax
  801820:	f7 d2                	not    %edx
  801822:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801825:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80182b:	89 d0                	mov    %edx,%eax
  80182d:	83 e8 08             	sub    $0x8,%eax
  801830:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801835:	0f 86 ac 04 00 00    	jbe    801ce7 <spawn+0x5f3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80183b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801842:	00 
  801843:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80184a:	00 
  80184b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801852:	e8 42 f3 ff ff       	call   800b99 <sys_page_alloc>
  801857:	85 c0                	test   %eax,%eax
  801859:	0f 88 8d 04 00 00    	js     801cec <spawn+0x5f8>
  80185f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801864:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  80186a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80186d:	eb 2e                	jmp    80189d <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80186f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801875:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80187b:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80187e:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801881:	89 44 24 04          	mov    %eax,0x4(%esp)
  801885:	89 3c 24             	mov    %edi,(%esp)
  801888:	e8 1a ef ff ff       	call   8007a7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80188d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801890:	89 04 24             	mov    %eax,(%esp)
  801893:	e8 dc ee ff ff       	call   800774 <strlen>
  801898:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80189c:	43                   	inc    %ebx
  80189d:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8018a3:	7c ca                	jl     80186f <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8018a5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8018ab:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8018b1:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8018b8:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8018be:	74 24                	je     8018e4 <spawn+0x1f0>
  8018c0:	c7 44 24 0c 5c 30 80 	movl   $0x80305c,0xc(%esp)
  8018c7:	00 
  8018c8:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  8018cf:	00 
  8018d0:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  8018d7:	00 
  8018d8:	c7 04 24 ed 2f 80 00 	movl   $0x802fed,(%esp)
  8018df:	e8 20 e8 ff ff       	call   800104 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8018e4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8018ea:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8018ef:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8018f5:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8018f8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018fe:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801901:	89 d0                	mov    %edx,%eax
  801903:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801908:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80190e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801915:	00 
  801916:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  80191d:	ee 
  80191e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801924:	89 44 24 08          	mov    %eax,0x8(%esp)
  801928:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80192f:	00 
  801930:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801937:	e8 b1 f2 ff ff       	call   800bed <sys_page_map>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 1a                	js     80195c <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801942:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801949:	00 
  80194a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801951:	e8 ea f2 ff ff       	call   800c40 <sys_page_unmap>
  801956:	89 c3                	mov    %eax,%ebx
  801958:	85 c0                	test   %eax,%eax
  80195a:	79 1f                	jns    80197b <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80195c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801963:	00 
  801964:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196b:	e8 d0 f2 ff ff       	call   800c40 <sys_page_unmap>
	return r;
  801970:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801976:	e9 5b 03 00 00       	jmp    801cd6 <spawn+0x5e2>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80197b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801981:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801987:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80198d:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801994:	00 00 00 
  801997:	e9 bb 01 00 00       	jmp    801b57 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  80199c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019a2:	83 38 01             	cmpl   $0x1,(%eax)
  8019a5:	0f 85 9f 01 00 00    	jne    801b4a <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8019ab:	89 c2                	mov    %eax,%edx
  8019ad:	8b 40 18             	mov    0x18(%eax),%eax
  8019b0:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8019b3:	83 f8 01             	cmp    $0x1,%eax
  8019b6:	19 c0                	sbb    %eax,%eax
  8019b8:	83 e0 fe             	and    $0xfffffffe,%eax
  8019bb:	83 c0 07             	add    $0x7,%eax
  8019be:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8019c4:	8b 52 04             	mov    0x4(%edx),%edx
  8019c7:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  8019cd:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019d3:	8b 40 10             	mov    0x10(%eax),%eax
  8019d6:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8019dc:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8019e2:	8b 52 14             	mov    0x14(%edx),%edx
  8019e5:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8019eb:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019f1:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8019f4:	89 f8                	mov    %edi,%eax
  8019f6:	25 ff 0f 00 00       	and    $0xfff,%eax
  8019fb:	74 16                	je     801a13 <spawn+0x31f>
		va -= i;
  8019fd:	29 c7                	sub    %eax,%edi
		memsz += i;
  8019ff:	01 c2                	add    %eax,%edx
  801a01:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801a07:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801a0d:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a13:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a18:	e9 1f 01 00 00       	jmp    801b3c <spawn+0x448>
		if (i >= filesz) {
  801a1d:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  801a23:	72 2b                	jb     801a50 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801a25:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801a2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a2f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a33:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a39:	89 04 24             	mov    %eax,(%esp)
  801a3c:	e8 58 f1 ff ff       	call   800b99 <sys_page_alloc>
  801a41:	85 c0                	test   %eax,%eax
  801a43:	0f 89 e7 00 00 00    	jns    801b30 <spawn+0x43c>
  801a49:	89 c6                	mov    %eax,%esi
  801a4b:	e9 56 02 00 00       	jmp    801ca6 <spawn+0x5b2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a50:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a57:	00 
  801a58:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a5f:	00 
  801a60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a67:	e8 2d f1 ff ff       	call   800b99 <sys_page_alloc>
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	0f 88 28 02 00 00    	js     801c9c <spawn+0x5a8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801a74:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801a7a:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a80:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a86:	89 04 24             	mov    %eax,(%esp)
  801a89:	e8 58 f8 ff ff       	call   8012e6 <seek>
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	0f 88 0a 02 00 00    	js     801ca0 <spawn+0x5ac>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801a96:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a9c:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a9e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aa3:	76 05                	jbe    801aaa <spawn+0x3b6>
  801aa5:	b8 00 10 00 00       	mov    $0x1000,%eax
  801aaa:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aae:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ab5:	00 
  801ab6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801abc:	89 04 24             	mov    %eax,(%esp)
  801abf:	e8 4c f7 ff ff       	call   801210 <readn>
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	0f 88 d8 01 00 00    	js     801ca4 <spawn+0x5b0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801acc:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801ad2:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ad6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ada:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ae0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801aeb:	00 
  801aec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af3:	e8 f5 f0 ff ff       	call   800bed <sys_page_map>
  801af8:	85 c0                	test   %eax,%eax
  801afa:	79 20                	jns    801b1c <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801afc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b00:	c7 44 24 08 f9 2f 80 	movl   $0x802ff9,0x8(%esp)
  801b07:	00 
  801b08:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801b0f:	00 
  801b10:	c7 04 24 ed 2f 80 00 	movl   $0x802fed,(%esp)
  801b17:	e8 e8 e5 ff ff       	call   800104 <_panic>
			sys_page_unmap(0, UTEMP);
  801b1c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b23:	00 
  801b24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2b:	e8 10 f1 ff ff       	call   800c40 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b30:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b36:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801b3c:	89 de                	mov    %ebx,%esi
  801b3e:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801b44:	0f 82 d3 fe ff ff    	jb     801a1d <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b4a:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801b50:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801b57:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801b5e:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801b64:	0f 8c 32 fe ff ff    	jl     80199c <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801b6a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b70:	89 04 24             	mov    %eax,(%esp)
  801b73:	e8 a2 f4 ff ff       	call   80101a <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  801b78:	be 00 00 00 00       	mov    $0x0,%esi
  801b7d:	eb 0c                	jmp    801b8b <spawn+0x497>
	{
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  801b7f:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801b85:	0f 84 91 00 00 00    	je     801c1c <spawn+0x528>
  801b8b:	89 f0                	mov    %esi,%eax
  801b8d:	c1 e8 16             	shr    $0x16,%eax
  801b90:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b97:	a8 01                	test   $0x1,%al
  801b99:	74 6f                	je     801c0a <spawn+0x516>
  801b9b:	89 f0                	mov    %esi,%eax
  801b9d:	c1 e8 0c             	shr    $0xc,%eax
  801ba0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ba7:	f6 c2 01             	test   $0x1,%dl
  801baa:	74 5e                	je     801c0a <spawn+0x516>
		{
			continue;
		}
		if ((uvpt[PGNUM(addr)] & PTE_SHARE))
  801bac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801bb3:	f6 c6 04             	test   $0x4,%dh
  801bb6:	74 52                	je     801c0a <spawn+0x516>
		{
			if ((e = sys_page_map(0, (void *)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  801bb8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bbf:	25 07 0e 00 00       	and    $0xe07,%eax
  801bc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801bc8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bcc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bd2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be1:	e8 07 f0 ff ff       	call   800bed <sys_page_map>
  801be6:	85 c0                	test   %eax,%eax
  801be8:	79 20                	jns    801c0a <spawn+0x516>
			{
				panic("duppage error: %e", e);
  801bea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bee:	c7 44 24 08 16 30 80 	movl   $0x803016,0x8(%esp)
  801bf5:	00 
  801bf6:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  801bfd:	00 
  801bfe:	c7 04 24 ed 2f 80 00 	movl   $0x802fed,(%esp)
  801c05:	e8 fa e4 ff ff       	call   800104 <_panic>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  801c0a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c10:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  801c16:	0f 85 63 ff ff ff    	jne    801b7f <spawn+0x48b>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801c1c:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801c23:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801c26:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c30:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c36:	89 04 24             	mov    %eax,(%esp)
  801c39:	e8 a8 f0 ff ff       	call   800ce6 <sys_env_set_trapframe>
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	79 20                	jns    801c62 <spawn+0x56e>
		panic("sys_env_set_trapframe: %e", r);
  801c42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c46:	c7 44 24 08 28 30 80 	movl   $0x803028,0x8(%esp)
  801c4d:	00 
  801c4e:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801c55:	00 
  801c56:	c7 04 24 ed 2f 80 00 	movl   $0x802fed,(%esp)
  801c5d:	e8 a2 e4 ff ff       	call   800104 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801c62:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801c69:	00 
  801c6a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c70:	89 04 24             	mov    %eax,(%esp)
  801c73:	e8 1b f0 ff ff       	call   800c93 <sys_env_set_status>
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	79 5a                	jns    801cd6 <spawn+0x5e2>
		panic("sys_env_set_status: %e", r);
  801c7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c80:	c7 44 24 08 42 30 80 	movl   $0x803042,0x8(%esp)
  801c87:	00 
  801c88:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801c8f:	00 
  801c90:	c7 04 24 ed 2f 80 00 	movl   $0x802fed,(%esp)
  801c97:	e8 68 e4 ff ff       	call   800104 <_panic>
  801c9c:	89 c6                	mov    %eax,%esi
  801c9e:	eb 06                	jmp    801ca6 <spawn+0x5b2>
  801ca0:	89 c6                	mov    %eax,%esi
  801ca2:	eb 02                	jmp    801ca6 <spawn+0x5b2>
  801ca4:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801ca6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cac:	89 04 24             	mov    %eax,(%esp)
  801caf:	e8 55 ee ff ff       	call   800b09 <sys_env_destroy>
	close(fd);
  801cb4:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801cba:	89 04 24             	mov    %eax,(%esp)
  801cbd:	e8 58 f3 ff ff       	call   80101a <close>
	return r;
  801cc2:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  801cc8:	eb 0c                	jmp    801cd6 <spawn+0x5e2>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801cca:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801cd0:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801cd6:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801cdc:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801ce2:	5b                   	pop    %ebx
  801ce3:	5e                   	pop    %esi
  801ce4:	5f                   	pop    %edi
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ce7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801cec:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801cf2:	eb e2                	jmp    801cd6 <spawn+0x5e2>

00801cf4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	57                   	push   %edi
  801cf8:	56                   	push   %esi
  801cf9:	53                   	push   %ebx
  801cfa:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801cfd:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d00:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d05:	eb 03                	jmp    801d0a <spawnl+0x16>
		argc++;
  801d07:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d08:	89 d0                	mov    %edx,%eax
  801d0a:	8d 50 04             	lea    0x4(%eax),%edx
  801d0d:	83 38 00             	cmpl   $0x0,(%eax)
  801d10:	75 f5                	jne    801d07 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d12:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801d19:	83 e0 f0             	and    $0xfffffff0,%eax
  801d1c:	29 c4                	sub    %eax,%esp
  801d1e:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801d22:	83 e7 f0             	and    $0xfffffff0,%edi
  801d25:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2a:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801d2c:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801d33:	00 

	va_start(vl, arg0);
  801d34:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801d37:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3c:	eb 09                	jmp    801d47 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801d3e:	40                   	inc    %eax
  801d3f:	8b 1a                	mov    (%edx),%ebx
  801d41:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801d44:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d47:	39 c8                	cmp    %ecx,%eax
  801d49:	75 f3                	jne    801d3e <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801d4b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d52:	89 04 24             	mov    %eax,(%esp)
  801d55:	e8 9a f9 ff ff       	call   8016f4 <spawn>
}
  801d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
	...

00801d64 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d6a:	c7 44 24 04 84 30 80 	movl   $0x803084,0x4(%esp)
  801d71:	00 
  801d72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d75:	89 04 24             	mov    %eax,(%esp)
  801d78:	e8 2a ea ff ff       	call   8007a7 <strcpy>
	return 0;
}
  801d7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d82:	c9                   	leave  
  801d83:	c3                   	ret    

00801d84 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	53                   	push   %ebx
  801d88:	83 ec 14             	sub    $0x14,%esp
  801d8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d8e:	89 1c 24             	mov    %ebx,(%esp)
  801d91:	e8 1a 0b 00 00       	call   8028b0 <pageref>
  801d96:	83 f8 01             	cmp    $0x1,%eax
  801d99:	75 0d                	jne    801da8 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801d9b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d9e:	89 04 24             	mov    %eax,(%esp)
  801da1:	e8 1f 03 00 00       	call   8020c5 <nsipc_close>
  801da6:	eb 05                	jmp    801dad <devsock_close+0x29>
	else
		return 0;
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dad:	83 c4 14             	add    $0x14,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    

00801db3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801db9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dc0:	00 
  801dc1:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd5:	89 04 24             	mov    %eax,(%esp)
  801dd8:	e8 e3 03 00 00       	call   8021c0 <nsipc_send>
}
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    

00801ddf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801de5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dec:	00 
  801ded:	8b 45 10             	mov    0x10(%ebp),%eax
  801df0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	8b 40 0c             	mov    0xc(%eax),%eax
  801e01:	89 04 24             	mov    %eax,(%esp)
  801e04:	e8 37 03 00 00       	call   802140 <nsipc_recv>
}
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    

00801e0b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	56                   	push   %esi
  801e0f:	53                   	push   %ebx
  801e10:	83 ec 20             	sub    $0x20,%esp
  801e13:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e18:	89 04 24             	mov    %eax,(%esp)
  801e1b:	e8 6f f0 ff ff       	call   800e8f <fd_alloc>
  801e20:	89 c3                	mov    %eax,%ebx
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 21                	js     801e47 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e2d:	00 
  801e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e3c:	e8 58 ed ff ff       	call   800b99 <sys_page_alloc>
  801e41:	89 c3                	mov    %eax,%ebx
  801e43:	85 c0                	test   %eax,%eax
  801e45:	79 0a                	jns    801e51 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801e47:	89 34 24             	mov    %esi,(%esp)
  801e4a:	e8 76 02 00 00       	call   8020c5 <nsipc_close>
		return r;
  801e4f:	eb 22                	jmp    801e73 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e51:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e66:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e69:	89 04 24             	mov    %eax,(%esp)
  801e6c:	e8 f3 ef ff ff       	call   800e64 <fd2num>
  801e71:	89 c3                	mov    %eax,%ebx
}
  801e73:	89 d8                	mov    %ebx,%eax
  801e75:	83 c4 20             	add    $0x20,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e82:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e85:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e89:	89 04 24             	mov    %eax,(%esp)
  801e8c:	e8 51 f0 ff ff       	call   800ee2 <fd_lookup>
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 17                	js     801eac <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e98:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801e9e:	39 10                	cmp    %edx,(%eax)
  801ea0:	75 05                	jne    801ea7 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ea2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ea5:	eb 05                	jmp    801eac <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ea7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	e8 c0 ff ff ff       	call   801e7c <fd2sockid>
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 1f                	js     801edf <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ec0:	8b 55 10             	mov    0x10(%ebp),%edx
  801ec3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ec7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eca:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ece:	89 04 24             	mov    %eax,(%esp)
  801ed1:	e8 38 01 00 00       	call   80200e <nsipc_accept>
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 05                	js     801edf <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801eda:	e8 2c ff ff ff       	call   801e0b <alloc_sockfd>
}
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    

00801ee1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eea:	e8 8d ff ff ff       	call   801e7c <fd2sockid>
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	78 16                	js     801f09 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801ef3:	8b 55 10             	mov    0x10(%ebp),%edx
  801ef6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801efa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801efd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f01:	89 04 24             	mov    %eax,(%esp)
  801f04:	e8 5b 01 00 00       	call   802064 <nsipc_bind>
}
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <shutdown>:

int
shutdown(int s, int how)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f11:	8b 45 08             	mov    0x8(%ebp),%eax
  801f14:	e8 63 ff ff ff       	call   801e7c <fd2sockid>
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	78 0f                	js     801f2c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f20:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f24:	89 04 24             	mov    %eax,(%esp)
  801f27:	e8 77 01 00 00       	call   8020a3 <nsipc_shutdown>
}
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f34:	8b 45 08             	mov    0x8(%ebp),%eax
  801f37:	e8 40 ff ff ff       	call   801e7c <fd2sockid>
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 16                	js     801f56 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801f40:	8b 55 10             	mov    0x10(%ebp),%edx
  801f43:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f4e:	89 04 24             	mov    %eax,(%esp)
  801f51:	e8 89 01 00 00       	call   8020df <nsipc_connect>
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    

00801f58 <listen>:

int
listen(int s, int backlog)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f61:	e8 16 ff ff ff       	call   801e7c <fd2sockid>
  801f66:	85 c0                	test   %eax,%eax
  801f68:	78 0f                	js     801f79 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f71:	89 04 24             	mov    %eax,(%esp)
  801f74:	e8 a5 01 00 00       	call   80211e <nsipc_listen>
}
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f81:	8b 45 10             	mov    0x10(%ebp),%eax
  801f84:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f92:	89 04 24             	mov    %eax,(%esp)
  801f95:	e8 99 02 00 00       	call   802233 <nsipc_socket>
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	78 05                	js     801fa3 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801f9e:	e8 68 fe ff ff       	call   801e0b <alloc_sockfd>
}
  801fa3:	c9                   	leave  
  801fa4:	c3                   	ret    
  801fa5:	00 00                	add    %al,(%eax)
	...

00801fa8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	53                   	push   %ebx
  801fac:	83 ec 14             	sub    $0x14,%esp
  801faf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fb1:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801fb8:	75 11                	jne    801fcb <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fba:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801fc1:	e8 a5 08 00 00       	call   80286b <ipc_find_env>
  801fc6:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fcb:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801fd2:	00 
  801fd3:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801fda:	00 
  801fdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fdf:	a1 04 50 80 00       	mov    0x805004,%eax
  801fe4:	89 04 24             	mov    %eax,(%esp)
  801fe7:	e8 fc 07 00 00       	call   8027e8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ff3:	00 
  801ff4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ffb:	00 
  801ffc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802003:	e8 70 07 00 00       	call   802778 <ipc_recv>
}
  802008:	83 c4 14             	add    $0x14,%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	56                   	push   %esi
  802012:	53                   	push   %ebx
  802013:	83 ec 10             	sub    $0x10,%esp
  802016:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802021:	8b 06                	mov    (%esi),%eax
  802023:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802028:	b8 01 00 00 00       	mov    $0x1,%eax
  80202d:	e8 76 ff ff ff       	call   801fa8 <nsipc>
  802032:	89 c3                	mov    %eax,%ebx
  802034:	85 c0                	test   %eax,%eax
  802036:	78 23                	js     80205b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802038:	a1 10 70 80 00       	mov    0x807010,%eax
  80203d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802041:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802048:	00 
  802049:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204c:	89 04 24             	mov    %eax,(%esp)
  80204f:	e8 cc e8 ff ff       	call   800920 <memmove>
		*addrlen = ret->ret_addrlen;
  802054:	a1 10 70 80 00       	mov    0x807010,%eax
  802059:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  80205b:	89 d8                	mov    %ebx,%eax
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	5b                   	pop    %ebx
  802061:	5e                   	pop    %esi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    

00802064 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	53                   	push   %ebx
  802068:	83 ec 14             	sub    $0x14,%esp
  80206b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80206e:	8b 45 08             	mov    0x8(%ebp),%eax
  802071:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802076:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802081:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802088:	e8 93 e8 ff ff       	call   800920 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80208d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802093:	b8 02 00 00 00       	mov    $0x2,%eax
  802098:	e8 0b ff ff ff       	call   801fa8 <nsipc>
}
  80209d:	83 c4 14             	add    $0x14,%esp
  8020a0:	5b                   	pop    %ebx
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    

008020a3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8020a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ac:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8020b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8020b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8020be:	e8 e5 fe ff ff       	call   801fa8 <nsipc>
}
  8020c3:	c9                   	leave  
  8020c4:	c3                   	ret    

008020c5 <nsipc_close>:

int
nsipc_close(int s)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ce:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8020d3:	b8 04 00 00 00       	mov    $0x4,%eax
  8020d8:	e8 cb fe ff ff       	call   801fa8 <nsipc>
}
  8020dd:	c9                   	leave  
  8020de:	c3                   	ret    

008020df <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	53                   	push   %ebx
  8020e3:	83 ec 14             	sub    $0x14,%esp
  8020e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ec:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fc:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802103:	e8 18 e8 ff ff       	call   800920 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802108:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80210e:	b8 05 00 00 00       	mov    $0x5,%eax
  802113:	e8 90 fe ff ff       	call   801fa8 <nsipc>
}
  802118:	83 c4 14             	add    $0x14,%esp
  80211b:	5b                   	pop    %ebx
  80211c:	5d                   	pop    %ebp
  80211d:	c3                   	ret    

0080211e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802124:	8b 45 08             	mov    0x8(%ebp),%eax
  802127:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80212c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802134:	b8 06 00 00 00       	mov    $0x6,%eax
  802139:	e8 6a fe ff ff       	call   801fa8 <nsipc>
}
  80213e:	c9                   	leave  
  80213f:	c3                   	ret    

00802140 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	56                   	push   %esi
  802144:	53                   	push   %ebx
  802145:	83 ec 10             	sub    $0x10,%esp
  802148:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80214b:	8b 45 08             	mov    0x8(%ebp),%eax
  80214e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802153:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802159:	8b 45 14             	mov    0x14(%ebp),%eax
  80215c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802161:	b8 07 00 00 00       	mov    $0x7,%eax
  802166:	e8 3d fe ff ff       	call   801fa8 <nsipc>
  80216b:	89 c3                	mov    %eax,%ebx
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 46                	js     8021b7 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802171:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802176:	7f 04                	jg     80217c <nsipc_recv+0x3c>
  802178:	39 c6                	cmp    %eax,%esi
  80217a:	7d 24                	jge    8021a0 <nsipc_recv+0x60>
  80217c:	c7 44 24 0c 90 30 80 	movl   $0x803090,0xc(%esp)
  802183:	00 
  802184:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  80218b:	00 
  80218c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802193:	00 
  802194:	c7 04 24 a5 30 80 00 	movl   $0x8030a5,(%esp)
  80219b:	e8 64 df ff ff       	call   800104 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8021a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021a4:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8021ab:	00 
  8021ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021af:	89 04 24             	mov    %eax,(%esp)
  8021b2:	e8 69 e7 ff ff       	call   800920 <memmove>
	}

	return r;
}
  8021b7:	89 d8                	mov    %ebx,%eax
  8021b9:	83 c4 10             	add    $0x10,%esp
  8021bc:	5b                   	pop    %ebx
  8021bd:	5e                   	pop    %esi
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    

008021c0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 14             	sub    $0x14,%esp
  8021c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cd:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021d2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021d8:	7e 24                	jle    8021fe <nsipc_send+0x3e>
  8021da:	c7 44 24 0c b1 30 80 	movl   $0x8030b1,0xc(%esp)
  8021e1:	00 
  8021e2:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  8021e9:	00 
  8021ea:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8021f1:	00 
  8021f2:	c7 04 24 a5 30 80 00 	movl   $0x8030a5,(%esp)
  8021f9:	e8 06 df ff ff       	call   800104 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	8b 45 0c             	mov    0xc(%ebp),%eax
  802205:	89 44 24 04          	mov    %eax,0x4(%esp)
  802209:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802210:	e8 0b e7 ff ff       	call   800920 <memmove>
	nsipcbuf.send.req_size = size;
  802215:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80221b:	8b 45 14             	mov    0x14(%ebp),%eax
  80221e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802223:	b8 08 00 00 00       	mov    $0x8,%eax
  802228:	e8 7b fd ff ff       	call   801fa8 <nsipc>
}
  80222d:	83 c4 14             	add    $0x14,%esp
  802230:	5b                   	pop    %ebx
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    

00802233 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802239:	8b 45 08             	mov    0x8(%ebp),%eax
  80223c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802241:	8b 45 0c             	mov    0xc(%ebp),%eax
  802244:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802249:	8b 45 10             	mov    0x10(%ebp),%eax
  80224c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802251:	b8 09 00 00 00       	mov    $0x9,%eax
  802256:	e8 4d fd ff ff       	call   801fa8 <nsipc>
}
  80225b:	c9                   	leave  
  80225c:	c3                   	ret    
  80225d:	00 00                	add    %al,(%eax)
	...

00802260 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	56                   	push   %esi
  802264:	53                   	push   %ebx
  802265:	83 ec 10             	sub    $0x10,%esp
  802268:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80226b:	8b 45 08             	mov    0x8(%ebp),%eax
  80226e:	89 04 24             	mov    %eax,(%esp)
  802271:	e8 fe eb ff ff       	call   800e74 <fd2data>
  802276:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802278:	c7 44 24 04 bd 30 80 	movl   $0x8030bd,0x4(%esp)
  80227f:	00 
  802280:	89 34 24             	mov    %esi,(%esp)
  802283:	e8 1f e5 ff ff       	call   8007a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802288:	8b 43 04             	mov    0x4(%ebx),%eax
  80228b:	2b 03                	sub    (%ebx),%eax
  80228d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802293:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80229a:	00 00 00 
	stat->st_dev = &devpipe;
  80229d:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  8022a4:	40 80 00 
	return 0;
}
  8022a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ac:	83 c4 10             	add    $0x10,%esp
  8022af:	5b                   	pop    %ebx
  8022b0:	5e                   	pop    %esi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    

008022b3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	53                   	push   %ebx
  8022b7:	83 ec 14             	sub    $0x14,%esp
  8022ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c8:	e8 73 e9 ff ff       	call   800c40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022cd:	89 1c 24             	mov    %ebx,(%esp)
  8022d0:	e8 9f eb ff ff       	call   800e74 <fd2data>
  8022d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e0:	e8 5b e9 ff ff       	call   800c40 <sys_page_unmap>
}
  8022e5:	83 c4 14             	add    $0x14,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5d                   	pop    %ebp
  8022ea:	c3                   	ret    

008022eb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	57                   	push   %edi
  8022ef:	56                   	push   %esi
  8022f0:	53                   	push   %ebx
  8022f1:	83 ec 2c             	sub    $0x2c,%esp
  8022f4:	89 c7                	mov    %eax,%edi
  8022f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022f9:	a1 08 50 80 00       	mov    0x805008,%eax
  8022fe:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802301:	89 3c 24             	mov    %edi,(%esp)
  802304:	e8 a7 05 00 00       	call   8028b0 <pageref>
  802309:	89 c6                	mov    %eax,%esi
  80230b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80230e:	89 04 24             	mov    %eax,(%esp)
  802311:	e8 9a 05 00 00       	call   8028b0 <pageref>
  802316:	39 c6                	cmp    %eax,%esi
  802318:	0f 94 c0             	sete   %al
  80231b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80231e:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802324:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802327:	39 cb                	cmp    %ecx,%ebx
  802329:	75 08                	jne    802333 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80232b:	83 c4 2c             	add    $0x2c,%esp
  80232e:	5b                   	pop    %ebx
  80232f:	5e                   	pop    %esi
  802330:	5f                   	pop    %edi
  802331:	5d                   	pop    %ebp
  802332:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802333:	83 f8 01             	cmp    $0x1,%eax
  802336:	75 c1                	jne    8022f9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802338:	8b 42 58             	mov    0x58(%edx),%eax
  80233b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802342:	00 
  802343:	89 44 24 08          	mov    %eax,0x8(%esp)
  802347:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80234b:	c7 04 24 c4 30 80 00 	movl   $0x8030c4,(%esp)
  802352:	e8 a5 de ff ff       	call   8001fc <cprintf>
  802357:	eb a0                	jmp    8022f9 <_pipeisclosed+0xe>

00802359 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	57                   	push   %edi
  80235d:	56                   	push   %esi
  80235e:	53                   	push   %ebx
  80235f:	83 ec 1c             	sub    $0x1c,%esp
  802362:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802365:	89 34 24             	mov    %esi,(%esp)
  802368:	e8 07 eb ff ff       	call   800e74 <fd2data>
  80236d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80236f:	bf 00 00 00 00       	mov    $0x0,%edi
  802374:	eb 3c                	jmp    8023b2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802376:	89 da                	mov    %ebx,%edx
  802378:	89 f0                	mov    %esi,%eax
  80237a:	e8 6c ff ff ff       	call   8022eb <_pipeisclosed>
  80237f:	85 c0                	test   %eax,%eax
  802381:	75 38                	jne    8023bb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802383:	e8 f2 e7 ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802388:	8b 43 04             	mov    0x4(%ebx),%eax
  80238b:	8b 13                	mov    (%ebx),%edx
  80238d:	83 c2 20             	add    $0x20,%edx
  802390:	39 d0                	cmp    %edx,%eax
  802392:	73 e2                	jae    802376 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802394:	8b 55 0c             	mov    0xc(%ebp),%edx
  802397:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80239a:	89 c2                	mov    %eax,%edx
  80239c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8023a2:	79 05                	jns    8023a9 <devpipe_write+0x50>
  8023a4:	4a                   	dec    %edx
  8023a5:	83 ca e0             	or     $0xffffffe0,%edx
  8023a8:	42                   	inc    %edx
  8023a9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8023ad:	40                   	inc    %eax
  8023ae:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023b1:	47                   	inc    %edi
  8023b2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8023b5:	75 d1                	jne    802388 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8023b7:	89 f8                	mov    %edi,%eax
  8023b9:	eb 05                	jmp    8023c0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023bb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8023c0:	83 c4 1c             	add    $0x1c,%esp
  8023c3:	5b                   	pop    %ebx
  8023c4:	5e                   	pop    %esi
  8023c5:	5f                   	pop    %edi
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    

008023c8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023c8:	55                   	push   %ebp
  8023c9:	89 e5                	mov    %esp,%ebp
  8023cb:	57                   	push   %edi
  8023cc:	56                   	push   %esi
  8023cd:	53                   	push   %ebx
  8023ce:	83 ec 1c             	sub    $0x1c,%esp
  8023d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023d4:	89 3c 24             	mov    %edi,(%esp)
  8023d7:	e8 98 ea ff ff       	call   800e74 <fd2data>
  8023dc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023de:	be 00 00 00 00       	mov    $0x0,%esi
  8023e3:	eb 3a                	jmp    80241f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023e5:	85 f6                	test   %esi,%esi
  8023e7:	74 04                	je     8023ed <devpipe_read+0x25>
				return i;
  8023e9:	89 f0                	mov    %esi,%eax
  8023eb:	eb 40                	jmp    80242d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023ed:	89 da                	mov    %ebx,%edx
  8023ef:	89 f8                	mov    %edi,%eax
  8023f1:	e8 f5 fe ff ff       	call   8022eb <_pipeisclosed>
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	75 2e                	jne    802428 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023fa:	e8 7b e7 ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023ff:	8b 03                	mov    (%ebx),%eax
  802401:	3b 43 04             	cmp    0x4(%ebx),%eax
  802404:	74 df                	je     8023e5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802406:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80240b:	79 05                	jns    802412 <devpipe_read+0x4a>
  80240d:	48                   	dec    %eax
  80240e:	83 c8 e0             	or     $0xffffffe0,%eax
  802411:	40                   	inc    %eax
  802412:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802416:	8b 55 0c             	mov    0xc(%ebp),%edx
  802419:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80241c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80241e:	46                   	inc    %esi
  80241f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802422:	75 db                	jne    8023ff <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802424:	89 f0                	mov    %esi,%eax
  802426:	eb 05                	jmp    80242d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802428:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80242d:	83 c4 1c             	add    $0x1c,%esp
  802430:	5b                   	pop    %ebx
  802431:	5e                   	pop    %esi
  802432:	5f                   	pop    %edi
  802433:	5d                   	pop    %ebp
  802434:	c3                   	ret    

00802435 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802435:	55                   	push   %ebp
  802436:	89 e5                	mov    %esp,%ebp
  802438:	57                   	push   %edi
  802439:	56                   	push   %esi
  80243a:	53                   	push   %ebx
  80243b:	83 ec 3c             	sub    $0x3c,%esp
  80243e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802441:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802444:	89 04 24             	mov    %eax,(%esp)
  802447:	e8 43 ea ff ff       	call   800e8f <fd_alloc>
  80244c:	89 c3                	mov    %eax,%ebx
  80244e:	85 c0                	test   %eax,%eax
  802450:	0f 88 45 01 00 00    	js     80259b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802456:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80245d:	00 
  80245e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802461:	89 44 24 04          	mov    %eax,0x4(%esp)
  802465:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80246c:	e8 28 e7 ff ff       	call   800b99 <sys_page_alloc>
  802471:	89 c3                	mov    %eax,%ebx
  802473:	85 c0                	test   %eax,%eax
  802475:	0f 88 20 01 00 00    	js     80259b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80247b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80247e:	89 04 24             	mov    %eax,(%esp)
  802481:	e8 09 ea ff ff       	call   800e8f <fd_alloc>
  802486:	89 c3                	mov    %eax,%ebx
  802488:	85 c0                	test   %eax,%eax
  80248a:	0f 88 f8 00 00 00    	js     802588 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802490:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802497:	00 
  802498:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80249b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a6:	e8 ee e6 ff ff       	call   800b99 <sys_page_alloc>
  8024ab:	89 c3                	mov    %eax,%ebx
  8024ad:	85 c0                	test   %eax,%eax
  8024af:	0f 88 d3 00 00 00    	js     802588 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8024b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024b8:	89 04 24             	mov    %eax,(%esp)
  8024bb:	e8 b4 e9 ff ff       	call   800e74 <fd2data>
  8024c0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024c9:	00 
  8024ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024d5:	e8 bf e6 ff ff       	call   800b99 <sys_page_alloc>
  8024da:	89 c3                	mov    %eax,%ebx
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	0f 88 91 00 00 00    	js     802575 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024e7:	89 04 24             	mov    %eax,(%esp)
  8024ea:	e8 85 e9 ff ff       	call   800e74 <fd2data>
  8024ef:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8024f6:	00 
  8024f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802502:	00 
  802503:	89 74 24 04          	mov    %esi,0x4(%esp)
  802507:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80250e:	e8 da e6 ff ff       	call   800bed <sys_page_map>
  802513:	89 c3                	mov    %eax,%ebx
  802515:	85 c0                	test   %eax,%eax
  802517:	78 4c                	js     802565 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802519:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80251f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802522:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802524:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802527:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80252e:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802534:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802537:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802539:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80253c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802543:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802546:	89 04 24             	mov    %eax,(%esp)
  802549:	e8 16 e9 ff ff       	call   800e64 <fd2num>
  80254e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802550:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802553:	89 04 24             	mov    %eax,(%esp)
  802556:	e8 09 e9 ff ff       	call   800e64 <fd2num>
  80255b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80255e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802563:	eb 36                	jmp    80259b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802565:	89 74 24 04          	mov    %esi,0x4(%esp)
  802569:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802570:	e8 cb e6 ff ff       	call   800c40 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802575:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802578:	89 44 24 04          	mov    %eax,0x4(%esp)
  80257c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802583:	e8 b8 e6 ff ff       	call   800c40 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80258b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80258f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802596:	e8 a5 e6 ff ff       	call   800c40 <sys_page_unmap>
    err:
	return r;
}
  80259b:	89 d8                	mov    %ebx,%eax
  80259d:	83 c4 3c             	add    $0x3c,%esp
  8025a0:	5b                   	pop    %ebx
  8025a1:	5e                   	pop    %esi
  8025a2:	5f                   	pop    %edi
  8025a3:	5d                   	pop    %ebp
  8025a4:	c3                   	ret    

008025a5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025a5:	55                   	push   %ebp
  8025a6:	89 e5                	mov    %esp,%ebp
  8025a8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b5:	89 04 24             	mov    %eax,(%esp)
  8025b8:	e8 25 e9 ff ff       	call   800ee2 <fd_lookup>
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	78 15                	js     8025d6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c4:	89 04 24             	mov    %eax,(%esp)
  8025c7:	e8 a8 e8 ff ff       	call   800e74 <fd2data>
	return _pipeisclosed(fd, p);
  8025cc:	89 c2                	mov    %eax,%edx
  8025ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d1:	e8 15 fd ff ff       	call   8022eb <_pipeisclosed>
}
  8025d6:	c9                   	leave  
  8025d7:	c3                   	ret    

008025d8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8025d8:	55                   	push   %ebp
  8025d9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8025db:	b8 00 00 00 00       	mov    $0x0,%eax
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    

008025e2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8025e8:	c7 44 24 04 dc 30 80 	movl   $0x8030dc,0x4(%esp)
  8025ef:	00 
  8025f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f3:	89 04 24             	mov    %eax,(%esp)
  8025f6:	e8 ac e1 ff ff       	call   8007a7 <strcpy>
	return 0;
}
  8025fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802600:	c9                   	leave  
  802601:	c3                   	ret    

00802602 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802602:	55                   	push   %ebp
  802603:	89 e5                	mov    %esp,%ebp
  802605:	57                   	push   %edi
  802606:	56                   	push   %esi
  802607:	53                   	push   %ebx
  802608:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80260e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802613:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802619:	eb 30                	jmp    80264b <devcons_write+0x49>
		m = n - tot;
  80261b:	8b 75 10             	mov    0x10(%ebp),%esi
  80261e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802620:	83 fe 7f             	cmp    $0x7f,%esi
  802623:	76 05                	jbe    80262a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802625:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80262a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80262e:	03 45 0c             	add    0xc(%ebp),%eax
  802631:	89 44 24 04          	mov    %eax,0x4(%esp)
  802635:	89 3c 24             	mov    %edi,(%esp)
  802638:	e8 e3 e2 ff ff       	call   800920 <memmove>
		sys_cputs(buf, m);
  80263d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802641:	89 3c 24             	mov    %edi,(%esp)
  802644:	e8 83 e4 ff ff       	call   800acc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802649:	01 f3                	add    %esi,%ebx
  80264b:	89 d8                	mov    %ebx,%eax
  80264d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802650:	72 c9                	jb     80261b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802652:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802658:	5b                   	pop    %ebx
  802659:	5e                   	pop    %esi
  80265a:	5f                   	pop    %edi
  80265b:	5d                   	pop    %ebp
  80265c:	c3                   	ret    

0080265d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80265d:	55                   	push   %ebp
  80265e:	89 e5                	mov    %esp,%ebp
  802660:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802663:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802667:	75 07                	jne    802670 <devcons_read+0x13>
  802669:	eb 25                	jmp    802690 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80266b:	e8 0a e5 ff ff       	call   800b7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802670:	e8 75 e4 ff ff       	call   800aea <sys_cgetc>
  802675:	85 c0                	test   %eax,%eax
  802677:	74 f2                	je     80266b <devcons_read+0xe>
  802679:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80267b:	85 c0                	test   %eax,%eax
  80267d:	78 1d                	js     80269c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80267f:	83 f8 04             	cmp    $0x4,%eax
  802682:	74 13                	je     802697 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802684:	8b 45 0c             	mov    0xc(%ebp),%eax
  802687:	88 10                	mov    %dl,(%eax)
	return 1;
  802689:	b8 01 00 00 00       	mov    $0x1,%eax
  80268e:	eb 0c                	jmp    80269c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802690:	b8 00 00 00 00       	mov    $0x0,%eax
  802695:	eb 05                	jmp    80269c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802697:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80269c:	c9                   	leave  
  80269d:	c3                   	ret    

0080269e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80269e:	55                   	push   %ebp
  80269f:	89 e5                	mov    %esp,%ebp
  8026a1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8026a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8026aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8026b1:	00 
  8026b2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026b5:	89 04 24             	mov    %eax,(%esp)
  8026b8:	e8 0f e4 ff ff       	call   800acc <sys_cputs>
}
  8026bd:	c9                   	leave  
  8026be:	c3                   	ret    

008026bf <getchar>:

int
getchar(void)
{
  8026bf:	55                   	push   %ebp
  8026c0:	89 e5                	mov    %esp,%ebp
  8026c2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8026c5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8026cc:	00 
  8026cd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026db:	e8 a0 ea ff ff       	call   801180 <read>
	if (r < 0)
  8026e0:	85 c0                	test   %eax,%eax
  8026e2:	78 0f                	js     8026f3 <getchar+0x34>
		return r;
	if (r < 1)
  8026e4:	85 c0                	test   %eax,%eax
  8026e6:	7e 06                	jle    8026ee <getchar+0x2f>
		return -E_EOF;
	return c;
  8026e8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8026ec:	eb 05                	jmp    8026f3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8026ee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026f3:	c9                   	leave  
  8026f4:	c3                   	ret    

008026f5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8026f5:	55                   	push   %ebp
  8026f6:	89 e5                	mov    %esp,%ebp
  8026f8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802702:	8b 45 08             	mov    0x8(%ebp),%eax
  802705:	89 04 24             	mov    %eax,(%esp)
  802708:	e8 d5 e7 ff ff       	call   800ee2 <fd_lookup>
  80270d:	85 c0                	test   %eax,%eax
  80270f:	78 11                	js     802722 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802714:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80271a:	39 10                	cmp    %edx,(%eax)
  80271c:	0f 94 c0             	sete   %al
  80271f:	0f b6 c0             	movzbl %al,%eax
}
  802722:	c9                   	leave  
  802723:	c3                   	ret    

00802724 <opencons>:

int
opencons(void)
{
  802724:	55                   	push   %ebp
  802725:	89 e5                	mov    %esp,%ebp
  802727:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80272a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80272d:	89 04 24             	mov    %eax,(%esp)
  802730:	e8 5a e7 ff ff       	call   800e8f <fd_alloc>
  802735:	85 c0                	test   %eax,%eax
  802737:	78 3c                	js     802775 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802739:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802740:	00 
  802741:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802744:	89 44 24 04          	mov    %eax,0x4(%esp)
  802748:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80274f:	e8 45 e4 ff ff       	call   800b99 <sys_page_alloc>
  802754:	85 c0                	test   %eax,%eax
  802756:	78 1d                	js     802775 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802758:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80275e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802761:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802763:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802766:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80276d:	89 04 24             	mov    %eax,(%esp)
  802770:	e8 ef e6 ff ff       	call   800e64 <fd2num>
}
  802775:	c9                   	leave  
  802776:	c3                   	ret    
	...

00802778 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802778:	55                   	push   %ebp
  802779:	89 e5                	mov    %esp,%ebp
  80277b:	56                   	push   %esi
  80277c:	53                   	push   %ebx
  80277d:	83 ec 10             	sub    $0x10,%esp
  802780:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802783:	8b 45 0c             	mov    0xc(%ebp),%eax
  802786:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802789:	85 c0                	test   %eax,%eax
  80278b:	74 0a                	je     802797 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  80278d:	89 04 24             	mov    %eax,(%esp)
  802790:	e8 1a e6 ff ff       	call   800daf <sys_ipc_recv>
  802795:	eb 0c                	jmp    8027a3 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802797:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80279e:	e8 0c e6 ff ff       	call   800daf <sys_ipc_recv>
	}
	if (r < 0)
  8027a3:	85 c0                	test   %eax,%eax
  8027a5:	79 16                	jns    8027bd <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8027a7:	85 db                	test   %ebx,%ebx
  8027a9:	74 06                	je     8027b1 <ipc_recv+0x39>
  8027ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8027b1:	85 f6                	test   %esi,%esi
  8027b3:	74 2c                	je     8027e1 <ipc_recv+0x69>
  8027b5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8027bb:	eb 24                	jmp    8027e1 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8027bd:	85 db                	test   %ebx,%ebx
  8027bf:	74 0a                	je     8027cb <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8027c1:	a1 08 50 80 00       	mov    0x805008,%eax
  8027c6:	8b 40 74             	mov    0x74(%eax),%eax
  8027c9:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8027cb:	85 f6                	test   %esi,%esi
  8027cd:	74 0a                	je     8027d9 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8027cf:	a1 08 50 80 00       	mov    0x805008,%eax
  8027d4:	8b 40 78             	mov    0x78(%eax),%eax
  8027d7:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8027d9:	a1 08 50 80 00       	mov    0x805008,%eax
  8027de:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8027e1:	83 c4 10             	add    $0x10,%esp
  8027e4:	5b                   	pop    %ebx
  8027e5:	5e                   	pop    %esi
  8027e6:	5d                   	pop    %ebp
  8027e7:	c3                   	ret    

008027e8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027e8:	55                   	push   %ebp
  8027e9:	89 e5                	mov    %esp,%ebp
  8027eb:	57                   	push   %edi
  8027ec:	56                   	push   %esi
  8027ed:	53                   	push   %ebx
  8027ee:	83 ec 1c             	sub    $0x1c,%esp
  8027f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8027f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8027fa:	85 db                	test   %ebx,%ebx
  8027fc:	74 19                	je     802817 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8027fe:	8b 45 14             	mov    0x14(%ebp),%eax
  802801:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802805:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802809:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80280d:	89 34 24             	mov    %esi,(%esp)
  802810:	e8 77 e5 ff ff       	call   800d8c <sys_ipc_try_send>
  802815:	eb 1c                	jmp    802833 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802817:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80281e:	00 
  80281f:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802826:	ee 
  802827:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80282b:	89 34 24             	mov    %esi,(%esp)
  80282e:	e8 59 e5 ff ff       	call   800d8c <sys_ipc_try_send>
		}
		if (r == 0)
  802833:	85 c0                	test   %eax,%eax
  802835:	74 2c                	je     802863 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802837:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80283a:	74 20                	je     80285c <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  80283c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802840:	c7 44 24 08 e8 30 80 	movl   $0x8030e8,0x8(%esp)
  802847:	00 
  802848:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80284f:	00 
  802850:	c7 04 24 fb 30 80 00 	movl   $0x8030fb,(%esp)
  802857:	e8 a8 d8 ff ff       	call   800104 <_panic>
		}
		sys_yield();
  80285c:	e8 19 e3 ff ff       	call   800b7a <sys_yield>
	}
  802861:	eb 97                	jmp    8027fa <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802863:	83 c4 1c             	add    $0x1c,%esp
  802866:	5b                   	pop    %ebx
  802867:	5e                   	pop    %esi
  802868:	5f                   	pop    %edi
  802869:	5d                   	pop    %ebp
  80286a:	c3                   	ret    

0080286b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80286b:	55                   	push   %ebp
  80286c:	89 e5                	mov    %esp,%ebp
  80286e:	53                   	push   %ebx
  80286f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802872:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802877:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80287e:	89 c2                	mov    %eax,%edx
  802880:	c1 e2 07             	shl    $0x7,%edx
  802883:	29 ca                	sub    %ecx,%edx
  802885:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80288b:	8b 52 50             	mov    0x50(%edx),%edx
  80288e:	39 da                	cmp    %ebx,%edx
  802890:	75 0f                	jne    8028a1 <ipc_find_env+0x36>
			return envs[i].env_id;
  802892:	c1 e0 07             	shl    $0x7,%eax
  802895:	29 c8                	sub    %ecx,%eax
  802897:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80289c:	8b 40 40             	mov    0x40(%eax),%eax
  80289f:	eb 0c                	jmp    8028ad <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028a1:	40                   	inc    %eax
  8028a2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028a7:	75 ce                	jne    802877 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028a9:	66 b8 00 00          	mov    $0x0,%ax
}
  8028ad:	5b                   	pop    %ebx
  8028ae:	5d                   	pop    %ebp
  8028af:	c3                   	ret    

008028b0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028b0:	55                   	push   %ebp
  8028b1:	89 e5                	mov    %esp,%ebp
  8028b3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028b6:	89 c2                	mov    %eax,%edx
  8028b8:	c1 ea 16             	shr    $0x16,%edx
  8028bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028c2:	f6 c2 01             	test   $0x1,%dl
  8028c5:	74 1e                	je     8028e5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028c7:	c1 e8 0c             	shr    $0xc,%eax
  8028ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8028d1:	a8 01                	test   $0x1,%al
  8028d3:	74 17                	je     8028ec <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028d5:	c1 e8 0c             	shr    $0xc,%eax
  8028d8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8028df:	ef 
  8028e0:	0f b7 c0             	movzwl %ax,%eax
  8028e3:	eb 0c                	jmp    8028f1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8028e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8028ea:	eb 05                	jmp    8028f1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8028ec:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8028f1:	5d                   	pop    %ebp
  8028f2:	c3                   	ret    
	...

008028f4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8028f4:	55                   	push   %ebp
  8028f5:	57                   	push   %edi
  8028f6:	56                   	push   %esi
  8028f7:	83 ec 10             	sub    $0x10,%esp
  8028fa:	8b 74 24 20          	mov    0x20(%esp),%esi
  8028fe:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802902:	89 74 24 04          	mov    %esi,0x4(%esp)
  802906:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80290a:	89 cd                	mov    %ecx,%ebp
  80290c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802910:	85 c0                	test   %eax,%eax
  802912:	75 2c                	jne    802940 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802914:	39 f9                	cmp    %edi,%ecx
  802916:	77 68                	ja     802980 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802918:	85 c9                	test   %ecx,%ecx
  80291a:	75 0b                	jne    802927 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80291c:	b8 01 00 00 00       	mov    $0x1,%eax
  802921:	31 d2                	xor    %edx,%edx
  802923:	f7 f1                	div    %ecx
  802925:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802927:	31 d2                	xor    %edx,%edx
  802929:	89 f8                	mov    %edi,%eax
  80292b:	f7 f1                	div    %ecx
  80292d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80292f:	89 f0                	mov    %esi,%eax
  802931:	f7 f1                	div    %ecx
  802933:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802935:	89 f0                	mov    %esi,%eax
  802937:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802939:	83 c4 10             	add    $0x10,%esp
  80293c:	5e                   	pop    %esi
  80293d:	5f                   	pop    %edi
  80293e:	5d                   	pop    %ebp
  80293f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802940:	39 f8                	cmp    %edi,%eax
  802942:	77 2c                	ja     802970 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802944:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802947:	83 f6 1f             	xor    $0x1f,%esi
  80294a:	75 4c                	jne    802998 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80294c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80294e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802953:	72 0a                	jb     80295f <__udivdi3+0x6b>
  802955:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802959:	0f 87 ad 00 00 00    	ja     802a0c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80295f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802964:	89 f0                	mov    %esi,%eax
  802966:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802968:	83 c4 10             	add    $0x10,%esp
  80296b:	5e                   	pop    %esi
  80296c:	5f                   	pop    %edi
  80296d:	5d                   	pop    %ebp
  80296e:	c3                   	ret    
  80296f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802970:	31 ff                	xor    %edi,%edi
  802972:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802974:	89 f0                	mov    %esi,%eax
  802976:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802978:	83 c4 10             	add    $0x10,%esp
  80297b:	5e                   	pop    %esi
  80297c:	5f                   	pop    %edi
  80297d:	5d                   	pop    %ebp
  80297e:	c3                   	ret    
  80297f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802980:	89 fa                	mov    %edi,%edx
  802982:	89 f0                	mov    %esi,%eax
  802984:	f7 f1                	div    %ecx
  802986:	89 c6                	mov    %eax,%esi
  802988:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80298a:	89 f0                	mov    %esi,%eax
  80298c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80298e:	83 c4 10             	add    $0x10,%esp
  802991:	5e                   	pop    %esi
  802992:	5f                   	pop    %edi
  802993:	5d                   	pop    %ebp
  802994:	c3                   	ret    
  802995:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802998:	89 f1                	mov    %esi,%ecx
  80299a:	d3 e0                	shl    %cl,%eax
  80299c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8029a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8029a5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8029a7:	89 ea                	mov    %ebp,%edx
  8029a9:	88 c1                	mov    %al,%cl
  8029ab:	d3 ea                	shr    %cl,%edx
  8029ad:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8029b1:	09 ca                	or     %ecx,%edx
  8029b3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8029b7:	89 f1                	mov    %esi,%ecx
  8029b9:	d3 e5                	shl    %cl,%ebp
  8029bb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8029bf:	89 fd                	mov    %edi,%ebp
  8029c1:	88 c1                	mov    %al,%cl
  8029c3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8029c5:	89 fa                	mov    %edi,%edx
  8029c7:	89 f1                	mov    %esi,%ecx
  8029c9:	d3 e2                	shl    %cl,%edx
  8029cb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029cf:	88 c1                	mov    %al,%cl
  8029d1:	d3 ef                	shr    %cl,%edi
  8029d3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029d5:	89 f8                	mov    %edi,%eax
  8029d7:	89 ea                	mov    %ebp,%edx
  8029d9:	f7 74 24 08          	divl   0x8(%esp)
  8029dd:	89 d1                	mov    %edx,%ecx
  8029df:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8029e1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029e5:	39 d1                	cmp    %edx,%ecx
  8029e7:	72 17                	jb     802a00 <__udivdi3+0x10c>
  8029e9:	74 09                	je     8029f4 <__udivdi3+0x100>
  8029eb:	89 fe                	mov    %edi,%esi
  8029ed:	31 ff                	xor    %edi,%edi
  8029ef:	e9 41 ff ff ff       	jmp    802935 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8029f4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029f8:	89 f1                	mov    %esi,%ecx
  8029fa:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029fc:	39 c2                	cmp    %eax,%edx
  8029fe:	73 eb                	jae    8029eb <__udivdi3+0xf7>
		{
		  q0--;
  802a00:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a03:	31 ff                	xor    %edi,%edi
  802a05:	e9 2b ff ff ff       	jmp    802935 <__udivdi3+0x41>
  802a0a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a0c:	31 f6                	xor    %esi,%esi
  802a0e:	e9 22 ff ff ff       	jmp    802935 <__udivdi3+0x41>
	...

00802a14 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802a14:	55                   	push   %ebp
  802a15:	57                   	push   %edi
  802a16:	56                   	push   %esi
  802a17:	83 ec 20             	sub    $0x20,%esp
  802a1a:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a1e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a22:	89 44 24 14          	mov    %eax,0x14(%esp)
  802a26:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802a2a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a2e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802a32:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802a34:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802a36:	85 ed                	test   %ebp,%ebp
  802a38:	75 16                	jne    802a50 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802a3a:	39 f1                	cmp    %esi,%ecx
  802a3c:	0f 86 a6 00 00 00    	jbe    802ae8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a42:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802a44:	89 d0                	mov    %edx,%eax
  802a46:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a48:	83 c4 20             	add    $0x20,%esp
  802a4b:	5e                   	pop    %esi
  802a4c:	5f                   	pop    %edi
  802a4d:	5d                   	pop    %ebp
  802a4e:	c3                   	ret    
  802a4f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a50:	39 f5                	cmp    %esi,%ebp
  802a52:	0f 87 ac 00 00 00    	ja     802b04 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a58:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802a5b:	83 f0 1f             	xor    $0x1f,%eax
  802a5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a62:	0f 84 a8 00 00 00    	je     802b10 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a68:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a6c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a6e:	bf 20 00 00 00       	mov    $0x20,%edi
  802a73:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802a77:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a7b:	89 f9                	mov    %edi,%ecx
  802a7d:	d3 e8                	shr    %cl,%eax
  802a7f:	09 e8                	or     %ebp,%eax
  802a81:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802a85:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a89:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a8d:	d3 e0                	shl    %cl,%eax
  802a8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a93:	89 f2                	mov    %esi,%edx
  802a95:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802a97:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a9b:	d3 e0                	shl    %cl,%eax
  802a9d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802aa1:	8b 44 24 14          	mov    0x14(%esp),%eax
  802aa5:	89 f9                	mov    %edi,%ecx
  802aa7:	d3 e8                	shr    %cl,%eax
  802aa9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802aab:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802aad:	89 f2                	mov    %esi,%edx
  802aaf:	f7 74 24 18          	divl   0x18(%esp)
  802ab3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802ab5:	f7 64 24 0c          	mull   0xc(%esp)
  802ab9:	89 c5                	mov    %eax,%ebp
  802abb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802abd:	39 d6                	cmp    %edx,%esi
  802abf:	72 67                	jb     802b28 <__umoddi3+0x114>
  802ac1:	74 75                	je     802b38 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802ac3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802ac7:	29 e8                	sub    %ebp,%eax
  802ac9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802acb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802acf:	d3 e8                	shr    %cl,%eax
  802ad1:	89 f2                	mov    %esi,%edx
  802ad3:	89 f9                	mov    %edi,%ecx
  802ad5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802ad7:	09 d0                	or     %edx,%eax
  802ad9:	89 f2                	mov    %esi,%edx
  802adb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802adf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ae1:	83 c4 20             	add    $0x20,%esp
  802ae4:	5e                   	pop    %esi
  802ae5:	5f                   	pop    %edi
  802ae6:	5d                   	pop    %ebp
  802ae7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802ae8:	85 c9                	test   %ecx,%ecx
  802aea:	75 0b                	jne    802af7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802aec:	b8 01 00 00 00       	mov    $0x1,%eax
  802af1:	31 d2                	xor    %edx,%edx
  802af3:	f7 f1                	div    %ecx
  802af5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802af7:	89 f0                	mov    %esi,%eax
  802af9:	31 d2                	xor    %edx,%edx
  802afb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802afd:	89 f8                	mov    %edi,%eax
  802aff:	e9 3e ff ff ff       	jmp    802a42 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802b04:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b06:	83 c4 20             	add    $0x20,%esp
  802b09:	5e                   	pop    %esi
  802b0a:	5f                   	pop    %edi
  802b0b:	5d                   	pop    %ebp
  802b0c:	c3                   	ret    
  802b0d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b10:	39 f5                	cmp    %esi,%ebp
  802b12:	72 04                	jb     802b18 <__umoddi3+0x104>
  802b14:	39 f9                	cmp    %edi,%ecx
  802b16:	77 06                	ja     802b1e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b18:	89 f2                	mov    %esi,%edx
  802b1a:	29 cf                	sub    %ecx,%edi
  802b1c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b1e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b20:	83 c4 20             	add    $0x20,%esp
  802b23:	5e                   	pop    %esi
  802b24:	5f                   	pop    %edi
  802b25:	5d                   	pop    %ebp
  802b26:	c3                   	ret    
  802b27:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802b28:	89 d1                	mov    %edx,%ecx
  802b2a:	89 c5                	mov    %eax,%ebp
  802b2c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802b30:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802b34:	eb 8d                	jmp    802ac3 <__umoddi3+0xaf>
  802b36:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b38:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802b3c:	72 ea                	jb     802b28 <__umoddi3+0x114>
  802b3e:	89 f1                	mov    %esi,%ecx
  802b40:	eb 81                	jmp    802ac3 <__umoddi3+0xaf>
