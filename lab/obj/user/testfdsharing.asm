
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 eb 01 00 00       	call   80021c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800044:	00 
  800045:	c7 04 24 00 2b 80 00 	movl   $0x802b00,(%esp)
  80004c:	e8 46 1b 00 00       	call   801b97 <open>
  800051:	89 c3                	mov    %eax,%ebx
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("open motd: %e", fd);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 05 2b 80 	movl   $0x802b05,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 13 2b 80 00 	movl   $0x802b13,(%esp)
  800072:	e8 15 02 00 00       	call   80028c <_panic>
	seek(fd, 0);
  800077:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007e:	00 
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 a3 17 00 00       	call   80182a <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800087:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 20 52 80 	movl   $0x805220,0x4(%esp)
  800096:	00 
  800097:	89 1c 24             	mov    %ebx,(%esp)
  80009a:	e8 b5 16 00 00       	call   801754 <readn>
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	7f 20                	jg     8000c5 <umain+0x91>
		panic("readn: %e", n);
  8000a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a9:	c7 44 24 08 28 2b 80 	movl   $0x802b28,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b8:	00 
  8000b9:	c7 04 24 13 2b 80 00 	movl   $0x802b13,(%esp)
  8000c0:	e8 c7 01 00 00       	call   80028c <_panic>

	if ((r = fork()) < 0)
  8000c5:	e8 f9 0f 00 00       	call   8010c3 <fork>
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	85 c0                	test   %eax,%eax
  8000ce:	79 20                	jns    8000f0 <umain+0xbc>
		panic("fork: %e", r);
  8000d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d4:	c7 44 24 08 e5 2f 80 	movl   $0x802fe5,0x8(%esp)
  8000db:	00 
  8000dc:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e3:	00 
  8000e4:	c7 04 24 13 2b 80 00 	movl   $0x802b13,(%esp)
  8000eb:	e8 9c 01 00 00       	call   80028c <_panic>
	if (r == 0) {
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	0f 85 bd 00 00 00    	jne    8001b5 <umain+0x181>
		seek(fd, 0);
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 1c 24             	mov    %ebx,(%esp)
  800103:	e8 22 17 00 00       	call   80182a <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800108:	c7 04 24 68 2b 80 00 	movl   $0x802b68,(%esp)
  80010f:	e8 70 02 00 00       	call   800384 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800114:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011b:	00 
  80011c:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  800123:	00 
  800124:	89 1c 24             	mov    %ebx,(%esp)
  800127:	e8 28 16 00 00       	call   801754 <readn>
  80012c:	39 f8                	cmp    %edi,%eax
  80012e:	74 24                	je     800154 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  800130:	89 44 24 10          	mov    %eax,0x10(%esp)
  800134:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800138:	c7 44 24 08 ac 2b 80 	movl   $0x802bac,0x8(%esp)
  80013f:	00 
  800140:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800147:	00 
  800148:	c7 04 24 13 2b 80 00 	movl   $0x802b13,(%esp)
  80014f:	e8 38 01 00 00       	call   80028c <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800154:	89 44 24 08          	mov    %eax,0x8(%esp)
  800158:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  80015f:	00 
  800160:	c7 04 24 20 52 80 00 	movl   $0x805220,(%esp)
  800167:	e8 c7 09 00 00       	call   800b33 <memcmp>
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 1c                	je     80018c <umain+0x158>
			panic("read in parent got different bytes from read in child");
  800170:	c7 44 24 08 d8 2b 80 	movl   $0x802bd8,0x8(%esp)
  800177:	00 
  800178:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017f:	00 
  800180:	c7 04 24 13 2b 80 00 	movl   $0x802b13,(%esp)
  800187:	e8 00 01 00 00       	call   80028c <_panic>
		cprintf("read in child succeeded\n");
  80018c:	c7 04 24 32 2b 80 00 	movl   $0x802b32,(%esp)
  800193:	e8 ec 01 00 00       	call   800384 <cprintf>
		seek(fd, 0);
  800198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019f:	00 
  8001a0:	89 1c 24             	mov    %ebx,(%esp)
  8001a3:	e8 82 16 00 00       	call   80182a <seek>
		close(fd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 ae 13 00 00       	call   80155e <close>
		exit();
  8001b0:	e8 bb 00 00 00       	call   800270 <exit>
	}
	wait(r);
  8001b5:	89 34 24             	mov    %esi,(%esp)
  8001b8:	e8 ef 22 00 00       	call   8024ac <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  8001cc:	00 
  8001cd:	89 1c 24             	mov    %ebx,(%esp)
  8001d0:	e8 7f 15 00 00       	call   801754 <readn>
  8001d5:	39 f8                	cmp    %edi,%eax
  8001d7:	74 24                	je     8001fd <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e1:	c7 44 24 08 10 2c 80 	movl   $0x802c10,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 13 2b 80 00 	movl   $0x802b13,(%esp)
  8001f8:	e8 8f 00 00 00       	call   80028c <_panic>
	cprintf("read in parent succeeded\n");
  8001fd:	c7 04 24 4b 2b 80 00 	movl   $0x802b4b,(%esp)
  800204:	e8 7b 01 00 00       	call   800384 <cprintf>
	close(fd);
  800209:	89 1c 24             	mov    %ebx,(%esp)
  80020c:	e8 4d 13 00 00       	call   80155e <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800211:	cc                   	int3   

	breakpoint();
}
  800212:	83 c4 2c             	add    $0x2c,%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
	...

0080021c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 10             	sub    $0x10,%esp
  800224:	8b 75 08             	mov    0x8(%ebp),%esi
  800227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80022a:	e8 b4 0a 00 00       	call   800ce3 <sys_getenvid>
  80022f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800234:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80023b:	c1 e0 07             	shl    $0x7,%eax
  80023e:	29 d0                	sub    %edx,%eax
  800240:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800245:	a3 20 54 80 00       	mov    %eax,0x805420


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80024a:	85 f6                	test   %esi,%esi
  80024c:	7e 07                	jle    800255 <libmain+0x39>
		binaryname = argv[0];
  80024e:	8b 03                	mov    (%ebx),%eax
  800250:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800255:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800259:	89 34 24             	mov    %esi,(%esp)
  80025c:	e8 d3 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800261:	e8 0a 00 00 00       	call   800270 <exit>
}
  800266:	83 c4 10             	add    $0x10,%esp
  800269:	5b                   	pop    %ebx
  80026a:	5e                   	pop    %esi
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800276:	e8 14 13 00 00       	call   80158f <close_all>
	sys_env_destroy(0);
  80027b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800282:	e8 0a 0a 00 00       	call   800c91 <sys_env_destroy>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    
  800289:	00 00                	add    %al,(%eax)
	...

0080028c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800294:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800297:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  80029d:	e8 41 0a 00 00       	call   800ce3 <sys_getenvid>
  8002a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	c7 04 24 40 2c 80 00 	movl   $0x802c40,(%esp)
  8002bf:	e8 c0 00 00 00       	call   800384 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 50 00 00 00       	call   800323 <vcprintf>
	cprintf("\n");
  8002d3:	c7 04 24 49 2b 80 00 	movl   $0x802b49,(%esp)
  8002da:	e8 a5 00 00 00       	call   800384 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002df:	cc                   	int3   
  8002e0:	eb fd                	jmp    8002df <_panic+0x53>
	...

008002e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 14             	sub    $0x14,%esp
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ee:	8b 03                	mov    (%ebx),%eax
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002f7:	40                   	inc    %eax
  8002f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ff:	75 19                	jne    80031a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800301:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800308:	00 
  800309:	8d 43 08             	lea    0x8(%ebx),%eax
  80030c:	89 04 24             	mov    %eax,(%esp)
  80030f:	e8 40 09 00 00       	call   800c54 <sys_cputs>
		b->idx = 0;
  800314:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80031a:	ff 43 04             	incl   0x4(%ebx)
}
  80031d:	83 c4 14             	add    $0x14,%esp
  800320:	5b                   	pop    %ebx
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80032c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800333:	00 00 00 
	b.cnt = 0;
  800336:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
  800343:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800354:	89 44 24 04          	mov    %eax,0x4(%esp)
  800358:	c7 04 24 e4 02 80 00 	movl   $0x8002e4,(%esp)
  80035f:	e8 82 01 00 00       	call   8004e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800364:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80036a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	e8 d8 08 00 00       	call   800c54 <sys_cputs>

	return b.cnt;
}
  80037c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80038d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	e8 87 ff ff ff       	call   800323 <vcprintf>
	va_end(ap);

	return cnt;
}
  80039c:	c9                   	leave  
  80039d:	c3                   	ret    
	...

008003a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
  8003a6:	83 ec 3c             	sub    $0x3c,%esp
  8003a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ac:	89 d7                	mov    %edx,%edi
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	75 08                	jne    8003cc <printnum+0x2c>
  8003c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ca:	77 57                	ja     800423 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003d0:	4b                   	dec    %ebx
  8003d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003dc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003e0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003eb:	00 
  8003ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f9:	e8 aa 24 00 00       	call   8028a8 <__udivdi3>
  8003fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800402:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	89 54 24 04          	mov    %edx,0x4(%esp)
  80040d:	89 fa                	mov    %edi,%edx
  80040f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800412:	e8 89 ff ff ff       	call   8003a0 <printnum>
  800417:	eb 0f                	jmp    800428 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800419:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80041d:	89 34 24             	mov    %esi,(%esp)
  800420:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800423:	4b                   	dec    %ebx
  800424:	85 db                	test   %ebx,%ebx
  800426:	7f f1                	jg     800419 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800428:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800430:	8b 45 10             	mov    0x10(%ebp),%eax
  800433:	89 44 24 08          	mov    %eax,0x8(%esp)
  800437:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80043e:	00 
  80043f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800442:	89 04 24             	mov    %eax,(%esp)
  800445:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044c:	e8 77 25 00 00       	call   8029c8 <__umoddi3>
  800451:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800455:	0f be 80 63 2c 80 00 	movsbl 0x802c63(%eax),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800462:	83 c4 3c             	add    $0x3c,%esp
  800465:	5b                   	pop    %ebx
  800466:	5e                   	pop    %esi
  800467:	5f                   	pop    %edi
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    

0080046a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046d:	83 fa 01             	cmp    $0x1,%edx
  800470:	7e 0e                	jle    800480 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 4a 08             	lea    0x8(%edx),%ecx
  800477:	89 08                	mov    %ecx,(%eax)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	8b 52 04             	mov    0x4(%edx),%edx
  80047e:	eb 22                	jmp    8004a2 <getuint+0x38>
	else if (lflag)
  800480:	85 d2                	test   %edx,%edx
  800482:	74 10                	je     800494 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 04             	lea    0x4(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	ba 00 00 00 00       	mov    $0x0,%edx
  800492:	eb 0e                	jmp    8004a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800494:	8b 10                	mov    (%eax),%edx
  800496:	8d 4a 04             	lea    0x4(%edx),%ecx
  800499:	89 08                	mov    %ecx,(%eax)
  80049b:	8b 02                	mov    (%edx),%eax
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a2:	5d                   	pop    %ebp
  8004a3:	c3                   	ret    

008004a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004aa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004ad:	8b 10                	mov    (%eax),%edx
  8004af:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b2:	73 08                	jae    8004bc <sprintputch+0x18>
		*b->buf++ = ch;
  8004b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b7:	88 0a                	mov    %cl,(%edx)
  8004b9:	42                   	inc    %edx
  8004ba:	89 10                	mov    %edx,(%eax)
}
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 02 00 00 00       	call   8004e6 <vprintfmt>
	va_end(ap);
}
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    

008004e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
  8004ec:	83 ec 4c             	sub    $0x4c,%esp
  8004ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f5:	eb 12                	jmp    800509 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	0f 84 6b 03 00 00    	je     80086a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800509:	0f b6 06             	movzbl (%esi),%eax
  80050c:	46                   	inc    %esi
  80050d:	83 f8 25             	cmp    $0x25,%eax
  800510:	75 e5                	jne    8004f7 <vprintfmt+0x11>
  800512:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800516:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80051d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800522:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800529:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052e:	eb 26                	jmp    800556 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800533:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800537:	eb 1d                	jmp    800556 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80053c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800540:	eb 14                	jmp    800556 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800545:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80054c:	eb 08                	jmp    800556 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80054e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800551:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	0f b6 06             	movzbl (%esi),%eax
  800559:	8d 56 01             	lea    0x1(%esi),%edx
  80055c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80055f:	8a 16                	mov    (%esi),%dl
  800561:	83 ea 23             	sub    $0x23,%edx
  800564:	80 fa 55             	cmp    $0x55,%dl
  800567:	0f 87 e1 02 00 00    	ja     80084e <vprintfmt+0x368>
  80056d:	0f b6 d2             	movzbl %dl,%edx
  800570:	ff 24 95 a0 2d 80 00 	jmp    *0x802da0(,%edx,4)
  800577:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80057a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80057f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800582:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800586:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800589:	8d 50 d0             	lea    -0x30(%eax),%edx
  80058c:	83 fa 09             	cmp    $0x9,%edx
  80058f:	77 2a                	ja     8005bb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800591:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800592:	eb eb                	jmp    80057f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a2:	eb 17                	jmp    8005bb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a8:	78 98                	js     800542 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ad:	eb a7                	jmp    800556 <vprintfmt+0x70>
  8005af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005b9:	eb 9b                	jmp    800556 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bf:	79 95                	jns    800556 <vprintfmt+0x70>
  8005c1:	eb 8b                	jmp    80054e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005c7:	eb 8d                	jmp    800556 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005e1:	e9 23 ff ff ff       	jmp    800509 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	85 c0                	test   %eax,%eax
  8005f3:	79 02                	jns    8005f7 <vprintfmt+0x111>
  8005f5:	f7 d8                	neg    %eax
  8005f7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f9:	83 f8 10             	cmp    $0x10,%eax
  8005fc:	7f 0b                	jg     800609 <vprintfmt+0x123>
  8005fe:	8b 04 85 00 2f 80 00 	mov    0x802f00(,%eax,4),%eax
  800605:	85 c0                	test   %eax,%eax
  800607:	75 23                	jne    80062c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800609:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060d:	c7 44 24 08 7b 2c 80 	movl   $0x802c7b,0x8(%esp)
  800614:	00 
  800615:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800619:	8b 45 08             	mov    0x8(%ebp),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	e8 9a fe ff ff       	call   8004be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800627:	e9 dd fe ff ff       	jmp    800509 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80062c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800630:	c7 44 24 08 ed 30 80 	movl   $0x8030ed,0x8(%esp)
  800637:	00 
  800638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063c:	8b 55 08             	mov    0x8(%ebp),%edx
  80063f:	89 14 24             	mov    %edx,(%esp)
  800642:	e8 77 fe ff ff       	call   8004be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800647:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064a:	e9 ba fe ff ff       	jmp    800509 <vprintfmt+0x23>
  80064f:	89 f9                	mov    %edi,%ecx
  800651:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800654:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 30                	mov    (%eax),%esi
  800662:	85 f6                	test   %esi,%esi
  800664:	75 05                	jne    80066b <vprintfmt+0x185>
				p = "(null)";
  800666:	be 74 2c 80 00       	mov    $0x802c74,%esi
			if (width > 0 && padc != '-')
  80066b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80066f:	0f 8e 84 00 00 00    	jle    8006f9 <vprintfmt+0x213>
  800675:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800679:	74 7e                	je     8006f9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80067f:	89 34 24             	mov    %esi,(%esp)
  800682:	e8 8b 02 00 00       	call   800912 <strnlen>
  800687:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80068a:	29 c2                	sub    %eax,%edx
  80068c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80068f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800693:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800696:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800699:	89 de                	mov    %ebx,%esi
  80069b:	89 d3                	mov    %edx,%ebx
  80069d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	eb 0b                	jmp    8006ac <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a5:	89 3c 24             	mov    %edi,(%esp)
  8006a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	4b                   	dec    %ebx
  8006ac:	85 db                	test   %ebx,%ebx
  8006ae:	7f f1                	jg     8006a1 <vprintfmt+0x1bb>
  8006b0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006b3:	89 f3                	mov    %esi,%ebx
  8006b5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	79 05                	jns    8006c4 <vprintfmt+0x1de>
  8006bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c7:	29 c2                	sub    %eax,%edx
  8006c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006cc:	eb 2b                	jmp    8006f9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d2:	74 18                	je     8006ec <vprintfmt+0x206>
  8006d4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006d7:	83 fa 5e             	cmp    $0x5e,%edx
  8006da:	76 10                	jbe    8006ec <vprintfmt+0x206>
					putch('?', putdat);
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	eb 0a                	jmp    8006f6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f0:	89 04 24             	mov    %eax,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f6:	ff 4d e4             	decl   -0x1c(%ebp)
  8006f9:	0f be 06             	movsbl (%esi),%eax
  8006fc:	46                   	inc    %esi
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	74 21                	je     800722 <vprintfmt+0x23c>
  800701:	85 ff                	test   %edi,%edi
  800703:	78 c9                	js     8006ce <vprintfmt+0x1e8>
  800705:	4f                   	dec    %edi
  800706:	79 c6                	jns    8006ce <vprintfmt+0x1e8>
  800708:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070b:	89 de                	mov    %ebx,%esi
  80070d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800710:	eb 18                	jmp    80072a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800712:	89 74 24 04          	mov    %esi,0x4(%esp)
  800716:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80071d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071f:	4b                   	dec    %ebx
  800720:	eb 08                	jmp    80072a <vprintfmt+0x244>
  800722:	8b 7d 08             	mov    0x8(%ebp),%edi
  800725:	89 de                	mov    %ebx,%esi
  800727:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80072a:	85 db                	test   %ebx,%ebx
  80072c:	7f e4                	jg     800712 <vprintfmt+0x22c>
  80072e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800731:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800736:	e9 ce fd ff ff       	jmp    800509 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073b:	83 f9 01             	cmp    $0x1,%ecx
  80073e:	7e 10                	jle    800750 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 50 08             	lea    0x8(%eax),%edx
  800746:	89 55 14             	mov    %edx,0x14(%ebp)
  800749:	8b 30                	mov    (%eax),%esi
  80074b:	8b 78 04             	mov    0x4(%eax),%edi
  80074e:	eb 26                	jmp    800776 <vprintfmt+0x290>
	else if (lflag)
  800750:	85 c9                	test   %ecx,%ecx
  800752:	74 12                	je     800766 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 04             	lea    0x4(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 30                	mov    (%eax),%esi
  80075f:	89 f7                	mov    %esi,%edi
  800761:	c1 ff 1f             	sar    $0x1f,%edi
  800764:	eb 10                	jmp    800776 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8d 50 04             	lea    0x4(%eax),%edx
  80076c:	89 55 14             	mov    %edx,0x14(%ebp)
  80076f:	8b 30                	mov    (%eax),%esi
  800771:	89 f7                	mov    %esi,%edi
  800773:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800776:	85 ff                	test   %edi,%edi
  800778:	78 0a                	js     800784 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077f:	e9 8c 00 00 00       	jmp    800810 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800784:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800788:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80078f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800792:	f7 de                	neg    %esi
  800794:	83 d7 00             	adc    $0x0,%edi
  800797:	f7 df                	neg    %edi
			}
			base = 10;
  800799:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079e:	eb 70                	jmp    800810 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a0:	89 ca                	mov    %ecx,%edx
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a5:	e8 c0 fc ff ff       	call   80046a <getuint>
  8007aa:	89 c6                	mov    %eax,%esi
  8007ac:	89 d7                	mov    %edx,%edi
			base = 10;
  8007ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007b3:	eb 5b                	jmp    800810 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8007b5:	89 ca                	mov    %ecx,%edx
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ba:	e8 ab fc ff ff       	call   80046a <getuint>
  8007bf:	89 c6                	mov    %eax,%esi
  8007c1:	89 d7                	mov    %edx,%edi
			base = 8;
  8007c3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007c8:	eb 46                	jmp    800810 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ef:	8b 30                	mov    (%eax),%esi
  8007f1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007fb:	eb 13                	jmp    800810 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007fd:	89 ca                	mov    %ecx,%edx
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800802:	e8 63 fc ff ff       	call   80046a <getuint>
  800807:	89 c6                	mov    %eax,%esi
  800809:	89 d7                	mov    %edx,%edi
			base = 16;
  80080b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800810:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800814:	89 54 24 10          	mov    %edx,0x10(%esp)
  800818:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80081b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80081f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800823:	89 34 24             	mov    %esi,(%esp)
  800826:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80082a:	89 da                	mov    %ebx,%edx
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	e8 6c fb ff ff       	call   8003a0 <printnum>
			break;
  800834:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800837:	e9 cd fc ff ff       	jmp    800509 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800840:	89 04 24             	mov    %eax,(%esp)
  800843:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800849:	e9 bb fc ff ff       	jmp    800509 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800852:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800859:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085c:	eb 01                	jmp    80085f <vprintfmt+0x379>
  80085e:	4e                   	dec    %esi
  80085f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800863:	75 f9                	jne    80085e <vprintfmt+0x378>
  800865:	e9 9f fc ff ff       	jmp    800509 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80086a:	83 c4 4c             	add    $0x4c,%esp
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5f                   	pop    %edi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	83 ec 28             	sub    $0x28,%esp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800881:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800885:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800888:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088f:	85 c0                	test   %eax,%eax
  800891:	74 30                	je     8008c3 <vsnprintf+0x51>
  800893:	85 d2                	test   %edx,%edx
  800895:	7e 33                	jle    8008ca <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800897:	8b 45 14             	mov    0x14(%ebp),%eax
  80089a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089e:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	c7 04 24 a4 04 80 00 	movl   $0x8004a4,(%esp)
  8008b3:	e8 2e fc ff ff       	call   8004e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c1:	eb 0c                	jmp    8008cf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c8:	eb 05                	jmp    8008cf <vsnprintf+0x5d>
  8008ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    

008008d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008de:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	89 04 24             	mov    %eax,(%esp)
  8008f2:	e8 7b ff ff ff       	call   800872 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    
  8008f9:	00 00                	add    %al,(%eax)
	...

008008fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
  800907:	eb 01                	jmp    80090a <strlen+0xe>
		n++;
  800909:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80090a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80090e:	75 f9                	jne    800909 <strlen+0xd>
		n++;
	return n;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
  800920:	eb 01                	jmp    800923 <strnlen+0x11>
		n++;
  800922:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800923:	39 d0                	cmp    %edx,%eax
  800925:	74 06                	je     80092d <strnlen+0x1b>
  800927:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80092b:	75 f5                	jne    800922 <strnlen+0x10>
		n++;
	return n;
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	53                   	push   %ebx
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800939:	ba 00 00 00 00       	mov    $0x0,%edx
  80093e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800941:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800944:	42                   	inc    %edx
  800945:	84 c9                	test   %cl,%cl
  800947:	75 f5                	jne    80093e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800949:	5b                   	pop    %ebx
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	53                   	push   %ebx
  800950:	83 ec 08             	sub    $0x8,%esp
  800953:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800956:	89 1c 24             	mov    %ebx,(%esp)
  800959:	e8 9e ff ff ff       	call   8008fc <strlen>
	strcpy(dst + len, src);
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800961:	89 54 24 04          	mov    %edx,0x4(%esp)
  800965:	01 d8                	add    %ebx,%eax
  800967:	89 04 24             	mov    %eax,(%esp)
  80096a:	e8 c0 ff ff ff       	call   80092f <strcpy>
	return dst;
}
  80096f:	89 d8                	mov    %ebx,%eax
  800971:	83 c4 08             	add    $0x8,%esp
  800974:	5b                   	pop    %ebx
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800982:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800985:	b9 00 00 00 00       	mov    $0x0,%ecx
  80098a:	eb 0c                	jmp    800998 <strncpy+0x21>
		*dst++ = *src;
  80098c:	8a 1a                	mov    (%edx),%bl
  80098e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800991:	80 3a 01             	cmpb   $0x1,(%edx)
  800994:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800997:	41                   	inc    %ecx
  800998:	39 f1                	cmp    %esi,%ecx
  80099a:	75 f0                	jne    80098c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ae:	85 d2                	test   %edx,%edx
  8009b0:	75 0a                	jne    8009bc <strlcpy+0x1c>
  8009b2:	89 f0                	mov    %esi,%eax
  8009b4:	eb 1a                	jmp    8009d0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b6:	88 18                	mov    %bl,(%eax)
  8009b8:	40                   	inc    %eax
  8009b9:	41                   	inc    %ecx
  8009ba:	eb 02                	jmp    8009be <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009be:	4a                   	dec    %edx
  8009bf:	74 0a                	je     8009cb <strlcpy+0x2b>
  8009c1:	8a 19                	mov    (%ecx),%bl
  8009c3:	84 db                	test   %bl,%bl
  8009c5:	75 ef                	jne    8009b6 <strlcpy+0x16>
  8009c7:	89 c2                	mov    %eax,%edx
  8009c9:	eb 02                	jmp    8009cd <strlcpy+0x2d>
  8009cb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009cd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009d0:	29 f0                	sub    %esi,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009df:	eb 02                	jmp    8009e3 <strcmp+0xd>
		p++, q++;
  8009e1:	41                   	inc    %ecx
  8009e2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009e3:	8a 01                	mov    (%ecx),%al
  8009e5:	84 c0                	test   %al,%al
  8009e7:	74 04                	je     8009ed <strcmp+0x17>
  8009e9:	3a 02                	cmp    (%edx),%al
  8009eb:	74 f4                	je     8009e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ed:	0f b6 c0             	movzbl %al,%eax
  8009f0:	0f b6 12             	movzbl (%edx),%edx
  8009f3:	29 d0                	sub    %edx,%eax
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a01:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a04:	eb 03                	jmp    800a09 <strncmp+0x12>
		n--, p++, q++;
  800a06:	4a                   	dec    %edx
  800a07:	40                   	inc    %eax
  800a08:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a09:	85 d2                	test   %edx,%edx
  800a0b:	74 14                	je     800a21 <strncmp+0x2a>
  800a0d:	8a 18                	mov    (%eax),%bl
  800a0f:	84 db                	test   %bl,%bl
  800a11:	74 04                	je     800a17 <strncmp+0x20>
  800a13:	3a 19                	cmp    (%ecx),%bl
  800a15:	74 ef                	je     800a06 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a17:	0f b6 00             	movzbl (%eax),%eax
  800a1a:	0f b6 11             	movzbl (%ecx),%edx
  800a1d:	29 d0                	sub    %edx,%eax
  800a1f:	eb 05                	jmp    800a26 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a32:	eb 05                	jmp    800a39 <strchr+0x10>
		if (*s == c)
  800a34:	38 ca                	cmp    %cl,%dl
  800a36:	74 0c                	je     800a44 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a38:	40                   	inc    %eax
  800a39:	8a 10                	mov    (%eax),%dl
  800a3b:	84 d2                	test   %dl,%dl
  800a3d:	75 f5                	jne    800a34 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a4f:	eb 05                	jmp    800a56 <strfind+0x10>
		if (*s == c)
  800a51:	38 ca                	cmp    %cl,%dl
  800a53:	74 07                	je     800a5c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a55:	40                   	inc    %eax
  800a56:	8a 10                	mov    (%eax),%dl
  800a58:	84 d2                	test   %dl,%dl
  800a5a:	75 f5                	jne    800a51 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a6d:	85 c9                	test   %ecx,%ecx
  800a6f:	74 30                	je     800aa1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a71:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a77:	75 25                	jne    800a9e <memset+0x40>
  800a79:	f6 c1 03             	test   $0x3,%cl
  800a7c:	75 20                	jne    800a9e <memset+0x40>
		c &= 0xFF;
  800a7e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a81:	89 d3                	mov    %edx,%ebx
  800a83:	c1 e3 08             	shl    $0x8,%ebx
  800a86:	89 d6                	mov    %edx,%esi
  800a88:	c1 e6 18             	shl    $0x18,%esi
  800a8b:	89 d0                	mov    %edx,%eax
  800a8d:	c1 e0 10             	shl    $0x10,%eax
  800a90:	09 f0                	or     %esi,%eax
  800a92:	09 d0                	or     %edx,%eax
  800a94:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a96:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a99:	fc                   	cld    
  800a9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9c:	eb 03                	jmp    800aa1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9e:	fc                   	cld    
  800a9f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa1:	89 f8                	mov    %edi,%eax
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab6:	39 c6                	cmp    %eax,%esi
  800ab8:	73 34                	jae    800aee <memmove+0x46>
  800aba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abd:	39 d0                	cmp    %edx,%eax
  800abf:	73 2d                	jae    800aee <memmove+0x46>
		s += n;
		d += n;
  800ac1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	f6 c2 03             	test   $0x3,%dl
  800ac7:	75 1b                	jne    800ae4 <memmove+0x3c>
  800ac9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acf:	75 13                	jne    800ae4 <memmove+0x3c>
  800ad1:	f6 c1 03             	test   $0x3,%cl
  800ad4:	75 0e                	jne    800ae4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad6:	83 ef 04             	sub    $0x4,%edi
  800ad9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800adc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800adf:	fd                   	std    
  800ae0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae2:	eb 07                	jmp    800aeb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae4:	4f                   	dec    %edi
  800ae5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae8:	fd                   	std    
  800ae9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aeb:	fc                   	cld    
  800aec:	eb 20                	jmp    800b0e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af4:	75 13                	jne    800b09 <memmove+0x61>
  800af6:	a8 03                	test   $0x3,%al
  800af8:	75 0f                	jne    800b09 <memmove+0x61>
  800afa:	f6 c1 03             	test   $0x3,%cl
  800afd:	75 0a                	jne    800b09 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b02:	89 c7                	mov    %eax,%edi
  800b04:	fc                   	cld    
  800b05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b07:	eb 05                	jmp    800b0e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b09:	89 c7                	mov    %eax,%edi
  800b0b:	fc                   	cld    
  800b0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b18:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	89 04 24             	mov    %eax,(%esp)
  800b2c:	e8 77 ff ff ff       	call   800aa8 <memmove>
}
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    

00800b33 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	eb 16                	jmp    800b5f <memcmp+0x2c>
		if (*s1 != *s2)
  800b49:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b4c:	42                   	inc    %edx
  800b4d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b51:	38 c8                	cmp    %cl,%al
  800b53:	74 0a                	je     800b5f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c0             	movzbl %al,%eax
  800b58:	0f b6 c9             	movzbl %cl,%ecx
  800b5b:	29 c8                	sub    %ecx,%eax
  800b5d:	eb 09                	jmp    800b68 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5f:	39 da                	cmp    %ebx,%edx
  800b61:	75 e6                	jne    800b49 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b76:	89 c2                	mov    %eax,%edx
  800b78:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7b:	eb 05                	jmp    800b82 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7d:	38 08                	cmp    %cl,(%eax)
  800b7f:	74 05                	je     800b86 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b81:	40                   	inc    %eax
  800b82:	39 d0                	cmp    %edx,%eax
  800b84:	72 f7                	jb     800b7d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b94:	eb 01                	jmp    800b97 <strtol+0xf>
		s++;
  800b96:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b97:	8a 02                	mov    (%edx),%al
  800b99:	3c 20                	cmp    $0x20,%al
  800b9b:	74 f9                	je     800b96 <strtol+0xe>
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	74 f5                	je     800b96 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba1:	3c 2b                	cmp    $0x2b,%al
  800ba3:	75 08                	jne    800bad <strtol+0x25>
		s++;
  800ba5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bab:	eb 13                	jmp    800bc0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bad:	3c 2d                	cmp    $0x2d,%al
  800baf:	75 0a                	jne    800bbb <strtol+0x33>
		s++, neg = 1;
  800bb1:	8d 52 01             	lea    0x1(%edx),%edx
  800bb4:	bf 01 00 00 00       	mov    $0x1,%edi
  800bb9:	eb 05                	jmp    800bc0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bbb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc0:	85 db                	test   %ebx,%ebx
  800bc2:	74 05                	je     800bc9 <strtol+0x41>
  800bc4:	83 fb 10             	cmp    $0x10,%ebx
  800bc7:	75 28                	jne    800bf1 <strtol+0x69>
  800bc9:	8a 02                	mov    (%edx),%al
  800bcb:	3c 30                	cmp    $0x30,%al
  800bcd:	75 10                	jne    800bdf <strtol+0x57>
  800bcf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd3:	75 0a                	jne    800bdf <strtol+0x57>
		s += 2, base = 16;
  800bd5:	83 c2 02             	add    $0x2,%edx
  800bd8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bdd:	eb 12                	jmp    800bf1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bdf:	85 db                	test   %ebx,%ebx
  800be1:	75 0e                	jne    800bf1 <strtol+0x69>
  800be3:	3c 30                	cmp    $0x30,%al
  800be5:	75 05                	jne    800bec <strtol+0x64>
		s++, base = 8;
  800be7:	42                   	inc    %edx
  800be8:	b3 08                	mov    $0x8,%bl
  800bea:	eb 05                	jmp    800bf1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bec:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf8:	8a 0a                	mov    (%edx),%cl
  800bfa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bfd:	80 fb 09             	cmp    $0x9,%bl
  800c00:	77 08                	ja     800c0a <strtol+0x82>
			dig = *s - '0';
  800c02:	0f be c9             	movsbl %cl,%ecx
  800c05:	83 e9 30             	sub    $0x30,%ecx
  800c08:	eb 1e                	jmp    800c28 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c0a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c0d:	80 fb 19             	cmp    $0x19,%bl
  800c10:	77 08                	ja     800c1a <strtol+0x92>
			dig = *s - 'a' + 10;
  800c12:	0f be c9             	movsbl %cl,%ecx
  800c15:	83 e9 57             	sub    $0x57,%ecx
  800c18:	eb 0e                	jmp    800c28 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c1a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c1d:	80 fb 19             	cmp    $0x19,%bl
  800c20:	77 12                	ja     800c34 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c22:	0f be c9             	movsbl %cl,%ecx
  800c25:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c28:	39 f1                	cmp    %esi,%ecx
  800c2a:	7d 0c                	jge    800c38 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c2c:	42                   	inc    %edx
  800c2d:	0f af c6             	imul   %esi,%eax
  800c30:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c32:	eb c4                	jmp    800bf8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c34:	89 c1                	mov    %eax,%ecx
  800c36:	eb 02                	jmp    800c3a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c38:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3e:	74 05                	je     800c45 <strtol+0xbd>
		*endptr = (char *) s;
  800c40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c43:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c45:	85 ff                	test   %edi,%edi
  800c47:	74 04                	je     800c4d <strtol+0xc5>
  800c49:	89 c8                	mov    %ecx,%eax
  800c4b:	f7 d8                	neg    %eax
}
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    
	...

00800c54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 c3                	mov    %eax,%ebx
  800c67:	89 c7                	mov    %eax,%edi
  800c69:	89 c6                	mov    %eax,%esi
  800c6b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c78:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c82:	89 d1                	mov    %edx,%ecx
  800c84:	89 d3                	mov    %edx,%ebx
  800c86:	89 d7                	mov    %edx,%edi
  800c88:	89 d6                	mov    %edx,%esi
  800c8a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 cb                	mov    %ecx,%ebx
  800ca9:	89 cf                	mov    %ecx,%edi
  800cab:	89 ce                	mov    %ecx,%esi
  800cad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7e 28                	jle    800cdb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  800cc6:	00 
  800cc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cce:	00 
  800ccf:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800cd6:	e8 b1 f5 ff ff       	call   80028c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cdb:	83 c4 2c             	add    $0x2c,%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cee:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf3:	89 d1                	mov    %edx,%ecx
  800cf5:	89 d3                	mov    %edx,%ebx
  800cf7:	89 d7                	mov    %edx,%edi
  800cf9:	89 d6                	mov    %edx,%esi
  800cfb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_yield>:

void
sys_yield(void)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d12:	89 d1                	mov    %edx,%ecx
  800d14:	89 d3                	mov    %edx,%ebx
  800d16:	89 d7                	mov    %edx,%edi
  800d18:	89 d6                	mov    %edx,%esi
  800d1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	be 00 00 00 00       	mov    $0x0,%esi
  800d2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 f7                	mov    %esi,%edi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 28                	jle    800d6d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d49:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d50:	00 
  800d51:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  800d58:	00 
  800d59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d60:	00 
  800d61:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800d68:	e8 1f f5 ff ff       	call   80028c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6d:	83 c4 2c             	add    $0x2c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d83:	8b 75 18             	mov    0x18(%ebp),%esi
  800d86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d94:	85 c0                	test   %eax,%eax
  800d96:	7e 28                	jle    800dc0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800da3:	00 
  800da4:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  800dab:	00 
  800dac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db3:	00 
  800db4:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800dbb:	e8 cc f4 ff ff       	call   80028c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc0:	83 c4 2c             	add    $0x2c,%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 28                	jle    800e13 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800def:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800df6:	00 
  800df7:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800e0e:	e8 79 f4 ff ff       	call   80028c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e13:	83 c4 2c             	add    $0x2c,%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e29:	b8 08 00 00 00       	mov    $0x8,%eax
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
  800e34:	89 df                	mov    %ebx,%edi
  800e36:	89 de                	mov    %ebx,%esi
  800e38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	7e 28                	jle    800e66 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e42:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e49:	00 
  800e4a:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  800e51:	00 
  800e52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e59:	00 
  800e5a:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800e61:	e8 26 f4 ff ff       	call   80028c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e66:	83 c4 2c             	add    $0x2c,%esp
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	89 df                	mov    %ebx,%edi
  800e89:	89 de                	mov    %ebx,%esi
  800e8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	7e 28                	jle    800eb9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e95:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eac:	00 
  800ead:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800eb4:	e8 d3 f3 ff ff       	call   80028c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb9:	83 c4 2c             	add    $0x2c,%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	57                   	push   %edi
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
  800ec7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eda:	89 df                	mov    %ebx,%edi
  800edc:	89 de                	mov    %ebx,%esi
  800ede:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	7e 28                	jle    800f0c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eef:	00 
  800ef0:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  800ef7:	00 
  800ef8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eff:	00 
  800f00:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800f07:	e8 80 f3 ff ff       	call   80028c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0c:	83 c4 2c             	add    $0x2c,%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1a:	be 00 00 00 00       	mov    $0x0,%esi
  800f1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	53                   	push   %ebx
  800f3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4d:	89 cb                	mov    %ecx,%ebx
  800f4f:	89 cf                	mov    %ecx,%edi
  800f51:	89 ce                	mov    %ecx,%esi
  800f53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f55:	85 c0                	test   %eax,%eax
  800f57:	7e 28                	jle    800f81 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f64:	00 
  800f65:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f74:	00 
  800f75:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800f7c:	e8 0b f3 ff ff       	call   80028c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f81:	83 c4 2c             	add    $0x2c,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <sys_time_msec>:

unsigned int
sys_time_msec(void)
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
  800f8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f94:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f99:	89 d1                	mov    %edx,%ecx
  800f9b:	89 d3                	mov    %edx,%ebx
  800f9d:	89 d7                	mov    %edx,%edi
  800f9f:	89 d6                	mov    %edx,%esi
  800fa1:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbe:	89 df                	mov    %ebx,%edi
  800fc0:	89 de                	mov    %ebx,%esi
  800fc2:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd4:	b8 10 00 00 00       	mov    $0x10,%eax
  800fd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdf:	89 df                	mov    %ebx,%edi
  800fe1:	89 de                	mov    %ebx,%esi
  800fe3:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    
	...

00800fec <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 24             	sub    $0x24,%esp
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ff6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800ff8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ffc:	74 2d                	je     80102b <pgfault+0x3f>
  800ffe:	89 d8                	mov    %ebx,%eax
  801000:	c1 e8 16             	shr    $0x16,%eax
  801003:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100a:	a8 01                	test   $0x1,%al
  80100c:	74 1d                	je     80102b <pgfault+0x3f>
  80100e:	89 d8                	mov    %ebx,%eax
  801010:	c1 e8 0c             	shr    $0xc,%eax
  801013:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101a:	f6 c2 01             	test   $0x1,%dl
  80101d:	74 0c                	je     80102b <pgfault+0x3f>
  80101f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801026:	f6 c4 08             	test   $0x8,%ah
  801029:	75 1c                	jne    801047 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  80102b:	c7 44 24 08 90 2f 80 	movl   $0x802f90,0x8(%esp)
  801032:	00 
  801033:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80103a:	00 
  80103b:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  801042:	e8 45 f2 ff ff       	call   80028c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  801047:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  80104d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801064:	e8 b8 fc ff ff       	call   800d21 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  801069:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801070:	00 
  801071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801075:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80107c:	e8 91 fa ff ff       	call   800b12 <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  801081:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801088:	00 
  801089:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80108d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801094:	00 
  801095:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80109c:	00 
  80109d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a4:	e8 cc fc ff ff       	call   800d75 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  8010a9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b8:	e8 0b fd ff ff       	call   800dc8 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  8010bd:	83 c4 24             	add    $0x24,%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	57                   	push   %edi
  8010c7:	56                   	push   %esi
  8010c8:	53                   	push   %ebx
  8010c9:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8010cc:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  8010d3:	e8 e0 15 00 00       	call   8026b8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010d8:	ba 07 00 00 00       	mov    $0x7,%edx
  8010dd:	89 d0                	mov    %edx,%eax
  8010df:	cd 30                	int    $0x30
  8010e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010e4:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	79 20                	jns    80110a <fork+0x47>
		panic("sys_exofork: %e", envid);
  8010ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ee:	c7 44 24 08 de 2f 80 	movl   $0x802fde,0x8(%esp)
  8010f5:	00 
  8010f6:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  8010fd:	00 
  8010fe:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  801105:	e8 82 f1 ff ff       	call   80028c <_panic>
	if (envid == 0)
  80110a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80110e:	75 25                	jne    801135 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  801110:	e8 ce fb ff ff       	call   800ce3 <sys_getenvid>
  801115:	25 ff 03 00 00       	and    $0x3ff,%eax
  80111a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801121:	c1 e0 07             	shl    $0x7,%eax
  801124:	29 d0                	sub    %edx,%eax
  801126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80112b:	a3 20 54 80 00       	mov    %eax,0x805420
		return 0;
  801130:	e9 43 02 00 00       	jmp    801378 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  801135:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  80113a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801140:	0f 84 85 01 00 00    	je     8012cb <fork+0x208>
  801146:	89 d8                	mov    %ebx,%eax
  801148:	c1 e8 16             	shr    $0x16,%eax
  80114b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801152:	a8 01                	test   $0x1,%al
  801154:	0f 84 5f 01 00 00    	je     8012b9 <fork+0x1f6>
  80115a:	89 d8                	mov    %ebx,%eax
  80115c:	c1 e8 0c             	shr    $0xc,%eax
  80115f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801166:	f6 c2 01             	test   $0x1,%dl
  801169:	0f 84 4a 01 00 00    	je     8012b9 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  80116f:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  801171:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801178:	f6 c6 04             	test   $0x4,%dh
  80117b:	74 50                	je     8011cd <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  80117d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801184:	25 07 0e 00 00       	and    $0xe07,%eax
  801189:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801191:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801195:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801199:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a0:	e8 d0 fb ff ff       	call   800d75 <sys_page_map>
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	0f 89 0c 01 00 00    	jns    8012b9 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  8011ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b1:	c7 44 24 08 ee 2f 80 	movl   $0x802fee,0x8(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8011c0:	00 
  8011c1:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  8011c8:	e8 bf f0 ff ff       	call   80028c <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  8011cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011d4:	f6 c2 02             	test   $0x2,%dl
  8011d7:	75 10                	jne    8011e9 <fork+0x126>
  8011d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e0:	f6 c4 08             	test   $0x8,%ah
  8011e3:	0f 84 8c 00 00 00    	je     801275 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  8011e9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011f0:	00 
  8011f1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801204:	e8 6c fb ff ff       	call   800d75 <sys_page_map>
  801209:	85 c0                	test   %eax,%eax
  80120b:	79 20                	jns    80122d <fork+0x16a>
		{
			panic("duppage error: %e",e);
  80120d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801211:	c7 44 24 08 ee 2f 80 	movl   $0x802fee,0x8(%esp)
  801218:	00 
  801219:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801220:	00 
  801221:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  801228:	e8 5f f0 ff ff       	call   80028c <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  80122d:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801234:	00 
  801235:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801239:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801240:	00 
  801241:	89 74 24 04          	mov    %esi,0x4(%esp)
  801245:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80124c:	e8 24 fb ff ff       	call   800d75 <sys_page_map>
  801251:	85 c0                	test   %eax,%eax
  801253:	79 64                	jns    8012b9 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801255:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801259:	c7 44 24 08 ee 2f 80 	movl   $0x802fee,0x8(%esp)
  801260:	00 
  801261:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  801270:	e8 17 f0 ff ff       	call   80028c <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  801275:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80127c:	00 
  80127d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801281:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801285:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801290:	e8 e0 fa ff ff       	call   800d75 <sys_page_map>
  801295:	85 c0                	test   %eax,%eax
  801297:	79 20                	jns    8012b9 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80129d:	c7 44 24 08 ee 2f 80 	movl   $0x802fee,0x8(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8012ac:	00 
  8012ad:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  8012b4:	e8 d3 ef ff ff       	call   80028c <_panic>
  8012b9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  8012bf:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8012c5:	0f 85 6f fe ff ff    	jne    80113a <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  8012cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012d2:	00 
  8012d3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012da:	ee 
  8012db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012de:	89 04 24             	mov    %eax,(%esp)
  8012e1:	e8 3b fa ff ff       	call   800d21 <sys_page_alloc>
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	79 20                	jns    80130a <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  8012ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ee:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8012f5:	00 
  8012f6:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  8012fd:	00 
  8012fe:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  801305:	e8 82 ef ff ff       	call   80028c <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80130a:	c7 44 24 04 04 27 80 	movl   $0x802704,0x4(%esp)
  801311:	00 
  801312:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801315:	89 04 24             	mov    %eax,(%esp)
  801318:	e8 a4 fb ff ff       	call   800ec1 <sys_env_set_pgfault_upcall>
  80131d:	85 c0                	test   %eax,%eax
  80131f:	79 20                	jns    801341 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  801321:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801325:	c7 44 24 08 b4 2f 80 	movl   $0x802fb4,0x8(%esp)
  80132c:	00 
  80132d:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801334:	00 
  801335:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  80133c:	e8 4b ef ff ff       	call   80028c <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801341:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801348:	00 
  801349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80134c:	89 04 24             	mov    %eax,(%esp)
  80134f:	e8 c7 fa ff ff       	call   800e1b <sys_env_set_status>
  801354:	85 c0                	test   %eax,%eax
  801356:	79 20                	jns    801378 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801358:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80135c:	c7 44 24 08 13 30 80 	movl   $0x803013,0x8(%esp)
  801363:	00 
  801364:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80136b:	00 
  80136c:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  801373:	e8 14 ef ff ff       	call   80028c <_panic>

	return envid;
	// panic("fork not implemented");
}
  801378:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80137b:	83 c4 3c             	add    $0x3c,%esp
  80137e:	5b                   	pop    %ebx
  80137f:	5e                   	pop    %esi
  801380:	5f                   	pop    %edi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <sfork>:

// Challenge!
int
sfork(void)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801389:	c7 44 24 08 2a 30 80 	movl   $0x80302a,0x8(%esp)
  801390:	00 
  801391:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801398:	00 
  801399:	c7 04 24 d3 2f 80 00 	movl   $0x802fd3,(%esp)
  8013a0:	e8 e7 ee ff ff       	call   80028c <_panic>
  8013a5:	00 00                	add    %al,(%eax)
	...

008013a8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b3:	c1 e8 0c             	shr    $0xc,%eax
}
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013be:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c1:	89 04 24             	mov    %eax,(%esp)
  8013c4:	e8 df ff ff ff       	call   8013a8 <fd2num>
  8013c9:	c1 e0 0c             	shl    $0xc,%eax
  8013cc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	53                   	push   %ebx
  8013d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013da:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013df:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	c1 ea 16             	shr    $0x16,%edx
  8013e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ed:	f6 c2 01             	test   $0x1,%dl
  8013f0:	74 11                	je     801403 <fd_alloc+0x30>
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	c1 ea 0c             	shr    $0xc,%edx
  8013f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fe:	f6 c2 01             	test   $0x1,%dl
  801401:	75 09                	jne    80140c <fd_alloc+0x39>
			*fd_store = fd;
  801403:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801405:	b8 00 00 00 00       	mov    $0x0,%eax
  80140a:	eb 17                	jmp    801423 <fd_alloc+0x50>
  80140c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801411:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801416:	75 c7                	jne    8013df <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801418:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80141e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801423:	5b                   	pop    %ebx
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80142c:	83 f8 1f             	cmp    $0x1f,%eax
  80142f:	77 36                	ja     801467 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801431:	c1 e0 0c             	shl    $0xc,%eax
  801434:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801439:	89 c2                	mov    %eax,%edx
  80143b:	c1 ea 16             	shr    $0x16,%edx
  80143e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801445:	f6 c2 01             	test   $0x1,%dl
  801448:	74 24                	je     80146e <fd_lookup+0x48>
  80144a:	89 c2                	mov    %eax,%edx
  80144c:	c1 ea 0c             	shr    $0xc,%edx
  80144f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801456:	f6 c2 01             	test   $0x1,%dl
  801459:	74 1a                	je     801475 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80145b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80145e:	89 02                	mov    %eax,(%edx)
	return 0;
  801460:	b8 00 00 00 00       	mov    $0x0,%eax
  801465:	eb 13                	jmp    80147a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146c:	eb 0c                	jmp    80147a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80146e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801473:	eb 05                	jmp    80147a <fd_lookup+0x54>
  801475:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 14             	sub    $0x14,%esp
  801483:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801486:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801489:	ba 00 00 00 00       	mov    $0x0,%edx
  80148e:	eb 0e                	jmp    80149e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801490:	39 08                	cmp    %ecx,(%eax)
  801492:	75 09                	jne    80149d <dev_lookup+0x21>
			*dev = devtab[i];
  801494:	89 03                	mov    %eax,(%ebx)
			return 0;
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
  80149b:	eb 33                	jmp    8014d0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80149d:	42                   	inc    %edx
  80149e:	8b 04 95 c0 30 80 00 	mov    0x8030c0(,%edx,4),%eax
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	75 e7                	jne    801490 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014a9:	a1 20 54 80 00       	mov    0x805420,%eax
  8014ae:	8b 40 48             	mov    0x48(%eax),%eax
  8014b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b9:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  8014c0:	e8 bf ee ff ff       	call   800384 <cprintf>
	*dev = 0;
  8014c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014d0:	83 c4 14             	add    $0x14,%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	56                   	push   %esi
  8014da:	53                   	push   %ebx
  8014db:	83 ec 30             	sub    $0x30,%esp
  8014de:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e1:	8a 45 0c             	mov    0xc(%ebp),%al
  8014e4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014e7:	89 34 24             	mov    %esi,(%esp)
  8014ea:	e8 b9 fe ff ff       	call   8013a8 <fd2num>
  8014ef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014f6:	89 04 24             	mov    %eax,(%esp)
  8014f9:	e8 28 ff ff ff       	call   801426 <fd_lookup>
  8014fe:	89 c3                	mov    %eax,%ebx
  801500:	85 c0                	test   %eax,%eax
  801502:	78 05                	js     801509 <fd_close+0x33>
	    || fd != fd2)
  801504:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801507:	74 0d                	je     801516 <fd_close+0x40>
		return (must_exist ? r : 0);
  801509:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80150d:	75 46                	jne    801555 <fd_close+0x7f>
  80150f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801514:	eb 3f                	jmp    801555 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801516:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151d:	8b 06                	mov    (%esi),%eax
  80151f:	89 04 24             	mov    %eax,(%esp)
  801522:	e8 55 ff ff ff       	call   80147c <dev_lookup>
  801527:	89 c3                	mov    %eax,%ebx
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 18                	js     801545 <fd_close+0x6f>
		if (dev->dev_close)
  80152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801530:	8b 40 10             	mov    0x10(%eax),%eax
  801533:	85 c0                	test   %eax,%eax
  801535:	74 09                	je     801540 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801537:	89 34 24             	mov    %esi,(%esp)
  80153a:	ff d0                	call   *%eax
  80153c:	89 c3                	mov    %eax,%ebx
  80153e:	eb 05                	jmp    801545 <fd_close+0x6f>
		else
			r = 0;
  801540:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801545:	89 74 24 04          	mov    %esi,0x4(%esp)
  801549:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801550:	e8 73 f8 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
}
  801555:	89 d8                	mov    %ebx,%eax
  801557:	83 c4 30             	add    $0x30,%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801564:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801567:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156b:	8b 45 08             	mov    0x8(%ebp),%eax
  80156e:	89 04 24             	mov    %eax,(%esp)
  801571:	e8 b0 fe ff ff       	call   801426 <fd_lookup>
  801576:	85 c0                	test   %eax,%eax
  801578:	78 13                	js     80158d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80157a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801581:	00 
  801582:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801585:	89 04 24             	mov    %eax,(%esp)
  801588:	e8 49 ff ff ff       	call   8014d6 <fd_close>
}
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    

0080158f <close_all>:

void
close_all(void)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801596:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80159b:	89 1c 24             	mov    %ebx,(%esp)
  80159e:	e8 bb ff ff ff       	call   80155e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015a3:	43                   	inc    %ebx
  8015a4:	83 fb 20             	cmp    $0x20,%ebx
  8015a7:	75 f2                	jne    80159b <close_all+0xc>
		close(i);
}
  8015a9:	83 c4 14             	add    $0x14,%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	57                   	push   %edi
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 4c             	sub    $0x4c,%esp
  8015b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015bb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	e8 59 fe ff ff       	call   801426 <fd_lookup>
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	0f 88 e3 00 00 00    	js     8016ba <dup+0x10b>
		return r;
	close(newfdnum);
  8015d7:	89 3c 24             	mov    %edi,(%esp)
  8015da:	e8 7f ff ff ff       	call   80155e <close>

	newfd = INDEX2FD(newfdnum);
  8015df:	89 fe                	mov    %edi,%esi
  8015e1:	c1 e6 0c             	shl    $0xc,%esi
  8015e4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015ed:	89 04 24             	mov    %eax,(%esp)
  8015f0:	e8 c3 fd ff ff       	call   8013b8 <fd2data>
  8015f5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015f7:	89 34 24             	mov    %esi,(%esp)
  8015fa:	e8 b9 fd ff ff       	call   8013b8 <fd2data>
  8015ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801602:	89 d8                	mov    %ebx,%eax
  801604:	c1 e8 16             	shr    $0x16,%eax
  801607:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80160e:	a8 01                	test   $0x1,%al
  801610:	74 46                	je     801658 <dup+0xa9>
  801612:	89 d8                	mov    %ebx,%eax
  801614:	c1 e8 0c             	shr    $0xc,%eax
  801617:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80161e:	f6 c2 01             	test   $0x1,%dl
  801621:	74 35                	je     801658 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801623:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80162a:	25 07 0e 00 00       	and    $0xe07,%eax
  80162f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801633:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801636:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80163a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801641:	00 
  801642:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801646:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164d:	e8 23 f7 ff ff       	call   800d75 <sys_page_map>
  801652:	89 c3                	mov    %eax,%ebx
  801654:	85 c0                	test   %eax,%eax
  801656:	78 3b                	js     801693 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	c1 ea 0c             	shr    $0xc,%edx
  801660:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801667:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80166d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801671:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801675:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80167c:	00 
  80167d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801681:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801688:	e8 e8 f6 ff ff       	call   800d75 <sys_page_map>
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	85 c0                	test   %eax,%eax
  801691:	79 25                	jns    8016b8 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801693:	89 74 24 04          	mov    %esi,0x4(%esp)
  801697:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169e:	e8 25 f7 ff ff       	call   800dc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b1:	e8 12 f7 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  8016b6:	eb 02                	jmp    8016ba <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016b8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016ba:	89 d8                	mov    %ebx,%eax
  8016bc:	83 c4 4c             	add    $0x4c,%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5f                   	pop    %edi
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 24             	sub    $0x24,%esp
  8016cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d5:	89 1c 24             	mov    %ebx,(%esp)
  8016d8:	e8 49 fd ff ff       	call   801426 <fd_lookup>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 6d                	js     80174e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016eb:	8b 00                	mov    (%eax),%eax
  8016ed:	89 04 24             	mov    %eax,(%esp)
  8016f0:	e8 87 fd ff ff       	call   80147c <dev_lookup>
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 55                	js     80174e <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fc:	8b 50 08             	mov    0x8(%eax),%edx
  8016ff:	83 e2 03             	and    $0x3,%edx
  801702:	83 fa 01             	cmp    $0x1,%edx
  801705:	75 23                	jne    80172a <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801707:	a1 20 54 80 00       	mov    0x805420,%eax
  80170c:	8b 40 48             	mov    0x48(%eax),%eax
  80170f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801713:	89 44 24 04          	mov    %eax,0x4(%esp)
  801717:	c7 04 24 84 30 80 00 	movl   $0x803084,(%esp)
  80171e:	e8 61 ec ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  801723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801728:	eb 24                	jmp    80174e <read+0x8a>
	}
	if (!dev->dev_read)
  80172a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172d:	8b 52 08             	mov    0x8(%edx),%edx
  801730:	85 d2                	test   %edx,%edx
  801732:	74 15                	je     801749 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801734:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801737:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80173b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801742:	89 04 24             	mov    %eax,(%esp)
  801745:	ff d2                	call   *%edx
  801747:	eb 05                	jmp    80174e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801749:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80174e:	83 c4 24             	add    $0x24,%esp
  801751:	5b                   	pop    %ebx
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	57                   	push   %edi
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
  80175a:	83 ec 1c             	sub    $0x1c,%esp
  80175d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801760:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801763:	bb 00 00 00 00       	mov    $0x0,%ebx
  801768:	eb 23                	jmp    80178d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80176a:	89 f0                	mov    %esi,%eax
  80176c:	29 d8                	sub    %ebx,%eax
  80176e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801772:	8b 45 0c             	mov    0xc(%ebp),%eax
  801775:	01 d8                	add    %ebx,%eax
  801777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177b:	89 3c 24             	mov    %edi,(%esp)
  80177e:	e8 41 ff ff ff       	call   8016c4 <read>
		if (m < 0)
  801783:	85 c0                	test   %eax,%eax
  801785:	78 10                	js     801797 <readn+0x43>
			return m;
		if (m == 0)
  801787:	85 c0                	test   %eax,%eax
  801789:	74 0a                	je     801795 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80178b:	01 c3                	add    %eax,%ebx
  80178d:	39 f3                	cmp    %esi,%ebx
  80178f:	72 d9                	jb     80176a <readn+0x16>
  801791:	89 d8                	mov    %ebx,%eax
  801793:	eb 02                	jmp    801797 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801795:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801797:	83 c4 1c             	add    $0x1c,%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5f                   	pop    %edi
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	53                   	push   %ebx
  8017a3:	83 ec 24             	sub    $0x24,%esp
  8017a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b0:	89 1c 24             	mov    %ebx,(%esp)
  8017b3:	e8 6e fc ff ff       	call   801426 <fd_lookup>
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 68                	js     801824 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c6:	8b 00                	mov    (%eax),%eax
  8017c8:	89 04 24             	mov    %eax,(%esp)
  8017cb:	e8 ac fc ff ff       	call   80147c <dev_lookup>
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 50                	js     801824 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017db:	75 23                	jne    801800 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017dd:	a1 20 54 80 00       	mov    0x805420,%eax
  8017e2:	8b 40 48             	mov    0x48(%eax),%eax
  8017e5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ed:	c7 04 24 a0 30 80 00 	movl   $0x8030a0,(%esp)
  8017f4:	e8 8b eb ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  8017f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017fe:	eb 24                	jmp    801824 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801800:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801803:	8b 52 0c             	mov    0xc(%edx),%edx
  801806:	85 d2                	test   %edx,%edx
  801808:	74 15                	je     80181f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80180a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80180d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801814:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801818:	89 04 24             	mov    %eax,(%esp)
  80181b:	ff d2                	call   *%edx
  80181d:	eb 05                	jmp    801824 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80181f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801824:	83 c4 24             	add    $0x24,%esp
  801827:	5b                   	pop    %ebx
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <seek>:

int
seek(int fdnum, off_t offset)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801830:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801833:	89 44 24 04          	mov    %eax,0x4(%esp)
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	89 04 24             	mov    %eax,(%esp)
  80183d:	e8 e4 fb ff ff       	call   801426 <fd_lookup>
  801842:	85 c0                	test   %eax,%eax
  801844:	78 0e                	js     801854 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801846:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80184c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80184f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	83 ec 24             	sub    $0x24,%esp
  80185d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801860:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801863:	89 44 24 04          	mov    %eax,0x4(%esp)
  801867:	89 1c 24             	mov    %ebx,(%esp)
  80186a:	e8 b7 fb ff ff       	call   801426 <fd_lookup>
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 61                	js     8018d4 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801873:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187d:	8b 00                	mov    (%eax),%eax
  80187f:	89 04 24             	mov    %eax,(%esp)
  801882:	e8 f5 fb ff ff       	call   80147c <dev_lookup>
  801887:	85 c0                	test   %eax,%eax
  801889:	78 49                	js     8018d4 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801892:	75 23                	jne    8018b7 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801894:	a1 20 54 80 00       	mov    0x805420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801899:	8b 40 48             	mov    0x48(%eax),%eax
  80189c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a4:	c7 04 24 60 30 80 00 	movl   $0x803060,(%esp)
  8018ab:	e8 d4 ea ff ff       	call   800384 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018b5:	eb 1d                	jmp    8018d4 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ba:	8b 52 18             	mov    0x18(%edx),%edx
  8018bd:	85 d2                	test   %edx,%edx
  8018bf:	74 0e                	je     8018cf <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018c8:	89 04 24             	mov    %eax,(%esp)
  8018cb:	ff d2                	call   *%edx
  8018cd:	eb 05                	jmp    8018d4 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018d4:	83 c4 24             	add    $0x24,%esp
  8018d7:	5b                   	pop    %ebx
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	53                   	push   %ebx
  8018de:	83 ec 24             	sub    $0x24,%esp
  8018e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	89 04 24             	mov    %eax,(%esp)
  8018f1:	e8 30 fb ff ff       	call   801426 <fd_lookup>
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 52                	js     80194c <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801901:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801904:	8b 00                	mov    (%eax),%eax
  801906:	89 04 24             	mov    %eax,(%esp)
  801909:	e8 6e fb ff ff       	call   80147c <dev_lookup>
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 3a                	js     80194c <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801912:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801915:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801919:	74 2c                	je     801947 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80191b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80191e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801925:	00 00 00 
	stat->st_isdir = 0;
  801928:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80192f:	00 00 00 
	stat->st_dev = dev;
  801932:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801938:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80193c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80193f:	89 14 24             	mov    %edx,(%esp)
  801942:	ff 50 14             	call   *0x14(%eax)
  801945:	eb 05                	jmp    80194c <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801947:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80194c:	83 c4 24             	add    $0x24,%esp
  80194f:	5b                   	pop    %ebx
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
  801957:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80195a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801961:	00 
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	89 04 24             	mov    %eax,(%esp)
  801968:	e8 2a 02 00 00       	call   801b97 <open>
  80196d:	89 c3                	mov    %eax,%ebx
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 1b                	js     80198e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801973:	8b 45 0c             	mov    0xc(%ebp),%eax
  801976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197a:	89 1c 24             	mov    %ebx,(%esp)
  80197d:	e8 58 ff ff ff       	call   8018da <fstat>
  801982:	89 c6                	mov    %eax,%esi
	close(fd);
  801984:	89 1c 24             	mov    %ebx,(%esp)
  801987:	e8 d2 fb ff ff       	call   80155e <close>
	return r;
  80198c:	89 f3                	mov    %esi,%ebx
}
  80198e:	89 d8                	mov    %ebx,%eax
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	5b                   	pop    %ebx
  801994:	5e                   	pop    %esi
  801995:	5d                   	pop    %ebp
  801996:	c3                   	ret    
	...

00801998 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	56                   	push   %esi
  80199c:	53                   	push   %ebx
  80199d:	83 ec 10             	sub    $0x10,%esp
  8019a0:	89 c3                	mov    %eax,%ebx
  8019a2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019a4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019ab:	75 11                	jne    8019be <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019b4:	e8 66 0e 00 00       	call   80281f <ipc_find_env>
  8019b9:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019be:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019c5:	00 
  8019c6:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8019cd:	00 
  8019ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019d2:	a1 00 50 80 00       	mov    0x805000,%eax
  8019d7:	89 04 24             	mov    %eax,(%esp)
  8019da:	e8 bd 0d 00 00       	call   80279c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019e6:	00 
  8019e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f2:	e8 35 0d 00 00       	call   80272c <ipc_recv>
}
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	5b                   	pop    %ebx
  8019fb:	5e                   	pop    %esi
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    

008019fe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a12:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a17:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1c:	b8 02 00 00 00       	mov    $0x2,%eax
  801a21:	e8 72 ff ff ff       	call   801998 <fsipc>
}
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    

00801a28 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a31:	8b 40 0c             	mov    0xc(%eax),%eax
  801a34:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a39:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3e:	b8 06 00 00 00       	mov    $0x6,%eax
  801a43:	e8 50 ff ff ff       	call   801998 <fsipc>
}
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 14             	sub    $0x14,%esp
  801a51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a64:	b8 05 00 00 00       	mov    $0x5,%eax
  801a69:	e8 2a ff ff ff       	call   801998 <fsipc>
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 2b                	js     801a9d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a72:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a79:	00 
  801a7a:	89 1c 24             	mov    %ebx,(%esp)
  801a7d:	e8 ad ee ff ff       	call   80092f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a82:	a1 80 60 80 00       	mov    0x806080,%eax
  801a87:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a8d:	a1 84 60 80 00       	mov    0x806084,%eax
  801a92:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a9d:	83 c4 14             	add    $0x14,%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	83 ec 18             	sub    $0x18,%esp
  801aa9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aac:	8b 55 08             	mov    0x8(%ebp),%edx
  801aaf:	8b 52 0c             	mov    0xc(%edx),%edx
  801ab2:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801ab8:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801abd:	89 c2                	mov    %eax,%edx
  801abf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ac4:	76 05                	jbe    801acb <devfile_write+0x28>
  801ac6:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801acb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801add:	e8 30 f0 ff ff       	call   800b12 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae7:	b8 04 00 00 00       	mov    $0x4,%eax
  801aec:	e8 a7 fe ff ff       	call   801998 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	56                   	push   %esi
  801af7:	53                   	push   %ebx
  801af8:	83 ec 10             	sub    $0x10,%esp
  801afb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	8b 40 0c             	mov    0xc(%eax),%eax
  801b04:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b09:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b14:	b8 03 00 00 00       	mov    $0x3,%eax
  801b19:	e8 7a fe ff ff       	call   801998 <fsipc>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 6a                	js     801b8e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b24:	39 c6                	cmp    %eax,%esi
  801b26:	73 24                	jae    801b4c <devfile_read+0x59>
  801b28:	c7 44 24 0c d4 30 80 	movl   $0x8030d4,0xc(%esp)
  801b2f:	00 
  801b30:	c7 44 24 08 db 30 80 	movl   $0x8030db,0x8(%esp)
  801b37:	00 
  801b38:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b3f:	00 
  801b40:	c7 04 24 f0 30 80 00 	movl   $0x8030f0,(%esp)
  801b47:	e8 40 e7 ff ff       	call   80028c <_panic>
	assert(r <= PGSIZE);
  801b4c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b51:	7e 24                	jle    801b77 <devfile_read+0x84>
  801b53:	c7 44 24 0c fb 30 80 	movl   $0x8030fb,0xc(%esp)
  801b5a:	00 
  801b5b:	c7 44 24 08 db 30 80 	movl   $0x8030db,0x8(%esp)
  801b62:	00 
  801b63:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b6a:	00 
  801b6b:	c7 04 24 f0 30 80 00 	movl   $0x8030f0,(%esp)
  801b72:	e8 15 e7 ff ff       	call   80028c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b7b:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b82:	00 
  801b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b86:	89 04 24             	mov    %eax,(%esp)
  801b89:	e8 1a ef ff ff       	call   800aa8 <memmove>
	return r;
}
  801b8e:	89 d8                	mov    %ebx,%eax
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 20             	sub    $0x20,%esp
  801b9f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ba2:	89 34 24             	mov    %esi,(%esp)
  801ba5:	e8 52 ed ff ff       	call   8008fc <strlen>
  801baa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801baf:	7f 60                	jg     801c11 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb4:	89 04 24             	mov    %eax,(%esp)
  801bb7:	e8 17 f8 ff ff       	call   8013d3 <fd_alloc>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 54                	js     801c16 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bc2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bc6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801bcd:	e8 5d ed ff ff       	call   80092f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd5:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bda:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bdd:	b8 01 00 00 00       	mov    $0x1,%eax
  801be2:	e8 b1 fd ff ff       	call   801998 <fsipc>
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	85 c0                	test   %eax,%eax
  801beb:	79 15                	jns    801c02 <open+0x6b>
		fd_close(fd, 0);
  801bed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bf4:	00 
  801bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf8:	89 04 24             	mov    %eax,(%esp)
  801bfb:	e8 d6 f8 ff ff       	call   8014d6 <fd_close>
		return r;
  801c00:	eb 14                	jmp    801c16 <open+0x7f>
	}

	return fd2num(fd);
  801c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c05:	89 04 24             	mov    %eax,(%esp)
  801c08:	e8 9b f7 ff ff       	call   8013a8 <fd2num>
  801c0d:	89 c3                	mov    %eax,%ebx
  801c0f:	eb 05                	jmp    801c16 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c11:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	83 c4 20             	add    $0x20,%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c25:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2a:	b8 08 00 00 00       	mov    $0x8,%eax
  801c2f:	e8 64 fd ff ff       	call   801998 <fsipc>
}
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    
	...

00801c38 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c3e:	c7 44 24 04 07 31 80 	movl   $0x803107,0x4(%esp)
  801c45:	00 
  801c46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c49:	89 04 24             	mov    %eax,(%esp)
  801c4c:	e8 de ec ff ff       	call   80092f <strcpy>
	return 0;
}
  801c51:	b8 00 00 00 00       	mov    $0x0,%eax
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	53                   	push   %ebx
  801c5c:	83 ec 14             	sub    $0x14,%esp
  801c5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c62:	89 1c 24             	mov    %ebx,(%esp)
  801c65:	e8 fa 0b 00 00       	call   802864 <pageref>
  801c6a:	83 f8 01             	cmp    $0x1,%eax
  801c6d:	75 0d                	jne    801c7c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801c6f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c72:	89 04 24             	mov    %eax,(%esp)
  801c75:	e8 1f 03 00 00       	call   801f99 <nsipc_close>
  801c7a:	eb 05                	jmp    801c81 <devsock_close+0x29>
	else
		return 0;
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c81:	83 c4 14             	add    $0x14,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c8d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c94:	00 
  801c95:	8b 45 10             	mov    0x10(%ebp),%eax
  801c98:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ca9:	89 04 24             	mov    %eax,(%esp)
  801cac:	e8 e3 03 00 00       	call   802094 <nsipc_send>
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cb9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cc0:	00 
  801cc1:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd5:	89 04 24             	mov    %eax,(%esp)
  801cd8:	e8 37 03 00 00       	call   802014 <nsipc_recv>
}
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    

00801cdf <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 20             	sub    $0x20,%esp
  801ce7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ce9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cec:	89 04 24             	mov    %eax,(%esp)
  801cef:	e8 df f6 ff ff       	call   8013d3 <fd_alloc>
  801cf4:	89 c3                	mov    %eax,%ebx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 21                	js     801d1b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cfa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d01:	00 
  801d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d10:	e8 0c f0 ff ff       	call   800d21 <sys_page_alloc>
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	85 c0                	test   %eax,%eax
  801d19:	79 0a                	jns    801d25 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801d1b:	89 34 24             	mov    %esi,(%esp)
  801d1e:	e8 76 02 00 00       	call   801f99 <nsipc_close>
		return r;
  801d23:	eb 22                	jmp    801d47 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d25:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d33:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d3a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d3d:	89 04 24             	mov    %eax,(%esp)
  801d40:	e8 63 f6 ff ff       	call   8013a8 <fd2num>
  801d45:	89 c3                	mov    %eax,%ebx
}
  801d47:	89 d8                	mov    %ebx,%eax
  801d49:	83 c4 20             	add    $0x20,%esp
  801d4c:	5b                   	pop    %ebx
  801d4d:	5e                   	pop    %esi
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d56:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d59:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d5d:	89 04 24             	mov    %eax,(%esp)
  801d60:	e8 c1 f6 ff ff       	call   801426 <fd_lookup>
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 17                	js     801d80 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6c:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d72:	39 10                	cmp    %edx,(%eax)
  801d74:	75 05                	jne    801d7b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d76:	8b 40 0c             	mov    0xc(%eax),%eax
  801d79:	eb 05                	jmp    801d80 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d7b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    

00801d82 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d88:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8b:	e8 c0 ff ff ff       	call   801d50 <fd2sockid>
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 1f                	js     801db3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d94:	8b 55 10             	mov    0x10(%ebp),%edx
  801d97:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801da2:	89 04 24             	mov    %eax,(%esp)
  801da5:	e8 38 01 00 00       	call   801ee2 <nsipc_accept>
  801daa:	85 c0                	test   %eax,%eax
  801dac:	78 05                	js     801db3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801dae:	e8 2c ff ff ff       	call   801cdf <alloc_sockfd>
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	e8 8d ff ff ff       	call   801d50 <fd2sockid>
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	78 16                	js     801ddd <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801dc7:	8b 55 10             	mov    0x10(%ebp),%edx
  801dca:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd5:	89 04 24             	mov    %eax,(%esp)
  801dd8:	e8 5b 01 00 00       	call   801f38 <nsipc_bind>
}
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    

00801ddf <shutdown>:

int
shutdown(int s, int how)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801de5:	8b 45 08             	mov    0x8(%ebp),%eax
  801de8:	e8 63 ff ff ff       	call   801d50 <fd2sockid>
  801ded:	85 c0                	test   %eax,%eax
  801def:	78 0f                	js     801e00 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801df1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df8:	89 04 24             	mov    %eax,(%esp)
  801dfb:	e8 77 01 00 00       	call   801f77 <nsipc_shutdown>
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e08:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0b:	e8 40 ff ff ff       	call   801d50 <fd2sockid>
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 16                	js     801e2a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801e14:	8b 55 10             	mov    0x10(%ebp),%edx
  801e17:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e22:	89 04 24             	mov    %eax,(%esp)
  801e25:	e8 89 01 00 00       	call   801fb3 <nsipc_connect>
}
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <listen>:

int
listen(int s, int backlog)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	e8 16 ff ff ff       	call   801d50 <fd2sockid>
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	78 0f                	js     801e4d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e45:	89 04 24             	mov    %eax,(%esp)
  801e48:	e8 a5 01 00 00       	call   801ff2 <nsipc_listen>
}
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e55:	8b 45 10             	mov    0x10(%ebp),%eax
  801e58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e63:	8b 45 08             	mov    0x8(%ebp),%eax
  801e66:	89 04 24             	mov    %eax,(%esp)
  801e69:	e8 99 02 00 00       	call   802107 <nsipc_socket>
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	78 05                	js     801e77 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801e72:	e8 68 fe ff ff       	call   801cdf <alloc_sockfd>
}
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    
  801e79:	00 00                	add    %al,(%eax)
	...

00801e7c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	53                   	push   %ebx
  801e80:	83 ec 14             	sub    $0x14,%esp
  801e83:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e85:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801e8c:	75 11                	jne    801e9f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e8e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801e95:	e8 85 09 00 00       	call   80281f <ipc_find_env>
  801e9a:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e9f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ea6:	00 
  801ea7:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801eae:	00 
  801eaf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb3:	a1 04 50 80 00       	mov    0x805004,%eax
  801eb8:	89 04 24             	mov    %eax,(%esp)
  801ebb:	e8 dc 08 00 00       	call   80279c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ec0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ec7:	00 
  801ec8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ecf:	00 
  801ed0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed7:	e8 50 08 00 00       	call   80272c <ipc_recv>
}
  801edc:	83 c4 14             	add    $0x14,%esp
  801edf:	5b                   	pop    %ebx
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	56                   	push   %esi
  801ee6:	53                   	push   %ebx
  801ee7:	83 ec 10             	sub    $0x10,%esp
  801eea:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801eed:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ef5:	8b 06                	mov    (%esi),%eax
  801ef7:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801efc:	b8 01 00 00 00       	mov    $0x1,%eax
  801f01:	e8 76 ff ff ff       	call   801e7c <nsipc>
  801f06:	89 c3                	mov    %eax,%ebx
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 23                	js     801f2f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f0c:	a1 10 70 80 00       	mov    0x807010,%eax
  801f11:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f15:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801f1c:	00 
  801f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f20:	89 04 24             	mov    %eax,(%esp)
  801f23:	e8 80 eb ff ff       	call   800aa8 <memmove>
		*addrlen = ret->ret_addrlen;
  801f28:	a1 10 70 80 00       	mov    0x807010,%eax
  801f2d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f2f:	89 d8                	mov    %ebx,%eax
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5e                   	pop    %esi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	53                   	push   %ebx
  801f3c:	83 ec 14             	sub    $0x14,%esp
  801f3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f42:	8b 45 08             	mov    0x8(%ebp),%eax
  801f45:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f4a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f55:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801f5c:	e8 47 eb ff ff       	call   800aa8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f61:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f67:	b8 02 00 00 00       	mov    $0x2,%eax
  801f6c:	e8 0b ff ff ff       	call   801e7c <nsipc>
}
  801f71:	83 c4 14             	add    $0x14,%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f80:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f88:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f8d:	b8 03 00 00 00       	mov    $0x3,%eax
  801f92:	e8 e5 fe ff ff       	call   801e7c <nsipc>
}
  801f97:	c9                   	leave  
  801f98:	c3                   	ret    

00801f99 <nsipc_close>:

int
nsipc_close(int s)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801fa7:	b8 04 00 00 00       	mov    $0x4,%eax
  801fac:	e8 cb fe ff ff       	call   801e7c <nsipc>
}
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    

00801fb3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	53                   	push   %ebx
  801fb7:	83 ec 14             	sub    $0x14,%esp
  801fba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fc5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd0:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801fd7:	e8 cc ea ff ff       	call   800aa8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fdc:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801fe2:	b8 05 00 00 00       	mov    $0x5,%eax
  801fe7:	e8 90 fe ff ff       	call   801e7c <nsipc>
}
  801fec:	83 c4 14             	add    $0x14,%esp
  801fef:	5b                   	pop    %ebx
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    

00801ff2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ff8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802000:	8b 45 0c             	mov    0xc(%ebp),%eax
  802003:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802008:	b8 06 00 00 00       	mov    $0x6,%eax
  80200d:	e8 6a fe ff ff       	call   801e7c <nsipc>
}
  802012:	c9                   	leave  
  802013:	c3                   	ret    

00802014 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	56                   	push   %esi
  802018:	53                   	push   %ebx
  802019:	83 ec 10             	sub    $0x10,%esp
  80201c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80201f:	8b 45 08             	mov    0x8(%ebp),%eax
  802022:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802027:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80202d:	8b 45 14             	mov    0x14(%ebp),%eax
  802030:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802035:	b8 07 00 00 00       	mov    $0x7,%eax
  80203a:	e8 3d fe ff ff       	call   801e7c <nsipc>
  80203f:	89 c3                	mov    %eax,%ebx
  802041:	85 c0                	test   %eax,%eax
  802043:	78 46                	js     80208b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802045:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80204a:	7f 04                	jg     802050 <nsipc_recv+0x3c>
  80204c:	39 c6                	cmp    %eax,%esi
  80204e:	7d 24                	jge    802074 <nsipc_recv+0x60>
  802050:	c7 44 24 0c 13 31 80 	movl   $0x803113,0xc(%esp)
  802057:	00 
  802058:	c7 44 24 08 db 30 80 	movl   $0x8030db,0x8(%esp)
  80205f:	00 
  802060:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802067:	00 
  802068:	c7 04 24 28 31 80 00 	movl   $0x803128,(%esp)
  80206f:	e8 18 e2 ff ff       	call   80028c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802074:	89 44 24 08          	mov    %eax,0x8(%esp)
  802078:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80207f:	00 
  802080:	8b 45 0c             	mov    0xc(%ebp),%eax
  802083:	89 04 24             	mov    %eax,(%esp)
  802086:	e8 1d ea ff ff       	call   800aa8 <memmove>
	}

	return r;
}
  80208b:	89 d8                	mov    %ebx,%eax
  80208d:	83 c4 10             	add    $0x10,%esp
  802090:	5b                   	pop    %ebx
  802091:	5e                   	pop    %esi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    

00802094 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	53                   	push   %ebx
  802098:	83 ec 14             	sub    $0x14,%esp
  80209b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80209e:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a1:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8020a6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020ac:	7e 24                	jle    8020d2 <nsipc_send+0x3e>
  8020ae:	c7 44 24 0c 34 31 80 	movl   $0x803134,0xc(%esp)
  8020b5:	00 
  8020b6:	c7 44 24 08 db 30 80 	movl   $0x8030db,0x8(%esp)
  8020bd:	00 
  8020be:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8020c5:	00 
  8020c6:	c7 04 24 28 31 80 00 	movl   $0x803128,(%esp)
  8020cd:	e8 ba e1 ff ff       	call   80028c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020dd:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8020e4:	e8 bf e9 ff ff       	call   800aa8 <memmove>
	nsipcbuf.send.req_size = size;
  8020e9:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8020ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8020f2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8020f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8020fc:	e8 7b fd ff ff       	call   801e7c <nsipc>
}
  802101:	83 c4 14             	add    $0x14,%esp
  802104:	5b                   	pop    %ebx
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    

00802107 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802107:	55                   	push   %ebp
  802108:	89 e5                	mov    %esp,%ebp
  80210a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80210d:	8b 45 08             	mov    0x8(%ebp),%eax
  802110:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802115:	8b 45 0c             	mov    0xc(%ebp),%eax
  802118:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80211d:	8b 45 10             	mov    0x10(%ebp),%eax
  802120:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802125:	b8 09 00 00 00       	mov    $0x9,%eax
  80212a:	e8 4d fd ff ff       	call   801e7c <nsipc>
}
  80212f:	c9                   	leave  
  802130:	c3                   	ret    
  802131:	00 00                	add    %al,(%eax)
	...

00802134 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	56                   	push   %esi
  802138:	53                   	push   %ebx
  802139:	83 ec 10             	sub    $0x10,%esp
  80213c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80213f:	8b 45 08             	mov    0x8(%ebp),%eax
  802142:	89 04 24             	mov    %eax,(%esp)
  802145:	e8 6e f2 ff ff       	call   8013b8 <fd2data>
  80214a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80214c:	c7 44 24 04 40 31 80 	movl   $0x803140,0x4(%esp)
  802153:	00 
  802154:	89 34 24             	mov    %esi,(%esp)
  802157:	e8 d3 e7 ff ff       	call   80092f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80215c:	8b 43 04             	mov    0x4(%ebx),%eax
  80215f:	2b 03                	sub    (%ebx),%eax
  802161:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802167:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80216e:	00 00 00 
	stat->st_dev = &devpipe;
  802171:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802178:	40 80 00 
	return 0;
}
  80217b:	b8 00 00 00 00       	mov    $0x0,%eax
  802180:	83 c4 10             	add    $0x10,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    

00802187 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802187:	55                   	push   %ebp
  802188:	89 e5                	mov    %esp,%ebp
  80218a:	53                   	push   %ebx
  80218b:	83 ec 14             	sub    $0x14,%esp
  80218e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802191:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802195:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80219c:	e8 27 ec ff ff       	call   800dc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021a1:	89 1c 24             	mov    %ebx,(%esp)
  8021a4:	e8 0f f2 ff ff       	call   8013b8 <fd2data>
  8021a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b4:	e8 0f ec ff ff       	call   800dc8 <sys_page_unmap>
}
  8021b9:	83 c4 14             	add    $0x14,%esp
  8021bc:	5b                   	pop    %ebx
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    

008021bf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
  8021c2:	57                   	push   %edi
  8021c3:	56                   	push   %esi
  8021c4:	53                   	push   %ebx
  8021c5:	83 ec 2c             	sub    $0x2c,%esp
  8021c8:	89 c7                	mov    %eax,%edi
  8021ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021cd:	a1 20 54 80 00       	mov    0x805420,%eax
  8021d2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021d5:	89 3c 24             	mov    %edi,(%esp)
  8021d8:	e8 87 06 00 00       	call   802864 <pageref>
  8021dd:	89 c6                	mov    %eax,%esi
  8021df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021e2:	89 04 24             	mov    %eax,(%esp)
  8021e5:	e8 7a 06 00 00       	call   802864 <pageref>
  8021ea:	39 c6                	cmp    %eax,%esi
  8021ec:	0f 94 c0             	sete   %al
  8021ef:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021f2:	8b 15 20 54 80 00    	mov    0x805420,%edx
  8021f8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021fb:	39 cb                	cmp    %ecx,%ebx
  8021fd:	75 08                	jne    802207 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8021ff:	83 c4 2c             	add    $0x2c,%esp
  802202:	5b                   	pop    %ebx
  802203:	5e                   	pop    %esi
  802204:	5f                   	pop    %edi
  802205:	5d                   	pop    %ebp
  802206:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802207:	83 f8 01             	cmp    $0x1,%eax
  80220a:	75 c1                	jne    8021cd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80220c:	8b 42 58             	mov    0x58(%edx),%eax
  80220f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802216:	00 
  802217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80221b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80221f:	c7 04 24 47 31 80 00 	movl   $0x803147,(%esp)
  802226:	e8 59 e1 ff ff       	call   800384 <cprintf>
  80222b:	eb a0                	jmp    8021cd <_pipeisclosed+0xe>

0080222d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80222d:	55                   	push   %ebp
  80222e:	89 e5                	mov    %esp,%ebp
  802230:	57                   	push   %edi
  802231:	56                   	push   %esi
  802232:	53                   	push   %ebx
  802233:	83 ec 1c             	sub    $0x1c,%esp
  802236:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802239:	89 34 24             	mov    %esi,(%esp)
  80223c:	e8 77 f1 ff ff       	call   8013b8 <fd2data>
  802241:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802243:	bf 00 00 00 00       	mov    $0x0,%edi
  802248:	eb 3c                	jmp    802286 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80224a:	89 da                	mov    %ebx,%edx
  80224c:	89 f0                	mov    %esi,%eax
  80224e:	e8 6c ff ff ff       	call   8021bf <_pipeisclosed>
  802253:	85 c0                	test   %eax,%eax
  802255:	75 38                	jne    80228f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802257:	e8 a6 ea ff ff       	call   800d02 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80225c:	8b 43 04             	mov    0x4(%ebx),%eax
  80225f:	8b 13                	mov    (%ebx),%edx
  802261:	83 c2 20             	add    $0x20,%edx
  802264:	39 d0                	cmp    %edx,%eax
  802266:	73 e2                	jae    80224a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802268:	8b 55 0c             	mov    0xc(%ebp),%edx
  80226b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80226e:	89 c2                	mov    %eax,%edx
  802270:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802276:	79 05                	jns    80227d <devpipe_write+0x50>
  802278:	4a                   	dec    %edx
  802279:	83 ca e0             	or     $0xffffffe0,%edx
  80227c:	42                   	inc    %edx
  80227d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802281:	40                   	inc    %eax
  802282:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802285:	47                   	inc    %edi
  802286:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802289:	75 d1                	jne    80225c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80228b:	89 f8                	mov    %edi,%eax
  80228d:	eb 05                	jmp    802294 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80228f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802294:	83 c4 1c             	add    $0x1c,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    

0080229c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	57                   	push   %edi
  8022a0:	56                   	push   %esi
  8022a1:	53                   	push   %ebx
  8022a2:	83 ec 1c             	sub    $0x1c,%esp
  8022a5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022a8:	89 3c 24             	mov    %edi,(%esp)
  8022ab:	e8 08 f1 ff ff       	call   8013b8 <fd2data>
  8022b0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022b2:	be 00 00 00 00       	mov    $0x0,%esi
  8022b7:	eb 3a                	jmp    8022f3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022b9:	85 f6                	test   %esi,%esi
  8022bb:	74 04                	je     8022c1 <devpipe_read+0x25>
				return i;
  8022bd:	89 f0                	mov    %esi,%eax
  8022bf:	eb 40                	jmp    802301 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022c1:	89 da                	mov    %ebx,%edx
  8022c3:	89 f8                	mov    %edi,%eax
  8022c5:	e8 f5 fe ff ff       	call   8021bf <_pipeisclosed>
  8022ca:	85 c0                	test   %eax,%eax
  8022cc:	75 2e                	jne    8022fc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022ce:	e8 2f ea ff ff       	call   800d02 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022d3:	8b 03                	mov    (%ebx),%eax
  8022d5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022d8:	74 df                	je     8022b9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022da:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8022df:	79 05                	jns    8022e6 <devpipe_read+0x4a>
  8022e1:	48                   	dec    %eax
  8022e2:	83 c8 e0             	or     $0xffffffe0,%eax
  8022e5:	40                   	inc    %eax
  8022e6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022ed:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022f0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022f2:	46                   	inc    %esi
  8022f3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022f6:	75 db                	jne    8022d3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022f8:	89 f0                	mov    %esi,%eax
  8022fa:	eb 05                	jmp    802301 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022fc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    

00802309 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802309:	55                   	push   %ebp
  80230a:	89 e5                	mov    %esp,%ebp
  80230c:	57                   	push   %edi
  80230d:	56                   	push   %esi
  80230e:	53                   	push   %ebx
  80230f:	83 ec 3c             	sub    $0x3c,%esp
  802312:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802315:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802318:	89 04 24             	mov    %eax,(%esp)
  80231b:	e8 b3 f0 ff ff       	call   8013d3 <fd_alloc>
  802320:	89 c3                	mov    %eax,%ebx
  802322:	85 c0                	test   %eax,%eax
  802324:	0f 88 45 01 00 00    	js     80246f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80232a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802331:	00 
  802332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802335:	89 44 24 04          	mov    %eax,0x4(%esp)
  802339:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802340:	e8 dc e9 ff ff       	call   800d21 <sys_page_alloc>
  802345:	89 c3                	mov    %eax,%ebx
  802347:	85 c0                	test   %eax,%eax
  802349:	0f 88 20 01 00 00    	js     80246f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80234f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802352:	89 04 24             	mov    %eax,(%esp)
  802355:	e8 79 f0 ff ff       	call   8013d3 <fd_alloc>
  80235a:	89 c3                	mov    %eax,%ebx
  80235c:	85 c0                	test   %eax,%eax
  80235e:	0f 88 f8 00 00 00    	js     80245c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802364:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80236b:	00 
  80236c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80236f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802373:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80237a:	e8 a2 e9 ff ff       	call   800d21 <sys_page_alloc>
  80237f:	89 c3                	mov    %eax,%ebx
  802381:	85 c0                	test   %eax,%eax
  802383:	0f 88 d3 00 00 00    	js     80245c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802389:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80238c:	89 04 24             	mov    %eax,(%esp)
  80238f:	e8 24 f0 ff ff       	call   8013b8 <fd2data>
  802394:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802396:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80239d:	00 
  80239e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a9:	e8 73 e9 ff ff       	call   800d21 <sys_page_alloc>
  8023ae:	89 c3                	mov    %eax,%ebx
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	0f 88 91 00 00 00    	js     802449 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023bb:	89 04 24             	mov    %eax,(%esp)
  8023be:	e8 f5 ef ff ff       	call   8013b8 <fd2data>
  8023c3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8023ca:	00 
  8023cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023d6:	00 
  8023d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023e2:	e8 8e e9 ff ff       	call   800d75 <sys_page_map>
  8023e7:	89 c3                	mov    %eax,%ebx
  8023e9:	85 c0                	test   %eax,%eax
  8023eb:	78 4c                	js     802439 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023ed:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8023f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023f6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023fb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802402:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802408:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80240b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80240d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802410:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80241a:	89 04 24             	mov    %eax,(%esp)
  80241d:	e8 86 ef ff ff       	call   8013a8 <fd2num>
  802422:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802424:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802427:	89 04 24             	mov    %eax,(%esp)
  80242a:	e8 79 ef ff ff       	call   8013a8 <fd2num>
  80242f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802432:	bb 00 00 00 00       	mov    $0x0,%ebx
  802437:	eb 36                	jmp    80246f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802439:	89 74 24 04          	mov    %esi,0x4(%esp)
  80243d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802444:	e8 7f e9 ff ff       	call   800dc8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802449:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80244c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802450:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802457:	e8 6c e9 ff ff       	call   800dc8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80245c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80245f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802463:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80246a:	e8 59 e9 ff ff       	call   800dc8 <sys_page_unmap>
    err:
	return r;
}
  80246f:	89 d8                	mov    %ebx,%eax
  802471:	83 c4 3c             	add    $0x3c,%esp
  802474:	5b                   	pop    %ebx
  802475:	5e                   	pop    %esi
  802476:	5f                   	pop    %edi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    

00802479 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802479:	55                   	push   %ebp
  80247a:	89 e5                	mov    %esp,%ebp
  80247c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80247f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802482:	89 44 24 04          	mov    %eax,0x4(%esp)
  802486:	8b 45 08             	mov    0x8(%ebp),%eax
  802489:	89 04 24             	mov    %eax,(%esp)
  80248c:	e8 95 ef ff ff       	call   801426 <fd_lookup>
  802491:	85 c0                	test   %eax,%eax
  802493:	78 15                	js     8024aa <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802498:	89 04 24             	mov    %eax,(%esp)
  80249b:	e8 18 ef ff ff       	call   8013b8 <fd2data>
	return _pipeisclosed(fd, p);
  8024a0:	89 c2                	mov    %eax,%edx
  8024a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a5:	e8 15 fd ff ff       	call   8021bf <_pipeisclosed>
}
  8024aa:	c9                   	leave  
  8024ab:	c3                   	ret    

008024ac <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8024ac:	55                   	push   %ebp
  8024ad:	89 e5                	mov    %esp,%ebp
  8024af:	56                   	push   %esi
  8024b0:	53                   	push   %ebx
  8024b1:	83 ec 10             	sub    $0x10,%esp
  8024b4:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8024b7:	85 f6                	test   %esi,%esi
  8024b9:	75 24                	jne    8024df <wait+0x33>
  8024bb:	c7 44 24 0c 5f 31 80 	movl   $0x80315f,0xc(%esp)
  8024c2:	00 
  8024c3:	c7 44 24 08 db 30 80 	movl   $0x8030db,0x8(%esp)
  8024ca:	00 
  8024cb:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8024d2:	00 
  8024d3:	c7 04 24 6a 31 80 00 	movl   $0x80316a,(%esp)
  8024da:	e8 ad dd ff ff       	call   80028c <_panic>
	e = &envs[ENVX(envid)];
  8024df:	89 f3                	mov    %esi,%ebx
  8024e1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8024e7:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  8024ee:	c1 e3 07             	shl    $0x7,%ebx
  8024f1:	29 c3                	sub    %eax,%ebx
  8024f3:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024f9:	eb 05                	jmp    802500 <wait+0x54>
		sys_yield();
  8024fb:	e8 02 e8 ff ff       	call   800d02 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802500:	8b 43 48             	mov    0x48(%ebx),%eax
  802503:	39 f0                	cmp    %esi,%eax
  802505:	75 07                	jne    80250e <wait+0x62>
  802507:	8b 43 54             	mov    0x54(%ebx),%eax
  80250a:	85 c0                	test   %eax,%eax
  80250c:	75 ed                	jne    8024fb <wait+0x4f>
		sys_yield();
}
  80250e:	83 c4 10             	add    $0x10,%esp
  802511:	5b                   	pop    %ebx
  802512:	5e                   	pop    %esi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    
  802515:	00 00                	add    %al,(%eax)
	...

00802518 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802518:	55                   	push   %ebp
  802519:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80251b:	b8 00 00 00 00       	mov    $0x0,%eax
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    

00802522 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802522:	55                   	push   %ebp
  802523:	89 e5                	mov    %esp,%ebp
  802525:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802528:	c7 44 24 04 75 31 80 	movl   $0x803175,0x4(%esp)
  80252f:	00 
  802530:	8b 45 0c             	mov    0xc(%ebp),%eax
  802533:	89 04 24             	mov    %eax,(%esp)
  802536:	e8 f4 e3 ff ff       	call   80092f <strcpy>
	return 0;
}
  80253b:	b8 00 00 00 00       	mov    $0x0,%eax
  802540:	c9                   	leave  
  802541:	c3                   	ret    

00802542 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802542:	55                   	push   %ebp
  802543:	89 e5                	mov    %esp,%ebp
  802545:	57                   	push   %edi
  802546:	56                   	push   %esi
  802547:	53                   	push   %ebx
  802548:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80254e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802553:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802559:	eb 30                	jmp    80258b <devcons_write+0x49>
		m = n - tot;
  80255b:	8b 75 10             	mov    0x10(%ebp),%esi
  80255e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802560:	83 fe 7f             	cmp    $0x7f,%esi
  802563:	76 05                	jbe    80256a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802565:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80256a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80256e:	03 45 0c             	add    0xc(%ebp),%eax
  802571:	89 44 24 04          	mov    %eax,0x4(%esp)
  802575:	89 3c 24             	mov    %edi,(%esp)
  802578:	e8 2b e5 ff ff       	call   800aa8 <memmove>
		sys_cputs(buf, m);
  80257d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802581:	89 3c 24             	mov    %edi,(%esp)
  802584:	e8 cb e6 ff ff       	call   800c54 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802589:	01 f3                	add    %esi,%ebx
  80258b:	89 d8                	mov    %ebx,%eax
  80258d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802590:	72 c9                	jb     80255b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802592:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802598:	5b                   	pop    %ebx
  802599:	5e                   	pop    %esi
  80259a:	5f                   	pop    %edi
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    

0080259d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80259d:	55                   	push   %ebp
  80259e:	89 e5                	mov    %esp,%ebp
  8025a0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8025a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025a7:	75 07                	jne    8025b0 <devcons_read+0x13>
  8025a9:	eb 25                	jmp    8025d0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025ab:	e8 52 e7 ff ff       	call   800d02 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025b0:	e8 bd e6 ff ff       	call   800c72 <sys_cgetc>
  8025b5:	85 c0                	test   %eax,%eax
  8025b7:	74 f2                	je     8025ab <devcons_read+0xe>
  8025b9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8025bb:	85 c0                	test   %eax,%eax
  8025bd:	78 1d                	js     8025dc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025bf:	83 f8 04             	cmp    $0x4,%eax
  8025c2:	74 13                	je     8025d7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8025c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c7:	88 10                	mov    %dl,(%eax)
	return 1;
  8025c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ce:	eb 0c                	jmp    8025dc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8025d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8025d5:	eb 05                	jmp    8025dc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8025d7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8025dc:	c9                   	leave  
  8025dd:	c3                   	ret    

008025de <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8025de:	55                   	push   %ebp
  8025df:	89 e5                	mov    %esp,%ebp
  8025e1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8025e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8025f1:	00 
  8025f2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025f5:	89 04 24             	mov    %eax,(%esp)
  8025f8:	e8 57 e6 ff ff       	call   800c54 <sys_cputs>
}
  8025fd:	c9                   	leave  
  8025fe:	c3                   	ret    

008025ff <getchar>:

int
getchar(void)
{
  8025ff:	55                   	push   %ebp
  802600:	89 e5                	mov    %esp,%ebp
  802602:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802605:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80260c:	00 
  80260d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802610:	89 44 24 04          	mov    %eax,0x4(%esp)
  802614:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80261b:	e8 a4 f0 ff ff       	call   8016c4 <read>
	if (r < 0)
  802620:	85 c0                	test   %eax,%eax
  802622:	78 0f                	js     802633 <getchar+0x34>
		return r;
	if (r < 1)
  802624:	85 c0                	test   %eax,%eax
  802626:	7e 06                	jle    80262e <getchar+0x2f>
		return -E_EOF;
	return c;
  802628:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80262c:	eb 05                	jmp    802633 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80262e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802633:	c9                   	leave  
  802634:	c3                   	ret    

00802635 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802635:	55                   	push   %ebp
  802636:	89 e5                	mov    %esp,%ebp
  802638:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80263b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80263e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802642:	8b 45 08             	mov    0x8(%ebp),%eax
  802645:	89 04 24             	mov    %eax,(%esp)
  802648:	e8 d9 ed ff ff       	call   801426 <fd_lookup>
  80264d:	85 c0                	test   %eax,%eax
  80264f:	78 11                	js     802662 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802651:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802654:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80265a:	39 10                	cmp    %edx,(%eax)
  80265c:	0f 94 c0             	sete   %al
  80265f:	0f b6 c0             	movzbl %al,%eax
}
  802662:	c9                   	leave  
  802663:	c3                   	ret    

00802664 <opencons>:

int
opencons(void)
{
  802664:	55                   	push   %ebp
  802665:	89 e5                	mov    %esp,%ebp
  802667:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80266a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80266d:	89 04 24             	mov    %eax,(%esp)
  802670:	e8 5e ed ff ff       	call   8013d3 <fd_alloc>
  802675:	85 c0                	test   %eax,%eax
  802677:	78 3c                	js     8026b5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802679:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802680:	00 
  802681:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802684:	89 44 24 04          	mov    %eax,0x4(%esp)
  802688:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80268f:	e8 8d e6 ff ff       	call   800d21 <sys_page_alloc>
  802694:	85 c0                	test   %eax,%eax
  802696:	78 1d                	js     8026b5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802698:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80269e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026ad:	89 04 24             	mov    %eax,(%esp)
  8026b0:	e8 f3 ec ff ff       	call   8013a8 <fd2num>
}
  8026b5:	c9                   	leave  
  8026b6:	c3                   	ret    
	...

008026b8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026b8:	55                   	push   %ebp
  8026b9:	89 e5                	mov    %esp,%ebp
  8026bb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026be:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8026c5:	75 30                	jne    8026f7 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8026c7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8026ce:	00 
  8026cf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8026d6:	ee 
  8026d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026de:	e8 3e e6 ff ff       	call   800d21 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8026e3:	c7 44 24 04 04 27 80 	movl   $0x802704,0x4(%esp)
  8026ea:	00 
  8026eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026f2:	e8 ca e7 ff ff       	call   800ec1 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026fa:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8026ff:	c9                   	leave  
  802700:	c3                   	ret    
  802701:	00 00                	add    %al,(%eax)
	...

00802704 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802704:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802705:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80270a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80270c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  80270f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802713:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802717:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  80271a:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  80271c:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802720:	83 c4 08             	add    $0x8,%esp
	popal
  802723:	61                   	popa   

	addl $4,%esp 
  802724:	83 c4 04             	add    $0x4,%esp
	popfl
  802727:	9d                   	popf   

	popl %esp
  802728:	5c                   	pop    %esp

	ret
  802729:	c3                   	ret    
	...

0080272c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80272c:	55                   	push   %ebp
  80272d:	89 e5                	mov    %esp,%ebp
  80272f:	56                   	push   %esi
  802730:	53                   	push   %ebx
  802731:	83 ec 10             	sub    $0x10,%esp
  802734:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802737:	8b 45 0c             	mov    0xc(%ebp),%eax
  80273a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  80273d:	85 c0                	test   %eax,%eax
  80273f:	74 0a                	je     80274b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802741:	89 04 24             	mov    %eax,(%esp)
  802744:	e8 ee e7 ff ff       	call   800f37 <sys_ipc_recv>
  802749:	eb 0c                	jmp    802757 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80274b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802752:	e8 e0 e7 ff ff       	call   800f37 <sys_ipc_recv>
	}
	if (r < 0)
  802757:	85 c0                	test   %eax,%eax
  802759:	79 16                	jns    802771 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80275b:	85 db                	test   %ebx,%ebx
  80275d:	74 06                	je     802765 <ipc_recv+0x39>
  80275f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802765:	85 f6                	test   %esi,%esi
  802767:	74 2c                	je     802795 <ipc_recv+0x69>
  802769:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80276f:	eb 24                	jmp    802795 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802771:	85 db                	test   %ebx,%ebx
  802773:	74 0a                	je     80277f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802775:	a1 20 54 80 00       	mov    0x805420,%eax
  80277a:	8b 40 74             	mov    0x74(%eax),%eax
  80277d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80277f:	85 f6                	test   %esi,%esi
  802781:	74 0a                	je     80278d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802783:	a1 20 54 80 00       	mov    0x805420,%eax
  802788:	8b 40 78             	mov    0x78(%eax),%eax
  80278b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80278d:	a1 20 54 80 00       	mov    0x805420,%eax
  802792:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802795:	83 c4 10             	add    $0x10,%esp
  802798:	5b                   	pop    %ebx
  802799:	5e                   	pop    %esi
  80279a:	5d                   	pop    %ebp
  80279b:	c3                   	ret    

0080279c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80279c:	55                   	push   %ebp
  80279d:	89 e5                	mov    %esp,%ebp
  80279f:	57                   	push   %edi
  8027a0:	56                   	push   %esi
  8027a1:	53                   	push   %ebx
  8027a2:	83 ec 1c             	sub    $0x1c,%esp
  8027a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8027a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8027ae:	85 db                	test   %ebx,%ebx
  8027b0:	74 19                	je     8027cb <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8027b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8027b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8027c1:	89 34 24             	mov    %esi,(%esp)
  8027c4:	e8 4b e7 ff ff       	call   800f14 <sys_ipc_try_send>
  8027c9:	eb 1c                	jmp    8027e7 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8027cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8027d2:	00 
  8027d3:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8027da:	ee 
  8027db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8027df:	89 34 24             	mov    %esi,(%esp)
  8027e2:	e8 2d e7 ff ff       	call   800f14 <sys_ipc_try_send>
		}
		if (r == 0)
  8027e7:	85 c0                	test   %eax,%eax
  8027e9:	74 2c                	je     802817 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8027eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8027ee:	74 20                	je     802810 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8027f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027f4:	c7 44 24 08 81 31 80 	movl   $0x803181,0x8(%esp)
  8027fb:	00 
  8027fc:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802803:	00 
  802804:	c7 04 24 94 31 80 00 	movl   $0x803194,(%esp)
  80280b:	e8 7c da ff ff       	call   80028c <_panic>
		}
		sys_yield();
  802810:	e8 ed e4 ff ff       	call   800d02 <sys_yield>
	}
  802815:	eb 97                	jmp    8027ae <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802817:	83 c4 1c             	add    $0x1c,%esp
  80281a:	5b                   	pop    %ebx
  80281b:	5e                   	pop    %esi
  80281c:	5f                   	pop    %edi
  80281d:	5d                   	pop    %ebp
  80281e:	c3                   	ret    

0080281f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80281f:	55                   	push   %ebp
  802820:	89 e5                	mov    %esp,%ebp
  802822:	53                   	push   %ebx
  802823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802826:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80282b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802832:	89 c2                	mov    %eax,%edx
  802834:	c1 e2 07             	shl    $0x7,%edx
  802837:	29 ca                	sub    %ecx,%edx
  802839:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80283f:	8b 52 50             	mov    0x50(%edx),%edx
  802842:	39 da                	cmp    %ebx,%edx
  802844:	75 0f                	jne    802855 <ipc_find_env+0x36>
			return envs[i].env_id;
  802846:	c1 e0 07             	shl    $0x7,%eax
  802849:	29 c8                	sub    %ecx,%eax
  80284b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802850:	8b 40 40             	mov    0x40(%eax),%eax
  802853:	eb 0c                	jmp    802861 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802855:	40                   	inc    %eax
  802856:	3d 00 04 00 00       	cmp    $0x400,%eax
  80285b:	75 ce                	jne    80282b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80285d:	66 b8 00 00          	mov    $0x0,%ax
}
  802861:	5b                   	pop    %ebx
  802862:	5d                   	pop    %ebp
  802863:	c3                   	ret    

00802864 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802864:	55                   	push   %ebp
  802865:	89 e5                	mov    %esp,%ebp
  802867:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80286a:	89 c2                	mov    %eax,%edx
  80286c:	c1 ea 16             	shr    $0x16,%edx
  80286f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802876:	f6 c2 01             	test   $0x1,%dl
  802879:	74 1e                	je     802899 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80287b:	c1 e8 0c             	shr    $0xc,%eax
  80287e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802885:	a8 01                	test   $0x1,%al
  802887:	74 17                	je     8028a0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802889:	c1 e8 0c             	shr    $0xc,%eax
  80288c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802893:	ef 
  802894:	0f b7 c0             	movzwl %ax,%eax
  802897:	eb 0c                	jmp    8028a5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802899:	b8 00 00 00 00       	mov    $0x0,%eax
  80289e:	eb 05                	jmp    8028a5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8028a0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8028a5:	5d                   	pop    %ebp
  8028a6:	c3                   	ret    
	...

008028a8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8028a8:	55                   	push   %ebp
  8028a9:	57                   	push   %edi
  8028aa:	56                   	push   %esi
  8028ab:	83 ec 10             	sub    $0x10,%esp
  8028ae:	8b 74 24 20          	mov    0x20(%esp),%esi
  8028b2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8028b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028ba:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8028be:	89 cd                	mov    %ecx,%ebp
  8028c0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8028c4:	85 c0                	test   %eax,%eax
  8028c6:	75 2c                	jne    8028f4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8028c8:	39 f9                	cmp    %edi,%ecx
  8028ca:	77 68                	ja     802934 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8028cc:	85 c9                	test   %ecx,%ecx
  8028ce:	75 0b                	jne    8028db <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8028d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8028d5:	31 d2                	xor    %edx,%edx
  8028d7:	f7 f1                	div    %ecx
  8028d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8028db:	31 d2                	xor    %edx,%edx
  8028dd:	89 f8                	mov    %edi,%eax
  8028df:	f7 f1                	div    %ecx
  8028e1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028e3:	89 f0                	mov    %esi,%eax
  8028e5:	f7 f1                	div    %ecx
  8028e7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028e9:	89 f0                	mov    %esi,%eax
  8028eb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028ed:	83 c4 10             	add    $0x10,%esp
  8028f0:	5e                   	pop    %esi
  8028f1:	5f                   	pop    %edi
  8028f2:	5d                   	pop    %ebp
  8028f3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8028f4:	39 f8                	cmp    %edi,%eax
  8028f6:	77 2c                	ja     802924 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8028f8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8028fb:	83 f6 1f             	xor    $0x1f,%esi
  8028fe:	75 4c                	jne    80294c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802900:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802902:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802907:	72 0a                	jb     802913 <__udivdi3+0x6b>
  802909:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80290d:	0f 87 ad 00 00 00    	ja     8029c0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802913:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802918:	89 f0                	mov    %esi,%eax
  80291a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80291c:	83 c4 10             	add    $0x10,%esp
  80291f:	5e                   	pop    %esi
  802920:	5f                   	pop    %edi
  802921:	5d                   	pop    %ebp
  802922:	c3                   	ret    
  802923:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802924:	31 ff                	xor    %edi,%edi
  802926:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802928:	89 f0                	mov    %esi,%eax
  80292a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80292c:	83 c4 10             	add    $0x10,%esp
  80292f:	5e                   	pop    %esi
  802930:	5f                   	pop    %edi
  802931:	5d                   	pop    %ebp
  802932:	c3                   	ret    
  802933:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802934:	89 fa                	mov    %edi,%edx
  802936:	89 f0                	mov    %esi,%eax
  802938:	f7 f1                	div    %ecx
  80293a:	89 c6                	mov    %eax,%esi
  80293c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80293e:	89 f0                	mov    %esi,%eax
  802940:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802942:	83 c4 10             	add    $0x10,%esp
  802945:	5e                   	pop    %esi
  802946:	5f                   	pop    %edi
  802947:	5d                   	pop    %ebp
  802948:	c3                   	ret    
  802949:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80294c:	89 f1                	mov    %esi,%ecx
  80294e:	d3 e0                	shl    %cl,%eax
  802950:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802954:	b8 20 00 00 00       	mov    $0x20,%eax
  802959:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80295b:	89 ea                	mov    %ebp,%edx
  80295d:	88 c1                	mov    %al,%cl
  80295f:	d3 ea                	shr    %cl,%edx
  802961:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802965:	09 ca                	or     %ecx,%edx
  802967:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80296b:	89 f1                	mov    %esi,%ecx
  80296d:	d3 e5                	shl    %cl,%ebp
  80296f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802973:	89 fd                	mov    %edi,%ebp
  802975:	88 c1                	mov    %al,%cl
  802977:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802979:	89 fa                	mov    %edi,%edx
  80297b:	89 f1                	mov    %esi,%ecx
  80297d:	d3 e2                	shl    %cl,%edx
  80297f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802983:	88 c1                	mov    %al,%cl
  802985:	d3 ef                	shr    %cl,%edi
  802987:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802989:	89 f8                	mov    %edi,%eax
  80298b:	89 ea                	mov    %ebp,%edx
  80298d:	f7 74 24 08          	divl   0x8(%esp)
  802991:	89 d1                	mov    %edx,%ecx
  802993:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802995:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802999:	39 d1                	cmp    %edx,%ecx
  80299b:	72 17                	jb     8029b4 <__udivdi3+0x10c>
  80299d:	74 09                	je     8029a8 <__udivdi3+0x100>
  80299f:	89 fe                	mov    %edi,%esi
  8029a1:	31 ff                	xor    %edi,%edi
  8029a3:	e9 41 ff ff ff       	jmp    8028e9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8029a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029ac:	89 f1                	mov    %esi,%ecx
  8029ae:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029b0:	39 c2                	cmp    %eax,%edx
  8029b2:	73 eb                	jae    80299f <__udivdi3+0xf7>
		{
		  q0--;
  8029b4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8029b7:	31 ff                	xor    %edi,%edi
  8029b9:	e9 2b ff ff ff       	jmp    8028e9 <__udivdi3+0x41>
  8029be:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029c0:	31 f6                	xor    %esi,%esi
  8029c2:	e9 22 ff ff ff       	jmp    8028e9 <__udivdi3+0x41>
	...

008029c8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8029c8:	55                   	push   %ebp
  8029c9:	57                   	push   %edi
  8029ca:	56                   	push   %esi
  8029cb:	83 ec 20             	sub    $0x20,%esp
  8029ce:	8b 44 24 30          	mov    0x30(%esp),%eax
  8029d2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8029d6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8029da:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8029de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8029e2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8029e6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8029e8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8029ea:	85 ed                	test   %ebp,%ebp
  8029ec:	75 16                	jne    802a04 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8029ee:	39 f1                	cmp    %esi,%ecx
  8029f0:	0f 86 a6 00 00 00    	jbe    802a9c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029f6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8029f8:	89 d0                	mov    %edx,%eax
  8029fa:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029fc:	83 c4 20             	add    $0x20,%esp
  8029ff:	5e                   	pop    %esi
  802a00:	5f                   	pop    %edi
  802a01:	5d                   	pop    %ebp
  802a02:	c3                   	ret    
  802a03:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a04:	39 f5                	cmp    %esi,%ebp
  802a06:	0f 87 ac 00 00 00    	ja     802ab8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a0c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802a0f:	83 f0 1f             	xor    $0x1f,%eax
  802a12:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a16:	0f 84 a8 00 00 00    	je     802ac4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a1c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a20:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a22:	bf 20 00 00 00       	mov    $0x20,%edi
  802a27:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802a2b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a2f:	89 f9                	mov    %edi,%ecx
  802a31:	d3 e8                	shr    %cl,%eax
  802a33:	09 e8                	or     %ebp,%eax
  802a35:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802a39:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a3d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a41:	d3 e0                	shl    %cl,%eax
  802a43:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a47:	89 f2                	mov    %esi,%edx
  802a49:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802a4b:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a4f:	d3 e0                	shl    %cl,%eax
  802a51:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a55:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a59:	89 f9                	mov    %edi,%ecx
  802a5b:	d3 e8                	shr    %cl,%eax
  802a5d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802a5f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a61:	89 f2                	mov    %esi,%edx
  802a63:	f7 74 24 18          	divl   0x18(%esp)
  802a67:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802a69:	f7 64 24 0c          	mull   0xc(%esp)
  802a6d:	89 c5                	mov    %eax,%ebp
  802a6f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a71:	39 d6                	cmp    %edx,%esi
  802a73:	72 67                	jb     802adc <__umoddi3+0x114>
  802a75:	74 75                	je     802aec <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802a77:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802a7b:	29 e8                	sub    %ebp,%eax
  802a7d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802a7f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a83:	d3 e8                	shr    %cl,%eax
  802a85:	89 f2                	mov    %esi,%edx
  802a87:	89 f9                	mov    %edi,%ecx
  802a89:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802a8b:	09 d0                	or     %edx,%eax
  802a8d:	89 f2                	mov    %esi,%edx
  802a8f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a93:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a95:	83 c4 20             	add    $0x20,%esp
  802a98:	5e                   	pop    %esi
  802a99:	5f                   	pop    %edi
  802a9a:	5d                   	pop    %ebp
  802a9b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802a9c:	85 c9                	test   %ecx,%ecx
  802a9e:	75 0b                	jne    802aab <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802aa0:	b8 01 00 00 00       	mov    $0x1,%eax
  802aa5:	31 d2                	xor    %edx,%edx
  802aa7:	f7 f1                	div    %ecx
  802aa9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802aab:	89 f0                	mov    %esi,%eax
  802aad:	31 d2                	xor    %edx,%edx
  802aaf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802ab1:	89 f8                	mov    %edi,%eax
  802ab3:	e9 3e ff ff ff       	jmp    8029f6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802ab8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802aba:	83 c4 20             	add    $0x20,%esp
  802abd:	5e                   	pop    %esi
  802abe:	5f                   	pop    %edi
  802abf:	5d                   	pop    %ebp
  802ac0:	c3                   	ret    
  802ac1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802ac4:	39 f5                	cmp    %esi,%ebp
  802ac6:	72 04                	jb     802acc <__umoddi3+0x104>
  802ac8:	39 f9                	cmp    %edi,%ecx
  802aca:	77 06                	ja     802ad2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802acc:	89 f2                	mov    %esi,%edx
  802ace:	29 cf                	sub    %ecx,%edi
  802ad0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802ad2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ad4:	83 c4 20             	add    $0x20,%esp
  802ad7:	5e                   	pop    %esi
  802ad8:	5f                   	pop    %edi
  802ad9:	5d                   	pop    %ebp
  802ada:	c3                   	ret    
  802adb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802adc:	89 d1                	mov    %edx,%ecx
  802ade:	89 c5                	mov    %eax,%ebp
  802ae0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802ae4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802ae8:	eb 8d                	jmp    802a77 <__umoddi3+0xaf>
  802aea:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802aec:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802af0:	72 ea                	jb     802adc <__umoddi3+0x114>
  802af2:	89 f1                	mov    %esi,%ecx
  802af4:	eb 81                	jmp    802a77 <__umoddi3+0xaf>
