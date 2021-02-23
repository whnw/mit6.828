
obj/user/primes.debug:     file format elf32-i386


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

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 7c 12 00 00       	call   8012d4 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 08 40 80 00       	mov    0x804008,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 c0 29 80 00 	movl   $0x8029c0,(%esp)
  800071:	e8 3a 02 00 00       	call   8002b0 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 74 0f 00 00       	call   800fef <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 85 2d 80 	movl   $0x802d85,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 cc 29 80 00 	movl   $0x8029cc,(%esp)
  80009c:	e8 17 01 00 00       	call   8001b8 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 14 12 00 00       	call   8012d4 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	99                   	cltd   
  8000c3:	f7 fb                	idiv   %ebx
  8000c5:	85 d2                	test   %edx,%edx
  8000c7:	74 df                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d8:	00 
  8000d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dd:	89 3c 24             	mov    %edi,(%esp)
  8000e0:	e8 5f 12 00 00       	call   801344 <ipc_send>
  8000e5:	eb c1                	jmp    8000a8 <primeproc+0x74>

008000e7 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ef:	e8 fb 0e 00 00       	call   800fef <fork>
  8000f4:	89 c6                	mov    %eax,%esi
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	79 20                	jns    80011a <umain+0x33>
		panic("fork: %e", id);
  8000fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fe:	c7 44 24 08 85 2d 80 	movl   $0x802d85,0x8(%esp)
  800105:	00 
  800106:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010d:	00 
  80010e:	c7 04 24 cc 29 80 00 	movl   $0x8029cc,(%esp)
  800115:	e8 9e 00 00 00       	call   8001b8 <_panic>
	if (id == 0)
  80011a:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011f:	85 c0                	test   %eax,%eax
  800121:	75 05                	jne    800128 <umain+0x41>
		primeproc();
  800123:	e8 0c ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800128:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012f:	00 
  800130:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800137:	00 
  800138:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013c:	89 34 24             	mov    %esi,(%esp)
  80013f:	e8 00 12 00 00       	call   801344 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800144:	43                   	inc    %ebx
  800145:	eb e1                	jmp    800128 <umain+0x41>
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
  800156:	e8 b4 0a 00 00       	call   800c0f <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 08 40 80 00       	mov    %eax,0x804008


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
  800188:	e8 5a ff ff ff       	call   8000e7 <umain>

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
  8001a2:	e8 4c 14 00 00       	call   8015f3 <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 0a 0a 00 00       	call   800bbd <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001c9:	e8 41 0a 00 00       	call   800c0f <sys_getenvid>
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e4:	c7 04 24 e4 29 80 00 	movl   $0x8029e4,(%esp)
  8001eb:	e8 c0 00 00 00       	call   8002b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	e8 50 00 00 00       	call   80024f <vcprintf>
	cprintf("\n");
  8001ff:	c7 04 24 18 2f 80 00 	movl   $0x802f18,(%esp)
  800206:	e8 a5 00 00 00       	call   8002b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020b:	cc                   	int3   
  80020c:	eb fd                	jmp    80020b <_panic+0x53>
	...

00800210 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	53                   	push   %ebx
  800214:	83 ec 14             	sub    $0x14,%esp
  800217:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80021a:	8b 03                	mov    (%ebx),%eax
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800223:	40                   	inc    %eax
  800224:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800226:	3d ff 00 00 00       	cmp    $0xff,%eax
  80022b:	75 19                	jne    800246 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80022d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800234:	00 
  800235:	8d 43 08             	lea    0x8(%ebx),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 40 09 00 00       	call   800b80 <sys_cputs>
		b->idx = 0;
  800240:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800246:	ff 43 04             	incl   0x4(%ebx)
}
  800249:	83 c4 14             	add    $0x14,%esp
  80024c:	5b                   	pop    %ebx
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800258:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025f:	00 00 00 
	b.cnt = 0;
  800262:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800269:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800280:	89 44 24 04          	mov    %eax,0x4(%esp)
  800284:	c7 04 24 10 02 80 00 	movl   $0x800210,(%esp)
  80028b:	e8 82 01 00 00       	call   800412 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800290:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 d8 08 00 00       	call   800b80 <sys_cputs>

	return b.cnt;
}
  8002a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	e8 87 ff ff ff       	call   80024f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    
	...

008002cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 3c             	sub    $0x3c,%esp
  8002d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d8:	89 d7                	mov    %edx,%edi
  8002da:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	75 08                	jne    8002f8 <printnum+0x2c>
  8002f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f6:	77 57                	ja     80034f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002fc:	4b                   	dec    %ebx
  8002fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800301:	8b 45 10             	mov    0x10(%ebp),%eax
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80030c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800310:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800317:	00 
  800318:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	e8 3e 24 00 00       	call   802768 <__udivdi3>
  80032a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	89 54 24 04          	mov    %edx,0x4(%esp)
  800339:	89 fa                	mov    %edi,%edx
  80033b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033e:	e8 89 ff ff ff       	call   8002cc <printnum>
  800343:	eb 0f                	jmp    800354 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800345:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800349:	89 34 24             	mov    %esi,(%esp)
  80034c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034f:	4b                   	dec    %ebx
  800350:	85 db                	test   %ebx,%ebx
  800352:	7f f1                	jg     800345 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800363:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036a:	00 
  80036b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036e:	89 04 24             	mov    %eax,(%esp)
  800371:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800374:	89 44 24 04          	mov    %eax,0x4(%esp)
  800378:	e8 0b 25 00 00       	call   802888 <__umoddi3>
  80037d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800381:	0f be 80 07 2a 80 00 	movsbl 0x802a07(%eax),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80038e:	83 c4 3c             	add    $0x3c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800399:	83 fa 01             	cmp    $0x1,%edx
  80039c:	7e 0e                	jle    8003ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	8b 52 04             	mov    0x4(%edx),%edx
  8003aa:	eb 22                	jmp    8003ce <getuint+0x38>
	else if (lflag)
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 10                	je     8003c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b5:	89 08                	mov    %ecx,(%eax)
  8003b7:	8b 02                	mov    (%edx),%eax
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003be:	eb 0e                	jmp    8003ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	3b 50 04             	cmp    0x4(%eax),%edx
  8003de:	73 08                	jae    8003e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	88 0a                	mov    %cl,(%edx)
  8003e5:	42                   	inc    %edx
  8003e6:	89 10                	mov    %edx,(%eax)
}
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800401:	89 44 24 04          	mov    %eax,0x4(%esp)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 02 00 00 00       	call   800412 <vprintfmt>
	va_end(ap);
}
  800410:	c9                   	leave  
  800411:	c3                   	ret    

00800412 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	57                   	push   %edi
  800416:	56                   	push   %esi
  800417:	53                   	push   %ebx
  800418:	83 ec 4c             	sub    $0x4c,%esp
  80041b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041e:	8b 75 10             	mov    0x10(%ebp),%esi
  800421:	eb 12                	jmp    800435 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800423:	85 c0                	test   %eax,%eax
  800425:	0f 84 6b 03 00 00    	je     800796 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80042b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042f:	89 04 24             	mov    %eax,(%esp)
  800432:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800435:	0f b6 06             	movzbl (%esi),%eax
  800438:	46                   	inc    %esi
  800439:	83 f8 25             	cmp    $0x25,%eax
  80043c:	75 e5                	jne    800423 <vprintfmt+0x11>
  80043e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800442:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800449:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80044e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800455:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045a:	eb 26                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80045f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800463:	eb 1d                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800468:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80046c:	eb 14                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800471:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800478:	eb 08                	jmp    800482 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80047a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80047d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	0f b6 06             	movzbl (%esi),%eax
  800485:	8d 56 01             	lea    0x1(%esi),%edx
  800488:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048b:	8a 16                	mov    (%esi),%dl
  80048d:	83 ea 23             	sub    $0x23,%edx
  800490:	80 fa 55             	cmp    $0x55,%dl
  800493:	0f 87 e1 02 00 00    	ja     80077a <vprintfmt+0x368>
  800499:	0f b6 d2             	movzbl %dl,%edx
  80049c:	ff 24 95 40 2b 80 00 	jmp    *0x802b40(,%edx,4)
  8004a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004b8:	83 fa 09             	cmp    $0x9,%edx
  8004bb:	77 2a                	ja     8004e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004be:	eb eb                	jmp    8004ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ce:	eb 17                	jmp    8004e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d4:	78 98                	js     80046e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004d9:	eb a7                	jmp    800482 <vprintfmt+0x70>
  8004db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004e5:	eb 9b                	jmp    800482 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004eb:	79 95                	jns    800482 <vprintfmt+0x70>
  8004ed:	eb 8b                	jmp    80047a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f3:	eb 8d                	jmp    800482 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8d 50 04             	lea    0x4(%eax),%edx
  8004fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050d:	e9 23 ff ff ff       	jmp    800435 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	85 c0                	test   %eax,%eax
  80051f:	79 02                	jns    800523 <vprintfmt+0x111>
  800521:	f7 d8                	neg    %eax
  800523:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800525:	83 f8 10             	cmp    $0x10,%eax
  800528:	7f 0b                	jg     800535 <vprintfmt+0x123>
  80052a:	8b 04 85 a0 2c 80 00 	mov    0x802ca0(,%eax,4),%eax
  800531:	85 c0                	test   %eax,%eax
  800533:	75 23                	jne    800558 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800535:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800539:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800540:	00 
  800541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800545:	8b 45 08             	mov    0x8(%ebp),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	e8 9a fe ff ff       	call   8003ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800553:	e9 dd fe ff ff       	jmp    800435 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800558:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055c:	c7 44 24 08 ad 2e 80 	movl   $0x802ead,0x8(%esp)
  800563:	00 
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	8b 55 08             	mov    0x8(%ebp),%edx
  80056b:	89 14 24             	mov    %edx,(%esp)
  80056e:	e8 77 fe ff ff       	call   8003ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800576:	e9 ba fe ff ff       	jmp    800435 <vprintfmt+0x23>
  80057b:	89 f9                	mov    %edi,%ecx
  80057d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800580:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 30                	mov    (%eax),%esi
  80058e:	85 f6                	test   %esi,%esi
  800590:	75 05                	jne    800597 <vprintfmt+0x185>
				p = "(null)";
  800592:	be 18 2a 80 00       	mov    $0x802a18,%esi
			if (width > 0 && padc != '-')
  800597:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059b:	0f 8e 84 00 00 00    	jle    800625 <vprintfmt+0x213>
  8005a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005a5:	74 7e                	je     800625 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ab:	89 34 24             	mov    %esi,(%esp)
  8005ae:	e8 8b 02 00 00       	call   80083e <strnlen>
  8005b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005b6:	29 c2                	sub    %eax,%edx
  8005b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005c5:	89 de                	mov    %ebx,%esi
  8005c7:	89 d3                	mov    %edx,%ebx
  8005c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cb:	eb 0b                	jmp    8005d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d1:	89 3c 24             	mov    %edi,(%esp)
  8005d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	4b                   	dec    %ebx
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7f f1                	jg     8005cd <vprintfmt+0x1bb>
  8005dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005df:	89 f3                	mov    %esi,%ebx
  8005e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	79 05                	jns    8005f0 <vprintfmt+0x1de>
  8005eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f3:	29 c2                	sub    %eax,%edx
  8005f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f8:	eb 2b                	jmp    800625 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fe:	74 18                	je     800618 <vprintfmt+0x206>
  800600:	8d 50 e0             	lea    -0x20(%eax),%edx
  800603:	83 fa 5e             	cmp    $0x5e,%edx
  800606:	76 10                	jbe    800618 <vprintfmt+0x206>
					putch('?', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
  800616:	eb 0a                	jmp    800622 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800622:	ff 4d e4             	decl   -0x1c(%ebp)
  800625:	0f be 06             	movsbl (%esi),%eax
  800628:	46                   	inc    %esi
  800629:	85 c0                	test   %eax,%eax
  80062b:	74 21                	je     80064e <vprintfmt+0x23c>
  80062d:	85 ff                	test   %edi,%edi
  80062f:	78 c9                	js     8005fa <vprintfmt+0x1e8>
  800631:	4f                   	dec    %edi
  800632:	79 c6                	jns    8005fa <vprintfmt+0x1e8>
  800634:	8b 7d 08             	mov    0x8(%ebp),%edi
  800637:	89 de                	mov    %ebx,%esi
  800639:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80063c:	eb 18                	jmp    800656 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80063e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800642:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800649:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064b:	4b                   	dec    %ebx
  80064c:	eb 08                	jmp    800656 <vprintfmt+0x244>
  80064e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800651:	89 de                	mov    %ebx,%esi
  800653:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800656:	85 db                	test   %ebx,%ebx
  800658:	7f e4                	jg     80063e <vprintfmt+0x22c>
  80065a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80065d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800662:	e9 ce fd ff ff       	jmp    800435 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800667:	83 f9 01             	cmp    $0x1,%ecx
  80066a:	7e 10                	jle    80067c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 08             	lea    0x8(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 30                	mov    (%eax),%esi
  800677:	8b 78 04             	mov    0x4(%eax),%edi
  80067a:	eb 26                	jmp    8006a2 <vprintfmt+0x290>
	else if (lflag)
  80067c:	85 c9                	test   %ecx,%ecx
  80067e:	74 12                	je     800692 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 30                	mov    (%eax),%esi
  80068b:	89 f7                	mov    %esi,%edi
  80068d:	c1 ff 1f             	sar    $0x1f,%edi
  800690:	eb 10                	jmp    8006a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 30                	mov    (%eax),%esi
  80069d:	89 f7                	mov    %esi,%edi
  80069f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	78 0a                	js     8006b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ab:	e9 8c 00 00 00       	jmp    80073c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006be:	f7 de                	neg    %esi
  8006c0:	83 d7 00             	adc    $0x0,%edi
  8006c3:	f7 df                	neg    %edi
			}
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	eb 70                	jmp    80073c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cc:	89 ca                	mov    %ecx,%edx
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d1:	e8 c0 fc ff ff       	call   800396 <getuint>
  8006d6:	89 c6                	mov    %eax,%esi
  8006d8:	89 d7                	mov    %edx,%edi
			base = 10;
  8006da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006df:	eb 5b                	jmp    80073c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 ab fc ff ff       	call   800396 <getuint>
  8006eb:	89 c6                	mov    %eax,%esi
  8006ed:	89 d7                	mov    %edx,%edi
			base = 8;
  8006ef:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006f4:	eb 46                	jmp    80073c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800701:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 04             	lea    0x4(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071b:	8b 30                	mov    (%eax),%esi
  80071d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800727:	eb 13                	jmp    80073c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800729:	89 ca                	mov    %ecx,%edx
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 63 fc ff ff       	call   800396 <getuint>
  800733:	89 c6                	mov    %eax,%esi
  800735:	89 d7                	mov    %edx,%edi
			base = 16;
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800740:	89 54 24 10          	mov    %edx,0x10(%esp)
  800744:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800747:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074f:	89 34 24             	mov    %esi,(%esp)
  800752:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800756:	89 da                	mov    %ebx,%edx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	e8 6c fb ff ff       	call   8002cc <printnum>
			break;
  800760:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800763:	e9 cd fc ff ff       	jmp    800435 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800775:	e9 bb fc ff ff       	jmp    800435 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800785:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800788:	eb 01                	jmp    80078b <vprintfmt+0x379>
  80078a:	4e                   	dec    %esi
  80078b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80078f:	75 f9                	jne    80078a <vprintfmt+0x378>
  800791:	e9 9f fc ff ff       	jmp    800435 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800796:	83 c4 4c             	add    $0x4c,%esp
  800799:	5b                   	pop    %ebx
  80079a:	5e                   	pop    %esi
  80079b:	5f                   	pop    %edi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 28             	sub    $0x28,%esp
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	74 30                	je     8007ef <vsnprintf+0x51>
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	7e 33                	jle    8007f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	c7 04 24 d0 03 80 00 	movl   $0x8003d0,(%esp)
  8007df:	e8 2e fc ff ff       	call   800412 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ed:	eb 0c                	jmp    8007fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f4:	eb 05                	jmp    8007fb <vsnprintf+0x5d>
  8007f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800803:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800806:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080a:	8b 45 10             	mov    0x10(%ebp),%eax
  80080d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	e8 7b ff ff ff       	call   80079e <vsnprintf>
	va_end(ap);

	return rc;
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    
  800825:	00 00                	add    %al,(%eax)
	...

00800828 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
  800833:	eb 01                	jmp    800836 <strlen+0xe>
		n++;
  800835:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80083a:	75 f9                	jne    800835 <strlen+0xd>
		n++;
	return n;
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
  80084c:	eb 01                	jmp    80084f <strnlen+0x11>
		n++;
  80084e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084f:	39 d0                	cmp    %edx,%eax
  800851:	74 06                	je     800859 <strnlen+0x1b>
  800853:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800857:	75 f5                	jne    80084e <strnlen+0x10>
		n++;
	return n;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800865:	ba 00 00 00 00       	mov    $0x0,%edx
  80086a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80086d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800870:	42                   	inc    %edx
  800871:	84 c9                	test   %cl,%cl
  800873:	75 f5                	jne    80086a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800875:	5b                   	pop    %ebx
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800882:	89 1c 24             	mov    %ebx,(%esp)
  800885:	e8 9e ff ff ff       	call   800828 <strlen>
	strcpy(dst + len, src);
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800891:	01 d8                	add    %ebx,%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 c0 ff ff ff       	call   80085b <strcpy>
	return dst;
}
  80089b:	89 d8                	mov    %ebx,%eax
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	5b                   	pop    %ebx
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b6:	eb 0c                	jmp    8008c4 <strncpy+0x21>
		*dst++ = *src;
  8008b8:	8a 1a                	mov    (%edx),%bl
  8008ba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c3:	41                   	inc    %ecx
  8008c4:	39 f1                	cmp    %esi,%ecx
  8008c6:	75 f0                	jne    8008b8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	56                   	push   %esi
  8008d0:	53                   	push   %ebx
  8008d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008da:	85 d2                	test   %edx,%edx
  8008dc:	75 0a                	jne    8008e8 <strlcpy+0x1c>
  8008de:	89 f0                	mov    %esi,%eax
  8008e0:	eb 1a                	jmp    8008fc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e2:	88 18                	mov    %bl,(%eax)
  8008e4:	40                   	inc    %eax
  8008e5:	41                   	inc    %ecx
  8008e6:	eb 02                	jmp    8008ea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008ea:	4a                   	dec    %edx
  8008eb:	74 0a                	je     8008f7 <strlcpy+0x2b>
  8008ed:	8a 19                	mov    (%ecx),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	75 ef                	jne    8008e2 <strlcpy+0x16>
  8008f3:	89 c2                	mov    %eax,%edx
  8008f5:	eb 02                	jmp    8008f9 <strlcpy+0x2d>
  8008f7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008f9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008fc:	29 f0                	sub    %esi,%eax
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090b:	eb 02                	jmp    80090f <strcmp+0xd>
		p++, q++;
  80090d:	41                   	inc    %ecx
  80090e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090f:	8a 01                	mov    (%ecx),%al
  800911:	84 c0                	test   %al,%al
  800913:	74 04                	je     800919 <strcmp+0x17>
  800915:	3a 02                	cmp    (%edx),%al
  800917:	74 f4                	je     80090d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800919:	0f b6 c0             	movzbl %al,%eax
  80091c:	0f b6 12             	movzbl (%edx),%edx
  80091f:	29 d0                	sub    %edx,%eax
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800930:	eb 03                	jmp    800935 <strncmp+0x12>
		n--, p++, q++;
  800932:	4a                   	dec    %edx
  800933:	40                   	inc    %eax
  800934:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800935:	85 d2                	test   %edx,%edx
  800937:	74 14                	je     80094d <strncmp+0x2a>
  800939:	8a 18                	mov    (%eax),%bl
  80093b:	84 db                	test   %bl,%bl
  80093d:	74 04                	je     800943 <strncmp+0x20>
  80093f:	3a 19                	cmp    (%ecx),%bl
  800941:	74 ef                	je     800932 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800943:	0f b6 00             	movzbl (%eax),%eax
  800946:	0f b6 11             	movzbl (%ecx),%edx
  800949:	29 d0                	sub    %edx,%eax
  80094b:	eb 05                	jmp    800952 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80094d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800952:	5b                   	pop    %ebx
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80095e:	eb 05                	jmp    800965 <strchr+0x10>
		if (*s == c)
  800960:	38 ca                	cmp    %cl,%dl
  800962:	74 0c                	je     800970 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800964:	40                   	inc    %eax
  800965:	8a 10                	mov    (%eax),%dl
  800967:	84 d2                	test   %dl,%dl
  800969:	75 f5                	jne    800960 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097b:	eb 05                	jmp    800982 <strfind+0x10>
		if (*s == c)
  80097d:	38 ca                	cmp    %cl,%dl
  80097f:	74 07                	je     800988 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800981:	40                   	inc    %eax
  800982:	8a 10                	mov    (%eax),%dl
  800984:	84 d2                	test   %dl,%dl
  800986:	75 f5                	jne    80097d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	57                   	push   %edi
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 7d 08             	mov    0x8(%ebp),%edi
  800993:	8b 45 0c             	mov    0xc(%ebp),%eax
  800996:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800999:	85 c9                	test   %ecx,%ecx
  80099b:	74 30                	je     8009cd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a3:	75 25                	jne    8009ca <memset+0x40>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 20                	jne    8009ca <memset+0x40>
		c &= 0xFF;
  8009aa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ad:	89 d3                	mov    %edx,%ebx
  8009af:	c1 e3 08             	shl    $0x8,%ebx
  8009b2:	89 d6                	mov    %edx,%esi
  8009b4:	c1 e6 18             	shl    $0x18,%esi
  8009b7:	89 d0                	mov    %edx,%eax
  8009b9:	c1 e0 10             	shl    $0x10,%eax
  8009bc:	09 f0                	or     %esi,%eax
  8009be:	09 d0                	or     %edx,%eax
  8009c0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c5:	fc                   	cld    
  8009c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c8:	eb 03                	jmp    8009cd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ca:	fc                   	cld    
  8009cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cd:	89 f8                	mov    %edi,%eax
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e2:	39 c6                	cmp    %eax,%esi
  8009e4:	73 34                	jae    800a1a <memmove+0x46>
  8009e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 2d                	jae    800a1a <memmove+0x46>
		s += n;
		d += n;
  8009ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f0:	f6 c2 03             	test   $0x3,%dl
  8009f3:	75 1b                	jne    800a10 <memmove+0x3c>
  8009f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fb:	75 13                	jne    800a10 <memmove+0x3c>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 0e                	jne    800a10 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a02:	83 ef 04             	sub    $0x4,%edi
  800a05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a08:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0b:	fd                   	std    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 07                	jmp    800a17 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a10:	4f                   	dec    %edi
  800a11:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a14:	fd                   	std    
  800a15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a17:	fc                   	cld    
  800a18:	eb 20                	jmp    800a3a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a20:	75 13                	jne    800a35 <memmove+0x61>
  800a22:	a8 03                	test   $0x3,%al
  800a24:	75 0f                	jne    800a35 <memmove+0x61>
  800a26:	f6 c1 03             	test   $0x3,%cl
  800a29:	75 0a                	jne    800a35 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a2e:	89 c7                	mov    %eax,%edi
  800a30:	fc                   	cld    
  800a31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a33:	eb 05                	jmp    800a3a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a35:	89 c7                	mov    %eax,%edi
  800a37:	fc                   	cld    
  800a38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a44:	8b 45 10             	mov    0x10(%ebp),%eax
  800a47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	89 04 24             	mov    %eax,(%esp)
  800a58:	e8 77 ff ff ff       	call   8009d4 <memmove>
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a73:	eb 16                	jmp    800a8b <memcmp+0x2c>
		if (*s1 != *s2)
  800a75:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a78:	42                   	inc    %edx
  800a79:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a7d:	38 c8                	cmp    %cl,%al
  800a7f:	74 0a                	je     800a8b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a81:	0f b6 c0             	movzbl %al,%eax
  800a84:	0f b6 c9             	movzbl %cl,%ecx
  800a87:	29 c8                	sub    %ecx,%eax
  800a89:	eb 09                	jmp    800a94 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8b:	39 da                	cmp    %ebx,%edx
  800a8d:	75 e6                	jne    800a75 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa2:	89 c2                	mov    %eax,%edx
  800aa4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa7:	eb 05                	jmp    800aae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa9:	38 08                	cmp    %cl,(%eax)
  800aab:	74 05                	je     800ab2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aad:	40                   	inc    %eax
  800aae:	39 d0                	cmp    %edx,%eax
  800ab0:	72 f7                	jb     800aa9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac0:	eb 01                	jmp    800ac3 <strtol+0xf>
		s++;
  800ac2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac3:	8a 02                	mov    (%edx),%al
  800ac5:	3c 20                	cmp    $0x20,%al
  800ac7:	74 f9                	je     800ac2 <strtol+0xe>
  800ac9:	3c 09                	cmp    $0x9,%al
  800acb:	74 f5                	je     800ac2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800acd:	3c 2b                	cmp    $0x2b,%al
  800acf:	75 08                	jne    800ad9 <strtol+0x25>
		s++;
  800ad1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad7:	eb 13                	jmp    800aec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad9:	3c 2d                	cmp    $0x2d,%al
  800adb:	75 0a                	jne    800ae7 <strtol+0x33>
		s++, neg = 1;
  800add:	8d 52 01             	lea    0x1(%edx),%edx
  800ae0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae5:	eb 05                	jmp    800aec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	74 05                	je     800af5 <strtol+0x41>
  800af0:	83 fb 10             	cmp    $0x10,%ebx
  800af3:	75 28                	jne    800b1d <strtol+0x69>
  800af5:	8a 02                	mov    (%edx),%al
  800af7:	3c 30                	cmp    $0x30,%al
  800af9:	75 10                	jne    800b0b <strtol+0x57>
  800afb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aff:	75 0a                	jne    800b0b <strtol+0x57>
		s += 2, base = 16;
  800b01:	83 c2 02             	add    $0x2,%edx
  800b04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b09:	eb 12                	jmp    800b1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b0b:	85 db                	test   %ebx,%ebx
  800b0d:	75 0e                	jne    800b1d <strtol+0x69>
  800b0f:	3c 30                	cmp    $0x30,%al
  800b11:	75 05                	jne    800b18 <strtol+0x64>
		s++, base = 8;
  800b13:	42                   	inc    %edx
  800b14:	b3 08                	mov    $0x8,%bl
  800b16:	eb 05                	jmp    800b1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b24:	8a 0a                	mov    (%edx),%cl
  800b26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b29:	80 fb 09             	cmp    $0x9,%bl
  800b2c:	77 08                	ja     800b36 <strtol+0x82>
			dig = *s - '0';
  800b2e:	0f be c9             	movsbl %cl,%ecx
  800b31:	83 e9 30             	sub    $0x30,%ecx
  800b34:	eb 1e                	jmp    800b54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b39:	80 fb 19             	cmp    $0x19,%bl
  800b3c:	77 08                	ja     800b46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b3e:	0f be c9             	movsbl %cl,%ecx
  800b41:	83 e9 57             	sub    $0x57,%ecx
  800b44:	eb 0e                	jmp    800b54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b49:	80 fb 19             	cmp    $0x19,%bl
  800b4c:	77 12                	ja     800b60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b4e:	0f be c9             	movsbl %cl,%ecx
  800b51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b54:	39 f1                	cmp    %esi,%ecx
  800b56:	7d 0c                	jge    800b64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b58:	42                   	inc    %edx
  800b59:	0f af c6             	imul   %esi,%eax
  800b5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b5e:	eb c4                	jmp    800b24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b60:	89 c1                	mov    %eax,%ecx
  800b62:	eb 02                	jmp    800b66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 05                	je     800b71 <strtol+0xbd>
		*endptr = (char *) s;
  800b6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b71:	85 ff                	test   %edi,%edi
  800b73:	74 04                	je     800b79 <strtol+0xc5>
  800b75:	89 c8                	mov    %ecx,%eax
  800b77:	f7 d8                	neg    %eax
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    
	...

00800b80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	89 c3                	mov    %eax,%ebx
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	89 c6                	mov    %eax,%esi
  800b97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	89 cb                	mov    %ecx,%ebx
  800bd5:	89 cf                	mov    %ecx,%edi
  800bd7:	89 ce                	mov    %ecx,%esi
  800bd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 28                	jle    800c07 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bea:	00 
  800beb:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfa:	00 
  800bfb:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800c02:	e8 b1 f5 ff ff       	call   8001b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c07:	83 c4 2c             	add    $0x2c,%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1f:	89 d1                	mov    %edx,%ecx
  800c21:	89 d3                	mov    %edx,%ebx
  800c23:	89 d7                	mov    %edx,%edi
  800c25:	89 d6                	mov    %edx,%esi
  800c27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_yield>:

void
sys_yield(void)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	ba 00 00 00 00       	mov    $0x0,%edx
  800c39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3e:	89 d1                	mov    %edx,%ecx
  800c40:	89 d3                	mov    %edx,%ebx
  800c42:	89 d7                	mov    %edx,%edi
  800c44:	89 d6                	mov    %edx,%esi
  800c46:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	be 00 00 00 00       	mov    $0x0,%esi
  800c5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	89 f7                	mov    %esi,%edi
  800c6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7e 28                	jle    800c99 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800c84:	00 
  800c85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8c:	00 
  800c8d:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800c94:	e8 1f f5 ff ff       	call   8001b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c99:	83 c4 2c             	add    $0x2c,%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	b8 05 00 00 00       	mov    $0x5,%eax
  800caf:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 28                	jle    800cec <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdf:	00 
  800ce0:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800ce7:	e8 cc f4 ff ff       	call   8001b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cec:	83 c4 2c             	add    $0x2c,%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	b8 06 00 00 00       	mov    $0x6,%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	89 de                	mov    %ebx,%esi
  800d11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 28                	jle    800d3f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d22:	00 
  800d23:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800d3a:	e8 79 f4 ff ff       	call   8001b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d3f:	83 c4 2c             	add    $0x2c,%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7e 28                	jle    800d92 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d75:	00 
  800d76:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d85:	00 
  800d86:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800d8d:	e8 26 f4 ff ff       	call   8001b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d92:	83 c4 2c             	add    $0x2c,%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800de0:	e8 d3 f3 ff ff       	call   8001b8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de5:	83 c4 2c             	add    $0x2c,%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	89 df                	mov    %ebx,%edi
  800e08:	89 de                	mov    %ebx,%esi
  800e0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7e 28                	jle    800e38 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e14:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e1b:	00 
  800e1c:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800e23:	00 
  800e24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2b:	00 
  800e2c:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800e33:	e8 80 f3 ff ff       	call   8001b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e38:	83 c4 2c             	add    $0x2c,%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	be 00 00 00 00       	mov    $0x0,%esi
  800e4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	89 cb                	mov    %ecx,%ebx
  800e7b:	89 cf                	mov    %ecx,%edi
  800e7d:	89 ce                	mov    %ecx,%esi
  800e7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	7e 28                	jle    800ead <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e89:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e90:	00 
  800e91:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800e98:	00 
  800e99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea0:	00 
  800ea1:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800ea8:	e8 0b f3 ff ff       	call   8001b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ead:	83 c4 2c             	add    $0x2c,%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ec5:	89 d1                	mov    %edx,%ecx
  800ec7:	89 d3                	mov    %edx,%ebx
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	89 d6                	mov    %edx,%esi
  800ecd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
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
  800eda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edf:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eea:	89 df                	mov    %ebx,%edi
  800eec:	89 de                	mov    %ebx,%esi
  800eee:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f00:	b8 10 00 00 00       	mov    $0x10,%eax
  800f05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f08:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0b:	89 df                	mov    %ebx,%edi
  800f0d:	89 de                	mov    %ebx,%esi
  800f0f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    
	...

00800f18 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 24             	sub    $0x24,%esp
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f22:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800f24:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f28:	74 2d                	je     800f57 <pgfault+0x3f>
  800f2a:	89 d8                	mov    %ebx,%eax
  800f2c:	c1 e8 16             	shr    $0x16,%eax
  800f2f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f36:	a8 01                	test   $0x1,%al
  800f38:	74 1d                	je     800f57 <pgfault+0x3f>
  800f3a:	89 d8                	mov    %ebx,%eax
  800f3c:	c1 e8 0c             	shr    $0xc,%eax
  800f3f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f46:	f6 c2 01             	test   $0x1,%dl
  800f49:	74 0c                	je     800f57 <pgfault+0x3f>
  800f4b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f52:	f6 c4 08             	test   $0x8,%ah
  800f55:	75 1c                	jne    800f73 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  800f57:	c7 44 24 08 30 2d 80 	movl   $0x802d30,0x8(%esp)
  800f5e:	00 
  800f5f:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f66:	00 
  800f67:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  800f6e:	e8 45 f2 ff ff       	call   8001b8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  800f73:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f79:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f90:	e8 b8 fc ff ff       	call   800c4d <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  800f95:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f9c:	00 
  800f9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fa1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fa8:	e8 91 fa ff ff       	call   800a3e <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  800fad:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fb4:	00 
  800fb5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fb9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fd0:	e8 cc fc ff ff       	call   800ca1 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  800fd5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fdc:	00 
  800fdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe4:	e8 0b fd ff ff       	call   800cf4 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  800fe9:	83 c4 24             	add    $0x24,%esp
  800fec:	5b                   	pop    %ebx
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    

00800fef <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	57                   	push   %edi
  800ff3:	56                   	push   %esi
  800ff4:	53                   	push   %ebx
  800ff5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800ff8:	c7 04 24 18 0f 80 00 	movl   $0x800f18,(%esp)
  800fff:	e8 ac 16 00 00       	call   8026b0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801004:	ba 07 00 00 00       	mov    $0x7,%edx
  801009:	89 d0                	mov    %edx,%eax
  80100b:	cd 30                	int    $0x30
  80100d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801010:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  801012:	85 c0                	test   %eax,%eax
  801014:	79 20                	jns    801036 <fork+0x47>
		panic("sys_exofork: %e", envid);
  801016:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80101a:	c7 44 24 08 7e 2d 80 	movl   $0x802d7e,0x8(%esp)
  801021:	00 
  801022:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801029:	00 
  80102a:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  801031:	e8 82 f1 ff ff       	call   8001b8 <_panic>
	if (envid == 0)
  801036:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80103a:	75 25                	jne    801061 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80103c:	e8 ce fb ff ff       	call   800c0f <sys_getenvid>
  801041:	25 ff 03 00 00       	and    $0x3ff,%eax
  801046:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80104d:	c1 e0 07             	shl    $0x7,%eax
  801050:	29 d0                	sub    %edx,%eax
  801052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801057:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80105c:	e9 43 02 00 00       	jmp    8012a4 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  801066:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80106c:	0f 84 85 01 00 00    	je     8011f7 <fork+0x208>
  801072:	89 d8                	mov    %ebx,%eax
  801074:	c1 e8 16             	shr    $0x16,%eax
  801077:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107e:	a8 01                	test   $0x1,%al
  801080:	0f 84 5f 01 00 00    	je     8011e5 <fork+0x1f6>
  801086:	89 d8                	mov    %ebx,%eax
  801088:	c1 e8 0c             	shr    $0xc,%eax
  80108b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801092:	f6 c2 01             	test   $0x1,%dl
  801095:	0f 84 4a 01 00 00    	je     8011e5 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  80109b:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  80109d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a4:	f6 c6 04             	test   $0x4,%dh
  8010a7:	74 50                	je     8010f9 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  8010a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010bd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cc:	e8 d0 fb ff ff       	call   800ca1 <sys_page_map>
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	0f 89 0c 01 00 00    	jns    8011e5 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  8010d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010dd:	c7 44 24 08 8e 2d 80 	movl   $0x802d8e,0x8(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8010ec:	00 
  8010ed:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  8010f4:	e8 bf f0 ff ff       	call   8001b8 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  8010f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801100:	f6 c2 02             	test   $0x2,%dl
  801103:	75 10                	jne    801115 <fork+0x126>
  801105:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110c:	f6 c4 08             	test   $0x8,%ah
  80110f:	0f 84 8c 00 00 00    	je     8011a1 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  801115:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80111c:	00 
  80111d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801121:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801125:	89 74 24 04          	mov    %esi,0x4(%esp)
  801129:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801130:	e8 6c fb ff ff       	call   800ca1 <sys_page_map>
  801135:	85 c0                	test   %eax,%eax
  801137:	79 20                	jns    801159 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80113d:	c7 44 24 08 8e 2d 80 	movl   $0x802d8e,0x8(%esp)
  801144:	00 
  801145:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80114c:	00 
  80114d:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  801154:	e8 5f f0 ff ff       	call   8001b8 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801159:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801160:	00 
  801161:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801165:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80116c:	00 
  80116d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801171:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801178:	e8 24 fb ff ff       	call   800ca1 <sys_page_map>
  80117d:	85 c0                	test   %eax,%eax
  80117f:	79 64                	jns    8011e5 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801181:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801185:	c7 44 24 08 8e 2d 80 	movl   $0x802d8e,0x8(%esp)
  80118c:	00 
  80118d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801194:	00 
  801195:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  80119c:	e8 17 f0 ff ff       	call   8001b8 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  8011a1:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011a8:	00 
  8011a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011ad:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011bc:	e8 e0 fa ff ff       	call   800ca1 <sys_page_map>
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	79 20                	jns    8011e5 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8011c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c9:	c7 44 24 08 8e 2d 80 	movl   $0x802d8e,0x8(%esp)
  8011d0:	00 
  8011d1:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8011d8:	00 
  8011d9:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  8011e0:	e8 d3 ef ff ff       	call   8001b8 <_panic>
  8011e5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  8011eb:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8011f1:	0f 85 6f fe ff ff    	jne    801066 <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  8011f7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011fe:	00 
  8011ff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801206:	ee 
  801207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80120a:	89 04 24             	mov    %eax,(%esp)
  80120d:	e8 3b fa ff ff       	call   800c4d <sys_page_alloc>
  801212:	85 c0                	test   %eax,%eax
  801214:	79 20                	jns    801236 <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  801216:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121a:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  801221:	00 
  801222:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801229:	00 
  80122a:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  801231:	e8 82 ef ff ff       	call   8001b8 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801236:	c7 44 24 04 fc 26 80 	movl   $0x8026fc,0x4(%esp)
  80123d:	00 
  80123e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801241:	89 04 24             	mov    %eax,(%esp)
  801244:	e8 a4 fb ff ff       	call   800ded <sys_env_set_pgfault_upcall>
  801249:	85 c0                	test   %eax,%eax
  80124b:	79 20                	jns    80126d <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  80124d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801251:	c7 44 24 08 54 2d 80 	movl   $0x802d54,0x8(%esp)
  801258:	00 
  801259:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801260:	00 
  801261:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  801268:	e8 4b ef ff ff       	call   8001b8 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80126d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801274:	00 
  801275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801278:	89 04 24             	mov    %eax,(%esp)
  80127b:	e8 c7 fa ff ff       	call   800d47 <sys_env_set_status>
  801280:	85 c0                	test   %eax,%eax
  801282:	79 20                	jns    8012a4 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801284:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801288:	c7 44 24 08 b3 2d 80 	movl   $0x802db3,0x8(%esp)
  80128f:	00 
  801290:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801297:	00 
  801298:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  80129f:	e8 14 ef ff ff       	call   8001b8 <_panic>

	return envid;
	// panic("fork not implemented");
}
  8012a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012a7:	83 c4 3c             	add    $0x3c,%esp
  8012aa:	5b                   	pop    %ebx
  8012ab:	5e                   	pop    %esi
  8012ac:	5f                   	pop    %edi
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <sfork>:

// Challenge!
int
sfork(void)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012b5:	c7 44 24 08 ca 2d 80 	movl   $0x802dca,0x8(%esp)
  8012bc:	00 
  8012bd:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8012c4:	00 
  8012c5:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  8012cc:	e8 e7 ee ff ff       	call   8001b8 <_panic>
  8012d1:	00 00                	add    %al,(%eax)
	...

008012d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 10             	sub    $0x10,%esp
  8012dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	74 0a                	je     8012f3 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8012e9:	89 04 24             	mov    %eax,(%esp)
  8012ec:	e8 72 fb ff ff       	call   800e63 <sys_ipc_recv>
  8012f1:	eb 0c                	jmp    8012ff <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8012f3:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8012fa:	e8 64 fb ff ff       	call   800e63 <sys_ipc_recv>
	}
	if (r < 0)
  8012ff:	85 c0                	test   %eax,%eax
  801301:	79 16                	jns    801319 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  801303:	85 db                	test   %ebx,%ebx
  801305:	74 06                	je     80130d <ipc_recv+0x39>
  801307:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  80130d:	85 f6                	test   %esi,%esi
  80130f:	74 2c                	je     80133d <ipc_recv+0x69>
  801311:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801317:	eb 24                	jmp    80133d <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  801319:	85 db                	test   %ebx,%ebx
  80131b:	74 0a                	je     801327 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  80131d:	a1 08 40 80 00       	mov    0x804008,%eax
  801322:	8b 40 74             	mov    0x74(%eax),%eax
  801325:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  801327:	85 f6                	test   %esi,%esi
  801329:	74 0a                	je     801335 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80132b:	a1 08 40 80 00       	mov    0x804008,%eax
  801330:	8b 40 78             	mov    0x78(%eax),%eax
  801333:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  801335:	a1 08 40 80 00       	mov    0x804008,%eax
  80133a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	5b                   	pop    %ebx
  801341:	5e                   	pop    %esi
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	57                   	push   %edi
  801348:	56                   	push   %esi
  801349:	53                   	push   %ebx
  80134a:	83 ec 1c             	sub    $0x1c,%esp
  80134d:	8b 75 08             	mov    0x8(%ebp),%esi
  801350:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801353:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  801356:	85 db                	test   %ebx,%ebx
  801358:	74 19                	je     801373 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801361:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801365:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801369:	89 34 24             	mov    %esi,(%esp)
  80136c:	e8 cf fa ff ff       	call   800e40 <sys_ipc_try_send>
  801371:	eb 1c                	jmp    80138f <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  801373:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80137a:	00 
  80137b:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801382:	ee 
  801383:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801387:	89 34 24             	mov    %esi,(%esp)
  80138a:	e8 b1 fa ff ff       	call   800e40 <sys_ipc_try_send>
		}
		if (r == 0)
  80138f:	85 c0                	test   %eax,%eax
  801391:	74 2c                	je     8013bf <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  801393:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801396:	74 20                	je     8013b8 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  801398:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139c:	c7 44 24 08 e0 2d 80 	movl   $0x802de0,0x8(%esp)
  8013a3:	00 
  8013a4:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8013ab:	00 
  8013ac:	c7 04 24 f3 2d 80 00 	movl   $0x802df3,(%esp)
  8013b3:	e8 00 ee ff ff       	call   8001b8 <_panic>
		}
		sys_yield();
  8013b8:	e8 71 f8 ff ff       	call   800c2e <sys_yield>
	}
  8013bd:	eb 97                	jmp    801356 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8013bf:	83 c4 1c             	add    $0x1c,%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5f                   	pop    %edi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	53                   	push   %ebx
  8013cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8013ce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013d3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8013da:	89 c2                	mov    %eax,%edx
  8013dc:	c1 e2 07             	shl    $0x7,%edx
  8013df:	29 ca                	sub    %ecx,%edx
  8013e1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013e7:	8b 52 50             	mov    0x50(%edx),%edx
  8013ea:	39 da                	cmp    %ebx,%edx
  8013ec:	75 0f                	jne    8013fd <ipc_find_env+0x36>
			return envs[i].env_id;
  8013ee:	c1 e0 07             	shl    $0x7,%eax
  8013f1:	29 c8                	sub    %ecx,%eax
  8013f3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013f8:	8b 40 40             	mov    0x40(%eax),%eax
  8013fb:	eb 0c                	jmp    801409 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013fd:	40                   	inc    %eax
  8013fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801403:	75 ce                	jne    8013d3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801405:	66 b8 00 00          	mov    $0x0,%ax
}
  801409:	5b                   	pop    %ebx
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	05 00 00 00 30       	add    $0x30000000,%eax
  801417:	c1 e8 0c             	shr    $0xc,%eax
}
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	89 04 24             	mov    %eax,(%esp)
  801428:	e8 df ff ff ff       	call   80140c <fd2num>
  80142d:	c1 e0 0c             	shl    $0xc,%eax
  801430:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	53                   	push   %ebx
  80143b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80143e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801443:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801445:	89 c2                	mov    %eax,%edx
  801447:	c1 ea 16             	shr    $0x16,%edx
  80144a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801451:	f6 c2 01             	test   $0x1,%dl
  801454:	74 11                	je     801467 <fd_alloc+0x30>
  801456:	89 c2                	mov    %eax,%edx
  801458:	c1 ea 0c             	shr    $0xc,%edx
  80145b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801462:	f6 c2 01             	test   $0x1,%dl
  801465:	75 09                	jne    801470 <fd_alloc+0x39>
			*fd_store = fd;
  801467:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
  80146e:	eb 17                	jmp    801487 <fd_alloc+0x50>
  801470:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801475:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80147a:	75 c7                	jne    801443 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80147c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801482:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801487:	5b                   	pop    %ebx
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    

0080148a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801490:	83 f8 1f             	cmp    $0x1f,%eax
  801493:	77 36                	ja     8014cb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801495:	c1 e0 0c             	shl    $0xc,%eax
  801498:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80149d:	89 c2                	mov    %eax,%edx
  80149f:	c1 ea 16             	shr    $0x16,%edx
  8014a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a9:	f6 c2 01             	test   $0x1,%dl
  8014ac:	74 24                	je     8014d2 <fd_lookup+0x48>
  8014ae:	89 c2                	mov    %eax,%edx
  8014b0:	c1 ea 0c             	shr    $0xc,%edx
  8014b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ba:	f6 c2 01             	test   $0x1,%dl
  8014bd:	74 1a                	je     8014d9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c2:	89 02                	mov    %eax,(%edx)
	return 0;
  8014c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c9:	eb 13                	jmp    8014de <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d0:	eb 0c                	jmp    8014de <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d7:	eb 05                	jmp    8014de <fd_lookup+0x54>
  8014d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 14             	sub    $0x14,%esp
  8014e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8014ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f2:	eb 0e                	jmp    801502 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8014f4:	39 08                	cmp    %ecx,(%eax)
  8014f6:	75 09                	jne    801501 <dev_lookup+0x21>
			*dev = devtab[i];
  8014f8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ff:	eb 33                	jmp    801534 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801501:	42                   	inc    %edx
  801502:	8b 04 95 80 2e 80 00 	mov    0x802e80(,%edx,4),%eax
  801509:	85 c0                	test   %eax,%eax
  80150b:	75 e7                	jne    8014f4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80150d:	a1 08 40 80 00       	mov    0x804008,%eax
  801512:	8b 40 48             	mov    0x48(%eax),%eax
  801515:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151d:	c7 04 24 00 2e 80 00 	movl   $0x802e00,(%esp)
  801524:	e8 87 ed ff ff       	call   8002b0 <cprintf>
	*dev = 0;
  801529:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80152f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801534:	83 c4 14             	add    $0x14,%esp
  801537:	5b                   	pop    %ebx
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    

0080153a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	56                   	push   %esi
  80153e:	53                   	push   %ebx
  80153f:	83 ec 30             	sub    $0x30,%esp
  801542:	8b 75 08             	mov    0x8(%ebp),%esi
  801545:	8a 45 0c             	mov    0xc(%ebp),%al
  801548:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80154b:	89 34 24             	mov    %esi,(%esp)
  80154e:	e8 b9 fe ff ff       	call   80140c <fd2num>
  801553:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801556:	89 54 24 04          	mov    %edx,0x4(%esp)
  80155a:	89 04 24             	mov    %eax,(%esp)
  80155d:	e8 28 ff ff ff       	call   80148a <fd_lookup>
  801562:	89 c3                	mov    %eax,%ebx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 05                	js     80156d <fd_close+0x33>
	    || fd != fd2)
  801568:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80156b:	74 0d                	je     80157a <fd_close+0x40>
		return (must_exist ? r : 0);
  80156d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801571:	75 46                	jne    8015b9 <fd_close+0x7f>
  801573:	bb 00 00 00 00       	mov    $0x0,%ebx
  801578:	eb 3f                	jmp    8015b9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80157a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801581:	8b 06                	mov    (%esi),%eax
  801583:	89 04 24             	mov    %eax,(%esp)
  801586:	e8 55 ff ff ff       	call   8014e0 <dev_lookup>
  80158b:	89 c3                	mov    %eax,%ebx
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 18                	js     8015a9 <fd_close+0x6f>
		if (dev->dev_close)
  801591:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801594:	8b 40 10             	mov    0x10(%eax),%eax
  801597:	85 c0                	test   %eax,%eax
  801599:	74 09                	je     8015a4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80159b:	89 34 24             	mov    %esi,(%esp)
  80159e:	ff d0                	call   *%eax
  8015a0:	89 c3                	mov    %eax,%ebx
  8015a2:	eb 05                	jmp    8015a9 <fd_close+0x6f>
		else
			r = 0;
  8015a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b4:	e8 3b f7 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
}
  8015b9:	89 d8                	mov    %ebx,%eax
  8015bb:	83 c4 30             	add    $0x30,%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    

008015c2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d2:	89 04 24             	mov    %eax,(%esp)
  8015d5:	e8 b0 fe ff ff       	call   80148a <fd_lookup>
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 13                	js     8015f1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8015de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015e5:	00 
  8015e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e9:	89 04 24             	mov    %eax,(%esp)
  8015ec:	e8 49 ff ff ff       	call   80153a <fd_close>
}
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <close_all>:

void
close_all(void)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015ff:	89 1c 24             	mov    %ebx,(%esp)
  801602:	e8 bb ff ff ff       	call   8015c2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801607:	43                   	inc    %ebx
  801608:	83 fb 20             	cmp    $0x20,%ebx
  80160b:	75 f2                	jne    8015ff <close_all+0xc>
		close(i);
}
  80160d:	83 c4 14             	add    $0x14,%esp
  801610:	5b                   	pop    %ebx
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	57                   	push   %edi
  801617:	56                   	push   %esi
  801618:	53                   	push   %ebx
  801619:	83 ec 4c             	sub    $0x4c,%esp
  80161c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80161f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801622:	89 44 24 04          	mov    %eax,0x4(%esp)
  801626:	8b 45 08             	mov    0x8(%ebp),%eax
  801629:	89 04 24             	mov    %eax,(%esp)
  80162c:	e8 59 fe ff ff       	call   80148a <fd_lookup>
  801631:	89 c3                	mov    %eax,%ebx
  801633:	85 c0                	test   %eax,%eax
  801635:	0f 88 e3 00 00 00    	js     80171e <dup+0x10b>
		return r;
	close(newfdnum);
  80163b:	89 3c 24             	mov    %edi,(%esp)
  80163e:	e8 7f ff ff ff       	call   8015c2 <close>

	newfd = INDEX2FD(newfdnum);
  801643:	89 fe                	mov    %edi,%esi
  801645:	c1 e6 0c             	shl    $0xc,%esi
  801648:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80164e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801651:	89 04 24             	mov    %eax,(%esp)
  801654:	e8 c3 fd ff ff       	call   80141c <fd2data>
  801659:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80165b:	89 34 24             	mov    %esi,(%esp)
  80165e:	e8 b9 fd ff ff       	call   80141c <fd2data>
  801663:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801666:	89 d8                	mov    %ebx,%eax
  801668:	c1 e8 16             	shr    $0x16,%eax
  80166b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801672:	a8 01                	test   $0x1,%al
  801674:	74 46                	je     8016bc <dup+0xa9>
  801676:	89 d8                	mov    %ebx,%eax
  801678:	c1 e8 0c             	shr    $0xc,%eax
  80167b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801682:	f6 c2 01             	test   $0x1,%dl
  801685:	74 35                	je     8016bc <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801687:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80168e:	25 07 0e 00 00       	and    $0xe07,%eax
  801693:	89 44 24 10          	mov    %eax,0x10(%esp)
  801697:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80169a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80169e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016a5:	00 
  8016a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b1:	e8 eb f5 ff ff       	call   800ca1 <sys_page_map>
  8016b6:	89 c3                	mov    %eax,%ebx
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 3b                	js     8016f7 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	c1 ea 0c             	shr    $0xc,%edx
  8016c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016cb:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016e0:	00 
  8016e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ec:	e8 b0 f5 ff ff       	call   800ca1 <sys_page_map>
  8016f1:	89 c3                	mov    %eax,%ebx
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	79 25                	jns    80171c <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801702:	e8 ed f5 ff ff       	call   800cf4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801707:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80170a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801715:	e8 da f5 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  80171a:	eb 02                	jmp    80171e <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80171c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80171e:	89 d8                	mov    %ebx,%eax
  801720:	83 c4 4c             	add    $0x4c,%esp
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5f                   	pop    %edi
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	53                   	push   %ebx
  80172c:	83 ec 24             	sub    $0x24,%esp
  80172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801735:	89 44 24 04          	mov    %eax,0x4(%esp)
  801739:	89 1c 24             	mov    %ebx,(%esp)
  80173c:	e8 49 fd ff ff       	call   80148a <fd_lookup>
  801741:	85 c0                	test   %eax,%eax
  801743:	78 6d                	js     8017b2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801745:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174f:	8b 00                	mov    (%eax),%eax
  801751:	89 04 24             	mov    %eax,(%esp)
  801754:	e8 87 fd ff ff       	call   8014e0 <dev_lookup>
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 55                	js     8017b2 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80175d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801760:	8b 50 08             	mov    0x8(%eax),%edx
  801763:	83 e2 03             	and    $0x3,%edx
  801766:	83 fa 01             	cmp    $0x1,%edx
  801769:	75 23                	jne    80178e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80176b:	a1 08 40 80 00       	mov    0x804008,%eax
  801770:	8b 40 48             	mov    0x48(%eax),%eax
  801773:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177b:	c7 04 24 44 2e 80 00 	movl   $0x802e44,(%esp)
  801782:	e8 29 eb ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  801787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80178c:	eb 24                	jmp    8017b2 <read+0x8a>
	}
	if (!dev->dev_read)
  80178e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801791:	8b 52 08             	mov    0x8(%edx),%edx
  801794:	85 d2                	test   %edx,%edx
  801796:	74 15                	je     8017ad <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801798:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80179b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80179f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017a6:	89 04 24             	mov    %eax,(%esp)
  8017a9:	ff d2                	call   *%edx
  8017ab:	eb 05                	jmp    8017b2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017b2:	83 c4 24             	add    $0x24,%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	57                   	push   %edi
  8017bc:	56                   	push   %esi
  8017bd:	53                   	push   %ebx
  8017be:	83 ec 1c             	sub    $0x1c,%esp
  8017c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017cc:	eb 23                	jmp    8017f1 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017ce:	89 f0                	mov    %esi,%eax
  8017d0:	29 d8                	sub    %ebx,%eax
  8017d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d9:	01 d8                	add    %ebx,%eax
  8017db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017df:	89 3c 24             	mov    %edi,(%esp)
  8017e2:	e8 41 ff ff ff       	call   801728 <read>
		if (m < 0)
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 10                	js     8017fb <readn+0x43>
			return m;
		if (m == 0)
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	74 0a                	je     8017f9 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ef:	01 c3                	add    %eax,%ebx
  8017f1:	39 f3                	cmp    %esi,%ebx
  8017f3:	72 d9                	jb     8017ce <readn+0x16>
  8017f5:	89 d8                	mov    %ebx,%eax
  8017f7:	eb 02                	jmp    8017fb <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017f9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017fb:	83 c4 1c             	add    $0x1c,%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5f                   	pop    %edi
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	83 ec 24             	sub    $0x24,%esp
  80180a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801810:	89 44 24 04          	mov    %eax,0x4(%esp)
  801814:	89 1c 24             	mov    %ebx,(%esp)
  801817:	e8 6e fc ff ff       	call   80148a <fd_lookup>
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 68                	js     801888 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801820:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182a:	8b 00                	mov    (%eax),%eax
  80182c:	89 04 24             	mov    %eax,(%esp)
  80182f:	e8 ac fc ff ff       	call   8014e0 <dev_lookup>
  801834:	85 c0                	test   %eax,%eax
  801836:	78 50                	js     801888 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801838:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80183f:	75 23                	jne    801864 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801841:	a1 08 40 80 00       	mov    0x804008,%eax
  801846:	8b 40 48             	mov    0x48(%eax),%eax
  801849:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80184d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801851:	c7 04 24 60 2e 80 00 	movl   $0x802e60,(%esp)
  801858:	e8 53 ea ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  80185d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801862:	eb 24                	jmp    801888 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801864:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801867:	8b 52 0c             	mov    0xc(%edx),%edx
  80186a:	85 d2                	test   %edx,%edx
  80186c:	74 15                	je     801883 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80186e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801871:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801875:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801878:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80187c:	89 04 24             	mov    %eax,(%esp)
  80187f:	ff d2                	call   *%edx
  801881:	eb 05                	jmp    801888 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801883:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801888:	83 c4 24             	add    $0x24,%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5d                   	pop    %ebp
  80188d:	c3                   	ret    

0080188e <seek>:

int
seek(int fdnum, off_t offset)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801894:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	89 04 24             	mov    %eax,(%esp)
  8018a1:	e8 e4 fb ff ff       	call   80148a <fd_lookup>
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 0e                	js     8018b8 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    

008018ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	53                   	push   %ebx
  8018be:	83 ec 24             	sub    $0x24,%esp
  8018c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cb:	89 1c 24             	mov    %ebx,(%esp)
  8018ce:	e8 b7 fb ff ff       	call   80148a <fd_lookup>
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 61                	js     801938 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e1:	8b 00                	mov    (%eax),%eax
  8018e3:	89 04 24             	mov    %eax,(%esp)
  8018e6:	e8 f5 fb ff ff       	call   8014e0 <dev_lookup>
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 49                	js     801938 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018f6:	75 23                	jne    80191b <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018f8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018fd:	8b 40 48             	mov    0x48(%eax),%eax
  801900:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801904:	89 44 24 04          	mov    %eax,0x4(%esp)
  801908:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  80190f:	e8 9c e9 ff ff       	call   8002b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801914:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801919:	eb 1d                	jmp    801938 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80191b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80191e:	8b 52 18             	mov    0x18(%edx),%edx
  801921:	85 d2                	test   %edx,%edx
  801923:	74 0e                	je     801933 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801925:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801928:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80192c:	89 04 24             	mov    %eax,(%esp)
  80192f:	ff d2                	call   *%edx
  801931:	eb 05                	jmp    801938 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801933:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801938:	83 c4 24             	add    $0x24,%esp
  80193b:	5b                   	pop    %ebx
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    

0080193e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 24             	sub    $0x24,%esp
  801945:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801948:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80194b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194f:	8b 45 08             	mov    0x8(%ebp),%eax
  801952:	89 04 24             	mov    %eax,(%esp)
  801955:	e8 30 fb ff ff       	call   80148a <fd_lookup>
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 52                	js     8019b0 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801961:	89 44 24 04          	mov    %eax,0x4(%esp)
  801965:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801968:	8b 00                	mov    (%eax),%eax
  80196a:	89 04 24             	mov    %eax,(%esp)
  80196d:	e8 6e fb ff ff       	call   8014e0 <dev_lookup>
  801972:	85 c0                	test   %eax,%eax
  801974:	78 3a                	js     8019b0 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801976:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801979:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80197d:	74 2c                	je     8019ab <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80197f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801982:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801989:	00 00 00 
	stat->st_isdir = 0;
  80198c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801993:	00 00 00 
	stat->st_dev = dev;
  801996:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80199c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019a3:	89 14 24             	mov    %edx,(%esp)
  8019a6:	ff 50 14             	call   *0x14(%eax)
  8019a9:	eb 05                	jmp    8019b0 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019b0:	83 c4 24             	add    $0x24,%esp
  8019b3:	5b                   	pop    %ebx
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	56                   	push   %esi
  8019ba:	53                   	push   %ebx
  8019bb:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019c5:	00 
  8019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 2a 02 00 00       	call   801bfb <open>
  8019d1:	89 c3                	mov    %eax,%ebx
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 1b                	js     8019f2 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019de:	89 1c 24             	mov    %ebx,(%esp)
  8019e1:	e8 58 ff ff ff       	call   80193e <fstat>
  8019e6:	89 c6                	mov    %eax,%esi
	close(fd);
  8019e8:	89 1c 24             	mov    %ebx,(%esp)
  8019eb:	e8 d2 fb ff ff       	call   8015c2 <close>
	return r;
  8019f0:	89 f3                	mov    %esi,%ebx
}
  8019f2:	89 d8                	mov    %ebx,%eax
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	5b                   	pop    %ebx
  8019f8:	5e                   	pop    %esi
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    
	...

008019fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	83 ec 10             	sub    $0x10,%esp
  801a04:	89 c3                	mov    %eax,%ebx
  801a06:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a08:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a0f:	75 11                	jne    801a22 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a18:	e8 aa f9 ff ff       	call   8013c7 <ipc_find_env>
  801a1d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a22:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a29:	00 
  801a2a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a31:	00 
  801a32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a36:	a1 00 40 80 00       	mov    0x804000,%eax
  801a3b:	89 04 24             	mov    %eax,(%esp)
  801a3e:	e8 01 f9 ff ff       	call   801344 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a4a:	00 
  801a4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a56:	e8 79 f8 ff ff       	call   8012d4 <ipc_recv>
}
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	5b                   	pop    %ebx
  801a5f:	5e                   	pop    %esi
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a76:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a80:	b8 02 00 00 00       	mov    $0x2,%eax
  801a85:	e8 72 ff ff ff       	call   8019fc <fsipc>
}
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	8b 40 0c             	mov    0xc(%eax),%eax
  801a98:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa2:	b8 06 00 00 00       	mov    $0x6,%eax
  801aa7:	e8 50 ff ff ff       	call   8019fc <fsipc>
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 14             	sub    $0x14,%esp
  801ab5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  801abb:	8b 40 0c             	mov    0xc(%eax),%eax
  801abe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac8:	b8 05 00 00 00       	mov    $0x5,%eax
  801acd:	e8 2a ff ff ff       	call   8019fc <fsipc>
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	78 2b                	js     801b01 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ad6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801add:	00 
  801ade:	89 1c 24             	mov    %ebx,(%esp)
  801ae1:	e8 75 ed ff ff       	call   80085b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ae6:	a1 80 50 80 00       	mov    0x805080,%eax
  801aeb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801af1:	a1 84 50 80 00       	mov    0x805084,%eax
  801af6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b01:	83 c4 14             	add    $0x14,%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 18             	sub    $0x18,%esp
  801b0d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b10:	8b 55 08             	mov    0x8(%ebp),%edx
  801b13:	8b 52 0c             	mov    0xc(%edx),%edx
  801b16:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b1c:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801b21:	89 c2                	mov    %eax,%edx
  801b23:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b28:	76 05                	jbe    801b2f <devfile_write+0x28>
  801b2a:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801b2f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b36:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3a:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801b41:	e8 f8 ee ff ff       	call   800a3e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801b46:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4b:	b8 04 00 00 00       	mov    $0x4,%eax
  801b50:	e8 a7 fe ff ff       	call   8019fc <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 10             	sub    $0x10,%esp
  801b5f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	8b 40 0c             	mov    0xc(%eax),%eax
  801b68:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b6d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b73:	ba 00 00 00 00       	mov    $0x0,%edx
  801b78:	b8 03 00 00 00       	mov    $0x3,%eax
  801b7d:	e8 7a fe ff ff       	call   8019fc <fsipc>
  801b82:	89 c3                	mov    %eax,%ebx
  801b84:	85 c0                	test   %eax,%eax
  801b86:	78 6a                	js     801bf2 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b88:	39 c6                	cmp    %eax,%esi
  801b8a:	73 24                	jae    801bb0 <devfile_read+0x59>
  801b8c:	c7 44 24 0c 94 2e 80 	movl   $0x802e94,0xc(%esp)
  801b93:	00 
  801b94:	c7 44 24 08 9b 2e 80 	movl   $0x802e9b,0x8(%esp)
  801b9b:	00 
  801b9c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ba3:	00 
  801ba4:	c7 04 24 b0 2e 80 00 	movl   $0x802eb0,(%esp)
  801bab:	e8 08 e6 ff ff       	call   8001b8 <_panic>
	assert(r <= PGSIZE);
  801bb0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bb5:	7e 24                	jle    801bdb <devfile_read+0x84>
  801bb7:	c7 44 24 0c bb 2e 80 	movl   $0x802ebb,0xc(%esp)
  801bbe:	00 
  801bbf:	c7 44 24 08 9b 2e 80 	movl   $0x802e9b,0x8(%esp)
  801bc6:	00 
  801bc7:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801bce:	00 
  801bcf:	c7 04 24 b0 2e 80 00 	movl   $0x802eb0,(%esp)
  801bd6:	e8 dd e5 ff ff       	call   8001b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bdf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801be6:	00 
  801be7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bea:	89 04 24             	mov    %eax,(%esp)
  801bed:	e8 e2 ed ff ff       	call   8009d4 <memmove>
	return r;
}
  801bf2:	89 d8                	mov    %ebx,%eax
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	56                   	push   %esi
  801bff:	53                   	push   %ebx
  801c00:	83 ec 20             	sub    $0x20,%esp
  801c03:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c06:	89 34 24             	mov    %esi,(%esp)
  801c09:	e8 1a ec ff ff       	call   800828 <strlen>
  801c0e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c13:	7f 60                	jg     801c75 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c18:	89 04 24             	mov    %eax,(%esp)
  801c1b:	e8 17 f8 ff ff       	call   801437 <fd_alloc>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	85 c0                	test   %eax,%eax
  801c24:	78 54                	js     801c7a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c2a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c31:	e8 25 ec ff ff       	call   80085b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c39:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	e8 b1 fd ff ff       	call   8019fc <fsipc>
  801c4b:	89 c3                	mov    %eax,%ebx
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	79 15                	jns    801c66 <open+0x6b>
		fd_close(fd, 0);
  801c51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c58:	00 
  801c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5c:	89 04 24             	mov    %eax,(%esp)
  801c5f:	e8 d6 f8 ff ff       	call   80153a <fd_close>
		return r;
  801c64:	eb 14                	jmp    801c7a <open+0x7f>
	}

	return fd2num(fd);
  801c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c69:	89 04 24             	mov    %eax,(%esp)
  801c6c:	e8 9b f7 ff ff       	call   80140c <fd2num>
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	eb 05                	jmp    801c7a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c75:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c7a:	89 d8                	mov    %ebx,%eax
  801c7c:	83 c4 20             	add    $0x20,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c89:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c93:	e8 64 fd ff ff       	call   8019fc <fsipc>
}
  801c98:	c9                   	leave  
  801c99:	c3                   	ret    
	...

00801c9c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ca2:	c7 44 24 04 c7 2e 80 	movl   $0x802ec7,0x4(%esp)
  801ca9:	00 
  801caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cad:	89 04 24             	mov    %eax,(%esp)
  801cb0:	e8 a6 eb ff ff       	call   80085b <strcpy>
	return 0;
}
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    

00801cbc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	53                   	push   %ebx
  801cc0:	83 ec 14             	sub    $0x14,%esp
  801cc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cc6:	89 1c 24             	mov    %ebx,(%esp)
  801cc9:	e8 56 0a 00 00       	call   802724 <pageref>
  801cce:	83 f8 01             	cmp    $0x1,%eax
  801cd1:	75 0d                	jne    801ce0 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801cd3:	8b 43 0c             	mov    0xc(%ebx),%eax
  801cd6:	89 04 24             	mov    %eax,(%esp)
  801cd9:	e8 1f 03 00 00       	call   801ffd <nsipc_close>
  801cde:	eb 05                	jmp    801ce5 <devsock_close+0x29>
	else
		return 0;
  801ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce5:	83 c4 14             	add    $0x14,%esp
  801ce8:	5b                   	pop    %ebx
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cf1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cf8:	00 
  801cf9:	8b 45 10             	mov    0x10(%ebp),%eax
  801cfc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d0d:	89 04 24             	mov    %eax,(%esp)
  801d10:	e8 e3 03 00 00       	call   8020f8 <nsipc_send>
}
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d1d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d24:	00 
  801d25:	8b 45 10             	mov    0x10(%ebp),%eax
  801d28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d33:	8b 45 08             	mov    0x8(%ebp),%eax
  801d36:	8b 40 0c             	mov    0xc(%eax),%eax
  801d39:	89 04 24             	mov    %eax,(%esp)
  801d3c:	e8 37 03 00 00       	call   802078 <nsipc_recv>
}
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	83 ec 20             	sub    $0x20,%esp
  801d4b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d50:	89 04 24             	mov    %eax,(%esp)
  801d53:	e8 df f6 ff ff       	call   801437 <fd_alloc>
  801d58:	89 c3                	mov    %eax,%ebx
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 21                	js     801d7f <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d5e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d65:	00 
  801d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d74:	e8 d4 ee ff ff       	call   800c4d <sys_page_alloc>
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	79 0a                	jns    801d89 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801d7f:	89 34 24             	mov    %esi,(%esp)
  801d82:	e8 76 02 00 00       	call   801ffd <nsipc_close>
		return r;
  801d87:	eb 22                	jmp    801dab <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d89:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d92:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d97:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d9e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801da1:	89 04 24             	mov    %eax,(%esp)
  801da4:	e8 63 f6 ff ff       	call   80140c <fd2num>
  801da9:	89 c3                	mov    %eax,%ebx
}
  801dab:	89 d8                	mov    %ebx,%eax
  801dad:	83 c4 20             	add    $0x20,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801dba:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801dbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc1:	89 04 24             	mov    %eax,(%esp)
  801dc4:	e8 c1 f6 ff ff       	call   80148a <fd_lookup>
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	78 17                	js     801de4 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd6:	39 10                	cmp    %edx,(%eax)
  801dd8:	75 05                	jne    801ddf <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801dda:	8b 40 0c             	mov    0xc(%eax),%eax
  801ddd:	eb 05                	jmp    801de4 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ddf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801de4:	c9                   	leave  
  801de5:	c3                   	ret    

00801de6 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	e8 c0 ff ff ff       	call   801db4 <fd2sockid>
  801df4:	85 c0                	test   %eax,%eax
  801df6:	78 1f                	js     801e17 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801df8:	8b 55 10             	mov    0x10(%ebp),%edx
  801dfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e02:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e06:	89 04 24             	mov    %eax,(%esp)
  801e09:	e8 38 01 00 00       	call   801f46 <nsipc_accept>
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	78 05                	js     801e17 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801e12:	e8 2c ff ff ff       	call   801d43 <alloc_sockfd>
}
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    

00801e19 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	e8 8d ff ff ff       	call   801db4 <fd2sockid>
  801e27:	85 c0                	test   %eax,%eax
  801e29:	78 16                	js     801e41 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801e2b:	8b 55 10             	mov    0x10(%ebp),%edx
  801e2e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e35:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e39:	89 04 24             	mov    %eax,(%esp)
  801e3c:	e8 5b 01 00 00       	call   801f9c <nsipc_bind>
}
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    

00801e43 <shutdown>:

int
shutdown(int s, int how)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e49:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4c:	e8 63 ff ff ff       	call   801db4 <fd2sockid>
  801e51:	85 c0                	test   %eax,%eax
  801e53:	78 0f                	js     801e64 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e55:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e58:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e5c:	89 04 24             	mov    %eax,(%esp)
  801e5f:	e8 77 01 00 00       	call   801fdb <nsipc_shutdown>
}
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6f:	e8 40 ff ff ff       	call   801db4 <fd2sockid>
  801e74:	85 c0                	test   %eax,%eax
  801e76:	78 16                	js     801e8e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801e78:	8b 55 10             	mov    0x10(%ebp),%edx
  801e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e82:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e86:	89 04 24             	mov    %eax,(%esp)
  801e89:	e8 89 01 00 00       	call   802017 <nsipc_connect>
}
  801e8e:	c9                   	leave  
  801e8f:	c3                   	ret    

00801e90 <listen>:

int
listen(int s, int backlog)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e96:	8b 45 08             	mov    0x8(%ebp),%eax
  801e99:	e8 16 ff ff ff       	call   801db4 <fd2sockid>
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 0f                	js     801eb1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ea2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ea5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ea9:	89 04 24             	mov    %eax,(%esp)
  801eac:	e8 a5 01 00 00       	call   802056 <nsipc_listen>
}
  801eb1:	c9                   	leave  
  801eb2:	c3                   	ret    

00801eb3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801eb9:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eca:	89 04 24             	mov    %eax,(%esp)
  801ecd:	e8 99 02 00 00       	call   80216b <nsipc_socket>
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	78 05                	js     801edb <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801ed6:	e8 68 fe ff ff       	call   801d43 <alloc_sockfd>
}
  801edb:	c9                   	leave  
  801edc:	c3                   	ret    
  801edd:	00 00                	add    %al,(%eax)
	...

00801ee0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 14             	sub    $0x14,%esp
  801ee7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ee9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ef0:	75 11                	jne    801f03 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ef2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ef9:	e8 c9 f4 ff ff       	call   8013c7 <ipc_find_env>
  801efe:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f03:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f0a:	00 
  801f0b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801f12:	00 
  801f13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f17:	a1 04 40 80 00       	mov    0x804004,%eax
  801f1c:	89 04 24             	mov    %eax,(%esp)
  801f1f:	e8 20 f4 ff ff       	call   801344 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f24:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f2b:	00 
  801f2c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f33:	00 
  801f34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3b:	e8 94 f3 ff ff       	call   8012d4 <ipc_recv>
}
  801f40:	83 c4 14             	add    $0x14,%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5d                   	pop    %ebp
  801f45:	c3                   	ret    

00801f46 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	56                   	push   %esi
  801f4a:	53                   	push   %ebx
  801f4b:	83 ec 10             	sub    $0x10,%esp
  801f4e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f59:	8b 06                	mov    (%esi),%eax
  801f5b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f60:	b8 01 00 00 00       	mov    $0x1,%eax
  801f65:	e8 76 ff ff ff       	call   801ee0 <nsipc>
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	78 23                	js     801f93 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f70:	a1 10 60 80 00       	mov    0x806010,%eax
  801f75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f79:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f80:	00 
  801f81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f84:	89 04 24             	mov    %eax,(%esp)
  801f87:	e8 48 ea ff ff       	call   8009d4 <memmove>
		*addrlen = ret->ret_addrlen;
  801f8c:	a1 10 60 80 00       	mov    0x806010,%eax
  801f91:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f93:	89 d8                	mov    %ebx,%eax
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    

00801f9c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 14             	sub    $0x14,%esp
  801fa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb9:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801fc0:	e8 0f ea ff ff       	call   8009d4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fc5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801fcb:	b8 02 00 00 00       	mov    $0x2,%eax
  801fd0:	e8 0b ff ff ff       	call   801ee0 <nsipc>
}
  801fd5:	83 c4 14             	add    $0x14,%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fec:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ff1:	b8 03 00 00 00       	mov    $0x3,%eax
  801ff6:	e8 e5 fe ff ff       	call   801ee0 <nsipc>
}
  801ffb:	c9                   	leave  
  801ffc:	c3                   	ret    

00801ffd <nsipc_close>:

int
nsipc_close(int s)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802003:	8b 45 08             	mov    0x8(%ebp),%eax
  802006:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80200b:	b8 04 00 00 00       	mov    $0x4,%eax
  802010:	e8 cb fe ff ff       	call   801ee0 <nsipc>
}
  802015:	c9                   	leave  
  802016:	c3                   	ret    

00802017 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	53                   	push   %ebx
  80201b:	83 ec 14             	sub    $0x14,%esp
  80201e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802021:	8b 45 08             	mov    0x8(%ebp),%eax
  802024:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802029:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802030:	89 44 24 04          	mov    %eax,0x4(%esp)
  802034:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80203b:	e8 94 e9 ff ff       	call   8009d4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802040:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802046:	b8 05 00 00 00       	mov    $0x5,%eax
  80204b:	e8 90 fe ff ff       	call   801ee0 <nsipc>
}
  802050:	83 c4 14             	add    $0x14,%esp
  802053:	5b                   	pop    %ebx
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    

00802056 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80205c:	8b 45 08             	mov    0x8(%ebp),%eax
  80205f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802064:	8b 45 0c             	mov    0xc(%ebp),%eax
  802067:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80206c:	b8 06 00 00 00       	mov    $0x6,%eax
  802071:	e8 6a fe ff ff       	call   801ee0 <nsipc>
}
  802076:	c9                   	leave  
  802077:	c3                   	ret    

00802078 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	56                   	push   %esi
  80207c:	53                   	push   %ebx
  80207d:	83 ec 10             	sub    $0x10,%esp
  802080:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802083:	8b 45 08             	mov    0x8(%ebp),%eax
  802086:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80208b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802091:	8b 45 14             	mov    0x14(%ebp),%eax
  802094:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802099:	b8 07 00 00 00       	mov    $0x7,%eax
  80209e:	e8 3d fe ff ff       	call   801ee0 <nsipc>
  8020a3:	89 c3                	mov    %eax,%ebx
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	78 46                	js     8020ef <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8020a9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8020ae:	7f 04                	jg     8020b4 <nsipc_recv+0x3c>
  8020b0:	39 c6                	cmp    %eax,%esi
  8020b2:	7d 24                	jge    8020d8 <nsipc_recv+0x60>
  8020b4:	c7 44 24 0c d3 2e 80 	movl   $0x802ed3,0xc(%esp)
  8020bb:	00 
  8020bc:	c7 44 24 08 9b 2e 80 	movl   $0x802e9b,0x8(%esp)
  8020c3:	00 
  8020c4:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8020cb:	00 
  8020cc:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  8020d3:	e8 e0 e0 ff ff       	call   8001b8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020dc:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8020e3:	00 
  8020e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e7:	89 04 24             	mov    %eax,(%esp)
  8020ea:	e8 e5 e8 ff ff       	call   8009d4 <memmove>
	}

	return r;
}
  8020ef:	89 d8                	mov    %ebx,%eax
  8020f1:	83 c4 10             	add    $0x10,%esp
  8020f4:	5b                   	pop    %ebx
  8020f5:	5e                   	pop    %esi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    

008020f8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	53                   	push   %ebx
  8020fc:	83 ec 14             	sub    $0x14,%esp
  8020ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802102:	8b 45 08             	mov    0x8(%ebp),%eax
  802105:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80210a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802110:	7e 24                	jle    802136 <nsipc_send+0x3e>
  802112:	c7 44 24 0c f4 2e 80 	movl   $0x802ef4,0xc(%esp)
  802119:	00 
  80211a:	c7 44 24 08 9b 2e 80 	movl   $0x802e9b,0x8(%esp)
  802121:	00 
  802122:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802129:	00 
  80212a:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  802131:	e8 82 e0 ff ff       	call   8001b8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802136:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80213a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802141:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  802148:	e8 87 e8 ff ff       	call   8009d4 <memmove>
	nsipcbuf.send.req_size = size;
  80214d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802153:	8b 45 14             	mov    0x14(%ebp),%eax
  802156:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80215b:	b8 08 00 00 00       	mov    $0x8,%eax
  802160:	e8 7b fd ff ff       	call   801ee0 <nsipc>
}
  802165:	83 c4 14             	add    $0x14,%esp
  802168:	5b                   	pop    %ebx
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    

0080216b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802171:	8b 45 08             	mov    0x8(%ebp),%eax
  802174:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217c:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802181:	8b 45 10             	mov    0x10(%ebp),%eax
  802184:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802189:	b8 09 00 00 00       	mov    $0x9,%eax
  80218e:	e8 4d fd ff ff       	call   801ee0 <nsipc>
}
  802193:	c9                   	leave  
  802194:	c3                   	ret    
  802195:	00 00                	add    %al,(%eax)
	...

00802198 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	56                   	push   %esi
  80219c:	53                   	push   %ebx
  80219d:	83 ec 10             	sub    $0x10,%esp
  8021a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a6:	89 04 24             	mov    %eax,(%esp)
  8021a9:	e8 6e f2 ff ff       	call   80141c <fd2data>
  8021ae:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8021b0:	c7 44 24 04 00 2f 80 	movl   $0x802f00,0x4(%esp)
  8021b7:	00 
  8021b8:	89 34 24             	mov    %esi,(%esp)
  8021bb:	e8 9b e6 ff ff       	call   80085b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021c0:	8b 43 04             	mov    0x4(%ebx),%eax
  8021c3:	2b 03                	sub    (%ebx),%eax
  8021c5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8021cb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8021d2:	00 00 00 
	stat->st_dev = &devpipe;
  8021d5:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  8021dc:	30 80 00 
	return 0;
}
  8021df:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e4:	83 c4 10             	add    $0x10,%esp
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5d                   	pop    %ebp
  8021ea:	c3                   	ret    

008021eb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	53                   	push   %ebx
  8021ef:	83 ec 14             	sub    $0x14,%esp
  8021f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802200:	e8 ef ea ff ff       	call   800cf4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802205:	89 1c 24             	mov    %ebx,(%esp)
  802208:	e8 0f f2 ff ff       	call   80141c <fd2data>
  80220d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802211:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802218:	e8 d7 ea ff ff       	call   800cf4 <sys_page_unmap>
}
  80221d:	83 c4 14             	add    $0x14,%esp
  802220:	5b                   	pop    %ebx
  802221:	5d                   	pop    %ebp
  802222:	c3                   	ret    

00802223 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
  802226:	57                   	push   %edi
  802227:	56                   	push   %esi
  802228:	53                   	push   %ebx
  802229:	83 ec 2c             	sub    $0x2c,%esp
  80222c:	89 c7                	mov    %eax,%edi
  80222e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802231:	a1 08 40 80 00       	mov    0x804008,%eax
  802236:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802239:	89 3c 24             	mov    %edi,(%esp)
  80223c:	e8 e3 04 00 00       	call   802724 <pageref>
  802241:	89 c6                	mov    %eax,%esi
  802243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802246:	89 04 24             	mov    %eax,(%esp)
  802249:	e8 d6 04 00 00       	call   802724 <pageref>
  80224e:	39 c6                	cmp    %eax,%esi
  802250:	0f 94 c0             	sete   %al
  802253:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802256:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80225c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80225f:	39 cb                	cmp    %ecx,%ebx
  802261:	75 08                	jne    80226b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802263:	83 c4 2c             	add    $0x2c,%esp
  802266:	5b                   	pop    %ebx
  802267:	5e                   	pop    %esi
  802268:	5f                   	pop    %edi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80226b:	83 f8 01             	cmp    $0x1,%eax
  80226e:	75 c1                	jne    802231 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802270:	8b 42 58             	mov    0x58(%edx),%eax
  802273:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80227a:	00 
  80227b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80227f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802283:	c7 04 24 07 2f 80 00 	movl   $0x802f07,(%esp)
  80228a:	e8 21 e0 ff ff       	call   8002b0 <cprintf>
  80228f:	eb a0                	jmp    802231 <_pipeisclosed+0xe>

00802291 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	57                   	push   %edi
  802295:	56                   	push   %esi
  802296:	53                   	push   %ebx
  802297:	83 ec 1c             	sub    $0x1c,%esp
  80229a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80229d:	89 34 24             	mov    %esi,(%esp)
  8022a0:	e8 77 f1 ff ff       	call   80141c <fd2data>
  8022a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ac:	eb 3c                	jmp    8022ea <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022ae:	89 da                	mov    %ebx,%edx
  8022b0:	89 f0                	mov    %esi,%eax
  8022b2:	e8 6c ff ff ff       	call   802223 <_pipeisclosed>
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	75 38                	jne    8022f3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022bb:	e8 6e e9 ff ff       	call   800c2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022c0:	8b 43 04             	mov    0x4(%ebx),%eax
  8022c3:	8b 13                	mov    (%ebx),%edx
  8022c5:	83 c2 20             	add    $0x20,%edx
  8022c8:	39 d0                	cmp    %edx,%eax
  8022ca:	73 e2                	jae    8022ae <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022cf:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8022d2:	89 c2                	mov    %eax,%edx
  8022d4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8022da:	79 05                	jns    8022e1 <devpipe_write+0x50>
  8022dc:	4a                   	dec    %edx
  8022dd:	83 ca e0             	or     $0xffffffe0,%edx
  8022e0:	42                   	inc    %edx
  8022e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022e5:	40                   	inc    %eax
  8022e6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022e9:	47                   	inc    %edi
  8022ea:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022ed:	75 d1                	jne    8022c0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022ef:	89 f8                	mov    %edi,%eax
  8022f1:	eb 05                	jmp    8022f8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022f3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022f8:	83 c4 1c             	add    $0x1c,%esp
  8022fb:	5b                   	pop    %ebx
  8022fc:	5e                   	pop    %esi
  8022fd:	5f                   	pop    %edi
  8022fe:	5d                   	pop    %ebp
  8022ff:	c3                   	ret    

00802300 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	57                   	push   %edi
  802304:	56                   	push   %esi
  802305:	53                   	push   %ebx
  802306:	83 ec 1c             	sub    $0x1c,%esp
  802309:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80230c:	89 3c 24             	mov    %edi,(%esp)
  80230f:	e8 08 f1 ff ff       	call   80141c <fd2data>
  802314:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802316:	be 00 00 00 00       	mov    $0x0,%esi
  80231b:	eb 3a                	jmp    802357 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80231d:	85 f6                	test   %esi,%esi
  80231f:	74 04                	je     802325 <devpipe_read+0x25>
				return i;
  802321:	89 f0                	mov    %esi,%eax
  802323:	eb 40                	jmp    802365 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802325:	89 da                	mov    %ebx,%edx
  802327:	89 f8                	mov    %edi,%eax
  802329:	e8 f5 fe ff ff       	call   802223 <_pipeisclosed>
  80232e:	85 c0                	test   %eax,%eax
  802330:	75 2e                	jne    802360 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802332:	e8 f7 e8 ff ff       	call   800c2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802337:	8b 03                	mov    (%ebx),%eax
  802339:	3b 43 04             	cmp    0x4(%ebx),%eax
  80233c:	74 df                	je     80231d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80233e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802343:	79 05                	jns    80234a <devpipe_read+0x4a>
  802345:	48                   	dec    %eax
  802346:	83 c8 e0             	or     $0xffffffe0,%eax
  802349:	40                   	inc    %eax
  80234a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80234e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802351:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802354:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802356:	46                   	inc    %esi
  802357:	3b 75 10             	cmp    0x10(%ebp),%esi
  80235a:	75 db                	jne    802337 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80235c:	89 f0                	mov    %esi,%eax
  80235e:	eb 05                	jmp    802365 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802360:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802365:	83 c4 1c             	add    $0x1c,%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    

0080236d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80236d:	55                   	push   %ebp
  80236e:	89 e5                	mov    %esp,%ebp
  802370:	57                   	push   %edi
  802371:	56                   	push   %esi
  802372:	53                   	push   %ebx
  802373:	83 ec 3c             	sub    $0x3c,%esp
  802376:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802379:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80237c:	89 04 24             	mov    %eax,(%esp)
  80237f:	e8 b3 f0 ff ff       	call   801437 <fd_alloc>
  802384:	89 c3                	mov    %eax,%ebx
  802386:	85 c0                	test   %eax,%eax
  802388:	0f 88 45 01 00 00    	js     8024d3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80238e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802395:	00 
  802396:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80239d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a4:	e8 a4 e8 ff ff       	call   800c4d <sys_page_alloc>
  8023a9:	89 c3                	mov    %eax,%ebx
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	0f 88 20 01 00 00    	js     8024d3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023b3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8023b6:	89 04 24             	mov    %eax,(%esp)
  8023b9:	e8 79 f0 ff ff       	call   801437 <fd_alloc>
  8023be:	89 c3                	mov    %eax,%ebx
  8023c0:	85 c0                	test   %eax,%eax
  8023c2:	0f 88 f8 00 00 00    	js     8024c0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023cf:	00 
  8023d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023de:	e8 6a e8 ff ff       	call   800c4d <sys_page_alloc>
  8023e3:	89 c3                	mov    %eax,%ebx
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	0f 88 d3 00 00 00    	js     8024c0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023f0:	89 04 24             	mov    %eax,(%esp)
  8023f3:	e8 24 f0 ff ff       	call   80141c <fd2data>
  8023f8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023fa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802401:	00 
  802402:	89 44 24 04          	mov    %eax,0x4(%esp)
  802406:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80240d:	e8 3b e8 ff ff       	call   800c4d <sys_page_alloc>
  802412:	89 c3                	mov    %eax,%ebx
  802414:	85 c0                	test   %eax,%eax
  802416:	0f 88 91 00 00 00    	js     8024ad <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80241c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80241f:	89 04 24             	mov    %eax,(%esp)
  802422:	e8 f5 ef ff ff       	call   80141c <fd2data>
  802427:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80242e:	00 
  80242f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802433:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80243a:	00 
  80243b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80243f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802446:	e8 56 e8 ff ff       	call   800ca1 <sys_page_map>
  80244b:	89 c3                	mov    %eax,%ebx
  80244d:	85 c0                	test   %eax,%eax
  80244f:	78 4c                	js     80249d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802451:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80245a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80245c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80245f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802466:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80246c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80246f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802471:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802474:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80247b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80247e:	89 04 24             	mov    %eax,(%esp)
  802481:	e8 86 ef ff ff       	call   80140c <fd2num>
  802486:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802488:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80248b:	89 04 24             	mov    %eax,(%esp)
  80248e:	e8 79 ef ff ff       	call   80140c <fd2num>
  802493:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802496:	bb 00 00 00 00       	mov    $0x0,%ebx
  80249b:	eb 36                	jmp    8024d3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80249d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a8:	e8 47 e8 ff ff       	call   800cf4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8024ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024bb:	e8 34 e8 ff ff       	call   800cf4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8024c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024ce:	e8 21 e8 ff ff       	call   800cf4 <sys_page_unmap>
    err:
	return r;
}
  8024d3:	89 d8                	mov    %ebx,%eax
  8024d5:	83 c4 3c             	add    $0x3c,%esp
  8024d8:	5b                   	pop    %ebx
  8024d9:	5e                   	pop    %esi
  8024da:	5f                   	pop    %edi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    

008024dd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024dd:	55                   	push   %ebp
  8024de:	89 e5                	mov    %esp,%ebp
  8024e0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ed:	89 04 24             	mov    %eax,(%esp)
  8024f0:	e8 95 ef ff ff       	call   80148a <fd_lookup>
  8024f5:	85 c0                	test   %eax,%eax
  8024f7:	78 15                	js     80250e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024fc:	89 04 24             	mov    %eax,(%esp)
  8024ff:	e8 18 ef ff ff       	call   80141c <fd2data>
	return _pipeisclosed(fd, p);
  802504:	89 c2                	mov    %eax,%edx
  802506:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802509:	e8 15 fd ff ff       	call   802223 <_pipeisclosed>
}
  80250e:	c9                   	leave  
  80250f:	c3                   	ret    

00802510 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802513:	b8 00 00 00 00       	mov    $0x0,%eax
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    

0080251a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80251a:	55                   	push   %ebp
  80251b:	89 e5                	mov    %esp,%ebp
  80251d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802520:	c7 44 24 04 1f 2f 80 	movl   $0x802f1f,0x4(%esp)
  802527:	00 
  802528:	8b 45 0c             	mov    0xc(%ebp),%eax
  80252b:	89 04 24             	mov    %eax,(%esp)
  80252e:	e8 28 e3 ff ff       	call   80085b <strcpy>
	return 0;
}
  802533:	b8 00 00 00 00       	mov    $0x0,%eax
  802538:	c9                   	leave  
  802539:	c3                   	ret    

0080253a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80253a:	55                   	push   %ebp
  80253b:	89 e5                	mov    %esp,%ebp
  80253d:	57                   	push   %edi
  80253e:	56                   	push   %esi
  80253f:	53                   	push   %ebx
  802540:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802546:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80254b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802551:	eb 30                	jmp    802583 <devcons_write+0x49>
		m = n - tot;
  802553:	8b 75 10             	mov    0x10(%ebp),%esi
  802556:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802558:	83 fe 7f             	cmp    $0x7f,%esi
  80255b:	76 05                	jbe    802562 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80255d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802562:	89 74 24 08          	mov    %esi,0x8(%esp)
  802566:	03 45 0c             	add    0xc(%ebp),%eax
  802569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80256d:	89 3c 24             	mov    %edi,(%esp)
  802570:	e8 5f e4 ff ff       	call   8009d4 <memmove>
		sys_cputs(buf, m);
  802575:	89 74 24 04          	mov    %esi,0x4(%esp)
  802579:	89 3c 24             	mov    %edi,(%esp)
  80257c:	e8 ff e5 ff ff       	call   800b80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802581:	01 f3                	add    %esi,%ebx
  802583:	89 d8                	mov    %ebx,%eax
  802585:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802588:	72 c9                	jb     802553 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80258a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802590:	5b                   	pop    %ebx
  802591:	5e                   	pop    %esi
  802592:	5f                   	pop    %edi
  802593:	5d                   	pop    %ebp
  802594:	c3                   	ret    

00802595 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802595:	55                   	push   %ebp
  802596:	89 e5                	mov    %esp,%ebp
  802598:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80259b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80259f:	75 07                	jne    8025a8 <devcons_read+0x13>
  8025a1:	eb 25                	jmp    8025c8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025a3:	e8 86 e6 ff ff       	call   800c2e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025a8:	e8 f1 e5 ff ff       	call   800b9e <sys_cgetc>
  8025ad:	85 c0                	test   %eax,%eax
  8025af:	74 f2                	je     8025a3 <devcons_read+0xe>
  8025b1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8025b3:	85 c0                	test   %eax,%eax
  8025b5:	78 1d                	js     8025d4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025b7:	83 f8 04             	cmp    $0x4,%eax
  8025ba:	74 13                	je     8025cf <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8025bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025bf:	88 10                	mov    %dl,(%eax)
	return 1;
  8025c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c6:	eb 0c                	jmp    8025d4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8025c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8025cd:	eb 05                	jmp    8025d4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8025cf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8025d4:	c9                   	leave  
  8025d5:	c3                   	ret    

008025d6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8025d6:	55                   	push   %ebp
  8025d7:	89 e5                	mov    %esp,%ebp
  8025d9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8025dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8025df:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8025e9:	00 
  8025ea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025ed:	89 04 24             	mov    %eax,(%esp)
  8025f0:	e8 8b e5 ff ff       	call   800b80 <sys_cputs>
}
  8025f5:	c9                   	leave  
  8025f6:	c3                   	ret    

008025f7 <getchar>:

int
getchar(void)
{
  8025f7:	55                   	push   %ebp
  8025f8:	89 e5                	mov    %esp,%ebp
  8025fa:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802604:	00 
  802605:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802608:	89 44 24 04          	mov    %eax,0x4(%esp)
  80260c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802613:	e8 10 f1 ff ff       	call   801728 <read>
	if (r < 0)
  802618:	85 c0                	test   %eax,%eax
  80261a:	78 0f                	js     80262b <getchar+0x34>
		return r;
	if (r < 1)
  80261c:	85 c0                	test   %eax,%eax
  80261e:	7e 06                	jle    802626 <getchar+0x2f>
		return -E_EOF;
	return c;
  802620:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802624:	eb 05                	jmp    80262b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802626:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80262b:	c9                   	leave  
  80262c:	c3                   	ret    

0080262d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80262d:	55                   	push   %ebp
  80262e:	89 e5                	mov    %esp,%ebp
  802630:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802633:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80263a:	8b 45 08             	mov    0x8(%ebp),%eax
  80263d:	89 04 24             	mov    %eax,(%esp)
  802640:	e8 45 ee ff ff       	call   80148a <fd_lookup>
  802645:	85 c0                	test   %eax,%eax
  802647:	78 11                	js     80265a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802649:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802652:	39 10                	cmp    %edx,(%eax)
  802654:	0f 94 c0             	sete   %al
  802657:	0f b6 c0             	movzbl %al,%eax
}
  80265a:	c9                   	leave  
  80265b:	c3                   	ret    

0080265c <opencons>:

int
opencons(void)
{
  80265c:	55                   	push   %ebp
  80265d:	89 e5                	mov    %esp,%ebp
  80265f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802665:	89 04 24             	mov    %eax,(%esp)
  802668:	e8 ca ed ff ff       	call   801437 <fd_alloc>
  80266d:	85 c0                	test   %eax,%eax
  80266f:	78 3c                	js     8026ad <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802671:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802678:	00 
  802679:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80267c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802687:	e8 c1 e5 ff ff       	call   800c4d <sys_page_alloc>
  80268c:	85 c0                	test   %eax,%eax
  80268e:	78 1d                	js     8026ad <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802690:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802699:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80269b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026a5:	89 04 24             	mov    %eax,(%esp)
  8026a8:	e8 5f ed ff ff       	call   80140c <fd2num>
}
  8026ad:	c9                   	leave  
  8026ae:	c3                   	ret    
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
  8026d6:	e8 72 e5 ff ff       	call   800c4d <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8026db:	c7 44 24 04 fc 26 80 	movl   $0x8026fc,0x4(%esp)
  8026e2:	00 
  8026e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026ea:	e8 fe e6 ff ff       	call   800ded <sys_env_set_pgfault_upcall>
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
