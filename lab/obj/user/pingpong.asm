
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 05 0f 00 00       	call   800f47 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 17 0b 00 00       	call   800b67 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 80 29 80 00 	movl   $0x802980,(%esp)
  80005f:	e8 a4 01 00 00       	call   800208 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 15 12 00 00       	call   80129c <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 8a 11 00 00       	call   80122c <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 bb 0a 00 00       	call   800b67 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 96 29 80 00 	movl   $0x802996,(%esp)
  8000bf:	e8 44 01 00 00       	call   800208 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 25                	je     8000ee <umain+0xba>
			return;
		i++;
  8000c9:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d1:	00 
  8000d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d9:	00 
  8000da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 04 24             	mov    %eax,(%esp)
  8000e4:	e8 b3 11 00 00       	call   80129c <ipc_send>
		if (i == 10)
  8000e9:	83 fb 0a             	cmp    $0xa,%ebx
  8000ec:	75 9c                	jne    80008a <umain+0x56>
			return;
	}

}
  8000ee:	83 c4 2c             	add    $0x2c,%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800106:	e8 5c 0a 00 00       	call   800b67 <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 f6                	test   %esi,%esi
  800128:	7e 07                	jle    800131 <libmain+0x39>
		binaryname = argv[0];
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800135:	89 34 24             	mov    %esi,(%esp)
  800138:	e8 f7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800152:	e8 f4 13 00 00       	call   80154b <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 b2 09 00 00       	call   800b15 <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 14             	sub    $0x14,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	40                   	inc    %eax
  80017c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 19                	jne    80019e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800185:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80018c:	00 
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 40 09 00 00       	call   800ad8 <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019e:	ff 43 04             	incl   0x4(%ebx)
}
  8001a1:	83 c4 14             	add    $0x14,%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5d                   	pop    %ebp
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	c7 04 24 68 01 80 00 	movl   $0x800168,(%esp)
  8001e3:	e8 82 01 00 00       	call   80036a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 d8 08 00 00       	call   800ad8 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	89 44 24 04          	mov    %eax,0x4(%esp)
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	e8 87 ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800220:	c9                   	leave  
  800221:	c3                   	ret    
	...

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 3c             	sub    $0x3c,%esp
  80022d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800230:	89 d7                	mov    %edx,%edi
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800238:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800241:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	85 c0                	test   %eax,%eax
  800246:	75 08                	jne    800250 <printnum+0x2c>
  800248:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024e:	77 57                	ja     8002a7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	89 74 24 10          	mov    %esi,0x10(%esp)
  800254:	4b                   	dec    %ebx
  800255:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800259:	8b 45 10             	mov    0x10(%ebp),%eax
  80025c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800260:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800264:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026f:	00 
  800270:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	e8 96 24 00 00       	call   802718 <__udivdi3>
  800282:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800286:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800291:	89 fa                	mov    %edi,%edx
  800293:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800296:	e8 89 ff ff ff       	call   800224 <printnum>
  80029b:	eb 0f                	jmp    8002ac <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a1:	89 34 24             	mov    %esi,(%esp)
  8002a4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a7:	4b                   	dec    %ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f f1                	jg     80029d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c2:	00 
  8002c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	e8 63 25 00 00       	call   802838 <__umoddi3>
  8002d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d9:	0f be 80 b3 29 80 00 	movsbl 0x8029b3(%eax),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e6:	83 c4 3c             	add    $0x3c,%esp
  8002e9:	5b                   	pop    %ebx
  8002ea:	5e                   	pop    %esi
  8002eb:	5f                   	pop    %edi
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f1:	83 fa 01             	cmp    $0x1,%edx
  8002f4:	7e 0e                	jle    800304 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	8b 52 04             	mov    0x4(%edx),%edx
  800302:	eb 22                	jmp    800326 <getuint+0x38>
	else if (lflag)
  800304:	85 d2                	test   %edx,%edx
  800306:	74 10                	je     800318 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	eb 0e                	jmp    800326 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800331:	8b 10                	mov    (%eax),%edx
  800333:	3b 50 04             	cmp    0x4(%eax),%edx
  800336:	73 08                	jae    800340 <sprintputch+0x18>
		*b->buf++ = ch;
  800338:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033b:	88 0a                	mov    %cl,(%edx)
  80033d:	42                   	inc    %edx
  80033e:	89 10                	mov    %edx,(%eax)
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800348:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034f:	8b 45 10             	mov    0x10(%ebp),%eax
  800352:	89 44 24 08          	mov    %eax,0x8(%esp)
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	8b 45 08             	mov    0x8(%ebp),%eax
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	e8 02 00 00 00       	call   80036a <vprintfmt>
	va_end(ap);
}
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 4c             	sub    $0x4c,%esp
  800373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800376:	8b 75 10             	mov    0x10(%ebp),%esi
  800379:	eb 12                	jmp    80038d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037b:	85 c0                	test   %eax,%eax
  80037d:	0f 84 6b 03 00 00    	je     8006ee <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800383:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038d:	0f b6 06             	movzbl (%esi),%eax
  800390:	46                   	inc    %esi
  800391:	83 f8 25             	cmp    $0x25,%eax
  800394:	75 e5                	jne    80037b <vprintfmt+0x11>
  800396:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80039a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003a1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b2:	eb 26                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003bb:	eb 1d                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c4:	eb 14                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d0:	eb 08                	jmp    8003da <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003d5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	0f b6 06             	movzbl (%esi),%eax
  8003dd:	8d 56 01             	lea    0x1(%esi),%edx
  8003e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003e3:	8a 16                	mov    (%esi),%dl
  8003e5:	83 ea 23             	sub    $0x23,%edx
  8003e8:	80 fa 55             	cmp    $0x55,%dl
  8003eb:	0f 87 e1 02 00 00    	ja     8006d2 <vprintfmt+0x368>
  8003f1:	0f b6 d2             	movzbl %dl,%edx
  8003f4:	ff 24 95 00 2b 80 00 	jmp    *0x802b00(,%edx,4)
  8003fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fe:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800403:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800406:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80040a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80040d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800410:	83 fa 09             	cmp    $0x9,%edx
  800413:	77 2a                	ja     80043f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800415:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800416:	eb eb                	jmp    800403 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800426:	eb 17                	jmp    80043f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800428:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042c:	78 98                	js     8003c6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800431:	eb a7                	jmp    8003da <vprintfmt+0x70>
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800436:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80043d:	eb 9b                	jmp    8003da <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80043f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800443:	79 95                	jns    8003da <vprintfmt+0x70>
  800445:	eb 8b                	jmp    8003d2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044b:	eb 8d                	jmp    8003da <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800465:	e9 23 ff ff ff       	jmp    80038d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	85 c0                	test   %eax,%eax
  800477:	79 02                	jns    80047b <vprintfmt+0x111>
  800479:	f7 d8                	neg    %eax
  80047b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047d:	83 f8 10             	cmp    $0x10,%eax
  800480:	7f 0b                	jg     80048d <vprintfmt+0x123>
  800482:	8b 04 85 60 2c 80 00 	mov    0x802c60(,%eax,4),%eax
  800489:	85 c0                	test   %eax,%eax
  80048b:	75 23                	jne    8004b0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80048d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800491:	c7 44 24 08 cb 29 80 	movl   $0x8029cb,0x8(%esp)
  800498:	00 
  800499:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 9a fe ff ff       	call   800342 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ab:	e9 dd fe ff ff       	jmp    80038d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b4:	c7 44 24 08 69 2e 80 	movl   $0x802e69,0x8(%esp)
  8004bb:	00 
  8004bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c3:	89 14 24             	mov    %edx,(%esp)
  8004c6:	e8 77 fe ff ff       	call   800342 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ce:	e9 ba fe ff ff       	jmp    80038d <vprintfmt+0x23>
  8004d3:	89 f9                	mov    %edi,%ecx
  8004d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 30                	mov    (%eax),%esi
  8004e6:	85 f6                	test   %esi,%esi
  8004e8:	75 05                	jne    8004ef <vprintfmt+0x185>
				p = "(null)";
  8004ea:	be c4 29 80 00       	mov    $0x8029c4,%esi
			if (width > 0 && padc != '-')
  8004ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f3:	0f 8e 84 00 00 00    	jle    80057d <vprintfmt+0x213>
  8004f9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004fd:	74 7e                	je     80057d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800503:	89 34 24             	mov    %esi,(%esp)
  800506:	e8 8b 02 00 00       	call   800796 <strnlen>
  80050b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050e:	29 c2                	sub    %eax,%edx
  800510:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800513:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800517:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80051a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80051d:	89 de                	mov    %ebx,%esi
  80051f:	89 d3                	mov    %edx,%ebx
  800521:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	eb 0b                	jmp    800530 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800525:	89 74 24 04          	mov    %esi,0x4(%esp)
  800529:	89 3c 24             	mov    %edi,(%esp)
  80052c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	4b                   	dec    %ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f f1                	jg     800525 <vprintfmt+0x1bb>
  800534:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800537:	89 f3                	mov    %esi,%ebx
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80053c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053f:	85 c0                	test   %eax,%eax
  800541:	79 05                	jns    800548 <vprintfmt+0x1de>
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054b:	29 c2                	sub    %eax,%edx
  80054d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800550:	eb 2b                	jmp    80057d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800556:	74 18                	je     800570 <vprintfmt+0x206>
  800558:	8d 50 e0             	lea    -0x20(%eax),%edx
  80055b:	83 fa 5e             	cmp    $0x5e,%edx
  80055e:	76 10                	jbe    800570 <vprintfmt+0x206>
					putch('?', putdat);
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	eb 0a                	jmp    80057a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	ff 4d e4             	decl   -0x1c(%ebp)
  80057d:	0f be 06             	movsbl (%esi),%eax
  800580:	46                   	inc    %esi
  800581:	85 c0                	test   %eax,%eax
  800583:	74 21                	je     8005a6 <vprintfmt+0x23c>
  800585:	85 ff                	test   %edi,%edi
  800587:	78 c9                	js     800552 <vprintfmt+0x1e8>
  800589:	4f                   	dec    %edi
  80058a:	79 c6                	jns    800552 <vprintfmt+0x1e8>
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	89 de                	mov    %ebx,%esi
  800591:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800594:	eb 18                	jmp    8005ae <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800596:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a3:	4b                   	dec    %ebx
  8005a4:	eb 08                	jmp    8005ae <vprintfmt+0x244>
  8005a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a9:	89 de                	mov    %ebx,%esi
  8005ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7f e4                	jg     800596 <vprintfmt+0x22c>
  8005b2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ba:	e9 ce fd ff ff       	jmp    80038d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bf:	83 f9 01             	cmp    $0x1,%ecx
  8005c2:	7e 10                	jle    8005d4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 30                	mov    (%eax),%esi
  8005cf:	8b 78 04             	mov    0x4(%eax),%edi
  8005d2:	eb 26                	jmp    8005fa <vprintfmt+0x290>
	else if (lflag)
  8005d4:	85 c9                	test   %ecx,%ecx
  8005d6:	74 12                	je     8005ea <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 04             	lea    0x4(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e1:	8b 30                	mov    (%eax),%esi
  8005e3:	89 f7                	mov    %esi,%edi
  8005e5:	c1 ff 1f             	sar    $0x1f,%edi
  8005e8:	eb 10                	jmp    8005fa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 30                	mov    (%eax),%esi
  8005f5:	89 f7                	mov    %esi,%edi
  8005f7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	78 0a                	js     800608 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800603:	e9 8c 00 00 00       	jmp    800694 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800616:	f7 de                	neg    %esi
  800618:	83 d7 00             	adc    $0x0,%edi
  80061b:	f7 df                	neg    %edi
			}
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800622:	eb 70                	jmp    800694 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 c0 fc ff ff       	call   8002ee <getuint>
  80062e:	89 c6                	mov    %eax,%esi
  800630:	89 d7                	mov    %edx,%edi
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800637:	eb 5b                	jmp    800694 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 ab fc ff ff       	call   8002ee <getuint>
  800643:	89 c6                	mov    %eax,%esi
  800645:	89 d7                	mov    %edx,%edi
			base = 8;
  800647:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80064c:	eb 46                	jmp    800694 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80064e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800652:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800659:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800673:	8b 30                	mov    (%eax),%esi
  800675:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067f:	eb 13                	jmp    800694 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 63 fc ff ff       	call   8002ee <getuint>
  80068b:	89 c6                	mov    %eax,%esi
  80068d:	89 d7                	mov    %edx,%edi
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800694:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800698:	89 54 24 10          	mov    %edx,0x10(%esp)
  80069c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80069f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a7:	89 34 24             	mov    %esi,(%esp)
  8006aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ae:	89 da                	mov    %ebx,%edx
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	e8 6c fb ff ff       	call   800224 <printnum>
			break;
  8006b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006bb:	e9 cd fc ff ff       	jmp    80038d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cd:	e9 bb fc ff ff       	jmp    80038d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006dd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e0:	eb 01                	jmp    8006e3 <vprintfmt+0x379>
  8006e2:	4e                   	dec    %esi
  8006e3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e7:	75 f9                	jne    8006e2 <vprintfmt+0x378>
  8006e9:	e9 9f fc ff ff       	jmp    80038d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ee:	83 c4 4c             	add    $0x4c,%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 28             	sub    $0x28,%esp
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800705:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800709:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 30                	je     800747 <vsnprintf+0x51>
  800717:	85 d2                	test   %edx,%edx
  800719:	7e 33                	jle    80074e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800722:	8b 45 10             	mov    0x10(%ebp),%eax
  800725:	89 44 24 08          	mov    %eax,0x8(%esp)
  800729:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800730:	c7 04 24 28 03 80 00 	movl   $0x800328,(%esp)
  800737:	e8 2e fc ff ff       	call   80036a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800745:	eb 0c                	jmp    800753 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800747:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074c:	eb 05                	jmp    800753 <vsnprintf+0x5d>
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
  800765:	89 44 24 08          	mov    %eax,0x8(%esp)
  800769:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 7b ff ff ff       	call   8006f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    
  80077d:	00 00                	add    %al,(%eax)
	...

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 01                	jmp    80078e <strlen+0xe>
		n++;
  80078d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f9                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	eb 01                	jmp    8007a7 <strnlen+0x11>
		n++;
  8007a6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	39 d0                	cmp    %edx,%eax
  8007a9:	74 06                	je     8007b1 <strnlen+0x1b>
  8007ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007af:	75 f5                	jne    8007a6 <strnlen+0x10>
		n++;
	return n;
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c8:	42                   	inc    %edx
  8007c9:	84 c9                	test   %cl,%cl
  8007cb:	75 f5                	jne    8007c2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007cd:	5b                   	pop    %ebx
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007da:	89 1c 24             	mov    %ebx,(%esp)
  8007dd:	e8 9e ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	89 04 24             	mov    %eax,(%esp)
  8007ee:	e8 c0 ff ff ff       	call   8007b3 <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	83 c4 08             	add    $0x8,%esp
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080e:	eb 0c                	jmp    80081c <strncpy+0x21>
		*dst++ = *src;
  800810:	8a 1a                	mov    (%edx),%bl
  800812:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 3a 01             	cmpb   $0x1,(%edx)
  800818:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	41                   	inc    %ecx
  80081c:	39 f1                	cmp    %esi,%ecx
  80081e:	75 f0                	jne    800810 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800832:	85 d2                	test   %edx,%edx
  800834:	75 0a                	jne    800840 <strlcpy+0x1c>
  800836:	89 f0                	mov    %esi,%eax
  800838:	eb 1a                	jmp    800854 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083a:	88 18                	mov    %bl,(%eax)
  80083c:	40                   	inc    %eax
  80083d:	41                   	inc    %ecx
  80083e:	eb 02                	jmp    800842 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800840:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800842:	4a                   	dec    %edx
  800843:	74 0a                	je     80084f <strlcpy+0x2b>
  800845:	8a 19                	mov    (%ecx),%bl
  800847:	84 db                	test   %bl,%bl
  800849:	75 ef                	jne    80083a <strlcpy+0x16>
  80084b:	89 c2                	mov    %eax,%edx
  80084d:	eb 02                	jmp    800851 <strlcpy+0x2d>
  80084f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800851:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800854:	29 f0                	sub    %esi,%eax
}
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800863:	eb 02                	jmp    800867 <strcmp+0xd>
		p++, q++;
  800865:	41                   	inc    %ecx
  800866:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800867:	8a 01                	mov    (%ecx),%al
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x17>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 f4                	je     800865 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800885:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800888:	eb 03                	jmp    80088d <strncmp+0x12>
		n--, p++, q++;
  80088a:	4a                   	dec    %edx
  80088b:	40                   	inc    %eax
  80088c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088d:	85 d2                	test   %edx,%edx
  80088f:	74 14                	je     8008a5 <strncmp+0x2a>
  800891:	8a 18                	mov    (%eax),%bl
  800893:	84 db                	test   %bl,%bl
  800895:	74 04                	je     80089b <strncmp+0x20>
  800897:	3a 19                	cmp    (%ecx),%bl
  800899:	74 ef                	je     80088a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089b:	0f b6 00             	movzbl (%eax),%eax
  80089e:	0f b6 11             	movzbl (%ecx),%edx
  8008a1:	29 d0                	sub    %edx,%eax
  8008a3:	eb 05                	jmp    8008aa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b6:	eb 05                	jmp    8008bd <strchr+0x10>
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 0c                	je     8008c8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bc:	40                   	inc    %eax
  8008bd:	8a 10                	mov    (%eax),%dl
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f5                	jne    8008b8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d3:	eb 05                	jmp    8008da <strfind+0x10>
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 07                	je     8008e0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d9:	40                   	inc    %eax
  8008da:	8a 10                	mov    (%eax),%dl
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f5                	jne    8008d5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	57                   	push   %edi
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f1:	85 c9                	test   %ecx,%ecx
  8008f3:	74 30                	je     800925 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fb:	75 25                	jne    800922 <memset+0x40>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 20                	jne    800922 <memset+0x40>
		c &= 0xFF;
  800902:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800905:	89 d3                	mov    %edx,%ebx
  800907:	c1 e3 08             	shl    $0x8,%ebx
  80090a:	89 d6                	mov    %edx,%esi
  80090c:	c1 e6 18             	shl    $0x18,%esi
  80090f:	89 d0                	mov    %edx,%eax
  800911:	c1 e0 10             	shl    $0x10,%eax
  800914:	09 f0                	or     %esi,%eax
  800916:	09 d0                	or     %edx,%eax
  800918:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091d:	fc                   	cld    
  80091e:	f3 ab                	rep stos %eax,%es:(%edi)
  800920:	eb 03                	jmp    800925 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800922:	fc                   	cld    
  800923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800925:	89 f8                	mov    %edi,%eax
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	57                   	push   %edi
  800930:	56                   	push   %esi
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093a:	39 c6                	cmp    %eax,%esi
  80093c:	73 34                	jae    800972 <memmove+0x46>
  80093e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800941:	39 d0                	cmp    %edx,%eax
  800943:	73 2d                	jae    800972 <memmove+0x46>
		s += n;
		d += n;
  800945:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	f6 c2 03             	test   $0x3,%dl
  80094b:	75 1b                	jne    800968 <memmove+0x3c>
  80094d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800953:	75 13                	jne    800968 <memmove+0x3c>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0e                	jne    800968 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095a:	83 ef 04             	sub    $0x4,%edi
  80095d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800960:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800963:	fd                   	std    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 07                	jmp    80096f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800968:	4f                   	dec    %edi
  800969:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096c:	fd                   	std    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096f:	fc                   	cld    
  800970:	eb 20                	jmp    800992 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800972:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800978:	75 13                	jne    80098d <memmove+0x61>
  80097a:	a8 03                	test   $0x3,%al
  80097c:	75 0f                	jne    80098d <memmove+0x61>
  80097e:	f6 c1 03             	test   $0x3,%cl
  800981:	75 0a                	jne    80098d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800983:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800986:	89 c7                	mov    %eax,%edi
  800988:	fc                   	cld    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 05                	jmp    800992 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80099c:	8b 45 10             	mov    0x10(%ebp),%eax
  80099f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	89 04 24             	mov    %eax,(%esp)
  8009b0:	e8 77 ff ff ff       	call   80092c <memmove>
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cb:	eb 16                	jmp    8009e3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cd:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009d0:	42                   	inc    %edx
  8009d1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009d5:	38 c8                	cmp    %cl,%al
  8009d7:	74 0a                	je     8009e3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 c9             	movzbl %cl,%ecx
  8009df:	29 c8                	sub    %ecx,%eax
  8009e1:	eb 09                	jmp    8009ec <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e3:	39 da                	cmp    %ebx,%edx
  8009e5:	75 e6                	jne    8009cd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ff:	eb 05                	jmp    800a06 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a01:	38 08                	cmp    %cl,(%eax)
  800a03:	74 05                	je     800a0a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a05:	40                   	inc    %eax
  800a06:	39 d0                	cmp    %edx,%eax
  800a08:	72 f7                	jb     800a01 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
  800a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a18:	eb 01                	jmp    800a1b <strtol+0xf>
		s++;
  800a1a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1b:	8a 02                	mov    (%edx),%al
  800a1d:	3c 20                	cmp    $0x20,%al
  800a1f:	74 f9                	je     800a1a <strtol+0xe>
  800a21:	3c 09                	cmp    $0x9,%al
  800a23:	74 f5                	je     800a1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a25:	3c 2b                	cmp    $0x2b,%al
  800a27:	75 08                	jne    800a31 <strtol+0x25>
		s++;
  800a29:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2f:	eb 13                	jmp    800a44 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a31:	3c 2d                	cmp    $0x2d,%al
  800a33:	75 0a                	jne    800a3f <strtol+0x33>
		s++, neg = 1;
  800a35:	8d 52 01             	lea    0x1(%edx),%edx
  800a38:	bf 01 00 00 00       	mov    $0x1,%edi
  800a3d:	eb 05                	jmp    800a44 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	74 05                	je     800a4d <strtol+0x41>
  800a48:	83 fb 10             	cmp    $0x10,%ebx
  800a4b:	75 28                	jne    800a75 <strtol+0x69>
  800a4d:	8a 02                	mov    (%edx),%al
  800a4f:	3c 30                	cmp    $0x30,%al
  800a51:	75 10                	jne    800a63 <strtol+0x57>
  800a53:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a57:	75 0a                	jne    800a63 <strtol+0x57>
		s += 2, base = 16;
  800a59:	83 c2 02             	add    $0x2,%edx
  800a5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a61:	eb 12                	jmp    800a75 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a63:	85 db                	test   %ebx,%ebx
  800a65:	75 0e                	jne    800a75 <strtol+0x69>
  800a67:	3c 30                	cmp    $0x30,%al
  800a69:	75 05                	jne    800a70 <strtol+0x64>
		s++, base = 8;
  800a6b:	42                   	inc    %edx
  800a6c:	b3 08                	mov    $0x8,%bl
  800a6e:	eb 05                	jmp    800a75 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a70:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7c:	8a 0a                	mov    (%edx),%cl
  800a7e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a81:	80 fb 09             	cmp    $0x9,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x82>
			dig = *s - '0';
  800a86:	0f be c9             	movsbl %cl,%ecx
  800a89:	83 e9 30             	sub    $0x30,%ecx
  800a8c:	eb 1e                	jmp    800aac <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a8e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a96:	0f be c9             	movsbl %cl,%ecx
  800a99:	83 e9 57             	sub    $0x57,%ecx
  800a9c:	eb 0e                	jmp    800aac <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 12                	ja     800ab8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aa6:	0f be c9             	movsbl %cl,%ecx
  800aa9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aac:	39 f1                	cmp    %esi,%ecx
  800aae:	7d 0c                	jge    800abc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ab0:	42                   	inc    %edx
  800ab1:	0f af c6             	imul   %esi,%eax
  800ab4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ab6:	eb c4                	jmp    800a7c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab8:	89 c1                	mov    %eax,%ecx
  800aba:	eb 02                	jmp    800abe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800abe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac2:	74 05                	je     800ac9 <strtol+0xbd>
		*endptr = (char *) s;
  800ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac9:	85 ff                	test   %edi,%edi
  800acb:	74 04                	je     800ad1 <strtol+0xc5>
  800acd:	89 c8                	mov    %ecx,%eax
  800acf:	f7 d8                	neg    %eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    
	...

00800ad8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	89 c6                	mov    %eax,%esi
  800aef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 01 00 00 00       	mov    $0x1,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b23:	b8 03 00 00 00       	mov    $0x3,%eax
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	89 cb                	mov    %ecx,%ebx
  800b2d:	89 cf                	mov    %ecx,%edi
  800b2f:	89 ce                	mov    %ecx,%esi
  800b31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 28                	jle    800b5f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b3b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b42:	00 
  800b43:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800b4a:	00 
  800b4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b52:	00 
  800b53:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800b5a:	e8 a9 1a 00 00       	call   802608 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5f:	83 c4 2c             	add    $0x2c,%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 02 00 00 00       	mov    $0x2,%eax
  800b77:	89 d1                	mov    %edx,%ecx
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	89 d7                	mov    %edx,%edi
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_yield>:

void
sys_yield(void)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b96:	89 d1                	mov    %edx,%ecx
  800b98:	89 d3                	mov    %edx,%ebx
  800b9a:	89 d7                	mov    %edx,%edi
  800b9c:	89 d6                	mov    %edx,%esi
  800b9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	be 00 00 00 00       	mov    $0x0,%esi
  800bb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	89 f7                	mov    %esi,%edi
  800bc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	7e 28                	jle    800bf1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bcd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd4:	00 
  800bd5:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800bdc:	00 
  800bdd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be4:	00 
  800be5:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800bec:	e8 17 1a 00 00       	call   802608 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf1:	83 c4 2c             	add    $0x2c,%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b8 05 00 00 00       	mov    $0x5,%eax
  800c07:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 28                	jle    800c44 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c20:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c27:	00 
  800c28:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800c2f:	00 
  800c30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c37:	00 
  800c38:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800c3f:	e8 c4 19 00 00       	call   802608 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c44:	83 c4 2c             	add    $0x2c,%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7e 28                	jle    800c97 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c73:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800c82:	00 
  800c83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8a:	00 
  800c8b:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800c92:	e8 71 19 00 00       	call   802608 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c97:	83 c4 2c             	add    $0x2c,%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cad:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	89 df                	mov    %ebx,%edi
  800cba:	89 de                	mov    %ebx,%esi
  800cbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 28                	jle    800cea <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ccd:	00 
  800cce:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800cd5:	00 
  800cd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdd:	00 
  800cde:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800ce5:	e8 1e 19 00 00       	call   802608 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cea:	83 c4 2c             	add    $0x2c,%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d00:	b8 09 00 00 00       	mov    $0x9,%eax
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	89 df                	mov    %ebx,%edi
  800d0d:	89 de                	mov    %ebx,%esi
  800d0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 28                	jle    800d3d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d19:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d20:	00 
  800d21:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800d28:	00 
  800d29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d30:	00 
  800d31:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800d38:	e8 cb 18 00 00       	call   802608 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3d:	83 c4 2c             	add    $0x2c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7e 28                	jle    800d90 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d68:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d73:	00 
  800d74:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d83:	00 
  800d84:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800d8b:	e8 78 18 00 00       	call   802608 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d90:	83 c4 2c             	add    $0x2c,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d9e:	be 00 00 00 00       	mov    $0x0,%esi
  800da3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 cb                	mov    %ecx,%ebx
  800dd3:	89 cf                	mov    %ecx,%edi
  800dd5:	89 ce                	mov    %ecx,%esi
  800dd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800e00:	e8 03 18 00 00       	call   802608 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	ba 00 00 00 00       	mov    $0x0,%edx
  800e18:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e1d:	89 d1                	mov    %edx,%ecx
  800e1f:	89 d3                	mov    %edx,%ebx
  800e21:	89 d7                	mov    %edx,%edi
  800e23:	89 d6                	mov    %edx,%esi
  800e25:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e37:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	89 df                	mov    %ebx,%edi
  800e44:	89 de                	mov    %ebx,%esi
  800e46:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	b8 10 00 00 00       	mov    $0x10,%eax
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	89 df                	mov    %ebx,%edi
  800e65:	89 de                	mov    %ebx,%esi
  800e67:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    
	...

00800e70 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	53                   	push   %ebx
  800e74:	83 ec 24             	sub    $0x24,%esp
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e7a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e7c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e80:	74 2d                	je     800eaf <pgfault+0x3f>
  800e82:	89 d8                	mov    %ebx,%eax
  800e84:	c1 e8 16             	shr    $0x16,%eax
  800e87:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e8e:	a8 01                	test   $0x1,%al
  800e90:	74 1d                	je     800eaf <pgfault+0x3f>
  800e92:	89 d8                	mov    %ebx,%eax
  800e94:	c1 e8 0c             	shr    $0xc,%eax
  800e97:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e9e:	f6 c2 01             	test   $0x1,%dl
  800ea1:	74 0c                	je     800eaf <pgfault+0x3f>
  800ea3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eaa:	f6 c4 08             	test   $0x8,%ah
  800ead:	75 1c                	jne    800ecb <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  800eaf:	c7 44 24 08 f0 2c 80 	movl   $0x802cf0,0x8(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800ebe:	00 
  800ebf:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  800ec6:	e8 3d 17 00 00       	call   802608 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  800ecb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800ed1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ee8:	e8 b8 fc ff ff       	call   800ba5 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  800eed:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ef4:	00 
  800ef5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ef9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f00:	e8 91 fa ff ff       	call   800996 <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  800f05:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f0c:	00 
  800f0d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f28:	e8 cc fc ff ff       	call   800bf9 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  800f2d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f3c:	e8 0b fd ff ff       	call   800c4c <sys_page_unmap>

	// panic("pgfault not implemented");
}
  800f41:	83 c4 24             	add    $0x24,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f50:	c7 04 24 70 0e 80 00 	movl   $0x800e70,(%esp)
  800f57:	e8 04 17 00 00       	call   802660 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f5c:	ba 07 00 00 00       	mov    $0x7,%edx
  800f61:	89 d0                	mov    %edx,%eax
  800f63:	cd 30                	int    $0x30
  800f65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f68:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	79 20                	jns    800f8e <fork+0x47>
		panic("sys_exofork: %e", envid);
  800f6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f72:	c7 44 24 08 3e 2d 80 	movl   $0x802d3e,0x8(%esp)
  800f79:	00 
  800f7a:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f81:	00 
  800f82:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  800f89:	e8 7a 16 00 00       	call   802608 <_panic>
	if (envid == 0)
  800f8e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f92:	75 25                	jne    800fb9 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f94:	e8 ce fb ff ff       	call   800b67 <sys_getenvid>
  800f99:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fa5:	c1 e0 07             	shl    $0x7,%eax
  800fa8:	29 d0                	sub    %edx,%eax
  800faa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800faf:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fb4:	e9 43 02 00 00       	jmp    8011fc <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  800fbe:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fc4:	0f 84 85 01 00 00    	je     80114f <fork+0x208>
  800fca:	89 d8                	mov    %ebx,%eax
  800fcc:	c1 e8 16             	shr    $0x16,%eax
  800fcf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd6:	a8 01                	test   $0x1,%al
  800fd8:	0f 84 5f 01 00 00    	je     80113d <fork+0x1f6>
  800fde:	89 d8                	mov    %ebx,%eax
  800fe0:	c1 e8 0c             	shr    $0xc,%eax
  800fe3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fea:	f6 c2 01             	test   $0x1,%dl
  800fed:	0f 84 4a 01 00 00    	je     80113d <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  800ff3:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  800ff5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ffc:	f6 c6 04             	test   $0x4,%dh
  800fff:	74 50                	je     801051 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  801001:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801008:	25 07 0e 00 00       	and    $0xe07,%eax
  80100d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801011:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801015:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801019:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80101d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801024:	e8 d0 fb ff ff       	call   800bf9 <sys_page_map>
  801029:	85 c0                	test   %eax,%eax
  80102b:	0f 89 0c 01 00 00    	jns    80113d <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  801031:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801035:	c7 44 24 08 4e 2d 80 	movl   $0x802d4e,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  80104c:	e8 b7 15 00 00       	call   802608 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  801051:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801058:	f6 c2 02             	test   $0x2,%dl
  80105b:	75 10                	jne    80106d <fork+0x126>
  80105d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801064:	f6 c4 08             	test   $0x8,%ah
  801067:	0f 84 8c 00 00 00    	je     8010f9 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  80106d:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801074:	00 
  801075:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801079:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80107d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801081:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801088:	e8 6c fb ff ff       	call   800bf9 <sys_page_map>
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 20                	jns    8010b1 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801091:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801095:	c7 44 24 08 4e 2d 80 	movl   $0x802d4e,0x8(%esp)
  80109c:	00 
  80109d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8010a4:	00 
  8010a5:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  8010ac:	e8 57 15 00 00       	call   802608 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  8010b1:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010b8:	00 
  8010b9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010c4:	00 
  8010c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d0:	e8 24 fb ff ff       	call   800bf9 <sys_page_map>
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 64                	jns    80113d <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8010d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010dd:	c7 44 24 08 4e 2d 80 	movl   $0x802d4e,0x8(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  8010ec:	00 
  8010ed:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  8010f4:	e8 0f 15 00 00       	call   802608 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  8010f9:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801100:	00 
  801101:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801105:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801109:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80110d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801114:	e8 e0 fa ff ff       	call   800bf9 <sys_page_map>
  801119:	85 c0                	test   %eax,%eax
  80111b:	79 20                	jns    80113d <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  80111d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801121:	c7 44 24 08 4e 2d 80 	movl   $0x802d4e,0x8(%esp)
  801128:	00 
  801129:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801130:	00 
  801131:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  801138:	e8 cb 14 00 00       	call   802608 <_panic>
  80113d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  801143:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801149:	0f 85 6f fe ff ff    	jne    800fbe <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  80114f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801156:	00 
  801157:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80115e:	ee 
  80115f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801162:	89 04 24             	mov    %eax,(%esp)
  801165:	e8 3b fa ff ff       	call   800ba5 <sys_page_alloc>
  80116a:	85 c0                	test   %eax,%eax
  80116c:	79 20                	jns    80118e <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  80116e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801172:	c7 44 24 08 60 2d 80 	movl   $0x802d60,0x8(%esp)
  801179:	00 
  80117a:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801181:	00 
  801182:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  801189:	e8 7a 14 00 00       	call   802608 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80118e:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  801195:	00 
  801196:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801199:	89 04 24             	mov    %eax,(%esp)
  80119c:	e8 a4 fb ff ff       	call   800d45 <sys_env_set_pgfault_upcall>
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	79 20                	jns    8011c5 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  8011a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a9:	c7 44 24 08 14 2d 80 	movl   $0x802d14,0x8(%esp)
  8011b0:	00 
  8011b1:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  8011b8:	00 
  8011b9:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  8011c0:	e8 43 14 00 00       	call   802608 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011c5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011cc:	00 
  8011cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d0:	89 04 24             	mov    %eax,(%esp)
  8011d3:	e8 c7 fa ff ff       	call   800c9f <sys_env_set_status>
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	79 20                	jns    8011fc <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  8011dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e0:	c7 44 24 08 73 2d 80 	movl   $0x802d73,0x8(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8011ef:	00 
  8011f0:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  8011f7:	e8 0c 14 00 00       	call   802608 <_panic>

	return envid;
	// panic("fork not implemented");
}
  8011fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ff:	83 c4 3c             	add    $0x3c,%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <sfork>:

// Challenge!
int
sfork(void)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80120d:	c7 44 24 08 8a 2d 80 	movl   $0x802d8a,0x8(%esp)
  801214:	00 
  801215:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  80121c:	00 
  80121d:	c7 04 24 33 2d 80 00 	movl   $0x802d33,(%esp)
  801224:	e8 df 13 00 00       	call   802608 <_panic>
  801229:	00 00                	add    %al,(%eax)
	...

0080122c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 10             	sub    $0x10,%esp
  801234:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  80123d:	85 c0                	test   %eax,%eax
  80123f:	74 0a                	je     80124b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  801241:	89 04 24             	mov    %eax,(%esp)
  801244:	e8 72 fb ff ff       	call   800dbb <sys_ipc_recv>
  801249:	eb 0c                	jmp    801257 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80124b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801252:	e8 64 fb ff ff       	call   800dbb <sys_ipc_recv>
	}
	if (r < 0)
  801257:	85 c0                	test   %eax,%eax
  801259:	79 16                	jns    801271 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80125b:	85 db                	test   %ebx,%ebx
  80125d:	74 06                	je     801265 <ipc_recv+0x39>
  80125f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  801265:	85 f6                	test   %esi,%esi
  801267:	74 2c                	je     801295 <ipc_recv+0x69>
  801269:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80126f:	eb 24                	jmp    801295 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  801271:	85 db                	test   %ebx,%ebx
  801273:	74 0a                	je     80127f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  801275:	a1 08 40 80 00       	mov    0x804008,%eax
  80127a:	8b 40 74             	mov    0x74(%eax),%eax
  80127d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80127f:	85 f6                	test   %esi,%esi
  801281:	74 0a                	je     80128d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  801283:	a1 08 40 80 00       	mov    0x804008,%eax
  801288:	8b 40 78             	mov    0x78(%eax),%eax
  80128b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80128d:	a1 08 40 80 00       	mov    0x804008,%eax
  801292:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	5b                   	pop    %ebx
  801299:	5e                   	pop    %esi
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	57                   	push   %edi
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 1c             	sub    $0x1c,%esp
  8012a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8012ae:	85 db                	test   %ebx,%ebx
  8012b0:	74 19                	je     8012cb <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8012b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012c1:	89 34 24             	mov    %esi,(%esp)
  8012c4:	e8 cf fa ff ff       	call   800d98 <sys_ipc_try_send>
  8012c9:	eb 1c                	jmp    8012e7 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8012cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012d2:	00 
  8012d3:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8012da:	ee 
  8012db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012df:	89 34 24             	mov    %esi,(%esp)
  8012e2:	e8 b1 fa ff ff       	call   800d98 <sys_ipc_try_send>
		}
		if (r == 0)
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	74 2c                	je     801317 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8012eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012ee:	74 20                	je     801310 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8012f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f4:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  8012fb:	00 
  8012fc:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801303:	00 
  801304:	c7 04 24 b3 2d 80 00 	movl   $0x802db3,(%esp)
  80130b:	e8 f8 12 00 00       	call   802608 <_panic>
		}
		sys_yield();
  801310:	e8 71 f8 ff ff       	call   800b86 <sys_yield>
	}
  801315:	eb 97                	jmp    8012ae <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801317:	83 c4 1c             	add    $0x1c,%esp
  80131a:	5b                   	pop    %ebx
  80131b:	5e                   	pop    %esi
  80131c:	5f                   	pop    %edi
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    

0080131f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	53                   	push   %ebx
  801323:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801326:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80132b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801332:	89 c2                	mov    %eax,%edx
  801334:	c1 e2 07             	shl    $0x7,%edx
  801337:	29 ca                	sub    %ecx,%edx
  801339:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80133f:	8b 52 50             	mov    0x50(%edx),%edx
  801342:	39 da                	cmp    %ebx,%edx
  801344:	75 0f                	jne    801355 <ipc_find_env+0x36>
			return envs[i].env_id;
  801346:	c1 e0 07             	shl    $0x7,%eax
  801349:	29 c8                	sub    %ecx,%eax
  80134b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801350:	8b 40 40             	mov    0x40(%eax),%eax
  801353:	eb 0c                	jmp    801361 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801355:	40                   	inc    %eax
  801356:	3d 00 04 00 00       	cmp    $0x400,%eax
  80135b:	75 ce                	jne    80132b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80135d:	66 b8 00 00          	mov    $0x0,%ax
}
  801361:	5b                   	pop    %ebx
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    

00801364 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801367:	8b 45 08             	mov    0x8(%ebp),%eax
  80136a:	05 00 00 00 30       	add    $0x30000000,%eax
  80136f:	c1 e8 0c             	shr    $0xc,%eax
}
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	89 04 24             	mov    %eax,(%esp)
  801380:	e8 df ff ff ff       	call   801364 <fd2num>
  801385:	c1 e0 0c             	shl    $0xc,%eax
  801388:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	53                   	push   %ebx
  801393:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801396:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80139b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80139d:	89 c2                	mov    %eax,%edx
  80139f:	c1 ea 16             	shr    $0x16,%edx
  8013a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a9:	f6 c2 01             	test   $0x1,%dl
  8013ac:	74 11                	je     8013bf <fd_alloc+0x30>
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	c1 ea 0c             	shr    $0xc,%edx
  8013b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ba:	f6 c2 01             	test   $0x1,%dl
  8013bd:	75 09                	jne    8013c8 <fd_alloc+0x39>
			*fd_store = fd;
  8013bf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c6:	eb 17                	jmp    8013df <fd_alloc+0x50>
  8013c8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013cd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013d2:	75 c7                	jne    80139b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013da:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013df:	5b                   	pop    %ebx
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013e8:	83 f8 1f             	cmp    $0x1f,%eax
  8013eb:	77 36                	ja     801423 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ed:	c1 e0 0c             	shl    $0xc,%eax
  8013f0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	c1 ea 16             	shr    $0x16,%edx
  8013fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801401:	f6 c2 01             	test   $0x1,%dl
  801404:	74 24                	je     80142a <fd_lookup+0x48>
  801406:	89 c2                	mov    %eax,%edx
  801408:	c1 ea 0c             	shr    $0xc,%edx
  80140b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801412:	f6 c2 01             	test   $0x1,%dl
  801415:	74 1a                	je     801431 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801417:	8b 55 0c             	mov    0xc(%ebp),%edx
  80141a:	89 02                	mov    %eax,(%edx)
	return 0;
  80141c:	b8 00 00 00 00       	mov    $0x0,%eax
  801421:	eb 13                	jmp    801436 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801428:	eb 0c                	jmp    801436 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80142a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142f:	eb 05                	jmp    801436 <fd_lookup+0x54>
  801431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	53                   	push   %ebx
  80143c:	83 ec 14             	sub    $0x14,%esp
  80143f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801442:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801445:	ba 00 00 00 00       	mov    $0x0,%edx
  80144a:	eb 0e                	jmp    80145a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80144c:	39 08                	cmp    %ecx,(%eax)
  80144e:	75 09                	jne    801459 <dev_lookup+0x21>
			*dev = devtab[i];
  801450:	89 03                	mov    %eax,(%ebx)
			return 0;
  801452:	b8 00 00 00 00       	mov    $0x0,%eax
  801457:	eb 33                	jmp    80148c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801459:	42                   	inc    %edx
  80145a:	8b 04 95 3c 2e 80 00 	mov    0x802e3c(,%edx,4),%eax
  801461:	85 c0                	test   %eax,%eax
  801463:	75 e7                	jne    80144c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801465:	a1 08 40 80 00       	mov    0x804008,%eax
  80146a:	8b 40 48             	mov    0x48(%eax),%eax
  80146d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801471:	89 44 24 04          	mov    %eax,0x4(%esp)
  801475:	c7 04 24 c0 2d 80 00 	movl   $0x802dc0,(%esp)
  80147c:	e8 87 ed ff ff       	call   800208 <cprintf>
	*dev = 0;
  801481:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801487:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80148c:	83 c4 14             	add    $0x14,%esp
  80148f:	5b                   	pop    %ebx
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	56                   	push   %esi
  801496:	53                   	push   %ebx
  801497:	83 ec 30             	sub    $0x30,%esp
  80149a:	8b 75 08             	mov    0x8(%ebp),%esi
  80149d:	8a 45 0c             	mov    0xc(%ebp),%al
  8014a0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014a3:	89 34 24             	mov    %esi,(%esp)
  8014a6:	e8 b9 fe ff ff       	call   801364 <fd2num>
  8014ab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014b2:	89 04 24             	mov    %eax,(%esp)
  8014b5:	e8 28 ff ff ff       	call   8013e2 <fd_lookup>
  8014ba:	89 c3                	mov    %eax,%ebx
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 05                	js     8014c5 <fd_close+0x33>
	    || fd != fd2)
  8014c0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014c3:	74 0d                	je     8014d2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8014c5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014c9:	75 46                	jne    801511 <fd_close+0x7f>
  8014cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d0:	eb 3f                	jmp    801511 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d9:	8b 06                	mov    (%esi),%eax
  8014db:	89 04 24             	mov    %eax,(%esp)
  8014de:	e8 55 ff ff ff       	call   801438 <dev_lookup>
  8014e3:	89 c3                	mov    %eax,%ebx
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 18                	js     801501 <fd_close+0x6f>
		if (dev->dev_close)
  8014e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ec:	8b 40 10             	mov    0x10(%eax),%eax
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	74 09                	je     8014fc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014f3:	89 34 24             	mov    %esi,(%esp)
  8014f6:	ff d0                	call   *%eax
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	eb 05                	jmp    801501 <fd_close+0x6f>
		else
			r = 0;
  8014fc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801501:	89 74 24 04          	mov    %esi,0x4(%esp)
  801505:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80150c:	e8 3b f7 ff ff       	call   800c4c <sys_page_unmap>
	return r;
}
  801511:	89 d8                	mov    %ebx,%eax
  801513:	83 c4 30             	add    $0x30,%esp
  801516:	5b                   	pop    %ebx
  801517:	5e                   	pop    %esi
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801523:	89 44 24 04          	mov    %eax,0x4(%esp)
  801527:	8b 45 08             	mov    0x8(%ebp),%eax
  80152a:	89 04 24             	mov    %eax,(%esp)
  80152d:	e8 b0 fe ff ff       	call   8013e2 <fd_lookup>
  801532:	85 c0                	test   %eax,%eax
  801534:	78 13                	js     801549 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801536:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80153d:	00 
  80153e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801541:	89 04 24             	mov    %eax,(%esp)
  801544:	e8 49 ff ff ff       	call   801492 <fd_close>
}
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <close_all>:

void
close_all(void)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	53                   	push   %ebx
  80154f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801552:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801557:	89 1c 24             	mov    %ebx,(%esp)
  80155a:	e8 bb ff ff ff       	call   80151a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80155f:	43                   	inc    %ebx
  801560:	83 fb 20             	cmp    $0x20,%ebx
  801563:	75 f2                	jne    801557 <close_all+0xc>
		close(i);
}
  801565:	83 c4 14             	add    $0x14,%esp
  801568:	5b                   	pop    %ebx
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	57                   	push   %edi
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
  801571:	83 ec 4c             	sub    $0x4c,%esp
  801574:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801577:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80157a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157e:	8b 45 08             	mov    0x8(%ebp),%eax
  801581:	89 04 24             	mov    %eax,(%esp)
  801584:	e8 59 fe ff ff       	call   8013e2 <fd_lookup>
  801589:	89 c3                	mov    %eax,%ebx
  80158b:	85 c0                	test   %eax,%eax
  80158d:	0f 88 e3 00 00 00    	js     801676 <dup+0x10b>
		return r;
	close(newfdnum);
  801593:	89 3c 24             	mov    %edi,(%esp)
  801596:	e8 7f ff ff ff       	call   80151a <close>

	newfd = INDEX2FD(newfdnum);
  80159b:	89 fe                	mov    %edi,%esi
  80159d:	c1 e6 0c             	shl    $0xc,%esi
  8015a0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015a9:	89 04 24             	mov    %eax,(%esp)
  8015ac:	e8 c3 fd ff ff       	call   801374 <fd2data>
  8015b1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015b3:	89 34 24             	mov    %esi,(%esp)
  8015b6:	e8 b9 fd ff ff       	call   801374 <fd2data>
  8015bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015be:	89 d8                	mov    %ebx,%eax
  8015c0:	c1 e8 16             	shr    $0x16,%eax
  8015c3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ca:	a8 01                	test   $0x1,%al
  8015cc:	74 46                	je     801614 <dup+0xa9>
  8015ce:	89 d8                	mov    %ebx,%eax
  8015d0:	c1 e8 0c             	shr    $0xc,%eax
  8015d3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015da:	f6 c2 01             	test   $0x1,%dl
  8015dd:	74 35                	je     801614 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8015eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015fd:	00 
  8015fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801602:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801609:	e8 eb f5 ff ff       	call   800bf9 <sys_page_map>
  80160e:	89 c3                	mov    %eax,%ebx
  801610:	85 c0                	test   %eax,%eax
  801612:	78 3b                	js     80164f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801617:	89 c2                	mov    %eax,%edx
  801619:	c1 ea 0c             	shr    $0xc,%edx
  80161c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801623:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801629:	89 54 24 10          	mov    %edx,0x10(%esp)
  80162d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801631:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801638:	00 
  801639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801644:	e8 b0 f5 ff ff       	call   800bf9 <sys_page_map>
  801649:	89 c3                	mov    %eax,%ebx
  80164b:	85 c0                	test   %eax,%eax
  80164d:	79 25                	jns    801674 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80164f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801653:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165a:	e8 ed f5 ff ff       	call   800c4c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80165f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801662:	89 44 24 04          	mov    %eax,0x4(%esp)
  801666:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166d:	e8 da f5 ff ff       	call   800c4c <sys_page_unmap>
	return r;
  801672:	eb 02                	jmp    801676 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801674:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801676:	89 d8                	mov    %ebx,%eax
  801678:	83 c4 4c             	add    $0x4c,%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5f                   	pop    %edi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	53                   	push   %ebx
  801684:	83 ec 24             	sub    $0x24,%esp
  801687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801691:	89 1c 24             	mov    %ebx,(%esp)
  801694:	e8 49 fd ff ff       	call   8013e2 <fd_lookup>
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 6d                	js     80170a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a7:	8b 00                	mov    (%eax),%eax
  8016a9:	89 04 24             	mov    %eax,(%esp)
  8016ac:	e8 87 fd ff ff       	call   801438 <dev_lookup>
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 55                	js     80170a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b8:	8b 50 08             	mov    0x8(%eax),%edx
  8016bb:	83 e2 03             	and    $0x3,%edx
  8016be:	83 fa 01             	cmp    $0x1,%edx
  8016c1:	75 23                	jne    8016e6 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8016c8:	8b 40 48             	mov    0x48(%eax),%eax
  8016cb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d3:	c7 04 24 01 2e 80 00 	movl   $0x802e01,(%esp)
  8016da:	e8 29 eb ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  8016df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e4:	eb 24                	jmp    80170a <read+0x8a>
	}
	if (!dev->dev_read)
  8016e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e9:	8b 52 08             	mov    0x8(%edx),%edx
  8016ec:	85 d2                	test   %edx,%edx
  8016ee:	74 15                	je     801705 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016fe:	89 04 24             	mov    %eax,(%esp)
  801701:	ff d2                	call   *%edx
  801703:	eb 05                	jmp    80170a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801705:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80170a:	83 c4 24             	add    $0x24,%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	57                   	push   %edi
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
  801716:	83 ec 1c             	sub    $0x1c,%esp
  801719:	8b 7d 08             	mov    0x8(%ebp),%edi
  80171c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80171f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801724:	eb 23                	jmp    801749 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801726:	89 f0                	mov    %esi,%eax
  801728:	29 d8                	sub    %ebx,%eax
  80172a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80172e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801731:	01 d8                	add    %ebx,%eax
  801733:	89 44 24 04          	mov    %eax,0x4(%esp)
  801737:	89 3c 24             	mov    %edi,(%esp)
  80173a:	e8 41 ff ff ff       	call   801680 <read>
		if (m < 0)
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 10                	js     801753 <readn+0x43>
			return m;
		if (m == 0)
  801743:	85 c0                	test   %eax,%eax
  801745:	74 0a                	je     801751 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801747:	01 c3                	add    %eax,%ebx
  801749:	39 f3                	cmp    %esi,%ebx
  80174b:	72 d9                	jb     801726 <readn+0x16>
  80174d:	89 d8                	mov    %ebx,%eax
  80174f:	eb 02                	jmp    801753 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801751:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801753:	83 c4 1c             	add    $0x1c,%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5f                   	pop    %edi
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    

0080175b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	53                   	push   %ebx
  80175f:	83 ec 24             	sub    $0x24,%esp
  801762:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801765:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176c:	89 1c 24             	mov    %ebx,(%esp)
  80176f:	e8 6e fc ff ff       	call   8013e2 <fd_lookup>
  801774:	85 c0                	test   %eax,%eax
  801776:	78 68                	js     8017e0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801778:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801782:	8b 00                	mov    (%eax),%eax
  801784:	89 04 24             	mov    %eax,(%esp)
  801787:	e8 ac fc ff ff       	call   801438 <dev_lookup>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 50                	js     8017e0 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801790:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801793:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801797:	75 23                	jne    8017bc <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801799:	a1 08 40 80 00       	mov    0x804008,%eax
  80179e:	8b 40 48             	mov    0x48(%eax),%eax
  8017a1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a9:	c7 04 24 1d 2e 80 00 	movl   $0x802e1d,(%esp)
  8017b0:	e8 53 ea ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  8017b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ba:	eb 24                	jmp    8017e0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c2:	85 d2                	test   %edx,%edx
  8017c4:	74 15                	je     8017db <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017d4:	89 04 24             	mov    %eax,(%esp)
  8017d7:	ff d2                	call   *%edx
  8017d9:	eb 05                	jmp    8017e0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017e0:	83 c4 24             	add    $0x24,%esp
  8017e3:	5b                   	pop    %ebx
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	89 04 24             	mov    %eax,(%esp)
  8017f9:	e8 e4 fb ff ff       	call   8013e2 <fd_lookup>
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 0e                	js     801810 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801802:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801805:	8b 55 0c             	mov    0xc(%ebp),%edx
  801808:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80180b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	53                   	push   %ebx
  801816:	83 ec 24             	sub    $0x24,%esp
  801819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	89 1c 24             	mov    %ebx,(%esp)
  801826:	e8 b7 fb ff ff       	call   8013e2 <fd_lookup>
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 61                	js     801890 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	89 44 24 04          	mov    %eax,0x4(%esp)
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	8b 00                	mov    (%eax),%eax
  80183b:	89 04 24             	mov    %eax,(%esp)
  80183e:	e8 f5 fb ff ff       	call   801438 <dev_lookup>
  801843:	85 c0                	test   %eax,%eax
  801845:	78 49                	js     801890 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80184e:	75 23                	jne    801873 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801850:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801855:	8b 40 48             	mov    0x48(%eax),%eax
  801858:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80185c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801860:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  801867:	e8 9c e9 ff ff       	call   800208 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80186c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801871:	eb 1d                	jmp    801890 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801873:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801876:	8b 52 18             	mov    0x18(%edx),%edx
  801879:	85 d2                	test   %edx,%edx
  80187b:	74 0e                	je     80188b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80187d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801880:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801884:	89 04 24             	mov    %eax,(%esp)
  801887:	ff d2                	call   *%edx
  801889:	eb 05                	jmp    801890 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80188b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801890:	83 c4 24             	add    $0x24,%esp
  801893:	5b                   	pop    %ebx
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	53                   	push   %ebx
  80189a:	83 ec 24             	sub    $0x24,%esp
  80189d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	89 04 24             	mov    %eax,(%esp)
  8018ad:	e8 30 fb ff ff       	call   8013e2 <fd_lookup>
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	78 52                	js     801908 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c0:	8b 00                	mov    (%eax),%eax
  8018c2:	89 04 24             	mov    %eax,(%esp)
  8018c5:	e8 6e fb ff ff       	call   801438 <dev_lookup>
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 3a                	js     801908 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018d5:	74 2c                	je     801903 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018d7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018da:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018e1:	00 00 00 
	stat->st_isdir = 0;
  8018e4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018eb:	00 00 00 
	stat->st_dev = dev;
  8018ee:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018fb:	89 14 24             	mov    %edx,(%esp)
  8018fe:	ff 50 14             	call   *0x14(%eax)
  801901:	eb 05                	jmp    801908 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801903:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801908:	83 c4 24             	add    $0x24,%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801916:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80191d:	00 
  80191e:	8b 45 08             	mov    0x8(%ebp),%eax
  801921:	89 04 24             	mov    %eax,(%esp)
  801924:	e8 2a 02 00 00       	call   801b53 <open>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 1b                	js     80194a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80192f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801932:	89 44 24 04          	mov    %eax,0x4(%esp)
  801936:	89 1c 24             	mov    %ebx,(%esp)
  801939:	e8 58 ff ff ff       	call   801896 <fstat>
  80193e:	89 c6                	mov    %eax,%esi
	close(fd);
  801940:	89 1c 24             	mov    %ebx,(%esp)
  801943:	e8 d2 fb ff ff       	call   80151a <close>
	return r;
  801948:	89 f3                	mov    %esi,%ebx
}
  80194a:	89 d8                	mov    %ebx,%eax
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5d                   	pop    %ebp
  801952:	c3                   	ret    
	...

00801954 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	56                   	push   %esi
  801958:	53                   	push   %ebx
  801959:	83 ec 10             	sub    $0x10,%esp
  80195c:	89 c3                	mov    %eax,%ebx
  80195e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801960:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801967:	75 11                	jne    80197a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801969:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801970:	e8 aa f9 ff ff       	call   80131f <ipc_find_env>
  801975:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80197a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801981:	00 
  801982:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801989:	00 
  80198a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198e:	a1 00 40 80 00       	mov    0x804000,%eax
  801993:	89 04 24             	mov    %eax,(%esp)
  801996:	e8 01 f9 ff ff       	call   80129c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80199b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019a2:	00 
  8019a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ae:	e8 79 f8 ff ff       	call   80122c <ipc_recv>
}
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ce:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d8:	b8 02 00 00 00       	mov    $0x2,%eax
  8019dd:	e8 72 ff ff ff       	call   801954 <fsipc>
}
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ff:	e8 50 ff ff ff       	call   801954 <fsipc>
}
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	53                   	push   %ebx
  801a0a:	83 ec 14             	sub    $0x14,%esp
  801a0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	8b 40 0c             	mov    0xc(%eax),%eax
  801a16:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a20:	b8 05 00 00 00       	mov    $0x5,%eax
  801a25:	e8 2a ff ff ff       	call   801954 <fsipc>
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 2b                	js     801a59 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a2e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a35:	00 
  801a36:	89 1c 24             	mov    %ebx,(%esp)
  801a39:	e8 75 ed ff ff       	call   8007b3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a3e:	a1 80 50 80 00       	mov    0x805080,%eax
  801a43:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a49:	a1 84 50 80 00       	mov    0x805084,%eax
  801a4e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a59:	83 c4 14             	add    $0x14,%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 18             	sub    $0x18,%esp
  801a65:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a68:	8b 55 08             	mov    0x8(%ebp),%edx
  801a6b:	8b 52 0c             	mov    0xc(%edx),%edx
  801a6e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a74:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801a79:	89 c2                	mov    %eax,%edx
  801a7b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a80:	76 05                	jbe    801a87 <devfile_write+0x28>
  801a82:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801a87:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a92:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801a99:	e8 f8 ee ff ff       	call   800996 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801a9e:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa3:	b8 04 00 00 00       	mov    $0x4,%eax
  801aa8:	e8 a7 fe ff ff       	call   801954 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	83 ec 10             	sub    $0x10,%esp
  801ab7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ac5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801acb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad0:	b8 03 00 00 00       	mov    $0x3,%eax
  801ad5:	e8 7a fe ff ff       	call   801954 <fsipc>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 6a                	js     801b4a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ae0:	39 c6                	cmp    %eax,%esi
  801ae2:	73 24                	jae    801b08 <devfile_read+0x59>
  801ae4:	c7 44 24 0c 50 2e 80 	movl   $0x802e50,0xc(%esp)
  801aeb:	00 
  801aec:	c7 44 24 08 57 2e 80 	movl   $0x802e57,0x8(%esp)
  801af3:	00 
  801af4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801afb:	00 
  801afc:	c7 04 24 6c 2e 80 00 	movl   $0x802e6c,(%esp)
  801b03:	e8 00 0b 00 00       	call   802608 <_panic>
	assert(r <= PGSIZE);
  801b08:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b0d:	7e 24                	jle    801b33 <devfile_read+0x84>
  801b0f:	c7 44 24 0c 77 2e 80 	movl   $0x802e77,0xc(%esp)
  801b16:	00 
  801b17:	c7 44 24 08 57 2e 80 	movl   $0x802e57,0x8(%esp)
  801b1e:	00 
  801b1f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b26:	00 
  801b27:	c7 04 24 6c 2e 80 00 	movl   $0x802e6c,(%esp)
  801b2e:	e8 d5 0a 00 00       	call   802608 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b37:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b3e:	00 
  801b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b42:	89 04 24             	mov    %eax,(%esp)
  801b45:	e8 e2 ed ff ff       	call   80092c <memmove>
	return r;
}
  801b4a:	89 d8                	mov    %ebx,%eax
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5e                   	pop    %esi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	83 ec 20             	sub    $0x20,%esp
  801b5b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b5e:	89 34 24             	mov    %esi,(%esp)
  801b61:	e8 1a ec ff ff       	call   800780 <strlen>
  801b66:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b6b:	7f 60                	jg     801bcd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b70:	89 04 24             	mov    %eax,(%esp)
  801b73:	e8 17 f8 ff ff       	call   80138f <fd_alloc>
  801b78:	89 c3                	mov    %eax,%ebx
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 54                	js     801bd2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b7e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b82:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b89:	e8 25 ec ff ff       	call   8007b3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b91:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b99:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9e:	e8 b1 fd ff ff       	call   801954 <fsipc>
  801ba3:	89 c3                	mov    %eax,%ebx
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	79 15                	jns    801bbe <open+0x6b>
		fd_close(fd, 0);
  801ba9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bb0:	00 
  801bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb4:	89 04 24             	mov    %eax,(%esp)
  801bb7:	e8 d6 f8 ff ff       	call   801492 <fd_close>
		return r;
  801bbc:	eb 14                	jmp    801bd2 <open+0x7f>
	}

	return fd2num(fd);
  801bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc1:	89 04 24             	mov    %eax,(%esp)
  801bc4:	e8 9b f7 ff ff       	call   801364 <fd2num>
  801bc9:	89 c3                	mov    %eax,%ebx
  801bcb:	eb 05                	jmp    801bd2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bcd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bd2:	89 d8                	mov    %ebx,%eax
  801bd4:	83 c4 20             	add    $0x20,%esp
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801be1:	ba 00 00 00 00       	mov    $0x0,%edx
  801be6:	b8 08 00 00 00       	mov    $0x8,%eax
  801beb:	e8 64 fd ff ff       	call   801954 <fsipc>
}
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    
	...

00801bf4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801bfa:	c7 44 24 04 83 2e 80 	movl   $0x802e83,0x4(%esp)
  801c01:	00 
  801c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c05:	89 04 24             	mov    %eax,(%esp)
  801c08:	e8 a6 eb ff ff       	call   8007b3 <strcpy>
	return 0;
}
  801c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	53                   	push   %ebx
  801c18:	83 ec 14             	sub    $0x14,%esp
  801c1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c1e:	89 1c 24             	mov    %ebx,(%esp)
  801c21:	e8 ae 0a 00 00       	call   8026d4 <pageref>
  801c26:	83 f8 01             	cmp    $0x1,%eax
  801c29:	75 0d                	jne    801c38 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801c2b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c2e:	89 04 24             	mov    %eax,(%esp)
  801c31:	e8 1f 03 00 00       	call   801f55 <nsipc_close>
  801c36:	eb 05                	jmp    801c3d <devsock_close+0x29>
	else
		return 0;
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3d:	83 c4 14             	add    $0x14,%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c49:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c50:	00 
  801c51:	8b 45 10             	mov    0x10(%ebp),%eax
  801c54:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c62:	8b 40 0c             	mov    0xc(%eax),%eax
  801c65:	89 04 24             	mov    %eax,(%esp)
  801c68:	e8 e3 03 00 00       	call   802050 <nsipc_send>
}
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c7c:	00 
  801c7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c91:	89 04 24             	mov    %eax,(%esp)
  801c94:	e8 37 03 00 00       	call   801fd0 <nsipc_recv>
}
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	56                   	push   %esi
  801c9f:	53                   	push   %ebx
  801ca0:	83 ec 20             	sub    $0x20,%esp
  801ca3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ca5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca8:	89 04 24             	mov    %eax,(%esp)
  801cab:	e8 df f6 ff ff       	call   80138f <fd_alloc>
  801cb0:	89 c3                	mov    %eax,%ebx
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 21                	js     801cd7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cb6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cbd:	00 
  801cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ccc:	e8 d4 ee ff ff       	call   800ba5 <sys_page_alloc>
  801cd1:	89 c3                	mov    %eax,%ebx
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	79 0a                	jns    801ce1 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801cd7:	89 34 24             	mov    %esi,(%esp)
  801cda:	e8 76 02 00 00       	call   801f55 <nsipc_close>
		return r;
  801cdf:	eb 22                	jmp    801d03 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ce1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cea:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cf6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801cf9:	89 04 24             	mov    %eax,(%esp)
  801cfc:	e8 63 f6 ff ff       	call   801364 <fd2num>
  801d01:	89 c3                	mov    %eax,%ebx
}
  801d03:	89 d8                	mov    %ebx,%eax
  801d05:	83 c4 20             	add    $0x20,%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5e                   	pop    %esi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d12:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d15:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d19:	89 04 24             	mov    %eax,(%esp)
  801d1c:	e8 c1 f6 ff ff       	call   8013e2 <fd_lookup>
  801d21:	85 c0                	test   %eax,%eax
  801d23:	78 17                	js     801d3c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d28:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d2e:	39 10                	cmp    %edx,(%eax)
  801d30:	75 05                	jne    801d37 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d32:	8b 40 0c             	mov    0xc(%eax),%eax
  801d35:	eb 05                	jmp    801d3c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d37:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    

00801d3e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d44:	8b 45 08             	mov    0x8(%ebp),%eax
  801d47:	e8 c0 ff ff ff       	call   801d0c <fd2sockid>
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 1f                	js     801d6f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d50:	8b 55 10             	mov    0x10(%ebp),%edx
  801d53:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d5e:	89 04 24             	mov    %eax,(%esp)
  801d61:	e8 38 01 00 00       	call   801e9e <nsipc_accept>
  801d66:	85 c0                	test   %eax,%eax
  801d68:	78 05                	js     801d6f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d6a:	e8 2c ff ff ff       	call   801c9b <alloc_sockfd>
}
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    

00801d71 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d77:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7a:	e8 8d ff ff ff       	call   801d0c <fd2sockid>
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 16                	js     801d99 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801d83:	8b 55 10             	mov    0x10(%ebp),%edx
  801d86:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d91:	89 04 24             	mov    %eax,(%esp)
  801d94:	e8 5b 01 00 00       	call   801ef4 <nsipc_bind>
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <shutdown>:

int
shutdown(int s, int how)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801da1:	8b 45 08             	mov    0x8(%ebp),%eax
  801da4:	e8 63 ff ff ff       	call   801d0c <fd2sockid>
  801da9:	85 c0                	test   %eax,%eax
  801dab:	78 0f                	js     801dbc <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801dad:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db0:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db4:	89 04 24             	mov    %eax,(%esp)
  801db7:	e8 77 01 00 00       	call   801f33 <nsipc_shutdown>
}
  801dbc:	c9                   	leave  
  801dbd:	c3                   	ret    

00801dbe <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc7:	e8 40 ff ff ff       	call   801d0c <fd2sockid>
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	78 16                	js     801de6 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801dd0:	8b 55 10             	mov    0x10(%ebp),%edx
  801dd3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dda:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dde:	89 04 24             	mov    %eax,(%esp)
  801de1:	e8 89 01 00 00       	call   801f6f <nsipc_connect>
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <listen>:

int
listen(int s, int backlog)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dee:	8b 45 08             	mov    0x8(%ebp),%eax
  801df1:	e8 16 ff ff ff       	call   801d0c <fd2sockid>
  801df6:	85 c0                	test   %eax,%eax
  801df8:	78 0f                	js     801e09 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801dfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e01:	89 04 24             	mov    %eax,(%esp)
  801e04:	e8 a5 01 00 00       	call   801fae <nsipc_listen>
}
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    

00801e0b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e11:	8b 45 10             	mov    0x10(%ebp),%eax
  801e14:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	89 04 24             	mov    %eax,(%esp)
  801e25:	e8 99 02 00 00       	call   8020c3 <nsipc_socket>
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 05                	js     801e33 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801e2e:	e8 68 fe ff ff       	call   801c9b <alloc_sockfd>
}
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    
  801e35:	00 00                	add    %al,(%eax)
	...

00801e38 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	53                   	push   %ebx
  801e3c:	83 ec 14             	sub    $0x14,%esp
  801e3f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e41:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e48:	75 11                	jne    801e5b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e4a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801e51:	e8 c9 f4 ff ff       	call   80131f <ipc_find_env>
  801e56:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e5b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e62:	00 
  801e63:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801e6a:	00 
  801e6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e6f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e74:	89 04 24             	mov    %eax,(%esp)
  801e77:	e8 20 f4 ff ff       	call   80129c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e83:	00 
  801e84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e8b:	00 
  801e8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e93:	e8 94 f3 ff ff       	call   80122c <ipc_recv>
}
  801e98:	83 c4 14             	add    $0x14,%esp
  801e9b:	5b                   	pop    %ebx
  801e9c:	5d                   	pop    %ebp
  801e9d:	c3                   	ret    

00801e9e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	56                   	push   %esi
  801ea2:	53                   	push   %ebx
  801ea3:	83 ec 10             	sub    $0x10,%esp
  801ea6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  801eac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801eb1:	8b 06                	mov    (%esi),%eax
  801eb3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801eb8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebd:	e8 76 ff ff ff       	call   801e38 <nsipc>
  801ec2:	89 c3                	mov    %eax,%ebx
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 23                	js     801eeb <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ec8:	a1 10 60 80 00       	mov    0x806010,%eax
  801ecd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ed1:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ed8:	00 
  801ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edc:	89 04 24             	mov    %eax,(%esp)
  801edf:	e8 48 ea ff ff       	call   80092c <memmove>
		*addrlen = ret->ret_addrlen;
  801ee4:	a1 10 60 80 00       	mov    0x806010,%eax
  801ee9:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801eeb:	89 d8                	mov    %ebx,%eax
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5e                   	pop    %esi
  801ef2:	5d                   	pop    %ebp
  801ef3:	c3                   	ret    

00801ef4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	53                   	push   %ebx
  801ef8:	83 ec 14             	sub    $0x14,%esp
  801efb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801efe:	8b 45 08             	mov    0x8(%ebp),%eax
  801f01:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f06:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f11:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f18:	e8 0f ea ff ff       	call   80092c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f1d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f23:	b8 02 00 00 00       	mov    $0x2,%eax
  801f28:	e8 0b ff ff ff       	call   801e38 <nsipc>
}
  801f2d:	83 c4 14             	add    $0x14,%esp
  801f30:	5b                   	pop    %ebx
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    

00801f33 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f39:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f44:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f49:	b8 03 00 00 00       	mov    $0x3,%eax
  801f4e:	e8 e5 fe ff ff       	call   801e38 <nsipc>
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <nsipc_close>:

int
nsipc_close(int s)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f63:	b8 04 00 00 00       	mov    $0x4,%eax
  801f68:	e8 cb fe ff ff       	call   801e38 <nsipc>
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	53                   	push   %ebx
  801f73:	83 ec 14             	sub    $0x14,%esp
  801f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f79:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f81:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f93:	e8 94 e9 ff ff       	call   80092c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f98:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f9e:	b8 05 00 00 00       	mov    $0x5,%eax
  801fa3:	e8 90 fe ff ff       	call   801e38 <nsipc>
}
  801fa8:	83 c4 14             	add    $0x14,%esp
  801fab:	5b                   	pop    %ebx
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    

00801fae <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fbf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801fc4:	b8 06 00 00 00       	mov    $0x6,%eax
  801fc9:	e8 6a fe ff ff       	call   801e38 <nsipc>
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	56                   	push   %esi
  801fd4:	53                   	push   %ebx
  801fd5:	83 ec 10             	sub    $0x10,%esp
  801fd8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801fe3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801fe9:	8b 45 14             	mov    0x14(%ebp),%eax
  801fec:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ff1:	b8 07 00 00 00       	mov    $0x7,%eax
  801ff6:	e8 3d fe ff ff       	call   801e38 <nsipc>
  801ffb:	89 c3                	mov    %eax,%ebx
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 46                	js     802047 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802001:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802006:	7f 04                	jg     80200c <nsipc_recv+0x3c>
  802008:	39 c6                	cmp    %eax,%esi
  80200a:	7d 24                	jge    802030 <nsipc_recv+0x60>
  80200c:	c7 44 24 0c 8f 2e 80 	movl   $0x802e8f,0xc(%esp)
  802013:	00 
  802014:	c7 44 24 08 57 2e 80 	movl   $0x802e57,0x8(%esp)
  80201b:	00 
  80201c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802023:	00 
  802024:	c7 04 24 a4 2e 80 00 	movl   $0x802ea4,(%esp)
  80202b:	e8 d8 05 00 00       	call   802608 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802030:	89 44 24 08          	mov    %eax,0x8(%esp)
  802034:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80203b:	00 
  80203c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203f:	89 04 24             	mov    %eax,(%esp)
  802042:	e8 e5 e8 ff ff       	call   80092c <memmove>
	}

	return r;
}
  802047:	89 d8                	mov    %ebx,%eax
  802049:	83 c4 10             	add    $0x10,%esp
  80204c:	5b                   	pop    %ebx
  80204d:	5e                   	pop    %esi
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    

00802050 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	53                   	push   %ebx
  802054:	83 ec 14             	sub    $0x14,%esp
  802057:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80205a:	8b 45 08             	mov    0x8(%ebp),%eax
  80205d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802062:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802068:	7e 24                	jle    80208e <nsipc_send+0x3e>
  80206a:	c7 44 24 0c b0 2e 80 	movl   $0x802eb0,0xc(%esp)
  802071:	00 
  802072:	c7 44 24 08 57 2e 80 	movl   $0x802e57,0x8(%esp)
  802079:	00 
  80207a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802081:	00 
  802082:	c7 04 24 a4 2e 80 00 	movl   $0x802ea4,(%esp)
  802089:	e8 7a 05 00 00       	call   802608 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80208e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802092:	8b 45 0c             	mov    0xc(%ebp),%eax
  802095:	89 44 24 04          	mov    %eax,0x4(%esp)
  802099:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8020a0:	e8 87 e8 ff ff       	call   80092c <memmove>
	nsipcbuf.send.req_size = size;
  8020a5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ae:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020b3:	b8 08 00 00 00       	mov    $0x8,%eax
  8020b8:	e8 7b fd ff ff       	call   801e38 <nsipc>
}
  8020bd:	83 c4 14             	add    $0x14,%esp
  8020c0:	5b                   	pop    %ebx
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    

008020c3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020c3:	55                   	push   %ebp
  8020c4:	89 e5                	mov    %esp,%ebp
  8020c6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8020dc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020e1:	b8 09 00 00 00       	mov    $0x9,%eax
  8020e6:	e8 4d fd ff ff       	call   801e38 <nsipc>
}
  8020eb:	c9                   	leave  
  8020ec:	c3                   	ret    
  8020ed:	00 00                	add    %al,(%eax)
	...

008020f0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	56                   	push   %esi
  8020f4:	53                   	push   %ebx
  8020f5:	83 ec 10             	sub    $0x10,%esp
  8020f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fe:	89 04 24             	mov    %eax,(%esp)
  802101:	e8 6e f2 ff ff       	call   801374 <fd2data>
  802106:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802108:	c7 44 24 04 bc 2e 80 	movl   $0x802ebc,0x4(%esp)
  80210f:	00 
  802110:	89 34 24             	mov    %esi,(%esp)
  802113:	e8 9b e6 ff ff       	call   8007b3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802118:	8b 43 04             	mov    0x4(%ebx),%eax
  80211b:	2b 03                	sub    (%ebx),%eax
  80211d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802123:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80212a:	00 00 00 
	stat->st_dev = &devpipe;
  80212d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  802134:	30 80 00 
	return 0;
}
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    

00802143 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	53                   	push   %ebx
  802147:	83 ec 14             	sub    $0x14,%esp
  80214a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80214d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802151:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802158:	e8 ef ea ff ff       	call   800c4c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80215d:	89 1c 24             	mov    %ebx,(%esp)
  802160:	e8 0f f2 ff ff       	call   801374 <fd2data>
  802165:	89 44 24 04          	mov    %eax,0x4(%esp)
  802169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802170:	e8 d7 ea ff ff       	call   800c4c <sys_page_unmap>
}
  802175:	83 c4 14             	add    $0x14,%esp
  802178:	5b                   	pop    %ebx
  802179:	5d                   	pop    %ebp
  80217a:	c3                   	ret    

0080217b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80217b:	55                   	push   %ebp
  80217c:	89 e5                	mov    %esp,%ebp
  80217e:	57                   	push   %edi
  80217f:	56                   	push   %esi
  802180:	53                   	push   %ebx
  802181:	83 ec 2c             	sub    $0x2c,%esp
  802184:	89 c7                	mov    %eax,%edi
  802186:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802189:	a1 08 40 80 00       	mov    0x804008,%eax
  80218e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802191:	89 3c 24             	mov    %edi,(%esp)
  802194:	e8 3b 05 00 00       	call   8026d4 <pageref>
  802199:	89 c6                	mov    %eax,%esi
  80219b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80219e:	89 04 24             	mov    %eax,(%esp)
  8021a1:	e8 2e 05 00 00       	call   8026d4 <pageref>
  8021a6:	39 c6                	cmp    %eax,%esi
  8021a8:	0f 94 c0             	sete   %al
  8021ab:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021ae:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8021b4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021b7:	39 cb                	cmp    %ecx,%ebx
  8021b9:	75 08                	jne    8021c3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8021bb:	83 c4 2c             	add    $0x2c,%esp
  8021be:	5b                   	pop    %ebx
  8021bf:	5e                   	pop    %esi
  8021c0:	5f                   	pop    %edi
  8021c1:	5d                   	pop    %ebp
  8021c2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8021c3:	83 f8 01             	cmp    $0x1,%eax
  8021c6:	75 c1                	jne    802189 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021c8:	8b 42 58             	mov    0x58(%edx),%eax
  8021cb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8021d2:	00 
  8021d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021db:	c7 04 24 c3 2e 80 00 	movl   $0x802ec3,(%esp)
  8021e2:	e8 21 e0 ff ff       	call   800208 <cprintf>
  8021e7:	eb a0                	jmp    802189 <_pipeisclosed+0xe>

008021e9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021e9:	55                   	push   %ebp
  8021ea:	89 e5                	mov    %esp,%ebp
  8021ec:	57                   	push   %edi
  8021ed:	56                   	push   %esi
  8021ee:	53                   	push   %ebx
  8021ef:	83 ec 1c             	sub    $0x1c,%esp
  8021f2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021f5:	89 34 24             	mov    %esi,(%esp)
  8021f8:	e8 77 f1 ff ff       	call   801374 <fd2data>
  8021fd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021ff:	bf 00 00 00 00       	mov    $0x0,%edi
  802204:	eb 3c                	jmp    802242 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802206:	89 da                	mov    %ebx,%edx
  802208:	89 f0                	mov    %esi,%eax
  80220a:	e8 6c ff ff ff       	call   80217b <_pipeisclosed>
  80220f:	85 c0                	test   %eax,%eax
  802211:	75 38                	jne    80224b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802213:	e8 6e e9 ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802218:	8b 43 04             	mov    0x4(%ebx),%eax
  80221b:	8b 13                	mov    (%ebx),%edx
  80221d:	83 c2 20             	add    $0x20,%edx
  802220:	39 d0                	cmp    %edx,%eax
  802222:	73 e2                	jae    802206 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802224:	8b 55 0c             	mov    0xc(%ebp),%edx
  802227:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80222a:	89 c2                	mov    %eax,%edx
  80222c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802232:	79 05                	jns    802239 <devpipe_write+0x50>
  802234:	4a                   	dec    %edx
  802235:	83 ca e0             	or     $0xffffffe0,%edx
  802238:	42                   	inc    %edx
  802239:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80223d:	40                   	inc    %eax
  80223e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802241:	47                   	inc    %edi
  802242:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802245:	75 d1                	jne    802218 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802247:	89 f8                	mov    %edi,%eax
  802249:	eb 05                	jmp    802250 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    

00802258 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	57                   	push   %edi
  80225c:	56                   	push   %esi
  80225d:	53                   	push   %ebx
  80225e:	83 ec 1c             	sub    $0x1c,%esp
  802261:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802264:	89 3c 24             	mov    %edi,(%esp)
  802267:	e8 08 f1 ff ff       	call   801374 <fd2data>
  80226c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80226e:	be 00 00 00 00       	mov    $0x0,%esi
  802273:	eb 3a                	jmp    8022af <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802275:	85 f6                	test   %esi,%esi
  802277:	74 04                	je     80227d <devpipe_read+0x25>
				return i;
  802279:	89 f0                	mov    %esi,%eax
  80227b:	eb 40                	jmp    8022bd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80227d:	89 da                	mov    %ebx,%edx
  80227f:	89 f8                	mov    %edi,%eax
  802281:	e8 f5 fe ff ff       	call   80217b <_pipeisclosed>
  802286:	85 c0                	test   %eax,%eax
  802288:	75 2e                	jne    8022b8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80228a:	e8 f7 e8 ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80228f:	8b 03                	mov    (%ebx),%eax
  802291:	3b 43 04             	cmp    0x4(%ebx),%eax
  802294:	74 df                	je     802275 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802296:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80229b:	79 05                	jns    8022a2 <devpipe_read+0x4a>
  80229d:	48                   	dec    %eax
  80229e:	83 c8 e0             	or     $0xffffffe0,%eax
  8022a1:	40                   	inc    %eax
  8022a2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022a9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022ac:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022ae:	46                   	inc    %esi
  8022af:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022b2:	75 db                	jne    80228f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022b4:	89 f0                	mov    %esi,%eax
  8022b6:	eb 05                	jmp    8022bd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022b8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022bd:	83 c4 1c             	add    $0x1c,%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	57                   	push   %edi
  8022c9:	56                   	push   %esi
  8022ca:	53                   	push   %ebx
  8022cb:	83 ec 3c             	sub    $0x3c,%esp
  8022ce:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8022d4:	89 04 24             	mov    %eax,(%esp)
  8022d7:	e8 b3 f0 ff ff       	call   80138f <fd_alloc>
  8022dc:	89 c3                	mov    %eax,%ebx
  8022de:	85 c0                	test   %eax,%eax
  8022e0:	0f 88 45 01 00 00    	js     80242b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022ed:	00 
  8022ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022fc:	e8 a4 e8 ff ff       	call   800ba5 <sys_page_alloc>
  802301:	89 c3                	mov    %eax,%ebx
  802303:	85 c0                	test   %eax,%eax
  802305:	0f 88 20 01 00 00    	js     80242b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80230b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80230e:	89 04 24             	mov    %eax,(%esp)
  802311:	e8 79 f0 ff ff       	call   80138f <fd_alloc>
  802316:	89 c3                	mov    %eax,%ebx
  802318:	85 c0                	test   %eax,%eax
  80231a:	0f 88 f8 00 00 00    	js     802418 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802320:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802327:	00 
  802328:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80232b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80232f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802336:	e8 6a e8 ff ff       	call   800ba5 <sys_page_alloc>
  80233b:	89 c3                	mov    %eax,%ebx
  80233d:	85 c0                	test   %eax,%eax
  80233f:	0f 88 d3 00 00 00    	js     802418 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802345:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802348:	89 04 24             	mov    %eax,(%esp)
  80234b:	e8 24 f0 ff ff       	call   801374 <fd2data>
  802350:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802352:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802359:	00 
  80235a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802365:	e8 3b e8 ff ff       	call   800ba5 <sys_page_alloc>
  80236a:	89 c3                	mov    %eax,%ebx
  80236c:	85 c0                	test   %eax,%eax
  80236e:	0f 88 91 00 00 00    	js     802405 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802377:	89 04 24             	mov    %eax,(%esp)
  80237a:	e8 f5 ef ff ff       	call   801374 <fd2data>
  80237f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802386:	00 
  802387:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802392:	00 
  802393:	89 74 24 04          	mov    %esi,0x4(%esp)
  802397:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80239e:	e8 56 e8 ff ff       	call   800bf9 <sys_page_map>
  8023a3:	89 c3                	mov    %eax,%ebx
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	78 4c                	js     8023f5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023a9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023b2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023be:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023c7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023cc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023d6:	89 04 24             	mov    %eax,(%esp)
  8023d9:	e8 86 ef ff ff       	call   801364 <fd2num>
  8023de:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8023e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023e3:	89 04 24             	mov    %eax,(%esp)
  8023e6:	e8 79 ef ff ff       	call   801364 <fd2num>
  8023eb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8023ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023f3:	eb 36                	jmp    80242b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8023f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802400:	e8 47 e8 ff ff       	call   800c4c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802405:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80240c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802413:	e8 34 e8 ff ff       	call   800c4c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802418:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80241b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80241f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802426:	e8 21 e8 ff ff       	call   800c4c <sys_page_unmap>
    err:
	return r;
}
  80242b:	89 d8                	mov    %ebx,%eax
  80242d:	83 c4 3c             	add    $0x3c,%esp
  802430:	5b                   	pop    %ebx
  802431:	5e                   	pop    %esi
  802432:	5f                   	pop    %edi
  802433:	5d                   	pop    %ebp
  802434:	c3                   	ret    

00802435 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802435:	55                   	push   %ebp
  802436:	89 e5                	mov    %esp,%ebp
  802438:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80243b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80243e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802442:	8b 45 08             	mov    0x8(%ebp),%eax
  802445:	89 04 24             	mov    %eax,(%esp)
  802448:	e8 95 ef ff ff       	call   8013e2 <fd_lookup>
  80244d:	85 c0                	test   %eax,%eax
  80244f:	78 15                	js     802466 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802451:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802454:	89 04 24             	mov    %eax,(%esp)
  802457:	e8 18 ef ff ff       	call   801374 <fd2data>
	return _pipeisclosed(fd, p);
  80245c:	89 c2                	mov    %eax,%edx
  80245e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802461:	e8 15 fd ff ff       	call   80217b <_pipeisclosed>
}
  802466:	c9                   	leave  
  802467:	c3                   	ret    

00802468 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80246b:	b8 00 00 00 00       	mov    $0x0,%eax
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    

00802472 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802472:	55                   	push   %ebp
  802473:	89 e5                	mov    %esp,%ebp
  802475:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802478:	c7 44 24 04 db 2e 80 	movl   $0x802edb,0x4(%esp)
  80247f:	00 
  802480:	8b 45 0c             	mov    0xc(%ebp),%eax
  802483:	89 04 24             	mov    %eax,(%esp)
  802486:	e8 28 e3 ff ff       	call   8007b3 <strcpy>
	return 0;
}
  80248b:	b8 00 00 00 00       	mov    $0x0,%eax
  802490:	c9                   	leave  
  802491:	c3                   	ret    

00802492 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802492:	55                   	push   %ebp
  802493:	89 e5                	mov    %esp,%ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80249e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024a3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024a9:	eb 30                	jmp    8024db <devcons_write+0x49>
		m = n - tot;
  8024ab:	8b 75 10             	mov    0x10(%ebp),%esi
  8024ae:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8024b0:	83 fe 7f             	cmp    $0x7f,%esi
  8024b3:	76 05                	jbe    8024ba <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8024b5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8024ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8024be:	03 45 0c             	add    0xc(%ebp),%eax
  8024c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c5:	89 3c 24             	mov    %edi,(%esp)
  8024c8:	e8 5f e4 ff ff       	call   80092c <memmove>
		sys_cputs(buf, m);
  8024cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d1:	89 3c 24             	mov    %edi,(%esp)
  8024d4:	e8 ff e5 ff ff       	call   800ad8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024d9:	01 f3                	add    %esi,%ebx
  8024db:	89 d8                	mov    %ebx,%eax
  8024dd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8024e0:	72 c9                	jb     8024ab <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024e2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8024e8:	5b                   	pop    %ebx
  8024e9:	5e                   	pop    %esi
  8024ea:	5f                   	pop    %edi
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    

008024ed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024ed:	55                   	push   %ebp
  8024ee:	89 e5                	mov    %esp,%ebp
  8024f0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8024f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024f7:	75 07                	jne    802500 <devcons_read+0x13>
  8024f9:	eb 25                	jmp    802520 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024fb:	e8 86 e6 ff ff       	call   800b86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802500:	e8 f1 e5 ff ff       	call   800af6 <sys_cgetc>
  802505:	85 c0                	test   %eax,%eax
  802507:	74 f2                	je     8024fb <devcons_read+0xe>
  802509:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80250b:	85 c0                	test   %eax,%eax
  80250d:	78 1d                	js     80252c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80250f:	83 f8 04             	cmp    $0x4,%eax
  802512:	74 13                	je     802527 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802514:	8b 45 0c             	mov    0xc(%ebp),%eax
  802517:	88 10                	mov    %dl,(%eax)
	return 1;
  802519:	b8 01 00 00 00       	mov    $0x1,%eax
  80251e:	eb 0c                	jmp    80252c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802520:	b8 00 00 00 00       	mov    $0x0,%eax
  802525:	eb 05                	jmp    80252c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802527:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80252c:	c9                   	leave  
  80252d:	c3                   	ret    

0080252e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80252e:	55                   	push   %ebp
  80252f:	89 e5                	mov    %esp,%ebp
  802531:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802534:	8b 45 08             	mov    0x8(%ebp),%eax
  802537:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80253a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802541:	00 
  802542:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802545:	89 04 24             	mov    %eax,(%esp)
  802548:	e8 8b e5 ff ff       	call   800ad8 <sys_cputs>
}
  80254d:	c9                   	leave  
  80254e:	c3                   	ret    

0080254f <getchar>:

int
getchar(void)
{
  80254f:	55                   	push   %ebp
  802550:	89 e5                	mov    %esp,%ebp
  802552:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802555:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80255c:	00 
  80255d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802560:	89 44 24 04          	mov    %eax,0x4(%esp)
  802564:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80256b:	e8 10 f1 ff ff       	call   801680 <read>
	if (r < 0)
  802570:	85 c0                	test   %eax,%eax
  802572:	78 0f                	js     802583 <getchar+0x34>
		return r;
	if (r < 1)
  802574:	85 c0                	test   %eax,%eax
  802576:	7e 06                	jle    80257e <getchar+0x2f>
		return -E_EOF;
	return c;
  802578:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80257c:	eb 05                	jmp    802583 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80257e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802583:	c9                   	leave  
  802584:	c3                   	ret    

00802585 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802585:	55                   	push   %ebp
  802586:	89 e5                	mov    %esp,%ebp
  802588:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80258b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80258e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802592:	8b 45 08             	mov    0x8(%ebp),%eax
  802595:	89 04 24             	mov    %eax,(%esp)
  802598:	e8 45 ee ff ff       	call   8013e2 <fd_lookup>
  80259d:	85 c0                	test   %eax,%eax
  80259f:	78 11                	js     8025b2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025aa:	39 10                	cmp    %edx,(%eax)
  8025ac:	0f 94 c0             	sete   %al
  8025af:	0f b6 c0             	movzbl %al,%eax
}
  8025b2:	c9                   	leave  
  8025b3:	c3                   	ret    

008025b4 <opencons>:

int
opencons(void)
{
  8025b4:	55                   	push   %ebp
  8025b5:	89 e5                	mov    %esp,%ebp
  8025b7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025bd:	89 04 24             	mov    %eax,(%esp)
  8025c0:	e8 ca ed ff ff       	call   80138f <fd_alloc>
  8025c5:	85 c0                	test   %eax,%eax
  8025c7:	78 3c                	js     802605 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025c9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025d0:	00 
  8025d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025df:	e8 c1 e5 ff ff       	call   800ba5 <sys_page_alloc>
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	78 1d                	js     802605 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8025e8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025fd:	89 04 24             	mov    %eax,(%esp)
  802600:	e8 5f ed ff ff       	call   801364 <fd2num>
}
  802605:	c9                   	leave  
  802606:	c3                   	ret    
	...

00802608 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802608:	55                   	push   %ebp
  802609:	89 e5                	mov    %esp,%ebp
  80260b:	56                   	push   %esi
  80260c:	53                   	push   %ebx
  80260d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802610:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802613:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802619:	e8 49 e5 ff ff       	call   800b67 <sys_getenvid>
  80261e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802621:	89 54 24 10          	mov    %edx,0x10(%esp)
  802625:	8b 55 08             	mov    0x8(%ebp),%edx
  802628:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80262c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802630:	89 44 24 04          	mov    %eax,0x4(%esp)
  802634:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  80263b:	e8 c8 db ff ff       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802640:	89 74 24 04          	mov    %esi,0x4(%esp)
  802644:	8b 45 10             	mov    0x10(%ebp),%eax
  802647:	89 04 24             	mov    %eax,(%esp)
  80264a:	e8 58 db ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  80264f:	c7 04 24 d4 2e 80 00 	movl   $0x802ed4,(%esp)
  802656:	e8 ad db ff ff       	call   800208 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80265b:	cc                   	int3   
  80265c:	eb fd                	jmp    80265b <_panic+0x53>
	...

00802660 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802660:	55                   	push   %ebp
  802661:	89 e5                	mov    %esp,%ebp
  802663:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802666:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80266d:	75 30                	jne    80269f <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  80266f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802676:	00 
  802677:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80267e:	ee 
  80267f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802686:	e8 1a e5 ff ff       	call   800ba5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80268b:	c7 44 24 04 ac 26 80 	movl   $0x8026ac,0x4(%esp)
  802692:	00 
  802693:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80269a:	e8 a6 e6 ff ff       	call   800d45 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80269f:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a2:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8026a7:	c9                   	leave  
  8026a8:	c3                   	ret    
  8026a9:	00 00                	add    %al,(%eax)
	...

008026ac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026ac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026ad:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8026b2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026b4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  8026b7:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  8026bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  8026bf:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  8026c2:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  8026c4:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  8026c8:	83 c4 08             	add    $0x8,%esp
	popal
  8026cb:	61                   	popa   

	addl $4,%esp 
  8026cc:	83 c4 04             	add    $0x4,%esp
	popfl
  8026cf:	9d                   	popf   

	popl %esp
  8026d0:	5c                   	pop    %esp

	ret
  8026d1:	c3                   	ret    
	...

008026d4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026d4:	55                   	push   %ebp
  8026d5:	89 e5                	mov    %esp,%ebp
  8026d7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026da:	89 c2                	mov    %eax,%edx
  8026dc:	c1 ea 16             	shr    $0x16,%edx
  8026df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026e6:	f6 c2 01             	test   $0x1,%dl
  8026e9:	74 1e                	je     802709 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026eb:	c1 e8 0c             	shr    $0xc,%eax
  8026ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026f5:	a8 01                	test   $0x1,%al
  8026f7:	74 17                	je     802710 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026f9:	c1 e8 0c             	shr    $0xc,%eax
  8026fc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802703:	ef 
  802704:	0f b7 c0             	movzwl %ax,%eax
  802707:	eb 0c                	jmp    802715 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802709:	b8 00 00 00 00       	mov    $0x0,%eax
  80270e:	eb 05                	jmp    802715 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802710:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802715:	5d                   	pop    %ebp
  802716:	c3                   	ret    
	...

00802718 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802718:	55                   	push   %ebp
  802719:	57                   	push   %edi
  80271a:	56                   	push   %esi
  80271b:	83 ec 10             	sub    $0x10,%esp
  80271e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802722:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80272a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80272e:	89 cd                	mov    %ecx,%ebp
  802730:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802734:	85 c0                	test   %eax,%eax
  802736:	75 2c                	jne    802764 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802738:	39 f9                	cmp    %edi,%ecx
  80273a:	77 68                	ja     8027a4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80273c:	85 c9                	test   %ecx,%ecx
  80273e:	75 0b                	jne    80274b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802740:	b8 01 00 00 00       	mov    $0x1,%eax
  802745:	31 d2                	xor    %edx,%edx
  802747:	f7 f1                	div    %ecx
  802749:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80274b:	31 d2                	xor    %edx,%edx
  80274d:	89 f8                	mov    %edi,%eax
  80274f:	f7 f1                	div    %ecx
  802751:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802753:	89 f0                	mov    %esi,%eax
  802755:	f7 f1                	div    %ecx
  802757:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802759:	89 f0                	mov    %esi,%eax
  80275b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80275d:	83 c4 10             	add    $0x10,%esp
  802760:	5e                   	pop    %esi
  802761:	5f                   	pop    %edi
  802762:	5d                   	pop    %ebp
  802763:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802764:	39 f8                	cmp    %edi,%eax
  802766:	77 2c                	ja     802794 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802768:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80276b:	83 f6 1f             	xor    $0x1f,%esi
  80276e:	75 4c                	jne    8027bc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802770:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802772:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802777:	72 0a                	jb     802783 <__udivdi3+0x6b>
  802779:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80277d:	0f 87 ad 00 00 00    	ja     802830 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802783:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802788:	89 f0                	mov    %esi,%eax
  80278a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80278c:	83 c4 10             	add    $0x10,%esp
  80278f:	5e                   	pop    %esi
  802790:	5f                   	pop    %edi
  802791:	5d                   	pop    %ebp
  802792:	c3                   	ret    
  802793:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802794:	31 ff                	xor    %edi,%edi
  802796:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802798:	89 f0                	mov    %esi,%eax
  80279a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80279c:	83 c4 10             	add    $0x10,%esp
  80279f:	5e                   	pop    %esi
  8027a0:	5f                   	pop    %edi
  8027a1:	5d                   	pop    %ebp
  8027a2:	c3                   	ret    
  8027a3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027a4:	89 fa                	mov    %edi,%edx
  8027a6:	89 f0                	mov    %esi,%eax
  8027a8:	f7 f1                	div    %ecx
  8027aa:	89 c6                	mov    %eax,%esi
  8027ac:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027ae:	89 f0                	mov    %esi,%eax
  8027b0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027b2:	83 c4 10             	add    $0x10,%esp
  8027b5:	5e                   	pop    %esi
  8027b6:	5f                   	pop    %edi
  8027b7:	5d                   	pop    %ebp
  8027b8:	c3                   	ret    
  8027b9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027bc:	89 f1                	mov    %esi,%ecx
  8027be:	d3 e0                	shl    %cl,%eax
  8027c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027c4:	b8 20 00 00 00       	mov    $0x20,%eax
  8027c9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8027cb:	89 ea                	mov    %ebp,%edx
  8027cd:	88 c1                	mov    %al,%cl
  8027cf:	d3 ea                	shr    %cl,%edx
  8027d1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8027d5:	09 ca                	or     %ecx,%edx
  8027d7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8027db:	89 f1                	mov    %esi,%ecx
  8027dd:	d3 e5                	shl    %cl,%ebp
  8027df:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8027e3:	89 fd                	mov    %edi,%ebp
  8027e5:	88 c1                	mov    %al,%cl
  8027e7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8027e9:	89 fa                	mov    %edi,%edx
  8027eb:	89 f1                	mov    %esi,%ecx
  8027ed:	d3 e2                	shl    %cl,%edx
  8027ef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8027f3:	88 c1                	mov    %al,%cl
  8027f5:	d3 ef                	shr    %cl,%edi
  8027f7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027f9:	89 f8                	mov    %edi,%eax
  8027fb:	89 ea                	mov    %ebp,%edx
  8027fd:	f7 74 24 08          	divl   0x8(%esp)
  802801:	89 d1                	mov    %edx,%ecx
  802803:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802805:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802809:	39 d1                	cmp    %edx,%ecx
  80280b:	72 17                	jb     802824 <__udivdi3+0x10c>
  80280d:	74 09                	je     802818 <__udivdi3+0x100>
  80280f:	89 fe                	mov    %edi,%esi
  802811:	31 ff                	xor    %edi,%edi
  802813:	e9 41 ff ff ff       	jmp    802759 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802818:	8b 54 24 04          	mov    0x4(%esp),%edx
  80281c:	89 f1                	mov    %esi,%ecx
  80281e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802820:	39 c2                	cmp    %eax,%edx
  802822:	73 eb                	jae    80280f <__udivdi3+0xf7>
		{
		  q0--;
  802824:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802827:	31 ff                	xor    %edi,%edi
  802829:	e9 2b ff ff ff       	jmp    802759 <__udivdi3+0x41>
  80282e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802830:	31 f6                	xor    %esi,%esi
  802832:	e9 22 ff ff ff       	jmp    802759 <__udivdi3+0x41>
	...

00802838 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802838:	55                   	push   %ebp
  802839:	57                   	push   %edi
  80283a:	56                   	push   %esi
  80283b:	83 ec 20             	sub    $0x20,%esp
  80283e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802842:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802846:	89 44 24 14          	mov    %eax,0x14(%esp)
  80284a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80284e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802852:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802856:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802858:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80285a:	85 ed                	test   %ebp,%ebp
  80285c:	75 16                	jne    802874 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80285e:	39 f1                	cmp    %esi,%ecx
  802860:	0f 86 a6 00 00 00    	jbe    80290c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802866:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802868:	89 d0                	mov    %edx,%eax
  80286a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80286c:	83 c4 20             	add    $0x20,%esp
  80286f:	5e                   	pop    %esi
  802870:	5f                   	pop    %edi
  802871:	5d                   	pop    %ebp
  802872:	c3                   	ret    
  802873:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802874:	39 f5                	cmp    %esi,%ebp
  802876:	0f 87 ac 00 00 00    	ja     802928 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80287c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80287f:	83 f0 1f             	xor    $0x1f,%eax
  802882:	89 44 24 10          	mov    %eax,0x10(%esp)
  802886:	0f 84 a8 00 00 00    	je     802934 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80288c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802890:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802892:	bf 20 00 00 00       	mov    $0x20,%edi
  802897:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80289b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80289f:	89 f9                	mov    %edi,%ecx
  8028a1:	d3 e8                	shr    %cl,%eax
  8028a3:	09 e8                	or     %ebp,%eax
  8028a5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8028a9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028ad:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028b1:	d3 e0                	shl    %cl,%eax
  8028b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028b7:	89 f2                	mov    %esi,%edx
  8028b9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8028bb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028bf:	d3 e0                	shl    %cl,%eax
  8028c1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028c5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028c9:	89 f9                	mov    %edi,%ecx
  8028cb:	d3 e8                	shr    %cl,%eax
  8028cd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8028cf:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028d1:	89 f2                	mov    %esi,%edx
  8028d3:	f7 74 24 18          	divl   0x18(%esp)
  8028d7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8028d9:	f7 64 24 0c          	mull   0xc(%esp)
  8028dd:	89 c5                	mov    %eax,%ebp
  8028df:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028e1:	39 d6                	cmp    %edx,%esi
  8028e3:	72 67                	jb     80294c <__umoddi3+0x114>
  8028e5:	74 75                	je     80295c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8028e7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8028eb:	29 e8                	sub    %ebp,%eax
  8028ed:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8028ef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028f3:	d3 e8                	shr    %cl,%eax
  8028f5:	89 f2                	mov    %esi,%edx
  8028f7:	89 f9                	mov    %edi,%ecx
  8028f9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8028fb:	09 d0                	or     %edx,%eax
  8028fd:	89 f2                	mov    %esi,%edx
  8028ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802903:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802905:	83 c4 20             	add    $0x20,%esp
  802908:	5e                   	pop    %esi
  802909:	5f                   	pop    %edi
  80290a:	5d                   	pop    %ebp
  80290b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80290c:	85 c9                	test   %ecx,%ecx
  80290e:	75 0b                	jne    80291b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802910:	b8 01 00 00 00       	mov    $0x1,%eax
  802915:	31 d2                	xor    %edx,%edx
  802917:	f7 f1                	div    %ecx
  802919:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80291b:	89 f0                	mov    %esi,%eax
  80291d:	31 d2                	xor    %edx,%edx
  80291f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802921:	89 f8                	mov    %edi,%eax
  802923:	e9 3e ff ff ff       	jmp    802866 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802928:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80292a:	83 c4 20             	add    $0x20,%esp
  80292d:	5e                   	pop    %esi
  80292e:	5f                   	pop    %edi
  80292f:	5d                   	pop    %ebp
  802930:	c3                   	ret    
  802931:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802934:	39 f5                	cmp    %esi,%ebp
  802936:	72 04                	jb     80293c <__umoddi3+0x104>
  802938:	39 f9                	cmp    %edi,%ecx
  80293a:	77 06                	ja     802942 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80293c:	89 f2                	mov    %esi,%edx
  80293e:	29 cf                	sub    %ecx,%edi
  802940:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802942:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802944:	83 c4 20             	add    $0x20,%esp
  802947:	5e                   	pop    %esi
  802948:	5f                   	pop    %edi
  802949:	5d                   	pop    %ebp
  80294a:	c3                   	ret    
  80294b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80294c:	89 d1                	mov    %edx,%ecx
  80294e:	89 c5                	mov    %eax,%ebp
  802950:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802954:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802958:	eb 8d                	jmp    8028e7 <__umoddi3+0xaf>
  80295a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80295c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802960:	72 ea                	jb     80294c <__umoddi3+0x114>
  802962:	89 f1                	mov    %esi,%ecx
  802964:	eb 81                	jmp    8028e7 <__umoddi3+0xaf>
