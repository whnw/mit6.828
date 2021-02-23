
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 20 0b 00 00       	call   800b63 <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 80 29 80 00 	movl   $0x802980,(%esp)
  800052:	e8 ad 01 00 00       	call   800204 <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	53                   	push   %ebx
  800081:	83 ec 44             	sub    $0x44,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8a 45 0c             	mov    0xc(%ebp),%al
  80008a:	88 45 e7             	mov    %al,-0x19(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 e7 06 00 00       	call   80077c <strlen>
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 40                	jg     8000da <forkchild+0x5d>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80009e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a6:	c7 44 24 08 91 29 80 	movl   $0x802991,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 90 06 00 00       	call   800751 <snprintf>
	if (fork() == 0) {
  8000c1:	e8 7d 0e 00 00       	call   800f43 <fork>
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	75 10                	jne    8000da <forkchild+0x5d>
		forktree(nxt);
  8000ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cd:	89 04 24             	mov    %eax,(%esp)
  8000d0:	e8 5f ff ff ff       	call   800034 <forktree>
		exit();
  8000d5:	e8 6e 00 00 00       	call   800148 <exit>
	}
}
  8000da:	83 c4 44             	add    $0x44,%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e6:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <forktree>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800102:	e8 5c 0a 00 00       	call   800b63 <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800113:	c1 e0 07             	shl    $0x7,%eax
  800116:	29 d0                	sub    %edx,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800122:	85 f6                	test   %esi,%esi
  800124:	7e 07                	jle    80012d <libmain+0x39>
		binaryname = argv[0];
  800126:	8b 03                	mov    (%ebx),%eax
  800128:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800131:	89 34 24             	mov    %esi,(%esp)
  800134:	e8 a7 ff ff ff       	call   8000e0 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5d                   	pop    %ebp
  800144:	c3                   	ret    
  800145:	00 00                	add    %al,(%eax)
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80014e:	e8 bc 12 00 00       	call   80140f <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 b2 09 00 00       	call   800b11 <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
  800161:	00 00                	add    %al,(%eax)
	...

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 14             	sub    $0x14,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 03                	mov    (%ebx),%eax
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800177:	40                   	inc    %eax
  800178:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017f:	75 19                	jne    80019a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800181:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800188:	00 
  800189:	8d 43 08             	lea    0x8(%ebx),%eax
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 40 09 00 00       	call   800ad4 <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019a:	ff 43 04             	incl   0x4(%ebx)
}
  80019d:	83 c4 14             	add    $0x14,%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	c7 04 24 64 01 80 00 	movl   $0x800164,(%esp)
  8001df:	e8 82 01 00 00       	call   800366 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 d8 08 00 00       	call   800ad4 <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	89 04 24             	mov    %eax,(%esp)
  800217:	e8 87 ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	85 c0                	test   %eax,%eax
  800242:	75 08                	jne    80024c <printnum+0x2c>
  800244:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800247:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024a:	77 57                	ja     8002a3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800250:	4b                   	dec    %ebx
  800251:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800255:	8b 45 10             	mov    0x10(%ebp),%eax
  800258:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800260:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800264:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026b:	00 
  80026c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	e8 96 24 00 00       	call   802714 <__udivdi3>
  80027e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800282:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800286:	89 04 24             	mov    %eax,(%esp)
  800289:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028d:	89 fa                	mov    %edi,%edx
  80028f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800292:	e8 89 ff ff ff       	call   800220 <printnum>
  800297:	eb 0f                	jmp    8002a8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029d:	89 34 24             	mov    %esi,(%esp)
  8002a0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a3:	4b                   	dec    %ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f f1                	jg     800299 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002be:	00 
  8002bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	e8 63 25 00 00       	call   802834 <__umoddi3>
  8002d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d5:	0f be 80 a0 29 80 00 	movsbl 0x8029a0(%eax),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e2:	83 c4 3c             	add    $0x3c,%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ed:	83 fa 01             	cmp    $0x1,%edx
  8002f0:	7e 0e                	jle    800300 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	8b 52 04             	mov    0x4(%edx),%edx
  8002fe:	eb 22                	jmp    800322 <getuint+0x38>
	else if (lflag)
  800300:	85 d2                	test   %edx,%edx
  800302:	74 10                	je     800314 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	eb 0e                	jmp    800322 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 04             	lea    0x4(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 08                	jae    80033c <sprintputch+0x18>
		*b->buf++ = ch;
  800334:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800337:	88 0a                	mov    %cl,(%edx)
  800339:	42                   	inc    %edx
  80033a:	89 10                	mov    %edx,(%eax)
}
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034b:	8b 45 10             	mov    0x10(%ebp),%eax
  80034e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
  800355:	89 44 24 04          	mov    %eax,0x4(%esp)
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	89 04 24             	mov    %eax,(%esp)
  80035f:	e8 02 00 00 00       	call   800366 <vprintfmt>
	va_end(ap);
}
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
  80036c:	83 ec 4c             	sub    $0x4c,%esp
  80036f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800372:	8b 75 10             	mov    0x10(%ebp),%esi
  800375:	eb 12                	jmp    800389 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800377:	85 c0                	test   %eax,%eax
  800379:	0f 84 6b 03 00 00    	je     8006ea <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80037f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800383:	89 04 24             	mov    %eax,(%esp)
  800386:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800389:	0f b6 06             	movzbl (%esi),%eax
  80038c:	46                   	inc    %esi
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e5                	jne    800377 <vprintfmt+0x11>
  800392:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800396:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80039d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ae:	eb 26                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003b7:	eb 1d                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c0:	eb 14                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cc:	eb 08                	jmp    8003d6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	0f b6 06             	movzbl (%esi),%eax
  8003d9:	8d 56 01             	lea    0x1(%esi),%edx
  8003dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003df:	8a 16                	mov    (%esi),%dl
  8003e1:	83 ea 23             	sub    $0x23,%edx
  8003e4:	80 fa 55             	cmp    $0x55,%dl
  8003e7:	0f 87 e1 02 00 00    	ja     8006ce <vprintfmt+0x368>
  8003ed:	0f b6 d2             	movzbl %dl,%edx
  8003f0:	ff 24 95 e0 2a 80 00 	jmp    *0x802ae0(,%edx,4)
  8003f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fa:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800402:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800406:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800409:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040c:	83 fa 09             	cmp    $0x9,%edx
  80040f:	77 2a                	ja     80043b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800411:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800412:	eb eb                	jmp    8003ff <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800422:	eb 17                	jmp    80043b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800424:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800428:	78 98                	js     8003c2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042d:	eb a7                	jmp    8003d6 <vprintfmt+0x70>
  80042f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800432:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800439:	eb 9b                	jmp    8003d6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80043b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043f:	79 95                	jns    8003d6 <vprintfmt+0x70>
  800441:	eb 8b                	jmp    8003ce <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800443:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800447:	eb 8d                	jmp    8003d6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800461:	e9 23 ff ff ff       	jmp    800389 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	85 c0                	test   %eax,%eax
  800473:	79 02                	jns    800477 <vprintfmt+0x111>
  800475:	f7 d8                	neg    %eax
  800477:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800479:	83 f8 10             	cmp    $0x10,%eax
  80047c:	7f 0b                	jg     800489 <vprintfmt+0x123>
  80047e:	8b 04 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%eax
  800485:	85 c0                	test   %eax,%eax
  800487:	75 23                	jne    8004ac <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800489:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048d:	c7 44 24 08 b8 29 80 	movl   $0x8029b8,0x8(%esp)
  800494:	00 
  800495:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 9a fe ff ff       	call   80033e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a7:	e9 dd fe ff ff       	jmp    800389 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b0:	c7 44 24 08 29 2e 80 	movl   $0x802e29,0x8(%esp)
  8004b7:	00 
  8004b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	89 14 24             	mov    %edx,(%esp)
  8004c2:	e8 77 fe ff ff       	call   80033e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ca:	e9 ba fe ff ff       	jmp    800389 <vprintfmt+0x23>
  8004cf:	89 f9                	mov    %edi,%ecx
  8004d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 50 04             	lea    0x4(%eax),%edx
  8004dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e0:	8b 30                	mov    (%eax),%esi
  8004e2:	85 f6                	test   %esi,%esi
  8004e4:	75 05                	jne    8004eb <vprintfmt+0x185>
				p = "(null)";
  8004e6:	be b1 29 80 00       	mov    $0x8029b1,%esi
			if (width > 0 && padc != '-')
  8004eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ef:	0f 8e 84 00 00 00    	jle    800579 <vprintfmt+0x213>
  8004f5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f9:	74 7e                	je     800579 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ff:	89 34 24             	mov    %esi,(%esp)
  800502:	e8 8b 02 00 00       	call   800792 <strnlen>
  800507:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050a:	29 c2                	sub    %eax,%edx
  80050c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80050f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800513:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800516:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800519:	89 de                	mov    %ebx,%esi
  80051b:	89 d3                	mov    %edx,%ebx
  80051d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	eb 0b                	jmp    80052c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800521:	89 74 24 04          	mov    %esi,0x4(%esp)
  800525:	89 3c 24             	mov    %edi,(%esp)
  800528:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	4b                   	dec    %ebx
  80052c:	85 db                	test   %ebx,%ebx
  80052e:	7f f1                	jg     800521 <vprintfmt+0x1bb>
  800530:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800533:	89 f3                	mov    %esi,%ebx
  800535:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800538:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053b:	85 c0                	test   %eax,%eax
  80053d:	79 05                	jns    800544 <vprintfmt+0x1de>
  80053f:	b8 00 00 00 00       	mov    $0x0,%eax
  800544:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800547:	29 c2                	sub    %eax,%edx
  800549:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80054c:	eb 2b                	jmp    800579 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800552:	74 18                	je     80056c <vprintfmt+0x206>
  800554:	8d 50 e0             	lea    -0x20(%eax),%edx
  800557:	83 fa 5e             	cmp    $0x5e,%edx
  80055a:	76 10                	jbe    80056c <vprintfmt+0x206>
					putch('?', putdat);
  80055c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800560:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800567:	ff 55 08             	call   *0x8(%ebp)
  80056a:	eb 0a                	jmp    800576 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800576:	ff 4d e4             	decl   -0x1c(%ebp)
  800579:	0f be 06             	movsbl (%esi),%eax
  80057c:	46                   	inc    %esi
  80057d:	85 c0                	test   %eax,%eax
  80057f:	74 21                	je     8005a2 <vprintfmt+0x23c>
  800581:	85 ff                	test   %edi,%edi
  800583:	78 c9                	js     80054e <vprintfmt+0x1e8>
  800585:	4f                   	dec    %edi
  800586:	79 c6                	jns    80054e <vprintfmt+0x1e8>
  800588:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058b:	89 de                	mov    %ebx,%esi
  80058d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800590:	eb 18                	jmp    8005aa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800592:	89 74 24 04          	mov    %esi,0x4(%esp)
  800596:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	4b                   	dec    %ebx
  8005a0:	eb 08                	jmp    8005aa <vprintfmt+0x244>
  8005a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a5:	89 de                	mov    %ebx,%esi
  8005a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005aa:	85 db                	test   %ebx,%ebx
  8005ac:	7f e4                	jg     800592 <vprintfmt+0x22c>
  8005ae:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b6:	e9 ce fd ff ff       	jmp    800389 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 f9 01             	cmp    $0x1,%ecx
  8005be:	7e 10                	jle    8005d0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 08             	lea    0x8(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 30                	mov    (%eax),%esi
  8005cb:	8b 78 04             	mov    0x4(%eax),%edi
  8005ce:	eb 26                	jmp    8005f6 <vprintfmt+0x290>
	else if (lflag)
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	74 12                	je     8005e6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 30                	mov    (%eax),%esi
  8005df:	89 f7                	mov    %esi,%edi
  8005e1:	c1 ff 1f             	sar    $0x1f,%edi
  8005e4:	eb 10                	jmp    8005f6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 30                	mov    (%eax),%esi
  8005f1:	89 f7                	mov    %esi,%edi
  8005f3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f6:	85 ff                	test   %edi,%edi
  8005f8:	78 0a                	js     800604 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ff:	e9 8c 00 00 00       	jmp    800690 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800612:	f7 de                	neg    %esi
  800614:	83 d7 00             	adc    $0x0,%edi
  800617:	f7 df                	neg    %edi
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	eb 70                	jmp    800690 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 c0 fc ff ff       	call   8002ea <getuint>
  80062a:	89 c6                	mov    %eax,%esi
  80062c:	89 d7                	mov    %edx,%edi
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800633:	eb 5b                	jmp    800690 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800635:	89 ca                	mov    %ecx,%edx
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 ab fc ff ff       	call   8002ea <getuint>
  80063f:	89 c6                	mov    %eax,%esi
  800641:	89 d7                	mov    %edx,%edi
			base = 8;
  800643:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800648:	eb 46                	jmp    800690 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80064a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800655:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066f:	8b 30                	mov    (%eax),%esi
  800671:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800676:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067b:	eb 13                	jmp    800690 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067d:	89 ca                	mov    %ecx,%edx
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 63 fc ff ff       	call   8002ea <getuint>
  800687:	89 c6                	mov    %eax,%esi
  800689:	89 d7                	mov    %edx,%edi
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800690:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800694:	89 54 24 10          	mov    %edx,0x10(%esp)
  800698:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80069b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a3:	89 34 24             	mov    %esi,(%esp)
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006aa:	89 da                	mov    %ebx,%edx
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	e8 6c fb ff ff       	call   800220 <printnum>
			break;
  8006b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b7:	e9 cd fc ff ff       	jmp    800389 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c9:	e9 bb fc ff ff       	jmp    800389 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	eb 01                	jmp    8006df <vprintfmt+0x379>
  8006de:	4e                   	dec    %esi
  8006df:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e3:	75 f9                	jne    8006de <vprintfmt+0x378>
  8006e5:	e9 9f fc ff ff       	jmp    800389 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ea:	83 c4 4c             	add    $0x4c,%esp
  8006ed:	5b                   	pop    %ebx
  8006ee:	5e                   	pop    %esi
  8006ef:	5f                   	pop    %edi
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 28             	sub    $0x28,%esp
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800701:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800705:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800708:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070f:	85 c0                	test   %eax,%eax
  800711:	74 30                	je     800743 <vsnprintf+0x51>
  800713:	85 d2                	test   %edx,%edx
  800715:	7e 33                	jle    80074a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071e:	8b 45 10             	mov    0x10(%ebp),%eax
  800721:	89 44 24 08          	mov    %eax,0x8(%esp)
  800725:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072c:	c7 04 24 24 03 80 00 	movl   $0x800324,(%esp)
  800733:	e8 2e fc ff ff       	call   800366 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	eb 0c                	jmp    80074f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800748:	eb 05                	jmp    80074f <vsnprintf+0x5d>
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074f:	c9                   	leave  
  800750:	c3                   	ret    

00800751 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	8b 45 10             	mov    0x10(%ebp),%eax
  800761:	89 44 24 08          	mov    %eax,0x8(%esp)
  800765:	8b 45 0c             	mov    0xc(%ebp),%eax
  800768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	e8 7b ff ff ff       	call   8006f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800777:	c9                   	leave  
  800778:	c3                   	ret    
  800779:	00 00                	add    %al,(%eax)
	...

0080077c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	eb 01                	jmp    80078a <strlen+0xe>
		n++;
  800789:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078e:	75 f9                	jne    800789 <strlen+0xd>
		n++;
	return n;
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a0:	eb 01                	jmp    8007a3 <strnlen+0x11>
		n++;
  8007a2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a3:	39 d0                	cmp    %edx,%eax
  8007a5:	74 06                	je     8007ad <strnlen+0x1b>
  8007a7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ab:	75 f5                	jne    8007a2 <strnlen+0x10>
		n++;
	return n;
}
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007be:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c4:	42                   	inc    %edx
  8007c5:	84 c9                	test   %cl,%cl
  8007c7:	75 f5                	jne    8007be <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d6:	89 1c 24             	mov    %ebx,(%esp)
  8007d9:	e8 9e ff ff ff       	call   80077c <strlen>
	strcpy(dst + len, src);
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e5:	01 d8                	add    %ebx,%eax
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	e8 c0 ff ff ff       	call   8007af <strcpy>
	return dst;
}
  8007ef:	89 d8                	mov    %ebx,%eax
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	5b                   	pop    %ebx
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800802:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800805:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080a:	eb 0c                	jmp    800818 <strncpy+0x21>
		*dst++ = *src;
  80080c:	8a 1a                	mov    (%edx),%bl
  80080e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800811:	80 3a 01             	cmpb   $0x1,(%edx)
  800814:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800817:	41                   	inc    %ecx
  800818:	39 f1                	cmp    %esi,%ecx
  80081a:	75 f0                	jne    80080c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	56                   	push   %esi
  800824:	53                   	push   %ebx
  800825:	8b 75 08             	mov    0x8(%ebp),%esi
  800828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082e:	85 d2                	test   %edx,%edx
  800830:	75 0a                	jne    80083c <strlcpy+0x1c>
  800832:	89 f0                	mov    %esi,%eax
  800834:	eb 1a                	jmp    800850 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	88 18                	mov    %bl,(%eax)
  800838:	40                   	inc    %eax
  800839:	41                   	inc    %ecx
  80083a:	eb 02                	jmp    80083e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80083e:	4a                   	dec    %edx
  80083f:	74 0a                	je     80084b <strlcpy+0x2b>
  800841:	8a 19                	mov    (%ecx),%bl
  800843:	84 db                	test   %bl,%bl
  800845:	75 ef                	jne    800836 <strlcpy+0x16>
  800847:	89 c2                	mov    %eax,%edx
  800849:	eb 02                	jmp    80084d <strlcpy+0x2d>
  80084b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80084d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800850:	29 f0                	sub    %esi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085f:	eb 02                	jmp    800863 <strcmp+0xd>
		p++, q++;
  800861:	41                   	inc    %ecx
  800862:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800863:	8a 01                	mov    (%ecx),%al
  800865:	84 c0                	test   %al,%al
  800867:	74 04                	je     80086d <strcmp+0x17>
  800869:	3a 02                	cmp    (%edx),%al
  80086b:	74 f4                	je     800861 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 c0             	movzbl %al,%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800884:	eb 03                	jmp    800889 <strncmp+0x12>
		n--, p++, q++;
  800886:	4a                   	dec    %edx
  800887:	40                   	inc    %eax
  800888:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 14                	je     8008a1 <strncmp+0x2a>
  80088d:	8a 18                	mov    (%eax),%bl
  80088f:	84 db                	test   %bl,%bl
  800891:	74 04                	je     800897 <strncmp+0x20>
  800893:	3a 19                	cmp    (%ecx),%bl
  800895:	74 ef                	je     800886 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 00             	movzbl (%eax),%eax
  80089a:	0f b6 11             	movzbl (%ecx),%edx
  80089d:	29 d0                	sub    %edx,%eax
  80089f:	eb 05                	jmp    8008a6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b2:	eb 05                	jmp    8008b9 <strchr+0x10>
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 0c                	je     8008c4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b8:	40                   	inc    %eax
  8008b9:	8a 10                	mov    (%eax),%dl
  8008bb:	84 d2                	test   %dl,%dl
  8008bd:	75 f5                	jne    8008b4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cf:	eb 05                	jmp    8008d6 <strfind+0x10>
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 07                	je     8008dc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d5:	40                   	inc    %eax
  8008d6:	8a 10                	mov    (%eax),%dl
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	75 f5                	jne    8008d1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	57                   	push   %edi
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	74 30                	je     800921 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f7:	75 25                	jne    80091e <memset+0x40>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 20                	jne    80091e <memset+0x40>
		c &= 0xFF;
  8008fe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800901:	89 d3                	mov    %edx,%ebx
  800903:	c1 e3 08             	shl    $0x8,%ebx
  800906:	89 d6                	mov    %edx,%esi
  800908:	c1 e6 18             	shl    $0x18,%esi
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	c1 e0 10             	shl    $0x10,%eax
  800910:	09 f0                	or     %esi,%eax
  800912:	09 d0                	or     %edx,%eax
  800914:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800916:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800919:	fc                   	cld    
  80091a:	f3 ab                	rep stos %eax,%es:(%edi)
  80091c:	eb 03                	jmp    800921 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800936:	39 c6                	cmp    %eax,%esi
  800938:	73 34                	jae    80096e <memmove+0x46>
  80093a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093d:	39 d0                	cmp    %edx,%eax
  80093f:	73 2d                	jae    80096e <memmove+0x46>
		s += n;
		d += n;
  800941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	f6 c2 03             	test   $0x3,%dl
  800947:	75 1b                	jne    800964 <memmove+0x3c>
  800949:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094f:	75 13                	jne    800964 <memmove+0x3c>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0e                	jne    800964 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800956:	83 ef 04             	sub    $0x4,%edi
  800959:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095f:	fd                   	std    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 07                	jmp    80096b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800964:	4f                   	dec    %edi
  800965:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800968:	fd                   	std    
  800969:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096b:	fc                   	cld    
  80096c:	eb 20                	jmp    80098e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800974:	75 13                	jne    800989 <memmove+0x61>
  800976:	a8 03                	test   $0x3,%al
  800978:	75 0f                	jne    800989 <memmove+0x61>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0a                	jne    800989 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 05                	jmp    80098e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800998:	8b 45 10             	mov    0x10(%ebp),%eax
  80099b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	e8 77 ff ff ff       	call   800928 <memmove>
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c7:	eb 16                	jmp    8009df <memcmp+0x2c>
		if (*s1 != *s2)
  8009c9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009cc:	42                   	inc    %edx
  8009cd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009d1:	38 c8                	cmp    %cl,%al
  8009d3:	74 0a                	je     8009df <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009d5:	0f b6 c0             	movzbl %al,%eax
  8009d8:	0f b6 c9             	movzbl %cl,%ecx
  8009db:	29 c8                	sub    %ecx,%eax
  8009dd:	eb 09                	jmp    8009e8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009df:	39 da                	cmp    %ebx,%edx
  8009e1:	75 e6                	jne    8009c9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f6:	89 c2                	mov    %eax,%edx
  8009f8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fb:	eb 05                	jmp    800a02 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	38 08                	cmp    %cl,(%eax)
  8009ff:	74 05                	je     800a06 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a01:	40                   	inc    %eax
  800a02:	39 d0                	cmp    %edx,%eax
  800a04:	72 f7                	jb     8009fd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a14:	eb 01                	jmp    800a17 <strtol+0xf>
		s++;
  800a16:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a17:	8a 02                	mov    (%edx),%al
  800a19:	3c 20                	cmp    $0x20,%al
  800a1b:	74 f9                	je     800a16 <strtol+0xe>
  800a1d:	3c 09                	cmp    $0x9,%al
  800a1f:	74 f5                	je     800a16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a21:	3c 2b                	cmp    $0x2b,%al
  800a23:	75 08                	jne    800a2d <strtol+0x25>
		s++;
  800a25:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2b:	eb 13                	jmp    800a40 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2d:	3c 2d                	cmp    $0x2d,%al
  800a2f:	75 0a                	jne    800a3b <strtol+0x33>
		s++, neg = 1;
  800a31:	8d 52 01             	lea    0x1(%edx),%edx
  800a34:	bf 01 00 00 00       	mov    $0x1,%edi
  800a39:	eb 05                	jmp    800a40 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a40:	85 db                	test   %ebx,%ebx
  800a42:	74 05                	je     800a49 <strtol+0x41>
  800a44:	83 fb 10             	cmp    $0x10,%ebx
  800a47:	75 28                	jne    800a71 <strtol+0x69>
  800a49:	8a 02                	mov    (%edx),%al
  800a4b:	3c 30                	cmp    $0x30,%al
  800a4d:	75 10                	jne    800a5f <strtol+0x57>
  800a4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a53:	75 0a                	jne    800a5f <strtol+0x57>
		s += 2, base = 16;
  800a55:	83 c2 02             	add    $0x2,%edx
  800a58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5d:	eb 12                	jmp    800a71 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	75 0e                	jne    800a71 <strtol+0x69>
  800a63:	3c 30                	cmp    $0x30,%al
  800a65:	75 05                	jne    800a6c <strtol+0x64>
		s++, base = 8;
  800a67:	42                   	inc    %edx
  800a68:	b3 08                	mov    $0x8,%bl
  800a6a:	eb 05                	jmp    800a71 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a78:	8a 0a                	mov    (%edx),%cl
  800a7a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a7d:	80 fb 09             	cmp    $0x9,%bl
  800a80:	77 08                	ja     800a8a <strtol+0x82>
			dig = *s - '0';
  800a82:	0f be c9             	movsbl %cl,%ecx
  800a85:	83 e9 30             	sub    $0x30,%ecx
  800a88:	eb 1e                	jmp    800aa8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a8a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a92:	0f be c9             	movsbl %cl,%ecx
  800a95:	83 e9 57             	sub    $0x57,%ecx
  800a98:	eb 0e                	jmp    800aa8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a9d:	80 fb 19             	cmp    $0x19,%bl
  800aa0:	77 12                	ja     800ab4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aa2:	0f be c9             	movsbl %cl,%ecx
  800aa5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa8:	39 f1                	cmp    %esi,%ecx
  800aaa:	7d 0c                	jge    800ab8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aac:	42                   	inc    %edx
  800aad:	0f af c6             	imul   %esi,%eax
  800ab0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ab2:	eb c4                	jmp    800a78 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab4:	89 c1                	mov    %eax,%ecx
  800ab6:	eb 02                	jmp    800aba <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abe:	74 05                	je     800ac5 <strtol+0xbd>
		*endptr = (char *) s;
  800ac0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac5:	85 ff                	test   %edi,%edi
  800ac7:	74 04                	je     800acd <strtol+0xc5>
  800ac9:	89 c8                	mov    %ecx,%eax
  800acb:	f7 d8                	neg    %eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    
	...

00800ad4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	89 c3                	mov    %eax,%ebx
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	89 c6                	mov    %eax,%esi
  800aeb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cgetc>:

int
sys_cgetc(void)
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
  800afd:	b8 01 00 00 00       	mov    $0x1,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 cb                	mov    %ecx,%ebx
  800b29:	89 cf                	mov    %ecx,%edi
  800b2b:	89 ce                	mov    %ecx,%esi
  800b2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	7e 28                	jle    800b5b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b37:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  800b46:	00 
  800b47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4e:	00 
  800b4f:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  800b56:	e8 71 19 00 00       	call   8024cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5b:	83 c4 2c             	add    $0x2c,%esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b73:	89 d1                	mov    %edx,%ecx
  800b75:	89 d3                	mov    %edx,%ebx
  800b77:	89 d7                	mov    %edx,%edi
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_yield>:

void
sys_yield(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800baa:	be 00 00 00 00       	mov    $0x0,%esi
  800baf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	89 f7                	mov    %esi,%edi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 28                	jle    800bed <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  800bd8:	00 
  800bd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be0:	00 
  800be1:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  800be8:	e8 df 18 00 00       	call   8024cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bed:	83 c4 2c             	add    $0x2c,%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800c03:	8b 75 18             	mov    0x18(%ebp),%esi
  800c06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7e 28                	jle    800c40 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c23:	00 
  800c24:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  800c2b:	00 
  800c2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c33:	00 
  800c34:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  800c3b:	e8 8c 18 00 00       	call   8024cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c40:	83 c4 2c             	add    $0x2c,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 28                	jle    800c93 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c76:	00 
  800c77:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c86:	00 
  800c87:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  800c8e:	e8 39 18 00 00       	call   8024cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c93:	83 c4 2c             	add    $0x2c,%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	89 df                	mov    %ebx,%edi
  800cb6:	89 de                	mov    %ebx,%esi
  800cb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 28                	jle    800ce6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc9:	00 
  800cca:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  800cd1:	00 
  800cd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd9:	00 
  800cda:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  800ce1:	e8 e6 17 00 00       	call   8024cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce6:	83 c4 2c             	add    $0x2c,%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	b8 09 00 00 00       	mov    $0x9,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 28                	jle    800d39 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d15:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  800d24:	00 
  800d25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2c:	00 
  800d2d:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  800d34:	e8 93 17 00 00       	call   8024cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d39:	83 c4 2c             	add    $0x2c,%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 df                	mov    %ebx,%edi
  800d5c:	89 de                	mov    %ebx,%esi
  800d5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d60:	85 c0                	test   %eax,%eax
  800d62:	7e 28                	jle    800d8c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d68:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d6f:	00 
  800d70:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  800d77:	00 
  800d78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7f:	00 
  800d80:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  800d87:	e8 40 17 00 00       	call   8024cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8c:	83 c4 2c             	add    $0x2c,%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d9a:	be 00 00 00 00       	mov    $0x0,%esi
  800d9f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 cb                	mov    %ecx,%ebx
  800dcf:	89 cf                	mov    %ecx,%edi
  800dd1:	89 ce                	mov    %ecx,%esi
  800dd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 28                	jle    800e01 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de4:	00 
  800de5:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  800dec:	00 
  800ded:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df4:	00 
  800df5:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  800dfc:	e8 cb 16 00 00       	call   8024cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e01:	83 c4 2c             	add    $0x2c,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e14:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e19:	89 d1                	mov    %edx,%ecx
  800e1b:	89 d3                	mov    %edx,%ebx
  800e1d:	89 d7                	mov    %edx,%edi
  800e1f:	89 d6                	mov    %edx,%esi
  800e21:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e33:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	89 de                	mov    %ebx,%esi
  800e42:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e54:	b8 10 00 00 00       	mov    $0x10,%eax
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	89 df                	mov    %ebx,%edi
  800e61:	89 de                	mov    %ebx,%esi
  800e63:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    
	...

00800e6c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 24             	sub    $0x24,%esp
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e76:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e78:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e7c:	74 2d                	je     800eab <pgfault+0x3f>
  800e7e:	89 d8                	mov    %ebx,%eax
  800e80:	c1 e8 16             	shr    $0x16,%eax
  800e83:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e8a:	a8 01                	test   $0x1,%al
  800e8c:	74 1d                	je     800eab <pgfault+0x3f>
  800e8e:	89 d8                	mov    %ebx,%eax
  800e90:	c1 e8 0c             	shr    $0xc,%eax
  800e93:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e9a:	f6 c2 01             	test   $0x1,%dl
  800e9d:	74 0c                	je     800eab <pgfault+0x3f>
  800e9f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea6:	f6 c4 08             	test   $0x8,%ah
  800ea9:	75 1c                	jne    800ec7 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  800eab:	c7 44 24 08 d0 2c 80 	movl   $0x802cd0,0x8(%esp)
  800eb2:	00 
  800eb3:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800eba:	00 
  800ebb:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  800ec2:	e8 05 16 00 00       	call   8024cc <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  800ec7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800ecd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800edc:	00 
  800edd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ee4:	e8 b8 fc ff ff       	call   800ba1 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  800ee9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ef0:	00 
  800ef1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ef5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800efc:	e8 91 fa ff ff       	call   800992 <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  800f01:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f08:	00 
  800f09:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f0d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f14:	00 
  800f15:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f1c:	00 
  800f1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f24:	e8 cc fc ff ff       	call   800bf5 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  800f29:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f38:	e8 0b fd ff ff       	call   800c48 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  800f3d:	83 c4 24             	add    $0x24,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f4c:	c7 04 24 6c 0e 80 00 	movl   $0x800e6c,(%esp)
  800f53:	e8 cc 15 00 00       	call   802524 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f58:	ba 07 00 00 00       	mov    $0x7,%edx
  800f5d:	89 d0                	mov    %edx,%eax
  800f5f:	cd 30                	int    $0x30
  800f61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f64:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	79 20                	jns    800f8a <fork+0x47>
		panic("sys_exofork: %e", envid);
  800f6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6e:	c7 44 24 08 1e 2d 80 	movl   $0x802d1e,0x8(%esp)
  800f75:	00 
  800f76:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f7d:	00 
  800f7e:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  800f85:	e8 42 15 00 00       	call   8024cc <_panic>
	if (envid == 0)
  800f8a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f8e:	75 25                	jne    800fb5 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f90:	e8 ce fb ff ff       	call   800b63 <sys_getenvid>
  800f95:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fa1:	c1 e0 07             	shl    $0x7,%eax
  800fa4:	29 d0                	sub    %edx,%eax
  800fa6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fab:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fb0:	e9 43 02 00 00       	jmp    8011f8 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  800fb5:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  800fba:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fc0:	0f 84 85 01 00 00    	je     80114b <fork+0x208>
  800fc6:	89 d8                	mov    %ebx,%eax
  800fc8:	c1 e8 16             	shr    $0x16,%eax
  800fcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd2:	a8 01                	test   $0x1,%al
  800fd4:	0f 84 5f 01 00 00    	je     801139 <fork+0x1f6>
  800fda:	89 d8                	mov    %ebx,%eax
  800fdc:	c1 e8 0c             	shr    $0xc,%eax
  800fdf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe6:	f6 c2 01             	test   $0x1,%dl
  800fe9:	0f 84 4a 01 00 00    	je     801139 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  800fef:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  800ff1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff8:	f6 c6 04             	test   $0x4,%dh
  800ffb:	74 50                	je     80104d <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  800ffd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801004:	25 07 0e 00 00       	and    $0xe07,%eax
  801009:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801011:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801015:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801019:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801020:	e8 d0 fb ff ff       	call   800bf5 <sys_page_map>
  801025:	85 c0                	test   %eax,%eax
  801027:	0f 89 0c 01 00 00    	jns    801139 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  80102d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801031:	c7 44 24 08 2e 2d 80 	movl   $0x802d2e,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801040:	00 
  801041:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  801048:	e8 7f 14 00 00       	call   8024cc <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  80104d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801054:	f6 c2 02             	test   $0x2,%dl
  801057:	75 10                	jne    801069 <fork+0x126>
  801059:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801060:	f6 c4 08             	test   $0x8,%ah
  801063:	0f 84 8c 00 00 00    	je     8010f5 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  801069:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801070:	00 
  801071:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801075:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801079:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801084:	e8 6c fb ff ff       	call   800bf5 <sys_page_map>
  801089:	85 c0                	test   %eax,%eax
  80108b:	79 20                	jns    8010ad <fork+0x16a>
		{
			panic("duppage error: %e",e);
  80108d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801091:	c7 44 24 08 2e 2d 80 	movl   $0x802d2e,0x8(%esp)
  801098:	00 
  801099:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  8010a8:	e8 1f 14 00 00       	call   8024cc <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  8010ad:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010b4:	00 
  8010b5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010c0:	00 
  8010c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cc:	e8 24 fb ff ff       	call   800bf5 <sys_page_map>
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	79 64                	jns    801139 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8010d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d9:	c7 44 24 08 2e 2d 80 	movl   $0x802d2e,0x8(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  8010e8:	00 
  8010e9:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  8010f0:	e8 d7 13 00 00       	call   8024cc <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  8010f5:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8010fc:	00 
  8010fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801101:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801105:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801109:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801110:	e8 e0 fa ff ff       	call   800bf5 <sys_page_map>
  801115:	85 c0                	test   %eax,%eax
  801117:	79 20                	jns    801139 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111d:	c7 44 24 08 2e 2d 80 	movl   $0x802d2e,0x8(%esp)
  801124:	00 
  801125:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80112c:	00 
  80112d:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  801134:	e8 93 13 00 00       	call   8024cc <_panic>
  801139:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  80113f:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801145:	0f 85 6f fe ff ff    	jne    800fba <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  80114b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801152:	00 
  801153:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80115a:	ee 
  80115b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80115e:	89 04 24             	mov    %eax,(%esp)
  801161:	e8 3b fa ff ff       	call   800ba1 <sys_page_alloc>
  801166:	85 c0                	test   %eax,%eax
  801168:	79 20                	jns    80118a <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  80116a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116e:	c7 44 24 08 40 2d 80 	movl   $0x802d40,0x8(%esp)
  801175:	00 
  801176:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  80117d:	00 
  80117e:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  801185:	e8 42 13 00 00       	call   8024cc <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80118a:	c7 44 24 04 70 25 80 	movl   $0x802570,0x4(%esp)
  801191:	00 
  801192:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	e8 a4 fb ff ff       	call   800d41 <sys_env_set_pgfault_upcall>
  80119d:	85 c0                	test   %eax,%eax
  80119f:	79 20                	jns    8011c1 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  8011a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a5:	c7 44 24 08 f4 2c 80 	movl   $0x802cf4,0x8(%esp)
  8011ac:	00 
  8011ad:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  8011b4:	00 
  8011b5:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  8011bc:	e8 0b 13 00 00       	call   8024cc <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011c1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011c8:	00 
  8011c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011cc:	89 04 24             	mov    %eax,(%esp)
  8011cf:	e8 c7 fa ff ff       	call   800c9b <sys_env_set_status>
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	79 20                	jns    8011f8 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  8011d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011dc:	c7 44 24 08 53 2d 80 	movl   $0x802d53,0x8(%esp)
  8011e3:	00 
  8011e4:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8011eb:	00 
  8011ec:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  8011f3:	e8 d4 12 00 00       	call   8024cc <_panic>

	return envid;
	// panic("fork not implemented");
}
  8011f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011fb:	83 c4 3c             	add    $0x3c,%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <sfork>:

// Challenge!
int
sfork(void)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801209:	c7 44 24 08 6a 2d 80 	movl   $0x802d6a,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 13 2d 80 00 	movl   $0x802d13,(%esp)
  801220:	e8 a7 12 00 00       	call   8024cc <_panic>
  801225:	00 00                	add    %al,(%eax)
	...

00801228 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	05 00 00 00 30       	add    $0x30000000,%eax
  801233:	c1 e8 0c             	shr    $0xc,%eax
}
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80123e:	8b 45 08             	mov    0x8(%ebp),%eax
  801241:	89 04 24             	mov    %eax,(%esp)
  801244:	e8 df ff ff ff       	call   801228 <fd2num>
  801249:	c1 e0 0c             	shl    $0xc,%eax
  80124c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	53                   	push   %ebx
  801257:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80125a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80125f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801261:	89 c2                	mov    %eax,%edx
  801263:	c1 ea 16             	shr    $0x16,%edx
  801266:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126d:	f6 c2 01             	test   $0x1,%dl
  801270:	74 11                	je     801283 <fd_alloc+0x30>
  801272:	89 c2                	mov    %eax,%edx
  801274:	c1 ea 0c             	shr    $0xc,%edx
  801277:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127e:	f6 c2 01             	test   $0x1,%dl
  801281:	75 09                	jne    80128c <fd_alloc+0x39>
			*fd_store = fd;
  801283:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801285:	b8 00 00 00 00       	mov    $0x0,%eax
  80128a:	eb 17                	jmp    8012a3 <fd_alloc+0x50>
  80128c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801291:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801296:	75 c7                	jne    80125f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801298:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80129e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012a3:	5b                   	pop    %ebx
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ac:	83 f8 1f             	cmp    $0x1f,%eax
  8012af:	77 36                	ja     8012e7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012b1:	c1 e0 0c             	shl    $0xc,%eax
  8012b4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012b9:	89 c2                	mov    %eax,%edx
  8012bb:	c1 ea 16             	shr    $0x16,%edx
  8012be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c5:	f6 c2 01             	test   $0x1,%dl
  8012c8:	74 24                	je     8012ee <fd_lookup+0x48>
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	c1 ea 0c             	shr    $0xc,%edx
  8012cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d6:	f6 c2 01             	test   $0x1,%dl
  8012d9:	74 1a                	je     8012f5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012de:	89 02                	mov    %eax,(%edx)
	return 0;
  8012e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e5:	eb 13                	jmp    8012fa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ec:	eb 0c                	jmp    8012fa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f3:	eb 05                	jmp    8012fa <fd_lookup+0x54>
  8012f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	53                   	push   %ebx
  801300:	83 ec 14             	sub    $0x14,%esp
  801303:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801309:	ba 00 00 00 00       	mov    $0x0,%edx
  80130e:	eb 0e                	jmp    80131e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801310:	39 08                	cmp    %ecx,(%eax)
  801312:	75 09                	jne    80131d <dev_lookup+0x21>
			*dev = devtab[i];
  801314:	89 03                	mov    %eax,(%ebx)
			return 0;
  801316:	b8 00 00 00 00       	mov    $0x0,%eax
  80131b:	eb 33                	jmp    801350 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80131d:	42                   	inc    %edx
  80131e:	8b 04 95 fc 2d 80 00 	mov    0x802dfc(,%edx,4),%eax
  801325:	85 c0                	test   %eax,%eax
  801327:	75 e7                	jne    801310 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801329:	a1 08 40 80 00       	mov    0x804008,%eax
  80132e:	8b 40 48             	mov    0x48(%eax),%eax
  801331:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801335:	89 44 24 04          	mov    %eax,0x4(%esp)
  801339:	c7 04 24 80 2d 80 00 	movl   $0x802d80,(%esp)
  801340:	e8 bf ee ff ff       	call   800204 <cprintf>
	*dev = 0;
  801345:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80134b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801350:	83 c4 14             	add    $0x14,%esp
  801353:	5b                   	pop    %ebx
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	56                   	push   %esi
  80135a:	53                   	push   %ebx
  80135b:	83 ec 30             	sub    $0x30,%esp
  80135e:	8b 75 08             	mov    0x8(%ebp),%esi
  801361:	8a 45 0c             	mov    0xc(%ebp),%al
  801364:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801367:	89 34 24             	mov    %esi,(%esp)
  80136a:	e8 b9 fe ff ff       	call   801228 <fd2num>
  80136f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801372:	89 54 24 04          	mov    %edx,0x4(%esp)
  801376:	89 04 24             	mov    %eax,(%esp)
  801379:	e8 28 ff ff ff       	call   8012a6 <fd_lookup>
  80137e:	89 c3                	mov    %eax,%ebx
  801380:	85 c0                	test   %eax,%eax
  801382:	78 05                	js     801389 <fd_close+0x33>
	    || fd != fd2)
  801384:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801387:	74 0d                	je     801396 <fd_close+0x40>
		return (must_exist ? r : 0);
  801389:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80138d:	75 46                	jne    8013d5 <fd_close+0x7f>
  80138f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801394:	eb 3f                	jmp    8013d5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801396:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139d:	8b 06                	mov    (%esi),%eax
  80139f:	89 04 24             	mov    %eax,(%esp)
  8013a2:	e8 55 ff ff ff       	call   8012fc <dev_lookup>
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 18                	js     8013c5 <fd_close+0x6f>
		if (dev->dev_close)
  8013ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b0:	8b 40 10             	mov    0x10(%eax),%eax
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	74 09                	je     8013c0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013b7:	89 34 24             	mov    %esi,(%esp)
  8013ba:	ff d0                	call   *%eax
  8013bc:	89 c3                	mov    %eax,%ebx
  8013be:	eb 05                	jmp    8013c5 <fd_close+0x6f>
		else
			r = 0;
  8013c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d0:	e8 73 f8 ff ff       	call   800c48 <sys_page_unmap>
	return r;
}
  8013d5:	89 d8                	mov    %ebx,%eax
  8013d7:	83 c4 30             	add    $0x30,%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ee:	89 04 24             	mov    %eax,(%esp)
  8013f1:	e8 b0 fe ff ff       	call   8012a6 <fd_lookup>
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 13                	js     80140d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801401:	00 
  801402:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801405:	89 04 24             	mov    %eax,(%esp)
  801408:	e8 49 ff ff ff       	call   801356 <fd_close>
}
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <close_all>:

void
close_all(void)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	53                   	push   %ebx
  801413:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801416:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80141b:	89 1c 24             	mov    %ebx,(%esp)
  80141e:	e8 bb ff ff ff       	call   8013de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801423:	43                   	inc    %ebx
  801424:	83 fb 20             	cmp    $0x20,%ebx
  801427:	75 f2                	jne    80141b <close_all+0xc>
		close(i);
}
  801429:	83 c4 14             	add    $0x14,%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	57                   	push   %edi
  801433:	56                   	push   %esi
  801434:	53                   	push   %ebx
  801435:	83 ec 4c             	sub    $0x4c,%esp
  801438:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80143b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80143e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	89 04 24             	mov    %eax,(%esp)
  801448:	e8 59 fe ff ff       	call   8012a6 <fd_lookup>
  80144d:	89 c3                	mov    %eax,%ebx
  80144f:	85 c0                	test   %eax,%eax
  801451:	0f 88 e3 00 00 00    	js     80153a <dup+0x10b>
		return r;
	close(newfdnum);
  801457:	89 3c 24             	mov    %edi,(%esp)
  80145a:	e8 7f ff ff ff       	call   8013de <close>

	newfd = INDEX2FD(newfdnum);
  80145f:	89 fe                	mov    %edi,%esi
  801461:	c1 e6 0c             	shl    $0xc,%esi
  801464:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80146a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80146d:	89 04 24             	mov    %eax,(%esp)
  801470:	e8 c3 fd ff ff       	call   801238 <fd2data>
  801475:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801477:	89 34 24             	mov    %esi,(%esp)
  80147a:	e8 b9 fd ff ff       	call   801238 <fd2data>
  80147f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801482:	89 d8                	mov    %ebx,%eax
  801484:	c1 e8 16             	shr    $0x16,%eax
  801487:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80148e:	a8 01                	test   $0x1,%al
  801490:	74 46                	je     8014d8 <dup+0xa9>
  801492:	89 d8                	mov    %ebx,%eax
  801494:	c1 e8 0c             	shr    $0xc,%eax
  801497:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80149e:	f6 c2 01             	test   $0x1,%dl
  8014a1:	74 35                	je     8014d8 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8014af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014c1:	00 
  8014c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014cd:	e8 23 f7 ff ff       	call   800bf5 <sys_page_map>
  8014d2:	89 c3                	mov    %eax,%ebx
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 3b                	js     801513 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014db:	89 c2                	mov    %eax,%edx
  8014dd:	c1 ea 0c             	shr    $0xc,%edx
  8014e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014f1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014fc:	00 
  8014fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801501:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801508:	e8 e8 f6 ff ff       	call   800bf5 <sys_page_map>
  80150d:	89 c3                	mov    %eax,%ebx
  80150f:	85 c0                	test   %eax,%eax
  801511:	79 25                	jns    801538 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801513:	89 74 24 04          	mov    %esi,0x4(%esp)
  801517:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151e:	e8 25 f7 ff ff       	call   800c48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801523:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801531:	e8 12 f7 ff ff       	call   800c48 <sys_page_unmap>
	return r;
  801536:	eb 02                	jmp    80153a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801538:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80153a:	89 d8                	mov    %ebx,%eax
  80153c:	83 c4 4c             	add    $0x4c,%esp
  80153f:	5b                   	pop    %ebx
  801540:	5e                   	pop    %esi
  801541:	5f                   	pop    %edi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    

00801544 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	53                   	push   %ebx
  801548:	83 ec 24             	sub    $0x24,%esp
  80154b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801551:	89 44 24 04          	mov    %eax,0x4(%esp)
  801555:	89 1c 24             	mov    %ebx,(%esp)
  801558:	e8 49 fd ff ff       	call   8012a6 <fd_lookup>
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 6d                	js     8015ce <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801561:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	8b 00                	mov    (%eax),%eax
  80156d:	89 04 24             	mov    %eax,(%esp)
  801570:	e8 87 fd ff ff       	call   8012fc <dev_lookup>
  801575:	85 c0                	test   %eax,%eax
  801577:	78 55                	js     8015ce <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801579:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157c:	8b 50 08             	mov    0x8(%eax),%edx
  80157f:	83 e2 03             	and    $0x3,%edx
  801582:	83 fa 01             	cmp    $0x1,%edx
  801585:	75 23                	jne    8015aa <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801587:	a1 08 40 80 00       	mov    0x804008,%eax
  80158c:	8b 40 48             	mov    0x48(%eax),%eax
  80158f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801593:	89 44 24 04          	mov    %eax,0x4(%esp)
  801597:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  80159e:	e8 61 ec ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  8015a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a8:	eb 24                	jmp    8015ce <read+0x8a>
	}
	if (!dev->dev_read)
  8015aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ad:	8b 52 08             	mov    0x8(%edx),%edx
  8015b0:	85 d2                	test   %edx,%edx
  8015b2:	74 15                	je     8015c9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015c2:	89 04 24             	mov    %eax,(%esp)
  8015c5:	ff d2                	call   *%edx
  8015c7:	eb 05                	jmp    8015ce <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015ce:	83 c4 24             	add    $0x24,%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    

008015d4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	57                   	push   %edi
  8015d8:	56                   	push   %esi
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 1c             	sub    $0x1c,%esp
  8015dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e8:	eb 23                	jmp    80160d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ea:	89 f0                	mov    %esi,%eax
  8015ec:	29 d8                	sub    %ebx,%eax
  8015ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f5:	01 d8                	add    %ebx,%eax
  8015f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fb:	89 3c 24             	mov    %edi,(%esp)
  8015fe:	e8 41 ff ff ff       	call   801544 <read>
		if (m < 0)
  801603:	85 c0                	test   %eax,%eax
  801605:	78 10                	js     801617 <readn+0x43>
			return m;
		if (m == 0)
  801607:	85 c0                	test   %eax,%eax
  801609:	74 0a                	je     801615 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160b:	01 c3                	add    %eax,%ebx
  80160d:	39 f3                	cmp    %esi,%ebx
  80160f:	72 d9                	jb     8015ea <readn+0x16>
  801611:	89 d8                	mov    %ebx,%eax
  801613:	eb 02                	jmp    801617 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801615:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801617:	83 c4 1c             	add    $0x1c,%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5f                   	pop    %edi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	53                   	push   %ebx
  801623:	83 ec 24             	sub    $0x24,%esp
  801626:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801629:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801630:	89 1c 24             	mov    %ebx,(%esp)
  801633:	e8 6e fc ff ff       	call   8012a6 <fd_lookup>
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 68                	js     8016a4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	8b 00                	mov    (%eax),%eax
  801648:	89 04 24             	mov    %eax,(%esp)
  80164b:	e8 ac fc ff ff       	call   8012fc <dev_lookup>
  801650:	85 c0                	test   %eax,%eax
  801652:	78 50                	js     8016a4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801657:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165b:	75 23                	jne    801680 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80165d:	a1 08 40 80 00       	mov    0x804008,%eax
  801662:	8b 40 48             	mov    0x48(%eax),%eax
  801665:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166d:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  801674:	e8 8b eb ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  801679:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167e:	eb 24                	jmp    8016a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801680:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801683:	8b 52 0c             	mov    0xc(%edx),%edx
  801686:	85 d2                	test   %edx,%edx
  801688:	74 15                	je     80169f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80168a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80168d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801691:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801694:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801698:	89 04 24             	mov    %eax,(%esp)
  80169b:	ff d2                	call   *%edx
  80169d:	eb 05                	jmp    8016a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80169f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016a4:	83 c4 24             	add    $0x24,%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ba:	89 04 24             	mov    %eax,(%esp)
  8016bd:	e8 e4 fb ff ff       	call   8012a6 <fd_lookup>
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 0e                	js     8016d4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 24             	sub    $0x24,%esp
  8016dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e7:	89 1c 24             	mov    %ebx,(%esp)
  8016ea:	e8 b7 fb ff ff       	call   8012a6 <fd_lookup>
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 61                	js     801754 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fd:	8b 00                	mov    (%eax),%eax
  8016ff:	89 04 24             	mov    %eax,(%esp)
  801702:	e8 f5 fb ff ff       	call   8012fc <dev_lookup>
  801707:	85 c0                	test   %eax,%eax
  801709:	78 49                	js     801754 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801712:	75 23                	jne    801737 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801714:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801719:	8b 40 48             	mov    0x48(%eax),%eax
  80171c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801720:	89 44 24 04          	mov    %eax,0x4(%esp)
  801724:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  80172b:	e8 d4 ea ff ff       	call   800204 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801730:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801735:	eb 1d                	jmp    801754 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801737:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173a:	8b 52 18             	mov    0x18(%edx),%edx
  80173d:	85 d2                	test   %edx,%edx
  80173f:	74 0e                	je     80174f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801744:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801748:	89 04 24             	mov    %eax,(%esp)
  80174b:	ff d2                	call   *%edx
  80174d:	eb 05                	jmp    801754 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80174f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801754:	83 c4 24             	add    $0x24,%esp
  801757:	5b                   	pop    %ebx
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 24             	sub    $0x24,%esp
  801761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801764:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 30 fb ff ff       	call   8012a6 <fd_lookup>
  801776:	85 c0                	test   %eax,%eax
  801778:	78 52                	js     8017cc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	8b 00                	mov    (%eax),%eax
  801786:	89 04 24             	mov    %eax,(%esp)
  801789:	e8 6e fb ff ff       	call   8012fc <dev_lookup>
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 3a                	js     8017cc <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801795:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801799:	74 2c                	je     8017c7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80179b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80179e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017a5:	00 00 00 
	stat->st_isdir = 0;
  8017a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017af:	00 00 00 
	stat->st_dev = dev;
  8017b2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017bf:	89 14 24             	mov    %edx,(%esp)
  8017c2:	ff 50 14             	call   *0x14(%eax)
  8017c5:	eb 05                	jmp    8017cc <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017cc:	83 c4 24             	add    $0x24,%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017e1:	00 
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	89 04 24             	mov    %eax,(%esp)
  8017e8:	e8 2a 02 00 00       	call   801a17 <open>
  8017ed:	89 c3                	mov    %eax,%ebx
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 1b                	js     80180e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fa:	89 1c 24             	mov    %ebx,(%esp)
  8017fd:	e8 58 ff ff ff       	call   80175a <fstat>
  801802:	89 c6                	mov    %eax,%esi
	close(fd);
  801804:	89 1c 24             	mov    %ebx,(%esp)
  801807:	e8 d2 fb ff ff       	call   8013de <close>
	return r;
  80180c:	89 f3                	mov    %esi,%ebx
}
  80180e:	89 d8                	mov    %ebx,%eax
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	5b                   	pop    %ebx
  801814:	5e                   	pop    %esi
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    
	...

00801818 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
  80181d:	83 ec 10             	sub    $0x10,%esp
  801820:	89 c3                	mov    %eax,%ebx
  801822:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801824:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182b:	75 11                	jne    80183e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80182d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801834:	e8 52 0e 00 00       	call   80268b <ipc_find_env>
  801839:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80183e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801845:	00 
  801846:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80184d:	00 
  80184e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801852:	a1 00 40 80 00       	mov    0x804000,%eax
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	e8 a9 0d 00 00       	call   802608 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80185f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801866:	00 
  801867:	89 74 24 04          	mov    %esi,0x4(%esp)
  80186b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801872:	e8 21 0d 00 00       	call   802598 <ipc_recv>
}
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	8b 40 0c             	mov    0xc(%eax),%eax
  80188a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80188f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801892:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801897:	ba 00 00 00 00       	mov    $0x0,%edx
  80189c:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a1:	e8 72 ff ff ff       	call   801818 <fsipc>
}
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018be:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c3:	e8 50 ff ff ff       	call   801818 <fsipc>
}
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 14             	sub    $0x14,%esp
  8018d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018da:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e9:	e8 2a ff ff ff       	call   801818 <fsipc>
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 2b                	js     80191d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018f2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018f9:	00 
  8018fa:	89 1c 24             	mov    %ebx,(%esp)
  8018fd:	e8 ad ee ff ff       	call   8007af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801902:	a1 80 50 80 00       	mov    0x805080,%eax
  801907:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80190d:	a1 84 50 80 00       	mov    0x805084,%eax
  801912:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801918:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191d:	83 c4 14             	add    $0x14,%esp
  801920:	5b                   	pop    %ebx
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    

00801923 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 18             	sub    $0x18,%esp
  801929:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80192c:	8b 55 08             	mov    0x8(%ebp),%edx
  80192f:	8b 52 0c             	mov    0xc(%edx),%edx
  801932:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801938:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  80193d:	89 c2                	mov    %eax,%edx
  80193f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801944:	76 05                	jbe    80194b <devfile_write+0x28>
  801946:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  80194b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80194f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801952:	89 44 24 04          	mov    %eax,0x4(%esp)
  801956:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80195d:	e8 30 f0 ff ff       	call   800992 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801962:	ba 00 00 00 00       	mov    $0x0,%edx
  801967:	b8 04 00 00 00       	mov    $0x4,%eax
  80196c:	e8 a7 fe ff ff       	call   801818 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	83 ec 10             	sub    $0x10,%esp
  80197b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	8b 40 0c             	mov    0xc(%eax),%eax
  801984:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801989:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80198f:	ba 00 00 00 00       	mov    $0x0,%edx
  801994:	b8 03 00 00 00       	mov    $0x3,%eax
  801999:	e8 7a fe ff ff       	call   801818 <fsipc>
  80199e:	89 c3                	mov    %eax,%ebx
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 6a                	js     801a0e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8019a4:	39 c6                	cmp    %eax,%esi
  8019a6:	73 24                	jae    8019cc <devfile_read+0x59>
  8019a8:	c7 44 24 0c 10 2e 80 	movl   $0x802e10,0xc(%esp)
  8019af:	00 
  8019b0:	c7 44 24 08 17 2e 80 	movl   $0x802e17,0x8(%esp)
  8019b7:	00 
  8019b8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019bf:	00 
  8019c0:	c7 04 24 2c 2e 80 00 	movl   $0x802e2c,(%esp)
  8019c7:	e8 00 0b 00 00       	call   8024cc <_panic>
	assert(r <= PGSIZE);
  8019cc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019d1:	7e 24                	jle    8019f7 <devfile_read+0x84>
  8019d3:	c7 44 24 0c 37 2e 80 	movl   $0x802e37,0xc(%esp)
  8019da:	00 
  8019db:	c7 44 24 08 17 2e 80 	movl   $0x802e17,0x8(%esp)
  8019e2:	00 
  8019e3:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8019ea:	00 
  8019eb:	c7 04 24 2c 2e 80 00 	movl   $0x802e2c,(%esp)
  8019f2:	e8 d5 0a 00 00       	call   8024cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019fb:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a02:	00 
  801a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a06:	89 04 24             	mov    %eax,(%esp)
  801a09:	e8 1a ef ff ff       	call   800928 <memmove>
	return r;
}
  801a0e:	89 d8                	mov    %ebx,%eax
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	5b                   	pop    %ebx
  801a14:	5e                   	pop    %esi
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    

00801a17 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	56                   	push   %esi
  801a1b:	53                   	push   %ebx
  801a1c:	83 ec 20             	sub    $0x20,%esp
  801a1f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a22:	89 34 24             	mov    %esi,(%esp)
  801a25:	e8 52 ed ff ff       	call   80077c <strlen>
  801a2a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a2f:	7f 60                	jg     801a91 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a34:	89 04 24             	mov    %eax,(%esp)
  801a37:	e8 17 f8 ff ff       	call   801253 <fd_alloc>
  801a3c:	89 c3                	mov    %eax,%ebx
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 54                	js     801a96 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a42:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a46:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a4d:	e8 5d ed ff ff       	call   8007af <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a55:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a5d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a62:	e8 b1 fd ff ff       	call   801818 <fsipc>
  801a67:	89 c3                	mov    %eax,%ebx
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	79 15                	jns    801a82 <open+0x6b>
		fd_close(fd, 0);
  801a6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a74:	00 
  801a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a78:	89 04 24             	mov    %eax,(%esp)
  801a7b:	e8 d6 f8 ff ff       	call   801356 <fd_close>
		return r;
  801a80:	eb 14                	jmp    801a96 <open+0x7f>
	}

	return fd2num(fd);
  801a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a85:	89 04 24             	mov    %eax,(%esp)
  801a88:	e8 9b f7 ff ff       	call   801228 <fd2num>
  801a8d:	89 c3                	mov    %eax,%ebx
  801a8f:	eb 05                	jmp    801a96 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a91:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a96:	89 d8                	mov    %ebx,%eax
  801a98:	83 c4 20             	add    $0x20,%esp
  801a9b:	5b                   	pop    %ebx
  801a9c:	5e                   	pop    %esi
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    

00801a9f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aaa:	b8 08 00 00 00       	mov    $0x8,%eax
  801aaf:	e8 64 fd ff ff       	call   801818 <fsipc>
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    
	...

00801ab8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801abe:	c7 44 24 04 43 2e 80 	movl   $0x802e43,0x4(%esp)
  801ac5:	00 
  801ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac9:	89 04 24             	mov    %eax,(%esp)
  801acc:	e8 de ec ff ff       	call   8007af <strcpy>
	return 0;
}
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	53                   	push   %ebx
  801adc:	83 ec 14             	sub    $0x14,%esp
  801adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ae2:	89 1c 24             	mov    %ebx,(%esp)
  801ae5:	e8 e6 0b 00 00       	call   8026d0 <pageref>
  801aea:	83 f8 01             	cmp    $0x1,%eax
  801aed:	75 0d                	jne    801afc <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801aef:	8b 43 0c             	mov    0xc(%ebx),%eax
  801af2:	89 04 24             	mov    %eax,(%esp)
  801af5:	e8 1f 03 00 00       	call   801e19 <nsipc_close>
  801afa:	eb 05                	jmp    801b01 <devsock_close+0x29>
	else
		return 0;
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b01:	83 c4 14             	add    $0x14,%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b0d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b14:	00 
  801b15:	8b 45 10             	mov    0x10(%ebp),%eax
  801b18:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	8b 40 0c             	mov    0xc(%eax),%eax
  801b29:	89 04 24             	mov    %eax,(%esp)
  801b2c:	e8 e3 03 00 00       	call   801f14 <nsipc_send>
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b39:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b40:	00 
  801b41:	8b 45 10             	mov    0x10(%ebp),%eax
  801b44:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b52:	8b 40 0c             	mov    0xc(%eax),%eax
  801b55:	89 04 24             	mov    %eax,(%esp)
  801b58:	e8 37 03 00 00       	call   801e94 <nsipc_recv>
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 20             	sub    $0x20,%esp
  801b67:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6c:	89 04 24             	mov    %eax,(%esp)
  801b6f:	e8 df f6 ff ff       	call   801253 <fd_alloc>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 21                	js     801b9b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b7a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b81:	00 
  801b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b90:	e8 0c f0 ff ff       	call   800ba1 <sys_page_alloc>
  801b95:	89 c3                	mov    %eax,%ebx
  801b97:	85 c0                	test   %eax,%eax
  801b99:	79 0a                	jns    801ba5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801b9b:	89 34 24             	mov    %esi,(%esp)
  801b9e:	e8 76 02 00 00       	call   801e19 <nsipc_close>
		return r;
  801ba3:	eb 22                	jmp    801bc7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ba5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bae:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bba:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bbd:	89 04 24             	mov    %eax,(%esp)
  801bc0:	e8 63 f6 ff ff       	call   801228 <fd2num>
  801bc5:	89 c3                	mov    %eax,%ebx
}
  801bc7:	89 d8                	mov    %ebx,%eax
  801bc9:	83 c4 20             	add    $0x20,%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bd6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bd9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bdd:	89 04 24             	mov    %eax,(%esp)
  801be0:	e8 c1 f6 ff ff       	call   8012a6 <fd_lookup>
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 17                	js     801c00 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf2:	39 10                	cmp    %edx,(%eax)
  801bf4:	75 05                	jne    801bfb <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bf6:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf9:	eb 05                	jmp    801c00 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801bfb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c08:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0b:	e8 c0 ff ff ff       	call   801bd0 <fd2sockid>
  801c10:	85 c0                	test   %eax,%eax
  801c12:	78 1f                	js     801c33 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c14:	8b 55 10             	mov    0x10(%ebp),%edx
  801c17:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c22:	89 04 24             	mov    %eax,(%esp)
  801c25:	e8 38 01 00 00       	call   801d62 <nsipc_accept>
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 05                	js     801c33 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801c2e:	e8 2c ff ff ff       	call   801b5f <alloc_sockfd>
}
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3e:	e8 8d ff ff ff       	call   801bd0 <fd2sockid>
  801c43:	85 c0                	test   %eax,%eax
  801c45:	78 16                	js     801c5d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801c47:	8b 55 10             	mov    0x10(%ebp),%edx
  801c4a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 5b 01 00 00       	call   801db8 <nsipc_bind>
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <shutdown>:

int
shutdown(int s, int how)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c65:	8b 45 08             	mov    0x8(%ebp),%eax
  801c68:	e8 63 ff ff ff       	call   801bd0 <fd2sockid>
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 0f                	js     801c80 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c71:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c74:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c78:	89 04 24             	mov    %eax,(%esp)
  801c7b:	e8 77 01 00 00       	call   801df7 <nsipc_shutdown>
}
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    

00801c82 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c88:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8b:	e8 40 ff ff ff       	call   801bd0 <fd2sockid>
  801c90:	85 c0                	test   %eax,%eax
  801c92:	78 16                	js     801caa <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801c94:	8b 55 10             	mov    0x10(%ebp),%edx
  801c97:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ca2:	89 04 24             	mov    %eax,(%esp)
  801ca5:	e8 89 01 00 00       	call   801e33 <nsipc_connect>
}
  801caa:	c9                   	leave  
  801cab:	c3                   	ret    

00801cac <listen>:

int
listen(int s, int backlog)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb5:	e8 16 ff ff ff       	call   801bd0 <fd2sockid>
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	78 0f                	js     801ccd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801cbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cc5:	89 04 24             	mov    %eax,(%esp)
  801cc8:	e8 a5 01 00 00       	call   801e72 <nsipc_listen>
}
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    

00801ccf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cd5:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	89 04 24             	mov    %eax,(%esp)
  801ce9:	e8 99 02 00 00       	call   801f87 <nsipc_socket>
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 05                	js     801cf7 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801cf2:	e8 68 fe ff ff       	call   801b5f <alloc_sockfd>
}
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    
  801cf9:	00 00                	add    %al,(%eax)
	...

00801cfc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	53                   	push   %ebx
  801d00:	83 ec 14             	sub    $0x14,%esp
  801d03:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d05:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d0c:	75 11                	jne    801d1f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d0e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d15:	e8 71 09 00 00       	call   80268b <ipc_find_env>
  801d1a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d1f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d26:	00 
  801d27:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d2e:	00 
  801d2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d33:	a1 04 40 80 00       	mov    0x804004,%eax
  801d38:	89 04 24             	mov    %eax,(%esp)
  801d3b:	e8 c8 08 00 00       	call   802608 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d40:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d47:	00 
  801d48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d4f:	00 
  801d50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d57:	e8 3c 08 00 00       	call   802598 <ipc_recv>
}
  801d5c:	83 c4 14             	add    $0x14,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	56                   	push   %esi
  801d66:	53                   	push   %ebx
  801d67:	83 ec 10             	sub    $0x10,%esp
  801d6a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d70:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d75:	8b 06                	mov    (%esi),%eax
  801d77:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d81:	e8 76 ff ff ff       	call   801cfc <nsipc>
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 23                	js     801daf <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d8c:	a1 10 60 80 00       	mov    0x806010,%eax
  801d91:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d95:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d9c:	00 
  801d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da0:	89 04 24             	mov    %eax,(%esp)
  801da3:	e8 80 eb ff ff       	call   800928 <memmove>
		*addrlen = ret->ret_addrlen;
  801da8:	a1 10 60 80 00       	mov    0x806010,%eax
  801dad:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801daf:	89 d8                	mov    %ebx,%eax
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	53                   	push   %ebx
  801dbc:	83 ec 14             	sub    $0x14,%esp
  801dbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801dca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd5:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ddc:	e8 47 eb ff ff       	call   800928 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801de1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801de7:	b8 02 00 00 00       	mov    $0x2,%eax
  801dec:	e8 0b ff ff ff       	call   801cfc <nsipc>
}
  801df1:	83 c4 14             	add    $0x14,%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5d                   	pop    %ebp
  801df6:	c3                   	ret    

00801df7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801e00:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e08:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e0d:	b8 03 00 00 00       	mov    $0x3,%eax
  801e12:	e8 e5 fe ff ff       	call   801cfc <nsipc>
}
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    

00801e19 <nsipc_close>:

int
nsipc_close(int s)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e27:	b8 04 00 00 00       	mov    $0x4,%eax
  801e2c:	e8 cb fe ff ff       	call   801cfc <nsipc>
}
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	53                   	push   %ebx
  801e37:	83 ec 14             	sub    $0x14,%esp
  801e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e40:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e45:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e50:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e57:	e8 cc ea ff ff       	call   800928 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e5c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e62:	b8 05 00 00 00       	mov    $0x5,%eax
  801e67:	e8 90 fe ff ff       	call   801cfc <nsipc>
}
  801e6c:	83 c4 14             	add    $0x14,%esp
  801e6f:	5b                   	pop    %ebx
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    

00801e72 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e83:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e88:	b8 06 00 00 00       	mov    $0x6,%eax
  801e8d:	e8 6a fe ff ff       	call   801cfc <nsipc>
}
  801e92:	c9                   	leave  
  801e93:	c3                   	ret    

00801e94 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	56                   	push   %esi
  801e98:	53                   	push   %ebx
  801e99:	83 ec 10             	sub    $0x10,%esp
  801e9c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ea7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ead:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801eb5:	b8 07 00 00 00       	mov    $0x7,%eax
  801eba:	e8 3d fe ff ff       	call   801cfc <nsipc>
  801ebf:	89 c3                	mov    %eax,%ebx
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 46                	js     801f0b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801ec5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801eca:	7f 04                	jg     801ed0 <nsipc_recv+0x3c>
  801ecc:	39 c6                	cmp    %eax,%esi
  801ece:	7d 24                	jge    801ef4 <nsipc_recv+0x60>
  801ed0:	c7 44 24 0c 4f 2e 80 	movl   $0x802e4f,0xc(%esp)
  801ed7:	00 
  801ed8:	c7 44 24 08 17 2e 80 	movl   $0x802e17,0x8(%esp)
  801edf:	00 
  801ee0:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801ee7:	00 
  801ee8:	c7 04 24 64 2e 80 00 	movl   $0x802e64,(%esp)
  801eef:	e8 d8 05 00 00       	call   8024cc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ef4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef8:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801eff:	00 
  801f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f03:	89 04 24             	mov    %eax,(%esp)
  801f06:	e8 1d ea ff ff       	call   800928 <memmove>
	}

	return r;
}
  801f0b:	89 d8                	mov    %ebx,%eax
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	5b                   	pop    %ebx
  801f11:	5e                   	pop    %esi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

00801f14 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	53                   	push   %ebx
  801f18:	83 ec 14             	sub    $0x14,%esp
  801f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f21:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f26:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f2c:	7e 24                	jle    801f52 <nsipc_send+0x3e>
  801f2e:	c7 44 24 0c 70 2e 80 	movl   $0x802e70,0xc(%esp)
  801f35:	00 
  801f36:	c7 44 24 08 17 2e 80 	movl   $0x802e17,0x8(%esp)
  801f3d:	00 
  801f3e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801f45:	00 
  801f46:	c7 04 24 64 2e 80 00 	movl   $0x802e64,(%esp)
  801f4d:	e8 7a 05 00 00       	call   8024cc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801f64:	e8 bf e9 ff ff       	call   800928 <memmove>
	nsipcbuf.send.req_size = size;
  801f69:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f6f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f72:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f77:	b8 08 00 00 00       	mov    $0x8,%eax
  801f7c:	e8 7b fd ff ff       	call   801cfc <nsipc>
}
  801f81:	83 c4 14             	add    $0x14,%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5d                   	pop    %ebp
  801f86:	c3                   	ret    

00801f87 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f98:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801fa5:	b8 09 00 00 00       	mov    $0x9,%eax
  801faa:	e8 4d fd ff ff       	call   801cfc <nsipc>
}
  801faf:	c9                   	leave  
  801fb0:	c3                   	ret    
  801fb1:	00 00                	add    %al,(%eax)
	...

00801fb4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	56                   	push   %esi
  801fb8:	53                   	push   %ebx
  801fb9:	83 ec 10             	sub    $0x10,%esp
  801fbc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc2:	89 04 24             	mov    %eax,(%esp)
  801fc5:	e8 6e f2 ff ff       	call   801238 <fd2data>
  801fca:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801fcc:	c7 44 24 04 7c 2e 80 	movl   $0x802e7c,0x4(%esp)
  801fd3:	00 
  801fd4:	89 34 24             	mov    %esi,(%esp)
  801fd7:	e8 d3 e7 ff ff       	call   8007af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fdc:	8b 43 04             	mov    0x4(%ebx),%eax
  801fdf:	2b 03                	sub    (%ebx),%eax
  801fe1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801fe7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801fee:	00 00 00 
	stat->st_dev = &devpipe;
  801ff1:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801ff8:	30 80 00 
	return 0;
}
  801ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5d                   	pop    %ebp
  802006:	c3                   	ret    

00802007 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	53                   	push   %ebx
  80200b:	83 ec 14             	sub    $0x14,%esp
  80200e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802011:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802015:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80201c:	e8 27 ec ff ff       	call   800c48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802021:	89 1c 24             	mov    %ebx,(%esp)
  802024:	e8 0f f2 ff ff       	call   801238 <fd2data>
  802029:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802034:	e8 0f ec ff ff       	call   800c48 <sys_page_unmap>
}
  802039:	83 c4 14             	add    $0x14,%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    

0080203f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	57                   	push   %edi
  802043:	56                   	push   %esi
  802044:	53                   	push   %ebx
  802045:	83 ec 2c             	sub    $0x2c,%esp
  802048:	89 c7                	mov    %eax,%edi
  80204a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80204d:	a1 08 40 80 00       	mov    0x804008,%eax
  802052:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802055:	89 3c 24             	mov    %edi,(%esp)
  802058:	e8 73 06 00 00       	call   8026d0 <pageref>
  80205d:	89 c6                	mov    %eax,%esi
  80205f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802062:	89 04 24             	mov    %eax,(%esp)
  802065:	e8 66 06 00 00       	call   8026d0 <pageref>
  80206a:	39 c6                	cmp    %eax,%esi
  80206c:	0f 94 c0             	sete   %al
  80206f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802072:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802078:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80207b:	39 cb                	cmp    %ecx,%ebx
  80207d:	75 08                	jne    802087 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80207f:	83 c4 2c             	add    $0x2c,%esp
  802082:	5b                   	pop    %ebx
  802083:	5e                   	pop    %esi
  802084:	5f                   	pop    %edi
  802085:	5d                   	pop    %ebp
  802086:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802087:	83 f8 01             	cmp    $0x1,%eax
  80208a:	75 c1                	jne    80204d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80208c:	8b 42 58             	mov    0x58(%edx),%eax
  80208f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802096:	00 
  802097:	89 44 24 08          	mov    %eax,0x8(%esp)
  80209b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80209f:	c7 04 24 83 2e 80 00 	movl   $0x802e83,(%esp)
  8020a6:	e8 59 e1 ff ff       	call   800204 <cprintf>
  8020ab:	eb a0                	jmp    80204d <_pipeisclosed+0xe>

008020ad <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	57                   	push   %edi
  8020b1:	56                   	push   %esi
  8020b2:	53                   	push   %ebx
  8020b3:	83 ec 1c             	sub    $0x1c,%esp
  8020b6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020b9:	89 34 24             	mov    %esi,(%esp)
  8020bc:	e8 77 f1 ff ff       	call   801238 <fd2data>
  8020c1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8020c8:	eb 3c                	jmp    802106 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020ca:	89 da                	mov    %ebx,%edx
  8020cc:	89 f0                	mov    %esi,%eax
  8020ce:	e8 6c ff ff ff       	call   80203f <_pipeisclosed>
  8020d3:	85 c0                	test   %eax,%eax
  8020d5:	75 38                	jne    80210f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020d7:	e8 a6 ea ff ff       	call   800b82 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020dc:	8b 43 04             	mov    0x4(%ebx),%eax
  8020df:	8b 13                	mov    (%ebx),%edx
  8020e1:	83 c2 20             	add    $0x20,%edx
  8020e4:	39 d0                	cmp    %edx,%eax
  8020e6:	73 e2                	jae    8020ca <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020eb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8020ee:	89 c2                	mov    %eax,%edx
  8020f0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8020f6:	79 05                	jns    8020fd <devpipe_write+0x50>
  8020f8:	4a                   	dec    %edx
  8020f9:	83 ca e0             	or     $0xffffffe0,%edx
  8020fc:	42                   	inc    %edx
  8020fd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802101:	40                   	inc    %eax
  802102:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802105:	47                   	inc    %edi
  802106:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802109:	75 d1                	jne    8020dc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80210b:	89 f8                	mov    %edi,%eax
  80210d:	eb 05                	jmp    802114 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80210f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

0080211c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	57                   	push   %edi
  802120:	56                   	push   %esi
  802121:	53                   	push   %ebx
  802122:	83 ec 1c             	sub    $0x1c,%esp
  802125:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802128:	89 3c 24             	mov    %edi,(%esp)
  80212b:	e8 08 f1 ff ff       	call   801238 <fd2data>
  802130:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802132:	be 00 00 00 00       	mov    $0x0,%esi
  802137:	eb 3a                	jmp    802173 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802139:	85 f6                	test   %esi,%esi
  80213b:	74 04                	je     802141 <devpipe_read+0x25>
				return i;
  80213d:	89 f0                	mov    %esi,%eax
  80213f:	eb 40                	jmp    802181 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802141:	89 da                	mov    %ebx,%edx
  802143:	89 f8                	mov    %edi,%eax
  802145:	e8 f5 fe ff ff       	call   80203f <_pipeisclosed>
  80214a:	85 c0                	test   %eax,%eax
  80214c:	75 2e                	jne    80217c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80214e:	e8 2f ea ff ff       	call   800b82 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802153:	8b 03                	mov    (%ebx),%eax
  802155:	3b 43 04             	cmp    0x4(%ebx),%eax
  802158:	74 df                	je     802139 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80215a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80215f:	79 05                	jns    802166 <devpipe_read+0x4a>
  802161:	48                   	dec    %eax
  802162:	83 c8 e0             	or     $0xffffffe0,%eax
  802165:	40                   	inc    %eax
  802166:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80216a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80216d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802170:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802172:	46                   	inc    %esi
  802173:	3b 75 10             	cmp    0x10(%ebp),%esi
  802176:	75 db                	jne    802153 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802178:	89 f0                	mov    %esi,%eax
  80217a:	eb 05                	jmp    802181 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80217c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    

00802189 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	57                   	push   %edi
  80218d:	56                   	push   %esi
  80218e:	53                   	push   %ebx
  80218f:	83 ec 3c             	sub    $0x3c,%esp
  802192:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802195:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802198:	89 04 24             	mov    %eax,(%esp)
  80219b:	e8 b3 f0 ff ff       	call   801253 <fd_alloc>
  8021a0:	89 c3                	mov    %eax,%ebx
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	0f 88 45 01 00 00    	js     8022ef <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021aa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021b1:	00 
  8021b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c0:	e8 dc e9 ff ff       	call   800ba1 <sys_page_alloc>
  8021c5:	89 c3                	mov    %eax,%ebx
  8021c7:	85 c0                	test   %eax,%eax
  8021c9:	0f 88 20 01 00 00    	js     8022ef <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8021d2:	89 04 24             	mov    %eax,(%esp)
  8021d5:	e8 79 f0 ff ff       	call   801253 <fd_alloc>
  8021da:	89 c3                	mov    %eax,%ebx
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	0f 88 f8 00 00 00    	js     8022dc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021eb:	00 
  8021ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021fa:	e8 a2 e9 ff ff       	call   800ba1 <sys_page_alloc>
  8021ff:	89 c3                	mov    %eax,%ebx
  802201:	85 c0                	test   %eax,%eax
  802203:	0f 88 d3 00 00 00    	js     8022dc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802209:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80220c:	89 04 24             	mov    %eax,(%esp)
  80220f:	e8 24 f0 ff ff       	call   801238 <fd2data>
  802214:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802216:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80221d:	00 
  80221e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802222:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802229:	e8 73 e9 ff ff       	call   800ba1 <sys_page_alloc>
  80222e:	89 c3                	mov    %eax,%ebx
  802230:	85 c0                	test   %eax,%eax
  802232:	0f 88 91 00 00 00    	js     8022c9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802238:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80223b:	89 04 24             	mov    %eax,(%esp)
  80223e:	e8 f5 ef ff ff       	call   801238 <fd2data>
  802243:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80224a:	00 
  80224b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80224f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802256:	00 
  802257:	89 74 24 04          	mov    %esi,0x4(%esp)
  80225b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802262:	e8 8e e9 ff ff       	call   800bf5 <sys_page_map>
  802267:	89 c3                	mov    %eax,%ebx
  802269:	85 c0                	test   %eax,%eax
  80226b:	78 4c                	js     8022b9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80226d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802273:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802276:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802278:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80227b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802282:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802288:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80228b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80228d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802290:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80229a:	89 04 24             	mov    %eax,(%esp)
  80229d:	e8 86 ef ff ff       	call   801228 <fd2num>
  8022a2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8022a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022a7:	89 04 24             	mov    %eax,(%esp)
  8022aa:	e8 79 ef ff ff       	call   801228 <fd2num>
  8022af:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8022b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022b7:	eb 36                	jmp    8022ef <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8022b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c4:	e8 7f e9 ff ff       	call   800c48 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8022c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d7:	e8 6c e9 ff ff       	call   800c48 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8022dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ea:	e8 59 e9 ff ff       	call   800c48 <sys_page_unmap>
    err:
	return r;
}
  8022ef:	89 d8                	mov    %ebx,%eax
  8022f1:	83 c4 3c             	add    $0x3c,%esp
  8022f4:	5b                   	pop    %ebx
  8022f5:	5e                   	pop    %esi
  8022f6:	5f                   	pop    %edi
  8022f7:	5d                   	pop    %ebp
  8022f8:	c3                   	ret    

008022f9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022f9:	55                   	push   %ebp
  8022fa:	89 e5                	mov    %esp,%ebp
  8022fc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802302:	89 44 24 04          	mov    %eax,0x4(%esp)
  802306:	8b 45 08             	mov    0x8(%ebp),%eax
  802309:	89 04 24             	mov    %eax,(%esp)
  80230c:	e8 95 ef ff ff       	call   8012a6 <fd_lookup>
  802311:	85 c0                	test   %eax,%eax
  802313:	78 15                	js     80232a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802315:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802318:	89 04 24             	mov    %eax,(%esp)
  80231b:	e8 18 ef ff ff       	call   801238 <fd2data>
	return _pipeisclosed(fd, p);
  802320:	89 c2                	mov    %eax,%edx
  802322:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802325:	e8 15 fd ff ff       	call   80203f <_pipeisclosed>
}
  80232a:	c9                   	leave  
  80232b:	c3                   	ret    

0080232c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80232f:	b8 00 00 00 00       	mov    $0x0,%eax
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    

00802336 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80233c:	c7 44 24 04 9b 2e 80 	movl   $0x802e9b,0x4(%esp)
  802343:	00 
  802344:	8b 45 0c             	mov    0xc(%ebp),%eax
  802347:	89 04 24             	mov    %eax,(%esp)
  80234a:	e8 60 e4 ff ff       	call   8007af <strcpy>
	return 0;
}
  80234f:	b8 00 00 00 00       	mov    $0x0,%eax
  802354:	c9                   	leave  
  802355:	c3                   	ret    

00802356 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802356:	55                   	push   %ebp
  802357:	89 e5                	mov    %esp,%ebp
  802359:	57                   	push   %edi
  80235a:	56                   	push   %esi
  80235b:	53                   	push   %ebx
  80235c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802362:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802367:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80236d:	eb 30                	jmp    80239f <devcons_write+0x49>
		m = n - tot;
  80236f:	8b 75 10             	mov    0x10(%ebp),%esi
  802372:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802374:	83 fe 7f             	cmp    $0x7f,%esi
  802377:	76 05                	jbe    80237e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802379:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80237e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802382:	03 45 0c             	add    0xc(%ebp),%eax
  802385:	89 44 24 04          	mov    %eax,0x4(%esp)
  802389:	89 3c 24             	mov    %edi,(%esp)
  80238c:	e8 97 e5 ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  802391:	89 74 24 04          	mov    %esi,0x4(%esp)
  802395:	89 3c 24             	mov    %edi,(%esp)
  802398:	e8 37 e7 ff ff       	call   800ad4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80239d:	01 f3                	add    %esi,%ebx
  80239f:	89 d8                	mov    %ebx,%eax
  8023a1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023a4:	72 c9                	jb     80236f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023a6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8023ac:	5b                   	pop    %ebx
  8023ad:	5e                   	pop    %esi
  8023ae:	5f                   	pop    %edi
  8023af:	5d                   	pop    %ebp
  8023b0:	c3                   	ret    

008023b1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023b1:	55                   	push   %ebp
  8023b2:	89 e5                	mov    %esp,%ebp
  8023b4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8023b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023bb:	75 07                	jne    8023c4 <devcons_read+0x13>
  8023bd:	eb 25                	jmp    8023e4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023bf:	e8 be e7 ff ff       	call   800b82 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023c4:	e8 29 e7 ff ff       	call   800af2 <sys_cgetc>
  8023c9:	85 c0                	test   %eax,%eax
  8023cb:	74 f2                	je     8023bf <devcons_read+0xe>
  8023cd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8023cf:	85 c0                	test   %eax,%eax
  8023d1:	78 1d                	js     8023f0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023d3:	83 f8 04             	cmp    $0x4,%eax
  8023d6:	74 13                	je     8023eb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8023d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023db:	88 10                	mov    %dl,(%eax)
	return 1;
  8023dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e2:	eb 0c                	jmp    8023f0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8023e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8023e9:	eb 05                	jmp    8023f0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023eb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023f0:	c9                   	leave  
  8023f1:	c3                   	ret    

008023f2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023f2:	55                   	push   %ebp
  8023f3:	89 e5                	mov    %esp,%ebp
  8023f5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8023f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802405:	00 
  802406:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802409:	89 04 24             	mov    %eax,(%esp)
  80240c:	e8 c3 e6 ff ff       	call   800ad4 <sys_cputs>
}
  802411:	c9                   	leave  
  802412:	c3                   	ret    

00802413 <getchar>:

int
getchar(void)
{
  802413:	55                   	push   %ebp
  802414:	89 e5                	mov    %esp,%ebp
  802416:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802419:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802420:	00 
  802421:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802424:	89 44 24 04          	mov    %eax,0x4(%esp)
  802428:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80242f:	e8 10 f1 ff ff       	call   801544 <read>
	if (r < 0)
  802434:	85 c0                	test   %eax,%eax
  802436:	78 0f                	js     802447 <getchar+0x34>
		return r;
	if (r < 1)
  802438:	85 c0                	test   %eax,%eax
  80243a:	7e 06                	jle    802442 <getchar+0x2f>
		return -E_EOF;
	return c;
  80243c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802440:	eb 05                	jmp    802447 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802442:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802447:	c9                   	leave  
  802448:	c3                   	ret    

00802449 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802449:	55                   	push   %ebp
  80244a:	89 e5                	mov    %esp,%ebp
  80244c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80244f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802452:	89 44 24 04          	mov    %eax,0x4(%esp)
  802456:	8b 45 08             	mov    0x8(%ebp),%eax
  802459:	89 04 24             	mov    %eax,(%esp)
  80245c:	e8 45 ee ff ff       	call   8012a6 <fd_lookup>
  802461:	85 c0                	test   %eax,%eax
  802463:	78 11                	js     802476 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802465:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802468:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80246e:	39 10                	cmp    %edx,(%eax)
  802470:	0f 94 c0             	sete   %al
  802473:	0f b6 c0             	movzbl %al,%eax
}
  802476:	c9                   	leave  
  802477:	c3                   	ret    

00802478 <opencons>:

int
opencons(void)
{
  802478:	55                   	push   %ebp
  802479:	89 e5                	mov    %esp,%ebp
  80247b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80247e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802481:	89 04 24             	mov    %eax,(%esp)
  802484:	e8 ca ed ff ff       	call   801253 <fd_alloc>
  802489:	85 c0                	test   %eax,%eax
  80248b:	78 3c                	js     8024c9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80248d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802494:	00 
  802495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a3:	e8 f9 e6 ff ff       	call   800ba1 <sys_page_alloc>
  8024a8:	85 c0                	test   %eax,%eax
  8024aa:	78 1d                	js     8024c9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024ac:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024c1:	89 04 24             	mov    %eax,(%esp)
  8024c4:	e8 5f ed ff ff       	call   801228 <fd2num>
}
  8024c9:	c9                   	leave  
  8024ca:	c3                   	ret    
	...

008024cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8024cc:	55                   	push   %ebp
  8024cd:	89 e5                	mov    %esp,%ebp
  8024cf:	56                   	push   %esi
  8024d0:	53                   	push   %ebx
  8024d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8024d4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8024d7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8024dd:	e8 81 e6 ff ff       	call   800b63 <sys_getenvid>
  8024e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8024e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8024ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f8:	c7 04 24 a8 2e 80 00 	movl   $0x802ea8,(%esp)
  8024ff:	e8 00 dd ff ff       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802504:	89 74 24 04          	mov    %esi,0x4(%esp)
  802508:	8b 45 10             	mov    0x10(%ebp),%eax
  80250b:	89 04 24             	mov    %eax,(%esp)
  80250e:	e8 90 dc ff ff       	call   8001a3 <vcprintf>
	cprintf("\n");
  802513:	c7 04 24 8f 29 80 00 	movl   $0x80298f,(%esp)
  80251a:	e8 e5 dc ff ff       	call   800204 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80251f:	cc                   	int3   
  802520:	eb fd                	jmp    80251f <_panic+0x53>
	...

00802524 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802524:	55                   	push   %ebp
  802525:	89 e5                	mov    %esp,%ebp
  802527:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80252a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802531:	75 30                	jne    802563 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  802533:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80253a:	00 
  80253b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802542:	ee 
  802543:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80254a:	e8 52 e6 ff ff       	call   800ba1 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80254f:	c7 44 24 04 70 25 80 	movl   $0x802570,0x4(%esp)
  802556:	00 
  802557:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80255e:	e8 de e7 ff ff       	call   800d41 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802563:	8b 45 08             	mov    0x8(%ebp),%eax
  802566:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80256b:	c9                   	leave  
  80256c:	c3                   	ret    
  80256d:	00 00                	add    %al,(%eax)
	...

00802570 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802570:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802571:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802576:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802578:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  80257b:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  80257f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802583:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  802586:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802588:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  80258c:	83 c4 08             	add    $0x8,%esp
	popal
  80258f:	61                   	popa   

	addl $4,%esp 
  802590:	83 c4 04             	add    $0x4,%esp
	popfl
  802593:	9d                   	popf   

	popl %esp
  802594:	5c                   	pop    %esp

	ret
  802595:	c3                   	ret    
	...

00802598 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802598:	55                   	push   %ebp
  802599:	89 e5                	mov    %esp,%ebp
  80259b:	56                   	push   %esi
  80259c:	53                   	push   %ebx
  80259d:	83 ec 10             	sub    $0x10,%esp
  8025a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8025a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025a6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8025a9:	85 c0                	test   %eax,%eax
  8025ab:	74 0a                	je     8025b7 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8025ad:	89 04 24             	mov    %eax,(%esp)
  8025b0:	e8 02 e8 ff ff       	call   800db7 <sys_ipc_recv>
  8025b5:	eb 0c                	jmp    8025c3 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8025b7:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8025be:	e8 f4 e7 ff ff       	call   800db7 <sys_ipc_recv>
	}
	if (r < 0)
  8025c3:	85 c0                	test   %eax,%eax
  8025c5:	79 16                	jns    8025dd <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8025c7:	85 db                	test   %ebx,%ebx
  8025c9:	74 06                	je     8025d1 <ipc_recv+0x39>
  8025cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8025d1:	85 f6                	test   %esi,%esi
  8025d3:	74 2c                	je     802601 <ipc_recv+0x69>
  8025d5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8025db:	eb 24                	jmp    802601 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8025dd:	85 db                	test   %ebx,%ebx
  8025df:	74 0a                	je     8025eb <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8025e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8025e6:	8b 40 74             	mov    0x74(%eax),%eax
  8025e9:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8025eb:	85 f6                	test   %esi,%esi
  8025ed:	74 0a                	je     8025f9 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8025ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8025f4:	8b 40 78             	mov    0x78(%eax),%eax
  8025f7:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8025f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8025fe:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802601:	83 c4 10             	add    $0x10,%esp
  802604:	5b                   	pop    %ebx
  802605:	5e                   	pop    %esi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    

00802608 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802608:	55                   	push   %ebp
  802609:	89 e5                	mov    %esp,%ebp
  80260b:	57                   	push   %edi
  80260c:	56                   	push   %esi
  80260d:	53                   	push   %ebx
  80260e:	83 ec 1c             	sub    $0x1c,%esp
  802611:	8b 75 08             	mov    0x8(%ebp),%esi
  802614:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802617:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80261a:	85 db                	test   %ebx,%ebx
  80261c:	74 19                	je     802637 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80261e:	8b 45 14             	mov    0x14(%ebp),%eax
  802621:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802625:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802629:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80262d:	89 34 24             	mov    %esi,(%esp)
  802630:	e8 5f e7 ff ff       	call   800d94 <sys_ipc_try_send>
  802635:	eb 1c                	jmp    802653 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802637:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80263e:	00 
  80263f:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802646:	ee 
  802647:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80264b:	89 34 24             	mov    %esi,(%esp)
  80264e:	e8 41 e7 ff ff       	call   800d94 <sys_ipc_try_send>
		}
		if (r == 0)
  802653:	85 c0                	test   %eax,%eax
  802655:	74 2c                	je     802683 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802657:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80265a:	74 20                	je     80267c <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  80265c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802660:	c7 44 24 08 cc 2e 80 	movl   $0x802ecc,0x8(%esp)
  802667:	00 
  802668:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80266f:	00 
  802670:	c7 04 24 df 2e 80 00 	movl   $0x802edf,(%esp)
  802677:	e8 50 fe ff ff       	call   8024cc <_panic>
		}
		sys_yield();
  80267c:	e8 01 e5 ff ff       	call   800b82 <sys_yield>
	}
  802681:	eb 97                	jmp    80261a <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802683:	83 c4 1c             	add    $0x1c,%esp
  802686:	5b                   	pop    %ebx
  802687:	5e                   	pop    %esi
  802688:	5f                   	pop    %edi
  802689:	5d                   	pop    %ebp
  80268a:	c3                   	ret    

0080268b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80268b:	55                   	push   %ebp
  80268c:	89 e5                	mov    %esp,%ebp
  80268e:	53                   	push   %ebx
  80268f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802692:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802697:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80269e:	89 c2                	mov    %eax,%edx
  8026a0:	c1 e2 07             	shl    $0x7,%edx
  8026a3:	29 ca                	sub    %ecx,%edx
  8026a5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026ab:	8b 52 50             	mov    0x50(%edx),%edx
  8026ae:	39 da                	cmp    %ebx,%edx
  8026b0:	75 0f                	jne    8026c1 <ipc_find_env+0x36>
			return envs[i].env_id;
  8026b2:	c1 e0 07             	shl    $0x7,%eax
  8026b5:	29 c8                	sub    %ecx,%eax
  8026b7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8026bc:	8b 40 40             	mov    0x40(%eax),%eax
  8026bf:	eb 0c                	jmp    8026cd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026c1:	40                   	inc    %eax
  8026c2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026c7:	75 ce                	jne    802697 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026c9:	66 b8 00 00          	mov    $0x0,%ax
}
  8026cd:	5b                   	pop    %ebx
  8026ce:	5d                   	pop    %ebp
  8026cf:	c3                   	ret    

008026d0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026d0:	55                   	push   %ebp
  8026d1:	89 e5                	mov    %esp,%ebp
  8026d3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026d6:	89 c2                	mov    %eax,%edx
  8026d8:	c1 ea 16             	shr    $0x16,%edx
  8026db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026e2:	f6 c2 01             	test   $0x1,%dl
  8026e5:	74 1e                	je     802705 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026e7:	c1 e8 0c             	shr    $0xc,%eax
  8026ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026f1:	a8 01                	test   $0x1,%al
  8026f3:	74 17                	je     80270c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026f5:	c1 e8 0c             	shr    $0xc,%eax
  8026f8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8026ff:	ef 
  802700:	0f b7 c0             	movzwl %ax,%eax
  802703:	eb 0c                	jmp    802711 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802705:	b8 00 00 00 00       	mov    $0x0,%eax
  80270a:	eb 05                	jmp    802711 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80270c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802711:	5d                   	pop    %ebp
  802712:	c3                   	ret    
	...

00802714 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802714:	55                   	push   %ebp
  802715:	57                   	push   %edi
  802716:	56                   	push   %esi
  802717:	83 ec 10             	sub    $0x10,%esp
  80271a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80271e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802722:	89 74 24 04          	mov    %esi,0x4(%esp)
  802726:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80272a:	89 cd                	mov    %ecx,%ebp
  80272c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802730:	85 c0                	test   %eax,%eax
  802732:	75 2c                	jne    802760 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802734:	39 f9                	cmp    %edi,%ecx
  802736:	77 68                	ja     8027a0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802738:	85 c9                	test   %ecx,%ecx
  80273a:	75 0b                	jne    802747 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80273c:	b8 01 00 00 00       	mov    $0x1,%eax
  802741:	31 d2                	xor    %edx,%edx
  802743:	f7 f1                	div    %ecx
  802745:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802747:	31 d2                	xor    %edx,%edx
  802749:	89 f8                	mov    %edi,%eax
  80274b:	f7 f1                	div    %ecx
  80274d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80274f:	89 f0                	mov    %esi,%eax
  802751:	f7 f1                	div    %ecx
  802753:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802755:	89 f0                	mov    %esi,%eax
  802757:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802759:	83 c4 10             	add    $0x10,%esp
  80275c:	5e                   	pop    %esi
  80275d:	5f                   	pop    %edi
  80275e:	5d                   	pop    %ebp
  80275f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802760:	39 f8                	cmp    %edi,%eax
  802762:	77 2c                	ja     802790 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802764:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802767:	83 f6 1f             	xor    $0x1f,%esi
  80276a:	75 4c                	jne    8027b8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80276c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80276e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802773:	72 0a                	jb     80277f <__udivdi3+0x6b>
  802775:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802779:	0f 87 ad 00 00 00    	ja     80282c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80277f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802784:	89 f0                	mov    %esi,%eax
  802786:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802788:	83 c4 10             	add    $0x10,%esp
  80278b:	5e                   	pop    %esi
  80278c:	5f                   	pop    %edi
  80278d:	5d                   	pop    %ebp
  80278e:	c3                   	ret    
  80278f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802790:	31 ff                	xor    %edi,%edi
  802792:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802794:	89 f0                	mov    %esi,%eax
  802796:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802798:	83 c4 10             	add    $0x10,%esp
  80279b:	5e                   	pop    %esi
  80279c:	5f                   	pop    %edi
  80279d:	5d                   	pop    %ebp
  80279e:	c3                   	ret    
  80279f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027a0:	89 fa                	mov    %edi,%edx
  8027a2:	89 f0                	mov    %esi,%eax
  8027a4:	f7 f1                	div    %ecx
  8027a6:	89 c6                	mov    %eax,%esi
  8027a8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027aa:	89 f0                	mov    %esi,%eax
  8027ac:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027ae:	83 c4 10             	add    $0x10,%esp
  8027b1:	5e                   	pop    %esi
  8027b2:	5f                   	pop    %edi
  8027b3:	5d                   	pop    %ebp
  8027b4:	c3                   	ret    
  8027b5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027b8:	89 f1                	mov    %esi,%ecx
  8027ba:	d3 e0                	shl    %cl,%eax
  8027bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027c0:	b8 20 00 00 00       	mov    $0x20,%eax
  8027c5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8027c7:	89 ea                	mov    %ebp,%edx
  8027c9:	88 c1                	mov    %al,%cl
  8027cb:	d3 ea                	shr    %cl,%edx
  8027cd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8027d1:	09 ca                	or     %ecx,%edx
  8027d3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8027d7:	89 f1                	mov    %esi,%ecx
  8027d9:	d3 e5                	shl    %cl,%ebp
  8027db:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8027df:	89 fd                	mov    %edi,%ebp
  8027e1:	88 c1                	mov    %al,%cl
  8027e3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8027e5:	89 fa                	mov    %edi,%edx
  8027e7:	89 f1                	mov    %esi,%ecx
  8027e9:	d3 e2                	shl    %cl,%edx
  8027eb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8027ef:	88 c1                	mov    %al,%cl
  8027f1:	d3 ef                	shr    %cl,%edi
  8027f3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027f5:	89 f8                	mov    %edi,%eax
  8027f7:	89 ea                	mov    %ebp,%edx
  8027f9:	f7 74 24 08          	divl   0x8(%esp)
  8027fd:	89 d1                	mov    %edx,%ecx
  8027ff:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802801:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802805:	39 d1                	cmp    %edx,%ecx
  802807:	72 17                	jb     802820 <__udivdi3+0x10c>
  802809:	74 09                	je     802814 <__udivdi3+0x100>
  80280b:	89 fe                	mov    %edi,%esi
  80280d:	31 ff                	xor    %edi,%edi
  80280f:	e9 41 ff ff ff       	jmp    802755 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802814:	8b 54 24 04          	mov    0x4(%esp),%edx
  802818:	89 f1                	mov    %esi,%ecx
  80281a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80281c:	39 c2                	cmp    %eax,%edx
  80281e:	73 eb                	jae    80280b <__udivdi3+0xf7>
		{
		  q0--;
  802820:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802823:	31 ff                	xor    %edi,%edi
  802825:	e9 2b ff ff ff       	jmp    802755 <__udivdi3+0x41>
  80282a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80282c:	31 f6                	xor    %esi,%esi
  80282e:	e9 22 ff ff ff       	jmp    802755 <__udivdi3+0x41>
	...

00802834 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802834:	55                   	push   %ebp
  802835:	57                   	push   %edi
  802836:	56                   	push   %esi
  802837:	83 ec 20             	sub    $0x20,%esp
  80283a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80283e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802842:	89 44 24 14          	mov    %eax,0x14(%esp)
  802846:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80284a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80284e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802852:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802854:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802856:	85 ed                	test   %ebp,%ebp
  802858:	75 16                	jne    802870 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80285a:	39 f1                	cmp    %esi,%ecx
  80285c:	0f 86 a6 00 00 00    	jbe    802908 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802862:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802864:	89 d0                	mov    %edx,%eax
  802866:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802868:	83 c4 20             	add    $0x20,%esp
  80286b:	5e                   	pop    %esi
  80286c:	5f                   	pop    %edi
  80286d:	5d                   	pop    %ebp
  80286e:	c3                   	ret    
  80286f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802870:	39 f5                	cmp    %esi,%ebp
  802872:	0f 87 ac 00 00 00    	ja     802924 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802878:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80287b:	83 f0 1f             	xor    $0x1f,%eax
  80287e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802882:	0f 84 a8 00 00 00    	je     802930 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802888:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80288c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80288e:	bf 20 00 00 00       	mov    $0x20,%edi
  802893:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802897:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80289b:	89 f9                	mov    %edi,%ecx
  80289d:	d3 e8                	shr    %cl,%eax
  80289f:	09 e8                	or     %ebp,%eax
  8028a1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8028a5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028a9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028ad:	d3 e0                	shl    %cl,%eax
  8028af:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028b3:	89 f2                	mov    %esi,%edx
  8028b5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8028b7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028bb:	d3 e0                	shl    %cl,%eax
  8028bd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028c1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028c5:	89 f9                	mov    %edi,%ecx
  8028c7:	d3 e8                	shr    %cl,%eax
  8028c9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8028cb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028cd:	89 f2                	mov    %esi,%edx
  8028cf:	f7 74 24 18          	divl   0x18(%esp)
  8028d3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8028d5:	f7 64 24 0c          	mull   0xc(%esp)
  8028d9:	89 c5                	mov    %eax,%ebp
  8028db:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028dd:	39 d6                	cmp    %edx,%esi
  8028df:	72 67                	jb     802948 <__umoddi3+0x114>
  8028e1:	74 75                	je     802958 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8028e3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8028e7:	29 e8                	sub    %ebp,%eax
  8028e9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8028eb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028ef:	d3 e8                	shr    %cl,%eax
  8028f1:	89 f2                	mov    %esi,%edx
  8028f3:	89 f9                	mov    %edi,%ecx
  8028f5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8028f7:	09 d0                	or     %edx,%eax
  8028f9:	89 f2                	mov    %esi,%edx
  8028fb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028ff:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802901:	83 c4 20             	add    $0x20,%esp
  802904:	5e                   	pop    %esi
  802905:	5f                   	pop    %edi
  802906:	5d                   	pop    %ebp
  802907:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802908:	85 c9                	test   %ecx,%ecx
  80290a:	75 0b                	jne    802917 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80290c:	b8 01 00 00 00       	mov    $0x1,%eax
  802911:	31 d2                	xor    %edx,%edx
  802913:	f7 f1                	div    %ecx
  802915:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802917:	89 f0                	mov    %esi,%eax
  802919:	31 d2                	xor    %edx,%edx
  80291b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80291d:	89 f8                	mov    %edi,%eax
  80291f:	e9 3e ff ff ff       	jmp    802862 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802924:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802926:	83 c4 20             	add    $0x20,%esp
  802929:	5e                   	pop    %esi
  80292a:	5f                   	pop    %edi
  80292b:	5d                   	pop    %ebp
  80292c:	c3                   	ret    
  80292d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802930:	39 f5                	cmp    %esi,%ebp
  802932:	72 04                	jb     802938 <__umoddi3+0x104>
  802934:	39 f9                	cmp    %edi,%ecx
  802936:	77 06                	ja     80293e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802938:	89 f2                	mov    %esi,%edx
  80293a:	29 cf                	sub    %ecx,%edi
  80293c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80293e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802940:	83 c4 20             	add    $0x20,%esp
  802943:	5e                   	pop    %esi
  802944:	5f                   	pop    %edi
  802945:	5d                   	pop    %ebp
  802946:	c3                   	ret    
  802947:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802948:	89 d1                	mov    %edx,%ecx
  80294a:	89 c5                	mov    %eax,%ebp
  80294c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802950:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802954:	eb 8d                	jmp    8028e3 <__umoddi3+0xaf>
  802956:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802958:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80295c:	72 ea                	jb     802948 <__umoddi3+0x114>
  80295e:	89 f1                	mov    %esi,%ecx
  802960:	eb 81                	jmp    8028e3 <__umoddi3+0xaf>
