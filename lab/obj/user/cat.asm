
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 33 01 00 00       	call   800164 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800043:	eb 40                	jmp    800085 <cat+0x51>
		if ((r = write(1, buf, n)) != n)
  800045:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800049:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800050:	00 
  800051:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800058:	e8 ce 12 00 00       	call   80132b <write>
  80005d:	39 d8                	cmp    %ebx,%eax
  80005f:	74 24                	je     800085 <cat+0x51>
			panic("write error copying %s: %e", s, r);
  800061:	89 44 24 10          	mov    %eax,0x10(%esp)
  800065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800069:	c7 44 24 08 e0 26 80 	movl   $0x8026e0,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 fb 26 80 00 	movl   $0x8026fb,(%esp)
  800080:	e8 4f 01 00 00       	call   8001d4 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800085:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800094:	00 
  800095:	89 34 24             	mov    %esi,(%esp)
  800098:	e8 b3 11 00 00       	call   801250 <read>
  80009d:	89 c3                	mov    %eax,%ebx
  80009f:	85 c0                	test   %eax,%eax
  8000a1:	7f a2                	jg     800045 <cat+0x11>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 24                	jns    8000cb <cat+0x97>
		panic("error reading %s: %e", s, n);
  8000a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000af:	c7 44 24 08 06 27 80 	movl   $0x802706,0x8(%esp)
  8000b6:	00 
  8000b7:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 fb 26 80 00 	movl   $0x8026fb,(%esp)
  8000c6:	e8 09 01 00 00       	call   8001d4 <_panic>
}
  8000cb:	83 c4 2c             	add    $0x2c,%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int f, i;

	binaryname = "cat";
  8000df:	c7 05 00 30 80 00 1b 	movl   $0x80271b,0x803000
  8000e6:	27 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	75 62                	jne    800151 <umain+0x7e>
		cat(0, "<stdin>");
  8000ef:	c7 44 24 04 1f 27 80 	movl   $0x80271f,0x4(%esp)
  8000f6:	00 
  8000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fe:	e8 31 ff ff ff       	call   800034 <cat>
  800103:	eb 56                	jmp    80015b <umain+0x88>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80010c:	00 
  80010d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800110:	89 04 24             	mov    %eax,(%esp)
  800113:	e8 0b 16 00 00       	call   801723 <open>
  800118:	89 c7                	mov    %eax,%edi
			if (f < 0)
  80011a:	85 c0                	test   %eax,%eax
  80011c:	79 19                	jns    800137 <umain+0x64>
				printf("can't open %s: %e\n", argv[i], f);
  80011e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800122:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	c7 04 24 27 27 80 00 	movl   $0x802727,(%esp)
  800130:	e8 a4 17 00 00       	call   8018d9 <printf>
  800135:	eb 17                	jmp    80014e <umain+0x7b>
			else {
				cat(f, argv[i]);
  800137:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	89 3c 24             	mov    %edi,(%esp)
  800141:	e8 ee fe ff ff       	call   800034 <cat>
				close(f);
  800146:	89 3c 24             	mov    %edi,(%esp)
  800149:	e8 9c 0f 00 00       	call   8010ea <close>

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80014e:	43                   	inc    %ebx
  80014f:	eb 05                	jmp    800156 <umain+0x83>
umain(int argc, char **argv)
{
	int f, i;

	binaryname = "cat";
	if (argc == 1)
  800151:	bb 01 00 00 00       	mov    $0x1,%ebx
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800156:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800159:	7c aa                	jl     800105 <umain+0x32>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80015b:	83 c4 1c             	add    $0x1c,%esp
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    
	...

00800164 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 10             	sub    $0x10,%esp
  80016c:	8b 75 08             	mov    0x8(%ebp),%esi
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800172:	e8 b4 0a 00 00       	call   800c2b <sys_getenvid>
  800177:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800183:	c1 e0 07             	shl    $0x7,%eax
  800186:	29 d0                	sub    %edx,%eax
  800188:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80018d:	a3 20 60 80 00       	mov    %eax,0x806020


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800192:	85 f6                	test   %esi,%esi
  800194:	7e 07                	jle    80019d <libmain+0x39>
		binaryname = argv[0];
  800196:	8b 03                	mov    (%ebx),%eax
  800198:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80019d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 2a ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001a9:	e8 0a 00 00 00       	call   8001b8 <exit>
}
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001be:	e8 58 0f 00 00       	call   80111b <close_all>
	sys_env_destroy(0);
  8001c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ca:	e8 0a 0a 00 00       	call   800bd9 <sys_env_destroy>
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    
  8001d1:	00 00                	add    %al,(%eax)
	...

008001d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001dc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001df:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001e5:	e8 41 0a 00 00       	call   800c2b <sys_getenvid>
  8001ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800200:	c7 04 24 44 27 80 00 	movl   $0x802744,(%esp)
  800207:	e8 c0 00 00 00       	call   8002cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 50 00 00 00       	call   80026b <vcprintf>
	cprintf("\n");
  80021b:	c7 04 24 a8 2b 80 00 	movl   $0x802ba8,(%esp)
  800222:	e8 a5 00 00 00       	call   8002cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800227:	cc                   	int3   
  800228:	eb fd                	jmp    800227 <_panic+0x53>
	...

0080022c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	53                   	push   %ebx
  800230:	83 ec 14             	sub    $0x14,%esp
  800233:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800236:	8b 03                	mov    (%ebx),%eax
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80023f:	40                   	inc    %eax
  800240:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800242:	3d ff 00 00 00       	cmp    $0xff,%eax
  800247:	75 19                	jne    800262 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800249:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800250:	00 
  800251:	8d 43 08             	lea    0x8(%ebx),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 40 09 00 00       	call   800b9c <sys_cputs>
		b->idx = 0;
  80025c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800262:	ff 43 04             	incl   0x4(%ebx)
}
  800265:	83 c4 14             	add    $0x14,%esp
  800268:	5b                   	pop    %ebx
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800274:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027b:	00 00 00 
	b.cnt = 0;
  80027e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800285:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	89 44 24 08          	mov    %eax,0x8(%esp)
  800296:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	c7 04 24 2c 02 80 00 	movl   $0x80022c,(%esp)
  8002a7:	e8 82 01 00 00       	call   80042e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 d8 08 00 00       	call   800b9c <sys_cputs>

	return b.cnt;
}
  8002c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	e8 87 ff ff ff       	call   80026b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    
	...

008002e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 3c             	sub    $0x3c,%esp
  8002f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f4:	89 d7                	mov    %edx,%edi
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800302:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800305:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800308:	85 c0                	test   %eax,%eax
  80030a:	75 08                	jne    800314 <printnum+0x2c>
  80030c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800312:	77 57                	ja     80036b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	89 74 24 10          	mov    %esi,0x10(%esp)
  800318:	4b                   	dec    %ebx
  800319:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80031d:	8b 45 10             	mov    0x10(%ebp),%eax
  800320:	89 44 24 08          	mov    %eax,0x8(%esp)
  800324:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800328:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80032c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800333:	00 
  800334:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	e8 46 21 00 00       	call   80248c <__udivdi3>
  800346:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80034a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80034e:	89 04 24             	mov    %eax,(%esp)
  800351:	89 54 24 04          	mov    %edx,0x4(%esp)
  800355:	89 fa                	mov    %edi,%edx
  800357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035a:	e8 89 ff ff ff       	call   8002e8 <printnum>
  80035f:	eb 0f                	jmp    800370 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800361:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800365:	89 34 24             	mov    %esi,(%esp)
  800368:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036b:	4b                   	dec    %ebx
  80036c:	85 db                	test   %ebx,%ebx
  80036e:	7f f1                	jg     800361 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800370:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800374:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800378:	8b 45 10             	mov    0x10(%ebp),%eax
  80037b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800386:	00 
  800387:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800390:	89 44 24 04          	mov    %eax,0x4(%esp)
  800394:	e8 13 22 00 00       	call   8025ac <__umoddi3>
  800399:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039d:	0f be 80 67 27 80 00 	movsbl 0x802767(%eax),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003aa:	83 c4 3c             	add    $0x3c,%esp
  8003ad:	5b                   	pop    %ebx
  8003ae:	5e                   	pop    %esi
  8003af:	5f                   	pop    %edi
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b5:	83 fa 01             	cmp    $0x1,%edx
  8003b8:	7e 0e                	jle    8003c8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bf:	89 08                	mov    %ecx,(%eax)
  8003c1:	8b 02                	mov    (%edx),%eax
  8003c3:	8b 52 04             	mov    0x4(%edx),%edx
  8003c6:	eb 22                	jmp    8003ea <getuint+0x38>
	else if (lflag)
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	74 10                	je     8003dc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d1:	89 08                	mov    %ecx,(%eax)
  8003d3:	8b 02                	mov    (%edx),%eax
  8003d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003da:	eb 0e                	jmp    8003ea <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fa:	73 08                	jae    800404 <sprintputch+0x18>
		*b->buf++ = ch;
  8003fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ff:	88 0a                	mov    %cl,(%edx)
  800401:	42                   	inc    %edx
  800402:	89 10                	mov    %edx,(%eax)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800413:	8b 45 10             	mov    0x10(%ebp),%eax
  800416:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	e8 02 00 00 00       	call   80042e <vprintfmt>
	va_end(ap);
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
  800434:	83 ec 4c             	sub    $0x4c,%esp
  800437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043a:	8b 75 10             	mov    0x10(%ebp),%esi
  80043d:	eb 12                	jmp    800451 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043f:	85 c0                	test   %eax,%eax
  800441:	0f 84 6b 03 00 00    	je     8007b2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800447:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044b:	89 04 24             	mov    %eax,(%esp)
  80044e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800451:	0f b6 06             	movzbl (%esi),%eax
  800454:	46                   	inc    %esi
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e5                	jne    80043f <vprintfmt+0x11>
  80045a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80045e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800465:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80046a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800471:	b9 00 00 00 00       	mov    $0x0,%ecx
  800476:	eb 26                	jmp    80049e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80047f:	eb 1d                	jmp    80049e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800484:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800488:	eb 14                	jmp    80049e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80048d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800494:	eb 08                	jmp    80049e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800496:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800499:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	0f b6 06             	movzbl (%esi),%eax
  8004a1:	8d 56 01             	lea    0x1(%esi),%edx
  8004a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a7:	8a 16                	mov    (%esi),%dl
  8004a9:	83 ea 23             	sub    $0x23,%edx
  8004ac:	80 fa 55             	cmp    $0x55,%dl
  8004af:	0f 87 e1 02 00 00    	ja     800796 <vprintfmt+0x368>
  8004b5:	0f b6 d2             	movzbl %dl,%edx
  8004b8:	ff 24 95 a0 28 80 00 	jmp    *0x8028a0(,%edx,4)
  8004bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ca:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004ce:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d4:	83 fa 09             	cmp    $0x9,%edx
  8004d7:	77 2a                	ja     800503 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004da:	eb eb                	jmp    8004c7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ea:	eb 17                	jmp    800503 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f0:	78 98                	js     80048a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f5:	eb a7                	jmp    80049e <vprintfmt+0x70>
  8004f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004fa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800501:	eb 9b                	jmp    80049e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800503:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800507:	79 95                	jns    80049e <vprintfmt+0x70>
  800509:	eb 8b                	jmp    800496 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050f:	eb 8d                	jmp    80049e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 04 24             	mov    %eax,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800529:	e9 23 ff ff ff       	jmp    800451 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	8b 00                	mov    (%eax),%eax
  800539:	85 c0                	test   %eax,%eax
  80053b:	79 02                	jns    80053f <vprintfmt+0x111>
  80053d:	f7 d8                	neg    %eax
  80053f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800541:	83 f8 10             	cmp    $0x10,%eax
  800544:	7f 0b                	jg     800551 <vprintfmt+0x123>
  800546:	8b 04 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%eax
  80054d:	85 c0                	test   %eax,%eax
  80054f:	75 23                	jne    800574 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800551:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800555:	c7 44 24 08 7f 27 80 	movl   $0x80277f,0x8(%esp)
  80055c:	00 
  80055d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800561:	8b 45 08             	mov    0x8(%ebp),%eax
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	e8 9a fe ff ff       	call   800406 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056f:	e9 dd fe ff ff       	jmp    800451 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800574:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800578:	c7 44 24 08 3d 2b 80 	movl   $0x802b3d,0x8(%esp)
  80057f:	00 
  800580:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800584:	8b 55 08             	mov    0x8(%ebp),%edx
  800587:	89 14 24             	mov    %edx,(%esp)
  80058a:	e8 77 fe ff ff       	call   800406 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800592:	e9 ba fe ff ff       	jmp    800451 <vprintfmt+0x23>
  800597:	89 f9                	mov    %edi,%ecx
  800599:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 30                	mov    (%eax),%esi
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	75 05                	jne    8005b3 <vprintfmt+0x185>
				p = "(null)";
  8005ae:	be 78 27 80 00       	mov    $0x802778,%esi
			if (width > 0 && padc != '-')
  8005b3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b7:	0f 8e 84 00 00 00    	jle    800641 <vprintfmt+0x213>
  8005bd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005c1:	74 7e                	je     800641 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c7:	89 34 24             	mov    %esi,(%esp)
  8005ca:	e8 8b 02 00 00       	call   80085a <strnlen>
  8005cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005d2:	29 c2                	sub    %eax,%edx
  8005d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005d7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005db:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005de:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005e1:	89 de                	mov    %ebx,%esi
  8005e3:	89 d3                	mov    %edx,%ebx
  8005e5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e7:	eb 0b                	jmp    8005f4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ed:	89 3c 24             	mov    %edi,(%esp)
  8005f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	4b                   	dec    %ebx
  8005f4:	85 db                	test   %ebx,%ebx
  8005f6:	7f f1                	jg     8005e9 <vprintfmt+0x1bb>
  8005f8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005fb:	89 f3                	mov    %esi,%ebx
  8005fd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800603:	85 c0                	test   %eax,%eax
  800605:	79 05                	jns    80060c <vprintfmt+0x1de>
  800607:	b8 00 00 00 00       	mov    $0x0,%eax
  80060c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060f:	29 c2                	sub    %eax,%edx
  800611:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800614:	eb 2b                	jmp    800641 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800616:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061a:	74 18                	je     800634 <vprintfmt+0x206>
  80061c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80061f:	83 fa 5e             	cmp    $0x5e,%edx
  800622:	76 10                	jbe    800634 <vprintfmt+0x206>
					putch('?', putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
  800632:	eb 0a                	jmp    80063e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063e:	ff 4d e4             	decl   -0x1c(%ebp)
  800641:	0f be 06             	movsbl (%esi),%eax
  800644:	46                   	inc    %esi
  800645:	85 c0                	test   %eax,%eax
  800647:	74 21                	je     80066a <vprintfmt+0x23c>
  800649:	85 ff                	test   %edi,%edi
  80064b:	78 c9                	js     800616 <vprintfmt+0x1e8>
  80064d:	4f                   	dec    %edi
  80064e:	79 c6                	jns    800616 <vprintfmt+0x1e8>
  800650:	8b 7d 08             	mov    0x8(%ebp),%edi
  800653:	89 de                	mov    %ebx,%esi
  800655:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800658:	eb 18                	jmp    800672 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800665:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800667:	4b                   	dec    %ebx
  800668:	eb 08                	jmp    800672 <vprintfmt+0x244>
  80066a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066d:	89 de                	mov    %ebx,%esi
  80066f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800672:	85 db                	test   %ebx,%ebx
  800674:	7f e4                	jg     80065a <vprintfmt+0x22c>
  800676:	89 7d 08             	mov    %edi,0x8(%ebp)
  800679:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067e:	e9 ce fd ff ff       	jmp    800451 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800683:	83 f9 01             	cmp    $0x1,%ecx
  800686:	7e 10                	jle    800698 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 08             	lea    0x8(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	8b 30                	mov    (%eax),%esi
  800693:	8b 78 04             	mov    0x4(%eax),%edi
  800696:	eb 26                	jmp    8006be <vprintfmt+0x290>
	else if (lflag)
  800698:	85 c9                	test   %ecx,%ecx
  80069a:	74 12                	je     8006ae <vprintfmt+0x280>
		return va_arg(*ap, long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a5:	8b 30                	mov    (%eax),%esi
  8006a7:	89 f7                	mov    %esi,%edi
  8006a9:	c1 ff 1f             	sar    $0x1f,%edi
  8006ac:	eb 10                	jmp    8006be <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b7:	8b 30                	mov    (%eax),%esi
  8006b9:	89 f7                	mov    %esi,%edi
  8006bb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	78 0a                	js     8006cc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c7:	e9 8c 00 00 00       	jmp    800758 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006da:	f7 de                	neg    %esi
  8006dc:	83 d7 00             	adc    $0x0,%edi
  8006df:	f7 df                	neg    %edi
			}
			base = 10;
  8006e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e6:	eb 70                	jmp    800758 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e8:	89 ca                	mov    %ecx,%edx
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 c0 fc ff ff       	call   8003b2 <getuint>
  8006f2:	89 c6                	mov    %eax,%esi
  8006f4:	89 d7                	mov    %edx,%edi
			base = 10;
  8006f6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006fb:	eb 5b                	jmp    800758 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8006fd:	89 ca                	mov    %ecx,%edx
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800702:	e8 ab fc ff ff       	call   8003b2 <getuint>
  800707:	89 c6                	mov    %eax,%esi
  800709:	89 d7                	mov    %edx,%edi
			base = 8;
  80070b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800710:	eb 46                	jmp    800758 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800712:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800716:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 50 04             	lea    0x4(%eax),%edx
  800734:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800737:	8b 30                	mov    (%eax),%esi
  800739:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800743:	eb 13                	jmp    800758 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800745:	89 ca                	mov    %ecx,%edx
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 63 fc ff ff       	call   8003b2 <getuint>
  80074f:	89 c6                	mov    %eax,%esi
  800751:	89 d7                	mov    %edx,%edi
			base = 16;
  800753:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800758:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80075c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800760:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800763:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076b:	89 34 24             	mov    %esi,(%esp)
  80076e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800772:	89 da                	mov    %ebx,%edx
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	e8 6c fb ff ff       	call   8002e8 <printnum>
			break;
  80077c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80077f:	e9 cd fc ff ff       	jmp    800451 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800784:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800788:	89 04 24             	mov    %eax,(%esp)
  80078b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800791:	e9 bb fc ff ff       	jmp    800451 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800796:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a4:	eb 01                	jmp    8007a7 <vprintfmt+0x379>
  8007a6:	4e                   	dec    %esi
  8007a7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ab:	75 f9                	jne    8007a6 <vprintfmt+0x378>
  8007ad:	e9 9f fc ff ff       	jmp    800451 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007b2:	83 c4 4c             	add    $0x4c,%esp
  8007b5:	5b                   	pop    %ebx
  8007b6:	5e                   	pop    %esi
  8007b7:	5f                   	pop    %edi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 28             	sub    $0x28,%esp
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d7:	85 c0                	test   %eax,%eax
  8007d9:	74 30                	je     80080b <vsnprintf+0x51>
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	7e 33                	jle    800812 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f4:	c7 04 24 ec 03 80 00 	movl   $0x8003ec,(%esp)
  8007fb:	e8 2e fc ff ff       	call   80042e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800800:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800803:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800809:	eb 0c                	jmp    800817 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800810:	eb 05                	jmp    800817 <vsnprintf+0x5d>
  800812:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800822:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800826:	8b 45 10             	mov    0x10(%ebp),%eax
  800829:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800830:	89 44 24 04          	mov    %eax,0x4(%esp)
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	89 04 24             	mov    %eax,(%esp)
  80083a:	e8 7b ff ff ff       	call   8007ba <vsnprintf>
	va_end(ap);

	return rc;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    
  800841:	00 00                	add    %al,(%eax)
	...

00800844 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
  80084f:	eb 01                	jmp    800852 <strlen+0xe>
		n++;
  800851:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800852:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800856:	75 f9                	jne    800851 <strlen+0xd>
		n++;
	return n;
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	eb 01                	jmp    80086b <strnlen+0x11>
		n++;
  80086a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086b:	39 d0                	cmp    %edx,%eax
  80086d:	74 06                	je     800875 <strnlen+0x1b>
  80086f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800873:	75 f5                	jne    80086a <strnlen+0x10>
		n++;
	return n;
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800881:	ba 00 00 00 00       	mov    $0x0,%edx
  800886:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800889:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80088c:	42                   	inc    %edx
  80088d:	84 c9                	test   %cl,%cl
  80088f:	75 f5                	jne    800886 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800891:	5b                   	pop    %ebx
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089e:	89 1c 24             	mov    %ebx,(%esp)
  8008a1:	e8 9e ff ff ff       	call   800844 <strlen>
	strcpy(dst + len, src);
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ad:	01 d8                	add    %ebx,%eax
  8008af:	89 04 24             	mov    %eax,(%esp)
  8008b2:	e8 c0 ff ff ff       	call   800877 <strcpy>
	return dst;
}
  8008b7:	89 d8                	mov    %ebx,%eax
  8008b9:	83 c4 08             	add    $0x8,%esp
  8008bc:	5b                   	pop    %ebx
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d2:	eb 0c                	jmp    8008e0 <strncpy+0x21>
		*dst++ = *src;
  8008d4:	8a 1a                	mov    (%edx),%bl
  8008d6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d9:	80 3a 01             	cmpb   $0x1,(%edx)
  8008dc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008df:	41                   	inc    %ecx
  8008e0:	39 f1                	cmp    %esi,%ecx
  8008e2:	75 f0                	jne    8008d4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f6:	85 d2                	test   %edx,%edx
  8008f8:	75 0a                	jne    800904 <strlcpy+0x1c>
  8008fa:	89 f0                	mov    %esi,%eax
  8008fc:	eb 1a                	jmp    800918 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008fe:	88 18                	mov    %bl,(%eax)
  800900:	40                   	inc    %eax
  800901:	41                   	inc    %ecx
  800902:	eb 02                	jmp    800906 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800904:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800906:	4a                   	dec    %edx
  800907:	74 0a                	je     800913 <strlcpy+0x2b>
  800909:	8a 19                	mov    (%ecx),%bl
  80090b:	84 db                	test   %bl,%bl
  80090d:	75 ef                	jne    8008fe <strlcpy+0x16>
  80090f:	89 c2                	mov    %eax,%edx
  800911:	eb 02                	jmp    800915 <strlcpy+0x2d>
  800913:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800915:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800918:	29 f0                	sub    %esi,%eax
}
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800927:	eb 02                	jmp    80092b <strcmp+0xd>
		p++, q++;
  800929:	41                   	inc    %ecx
  80092a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092b:	8a 01                	mov    (%ecx),%al
  80092d:	84 c0                	test   %al,%al
  80092f:	74 04                	je     800935 <strcmp+0x17>
  800931:	3a 02                	cmp    (%edx),%al
  800933:	74 f4                	je     800929 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800935:	0f b6 c0             	movzbl %al,%eax
  800938:	0f b6 12             	movzbl (%edx),%edx
  80093b:	29 d0                	sub    %edx,%eax
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	53                   	push   %ebx
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800949:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80094c:	eb 03                	jmp    800951 <strncmp+0x12>
		n--, p++, q++;
  80094e:	4a                   	dec    %edx
  80094f:	40                   	inc    %eax
  800950:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800951:	85 d2                	test   %edx,%edx
  800953:	74 14                	je     800969 <strncmp+0x2a>
  800955:	8a 18                	mov    (%eax),%bl
  800957:	84 db                	test   %bl,%bl
  800959:	74 04                	je     80095f <strncmp+0x20>
  80095b:	3a 19                	cmp    (%ecx),%bl
  80095d:	74 ef                	je     80094e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095f:	0f b6 00             	movzbl (%eax),%eax
  800962:	0f b6 11             	movzbl (%ecx),%edx
  800965:	29 d0                	sub    %edx,%eax
  800967:	eb 05                	jmp    80096e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800969:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096e:	5b                   	pop    %ebx
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097a:	eb 05                	jmp    800981 <strchr+0x10>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	74 0c                	je     80098c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800980:	40                   	inc    %eax
  800981:	8a 10                	mov    (%eax),%dl
  800983:	84 d2                	test   %dl,%dl
  800985:	75 f5                	jne    80097c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800997:	eb 05                	jmp    80099e <strfind+0x10>
		if (*s == c)
  800999:	38 ca                	cmp    %cl,%dl
  80099b:	74 07                	je     8009a4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80099d:	40                   	inc    %eax
  80099e:	8a 10                	mov    (%eax),%dl
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 f5                	jne    800999 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b5:	85 c9                	test   %ecx,%ecx
  8009b7:	74 30                	je     8009e9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bf:	75 25                	jne    8009e6 <memset+0x40>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 20                	jne    8009e6 <memset+0x40>
		c &= 0xFF;
  8009c6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c9:	89 d3                	mov    %edx,%ebx
  8009cb:	c1 e3 08             	shl    $0x8,%ebx
  8009ce:	89 d6                	mov    %edx,%esi
  8009d0:	c1 e6 18             	shl    $0x18,%esi
  8009d3:	89 d0                	mov    %edx,%eax
  8009d5:	c1 e0 10             	shl    $0x10,%eax
  8009d8:	09 f0                	or     %esi,%eax
  8009da:	09 d0                	or     %edx,%eax
  8009dc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009de:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e1:	fc                   	cld    
  8009e2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e4:	eb 03                	jmp    8009e9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e6:	fc                   	cld    
  8009e7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e9:	89 f8                	mov    %edi,%eax
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fe:	39 c6                	cmp    %eax,%esi
  800a00:	73 34                	jae    800a36 <memmove+0x46>
  800a02:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a05:	39 d0                	cmp    %edx,%eax
  800a07:	73 2d                	jae    800a36 <memmove+0x46>
		s += n;
		d += n;
  800a09:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0c:	f6 c2 03             	test   $0x3,%dl
  800a0f:	75 1b                	jne    800a2c <memmove+0x3c>
  800a11:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a17:	75 13                	jne    800a2c <memmove+0x3c>
  800a19:	f6 c1 03             	test   $0x3,%cl
  800a1c:	75 0e                	jne    800a2c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1e:	83 ef 04             	sub    $0x4,%edi
  800a21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a24:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a27:	fd                   	std    
  800a28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2a:	eb 07                	jmp    800a33 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2c:	4f                   	dec    %edi
  800a2d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a30:	fd                   	std    
  800a31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a33:	fc                   	cld    
  800a34:	eb 20                	jmp    800a56 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3c:	75 13                	jne    800a51 <memmove+0x61>
  800a3e:	a8 03                	test   $0x3,%al
  800a40:	75 0f                	jne    800a51 <memmove+0x61>
  800a42:	f6 c1 03             	test   $0x3,%cl
  800a45:	75 0a                	jne    800a51 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a47:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	fc                   	cld    
  800a4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4f:	eb 05                	jmp    800a56 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	fc                   	cld    
  800a54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a60:	8b 45 10             	mov    0x10(%ebp),%eax
  800a63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	89 04 24             	mov    %eax,(%esp)
  800a74:	e8 77 ff ff ff       	call   8009f0 <memmove>
}
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8f:	eb 16                	jmp    800aa7 <memcmp+0x2c>
		if (*s1 != *s2)
  800a91:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a94:	42                   	inc    %edx
  800a95:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a99:	38 c8                	cmp    %cl,%al
  800a9b:	74 0a                	je     800aa7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a9d:	0f b6 c0             	movzbl %al,%eax
  800aa0:	0f b6 c9             	movzbl %cl,%ecx
  800aa3:	29 c8                	sub    %ecx,%eax
  800aa5:	eb 09                	jmp    800ab0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	39 da                	cmp    %ebx,%edx
  800aa9:	75 e6                	jne    800a91 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac3:	eb 05                	jmp    800aca <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac5:	38 08                	cmp    %cl,(%eax)
  800ac7:	74 05                	je     800ace <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac9:	40                   	inc    %eax
  800aca:	39 d0                	cmp    %edx,%eax
  800acc:	72 f7                	jb     800ac5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adc:	eb 01                	jmp    800adf <strtol+0xf>
		s++;
  800ade:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adf:	8a 02                	mov    (%edx),%al
  800ae1:	3c 20                	cmp    $0x20,%al
  800ae3:	74 f9                	je     800ade <strtol+0xe>
  800ae5:	3c 09                	cmp    $0x9,%al
  800ae7:	74 f5                	je     800ade <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae9:	3c 2b                	cmp    $0x2b,%al
  800aeb:	75 08                	jne    800af5 <strtol+0x25>
		s++;
  800aed:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aee:	bf 00 00 00 00       	mov    $0x0,%edi
  800af3:	eb 13                	jmp    800b08 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af5:	3c 2d                	cmp    $0x2d,%al
  800af7:	75 0a                	jne    800b03 <strtol+0x33>
		s++, neg = 1;
  800af9:	8d 52 01             	lea    0x1(%edx),%edx
  800afc:	bf 01 00 00 00       	mov    $0x1,%edi
  800b01:	eb 05                	jmp    800b08 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b08:	85 db                	test   %ebx,%ebx
  800b0a:	74 05                	je     800b11 <strtol+0x41>
  800b0c:	83 fb 10             	cmp    $0x10,%ebx
  800b0f:	75 28                	jne    800b39 <strtol+0x69>
  800b11:	8a 02                	mov    (%edx),%al
  800b13:	3c 30                	cmp    $0x30,%al
  800b15:	75 10                	jne    800b27 <strtol+0x57>
  800b17:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b1b:	75 0a                	jne    800b27 <strtol+0x57>
		s += 2, base = 16;
  800b1d:	83 c2 02             	add    $0x2,%edx
  800b20:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b25:	eb 12                	jmp    800b39 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b27:	85 db                	test   %ebx,%ebx
  800b29:	75 0e                	jne    800b39 <strtol+0x69>
  800b2b:	3c 30                	cmp    $0x30,%al
  800b2d:	75 05                	jne    800b34 <strtol+0x64>
		s++, base = 8;
  800b2f:	42                   	inc    %edx
  800b30:	b3 08                	mov    $0x8,%bl
  800b32:	eb 05                	jmp    800b39 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b34:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b40:	8a 0a                	mov    (%edx),%cl
  800b42:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b45:	80 fb 09             	cmp    $0x9,%bl
  800b48:	77 08                	ja     800b52 <strtol+0x82>
			dig = *s - '0';
  800b4a:	0f be c9             	movsbl %cl,%ecx
  800b4d:	83 e9 30             	sub    $0x30,%ecx
  800b50:	eb 1e                	jmp    800b70 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b52:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b55:	80 fb 19             	cmp    $0x19,%bl
  800b58:	77 08                	ja     800b62 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b5a:	0f be c9             	movsbl %cl,%ecx
  800b5d:	83 e9 57             	sub    $0x57,%ecx
  800b60:	eb 0e                	jmp    800b70 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b62:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b65:	80 fb 19             	cmp    $0x19,%bl
  800b68:	77 12                	ja     800b7c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b6a:	0f be c9             	movsbl %cl,%ecx
  800b6d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b70:	39 f1                	cmp    %esi,%ecx
  800b72:	7d 0c                	jge    800b80 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b74:	42                   	inc    %edx
  800b75:	0f af c6             	imul   %esi,%eax
  800b78:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b7a:	eb c4                	jmp    800b40 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	89 c1                	mov    %eax,%ecx
  800b7e:	eb 02                	jmp    800b82 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b80:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b86:	74 05                	je     800b8d <strtol+0xbd>
		*endptr = (char *) s;
  800b88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b8b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b8d:	85 ff                	test   %edi,%edi
  800b8f:	74 04                	je     800b95 <strtol+0xc5>
  800b91:	89 c8                	mov    %ecx,%eax
  800b93:	f7 d8                	neg    %eax
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    
	...

00800b9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	89 c3                	mov    %eax,%ebx
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	89 c6                	mov    %eax,%esi
  800bb3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_cgetc>:

int
sys_cgetc(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	89 cb                	mov    %ecx,%ebx
  800bf1:	89 cf                	mov    %ecx,%edi
  800bf3:	89 ce                	mov    %ecx,%esi
  800bf5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 28                	jle    800c23 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c06:	00 
  800c07:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c16:	00 
  800c17:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800c1e:	e8 b1 f5 ff ff       	call   8001d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c23:	83 c4 2c             	add    $0x2c,%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	ba 00 00 00 00       	mov    $0x0,%edx
  800c36:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3b:	89 d1                	mov    %edx,%ecx
  800c3d:	89 d3                	mov    %edx,%ebx
  800c3f:	89 d7                	mov    %edx,%edi
  800c41:	89 d6                	mov    %edx,%esi
  800c43:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_yield>:

void
sys_yield(void)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	be 00 00 00 00       	mov    $0x0,%esi
  800c77:	b8 04 00 00 00       	mov    $0x4,%eax
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 f7                	mov    %esi,%edi
  800c87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 28                	jle    800cb5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c91:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c98:	00 
  800c99:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca8:	00 
  800ca9:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800cb0:	e8 1f f5 ff ff       	call   8001d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb5:	83 c4 2c             	add    $0x2c,%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 28                	jle    800d08 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ceb:	00 
  800cec:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800cf3:	00 
  800cf4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfb:	00 
  800cfc:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800d03:	e8 cc f4 ff ff       	call   8001d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d08:	83 c4 2c             	add    $0x2c,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 df                	mov    %ebx,%edi
  800d2b:	89 de                	mov    %ebx,%esi
  800d2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	7e 28                	jle    800d5b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d37:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800d46:	00 
  800d47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4e:	00 
  800d4f:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800d56:	e8 79 f4 ff ff       	call   8001d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	83 c4 2c             	add    $0x2c,%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 28                	jle    800dae <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d91:	00 
  800d92:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800d99:	00 
  800d9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da1:	00 
  800da2:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800da9:	e8 26 f4 ff ff       	call   8001d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dae:	83 c4 2c             	add    $0x2c,%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 28                	jle    800e01 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de4:	00 
  800de5:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800dec:	00 
  800ded:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df4:	00 
  800df5:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800dfc:	e8 d3 f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e01:	83 c4 2c             	add    $0x2c,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e17:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	89 df                	mov    %ebx,%edi
  800e24:	89 de                	mov    %ebx,%esi
  800e26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	7e 28                	jle    800e54 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e30:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e37:	00 
  800e38:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800e3f:	00 
  800e40:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e47:	00 
  800e48:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800e4f:	e8 80 f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e54:	83 c4 2c             	add    $0x2c,%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e62:	be 00 00 00 00       	mov    $0x0,%esi
  800e67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e6c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	57                   	push   %edi
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	89 cb                	mov    %ecx,%ebx
  800e97:	89 cf                	mov    %ecx,%edi
  800e99:	89 ce                	mov    %ecx,%esi
  800e9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	7e 28                	jle    800ec9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800eac:	00 
  800ead:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800ec4:	e8 0b f3 ff ff       	call   8001d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec9:	83 c4 2c             	add    $0x2c,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	57                   	push   %edi
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed7:	ba 00 00 00 00       	mov    $0x0,%edx
  800edc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ee1:	89 d1                	mov    %edx,%ecx
  800ee3:	89 d3                	mov    %edx,%ebx
  800ee5:	89 d7                	mov    %edx,%edi
  800ee7:	89 d6                	mov    %edx,%esi
  800ee9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	57                   	push   %edi
  800f15:	56                   	push   %esi
  800f16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1c:	b8 10 00 00 00       	mov    $0x10,%eax
  800f21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f24:	8b 55 08             	mov    0x8(%ebp),%edx
  800f27:	89 df                	mov    %ebx,%edi
  800f29:	89 de                	mov    %ebx,%esi
  800f2b:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    
	...

00800f34 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f3f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4d:	89 04 24             	mov    %eax,(%esp)
  800f50:	e8 df ff ff ff       	call   800f34 <fd2num>
  800f55:	c1 e0 0c             	shl    $0xc,%eax
  800f58:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	53                   	push   %ebx
  800f63:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f66:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f6b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f6d:	89 c2                	mov    %eax,%edx
  800f6f:	c1 ea 16             	shr    $0x16,%edx
  800f72:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f79:	f6 c2 01             	test   $0x1,%dl
  800f7c:	74 11                	je     800f8f <fd_alloc+0x30>
  800f7e:	89 c2                	mov    %eax,%edx
  800f80:	c1 ea 0c             	shr    $0xc,%edx
  800f83:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f8a:	f6 c2 01             	test   $0x1,%dl
  800f8d:	75 09                	jne    800f98 <fd_alloc+0x39>
			*fd_store = fd;
  800f8f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f91:	b8 00 00 00 00       	mov    $0x0,%eax
  800f96:	eb 17                	jmp    800faf <fd_alloc+0x50>
  800f98:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f9d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fa2:	75 c7                	jne    800f6b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fa4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800faa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800faf:	5b                   	pop    %ebx
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fb8:	83 f8 1f             	cmp    $0x1f,%eax
  800fbb:	77 36                	ja     800ff3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fbd:	c1 e0 0c             	shl    $0xc,%eax
  800fc0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fc5:	89 c2                	mov    %eax,%edx
  800fc7:	c1 ea 16             	shr    $0x16,%edx
  800fca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fd1:	f6 c2 01             	test   $0x1,%dl
  800fd4:	74 24                	je     800ffa <fd_lookup+0x48>
  800fd6:	89 c2                	mov    %eax,%edx
  800fd8:	c1 ea 0c             	shr    $0xc,%edx
  800fdb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe2:	f6 c2 01             	test   $0x1,%dl
  800fe5:	74 1a                	je     801001 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fe7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fea:	89 02                	mov    %eax,(%edx)
	return 0;
  800fec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff1:	eb 13                	jmp    801006 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ff3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff8:	eb 0c                	jmp    801006 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ffa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fff:	eb 05                	jmp    801006 <fd_lookup+0x54>
  801001:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	53                   	push   %ebx
  80100c:	83 ec 14             	sub    $0x14,%esp
  80100f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801012:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801015:	ba 00 00 00 00       	mov    $0x0,%edx
  80101a:	eb 0e                	jmp    80102a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80101c:	39 08                	cmp    %ecx,(%eax)
  80101e:	75 09                	jne    801029 <dev_lookup+0x21>
			*dev = devtab[i];
  801020:	89 03                	mov    %eax,(%ebx)
			return 0;
  801022:	b8 00 00 00 00       	mov    $0x0,%eax
  801027:	eb 33                	jmp    80105c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801029:	42                   	inc    %edx
  80102a:	8b 04 95 10 2b 80 00 	mov    0x802b10(,%edx,4),%eax
  801031:	85 c0                	test   %eax,%eax
  801033:	75 e7                	jne    80101c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801035:	a1 20 60 80 00       	mov    0x806020,%eax
  80103a:	8b 40 48             	mov    0x48(%eax),%eax
  80103d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801041:	89 44 24 04          	mov    %eax,0x4(%esp)
  801045:	c7 04 24 90 2a 80 00 	movl   $0x802a90,(%esp)
  80104c:	e8 7b f2 ff ff       	call   8002cc <cprintf>
	*dev = 0;
  801051:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801057:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80105c:	83 c4 14             	add    $0x14,%esp
  80105f:	5b                   	pop    %ebx
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	83 ec 30             	sub    $0x30,%esp
  80106a:	8b 75 08             	mov    0x8(%ebp),%esi
  80106d:	8a 45 0c             	mov    0xc(%ebp),%al
  801070:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801073:	89 34 24             	mov    %esi,(%esp)
  801076:	e8 b9 fe ff ff       	call   800f34 <fd2num>
  80107b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80107e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801082:	89 04 24             	mov    %eax,(%esp)
  801085:	e8 28 ff ff ff       	call   800fb2 <fd_lookup>
  80108a:	89 c3                	mov    %eax,%ebx
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 05                	js     801095 <fd_close+0x33>
	    || fd != fd2)
  801090:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801093:	74 0d                	je     8010a2 <fd_close+0x40>
		return (must_exist ? r : 0);
  801095:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801099:	75 46                	jne    8010e1 <fd_close+0x7f>
  80109b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a0:	eb 3f                	jmp    8010e1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a9:	8b 06                	mov    (%esi),%eax
  8010ab:	89 04 24             	mov    %eax,(%esp)
  8010ae:	e8 55 ff ff ff       	call   801008 <dev_lookup>
  8010b3:	89 c3                	mov    %eax,%ebx
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	78 18                	js     8010d1 <fd_close+0x6f>
		if (dev->dev_close)
  8010b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010bc:	8b 40 10             	mov    0x10(%eax),%eax
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	74 09                	je     8010cc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010c3:	89 34 24             	mov    %esi,(%esp)
  8010c6:	ff d0                	call   *%eax
  8010c8:	89 c3                	mov    %eax,%ebx
  8010ca:	eb 05                	jmp    8010d1 <fd_close+0x6f>
		else
			r = 0;
  8010cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010dc:	e8 2f fc ff ff       	call   800d10 <sys_page_unmap>
	return r;
}
  8010e1:	89 d8                	mov    %ebx,%eax
  8010e3:	83 c4 30             	add    $0x30,%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	89 04 24             	mov    %eax,(%esp)
  8010fd:	e8 b0 fe ff ff       	call   800fb2 <fd_lookup>
  801102:	85 c0                	test   %eax,%eax
  801104:	78 13                	js     801119 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801106:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80110d:	00 
  80110e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801111:	89 04 24             	mov    %eax,(%esp)
  801114:	e8 49 ff ff ff       	call   801062 <fd_close>
}
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <close_all>:

void
close_all(void)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	53                   	push   %ebx
  80111f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801122:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801127:	89 1c 24             	mov    %ebx,(%esp)
  80112a:	e8 bb ff ff ff       	call   8010ea <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80112f:	43                   	inc    %ebx
  801130:	83 fb 20             	cmp    $0x20,%ebx
  801133:	75 f2                	jne    801127 <close_all+0xc>
		close(i);
}
  801135:	83 c4 14             	add    $0x14,%esp
  801138:	5b                   	pop    %ebx
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	57                   	push   %edi
  80113f:	56                   	push   %esi
  801140:	53                   	push   %ebx
  801141:	83 ec 4c             	sub    $0x4c,%esp
  801144:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801147:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80114a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114e:	8b 45 08             	mov    0x8(%ebp),%eax
  801151:	89 04 24             	mov    %eax,(%esp)
  801154:	e8 59 fe ff ff       	call   800fb2 <fd_lookup>
  801159:	89 c3                	mov    %eax,%ebx
  80115b:	85 c0                	test   %eax,%eax
  80115d:	0f 88 e3 00 00 00    	js     801246 <dup+0x10b>
		return r;
	close(newfdnum);
  801163:	89 3c 24             	mov    %edi,(%esp)
  801166:	e8 7f ff ff ff       	call   8010ea <close>

	newfd = INDEX2FD(newfdnum);
  80116b:	89 fe                	mov    %edi,%esi
  80116d:	c1 e6 0c             	shl    $0xc,%esi
  801170:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801176:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801179:	89 04 24             	mov    %eax,(%esp)
  80117c:	e8 c3 fd ff ff       	call   800f44 <fd2data>
  801181:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801183:	89 34 24             	mov    %esi,(%esp)
  801186:	e8 b9 fd ff ff       	call   800f44 <fd2data>
  80118b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80118e:	89 d8                	mov    %ebx,%eax
  801190:	c1 e8 16             	shr    $0x16,%eax
  801193:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80119a:	a8 01                	test   $0x1,%al
  80119c:	74 46                	je     8011e4 <dup+0xa9>
  80119e:	89 d8                	mov    %ebx,%eax
  8011a0:	c1 e8 0c             	shr    $0xc,%eax
  8011a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011aa:	f6 c2 01             	test   $0x1,%dl
  8011ad:	74 35                	je     8011e4 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011cd:	00 
  8011ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d9:	e8 df fa ff ff       	call   800cbd <sys_page_map>
  8011de:	89 c3                	mov    %eax,%ebx
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	78 3b                	js     80121f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 0c             	shr    $0xc,%edx
  8011ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011fd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801201:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801208:	00 
  801209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801214:	e8 a4 fa ff ff       	call   800cbd <sys_page_map>
  801219:	89 c3                	mov    %eax,%ebx
  80121b:	85 c0                	test   %eax,%eax
  80121d:	79 25                	jns    801244 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80121f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801223:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122a:	e8 e1 fa ff ff       	call   800d10 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80122f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801232:	89 44 24 04          	mov    %eax,0x4(%esp)
  801236:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123d:	e8 ce fa ff ff       	call   800d10 <sys_page_unmap>
	return r;
  801242:	eb 02                	jmp    801246 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801244:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801246:	89 d8                	mov    %ebx,%eax
  801248:	83 c4 4c             	add    $0x4c,%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	53                   	push   %ebx
  801254:	83 ec 24             	sub    $0x24,%esp
  801257:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801261:	89 1c 24             	mov    %ebx,(%esp)
  801264:	e8 49 fd ff ff       	call   800fb2 <fd_lookup>
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 6d                	js     8012da <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801270:	89 44 24 04          	mov    %eax,0x4(%esp)
  801274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801277:	8b 00                	mov    (%eax),%eax
  801279:	89 04 24             	mov    %eax,(%esp)
  80127c:	e8 87 fd ff ff       	call   801008 <dev_lookup>
  801281:	85 c0                	test   %eax,%eax
  801283:	78 55                	js     8012da <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801288:	8b 50 08             	mov    0x8(%eax),%edx
  80128b:	83 e2 03             	and    $0x3,%edx
  80128e:	83 fa 01             	cmp    $0x1,%edx
  801291:	75 23                	jne    8012b6 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801293:	a1 20 60 80 00       	mov    0x806020,%eax
  801298:	8b 40 48             	mov    0x48(%eax),%eax
  80129b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80129f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a3:	c7 04 24 d4 2a 80 00 	movl   $0x802ad4,(%esp)
  8012aa:	e8 1d f0 ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  8012af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b4:	eb 24                	jmp    8012da <read+0x8a>
	}
	if (!dev->dev_read)
  8012b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b9:	8b 52 08             	mov    0x8(%edx),%edx
  8012bc:	85 d2                	test   %edx,%edx
  8012be:	74 15                	je     8012d5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012ce:	89 04 24             	mov    %eax,(%esp)
  8012d1:	ff d2                	call   *%edx
  8012d3:	eb 05                	jmp    8012da <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012da:	83 c4 24             	add    $0x24,%esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	57                   	push   %edi
  8012e4:	56                   	push   %esi
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 1c             	sub    $0x1c,%esp
  8012e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f4:	eb 23                	jmp    801319 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012f6:	89 f0                	mov    %esi,%eax
  8012f8:	29 d8                	sub    %ebx,%eax
  8012fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801301:	01 d8                	add    %ebx,%eax
  801303:	89 44 24 04          	mov    %eax,0x4(%esp)
  801307:	89 3c 24             	mov    %edi,(%esp)
  80130a:	e8 41 ff ff ff       	call   801250 <read>
		if (m < 0)
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 10                	js     801323 <readn+0x43>
			return m;
		if (m == 0)
  801313:	85 c0                	test   %eax,%eax
  801315:	74 0a                	je     801321 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801317:	01 c3                	add    %eax,%ebx
  801319:	39 f3                	cmp    %esi,%ebx
  80131b:	72 d9                	jb     8012f6 <readn+0x16>
  80131d:	89 d8                	mov    %ebx,%eax
  80131f:	eb 02                	jmp    801323 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801321:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801323:	83 c4 1c             	add    $0x1c,%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5f                   	pop    %edi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    

0080132b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	53                   	push   %ebx
  80132f:	83 ec 24             	sub    $0x24,%esp
  801332:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801335:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133c:	89 1c 24             	mov    %ebx,(%esp)
  80133f:	e8 6e fc ff ff       	call   800fb2 <fd_lookup>
  801344:	85 c0                	test   %eax,%eax
  801346:	78 68                	js     8013b0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801352:	8b 00                	mov    (%eax),%eax
  801354:	89 04 24             	mov    %eax,(%esp)
  801357:	e8 ac fc ff ff       	call   801008 <dev_lookup>
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 50                	js     8013b0 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801360:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801363:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801367:	75 23                	jne    80138c <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801369:	a1 20 60 80 00       	mov    0x806020,%eax
  80136e:	8b 40 48             	mov    0x48(%eax),%eax
  801371:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801375:	89 44 24 04          	mov    %eax,0x4(%esp)
  801379:	c7 04 24 f0 2a 80 00 	movl   $0x802af0,(%esp)
  801380:	e8 47 ef ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  801385:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138a:	eb 24                	jmp    8013b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80138c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80138f:	8b 52 0c             	mov    0xc(%edx),%edx
  801392:	85 d2                	test   %edx,%edx
  801394:	74 15                	je     8013ab <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801396:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801399:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013a4:	89 04 24             	mov    %eax,(%esp)
  8013a7:	ff d2                	call   *%edx
  8013a9:	eb 05                	jmp    8013b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013b0:	83 c4 24             	add    $0x24,%esp
  8013b3:	5b                   	pop    %ebx
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013bc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c6:	89 04 24             	mov    %eax,(%esp)
  8013c9:	e8 e4 fb ff ff       	call   800fb2 <fd_lookup>
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 0e                	js     8013e0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e0:	c9                   	leave  
  8013e1:	c3                   	ret    

008013e2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	53                   	push   %ebx
  8013e6:	83 ec 24             	sub    $0x24,%esp
  8013e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f3:	89 1c 24             	mov    %ebx,(%esp)
  8013f6:	e8 b7 fb ff ff       	call   800fb2 <fd_lookup>
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 61                	js     801460 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801402:	89 44 24 04          	mov    %eax,0x4(%esp)
  801406:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801409:	8b 00                	mov    (%eax),%eax
  80140b:	89 04 24             	mov    %eax,(%esp)
  80140e:	e8 f5 fb ff ff       	call   801008 <dev_lookup>
  801413:	85 c0                	test   %eax,%eax
  801415:	78 49                	js     801460 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801417:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80141e:	75 23                	jne    801443 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801420:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801425:	8b 40 48             	mov    0x48(%eax),%eax
  801428:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80142c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801430:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  801437:	e8 90 ee ff ff       	call   8002cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80143c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801441:	eb 1d                	jmp    801460 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801443:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801446:	8b 52 18             	mov    0x18(%edx),%edx
  801449:	85 d2                	test   %edx,%edx
  80144b:	74 0e                	je     80145b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80144d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801450:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801454:	89 04 24             	mov    %eax,(%esp)
  801457:	ff d2                	call   *%edx
  801459:	eb 05                	jmp    801460 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80145b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801460:	83 c4 24             	add    $0x24,%esp
  801463:	5b                   	pop    %ebx
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	53                   	push   %ebx
  80146a:	83 ec 24             	sub    $0x24,%esp
  80146d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801470:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801473:	89 44 24 04          	mov    %eax,0x4(%esp)
  801477:	8b 45 08             	mov    0x8(%ebp),%eax
  80147a:	89 04 24             	mov    %eax,(%esp)
  80147d:	e8 30 fb ff ff       	call   800fb2 <fd_lookup>
  801482:	85 c0                	test   %eax,%eax
  801484:	78 52                	js     8014d8 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801486:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801490:	8b 00                	mov    (%eax),%eax
  801492:	89 04 24             	mov    %eax,(%esp)
  801495:	e8 6e fb ff ff       	call   801008 <dev_lookup>
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 3a                	js     8014d8 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80149e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014a5:	74 2c                	je     8014d3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014b1:	00 00 00 
	stat->st_isdir = 0;
  8014b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014bb:	00 00 00 
	stat->st_dev = dev;
  8014be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014cb:	89 14 24             	mov    %edx,(%esp)
  8014ce:	ff 50 14             	call   *0x14(%eax)
  8014d1:	eb 05                	jmp    8014d8 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014d8:	83 c4 24             	add    $0x24,%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014ed:	00 
  8014ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f1:	89 04 24             	mov    %eax,(%esp)
  8014f4:	e8 2a 02 00 00       	call   801723 <open>
  8014f9:	89 c3                	mov    %eax,%ebx
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 1b                	js     80151a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801502:	89 44 24 04          	mov    %eax,0x4(%esp)
  801506:	89 1c 24             	mov    %ebx,(%esp)
  801509:	e8 58 ff ff ff       	call   801466 <fstat>
  80150e:	89 c6                	mov    %eax,%esi
	close(fd);
  801510:	89 1c 24             	mov    %ebx,(%esp)
  801513:	e8 d2 fb ff ff       	call   8010ea <close>
	return r;
  801518:	89 f3                	mov    %esi,%ebx
}
  80151a:	89 d8                	mov    %ebx,%eax
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	5b                   	pop    %ebx
  801520:	5e                   	pop    %esi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    
	...

00801524 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	56                   	push   %esi
  801528:	53                   	push   %ebx
  801529:	83 ec 10             	sub    $0x10,%esp
  80152c:	89 c3                	mov    %eax,%ebx
  80152e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801530:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801537:	75 11                	jne    80154a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801539:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801540:	e8 be 0e 00 00       	call   802403 <ipc_find_env>
  801545:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80154a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801551:	00 
  801552:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801559:	00 
  80155a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80155e:	a1 00 40 80 00       	mov    0x804000,%eax
  801563:	89 04 24             	mov    %eax,(%esp)
  801566:	e8 15 0e 00 00       	call   802380 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80156b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801572:	00 
  801573:	89 74 24 04          	mov    %esi,0x4(%esp)
  801577:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157e:	e8 8d 0d 00 00       	call   802310 <ipc_recv>
}
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	5d                   	pop    %ebp
  801589:	c3                   	ret    

0080158a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801590:	8b 45 08             	mov    0x8(%ebp),%eax
  801593:	8b 40 0c             	mov    0xc(%eax),%eax
  801596:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80159b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159e:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8015ad:	e8 72 ff ff ff       	call   801524 <fsipc>
}
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c0:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8015c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8015cf:	e8 50 ff ff ff       	call   801524 <fsipc>
}
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 14             	sub    $0x14,%esp
  8015dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e6:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8015f5:	e8 2a ff ff ff       	call   801524 <fsipc>
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 2b                	js     801629 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015fe:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801605:	00 
  801606:	89 1c 24             	mov    %ebx,(%esp)
  801609:	e8 69 f2 ff ff       	call   800877 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80160e:	a1 80 70 80 00       	mov    0x807080,%eax
  801613:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801619:	a1 84 70 80 00       	mov    0x807084,%eax
  80161e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801624:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801629:	83 c4 14             	add    $0x14,%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 18             	sub    $0x18,%esp
  801635:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801638:	8b 55 08             	mov    0x8(%ebp),%edx
  80163b:	8b 52 0c             	mov    0xc(%edx),%edx
  80163e:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  801644:	a3 04 70 80 00       	mov    %eax,0x807004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801649:	89 c2                	mov    %eax,%edx
  80164b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801650:	76 05                	jbe    801657 <devfile_write+0x28>
  801652:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801657:	89 54 24 08          	mov    %edx,0x8(%esp)
  80165b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801662:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  801669:	e8 ec f3 ff ff       	call   800a5a <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80166e:	ba 00 00 00 00       	mov    $0x0,%edx
  801673:	b8 04 00 00 00       	mov    $0x4,%eax
  801678:	e8 a7 fe ff ff       	call   801524 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 10             	sub    $0x10,%esp
  801687:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80168a:	8b 45 08             	mov    0x8(%ebp),%eax
  80168d:	8b 40 0c             	mov    0xc(%eax),%eax
  801690:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801695:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80169b:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a0:	b8 03 00 00 00       	mov    $0x3,%eax
  8016a5:	e8 7a fe ff ff       	call   801524 <fsipc>
  8016aa:	89 c3                	mov    %eax,%ebx
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 6a                	js     80171a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016b0:	39 c6                	cmp    %eax,%esi
  8016b2:	73 24                	jae    8016d8 <devfile_read+0x59>
  8016b4:	c7 44 24 0c 24 2b 80 	movl   $0x802b24,0xc(%esp)
  8016bb:	00 
  8016bc:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  8016c3:	00 
  8016c4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016cb:	00 
  8016cc:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  8016d3:	e8 fc ea ff ff       	call   8001d4 <_panic>
	assert(r <= PGSIZE);
  8016d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016dd:	7e 24                	jle    801703 <devfile_read+0x84>
  8016df:	c7 44 24 0c 4b 2b 80 	movl   $0x802b4b,0xc(%esp)
  8016e6:	00 
  8016e7:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  8016ee:	00 
  8016ef:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016f6:	00 
  8016f7:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  8016fe:	e8 d1 ea ff ff       	call   8001d4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801703:	89 44 24 08          	mov    %eax,0x8(%esp)
  801707:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80170e:	00 
  80170f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801712:	89 04 24             	mov    %eax,(%esp)
  801715:	e8 d6 f2 ff ff       	call   8009f0 <memmove>
	return r;
}
  80171a:	89 d8                	mov    %ebx,%eax
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	5b                   	pop    %ebx
  801720:	5e                   	pop    %esi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	56                   	push   %esi
  801727:	53                   	push   %ebx
  801728:	83 ec 20             	sub    $0x20,%esp
  80172b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80172e:	89 34 24             	mov    %esi,(%esp)
  801731:	e8 0e f1 ff ff       	call   800844 <strlen>
  801736:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80173b:	7f 60                	jg     80179d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80173d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801740:	89 04 24             	mov    %eax,(%esp)
  801743:	e8 17 f8 ff ff       	call   800f5f <fd_alloc>
  801748:	89 c3                	mov    %eax,%ebx
  80174a:	85 c0                	test   %eax,%eax
  80174c:	78 54                	js     8017a2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80174e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801752:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801759:	e8 19 f1 ff ff       	call   800877 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80175e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801761:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801766:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801769:	b8 01 00 00 00       	mov    $0x1,%eax
  80176e:	e8 b1 fd ff ff       	call   801524 <fsipc>
  801773:	89 c3                	mov    %eax,%ebx
  801775:	85 c0                	test   %eax,%eax
  801777:	79 15                	jns    80178e <open+0x6b>
		fd_close(fd, 0);
  801779:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801780:	00 
  801781:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801784:	89 04 24             	mov    %eax,(%esp)
  801787:	e8 d6 f8 ff ff       	call   801062 <fd_close>
		return r;
  80178c:	eb 14                	jmp    8017a2 <open+0x7f>
	}

	return fd2num(fd);
  80178e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 9b f7 ff ff       	call   800f34 <fd2num>
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	eb 05                	jmp    8017a2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80179d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017a2:	89 d8                	mov    %ebx,%eax
  8017a4:	83 c4 20             	add    $0x20,%esp
  8017a7:	5b                   	pop    %ebx
  8017a8:	5e                   	pop    %esi
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8017bb:	e8 64 fd ff ff       	call   801524 <fsipc>
}
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    
	...

008017c4 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 14             	sub    $0x14,%esp
  8017cb:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8017cd:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017d1:	7e 32                	jle    801805 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017d3:	8b 40 04             	mov    0x4(%eax),%eax
  8017d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017da:	8d 43 10             	lea    0x10(%ebx),%eax
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	8b 03                	mov    (%ebx),%eax
  8017e3:	89 04 24             	mov    %eax,(%esp)
  8017e6:	e8 40 fb ff ff       	call   80132b <write>
		if (result > 0)
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	7e 03                	jle    8017f2 <writebuf+0x2e>
			b->result += result;
  8017ef:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017f2:	39 43 04             	cmp    %eax,0x4(%ebx)
  8017f5:	74 0e                	je     801805 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8017f7:	89 c2                	mov    %eax,%edx
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	7e 05                	jle    801802 <writebuf+0x3e>
  8017fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801802:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801805:	83 c4 14             	add    $0x14,%esp
  801808:	5b                   	pop    %ebx
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <putch>:

static void
putch(int ch, void *thunk)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	53                   	push   %ebx
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801815:	8b 43 04             	mov    0x4(%ebx),%eax
  801818:	8b 55 08             	mov    0x8(%ebp),%edx
  80181b:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80181f:	40                   	inc    %eax
  801820:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801823:	3d 00 01 00 00       	cmp    $0x100,%eax
  801828:	75 0e                	jne    801838 <putch+0x2d>
		writebuf(b);
  80182a:	89 d8                	mov    %ebx,%eax
  80182c:	e8 93 ff ff ff       	call   8017c4 <writebuf>
		b->idx = 0;
  801831:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801838:	83 c4 04             	add    $0x4,%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801847:	8b 45 08             	mov    0x8(%ebp),%eax
  80184a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801850:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801857:	00 00 00 
	b.result = 0;
  80185a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801861:	00 00 00 
	b.error = 1;
  801864:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80186b:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80186e:	8b 45 10             	mov    0x10(%ebp),%eax
  801871:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	89 44 24 08          	mov    %eax,0x8(%esp)
  80187c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	c7 04 24 0b 18 80 00 	movl   $0x80180b,(%esp)
  80188d:	e8 9c eb ff ff       	call   80042e <vprintfmt>
	if (b.idx > 0)
  801892:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801899:	7e 0b                	jle    8018a6 <vfprintf+0x68>
		writebuf(&b);
  80189b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018a1:	e8 1e ff ff ff       	call   8017c4 <writebuf>

	return (b.result ? b.result : b.error);
  8018a6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	75 06                	jne    8018b6 <vfprintf+0x78>
  8018b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018be:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8018c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	89 04 24             	mov    %eax,(%esp)
  8018d2:	e8 67 ff ff ff       	call   80183e <vfprintf>
	va_end(ap);

	return cnt;
}
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <printf>:

int
printf(const char *fmt, ...)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018f4:	e8 45 ff ff ff       	call   80183e <vfprintf>
	va_end(ap);

	return cnt;
}
  8018f9:	c9                   	leave  
  8018fa:	c3                   	ret    
	...

008018fc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801902:	c7 44 24 04 57 2b 80 	movl   $0x802b57,0x4(%esp)
  801909:	00 
  80190a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190d:	89 04 24             	mov    %eax,(%esp)
  801910:	e8 62 ef ff ff       	call   800877 <strcpy>
	return 0;
}
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	53                   	push   %ebx
  801920:	83 ec 14             	sub    $0x14,%esp
  801923:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801926:	89 1c 24             	mov    %ebx,(%esp)
  801929:	e8 1a 0b 00 00       	call   802448 <pageref>
  80192e:	83 f8 01             	cmp    $0x1,%eax
  801931:	75 0d                	jne    801940 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801933:	8b 43 0c             	mov    0xc(%ebx),%eax
  801936:	89 04 24             	mov    %eax,(%esp)
  801939:	e8 1f 03 00 00       	call   801c5d <nsipc_close>
  80193e:	eb 05                	jmp    801945 <devsock_close+0x29>
	else
		return 0;
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801945:	83 c4 14             	add    $0x14,%esp
  801948:	5b                   	pop    %ebx
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801951:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801958:	00 
  801959:	8b 45 10             	mov    0x10(%ebp),%eax
  80195c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801960:	8b 45 0c             	mov    0xc(%ebp),%eax
  801963:	89 44 24 04          	mov    %eax,0x4(%esp)
  801967:	8b 45 08             	mov    0x8(%ebp),%eax
  80196a:	8b 40 0c             	mov    0xc(%eax),%eax
  80196d:	89 04 24             	mov    %eax,(%esp)
  801970:	e8 e3 03 00 00       	call   801d58 <nsipc_send>
}
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80197d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801984:	00 
  801985:	8b 45 10             	mov    0x10(%ebp),%eax
  801988:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801993:	8b 45 08             	mov    0x8(%ebp),%eax
  801996:	8b 40 0c             	mov    0xc(%eax),%eax
  801999:	89 04 24             	mov    %eax,(%esp)
  80199c:	e8 37 03 00 00       	call   801cd8 <nsipc_recv>
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 20             	sub    $0x20,%esp
  8019ab:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b0:	89 04 24             	mov    %eax,(%esp)
  8019b3:	e8 a7 f5 ff ff       	call   800f5f <fd_alloc>
  8019b8:	89 c3                	mov    %eax,%ebx
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 21                	js     8019df <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019be:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019c5:	00 
  8019c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d4:	e8 90 f2 ff ff       	call   800c69 <sys_page_alloc>
  8019d9:	89 c3                	mov    %eax,%ebx
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	79 0a                	jns    8019e9 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8019df:	89 34 24             	mov    %esi,(%esp)
  8019e2:	e8 76 02 00 00       	call   801c5d <nsipc_close>
		return r;
  8019e7:	eb 22                	jmp    801a0b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019e9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019fe:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a01:	89 04 24             	mov    %eax,(%esp)
  801a04:	e8 2b f5 ff ff       	call   800f34 <fd2num>
  801a09:	89 c3                	mov    %eax,%ebx
}
  801a0b:	89 d8                	mov    %ebx,%eax
  801a0d:	83 c4 20             	add    $0x20,%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    

00801a14 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a1a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a21:	89 04 24             	mov    %eax,(%esp)
  801a24:	e8 89 f5 ff ff       	call   800fb2 <fd_lookup>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 17                	js     801a44 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a30:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a36:	39 10                	cmp    %edx,(%eax)
  801a38:	75 05                	jne    801a3f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3d:	eb 05                	jmp    801a44 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a3f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4f:	e8 c0 ff ff ff       	call   801a14 <fd2sockid>
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 1f                	js     801a77 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a58:	8b 55 10             	mov    0x10(%ebp),%edx
  801a5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a62:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a66:	89 04 24             	mov    %eax,(%esp)
  801a69:	e8 38 01 00 00       	call   801ba6 <nsipc_accept>
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 05                	js     801a77 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801a72:	e8 2c ff ff ff       	call   8019a3 <alloc_sockfd>
}
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a82:	e8 8d ff ff ff       	call   801a14 <fd2sockid>
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 16                	js     801aa1 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801a8b:	8b 55 10             	mov    0x10(%ebp),%edx
  801a8e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a95:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a99:	89 04 24             	mov    %eax,(%esp)
  801a9c:	e8 5b 01 00 00       	call   801bfc <nsipc_bind>
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <shutdown>:

int
shutdown(int s, int how)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aac:	e8 63 ff ff ff       	call   801a14 <fd2sockid>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 0f                	js     801ac4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801abc:	89 04 24             	mov    %eax,(%esp)
  801abf:	e8 77 01 00 00       	call   801c3b <nsipc_shutdown>
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	e8 40 ff ff ff       	call   801a14 <fd2sockid>
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 16                	js     801aee <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801ad8:	8b 55 10             	mov    0x10(%ebp),%edx
  801adb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ae2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ae6:	89 04 24             	mov    %eax,(%esp)
  801ae9:	e8 89 01 00 00       	call   801c77 <nsipc_connect>
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <listen>:

int
listen(int s, int backlog)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af6:	8b 45 08             	mov    0x8(%ebp),%eax
  801af9:	e8 16 ff ff ff       	call   801a14 <fd2sockid>
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 0f                	js     801b11 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b05:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b09:	89 04 24             	mov    %eax,(%esp)
  801b0c:	e8 a5 01 00 00       	call   801cb6 <nsipc_listen>
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b19:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b27:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2a:	89 04 24             	mov    %eax,(%esp)
  801b2d:	e8 99 02 00 00       	call   801dcb <nsipc_socket>
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 05                	js     801b3b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801b36:	e8 68 fe ff ff       	call   8019a3 <alloc_sockfd>
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    
  801b3d:	00 00                	add    %al,(%eax)
	...

00801b40 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	53                   	push   %ebx
  801b44:	83 ec 14             	sub    $0x14,%esp
  801b47:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b49:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b50:	75 11                	jne    801b63 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b52:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b59:	e8 a5 08 00 00       	call   802403 <ipc_find_env>
  801b5e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b63:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b6a:	00 
  801b6b:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  801b72:	00 
  801b73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b77:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7c:	89 04 24             	mov    %eax,(%esp)
  801b7f:	e8 fc 07 00 00       	call   802380 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b84:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b8b:	00 
  801b8c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b93:	00 
  801b94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b9b:	e8 70 07 00 00       	call   802310 <ipc_recv>
}
  801ba0:	83 c4 14             	add    $0x14,%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5d                   	pop    %ebp
  801ba5:	c3                   	ret    

00801ba6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	83 ec 10             	sub    $0x10,%esp
  801bae:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bb9:	8b 06                	mov    (%esi),%eax
  801bbb:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bc0:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc5:	e8 76 ff ff ff       	call   801b40 <nsipc>
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	78 23                	js     801bf3 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bd0:	a1 10 80 80 00       	mov    0x808010,%eax
  801bd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd9:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801be0:	00 
  801be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be4:	89 04 24             	mov    %eax,(%esp)
  801be7:	e8 04 ee ff ff       	call   8009f0 <memmove>
		*addrlen = ret->ret_addrlen;
  801bec:	a1 10 80 80 00       	mov    0x808010,%eax
  801bf1:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801bf3:	89 d8                	mov    %ebx,%eax
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	5b                   	pop    %ebx
  801bf9:	5e                   	pop    %esi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	53                   	push   %ebx
  801c00:	83 ec 14             	sub    $0x14,%esp
  801c03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c06:	8b 45 08             	mov    0x8(%ebp),%eax
  801c09:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c19:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  801c20:	e8 cb ed ff ff       	call   8009f0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c25:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801c2b:	b8 02 00 00 00       	mov    $0x2,%eax
  801c30:	e8 0b ff ff ff       	call   801b40 <nsipc>
}
  801c35:	83 c4 14             	add    $0x14,%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
  801c44:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801c49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4c:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801c51:	b8 03 00 00 00       	mov    $0x3,%eax
  801c56:	e8 e5 fe ff ff       	call   801b40 <nsipc>
}
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <nsipc_close>:

int
nsipc_close(int s)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801c6b:	b8 04 00 00 00       	mov    $0x4,%eax
  801c70:	e8 cb fe ff ff       	call   801b40 <nsipc>
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 14             	sub    $0x14,%esp
  801c7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c94:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  801c9b:	e8 50 ed ff ff       	call   8009f0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ca0:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801ca6:	b8 05 00 00 00       	mov    $0x5,%eax
  801cab:	e8 90 fe ff ff       	call   801b40 <nsipc>
}
  801cb0:	83 c4 14             	add    $0x14,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    

00801cb6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbf:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc7:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801ccc:	b8 06 00 00 00       	mov    $0x6,%eax
  801cd1:	e8 6a fe ff ff       	call   801b40 <nsipc>
}
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	56                   	push   %esi
  801cdc:	53                   	push   %ebx
  801cdd:	83 ec 10             	sub    $0x10,%esp
  801ce0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801ceb:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801cf1:	8b 45 14             	mov    0x14(%ebp),%eax
  801cf4:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cf9:	b8 07 00 00 00       	mov    $0x7,%eax
  801cfe:	e8 3d fe ff ff       	call   801b40 <nsipc>
  801d03:	89 c3                	mov    %eax,%ebx
  801d05:	85 c0                	test   %eax,%eax
  801d07:	78 46                	js     801d4f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801d09:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d0e:	7f 04                	jg     801d14 <nsipc_recv+0x3c>
  801d10:	39 c6                	cmp    %eax,%esi
  801d12:	7d 24                	jge    801d38 <nsipc_recv+0x60>
  801d14:	c7 44 24 0c 63 2b 80 	movl   $0x802b63,0xc(%esp)
  801d1b:	00 
  801d1c:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  801d23:	00 
  801d24:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801d2b:	00 
  801d2c:	c7 04 24 78 2b 80 00 	movl   $0x802b78,(%esp)
  801d33:	e8 9c e4 ff ff       	call   8001d4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d3c:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801d43:	00 
  801d44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d47:	89 04 24             	mov    %eax,(%esp)
  801d4a:	e8 a1 ec ff ff       	call   8009f0 <memmove>
	}

	return r;
}
  801d4f:	89 d8                	mov    %ebx,%eax
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	53                   	push   %ebx
  801d5c:	83 ec 14             	sub    $0x14,%esp
  801d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d62:	8b 45 08             	mov    0x8(%ebp),%eax
  801d65:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801d6a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d70:	7e 24                	jle    801d96 <nsipc_send+0x3e>
  801d72:	c7 44 24 0c 84 2b 80 	movl   $0x802b84,0xc(%esp)
  801d79:	00 
  801d7a:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  801d81:	00 
  801d82:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801d89:	00 
  801d8a:	c7 04 24 78 2b 80 00 	movl   $0x802b78,(%esp)
  801d91:	e8 3e e4 ff ff       	call   8001d4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d96:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da1:	c7 04 24 0c 80 80 00 	movl   $0x80800c,(%esp)
  801da8:	e8 43 ec ff ff       	call   8009f0 <memmove>
	nsipcbuf.send.req_size = size;
  801dad:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801db3:	8b 45 14             	mov    0x14(%ebp),%eax
  801db6:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801dbb:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc0:	e8 7b fd ff ff       	call   801b40 <nsipc>
}
  801dc5:	83 c4 14             	add    $0x14,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    

00801dcb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddc:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801de1:	8b 45 10             	mov    0x10(%ebp),%eax
  801de4:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801de9:	b8 09 00 00 00       	mov    $0x9,%eax
  801dee:	e8 4d fd ff ff       	call   801b40 <nsipc>
}
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    
  801df5:	00 00                	add    %al,(%eax)
	...

00801df8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	56                   	push   %esi
  801dfc:	53                   	push   %ebx
  801dfd:	83 ec 10             	sub    $0x10,%esp
  801e00:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e03:	8b 45 08             	mov    0x8(%ebp),%eax
  801e06:	89 04 24             	mov    %eax,(%esp)
  801e09:	e8 36 f1 ff ff       	call   800f44 <fd2data>
  801e0e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e10:	c7 44 24 04 90 2b 80 	movl   $0x802b90,0x4(%esp)
  801e17:	00 
  801e18:	89 34 24             	mov    %esi,(%esp)
  801e1b:	e8 57 ea ff ff       	call   800877 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e20:	8b 43 04             	mov    0x4(%ebx),%eax
  801e23:	2b 03                	sub    (%ebx),%eax
  801e25:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e2b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e32:	00 00 00 
	stat->st_dev = &devpipe;
  801e35:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801e3c:	30 80 00 
	return 0;
}
  801e3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    

00801e4b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	53                   	push   %ebx
  801e4f:	83 ec 14             	sub    $0x14,%esp
  801e52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e60:	e8 ab ee ff ff       	call   800d10 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e65:	89 1c 24             	mov    %ebx,(%esp)
  801e68:	e8 d7 f0 ff ff       	call   800f44 <fd2data>
  801e6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e78:	e8 93 ee ff ff       	call   800d10 <sys_page_unmap>
}
  801e7d:	83 c4 14             	add    $0x14,%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    

00801e83 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	57                   	push   %edi
  801e87:	56                   	push   %esi
  801e88:	53                   	push   %ebx
  801e89:	83 ec 2c             	sub    $0x2c,%esp
  801e8c:	89 c7                	mov    %eax,%edi
  801e8e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e91:	a1 20 60 80 00       	mov    0x806020,%eax
  801e96:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e99:	89 3c 24             	mov    %edi,(%esp)
  801e9c:	e8 a7 05 00 00       	call   802448 <pageref>
  801ea1:	89 c6                	mov    %eax,%esi
  801ea3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ea6:	89 04 24             	mov    %eax,(%esp)
  801ea9:	e8 9a 05 00 00       	call   802448 <pageref>
  801eae:	39 c6                	cmp    %eax,%esi
  801eb0:	0f 94 c0             	sete   %al
  801eb3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801eb6:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801ebc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ebf:	39 cb                	cmp    %ecx,%ebx
  801ec1:	75 08                	jne    801ecb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ec3:	83 c4 2c             	add    $0x2c,%esp
  801ec6:	5b                   	pop    %ebx
  801ec7:	5e                   	pop    %esi
  801ec8:	5f                   	pop    %edi
  801ec9:	5d                   	pop    %ebp
  801eca:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ecb:	83 f8 01             	cmp    $0x1,%eax
  801ece:	75 c1                	jne    801e91 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ed0:	8b 42 58             	mov    0x58(%edx),%eax
  801ed3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801eda:	00 
  801edb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801edf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ee3:	c7 04 24 97 2b 80 00 	movl   $0x802b97,(%esp)
  801eea:	e8 dd e3 ff ff       	call   8002cc <cprintf>
  801eef:	eb a0                	jmp    801e91 <_pipeisclosed+0xe>

00801ef1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	57                   	push   %edi
  801ef5:	56                   	push   %esi
  801ef6:	53                   	push   %ebx
  801ef7:	83 ec 1c             	sub    $0x1c,%esp
  801efa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801efd:	89 34 24             	mov    %esi,(%esp)
  801f00:	e8 3f f0 ff ff       	call   800f44 <fd2data>
  801f05:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f07:	bf 00 00 00 00       	mov    $0x0,%edi
  801f0c:	eb 3c                	jmp    801f4a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f0e:	89 da                	mov    %ebx,%edx
  801f10:	89 f0                	mov    %esi,%eax
  801f12:	e8 6c ff ff ff       	call   801e83 <_pipeisclosed>
  801f17:	85 c0                	test   %eax,%eax
  801f19:	75 38                	jne    801f53 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f1b:	e8 2a ed ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f20:	8b 43 04             	mov    0x4(%ebx),%eax
  801f23:	8b 13                	mov    (%ebx),%edx
  801f25:	83 c2 20             	add    $0x20,%edx
  801f28:	39 d0                	cmp    %edx,%eax
  801f2a:	73 e2                	jae    801f0e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f2f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f32:	89 c2                	mov    %eax,%edx
  801f34:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f3a:	79 05                	jns    801f41 <devpipe_write+0x50>
  801f3c:	4a                   	dec    %edx
  801f3d:	83 ca e0             	or     $0xffffffe0,%edx
  801f40:	42                   	inc    %edx
  801f41:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f45:	40                   	inc    %eax
  801f46:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f49:	47                   	inc    %edi
  801f4a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f4d:	75 d1                	jne    801f20 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	eb 05                	jmp    801f58 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f58:	83 c4 1c             	add    $0x1c,%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5f                   	pop    %edi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	57                   	push   %edi
  801f64:	56                   	push   %esi
  801f65:	53                   	push   %ebx
  801f66:	83 ec 1c             	sub    $0x1c,%esp
  801f69:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f6c:	89 3c 24             	mov    %edi,(%esp)
  801f6f:	e8 d0 ef ff ff       	call   800f44 <fd2data>
  801f74:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f76:	be 00 00 00 00       	mov    $0x0,%esi
  801f7b:	eb 3a                	jmp    801fb7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f7d:	85 f6                	test   %esi,%esi
  801f7f:	74 04                	je     801f85 <devpipe_read+0x25>
				return i;
  801f81:	89 f0                	mov    %esi,%eax
  801f83:	eb 40                	jmp    801fc5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f85:	89 da                	mov    %ebx,%edx
  801f87:	89 f8                	mov    %edi,%eax
  801f89:	e8 f5 fe ff ff       	call   801e83 <_pipeisclosed>
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	75 2e                	jne    801fc0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f92:	e8 b3 ec ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f97:	8b 03                	mov    (%ebx),%eax
  801f99:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f9c:	74 df                	je     801f7d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f9e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801fa3:	79 05                	jns    801faa <devpipe_read+0x4a>
  801fa5:	48                   	dec    %eax
  801fa6:	83 c8 e0             	or     $0xffffffe0,%eax
  801fa9:	40                   	inc    %eax
  801faa:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801fae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801fb4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb6:	46                   	inc    %esi
  801fb7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fba:	75 db                	jne    801f97 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fbc:	89 f0                	mov    %esi,%eax
  801fbe:	eb 05                	jmp    801fc5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fc0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fc5:	83 c4 1c             	add    $0x1c,%esp
  801fc8:	5b                   	pop    %ebx
  801fc9:	5e                   	pop    %esi
  801fca:	5f                   	pop    %edi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	57                   	push   %edi
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 3c             	sub    $0x3c,%esp
  801fd6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fd9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fdc:	89 04 24             	mov    %eax,(%esp)
  801fdf:	e8 7b ef ff ff       	call   800f5f <fd_alloc>
  801fe4:	89 c3                	mov    %eax,%ebx
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	0f 88 45 01 00 00    	js     802133 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ff5:	00 
  801ff6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ff9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802004:	e8 60 ec ff ff       	call   800c69 <sys_page_alloc>
  802009:	89 c3                	mov    %eax,%ebx
  80200b:	85 c0                	test   %eax,%eax
  80200d:	0f 88 20 01 00 00    	js     802133 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802013:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802016:	89 04 24             	mov    %eax,(%esp)
  802019:	e8 41 ef ff ff       	call   800f5f <fd_alloc>
  80201e:	89 c3                	mov    %eax,%ebx
  802020:	85 c0                	test   %eax,%eax
  802022:	0f 88 f8 00 00 00    	js     802120 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802028:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80202f:	00 
  802030:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802033:	89 44 24 04          	mov    %eax,0x4(%esp)
  802037:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80203e:	e8 26 ec ff ff       	call   800c69 <sys_page_alloc>
  802043:	89 c3                	mov    %eax,%ebx
  802045:	85 c0                	test   %eax,%eax
  802047:	0f 88 d3 00 00 00    	js     802120 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80204d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802050:	89 04 24             	mov    %eax,(%esp)
  802053:	e8 ec ee ff ff       	call   800f44 <fd2data>
  802058:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802061:	00 
  802062:	89 44 24 04          	mov    %eax,0x4(%esp)
  802066:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80206d:	e8 f7 eb ff ff       	call   800c69 <sys_page_alloc>
  802072:	89 c3                	mov    %eax,%ebx
  802074:	85 c0                	test   %eax,%eax
  802076:	0f 88 91 00 00 00    	js     80210d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80207c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80207f:	89 04 24             	mov    %eax,(%esp)
  802082:	e8 bd ee ff ff       	call   800f44 <fd2data>
  802087:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80208e:	00 
  80208f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802093:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80209a:	00 
  80209b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a6:	e8 12 ec ff ff       	call   800cbd <sys_page_map>
  8020ab:	89 c3                	mov    %eax,%ebx
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	78 4c                	js     8020fd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020b1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ba:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020bf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020c6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020cf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020d4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020de:	89 04 24             	mov    %eax,(%esp)
  8020e1:	e8 4e ee ff ff       	call   800f34 <fd2num>
  8020e6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020eb:	89 04 24             	mov    %eax,(%esp)
  8020ee:	e8 41 ee ff ff       	call   800f34 <fd2num>
  8020f3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8020f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020fb:	eb 36                	jmp    802133 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8020fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  802101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802108:	e8 03 ec ff ff       	call   800d10 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80210d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802110:	89 44 24 04          	mov    %eax,0x4(%esp)
  802114:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80211b:	e8 f0 eb ff ff       	call   800d10 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802120:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802123:	89 44 24 04          	mov    %eax,0x4(%esp)
  802127:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80212e:	e8 dd eb ff ff       	call   800d10 <sys_page_unmap>
    err:
	return r;
}
  802133:	89 d8                	mov    %ebx,%eax
  802135:	83 c4 3c             	add    $0x3c,%esp
  802138:	5b                   	pop    %ebx
  802139:	5e                   	pop    %esi
  80213a:	5f                   	pop    %edi
  80213b:	5d                   	pop    %ebp
  80213c:	c3                   	ret    

0080213d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80213d:	55                   	push   %ebp
  80213e:	89 e5                	mov    %esp,%ebp
  802140:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802143:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80214a:	8b 45 08             	mov    0x8(%ebp),%eax
  80214d:	89 04 24             	mov    %eax,(%esp)
  802150:	e8 5d ee ff ff       	call   800fb2 <fd_lookup>
  802155:	85 c0                	test   %eax,%eax
  802157:	78 15                	js     80216e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802159:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215c:	89 04 24             	mov    %eax,(%esp)
  80215f:	e8 e0 ed ff ff       	call   800f44 <fd2data>
	return _pipeisclosed(fd, p);
  802164:	89 c2                	mov    %eax,%edx
  802166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802169:	e8 15 fd ff ff       	call   801e83 <_pipeisclosed>
}
  80216e:	c9                   	leave  
  80216f:	c3                   	ret    

00802170 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802173:	b8 00 00 00 00       	mov    $0x0,%eax
  802178:	5d                   	pop    %ebp
  802179:	c3                   	ret    

0080217a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802180:	c7 44 24 04 af 2b 80 	movl   $0x802baf,0x4(%esp)
  802187:	00 
  802188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80218b:	89 04 24             	mov    %eax,(%esp)
  80218e:	e8 e4 e6 ff ff       	call   800877 <strcpy>
	return 0;
}
  802193:	b8 00 00 00 00       	mov    $0x0,%eax
  802198:	c9                   	leave  
  802199:	c3                   	ret    

0080219a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	57                   	push   %edi
  80219e:	56                   	push   %esi
  80219f:	53                   	push   %ebx
  8021a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b1:	eb 30                	jmp    8021e3 <devcons_write+0x49>
		m = n - tot;
  8021b3:	8b 75 10             	mov    0x10(%ebp),%esi
  8021b6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8021b8:	83 fe 7f             	cmp    $0x7f,%esi
  8021bb:	76 05                	jbe    8021c2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8021bd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021c2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021c6:	03 45 0c             	add    0xc(%ebp),%eax
  8021c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021cd:	89 3c 24             	mov    %edi,(%esp)
  8021d0:	e8 1b e8 ff ff       	call   8009f0 <memmove>
		sys_cputs(buf, m);
  8021d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d9:	89 3c 24             	mov    %edi,(%esp)
  8021dc:	e8 bb e9 ff ff       	call   800b9c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021e1:	01 f3                	add    %esi,%ebx
  8021e3:	89 d8                	mov    %ebx,%eax
  8021e5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021e8:	72 c9                	jb     8021b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021ea:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8021fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021ff:	75 07                	jne    802208 <devcons_read+0x13>
  802201:	eb 25                	jmp    802228 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802203:	e8 42 ea ff ff       	call   800c4a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802208:	e8 ad e9 ff ff       	call   800bba <sys_cgetc>
  80220d:	85 c0                	test   %eax,%eax
  80220f:	74 f2                	je     802203 <devcons_read+0xe>
  802211:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802213:	85 c0                	test   %eax,%eax
  802215:	78 1d                	js     802234 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802217:	83 f8 04             	cmp    $0x4,%eax
  80221a:	74 13                	je     80222f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80221c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80221f:	88 10                	mov    %dl,(%eax)
	return 1;
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	eb 0c                	jmp    802234 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802228:	b8 00 00 00 00       	mov    $0x0,%eax
  80222d:	eb 05                	jmp    802234 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80222f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802234:	c9                   	leave  
  802235:	c3                   	ret    

00802236 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802236:	55                   	push   %ebp
  802237:	89 e5                	mov    %esp,%ebp
  802239:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80223c:	8b 45 08             	mov    0x8(%ebp),%eax
  80223f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802242:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802249:	00 
  80224a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80224d:	89 04 24             	mov    %eax,(%esp)
  802250:	e8 47 e9 ff ff       	call   800b9c <sys_cputs>
}
  802255:	c9                   	leave  
  802256:	c3                   	ret    

00802257 <getchar>:

int
getchar(void)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80225d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802264:	00 
  802265:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80226c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802273:	e8 d8 ef ff ff       	call   801250 <read>
	if (r < 0)
  802278:	85 c0                	test   %eax,%eax
  80227a:	78 0f                	js     80228b <getchar+0x34>
		return r;
	if (r < 1)
  80227c:	85 c0                	test   %eax,%eax
  80227e:	7e 06                	jle    802286 <getchar+0x2f>
		return -E_EOF;
	return c;
  802280:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802284:	eb 05                	jmp    80228b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802286:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80228b:	c9                   	leave  
  80228c:	c3                   	ret    

0080228d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80228d:	55                   	push   %ebp
  80228e:	89 e5                	mov    %esp,%ebp
  802290:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802293:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80229a:	8b 45 08             	mov    0x8(%ebp),%eax
  80229d:	89 04 24             	mov    %eax,(%esp)
  8022a0:	e8 0d ed ff ff       	call   800fb2 <fd_lookup>
  8022a5:	85 c0                	test   %eax,%eax
  8022a7:	78 11                	js     8022ba <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ac:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b2:	39 10                	cmp    %edx,(%eax)
  8022b4:	0f 94 c0             	sete   %al
  8022b7:	0f b6 c0             	movzbl %al,%eax
}
  8022ba:	c9                   	leave  
  8022bb:	c3                   	ret    

008022bc <opencons>:

int
opencons(void)
{
  8022bc:	55                   	push   %ebp
  8022bd:	89 e5                	mov    %esp,%ebp
  8022bf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c5:	89 04 24             	mov    %eax,(%esp)
  8022c8:	e8 92 ec ff ff       	call   800f5f <fd_alloc>
  8022cd:	85 c0                	test   %eax,%eax
  8022cf:	78 3c                	js     80230d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022d8:	00 
  8022d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e7:	e8 7d e9 ff ff       	call   800c69 <sys_page_alloc>
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	78 1d                	js     80230d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022f0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802305:	89 04 24             	mov    %eax,(%esp)
  802308:	e8 27 ec ff ff       	call   800f34 <fd2num>
}
  80230d:	c9                   	leave  
  80230e:	c3                   	ret    
	...

00802310 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	56                   	push   %esi
  802314:	53                   	push   %ebx
  802315:	83 ec 10             	sub    $0x10,%esp
  802318:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80231b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80231e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802321:	85 c0                	test   %eax,%eax
  802323:	74 0a                	je     80232f <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802325:	89 04 24             	mov    %eax,(%esp)
  802328:	e8 52 eb ff ff       	call   800e7f <sys_ipc_recv>
  80232d:	eb 0c                	jmp    80233b <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80232f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802336:	e8 44 eb ff ff       	call   800e7f <sys_ipc_recv>
	}
	if (r < 0)
  80233b:	85 c0                	test   %eax,%eax
  80233d:	79 16                	jns    802355 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80233f:	85 db                	test   %ebx,%ebx
  802341:	74 06                	je     802349 <ipc_recv+0x39>
  802343:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802349:	85 f6                	test   %esi,%esi
  80234b:	74 2c                	je     802379 <ipc_recv+0x69>
  80234d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802353:	eb 24                	jmp    802379 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802355:	85 db                	test   %ebx,%ebx
  802357:	74 0a                	je     802363 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802359:	a1 20 60 80 00       	mov    0x806020,%eax
  80235e:	8b 40 74             	mov    0x74(%eax),%eax
  802361:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802363:	85 f6                	test   %esi,%esi
  802365:	74 0a                	je     802371 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802367:	a1 20 60 80 00       	mov    0x806020,%eax
  80236c:	8b 40 78             	mov    0x78(%eax),%eax
  80236f:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802371:	a1 20 60 80 00       	mov    0x806020,%eax
  802376:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802379:	83 c4 10             	add    $0x10,%esp
  80237c:	5b                   	pop    %ebx
  80237d:	5e                   	pop    %esi
  80237e:	5d                   	pop    %ebp
  80237f:	c3                   	ret    

00802380 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	57                   	push   %edi
  802384:	56                   	push   %esi
  802385:	53                   	push   %ebx
  802386:	83 ec 1c             	sub    $0x1c,%esp
  802389:	8b 75 08             	mov    0x8(%ebp),%esi
  80238c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80238f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802392:	85 db                	test   %ebx,%ebx
  802394:	74 19                	je     8023af <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802396:	8b 45 14             	mov    0x14(%ebp),%eax
  802399:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80239d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023a5:	89 34 24             	mov    %esi,(%esp)
  8023a8:	e8 af ea ff ff       	call   800e5c <sys_ipc_try_send>
  8023ad:	eb 1c                	jmp    8023cb <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8023af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8023b6:	00 
  8023b7:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8023be:	ee 
  8023bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023c3:	89 34 24             	mov    %esi,(%esp)
  8023c6:	e8 91 ea ff ff       	call   800e5c <sys_ipc_try_send>
		}
		if (r == 0)
  8023cb:	85 c0                	test   %eax,%eax
  8023cd:	74 2c                	je     8023fb <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8023cf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023d2:	74 20                	je     8023f4 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8023d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d8:	c7 44 24 08 bb 2b 80 	movl   $0x802bbb,0x8(%esp)
  8023df:	00 
  8023e0:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8023e7:	00 
  8023e8:	c7 04 24 ce 2b 80 00 	movl   $0x802bce,(%esp)
  8023ef:	e8 e0 dd ff ff       	call   8001d4 <_panic>
		}
		sys_yield();
  8023f4:	e8 51 e8 ff ff       	call   800c4a <sys_yield>
	}
  8023f9:	eb 97                	jmp    802392 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8023fb:	83 c4 1c             	add    $0x1c,%esp
  8023fe:	5b                   	pop    %ebx
  8023ff:	5e                   	pop    %esi
  802400:	5f                   	pop    %edi
  802401:	5d                   	pop    %ebp
  802402:	c3                   	ret    

00802403 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802403:	55                   	push   %ebp
  802404:	89 e5                	mov    %esp,%ebp
  802406:	53                   	push   %ebx
  802407:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80240a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80240f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802416:	89 c2                	mov    %eax,%edx
  802418:	c1 e2 07             	shl    $0x7,%edx
  80241b:	29 ca                	sub    %ecx,%edx
  80241d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802423:	8b 52 50             	mov    0x50(%edx),%edx
  802426:	39 da                	cmp    %ebx,%edx
  802428:	75 0f                	jne    802439 <ipc_find_env+0x36>
			return envs[i].env_id;
  80242a:	c1 e0 07             	shl    $0x7,%eax
  80242d:	29 c8                	sub    %ecx,%eax
  80242f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802434:	8b 40 40             	mov    0x40(%eax),%eax
  802437:	eb 0c                	jmp    802445 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802439:	40                   	inc    %eax
  80243a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80243f:	75 ce                	jne    80240f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802441:	66 b8 00 00          	mov    $0x0,%ax
}
  802445:	5b                   	pop    %ebx
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    

00802448 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802448:	55                   	push   %ebp
  802449:	89 e5                	mov    %esp,%ebp
  80244b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80244e:	89 c2                	mov    %eax,%edx
  802450:	c1 ea 16             	shr    $0x16,%edx
  802453:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80245a:	f6 c2 01             	test   $0x1,%dl
  80245d:	74 1e                	je     80247d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80245f:	c1 e8 0c             	shr    $0xc,%eax
  802462:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802469:	a8 01                	test   $0x1,%al
  80246b:	74 17                	je     802484 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80246d:	c1 e8 0c             	shr    $0xc,%eax
  802470:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802477:	ef 
  802478:	0f b7 c0             	movzwl %ax,%eax
  80247b:	eb 0c                	jmp    802489 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80247d:	b8 00 00 00 00       	mov    $0x0,%eax
  802482:	eb 05                	jmp    802489 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802484:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802489:	5d                   	pop    %ebp
  80248a:	c3                   	ret    
	...

0080248c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80248c:	55                   	push   %ebp
  80248d:	57                   	push   %edi
  80248e:	56                   	push   %esi
  80248f:	83 ec 10             	sub    $0x10,%esp
  802492:	8b 74 24 20          	mov    0x20(%esp),%esi
  802496:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80249a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80249e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8024a2:	89 cd                	mov    %ecx,%ebp
  8024a4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024a8:	85 c0                	test   %eax,%eax
  8024aa:	75 2c                	jne    8024d8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8024ac:	39 f9                	cmp    %edi,%ecx
  8024ae:	77 68                	ja     802518 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024b0:	85 c9                	test   %ecx,%ecx
  8024b2:	75 0b                	jne    8024bf <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b9:	31 d2                	xor    %edx,%edx
  8024bb:	f7 f1                	div    %ecx
  8024bd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024bf:	31 d2                	xor    %edx,%edx
  8024c1:	89 f8                	mov    %edi,%eax
  8024c3:	f7 f1                	div    %ecx
  8024c5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024c7:	89 f0                	mov    %esi,%eax
  8024c9:	f7 f1                	div    %ecx
  8024cb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024cd:	89 f0                	mov    %esi,%eax
  8024cf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024d1:	83 c4 10             	add    $0x10,%esp
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024d8:	39 f8                	cmp    %edi,%eax
  8024da:	77 2c                	ja     802508 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024dc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8024df:	83 f6 1f             	xor    $0x1f,%esi
  8024e2:	75 4c                	jne    802530 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024e4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024e6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024eb:	72 0a                	jb     8024f7 <__udivdi3+0x6b>
  8024ed:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8024f1:	0f 87 ad 00 00 00    	ja     8025a4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024f7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024fc:	89 f0                	mov    %esi,%eax
  8024fe:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802500:	83 c4 10             	add    $0x10,%esp
  802503:	5e                   	pop    %esi
  802504:	5f                   	pop    %edi
  802505:	5d                   	pop    %ebp
  802506:	c3                   	ret    
  802507:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802508:	31 ff                	xor    %edi,%edi
  80250a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80250c:	89 f0                	mov    %esi,%eax
  80250e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802510:	83 c4 10             	add    $0x10,%esp
  802513:	5e                   	pop    %esi
  802514:	5f                   	pop    %edi
  802515:	5d                   	pop    %ebp
  802516:	c3                   	ret    
  802517:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802518:	89 fa                	mov    %edi,%edx
  80251a:	89 f0                	mov    %esi,%eax
  80251c:	f7 f1                	div    %ecx
  80251e:	89 c6                	mov    %eax,%esi
  802520:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802522:	89 f0                	mov    %esi,%eax
  802524:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802526:	83 c4 10             	add    $0x10,%esp
  802529:	5e                   	pop    %esi
  80252a:	5f                   	pop    %edi
  80252b:	5d                   	pop    %ebp
  80252c:	c3                   	ret    
  80252d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802530:	89 f1                	mov    %esi,%ecx
  802532:	d3 e0                	shl    %cl,%eax
  802534:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802538:	b8 20 00 00 00       	mov    $0x20,%eax
  80253d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80253f:	89 ea                	mov    %ebp,%edx
  802541:	88 c1                	mov    %al,%cl
  802543:	d3 ea                	shr    %cl,%edx
  802545:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802549:	09 ca                	or     %ecx,%edx
  80254b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80254f:	89 f1                	mov    %esi,%ecx
  802551:	d3 e5                	shl    %cl,%ebp
  802553:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802557:	89 fd                	mov    %edi,%ebp
  802559:	88 c1                	mov    %al,%cl
  80255b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80255d:	89 fa                	mov    %edi,%edx
  80255f:	89 f1                	mov    %esi,%ecx
  802561:	d3 e2                	shl    %cl,%edx
  802563:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802567:	88 c1                	mov    %al,%cl
  802569:	d3 ef                	shr    %cl,%edi
  80256b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80256d:	89 f8                	mov    %edi,%eax
  80256f:	89 ea                	mov    %ebp,%edx
  802571:	f7 74 24 08          	divl   0x8(%esp)
  802575:	89 d1                	mov    %edx,%ecx
  802577:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802579:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80257d:	39 d1                	cmp    %edx,%ecx
  80257f:	72 17                	jb     802598 <__udivdi3+0x10c>
  802581:	74 09                	je     80258c <__udivdi3+0x100>
  802583:	89 fe                	mov    %edi,%esi
  802585:	31 ff                	xor    %edi,%edi
  802587:	e9 41 ff ff ff       	jmp    8024cd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80258c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802590:	89 f1                	mov    %esi,%ecx
  802592:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802594:	39 c2                	cmp    %eax,%edx
  802596:	73 eb                	jae    802583 <__udivdi3+0xf7>
		{
		  q0--;
  802598:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80259b:	31 ff                	xor    %edi,%edi
  80259d:	e9 2b ff ff ff       	jmp    8024cd <__udivdi3+0x41>
  8025a2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025a4:	31 f6                	xor    %esi,%esi
  8025a6:	e9 22 ff ff ff       	jmp    8024cd <__udivdi3+0x41>
	...

008025ac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8025ac:	55                   	push   %ebp
  8025ad:	57                   	push   %edi
  8025ae:	56                   	push   %esi
  8025af:	83 ec 20             	sub    $0x20,%esp
  8025b2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025b6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025ba:	89 44 24 14          	mov    %eax,0x14(%esp)
  8025be:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8025c2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025c6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8025ca:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8025cc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025ce:	85 ed                	test   %ebp,%ebp
  8025d0:	75 16                	jne    8025e8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8025d2:	39 f1                	cmp    %esi,%ecx
  8025d4:	0f 86 a6 00 00 00    	jbe    802680 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025da:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8025dc:	89 d0                	mov    %edx,%eax
  8025de:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025e0:	83 c4 20             	add    $0x20,%esp
  8025e3:	5e                   	pop    %esi
  8025e4:	5f                   	pop    %edi
  8025e5:	5d                   	pop    %ebp
  8025e6:	c3                   	ret    
  8025e7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025e8:	39 f5                	cmp    %esi,%ebp
  8025ea:	0f 87 ac 00 00 00    	ja     80269c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025f0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8025f3:	83 f0 1f             	xor    $0x1f,%eax
  8025f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025fa:	0f 84 a8 00 00 00    	je     8026a8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802600:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802604:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802606:	bf 20 00 00 00       	mov    $0x20,%edi
  80260b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80260f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802613:	89 f9                	mov    %edi,%ecx
  802615:	d3 e8                	shr    %cl,%eax
  802617:	09 e8                	or     %ebp,%eax
  802619:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80261d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802621:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802625:	d3 e0                	shl    %cl,%eax
  802627:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80262b:	89 f2                	mov    %esi,%edx
  80262d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80262f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802633:	d3 e0                	shl    %cl,%eax
  802635:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802639:	8b 44 24 14          	mov    0x14(%esp),%eax
  80263d:	89 f9                	mov    %edi,%ecx
  80263f:	d3 e8                	shr    %cl,%eax
  802641:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802643:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802645:	89 f2                	mov    %esi,%edx
  802647:	f7 74 24 18          	divl   0x18(%esp)
  80264b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80264d:	f7 64 24 0c          	mull   0xc(%esp)
  802651:	89 c5                	mov    %eax,%ebp
  802653:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802655:	39 d6                	cmp    %edx,%esi
  802657:	72 67                	jb     8026c0 <__umoddi3+0x114>
  802659:	74 75                	je     8026d0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80265b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80265f:	29 e8                	sub    %ebp,%eax
  802661:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802663:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 f2                	mov    %esi,%edx
  80266b:	89 f9                	mov    %edi,%ecx
  80266d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80266f:	09 d0                	or     %edx,%eax
  802671:	89 f2                	mov    %esi,%edx
  802673:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802677:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802679:	83 c4 20             	add    $0x20,%esp
  80267c:	5e                   	pop    %esi
  80267d:	5f                   	pop    %edi
  80267e:	5d                   	pop    %ebp
  80267f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802680:	85 c9                	test   %ecx,%ecx
  802682:	75 0b                	jne    80268f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802684:	b8 01 00 00 00       	mov    $0x1,%eax
  802689:	31 d2                	xor    %edx,%edx
  80268b:	f7 f1                	div    %ecx
  80268d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80268f:	89 f0                	mov    %esi,%eax
  802691:	31 d2                	xor    %edx,%edx
  802693:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802695:	89 f8                	mov    %edi,%eax
  802697:	e9 3e ff ff ff       	jmp    8025da <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80269c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80269e:	83 c4 20             	add    $0x20,%esp
  8026a1:	5e                   	pop    %esi
  8026a2:	5f                   	pop    %edi
  8026a3:	5d                   	pop    %ebp
  8026a4:	c3                   	ret    
  8026a5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026a8:	39 f5                	cmp    %esi,%ebp
  8026aa:	72 04                	jb     8026b0 <__umoddi3+0x104>
  8026ac:	39 f9                	cmp    %edi,%ecx
  8026ae:	77 06                	ja     8026b6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8026b0:	89 f2                	mov    %esi,%edx
  8026b2:	29 cf                	sub    %ecx,%edi
  8026b4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8026b6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026b8:	83 c4 20             	add    $0x20,%esp
  8026bb:	5e                   	pop    %esi
  8026bc:	5f                   	pop    %edi
  8026bd:	5d                   	pop    %ebp
  8026be:	c3                   	ret    
  8026bf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026c0:	89 d1                	mov    %edx,%ecx
  8026c2:	89 c5                	mov    %eax,%ebp
  8026c4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8026c8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8026cc:	eb 8d                	jmp    80265b <__umoddi3+0xaf>
  8026ce:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026d0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8026d4:	72 ea                	jb     8026c0 <__umoddi3+0x114>
  8026d6:	89 f1                	mov    %esi,%ecx
  8026d8:	eb 81                	jmp    80265b <__umoddi3+0xaf>
