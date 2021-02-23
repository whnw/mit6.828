
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  80005c:	e8 13 01 00 00       	call   800174 <cprintf>
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 10             	sub    $0x10,%esp
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800072:	e8 5c 0a 00 00       	call   800ad3 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800083:	c1 e0 07             	shl    $0x7,%eax
  800086:	29 d0                	sub    %edx,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 0c 40 80 00       	mov    %eax,0x80400c


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 f6                	test   %esi,%esi
  800094:	7e 07                	jle    80009d <libmain+0x39>
		binaryname = argv[0];
  800096:	8b 03                	mov    (%ebx),%eax
  800098:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	89 34 24             	mov    %esi,(%esp)
  8000a4:	e8 8b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a9:	e8 0a 00 00 00       	call   8000b8 <exit>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    
  8000b5:	00 00                	add    %al,(%eax)
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000be:	e8 00 0f 00 00       	call   800fc3 <close_all>
	sys_env_destroy(0);
  8000c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ca:	e8 b2 09 00 00       	call   800a81 <sys_env_destroy>
}
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    
  8000d1:	00 00                	add    %al,(%eax)
	...

008000d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 14             	sub    $0x14,%esp
  8000db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000de:	8b 03                	mov    (%ebx),%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e7:	40                   	inc    %eax
  8000e8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	75 19                	jne    80010a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000f1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f8:	00 
  8000f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fc:	89 04 24             	mov    %eax,(%esp)
  8000ff:	e8 40 09 00 00       	call   800a44 <sys_cputs>
		b->idx = 0;
  800104:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010a:	ff 43 04             	incl   0x4(%ebx)
}
  80010d:	83 c4 14             	add    $0x14,%esp
  800110:	5b                   	pop    %ebx
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800123:	00 00 00 
	b.cnt = 0;
  800126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800130:	8b 45 0c             	mov    0xc(%ebp),%eax
  800133:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800137:	8b 45 08             	mov    0x8(%ebp),%eax
  80013a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800144:	89 44 24 04          	mov    %eax,0x4(%esp)
  800148:	c7 04 24 d4 00 80 00 	movl   $0x8000d4,(%esp)
  80014f:	e8 82 01 00 00       	call   8002d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800154:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 d8 08 00 00       	call   800a44 <sys_cputs>

	return b.cnt;
}
  80016c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 87 ff ff ff       	call   800113 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	75 08                	jne    8001bc <printnum+0x2c>
  8001b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ba:	77 57                	ja     800213 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001c0:	4b                   	dec    %ebx
  8001c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001db:	00 
  8001dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001df:	89 04 24             	mov    %eax,(%esp)
  8001e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	e8 66 20 00 00       	call   802254 <__udivdi3>
  8001ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f6:	89 04 24             	mov    %eax,(%esp)
  8001f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fd:	89 fa                	mov    %edi,%edx
  8001ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800202:	e8 89 ff ff ff       	call   800190 <printnum>
  800207:	eb 0f                	jmp    800218 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800209:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020d:	89 34 24             	mov    %esi,(%esp)
  800210:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800213:	4b                   	dec    %ebx
  800214:	85 db                	test   %ebx,%ebx
  800216:	7f f1                	jg     800209 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800218:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800220:	8b 45 10             	mov    0x10(%ebp),%eax
  800223:	89 44 24 08          	mov    %eax,0x8(%esp)
  800227:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022e:	00 
  80022f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	e8 33 21 00 00       	call   802374 <__umoddi3>
  800241:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800245:	0f be 80 d8 24 80 00 	movsbl 0x8024d8(%eax),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800252:	83 c4 3c             	add    $0x3c,%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025d:	83 fa 01             	cmp    $0x1,%edx
  800260:	7e 0e                	jle    800270 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 08             	lea    0x8(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	8b 52 04             	mov    0x4(%edx),%edx
  80026e:	eb 22                	jmp    800292 <getuint+0x38>
	else if (lflag)
  800270:	85 d2                	test   %edx,%edx
  800272:	74 10                	je     800284 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
  800282:	eb 0e                	jmp    800292 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 04             	lea    0x4(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a2:	73 08                	jae    8002ac <sprintputch+0x18>
		*b->buf++ = ch;
  8002a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a7:	88 0a                	mov    %cl,(%edx)
  8002a9:	42                   	inc    %edx
  8002aa:	89 10                	mov    %edx,(%eax)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	e8 02 00 00 00       	call   8002d6 <vprintfmt>
	va_end(ap);
}
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 4c             	sub    $0x4c,%esp
  8002df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e5:	eb 12                	jmp    8002f9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	0f 84 6b 03 00 00    	je     80065a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f9:	0f b6 06             	movzbl (%esi),%eax
  8002fc:	46                   	inc    %esi
  8002fd:	83 f8 25             	cmp    $0x25,%eax
  800300:	75 e5                	jne    8002e7 <vprintfmt+0x11>
  800302:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800306:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80030d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800312:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800319:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031e:	eb 26                	jmp    800346 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800323:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800327:	eb 1d                	jmp    800346 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800330:	eb 14                	jmp    800346 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800335:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80033c:	eb 08                	jmp    800346 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800341:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	0f b6 06             	movzbl (%esi),%eax
  800349:	8d 56 01             	lea    0x1(%esi),%edx
  80034c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80034f:	8a 16                	mov    (%esi),%dl
  800351:	83 ea 23             	sub    $0x23,%edx
  800354:	80 fa 55             	cmp    $0x55,%dl
  800357:	0f 87 e1 02 00 00    	ja     80063e <vprintfmt+0x368>
  80035d:	0f b6 d2             	movzbl %dl,%edx
  800360:	ff 24 95 20 26 80 00 	jmp    *0x802620(,%edx,4)
  800367:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80036a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800372:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800376:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800379:	8d 50 d0             	lea    -0x30(%eax),%edx
  80037c:	83 fa 09             	cmp    $0x9,%edx
  80037f:	77 2a                	ja     8003ab <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800381:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800382:	eb eb                	jmp    80036f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 50 04             	lea    0x4(%eax),%edx
  80038a:	89 55 14             	mov    %edx,0x14(%ebp)
  80038d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800392:	eb 17                	jmp    8003ab <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800394:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800398:	78 98                	js     800332 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80039d:	eb a7                	jmp    800346 <vprintfmt+0x70>
  80039f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003a9:	eb 9b                	jmp    800346 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003af:	79 95                	jns    800346 <vprintfmt+0x70>
  8003b1:	eb 8b                	jmp    80033e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b7:	eb 8d                	jmp    800346 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 50 04             	lea    0x4(%eax),%edx
  8003bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d1:	e9 23 ff ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 50 04             	lea    0x4(%eax),%edx
  8003dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	79 02                	jns    8003e7 <vprintfmt+0x111>
  8003e5:	f7 d8                	neg    %eax
  8003e7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e9:	83 f8 10             	cmp    $0x10,%eax
  8003ec:	7f 0b                	jg     8003f9 <vprintfmt+0x123>
  8003ee:	8b 04 85 80 27 80 00 	mov    0x802780(,%eax,4),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	75 23                	jne    80041c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003fd:	c7 44 24 08 f0 24 80 	movl   $0x8024f0,0x8(%esp)
  800404:	00 
  800405:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 9a fe ff ff       	call   8002ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800417:	e9 dd fe ff ff       	jmp    8002f9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80041c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800420:	c7 44 24 08 b9 28 80 	movl   $0x8028b9,0x8(%esp)
  800427:	00 
  800428:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042c:	8b 55 08             	mov    0x8(%ebp),%edx
  80042f:	89 14 24             	mov    %edx,(%esp)
  800432:	e8 77 fe ff ff       	call   8002ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043a:	e9 ba fe ff ff       	jmp    8002f9 <vprintfmt+0x23>
  80043f:	89 f9                	mov    %edi,%ecx
  800441:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800444:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 30                	mov    (%eax),%esi
  800452:	85 f6                	test   %esi,%esi
  800454:	75 05                	jne    80045b <vprintfmt+0x185>
				p = "(null)";
  800456:	be e9 24 80 00       	mov    $0x8024e9,%esi
			if (width > 0 && padc != '-')
  80045b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045f:	0f 8e 84 00 00 00    	jle    8004e9 <vprintfmt+0x213>
  800465:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800469:	74 7e                	je     8004e9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80046f:	89 34 24             	mov    %esi,(%esp)
  800472:	e8 8b 02 00 00       	call   800702 <strnlen>
  800477:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80047a:	29 c2                	sub    %eax,%edx
  80047c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80047f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800483:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800486:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800489:	89 de                	mov    %ebx,%esi
  80048b:	89 d3                	mov    %edx,%ebx
  80048d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	eb 0b                	jmp    80049c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800491:	89 74 24 04          	mov    %esi,0x4(%esp)
  800495:	89 3c 24             	mov    %edi,(%esp)
  800498:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	4b                   	dec    %ebx
  80049c:	85 db                	test   %ebx,%ebx
  80049e:	7f f1                	jg     800491 <vprintfmt+0x1bb>
  8004a0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004a3:	89 f3                	mov    %esi,%ebx
  8004a5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	79 05                	jns    8004b4 <vprintfmt+0x1de>
  8004af:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b7:	29 c2                	sub    %eax,%edx
  8004b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004bc:	eb 2b                	jmp    8004e9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c2:	74 18                	je     8004dc <vprintfmt+0x206>
  8004c4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ca:	76 10                	jbe    8004dc <vprintfmt+0x206>
					putch('?', putdat);
  8004cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d7:	ff 55 08             	call   *0x8(%ebp)
  8004da:	eb 0a                	jmp    8004e6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e9:	0f be 06             	movsbl (%esi),%eax
  8004ec:	46                   	inc    %esi
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	74 21                	je     800512 <vprintfmt+0x23c>
  8004f1:	85 ff                	test   %edi,%edi
  8004f3:	78 c9                	js     8004be <vprintfmt+0x1e8>
  8004f5:	4f                   	dec    %edi
  8004f6:	79 c6                	jns    8004be <vprintfmt+0x1e8>
  8004f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004fb:	89 de                	mov    %ebx,%esi
  8004fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800500:	eb 18                	jmp    80051a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800502:	89 74 24 04          	mov    %esi,0x4(%esp)
  800506:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80050d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050f:	4b                   	dec    %ebx
  800510:	eb 08                	jmp    80051a <vprintfmt+0x244>
  800512:	8b 7d 08             	mov    0x8(%ebp),%edi
  800515:	89 de                	mov    %ebx,%esi
  800517:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80051a:	85 db                	test   %ebx,%ebx
  80051c:	7f e4                	jg     800502 <vprintfmt+0x22c>
  80051e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800521:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800526:	e9 ce fd ff ff       	jmp    8002f9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052b:	83 f9 01             	cmp    $0x1,%ecx
  80052e:	7e 10                	jle    800540 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 08             	lea    0x8(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 30                	mov    (%eax),%esi
  80053b:	8b 78 04             	mov    0x4(%eax),%edi
  80053e:	eb 26                	jmp    800566 <vprintfmt+0x290>
	else if (lflag)
  800540:	85 c9                	test   %ecx,%ecx
  800542:	74 12                	je     800556 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 30                	mov    (%eax),%esi
  80054f:	89 f7                	mov    %esi,%edi
  800551:	c1 ff 1f             	sar    $0x1f,%edi
  800554:	eb 10                	jmp    800566 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 30                	mov    (%eax),%esi
  800561:	89 f7                	mov    %esi,%edi
  800563:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800566:	85 ff                	test   %edi,%edi
  800568:	78 0a                	js     800574 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056f:	e9 8c 00 00 00       	jmp    800600 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800574:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800578:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800582:	f7 de                	neg    %esi
  800584:	83 d7 00             	adc    $0x0,%edi
  800587:	f7 df                	neg    %edi
			}
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058e:	eb 70                	jmp    800600 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800590:	89 ca                	mov    %ecx,%edx
  800592:	8d 45 14             	lea    0x14(%ebp),%eax
  800595:	e8 c0 fc ff ff       	call   80025a <getuint>
  80059a:	89 c6                	mov    %eax,%esi
  80059c:	89 d7                	mov    %edx,%edi
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a3:	eb 5b                	jmp    800600 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8005a5:	89 ca                	mov    %ecx,%edx
  8005a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005aa:	e8 ab fc ff ff       	call   80025a <getuint>
  8005af:	89 c6                	mov    %eax,%esi
  8005b1:	89 d7                	mov    %edx,%edi
			base = 8;
  8005b3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005b8:	eb 46                	jmp    800600 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005be:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005c5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005df:	8b 30                	mov    (%eax),%esi
  8005e1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005eb:	eb 13                	jmp    800600 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005ed:	89 ca                	mov    %ecx,%edx
  8005ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f2:	e8 63 fc ff ff       	call   80025a <getuint>
  8005f7:	89 c6                	mov    %eax,%esi
  8005f9:	89 d7                	mov    %edx,%edi
			base = 16;
  8005fb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800600:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800604:	89 54 24 10          	mov    %edx,0x10(%esp)
  800608:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800613:	89 34 24             	mov    %esi,(%esp)
  800616:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061a:	89 da                	mov    %ebx,%edx
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	e8 6c fb ff ff       	call   800190 <printnum>
			break;
  800624:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800627:	e9 cd fc ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80062c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800639:	e9 bb fc ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800642:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800649:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064c:	eb 01                	jmp    80064f <vprintfmt+0x379>
  80064e:	4e                   	dec    %esi
  80064f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800653:	75 f9                	jne    80064e <vprintfmt+0x378>
  800655:	e9 9f fc ff ff       	jmp    8002f9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80065a:	83 c4 4c             	add    $0x4c,%esp
  80065d:	5b                   	pop    %ebx
  80065e:	5e                   	pop    %esi
  80065f:	5f                   	pop    %edi
  800660:	5d                   	pop    %ebp
  800661:	c3                   	ret    

00800662 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
  800665:	83 ec 28             	sub    $0x28,%esp
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800671:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800675:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067f:	85 c0                	test   %eax,%eax
  800681:	74 30                	je     8006b3 <vsnprintf+0x51>
  800683:	85 d2                	test   %edx,%edx
  800685:	7e 33                	jle    8006ba <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068e:	8b 45 10             	mov    0x10(%ebp),%eax
  800691:	89 44 24 08          	mov    %eax,0x8(%esp)
  800695:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069c:	c7 04 24 94 02 80 00 	movl   $0x800294,(%esp)
  8006a3:	e8 2e fc ff ff       	call   8002d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b1:	eb 0c                	jmp    8006bf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b8:	eb 05                	jmp    8006bf <vsnprintf+0x5d>
  8006ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	89 04 24             	mov    %eax,(%esp)
  8006e2:	e8 7b ff ff ff       	call   800662 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    
  8006e9:	00 00                	add    %al,(%eax)
	...

008006ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f7:	eb 01                	jmp    8006fa <strlen+0xe>
		n++;
  8006f9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fe:	75 f9                	jne    8006f9 <strlen+0xd>
		n++;
	return n;
}
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	b8 00 00 00 00       	mov    $0x0,%eax
  800710:	eb 01                	jmp    800713 <strnlen+0x11>
		n++;
  800712:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800713:	39 d0                	cmp    %edx,%eax
  800715:	74 06                	je     80071d <strnlen+0x1b>
  800717:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80071b:	75 f5                	jne    800712 <strnlen+0x10>
		n++;
	return n;
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800729:	ba 00 00 00 00       	mov    $0x0,%edx
  80072e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800731:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800734:	42                   	inc    %edx
  800735:	84 c9                	test   %cl,%cl
  800737:	75 f5                	jne    80072e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800739:	5b                   	pop    %ebx
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800746:	89 1c 24             	mov    %ebx,(%esp)
  800749:	e8 9e ff ff ff       	call   8006ec <strlen>
	strcpy(dst + len, src);
  80074e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800751:	89 54 24 04          	mov    %edx,0x4(%esp)
  800755:	01 d8                	add    %ebx,%eax
  800757:	89 04 24             	mov    %eax,(%esp)
  80075a:	e8 c0 ff ff ff       	call   80071f <strcpy>
	return dst;
}
  80075f:	89 d8                	mov    %ebx,%eax
  800761:	83 c4 08             	add    $0x8,%esp
  800764:	5b                   	pop    %ebx
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800772:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800775:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077a:	eb 0c                	jmp    800788 <strncpy+0x21>
		*dst++ = *src;
  80077c:	8a 1a                	mov    (%edx),%bl
  80077e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800781:	80 3a 01             	cmpb   $0x1,(%edx)
  800784:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800787:	41                   	inc    %ecx
  800788:	39 f1                	cmp    %esi,%ecx
  80078a:	75 f0                	jne    80077c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078c:	5b                   	pop    %ebx
  80078d:	5e                   	pop    %esi
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	56                   	push   %esi
  800794:	53                   	push   %ebx
  800795:	8b 75 08             	mov    0x8(%ebp),%esi
  800798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	75 0a                	jne    8007ac <strlcpy+0x1c>
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	eb 1a                	jmp    8007c0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a6:	88 18                	mov    %bl,(%eax)
  8007a8:	40                   	inc    %eax
  8007a9:	41                   	inc    %ecx
  8007aa:	eb 02                	jmp    8007ae <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ac:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ae:	4a                   	dec    %edx
  8007af:	74 0a                	je     8007bb <strlcpy+0x2b>
  8007b1:	8a 19                	mov    (%ecx),%bl
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 ef                	jne    8007a6 <strlcpy+0x16>
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	eb 02                	jmp    8007bd <strlcpy+0x2d>
  8007bb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007bd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007c0:	29 f0                	sub    %esi,%eax
}
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cf:	eb 02                	jmp    8007d3 <strcmp+0xd>
		p++, q++;
  8007d1:	41                   	inc    %ecx
  8007d2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d3:	8a 01                	mov    (%ecx),%al
  8007d5:	84 c0                	test   %al,%al
  8007d7:	74 04                	je     8007dd <strcmp+0x17>
  8007d9:	3a 02                	cmp    (%edx),%al
  8007db:	74 f4                	je     8007d1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007dd:	0f b6 c0             	movzbl %al,%eax
  8007e0:	0f b6 12             	movzbl (%edx),%edx
  8007e3:	29 d0                	sub    %edx,%eax
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007f4:	eb 03                	jmp    8007f9 <strncmp+0x12>
		n--, p++, q++;
  8007f6:	4a                   	dec    %edx
  8007f7:	40                   	inc    %eax
  8007f8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 14                	je     800811 <strncmp+0x2a>
  8007fd:	8a 18                	mov    (%eax),%bl
  8007ff:	84 db                	test   %bl,%bl
  800801:	74 04                	je     800807 <strncmp+0x20>
  800803:	3a 19                	cmp    (%ecx),%bl
  800805:	74 ef                	je     8007f6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800807:	0f b6 00             	movzbl (%eax),%eax
  80080a:	0f b6 11             	movzbl (%ecx),%edx
  80080d:	29 d0                	sub    %edx,%eax
  80080f:	eb 05                	jmp    800816 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800822:	eb 05                	jmp    800829 <strchr+0x10>
		if (*s == c)
  800824:	38 ca                	cmp    %cl,%dl
  800826:	74 0c                	je     800834 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800828:	40                   	inc    %eax
  800829:	8a 10                	mov    (%eax),%dl
  80082b:	84 d2                	test   %dl,%dl
  80082d:	75 f5                	jne    800824 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083f:	eb 05                	jmp    800846 <strfind+0x10>
		if (*s == c)
  800841:	38 ca                	cmp    %cl,%dl
  800843:	74 07                	je     80084c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800845:	40                   	inc    %eax
  800846:	8a 10                	mov    (%eax),%dl
  800848:	84 d2                	test   %dl,%dl
  80084a:	75 f5                	jne    800841 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	57                   	push   %edi
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 7d 08             	mov    0x8(%ebp),%edi
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80085d:	85 c9                	test   %ecx,%ecx
  80085f:	74 30                	je     800891 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800861:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800867:	75 25                	jne    80088e <memset+0x40>
  800869:	f6 c1 03             	test   $0x3,%cl
  80086c:	75 20                	jne    80088e <memset+0x40>
		c &= 0xFF;
  80086e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800871:	89 d3                	mov    %edx,%ebx
  800873:	c1 e3 08             	shl    $0x8,%ebx
  800876:	89 d6                	mov    %edx,%esi
  800878:	c1 e6 18             	shl    $0x18,%esi
  80087b:	89 d0                	mov    %edx,%eax
  80087d:	c1 e0 10             	shl    $0x10,%eax
  800880:	09 f0                	or     %esi,%eax
  800882:	09 d0                	or     %edx,%eax
  800884:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800886:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800889:	fc                   	cld    
  80088a:	f3 ab                	rep stos %eax,%es:(%edi)
  80088c:	eb 03                	jmp    800891 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088e:	fc                   	cld    
  80088f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800891:	89 f8                	mov    %edi,%eax
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5f                   	pop    %edi
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a6:	39 c6                	cmp    %eax,%esi
  8008a8:	73 34                	jae    8008de <memmove+0x46>
  8008aa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ad:	39 d0                	cmp    %edx,%eax
  8008af:	73 2d                	jae    8008de <memmove+0x46>
		s += n;
		d += n;
  8008b1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b4:	f6 c2 03             	test   $0x3,%dl
  8008b7:	75 1b                	jne    8008d4 <memmove+0x3c>
  8008b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bf:	75 13                	jne    8008d4 <memmove+0x3c>
  8008c1:	f6 c1 03             	test   $0x3,%cl
  8008c4:	75 0e                	jne    8008d4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008c6:	83 ef 04             	sub    $0x4,%edi
  8008c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008cc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008cf:	fd                   	std    
  8008d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d2:	eb 07                	jmp    8008db <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008d4:	4f                   	dec    %edi
  8008d5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d8:	fd                   	std    
  8008d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008db:	fc                   	cld    
  8008dc:	eb 20                	jmp    8008fe <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008de:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e4:	75 13                	jne    8008f9 <memmove+0x61>
  8008e6:	a8 03                	test   $0x3,%al
  8008e8:	75 0f                	jne    8008f9 <memmove+0x61>
  8008ea:	f6 c1 03             	test   $0x3,%cl
  8008ed:	75 0a                	jne    8008f9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008ef:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008f2:	89 c7                	mov    %eax,%edi
  8008f4:	fc                   	cld    
  8008f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f7:	eb 05                	jmp    8008fe <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f9:	89 c7                	mov    %eax,%edi
  8008fb:	fc                   	cld    
  8008fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fe:	5e                   	pop    %esi
  8008ff:	5f                   	pop    %edi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800908:	8b 45 10             	mov    0x10(%ebp),%eax
  80090b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800912:	89 44 24 04          	mov    %eax,0x4(%esp)
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	89 04 24             	mov    %eax,(%esp)
  80091c:	e8 77 ff ff ff       	call   800898 <memmove>
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800932:	ba 00 00 00 00       	mov    $0x0,%edx
  800937:	eb 16                	jmp    80094f <memcmp+0x2c>
		if (*s1 != *s2)
  800939:	8a 04 17             	mov    (%edi,%edx,1),%al
  80093c:	42                   	inc    %edx
  80093d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800941:	38 c8                	cmp    %cl,%al
  800943:	74 0a                	je     80094f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800945:	0f b6 c0             	movzbl %al,%eax
  800948:	0f b6 c9             	movzbl %cl,%ecx
  80094b:	29 c8                	sub    %ecx,%eax
  80094d:	eb 09                	jmp    800958 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094f:	39 da                	cmp    %ebx,%edx
  800951:	75 e6                	jne    800939 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5f                   	pop    %edi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800966:	89 c2                	mov    %eax,%edx
  800968:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80096b:	eb 05                	jmp    800972 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096d:	38 08                	cmp    %cl,(%eax)
  80096f:	74 05                	je     800976 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800971:	40                   	inc    %eax
  800972:	39 d0                	cmp    %edx,%eax
  800974:	72 f7                	jb     80096d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	57                   	push   %edi
  80097c:	56                   	push   %esi
  80097d:	53                   	push   %ebx
  80097e:	8b 55 08             	mov    0x8(%ebp),%edx
  800981:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800984:	eb 01                	jmp    800987 <strtol+0xf>
		s++;
  800986:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800987:	8a 02                	mov    (%edx),%al
  800989:	3c 20                	cmp    $0x20,%al
  80098b:	74 f9                	je     800986 <strtol+0xe>
  80098d:	3c 09                	cmp    $0x9,%al
  80098f:	74 f5                	je     800986 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800991:	3c 2b                	cmp    $0x2b,%al
  800993:	75 08                	jne    80099d <strtol+0x25>
		s++;
  800995:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800996:	bf 00 00 00 00       	mov    $0x0,%edi
  80099b:	eb 13                	jmp    8009b0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80099d:	3c 2d                	cmp    $0x2d,%al
  80099f:	75 0a                	jne    8009ab <strtol+0x33>
		s++, neg = 1;
  8009a1:	8d 52 01             	lea    0x1(%edx),%edx
  8009a4:	bf 01 00 00 00       	mov    $0x1,%edi
  8009a9:	eb 05                	jmp    8009b0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b0:	85 db                	test   %ebx,%ebx
  8009b2:	74 05                	je     8009b9 <strtol+0x41>
  8009b4:	83 fb 10             	cmp    $0x10,%ebx
  8009b7:	75 28                	jne    8009e1 <strtol+0x69>
  8009b9:	8a 02                	mov    (%edx),%al
  8009bb:	3c 30                	cmp    $0x30,%al
  8009bd:	75 10                	jne    8009cf <strtol+0x57>
  8009bf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009c3:	75 0a                	jne    8009cf <strtol+0x57>
		s += 2, base = 16;
  8009c5:	83 c2 02             	add    $0x2,%edx
  8009c8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009cd:	eb 12                	jmp    8009e1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009cf:	85 db                	test   %ebx,%ebx
  8009d1:	75 0e                	jne    8009e1 <strtol+0x69>
  8009d3:	3c 30                	cmp    $0x30,%al
  8009d5:	75 05                	jne    8009dc <strtol+0x64>
		s++, base = 8;
  8009d7:	42                   	inc    %edx
  8009d8:	b3 08                	mov    $0x8,%bl
  8009da:	eb 05                	jmp    8009e1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009dc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e8:	8a 0a                	mov    (%edx),%cl
  8009ea:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009ed:	80 fb 09             	cmp    $0x9,%bl
  8009f0:	77 08                	ja     8009fa <strtol+0x82>
			dig = *s - '0';
  8009f2:	0f be c9             	movsbl %cl,%ecx
  8009f5:	83 e9 30             	sub    $0x30,%ecx
  8009f8:	eb 1e                	jmp    800a18 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009fa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009fd:	80 fb 19             	cmp    $0x19,%bl
  800a00:	77 08                	ja     800a0a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a02:	0f be c9             	movsbl %cl,%ecx
  800a05:	83 e9 57             	sub    $0x57,%ecx
  800a08:	eb 0e                	jmp    800a18 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a0a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a0d:	80 fb 19             	cmp    $0x19,%bl
  800a10:	77 12                	ja     800a24 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a12:	0f be c9             	movsbl %cl,%ecx
  800a15:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a18:	39 f1                	cmp    %esi,%ecx
  800a1a:	7d 0c                	jge    800a28 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a1c:	42                   	inc    %edx
  800a1d:	0f af c6             	imul   %esi,%eax
  800a20:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a22:	eb c4                	jmp    8009e8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a24:	89 c1                	mov    %eax,%ecx
  800a26:	eb 02                	jmp    800a2a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a28:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2e:	74 05                	je     800a35 <strtol+0xbd>
		*endptr = (char *) s;
  800a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a33:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a35:	85 ff                	test   %edi,%edi
  800a37:	74 04                	je     800a3d <strtol+0xc5>
  800a39:	89 c8                	mov    %ecx,%eax
  800a3b:	f7 d8                	neg    %eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    
	...

00800a44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a52:	8b 55 08             	mov    0x8(%ebp),%edx
  800a55:	89 c3                	mov    %eax,%ebx
  800a57:	89 c7                	mov    %eax,%edi
  800a59:	89 c6                	mov    %eax,%esi
  800a5b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a72:	89 d1                	mov    %edx,%ecx
  800a74:	89 d3                	mov    %edx,%ebx
  800a76:	89 d7                	mov    %edx,%edi
  800a78:	89 d6                	mov    %edx,%esi
  800a7a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a94:	8b 55 08             	mov    0x8(%ebp),%edx
  800a97:	89 cb                	mov    %ecx,%ebx
  800a99:	89 cf                	mov    %ecx,%edi
  800a9b:	89 ce                	mov    %ecx,%esi
  800a9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	7e 28                	jle    800acb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aa7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aae:	00 
  800aaf:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800ab6:	00 
  800ab7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800abe:	00 
  800abf:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800ac6:	e8 b5 15 00 00       	call   802080 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acb:	83 c4 2c             	add    $0x2c,%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ade:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae3:	89 d1                	mov    %edx,%ecx
  800ae5:	89 d3                	mov    %edx,%ebx
  800ae7:	89 d7                	mov    %edx,%edi
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_yield>:

void
sys_yield(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	be 00 00 00 00       	mov    $0x0,%esi
  800b1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	89 f7                	mov    %esi,%edi
  800b2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	7e 28                	jle    800b5d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b39:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b40:	00 
  800b41:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800b48:	00 
  800b49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b50:	00 
  800b51:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800b58:	e8 23 15 00 00       	call   802080 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5d:	83 c4 2c             	add    $0x2c,%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b73:	8b 75 18             	mov    0x18(%ebp),%esi
  800b76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7e 28                	jle    800bb0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b8c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b93:	00 
  800b94:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800b9b:	00 
  800b9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba3:	00 
  800ba4:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800bab:	e8 d0 14 00 00       	call   802080 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb0:	83 c4 2c             	add    $0x2c,%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	89 df                	mov    %ebx,%edi
  800bd3:	89 de                	mov    %ebx,%esi
  800bd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 28                	jle    800c03 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800be6:	00 
  800be7:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800bee:	00 
  800bef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf6:	00 
  800bf7:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800bfe:	e8 7d 14 00 00       	call   802080 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c03:	83 c4 2c             	add    $0x2c,%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c19:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	89 df                	mov    %ebx,%edi
  800c26:	89 de                	mov    %ebx,%esi
  800c28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 28                	jle    800c56 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c32:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c39:	00 
  800c3a:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800c41:	00 
  800c42:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c49:	00 
  800c4a:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800c51:	e8 2a 14 00 00       	call   802080 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c56:	83 c4 2c             	add    $0x2c,%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 df                	mov    %ebx,%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 28                	jle    800ca9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c85:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c8c:	00 
  800c8d:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800c94:	00 
  800c95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9c:	00 
  800c9d:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800ca4:	e8 d7 13 00 00       	call   802080 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca9:	83 c4 2c             	add    $0x2c,%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	89 df                	mov    %ebx,%edi
  800ccc:	89 de                	mov    %ebx,%esi
  800cce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7e 28                	jle    800cfc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800ce7:	00 
  800ce8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cef:	00 
  800cf0:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800cf7:	e8 84 13 00 00       	call   802080 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfc:	83 c4 2c             	add    $0x2c,%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	be 00 00 00 00       	mov    $0x0,%esi
  800d0f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d35:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 cb                	mov    %ecx,%ebx
  800d3f:	89 cf                	mov    %ecx,%edi
  800d41:	89 ce                	mov    %ecx,%esi
  800d43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 28                	jle    800d71 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d54:	00 
  800d55:	c7 44 24 08 e3 27 80 	movl   $0x8027e3,0x8(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d64:	00 
  800d65:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  800d6c:	e8 0f 13 00 00       	call   802080 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d71:	83 c4 2c             	add    $0x2c,%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d84:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d89:	89 d1                	mov    %edx,%ecx
  800d8b:	89 d3                	mov    %edx,%ebx
  800d8d:	89 d7                	mov    %edx,%edi
  800d8f:	89 d6                	mov    %edx,%esi
  800d91:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	89 df                	mov    %ebx,%edi
  800db0:	89 de                	mov    %ebx,%esi
  800db2:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	b8 10 00 00 00       	mov    $0x10,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    
	...

00800ddc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	05 00 00 00 30       	add    $0x30000000,%eax
  800de7:	c1 e8 0c             	shr    $0xc,%eax
}
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
  800df5:	89 04 24             	mov    %eax,(%esp)
  800df8:	e8 df ff ff ff       	call   800ddc <fd2num>
  800dfd:	c1 e0 0c             	shl    $0xc,%eax
  800e00:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e05:	c9                   	leave  
  800e06:	c3                   	ret    

00800e07 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	53                   	push   %ebx
  800e0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e0e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e13:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e15:	89 c2                	mov    %eax,%edx
  800e17:	c1 ea 16             	shr    $0x16,%edx
  800e1a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e21:	f6 c2 01             	test   $0x1,%dl
  800e24:	74 11                	je     800e37 <fd_alloc+0x30>
  800e26:	89 c2                	mov    %eax,%edx
  800e28:	c1 ea 0c             	shr    $0xc,%edx
  800e2b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e32:	f6 c2 01             	test   $0x1,%dl
  800e35:	75 09                	jne    800e40 <fd_alloc+0x39>
			*fd_store = fd;
  800e37:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3e:	eb 17                	jmp    800e57 <fd_alloc+0x50>
  800e40:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e45:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e4a:	75 c7                	jne    800e13 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e52:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e57:	5b                   	pop    %ebx
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e60:	83 f8 1f             	cmp    $0x1f,%eax
  800e63:	77 36                	ja     800e9b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e65:	c1 e0 0c             	shl    $0xc,%eax
  800e68:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e6d:	89 c2                	mov    %eax,%edx
  800e6f:	c1 ea 16             	shr    $0x16,%edx
  800e72:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e79:	f6 c2 01             	test   $0x1,%dl
  800e7c:	74 24                	je     800ea2 <fd_lookup+0x48>
  800e7e:	89 c2                	mov    %eax,%edx
  800e80:	c1 ea 0c             	shr    $0xc,%edx
  800e83:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8a:	f6 c2 01             	test   $0x1,%dl
  800e8d:	74 1a                	je     800ea9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e92:	89 02                	mov    %eax,(%edx)
	return 0;
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
  800e99:	eb 13                	jmp    800eae <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea0:	eb 0c                	jmp    800eae <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea7:	eb 05                	jmp    800eae <fd_lookup+0x54>
  800ea9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 14             	sub    $0x14,%esp
  800eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800ebd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec2:	eb 0e                	jmp    800ed2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800ec4:	39 08                	cmp    %ecx,(%eax)
  800ec6:	75 09                	jne    800ed1 <dev_lookup+0x21>
			*dev = devtab[i];
  800ec8:	89 03                	mov    %eax,(%ebx)
			return 0;
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecf:	eb 33                	jmp    800f04 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed1:	42                   	inc    %edx
  800ed2:	8b 04 95 8c 28 80 00 	mov    0x80288c(,%edx,4),%eax
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	75 e7                	jne    800ec4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800edd:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800ee2:	8b 40 48             	mov    0x48(%eax),%eax
  800ee5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eed:	c7 04 24 10 28 80 00 	movl   $0x802810,(%esp)
  800ef4:	e8 7b f2 ff ff       	call   800174 <cprintf>
	*dev = 0;
  800ef9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800eff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f04:	83 c4 14             	add    $0x14,%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 30             	sub    $0x30,%esp
  800f12:	8b 75 08             	mov    0x8(%ebp),%esi
  800f15:	8a 45 0c             	mov    0xc(%ebp),%al
  800f18:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1b:	89 34 24             	mov    %esi,(%esp)
  800f1e:	e8 b9 fe ff ff       	call   800ddc <fd2num>
  800f23:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f26:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f2a:	89 04 24             	mov    %eax,(%esp)
  800f2d:	e8 28 ff ff ff       	call   800e5a <fd_lookup>
  800f32:	89 c3                	mov    %eax,%ebx
  800f34:	85 c0                	test   %eax,%eax
  800f36:	78 05                	js     800f3d <fd_close+0x33>
	    || fd != fd2)
  800f38:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f3b:	74 0d                	je     800f4a <fd_close+0x40>
		return (must_exist ? r : 0);
  800f3d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f41:	75 46                	jne    800f89 <fd_close+0x7f>
  800f43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f48:	eb 3f                	jmp    800f89 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f51:	8b 06                	mov    (%esi),%eax
  800f53:	89 04 24             	mov    %eax,(%esp)
  800f56:	e8 55 ff ff ff       	call   800eb0 <dev_lookup>
  800f5b:	89 c3                	mov    %eax,%ebx
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 18                	js     800f79 <fd_close+0x6f>
		if (dev->dev_close)
  800f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f64:	8b 40 10             	mov    0x10(%eax),%eax
  800f67:	85 c0                	test   %eax,%eax
  800f69:	74 09                	je     800f74 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f6b:	89 34 24             	mov    %esi,(%esp)
  800f6e:	ff d0                	call   *%eax
  800f70:	89 c3                	mov    %eax,%ebx
  800f72:	eb 05                	jmp    800f79 <fd_close+0x6f>
		else
			r = 0;
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f79:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f84:	e8 2f fc ff ff       	call   800bb8 <sys_page_unmap>
	return r;
}
  800f89:	89 d8                	mov    %ebx,%eax
  800f8b:	83 c4 30             	add    $0x30,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa2:	89 04 24             	mov    %eax,(%esp)
  800fa5:	e8 b0 fe ff ff       	call   800e5a <fd_lookup>
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 13                	js     800fc1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800fae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fb5:	00 
  800fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb9:	89 04 24             	mov    %eax,(%esp)
  800fbc:	e8 49 ff ff ff       	call   800f0a <fd_close>
}
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <close_all>:

void
close_all(void)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	53                   	push   %ebx
  800fc7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fcf:	89 1c 24             	mov    %ebx,(%esp)
  800fd2:	e8 bb ff ff ff       	call   800f92 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd7:	43                   	inc    %ebx
  800fd8:	83 fb 20             	cmp    $0x20,%ebx
  800fdb:	75 f2                	jne    800fcf <close_all+0xc>
		close(i);
}
  800fdd:	83 c4 14             	add    $0x14,%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 4c             	sub    $0x4c,%esp
  800fec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff9:	89 04 24             	mov    %eax,(%esp)
  800ffc:	e8 59 fe ff ff       	call   800e5a <fd_lookup>
  801001:	89 c3                	mov    %eax,%ebx
  801003:	85 c0                	test   %eax,%eax
  801005:	0f 88 e3 00 00 00    	js     8010ee <dup+0x10b>
		return r;
	close(newfdnum);
  80100b:	89 3c 24             	mov    %edi,(%esp)
  80100e:	e8 7f ff ff ff       	call   800f92 <close>

	newfd = INDEX2FD(newfdnum);
  801013:	89 fe                	mov    %edi,%esi
  801015:	c1 e6 0c             	shl    $0xc,%esi
  801018:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80101e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801021:	89 04 24             	mov    %eax,(%esp)
  801024:	e8 c3 fd ff ff       	call   800dec <fd2data>
  801029:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80102b:	89 34 24             	mov    %esi,(%esp)
  80102e:	e8 b9 fd ff ff       	call   800dec <fd2data>
  801033:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801036:	89 d8                	mov    %ebx,%eax
  801038:	c1 e8 16             	shr    $0x16,%eax
  80103b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801042:	a8 01                	test   $0x1,%al
  801044:	74 46                	je     80108c <dup+0xa9>
  801046:	89 d8                	mov    %ebx,%eax
  801048:	c1 e8 0c             	shr    $0xc,%eax
  80104b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801052:	f6 c2 01             	test   $0x1,%dl
  801055:	74 35                	je     80108c <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801057:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105e:	25 07 0e 00 00       	and    $0xe07,%eax
  801063:	89 44 24 10          	mov    %eax,0x10(%esp)
  801067:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80106a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80106e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801075:	00 
  801076:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80107a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801081:	e8 df fa ff ff       	call   800b65 <sys_page_map>
  801086:	89 c3                	mov    %eax,%ebx
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 3b                	js     8010c7 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80108f:	89 c2                	mov    %eax,%edx
  801091:	c1 ea 0c             	shr    $0xc,%edx
  801094:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b0:	00 
  8010b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010bc:	e8 a4 fa ff ff       	call   800b65 <sys_page_map>
  8010c1:	89 c3                	mov    %eax,%ebx
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	79 25                	jns    8010ec <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d2:	e8 e1 fa ff ff       	call   800bb8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e5:	e8 ce fa ff ff       	call   800bb8 <sys_page_unmap>
	return r;
  8010ea:	eb 02                	jmp    8010ee <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010ec:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010ee:	89 d8                	mov    %ebx,%eax
  8010f0:	83 c4 4c             	add    $0x4c,%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 24             	sub    $0x24,%esp
  8010ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801102:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801105:	89 44 24 04          	mov    %eax,0x4(%esp)
  801109:	89 1c 24             	mov    %ebx,(%esp)
  80110c:	e8 49 fd ff ff       	call   800e5a <fd_lookup>
  801111:	85 c0                	test   %eax,%eax
  801113:	78 6d                	js     801182 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801115:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801118:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111f:	8b 00                	mov    (%eax),%eax
  801121:	89 04 24             	mov    %eax,(%esp)
  801124:	e8 87 fd ff ff       	call   800eb0 <dev_lookup>
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 55                	js     801182 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80112d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801130:	8b 50 08             	mov    0x8(%eax),%edx
  801133:	83 e2 03             	and    $0x3,%edx
  801136:	83 fa 01             	cmp    $0x1,%edx
  801139:	75 23                	jne    80115e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80113b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801140:	8b 40 48             	mov    0x48(%eax),%eax
  801143:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114b:	c7 04 24 51 28 80 00 	movl   $0x802851,(%esp)
  801152:	e8 1d f0 ff ff       	call   800174 <cprintf>
		return -E_INVAL;
  801157:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115c:	eb 24                	jmp    801182 <read+0x8a>
	}
	if (!dev->dev_read)
  80115e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801161:	8b 52 08             	mov    0x8(%edx),%edx
  801164:	85 d2                	test   %edx,%edx
  801166:	74 15                	je     80117d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801168:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80116b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80116f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801172:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801176:	89 04 24             	mov    %eax,(%esp)
  801179:	ff d2                	call   *%edx
  80117b:	eb 05                	jmp    801182 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80117d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801182:	83 c4 24             	add    $0x24,%esp
  801185:	5b                   	pop    %ebx
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	57                   	push   %edi
  80118c:	56                   	push   %esi
  80118d:	53                   	push   %ebx
  80118e:	83 ec 1c             	sub    $0x1c,%esp
  801191:	8b 7d 08             	mov    0x8(%ebp),%edi
  801194:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119c:	eb 23                	jmp    8011c1 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80119e:	89 f0                	mov    %esi,%eax
  8011a0:	29 d8                	sub    %ebx,%eax
  8011a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a9:	01 d8                	add    %ebx,%eax
  8011ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011af:	89 3c 24             	mov    %edi,(%esp)
  8011b2:	e8 41 ff ff ff       	call   8010f8 <read>
		if (m < 0)
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 10                	js     8011cb <readn+0x43>
			return m;
		if (m == 0)
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	74 0a                	je     8011c9 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011bf:	01 c3                	add    %eax,%ebx
  8011c1:	39 f3                	cmp    %esi,%ebx
  8011c3:	72 d9                	jb     80119e <readn+0x16>
  8011c5:	89 d8                	mov    %ebx,%eax
  8011c7:	eb 02                	jmp    8011cb <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011c9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011cb:	83 c4 1c             	add    $0x1c,%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5f                   	pop    %edi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 24             	sub    $0x24,%esp
  8011da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e4:	89 1c 24             	mov    %ebx,(%esp)
  8011e7:	e8 6e fc ff ff       	call   800e5a <fd_lookup>
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 68                	js     801258 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fa:	8b 00                	mov    (%eax),%eax
  8011fc:	89 04 24             	mov    %eax,(%esp)
  8011ff:	e8 ac fc ff ff       	call   800eb0 <dev_lookup>
  801204:	85 c0                	test   %eax,%eax
  801206:	78 50                	js     801258 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120f:	75 23                	jne    801234 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801211:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801216:	8b 40 48             	mov    0x48(%eax),%eax
  801219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80121d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801221:	c7 04 24 6d 28 80 00 	movl   $0x80286d,(%esp)
  801228:	e8 47 ef ff ff       	call   800174 <cprintf>
		return -E_INVAL;
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801232:	eb 24                	jmp    801258 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801234:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801237:	8b 52 0c             	mov    0xc(%edx),%edx
  80123a:	85 d2                	test   %edx,%edx
  80123c:	74 15                	je     801253 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80123e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801241:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801248:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80124c:	89 04 24             	mov    %eax,(%esp)
  80124f:	ff d2                	call   *%edx
  801251:	eb 05                	jmp    801258 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801253:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801258:	83 c4 24             	add    $0x24,%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    

0080125e <seek>:

int
seek(int fdnum, off_t offset)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801264:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
  80126e:	89 04 24             	mov    %eax,(%esp)
  801271:	e8 e4 fb ff ff       	call   800e5a <fd_lookup>
  801276:	85 c0                	test   %eax,%eax
  801278:	78 0e                	js     801288 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80127a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80127d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801280:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	53                   	push   %ebx
  80128e:	83 ec 24             	sub    $0x24,%esp
  801291:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801294:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129b:	89 1c 24             	mov    %ebx,(%esp)
  80129e:	e8 b7 fb ff ff       	call   800e5a <fd_lookup>
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 61                	js     801308 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b1:	8b 00                	mov    (%eax),%eax
  8012b3:	89 04 24             	mov    %eax,(%esp)
  8012b6:	e8 f5 fb ff ff       	call   800eb0 <dev_lookup>
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 49                	js     801308 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c6:	75 23                	jne    8012eb <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012c8:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012cd:	8b 40 48             	mov    0x48(%eax),%eax
  8012d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d8:	c7 04 24 30 28 80 00 	movl   $0x802830,(%esp)
  8012df:	e8 90 ee ff ff       	call   800174 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e9:	eb 1d                	jmp    801308 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8012eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ee:	8b 52 18             	mov    0x18(%edx),%edx
  8012f1:	85 d2                	test   %edx,%edx
  8012f3:	74 0e                	je     801303 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012fc:	89 04 24             	mov    %eax,(%esp)
  8012ff:	ff d2                	call   *%edx
  801301:	eb 05                	jmp    801308 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801303:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801308:	83 c4 24             	add    $0x24,%esp
  80130b:	5b                   	pop    %ebx
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	53                   	push   %ebx
  801312:	83 ec 24             	sub    $0x24,%esp
  801315:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801318:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131f:	8b 45 08             	mov    0x8(%ebp),%eax
  801322:	89 04 24             	mov    %eax,(%esp)
  801325:	e8 30 fb ff ff       	call   800e5a <fd_lookup>
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 52                	js     801380 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801331:	89 44 24 04          	mov    %eax,0x4(%esp)
  801335:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801338:	8b 00                	mov    (%eax),%eax
  80133a:	89 04 24             	mov    %eax,(%esp)
  80133d:	e8 6e fb ff ff       	call   800eb0 <dev_lookup>
  801342:	85 c0                	test   %eax,%eax
  801344:	78 3a                	js     801380 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801346:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801349:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80134d:	74 2c                	je     80137b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80134f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801352:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801359:	00 00 00 
	stat->st_isdir = 0;
  80135c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801363:	00 00 00 
	stat->st_dev = dev;
  801366:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80136c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801370:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801373:	89 14 24             	mov    %edx,(%esp)
  801376:	ff 50 14             	call   *0x14(%eax)
  801379:	eb 05                	jmp    801380 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80137b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801380:	83 c4 24             	add    $0x24,%esp
  801383:	5b                   	pop    %ebx
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	56                   	push   %esi
  80138a:	53                   	push   %ebx
  80138b:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80138e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801395:	00 
  801396:	8b 45 08             	mov    0x8(%ebp),%eax
  801399:	89 04 24             	mov    %eax,(%esp)
  80139c:	e8 2a 02 00 00       	call   8015cb <open>
  8013a1:	89 c3                	mov    %eax,%ebx
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 1b                	js     8013c2 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ae:	89 1c 24             	mov    %ebx,(%esp)
  8013b1:	e8 58 ff ff ff       	call   80130e <fstat>
  8013b6:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b8:	89 1c 24             	mov    %ebx,(%esp)
  8013bb:	e8 d2 fb ff ff       	call   800f92 <close>
	return r;
  8013c0:	89 f3                	mov    %esi,%ebx
}
  8013c2:	89 d8                	mov    %ebx,%eax
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    
	...

008013cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 10             	sub    $0x10,%esp
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013d8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013df:	75 11                	jne    8013f2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8013e8:	e8 de 0d 00 00       	call   8021cb <ipc_find_env>
  8013ed:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013f9:	00 
  8013fa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801401:	00 
  801402:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801406:	a1 00 40 80 00       	mov    0x804000,%eax
  80140b:	89 04 24             	mov    %eax,(%esp)
  80140e:	e8 35 0d 00 00       	call   802148 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801413:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80141a:	00 
  80141b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80141f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801426:	e8 ad 0c 00 00       	call   8020d8 <ipc_recv>
}
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	5b                   	pop    %ebx
  80142f:	5e                   	pop    %esi
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801438:	8b 45 08             	mov    0x8(%ebp),%eax
  80143b:	8b 40 0c             	mov    0xc(%eax),%eax
  80143e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801443:	8b 45 0c             	mov    0xc(%ebp),%eax
  801446:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80144b:	ba 00 00 00 00       	mov    $0x0,%edx
  801450:	b8 02 00 00 00       	mov    $0x2,%eax
  801455:	e8 72 ff ff ff       	call   8013cc <fsipc>
}
  80145a:	c9                   	leave  
  80145b:	c3                   	ret    

0080145c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801462:	8b 45 08             	mov    0x8(%ebp),%eax
  801465:	8b 40 0c             	mov    0xc(%eax),%eax
  801468:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80146d:	ba 00 00 00 00       	mov    $0x0,%edx
  801472:	b8 06 00 00 00       	mov    $0x6,%eax
  801477:	e8 50 ff ff ff       	call   8013cc <fsipc>
}
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	53                   	push   %ebx
  801482:	83 ec 14             	sub    $0x14,%esp
  801485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801488:	8b 45 08             	mov    0x8(%ebp),%eax
  80148b:	8b 40 0c             	mov    0xc(%eax),%eax
  80148e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801493:	ba 00 00 00 00       	mov    $0x0,%edx
  801498:	b8 05 00 00 00       	mov    $0x5,%eax
  80149d:	e8 2a ff ff ff       	call   8013cc <fsipc>
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 2b                	js     8014d1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014ad:	00 
  8014ae:	89 1c 24             	mov    %ebx,(%esp)
  8014b1:	e8 69 f2 ff ff       	call   80071f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8014bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d1:	83 c4 14             	add    $0x14,%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    

008014d7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	83 ec 18             	sub    $0x18,%esp
  8014dd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014ec:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014f8:	76 05                	jbe    8014ff <devfile_write+0x28>
  8014fa:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8014ff:	89 54 24 08          	mov    %edx,0x8(%esp)
  801503:	8b 45 0c             	mov    0xc(%ebp),%eax
  801506:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150a:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801511:	e8 ec f3 ff ff       	call   800902 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801516:	ba 00 00 00 00       	mov    $0x0,%edx
  80151b:	b8 04 00 00 00       	mov    $0x4,%eax
  801520:	e8 a7 fe ff ff       	call   8013cc <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	56                   	push   %esi
  80152b:	53                   	push   %ebx
  80152c:	83 ec 10             	sub    $0x10,%esp
  80152f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801532:	8b 45 08             	mov    0x8(%ebp),%eax
  801535:	8b 40 0c             	mov    0xc(%eax),%eax
  801538:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80153d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801543:	ba 00 00 00 00       	mov    $0x0,%edx
  801548:	b8 03 00 00 00       	mov    $0x3,%eax
  80154d:	e8 7a fe ff ff       	call   8013cc <fsipc>
  801552:	89 c3                	mov    %eax,%ebx
  801554:	85 c0                	test   %eax,%eax
  801556:	78 6a                	js     8015c2 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801558:	39 c6                	cmp    %eax,%esi
  80155a:	73 24                	jae    801580 <devfile_read+0x59>
  80155c:	c7 44 24 0c a0 28 80 	movl   $0x8028a0,0xc(%esp)
  801563:	00 
  801564:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  80156b:	00 
  80156c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801573:	00 
  801574:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  80157b:	e8 00 0b 00 00       	call   802080 <_panic>
	assert(r <= PGSIZE);
  801580:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801585:	7e 24                	jle    8015ab <devfile_read+0x84>
  801587:	c7 44 24 0c c7 28 80 	movl   $0x8028c7,0xc(%esp)
  80158e:	00 
  80158f:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  801596:	00 
  801597:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80159e:	00 
  80159f:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  8015a6:	e8 d5 0a 00 00       	call   802080 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015af:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015b6:	00 
  8015b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ba:	89 04 24             	mov    %eax,(%esp)
  8015bd:	e8 d6 f2 ff ff       	call   800898 <memmove>
	return r;
}
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    

008015cb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 20             	sub    $0x20,%esp
  8015d3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d6:	89 34 24             	mov    %esi,(%esp)
  8015d9:	e8 0e f1 ff ff       	call   8006ec <strlen>
  8015de:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e3:	7f 60                	jg     801645 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e8:	89 04 24             	mov    %eax,(%esp)
  8015eb:	e8 17 f8 ff ff       	call   800e07 <fd_alloc>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 54                	js     80164a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015fa:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801601:	e8 19 f1 ff ff       	call   80071f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801606:	8b 45 0c             	mov    0xc(%ebp),%eax
  801609:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80160e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801611:	b8 01 00 00 00       	mov    $0x1,%eax
  801616:	e8 b1 fd ff ff       	call   8013cc <fsipc>
  80161b:	89 c3                	mov    %eax,%ebx
  80161d:	85 c0                	test   %eax,%eax
  80161f:	79 15                	jns    801636 <open+0x6b>
		fd_close(fd, 0);
  801621:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801628:	00 
  801629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162c:	89 04 24             	mov    %eax,(%esp)
  80162f:	e8 d6 f8 ff ff       	call   800f0a <fd_close>
		return r;
  801634:	eb 14                	jmp    80164a <open+0x7f>
	}

	return fd2num(fd);
  801636:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801639:	89 04 24             	mov    %eax,(%esp)
  80163c:	e8 9b f7 ff ff       	call   800ddc <fd2num>
  801641:	89 c3                	mov    %eax,%ebx
  801643:	eb 05                	jmp    80164a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801645:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80164a:	89 d8                	mov    %ebx,%eax
  80164c:	83 c4 20             	add    $0x20,%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801659:	ba 00 00 00 00       	mov    $0x0,%edx
  80165e:	b8 08 00 00 00       	mov    $0x8,%eax
  801663:	e8 64 fd ff ff       	call   8013cc <fsipc>
}
  801668:	c9                   	leave  
  801669:	c3                   	ret    
	...

0080166c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801672:	c7 44 24 04 d3 28 80 	movl   $0x8028d3,0x4(%esp)
  801679:	00 
  80167a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167d:	89 04 24             	mov    %eax,(%esp)
  801680:	e8 9a f0 ff ff       	call   80071f <strcpy>
	return 0;
}
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	53                   	push   %ebx
  801690:	83 ec 14             	sub    $0x14,%esp
  801693:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801696:	89 1c 24             	mov    %ebx,(%esp)
  801699:	e8 72 0b 00 00       	call   802210 <pageref>
  80169e:	83 f8 01             	cmp    $0x1,%eax
  8016a1:	75 0d                	jne    8016b0 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8016a3:	8b 43 0c             	mov    0xc(%ebx),%eax
  8016a6:	89 04 24             	mov    %eax,(%esp)
  8016a9:	e8 1f 03 00 00       	call   8019cd <nsipc_close>
  8016ae:	eb 05                	jmp    8016b5 <devsock_close+0x29>
	else
		return 0;
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b5:	83 c4 14             	add    $0x14,%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016c8:	00 
  8016c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	8b 40 0c             	mov    0xc(%eax),%eax
  8016dd:	89 04 24             	mov    %eax,(%esp)
  8016e0:	e8 e3 03 00 00       	call   801ac8 <nsipc_send>
}
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    

008016e7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016f4:	00 
  8016f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	8b 40 0c             	mov    0xc(%eax),%eax
  801709:	89 04 24             	mov    %eax,(%esp)
  80170c:	e8 37 03 00 00       	call   801a48 <nsipc_recv>
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	56                   	push   %esi
  801717:	53                   	push   %ebx
  801718:	83 ec 20             	sub    $0x20,%esp
  80171b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80171d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801720:	89 04 24             	mov    %eax,(%esp)
  801723:	e8 df f6 ff ff       	call   800e07 <fd_alloc>
  801728:	89 c3                	mov    %eax,%ebx
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 21                	js     80174f <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80172e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801735:	00 
  801736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801744:	e8 c8 f3 ff ff       	call   800b11 <sys_page_alloc>
  801749:	89 c3                	mov    %eax,%ebx
  80174b:	85 c0                	test   %eax,%eax
  80174d:	79 0a                	jns    801759 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80174f:	89 34 24             	mov    %esi,(%esp)
  801752:	e8 76 02 00 00       	call   8019cd <nsipc_close>
		return r;
  801757:	eb 22                	jmp    80177b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801759:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80175f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801762:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801767:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80176e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801771:	89 04 24             	mov    %eax,(%esp)
  801774:	e8 63 f6 ff ff       	call   800ddc <fd2num>
  801779:	89 c3                	mov    %eax,%ebx
}
  80177b:	89 d8                	mov    %ebx,%eax
  80177d:	83 c4 20             	add    $0x20,%esp
  801780:	5b                   	pop    %ebx
  801781:	5e                   	pop    %esi
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80178a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80178d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 c1 f6 ff ff       	call   800e5a <fd_lookup>
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 17                	js     8017b4 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80179d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a6:	39 10                	cmp    %edx,(%eax)
  8017a8:	75 05                	jne    8017af <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8017aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ad:	eb 05                	jmp    8017b4 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8017af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    

008017b6 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	e8 c0 ff ff ff       	call   801784 <fd2sockid>
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 1f                	js     8017e7 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017c8:	8b 55 10             	mov    0x10(%ebp),%edx
  8017cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017d6:	89 04 24             	mov    %eax,(%esp)
  8017d9:	e8 38 01 00 00       	call   801916 <nsipc_accept>
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 05                	js     8017e7 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8017e2:	e8 2c ff ff ff       	call   801713 <alloc_sockfd>
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f2:	e8 8d ff ff ff       	call   801784 <fd2sockid>
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 16                	js     801811 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8017fb:	8b 55 10             	mov    0x10(%ebp),%edx
  8017fe:	89 54 24 08          	mov    %edx,0x8(%esp)
  801802:	8b 55 0c             	mov    0xc(%ebp),%edx
  801805:	89 54 24 04          	mov    %edx,0x4(%esp)
  801809:	89 04 24             	mov    %eax,(%esp)
  80180c:	e8 5b 01 00 00       	call   80196c <nsipc_bind>
}
  801811:	c9                   	leave  
  801812:	c3                   	ret    

00801813 <shutdown>:

int
shutdown(int s, int how)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	e8 63 ff ff ff       	call   801784 <fd2sockid>
  801821:	85 c0                	test   %eax,%eax
  801823:	78 0f                	js     801834 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801825:	8b 55 0c             	mov    0xc(%ebp),%edx
  801828:	89 54 24 04          	mov    %edx,0x4(%esp)
  80182c:	89 04 24             	mov    %eax,(%esp)
  80182f:	e8 77 01 00 00       	call   8019ab <nsipc_shutdown>
}
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	e8 40 ff ff ff       	call   801784 <fd2sockid>
  801844:	85 c0                	test   %eax,%eax
  801846:	78 16                	js     80185e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801848:	8b 55 10             	mov    0x10(%ebp),%edx
  80184b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80184f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801852:	89 54 24 04          	mov    %edx,0x4(%esp)
  801856:	89 04 24             	mov    %eax,(%esp)
  801859:	e8 89 01 00 00       	call   8019e7 <nsipc_connect>
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <listen>:

int
listen(int s, int backlog)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	e8 16 ff ff ff       	call   801784 <fd2sockid>
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 0f                	js     801881 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801872:	8b 55 0c             	mov    0xc(%ebp),%edx
  801875:	89 54 24 04          	mov    %edx,0x4(%esp)
  801879:	89 04 24             	mov    %eax,(%esp)
  80187c:	e8 a5 01 00 00       	call   801a26 <nsipc_listen>
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801889:	8b 45 10             	mov    0x10(%ebp),%eax
  80188c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801890:	8b 45 0c             	mov    0xc(%ebp),%eax
  801893:	89 44 24 04          	mov    %eax,0x4(%esp)
  801897:	8b 45 08             	mov    0x8(%ebp),%eax
  80189a:	89 04 24             	mov    %eax,(%esp)
  80189d:	e8 99 02 00 00       	call   801b3b <nsipc_socket>
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 05                	js     8018ab <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8018a6:	e8 68 fe ff ff       	call   801713 <alloc_sockfd>
}
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    
  8018ad:	00 00                	add    %al,(%eax)
	...

008018b0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	53                   	push   %ebx
  8018b4:	83 ec 14             	sub    $0x14,%esp
  8018b7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018b9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018c0:	75 11                	jne    8018d3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8018c9:	e8 fd 08 00 00       	call   8021cb <ipc_find_env>
  8018ce:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018d3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018da:	00 
  8018db:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8018e2:	00 
  8018e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ec:	89 04 24             	mov    %eax,(%esp)
  8018ef:	e8 54 08 00 00       	call   802148 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018fb:	00 
  8018fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801903:	00 
  801904:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190b:	e8 c8 07 00 00       	call   8020d8 <ipc_recv>
}
  801910:	83 c4 14             	add    $0x14,%esp
  801913:	5b                   	pop    %ebx
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	83 ec 10             	sub    $0x10,%esp
  80191e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
  801924:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801929:	8b 06                	mov    (%esi),%eax
  80192b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801930:	b8 01 00 00 00       	mov    $0x1,%eax
  801935:	e8 76 ff ff ff       	call   8018b0 <nsipc>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 23                	js     801963 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801940:	a1 10 60 80 00       	mov    0x806010,%eax
  801945:	89 44 24 08          	mov    %eax,0x8(%esp)
  801949:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801950:	00 
  801951:	8b 45 0c             	mov    0xc(%ebp),%eax
  801954:	89 04 24             	mov    %eax,(%esp)
  801957:	e8 3c ef ff ff       	call   800898 <memmove>
		*addrlen = ret->ret_addrlen;
  80195c:	a1 10 60 80 00       	mov    0x806010,%eax
  801961:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801963:	89 d8                	mov    %ebx,%eax
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	53                   	push   %ebx
  801970:	83 ec 14             	sub    $0x14,%esp
  801973:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80197e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801982:	8b 45 0c             	mov    0xc(%ebp),%eax
  801985:	89 44 24 04          	mov    %eax,0x4(%esp)
  801989:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801990:	e8 03 ef ff ff       	call   800898 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801995:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80199b:	b8 02 00 00 00       	mov    $0x2,%eax
  8019a0:	e8 0b ff ff ff       	call   8018b0 <nsipc>
}
  8019a5:	83 c4 14             	add    $0x14,%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c6:	e8 e5 fe ff ff       	call   8018b0 <nsipc>
}
  8019cb:	c9                   	leave  
  8019cc:	c3                   	ret    

008019cd <nsipc_close>:

int
nsipc_close(int s)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d6:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019db:	b8 04 00 00 00       	mov    $0x4,%eax
  8019e0:	e8 cb fe ff ff       	call   8018b0 <nsipc>
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	53                   	push   %ebx
  8019eb:	83 ec 14             	sub    $0x14,%esp
  8019ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a04:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801a0b:	e8 88 ee ff ff       	call   800898 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a10:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a16:	b8 05 00 00 00       	mov    $0x5,%eax
  801a1b:	e8 90 fe ff ff       	call   8018b0 <nsipc>
}
  801a20:	83 c4 14             	add    $0x14,%esp
  801a23:	5b                   	pop    %ebx
  801a24:	5d                   	pop    %ebp
  801a25:	c3                   	ret    

00801a26 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a3c:	b8 06 00 00 00       	mov    $0x6,%eax
  801a41:	e8 6a fe ff ff       	call   8018b0 <nsipc>
}
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	83 ec 10             	sub    $0x10,%esp
  801a50:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a53:	8b 45 08             	mov    0x8(%ebp),%eax
  801a56:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a5b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a61:	8b 45 14             	mov    0x14(%ebp),%eax
  801a64:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a69:	b8 07 00 00 00       	mov    $0x7,%eax
  801a6e:	e8 3d fe ff ff       	call   8018b0 <nsipc>
  801a73:	89 c3                	mov    %eax,%ebx
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 46                	js     801abf <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801a79:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a7e:	7f 04                	jg     801a84 <nsipc_recv+0x3c>
  801a80:	39 c6                	cmp    %eax,%esi
  801a82:	7d 24                	jge    801aa8 <nsipc_recv+0x60>
  801a84:	c7 44 24 0c df 28 80 	movl   $0x8028df,0xc(%esp)
  801a8b:	00 
  801a8c:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  801a93:	00 
  801a94:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801a9b:	00 
  801a9c:	c7 04 24 f4 28 80 00 	movl   $0x8028f4,(%esp)
  801aa3:	e8 d8 05 00 00       	call   802080 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801aa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aac:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ab3:	00 
  801ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab7:	89 04 24             	mov    %eax,(%esp)
  801aba:	e8 d9 ed ff ff       	call   800898 <memmove>
	}

	return r;
}
  801abf:	89 d8                	mov    %ebx,%eax
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	53                   	push   %ebx
  801acc:	83 ec 14             	sub    $0x14,%esp
  801acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ada:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ae0:	7e 24                	jle    801b06 <nsipc_send+0x3e>
  801ae2:	c7 44 24 0c 00 29 80 	movl   $0x802900,0xc(%esp)
  801ae9:	00 
  801aea:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  801af1:	00 
  801af2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801af9:	00 
  801afa:	c7 04 24 f4 28 80 00 	movl   $0x8028f4,(%esp)
  801b01:	e8 7a 05 00 00       	call   802080 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b06:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b11:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801b18:	e8 7b ed ff ff       	call   800898 <memmove>
	nsipcbuf.send.req_size = size;
  801b1d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b23:	8b 45 14             	mov    0x14(%ebp),%eax
  801b26:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b2b:	b8 08 00 00 00       	mov    $0x8,%eax
  801b30:	e8 7b fd ff ff       	call   8018b0 <nsipc>
}
  801b35:	83 c4 14             	add    $0x14,%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b41:	8b 45 08             	mov    0x8(%ebp),%eax
  801b44:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4c:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b51:	8b 45 10             	mov    0x10(%ebp),%eax
  801b54:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b59:	b8 09 00 00 00       	mov    $0x9,%eax
  801b5e:	e8 4d fd ff ff       	call   8018b0 <nsipc>
}
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    
  801b65:	00 00                	add    %al,(%eax)
	...

00801b68 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 10             	sub    $0x10,%esp
  801b70:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b73:	8b 45 08             	mov    0x8(%ebp),%eax
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	e8 6e f2 ff ff       	call   800dec <fd2data>
  801b7e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b80:	c7 44 24 04 0c 29 80 	movl   $0x80290c,0x4(%esp)
  801b87:	00 
  801b88:	89 34 24             	mov    %esi,(%esp)
  801b8b:	e8 8f eb ff ff       	call   80071f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b90:	8b 43 04             	mov    0x4(%ebx),%eax
  801b93:	2b 03                	sub    (%ebx),%eax
  801b95:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b9b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801ba2:	00 00 00 
	stat->st_dev = &devpipe;
  801ba5:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801bac:	30 80 00 
	return 0;
}
  801baf:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	53                   	push   %ebx
  801bbf:	83 ec 14             	sub    $0x14,%esp
  801bc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd0:	e8 e3 ef ff ff       	call   800bb8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bd5:	89 1c 24             	mov    %ebx,(%esp)
  801bd8:	e8 0f f2 ff ff       	call   800dec <fd2data>
  801bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be8:	e8 cb ef ff ff       	call   800bb8 <sys_page_unmap>
}
  801bed:	83 c4 14             	add    $0x14,%esp
  801bf0:	5b                   	pop    %ebx
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	57                   	push   %edi
  801bf7:	56                   	push   %esi
  801bf8:	53                   	push   %ebx
  801bf9:	83 ec 2c             	sub    $0x2c,%esp
  801bfc:	89 c7                	mov    %eax,%edi
  801bfe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c01:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801c06:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c09:	89 3c 24             	mov    %edi,(%esp)
  801c0c:	e8 ff 05 00 00       	call   802210 <pageref>
  801c11:	89 c6                	mov    %eax,%esi
  801c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c16:	89 04 24             	mov    %eax,(%esp)
  801c19:	e8 f2 05 00 00       	call   802210 <pageref>
  801c1e:	39 c6                	cmp    %eax,%esi
  801c20:	0f 94 c0             	sete   %al
  801c23:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c26:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801c2c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c2f:	39 cb                	cmp    %ecx,%ebx
  801c31:	75 08                	jne    801c3b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c33:	83 c4 2c             	add    $0x2c,%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c3b:	83 f8 01             	cmp    $0x1,%eax
  801c3e:	75 c1                	jne    801c01 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c40:	8b 42 58             	mov    0x58(%edx),%eax
  801c43:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c4a:	00 
  801c4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c53:	c7 04 24 13 29 80 00 	movl   $0x802913,(%esp)
  801c5a:	e8 15 e5 ff ff       	call   800174 <cprintf>
  801c5f:	eb a0                	jmp    801c01 <_pipeisclosed+0xe>

00801c61 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	57                   	push   %edi
  801c65:	56                   	push   %esi
  801c66:	53                   	push   %ebx
  801c67:	83 ec 1c             	sub    $0x1c,%esp
  801c6a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c6d:	89 34 24             	mov    %esi,(%esp)
  801c70:	e8 77 f1 ff ff       	call   800dec <fd2data>
  801c75:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c77:	bf 00 00 00 00       	mov    $0x0,%edi
  801c7c:	eb 3c                	jmp    801cba <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c7e:	89 da                	mov    %ebx,%edx
  801c80:	89 f0                	mov    %esi,%eax
  801c82:	e8 6c ff ff ff       	call   801bf3 <_pipeisclosed>
  801c87:	85 c0                	test   %eax,%eax
  801c89:	75 38                	jne    801cc3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c8b:	e8 62 ee ff ff       	call   800af2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c90:	8b 43 04             	mov    0x4(%ebx),%eax
  801c93:	8b 13                	mov    (%ebx),%edx
  801c95:	83 c2 20             	add    $0x20,%edx
  801c98:	39 d0                	cmp    %edx,%eax
  801c9a:	73 e2                	jae    801c7e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801ca2:	89 c2                	mov    %eax,%edx
  801ca4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801caa:	79 05                	jns    801cb1 <devpipe_write+0x50>
  801cac:	4a                   	dec    %edx
  801cad:	83 ca e0             	or     $0xffffffe0,%edx
  801cb0:	42                   	inc    %edx
  801cb1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cb5:	40                   	inc    %eax
  801cb6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb9:	47                   	inc    %edi
  801cba:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cbd:	75 d1                	jne    801c90 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	eb 05                	jmp    801cc8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cc8:	83 c4 1c             	add    $0x1c,%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5f                   	pop    %edi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	57                   	push   %edi
  801cd4:	56                   	push   %esi
  801cd5:	53                   	push   %ebx
  801cd6:	83 ec 1c             	sub    $0x1c,%esp
  801cd9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cdc:	89 3c 24             	mov    %edi,(%esp)
  801cdf:	e8 08 f1 ff ff       	call   800dec <fd2data>
  801ce4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce6:	be 00 00 00 00       	mov    $0x0,%esi
  801ceb:	eb 3a                	jmp    801d27 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ced:	85 f6                	test   %esi,%esi
  801cef:	74 04                	je     801cf5 <devpipe_read+0x25>
				return i;
  801cf1:	89 f0                	mov    %esi,%eax
  801cf3:	eb 40                	jmp    801d35 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cf5:	89 da                	mov    %ebx,%edx
  801cf7:	89 f8                	mov    %edi,%eax
  801cf9:	e8 f5 fe ff ff       	call   801bf3 <_pipeisclosed>
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	75 2e                	jne    801d30 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d02:	e8 eb ed ff ff       	call   800af2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d07:	8b 03                	mov    (%ebx),%eax
  801d09:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d0c:	74 df                	je     801ced <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d0e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d13:	79 05                	jns    801d1a <devpipe_read+0x4a>
  801d15:	48                   	dec    %eax
  801d16:	83 c8 e0             	or     $0xffffffe0,%eax
  801d19:	40                   	inc    %eax
  801d1a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d21:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d24:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d26:	46                   	inc    %esi
  801d27:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d2a:	75 db                	jne    801d07 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d2c:	89 f0                	mov    %esi,%eax
  801d2e:	eb 05                	jmp    801d35 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d30:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d35:	83 c4 1c             	add    $0x1c,%esp
  801d38:	5b                   	pop    %ebx
  801d39:	5e                   	pop    %esi
  801d3a:	5f                   	pop    %edi
  801d3b:	5d                   	pop    %ebp
  801d3c:	c3                   	ret    

00801d3d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	57                   	push   %edi
  801d41:	56                   	push   %esi
  801d42:	53                   	push   %ebx
  801d43:	83 ec 3c             	sub    $0x3c,%esp
  801d46:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d49:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d4c:	89 04 24             	mov    %eax,(%esp)
  801d4f:	e8 b3 f0 ff ff       	call   800e07 <fd_alloc>
  801d54:	89 c3                	mov    %eax,%ebx
  801d56:	85 c0                	test   %eax,%eax
  801d58:	0f 88 45 01 00 00    	js     801ea3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d65:	00 
  801d66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d74:	e8 98 ed ff ff       	call   800b11 <sys_page_alloc>
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	0f 88 20 01 00 00    	js     801ea3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d83:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d86:	89 04 24             	mov    %eax,(%esp)
  801d89:	e8 79 f0 ff ff       	call   800e07 <fd_alloc>
  801d8e:	89 c3                	mov    %eax,%ebx
  801d90:	85 c0                	test   %eax,%eax
  801d92:	0f 88 f8 00 00 00    	js     801e90 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d98:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d9f:	00 
  801da0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801da3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dae:	e8 5e ed ff ff       	call   800b11 <sys_page_alloc>
  801db3:	89 c3                	mov    %eax,%ebx
  801db5:	85 c0                	test   %eax,%eax
  801db7:	0f 88 d3 00 00 00    	js     801e90 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc0:	89 04 24             	mov    %eax,(%esp)
  801dc3:	e8 24 f0 ff ff       	call   800dec <fd2data>
  801dc8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dd1:	00 
  801dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddd:	e8 2f ed ff ff       	call   800b11 <sys_page_alloc>
  801de2:	89 c3                	mov    %eax,%ebx
  801de4:	85 c0                	test   %eax,%eax
  801de6:	0f 88 91 00 00 00    	js     801e7d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801def:	89 04 24             	mov    %eax,(%esp)
  801df2:	e8 f5 ef ff ff       	call   800dec <fd2data>
  801df7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801dfe:	00 
  801dff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e0a:	00 
  801e0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e16:	e8 4a ed ff ff       	call   800b65 <sys_page_map>
  801e1b:	89 c3                	mov    %eax,%ebx
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	78 4c                	js     801e6d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e21:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e2a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e2f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e36:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e3f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e41:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e44:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e4e:	89 04 24             	mov    %eax,(%esp)
  801e51:	e8 86 ef ff ff       	call   800ddc <fd2num>
  801e56:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e5b:	89 04 24             	mov    %eax,(%esp)
  801e5e:	e8 79 ef ff ff       	call   800ddc <fd2num>
  801e63:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e6b:	eb 36                	jmp    801ea3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e78:	e8 3b ed ff ff       	call   800bb8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8b:	e8 28 ed ff ff       	call   800bb8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9e:	e8 15 ed ff ff       	call   800bb8 <sys_page_unmap>
    err:
	return r;
}
  801ea3:	89 d8                	mov    %ebx,%eax
  801ea5:	83 c4 3c             	add    $0x3c,%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    

00801ead <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eba:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebd:	89 04 24             	mov    %eax,(%esp)
  801ec0:	e8 95 ef ff ff       	call   800e5a <fd_lookup>
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	78 15                	js     801ede <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecc:	89 04 24             	mov    %eax,(%esp)
  801ecf:	e8 18 ef ff ff       	call   800dec <fd2data>
	return _pipeisclosed(fd, p);
  801ed4:	89 c2                	mov    %eax,%edx
  801ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed9:	e8 15 fd ff ff       	call   801bf3 <_pipeisclosed>
}
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ef0:	c7 44 24 04 2b 29 80 	movl   $0x80292b,0x4(%esp)
  801ef7:	00 
  801ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801efb:	89 04 24             	mov    %eax,(%esp)
  801efe:	e8 1c e8 ff ff       	call   80071f <strcpy>
	return 0;
}
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    

00801f0a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	57                   	push   %edi
  801f0e:	56                   	push   %esi
  801f0f:	53                   	push   %ebx
  801f10:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f16:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f21:	eb 30                	jmp    801f53 <devcons_write+0x49>
		m = n - tot;
  801f23:	8b 75 10             	mov    0x10(%ebp),%esi
  801f26:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f28:	83 fe 7f             	cmp    $0x7f,%esi
  801f2b:	76 05                	jbe    801f32 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f2d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f32:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f36:	03 45 0c             	add    0xc(%ebp),%eax
  801f39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3d:	89 3c 24             	mov    %edi,(%esp)
  801f40:	e8 53 e9 ff ff       	call   800898 <memmove>
		sys_cputs(buf, m);
  801f45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f49:	89 3c 24             	mov    %edi,(%esp)
  801f4c:	e8 f3 ea ff ff       	call   800a44 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f51:	01 f3                	add    %esi,%ebx
  801f53:	89 d8                	mov    %ebx,%eax
  801f55:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f58:	72 c9                	jb     801f23 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f5a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5e                   	pop    %esi
  801f62:	5f                   	pop    %edi
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    

00801f65 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f6f:	75 07                	jne    801f78 <devcons_read+0x13>
  801f71:	eb 25                	jmp    801f98 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f73:	e8 7a eb ff ff       	call   800af2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f78:	e8 e5 ea ff ff       	call   800a62 <sys_cgetc>
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	74 f2                	je     801f73 <devcons_read+0xe>
  801f81:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f83:	85 c0                	test   %eax,%eax
  801f85:	78 1d                	js     801fa4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f87:	83 f8 04             	cmp    $0x4,%eax
  801f8a:	74 13                	je     801f9f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8f:	88 10                	mov    %dl,(%eax)
	return 1;
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
  801f96:	eb 0c                	jmp    801fa4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9d:	eb 05                	jmp    801fa4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801fac:	8b 45 08             	mov    0x8(%ebp),%eax
  801faf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fb2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fb9:	00 
  801fba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fbd:	89 04 24             	mov    %eax,(%esp)
  801fc0:	e8 7f ea ff ff       	call   800a44 <sys_cputs>
}
  801fc5:	c9                   	leave  
  801fc6:	c3                   	ret    

00801fc7 <getchar>:

int
getchar(void)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fcd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801fd4:	00 
  801fd5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe3:	e8 10 f1 ff ff       	call   8010f8 <read>
	if (r < 0)
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	78 0f                	js     801ffb <getchar+0x34>
		return r;
	if (r < 1)
  801fec:	85 c0                	test   %eax,%eax
  801fee:	7e 06                	jle    801ff6 <getchar+0x2f>
		return -E_EOF;
	return c;
  801ff0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ff4:	eb 05                	jmp    801ffb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ff6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ffb:	c9                   	leave  
  801ffc:	c3                   	ret    

00801ffd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802003:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802006:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200a:	8b 45 08             	mov    0x8(%ebp),%eax
  80200d:	89 04 24             	mov    %eax,(%esp)
  802010:	e8 45 ee ff ff       	call   800e5a <fd_lookup>
  802015:	85 c0                	test   %eax,%eax
  802017:	78 11                	js     80202a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802019:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802022:	39 10                	cmp    %edx,(%eax)
  802024:	0f 94 c0             	sete   %al
  802027:	0f b6 c0             	movzbl %al,%eax
}
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    

0080202c <opencons>:

int
opencons(void)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802032:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802035:	89 04 24             	mov    %eax,(%esp)
  802038:	e8 ca ed ff ff       	call   800e07 <fd_alloc>
  80203d:	85 c0                	test   %eax,%eax
  80203f:	78 3c                	js     80207d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802041:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802048:	00 
  802049:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802050:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802057:	e8 b5 ea ff ff       	call   800b11 <sys_page_alloc>
  80205c:	85 c0                	test   %eax,%eax
  80205e:	78 1d                	js     80207d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802060:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802066:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802069:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80206b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802075:	89 04 24             	mov    %eax,(%esp)
  802078:	e8 5f ed ff ff       	call   800ddc <fd2num>
}
  80207d:	c9                   	leave  
  80207e:	c3                   	ret    
	...

00802080 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	56                   	push   %esi
  802084:	53                   	push   %ebx
  802085:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802088:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80208b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802091:	e8 3d ea ff ff       	call   800ad3 <sys_getenvid>
  802096:	8b 55 0c             	mov    0xc(%ebp),%edx
  802099:	89 54 24 10          	mov    %edx,0x10(%esp)
  80209d:	8b 55 08             	mov    0x8(%ebp),%edx
  8020a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ac:	c7 04 24 38 29 80 00 	movl   $0x802938,(%esp)
  8020b3:	e8 bc e0 ff ff       	call   800174 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8020bf:	89 04 24             	mov    %eax,(%esp)
  8020c2:	e8 4c e0 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  8020c7:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  8020ce:	e8 a1 e0 ff ff       	call   800174 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020d3:	cc                   	int3   
  8020d4:	eb fd                	jmp    8020d3 <_panic+0x53>
	...

008020d8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	56                   	push   %esi
  8020dc:	53                   	push   %ebx
  8020dd:	83 ec 10             	sub    $0x10,%esp
  8020e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020e9:	85 c0                	test   %eax,%eax
  8020eb:	74 0a                	je     8020f7 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8020ed:	89 04 24             	mov    %eax,(%esp)
  8020f0:	e8 32 ec ff ff       	call   800d27 <sys_ipc_recv>
  8020f5:	eb 0c                	jmp    802103 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8020f7:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8020fe:	e8 24 ec ff ff       	call   800d27 <sys_ipc_recv>
	}
	if (r < 0)
  802103:	85 c0                	test   %eax,%eax
  802105:	79 16                	jns    80211d <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802107:	85 db                	test   %ebx,%ebx
  802109:	74 06                	je     802111 <ipc_recv+0x39>
  80210b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802111:	85 f6                	test   %esi,%esi
  802113:	74 2c                	je     802141 <ipc_recv+0x69>
  802115:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80211b:	eb 24                	jmp    802141 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  80211d:	85 db                	test   %ebx,%ebx
  80211f:	74 0a                	je     80212b <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802121:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802126:	8b 40 74             	mov    0x74(%eax),%eax
  802129:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80212b:	85 f6                	test   %esi,%esi
  80212d:	74 0a                	je     802139 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80212f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802134:	8b 40 78             	mov    0x78(%eax),%eax
  802137:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802139:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80213e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    

00802148 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
  80214b:	57                   	push   %edi
  80214c:	56                   	push   %esi
  80214d:	53                   	push   %ebx
  80214e:	83 ec 1c             	sub    $0x1c,%esp
  802151:	8b 75 08             	mov    0x8(%ebp),%esi
  802154:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802157:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80215a:	85 db                	test   %ebx,%ebx
  80215c:	74 19                	je     802177 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80215e:	8b 45 14             	mov    0x14(%ebp),%eax
  802161:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802165:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802169:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80216d:	89 34 24             	mov    %esi,(%esp)
  802170:	e8 8f eb ff ff       	call   800d04 <sys_ipc_try_send>
  802175:	eb 1c                	jmp    802193 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802177:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80217e:	00 
  80217f:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802186:	ee 
  802187:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80218b:	89 34 24             	mov    %esi,(%esp)
  80218e:	e8 71 eb ff ff       	call   800d04 <sys_ipc_try_send>
		}
		if (r == 0)
  802193:	85 c0                	test   %eax,%eax
  802195:	74 2c                	je     8021c3 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802197:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80219a:	74 20                	je     8021bc <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  80219c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021a0:	c7 44 24 08 5c 29 80 	movl   $0x80295c,0x8(%esp)
  8021a7:	00 
  8021a8:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8021af:	00 
  8021b0:	c7 04 24 6f 29 80 00 	movl   $0x80296f,(%esp)
  8021b7:	e8 c4 fe ff ff       	call   802080 <_panic>
		}
		sys_yield();
  8021bc:	e8 31 e9 ff ff       	call   800af2 <sys_yield>
	}
  8021c1:	eb 97                	jmp    80215a <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8021c3:	83 c4 1c             	add    $0x1c,%esp
  8021c6:	5b                   	pop    %ebx
  8021c7:	5e                   	pop    %esi
  8021c8:	5f                   	pop    %edi
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    

008021cb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	53                   	push   %ebx
  8021cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021d2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021d7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021de:	89 c2                	mov    %eax,%edx
  8021e0:	c1 e2 07             	shl    $0x7,%edx
  8021e3:	29 ca                	sub    %ecx,%edx
  8021e5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021eb:	8b 52 50             	mov    0x50(%edx),%edx
  8021ee:	39 da                	cmp    %ebx,%edx
  8021f0:	75 0f                	jne    802201 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021f2:	c1 e0 07             	shl    $0x7,%eax
  8021f5:	29 c8                	sub    %ecx,%eax
  8021f7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021fc:	8b 40 40             	mov    0x40(%eax),%eax
  8021ff:	eb 0c                	jmp    80220d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802201:	40                   	inc    %eax
  802202:	3d 00 04 00 00       	cmp    $0x400,%eax
  802207:	75 ce                	jne    8021d7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802209:	66 b8 00 00          	mov    $0x0,%ax
}
  80220d:	5b                   	pop    %ebx
  80220e:	5d                   	pop    %ebp
  80220f:	c3                   	ret    

00802210 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802216:	89 c2                	mov    %eax,%edx
  802218:	c1 ea 16             	shr    $0x16,%edx
  80221b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802222:	f6 c2 01             	test   $0x1,%dl
  802225:	74 1e                	je     802245 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802227:	c1 e8 0c             	shr    $0xc,%eax
  80222a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802231:	a8 01                	test   $0x1,%al
  802233:	74 17                	je     80224c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802235:	c1 e8 0c             	shr    $0xc,%eax
  802238:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80223f:	ef 
  802240:	0f b7 c0             	movzwl %ax,%eax
  802243:	eb 0c                	jmp    802251 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802245:	b8 00 00 00 00       	mov    $0x0,%eax
  80224a:	eb 05                	jmp    802251 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80224c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    
	...

00802254 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802254:	55                   	push   %ebp
  802255:	57                   	push   %edi
  802256:	56                   	push   %esi
  802257:	83 ec 10             	sub    $0x10,%esp
  80225a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80225e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802262:	89 74 24 04          	mov    %esi,0x4(%esp)
  802266:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80226a:	89 cd                	mov    %ecx,%ebp
  80226c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802270:	85 c0                	test   %eax,%eax
  802272:	75 2c                	jne    8022a0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802274:	39 f9                	cmp    %edi,%ecx
  802276:	77 68                	ja     8022e0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802278:	85 c9                	test   %ecx,%ecx
  80227a:	75 0b                	jne    802287 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80227c:	b8 01 00 00 00       	mov    $0x1,%eax
  802281:	31 d2                	xor    %edx,%edx
  802283:	f7 f1                	div    %ecx
  802285:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802287:	31 d2                	xor    %edx,%edx
  802289:	89 f8                	mov    %edi,%eax
  80228b:	f7 f1                	div    %ecx
  80228d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80228f:	89 f0                	mov    %esi,%eax
  802291:	f7 f1                	div    %ecx
  802293:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802295:	89 f0                	mov    %esi,%eax
  802297:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802299:	83 c4 10             	add    $0x10,%esp
  80229c:	5e                   	pop    %esi
  80229d:	5f                   	pop    %edi
  80229e:	5d                   	pop    %ebp
  80229f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022a0:	39 f8                	cmp    %edi,%eax
  8022a2:	77 2c                	ja     8022d0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022a4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8022a7:	83 f6 1f             	xor    $0x1f,%esi
  8022aa:	75 4c                	jne    8022f8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022ac:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022ae:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022b3:	72 0a                	jb     8022bf <__udivdi3+0x6b>
  8022b5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022b9:	0f 87 ad 00 00 00    	ja     80236c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022bf:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022d0:	31 ff                	xor    %edi,%edi
  8022d2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022d4:	89 f0                	mov    %esi,%eax
  8022d6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022d8:	83 c4 10             	add    $0x10,%esp
  8022db:	5e                   	pop    %esi
  8022dc:	5f                   	pop    %edi
  8022dd:	5d                   	pop    %ebp
  8022de:	c3                   	ret    
  8022df:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022e0:	89 fa                	mov    %edi,%edx
  8022e2:	89 f0                	mov    %esi,%eax
  8022e4:	f7 f1                	div    %ecx
  8022e6:	89 c6                	mov    %eax,%esi
  8022e8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022ea:	89 f0                	mov    %esi,%eax
  8022ec:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ee:	83 c4 10             	add    $0x10,%esp
  8022f1:	5e                   	pop    %esi
  8022f2:	5f                   	pop    %edi
  8022f3:	5d                   	pop    %ebp
  8022f4:	c3                   	ret    
  8022f5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022f8:	89 f1                	mov    %esi,%ecx
  8022fa:	d3 e0                	shl    %cl,%eax
  8022fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802300:	b8 20 00 00 00       	mov    $0x20,%eax
  802305:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802307:	89 ea                	mov    %ebp,%edx
  802309:	88 c1                	mov    %al,%cl
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802311:	09 ca                	or     %ecx,%edx
  802313:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802317:	89 f1                	mov    %esi,%ecx
  802319:	d3 e5                	shl    %cl,%ebp
  80231b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80231f:	89 fd                	mov    %edi,%ebp
  802321:	88 c1                	mov    %al,%cl
  802323:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802325:	89 fa                	mov    %edi,%edx
  802327:	89 f1                	mov    %esi,%ecx
  802329:	d3 e2                	shl    %cl,%edx
  80232b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80232f:	88 c1                	mov    %al,%cl
  802331:	d3 ef                	shr    %cl,%edi
  802333:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802335:	89 f8                	mov    %edi,%eax
  802337:	89 ea                	mov    %ebp,%edx
  802339:	f7 74 24 08          	divl   0x8(%esp)
  80233d:	89 d1                	mov    %edx,%ecx
  80233f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802341:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802345:	39 d1                	cmp    %edx,%ecx
  802347:	72 17                	jb     802360 <__udivdi3+0x10c>
  802349:	74 09                	je     802354 <__udivdi3+0x100>
  80234b:	89 fe                	mov    %edi,%esi
  80234d:	31 ff                	xor    %edi,%edi
  80234f:	e9 41 ff ff ff       	jmp    802295 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802354:	8b 54 24 04          	mov    0x4(%esp),%edx
  802358:	89 f1                	mov    %esi,%ecx
  80235a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80235c:	39 c2                	cmp    %eax,%edx
  80235e:	73 eb                	jae    80234b <__udivdi3+0xf7>
		{
		  q0--;
  802360:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802363:	31 ff                	xor    %edi,%edi
  802365:	e9 2b ff ff ff       	jmp    802295 <__udivdi3+0x41>
  80236a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80236c:	31 f6                	xor    %esi,%esi
  80236e:	e9 22 ff ff ff       	jmp    802295 <__udivdi3+0x41>
	...

00802374 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802374:	55                   	push   %ebp
  802375:	57                   	push   %edi
  802376:	56                   	push   %esi
  802377:	83 ec 20             	sub    $0x20,%esp
  80237a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80237e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802382:	89 44 24 14          	mov    %eax,0x14(%esp)
  802386:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80238a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80238e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802392:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802394:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802396:	85 ed                	test   %ebp,%ebp
  802398:	75 16                	jne    8023b0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80239a:	39 f1                	cmp    %esi,%ecx
  80239c:	0f 86 a6 00 00 00    	jbe    802448 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023a2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8023a4:	89 d0                	mov    %edx,%eax
  8023a6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023a8:	83 c4 20             	add    $0x20,%esp
  8023ab:	5e                   	pop    %esi
  8023ac:	5f                   	pop    %edi
  8023ad:	5d                   	pop    %ebp
  8023ae:	c3                   	ret    
  8023af:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023b0:	39 f5                	cmp    %esi,%ebp
  8023b2:	0f 87 ac 00 00 00    	ja     802464 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023b8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8023bb:	83 f0 1f             	xor    $0x1f,%eax
  8023be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023c2:	0f 84 a8 00 00 00    	je     802470 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023c8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023cc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023ce:	bf 20 00 00 00       	mov    $0x20,%edi
  8023d3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023d7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023db:	89 f9                	mov    %edi,%ecx
  8023dd:	d3 e8                	shr    %cl,%eax
  8023df:	09 e8                	or     %ebp,%eax
  8023e1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023e5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023e9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023ed:	d3 e0                	shl    %cl,%eax
  8023ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023f3:	89 f2                	mov    %esi,%edx
  8023f5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023f7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023fb:	d3 e0                	shl    %cl,%eax
  8023fd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802401:	8b 44 24 14          	mov    0x14(%esp),%eax
  802405:	89 f9                	mov    %edi,%ecx
  802407:	d3 e8                	shr    %cl,%eax
  802409:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80240b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80240d:	89 f2                	mov    %esi,%edx
  80240f:	f7 74 24 18          	divl   0x18(%esp)
  802413:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802415:	f7 64 24 0c          	mull   0xc(%esp)
  802419:	89 c5                	mov    %eax,%ebp
  80241b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80241d:	39 d6                	cmp    %edx,%esi
  80241f:	72 67                	jb     802488 <__umoddi3+0x114>
  802421:	74 75                	je     802498 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802423:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802427:	29 e8                	sub    %ebp,%eax
  802429:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80242b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80242f:	d3 e8                	shr    %cl,%eax
  802431:	89 f2                	mov    %esi,%edx
  802433:	89 f9                	mov    %edi,%ecx
  802435:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802437:	09 d0                	or     %edx,%eax
  802439:	89 f2                	mov    %esi,%edx
  80243b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80243f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802441:	83 c4 20             	add    $0x20,%esp
  802444:	5e                   	pop    %esi
  802445:	5f                   	pop    %edi
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802448:	85 c9                	test   %ecx,%ecx
  80244a:	75 0b                	jne    802457 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80244c:	b8 01 00 00 00       	mov    $0x1,%eax
  802451:	31 d2                	xor    %edx,%edx
  802453:	f7 f1                	div    %ecx
  802455:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802457:	89 f0                	mov    %esi,%eax
  802459:	31 d2                	xor    %edx,%edx
  80245b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80245d:	89 f8                	mov    %edi,%eax
  80245f:	e9 3e ff ff ff       	jmp    8023a2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802464:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802466:	83 c4 20             	add    $0x20,%esp
  802469:	5e                   	pop    %esi
  80246a:	5f                   	pop    %edi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802470:	39 f5                	cmp    %esi,%ebp
  802472:	72 04                	jb     802478 <__umoddi3+0x104>
  802474:	39 f9                	cmp    %edi,%ecx
  802476:	77 06                	ja     80247e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802478:	89 f2                	mov    %esi,%edx
  80247a:	29 cf                	sub    %ecx,%edi
  80247c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80247e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802480:	83 c4 20             	add    $0x20,%esp
  802483:	5e                   	pop    %esi
  802484:	5f                   	pop    %edi
  802485:	5d                   	pop    %ebp
  802486:	c3                   	ret    
  802487:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802488:	89 d1                	mov    %edx,%ecx
  80248a:	89 c5                	mov    %eax,%ebp
  80248c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802490:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802494:	eb 8d                	jmp    802423 <__umoddi3+0xaf>
  802496:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802498:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80249c:	72 ea                	jb     802488 <__umoddi3+0x114>
  80249e:	89 f1                	mov    %esi,%ecx
  8024a0:	eb 81                	jmp    802423 <__umoddi3+0xaf>
