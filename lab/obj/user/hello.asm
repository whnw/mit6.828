
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  800041:	e8 2a 01 00 00       	call   800170 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 08 40 80 00       	mov    0x804008,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 ae 24 80 00 	movl   $0x8024ae,(%esp)
  800059:	e8 12 01 00 00       	call   800170 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	83 ec 10             	sub    $0x10,%esp
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006e:	e8 5c 0a 00 00       	call   800acf <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007f:	c1 e0 07             	shl    $0x7,%eax
  800082:	29 d0                	sub    %edx,%eax
  800084:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800089:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 f6                	test   %esi,%esi
  800090:	7e 07                	jle    800099 <libmain+0x39>
		binaryname = argv[0];
  800092:	8b 03                	mov    (%ebx),%eax
  800094:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800099:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009d:	89 34 24             	mov    %esi,(%esp)
  8000a0:	e8 8f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 0a 00 00 00       	call   8000b4 <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5d                   	pop    %ebp
  8000b0:	c3                   	ret    
  8000b1:	00 00                	add    %al,(%eax)
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ba:	e8 00 0f 00 00       	call   800fbf <close_all>
	sys_env_destroy(0);
  8000bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c6:	e8 b2 09 00 00       	call   800a7d <sys_env_destroy>
}
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    
  8000cd:	00 00                	add    %al,(%eax)
	...

008000d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 14             	sub    $0x14,%esp
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000da:	8b 03                	mov    (%ebx),%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e3:	40                   	inc    %eax
  8000e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000eb:	75 19                	jne    800106 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f4:	00 
  8000f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 40 09 00 00       	call   800a40 <sys_cputs>
		b->idx = 0;
  800100:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800106:	ff 43 04             	incl   0x4(%ebx)
}
  800109:	83 c4 14             	add    $0x14,%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800133:	8b 45 08             	mov    0x8(%ebp),%eax
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800140:	89 44 24 04          	mov    %eax,0x4(%esp)
  800144:	c7 04 24 d0 00 80 00 	movl   $0x8000d0,(%esp)
  80014b:	e8 82 01 00 00       	call   8002d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800150:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800160:	89 04 24             	mov    %eax,(%esp)
  800163:	e8 d8 08 00 00       	call   800a40 <sys_cputs>

	return b.cnt;
}
  800168:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800176:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800179:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017d:	8b 45 08             	mov    0x8(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 87 ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800188:	c9                   	leave  
  800189:	c3                   	ret    
	...

0080018c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 3c             	sub    $0x3c,%esp
  800195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800198:	89 d7                	mov    %edx,%edi
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	75 08                	jne    8001b8 <printnum+0x2c>
  8001b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b6:	77 57                	ja     80020f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001bc:	4b                   	dec    %ebx
  8001bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001cc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d7:	00 
  8001d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	e8 66 20 00 00       	call   802250 <__udivdi3>
  8001ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f9:	89 fa                	mov    %edi,%edx
  8001fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fe:	e8 89 ff ff ff       	call   80018c <printnum>
  800203:	eb 0f                	jmp    800214 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800205:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800209:	89 34 24             	mov    %esi,(%esp)
  80020c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020f:	4b                   	dec    %ebx
  800210:	85 db                	test   %ebx,%ebx
  800212:	7f f1                	jg     800205 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800214:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800218:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021c:	8b 45 10             	mov    0x10(%ebp),%eax
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022a:	00 
  80022b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	e8 33 21 00 00       	call   802370 <__umoddi3>
  80023d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800241:	0f be 80 cf 24 80 00 	movsbl 0x8024cf(%eax),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80024e:	83 c4 3c             	add    $0x3c,%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800259:	83 fa 01             	cmp    $0x1,%edx
  80025c:	7e 0e                	jle    80026c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 4a 08             	lea    0x8(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	8b 52 04             	mov    0x4(%edx),%edx
  80026a:	eb 22                	jmp    80028e <getuint+0x38>
	else if (lflag)
  80026c:	85 d2                	test   %edx,%edx
  80026e:	74 10                	je     800280 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 04             	lea    0x4(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
  80027e:	eb 0e                	jmp    80028e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 04             	lea    0x4(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    

00800290 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800296:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	3b 50 04             	cmp    0x4(%eax),%edx
  80029e:	73 08                	jae    8002a8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a3:	88 0a                	mov    %cl,(%edx)
  8002a5:	42                   	inc    %edx
  8002a6:	89 10                	mov    %edx,(%eax)
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	e8 02 00 00 00       	call   8002d2 <vprintfmt>
	va_end(ap);
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 4c             	sub    $0x4c,%esp
  8002db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002de:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e1:	eb 12                	jmp    8002f5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	0f 84 6b 03 00 00    	je     800656 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f5:	0f b6 06             	movzbl (%esi),%eax
  8002f8:	46                   	inc    %esi
  8002f9:	83 f8 25             	cmp    $0x25,%eax
  8002fc:	75 e5                	jne    8002e3 <vprintfmt+0x11>
  8002fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800302:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800309:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800315:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031a:	eb 26                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800323:	eb 1d                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800328:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80032c:	eb 14                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800331:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800338:	eb 08                	jmp    800342 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80033d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	0f b6 06             	movzbl (%esi),%eax
  800345:	8d 56 01             	lea    0x1(%esi),%edx
  800348:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80034b:	8a 16                	mov    (%esi),%dl
  80034d:	83 ea 23             	sub    $0x23,%edx
  800350:	80 fa 55             	cmp    $0x55,%dl
  800353:	0f 87 e1 02 00 00    	ja     80063a <vprintfmt+0x368>
  800359:	0f b6 d2             	movzbl %dl,%edx
  80035c:	ff 24 95 20 26 80 00 	jmp    *0x802620(,%edx,4)
  800363:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800366:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80036e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800372:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800375:	8d 50 d0             	lea    -0x30(%eax),%edx
  800378:	83 fa 09             	cmp    $0x9,%edx
  80037b:	77 2a                	ja     8003a7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037e:	eb eb                	jmp    80036b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 50 04             	lea    0x4(%eax),%edx
  800386:	89 55 14             	mov    %edx,0x14(%ebp)
  800389:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038e:	eb 17                	jmp    8003a7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800390:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800394:	78 98                	js     80032e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800399:	eb a7                	jmp    800342 <vprintfmt+0x70>
  80039b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003a5:	eb 9b                	jmp    800342 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ab:	79 95                	jns    800342 <vprintfmt+0x70>
  8003ad:	eb 8b                	jmp    80033a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003af:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b3:	eb 8d                	jmp    800342 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 50 04             	lea    0x4(%eax),%edx
  8003bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003cd:	e9 23 ff ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 50 04             	lea    0x4(%eax),%edx
  8003d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	79 02                	jns    8003e3 <vprintfmt+0x111>
  8003e1:	f7 d8                	neg    %eax
  8003e3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e5:	83 f8 10             	cmp    $0x10,%eax
  8003e8:	7f 0b                	jg     8003f5 <vprintfmt+0x123>
  8003ea:	8b 04 85 80 27 80 00 	mov    0x802780(,%eax,4),%eax
  8003f1:	85 c0                	test   %eax,%eax
  8003f3:	75 23                	jne    800418 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f9:	c7 44 24 08 e7 24 80 	movl   $0x8024e7,0x8(%esp)
  800400:	00 
  800401:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 9a fe ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800413:	e9 dd fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800418:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041c:	c7 44 24 08 b9 28 80 	movl   $0x8028b9,0x8(%esp)
  800423:	00 
  800424:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800428:	8b 55 08             	mov    0x8(%ebp),%edx
  80042b:	89 14 24             	mov    %edx,(%esp)
  80042e:	e8 77 fe ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800436:	e9 ba fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
  80043b:	89 f9                	mov    %edi,%ecx
  80043d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800440:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 30                	mov    (%eax),%esi
  80044e:	85 f6                	test   %esi,%esi
  800450:	75 05                	jne    800457 <vprintfmt+0x185>
				p = "(null)";
  800452:	be e0 24 80 00       	mov    $0x8024e0,%esi
			if (width > 0 && padc != '-')
  800457:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045b:	0f 8e 84 00 00 00    	jle    8004e5 <vprintfmt+0x213>
  800461:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800465:	74 7e                	je     8004e5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80046b:	89 34 24             	mov    %esi,(%esp)
  80046e:	e8 8b 02 00 00       	call   8006fe <strnlen>
  800473:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800476:	29 c2                	sub    %eax,%edx
  800478:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80047b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80047f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800482:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800485:	89 de                	mov    %ebx,%esi
  800487:	89 d3                	mov    %edx,%ebx
  800489:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	eb 0b                	jmp    800498 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80048d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800491:	89 3c 24             	mov    %edi,(%esp)
  800494:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	4b                   	dec    %ebx
  800498:	85 db                	test   %ebx,%ebx
  80049a:	7f f1                	jg     80048d <vprintfmt+0x1bb>
  80049c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80049f:	89 f3                	mov    %esi,%ebx
  8004a1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	79 05                	jns    8004b0 <vprintfmt+0x1de>
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b3:	29 c2                	sub    %eax,%edx
  8004b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b8:	eb 2b                	jmp    8004e5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004be:	74 18                	je     8004d8 <vprintfmt+0x206>
  8004c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c3:	83 fa 5e             	cmp    $0x5e,%edx
  8004c6:	76 10                	jbe    8004d8 <vprintfmt+0x206>
					putch('?', putdat);
  8004c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
  8004d6:	eb 0a                	jmp    8004e2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e5:	0f be 06             	movsbl (%esi),%eax
  8004e8:	46                   	inc    %esi
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	74 21                	je     80050e <vprintfmt+0x23c>
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	78 c9                	js     8004ba <vprintfmt+0x1e8>
  8004f1:	4f                   	dec    %edi
  8004f2:	79 c6                	jns    8004ba <vprintfmt+0x1e8>
  8004f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f7:	89 de                	mov    %ebx,%esi
  8004f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004fc:	eb 18                	jmp    800516 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800502:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800509:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050b:	4b                   	dec    %ebx
  80050c:	eb 08                	jmp    800516 <vprintfmt+0x244>
  80050e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800511:	89 de                	mov    %ebx,%esi
  800513:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800516:	85 db                	test   %ebx,%ebx
  800518:	7f e4                	jg     8004fe <vprintfmt+0x22c>
  80051a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80051d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800522:	e9 ce fd ff ff       	jmp    8002f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800527:	83 f9 01             	cmp    $0x1,%ecx
  80052a:	7e 10                	jle    80053c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 08             	lea    0x8(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 30                	mov    (%eax),%esi
  800537:	8b 78 04             	mov    0x4(%eax),%edi
  80053a:	eb 26                	jmp    800562 <vprintfmt+0x290>
	else if (lflag)
  80053c:	85 c9                	test   %ecx,%ecx
  80053e:	74 12                	je     800552 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 30                	mov    (%eax),%esi
  80054b:	89 f7                	mov    %esi,%edi
  80054d:	c1 ff 1f             	sar    $0x1f,%edi
  800550:	eb 10                	jmp    800562 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 30                	mov    (%eax),%esi
  80055d:	89 f7                	mov    %esi,%edi
  80055f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800562:	85 ff                	test   %edi,%edi
  800564:	78 0a                	js     800570 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056b:	e9 8c 00 00 00       	jmp    8005fc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80057b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80057e:	f7 de                	neg    %esi
  800580:	83 d7 00             	adc    $0x0,%edi
  800583:	f7 df                	neg    %edi
			}
			base = 10;
  800585:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058a:	eb 70                	jmp    8005fc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058c:	89 ca                	mov    %ecx,%edx
  80058e:	8d 45 14             	lea    0x14(%ebp),%eax
  800591:	e8 c0 fc ff ff       	call   800256 <getuint>
  800596:	89 c6                	mov    %eax,%esi
  800598:	89 d7                	mov    %edx,%edi
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80059f:	eb 5b                	jmp    8005fc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8005a1:	89 ca                	mov    %ecx,%edx
  8005a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a6:	e8 ab fc ff ff       	call   800256 <getuint>
  8005ab:	89 c6                	mov    %eax,%esi
  8005ad:	89 d7                	mov    %edx,%edi
			base = 8;
  8005af:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005b4:	eb 46                	jmp    8005fc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ba:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005c1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005db:	8b 30                	mov    (%eax),%esi
  8005dd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005e7:	eb 13                	jmp    8005fc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e9:	89 ca                	mov    %ecx,%edx
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 63 fc ff ff       	call   800256 <getuint>
  8005f3:	89 c6                	mov    %eax,%esi
  8005f5:	89 d7                	mov    %edx,%edi
			base = 16;
  8005f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005fc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800600:	89 54 24 10          	mov    %edx,0x10(%esp)
  800604:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800607:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060f:	89 34 24             	mov    %esi,(%esp)
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	89 da                	mov    %ebx,%edx
  800618:	8b 45 08             	mov    0x8(%ebp),%eax
  80061b:	e8 6c fb ff ff       	call   80018c <printnum>
			break;
  800620:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800623:	e9 cd fc ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	89 04 24             	mov    %eax,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800635:	e9 bb fc ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800648:	eb 01                	jmp    80064b <vprintfmt+0x379>
  80064a:	4e                   	dec    %esi
  80064b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80064f:	75 f9                	jne    80064a <vprintfmt+0x378>
  800651:	e9 9f fc ff ff       	jmp    8002f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800656:	83 c4 4c             	add    $0x4c,%esp
  800659:	5b                   	pop    %ebx
  80065a:	5e                   	pop    %esi
  80065b:	5f                   	pop    %edi
  80065c:	5d                   	pop    %ebp
  80065d:	c3                   	ret    

0080065e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065e:	55                   	push   %ebp
  80065f:	89 e5                	mov    %esp,%ebp
  800661:	83 ec 28             	sub    $0x28,%esp
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80066d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800671:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800674:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067b:	85 c0                	test   %eax,%eax
  80067d:	74 30                	je     8006af <vsnprintf+0x51>
  80067f:	85 d2                	test   %edx,%edx
  800681:	7e 33                	jle    8006b6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068a:	8b 45 10             	mov    0x10(%ebp),%eax
  80068d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800691:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800694:	89 44 24 04          	mov    %eax,0x4(%esp)
  800698:	c7 04 24 90 02 80 00 	movl   $0x800290,(%esp)
  80069f:	e8 2e fc ff ff       	call   8002d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ad:	eb 0c                	jmp    8006bb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b4:	eb 05                	jmp    8006bb <vsnprintf+0x5d>
  8006b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	e8 7b ff ff ff       	call   80065e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    
  8006e5:	00 00                	add    %al,(%eax)
	...

008006e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f3:	eb 01                	jmp    8006f6 <strlen+0xe>
		n++;
  8006f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fa:	75 f9                	jne    8006f5 <strlen+0xd>
		n++;
	return n;
}
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
  80070c:	eb 01                	jmp    80070f <strnlen+0x11>
		n++;
  80070e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070f:	39 d0                	cmp    %edx,%eax
  800711:	74 06                	je     800719 <strnlen+0x1b>
  800713:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800717:	75 f5                	jne    80070e <strnlen+0x10>
		n++;
	return n;
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800725:	ba 00 00 00 00       	mov    $0x0,%edx
  80072a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80072d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800730:	42                   	inc    %edx
  800731:	84 c9                	test   %cl,%cl
  800733:	75 f5                	jne    80072a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800735:	5b                   	pop    %ebx
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800742:	89 1c 24             	mov    %ebx,(%esp)
  800745:	e8 9e ff ff ff       	call   8006e8 <strlen>
	strcpy(dst + len, src);
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800751:	01 d8                	add    %ebx,%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 c0 ff ff ff       	call   80071b <strcpy>
	return dst;
}
  80075b:	89 d8                	mov    %ebx,%eax
  80075d:	83 c4 08             	add    $0x8,%esp
  800760:	5b                   	pop    %ebx
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	56                   	push   %esi
  800767:	53                   	push   %ebx
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800771:	b9 00 00 00 00       	mov    $0x0,%ecx
  800776:	eb 0c                	jmp    800784 <strncpy+0x21>
		*dst++ = *src;
  800778:	8a 1a                	mov    (%edx),%bl
  80077a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077d:	80 3a 01             	cmpb   $0x1,(%edx)
  800780:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800783:	41                   	inc    %ecx
  800784:	39 f1                	cmp    %esi,%ecx
  800786:	75 f0                	jne    800778 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	56                   	push   %esi
  800790:	53                   	push   %ebx
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800797:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079a:	85 d2                	test   %edx,%edx
  80079c:	75 0a                	jne    8007a8 <strlcpy+0x1c>
  80079e:	89 f0                	mov    %esi,%eax
  8007a0:	eb 1a                	jmp    8007bc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a2:	88 18                	mov    %bl,(%eax)
  8007a4:	40                   	inc    %eax
  8007a5:	41                   	inc    %ecx
  8007a6:	eb 02                	jmp    8007aa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007aa:	4a                   	dec    %edx
  8007ab:	74 0a                	je     8007b7 <strlcpy+0x2b>
  8007ad:	8a 19                	mov    (%ecx),%bl
  8007af:	84 db                	test   %bl,%bl
  8007b1:	75 ef                	jne    8007a2 <strlcpy+0x16>
  8007b3:	89 c2                	mov    %eax,%edx
  8007b5:	eb 02                	jmp    8007b9 <strlcpy+0x2d>
  8007b7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007b9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007bc:	29 f0                	sub    %esi,%eax
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cb:	eb 02                	jmp    8007cf <strcmp+0xd>
		p++, q++;
  8007cd:	41                   	inc    %ecx
  8007ce:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cf:	8a 01                	mov    (%ecx),%al
  8007d1:	84 c0                	test   %al,%al
  8007d3:	74 04                	je     8007d9 <strcmp+0x17>
  8007d5:	3a 02                	cmp    (%edx),%al
  8007d7:	74 f4                	je     8007cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d9:	0f b6 c0             	movzbl %al,%eax
  8007dc:	0f b6 12             	movzbl (%edx),%edx
  8007df:	29 d0                	sub    %edx,%eax
}
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007f0:	eb 03                	jmp    8007f5 <strncmp+0x12>
		n--, p++, q++;
  8007f2:	4a                   	dec    %edx
  8007f3:	40                   	inc    %eax
  8007f4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 14                	je     80080d <strncmp+0x2a>
  8007f9:	8a 18                	mov    (%eax),%bl
  8007fb:	84 db                	test   %bl,%bl
  8007fd:	74 04                	je     800803 <strncmp+0x20>
  8007ff:	3a 19                	cmp    (%ecx),%bl
  800801:	74 ef                	je     8007f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800803:	0f b6 00             	movzbl (%eax),%eax
  800806:	0f b6 11             	movzbl (%ecx),%edx
  800809:	29 d0                	sub    %edx,%eax
  80080b:	eb 05                	jmp    800812 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80081e:	eb 05                	jmp    800825 <strchr+0x10>
		if (*s == c)
  800820:	38 ca                	cmp    %cl,%dl
  800822:	74 0c                	je     800830 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800824:	40                   	inc    %eax
  800825:	8a 10                	mov    (%eax),%dl
  800827:	84 d2                	test   %dl,%dl
  800829:	75 f5                	jne    800820 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083b:	eb 05                	jmp    800842 <strfind+0x10>
		if (*s == c)
  80083d:	38 ca                	cmp    %cl,%dl
  80083f:	74 07                	je     800848 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800841:	40                   	inc    %eax
  800842:	8a 10                	mov    (%eax),%dl
  800844:	84 d2                	test   %dl,%dl
  800846:	75 f5                	jne    80083d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	57                   	push   %edi
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 7d 08             	mov    0x8(%ebp),%edi
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
  800856:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800859:	85 c9                	test   %ecx,%ecx
  80085b:	74 30                	je     80088d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800863:	75 25                	jne    80088a <memset+0x40>
  800865:	f6 c1 03             	test   $0x3,%cl
  800868:	75 20                	jne    80088a <memset+0x40>
		c &= 0xFF;
  80086a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086d:	89 d3                	mov    %edx,%ebx
  80086f:	c1 e3 08             	shl    $0x8,%ebx
  800872:	89 d6                	mov    %edx,%esi
  800874:	c1 e6 18             	shl    $0x18,%esi
  800877:	89 d0                	mov    %edx,%eax
  800879:	c1 e0 10             	shl    $0x10,%eax
  80087c:	09 f0                	or     %esi,%eax
  80087e:	09 d0                	or     %edx,%eax
  800880:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800882:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800885:	fc                   	cld    
  800886:	f3 ab                	rep stos %eax,%es:(%edi)
  800888:	eb 03                	jmp    80088d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088a:	fc                   	cld    
  80088b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80088d:	89 f8                	mov    %edi,%eax
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5f                   	pop    %edi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	57                   	push   %edi
  800898:	56                   	push   %esi
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a2:	39 c6                	cmp    %eax,%esi
  8008a4:	73 34                	jae    8008da <memmove+0x46>
  8008a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a9:	39 d0                	cmp    %edx,%eax
  8008ab:	73 2d                	jae    8008da <memmove+0x46>
		s += n;
		d += n;
  8008ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b0:	f6 c2 03             	test   $0x3,%dl
  8008b3:	75 1b                	jne    8008d0 <memmove+0x3c>
  8008b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bb:	75 13                	jne    8008d0 <memmove+0x3c>
  8008bd:	f6 c1 03             	test   $0x3,%cl
  8008c0:	75 0e                	jne    8008d0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008c2:	83 ef 04             	sub    $0x4,%edi
  8008c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008cb:	fd                   	std    
  8008cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ce:	eb 07                	jmp    8008d7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008d0:	4f                   	dec    %edi
  8008d1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d4:	fd                   	std    
  8008d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d7:	fc                   	cld    
  8008d8:	eb 20                	jmp    8008fa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e0:	75 13                	jne    8008f5 <memmove+0x61>
  8008e2:	a8 03                	test   $0x3,%al
  8008e4:	75 0f                	jne    8008f5 <memmove+0x61>
  8008e6:	f6 c1 03             	test   $0x3,%cl
  8008e9:	75 0a                	jne    8008f5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008eb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ee:	89 c7                	mov    %eax,%edi
  8008f0:	fc                   	cld    
  8008f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f3:	eb 05                	jmp    8008fa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f5:	89 c7                	mov    %eax,%edi
  8008f7:	fc                   	cld    
  8008f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800904:	8b 45 10             	mov    0x10(%ebp),%eax
  800907:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	89 04 24             	mov    %eax,(%esp)
  800918:	e8 77 ff ff ff       	call   800894 <memmove>
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	57                   	push   %edi
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	8b 7d 08             	mov    0x8(%ebp),%edi
  800928:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092e:	ba 00 00 00 00       	mov    $0x0,%edx
  800933:	eb 16                	jmp    80094b <memcmp+0x2c>
		if (*s1 != *s2)
  800935:	8a 04 17             	mov    (%edi,%edx,1),%al
  800938:	42                   	inc    %edx
  800939:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80093d:	38 c8                	cmp    %cl,%al
  80093f:	74 0a                	je     80094b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800941:	0f b6 c0             	movzbl %al,%eax
  800944:	0f b6 c9             	movzbl %cl,%ecx
  800947:	29 c8                	sub    %ecx,%eax
  800949:	eb 09                	jmp    800954 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	39 da                	cmp    %ebx,%edx
  80094d:	75 e6                	jne    800935 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800962:	89 c2                	mov    %eax,%edx
  800964:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800967:	eb 05                	jmp    80096e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800969:	38 08                	cmp    %cl,(%eax)
  80096b:	74 05                	je     800972 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096d:	40                   	inc    %eax
  80096e:	39 d0                	cmp    %edx,%eax
  800970:	72 f7                	jb     800969 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 55 08             	mov    0x8(%ebp),%edx
  80097d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800980:	eb 01                	jmp    800983 <strtol+0xf>
		s++;
  800982:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800983:	8a 02                	mov    (%edx),%al
  800985:	3c 20                	cmp    $0x20,%al
  800987:	74 f9                	je     800982 <strtol+0xe>
  800989:	3c 09                	cmp    $0x9,%al
  80098b:	74 f5                	je     800982 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098d:	3c 2b                	cmp    $0x2b,%al
  80098f:	75 08                	jne    800999 <strtol+0x25>
		s++;
  800991:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800992:	bf 00 00 00 00       	mov    $0x0,%edi
  800997:	eb 13                	jmp    8009ac <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800999:	3c 2d                	cmp    $0x2d,%al
  80099b:	75 0a                	jne    8009a7 <strtol+0x33>
		s++, neg = 1;
  80099d:	8d 52 01             	lea    0x1(%edx),%edx
  8009a0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009a5:	eb 05                	jmp    8009ac <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ac:	85 db                	test   %ebx,%ebx
  8009ae:	74 05                	je     8009b5 <strtol+0x41>
  8009b0:	83 fb 10             	cmp    $0x10,%ebx
  8009b3:	75 28                	jne    8009dd <strtol+0x69>
  8009b5:	8a 02                	mov    (%edx),%al
  8009b7:	3c 30                	cmp    $0x30,%al
  8009b9:	75 10                	jne    8009cb <strtol+0x57>
  8009bb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009bf:	75 0a                	jne    8009cb <strtol+0x57>
		s += 2, base = 16;
  8009c1:	83 c2 02             	add    $0x2,%edx
  8009c4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c9:	eb 12                	jmp    8009dd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009cb:	85 db                	test   %ebx,%ebx
  8009cd:	75 0e                	jne    8009dd <strtol+0x69>
  8009cf:	3c 30                	cmp    $0x30,%al
  8009d1:	75 05                	jne    8009d8 <strtol+0x64>
		s++, base = 8;
  8009d3:	42                   	inc    %edx
  8009d4:	b3 08                	mov    $0x8,%bl
  8009d6:	eb 05                	jmp    8009dd <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009d8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e4:	8a 0a                	mov    (%edx),%cl
  8009e6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009e9:	80 fb 09             	cmp    $0x9,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0x82>
			dig = *s - '0';
  8009ee:	0f be c9             	movsbl %cl,%ecx
  8009f1:	83 e9 30             	sub    $0x30,%ecx
  8009f4:	eb 1e                	jmp    800a14 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009f6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009f9:	80 fb 19             	cmp    $0x19,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009fe:	0f be c9             	movsbl %cl,%ecx
  800a01:	83 e9 57             	sub    $0x57,%ecx
  800a04:	eb 0e                	jmp    800a14 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a06:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a09:	80 fb 19             	cmp    $0x19,%bl
  800a0c:	77 12                	ja     800a20 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a0e:	0f be c9             	movsbl %cl,%ecx
  800a11:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a14:	39 f1                	cmp    %esi,%ecx
  800a16:	7d 0c                	jge    800a24 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a18:	42                   	inc    %edx
  800a19:	0f af c6             	imul   %esi,%eax
  800a1c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a1e:	eb c4                	jmp    8009e4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a20:	89 c1                	mov    %eax,%ecx
  800a22:	eb 02                	jmp    800a26 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a24:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2a:	74 05                	je     800a31 <strtol+0xbd>
		*endptr = (char *) s;
  800a2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a31:	85 ff                	test   %edi,%edi
  800a33:	74 04                	je     800a39 <strtol+0xc5>
  800a35:	89 c8                	mov    %ecx,%eax
  800a37:	f7 d8                	neg    %eax
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    
	...

00800a40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a51:	89 c3                	mov    %eax,%ebx
  800a53:	89 c7                	mov    %eax,%edi
  800a55:	89 c6                	mov    %eax,%esi
  800a57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
  800a69:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6e:	89 d1                	mov    %edx,%ecx
  800a70:	89 d3                	mov    %edx,%ebx
  800a72:	89 d7                	mov    %edx,%edi
  800a74:	89 d6                	mov    %edx,%esi
  800a76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a90:	8b 55 08             	mov    0x8(%ebp),%edx
  800a93:	89 cb                	mov    %ecx,%ebx
  800a95:	89 cf                	mov    %ecx,%edi
  800a97:	89 ce                	mov    %ecx,%esi
  800a99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9b:	85 c0                	test   %eax,%eax
  800a9d:	7e 28                	jle    800ac7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aa3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aaa:	00 
  800aab:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800ab2:	00 
  800ab3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aba:	00 
  800abb:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800ac2:	e8 b5 15 00 00       	call   80207c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac7:	83 c4 2c             	add    $0x2c,%esp
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 02 00 00 00       	mov    $0x2,%eax
  800adf:	89 d1                	mov    %edx,%ecx
  800ae1:	89 d3                	mov    %edx,%ebx
  800ae3:	89 d7                	mov    %edx,%edi
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_yield>:

void
sys_yield(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	be 00 00 00 00       	mov    $0x0,%esi
  800b1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	89 f7                	mov    %esi,%edi
  800b2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	7e 28                	jle    800b59 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b35:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b3c:	00 
  800b3d:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800b44:	00 
  800b45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4c:	00 
  800b4d:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800b54:	e8 23 15 00 00       	call   80207c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b59:	83 c4 2c             	add    $0x2c,%esp
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b80:	85 c0                	test   %eax,%eax
  800b82:	7e 28                	jle    800bac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b8f:	00 
  800b90:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800b97:	00 
  800b98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9f:	00 
  800ba0:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800ba7:	e8 d0 14 00 00       	call   80207c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bac:	83 c4 2c             	add    $0x2c,%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	89 df                	mov    %ebx,%edi
  800bcf:	89 de                	mov    %ebx,%esi
  800bd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 28                	jle    800bff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800be2:	00 
  800be3:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800bea:	00 
  800beb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf2:	00 
  800bf3:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800bfa:	e8 7d 14 00 00       	call   80207c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bff:	83 c4 2c             	add    $0x2c,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c15:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	89 df                	mov    %ebx,%edi
  800c22:	89 de                	mov    %ebx,%esi
  800c24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 28                	jle    800c52 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c35:	00 
  800c36:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800c3d:	00 
  800c3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c45:	00 
  800c46:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800c4d:	e8 2a 14 00 00       	call   80207c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c52:	83 c4 2c             	add    $0x2c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c68:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	89 df                	mov    %ebx,%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 28                	jle    800ca5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c81:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c88:	00 
  800c89:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800c90:	00 
  800c91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c98:	00 
  800c99:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800ca0:	e8 d7 13 00 00       	call   80207c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca5:	83 c4 2c             	add    $0x2c,%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	89 df                	mov    %ebx,%edi
  800cc8:	89 de                	mov    %ebx,%esi
  800cca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 28                	jle    800cf8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cdb:	00 
  800cdc:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ceb:	00 
  800cec:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800cf3:	e8 84 13 00 00       	call   80207c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf8:	83 c4 2c             	add    $0x2c,%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	be 00 00 00 00       	mov    $0x0,%esi
  800d0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 cb                	mov    %ecx,%ebx
  800d3b:	89 cf                	mov    %ecx,%edi
  800d3d:	89 ce                	mov    %ecx,%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 28                	jle    800d6d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d49:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d50:	00 
  800d51:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800d58:	00 
  800d59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d60:	00 
  800d61:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800d68:	e8 0f 13 00 00       	call   80207c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6d:	83 c4 2c             	add    $0x2c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d85:	89 d1                	mov    %edx,%ecx
  800d87:	89 d3                	mov    %edx,%ebx
  800d89:	89 d7                	mov    %edx,%edi
  800d8b:	89 d6                	mov    %edx,%esi
  800d8d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	89 df                	mov    %ebx,%edi
  800dac:	89 de                	mov    %ebx,%esi
  800dae:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc0:	b8 10 00 00 00       	mov    $0x10,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	89 df                	mov    %ebx,%edi
  800dcd:	89 de                	mov    %ebx,%esi
  800dcf:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    
	...

00800dd8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	05 00 00 00 30       	add    $0x30000000,%eax
  800de3:	c1 e8 0c             	shr    $0xc,%eax
}
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	89 04 24             	mov    %eax,(%esp)
  800df4:	e8 df ff ff ff       	call   800dd8 <fd2num>
  800df9:	c1 e0 0c             	shl    $0xc,%eax
  800dfc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    

00800e03 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	53                   	push   %ebx
  800e07:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e0a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e0f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	c1 ea 16             	shr    $0x16,%edx
  800e16:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1d:	f6 c2 01             	test   $0x1,%dl
  800e20:	74 11                	je     800e33 <fd_alloc+0x30>
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	c1 ea 0c             	shr    $0xc,%edx
  800e27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2e:	f6 c2 01             	test   $0x1,%dl
  800e31:	75 09                	jne    800e3c <fd_alloc+0x39>
			*fd_store = fd;
  800e33:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e35:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3a:	eb 17                	jmp    800e53 <fd_alloc+0x50>
  800e3c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e41:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e46:	75 c7                	jne    800e0f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e48:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e4e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e53:	5b                   	pop    %ebx
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e5c:	83 f8 1f             	cmp    $0x1f,%eax
  800e5f:	77 36                	ja     800e97 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e61:	c1 e0 0c             	shl    $0xc,%eax
  800e64:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	c1 ea 16             	shr    $0x16,%edx
  800e6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e75:	f6 c2 01             	test   $0x1,%dl
  800e78:	74 24                	je     800e9e <fd_lookup+0x48>
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	c1 ea 0c             	shr    $0xc,%edx
  800e7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e86:	f6 c2 01             	test   $0x1,%dl
  800e89:	74 1a                	je     800ea5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8e:	89 02                	mov    %eax,(%edx)
	return 0;
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	eb 13                	jmp    800eaa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9c:	eb 0c                	jmp    800eaa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea3:	eb 05                	jmp    800eaa <fd_lookup+0x54>
  800ea5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 14             	sub    $0x14,%esp
  800eb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebe:	eb 0e                	jmp    800ece <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800ec0:	39 08                	cmp    %ecx,(%eax)
  800ec2:	75 09                	jne    800ecd <dev_lookup+0x21>
			*dev = devtab[i];
  800ec4:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ec6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecb:	eb 33                	jmp    800f00 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ecd:	42                   	inc    %edx
  800ece:	8b 04 95 8c 28 80 00 	mov    0x80288c(,%edx,4),%eax
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	75 e7                	jne    800ec0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed9:	a1 08 40 80 00       	mov    0x804008,%eax
  800ede:	8b 40 48             	mov    0x48(%eax),%eax
  800ee1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee9:	c7 04 24 10 28 80 00 	movl   $0x802810,(%esp)
  800ef0:	e8 7b f2 ff ff       	call   800170 <cprintf>
	*dev = 0;
  800ef5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800efb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f00:	83 c4 14             	add    $0x14,%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 30             	sub    $0x30,%esp
  800f0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f11:	8a 45 0c             	mov    0xc(%ebp),%al
  800f14:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f17:	89 34 24             	mov    %esi,(%esp)
  800f1a:	e8 b9 fe ff ff       	call   800dd8 <fd2num>
  800f1f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f22:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f26:	89 04 24             	mov    %eax,(%esp)
  800f29:	e8 28 ff ff ff       	call   800e56 <fd_lookup>
  800f2e:	89 c3                	mov    %eax,%ebx
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 05                	js     800f39 <fd_close+0x33>
	    || fd != fd2)
  800f34:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f37:	74 0d                	je     800f46 <fd_close+0x40>
		return (must_exist ? r : 0);
  800f39:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f3d:	75 46                	jne    800f85 <fd_close+0x7f>
  800f3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f44:	eb 3f                	jmp    800f85 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4d:	8b 06                	mov    (%esi),%eax
  800f4f:	89 04 24             	mov    %eax,(%esp)
  800f52:	e8 55 ff ff ff       	call   800eac <dev_lookup>
  800f57:	89 c3                	mov    %eax,%ebx
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 18                	js     800f75 <fd_close+0x6f>
		if (dev->dev_close)
  800f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f60:	8b 40 10             	mov    0x10(%eax),%eax
  800f63:	85 c0                	test   %eax,%eax
  800f65:	74 09                	je     800f70 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f67:	89 34 24             	mov    %esi,(%esp)
  800f6a:	ff d0                	call   *%eax
  800f6c:	89 c3                	mov    %eax,%ebx
  800f6e:	eb 05                	jmp    800f75 <fd_close+0x6f>
		else
			r = 0;
  800f70:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f75:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f80:	e8 2f fc ff ff       	call   800bb4 <sys_page_unmap>
	return r;
}
  800f85:	89 d8                	mov    %ebx,%eax
  800f87:	83 c4 30             	add    $0x30,%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	89 04 24             	mov    %eax,(%esp)
  800fa1:	e8 b0 fe ff ff       	call   800e56 <fd_lookup>
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 13                	js     800fbd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800faa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fb1:	00 
  800fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb5:	89 04 24             	mov    %eax,(%esp)
  800fb8:	e8 49 ff ff ff       	call   800f06 <fd_close>
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <close_all>:

void
close_all(void)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	53                   	push   %ebx
  800fc3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fcb:	89 1c 24             	mov    %ebx,(%esp)
  800fce:	e8 bb ff ff ff       	call   800f8e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd3:	43                   	inc    %ebx
  800fd4:	83 fb 20             	cmp    $0x20,%ebx
  800fd7:	75 f2                	jne    800fcb <close_all+0xc>
		close(i);
}
  800fd9:	83 c4 14             	add    $0x14,%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	57                   	push   %edi
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 4c             	sub    $0x4c,%esp
  800fe8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800feb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff5:	89 04 24             	mov    %eax,(%esp)
  800ff8:	e8 59 fe ff ff       	call   800e56 <fd_lookup>
  800ffd:	89 c3                	mov    %eax,%ebx
  800fff:	85 c0                	test   %eax,%eax
  801001:	0f 88 e3 00 00 00    	js     8010ea <dup+0x10b>
		return r;
	close(newfdnum);
  801007:	89 3c 24             	mov    %edi,(%esp)
  80100a:	e8 7f ff ff ff       	call   800f8e <close>

	newfd = INDEX2FD(newfdnum);
  80100f:	89 fe                	mov    %edi,%esi
  801011:	c1 e6 0c             	shl    $0xc,%esi
  801014:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80101a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80101d:	89 04 24             	mov    %eax,(%esp)
  801020:	e8 c3 fd ff ff       	call   800de8 <fd2data>
  801025:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801027:	89 34 24             	mov    %esi,(%esp)
  80102a:	e8 b9 fd ff ff       	call   800de8 <fd2data>
  80102f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801032:	89 d8                	mov    %ebx,%eax
  801034:	c1 e8 16             	shr    $0x16,%eax
  801037:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103e:	a8 01                	test   $0x1,%al
  801040:	74 46                	je     801088 <dup+0xa9>
  801042:	89 d8                	mov    %ebx,%eax
  801044:	c1 e8 0c             	shr    $0xc,%eax
  801047:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104e:	f6 c2 01             	test   $0x1,%dl
  801051:	74 35                	je     801088 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801053:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105a:	25 07 0e 00 00       	and    $0xe07,%eax
  80105f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801063:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80106a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801071:	00 
  801072:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801076:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107d:	e8 df fa ff ff       	call   800b61 <sys_page_map>
  801082:	89 c3                	mov    %eax,%ebx
  801084:	85 c0                	test   %eax,%eax
  801086:	78 3b                	js     8010c3 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801088:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80108b:	89 c2                	mov    %eax,%edx
  80108d:	c1 ea 0c             	shr    $0xc,%edx
  801090:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801097:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80109d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010a1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010ac:	00 
  8010ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b8:	e8 a4 fa ff ff       	call   800b61 <sys_page_map>
  8010bd:	89 c3                	mov    %eax,%ebx
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	79 25                	jns    8010e8 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ce:	e8 e1 fa ff ff       	call   800bb4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e1:	e8 ce fa ff ff       	call   800bb4 <sys_page_unmap>
	return r;
  8010e6:	eb 02                	jmp    8010ea <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010e8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010ea:	89 d8                	mov    %ebx,%eax
  8010ec:	83 c4 4c             	add    $0x4c,%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 24             	sub    $0x24,%esp
  8010fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801101:	89 44 24 04          	mov    %eax,0x4(%esp)
  801105:	89 1c 24             	mov    %ebx,(%esp)
  801108:	e8 49 fd ff ff       	call   800e56 <fd_lookup>
  80110d:	85 c0                	test   %eax,%eax
  80110f:	78 6d                	js     80117e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801114:	89 44 24 04          	mov    %eax,0x4(%esp)
  801118:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111b:	8b 00                	mov    (%eax),%eax
  80111d:	89 04 24             	mov    %eax,(%esp)
  801120:	e8 87 fd ff ff       	call   800eac <dev_lookup>
  801125:	85 c0                	test   %eax,%eax
  801127:	78 55                	js     80117e <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801129:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112c:	8b 50 08             	mov    0x8(%eax),%edx
  80112f:	83 e2 03             	and    $0x3,%edx
  801132:	83 fa 01             	cmp    $0x1,%edx
  801135:	75 23                	jne    80115a <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801137:	a1 08 40 80 00       	mov    0x804008,%eax
  80113c:	8b 40 48             	mov    0x48(%eax),%eax
  80113f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801143:	89 44 24 04          	mov    %eax,0x4(%esp)
  801147:	c7 04 24 51 28 80 00 	movl   $0x802851,(%esp)
  80114e:	e8 1d f0 ff ff       	call   800170 <cprintf>
		return -E_INVAL;
  801153:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801158:	eb 24                	jmp    80117e <read+0x8a>
	}
	if (!dev->dev_read)
  80115a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80115d:	8b 52 08             	mov    0x8(%edx),%edx
  801160:	85 d2                	test   %edx,%edx
  801162:	74 15                	je     801179 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801164:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801167:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80116b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801172:	89 04 24             	mov    %eax,(%esp)
  801175:	ff d2                	call   *%edx
  801177:	eb 05                	jmp    80117e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801179:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80117e:	83 c4 24             	add    $0x24,%esp
  801181:	5b                   	pop    %ebx
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	57                   	push   %edi
  801188:	56                   	push   %esi
  801189:	53                   	push   %ebx
  80118a:	83 ec 1c             	sub    $0x1c,%esp
  80118d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801190:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801193:	bb 00 00 00 00       	mov    $0x0,%ebx
  801198:	eb 23                	jmp    8011bd <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80119a:	89 f0                	mov    %esi,%eax
  80119c:	29 d8                	sub    %ebx,%eax
  80119e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a5:	01 d8                	add    %ebx,%eax
  8011a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ab:	89 3c 24             	mov    %edi,(%esp)
  8011ae:	e8 41 ff ff ff       	call   8010f4 <read>
		if (m < 0)
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 10                	js     8011c7 <readn+0x43>
			return m;
		if (m == 0)
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	74 0a                	je     8011c5 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011bb:	01 c3                	add    %eax,%ebx
  8011bd:	39 f3                	cmp    %esi,%ebx
  8011bf:	72 d9                	jb     80119a <readn+0x16>
  8011c1:	89 d8                	mov    %ebx,%eax
  8011c3:	eb 02                	jmp    8011c7 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011c5:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011c7:	83 c4 1c             	add    $0x1c,%esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5e                   	pop    %esi
  8011cc:	5f                   	pop    %edi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 24             	sub    $0x24,%esp
  8011d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e0:	89 1c 24             	mov    %ebx,(%esp)
  8011e3:	e8 6e fc ff ff       	call   800e56 <fd_lookup>
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 68                	js     801254 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f6:	8b 00                	mov    (%eax),%eax
  8011f8:	89 04 24             	mov    %eax,(%esp)
  8011fb:	e8 ac fc ff ff       	call   800eac <dev_lookup>
  801200:	85 c0                	test   %eax,%eax
  801202:	78 50                	js     801254 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801204:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801207:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120b:	75 23                	jne    801230 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80120d:	a1 08 40 80 00       	mov    0x804008,%eax
  801212:	8b 40 48             	mov    0x48(%eax),%eax
  801215:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121d:	c7 04 24 6d 28 80 00 	movl   $0x80286d,(%esp)
  801224:	e8 47 ef ff ff       	call   800170 <cprintf>
		return -E_INVAL;
  801229:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122e:	eb 24                	jmp    801254 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801230:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801233:	8b 52 0c             	mov    0xc(%edx),%edx
  801236:	85 d2                	test   %edx,%edx
  801238:	74 15                	je     80124f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80123a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80123d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801244:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801248:	89 04 24             	mov    %eax,(%esp)
  80124b:	ff d2                	call   *%edx
  80124d:	eb 05                	jmp    801254 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80124f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801254:	83 c4 24             	add    $0x24,%esp
  801257:	5b                   	pop    %ebx
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <seek>:

int
seek(int fdnum, off_t offset)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801260:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801263:	89 44 24 04          	mov    %eax,0x4(%esp)
  801267:	8b 45 08             	mov    0x8(%ebp),%eax
  80126a:	89 04 24             	mov    %eax,(%esp)
  80126d:	e8 e4 fb ff ff       	call   800e56 <fd_lookup>
  801272:	85 c0                	test   %eax,%eax
  801274:	78 0e                	js     801284 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801276:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80127f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801284:	c9                   	leave  
  801285:	c3                   	ret    

00801286 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	53                   	push   %ebx
  80128a:	83 ec 24             	sub    $0x24,%esp
  80128d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801290:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801293:	89 44 24 04          	mov    %eax,0x4(%esp)
  801297:	89 1c 24             	mov    %ebx,(%esp)
  80129a:	e8 b7 fb ff ff       	call   800e56 <fd_lookup>
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 61                	js     801304 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ad:	8b 00                	mov    (%eax),%eax
  8012af:	89 04 24             	mov    %eax,(%esp)
  8012b2:	e8 f5 fb ff ff       	call   800eac <dev_lookup>
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 49                	js     801304 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c2:	75 23                	jne    8012e7 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012c4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012c9:	8b 40 48             	mov    0x48(%eax),%eax
  8012cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d4:	c7 04 24 30 28 80 00 	movl   $0x802830,(%esp)
  8012db:	e8 90 ee ff ff       	call   800170 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e5:	eb 1d                	jmp    801304 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8012e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ea:	8b 52 18             	mov    0x18(%edx),%edx
  8012ed:	85 d2                	test   %edx,%edx
  8012ef:	74 0e                	je     8012ff <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012f8:	89 04 24             	mov    %eax,(%esp)
  8012fb:	ff d2                	call   *%edx
  8012fd:	eb 05                	jmp    801304 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801304:	83 c4 24             	add    $0x24,%esp
  801307:	5b                   	pop    %ebx
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    

0080130a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80130a:	55                   	push   %ebp
  80130b:	89 e5                	mov    %esp,%ebp
  80130d:	53                   	push   %ebx
  80130e:	83 ec 24             	sub    $0x24,%esp
  801311:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801314:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801317:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	89 04 24             	mov    %eax,(%esp)
  801321:	e8 30 fb ff ff       	call   800e56 <fd_lookup>
  801326:	85 c0                	test   %eax,%eax
  801328:	78 52                	js     80137c <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801331:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801334:	8b 00                	mov    (%eax),%eax
  801336:	89 04 24             	mov    %eax,(%esp)
  801339:	e8 6e fb ff ff       	call   800eac <dev_lookup>
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 3a                	js     80137c <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801342:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801345:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801349:	74 2c                	je     801377 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80134b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80134e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801355:	00 00 00 
	stat->st_isdir = 0;
  801358:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80135f:	00 00 00 
	stat->st_dev = dev;
  801362:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801368:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80136c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80136f:	89 14 24             	mov    %edx,(%esp)
  801372:	ff 50 14             	call   *0x14(%eax)
  801375:	eb 05                	jmp    80137c <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801377:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80137c:	83 c4 24             	add    $0x24,%esp
  80137f:	5b                   	pop    %ebx
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	56                   	push   %esi
  801386:	53                   	push   %ebx
  801387:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80138a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801391:	00 
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
  801395:	89 04 24             	mov    %eax,(%esp)
  801398:	e8 2a 02 00 00       	call   8015c7 <open>
  80139d:	89 c3                	mov    %eax,%ebx
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 1b                	js     8013be <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013aa:	89 1c 24             	mov    %ebx,(%esp)
  8013ad:	e8 58 ff ff ff       	call   80130a <fstat>
  8013b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b4:	89 1c 24             	mov    %ebx,(%esp)
  8013b7:	e8 d2 fb ff ff       	call   800f8e <close>
	return r;
  8013bc:	89 f3                	mov    %esi,%ebx
}
  8013be:	89 d8                	mov    %ebx,%eax
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    
	...

008013c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 10             	sub    $0x10,%esp
  8013d0:	89 c3                	mov    %eax,%ebx
  8013d2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013d4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013db:	75 11                	jne    8013ee <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8013e4:	e8 de 0d 00 00       	call   8021c7 <ipc_find_env>
  8013e9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ee:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013f5:	00 
  8013f6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013fd:	00 
  8013fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801402:	a1 00 40 80 00       	mov    0x804000,%eax
  801407:	89 04 24             	mov    %eax,(%esp)
  80140a:	e8 35 0d 00 00       	call   802144 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80140f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801416:	00 
  801417:	89 74 24 04          	mov    %esi,0x4(%esp)
  80141b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801422:	e8 ad 0c 00 00       	call   8020d4 <ipc_recv>
}
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801434:	8b 45 08             	mov    0x8(%ebp),%eax
  801437:	8b 40 0c             	mov    0xc(%eax),%eax
  80143a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80143f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801442:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801447:	ba 00 00 00 00       	mov    $0x0,%edx
  80144c:	b8 02 00 00 00       	mov    $0x2,%eax
  801451:	e8 72 ff ff ff       	call   8013c8 <fsipc>
}
  801456:	c9                   	leave  
  801457:	c3                   	ret    

00801458 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145e:	8b 45 08             	mov    0x8(%ebp),%eax
  801461:	8b 40 0c             	mov    0xc(%eax),%eax
  801464:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801469:	ba 00 00 00 00       	mov    $0x0,%edx
  80146e:	b8 06 00 00 00       	mov    $0x6,%eax
  801473:	e8 50 ff ff ff       	call   8013c8 <fsipc>
}
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	53                   	push   %ebx
  80147e:	83 ec 14             	sub    $0x14,%esp
  801481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	8b 40 0c             	mov    0xc(%eax),%eax
  80148a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148f:	ba 00 00 00 00       	mov    $0x0,%edx
  801494:	b8 05 00 00 00       	mov    $0x5,%eax
  801499:	e8 2a ff ff ff       	call   8013c8 <fsipc>
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 2b                	js     8014cd <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014a9:	00 
  8014aa:	89 1c 24             	mov    %ebx,(%esp)
  8014ad:	e8 69 f2 ff ff       	call   80071b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014cd:	83 c4 14             	add    $0x14,%esp
  8014d0:	5b                   	pop    %ebx
  8014d1:	5d                   	pop    %ebp
  8014d2:	c3                   	ret    

008014d3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 18             	sub    $0x18,%esp
  8014d9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8014df:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014e8:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014f4:	76 05                	jbe    8014fb <devfile_write+0x28>
  8014f6:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8014fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801502:	89 44 24 04          	mov    %eax,0x4(%esp)
  801506:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80150d:	e8 ec f3 ff ff       	call   8008fe <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801512:	ba 00 00 00 00       	mov    $0x0,%edx
  801517:	b8 04 00 00 00       	mov    $0x4,%eax
  80151c:	e8 a7 fe ff ff       	call   8013c8 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	83 ec 10             	sub    $0x10,%esp
  80152b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152e:	8b 45 08             	mov    0x8(%ebp),%eax
  801531:	8b 40 0c             	mov    0xc(%eax),%eax
  801534:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801539:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80153f:	ba 00 00 00 00       	mov    $0x0,%edx
  801544:	b8 03 00 00 00       	mov    $0x3,%eax
  801549:	e8 7a fe ff ff       	call   8013c8 <fsipc>
  80154e:	89 c3                	mov    %eax,%ebx
  801550:	85 c0                	test   %eax,%eax
  801552:	78 6a                	js     8015be <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801554:	39 c6                	cmp    %eax,%esi
  801556:	73 24                	jae    80157c <devfile_read+0x59>
  801558:	c7 44 24 0c a0 28 80 	movl   $0x8028a0,0xc(%esp)
  80155f:	00 
  801560:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  801567:	00 
  801568:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80156f:	00 
  801570:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  801577:	e8 00 0b 00 00       	call   80207c <_panic>
	assert(r <= PGSIZE);
  80157c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801581:	7e 24                	jle    8015a7 <devfile_read+0x84>
  801583:	c7 44 24 0c c7 28 80 	movl   $0x8028c7,0xc(%esp)
  80158a:	00 
  80158b:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  801592:	00 
  801593:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80159a:	00 
  80159b:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  8015a2:	e8 d5 0a 00 00       	call   80207c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ab:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015b2:	00 
  8015b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b6:	89 04 24             	mov    %eax,(%esp)
  8015b9:	e8 d6 f2 ff ff       	call   800894 <memmove>
	return r;
}
  8015be:	89 d8                	mov    %ebx,%eax
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	5b                   	pop    %ebx
  8015c4:	5e                   	pop    %esi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 20             	sub    $0x20,%esp
  8015cf:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d2:	89 34 24             	mov    %esi,(%esp)
  8015d5:	e8 0e f1 ff ff       	call   8006e8 <strlen>
  8015da:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015df:	7f 60                	jg     801641 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e4:	89 04 24             	mov    %eax,(%esp)
  8015e7:	e8 17 f8 ff ff       	call   800e03 <fd_alloc>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 54                	js     801646 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8015fd:	e8 19 f1 ff ff       	call   80071b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801602:	8b 45 0c             	mov    0xc(%ebp),%eax
  801605:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80160a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160d:	b8 01 00 00 00       	mov    $0x1,%eax
  801612:	e8 b1 fd ff ff       	call   8013c8 <fsipc>
  801617:	89 c3                	mov    %eax,%ebx
  801619:	85 c0                	test   %eax,%eax
  80161b:	79 15                	jns    801632 <open+0x6b>
		fd_close(fd, 0);
  80161d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801624:	00 
  801625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801628:	89 04 24             	mov    %eax,(%esp)
  80162b:	e8 d6 f8 ff ff       	call   800f06 <fd_close>
		return r;
  801630:	eb 14                	jmp    801646 <open+0x7f>
	}

	return fd2num(fd);
  801632:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801635:	89 04 24             	mov    %eax,(%esp)
  801638:	e8 9b f7 ff ff       	call   800dd8 <fd2num>
  80163d:	89 c3                	mov    %eax,%ebx
  80163f:	eb 05                	jmp    801646 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801641:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801646:	89 d8                	mov    %ebx,%eax
  801648:	83 c4 20             	add    $0x20,%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801655:	ba 00 00 00 00       	mov    $0x0,%edx
  80165a:	b8 08 00 00 00       	mov    $0x8,%eax
  80165f:	e8 64 fd ff ff       	call   8013c8 <fsipc>
}
  801664:	c9                   	leave  
  801665:	c3                   	ret    
	...

00801668 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  80166e:	c7 44 24 04 d3 28 80 	movl   $0x8028d3,0x4(%esp)
  801675:	00 
  801676:	8b 45 0c             	mov    0xc(%ebp),%eax
  801679:	89 04 24             	mov    %eax,(%esp)
  80167c:	e8 9a f0 ff ff       	call   80071b <strcpy>
	return 0;
}
  801681:	b8 00 00 00 00       	mov    $0x0,%eax
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	53                   	push   %ebx
  80168c:	83 ec 14             	sub    $0x14,%esp
  80168f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801692:	89 1c 24             	mov    %ebx,(%esp)
  801695:	e8 72 0b 00 00       	call   80220c <pageref>
  80169a:	83 f8 01             	cmp    $0x1,%eax
  80169d:	75 0d                	jne    8016ac <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80169f:	8b 43 0c             	mov    0xc(%ebx),%eax
  8016a2:	89 04 24             	mov    %eax,(%esp)
  8016a5:	e8 1f 03 00 00       	call   8019c9 <nsipc_close>
  8016aa:	eb 05                	jmp    8016b1 <devsock_close+0x29>
	else
		return 0;
  8016ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b1:	83 c4 14             	add    $0x14,%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016c4:	00 
  8016c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d9:	89 04 24             	mov    %eax,(%esp)
  8016dc:	e8 e3 03 00 00       	call   801ac4 <nsipc_send>
}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016f0:	00 
  8016f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 40 0c             	mov    0xc(%eax),%eax
  801705:	89 04 24             	mov    %eax,(%esp)
  801708:	e8 37 03 00 00       	call   801a44 <nsipc_recv>
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	83 ec 20             	sub    $0x20,%esp
  801717:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801719:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171c:	89 04 24             	mov    %eax,(%esp)
  80171f:	e8 df f6 ff ff       	call   800e03 <fd_alloc>
  801724:	89 c3                	mov    %eax,%ebx
  801726:	85 c0                	test   %eax,%eax
  801728:	78 21                	js     80174b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80172a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801731:	00 
  801732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801735:	89 44 24 04          	mov    %eax,0x4(%esp)
  801739:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801740:	e8 c8 f3 ff ff       	call   800b0d <sys_page_alloc>
  801745:	89 c3                	mov    %eax,%ebx
  801747:	85 c0                	test   %eax,%eax
  801749:	79 0a                	jns    801755 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80174b:	89 34 24             	mov    %esi,(%esp)
  80174e:	e8 76 02 00 00       	call   8019c9 <nsipc_close>
		return r;
  801753:	eb 22                	jmp    801777 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801755:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80175b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801760:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801763:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80176a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80176d:	89 04 24             	mov    %eax,(%esp)
  801770:	e8 63 f6 ff ff       	call   800dd8 <fd2num>
  801775:	89 c3                	mov    %eax,%ebx
}
  801777:	89 d8                	mov    %ebx,%eax
  801779:	83 c4 20             	add    $0x20,%esp
  80177c:	5b                   	pop    %ebx
  80177d:	5e                   	pop    %esi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801786:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801789:	89 54 24 04          	mov    %edx,0x4(%esp)
  80178d:	89 04 24             	mov    %eax,(%esp)
  801790:	e8 c1 f6 ff ff       	call   800e56 <fd_lookup>
  801795:	85 c0                	test   %eax,%eax
  801797:	78 17                	js     8017b0 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801799:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a2:	39 10                	cmp    %edx,(%eax)
  8017a4:	75 05                	jne    8017ab <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8017a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a9:	eb 05                	jmp    8017b0 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8017ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	e8 c0 ff ff ff       	call   801780 <fd2sockid>
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 1f                	js     8017e3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8017c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017d2:	89 04 24             	mov    %eax,(%esp)
  8017d5:	e8 38 01 00 00       	call   801912 <nsipc_accept>
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	78 05                	js     8017e3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8017de:	e8 2c ff ff ff       	call   80170f <alloc_sockfd>
}
  8017e3:	c9                   	leave  
  8017e4:	c3                   	ret    

008017e5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	e8 8d ff ff ff       	call   801780 <fd2sockid>
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 16                	js     80180d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8017f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8017fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801801:	89 54 24 04          	mov    %edx,0x4(%esp)
  801805:	89 04 24             	mov    %eax,(%esp)
  801808:	e8 5b 01 00 00       	call   801968 <nsipc_bind>
}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <shutdown>:

int
shutdown(int s, int how)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	e8 63 ff ff ff       	call   801780 <fd2sockid>
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 0f                	js     801830 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801821:	8b 55 0c             	mov    0xc(%ebp),%edx
  801824:	89 54 24 04          	mov    %edx,0x4(%esp)
  801828:	89 04 24             	mov    %eax,(%esp)
  80182b:	e8 77 01 00 00       	call   8019a7 <nsipc_shutdown>
}
  801830:	c9                   	leave  
  801831:	c3                   	ret    

00801832 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801838:	8b 45 08             	mov    0x8(%ebp),%eax
  80183b:	e8 40 ff ff ff       	call   801780 <fd2sockid>
  801840:	85 c0                	test   %eax,%eax
  801842:	78 16                	js     80185a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801844:	8b 55 10             	mov    0x10(%ebp),%edx
  801847:	89 54 24 08          	mov    %edx,0x8(%esp)
  80184b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80184e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	e8 89 01 00 00       	call   8019e3 <nsipc_connect>
}
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <listen>:

int
listen(int s, int backlog)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	e8 16 ff ff ff       	call   801780 <fd2sockid>
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 0f                	js     80187d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80186e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801871:	89 54 24 04          	mov    %edx,0x4(%esp)
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 a5 01 00 00       	call   801a22 <nsipc_listen>
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801885:	8b 45 10             	mov    0x10(%ebp),%eax
  801888:	89 44 24 08          	mov    %eax,0x8(%esp)
  80188c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801893:	8b 45 08             	mov    0x8(%ebp),%eax
  801896:	89 04 24             	mov    %eax,(%esp)
  801899:	e8 99 02 00 00       	call   801b37 <nsipc_socket>
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 05                	js     8018a7 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8018a2:	e8 68 fe ff ff       	call   80170f <alloc_sockfd>
}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    
  8018a9:	00 00                	add    %al,(%eax)
	...

008018ac <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 14             	sub    $0x14,%esp
  8018b3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018b5:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018bc:	75 11                	jne    8018cf <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018be:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8018c5:	e8 fd 08 00 00       	call   8021c7 <ipc_find_env>
  8018ca:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018cf:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018d6:	00 
  8018d7:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8018de:	00 
  8018df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e8:	89 04 24             	mov    %eax,(%esp)
  8018eb:	e8 54 08 00 00       	call   802144 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018f7:	00 
  8018f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018ff:	00 
  801900:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801907:	e8 c8 07 00 00       	call   8020d4 <ipc_recv>
}
  80190c:	83 c4 14             	add    $0x14,%esp
  80190f:	5b                   	pop    %ebx
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	83 ec 10             	sub    $0x10,%esp
  80191a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801925:	8b 06                	mov    (%esi),%eax
  801927:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80192c:	b8 01 00 00 00       	mov    $0x1,%eax
  801931:	e8 76 ff ff ff       	call   8018ac <nsipc>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 23                	js     80195f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80193c:	a1 10 60 80 00       	mov    0x806010,%eax
  801941:	89 44 24 08          	mov    %eax,0x8(%esp)
  801945:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80194c:	00 
  80194d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801950:	89 04 24             	mov    %eax,(%esp)
  801953:	e8 3c ef ff ff       	call   800894 <memmove>
		*addrlen = ret->ret_addrlen;
  801958:	a1 10 60 80 00       	mov    0x806010,%eax
  80195d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  80195f:	89 d8                	mov    %ebx,%eax
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	5b                   	pop    %ebx
  801965:	5e                   	pop    %esi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	83 ec 14             	sub    $0x14,%esp
  80196f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80197a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80197e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801981:	89 44 24 04          	mov    %eax,0x4(%esp)
  801985:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80198c:	e8 03 ef ff ff       	call   800894 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801991:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801997:	b8 02 00 00 00       	mov    $0x2,%eax
  80199c:	e8 0b ff ff ff       	call   8018ac <nsipc>
}
  8019a1:	83 c4 14             	add    $0x14,%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5d                   	pop    %ebp
  8019a6:	c3                   	ret    

008019a7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c2:	e8 e5 fe ff ff       	call   8018ac <nsipc>
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <nsipc_close>:

int
nsipc_close(int s)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8019dc:	e8 cb fe ff ff       	call   8018ac <nsipc>
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 14             	sub    $0x14,%esp
  8019ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019f5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a00:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801a07:	e8 88 ee ff ff       	call   800894 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a0c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a12:	b8 05 00 00 00       	mov    $0x5,%eax
  801a17:	e8 90 fe ff ff       	call   8018ac <nsipc>
}
  801a1c:	83 c4 14             	add    $0x14,%esp
  801a1f:	5b                   	pop    %ebx
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a33:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a38:	b8 06 00 00 00       	mov    $0x6,%eax
  801a3d:	e8 6a fe ff ff       	call   8018ac <nsipc>
}
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	56                   	push   %esi
  801a48:	53                   	push   %ebx
  801a49:	83 ec 10             	sub    $0x10,%esp
  801a4c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a52:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a57:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a5d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a60:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a65:	b8 07 00 00 00       	mov    $0x7,%eax
  801a6a:	e8 3d fe ff ff       	call   8018ac <nsipc>
  801a6f:	89 c3                	mov    %eax,%ebx
  801a71:	85 c0                	test   %eax,%eax
  801a73:	78 46                	js     801abb <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801a75:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a7a:	7f 04                	jg     801a80 <nsipc_recv+0x3c>
  801a7c:	39 c6                	cmp    %eax,%esi
  801a7e:	7d 24                	jge    801aa4 <nsipc_recv+0x60>
  801a80:	c7 44 24 0c df 28 80 	movl   $0x8028df,0xc(%esp)
  801a87:	00 
  801a88:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  801a8f:	00 
  801a90:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801a97:	00 
  801a98:	c7 04 24 f4 28 80 00 	movl   $0x8028f4,(%esp)
  801a9f:	e8 d8 05 00 00       	call   80207c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801aa4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa8:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801aaf:	00 
  801ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab3:	89 04 24             	mov    %eax,(%esp)
  801ab6:	e8 d9 ed ff ff       	call   800894 <memmove>
	}

	return r;
}
  801abb:	89 d8                	mov    %ebx,%eax
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 14             	sub    $0x14,%esp
  801acb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ad6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801adc:	7e 24                	jle    801b02 <nsipc_send+0x3e>
  801ade:	c7 44 24 0c 00 29 80 	movl   $0x802900,0xc(%esp)
  801ae5:	00 
  801ae6:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  801aed:	00 
  801aee:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801af5:	00 
  801af6:	c7 04 24 f4 28 80 00 	movl   $0x8028f4,(%esp)
  801afd:	e8 7a 05 00 00       	call   80207c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b02:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801b14:	e8 7b ed ff ff       	call   800894 <memmove>
	nsipcbuf.send.req_size = size;
  801b19:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801b22:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b27:	b8 08 00 00 00       	mov    $0x8,%eax
  801b2c:	e8 7b fd ff ff       	call   8018ac <nsipc>
}
  801b31:	83 c4 14             	add    $0x14,%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    

00801b37 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b40:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b48:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b50:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b55:	b8 09 00 00 00       	mov    $0x9,%eax
  801b5a:	e8 4d fd ff ff       	call   8018ac <nsipc>
}
  801b5f:	c9                   	leave  
  801b60:	c3                   	ret    
  801b61:	00 00                	add    %al,(%eax)
	...

00801b64 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	56                   	push   %esi
  801b68:	53                   	push   %ebx
  801b69:	83 ec 10             	sub    $0x10,%esp
  801b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 6e f2 ff ff       	call   800de8 <fd2data>
  801b7a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b7c:	c7 44 24 04 0c 29 80 	movl   $0x80290c,0x4(%esp)
  801b83:	00 
  801b84:	89 34 24             	mov    %esi,(%esp)
  801b87:	e8 8f eb ff ff       	call   80071b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b8c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b8f:	2b 03                	sub    (%ebx),%eax
  801b91:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b97:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b9e:	00 00 00 
	stat->st_dev = &devpipe;
  801ba1:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801ba8:	30 80 00 
	return 0;
}
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5d                   	pop    %ebp
  801bb6:	c3                   	ret    

00801bb7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	53                   	push   %ebx
  801bbb:	83 ec 14             	sub    $0x14,%esp
  801bbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bc1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bcc:	e8 e3 ef ff ff       	call   800bb4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bd1:	89 1c 24             	mov    %ebx,(%esp)
  801bd4:	e8 0f f2 ff ff       	call   800de8 <fd2data>
  801bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be4:	e8 cb ef ff ff       	call   800bb4 <sys_page_unmap>
}
  801be9:	83 c4 14             	add    $0x14,%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	57                   	push   %edi
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	83 ec 2c             	sub    $0x2c,%esp
  801bf8:	89 c7                	mov    %eax,%edi
  801bfa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bfd:	a1 08 40 80 00       	mov    0x804008,%eax
  801c02:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c05:	89 3c 24             	mov    %edi,(%esp)
  801c08:	e8 ff 05 00 00       	call   80220c <pageref>
  801c0d:	89 c6                	mov    %eax,%esi
  801c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c12:	89 04 24             	mov    %eax,(%esp)
  801c15:	e8 f2 05 00 00       	call   80220c <pageref>
  801c1a:	39 c6                	cmp    %eax,%esi
  801c1c:	0f 94 c0             	sete   %al
  801c1f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c22:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c28:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c2b:	39 cb                	cmp    %ecx,%ebx
  801c2d:	75 08                	jne    801c37 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c2f:	83 c4 2c             	add    $0x2c,%esp
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5f                   	pop    %edi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c37:	83 f8 01             	cmp    $0x1,%eax
  801c3a:	75 c1                	jne    801bfd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c3c:	8b 42 58             	mov    0x58(%edx),%eax
  801c3f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c46:	00 
  801c47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c4f:	c7 04 24 13 29 80 00 	movl   $0x802913,(%esp)
  801c56:	e8 15 e5 ff ff       	call   800170 <cprintf>
  801c5b:	eb a0                	jmp    801bfd <_pipeisclosed+0xe>

00801c5d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	57                   	push   %edi
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	83 ec 1c             	sub    $0x1c,%esp
  801c66:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c69:	89 34 24             	mov    %esi,(%esp)
  801c6c:	e8 77 f1 ff ff       	call   800de8 <fd2data>
  801c71:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c73:	bf 00 00 00 00       	mov    $0x0,%edi
  801c78:	eb 3c                	jmp    801cb6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c7a:	89 da                	mov    %ebx,%edx
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	e8 6c ff ff ff       	call   801bef <_pipeisclosed>
  801c83:	85 c0                	test   %eax,%eax
  801c85:	75 38                	jne    801cbf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c87:	e8 62 ee ff ff       	call   800aee <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c8c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c8f:	8b 13                	mov    (%ebx),%edx
  801c91:	83 c2 20             	add    $0x20,%edx
  801c94:	39 d0                	cmp    %edx,%eax
  801c96:	73 e2                	jae    801c7a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c98:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801c9e:	89 c2                	mov    %eax,%edx
  801ca0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ca6:	79 05                	jns    801cad <devpipe_write+0x50>
  801ca8:	4a                   	dec    %edx
  801ca9:	83 ca e0             	or     $0xffffffe0,%edx
  801cac:	42                   	inc    %edx
  801cad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cb1:	40                   	inc    %eax
  801cb2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb5:	47                   	inc    %edi
  801cb6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cb9:	75 d1                	jne    801c8c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cbb:	89 f8                	mov    %edi,%eax
  801cbd:	eb 05                	jmp    801cc4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cbf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cc4:	83 c4 1c             	add    $0x1c,%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	57                   	push   %edi
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	83 ec 1c             	sub    $0x1c,%esp
  801cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cd8:	89 3c 24             	mov    %edi,(%esp)
  801cdb:	e8 08 f1 ff ff       	call   800de8 <fd2data>
  801ce0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce2:	be 00 00 00 00       	mov    $0x0,%esi
  801ce7:	eb 3a                	jmp    801d23 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ce9:	85 f6                	test   %esi,%esi
  801ceb:	74 04                	je     801cf1 <devpipe_read+0x25>
				return i;
  801ced:	89 f0                	mov    %esi,%eax
  801cef:	eb 40                	jmp    801d31 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cf1:	89 da                	mov    %ebx,%edx
  801cf3:	89 f8                	mov    %edi,%eax
  801cf5:	e8 f5 fe ff ff       	call   801bef <_pipeisclosed>
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	75 2e                	jne    801d2c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cfe:	e8 eb ed ff ff       	call   800aee <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d03:	8b 03                	mov    (%ebx),%eax
  801d05:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d08:	74 df                	je     801ce9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d0a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d0f:	79 05                	jns    801d16 <devpipe_read+0x4a>
  801d11:	48                   	dec    %eax
  801d12:	83 c8 e0             	or     $0xffffffe0,%eax
  801d15:	40                   	inc    %eax
  801d16:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d20:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d22:	46                   	inc    %esi
  801d23:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d26:	75 db                	jne    801d03 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d28:	89 f0                	mov    %esi,%eax
  801d2a:	eb 05                	jmp    801d31 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	57                   	push   %edi
  801d3d:	56                   	push   %esi
  801d3e:	53                   	push   %ebx
  801d3f:	83 ec 3c             	sub    $0x3c,%esp
  801d42:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d45:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d48:	89 04 24             	mov    %eax,(%esp)
  801d4b:	e8 b3 f0 ff ff       	call   800e03 <fd_alloc>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	85 c0                	test   %eax,%eax
  801d54:	0f 88 45 01 00 00    	js     801e9f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d61:	00 
  801d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d70:	e8 98 ed ff ff       	call   800b0d <sys_page_alloc>
  801d75:	89 c3                	mov    %eax,%ebx
  801d77:	85 c0                	test   %eax,%eax
  801d79:	0f 88 20 01 00 00    	js     801e9f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d7f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d82:	89 04 24             	mov    %eax,(%esp)
  801d85:	e8 79 f0 ff ff       	call   800e03 <fd_alloc>
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	0f 88 f8 00 00 00    	js     801e8c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d94:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d9b:	00 
  801d9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801daa:	e8 5e ed ff ff       	call   800b0d <sys_page_alloc>
  801daf:	89 c3                	mov    %eax,%ebx
  801db1:	85 c0                	test   %eax,%eax
  801db3:	0f 88 d3 00 00 00    	js     801e8c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dbc:	89 04 24             	mov    %eax,(%esp)
  801dbf:	e8 24 f0 ff ff       	call   800de8 <fd2data>
  801dc4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dcd:	00 
  801dce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd9:	e8 2f ed ff ff       	call   800b0d <sys_page_alloc>
  801dde:	89 c3                	mov    %eax,%ebx
  801de0:	85 c0                	test   %eax,%eax
  801de2:	0f 88 91 00 00 00    	js     801e79 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801deb:	89 04 24             	mov    %eax,(%esp)
  801dee:	e8 f5 ef ff ff       	call   800de8 <fd2data>
  801df3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801dfa:	00 
  801dfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e06:	00 
  801e07:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e12:	e8 4a ed ff ff       	call   800b61 <sys_page_map>
  801e17:	89 c3                	mov    %eax,%ebx
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	78 4c                	js     801e69 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e1d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e26:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e32:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e3b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e40:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e4a:	89 04 24             	mov    %eax,(%esp)
  801e4d:	e8 86 ef ff ff       	call   800dd8 <fd2num>
  801e52:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e57:	89 04 24             	mov    %eax,(%esp)
  801e5a:	e8 79 ef ff ff       	call   800dd8 <fd2num>
  801e5f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e62:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e67:	eb 36                	jmp    801e9f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e69:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e74:	e8 3b ed ff ff       	call   800bb4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e79:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e87:	e8 28 ed ff ff       	call   800bb4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9a:	e8 15 ed ff ff       	call   800bb4 <sys_page_unmap>
    err:
	return r;
}
  801e9f:	89 d8                	mov    %ebx,%eax
  801ea1:	83 c4 3c             	add    $0x3c,%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5f                   	pop    %edi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb9:	89 04 24             	mov    %eax,(%esp)
  801ebc:	e8 95 ef ff ff       	call   800e56 <fd_lookup>
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 15                	js     801eda <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec8:	89 04 24             	mov    %eax,(%esp)
  801ecb:	e8 18 ef ff ff       	call   800de8 <fd2data>
	return _pipeisclosed(fd, p);
  801ed0:	89 c2                	mov    %eax,%edx
  801ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed5:	e8 15 fd ff ff       	call   801bef <_pipeisclosed>
}
  801eda:	c9                   	leave  
  801edb:	c3                   	ret    

00801edc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801edf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    

00801ee6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801eec:	c7 44 24 04 2b 29 80 	movl   $0x80292b,0x4(%esp)
  801ef3:	00 
  801ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef7:	89 04 24             	mov    %eax,(%esp)
  801efa:	e8 1c e8 ff ff       	call   80071b <strcpy>
	return 0;
}
  801eff:	b8 00 00 00 00       	mov    $0x0,%eax
  801f04:	c9                   	leave  
  801f05:	c3                   	ret    

00801f06 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	57                   	push   %edi
  801f0a:	56                   	push   %esi
  801f0b:	53                   	push   %ebx
  801f0c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f12:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f17:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f1d:	eb 30                	jmp    801f4f <devcons_write+0x49>
		m = n - tot;
  801f1f:	8b 75 10             	mov    0x10(%ebp),%esi
  801f22:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f24:	83 fe 7f             	cmp    $0x7f,%esi
  801f27:	76 05                	jbe    801f2e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f29:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f2e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f32:	03 45 0c             	add    0xc(%ebp),%eax
  801f35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f39:	89 3c 24             	mov    %edi,(%esp)
  801f3c:	e8 53 e9 ff ff       	call   800894 <memmove>
		sys_cputs(buf, m);
  801f41:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f45:	89 3c 24             	mov    %edi,(%esp)
  801f48:	e8 f3 ea ff ff       	call   800a40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f4d:	01 f3                	add    %esi,%ebx
  801f4f:	89 d8                	mov    %ebx,%eax
  801f51:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f54:	72 c9                	jb     801f1f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f56:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5f                   	pop    %edi
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f6b:	75 07                	jne    801f74 <devcons_read+0x13>
  801f6d:	eb 25                	jmp    801f94 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f6f:	e8 7a eb ff ff       	call   800aee <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f74:	e8 e5 ea ff ff       	call   800a5e <sys_cgetc>
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	74 f2                	je     801f6f <devcons_read+0xe>
  801f7d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	78 1d                	js     801fa0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f83:	83 f8 04             	cmp    $0x4,%eax
  801f86:	74 13                	je     801f9b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8b:	88 10                	mov    %dl,(%eax)
	return 1;
  801f8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f92:	eb 0c                	jmp    801fa0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f94:	b8 00 00 00 00       	mov    $0x0,%eax
  801f99:	eb 05                	jmp    801fa0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fb5:	00 
  801fb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fb9:	89 04 24             	mov    %eax,(%esp)
  801fbc:	e8 7f ea ff ff       	call   800a40 <sys_cputs>
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <getchar>:

int
getchar(void)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fc9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801fd0:	00 
  801fd1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fdf:	e8 10 f1 ff ff       	call   8010f4 <read>
	if (r < 0)
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	78 0f                	js     801ff7 <getchar+0x34>
		return r;
	if (r < 1)
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	7e 06                	jle    801ff2 <getchar+0x2f>
		return -E_EOF;
	return c;
  801fec:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ff0:	eb 05                	jmp    801ff7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ff2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ff7:	c9                   	leave  
  801ff8:	c3                   	ret    

00801ff9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802002:	89 44 24 04          	mov    %eax,0x4(%esp)
  802006:	8b 45 08             	mov    0x8(%ebp),%eax
  802009:	89 04 24             	mov    %eax,(%esp)
  80200c:	e8 45 ee ff ff       	call   800e56 <fd_lookup>
  802011:	85 c0                	test   %eax,%eax
  802013:	78 11                	js     802026 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802018:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80201e:	39 10                	cmp    %edx,(%eax)
  802020:	0f 94 c0             	sete   %al
  802023:	0f b6 c0             	movzbl %al,%eax
}
  802026:	c9                   	leave  
  802027:	c3                   	ret    

00802028 <opencons>:

int
opencons(void)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80202e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802031:	89 04 24             	mov    %eax,(%esp)
  802034:	e8 ca ed ff ff       	call   800e03 <fd_alloc>
  802039:	85 c0                	test   %eax,%eax
  80203b:	78 3c                	js     802079 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80203d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802044:	00 
  802045:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802048:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802053:	e8 b5 ea ff ff       	call   800b0d <sys_page_alloc>
  802058:	85 c0                	test   %eax,%eax
  80205a:	78 1d                	js     802079 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80205c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802062:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802065:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802067:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802071:	89 04 24             	mov    %eax,(%esp)
  802074:	e8 5f ed ff ff       	call   800dd8 <fd2num>
}
  802079:	c9                   	leave  
  80207a:	c3                   	ret    
	...

0080207c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	56                   	push   %esi
  802080:	53                   	push   %ebx
  802081:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802084:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802087:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80208d:	e8 3d ea ff ff       	call   800acf <sys_getenvid>
  802092:	8b 55 0c             	mov    0xc(%ebp),%edx
  802095:	89 54 24 10          	mov    %edx,0x10(%esp)
  802099:	8b 55 08             	mov    0x8(%ebp),%edx
  80209c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a8:	c7 04 24 38 29 80 00 	movl   $0x802938,(%esp)
  8020af:	e8 bc e0 ff ff       	call   800170 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8020bb:	89 04 24             	mov    %eax,(%esp)
  8020be:	e8 4c e0 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  8020c3:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  8020ca:	e8 a1 e0 ff ff       	call   800170 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020cf:	cc                   	int3   
  8020d0:	eb fd                	jmp    8020cf <_panic+0x53>
	...

008020d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	56                   	push   %esi
  8020d8:	53                   	push   %ebx
  8020d9:	83 ec 10             	sub    $0x10,%esp
  8020dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	74 0a                	je     8020f3 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8020e9:	89 04 24             	mov    %eax,(%esp)
  8020ec:	e8 32 ec ff ff       	call   800d23 <sys_ipc_recv>
  8020f1:	eb 0c                	jmp    8020ff <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8020f3:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8020fa:	e8 24 ec ff ff       	call   800d23 <sys_ipc_recv>
	}
	if (r < 0)
  8020ff:	85 c0                	test   %eax,%eax
  802101:	79 16                	jns    802119 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802103:	85 db                	test   %ebx,%ebx
  802105:	74 06                	je     80210d <ipc_recv+0x39>
  802107:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  80210d:	85 f6                	test   %esi,%esi
  80210f:	74 2c                	je     80213d <ipc_recv+0x69>
  802111:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802117:	eb 24                	jmp    80213d <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802119:	85 db                	test   %ebx,%ebx
  80211b:	74 0a                	je     802127 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  80211d:	a1 08 40 80 00       	mov    0x804008,%eax
  802122:	8b 40 74             	mov    0x74(%eax),%eax
  802125:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802127:	85 f6                	test   %esi,%esi
  802129:	74 0a                	je     802135 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80212b:	a1 08 40 80 00       	mov    0x804008,%eax
  802130:	8b 40 78             	mov    0x78(%eax),%eax
  802133:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802135:	a1 08 40 80 00       	mov    0x804008,%eax
  80213a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    

00802144 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	57                   	push   %edi
  802148:	56                   	push   %esi
  802149:	53                   	push   %ebx
  80214a:	83 ec 1c             	sub    $0x1c,%esp
  80214d:	8b 75 08             	mov    0x8(%ebp),%esi
  802150:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802153:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802156:	85 db                	test   %ebx,%ebx
  802158:	74 19                	je     802173 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80215a:	8b 45 14             	mov    0x14(%ebp),%eax
  80215d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802161:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802165:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802169:	89 34 24             	mov    %esi,(%esp)
  80216c:	e8 8f eb ff ff       	call   800d00 <sys_ipc_try_send>
  802171:	eb 1c                	jmp    80218f <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802173:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80217a:	00 
  80217b:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802182:	ee 
  802183:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802187:	89 34 24             	mov    %esi,(%esp)
  80218a:	e8 71 eb ff ff       	call   800d00 <sys_ipc_try_send>
		}
		if (r == 0)
  80218f:	85 c0                	test   %eax,%eax
  802191:	74 2c                	je     8021bf <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802193:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802196:	74 20                	je     8021b8 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802198:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219c:	c7 44 24 08 5c 29 80 	movl   $0x80295c,0x8(%esp)
  8021a3:	00 
  8021a4:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8021ab:	00 
  8021ac:	c7 04 24 6f 29 80 00 	movl   $0x80296f,(%esp)
  8021b3:	e8 c4 fe ff ff       	call   80207c <_panic>
		}
		sys_yield();
  8021b8:	e8 31 e9 ff ff       	call   800aee <sys_yield>
	}
  8021bd:	eb 97                	jmp    802156 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8021bf:	83 c4 1c             	add    $0x1c,%esp
  8021c2:	5b                   	pop    %ebx
  8021c3:	5e                   	pop    %esi
  8021c4:	5f                   	pop    %edi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    

008021c7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	53                   	push   %ebx
  8021cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021ce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021d3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021da:	89 c2                	mov    %eax,%edx
  8021dc:	c1 e2 07             	shl    $0x7,%edx
  8021df:	29 ca                	sub    %ecx,%edx
  8021e1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021e7:	8b 52 50             	mov    0x50(%edx),%edx
  8021ea:	39 da                	cmp    %ebx,%edx
  8021ec:	75 0f                	jne    8021fd <ipc_find_env+0x36>
			return envs[i].env_id;
  8021ee:	c1 e0 07             	shl    $0x7,%eax
  8021f1:	29 c8                	sub    %ecx,%eax
  8021f3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021f8:	8b 40 40             	mov    0x40(%eax),%eax
  8021fb:	eb 0c                	jmp    802209 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021fd:	40                   	inc    %eax
  8021fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802203:	75 ce                	jne    8021d3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802205:	66 b8 00 00          	mov    $0x0,%ax
}
  802209:	5b                   	pop    %ebx
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    

0080220c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
  80220f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802212:	89 c2                	mov    %eax,%edx
  802214:	c1 ea 16             	shr    $0x16,%edx
  802217:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80221e:	f6 c2 01             	test   $0x1,%dl
  802221:	74 1e                	je     802241 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802223:	c1 e8 0c             	shr    $0xc,%eax
  802226:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80222d:	a8 01                	test   $0x1,%al
  80222f:	74 17                	je     802248 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802231:	c1 e8 0c             	shr    $0xc,%eax
  802234:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80223b:	ef 
  80223c:	0f b7 c0             	movzwl %ax,%eax
  80223f:	eb 0c                	jmp    80224d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802241:	b8 00 00 00 00       	mov    $0x0,%eax
  802246:	eb 05                	jmp    80224d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802248:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80224d:	5d                   	pop    %ebp
  80224e:	c3                   	ret    
	...

00802250 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	83 ec 10             	sub    $0x10,%esp
  802256:	8b 74 24 20          	mov    0x20(%esp),%esi
  80225a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80225e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802262:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802266:	89 cd                	mov    %ecx,%ebp
  802268:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80226c:	85 c0                	test   %eax,%eax
  80226e:	75 2c                	jne    80229c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802270:	39 f9                	cmp    %edi,%ecx
  802272:	77 68                	ja     8022dc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802274:	85 c9                	test   %ecx,%ecx
  802276:	75 0b                	jne    802283 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802278:	b8 01 00 00 00       	mov    $0x1,%eax
  80227d:	31 d2                	xor    %edx,%edx
  80227f:	f7 f1                	div    %ecx
  802281:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802283:	31 d2                	xor    %edx,%edx
  802285:	89 f8                	mov    %edi,%eax
  802287:	f7 f1                	div    %ecx
  802289:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80228b:	89 f0                	mov    %esi,%eax
  80228d:	f7 f1                	div    %ecx
  80228f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802291:	89 f0                	mov    %esi,%eax
  802293:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80229c:	39 f8                	cmp    %edi,%eax
  80229e:	77 2c                	ja     8022cc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022a0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8022a3:	83 f6 1f             	xor    $0x1f,%esi
  8022a6:	75 4c                	jne    8022f4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022a8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022aa:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022af:	72 0a                	jb     8022bb <__udivdi3+0x6b>
  8022b1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022b5:	0f 87 ad 00 00 00    	ja     802368 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022bb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022c0:	89 f0                	mov    %esi,%eax
  8022c2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022c4:	83 c4 10             	add    $0x10,%esp
  8022c7:	5e                   	pop    %esi
  8022c8:	5f                   	pop    %edi
  8022c9:	5d                   	pop    %ebp
  8022ca:	c3                   	ret    
  8022cb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022cc:	31 ff                	xor    %edi,%edi
  8022ce:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022d0:	89 f0                	mov    %esi,%eax
  8022d2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022d4:	83 c4 10             	add    $0x10,%esp
  8022d7:	5e                   	pop    %esi
  8022d8:	5f                   	pop    %edi
  8022d9:	5d                   	pop    %ebp
  8022da:	c3                   	ret    
  8022db:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022dc:	89 fa                	mov    %edi,%edx
  8022de:	89 f0                	mov    %esi,%eax
  8022e0:	f7 f1                	div    %ecx
  8022e2:	89 c6                	mov    %eax,%esi
  8022e4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022e6:	89 f0                	mov    %esi,%eax
  8022e8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ea:	83 c4 10             	add    $0x10,%esp
  8022ed:	5e                   	pop    %esi
  8022ee:	5f                   	pop    %edi
  8022ef:	5d                   	pop    %ebp
  8022f0:	c3                   	ret    
  8022f1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022f4:	89 f1                	mov    %esi,%ecx
  8022f6:	d3 e0                	shl    %cl,%eax
  8022f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022fc:	b8 20 00 00 00       	mov    $0x20,%eax
  802301:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802303:	89 ea                	mov    %ebp,%edx
  802305:	88 c1                	mov    %al,%cl
  802307:	d3 ea                	shr    %cl,%edx
  802309:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80230d:	09 ca                	or     %ecx,%edx
  80230f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802313:	89 f1                	mov    %esi,%ecx
  802315:	d3 e5                	shl    %cl,%ebp
  802317:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80231b:	89 fd                	mov    %edi,%ebp
  80231d:	88 c1                	mov    %al,%cl
  80231f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802321:	89 fa                	mov    %edi,%edx
  802323:	89 f1                	mov    %esi,%ecx
  802325:	d3 e2                	shl    %cl,%edx
  802327:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80232b:	88 c1                	mov    %al,%cl
  80232d:	d3 ef                	shr    %cl,%edi
  80232f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802331:	89 f8                	mov    %edi,%eax
  802333:	89 ea                	mov    %ebp,%edx
  802335:	f7 74 24 08          	divl   0x8(%esp)
  802339:	89 d1                	mov    %edx,%ecx
  80233b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80233d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802341:	39 d1                	cmp    %edx,%ecx
  802343:	72 17                	jb     80235c <__udivdi3+0x10c>
  802345:	74 09                	je     802350 <__udivdi3+0x100>
  802347:	89 fe                	mov    %edi,%esi
  802349:	31 ff                	xor    %edi,%edi
  80234b:	e9 41 ff ff ff       	jmp    802291 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802350:	8b 54 24 04          	mov    0x4(%esp),%edx
  802354:	89 f1                	mov    %esi,%ecx
  802356:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802358:	39 c2                	cmp    %eax,%edx
  80235a:	73 eb                	jae    802347 <__udivdi3+0xf7>
		{
		  q0--;
  80235c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80235f:	31 ff                	xor    %edi,%edi
  802361:	e9 2b ff ff ff       	jmp    802291 <__udivdi3+0x41>
  802366:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802368:	31 f6                	xor    %esi,%esi
  80236a:	e9 22 ff ff ff       	jmp    802291 <__udivdi3+0x41>
	...

00802370 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802370:	55                   	push   %ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	83 ec 20             	sub    $0x20,%esp
  802376:	8b 44 24 30          	mov    0x30(%esp),%eax
  80237a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80237e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802382:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802386:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80238a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80238e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802390:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802392:	85 ed                	test   %ebp,%ebp
  802394:	75 16                	jne    8023ac <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802396:	39 f1                	cmp    %esi,%ecx
  802398:	0f 86 a6 00 00 00    	jbe    802444 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80239e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8023a0:	89 d0                	mov    %edx,%eax
  8023a2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023a4:	83 c4 20             	add    $0x20,%esp
  8023a7:	5e                   	pop    %esi
  8023a8:	5f                   	pop    %edi
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    
  8023ab:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023ac:	39 f5                	cmp    %esi,%ebp
  8023ae:	0f 87 ac 00 00 00    	ja     802460 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023b4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8023b7:	83 f0 1f             	xor    $0x1f,%eax
  8023ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023be:	0f 84 a8 00 00 00    	je     80246c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023c4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023c8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023ca:	bf 20 00 00 00       	mov    $0x20,%edi
  8023cf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023d3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023d7:	89 f9                	mov    %edi,%ecx
  8023d9:	d3 e8                	shr    %cl,%eax
  8023db:	09 e8                	or     %ebp,%eax
  8023dd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023e1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023e5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023e9:	d3 e0                	shl    %cl,%eax
  8023eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023ef:	89 f2                	mov    %esi,%edx
  8023f1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023f3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023f7:	d3 e0                	shl    %cl,%eax
  8023f9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023fd:	8b 44 24 14          	mov    0x14(%esp),%eax
  802401:	89 f9                	mov    %edi,%ecx
  802403:	d3 e8                	shr    %cl,%eax
  802405:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802407:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802409:	89 f2                	mov    %esi,%edx
  80240b:	f7 74 24 18          	divl   0x18(%esp)
  80240f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802411:	f7 64 24 0c          	mull   0xc(%esp)
  802415:	89 c5                	mov    %eax,%ebp
  802417:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802419:	39 d6                	cmp    %edx,%esi
  80241b:	72 67                	jb     802484 <__umoddi3+0x114>
  80241d:	74 75                	je     802494 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80241f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802423:	29 e8                	sub    %ebp,%eax
  802425:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802427:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	89 f2                	mov    %esi,%edx
  80242f:	89 f9                	mov    %edi,%ecx
  802431:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802433:	09 d0                	or     %edx,%eax
  802435:	89 f2                	mov    %esi,%edx
  802437:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80243b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80243d:	83 c4 20             	add    $0x20,%esp
  802440:	5e                   	pop    %esi
  802441:	5f                   	pop    %edi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802444:	85 c9                	test   %ecx,%ecx
  802446:	75 0b                	jne    802453 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802448:	b8 01 00 00 00       	mov    $0x1,%eax
  80244d:	31 d2                	xor    %edx,%edx
  80244f:	f7 f1                	div    %ecx
  802451:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802453:	89 f0                	mov    %esi,%eax
  802455:	31 d2                	xor    %edx,%edx
  802457:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802459:	89 f8                	mov    %edi,%eax
  80245b:	e9 3e ff ff ff       	jmp    80239e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802460:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802462:	83 c4 20             	add    $0x20,%esp
  802465:	5e                   	pop    %esi
  802466:	5f                   	pop    %edi
  802467:	5d                   	pop    %ebp
  802468:	c3                   	ret    
  802469:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80246c:	39 f5                	cmp    %esi,%ebp
  80246e:	72 04                	jb     802474 <__umoddi3+0x104>
  802470:	39 f9                	cmp    %edi,%ecx
  802472:	77 06                	ja     80247a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802474:	89 f2                	mov    %esi,%edx
  802476:	29 cf                	sub    %ecx,%edi
  802478:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80247a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80247c:	83 c4 20             	add    $0x20,%esp
  80247f:	5e                   	pop    %esi
  802480:	5f                   	pop    %edi
  802481:	5d                   	pop    %ebp
  802482:	c3                   	ret    
  802483:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802484:	89 d1                	mov    %edx,%ecx
  802486:	89 c5                	mov    %eax,%ebp
  802488:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80248c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802490:	eb 8d                	jmp    80241f <__umoddi3+0xaf>
  802492:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802494:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802498:	72 ea                	jb     802484 <__umoddi3+0x114>
  80249a:	89 f1                	mov    %esi,%ecx
  80249c:	eb 81                	jmp    80241f <__umoddi3+0xaf>
