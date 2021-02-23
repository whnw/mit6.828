
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	89 54 24 08          	mov    %edx,0x8(%esp)
  800047:	8b 00                	mov    (%eax),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  800054:	e8 3f 01 00 00       	call   800198 <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 99 0a 00 00       	call   800af7 <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 3f 0a 00 00       	call   800aa5 <sys_env_destroy>
}
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80006e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800075:	e8 86 0d 00 00       	call   800e00 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007a:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800081:	00 00 00 
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	8b 75 08             	mov    0x8(%ebp),%esi
  800093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800096:	e8 5c 0a 00 00       	call   800af7 <sys_getenvid>
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a7:	c1 e0 07             	shl    $0x7,%eax
  8000aa:	29 d0                	sub    %edx,%eax
  8000ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b1:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b6:	85 f6                	test   %esi,%esi
  8000b8:	7e 07                	jle    8000c1 <libmain+0x39>
		binaryname = argv[0];
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c5:	89 34 24             	mov    %esi,(%esp)
  8000c8:	e8 9b ff ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8000cd:	e8 0a 00 00 00       	call   8000dc <exit>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    
  8000d9:	00 00                	add    %al,(%eax)
	...

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000e2:	e8 74 0f 00 00       	call   80105b <close_all>
	sys_env_destroy(0);
  8000e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ee:	e8 b2 09 00 00       	call   800aa5 <sys_env_destroy>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 14             	sub    $0x14,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	40                   	inc    %eax
  80010c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80010e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800113:	75 19                	jne    80012e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800115:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80011c:	00 
  80011d:	8d 43 08             	lea    0x8(%ebx),%eax
  800120:	89 04 24             	mov    %eax,(%esp)
  800123:	e8 40 09 00 00       	call   800a68 <sys_cputs>
		b->idx = 0;
  800128:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80012e:	ff 43 04             	incl   0x4(%ebx)
}
  800131:	83 c4 14             	add    $0x14,%esp
  800134:	5b                   	pop    %ebx
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800140:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800147:	00 00 00 
	b.cnt = 0;
  80014a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800151:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800154:	8b 45 0c             	mov    0xc(%ebp),%eax
  800157:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015b:	8b 45 08             	mov    0x8(%ebp),%eax
  80015e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016c:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800173:	e8 82 01 00 00       	call   8002fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800178:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 d8 08 00 00       	call   800a68 <sys_cputs>

	return b.cnt;
}
  800190:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 87 ff ff ff       	call   800137 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    
	...

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 3c             	sub    $0x3c,%esp
  8001bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001c0:	89 d7                	mov    %edx,%edi
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	75 08                	jne    8001e0 <printnum+0x2c>
  8001d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001de:	77 57                	ja     800237 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001e4:	4b                   	dec    %ebx
  8001e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001f4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	e8 da 20 00 00       	call   8022ec <__udivdi3>
  800212:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800216:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800221:	89 fa                	mov    %edi,%edx
  800223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800226:	e8 89 ff ff ff       	call   8001b4 <printnum>
  80022b:	eb 0f                	jmp    80023c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800231:	89 34 24             	mov    %esi,(%esp)
  800234:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800237:	4b                   	dec    %ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7f f1                	jg     80022d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800240:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800244:	8b 45 10             	mov    0x10(%ebp),%eax
  800247:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800252:	00 
  800253:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80025c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800260:	e8 a7 21 00 00       	call   80240c <__umoddi3>
  800265:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800269:	0f be 80 66 25 80 00 	movsbl 0x802566(%eax),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800276:	83 c4 3c             	add    $0x3c,%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800281:	83 fa 01             	cmp    $0x1,%edx
  800284:	7e 0e                	jle    800294 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	8b 52 04             	mov    0x4(%edx),%edx
  800292:	eb 22                	jmp    8002b6 <getuint+0x38>
	else if (lflag)
  800294:	85 d2                	test   %edx,%edx
  800296:	74 10                	je     8002a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a6:	eb 0e                	jmp    8002b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002be:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c6:	73 08                	jae    8002d0 <sprintputch+0x18>
		*b->buf++ = ch;
  8002c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cb:	88 0a                	mov    %cl,(%edx)
  8002cd:	42                   	inc    %edx
  8002ce:	89 10                	mov    %edx,(%eax)
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002df:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	e8 02 00 00 00       	call   8002fa <vprintfmt>
	va_end(ap);
}
  8002f8:	c9                   	leave  
  8002f9:	c3                   	ret    

008002fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	57                   	push   %edi
  8002fe:	56                   	push   %esi
  8002ff:	53                   	push   %ebx
  800300:	83 ec 4c             	sub    $0x4c,%esp
  800303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800306:	8b 75 10             	mov    0x10(%ebp),%esi
  800309:	eb 12                	jmp    80031d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030b:	85 c0                	test   %eax,%eax
  80030d:	0f 84 6b 03 00 00    	je     80067e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800313:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031d:	0f b6 06             	movzbl (%esi),%eax
  800320:	46                   	inc    %esi
  800321:	83 f8 25             	cmp    $0x25,%eax
  800324:	75 e5                	jne    80030b <vprintfmt+0x11>
  800326:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80032a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800331:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800336:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	eb 26                	jmp    80036a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800347:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80034b:	eb 1d                	jmp    80036a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800350:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800354:	eb 14                	jmp    80036a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800359:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800360:	eb 08                	jmp    80036a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800362:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800365:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	0f b6 06             	movzbl (%esi),%eax
  80036d:	8d 56 01             	lea    0x1(%esi),%edx
  800370:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800373:	8a 16                	mov    (%esi),%dl
  800375:	83 ea 23             	sub    $0x23,%edx
  800378:	80 fa 55             	cmp    $0x55,%dl
  80037b:	0f 87 e1 02 00 00    	ja     800662 <vprintfmt+0x368>
  800381:	0f b6 d2             	movzbl %dl,%edx
  800384:	ff 24 95 a0 26 80 00 	jmp    *0x8026a0(,%edx,4)
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80038e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800393:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800396:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80039a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80039d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a0:	83 fa 09             	cmp    $0x9,%edx
  8003a3:	77 2a                	ja     8003cf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a6:	eb eb                	jmp    800393 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 50 04             	lea    0x4(%eax),%edx
  8003ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b6:	eb 17                	jmp    8003cf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003bc:	78 98                	js     800356 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003c1:	eb a7                	jmp    80036a <vprintfmt+0x70>
  8003c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003cd:	eb 9b                	jmp    80036a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d3:	79 95                	jns    80036a <vprintfmt+0x70>
  8003d5:	eb 8b                	jmp    800362 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003db:	eb 8d                	jmp    80036a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f5:	e9 23 ff ff ff       	jmp    80031d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	8b 00                	mov    (%eax),%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	79 02                	jns    80040b <vprintfmt+0x111>
  800409:	f7 d8                	neg    %eax
  80040b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040d:	83 f8 10             	cmp    $0x10,%eax
  800410:	7f 0b                	jg     80041d <vprintfmt+0x123>
  800412:	8b 04 85 00 28 80 00 	mov    0x802800(,%eax,4),%eax
  800419:	85 c0                	test   %eax,%eax
  80041b:	75 23                	jne    800440 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80041d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800421:	c7 44 24 08 7e 25 80 	movl   $0x80257e,0x8(%esp)
  800428:	00 
  800429:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	e8 9a fe ff ff       	call   8002d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043b:	e9 dd fe ff ff       	jmp    80031d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800444:	c7 44 24 08 39 29 80 	movl   $0x802939,0x8(%esp)
  80044b:	00 
  80044c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800450:	8b 55 08             	mov    0x8(%ebp),%edx
  800453:	89 14 24             	mov    %edx,(%esp)
  800456:	e8 77 fe ff ff       	call   8002d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045e:	e9 ba fe ff ff       	jmp    80031d <vprintfmt+0x23>
  800463:	89 f9                	mov    %edi,%ecx
  800465:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800468:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 50 04             	lea    0x4(%eax),%edx
  800471:	89 55 14             	mov    %edx,0x14(%ebp)
  800474:	8b 30                	mov    (%eax),%esi
  800476:	85 f6                	test   %esi,%esi
  800478:	75 05                	jne    80047f <vprintfmt+0x185>
				p = "(null)";
  80047a:	be 77 25 80 00       	mov    $0x802577,%esi
			if (width > 0 && padc != '-')
  80047f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800483:	0f 8e 84 00 00 00    	jle    80050d <vprintfmt+0x213>
  800489:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80048d:	74 7e                	je     80050d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800493:	89 34 24             	mov    %esi,(%esp)
  800496:	e8 8b 02 00 00       	call   800726 <strnlen>
  80049b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049e:	29 c2                	sub    %eax,%edx
  8004a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004ad:	89 de                	mov    %ebx,%esi
  8004af:	89 d3                	mov    %edx,%ebx
  8004b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	eb 0b                	jmp    8004c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b9:	89 3c 24             	mov    %edi,(%esp)
  8004bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	4b                   	dec    %ebx
  8004c0:	85 db                	test   %ebx,%ebx
  8004c2:	7f f1                	jg     8004b5 <vprintfmt+0x1bb>
  8004c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004c7:	89 f3                	mov    %esi,%ebx
  8004c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	79 05                	jns    8004d8 <vprintfmt+0x1de>
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004db:	29 c2                	sub    %eax,%edx
  8004dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004e0:	eb 2b                	jmp    80050d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e6:	74 18                	je     800500 <vprintfmt+0x206>
  8004e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004eb:	83 fa 5e             	cmp    $0x5e,%edx
  8004ee:	76 10                	jbe    800500 <vprintfmt+0x206>
					putch('?', putdat);
  8004f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004fb:	ff 55 08             	call   *0x8(%ebp)
  8004fe:	eb 0a                	jmp    80050a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	ff 4d e4             	decl   -0x1c(%ebp)
  80050d:	0f be 06             	movsbl (%esi),%eax
  800510:	46                   	inc    %esi
  800511:	85 c0                	test   %eax,%eax
  800513:	74 21                	je     800536 <vprintfmt+0x23c>
  800515:	85 ff                	test   %edi,%edi
  800517:	78 c9                	js     8004e2 <vprintfmt+0x1e8>
  800519:	4f                   	dec    %edi
  80051a:	79 c6                	jns    8004e2 <vprintfmt+0x1e8>
  80051c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80051f:	89 de                	mov    %ebx,%esi
  800521:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800524:	eb 18                	jmp    80053e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800526:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800531:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800533:	4b                   	dec    %ebx
  800534:	eb 08                	jmp    80053e <vprintfmt+0x244>
  800536:	8b 7d 08             	mov    0x8(%ebp),%edi
  800539:	89 de                	mov    %ebx,%esi
  80053b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053e:	85 db                	test   %ebx,%ebx
  800540:	7f e4                	jg     800526 <vprintfmt+0x22c>
  800542:	89 7d 08             	mov    %edi,0x8(%ebp)
  800545:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054a:	e9 ce fd ff ff       	jmp    80031d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 f9 01             	cmp    $0x1,%ecx
  800552:	7e 10                	jle    800564 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 08             	lea    0x8(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 30                	mov    (%eax),%esi
  80055f:	8b 78 04             	mov    0x4(%eax),%edi
  800562:	eb 26                	jmp    80058a <vprintfmt+0x290>
	else if (lflag)
  800564:	85 c9                	test   %ecx,%ecx
  800566:	74 12                	je     80057a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 30                	mov    (%eax),%esi
  800573:	89 f7                	mov    %esi,%edi
  800575:	c1 ff 1f             	sar    $0x1f,%edi
  800578:	eb 10                	jmp    80058a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 50 04             	lea    0x4(%eax),%edx
  800580:	89 55 14             	mov    %edx,0x14(%ebp)
  800583:	8b 30                	mov    (%eax),%esi
  800585:	89 f7                	mov    %esi,%edi
  800587:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058a:	85 ff                	test   %edi,%edi
  80058c:	78 0a                	js     800598 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800593:	e9 8c 00 00 00       	jmp    800624 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a6:	f7 de                	neg    %esi
  8005a8:	83 d7 00             	adc    $0x0,%edi
  8005ab:	f7 df                	neg    %edi
			}
			base = 10;
  8005ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b2:	eb 70                	jmp    800624 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b4:	89 ca                	mov    %ecx,%edx
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 c0 fc ff ff       	call   80027e <getuint>
  8005be:	89 c6                	mov    %eax,%esi
  8005c0:	89 d7                	mov    %edx,%edi
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005c7:	eb 5b                	jmp    800624 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8005c9:	89 ca                	mov    %ecx,%edx
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 ab fc ff ff       	call   80027e <getuint>
  8005d3:	89 c6                	mov    %eax,%esi
  8005d5:	89 d7                	mov    %edx,%edi
			base = 8;
  8005d7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005dc:	eb 46                	jmp    800624 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800603:	8b 30                	mov    (%eax),%esi
  800605:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060f:	eb 13                	jmp    800624 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800611:	89 ca                	mov    %ecx,%edx
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 63 fc ff ff       	call   80027e <getuint>
  80061b:	89 c6                	mov    %eax,%esi
  80061d:	89 d7                	mov    %edx,%edi
			base = 16;
  80061f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800624:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800628:	89 54 24 10          	mov    %edx,0x10(%esp)
  80062c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800633:	89 44 24 08          	mov    %eax,0x8(%esp)
  800637:	89 34 24             	mov    %esi,(%esp)
  80063a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063e:	89 da                	mov    %ebx,%edx
  800640:	8b 45 08             	mov    0x8(%ebp),%eax
  800643:	e8 6c fb ff ff       	call   8001b4 <printnum>
			break;
  800648:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064b:	e9 cd fc ff ff       	jmp    80031d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80065d:	e9 bb fc ff ff       	jmp    80031d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800662:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800666:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80066d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800670:	eb 01                	jmp    800673 <vprintfmt+0x379>
  800672:	4e                   	dec    %esi
  800673:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800677:	75 f9                	jne    800672 <vprintfmt+0x378>
  800679:	e9 9f fc ff ff       	jmp    80031d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80067e:	83 c4 4c             	add    $0x4c,%esp
  800681:	5b                   	pop    %ebx
  800682:	5e                   	pop    %esi
  800683:	5f                   	pop    %edi
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 28             	sub    $0x28,%esp
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800692:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800695:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800699:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	74 30                	je     8006d7 <vsnprintf+0x51>
  8006a7:	85 d2                	test   %edx,%edx
  8006a9:	7e 33                	jle    8006de <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c0:	c7 04 24 b8 02 80 00 	movl   $0x8002b8,(%esp)
  8006c7:	e8 2e fc ff ff       	call   8002fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d5:	eb 0c                	jmp    8006e3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006dc:	eb 05                	jmp    8006e3 <vsnprintf+0x5d>
  8006de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800700:	8b 45 08             	mov    0x8(%ebp),%eax
  800703:	89 04 24             	mov    %eax,(%esp)
  800706:	e8 7b ff ff ff       	call   800686 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    
  80070d:	00 00                	add    %al,(%eax)
	...

00800710 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	eb 01                	jmp    80071e <strlen+0xe>
		n++;
  80071d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800722:	75 f9                	jne    80071d <strlen+0xd>
		n++;
	return n;
}
  800724:	5d                   	pop    %ebp
  800725:	c3                   	ret    

00800726 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80072c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072f:	b8 00 00 00 00       	mov    $0x0,%eax
  800734:	eb 01                	jmp    800737 <strnlen+0x11>
		n++;
  800736:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800737:	39 d0                	cmp    %edx,%eax
  800739:	74 06                	je     800741 <strnlen+0x1b>
  80073b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80073f:	75 f5                	jne    800736 <strnlen+0x10>
		n++;
	return n;
}
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	53                   	push   %ebx
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074d:	ba 00 00 00 00       	mov    $0x0,%edx
  800752:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800755:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800758:	42                   	inc    %edx
  800759:	84 c9                	test   %cl,%cl
  80075b:	75 f5                	jne    800752 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80075d:	5b                   	pop    %ebx
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076a:	89 1c 24             	mov    %ebx,(%esp)
  80076d:	e8 9e ff ff ff       	call   800710 <strlen>
	strcpy(dst + len, src);
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
  800775:	89 54 24 04          	mov    %edx,0x4(%esp)
  800779:	01 d8                	add    %ebx,%eax
  80077b:	89 04 24             	mov    %eax,(%esp)
  80077e:	e8 c0 ff ff ff       	call   800743 <strcpy>
	return dst;
}
  800783:	89 d8                	mov    %ebx,%eax
  800785:	83 c4 08             	add    $0x8,%esp
  800788:	5b                   	pop    %ebx
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8b 55 0c             	mov    0xc(%ebp),%edx
  800796:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800799:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079e:	eb 0c                	jmp    8007ac <strncpy+0x21>
		*dst++ = *src;
  8007a0:	8a 1a                	mov    (%edx),%bl
  8007a2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007a8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	41                   	inc    %ecx
  8007ac:	39 f1                	cmp    %esi,%ecx
  8007ae:	75 f0                	jne    8007a0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	75 0a                	jne    8007d0 <strlcpy+0x1c>
  8007c6:	89 f0                	mov    %esi,%eax
  8007c8:	eb 1a                	jmp    8007e4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ca:	88 18                	mov    %bl,(%eax)
  8007cc:	40                   	inc    %eax
  8007cd:	41                   	inc    %ecx
  8007ce:	eb 02                	jmp    8007d2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007d2:	4a                   	dec    %edx
  8007d3:	74 0a                	je     8007df <strlcpy+0x2b>
  8007d5:	8a 19                	mov    (%ecx),%bl
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	75 ef                	jne    8007ca <strlcpy+0x16>
  8007db:	89 c2                	mov    %eax,%edx
  8007dd:	eb 02                	jmp    8007e1 <strlcpy+0x2d>
  8007df:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007e1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007e4:	29 f0                	sub    %esi,%eax
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f3:	eb 02                	jmp    8007f7 <strcmp+0xd>
		p++, q++;
  8007f5:	41                   	inc    %ecx
  8007f6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f7:	8a 01                	mov    (%ecx),%al
  8007f9:	84 c0                	test   %al,%al
  8007fb:	74 04                	je     800801 <strcmp+0x17>
  8007fd:	3a 02                	cmp    (%edx),%al
  8007ff:	74 f4                	je     8007f5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800801:	0f b6 c0             	movzbl %al,%eax
  800804:	0f b6 12             	movzbl (%edx),%edx
  800807:	29 d0                	sub    %edx,%eax
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800815:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800818:	eb 03                	jmp    80081d <strncmp+0x12>
		n--, p++, q++;
  80081a:	4a                   	dec    %edx
  80081b:	40                   	inc    %eax
  80081c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081d:	85 d2                	test   %edx,%edx
  80081f:	74 14                	je     800835 <strncmp+0x2a>
  800821:	8a 18                	mov    (%eax),%bl
  800823:	84 db                	test   %bl,%bl
  800825:	74 04                	je     80082b <strncmp+0x20>
  800827:	3a 19                	cmp    (%ecx),%bl
  800829:	74 ef                	je     80081a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082b:	0f b6 00             	movzbl (%eax),%eax
  80082e:	0f b6 11             	movzbl (%ecx),%edx
  800831:	29 d0                	sub    %edx,%eax
  800833:	eb 05                	jmp    80083a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083a:	5b                   	pop    %ebx
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800846:	eb 05                	jmp    80084d <strchr+0x10>
		if (*s == c)
  800848:	38 ca                	cmp    %cl,%dl
  80084a:	74 0c                	je     800858 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084c:	40                   	inc    %eax
  80084d:	8a 10                	mov    (%eax),%dl
  80084f:	84 d2                	test   %dl,%dl
  800851:	75 f5                	jne    800848 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800863:	eb 05                	jmp    80086a <strfind+0x10>
		if (*s == c)
  800865:	38 ca                	cmp    %cl,%dl
  800867:	74 07                	je     800870 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800869:	40                   	inc    %eax
  80086a:	8a 10                	mov    (%eax),%dl
  80086c:	84 d2                	test   %dl,%dl
  80086e:	75 f5                	jne    800865 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800881:	85 c9                	test   %ecx,%ecx
  800883:	74 30                	je     8008b5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800885:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088b:	75 25                	jne    8008b2 <memset+0x40>
  80088d:	f6 c1 03             	test   $0x3,%cl
  800890:	75 20                	jne    8008b2 <memset+0x40>
		c &= 0xFF;
  800892:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800895:	89 d3                	mov    %edx,%ebx
  800897:	c1 e3 08             	shl    $0x8,%ebx
  80089a:	89 d6                	mov    %edx,%esi
  80089c:	c1 e6 18             	shl    $0x18,%esi
  80089f:	89 d0                	mov    %edx,%eax
  8008a1:	c1 e0 10             	shl    $0x10,%eax
  8008a4:	09 f0                	or     %esi,%eax
  8008a6:	09 d0                	or     %edx,%eax
  8008a8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008ad:	fc                   	cld    
  8008ae:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b0:	eb 03                	jmp    8008b5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b2:	fc                   	cld    
  8008b3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b5:	89 f8                	mov    %edi,%eax
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5f                   	pop    %edi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ca:	39 c6                	cmp    %eax,%esi
  8008cc:	73 34                	jae    800902 <memmove+0x46>
  8008ce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d1:	39 d0                	cmp    %edx,%eax
  8008d3:	73 2d                	jae    800902 <memmove+0x46>
		s += n;
		d += n;
  8008d5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d8:	f6 c2 03             	test   $0x3,%dl
  8008db:	75 1b                	jne    8008f8 <memmove+0x3c>
  8008dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e3:	75 13                	jne    8008f8 <memmove+0x3c>
  8008e5:	f6 c1 03             	test   $0x3,%cl
  8008e8:	75 0e                	jne    8008f8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ea:	83 ef 04             	sub    $0x4,%edi
  8008ed:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f3:	fd                   	std    
  8008f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f6:	eb 07                	jmp    8008ff <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f8:	4f                   	dec    %edi
  8008f9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fc:	fd                   	std    
  8008fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ff:	fc                   	cld    
  800900:	eb 20                	jmp    800922 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800902:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800908:	75 13                	jne    80091d <memmove+0x61>
  80090a:	a8 03                	test   $0x3,%al
  80090c:	75 0f                	jne    80091d <memmove+0x61>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 0a                	jne    80091d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800913:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800916:	89 c7                	mov    %eax,%edi
  800918:	fc                   	cld    
  800919:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091b:	eb 05                	jmp    800922 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091d:	89 c7                	mov    %eax,%edi
  80091f:	fc                   	cld    
  800920:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80092c:	8b 45 10             	mov    0x10(%ebp),%eax
  80092f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	89 04 24             	mov    %eax,(%esp)
  800940:	e8 77 ff ff ff       	call   8008bc <memmove>
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800956:	ba 00 00 00 00       	mov    $0x0,%edx
  80095b:	eb 16                	jmp    800973 <memcmp+0x2c>
		if (*s1 != *s2)
  80095d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800960:	42                   	inc    %edx
  800961:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800965:	38 c8                	cmp    %cl,%al
  800967:	74 0a                	je     800973 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800969:	0f b6 c0             	movzbl %al,%eax
  80096c:	0f b6 c9             	movzbl %cl,%ecx
  80096f:	29 c8                	sub    %ecx,%eax
  800971:	eb 09                	jmp    80097c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800973:	39 da                	cmp    %ebx,%edx
  800975:	75 e6                	jne    80095d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098a:	89 c2                	mov    %eax,%edx
  80098c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098f:	eb 05                	jmp    800996 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800991:	38 08                	cmp    %cl,(%eax)
  800993:	74 05                	je     80099a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800995:	40                   	inc    %eax
  800996:	39 d0                	cmp    %edx,%eax
  800998:	72 f7                	jb     800991 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a8:	eb 01                	jmp    8009ab <strtol+0xf>
		s++;
  8009aa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ab:	8a 02                	mov    (%edx),%al
  8009ad:	3c 20                	cmp    $0x20,%al
  8009af:	74 f9                	je     8009aa <strtol+0xe>
  8009b1:	3c 09                	cmp    $0x9,%al
  8009b3:	74 f5                	je     8009aa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b5:	3c 2b                	cmp    $0x2b,%al
  8009b7:	75 08                	jne    8009c1 <strtol+0x25>
		s++;
  8009b9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bf:	eb 13                	jmp    8009d4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c1:	3c 2d                	cmp    $0x2d,%al
  8009c3:	75 0a                	jne    8009cf <strtol+0x33>
		s++, neg = 1;
  8009c5:	8d 52 01             	lea    0x1(%edx),%edx
  8009c8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009cd:	eb 05                	jmp    8009d4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d4:	85 db                	test   %ebx,%ebx
  8009d6:	74 05                	je     8009dd <strtol+0x41>
  8009d8:	83 fb 10             	cmp    $0x10,%ebx
  8009db:	75 28                	jne    800a05 <strtol+0x69>
  8009dd:	8a 02                	mov    (%edx),%al
  8009df:	3c 30                	cmp    $0x30,%al
  8009e1:	75 10                	jne    8009f3 <strtol+0x57>
  8009e3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009e7:	75 0a                	jne    8009f3 <strtol+0x57>
		s += 2, base = 16;
  8009e9:	83 c2 02             	add    $0x2,%edx
  8009ec:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f1:	eb 12                	jmp    800a05 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009f3:	85 db                	test   %ebx,%ebx
  8009f5:	75 0e                	jne    800a05 <strtol+0x69>
  8009f7:	3c 30                	cmp    $0x30,%al
  8009f9:	75 05                	jne    800a00 <strtol+0x64>
		s++, base = 8;
  8009fb:	42                   	inc    %edx
  8009fc:	b3 08                	mov    $0x8,%bl
  8009fe:	eb 05                	jmp    800a05 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a00:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0c:	8a 0a                	mov    (%edx),%cl
  800a0e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a11:	80 fb 09             	cmp    $0x9,%bl
  800a14:	77 08                	ja     800a1e <strtol+0x82>
			dig = *s - '0';
  800a16:	0f be c9             	movsbl %cl,%ecx
  800a19:	83 e9 30             	sub    $0x30,%ecx
  800a1c:	eb 1e                	jmp    800a3c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a1e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a21:	80 fb 19             	cmp    $0x19,%bl
  800a24:	77 08                	ja     800a2e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a26:	0f be c9             	movsbl %cl,%ecx
  800a29:	83 e9 57             	sub    $0x57,%ecx
  800a2c:	eb 0e                	jmp    800a3c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a2e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a31:	80 fb 19             	cmp    $0x19,%bl
  800a34:	77 12                	ja     800a48 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a36:	0f be c9             	movsbl %cl,%ecx
  800a39:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a3c:	39 f1                	cmp    %esi,%ecx
  800a3e:	7d 0c                	jge    800a4c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a40:	42                   	inc    %edx
  800a41:	0f af c6             	imul   %esi,%eax
  800a44:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a46:	eb c4                	jmp    800a0c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a48:	89 c1                	mov    %eax,%ecx
  800a4a:	eb 02                	jmp    800a4e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a4c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a52:	74 05                	je     800a59 <strtol+0xbd>
		*endptr = (char *) s;
  800a54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a57:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a59:	85 ff                	test   %edi,%edi
  800a5b:	74 04                	je     800a61 <strtol+0xc5>
  800a5d:	89 c8                	mov    %ecx,%eax
  800a5f:	f7 d8                	neg    %eax
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
	...

00800a68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	89 c3                	mov    %eax,%ebx
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	89 c6                	mov    %eax,%esi
  800a7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 01 00 00 00       	mov    $0x1,%eax
  800a96:	89 d1                	mov    %edx,%ecx
  800a98:	89 d3                	mov    %edx,%ebx
  800a9a:	89 d7                	mov    %edx,%edi
  800a9c:	89 d6                	mov    %edx,%esi
  800a9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	89 cb                	mov    %ecx,%ebx
  800abd:	89 cf                	mov    %ecx,%edi
  800abf:	89 ce                	mov    %ecx,%esi
  800ac1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	7e 28                	jle    800aef <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800acb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ad2:	00 
  800ad3:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800ada:	00 
  800adb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ae2:	00 
  800ae3:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800aea:	e8 29 16 00 00       	call   802118 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aef:	83 c4 2c             	add    $0x2c,%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afd:	ba 00 00 00 00       	mov    $0x0,%edx
  800b02:	b8 02 00 00 00       	mov    $0x2,%eax
  800b07:	89 d1                	mov    %edx,%ecx
  800b09:	89 d3                	mov    %edx,%ebx
  800b0b:	89 d7                	mov    %edx,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_yield>:

void
sys_yield(void)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b26:	89 d1                	mov    %edx,%ecx
  800b28:	89 d3                	mov    %edx,%ebx
  800b2a:	89 d7                	mov    %edx,%edi
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	be 00 00 00 00       	mov    $0x0,%esi
  800b43:	b8 04 00 00 00       	mov    $0x4,%eax
  800b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 f7                	mov    %esi,%edi
  800b53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b55:	85 c0                	test   %eax,%eax
  800b57:	7e 28                	jle    800b81 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b5d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b64:	00 
  800b65:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800b6c:	00 
  800b6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b74:	00 
  800b75:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800b7c:	e8 97 15 00 00       	call   802118 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b81:	83 c4 2c             	add    $0x2c,%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	b8 05 00 00 00       	mov    $0x5,%eax
  800b97:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	7e 28                	jle    800bd4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bb7:	00 
  800bb8:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800bbf:	00 
  800bc0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc7:	00 
  800bc8:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800bcf:	e8 44 15 00 00       	call   802118 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd4:	83 c4 2c             	add    $0x2c,%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 06 00 00 00       	mov    $0x6,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 28                	jle    800c27 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c03:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800c12:	00 
  800c13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1a:	00 
  800c1b:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800c22:	e8 f1 14 00 00       	call   802118 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c27:	83 c4 2c             	add    $0x2c,%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	89 df                	mov    %ebx,%edi
  800c4a:	89 de                	mov    %ebx,%esi
  800c4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	7e 28                	jle    800c7a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c56:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c5d:	00 
  800c5e:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800c65:	00 
  800c66:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6d:	00 
  800c6e:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800c75:	e8 9e 14 00 00       	call   802118 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7a:	83 c4 2c             	add    $0x2c,%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 09 00 00 00       	mov    $0x9,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 28                	jle    800ccd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800cb8:	00 
  800cb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc0:	00 
  800cc1:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800cc8:	e8 4b 14 00 00       	call   802118 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ccd:	83 c4 2c             	add    $0x2c,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	89 df                	mov    %ebx,%edi
  800cf0:	89 de                	mov    %ebx,%esi
  800cf2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7e 28                	jle    800d20 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d03:	00 
  800d04:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800d0b:	00 
  800d0c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d13:	00 
  800d14:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800d1b:	e8 f8 13 00 00       	call   802118 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d20:	83 c4 2c             	add    $0x2c,%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	be 00 00 00 00       	mov    $0x0,%esi
  800d33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 cb                	mov    %ecx,%ebx
  800d63:	89 cf                	mov    %ecx,%edi
  800d65:	89 ce                	mov    %ecx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 28                	jle    800d95 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d71:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d78:	00 
  800d79:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800d80:	00 
  800d81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d88:	00 
  800d89:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800d90:	e8 83 13 00 00       	call   802118 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d95:	83 c4 2c             	add    $0x2c,%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da3:	ba 00 00 00 00       	mov    $0x0,%edx
  800da8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dad:	89 d1                	mov    %edx,%ecx
  800daf:	89 d3                	mov    %edx,%ebx
  800db1:	89 d7                	mov    %edx,%edi
  800db3:	89 d6                	mov    %edx,%esi
  800db5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc7:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	89 df                	mov    %ebx,%edi
  800dd4:	89 de                	mov    %ebx,%esi
  800dd6:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de8:	b8 10 00 00 00       	mov    $0x10,%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 df                	mov    %ebx,%edi
  800df5:	89 de                	mov    %ebx,%esi
  800df7:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    
	...

00800e00 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e06:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e0d:	75 30                	jne    800e3f <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  800e0f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e1e:	ee 
  800e1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e26:	e8 0a fd ff ff       	call   800b35 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  800e2b:	c7 44 24 04 4c 0e 80 	movl   $0x800e4c,0x4(%esp)
  800e32:	00 
  800e33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e3a:	e8 96 fe ff ff       	call   800cd5 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    
  800e49:	00 00                	add    %al,(%eax)
	...

00800e4c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e4c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e4d:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e52:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e54:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  800e57:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  800e5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  800e5f:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  800e62:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  800e64:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  800e68:	83 c4 08             	add    $0x8,%esp
	popal
  800e6b:	61                   	popa   

	addl $4,%esp 
  800e6c:	83 c4 04             	add    $0x4,%esp
	popfl
  800e6f:	9d                   	popf   

	popl %esp
  800e70:	5c                   	pop    %esp

	ret
  800e71:	c3                   	ret    
	...

00800e74 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e7f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	e8 df ff ff ff       	call   800e74 <fd2num>
  800e95:	c1 e0 0c             	shl    $0xc,%eax
  800e98:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	53                   	push   %ebx
  800ea3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ea6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800eab:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ead:	89 c2                	mov    %eax,%edx
  800eaf:	c1 ea 16             	shr    $0x16,%edx
  800eb2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb9:	f6 c2 01             	test   $0x1,%dl
  800ebc:	74 11                	je     800ecf <fd_alloc+0x30>
  800ebe:	89 c2                	mov    %eax,%edx
  800ec0:	c1 ea 0c             	shr    $0xc,%edx
  800ec3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eca:	f6 c2 01             	test   $0x1,%dl
  800ecd:	75 09                	jne    800ed8 <fd_alloc+0x39>
			*fd_store = fd;
  800ecf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	eb 17                	jmp    800eef <fd_alloc+0x50>
  800ed8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800edd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee2:	75 c7                	jne    800eab <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ee4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800eea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eef:	5b                   	pop    %ebx
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ef8:	83 f8 1f             	cmp    $0x1f,%eax
  800efb:	77 36                	ja     800f33 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800efd:	c1 e0 0c             	shl    $0xc,%eax
  800f00:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f05:	89 c2                	mov    %eax,%edx
  800f07:	c1 ea 16             	shr    $0x16,%edx
  800f0a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f11:	f6 c2 01             	test   $0x1,%dl
  800f14:	74 24                	je     800f3a <fd_lookup+0x48>
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	c1 ea 0c             	shr    $0xc,%edx
  800f1b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f22:	f6 c2 01             	test   $0x1,%dl
  800f25:	74 1a                	je     800f41 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f31:	eb 13                	jmp    800f46 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f38:	eb 0c                	jmp    800f46 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3f:	eb 05                	jmp    800f46 <fd_lookup+0x54>
  800f41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	53                   	push   %ebx
  800f4c:	83 ec 14             	sub    $0x14,%esp
  800f4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800f55:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5a:	eb 0e                	jmp    800f6a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800f5c:	39 08                	cmp    %ecx,(%eax)
  800f5e:	75 09                	jne    800f69 <dev_lookup+0x21>
			*dev = devtab[i];
  800f60:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
  800f67:	eb 33                	jmp    800f9c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f69:	42                   	inc    %edx
  800f6a:	8b 04 95 0c 29 80 00 	mov    0x80290c(,%edx,4),%eax
  800f71:	85 c0                	test   %eax,%eax
  800f73:	75 e7                	jne    800f5c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f75:	a1 08 40 80 00       	mov    0x804008,%eax
  800f7a:	8b 40 48             	mov    0x48(%eax),%eax
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f85:	c7 04 24 90 28 80 00 	movl   $0x802890,(%esp)
  800f8c:	e8 07 f2 ff ff       	call   800198 <cprintf>
	*dev = 0;
  800f91:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f9c:	83 c4 14             	add    $0x14,%esp
  800f9f:	5b                   	pop    %ebx
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 30             	sub    $0x30,%esp
  800faa:	8b 75 08             	mov    0x8(%ebp),%esi
  800fad:	8a 45 0c             	mov    0xc(%ebp),%al
  800fb0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb3:	89 34 24             	mov    %esi,(%esp)
  800fb6:	e8 b9 fe ff ff       	call   800e74 <fd2num>
  800fbb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fbe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc2:	89 04 24             	mov    %eax,(%esp)
  800fc5:	e8 28 ff ff ff       	call   800ef2 <fd_lookup>
  800fca:	89 c3                	mov    %eax,%ebx
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 05                	js     800fd5 <fd_close+0x33>
	    || fd != fd2)
  800fd0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd3:	74 0d                	je     800fe2 <fd_close+0x40>
		return (must_exist ? r : 0);
  800fd5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fd9:	75 46                	jne    801021 <fd_close+0x7f>
  800fdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe0:	eb 3f                	jmp    801021 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe9:	8b 06                	mov    (%esi),%eax
  800feb:	89 04 24             	mov    %eax,(%esp)
  800fee:	e8 55 ff ff ff       	call   800f48 <dev_lookup>
  800ff3:	89 c3                	mov    %eax,%ebx
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 18                	js     801011 <fd_close+0x6f>
		if (dev->dev_close)
  800ff9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffc:	8b 40 10             	mov    0x10(%eax),%eax
  800fff:	85 c0                	test   %eax,%eax
  801001:	74 09                	je     80100c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801003:	89 34 24             	mov    %esi,(%esp)
  801006:	ff d0                	call   *%eax
  801008:	89 c3                	mov    %eax,%ebx
  80100a:	eb 05                	jmp    801011 <fd_close+0x6f>
		else
			r = 0;
  80100c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801011:	89 74 24 04          	mov    %esi,0x4(%esp)
  801015:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101c:	e8 bb fb ff ff       	call   800bdc <sys_page_unmap>
	return r;
}
  801021:	89 d8                	mov    %ebx,%eax
  801023:	83 c4 30             	add    $0x30,%esp
  801026:	5b                   	pop    %ebx
  801027:	5e                   	pop    %esi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801030:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801033:	89 44 24 04          	mov    %eax,0x4(%esp)
  801037:	8b 45 08             	mov    0x8(%ebp),%eax
  80103a:	89 04 24             	mov    %eax,(%esp)
  80103d:	e8 b0 fe ff ff       	call   800ef2 <fd_lookup>
  801042:	85 c0                	test   %eax,%eax
  801044:	78 13                	js     801059 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801046:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80104d:	00 
  80104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801051:	89 04 24             	mov    %eax,(%esp)
  801054:	e8 49 ff ff ff       	call   800fa2 <fd_close>
}
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <close_all>:

void
close_all(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	53                   	push   %ebx
  80105f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801062:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801067:	89 1c 24             	mov    %ebx,(%esp)
  80106a:	e8 bb ff ff ff       	call   80102a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80106f:	43                   	inc    %ebx
  801070:	83 fb 20             	cmp    $0x20,%ebx
  801073:	75 f2                	jne    801067 <close_all+0xc>
		close(i);
}
  801075:	83 c4 14             	add    $0x14,%esp
  801078:	5b                   	pop    %ebx
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 4c             	sub    $0x4c,%esp
  801084:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801087:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108e:	8b 45 08             	mov    0x8(%ebp),%eax
  801091:	89 04 24             	mov    %eax,(%esp)
  801094:	e8 59 fe ff ff       	call   800ef2 <fd_lookup>
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	85 c0                	test   %eax,%eax
  80109d:	0f 88 e3 00 00 00    	js     801186 <dup+0x10b>
		return r;
	close(newfdnum);
  8010a3:	89 3c 24             	mov    %edi,(%esp)
  8010a6:	e8 7f ff ff ff       	call   80102a <close>

	newfd = INDEX2FD(newfdnum);
  8010ab:	89 fe                	mov    %edi,%esi
  8010ad:	c1 e6 0c             	shl    $0xc,%esi
  8010b0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b9:	89 04 24             	mov    %eax,(%esp)
  8010bc:	e8 c3 fd ff ff       	call   800e84 <fd2data>
  8010c1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010c3:	89 34 24             	mov    %esi,(%esp)
  8010c6:	e8 b9 fd ff ff       	call   800e84 <fd2data>
  8010cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ce:	89 d8                	mov    %ebx,%eax
  8010d0:	c1 e8 16             	shr    $0x16,%eax
  8010d3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010da:	a8 01                	test   $0x1,%al
  8010dc:	74 46                	je     801124 <dup+0xa9>
  8010de:	89 d8                	mov    %ebx,%eax
  8010e0:	c1 e8 0c             	shr    $0xc,%eax
  8010e3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ea:	f6 c2 01             	test   $0x1,%dl
  8010ed:	74 35                	je     801124 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801106:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80110d:	00 
  80110e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801119:	e8 6b fa ff ff       	call   800b89 <sys_page_map>
  80111e:	89 c3                	mov    %eax,%ebx
  801120:	85 c0                	test   %eax,%eax
  801122:	78 3b                	js     80115f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801124:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801127:	89 c2                	mov    %eax,%edx
  801129:	c1 ea 0c             	shr    $0xc,%edx
  80112c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801133:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801139:	89 54 24 10          	mov    %edx,0x10(%esp)
  80113d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801141:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801148:	00 
  801149:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801154:	e8 30 fa ff ff       	call   800b89 <sys_page_map>
  801159:	89 c3                	mov    %eax,%ebx
  80115b:	85 c0                	test   %eax,%eax
  80115d:	79 25                	jns    801184 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80115f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801163:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116a:	e8 6d fa ff ff       	call   800bdc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801172:	89 44 24 04          	mov    %eax,0x4(%esp)
  801176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117d:	e8 5a fa ff ff       	call   800bdc <sys_page_unmap>
	return r;
  801182:	eb 02                	jmp    801186 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801184:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801186:	89 d8                	mov    %ebx,%eax
  801188:	83 c4 4c             	add    $0x4c,%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	53                   	push   %ebx
  801194:	83 ec 24             	sub    $0x24,%esp
  801197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a1:	89 1c 24             	mov    %ebx,(%esp)
  8011a4:	e8 49 fd ff ff       	call   800ef2 <fd_lookup>
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	78 6d                	js     80121a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b7:	8b 00                	mov    (%eax),%eax
  8011b9:	89 04 24             	mov    %eax,(%esp)
  8011bc:	e8 87 fd ff ff       	call   800f48 <dev_lookup>
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 55                	js     80121a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c8:	8b 50 08             	mov    0x8(%eax),%edx
  8011cb:	83 e2 03             	and    $0x3,%edx
  8011ce:	83 fa 01             	cmp    $0x1,%edx
  8011d1:	75 23                	jne    8011f6 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d3:	a1 08 40 80 00       	mov    0x804008,%eax
  8011d8:	8b 40 48             	mov    0x48(%eax),%eax
  8011db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e3:	c7 04 24 d1 28 80 00 	movl   $0x8028d1,(%esp)
  8011ea:	e8 a9 ef ff ff       	call   800198 <cprintf>
		return -E_INVAL;
  8011ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f4:	eb 24                	jmp    80121a <read+0x8a>
	}
	if (!dev->dev_read)
  8011f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f9:	8b 52 08             	mov    0x8(%edx),%edx
  8011fc:	85 d2                	test   %edx,%edx
  8011fe:	74 15                	je     801215 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801200:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801203:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801207:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80120e:	89 04 24             	mov    %eax,(%esp)
  801211:	ff d2                	call   *%edx
  801213:	eb 05                	jmp    80121a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801215:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80121a:	83 c4 24             	add    $0x24,%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 1c             	sub    $0x1c,%esp
  801229:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801234:	eb 23                	jmp    801259 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801236:	89 f0                	mov    %esi,%eax
  801238:	29 d8                	sub    %ebx,%eax
  80123a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801241:	01 d8                	add    %ebx,%eax
  801243:	89 44 24 04          	mov    %eax,0x4(%esp)
  801247:	89 3c 24             	mov    %edi,(%esp)
  80124a:	e8 41 ff ff ff       	call   801190 <read>
		if (m < 0)
  80124f:	85 c0                	test   %eax,%eax
  801251:	78 10                	js     801263 <readn+0x43>
			return m;
		if (m == 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	74 0a                	je     801261 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801257:	01 c3                	add    %eax,%ebx
  801259:	39 f3                	cmp    %esi,%ebx
  80125b:	72 d9                	jb     801236 <readn+0x16>
  80125d:	89 d8                	mov    %ebx,%eax
  80125f:	eb 02                	jmp    801263 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801261:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801263:	83 c4 1c             	add    $0x1c,%esp
  801266:	5b                   	pop    %ebx
  801267:	5e                   	pop    %esi
  801268:	5f                   	pop    %edi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    

0080126b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	53                   	push   %ebx
  80126f:	83 ec 24             	sub    $0x24,%esp
  801272:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801275:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127c:	89 1c 24             	mov    %ebx,(%esp)
  80127f:	e8 6e fc ff ff       	call   800ef2 <fd_lookup>
  801284:	85 c0                	test   %eax,%eax
  801286:	78 68                	js     8012f0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801288:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801292:	8b 00                	mov    (%eax),%eax
  801294:	89 04 24             	mov    %eax,(%esp)
  801297:	e8 ac fc ff ff       	call   800f48 <dev_lookup>
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 50                	js     8012f0 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a7:	75 23                	jne    8012cc <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ae:	8b 40 48             	mov    0x48(%eax),%eax
  8012b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b9:	c7 04 24 ed 28 80 00 	movl   $0x8028ed,(%esp)
  8012c0:	e8 d3 ee ff ff       	call   800198 <cprintf>
		return -E_INVAL;
  8012c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ca:	eb 24                	jmp    8012f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8012d2:	85 d2                	test   %edx,%edx
  8012d4:	74 15                	je     8012eb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e4:	89 04 24             	mov    %eax,(%esp)
  8012e7:	ff d2                	call   *%edx
  8012e9:	eb 05                	jmp    8012f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012f0:	83 c4 24             	add    $0x24,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	89 04 24             	mov    %eax,(%esp)
  801309:	e8 e4 fb ff ff       	call   800ef2 <fd_lookup>
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 0e                	js     801320 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801312:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801315:	8b 55 0c             	mov    0xc(%ebp),%edx
  801318:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	53                   	push   %ebx
  801326:	83 ec 24             	sub    $0x24,%esp
  801329:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801333:	89 1c 24             	mov    %ebx,(%esp)
  801336:	e8 b7 fb ff ff       	call   800ef2 <fd_lookup>
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 61                	js     8013a0 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
  801346:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801349:	8b 00                	mov    (%eax),%eax
  80134b:	89 04 24             	mov    %eax,(%esp)
  80134e:	e8 f5 fb ff ff       	call   800f48 <dev_lookup>
  801353:	85 c0                	test   %eax,%eax
  801355:	78 49                	js     8013a0 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801357:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80135e:	75 23                	jne    801383 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801360:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801365:	8b 40 48             	mov    0x48(%eax),%eax
  801368:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80136c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801370:	c7 04 24 b0 28 80 00 	movl   $0x8028b0,(%esp)
  801377:	e8 1c ee ff ff       	call   800198 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80137c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801381:	eb 1d                	jmp    8013a0 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801383:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801386:	8b 52 18             	mov    0x18(%edx),%edx
  801389:	85 d2                	test   %edx,%edx
  80138b:	74 0e                	je     80139b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80138d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801390:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801394:	89 04 24             	mov    %eax,(%esp)
  801397:	ff d2                	call   *%edx
  801399:	eb 05                	jmp    8013a0 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80139b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013a0:	83 c4 24             	add    $0x24,%esp
  8013a3:	5b                   	pop    %ebx
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 24             	sub    $0x24,%esp
  8013ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	e8 30 fb ff ff       	call   800ef2 <fd_lookup>
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 52                	js     801418 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d0:	8b 00                	mov    (%eax),%eax
  8013d2:	89 04 24             	mov    %eax,(%esp)
  8013d5:	e8 6e fb ff ff       	call   800f48 <dev_lookup>
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 3a                	js     801418 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8013de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e5:	74 2c                	je     801413 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f1:	00 00 00 
	stat->st_isdir = 0;
  8013f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013fb:	00 00 00 
	stat->st_dev = dev;
  8013fe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801404:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801408:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80140b:	89 14 24             	mov    %edx,(%esp)
  80140e:	ff 50 14             	call   *0x14(%eax)
  801411:	eb 05                	jmp    801418 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801413:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801418:	83 c4 24             	add    $0x24,%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
  801423:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801426:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80142d:	00 
  80142e:	8b 45 08             	mov    0x8(%ebp),%eax
  801431:	89 04 24             	mov    %eax,(%esp)
  801434:	e8 2a 02 00 00       	call   801663 <open>
  801439:	89 c3                	mov    %eax,%ebx
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 1b                	js     80145a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80143f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801442:	89 44 24 04          	mov    %eax,0x4(%esp)
  801446:	89 1c 24             	mov    %ebx,(%esp)
  801449:	e8 58 ff ff ff       	call   8013a6 <fstat>
  80144e:	89 c6                	mov    %eax,%esi
	close(fd);
  801450:	89 1c 24             	mov    %ebx,(%esp)
  801453:	e8 d2 fb ff ff       	call   80102a <close>
	return r;
  801458:	89 f3                	mov    %esi,%ebx
}
  80145a:	89 d8                	mov    %ebx,%eax
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	5b                   	pop    %ebx
  801460:	5e                   	pop    %esi
  801461:	5d                   	pop    %ebp
  801462:	c3                   	ret    
	...

00801464 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	56                   	push   %esi
  801468:	53                   	push   %ebx
  801469:	83 ec 10             	sub    $0x10,%esp
  80146c:	89 c3                	mov    %eax,%ebx
  80146e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801470:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801477:	75 11                	jne    80148a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801479:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801480:	e8 de 0d 00 00       	call   802263 <ipc_find_env>
  801485:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80148a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801491:	00 
  801492:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801499:	00 
  80149a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80149e:	a1 00 40 80 00       	mov    0x804000,%eax
  8014a3:	89 04 24             	mov    %eax,(%esp)
  8014a6:	e8 35 0d 00 00       	call   8021e0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b2:	00 
  8014b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014be:	e8 ad 0c 00 00       	call   802170 <ipc_recv>
}
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	5b                   	pop    %ebx
  8014c7:	5e                   	pop    %esi
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014de:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8014ed:	e8 72 ff ff ff       	call   801464 <fsipc>
}
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801500:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801505:	ba 00 00 00 00       	mov    $0x0,%edx
  80150a:	b8 06 00 00 00       	mov    $0x6,%eax
  80150f:	e8 50 ff ff ff       	call   801464 <fsipc>
}
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	53                   	push   %ebx
  80151a:	83 ec 14             	sub    $0x14,%esp
  80151d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
  801523:	8b 40 0c             	mov    0xc(%eax),%eax
  801526:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80152b:	ba 00 00 00 00       	mov    $0x0,%edx
  801530:	b8 05 00 00 00       	mov    $0x5,%eax
  801535:	e8 2a ff ff ff       	call   801464 <fsipc>
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 2b                	js     801569 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80153e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801545:	00 
  801546:	89 1c 24             	mov    %ebx,(%esp)
  801549:	e8 f5 f1 ff ff       	call   800743 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80154e:	a1 80 50 80 00       	mov    0x805080,%eax
  801553:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801559:	a1 84 50 80 00       	mov    0x805084,%eax
  80155e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801564:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801569:	83 c4 14             	add    $0x14,%esp
  80156c:	5b                   	pop    %ebx
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    

0080156f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	83 ec 18             	sub    $0x18,%esp
  801575:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801578:	8b 55 08             	mov    0x8(%ebp),%edx
  80157b:	8b 52 0c             	mov    0xc(%edx),%edx
  80157e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801584:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801589:	89 c2                	mov    %eax,%edx
  80158b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801590:	76 05                	jbe    801597 <devfile_write+0x28>
  801592:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801597:	89 54 24 08          	mov    %edx,0x8(%esp)
  80159b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8015a9:	e8 78 f3 ff ff       	call   800926 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8015ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8015b8:	e8 a7 fe ff ff       	call   801464 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	56                   	push   %esi
  8015c3:	53                   	push   %ebx
  8015c4:	83 ec 10             	sub    $0x10,%esp
  8015c7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015d5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015db:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8015e5:	e8 7a fe ff ff       	call   801464 <fsipc>
  8015ea:	89 c3                	mov    %eax,%ebx
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 6a                	js     80165a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8015f0:	39 c6                	cmp    %eax,%esi
  8015f2:	73 24                	jae    801618 <devfile_read+0x59>
  8015f4:	c7 44 24 0c 20 29 80 	movl   $0x802920,0xc(%esp)
  8015fb:	00 
  8015fc:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  801603:	00 
  801604:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80160b:	00 
  80160c:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  801613:	e8 00 0b 00 00       	call   802118 <_panic>
	assert(r <= PGSIZE);
  801618:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80161d:	7e 24                	jle    801643 <devfile_read+0x84>
  80161f:	c7 44 24 0c 47 29 80 	movl   $0x802947,0xc(%esp)
  801626:	00 
  801627:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  80162e:	00 
  80162f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801636:	00 
  801637:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  80163e:	e8 d5 0a 00 00       	call   802118 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801643:	89 44 24 08          	mov    %eax,0x8(%esp)
  801647:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80164e:	00 
  80164f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 62 f2 ff ff       	call   8008bc <memmove>
	return r;
}
  80165a:	89 d8                	mov    %ebx,%eax
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	5d                   	pop    %ebp
  801662:	c3                   	ret    

00801663 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
  801668:	83 ec 20             	sub    $0x20,%esp
  80166b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80166e:	89 34 24             	mov    %esi,(%esp)
  801671:	e8 9a f0 ff ff       	call   800710 <strlen>
  801676:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80167b:	7f 60                	jg     8016dd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80167d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801680:	89 04 24             	mov    %eax,(%esp)
  801683:	e8 17 f8 ff ff       	call   800e9f <fd_alloc>
  801688:	89 c3                	mov    %eax,%ebx
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 54                	js     8016e2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80168e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801692:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801699:	e8 a5 f0 ff ff       	call   800743 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80169e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8016ae:	e8 b1 fd ff ff       	call   801464 <fsipc>
  8016b3:	89 c3                	mov    %eax,%ebx
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	79 15                	jns    8016ce <open+0x6b>
		fd_close(fd, 0);
  8016b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016c0:	00 
  8016c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c4:	89 04 24             	mov    %eax,(%esp)
  8016c7:	e8 d6 f8 ff ff       	call   800fa2 <fd_close>
		return r;
  8016cc:	eb 14                	jmp    8016e2 <open+0x7f>
	}

	return fd2num(fd);
  8016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d1:	89 04 24             	mov    %eax,(%esp)
  8016d4:	e8 9b f7 ff ff       	call   800e74 <fd2num>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	eb 05                	jmp    8016e2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016dd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016e2:	89 d8                	mov    %ebx,%eax
  8016e4:	83 c4 20             	add    $0x20,%esp
  8016e7:	5b                   	pop    %ebx
  8016e8:	5e                   	pop    %esi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8016fb:	e8 64 fd ff ff       	call   801464 <fsipc>
}
  801700:	c9                   	leave  
  801701:	c3                   	ret    
	...

00801704 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  80170a:	c7 44 24 04 53 29 80 	movl   $0x802953,0x4(%esp)
  801711:	00 
  801712:	8b 45 0c             	mov    0xc(%ebp),%eax
  801715:	89 04 24             	mov    %eax,(%esp)
  801718:	e8 26 f0 ff ff       	call   800743 <strcpy>
	return 0;
}
  80171d:	b8 00 00 00 00       	mov    $0x0,%eax
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	53                   	push   %ebx
  801728:	83 ec 14             	sub    $0x14,%esp
  80172b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80172e:	89 1c 24             	mov    %ebx,(%esp)
  801731:	e8 72 0b 00 00       	call   8022a8 <pageref>
  801736:	83 f8 01             	cmp    $0x1,%eax
  801739:	75 0d                	jne    801748 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80173b:	8b 43 0c             	mov    0xc(%ebx),%eax
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	e8 1f 03 00 00       	call   801a65 <nsipc_close>
  801746:	eb 05                	jmp    80174d <devsock_close+0x29>
	else
		return 0;
  801748:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174d:	83 c4 14             	add    $0x14,%esp
  801750:	5b                   	pop    %ebx
  801751:	5d                   	pop    %ebp
  801752:	c3                   	ret    

00801753 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801759:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801760:	00 
  801761:	8b 45 10             	mov    0x10(%ebp),%eax
  801764:	89 44 24 08          	mov    %eax,0x8(%esp)
  801768:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
  801772:	8b 40 0c             	mov    0xc(%eax),%eax
  801775:	89 04 24             	mov    %eax,(%esp)
  801778:	e8 e3 03 00 00       	call   801b60 <nsipc_send>
}
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801785:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80178c:	00 
  80178d:	8b 45 10             	mov    0x10(%ebp),%eax
  801790:	89 44 24 08          	mov    %eax,0x8(%esp)
  801794:	8b 45 0c             	mov    0xc(%ebp),%eax
  801797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179b:	8b 45 08             	mov    0x8(%ebp),%eax
  80179e:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a1:	89 04 24             	mov    %eax,(%esp)
  8017a4:	e8 37 03 00 00       	call   801ae0 <nsipc_recv>
}
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
  8017b0:	83 ec 20             	sub    $0x20,%esp
  8017b3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8017b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b8:	89 04 24             	mov    %eax,(%esp)
  8017bb:	e8 df f6 ff ff       	call   800e9f <fd_alloc>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 21                	js     8017e7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017c6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8017cd:	00 
  8017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017dc:	e8 54 f3 ff ff       	call   800b35 <sys_page_alloc>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	79 0a                	jns    8017f1 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8017e7:	89 34 24             	mov    %esi,(%esp)
  8017ea:	e8 76 02 00 00       	call   801a65 <nsipc_close>
		return r;
  8017ef:	eb 22                	jmp    801813 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8017f1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fa:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801806:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801809:	89 04 24             	mov    %eax,(%esp)
  80180c:	e8 63 f6 ff ff       	call   800e74 <fd2num>
  801811:	89 c3                	mov    %eax,%ebx
}
  801813:	89 d8                	mov    %ebx,%eax
  801815:	83 c4 20             	add    $0x20,%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801822:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801825:	89 54 24 04          	mov    %edx,0x4(%esp)
  801829:	89 04 24             	mov    %eax,(%esp)
  80182c:	e8 c1 f6 ff ff       	call   800ef2 <fd_lookup>
  801831:	85 c0                	test   %eax,%eax
  801833:	78 17                	js     80184c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801835:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801838:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80183e:	39 10                	cmp    %edx,(%eax)
  801840:	75 05                	jne    801847 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801842:	8b 40 0c             	mov    0xc(%eax),%eax
  801845:	eb 05                	jmp    80184c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801847:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80184c:	c9                   	leave  
  80184d:	c3                   	ret    

0080184e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	e8 c0 ff ff ff       	call   80181c <fd2sockid>
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 1f                	js     80187f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801860:	8b 55 10             	mov    0x10(%ebp),%edx
  801863:	89 54 24 08          	mov    %edx,0x8(%esp)
  801867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80186a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	e8 38 01 00 00       	call   8019ae <nsipc_accept>
  801876:	85 c0                	test   %eax,%eax
  801878:	78 05                	js     80187f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80187a:	e8 2c ff ff ff       	call   8017ab <alloc_sockfd>
}
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	e8 8d ff ff ff       	call   80181c <fd2sockid>
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 16                	js     8018a9 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801893:	8b 55 10             	mov    0x10(%ebp),%edx
  801896:	89 54 24 08          	mov    %edx,0x8(%esp)
  80189a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018a1:	89 04 24             	mov    %eax,(%esp)
  8018a4:	e8 5b 01 00 00       	call   801a04 <nsipc_bind>
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <shutdown>:

int
shutdown(int s, int how)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	e8 63 ff ff ff       	call   80181c <fd2sockid>
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 0f                	js     8018cc <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8018bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018c4:	89 04 24             	mov    %eax,(%esp)
  8018c7:	e8 77 01 00 00       	call   801a43 <nsipc_shutdown>
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	e8 40 ff ff ff       	call   80181c <fd2sockid>
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 16                	js     8018f6 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8018e0:	8b 55 10             	mov    0x10(%ebp),%edx
  8018e3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018ee:	89 04 24             	mov    %eax,(%esp)
  8018f1:	e8 89 01 00 00       	call   801a7f <nsipc_connect>
}
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <listen>:

int
listen(int s, int backlog)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	e8 16 ff ff ff       	call   80181c <fd2sockid>
  801906:	85 c0                	test   %eax,%eax
  801908:	78 0f                	js     801919 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80190a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801911:	89 04 24             	mov    %eax,(%esp)
  801914:	e8 a5 01 00 00       	call   801abe <nsipc_listen>
}
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801921:	8b 45 10             	mov    0x10(%ebp),%eax
  801924:	89 44 24 08          	mov    %eax,0x8(%esp)
  801928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	89 04 24             	mov    %eax,(%esp)
  801935:	e8 99 02 00 00       	call   801bd3 <nsipc_socket>
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 05                	js     801943 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  80193e:	e8 68 fe ff ff       	call   8017ab <alloc_sockfd>
}
  801943:	c9                   	leave  
  801944:	c3                   	ret    
  801945:	00 00                	add    %al,(%eax)
	...

00801948 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	53                   	push   %ebx
  80194c:	83 ec 14             	sub    $0x14,%esp
  80194f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801951:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801958:	75 11                	jne    80196b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80195a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801961:	e8 fd 08 00 00       	call   802263 <ipc_find_env>
  801966:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80196b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801972:	00 
  801973:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80197a:	00 
  80197b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197f:	a1 04 40 80 00       	mov    0x804004,%eax
  801984:	89 04 24             	mov    %eax,(%esp)
  801987:	e8 54 08 00 00       	call   8021e0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80198c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801993:	00 
  801994:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80199b:	00 
  80199c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a3:	e8 c8 07 00 00       	call   802170 <ipc_recv>
}
  8019a8:	83 c4 14             	add    $0x14,%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5d                   	pop    %ebp
  8019ad:	c3                   	ret    

008019ae <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	56                   	push   %esi
  8019b2:	53                   	push   %ebx
  8019b3:	83 ec 10             	sub    $0x10,%esp
  8019b6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8019c1:	8b 06                	mov    (%esi),%eax
  8019c3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8019c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cd:	e8 76 ff ff ff       	call   801948 <nsipc>
  8019d2:	89 c3                	mov    %eax,%ebx
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 23                	js     8019fb <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8019d8:	a1 10 60 80 00       	mov    0x806010,%eax
  8019dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019e1:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8019e8:	00 
  8019e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ec:	89 04 24             	mov    %eax,(%esp)
  8019ef:	e8 c8 ee ff ff       	call   8008bc <memmove>
		*addrlen = ret->ret_addrlen;
  8019f4:	a1 10 60 80 00       	mov    0x806010,%eax
  8019f9:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8019fb:	89 d8                	mov    %ebx,%eax
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	5b                   	pop    %ebx
  801a01:	5e                   	pop    %esi
  801a02:	5d                   	pop    %ebp
  801a03:	c3                   	ret    

00801a04 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	53                   	push   %ebx
  801a08:	83 ec 14             	sub    $0x14,%esp
  801a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a11:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a16:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801a28:	e8 8f ee ff ff       	call   8008bc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a2d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a33:	b8 02 00 00 00       	mov    $0x2,%eax
  801a38:	e8 0b ff ff ff       	call   801948 <nsipc>
}
  801a3d:	83 c4 14             	add    $0x14,%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    

00801a43 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a54:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801a59:	b8 03 00 00 00       	mov    $0x3,%eax
  801a5e:	e8 e5 fe ff ff       	call   801948 <nsipc>
}
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <nsipc_close>:

int
nsipc_close(int s)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801a73:	b8 04 00 00 00       	mov    $0x4,%eax
  801a78:	e8 cb fe ff ff       	call   801948 <nsipc>
}
  801a7d:	c9                   	leave  
  801a7e:	c3                   	ret    

00801a7f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	53                   	push   %ebx
  801a83:	83 ec 14             	sub    $0x14,%esp
  801a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a89:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801aa3:	e8 14 ee ff ff       	call   8008bc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801aa8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801aae:	b8 05 00 00 00       	mov    $0x5,%eax
  801ab3:	e8 90 fe ff ff       	call   801948 <nsipc>
}
  801ab8:	83 c4 14             	add    $0x14,%esp
  801abb:	5b                   	pop    %ebx
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ad4:	b8 06 00 00 00       	mov    $0x6,%eax
  801ad9:	e8 6a fe ff ff       	call   801948 <nsipc>
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 10             	sub    $0x10,%esp
  801ae8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801af3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801af9:	8b 45 14             	mov    0x14(%ebp),%eax
  801afc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b01:	b8 07 00 00 00       	mov    $0x7,%eax
  801b06:	e8 3d fe ff ff       	call   801948 <nsipc>
  801b0b:	89 c3                	mov    %eax,%ebx
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 46                	js     801b57 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801b11:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b16:	7f 04                	jg     801b1c <nsipc_recv+0x3c>
  801b18:	39 c6                	cmp    %eax,%esi
  801b1a:	7d 24                	jge    801b40 <nsipc_recv+0x60>
  801b1c:	c7 44 24 0c 5f 29 80 	movl   $0x80295f,0xc(%esp)
  801b23:	00 
  801b24:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  801b2b:	00 
  801b2c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801b33:	00 
  801b34:	c7 04 24 74 29 80 00 	movl   $0x802974,(%esp)
  801b3b:	e8 d8 05 00 00       	call   802118 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b44:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b4b:	00 
  801b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4f:	89 04 24             	mov    %eax,(%esp)
  801b52:	e8 65 ed ff ff       	call   8008bc <memmove>
	}

	return r;
}
  801b57:	89 d8                	mov    %ebx,%eax
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	5b                   	pop    %ebx
  801b5d:	5e                   	pop    %esi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	53                   	push   %ebx
  801b64:	83 ec 14             	sub    $0x14,%esp
  801b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801b72:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b78:	7e 24                	jle    801b9e <nsipc_send+0x3e>
  801b7a:	c7 44 24 0c 80 29 80 	movl   $0x802980,0xc(%esp)
  801b81:	00 
  801b82:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  801b89:	00 
  801b8a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801b91:	00 
  801b92:	c7 04 24 74 29 80 00 	movl   $0x802974,(%esp)
  801b99:	e8 7a 05 00 00       	call   802118 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba9:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801bb0:	e8 07 ed ff ff       	call   8008bc <memmove>
	nsipcbuf.send.req_size = size;
  801bb5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801bbb:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801bc3:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc8:	e8 7b fd ff ff       	call   801948 <nsipc>
}
  801bcd:	83 c4 14             	add    $0x14,%esp
  801bd0:	5b                   	pop    %ebx
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801be9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bec:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801bf1:	b8 09 00 00 00       	mov    $0x9,%eax
  801bf6:	e8 4d fd ff ff       	call   801948 <nsipc>
}
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    
  801bfd:	00 00                	add    %al,(%eax)
	...

00801c00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	83 ec 10             	sub    $0x10,%esp
  801c08:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0e:	89 04 24             	mov    %eax,(%esp)
  801c11:	e8 6e f2 ff ff       	call   800e84 <fd2data>
  801c16:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c18:	c7 44 24 04 8c 29 80 	movl   $0x80298c,0x4(%esp)
  801c1f:	00 
  801c20:	89 34 24             	mov    %esi,(%esp)
  801c23:	e8 1b eb ff ff       	call   800743 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c28:	8b 43 04             	mov    0x4(%ebx),%eax
  801c2b:	2b 03                	sub    (%ebx),%eax
  801c2d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c33:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c3a:	00 00 00 
	stat->st_dev = &devpipe;
  801c3d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801c44:	30 80 00 
	return 0;
}
  801c47:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	53                   	push   %ebx
  801c57:	83 ec 14             	sub    $0x14,%esp
  801c5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c68:	e8 6f ef ff ff       	call   800bdc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c6d:	89 1c 24             	mov    %ebx,(%esp)
  801c70:	e8 0f f2 ff ff       	call   800e84 <fd2data>
  801c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c80:	e8 57 ef ff ff       	call   800bdc <sys_page_unmap>
}
  801c85:	83 c4 14             	add    $0x14,%esp
  801c88:	5b                   	pop    %ebx
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	57                   	push   %edi
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	83 ec 2c             	sub    $0x2c,%esp
  801c94:	89 c7                	mov    %eax,%edi
  801c96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c99:	a1 08 40 80 00       	mov    0x804008,%eax
  801c9e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ca1:	89 3c 24             	mov    %edi,(%esp)
  801ca4:	e8 ff 05 00 00       	call   8022a8 <pageref>
  801ca9:	89 c6                	mov    %eax,%esi
  801cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cae:	89 04 24             	mov    %eax,(%esp)
  801cb1:	e8 f2 05 00 00       	call   8022a8 <pageref>
  801cb6:	39 c6                	cmp    %eax,%esi
  801cb8:	0f 94 c0             	sete   %al
  801cbb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cbe:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801cc4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cc7:	39 cb                	cmp    %ecx,%ebx
  801cc9:	75 08                	jne    801cd3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ccb:	83 c4 2c             	add    $0x2c,%esp
  801cce:	5b                   	pop    %ebx
  801ccf:	5e                   	pop    %esi
  801cd0:	5f                   	pop    %edi
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801cd3:	83 f8 01             	cmp    $0x1,%eax
  801cd6:	75 c1                	jne    801c99 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cd8:	8b 42 58             	mov    0x58(%edx),%eax
  801cdb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801ce2:	00 
  801ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ceb:	c7 04 24 93 29 80 00 	movl   $0x802993,(%esp)
  801cf2:	e8 a1 e4 ff ff       	call   800198 <cprintf>
  801cf7:	eb a0                	jmp    801c99 <_pipeisclosed+0xe>

00801cf9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	57                   	push   %edi
  801cfd:	56                   	push   %esi
  801cfe:	53                   	push   %ebx
  801cff:	83 ec 1c             	sub    $0x1c,%esp
  801d02:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d05:	89 34 24             	mov    %esi,(%esp)
  801d08:	e8 77 f1 ff ff       	call   800e84 <fd2data>
  801d0d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d14:	eb 3c                	jmp    801d52 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d16:	89 da                	mov    %ebx,%edx
  801d18:	89 f0                	mov    %esi,%eax
  801d1a:	e8 6c ff ff ff       	call   801c8b <_pipeisclosed>
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	75 38                	jne    801d5b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d23:	e8 ee ed ff ff       	call   800b16 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d28:	8b 43 04             	mov    0x4(%ebx),%eax
  801d2b:	8b 13                	mov    (%ebx),%edx
  801d2d:	83 c2 20             	add    $0x20,%edx
  801d30:	39 d0                	cmp    %edx,%eax
  801d32:	73 e2                	jae    801d16 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d37:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d3a:	89 c2                	mov    %eax,%edx
  801d3c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d42:	79 05                	jns    801d49 <devpipe_write+0x50>
  801d44:	4a                   	dec    %edx
  801d45:	83 ca e0             	or     $0xffffffe0,%edx
  801d48:	42                   	inc    %edx
  801d49:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d4d:	40                   	inc    %eax
  801d4e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d51:	47                   	inc    %edi
  801d52:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d55:	75 d1                	jne    801d28 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d57:	89 f8                	mov    %edi,%eax
  801d59:	eb 05                	jmp    801d60 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d5b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d60:	83 c4 1c             	add    $0x1c,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    

00801d68 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	57                   	push   %edi
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	83 ec 1c             	sub    $0x1c,%esp
  801d71:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d74:	89 3c 24             	mov    %edi,(%esp)
  801d77:	e8 08 f1 ff ff       	call   800e84 <fd2data>
  801d7c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7e:	be 00 00 00 00       	mov    $0x0,%esi
  801d83:	eb 3a                	jmp    801dbf <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d85:	85 f6                	test   %esi,%esi
  801d87:	74 04                	je     801d8d <devpipe_read+0x25>
				return i;
  801d89:	89 f0                	mov    %esi,%eax
  801d8b:	eb 40                	jmp    801dcd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d8d:	89 da                	mov    %ebx,%edx
  801d8f:	89 f8                	mov    %edi,%eax
  801d91:	e8 f5 fe ff ff       	call   801c8b <_pipeisclosed>
  801d96:	85 c0                	test   %eax,%eax
  801d98:	75 2e                	jne    801dc8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d9a:	e8 77 ed ff ff       	call   800b16 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d9f:	8b 03                	mov    (%ebx),%eax
  801da1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801da4:	74 df                	je     801d85 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801da6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801dab:	79 05                	jns    801db2 <devpipe_read+0x4a>
  801dad:	48                   	dec    %eax
  801dae:	83 c8 e0             	or     $0xffffffe0,%eax
  801db1:	40                   	inc    %eax
  801db2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801db6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dbc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dbe:	46                   	inc    %esi
  801dbf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc2:	75 db                	jne    801d9f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dc4:	89 f0                	mov    %esi,%eax
  801dc6:	eb 05                	jmp    801dcd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dc8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dcd:	83 c4 1c             	add    $0x1c,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	57                   	push   %edi
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	83 ec 3c             	sub    $0x3c,%esp
  801dde:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801de1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801de4:	89 04 24             	mov    %eax,(%esp)
  801de7:	e8 b3 f0 ff ff       	call   800e9f <fd_alloc>
  801dec:	89 c3                	mov    %eax,%ebx
  801dee:	85 c0                	test   %eax,%eax
  801df0:	0f 88 45 01 00 00    	js     801f3b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dfd:	00 
  801dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0c:	e8 24 ed ff ff       	call   800b35 <sys_page_alloc>
  801e11:	89 c3                	mov    %eax,%ebx
  801e13:	85 c0                	test   %eax,%eax
  801e15:	0f 88 20 01 00 00    	js     801f3b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e1b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e1e:	89 04 24             	mov    %eax,(%esp)
  801e21:	e8 79 f0 ff ff       	call   800e9f <fd_alloc>
  801e26:	89 c3                	mov    %eax,%ebx
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	0f 88 f8 00 00 00    	js     801f28 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e30:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e37:	00 
  801e38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e46:	e8 ea ec ff ff       	call   800b35 <sys_page_alloc>
  801e4b:	89 c3                	mov    %eax,%ebx
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	0f 88 d3 00 00 00    	js     801f28 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e58:	89 04 24             	mov    %eax,(%esp)
  801e5b:	e8 24 f0 ff ff       	call   800e84 <fd2data>
  801e60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e62:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e69:	00 
  801e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e75:	e8 bb ec ff ff       	call   800b35 <sys_page_alloc>
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	0f 88 91 00 00 00    	js     801f15 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e87:	89 04 24             	mov    %eax,(%esp)
  801e8a:	e8 f5 ef ff ff       	call   800e84 <fd2data>
  801e8f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e96:	00 
  801e97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ea2:	00 
  801ea3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eae:	e8 d6 ec ff ff       	call   800b89 <sys_page_map>
  801eb3:	89 c3                	mov    %eax,%ebx
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	78 4c                	js     801f05 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801eb9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ebf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ece:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ed7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ed9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801edc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 86 ef ff ff       	call   800e74 <fd2num>
  801eee:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef3:	89 04 24             	mov    %eax,(%esp)
  801ef6:	e8 79 ef ff ff       	call   800e74 <fd2num>
  801efb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801efe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f03:	eb 36                	jmp    801f3b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f05:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f10:	e8 c7 ec ff ff       	call   800bdc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f23:	e8 b4 ec ff ff       	call   800bdc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f36:	e8 a1 ec ff ff       	call   800bdc <sys_page_unmap>
    err:
	return r;
}
  801f3b:	89 d8                	mov    %ebx,%eax
  801f3d:	83 c4 3c             	add    $0x3c,%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5f                   	pop    %edi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    

00801f45 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f52:	8b 45 08             	mov    0x8(%ebp),%eax
  801f55:	89 04 24             	mov    %eax,(%esp)
  801f58:	e8 95 ef ff ff       	call   800ef2 <fd_lookup>
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 15                	js     801f76 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f64:	89 04 24             	mov    %eax,(%esp)
  801f67:	e8 18 ef ff ff       	call   800e84 <fd2data>
	return _pipeisclosed(fd, p);
  801f6c:	89 c2                	mov    %eax,%edx
  801f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f71:	e8 15 fd ff ff       	call   801c8b <_pipeisclosed>
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    

00801f82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f88:	c7 44 24 04 ab 29 80 	movl   $0x8029ab,0x4(%esp)
  801f8f:	00 
  801f90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f93:	89 04 24             	mov    %eax,(%esp)
  801f96:	e8 a8 e7 ff ff       	call   800743 <strcpy>
	return 0;
}
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	57                   	push   %edi
  801fa6:	56                   	push   %esi
  801fa7:	53                   	push   %ebx
  801fa8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fae:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fb3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb9:	eb 30                	jmp    801feb <devcons_write+0x49>
		m = n - tot;
  801fbb:	8b 75 10             	mov    0x10(%ebp),%esi
  801fbe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fc0:	83 fe 7f             	cmp    $0x7f,%esi
  801fc3:	76 05                	jbe    801fca <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801fc5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fca:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fce:	03 45 0c             	add    0xc(%ebp),%eax
  801fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd5:	89 3c 24             	mov    %edi,(%esp)
  801fd8:	e8 df e8 ff ff       	call   8008bc <memmove>
		sys_cputs(buf, m);
  801fdd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe1:	89 3c 24             	mov    %edi,(%esp)
  801fe4:	e8 7f ea ff ff       	call   800a68 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe9:	01 f3                	add    %esi,%ebx
  801feb:	89 d8                	mov    %ebx,%eax
  801fed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ff0:	72 c9                	jb     801fbb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ff2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    

00801ffd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802003:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802007:	75 07                	jne    802010 <devcons_read+0x13>
  802009:	eb 25                	jmp    802030 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80200b:	e8 06 eb ff ff       	call   800b16 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802010:	e8 71 ea ff ff       	call   800a86 <sys_cgetc>
  802015:	85 c0                	test   %eax,%eax
  802017:	74 f2                	je     80200b <devcons_read+0xe>
  802019:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80201b:	85 c0                	test   %eax,%eax
  80201d:	78 1d                	js     80203c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80201f:	83 f8 04             	cmp    $0x4,%eax
  802022:	74 13                	je     802037 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802024:	8b 45 0c             	mov    0xc(%ebp),%eax
  802027:	88 10                	mov    %dl,(%eax)
	return 1;
  802029:	b8 01 00 00 00       	mov    $0x1,%eax
  80202e:	eb 0c                	jmp    80203c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802030:	b8 00 00 00 00       	mov    $0x0,%eax
  802035:	eb 05                	jmp    80203c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802044:	8b 45 08             	mov    0x8(%ebp),%eax
  802047:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80204a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802051:	00 
  802052:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 0b ea ff ff       	call   800a68 <sys_cputs>
}
  80205d:	c9                   	leave  
  80205e:	c3                   	ret    

0080205f <getchar>:

int
getchar(void)
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802065:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80206c:	00 
  80206d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802070:	89 44 24 04          	mov    %eax,0x4(%esp)
  802074:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207b:	e8 10 f1 ff ff       	call   801190 <read>
	if (r < 0)
  802080:	85 c0                	test   %eax,%eax
  802082:	78 0f                	js     802093 <getchar+0x34>
		return r;
	if (r < 1)
  802084:	85 c0                	test   %eax,%eax
  802086:	7e 06                	jle    80208e <getchar+0x2f>
		return -E_EOF;
	return c;
  802088:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80208c:	eb 05                	jmp    802093 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80208e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802093:	c9                   	leave  
  802094:	c3                   	ret    

00802095 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80209b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a5:	89 04 24             	mov    %eax,(%esp)
  8020a8:	e8 45 ee ff ff       	call   800ef2 <fd_lookup>
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	78 11                	js     8020c2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020ba:	39 10                	cmp    %edx,(%eax)
  8020bc:	0f 94 c0             	sete   %al
  8020bf:	0f b6 c0             	movzbl %al,%eax
}
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    

008020c4 <opencons>:

int
opencons(void)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cd:	89 04 24             	mov    %eax,(%esp)
  8020d0:	e8 ca ed ff ff       	call   800e9f <fd_alloc>
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	78 3c                	js     802115 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020d9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020e0:	00 
  8020e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ef:	e8 41 ea ff ff       	call   800b35 <sys_page_alloc>
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	78 1d                	js     802115 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020f8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802101:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802103:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802106:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80210d:	89 04 24             	mov    %eax,(%esp)
  802110:	e8 5f ed ff ff       	call   800e74 <fd2num>
}
  802115:	c9                   	leave  
  802116:	c3                   	ret    
	...

00802118 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	56                   	push   %esi
  80211c:	53                   	push   %ebx
  80211d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802120:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802123:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802129:	e8 c9 e9 ff ff       	call   800af7 <sys_getenvid>
  80212e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802131:	89 54 24 10          	mov    %edx,0x10(%esp)
  802135:	8b 55 08             	mov    0x8(%ebp),%edx
  802138:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80213c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802140:	89 44 24 04          	mov    %eax,0x4(%esp)
  802144:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  80214b:	e8 48 e0 ff ff       	call   800198 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802150:	89 74 24 04          	mov    %esi,0x4(%esp)
  802154:	8b 45 10             	mov    0x10(%ebp),%eax
  802157:	89 04 24             	mov    %eax,(%esp)
  80215a:	e8 d8 df ff ff       	call   800137 <vcprintf>
	cprintf("\n");
  80215f:	c7 04 24 a4 29 80 00 	movl   $0x8029a4,(%esp)
  802166:	e8 2d e0 ff ff       	call   800198 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80216b:	cc                   	int3   
  80216c:	eb fd                	jmp    80216b <_panic+0x53>
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
  802188:	e8 be eb ff ff       	call   800d4b <sys_ipc_recv>
  80218d:	eb 0c                	jmp    80219b <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80218f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802196:	e8 b0 eb ff ff       	call   800d4b <sys_ipc_recv>
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
  8021b9:	a1 08 40 80 00       	mov    0x804008,%eax
  8021be:	8b 40 74             	mov    0x74(%eax),%eax
  8021c1:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8021c3:	85 f6                	test   %esi,%esi
  8021c5:	74 0a                	je     8021d1 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8021c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8021cc:	8b 40 78             	mov    0x78(%eax),%eax
  8021cf:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8021d1:	a1 08 40 80 00       	mov    0x804008,%eax
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
  802208:	e8 1b eb ff ff       	call   800d28 <sys_ipc_try_send>
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
  802226:	e8 fd ea ff ff       	call   800d28 <sys_ipc_try_send>
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
  802238:	c7 44 24 08 dc 29 80 	movl   $0x8029dc,0x8(%esp)
  80223f:	00 
  802240:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802247:	00 
  802248:	c7 04 24 ef 29 80 00 	movl   $0x8029ef,(%esp)
  80224f:	e8 c4 fe ff ff       	call   802118 <_panic>
		}
		sys_yield();
  802254:	e8 bd e8 ff ff       	call   800b16 <sys_yield>
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
