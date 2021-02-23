
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 f2 0a 00 00       	call   800b33 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 d2 0d 00 00       	call   800e3c <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  80007c:	e8 53 01 00 00       	call   8001d4 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 31 25 80 00 	movl   $0x802531,(%esp)
  800097:	e8 38 01 00 00       	call   8001d4 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 eb 0d 00 00       	call   800eac <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 10             	sub    $0x10,%esp
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d2:	e8 5c 0a 00 00       	call   800b33 <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e3:	c1 e0 07             	shl    $0x7,%eax
  8000e6:	29 d0                	sub    %edx,%eax
  8000e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ed:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f2:	85 f6                	test   %esi,%esi
  8000f4:	7e 07                	jle    8000fd <libmain+0x39>
		binaryname = argv[0];
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800101:	89 34 24             	mov    %esi,(%esp)
  800104:	e8 2b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800109:	e8 0a 00 00 00       	call   800118 <exit>
}
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
  800115:	00 00                	add    %al,(%eax)
	...

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80011e:	e8 38 10 00 00       	call   80115b <close_all>
	sys_env_destroy(0);
  800123:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012a:	e8 b2 09 00 00       	call   800ae1 <sys_env_destroy>
}
  80012f:	c9                   	leave  
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	53                   	push   %ebx
  800138:	83 ec 14             	sub    $0x14,%esp
  80013b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013e:	8b 03                	mov    (%ebx),%eax
  800140:	8b 55 08             	mov    0x8(%ebp),%edx
  800143:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800147:	40                   	inc    %eax
  800148:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014f:	75 19                	jne    80016a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800151:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800158:	00 
  800159:	8d 43 08             	lea    0x8(%ebx),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 40 09 00 00       	call   800aa4 <sys_cputs>
		b->idx = 0;
  800164:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016a:	ff 43 04             	incl   0x4(%ebx)
}
  80016d:	83 c4 14             	add    $0x14,%esp
  800170:	5b                   	pop    %ebx
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80017c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800183:	00 00 00 
	b.cnt = 0;
  800186:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800190:	8b 45 0c             	mov    0xc(%ebp),%eax
  800193:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800197:	8b 45 08             	mov    0x8(%ebp),%eax
  80019a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	c7 04 24 34 01 80 00 	movl   $0x800134,(%esp)
  8001af:	e8 82 01 00 00       	call   800336 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c4:	89 04 24             	mov    %eax,(%esp)
  8001c7:	e8 d8 08 00 00       	call   800aa4 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 87 ff ff ff       	call   800173 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 3c             	sub    $0x3c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d7                	mov    %edx,%edi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800210:	85 c0                	test   %eax,%eax
  800212:	75 08                	jne    80021c <printnum+0x2c>
  800214:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800217:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021a:	77 57                	ja     800273 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800220:	4b                   	dec    %ebx
  800221:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800225:	8b 45 10             	mov    0x10(%ebp),%eax
  800228:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800230:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800234:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023b:	00 
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	e8 66 20 00 00       	call   8022b4 <__udivdi3>
  80024e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800252:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025d:	89 fa                	mov    %edi,%edx
  80025f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800262:	e8 89 ff ff ff       	call   8001f0 <printnum>
  800267:	eb 0f                	jmp    800278 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800273:	4b                   	dec    %ebx
  800274:	85 db                	test   %ebx,%ebx
  800276:	7f f1                	jg     800269 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800278:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800280:	8b 45 10             	mov    0x10(%ebp),%eax
  800283:	89 44 24 08          	mov    %eax,0x8(%esp)
  800287:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028e:	00 
  80028f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	e8 33 21 00 00       	call   8023d4 <__umoddi3>
  8002a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a5:	0f be 80 52 25 80 00 	movsbl 0x802552(%eax),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002b2:	83 c4 3c             	add    $0x3c,%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bd:	83 fa 01             	cmp    $0x1,%edx
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x38>
	else if (lflag)
  8002d0:	85 d2                	test   %edx,%edx
  8002d2:	74 10                	je     8002e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800302:	73 08                	jae    80030c <sprintputch+0x18>
		*b->buf++ = ch;
  800304:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800307:	88 0a                	mov    %cl,(%edx)
  800309:	42                   	inc    %edx
  80030a:	89 10                	mov    %edx,(%eax)
}
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800314:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800317:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031b:	8b 45 10             	mov    0x10(%ebp),%eax
  80031e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
  800325:	89 44 24 04          	mov    %eax,0x4(%esp)
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	e8 02 00 00 00       	call   800336 <vprintfmt>
	va_end(ap);
}
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	57                   	push   %edi
  80033a:	56                   	push   %esi
  80033b:	53                   	push   %ebx
  80033c:	83 ec 4c             	sub    $0x4c,%esp
  80033f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800342:	8b 75 10             	mov    0x10(%ebp),%esi
  800345:	eb 12                	jmp    800359 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800347:	85 c0                	test   %eax,%eax
  800349:	0f 84 6b 03 00 00    	je     8006ba <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80034f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	0f b6 06             	movzbl (%esi),%eax
  80035c:	46                   	inc    %esi
  80035d:	83 f8 25             	cmp    $0x25,%eax
  800360:	75 e5                	jne    800347 <vprintfmt+0x11>
  800362:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800366:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80036d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800372:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	eb 26                	jmp    8003a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800387:	eb 1d                	jmp    8003a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800390:	eb 14                	jmp    8003a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800395:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80039c:	eb 08                	jmp    8003a6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80039e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003a1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	0f b6 06             	movzbl (%esi),%eax
  8003a9:	8d 56 01             	lea    0x1(%esi),%edx
  8003ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003af:	8a 16                	mov    (%esi),%dl
  8003b1:	83 ea 23             	sub    $0x23,%edx
  8003b4:	80 fa 55             	cmp    $0x55,%dl
  8003b7:	0f 87 e1 02 00 00    	ja     80069e <vprintfmt+0x368>
  8003bd:	0f b6 d2             	movzbl %dl,%edx
  8003c0:	ff 24 95 a0 26 80 00 	jmp    *0x8026a0(,%edx,4)
  8003c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ca:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003d2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003d6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003dc:	83 fa 09             	cmp    $0x9,%edx
  8003df:	77 2a                	ja     80040b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e2:	eb eb                	jmp    8003cf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ed:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f2:	eb 17                	jmp    80040b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f8:	78 98                	js     800392 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fd:	eb a7                	jmp    8003a6 <vprintfmt+0x70>
  8003ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800402:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800409:	eb 9b                	jmp    8003a6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80040b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040f:	79 95                	jns    8003a6 <vprintfmt+0x70>
  800411:	eb 8b                	jmp    80039e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800413:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800417:	eb 8d                	jmp    8003a6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 50 04             	lea    0x4(%eax),%edx
  80041f:	89 55 14             	mov    %edx,0x14(%ebp)
  800422:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800426:	8b 00                	mov    (%eax),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800431:	e9 23 ff ff ff       	jmp    800359 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	85 c0                	test   %eax,%eax
  800443:	79 02                	jns    800447 <vprintfmt+0x111>
  800445:	f7 d8                	neg    %eax
  800447:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800449:	83 f8 10             	cmp    $0x10,%eax
  80044c:	7f 0b                	jg     800459 <vprintfmt+0x123>
  80044e:	8b 04 85 00 28 80 00 	mov    0x802800(,%eax,4),%eax
  800455:	85 c0                	test   %eax,%eax
  800457:	75 23                	jne    80047c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800459:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045d:	c7 44 24 08 6a 25 80 	movl   $0x80256a,0x8(%esp)
  800464:	00 
  800465:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800469:	8b 45 08             	mov    0x8(%ebp),%eax
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	e8 9a fe ff ff       	call   80030e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800477:	e9 dd fe ff ff       	jmp    800359 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80047c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800480:	c7 44 24 08 55 29 80 	movl   $0x802955,0x8(%esp)
  800487:	00 
  800488:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048c:	8b 55 08             	mov    0x8(%ebp),%edx
  80048f:	89 14 24             	mov    %edx,(%esp)
  800492:	e8 77 fe ff ff       	call   80030e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049a:	e9 ba fe ff ff       	jmp    800359 <vprintfmt+0x23>
  80049f:	89 f9                	mov    %edi,%ecx
  8004a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 50 04             	lea    0x4(%eax),%edx
  8004ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b0:	8b 30                	mov    (%eax),%esi
  8004b2:	85 f6                	test   %esi,%esi
  8004b4:	75 05                	jne    8004bb <vprintfmt+0x185>
				p = "(null)";
  8004b6:	be 63 25 80 00       	mov    $0x802563,%esi
			if (width > 0 && padc != '-')
  8004bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004bf:	0f 8e 84 00 00 00    	jle    800549 <vprintfmt+0x213>
  8004c5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004c9:	74 7e                	je     800549 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004cf:	89 34 24             	mov    %esi,(%esp)
  8004d2:	e8 8b 02 00 00       	call   800762 <strnlen>
  8004d7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004da:	29 c2                	sub    %eax,%edx
  8004dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004df:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004e3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004e6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004e9:	89 de                	mov    %ebx,%esi
  8004eb:	89 d3                	mov    %edx,%ebx
  8004ed:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	eb 0b                	jmp    8004fc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f5:	89 3c 24             	mov    %edi,(%esp)
  8004f8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	4b                   	dec    %ebx
  8004fc:	85 db                	test   %ebx,%ebx
  8004fe:	7f f1                	jg     8004f1 <vprintfmt+0x1bb>
  800500:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800503:	89 f3                	mov    %esi,%ebx
  800505:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800508:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050b:	85 c0                	test   %eax,%eax
  80050d:	79 05                	jns    800514 <vprintfmt+0x1de>
  80050f:	b8 00 00 00 00       	mov    $0x0,%eax
  800514:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800517:	29 c2                	sub    %eax,%edx
  800519:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80051c:	eb 2b                	jmp    800549 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800522:	74 18                	je     80053c <vprintfmt+0x206>
  800524:	8d 50 e0             	lea    -0x20(%eax),%edx
  800527:	83 fa 5e             	cmp    $0x5e,%edx
  80052a:	76 10                	jbe    80053c <vprintfmt+0x206>
					putch('?', putdat);
  80052c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800530:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800537:	ff 55 08             	call   *0x8(%ebp)
  80053a:	eb 0a                	jmp    800546 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80053c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800546:	ff 4d e4             	decl   -0x1c(%ebp)
  800549:	0f be 06             	movsbl (%esi),%eax
  80054c:	46                   	inc    %esi
  80054d:	85 c0                	test   %eax,%eax
  80054f:	74 21                	je     800572 <vprintfmt+0x23c>
  800551:	85 ff                	test   %edi,%edi
  800553:	78 c9                	js     80051e <vprintfmt+0x1e8>
  800555:	4f                   	dec    %edi
  800556:	79 c6                	jns    80051e <vprintfmt+0x1e8>
  800558:	8b 7d 08             	mov    0x8(%ebp),%edi
  80055b:	89 de                	mov    %ebx,%esi
  80055d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800560:	eb 18                	jmp    80057a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800562:	89 74 24 04          	mov    %esi,0x4(%esp)
  800566:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80056d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056f:	4b                   	dec    %ebx
  800570:	eb 08                	jmp    80057a <vprintfmt+0x244>
  800572:	8b 7d 08             	mov    0x8(%ebp),%edi
  800575:	89 de                	mov    %ebx,%esi
  800577:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80057a:	85 db                	test   %ebx,%ebx
  80057c:	7f e4                	jg     800562 <vprintfmt+0x22c>
  80057e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800581:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800583:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800586:	e9 ce fd ff ff       	jmp    800359 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058b:	83 f9 01             	cmp    $0x1,%ecx
  80058e:	7e 10                	jle    8005a0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 08             	lea    0x8(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
  80059b:	8b 78 04             	mov    0x4(%eax),%edi
  80059e:	eb 26                	jmp    8005c6 <vprintfmt+0x290>
	else if (lflag)
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	74 12                	je     8005b6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 30                	mov    (%eax),%esi
  8005af:	89 f7                	mov    %esi,%edi
  8005b1:	c1 ff 1f             	sar    $0x1f,%edi
  8005b4:	eb 10                	jmp    8005c6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bf:	8b 30                	mov    (%eax),%esi
  8005c1:	89 f7                	mov    %esi,%edi
  8005c3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	78 0a                	js     8005d4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cf:	e9 8c 00 00 00       	jmp    800660 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e2:	f7 de                	neg    %esi
  8005e4:	83 d7 00             	adc    $0x0,%edi
  8005e7:	f7 df                	neg    %edi
			}
			base = 10;
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ee:	eb 70                	jmp    800660 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f0:	89 ca                	mov    %ecx,%edx
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 c0 fc ff ff       	call   8002ba <getuint>
  8005fa:	89 c6                	mov    %eax,%esi
  8005fc:	89 d7                	mov    %edx,%edi
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800603:	eb 5b                	jmp    800660 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800605:	89 ca                	mov    %ecx,%edx
  800607:	8d 45 14             	lea    0x14(%ebp),%eax
  80060a:	e8 ab fc ff ff       	call   8002ba <getuint>
  80060f:	89 c6                	mov    %eax,%esi
  800611:	89 d7                	mov    %edx,%edi
			base = 8;
  800613:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800618:	eb 46                	jmp    800660 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80061a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800625:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 50 04             	lea    0x4(%eax),%edx
  80063c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063f:	8b 30                	mov    (%eax),%esi
  800641:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800646:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064b:	eb 13                	jmp    800660 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064d:	89 ca                	mov    %ecx,%edx
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 63 fc ff ff       	call   8002ba <getuint>
  800657:	89 c6                	mov    %eax,%esi
  800659:	89 d7                	mov    %edx,%edi
			base = 16;
  80065b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800660:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800664:	89 54 24 10          	mov    %edx,0x10(%esp)
  800668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80066f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800673:	89 34 24             	mov    %esi,(%esp)
  800676:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067a:	89 da                	mov    %ebx,%edx
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	e8 6c fb ff ff       	call   8001f0 <printnum>
			break;
  800684:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800687:	e9 cd fc ff ff       	jmp    800359 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800699:	e9 bb fc ff ff       	jmp    800359 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ac:	eb 01                	jmp    8006af <vprintfmt+0x379>
  8006ae:	4e                   	dec    %esi
  8006af:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b3:	75 f9                	jne    8006ae <vprintfmt+0x378>
  8006b5:	e9 9f fc ff ff       	jmp    800359 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ba:	83 c4 4c             	add    $0x4c,%esp
  8006bd:	5b                   	pop    %ebx
  8006be:	5e                   	pop    %esi
  8006bf:	5f                   	pop    %edi
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 28             	sub    $0x28,%esp
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 30                	je     800713 <vsnprintf+0x51>
  8006e3:	85 d2                	test   %edx,%edx
  8006e5:	7e 33                	jle    80071a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	c7 04 24 f4 02 80 00 	movl   $0x8002f4,(%esp)
  800703:	e8 2e fc ff ff       	call   800336 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800708:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800711:	eb 0c                	jmp    80071f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800718:	eb 05                	jmp    80071f <vsnprintf+0x5d>
  80071a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800727:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072e:	8b 45 10             	mov    0x10(%ebp),%eax
  800731:	89 44 24 08          	mov    %eax,0x8(%esp)
  800735:	8b 45 0c             	mov    0xc(%ebp),%eax
  800738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	89 04 24             	mov    %eax,(%esp)
  800742:	e8 7b ff ff ff       	call   8006c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    
  800749:	00 00                	add    %al,(%eax)
	...

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 01                	jmp    80075a <strlen+0xe>
		n++;
  800759:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075e:	75 f9                	jne    800759 <strlen+0xd>
		n++;
	return n;
}
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800768:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	eb 01                	jmp    800773 <strnlen+0x11>
		n++;
  800772:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800773:	39 d0                	cmp    %edx,%eax
  800775:	74 06                	je     80077d <strnlen+0x1b>
  800777:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077b:	75 f5                	jne    800772 <strnlen+0x10>
		n++;
	return n;
}
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	53                   	push   %ebx
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800789:	ba 00 00 00 00       	mov    $0x0,%edx
  80078e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800791:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800794:	42                   	inc    %edx
  800795:	84 c9                	test   %cl,%cl
  800797:	75 f5                	jne    80078e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800799:	5b                   	pop    %ebx
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a6:	89 1c 24             	mov    %ebx,(%esp)
  8007a9:	e8 9e ff ff ff       	call   80074c <strlen>
	strcpy(dst + len, src);
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b5:	01 d8                	add    %ebx,%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 c0 ff ff ff       	call   80077f <strcpy>
	return dst;
}
  8007bf:	89 d8                	mov    %ebx,%eax
  8007c1:	83 c4 08             	add    $0x8,%esp
  8007c4:	5b                   	pop    %ebx
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007da:	eb 0c                	jmp    8007e8 <strncpy+0x21>
		*dst++ = *src;
  8007dc:	8a 1a                	mov    (%edx),%bl
  8007de:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e1:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e7:	41                   	inc    %ecx
  8007e8:	39 f1                	cmp    %esi,%ecx
  8007ea:	75 f0                	jne    8007dc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fe:	85 d2                	test   %edx,%edx
  800800:	75 0a                	jne    80080c <strlcpy+0x1c>
  800802:	89 f0                	mov    %esi,%eax
  800804:	eb 1a                	jmp    800820 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800806:	88 18                	mov    %bl,(%eax)
  800808:	40                   	inc    %eax
  800809:	41                   	inc    %ecx
  80080a:	eb 02                	jmp    80080e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80080e:	4a                   	dec    %edx
  80080f:	74 0a                	je     80081b <strlcpy+0x2b>
  800811:	8a 19                	mov    (%ecx),%bl
  800813:	84 db                	test   %bl,%bl
  800815:	75 ef                	jne    800806 <strlcpy+0x16>
  800817:	89 c2                	mov    %eax,%edx
  800819:	eb 02                	jmp    80081d <strlcpy+0x2d>
  80081b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80081d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800820:	29 f0                	sub    %esi,%eax
}
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082f:	eb 02                	jmp    800833 <strcmp+0xd>
		p++, q++;
  800831:	41                   	inc    %ecx
  800832:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800833:	8a 01                	mov    (%ecx),%al
  800835:	84 c0                	test   %al,%al
  800837:	74 04                	je     80083d <strcmp+0x17>
  800839:	3a 02                	cmp    (%edx),%al
  80083b:	74 f4                	je     800831 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	0f b6 12             	movzbl (%edx),%edx
  800843:	29 d0                	sub    %edx,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800854:	eb 03                	jmp    800859 <strncmp+0x12>
		n--, p++, q++;
  800856:	4a                   	dec    %edx
  800857:	40                   	inc    %eax
  800858:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800859:	85 d2                	test   %edx,%edx
  80085b:	74 14                	je     800871 <strncmp+0x2a>
  80085d:	8a 18                	mov    (%eax),%bl
  80085f:	84 db                	test   %bl,%bl
  800861:	74 04                	je     800867 <strncmp+0x20>
  800863:	3a 19                	cmp    (%ecx),%bl
  800865:	74 ef                	je     800856 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800867:	0f b6 00             	movzbl (%eax),%eax
  80086a:	0f b6 11             	movzbl (%ecx),%edx
  80086d:	29 d0                	sub    %edx,%eax
  80086f:	eb 05                	jmp    800876 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800876:	5b                   	pop    %ebx
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800882:	eb 05                	jmp    800889 <strchr+0x10>
		if (*s == c)
  800884:	38 ca                	cmp    %cl,%dl
  800886:	74 0c                	je     800894 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800888:	40                   	inc    %eax
  800889:	8a 10                	mov    (%eax),%dl
  80088b:	84 d2                	test   %dl,%dl
  80088d:	75 f5                	jne    800884 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089f:	eb 05                	jmp    8008a6 <strfind+0x10>
		if (*s == c)
  8008a1:	38 ca                	cmp    %cl,%dl
  8008a3:	74 07                	je     8008ac <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a5:	40                   	inc    %eax
  8008a6:	8a 10                	mov    (%eax),%dl
  8008a8:	84 d2                	test   %dl,%dl
  8008aa:	75 f5                	jne    8008a1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	57                   	push   %edi
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008bd:	85 c9                	test   %ecx,%ecx
  8008bf:	74 30                	je     8008f1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c7:	75 25                	jne    8008ee <memset+0x40>
  8008c9:	f6 c1 03             	test   $0x3,%cl
  8008cc:	75 20                	jne    8008ee <memset+0x40>
		c &= 0xFF;
  8008ce:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d1:	89 d3                	mov    %edx,%ebx
  8008d3:	c1 e3 08             	shl    $0x8,%ebx
  8008d6:	89 d6                	mov    %edx,%esi
  8008d8:	c1 e6 18             	shl    $0x18,%esi
  8008db:	89 d0                	mov    %edx,%eax
  8008dd:	c1 e0 10             	shl    $0x10,%eax
  8008e0:	09 f0                	or     %esi,%eax
  8008e2:	09 d0                	or     %edx,%eax
  8008e4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008e6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008e9:	fc                   	cld    
  8008ea:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ec:	eb 03                	jmp    8008f1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ee:	fc                   	cld    
  8008ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f1:	89 f8                	mov    %edi,%eax
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5f                   	pop    %edi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	57                   	push   %edi
  8008fc:	56                   	push   %esi
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8b 75 0c             	mov    0xc(%ebp),%esi
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800906:	39 c6                	cmp    %eax,%esi
  800908:	73 34                	jae    80093e <memmove+0x46>
  80090a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090d:	39 d0                	cmp    %edx,%eax
  80090f:	73 2d                	jae    80093e <memmove+0x46>
		s += n;
		d += n;
  800911:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800914:	f6 c2 03             	test   $0x3,%dl
  800917:	75 1b                	jne    800934 <memmove+0x3c>
  800919:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091f:	75 13                	jne    800934 <memmove+0x3c>
  800921:	f6 c1 03             	test   $0x3,%cl
  800924:	75 0e                	jne    800934 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800926:	83 ef 04             	sub    $0x4,%edi
  800929:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80092f:	fd                   	std    
  800930:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800932:	eb 07                	jmp    80093b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800934:	4f                   	dec    %edi
  800935:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800938:	fd                   	std    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093b:	fc                   	cld    
  80093c:	eb 20                	jmp    80095e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800944:	75 13                	jne    800959 <memmove+0x61>
  800946:	a8 03                	test   $0x3,%al
  800948:	75 0f                	jne    800959 <memmove+0x61>
  80094a:	f6 c1 03             	test   $0x3,%cl
  80094d:	75 0a                	jne    800959 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800952:	89 c7                	mov    %eax,%edi
  800954:	fc                   	cld    
  800955:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800957:	eb 05                	jmp    80095e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800959:	89 c7                	mov    %eax,%edi
  80095b:	fc                   	cld    
  80095c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800968:	8b 45 10             	mov    0x10(%ebp),%eax
  80096b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	89 44 24 04          	mov    %eax,0x4(%esp)
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	89 04 24             	mov    %eax,(%esp)
  80097c:	e8 77 ff ff ff       	call   8008f8 <memmove>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	ba 00 00 00 00       	mov    $0x0,%edx
  800997:	eb 16                	jmp    8009af <memcmp+0x2c>
		if (*s1 != *s2)
  800999:	8a 04 17             	mov    (%edi,%edx,1),%al
  80099c:	42                   	inc    %edx
  80099d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009a1:	38 c8                	cmp    %cl,%al
  8009a3:	74 0a                	je     8009af <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009a5:	0f b6 c0             	movzbl %al,%eax
  8009a8:	0f b6 c9             	movzbl %cl,%ecx
  8009ab:	29 c8                	sub    %ecx,%eax
  8009ad:	eb 09                	jmp    8009b8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	39 da                	cmp    %ebx,%edx
  8009b1:	75 e6                	jne    800999 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c6:	89 c2                	mov    %eax,%edx
  8009c8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009cb:	eb 05                	jmp    8009d2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cd:	38 08                	cmp    %cl,(%eax)
  8009cf:	74 05                	je     8009d6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d1:	40                   	inc    %eax
  8009d2:	39 d0                	cmp    %edx,%eax
  8009d4:	72 f7                	jb     8009cd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e4:	eb 01                	jmp    8009e7 <strtol+0xf>
		s++;
  8009e6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e7:	8a 02                	mov    (%edx),%al
  8009e9:	3c 20                	cmp    $0x20,%al
  8009eb:	74 f9                	je     8009e6 <strtol+0xe>
  8009ed:	3c 09                	cmp    $0x9,%al
  8009ef:	74 f5                	je     8009e6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f1:	3c 2b                	cmp    $0x2b,%al
  8009f3:	75 08                	jne    8009fd <strtol+0x25>
		s++;
  8009f5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fb:	eb 13                	jmp    800a10 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009fd:	3c 2d                	cmp    $0x2d,%al
  8009ff:	75 0a                	jne    800a0b <strtol+0x33>
		s++, neg = 1;
  800a01:	8d 52 01             	lea    0x1(%edx),%edx
  800a04:	bf 01 00 00 00       	mov    $0x1,%edi
  800a09:	eb 05                	jmp    800a10 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a10:	85 db                	test   %ebx,%ebx
  800a12:	74 05                	je     800a19 <strtol+0x41>
  800a14:	83 fb 10             	cmp    $0x10,%ebx
  800a17:	75 28                	jne    800a41 <strtol+0x69>
  800a19:	8a 02                	mov    (%edx),%al
  800a1b:	3c 30                	cmp    $0x30,%al
  800a1d:	75 10                	jne    800a2f <strtol+0x57>
  800a1f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a23:	75 0a                	jne    800a2f <strtol+0x57>
		s += 2, base = 16;
  800a25:	83 c2 02             	add    $0x2,%edx
  800a28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2d:	eb 12                	jmp    800a41 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a2f:	85 db                	test   %ebx,%ebx
  800a31:	75 0e                	jne    800a41 <strtol+0x69>
  800a33:	3c 30                	cmp    $0x30,%al
  800a35:	75 05                	jne    800a3c <strtol+0x64>
		s++, base = 8;
  800a37:	42                   	inc    %edx
  800a38:	b3 08                	mov    $0x8,%bl
  800a3a:	eb 05                	jmp    800a41 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
  800a46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a48:	8a 0a                	mov    (%edx),%cl
  800a4a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a4d:	80 fb 09             	cmp    $0x9,%bl
  800a50:	77 08                	ja     800a5a <strtol+0x82>
			dig = *s - '0';
  800a52:	0f be c9             	movsbl %cl,%ecx
  800a55:	83 e9 30             	sub    $0x30,%ecx
  800a58:	eb 1e                	jmp    800a78 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a5a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a5d:	80 fb 19             	cmp    $0x19,%bl
  800a60:	77 08                	ja     800a6a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a62:	0f be c9             	movsbl %cl,%ecx
  800a65:	83 e9 57             	sub    $0x57,%ecx
  800a68:	eb 0e                	jmp    800a78 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a6a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a6d:	80 fb 19             	cmp    $0x19,%bl
  800a70:	77 12                	ja     800a84 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a72:	0f be c9             	movsbl %cl,%ecx
  800a75:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a78:	39 f1                	cmp    %esi,%ecx
  800a7a:	7d 0c                	jge    800a88 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a7c:	42                   	inc    %edx
  800a7d:	0f af c6             	imul   %esi,%eax
  800a80:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a82:	eb c4                	jmp    800a48 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a84:	89 c1                	mov    %eax,%ecx
  800a86:	eb 02                	jmp    800a8a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a88:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8e:	74 05                	je     800a95 <strtol+0xbd>
		*endptr = (char *) s;
  800a90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a93:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a95:	85 ff                	test   %edi,%edi
  800a97:	74 04                	je     800a9d <strtol+0xc5>
  800a99:	89 c8                	mov    %ecx,%eax
  800a9b:	f7 d8                	neg    %eax
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    
	...

00800aa4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	89 c3                	mov    %eax,%ebx
  800ab7:	89 c7                	mov    %eax,%edi
  800ab9:	89 c6                	mov    %eax,%esi
  800abb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  800acd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad2:	89 d1                	mov    %edx,%ecx
  800ad4:	89 d3                	mov    %edx,%ebx
  800ad6:	89 d7                	mov    %edx,%edi
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aef:	b8 03 00 00 00       	mov    $0x3,%eax
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	89 cb                	mov    %ecx,%ebx
  800af9:	89 cf                	mov    %ecx,%edi
  800afb:	89 ce                	mov    %ecx,%esi
  800afd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aff:	85 c0                	test   %eax,%eax
  800b01:	7e 28                	jle    800b2b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b07:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b0e:	00 
  800b0f:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800b16:	00 
  800b17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b1e:	00 
  800b1f:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800b26:	e8 ed 16 00 00       	call   802218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2b:	83 c4 2c             	add    $0x2c,%esp
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b43:	89 d1                	mov    %edx,%ecx
  800b45:	89 d3                	mov    %edx,%ebx
  800b47:	89 d7                	mov    %edx,%edi
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_yield>:

void
sys_yield(void)
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
  800b5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b7a:	be 00 00 00 00       	mov    $0x0,%esi
  800b7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	89 f7                	mov    %esi,%edi
  800b8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 28                	jle    800bbd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b99:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ba0:	00 
  800ba1:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb0:	00 
  800bb1:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800bb8:	e8 5b 16 00 00       	call   802218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbd:	83 c4 2c             	add    $0x2c,%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7e 28                	jle    800c10 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bec:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bf3:	00 
  800bf4:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800bfb:	00 
  800bfc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c03:	00 
  800c04:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800c0b:	e8 08 16 00 00       	call   802218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c10:	83 c4 2c             	add    $0x2c,%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c26:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	89 df                	mov    %ebx,%edi
  800c33:	89 de                	mov    %ebx,%esi
  800c35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c37:	85 c0                	test   %eax,%eax
  800c39:	7e 28                	jle    800c63 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c46:	00 
  800c47:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800c4e:	00 
  800c4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c56:	00 
  800c57:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800c5e:	e8 b5 15 00 00       	call   802218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c63:	83 c4 2c             	add    $0x2c,%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 28                	jle    800cb6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c92:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c99:	00 
  800c9a:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800ca1:	00 
  800ca2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca9:	00 
  800caa:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800cb1:	e8 62 15 00 00       	call   802218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb6:	83 c4 2c             	add    $0x2c,%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 28                	jle    800d09 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cec:	00 
  800ced:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfc:	00 
  800cfd:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800d04:	e8 0f 15 00 00       	call   802218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d09:	83 c4 2c             	add    $0x2c,%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 28                	jle    800d5c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d38:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d3f:	00 
  800d40:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800d47:	00 
  800d48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4f:	00 
  800d50:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800d57:	e8 bc 14 00 00       	call   802218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5c:	83 c4 2c             	add    $0x2c,%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	be 00 00 00 00       	mov    $0x0,%esi
  800d6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 cb                	mov    %ecx,%ebx
  800d9f:	89 cf                	mov    %ecx,%edi
  800da1:	89 ce                	mov    %ecx,%esi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 28                	jle    800dd1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dad:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800db4:	00 
  800db5:	c7 44 24 08 63 28 80 	movl   $0x802863,0x8(%esp)
  800dbc:	00 
  800dbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc4:	00 
  800dc5:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800dcc:	e8 47 14 00 00       	call   802218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd1:	83 c4 2c             	add    $0x2c,%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddf:	ba 00 00 00 00       	mov    $0x0,%edx
  800de4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de9:	89 d1                	mov    %edx,%ecx
  800deb:	89 d3                	mov    %edx,%ebx
  800ded:	89 d7                	mov    %edx,%edi
  800def:	89 d6                	mov    %edx,%esi
  800df1:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e03:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	89 df                	mov    %ebx,%edi
  800e10:	89 de                	mov    %ebx,%esi
  800e12:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e24:	b8 10 00 00 00       	mov    $0x10,%eax
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 df                	mov    %ebx,%edi
  800e31:	89 de                	mov    %ebx,%esi
  800e33:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
	...

00800e3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	83 ec 10             	sub    $0x10,%esp
  800e44:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	74 0a                	je     800e5b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  800e51:	89 04 24             	mov    %eax,(%esp)
  800e54:	e8 2e ff ff ff       	call   800d87 <sys_ipc_recv>
  800e59:	eb 0c                	jmp    800e67 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  800e5b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  800e62:	e8 20 ff ff ff       	call   800d87 <sys_ipc_recv>
	}
	if (r < 0)
  800e67:	85 c0                	test   %eax,%eax
  800e69:	79 16                	jns    800e81 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  800e6b:	85 db                	test   %ebx,%ebx
  800e6d:	74 06                	je     800e75 <ipc_recv+0x39>
  800e6f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  800e75:	85 f6                	test   %esi,%esi
  800e77:	74 2c                	je     800ea5 <ipc_recv+0x69>
  800e79:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800e7f:	eb 24                	jmp    800ea5 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  800e81:	85 db                	test   %ebx,%ebx
  800e83:	74 0a                	je     800e8f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  800e85:	a1 08 40 80 00       	mov    0x804008,%eax
  800e8a:	8b 40 74             	mov    0x74(%eax),%eax
  800e8d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  800e8f:	85 f6                	test   %esi,%esi
  800e91:	74 0a                	je     800e9d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  800e93:	a1 08 40 80 00       	mov    0x804008,%eax
  800e98:	8b 40 78             	mov    0x78(%eax),%eax
  800e9b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  800e9d:	a1 08 40 80 00       	mov    0x804008,%eax
  800ea2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 1c             	sub    $0x1c,%esp
  800eb5:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ebb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  800ebe:	85 db                	test   %ebx,%ebx
  800ec0:	74 19                	je     800edb <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  800ec2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ecd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ed1:	89 34 24             	mov    %esi,(%esp)
  800ed4:	e8 8b fe ff ff       	call   800d64 <sys_ipc_try_send>
  800ed9:	eb 1c                	jmp    800ef7 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  800edb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  800eea:	ee 
  800eeb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800eef:	89 34 24             	mov    %esi,(%esp)
  800ef2:	e8 6d fe ff ff       	call   800d64 <sys_ipc_try_send>
		}
		if (r == 0)
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	74 2c                	je     800f27 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  800efb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800efe:	74 20                	je     800f20 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  800f00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f04:	c7 44 24 08 8e 28 80 	movl   $0x80288e,0x8(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800f13:	00 
  800f14:	c7 04 24 a1 28 80 00 	movl   $0x8028a1,(%esp)
  800f1b:	e8 f8 12 00 00       	call   802218 <_panic>
		}
		sys_yield();
  800f20:	e8 2d fc ff ff       	call   800b52 <sys_yield>
	}
  800f25:	eb 97                	jmp    800ebe <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  800f27:	83 c4 1c             	add    $0x1c,%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	53                   	push   %ebx
  800f33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800f3b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800f42:	89 c2                	mov    %eax,%edx
  800f44:	c1 e2 07             	shl    $0x7,%edx
  800f47:	29 ca                	sub    %ecx,%edx
  800f49:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800f4f:	8b 52 50             	mov    0x50(%edx),%edx
  800f52:	39 da                	cmp    %ebx,%edx
  800f54:	75 0f                	jne    800f65 <ipc_find_env+0x36>
			return envs[i].env_id;
  800f56:	c1 e0 07             	shl    $0x7,%eax
  800f59:	29 c8                	sub    %ecx,%eax
  800f5b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800f60:	8b 40 40             	mov    0x40(%eax),%eax
  800f63:	eb 0c                	jmp    800f71 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f65:	40                   	inc    %eax
  800f66:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f6b:	75 ce                	jne    800f3b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f6d:	66 b8 00 00          	mov    $0x0,%ax
}
  800f71:	5b                   	pop    %ebx
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f7f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	89 04 24             	mov    %eax,(%esp)
  800f90:	e8 df ff ff ff       	call   800f74 <fd2num>
  800f95:	c1 e0 0c             	shl    $0xc,%eax
  800f98:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	53                   	push   %ebx
  800fa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fa6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fab:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fad:	89 c2                	mov    %eax,%edx
  800faf:	c1 ea 16             	shr    $0x16,%edx
  800fb2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb9:	f6 c2 01             	test   $0x1,%dl
  800fbc:	74 11                	je     800fcf <fd_alloc+0x30>
  800fbe:	89 c2                	mov    %eax,%edx
  800fc0:	c1 ea 0c             	shr    $0xc,%edx
  800fc3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fca:	f6 c2 01             	test   $0x1,%dl
  800fcd:	75 09                	jne    800fd8 <fd_alloc+0x39>
			*fd_store = fd;
  800fcf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800fd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd6:	eb 17                	jmp    800fef <fd_alloc+0x50>
  800fd8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fdd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fe2:	75 c7                	jne    800fab <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fe4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fef:	5b                   	pop    %ebx
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ff8:	83 f8 1f             	cmp    $0x1f,%eax
  800ffb:	77 36                	ja     801033 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ffd:	c1 e0 0c             	shl    $0xc,%eax
  801000:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801005:	89 c2                	mov    %eax,%edx
  801007:	c1 ea 16             	shr    $0x16,%edx
  80100a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801011:	f6 c2 01             	test   $0x1,%dl
  801014:	74 24                	je     80103a <fd_lookup+0x48>
  801016:	89 c2                	mov    %eax,%edx
  801018:	c1 ea 0c             	shr    $0xc,%edx
  80101b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801022:	f6 c2 01             	test   $0x1,%dl
  801025:	74 1a                	je     801041 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801027:	8b 55 0c             	mov    0xc(%ebp),%edx
  80102a:	89 02                	mov    %eax,(%edx)
	return 0;
  80102c:	b8 00 00 00 00       	mov    $0x0,%eax
  801031:	eb 13                	jmp    801046 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801033:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801038:	eb 0c                	jmp    801046 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80103a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80103f:	eb 05                	jmp    801046 <fd_lookup+0x54>
  801041:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	53                   	push   %ebx
  80104c:	83 ec 14             	sub    $0x14,%esp
  80104f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801052:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801055:	ba 00 00 00 00       	mov    $0x0,%edx
  80105a:	eb 0e                	jmp    80106a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80105c:	39 08                	cmp    %ecx,(%eax)
  80105e:	75 09                	jne    801069 <dev_lookup+0x21>
			*dev = devtab[i];
  801060:	89 03                	mov    %eax,(%ebx)
			return 0;
  801062:	b8 00 00 00 00       	mov    $0x0,%eax
  801067:	eb 33                	jmp    80109c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801069:	42                   	inc    %edx
  80106a:	8b 04 95 28 29 80 00 	mov    0x802928(,%edx,4),%eax
  801071:	85 c0                	test   %eax,%eax
  801073:	75 e7                	jne    80105c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801075:	a1 08 40 80 00       	mov    0x804008,%eax
  80107a:	8b 40 48             	mov    0x48(%eax),%eax
  80107d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801081:	89 44 24 04          	mov    %eax,0x4(%esp)
  801085:	c7 04 24 ac 28 80 00 	movl   $0x8028ac,(%esp)
  80108c:	e8 43 f1 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801091:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801097:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80109c:	83 c4 14             	add    $0x14,%esp
  80109f:	5b                   	pop    %ebx
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	56                   	push   %esi
  8010a6:	53                   	push   %ebx
  8010a7:	83 ec 30             	sub    $0x30,%esp
  8010aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8010ad:	8a 45 0c             	mov    0xc(%ebp),%al
  8010b0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010b3:	89 34 24             	mov    %esi,(%esp)
  8010b6:	e8 b9 fe ff ff       	call   800f74 <fd2num>
  8010bb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010c2:	89 04 24             	mov    %eax,(%esp)
  8010c5:	e8 28 ff ff ff       	call   800ff2 <fd_lookup>
  8010ca:	89 c3                	mov    %eax,%ebx
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	78 05                	js     8010d5 <fd_close+0x33>
	    || fd != fd2)
  8010d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010d3:	74 0d                	je     8010e2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8010d5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010d9:	75 46                	jne    801121 <fd_close+0x7f>
  8010db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e0:	eb 3f                	jmp    801121 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e9:	8b 06                	mov    (%esi),%eax
  8010eb:	89 04 24             	mov    %eax,(%esp)
  8010ee:	e8 55 ff ff ff       	call   801048 <dev_lookup>
  8010f3:	89 c3                	mov    %eax,%ebx
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	78 18                	js     801111 <fd_close+0x6f>
		if (dev->dev_close)
  8010f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010fc:	8b 40 10             	mov    0x10(%eax),%eax
  8010ff:	85 c0                	test   %eax,%eax
  801101:	74 09                	je     80110c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801103:	89 34 24             	mov    %esi,(%esp)
  801106:	ff d0                	call   *%eax
  801108:	89 c3                	mov    %eax,%ebx
  80110a:	eb 05                	jmp    801111 <fd_close+0x6f>
		else
			r = 0;
  80110c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801111:	89 74 24 04          	mov    %esi,0x4(%esp)
  801115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80111c:	e8 f7 fa ff ff       	call   800c18 <sys_page_unmap>
	return r;
}
  801121:	89 d8                	mov    %ebx,%eax
  801123:	83 c4 30             	add    $0x30,%esp
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801130:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801133:	89 44 24 04          	mov    %eax,0x4(%esp)
  801137:	8b 45 08             	mov    0x8(%ebp),%eax
  80113a:	89 04 24             	mov    %eax,(%esp)
  80113d:	e8 b0 fe ff ff       	call   800ff2 <fd_lookup>
  801142:	85 c0                	test   %eax,%eax
  801144:	78 13                	js     801159 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801146:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80114d:	00 
  80114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801151:	89 04 24             	mov    %eax,(%esp)
  801154:	e8 49 ff ff ff       	call   8010a2 <fd_close>
}
  801159:	c9                   	leave  
  80115a:	c3                   	ret    

0080115b <close_all>:

void
close_all(void)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	53                   	push   %ebx
  80115f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801162:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801167:	89 1c 24             	mov    %ebx,(%esp)
  80116a:	e8 bb ff ff ff       	call   80112a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80116f:	43                   	inc    %ebx
  801170:	83 fb 20             	cmp    $0x20,%ebx
  801173:	75 f2                	jne    801167 <close_all+0xc>
		close(i);
}
  801175:	83 c4 14             	add    $0x14,%esp
  801178:	5b                   	pop    %ebx
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 4c             	sub    $0x4c,%esp
  801184:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801187:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80118a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	89 04 24             	mov    %eax,(%esp)
  801194:	e8 59 fe ff ff       	call   800ff2 <fd_lookup>
  801199:	89 c3                	mov    %eax,%ebx
  80119b:	85 c0                	test   %eax,%eax
  80119d:	0f 88 e3 00 00 00    	js     801286 <dup+0x10b>
		return r;
	close(newfdnum);
  8011a3:	89 3c 24             	mov    %edi,(%esp)
  8011a6:	e8 7f ff ff ff       	call   80112a <close>

	newfd = INDEX2FD(newfdnum);
  8011ab:	89 fe                	mov    %edi,%esi
  8011ad:	c1 e6 0c             	shl    $0xc,%esi
  8011b0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8011b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b9:	89 04 24             	mov    %eax,(%esp)
  8011bc:	e8 c3 fd ff ff       	call   800f84 <fd2data>
  8011c1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011c3:	89 34 24             	mov    %esi,(%esp)
  8011c6:	e8 b9 fd ff ff       	call   800f84 <fd2data>
  8011cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011ce:	89 d8                	mov    %ebx,%eax
  8011d0:	c1 e8 16             	shr    $0x16,%eax
  8011d3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011da:	a8 01                	test   $0x1,%al
  8011dc:	74 46                	je     801224 <dup+0xa9>
  8011de:	89 d8                	mov    %ebx,%eax
  8011e0:	c1 e8 0c             	shr    $0xc,%eax
  8011e3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011ea:	f6 c2 01             	test   $0x1,%dl
  8011ed:	74 35                	je     801224 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801202:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801206:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80120d:	00 
  80120e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801212:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801219:	e8 a7 f9 ff ff       	call   800bc5 <sys_page_map>
  80121e:	89 c3                	mov    %eax,%ebx
  801220:	85 c0                	test   %eax,%eax
  801222:	78 3b                	js     80125f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801224:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801227:	89 c2                	mov    %eax,%edx
  801229:	c1 ea 0c             	shr    $0xc,%edx
  80122c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801233:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801239:	89 54 24 10          	mov    %edx,0x10(%esp)
  80123d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801241:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801248:	00 
  801249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801254:	e8 6c f9 ff ff       	call   800bc5 <sys_page_map>
  801259:	89 c3                	mov    %eax,%ebx
  80125b:	85 c0                	test   %eax,%eax
  80125d:	79 25                	jns    801284 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80125f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801263:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80126a:	e8 a9 f9 ff ff       	call   800c18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80126f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801272:	89 44 24 04          	mov    %eax,0x4(%esp)
  801276:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80127d:	e8 96 f9 ff ff       	call   800c18 <sys_page_unmap>
	return r;
  801282:	eb 02                	jmp    801286 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801284:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801286:	89 d8                	mov    %ebx,%eax
  801288:	83 c4 4c             	add    $0x4c,%esp
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5f                   	pop    %edi
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	53                   	push   %ebx
  801294:	83 ec 24             	sub    $0x24,%esp
  801297:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a1:	89 1c 24             	mov    %ebx,(%esp)
  8012a4:	e8 49 fd ff ff       	call   800ff2 <fd_lookup>
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 6d                	js     80131a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b7:	8b 00                	mov    (%eax),%eax
  8012b9:	89 04 24             	mov    %eax,(%esp)
  8012bc:	e8 87 fd ff ff       	call   801048 <dev_lookup>
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 55                	js     80131a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c8:	8b 50 08             	mov    0x8(%eax),%edx
  8012cb:	83 e2 03             	and    $0x3,%edx
  8012ce:	83 fa 01             	cmp    $0x1,%edx
  8012d1:	75 23                	jne    8012f6 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d3:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d8:	8b 40 48             	mov    0x48(%eax),%eax
  8012db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e3:	c7 04 24 ed 28 80 00 	movl   $0x8028ed,(%esp)
  8012ea:	e8 e5 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8012ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f4:	eb 24                	jmp    80131a <read+0x8a>
	}
	if (!dev->dev_read)
  8012f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f9:	8b 52 08             	mov    0x8(%edx),%edx
  8012fc:	85 d2                	test   %edx,%edx
  8012fe:	74 15                	je     801315 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801300:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801303:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80130e:	89 04 24             	mov    %eax,(%esp)
  801311:	ff d2                	call   *%edx
  801313:	eb 05                	jmp    80131a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801315:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80131a:	83 c4 24             	add    $0x24,%esp
  80131d:	5b                   	pop    %ebx
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	57                   	push   %edi
  801324:	56                   	push   %esi
  801325:	53                   	push   %ebx
  801326:	83 ec 1c             	sub    $0x1c,%esp
  801329:	8b 7d 08             	mov    0x8(%ebp),%edi
  80132c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80132f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801334:	eb 23                	jmp    801359 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801336:	89 f0                	mov    %esi,%eax
  801338:	29 d8                	sub    %ebx,%eax
  80133a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801341:	01 d8                	add    %ebx,%eax
  801343:	89 44 24 04          	mov    %eax,0x4(%esp)
  801347:	89 3c 24             	mov    %edi,(%esp)
  80134a:	e8 41 ff ff ff       	call   801290 <read>
		if (m < 0)
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 10                	js     801363 <readn+0x43>
			return m;
		if (m == 0)
  801353:	85 c0                	test   %eax,%eax
  801355:	74 0a                	je     801361 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801357:	01 c3                	add    %eax,%ebx
  801359:	39 f3                	cmp    %esi,%ebx
  80135b:	72 d9                	jb     801336 <readn+0x16>
  80135d:	89 d8                	mov    %ebx,%eax
  80135f:	eb 02                	jmp    801363 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801361:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801363:	83 c4 1c             	add    $0x1c,%esp
  801366:	5b                   	pop    %ebx
  801367:	5e                   	pop    %esi
  801368:	5f                   	pop    %edi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	53                   	push   %ebx
  80136f:	83 ec 24             	sub    $0x24,%esp
  801372:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801375:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801378:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137c:	89 1c 24             	mov    %ebx,(%esp)
  80137f:	e8 6e fc ff ff       	call   800ff2 <fd_lookup>
  801384:	85 c0                	test   %eax,%eax
  801386:	78 68                	js     8013f0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801388:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801392:	8b 00                	mov    (%eax),%eax
  801394:	89 04 24             	mov    %eax,(%esp)
  801397:	e8 ac fc ff ff       	call   801048 <dev_lookup>
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 50                	js     8013f0 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013a7:	75 23                	jne    8013cc <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ae:	8b 40 48             	mov    0x48(%eax),%eax
  8013b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b9:	c7 04 24 09 29 80 00 	movl   $0x802909,(%esp)
  8013c0:	e8 0f ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8013c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ca:	eb 24                	jmp    8013f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d2:	85 d2                	test   %edx,%edx
  8013d4:	74 15                	je     8013eb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013e4:	89 04 24             	mov    %eax,(%esp)
  8013e7:	ff d2                	call   *%edx
  8013e9:	eb 05                	jmp    8013f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013f0:	83 c4 24             	add    $0x24,%esp
  8013f3:	5b                   	pop    %ebx
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801403:	8b 45 08             	mov    0x8(%ebp),%eax
  801406:	89 04 24             	mov    %eax,(%esp)
  801409:	e8 e4 fb ff ff       	call   800ff2 <fd_lookup>
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 0e                	js     801420 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801412:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801415:	8b 55 0c             	mov    0xc(%ebp),%edx
  801418:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80141b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	53                   	push   %ebx
  801426:	83 ec 24             	sub    $0x24,%esp
  801429:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801433:	89 1c 24             	mov    %ebx,(%esp)
  801436:	e8 b7 fb ff ff       	call   800ff2 <fd_lookup>
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 61                	js     8014a0 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801442:	89 44 24 04          	mov    %eax,0x4(%esp)
  801446:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801449:	8b 00                	mov    (%eax),%eax
  80144b:	89 04 24             	mov    %eax,(%esp)
  80144e:	e8 f5 fb ff ff       	call   801048 <dev_lookup>
  801453:	85 c0                	test   %eax,%eax
  801455:	78 49                	js     8014a0 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801457:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80145e:	75 23                	jne    801483 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801460:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801465:	8b 40 48             	mov    0x48(%eax),%eax
  801468:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80146c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801470:	c7 04 24 cc 28 80 00 	movl   $0x8028cc,(%esp)
  801477:	e8 58 ed ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80147c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801481:	eb 1d                	jmp    8014a0 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801483:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801486:	8b 52 18             	mov    0x18(%edx),%edx
  801489:	85 d2                	test   %edx,%edx
  80148b:	74 0e                	je     80149b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80148d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801490:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801494:	89 04 24             	mov    %eax,(%esp)
  801497:	ff d2                	call   *%edx
  801499:	eb 05                	jmp    8014a0 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80149b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014a0:	83 c4 24             	add    $0x24,%esp
  8014a3:	5b                   	pop    %ebx
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 24             	sub    $0x24,%esp
  8014ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	89 04 24             	mov    %eax,(%esp)
  8014bd:	e8 30 fb ff ff       	call   800ff2 <fd_lookup>
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 52                	js     801518 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d0:	8b 00                	mov    (%eax),%eax
  8014d2:	89 04 24             	mov    %eax,(%esp)
  8014d5:	e8 6e fb ff ff       	call   801048 <dev_lookup>
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 3a                	js     801518 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8014de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014e5:	74 2c                	je     801513 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014e7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014ea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014f1:	00 00 00 
	stat->st_isdir = 0;
  8014f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014fb:	00 00 00 
	stat->st_dev = dev;
  8014fe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801508:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80150b:	89 14 24             	mov    %edx,(%esp)
  80150e:	ff 50 14             	call   *0x14(%eax)
  801511:	eb 05                	jmp    801518 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801513:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801518:	83 c4 24             	add    $0x24,%esp
  80151b:	5b                   	pop    %ebx
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    

0080151e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801526:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80152d:	00 
  80152e:	8b 45 08             	mov    0x8(%ebp),%eax
  801531:	89 04 24             	mov    %eax,(%esp)
  801534:	e8 2a 02 00 00       	call   801763 <open>
  801539:	89 c3                	mov    %eax,%ebx
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 1b                	js     80155a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80153f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801542:	89 44 24 04          	mov    %eax,0x4(%esp)
  801546:	89 1c 24             	mov    %ebx,(%esp)
  801549:	e8 58 ff ff ff       	call   8014a6 <fstat>
  80154e:	89 c6                	mov    %eax,%esi
	close(fd);
  801550:	89 1c 24             	mov    %ebx,(%esp)
  801553:	e8 d2 fb ff ff       	call   80112a <close>
	return r;
  801558:	89 f3                	mov    %esi,%ebx
}
  80155a:	89 d8                	mov    %ebx,%eax
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    
	...

00801564 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	83 ec 10             	sub    $0x10,%esp
  80156c:	89 c3                	mov    %eax,%ebx
  80156e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801570:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801577:	75 11                	jne    80158a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801579:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801580:	e8 aa f9 ff ff       	call   800f2f <ipc_find_env>
  801585:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80158a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801591:	00 
  801592:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801599:	00 
  80159a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80159e:	a1 00 40 80 00       	mov    0x804000,%eax
  8015a3:	89 04 24             	mov    %eax,(%esp)
  8015a6:	e8 01 f9 ff ff       	call   800eac <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015b2:	00 
  8015b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015be:	e8 79 f8 ff ff       	call   800e3c <ipc_recv>
}
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015de:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8015ed:	e8 72 ff ff ff       	call   801564 <fsipc>
}
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801600:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801605:	ba 00 00 00 00       	mov    $0x0,%edx
  80160a:	b8 06 00 00 00       	mov    $0x6,%eax
  80160f:	e8 50 ff ff ff       	call   801564 <fsipc>
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	53                   	push   %ebx
  80161a:	83 ec 14             	sub    $0x14,%esp
  80161d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	8b 40 0c             	mov    0xc(%eax),%eax
  801626:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80162b:	ba 00 00 00 00       	mov    $0x0,%edx
  801630:	b8 05 00 00 00       	mov    $0x5,%eax
  801635:	e8 2a ff ff ff       	call   801564 <fsipc>
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 2b                	js     801669 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80163e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801645:	00 
  801646:	89 1c 24             	mov    %ebx,(%esp)
  801649:	e8 31 f1 ff ff       	call   80077f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80164e:	a1 80 50 80 00       	mov    0x805080,%eax
  801653:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801659:	a1 84 50 80 00       	mov    0x805084,%eax
  80165e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801664:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801669:	83 c4 14             	add    $0x14,%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 18             	sub    $0x18,%esp
  801675:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801678:	8b 55 08             	mov    0x8(%ebp),%edx
  80167b:	8b 52 0c             	mov    0xc(%edx),%edx
  80167e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801684:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801689:	89 c2                	mov    %eax,%edx
  80168b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801690:	76 05                	jbe    801697 <devfile_write+0x28>
  801692:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801697:	89 54 24 08          	mov    %edx,0x8(%esp)
  80169b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8016a9:	e8 b4 f2 ff ff       	call   800962 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8016ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8016b8:	e8 a7 fe ff ff       	call   801564 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 10             	sub    $0x10,%esp
  8016c7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016d5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016db:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8016e5:	e8 7a fe ff ff       	call   801564 <fsipc>
  8016ea:	89 c3                	mov    %eax,%ebx
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 6a                	js     80175a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016f0:	39 c6                	cmp    %eax,%esi
  8016f2:	73 24                	jae    801718 <devfile_read+0x59>
  8016f4:	c7 44 24 0c 3c 29 80 	movl   $0x80293c,0xc(%esp)
  8016fb:	00 
  8016fc:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  801703:	00 
  801704:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80170b:	00 
  80170c:	c7 04 24 58 29 80 00 	movl   $0x802958,(%esp)
  801713:	e8 00 0b 00 00       	call   802218 <_panic>
	assert(r <= PGSIZE);
  801718:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80171d:	7e 24                	jle    801743 <devfile_read+0x84>
  80171f:	c7 44 24 0c 63 29 80 	movl   $0x802963,0xc(%esp)
  801726:	00 
  801727:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  80172e:	00 
  80172f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801736:	00 
  801737:	c7 04 24 58 29 80 00 	movl   $0x802958,(%esp)
  80173e:	e8 d5 0a 00 00       	call   802218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801743:	89 44 24 08          	mov    %eax,0x8(%esp)
  801747:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80174e:	00 
  80174f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	e8 9e f1 ff ff       	call   8008f8 <memmove>
	return r;
}
  80175a:	89 d8                	mov    %ebx,%eax
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	83 ec 20             	sub    $0x20,%esp
  80176b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80176e:	89 34 24             	mov    %esi,(%esp)
  801771:	e8 d6 ef ff ff       	call   80074c <strlen>
  801776:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80177b:	7f 60                	jg     8017dd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80177d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801780:	89 04 24             	mov    %eax,(%esp)
  801783:	e8 17 f8 ff ff       	call   800f9f <fd_alloc>
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 54                	js     8017e2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80178e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801792:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801799:	e8 e1 ef ff ff       	call   80077f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80179e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ae:	e8 b1 fd ff ff       	call   801564 <fsipc>
  8017b3:	89 c3                	mov    %eax,%ebx
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	79 15                	jns    8017ce <open+0x6b>
		fd_close(fd, 0);
  8017b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017c0:	00 
  8017c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c4:	89 04 24             	mov    %eax,(%esp)
  8017c7:	e8 d6 f8 ff ff       	call   8010a2 <fd_close>
		return r;
  8017cc:	eb 14                	jmp    8017e2 <open+0x7f>
	}

	return fd2num(fd);
  8017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d1:	89 04 24             	mov    %eax,(%esp)
  8017d4:	e8 9b f7 ff ff       	call   800f74 <fd2num>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	eb 05                	jmp    8017e2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017dd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017e2:	89 d8                	mov    %ebx,%eax
  8017e4:	83 c4 20             	add    $0x20,%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8017fb:	e8 64 fd ff ff       	call   801564 <fsipc>
}
  801800:	c9                   	leave  
  801801:	c3                   	ret    
	...

00801804 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  80180a:	c7 44 24 04 6f 29 80 	movl   $0x80296f,0x4(%esp)
  801811:	00 
  801812:	8b 45 0c             	mov    0xc(%ebp),%eax
  801815:	89 04 24             	mov    %eax,(%esp)
  801818:	e8 62 ef ff ff       	call   80077f <strcpy>
	return 0;
}
  80181d:	b8 00 00 00 00       	mov    $0x0,%eax
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	53                   	push   %ebx
  801828:	83 ec 14             	sub    $0x14,%esp
  80182b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80182e:	89 1c 24             	mov    %ebx,(%esp)
  801831:	e8 3a 0a 00 00       	call   802270 <pageref>
  801836:	83 f8 01             	cmp    $0x1,%eax
  801839:	75 0d                	jne    801848 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80183b:	8b 43 0c             	mov    0xc(%ebx),%eax
  80183e:	89 04 24             	mov    %eax,(%esp)
  801841:	e8 1f 03 00 00       	call   801b65 <nsipc_close>
  801846:	eb 05                	jmp    80184d <devsock_close+0x29>
	else
		return 0;
  801848:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184d:	83 c4 14             	add    $0x14,%esp
  801850:	5b                   	pop    %ebx
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801859:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801860:	00 
  801861:	8b 45 10             	mov    0x10(%ebp),%eax
  801864:	89 44 24 08          	mov    %eax,0x8(%esp)
  801868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	8b 40 0c             	mov    0xc(%eax),%eax
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 e3 03 00 00       	call   801c60 <nsipc_send>
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801885:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80188c:	00 
  80188d:	8b 45 10             	mov    0x10(%ebp),%eax
  801890:	89 44 24 08          	mov    %eax,0x8(%esp)
  801894:	8b 45 0c             	mov    0xc(%ebp),%eax
  801897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a1:	89 04 24             	mov    %eax,(%esp)
  8018a4:	e8 37 03 00 00       	call   801be0 <nsipc_recv>
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 20             	sub    $0x20,%esp
  8018b3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b8:	89 04 24             	mov    %eax,(%esp)
  8018bb:	e8 df f6 ff ff       	call   800f9f <fd_alloc>
  8018c0:	89 c3                	mov    %eax,%ebx
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 21                	js     8018e7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018c6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018cd:	00 
  8018ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018dc:	e8 90 f2 ff ff       	call   800b71 <sys_page_alloc>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	79 0a                	jns    8018f1 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8018e7:	89 34 24             	mov    %esi,(%esp)
  8018ea:	e8 76 02 00 00       	call   801b65 <nsipc_close>
		return r;
  8018ef:	eb 22                	jmp    801913 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8018f1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fa:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801906:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801909:	89 04 24             	mov    %eax,(%esp)
  80190c:	e8 63 f6 ff ff       	call   800f74 <fd2num>
  801911:	89 c3                	mov    %eax,%ebx
}
  801913:	89 d8                	mov    %ebx,%eax
  801915:	83 c4 20             	add    $0x20,%esp
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801922:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801925:	89 54 24 04          	mov    %edx,0x4(%esp)
  801929:	89 04 24             	mov    %eax,(%esp)
  80192c:	e8 c1 f6 ff ff       	call   800ff2 <fd_lookup>
  801931:	85 c0                	test   %eax,%eax
  801933:	78 17                	js     80194c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801935:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801938:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80193e:	39 10                	cmp    %edx,(%eax)
  801940:	75 05                	jne    801947 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801942:	8b 40 0c             	mov    0xc(%eax),%eax
  801945:	eb 05                	jmp    80194c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801947:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	e8 c0 ff ff ff       	call   80191c <fd2sockid>
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 1f                	js     80197f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801960:	8b 55 10             	mov    0x10(%ebp),%edx
  801963:	89 54 24 08          	mov    %edx,0x8(%esp)
  801967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80196a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80196e:	89 04 24             	mov    %eax,(%esp)
  801971:	e8 38 01 00 00       	call   801aae <nsipc_accept>
  801976:	85 c0                	test   %eax,%eax
  801978:	78 05                	js     80197f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80197a:	e8 2c ff ff ff       	call   8018ab <alloc_sockfd>
}
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801987:	8b 45 08             	mov    0x8(%ebp),%eax
  80198a:	e8 8d ff ff ff       	call   80191c <fd2sockid>
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 16                	js     8019a9 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801993:	8b 55 10             	mov    0x10(%ebp),%edx
  801996:	89 54 24 08          	mov    %edx,0x8(%esp)
  80199a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80199d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019a1:	89 04 24             	mov    %eax,(%esp)
  8019a4:	e8 5b 01 00 00       	call   801b04 <nsipc_bind>
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <shutdown>:

int
shutdown(int s, int how)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b4:	e8 63 ff ff ff       	call   80191c <fd2sockid>
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 0f                	js     8019cc <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019c4:	89 04 24             	mov    %eax,(%esp)
  8019c7:	e8 77 01 00 00       	call   801b43 <nsipc_shutdown>
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	e8 40 ff ff ff       	call   80191c <fd2sockid>
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	78 16                	js     8019f6 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8019e0:	8b 55 10             	mov    0x10(%ebp),%edx
  8019e3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	e8 89 01 00 00       	call   801b7f <nsipc_connect>
}
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <listen>:

int
listen(int s, int backlog)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	e8 16 ff ff ff       	call   80191c <fd2sockid>
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 0f                	js     801a19 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a11:	89 04 24             	mov    %eax,(%esp)
  801a14:	e8 a5 01 00 00       	call   801bbe <nsipc_listen>
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a21:	8b 45 10             	mov    0x10(%ebp),%eax
  801a24:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	89 04 24             	mov    %eax,(%esp)
  801a35:	e8 99 02 00 00       	call   801cd3 <nsipc_socket>
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	78 05                	js     801a43 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801a3e:	e8 68 fe ff ff       	call   8018ab <alloc_sockfd>
}
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    
  801a45:	00 00                	add    %al,(%eax)
	...

00801a48 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 14             	sub    $0x14,%esp
  801a4f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a51:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a58:	75 11                	jne    801a6b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a5a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801a61:	e8 c9 f4 ff ff       	call   800f2f <ipc_find_env>
  801a66:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a6b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a72:	00 
  801a73:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a7a:	00 
  801a7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a84:	89 04 24             	mov    %eax,(%esp)
  801a87:	e8 20 f4 ff ff       	call   800eac <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a8c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a93:	00 
  801a94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a9b:	00 
  801a9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aa3:	e8 94 f3 ff ff       	call   800e3c <ipc_recv>
}
  801aa8:	83 c4 14             	add    $0x14,%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 10             	sub    $0x10,%esp
  801ab6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ac1:	8b 06                	mov    (%esi),%eax
  801ac3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ac8:	b8 01 00 00 00       	mov    $0x1,%eax
  801acd:	e8 76 ff ff ff       	call   801a48 <nsipc>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 23                	js     801afb <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ad8:	a1 10 60 80 00       	mov    0x806010,%eax
  801add:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae1:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ae8:	00 
  801ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aec:	89 04 24             	mov    %eax,(%esp)
  801aef:	e8 04 ee ff ff       	call   8008f8 <memmove>
		*addrlen = ret->ret_addrlen;
  801af4:	a1 10 60 80 00       	mov    0x806010,%eax
  801af9:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801afb:	89 d8                	mov    %ebx,%eax
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	5d                   	pop    %ebp
  801b03:	c3                   	ret    

00801b04 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	53                   	push   %ebx
  801b08:	83 ec 14             	sub    $0x14,%esp
  801b0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b16:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b21:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801b28:	e8 cb ed ff ff       	call   8008f8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b2d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b33:	b8 02 00 00 00       	mov    $0x2,%eax
  801b38:	e8 0b ff ff ff       	call   801a48 <nsipc>
}
  801b3d:	83 c4 14             	add    $0x14,%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b54:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b59:	b8 03 00 00 00       	mov    $0x3,%eax
  801b5e:	e8 e5 fe ff ff       	call   801a48 <nsipc>
}
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <nsipc_close>:

int
nsipc_close(int s)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b73:	b8 04 00 00 00       	mov    $0x4,%eax
  801b78:	e8 cb fe ff ff       	call   801a48 <nsipc>
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	53                   	push   %ebx
  801b83:	83 ec 14             	sub    $0x14,%esp
  801b86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b89:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ba3:	e8 50 ed ff ff       	call   8008f8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ba8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bae:	b8 05 00 00 00       	mov    $0x5,%eax
  801bb3:	e8 90 fe ff ff       	call   801a48 <nsipc>
}
  801bb8:	83 c4 14             	add    $0x14,%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bd4:	b8 06 00 00 00       	mov    $0x6,%eax
  801bd9:	e8 6a fe ff ff       	call   801a48 <nsipc>
}
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 10             	sub    $0x10,%esp
  801be8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bf3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bf9:	8b 45 14             	mov    0x14(%ebp),%eax
  801bfc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c01:	b8 07 00 00 00       	mov    $0x7,%eax
  801c06:	e8 3d fe ff ff       	call   801a48 <nsipc>
  801c0b:	89 c3                	mov    %eax,%ebx
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	78 46                	js     801c57 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801c11:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c16:	7f 04                	jg     801c1c <nsipc_recv+0x3c>
  801c18:	39 c6                	cmp    %eax,%esi
  801c1a:	7d 24                	jge    801c40 <nsipc_recv+0x60>
  801c1c:	c7 44 24 0c 7b 29 80 	movl   $0x80297b,0xc(%esp)
  801c23:	00 
  801c24:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  801c2b:	00 
  801c2c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801c33:	00 
  801c34:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  801c3b:	e8 d8 05 00 00       	call   802218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c44:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c4b:	00 
  801c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4f:	89 04 24             	mov    %eax,(%esp)
  801c52:	e8 a1 ec ff ff       	call   8008f8 <memmove>
	}

	return r;
}
  801c57:	89 d8                	mov    %ebx,%eax
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	5b                   	pop    %ebx
  801c5d:	5e                   	pop    %esi
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	53                   	push   %ebx
  801c64:	83 ec 14             	sub    $0x14,%esp
  801c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c72:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c78:	7e 24                	jle    801c9e <nsipc_send+0x3e>
  801c7a:	c7 44 24 0c 9c 29 80 	movl   $0x80299c,0xc(%esp)
  801c81:	00 
  801c82:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  801c89:	00 
  801c8a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801c91:	00 
  801c92:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  801c99:	e8 7a 05 00 00       	call   802218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca9:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801cb0:	e8 43 ec ff ff       	call   8008f8 <memmove>
	nsipcbuf.send.req_size = size;
  801cb5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cbb:	8b 45 14             	mov    0x14(%ebp),%eax
  801cbe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cc3:	b8 08 00 00 00       	mov    $0x8,%eax
  801cc8:	e8 7b fd ff ff       	call   801a48 <nsipc>
}
  801ccd:	83 c4 14             	add    $0x14,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ce9:	8b 45 10             	mov    0x10(%ebp),%eax
  801cec:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cf1:	b8 09 00 00 00       	mov    $0x9,%eax
  801cf6:	e8 4d fd ff ff       	call   801a48 <nsipc>
}
  801cfb:	c9                   	leave  
  801cfc:	c3                   	ret    
  801cfd:	00 00                	add    %al,(%eax)
	...

00801d00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	83 ec 10             	sub    $0x10,%esp
  801d08:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0e:	89 04 24             	mov    %eax,(%esp)
  801d11:	e8 6e f2 ff ff       	call   800f84 <fd2data>
  801d16:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d18:	c7 44 24 04 a8 29 80 	movl   $0x8029a8,0x4(%esp)
  801d1f:	00 
  801d20:	89 34 24             	mov    %esi,(%esp)
  801d23:	e8 57 ea ff ff       	call   80077f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d28:	8b 43 04             	mov    0x4(%ebx),%eax
  801d2b:	2b 03                	sub    (%ebx),%eax
  801d2d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801d33:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801d3a:	00 00 00 
	stat->st_dev = &devpipe;
  801d3d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801d44:	30 80 00 
	return 0;
}
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	53                   	push   %ebx
  801d57:	83 ec 14             	sub    $0x14,%esp
  801d5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d68:	e8 ab ee ff ff       	call   800c18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d6d:	89 1c 24             	mov    %ebx,(%esp)
  801d70:	e8 0f f2 ff ff       	call   800f84 <fd2data>
  801d75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d80:	e8 93 ee ff ff       	call   800c18 <sys_page_unmap>
}
  801d85:	83 c4 14             	add    $0x14,%esp
  801d88:	5b                   	pop    %ebx
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	57                   	push   %edi
  801d8f:	56                   	push   %esi
  801d90:	53                   	push   %ebx
  801d91:	83 ec 2c             	sub    $0x2c,%esp
  801d94:	89 c7                	mov    %eax,%edi
  801d96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d99:	a1 08 40 80 00       	mov    0x804008,%eax
  801d9e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801da1:	89 3c 24             	mov    %edi,(%esp)
  801da4:	e8 c7 04 00 00       	call   802270 <pageref>
  801da9:	89 c6                	mov    %eax,%esi
  801dab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dae:	89 04 24             	mov    %eax,(%esp)
  801db1:	e8 ba 04 00 00       	call   802270 <pageref>
  801db6:	39 c6                	cmp    %eax,%esi
  801db8:	0f 94 c0             	sete   %al
  801dbb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801dbe:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801dc4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dc7:	39 cb                	cmp    %ecx,%ebx
  801dc9:	75 08                	jne    801dd3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801dcb:	83 c4 2c             	add    $0x2c,%esp
  801dce:	5b                   	pop    %ebx
  801dcf:	5e                   	pop    %esi
  801dd0:	5f                   	pop    %edi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801dd3:	83 f8 01             	cmp    $0x1,%eax
  801dd6:	75 c1                	jne    801d99 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dd8:	8b 42 58             	mov    0x58(%edx),%eax
  801ddb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801de2:	00 
  801de3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801de7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801deb:	c7 04 24 af 29 80 00 	movl   $0x8029af,(%esp)
  801df2:	e8 dd e3 ff ff       	call   8001d4 <cprintf>
  801df7:	eb a0                	jmp    801d99 <_pipeisclosed+0xe>

00801df9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	57                   	push   %edi
  801dfd:	56                   	push   %esi
  801dfe:	53                   	push   %ebx
  801dff:	83 ec 1c             	sub    $0x1c,%esp
  801e02:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e05:	89 34 24             	mov    %esi,(%esp)
  801e08:	e8 77 f1 ff ff       	call   800f84 <fd2data>
  801e0d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e14:	eb 3c                	jmp    801e52 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e16:	89 da                	mov    %ebx,%edx
  801e18:	89 f0                	mov    %esi,%eax
  801e1a:	e8 6c ff ff ff       	call   801d8b <_pipeisclosed>
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	75 38                	jne    801e5b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e23:	e8 2a ed ff ff       	call   800b52 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e28:	8b 43 04             	mov    0x4(%ebx),%eax
  801e2b:	8b 13                	mov    (%ebx),%edx
  801e2d:	83 c2 20             	add    $0x20,%edx
  801e30:	39 d0                	cmp    %edx,%eax
  801e32:	73 e2                	jae    801e16 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e37:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801e3a:	89 c2                	mov    %eax,%edx
  801e3c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e42:	79 05                	jns    801e49 <devpipe_write+0x50>
  801e44:	4a                   	dec    %edx
  801e45:	83 ca e0             	or     $0xffffffe0,%edx
  801e48:	42                   	inc    %edx
  801e49:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e4d:	40                   	inc    %eax
  801e4e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e51:	47                   	inc    %edi
  801e52:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e55:	75 d1                	jne    801e28 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e57:	89 f8                	mov    %edi,%eax
  801e59:	eb 05                	jmp    801e60 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e60:	83 c4 1c             	add    $0x1c,%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5f                   	pop    %edi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	57                   	push   %edi
  801e6c:	56                   	push   %esi
  801e6d:	53                   	push   %ebx
  801e6e:	83 ec 1c             	sub    $0x1c,%esp
  801e71:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e74:	89 3c 24             	mov    %edi,(%esp)
  801e77:	e8 08 f1 ff ff       	call   800f84 <fd2data>
  801e7c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e7e:	be 00 00 00 00       	mov    $0x0,%esi
  801e83:	eb 3a                	jmp    801ebf <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e85:	85 f6                	test   %esi,%esi
  801e87:	74 04                	je     801e8d <devpipe_read+0x25>
				return i;
  801e89:	89 f0                	mov    %esi,%eax
  801e8b:	eb 40                	jmp    801ecd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e8d:	89 da                	mov    %ebx,%edx
  801e8f:	89 f8                	mov    %edi,%eax
  801e91:	e8 f5 fe ff ff       	call   801d8b <_pipeisclosed>
  801e96:	85 c0                	test   %eax,%eax
  801e98:	75 2e                	jne    801ec8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e9a:	e8 b3 ec ff ff       	call   800b52 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e9f:	8b 03                	mov    (%ebx),%eax
  801ea1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ea4:	74 df                	je     801e85 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ea6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801eab:	79 05                	jns    801eb2 <devpipe_read+0x4a>
  801ead:	48                   	dec    %eax
  801eae:	83 c8 e0             	or     $0xffffffe0,%eax
  801eb1:	40                   	inc    %eax
  801eb2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801eb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eb9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ebc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ebe:	46                   	inc    %esi
  801ebf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec2:	75 db                	jne    801e9f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ec4:	89 f0                	mov    %esi,%eax
  801ec6:	eb 05                	jmp    801ecd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ecd:	83 c4 1c             	add    $0x1c,%esp
  801ed0:	5b                   	pop    %ebx
  801ed1:	5e                   	pop    %esi
  801ed2:	5f                   	pop    %edi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	57                   	push   %edi
  801ed9:	56                   	push   %esi
  801eda:	53                   	push   %ebx
  801edb:	83 ec 3c             	sub    $0x3c,%esp
  801ede:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ee1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ee4:	89 04 24             	mov    %eax,(%esp)
  801ee7:	e8 b3 f0 ff ff       	call   800f9f <fd_alloc>
  801eec:	89 c3                	mov    %eax,%ebx
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	0f 88 45 01 00 00    	js     80203b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801efd:	00 
  801efe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0c:	e8 60 ec ff ff       	call   800b71 <sys_page_alloc>
  801f11:	89 c3                	mov    %eax,%ebx
  801f13:	85 c0                	test   %eax,%eax
  801f15:	0f 88 20 01 00 00    	js     80203b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f1b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801f1e:	89 04 24             	mov    %eax,(%esp)
  801f21:	e8 79 f0 ff ff       	call   800f9f <fd_alloc>
  801f26:	89 c3                	mov    %eax,%ebx
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	0f 88 f8 00 00 00    	js     802028 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f30:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f37:	00 
  801f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f46:	e8 26 ec ff ff       	call   800b71 <sys_page_alloc>
  801f4b:	89 c3                	mov    %eax,%ebx
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	0f 88 d3 00 00 00    	js     802028 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f58:	89 04 24             	mov    %eax,(%esp)
  801f5b:	e8 24 f0 ff ff       	call   800f84 <fd2data>
  801f60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f62:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f69:	00 
  801f6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f75:	e8 f7 eb ff ff       	call   800b71 <sys_page_alloc>
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	0f 88 91 00 00 00    	js     802015 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f87:	89 04 24             	mov    %eax,(%esp)
  801f8a:	e8 f5 ef ff ff       	call   800f84 <fd2data>
  801f8f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f96:	00 
  801f97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fa2:	00 
  801fa3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fa7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fae:	e8 12 ec ff ff       	call   800bc5 <sys_page_map>
  801fb3:	89 c3                	mov    %eax,%ebx
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	78 4c                	js     802005 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fb9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fc2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fc7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fd7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fdc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fe3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fe6:	89 04 24             	mov    %eax,(%esp)
  801fe9:	e8 86 ef ff ff       	call   800f74 <fd2num>
  801fee:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ff0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ff3:	89 04 24             	mov    %eax,(%esp)
  801ff6:	e8 79 ef ff ff       	call   800f74 <fd2num>
  801ffb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
  802003:	eb 36                	jmp    80203b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802005:	89 74 24 04          	mov    %esi,0x4(%esp)
  802009:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802010:	e8 03 ec ff ff       	call   800c18 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802015:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802018:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802023:	e8 f0 eb ff ff       	call   800c18 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802028:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80202b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802036:	e8 dd eb ff ff       	call   800c18 <sys_page_unmap>
    err:
	return r;
}
  80203b:	89 d8                	mov    %ebx,%eax
  80203d:	83 c4 3c             	add    $0x3c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802052:	8b 45 08             	mov    0x8(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 95 ef ff ff       	call   800ff2 <fd_lookup>
  80205d:	85 c0                	test   %eax,%eax
  80205f:	78 15                	js     802076 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802064:	89 04 24             	mov    %eax,(%esp)
  802067:	e8 18 ef ff ff       	call   800f84 <fd2data>
	return _pipeisclosed(fd, p);
  80206c:	89 c2                	mov    %eax,%edx
  80206e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802071:	e8 15 fd ff ff       	call   801d8b <_pipeisclosed>
}
  802076:	c9                   	leave  
  802077:	c3                   	ret    

00802078 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    

00802082 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802088:	c7 44 24 04 c7 29 80 	movl   $0x8029c7,0x4(%esp)
  80208f:	00 
  802090:	8b 45 0c             	mov    0xc(%ebp),%eax
  802093:	89 04 24             	mov    %eax,(%esp)
  802096:	e8 e4 e6 ff ff       	call   80077f <strcpy>
	return 0;
}
  80209b:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    

008020a2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	57                   	push   %edi
  8020a6:	56                   	push   %esi
  8020a7:	53                   	push   %ebx
  8020a8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020ae:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020b3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b9:	eb 30                	jmp    8020eb <devcons_write+0x49>
		m = n - tot;
  8020bb:	8b 75 10             	mov    0x10(%ebp),%esi
  8020be:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8020c0:	83 fe 7f             	cmp    $0x7f,%esi
  8020c3:	76 05                	jbe    8020ca <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8020c5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020ca:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020ce:	03 45 0c             	add    0xc(%ebp),%eax
  8020d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d5:	89 3c 24             	mov    %edi,(%esp)
  8020d8:	e8 1b e8 ff ff       	call   8008f8 <memmove>
		sys_cputs(buf, m);
  8020dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020e1:	89 3c 24             	mov    %edi,(%esp)
  8020e4:	e8 bb e9 ff ff       	call   800aa4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020e9:	01 f3                	add    %esi,%ebx
  8020eb:	89 d8                	mov    %ebx,%eax
  8020ed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020f0:	72 c9                	jb     8020bb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020f2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020f8:	5b                   	pop    %ebx
  8020f9:	5e                   	pop    %esi
  8020fa:	5f                   	pop    %edi
  8020fb:	5d                   	pop    %ebp
  8020fc:	c3                   	ret    

008020fd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020fd:	55                   	push   %ebp
  8020fe:	89 e5                	mov    %esp,%ebp
  802100:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802103:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802107:	75 07                	jne    802110 <devcons_read+0x13>
  802109:	eb 25                	jmp    802130 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80210b:	e8 42 ea ff ff       	call   800b52 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802110:	e8 ad e9 ff ff       	call   800ac2 <sys_cgetc>
  802115:	85 c0                	test   %eax,%eax
  802117:	74 f2                	je     80210b <devcons_read+0xe>
  802119:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80211b:	85 c0                	test   %eax,%eax
  80211d:	78 1d                	js     80213c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80211f:	83 f8 04             	cmp    $0x4,%eax
  802122:	74 13                	je     802137 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802124:	8b 45 0c             	mov    0xc(%ebp),%eax
  802127:	88 10                	mov    %dl,(%eax)
	return 1;
  802129:	b8 01 00 00 00       	mov    $0x1,%eax
  80212e:	eb 0c                	jmp    80213c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802130:	b8 00 00 00 00       	mov    $0x0,%eax
  802135:	eb 05                	jmp    80213c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802144:	8b 45 08             	mov    0x8(%ebp),%eax
  802147:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80214a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802151:	00 
  802152:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802155:	89 04 24             	mov    %eax,(%esp)
  802158:	e8 47 e9 ff ff       	call   800aa4 <sys_cputs>
}
  80215d:	c9                   	leave  
  80215e:	c3                   	ret    

0080215f <getchar>:

int
getchar(void)
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802165:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80216c:	00 
  80216d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802170:	89 44 24 04          	mov    %eax,0x4(%esp)
  802174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80217b:	e8 10 f1 ff ff       	call   801290 <read>
	if (r < 0)
  802180:	85 c0                	test   %eax,%eax
  802182:	78 0f                	js     802193 <getchar+0x34>
		return r;
	if (r < 1)
  802184:	85 c0                	test   %eax,%eax
  802186:	7e 06                	jle    80218e <getchar+0x2f>
		return -E_EOF;
	return c;
  802188:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80218c:	eb 05                	jmp    802193 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80218e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802193:	c9                   	leave  
  802194:	c3                   	ret    

00802195 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
  802198:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80219e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a5:	89 04 24             	mov    %eax,(%esp)
  8021a8:	e8 45 ee ff ff       	call   800ff2 <fd_lookup>
  8021ad:	85 c0                	test   %eax,%eax
  8021af:	78 11                	js     8021c2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021ba:	39 10                	cmp    %edx,(%eax)
  8021bc:	0f 94 c0             	sete   %al
  8021bf:	0f b6 c0             	movzbl %al,%eax
}
  8021c2:	c9                   	leave  
  8021c3:	c3                   	ret    

008021c4 <opencons>:

int
opencons(void)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021cd:	89 04 24             	mov    %eax,(%esp)
  8021d0:	e8 ca ed ff ff       	call   800f9f <fd_alloc>
  8021d5:	85 c0                	test   %eax,%eax
  8021d7:	78 3c                	js     802215 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021e0:	00 
  8021e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ef:	e8 7d e9 ff ff       	call   800b71 <sys_page_alloc>
  8021f4:	85 c0                	test   %eax,%eax
  8021f6:	78 1d                	js     802215 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021f8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802201:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802203:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802206:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80220d:	89 04 24             	mov    %eax,(%esp)
  802210:	e8 5f ed ff ff       	call   800f74 <fd2num>
}
  802215:	c9                   	leave  
  802216:	c3                   	ret    
	...

00802218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802218:	55                   	push   %ebp
  802219:	89 e5                	mov    %esp,%ebp
  80221b:	56                   	push   %esi
  80221c:	53                   	push   %ebx
  80221d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802220:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802223:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802229:	e8 05 e9 ff ff       	call   800b33 <sys_getenvid>
  80222e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802231:	89 54 24 10          	mov    %edx,0x10(%esp)
  802235:	8b 55 08             	mov    0x8(%ebp),%edx
  802238:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80223c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802240:	89 44 24 04          	mov    %eax,0x4(%esp)
  802244:	c7 04 24 d4 29 80 00 	movl   $0x8029d4,(%esp)
  80224b:	e8 84 df ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802250:	89 74 24 04          	mov    %esi,0x4(%esp)
  802254:	8b 45 10             	mov    0x10(%ebp),%eax
  802257:	89 04 24             	mov    %eax,(%esp)
  80225a:	e8 14 df ff ff       	call   800173 <vcprintf>
	cprintf("\n");
  80225f:	c7 04 24 c0 29 80 00 	movl   $0x8029c0,(%esp)
  802266:	e8 69 df ff ff       	call   8001d4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80226b:	cc                   	int3   
  80226c:	eb fd                	jmp    80226b <_panic+0x53>
	...

00802270 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802276:	89 c2                	mov    %eax,%edx
  802278:	c1 ea 16             	shr    $0x16,%edx
  80227b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802282:	f6 c2 01             	test   $0x1,%dl
  802285:	74 1e                	je     8022a5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802287:	c1 e8 0c             	shr    $0xc,%eax
  80228a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802291:	a8 01                	test   $0x1,%al
  802293:	74 17                	je     8022ac <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802295:	c1 e8 0c             	shr    $0xc,%eax
  802298:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80229f:	ef 
  8022a0:	0f b7 c0             	movzwl %ax,%eax
  8022a3:	eb 0c                	jmp    8022b1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022aa:	eb 05                	jmp    8022b1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022ac:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    
	...

008022b4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8022b4:	55                   	push   %ebp
  8022b5:	57                   	push   %edi
  8022b6:	56                   	push   %esi
  8022b7:	83 ec 10             	sub    $0x10,%esp
  8022ba:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022be:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8022ca:	89 cd                	mov    %ecx,%ebp
  8022cc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022d0:	85 c0                	test   %eax,%eax
  8022d2:	75 2c                	jne    802300 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8022d4:	39 f9                	cmp    %edi,%ecx
  8022d6:	77 68                	ja     802340 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022d8:	85 c9                	test   %ecx,%ecx
  8022da:	75 0b                	jne    8022e7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e1:	31 d2                	xor    %edx,%edx
  8022e3:	f7 f1                	div    %ecx
  8022e5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022e7:	31 d2                	xor    %edx,%edx
  8022e9:	89 f8                	mov    %edi,%eax
  8022eb:	f7 f1                	div    %ecx
  8022ed:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022ef:	89 f0                	mov    %esi,%eax
  8022f1:	f7 f1                	div    %ecx
  8022f3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022f5:	89 f0                	mov    %esi,%eax
  8022f7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022f9:	83 c4 10             	add    $0x10,%esp
  8022fc:	5e                   	pop    %esi
  8022fd:	5f                   	pop    %edi
  8022fe:	5d                   	pop    %ebp
  8022ff:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802300:	39 f8                	cmp    %edi,%eax
  802302:	77 2c                	ja     802330 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802304:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802307:	83 f6 1f             	xor    $0x1f,%esi
  80230a:	75 4c                	jne    802358 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80230c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80230e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802313:	72 0a                	jb     80231f <__udivdi3+0x6b>
  802315:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802319:	0f 87 ad 00 00 00    	ja     8023cc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80231f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802324:	89 f0                	mov    %esi,%eax
  802326:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802328:	83 c4 10             	add    $0x10,%esp
  80232b:	5e                   	pop    %esi
  80232c:	5f                   	pop    %edi
  80232d:	5d                   	pop    %ebp
  80232e:	c3                   	ret    
  80232f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802330:	31 ff                	xor    %edi,%edi
  802332:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802334:	89 f0                	mov    %esi,%eax
  802336:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802338:	83 c4 10             	add    $0x10,%esp
  80233b:	5e                   	pop    %esi
  80233c:	5f                   	pop    %edi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    
  80233f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802340:	89 fa                	mov    %edi,%edx
  802342:	89 f0                	mov    %esi,%eax
  802344:	f7 f1                	div    %ecx
  802346:	89 c6                	mov    %eax,%esi
  802348:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80234a:	89 f0                	mov    %esi,%eax
  80234c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80234e:	83 c4 10             	add    $0x10,%esp
  802351:	5e                   	pop    %esi
  802352:	5f                   	pop    %edi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    
  802355:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802358:	89 f1                	mov    %esi,%ecx
  80235a:	d3 e0                	shl    %cl,%eax
  80235c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802360:	b8 20 00 00 00       	mov    $0x20,%eax
  802365:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802367:	89 ea                	mov    %ebp,%edx
  802369:	88 c1                	mov    %al,%cl
  80236b:	d3 ea                	shr    %cl,%edx
  80236d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802371:	09 ca                	or     %ecx,%edx
  802373:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802377:	89 f1                	mov    %esi,%ecx
  802379:	d3 e5                	shl    %cl,%ebp
  80237b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80237f:	89 fd                	mov    %edi,%ebp
  802381:	88 c1                	mov    %al,%cl
  802383:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802385:	89 fa                	mov    %edi,%edx
  802387:	89 f1                	mov    %esi,%ecx
  802389:	d3 e2                	shl    %cl,%edx
  80238b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80238f:	88 c1                	mov    %al,%cl
  802391:	d3 ef                	shr    %cl,%edi
  802393:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802395:	89 f8                	mov    %edi,%eax
  802397:	89 ea                	mov    %ebp,%edx
  802399:	f7 74 24 08          	divl   0x8(%esp)
  80239d:	89 d1                	mov    %edx,%ecx
  80239f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8023a1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023a5:	39 d1                	cmp    %edx,%ecx
  8023a7:	72 17                	jb     8023c0 <__udivdi3+0x10c>
  8023a9:	74 09                	je     8023b4 <__udivdi3+0x100>
  8023ab:	89 fe                	mov    %edi,%esi
  8023ad:	31 ff                	xor    %edi,%edi
  8023af:	e9 41 ff ff ff       	jmp    8022f5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8023b4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023b8:	89 f1                	mov    %esi,%ecx
  8023ba:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023bc:	39 c2                	cmp    %eax,%edx
  8023be:	73 eb                	jae    8023ab <__udivdi3+0xf7>
		{
		  q0--;
  8023c0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023c3:	31 ff                	xor    %edi,%edi
  8023c5:	e9 2b ff ff ff       	jmp    8022f5 <__udivdi3+0x41>
  8023ca:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023cc:	31 f6                	xor    %esi,%esi
  8023ce:	e9 22 ff ff ff       	jmp    8022f5 <__udivdi3+0x41>
	...

008023d4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8023d4:	55                   	push   %ebp
  8023d5:	57                   	push   %edi
  8023d6:	56                   	push   %esi
  8023d7:	83 ec 20             	sub    $0x20,%esp
  8023da:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023de:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023e2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023e6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8023ea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ee:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8023f2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8023f4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023f6:	85 ed                	test   %ebp,%ebp
  8023f8:	75 16                	jne    802410 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8023fa:	39 f1                	cmp    %esi,%ecx
  8023fc:	0f 86 a6 00 00 00    	jbe    8024a8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802402:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802404:	89 d0                	mov    %edx,%eax
  802406:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802408:	83 c4 20             	add    $0x20,%esp
  80240b:	5e                   	pop    %esi
  80240c:	5f                   	pop    %edi
  80240d:	5d                   	pop    %ebp
  80240e:	c3                   	ret    
  80240f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802410:	39 f5                	cmp    %esi,%ebp
  802412:	0f 87 ac 00 00 00    	ja     8024c4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802418:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80241b:	83 f0 1f             	xor    $0x1f,%eax
  80241e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802422:	0f 84 a8 00 00 00    	je     8024d0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802428:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80242c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80242e:	bf 20 00 00 00       	mov    $0x20,%edi
  802433:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802437:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80243b:	89 f9                	mov    %edi,%ecx
  80243d:	d3 e8                	shr    %cl,%eax
  80243f:	09 e8                	or     %ebp,%eax
  802441:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802445:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802449:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80244d:	d3 e0                	shl    %cl,%eax
  80244f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802453:	89 f2                	mov    %esi,%edx
  802455:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802457:	8b 44 24 14          	mov    0x14(%esp),%eax
  80245b:	d3 e0                	shl    %cl,%eax
  80245d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802461:	8b 44 24 14          	mov    0x14(%esp),%eax
  802465:	89 f9                	mov    %edi,%ecx
  802467:	d3 e8                	shr    %cl,%eax
  802469:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80246b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80246d:	89 f2                	mov    %esi,%edx
  80246f:	f7 74 24 18          	divl   0x18(%esp)
  802473:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802475:	f7 64 24 0c          	mull   0xc(%esp)
  802479:	89 c5                	mov    %eax,%ebp
  80247b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80247d:	39 d6                	cmp    %edx,%esi
  80247f:	72 67                	jb     8024e8 <__umoddi3+0x114>
  802481:	74 75                	je     8024f8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802483:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802487:	29 e8                	sub    %ebp,%eax
  802489:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80248b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80248f:	d3 e8                	shr    %cl,%eax
  802491:	89 f2                	mov    %esi,%edx
  802493:	89 f9                	mov    %edi,%ecx
  802495:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802497:	09 d0                	or     %edx,%eax
  802499:	89 f2                	mov    %esi,%edx
  80249b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80249f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024a1:	83 c4 20             	add    $0x20,%esp
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024a8:	85 c9                	test   %ecx,%ecx
  8024aa:	75 0b                	jne    8024b7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b1:	31 d2                	xor    %edx,%edx
  8024b3:	f7 f1                	div    %ecx
  8024b5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024b7:	89 f0                	mov    %esi,%eax
  8024b9:	31 d2                	xor    %edx,%edx
  8024bb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024bd:	89 f8                	mov    %edi,%eax
  8024bf:	e9 3e ff ff ff       	jmp    802402 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8024c4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024c6:	83 c4 20             	add    $0x20,%esp
  8024c9:	5e                   	pop    %esi
  8024ca:	5f                   	pop    %edi
  8024cb:	5d                   	pop    %ebp
  8024cc:	c3                   	ret    
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024d0:	39 f5                	cmp    %esi,%ebp
  8024d2:	72 04                	jb     8024d8 <__umoddi3+0x104>
  8024d4:	39 f9                	cmp    %edi,%ecx
  8024d6:	77 06                	ja     8024de <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024d8:	89 f2                	mov    %esi,%edx
  8024da:	29 cf                	sub    %ecx,%edi
  8024dc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8024de:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024e0:	83 c4 20             	add    $0x20,%esp
  8024e3:	5e                   	pop    %esi
  8024e4:	5f                   	pop    %edi
  8024e5:	5d                   	pop    %ebp
  8024e6:	c3                   	ret    
  8024e7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024e8:	89 d1                	mov    %edx,%ecx
  8024ea:	89 c5                	mov    %eax,%ebp
  8024ec:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024f0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8024f4:	eb 8d                	jmp    802483 <__umoddi3+0xaf>
  8024f6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024f8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8024fc:	72 ea                	jb     8024e8 <__umoddi3+0x114>
  8024fe:	89 f1                	mov    %esi,%ecx
  802500:	eb 81                	jmp    802483 <__umoddi3+0xaf>
