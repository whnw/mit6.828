
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 08 40 80 00       	mov    0x804008,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 e0 24 80 00 	movl   $0x8024e0,(%esp)
  80004e:	e8 5d 01 00 00       	call   8001b0 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 d1 0a 00 00       	call   800b2e <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 08 40 80 00       	mov    0x804008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  800074:	e8 37 01 00 00       	call   8001b0 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	43                   	inc    %ebx
  80007a:	83 fb 05             	cmp    $0x5,%ebx
  80007d:	75 d9                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007f:	a1 08 40 80 00       	mov    0x804008,%eax
  800084:	8b 40 48             	mov    0x48(%eax),%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 2c 25 80 00 	movl   $0x80252c,(%esp)
  800092:	e8 19 01 00 00       	call   8001b0 <cprintf>
}
  800097:	83 c4 14             	add    $0x14,%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ae:	e8 5c 0a 00 00       	call   800b0f <sys_getenvid>
  8000b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000bf:	c1 e0 07             	shl    $0x7,%eax
  8000c2:	29 d0                	sub    %edx,%eax
  8000c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c9:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ce:	85 f6                	test   %esi,%esi
  8000d0:	7e 07                	jle    8000d9 <libmain+0x39>
		binaryname = argv[0];
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000dd:	89 34 24             	mov    %esi,(%esp)
  8000e0:	e8 4f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e5:	e8 0a 00 00 00       	call   8000f4 <exit>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    
  8000f1:	00 00                	add    %al,(%eax)
	...

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000fa:	e8 00 0f 00 00       	call   800fff <close_all>
	sys_env_destroy(0);
  8000ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800106:	e8 b2 09 00 00       	call   800abd <sys_env_destroy>
}
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    
  80010d:	00 00                	add    %al,(%eax)
	...

00800110 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	53                   	push   %ebx
  800114:	83 ec 14             	sub    $0x14,%esp
  800117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011a:	8b 03                	mov    (%ebx),%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800123:	40                   	inc    %eax
  800124:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800126:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012b:	75 19                	jne    800146 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80012d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800134:	00 
  800135:	8d 43 08             	lea    0x8(%ebx),%eax
  800138:	89 04 24             	mov    %eax,(%esp)
  80013b:	e8 40 09 00 00       	call   800a80 <sys_cputs>
		b->idx = 0;
  800140:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800146:	ff 43 04             	incl   0x4(%ebx)
}
  800149:	83 c4 14             	add    $0x14,%esp
  80014c:	5b                   	pop    %ebx
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800173:	8b 45 08             	mov    0x8(%ebp),%eax
  800176:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
  800184:	c7 04 24 10 01 80 00 	movl   $0x800110,(%esp)
  80018b:	e8 82 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800190:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 d8 08 00 00       	call   800a80 <sys_cputs>

	return b.cnt;
}
  8001a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 87 ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    
	...

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 3c             	sub    $0x3c,%esp
  8001d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d8:	89 d7                	mov    %edx,%edi
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	75 08                	jne    8001f8 <printnum+0x2c>
  8001f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 57                	ja     80024f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001fc:	4b                   	dec    %ebx
  8001fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800201:	8b 45 10             	mov    0x10(%ebp),%eax
  800204:	89 44 24 08          	mov    %eax,0x8(%esp)
  800208:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80020c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800210:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800217:	00 
  800218:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021b:	89 04 24             	mov    %eax,(%esp)
  80021e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800221:	89 44 24 04          	mov    %eax,0x4(%esp)
  800225:	e8 66 20 00 00       	call   802290 <__udivdi3>
  80022a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80022e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	89 54 24 04          	mov    %edx,0x4(%esp)
  800239:	89 fa                	mov    %edi,%edx
  80023b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023e:	e8 89 ff ff ff       	call   8001cc <printnum>
  800243:	eb 0f                	jmp    800254 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800245:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800249:	89 34 24             	mov    %esi,(%esp)
  80024c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024f:	4b                   	dec    %ebx
  800250:	85 db                	test   %ebx,%ebx
  800252:	7f f1                	jg     800245 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800254:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800258:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80025c:	8b 45 10             	mov    0x10(%ebp),%eax
  80025f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800263:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026a:	00 
  80026b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	e8 33 21 00 00       	call   8023b0 <__umoddi3>
  80027d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800281:	0f be 80 55 25 80 00 	movsbl 0x802555(%eax),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80028e:	83 c4 3c             	add    $0x3c,%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800299:	83 fa 01             	cmp    $0x1,%edx
  80029c:	7e 0e                	jle    8002ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	8b 52 04             	mov    0x4(%edx),%edx
  8002aa:	eb 22                	jmp    8002ce <getuint+0x38>
	else if (lflag)
  8002ac:	85 d2                	test   %edx,%edx
  8002ae:	74 10                	je     8002c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002be:	eb 0e                	jmp    8002ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	3b 50 04             	cmp    0x4(%eax),%edx
  8002de:	73 08                	jae    8002e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e3:	88 0a                	mov    %cl,(%edx)
  8002e5:	42                   	inc    %edx
  8002e6:	89 10                	mov    %edx,(%eax)
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800301:	89 44 24 04          	mov    %eax,0x4(%esp)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	e8 02 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 4c             	sub    $0x4c,%esp
  80031b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031e:	8b 75 10             	mov    0x10(%ebp),%esi
  800321:	eb 12                	jmp    800335 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800323:	85 c0                	test   %eax,%eax
  800325:	0f 84 6b 03 00 00    	je     800696 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80032b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800335:	0f b6 06             	movzbl (%esi),%eax
  800338:	46                   	inc    %esi
  800339:	83 f8 25             	cmp    $0x25,%eax
  80033c:	75 e5                	jne    800323 <vprintfmt+0x11>
  80033e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800342:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800349:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80034e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800355:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035a:	eb 26                	jmp    800382 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800363:	eb 1d                	jmp    800382 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80036c:	eb 14                	jmp    800382 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800371:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800378:	eb 08                	jmp    800382 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80037a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80037d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	0f b6 06             	movzbl (%esi),%eax
  800385:	8d 56 01             	lea    0x1(%esi),%edx
  800388:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80038b:	8a 16                	mov    (%esi),%dl
  80038d:	83 ea 23             	sub    $0x23,%edx
  800390:	80 fa 55             	cmp    $0x55,%dl
  800393:	0f 87 e1 02 00 00    	ja     80067a <vprintfmt+0x368>
  800399:	0f b6 d2             	movzbl %dl,%edx
  80039c:	ff 24 95 a0 26 80 00 	jmp    *0x8026a0(,%edx,4)
  8003a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b8:	83 fa 09             	cmp    $0x9,%edx
  8003bb:	77 2a                	ja     8003e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003be:	eb eb                	jmp    8003ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 50 04             	lea    0x4(%eax),%edx
  8003c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ce:	eb 17                	jmp    8003e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d4:	78 98                	js     80036e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003d9:	eb a7                	jmp    800382 <vprintfmt+0x70>
  8003db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003e5:	eb 9b                	jmp    800382 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003eb:	79 95                	jns    800382 <vprintfmt+0x70>
  8003ed:	eb 8b                	jmp    80037a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f3:	eb 8d                	jmp    800382 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 50 04             	lea    0x4(%eax),%edx
  8003fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800402:	8b 00                	mov    (%eax),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040d:	e9 23 ff ff ff       	jmp    800335 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	89 55 14             	mov    %edx,0x14(%ebp)
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	85 c0                	test   %eax,%eax
  80041f:	79 02                	jns    800423 <vprintfmt+0x111>
  800421:	f7 d8                	neg    %eax
  800423:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800425:	83 f8 10             	cmp    $0x10,%eax
  800428:	7f 0b                	jg     800435 <vprintfmt+0x123>
  80042a:	8b 04 85 00 28 80 00 	mov    0x802800(,%eax,4),%eax
  800431:	85 c0                	test   %eax,%eax
  800433:	75 23                	jne    800458 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800435:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800439:	c7 44 24 08 6d 25 80 	movl   $0x80256d,0x8(%esp)
  800440:	00 
  800441:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 9a fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800453:	e9 dd fe ff ff       	jmp    800335 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800458:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045c:	c7 44 24 08 39 29 80 	movl   $0x802939,0x8(%esp)
  800463:	00 
  800464:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800468:	8b 55 08             	mov    0x8(%ebp),%edx
  80046b:	89 14 24             	mov    %edx,(%esp)
  80046e:	e8 77 fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800476:	e9 ba fe ff ff       	jmp    800335 <vprintfmt+0x23>
  80047b:	89 f9                	mov    %edi,%ecx
  80047d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800480:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 50 04             	lea    0x4(%eax),%edx
  800489:	89 55 14             	mov    %edx,0x14(%ebp)
  80048c:	8b 30                	mov    (%eax),%esi
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 05                	jne    800497 <vprintfmt+0x185>
				p = "(null)";
  800492:	be 66 25 80 00       	mov    $0x802566,%esi
			if (width > 0 && padc != '-')
  800497:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80049b:	0f 8e 84 00 00 00    	jle    800525 <vprintfmt+0x213>
  8004a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004a5:	74 7e                	je     800525 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ab:	89 34 24             	mov    %esi,(%esp)
  8004ae:	e8 8b 02 00 00       	call   80073e <strnlen>
  8004b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b6:	29 c2                	sub    %eax,%edx
  8004b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004c5:	89 de                	mov    %ebx,%esi
  8004c7:	89 d3                	mov    %edx,%ebx
  8004c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	eb 0b                	jmp    8004d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d1:	89 3c 24             	mov    %edi,(%esp)
  8004d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	4b                   	dec    %ebx
  8004d8:	85 db                	test   %ebx,%ebx
  8004da:	7f f1                	jg     8004cd <vprintfmt+0x1bb>
  8004dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004df:	89 f3                	mov    %esi,%ebx
  8004e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	79 05                	jns    8004f0 <vprintfmt+0x1de>
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f3:	29 c2                	sub    %eax,%edx
  8004f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f8:	eb 2b                	jmp    800525 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004fe:	74 18                	je     800518 <vprintfmt+0x206>
  800500:	8d 50 e0             	lea    -0x20(%eax),%edx
  800503:	83 fa 5e             	cmp    $0x5e,%edx
  800506:	76 10                	jbe    800518 <vprintfmt+0x206>
					putch('?', putdat);
  800508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800513:	ff 55 08             	call   *0x8(%ebp)
  800516:	eb 0a                	jmp    800522 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800522:	ff 4d e4             	decl   -0x1c(%ebp)
  800525:	0f be 06             	movsbl (%esi),%eax
  800528:	46                   	inc    %esi
  800529:	85 c0                	test   %eax,%eax
  80052b:	74 21                	je     80054e <vprintfmt+0x23c>
  80052d:	85 ff                	test   %edi,%edi
  80052f:	78 c9                	js     8004fa <vprintfmt+0x1e8>
  800531:	4f                   	dec    %edi
  800532:	79 c6                	jns    8004fa <vprintfmt+0x1e8>
  800534:	8b 7d 08             	mov    0x8(%ebp),%edi
  800537:	89 de                	mov    %ebx,%esi
  800539:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053c:	eb 18                	jmp    800556 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800542:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800549:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054b:	4b                   	dec    %ebx
  80054c:	eb 08                	jmp    800556 <vprintfmt+0x244>
  80054e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800551:	89 de                	mov    %ebx,%esi
  800553:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800556:	85 db                	test   %ebx,%ebx
  800558:	7f e4                	jg     80053e <vprintfmt+0x22c>
  80055a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80055d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800562:	e9 ce fd ff ff       	jmp    800335 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7e 10                	jle    80057c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 50 08             	lea    0x8(%eax),%edx
  800572:	89 55 14             	mov    %edx,0x14(%ebp)
  800575:	8b 30                	mov    (%eax),%esi
  800577:	8b 78 04             	mov    0x4(%eax),%edi
  80057a:	eb 26                	jmp    8005a2 <vprintfmt+0x290>
	else if (lflag)
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	74 12                	je     800592 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 30                	mov    (%eax),%esi
  80058b:	89 f7                	mov    %esi,%edi
  80058d:	c1 ff 1f             	sar    $0x1f,%edi
  800590:	eb 10                	jmp    8005a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 30                	mov    (%eax),%esi
  80059d:	89 f7                	mov    %esi,%edi
  80059f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a2:	85 ff                	test   %edi,%edi
  8005a4:	78 0a                	js     8005b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 8c 00 00 00       	jmp    80063c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005be:	f7 de                	neg    %esi
  8005c0:	83 d7 00             	adc    $0x0,%edi
  8005c3:	f7 df                	neg    %edi
			}
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ca:	eb 70                	jmp    80063c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cc:	89 ca                	mov    %ecx,%edx
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 c0 fc ff ff       	call   800296 <getuint>
  8005d6:	89 c6                	mov    %eax,%esi
  8005d8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005df:	eb 5b                	jmp    80063c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8005e1:	89 ca                	mov    %ecx,%edx
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	e8 ab fc ff ff       	call   800296 <getuint>
  8005eb:	89 c6                	mov    %eax,%esi
  8005ed:	89 d7                	mov    %edx,%edi
			base = 8;
  8005ef:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005f4:	eb 46                	jmp    80063c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800601:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061b:	8b 30                	mov    (%eax),%esi
  80061d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800622:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800627:	eb 13                	jmp    80063c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800629:	89 ca                	mov    %ecx,%edx
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 63 fc ff ff       	call   800296 <getuint>
  800633:	89 c6                	mov    %eax,%esi
  800635:	89 d7                	mov    %edx,%edi
			base = 16;
  800637:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800640:	89 54 24 10          	mov    %edx,0x10(%esp)
  800644:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800647:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80064b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80064f:	89 34 24             	mov    %esi,(%esp)
  800652:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800656:	89 da                	mov    %ebx,%edx
  800658:	8b 45 08             	mov    0x8(%ebp),%eax
  80065b:	e8 6c fb ff ff       	call   8001cc <printnum>
			break;
  800660:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800663:	e9 cd fc ff ff       	jmp    800335 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	89 04 24             	mov    %eax,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800675:	e9 bb fc ff ff       	jmp    800335 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800685:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800688:	eb 01                	jmp    80068b <vprintfmt+0x379>
  80068a:	4e                   	dec    %esi
  80068b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068f:	75 f9                	jne    80068a <vprintfmt+0x378>
  800691:	e9 9f fc ff ff       	jmp    800335 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800696:	83 c4 4c             	add    $0x4c,%esp
  800699:	5b                   	pop    %ebx
  80069a:	5e                   	pop    %esi
  80069b:	5f                   	pop    %edi
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	83 ec 28             	sub    $0x28,%esp
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	74 30                	je     8006ef <vsnprintf+0x51>
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	7e 33                	jle    8006f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d8:	c7 04 24 d0 02 80 00 	movl   $0x8002d0,(%esp)
  8006df:	e8 2e fc ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ed:	eb 0c                	jmp    8006fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f4:	eb 05                	jmp    8006fb <vsnprintf+0x5d>
  8006f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800706:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070a:	8b 45 10             	mov    0x10(%ebp),%eax
  80070d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	e8 7b ff ff ff       	call   80069e <vsnprintf>
	va_end(ap);

	return rc;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    
  800725:	00 00                	add    %al,(%eax)
	...

00800728 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax
  800733:	eb 01                	jmp    800736 <strlen+0xe>
		n++;
  800735:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073a:	75 f9                	jne    800735 <strlen+0xd>
		n++;
	return n;
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 01                	jmp    80074f <strnlen+0x11>
		n++;
  80074e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	39 d0                	cmp    %edx,%eax
  800751:	74 06                	je     800759 <strnlen+0x1b>
  800753:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800757:	75 f5                	jne    80074e <strnlen+0x10>
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800765:	ba 00 00 00 00       	mov    $0x0,%edx
  80076a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80076d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800770:	42                   	inc    %edx
  800771:	84 c9                	test   %cl,%cl
  800773:	75 f5                	jne    80076a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800775:	5b                   	pop    %ebx
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800782:	89 1c 24             	mov    %ebx,(%esp)
  800785:	e8 9e ff ff ff       	call   800728 <strlen>
	strcpy(dst + len, src);
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800791:	01 d8                	add    %ebx,%eax
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	e8 c0 ff ff ff       	call   80075b <strcpy>
	return dst;
}
  80079b:	89 d8                	mov    %ebx,%eax
  80079d:	83 c4 08             	add    $0x8,%esp
  8007a0:	5b                   	pop    %ebx
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	56                   	push   %esi
  8007a7:	53                   	push   %ebx
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	eb 0c                	jmp    8007c4 <strncpy+0x21>
		*dst++ = *src;
  8007b8:	8a 1a                	mov    (%edx),%bl
  8007ba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c3:	41                   	inc    %ecx
  8007c4:	39 f1                	cmp    %esi,%ecx
  8007c6:	75 f0                	jne    8007b8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	75 0a                	jne    8007e8 <strlcpy+0x1c>
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	eb 1a                	jmp    8007fc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e2:	88 18                	mov    %bl,(%eax)
  8007e4:	40                   	inc    %eax
  8007e5:	41                   	inc    %ecx
  8007e6:	eb 02                	jmp    8007ea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ea:	4a                   	dec    %edx
  8007eb:	74 0a                	je     8007f7 <strlcpy+0x2b>
  8007ed:	8a 19                	mov    (%ecx),%bl
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	75 ef                	jne    8007e2 <strlcpy+0x16>
  8007f3:	89 c2                	mov    %eax,%edx
  8007f5:	eb 02                	jmp    8007f9 <strlcpy+0x2d>
  8007f7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007f9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007fc:	29 f0                	sub    %esi,%eax
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080b:	eb 02                	jmp    80080f <strcmp+0xd>
		p++, q++;
  80080d:	41                   	inc    %ecx
  80080e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080f:	8a 01                	mov    (%ecx),%al
  800811:	84 c0                	test   %al,%al
  800813:	74 04                	je     800819 <strcmp+0x17>
  800815:	3a 02                	cmp    (%edx),%al
  800817:	74 f4                	je     80080d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800819:	0f b6 c0             	movzbl %al,%eax
  80081c:	0f b6 12             	movzbl (%edx),%edx
  80081f:	29 d0                	sub    %edx,%eax
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800830:	eb 03                	jmp    800835 <strncmp+0x12>
		n--, p++, q++;
  800832:	4a                   	dec    %edx
  800833:	40                   	inc    %eax
  800834:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800835:	85 d2                	test   %edx,%edx
  800837:	74 14                	je     80084d <strncmp+0x2a>
  800839:	8a 18                	mov    (%eax),%bl
  80083b:	84 db                	test   %bl,%bl
  80083d:	74 04                	je     800843 <strncmp+0x20>
  80083f:	3a 19                	cmp    (%ecx),%bl
  800841:	74 ef                	je     800832 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 00             	movzbl (%eax),%eax
  800846:	0f b6 11             	movzbl (%ecx),%edx
  800849:	29 d0                	sub    %edx,%eax
  80084b:	eb 05                	jmp    800852 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085e:	eb 05                	jmp    800865 <strchr+0x10>
		if (*s == c)
  800860:	38 ca                	cmp    %cl,%dl
  800862:	74 0c                	je     800870 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800864:	40                   	inc    %eax
  800865:	8a 10                	mov    (%eax),%dl
  800867:	84 d2                	test   %dl,%dl
  800869:	75 f5                	jne    800860 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087b:	eb 05                	jmp    800882 <strfind+0x10>
		if (*s == c)
  80087d:	38 ca                	cmp    %cl,%dl
  80087f:	74 07                	je     800888 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800881:	40                   	inc    %eax
  800882:	8a 10                	mov    (%eax),%dl
  800884:	84 d2                	test   %dl,%dl
  800886:	75 f5                	jne    80087d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 7d 08             	mov    0x8(%ebp),%edi
  800893:	8b 45 0c             	mov    0xc(%ebp),%eax
  800896:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800899:	85 c9                	test   %ecx,%ecx
  80089b:	74 30                	je     8008cd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a3:	75 25                	jne    8008ca <memset+0x40>
  8008a5:	f6 c1 03             	test   $0x3,%cl
  8008a8:	75 20                	jne    8008ca <memset+0x40>
		c &= 0xFF;
  8008aa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ad:	89 d3                	mov    %edx,%ebx
  8008af:	c1 e3 08             	shl    $0x8,%ebx
  8008b2:	89 d6                	mov    %edx,%esi
  8008b4:	c1 e6 18             	shl    $0x18,%esi
  8008b7:	89 d0                	mov    %edx,%eax
  8008b9:	c1 e0 10             	shl    $0x10,%eax
  8008bc:	09 f0                	or     %esi,%eax
  8008be:	09 d0                	or     %edx,%eax
  8008c0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008c2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008c5:	fc                   	cld    
  8008c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c8:	eb 03                	jmp    8008cd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	fc                   	cld    
  8008cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008cd:	89 f8                	mov    %edi,%eax
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5f                   	pop    %edi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e2:	39 c6                	cmp    %eax,%esi
  8008e4:	73 34                	jae    80091a <memmove+0x46>
  8008e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e9:	39 d0                	cmp    %edx,%eax
  8008eb:	73 2d                	jae    80091a <memmove+0x46>
		s += n;
		d += n;
  8008ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f0:	f6 c2 03             	test   $0x3,%dl
  8008f3:	75 1b                	jne    800910 <memmove+0x3c>
  8008f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fb:	75 13                	jne    800910 <memmove+0x3c>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 0e                	jne    800910 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800902:	83 ef 04             	sub    $0x4,%edi
  800905:	8d 72 fc             	lea    -0x4(%edx),%esi
  800908:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80090b:	fd                   	std    
  80090c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090e:	eb 07                	jmp    800917 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800910:	4f                   	dec    %edi
  800911:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800914:	fd                   	std    
  800915:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800917:	fc                   	cld    
  800918:	eb 20                	jmp    80093a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800920:	75 13                	jne    800935 <memmove+0x61>
  800922:	a8 03                	test   $0x3,%al
  800924:	75 0f                	jne    800935 <memmove+0x61>
  800926:	f6 c1 03             	test   $0x3,%cl
  800929:	75 0a                	jne    800935 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80092b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80092e:	89 c7                	mov    %eax,%edi
  800930:	fc                   	cld    
  800931:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800933:	eb 05                	jmp    80093a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800935:	89 c7                	mov    %eax,%edi
  800937:	fc                   	cld    
  800938:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800944:	8b 45 10             	mov    0x10(%ebp),%eax
  800947:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	89 04 24             	mov    %eax,(%esp)
  800958:	e8 77 ff ff ff       	call   8008d4 <memmove>
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 7d 08             	mov    0x8(%ebp),%edi
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	eb 16                	jmp    80098b <memcmp+0x2c>
		if (*s1 != *s2)
  800975:	8a 04 17             	mov    (%edi,%edx,1),%al
  800978:	42                   	inc    %edx
  800979:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80097d:	38 c8                	cmp    %cl,%al
  80097f:	74 0a                	je     80098b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800981:	0f b6 c0             	movzbl %al,%eax
  800984:	0f b6 c9             	movzbl %cl,%ecx
  800987:	29 c8                	sub    %ecx,%eax
  800989:	eb 09                	jmp    800994 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098b:	39 da                	cmp    %ebx,%edx
  80098d:	75 e6                	jne    800975 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a7:	eb 05                	jmp    8009ae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a9:	38 08                	cmp    %cl,(%eax)
  8009ab:	74 05                	je     8009b2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ad:	40                   	inc    %eax
  8009ae:	39 d0                	cmp    %edx,%eax
  8009b0:	72 f7                	jb     8009a9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c0:	eb 01                	jmp    8009c3 <strtol+0xf>
		s++;
  8009c2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c3:	8a 02                	mov    (%edx),%al
  8009c5:	3c 20                	cmp    $0x20,%al
  8009c7:	74 f9                	je     8009c2 <strtol+0xe>
  8009c9:	3c 09                	cmp    $0x9,%al
  8009cb:	74 f5                	je     8009c2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009cd:	3c 2b                	cmp    $0x2b,%al
  8009cf:	75 08                	jne    8009d9 <strtol+0x25>
		s++;
  8009d1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d7:	eb 13                	jmp    8009ec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d9:	3c 2d                	cmp    $0x2d,%al
  8009db:	75 0a                	jne    8009e7 <strtol+0x33>
		s++, neg = 1;
  8009dd:	8d 52 01             	lea    0x1(%edx),%edx
  8009e0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e5:	eb 05                	jmp    8009ec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ec:	85 db                	test   %ebx,%ebx
  8009ee:	74 05                	je     8009f5 <strtol+0x41>
  8009f0:	83 fb 10             	cmp    $0x10,%ebx
  8009f3:	75 28                	jne    800a1d <strtol+0x69>
  8009f5:	8a 02                	mov    (%edx),%al
  8009f7:	3c 30                	cmp    $0x30,%al
  8009f9:	75 10                	jne    800a0b <strtol+0x57>
  8009fb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009ff:	75 0a                	jne    800a0b <strtol+0x57>
		s += 2, base = 16;
  800a01:	83 c2 02             	add    $0x2,%edx
  800a04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a09:	eb 12                	jmp    800a1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a0b:	85 db                	test   %ebx,%ebx
  800a0d:	75 0e                	jne    800a1d <strtol+0x69>
  800a0f:	3c 30                	cmp    $0x30,%al
  800a11:	75 05                	jne    800a18 <strtol+0x64>
		s++, base = 8;
  800a13:	42                   	inc    %edx
  800a14:	b3 08                	mov    $0x8,%bl
  800a16:	eb 05                	jmp    800a1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a24:	8a 0a                	mov    (%edx),%cl
  800a26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a29:	80 fb 09             	cmp    $0x9,%bl
  800a2c:	77 08                	ja     800a36 <strtol+0x82>
			dig = *s - '0';
  800a2e:	0f be c9             	movsbl %cl,%ecx
  800a31:	83 e9 30             	sub    $0x30,%ecx
  800a34:	eb 1e                	jmp    800a54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a39:	80 fb 19             	cmp    $0x19,%bl
  800a3c:	77 08                	ja     800a46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a3e:	0f be c9             	movsbl %cl,%ecx
  800a41:	83 e9 57             	sub    $0x57,%ecx
  800a44:	eb 0e                	jmp    800a54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 12                	ja     800a60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a4e:	0f be c9             	movsbl %cl,%ecx
  800a51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a54:	39 f1                	cmp    %esi,%ecx
  800a56:	7d 0c                	jge    800a64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a58:	42                   	inc    %edx
  800a59:	0f af c6             	imul   %esi,%eax
  800a5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a5e:	eb c4                	jmp    800a24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a60:	89 c1                	mov    %eax,%ecx
  800a62:	eb 02                	jmp    800a66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6a:	74 05                	je     800a71 <strtol+0xbd>
		*endptr = (char *) s;
  800a6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a71:	85 ff                	test   %edi,%edi
  800a73:	74 04                	je     800a79 <strtol+0xc5>
  800a75:	89 c8                	mov    %ecx,%eax
  800a77:	f7 d8                	neg    %eax
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    
	...

00800a80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	89 c6                	mov    %eax,%esi
  800a97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aae:	89 d1                	mov    %edx,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	89 d7                	mov    %edx,%edi
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 cb                	mov    %ecx,%ebx
  800ad5:	89 cf                	mov    %ecx,%edi
  800ad7:	89 ce                	mov    %ecx,%esi
  800ad9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800adb:	85 c0                	test   %eax,%eax
  800add:	7e 28                	jle    800b07 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ae3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aea:	00 
  800aeb:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800af2:	00 
  800af3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800afa:	00 
  800afb:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800b02:	e8 b5 15 00 00       	call   8020bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b07:	83 c4 2c             	add    $0x2c,%esp
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1f:	89 d1                	mov    %edx,%ecx
  800b21:	89 d3                	mov    %edx,%ebx
  800b23:	89 d7                	mov    %edx,%edi
  800b25:	89 d6                	mov    %edx,%esi
  800b27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <sys_yield>:

void
sys_yield(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b3e:	89 d1                	mov    %edx,%ecx
  800b40:	89 d3                	mov    %edx,%ebx
  800b42:	89 d7                	mov    %edx,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	be 00 00 00 00       	mov    $0x0,%esi
  800b5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 f7                	mov    %esi,%edi
  800b6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7e 28                	jle    800b99 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b7c:	00 
  800b7d:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800b84:	00 
  800b85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8c:	00 
  800b8d:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800b94:	e8 23 15 00 00       	call   8020bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b99:	83 c4 2c             	add    $0x2c,%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	b8 05 00 00 00       	mov    $0x5,%eax
  800baf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 28                	jle    800bec <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bcf:	00 
  800bd0:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800bd7:	00 
  800bd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bdf:	00 
  800be0:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800be7:	e8 d0 14 00 00       	call   8020bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bec:	83 c4 2c             	add    $0x2c,%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c02:	b8 06 00 00 00       	mov    $0x6,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	89 df                	mov    %ebx,%edi
  800c0f:	89 de                	mov    %ebx,%esi
  800c11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 28                	jle    800c3f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c22:	00 
  800c23:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c32:	00 
  800c33:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800c3a:	e8 7d 14 00 00       	call   8020bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3f:	83 c4 2c             	add    $0x2c,%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 28                	jle    800c92 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c75:	00 
  800c76:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800c7d:	00 
  800c7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c85:	00 
  800c86:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800c8d:	e8 2a 14 00 00       	call   8020bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c92:	83 c4 2c             	add    $0x2c,%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 28                	jle    800ce5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd8:	00 
  800cd9:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800ce0:	e8 d7 13 00 00       	call   8020bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce5:	83 c4 2c             	add    $0x2c,%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	89 df                	mov    %ebx,%edi
  800d08:	89 de                	mov    %ebx,%esi
  800d0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7e 28                	jle    800d38 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d14:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d1b:	00 
  800d1c:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800d23:	00 
  800d24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2b:	00 
  800d2c:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800d33:	e8 84 13 00 00       	call   8020bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d38:	83 c4 2c             	add    $0x2c,%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	be 00 00 00 00       	mov    $0x0,%esi
  800d4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 cb                	mov    %ecx,%ebx
  800d7b:	89 cf                	mov    %ecx,%edi
  800d7d:	89 ce                	mov    %ecx,%esi
  800d7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 28                	jle    800dad <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d89:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d90:	00 
  800d91:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800d98:	00 
  800d99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da0:	00 
  800da1:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800da8:	e8 0f 13 00 00       	call   8020bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dad:	83 c4 2c             	add    $0x2c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
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
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	89 d3                	mov    %edx,%ebx
  800dc9:	89 d7                	mov    %edx,%edi
  800dcb:	89 d6                	mov    %edx,%esi
  800dcd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddf:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	89 df                	mov    %ebx,%edi
  800dec:	89 de                	mov    %ebx,%esi
  800dee:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e00:	b8 10 00 00 00       	mov    $0x10,%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	89 df                	mov    %ebx,%edi
  800e0d:	89 de                	mov    %ebx,%esi
  800e0f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
	...

00800e18 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	05 00 00 00 30       	add    $0x30000000,%eax
  800e23:	c1 e8 0c             	shr    $0xc,%eax
}
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	89 04 24             	mov    %eax,(%esp)
  800e34:	e8 df ff ff ff       	call   800e18 <fd2num>
  800e39:	c1 e0 0c             	shl    $0xc,%eax
  800e3c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	53                   	push   %ebx
  800e47:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e4a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e4f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e51:	89 c2                	mov    %eax,%edx
  800e53:	c1 ea 16             	shr    $0x16,%edx
  800e56:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5d:	f6 c2 01             	test   $0x1,%dl
  800e60:	74 11                	je     800e73 <fd_alloc+0x30>
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	c1 ea 0c             	shr    $0xc,%edx
  800e67:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6e:	f6 c2 01             	test   $0x1,%dl
  800e71:	75 09                	jne    800e7c <fd_alloc+0x39>
			*fd_store = fd;
  800e73:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e75:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7a:	eb 17                	jmp    800e93 <fd_alloc+0x50>
  800e7c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e81:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e86:	75 c7                	jne    800e4f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e8e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e93:	5b                   	pop    %ebx
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e9c:	83 f8 1f             	cmp    $0x1f,%eax
  800e9f:	77 36                	ja     800ed7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea1:	c1 e0 0c             	shl    $0xc,%eax
  800ea4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	c1 ea 16             	shr    $0x16,%edx
  800eae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb5:	f6 c2 01             	test   $0x1,%dl
  800eb8:	74 24                	je     800ede <fd_lookup+0x48>
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	c1 ea 0c             	shr    $0xc,%edx
  800ebf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec6:	f6 c2 01             	test   $0x1,%dl
  800ec9:	74 1a                	je     800ee5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ece:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed5:	eb 13                	jmp    800eea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edc:	eb 0c                	jmp    800eea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee3:	eb 05                	jmp    800eea <fd_lookup+0x54>
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	53                   	push   %ebx
  800ef0:	83 ec 14             	sub    $0x14,%esp
  800ef3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800ef9:	ba 00 00 00 00       	mov    $0x0,%edx
  800efe:	eb 0e                	jmp    800f0e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800f00:	39 08                	cmp    %ecx,(%eax)
  800f02:	75 09                	jne    800f0d <dev_lookup+0x21>
			*dev = devtab[i];
  800f04:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f06:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0b:	eb 33                	jmp    800f40 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f0d:	42                   	inc    %edx
  800f0e:	8b 04 95 0c 29 80 00 	mov    0x80290c(,%edx,4),%eax
  800f15:	85 c0                	test   %eax,%eax
  800f17:	75 e7                	jne    800f00 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f19:	a1 08 40 80 00       	mov    0x804008,%eax
  800f1e:	8b 40 48             	mov    0x48(%eax),%eax
  800f21:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f29:	c7 04 24 90 28 80 00 	movl   $0x802890,(%esp)
  800f30:	e8 7b f2 ff ff       	call   8001b0 <cprintf>
	*dev = 0;
  800f35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f40:	83 c4 14             	add    $0x14,%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 30             	sub    $0x30,%esp
  800f4e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f51:	8a 45 0c             	mov    0xc(%ebp),%al
  800f54:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f57:	89 34 24             	mov    %esi,(%esp)
  800f5a:	e8 b9 fe ff ff       	call   800e18 <fd2num>
  800f5f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f62:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f66:	89 04 24             	mov    %eax,(%esp)
  800f69:	e8 28 ff ff ff       	call   800e96 <fd_lookup>
  800f6e:	89 c3                	mov    %eax,%ebx
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 05                	js     800f79 <fd_close+0x33>
	    || fd != fd2)
  800f74:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f77:	74 0d                	je     800f86 <fd_close+0x40>
		return (must_exist ? r : 0);
  800f79:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f7d:	75 46                	jne    800fc5 <fd_close+0x7f>
  800f7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f84:	eb 3f                	jmp    800fc5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8d:	8b 06                	mov    (%esi),%eax
  800f8f:	89 04 24             	mov    %eax,(%esp)
  800f92:	e8 55 ff ff ff       	call   800eec <dev_lookup>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 18                	js     800fb5 <fd_close+0x6f>
		if (dev->dev_close)
  800f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa0:	8b 40 10             	mov    0x10(%eax),%eax
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	74 09                	je     800fb0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fa7:	89 34 24             	mov    %esi,(%esp)
  800faa:	ff d0                	call   *%eax
  800fac:	89 c3                	mov    %eax,%ebx
  800fae:	eb 05                	jmp    800fb5 <fd_close+0x6f>
		else
			r = 0;
  800fb0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc0:	e8 2f fc ff ff       	call   800bf4 <sys_page_unmap>
	return r;
}
  800fc5:	89 d8                	mov    %ebx,%eax
  800fc7:	83 c4 30             	add    $0x30,%esp
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fde:	89 04 24             	mov    %eax,(%esp)
  800fe1:	e8 b0 fe ff ff       	call   800e96 <fd_lookup>
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 13                	js     800ffd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800fea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ff1:	00 
  800ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff5:	89 04 24             	mov    %eax,(%esp)
  800ff8:	e8 49 ff ff ff       	call   800f46 <fd_close>
}
  800ffd:	c9                   	leave  
  800ffe:	c3                   	ret    

00800fff <close_all>:

void
close_all(void)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	53                   	push   %ebx
  801003:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801006:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80100b:	89 1c 24             	mov    %ebx,(%esp)
  80100e:	e8 bb ff ff ff       	call   800fce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801013:	43                   	inc    %ebx
  801014:	83 fb 20             	cmp    $0x20,%ebx
  801017:	75 f2                	jne    80100b <close_all+0xc>
		close(i);
}
  801019:	83 c4 14             	add    $0x14,%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    

0080101f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	57                   	push   %edi
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	83 ec 4c             	sub    $0x4c,%esp
  801028:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801032:	8b 45 08             	mov    0x8(%ebp),%eax
  801035:	89 04 24             	mov    %eax,(%esp)
  801038:	e8 59 fe ff ff       	call   800e96 <fd_lookup>
  80103d:	89 c3                	mov    %eax,%ebx
  80103f:	85 c0                	test   %eax,%eax
  801041:	0f 88 e3 00 00 00    	js     80112a <dup+0x10b>
		return r;
	close(newfdnum);
  801047:	89 3c 24             	mov    %edi,(%esp)
  80104a:	e8 7f ff ff ff       	call   800fce <close>

	newfd = INDEX2FD(newfdnum);
  80104f:	89 fe                	mov    %edi,%esi
  801051:	c1 e6 0c             	shl    $0xc,%esi
  801054:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80105a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80105d:	89 04 24             	mov    %eax,(%esp)
  801060:	e8 c3 fd ff ff       	call   800e28 <fd2data>
  801065:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801067:	89 34 24             	mov    %esi,(%esp)
  80106a:	e8 b9 fd ff ff       	call   800e28 <fd2data>
  80106f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801072:	89 d8                	mov    %ebx,%eax
  801074:	c1 e8 16             	shr    $0x16,%eax
  801077:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107e:	a8 01                	test   $0x1,%al
  801080:	74 46                	je     8010c8 <dup+0xa9>
  801082:	89 d8                	mov    %ebx,%eax
  801084:	c1 e8 0c             	shr    $0xc,%eax
  801087:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108e:	f6 c2 01             	test   $0x1,%dl
  801091:	74 35                	je     8010c8 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801093:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109a:	25 07 0e 00 00       	and    $0xe07,%eax
  80109f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b1:	00 
  8010b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010bd:	e8 df fa ff ff       	call   800ba1 <sys_page_map>
  8010c2:	89 c3                	mov    %eax,%ebx
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 3b                	js     801103 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010cb:	89 c2                	mov    %eax,%edx
  8010cd:	c1 ea 0c             	shr    $0xc,%edx
  8010d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010e1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010ec:	00 
  8010ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f8:	e8 a4 fa ff ff       	call   800ba1 <sys_page_map>
  8010fd:	89 c3                	mov    %eax,%ebx
  8010ff:	85 c0                	test   %eax,%eax
  801101:	79 25                	jns    801128 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801103:	89 74 24 04          	mov    %esi,0x4(%esp)
  801107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80110e:	e8 e1 fa ff ff       	call   800bf4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801113:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801116:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801121:	e8 ce fa ff ff       	call   800bf4 <sys_page_unmap>
	return r;
  801126:	eb 02                	jmp    80112a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801128:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80112a:	89 d8                	mov    %ebx,%eax
  80112c:	83 c4 4c             	add    $0x4c,%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	53                   	push   %ebx
  801138:	83 ec 24             	sub    $0x24,%esp
  80113b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80113e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801141:	89 44 24 04          	mov    %eax,0x4(%esp)
  801145:	89 1c 24             	mov    %ebx,(%esp)
  801148:	e8 49 fd ff ff       	call   800e96 <fd_lookup>
  80114d:	85 c0                	test   %eax,%eax
  80114f:	78 6d                	js     8011be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801151:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801154:	89 44 24 04          	mov    %eax,0x4(%esp)
  801158:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115b:	8b 00                	mov    (%eax),%eax
  80115d:	89 04 24             	mov    %eax,(%esp)
  801160:	e8 87 fd ff ff       	call   800eec <dev_lookup>
  801165:	85 c0                	test   %eax,%eax
  801167:	78 55                	js     8011be <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801169:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116c:	8b 50 08             	mov    0x8(%eax),%edx
  80116f:	83 e2 03             	and    $0x3,%edx
  801172:	83 fa 01             	cmp    $0x1,%edx
  801175:	75 23                	jne    80119a <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801177:	a1 08 40 80 00       	mov    0x804008,%eax
  80117c:	8b 40 48             	mov    0x48(%eax),%eax
  80117f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801183:	89 44 24 04          	mov    %eax,0x4(%esp)
  801187:	c7 04 24 d1 28 80 00 	movl   $0x8028d1,(%esp)
  80118e:	e8 1d f0 ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801193:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801198:	eb 24                	jmp    8011be <read+0x8a>
	}
	if (!dev->dev_read)
  80119a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119d:	8b 52 08             	mov    0x8(%edx),%edx
  8011a0:	85 d2                	test   %edx,%edx
  8011a2:	74 15                	je     8011b9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011a7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011b2:	89 04 24             	mov    %eax,(%esp)
  8011b5:	ff d2                	call   *%edx
  8011b7:	eb 05                	jmp    8011be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011be:	83 c4 24             	add    $0x24,%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	57                   	push   %edi
  8011c8:	56                   	push   %esi
  8011c9:	53                   	push   %ebx
  8011ca:	83 ec 1c             	sub    $0x1c,%esp
  8011cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d8:	eb 23                	jmp    8011fd <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011da:	89 f0                	mov    %esi,%eax
  8011dc:	29 d8                	sub    %ebx,%eax
  8011de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e5:	01 d8                	add    %ebx,%eax
  8011e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011eb:	89 3c 24             	mov    %edi,(%esp)
  8011ee:	e8 41 ff ff ff       	call   801134 <read>
		if (m < 0)
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 10                	js     801207 <readn+0x43>
			return m;
		if (m == 0)
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	74 0a                	je     801205 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011fb:	01 c3                	add    %eax,%ebx
  8011fd:	39 f3                	cmp    %esi,%ebx
  8011ff:	72 d9                	jb     8011da <readn+0x16>
  801201:	89 d8                	mov    %ebx,%eax
  801203:	eb 02                	jmp    801207 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801205:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801207:	83 c4 1c             	add    $0x1c,%esp
  80120a:	5b                   	pop    %ebx
  80120b:	5e                   	pop    %esi
  80120c:	5f                   	pop    %edi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	53                   	push   %ebx
  801213:	83 ec 24             	sub    $0x24,%esp
  801216:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801219:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801220:	89 1c 24             	mov    %ebx,(%esp)
  801223:	e8 6e fc ff ff       	call   800e96 <fd_lookup>
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 68                	js     801294 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801236:	8b 00                	mov    (%eax),%eax
  801238:	89 04 24             	mov    %eax,(%esp)
  80123b:	e8 ac fc ff ff       	call   800eec <dev_lookup>
  801240:	85 c0                	test   %eax,%eax
  801242:	78 50                	js     801294 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801244:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801247:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80124b:	75 23                	jne    801270 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80124d:	a1 08 40 80 00       	mov    0x804008,%eax
  801252:	8b 40 48             	mov    0x48(%eax),%eax
  801255:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125d:	c7 04 24 ed 28 80 00 	movl   $0x8028ed,(%esp)
  801264:	e8 47 ef ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126e:	eb 24                	jmp    801294 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801270:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801273:	8b 52 0c             	mov    0xc(%edx),%edx
  801276:	85 d2                	test   %edx,%edx
  801278:	74 15                	je     80128f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80127a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80127d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801281:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801284:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801288:	89 04 24             	mov    %eax,(%esp)
  80128b:	ff d2                	call   *%edx
  80128d:	eb 05                	jmp    801294 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80128f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801294:	83 c4 24             	add    $0x24,%esp
  801297:	5b                   	pop    %ebx
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    

0080129a <seek>:

int
seek(int fdnum, off_t offset)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012aa:	89 04 24             	mov    %eax,(%esp)
  8012ad:	e8 e4 fb ff ff       	call   800e96 <fd_lookup>
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 0e                	js     8012c4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c4:	c9                   	leave  
  8012c5:	c3                   	ret    

008012c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 24             	sub    $0x24,%esp
  8012cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d7:	89 1c 24             	mov    %ebx,(%esp)
  8012da:	e8 b7 fb ff ff       	call   800e96 <fd_lookup>
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 61                	js     801344 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ed:	8b 00                	mov    (%eax),%eax
  8012ef:	89 04 24             	mov    %eax,(%esp)
  8012f2:	e8 f5 fb ff ff       	call   800eec <dev_lookup>
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 49                	js     801344 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801302:	75 23                	jne    801327 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801304:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801309:	8b 40 48             	mov    0x48(%eax),%eax
  80130c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801310:	89 44 24 04          	mov    %eax,0x4(%esp)
  801314:	c7 04 24 b0 28 80 00 	movl   $0x8028b0,(%esp)
  80131b:	e8 90 ee ff ff       	call   8001b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801320:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801325:	eb 1d                	jmp    801344 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801327:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132a:	8b 52 18             	mov    0x18(%edx),%edx
  80132d:	85 d2                	test   %edx,%edx
  80132f:	74 0e                	je     80133f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801334:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801338:	89 04 24             	mov    %eax,(%esp)
  80133b:	ff d2                	call   *%edx
  80133d:	eb 05                	jmp    801344 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80133f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801344:	83 c4 24             	add    $0x24,%esp
  801347:	5b                   	pop    %ebx
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	53                   	push   %ebx
  80134e:	83 ec 24             	sub    $0x24,%esp
  801351:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801354:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	89 04 24             	mov    %eax,(%esp)
  801361:	e8 30 fb ff ff       	call   800e96 <fd_lookup>
  801366:	85 c0                	test   %eax,%eax
  801368:	78 52                	js     8013bc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801371:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801374:	8b 00                	mov    (%eax),%eax
  801376:	89 04 24             	mov    %eax,(%esp)
  801379:	e8 6e fb ff ff       	call   800eec <dev_lookup>
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 3a                	js     8013bc <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801382:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801385:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801389:	74 2c                	je     8013b7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80138b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80138e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801395:	00 00 00 
	stat->st_isdir = 0;
  801398:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80139f:	00 00 00 
	stat->st_dev = dev;
  8013a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013af:	89 14 24             	mov    %edx,(%esp)
  8013b2:	ff 50 14             	call   *0x14(%eax)
  8013b5:	eb 05                	jmp    8013bc <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013bc:	83 c4 24             	add    $0x24,%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	56                   	push   %esi
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013d1:	00 
  8013d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d5:	89 04 24             	mov    %eax,(%esp)
  8013d8:	e8 2a 02 00 00       	call   801607 <open>
  8013dd:	89 c3                	mov    %eax,%ebx
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 1b                	js     8013fe <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ea:	89 1c 24             	mov    %ebx,(%esp)
  8013ed:	e8 58 ff ff ff       	call   80134a <fstat>
  8013f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8013f4:	89 1c 24             	mov    %ebx,(%esp)
  8013f7:	e8 d2 fb ff ff       	call   800fce <close>
	return r;
  8013fc:	89 f3                	mov    %esi,%ebx
}
  8013fe:	89 d8                	mov    %ebx,%eax
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    
	...

00801408 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	83 ec 10             	sub    $0x10,%esp
  801410:	89 c3                	mov    %eax,%ebx
  801412:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801414:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80141b:	75 11                	jne    80142e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80141d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801424:	e8 de 0d 00 00       	call   802207 <ipc_find_env>
  801429:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80142e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801435:	00 
  801436:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80143d:	00 
  80143e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801442:	a1 00 40 80 00       	mov    0x804000,%eax
  801447:	89 04 24             	mov    %eax,(%esp)
  80144a:	e8 35 0d 00 00       	call   802184 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801456:	00 
  801457:	89 74 24 04          	mov    %esi,0x4(%esp)
  80145b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801462:	e8 ad 0c 00 00       	call   802114 <ipc_recv>
}
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	5b                   	pop    %ebx
  80146b:	5e                   	pop    %esi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801474:	8b 45 08             	mov    0x8(%ebp),%eax
  801477:	8b 40 0c             	mov    0xc(%eax),%eax
  80147a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80147f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801482:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801487:	ba 00 00 00 00       	mov    $0x0,%edx
  80148c:	b8 02 00 00 00       	mov    $0x2,%eax
  801491:	e8 72 ff ff ff       	call   801408 <fsipc>
}
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80149e:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b3:	e8 50 ff ff ff       	call   801408 <fsipc>
}
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	53                   	push   %ebx
  8014be:	83 ec 14             	sub    $0x14,%esp
  8014c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ca:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d9:	e8 2a ff ff ff       	call   801408 <fsipc>
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 2b                	js     80150d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014e2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014e9:	00 
  8014ea:	89 1c 24             	mov    %ebx,(%esp)
  8014ed:	e8 69 f2 ff ff       	call   80075b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801502:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801508:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150d:	83 c4 14             	add    $0x14,%esp
  801510:	5b                   	pop    %ebx
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	83 ec 18             	sub    $0x18,%esp
  801519:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151c:	8b 55 08             	mov    0x8(%ebp),%edx
  80151f:	8b 52 0c             	mov    0xc(%edx),%edx
  801522:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801528:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801534:	76 05                	jbe    80153b <devfile_write+0x28>
  801536:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  80153b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80153f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801542:	89 44 24 04          	mov    %eax,0x4(%esp)
  801546:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80154d:	e8 ec f3 ff ff       	call   80093e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801552:	ba 00 00 00 00       	mov    $0x0,%edx
  801557:	b8 04 00 00 00       	mov    $0x4,%eax
  80155c:	e8 a7 fe ff ff       	call   801408 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	56                   	push   %esi
  801567:	53                   	push   %ebx
  801568:	83 ec 10             	sub    $0x10,%esp
  80156b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80156e:	8b 45 08             	mov    0x8(%ebp),%eax
  801571:	8b 40 0c             	mov    0xc(%eax),%eax
  801574:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801579:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80157f:	ba 00 00 00 00       	mov    $0x0,%edx
  801584:	b8 03 00 00 00       	mov    $0x3,%eax
  801589:	e8 7a fe ff ff       	call   801408 <fsipc>
  80158e:	89 c3                	mov    %eax,%ebx
  801590:	85 c0                	test   %eax,%eax
  801592:	78 6a                	js     8015fe <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801594:	39 c6                	cmp    %eax,%esi
  801596:	73 24                	jae    8015bc <devfile_read+0x59>
  801598:	c7 44 24 0c 20 29 80 	movl   $0x802920,0xc(%esp)
  80159f:	00 
  8015a0:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  8015a7:	00 
  8015a8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8015af:	00 
  8015b0:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  8015b7:	e8 00 0b 00 00       	call   8020bc <_panic>
	assert(r <= PGSIZE);
  8015bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015c1:	7e 24                	jle    8015e7 <devfile_read+0x84>
  8015c3:	c7 44 24 0c 47 29 80 	movl   $0x802947,0xc(%esp)
  8015ca:	00 
  8015cb:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  8015d2:	00 
  8015d3:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8015da:	00 
  8015db:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  8015e2:	e8 d5 0a 00 00       	call   8020bc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015eb:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015f2:	00 
  8015f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f6:	89 04 24             	mov    %eax,(%esp)
  8015f9:	e8 d6 f2 ff ff       	call   8008d4 <memmove>
	return r;
}
  8015fe:	89 d8                	mov    %ebx,%eax
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	5b                   	pop    %ebx
  801604:	5e                   	pop    %esi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
  80160c:	83 ec 20             	sub    $0x20,%esp
  80160f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801612:	89 34 24             	mov    %esi,(%esp)
  801615:	e8 0e f1 ff ff       	call   800728 <strlen>
  80161a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80161f:	7f 60                	jg     801681 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801621:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801624:	89 04 24             	mov    %eax,(%esp)
  801627:	e8 17 f8 ff ff       	call   800e43 <fd_alloc>
  80162c:	89 c3                	mov    %eax,%ebx
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 54                	js     801686 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801632:	89 74 24 04          	mov    %esi,0x4(%esp)
  801636:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80163d:	e8 19 f1 ff ff       	call   80075b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801642:	8b 45 0c             	mov    0xc(%ebp),%eax
  801645:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80164a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164d:	b8 01 00 00 00       	mov    $0x1,%eax
  801652:	e8 b1 fd ff ff       	call   801408 <fsipc>
  801657:	89 c3                	mov    %eax,%ebx
  801659:	85 c0                	test   %eax,%eax
  80165b:	79 15                	jns    801672 <open+0x6b>
		fd_close(fd, 0);
  80165d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801664:	00 
  801665:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801668:	89 04 24             	mov    %eax,(%esp)
  80166b:	e8 d6 f8 ff ff       	call   800f46 <fd_close>
		return r;
  801670:	eb 14                	jmp    801686 <open+0x7f>
	}

	return fd2num(fd);
  801672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801675:	89 04 24             	mov    %eax,(%esp)
  801678:	e8 9b f7 ff ff       	call   800e18 <fd2num>
  80167d:	89 c3                	mov    %eax,%ebx
  80167f:	eb 05                	jmp    801686 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801681:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801686:	89 d8                	mov    %ebx,%eax
  801688:	83 c4 20             	add    $0x20,%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801695:	ba 00 00 00 00       	mov    $0x0,%edx
  80169a:	b8 08 00 00 00       	mov    $0x8,%eax
  80169f:	e8 64 fd ff ff       	call   801408 <fsipc>
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    
	...

008016a8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8016ae:	c7 44 24 04 53 29 80 	movl   $0x802953,0x4(%esp)
  8016b5:	00 
  8016b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b9:	89 04 24             	mov    %eax,(%esp)
  8016bc:	e8 9a f0 ff ff       	call   80075b <strcpy>
	return 0;
}
  8016c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 14             	sub    $0x14,%esp
  8016cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016d2:	89 1c 24             	mov    %ebx,(%esp)
  8016d5:	e8 72 0b 00 00       	call   80224c <pageref>
  8016da:	83 f8 01             	cmp    $0x1,%eax
  8016dd:	75 0d                	jne    8016ec <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8016df:	8b 43 0c             	mov    0xc(%ebx),%eax
  8016e2:	89 04 24             	mov    %eax,(%esp)
  8016e5:	e8 1f 03 00 00       	call   801a09 <nsipc_close>
  8016ea:	eb 05                	jmp    8016f1 <devsock_close+0x29>
	else
		return 0;
  8016ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f1:	83 c4 14             	add    $0x14,%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801704:	00 
  801705:	8b 45 10             	mov    0x10(%ebp),%eax
  801708:	89 44 24 08          	mov    %eax,0x8(%esp)
  80170c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	8b 40 0c             	mov    0xc(%eax),%eax
  801719:	89 04 24             	mov    %eax,(%esp)
  80171c:	e8 e3 03 00 00       	call   801b04 <nsipc_send>
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801729:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801730:	00 
  801731:	8b 45 10             	mov    0x10(%ebp),%eax
  801734:	89 44 24 08          	mov    %eax,0x8(%esp)
  801738:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	8b 40 0c             	mov    0xc(%eax),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 37 03 00 00       	call   801a84 <nsipc_recv>
}
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
  801754:	83 ec 20             	sub    $0x20,%esp
  801757:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801759:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175c:	89 04 24             	mov    %eax,(%esp)
  80175f:	e8 df f6 ff ff       	call   800e43 <fd_alloc>
  801764:	89 c3                	mov    %eax,%ebx
  801766:	85 c0                	test   %eax,%eax
  801768:	78 21                	js     80178b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80176a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801771:	00 
  801772:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801775:	89 44 24 04          	mov    %eax,0x4(%esp)
  801779:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801780:	e8 c8 f3 ff ff       	call   800b4d <sys_page_alloc>
  801785:	89 c3                	mov    %eax,%ebx
  801787:	85 c0                	test   %eax,%eax
  801789:	79 0a                	jns    801795 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80178b:	89 34 24             	mov    %esi,(%esp)
  80178e:	e8 76 02 00 00       	call   801a09 <nsipc_close>
		return r;
  801793:	eb 22                	jmp    8017b7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801795:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017aa:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017ad:	89 04 24             	mov    %eax,(%esp)
  8017b0:	e8 63 f6 ff ff       	call   800e18 <fd2num>
  8017b5:	89 c3                	mov    %eax,%ebx
}
  8017b7:	89 d8                	mov    %ebx,%eax
  8017b9:	83 c4 20             	add    $0x20,%esp
  8017bc:	5b                   	pop    %ebx
  8017bd:	5e                   	pop    %esi
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017c6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017cd:	89 04 24             	mov    %eax,(%esp)
  8017d0:	e8 c1 f6 ff ff       	call   800e96 <fd_lookup>
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 17                	js     8017f0 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8017d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017dc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e2:	39 10                	cmp    %edx,(%eax)
  8017e4:	75 05                	jne    8017eb <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8017e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e9:	eb 05                	jmp    8017f0 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8017eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	e8 c0 ff ff ff       	call   8017c0 <fd2sockid>
  801800:	85 c0                	test   %eax,%eax
  801802:	78 1f                	js     801823 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801804:	8b 55 10             	mov    0x10(%ebp),%edx
  801807:	89 54 24 08          	mov    %edx,0x8(%esp)
  80180b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801812:	89 04 24             	mov    %eax,(%esp)
  801815:	e8 38 01 00 00       	call   801952 <nsipc_accept>
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 05                	js     801823 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80181e:	e8 2c ff ff ff       	call   80174f <alloc_sockfd>
}
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80182b:	8b 45 08             	mov    0x8(%ebp),%eax
  80182e:	e8 8d ff ff ff       	call   8017c0 <fd2sockid>
  801833:	85 c0                	test   %eax,%eax
  801835:	78 16                	js     80184d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801837:	8b 55 10             	mov    0x10(%ebp),%edx
  80183a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80183e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801841:	89 54 24 04          	mov    %edx,0x4(%esp)
  801845:	89 04 24             	mov    %eax,(%esp)
  801848:	e8 5b 01 00 00       	call   8019a8 <nsipc_bind>
}
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <shutdown>:

int
shutdown(int s, int how)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	e8 63 ff ff ff       	call   8017c0 <fd2sockid>
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 0f                	js     801870 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801861:	8b 55 0c             	mov    0xc(%ebp),%edx
  801864:	89 54 24 04          	mov    %edx,0x4(%esp)
  801868:	89 04 24             	mov    %eax,(%esp)
  80186b:	e8 77 01 00 00       	call   8019e7 <nsipc_shutdown>
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	e8 40 ff ff ff       	call   8017c0 <fd2sockid>
  801880:	85 c0                	test   %eax,%eax
  801882:	78 16                	js     80189a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801884:	8b 55 10             	mov    0x10(%ebp),%edx
  801887:	89 54 24 08          	mov    %edx,0x8(%esp)
  80188b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 89 01 00 00       	call   801a23 <nsipc_connect>
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <listen>:

int
listen(int s, int backlog)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a5:	e8 16 ff ff ff       	call   8017c0 <fd2sockid>
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 0f                	js     8018bd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8018ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018b5:	89 04 24             	mov    %eax,(%esp)
  8018b8:	e8 a5 01 00 00       	call   801a62 <nsipc_listen>
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	e8 99 02 00 00       	call   801b77 <nsipc_socket>
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 05                	js     8018e7 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8018e2:	e8 68 fe ff ff       	call   80174f <alloc_sockfd>
}
  8018e7:	c9                   	leave  
  8018e8:	c3                   	ret    
  8018e9:	00 00                	add    %al,(%eax)
	...

008018ec <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	53                   	push   %ebx
  8018f0:	83 ec 14             	sub    $0x14,%esp
  8018f3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018f5:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018fc:	75 11                	jne    80190f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018fe:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801905:	e8 fd 08 00 00       	call   802207 <ipc_find_env>
  80190a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80190f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801916:	00 
  801917:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80191e:	00 
  80191f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801923:	a1 04 40 80 00       	mov    0x804004,%eax
  801928:	89 04 24             	mov    %eax,(%esp)
  80192b:	e8 54 08 00 00       	call   802184 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801930:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801937:	00 
  801938:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80193f:	00 
  801940:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801947:	e8 c8 07 00 00       	call   802114 <ipc_recv>
}
  80194c:	83 c4 14             	add    $0x14,%esp
  80194f:	5b                   	pop    %ebx
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
  801957:	83 ec 10             	sub    $0x10,%esp
  80195a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
  801960:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801965:	8b 06                	mov    (%esi),%eax
  801967:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80196c:	b8 01 00 00 00       	mov    $0x1,%eax
  801971:	e8 76 ff ff ff       	call   8018ec <nsipc>
  801976:	89 c3                	mov    %eax,%ebx
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 23                	js     80199f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80197c:	a1 10 60 80 00       	mov    0x806010,%eax
  801981:	89 44 24 08          	mov    %eax,0x8(%esp)
  801985:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80198c:	00 
  80198d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801990:	89 04 24             	mov    %eax,(%esp)
  801993:	e8 3c ef ff ff       	call   8008d4 <memmove>
		*addrlen = ret->ret_addrlen;
  801998:	a1 10 60 80 00       	mov    0x806010,%eax
  80199d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  80199f:	89 d8                	mov    %ebx,%eax
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5e                   	pop    %esi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	53                   	push   %ebx
  8019ac:	83 ec 14             	sub    $0x14,%esp
  8019af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c5:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8019cc:	e8 03 ef ff ff       	call   8008d4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019d1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8019d7:	b8 02 00 00 00       	mov    $0x2,%eax
  8019dc:	e8 0b ff ff ff       	call   8018ec <nsipc>
}
  8019e1:	83 c4 14             	add    $0x14,%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5d                   	pop    %ebp
  8019e6:	c3                   	ret    

008019e7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019fd:	b8 03 00 00 00       	mov    $0x3,%eax
  801a02:	e8 e5 fe ff ff       	call   8018ec <nsipc>
}
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <nsipc_close>:

int
nsipc_close(int s)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a12:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801a17:	b8 04 00 00 00       	mov    $0x4,%eax
  801a1c:	e8 cb fe ff ff       	call   8018ec <nsipc>
}
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	53                   	push   %ebx
  801a27:	83 ec 14             	sub    $0x14,%esp
  801a2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a30:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a35:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a40:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801a47:	e8 88 ee ff ff       	call   8008d4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a4c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a52:	b8 05 00 00 00       	mov    $0x5,%eax
  801a57:	e8 90 fe ff ff       	call   8018ec <nsipc>
}
  801a5c:	83 c4 14             	add    $0x14,%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a73:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a78:	b8 06 00 00 00       	mov    $0x6,%eax
  801a7d:	e8 6a fe ff ff       	call   8018ec <nsipc>
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	56                   	push   %esi
  801a88:	53                   	push   %ebx
  801a89:	83 ec 10             	sub    $0x10,%esp
  801a8c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a97:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a9d:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801aa5:	b8 07 00 00 00       	mov    $0x7,%eax
  801aaa:	e8 3d fe ff ff       	call   8018ec <nsipc>
  801aaf:	89 c3                	mov    %eax,%ebx
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 46                	js     801afb <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801ab5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801aba:	7f 04                	jg     801ac0 <nsipc_recv+0x3c>
  801abc:	39 c6                	cmp    %eax,%esi
  801abe:	7d 24                	jge    801ae4 <nsipc_recv+0x60>
  801ac0:	c7 44 24 0c 5f 29 80 	movl   $0x80295f,0xc(%esp)
  801ac7:	00 
  801ac8:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  801acf:	00 
  801ad0:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801ad7:	00 
  801ad8:	c7 04 24 74 29 80 00 	movl   $0x802974,(%esp)
  801adf:	e8 d8 05 00 00       	call   8020bc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ae4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae8:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801aef:	00 
  801af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af3:	89 04 24             	mov    %eax,(%esp)
  801af6:	e8 d9 ed ff ff       	call   8008d4 <memmove>
	}

	return r;
}
  801afb:	89 d8                	mov    %ebx,%eax
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	5d                   	pop    %ebp
  801b03:	c3                   	ret    

00801b04 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	53                   	push   %ebx
  801b08:	83 ec 14             	sub    $0x14,%esp
  801b0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801b16:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b1c:	7e 24                	jle    801b42 <nsipc_send+0x3e>
  801b1e:	c7 44 24 0c 80 29 80 	movl   $0x802980,0xc(%esp)
  801b25:	00 
  801b26:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  801b2d:	00 
  801b2e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801b35:	00 
  801b36:	c7 04 24 74 29 80 00 	movl   $0x802974,(%esp)
  801b3d:	e8 7a 05 00 00       	call   8020bc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b42:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801b54:	e8 7b ed ff ff       	call   8008d4 <memmove>
	nsipcbuf.send.req_size = size;
  801b59:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  801b62:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b67:	b8 08 00 00 00       	mov    $0x8,%eax
  801b6c:	e8 7b fd ff ff       	call   8018ec <nsipc>
}
  801b71:	83 c4 14             	add    $0x14,%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b80:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b88:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b90:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b95:	b8 09 00 00 00       	mov    $0x9,%eax
  801b9a:	e8 4d fd ff ff       	call   8018ec <nsipc>
}
  801b9f:	c9                   	leave  
  801ba0:	c3                   	ret    
  801ba1:	00 00                	add    %al,(%eax)
	...

00801ba4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 10             	sub    $0x10,%esp
  801bac:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801baf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb2:	89 04 24             	mov    %eax,(%esp)
  801bb5:	e8 6e f2 ff ff       	call   800e28 <fd2data>
  801bba:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bbc:	c7 44 24 04 8c 29 80 	movl   $0x80298c,0x4(%esp)
  801bc3:	00 
  801bc4:	89 34 24             	mov    %esi,(%esp)
  801bc7:	e8 8f eb ff ff       	call   80075b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bcc:	8b 43 04             	mov    0x4(%ebx),%eax
  801bcf:	2b 03                	sub    (%ebx),%eax
  801bd1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801bd7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bde:	00 00 00 
	stat->st_dev = &devpipe;
  801be1:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801be8:	30 80 00 
	return 0;
}
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5d                   	pop    %ebp
  801bf6:	c3                   	ret    

00801bf7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	53                   	push   %ebx
  801bfb:	83 ec 14             	sub    $0x14,%esp
  801bfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0c:	e8 e3 ef ff ff       	call   800bf4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c11:	89 1c 24             	mov    %ebx,(%esp)
  801c14:	e8 0f f2 ff ff       	call   800e28 <fd2data>
  801c19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c24:	e8 cb ef ff ff       	call   800bf4 <sys_page_unmap>
}
  801c29:	83 c4 14             	add    $0x14,%esp
  801c2c:	5b                   	pop    %ebx
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    

00801c2f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	57                   	push   %edi
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	83 ec 2c             	sub    $0x2c,%esp
  801c38:	89 c7                	mov    %eax,%edi
  801c3a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c3d:	a1 08 40 80 00       	mov    0x804008,%eax
  801c42:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c45:	89 3c 24             	mov    %edi,(%esp)
  801c48:	e8 ff 05 00 00       	call   80224c <pageref>
  801c4d:	89 c6                	mov    %eax,%esi
  801c4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c52:	89 04 24             	mov    %eax,(%esp)
  801c55:	e8 f2 05 00 00       	call   80224c <pageref>
  801c5a:	39 c6                	cmp    %eax,%esi
  801c5c:	0f 94 c0             	sete   %al
  801c5f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c62:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c68:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c6b:	39 cb                	cmp    %ecx,%ebx
  801c6d:	75 08                	jne    801c77 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c6f:	83 c4 2c             	add    $0x2c,%esp
  801c72:	5b                   	pop    %ebx
  801c73:	5e                   	pop    %esi
  801c74:	5f                   	pop    %edi
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c77:	83 f8 01             	cmp    $0x1,%eax
  801c7a:	75 c1                	jne    801c3d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c7c:	8b 42 58             	mov    0x58(%edx),%eax
  801c7f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c86:	00 
  801c87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c8f:	c7 04 24 93 29 80 00 	movl   $0x802993,(%esp)
  801c96:	e8 15 e5 ff ff       	call   8001b0 <cprintf>
  801c9b:	eb a0                	jmp    801c3d <_pipeisclosed+0xe>

00801c9d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	57                   	push   %edi
  801ca1:	56                   	push   %esi
  801ca2:	53                   	push   %ebx
  801ca3:	83 ec 1c             	sub    $0x1c,%esp
  801ca6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ca9:	89 34 24             	mov    %esi,(%esp)
  801cac:	e8 77 f1 ff ff       	call   800e28 <fd2data>
  801cb1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb3:	bf 00 00 00 00       	mov    $0x0,%edi
  801cb8:	eb 3c                	jmp    801cf6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cba:	89 da                	mov    %ebx,%edx
  801cbc:	89 f0                	mov    %esi,%eax
  801cbe:	e8 6c ff ff ff       	call   801c2f <_pipeisclosed>
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	75 38                	jne    801cff <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cc7:	e8 62 ee ff ff       	call   800b2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ccc:	8b 43 04             	mov    0x4(%ebx),%eax
  801ccf:	8b 13                	mov    (%ebx),%edx
  801cd1:	83 c2 20             	add    $0x20,%edx
  801cd4:	39 d0                	cmp    %edx,%eax
  801cd6:	73 e2                	jae    801cba <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801cde:	89 c2                	mov    %eax,%edx
  801ce0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ce6:	79 05                	jns    801ced <devpipe_write+0x50>
  801ce8:	4a                   	dec    %edx
  801ce9:	83 ca e0             	or     $0xffffffe0,%edx
  801cec:	42                   	inc    %edx
  801ced:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf1:	40                   	inc    %eax
  801cf2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf5:	47                   	inc    %edi
  801cf6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cf9:	75 d1                	jne    801ccc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cfb:	89 f8                	mov    %edi,%eax
  801cfd:	eb 05                	jmp    801d04 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d04:	83 c4 1c             	add    $0x1c,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5f                   	pop    %edi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	57                   	push   %edi
  801d10:	56                   	push   %esi
  801d11:	53                   	push   %ebx
  801d12:	83 ec 1c             	sub    $0x1c,%esp
  801d15:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d18:	89 3c 24             	mov    %edi,(%esp)
  801d1b:	e8 08 f1 ff ff       	call   800e28 <fd2data>
  801d20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d22:	be 00 00 00 00       	mov    $0x0,%esi
  801d27:	eb 3a                	jmp    801d63 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d29:	85 f6                	test   %esi,%esi
  801d2b:	74 04                	je     801d31 <devpipe_read+0x25>
				return i;
  801d2d:	89 f0                	mov    %esi,%eax
  801d2f:	eb 40                	jmp    801d71 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d31:	89 da                	mov    %ebx,%edx
  801d33:	89 f8                	mov    %edi,%eax
  801d35:	e8 f5 fe ff ff       	call   801c2f <_pipeisclosed>
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	75 2e                	jne    801d6c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d3e:	e8 eb ed ff ff       	call   800b2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d43:	8b 03                	mov    (%ebx),%eax
  801d45:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d48:	74 df                	je     801d29 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d4a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d4f:	79 05                	jns    801d56 <devpipe_read+0x4a>
  801d51:	48                   	dec    %eax
  801d52:	83 c8 e0             	or     $0xffffffe0,%eax
  801d55:	40                   	inc    %eax
  801d56:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d60:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d62:	46                   	inc    %esi
  801d63:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d66:	75 db                	jne    801d43 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d68:	89 f0                	mov    %esi,%eax
  801d6a:	eb 05                	jmp    801d71 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d71:	83 c4 1c             	add    $0x1c,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	57                   	push   %edi
  801d7d:	56                   	push   %esi
  801d7e:	53                   	push   %ebx
  801d7f:	83 ec 3c             	sub    $0x3c,%esp
  801d82:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d85:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d88:	89 04 24             	mov    %eax,(%esp)
  801d8b:	e8 b3 f0 ff ff       	call   800e43 <fd_alloc>
  801d90:	89 c3                	mov    %eax,%ebx
  801d92:	85 c0                	test   %eax,%eax
  801d94:	0f 88 45 01 00 00    	js     801edf <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801da1:	00 
  801da2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801da5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db0:	e8 98 ed ff ff       	call   800b4d <sys_page_alloc>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	85 c0                	test   %eax,%eax
  801db9:	0f 88 20 01 00 00    	js     801edf <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dbf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801dc2:	89 04 24             	mov    %eax,(%esp)
  801dc5:	e8 79 f0 ff ff       	call   800e43 <fd_alloc>
  801dca:	89 c3                	mov    %eax,%ebx
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	0f 88 f8 00 00 00    	js     801ecc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ddb:	00 
  801ddc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dea:	e8 5e ed ff ff       	call   800b4d <sys_page_alloc>
  801def:	89 c3                	mov    %eax,%ebx
  801df1:	85 c0                	test   %eax,%eax
  801df3:	0f 88 d3 00 00 00    	js     801ecc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801df9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dfc:	89 04 24             	mov    %eax,(%esp)
  801dff:	e8 24 f0 ff ff       	call   800e28 <fd2data>
  801e04:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e06:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e0d:	00 
  801e0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e19:	e8 2f ed ff ff       	call   800b4d <sys_page_alloc>
  801e1e:	89 c3                	mov    %eax,%ebx
  801e20:	85 c0                	test   %eax,%eax
  801e22:	0f 88 91 00 00 00    	js     801eb9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e2b:	89 04 24             	mov    %eax,(%esp)
  801e2e:	e8 f5 ef ff ff       	call   800e28 <fd2data>
  801e33:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e3a:	00 
  801e3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e46:	00 
  801e47:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e52:	e8 4a ed ff ff       	call   800ba1 <sys_page_map>
  801e57:	89 c3                	mov    %eax,%ebx
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	78 4c                	js     801ea9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e5d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e66:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e7b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e80:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e8a:	89 04 24             	mov    %eax,(%esp)
  801e8d:	e8 86 ef ff ff       	call   800e18 <fd2num>
  801e92:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e97:	89 04 24             	mov    %eax,(%esp)
  801e9a:	e8 79 ef ff ff       	call   800e18 <fd2num>
  801e9f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ea2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ea7:	eb 36                	jmp    801edf <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801ea9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ead:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb4:	e8 3b ed ff ff       	call   800bf4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801eb9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ebc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec7:	e8 28 ed ff ff       	call   800bf4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ecf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eda:	e8 15 ed ff ff       	call   800bf4 <sys_page_unmap>
    err:
	return r;
}
  801edf:	89 d8                	mov    %ebx,%eax
  801ee1:	83 c4 3c             	add    $0x3c,%esp
  801ee4:	5b                   	pop    %ebx
  801ee5:	5e                   	pop    %esi
  801ee6:	5f                   	pop    %edi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef9:	89 04 24             	mov    %eax,(%esp)
  801efc:	e8 95 ef ff ff       	call   800e96 <fd_lookup>
  801f01:	85 c0                	test   %eax,%eax
  801f03:	78 15                	js     801f1a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f08:	89 04 24             	mov    %eax,(%esp)
  801f0b:	e8 18 ef ff ff       	call   800e28 <fd2data>
	return _pipeisclosed(fd, p);
  801f10:	89 c2                	mov    %eax,%edx
  801f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f15:	e8 15 fd ff ff       	call   801c2f <_pipeisclosed>
}
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    

00801f26 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f2c:	c7 44 24 04 ab 29 80 	movl   $0x8029ab,0x4(%esp)
  801f33:	00 
  801f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f37:	89 04 24             	mov    %eax,(%esp)
  801f3a:	e8 1c e8 ff ff       	call   80075b <strcpy>
	return 0;
}
  801f3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	57                   	push   %edi
  801f4a:	56                   	push   %esi
  801f4b:	53                   	push   %ebx
  801f4c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f52:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f57:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f5d:	eb 30                	jmp    801f8f <devcons_write+0x49>
		m = n - tot;
  801f5f:	8b 75 10             	mov    0x10(%ebp),%esi
  801f62:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f64:	83 fe 7f             	cmp    $0x7f,%esi
  801f67:	76 05                	jbe    801f6e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f69:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f6e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f72:	03 45 0c             	add    0xc(%ebp),%eax
  801f75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f79:	89 3c 24             	mov    %edi,(%esp)
  801f7c:	e8 53 e9 ff ff       	call   8008d4 <memmove>
		sys_cputs(buf, m);
  801f81:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f85:	89 3c 24             	mov    %edi,(%esp)
  801f88:	e8 f3 ea ff ff       	call   800a80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f8d:	01 f3                	add    %esi,%ebx
  801f8f:	89 d8                	mov    %ebx,%eax
  801f91:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f94:	72 c9                	jb     801f5f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f96:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    

00801fa1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fa7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fab:	75 07                	jne    801fb4 <devcons_read+0x13>
  801fad:	eb 25                	jmp    801fd4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801faf:	e8 7a eb ff ff       	call   800b2e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fb4:	e8 e5 ea ff ff       	call   800a9e <sys_cgetc>
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	74 f2                	je     801faf <devcons_read+0xe>
  801fbd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	78 1d                	js     801fe0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fc3:	83 f8 04             	cmp    $0x4,%eax
  801fc6:	74 13                	je     801fdb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcb:	88 10                	mov    %dl,(%eax)
	return 1;
  801fcd:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd2:	eb 0c                	jmp    801fe0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd9:	eb 05                	jmp    801fe0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ff5:	00 
  801ff6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff9:	89 04 24             	mov    %eax,(%esp)
  801ffc:	e8 7f ea ff ff       	call   800a80 <sys_cputs>
}
  802001:	c9                   	leave  
  802002:	c3                   	ret    

00802003 <getchar>:

int
getchar(void)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802009:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802010:	00 
  802011:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802014:	89 44 24 04          	mov    %eax,0x4(%esp)
  802018:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80201f:	e8 10 f1 ff ff       	call   801134 <read>
	if (r < 0)
  802024:	85 c0                	test   %eax,%eax
  802026:	78 0f                	js     802037 <getchar+0x34>
		return r;
	if (r < 1)
  802028:	85 c0                	test   %eax,%eax
  80202a:	7e 06                	jle    802032 <getchar+0x2f>
		return -E_EOF;
	return c;
  80202c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802030:	eb 05                	jmp    802037 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802032:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802037:	c9                   	leave  
  802038:	c3                   	ret    

00802039 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80203f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802042:	89 44 24 04          	mov    %eax,0x4(%esp)
  802046:	8b 45 08             	mov    0x8(%ebp),%eax
  802049:	89 04 24             	mov    %eax,(%esp)
  80204c:	e8 45 ee ff ff       	call   800e96 <fd_lookup>
  802051:	85 c0                	test   %eax,%eax
  802053:	78 11                	js     802066 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802058:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80205e:	39 10                	cmp    %edx,(%eax)
  802060:	0f 94 c0             	sete   %al
  802063:	0f b6 c0             	movzbl %al,%eax
}
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <opencons>:

int
opencons(void)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80206e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802071:	89 04 24             	mov    %eax,(%esp)
  802074:	e8 ca ed ff ff       	call   800e43 <fd_alloc>
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 3c                	js     8020b9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80207d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802084:	00 
  802085:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802093:	e8 b5 ea ff ff       	call   800b4d <sys_page_alloc>
  802098:	85 c0                	test   %eax,%eax
  80209a:	78 1d                	js     8020b9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80209c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 5f ed ff ff       	call   800e18 <fd2num>
}
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    
	...

008020bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	56                   	push   %esi
  8020c0:	53                   	push   %ebx
  8020c1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8020c4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020c7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8020cd:	e8 3d ea ff ff       	call   800b0f <sys_getenvid>
  8020d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8020d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8020dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e8:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  8020ef:	e8 bc e0 ff ff       	call   8001b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8020fb:	89 04 24             	mov    %eax,(%esp)
  8020fe:	e8 4c e0 ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  802103:	c7 04 24 a4 29 80 00 	movl   $0x8029a4,(%esp)
  80210a:	e8 a1 e0 ff ff       	call   8001b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80210f:	cc                   	int3   
  802110:	eb fd                	jmp    80210f <_panic+0x53>
	...

00802114 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	56                   	push   %esi
  802118:	53                   	push   %ebx
  802119:	83 ec 10             	sub    $0x10,%esp
  80211c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80211f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802122:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802125:	85 c0                	test   %eax,%eax
  802127:	74 0a                	je     802133 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802129:	89 04 24             	mov    %eax,(%esp)
  80212c:	e8 32 ec ff ff       	call   800d63 <sys_ipc_recv>
  802131:	eb 0c                	jmp    80213f <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802133:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80213a:	e8 24 ec ff ff       	call   800d63 <sys_ipc_recv>
	}
	if (r < 0)
  80213f:	85 c0                	test   %eax,%eax
  802141:	79 16                	jns    802159 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802143:	85 db                	test   %ebx,%ebx
  802145:	74 06                	je     80214d <ipc_recv+0x39>
  802147:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  80214d:	85 f6                	test   %esi,%esi
  80214f:	74 2c                	je     80217d <ipc_recv+0x69>
  802151:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802157:	eb 24                	jmp    80217d <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802159:	85 db                	test   %ebx,%ebx
  80215b:	74 0a                	je     802167 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  80215d:	a1 08 40 80 00       	mov    0x804008,%eax
  802162:	8b 40 74             	mov    0x74(%eax),%eax
  802165:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802167:	85 f6                	test   %esi,%esi
  802169:	74 0a                	je     802175 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80216b:	a1 08 40 80 00       	mov    0x804008,%eax
  802170:	8b 40 78             	mov    0x78(%eax),%eax
  802173:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802175:	a1 08 40 80 00       	mov    0x804008,%eax
  80217a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80217d:	83 c4 10             	add    $0x10,%esp
  802180:	5b                   	pop    %ebx
  802181:	5e                   	pop    %esi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    

00802184 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	57                   	push   %edi
  802188:	56                   	push   %esi
  802189:	53                   	push   %ebx
  80218a:	83 ec 1c             	sub    $0x1c,%esp
  80218d:	8b 75 08             	mov    0x8(%ebp),%esi
  802190:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802193:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802196:	85 db                	test   %ebx,%ebx
  802198:	74 19                	je     8021b3 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80219a:	8b 45 14             	mov    0x14(%ebp),%eax
  80219d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021a1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021a9:	89 34 24             	mov    %esi,(%esp)
  8021ac:	e8 8f eb ff ff       	call   800d40 <sys_ipc_try_send>
  8021b1:	eb 1c                	jmp    8021cf <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8021b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8021ba:	00 
  8021bb:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8021c2:	ee 
  8021c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021c7:	89 34 24             	mov    %esi,(%esp)
  8021ca:	e8 71 eb ff ff       	call   800d40 <sys_ipc_try_send>
		}
		if (r == 0)
  8021cf:	85 c0                	test   %eax,%eax
  8021d1:	74 2c                	je     8021ff <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8021d3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021d6:	74 20                	je     8021f8 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8021d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021dc:	c7 44 24 08 dc 29 80 	movl   $0x8029dc,0x8(%esp)
  8021e3:	00 
  8021e4:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8021eb:	00 
  8021ec:	c7 04 24 ef 29 80 00 	movl   $0x8029ef,(%esp)
  8021f3:	e8 c4 fe ff ff       	call   8020bc <_panic>
		}
		sys_yield();
  8021f8:	e8 31 e9 ff ff       	call   800b2e <sys_yield>
	}
  8021fd:	eb 97                	jmp    802196 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8021ff:	83 c4 1c             	add    $0x1c,%esp
  802202:	5b                   	pop    %ebx
  802203:	5e                   	pop    %esi
  802204:	5f                   	pop    %edi
  802205:	5d                   	pop    %ebp
  802206:	c3                   	ret    

00802207 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802207:	55                   	push   %ebp
  802208:	89 e5                	mov    %esp,%ebp
  80220a:	53                   	push   %ebx
  80220b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80220e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802213:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80221a:	89 c2                	mov    %eax,%edx
  80221c:	c1 e2 07             	shl    $0x7,%edx
  80221f:	29 ca                	sub    %ecx,%edx
  802221:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802227:	8b 52 50             	mov    0x50(%edx),%edx
  80222a:	39 da                	cmp    %ebx,%edx
  80222c:	75 0f                	jne    80223d <ipc_find_env+0x36>
			return envs[i].env_id;
  80222e:	c1 e0 07             	shl    $0x7,%eax
  802231:	29 c8                	sub    %ecx,%eax
  802233:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802238:	8b 40 40             	mov    0x40(%eax),%eax
  80223b:	eb 0c                	jmp    802249 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80223d:	40                   	inc    %eax
  80223e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802243:	75 ce                	jne    802213 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802245:	66 b8 00 00          	mov    $0x0,%ax
}
  802249:	5b                   	pop    %ebx
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    

0080224c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802252:	89 c2                	mov    %eax,%edx
  802254:	c1 ea 16             	shr    $0x16,%edx
  802257:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80225e:	f6 c2 01             	test   $0x1,%dl
  802261:	74 1e                	je     802281 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802263:	c1 e8 0c             	shr    $0xc,%eax
  802266:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80226d:	a8 01                	test   $0x1,%al
  80226f:	74 17                	je     802288 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802271:	c1 e8 0c             	shr    $0xc,%eax
  802274:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80227b:	ef 
  80227c:	0f b7 c0             	movzwl %ax,%eax
  80227f:	eb 0c                	jmp    80228d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802281:	b8 00 00 00 00       	mov    $0x0,%eax
  802286:	eb 05                	jmp    80228d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802288:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80228d:	5d                   	pop    %ebp
  80228e:	c3                   	ret    
	...

00802290 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	83 ec 10             	sub    $0x10,%esp
  802296:	8b 74 24 20          	mov    0x20(%esp),%esi
  80229a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80229e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8022a6:	89 cd                	mov    %ecx,%ebp
  8022a8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	75 2c                	jne    8022dc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8022b0:	39 f9                	cmp    %edi,%ecx
  8022b2:	77 68                	ja     80231c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022b4:	85 c9                	test   %ecx,%ecx
  8022b6:	75 0b                	jne    8022c3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	f7 f1                	div    %ecx
  8022c1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	89 f8                	mov    %edi,%eax
  8022c7:	f7 f1                	div    %ecx
  8022c9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022cb:	89 f0                	mov    %esi,%eax
  8022cd:	f7 f1                	div    %ecx
  8022cf:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022d5:	83 c4 10             	add    $0x10,%esp
  8022d8:	5e                   	pop    %esi
  8022d9:	5f                   	pop    %edi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022dc:	39 f8                	cmp    %edi,%eax
  8022de:	77 2c                	ja     80230c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022e0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8022e3:	83 f6 1f             	xor    $0x1f,%esi
  8022e6:	75 4c                	jne    802334 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022e8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022ea:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022ef:	72 0a                	jb     8022fb <__udivdi3+0x6b>
  8022f1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022f5:	0f 87 ad 00 00 00    	ja     8023a8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022fb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802300:	89 f0                	mov    %esi,%eax
  802302:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802304:	83 c4 10             	add    $0x10,%esp
  802307:	5e                   	pop    %esi
  802308:	5f                   	pop    %edi
  802309:	5d                   	pop    %ebp
  80230a:	c3                   	ret    
  80230b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80230c:	31 ff                	xor    %edi,%edi
  80230e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802310:	89 f0                	mov    %esi,%eax
  802312:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	5e                   	pop    %esi
  802318:	5f                   	pop    %edi
  802319:	5d                   	pop    %ebp
  80231a:	c3                   	ret    
  80231b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80231c:	89 fa                	mov    %edi,%edx
  80231e:	89 f0                	mov    %esi,%eax
  802320:	f7 f1                	div    %ecx
  802322:	89 c6                	mov    %eax,%esi
  802324:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802326:	89 f0                	mov    %esi,%eax
  802328:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80232a:	83 c4 10             	add    $0x10,%esp
  80232d:	5e                   	pop    %esi
  80232e:	5f                   	pop    %edi
  80232f:	5d                   	pop    %ebp
  802330:	c3                   	ret    
  802331:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802334:	89 f1                	mov    %esi,%ecx
  802336:	d3 e0                	shl    %cl,%eax
  802338:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80233c:	b8 20 00 00 00       	mov    $0x20,%eax
  802341:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802343:	89 ea                	mov    %ebp,%edx
  802345:	88 c1                	mov    %al,%cl
  802347:	d3 ea                	shr    %cl,%edx
  802349:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80234d:	09 ca                	or     %ecx,%edx
  80234f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802353:	89 f1                	mov    %esi,%ecx
  802355:	d3 e5                	shl    %cl,%ebp
  802357:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80235b:	89 fd                	mov    %edi,%ebp
  80235d:	88 c1                	mov    %al,%cl
  80235f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802361:	89 fa                	mov    %edi,%edx
  802363:	89 f1                	mov    %esi,%ecx
  802365:	d3 e2                	shl    %cl,%edx
  802367:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80236b:	88 c1                	mov    %al,%cl
  80236d:	d3 ef                	shr    %cl,%edi
  80236f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802371:	89 f8                	mov    %edi,%eax
  802373:	89 ea                	mov    %ebp,%edx
  802375:	f7 74 24 08          	divl   0x8(%esp)
  802379:	89 d1                	mov    %edx,%ecx
  80237b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80237d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802381:	39 d1                	cmp    %edx,%ecx
  802383:	72 17                	jb     80239c <__udivdi3+0x10c>
  802385:	74 09                	je     802390 <__udivdi3+0x100>
  802387:	89 fe                	mov    %edi,%esi
  802389:	31 ff                	xor    %edi,%edi
  80238b:	e9 41 ff ff ff       	jmp    8022d1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802390:	8b 54 24 04          	mov    0x4(%esp),%edx
  802394:	89 f1                	mov    %esi,%ecx
  802396:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802398:	39 c2                	cmp    %eax,%edx
  80239a:	73 eb                	jae    802387 <__udivdi3+0xf7>
		{
		  q0--;
  80239c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80239f:	31 ff                	xor    %edi,%edi
  8023a1:	e9 2b ff ff ff       	jmp    8022d1 <__udivdi3+0x41>
  8023a6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023a8:	31 f6                	xor    %esi,%esi
  8023aa:	e9 22 ff ff ff       	jmp    8022d1 <__udivdi3+0x41>
	...

008023b0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	83 ec 20             	sub    $0x20,%esp
  8023b6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023ba:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023be:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023c2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8023c6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ca:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8023ce:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8023d0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023d2:	85 ed                	test   %ebp,%ebp
  8023d4:	75 16                	jne    8023ec <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8023d6:	39 f1                	cmp    %esi,%ecx
  8023d8:	0f 86 a6 00 00 00    	jbe    802484 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023de:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8023e0:	89 d0                	mov    %edx,%eax
  8023e2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023e4:	83 c4 20             	add    $0x20,%esp
  8023e7:	5e                   	pop    %esi
  8023e8:	5f                   	pop    %edi
  8023e9:	5d                   	pop    %ebp
  8023ea:	c3                   	ret    
  8023eb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023ec:	39 f5                	cmp    %esi,%ebp
  8023ee:	0f 87 ac 00 00 00    	ja     8024a0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023f4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8023f7:	83 f0 1f             	xor    $0x1f,%eax
  8023fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023fe:	0f 84 a8 00 00 00    	je     8024ac <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802404:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802408:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80240a:	bf 20 00 00 00       	mov    $0x20,%edi
  80240f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802413:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802417:	89 f9                	mov    %edi,%ecx
  802419:	d3 e8                	shr    %cl,%eax
  80241b:	09 e8                	or     %ebp,%eax
  80241d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802421:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802425:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802429:	d3 e0                	shl    %cl,%eax
  80242b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80242f:	89 f2                	mov    %esi,%edx
  802431:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802433:	8b 44 24 14          	mov    0x14(%esp),%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80243d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802441:	89 f9                	mov    %edi,%ecx
  802443:	d3 e8                	shr    %cl,%eax
  802445:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802447:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802449:	89 f2                	mov    %esi,%edx
  80244b:	f7 74 24 18          	divl   0x18(%esp)
  80244f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802451:	f7 64 24 0c          	mull   0xc(%esp)
  802455:	89 c5                	mov    %eax,%ebp
  802457:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802459:	39 d6                	cmp    %edx,%esi
  80245b:	72 67                	jb     8024c4 <__umoddi3+0x114>
  80245d:	74 75                	je     8024d4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80245f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802463:	29 e8                	sub    %ebp,%eax
  802465:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802467:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	89 f2                	mov    %esi,%edx
  80246f:	89 f9                	mov    %edi,%ecx
  802471:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802473:	09 d0                	or     %edx,%eax
  802475:	89 f2                	mov    %esi,%edx
  802477:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80247b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80247d:	83 c4 20             	add    $0x20,%esp
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802484:	85 c9                	test   %ecx,%ecx
  802486:	75 0b                	jne    802493 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802488:	b8 01 00 00 00       	mov    $0x1,%eax
  80248d:	31 d2                	xor    %edx,%edx
  80248f:	f7 f1                	div    %ecx
  802491:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802493:	89 f0                	mov    %esi,%eax
  802495:	31 d2                	xor    %edx,%edx
  802497:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802499:	89 f8                	mov    %edi,%eax
  80249b:	e9 3e ff ff ff       	jmp    8023de <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8024a0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024a2:	83 c4 20             	add    $0x20,%esp
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024ac:	39 f5                	cmp    %esi,%ebp
  8024ae:	72 04                	jb     8024b4 <__umoddi3+0x104>
  8024b0:	39 f9                	cmp    %edi,%ecx
  8024b2:	77 06                	ja     8024ba <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024b4:	89 f2                	mov    %esi,%edx
  8024b6:	29 cf                	sub    %ecx,%edi
  8024b8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8024ba:	89 f8                	mov    %edi,%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024c4:	89 d1                	mov    %edx,%ecx
  8024c6:	89 c5                	mov    %eax,%ebp
  8024c8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024cc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8024d0:	eb 8d                	jmp    80245f <__umoddi3+0xaf>
  8024d2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024d4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8024d8:	72 ea                	jb     8024c4 <__umoddi3+0x114>
  8024da:	89 f1                	mov    %esi,%ecx
  8024dc:	eb 81                	jmp    80245f <__umoddi3+0xaf>
