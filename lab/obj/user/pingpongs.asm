
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 15 12 00 00       	call   801257 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004f:	e8 63 0b 00 00       	call   800bb7 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 c0 29 80 00 	movl   $0x8029c0,(%esp)
  800063:	e8 f0 01 00 00       	call   800258 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 47 0b 00 00       	call   800bb7 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 da 29 80 00 	movl   $0x8029da,(%esp)
  80007f:	e8 d4 01 00 00       	call   800258 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 45 12 00 00       	call   8012ec <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 ba 11 00 00       	call   80127c <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 db 0a 00 00       	call   800bb7 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  8000fa:	e8 59 01 00 00       	call   800258 <cprintf>
		if (val == 10)
  8000ff:	a1 08 40 80 00       	mov    0x804008,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 36                	je     80013f <umain+0x10b>
			return;
		++val;
  800109:	40                   	inc    %eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 ba 11 00 00       	call   8012ec <ipc_send>
		if (val == 10)
  800132:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
  800139:	0f 85 68 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 4c             	add    $0x4c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 5c 0a 00 00       	call   800bb7 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 0c 40 80 00       	mov    %eax,0x80400c


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	85 f6                	test   %esi,%esi
  800178:	7e 07                	jle    800181 <libmain+0x39>
		binaryname = argv[0];
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800181:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800185:	89 34 24             	mov    %esi,(%esp)
  800188:	e8 a7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018d:	e8 0a 00 00 00       	call   80019c <exit>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a2:	e8 f4 13 00 00       	call   80159b <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 b2 09 00 00       	call   800b65 <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 14             	sub    $0x14,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 03                	mov    (%ebx),%eax
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cb:	40                   	inc    %eax
  8001cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d3:	75 19                	jne    8001ee <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001d5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001dc:	00 
  8001dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 40 09 00 00       	call   800b28 <sys_cputs>
		b->idx = 0;
  8001e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ee:	ff 43 04             	incl   0x4(%ebx)
}
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800207:	00 00 00 
	b.cnt = 0;
  80020a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800222:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	c7 04 24 b8 01 80 00 	movl   $0x8001b8,(%esp)
  800233:	e8 82 01 00 00       	call   8003ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800238:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 d8 08 00 00       	call   800b28 <sys_cputs>

	return b.cnt;
}
  800250:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 87 ff ff ff       	call   8001f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    
	...

00800274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 3c             	sub    $0x3c,%esp
  80027d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800280:	89 d7                	mov    %edx,%edi
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800291:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800294:	85 c0                	test   %eax,%eax
  800296:	75 08                	jne    8002a0 <printnum+0x2c>
  800298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029e:	77 57                	ja     8002f7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a4:	4b                   	dec    %ebx
  8002a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bf:	00 
  8002c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	e8 96 24 00 00       	call   802768 <__udivdi3>
  8002d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e1:	89 fa                	mov    %edi,%edx
  8002e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e6:	e8 89 ff ff ff       	call   800274 <printnum>
  8002eb:	eb 0f                	jmp    8002fc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f1:	89 34 24             	mov    %esi,(%esp)
  8002f4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f7:	4b                   	dec    %ebx
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7f f1                	jg     8002ed <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 10             	mov    0x10(%ebp),%eax
  800307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800312:	00 
  800313:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800320:	e8 63 25 00 00       	call   802888 <__umoddi3>
  800325:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800329:	0f be 80 20 2a 80 00 	movsbl 0x802a20(%eax),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800336:	83 c4 3c             	add    $0x3c,%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800341:	83 fa 01             	cmp    $0x1,%edx
  800344:	7e 0e                	jle    800354 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	8b 52 04             	mov    0x4(%edx),%edx
  800352:	eb 22                	jmp    800376 <getuint+0x38>
	else if (lflag)
  800354:	85 d2                	test   %edx,%edx
  800356:	74 10                	je     800368 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	eb 0e                	jmp    800376 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800381:	8b 10                	mov    (%eax),%edx
  800383:	3b 50 04             	cmp    0x4(%eax),%edx
  800386:	73 08                	jae    800390 <sprintputch+0x18>
		*b->buf++ = ch;
  800388:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038b:	88 0a                	mov    %cl,(%edx)
  80038d:	42                   	inc    %edx
  80038e:	89 10                	mov    %edx,(%eax)
}
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800398:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80039f:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 02 00 00 00       	call   8003ba <vprintfmt>
	va_end(ap);
}
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    

008003ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	57                   	push   %edi
  8003be:	56                   	push   %esi
  8003bf:	53                   	push   %ebx
  8003c0:	83 ec 4c             	sub    $0x4c,%esp
  8003c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c9:	eb 12                	jmp    8003dd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cb:	85 c0                	test   %eax,%eax
  8003cd:	0f 84 6b 03 00 00    	je     80073e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003dd:	0f b6 06             	movzbl (%esi),%eax
  8003e0:	46                   	inc    %esi
  8003e1:	83 f8 25             	cmp    $0x25,%eax
  8003e4:	75 e5                	jne    8003cb <vprintfmt+0x11>
  8003e6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800402:	eb 26                	jmp    80042a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800407:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80040b:	eb 1d                	jmp    80042a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800410:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800414:	eb 14                	jmp    80042a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800419:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800420:	eb 08                	jmp    80042a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800422:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800425:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	0f b6 06             	movzbl (%esi),%eax
  80042d:	8d 56 01             	lea    0x1(%esi),%edx
  800430:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800433:	8a 16                	mov    (%esi),%dl
  800435:	83 ea 23             	sub    $0x23,%edx
  800438:	80 fa 55             	cmp    $0x55,%dl
  80043b:	0f 87 e1 02 00 00    	ja     800722 <vprintfmt+0x368>
  800441:	0f b6 d2             	movzbl %dl,%edx
  800444:	ff 24 95 60 2b 80 00 	jmp    *0x802b60(,%edx,4)
  80044b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80044e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800453:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800456:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80045a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80045d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800460:	83 fa 09             	cmp    $0x9,%edx
  800463:	77 2a                	ja     80048f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800465:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb eb                	jmp    800453 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 50 04             	lea    0x4(%eax),%edx
  80046e:	89 55 14             	mov    %edx,0x14(%ebp)
  800471:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800476:	eb 17                	jmp    80048f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800478:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047c:	78 98                	js     800416 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800481:	eb a7                	jmp    80042a <vprintfmt+0x70>
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800486:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80048d:	eb 9b                	jmp    80042a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80048f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800493:	79 95                	jns    80042a <vprintfmt+0x70>
  800495:	eb 8b                	jmp    800422 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800497:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049b:	eb 8d                	jmp    80042a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b5:	e9 23 ff ff ff       	jmp    8003dd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 50 04             	lea    0x4(%eax),%edx
  8004c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c3:	8b 00                	mov    (%eax),%eax
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	79 02                	jns    8004cb <vprintfmt+0x111>
  8004c9:	f7 d8                	neg    %eax
  8004cb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cd:	83 f8 10             	cmp    $0x10,%eax
  8004d0:	7f 0b                	jg     8004dd <vprintfmt+0x123>
  8004d2:	8b 04 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%eax
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	75 23                	jne    800500 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e1:	c7 44 24 08 38 2a 80 	movl   $0x802a38,0x8(%esp)
  8004e8:	00 
  8004e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	e8 9a fe ff ff       	call   800392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004fb:	e9 dd fe ff ff       	jmp    8003dd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800500:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800504:	c7 44 24 08 c9 2e 80 	movl   $0x802ec9,0x8(%esp)
  80050b:	00 
  80050c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800510:	8b 55 08             	mov    0x8(%ebp),%edx
  800513:	89 14 24             	mov    %edx,(%esp)
  800516:	e8 77 fe ff ff       	call   800392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	e9 ba fe ff ff       	jmp    8003dd <vprintfmt+0x23>
  800523:	89 f9                	mov    %edi,%ecx
  800525:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800528:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 30                	mov    (%eax),%esi
  800536:	85 f6                	test   %esi,%esi
  800538:	75 05                	jne    80053f <vprintfmt+0x185>
				p = "(null)";
  80053a:	be 31 2a 80 00       	mov    $0x802a31,%esi
			if (width > 0 && padc != '-')
  80053f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800543:	0f 8e 84 00 00 00    	jle    8005cd <vprintfmt+0x213>
  800549:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80054d:	74 7e                	je     8005cd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800553:	89 34 24             	mov    %esi,(%esp)
  800556:	e8 8b 02 00 00       	call   8007e6 <strnlen>
  80055b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80055e:	29 c2                	sub    %eax,%edx
  800560:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800563:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800567:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80056a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80056d:	89 de                	mov    %ebx,%esi
  80056f:	89 d3                	mov    %edx,%ebx
  800571:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	eb 0b                	jmp    800580 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800575:	89 74 24 04          	mov    %esi,0x4(%esp)
  800579:	89 3c 24             	mov    %edi,(%esp)
  80057c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	4b                   	dec    %ebx
  800580:	85 db                	test   %ebx,%ebx
  800582:	7f f1                	jg     800575 <vprintfmt+0x1bb>
  800584:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800587:	89 f3                	mov    %esi,%ebx
  800589:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80058c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058f:	85 c0                	test   %eax,%eax
  800591:	79 05                	jns    800598 <vprintfmt+0x1de>
  800593:	b8 00 00 00 00       	mov    $0x0,%eax
  800598:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059b:	29 c2                	sub    %eax,%edx
  80059d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a0:	eb 2b                	jmp    8005cd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a6:	74 18                	je     8005c0 <vprintfmt+0x206>
  8005a8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ab:	83 fa 5e             	cmp    $0x5e,%edx
  8005ae:	76 10                	jbe    8005c0 <vprintfmt+0x206>
					putch('?', putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	eb 0a                	jmp    8005ca <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	ff 4d e4             	decl   -0x1c(%ebp)
  8005cd:	0f be 06             	movsbl (%esi),%eax
  8005d0:	46                   	inc    %esi
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	74 21                	je     8005f6 <vprintfmt+0x23c>
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	78 c9                	js     8005a2 <vprintfmt+0x1e8>
  8005d9:	4f                   	dec    %edi
  8005da:	79 c6                	jns    8005a2 <vprintfmt+0x1e8>
  8005dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005df:	89 de                	mov    %ebx,%esi
  8005e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e4:	eb 18                	jmp    8005fe <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f3:	4b                   	dec    %ebx
  8005f4:	eb 08                	jmp    8005fe <vprintfmt+0x244>
  8005f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f9:	89 de                	mov    %ebx,%esi
  8005fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005fe:	85 db                	test   %ebx,%ebx
  800600:	7f e4                	jg     8005e6 <vprintfmt+0x22c>
  800602:	89 7d 08             	mov    %edi,0x8(%ebp)
  800605:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060a:	e9 ce fd ff ff       	jmp    8003dd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060f:	83 f9 01             	cmp    $0x1,%ecx
  800612:	7e 10                	jle    800624 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 08             	lea    0x8(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	8b 78 04             	mov    0x4(%eax),%edi
  800622:	eb 26                	jmp    80064a <vprintfmt+0x290>
	else if (lflag)
  800624:	85 c9                	test   %ecx,%ecx
  800626:	74 12                	je     80063a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 30                	mov    (%eax),%esi
  800633:	89 f7                	mov    %esi,%edi
  800635:	c1 ff 1f             	sar    $0x1f,%edi
  800638:	eb 10                	jmp    80064a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 30                	mov    (%eax),%esi
  800645:	89 f7                	mov    %esi,%edi
  800647:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064a:	85 ff                	test   %edi,%edi
  80064c:	78 0a                	js     800658 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800653:	e9 8c 00 00 00       	jmp    8006e4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800666:	f7 de                	neg    %esi
  800668:	83 d7 00             	adc    $0x0,%edi
  80066b:	f7 df                	neg    %edi
			}
			base = 10;
  80066d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800672:	eb 70                	jmp    8006e4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800674:	89 ca                	mov    %ecx,%edx
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 c0 fc ff ff       	call   80033e <getuint>
  80067e:	89 c6                	mov    %eax,%esi
  800680:	89 d7                	mov    %edx,%edi
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800687:	eb 5b                	jmp    8006e4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 ab fc ff ff       	call   80033e <getuint>
  800693:	89 c6                	mov    %eax,%esi
  800695:	89 d7                	mov    %edx,%edi
			base = 8;
  800697:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80069c:	eb 46                	jmp    8006e4 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80069e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006b7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c3:	8b 30                	mov    (%eax),%esi
  8006c5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006cf:	eb 13                	jmp    8006e4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d1:	89 ca                	mov    %ecx,%edx
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 63 fc ff ff       	call   80033e <getuint>
  8006db:	89 c6                	mov    %eax,%esi
  8006dd:	89 d7                	mov    %edx,%edi
			base = 16;
  8006df:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006e8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f7:	89 34 24             	mov    %esi,(%esp)
  8006fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fe:	89 da                	mov    %ebx,%edx
  800700:	8b 45 08             	mov    0x8(%ebp),%eax
  800703:	e8 6c fb ff ff       	call   800274 <printnum>
			break;
  800708:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80070b:	e9 cd fc ff ff       	jmp    8003dd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800710:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80071d:	e9 bb fc ff ff       	jmp    8003dd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800722:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800726:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800730:	eb 01                	jmp    800733 <vprintfmt+0x379>
  800732:	4e                   	dec    %esi
  800733:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800737:	75 f9                	jne    800732 <vprintfmt+0x378>
  800739:	e9 9f fc ff ff       	jmp    8003dd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80073e:	83 c4 4c             	add    $0x4c,%esp
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5f                   	pop    %edi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 28             	sub    $0x28,%esp
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800752:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800755:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800759:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800763:	85 c0                	test   %eax,%eax
  800765:	74 30                	je     800797 <vsnprintf+0x51>
  800767:	85 d2                	test   %edx,%edx
  800769:	7e 33                	jle    80079e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800772:	8b 45 10             	mov    0x10(%ebp),%eax
  800775:	89 44 24 08          	mov    %eax,0x8(%esp)
  800779:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800780:	c7 04 24 78 03 80 00 	movl   $0x800378,(%esp)
  800787:	e8 2e fc ff ff       	call   8003ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800795:	eb 0c                	jmp    8007a3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079c:	eb 05                	jmp    8007a3 <vsnprintf+0x5d>
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	e8 7b ff ff ff       	call   800746 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    
  8007cd:	00 00                	add    %al,(%eax)
	...

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	eb 01                	jmp    8007de <strlen+0xe>
		n++;
  8007dd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e2:	75 f9                	jne    8007dd <strlen+0xd>
		n++;
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f4:	eb 01                	jmp    8007f7 <strnlen+0x11>
		n++;
  8007f6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	39 d0                	cmp    %edx,%eax
  8007f9:	74 06                	je     800801 <strnlen+0x1b>
  8007fb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ff:	75 f5                	jne    8007f6 <strnlen+0x10>
		n++;
	return n;
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080d:	ba 00 00 00 00       	mov    $0x0,%edx
  800812:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800815:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800818:	42                   	inc    %edx
  800819:	84 c9                	test   %cl,%cl
  80081b:	75 f5                	jne    800812 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80081d:	5b                   	pop    %ebx
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082a:	89 1c 24             	mov    %ebx,(%esp)
  80082d:	e8 9e ff ff ff       	call   8007d0 <strlen>
	strcpy(dst + len, src);
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
  800835:	89 54 24 04          	mov    %edx,0x4(%esp)
  800839:	01 d8                	add    %ebx,%eax
  80083b:	89 04 24             	mov    %eax,(%esp)
  80083e:	e8 c0 ff ff ff       	call   800803 <strcpy>
	return dst;
}
  800843:	89 d8                	mov    %ebx,%eax
  800845:	83 c4 08             	add    $0x8,%esp
  800848:	5b                   	pop    %ebx
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
  800856:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085e:	eb 0c                	jmp    80086c <strncpy+0x21>
		*dst++ = *src;
  800860:	8a 1a                	mov    (%edx),%bl
  800862:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800865:	80 3a 01             	cmpb   $0x1,(%edx)
  800868:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086b:	41                   	inc    %ecx
  80086c:	39 f1                	cmp    %esi,%ecx
  80086e:	75 f0                	jne    800860 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	8b 75 08             	mov    0x8(%ebp),%esi
  80087c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800882:	85 d2                	test   %edx,%edx
  800884:	75 0a                	jne    800890 <strlcpy+0x1c>
  800886:	89 f0                	mov    %esi,%eax
  800888:	eb 1a                	jmp    8008a4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088a:	88 18                	mov    %bl,(%eax)
  80088c:	40                   	inc    %eax
  80088d:	41                   	inc    %ecx
  80088e:	eb 02                	jmp    800892 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800892:	4a                   	dec    %edx
  800893:	74 0a                	je     80089f <strlcpy+0x2b>
  800895:	8a 19                	mov    (%ecx),%bl
  800897:	84 db                	test   %bl,%bl
  800899:	75 ef                	jne    80088a <strlcpy+0x16>
  80089b:	89 c2                	mov    %eax,%edx
  80089d:	eb 02                	jmp    8008a1 <strlcpy+0x2d>
  80089f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008a4:	29 f0                	sub    %esi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b3:	eb 02                	jmp    8008b7 <strcmp+0xd>
		p++, q++;
  8008b5:	41                   	inc    %ecx
  8008b6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b7:	8a 01                	mov    (%ecx),%al
  8008b9:	84 c0                	test   %al,%al
  8008bb:	74 04                	je     8008c1 <strcmp+0x17>
  8008bd:	3a 02                	cmp    (%edx),%al
  8008bf:	74 f4                	je     8008b5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c1:	0f b6 c0             	movzbl %al,%eax
  8008c4:	0f b6 12             	movzbl (%edx),%edx
  8008c7:	29 d0                	sub    %edx,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d8:	eb 03                	jmp    8008dd <strncmp+0x12>
		n--, p++, q++;
  8008da:	4a                   	dec    %edx
  8008db:	40                   	inc    %eax
  8008dc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008dd:	85 d2                	test   %edx,%edx
  8008df:	74 14                	je     8008f5 <strncmp+0x2a>
  8008e1:	8a 18                	mov    (%eax),%bl
  8008e3:	84 db                	test   %bl,%bl
  8008e5:	74 04                	je     8008eb <strncmp+0x20>
  8008e7:	3a 19                	cmp    (%ecx),%bl
  8008e9:	74 ef                	je     8008da <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	0f b6 11             	movzbl (%ecx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
  8008f3:	eb 05                	jmp    8008fa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800906:	eb 05                	jmp    80090d <strchr+0x10>
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 0c                	je     800918 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090c:	40                   	inc    %eax
  80090d:	8a 10                	mov    (%eax),%dl
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f5                	jne    800908 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800923:	eb 05                	jmp    80092a <strfind+0x10>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 07                	je     800930 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800929:	40                   	inc    %eax
  80092a:	8a 10                	mov    (%eax),%dl
  80092c:	84 d2                	test   %dl,%dl
  80092e:	75 f5                	jne    800925 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	57                   	push   %edi
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800941:	85 c9                	test   %ecx,%ecx
  800943:	74 30                	je     800975 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800945:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094b:	75 25                	jne    800972 <memset+0x40>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 20                	jne    800972 <memset+0x40>
		c &= 0xFF;
  800952:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800955:	89 d3                	mov    %edx,%ebx
  800957:	c1 e3 08             	shl    $0x8,%ebx
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	c1 e6 18             	shl    $0x18,%esi
  80095f:	89 d0                	mov    %edx,%eax
  800961:	c1 e0 10             	shl    $0x10,%eax
  800964:	09 f0                	or     %esi,%eax
  800966:	09 d0                	or     %edx,%eax
  800968:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80096d:	fc                   	cld    
  80096e:	f3 ab                	rep stos %eax,%es:(%edi)
  800970:	eb 03                	jmp    800975 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800972:	fc                   	cld    
  800973:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800975:	89 f8                	mov    %edi,%eax
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 75 0c             	mov    0xc(%ebp),%esi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098a:	39 c6                	cmp    %eax,%esi
  80098c:	73 34                	jae    8009c2 <memmove+0x46>
  80098e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800991:	39 d0                	cmp    %edx,%eax
  800993:	73 2d                	jae    8009c2 <memmove+0x46>
		s += n;
		d += n;
  800995:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800998:	f6 c2 03             	test   $0x3,%dl
  80099b:	75 1b                	jne    8009b8 <memmove+0x3c>
  80099d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a3:	75 13                	jne    8009b8 <memmove+0x3c>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 0e                	jne    8009b8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009aa:	83 ef 04             	sub    $0x4,%edi
  8009ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b6:	eb 07                	jmp    8009bf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b8:	4f                   	dec    %edi
  8009b9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bc:	fd                   	std    
  8009bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bf:	fc                   	cld    
  8009c0:	eb 20                	jmp    8009e2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c8:	75 13                	jne    8009dd <memmove+0x61>
  8009ca:	a8 03                	test   $0x3,%al
  8009cc:	75 0f                	jne    8009dd <memmove+0x61>
  8009ce:	f6 c1 03             	test   $0x3,%cl
  8009d1:	75 0a                	jne    8009dd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009db:	eb 05                	jmp    8009e2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	89 04 24             	mov    %eax,(%esp)
  800a00:	e8 77 ff ff ff       	call   80097c <memmove>
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a16:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1b:	eb 16                	jmp    800a33 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a20:	42                   	inc    %edx
  800a21:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a25:	38 c8                	cmp    %cl,%al
  800a27:	74 0a                	je     800a33 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 c9             	movzbl %cl,%ecx
  800a2f:	29 c8                	sub    %ecx,%eax
  800a31:	eb 09                	jmp    800a3c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	75 e6                	jne    800a1d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4a:	89 c2                	mov    %eax,%edx
  800a4c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4f:	eb 05                	jmp    800a56 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a51:	38 08                	cmp    %cl,(%eax)
  800a53:	74 05                	je     800a5a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a55:	40                   	inc    %eax
  800a56:	39 d0                	cmp    %edx,%eax
  800a58:	72 f7                	jb     800a51 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a68:	eb 01                	jmp    800a6b <strtol+0xf>
		s++;
  800a6a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6b:	8a 02                	mov    (%edx),%al
  800a6d:	3c 20                	cmp    $0x20,%al
  800a6f:	74 f9                	je     800a6a <strtol+0xe>
  800a71:	3c 09                	cmp    $0x9,%al
  800a73:	74 f5                	je     800a6a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a75:	3c 2b                	cmp    $0x2b,%al
  800a77:	75 08                	jne    800a81 <strtol+0x25>
		s++;
  800a79:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7f:	eb 13                	jmp    800a94 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a81:	3c 2d                	cmp    $0x2d,%al
  800a83:	75 0a                	jne    800a8f <strtol+0x33>
		s++, neg = 1;
  800a85:	8d 52 01             	lea    0x1(%edx),%edx
  800a88:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8d:	eb 05                	jmp    800a94 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	74 05                	je     800a9d <strtol+0x41>
  800a98:	83 fb 10             	cmp    $0x10,%ebx
  800a9b:	75 28                	jne    800ac5 <strtol+0x69>
  800a9d:	8a 02                	mov    (%edx),%al
  800a9f:	3c 30                	cmp    $0x30,%al
  800aa1:	75 10                	jne    800ab3 <strtol+0x57>
  800aa3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa7:	75 0a                	jne    800ab3 <strtol+0x57>
		s += 2, base = 16;
  800aa9:	83 c2 02             	add    $0x2,%edx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 12                	jmp    800ac5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	75 0e                	jne    800ac5 <strtol+0x69>
  800ab7:	3c 30                	cmp    $0x30,%al
  800ab9:	75 05                	jne    800ac0 <strtol+0x64>
		s++, base = 8;
  800abb:	42                   	inc    %edx
  800abc:	b3 08                	mov    $0x8,%bl
  800abe:	eb 05                	jmp    800ac5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aca:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800acc:	8a 0a                	mov    (%edx),%cl
  800ace:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad1:	80 fb 09             	cmp    $0x9,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x82>
			dig = *s - '0';
  800ad6:	0f be c9             	movsbl %cl,%ecx
  800ad9:	83 e9 30             	sub    $0x30,%ecx
  800adc:	eb 1e                	jmp    800afc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ade:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x92>
			dig = *s - 'a' + 10;
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 57             	sub    $0x57,%ecx
  800aec:	eb 0e                	jmp    800afc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aee:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 12                	ja     800b08 <strtol+0xac>
			dig = *s - 'A' + 10;
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800afc:	39 f1                	cmp    %esi,%ecx
  800afe:	7d 0c                	jge    800b0c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b00:	42                   	inc    %edx
  800b01:	0f af c6             	imul   %esi,%eax
  800b04:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b06:	eb c4                	jmp    800acc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b08:	89 c1                	mov    %eax,%ecx
  800b0a:	eb 02                	jmp    800b0e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b12:	74 05                	je     800b19 <strtol+0xbd>
		*endptr = (char *) s;
  800b14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b17:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b19:	85 ff                	test   %edi,%edi
  800b1b:	74 04                	je     800b21 <strtol+0xc5>
  800b1d:	89 c8                	mov    %ecx,%eax
  800b1f:	f7 d8                	neg    %eax
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    
	...

00800b28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	89 c3                	mov    %eax,%ebx
  800b3b:	89 c7                	mov    %eax,%edi
  800b3d:	89 c6                	mov    %eax,%esi
  800b3f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 01 00 00 00       	mov    $0x1,%eax
  800b56:	89 d1                	mov    %edx,%ecx
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b73:	b8 03 00 00 00       	mov    $0x3,%eax
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	89 cb                	mov    %ecx,%ebx
  800b7d:	89 cf                	mov    %ecx,%edi
  800b7f:	89 ce                	mov    %ecx,%esi
  800b81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7e 28                	jle    800baf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b8b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b92:	00 
  800b93:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  800b9a:	00 
  800b9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba2:	00 
  800ba3:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800baa:	e8 a9 1a 00 00       	call   802658 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	83 c4 2c             	add    $0x2c,%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_yield>:

void
sys_yield(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 28                	jle    800c41 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c24:	00 
  800c25:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  800c2c:	00 
  800c2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c34:	00 
  800c35:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800c3c:	e8 17 1a 00 00       	call   802658 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c41:	83 c4 2c             	add    $0x2c,%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	b8 05 00 00 00       	mov    $0x5,%eax
  800c57:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7e 28                	jle    800c94 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c70:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c77:	00 
  800c78:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  800c7f:	00 
  800c80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c87:	00 
  800c88:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800c8f:	e8 c4 19 00 00       	call   802658 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c94:	83 c4 2c             	add    $0x2c,%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	b8 06 00 00 00       	mov    $0x6,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	89 df                	mov    %ebx,%edi
  800cb7:	89 de                	mov    %ebx,%esi
  800cb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 28                	jle    800ce7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cca:	00 
  800ccb:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cda:	00 
  800cdb:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800ce2:	e8 71 19 00 00       	call   802658 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce7:	83 c4 2c             	add    $0x2c,%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	b8 08 00 00 00       	mov    $0x8,%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	89 df                	mov    %ebx,%edi
  800d0a:	89 de                	mov    %ebx,%esi
  800d0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 28                	jle    800d3a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d16:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  800d25:	00 
  800d26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2d:	00 
  800d2e:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800d35:	e8 1e 19 00 00       	call   802658 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3a:	83 c4 2c             	add    $0x2c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 09 00 00 00       	mov    $0x9,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 28                	jle    800d8d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d69:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d70:	00 
  800d71:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  800d78:	00 
  800d79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d80:	00 
  800d81:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800d88:	e8 cb 18 00 00       	call   802658 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d8d:	83 c4 2c             	add    $0x2c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	89 df                	mov    %ebx,%edi
  800db0:	89 de                	mov    %ebx,%esi
  800db2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db4:	85 c0                	test   %eax,%eax
  800db6:	7e 28                	jle    800de0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd3:	00 
  800dd4:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800ddb:	e8 78 18 00 00       	call   802658 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de0:	83 c4 2c             	add    $0x2c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	be 00 00 00 00       	mov    $0x0,%esi
  800df3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e19:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	89 cb                	mov    %ecx,%ebx
  800e23:	89 cf                	mov    %ecx,%edi
  800e25:	89 ce                	mov    %ecx,%esi
  800e27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800e50:	e8 03 18 00 00       	call   802658 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e55:	83 c4 2c             	add    $0x2c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	ba 00 00 00 00       	mov    $0x0,%edx
  800e68:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e6d:	89 d1                	mov    %edx,%ecx
  800e6f:	89 d3                	mov    %edx,%ebx
  800e71:	89 d7                	mov    %edx,%edi
  800e73:	89 d6                	mov    %edx,%esi
  800e75:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e87:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e92:	89 df                	mov    %ebx,%edi
  800e94:	89 de                	mov    %ebx,%esi
  800e96:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	b8 10 00 00 00       	mov    $0x10,%eax
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    
	...

00800ec0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 24             	sub    $0x24,%esp
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eca:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800ecc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ed0:	74 2d                	je     800eff <pgfault+0x3f>
  800ed2:	89 d8                	mov    %ebx,%eax
  800ed4:	c1 e8 16             	shr    $0x16,%eax
  800ed7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ede:	a8 01                	test   $0x1,%al
  800ee0:	74 1d                	je     800eff <pgfault+0x3f>
  800ee2:	89 d8                	mov    %ebx,%eax
  800ee4:	c1 e8 0c             	shr    $0xc,%eax
  800ee7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eee:	f6 c2 01             	test   $0x1,%dl
  800ef1:	74 0c                	je     800eff <pgfault+0x3f>
  800ef3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800efa:	f6 c4 08             	test   $0x8,%ah
  800efd:	75 1c                	jne    800f1b <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  800eff:	c7 44 24 08 50 2d 80 	movl   $0x802d50,0x8(%esp)
  800f06:	00 
  800f07:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f0e:	00 
  800f0f:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  800f16:	e8 3d 17 00 00       	call   802658 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  800f1b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f21:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f38:	e8 b8 fc ff ff       	call   800bf5 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  800f3d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f44:	00 
  800f45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f49:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f50:	e8 91 fa ff ff       	call   8009e6 <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  800f55:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f5c:	00 
  800f5d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f68:	00 
  800f69:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f70:	00 
  800f71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f78:	e8 cc fc ff ff       	call   800c49 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  800f7d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f84:	00 
  800f85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8c:	e8 0b fd ff ff       	call   800c9c <sys_page_unmap>

	// panic("pgfault not implemented");
}
  800f91:	83 c4 24             	add    $0x24,%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	57                   	push   %edi
  800f9b:	56                   	push   %esi
  800f9c:	53                   	push   %ebx
  800f9d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fa0:	c7 04 24 c0 0e 80 00 	movl   $0x800ec0,(%esp)
  800fa7:	e8 04 17 00 00       	call   8026b0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fac:	ba 07 00 00 00       	mov    $0x7,%edx
  800fb1:	89 d0                	mov    %edx,%eax
  800fb3:	cd 30                	int    $0x30
  800fb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fb8:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	79 20                	jns    800fde <fork+0x47>
		panic("sys_exofork: %e", envid);
  800fbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fc2:	c7 44 24 08 9e 2d 80 	movl   $0x802d9e,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  800fd9:	e8 7a 16 00 00       	call   802658 <_panic>
	if (envid == 0)
  800fde:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fe2:	75 25                	jne    801009 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe4:	e8 ce fb ff ff       	call   800bb7 <sys_getenvid>
  800fe9:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ff5:	c1 e0 07             	shl    $0x7,%eax
  800ff8:	29 d0                	sub    %edx,%eax
  800ffa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fff:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  801004:	e9 43 02 00 00       	jmp    80124c <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  801009:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  80100e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801014:	0f 84 85 01 00 00    	je     80119f <fork+0x208>
  80101a:	89 d8                	mov    %ebx,%eax
  80101c:	c1 e8 16             	shr    $0x16,%eax
  80101f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801026:	a8 01                	test   $0x1,%al
  801028:	0f 84 5f 01 00 00    	je     80118d <fork+0x1f6>
  80102e:	89 d8                	mov    %ebx,%eax
  801030:	c1 e8 0c             	shr    $0xc,%eax
  801033:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103a:	f6 c2 01             	test   $0x1,%dl
  80103d:	0f 84 4a 01 00 00    	je     80118d <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  801043:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  801045:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104c:	f6 c6 04             	test   $0x4,%dh
  80104f:	74 50                	je     8010a1 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  801051:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801058:	25 07 0e 00 00       	and    $0xe07,%eax
  80105d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801061:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801065:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801069:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80106d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801074:	e8 d0 fb ff ff       	call   800c49 <sys_page_map>
  801079:	85 c0                	test   %eax,%eax
  80107b:	0f 89 0c 01 00 00    	jns    80118d <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  801081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801085:	c7 44 24 08 ae 2d 80 	movl   $0x802dae,0x8(%esp)
  80108c:	00 
  80108d:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801094:	00 
  801095:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  80109c:	e8 b7 15 00 00       	call   802658 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  8010a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a8:	f6 c2 02             	test   $0x2,%dl
  8010ab:	75 10                	jne    8010bd <fork+0x126>
  8010ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b4:	f6 c4 08             	test   $0x8,%ah
  8010b7:	0f 84 8c 00 00 00    	je     801149 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  8010bd:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010c4:	00 
  8010c5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010c9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d8:	e8 6c fb ff ff       	call   800c49 <sys_page_map>
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	79 20                	jns    801101 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  8010e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e5:	c7 44 24 08 ae 2d 80 	movl   $0x802dae,0x8(%esp)
  8010ec:	00 
  8010ed:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8010f4:	00 
  8010f5:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  8010fc:	e8 57 15 00 00       	call   802658 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801101:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801108:	00 
  801109:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80110d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801114:	00 
  801115:	89 74 24 04          	mov    %esi,0x4(%esp)
  801119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801120:	e8 24 fb ff ff       	call   800c49 <sys_page_map>
  801125:	85 c0                	test   %eax,%eax
  801127:	79 64                	jns    80118d <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80112d:	c7 44 24 08 ae 2d 80 	movl   $0x802dae,0x8(%esp)
  801134:	00 
  801135:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  80113c:	00 
  80113d:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  801144:	e8 0f 15 00 00       	call   802658 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  801149:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801150:	00 
  801151:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801155:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801159:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80115d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801164:	e8 e0 fa ff ff       	call   800c49 <sys_page_map>
  801169:	85 c0                	test   %eax,%eax
  80116b:	79 20                	jns    80118d <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  80116d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801171:	c7 44 24 08 ae 2d 80 	movl   $0x802dae,0x8(%esp)
  801178:	00 
  801179:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801180:	00 
  801181:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  801188:	e8 cb 14 00 00       	call   802658 <_panic>
  80118d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  801193:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801199:	0f 85 6f fe ff ff    	jne    80100e <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  80119f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011ae:	ee 
  8011af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b2:	89 04 24             	mov    %eax,(%esp)
  8011b5:	e8 3b fa ff ff       	call   800bf5 <sys_page_alloc>
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	79 20                	jns    8011de <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  8011be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c2:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  8011c9:	00 
  8011ca:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  8011d1:	00 
  8011d2:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  8011d9:	e8 7a 14 00 00       	call   802658 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8011de:	c7 44 24 04 fc 26 80 	movl   $0x8026fc,0x4(%esp)
  8011e5:	00 
  8011e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e9:	89 04 24             	mov    %eax,(%esp)
  8011ec:	e8 a4 fb ff ff       	call   800d95 <sys_env_set_pgfault_upcall>
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	79 20                	jns    801215 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  8011f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f9:	c7 44 24 08 74 2d 80 	movl   $0x802d74,0x8(%esp)
  801200:	00 
  801201:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801208:	00 
  801209:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  801210:	e8 43 14 00 00       	call   802658 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801215:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80121c:	00 
  80121d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801220:	89 04 24             	mov    %eax,(%esp)
  801223:	e8 c7 fa ff ff       	call   800cef <sys_env_set_status>
  801228:	85 c0                	test   %eax,%eax
  80122a:	79 20                	jns    80124c <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  80122c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801230:	c7 44 24 08 d3 2d 80 	movl   $0x802dd3,0x8(%esp)
  801237:	00 
  801238:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80123f:	00 
  801240:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  801247:	e8 0c 14 00 00       	call   802658 <_panic>

	return envid;
	// panic("fork not implemented");
}
  80124c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80124f:	83 c4 3c             	add    $0x3c,%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <sfork>:

// Challenge!
int
sfork(void)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80125d:	c7 44 24 08 ea 2d 80 	movl   $0x802dea,0x8(%esp)
  801264:	00 
  801265:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  80126c:	00 
  80126d:	c7 04 24 93 2d 80 00 	movl   $0x802d93,(%esp)
  801274:	e8 df 13 00 00       	call   802658 <_panic>
  801279:	00 00                	add    %al,(%eax)
	...

0080127c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	56                   	push   %esi
  801280:	53                   	push   %ebx
  801281:	83 ec 10             	sub    $0x10,%esp
  801284:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  80128d:	85 c0                	test   %eax,%eax
  80128f:	74 0a                	je     80129b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  801291:	89 04 24             	mov    %eax,(%esp)
  801294:	e8 72 fb ff ff       	call   800e0b <sys_ipc_recv>
  801299:	eb 0c                	jmp    8012a7 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80129b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8012a2:	e8 64 fb ff ff       	call   800e0b <sys_ipc_recv>
	}
	if (r < 0)
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	79 16                	jns    8012c1 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8012ab:	85 db                	test   %ebx,%ebx
  8012ad:	74 06                	je     8012b5 <ipc_recv+0x39>
  8012af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8012b5:	85 f6                	test   %esi,%esi
  8012b7:	74 2c                	je     8012e5 <ipc_recv+0x69>
  8012b9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8012bf:	eb 24                	jmp    8012e5 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8012c1:	85 db                	test   %ebx,%ebx
  8012c3:	74 0a                	je     8012cf <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8012c5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012ca:	8b 40 74             	mov    0x74(%eax),%eax
  8012cd:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8012cf:	85 f6                	test   %esi,%esi
  8012d1:	74 0a                	je     8012dd <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8012d3:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012d8:	8b 40 78             	mov    0x78(%eax),%eax
  8012db:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8012dd:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012e2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	57                   	push   %edi
  8012f0:	56                   	push   %esi
  8012f1:	53                   	push   %ebx
  8012f2:	83 ec 1c             	sub    $0x1c,%esp
  8012f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8012fe:	85 db                	test   %ebx,%ebx
  801300:	74 19                	je     80131b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  801302:	8b 45 14             	mov    0x14(%ebp),%eax
  801305:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801309:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80130d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801311:	89 34 24             	mov    %esi,(%esp)
  801314:	e8 cf fa ff ff       	call   800de8 <sys_ipc_try_send>
  801319:	eb 1c                	jmp    801337 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80131b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801322:	00 
  801323:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80132a:	ee 
  80132b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80132f:	89 34 24             	mov    %esi,(%esp)
  801332:	e8 b1 fa ff ff       	call   800de8 <sys_ipc_try_send>
		}
		if (r == 0)
  801337:	85 c0                	test   %eax,%eax
  801339:	74 2c                	je     801367 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80133b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80133e:	74 20                	je     801360 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  801340:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801344:	c7 44 24 08 00 2e 80 	movl   $0x802e00,0x8(%esp)
  80134b:	00 
  80134c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801353:	00 
  801354:	c7 04 24 13 2e 80 00 	movl   $0x802e13,(%esp)
  80135b:	e8 f8 12 00 00       	call   802658 <_panic>
		}
		sys_yield();
  801360:	e8 71 f8 ff ff       	call   800bd6 <sys_yield>
	}
  801365:	eb 97                	jmp    8012fe <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801367:	83 c4 1c             	add    $0x1c,%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	53                   	push   %ebx
  801373:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80137b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801382:	89 c2                	mov    %eax,%edx
  801384:	c1 e2 07             	shl    $0x7,%edx
  801387:	29 ca                	sub    %ecx,%edx
  801389:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80138f:	8b 52 50             	mov    0x50(%edx),%edx
  801392:	39 da                	cmp    %ebx,%edx
  801394:	75 0f                	jne    8013a5 <ipc_find_env+0x36>
			return envs[i].env_id;
  801396:	c1 e0 07             	shl    $0x7,%eax
  801399:	29 c8                	sub    %ecx,%eax
  80139b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013a0:	8b 40 40             	mov    0x40(%eax),%eax
  8013a3:	eb 0c                	jmp    8013b1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013a5:	40                   	inc    %eax
  8013a6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013ab:	75 ce                	jne    80137b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013ad:	66 b8 00 00          	mov    $0x0,%ax
}
  8013b1:	5b                   	pop    %ebx
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8013bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	e8 df ff ff ff       	call   8013b4 <fd2num>
  8013d5:	c1 e0 0c             	shl    $0xc,%eax
  8013d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013eb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	c1 ea 16             	shr    $0x16,%edx
  8013f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f9:	f6 c2 01             	test   $0x1,%dl
  8013fc:	74 11                	je     80140f <fd_alloc+0x30>
  8013fe:	89 c2                	mov    %eax,%edx
  801400:	c1 ea 0c             	shr    $0xc,%edx
  801403:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140a:	f6 c2 01             	test   $0x1,%dl
  80140d:	75 09                	jne    801418 <fd_alloc+0x39>
			*fd_store = fd;
  80140f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801411:	b8 00 00 00 00       	mov    $0x0,%eax
  801416:	eb 17                	jmp    80142f <fd_alloc+0x50>
  801418:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80141d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801422:	75 c7                	jne    8013eb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801424:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80142a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80142f:	5b                   	pop    %ebx
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801438:	83 f8 1f             	cmp    $0x1f,%eax
  80143b:	77 36                	ja     801473 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80143d:	c1 e0 0c             	shl    $0xc,%eax
  801440:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801445:	89 c2                	mov    %eax,%edx
  801447:	c1 ea 16             	shr    $0x16,%edx
  80144a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801451:	f6 c2 01             	test   $0x1,%dl
  801454:	74 24                	je     80147a <fd_lookup+0x48>
  801456:	89 c2                	mov    %eax,%edx
  801458:	c1 ea 0c             	shr    $0xc,%edx
  80145b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801462:	f6 c2 01             	test   $0x1,%dl
  801465:	74 1a                	je     801481 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801467:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146a:	89 02                	mov    %eax,(%edx)
	return 0;
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
  801471:	eb 13                	jmp    801486 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801478:	eb 0c                	jmp    801486 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80147a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147f:	eb 05                	jmp    801486 <fd_lookup+0x54>
  801481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 14             	sub    $0x14,%esp
  80148f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801492:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	eb 0e                	jmp    8014aa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80149c:	39 08                	cmp    %ecx,(%eax)
  80149e:	75 09                	jne    8014a9 <dev_lookup+0x21>
			*dev = devtab[i];
  8014a0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a7:	eb 33                	jmp    8014dc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014a9:	42                   	inc    %edx
  8014aa:	8b 04 95 9c 2e 80 00 	mov    0x802e9c(,%edx,4),%eax
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	75 e7                	jne    80149c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014b5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014ba:	8b 40 48             	mov    0x48(%eax),%eax
  8014bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c5:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  8014cc:	e8 87 ed ff ff       	call   800258 <cprintf>
	*dev = 0;
  8014d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014dc:	83 c4 14             	add    $0x14,%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5d                   	pop    %ebp
  8014e1:	c3                   	ret    

008014e2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	56                   	push   %esi
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 30             	sub    $0x30,%esp
  8014ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ed:	8a 45 0c             	mov    0xc(%ebp),%al
  8014f0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014f3:	89 34 24             	mov    %esi,(%esp)
  8014f6:	e8 b9 fe ff ff       	call   8013b4 <fd2num>
  8014fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801502:	89 04 24             	mov    %eax,(%esp)
  801505:	e8 28 ff ff ff       	call   801432 <fd_lookup>
  80150a:	89 c3                	mov    %eax,%ebx
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 05                	js     801515 <fd_close+0x33>
	    || fd != fd2)
  801510:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801513:	74 0d                	je     801522 <fd_close+0x40>
		return (must_exist ? r : 0);
  801515:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801519:	75 46                	jne    801561 <fd_close+0x7f>
  80151b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801520:	eb 3f                	jmp    801561 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801522:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801525:	89 44 24 04          	mov    %eax,0x4(%esp)
  801529:	8b 06                	mov    (%esi),%eax
  80152b:	89 04 24             	mov    %eax,(%esp)
  80152e:	e8 55 ff ff ff       	call   801488 <dev_lookup>
  801533:	89 c3                	mov    %eax,%ebx
  801535:	85 c0                	test   %eax,%eax
  801537:	78 18                	js     801551 <fd_close+0x6f>
		if (dev->dev_close)
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	8b 40 10             	mov    0x10(%eax),%eax
  80153f:	85 c0                	test   %eax,%eax
  801541:	74 09                	je     80154c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801543:	89 34 24             	mov    %esi,(%esp)
  801546:	ff d0                	call   *%eax
  801548:	89 c3                	mov    %eax,%ebx
  80154a:	eb 05                	jmp    801551 <fd_close+0x6f>
		else
			r = 0;
  80154c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801551:	89 74 24 04          	mov    %esi,0x4(%esp)
  801555:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80155c:	e8 3b f7 ff ff       	call   800c9c <sys_page_unmap>
	return r;
}
  801561:	89 d8                	mov    %ebx,%eax
  801563:	83 c4 30             	add    $0x30,%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801570:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801573:	89 44 24 04          	mov    %eax,0x4(%esp)
  801577:	8b 45 08             	mov    0x8(%ebp),%eax
  80157a:	89 04 24             	mov    %eax,(%esp)
  80157d:	e8 b0 fe ff ff       	call   801432 <fd_lookup>
  801582:	85 c0                	test   %eax,%eax
  801584:	78 13                	js     801599 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801586:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80158d:	00 
  80158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801591:	89 04 24             	mov    %eax,(%esp)
  801594:	e8 49 ff ff ff       	call   8014e2 <fd_close>
}
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <close_all>:

void
close_all(void)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	53                   	push   %ebx
  80159f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015a7:	89 1c 24             	mov    %ebx,(%esp)
  8015aa:	e8 bb ff ff ff       	call   80156a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015af:	43                   	inc    %ebx
  8015b0:	83 fb 20             	cmp    $0x20,%ebx
  8015b3:	75 f2                	jne    8015a7 <close_all+0xc>
		close(i);
}
  8015b5:	83 c4 14             	add    $0x14,%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    

008015bb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	57                   	push   %edi
  8015bf:	56                   	push   %esi
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 4c             	sub    $0x4c,%esp
  8015c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d1:	89 04 24             	mov    %eax,(%esp)
  8015d4:	e8 59 fe ff ff       	call   801432 <fd_lookup>
  8015d9:	89 c3                	mov    %eax,%ebx
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	0f 88 e3 00 00 00    	js     8016c6 <dup+0x10b>
		return r;
	close(newfdnum);
  8015e3:	89 3c 24             	mov    %edi,(%esp)
  8015e6:	e8 7f ff ff ff       	call   80156a <close>

	newfd = INDEX2FD(newfdnum);
  8015eb:	89 fe                	mov    %edi,%esi
  8015ed:	c1 e6 0c             	shl    $0xc,%esi
  8015f0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f9:	89 04 24             	mov    %eax,(%esp)
  8015fc:	e8 c3 fd ff ff       	call   8013c4 <fd2data>
  801601:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801603:	89 34 24             	mov    %esi,(%esp)
  801606:	e8 b9 fd ff ff       	call   8013c4 <fd2data>
  80160b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80160e:	89 d8                	mov    %ebx,%eax
  801610:	c1 e8 16             	shr    $0x16,%eax
  801613:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80161a:	a8 01                	test   $0x1,%al
  80161c:	74 46                	je     801664 <dup+0xa9>
  80161e:	89 d8                	mov    %ebx,%eax
  801620:	c1 e8 0c             	shr    $0xc,%eax
  801623:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80162a:	f6 c2 01             	test   $0x1,%dl
  80162d:	74 35                	je     801664 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80162f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801636:	25 07 0e 00 00       	and    $0xe07,%eax
  80163b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80163f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801642:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801646:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80164d:	00 
  80164e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801652:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801659:	e8 eb f5 ff ff       	call   800c49 <sys_page_map>
  80165e:	89 c3                	mov    %eax,%ebx
  801660:	85 c0                	test   %eax,%eax
  801662:	78 3b                	js     80169f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801664:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801667:	89 c2                	mov    %eax,%edx
  801669:	c1 ea 0c             	shr    $0xc,%edx
  80166c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801673:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801679:	89 54 24 10          	mov    %edx,0x10(%esp)
  80167d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801681:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801688:	00 
  801689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801694:	e8 b0 f5 ff ff       	call   800c49 <sys_page_map>
  801699:	89 c3                	mov    %eax,%ebx
  80169b:	85 c0                	test   %eax,%eax
  80169d:	79 25                	jns    8016c4 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80169f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016aa:	e8 ed f5 ff ff       	call   800c9c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016bd:	e8 da f5 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  8016c2:	eb 02                	jmp    8016c6 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016c4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016c6:	89 d8                	mov    %ebx,%eax
  8016c8:	83 c4 4c             	add    $0x4c,%esp
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	5f                   	pop    %edi
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 24             	sub    $0x24,%esp
  8016d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e1:	89 1c 24             	mov    %ebx,(%esp)
  8016e4:	e8 49 fd ff ff       	call   801432 <fd_lookup>
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 6d                	js     80175a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f7:	8b 00                	mov    (%eax),%eax
  8016f9:	89 04 24             	mov    %eax,(%esp)
  8016fc:	e8 87 fd ff ff       	call   801488 <dev_lookup>
  801701:	85 c0                	test   %eax,%eax
  801703:	78 55                	js     80175a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801705:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801708:	8b 50 08             	mov    0x8(%eax),%edx
  80170b:	83 e2 03             	and    $0x3,%edx
  80170e:	83 fa 01             	cmp    $0x1,%edx
  801711:	75 23                	jne    801736 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801713:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801718:	8b 40 48             	mov    0x48(%eax),%eax
  80171b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80171f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801723:	c7 04 24 61 2e 80 00 	movl   $0x802e61,(%esp)
  80172a:	e8 29 eb ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  80172f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801734:	eb 24                	jmp    80175a <read+0x8a>
	}
	if (!dev->dev_read)
  801736:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801739:	8b 52 08             	mov    0x8(%edx),%edx
  80173c:	85 d2                	test   %edx,%edx
  80173e:	74 15                	je     801755 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801740:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801743:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80174e:	89 04 24             	mov    %eax,(%esp)
  801751:	ff d2                	call   *%edx
  801753:	eb 05                	jmp    80175a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801755:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80175a:	83 c4 24             	add    $0x24,%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	57                   	push   %edi
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
  801766:	83 ec 1c             	sub    $0x1c,%esp
  801769:	8b 7d 08             	mov    0x8(%ebp),%edi
  80176c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80176f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801774:	eb 23                	jmp    801799 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801776:	89 f0                	mov    %esi,%eax
  801778:	29 d8                	sub    %ebx,%eax
  80177a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80177e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801781:	01 d8                	add    %ebx,%eax
  801783:	89 44 24 04          	mov    %eax,0x4(%esp)
  801787:	89 3c 24             	mov    %edi,(%esp)
  80178a:	e8 41 ff ff ff       	call   8016d0 <read>
		if (m < 0)
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 10                	js     8017a3 <readn+0x43>
			return m;
		if (m == 0)
  801793:	85 c0                	test   %eax,%eax
  801795:	74 0a                	je     8017a1 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801797:	01 c3                	add    %eax,%ebx
  801799:	39 f3                	cmp    %esi,%ebx
  80179b:	72 d9                	jb     801776 <readn+0x16>
  80179d:	89 d8                	mov    %ebx,%eax
  80179f:	eb 02                	jmp    8017a3 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017a1:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017a3:	83 c4 1c             	add    $0x1c,%esp
  8017a6:	5b                   	pop    %ebx
  8017a7:	5e                   	pop    %esi
  8017a8:	5f                   	pop    %edi
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 24             	sub    $0x24,%esp
  8017b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bc:	89 1c 24             	mov    %ebx,(%esp)
  8017bf:	e8 6e fc ff ff       	call   801432 <fd_lookup>
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 68                	js     801830 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d2:	8b 00                	mov    (%eax),%eax
  8017d4:	89 04 24             	mov    %eax,(%esp)
  8017d7:	e8 ac fc ff ff       	call   801488 <dev_lookup>
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 50                	js     801830 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017e7:	75 23                	jne    80180c <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8017ee:	8b 40 48             	mov    0x48(%eax),%eax
  8017f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f9:	c7 04 24 7d 2e 80 00 	movl   $0x802e7d,(%esp)
  801800:	e8 53 ea ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  801805:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80180a:	eb 24                	jmp    801830 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80180c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180f:	8b 52 0c             	mov    0xc(%edx),%edx
  801812:	85 d2                	test   %edx,%edx
  801814:	74 15                	je     80182b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801816:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801819:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80181d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801820:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801824:	89 04 24             	mov    %eax,(%esp)
  801827:	ff d2                	call   *%edx
  801829:	eb 05                	jmp    801830 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80182b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801830:	83 c4 24             	add    $0x24,%esp
  801833:	5b                   	pop    %ebx
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    

00801836 <seek>:

int
seek(int fdnum, off_t offset)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80183f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	89 04 24             	mov    %eax,(%esp)
  801849:	e8 e4 fb ff ff       	call   801432 <fd_lookup>
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 0e                	js     801860 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801852:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801855:	8b 55 0c             	mov    0xc(%ebp),%edx
  801858:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80185b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	53                   	push   %ebx
  801866:	83 ec 24             	sub    $0x24,%esp
  801869:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801873:	89 1c 24             	mov    %ebx,(%esp)
  801876:	e8 b7 fb ff ff       	call   801432 <fd_lookup>
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 61                	js     8018e0 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801889:	8b 00                	mov    (%eax),%eax
  80188b:	89 04 24             	mov    %eax,(%esp)
  80188e:	e8 f5 fb ff ff       	call   801488 <dev_lookup>
  801893:	85 c0                	test   %eax,%eax
  801895:	78 49                	js     8018e0 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80189e:	75 23                	jne    8018c3 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a0:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018a5:	8b 40 48             	mov    0x48(%eax),%eax
  8018a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b0:	c7 04 24 40 2e 80 00 	movl   $0x802e40,(%esp)
  8018b7:	e8 9c e9 ff ff       	call   800258 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c1:	eb 1d                	jmp    8018e0 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c6:	8b 52 18             	mov    0x18(%edx),%edx
  8018c9:	85 d2                	test   %edx,%edx
  8018cb:	74 0e                	je     8018db <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018d4:	89 04 24             	mov    %eax,(%esp)
  8018d7:	ff d2                	call   *%edx
  8018d9:	eb 05                	jmp    8018e0 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018e0:	83 c4 24             	add    $0x24,%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    

008018e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	53                   	push   %ebx
  8018ea:	83 ec 24             	sub    $0x24,%esp
  8018ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	89 04 24             	mov    %eax,(%esp)
  8018fd:	e8 30 fb ff ff       	call   801432 <fd_lookup>
  801902:	85 c0                	test   %eax,%eax
  801904:	78 52                	js     801958 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801906:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801910:	8b 00                	mov    (%eax),%eax
  801912:	89 04 24             	mov    %eax,(%esp)
  801915:	e8 6e fb ff ff       	call   801488 <dev_lookup>
  80191a:	85 c0                	test   %eax,%eax
  80191c:	78 3a                	js     801958 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80191e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801921:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801925:	74 2c                	je     801953 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801927:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80192a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801931:	00 00 00 
	stat->st_isdir = 0;
  801934:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80193b:	00 00 00 
	stat->st_dev = dev;
  80193e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801944:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801948:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80194b:	89 14 24             	mov    %edx,(%esp)
  80194e:	ff 50 14             	call   *0x14(%eax)
  801951:	eb 05                	jmp    801958 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801953:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801958:	83 c4 24             	add    $0x24,%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	56                   	push   %esi
  801962:	53                   	push   %ebx
  801963:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801966:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80196d:	00 
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	89 04 24             	mov    %eax,(%esp)
  801974:	e8 2a 02 00 00       	call   801ba3 <open>
  801979:	89 c3                	mov    %eax,%ebx
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 1b                	js     80199a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80197f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801982:	89 44 24 04          	mov    %eax,0x4(%esp)
  801986:	89 1c 24             	mov    %ebx,(%esp)
  801989:	e8 58 ff ff ff       	call   8018e6 <fstat>
  80198e:	89 c6                	mov    %eax,%esi
	close(fd);
  801990:	89 1c 24             	mov    %ebx,(%esp)
  801993:	e8 d2 fb ff ff       	call   80156a <close>
	return r;
  801998:	89 f3                	mov    %esi,%ebx
}
  80199a:	89 d8                	mov    %ebx,%eax
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    
	...

008019a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	83 ec 10             	sub    $0x10,%esp
  8019ac:	89 c3                	mov    %eax,%ebx
  8019ae:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019b0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019b7:	75 11                	jne    8019ca <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019c0:	e8 aa f9 ff ff       	call   80136f <ipc_find_env>
  8019c5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019ca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019d1:	00 
  8019d2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019d9:	00 
  8019da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019de:	a1 00 40 80 00       	mov    0x804000,%eax
  8019e3:	89 04 24             	mov    %eax,(%esp)
  8019e6:	e8 01 f9 ff ff       	call   8012ec <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f2:	00 
  8019f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fe:	e8 79 f8 ff ff       	call   80127c <ipc_recv>
}
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    

00801a0a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	8b 40 0c             	mov    0xc(%eax),%eax
  801a16:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a23:	ba 00 00 00 00       	mov    $0x0,%edx
  801a28:	b8 02 00 00 00       	mov    $0x2,%eax
  801a2d:	e8 72 ff ff ff       	call   8019a4 <fsipc>
}
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a40:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a45:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4a:	b8 06 00 00 00       	mov    $0x6,%eax
  801a4f:	e8 50 ff ff ff       	call   8019a4 <fsipc>
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	53                   	push   %ebx
  801a5a:	83 ec 14             	sub    $0x14,%esp
  801a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	8b 40 0c             	mov    0xc(%eax),%eax
  801a66:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a70:	b8 05 00 00 00       	mov    $0x5,%eax
  801a75:	e8 2a ff ff ff       	call   8019a4 <fsipc>
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 2b                	js     801aa9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a7e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a85:	00 
  801a86:	89 1c 24             	mov    %ebx,(%esp)
  801a89:	e8 75 ed ff ff       	call   800803 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a8e:	a1 80 50 80 00       	mov    0x805080,%eax
  801a93:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a99:	a1 84 50 80 00       	mov    0x805084,%eax
  801a9e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa9:	83 c4 14             	add    $0x14,%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	83 ec 18             	sub    $0x18,%esp
  801ab5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  801abb:	8b 52 0c             	mov    0xc(%edx),%edx
  801abe:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801ac4:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801ac9:	89 c2                	mov    %eax,%edx
  801acb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ad0:	76 05                	jbe    801ad7 <devfile_write+0x28>
  801ad2:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801ad7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801ae9:	e8 f8 ee ff ff       	call   8009e6 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801aee:	ba 00 00 00 00       	mov    $0x0,%edx
  801af3:	b8 04 00 00 00       	mov    $0x4,%eax
  801af8:	e8 a7 fe ff ff       	call   8019a4 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 10             	sub    $0x10,%esp
  801b07:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b10:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b15:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b20:	b8 03 00 00 00       	mov    $0x3,%eax
  801b25:	e8 7a fe ff ff       	call   8019a4 <fsipc>
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 6a                	js     801b9a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b30:	39 c6                	cmp    %eax,%esi
  801b32:	73 24                	jae    801b58 <devfile_read+0x59>
  801b34:	c7 44 24 0c b0 2e 80 	movl   $0x802eb0,0xc(%esp)
  801b3b:	00 
  801b3c:	c7 44 24 08 b7 2e 80 	movl   $0x802eb7,0x8(%esp)
  801b43:	00 
  801b44:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b4b:	00 
  801b4c:	c7 04 24 cc 2e 80 00 	movl   $0x802ecc,(%esp)
  801b53:	e8 00 0b 00 00       	call   802658 <_panic>
	assert(r <= PGSIZE);
  801b58:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b5d:	7e 24                	jle    801b83 <devfile_read+0x84>
  801b5f:	c7 44 24 0c d7 2e 80 	movl   $0x802ed7,0xc(%esp)
  801b66:	00 
  801b67:	c7 44 24 08 b7 2e 80 	movl   $0x802eb7,0x8(%esp)
  801b6e:	00 
  801b6f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b76:	00 
  801b77:	c7 04 24 cc 2e 80 00 	movl   $0x802ecc,(%esp)
  801b7e:	e8 d5 0a 00 00       	call   802658 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b87:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b8e:	00 
  801b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 e2 ed ff ff       	call   80097c <memmove>
	return r;
}
  801b9a:	89 d8                	mov    %ebx,%eax
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	5b                   	pop    %ebx
  801ba0:	5e                   	pop    %esi
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 20             	sub    $0x20,%esp
  801bab:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bae:	89 34 24             	mov    %esi,(%esp)
  801bb1:	e8 1a ec ff ff       	call   8007d0 <strlen>
  801bb6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bbb:	7f 60                	jg     801c1d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc0:	89 04 24             	mov    %eax,(%esp)
  801bc3:	e8 17 f8 ff ff       	call   8013df <fd_alloc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	78 54                	js     801c22 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bce:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bd2:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bd9:	e8 25 ec ff ff       	call   800803 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bee:	e8 b1 fd ff ff       	call   8019a4 <fsipc>
  801bf3:	89 c3                	mov    %eax,%ebx
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	79 15                	jns    801c0e <open+0x6b>
		fd_close(fd, 0);
  801bf9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c00:	00 
  801c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c04:	89 04 24             	mov    %eax,(%esp)
  801c07:	e8 d6 f8 ff ff       	call   8014e2 <fd_close>
		return r;
  801c0c:	eb 14                	jmp    801c22 <open+0x7f>
	}

	return fd2num(fd);
  801c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c11:	89 04 24             	mov    %eax,(%esp)
  801c14:	e8 9b f7 ff ff       	call   8013b4 <fd2num>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	eb 05                	jmp    801c22 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c1d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c22:	89 d8                	mov    %ebx,%eax
  801c24:	83 c4 20             	add    $0x20,%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c31:	ba 00 00 00 00       	mov    $0x0,%edx
  801c36:	b8 08 00 00 00       	mov    $0x8,%eax
  801c3b:	e8 64 fd ff ff       	call   8019a4 <fsipc>
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    
	...

00801c44 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c4a:	c7 44 24 04 e3 2e 80 	movl   $0x802ee3,0x4(%esp)
  801c51:	00 
  801c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 a6 eb ff ff       	call   800803 <strcpy>
	return 0;
}
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	53                   	push   %ebx
  801c68:	83 ec 14             	sub    $0x14,%esp
  801c6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c6e:	89 1c 24             	mov    %ebx,(%esp)
  801c71:	e8 ae 0a 00 00       	call   802724 <pageref>
  801c76:	83 f8 01             	cmp    $0x1,%eax
  801c79:	75 0d                	jne    801c88 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801c7b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c7e:	89 04 24             	mov    %eax,(%esp)
  801c81:	e8 1f 03 00 00       	call   801fa5 <nsipc_close>
  801c86:	eb 05                	jmp    801c8d <devsock_close+0x29>
	else
		return 0;
  801c88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c8d:	83 c4 14             	add    $0x14,%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c99:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ca0:	00 
  801ca1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	8b 40 0c             	mov    0xc(%eax),%eax
  801cb5:	89 04 24             	mov    %eax,(%esp)
  801cb8:	e8 e3 03 00 00       	call   8020a0 <nsipc_send>
}
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cc5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ccc:	00 
  801ccd:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce1:	89 04 24             	mov    %eax,(%esp)
  801ce4:	e8 37 03 00 00       	call   802020 <nsipc_recv>
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	56                   	push   %esi
  801cef:	53                   	push   %ebx
  801cf0:	83 ec 20             	sub    $0x20,%esp
  801cf3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801cf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf8:	89 04 24             	mov    %eax,(%esp)
  801cfb:	e8 df f6 ff ff       	call   8013df <fd_alloc>
  801d00:	89 c3                	mov    %eax,%ebx
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 21                	js     801d27 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d06:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d0d:	00 
  801d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d1c:	e8 d4 ee ff ff       	call   800bf5 <sys_page_alloc>
  801d21:	89 c3                	mov    %eax,%ebx
  801d23:	85 c0                	test   %eax,%eax
  801d25:	79 0a                	jns    801d31 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801d27:	89 34 24             	mov    %esi,(%esp)
  801d2a:	e8 76 02 00 00       	call   801fa5 <nsipc_close>
		return r;
  801d2f:	eb 22                	jmp    801d53 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d31:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d46:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d49:	89 04 24             	mov    %eax,(%esp)
  801d4c:	e8 63 f6 ff ff       	call   8013b4 <fd2num>
  801d51:	89 c3                	mov    %eax,%ebx
}
  801d53:	89 d8                	mov    %ebx,%eax
  801d55:	83 c4 20             	add    $0x20,%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    

00801d5c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d65:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d69:	89 04 24             	mov    %eax,(%esp)
  801d6c:	e8 c1 f6 ff ff       	call   801432 <fd_lookup>
  801d71:	85 c0                	test   %eax,%eax
  801d73:	78 17                	js     801d8c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d78:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d7e:	39 10                	cmp    %edx,(%eax)
  801d80:	75 05                	jne    801d87 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d82:	8b 40 0c             	mov    0xc(%eax),%eax
  801d85:	eb 05                	jmp    801d8c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d87:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	e8 c0 ff ff ff       	call   801d5c <fd2sockid>
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	78 1f                	js     801dbf <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801da0:	8b 55 10             	mov    0x10(%ebp),%edx
  801da3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801da7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801daa:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dae:	89 04 24             	mov    %eax,(%esp)
  801db1:	e8 38 01 00 00       	call   801eee <nsipc_accept>
  801db6:	85 c0                	test   %eax,%eax
  801db8:	78 05                	js     801dbf <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801dba:	e8 2c ff ff ff       	call   801ceb <alloc_sockfd>
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dca:	e8 8d ff ff ff       	call   801d5c <fd2sockid>
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 16                	js     801de9 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801dd3:	8b 55 10             	mov    0x10(%ebp),%edx
  801dd6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ddd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de1:	89 04 24             	mov    %eax,(%esp)
  801de4:	e8 5b 01 00 00       	call   801f44 <nsipc_bind>
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <shutdown>:

int
shutdown(int s, int how)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df1:	8b 45 08             	mov    0x8(%ebp),%eax
  801df4:	e8 63 ff ff ff       	call   801d5c <fd2sockid>
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	78 0f                	js     801e0c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801dfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e00:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e04:	89 04 24             	mov    %eax,(%esp)
  801e07:	e8 77 01 00 00       	call   801f83 <nsipc_shutdown>
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	e8 40 ff ff ff       	call   801d5c <fd2sockid>
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	78 16                	js     801e36 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801e20:	8b 55 10             	mov    0x10(%ebp),%edx
  801e23:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e2e:	89 04 24             	mov    %eax,(%esp)
  801e31:	e8 89 01 00 00       	call   801fbf <nsipc_connect>
}
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <listen>:

int
listen(int s, int backlog)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	e8 16 ff ff ff       	call   801d5c <fd2sockid>
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 0f                	js     801e59 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e51:	89 04 24             	mov    %eax,(%esp)
  801e54:	e8 a5 01 00 00       	call   801ffe <nsipc_listen>
}
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    

00801e5b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e61:	8b 45 10             	mov    0x10(%ebp),%eax
  801e64:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e72:	89 04 24             	mov    %eax,(%esp)
  801e75:	e8 99 02 00 00       	call   802113 <nsipc_socket>
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	78 05                	js     801e83 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801e7e:	e8 68 fe ff ff       	call   801ceb <alloc_sockfd>
}
  801e83:	c9                   	leave  
  801e84:	c3                   	ret    
  801e85:	00 00                	add    %al,(%eax)
	...

00801e88 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	53                   	push   %ebx
  801e8c:	83 ec 14             	sub    $0x14,%esp
  801e8f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e91:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e98:	75 11                	jne    801eab <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e9a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ea1:	e8 c9 f4 ff ff       	call   80136f <ipc_find_env>
  801ea6:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801eab:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801eb2:	00 
  801eb3:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801eba:	00 
  801ebb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ebf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec4:	89 04 24             	mov    %eax,(%esp)
  801ec7:	e8 20 f4 ff ff       	call   8012ec <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ecc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ed3:	00 
  801ed4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801edb:	00 
  801edc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee3:	e8 94 f3 ff ff       	call   80127c <ipc_recv>
}
  801ee8:	83 c4 14             	add    $0x14,%esp
  801eeb:	5b                   	pop    %ebx
  801eec:	5d                   	pop    %ebp
  801eed:	c3                   	ret    

00801eee <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	56                   	push   %esi
  801ef2:	53                   	push   %ebx
  801ef3:	83 ec 10             	sub    $0x10,%esp
  801ef6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  801efc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f01:	8b 06                	mov    (%esi),%eax
  801f03:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f08:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0d:	e8 76 ff ff ff       	call   801e88 <nsipc>
  801f12:	89 c3                	mov    %eax,%ebx
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 23                	js     801f3b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f18:	a1 10 60 80 00       	mov    0x806010,%eax
  801f1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f21:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f28:	00 
  801f29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2c:	89 04 24             	mov    %eax,(%esp)
  801f2f:	e8 48 ea ff ff       	call   80097c <memmove>
		*addrlen = ret->ret_addrlen;
  801f34:	a1 10 60 80 00       	mov    0x806010,%eax
  801f39:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f3b:	89 d8                	mov    %ebx,%eax
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	53                   	push   %ebx
  801f48:	83 ec 14             	sub    $0x14,%esp
  801f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f51:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f56:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f61:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f68:	e8 0f ea ff ff       	call   80097c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f6d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f73:	b8 02 00 00 00       	mov    $0x2,%eax
  801f78:	e8 0b ff ff ff       	call   801e88 <nsipc>
}
  801f7d:	83 c4 14             	add    $0x14,%esp
  801f80:	5b                   	pop    %ebx
  801f81:	5d                   	pop    %ebp
  801f82:	c3                   	ret    

00801f83 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f89:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f94:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f99:	b8 03 00 00 00       	mov    $0x3,%eax
  801f9e:	e8 e5 fe ff ff       	call   801e88 <nsipc>
}
  801fa3:	c9                   	leave  
  801fa4:	c3                   	ret    

00801fa5 <nsipc_close>:

int
nsipc_close(int s)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801fb3:	b8 04 00 00 00       	mov    $0x4,%eax
  801fb8:	e8 cb fe ff ff       	call   801e88 <nsipc>
}
  801fbd:	c9                   	leave  
  801fbe:	c3                   	ret    

00801fbf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	53                   	push   %ebx
  801fc3:	83 ec 14             	sub    $0x14,%esp
  801fc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fd1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fdc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801fe3:	e8 94 e9 ff ff       	call   80097c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fe8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fee:	b8 05 00 00 00       	mov    $0x5,%eax
  801ff3:	e8 90 fe ff ff       	call   801e88 <nsipc>
}
  801ff8:	83 c4 14             	add    $0x14,%esp
  801ffb:	5b                   	pop    %ebx
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    

00801ffe <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802004:	8b 45 08             	mov    0x8(%ebp),%eax
  802007:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80200c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802014:	b8 06 00 00 00       	mov    $0x6,%eax
  802019:	e8 6a fe ff ff       	call   801e88 <nsipc>
}
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	83 ec 10             	sub    $0x10,%esp
  802028:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80202b:	8b 45 08             	mov    0x8(%ebp),%eax
  80202e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802033:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802039:	8b 45 14             	mov    0x14(%ebp),%eax
  80203c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802041:	b8 07 00 00 00       	mov    $0x7,%eax
  802046:	e8 3d fe ff ff       	call   801e88 <nsipc>
  80204b:	89 c3                	mov    %eax,%ebx
  80204d:	85 c0                	test   %eax,%eax
  80204f:	78 46                	js     802097 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802051:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802056:	7f 04                	jg     80205c <nsipc_recv+0x3c>
  802058:	39 c6                	cmp    %eax,%esi
  80205a:	7d 24                	jge    802080 <nsipc_recv+0x60>
  80205c:	c7 44 24 0c ef 2e 80 	movl   $0x802eef,0xc(%esp)
  802063:	00 
  802064:	c7 44 24 08 b7 2e 80 	movl   $0x802eb7,0x8(%esp)
  80206b:	00 
  80206c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802073:	00 
  802074:	c7 04 24 04 2f 80 00 	movl   $0x802f04,(%esp)
  80207b:	e8 d8 05 00 00       	call   802658 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802080:	89 44 24 08          	mov    %eax,0x8(%esp)
  802084:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80208b:	00 
  80208c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208f:	89 04 24             	mov    %eax,(%esp)
  802092:	e8 e5 e8 ff ff       	call   80097c <memmove>
	}

	return r;
}
  802097:	89 d8                	mov    %ebx,%eax
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	5b                   	pop    %ebx
  80209d:	5e                   	pop    %esi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    

008020a0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 14             	sub    $0x14,%esp
  8020a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ad:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8020b2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020b8:	7e 24                	jle    8020de <nsipc_send+0x3e>
  8020ba:	c7 44 24 0c 10 2f 80 	movl   $0x802f10,0xc(%esp)
  8020c1:	00 
  8020c2:	c7 44 24 08 b7 2e 80 	movl   $0x802eb7,0x8(%esp)
  8020c9:	00 
  8020ca:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8020d1:	00 
  8020d2:	c7 04 24 04 2f 80 00 	movl   $0x802f04,(%esp)
  8020d9:	e8 7a 05 00 00       	call   802658 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e9:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8020f0:	e8 87 e8 ff ff       	call   80097c <memmove>
	nsipcbuf.send.req_size = size;
  8020f5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8020fe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802103:	b8 08 00 00 00       	mov    $0x8,%eax
  802108:	e8 7b fd ff ff       	call   801e88 <nsipc>
}
  80210d:	83 c4 14             	add    $0x14,%esp
  802110:	5b                   	pop    %ebx
  802111:	5d                   	pop    %ebp
  802112:	c3                   	ret    

00802113 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802113:	55                   	push   %ebp
  802114:	89 e5                	mov    %esp,%ebp
  802116:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802119:	8b 45 08             	mov    0x8(%ebp),%eax
  80211c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802121:	8b 45 0c             	mov    0xc(%ebp),%eax
  802124:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802129:	8b 45 10             	mov    0x10(%ebp),%eax
  80212c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802131:	b8 09 00 00 00       	mov    $0x9,%eax
  802136:	e8 4d fd ff ff       	call   801e88 <nsipc>
}
  80213b:	c9                   	leave  
  80213c:	c3                   	ret    
  80213d:	00 00                	add    %al,(%eax)
	...

00802140 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	56                   	push   %esi
  802144:	53                   	push   %ebx
  802145:	83 ec 10             	sub    $0x10,%esp
  802148:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80214b:	8b 45 08             	mov    0x8(%ebp),%eax
  80214e:	89 04 24             	mov    %eax,(%esp)
  802151:	e8 6e f2 ff ff       	call   8013c4 <fd2data>
  802156:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802158:	c7 44 24 04 1c 2f 80 	movl   $0x802f1c,0x4(%esp)
  80215f:	00 
  802160:	89 34 24             	mov    %esi,(%esp)
  802163:	e8 9b e6 ff ff       	call   800803 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802168:	8b 43 04             	mov    0x4(%ebx),%eax
  80216b:	2b 03                	sub    (%ebx),%eax
  80216d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802173:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80217a:	00 00 00 
	stat->st_dev = &devpipe;
  80217d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  802184:	30 80 00 
	return 0;
}
  802187:	b8 00 00 00 00       	mov    $0x0,%eax
  80218c:	83 c4 10             	add    $0x10,%esp
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5d                   	pop    %ebp
  802192:	c3                   	ret    

00802193 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	53                   	push   %ebx
  802197:	83 ec 14             	sub    $0x14,%esp
  80219a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80219d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a8:	e8 ef ea ff ff       	call   800c9c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021ad:	89 1c 24             	mov    %ebx,(%esp)
  8021b0:	e8 0f f2 ff ff       	call   8013c4 <fd2data>
  8021b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c0:	e8 d7 ea ff ff       	call   800c9c <sys_page_unmap>
}
  8021c5:	83 c4 14             	add    $0x14,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    

008021cb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	57                   	push   %edi
  8021cf:	56                   	push   %esi
  8021d0:	53                   	push   %ebx
  8021d1:	83 ec 2c             	sub    $0x2c,%esp
  8021d4:	89 c7                	mov    %eax,%edi
  8021d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021d9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8021de:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021e1:	89 3c 24             	mov    %edi,(%esp)
  8021e4:	e8 3b 05 00 00       	call   802724 <pageref>
  8021e9:	89 c6                	mov    %eax,%esi
  8021eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ee:	89 04 24             	mov    %eax,(%esp)
  8021f1:	e8 2e 05 00 00       	call   802724 <pageref>
  8021f6:	39 c6                	cmp    %eax,%esi
  8021f8:	0f 94 c0             	sete   %al
  8021fb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021fe:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  802204:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802207:	39 cb                	cmp    %ecx,%ebx
  802209:	75 08                	jne    802213 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80220b:	83 c4 2c             	add    $0x2c,%esp
  80220e:	5b                   	pop    %ebx
  80220f:	5e                   	pop    %esi
  802210:	5f                   	pop    %edi
  802211:	5d                   	pop    %ebp
  802212:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802213:	83 f8 01             	cmp    $0x1,%eax
  802216:	75 c1                	jne    8021d9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802218:	8b 42 58             	mov    0x58(%edx),%eax
  80221b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802222:	00 
  802223:	89 44 24 08          	mov    %eax,0x8(%esp)
  802227:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80222b:	c7 04 24 23 2f 80 00 	movl   $0x802f23,(%esp)
  802232:	e8 21 e0 ff ff       	call   800258 <cprintf>
  802237:	eb a0                	jmp    8021d9 <_pipeisclosed+0xe>

00802239 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	57                   	push   %edi
  80223d:	56                   	push   %esi
  80223e:	53                   	push   %ebx
  80223f:	83 ec 1c             	sub    $0x1c,%esp
  802242:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802245:	89 34 24             	mov    %esi,(%esp)
  802248:	e8 77 f1 ff ff       	call   8013c4 <fd2data>
  80224d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80224f:	bf 00 00 00 00       	mov    $0x0,%edi
  802254:	eb 3c                	jmp    802292 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802256:	89 da                	mov    %ebx,%edx
  802258:	89 f0                	mov    %esi,%eax
  80225a:	e8 6c ff ff ff       	call   8021cb <_pipeisclosed>
  80225f:	85 c0                	test   %eax,%eax
  802261:	75 38                	jne    80229b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802263:	e8 6e e9 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802268:	8b 43 04             	mov    0x4(%ebx),%eax
  80226b:	8b 13                	mov    (%ebx),%edx
  80226d:	83 c2 20             	add    $0x20,%edx
  802270:	39 d0                	cmp    %edx,%eax
  802272:	73 e2                	jae    802256 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802274:	8b 55 0c             	mov    0xc(%ebp),%edx
  802277:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80227a:	89 c2                	mov    %eax,%edx
  80227c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802282:	79 05                	jns    802289 <devpipe_write+0x50>
  802284:	4a                   	dec    %edx
  802285:	83 ca e0             	or     $0xffffffe0,%edx
  802288:	42                   	inc    %edx
  802289:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80228d:	40                   	inc    %eax
  80228e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802291:	47                   	inc    %edi
  802292:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802295:	75 d1                	jne    802268 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802297:	89 f8                	mov    %edi,%eax
  802299:	eb 05                	jmp    8022a0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80229b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    

008022a8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	57                   	push   %edi
  8022ac:	56                   	push   %esi
  8022ad:	53                   	push   %ebx
  8022ae:	83 ec 1c             	sub    $0x1c,%esp
  8022b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022b4:	89 3c 24             	mov    %edi,(%esp)
  8022b7:	e8 08 f1 ff ff       	call   8013c4 <fd2data>
  8022bc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022be:	be 00 00 00 00       	mov    $0x0,%esi
  8022c3:	eb 3a                	jmp    8022ff <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022c5:	85 f6                	test   %esi,%esi
  8022c7:	74 04                	je     8022cd <devpipe_read+0x25>
				return i;
  8022c9:	89 f0                	mov    %esi,%eax
  8022cb:	eb 40                	jmp    80230d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022cd:	89 da                	mov    %ebx,%edx
  8022cf:	89 f8                	mov    %edi,%eax
  8022d1:	e8 f5 fe ff ff       	call   8021cb <_pipeisclosed>
  8022d6:	85 c0                	test   %eax,%eax
  8022d8:	75 2e                	jne    802308 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022da:	e8 f7 e8 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022df:	8b 03                	mov    (%ebx),%eax
  8022e1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022e4:	74 df                	je     8022c5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022e6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8022eb:	79 05                	jns    8022f2 <devpipe_read+0x4a>
  8022ed:	48                   	dec    %eax
  8022ee:	83 c8 e0             	or     $0xffffffe0,%eax
  8022f1:	40                   	inc    %eax
  8022f2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022f9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022fc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022fe:	46                   	inc    %esi
  8022ff:	3b 75 10             	cmp    0x10(%ebp),%esi
  802302:	75 db                	jne    8022df <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802304:	89 f0                	mov    %esi,%eax
  802306:	eb 05                	jmp    80230d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802308:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80230d:	83 c4 1c             	add    $0x1c,%esp
  802310:	5b                   	pop    %ebx
  802311:	5e                   	pop    %esi
  802312:	5f                   	pop    %edi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    

00802315 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
  802318:	57                   	push   %edi
  802319:	56                   	push   %esi
  80231a:	53                   	push   %ebx
  80231b:	83 ec 3c             	sub    $0x3c,%esp
  80231e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802321:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802324:	89 04 24             	mov    %eax,(%esp)
  802327:	e8 b3 f0 ff ff       	call   8013df <fd_alloc>
  80232c:	89 c3                	mov    %eax,%ebx
  80232e:	85 c0                	test   %eax,%eax
  802330:	0f 88 45 01 00 00    	js     80247b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802336:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80233d:	00 
  80233e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802341:	89 44 24 04          	mov    %eax,0x4(%esp)
  802345:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80234c:	e8 a4 e8 ff ff       	call   800bf5 <sys_page_alloc>
  802351:	89 c3                	mov    %eax,%ebx
  802353:	85 c0                	test   %eax,%eax
  802355:	0f 88 20 01 00 00    	js     80247b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80235b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80235e:	89 04 24             	mov    %eax,(%esp)
  802361:	e8 79 f0 ff ff       	call   8013df <fd_alloc>
  802366:	89 c3                	mov    %eax,%ebx
  802368:	85 c0                	test   %eax,%eax
  80236a:	0f 88 f8 00 00 00    	js     802468 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802370:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802377:	00 
  802378:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80237b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802386:	e8 6a e8 ff ff       	call   800bf5 <sys_page_alloc>
  80238b:	89 c3                	mov    %eax,%ebx
  80238d:	85 c0                	test   %eax,%eax
  80238f:	0f 88 d3 00 00 00    	js     802468 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802395:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802398:	89 04 24             	mov    %eax,(%esp)
  80239b:	e8 24 f0 ff ff       	call   8013c4 <fd2data>
  8023a0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023a9:	00 
  8023aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b5:	e8 3b e8 ff ff       	call   800bf5 <sys_page_alloc>
  8023ba:	89 c3                	mov    %eax,%ebx
  8023bc:	85 c0                	test   %eax,%eax
  8023be:	0f 88 91 00 00 00    	js     802455 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023c7:	89 04 24             	mov    %eax,(%esp)
  8023ca:	e8 f5 ef ff ff       	call   8013c4 <fd2data>
  8023cf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8023d6:	00 
  8023d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023e2:	00 
  8023e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ee:	e8 56 e8 ff ff       	call   800c49 <sys_page_map>
  8023f3:	89 c3                	mov    %eax,%ebx
  8023f5:	85 c0                	test   %eax,%eax
  8023f7:	78 4c                	js     802445 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023f9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802402:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802407:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80240e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802414:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802417:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802419:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80241c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802423:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802426:	89 04 24             	mov    %eax,(%esp)
  802429:	e8 86 ef ff ff       	call   8013b4 <fd2num>
  80242e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802430:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802433:	89 04 24             	mov    %eax,(%esp)
  802436:	e8 79 ef ff ff       	call   8013b4 <fd2num>
  80243b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80243e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802443:	eb 36                	jmp    80247b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802445:	89 74 24 04          	mov    %esi,0x4(%esp)
  802449:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802450:	e8 47 e8 ff ff       	call   800c9c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802455:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802463:	e8 34 e8 ff ff       	call   800c9c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802468:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80246b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80246f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802476:	e8 21 e8 ff ff       	call   800c9c <sys_page_unmap>
    err:
	return r;
}
  80247b:	89 d8                	mov    %ebx,%eax
  80247d:	83 c4 3c             	add    $0x3c,%esp
  802480:	5b                   	pop    %ebx
  802481:	5e                   	pop    %esi
  802482:	5f                   	pop    %edi
  802483:	5d                   	pop    %ebp
  802484:	c3                   	ret    

00802485 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802485:	55                   	push   %ebp
  802486:	89 e5                	mov    %esp,%ebp
  802488:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80248b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80248e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802492:	8b 45 08             	mov    0x8(%ebp),%eax
  802495:	89 04 24             	mov    %eax,(%esp)
  802498:	e8 95 ef ff ff       	call   801432 <fd_lookup>
  80249d:	85 c0                	test   %eax,%eax
  80249f:	78 15                	js     8024b6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a4:	89 04 24             	mov    %eax,(%esp)
  8024a7:	e8 18 ef ff ff       	call   8013c4 <fd2data>
	return _pipeisclosed(fd, p);
  8024ac:	89 c2                	mov    %eax,%edx
  8024ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b1:	e8 15 fd ff ff       	call   8021cb <_pipeisclosed>
}
  8024b6:	c9                   	leave  
  8024b7:	c3                   	ret    

008024b8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024b8:	55                   	push   %ebp
  8024b9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8024c0:	5d                   	pop    %ebp
  8024c1:	c3                   	ret    

008024c2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024c2:	55                   	push   %ebp
  8024c3:	89 e5                	mov    %esp,%ebp
  8024c5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8024c8:	c7 44 24 04 3b 2f 80 	movl   $0x802f3b,0x4(%esp)
  8024cf:	00 
  8024d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d3:	89 04 24             	mov    %eax,(%esp)
  8024d6:	e8 28 e3 ff ff       	call   800803 <strcpy>
	return 0;
}
  8024db:	b8 00 00 00 00       	mov    $0x0,%eax
  8024e0:	c9                   	leave  
  8024e1:	c3                   	ret    

008024e2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024e2:	55                   	push   %ebp
  8024e3:	89 e5                	mov    %esp,%ebp
  8024e5:	57                   	push   %edi
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
  8024e8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024f3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024f9:	eb 30                	jmp    80252b <devcons_write+0x49>
		m = n - tot;
  8024fb:	8b 75 10             	mov    0x10(%ebp),%esi
  8024fe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802500:	83 fe 7f             	cmp    $0x7f,%esi
  802503:	76 05                	jbe    80250a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802505:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80250a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80250e:	03 45 0c             	add    0xc(%ebp),%eax
  802511:	89 44 24 04          	mov    %eax,0x4(%esp)
  802515:	89 3c 24             	mov    %edi,(%esp)
  802518:	e8 5f e4 ff ff       	call   80097c <memmove>
		sys_cputs(buf, m);
  80251d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802521:	89 3c 24             	mov    %edi,(%esp)
  802524:	e8 ff e5 ff ff       	call   800b28 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802529:	01 f3                	add    %esi,%ebx
  80252b:	89 d8                	mov    %ebx,%eax
  80252d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802530:	72 c9                	jb     8024fb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802532:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802538:	5b                   	pop    %ebx
  802539:	5e                   	pop    %esi
  80253a:	5f                   	pop    %edi
  80253b:	5d                   	pop    %ebp
  80253c:	c3                   	ret    

0080253d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80253d:	55                   	push   %ebp
  80253e:	89 e5                	mov    %esp,%ebp
  802540:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802543:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802547:	75 07                	jne    802550 <devcons_read+0x13>
  802549:	eb 25                	jmp    802570 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80254b:	e8 86 e6 ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802550:	e8 f1 e5 ff ff       	call   800b46 <sys_cgetc>
  802555:	85 c0                	test   %eax,%eax
  802557:	74 f2                	je     80254b <devcons_read+0xe>
  802559:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80255b:	85 c0                	test   %eax,%eax
  80255d:	78 1d                	js     80257c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80255f:	83 f8 04             	cmp    $0x4,%eax
  802562:	74 13                	je     802577 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802564:	8b 45 0c             	mov    0xc(%ebp),%eax
  802567:	88 10                	mov    %dl,(%eax)
	return 1;
  802569:	b8 01 00 00 00       	mov    $0x1,%eax
  80256e:	eb 0c                	jmp    80257c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802570:	b8 00 00 00 00       	mov    $0x0,%eax
  802575:	eb 05                	jmp    80257c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802577:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80257c:	c9                   	leave  
  80257d:	c3                   	ret    

0080257e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80257e:	55                   	push   %ebp
  80257f:	89 e5                	mov    %esp,%ebp
  802581:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802584:	8b 45 08             	mov    0x8(%ebp),%eax
  802587:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80258a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802591:	00 
  802592:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802595:	89 04 24             	mov    %eax,(%esp)
  802598:	e8 8b e5 ff ff       	call   800b28 <sys_cputs>
}
  80259d:	c9                   	leave  
  80259e:	c3                   	ret    

0080259f <getchar>:

int
getchar(void)
{
  80259f:	55                   	push   %ebp
  8025a0:	89 e5                	mov    %esp,%ebp
  8025a2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8025ac:	00 
  8025ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025bb:	e8 10 f1 ff ff       	call   8016d0 <read>
	if (r < 0)
  8025c0:	85 c0                	test   %eax,%eax
  8025c2:	78 0f                	js     8025d3 <getchar+0x34>
		return r;
	if (r < 1)
  8025c4:	85 c0                	test   %eax,%eax
  8025c6:	7e 06                	jle    8025ce <getchar+0x2f>
		return -E_EOF;
	return c;
  8025c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025cc:	eb 05                	jmp    8025d3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025d3:	c9                   	leave  
  8025d4:	c3                   	ret    

008025d5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025d5:	55                   	push   %ebp
  8025d6:	89 e5                	mov    %esp,%ebp
  8025d8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e5:	89 04 24             	mov    %eax,(%esp)
  8025e8:	e8 45 ee ff ff       	call   801432 <fd_lookup>
  8025ed:	85 c0                	test   %eax,%eax
  8025ef:	78 11                	js     802602 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025fa:	39 10                	cmp    %edx,(%eax)
  8025fc:	0f 94 c0             	sete   %al
  8025ff:	0f b6 c0             	movzbl %al,%eax
}
  802602:	c9                   	leave  
  802603:	c3                   	ret    

00802604 <opencons>:

int
opencons(void)
{
  802604:	55                   	push   %ebp
  802605:	89 e5                	mov    %esp,%ebp
  802607:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80260a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80260d:	89 04 24             	mov    %eax,(%esp)
  802610:	e8 ca ed ff ff       	call   8013df <fd_alloc>
  802615:	85 c0                	test   %eax,%eax
  802617:	78 3c                	js     802655 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802619:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802620:	00 
  802621:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802624:	89 44 24 04          	mov    %eax,0x4(%esp)
  802628:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80262f:	e8 c1 e5 ff ff       	call   800bf5 <sys_page_alloc>
  802634:	85 c0                	test   %eax,%eax
  802636:	78 1d                	js     802655 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802638:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80263e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802641:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802643:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802646:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80264d:	89 04 24             	mov    %eax,(%esp)
  802650:	e8 5f ed ff ff       	call   8013b4 <fd2num>
}
  802655:	c9                   	leave  
  802656:	c3                   	ret    
	...

00802658 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802658:	55                   	push   %ebp
  802659:	89 e5                	mov    %esp,%ebp
  80265b:	56                   	push   %esi
  80265c:	53                   	push   %ebx
  80265d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802660:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802663:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802669:	e8 49 e5 ff ff       	call   800bb7 <sys_getenvid>
  80266e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802671:	89 54 24 10          	mov    %edx,0x10(%esp)
  802675:	8b 55 08             	mov    0x8(%ebp),%edx
  802678:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80267c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802680:	89 44 24 04          	mov    %eax,0x4(%esp)
  802684:	c7 04 24 48 2f 80 00 	movl   $0x802f48,(%esp)
  80268b:	e8 c8 db ff ff       	call   800258 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802690:	89 74 24 04          	mov    %esi,0x4(%esp)
  802694:	8b 45 10             	mov    0x10(%ebp),%eax
  802697:	89 04 24             	mov    %eax,(%esp)
  80269a:	e8 58 db ff ff       	call   8001f7 <vcprintf>
	cprintf("\n");
  80269f:	c7 04 24 34 2f 80 00 	movl   $0x802f34,(%esp)
  8026a6:	e8 ad db ff ff       	call   800258 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8026ab:	cc                   	int3   
  8026ac:	eb fd                	jmp    8026ab <_panic+0x53>
	...

008026b0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026b0:	55                   	push   %ebp
  8026b1:	89 e5                	mov    %esp,%ebp
  8026b3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026b6:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8026bd:	75 30                	jne    8026ef <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8026bf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8026c6:	00 
  8026c7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8026ce:	ee 
  8026cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026d6:	e8 1a e5 ff ff       	call   800bf5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8026db:	c7 44 24 04 fc 26 80 	movl   $0x8026fc,0x4(%esp)
  8026e2:	00 
  8026e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026ea:	e8 a6 e6 ff ff       	call   800d95 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f2:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8026f7:	c9                   	leave  
  8026f8:	c3                   	ret    
  8026f9:	00 00                	add    %al,(%eax)
	...

008026fc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026fc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026fd:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802702:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802704:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  802707:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  80270b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  80270f:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  802712:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802714:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802718:	83 c4 08             	add    $0x8,%esp
	popal
  80271b:	61                   	popa   

	addl $4,%esp 
  80271c:	83 c4 04             	add    $0x4,%esp
	popfl
  80271f:	9d                   	popf   

	popl %esp
  802720:	5c                   	pop    %esp

	ret
  802721:	c3                   	ret    
	...

00802724 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802724:	55                   	push   %ebp
  802725:	89 e5                	mov    %esp,%ebp
  802727:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80272a:	89 c2                	mov    %eax,%edx
  80272c:	c1 ea 16             	shr    $0x16,%edx
  80272f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802736:	f6 c2 01             	test   $0x1,%dl
  802739:	74 1e                	je     802759 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80273b:	c1 e8 0c             	shr    $0xc,%eax
  80273e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802745:	a8 01                	test   $0x1,%al
  802747:	74 17                	je     802760 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802749:	c1 e8 0c             	shr    $0xc,%eax
  80274c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802753:	ef 
  802754:	0f b7 c0             	movzwl %ax,%eax
  802757:	eb 0c                	jmp    802765 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802759:	b8 00 00 00 00       	mov    $0x0,%eax
  80275e:	eb 05                	jmp    802765 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802760:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802765:	5d                   	pop    %ebp
  802766:	c3                   	ret    
	...

00802768 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802768:	55                   	push   %ebp
  802769:	57                   	push   %edi
  80276a:	56                   	push   %esi
  80276b:	83 ec 10             	sub    $0x10,%esp
  80276e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802772:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802776:	89 74 24 04          	mov    %esi,0x4(%esp)
  80277a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80277e:	89 cd                	mov    %ecx,%ebp
  802780:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802784:	85 c0                	test   %eax,%eax
  802786:	75 2c                	jne    8027b4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802788:	39 f9                	cmp    %edi,%ecx
  80278a:	77 68                	ja     8027f4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80278c:	85 c9                	test   %ecx,%ecx
  80278e:	75 0b                	jne    80279b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802790:	b8 01 00 00 00       	mov    $0x1,%eax
  802795:	31 d2                	xor    %edx,%edx
  802797:	f7 f1                	div    %ecx
  802799:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80279b:	31 d2                	xor    %edx,%edx
  80279d:	89 f8                	mov    %edi,%eax
  80279f:	f7 f1                	div    %ecx
  8027a1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027a3:	89 f0                	mov    %esi,%eax
  8027a5:	f7 f1                	div    %ecx
  8027a7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027a9:	89 f0                	mov    %esi,%eax
  8027ab:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027ad:	83 c4 10             	add    $0x10,%esp
  8027b0:	5e                   	pop    %esi
  8027b1:	5f                   	pop    %edi
  8027b2:	5d                   	pop    %ebp
  8027b3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027b4:	39 f8                	cmp    %edi,%eax
  8027b6:	77 2c                	ja     8027e4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8027b8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8027bb:	83 f6 1f             	xor    $0x1f,%esi
  8027be:	75 4c                	jne    80280c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027c0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027c2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027c7:	72 0a                	jb     8027d3 <__udivdi3+0x6b>
  8027c9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8027cd:	0f 87 ad 00 00 00    	ja     802880 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027d3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027d8:	89 f0                	mov    %esi,%eax
  8027da:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027dc:	83 c4 10             	add    $0x10,%esp
  8027df:	5e                   	pop    %esi
  8027e0:	5f                   	pop    %edi
  8027e1:	5d                   	pop    %ebp
  8027e2:	c3                   	ret    
  8027e3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027e4:	31 ff                	xor    %edi,%edi
  8027e6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027e8:	89 f0                	mov    %esi,%eax
  8027ea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027ec:	83 c4 10             	add    $0x10,%esp
  8027ef:	5e                   	pop    %esi
  8027f0:	5f                   	pop    %edi
  8027f1:	5d                   	pop    %ebp
  8027f2:	c3                   	ret    
  8027f3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027f4:	89 fa                	mov    %edi,%edx
  8027f6:	89 f0                	mov    %esi,%eax
  8027f8:	f7 f1                	div    %ecx
  8027fa:	89 c6                	mov    %eax,%esi
  8027fc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027fe:	89 f0                	mov    %esi,%eax
  802800:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802802:	83 c4 10             	add    $0x10,%esp
  802805:	5e                   	pop    %esi
  802806:	5f                   	pop    %edi
  802807:	5d                   	pop    %ebp
  802808:	c3                   	ret    
  802809:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80280c:	89 f1                	mov    %esi,%ecx
  80280e:	d3 e0                	shl    %cl,%eax
  802810:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802814:	b8 20 00 00 00       	mov    $0x20,%eax
  802819:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80281b:	89 ea                	mov    %ebp,%edx
  80281d:	88 c1                	mov    %al,%cl
  80281f:	d3 ea                	shr    %cl,%edx
  802821:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802825:	09 ca                	or     %ecx,%edx
  802827:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80282b:	89 f1                	mov    %esi,%ecx
  80282d:	d3 e5                	shl    %cl,%ebp
  80282f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802833:	89 fd                	mov    %edi,%ebp
  802835:	88 c1                	mov    %al,%cl
  802837:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802839:	89 fa                	mov    %edi,%edx
  80283b:	89 f1                	mov    %esi,%ecx
  80283d:	d3 e2                	shl    %cl,%edx
  80283f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802843:	88 c1                	mov    %al,%cl
  802845:	d3 ef                	shr    %cl,%edi
  802847:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802849:	89 f8                	mov    %edi,%eax
  80284b:	89 ea                	mov    %ebp,%edx
  80284d:	f7 74 24 08          	divl   0x8(%esp)
  802851:	89 d1                	mov    %edx,%ecx
  802853:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802855:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802859:	39 d1                	cmp    %edx,%ecx
  80285b:	72 17                	jb     802874 <__udivdi3+0x10c>
  80285d:	74 09                	je     802868 <__udivdi3+0x100>
  80285f:	89 fe                	mov    %edi,%esi
  802861:	31 ff                	xor    %edi,%edi
  802863:	e9 41 ff ff ff       	jmp    8027a9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802868:	8b 54 24 04          	mov    0x4(%esp),%edx
  80286c:	89 f1                	mov    %esi,%ecx
  80286e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802870:	39 c2                	cmp    %eax,%edx
  802872:	73 eb                	jae    80285f <__udivdi3+0xf7>
		{
		  q0--;
  802874:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802877:	31 ff                	xor    %edi,%edi
  802879:	e9 2b ff ff ff       	jmp    8027a9 <__udivdi3+0x41>
  80287e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802880:	31 f6                	xor    %esi,%esi
  802882:	e9 22 ff ff ff       	jmp    8027a9 <__udivdi3+0x41>
	...

00802888 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802888:	55                   	push   %ebp
  802889:	57                   	push   %edi
  80288a:	56                   	push   %esi
  80288b:	83 ec 20             	sub    $0x20,%esp
  80288e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802892:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802896:	89 44 24 14          	mov    %eax,0x14(%esp)
  80289a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80289e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028a2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8028a6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8028a8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8028aa:	85 ed                	test   %ebp,%ebp
  8028ac:	75 16                	jne    8028c4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8028ae:	39 f1                	cmp    %esi,%ecx
  8028b0:	0f 86 a6 00 00 00    	jbe    80295c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028b6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8028b8:	89 d0                	mov    %edx,%eax
  8028ba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028bc:	83 c4 20             	add    $0x20,%esp
  8028bf:	5e                   	pop    %esi
  8028c0:	5f                   	pop    %edi
  8028c1:	5d                   	pop    %ebp
  8028c2:	c3                   	ret    
  8028c3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8028c4:	39 f5                	cmp    %esi,%ebp
  8028c6:	0f 87 ac 00 00 00    	ja     802978 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8028cc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8028cf:	83 f0 1f             	xor    $0x1f,%eax
  8028d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028d6:	0f 84 a8 00 00 00    	je     802984 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8028dc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028e0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8028e2:	bf 20 00 00 00       	mov    $0x20,%edi
  8028e7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8028eb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028ef:	89 f9                	mov    %edi,%ecx
  8028f1:	d3 e8                	shr    %cl,%eax
  8028f3:	09 e8                	or     %ebp,%eax
  8028f5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8028f9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028fd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802901:	d3 e0                	shl    %cl,%eax
  802903:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802907:	89 f2                	mov    %esi,%edx
  802909:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80290b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80290f:	d3 e0                	shl    %cl,%eax
  802911:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802915:	8b 44 24 14          	mov    0x14(%esp),%eax
  802919:	89 f9                	mov    %edi,%ecx
  80291b:	d3 e8                	shr    %cl,%eax
  80291d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80291f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802921:	89 f2                	mov    %esi,%edx
  802923:	f7 74 24 18          	divl   0x18(%esp)
  802927:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802929:	f7 64 24 0c          	mull   0xc(%esp)
  80292d:	89 c5                	mov    %eax,%ebp
  80292f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802931:	39 d6                	cmp    %edx,%esi
  802933:	72 67                	jb     80299c <__umoddi3+0x114>
  802935:	74 75                	je     8029ac <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802937:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80293b:	29 e8                	sub    %ebp,%eax
  80293d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80293f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802943:	d3 e8                	shr    %cl,%eax
  802945:	89 f2                	mov    %esi,%edx
  802947:	89 f9                	mov    %edi,%ecx
  802949:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80294b:	09 d0                	or     %edx,%eax
  80294d:	89 f2                	mov    %esi,%edx
  80294f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802953:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802955:	83 c4 20             	add    $0x20,%esp
  802958:	5e                   	pop    %esi
  802959:	5f                   	pop    %edi
  80295a:	5d                   	pop    %ebp
  80295b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80295c:	85 c9                	test   %ecx,%ecx
  80295e:	75 0b                	jne    80296b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802960:	b8 01 00 00 00       	mov    $0x1,%eax
  802965:	31 d2                	xor    %edx,%edx
  802967:	f7 f1                	div    %ecx
  802969:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80296b:	89 f0                	mov    %esi,%eax
  80296d:	31 d2                	xor    %edx,%edx
  80296f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802971:	89 f8                	mov    %edi,%eax
  802973:	e9 3e ff ff ff       	jmp    8028b6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802978:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80297a:	83 c4 20             	add    $0x20,%esp
  80297d:	5e                   	pop    %esi
  80297e:	5f                   	pop    %edi
  80297f:	5d                   	pop    %ebp
  802980:	c3                   	ret    
  802981:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802984:	39 f5                	cmp    %esi,%ebp
  802986:	72 04                	jb     80298c <__umoddi3+0x104>
  802988:	39 f9                	cmp    %edi,%ecx
  80298a:	77 06                	ja     802992 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80298c:	89 f2                	mov    %esi,%edx
  80298e:	29 cf                	sub    %ecx,%edi
  802990:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802992:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802994:	83 c4 20             	add    $0x20,%esp
  802997:	5e                   	pop    %esi
  802998:	5f                   	pop    %edi
  802999:	5d                   	pop    %ebp
  80299a:	c3                   	ret    
  80299b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80299c:	89 d1                	mov    %edx,%ecx
  80299e:	89 c5                	mov    %eax,%ebp
  8029a0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8029a4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8029a8:	eb 8d                	jmp    802937 <__umoddi3+0xaf>
  8029aa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029ac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8029b0:	72 ea                	jb     80299c <__umoddi3+0x114>
  8029b2:	89 f1                	mov    %esi,%ecx
  8029b4:	eb 81                	jmp    802937 <__umoddi3+0xaf>
