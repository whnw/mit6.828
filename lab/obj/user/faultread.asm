
obj/user/faultread.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  80004a:	e8 15 01 00 00       	call   800164 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800062:	e8 5c 0a 00 00       	call   800ac3 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ae:	e8 00 0f 00 00       	call   800fb3 <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 b2 09 00 00       	call   800a71 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	40                   	inc    %eax
  8000d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	75 19                	jne    8000fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e8:	00 
  8000e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ec:	89 04 24             	mov    %eax,(%esp)
  8000ef:	e8 40 09 00 00       	call   800a34 <sys_cputs>
		b->idx = 0;
  8000f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fa:	ff 43 04             	incl   0x4(%ebx)
}
  8000fd:	83 c4 14             	add    $0x14,%esp
  800100:	5b                   	pop    %ebx
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800120:	8b 45 0c             	mov    0xc(%ebp),%eax
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	8b 45 08             	mov    0x8(%ebp),%eax
  80012a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800134:	89 44 24 04          	mov    %eax,0x4(%esp)
  800138:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  80013f:	e8 82 01 00 00       	call   8002c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800144:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800154:	89 04 24             	mov    %eax,(%esp)
  800157:	e8 d8 08 00 00       	call   800a34 <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800171:	8b 45 08             	mov    0x8(%ebp),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 87 ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	75 08                	jne    8001ac <printnum+0x2c>
  8001a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001aa:	77 57                	ja     800203 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b0:	4b                   	dec    %ebx
  8001b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cb:	00 
  8001cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cf:	89 04 24             	mov    %eax,(%esp)
  8001d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d9:	e8 66 20 00 00       	call   802244 <__udivdi3>
  8001de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ed:	89 fa                	mov    %edi,%edx
  8001ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f2:	e8 89 ff ff ff       	call   800180 <printnum>
  8001f7:	eb 0f                	jmp    800208 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001fd:	89 34 24             	mov    %esi,(%esp)
  800200:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800203:	4b                   	dec    %ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f f1                	jg     8001f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 44 24 08          	mov    %eax,0x8(%esp)
  800217:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021e:	00 
  80021f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	e8 33 21 00 00       	call   802364 <__umoddi3>
  800231:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800235:	0f be 80 c8 24 80 00 	movsbl 0x8024c8(%eax),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800242:	83 c4 3c             	add    $0x3c,%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024d:	83 fa 01             	cmp    $0x1,%edx
  800250:	7e 0e                	jle    800260 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 08             	lea    0x8(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	8b 52 04             	mov    0x4(%edx),%edx
  80025e:	eb 22                	jmp    800282 <getuint+0x38>
	else if (lflag)
  800260:	85 d2                	test   %edx,%edx
  800262:	74 10                	je     800274 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	eb 0e                	jmp    800282 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	3b 50 04             	cmp    0x4(%eax),%edx
  800292:	73 08                	jae    80029c <sprintputch+0x18>
		*b->buf++ = ch;
  800294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800297:	88 0a                	mov    %cl,(%edx)
  800299:	42                   	inc    %edx
  80029a:	89 10                	mov    %edx,(%eax)
}
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 02 00 00 00       	call   8002c6 <vprintfmt>
	va_end(ap);
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 4c             	sub    $0x4c,%esp
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d5:	eb 12                	jmp    8002e9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	0f 84 6b 03 00 00    	je     80064a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	0f b6 06             	movzbl (%esi),%eax
  8002ec:	46                   	inc    %esi
  8002ed:	83 f8 25             	cmp    $0x25,%eax
  8002f0:	75 e5                	jne    8002d7 <vprintfmt+0x11>
  8002f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800302:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800309:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030e:	eb 26                	jmp    800336 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800313:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800317:	eb 1d                	jmp    800336 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800319:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800320:	eb 14                	jmp    800336 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800325:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80032c:	eb 08                	jmp    800336 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80032e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800331:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	0f b6 06             	movzbl (%esi),%eax
  800339:	8d 56 01             	lea    0x1(%esi),%edx
  80033c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80033f:	8a 16                	mov    (%esi),%dl
  800341:	83 ea 23             	sub    $0x23,%edx
  800344:	80 fa 55             	cmp    $0x55,%dl
  800347:	0f 87 e1 02 00 00    	ja     80062e <vprintfmt+0x368>
  80034d:	0f b6 d2             	movzbl %dl,%edx
  800350:	ff 24 95 00 26 80 00 	jmp    *0x802600(,%edx,4)
  800357:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80035a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800362:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800366:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800369:	8d 50 d0             	lea    -0x30(%eax),%edx
  80036c:	83 fa 09             	cmp    $0x9,%edx
  80036f:	77 2a                	ja     80039b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800372:	eb eb                	jmp    80035f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 50 04             	lea    0x4(%eax),%edx
  80037a:	89 55 14             	mov    %edx,0x14(%ebp)
  80037d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800382:	eb 17                	jmp    80039b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800384:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800388:	78 98                	js     800322 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80038d:	eb a7                	jmp    800336 <vprintfmt+0x70>
  80038f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800392:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800399:	eb 9b                	jmp    800336 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80039b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039f:	79 95                	jns    800336 <vprintfmt+0x70>
  8003a1:	eb 8b                	jmp    80032e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a7:	eb 8d                	jmp    800336 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	8d 50 04             	lea    0x4(%eax),%edx
  8003af:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c1:	e9 23 ff ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 50 04             	lea    0x4(%eax),%edx
  8003cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	79 02                	jns    8003d7 <vprintfmt+0x111>
  8003d5:	f7 d8                	neg    %eax
  8003d7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d9:	83 f8 10             	cmp    $0x10,%eax
  8003dc:	7f 0b                	jg     8003e9 <vprintfmt+0x123>
  8003de:	8b 04 85 60 27 80 00 	mov    0x802760(,%eax,4),%eax
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	75 23                	jne    80040c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ed:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  8003f4:	00 
  8003f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	e8 9a fe ff ff       	call   80029e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800407:	e9 dd fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80040c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800410:	c7 44 24 08 99 28 80 	movl   $0x802899,0x8(%esp)
  800417:	00 
  800418:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041c:	8b 55 08             	mov    0x8(%ebp),%edx
  80041f:	89 14 24             	mov    %edx,(%esp)
  800422:	e8 77 fe ff ff       	call   80029e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042a:	e9 ba fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
  80042f:	89 f9                	mov    %edi,%ecx
  800431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800434:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 50 04             	lea    0x4(%eax),%edx
  80043d:	89 55 14             	mov    %edx,0x14(%ebp)
  800440:	8b 30                	mov    (%eax),%esi
  800442:	85 f6                	test   %esi,%esi
  800444:	75 05                	jne    80044b <vprintfmt+0x185>
				p = "(null)";
  800446:	be d9 24 80 00       	mov    $0x8024d9,%esi
			if (width > 0 && padc != '-')
  80044b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80044f:	0f 8e 84 00 00 00    	jle    8004d9 <vprintfmt+0x213>
  800455:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800459:	74 7e                	je     8004d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80045f:	89 34 24             	mov    %esi,(%esp)
  800462:	e8 8b 02 00 00       	call   8006f2 <strnlen>
  800467:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80046a:	29 c2                	sub    %eax,%edx
  80046c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80046f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800473:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800476:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800479:	89 de                	mov    %ebx,%esi
  80047b:	89 d3                	mov    %edx,%ebx
  80047d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	eb 0b                	jmp    80048c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800481:	89 74 24 04          	mov    %esi,0x4(%esp)
  800485:	89 3c 24             	mov    %edi,(%esp)
  800488:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	4b                   	dec    %ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f f1                	jg     800481 <vprintfmt+0x1bb>
  800490:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800493:	89 f3                	mov    %esi,%ebx
  800495:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800498:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	79 05                	jns    8004a4 <vprintfmt+0x1de>
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a7:	29 c2                	sub    %eax,%edx
  8004a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ac:	eb 2b                	jmp    8004d9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b2:	74 18                	je     8004cc <vprintfmt+0x206>
  8004b4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004b7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ba:	76 10                	jbe    8004cc <vprintfmt+0x206>
					putch('?', putdat);
  8004bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
  8004ca:	eb 0a                	jmp    8004d6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d9:	0f be 06             	movsbl (%esi),%eax
  8004dc:	46                   	inc    %esi
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	74 21                	je     800502 <vprintfmt+0x23c>
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	78 c9                	js     8004ae <vprintfmt+0x1e8>
  8004e5:	4f                   	dec    %edi
  8004e6:	79 c6                	jns    8004ae <vprintfmt+0x1e8>
  8004e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004eb:	89 de                	mov    %ebx,%esi
  8004ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f0:	eb 18                	jmp    80050a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ff:	4b                   	dec    %ebx
  800500:	eb 08                	jmp    80050a <vprintfmt+0x244>
  800502:	8b 7d 08             	mov    0x8(%ebp),%edi
  800505:	89 de                	mov    %ebx,%esi
  800507:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80050a:	85 db                	test   %ebx,%ebx
  80050c:	7f e4                	jg     8004f2 <vprintfmt+0x22c>
  80050e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800511:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	e9 ce fd ff ff       	jmp    8002e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051b:	83 f9 01             	cmp    $0x1,%ecx
  80051e:	7e 10                	jle    800530 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 08             	lea    0x8(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 30                	mov    (%eax),%esi
  80052b:	8b 78 04             	mov    0x4(%eax),%edi
  80052e:	eb 26                	jmp    800556 <vprintfmt+0x290>
	else if (lflag)
  800530:	85 c9                	test   %ecx,%ecx
  800532:	74 12                	je     800546 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 04             	lea    0x4(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 30                	mov    (%eax),%esi
  80053f:	89 f7                	mov    %esi,%edi
  800541:	c1 ff 1f             	sar    $0x1f,%edi
  800544:	eb 10                	jmp    800556 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 50 04             	lea    0x4(%eax),%edx
  80054c:	89 55 14             	mov    %edx,0x14(%ebp)
  80054f:	8b 30                	mov    (%eax),%esi
  800551:	89 f7                	mov    %esi,%edi
  800553:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800556:	85 ff                	test   %edi,%edi
  800558:	78 0a                	js     800564 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055f:	e9 8c 00 00 00       	jmp    8005f0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80056f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800572:	f7 de                	neg    %esi
  800574:	83 d7 00             	adc    $0x0,%edi
  800577:	f7 df                	neg    %edi
			}
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057e:	eb 70                	jmp    8005f0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800580:	89 ca                	mov    %ecx,%edx
  800582:	8d 45 14             	lea    0x14(%ebp),%eax
  800585:	e8 c0 fc ff ff       	call   80024a <getuint>
  80058a:	89 c6                	mov    %eax,%esi
  80058c:	89 d7                	mov    %edx,%edi
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800593:	eb 5b                	jmp    8005f0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800595:	89 ca                	mov    %ecx,%edx
  800597:	8d 45 14             	lea    0x14(%ebp),%eax
  80059a:	e8 ab fc ff ff       	call   80024a <getuint>
  80059f:	89 c6                	mov    %eax,%esi
  8005a1:	89 d7                	mov    %edx,%edi
			base = 8;
  8005a3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005a8:	eb 46                	jmp    8005f0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cf:	8b 30                	mov    (%eax),%esi
  8005d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005db:	eb 13                	jmp    8005f0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005dd:	89 ca                	mov    %ecx,%edx
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 63 fc ff ff       	call   80024a <getuint>
  8005e7:	89 c6                	mov    %eax,%esi
  8005e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8005eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800603:	89 34 24             	mov    %esi,(%esp)
  800606:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060a:	89 da                	mov    %ebx,%edx
  80060c:	8b 45 08             	mov    0x8(%ebp),%eax
  80060f:	e8 6c fb ff ff       	call   800180 <printnum>
			break;
  800614:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800617:	e9 cd fc ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800629:	e9 bb fc ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80062e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800632:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800639:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	eb 01                	jmp    80063f <vprintfmt+0x379>
  80063e:	4e                   	dec    %esi
  80063f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800643:	75 f9                	jne    80063e <vprintfmt+0x378>
  800645:	e9 9f fc ff ff       	jmp    8002e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80064a:	83 c4 4c             	add    $0x4c,%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	83 ec 28             	sub    $0x28,%esp
  800658:	8b 45 08             	mov    0x8(%ebp),%eax
  80065b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800661:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800665:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800668:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066f:	85 c0                	test   %eax,%eax
  800671:	74 30                	je     8006a3 <vsnprintf+0x51>
  800673:	85 d2                	test   %edx,%edx
  800675:	7e 33                	jle    8006aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067e:	8b 45 10             	mov    0x10(%ebp),%eax
  800681:	89 44 24 08          	mov    %eax,0x8(%esp)
  800685:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068c:	c7 04 24 84 02 80 00 	movl   $0x800284,(%esp)
  800693:	e8 2e fc ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800698:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80069e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a1:	eb 0c                	jmp    8006af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a8:	eb 05                	jmp    8006af <vsnprintf+0x5d>
  8006aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    

008006b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006be:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	89 04 24             	mov    %eax,(%esp)
  8006d2:	e8 7b ff ff ff       	call   800652 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    
  8006d9:	00 00                	add    %al,(%eax)
	...

008006dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e7:	eb 01                	jmp    8006ea <strlen+0xe>
		n++;
  8006e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ee:	75 f9                	jne    8006e9 <strlen+0xd>
		n++;
	return n;
}
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 01                	jmp    800703 <strnlen+0x11>
		n++;
  800702:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	39 d0                	cmp    %edx,%eax
  800705:	74 06                	je     80070d <strnlen+0x1b>
  800707:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070b:	75 f5                	jne    800702 <strnlen+0x10>
		n++;
	return n;
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	53                   	push   %ebx
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800719:	ba 00 00 00 00       	mov    $0x0,%edx
  80071e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800721:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800724:	42                   	inc    %edx
  800725:	84 c9                	test   %cl,%cl
  800727:	75 f5                	jne    80071e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800729:	5b                   	pop    %ebx
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800736:	89 1c 24             	mov    %ebx,(%esp)
  800739:	e8 9e ff ff ff       	call   8006dc <strlen>
	strcpy(dst + len, src);
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800741:	89 54 24 04          	mov    %edx,0x4(%esp)
  800745:	01 d8                	add    %ebx,%eax
  800747:	89 04 24             	mov    %eax,(%esp)
  80074a:	e8 c0 ff ff ff       	call   80070f <strcpy>
	return dst;
}
  80074f:	89 d8                	mov    %ebx,%eax
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	5b                   	pop    %ebx
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	56                   	push   %esi
  80075b:	53                   	push   %ebx
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800762:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800765:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076a:	eb 0c                	jmp    800778 <strncpy+0x21>
		*dst++ = *src;
  80076c:	8a 1a                	mov    (%edx),%bl
  80076e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800771:	80 3a 01             	cmpb   $0x1,(%edx)
  800774:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800777:	41                   	inc    %ecx
  800778:	39 f1                	cmp    %esi,%ecx
  80077a:	75 f0                	jne    80076c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078e:	85 d2                	test   %edx,%edx
  800790:	75 0a                	jne    80079c <strlcpy+0x1c>
  800792:	89 f0                	mov    %esi,%eax
  800794:	eb 1a                	jmp    8007b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800796:	88 18                	mov    %bl,(%eax)
  800798:	40                   	inc    %eax
  800799:	41                   	inc    %ecx
  80079a:	eb 02                	jmp    80079e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80079e:	4a                   	dec    %edx
  80079f:	74 0a                	je     8007ab <strlcpy+0x2b>
  8007a1:	8a 19                	mov    (%ecx),%bl
  8007a3:	84 db                	test   %bl,%bl
  8007a5:	75 ef                	jne    800796 <strlcpy+0x16>
  8007a7:	89 c2                	mov    %eax,%edx
  8007a9:	eb 02                	jmp    8007ad <strlcpy+0x2d>
  8007ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007b0:	29 f0                	sub    %esi,%eax
}
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bf:	eb 02                	jmp    8007c3 <strcmp+0xd>
		p++, q++;
  8007c1:	41                   	inc    %ecx
  8007c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c3:	8a 01                	mov    (%ecx),%al
  8007c5:	84 c0                	test   %al,%al
  8007c7:	74 04                	je     8007cd <strcmp+0x17>
  8007c9:	3a 02                	cmp    (%edx),%al
  8007cb:	74 f4                	je     8007c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cd:	0f b6 c0             	movzbl %al,%eax
  8007d0:	0f b6 12             	movzbl (%edx),%edx
  8007d3:	29 d0                	sub    %edx,%eax
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007e4:	eb 03                	jmp    8007e9 <strncmp+0x12>
		n--, p++, q++;
  8007e6:	4a                   	dec    %edx
  8007e7:	40                   	inc    %eax
  8007e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	74 14                	je     800801 <strncmp+0x2a>
  8007ed:	8a 18                	mov    (%eax),%bl
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	74 04                	je     8007f7 <strncmp+0x20>
  8007f3:	3a 19                	cmp    (%ecx),%bl
  8007f5:	74 ef                	je     8007e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f7:	0f b6 00             	movzbl (%eax),%eax
  8007fa:	0f b6 11             	movzbl (%ecx),%edx
  8007fd:	29 d0                	sub    %edx,%eax
  8007ff:	eb 05                	jmp    800806 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800806:	5b                   	pop    %ebx
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800812:	eb 05                	jmp    800819 <strchr+0x10>
		if (*s == c)
  800814:	38 ca                	cmp    %cl,%dl
  800816:	74 0c                	je     800824 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800818:	40                   	inc    %eax
  800819:	8a 10                	mov    (%eax),%dl
  80081b:	84 d2                	test   %dl,%dl
  80081d:	75 f5                	jne    800814 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80082f:	eb 05                	jmp    800836 <strfind+0x10>
		if (*s == c)
  800831:	38 ca                	cmp    %cl,%dl
  800833:	74 07                	je     80083c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800835:	40                   	inc    %eax
  800836:	8a 10                	mov    (%eax),%dl
  800838:	84 d2                	test   %dl,%dl
  80083a:	75 f5                	jne    800831 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	57                   	push   %edi
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 7d 08             	mov    0x8(%ebp),%edi
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084d:	85 c9                	test   %ecx,%ecx
  80084f:	74 30                	je     800881 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800851:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800857:	75 25                	jne    80087e <memset+0x40>
  800859:	f6 c1 03             	test   $0x3,%cl
  80085c:	75 20                	jne    80087e <memset+0x40>
		c &= 0xFF;
  80085e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800861:	89 d3                	mov    %edx,%ebx
  800863:	c1 e3 08             	shl    $0x8,%ebx
  800866:	89 d6                	mov    %edx,%esi
  800868:	c1 e6 18             	shl    $0x18,%esi
  80086b:	89 d0                	mov    %edx,%eax
  80086d:	c1 e0 10             	shl    $0x10,%eax
  800870:	09 f0                	or     %esi,%eax
  800872:	09 d0                	or     %edx,%eax
  800874:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800876:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800879:	fc                   	cld    
  80087a:	f3 ab                	rep stos %eax,%es:(%edi)
  80087c:	eb 03                	jmp    800881 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087e:	fc                   	cld    
  80087f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800881:	89 f8                	mov    %edi,%eax
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5f                   	pop    %edi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	57                   	push   %edi
  80088c:	56                   	push   %esi
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 75 0c             	mov    0xc(%ebp),%esi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800896:	39 c6                	cmp    %eax,%esi
  800898:	73 34                	jae    8008ce <memmove+0x46>
  80089a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089d:	39 d0                	cmp    %edx,%eax
  80089f:	73 2d                	jae    8008ce <memmove+0x46>
		s += n;
		d += n;
  8008a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a4:	f6 c2 03             	test   $0x3,%dl
  8008a7:	75 1b                	jne    8008c4 <memmove+0x3c>
  8008a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008af:	75 13                	jne    8008c4 <memmove+0x3c>
  8008b1:	f6 c1 03             	test   $0x3,%cl
  8008b4:	75 0e                	jne    8008c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b6:	83 ef 04             	sub    $0x4,%edi
  8008b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008bf:	fd                   	std    
  8008c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c2:	eb 07                	jmp    8008cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c4:	4f                   	dec    %edi
  8008c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c8:	fd                   	std    
  8008c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cb:	fc                   	cld    
  8008cc:	eb 20                	jmp    8008ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d4:	75 13                	jne    8008e9 <memmove+0x61>
  8008d6:	a8 03                	test   $0x3,%al
  8008d8:	75 0f                	jne    8008e9 <memmove+0x61>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0a                	jne    8008e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008e2:	89 c7                	mov    %eax,%edi
  8008e4:	fc                   	cld    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 05                	jmp    8008ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e9:	89 c7                	mov    %eax,%edi
  8008eb:	fc                   	cld    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8008fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800902:	89 44 24 04          	mov    %eax,0x4(%esp)
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	89 04 24             	mov    %eax,(%esp)
  80090c:	e8 77 ff ff ff       	call   800888 <memmove>
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	57                   	push   %edi
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800922:	ba 00 00 00 00       	mov    $0x0,%edx
  800927:	eb 16                	jmp    80093f <memcmp+0x2c>
		if (*s1 != *s2)
  800929:	8a 04 17             	mov    (%edi,%edx,1),%al
  80092c:	42                   	inc    %edx
  80092d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800931:	38 c8                	cmp    %cl,%al
  800933:	74 0a                	je     80093f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800935:	0f b6 c0             	movzbl %al,%eax
  800938:	0f b6 c9             	movzbl %cl,%ecx
  80093b:	29 c8                	sub    %ecx,%eax
  80093d:	eb 09                	jmp    800948 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093f:	39 da                	cmp    %ebx,%edx
  800941:	75 e6                	jne    800929 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5f                   	pop    %edi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800956:	89 c2                	mov    %eax,%edx
  800958:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80095b:	eb 05                	jmp    800962 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095d:	38 08                	cmp    %cl,(%eax)
  80095f:	74 05                	je     800966 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800961:	40                   	inc    %eax
  800962:	39 d0                	cmp    %edx,%eax
  800964:	72 f7                	jb     80095d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	53                   	push   %ebx
  80096e:	8b 55 08             	mov    0x8(%ebp),%edx
  800971:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800974:	eb 01                	jmp    800977 <strtol+0xf>
		s++;
  800976:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800977:	8a 02                	mov    (%edx),%al
  800979:	3c 20                	cmp    $0x20,%al
  80097b:	74 f9                	je     800976 <strtol+0xe>
  80097d:	3c 09                	cmp    $0x9,%al
  80097f:	74 f5                	je     800976 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800981:	3c 2b                	cmp    $0x2b,%al
  800983:	75 08                	jne    80098d <strtol+0x25>
		s++;
  800985:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800986:	bf 00 00 00 00       	mov    $0x0,%edi
  80098b:	eb 13                	jmp    8009a0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80098d:	3c 2d                	cmp    $0x2d,%al
  80098f:	75 0a                	jne    80099b <strtol+0x33>
		s++, neg = 1;
  800991:	8d 52 01             	lea    0x1(%edx),%edx
  800994:	bf 01 00 00 00       	mov    $0x1,%edi
  800999:	eb 05                	jmp    8009a0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a0:	85 db                	test   %ebx,%ebx
  8009a2:	74 05                	je     8009a9 <strtol+0x41>
  8009a4:	83 fb 10             	cmp    $0x10,%ebx
  8009a7:	75 28                	jne    8009d1 <strtol+0x69>
  8009a9:	8a 02                	mov    (%edx),%al
  8009ab:	3c 30                	cmp    $0x30,%al
  8009ad:	75 10                	jne    8009bf <strtol+0x57>
  8009af:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009b3:	75 0a                	jne    8009bf <strtol+0x57>
		s += 2, base = 16;
  8009b5:	83 c2 02             	add    $0x2,%edx
  8009b8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009bd:	eb 12                	jmp    8009d1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	75 0e                	jne    8009d1 <strtol+0x69>
  8009c3:	3c 30                	cmp    $0x30,%al
  8009c5:	75 05                	jne    8009cc <strtol+0x64>
		s++, base = 8;
  8009c7:	42                   	inc    %edx
  8009c8:	b3 08                	mov    $0x8,%bl
  8009ca:	eb 05                	jmp    8009d1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009cc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d8:	8a 0a                	mov    (%edx),%cl
  8009da:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009dd:	80 fb 09             	cmp    $0x9,%bl
  8009e0:	77 08                	ja     8009ea <strtol+0x82>
			dig = *s - '0';
  8009e2:	0f be c9             	movsbl %cl,%ecx
  8009e5:	83 e9 30             	sub    $0x30,%ecx
  8009e8:	eb 1e                	jmp    800a08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009ea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009ed:	80 fb 19             	cmp    $0x19,%bl
  8009f0:	77 08                	ja     8009fa <strtol+0x92>
			dig = *s - 'a' + 10;
  8009f2:	0f be c9             	movsbl %cl,%ecx
  8009f5:	83 e9 57             	sub    $0x57,%ecx
  8009f8:	eb 0e                	jmp    800a08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009fa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009fd:	80 fb 19             	cmp    $0x19,%bl
  800a00:	77 12                	ja     800a14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a02:	0f be c9             	movsbl %cl,%ecx
  800a05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a08:	39 f1                	cmp    %esi,%ecx
  800a0a:	7d 0c                	jge    800a18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a0c:	42                   	inc    %edx
  800a0d:	0f af c6             	imul   %esi,%eax
  800a10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a12:	eb c4                	jmp    8009d8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a14:	89 c1                	mov    %eax,%ecx
  800a16:	eb 02                	jmp    800a1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1e:	74 05                	je     800a25 <strtol+0xbd>
		*endptr = (char *) s;
  800a20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a25:	85 ff                	test   %edi,%edi
  800a27:	74 04                	je     800a2d <strtol+0xc5>
  800a29:	89 c8                	mov    %ecx,%eax
  800a2b:	f7 d8                	neg    %eax
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    
	...

00800a34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	89 c3                	mov    %eax,%ebx
  800a47:	89 c7                	mov    %eax,%edi
  800a49:	89 c6                	mov    %eax,%esi
  800a4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a62:	89 d1                	mov    %edx,%ecx
  800a64:	89 d3                	mov    %edx,%ebx
  800a66:	89 d7                	mov    %edx,%edi
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
  800a87:	89 cb                	mov    %ecx,%ebx
  800a89:	89 cf                	mov    %ecx,%edi
  800a8b:	89 ce                	mov    %ecx,%esi
  800a8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	7e 28                	jle    800abb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a9e:	00 
  800a9f:	c7 44 24 08 c3 27 80 	movl   $0x8027c3,0x8(%esp)
  800aa6:	00 
  800aa7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aae:	00 
  800aaf:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  800ab6:	e8 b5 15 00 00       	call   802070 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abb:	83 c4 2c             	add    $0x2c,%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ace:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad3:	89 d1                	mov    %edx,%ecx
  800ad5:	89 d3                	mov    %edx,%ebx
  800ad7:	89 d7                	mov    %edx,%edi
  800ad9:	89 d6                	mov    %edx,%esi
  800adb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_yield>:

void
sys_yield(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	be 00 00 00 00       	mov    $0x0,%esi
  800b0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	89 f7                	mov    %esi,%edi
  800b1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	7e 28                	jle    800b4d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b29:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b30:	00 
  800b31:	c7 44 24 08 c3 27 80 	movl   $0x8027c3,0x8(%esp)
  800b38:	00 
  800b39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b40:	00 
  800b41:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  800b48:	e8 23 15 00 00       	call   802070 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b4d:	83 c4 2c             	add    $0x2c,%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b63:	8b 75 18             	mov    0x18(%ebp),%esi
  800b66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b74:	85 c0                	test   %eax,%eax
  800b76:	7e 28                	jle    800ba0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b7c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b83:	00 
  800b84:	c7 44 24 08 c3 27 80 	movl   $0x8027c3,0x8(%esp)
  800b8b:	00 
  800b8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b93:	00 
  800b94:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  800b9b:	e8 d0 14 00 00       	call   802070 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba0:	83 c4 2c             	add    $0x2c,%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	89 df                	mov    %ebx,%edi
  800bc3:	89 de                	mov    %ebx,%esi
  800bc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7e 28                	jle    800bf3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bcf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bd6:	00 
  800bd7:	c7 44 24 08 c3 27 80 	movl   $0x8027c3,0x8(%esp)
  800bde:	00 
  800bdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be6:	00 
  800be7:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  800bee:	e8 7d 14 00 00       	call   802070 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf3:	83 c4 2c             	add    $0x2c,%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c09:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	89 df                	mov    %ebx,%edi
  800c16:	89 de                	mov    %ebx,%esi
  800c18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 28                	jle    800c46 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c22:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c29:	00 
  800c2a:	c7 44 24 08 c3 27 80 	movl   $0x8027c3,0x8(%esp)
  800c31:	00 
  800c32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c39:	00 
  800c3a:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  800c41:	e8 2a 14 00 00       	call   802070 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c46:	83 c4 2c             	add    $0x2c,%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 df                	mov    %ebx,%edi
  800c69:	89 de                	mov    %ebx,%esi
  800c6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7e 28                	jle    800c99 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c75:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 08 c3 27 80 	movl   $0x8027c3,0x8(%esp)
  800c84:	00 
  800c85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8c:	00 
  800c8d:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  800c94:	e8 d7 13 00 00       	call   802070 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c99:	83 c4 2c             	add    $0x2c,%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 df                	mov    %ebx,%edi
  800cbc:	89 de                	mov    %ebx,%esi
  800cbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 28                	jle    800cec <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 08 c3 27 80 	movl   $0x8027c3,0x8(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdf:	00 
  800ce0:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  800ce7:	e8 84 13 00 00       	call   802070 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cec:	83 c4 2c             	add    $0x2c,%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	be 00 00 00 00       	mov    $0x0,%esi
  800cff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 cb                	mov    %ecx,%ebx
  800d2f:	89 cf                	mov    %ecx,%edi
  800d31:	89 ce                	mov    %ecx,%esi
  800d33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d35:	85 c0                	test   %eax,%eax
  800d37:	7e 28                	jle    800d61 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d44:	00 
  800d45:	c7 44 24 08 c3 27 80 	movl   $0x8027c3,0x8(%esp)
  800d4c:	00 
  800d4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d54:	00 
  800d55:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  800d5c:	e8 0f 13 00 00       	call   802070 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d61:	83 c4 2c             	add    $0x2c,%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d74:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d79:	89 d1                	mov    %edx,%ecx
  800d7b:	89 d3                	mov    %edx,%ebx
  800d7d:	89 d7                	mov    %edx,%edi
  800d7f:	89 d6                	mov    %edx,%esi
  800d81:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d93:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	89 df                	mov    %ebx,%edi
  800da0:	89 de                	mov    %ebx,%esi
  800da2:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db4:	b8 10 00 00 00       	mov    $0x10,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 df                	mov    %ebx,%edi
  800dc1:	89 de                	mov    %ebx,%esi
  800dc3:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    
	...

00800dcc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	05 00 00 00 30       	add    $0x30000000,%eax
  800dd7:	c1 e8 0c             	shr    $0xc,%eax
}
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	89 04 24             	mov    %eax,(%esp)
  800de8:	e8 df ff ff ff       	call   800dcc <fd2num>
  800ded:	c1 e0 0c             	shl    $0xc,%eax
  800df0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    

00800df7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	53                   	push   %ebx
  800dfb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dfe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e03:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e05:	89 c2                	mov    %eax,%edx
  800e07:	c1 ea 16             	shr    $0x16,%edx
  800e0a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e11:	f6 c2 01             	test   $0x1,%dl
  800e14:	74 11                	je     800e27 <fd_alloc+0x30>
  800e16:	89 c2                	mov    %eax,%edx
  800e18:	c1 ea 0c             	shr    $0xc,%edx
  800e1b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e22:	f6 c2 01             	test   $0x1,%dl
  800e25:	75 09                	jne    800e30 <fd_alloc+0x39>
			*fd_store = fd;
  800e27:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e29:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2e:	eb 17                	jmp    800e47 <fd_alloc+0x50>
  800e30:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e35:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3a:	75 c7                	jne    800e03 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e3c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e42:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e47:	5b                   	pop    %ebx
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e50:	83 f8 1f             	cmp    $0x1f,%eax
  800e53:	77 36                	ja     800e8b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e55:	c1 e0 0c             	shl    $0xc,%eax
  800e58:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e5d:	89 c2                	mov    %eax,%edx
  800e5f:	c1 ea 16             	shr    $0x16,%edx
  800e62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e69:	f6 c2 01             	test   $0x1,%dl
  800e6c:	74 24                	je     800e92 <fd_lookup+0x48>
  800e6e:	89 c2                	mov    %eax,%edx
  800e70:	c1 ea 0c             	shr    $0xc,%edx
  800e73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7a:	f6 c2 01             	test   $0x1,%dl
  800e7d:	74 1a                	je     800e99 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e82:	89 02                	mov    %eax,(%edx)
	return 0;
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
  800e89:	eb 13                	jmp    800e9e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e90:	eb 0c                	jmp    800e9e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e97:	eb 05                	jmp    800e9e <fd_lookup+0x54>
  800e99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 14             	sub    $0x14,%esp
  800ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	eb 0e                	jmp    800ec2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800eb4:	39 08                	cmp    %ecx,(%eax)
  800eb6:	75 09                	jne    800ec1 <dev_lookup+0x21>
			*dev = devtab[i];
  800eb8:	89 03                	mov    %eax,(%ebx)
			return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	eb 33                	jmp    800ef4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec1:	42                   	inc    %edx
  800ec2:	8b 04 95 6c 28 80 00 	mov    0x80286c(,%edx,4),%eax
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	75 e7                	jne    800eb4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ecd:	a1 08 40 80 00       	mov    0x804008,%eax
  800ed2:	8b 40 48             	mov    0x48(%eax),%eax
  800ed5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ed9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800edd:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800ee4:	e8 7b f2 ff ff       	call   800164 <cprintf>
	*dev = 0;
  800ee9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800eef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef4:	83 c4 14             	add    $0x14,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 30             	sub    $0x30,%esp
  800f02:	8b 75 08             	mov    0x8(%ebp),%esi
  800f05:	8a 45 0c             	mov    0xc(%ebp),%al
  800f08:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0b:	89 34 24             	mov    %esi,(%esp)
  800f0e:	e8 b9 fe ff ff       	call   800dcc <fd2num>
  800f13:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f16:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f1a:	89 04 24             	mov    %eax,(%esp)
  800f1d:	e8 28 ff ff ff       	call   800e4a <fd_lookup>
  800f22:	89 c3                	mov    %eax,%ebx
  800f24:	85 c0                	test   %eax,%eax
  800f26:	78 05                	js     800f2d <fd_close+0x33>
	    || fd != fd2)
  800f28:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f2b:	74 0d                	je     800f3a <fd_close+0x40>
		return (must_exist ? r : 0);
  800f2d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f31:	75 46                	jne    800f79 <fd_close+0x7f>
  800f33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f38:	eb 3f                	jmp    800f79 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f41:	8b 06                	mov    (%esi),%eax
  800f43:	89 04 24             	mov    %eax,(%esp)
  800f46:	e8 55 ff ff ff       	call   800ea0 <dev_lookup>
  800f4b:	89 c3                	mov    %eax,%ebx
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	78 18                	js     800f69 <fd_close+0x6f>
		if (dev->dev_close)
  800f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f54:	8b 40 10             	mov    0x10(%eax),%eax
  800f57:	85 c0                	test   %eax,%eax
  800f59:	74 09                	je     800f64 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f5b:	89 34 24             	mov    %esi,(%esp)
  800f5e:	ff d0                	call   *%eax
  800f60:	89 c3                	mov    %eax,%ebx
  800f62:	eb 05                	jmp    800f69 <fd_close+0x6f>
		else
			r = 0;
  800f64:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f69:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f74:	e8 2f fc ff ff       	call   800ba8 <sys_page_unmap>
	return r;
}
  800f79:	89 d8                	mov    %ebx,%eax
  800f7b:	83 c4 30             	add    $0x30,%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	89 04 24             	mov    %eax,(%esp)
  800f95:	e8 b0 fe ff ff       	call   800e4a <fd_lookup>
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	78 13                	js     800fb1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fa5:	00 
  800fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa9:	89 04 24             	mov    %eax,(%esp)
  800fac:	e8 49 ff ff ff       	call   800efa <fd_close>
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <close_all>:

void
close_all(void)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbf:	89 1c 24             	mov    %ebx,(%esp)
  800fc2:	e8 bb ff ff ff       	call   800f82 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc7:	43                   	inc    %ebx
  800fc8:	83 fb 20             	cmp    $0x20,%ebx
  800fcb:	75 f2                	jne    800fbf <close_all+0xc>
		close(i);
}
  800fcd:	83 c4 14             	add    $0x14,%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 4c             	sub    $0x4c,%esp
  800fdc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fdf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe9:	89 04 24             	mov    %eax,(%esp)
  800fec:	e8 59 fe ff ff       	call   800e4a <fd_lookup>
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	0f 88 e3 00 00 00    	js     8010de <dup+0x10b>
		return r;
	close(newfdnum);
  800ffb:	89 3c 24             	mov    %edi,(%esp)
  800ffe:	e8 7f ff ff ff       	call   800f82 <close>

	newfd = INDEX2FD(newfdnum);
  801003:	89 fe                	mov    %edi,%esi
  801005:	c1 e6 0c             	shl    $0xc,%esi
  801008:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80100e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801011:	89 04 24             	mov    %eax,(%esp)
  801014:	e8 c3 fd ff ff       	call   800ddc <fd2data>
  801019:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80101b:	89 34 24             	mov    %esi,(%esp)
  80101e:	e8 b9 fd ff ff       	call   800ddc <fd2data>
  801023:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801026:	89 d8                	mov    %ebx,%eax
  801028:	c1 e8 16             	shr    $0x16,%eax
  80102b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801032:	a8 01                	test   $0x1,%al
  801034:	74 46                	je     80107c <dup+0xa9>
  801036:	89 d8                	mov    %ebx,%eax
  801038:	c1 e8 0c             	shr    $0xc,%eax
  80103b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801042:	f6 c2 01             	test   $0x1,%dl
  801045:	74 35                	je     80107c <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801047:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104e:	25 07 0e 00 00       	and    $0xe07,%eax
  801053:	89 44 24 10          	mov    %eax,0x10(%esp)
  801057:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80105a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80105e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801065:	00 
  801066:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80106a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801071:	e8 df fa ff ff       	call   800b55 <sys_page_map>
  801076:	89 c3                	mov    %eax,%ebx
  801078:	85 c0                	test   %eax,%eax
  80107a:	78 3b                	js     8010b7 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107f:	89 c2                	mov    %eax,%edx
  801081:	c1 ea 0c             	shr    $0xc,%edx
  801084:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80108b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801091:	89 54 24 10          	mov    %edx,0x10(%esp)
  801095:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801099:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a0:	00 
  8010a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ac:	e8 a4 fa ff ff       	call   800b55 <sys_page_map>
  8010b1:	89 c3                	mov    %eax,%ebx
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	79 25                	jns    8010dc <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c2:	e8 e1 fa ff ff       	call   800ba8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d5:	e8 ce fa ff ff       	call   800ba8 <sys_page_unmap>
	return r;
  8010da:	eb 02                	jmp    8010de <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010dc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010de:	89 d8                	mov    %ebx,%eax
  8010e0:	83 c4 4c             	add    $0x4c,%esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 24             	sub    $0x24,%esp
  8010ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f9:	89 1c 24             	mov    %ebx,(%esp)
  8010fc:	e8 49 fd ff ff       	call   800e4a <fd_lookup>
  801101:	85 c0                	test   %eax,%eax
  801103:	78 6d                	js     801172 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801105:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801108:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110f:	8b 00                	mov    (%eax),%eax
  801111:	89 04 24             	mov    %eax,(%esp)
  801114:	e8 87 fd ff ff       	call   800ea0 <dev_lookup>
  801119:	85 c0                	test   %eax,%eax
  80111b:	78 55                	js     801172 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801120:	8b 50 08             	mov    0x8(%eax),%edx
  801123:	83 e2 03             	and    $0x3,%edx
  801126:	83 fa 01             	cmp    $0x1,%edx
  801129:	75 23                	jne    80114e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80112b:	a1 08 40 80 00       	mov    0x804008,%eax
  801130:	8b 40 48             	mov    0x48(%eax),%eax
  801133:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113b:	c7 04 24 31 28 80 00 	movl   $0x802831,(%esp)
  801142:	e8 1d f0 ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114c:	eb 24                	jmp    801172 <read+0x8a>
	}
	if (!dev->dev_read)
  80114e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801151:	8b 52 08             	mov    0x8(%edx),%edx
  801154:	85 d2                	test   %edx,%edx
  801156:	74 15                	je     80116d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801158:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80115b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80115f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801162:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801166:	89 04 24             	mov    %eax,(%esp)
  801169:	ff d2                	call   *%edx
  80116b:	eb 05                	jmp    801172 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80116d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801172:	83 c4 24             	add    $0x24,%esp
  801175:	5b                   	pop    %ebx
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
  80117e:	83 ec 1c             	sub    $0x1c,%esp
  801181:	8b 7d 08             	mov    0x8(%ebp),%edi
  801184:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801187:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118c:	eb 23                	jmp    8011b1 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80118e:	89 f0                	mov    %esi,%eax
  801190:	29 d8                	sub    %ebx,%eax
  801192:	89 44 24 08          	mov    %eax,0x8(%esp)
  801196:	8b 45 0c             	mov    0xc(%ebp),%eax
  801199:	01 d8                	add    %ebx,%eax
  80119b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119f:	89 3c 24             	mov    %edi,(%esp)
  8011a2:	e8 41 ff ff ff       	call   8010e8 <read>
		if (m < 0)
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 10                	js     8011bb <readn+0x43>
			return m;
		if (m == 0)
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	74 0a                	je     8011b9 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011af:	01 c3                	add    %eax,%ebx
  8011b1:	39 f3                	cmp    %esi,%ebx
  8011b3:	72 d9                	jb     80118e <readn+0x16>
  8011b5:	89 d8                	mov    %ebx,%eax
  8011b7:	eb 02                	jmp    8011bb <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011b9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011bb:	83 c4 1c             	add    $0x1c,%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5f                   	pop    %edi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 24             	sub    $0x24,%esp
  8011ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d4:	89 1c 24             	mov    %ebx,(%esp)
  8011d7:	e8 6e fc ff ff       	call   800e4a <fd_lookup>
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 68                	js     801248 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ea:	8b 00                	mov    (%eax),%eax
  8011ec:	89 04 24             	mov    %eax,(%esp)
  8011ef:	e8 ac fc ff ff       	call   800ea0 <dev_lookup>
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 50                	js     801248 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ff:	75 23                	jne    801224 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801201:	a1 08 40 80 00       	mov    0x804008,%eax
  801206:	8b 40 48             	mov    0x48(%eax),%eax
  801209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80120d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801211:	c7 04 24 4d 28 80 00 	movl   $0x80284d,(%esp)
  801218:	e8 47 ef ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  80121d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801222:	eb 24                	jmp    801248 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801224:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801227:	8b 52 0c             	mov    0xc(%edx),%edx
  80122a:	85 d2                	test   %edx,%edx
  80122c:	74 15                	je     801243 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80122e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801231:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801238:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80123c:	89 04 24             	mov    %eax,(%esp)
  80123f:	ff d2                	call   *%edx
  801241:	eb 05                	jmp    801248 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801243:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801248:	83 c4 24             	add    $0x24,%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <seek>:

int
seek(int fdnum, off_t offset)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801254:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	89 04 24             	mov    %eax,(%esp)
  801261:	e8 e4 fb ff ff       	call   800e4a <fd_lookup>
  801266:	85 c0                	test   %eax,%eax
  801268:	78 0e                	js     801278 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80126a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80126d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801270:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	53                   	push   %ebx
  80127e:	83 ec 24             	sub    $0x24,%esp
  801281:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801284:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128b:	89 1c 24             	mov    %ebx,(%esp)
  80128e:	e8 b7 fb ff ff       	call   800e4a <fd_lookup>
  801293:	85 c0                	test   %eax,%eax
  801295:	78 61                	js     8012f8 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801297:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	8b 00                	mov    (%eax),%eax
  8012a3:	89 04 24             	mov    %eax,(%esp)
  8012a6:	e8 f5 fb ff ff       	call   800ea0 <dev_lookup>
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 49                	js     8012f8 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b6:	75 23                	jne    8012db <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012bd:	8b 40 48             	mov    0x48(%eax),%eax
  8012c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c8:	c7 04 24 10 28 80 00 	movl   $0x802810,(%esp)
  8012cf:	e8 90 ee ff ff       	call   800164 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d9:	eb 1d                	jmp    8012f8 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8012db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012de:	8b 52 18             	mov    0x18(%edx),%edx
  8012e1:	85 d2                	test   %edx,%edx
  8012e3:	74 0e                	je     8012f3 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012ec:	89 04 24             	mov    %eax,(%esp)
  8012ef:	ff d2                	call   *%edx
  8012f1:	eb 05                	jmp    8012f8 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f8:	83 c4 24             	add    $0x24,%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 24             	sub    $0x24,%esp
  801305:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801308:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130f:	8b 45 08             	mov    0x8(%ebp),%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	e8 30 fb ff ff       	call   800e4a <fd_lookup>
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 52                	js     801370 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801321:	89 44 24 04          	mov    %eax,0x4(%esp)
  801325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801328:	8b 00                	mov    (%eax),%eax
  80132a:	89 04 24             	mov    %eax,(%esp)
  80132d:	e8 6e fb ff ff       	call   800ea0 <dev_lookup>
  801332:	85 c0                	test   %eax,%eax
  801334:	78 3a                	js     801370 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801336:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801339:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133d:	74 2c                	je     80136b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80133f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801342:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801349:	00 00 00 
	stat->st_isdir = 0;
  80134c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801353:	00 00 00 
	stat->st_dev = dev;
  801356:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801360:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801363:	89 14 24             	mov    %edx,(%esp)
  801366:	ff 50 14             	call   *0x14(%eax)
  801369:	eb 05                	jmp    801370 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80136b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801370:	83 c4 24             	add    $0x24,%esp
  801373:	5b                   	pop    %ebx
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	56                   	push   %esi
  80137a:	53                   	push   %ebx
  80137b:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80137e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801385:	00 
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
  801389:	89 04 24             	mov    %eax,(%esp)
  80138c:	e8 2a 02 00 00       	call   8015bb <open>
  801391:	89 c3                	mov    %eax,%ebx
  801393:	85 c0                	test   %eax,%eax
  801395:	78 1b                	js     8013b2 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801397:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139e:	89 1c 24             	mov    %ebx,(%esp)
  8013a1:	e8 58 ff ff ff       	call   8012fe <fstat>
  8013a6:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a8:	89 1c 24             	mov    %ebx,(%esp)
  8013ab:	e8 d2 fb ff ff       	call   800f82 <close>
	return r;
  8013b0:	89 f3                	mov    %esi,%ebx
}
  8013b2:	89 d8                	mov    %ebx,%eax
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    
	...

008013bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 10             	sub    $0x10,%esp
  8013c4:	89 c3                	mov    %eax,%ebx
  8013c6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013c8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013cf:	75 11                	jne    8013e2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8013d8:	e8 de 0d 00 00       	call   8021bb <ipc_find_env>
  8013dd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013e2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013e9:	00 
  8013ea:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013f1:	00 
  8013f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013f6:	a1 00 40 80 00       	mov    0x804000,%eax
  8013fb:	89 04 24             	mov    %eax,(%esp)
  8013fe:	e8 35 0d 00 00       	call   802138 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801403:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80140a:	00 
  80140b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80140f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801416:	e8 ad 0c 00 00       	call   8020c8 <ipc_recv>
}
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	5b                   	pop    %ebx
  80141f:	5e                   	pop    %esi
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801428:	8b 45 08             	mov    0x8(%ebp),%eax
  80142b:	8b 40 0c             	mov    0xc(%eax),%eax
  80142e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801433:	8b 45 0c             	mov    0xc(%ebp),%eax
  801436:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80143b:	ba 00 00 00 00       	mov    $0x0,%edx
  801440:	b8 02 00 00 00       	mov    $0x2,%eax
  801445:	e8 72 ff ff ff       	call   8013bc <fsipc>
}
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801452:	8b 45 08             	mov    0x8(%ebp),%eax
  801455:	8b 40 0c             	mov    0xc(%eax),%eax
  801458:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80145d:	ba 00 00 00 00       	mov    $0x0,%edx
  801462:	b8 06 00 00 00       	mov    $0x6,%eax
  801467:	e8 50 ff ff ff       	call   8013bc <fsipc>
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 14             	sub    $0x14,%esp
  801475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801478:	8b 45 08             	mov    0x8(%ebp),%eax
  80147b:	8b 40 0c             	mov    0xc(%eax),%eax
  80147e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801483:	ba 00 00 00 00       	mov    $0x0,%edx
  801488:	b8 05 00 00 00       	mov    $0x5,%eax
  80148d:	e8 2a ff ff ff       	call   8013bc <fsipc>
  801492:	85 c0                	test   %eax,%eax
  801494:	78 2b                	js     8014c1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801496:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80149d:	00 
  80149e:	89 1c 24             	mov    %ebx,(%esp)
  8014a1:	e8 69 f2 ff ff       	call   80070f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a6:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b1:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c1:	83 c4 14             	add    $0x14,%esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	83 ec 18             	sub    $0x18,%esp
  8014cd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014dc:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014e8:	76 05                	jbe    8014ef <devfile_write+0x28>
  8014ea:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8014ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fa:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801501:	e8 ec f3 ff ff       	call   8008f2 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801506:	ba 00 00 00 00       	mov    $0x0,%edx
  80150b:	b8 04 00 00 00       	mov    $0x4,%eax
  801510:	e8 a7 fe ff ff       	call   8013bc <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801515:	c9                   	leave  
  801516:	c3                   	ret    

00801517 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	56                   	push   %esi
  80151b:	53                   	push   %ebx
  80151c:	83 ec 10             	sub    $0x10,%esp
  80151f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801522:	8b 45 08             	mov    0x8(%ebp),%eax
  801525:	8b 40 0c             	mov    0xc(%eax),%eax
  801528:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80152d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801533:	ba 00 00 00 00       	mov    $0x0,%edx
  801538:	b8 03 00 00 00       	mov    $0x3,%eax
  80153d:	e8 7a fe ff ff       	call   8013bc <fsipc>
  801542:	89 c3                	mov    %eax,%ebx
  801544:	85 c0                	test   %eax,%eax
  801546:	78 6a                	js     8015b2 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801548:	39 c6                	cmp    %eax,%esi
  80154a:	73 24                	jae    801570 <devfile_read+0x59>
  80154c:	c7 44 24 0c 80 28 80 	movl   $0x802880,0xc(%esp)
  801553:	00 
  801554:	c7 44 24 08 87 28 80 	movl   $0x802887,0x8(%esp)
  80155b:	00 
  80155c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801563:	00 
  801564:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  80156b:	e8 00 0b 00 00       	call   802070 <_panic>
	assert(r <= PGSIZE);
  801570:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801575:	7e 24                	jle    80159b <devfile_read+0x84>
  801577:	c7 44 24 0c a7 28 80 	movl   $0x8028a7,0xc(%esp)
  80157e:	00 
  80157f:	c7 44 24 08 87 28 80 	movl   $0x802887,0x8(%esp)
  801586:	00 
  801587:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80158e:	00 
  80158f:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  801596:	e8 d5 0a 00 00       	call   802070 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80159b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80159f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015a6:	00 
  8015a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015aa:	89 04 24             	mov    %eax,(%esp)
  8015ad:	e8 d6 f2 ff ff       	call   800888 <memmove>
	return r;
}
  8015b2:	89 d8                	mov    %ebx,%eax
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	5b                   	pop    %ebx
  8015b8:	5e                   	pop    %esi
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    

008015bb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	56                   	push   %esi
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 20             	sub    $0x20,%esp
  8015c3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c6:	89 34 24             	mov    %esi,(%esp)
  8015c9:	e8 0e f1 ff ff       	call   8006dc <strlen>
  8015ce:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d3:	7f 60                	jg     801635 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	89 04 24             	mov    %eax,(%esp)
  8015db:	e8 17 f8 ff ff       	call   800df7 <fd_alloc>
  8015e0:	89 c3                	mov    %eax,%ebx
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 54                	js     80163a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ea:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8015f1:	e8 19 f1 ff ff       	call   80070f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801601:	b8 01 00 00 00       	mov    $0x1,%eax
  801606:	e8 b1 fd ff ff       	call   8013bc <fsipc>
  80160b:	89 c3                	mov    %eax,%ebx
  80160d:	85 c0                	test   %eax,%eax
  80160f:	79 15                	jns    801626 <open+0x6b>
		fd_close(fd, 0);
  801611:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801618:	00 
  801619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161c:	89 04 24             	mov    %eax,(%esp)
  80161f:	e8 d6 f8 ff ff       	call   800efa <fd_close>
		return r;
  801624:	eb 14                	jmp    80163a <open+0x7f>
	}

	return fd2num(fd);
  801626:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801629:	89 04 24             	mov    %eax,(%esp)
  80162c:	e8 9b f7 ff ff       	call   800dcc <fd2num>
  801631:	89 c3                	mov    %eax,%ebx
  801633:	eb 05                	jmp    80163a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801635:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80163a:	89 d8                	mov    %ebx,%eax
  80163c:	83 c4 20             	add    $0x20,%esp
  80163f:	5b                   	pop    %ebx
  801640:	5e                   	pop    %esi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    

00801643 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801649:	ba 00 00 00 00       	mov    $0x0,%edx
  80164e:	b8 08 00 00 00       	mov    $0x8,%eax
  801653:	e8 64 fd ff ff       	call   8013bc <fsipc>
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    
	...

0080165c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801662:	c7 44 24 04 b3 28 80 	movl   $0x8028b3,0x4(%esp)
  801669:	00 
  80166a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166d:	89 04 24             	mov    %eax,(%esp)
  801670:	e8 9a f0 ff ff       	call   80070f <strcpy>
	return 0;
}
  801675:	b8 00 00 00 00       	mov    $0x0,%eax
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	53                   	push   %ebx
  801680:	83 ec 14             	sub    $0x14,%esp
  801683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801686:	89 1c 24             	mov    %ebx,(%esp)
  801689:	e8 72 0b 00 00       	call   802200 <pageref>
  80168e:	83 f8 01             	cmp    $0x1,%eax
  801691:	75 0d                	jne    8016a0 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801693:	8b 43 0c             	mov    0xc(%ebx),%eax
  801696:	89 04 24             	mov    %eax,(%esp)
  801699:	e8 1f 03 00 00       	call   8019bd <nsipc_close>
  80169e:	eb 05                	jmp    8016a5 <devsock_close+0x29>
	else
		return 0;
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a5:	83 c4 14             	add    $0x14,%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016b8:	00 
  8016b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cd:	89 04 24             	mov    %eax,(%esp)
  8016d0:	e8 e3 03 00 00       	call   801ab8 <nsipc_send>
}
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016e4:	00 
  8016e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f9:	89 04 24             	mov    %eax,(%esp)
  8016fc:	e8 37 03 00 00       	call   801a38 <nsipc_recv>
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	83 ec 20             	sub    $0x20,%esp
  80170b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80170d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801710:	89 04 24             	mov    %eax,(%esp)
  801713:	e8 df f6 ff ff       	call   800df7 <fd_alloc>
  801718:	89 c3                	mov    %eax,%ebx
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 21                	js     80173f <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80171e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801725:	00 
  801726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801734:	e8 c8 f3 ff ff       	call   800b01 <sys_page_alloc>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	79 0a                	jns    801749 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80173f:	89 34 24             	mov    %esi,(%esp)
  801742:	e8 76 02 00 00       	call   8019bd <nsipc_close>
		return r;
  801747:	eb 22                	jmp    80176b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801749:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801752:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801757:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80175e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801761:	89 04 24             	mov    %eax,(%esp)
  801764:	e8 63 f6 ff ff       	call   800dcc <fd2num>
  801769:	89 c3                	mov    %eax,%ebx
}
  80176b:	89 d8                	mov    %ebx,%eax
  80176d:	83 c4 20             	add    $0x20,%esp
  801770:	5b                   	pop    %ebx
  801771:	5e                   	pop    %esi
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80177a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80177d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801781:	89 04 24             	mov    %eax,(%esp)
  801784:	e8 c1 f6 ff ff       	call   800e4a <fd_lookup>
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 17                	js     8017a4 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801790:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801796:	39 10                	cmp    %edx,(%eax)
  801798:	75 05                	jne    80179f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80179a:	8b 40 0c             	mov    0xc(%eax),%eax
  80179d:	eb 05                	jmp    8017a4 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80179f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	e8 c0 ff ff ff       	call   801774 <fd2sockid>
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 1f                	js     8017d7 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017b8:	8b 55 10             	mov    0x10(%ebp),%edx
  8017bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017c6:	89 04 24             	mov    %eax,(%esp)
  8017c9:	e8 38 01 00 00       	call   801906 <nsipc_accept>
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	78 05                	js     8017d7 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8017d2:	e8 2c ff ff ff       	call   801703 <alloc_sockfd>
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	e8 8d ff ff ff       	call   801774 <fd2sockid>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 16                	js     801801 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8017eb:	8b 55 10             	mov    0x10(%ebp),%edx
  8017ee:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017f9:	89 04 24             	mov    %eax,(%esp)
  8017fc:	e8 5b 01 00 00       	call   80195c <nsipc_bind>
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <shutdown>:

int
shutdown(int s, int how)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801809:	8b 45 08             	mov    0x8(%ebp),%eax
  80180c:	e8 63 ff ff ff       	call   801774 <fd2sockid>
  801811:	85 c0                	test   %eax,%eax
  801813:	78 0f                	js     801824 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801815:	8b 55 0c             	mov    0xc(%ebp),%edx
  801818:	89 54 24 04          	mov    %edx,0x4(%esp)
  80181c:	89 04 24             	mov    %eax,(%esp)
  80181f:	e8 77 01 00 00       	call   80199b <nsipc_shutdown>
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	e8 40 ff ff ff       	call   801774 <fd2sockid>
  801834:	85 c0                	test   %eax,%eax
  801836:	78 16                	js     80184e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801838:	8b 55 10             	mov    0x10(%ebp),%edx
  80183b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80183f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801842:	89 54 24 04          	mov    %edx,0x4(%esp)
  801846:	89 04 24             	mov    %eax,(%esp)
  801849:	e8 89 01 00 00       	call   8019d7 <nsipc_connect>
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <listen>:

int
listen(int s, int backlog)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	e8 16 ff ff ff       	call   801774 <fd2sockid>
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 0f                	js     801871 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801862:	8b 55 0c             	mov    0xc(%ebp),%edx
  801865:	89 54 24 04          	mov    %edx,0x4(%esp)
  801869:	89 04 24             	mov    %eax,(%esp)
  80186c:	e8 a5 01 00 00       	call   801a16 <nsipc_listen>
}
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801879:	8b 45 10             	mov    0x10(%ebp),%eax
  80187c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801880:	8b 45 0c             	mov    0xc(%ebp),%eax
  801883:	89 44 24 04          	mov    %eax,0x4(%esp)
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	89 04 24             	mov    %eax,(%esp)
  80188d:	e8 99 02 00 00       	call   801b2b <nsipc_socket>
  801892:	85 c0                	test   %eax,%eax
  801894:	78 05                	js     80189b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801896:	e8 68 fe ff ff       	call   801703 <alloc_sockfd>
}
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    
  80189d:	00 00                	add    %al,(%eax)
	...

008018a0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 14             	sub    $0x14,%esp
  8018a7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018a9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018b0:	75 11                	jne    8018c3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018b2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8018b9:	e8 fd 08 00 00       	call   8021bb <ipc_find_env>
  8018be:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018c3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018ca:	00 
  8018cb:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8018d2:	00 
  8018d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8018dc:	89 04 24             	mov    %eax,(%esp)
  8018df:	e8 54 08 00 00       	call   802138 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018eb:	00 
  8018ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018f3:	00 
  8018f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fb:	e8 c8 07 00 00       	call   8020c8 <ipc_recv>
}
  801900:	83 c4 14             	add    $0x14,%esp
  801903:	5b                   	pop    %ebx
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	83 ec 10             	sub    $0x10,%esp
  80190e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801919:	8b 06                	mov    (%esi),%eax
  80191b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801920:	b8 01 00 00 00       	mov    $0x1,%eax
  801925:	e8 76 ff ff ff       	call   8018a0 <nsipc>
  80192a:	89 c3                	mov    %eax,%ebx
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 23                	js     801953 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801930:	a1 10 60 80 00       	mov    0x806010,%eax
  801935:	89 44 24 08          	mov    %eax,0x8(%esp)
  801939:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801940:	00 
  801941:	8b 45 0c             	mov    0xc(%ebp),%eax
  801944:	89 04 24             	mov    %eax,(%esp)
  801947:	e8 3c ef ff ff       	call   800888 <memmove>
		*addrlen = ret->ret_addrlen;
  80194c:	a1 10 60 80 00       	mov    0x806010,%eax
  801951:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801953:	89 d8                	mov    %ebx,%eax
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 14             	sub    $0x14,%esp
  801963:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80196e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801972:	8b 45 0c             	mov    0xc(%ebp),%eax
  801975:	89 44 24 04          	mov    %eax,0x4(%esp)
  801979:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801980:	e8 03 ef ff ff       	call   800888 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801985:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80198b:	b8 02 00 00 00       	mov    $0x2,%eax
  801990:	e8 0b ff ff ff       	call   8018a0 <nsipc>
}
  801995:	83 c4 14             	add    $0x14,%esp
  801998:	5b                   	pop    %ebx
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ac:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019b1:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b6:	e8 e5 fe ff ff       	call   8018a0 <nsipc>
}
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <nsipc_close>:

int
nsipc_close(int s)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019cb:	b8 04 00 00 00       	mov    $0x4,%eax
  8019d0:	e8 cb fe ff ff       	call   8018a0 <nsipc>
}
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    

008019d7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	53                   	push   %ebx
  8019db:	83 ec 14             	sub    $0x14,%esp
  8019de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f4:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8019fb:	e8 88 ee ff ff       	call   800888 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a00:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a06:	b8 05 00 00 00       	mov    $0x5,%eax
  801a0b:	e8 90 fe ff ff       	call   8018a0 <nsipc>
}
  801a10:	83 c4 14             	add    $0x14,%esp
  801a13:	5b                   	pop    %ebx
  801a14:	5d                   	pop    %ebp
  801a15:	c3                   	ret    

00801a16 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a27:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a2c:	b8 06 00 00 00       	mov    $0x6,%eax
  801a31:	e8 6a fe ff ff       	call   8018a0 <nsipc>
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 10             	sub    $0x10,%esp
  801a40:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a43:	8b 45 08             	mov    0x8(%ebp),%eax
  801a46:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a4b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a51:	8b 45 14             	mov    0x14(%ebp),%eax
  801a54:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a59:	b8 07 00 00 00       	mov    $0x7,%eax
  801a5e:	e8 3d fe ff ff       	call   8018a0 <nsipc>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 46                	js     801aaf <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801a69:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a6e:	7f 04                	jg     801a74 <nsipc_recv+0x3c>
  801a70:	39 c6                	cmp    %eax,%esi
  801a72:	7d 24                	jge    801a98 <nsipc_recv+0x60>
  801a74:	c7 44 24 0c bf 28 80 	movl   $0x8028bf,0xc(%esp)
  801a7b:	00 
  801a7c:	c7 44 24 08 87 28 80 	movl   $0x802887,0x8(%esp)
  801a83:	00 
  801a84:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801a8b:	00 
  801a8c:	c7 04 24 d4 28 80 00 	movl   $0x8028d4,(%esp)
  801a93:	e8 d8 05 00 00       	call   802070 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a98:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a9c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801aa3:	00 
  801aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa7:	89 04 24             	mov    %eax,(%esp)
  801aaa:	e8 d9 ed ff ff       	call   800888 <memmove>
	}

	return r;
}
  801aaf:	89 d8                	mov    %ebx,%eax
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	53                   	push   %ebx
  801abc:	83 ec 14             	sub    $0x14,%esp
  801abf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801aca:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ad0:	7e 24                	jle    801af6 <nsipc_send+0x3e>
  801ad2:	c7 44 24 0c e0 28 80 	movl   $0x8028e0,0xc(%esp)
  801ad9:	00 
  801ada:	c7 44 24 08 87 28 80 	movl   $0x802887,0x8(%esp)
  801ae1:	00 
  801ae2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801ae9:	00 
  801aea:	c7 04 24 d4 28 80 00 	movl   $0x8028d4,(%esp)
  801af1:	e8 7a 05 00 00       	call   802070 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801af6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b01:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801b08:	e8 7b ed ff ff       	call   800888 <memmove>
	nsipcbuf.send.req_size = size;
  801b0d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b13:	8b 45 14             	mov    0x14(%ebp),%eax
  801b16:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b1b:	b8 08 00 00 00       	mov    $0x8,%eax
  801b20:	e8 7b fd ff ff       	call   8018a0 <nsipc>
}
  801b25:	83 c4 14             	add    $0x14,%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3c:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b41:	8b 45 10             	mov    0x10(%ebp),%eax
  801b44:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b49:	b8 09 00 00 00       	mov    $0x9,%eax
  801b4e:	e8 4d fd ff ff       	call   8018a0 <nsipc>
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    
  801b55:	00 00                	add    %al,(%eax)
	...

00801b58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	83 ec 10             	sub    $0x10,%esp
  801b60:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b63:	8b 45 08             	mov    0x8(%ebp),%eax
  801b66:	89 04 24             	mov    %eax,(%esp)
  801b69:	e8 6e f2 ff ff       	call   800ddc <fd2data>
  801b6e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b70:	c7 44 24 04 ec 28 80 	movl   $0x8028ec,0x4(%esp)
  801b77:	00 
  801b78:	89 34 24             	mov    %esi,(%esp)
  801b7b:	e8 8f eb ff ff       	call   80070f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b80:	8b 43 04             	mov    0x4(%ebx),%eax
  801b83:	2b 03                	sub    (%ebx),%eax
  801b85:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b8b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b92:	00 00 00 
	stat->st_dev = &devpipe;
  801b95:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801b9c:	30 80 00 
	return 0;
}
  801b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	53                   	push   %ebx
  801baf:	83 ec 14             	sub    $0x14,%esp
  801bb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc0:	e8 e3 ef ff ff       	call   800ba8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc5:	89 1c 24             	mov    %ebx,(%esp)
  801bc8:	e8 0f f2 ff ff       	call   800ddc <fd2data>
  801bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd8:	e8 cb ef ff ff       	call   800ba8 <sys_page_unmap>
}
  801bdd:	83 c4 14             	add    $0x14,%esp
  801be0:	5b                   	pop    %ebx
  801be1:	5d                   	pop    %ebp
  801be2:	c3                   	ret    

00801be3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	57                   	push   %edi
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	83 ec 2c             	sub    $0x2c,%esp
  801bec:	89 c7                	mov    %eax,%edi
  801bee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bf1:	a1 08 40 80 00       	mov    0x804008,%eax
  801bf6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bf9:	89 3c 24             	mov    %edi,(%esp)
  801bfc:	e8 ff 05 00 00       	call   802200 <pageref>
  801c01:	89 c6                	mov    %eax,%esi
  801c03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c06:	89 04 24             	mov    %eax,(%esp)
  801c09:	e8 f2 05 00 00       	call   802200 <pageref>
  801c0e:	39 c6                	cmp    %eax,%esi
  801c10:	0f 94 c0             	sete   %al
  801c13:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c16:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c1c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c1f:	39 cb                	cmp    %ecx,%ebx
  801c21:	75 08                	jne    801c2b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c23:	83 c4 2c             	add    $0x2c,%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5f                   	pop    %edi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c2b:	83 f8 01             	cmp    $0x1,%eax
  801c2e:	75 c1                	jne    801bf1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c30:	8b 42 58             	mov    0x58(%edx),%eax
  801c33:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c3a:	00 
  801c3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c43:	c7 04 24 f3 28 80 00 	movl   $0x8028f3,(%esp)
  801c4a:	e8 15 e5 ff ff       	call   800164 <cprintf>
  801c4f:	eb a0                	jmp    801bf1 <_pipeisclosed+0xe>

00801c51 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	57                   	push   %edi
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	83 ec 1c             	sub    $0x1c,%esp
  801c5a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c5d:	89 34 24             	mov    %esi,(%esp)
  801c60:	e8 77 f1 ff ff       	call   800ddc <fd2data>
  801c65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c67:	bf 00 00 00 00       	mov    $0x0,%edi
  801c6c:	eb 3c                	jmp    801caa <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c6e:	89 da                	mov    %ebx,%edx
  801c70:	89 f0                	mov    %esi,%eax
  801c72:	e8 6c ff ff ff       	call   801be3 <_pipeisclosed>
  801c77:	85 c0                	test   %eax,%eax
  801c79:	75 38                	jne    801cb3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c7b:	e8 62 ee ff ff       	call   800ae2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c80:	8b 43 04             	mov    0x4(%ebx),%eax
  801c83:	8b 13                	mov    (%ebx),%edx
  801c85:	83 c2 20             	add    $0x20,%edx
  801c88:	39 d0                	cmp    %edx,%eax
  801c8a:	73 e2                	jae    801c6e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801c92:	89 c2                	mov    %eax,%edx
  801c94:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c9a:	79 05                	jns    801ca1 <devpipe_write+0x50>
  801c9c:	4a                   	dec    %edx
  801c9d:	83 ca e0             	or     $0xffffffe0,%edx
  801ca0:	42                   	inc    %edx
  801ca1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca5:	40                   	inc    %eax
  801ca6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca9:	47                   	inc    %edi
  801caa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cad:	75 d1                	jne    801c80 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	eb 05                	jmp    801cb8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cb8:	83 c4 1c             	add    $0x1c,%esp
  801cbb:	5b                   	pop    %ebx
  801cbc:	5e                   	pop    %esi
  801cbd:	5f                   	pop    %edi
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    

00801cc0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	57                   	push   %edi
  801cc4:	56                   	push   %esi
  801cc5:	53                   	push   %ebx
  801cc6:	83 ec 1c             	sub    $0x1c,%esp
  801cc9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ccc:	89 3c 24             	mov    %edi,(%esp)
  801ccf:	e8 08 f1 ff ff       	call   800ddc <fd2data>
  801cd4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd6:	be 00 00 00 00       	mov    $0x0,%esi
  801cdb:	eb 3a                	jmp    801d17 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cdd:	85 f6                	test   %esi,%esi
  801cdf:	74 04                	je     801ce5 <devpipe_read+0x25>
				return i;
  801ce1:	89 f0                	mov    %esi,%eax
  801ce3:	eb 40                	jmp    801d25 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ce5:	89 da                	mov    %ebx,%edx
  801ce7:	89 f8                	mov    %edi,%eax
  801ce9:	e8 f5 fe ff ff       	call   801be3 <_pipeisclosed>
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	75 2e                	jne    801d20 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cf2:	e8 eb ed ff ff       	call   800ae2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cf7:	8b 03                	mov    (%ebx),%eax
  801cf9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cfc:	74 df                	je     801cdd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cfe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d03:	79 05                	jns    801d0a <devpipe_read+0x4a>
  801d05:	48                   	dec    %eax
  801d06:	83 c8 e0             	or     $0xffffffe0,%eax
  801d09:	40                   	inc    %eax
  801d0a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d11:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d14:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d16:	46                   	inc    %esi
  801d17:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d1a:	75 db                	jne    801cf7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d1c:	89 f0                	mov    %esi,%eax
  801d1e:	eb 05                	jmp    801d25 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d25:	83 c4 1c             	add    $0x1c,%esp
  801d28:	5b                   	pop    %ebx
  801d29:	5e                   	pop    %esi
  801d2a:	5f                   	pop    %edi
  801d2b:	5d                   	pop    %ebp
  801d2c:	c3                   	ret    

00801d2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	57                   	push   %edi
  801d31:	56                   	push   %esi
  801d32:	53                   	push   %ebx
  801d33:	83 ec 3c             	sub    $0x3c,%esp
  801d36:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 b3 f0 ff ff       	call   800df7 <fd_alloc>
  801d44:	89 c3                	mov    %eax,%ebx
  801d46:	85 c0                	test   %eax,%eax
  801d48:	0f 88 45 01 00 00    	js     801e93 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d55:	00 
  801d56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d64:	e8 98 ed ff ff       	call   800b01 <sys_page_alloc>
  801d69:	89 c3                	mov    %eax,%ebx
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	0f 88 20 01 00 00    	js     801e93 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d73:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d76:	89 04 24             	mov    %eax,(%esp)
  801d79:	e8 79 f0 ff ff       	call   800df7 <fd_alloc>
  801d7e:	89 c3                	mov    %eax,%ebx
  801d80:	85 c0                	test   %eax,%eax
  801d82:	0f 88 f8 00 00 00    	js     801e80 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d88:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d8f:	00 
  801d90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d9e:	e8 5e ed ff ff       	call   800b01 <sys_page_alloc>
  801da3:	89 c3                	mov    %eax,%ebx
  801da5:	85 c0                	test   %eax,%eax
  801da7:	0f 88 d3 00 00 00    	js     801e80 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801db0:	89 04 24             	mov    %eax,(%esp)
  801db3:	e8 24 f0 ff ff       	call   800ddc <fd2data>
  801db8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dc1:	00 
  801dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dcd:	e8 2f ed ff ff       	call   800b01 <sys_page_alloc>
  801dd2:	89 c3                	mov    %eax,%ebx
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	0f 88 91 00 00 00    	js     801e6d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ddc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ddf:	89 04 24             	mov    %eax,(%esp)
  801de2:	e8 f5 ef ff ff       	call   800ddc <fd2data>
  801de7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801dee:	00 
  801def:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801df3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dfa:	00 
  801dfb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e06:	e8 4a ed ff ff       	call   800b55 <sys_page_map>
  801e0b:	89 c3                	mov    %eax,%ebx
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 4c                	js     801e5d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e11:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e26:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e3e:	89 04 24             	mov    %eax,(%esp)
  801e41:	e8 86 ef ff ff       	call   800dcc <fd2num>
  801e46:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e4b:	89 04 24             	mov    %eax,(%esp)
  801e4e:	e8 79 ef ff ff       	call   800dcc <fd2num>
  801e53:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e56:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e5b:	eb 36                	jmp    801e93 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e5d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e68:	e8 3b ed ff ff       	call   800ba8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e7b:	e8 28 ed ff ff       	call   800ba8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8e:	e8 15 ed ff ff       	call   800ba8 <sys_page_unmap>
    err:
	return r;
}
  801e93:	89 d8                	mov    %ebx,%eax
  801e95:	83 c4 3c             	add    $0x3c,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801ead:	89 04 24             	mov    %eax,(%esp)
  801eb0:	e8 95 ef ff ff       	call   800e4a <fd_lookup>
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	78 15                	js     801ece <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebc:	89 04 24             	mov    %eax,(%esp)
  801ebf:	e8 18 ef ff ff       	call   800ddc <fd2data>
	return _pipeisclosed(fd, p);
  801ec4:	89 c2                	mov    %eax,%edx
  801ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec9:	e8 15 fd ff ff       	call   801be3 <_pipeisclosed>
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ee0:	c7 44 24 04 0b 29 80 	movl   $0x80290b,0x4(%esp)
  801ee7:	00 
  801ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eeb:	89 04 24             	mov    %eax,(%esp)
  801eee:	e8 1c e8 ff ff       	call   80070f <strcpy>
	return 0;
}
  801ef3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	57                   	push   %edi
  801efe:	56                   	push   %esi
  801eff:	53                   	push   %ebx
  801f00:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f06:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f0b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f11:	eb 30                	jmp    801f43 <devcons_write+0x49>
		m = n - tot;
  801f13:	8b 75 10             	mov    0x10(%ebp),%esi
  801f16:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f18:	83 fe 7f             	cmp    $0x7f,%esi
  801f1b:	76 05                	jbe    801f22 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f1d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f22:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f26:	03 45 0c             	add    0xc(%ebp),%eax
  801f29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2d:	89 3c 24             	mov    %edi,(%esp)
  801f30:	e8 53 e9 ff ff       	call   800888 <memmove>
		sys_cputs(buf, m);
  801f35:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f39:	89 3c 24             	mov    %edi,(%esp)
  801f3c:	e8 f3 ea ff ff       	call   800a34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f41:	01 f3                	add    %esi,%ebx
  801f43:	89 d8                	mov    %ebx,%eax
  801f45:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f48:	72 c9                	jb     801f13 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f4a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f50:	5b                   	pop    %ebx
  801f51:	5e                   	pop    %esi
  801f52:	5f                   	pop    %edi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f5f:	75 07                	jne    801f68 <devcons_read+0x13>
  801f61:	eb 25                	jmp    801f88 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f63:	e8 7a eb ff ff       	call   800ae2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f68:	e8 e5 ea ff ff       	call   800a52 <sys_cgetc>
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	74 f2                	je     801f63 <devcons_read+0xe>
  801f71:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 1d                	js     801f94 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f77:	83 f8 04             	cmp    $0x4,%eax
  801f7a:	74 13                	je     801f8f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7f:	88 10                	mov    %dl,(%eax)
	return 1;
  801f81:	b8 01 00 00 00       	mov    $0x1,%eax
  801f86:	eb 0c                	jmp    801f94 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f88:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8d:	eb 05                	jmp    801f94 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f8f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fa2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fa9:	00 
  801faa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fad:	89 04 24             	mov    %eax,(%esp)
  801fb0:	e8 7f ea ff ff       	call   800a34 <sys_cputs>
}
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <getchar>:

int
getchar(void)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fbd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801fc4:	00 
  801fc5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd3:	e8 10 f1 ff ff       	call   8010e8 <read>
	if (r < 0)
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 0f                	js     801feb <getchar+0x34>
		return r;
	if (r < 1)
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	7e 06                	jle    801fe6 <getchar+0x2f>
		return -E_EOF;
	return c;
  801fe0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fe4:	eb 05                	jmp    801feb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fe6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801feb:	c9                   	leave  
  801fec:	c3                   	ret    

00801fed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffa:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffd:	89 04 24             	mov    %eax,(%esp)
  802000:	e8 45 ee ff ff       	call   800e4a <fd_lookup>
  802005:	85 c0                	test   %eax,%eax
  802007:	78 11                	js     80201a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802009:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802012:	39 10                	cmp    %edx,(%eax)
  802014:	0f 94 c0             	sete   %al
  802017:	0f b6 c0             	movzbl %al,%eax
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <opencons>:

int
opencons(void)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802025:	89 04 24             	mov    %eax,(%esp)
  802028:	e8 ca ed ff ff       	call   800df7 <fd_alloc>
  80202d:	85 c0                	test   %eax,%eax
  80202f:	78 3c                	js     80206d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802031:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802038:	00 
  802039:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802047:	e8 b5 ea ff ff       	call   800b01 <sys_page_alloc>
  80204c:	85 c0                	test   %eax,%eax
  80204e:	78 1d                	js     80206d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802050:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802059:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802065:	89 04 24             	mov    %eax,(%esp)
  802068:	e8 5f ed ff ff       	call   800dcc <fd2num>
}
  80206d:	c9                   	leave  
  80206e:	c3                   	ret    
	...

00802070 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	56                   	push   %esi
  802074:	53                   	push   %ebx
  802075:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802078:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80207b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802081:	e8 3d ea ff ff       	call   800ac3 <sys_getenvid>
  802086:	8b 55 0c             	mov    0xc(%ebp),%edx
  802089:	89 54 24 10          	mov    %edx,0x10(%esp)
  80208d:	8b 55 08             	mov    0x8(%ebp),%edx
  802090:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802094:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802098:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209c:	c7 04 24 18 29 80 00 	movl   $0x802918,(%esp)
  8020a3:	e8 bc e0 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8020af:	89 04 24             	mov    %eax,(%esp)
  8020b2:	e8 4c e0 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  8020b7:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  8020be:	e8 a1 e0 ff ff       	call   800164 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020c3:	cc                   	int3   
  8020c4:	eb fd                	jmp    8020c3 <_panic+0x53>
	...

008020c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	56                   	push   %esi
  8020cc:	53                   	push   %ebx
  8020cd:	83 ec 10             	sub    $0x10,%esp
  8020d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	74 0a                	je     8020e7 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8020dd:	89 04 24             	mov    %eax,(%esp)
  8020e0:	e8 32 ec ff ff       	call   800d17 <sys_ipc_recv>
  8020e5:	eb 0c                	jmp    8020f3 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8020e7:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8020ee:	e8 24 ec ff ff       	call   800d17 <sys_ipc_recv>
	}
	if (r < 0)
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	79 16                	jns    80210d <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8020f7:	85 db                	test   %ebx,%ebx
  8020f9:	74 06                	je     802101 <ipc_recv+0x39>
  8020fb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802101:	85 f6                	test   %esi,%esi
  802103:	74 2c                	je     802131 <ipc_recv+0x69>
  802105:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80210b:	eb 24                	jmp    802131 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  80210d:	85 db                	test   %ebx,%ebx
  80210f:	74 0a                	je     80211b <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802111:	a1 08 40 80 00       	mov    0x804008,%eax
  802116:	8b 40 74             	mov    0x74(%eax),%eax
  802119:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80211b:	85 f6                	test   %esi,%esi
  80211d:	74 0a                	je     802129 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80211f:	a1 08 40 80 00       	mov    0x804008,%eax
  802124:	8b 40 78             	mov    0x78(%eax),%eax
  802127:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802129:	a1 08 40 80 00       	mov    0x804008,%eax
  80212e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    

00802138 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	57                   	push   %edi
  80213c:	56                   	push   %esi
  80213d:	53                   	push   %ebx
  80213e:	83 ec 1c             	sub    $0x1c,%esp
  802141:	8b 75 08             	mov    0x8(%ebp),%esi
  802144:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802147:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80214a:	85 db                	test   %ebx,%ebx
  80214c:	74 19                	je     802167 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80214e:	8b 45 14             	mov    0x14(%ebp),%eax
  802151:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802155:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802159:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80215d:	89 34 24             	mov    %esi,(%esp)
  802160:	e8 8f eb ff ff       	call   800cf4 <sys_ipc_try_send>
  802165:	eb 1c                	jmp    802183 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802167:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80216e:	00 
  80216f:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802176:	ee 
  802177:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80217b:	89 34 24             	mov    %esi,(%esp)
  80217e:	e8 71 eb ff ff       	call   800cf4 <sys_ipc_try_send>
		}
		if (r == 0)
  802183:	85 c0                	test   %eax,%eax
  802185:	74 2c                	je     8021b3 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802187:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80218a:	74 20                	je     8021ac <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  80218c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802190:	c7 44 24 08 3c 29 80 	movl   $0x80293c,0x8(%esp)
  802197:	00 
  802198:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80219f:	00 
  8021a0:	c7 04 24 4f 29 80 00 	movl   $0x80294f,(%esp)
  8021a7:	e8 c4 fe ff ff       	call   802070 <_panic>
		}
		sys_yield();
  8021ac:	e8 31 e9 ff ff       	call   800ae2 <sys_yield>
	}
  8021b1:	eb 97                	jmp    80214a <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8021b3:	83 c4 1c             	add    $0x1c,%esp
  8021b6:	5b                   	pop    %ebx
  8021b7:	5e                   	pop    %esi
  8021b8:	5f                   	pop    %edi
  8021b9:	5d                   	pop    %ebp
  8021ba:	c3                   	ret    

008021bb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	53                   	push   %ebx
  8021bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021c7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021ce:	89 c2                	mov    %eax,%edx
  8021d0:	c1 e2 07             	shl    $0x7,%edx
  8021d3:	29 ca                	sub    %ecx,%edx
  8021d5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021db:	8b 52 50             	mov    0x50(%edx),%edx
  8021de:	39 da                	cmp    %ebx,%edx
  8021e0:	75 0f                	jne    8021f1 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021e2:	c1 e0 07             	shl    $0x7,%eax
  8021e5:	29 c8                	sub    %ecx,%eax
  8021e7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021ec:	8b 40 40             	mov    0x40(%eax),%eax
  8021ef:	eb 0c                	jmp    8021fd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021f1:	40                   	inc    %eax
  8021f2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021f7:	75 ce                	jne    8021c7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021f9:	66 b8 00 00          	mov    $0x0,%ax
}
  8021fd:	5b                   	pop    %ebx
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802206:	89 c2                	mov    %eax,%edx
  802208:	c1 ea 16             	shr    $0x16,%edx
  80220b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802212:	f6 c2 01             	test   $0x1,%dl
  802215:	74 1e                	je     802235 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802217:	c1 e8 0c             	shr    $0xc,%eax
  80221a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802221:	a8 01                	test   $0x1,%al
  802223:	74 17                	je     80223c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802225:	c1 e8 0c             	shr    $0xc,%eax
  802228:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80222f:	ef 
  802230:	0f b7 c0             	movzwl %ax,%eax
  802233:	eb 0c                	jmp    802241 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802235:	b8 00 00 00 00       	mov    $0x0,%eax
  80223a:	eb 05                	jmp    802241 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80223c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802241:	5d                   	pop    %ebp
  802242:	c3                   	ret    
	...

00802244 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802244:	55                   	push   %ebp
  802245:	57                   	push   %edi
  802246:	56                   	push   %esi
  802247:	83 ec 10             	sub    $0x10,%esp
  80224a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80224e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802252:	89 74 24 04          	mov    %esi,0x4(%esp)
  802256:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80225a:	89 cd                	mov    %ecx,%ebp
  80225c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802260:	85 c0                	test   %eax,%eax
  802262:	75 2c                	jne    802290 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802264:	39 f9                	cmp    %edi,%ecx
  802266:	77 68                	ja     8022d0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802268:	85 c9                	test   %ecx,%ecx
  80226a:	75 0b                	jne    802277 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80226c:	b8 01 00 00 00       	mov    $0x1,%eax
  802271:	31 d2                	xor    %edx,%edx
  802273:	f7 f1                	div    %ecx
  802275:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802277:	31 d2                	xor    %edx,%edx
  802279:	89 f8                	mov    %edi,%eax
  80227b:	f7 f1                	div    %ecx
  80227d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80227f:	89 f0                	mov    %esi,%eax
  802281:	f7 f1                	div    %ecx
  802283:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802285:	89 f0                	mov    %esi,%eax
  802287:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802289:	83 c4 10             	add    $0x10,%esp
  80228c:	5e                   	pop    %esi
  80228d:	5f                   	pop    %edi
  80228e:	5d                   	pop    %ebp
  80228f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802290:	39 f8                	cmp    %edi,%eax
  802292:	77 2c                	ja     8022c0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802294:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802297:	83 f6 1f             	xor    $0x1f,%esi
  80229a:	75 4c                	jne    8022e8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80229c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80229e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022a3:	72 0a                	jb     8022af <__udivdi3+0x6b>
  8022a5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022a9:	0f 87 ad 00 00 00    	ja     80235c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022af:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022b4:	89 f0                	mov    %esi,%eax
  8022b6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022b8:	83 c4 10             	add    $0x10,%esp
  8022bb:	5e                   	pop    %esi
  8022bc:	5f                   	pop    %edi
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    
  8022bf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022c0:	31 ff                	xor    %edi,%edi
  8022c2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022c4:	89 f0                	mov    %esi,%eax
  8022c6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022c8:	83 c4 10             	add    $0x10,%esp
  8022cb:	5e                   	pop    %esi
  8022cc:	5f                   	pop    %edi
  8022cd:	5d                   	pop    %ebp
  8022ce:	c3                   	ret    
  8022cf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022d0:	89 fa                	mov    %edi,%edx
  8022d2:	89 f0                	mov    %esi,%eax
  8022d4:	f7 f1                	div    %ecx
  8022d6:	89 c6                	mov    %eax,%esi
  8022d8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022da:	89 f0                	mov    %esi,%eax
  8022dc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022e8:	89 f1                	mov    %esi,%ecx
  8022ea:	d3 e0                	shl    %cl,%eax
  8022ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022f0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022f5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022f7:	89 ea                	mov    %ebp,%edx
  8022f9:	88 c1                	mov    %al,%cl
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802301:	09 ca                	or     %ecx,%edx
  802303:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802307:	89 f1                	mov    %esi,%ecx
  802309:	d3 e5                	shl    %cl,%ebp
  80230b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80230f:	89 fd                	mov    %edi,%ebp
  802311:	88 c1                	mov    %al,%cl
  802313:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802315:	89 fa                	mov    %edi,%edx
  802317:	89 f1                	mov    %esi,%ecx
  802319:	d3 e2                	shl    %cl,%edx
  80231b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80231f:	88 c1                	mov    %al,%cl
  802321:	d3 ef                	shr    %cl,%edi
  802323:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802325:	89 f8                	mov    %edi,%eax
  802327:	89 ea                	mov    %ebp,%edx
  802329:	f7 74 24 08          	divl   0x8(%esp)
  80232d:	89 d1                	mov    %edx,%ecx
  80232f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802331:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802335:	39 d1                	cmp    %edx,%ecx
  802337:	72 17                	jb     802350 <__udivdi3+0x10c>
  802339:	74 09                	je     802344 <__udivdi3+0x100>
  80233b:	89 fe                	mov    %edi,%esi
  80233d:	31 ff                	xor    %edi,%edi
  80233f:	e9 41 ff ff ff       	jmp    802285 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802344:	8b 54 24 04          	mov    0x4(%esp),%edx
  802348:	89 f1                	mov    %esi,%ecx
  80234a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80234c:	39 c2                	cmp    %eax,%edx
  80234e:	73 eb                	jae    80233b <__udivdi3+0xf7>
		{
		  q0--;
  802350:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802353:	31 ff                	xor    %edi,%edi
  802355:	e9 2b ff ff ff       	jmp    802285 <__udivdi3+0x41>
  80235a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80235c:	31 f6                	xor    %esi,%esi
  80235e:	e9 22 ff ff ff       	jmp    802285 <__udivdi3+0x41>
	...

00802364 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802364:	55                   	push   %ebp
  802365:	57                   	push   %edi
  802366:	56                   	push   %esi
  802367:	83 ec 20             	sub    $0x20,%esp
  80236a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80236e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802372:	89 44 24 14          	mov    %eax,0x14(%esp)
  802376:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80237a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80237e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802382:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802384:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802386:	85 ed                	test   %ebp,%ebp
  802388:	75 16                	jne    8023a0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80238a:	39 f1                	cmp    %esi,%ecx
  80238c:	0f 86 a6 00 00 00    	jbe    802438 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802392:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802394:	89 d0                	mov    %edx,%eax
  802396:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802398:	83 c4 20             	add    $0x20,%esp
  80239b:	5e                   	pop    %esi
  80239c:	5f                   	pop    %edi
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    
  80239f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023a0:	39 f5                	cmp    %esi,%ebp
  8023a2:	0f 87 ac 00 00 00    	ja     802454 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023a8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8023ab:	83 f0 1f             	xor    $0x1f,%eax
  8023ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023b2:	0f 84 a8 00 00 00    	je     802460 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023b8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023bc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023be:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023c7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023cb:	89 f9                	mov    %edi,%ecx
  8023cd:	d3 e8                	shr    %cl,%eax
  8023cf:	09 e8                	or     %ebp,%eax
  8023d1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023d5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023d9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023dd:	d3 e0                	shl    %cl,%eax
  8023df:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023e7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023eb:	d3 e0                	shl    %cl,%eax
  8023ed:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023f1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023fb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023fd:	89 f2                	mov    %esi,%edx
  8023ff:	f7 74 24 18          	divl   0x18(%esp)
  802403:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802405:	f7 64 24 0c          	mull   0xc(%esp)
  802409:	89 c5                	mov    %eax,%ebp
  80240b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80240d:	39 d6                	cmp    %edx,%esi
  80240f:	72 67                	jb     802478 <__umoddi3+0x114>
  802411:	74 75                	je     802488 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802413:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802417:	29 e8                	sub    %ebp,%eax
  802419:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80241b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80241f:	d3 e8                	shr    %cl,%eax
  802421:	89 f2                	mov    %esi,%edx
  802423:	89 f9                	mov    %edi,%ecx
  802425:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802427:	09 d0                	or     %edx,%eax
  802429:	89 f2                	mov    %esi,%edx
  80242b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80242f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802431:	83 c4 20             	add    $0x20,%esp
  802434:	5e                   	pop    %esi
  802435:	5f                   	pop    %edi
  802436:	5d                   	pop    %ebp
  802437:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802438:	85 c9                	test   %ecx,%ecx
  80243a:	75 0b                	jne    802447 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80243c:	b8 01 00 00 00       	mov    $0x1,%eax
  802441:	31 d2                	xor    %edx,%edx
  802443:	f7 f1                	div    %ecx
  802445:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802447:	89 f0                	mov    %esi,%eax
  802449:	31 d2                	xor    %edx,%edx
  80244b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80244d:	89 f8                	mov    %edi,%eax
  80244f:	e9 3e ff ff ff       	jmp    802392 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802454:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802456:	83 c4 20             	add    $0x20,%esp
  802459:	5e                   	pop    %esi
  80245a:	5f                   	pop    %edi
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    
  80245d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802460:	39 f5                	cmp    %esi,%ebp
  802462:	72 04                	jb     802468 <__umoddi3+0x104>
  802464:	39 f9                	cmp    %edi,%ecx
  802466:	77 06                	ja     80246e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802468:	89 f2                	mov    %esi,%edx
  80246a:	29 cf                	sub    %ecx,%edi
  80246c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80246e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802470:	83 c4 20             	add    $0x20,%esp
  802473:	5e                   	pop    %esi
  802474:	5f                   	pop    %edi
  802475:	5d                   	pop    %ebp
  802476:	c3                   	ret    
  802477:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802478:	89 d1                	mov    %edx,%ecx
  80247a:	89 c5                	mov    %eax,%ebp
  80247c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802480:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802484:	eb 8d                	jmp    802413 <__umoddi3+0xaf>
  802486:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802488:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80248c:	72 ea                	jb     802478 <__umoddi3+0x114>
  80248e:	89 f1                	mov    %esi,%ecx
  802490:	eb 81                	jmp    802413 <__umoddi3+0xaf>
