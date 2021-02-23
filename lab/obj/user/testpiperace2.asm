
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 ab 01 00 00       	call   8001dc <libmain>
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
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003d:	c7 04 24 60 2a 80 00 	movl   $0x802a60,(%esp)
  800044:	e8 fb 02 00 00       	call   800344 <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 75 22 00 00       	call   8022c9 <pipe>
  800054:	85 c0                	test   %eax,%eax
  800056:	79 20                	jns    800078 <umain+0x44>
		panic("pipe: %e", r);
  800058:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005c:	c7 44 24 08 ae 2a 80 	movl   $0x802aae,0x8(%esp)
  800063:	00 
  800064:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006b:	00 
  80006c:	c7 04 24 b7 2a 80 00 	movl   $0x802ab7,(%esp)
  800073:	e8 d4 01 00 00       	call   80024c <_panic>
	if ((r = fork()) < 0)
  800078:	e8 06 10 00 00       	call   801083 <fork>
  80007d:	89 c7                	mov    %eax,%edi
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 20                	jns    8000a3 <umain+0x6f>
		panic("fork: %e", r);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 e5 2e 80 	movl   $0x802ee5,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 b7 2a 80 00 	movl   $0x802ab7,(%esp)
  80009e:	e8 a9 01 00 00       	call   80024c <_panic>
	if (r == 0) {
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 5d                	jne    800104 <umain+0xd0>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000aa:	89 04 24             	mov    %eax,(%esp)
  8000ad:	e8 6c 14 00 00       	call   80151e <close>
		for (i = 0; i < 200; i++) {
  8000b2:	be 00 00 00 00       	mov    $0x0,%esi
			if (i % 10 == 0)
  8000b7:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8000bc:	89 f0                	mov    %esi,%eax
  8000be:	99                   	cltd   
  8000bf:	f7 fb                	idiv   %ebx
  8000c1:	85 d2                	test   %edx,%edx
  8000c3:	75 10                	jne    8000d5 <umain+0xa1>
				cprintf("%d.", i);
  8000c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c9:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  8000d0:	e8 6f 02 00 00       	call   800344 <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000dc:	89 04 24             	mov    %eax,(%esp)
  8000df:	e8 8b 14 00 00       	call   80156f <dup>
			sys_yield();
  8000e4:	e8 d9 0b 00 00       	call   800cc2 <sys_yield>
			close(10);
  8000e9:	89 1c 24             	mov    %ebx,(%esp)
  8000ec:	e8 2d 14 00 00       	call   80151e <close>
			sys_yield();
  8000f1:	e8 cc 0b 00 00       	call   800cc2 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000f6:	46                   	inc    %esi
  8000f7:	81 fe c8 00 00 00    	cmp    $0xc8,%esi
  8000fd:	75 bd                	jne    8000bc <umain+0x88>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000ff:	e8 2c 01 00 00       	call   800230 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800104:	89 f8                	mov    %edi,%eax
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800112:	c1 e0 07             	shl    $0x7,%eax
  800115:	29 d0                	sub    %edx,%eax
  800117:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80011d:	eb 28                	jmp    800147 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  80011f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 0f 23 00 00       	call   802439 <pipeisclosed>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	74 19                	je     800147 <umain+0x113>
			cprintf("\nRACE: pipe appears closed\n");
  80012e:	c7 04 24 d0 2a 80 00 	movl   $0x802ad0,(%esp)
  800135:	e8 0a 02 00 00       	call   800344 <cprintf>
			sys_env_destroy(r);
  80013a:	89 3c 24             	mov    %edi,(%esp)
  80013d:	e8 0f 0b 00 00       	call   800c51 <sys_env_destroy>
			exit();
  800142:	e8 e9 00 00 00       	call   800230 <exit>
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800147:	8b 43 54             	mov    0x54(%ebx),%eax
  80014a:	83 f8 02             	cmp    $0x2,%eax
  80014d:	74 d0                	je     80011f <umain+0xeb>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  80014f:	c7 04 24 ec 2a 80 00 	movl   $0x802aec,(%esp)
  800156:	e8 e9 01 00 00       	call   800344 <cprintf>
	if (pipeisclosed(p[0]))
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 d3 22 00 00       	call   802439 <pipeisclosed>
  800166:	85 c0                	test   %eax,%eax
  800168:	74 1c                	je     800186 <umain+0x152>
		panic("somehow the other end of p[0] got closed!");
  80016a:	c7 44 24 08 84 2a 80 	movl   $0x802a84,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 b7 2a 80 00 	movl   $0x802ab7,(%esp)
  800181:	e8 c6 00 00 00       	call   80024c <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800186:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 4e 12 00 00       	call   8013e6 <fd_lookup>
  800198:	85 c0                	test   %eax,%eax
  80019a:	79 20                	jns    8001bc <umain+0x188>
		panic("cannot look up p[0]: %e", r);
  80019c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a0:	c7 44 24 08 02 2b 80 	movl   $0x802b02,0x8(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001af:	00 
  8001b0:	c7 04 24 b7 2a 80 00 	movl   $0x802ab7,(%esp)
  8001b7:	e8 90 00 00 00       	call   80024c <_panic>
	(void) fd2data(fd);
  8001bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 b1 11 00 00       	call   801378 <fd2data>
	cprintf("race didn't happen\n");
  8001c7:	c7 04 24 1a 2b 80 00 	movl   $0x802b1a,(%esp)
  8001ce:	e8 71 01 00 00       	call   800344 <cprintf>
}
  8001d3:	83 c4 2c             	add    $0x2c,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    
	...

008001dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 10             	sub    $0x10,%esp
  8001e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ea:	e8 b4 0a 00 00       	call   800ca3 <sys_getenvid>
  8001ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001fb:	c1 e0 07             	shl    $0x7,%eax
  8001fe:	29 d0                	sub    %edx,%eax
  800200:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800205:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020a:	85 f6                	test   %esi,%esi
  80020c:	7e 07                	jle    800215 <libmain+0x39>
		binaryname = argv[0];
  80020e:	8b 03                	mov    (%ebx),%eax
  800210:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800215:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800219:	89 34 24             	mov    %esi,(%esp)
  80021c:	e8 13 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800221:	e8 0a 00 00 00       	call   800230 <exit>
}
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    
  80022d:	00 00                	add    %al,(%eax)
	...

00800230 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800236:	e8 14 13 00 00       	call   80154f <close_all>
	sys_env_destroy(0);
  80023b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800242:	e8 0a 0a 00 00       	call   800c51 <sys_env_destroy>
}
  800247:	c9                   	leave  
  800248:	c3                   	ret    
  800249:	00 00                	add    %al,(%eax)
	...

0080024c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800254:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800257:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  80025d:	e8 41 0a 00 00       	call   800ca3 <sys_getenvid>
  800262:	8b 55 0c             	mov    0xc(%ebp),%edx
  800265:	89 54 24 10          	mov    %edx,0x10(%esp)
  800269:	8b 55 08             	mov    0x8(%ebp),%edx
  80026c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800270:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	c7 04 24 38 2b 80 00 	movl   $0x802b38,(%esp)
  80027f:	e8 c0 00 00 00       	call   800344 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800284:	89 74 24 04          	mov    %esi,0x4(%esp)
  800288:	8b 45 10             	mov    0x10(%ebp),%eax
  80028b:	89 04 24             	mov    %eax,(%esp)
  80028e:	e8 50 00 00 00       	call   8002e3 <vcprintf>
	cprintf("\n");
  800293:	c7 04 24 58 30 80 00 	movl   $0x803058,(%esp)
  80029a:	e8 a5 00 00 00       	call   800344 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80029f:	cc                   	int3   
  8002a0:	eb fd                	jmp    80029f <_panic+0x53>
	...

008002a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 14             	sub    $0x14,%esp
  8002ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ae:	8b 03                	mov    (%ebx),%eax
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002b7:	40                   	inc    %eax
  8002b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002bf:	75 19                	jne    8002da <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002c1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c8:	00 
  8002c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	e8 40 09 00 00       	call   800c14 <sys_cputs>
		b->idx = 0;
  8002d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002da:	ff 43 04             	incl   0x4(%ebx)
}
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f3:	00 00 00 
	b.cnt = 0;
  8002f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	c7 04 24 a4 02 80 00 	movl   $0x8002a4,(%esp)
  80031f:	e8 82 01 00 00       	call   8004a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800324:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	e8 d8 08 00 00       	call   800c14 <sys_cputs>

	return b.cnt;
}
  80033c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 87 ff ff ff       	call   8002e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    
	...

00800360 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 3c             	sub    $0x3c,%esp
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	89 d7                	mov    %edx,%edi
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
  800377:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80037d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800380:	85 c0                	test   %eax,%eax
  800382:	75 08                	jne    80038c <printnum+0x2c>
  800384:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800387:	39 45 10             	cmp    %eax,0x10(%ebp)
  80038a:	77 57                	ja     8003e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80038c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800390:	4b                   	dec    %ebx
  800391:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800395:	8b 45 10             	mov    0x10(%ebp),%eax
  800398:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ab:	00 
  8003ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	e8 3e 24 00 00       	call   8027fc <__udivdi3>
  8003be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003cd:	89 fa                	mov    %edi,%edx
  8003cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003d2:	e8 89 ff ff ff       	call   800360 <printnum>
  8003d7:	eb 0f                	jmp    8003e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003dd:	89 34 24             	mov    %esi,(%esp)
  8003e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e3:	4b                   	dec    %ebx
  8003e4:	85 db                	test   %ebx,%ebx
  8003e6:	7f f1                	jg     8003d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003fe:	00 
  8003ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800402:	89 04 24             	mov    %eax,(%esp)
  800405:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040c:	e8 0b 25 00 00       	call   80291c <__umoddi3>
  800411:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800415:	0f be 80 5b 2b 80 00 	movsbl 0x802b5b(%eax),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800422:	83 c4 3c             	add    $0x3c,%esp
  800425:	5b                   	pop    %ebx
  800426:	5e                   	pop    %esi
  800427:	5f                   	pop    %edi
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80042d:	83 fa 01             	cmp    $0x1,%edx
  800430:	7e 0e                	jle    800440 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800432:	8b 10                	mov    (%eax),%edx
  800434:	8d 4a 08             	lea    0x8(%edx),%ecx
  800437:	89 08                	mov    %ecx,(%eax)
  800439:	8b 02                	mov    (%edx),%eax
  80043b:	8b 52 04             	mov    0x4(%edx),%edx
  80043e:	eb 22                	jmp    800462 <getuint+0x38>
	else if (lflag)
  800440:	85 d2                	test   %edx,%edx
  800442:	74 10                	je     800454 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800444:	8b 10                	mov    (%eax),%edx
  800446:	8d 4a 04             	lea    0x4(%edx),%ecx
  800449:	89 08                	mov    %ecx,(%eax)
  80044b:	8b 02                	mov    (%edx),%eax
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
  800452:	eb 0e                	jmp    800462 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800454:	8b 10                	mov    (%eax),%edx
  800456:	8d 4a 04             	lea    0x4(%edx),%ecx
  800459:	89 08                	mov    %ecx,(%eax)
  80045b:	8b 02                	mov    (%edx),%eax
  80045d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800462:	5d                   	pop    %ebp
  800463:	c3                   	ret    

00800464 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80046d:	8b 10                	mov    (%eax),%edx
  80046f:	3b 50 04             	cmp    0x4(%eax),%edx
  800472:	73 08                	jae    80047c <sprintputch+0x18>
		*b->buf++ = ch;
  800474:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800477:	88 0a                	mov    %cl,(%edx)
  800479:	42                   	inc    %edx
  80047a:	89 10                	mov    %edx,(%eax)
}
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800484:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800487:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048b:	8b 45 10             	mov    0x10(%ebp),%eax
  80048e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800492:	8b 45 0c             	mov    0xc(%ebp),%eax
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 02 00 00 00       	call   8004a6 <vprintfmt>
	va_end(ap);
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	57                   	push   %edi
  8004aa:	56                   	push   %esi
  8004ab:	53                   	push   %ebx
  8004ac:	83 ec 4c             	sub    $0x4c,%esp
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004b5:	eb 12                	jmp    8004c9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	0f 84 6b 03 00 00    	je     80082a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c3:	89 04 24             	mov    %eax,(%esp)
  8004c6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c9:	0f b6 06             	movzbl (%esi),%eax
  8004cc:	46                   	inc    %esi
  8004cd:	83 f8 25             	cmp    $0x25,%eax
  8004d0:	75 e5                	jne    8004b7 <vprintfmt+0x11>
  8004d2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ee:	eb 26                	jmp    800516 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004f7:	eb 1d                	jmp    800516 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004fc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800500:	eb 14                	jmp    800516 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800505:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80050c:	eb 08                	jmp    800516 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80050e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800511:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	0f b6 06             	movzbl (%esi),%eax
  800519:	8d 56 01             	lea    0x1(%esi),%edx
  80051c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80051f:	8a 16                	mov    (%esi),%dl
  800521:	83 ea 23             	sub    $0x23,%edx
  800524:	80 fa 55             	cmp    $0x55,%dl
  800527:	0f 87 e1 02 00 00    	ja     80080e <vprintfmt+0x368>
  80052d:	0f b6 d2             	movzbl %dl,%edx
  800530:	ff 24 95 a0 2c 80 00 	jmp    *0x802ca0(,%edx,4)
  800537:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80053f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800542:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800546:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800549:	8d 50 d0             	lea    -0x30(%eax),%edx
  80054c:	83 fa 09             	cmp    $0x9,%edx
  80054f:	77 2a                	ja     80057b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800551:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800552:	eb eb                	jmp    80053f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800562:	eb 17                	jmp    80057b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800564:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800568:	78 98                	js     800502 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80056d:	eb a7                	jmp    800516 <vprintfmt+0x70>
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800572:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800579:	eb 9b                	jmp    800516 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80057b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057f:	79 95                	jns    800516 <vprintfmt+0x70>
  800581:	eb 8b                	jmp    80050e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800583:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800587:	eb 8d                	jmp    800516 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 04 24             	mov    %eax,(%esp)
  80059b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005a1:	e9 23 ff ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	79 02                	jns    8005b7 <vprintfmt+0x111>
  8005b5:	f7 d8                	neg    %eax
  8005b7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b9:	83 f8 10             	cmp    $0x10,%eax
  8005bc:	7f 0b                	jg     8005c9 <vprintfmt+0x123>
  8005be:	8b 04 85 00 2e 80 00 	mov    0x802e00(,%eax,4),%eax
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	75 23                	jne    8005ec <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cd:	c7 44 24 08 73 2b 80 	movl   $0x802b73,0x8(%esp)
  8005d4:	00 
  8005d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 9a fe ff ff       	call   80047e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005e7:	e9 dd fe ff ff       	jmp    8004c9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f0:	c7 44 24 08 ed 2f 80 	movl   $0x802fed,0x8(%esp)
  8005f7:	00 
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ff:	89 14 24             	mov    %edx,(%esp)
  800602:	e8 77 fe ff ff       	call   80047e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060a:	e9 ba fe ff ff       	jmp    8004c9 <vprintfmt+0x23>
  80060f:	89 f9                	mov    %edi,%ecx
  800611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800614:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 30                	mov    (%eax),%esi
  800622:	85 f6                	test   %esi,%esi
  800624:	75 05                	jne    80062b <vprintfmt+0x185>
				p = "(null)";
  800626:	be 6c 2b 80 00       	mov    $0x802b6c,%esi
			if (width > 0 && padc != '-')
  80062b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80062f:	0f 8e 84 00 00 00    	jle    8006b9 <vprintfmt+0x213>
  800635:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800639:	74 7e                	je     8006b9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80063f:	89 34 24             	mov    %esi,(%esp)
  800642:	e8 8b 02 00 00       	call   8008d2 <strnlen>
  800647:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80064a:	29 c2                	sub    %eax,%edx
  80064c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80064f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800653:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800656:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800659:	89 de                	mov    %ebx,%esi
  80065b:	89 d3                	mov    %edx,%ebx
  80065d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065f:	eb 0b                	jmp    80066c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800661:	89 74 24 04          	mov    %esi,0x4(%esp)
  800665:	89 3c 24             	mov    %edi,(%esp)
  800668:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066b:	4b                   	dec    %ebx
  80066c:	85 db                	test   %ebx,%ebx
  80066e:	7f f1                	jg     800661 <vprintfmt+0x1bb>
  800670:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800673:	89 f3                	mov    %esi,%ebx
  800675:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800678:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80067b:	85 c0                	test   %eax,%eax
  80067d:	79 05                	jns    800684 <vprintfmt+0x1de>
  80067f:	b8 00 00 00 00       	mov    $0x0,%eax
  800684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800687:	29 c2                	sub    %eax,%edx
  800689:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80068c:	eb 2b                	jmp    8006b9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80068e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800692:	74 18                	je     8006ac <vprintfmt+0x206>
  800694:	8d 50 e0             	lea    -0x20(%eax),%edx
  800697:	83 fa 5e             	cmp    $0x5e,%edx
  80069a:	76 10                	jbe    8006ac <vprintfmt+0x206>
					putch('?', putdat);
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
  8006aa:	eb 0a                	jmp    8006b6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b6:	ff 4d e4             	decl   -0x1c(%ebp)
  8006b9:	0f be 06             	movsbl (%esi),%eax
  8006bc:	46                   	inc    %esi
  8006bd:	85 c0                	test   %eax,%eax
  8006bf:	74 21                	je     8006e2 <vprintfmt+0x23c>
  8006c1:	85 ff                	test   %edi,%edi
  8006c3:	78 c9                	js     80068e <vprintfmt+0x1e8>
  8006c5:	4f                   	dec    %edi
  8006c6:	79 c6                	jns    80068e <vprintfmt+0x1e8>
  8006c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cb:	89 de                	mov    %ebx,%esi
  8006cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006d0:	eb 18                	jmp    8006ea <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006df:	4b                   	dec    %ebx
  8006e0:	eb 08                	jmp    8006ea <vprintfmt+0x244>
  8006e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e5:	89 de                	mov    %ebx,%esi
  8006e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ea:	85 db                	test   %ebx,%ebx
  8006ec:	7f e4                	jg     8006d2 <vprintfmt+0x22c>
  8006ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006f1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f6:	e9 ce fd ff ff       	jmp    8004c9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fb:	83 f9 01             	cmp    $0x1,%ecx
  8006fe:	7e 10                	jle    800710 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8d 50 08             	lea    0x8(%eax),%edx
  800706:	89 55 14             	mov    %edx,0x14(%ebp)
  800709:	8b 30                	mov    (%eax),%esi
  80070b:	8b 78 04             	mov    0x4(%eax),%edi
  80070e:	eb 26                	jmp    800736 <vprintfmt+0x290>
	else if (lflag)
  800710:	85 c9                	test   %ecx,%ecx
  800712:	74 12                	je     800726 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 30                	mov    (%eax),%esi
  80071f:	89 f7                	mov    %esi,%edi
  800721:	c1 ff 1f             	sar    $0x1f,%edi
  800724:	eb 10                	jmp    800736 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 30                	mov    (%eax),%esi
  800731:	89 f7                	mov    %esi,%edi
  800733:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800736:	85 ff                	test   %edi,%edi
  800738:	78 0a                	js     800744 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80073a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073f:	e9 8c 00 00 00       	jmp    8007d0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800752:	f7 de                	neg    %esi
  800754:	83 d7 00             	adc    $0x0,%edi
  800757:	f7 df                	neg    %edi
			}
			base = 10;
  800759:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075e:	eb 70                	jmp    8007d0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800760:	89 ca                	mov    %ecx,%edx
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 c0 fc ff ff       	call   80042a <getuint>
  80076a:	89 c6                	mov    %eax,%esi
  80076c:	89 d7                	mov    %edx,%edi
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800773:	eb 5b                	jmp    8007d0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800775:	89 ca                	mov    %ecx,%edx
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
  80077a:	e8 ab fc ff ff       	call   80042a <getuint>
  80077f:	89 c6                	mov    %eax,%esi
  800781:	89 d7                	mov    %edx,%edi
			base = 8;
  800783:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800788:	eb 46                	jmp    8007d0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80078a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800795:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007af:	8b 30                	mov    (%eax),%esi
  8007b1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007bb:	eb 13                	jmp    8007d0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007bd:	89 ca                	mov    %ecx,%edx
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c2:	e8 63 fc ff ff       	call   80042a <getuint>
  8007c7:	89 c6                	mov    %eax,%esi
  8007c9:	89 d7                	mov    %edx,%edi
			base = 16;
  8007cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	89 34 24             	mov    %esi,(%esp)
  8007e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ea:	89 da                	mov    %ebx,%edx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	e8 6c fb ff ff       	call   800360 <printnum>
			break;
  8007f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007f7:	e9 cd fc ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800800:	89 04 24             	mov    %eax,(%esp)
  800803:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800806:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800809:	e9 bb fc ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80080e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800812:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800819:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081c:	eb 01                	jmp    80081f <vprintfmt+0x379>
  80081e:	4e                   	dec    %esi
  80081f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800823:	75 f9                	jne    80081e <vprintfmt+0x378>
  800825:	e9 9f fc ff ff       	jmp    8004c9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80082a:	83 c4 4c             	add    $0x4c,%esp
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5f                   	pop    %edi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	83 ec 28             	sub    $0x28,%esp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80083e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800841:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800845:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800848:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084f:	85 c0                	test   %eax,%eax
  800851:	74 30                	je     800883 <vsnprintf+0x51>
  800853:	85 d2                	test   %edx,%edx
  800855:	7e 33                	jle    80088a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085e:	8b 45 10             	mov    0x10(%ebp),%eax
  800861:	89 44 24 08          	mov    %eax,0x8(%esp)
  800865:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086c:	c7 04 24 64 04 80 00 	movl   $0x800464,(%esp)
  800873:	e8 2e fc ff ff       	call   8004a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	eb 0c                	jmp    80088f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800888:	eb 05                	jmp    80088f <vsnprintf+0x5d>
  80088a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80088f:	c9                   	leave  
  800890:	c3                   	ret    

00800891 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800897:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089e:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	89 04 24             	mov    %eax,(%esp)
  8008b2:	e8 7b ff ff ff       	call   800832 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    
  8008b9:	00 00                	add    %al,(%eax)
	...

008008bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	eb 01                	jmp    8008ca <strlen+0xe>
		n++;
  8008c9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ce:	75 f9                	jne    8008c9 <strlen+0xd>
		n++;
	return n;
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e0:	eb 01                	jmp    8008e3 <strnlen+0x11>
		n++;
  8008e2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e3:	39 d0                	cmp    %edx,%eax
  8008e5:	74 06                	je     8008ed <strnlen+0x1b>
  8008e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008eb:	75 f5                	jne    8008e2 <strnlen+0x10>
		n++;
	return n;
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	53                   	push   %ebx
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008fe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800901:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800904:	42                   	inc    %edx
  800905:	84 c9                	test   %cl,%cl
  800907:	75 f5                	jne    8008fe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800909:	5b                   	pop    %ebx
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800916:	89 1c 24             	mov    %ebx,(%esp)
  800919:	e8 9e ff ff ff       	call   8008bc <strlen>
	strcpy(dst + len, src);
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	89 54 24 04          	mov    %edx,0x4(%esp)
  800925:	01 d8                	add    %ebx,%eax
  800927:	89 04 24             	mov    %eax,(%esp)
  80092a:	e8 c0 ff ff ff       	call   8008ef <strcpy>
	return dst;
}
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	83 c4 08             	add    $0x8,%esp
  800934:	5b                   	pop    %ebx
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800942:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800945:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094a:	eb 0c                	jmp    800958 <strncpy+0x21>
		*dst++ = *src;
  80094c:	8a 1a                	mov    (%edx),%bl
  80094e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800951:	80 3a 01             	cmpb   $0x1,(%edx)
  800954:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800957:	41                   	inc    %ecx
  800958:	39 f1                	cmp    %esi,%ecx
  80095a:	75 f0                	jne    80094c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 75 08             	mov    0x8(%ebp),%esi
  800968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096e:	85 d2                	test   %edx,%edx
  800970:	75 0a                	jne    80097c <strlcpy+0x1c>
  800972:	89 f0                	mov    %esi,%eax
  800974:	eb 1a                	jmp    800990 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800976:	88 18                	mov    %bl,(%eax)
  800978:	40                   	inc    %eax
  800979:	41                   	inc    %ecx
  80097a:	eb 02                	jmp    80097e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80097e:	4a                   	dec    %edx
  80097f:	74 0a                	je     80098b <strlcpy+0x2b>
  800981:	8a 19                	mov    (%ecx),%bl
  800983:	84 db                	test   %bl,%bl
  800985:	75 ef                	jne    800976 <strlcpy+0x16>
  800987:	89 c2                	mov    %eax,%edx
  800989:	eb 02                	jmp    80098d <strlcpy+0x2d>
  80098b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80098d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800990:	29 f0                	sub    %esi,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099f:	eb 02                	jmp    8009a3 <strcmp+0xd>
		p++, q++;
  8009a1:	41                   	inc    %ecx
  8009a2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a3:	8a 01                	mov    (%ecx),%al
  8009a5:	84 c0                	test   %al,%al
  8009a7:	74 04                	je     8009ad <strcmp+0x17>
  8009a9:	3a 02                	cmp    (%edx),%al
  8009ab:	74 f4                	je     8009a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ad:	0f b6 c0             	movzbl %al,%eax
  8009b0:	0f b6 12             	movzbl (%edx),%edx
  8009b3:	29 d0                	sub    %edx,%eax
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009c4:	eb 03                	jmp    8009c9 <strncmp+0x12>
		n--, p++, q++;
  8009c6:	4a                   	dec    %edx
  8009c7:	40                   	inc    %eax
  8009c8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c9:	85 d2                	test   %edx,%edx
  8009cb:	74 14                	je     8009e1 <strncmp+0x2a>
  8009cd:	8a 18                	mov    (%eax),%bl
  8009cf:	84 db                	test   %bl,%bl
  8009d1:	74 04                	je     8009d7 <strncmp+0x20>
  8009d3:	3a 19                	cmp    (%ecx),%bl
  8009d5:	74 ef                	je     8009c6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d7:	0f b6 00             	movzbl (%eax),%eax
  8009da:	0f b6 11             	movzbl (%ecx),%edx
  8009dd:	29 d0                	sub    %edx,%eax
  8009df:	eb 05                	jmp    8009e6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f2:	eb 05                	jmp    8009f9 <strchr+0x10>
		if (*s == c)
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	74 0c                	je     800a04 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f8:	40                   	inc    %eax
  8009f9:	8a 10                	mov    (%eax),%dl
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	75 f5                	jne    8009f4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a0f:	eb 05                	jmp    800a16 <strfind+0x10>
		if (*s == c)
  800a11:	38 ca                	cmp    %cl,%dl
  800a13:	74 07                	je     800a1c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a15:	40                   	inc    %eax
  800a16:	8a 10                	mov    (%eax),%dl
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	75 f5                	jne    800a11 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2d:	85 c9                	test   %ecx,%ecx
  800a2f:	74 30                	je     800a61 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a37:	75 25                	jne    800a5e <memset+0x40>
  800a39:	f6 c1 03             	test   $0x3,%cl
  800a3c:	75 20                	jne    800a5e <memset+0x40>
		c &= 0xFF;
  800a3e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a41:	89 d3                	mov    %edx,%ebx
  800a43:	c1 e3 08             	shl    $0x8,%ebx
  800a46:	89 d6                	mov    %edx,%esi
  800a48:	c1 e6 18             	shl    $0x18,%esi
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	c1 e0 10             	shl    $0x10,%eax
  800a50:	09 f0                	or     %esi,%eax
  800a52:	09 d0                	or     %edx,%eax
  800a54:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a56:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a59:	fc                   	cld    
  800a5a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a5c:	eb 03                	jmp    800a61 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5e:	fc                   	cld    
  800a5f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a61:	89 f8                	mov    %edi,%eax
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a76:	39 c6                	cmp    %eax,%esi
  800a78:	73 34                	jae    800aae <memmove+0x46>
  800a7a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7d:	39 d0                	cmp    %edx,%eax
  800a7f:	73 2d                	jae    800aae <memmove+0x46>
		s += n;
		d += n;
  800a81:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a84:	f6 c2 03             	test   $0x3,%dl
  800a87:	75 1b                	jne    800aa4 <memmove+0x3c>
  800a89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8f:	75 13                	jne    800aa4 <memmove+0x3c>
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 0e                	jne    800aa4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a96:	83 ef 04             	sub    $0x4,%edi
  800a99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a9f:	fd                   	std    
  800aa0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa2:	eb 07                	jmp    800aab <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa4:	4f                   	dec    %edi
  800aa5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa8:	fd                   	std    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aab:	fc                   	cld    
  800aac:	eb 20                	jmp    800ace <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab4:	75 13                	jne    800ac9 <memmove+0x61>
  800ab6:	a8 03                	test   $0x3,%al
  800ab8:	75 0f                	jne    800ac9 <memmove+0x61>
  800aba:	f6 c1 03             	test   $0x3,%cl
  800abd:	75 0a                	jne    800ac9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ac2:	89 c7                	mov    %eax,%edi
  800ac4:	fc                   	cld    
  800ac5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac7:	eb 05                	jmp    800ace <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac9:	89 c7                	mov    %eax,%edi
  800acb:	fc                   	cld    
  800acc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad8:	8b 45 10             	mov    0x10(%ebp),%eax
  800adb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800adf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	89 04 24             	mov    %eax,(%esp)
  800aec:	e8 77 ff ff ff       	call   800a68 <memmove>
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	eb 16                	jmp    800b1f <memcmp+0x2c>
		if (*s1 != *s2)
  800b09:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b0c:	42                   	inc    %edx
  800b0d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b11:	38 c8                	cmp    %cl,%al
  800b13:	74 0a                	je     800b1f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b15:	0f b6 c0             	movzbl %al,%eax
  800b18:	0f b6 c9             	movzbl %cl,%ecx
  800b1b:	29 c8                	sub    %ecx,%eax
  800b1d:	eb 09                	jmp    800b28 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1f:	39 da                	cmp    %ebx,%edx
  800b21:	75 e6                	jne    800b09 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3b:	eb 05                	jmp    800b42 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3d:	38 08                	cmp    %cl,(%eax)
  800b3f:	74 05                	je     800b46 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b41:	40                   	inc    %eax
  800b42:	39 d0                	cmp    %edx,%eax
  800b44:	72 f7                	jb     800b3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b54:	eb 01                	jmp    800b57 <strtol+0xf>
		s++;
  800b56:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b57:	8a 02                	mov    (%edx),%al
  800b59:	3c 20                	cmp    $0x20,%al
  800b5b:	74 f9                	je     800b56 <strtol+0xe>
  800b5d:	3c 09                	cmp    $0x9,%al
  800b5f:	74 f5                	je     800b56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b61:	3c 2b                	cmp    $0x2b,%al
  800b63:	75 08                	jne    800b6d <strtol+0x25>
		s++;
  800b65:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b66:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6b:	eb 13                	jmp    800b80 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b6d:	3c 2d                	cmp    $0x2d,%al
  800b6f:	75 0a                	jne    800b7b <strtol+0x33>
		s++, neg = 1;
  800b71:	8d 52 01             	lea    0x1(%edx),%edx
  800b74:	bf 01 00 00 00       	mov    $0x1,%edi
  800b79:	eb 05                	jmp    800b80 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	74 05                	je     800b89 <strtol+0x41>
  800b84:	83 fb 10             	cmp    $0x10,%ebx
  800b87:	75 28                	jne    800bb1 <strtol+0x69>
  800b89:	8a 02                	mov    (%edx),%al
  800b8b:	3c 30                	cmp    $0x30,%al
  800b8d:	75 10                	jne    800b9f <strtol+0x57>
  800b8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b93:	75 0a                	jne    800b9f <strtol+0x57>
		s += 2, base = 16;
  800b95:	83 c2 02             	add    $0x2,%edx
  800b98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9d:	eb 12                	jmp    800bb1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b9f:	85 db                	test   %ebx,%ebx
  800ba1:	75 0e                	jne    800bb1 <strtol+0x69>
  800ba3:	3c 30                	cmp    $0x30,%al
  800ba5:	75 05                	jne    800bac <strtol+0x64>
		s++, base = 8;
  800ba7:	42                   	inc    %edx
  800ba8:	b3 08                	mov    $0x8,%bl
  800baa:	eb 05                	jmp    800bb1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bac:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb8:	8a 0a                	mov    (%edx),%cl
  800bba:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bbd:	80 fb 09             	cmp    $0x9,%bl
  800bc0:	77 08                	ja     800bca <strtol+0x82>
			dig = *s - '0';
  800bc2:	0f be c9             	movsbl %cl,%ecx
  800bc5:	83 e9 30             	sub    $0x30,%ecx
  800bc8:	eb 1e                	jmp    800be8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bca:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bcd:	80 fb 19             	cmp    $0x19,%bl
  800bd0:	77 08                	ja     800bda <strtol+0x92>
			dig = *s - 'a' + 10;
  800bd2:	0f be c9             	movsbl %cl,%ecx
  800bd5:	83 e9 57             	sub    $0x57,%ecx
  800bd8:	eb 0e                	jmp    800be8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bda:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bdd:	80 fb 19             	cmp    $0x19,%bl
  800be0:	77 12                	ja     800bf4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800be2:	0f be c9             	movsbl %cl,%ecx
  800be5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800be8:	39 f1                	cmp    %esi,%ecx
  800bea:	7d 0c                	jge    800bf8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bec:	42                   	inc    %edx
  800bed:	0f af c6             	imul   %esi,%eax
  800bf0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bf2:	eb c4                	jmp    800bb8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bf4:	89 c1                	mov    %eax,%ecx
  800bf6:	eb 02                	jmp    800bfa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bfa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfe:	74 05                	je     800c05 <strtol+0xbd>
		*endptr = (char *) s;
  800c00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c03:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c05:	85 ff                	test   %edi,%edi
  800c07:	74 04                	je     800c0d <strtol+0xc5>
  800c09:	89 c8                	mov    %ecx,%eax
  800c0b:	f7 d8                	neg    %eax
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
	...

00800c14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 c3                	mov    %eax,%ebx
  800c27:	89 c7                	mov    %eax,%edi
  800c29:	89 c6                	mov    %eax,%esi
  800c2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c42:	89 d1                	mov    %edx,%ecx
  800c44:	89 d3                	mov    %edx,%ebx
  800c46:	89 d7                	mov    %edx,%edi
  800c48:	89 d6                	mov    %edx,%esi
  800c4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 cb                	mov    %ecx,%ebx
  800c69:	89 cf                	mov    %ecx,%edi
  800c6b:	89 ce                	mov    %ecx,%esi
  800c6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	7e 28                	jle    800c9b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  800c86:	00 
  800c87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8e:	00 
  800c8f:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800c96:	e8 b1 f5 ff ff       	call   80024c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9b:	83 c4 2c             	add    $0x2c,%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cae:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_yield>:

void
sys_yield(void)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	be 00 00 00 00       	mov    $0x0,%esi
  800cef:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 f7                	mov    %esi,%edi
  800cff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 28                	jle    800d2d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d09:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d10:	00 
  800d11:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  800d18:	00 
  800d19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d20:	00 
  800d21:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800d28:	e8 1f f5 ff ff       	call   80024c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2d:	83 c4 2c             	add    $0x2c,%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d43:	8b 75 18             	mov    0x18(%ebp),%esi
  800d46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7e 28                	jle    800d80 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d63:	00 
  800d64:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  800d6b:	00 
  800d6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d73:	00 
  800d74:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800d7b:	e8 cc f4 ff ff       	call   80024c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d80:	83 c4 2c             	add    $0x2c,%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d96:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 df                	mov    %ebx,%edi
  800da3:	89 de                	mov    %ebx,%esi
  800da5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 28                	jle    800dd3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800db6:	00 
  800db7:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc6:	00 
  800dc7:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800dce:	e8 79 f4 ff ff       	call   80024c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd3:	83 c4 2c             	add    $0x2c,%esp
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
  800de1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	89 df                	mov    %ebx,%edi
  800df6:	89 de                	mov    %ebx,%esi
  800df8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	7e 28                	jle    800e26 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e02:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e09:	00 
  800e0a:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  800e11:	00 
  800e12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e19:	00 
  800e1a:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800e21:	e8 26 f4 ff ff       	call   80024c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e26:	83 c4 2c             	add    $0x2c,%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 df                	mov    %ebx,%edi
  800e49:	89 de                	mov    %ebx,%esi
  800e4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7e 28                	jle    800e79 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e55:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  800e64:	00 
  800e65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6c:	00 
  800e6d:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800e74:	e8 d3 f3 ff ff       	call   80024c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e79:	83 c4 2c             	add    $0x2c,%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 df                	mov    %ebx,%edi
  800e9c:	89 de                	mov    %ebx,%esi
  800e9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 28                	jle    800ecc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800ec7:	e8 80 f3 ff ff       	call   80024c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ecc:	83 c4 2c             	add    $0x2c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eda:	be 00 00 00 00       	mov    $0x0,%esi
  800edf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f05:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0d:	89 cb                	mov    %ecx,%ebx
  800f0f:	89 cf                	mov    %ecx,%edi
  800f11:	89 ce                	mov    %ecx,%esi
  800f13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f15:	85 c0                	test   %eax,%eax
  800f17:	7e 28                	jle    800f41 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f24:	00 
  800f25:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800f3c:	e8 0b f3 ff ff       	call   80024c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f41:	83 c4 2c             	add    $0x2c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f54:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f59:	89 d1                	mov    %edx,%ecx
  800f5b:	89 d3                	mov    %edx,%ebx
  800f5d:	89 d7                	mov    %edx,%edi
  800f5f:	89 d6                	mov    %edx,%esi
  800f61:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	57                   	push   %edi
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f73:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	89 df                	mov    %ebx,%edi
  800f80:	89 de                	mov    %ebx,%esi
  800f82:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f94:	b8 10 00 00 00       	mov    $0x10,%eax
  800f99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9f:	89 df                	mov    %ebx,%edi
  800fa1:	89 de                	mov    %ebx,%esi
  800fa3:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    
	...

00800fac <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 24             	sub    $0x24,%esp
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fb6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800fb8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fbc:	74 2d                	je     800feb <pgfault+0x3f>
  800fbe:	89 d8                	mov    %ebx,%eax
  800fc0:	c1 e8 16             	shr    $0x16,%eax
  800fc3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fca:	a8 01                	test   $0x1,%al
  800fcc:	74 1d                	je     800feb <pgfault+0x3f>
  800fce:	89 d8                	mov    %ebx,%eax
  800fd0:	c1 e8 0c             	shr    $0xc,%eax
  800fd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fda:	f6 c2 01             	test   $0x1,%dl
  800fdd:	74 0c                	je     800feb <pgfault+0x3f>
  800fdf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe6:	f6 c4 08             	test   $0x8,%ah
  800fe9:	75 1c                	jne    801007 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  800feb:	c7 44 24 08 90 2e 80 	movl   $0x802e90,0x8(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800ffa:	00 
  800ffb:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  801002:	e8 45 f2 ff ff       	call   80024c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  801007:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  80100d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801014:	00 
  801015:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80101c:	00 
  80101d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801024:	e8 b8 fc ff ff       	call   800ce1 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  801029:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801030:	00 
  801031:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801035:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80103c:	e8 91 fa ff ff       	call   800ad2 <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  801041:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801048:	00 
  801049:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80104d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801064:	e8 cc fc ff ff       	call   800d35 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  801069:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801078:	e8 0b fd ff ff       	call   800d88 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  80107d:	83 c4 24             	add    $0x24,%esp
  801080:	5b                   	pop    %ebx
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80108c:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  801093:	e8 74 15 00 00       	call   80260c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801098:	ba 07 00 00 00       	mov    $0x7,%edx
  80109d:	89 d0                	mov    %edx,%eax
  80109f:	cd 30                	int    $0x30
  8010a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a4:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 20                	jns    8010ca <fork+0x47>
		panic("sys_exofork: %e", envid);
  8010aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ae:	c7 44 24 08 de 2e 80 	movl   $0x802ede,0x8(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  8010bd:	00 
  8010be:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  8010c5:	e8 82 f1 ff ff       	call   80024c <_panic>
	if (envid == 0)
  8010ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010ce:	75 25                	jne    8010f5 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8010d0:	e8 ce fb ff ff       	call   800ca3 <sys_getenvid>
  8010d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010e1:	c1 e0 07             	shl    $0x7,%eax
  8010e4:	29 d0                	sub    %edx,%eax
  8010e6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010eb:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8010f0:	e9 43 02 00 00       	jmp    801338 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  8010f5:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  8010fa:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801100:	0f 84 85 01 00 00    	je     80128b <fork+0x208>
  801106:	89 d8                	mov    %ebx,%eax
  801108:	c1 e8 16             	shr    $0x16,%eax
  80110b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801112:	a8 01                	test   $0x1,%al
  801114:	0f 84 5f 01 00 00    	je     801279 <fork+0x1f6>
  80111a:	89 d8                	mov    %ebx,%eax
  80111c:	c1 e8 0c             	shr    $0xc,%eax
  80111f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801126:	f6 c2 01             	test   $0x1,%dl
  801129:	0f 84 4a 01 00 00    	je     801279 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  80112f:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  801131:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801138:	f6 c6 04             	test   $0x4,%dh
  80113b:	74 50                	je     80118d <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  80113d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801144:	25 07 0e 00 00       	and    $0xe07,%eax
  801149:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801151:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801155:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801160:	e8 d0 fb ff ff       	call   800d35 <sys_page_map>
  801165:	85 c0                	test   %eax,%eax
  801167:	0f 89 0c 01 00 00    	jns    801279 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  80116d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801171:	c7 44 24 08 ee 2e 80 	movl   $0x802eee,0x8(%esp)
  801178:	00 
  801179:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801180:	00 
  801181:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  801188:	e8 bf f0 ff ff       	call   80024c <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  80118d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801194:	f6 c2 02             	test   $0x2,%dl
  801197:	75 10                	jne    8011a9 <fork+0x126>
  801199:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a0:	f6 c4 08             	test   $0x8,%ah
  8011a3:	0f 84 8c 00 00 00    	je     801235 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  8011a9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011b0:	00 
  8011b1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011b5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c4:	e8 6c fb ff ff       	call   800d35 <sys_page_map>
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	79 20                	jns    8011ed <fork+0x16a>
		{
			panic("duppage error: %e",e);
  8011cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011d1:	c7 44 24 08 ee 2e 80 	movl   $0x802eee,0x8(%esp)
  8011d8:	00 
  8011d9:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8011e0:	00 
  8011e1:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  8011e8:	e8 5f f0 ff ff       	call   80024c <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  8011ed:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011f4:	00 
  8011f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801200:	00 
  801201:	89 74 24 04          	mov    %esi,0x4(%esp)
  801205:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120c:	e8 24 fb ff ff       	call   800d35 <sys_page_map>
  801211:	85 c0                	test   %eax,%eax
  801213:	79 64                	jns    801279 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801215:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801219:	c7 44 24 08 ee 2e 80 	movl   $0x802eee,0x8(%esp)
  801220:	00 
  801221:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  801230:	e8 17 f0 ff ff       	call   80024c <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  801235:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80123c:	00 
  80123d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801241:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801245:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801249:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801250:	e8 e0 fa ff ff       	call   800d35 <sys_page_map>
  801255:	85 c0                	test   %eax,%eax
  801257:	79 20                	jns    801279 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125d:	c7 44 24 08 ee 2e 80 	movl   $0x802eee,0x8(%esp)
  801264:	00 
  801265:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80126c:	00 
  80126d:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  801274:	e8 d3 ef ff ff       	call   80024c <_panic>
  801279:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  80127f:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801285:	0f 85 6f fe ff ff    	jne    8010fa <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  80128b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801292:	00 
  801293:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80129a:	ee 
  80129b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80129e:	89 04 24             	mov    %eax,(%esp)
  8012a1:	e8 3b fa ff ff       	call   800ce1 <sys_page_alloc>
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	79 20                	jns    8012ca <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  8012aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ae:	c7 44 24 08 00 2f 80 	movl   $0x802f00,0x8(%esp)
  8012b5:	00 
  8012b6:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  8012bd:	00 
  8012be:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  8012c5:	e8 82 ef ff ff       	call   80024c <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8012ca:	c7 44 24 04 58 26 80 	movl   $0x802658,0x4(%esp)
  8012d1:	00 
  8012d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d5:	89 04 24             	mov    %eax,(%esp)
  8012d8:	e8 a4 fb ff ff       	call   800e81 <sys_env_set_pgfault_upcall>
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	79 20                	jns    801301 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  8012e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e5:	c7 44 24 08 b4 2e 80 	movl   $0x802eb4,0x8(%esp)
  8012ec:	00 
  8012ed:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  8012f4:	00 
  8012f5:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  8012fc:	e8 4b ef ff ff       	call   80024c <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801301:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801308:	00 
  801309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80130c:	89 04 24             	mov    %eax,(%esp)
  80130f:	e8 c7 fa ff ff       	call   800ddb <sys_env_set_status>
  801314:	85 c0                	test   %eax,%eax
  801316:	79 20                	jns    801338 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801318:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80131c:	c7 44 24 08 13 2f 80 	movl   $0x802f13,0x8(%esp)
  801323:	00 
  801324:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80132b:	00 
  80132c:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  801333:	e8 14 ef ff ff       	call   80024c <_panic>

	return envid;
	// panic("fork not implemented");
}
  801338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80133b:	83 c4 3c             	add    $0x3c,%esp
  80133e:	5b                   	pop    %ebx
  80133f:	5e                   	pop    %esi
  801340:	5f                   	pop    %edi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <sfork>:

// Challenge!
int
sfork(void)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801349:	c7 44 24 08 2a 2f 80 	movl   $0x802f2a,0x8(%esp)
  801350:	00 
  801351:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801358:	00 
  801359:	c7 04 24 d3 2e 80 00 	movl   $0x802ed3,(%esp)
  801360:	e8 e7 ee ff ff       	call   80024c <_panic>
  801365:	00 00                	add    %al,(%eax)
	...

00801368 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80136b:	8b 45 08             	mov    0x8(%ebp),%eax
  80136e:	05 00 00 00 30       	add    $0x30000000,%eax
  801373:	c1 e8 0c             	shr    $0xc,%eax
}
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80137e:	8b 45 08             	mov    0x8(%ebp),%eax
  801381:	89 04 24             	mov    %eax,(%esp)
  801384:	e8 df ff ff ff       	call   801368 <fd2num>
  801389:	c1 e0 0c             	shl    $0xc,%eax
  80138c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801391:	c9                   	leave  
  801392:	c3                   	ret    

00801393 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	53                   	push   %ebx
  801397:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80139a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80139f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	c1 ea 16             	shr    $0x16,%edx
  8013a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ad:	f6 c2 01             	test   $0x1,%dl
  8013b0:	74 11                	je     8013c3 <fd_alloc+0x30>
  8013b2:	89 c2                	mov    %eax,%edx
  8013b4:	c1 ea 0c             	shr    $0xc,%edx
  8013b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013be:	f6 c2 01             	test   $0x1,%dl
  8013c1:	75 09                	jne    8013cc <fd_alloc+0x39>
			*fd_store = fd;
  8013c3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ca:	eb 17                	jmp    8013e3 <fd_alloc+0x50>
  8013cc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013d1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013d6:	75 c7                	jne    80139f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013de:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013e3:	5b                   	pop    %ebx
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013ec:	83 f8 1f             	cmp    $0x1f,%eax
  8013ef:	77 36                	ja     801427 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013f1:	c1 e0 0c             	shl    $0xc,%eax
  8013f4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013f9:	89 c2                	mov    %eax,%edx
  8013fb:	c1 ea 16             	shr    $0x16,%edx
  8013fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801405:	f6 c2 01             	test   $0x1,%dl
  801408:	74 24                	je     80142e <fd_lookup+0x48>
  80140a:	89 c2                	mov    %eax,%edx
  80140c:	c1 ea 0c             	shr    $0xc,%edx
  80140f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801416:	f6 c2 01             	test   $0x1,%dl
  801419:	74 1a                	je     801435 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80141b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80141e:	89 02                	mov    %eax,(%edx)
	return 0;
  801420:	b8 00 00 00 00       	mov    $0x0,%eax
  801425:	eb 13                	jmp    80143a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801427:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142c:	eb 0c                	jmp    80143a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80142e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801433:	eb 05                	jmp    80143a <fd_lookup+0x54>
  801435:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	53                   	push   %ebx
  801440:	83 ec 14             	sub    $0x14,%esp
  801443:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801449:	ba 00 00 00 00       	mov    $0x0,%edx
  80144e:	eb 0e                	jmp    80145e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801450:	39 08                	cmp    %ecx,(%eax)
  801452:	75 09                	jne    80145d <dev_lookup+0x21>
			*dev = devtab[i];
  801454:	89 03                	mov    %eax,(%ebx)
			return 0;
  801456:	b8 00 00 00 00       	mov    $0x0,%eax
  80145b:	eb 33                	jmp    801490 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80145d:	42                   	inc    %edx
  80145e:	8b 04 95 c0 2f 80 00 	mov    0x802fc0(,%edx,4),%eax
  801465:	85 c0                	test   %eax,%eax
  801467:	75 e7                	jne    801450 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801469:	a1 08 50 80 00       	mov    0x805008,%eax
  80146e:	8b 40 48             	mov    0x48(%eax),%eax
  801471:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801475:	89 44 24 04          	mov    %eax,0x4(%esp)
  801479:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  801480:	e8 bf ee ff ff       	call   800344 <cprintf>
	*dev = 0;
  801485:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80148b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801490:	83 c4 14             	add    $0x14,%esp
  801493:	5b                   	pop    %ebx
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    

00801496 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	56                   	push   %esi
  80149a:	53                   	push   %ebx
  80149b:	83 ec 30             	sub    $0x30,%esp
  80149e:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a1:	8a 45 0c             	mov    0xc(%ebp),%al
  8014a4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014a7:	89 34 24             	mov    %esi,(%esp)
  8014aa:	e8 b9 fe ff ff       	call   801368 <fd2num>
  8014af:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014b2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014b6:	89 04 24             	mov    %eax,(%esp)
  8014b9:	e8 28 ff ff ff       	call   8013e6 <fd_lookup>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 05                	js     8014c9 <fd_close+0x33>
	    || fd != fd2)
  8014c4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014c7:	74 0d                	je     8014d6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8014c9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014cd:	75 46                	jne    801515 <fd_close+0x7f>
  8014cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d4:	eb 3f                	jmp    801515 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dd:	8b 06                	mov    (%esi),%eax
  8014df:	89 04 24             	mov    %eax,(%esp)
  8014e2:	e8 55 ff ff ff       	call   80143c <dev_lookup>
  8014e7:	89 c3                	mov    %eax,%ebx
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 18                	js     801505 <fd_close+0x6f>
		if (dev->dev_close)
  8014ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f0:	8b 40 10             	mov    0x10(%eax),%eax
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	74 09                	je     801500 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014f7:	89 34 24             	mov    %esi,(%esp)
  8014fa:	ff d0                	call   *%eax
  8014fc:	89 c3                	mov    %eax,%ebx
  8014fe:	eb 05                	jmp    801505 <fd_close+0x6f>
		else
			r = 0;
  801500:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801505:	89 74 24 04          	mov    %esi,0x4(%esp)
  801509:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801510:	e8 73 f8 ff ff       	call   800d88 <sys_page_unmap>
	return r;
}
  801515:	89 d8                	mov    %ebx,%eax
  801517:	83 c4 30             	add    $0x30,%esp
  80151a:	5b                   	pop    %ebx
  80151b:	5e                   	pop    %esi
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    

0080151e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
  80152e:	89 04 24             	mov    %eax,(%esp)
  801531:	e8 b0 fe ff ff       	call   8013e6 <fd_lookup>
  801536:	85 c0                	test   %eax,%eax
  801538:	78 13                	js     80154d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80153a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801541:	00 
  801542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801545:	89 04 24             	mov    %eax,(%esp)
  801548:	e8 49 ff ff ff       	call   801496 <fd_close>
}
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <close_all>:

void
close_all(void)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	53                   	push   %ebx
  801553:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801556:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80155b:	89 1c 24             	mov    %ebx,(%esp)
  80155e:	e8 bb ff ff ff       	call   80151e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801563:	43                   	inc    %ebx
  801564:	83 fb 20             	cmp    $0x20,%ebx
  801567:	75 f2                	jne    80155b <close_all+0xc>
		close(i);
}
  801569:	83 c4 14             	add    $0x14,%esp
  80156c:	5b                   	pop    %ebx
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    

0080156f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	57                   	push   %edi
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	83 ec 4c             	sub    $0x4c,%esp
  801578:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80157b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80157e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801582:	8b 45 08             	mov    0x8(%ebp),%eax
  801585:	89 04 24             	mov    %eax,(%esp)
  801588:	e8 59 fe ff ff       	call   8013e6 <fd_lookup>
  80158d:	89 c3                	mov    %eax,%ebx
  80158f:	85 c0                	test   %eax,%eax
  801591:	0f 88 e3 00 00 00    	js     80167a <dup+0x10b>
		return r;
	close(newfdnum);
  801597:	89 3c 24             	mov    %edi,(%esp)
  80159a:	e8 7f ff ff ff       	call   80151e <close>

	newfd = INDEX2FD(newfdnum);
  80159f:	89 fe                	mov    %edi,%esi
  8015a1:	c1 e6 0c             	shl    $0xc,%esi
  8015a4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015ad:	89 04 24             	mov    %eax,(%esp)
  8015b0:	e8 c3 fd ff ff       	call   801378 <fd2data>
  8015b5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015b7:	89 34 24             	mov    %esi,(%esp)
  8015ba:	e8 b9 fd ff ff       	call   801378 <fd2data>
  8015bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	c1 e8 16             	shr    $0x16,%eax
  8015c7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ce:	a8 01                	test   $0x1,%al
  8015d0:	74 46                	je     801618 <dup+0xa9>
  8015d2:	89 d8                	mov    %ebx,%eax
  8015d4:	c1 e8 0c             	shr    $0xc,%eax
  8015d7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015de:	f6 c2 01             	test   $0x1,%dl
  8015e1:	74 35                	je     801618 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801601:	00 
  801602:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801606:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160d:	e8 23 f7 ff ff       	call   800d35 <sys_page_map>
  801612:	89 c3                	mov    %eax,%ebx
  801614:	85 c0                	test   %eax,%eax
  801616:	78 3b                	js     801653 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801618:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	c1 ea 0c             	shr    $0xc,%edx
  801620:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801627:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80162d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801631:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801635:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80163c:	00 
  80163d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801641:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801648:	e8 e8 f6 ff ff       	call   800d35 <sys_page_map>
  80164d:	89 c3                	mov    %eax,%ebx
  80164f:	85 c0                	test   %eax,%eax
  801651:	79 25                	jns    801678 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801653:	89 74 24 04          	mov    %esi,0x4(%esp)
  801657:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165e:	e8 25 f7 ff ff       	call   800d88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801663:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801666:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801671:	e8 12 f7 ff ff       	call   800d88 <sys_page_unmap>
	return r;
  801676:	eb 02                	jmp    80167a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801678:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80167a:	89 d8                	mov    %ebx,%eax
  80167c:	83 c4 4c             	add    $0x4c,%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5f                   	pop    %edi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	53                   	push   %ebx
  801688:	83 ec 24             	sub    $0x24,%esp
  80168b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801691:	89 44 24 04          	mov    %eax,0x4(%esp)
  801695:	89 1c 24             	mov    %ebx,(%esp)
  801698:	e8 49 fd ff ff       	call   8013e6 <fd_lookup>
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 6d                	js     80170e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ab:	8b 00                	mov    (%eax),%eax
  8016ad:	89 04 24             	mov    %eax,(%esp)
  8016b0:	e8 87 fd ff ff       	call   80143c <dev_lookup>
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 55                	js     80170e <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bc:	8b 50 08             	mov    0x8(%eax),%edx
  8016bf:	83 e2 03             	and    $0x3,%edx
  8016c2:	83 fa 01             	cmp    $0x1,%edx
  8016c5:	75 23                	jne    8016ea <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c7:	a1 08 50 80 00       	mov    0x805008,%eax
  8016cc:	8b 40 48             	mov    0x48(%eax),%eax
  8016cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d7:	c7 04 24 84 2f 80 00 	movl   $0x802f84,(%esp)
  8016de:	e8 61 ec ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  8016e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e8:	eb 24                	jmp    80170e <read+0x8a>
	}
	if (!dev->dev_read)
  8016ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ed:	8b 52 08             	mov    0x8(%edx),%edx
  8016f0:	85 d2                	test   %edx,%edx
  8016f2:	74 15                	je     801709 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801702:	89 04 24             	mov    %eax,(%esp)
  801705:	ff d2                	call   *%edx
  801707:	eb 05                	jmp    80170e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801709:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80170e:	83 c4 24             	add    $0x24,%esp
  801711:	5b                   	pop    %ebx
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	57                   	push   %edi
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
  80171a:	83 ec 1c             	sub    $0x1c,%esp
  80171d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801720:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801723:	bb 00 00 00 00       	mov    $0x0,%ebx
  801728:	eb 23                	jmp    80174d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80172a:	89 f0                	mov    %esi,%eax
  80172c:	29 d8                	sub    %ebx,%eax
  80172e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801732:	8b 45 0c             	mov    0xc(%ebp),%eax
  801735:	01 d8                	add    %ebx,%eax
  801737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173b:	89 3c 24             	mov    %edi,(%esp)
  80173e:	e8 41 ff ff ff       	call   801684 <read>
		if (m < 0)
  801743:	85 c0                	test   %eax,%eax
  801745:	78 10                	js     801757 <readn+0x43>
			return m;
		if (m == 0)
  801747:	85 c0                	test   %eax,%eax
  801749:	74 0a                	je     801755 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80174b:	01 c3                	add    %eax,%ebx
  80174d:	39 f3                	cmp    %esi,%ebx
  80174f:	72 d9                	jb     80172a <readn+0x16>
  801751:	89 d8                	mov    %ebx,%eax
  801753:	eb 02                	jmp    801757 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801755:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801757:	83 c4 1c             	add    $0x1c,%esp
  80175a:	5b                   	pop    %ebx
  80175b:	5e                   	pop    %esi
  80175c:	5f                   	pop    %edi
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	83 ec 24             	sub    $0x24,%esp
  801766:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801769:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801770:	89 1c 24             	mov    %ebx,(%esp)
  801773:	e8 6e fc ff ff       	call   8013e6 <fd_lookup>
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 68                	js     8017e4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801783:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801786:	8b 00                	mov    (%eax),%eax
  801788:	89 04 24             	mov    %eax,(%esp)
  80178b:	e8 ac fc ff ff       	call   80143c <dev_lookup>
  801790:	85 c0                	test   %eax,%eax
  801792:	78 50                	js     8017e4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801794:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801797:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80179b:	75 23                	jne    8017c0 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80179d:	a1 08 50 80 00       	mov    0x805008,%eax
  8017a2:	8b 40 48             	mov    0x48(%eax),%eax
  8017a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ad:	c7 04 24 a0 2f 80 00 	movl   $0x802fa0,(%esp)
  8017b4:	e8 8b eb ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  8017b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017be:	eb 24                	jmp    8017e4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c3:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c6:	85 d2                	test   %edx,%edx
  8017c8:	74 15                	je     8017df <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017d8:	89 04 24             	mov    %eax,(%esp)
  8017db:	ff d2                	call   *%edx
  8017dd:	eb 05                	jmp    8017e4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017e4:	83 c4 24             	add    $0x24,%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	e8 e4 fb ff ff       	call   8013e6 <fd_lookup>
  801802:	85 c0                	test   %eax,%eax
  801804:	78 0e                	js     801814 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801806:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801809:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80180f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801814:	c9                   	leave  
  801815:	c3                   	ret    

00801816 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	53                   	push   %ebx
  80181a:	83 ec 24             	sub    $0x24,%esp
  80181d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801820:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	89 1c 24             	mov    %ebx,(%esp)
  80182a:	e8 b7 fb ff ff       	call   8013e6 <fd_lookup>
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 61                	js     801894 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801833:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801836:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183d:	8b 00                	mov    (%eax),%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 f5 fb ff ff       	call   80143c <dev_lookup>
  801847:	85 c0                	test   %eax,%eax
  801849:	78 49                	js     801894 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80184b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801852:	75 23                	jne    801877 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801854:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801859:	8b 40 48             	mov    0x48(%eax),%eax
  80185c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801860:	89 44 24 04          	mov    %eax,0x4(%esp)
  801864:	c7 04 24 60 2f 80 00 	movl   $0x802f60,(%esp)
  80186b:	e8 d4 ea ff ff       	call   800344 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801870:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801875:	eb 1d                	jmp    801894 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801877:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187a:	8b 52 18             	mov    0x18(%edx),%edx
  80187d:	85 d2                	test   %edx,%edx
  80187f:	74 0e                	je     80188f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801884:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801888:	89 04 24             	mov    %eax,(%esp)
  80188b:	ff d2                	call   *%edx
  80188d:	eb 05                	jmp    801894 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80188f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801894:	83 c4 24             	add    $0x24,%esp
  801897:	5b                   	pop    %ebx
  801898:	5d                   	pop    %ebp
  801899:	c3                   	ret    

0080189a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	53                   	push   %ebx
  80189e:	83 ec 24             	sub    $0x24,%esp
  8018a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	89 04 24             	mov    %eax,(%esp)
  8018b1:	e8 30 fb ff ff       	call   8013e6 <fd_lookup>
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 52                	js     80190c <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c4:	8b 00                	mov    (%eax),%eax
  8018c6:	89 04 24             	mov    %eax,(%esp)
  8018c9:	e8 6e fb ff ff       	call   80143c <dev_lookup>
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 3a                	js     80190c <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018d9:	74 2c                	je     801907 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018e5:	00 00 00 
	stat->st_isdir = 0;
  8018e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ef:	00 00 00 
	stat->st_dev = dev;
  8018f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018ff:	89 14 24             	mov    %edx,(%esp)
  801902:	ff 50 14             	call   *0x14(%eax)
  801905:	eb 05                	jmp    80190c <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801907:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80190c:	83 c4 24             	add    $0x24,%esp
  80190f:	5b                   	pop    %ebx
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80191a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801921:	00 
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	89 04 24             	mov    %eax,(%esp)
  801928:	e8 2a 02 00 00       	call   801b57 <open>
  80192d:	89 c3                	mov    %eax,%ebx
  80192f:	85 c0                	test   %eax,%eax
  801931:	78 1b                	js     80194e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801933:	8b 45 0c             	mov    0xc(%ebp),%eax
  801936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193a:	89 1c 24             	mov    %ebx,(%esp)
  80193d:	e8 58 ff ff ff       	call   80189a <fstat>
  801942:	89 c6                	mov    %eax,%esi
	close(fd);
  801944:	89 1c 24             	mov    %ebx,(%esp)
  801947:	e8 d2 fb ff ff       	call   80151e <close>
	return r;
  80194c:	89 f3                	mov    %esi,%ebx
}
  80194e:	89 d8                	mov    %ebx,%eax
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	5b                   	pop    %ebx
  801954:	5e                   	pop    %esi
  801955:	5d                   	pop    %ebp
  801956:	c3                   	ret    
	...

00801958 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	56                   	push   %esi
  80195c:	53                   	push   %ebx
  80195d:	83 ec 10             	sub    $0x10,%esp
  801960:	89 c3                	mov    %eax,%ebx
  801962:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801964:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80196b:	75 11                	jne    80197e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80196d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801974:	e8 fa 0d 00 00       	call   802773 <ipc_find_env>
  801979:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80197e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801985:	00 
  801986:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80198d:	00 
  80198e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801992:	a1 00 50 80 00       	mov    0x805000,%eax
  801997:	89 04 24             	mov    %eax,(%esp)
  80199a:	e8 51 0d 00 00       	call   8026f0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80199f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019a6:	00 
  8019a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b2:	e8 c9 0c 00 00       	call   802680 <ipc_recv>
}
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ca:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dc:	b8 02 00 00 00       	mov    $0x2,%eax
  8019e1:	e8 72 ff ff ff       	call   801958 <fsipc>
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8019f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fe:	b8 06 00 00 00       	mov    $0x6,%eax
  801a03:	e8 50 ff ff ff       	call   801958 <fsipc>
}
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 14             	sub    $0x14,%esp
  801a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a14:	8b 45 08             	mov    0x8(%ebp),%eax
  801a17:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a24:	b8 05 00 00 00       	mov    $0x5,%eax
  801a29:	e8 2a ff ff ff       	call   801958 <fsipc>
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 2b                	js     801a5d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a32:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a39:	00 
  801a3a:	89 1c 24             	mov    %ebx,(%esp)
  801a3d:	e8 ad ee ff ff       	call   8008ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a42:	a1 80 60 80 00       	mov    0x806080,%eax
  801a47:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a4d:	a1 84 60 80 00       	mov    0x806084,%eax
  801a52:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5d:	83 c4 14             	add    $0x14,%esp
  801a60:	5b                   	pop    %ebx
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    

00801a63 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 18             	sub    $0x18,%esp
  801a69:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a6c:	8b 55 08             	mov    0x8(%ebp),%edx
  801a6f:	8b 52 0c             	mov    0xc(%edx),%edx
  801a72:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801a78:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801a7d:	89 c2                	mov    %eax,%edx
  801a7f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a84:	76 05                	jbe    801a8b <devfile_write+0x28>
  801a86:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801a8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a96:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801a9d:	e8 30 f0 ff ff       	call   800ad2 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa7:	b8 04 00 00 00       	mov    $0x4,%eax
  801aac:	e8 a7 fe ff ff       	call   801958 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    

00801ab3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	56                   	push   %esi
  801ab7:	53                   	push   %ebx
  801ab8:	83 ec 10             	sub    $0x10,%esp
  801abb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801abe:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac4:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ac9:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801acf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad4:	b8 03 00 00 00       	mov    $0x3,%eax
  801ad9:	e8 7a fe ff ff       	call   801958 <fsipc>
  801ade:	89 c3                	mov    %eax,%ebx
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	78 6a                	js     801b4e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ae4:	39 c6                	cmp    %eax,%esi
  801ae6:	73 24                	jae    801b0c <devfile_read+0x59>
  801ae8:	c7 44 24 0c d4 2f 80 	movl   $0x802fd4,0xc(%esp)
  801aef:	00 
  801af0:	c7 44 24 08 db 2f 80 	movl   $0x802fdb,0x8(%esp)
  801af7:	00 
  801af8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801aff:	00 
  801b00:	c7 04 24 f0 2f 80 00 	movl   $0x802ff0,(%esp)
  801b07:	e8 40 e7 ff ff       	call   80024c <_panic>
	assert(r <= PGSIZE);
  801b0c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b11:	7e 24                	jle    801b37 <devfile_read+0x84>
  801b13:	c7 44 24 0c fb 2f 80 	movl   $0x802ffb,0xc(%esp)
  801b1a:	00 
  801b1b:	c7 44 24 08 db 2f 80 	movl   $0x802fdb,0x8(%esp)
  801b22:	00 
  801b23:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b2a:	00 
  801b2b:	c7 04 24 f0 2f 80 00 	movl   $0x802ff0,(%esp)
  801b32:	e8 15 e7 ff ff       	call   80024c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b3b:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b42:	00 
  801b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b46:	89 04 24             	mov    %eax,(%esp)
  801b49:	e8 1a ef ff ff       	call   800a68 <memmove>
	return r;
}
  801b4e:	89 d8                	mov    %ebx,%eax
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 20             	sub    $0x20,%esp
  801b5f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b62:	89 34 24             	mov    %esi,(%esp)
  801b65:	e8 52 ed ff ff       	call   8008bc <strlen>
  801b6a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b6f:	7f 60                	jg     801bd1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b74:	89 04 24             	mov    %eax,(%esp)
  801b77:	e8 17 f8 ff ff       	call   801393 <fd_alloc>
  801b7c:	89 c3                	mov    %eax,%ebx
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	78 54                	js     801bd6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b82:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b86:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801b8d:	e8 5d ed ff ff       	call   8008ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b95:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba2:	e8 b1 fd ff ff       	call   801958 <fsipc>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	79 15                	jns    801bc2 <open+0x6b>
		fd_close(fd, 0);
  801bad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bb4:	00 
  801bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb8:	89 04 24             	mov    %eax,(%esp)
  801bbb:	e8 d6 f8 ff ff       	call   801496 <fd_close>
		return r;
  801bc0:	eb 14                	jmp    801bd6 <open+0x7f>
	}

	return fd2num(fd);
  801bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc5:	89 04 24             	mov    %eax,(%esp)
  801bc8:	e8 9b f7 ff ff       	call   801368 <fd2num>
  801bcd:	89 c3                	mov    %eax,%ebx
  801bcf:	eb 05                	jmp    801bd6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bd1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	83 c4 20             	add    $0x20,%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801be5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bea:	b8 08 00 00 00       	mov    $0x8,%eax
  801bef:	e8 64 fd ff ff       	call   801958 <fsipc>
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    
	...

00801bf8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801bfe:	c7 44 24 04 07 30 80 	movl   $0x803007,0x4(%esp)
  801c05:	00 
  801c06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c09:	89 04 24             	mov    %eax,(%esp)
  801c0c:	e8 de ec ff ff       	call   8008ef <strcpy>
	return 0;
}
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	53                   	push   %ebx
  801c1c:	83 ec 14             	sub    $0x14,%esp
  801c1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c22:	89 1c 24             	mov    %ebx,(%esp)
  801c25:	e8 8e 0b 00 00       	call   8027b8 <pageref>
  801c2a:	83 f8 01             	cmp    $0x1,%eax
  801c2d:	75 0d                	jne    801c3c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801c2f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c32:	89 04 24             	mov    %eax,(%esp)
  801c35:	e8 1f 03 00 00       	call   801f59 <nsipc_close>
  801c3a:	eb 05                	jmp    801c41 <devsock_close+0x29>
	else
		return 0;
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c41:	83 c4 14             	add    $0x14,%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c4d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c54:	00 
  801c55:	8b 45 10             	mov    0x10(%ebp),%eax
  801c58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	8b 40 0c             	mov    0xc(%eax),%eax
  801c69:	89 04 24             	mov    %eax,(%esp)
  801c6c:	e8 e3 03 00 00       	call   802054 <nsipc_send>
}
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c79:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c80:	00 
  801c81:	8b 45 10             	mov    0x10(%ebp),%eax
  801c84:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c92:	8b 40 0c             	mov    0xc(%eax),%eax
  801c95:	89 04 24             	mov    %eax,(%esp)
  801c98:	e8 37 03 00 00       	call   801fd4 <nsipc_recv>
}
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 20             	sub    $0x20,%esp
  801ca7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ca9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cac:	89 04 24             	mov    %eax,(%esp)
  801caf:	e8 df f6 ff ff       	call   801393 <fd_alloc>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	78 21                	js     801cdb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cc1:	00 
  801cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd0:	e8 0c f0 ff ff       	call   800ce1 <sys_page_alloc>
  801cd5:	89 c3                	mov    %eax,%ebx
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	79 0a                	jns    801ce5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801cdb:	89 34 24             	mov    %esi,(%esp)
  801cde:	e8 76 02 00 00       	call   801f59 <nsipc_close>
		return r;
  801ce3:	eb 22                	jmp    801d07 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ce5:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cee:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cfa:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801cfd:	89 04 24             	mov    %eax,(%esp)
  801d00:	e8 63 f6 ff ff       	call   801368 <fd2num>
  801d05:	89 c3                	mov    %eax,%ebx
}
  801d07:	89 d8                	mov    %ebx,%eax
  801d09:	83 c4 20             	add    $0x20,%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5e                   	pop    %esi
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    

00801d10 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d16:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d19:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d1d:	89 04 24             	mov    %eax,(%esp)
  801d20:	e8 c1 f6 ff ff       	call   8013e6 <fd_lookup>
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 17                	js     801d40 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2c:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d32:	39 10                	cmp    %edx,(%eax)
  801d34:	75 05                	jne    801d3b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d36:	8b 40 0c             	mov    0xc(%eax),%eax
  801d39:	eb 05                	jmp    801d40 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d3b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d48:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4b:	e8 c0 ff ff ff       	call   801d10 <fd2sockid>
  801d50:	85 c0                	test   %eax,%eax
  801d52:	78 1f                	js     801d73 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d54:	8b 55 10             	mov    0x10(%ebp),%edx
  801d57:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d62:	89 04 24             	mov    %eax,(%esp)
  801d65:	e8 38 01 00 00       	call   801ea2 <nsipc_accept>
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	78 05                	js     801d73 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d6e:	e8 2c ff ff ff       	call   801c9f <alloc_sockfd>
}
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	e8 8d ff ff ff       	call   801d10 <fd2sockid>
  801d83:	85 c0                	test   %eax,%eax
  801d85:	78 16                	js     801d9d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801d87:	8b 55 10             	mov    0x10(%ebp),%edx
  801d8a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d91:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d95:	89 04 24             	mov    %eax,(%esp)
  801d98:	e8 5b 01 00 00       	call   801ef8 <nsipc_bind>
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <shutdown>:

int
shutdown(int s, int how)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801da5:	8b 45 08             	mov    0x8(%ebp),%eax
  801da8:	e8 63 ff ff ff       	call   801d10 <fd2sockid>
  801dad:	85 c0                	test   %eax,%eax
  801daf:	78 0f                	js     801dc0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801db1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db8:	89 04 24             	mov    %eax,(%esp)
  801dbb:	e8 77 01 00 00       	call   801f37 <nsipc_shutdown>
}
  801dc0:	c9                   	leave  
  801dc1:	c3                   	ret    

00801dc2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	e8 40 ff ff ff       	call   801d10 <fd2sockid>
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	78 16                	js     801dea <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801dd4:	8b 55 10             	mov    0x10(%ebp),%edx
  801dd7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ddb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dde:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de2:	89 04 24             	mov    %eax,(%esp)
  801de5:	e8 89 01 00 00       	call   801f73 <nsipc_connect>
}
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <listen>:

int
listen(int s, int backlog)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	e8 16 ff ff ff       	call   801d10 <fd2sockid>
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 0f                	js     801e0d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801dfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e01:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e05:	89 04 24             	mov    %eax,(%esp)
  801e08:	e8 a5 01 00 00       	call   801fb2 <nsipc_listen>
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e15:	8b 45 10             	mov    0x10(%ebp),%eax
  801e18:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e23:	8b 45 08             	mov    0x8(%ebp),%eax
  801e26:	89 04 24             	mov    %eax,(%esp)
  801e29:	e8 99 02 00 00       	call   8020c7 <nsipc_socket>
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 05                	js     801e37 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801e32:	e8 68 fe ff ff       	call   801c9f <alloc_sockfd>
}
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    
  801e39:	00 00                	add    %al,(%eax)
	...

00801e3c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	53                   	push   %ebx
  801e40:	83 ec 14             	sub    $0x14,%esp
  801e43:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e45:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801e4c:	75 11                	jne    801e5f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e4e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801e55:	e8 19 09 00 00       	call   802773 <ipc_find_env>
  801e5a:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e5f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e66:	00 
  801e67:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801e6e:	00 
  801e6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e73:	a1 04 50 80 00       	mov    0x805004,%eax
  801e78:	89 04 24             	mov    %eax,(%esp)
  801e7b:	e8 70 08 00 00       	call   8026f0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e87:	00 
  801e88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e8f:	00 
  801e90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e97:	e8 e4 07 00 00       	call   802680 <ipc_recv>
}
  801e9c:	83 c4 14             	add    $0x14,%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	56                   	push   %esi
  801ea6:	53                   	push   %ebx
  801ea7:	83 ec 10             	sub    $0x10,%esp
  801eaa:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ead:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801eb5:	8b 06                	mov    (%esi),%eax
  801eb7:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec1:	e8 76 ff ff ff       	call   801e3c <nsipc>
  801ec6:	89 c3                	mov    %eax,%ebx
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	78 23                	js     801eef <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ecc:	a1 10 70 80 00       	mov    0x807010,%eax
  801ed1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ed5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801edc:	00 
  801edd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee0:	89 04 24             	mov    %eax,(%esp)
  801ee3:	e8 80 eb ff ff       	call   800a68 <memmove>
		*addrlen = ret->ret_addrlen;
  801ee8:	a1 10 70 80 00       	mov    0x807010,%eax
  801eed:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801eef:	89 d8                	mov    %ebx,%eax
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	5b                   	pop    %ebx
  801ef5:	5e                   	pop    %esi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	53                   	push   %ebx
  801efc:	83 ec 14             	sub    $0x14,%esp
  801eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f02:	8b 45 08             	mov    0x8(%ebp),%eax
  801f05:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f0a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f15:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801f1c:	e8 47 eb ff ff       	call   800a68 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f21:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f27:	b8 02 00 00 00       	mov    $0x2,%eax
  801f2c:	e8 0b ff ff ff       	call   801e3c <nsipc>
}
  801f31:	83 c4 14             	add    $0x14,%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f40:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f48:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f4d:	b8 03 00 00 00       	mov    $0x3,%eax
  801f52:	e8 e5 fe ff ff       	call   801e3c <nsipc>
}
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <nsipc_close>:

int
nsipc_close(int s)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f62:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801f67:	b8 04 00 00 00       	mov    $0x4,%eax
  801f6c:	e8 cb fe ff ff       	call   801e3c <nsipc>
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	53                   	push   %ebx
  801f77:	83 ec 14             	sub    $0x14,%esp
  801f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f80:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f85:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f90:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801f97:	e8 cc ea ff ff       	call   800a68 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f9c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801fa2:	b8 05 00 00 00       	mov    $0x5,%eax
  801fa7:	e8 90 fe ff ff       	call   801e3c <nsipc>
}
  801fac:	83 c4 14             	add    $0x14,%esp
  801faf:	5b                   	pop    %ebx
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    

00801fb2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801fc8:	b8 06 00 00 00       	mov    $0x6,%eax
  801fcd:	e8 6a fe ff ff       	call   801e3c <nsipc>
}
  801fd2:	c9                   	leave  
  801fd3:	c3                   	ret    

00801fd4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	56                   	push   %esi
  801fd8:	53                   	push   %ebx
  801fd9:	83 ec 10             	sub    $0x10,%esp
  801fdc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801fe7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801fed:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ff5:	b8 07 00 00 00       	mov    $0x7,%eax
  801ffa:	e8 3d fe ff ff       	call   801e3c <nsipc>
  801fff:	89 c3                	mov    %eax,%ebx
  802001:	85 c0                	test   %eax,%eax
  802003:	78 46                	js     80204b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802005:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80200a:	7f 04                	jg     802010 <nsipc_recv+0x3c>
  80200c:	39 c6                	cmp    %eax,%esi
  80200e:	7d 24                	jge    802034 <nsipc_recv+0x60>
  802010:	c7 44 24 0c 13 30 80 	movl   $0x803013,0xc(%esp)
  802017:	00 
  802018:	c7 44 24 08 db 2f 80 	movl   $0x802fdb,0x8(%esp)
  80201f:	00 
  802020:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802027:	00 
  802028:	c7 04 24 28 30 80 00 	movl   $0x803028,(%esp)
  80202f:	e8 18 e2 ff ff       	call   80024c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802034:	89 44 24 08          	mov    %eax,0x8(%esp)
  802038:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80203f:	00 
  802040:	8b 45 0c             	mov    0xc(%ebp),%eax
  802043:	89 04 24             	mov    %eax,(%esp)
  802046:	e8 1d ea ff ff       	call   800a68 <memmove>
	}

	return r;
}
  80204b:	89 d8                	mov    %ebx,%eax
  80204d:	83 c4 10             	add    $0x10,%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    

00802054 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	53                   	push   %ebx
  802058:	83 ec 14             	sub    $0x14,%esp
  80205b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80205e:	8b 45 08             	mov    0x8(%ebp),%eax
  802061:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802066:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80206c:	7e 24                	jle    802092 <nsipc_send+0x3e>
  80206e:	c7 44 24 0c 34 30 80 	movl   $0x803034,0xc(%esp)
  802075:	00 
  802076:	c7 44 24 08 db 2f 80 	movl   $0x802fdb,0x8(%esp)
  80207d:	00 
  80207e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802085:	00 
  802086:	c7 04 24 28 30 80 00 	movl   $0x803028,(%esp)
  80208d:	e8 ba e1 ff ff       	call   80024c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802092:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802096:	8b 45 0c             	mov    0xc(%ebp),%eax
  802099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209d:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8020a4:	e8 bf e9 ff ff       	call   800a68 <memmove>
	nsipcbuf.send.req_size = size;
  8020a9:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8020af:	8b 45 14             	mov    0x14(%ebp),%eax
  8020b2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8020b7:	b8 08 00 00 00       	mov    $0x8,%eax
  8020bc:	e8 7b fd ff ff       	call   801e3c <nsipc>
}
  8020c1:	83 c4 14             	add    $0x14,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    

008020c7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8020d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8020dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8020e5:	b8 09 00 00 00       	mov    $0x9,%eax
  8020ea:	e8 4d fd ff ff       	call   801e3c <nsipc>
}
  8020ef:	c9                   	leave  
  8020f0:	c3                   	ret    
  8020f1:	00 00                	add    %al,(%eax)
	...

008020f4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	56                   	push   %esi
  8020f8:	53                   	push   %ebx
  8020f9:	83 ec 10             	sub    $0x10,%esp
  8020fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802102:	89 04 24             	mov    %eax,(%esp)
  802105:	e8 6e f2 ff ff       	call   801378 <fd2data>
  80210a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80210c:	c7 44 24 04 40 30 80 	movl   $0x803040,0x4(%esp)
  802113:	00 
  802114:	89 34 24             	mov    %esi,(%esp)
  802117:	e8 d3 e7 ff ff       	call   8008ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80211c:	8b 43 04             	mov    0x4(%ebx),%eax
  80211f:	2b 03                	sub    (%ebx),%eax
  802121:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802127:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80212e:	00 00 00 
	stat->st_dev = &devpipe;
  802131:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802138:	40 80 00 
	return 0;
}
  80213b:	b8 00 00 00 00       	mov    $0x0,%eax
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5d                   	pop    %ebp
  802146:	c3                   	ret    

00802147 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	53                   	push   %ebx
  80214b:	83 ec 14             	sub    $0x14,%esp
  80214e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802151:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802155:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80215c:	e8 27 ec ff ff       	call   800d88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802161:	89 1c 24             	mov    %ebx,(%esp)
  802164:	e8 0f f2 ff ff       	call   801378 <fd2data>
  802169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802174:	e8 0f ec ff ff       	call   800d88 <sys_page_unmap>
}
  802179:	83 c4 14             	add    $0x14,%esp
  80217c:	5b                   	pop    %ebx
  80217d:	5d                   	pop    %ebp
  80217e:	c3                   	ret    

0080217f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80217f:	55                   	push   %ebp
  802180:	89 e5                	mov    %esp,%ebp
  802182:	57                   	push   %edi
  802183:	56                   	push   %esi
  802184:	53                   	push   %ebx
  802185:	83 ec 2c             	sub    $0x2c,%esp
  802188:	89 c7                	mov    %eax,%edi
  80218a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80218d:	a1 08 50 80 00       	mov    0x805008,%eax
  802192:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802195:	89 3c 24             	mov    %edi,(%esp)
  802198:	e8 1b 06 00 00       	call   8027b8 <pageref>
  80219d:	89 c6                	mov    %eax,%esi
  80219f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021a2:	89 04 24             	mov    %eax,(%esp)
  8021a5:	e8 0e 06 00 00       	call   8027b8 <pageref>
  8021aa:	39 c6                	cmp    %eax,%esi
  8021ac:	0f 94 c0             	sete   %al
  8021af:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021b2:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8021b8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021bb:	39 cb                	cmp    %ecx,%ebx
  8021bd:	75 08                	jne    8021c7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8021bf:	83 c4 2c             	add    $0x2c,%esp
  8021c2:	5b                   	pop    %ebx
  8021c3:	5e                   	pop    %esi
  8021c4:	5f                   	pop    %edi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8021c7:	83 f8 01             	cmp    $0x1,%eax
  8021ca:	75 c1                	jne    80218d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021cc:	8b 42 58             	mov    0x58(%edx),%eax
  8021cf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8021d6:	00 
  8021d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021df:	c7 04 24 47 30 80 00 	movl   $0x803047,(%esp)
  8021e6:	e8 59 e1 ff ff       	call   800344 <cprintf>
  8021eb:	eb a0                	jmp    80218d <_pipeisclosed+0xe>

008021ed <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021ed:	55                   	push   %ebp
  8021ee:	89 e5                	mov    %esp,%ebp
  8021f0:	57                   	push   %edi
  8021f1:	56                   	push   %esi
  8021f2:	53                   	push   %ebx
  8021f3:	83 ec 1c             	sub    $0x1c,%esp
  8021f6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021f9:	89 34 24             	mov    %esi,(%esp)
  8021fc:	e8 77 f1 ff ff       	call   801378 <fd2data>
  802201:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802203:	bf 00 00 00 00       	mov    $0x0,%edi
  802208:	eb 3c                	jmp    802246 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80220a:	89 da                	mov    %ebx,%edx
  80220c:	89 f0                	mov    %esi,%eax
  80220e:	e8 6c ff ff ff       	call   80217f <_pipeisclosed>
  802213:	85 c0                	test   %eax,%eax
  802215:	75 38                	jne    80224f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802217:	e8 a6 ea ff ff       	call   800cc2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80221c:	8b 43 04             	mov    0x4(%ebx),%eax
  80221f:	8b 13                	mov    (%ebx),%edx
  802221:	83 c2 20             	add    $0x20,%edx
  802224:	39 d0                	cmp    %edx,%eax
  802226:	73 e2                	jae    80220a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80222b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80222e:	89 c2                	mov    %eax,%edx
  802230:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802236:	79 05                	jns    80223d <devpipe_write+0x50>
  802238:	4a                   	dec    %edx
  802239:	83 ca e0             	or     $0xffffffe0,%edx
  80223c:	42                   	inc    %edx
  80223d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802241:	40                   	inc    %eax
  802242:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802245:	47                   	inc    %edi
  802246:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802249:	75 d1                	jne    80221c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80224b:	89 f8                	mov    %edi,%eax
  80224d:	eb 05                	jmp    802254 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80224f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    

0080225c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	57                   	push   %edi
  802260:	56                   	push   %esi
  802261:	53                   	push   %ebx
  802262:	83 ec 1c             	sub    $0x1c,%esp
  802265:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802268:	89 3c 24             	mov    %edi,(%esp)
  80226b:	e8 08 f1 ff ff       	call   801378 <fd2data>
  802270:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802272:	be 00 00 00 00       	mov    $0x0,%esi
  802277:	eb 3a                	jmp    8022b3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802279:	85 f6                	test   %esi,%esi
  80227b:	74 04                	je     802281 <devpipe_read+0x25>
				return i;
  80227d:	89 f0                	mov    %esi,%eax
  80227f:	eb 40                	jmp    8022c1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802281:	89 da                	mov    %ebx,%edx
  802283:	89 f8                	mov    %edi,%eax
  802285:	e8 f5 fe ff ff       	call   80217f <_pipeisclosed>
  80228a:	85 c0                	test   %eax,%eax
  80228c:	75 2e                	jne    8022bc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80228e:	e8 2f ea ff ff       	call   800cc2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802293:	8b 03                	mov    (%ebx),%eax
  802295:	3b 43 04             	cmp    0x4(%ebx),%eax
  802298:	74 df                	je     802279 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80229a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80229f:	79 05                	jns    8022a6 <devpipe_read+0x4a>
  8022a1:	48                   	dec    %eax
  8022a2:	83 c8 e0             	or     $0xffffffe0,%eax
  8022a5:	40                   	inc    %eax
  8022a6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022ad:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022b0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022b2:	46                   	inc    %esi
  8022b3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022b6:	75 db                	jne    802293 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022b8:	89 f0                	mov    %esi,%eax
  8022ba:	eb 05                	jmp    8022c1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022bc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    

008022c9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	57                   	push   %edi
  8022cd:	56                   	push   %esi
  8022ce:	53                   	push   %ebx
  8022cf:	83 ec 3c             	sub    $0x3c,%esp
  8022d2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8022d8:	89 04 24             	mov    %eax,(%esp)
  8022db:	e8 b3 f0 ff ff       	call   801393 <fd_alloc>
  8022e0:	89 c3                	mov    %eax,%ebx
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	0f 88 45 01 00 00    	js     80242f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ea:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022f1:	00 
  8022f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802300:	e8 dc e9 ff ff       	call   800ce1 <sys_page_alloc>
  802305:	89 c3                	mov    %eax,%ebx
  802307:	85 c0                	test   %eax,%eax
  802309:	0f 88 20 01 00 00    	js     80242f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80230f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802312:	89 04 24             	mov    %eax,(%esp)
  802315:	e8 79 f0 ff ff       	call   801393 <fd_alloc>
  80231a:	89 c3                	mov    %eax,%ebx
  80231c:	85 c0                	test   %eax,%eax
  80231e:	0f 88 f8 00 00 00    	js     80241c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802324:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80232b:	00 
  80232c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80232f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802333:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80233a:	e8 a2 e9 ff ff       	call   800ce1 <sys_page_alloc>
  80233f:	89 c3                	mov    %eax,%ebx
  802341:	85 c0                	test   %eax,%eax
  802343:	0f 88 d3 00 00 00    	js     80241c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80234c:	89 04 24             	mov    %eax,(%esp)
  80234f:	e8 24 f0 ff ff       	call   801378 <fd2data>
  802354:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802356:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80235d:	00 
  80235e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802362:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802369:	e8 73 e9 ff ff       	call   800ce1 <sys_page_alloc>
  80236e:	89 c3                	mov    %eax,%ebx
  802370:	85 c0                	test   %eax,%eax
  802372:	0f 88 91 00 00 00    	js     802409 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802378:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80237b:	89 04 24             	mov    %eax,(%esp)
  80237e:	e8 f5 ef ff ff       	call   801378 <fd2data>
  802383:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80238a:	00 
  80238b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802396:	00 
  802397:	89 74 24 04          	mov    %esi,0x4(%esp)
  80239b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a2:	e8 8e e9 ff ff       	call   800d35 <sys_page_map>
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	78 4c                	js     8023f9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023ad:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8023b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023b6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023bb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023c2:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8023c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023cb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023d0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023da:	89 04 24             	mov    %eax,(%esp)
  8023dd:	e8 86 ef ff ff       	call   801368 <fd2num>
  8023e2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8023e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023e7:	89 04 24             	mov    %eax,(%esp)
  8023ea:	e8 79 ef ff ff       	call   801368 <fd2num>
  8023ef:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8023f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023f7:	eb 36                	jmp    80242f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8023f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802404:	e8 7f e9 ff ff       	call   800d88 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802409:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80240c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802410:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802417:	e8 6c e9 ff ff       	call   800d88 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80241c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80241f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802423:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80242a:	e8 59 e9 ff ff       	call   800d88 <sys_page_unmap>
    err:
	return r;
}
  80242f:	89 d8                	mov    %ebx,%eax
  802431:	83 c4 3c             	add    $0x3c,%esp
  802434:	5b                   	pop    %ebx
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    

00802439 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802439:	55                   	push   %ebp
  80243a:	89 e5                	mov    %esp,%ebp
  80243c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80243f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802442:	89 44 24 04          	mov    %eax,0x4(%esp)
  802446:	8b 45 08             	mov    0x8(%ebp),%eax
  802449:	89 04 24             	mov    %eax,(%esp)
  80244c:	e8 95 ef ff ff       	call   8013e6 <fd_lookup>
  802451:	85 c0                	test   %eax,%eax
  802453:	78 15                	js     80246a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802458:	89 04 24             	mov    %eax,(%esp)
  80245b:	e8 18 ef ff ff       	call   801378 <fd2data>
	return _pipeisclosed(fd, p);
  802460:	89 c2                	mov    %eax,%edx
  802462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802465:	e8 15 fd ff ff       	call   80217f <_pipeisclosed>
}
  80246a:	c9                   	leave  
  80246b:	c3                   	ret    

0080246c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80246c:	55                   	push   %ebp
  80246d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80246f:	b8 00 00 00 00       	mov    $0x0,%eax
  802474:	5d                   	pop    %ebp
  802475:	c3                   	ret    

00802476 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802476:	55                   	push   %ebp
  802477:	89 e5                	mov    %esp,%ebp
  802479:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80247c:	c7 44 24 04 5f 30 80 	movl   $0x80305f,0x4(%esp)
  802483:	00 
  802484:	8b 45 0c             	mov    0xc(%ebp),%eax
  802487:	89 04 24             	mov    %eax,(%esp)
  80248a:	e8 60 e4 ff ff       	call   8008ef <strcpy>
	return 0;
}
  80248f:	b8 00 00 00 00       	mov    $0x0,%eax
  802494:	c9                   	leave  
  802495:	c3                   	ret    

00802496 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802496:	55                   	push   %ebp
  802497:	89 e5                	mov    %esp,%ebp
  802499:	57                   	push   %edi
  80249a:	56                   	push   %esi
  80249b:	53                   	push   %ebx
  80249c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024a7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024ad:	eb 30                	jmp    8024df <devcons_write+0x49>
		m = n - tot;
  8024af:	8b 75 10             	mov    0x10(%ebp),%esi
  8024b2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8024b4:	83 fe 7f             	cmp    $0x7f,%esi
  8024b7:	76 05                	jbe    8024be <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8024b9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8024be:	89 74 24 08          	mov    %esi,0x8(%esp)
  8024c2:	03 45 0c             	add    0xc(%ebp),%eax
  8024c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c9:	89 3c 24             	mov    %edi,(%esp)
  8024cc:	e8 97 e5 ff ff       	call   800a68 <memmove>
		sys_cputs(buf, m);
  8024d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d5:	89 3c 24             	mov    %edi,(%esp)
  8024d8:	e8 37 e7 ff ff       	call   800c14 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024dd:	01 f3                	add    %esi,%ebx
  8024df:	89 d8                	mov    %ebx,%eax
  8024e1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8024e4:	72 c9                	jb     8024af <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024e6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8024ec:	5b                   	pop    %ebx
  8024ed:	5e                   	pop    %esi
  8024ee:	5f                   	pop    %edi
  8024ef:	5d                   	pop    %ebp
  8024f0:	c3                   	ret    

008024f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024f1:	55                   	push   %ebp
  8024f2:	89 e5                	mov    %esp,%ebp
  8024f4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8024f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024fb:	75 07                	jne    802504 <devcons_read+0x13>
  8024fd:	eb 25                	jmp    802524 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024ff:	e8 be e7 ff ff       	call   800cc2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802504:	e8 29 e7 ff ff       	call   800c32 <sys_cgetc>
  802509:	85 c0                	test   %eax,%eax
  80250b:	74 f2                	je     8024ff <devcons_read+0xe>
  80250d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80250f:	85 c0                	test   %eax,%eax
  802511:	78 1d                	js     802530 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802513:	83 f8 04             	cmp    $0x4,%eax
  802516:	74 13                	je     80252b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80251b:	88 10                	mov    %dl,(%eax)
	return 1;
  80251d:	b8 01 00 00 00       	mov    $0x1,%eax
  802522:	eb 0c                	jmp    802530 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802524:	b8 00 00 00 00       	mov    $0x0,%eax
  802529:	eb 05                	jmp    802530 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80252b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802530:	c9                   	leave  
  802531:	c3                   	ret    

00802532 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802532:	55                   	push   %ebp
  802533:	89 e5                	mov    %esp,%ebp
  802535:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802538:	8b 45 08             	mov    0x8(%ebp),%eax
  80253b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80253e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802545:	00 
  802546:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802549:	89 04 24             	mov    %eax,(%esp)
  80254c:	e8 c3 e6 ff ff       	call   800c14 <sys_cputs>
}
  802551:	c9                   	leave  
  802552:	c3                   	ret    

00802553 <getchar>:

int
getchar(void)
{
  802553:	55                   	push   %ebp
  802554:	89 e5                	mov    %esp,%ebp
  802556:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802559:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802560:	00 
  802561:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802564:	89 44 24 04          	mov    %eax,0x4(%esp)
  802568:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80256f:	e8 10 f1 ff ff       	call   801684 <read>
	if (r < 0)
  802574:	85 c0                	test   %eax,%eax
  802576:	78 0f                	js     802587 <getchar+0x34>
		return r;
	if (r < 1)
  802578:	85 c0                	test   %eax,%eax
  80257a:	7e 06                	jle    802582 <getchar+0x2f>
		return -E_EOF;
	return c;
  80257c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802580:	eb 05                	jmp    802587 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802582:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802587:	c9                   	leave  
  802588:	c3                   	ret    

00802589 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802589:	55                   	push   %ebp
  80258a:	89 e5                	mov    %esp,%ebp
  80258c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80258f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802592:	89 44 24 04          	mov    %eax,0x4(%esp)
  802596:	8b 45 08             	mov    0x8(%ebp),%eax
  802599:	89 04 24             	mov    %eax,(%esp)
  80259c:	e8 45 ee ff ff       	call   8013e6 <fd_lookup>
  8025a1:	85 c0                	test   %eax,%eax
  8025a3:	78 11                	js     8025b6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a8:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8025ae:	39 10                	cmp    %edx,(%eax)
  8025b0:	0f 94 c0             	sete   %al
  8025b3:	0f b6 c0             	movzbl %al,%eax
}
  8025b6:	c9                   	leave  
  8025b7:	c3                   	ret    

008025b8 <opencons>:

int
opencons(void)
{
  8025b8:	55                   	push   %ebp
  8025b9:	89 e5                	mov    %esp,%ebp
  8025bb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025c1:	89 04 24             	mov    %eax,(%esp)
  8025c4:	e8 ca ed ff ff       	call   801393 <fd_alloc>
  8025c9:	85 c0                	test   %eax,%eax
  8025cb:	78 3c                	js     802609 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025cd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025d4:	00 
  8025d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025e3:	e8 f9 e6 ff ff       	call   800ce1 <sys_page_alloc>
  8025e8:	85 c0                	test   %eax,%eax
  8025ea:	78 1d                	js     802609 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8025ec:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8025f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025fa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802601:	89 04 24             	mov    %eax,(%esp)
  802604:	e8 5f ed ff ff       	call   801368 <fd2num>
}
  802609:	c9                   	leave  
  80260a:	c3                   	ret    
	...

0080260c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80260c:	55                   	push   %ebp
  80260d:	89 e5                	mov    %esp,%ebp
  80260f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802612:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802619:	75 30                	jne    80264b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  80261b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802622:	00 
  802623:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80262a:	ee 
  80262b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802632:	e8 aa e6 ff ff       	call   800ce1 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802637:	c7 44 24 04 58 26 80 	movl   $0x802658,0x4(%esp)
  80263e:	00 
  80263f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802646:	e8 36 e8 ff ff       	call   800e81 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80264b:	8b 45 08             	mov    0x8(%ebp),%eax
  80264e:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802653:	c9                   	leave  
  802654:	c3                   	ret    
  802655:	00 00                	add    %al,(%eax)
	...

00802658 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802658:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802659:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80265e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802660:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  802663:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802667:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  80266b:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  80266e:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802670:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802674:	83 c4 08             	add    $0x8,%esp
	popal
  802677:	61                   	popa   

	addl $4,%esp 
  802678:	83 c4 04             	add    $0x4,%esp
	popfl
  80267b:	9d                   	popf   

	popl %esp
  80267c:	5c                   	pop    %esp

	ret
  80267d:	c3                   	ret    
	...

00802680 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802680:	55                   	push   %ebp
  802681:	89 e5                	mov    %esp,%ebp
  802683:	56                   	push   %esi
  802684:	53                   	push   %ebx
  802685:	83 ec 10             	sub    $0x10,%esp
  802688:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80268b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80268e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802691:	85 c0                	test   %eax,%eax
  802693:	74 0a                	je     80269f <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802695:	89 04 24             	mov    %eax,(%esp)
  802698:	e8 5a e8 ff ff       	call   800ef7 <sys_ipc_recv>
  80269d:	eb 0c                	jmp    8026ab <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80269f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8026a6:	e8 4c e8 ff ff       	call   800ef7 <sys_ipc_recv>
	}
	if (r < 0)
  8026ab:	85 c0                	test   %eax,%eax
  8026ad:	79 16                	jns    8026c5 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8026af:	85 db                	test   %ebx,%ebx
  8026b1:	74 06                	je     8026b9 <ipc_recv+0x39>
  8026b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8026b9:	85 f6                	test   %esi,%esi
  8026bb:	74 2c                	je     8026e9 <ipc_recv+0x69>
  8026bd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8026c3:	eb 24                	jmp    8026e9 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8026c5:	85 db                	test   %ebx,%ebx
  8026c7:	74 0a                	je     8026d3 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8026c9:	a1 08 50 80 00       	mov    0x805008,%eax
  8026ce:	8b 40 74             	mov    0x74(%eax),%eax
  8026d1:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8026d3:	85 f6                	test   %esi,%esi
  8026d5:	74 0a                	je     8026e1 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8026d7:	a1 08 50 80 00       	mov    0x805008,%eax
  8026dc:	8b 40 78             	mov    0x78(%eax),%eax
  8026df:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8026e1:	a1 08 50 80 00       	mov    0x805008,%eax
  8026e6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8026e9:	83 c4 10             	add    $0x10,%esp
  8026ec:	5b                   	pop    %ebx
  8026ed:	5e                   	pop    %esi
  8026ee:	5d                   	pop    %ebp
  8026ef:	c3                   	ret    

008026f0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026f0:	55                   	push   %ebp
  8026f1:	89 e5                	mov    %esp,%ebp
  8026f3:	57                   	push   %edi
  8026f4:	56                   	push   %esi
  8026f5:	53                   	push   %ebx
  8026f6:	83 ec 1c             	sub    $0x1c,%esp
  8026f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8026fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8026ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802702:	85 db                	test   %ebx,%ebx
  802704:	74 19                	je     80271f <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802706:	8b 45 14             	mov    0x14(%ebp),%eax
  802709:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80270d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802711:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802715:	89 34 24             	mov    %esi,(%esp)
  802718:	e8 b7 e7 ff ff       	call   800ed4 <sys_ipc_try_send>
  80271d:	eb 1c                	jmp    80273b <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80271f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802726:	00 
  802727:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80272e:	ee 
  80272f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802733:	89 34 24             	mov    %esi,(%esp)
  802736:	e8 99 e7 ff ff       	call   800ed4 <sys_ipc_try_send>
		}
		if (r == 0)
  80273b:	85 c0                	test   %eax,%eax
  80273d:	74 2c                	je     80276b <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80273f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802742:	74 20                	je     802764 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802744:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802748:	c7 44 24 08 6b 30 80 	movl   $0x80306b,0x8(%esp)
  80274f:	00 
  802750:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802757:	00 
  802758:	c7 04 24 7e 30 80 00 	movl   $0x80307e,(%esp)
  80275f:	e8 e8 da ff ff       	call   80024c <_panic>
		}
		sys_yield();
  802764:	e8 59 e5 ff ff       	call   800cc2 <sys_yield>
	}
  802769:	eb 97                	jmp    802702 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80276b:	83 c4 1c             	add    $0x1c,%esp
  80276e:	5b                   	pop    %ebx
  80276f:	5e                   	pop    %esi
  802770:	5f                   	pop    %edi
  802771:	5d                   	pop    %ebp
  802772:	c3                   	ret    

00802773 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802773:	55                   	push   %ebp
  802774:	89 e5                	mov    %esp,%ebp
  802776:	53                   	push   %ebx
  802777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80277a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80277f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802786:	89 c2                	mov    %eax,%edx
  802788:	c1 e2 07             	shl    $0x7,%edx
  80278b:	29 ca                	sub    %ecx,%edx
  80278d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802793:	8b 52 50             	mov    0x50(%edx),%edx
  802796:	39 da                	cmp    %ebx,%edx
  802798:	75 0f                	jne    8027a9 <ipc_find_env+0x36>
			return envs[i].env_id;
  80279a:	c1 e0 07             	shl    $0x7,%eax
  80279d:	29 c8                	sub    %ecx,%eax
  80279f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8027a4:	8b 40 40             	mov    0x40(%eax),%eax
  8027a7:	eb 0c                	jmp    8027b5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027a9:	40                   	inc    %eax
  8027aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027af:	75 ce                	jne    80277f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027b1:	66 b8 00 00          	mov    $0x0,%ax
}
  8027b5:	5b                   	pop    %ebx
  8027b6:	5d                   	pop    %ebp
  8027b7:	c3                   	ret    

008027b8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027b8:	55                   	push   %ebp
  8027b9:	89 e5                	mov    %esp,%ebp
  8027bb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027be:	89 c2                	mov    %eax,%edx
  8027c0:	c1 ea 16             	shr    $0x16,%edx
  8027c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8027ca:	f6 c2 01             	test   $0x1,%dl
  8027cd:	74 1e                	je     8027ed <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8027cf:	c1 e8 0c             	shr    $0xc,%eax
  8027d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8027d9:	a8 01                	test   $0x1,%al
  8027db:	74 17                	je     8027f4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027dd:	c1 e8 0c             	shr    $0xc,%eax
  8027e0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8027e7:	ef 
  8027e8:	0f b7 c0             	movzwl %ax,%eax
  8027eb:	eb 0c                	jmp    8027f9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8027ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8027f2:	eb 05                	jmp    8027f9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8027f4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8027f9:	5d                   	pop    %ebp
  8027fa:	c3                   	ret    
	...

008027fc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8027fc:	55                   	push   %ebp
  8027fd:	57                   	push   %edi
  8027fe:	56                   	push   %esi
  8027ff:	83 ec 10             	sub    $0x10,%esp
  802802:	8b 74 24 20          	mov    0x20(%esp),%esi
  802806:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80280a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80280e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802812:	89 cd                	mov    %ecx,%ebp
  802814:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802818:	85 c0                	test   %eax,%eax
  80281a:	75 2c                	jne    802848 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80281c:	39 f9                	cmp    %edi,%ecx
  80281e:	77 68                	ja     802888 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802820:	85 c9                	test   %ecx,%ecx
  802822:	75 0b                	jne    80282f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802824:	b8 01 00 00 00       	mov    $0x1,%eax
  802829:	31 d2                	xor    %edx,%edx
  80282b:	f7 f1                	div    %ecx
  80282d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80282f:	31 d2                	xor    %edx,%edx
  802831:	89 f8                	mov    %edi,%eax
  802833:	f7 f1                	div    %ecx
  802835:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802837:	89 f0                	mov    %esi,%eax
  802839:	f7 f1                	div    %ecx
  80283b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80283d:	89 f0                	mov    %esi,%eax
  80283f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802841:	83 c4 10             	add    $0x10,%esp
  802844:	5e                   	pop    %esi
  802845:	5f                   	pop    %edi
  802846:	5d                   	pop    %ebp
  802847:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802848:	39 f8                	cmp    %edi,%eax
  80284a:	77 2c                	ja     802878 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80284c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80284f:	83 f6 1f             	xor    $0x1f,%esi
  802852:	75 4c                	jne    8028a0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802854:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802856:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80285b:	72 0a                	jb     802867 <__udivdi3+0x6b>
  80285d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802861:	0f 87 ad 00 00 00    	ja     802914 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802867:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80286c:	89 f0                	mov    %esi,%eax
  80286e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802870:	83 c4 10             	add    $0x10,%esp
  802873:	5e                   	pop    %esi
  802874:	5f                   	pop    %edi
  802875:	5d                   	pop    %ebp
  802876:	c3                   	ret    
  802877:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802878:	31 ff                	xor    %edi,%edi
  80287a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80287c:	89 f0                	mov    %esi,%eax
  80287e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802880:	83 c4 10             	add    $0x10,%esp
  802883:	5e                   	pop    %esi
  802884:	5f                   	pop    %edi
  802885:	5d                   	pop    %ebp
  802886:	c3                   	ret    
  802887:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802888:	89 fa                	mov    %edi,%edx
  80288a:	89 f0                	mov    %esi,%eax
  80288c:	f7 f1                	div    %ecx
  80288e:	89 c6                	mov    %eax,%esi
  802890:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802892:	89 f0                	mov    %esi,%eax
  802894:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802896:	83 c4 10             	add    $0x10,%esp
  802899:	5e                   	pop    %esi
  80289a:	5f                   	pop    %edi
  80289b:	5d                   	pop    %ebp
  80289c:	c3                   	ret    
  80289d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8028a0:	89 f1                	mov    %esi,%ecx
  8028a2:	d3 e0                	shl    %cl,%eax
  8028a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8028a8:	b8 20 00 00 00       	mov    $0x20,%eax
  8028ad:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8028af:	89 ea                	mov    %ebp,%edx
  8028b1:	88 c1                	mov    %al,%cl
  8028b3:	d3 ea                	shr    %cl,%edx
  8028b5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8028b9:	09 ca                	or     %ecx,%edx
  8028bb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8028bf:	89 f1                	mov    %esi,%ecx
  8028c1:	d3 e5                	shl    %cl,%ebp
  8028c3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8028c7:	89 fd                	mov    %edi,%ebp
  8028c9:	88 c1                	mov    %al,%cl
  8028cb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8028cd:	89 fa                	mov    %edi,%edx
  8028cf:	89 f1                	mov    %esi,%ecx
  8028d1:	d3 e2                	shl    %cl,%edx
  8028d3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8028d7:	88 c1                	mov    %al,%cl
  8028d9:	d3 ef                	shr    %cl,%edi
  8028db:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028dd:	89 f8                	mov    %edi,%eax
  8028df:	89 ea                	mov    %ebp,%edx
  8028e1:	f7 74 24 08          	divl   0x8(%esp)
  8028e5:	89 d1                	mov    %edx,%ecx
  8028e7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8028e9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028ed:	39 d1                	cmp    %edx,%ecx
  8028ef:	72 17                	jb     802908 <__udivdi3+0x10c>
  8028f1:	74 09                	je     8028fc <__udivdi3+0x100>
  8028f3:	89 fe                	mov    %edi,%esi
  8028f5:	31 ff                	xor    %edi,%edi
  8028f7:	e9 41 ff ff ff       	jmp    80283d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8028fc:	8b 54 24 04          	mov    0x4(%esp),%edx
  802900:	89 f1                	mov    %esi,%ecx
  802902:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802904:	39 c2                	cmp    %eax,%edx
  802906:	73 eb                	jae    8028f3 <__udivdi3+0xf7>
		{
		  q0--;
  802908:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80290b:	31 ff                	xor    %edi,%edi
  80290d:	e9 2b ff ff ff       	jmp    80283d <__udivdi3+0x41>
  802912:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802914:	31 f6                	xor    %esi,%esi
  802916:	e9 22 ff ff ff       	jmp    80283d <__udivdi3+0x41>
	...

0080291c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80291c:	55                   	push   %ebp
  80291d:	57                   	push   %edi
  80291e:	56                   	push   %esi
  80291f:	83 ec 20             	sub    $0x20,%esp
  802922:	8b 44 24 30          	mov    0x30(%esp),%eax
  802926:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80292a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80292e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802932:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802936:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80293a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80293c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80293e:	85 ed                	test   %ebp,%ebp
  802940:	75 16                	jne    802958 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802942:	39 f1                	cmp    %esi,%ecx
  802944:	0f 86 a6 00 00 00    	jbe    8029f0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80294a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80294c:	89 d0                	mov    %edx,%eax
  80294e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802950:	83 c4 20             	add    $0x20,%esp
  802953:	5e                   	pop    %esi
  802954:	5f                   	pop    %edi
  802955:	5d                   	pop    %ebp
  802956:	c3                   	ret    
  802957:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802958:	39 f5                	cmp    %esi,%ebp
  80295a:	0f 87 ac 00 00 00    	ja     802a0c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802960:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802963:	83 f0 1f             	xor    $0x1f,%eax
  802966:	89 44 24 10          	mov    %eax,0x10(%esp)
  80296a:	0f 84 a8 00 00 00    	je     802a18 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802970:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802974:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802976:	bf 20 00 00 00       	mov    $0x20,%edi
  80297b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80297f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802983:	89 f9                	mov    %edi,%ecx
  802985:	d3 e8                	shr    %cl,%eax
  802987:	09 e8                	or     %ebp,%eax
  802989:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80298d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802991:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802995:	d3 e0                	shl    %cl,%eax
  802997:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80299b:	89 f2                	mov    %esi,%edx
  80299d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80299f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8029a3:	d3 e0                	shl    %cl,%eax
  8029a5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8029a9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8029ad:	89 f9                	mov    %edi,%ecx
  8029af:	d3 e8                	shr    %cl,%eax
  8029b1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8029b3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029b5:	89 f2                	mov    %esi,%edx
  8029b7:	f7 74 24 18          	divl   0x18(%esp)
  8029bb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8029bd:	f7 64 24 0c          	mull   0xc(%esp)
  8029c1:	89 c5                	mov    %eax,%ebp
  8029c3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029c5:	39 d6                	cmp    %edx,%esi
  8029c7:	72 67                	jb     802a30 <__umoddi3+0x114>
  8029c9:	74 75                	je     802a40 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8029cb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8029cf:	29 e8                	sub    %ebp,%eax
  8029d1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8029d3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029d7:	d3 e8                	shr    %cl,%eax
  8029d9:	89 f2                	mov    %esi,%edx
  8029db:	89 f9                	mov    %edi,%ecx
  8029dd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8029df:	09 d0                	or     %edx,%eax
  8029e1:	89 f2                	mov    %esi,%edx
  8029e3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029e7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029e9:	83 c4 20             	add    $0x20,%esp
  8029ec:	5e                   	pop    %esi
  8029ed:	5f                   	pop    %edi
  8029ee:	5d                   	pop    %ebp
  8029ef:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8029f0:	85 c9                	test   %ecx,%ecx
  8029f2:	75 0b                	jne    8029ff <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8029f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8029f9:	31 d2                	xor    %edx,%edx
  8029fb:	f7 f1                	div    %ecx
  8029fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8029ff:	89 f0                	mov    %esi,%eax
  802a01:	31 d2                	xor    %edx,%edx
  802a03:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a05:	89 f8                	mov    %edi,%eax
  802a07:	e9 3e ff ff ff       	jmp    80294a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802a0c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a0e:	83 c4 20             	add    $0x20,%esp
  802a11:	5e                   	pop    %esi
  802a12:	5f                   	pop    %edi
  802a13:	5d                   	pop    %ebp
  802a14:	c3                   	ret    
  802a15:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a18:	39 f5                	cmp    %esi,%ebp
  802a1a:	72 04                	jb     802a20 <__umoddi3+0x104>
  802a1c:	39 f9                	cmp    %edi,%ecx
  802a1e:	77 06                	ja     802a26 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a20:	89 f2                	mov    %esi,%edx
  802a22:	29 cf                	sub    %ecx,%edi
  802a24:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802a26:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a28:	83 c4 20             	add    $0x20,%esp
  802a2b:	5e                   	pop    %esi
  802a2c:	5f                   	pop    %edi
  802a2d:	5d                   	pop    %ebp
  802a2e:	c3                   	ret    
  802a2f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a30:	89 d1                	mov    %edx,%ecx
  802a32:	89 c5                	mov    %eax,%ebp
  802a34:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802a38:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802a3c:	eb 8d                	jmp    8029cb <__umoddi3+0xaf>
  802a3e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a40:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802a44:	72 ea                	jb     802a30 <__umoddi3+0x114>
  802a46:	89 f1                	mov    %esi,%ecx
  802a48:	eb 81                	jmp    8029cb <__umoddi3+0xaf>
