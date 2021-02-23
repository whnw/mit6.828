
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 8b 01 00 00       	call   8001bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	strcpy(VA, msg2);
  80003a:	a1 00 40 80 00       	mov    0x804000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80004a:	e8 80 08 00 00       	call   8008cf <strcpy>
	exit();
  80004f:	e8 bc 01 00 00       	call   800210 <exit>
}
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	53                   	push   %ebx
  80005a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (argc != 0)
  80005d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800061:	74 05                	je     800068 <umain+0x12>
		childofspawn();
  800063:	e8 cc ff ff ff       	call   800034 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800068:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80006f:	00 
  800070:	c7 44 24 04 00 00 00 	movl   $0xa0000000,0x4(%esp)
  800077:	a0 
  800078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007f:	e8 3d 0c 00 00       	call   800cc1 <sys_page_alloc>
  800084:	85 c0                	test   %eax,%eax
  800086:	79 20                	jns    8000a8 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800088:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008c:	c7 44 24 08 2c 31 80 	movl   $0x80312c,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009b:	00 
  80009c:	c7 04 24 3f 31 80 00 	movl   $0x80313f,(%esp)
  8000a3:	e8 84 01 00 00       	call   80022c <_panic>

	// check fork
	if ((r = fork()) < 0)
  8000a8:	e8 b6 0f 00 00       	call   801063 <fork>
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	79 20                	jns    8000d3 <umain+0x7d>
		panic("fork: %e", r);
  8000b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b7:	c7 44 24 08 85 35 80 	movl   $0x803585,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 3f 31 80 00 	movl   $0x80313f,(%esp)
  8000ce:	e8 59 01 00 00       	call   80022c <_panic>
	if (r == 0) {
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	75 1a                	jne    8000f1 <umain+0x9b>
		strcpy(VA, msg);
  8000d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e7:	e8 e3 07 00 00       	call   8008cf <strcpy>
		exit();
  8000ec:	e8 1f 01 00 00       	call   800210 <exit>
	}
	wait(r);
  8000f1:	89 1c 24             	mov    %ebx,(%esp)
  8000f4:	e8 c3 29 00 00       	call   802abc <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800109:	e8 68 08 00 00       	call   800976 <strcmp>
  80010e:	85 c0                	test   %eax,%eax
  800110:	75 07                	jne    800119 <umain+0xc3>
  800112:	b8 20 31 80 00       	mov    $0x803120,%eax
  800117:	eb 05                	jmp    80011e <umain+0xc8>
  800119:	b8 26 31 80 00       	mov    $0x803126,%eax
  80011e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800122:	c7 04 24 53 31 80 00 	movl   $0x803153,(%esp)
  800129:	e8 f6 01 00 00       	call   800324 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800135:	00 
  800136:	c7 44 24 08 6e 31 80 	movl   $0x80316e,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 73 31 80 	movl   $0x803173,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 72 31 80 00 	movl   $0x803172,(%esp)
  80014d:	e8 86 20 00 00       	call   8021d8 <spawnl>
  800152:	85 c0                	test   %eax,%eax
  800154:	79 20                	jns    800176 <umain+0x120>
		panic("spawn: %e", r);
  800156:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015a:	c7 44 24 08 80 31 80 	movl   $0x803180,0x8(%esp)
  800161:	00 
  800162:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800169:	00 
  80016a:	c7 04 24 3f 31 80 00 	movl   $0x80313f,(%esp)
  800171:	e8 b6 00 00 00       	call   80022c <_panic>
	wait(r);
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 3e 29 00 00       	call   802abc <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017e:	a1 00 40 80 00       	mov    0x804000,%eax
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018e:	e8 e3 07 00 00       	call   800976 <strcmp>
  800193:	85 c0                	test   %eax,%eax
  800195:	75 07                	jne    80019e <umain+0x148>
  800197:	b8 20 31 80 00       	mov    $0x803120,%eax
  80019c:	eb 05                	jmp    8001a3 <umain+0x14d>
  80019e:	b8 26 31 80 00       	mov    $0x803126,%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	c7 04 24 8a 31 80 00 	movl   $0x80318a,(%esp)
  8001ae:	e8 71 01 00 00       	call   800324 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001b3:	cc                   	int3   

	breakpoint();
}
  8001b4:	83 c4 14             	add    $0x14,%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5d                   	pop    %ebp
  8001b9:	c3                   	ret    
	...

008001bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 10             	sub    $0x10,%esp
  8001c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ca:	e8 b4 0a 00 00       	call   800c83 <sys_getenvid>
  8001cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001db:	c1 e0 07             	shl    $0x7,%eax
  8001de:	29 d0                	sub    %edx,%eax
  8001e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e5:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ea:	85 f6                	test   %esi,%esi
  8001ec:	7e 07                	jle    8001f5 <libmain+0x39>
		binaryname = argv[0];
  8001ee:	8b 03                	mov    (%ebx),%eax
  8001f0:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f9:	89 34 24             	mov    %esi,(%esp)
  8001fc:	e8 55 fe ff ff       	call   800056 <umain>

	// exit gracefully
	exit();
  800201:	e8 0a 00 00 00       	call   800210 <exit>
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    
  80020d:	00 00                	add    %al,(%eax)
	...

00800210 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800216:	e8 14 13 00 00       	call   80152f <close_all>
	sys_env_destroy(0);
  80021b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800222:	e8 0a 0a 00 00       	call   800c31 <sys_env_destroy>
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    
  800229:	00 00                	add    %al,(%eax)
	...

0080022c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800234:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800237:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80023d:	e8 41 0a 00 00       	call   800c83 <sys_getenvid>
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 54 24 10          	mov    %edx,0x10(%esp)
  800249:	8b 55 08             	mov    0x8(%ebp),%edx
  80024c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800250:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	c7 04 24 d0 31 80 00 	movl   $0x8031d0,(%esp)
  80025f:	e8 c0 00 00 00       	call   800324 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800264:	89 74 24 04          	mov    %esi,0x4(%esp)
  800268:	8b 45 10             	mov    0x10(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 50 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  800273:	c7 04 24 69 37 80 00 	movl   $0x803769,(%esp)
  80027a:	e8 a5 00 00 00       	call   800324 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027f:	cc                   	int3   
  800280:	eb fd                	jmp    80027f <_panic+0x53>
	...

00800284 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	53                   	push   %ebx
  800288:	83 ec 14             	sub    $0x14,%esp
  80028b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028e:	8b 03                	mov    (%ebx),%eax
  800290:	8b 55 08             	mov    0x8(%ebp),%edx
  800293:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800297:	40                   	inc    %eax
  800298:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029f:	75 19                	jne    8002ba <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002a1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002a8:	00 
  8002a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	e8 40 09 00 00       	call   800bf4 <sys_cputs>
		b->idx = 0;
  8002b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002ba:	ff 43 04             	incl   0x4(%ebx)
}
  8002bd:	83 c4 14             	add    $0x14,%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	c7 04 24 84 02 80 00 	movl   $0x800284,(%esp)
  8002ff:	e8 82 01 00 00       	call   800486 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800304:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80030a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	e8 d8 08 00 00       	call   800bf4 <sys_cputs>

	return b.cnt;
}
  80031c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80032d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	e8 87 ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    
	...

00800340 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 3c             	sub    $0x3c,%esp
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	89 d7                	mov    %edx,%edi
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
  800357:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800360:	85 c0                	test   %eax,%eax
  800362:	75 08                	jne    80036c <printnum+0x2c>
  800364:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800367:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036a:	77 57                	ja     8003c3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800370:	4b                   	dec    %ebx
  800371:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800375:	8b 45 10             	mov    0x10(%ebp),%eax
  800378:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800380:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800384:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038b:	00 
  80038c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	e8 1a 2b 00 00       	call   802eb8 <__udivdi3>
  80039e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003a6:	89 04 24             	mov    %eax,(%esp)
  8003a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ad:	89 fa                	mov    %edi,%edx
  8003af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b2:	e8 89 ff ff ff       	call   800340 <printnum>
  8003b7:	eb 0f                	jmp    8003c8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003bd:	89 34 24             	mov    %esi,(%esp)
  8003c0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c3:	4b                   	dec    %ebx
  8003c4:	85 db                	test   %ebx,%ebx
  8003c6:	7f f1                	jg     8003b9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003cc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003de:	00 
  8003df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e2:	89 04 24             	mov    %eax,(%esp)
  8003e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ec:	e8 e7 2b 00 00       	call   802fd8 <__umoddi3>
  8003f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f5:	0f be 80 f3 31 80 00 	movsbl 0x8031f3(%eax),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800402:	83 c4 3c             	add    $0x3c,%esp
  800405:	5b                   	pop    %ebx
  800406:	5e                   	pop    %esi
  800407:	5f                   	pop    %edi
  800408:	5d                   	pop    %ebp
  800409:	c3                   	ret    

0080040a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80040d:	83 fa 01             	cmp    $0x1,%edx
  800410:	7e 0e                	jle    800420 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800412:	8b 10                	mov    (%eax),%edx
  800414:	8d 4a 08             	lea    0x8(%edx),%ecx
  800417:	89 08                	mov    %ecx,(%eax)
  800419:	8b 02                	mov    (%edx),%eax
  80041b:	8b 52 04             	mov    0x4(%edx),%edx
  80041e:	eb 22                	jmp    800442 <getuint+0x38>
	else if (lflag)
  800420:	85 d2                	test   %edx,%edx
  800422:	74 10                	je     800434 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800424:	8b 10                	mov    (%eax),%edx
  800426:	8d 4a 04             	lea    0x4(%edx),%ecx
  800429:	89 08                	mov    %ecx,(%eax)
  80042b:	8b 02                	mov    (%edx),%eax
  80042d:	ba 00 00 00 00       	mov    $0x0,%edx
  800432:	eb 0e                	jmp    800442 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 4a 04             	lea    0x4(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80044d:	8b 10                	mov    (%eax),%edx
  80044f:	3b 50 04             	cmp    0x4(%eax),%edx
  800452:	73 08                	jae    80045c <sprintputch+0x18>
		*b->buf++ = ch;
  800454:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800457:	88 0a                	mov    %cl,(%edx)
  800459:	42                   	inc    %edx
  80045a:	89 10                	mov    %edx,(%eax)
}
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    

0080045e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800464:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800467:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046b:	8b 45 10             	mov    0x10(%ebp),%eax
  80046e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
  800475:	89 44 24 04          	mov    %eax,0x4(%esp)
  800479:	8b 45 08             	mov    0x8(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 02 00 00 00       	call   800486 <vprintfmt>
	va_end(ap);
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	57                   	push   %edi
  80048a:	56                   	push   %esi
  80048b:	53                   	push   %ebx
  80048c:	83 ec 4c             	sub    $0x4c,%esp
  80048f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800492:	8b 75 10             	mov    0x10(%ebp),%esi
  800495:	eb 12                	jmp    8004a9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800497:	85 c0                	test   %eax,%eax
  800499:	0f 84 6b 03 00 00    	je     80080a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80049f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a9:	0f b6 06             	movzbl (%esi),%eax
  8004ac:	46                   	inc    %esi
  8004ad:	83 f8 25             	cmp    $0x25,%eax
  8004b0:	75 e5                	jne    800497 <vprintfmt+0x11>
  8004b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ce:	eb 26                	jmp    8004f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004d7:	eb 1d                	jmp    8004f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004dc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004e0:	eb 14                	jmp    8004f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004e5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004ec:	eb 08                	jmp    8004f6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ee:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	0f b6 06             	movzbl (%esi),%eax
  8004f9:	8d 56 01             	lea    0x1(%esi),%edx
  8004fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ff:	8a 16                	mov    (%esi),%dl
  800501:	83 ea 23             	sub    $0x23,%edx
  800504:	80 fa 55             	cmp    $0x55,%dl
  800507:	0f 87 e1 02 00 00    	ja     8007ee <vprintfmt+0x368>
  80050d:	0f b6 d2             	movzbl %dl,%edx
  800510:	ff 24 95 40 33 80 00 	jmp    *0x803340(,%edx,4)
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80051f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800522:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800526:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800529:	8d 50 d0             	lea    -0x30(%eax),%edx
  80052c:	83 fa 09             	cmp    $0x9,%edx
  80052f:	77 2a                	ja     80055b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800531:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800532:	eb eb                	jmp    80051f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 04             	lea    0x4(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800542:	eb 17                	jmp    80055b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800548:	78 98                	js     8004e2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054d:	eb a7                	jmp    8004f6 <vprintfmt+0x70>
  80054f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800552:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800559:	eb 9b                	jmp    8004f6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80055b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055f:	79 95                	jns    8004f6 <vprintfmt+0x70>
  800561:	eb 8b                	jmp    8004ee <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800563:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800567:	eb 8d                	jmp    8004f6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 04 24             	mov    %eax,(%esp)
  80057b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800581:	e9 23 ff ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	85 c0                	test   %eax,%eax
  800593:	79 02                	jns    800597 <vprintfmt+0x111>
  800595:	f7 d8                	neg    %eax
  800597:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800599:	83 f8 10             	cmp    $0x10,%eax
  80059c:	7f 0b                	jg     8005a9 <vprintfmt+0x123>
  80059e:	8b 04 85 a0 34 80 00 	mov    0x8034a0(,%eax,4),%eax
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	75 23                	jne    8005cc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ad:	c7 44 24 08 0b 32 80 	movl   $0x80320b,0x8(%esp)
  8005b4:	00 
  8005b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	e8 9a fe ff ff       	call   80045e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c7:	e9 dd fe ff ff       	jmp    8004a9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d0:	c7 44 24 08 79 36 80 	movl   $0x803679,0x8(%esp)
  8005d7:	00 
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8005df:	89 14 24             	mov    %edx,(%esp)
  8005e2:	e8 77 fe ff ff       	call   80045e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ea:	e9 ba fe ff ff       	jmp    8004a9 <vprintfmt+0x23>
  8005ef:	89 f9                	mov    %edi,%ecx
  8005f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 30                	mov    (%eax),%esi
  800602:	85 f6                	test   %esi,%esi
  800604:	75 05                	jne    80060b <vprintfmt+0x185>
				p = "(null)";
  800606:	be 04 32 80 00       	mov    $0x803204,%esi
			if (width > 0 && padc != '-')
  80060b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060f:	0f 8e 84 00 00 00    	jle    800699 <vprintfmt+0x213>
  800615:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800619:	74 7e                	je     800699 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80061f:	89 34 24             	mov    %esi,(%esp)
  800622:	e8 8b 02 00 00       	call   8008b2 <strnlen>
  800627:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062a:	29 c2                	sub    %eax,%edx
  80062c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80062f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800633:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800636:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800639:	89 de                	mov    %ebx,%esi
  80063b:	89 d3                	mov    %edx,%ebx
  80063d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063f:	eb 0b                	jmp    80064c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800641:	89 74 24 04          	mov    %esi,0x4(%esp)
  800645:	89 3c 24             	mov    %edi,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064b:	4b                   	dec    %ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f f1                	jg     800641 <vprintfmt+0x1bb>
  800650:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800653:	89 f3                	mov    %esi,%ebx
  800655:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065b:	85 c0                	test   %eax,%eax
  80065d:	79 05                	jns    800664 <vprintfmt+0x1de>
  80065f:	b8 00 00 00 00       	mov    $0x0,%eax
  800664:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800667:	29 c2                	sub    %eax,%edx
  800669:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80066c:	eb 2b                	jmp    800699 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800672:	74 18                	je     80068c <vprintfmt+0x206>
  800674:	8d 50 e0             	lea    -0x20(%eax),%edx
  800677:	83 fa 5e             	cmp    $0x5e,%edx
  80067a:	76 10                	jbe    80068c <vprintfmt+0x206>
					putch('?', putdat);
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
  80068a:	eb 0a                	jmp    800696 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800696:	ff 4d e4             	decl   -0x1c(%ebp)
  800699:	0f be 06             	movsbl (%esi),%eax
  80069c:	46                   	inc    %esi
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 21                	je     8006c2 <vprintfmt+0x23c>
  8006a1:	85 ff                	test   %edi,%edi
  8006a3:	78 c9                	js     80066e <vprintfmt+0x1e8>
  8006a5:	4f                   	dec    %edi
  8006a6:	79 c6                	jns    80066e <vprintfmt+0x1e8>
  8006a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ab:	89 de                	mov    %ebx,%esi
  8006ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b0:	eb 18                	jmp    8006ca <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006bd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bf:	4b                   	dec    %ebx
  8006c0:	eb 08                	jmp    8006ca <vprintfmt+0x244>
  8006c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c5:	89 de                	mov    %ebx,%esi
  8006c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ca:	85 db                	test   %ebx,%ebx
  8006cc:	7f e4                	jg     8006b2 <vprintfmt+0x22c>
  8006ce:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d6:	e9 ce fd ff ff       	jmp    8004a9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006db:	83 f9 01             	cmp    $0x1,%ecx
  8006de:	7e 10                	jle    8006f0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 08             	lea    0x8(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 30                	mov    (%eax),%esi
  8006eb:	8b 78 04             	mov    0x4(%eax),%edi
  8006ee:	eb 26                	jmp    800716 <vprintfmt+0x290>
	else if (lflag)
  8006f0:	85 c9                	test   %ecx,%ecx
  8006f2:	74 12                	je     800706 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 30                	mov    (%eax),%esi
  8006ff:	89 f7                	mov    %esi,%edi
  800701:	c1 ff 1f             	sar    $0x1f,%edi
  800704:	eb 10                	jmp    800716 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 30                	mov    (%eax),%esi
  800711:	89 f7                	mov    %esi,%edi
  800713:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800716:	85 ff                	test   %edi,%edi
  800718:	78 0a                	js     800724 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071f:	e9 8c 00 00 00       	jmp    8007b0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800732:	f7 de                	neg    %esi
  800734:	83 d7 00             	adc    $0x0,%edi
  800737:	f7 df                	neg    %edi
			}
			base = 10;
  800739:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073e:	eb 70                	jmp    8007b0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800740:	89 ca                	mov    %ecx,%edx
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
  800745:	e8 c0 fc ff ff       	call   80040a <getuint>
  80074a:	89 c6                	mov    %eax,%esi
  80074c:	89 d7                	mov    %edx,%edi
			base = 10;
  80074e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800753:	eb 5b                	jmp    8007b0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800755:	89 ca                	mov    %ecx,%edx
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
  80075a:	e8 ab fc ff ff       	call   80040a <getuint>
  80075f:	89 c6                	mov    %eax,%esi
  800761:	89 d7                	mov    %edx,%edi
			base = 8;
  800763:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800768:	eb 46                	jmp    8007b0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800775:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 50 04             	lea    0x4(%eax),%edx
  80078c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078f:	8b 30                	mov    (%eax),%esi
  800791:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800796:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80079b:	eb 13                	jmp    8007b0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079d:	89 ca                	mov    %ecx,%edx
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a2:	e8 63 fc ff ff       	call   80040a <getuint>
  8007a7:	89 c6                	mov    %eax,%esi
  8007a9:	89 d7                	mov    %edx,%edi
			base = 16;
  8007ab:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007b4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c3:	89 34 24             	mov    %esi,(%esp)
  8007c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ca:	89 da                	mov    %ebx,%edx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	e8 6c fb ff ff       	call   800340 <printnum>
			break;
  8007d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d7:	e9 cd fc ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e9:	e9 bb fc ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fc:	eb 01                	jmp    8007ff <vprintfmt+0x379>
  8007fe:	4e                   	dec    %esi
  8007ff:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800803:	75 f9                	jne    8007fe <vprintfmt+0x378>
  800805:	e9 9f fc ff ff       	jmp    8004a9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80080a:	83 c4 4c             	add    $0x4c,%esp
  80080d:	5b                   	pop    %ebx
  80080e:	5e                   	pop    %esi
  80080f:	5f                   	pop    %edi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 28             	sub    $0x28,%esp
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800821:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800825:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800828:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082f:	85 c0                	test   %eax,%eax
  800831:	74 30                	je     800863 <vsnprintf+0x51>
  800833:	85 d2                	test   %edx,%edx
  800835:	7e 33                	jle    80086a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083e:	8b 45 10             	mov    0x10(%ebp),%eax
  800841:	89 44 24 08          	mov    %eax,0x8(%esp)
  800845:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084c:	c7 04 24 44 04 80 00 	movl   $0x800444,(%esp)
  800853:	e8 2e fc ff ff       	call   800486 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800858:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800861:	eb 0c                	jmp    80086f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800863:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800868:	eb 05                	jmp    80086f <vsnprintf+0x5d>
  80086a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800877:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087e:	8b 45 10             	mov    0x10(%ebp),%eax
  800881:	89 44 24 08          	mov    %eax,0x8(%esp)
  800885:	8b 45 0c             	mov    0xc(%ebp),%eax
  800888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	89 04 24             	mov    %eax,(%esp)
  800892:	e8 7b ff ff ff       	call   800812 <vsnprintf>
	va_end(ap);

	return rc;
}
  800897:	c9                   	leave  
  800898:	c3                   	ret    
  800899:	00 00                	add    %al,(%eax)
	...

0080089c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a7:	eb 01                	jmp    8008aa <strlen+0xe>
		n++;
  8008a9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ae:	75 f9                	jne    8008a9 <strlen+0xd>
		n++;
	return n;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c0:	eb 01                	jmp    8008c3 <strnlen+0x11>
		n++;
  8008c2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c3:	39 d0                	cmp    %edx,%eax
  8008c5:	74 06                	je     8008cd <strnlen+0x1b>
  8008c7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cb:	75 f5                	jne    8008c2 <strnlen+0x10>
		n++;
	return n;
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008de:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008e1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e4:	42                   	inc    %edx
  8008e5:	84 c9                	test   %cl,%cl
  8008e7:	75 f5                	jne    8008de <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 9e ff ff ff       	call   80089c <strlen>
	strcpy(dst + len, src);
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	89 54 24 04          	mov    %edx,0x4(%esp)
  800905:	01 d8                	add    %ebx,%eax
  800907:	89 04 24             	mov    %eax,(%esp)
  80090a:	e8 c0 ff ff ff       	call   8008cf <strcpy>
	return dst;
}
  80090f:	89 d8                	mov    %ebx,%eax
  800911:	83 c4 08             	add    $0x8,%esp
  800914:	5b                   	pop    %ebx
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800922:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800925:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092a:	eb 0c                	jmp    800938 <strncpy+0x21>
		*dst++ = *src;
  80092c:	8a 1a                	mov    (%edx),%bl
  80092e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800931:	80 3a 01             	cmpb   $0x1,(%edx)
  800934:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800937:	41                   	inc    %ecx
  800938:	39 f1                	cmp    %esi,%ecx
  80093a:	75 f0                	jne    80092c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 75 08             	mov    0x8(%ebp),%esi
  800948:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094e:	85 d2                	test   %edx,%edx
  800950:	75 0a                	jne    80095c <strlcpy+0x1c>
  800952:	89 f0                	mov    %esi,%eax
  800954:	eb 1a                	jmp    800970 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800956:	88 18                	mov    %bl,(%eax)
  800958:	40                   	inc    %eax
  800959:	41                   	inc    %ecx
  80095a:	eb 02                	jmp    80095e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80095e:	4a                   	dec    %edx
  80095f:	74 0a                	je     80096b <strlcpy+0x2b>
  800961:	8a 19                	mov    (%ecx),%bl
  800963:	84 db                	test   %bl,%bl
  800965:	75 ef                	jne    800956 <strlcpy+0x16>
  800967:	89 c2                	mov    %eax,%edx
  800969:	eb 02                	jmp    80096d <strlcpy+0x2d>
  80096b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80096d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800970:	29 f0                	sub    %esi,%eax
}
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097f:	eb 02                	jmp    800983 <strcmp+0xd>
		p++, q++;
  800981:	41                   	inc    %ecx
  800982:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800983:	8a 01                	mov    (%ecx),%al
  800985:	84 c0                	test   %al,%al
  800987:	74 04                	je     80098d <strcmp+0x17>
  800989:	3a 02                	cmp    (%edx),%al
  80098b:	74 f4                	je     800981 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098d:	0f b6 c0             	movzbl %al,%eax
  800990:	0f b6 12             	movzbl (%edx),%edx
  800993:	29 d0                	sub    %edx,%eax
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009a4:	eb 03                	jmp    8009a9 <strncmp+0x12>
		n--, p++, q++;
  8009a6:	4a                   	dec    %edx
  8009a7:	40                   	inc    %eax
  8009a8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a9:	85 d2                	test   %edx,%edx
  8009ab:	74 14                	je     8009c1 <strncmp+0x2a>
  8009ad:	8a 18                	mov    (%eax),%bl
  8009af:	84 db                	test   %bl,%bl
  8009b1:	74 04                	je     8009b7 <strncmp+0x20>
  8009b3:	3a 19                	cmp    (%ecx),%bl
  8009b5:	74 ef                	je     8009a6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b7:	0f b6 00             	movzbl (%eax),%eax
  8009ba:	0f b6 11             	movzbl (%ecx),%edx
  8009bd:	29 d0                	sub    %edx,%eax
  8009bf:	eb 05                	jmp    8009c6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009d2:	eb 05                	jmp    8009d9 <strchr+0x10>
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 0c                	je     8009e4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d8:	40                   	inc    %eax
  8009d9:	8a 10                	mov    (%eax),%dl
  8009db:	84 d2                	test   %dl,%dl
  8009dd:	75 f5                	jne    8009d4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009ef:	eb 05                	jmp    8009f6 <strfind+0x10>
		if (*s == c)
  8009f1:	38 ca                	cmp    %cl,%dl
  8009f3:	74 07                	je     8009fc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f5:	40                   	inc    %eax
  8009f6:	8a 10                	mov    (%eax),%dl
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	75 f5                	jne    8009f1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0d:	85 c9                	test   %ecx,%ecx
  800a0f:	74 30                	je     800a41 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a11:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a17:	75 25                	jne    800a3e <memset+0x40>
  800a19:	f6 c1 03             	test   $0x3,%cl
  800a1c:	75 20                	jne    800a3e <memset+0x40>
		c &= 0xFF;
  800a1e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a21:	89 d3                	mov    %edx,%ebx
  800a23:	c1 e3 08             	shl    $0x8,%ebx
  800a26:	89 d6                	mov    %edx,%esi
  800a28:	c1 e6 18             	shl    $0x18,%esi
  800a2b:	89 d0                	mov    %edx,%eax
  800a2d:	c1 e0 10             	shl    $0x10,%eax
  800a30:	09 f0                	or     %esi,%eax
  800a32:	09 d0                	or     %edx,%eax
  800a34:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a36:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a39:	fc                   	cld    
  800a3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3c:	eb 03                	jmp    800a41 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3e:	fc                   	cld    
  800a3f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a41:	89 f8                	mov    %edi,%eax
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5f                   	pop    %edi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a56:	39 c6                	cmp    %eax,%esi
  800a58:	73 34                	jae    800a8e <memmove+0x46>
  800a5a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5d:	39 d0                	cmp    %edx,%eax
  800a5f:	73 2d                	jae    800a8e <memmove+0x46>
		s += n;
		d += n;
  800a61:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a64:	f6 c2 03             	test   $0x3,%dl
  800a67:	75 1b                	jne    800a84 <memmove+0x3c>
  800a69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6f:	75 13                	jne    800a84 <memmove+0x3c>
  800a71:	f6 c1 03             	test   $0x3,%cl
  800a74:	75 0e                	jne    800a84 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a76:	83 ef 04             	sub    $0x4,%edi
  800a79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a7f:	fd                   	std    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 07                	jmp    800a8b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a84:	4f                   	dec    %edi
  800a85:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a88:	fd                   	std    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8b:	fc                   	cld    
  800a8c:	eb 20                	jmp    800aae <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a94:	75 13                	jne    800aa9 <memmove+0x61>
  800a96:	a8 03                	test   $0x3,%al
  800a98:	75 0f                	jne    800aa9 <memmove+0x61>
  800a9a:	f6 c1 03             	test   $0x3,%cl
  800a9d:	75 0a                	jne    800aa9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb 05                	jmp    800aae <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa9:	89 c7                	mov    %eax,%edi
  800aab:	fc                   	cld    
  800aac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab8:	8b 45 10             	mov    0x10(%ebp),%eax
  800abb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	89 04 24             	mov    %eax,(%esp)
  800acc:	e8 77 ff ff ff       	call   800a48 <memmove>
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	eb 16                	jmp    800aff <memcmp+0x2c>
		if (*s1 != *s2)
  800ae9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800aec:	42                   	inc    %edx
  800aed:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800af1:	38 c8                	cmp    %cl,%al
  800af3:	74 0a                	je     800aff <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800af5:	0f b6 c0             	movzbl %al,%eax
  800af8:	0f b6 c9             	movzbl %cl,%ecx
  800afb:	29 c8                	sub    %ecx,%eax
  800afd:	eb 09                	jmp    800b08 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aff:	39 da                	cmp    %ebx,%edx
  800b01:	75 e6                	jne    800ae9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b16:	89 c2                	mov    %eax,%edx
  800b18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1b:	eb 05                	jmp    800b22 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1d:	38 08                	cmp    %cl,(%eax)
  800b1f:	74 05                	je     800b26 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b21:	40                   	inc    %eax
  800b22:	39 d0                	cmp    %edx,%eax
  800b24:	72 f7                	jb     800b1d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b34:	eb 01                	jmp    800b37 <strtol+0xf>
		s++;
  800b36:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b37:	8a 02                	mov    (%edx),%al
  800b39:	3c 20                	cmp    $0x20,%al
  800b3b:	74 f9                	je     800b36 <strtol+0xe>
  800b3d:	3c 09                	cmp    $0x9,%al
  800b3f:	74 f5                	je     800b36 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b41:	3c 2b                	cmp    $0x2b,%al
  800b43:	75 08                	jne    800b4d <strtol+0x25>
		s++;
  800b45:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b46:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4b:	eb 13                	jmp    800b60 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4d:	3c 2d                	cmp    $0x2d,%al
  800b4f:	75 0a                	jne    800b5b <strtol+0x33>
		s++, neg = 1;
  800b51:	8d 52 01             	lea    0x1(%edx),%edx
  800b54:	bf 01 00 00 00       	mov    $0x1,%edi
  800b59:	eb 05                	jmp    800b60 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b60:	85 db                	test   %ebx,%ebx
  800b62:	74 05                	je     800b69 <strtol+0x41>
  800b64:	83 fb 10             	cmp    $0x10,%ebx
  800b67:	75 28                	jne    800b91 <strtol+0x69>
  800b69:	8a 02                	mov    (%edx),%al
  800b6b:	3c 30                	cmp    $0x30,%al
  800b6d:	75 10                	jne    800b7f <strtol+0x57>
  800b6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b73:	75 0a                	jne    800b7f <strtol+0x57>
		s += 2, base = 16;
  800b75:	83 c2 02             	add    $0x2,%edx
  800b78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7d:	eb 12                	jmp    800b91 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b7f:	85 db                	test   %ebx,%ebx
  800b81:	75 0e                	jne    800b91 <strtol+0x69>
  800b83:	3c 30                	cmp    $0x30,%al
  800b85:	75 05                	jne    800b8c <strtol+0x64>
		s++, base = 8;
  800b87:	42                   	inc    %edx
  800b88:	b3 08                	mov    $0x8,%bl
  800b8a:	eb 05                	jmp    800b91 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b98:	8a 0a                	mov    (%edx),%cl
  800b9a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b9d:	80 fb 09             	cmp    $0x9,%bl
  800ba0:	77 08                	ja     800baa <strtol+0x82>
			dig = *s - '0';
  800ba2:	0f be c9             	movsbl %cl,%ecx
  800ba5:	83 e9 30             	sub    $0x30,%ecx
  800ba8:	eb 1e                	jmp    800bc8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800baa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 08                	ja     800bba <strtol+0x92>
			dig = *s - 'a' + 10;
  800bb2:	0f be c9             	movsbl %cl,%ecx
  800bb5:	83 e9 57             	sub    $0x57,%ecx
  800bb8:	eb 0e                	jmp    800bc8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bba:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bbd:	80 fb 19             	cmp    $0x19,%bl
  800bc0:	77 12                	ja     800bd4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bc2:	0f be c9             	movsbl %cl,%ecx
  800bc5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bc8:	39 f1                	cmp    %esi,%ecx
  800bca:	7d 0c                	jge    800bd8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bcc:	42                   	inc    %edx
  800bcd:	0f af c6             	imul   %esi,%eax
  800bd0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bd2:	eb c4                	jmp    800b98 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bd4:	89 c1                	mov    %eax,%ecx
  800bd6:	eb 02                	jmp    800bda <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bde:	74 05                	je     800be5 <strtol+0xbd>
		*endptr = (char *) s;
  800be0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be5:	85 ff                	test   %edi,%edi
  800be7:	74 04                	je     800bed <strtol+0xc5>
  800be9:	89 c8                	mov    %ecx,%eax
  800beb:	f7 d8                	neg    %eax
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    
	...

00800bf4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 c3                	mov    %eax,%ebx
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	89 c6                	mov    %eax,%esi
  800c0b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c22:	89 d1                	mov    %edx,%ecx
  800c24:	89 d3                	mov    %edx,%ebx
  800c26:	89 d7                	mov    %edx,%edi
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 cb                	mov    %ecx,%ebx
  800c49:	89 cf                	mov    %ecx,%edi
  800c4b:	89 ce                	mov    %ecx,%esi
  800c4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 28                	jle    800c7b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c57:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c5e:	00 
  800c5f:	c7 44 24 08 03 35 80 	movl   $0x803503,0x8(%esp)
  800c66:	00 
  800c67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6e:	00 
  800c6f:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800c76:	e8 b1 f5 ff ff       	call   80022c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7b:	83 c4 2c             	add    $0x2c,%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	89 d3                	mov    %edx,%ebx
  800c97:	89 d7                	mov    %edx,%edi
  800c99:	89 d6                	mov    %edx,%esi
  800c9b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_yield>:

void
sys_yield(void)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	89 d7                	mov    %edx,%edi
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	be 00 00 00 00       	mov    $0x0,%esi
  800ccf:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 f7                	mov    %esi,%edi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 28                	jle    800d0d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 08 03 35 80 	movl   $0x803503,0x8(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d00:	00 
  800d01:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800d08:	e8 1f f5 ff ff       	call   80022c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0d:	83 c4 2c             	add    $0x2c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d23:	8b 75 18             	mov    0x18(%ebp),%esi
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 28                	jle    800d60 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d43:	00 
  800d44:	c7 44 24 08 03 35 80 	movl   $0x803503,0x8(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d53:	00 
  800d54:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800d5b:	e8 cc f4 ff ff       	call   80022c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d60:	83 c4 2c             	add    $0x2c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 28                	jle    800db3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d96:	00 
  800d97:	c7 44 24 08 03 35 80 	movl   $0x803503,0x8(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da6:	00 
  800da7:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800dae:	e8 79 f4 ff ff       	call   80022c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db3:	83 c4 2c             	add    $0x2c,%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800dc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	89 df                	mov    %ebx,%edi
  800dd6:	89 de                	mov    %ebx,%esi
  800dd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7e 28                	jle    800e06 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800de9:	00 
  800dea:	c7 44 24 08 03 35 80 	movl   $0x803503,0x8(%esp)
  800df1:	00 
  800df2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df9:	00 
  800dfa:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800e01:	e8 26 f4 ff ff       	call   80022c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e06:	83 c4 2c             	add    $0x2c,%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 df                	mov    %ebx,%edi
  800e29:	89 de                	mov    %ebx,%esi
  800e2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7e 28                	jle    800e59 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e35:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e3c:	00 
  800e3d:	c7 44 24 08 03 35 80 	movl   $0x803503,0x8(%esp)
  800e44:	00 
  800e45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4c:	00 
  800e4d:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800e54:	e8 d3 f3 ff ff       	call   80022c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e59:	83 c4 2c             	add    $0x2c,%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 df                	mov    %ebx,%edi
  800e7c:	89 de                	mov    %ebx,%esi
  800e7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 28                	jle    800eac <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e88:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e8f:	00 
  800e90:	c7 44 24 08 03 35 80 	movl   $0x803503,0x8(%esp)
  800e97:	00 
  800e98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9f:	00 
  800ea0:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800ea7:	e8 80 f3 ff ff       	call   80022c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eac:	83 c4 2c             	add    $0x2c,%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eba:	be 00 00 00 00       	mov    $0x0,%esi
  800ebf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed2:	5b                   	pop    %ebx
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	89 cb                	mov    %ecx,%ebx
  800eef:	89 cf                	mov    %ecx,%edi
  800ef1:	89 ce                	mov    %ecx,%esi
  800ef3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	7e 28                	jle    800f21 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f04:	00 
  800f05:	c7 44 24 08 03 35 80 	movl   $0x803503,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  800f1c:	e8 0b f3 ff ff       	call   80022c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f21:	83 c4 2c             	add    $0x2c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f34:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f39:	89 d1                	mov    %edx,%ecx
  800f3b:	89 d3                	mov    %edx,%ebx
  800f3d:	89 d7                	mov    %edx,%edi
  800f3f:	89 d6                	mov    %edx,%esi
  800f41:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f53:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	89 df                	mov    %ebx,%edi
  800f60:	89 de                	mov    %ebx,%esi
  800f62:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f74:	b8 10 00 00 00       	mov    $0x10,%eax
  800f79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7f:	89 df                	mov    %ebx,%edi
  800f81:	89 de                	mov    %ebx,%esi
  800f83:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    
	...

00800f8c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	53                   	push   %ebx
  800f90:	83 ec 24             	sub    $0x24,%esp
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f96:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800f98:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f9c:	74 2d                	je     800fcb <pgfault+0x3f>
  800f9e:	89 d8                	mov    %ebx,%eax
  800fa0:	c1 e8 16             	shr    $0x16,%eax
  800fa3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800faa:	a8 01                	test   $0x1,%al
  800fac:	74 1d                	je     800fcb <pgfault+0x3f>
  800fae:	89 d8                	mov    %ebx,%eax
  800fb0:	c1 e8 0c             	shr    $0xc,%eax
  800fb3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fba:	f6 c2 01             	test   $0x1,%dl
  800fbd:	74 0c                	je     800fcb <pgfault+0x3f>
  800fbf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc6:	f6 c4 08             	test   $0x8,%ah
  800fc9:	75 1c                	jne    800fe7 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  800fcb:	c7 44 24 08 30 35 80 	movl   $0x803530,0x8(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800fda:	00 
  800fdb:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  800fe2:	e8 45 f2 ff ff       	call   80022c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  800fe7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800fed:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801004:	e8 b8 fc ff ff       	call   800cc1 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  801009:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801010:	00 
  801011:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801015:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80101c:	e8 91 fa ff ff       	call   800ab2 <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  801021:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801028:	00 
  801029:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80102d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801034:	00 
  801035:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80103c:	00 
  80103d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801044:	e8 cc fc ff ff       	call   800d15 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  801049:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801050:	00 
  801051:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801058:	e8 0b fd ff ff       	call   800d68 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  80105d:	83 c4 24             	add    $0x24,%esp
  801060:	5b                   	pop    %ebx
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	57                   	push   %edi
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80106c:	c7 04 24 8c 0f 80 00 	movl   $0x800f8c,(%esp)
  801073:	e8 50 1c 00 00       	call   802cc8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801078:	ba 07 00 00 00       	mov    $0x7,%edx
  80107d:	89 d0                	mov    %edx,%eax
  80107f:	cd 30                	int    $0x30
  801081:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801084:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  801086:	85 c0                	test   %eax,%eax
  801088:	79 20                	jns    8010aa <fork+0x47>
		panic("sys_exofork: %e", envid);
  80108a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108e:	c7 44 24 08 7e 35 80 	movl   $0x80357e,0x8(%esp)
  801095:	00 
  801096:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  80109d:	00 
  80109e:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  8010a5:	e8 82 f1 ff ff       	call   80022c <_panic>
	if (envid == 0)
  8010aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010ae:	75 25                	jne    8010d5 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8010b0:	e8 ce fb ff ff       	call   800c83 <sys_getenvid>
  8010b5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010c1:	c1 e0 07             	shl    $0x7,%eax
  8010c4:	29 d0                	sub    %edx,%eax
  8010c6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010cb:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8010d0:	e9 43 02 00 00       	jmp    801318 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  8010d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  8010da:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010e0:	0f 84 85 01 00 00    	je     80126b <fork+0x208>
  8010e6:	89 d8                	mov    %ebx,%eax
  8010e8:	c1 e8 16             	shr    $0x16,%eax
  8010eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f2:	a8 01                	test   $0x1,%al
  8010f4:	0f 84 5f 01 00 00    	je     801259 <fork+0x1f6>
  8010fa:	89 d8                	mov    %ebx,%eax
  8010fc:	c1 e8 0c             	shr    $0xc,%eax
  8010ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801106:	f6 c2 01             	test   $0x1,%dl
  801109:	0f 84 4a 01 00 00    	je     801259 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  80110f:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  801111:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801118:	f6 c6 04             	test   $0x4,%dh
  80111b:	74 50                	je     80116d <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  80111d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801124:	25 07 0e 00 00       	and    $0xe07,%eax
  801129:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801131:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801135:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801139:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801140:	e8 d0 fb ff ff       	call   800d15 <sys_page_map>
  801145:	85 c0                	test   %eax,%eax
  801147:	0f 89 0c 01 00 00    	jns    801259 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  80114d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801151:	c7 44 24 08 8e 35 80 	movl   $0x80358e,0x8(%esp)
  801158:	00 
  801159:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801160:	00 
  801161:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  801168:	e8 bf f0 ff ff       	call   80022c <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  80116d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801174:	f6 c2 02             	test   $0x2,%dl
  801177:	75 10                	jne    801189 <fork+0x126>
  801179:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801180:	f6 c4 08             	test   $0x8,%ah
  801183:	0f 84 8c 00 00 00    	je     801215 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  801189:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801190:	00 
  801191:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801195:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801199:	89 74 24 04          	mov    %esi,0x4(%esp)
  80119d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a4:	e8 6c fb ff ff       	call   800d15 <sys_page_map>
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	79 20                	jns    8011cd <fork+0x16a>
		{
			panic("duppage error: %e",e);
  8011ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b1:	c7 44 24 08 8e 35 80 	movl   $0x80358e,0x8(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8011c0:	00 
  8011c1:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  8011c8:	e8 5f f0 ff ff       	call   80022c <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  8011cd:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011d4:	00 
  8011d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e0:	00 
  8011e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ec:	e8 24 fb ff ff       	call   800d15 <sys_page_map>
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	79 64                	jns    801259 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8011f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f9:	c7 44 24 08 8e 35 80 	movl   $0x80358e,0x8(%esp)
  801200:	00 
  801201:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801208:	00 
  801209:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  801210:	e8 17 f0 ff ff       	call   80022c <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  801215:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80121c:	00 
  80121d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801221:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801225:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801229:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801230:	e8 e0 fa ff ff       	call   800d15 <sys_page_map>
  801235:	85 c0                	test   %eax,%eax
  801237:	79 20                	jns    801259 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801239:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123d:	c7 44 24 08 8e 35 80 	movl   $0x80358e,0x8(%esp)
  801244:	00 
  801245:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80124c:	00 
  80124d:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  801254:	e8 d3 ef ff ff       	call   80022c <_panic>
  801259:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  80125f:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801265:	0f 85 6f fe ff ff    	jne    8010da <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  80126b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801272:	00 
  801273:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80127a:	ee 
  80127b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127e:	89 04 24             	mov    %eax,(%esp)
  801281:	e8 3b fa ff ff       	call   800cc1 <sys_page_alloc>
  801286:	85 c0                	test   %eax,%eax
  801288:	79 20                	jns    8012aa <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  80128a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128e:	c7 44 24 08 2c 31 80 	movl   $0x80312c,0x8(%esp)
  801295:	00 
  801296:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  80129d:	00 
  80129e:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  8012a5:	e8 82 ef ff ff       	call   80022c <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8012aa:	c7 44 24 04 14 2d 80 	movl   $0x802d14,0x4(%esp)
  8012b1:	00 
  8012b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b5:	89 04 24             	mov    %eax,(%esp)
  8012b8:	e8 a4 fb ff ff       	call   800e61 <sys_env_set_pgfault_upcall>
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	79 20                	jns    8012e1 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  8012c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c5:	c7 44 24 08 54 35 80 	movl   $0x803554,0x8(%esp)
  8012cc:	00 
  8012cd:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  8012d4:	00 
  8012d5:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  8012dc:	e8 4b ef ff ff       	call   80022c <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8012e1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012e8:	00 
  8012e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ec:	89 04 24             	mov    %eax,(%esp)
  8012ef:	e8 c7 fa ff ff       	call   800dbb <sys_env_set_status>
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	79 20                	jns    801318 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  8012f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fc:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  801303:	00 
  801304:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80130b:	00 
  80130c:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  801313:	e8 14 ef ff ff       	call   80022c <_panic>

	return envid;
	// panic("fork not implemented");
}
  801318:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80131b:	83 c4 3c             	add    $0x3c,%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <sfork>:

// Challenge!
int
sfork(void)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801329:	c7 44 24 08 b7 35 80 	movl   $0x8035b7,0x8(%esp)
  801330:	00 
  801331:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801338:	00 
  801339:	c7 04 24 73 35 80 00 	movl   $0x803573,(%esp)
  801340:	e8 e7 ee ff ff       	call   80022c <_panic>
  801345:	00 00                	add    %al,(%eax)
	...

00801348 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134b:	8b 45 08             	mov    0x8(%ebp),%eax
  80134e:	05 00 00 00 30       	add    $0x30000000,%eax
  801353:	c1 e8 0c             	shr    $0xc,%eax
}
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    

00801358 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80135e:	8b 45 08             	mov    0x8(%ebp),%eax
  801361:	89 04 24             	mov    %eax,(%esp)
  801364:	e8 df ff ff ff       	call   801348 <fd2num>
  801369:	c1 e0 0c             	shl    $0xc,%eax
  80136c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	53                   	push   %ebx
  801377:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80137a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80137f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801381:	89 c2                	mov    %eax,%edx
  801383:	c1 ea 16             	shr    $0x16,%edx
  801386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80138d:	f6 c2 01             	test   $0x1,%dl
  801390:	74 11                	je     8013a3 <fd_alloc+0x30>
  801392:	89 c2                	mov    %eax,%edx
  801394:	c1 ea 0c             	shr    $0xc,%edx
  801397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80139e:	f6 c2 01             	test   $0x1,%dl
  8013a1:	75 09                	jne    8013ac <fd_alloc+0x39>
			*fd_store = fd;
  8013a3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013aa:	eb 17                	jmp    8013c3 <fd_alloc+0x50>
  8013ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013b6:	75 c7                	jne    80137f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013c3:	5b                   	pop    %ebx
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013cc:	83 f8 1f             	cmp    $0x1f,%eax
  8013cf:	77 36                	ja     801407 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013d1:	c1 e0 0c             	shl    $0xc,%eax
  8013d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	c1 ea 16             	shr    $0x16,%edx
  8013de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e5:	f6 c2 01             	test   $0x1,%dl
  8013e8:	74 24                	je     80140e <fd_lookup+0x48>
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	c1 ea 0c             	shr    $0xc,%edx
  8013ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	74 1a                	je     801415 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
  801405:	eb 13                	jmp    80141a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140c:	eb 0c                	jmp    80141a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80140e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801413:	eb 05                	jmp    80141a <fd_lookup+0x54>
  801415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	53                   	push   %ebx
  801420:	83 ec 14             	sub    $0x14,%esp
  801423:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801429:	ba 00 00 00 00       	mov    $0x0,%edx
  80142e:	eb 0e                	jmp    80143e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801430:	39 08                	cmp    %ecx,(%eax)
  801432:	75 09                	jne    80143d <dev_lookup+0x21>
			*dev = devtab[i];
  801434:	89 03                	mov    %eax,(%ebx)
			return 0;
  801436:	b8 00 00 00 00       	mov    $0x0,%eax
  80143b:	eb 33                	jmp    801470 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80143d:	42                   	inc    %edx
  80143e:	8b 04 95 4c 36 80 00 	mov    0x80364c(,%edx,4),%eax
  801445:	85 c0                	test   %eax,%eax
  801447:	75 e7                	jne    801430 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801449:	a1 08 50 80 00       	mov    0x805008,%eax
  80144e:	8b 40 48             	mov    0x48(%eax),%eax
  801451:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801455:	89 44 24 04          	mov    %eax,0x4(%esp)
  801459:	c7 04 24 d0 35 80 00 	movl   $0x8035d0,(%esp)
  801460:	e8 bf ee ff ff       	call   800324 <cprintf>
	*dev = 0;
  801465:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80146b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801470:	83 c4 14             	add    $0x14,%esp
  801473:	5b                   	pop    %ebx
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	83 ec 30             	sub    $0x30,%esp
  80147e:	8b 75 08             	mov    0x8(%ebp),%esi
  801481:	8a 45 0c             	mov    0xc(%ebp),%al
  801484:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801487:	89 34 24             	mov    %esi,(%esp)
  80148a:	e8 b9 fe ff ff       	call   801348 <fd2num>
  80148f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801492:	89 54 24 04          	mov    %edx,0x4(%esp)
  801496:	89 04 24             	mov    %eax,(%esp)
  801499:	e8 28 ff ff ff       	call   8013c6 <fd_lookup>
  80149e:	89 c3                	mov    %eax,%ebx
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 05                	js     8014a9 <fd_close+0x33>
	    || fd != fd2)
  8014a4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014a7:	74 0d                	je     8014b6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8014a9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014ad:	75 46                	jne    8014f5 <fd_close+0x7f>
  8014af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b4:	eb 3f                	jmp    8014f5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bd:	8b 06                	mov    (%esi),%eax
  8014bf:	89 04 24             	mov    %eax,(%esp)
  8014c2:	e8 55 ff ff ff       	call   80141c <dev_lookup>
  8014c7:	89 c3                	mov    %eax,%ebx
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 18                	js     8014e5 <fd_close+0x6f>
		if (dev->dev_close)
  8014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d0:	8b 40 10             	mov    0x10(%eax),%eax
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	74 09                	je     8014e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014d7:	89 34 24             	mov    %esi,(%esp)
  8014da:	ff d0                	call   *%eax
  8014dc:	89 c3                	mov    %eax,%ebx
  8014de:	eb 05                	jmp    8014e5 <fd_close+0x6f>
		else
			r = 0;
  8014e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f0:	e8 73 f8 ff ff       	call   800d68 <sys_page_unmap>
	return r;
}
  8014f5:	89 d8                	mov    %ebx,%eax
  8014f7:	83 c4 30             	add    $0x30,%esp
  8014fa:	5b                   	pop    %ebx
  8014fb:	5e                   	pop    %esi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801504:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	89 04 24             	mov    %eax,(%esp)
  801511:	e8 b0 fe ff ff       	call   8013c6 <fd_lookup>
  801516:	85 c0                	test   %eax,%eax
  801518:	78 13                	js     80152d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80151a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801521:	00 
  801522:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801525:	89 04 24             	mov    %eax,(%esp)
  801528:	e8 49 ff ff ff       	call   801476 <fd_close>
}
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <close_all>:

void
close_all(void)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	53                   	push   %ebx
  801533:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801536:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80153b:	89 1c 24             	mov    %ebx,(%esp)
  80153e:	e8 bb ff ff ff       	call   8014fe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801543:	43                   	inc    %ebx
  801544:	83 fb 20             	cmp    $0x20,%ebx
  801547:	75 f2                	jne    80153b <close_all+0xc>
		close(i);
}
  801549:	83 c4 14             	add    $0x14,%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	57                   	push   %edi
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	83 ec 4c             	sub    $0x4c,%esp
  801558:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80155b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80155e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801562:	8b 45 08             	mov    0x8(%ebp),%eax
  801565:	89 04 24             	mov    %eax,(%esp)
  801568:	e8 59 fe ff ff       	call   8013c6 <fd_lookup>
  80156d:	89 c3                	mov    %eax,%ebx
  80156f:	85 c0                	test   %eax,%eax
  801571:	0f 88 e3 00 00 00    	js     80165a <dup+0x10b>
		return r;
	close(newfdnum);
  801577:	89 3c 24             	mov    %edi,(%esp)
  80157a:	e8 7f ff ff ff       	call   8014fe <close>

	newfd = INDEX2FD(newfdnum);
  80157f:	89 fe                	mov    %edi,%esi
  801581:	c1 e6 0c             	shl    $0xc,%esi
  801584:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80158a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 c3 fd ff ff       	call   801358 <fd2data>
  801595:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801597:	89 34 24             	mov    %esi,(%esp)
  80159a:	e8 b9 fd ff ff       	call   801358 <fd2data>
  80159f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a2:	89 d8                	mov    %ebx,%eax
  8015a4:	c1 e8 16             	shr    $0x16,%eax
  8015a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ae:	a8 01                	test   $0x1,%al
  8015b0:	74 46                	je     8015f8 <dup+0xa9>
  8015b2:	89 d8                	mov    %ebx,%eax
  8015b4:	c1 e8 0c             	shr    $0xc,%eax
  8015b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015be:	f6 c2 01             	test   $0x1,%dl
  8015c1:	74 35                	je     8015f8 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8015cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015e1:	00 
  8015e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ed:	e8 23 f7 ff ff       	call   800d15 <sys_page_map>
  8015f2:	89 c3                	mov    %eax,%ebx
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 3b                	js     801633 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015fb:	89 c2                	mov    %eax,%edx
  8015fd:	c1 ea 0c             	shr    $0xc,%edx
  801600:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801607:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80160d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801611:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801615:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80161c:	00 
  80161d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801621:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801628:	e8 e8 f6 ff ff       	call   800d15 <sys_page_map>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	85 c0                	test   %eax,%eax
  801631:	79 25                	jns    801658 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801633:	89 74 24 04          	mov    %esi,0x4(%esp)
  801637:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163e:	e8 25 f7 ff ff       	call   800d68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801643:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801651:	e8 12 f7 ff ff       	call   800d68 <sys_page_unmap>
	return r;
  801656:	eb 02                	jmp    80165a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801658:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80165a:	89 d8                	mov    %ebx,%eax
  80165c:	83 c4 4c             	add    $0x4c,%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	5f                   	pop    %edi
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    

00801664 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	53                   	push   %ebx
  801668:	83 ec 24             	sub    $0x24,%esp
  80166b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801671:	89 44 24 04          	mov    %eax,0x4(%esp)
  801675:	89 1c 24             	mov    %ebx,(%esp)
  801678:	e8 49 fd ff ff       	call   8013c6 <fd_lookup>
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 6d                	js     8016ee <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801684:	89 44 24 04          	mov    %eax,0x4(%esp)
  801688:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168b:	8b 00                	mov    (%eax),%eax
  80168d:	89 04 24             	mov    %eax,(%esp)
  801690:	e8 87 fd ff ff       	call   80141c <dev_lookup>
  801695:	85 c0                	test   %eax,%eax
  801697:	78 55                	js     8016ee <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801699:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169c:	8b 50 08             	mov    0x8(%eax),%edx
  80169f:	83 e2 03             	and    $0x3,%edx
  8016a2:	83 fa 01             	cmp    $0x1,%edx
  8016a5:	75 23                	jne    8016ca <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016a7:	a1 08 50 80 00       	mov    0x805008,%eax
  8016ac:	8b 40 48             	mov    0x48(%eax),%eax
  8016af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b7:	c7 04 24 11 36 80 00 	movl   $0x803611,(%esp)
  8016be:	e8 61 ec ff ff       	call   800324 <cprintf>
		return -E_INVAL;
  8016c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c8:	eb 24                	jmp    8016ee <read+0x8a>
	}
	if (!dev->dev_read)
  8016ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cd:	8b 52 08             	mov    0x8(%edx),%edx
  8016d0:	85 d2                	test   %edx,%edx
  8016d2:	74 15                	je     8016e9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016e2:	89 04 24             	mov    %eax,(%esp)
  8016e5:	ff d2                	call   *%edx
  8016e7:	eb 05                	jmp    8016ee <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016ee:	83 c4 24             	add    $0x24,%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5d                   	pop    %ebp
  8016f3:	c3                   	ret    

008016f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	57                   	push   %edi
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	83 ec 1c             	sub    $0x1c,%esp
  8016fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801700:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801703:	bb 00 00 00 00       	mov    $0x0,%ebx
  801708:	eb 23                	jmp    80172d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80170a:	89 f0                	mov    %esi,%eax
  80170c:	29 d8                	sub    %ebx,%eax
  80170e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801712:	8b 45 0c             	mov    0xc(%ebp),%eax
  801715:	01 d8                	add    %ebx,%eax
  801717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171b:	89 3c 24             	mov    %edi,(%esp)
  80171e:	e8 41 ff ff ff       	call   801664 <read>
		if (m < 0)
  801723:	85 c0                	test   %eax,%eax
  801725:	78 10                	js     801737 <readn+0x43>
			return m;
		if (m == 0)
  801727:	85 c0                	test   %eax,%eax
  801729:	74 0a                	je     801735 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172b:	01 c3                	add    %eax,%ebx
  80172d:	39 f3                	cmp    %esi,%ebx
  80172f:	72 d9                	jb     80170a <readn+0x16>
  801731:	89 d8                	mov    %ebx,%eax
  801733:	eb 02                	jmp    801737 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801735:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801737:	83 c4 1c             	add    $0x1c,%esp
  80173a:	5b                   	pop    %ebx
  80173b:	5e                   	pop    %esi
  80173c:	5f                   	pop    %edi
  80173d:	5d                   	pop    %ebp
  80173e:	c3                   	ret    

0080173f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	53                   	push   %ebx
  801743:	83 ec 24             	sub    $0x24,%esp
  801746:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801749:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801750:	89 1c 24             	mov    %ebx,(%esp)
  801753:	e8 6e fc ff ff       	call   8013c6 <fd_lookup>
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 68                	js     8017c4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801763:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801766:	8b 00                	mov    (%eax),%eax
  801768:	89 04 24             	mov    %eax,(%esp)
  80176b:	e8 ac fc ff ff       	call   80141c <dev_lookup>
  801770:	85 c0                	test   %eax,%eax
  801772:	78 50                	js     8017c4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801774:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801777:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177b:	75 23                	jne    8017a0 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80177d:	a1 08 50 80 00       	mov    0x805008,%eax
  801782:	8b 40 48             	mov    0x48(%eax),%eax
  801785:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178d:	c7 04 24 2d 36 80 00 	movl   $0x80362d,(%esp)
  801794:	e8 8b eb ff ff       	call   800324 <cprintf>
		return -E_INVAL;
  801799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80179e:	eb 24                	jmp    8017c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a6:	85 d2                	test   %edx,%edx
  8017a8:	74 15                	je     8017bf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017b8:	89 04 24             	mov    %eax,(%esp)
  8017bb:	ff d2                	call   *%edx
  8017bd:	eb 05                	jmp    8017c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017c4:	83 c4 24             	add    $0x24,%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	89 04 24             	mov    %eax,(%esp)
  8017dd:	e8 e4 fb ff ff       	call   8013c6 <fd_lookup>
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 0e                	js     8017f4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ec:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	53                   	push   %ebx
  8017fa:	83 ec 24             	sub    $0x24,%esp
  8017fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801800:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801803:	89 44 24 04          	mov    %eax,0x4(%esp)
  801807:	89 1c 24             	mov    %ebx,(%esp)
  80180a:	e8 b7 fb ff ff       	call   8013c6 <fd_lookup>
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 61                	js     801874 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801813:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801816:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181d:	8b 00                	mov    (%eax),%eax
  80181f:	89 04 24             	mov    %eax,(%esp)
  801822:	e8 f5 fb ff ff       	call   80141c <dev_lookup>
  801827:	85 c0                	test   %eax,%eax
  801829:	78 49                	js     801874 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80182b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801832:	75 23                	jne    801857 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801834:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801839:	8b 40 48             	mov    0x48(%eax),%eax
  80183c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801840:	89 44 24 04          	mov    %eax,0x4(%esp)
  801844:	c7 04 24 f0 35 80 00 	movl   $0x8035f0,(%esp)
  80184b:	e8 d4 ea ff ff       	call   800324 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801850:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801855:	eb 1d                	jmp    801874 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801857:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185a:	8b 52 18             	mov    0x18(%edx),%edx
  80185d:	85 d2                	test   %edx,%edx
  80185f:	74 0e                	je     80186f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801864:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801868:	89 04 24             	mov    %eax,(%esp)
  80186b:	ff d2                	call   *%edx
  80186d:	eb 05                	jmp    801874 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80186f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801874:	83 c4 24             	add    $0x24,%esp
  801877:	5b                   	pop    %ebx
  801878:	5d                   	pop    %ebp
  801879:	c3                   	ret    

0080187a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	53                   	push   %ebx
  80187e:	83 ec 24             	sub    $0x24,%esp
  801881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801884:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801887:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	89 04 24             	mov    %eax,(%esp)
  801891:	e8 30 fb ff ff       	call   8013c6 <fd_lookup>
  801896:	85 c0                	test   %eax,%eax
  801898:	78 52                	js     8018ec <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a4:	8b 00                	mov    (%eax),%eax
  8018a6:	89 04 24             	mov    %eax,(%esp)
  8018a9:	e8 6e fb ff ff       	call   80141c <dev_lookup>
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 3a                	js     8018ec <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018b9:	74 2c                	je     8018e7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018c5:	00 00 00 
	stat->st_isdir = 0;
  8018c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018cf:	00 00 00 
	stat->st_dev = dev;
  8018d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018df:	89 14 24             	mov    %edx,(%esp)
  8018e2:	ff 50 14             	call   *0x14(%eax)
  8018e5:	eb 05                	jmp    8018ec <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018e7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018ec:	83 c4 24             	add    $0x24,%esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801901:	00 
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
  801905:	89 04 24             	mov    %eax,(%esp)
  801908:	e8 2a 02 00 00       	call   801b37 <open>
  80190d:	89 c3                	mov    %eax,%ebx
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 1b                	js     80192e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801913:	8b 45 0c             	mov    0xc(%ebp),%eax
  801916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191a:	89 1c 24             	mov    %ebx,(%esp)
  80191d:	e8 58 ff ff ff       	call   80187a <fstat>
  801922:	89 c6                	mov    %eax,%esi
	close(fd);
  801924:	89 1c 24             	mov    %ebx,(%esp)
  801927:	e8 d2 fb ff ff       	call   8014fe <close>
	return r;
  80192c:	89 f3                	mov    %esi,%ebx
}
  80192e:	89 d8                	mov    %ebx,%eax
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	5b                   	pop    %ebx
  801934:	5e                   	pop    %esi
  801935:	5d                   	pop    %ebp
  801936:	c3                   	ret    
	...

00801938 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	83 ec 10             	sub    $0x10,%esp
  801940:	89 c3                	mov    %eax,%ebx
  801942:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801944:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80194b:	75 11                	jne    80195e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80194d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801954:	e8 d6 14 00 00       	call   802e2f <ipc_find_env>
  801959:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80195e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801965:	00 
  801966:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80196d:	00 
  80196e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801972:	a1 00 50 80 00       	mov    0x805000,%eax
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	e8 2d 14 00 00       	call   802dac <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80197f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801986:	00 
  801987:	89 74 24 04          	mov    %esi,0x4(%esp)
  80198b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801992:	e8 a5 13 00 00       	call   802d3c <ipc_recv>
}
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019aa:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8019c1:	e8 72 ff ff ff       	call   801938 <fsipc>
}
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8019d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019de:	b8 06 00 00 00       	mov    $0x6,%eax
  8019e3:	e8 50 ff ff ff       	call   801938 <fsipc>
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	53                   	push   %ebx
  8019ee:	83 ec 14             	sub    $0x14,%esp
  8019f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fa:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801a04:	b8 05 00 00 00       	mov    $0x5,%eax
  801a09:	e8 2a ff ff ff       	call   801938 <fsipc>
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 2b                	js     801a3d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a12:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a19:	00 
  801a1a:	89 1c 24             	mov    %ebx,(%esp)
  801a1d:	e8 ad ee ff ff       	call   8008cf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a22:	a1 80 60 80 00       	mov    0x806080,%eax
  801a27:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a2d:	a1 84 60 80 00       	mov    0x806084,%eax
  801a32:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a3d:	83 c4 14             	add    $0x14,%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    

00801a43 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	83 ec 18             	sub    $0x18,%esp
  801a49:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a4c:	8b 55 08             	mov    0x8(%ebp),%edx
  801a4f:	8b 52 0c             	mov    0xc(%edx),%edx
  801a52:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801a58:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801a5d:	89 c2                	mov    %eax,%edx
  801a5f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a64:	76 05                	jbe    801a6b <devfile_write+0x28>
  801a66:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801a6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a76:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801a7d:	e8 30 f0 ff ff       	call   800ab2 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801a82:	ba 00 00 00 00       	mov    $0x0,%edx
  801a87:	b8 04 00 00 00       	mov    $0x4,%eax
  801a8c:	e8 a7 fe ff ff       	call   801938 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	83 ec 10             	sub    $0x10,%esp
  801a9b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa4:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801aa9:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab4:	b8 03 00 00 00       	mov    $0x3,%eax
  801ab9:	e8 7a fe ff ff       	call   801938 <fsipc>
  801abe:	89 c3                	mov    %eax,%ebx
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	78 6a                	js     801b2e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ac4:	39 c6                	cmp    %eax,%esi
  801ac6:	73 24                	jae    801aec <devfile_read+0x59>
  801ac8:	c7 44 24 0c 60 36 80 	movl   $0x803660,0xc(%esp)
  801acf:	00 
  801ad0:	c7 44 24 08 67 36 80 	movl   $0x803667,0x8(%esp)
  801ad7:	00 
  801ad8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801adf:	00 
  801ae0:	c7 04 24 7c 36 80 00 	movl   $0x80367c,(%esp)
  801ae7:	e8 40 e7 ff ff       	call   80022c <_panic>
	assert(r <= PGSIZE);
  801aec:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801af1:	7e 24                	jle    801b17 <devfile_read+0x84>
  801af3:	c7 44 24 0c 87 36 80 	movl   $0x803687,0xc(%esp)
  801afa:	00 
  801afb:	c7 44 24 08 67 36 80 	movl   $0x803667,0x8(%esp)
  801b02:	00 
  801b03:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b0a:	00 
  801b0b:	c7 04 24 7c 36 80 00 	movl   $0x80367c,(%esp)
  801b12:	e8 15 e7 ff ff       	call   80022c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b17:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b1b:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b22:	00 
  801b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b26:	89 04 24             	mov    %eax,(%esp)
  801b29:	e8 1a ef ff ff       	call   800a48 <memmove>
	return r;
}
  801b2e:	89 d8                	mov    %ebx,%eax
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	5b                   	pop    %ebx
  801b34:	5e                   	pop    %esi
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    

00801b37 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 20             	sub    $0x20,%esp
  801b3f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b42:	89 34 24             	mov    %esi,(%esp)
  801b45:	e8 52 ed ff ff       	call   80089c <strlen>
  801b4a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b4f:	7f 60                	jg     801bb1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b54:	89 04 24             	mov    %eax,(%esp)
  801b57:	e8 17 f8 ff ff       	call   801373 <fd_alloc>
  801b5c:	89 c3                	mov    %eax,%ebx
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	78 54                	js     801bb6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b62:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b66:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801b6d:	e8 5d ed ff ff       	call   8008cf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b75:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b82:	e8 b1 fd ff ff       	call   801938 <fsipc>
  801b87:	89 c3                	mov    %eax,%ebx
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	79 15                	jns    801ba2 <open+0x6b>
		fd_close(fd, 0);
  801b8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b94:	00 
  801b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b98:	89 04 24             	mov    %eax,(%esp)
  801b9b:	e8 d6 f8 ff ff       	call   801476 <fd_close>
		return r;
  801ba0:	eb 14                	jmp    801bb6 <open+0x7f>
	}

	return fd2num(fd);
  801ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba5:	89 04 24             	mov    %eax,(%esp)
  801ba8:	e8 9b f7 ff ff       	call   801348 <fd2num>
  801bad:	89 c3                	mov    %eax,%ebx
  801baf:	eb 05                	jmp    801bb6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bb1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bb6:	89 d8                	mov    %ebx,%eax
  801bb8:	83 c4 20             	add    $0x20,%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bca:	b8 08 00 00 00       	mov    $0x8,%eax
  801bcf:	e8 64 fd ff ff       	call   801938 <fsipc>
}
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    
	...

00801bd8 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	57                   	push   %edi
  801bdc:	56                   	push   %esi
  801bdd:	53                   	push   %ebx
  801bde:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801be4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801beb:	00 
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
  801bef:	89 04 24             	mov    %eax,(%esp)
  801bf2:	e8 40 ff ff ff       	call   801b37 <open>
  801bf7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 88 a9 05 00 00    	js     8021ae <spawn+0x5d6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c05:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801c0c:	00 
  801c0d:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c17:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801c1d:	89 04 24             	mov    %eax,(%esp)
  801c20:	e8 cf fa ff ff       	call   8016f4 <readn>
  801c25:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c2a:	75 0c                	jne    801c38 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801c2c:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c33:	45 4c 46 
  801c36:	74 3b                	je     801c73 <spawn+0x9b>
		close(fd);
  801c38:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	e8 b8 f8 ff ff       	call   8014fe <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c46:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801c4d:	46 
  801c4e:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801c54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c58:	c7 04 24 93 36 80 00 	movl   $0x803693,(%esp)
  801c5f:	e8 c0 e6 ff ff       	call   800324 <cprintf>
		return -E_NOT_EXEC;
  801c64:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  801c6b:	ff ff ff 
  801c6e:	e9 47 05 00 00       	jmp    8021ba <spawn+0x5e2>
  801c73:	ba 07 00 00 00       	mov    $0x7,%edx
  801c78:	89 d0                	mov    %edx,%eax
  801c7a:	cd 30                	int    $0x30
  801c7c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c82:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	0f 88 2a 05 00 00    	js     8021ba <spawn+0x5e2>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c90:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c95:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801c9c:	c1 e0 07             	shl    $0x7,%eax
  801c9f:	29 d0                	sub    %edx,%eax
  801ca1:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801ca7:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cad:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cb2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cb4:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801cba:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cc0:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ccd:	eb 0d                	jmp    801cdc <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801ccf:	89 04 24             	mov    %eax,(%esp)
  801cd2:	e8 c5 eb ff ff       	call   80089c <strlen>
  801cd7:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cdb:	46                   	inc    %esi
  801cdc:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801cde:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ce5:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	75 e3                	jne    801ccf <spawn+0xf7>
  801cec:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801cf2:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801cf8:	bf 00 10 40 00       	mov    $0x401000,%edi
  801cfd:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801cff:	89 f8                	mov    %edi,%eax
  801d01:	83 e0 fc             	and    $0xfffffffc,%eax
  801d04:	f7 d2                	not    %edx
  801d06:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801d09:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d0f:	89 d0                	mov    %edx,%eax
  801d11:	83 e8 08             	sub    $0x8,%eax
  801d14:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d19:	0f 86 ac 04 00 00    	jbe    8021cb <spawn+0x5f3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d1f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d26:	00 
  801d27:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d2e:	00 
  801d2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d36:	e8 86 ef ff ff       	call   800cc1 <sys_page_alloc>
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	0f 88 8d 04 00 00    	js     8021d0 <spawn+0x5f8>
  801d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d48:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801d4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d51:	eb 2e                	jmp    801d81 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d53:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d59:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d5f:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801d62:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d69:	89 3c 24             	mov    %edi,(%esp)
  801d6c:	e8 5e eb ff ff       	call   8008cf <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d71:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801d74:	89 04 24             	mov    %eax,(%esp)
  801d77:	e8 20 eb ff ff       	call   80089c <strlen>
  801d7c:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d80:	43                   	inc    %ebx
  801d81:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d87:	7c ca                	jl     801d53 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d89:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d8f:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801d95:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d9c:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801da2:	74 24                	je     801dc8 <spawn+0x1f0>
  801da4:	c7 44 24 0c f0 36 80 	movl   $0x8036f0,0xc(%esp)
  801dab:	00 
  801dac:	c7 44 24 08 67 36 80 	movl   $0x803667,0x8(%esp)
  801db3:	00 
  801db4:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801dbb:	00 
  801dbc:	c7 04 24 ad 36 80 00 	movl   $0x8036ad,(%esp)
  801dc3:	e8 64 e4 ff ff       	call   80022c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801dc8:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dce:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801dd3:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801dd9:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801ddc:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801de2:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801dec:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801df2:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801df9:	00 
  801dfa:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801e01:	ee 
  801e02:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e08:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e0c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e13:	00 
  801e14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1b:	e8 f5 ee ff ff       	call   800d15 <sys_page_map>
  801e20:	89 c3                	mov    %eax,%ebx
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 1a                	js     801e40 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e26:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e2d:	00 
  801e2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e35:	e8 2e ef ff ff       	call   800d68 <sys_page_unmap>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	79 1f                	jns    801e5f <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e40:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e47:	00 
  801e48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4f:	e8 14 ef ff ff       	call   800d68 <sys_page_unmap>
	return r;
  801e54:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801e5a:	e9 5b 03 00 00       	jmp    8021ba <spawn+0x5e2>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e5f:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801e65:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801e6b:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e71:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801e78:	00 00 00 
  801e7b:	e9 bb 01 00 00       	jmp    80203b <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801e80:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e86:	83 38 01             	cmpl   $0x1,(%eax)
  801e89:	0f 85 9f 01 00 00    	jne    80202e <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e8f:	89 c2                	mov    %eax,%edx
  801e91:	8b 40 18             	mov    0x18(%eax),%eax
  801e94:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801e97:	83 f8 01             	cmp    $0x1,%eax
  801e9a:	19 c0                	sbb    %eax,%eax
  801e9c:	83 e0 fe             	and    $0xfffffffe,%eax
  801e9f:	83 c0 07             	add    $0x7,%eax
  801ea2:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ea8:	8b 52 04             	mov    0x4(%edx),%edx
  801eab:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801eb1:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801eb7:	8b 40 10             	mov    0x10(%eax),%eax
  801eba:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ec0:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801ec6:	8b 52 14             	mov    0x14(%edx),%edx
  801ec9:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801ecf:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ed5:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ed8:	89 f8                	mov    %edi,%eax
  801eda:	25 ff 0f 00 00       	and    $0xfff,%eax
  801edf:	74 16                	je     801ef7 <spawn+0x31f>
		va -= i;
  801ee1:	29 c7                	sub    %eax,%edi
		memsz += i;
  801ee3:	01 c2                	add    %eax,%edx
  801ee5:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801eeb:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801ef1:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801efc:	e9 1f 01 00 00       	jmp    802020 <spawn+0x448>
		if (i >= filesz) {
  801f01:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  801f07:	72 2b                	jb     801f34 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f09:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801f0f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f13:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f17:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f1d:	89 04 24             	mov    %eax,(%esp)
  801f20:	e8 9c ed ff ff       	call   800cc1 <sys_page_alloc>
  801f25:	85 c0                	test   %eax,%eax
  801f27:	0f 89 e7 00 00 00    	jns    802014 <spawn+0x43c>
  801f2d:	89 c6                	mov    %eax,%esi
  801f2f:	e9 56 02 00 00       	jmp    80218a <spawn+0x5b2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f34:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801f3b:	00 
  801f3c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f43:	00 
  801f44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4b:	e8 71 ed ff ff       	call   800cc1 <sys_page_alloc>
  801f50:	85 c0                	test   %eax,%eax
  801f52:	0f 88 28 02 00 00    	js     802180 <spawn+0x5a8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801f58:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801f5e:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f64:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f6a:	89 04 24             	mov    %eax,(%esp)
  801f6d:	e8 58 f8 ff ff       	call   8017ca <seek>
  801f72:	85 c0                	test   %eax,%eax
  801f74:	0f 88 0a 02 00 00    	js     802184 <spawn+0x5ac>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801f7a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f80:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f82:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f87:	76 05                	jbe    801f8e <spawn+0x3b6>
  801f89:	b8 00 10 00 00       	mov    $0x1000,%eax
  801f8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f92:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f99:	00 
  801f9a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801fa0:	89 04 24             	mov    %eax,(%esp)
  801fa3:	e8 4c f7 ff ff       	call   8016f4 <readn>
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	0f 88 d8 01 00 00    	js     802188 <spawn+0x5b0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fb0:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801fb6:	89 54 24 10          	mov    %edx,0x10(%esp)
  801fba:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fbe:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801fc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fc8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fcf:	00 
  801fd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd7:	e8 39 ed ff ff       	call   800d15 <sys_page_map>
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	79 20                	jns    802000 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801fe0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fe4:	c7 44 24 08 b9 36 80 	movl   $0x8036b9,0x8(%esp)
  801feb:	00 
  801fec:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801ff3:	00 
  801ff4:	c7 04 24 ad 36 80 00 	movl   $0x8036ad,(%esp)
  801ffb:	e8 2c e2 ff ff       	call   80022c <_panic>
			sys_page_unmap(0, UTEMP);
  802000:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802007:	00 
  802008:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200f:	e8 54 ed ff ff       	call   800d68 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802014:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80201a:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802020:	89 de                	mov    %ebx,%esi
  802022:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  802028:	0f 82 d3 fe ff ff    	jb     801f01 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80202e:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802034:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  80203b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802042:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  802048:	0f 8c 32 fe ff ff    	jl     801e80 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80204e:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802054:	89 04 24             	mov    %eax,(%esp)
  802057:	e8 a2 f4 ff ff       	call   8014fe <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  80205c:	be 00 00 00 00       	mov    $0x0,%esi
  802061:	eb 0c                	jmp    80206f <spawn+0x497>
	{
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  802063:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  802069:	0f 84 91 00 00 00    	je     802100 <spawn+0x528>
  80206f:	89 f0                	mov    %esi,%eax
  802071:	c1 e8 16             	shr    $0x16,%eax
  802074:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80207b:	a8 01                	test   $0x1,%al
  80207d:	74 6f                	je     8020ee <spawn+0x516>
  80207f:	89 f0                	mov    %esi,%eax
  802081:	c1 e8 0c             	shr    $0xc,%eax
  802084:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80208b:	f6 c2 01             	test   $0x1,%dl
  80208e:	74 5e                	je     8020ee <spawn+0x516>
		{
			continue;
		}
		if ((uvpt[PGNUM(addr)] & PTE_SHARE))
  802090:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802097:	f6 c6 04             	test   $0x4,%dh
  80209a:	74 52                	je     8020ee <spawn+0x516>
		{
			if ((e = sys_page_map(0, (void *)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80209c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8020a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8020b0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8020b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c5:	e8 4b ec ff ff       	call   800d15 <sys_page_map>
  8020ca:	85 c0                	test   %eax,%eax
  8020cc:	79 20                	jns    8020ee <spawn+0x516>
			{
				panic("duppage error: %e", e);
  8020ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020d2:	c7 44 24 08 8e 35 80 	movl   $0x80358e,0x8(%esp)
  8020d9:	00 
  8020da:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  8020e1:	00 
  8020e2:	c7 04 24 ad 36 80 00 	movl   $0x8036ad,(%esp)
  8020e9:	e8 3e e1 ff ff       	call   80022c <_panic>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  8020ee:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8020f4:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  8020fa:	0f 85 63 ff ff ff    	jne    802063 <spawn+0x48b>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802100:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802107:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80210a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802110:	89 44 24 04          	mov    %eax,0x4(%esp)
  802114:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80211a:	89 04 24             	mov    %eax,(%esp)
  80211d:	e8 ec ec ff ff       	call   800e0e <sys_env_set_trapframe>
  802122:	85 c0                	test   %eax,%eax
  802124:	79 20                	jns    802146 <spawn+0x56e>
		panic("sys_env_set_trapframe: %e", r);
  802126:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80212a:	c7 44 24 08 d6 36 80 	movl   $0x8036d6,0x8(%esp)
  802131:	00 
  802132:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802139:	00 
  80213a:	c7 04 24 ad 36 80 00 	movl   $0x8036ad,(%esp)
  802141:	e8 e6 e0 ff ff       	call   80022c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802146:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80214d:	00 
  80214e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802154:	89 04 24             	mov    %eax,(%esp)
  802157:	e8 5f ec ff ff       	call   800dbb <sys_env_set_status>
  80215c:	85 c0                	test   %eax,%eax
  80215e:	79 5a                	jns    8021ba <spawn+0x5e2>
		panic("sys_env_set_status: %e", r);
  802160:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802164:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  80216b:	00 
  80216c:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  802173:	00 
  802174:	c7 04 24 ad 36 80 00 	movl   $0x8036ad,(%esp)
  80217b:	e8 ac e0 ff ff       	call   80022c <_panic>
  802180:	89 c6                	mov    %eax,%esi
  802182:	eb 06                	jmp    80218a <spawn+0x5b2>
  802184:	89 c6                	mov    %eax,%esi
  802186:	eb 02                	jmp    80218a <spawn+0x5b2>
  802188:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  80218a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802190:	89 04 24             	mov    %eax,(%esp)
  802193:	e8 99 ea ff ff       	call   800c31 <sys_env_destroy>
	close(fd);
  802198:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80219e:	89 04 24             	mov    %eax,(%esp)
  8021a1:	e8 58 f3 ff ff       	call   8014fe <close>
	return r;
  8021a6:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  8021ac:	eb 0c                	jmp    8021ba <spawn+0x5e2>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8021ae:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8021b4:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021ba:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8021c0:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  8021c6:	5b                   	pop    %ebx
  8021c7:	5e                   	pop    %esi
  8021c8:	5f                   	pop    %edi
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8021cb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  8021d0:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8021d6:	eb e2                	jmp    8021ba <spawn+0x5e2>

008021d8 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	57                   	push   %edi
  8021dc:	56                   	push   %esi
  8021dd:	53                   	push   %ebx
  8021de:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  8021e1:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021e4:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021e9:	eb 03                	jmp    8021ee <spawnl+0x16>
		argc++;
  8021eb:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021ec:	89 d0                	mov    %edx,%eax
  8021ee:	8d 50 04             	lea    0x4(%eax),%edx
  8021f1:	83 38 00             	cmpl   $0x0,(%eax)
  8021f4:	75 f5                	jne    8021eb <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021f6:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8021fd:	83 e0 f0             	and    $0xfffffff0,%eax
  802200:	29 c4                	sub    %eax,%esp
  802202:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802206:	83 e7 f0             	and    $0xfffffff0,%edi
  802209:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  80220b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220e:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802210:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802217:	00 

	va_start(vl, arg0);
  802218:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
  802220:	eb 09                	jmp    80222b <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802222:	40                   	inc    %eax
  802223:	8b 1a                	mov    (%edx),%ebx
  802225:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802228:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80222b:	39 c8                	cmp    %ecx,%eax
  80222d:	75 f3                	jne    802222 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80222f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802233:	8b 45 08             	mov    0x8(%ebp),%eax
  802236:	89 04 24             	mov    %eax,(%esp)
  802239:	e8 9a f9 ff ff       	call   801bd8 <spawn>
}
  80223e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802241:	5b                   	pop    %ebx
  802242:	5e                   	pop    %esi
  802243:	5f                   	pop    %edi
  802244:	5d                   	pop    %ebp
  802245:	c3                   	ret    
	...

00802248 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  80224e:	c7 44 24 04 18 37 80 	movl   $0x803718,0x4(%esp)
  802255:	00 
  802256:	8b 45 0c             	mov    0xc(%ebp),%eax
  802259:	89 04 24             	mov    %eax,(%esp)
  80225c:	e8 6e e6 ff ff       	call   8008cf <strcpy>
	return 0;
}
  802261:	b8 00 00 00 00       	mov    $0x0,%eax
  802266:	c9                   	leave  
  802267:	c3                   	ret    

00802268 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	53                   	push   %ebx
  80226c:	83 ec 14             	sub    $0x14,%esp
  80226f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802272:	89 1c 24             	mov    %ebx,(%esp)
  802275:	e8 fa 0b 00 00       	call   802e74 <pageref>
  80227a:	83 f8 01             	cmp    $0x1,%eax
  80227d:	75 0d                	jne    80228c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80227f:	8b 43 0c             	mov    0xc(%ebx),%eax
  802282:	89 04 24             	mov    %eax,(%esp)
  802285:	e8 1f 03 00 00       	call   8025a9 <nsipc_close>
  80228a:	eb 05                	jmp    802291 <devsock_close+0x29>
	else
		return 0;
  80228c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802291:	83 c4 14             	add    $0x14,%esp
  802294:	5b                   	pop    %ebx
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    

00802297 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80229d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8022a4:	00 
  8022a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8022a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8022b9:	89 04 24             	mov    %eax,(%esp)
  8022bc:	e8 e3 03 00 00       	call   8026a4 <nsipc_send>
}
  8022c1:	c9                   	leave  
  8022c2:	c3                   	ret    

008022c3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8022c3:	55                   	push   %ebp
  8022c4:	89 e5                	mov    %esp,%ebp
  8022c6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8022c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8022d0:	00 
  8022d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8022d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022df:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8022e5:	89 04 24             	mov    %eax,(%esp)
  8022e8:	e8 37 03 00 00       	call   802624 <nsipc_recv>
}
  8022ed:	c9                   	leave  
  8022ee:	c3                   	ret    

008022ef <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8022ef:	55                   	push   %ebp
  8022f0:	89 e5                	mov    %esp,%ebp
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 20             	sub    $0x20,%esp
  8022f7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8022f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fc:	89 04 24             	mov    %eax,(%esp)
  8022ff:	e8 6f f0 ff ff       	call   801373 <fd_alloc>
  802304:	89 c3                	mov    %eax,%ebx
  802306:	85 c0                	test   %eax,%eax
  802308:	78 21                	js     80232b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80230a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802311:	00 
  802312:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802315:	89 44 24 04          	mov    %eax,0x4(%esp)
  802319:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802320:	e8 9c e9 ff ff       	call   800cc1 <sys_page_alloc>
  802325:	89 c3                	mov    %eax,%ebx
  802327:	85 c0                	test   %eax,%eax
  802329:	79 0a                	jns    802335 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80232b:	89 34 24             	mov    %esi,(%esp)
  80232e:	e8 76 02 00 00       	call   8025a9 <nsipc_close>
		return r;
  802333:	eb 22                	jmp    802357 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802335:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80233b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802343:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80234a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80234d:	89 04 24             	mov    %eax,(%esp)
  802350:	e8 f3 ef ff ff       	call   801348 <fd2num>
  802355:	89 c3                	mov    %eax,%ebx
}
  802357:	89 d8                	mov    %ebx,%eax
  802359:	83 c4 20             	add    $0x20,%esp
  80235c:	5b                   	pop    %ebx
  80235d:	5e                   	pop    %esi
  80235e:	5d                   	pop    %ebp
  80235f:	c3                   	ret    

00802360 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
  802363:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802366:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802369:	89 54 24 04          	mov    %edx,0x4(%esp)
  80236d:	89 04 24             	mov    %eax,(%esp)
  802370:	e8 51 f0 ff ff       	call   8013c6 <fd_lookup>
  802375:	85 c0                	test   %eax,%eax
  802377:	78 17                	js     802390 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802379:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237c:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802382:	39 10                	cmp    %edx,(%eax)
  802384:	75 05                	jne    80238b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802386:	8b 40 0c             	mov    0xc(%eax),%eax
  802389:	eb 05                	jmp    802390 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80238b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802390:	c9                   	leave  
  802391:	c3                   	ret    

00802392 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802398:	8b 45 08             	mov    0x8(%ebp),%eax
  80239b:	e8 c0 ff ff ff       	call   802360 <fd2sockid>
  8023a0:	85 c0                	test   %eax,%eax
  8023a2:	78 1f                	js     8023c3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8023a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8023a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023b2:	89 04 24             	mov    %eax,(%esp)
  8023b5:	e8 38 01 00 00       	call   8024f2 <nsipc_accept>
  8023ba:	85 c0                	test   %eax,%eax
  8023bc:	78 05                	js     8023c3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8023be:	e8 2c ff ff ff       	call   8022ef <alloc_sockfd>
}
  8023c3:	c9                   	leave  
  8023c4:	c3                   	ret    

008023c5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023c5:	55                   	push   %ebp
  8023c6:	89 e5                	mov    %esp,%ebp
  8023c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ce:	e8 8d ff ff ff       	call   802360 <fd2sockid>
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	78 16                	js     8023ed <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8023d7:	8b 55 10             	mov    0x10(%ebp),%edx
  8023da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e5:	89 04 24             	mov    %eax,(%esp)
  8023e8:	e8 5b 01 00 00       	call   802548 <nsipc_bind>
}
  8023ed:	c9                   	leave  
  8023ee:	c3                   	ret    

008023ef <shutdown>:

int
shutdown(int s, int how)
{
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f8:	e8 63 ff ff ff       	call   802360 <fd2sockid>
  8023fd:	85 c0                	test   %eax,%eax
  8023ff:	78 0f                	js     802410 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802401:	8b 55 0c             	mov    0xc(%ebp),%edx
  802404:	89 54 24 04          	mov    %edx,0x4(%esp)
  802408:	89 04 24             	mov    %eax,(%esp)
  80240b:	e8 77 01 00 00       	call   802587 <nsipc_shutdown>
}
  802410:	c9                   	leave  
  802411:	c3                   	ret    

00802412 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802412:	55                   	push   %ebp
  802413:	89 e5                	mov    %esp,%ebp
  802415:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802418:	8b 45 08             	mov    0x8(%ebp),%eax
  80241b:	e8 40 ff ff ff       	call   802360 <fd2sockid>
  802420:	85 c0                	test   %eax,%eax
  802422:	78 16                	js     80243a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802424:	8b 55 10             	mov    0x10(%ebp),%edx
  802427:	89 54 24 08          	mov    %edx,0x8(%esp)
  80242b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80242e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802432:	89 04 24             	mov    %eax,(%esp)
  802435:	e8 89 01 00 00       	call   8025c3 <nsipc_connect>
}
  80243a:	c9                   	leave  
  80243b:	c3                   	ret    

0080243c <listen>:

int
listen(int s, int backlog)
{
  80243c:	55                   	push   %ebp
  80243d:	89 e5                	mov    %esp,%ebp
  80243f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802442:	8b 45 08             	mov    0x8(%ebp),%eax
  802445:	e8 16 ff ff ff       	call   802360 <fd2sockid>
  80244a:	85 c0                	test   %eax,%eax
  80244c:	78 0f                	js     80245d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80244e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802451:	89 54 24 04          	mov    %edx,0x4(%esp)
  802455:	89 04 24             	mov    %eax,(%esp)
  802458:	e8 a5 01 00 00       	call   802602 <nsipc_listen>
}
  80245d:	c9                   	leave  
  80245e:	c3                   	ret    

0080245f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802465:	8b 45 10             	mov    0x10(%ebp),%eax
  802468:	89 44 24 08          	mov    %eax,0x8(%esp)
  80246c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80246f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802473:	8b 45 08             	mov    0x8(%ebp),%eax
  802476:	89 04 24             	mov    %eax,(%esp)
  802479:	e8 99 02 00 00       	call   802717 <nsipc_socket>
  80247e:	85 c0                	test   %eax,%eax
  802480:	78 05                	js     802487 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802482:	e8 68 fe ff ff       	call   8022ef <alloc_sockfd>
}
  802487:	c9                   	leave  
  802488:	c3                   	ret    
  802489:	00 00                	add    %al,(%eax)
	...

0080248c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80248c:	55                   	push   %ebp
  80248d:	89 e5                	mov    %esp,%ebp
  80248f:	53                   	push   %ebx
  802490:	83 ec 14             	sub    $0x14,%esp
  802493:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802495:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80249c:	75 11                	jne    8024af <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80249e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8024a5:	e8 85 09 00 00       	call   802e2f <ipc_find_env>
  8024aa:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8024af:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8024b6:	00 
  8024b7:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8024be:	00 
  8024bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024c3:	a1 04 50 80 00       	mov    0x805004,%eax
  8024c8:	89 04 24             	mov    %eax,(%esp)
  8024cb:	e8 dc 08 00 00       	call   802dac <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8024d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024d7:	00 
  8024d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8024df:	00 
  8024e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024e7:	e8 50 08 00 00       	call   802d3c <ipc_recv>
}
  8024ec:	83 c4 14             	add    $0x14,%esp
  8024ef:	5b                   	pop    %ebx
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    

008024f2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024f2:	55                   	push   %ebp
  8024f3:	89 e5                	mov    %esp,%ebp
  8024f5:	56                   	push   %esi
  8024f6:	53                   	push   %ebx
  8024f7:	83 ec 10             	sub    $0x10,%esp
  8024fa:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8024fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802500:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802505:	8b 06                	mov    (%esi),%eax
  802507:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80250c:	b8 01 00 00 00       	mov    $0x1,%eax
  802511:	e8 76 ff ff ff       	call   80248c <nsipc>
  802516:	89 c3                	mov    %eax,%ebx
  802518:	85 c0                	test   %eax,%eax
  80251a:	78 23                	js     80253f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80251c:	a1 10 70 80 00       	mov    0x807010,%eax
  802521:	89 44 24 08          	mov    %eax,0x8(%esp)
  802525:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80252c:	00 
  80252d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802530:	89 04 24             	mov    %eax,(%esp)
  802533:	e8 10 e5 ff ff       	call   800a48 <memmove>
		*addrlen = ret->ret_addrlen;
  802538:	a1 10 70 80 00       	mov    0x807010,%eax
  80253d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  80253f:	89 d8                	mov    %ebx,%eax
  802541:	83 c4 10             	add    $0x10,%esp
  802544:	5b                   	pop    %ebx
  802545:	5e                   	pop    %esi
  802546:	5d                   	pop    %ebp
  802547:	c3                   	ret    

00802548 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802548:	55                   	push   %ebp
  802549:	89 e5                	mov    %esp,%ebp
  80254b:	53                   	push   %ebx
  80254c:	83 ec 14             	sub    $0x14,%esp
  80254f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802552:	8b 45 08             	mov    0x8(%ebp),%eax
  802555:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80255a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80255e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802561:	89 44 24 04          	mov    %eax,0x4(%esp)
  802565:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80256c:	e8 d7 e4 ff ff       	call   800a48 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802571:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802577:	b8 02 00 00 00       	mov    $0x2,%eax
  80257c:	e8 0b ff ff ff       	call   80248c <nsipc>
}
  802581:	83 c4 14             	add    $0x14,%esp
  802584:	5b                   	pop    %ebx
  802585:	5d                   	pop    %ebp
  802586:	c3                   	ret    

00802587 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802587:	55                   	push   %ebp
  802588:	89 e5                	mov    %esp,%ebp
  80258a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80258d:	8b 45 08             	mov    0x8(%ebp),%eax
  802590:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802595:	8b 45 0c             	mov    0xc(%ebp),%eax
  802598:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80259d:	b8 03 00 00 00       	mov    $0x3,%eax
  8025a2:	e8 e5 fe ff ff       	call   80248c <nsipc>
}
  8025a7:	c9                   	leave  
  8025a8:	c3                   	ret    

008025a9 <nsipc_close>:

int
nsipc_close(int s)
{
  8025a9:	55                   	push   %ebp
  8025aa:	89 e5                	mov    %esp,%ebp
  8025ac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8025af:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8025b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8025bc:	e8 cb fe ff ff       	call   80248c <nsipc>
}
  8025c1:	c9                   	leave  
  8025c2:	c3                   	ret    

008025c3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025c3:	55                   	push   %ebp
  8025c4:	89 e5                	mov    %esp,%ebp
  8025c6:	53                   	push   %ebx
  8025c7:	83 ec 14             	sub    $0x14,%esp
  8025ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8025cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8025d5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e0:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8025e7:	e8 5c e4 ff ff       	call   800a48 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8025ec:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8025f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8025f7:	e8 90 fe ff ff       	call   80248c <nsipc>
}
  8025fc:	83 c4 14             	add    $0x14,%esp
  8025ff:	5b                   	pop    %ebx
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    

00802602 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802602:	55                   	push   %ebp
  802603:	89 e5                	mov    %esp,%ebp
  802605:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802608:	8b 45 08             	mov    0x8(%ebp),%eax
  80260b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802610:	8b 45 0c             	mov    0xc(%ebp),%eax
  802613:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802618:	b8 06 00 00 00       	mov    $0x6,%eax
  80261d:	e8 6a fe ff ff       	call   80248c <nsipc>
}
  802622:	c9                   	leave  
  802623:	c3                   	ret    

00802624 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802624:	55                   	push   %ebp
  802625:	89 e5                	mov    %esp,%ebp
  802627:	56                   	push   %esi
  802628:	53                   	push   %ebx
  802629:	83 ec 10             	sub    $0x10,%esp
  80262c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80262f:	8b 45 08             	mov    0x8(%ebp),%eax
  802632:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802637:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80263d:	8b 45 14             	mov    0x14(%ebp),%eax
  802640:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802645:	b8 07 00 00 00       	mov    $0x7,%eax
  80264a:	e8 3d fe ff ff       	call   80248c <nsipc>
  80264f:	89 c3                	mov    %eax,%ebx
  802651:	85 c0                	test   %eax,%eax
  802653:	78 46                	js     80269b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802655:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80265a:	7f 04                	jg     802660 <nsipc_recv+0x3c>
  80265c:	39 c6                	cmp    %eax,%esi
  80265e:	7d 24                	jge    802684 <nsipc_recv+0x60>
  802660:	c7 44 24 0c 24 37 80 	movl   $0x803724,0xc(%esp)
  802667:	00 
  802668:	c7 44 24 08 67 36 80 	movl   $0x803667,0x8(%esp)
  80266f:	00 
  802670:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802677:	00 
  802678:	c7 04 24 39 37 80 00 	movl   $0x803739,(%esp)
  80267f:	e8 a8 db ff ff       	call   80022c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802684:	89 44 24 08          	mov    %eax,0x8(%esp)
  802688:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80268f:	00 
  802690:	8b 45 0c             	mov    0xc(%ebp),%eax
  802693:	89 04 24             	mov    %eax,(%esp)
  802696:	e8 ad e3 ff ff       	call   800a48 <memmove>
	}

	return r;
}
  80269b:	89 d8                	mov    %ebx,%eax
  80269d:	83 c4 10             	add    $0x10,%esp
  8026a0:	5b                   	pop    %ebx
  8026a1:	5e                   	pop    %esi
  8026a2:	5d                   	pop    %ebp
  8026a3:	c3                   	ret    

008026a4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8026a4:	55                   	push   %ebp
  8026a5:	89 e5                	mov    %esp,%ebp
  8026a7:	53                   	push   %ebx
  8026a8:	83 ec 14             	sub    $0x14,%esp
  8026ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8026ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b1:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8026b6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8026bc:	7e 24                	jle    8026e2 <nsipc_send+0x3e>
  8026be:	c7 44 24 0c 45 37 80 	movl   $0x803745,0xc(%esp)
  8026c5:	00 
  8026c6:	c7 44 24 08 67 36 80 	movl   $0x803667,0x8(%esp)
  8026cd:	00 
  8026ce:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8026d5:	00 
  8026d6:	c7 04 24 39 37 80 00 	movl   $0x803739,(%esp)
  8026dd:	e8 4a db ff ff       	call   80022c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8026e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ed:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8026f4:	e8 4f e3 ff ff       	call   800a48 <memmove>
	nsipcbuf.send.req_size = size;
  8026f9:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8026ff:	8b 45 14             	mov    0x14(%ebp),%eax
  802702:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802707:	b8 08 00 00 00       	mov    $0x8,%eax
  80270c:	e8 7b fd ff ff       	call   80248c <nsipc>
}
  802711:	83 c4 14             	add    $0x14,%esp
  802714:	5b                   	pop    %ebx
  802715:	5d                   	pop    %ebp
  802716:	c3                   	ret    

00802717 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802717:	55                   	push   %ebp
  802718:	89 e5                	mov    %esp,%ebp
  80271a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80271d:	8b 45 08             	mov    0x8(%ebp),%eax
  802720:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802725:	8b 45 0c             	mov    0xc(%ebp),%eax
  802728:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80272d:	8b 45 10             	mov    0x10(%ebp),%eax
  802730:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802735:	b8 09 00 00 00       	mov    $0x9,%eax
  80273a:	e8 4d fd ff ff       	call   80248c <nsipc>
}
  80273f:	c9                   	leave  
  802740:	c3                   	ret    
  802741:	00 00                	add    %al,(%eax)
	...

00802744 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802744:	55                   	push   %ebp
  802745:	89 e5                	mov    %esp,%ebp
  802747:	56                   	push   %esi
  802748:	53                   	push   %ebx
  802749:	83 ec 10             	sub    $0x10,%esp
  80274c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80274f:	8b 45 08             	mov    0x8(%ebp),%eax
  802752:	89 04 24             	mov    %eax,(%esp)
  802755:	e8 fe eb ff ff       	call   801358 <fd2data>
  80275a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80275c:	c7 44 24 04 51 37 80 	movl   $0x803751,0x4(%esp)
  802763:	00 
  802764:	89 34 24             	mov    %esi,(%esp)
  802767:	e8 63 e1 ff ff       	call   8008cf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80276c:	8b 43 04             	mov    0x4(%ebx),%eax
  80276f:	2b 03                	sub    (%ebx),%eax
  802771:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802777:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80277e:	00 00 00 
	stat->st_dev = &devpipe;
  802781:	c7 86 88 00 00 00 44 	movl   $0x804044,0x88(%esi)
  802788:	40 80 00 
	return 0;
}
  80278b:	b8 00 00 00 00       	mov    $0x0,%eax
  802790:	83 c4 10             	add    $0x10,%esp
  802793:	5b                   	pop    %ebx
  802794:	5e                   	pop    %esi
  802795:	5d                   	pop    %ebp
  802796:	c3                   	ret    

00802797 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802797:	55                   	push   %ebp
  802798:	89 e5                	mov    %esp,%ebp
  80279a:	53                   	push   %ebx
  80279b:	83 ec 14             	sub    $0x14,%esp
  80279e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8027a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8027a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027ac:	e8 b7 e5 ff ff       	call   800d68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8027b1:	89 1c 24             	mov    %ebx,(%esp)
  8027b4:	e8 9f eb ff ff       	call   801358 <fd2data>
  8027b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027c4:	e8 9f e5 ff ff       	call   800d68 <sys_page_unmap>
}
  8027c9:	83 c4 14             	add    $0x14,%esp
  8027cc:	5b                   	pop    %ebx
  8027cd:	5d                   	pop    %ebp
  8027ce:	c3                   	ret    

008027cf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8027cf:	55                   	push   %ebp
  8027d0:	89 e5                	mov    %esp,%ebp
  8027d2:	57                   	push   %edi
  8027d3:	56                   	push   %esi
  8027d4:	53                   	push   %ebx
  8027d5:	83 ec 2c             	sub    $0x2c,%esp
  8027d8:	89 c7                	mov    %eax,%edi
  8027da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8027dd:	a1 08 50 80 00       	mov    0x805008,%eax
  8027e2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8027e5:	89 3c 24             	mov    %edi,(%esp)
  8027e8:	e8 87 06 00 00       	call   802e74 <pageref>
  8027ed:	89 c6                	mov    %eax,%esi
  8027ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027f2:	89 04 24             	mov    %eax,(%esp)
  8027f5:	e8 7a 06 00 00       	call   802e74 <pageref>
  8027fa:	39 c6                	cmp    %eax,%esi
  8027fc:	0f 94 c0             	sete   %al
  8027ff:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802802:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802808:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80280b:	39 cb                	cmp    %ecx,%ebx
  80280d:	75 08                	jne    802817 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80280f:	83 c4 2c             	add    $0x2c,%esp
  802812:	5b                   	pop    %ebx
  802813:	5e                   	pop    %esi
  802814:	5f                   	pop    %edi
  802815:	5d                   	pop    %ebp
  802816:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802817:	83 f8 01             	cmp    $0x1,%eax
  80281a:	75 c1                	jne    8027dd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80281c:	8b 42 58             	mov    0x58(%edx),%eax
  80281f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802826:	00 
  802827:	89 44 24 08          	mov    %eax,0x8(%esp)
  80282b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80282f:	c7 04 24 58 37 80 00 	movl   $0x803758,(%esp)
  802836:	e8 e9 da ff ff       	call   800324 <cprintf>
  80283b:	eb a0                	jmp    8027dd <_pipeisclosed+0xe>

0080283d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80283d:	55                   	push   %ebp
  80283e:	89 e5                	mov    %esp,%ebp
  802840:	57                   	push   %edi
  802841:	56                   	push   %esi
  802842:	53                   	push   %ebx
  802843:	83 ec 1c             	sub    $0x1c,%esp
  802846:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802849:	89 34 24             	mov    %esi,(%esp)
  80284c:	e8 07 eb ff ff       	call   801358 <fd2data>
  802851:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802853:	bf 00 00 00 00       	mov    $0x0,%edi
  802858:	eb 3c                	jmp    802896 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80285a:	89 da                	mov    %ebx,%edx
  80285c:	89 f0                	mov    %esi,%eax
  80285e:	e8 6c ff ff ff       	call   8027cf <_pipeisclosed>
  802863:	85 c0                	test   %eax,%eax
  802865:	75 38                	jne    80289f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802867:	e8 36 e4 ff ff       	call   800ca2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80286c:	8b 43 04             	mov    0x4(%ebx),%eax
  80286f:	8b 13                	mov    (%ebx),%edx
  802871:	83 c2 20             	add    $0x20,%edx
  802874:	39 d0                	cmp    %edx,%eax
  802876:	73 e2                	jae    80285a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802878:	8b 55 0c             	mov    0xc(%ebp),%edx
  80287b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80287e:	89 c2                	mov    %eax,%edx
  802880:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802886:	79 05                	jns    80288d <devpipe_write+0x50>
  802888:	4a                   	dec    %edx
  802889:	83 ca e0             	or     $0xffffffe0,%edx
  80288c:	42                   	inc    %edx
  80288d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802891:	40                   	inc    %eax
  802892:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802895:	47                   	inc    %edi
  802896:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802899:	75 d1                	jne    80286c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80289b:	89 f8                	mov    %edi,%eax
  80289d:	eb 05                	jmp    8028a4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80289f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8028a4:	83 c4 1c             	add    $0x1c,%esp
  8028a7:	5b                   	pop    %ebx
  8028a8:	5e                   	pop    %esi
  8028a9:	5f                   	pop    %edi
  8028aa:	5d                   	pop    %ebp
  8028ab:	c3                   	ret    

008028ac <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8028ac:	55                   	push   %ebp
  8028ad:	89 e5                	mov    %esp,%ebp
  8028af:	57                   	push   %edi
  8028b0:	56                   	push   %esi
  8028b1:	53                   	push   %ebx
  8028b2:	83 ec 1c             	sub    $0x1c,%esp
  8028b5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8028b8:	89 3c 24             	mov    %edi,(%esp)
  8028bb:	e8 98 ea ff ff       	call   801358 <fd2data>
  8028c0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028c2:	be 00 00 00 00       	mov    $0x0,%esi
  8028c7:	eb 3a                	jmp    802903 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8028c9:	85 f6                	test   %esi,%esi
  8028cb:	74 04                	je     8028d1 <devpipe_read+0x25>
				return i;
  8028cd:	89 f0                	mov    %esi,%eax
  8028cf:	eb 40                	jmp    802911 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8028d1:	89 da                	mov    %ebx,%edx
  8028d3:	89 f8                	mov    %edi,%eax
  8028d5:	e8 f5 fe ff ff       	call   8027cf <_pipeisclosed>
  8028da:	85 c0                	test   %eax,%eax
  8028dc:	75 2e                	jne    80290c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8028de:	e8 bf e3 ff ff       	call   800ca2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8028e3:	8b 03                	mov    (%ebx),%eax
  8028e5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8028e8:	74 df                	je     8028c9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8028ea:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8028ef:	79 05                	jns    8028f6 <devpipe_read+0x4a>
  8028f1:	48                   	dec    %eax
  8028f2:	83 c8 e0             	or     $0xffffffe0,%eax
  8028f5:	40                   	inc    %eax
  8028f6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8028fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028fd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802900:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802902:	46                   	inc    %esi
  802903:	3b 75 10             	cmp    0x10(%ebp),%esi
  802906:	75 db                	jne    8028e3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802908:	89 f0                	mov    %esi,%eax
  80290a:	eb 05                	jmp    802911 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80290c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802911:	83 c4 1c             	add    $0x1c,%esp
  802914:	5b                   	pop    %ebx
  802915:	5e                   	pop    %esi
  802916:	5f                   	pop    %edi
  802917:	5d                   	pop    %ebp
  802918:	c3                   	ret    

00802919 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802919:	55                   	push   %ebp
  80291a:	89 e5                	mov    %esp,%ebp
  80291c:	57                   	push   %edi
  80291d:	56                   	push   %esi
  80291e:	53                   	push   %ebx
  80291f:	83 ec 3c             	sub    $0x3c,%esp
  802922:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802925:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802928:	89 04 24             	mov    %eax,(%esp)
  80292b:	e8 43 ea ff ff       	call   801373 <fd_alloc>
  802930:	89 c3                	mov    %eax,%ebx
  802932:	85 c0                	test   %eax,%eax
  802934:	0f 88 45 01 00 00    	js     802a7f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80293a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802941:	00 
  802942:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802945:	89 44 24 04          	mov    %eax,0x4(%esp)
  802949:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802950:	e8 6c e3 ff ff       	call   800cc1 <sys_page_alloc>
  802955:	89 c3                	mov    %eax,%ebx
  802957:	85 c0                	test   %eax,%eax
  802959:	0f 88 20 01 00 00    	js     802a7f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80295f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802962:	89 04 24             	mov    %eax,(%esp)
  802965:	e8 09 ea ff ff       	call   801373 <fd_alloc>
  80296a:	89 c3                	mov    %eax,%ebx
  80296c:	85 c0                	test   %eax,%eax
  80296e:	0f 88 f8 00 00 00    	js     802a6c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802974:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80297b:	00 
  80297c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80297f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802983:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80298a:	e8 32 e3 ff ff       	call   800cc1 <sys_page_alloc>
  80298f:	89 c3                	mov    %eax,%ebx
  802991:	85 c0                	test   %eax,%eax
  802993:	0f 88 d3 00 00 00    	js     802a6c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802999:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80299c:	89 04 24             	mov    %eax,(%esp)
  80299f:	e8 b4 e9 ff ff       	call   801358 <fd2data>
  8029a4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8029a6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8029ad:	00 
  8029ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029b9:	e8 03 e3 ff ff       	call   800cc1 <sys_page_alloc>
  8029be:	89 c3                	mov    %eax,%ebx
  8029c0:	85 c0                	test   %eax,%eax
  8029c2:	0f 88 91 00 00 00    	js     802a59 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8029c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8029cb:	89 04 24             	mov    %eax,(%esp)
  8029ce:	e8 85 e9 ff ff       	call   801358 <fd2data>
  8029d3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8029da:	00 
  8029db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8029e6:	00 
  8029e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029f2:	e8 1e e3 ff ff       	call   800d15 <sys_page_map>
  8029f7:	89 c3                	mov    %eax,%ebx
  8029f9:	85 c0                	test   %eax,%eax
  8029fb:	78 4c                	js     802a49 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8029fd:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802a03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a06:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802a08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a0b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802a12:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802a18:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a1b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802a1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a20:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802a27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a2a:	89 04 24             	mov    %eax,(%esp)
  802a2d:	e8 16 e9 ff ff       	call   801348 <fd2num>
  802a32:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802a34:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a37:	89 04 24             	mov    %eax,(%esp)
  802a3a:	e8 09 e9 ff ff       	call   801348 <fd2num>
  802a3f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802a42:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a47:	eb 36                	jmp    802a7f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802a49:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a54:	e8 0f e3 ff ff       	call   800d68 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802a59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a67:	e8 fc e2 ff ff       	call   800d68 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a7a:	e8 e9 e2 ff ff       	call   800d68 <sys_page_unmap>
    err:
	return r;
}
  802a7f:	89 d8                	mov    %ebx,%eax
  802a81:	83 c4 3c             	add    $0x3c,%esp
  802a84:	5b                   	pop    %ebx
  802a85:	5e                   	pop    %esi
  802a86:	5f                   	pop    %edi
  802a87:	5d                   	pop    %ebp
  802a88:	c3                   	ret    

00802a89 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802a89:	55                   	push   %ebp
  802a8a:	89 e5                	mov    %esp,%ebp
  802a8c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a96:	8b 45 08             	mov    0x8(%ebp),%eax
  802a99:	89 04 24             	mov    %eax,(%esp)
  802a9c:	e8 25 e9 ff ff       	call   8013c6 <fd_lookup>
  802aa1:	85 c0                	test   %eax,%eax
  802aa3:	78 15                	js     802aba <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802aa8:	89 04 24             	mov    %eax,(%esp)
  802aab:	e8 a8 e8 ff ff       	call   801358 <fd2data>
	return _pipeisclosed(fd, p);
  802ab0:	89 c2                	mov    %eax,%edx
  802ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ab5:	e8 15 fd ff ff       	call   8027cf <_pipeisclosed>
}
  802aba:	c9                   	leave  
  802abb:	c3                   	ret    

00802abc <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802abc:	55                   	push   %ebp
  802abd:	89 e5                	mov    %esp,%ebp
  802abf:	56                   	push   %esi
  802ac0:	53                   	push   %ebx
  802ac1:	83 ec 10             	sub    $0x10,%esp
  802ac4:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802ac7:	85 f6                	test   %esi,%esi
  802ac9:	75 24                	jne    802aef <wait+0x33>
  802acb:	c7 44 24 0c 70 37 80 	movl   $0x803770,0xc(%esp)
  802ad2:	00 
  802ad3:	c7 44 24 08 67 36 80 	movl   $0x803667,0x8(%esp)
  802ada:	00 
  802adb:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802ae2:	00 
  802ae3:	c7 04 24 7b 37 80 00 	movl   $0x80377b,(%esp)
  802aea:	e8 3d d7 ff ff       	call   80022c <_panic>
	e = &envs[ENVX(envid)];
  802aef:	89 f3                	mov    %esi,%ebx
  802af1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802af7:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  802afe:	c1 e3 07             	shl    $0x7,%ebx
  802b01:	29 c3                	sub    %eax,%ebx
  802b03:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802b09:	eb 05                	jmp    802b10 <wait+0x54>
		sys_yield();
  802b0b:	e8 92 e1 ff ff       	call   800ca2 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802b10:	8b 43 48             	mov    0x48(%ebx),%eax
  802b13:	39 f0                	cmp    %esi,%eax
  802b15:	75 07                	jne    802b1e <wait+0x62>
  802b17:	8b 43 54             	mov    0x54(%ebx),%eax
  802b1a:	85 c0                	test   %eax,%eax
  802b1c:	75 ed                	jne    802b0b <wait+0x4f>
		sys_yield();
}
  802b1e:	83 c4 10             	add    $0x10,%esp
  802b21:	5b                   	pop    %ebx
  802b22:	5e                   	pop    %esi
  802b23:	5d                   	pop    %ebp
  802b24:	c3                   	ret    
  802b25:	00 00                	add    %al,(%eax)
	...

00802b28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802b28:	55                   	push   %ebp
  802b29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  802b30:	5d                   	pop    %ebp
  802b31:	c3                   	ret    

00802b32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802b32:	55                   	push   %ebp
  802b33:	89 e5                	mov    %esp,%ebp
  802b35:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802b38:	c7 44 24 04 86 37 80 	movl   $0x803786,0x4(%esp)
  802b3f:	00 
  802b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b43:	89 04 24             	mov    %eax,(%esp)
  802b46:	e8 84 dd ff ff       	call   8008cf <strcpy>
	return 0;
}
  802b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  802b50:	c9                   	leave  
  802b51:	c3                   	ret    

00802b52 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b52:	55                   	push   %ebp
  802b53:	89 e5                	mov    %esp,%ebp
  802b55:	57                   	push   %edi
  802b56:	56                   	push   %esi
  802b57:	53                   	push   %ebx
  802b58:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802b5e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802b63:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802b69:	eb 30                	jmp    802b9b <devcons_write+0x49>
		m = n - tot;
  802b6b:	8b 75 10             	mov    0x10(%ebp),%esi
  802b6e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802b70:	83 fe 7f             	cmp    $0x7f,%esi
  802b73:	76 05                	jbe    802b7a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802b75:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802b7a:	89 74 24 08          	mov    %esi,0x8(%esp)
  802b7e:	03 45 0c             	add    0xc(%ebp),%eax
  802b81:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b85:	89 3c 24             	mov    %edi,(%esp)
  802b88:	e8 bb de ff ff       	call   800a48 <memmove>
		sys_cputs(buf, m);
  802b8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b91:	89 3c 24             	mov    %edi,(%esp)
  802b94:	e8 5b e0 ff ff       	call   800bf4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802b99:	01 f3                	add    %esi,%ebx
  802b9b:	89 d8                	mov    %ebx,%eax
  802b9d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802ba0:	72 c9                	jb     802b6b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802ba2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802ba8:	5b                   	pop    %ebx
  802ba9:	5e                   	pop    %esi
  802baa:	5f                   	pop    %edi
  802bab:	5d                   	pop    %ebp
  802bac:	c3                   	ret    

00802bad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802bad:	55                   	push   %ebp
  802bae:	89 e5                	mov    %esp,%ebp
  802bb0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802bb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802bb7:	75 07                	jne    802bc0 <devcons_read+0x13>
  802bb9:	eb 25                	jmp    802be0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802bbb:	e8 e2 e0 ff ff       	call   800ca2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802bc0:	e8 4d e0 ff ff       	call   800c12 <sys_cgetc>
  802bc5:	85 c0                	test   %eax,%eax
  802bc7:	74 f2                	je     802bbb <devcons_read+0xe>
  802bc9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802bcb:	85 c0                	test   %eax,%eax
  802bcd:	78 1d                	js     802bec <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802bcf:	83 f8 04             	cmp    $0x4,%eax
  802bd2:	74 13                	je     802be7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  802bd7:	88 10                	mov    %dl,(%eax)
	return 1;
  802bd9:	b8 01 00 00 00       	mov    $0x1,%eax
  802bde:	eb 0c                	jmp    802bec <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802be0:	b8 00 00 00 00       	mov    $0x0,%eax
  802be5:	eb 05                	jmp    802bec <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802be7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802bec:	c9                   	leave  
  802bed:	c3                   	ret    

00802bee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802bee:	55                   	push   %ebp
  802bef:	89 e5                	mov    %esp,%ebp
  802bf1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  802bf7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802bfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802c01:	00 
  802c02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802c05:	89 04 24             	mov    %eax,(%esp)
  802c08:	e8 e7 df ff ff       	call   800bf4 <sys_cputs>
}
  802c0d:	c9                   	leave  
  802c0e:	c3                   	ret    

00802c0f <getchar>:

int
getchar(void)
{
  802c0f:	55                   	push   %ebp
  802c10:	89 e5                	mov    %esp,%ebp
  802c12:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802c15:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802c1c:	00 
  802c1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c2b:	e8 34 ea ff ff       	call   801664 <read>
	if (r < 0)
  802c30:	85 c0                	test   %eax,%eax
  802c32:	78 0f                	js     802c43 <getchar+0x34>
		return r;
	if (r < 1)
  802c34:	85 c0                	test   %eax,%eax
  802c36:	7e 06                	jle    802c3e <getchar+0x2f>
		return -E_EOF;
	return c;
  802c38:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802c3c:	eb 05                	jmp    802c43 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802c3e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802c43:	c9                   	leave  
  802c44:	c3                   	ret    

00802c45 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802c45:	55                   	push   %ebp
  802c46:	89 e5                	mov    %esp,%ebp
  802c48:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c52:	8b 45 08             	mov    0x8(%ebp),%eax
  802c55:	89 04 24             	mov    %eax,(%esp)
  802c58:	e8 69 e7 ff ff       	call   8013c6 <fd_lookup>
  802c5d:	85 c0                	test   %eax,%eax
  802c5f:	78 11                	js     802c72 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c64:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802c6a:	39 10                	cmp    %edx,(%eax)
  802c6c:	0f 94 c0             	sete   %al
  802c6f:	0f b6 c0             	movzbl %al,%eax
}
  802c72:	c9                   	leave  
  802c73:	c3                   	ret    

00802c74 <opencons>:

int
opencons(void)
{
  802c74:	55                   	push   %ebp
  802c75:	89 e5                	mov    %esp,%ebp
  802c77:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802c7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c7d:	89 04 24             	mov    %eax,(%esp)
  802c80:	e8 ee e6 ff ff       	call   801373 <fd_alloc>
  802c85:	85 c0                	test   %eax,%eax
  802c87:	78 3c                	js     802cc5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802c89:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802c90:	00 
  802c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c94:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c9f:	e8 1d e0 ff ff       	call   800cc1 <sys_page_alloc>
  802ca4:	85 c0                	test   %eax,%eax
  802ca6:	78 1d                	js     802cc5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802ca8:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cb1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cb6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802cbd:	89 04 24             	mov    %eax,(%esp)
  802cc0:	e8 83 e6 ff ff       	call   801348 <fd2num>
}
  802cc5:	c9                   	leave  
  802cc6:	c3                   	ret    
	...

00802cc8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802cc8:	55                   	push   %ebp
  802cc9:	89 e5                	mov    %esp,%ebp
  802ccb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802cce:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802cd5:	75 30                	jne    802d07 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  802cd7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802cde:	00 
  802cdf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802ce6:	ee 
  802ce7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cee:	e8 ce df ff ff       	call   800cc1 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802cf3:	c7 44 24 04 14 2d 80 	movl   $0x802d14,0x4(%esp)
  802cfa:	00 
  802cfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d02:	e8 5a e1 ff ff       	call   800e61 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802d07:	8b 45 08             	mov    0x8(%ebp),%eax
  802d0a:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802d0f:	c9                   	leave  
  802d10:	c3                   	ret    
  802d11:	00 00                	add    %al,(%eax)
	...

00802d14 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802d14:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802d15:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802d1a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802d1c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  802d1f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802d23:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802d27:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  802d2a:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802d2c:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802d30:	83 c4 08             	add    $0x8,%esp
	popal
  802d33:	61                   	popa   

	addl $4,%esp 
  802d34:	83 c4 04             	add    $0x4,%esp
	popfl
  802d37:	9d                   	popf   

	popl %esp
  802d38:	5c                   	pop    %esp

	ret
  802d39:	c3                   	ret    
	...

00802d3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802d3c:	55                   	push   %ebp
  802d3d:	89 e5                	mov    %esp,%ebp
  802d3f:	56                   	push   %esi
  802d40:	53                   	push   %ebx
  802d41:	83 ec 10             	sub    $0x10,%esp
  802d44:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802d47:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d4a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802d4d:	85 c0                	test   %eax,%eax
  802d4f:	74 0a                	je     802d5b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802d51:	89 04 24             	mov    %eax,(%esp)
  802d54:	e8 7e e1 ff ff       	call   800ed7 <sys_ipc_recv>
  802d59:	eb 0c                	jmp    802d67 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802d5b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802d62:	e8 70 e1 ff ff       	call   800ed7 <sys_ipc_recv>
	}
	if (r < 0)
  802d67:	85 c0                	test   %eax,%eax
  802d69:	79 16                	jns    802d81 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802d6b:	85 db                	test   %ebx,%ebx
  802d6d:	74 06                	je     802d75 <ipc_recv+0x39>
  802d6f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802d75:	85 f6                	test   %esi,%esi
  802d77:	74 2c                	je     802da5 <ipc_recv+0x69>
  802d79:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802d7f:	eb 24                	jmp    802da5 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802d81:	85 db                	test   %ebx,%ebx
  802d83:	74 0a                	je     802d8f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802d85:	a1 08 50 80 00       	mov    0x805008,%eax
  802d8a:	8b 40 74             	mov    0x74(%eax),%eax
  802d8d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802d8f:	85 f6                	test   %esi,%esi
  802d91:	74 0a                	je     802d9d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802d93:	a1 08 50 80 00       	mov    0x805008,%eax
  802d98:	8b 40 78             	mov    0x78(%eax),%eax
  802d9b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802d9d:	a1 08 50 80 00       	mov    0x805008,%eax
  802da2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802da5:	83 c4 10             	add    $0x10,%esp
  802da8:	5b                   	pop    %ebx
  802da9:	5e                   	pop    %esi
  802daa:	5d                   	pop    %ebp
  802dab:	c3                   	ret    

00802dac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802dac:	55                   	push   %ebp
  802dad:	89 e5                	mov    %esp,%ebp
  802daf:	57                   	push   %edi
  802db0:	56                   	push   %esi
  802db1:	53                   	push   %ebx
  802db2:	83 ec 1c             	sub    $0x1c,%esp
  802db5:	8b 75 08             	mov    0x8(%ebp),%esi
  802db8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802dbe:	85 db                	test   %ebx,%ebx
  802dc0:	74 19                	je     802ddb <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802dc2:	8b 45 14             	mov    0x14(%ebp),%eax
  802dc5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802dc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802dcd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802dd1:	89 34 24             	mov    %esi,(%esp)
  802dd4:	e8 db e0 ff ff       	call   800eb4 <sys_ipc_try_send>
  802dd9:	eb 1c                	jmp    802df7 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802ddb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802de2:	00 
  802de3:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802dea:	ee 
  802deb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802def:	89 34 24             	mov    %esi,(%esp)
  802df2:	e8 bd e0 ff ff       	call   800eb4 <sys_ipc_try_send>
		}
		if (r == 0)
  802df7:	85 c0                	test   %eax,%eax
  802df9:	74 2c                	je     802e27 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802dfb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802dfe:	74 20                	je     802e20 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802e00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e04:	c7 44 24 08 92 37 80 	movl   $0x803792,0x8(%esp)
  802e0b:	00 
  802e0c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802e13:	00 
  802e14:	c7 04 24 a5 37 80 00 	movl   $0x8037a5,(%esp)
  802e1b:	e8 0c d4 ff ff       	call   80022c <_panic>
		}
		sys_yield();
  802e20:	e8 7d de ff ff       	call   800ca2 <sys_yield>
	}
  802e25:	eb 97                	jmp    802dbe <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802e27:	83 c4 1c             	add    $0x1c,%esp
  802e2a:	5b                   	pop    %ebx
  802e2b:	5e                   	pop    %esi
  802e2c:	5f                   	pop    %edi
  802e2d:	5d                   	pop    %ebp
  802e2e:	c3                   	ret    

00802e2f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802e2f:	55                   	push   %ebp
  802e30:	89 e5                	mov    %esp,%ebp
  802e32:	53                   	push   %ebx
  802e33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802e36:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802e3b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802e42:	89 c2                	mov    %eax,%edx
  802e44:	c1 e2 07             	shl    $0x7,%edx
  802e47:	29 ca                	sub    %ecx,%edx
  802e49:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802e4f:	8b 52 50             	mov    0x50(%edx),%edx
  802e52:	39 da                	cmp    %ebx,%edx
  802e54:	75 0f                	jne    802e65 <ipc_find_env+0x36>
			return envs[i].env_id;
  802e56:	c1 e0 07             	shl    $0x7,%eax
  802e59:	29 c8                	sub    %ecx,%eax
  802e5b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802e60:	8b 40 40             	mov    0x40(%eax),%eax
  802e63:	eb 0c                	jmp    802e71 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802e65:	40                   	inc    %eax
  802e66:	3d 00 04 00 00       	cmp    $0x400,%eax
  802e6b:	75 ce                	jne    802e3b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802e6d:	66 b8 00 00          	mov    $0x0,%ax
}
  802e71:	5b                   	pop    %ebx
  802e72:	5d                   	pop    %ebp
  802e73:	c3                   	ret    

00802e74 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802e74:	55                   	push   %ebp
  802e75:	89 e5                	mov    %esp,%ebp
  802e77:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802e7a:	89 c2                	mov    %eax,%edx
  802e7c:	c1 ea 16             	shr    $0x16,%edx
  802e7f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802e86:	f6 c2 01             	test   $0x1,%dl
  802e89:	74 1e                	je     802ea9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802e8b:	c1 e8 0c             	shr    $0xc,%eax
  802e8e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802e95:	a8 01                	test   $0x1,%al
  802e97:	74 17                	je     802eb0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802e99:	c1 e8 0c             	shr    $0xc,%eax
  802e9c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802ea3:	ef 
  802ea4:	0f b7 c0             	movzwl %ax,%eax
  802ea7:	eb 0c                	jmp    802eb5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  802eae:	eb 05                	jmp    802eb5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802eb0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802eb5:	5d                   	pop    %ebp
  802eb6:	c3                   	ret    
	...

00802eb8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802eb8:	55                   	push   %ebp
  802eb9:	57                   	push   %edi
  802eba:	56                   	push   %esi
  802ebb:	83 ec 10             	sub    $0x10,%esp
  802ebe:	8b 74 24 20          	mov    0x20(%esp),%esi
  802ec2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802ec6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802eca:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802ece:	89 cd                	mov    %ecx,%ebp
  802ed0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802ed4:	85 c0                	test   %eax,%eax
  802ed6:	75 2c                	jne    802f04 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802ed8:	39 f9                	cmp    %edi,%ecx
  802eda:	77 68                	ja     802f44 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802edc:	85 c9                	test   %ecx,%ecx
  802ede:	75 0b                	jne    802eeb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802ee0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ee5:	31 d2                	xor    %edx,%edx
  802ee7:	f7 f1                	div    %ecx
  802ee9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802eeb:	31 d2                	xor    %edx,%edx
  802eed:	89 f8                	mov    %edi,%eax
  802eef:	f7 f1                	div    %ecx
  802ef1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802ef3:	89 f0                	mov    %esi,%eax
  802ef5:	f7 f1                	div    %ecx
  802ef7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802ef9:	89 f0                	mov    %esi,%eax
  802efb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802efd:	83 c4 10             	add    $0x10,%esp
  802f00:	5e                   	pop    %esi
  802f01:	5f                   	pop    %edi
  802f02:	5d                   	pop    %ebp
  802f03:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802f04:	39 f8                	cmp    %edi,%eax
  802f06:	77 2c                	ja     802f34 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802f08:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802f0b:	83 f6 1f             	xor    $0x1f,%esi
  802f0e:	75 4c                	jne    802f5c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802f10:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802f12:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802f17:	72 0a                	jb     802f23 <__udivdi3+0x6b>
  802f19:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802f1d:	0f 87 ad 00 00 00    	ja     802fd0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802f23:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802f28:	89 f0                	mov    %esi,%eax
  802f2a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802f2c:	83 c4 10             	add    $0x10,%esp
  802f2f:	5e                   	pop    %esi
  802f30:	5f                   	pop    %edi
  802f31:	5d                   	pop    %ebp
  802f32:	c3                   	ret    
  802f33:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802f34:	31 ff                	xor    %edi,%edi
  802f36:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802f38:	89 f0                	mov    %esi,%eax
  802f3a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802f3c:	83 c4 10             	add    $0x10,%esp
  802f3f:	5e                   	pop    %esi
  802f40:	5f                   	pop    %edi
  802f41:	5d                   	pop    %ebp
  802f42:	c3                   	ret    
  802f43:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802f44:	89 fa                	mov    %edi,%edx
  802f46:	89 f0                	mov    %esi,%eax
  802f48:	f7 f1                	div    %ecx
  802f4a:	89 c6                	mov    %eax,%esi
  802f4c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802f4e:	89 f0                	mov    %esi,%eax
  802f50:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802f52:	83 c4 10             	add    $0x10,%esp
  802f55:	5e                   	pop    %esi
  802f56:	5f                   	pop    %edi
  802f57:	5d                   	pop    %ebp
  802f58:	c3                   	ret    
  802f59:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802f5c:	89 f1                	mov    %esi,%ecx
  802f5e:	d3 e0                	shl    %cl,%eax
  802f60:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802f64:	b8 20 00 00 00       	mov    $0x20,%eax
  802f69:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802f6b:	89 ea                	mov    %ebp,%edx
  802f6d:	88 c1                	mov    %al,%cl
  802f6f:	d3 ea                	shr    %cl,%edx
  802f71:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802f75:	09 ca                	or     %ecx,%edx
  802f77:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802f7b:	89 f1                	mov    %esi,%ecx
  802f7d:	d3 e5                	shl    %cl,%ebp
  802f7f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802f83:	89 fd                	mov    %edi,%ebp
  802f85:	88 c1                	mov    %al,%cl
  802f87:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802f89:	89 fa                	mov    %edi,%edx
  802f8b:	89 f1                	mov    %esi,%ecx
  802f8d:	d3 e2                	shl    %cl,%edx
  802f8f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802f93:	88 c1                	mov    %al,%cl
  802f95:	d3 ef                	shr    %cl,%edi
  802f97:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802f99:	89 f8                	mov    %edi,%eax
  802f9b:	89 ea                	mov    %ebp,%edx
  802f9d:	f7 74 24 08          	divl   0x8(%esp)
  802fa1:	89 d1                	mov    %edx,%ecx
  802fa3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802fa5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802fa9:	39 d1                	cmp    %edx,%ecx
  802fab:	72 17                	jb     802fc4 <__udivdi3+0x10c>
  802fad:	74 09                	je     802fb8 <__udivdi3+0x100>
  802faf:	89 fe                	mov    %edi,%esi
  802fb1:	31 ff                	xor    %edi,%edi
  802fb3:	e9 41 ff ff ff       	jmp    802ef9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802fb8:	8b 54 24 04          	mov    0x4(%esp),%edx
  802fbc:	89 f1                	mov    %esi,%ecx
  802fbe:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802fc0:	39 c2                	cmp    %eax,%edx
  802fc2:	73 eb                	jae    802faf <__udivdi3+0xf7>
		{
		  q0--;
  802fc4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802fc7:	31 ff                	xor    %edi,%edi
  802fc9:	e9 2b ff ff ff       	jmp    802ef9 <__udivdi3+0x41>
  802fce:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802fd0:	31 f6                	xor    %esi,%esi
  802fd2:	e9 22 ff ff ff       	jmp    802ef9 <__udivdi3+0x41>
	...

00802fd8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802fd8:	55                   	push   %ebp
  802fd9:	57                   	push   %edi
  802fda:	56                   	push   %esi
  802fdb:	83 ec 20             	sub    $0x20,%esp
  802fde:	8b 44 24 30          	mov    0x30(%esp),%eax
  802fe2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802fe6:	89 44 24 14          	mov    %eax,0x14(%esp)
  802fea:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802fee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802ff2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802ff6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802ff8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802ffa:	85 ed                	test   %ebp,%ebp
  802ffc:	75 16                	jne    803014 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802ffe:	39 f1                	cmp    %esi,%ecx
  803000:	0f 86 a6 00 00 00    	jbe    8030ac <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803006:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803008:	89 d0                	mov    %edx,%eax
  80300a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80300c:	83 c4 20             	add    $0x20,%esp
  80300f:	5e                   	pop    %esi
  803010:	5f                   	pop    %edi
  803011:	5d                   	pop    %ebp
  803012:	c3                   	ret    
  803013:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803014:	39 f5                	cmp    %esi,%ebp
  803016:	0f 87 ac 00 00 00    	ja     8030c8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80301c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80301f:	83 f0 1f             	xor    $0x1f,%eax
  803022:	89 44 24 10          	mov    %eax,0x10(%esp)
  803026:	0f 84 a8 00 00 00    	je     8030d4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80302c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803030:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803032:	bf 20 00 00 00       	mov    $0x20,%edi
  803037:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80303b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80303f:	89 f9                	mov    %edi,%ecx
  803041:	d3 e8                	shr    %cl,%eax
  803043:	09 e8                	or     %ebp,%eax
  803045:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803049:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80304d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803051:	d3 e0                	shl    %cl,%eax
  803053:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803057:	89 f2                	mov    %esi,%edx
  803059:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80305b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80305f:	d3 e0                	shl    %cl,%eax
  803061:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803065:	8b 44 24 14          	mov    0x14(%esp),%eax
  803069:	89 f9                	mov    %edi,%ecx
  80306b:	d3 e8                	shr    %cl,%eax
  80306d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80306f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803071:	89 f2                	mov    %esi,%edx
  803073:	f7 74 24 18          	divl   0x18(%esp)
  803077:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803079:	f7 64 24 0c          	mull   0xc(%esp)
  80307d:	89 c5                	mov    %eax,%ebp
  80307f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803081:	39 d6                	cmp    %edx,%esi
  803083:	72 67                	jb     8030ec <__umoddi3+0x114>
  803085:	74 75                	je     8030fc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803087:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80308b:	29 e8                	sub    %ebp,%eax
  80308d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80308f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803093:	d3 e8                	shr    %cl,%eax
  803095:	89 f2                	mov    %esi,%edx
  803097:	89 f9                	mov    %edi,%ecx
  803099:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80309b:	09 d0                	or     %edx,%eax
  80309d:	89 f2                	mov    %esi,%edx
  80309f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8030a3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8030a5:	83 c4 20             	add    $0x20,%esp
  8030a8:	5e                   	pop    %esi
  8030a9:	5f                   	pop    %edi
  8030aa:	5d                   	pop    %ebp
  8030ab:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8030ac:	85 c9                	test   %ecx,%ecx
  8030ae:	75 0b                	jne    8030bb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8030b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8030b5:	31 d2                	xor    %edx,%edx
  8030b7:	f7 f1                	div    %ecx
  8030b9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8030bb:	89 f0                	mov    %esi,%eax
  8030bd:	31 d2                	xor    %edx,%edx
  8030bf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8030c1:	89 f8                	mov    %edi,%eax
  8030c3:	e9 3e ff ff ff       	jmp    803006 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8030c8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8030ca:	83 c4 20             	add    $0x20,%esp
  8030cd:	5e                   	pop    %esi
  8030ce:	5f                   	pop    %edi
  8030cf:	5d                   	pop    %ebp
  8030d0:	c3                   	ret    
  8030d1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8030d4:	39 f5                	cmp    %esi,%ebp
  8030d6:	72 04                	jb     8030dc <__umoddi3+0x104>
  8030d8:	39 f9                	cmp    %edi,%ecx
  8030da:	77 06                	ja     8030e2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8030dc:	89 f2                	mov    %esi,%edx
  8030de:	29 cf                	sub    %ecx,%edi
  8030e0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8030e2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8030e4:	83 c4 20             	add    $0x20,%esp
  8030e7:	5e                   	pop    %esi
  8030e8:	5f                   	pop    %edi
  8030e9:	5d                   	pop    %ebp
  8030ea:	c3                   	ret    
  8030eb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8030ec:	89 d1                	mov    %edx,%ecx
  8030ee:	89 c5                	mov    %eax,%ebp
  8030f0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8030f4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8030f8:	eb 8d                	jmp    803087 <__umoddi3+0xaf>
  8030fa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8030fc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803100:	72 ea                	jb     8030ec <__umoddi3+0x114>
  803102:	89 f1                	mov    %esi,%ecx
  803104:	eb 81                	jmp    803087 <__umoddi3+0xaf>
