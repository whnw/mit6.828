
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	c7 04 24 20 29 80 00 	movl   $0x802920,(%esp)
  800042:	e8 79 01 00 00       	call   8001c0 <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 b3 0e 00 00       	call   800eff <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  800059:	e8 62 01 00 00       	call   8001c0 <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 48 29 80 00 	movl   $0x802948,(%esp)
  800067:	e8 54 01 00 00       	call   8001c0 <cprintf>
	sys_yield();
  80006c:	e8 cd 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  800071:	e8 c8 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  800076:	e8 c3 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  80007b:	e8 be 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  800080:	e8 b9 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  800085:	e8 b4 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  80008a:	e8 af 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  80008f:	e8 aa 0a 00 00       	call   800b3e <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 70 29 80 00 	movl   $0x802970,(%esp)
  80009b:	e8 20 01 00 00       	call   8001c0 <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 25 0a 00 00       	call   800acd <sys_env_destroy>
}
  8000a8:	83 c4 14             	add    $0x14,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
	...

008000b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 10             	sub    $0x10,%esp
  8000b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000be:	e8 5c 0a 00 00       	call   800b1f <sys_getenvid>
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000cf:	c1 e0 07             	shl    $0x7,%eax
  8000d2:	29 d0                	sub    %edx,%eax
  8000d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d9:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000de:	85 f6                	test   %esi,%esi
  8000e0:	7e 07                	jle    8000e9 <libmain+0x39>
		binaryname = argv[0];
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ed:	89 34 24             	mov    %esi,(%esp)
  8000f0:	e8 3f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80010a:	e8 bc 12 00 00       	call   8013cb <close_all>
	sys_env_destroy(0);
  80010f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800116:	e8 b2 09 00 00       	call   800acd <sys_env_destroy>
}
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    
  80011d:	00 00                	add    %al,(%eax)
	...

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 14             	sub    $0x14,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800133:	40                   	inc    %eax
  800134:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 19                	jne    800156 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80013d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800144:	00 
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	89 04 24             	mov    %eax,(%esp)
  80014b:	e8 40 09 00 00       	call   800a90 <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800156:	ff 43 04             	incl   0x4(%ebx)
}
  800159:	83 c4 14             	add    $0x14,%esp
  80015c:	5b                   	pop    %ebx
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800168:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016f:	00 00 00 
	b.cnt = 0;
  800172:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800179:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800183:	8b 45 08             	mov    0x8(%ebp),%eax
  800186:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 20 01 80 00 	movl   $0x800120,(%esp)
  80019b:	e8 82 01 00 00       	call   800322 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b0:	89 04 24             	mov    %eax,(%esp)
  8001b3:	e8 d8 08 00 00       	call   800a90 <sys_cputs>

	return b.cnt;
}
  8001b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 87 ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    
	...

008001dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
  8001e2:	83 ec 3c             	sub    $0x3c,%esp
  8001e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001e8:	89 d7                	mov    %edx,%edi
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	75 08                	jne    800208 <printnum+0x2c>
  800200:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800203:	39 45 10             	cmp    %eax,0x10(%ebp)
  800206:	77 57                	ja     80025f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800208:	89 74 24 10          	mov    %esi,0x10(%esp)
  80020c:	4b                   	dec    %ebx
  80020d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800211:	8b 45 10             	mov    0x10(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80021c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800220:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800227:	00 
  800228:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022b:	89 04 24             	mov    %eax,(%esp)
  80022e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	e8 96 24 00 00       	call   8026d0 <__udivdi3>
  80023a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80023e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	89 54 24 04          	mov    %edx,0x4(%esp)
  800249:	89 fa                	mov    %edi,%edx
  80024b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024e:	e8 89 ff ff ff       	call   8001dc <printnum>
  800253:	eb 0f                	jmp    800264 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800259:	89 34 24             	mov    %esi,(%esp)
  80025c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	4b                   	dec    %ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f f1                	jg     800255 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800268:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027a:	00 
  80027b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	e8 63 25 00 00       	call   8027f0 <__umoddi3>
  80028d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800291:	0f be 80 c0 29 80 00 	movsbl 0x8029c0(%eax),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80029e:	83 c4 3c             	add    $0x3c,%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a9:	83 fa 01             	cmp    $0x1,%edx
  8002ac:	7e 0e                	jle    8002bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	eb 22                	jmp    8002de <getuint+0x38>
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 10                	je     8002d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 0e                	jmp    8002de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 08                	jae    8002f8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	88 0a                	mov    %cl,(%edx)
  8002f5:	42                   	inc    %edx
  8002f6:	89 10                	mov    %edx,(%eax)
}
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800300:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 10             	mov    0x10(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800311:	89 44 24 04          	mov    %eax,0x4(%esp)
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 02 00 00 00       	call   800322 <vprintfmt>
	va_end(ap);
}
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 4c             	sub    $0x4c,%esp
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032e:	8b 75 10             	mov    0x10(%ebp),%esi
  800331:	eb 12                	jmp    800345 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800333:	85 c0                	test   %eax,%eax
  800335:	0f 84 6b 03 00 00    	je     8006a6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80033b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800345:	0f b6 06             	movzbl (%esi),%eax
  800348:	46                   	inc    %esi
  800349:	83 f8 25             	cmp    $0x25,%eax
  80034c:	75 e5                	jne    800333 <vprintfmt+0x11>
  80034e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800352:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800359:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800365:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036a:	eb 26                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800373:	eb 1d                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800378:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80037c:	eb 14                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800381:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800388:	eb 08                	jmp    800392 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80038d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	0f b6 06             	movzbl (%esi),%eax
  800395:	8d 56 01             	lea    0x1(%esi),%edx
  800398:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80039b:	8a 16                	mov    (%esi),%dl
  80039d:	83 ea 23             	sub    $0x23,%edx
  8003a0:	80 fa 55             	cmp    $0x55,%dl
  8003a3:	0f 87 e1 02 00 00    	ja     80068a <vprintfmt+0x368>
  8003a9:	0f b6 d2             	movzbl %dl,%edx
  8003ac:	ff 24 95 00 2b 80 00 	jmp    *0x802b00(,%edx,4)
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003be:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003c2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c8:	83 fa 09             	cmp    $0x9,%edx
  8003cb:	77 2a                	ja     8003f7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ce:	eb eb                	jmp    8003bb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 50 04             	lea    0x4(%eax),%edx
  8003d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 17                	jmp    8003f7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e4:	78 98                	js     80037e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e9:	eb a7                	jmp    800392 <vprintfmt+0x70>
  8003eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f5:	eb 9b                	jmp    800392 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fb:	79 95                	jns    800392 <vprintfmt+0x70>
  8003fd:	eb 8b                	jmp    80038a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ff:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800403:	eb 8d                	jmp    800392 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 50 04             	lea    0x4(%eax),%edx
  80040b:	89 55 14             	mov    %edx,0x14(%ebp)
  80040e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041d:	e9 23 ff ff ff       	jmp    800345 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	85 c0                	test   %eax,%eax
  80042f:	79 02                	jns    800433 <vprintfmt+0x111>
  800431:	f7 d8                	neg    %eax
  800433:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 10             	cmp    $0x10,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x123>
  80043a:	8b 04 85 60 2c 80 00 	mov    0x802c60(,%eax,4),%eax
  800441:	85 c0                	test   %eax,%eax
  800443:	75 23                	jne    800468 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800445:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800449:	c7 44 24 08 d8 29 80 	movl   $0x8029d8,0x8(%esp)
  800450:	00 
  800451:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 9a fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 dd fe ff ff       	jmp    800345 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046c:	c7 44 24 08 49 2e 80 	movl   $0x802e49,0x8(%esp)
  800473:	00 
  800474:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800478:	8b 55 08             	mov    0x8(%ebp),%edx
  80047b:	89 14 24             	mov    %edx,(%esp)
  80047e:	e8 77 fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800486:	e9 ba fe ff ff       	jmp    800345 <vprintfmt+0x23>
  80048b:	89 f9                	mov    %edi,%ecx
  80048d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	8b 30                	mov    (%eax),%esi
  80049e:	85 f6                	test   %esi,%esi
  8004a0:	75 05                	jne    8004a7 <vprintfmt+0x185>
				p = "(null)";
  8004a2:	be d1 29 80 00       	mov    $0x8029d1,%esi
			if (width > 0 && padc != '-')
  8004a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ab:	0f 8e 84 00 00 00    	jle    800535 <vprintfmt+0x213>
  8004b1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004b5:	74 7e                	je     800535 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004bb:	89 34 24             	mov    %esi,(%esp)
  8004be:	e8 8b 02 00 00       	call   80074e <strnlen>
  8004c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c6:	29 c2                	sub    %eax,%edx
  8004c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004cb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004cf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004d5:	89 de                	mov    %ebx,%esi
  8004d7:	89 d3                	mov    %edx,%ebx
  8004d9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	eb 0b                	jmp    8004e8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e1:	89 3c 24             	mov    %edi,(%esp)
  8004e4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	4b                   	dec    %ebx
  8004e8:	85 db                	test   %ebx,%ebx
  8004ea:	7f f1                	jg     8004dd <vprintfmt+0x1bb>
  8004ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004ef:	89 f3                	mov    %esi,%ebx
  8004f1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	79 05                	jns    800500 <vprintfmt+0x1de>
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800503:	29 c2                	sub    %eax,%edx
  800505:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800508:	eb 2b                	jmp    800535 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050e:	74 18                	je     800528 <vprintfmt+0x206>
  800510:	8d 50 e0             	lea    -0x20(%eax),%edx
  800513:	83 fa 5e             	cmp    $0x5e,%edx
  800516:	76 10                	jbe    800528 <vprintfmt+0x206>
					putch('?', putdat);
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	eb 0a                	jmp    800532 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800528:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052c:	89 04 24             	mov    %eax,(%esp)
  80052f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	ff 4d e4             	decl   -0x1c(%ebp)
  800535:	0f be 06             	movsbl (%esi),%eax
  800538:	46                   	inc    %esi
  800539:	85 c0                	test   %eax,%eax
  80053b:	74 21                	je     80055e <vprintfmt+0x23c>
  80053d:	85 ff                	test   %edi,%edi
  80053f:	78 c9                	js     80050a <vprintfmt+0x1e8>
  800541:	4f                   	dec    %edi
  800542:	79 c6                	jns    80050a <vprintfmt+0x1e8>
  800544:	8b 7d 08             	mov    0x8(%ebp),%edi
  800547:	89 de                	mov    %ebx,%esi
  800549:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80054c:	eb 18                	jmp    800566 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800552:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800559:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055b:	4b                   	dec    %ebx
  80055c:	eb 08                	jmp    800566 <vprintfmt+0x244>
  80055e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800561:	89 de                	mov    %ebx,%esi
  800563:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800566:	85 db                	test   %ebx,%ebx
  800568:	7f e4                	jg     80054e <vprintfmt+0x22c>
  80056a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80056d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800572:	e9 ce fd ff ff       	jmp    800345 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800577:	83 f9 01             	cmp    $0x1,%ecx
  80057a:	7e 10                	jle    80058c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 08             	lea    0x8(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	8b 30                	mov    (%eax),%esi
  800587:	8b 78 04             	mov    0x4(%eax),%edi
  80058a:	eb 26                	jmp    8005b2 <vprintfmt+0x290>
	else if (lflag)
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	74 12                	je     8005a2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
  80059b:	89 f7                	mov    %esi,%edi
  80059d:	c1 ff 1f             	sar    $0x1f,%edi
  8005a0:	eb 10                	jmp    8005b2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 30                	mov    (%eax),%esi
  8005ad:	89 f7                	mov    %esi,%edi
  8005af:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	78 0a                	js     8005c0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bb:	e9 8c 00 00 00       	jmp    80064c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ce:	f7 de                	neg    %esi
  8005d0:	83 d7 00             	adc    $0x0,%edi
  8005d3:	f7 df                	neg    %edi
			}
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005da:	eb 70                	jmp    80064c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005dc:	89 ca                	mov    %ecx,%edx
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 c0 fc ff ff       	call   8002a6 <getuint>
  8005e6:	89 c6                	mov    %eax,%esi
  8005e8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ef:	eb 5b                	jmp    80064c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8005f1:	89 ca                	mov    %ecx,%edx
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 ab fc ff ff       	call   8002a6 <getuint>
  8005fb:	89 c6                	mov    %eax,%esi
  8005fd:	89 d7                	mov    %edx,%edi
			base = 8;
  8005ff:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800604:	eb 46                	jmp    80064c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800606:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800611:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062b:	8b 30                	mov    (%eax),%esi
  80062d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800632:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800637:	eb 13                	jmp    80064c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 63 fc ff ff       	call   8002a6 <getuint>
  800643:	89 c6                	mov    %eax,%esi
  800645:	89 d7                	mov    %edx,%edi
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800650:	89 54 24 10          	mov    %edx,0x10(%esp)
  800654:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800657:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065f:	89 34 24             	mov    %esi,(%esp)
  800662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800666:	89 da                	mov    %ebx,%edx
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	e8 6c fb ff ff       	call   8001dc <printnum>
			break;
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800673:	e9 cd fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800685:	e9 bb fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800698:	eb 01                	jmp    80069b <vprintfmt+0x379>
  80069a:	4e                   	dec    %esi
  80069b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069f:	75 f9                	jne    80069a <vprintfmt+0x378>
  8006a1:	e9 9f fc ff ff       	jmp    800345 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006a6:	83 c4 4c             	add    $0x4c,%esp
  8006a9:	5b                   	pop    %ebx
  8006aa:	5e                   	pop    %esi
  8006ab:	5f                   	pop    %edi
  8006ac:	5d                   	pop    %ebp
  8006ad:	c3                   	ret    

008006ae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	83 ec 28             	sub    $0x28,%esp
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 30                	je     8006ff <vsnprintf+0x51>
  8006cf:	85 d2                	test   %edx,%edx
  8006d1:	7e 33                	jle    800706 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006da:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	c7 04 24 e0 02 80 00 	movl   $0x8002e0,(%esp)
  8006ef:	e8 2e fc ff ff       	call   800322 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	eb 0c                	jmp    80070b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800704:	eb 05                	jmp    80070b <vsnprintf+0x5d>
  800706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    

0080070d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800716:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
  800724:	89 44 24 04          	mov    %eax,0x4(%esp)
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	89 04 24             	mov    %eax,(%esp)
  80072e:	e8 7b ff ff ff       	call   8006ae <vsnprintf>
	va_end(ap);

	return rc;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    
  800735:	00 00                	add    %al,(%eax)
	...

00800738 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	eb 01                	jmp    800746 <strlen+0xe>
		n++;
  800745:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074a:	75 f9                	jne    800745 <strlen+0xd>
		n++;
	return n;
}
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
  80075c:	eb 01                	jmp    80075f <strnlen+0x11>
		n++;
  80075e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	39 d0                	cmp    %edx,%eax
  800761:	74 06                	je     800769 <strnlen+0x1b>
  800763:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800767:	75 f5                	jne    80075e <strnlen+0x10>
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800775:	ba 00 00 00 00       	mov    $0x0,%edx
  80077a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80077d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800780:	42                   	inc    %edx
  800781:	84 c9                	test   %cl,%cl
  800783:	75 f5                	jne    80077a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800785:	5b                   	pop    %ebx
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800792:	89 1c 24             	mov    %ebx,(%esp)
  800795:	e8 9e ff ff ff       	call   800738 <strlen>
	strcpy(dst + len, src);
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a1:	01 d8                	add    %ebx,%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	e8 c0 ff ff ff       	call   80076b <strcpy>
	return dst;
}
  8007ab:	89 d8                	mov    %ebx,%eax
  8007ad:	83 c4 08             	add    $0x8,%esp
  8007b0:	5b                   	pop    %ebx
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	56                   	push   %esi
  8007b7:	53                   	push   %ebx
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007be:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c6:	eb 0c                	jmp    8007d4 <strncpy+0x21>
		*dst++ = *src;
  8007c8:	8a 1a                	mov    (%edx),%bl
  8007ca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d3:	41                   	inc    %ecx
  8007d4:	39 f1                	cmp    %esi,%ecx
  8007d6:	75 f0                	jne    8007c8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	75 0a                	jne    8007f8 <strlcpy+0x1c>
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	eb 1a                	jmp    80080c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f2:	88 18                	mov    %bl,(%eax)
  8007f4:	40                   	inc    %eax
  8007f5:	41                   	inc    %ecx
  8007f6:	eb 02                	jmp    8007fa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007fa:	4a                   	dec    %edx
  8007fb:	74 0a                	je     800807 <strlcpy+0x2b>
  8007fd:	8a 19                	mov    (%ecx),%bl
  8007ff:	84 db                	test   %bl,%bl
  800801:	75 ef                	jne    8007f2 <strlcpy+0x16>
  800803:	89 c2                	mov    %eax,%edx
  800805:	eb 02                	jmp    800809 <strlcpy+0x2d>
  800807:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800809:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80080c:	29 f0                	sub    %esi,%eax
}
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081b:	eb 02                	jmp    80081f <strcmp+0xd>
		p++, q++;
  80081d:	41                   	inc    %ecx
  80081e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081f:	8a 01                	mov    (%ecx),%al
  800821:	84 c0                	test   %al,%al
  800823:	74 04                	je     800829 <strcmp+0x17>
  800825:	3a 02                	cmp    (%edx),%al
  800827:	74 f4                	je     80081d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800829:	0f b6 c0             	movzbl %al,%eax
  80082c:	0f b6 12             	movzbl (%edx),%edx
  80082f:	29 d0                	sub    %edx,%eax
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800840:	eb 03                	jmp    800845 <strncmp+0x12>
		n--, p++, q++;
  800842:	4a                   	dec    %edx
  800843:	40                   	inc    %eax
  800844:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800845:	85 d2                	test   %edx,%edx
  800847:	74 14                	je     80085d <strncmp+0x2a>
  800849:	8a 18                	mov    (%eax),%bl
  80084b:	84 db                	test   %bl,%bl
  80084d:	74 04                	je     800853 <strncmp+0x20>
  80084f:	3a 19                	cmp    (%ecx),%bl
  800851:	74 ef                	je     800842 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 00             	movzbl (%eax),%eax
  800856:	0f b6 11             	movzbl (%ecx),%edx
  800859:	29 d0                	sub    %edx,%eax
  80085b:	eb 05                	jmp    800862 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800862:	5b                   	pop    %ebx
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80086e:	eb 05                	jmp    800875 <strchr+0x10>
		if (*s == c)
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 0c                	je     800880 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800874:	40                   	inc    %eax
  800875:	8a 10                	mov    (%eax),%dl
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f5                	jne    800870 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088b:	eb 05                	jmp    800892 <strfind+0x10>
		if (*s == c)
  80088d:	38 ca                	cmp    %cl,%dl
  80088f:	74 07                	je     800898 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800891:	40                   	inc    %eax
  800892:	8a 10                	mov    (%eax),%dl
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f5                	jne    80088d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	74 30                	je     8008dd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 25                	jne    8008da <memset+0x40>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 20                	jne    8008da <memset+0x40>
		c &= 0xFF;
  8008ba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bd:	89 d3                	mov    %edx,%ebx
  8008bf:	c1 e3 08             	shl    $0x8,%ebx
  8008c2:	89 d6                	mov    %edx,%esi
  8008c4:	c1 e6 18             	shl    $0x18,%esi
  8008c7:	89 d0                	mov    %edx,%eax
  8008c9:	c1 e0 10             	shl    $0x10,%eax
  8008cc:	09 f0                	or     %esi,%eax
  8008ce:	09 d0                	or     %edx,%eax
  8008d0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d5:	fc                   	cld    
  8008d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d8:	eb 03                	jmp    8008dd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008da:	fc                   	cld    
  8008db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008dd:	89 f8                	mov    %edi,%eax
  8008df:	5b                   	pop    %ebx
  8008e0:	5e                   	pop    %esi
  8008e1:	5f                   	pop    %edi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f2:	39 c6                	cmp    %eax,%esi
  8008f4:	73 34                	jae    80092a <memmove+0x46>
  8008f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f9:	39 d0                	cmp    %edx,%eax
  8008fb:	73 2d                	jae    80092a <memmove+0x46>
		s += n;
		d += n;
  8008fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800900:	f6 c2 03             	test   $0x3,%dl
  800903:	75 1b                	jne    800920 <memmove+0x3c>
  800905:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090b:	75 13                	jne    800920 <memmove+0x3c>
  80090d:	f6 c1 03             	test   $0x3,%cl
  800910:	75 0e                	jne    800920 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800912:	83 ef 04             	sub    $0x4,%edi
  800915:	8d 72 fc             	lea    -0x4(%edx),%esi
  800918:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80091b:	fd                   	std    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 07                	jmp    800927 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	4f                   	dec    %edi
  800921:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800924:	fd                   	std    
  800925:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800927:	fc                   	cld    
  800928:	eb 20                	jmp    80094a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800930:	75 13                	jne    800945 <memmove+0x61>
  800932:	a8 03                	test   $0x3,%al
  800934:	75 0f                	jne    800945 <memmove+0x61>
  800936:	f6 c1 03             	test   $0x3,%cl
  800939:	75 0a                	jne    800945 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80093b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80093e:	89 c7                	mov    %eax,%edi
  800940:	fc                   	cld    
  800941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800943:	eb 05                	jmp    80094a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800954:	8b 45 10             	mov    0x10(%ebp),%eax
  800957:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	e8 77 ff ff ff       	call   8008e4 <memmove>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 7d 08             	mov    0x8(%ebp),%edi
  800978:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	ba 00 00 00 00       	mov    $0x0,%edx
  800983:	eb 16                	jmp    80099b <memcmp+0x2c>
		if (*s1 != *s2)
  800985:	8a 04 17             	mov    (%edi,%edx,1),%al
  800988:	42                   	inc    %edx
  800989:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80098d:	38 c8                	cmp    %cl,%al
  80098f:	74 0a                	je     80099b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 c9             	movzbl %cl,%ecx
  800997:	29 c8                	sub    %ecx,%eax
  800999:	eb 09                	jmp    8009a4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099b:	39 da                	cmp    %ebx,%edx
  80099d:	75 e6                	jne    800985 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5f                   	pop    %edi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b2:	89 c2                	mov    %eax,%edx
  8009b4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b7:	eb 05                	jmp    8009be <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b9:	38 08                	cmp    %cl,(%eax)
  8009bb:	74 05                	je     8009c2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bd:	40                   	inc    %eax
  8009be:	39 d0                	cmp    %edx,%eax
  8009c0:	72 f7                	jb     8009b9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d0:	eb 01                	jmp    8009d3 <strtol+0xf>
		s++;
  8009d2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d3:	8a 02                	mov    (%edx),%al
  8009d5:	3c 20                	cmp    $0x20,%al
  8009d7:	74 f9                	je     8009d2 <strtol+0xe>
  8009d9:	3c 09                	cmp    $0x9,%al
  8009db:	74 f5                	je     8009d2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009dd:	3c 2b                	cmp    $0x2b,%al
  8009df:	75 08                	jne    8009e9 <strtol+0x25>
		s++;
  8009e1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e7:	eb 13                	jmp    8009fc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e9:	3c 2d                	cmp    $0x2d,%al
  8009eb:	75 0a                	jne    8009f7 <strtol+0x33>
		s++, neg = 1;
  8009ed:	8d 52 01             	lea    0x1(%edx),%edx
  8009f0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f5:	eb 05                	jmp    8009fc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fc:	85 db                	test   %ebx,%ebx
  8009fe:	74 05                	je     800a05 <strtol+0x41>
  800a00:	83 fb 10             	cmp    $0x10,%ebx
  800a03:	75 28                	jne    800a2d <strtol+0x69>
  800a05:	8a 02                	mov    (%edx),%al
  800a07:	3c 30                	cmp    $0x30,%al
  800a09:	75 10                	jne    800a1b <strtol+0x57>
  800a0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a0f:	75 0a                	jne    800a1b <strtol+0x57>
		s += 2, base = 16;
  800a11:	83 c2 02             	add    $0x2,%edx
  800a14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a19:	eb 12                	jmp    800a2d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a1b:	85 db                	test   %ebx,%ebx
  800a1d:	75 0e                	jne    800a2d <strtol+0x69>
  800a1f:	3c 30                	cmp    $0x30,%al
  800a21:	75 05                	jne    800a28 <strtol+0x64>
		s++, base = 8;
  800a23:	42                   	inc    %edx
  800a24:	b3 08                	mov    $0x8,%bl
  800a26:	eb 05                	jmp    800a2d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a28:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a34:	8a 0a                	mov    (%edx),%cl
  800a36:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a39:	80 fb 09             	cmp    $0x9,%bl
  800a3c:	77 08                	ja     800a46 <strtol+0x82>
			dig = *s - '0';
  800a3e:	0f be c9             	movsbl %cl,%ecx
  800a41:	83 e9 30             	sub    $0x30,%ecx
  800a44:	eb 1e                	jmp    800a64 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a46:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 08                	ja     800a56 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a4e:	0f be c9             	movsbl %cl,%ecx
  800a51:	83 e9 57             	sub    $0x57,%ecx
  800a54:	eb 0e                	jmp    800a64 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a56:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 12                	ja     800a70 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a5e:	0f be c9             	movsbl %cl,%ecx
  800a61:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a64:	39 f1                	cmp    %esi,%ecx
  800a66:	7d 0c                	jge    800a74 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a68:	42                   	inc    %edx
  800a69:	0f af c6             	imul   %esi,%eax
  800a6c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a6e:	eb c4                	jmp    800a34 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a70:	89 c1                	mov    %eax,%ecx
  800a72:	eb 02                	jmp    800a76 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a74:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7a:	74 05                	je     800a81 <strtol+0xbd>
		*endptr = (char *) s;
  800a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a81:	85 ff                	test   %edi,%edi
  800a83:	74 04                	je     800a89 <strtol+0xc5>
  800a85:	89 c8                	mov    %ecx,%eax
  800a87:	f7 d8                	neg    %eax
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    
	...

00800a90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	89 c6                	mov    %eax,%esi
  800aa7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <sys_cgetc>:

int
sys_cgetc(void)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab9:	b8 01 00 00 00       	mov    $0x1,%eax
  800abe:	89 d1                	mov    %edx,%ecx
  800ac0:	89 d3                	mov    %edx,%ebx
  800ac2:	89 d7                	mov    %edx,%edi
  800ac4:	89 d6                	mov    %edx,%esi
  800ac6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	89 cb                	mov    %ecx,%ebx
  800ae5:	89 cf                	mov    %ecx,%edi
  800ae7:	89 ce                	mov    %ecx,%esi
  800ae9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	7e 28                	jle    800b17 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800af3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800afa:	00 
  800afb:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800b02:	00 
  800b03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b0a:	00 
  800b0b:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800b12:	e8 71 19 00 00       	call   802488 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b17:	83 c4 2c             	add    $0x2c,%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_yield>:

void
sys_yield(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	be 00 00 00 00       	mov    $0x0,%esi
  800b6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	89 f7                	mov    %esi,%edi
  800b7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 28                	jle    800ba9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b85:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800b94:	00 
  800b95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9c:	00 
  800b9d:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800ba4:	e8 df 18 00 00       	call   802488 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba9:	83 c4 2c             	add    $0x2c,%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 28                	jle    800bfc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bdf:	00 
  800be0:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800be7:	00 
  800be8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bef:	00 
  800bf0:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800bf7:	e8 8c 18 00 00       	call   802488 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfc:	83 c4 2c             	add    $0x2c,%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 06 00 00 00       	mov    $0x6,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 28                	jle    800c4f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800c4a:	e8 39 18 00 00       	call   802488 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4f:	83 c4 2c             	add    $0x2c,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 28                	jle    800ca2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c85:	00 
  800c86:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800c9d:	e8 e6 17 00 00       	call   802488 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca2:	83 c4 2c             	add    $0x2c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800cf0:	e8 93 17 00 00       	call   802488 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 28                	jle    800d48 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800d43:	e8 40 17 00 00       	call   802488 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	be 00 00 00 00       	mov    $0x0,%esi
  800d5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 28                	jle    800dbd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d99:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800da0:	00 
  800da1:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800da8:	00 
  800da9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db0:	00 
  800db1:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800db8:	e8 cb 16 00 00       	call   802488 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbd:	83 c4 2c             	add    $0x2c,%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	89 d3                	mov    %edx,%ebx
  800dd9:	89 d7                	mov    %edx,%edi
  800ddb:	89 d6                	mov    %edx,%esi
  800ddd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800def:	b8 0f 00 00 00       	mov    $0xf,%eax
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 df                	mov    %ebx,%edi
  800dfc:	89 de                	mov    %ebx,%esi
  800dfe:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 10 00 00 00       	mov    $0x10,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    
	...

00800e28 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 24             	sub    $0x24,%esp
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e32:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e38:	74 2d                	je     800e67 <pgfault+0x3f>
  800e3a:	89 d8                	mov    %ebx,%eax
  800e3c:	c1 e8 16             	shr    $0x16,%eax
  800e3f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e46:	a8 01                	test   $0x1,%al
  800e48:	74 1d                	je     800e67 <pgfault+0x3f>
  800e4a:	89 d8                	mov    %ebx,%eax
  800e4c:	c1 e8 0c             	shr    $0xc,%eax
  800e4f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e56:	f6 c2 01             	test   $0x1,%dl
  800e59:	74 0c                	je     800e67 <pgfault+0x3f>
  800e5b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e62:	f6 c4 08             	test   $0x8,%ah
  800e65:	75 1c                	jne    800e83 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  800e67:	c7 44 24 08 f0 2c 80 	movl   $0x802cf0,0x8(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e76:	00 
  800e77:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  800e7e:	e8 05 16 00 00       	call   802488 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  800e83:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e89:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea0:	e8 b8 fc ff ff       	call   800b5d <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  800ea5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800eac:	00 
  800ead:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eb1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800eb8:	e8 91 fa ff ff       	call   80094e <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  800ebd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ec4:	00 
  800ec5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ec9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ee0:	e8 cc fc ff ff       	call   800bb1 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  800ee5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800eec:	00 
  800eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef4:	e8 0b fd ff ff       	call   800c04 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  800ef9:	83 c4 24             	add    $0x24,%esp
  800efc:	5b                   	pop    %ebx
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	57                   	push   %edi
  800f03:	56                   	push   %esi
  800f04:	53                   	push   %ebx
  800f05:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f08:	c7 04 24 28 0e 80 00 	movl   $0x800e28,(%esp)
  800f0f:	e8 cc 15 00 00       	call   8024e0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f14:	ba 07 00 00 00       	mov    $0x7,%edx
  800f19:	89 d0                	mov    %edx,%eax
  800f1b:	cd 30                	int    $0x30
  800f1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f20:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	79 20                	jns    800f46 <fork+0x47>
		panic("sys_exofork: %e", envid);
  800f26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f2a:	c7 44 24 08 3e 2d 80 	movl   $0x802d3e,0x8(%esp)
  800f31:	00 
  800f32:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f39:	00 
  800f3a:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  800f41:	e8 42 15 00 00       	call   802488 <_panic>
	if (envid == 0)
  800f46:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f4a:	75 25                	jne    800f71 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f4c:	e8 ce fb ff ff       	call   800b1f <sys_getenvid>
  800f51:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f56:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f5d:	c1 e0 07             	shl    $0x7,%eax
  800f60:	29 d0                	sub    %edx,%eax
  800f62:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f67:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f6c:	e9 43 02 00 00       	jmp    8011b4 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  800f71:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  800f76:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800f7c:	0f 84 85 01 00 00    	je     801107 <fork+0x208>
  800f82:	89 d8                	mov    %ebx,%eax
  800f84:	c1 e8 16             	shr    $0x16,%eax
  800f87:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8e:	a8 01                	test   $0x1,%al
  800f90:	0f 84 5f 01 00 00    	je     8010f5 <fork+0x1f6>
  800f96:	89 d8                	mov    %ebx,%eax
  800f98:	c1 e8 0c             	shr    $0xc,%eax
  800f9b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa2:	f6 c2 01             	test   $0x1,%dl
  800fa5:	0f 84 4a 01 00 00    	je     8010f5 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  800fab:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  800fad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb4:	f6 c6 04             	test   $0x4,%dh
  800fb7:	74 50                	je     801009 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  800fb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc0:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fcd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fd1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fdc:	e8 d0 fb ff ff       	call   800bb1 <sys_page_map>
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	0f 89 0c 01 00 00    	jns    8010f5 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  800fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fed:	c7 44 24 08 4e 2d 80 	movl   $0x802d4e,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  801004:	e8 7f 14 00 00       	call   802488 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  801009:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801010:	f6 c2 02             	test   $0x2,%dl
  801013:	75 10                	jne    801025 <fork+0x126>
  801015:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101c:	f6 c4 08             	test   $0x8,%ah
  80101f:	0f 84 8c 00 00 00    	je     8010b1 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  801025:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80102c:	00 
  80102d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801031:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801035:	89 74 24 04          	mov    %esi,0x4(%esp)
  801039:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801040:	e8 6c fb ff ff       	call   800bb1 <sys_page_map>
  801045:	85 c0                	test   %eax,%eax
  801047:	79 20                	jns    801069 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80104d:	c7 44 24 08 4e 2d 80 	movl   $0x802d4e,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  801064:	e8 1f 14 00 00       	call   802488 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801069:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801070:	00 
  801071:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801075:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80107c:	00 
  80107d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801081:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801088:	e8 24 fb ff ff       	call   800bb1 <sys_page_map>
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 64                	jns    8010f5 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801091:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801095:	c7 44 24 08 4e 2d 80 	movl   $0x802d4e,0x8(%esp)
  80109c:	00 
  80109d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  8010a4:	00 
  8010a5:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  8010ac:	e8 d7 13 00 00       	call   802488 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  8010b1:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8010b8:	00 
  8010b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010bd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cc:	e8 e0 fa ff ff       	call   800bb1 <sys_page_map>
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	79 20                	jns    8010f5 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8010d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d9:	c7 44 24 08 4e 2d 80 	movl   $0x802d4e,0x8(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8010e8:	00 
  8010e9:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  8010f0:	e8 93 13 00 00       	call   802488 <_panic>
  8010f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  8010fb:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801101:	0f 85 6f fe ff ff    	jne    800f76 <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  801107:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80110e:	00 
  80110f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801116:	ee 
  801117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111a:	89 04 24             	mov    %eax,(%esp)
  80111d:	e8 3b fa ff ff       	call   800b5d <sys_page_alloc>
  801122:	85 c0                	test   %eax,%eax
  801124:	79 20                	jns    801146 <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  801126:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80112a:	c7 44 24 08 60 2d 80 	movl   $0x802d60,0x8(%esp)
  801131:	00 
  801132:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801139:	00 
  80113a:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  801141:	e8 42 13 00 00       	call   802488 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801146:	c7 44 24 04 2c 25 80 	movl   $0x80252c,0x4(%esp)
  80114d:	00 
  80114e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801151:	89 04 24             	mov    %eax,(%esp)
  801154:	e8 a4 fb ff ff       	call   800cfd <sys_env_set_pgfault_upcall>
  801159:	85 c0                	test   %eax,%eax
  80115b:	79 20                	jns    80117d <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  80115d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801161:	c7 44 24 08 14 2d 80 	movl   $0x802d14,0x8(%esp)
  801168:	00 
  801169:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801170:	00 
  801171:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  801178:	e8 0b 13 00 00       	call   802488 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80117d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801184:	00 
  801185:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801188:	89 04 24             	mov    %eax,(%esp)
  80118b:	e8 c7 fa ff ff       	call   800c57 <sys_env_set_status>
  801190:	85 c0                	test   %eax,%eax
  801192:	79 20                	jns    8011b4 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801198:	c7 44 24 08 73 2d 80 	movl   $0x802d73,0x8(%esp)
  80119f:	00 
  8011a0:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8011a7:	00 
  8011a8:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  8011af:	e8 d4 12 00 00       	call   802488 <_panic>

	return envid;
	// panic("fork not implemented");
}
  8011b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b7:	83 c4 3c             	add    $0x3c,%esp
  8011ba:	5b                   	pop    %ebx
  8011bb:	5e                   	pop    %esi
  8011bc:	5f                   	pop    %edi
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <sfork>:

// Challenge!
int
sfork(void)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011c5:	c7 44 24 08 8a 2d 80 	movl   $0x802d8a,0x8(%esp)
  8011cc:	00 
  8011cd:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  8011dc:	e8 a7 12 00 00       	call   802488 <_panic>
  8011e1:	00 00                	add    %al,(%eax)
	...

008011e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ef:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fd:	89 04 24             	mov    %eax,(%esp)
  801200:	e8 df ff ff ff       	call   8011e4 <fd2num>
  801205:	c1 e0 0c             	shl    $0xc,%eax
  801208:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    

0080120f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	53                   	push   %ebx
  801213:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801216:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80121b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	c1 ea 16             	shr    $0x16,%edx
  801222:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801229:	f6 c2 01             	test   $0x1,%dl
  80122c:	74 11                	je     80123f <fd_alloc+0x30>
  80122e:	89 c2                	mov    %eax,%edx
  801230:	c1 ea 0c             	shr    $0xc,%edx
  801233:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123a:	f6 c2 01             	test   $0x1,%dl
  80123d:	75 09                	jne    801248 <fd_alloc+0x39>
			*fd_store = fd;
  80123f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801241:	b8 00 00 00 00       	mov    $0x0,%eax
  801246:	eb 17                	jmp    80125f <fd_alloc+0x50>
  801248:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80124d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801252:	75 c7                	jne    80121b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801254:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80125a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80125f:	5b                   	pop    %ebx
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801268:	83 f8 1f             	cmp    $0x1f,%eax
  80126b:	77 36                	ja     8012a3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80126d:	c1 e0 0c             	shl    $0xc,%eax
  801270:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801275:	89 c2                	mov    %eax,%edx
  801277:	c1 ea 16             	shr    $0x16,%edx
  80127a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801281:	f6 c2 01             	test   $0x1,%dl
  801284:	74 24                	je     8012aa <fd_lookup+0x48>
  801286:	89 c2                	mov    %eax,%edx
  801288:	c1 ea 0c             	shr    $0xc,%edx
  80128b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801292:	f6 c2 01             	test   $0x1,%dl
  801295:	74 1a                	je     8012b1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129a:	89 02                	mov    %eax,(%edx)
	return 0;
  80129c:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a1:	eb 13                	jmp    8012b6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a8:	eb 0c                	jmp    8012b6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012af:	eb 05                	jmp    8012b6 <fd_lookup+0x54>
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 14             	sub    $0x14,%esp
  8012bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8012c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ca:	eb 0e                	jmp    8012da <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8012cc:	39 08                	cmp    %ecx,(%eax)
  8012ce:	75 09                	jne    8012d9 <dev_lookup+0x21>
			*dev = devtab[i];
  8012d0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d7:	eb 33                	jmp    80130c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d9:	42                   	inc    %edx
  8012da:	8b 04 95 1c 2e 80 00 	mov    0x802e1c(,%edx,4),%eax
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	75 e7                	jne    8012cc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ea:	8b 40 48             	mov    0x48(%eax),%eax
  8012ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f5:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  8012fc:	e8 bf ee ff ff       	call   8001c0 <cprintf>
	*dev = 0;
  801301:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801307:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80130c:	83 c4 14             	add    $0x14,%esp
  80130f:	5b                   	pop    %ebx
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    

00801312 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	56                   	push   %esi
  801316:	53                   	push   %ebx
  801317:	83 ec 30             	sub    $0x30,%esp
  80131a:	8b 75 08             	mov    0x8(%ebp),%esi
  80131d:	8a 45 0c             	mov    0xc(%ebp),%al
  801320:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801323:	89 34 24             	mov    %esi,(%esp)
  801326:	e8 b9 fe ff ff       	call   8011e4 <fd2num>
  80132b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80132e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	e8 28 ff ff ff       	call   801262 <fd_lookup>
  80133a:	89 c3                	mov    %eax,%ebx
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 05                	js     801345 <fd_close+0x33>
	    || fd != fd2)
  801340:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801343:	74 0d                	je     801352 <fd_close+0x40>
		return (must_exist ? r : 0);
  801345:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801349:	75 46                	jne    801391 <fd_close+0x7f>
  80134b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801350:	eb 3f                	jmp    801391 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801352:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801355:	89 44 24 04          	mov    %eax,0x4(%esp)
  801359:	8b 06                	mov    (%esi),%eax
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	e8 55 ff ff ff       	call   8012b8 <dev_lookup>
  801363:	89 c3                	mov    %eax,%ebx
  801365:	85 c0                	test   %eax,%eax
  801367:	78 18                	js     801381 <fd_close+0x6f>
		if (dev->dev_close)
  801369:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136c:	8b 40 10             	mov    0x10(%eax),%eax
  80136f:	85 c0                	test   %eax,%eax
  801371:	74 09                	je     80137c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801373:	89 34 24             	mov    %esi,(%esp)
  801376:	ff d0                	call   *%eax
  801378:	89 c3                	mov    %eax,%ebx
  80137a:	eb 05                	jmp    801381 <fd_close+0x6f>
		else
			r = 0;
  80137c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801381:	89 74 24 04          	mov    %esi,0x4(%esp)
  801385:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80138c:	e8 73 f8 ff ff       	call   800c04 <sys_page_unmap>
	return r;
}
  801391:	89 d8                	mov    %ebx,%eax
  801393:	83 c4 30             	add    $0x30,%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013aa:	89 04 24             	mov    %eax,(%esp)
  8013ad:	e8 b0 fe ff ff       	call   801262 <fd_lookup>
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 13                	js     8013c9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013bd:	00 
  8013be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c1:	89 04 24             	mov    %eax,(%esp)
  8013c4:	e8 49 ff ff ff       	call   801312 <fd_close>
}
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <close_all>:

void
close_all(void)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013d7:	89 1c 24             	mov    %ebx,(%esp)
  8013da:	e8 bb ff ff ff       	call   80139a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013df:	43                   	inc    %ebx
  8013e0:	83 fb 20             	cmp    $0x20,%ebx
  8013e3:	75 f2                	jne    8013d7 <close_all+0xc>
		close(i);
}
  8013e5:	83 c4 14             	add    $0x14,%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	57                   	push   %edi
  8013ef:	56                   	push   %esi
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 4c             	sub    $0x4c,%esp
  8013f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801401:	89 04 24             	mov    %eax,(%esp)
  801404:	e8 59 fe ff ff       	call   801262 <fd_lookup>
  801409:	89 c3                	mov    %eax,%ebx
  80140b:	85 c0                	test   %eax,%eax
  80140d:	0f 88 e3 00 00 00    	js     8014f6 <dup+0x10b>
		return r;
	close(newfdnum);
  801413:	89 3c 24             	mov    %edi,(%esp)
  801416:	e8 7f ff ff ff       	call   80139a <close>

	newfd = INDEX2FD(newfdnum);
  80141b:	89 fe                	mov    %edi,%esi
  80141d:	c1 e6 0c             	shl    $0xc,%esi
  801420:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801426:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801429:	89 04 24             	mov    %eax,(%esp)
  80142c:	e8 c3 fd ff ff       	call   8011f4 <fd2data>
  801431:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801433:	89 34 24             	mov    %esi,(%esp)
  801436:	e8 b9 fd ff ff       	call   8011f4 <fd2data>
  80143b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80143e:	89 d8                	mov    %ebx,%eax
  801440:	c1 e8 16             	shr    $0x16,%eax
  801443:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80144a:	a8 01                	test   $0x1,%al
  80144c:	74 46                	je     801494 <dup+0xa9>
  80144e:	89 d8                	mov    %ebx,%eax
  801450:	c1 e8 0c             	shr    $0xc,%eax
  801453:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80145a:	f6 c2 01             	test   $0x1,%dl
  80145d:	74 35                	je     801494 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80145f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801466:	25 07 0e 00 00       	and    $0xe07,%eax
  80146b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80146f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801472:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801476:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80147d:	00 
  80147e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801482:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801489:	e8 23 f7 ff ff       	call   800bb1 <sys_page_map>
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	85 c0                	test   %eax,%eax
  801492:	78 3b                	js     8014cf <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801494:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801497:	89 c2                	mov    %eax,%edx
  801499:	c1 ea 0c             	shr    $0xc,%edx
  80149c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014ad:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b8:	00 
  8014b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c4:	e8 e8 f6 ff ff       	call   800bb1 <sys_page_map>
  8014c9:	89 c3                	mov    %eax,%ebx
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	79 25                	jns    8014f4 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014da:	e8 25 f7 ff ff       	call   800c04 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ed:	e8 12 f7 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  8014f2:	eb 02                	jmp    8014f6 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014f4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f6:	89 d8                	mov    %ebx,%eax
  8014f8:	83 c4 4c             	add    $0x4c,%esp
  8014fb:	5b                   	pop    %ebx
  8014fc:	5e                   	pop    %esi
  8014fd:	5f                   	pop    %edi
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    

00801500 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	53                   	push   %ebx
  801504:	83 ec 24             	sub    $0x24,%esp
  801507:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801511:	89 1c 24             	mov    %ebx,(%esp)
  801514:	e8 49 fd ff ff       	call   801262 <fd_lookup>
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 6d                	js     80158a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801520:	89 44 24 04          	mov    %eax,0x4(%esp)
  801524:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801527:	8b 00                	mov    (%eax),%eax
  801529:	89 04 24             	mov    %eax,(%esp)
  80152c:	e8 87 fd ff ff       	call   8012b8 <dev_lookup>
  801531:	85 c0                	test   %eax,%eax
  801533:	78 55                	js     80158a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801538:	8b 50 08             	mov    0x8(%eax),%edx
  80153b:	83 e2 03             	and    $0x3,%edx
  80153e:	83 fa 01             	cmp    $0x1,%edx
  801541:	75 23                	jne    801566 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801543:	a1 08 40 80 00       	mov    0x804008,%eax
  801548:	8b 40 48             	mov    0x48(%eax),%eax
  80154b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80154f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801553:	c7 04 24 e1 2d 80 00 	movl   $0x802de1,(%esp)
  80155a:	e8 61 ec ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  80155f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801564:	eb 24                	jmp    80158a <read+0x8a>
	}
	if (!dev->dev_read)
  801566:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801569:	8b 52 08             	mov    0x8(%edx),%edx
  80156c:	85 d2                	test   %edx,%edx
  80156e:	74 15                	je     801585 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801570:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801573:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801577:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80157e:	89 04 24             	mov    %eax,(%esp)
  801581:	ff d2                	call   *%edx
  801583:	eb 05                	jmp    80158a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801585:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80158a:	83 c4 24             	add    $0x24,%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	57                   	push   %edi
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 1c             	sub    $0x1c,%esp
  801599:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a4:	eb 23                	jmp    8015c9 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a6:	89 f0                	mov    %esi,%eax
  8015a8:	29 d8                	sub    %ebx,%eax
  8015aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b1:	01 d8                	add    %ebx,%eax
  8015b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b7:	89 3c 24             	mov    %edi,(%esp)
  8015ba:	e8 41 ff ff ff       	call   801500 <read>
		if (m < 0)
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 10                	js     8015d3 <readn+0x43>
			return m;
		if (m == 0)
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	74 0a                	je     8015d1 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c7:	01 c3                	add    %eax,%ebx
  8015c9:	39 f3                	cmp    %esi,%ebx
  8015cb:	72 d9                	jb     8015a6 <readn+0x16>
  8015cd:	89 d8                	mov    %ebx,%eax
  8015cf:	eb 02                	jmp    8015d3 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015d1:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015d3:	83 c4 1c             	add    $0x1c,%esp
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	5f                   	pop    %edi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	83 ec 24             	sub    $0x24,%esp
  8015e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ec:	89 1c 24             	mov    %ebx,(%esp)
  8015ef:	e8 6e fc ff ff       	call   801262 <fd_lookup>
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 68                	js     801660 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801602:	8b 00                	mov    (%eax),%eax
  801604:	89 04 24             	mov    %eax,(%esp)
  801607:	e8 ac fc ff ff       	call   8012b8 <dev_lookup>
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 50                	js     801660 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801610:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801613:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801617:	75 23                	jne    80163c <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801619:	a1 08 40 80 00       	mov    0x804008,%eax
  80161e:	8b 40 48             	mov    0x48(%eax),%eax
  801621:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801625:	89 44 24 04          	mov    %eax,0x4(%esp)
  801629:	c7 04 24 fd 2d 80 00 	movl   $0x802dfd,(%esp)
  801630:	e8 8b eb ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  801635:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163a:	eb 24                	jmp    801660 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80163c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163f:	8b 52 0c             	mov    0xc(%edx),%edx
  801642:	85 d2                	test   %edx,%edx
  801644:	74 15                	je     80165b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801646:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801649:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80164d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801650:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801654:	89 04 24             	mov    %eax,(%esp)
  801657:	ff d2                	call   *%edx
  801659:	eb 05                	jmp    801660 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80165b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801660:	83 c4 24             	add    $0x24,%esp
  801663:	5b                   	pop    %ebx
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <seek>:

int
seek(int fdnum, off_t offset)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80166f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	89 04 24             	mov    %eax,(%esp)
  801679:	e8 e4 fb ff ff       	call   801262 <fd_lookup>
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 0e                	js     801690 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801682:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801685:	8b 55 0c             	mov    0xc(%ebp),%edx
  801688:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80168b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	53                   	push   %ebx
  801696:	83 ec 24             	sub    $0x24,%esp
  801699:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a3:	89 1c 24             	mov    %ebx,(%esp)
  8016a6:	e8 b7 fb ff ff       	call   801262 <fd_lookup>
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 61                	js     801710 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b9:	8b 00                	mov    (%eax),%eax
  8016bb:	89 04 24             	mov    %eax,(%esp)
  8016be:	e8 f5 fb ff ff       	call   8012b8 <dev_lookup>
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	78 49                	js     801710 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ce:	75 23                	jne    8016f3 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016d0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d5:	8b 40 48             	mov    0x48(%eax),%eax
  8016d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e0:	c7 04 24 c0 2d 80 00 	movl   $0x802dc0,(%esp)
  8016e7:	e8 d4 ea ff ff       	call   8001c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f1:	eb 1d                	jmp    801710 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f6:	8b 52 18             	mov    0x18(%edx),%edx
  8016f9:	85 d2                	test   %edx,%edx
  8016fb:	74 0e                	je     80170b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801700:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801704:	89 04 24             	mov    %eax,(%esp)
  801707:	ff d2                	call   *%edx
  801709:	eb 05                	jmp    801710 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80170b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801710:	83 c4 24             	add    $0x24,%esp
  801713:	5b                   	pop    %ebx
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	53                   	push   %ebx
  80171a:	83 ec 24             	sub    $0x24,%esp
  80171d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801720:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801723:	89 44 24 04          	mov    %eax,0x4(%esp)
  801727:	8b 45 08             	mov    0x8(%ebp),%eax
  80172a:	89 04 24             	mov    %eax,(%esp)
  80172d:	e8 30 fb ff ff       	call   801262 <fd_lookup>
  801732:	85 c0                	test   %eax,%eax
  801734:	78 52                	js     801788 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801736:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801740:	8b 00                	mov    (%eax),%eax
  801742:	89 04 24             	mov    %eax,(%esp)
  801745:	e8 6e fb ff ff       	call   8012b8 <dev_lookup>
  80174a:	85 c0                	test   %eax,%eax
  80174c:	78 3a                	js     801788 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801751:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801755:	74 2c                	je     801783 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801757:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80175a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801761:	00 00 00 
	stat->st_isdir = 0;
  801764:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80176b:	00 00 00 
	stat->st_dev = dev;
  80176e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801774:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801778:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80177b:	89 14 24             	mov    %edx,(%esp)
  80177e:	ff 50 14             	call   *0x14(%eax)
  801781:	eb 05                	jmp    801788 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801783:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801788:	83 c4 24             	add    $0x24,%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801796:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80179d:	00 
  80179e:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a1:	89 04 24             	mov    %eax,(%esp)
  8017a4:	e8 2a 02 00 00       	call   8019d3 <open>
  8017a9:	89 c3                	mov    %eax,%ebx
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 1b                	js     8017ca <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b6:	89 1c 24             	mov    %ebx,(%esp)
  8017b9:	e8 58 ff ff ff       	call   801716 <fstat>
  8017be:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c0:	89 1c 24             	mov    %ebx,(%esp)
  8017c3:	e8 d2 fb ff ff       	call   80139a <close>
	return r;
  8017c8:	89 f3                	mov    %esi,%ebx
}
  8017ca:	89 d8                	mov    %ebx,%eax
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    
	...

008017d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	56                   	push   %esi
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 10             	sub    $0x10,%esp
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017e0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e7:	75 11                	jne    8017fa <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017f0:	e8 52 0e 00 00       	call   802647 <ipc_find_env>
  8017f5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017fa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801801:	00 
  801802:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801809:	00 
  80180a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80180e:	a1 00 40 80 00       	mov    0x804000,%eax
  801813:	89 04 24             	mov    %eax,(%esp)
  801816:	e8 a9 0d 00 00       	call   8025c4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80181b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801822:	00 
  801823:	89 74 24 04          	mov    %esi,0x4(%esp)
  801827:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80182e:	e8 21 0d 00 00       	call   802554 <ipc_recv>
}
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5d                   	pop    %ebp
  801839:	c3                   	ret    

0080183a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	8b 40 0c             	mov    0xc(%eax),%eax
  801846:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80184b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801853:	ba 00 00 00 00       	mov    $0x0,%edx
  801858:	b8 02 00 00 00       	mov    $0x2,%eax
  80185d:	e8 72 ff ff ff       	call   8017d4 <fsipc>
}
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	b8 06 00 00 00       	mov    $0x6,%eax
  80187f:	e8 50 ff ff ff       	call   8017d4 <fsipc>
}
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	53                   	push   %ebx
  80188a:	83 ec 14             	sub    $0x14,%esp
  80188d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	8b 40 0c             	mov    0xc(%eax),%eax
  801896:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80189b:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a5:	e8 2a ff ff ff       	call   8017d4 <fsipc>
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 2b                	js     8018d9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ae:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018b5:	00 
  8018b6:	89 1c 24             	mov    %ebx,(%esp)
  8018b9:	e8 ad ee ff ff       	call   80076b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018be:	a1 80 50 80 00       	mov    0x805080,%eax
  8018c3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c9:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ce:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d9:	83 c4 14             	add    $0x14,%esp
  8018dc:	5b                   	pop    %ebx
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	83 ec 18             	sub    $0x18,%esp
  8018e5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ee:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018f4:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801900:	76 05                	jbe    801907 <devfile_write+0x28>
  801902:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801907:	89 54 24 08          	mov    %edx,0x8(%esp)
  80190b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801912:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801919:	e8 30 f0 ff ff       	call   80094e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80191e:	ba 00 00 00 00       	mov    $0x0,%edx
  801923:	b8 04 00 00 00       	mov    $0x4,%eax
  801928:	e8 a7 fe ff ff       	call   8017d4 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	83 ec 10             	sub    $0x10,%esp
  801937:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80193a:	8b 45 08             	mov    0x8(%ebp),%eax
  80193d:	8b 40 0c             	mov    0xc(%eax),%eax
  801940:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801945:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80194b:	ba 00 00 00 00       	mov    $0x0,%edx
  801950:	b8 03 00 00 00       	mov    $0x3,%eax
  801955:	e8 7a fe ff ff       	call   8017d4 <fsipc>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 6a                	js     8019ca <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801960:	39 c6                	cmp    %eax,%esi
  801962:	73 24                	jae    801988 <devfile_read+0x59>
  801964:	c7 44 24 0c 30 2e 80 	movl   $0x802e30,0xc(%esp)
  80196b:	00 
  80196c:	c7 44 24 08 37 2e 80 	movl   $0x802e37,0x8(%esp)
  801973:	00 
  801974:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80197b:	00 
  80197c:	c7 04 24 4c 2e 80 00 	movl   $0x802e4c,(%esp)
  801983:	e8 00 0b 00 00       	call   802488 <_panic>
	assert(r <= PGSIZE);
  801988:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80198d:	7e 24                	jle    8019b3 <devfile_read+0x84>
  80198f:	c7 44 24 0c 57 2e 80 	movl   $0x802e57,0xc(%esp)
  801996:	00 
  801997:	c7 44 24 08 37 2e 80 	movl   $0x802e37,0x8(%esp)
  80199e:	00 
  80199f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8019a6:	00 
  8019a7:	c7 04 24 4c 2e 80 00 	movl   $0x802e4c,(%esp)
  8019ae:	e8 d5 0a 00 00       	call   802488 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019b7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019be:	00 
  8019bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c2:	89 04 24             	mov    %eax,(%esp)
  8019c5:	e8 1a ef ff ff       	call   8008e4 <memmove>
	return r;
}
  8019ca:	89 d8                	mov    %ebx,%eax
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5e                   	pop    %esi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	83 ec 20             	sub    $0x20,%esp
  8019db:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019de:	89 34 24             	mov    %esi,(%esp)
  8019e1:	e8 52 ed ff ff       	call   800738 <strlen>
  8019e6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019eb:	7f 60                	jg     801a4d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f0:	89 04 24             	mov    %eax,(%esp)
  8019f3:	e8 17 f8 ff ff       	call   80120f <fd_alloc>
  8019f8:	89 c3                	mov    %eax,%ebx
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 54                	js     801a52 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a02:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a09:	e8 5d ed ff ff       	call   80076b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a11:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a19:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1e:	e8 b1 fd ff ff       	call   8017d4 <fsipc>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	85 c0                	test   %eax,%eax
  801a27:	79 15                	jns    801a3e <open+0x6b>
		fd_close(fd, 0);
  801a29:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a30:	00 
  801a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a34:	89 04 24             	mov    %eax,(%esp)
  801a37:	e8 d6 f8 ff ff       	call   801312 <fd_close>
		return r;
  801a3c:	eb 14                	jmp    801a52 <open+0x7f>
	}

	return fd2num(fd);
  801a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a41:	89 04 24             	mov    %eax,(%esp)
  801a44:	e8 9b f7 ff ff       	call   8011e4 <fd2num>
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	eb 05                	jmp    801a52 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a4d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a52:	89 d8                	mov    %ebx,%eax
  801a54:	83 c4 20             	add    $0x20,%esp
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a61:	ba 00 00 00 00       	mov    $0x0,%edx
  801a66:	b8 08 00 00 00       	mov    $0x8,%eax
  801a6b:	e8 64 fd ff ff       	call   8017d4 <fsipc>
}
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    
	...

00801a74 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801a7a:	c7 44 24 04 63 2e 80 	movl   $0x802e63,0x4(%esp)
  801a81:	00 
  801a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a85:	89 04 24             	mov    %eax,(%esp)
  801a88:	e8 de ec ff ff       	call   80076b <strcpy>
	return 0;
}
  801a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	53                   	push   %ebx
  801a98:	83 ec 14             	sub    $0x14,%esp
  801a9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a9e:	89 1c 24             	mov    %ebx,(%esp)
  801aa1:	e8 e6 0b 00 00       	call   80268c <pageref>
  801aa6:	83 f8 01             	cmp    $0x1,%eax
  801aa9:	75 0d                	jne    801ab8 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801aab:	8b 43 0c             	mov    0xc(%ebx),%eax
  801aae:	89 04 24             	mov    %eax,(%esp)
  801ab1:	e8 1f 03 00 00       	call   801dd5 <nsipc_close>
  801ab6:	eb 05                	jmp    801abd <devsock_close+0x29>
	else
		return 0;
  801ab8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801abd:	83 c4 14             	add    $0x14,%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ac9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ad0:	00 
  801ad1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae5:	89 04 24             	mov    %eax,(%esp)
  801ae8:	e8 e3 03 00 00       	call   801ed0 <nsipc_send>
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801af5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801afc:	00 
  801afd:	8b 45 10             	mov    0x10(%ebp),%eax
  801b00:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b11:	89 04 24             	mov    %eax,(%esp)
  801b14:	e8 37 03 00 00       	call   801e50 <nsipc_recv>
}
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	56                   	push   %esi
  801b1f:	53                   	push   %ebx
  801b20:	83 ec 20             	sub    $0x20,%esp
  801b23:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b28:	89 04 24             	mov    %eax,(%esp)
  801b2b:	e8 df f6 ff ff       	call   80120f <fd_alloc>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 21                	js     801b57 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b3d:	00 
  801b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b4c:	e8 0c f0 ff ff       	call   800b5d <sys_page_alloc>
  801b51:	89 c3                	mov    %eax,%ebx
  801b53:	85 c0                	test   %eax,%eax
  801b55:	79 0a                	jns    801b61 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801b57:	89 34 24             	mov    %esi,(%esp)
  801b5a:	e8 76 02 00 00       	call   801dd5 <nsipc_close>
		return r;
  801b5f:	eb 22                	jmp    801b83 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b76:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b79:	89 04 24             	mov    %eax,(%esp)
  801b7c:	e8 63 f6 ff ff       	call   8011e4 <fd2num>
  801b81:	89 c3                	mov    %eax,%ebx
}
  801b83:	89 d8                	mov    %ebx,%eax
  801b85:	83 c4 20             	add    $0x20,%esp
  801b88:	5b                   	pop    %ebx
  801b89:	5e                   	pop    %esi
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b92:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b95:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b99:	89 04 24             	mov    %eax,(%esp)
  801b9c:	e8 c1 f6 ff ff       	call   801262 <fd_lookup>
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 17                	js     801bbc <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bae:	39 10                	cmp    %edx,(%eax)
  801bb0:	75 05                	jne    801bb7 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bb2:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb5:	eb 05                	jmp    801bbc <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801bb7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	e8 c0 ff ff ff       	call   801b8c <fd2sockid>
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	78 1f                	js     801bef <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bd0:	8b 55 10             	mov    0x10(%ebp),%edx
  801bd3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bda:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bde:	89 04 24             	mov    %eax,(%esp)
  801be1:	e8 38 01 00 00       	call   801d1e <nsipc_accept>
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 05                	js     801bef <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801bea:	e8 2c ff ff ff       	call   801b1b <alloc_sockfd>
}
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    

00801bf1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfa:	e8 8d ff ff ff       	call   801b8c <fd2sockid>
  801bff:	85 c0                	test   %eax,%eax
  801c01:	78 16                	js     801c19 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801c03:	8b 55 10             	mov    0x10(%ebp),%edx
  801c06:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c11:	89 04 24             	mov    %eax,(%esp)
  801c14:	e8 5b 01 00 00       	call   801d74 <nsipc_bind>
}
  801c19:	c9                   	leave  
  801c1a:	c3                   	ret    

00801c1b <shutdown>:

int
shutdown(int s, int how)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c21:	8b 45 08             	mov    0x8(%ebp),%eax
  801c24:	e8 63 ff ff ff       	call   801b8c <fd2sockid>
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 0f                	js     801c3c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c30:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c34:	89 04 24             	mov    %eax,(%esp)
  801c37:	e8 77 01 00 00       	call   801db3 <nsipc_shutdown>
}
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	e8 40 ff ff ff       	call   801b8c <fd2sockid>
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	78 16                	js     801c66 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801c50:	8b 55 10             	mov    0x10(%ebp),%edx
  801c53:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c57:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c5e:	89 04 24             	mov    %eax,(%esp)
  801c61:	e8 89 01 00 00       	call   801def <nsipc_connect>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <listen>:

int
listen(int s, int backlog)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c71:	e8 16 ff ff ff       	call   801b8c <fd2sockid>
  801c76:	85 c0                	test   %eax,%eax
  801c78:	78 0f                	js     801c89 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c81:	89 04 24             	mov    %eax,(%esp)
  801c84:	e8 a5 01 00 00       	call   801e2e <nsipc_listen>
}
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c91:	8b 45 10             	mov    0x10(%ebp),%eax
  801c94:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	89 04 24             	mov    %eax,(%esp)
  801ca5:	e8 99 02 00 00       	call   801f43 <nsipc_socket>
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 05                	js     801cb3 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801cae:	e8 68 fe ff ff       	call   801b1b <alloc_sockfd>
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    
  801cb5:	00 00                	add    %al,(%eax)
	...

00801cb8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	53                   	push   %ebx
  801cbc:	83 ec 14             	sub    $0x14,%esp
  801cbf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cc1:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801cc8:	75 11                	jne    801cdb <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cca:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801cd1:	e8 71 09 00 00       	call   802647 <ipc_find_env>
  801cd6:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cdb:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ce2:	00 
  801ce3:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801cea:	00 
  801ceb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cef:	a1 04 40 80 00       	mov    0x804004,%eax
  801cf4:	89 04 24             	mov    %eax,(%esp)
  801cf7:	e8 c8 08 00 00       	call   8025c4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cfc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d03:	00 
  801d04:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d0b:	00 
  801d0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d13:	e8 3c 08 00 00       	call   802554 <ipc_recv>
}
  801d18:	83 c4 14             	add    $0x14,%esp
  801d1b:	5b                   	pop    %ebx
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    

00801d1e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	83 ec 10             	sub    $0x10,%esp
  801d26:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d31:	8b 06                	mov    (%esi),%eax
  801d33:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d38:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3d:	e8 76 ff ff ff       	call   801cb8 <nsipc>
  801d42:	89 c3                	mov    %eax,%ebx
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 23                	js     801d6b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d48:	a1 10 60 80 00       	mov    0x806010,%eax
  801d4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d51:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d58:	00 
  801d59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5c:	89 04 24             	mov    %eax,(%esp)
  801d5f:	e8 80 eb ff ff       	call   8008e4 <memmove>
		*addrlen = ret->ret_addrlen;
  801d64:	a1 10 60 80 00       	mov    0x806010,%eax
  801d69:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	83 c4 10             	add    $0x10,%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    

00801d74 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	53                   	push   %ebx
  801d78:	83 ec 14             	sub    $0x14,%esp
  801d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d81:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d86:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d91:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801d98:	e8 47 eb ff ff       	call   8008e4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d9d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801da3:	b8 02 00 00 00       	mov    $0x2,%eax
  801da8:	e8 0b ff ff ff       	call   801cb8 <nsipc>
}
  801dad:	83 c4 14             	add    $0x14,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    

00801db3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801dc9:	b8 03 00 00 00       	mov    $0x3,%eax
  801dce:	e8 e5 fe ff ff       	call   801cb8 <nsipc>
}
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    

00801dd5 <nsipc_close>:

int
nsipc_close(int s)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dde:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801de3:	b8 04 00 00 00       	mov    $0x4,%eax
  801de8:	e8 cb fe ff ff       	call   801cb8 <nsipc>
}
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	53                   	push   %ebx
  801df3:	83 ec 14             	sub    $0x14,%esp
  801df6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e01:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e13:	e8 cc ea ff ff       	call   8008e4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e18:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e1e:	b8 05 00 00 00       	mov    $0x5,%eax
  801e23:	e8 90 fe ff ff       	call   801cb8 <nsipc>
}
  801e28:	83 c4 14             	add    $0x14,%esp
  801e2b:	5b                   	pop    %ebx
  801e2c:	5d                   	pop    %ebp
  801e2d:	c3                   	ret    

00801e2e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e34:	8b 45 08             	mov    0x8(%ebp),%eax
  801e37:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e44:	b8 06 00 00 00       	mov    $0x6,%eax
  801e49:	e8 6a fe ff ff       	call   801cb8 <nsipc>
}
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	56                   	push   %esi
  801e54:	53                   	push   %ebx
  801e55:	83 ec 10             	sub    $0x10,%esp
  801e58:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e63:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e69:	8b 45 14             	mov    0x14(%ebp),%eax
  801e6c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e71:	b8 07 00 00 00       	mov    $0x7,%eax
  801e76:	e8 3d fe ff ff       	call   801cb8 <nsipc>
  801e7b:	89 c3                	mov    %eax,%ebx
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 46                	js     801ec7 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801e81:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e86:	7f 04                	jg     801e8c <nsipc_recv+0x3c>
  801e88:	39 c6                	cmp    %eax,%esi
  801e8a:	7d 24                	jge    801eb0 <nsipc_recv+0x60>
  801e8c:	c7 44 24 0c 6f 2e 80 	movl   $0x802e6f,0xc(%esp)
  801e93:	00 
  801e94:	c7 44 24 08 37 2e 80 	movl   $0x802e37,0x8(%esp)
  801e9b:	00 
  801e9c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801ea3:	00 
  801ea4:	c7 04 24 84 2e 80 00 	movl   $0x802e84,(%esp)
  801eab:	e8 d8 05 00 00       	call   802488 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801eb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ebb:	00 
  801ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebf:	89 04 24             	mov    %eax,(%esp)
  801ec2:	e8 1d ea ff ff       	call   8008e4 <memmove>
	}

	return r;
}
  801ec7:	89 d8                	mov    %ebx,%eax
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	5b                   	pop    %ebx
  801ecd:	5e                   	pop    %esi
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 14             	sub    $0x14,%esp
  801ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ee2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ee8:	7e 24                	jle    801f0e <nsipc_send+0x3e>
  801eea:	c7 44 24 0c 90 2e 80 	movl   $0x802e90,0xc(%esp)
  801ef1:	00 
  801ef2:	c7 44 24 08 37 2e 80 	movl   $0x802e37,0x8(%esp)
  801ef9:	00 
  801efa:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801f01:	00 
  801f02:	c7 04 24 84 2e 80 00 	movl   $0x802e84,(%esp)
  801f09:	e8 7a 05 00 00       	call   802488 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f19:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801f20:	e8 bf e9 ff ff       	call   8008e4 <memmove>
	nsipcbuf.send.req_size = size;
  801f25:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f33:	b8 08 00 00 00       	mov    $0x8,%eax
  801f38:	e8 7b fd ff ff       	call   801cb8 <nsipc>
}
  801f3d:	83 c4 14             	add    $0x14,%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    

00801f43 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f49:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f54:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f59:	8b 45 10             	mov    0x10(%ebp),%eax
  801f5c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f61:	b8 09 00 00 00       	mov    $0x9,%eax
  801f66:	e8 4d fd ff ff       	call   801cb8 <nsipc>
}
  801f6b:	c9                   	leave  
  801f6c:	c3                   	ret    
  801f6d:	00 00                	add    %al,(%eax)
	...

00801f70 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	56                   	push   %esi
  801f74:	53                   	push   %ebx
  801f75:	83 ec 10             	sub    $0x10,%esp
  801f78:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7e:	89 04 24             	mov    %eax,(%esp)
  801f81:	e8 6e f2 ff ff       	call   8011f4 <fd2data>
  801f86:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801f88:	c7 44 24 04 9c 2e 80 	movl   $0x802e9c,0x4(%esp)
  801f8f:	00 
  801f90:	89 34 24             	mov    %esi,(%esp)
  801f93:	e8 d3 e7 ff ff       	call   80076b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f98:	8b 43 04             	mov    0x4(%ebx),%eax
  801f9b:	2b 03                	sub    (%ebx),%eax
  801f9d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801fa3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801faa:	00 00 00 
	stat->st_dev = &devpipe;
  801fad:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801fb4:	30 80 00 
	return 0;
}
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbc:	83 c4 10             	add    $0x10,%esp
  801fbf:	5b                   	pop    %ebx
  801fc0:	5e                   	pop    %esi
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    

00801fc3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	53                   	push   %ebx
  801fc7:	83 ec 14             	sub    $0x14,%esp
  801fca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fcd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd8:	e8 27 ec ff ff       	call   800c04 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fdd:	89 1c 24             	mov    %ebx,(%esp)
  801fe0:	e8 0f f2 ff ff       	call   8011f4 <fd2data>
  801fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff0:	e8 0f ec ff ff       	call   800c04 <sys_page_unmap>
}
  801ff5:	83 c4 14             	add    $0x14,%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    

00801ffb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	57                   	push   %edi
  801fff:	56                   	push   %esi
  802000:	53                   	push   %ebx
  802001:	83 ec 2c             	sub    $0x2c,%esp
  802004:	89 c7                	mov    %eax,%edi
  802006:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802009:	a1 08 40 80 00       	mov    0x804008,%eax
  80200e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802011:	89 3c 24             	mov    %edi,(%esp)
  802014:	e8 73 06 00 00       	call   80268c <pageref>
  802019:	89 c6                	mov    %eax,%esi
  80201b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80201e:	89 04 24             	mov    %eax,(%esp)
  802021:	e8 66 06 00 00       	call   80268c <pageref>
  802026:	39 c6                	cmp    %eax,%esi
  802028:	0f 94 c0             	sete   %al
  80202b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80202e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802034:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802037:	39 cb                	cmp    %ecx,%ebx
  802039:	75 08                	jne    802043 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80203b:	83 c4 2c             	add    $0x2c,%esp
  80203e:	5b                   	pop    %ebx
  80203f:	5e                   	pop    %esi
  802040:	5f                   	pop    %edi
  802041:	5d                   	pop    %ebp
  802042:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802043:	83 f8 01             	cmp    $0x1,%eax
  802046:	75 c1                	jne    802009 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802048:	8b 42 58             	mov    0x58(%edx),%eax
  80204b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802052:	00 
  802053:	89 44 24 08          	mov    %eax,0x8(%esp)
  802057:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80205b:	c7 04 24 a3 2e 80 00 	movl   $0x802ea3,(%esp)
  802062:	e8 59 e1 ff ff       	call   8001c0 <cprintf>
  802067:	eb a0                	jmp    802009 <_pipeisclosed+0xe>

00802069 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	57                   	push   %edi
  80206d:	56                   	push   %esi
  80206e:	53                   	push   %ebx
  80206f:	83 ec 1c             	sub    $0x1c,%esp
  802072:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802075:	89 34 24             	mov    %esi,(%esp)
  802078:	e8 77 f1 ff ff       	call   8011f4 <fd2data>
  80207d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80207f:	bf 00 00 00 00       	mov    $0x0,%edi
  802084:	eb 3c                	jmp    8020c2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802086:	89 da                	mov    %ebx,%edx
  802088:	89 f0                	mov    %esi,%eax
  80208a:	e8 6c ff ff ff       	call   801ffb <_pipeisclosed>
  80208f:	85 c0                	test   %eax,%eax
  802091:	75 38                	jne    8020cb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802093:	e8 a6 ea ff ff       	call   800b3e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802098:	8b 43 04             	mov    0x4(%ebx),%eax
  80209b:	8b 13                	mov    (%ebx),%edx
  80209d:	83 c2 20             	add    $0x20,%edx
  8020a0:	39 d0                	cmp    %edx,%eax
  8020a2:	73 e2                	jae    802086 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8020aa:	89 c2                	mov    %eax,%edx
  8020ac:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8020b2:	79 05                	jns    8020b9 <devpipe_write+0x50>
  8020b4:	4a                   	dec    %edx
  8020b5:	83 ca e0             	or     $0xffffffe0,%edx
  8020b8:	42                   	inc    %edx
  8020b9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020bd:	40                   	inc    %eax
  8020be:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c1:	47                   	inc    %edi
  8020c2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020c5:	75 d1                	jne    802098 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020c7:	89 f8                	mov    %edi,%eax
  8020c9:	eb 05                	jmp    8020d0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020cb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    

008020d8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	57                   	push   %edi
  8020dc:	56                   	push   %esi
  8020dd:	53                   	push   %ebx
  8020de:	83 ec 1c             	sub    $0x1c,%esp
  8020e1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020e4:	89 3c 24             	mov    %edi,(%esp)
  8020e7:	e8 08 f1 ff ff       	call   8011f4 <fd2data>
  8020ec:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ee:	be 00 00 00 00       	mov    $0x0,%esi
  8020f3:	eb 3a                	jmp    80212f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020f5:	85 f6                	test   %esi,%esi
  8020f7:	74 04                	je     8020fd <devpipe_read+0x25>
				return i;
  8020f9:	89 f0                	mov    %esi,%eax
  8020fb:	eb 40                	jmp    80213d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020fd:	89 da                	mov    %ebx,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	e8 f5 fe ff ff       	call   801ffb <_pipeisclosed>
  802106:	85 c0                	test   %eax,%eax
  802108:	75 2e                	jne    802138 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80210a:	e8 2f ea ff ff       	call   800b3e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80210f:	8b 03                	mov    (%ebx),%eax
  802111:	3b 43 04             	cmp    0x4(%ebx),%eax
  802114:	74 df                	je     8020f5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802116:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80211b:	79 05                	jns    802122 <devpipe_read+0x4a>
  80211d:	48                   	dec    %eax
  80211e:	83 c8 e0             	or     $0xffffffe0,%eax
  802121:	40                   	inc    %eax
  802122:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802126:	8b 55 0c             	mov    0xc(%ebp),%edx
  802129:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80212c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80212e:	46                   	inc    %esi
  80212f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802132:	75 db                	jne    80210f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802134:	89 f0                	mov    %esi,%eax
  802136:	eb 05                	jmp    80213d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802138:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	57                   	push   %edi
  802149:	56                   	push   %esi
  80214a:	53                   	push   %ebx
  80214b:	83 ec 3c             	sub    $0x3c,%esp
  80214e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802151:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802154:	89 04 24             	mov    %eax,(%esp)
  802157:	e8 b3 f0 ff ff       	call   80120f <fd_alloc>
  80215c:	89 c3                	mov    %eax,%ebx
  80215e:	85 c0                	test   %eax,%eax
  802160:	0f 88 45 01 00 00    	js     8022ab <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802166:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80216d:	00 
  80216e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802171:	89 44 24 04          	mov    %eax,0x4(%esp)
  802175:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80217c:	e8 dc e9 ff ff       	call   800b5d <sys_page_alloc>
  802181:	89 c3                	mov    %eax,%ebx
  802183:	85 c0                	test   %eax,%eax
  802185:	0f 88 20 01 00 00    	js     8022ab <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80218b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80218e:	89 04 24             	mov    %eax,(%esp)
  802191:	e8 79 f0 ff ff       	call   80120f <fd_alloc>
  802196:	89 c3                	mov    %eax,%ebx
  802198:	85 c0                	test   %eax,%eax
  80219a:	0f 88 f8 00 00 00    	js     802298 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021a7:	00 
  8021a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b6:	e8 a2 e9 ff ff       	call   800b5d <sys_page_alloc>
  8021bb:	89 c3                	mov    %eax,%ebx
  8021bd:	85 c0                	test   %eax,%eax
  8021bf:	0f 88 d3 00 00 00    	js     802298 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021c8:	89 04 24             	mov    %eax,(%esp)
  8021cb:	e8 24 f0 ff ff       	call   8011f4 <fd2data>
  8021d0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021d9:	00 
  8021da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e5:	e8 73 e9 ff ff       	call   800b5d <sys_page_alloc>
  8021ea:	89 c3                	mov    %eax,%ebx
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	0f 88 91 00 00 00    	js     802285 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021f7:	89 04 24             	mov    %eax,(%esp)
  8021fa:	e8 f5 ef ff ff       	call   8011f4 <fd2data>
  8021ff:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802206:	00 
  802207:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802212:	00 
  802213:	89 74 24 04          	mov    %esi,0x4(%esp)
  802217:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80221e:	e8 8e e9 ff ff       	call   800bb1 <sys_page_map>
  802223:	89 c3                	mov    %eax,%ebx
  802225:	85 c0                	test   %eax,%eax
  802227:	78 4c                	js     802275 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802229:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80222f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802232:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802234:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802237:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80223e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802244:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802247:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802249:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80224c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802253:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802256:	89 04 24             	mov    %eax,(%esp)
  802259:	e8 86 ef ff ff       	call   8011e4 <fd2num>
  80225e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802260:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802263:	89 04 24             	mov    %eax,(%esp)
  802266:	e8 79 ef ff ff       	call   8011e4 <fd2num>
  80226b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80226e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802273:	eb 36                	jmp    8022ab <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802275:	89 74 24 04          	mov    %esi,0x4(%esp)
  802279:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802280:	e8 7f e9 ff ff       	call   800c04 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802285:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802293:	e8 6c e9 ff ff       	call   800c04 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802298:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80229b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80229f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a6:	e8 59 e9 ff ff       	call   800c04 <sys_page_unmap>
    err:
	return r;
}
  8022ab:	89 d8                	mov    %ebx,%eax
  8022ad:	83 c4 3c             	add    $0x3c,%esp
  8022b0:	5b                   	pop    %ebx
  8022b1:	5e                   	pop    %esi
  8022b2:	5f                   	pop    %edi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    

008022b5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
  8022b8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c5:	89 04 24             	mov    %eax,(%esp)
  8022c8:	e8 95 ef ff ff       	call   801262 <fd_lookup>
  8022cd:	85 c0                	test   %eax,%eax
  8022cf:	78 15                	js     8022e6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d4:	89 04 24             	mov    %eax,(%esp)
  8022d7:	e8 18 ef ff ff       	call   8011f4 <fd2data>
	return _pipeisclosed(fd, p);
  8022dc:	89 c2                	mov    %eax,%edx
  8022de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e1:	e8 15 fd ff ff       	call   801ffb <_pipeisclosed>
}
  8022e6:	c9                   	leave  
  8022e7:	c3                   	ret    

008022e8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    

008022f2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
  8022f5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8022f8:	c7 44 24 04 bb 2e 80 	movl   $0x802ebb,0x4(%esp)
  8022ff:	00 
  802300:	8b 45 0c             	mov    0xc(%ebp),%eax
  802303:	89 04 24             	mov    %eax,(%esp)
  802306:	e8 60 e4 ff ff       	call   80076b <strcpy>
	return 0;
}
  80230b:	b8 00 00 00 00       	mov    $0x0,%eax
  802310:	c9                   	leave  
  802311:	c3                   	ret    

00802312 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	57                   	push   %edi
  802316:	56                   	push   %esi
  802317:	53                   	push   %ebx
  802318:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80231e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802323:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802329:	eb 30                	jmp    80235b <devcons_write+0x49>
		m = n - tot;
  80232b:	8b 75 10             	mov    0x10(%ebp),%esi
  80232e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802330:	83 fe 7f             	cmp    $0x7f,%esi
  802333:	76 05                	jbe    80233a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802335:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80233a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80233e:	03 45 0c             	add    0xc(%ebp),%eax
  802341:	89 44 24 04          	mov    %eax,0x4(%esp)
  802345:	89 3c 24             	mov    %edi,(%esp)
  802348:	e8 97 e5 ff ff       	call   8008e4 <memmove>
		sys_cputs(buf, m);
  80234d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802351:	89 3c 24             	mov    %edi,(%esp)
  802354:	e8 37 e7 ff ff       	call   800a90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802359:	01 f3                	add    %esi,%ebx
  80235b:	89 d8                	mov    %ebx,%eax
  80235d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802360:	72 c9                	jb     80232b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802362:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    

0080236d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80236d:	55                   	push   %ebp
  80236e:	89 e5                	mov    %esp,%ebp
  802370:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802373:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802377:	75 07                	jne    802380 <devcons_read+0x13>
  802379:	eb 25                	jmp    8023a0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80237b:	e8 be e7 ff ff       	call   800b3e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802380:	e8 29 e7 ff ff       	call   800aae <sys_cgetc>
  802385:	85 c0                	test   %eax,%eax
  802387:	74 f2                	je     80237b <devcons_read+0xe>
  802389:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80238b:	85 c0                	test   %eax,%eax
  80238d:	78 1d                	js     8023ac <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80238f:	83 f8 04             	cmp    $0x4,%eax
  802392:	74 13                	je     8023a7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802394:	8b 45 0c             	mov    0xc(%ebp),%eax
  802397:	88 10                	mov    %dl,(%eax)
	return 1;
  802399:	b8 01 00 00 00       	mov    $0x1,%eax
  80239e:	eb 0c                	jmp    8023ac <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8023a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a5:	eb 05                	jmp    8023ac <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023a7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023ac:	c9                   	leave  
  8023ad:	c3                   	ret    

008023ae <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023ae:	55                   	push   %ebp
  8023af:	89 e5                	mov    %esp,%ebp
  8023b1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8023b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8023c1:	00 
  8023c2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023c5:	89 04 24             	mov    %eax,(%esp)
  8023c8:	e8 c3 e6 ff ff       	call   800a90 <sys_cputs>
}
  8023cd:	c9                   	leave  
  8023ce:	c3                   	ret    

008023cf <getchar>:

int
getchar(void)
{
  8023cf:	55                   	push   %ebp
  8023d0:	89 e5                	mov    %esp,%ebp
  8023d2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023d5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8023dc:	00 
  8023dd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023eb:	e8 10 f1 ff ff       	call   801500 <read>
	if (r < 0)
  8023f0:	85 c0                	test   %eax,%eax
  8023f2:	78 0f                	js     802403 <getchar+0x34>
		return r;
	if (r < 1)
  8023f4:	85 c0                	test   %eax,%eax
  8023f6:	7e 06                	jle    8023fe <getchar+0x2f>
		return -E_EOF;
	return c;
  8023f8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023fc:	eb 05                	jmp    802403 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023fe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802403:	c9                   	leave  
  802404:	c3                   	ret    

00802405 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802405:	55                   	push   %ebp
  802406:	89 e5                	mov    %esp,%ebp
  802408:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80240b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80240e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802412:	8b 45 08             	mov    0x8(%ebp),%eax
  802415:	89 04 24             	mov    %eax,(%esp)
  802418:	e8 45 ee ff ff       	call   801262 <fd_lookup>
  80241d:	85 c0                	test   %eax,%eax
  80241f:	78 11                	js     802432 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802421:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802424:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80242a:	39 10                	cmp    %edx,(%eax)
  80242c:	0f 94 c0             	sete   %al
  80242f:	0f b6 c0             	movzbl %al,%eax
}
  802432:	c9                   	leave  
  802433:	c3                   	ret    

00802434 <opencons>:

int
opencons(void)
{
  802434:	55                   	push   %ebp
  802435:	89 e5                	mov    %esp,%ebp
  802437:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80243a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80243d:	89 04 24             	mov    %eax,(%esp)
  802440:	e8 ca ed ff ff       	call   80120f <fd_alloc>
  802445:	85 c0                	test   %eax,%eax
  802447:	78 3c                	js     802485 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802449:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802450:	00 
  802451:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802454:	89 44 24 04          	mov    %eax,0x4(%esp)
  802458:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80245f:	e8 f9 e6 ff ff       	call   800b5d <sys_page_alloc>
  802464:	85 c0                	test   %eax,%eax
  802466:	78 1d                	js     802485 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802468:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80246e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802471:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802473:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802476:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80247d:	89 04 24             	mov    %eax,(%esp)
  802480:	e8 5f ed ff ff       	call   8011e4 <fd2num>
}
  802485:	c9                   	leave  
  802486:	c3                   	ret    
	...

00802488 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802488:	55                   	push   %ebp
  802489:	89 e5                	mov    %esp,%ebp
  80248b:	56                   	push   %esi
  80248c:	53                   	push   %ebx
  80248d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802490:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802493:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802499:	e8 81 e6 ff ff       	call   800b1f <sys_getenvid>
  80249e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8024a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8024a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b4:	c7 04 24 c8 2e 80 00 	movl   $0x802ec8,(%esp)
  8024bb:	e8 00 dd ff ff       	call   8001c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8024c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8024c7:	89 04 24             	mov    %eax,(%esp)
  8024ca:	e8 90 dc ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  8024cf:	c7 04 24 b4 29 80 00 	movl   $0x8029b4,(%esp)
  8024d6:	e8 e5 dc ff ff       	call   8001c0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8024db:	cc                   	int3   
  8024dc:	eb fd                	jmp    8024db <_panic+0x53>
	...

008024e0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024e6:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024ed:	75 30                	jne    80251f <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8024ef:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8024f6:	00 
  8024f7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8024fe:	ee 
  8024ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802506:	e8 52 e6 ff ff       	call   800b5d <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80250b:	c7 44 24 04 2c 25 80 	movl   $0x80252c,0x4(%esp)
  802512:	00 
  802513:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80251a:	e8 de e7 ff ff       	call   800cfd <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80251f:	8b 45 08             	mov    0x8(%ebp),%eax
  802522:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802527:	c9                   	leave  
  802528:	c3                   	ret    
  802529:	00 00                	add    %al,(%eax)
	...

0080252c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80252c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80252d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802532:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802534:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  802537:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  80253b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  80253f:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  802542:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802544:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802548:	83 c4 08             	add    $0x8,%esp
	popal
  80254b:	61                   	popa   

	addl $4,%esp 
  80254c:	83 c4 04             	add    $0x4,%esp
	popfl
  80254f:	9d                   	popf   

	popl %esp
  802550:	5c                   	pop    %esp

	ret
  802551:	c3                   	ret    
	...

00802554 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802554:	55                   	push   %ebp
  802555:	89 e5                	mov    %esp,%ebp
  802557:	56                   	push   %esi
  802558:	53                   	push   %ebx
  802559:	83 ec 10             	sub    $0x10,%esp
  80255c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80255f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802562:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802565:	85 c0                	test   %eax,%eax
  802567:	74 0a                	je     802573 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802569:	89 04 24             	mov    %eax,(%esp)
  80256c:	e8 02 e8 ff ff       	call   800d73 <sys_ipc_recv>
  802571:	eb 0c                	jmp    80257f <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802573:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80257a:	e8 f4 e7 ff ff       	call   800d73 <sys_ipc_recv>
	}
	if (r < 0)
  80257f:	85 c0                	test   %eax,%eax
  802581:	79 16                	jns    802599 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802583:	85 db                	test   %ebx,%ebx
  802585:	74 06                	je     80258d <ipc_recv+0x39>
  802587:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  80258d:	85 f6                	test   %esi,%esi
  80258f:	74 2c                	je     8025bd <ipc_recv+0x69>
  802591:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802597:	eb 24                	jmp    8025bd <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802599:	85 db                	test   %ebx,%ebx
  80259b:	74 0a                	je     8025a7 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  80259d:	a1 08 40 80 00       	mov    0x804008,%eax
  8025a2:	8b 40 74             	mov    0x74(%eax),%eax
  8025a5:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8025a7:	85 f6                	test   %esi,%esi
  8025a9:	74 0a                	je     8025b5 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8025ab:	a1 08 40 80 00       	mov    0x804008,%eax
  8025b0:	8b 40 78             	mov    0x78(%eax),%eax
  8025b3:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8025b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8025ba:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8025bd:	83 c4 10             	add    $0x10,%esp
  8025c0:	5b                   	pop    %ebx
  8025c1:	5e                   	pop    %esi
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    

008025c4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025c4:	55                   	push   %ebp
  8025c5:	89 e5                	mov    %esp,%ebp
  8025c7:	57                   	push   %edi
  8025c8:	56                   	push   %esi
  8025c9:	53                   	push   %ebx
  8025ca:	83 ec 1c             	sub    $0x1c,%esp
  8025cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8025d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8025d6:	85 db                	test   %ebx,%ebx
  8025d8:	74 19                	je     8025f3 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8025da:	8b 45 14             	mov    0x14(%ebp),%eax
  8025dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025e1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025e9:	89 34 24             	mov    %esi,(%esp)
  8025ec:	e8 5f e7 ff ff       	call   800d50 <sys_ipc_try_send>
  8025f1:	eb 1c                	jmp    80260f <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8025f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8025fa:	00 
  8025fb:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802602:	ee 
  802603:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802607:	89 34 24             	mov    %esi,(%esp)
  80260a:	e8 41 e7 ff ff       	call   800d50 <sys_ipc_try_send>
		}
		if (r == 0)
  80260f:	85 c0                	test   %eax,%eax
  802611:	74 2c                	je     80263f <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802613:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802616:	74 20                	je     802638 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802618:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80261c:	c7 44 24 08 ec 2e 80 	movl   $0x802eec,0x8(%esp)
  802623:	00 
  802624:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80262b:	00 
  80262c:	c7 04 24 ff 2e 80 00 	movl   $0x802eff,(%esp)
  802633:	e8 50 fe ff ff       	call   802488 <_panic>
		}
		sys_yield();
  802638:	e8 01 e5 ff ff       	call   800b3e <sys_yield>
	}
  80263d:	eb 97                	jmp    8025d6 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80263f:	83 c4 1c             	add    $0x1c,%esp
  802642:	5b                   	pop    %ebx
  802643:	5e                   	pop    %esi
  802644:	5f                   	pop    %edi
  802645:	5d                   	pop    %ebp
  802646:	c3                   	ret    

00802647 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802647:	55                   	push   %ebp
  802648:	89 e5                	mov    %esp,%ebp
  80264a:	53                   	push   %ebx
  80264b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80264e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802653:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80265a:	89 c2                	mov    %eax,%edx
  80265c:	c1 e2 07             	shl    $0x7,%edx
  80265f:	29 ca                	sub    %ecx,%edx
  802661:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802667:	8b 52 50             	mov    0x50(%edx),%edx
  80266a:	39 da                	cmp    %ebx,%edx
  80266c:	75 0f                	jne    80267d <ipc_find_env+0x36>
			return envs[i].env_id;
  80266e:	c1 e0 07             	shl    $0x7,%eax
  802671:	29 c8                	sub    %ecx,%eax
  802673:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802678:	8b 40 40             	mov    0x40(%eax),%eax
  80267b:	eb 0c                	jmp    802689 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80267d:	40                   	inc    %eax
  80267e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802683:	75 ce                	jne    802653 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802685:	66 b8 00 00          	mov    $0x0,%ax
}
  802689:	5b                   	pop    %ebx
  80268a:	5d                   	pop    %ebp
  80268b:	c3                   	ret    

0080268c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80268c:	55                   	push   %ebp
  80268d:	89 e5                	mov    %esp,%ebp
  80268f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802692:	89 c2                	mov    %eax,%edx
  802694:	c1 ea 16             	shr    $0x16,%edx
  802697:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80269e:	f6 c2 01             	test   $0x1,%dl
  8026a1:	74 1e                	je     8026c1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026a3:	c1 e8 0c             	shr    $0xc,%eax
  8026a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026ad:	a8 01                	test   $0x1,%al
  8026af:	74 17                	je     8026c8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026b1:	c1 e8 0c             	shr    $0xc,%eax
  8026b4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8026bb:	ef 
  8026bc:	0f b7 c0             	movzwl %ax,%eax
  8026bf:	eb 0c                	jmp    8026cd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8026c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8026c6:	eb 05                	jmp    8026cd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8026c8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8026cd:	5d                   	pop    %ebp
  8026ce:	c3                   	ret    
	...

008026d0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8026d0:	55                   	push   %ebp
  8026d1:	57                   	push   %edi
  8026d2:	56                   	push   %esi
  8026d3:	83 ec 10             	sub    $0x10,%esp
  8026d6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8026da:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026e2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8026e6:	89 cd                	mov    %ecx,%ebp
  8026e8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026ec:	85 c0                	test   %eax,%eax
  8026ee:	75 2c                	jne    80271c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8026f0:	39 f9                	cmp    %edi,%ecx
  8026f2:	77 68                	ja     80275c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026f4:	85 c9                	test   %ecx,%ecx
  8026f6:	75 0b                	jne    802703 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8026fd:	31 d2                	xor    %edx,%edx
  8026ff:	f7 f1                	div    %ecx
  802701:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802703:	31 d2                	xor    %edx,%edx
  802705:	89 f8                	mov    %edi,%eax
  802707:	f7 f1                	div    %ecx
  802709:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80270b:	89 f0                	mov    %esi,%eax
  80270d:	f7 f1                	div    %ecx
  80270f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802711:	89 f0                	mov    %esi,%eax
  802713:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802715:	83 c4 10             	add    $0x10,%esp
  802718:	5e                   	pop    %esi
  802719:	5f                   	pop    %edi
  80271a:	5d                   	pop    %ebp
  80271b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80271c:	39 f8                	cmp    %edi,%eax
  80271e:	77 2c                	ja     80274c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802720:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802723:	83 f6 1f             	xor    $0x1f,%esi
  802726:	75 4c                	jne    802774 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802728:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80272a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80272f:	72 0a                	jb     80273b <__udivdi3+0x6b>
  802731:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802735:	0f 87 ad 00 00 00    	ja     8027e8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80273b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802740:	89 f0                	mov    %esi,%eax
  802742:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802744:	83 c4 10             	add    $0x10,%esp
  802747:	5e                   	pop    %esi
  802748:	5f                   	pop    %edi
  802749:	5d                   	pop    %ebp
  80274a:	c3                   	ret    
  80274b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80274c:	31 ff                	xor    %edi,%edi
  80274e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802750:	89 f0                	mov    %esi,%eax
  802752:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802754:	83 c4 10             	add    $0x10,%esp
  802757:	5e                   	pop    %esi
  802758:	5f                   	pop    %edi
  802759:	5d                   	pop    %ebp
  80275a:	c3                   	ret    
  80275b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80275c:	89 fa                	mov    %edi,%edx
  80275e:	89 f0                	mov    %esi,%eax
  802760:	f7 f1                	div    %ecx
  802762:	89 c6                	mov    %eax,%esi
  802764:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802766:	89 f0                	mov    %esi,%eax
  802768:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80276a:	83 c4 10             	add    $0x10,%esp
  80276d:	5e                   	pop    %esi
  80276e:	5f                   	pop    %edi
  80276f:	5d                   	pop    %ebp
  802770:	c3                   	ret    
  802771:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802774:	89 f1                	mov    %esi,%ecx
  802776:	d3 e0                	shl    %cl,%eax
  802778:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80277c:	b8 20 00 00 00       	mov    $0x20,%eax
  802781:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802783:	89 ea                	mov    %ebp,%edx
  802785:	88 c1                	mov    %al,%cl
  802787:	d3 ea                	shr    %cl,%edx
  802789:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80278d:	09 ca                	or     %ecx,%edx
  80278f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802793:	89 f1                	mov    %esi,%ecx
  802795:	d3 e5                	shl    %cl,%ebp
  802797:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80279b:	89 fd                	mov    %edi,%ebp
  80279d:	88 c1                	mov    %al,%cl
  80279f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8027a1:	89 fa                	mov    %edi,%edx
  8027a3:	89 f1                	mov    %esi,%ecx
  8027a5:	d3 e2                	shl    %cl,%edx
  8027a7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8027ab:	88 c1                	mov    %al,%cl
  8027ad:	d3 ef                	shr    %cl,%edi
  8027af:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027b1:	89 f8                	mov    %edi,%eax
  8027b3:	89 ea                	mov    %ebp,%edx
  8027b5:	f7 74 24 08          	divl   0x8(%esp)
  8027b9:	89 d1                	mov    %edx,%ecx
  8027bb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8027bd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027c1:	39 d1                	cmp    %edx,%ecx
  8027c3:	72 17                	jb     8027dc <__udivdi3+0x10c>
  8027c5:	74 09                	je     8027d0 <__udivdi3+0x100>
  8027c7:	89 fe                	mov    %edi,%esi
  8027c9:	31 ff                	xor    %edi,%edi
  8027cb:	e9 41 ff ff ff       	jmp    802711 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8027d0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027d4:	89 f1                	mov    %esi,%ecx
  8027d6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027d8:	39 c2                	cmp    %eax,%edx
  8027da:	73 eb                	jae    8027c7 <__udivdi3+0xf7>
		{
		  q0--;
  8027dc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027df:	31 ff                	xor    %edi,%edi
  8027e1:	e9 2b ff ff ff       	jmp    802711 <__udivdi3+0x41>
  8027e6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027e8:	31 f6                	xor    %esi,%esi
  8027ea:	e9 22 ff ff ff       	jmp    802711 <__udivdi3+0x41>
	...

008027f0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8027f0:	55                   	push   %ebp
  8027f1:	57                   	push   %edi
  8027f2:	56                   	push   %esi
  8027f3:	83 ec 20             	sub    $0x20,%esp
  8027f6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8027fa:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8027fe:	89 44 24 14          	mov    %eax,0x14(%esp)
  802802:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802806:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80280a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80280e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802810:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802812:	85 ed                	test   %ebp,%ebp
  802814:	75 16                	jne    80282c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802816:	39 f1                	cmp    %esi,%ecx
  802818:	0f 86 a6 00 00 00    	jbe    8028c4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80281e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802820:	89 d0                	mov    %edx,%eax
  802822:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802824:	83 c4 20             	add    $0x20,%esp
  802827:	5e                   	pop    %esi
  802828:	5f                   	pop    %edi
  802829:	5d                   	pop    %ebp
  80282a:	c3                   	ret    
  80282b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80282c:	39 f5                	cmp    %esi,%ebp
  80282e:	0f 87 ac 00 00 00    	ja     8028e0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802834:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802837:	83 f0 1f             	xor    $0x1f,%eax
  80283a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80283e:	0f 84 a8 00 00 00    	je     8028ec <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802844:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802848:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80284a:	bf 20 00 00 00       	mov    $0x20,%edi
  80284f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802853:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802857:	89 f9                	mov    %edi,%ecx
  802859:	d3 e8                	shr    %cl,%eax
  80285b:	09 e8                	or     %ebp,%eax
  80285d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802861:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802865:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802869:	d3 e0                	shl    %cl,%eax
  80286b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80286f:	89 f2                	mov    %esi,%edx
  802871:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802873:	8b 44 24 14          	mov    0x14(%esp),%eax
  802877:	d3 e0                	shl    %cl,%eax
  802879:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80287d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802881:	89 f9                	mov    %edi,%ecx
  802883:	d3 e8                	shr    %cl,%eax
  802885:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802887:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802889:	89 f2                	mov    %esi,%edx
  80288b:	f7 74 24 18          	divl   0x18(%esp)
  80288f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802891:	f7 64 24 0c          	mull   0xc(%esp)
  802895:	89 c5                	mov    %eax,%ebp
  802897:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802899:	39 d6                	cmp    %edx,%esi
  80289b:	72 67                	jb     802904 <__umoddi3+0x114>
  80289d:	74 75                	je     802914 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80289f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8028a3:	29 e8                	sub    %ebp,%eax
  8028a5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8028a7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028ab:	d3 e8                	shr    %cl,%eax
  8028ad:	89 f2                	mov    %esi,%edx
  8028af:	89 f9                	mov    %edi,%ecx
  8028b1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8028b3:	09 d0                	or     %edx,%eax
  8028b5:	89 f2                	mov    %esi,%edx
  8028b7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028bb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028bd:	83 c4 20             	add    $0x20,%esp
  8028c0:	5e                   	pop    %esi
  8028c1:	5f                   	pop    %edi
  8028c2:	5d                   	pop    %ebp
  8028c3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8028c4:	85 c9                	test   %ecx,%ecx
  8028c6:	75 0b                	jne    8028d3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8028c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8028cd:	31 d2                	xor    %edx,%edx
  8028cf:	f7 f1                	div    %ecx
  8028d1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8028d3:	89 f0                	mov    %esi,%eax
  8028d5:	31 d2                	xor    %edx,%edx
  8028d7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028d9:	89 f8                	mov    %edi,%eax
  8028db:	e9 3e ff ff ff       	jmp    80281e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8028e0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028e2:	83 c4 20             	add    $0x20,%esp
  8028e5:	5e                   	pop    %esi
  8028e6:	5f                   	pop    %edi
  8028e7:	5d                   	pop    %ebp
  8028e8:	c3                   	ret    
  8028e9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028ec:	39 f5                	cmp    %esi,%ebp
  8028ee:	72 04                	jb     8028f4 <__umoddi3+0x104>
  8028f0:	39 f9                	cmp    %edi,%ecx
  8028f2:	77 06                	ja     8028fa <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028f4:	89 f2                	mov    %esi,%edx
  8028f6:	29 cf                	sub    %ecx,%edi
  8028f8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8028fa:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028fc:	83 c4 20             	add    $0x20,%esp
  8028ff:	5e                   	pop    %esi
  802900:	5f                   	pop    %edi
  802901:	5d                   	pop    %ebp
  802902:	c3                   	ret    
  802903:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802904:	89 d1                	mov    %edx,%ecx
  802906:	89 c5                	mov    %eax,%ebp
  802908:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80290c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802910:	eb 8d                	jmp    80289f <__umoddi3+0xaf>
  802912:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802914:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802918:	72 ea                	jb     802904 <__umoddi3+0x114>
  80291a:	89 f1                	mov    %esi,%ecx
  80291c:	eb 81                	jmp    80289f <__umoddi3+0xaf>
