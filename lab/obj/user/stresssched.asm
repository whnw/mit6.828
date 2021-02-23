
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 8e 0b 00 00       	call   800bcf <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 62 0f 00 00       	call   800faf <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 08                	je     800059 <umain+0x25>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  800051:	43                   	inc    %ebx
  800052:	83 fb 14             	cmp    $0x14,%ebx
  800055:	75 f1                	jne    800048 <umain+0x14>
  800057:	eb 05                	jmp    80005e <umain+0x2a>
		if (fork() == 0)
			break;
	if (i == 20) {
  800059:	83 fb 14             	cmp    $0x14,%ebx
  80005c:	75 0e                	jne    80006c <umain+0x38>
		sys_yield();
  80005e:	e8 8b 0b 00 00       	call   800bee <sys_yield>
		return;
  800063:	e9 97 00 00 00       	jmp    8000ff <umain+0xcb>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800068:	f3 90                	pause  
  80006a:	eb 1a                	jmp    800086 <umain+0x52>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800079:	89 f2                	mov    %esi,%edx
  80007b:	c1 e2 07             	shl    $0x7,%edx
  80007e:	29 c2                	sub    %eax,%edx
  800080:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  800086:	8b 42 50             	mov    0x50(%edx),%eax
  800089:	85 c0                	test   %eax,%eax
  80008b:	75 db                	jne    800068 <umain+0x34>
  80008d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800092:	e8 57 0b 00 00       	call   800bee <sys_yield>
  800097:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  80009c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8000a2:	42                   	inc    %edx
  8000a3:	89 15 08 40 80 00    	mov    %edx,0x804008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a9:	48                   	dec    %eax
  8000aa:	75 f0                	jne    80009c <umain+0x68>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000ac:	4b                   	dec    %ebx
  8000ad:	75 e3                	jne    800092 <umain+0x5e>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000af:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b9:	74 25                	je     8000e0 <umain+0xac>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000bb:	a1 08 40 80 00       	mov    0x804008,%eax
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 80 29 80 	movl   $0x802980,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 a8 29 80 00 	movl   $0x8029a8,(%esp)
  8000db:	e8 98 00 00 00       	call   800178 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e0:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000e5:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000e8:	8b 40 48             	mov    0x48(%eax),%eax
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  8000fa:	e8 71 01 00 00       	call   800270 <cprintf>

}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    
	...

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
  80010d:	83 ec 10             	sub    $0x10,%esp
  800110:	8b 75 08             	mov    0x8(%ebp),%esi
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800116:	e8 b4 0a 00 00       	call   800bcf <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800127:	c1 e0 07             	shl    $0x7,%eax
  80012a:	29 d0                	sub    %edx,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 0c 40 80 00       	mov    %eax,0x80400c


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 f6                	test   %esi,%esi
  800138:	7e 07                	jle    800141 <libmain+0x39>
		binaryname = argv[0];
  80013a:	8b 03                	mov    (%ebx),%eax
  80013c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800141:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800145:	89 34 24             	mov    %esi,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80014d:	e8 0a 00 00 00       	call   80015c <exit>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800162:	e8 14 13 00 00       	call   80147b <close_all>
	sys_env_destroy(0);
  800167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80016e:	e8 0a 0a 00 00       	call   800b7d <sys_env_destroy>
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    
  800175:	00 00                	add    %al,(%eax)
	...

00800178 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800180:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800183:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800189:	e8 41 0a 00 00       	call   800bcf <sys_getenvid>
  80018e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800191:	89 54 24 10          	mov    %edx,0x10(%esp)
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80019c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 e4 29 80 00 	movl   $0x8029e4,(%esp)
  8001ab:	e8 c0 00 00 00       	call   800270 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 50 00 00 00       	call   80020f <vcprintf>
	cprintf("\n");
  8001bf:	c7 04 24 d7 29 80 00 	movl   $0x8029d7,(%esp)
  8001c6:	e8 a5 00 00 00       	call   800270 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cb:	cc                   	int3   
  8001cc:	eb fd                	jmp    8001cb <_panic+0x53>
	...

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 14             	sub    $0x14,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 03                	mov    (%ebx),%eax
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e3:	40                   	inc    %eax
  8001e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001eb:	75 19                	jne    800206 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f4:	00 
  8001f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 40 09 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  800200:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800206:	ff 43 04             	incl   0x4(%ebx)
}
  800209:	83 c4 14             	add    $0x14,%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	c7 04 24 d0 01 80 00 	movl   $0x8001d0,(%esp)
  80024b:	e8 82 01 00 00       	call   8003d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 d8 08 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
}
  800268:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800276:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	e8 87 ff ff ff       	call   80020f <vcprintf>
	va_end(ap);

	return cnt;
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    
	...

0080028c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 3c             	sub    $0x3c,%esp
  800295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800298:	89 d7                	mov    %edx,%edi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ac:	85 c0                	test   %eax,%eax
  8002ae:	75 08                	jne    8002b8 <printnum+0x2c>
  8002b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b6:	77 57                	ja     80030f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002bc:	4b                   	dec    %ebx
  8002bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002cc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d7:	00 
  8002d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	e8 3e 24 00 00       	call   802728 <__udivdi3>
  8002ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f9:	89 fa                	mov    %edi,%edx
  8002fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fe:	e8 89 ff ff ff       	call   80028c <printnum>
  800303:	eb 0f                	jmp    800314 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800309:	89 34 24             	mov    %esi,(%esp)
  80030c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030f:	4b                   	dec    %ebx
  800310:	85 db                	test   %ebx,%ebx
  800312:	7f f1                	jg     800305 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800314:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800318:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032a:	00 
  80032b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032e:	89 04 24             	mov    %eax,(%esp)
  800331:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800334:	89 44 24 04          	mov    %eax,0x4(%esp)
  800338:	e8 0b 25 00 00       	call   802848 <__umoddi3>
  80033d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800341:	0f be 80 07 2a 80 00 	movsbl 0x802a07(%eax),%eax
  800348:	89 04 24             	mov    %eax,(%esp)
  80034b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80034e:	83 c4 3c             	add    $0x3c,%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800359:	83 fa 01             	cmp    $0x1,%edx
  80035c:	7e 0e                	jle    80036c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035e:	8b 10                	mov    (%eax),%edx
  800360:	8d 4a 08             	lea    0x8(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 02                	mov    (%edx),%eax
  800367:	8b 52 04             	mov    0x4(%edx),%edx
  80036a:	eb 22                	jmp    80038e <getuint+0x38>
	else if (lflag)
  80036c:	85 d2                	test   %edx,%edx
  80036e:	74 10                	je     800380 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	eb 0e                	jmp    80038e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 04             	lea    0x4(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800396:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	3b 50 04             	cmp    0x4(%eax),%edx
  80039e:	73 08                	jae    8003a8 <sprintputch+0x18>
		*b->buf++ = ch;
  8003a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a3:	88 0a                	mov    %cl,(%edx)
  8003a5:	42                   	inc    %edx
  8003a6:	89 10                	mov    %edx,(%eax)
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	e8 02 00 00 00       	call   8003d2 <vprintfmt>
	va_end(ap);
}
  8003d0:	c9                   	leave  
  8003d1:	c3                   	ret    

008003d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	57                   	push   %edi
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	83 ec 4c             	sub    $0x4c,%esp
  8003db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003de:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e1:	eb 12                	jmp    8003f5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	0f 84 6b 03 00 00    	je     800756 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f5:	0f b6 06             	movzbl (%esi),%eax
  8003f8:	46                   	inc    %esi
  8003f9:	83 f8 25             	cmp    $0x25,%eax
  8003fc:	75 e5                	jne    8003e3 <vprintfmt+0x11>
  8003fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800402:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800409:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80040e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041a:	eb 26                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800423:	eb 1d                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800428:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80042c:	eb 14                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800431:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800438:	eb 08                	jmp    800442 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80043d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	0f b6 06             	movzbl (%esi),%eax
  800445:	8d 56 01             	lea    0x1(%esi),%edx
  800448:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80044b:	8a 16                	mov    (%esi),%dl
  80044d:	83 ea 23             	sub    $0x23,%edx
  800450:	80 fa 55             	cmp    $0x55,%dl
  800453:	0f 87 e1 02 00 00    	ja     80073a <vprintfmt+0x368>
  800459:	0f b6 d2             	movzbl %dl,%edx
  80045c:	ff 24 95 40 2b 80 00 	jmp    *0x802b40(,%edx,4)
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800466:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80046e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800472:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800475:	8d 50 d0             	lea    -0x30(%eax),%edx
  800478:	83 fa 09             	cmp    $0x9,%edx
  80047b:	77 2a                	ja     8004a7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047e:	eb eb                	jmp    80046b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80048e:	eb 17                	jmp    8004a7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800490:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800494:	78 98                	js     80042e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800499:	eb a7                	jmp    800442 <vprintfmt+0x70>
  80049b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004a5:	eb 9b                	jmp    800442 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ab:	79 95                	jns    800442 <vprintfmt+0x70>
  8004ad:	eb 8b                	jmp    80043a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004af:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b3:	eb 8d                	jmp    800442 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004cd:	e9 23 ff ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	79 02                	jns    8004e3 <vprintfmt+0x111>
  8004e1:	f7 d8                	neg    %eax
  8004e3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e5:	83 f8 10             	cmp    $0x10,%eax
  8004e8:	7f 0b                	jg     8004f5 <vprintfmt+0x123>
  8004ea:	8b 04 85 a0 2c 80 00 	mov    0x802ca0(,%eax,4),%eax
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	75 23                	jne    800518 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f9:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800500:	00 
  800501:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800505:	8b 45 08             	mov    0x8(%ebp),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	e8 9a fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800513:	e9 dd fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800518:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051c:	c7 44 24 08 8d 2e 80 	movl   $0x802e8d,0x8(%esp)
  800523:	00 
  800524:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800528:	8b 55 08             	mov    0x8(%ebp),%edx
  80052b:	89 14 24             	mov    %edx,(%esp)
  80052e:	e8 77 fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800536:	e9 ba fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
  80053b:	89 f9                	mov    %edi,%ecx
  80053d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800540:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 30                	mov    (%eax),%esi
  80054e:	85 f6                	test   %esi,%esi
  800550:	75 05                	jne    800557 <vprintfmt+0x185>
				p = "(null)";
  800552:	be 18 2a 80 00       	mov    $0x802a18,%esi
			if (width > 0 && padc != '-')
  800557:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055b:	0f 8e 84 00 00 00    	jle    8005e5 <vprintfmt+0x213>
  800561:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800565:	74 7e                	je     8005e5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056b:	89 34 24             	mov    %esi,(%esp)
  80056e:	e8 8b 02 00 00       	call   8007fe <strnlen>
  800573:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800576:	29 c2                	sub    %eax,%edx
  800578:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80057b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80057f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800582:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800585:	89 de                	mov    %ebx,%esi
  800587:	89 d3                	mov    %edx,%ebx
  800589:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	eb 0b                	jmp    800598 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80058d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800591:	89 3c 24             	mov    %edi,(%esp)
  800594:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	4b                   	dec    %ebx
  800598:	85 db                	test   %ebx,%ebx
  80059a:	7f f1                	jg     80058d <vprintfmt+0x1bb>
  80059c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80059f:	89 f3                	mov    %esi,%ebx
  8005a1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	79 05                	jns    8005b0 <vprintfmt+0x1de>
  8005ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b3:	29 c2                	sub    %eax,%edx
  8005b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b8:	eb 2b                	jmp    8005e5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005be:	74 18                	je     8005d8 <vprintfmt+0x206>
  8005c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005c3:	83 fa 5e             	cmp    $0x5e,%edx
  8005c6:	76 10                	jbe    8005d8 <vprintfmt+0x206>
					putch('?', putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
  8005d6:	eb 0a                	jmp    8005e2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e5:	0f be 06             	movsbl (%esi),%eax
  8005e8:	46                   	inc    %esi
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	74 21                	je     80060e <vprintfmt+0x23c>
  8005ed:	85 ff                	test   %edi,%edi
  8005ef:	78 c9                	js     8005ba <vprintfmt+0x1e8>
  8005f1:	4f                   	dec    %edi
  8005f2:	79 c6                	jns    8005ba <vprintfmt+0x1e8>
  8005f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f7:	89 de                	mov    %ebx,%esi
  8005f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005fc:	eb 18                	jmp    800616 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800602:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800609:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	4b                   	dec    %ebx
  80060c:	eb 08                	jmp    800616 <vprintfmt+0x244>
  80060e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800611:	89 de                	mov    %ebx,%esi
  800613:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800616:	85 db                	test   %ebx,%ebx
  800618:	7f e4                	jg     8005fe <vprintfmt+0x22c>
  80061a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80061d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800622:	e9 ce fd ff ff       	jmp    8003f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 f9 01             	cmp    $0x1,%ecx
  80062a:	7e 10                	jle    80063c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 30                	mov    (%eax),%esi
  800637:	8b 78 04             	mov    0x4(%eax),%edi
  80063a:	eb 26                	jmp    800662 <vprintfmt+0x290>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	74 12                	je     800652 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 30                	mov    (%eax),%esi
  80064b:	89 f7                	mov    %esi,%edi
  80064d:	c1 ff 1f             	sar    $0x1f,%edi
  800650:	eb 10                	jmp    800662 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 30                	mov    (%eax),%esi
  80065d:	89 f7                	mov    %esi,%edi
  80065f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800662:	85 ff                	test   %edi,%edi
  800664:	78 0a                	js     800670 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 8c 00 00 00       	jmp    8006fc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80067e:	f7 de                	neg    %esi
  800680:	83 d7 00             	adc    $0x0,%edi
  800683:	f7 df                	neg    %edi
			}
			base = 10;
  800685:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068a:	eb 70                	jmp    8006fc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068c:	89 ca                	mov    %ecx,%edx
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 c0 fc ff ff       	call   800356 <getuint>
  800696:	89 c6                	mov    %eax,%esi
  800698:	89 d7                	mov    %edx,%edi
			base = 10;
  80069a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80069f:	eb 5b                	jmp    8006fc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8006a1:	89 ca                	mov    %ecx,%edx
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 ab fc ff ff       	call   800356 <getuint>
  8006ab:	89 c6                	mov    %eax,%esi
  8006ad:	89 d7                	mov    %edx,%edi
			base = 8;
  8006af:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006b4:	eb 46                	jmp    8006fc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ba:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006db:	8b 30                	mov    (%eax),%esi
  8006dd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e7:	eb 13                	jmp    8006fc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e9:	89 ca                	mov    %ecx,%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 63 fc ff ff       	call   800356 <getuint>
  8006f3:	89 c6                	mov    %eax,%esi
  8006f5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800700:	89 54 24 10          	mov    %edx,0x10(%esp)
  800704:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800707:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070f:	89 34 24             	mov    %esi,(%esp)
  800712:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800716:	89 da                	mov    %ebx,%edx
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	e8 6c fb ff ff       	call   80028c <printnum>
			break;
  800720:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800723:	e9 cd fc ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800728:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800735:	e9 bb fc ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800745:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800748:	eb 01                	jmp    80074b <vprintfmt+0x379>
  80074a:	4e                   	dec    %esi
  80074b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074f:	75 f9                	jne    80074a <vprintfmt+0x378>
  800751:	e9 9f fc ff ff       	jmp    8003f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800756:	83 c4 4c             	add    $0x4c,%esp
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	5f                   	pop    %edi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 28             	sub    $0x28,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 30                	je     8007af <vsnprintf+0x51>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 33                	jle    8007b6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078a:	8b 45 10             	mov    0x10(%ebp),%eax
  80078d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	c7 04 24 90 03 80 00 	movl   $0x800390,(%esp)
  80079f:	e8 2e fc ff ff       	call   8003d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ad:	eb 0c                	jmp    8007bb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b4:	eb 05                	jmp    8007bb <vsnprintf+0x5d>
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	89 04 24             	mov    %eax,(%esp)
  8007de:	e8 7b ff ff ff       	call   80075e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
  8007e5:	00 00                	add    %al,(%eax)
	...

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	eb 01                	jmp    8007f6 <strlen+0xe>
		n++;
  8007f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fa:	75 f9                	jne    8007f5 <strlen+0xd>
		n++;
	return n;
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	eb 01                	jmp    80080f <strnlen+0x11>
		n++;
  80080e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	39 d0                	cmp    %edx,%eax
  800811:	74 06                	je     800819 <strnlen+0x1b>
  800813:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800817:	75 f5                	jne    80080e <strnlen+0x10>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	ba 00 00 00 00       	mov    $0x0,%edx
  80082a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80082d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800830:	42                   	inc    %edx
  800831:	84 c9                	test   %cl,%cl
  800833:	75 f5                	jne    80082a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800835:	5b                   	pop    %ebx
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800842:	89 1c 24             	mov    %ebx,(%esp)
  800845:	e8 9e ff ff ff       	call   8007e8 <strlen>
	strcpy(dst + len, src);
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800851:	01 d8                	add    %ebx,%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 c0 ff ff ff       	call   80081b <strcpy>
	return dst;
}
  80085b:	89 d8                	mov    %ebx,%eax
  80085d:	83 c4 08             	add    $0x8,%esp
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800871:	b9 00 00 00 00       	mov    $0x0,%ecx
  800876:	eb 0c                	jmp    800884 <strncpy+0x21>
		*dst++ = *src;
  800878:	8a 1a                	mov    (%edx),%bl
  80087a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087d:	80 3a 01             	cmpb   $0x1,(%edx)
  800880:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800883:	41                   	inc    %ecx
  800884:	39 f1                	cmp    %esi,%ecx
  800886:	75 f0                	jne    800878 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	8b 75 08             	mov    0x8(%ebp),%esi
  800894:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800897:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089a:	85 d2                	test   %edx,%edx
  80089c:	75 0a                	jne    8008a8 <strlcpy+0x1c>
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	eb 1a                	jmp    8008bc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a2:	88 18                	mov    %bl,(%eax)
  8008a4:	40                   	inc    %eax
  8008a5:	41                   	inc    %ecx
  8008a6:	eb 02                	jmp    8008aa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008aa:	4a                   	dec    %edx
  8008ab:	74 0a                	je     8008b7 <strlcpy+0x2b>
  8008ad:	8a 19                	mov    (%ecx),%bl
  8008af:	84 db                	test   %bl,%bl
  8008b1:	75 ef                	jne    8008a2 <strlcpy+0x16>
  8008b3:	89 c2                	mov    %eax,%edx
  8008b5:	eb 02                	jmp    8008b9 <strlcpy+0x2d>
  8008b7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008bc:	29 f0                	sub    %esi,%eax
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cb:	eb 02                	jmp    8008cf <strcmp+0xd>
		p++, q++;
  8008cd:	41                   	inc    %ecx
  8008ce:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cf:	8a 01                	mov    (%ecx),%al
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x17>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 f4                	je     8008cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ed:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 03                	jmp    8008f5 <strncmp+0x12>
		n--, p++, q++;
  8008f2:	4a                   	dec    %edx
  8008f3:	40                   	inc    %eax
  8008f4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 14                	je     80090d <strncmp+0x2a>
  8008f9:	8a 18                	mov    (%eax),%bl
  8008fb:	84 db                	test   %bl,%bl
  8008fd:	74 04                	je     800903 <strncmp+0x20>
  8008ff:	3a 19                	cmp    (%ecx),%bl
  800901:	74 ef                	je     8008f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800903:	0f b6 00             	movzbl (%eax),%eax
  800906:	0f b6 11             	movzbl (%ecx),%edx
  800909:	29 d0                	sub    %edx,%eax
  80090b:	eb 05                	jmp    800912 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091e:	eb 05                	jmp    800925 <strchr+0x10>
		if (*s == c)
  800920:	38 ca                	cmp    %cl,%dl
  800922:	74 0c                	je     800930 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800924:	40                   	inc    %eax
  800925:	8a 10                	mov    (%eax),%dl
  800927:	84 d2                	test   %dl,%dl
  800929:	75 f5                	jne    800920 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093b:	eb 05                	jmp    800942 <strfind+0x10>
		if (*s == c)
  80093d:	38 ca                	cmp    %cl,%dl
  80093f:	74 07                	je     800948 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800941:	40                   	inc    %eax
  800942:	8a 10                	mov    (%eax),%dl
  800944:	84 d2                	test   %dl,%dl
  800946:	75 f5                	jne    80093d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 7d 08             	mov    0x8(%ebp),%edi
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800959:	85 c9                	test   %ecx,%ecx
  80095b:	74 30                	je     80098d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800963:	75 25                	jne    80098a <memset+0x40>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 20                	jne    80098a <memset+0x40>
		c &= 0xFF;
  80096a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d3                	mov    %edx,%ebx
  80096f:	c1 e3 08             	shl    $0x8,%ebx
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 18             	shl    $0x18,%esi
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 10             	shl    $0x10,%eax
  80097c:	09 f0                	or     %esi,%eax
  80097e:	09 d0                	or     %edx,%eax
  800980:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800982:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800985:	fc                   	cld    
  800986:	f3 ab                	rep stos %eax,%es:(%edi)
  800988:	eb 03                	jmp    80098d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098a:	fc                   	cld    
  80098b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098d:	89 f8                	mov    %edi,%eax
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a2:	39 c6                	cmp    %eax,%esi
  8009a4:	73 34                	jae    8009da <memmove+0x46>
  8009a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a9:	39 d0                	cmp    %edx,%eax
  8009ab:	73 2d                	jae    8009da <memmove+0x46>
		s += n;
		d += n;
  8009ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	f6 c2 03             	test   $0x3,%dl
  8009b3:	75 1b                	jne    8009d0 <memmove+0x3c>
  8009b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bb:	75 13                	jne    8009d0 <memmove+0x3c>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 0e                	jne    8009d0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c2:	83 ef 04             	sub    $0x4,%edi
  8009c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009cb:	fd                   	std    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 07                	jmp    8009d7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d0:	4f                   	dec    %edi
  8009d1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d4:	fd                   	std    
  8009d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d7:	fc                   	cld    
  8009d8:	eb 20                	jmp    8009fa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e0:	75 13                	jne    8009f5 <memmove+0x61>
  8009e2:	a8 03                	test   $0x3,%al
  8009e4:	75 0f                	jne    8009f5 <memmove+0x61>
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 0a                	jne    8009f5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ee:	89 c7                	mov    %eax,%edi
  8009f0:	fc                   	cld    
  8009f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f3:	eb 05                	jmp    8009fa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a04:	8b 45 10             	mov    0x10(%ebp),%eax
  800a07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 04 24             	mov    %eax,(%esp)
  800a18:	e8 77 ff ff ff       	call   800994 <memmove>
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a33:	eb 16                	jmp    800a4b <memcmp+0x2c>
		if (*s1 != *s2)
  800a35:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a38:	42                   	inc    %edx
  800a39:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a3d:	38 c8                	cmp    %cl,%al
  800a3f:	74 0a                	je     800a4b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a41:	0f b6 c0             	movzbl %al,%eax
  800a44:	0f b6 c9             	movzbl %cl,%ecx
  800a47:	29 c8                	sub    %ecx,%eax
  800a49:	eb 09                	jmp    800a54 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4b:	39 da                	cmp    %ebx,%edx
  800a4d:	75 e6                	jne    800a35 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a62:	89 c2                	mov    %eax,%edx
  800a64:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a67:	eb 05                	jmp    800a6e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	38 08                	cmp    %cl,(%eax)
  800a6b:	74 05                	je     800a72 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6d:	40                   	inc    %eax
  800a6e:	39 d0                	cmp    %edx,%eax
  800a70:	72 f7                	jb     800a69 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a80:	eb 01                	jmp    800a83 <strtol+0xf>
		s++;
  800a82:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a83:	8a 02                	mov    (%edx),%al
  800a85:	3c 20                	cmp    $0x20,%al
  800a87:	74 f9                	je     800a82 <strtol+0xe>
  800a89:	3c 09                	cmp    $0x9,%al
  800a8b:	74 f5                	je     800a82 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8d:	3c 2b                	cmp    $0x2b,%al
  800a8f:	75 08                	jne    800a99 <strtol+0x25>
		s++;
  800a91:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a92:	bf 00 00 00 00       	mov    $0x0,%edi
  800a97:	eb 13                	jmp    800aac <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a99:	3c 2d                	cmp    $0x2d,%al
  800a9b:	75 0a                	jne    800aa7 <strtol+0x33>
		s++, neg = 1;
  800a9d:	8d 52 01             	lea    0x1(%edx),%edx
  800aa0:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa5:	eb 05                	jmp    800aac <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	74 05                	je     800ab5 <strtol+0x41>
  800ab0:	83 fb 10             	cmp    $0x10,%ebx
  800ab3:	75 28                	jne    800add <strtol+0x69>
  800ab5:	8a 02                	mov    (%edx),%al
  800ab7:	3c 30                	cmp    $0x30,%al
  800ab9:	75 10                	jne    800acb <strtol+0x57>
  800abb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abf:	75 0a                	jne    800acb <strtol+0x57>
		s += 2, base = 16;
  800ac1:	83 c2 02             	add    $0x2,%edx
  800ac4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac9:	eb 12                	jmp    800add <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	75 0e                	jne    800add <strtol+0x69>
  800acf:	3c 30                	cmp    $0x30,%al
  800ad1:	75 05                	jne    800ad8 <strtol+0x64>
		s++, base = 8;
  800ad3:	42                   	inc    %edx
  800ad4:	b3 08                	mov    $0x8,%bl
  800ad6:	eb 05                	jmp    800add <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae4:	8a 0a                	mov    (%edx),%cl
  800ae6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae9:	80 fb 09             	cmp    $0x9,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x82>
			dig = *s - '0';
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 30             	sub    $0x30,%ecx
  800af4:	eb 1e                	jmp    800b14 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 08                	ja     800b06 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afe:	0f be c9             	movsbl %cl,%ecx
  800b01:	83 e9 57             	sub    $0x57,%ecx
  800b04:	eb 0e                	jmp    800b14 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b06:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 12                	ja     800b20 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b0e:	0f be c9             	movsbl %cl,%ecx
  800b11:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b14:	39 f1                	cmp    %esi,%ecx
  800b16:	7d 0c                	jge    800b24 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b18:	42                   	inc    %edx
  800b19:	0f af c6             	imul   %esi,%eax
  800b1c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b1e:	eb c4                	jmp    800ae4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b20:	89 c1                	mov    %eax,%ecx
  800b22:	eb 02                	jmp    800b26 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b24:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2a:	74 05                	je     800b31 <strtol+0xbd>
		*endptr = (char *) s;
  800b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b31:	85 ff                	test   %edi,%edi
  800b33:	74 04                	je     800b39 <strtol+0xc5>
  800b35:	89 c8                	mov    %ecx,%eax
  800b37:	f7 d8                	neg    %eax
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    
	...

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 cb                	mov    %ecx,%ebx
  800b95:	89 cf                	mov    %ecx,%edi
  800b97:	89 ce                	mov    %ecx,%esi
  800b99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 28                	jle    800bc7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800baa:	00 
  800bab:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bba:	00 
  800bbb:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800bc2:	e8 b1 f5 ff ff       	call   800178 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc7:	83 c4 2c             	add    $0x2c,%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bda:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdf:	89 d1                	mov    %edx,%ecx
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	89 d7                	mov    %edx,%edi
  800be5:	89 d6                	mov    %edx,%esi
  800be7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_yield>:

void
sys_yield(void)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfe:	89 d1                	mov    %edx,%ecx
  800c00:	89 d3                	mov    %edx,%ebx
  800c02:	89 d7                	mov    %edx,%edi
  800c04:	89 d6                	mov    %edx,%esi
  800c06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	be 00 00 00 00       	mov    $0x0,%esi
  800c1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 f7                	mov    %esi,%edi
  800c2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	7e 28                	jle    800c59 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c35:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c3c:	00 
  800c3d:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800c44:	00 
  800c45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4c:	00 
  800c4d:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800c54:	e8 1f f5 ff ff       	call   800178 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c59:	83 c4 2c             	add    $0x2c,%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 28                	jle    800cac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c8f:	00 
  800c90:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800c97:	00 
  800c98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9f:	00 
  800ca0:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800ca7:	e8 cc f4 ff ff       	call   800178 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cac:	83 c4 2c             	add    $0x2c,%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800cfa:	e8 79 f4 ff ff       	call   800178 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800d4d:	e8 26 f4 ff ff       	call   800178 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d52:	83 c4 2c             	add    $0x2c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800da0:	e8 d3 f3 ff ff       	call   800178 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 28                	jle    800df8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800df3:	e8 80 f3 ff ff       	call   800178 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df8:	83 c4 2c             	add    $0x2c,%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	be 00 00 00 00       	mov    $0x0,%esi
  800e0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 cb                	mov    %ecx,%ebx
  800e3b:	89 cf                	mov    %ecx,%edi
  800e3d:	89 ce                	mov    %ecx,%esi
  800e3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7e 28                	jle    800e6d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e49:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e50:	00 
  800e51:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800e58:	00 
  800e59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e60:	00 
  800e61:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800e68:	e8 0b f3 ff ff       	call   800178 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6d:	83 c4 2c             	add    $0x2c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e85:	89 d1                	mov    %edx,%ecx
  800e87:	89 d3                	mov    %edx,%ebx
  800e89:	89 d7                	mov    %edx,%edi
  800e8b:	89 d6                	mov    %edx,%esi
  800e8d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ea4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	89 df                	mov    %ebx,%edi
  800eac:	89 de                	mov    %ebx,%esi
  800eae:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
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
  800ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec0:	b8 10 00 00 00       	mov    $0x10,%eax
  800ec5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	89 df                	mov    %ebx,%edi
  800ecd:	89 de                	mov    %ebx,%esi
  800ecf:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    
	...

00800ed8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	53                   	push   %ebx
  800edc:	83 ec 24             	sub    $0x24,%esp
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ee2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800ee4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee8:	74 2d                	je     800f17 <pgfault+0x3f>
  800eea:	89 d8                	mov    %ebx,%eax
  800eec:	c1 e8 16             	shr    $0x16,%eax
  800eef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef6:	a8 01                	test   $0x1,%al
  800ef8:	74 1d                	je     800f17 <pgfault+0x3f>
  800efa:	89 d8                	mov    %ebx,%eax
  800efc:	c1 e8 0c             	shr    $0xc,%eax
  800eff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f06:	f6 c2 01             	test   $0x1,%dl
  800f09:	74 0c                	je     800f17 <pgfault+0x3f>
  800f0b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f12:	f6 c4 08             	test   $0x8,%ah
  800f15:	75 1c                	jne    800f33 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  800f17:	c7 44 24 08 30 2d 80 	movl   $0x802d30,0x8(%esp)
  800f1e:	00 
  800f1f:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f26:	00 
  800f27:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  800f2e:	e8 45 f2 ff ff       	call   800178 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  800f33:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f39:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f40:	00 
  800f41:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f48:	00 
  800f49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f50:	e8 b8 fc ff ff       	call   800c0d <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  800f55:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f5c:	00 
  800f5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f61:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f68:	e8 91 fa ff ff       	call   8009fe <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  800f6d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f74:	00 
  800f75:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f90:	e8 cc fc ff ff       	call   800c61 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  800f95:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f9c:	00 
  800f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa4:	e8 0b fd ff ff       	call   800cb4 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  800fa9:	83 c4 24             	add    $0x24,%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	53                   	push   %ebx
  800fb5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fb8:	c7 04 24 d8 0e 80 00 	movl   $0x800ed8,(%esp)
  800fbf:	e8 74 15 00 00       	call   802538 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fc4:	ba 07 00 00 00       	mov    $0x7,%edx
  800fc9:	89 d0                	mov    %edx,%eax
  800fcb:	cd 30                	int    $0x30
  800fcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fd0:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	79 20                	jns    800ff6 <fork+0x47>
		panic("sys_exofork: %e", envid);
  800fd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fda:	c7 44 24 08 7e 2d 80 	movl   $0x802d7e,0x8(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800fe9:	00 
  800fea:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  800ff1:	e8 82 f1 ff ff       	call   800178 <_panic>
	if (envid == 0)
  800ff6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ffa:	75 25                	jne    801021 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800ffc:	e8 ce fb ff ff       	call   800bcf <sys_getenvid>
  801001:	25 ff 03 00 00       	and    $0x3ff,%eax
  801006:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80100d:	c1 e0 07             	shl    $0x7,%eax
  801010:	29 d0                	sub    %edx,%eax
  801012:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801017:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  80101c:	e9 43 02 00 00       	jmp    801264 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  801021:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  801026:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80102c:	0f 84 85 01 00 00    	je     8011b7 <fork+0x208>
  801032:	89 d8                	mov    %ebx,%eax
  801034:	c1 e8 16             	shr    $0x16,%eax
  801037:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103e:	a8 01                	test   $0x1,%al
  801040:	0f 84 5f 01 00 00    	je     8011a5 <fork+0x1f6>
  801046:	89 d8                	mov    %ebx,%eax
  801048:	c1 e8 0c             	shr    $0xc,%eax
  80104b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801052:	f6 c2 01             	test   $0x1,%dl
  801055:	0f 84 4a 01 00 00    	je     8011a5 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  80105b:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  80105d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801064:	f6 c6 04             	test   $0x4,%dh
  801067:	74 50                	je     8010b9 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  801069:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801070:	25 07 0e 00 00       	and    $0xe07,%eax
  801075:	89 44 24 10          	mov    %eax,0x10(%esp)
  801079:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80107d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801081:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801085:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108c:	e8 d0 fb ff ff       	call   800c61 <sys_page_map>
  801091:	85 c0                	test   %eax,%eax
  801093:	0f 89 0c 01 00 00    	jns    8011a5 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  801099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80109d:	c7 44 24 08 8e 2d 80 	movl   $0x802d8e,0x8(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8010ac:	00 
  8010ad:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  8010b4:	e8 bf f0 ff ff       	call   800178 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  8010b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c0:	f6 c2 02             	test   $0x2,%dl
  8010c3:	75 10                	jne    8010d5 <fork+0x126>
  8010c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cc:	f6 c4 08             	test   $0x8,%ah
  8010cf:	0f 84 8c 00 00 00    	je     801161 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  8010d5:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010dc:	00 
  8010dd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010e1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f0:	e8 6c fb ff ff       	call   800c61 <sys_page_map>
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	79 20                	jns    801119 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  8010f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010fd:	c7 44 24 08 8e 2d 80 	movl   $0x802d8e,0x8(%esp)
  801104:	00 
  801105:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80110c:	00 
  80110d:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  801114:	e8 5f f0 ff ff       	call   800178 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801119:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801120:	00 
  801121:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801125:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80112c:	00 
  80112d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801138:	e8 24 fb ff ff       	call   800c61 <sys_page_map>
  80113d:	85 c0                	test   %eax,%eax
  80113f:	79 64                	jns    8011a5 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801141:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801145:	c7 44 24 08 8e 2d 80 	movl   $0x802d8e,0x8(%esp)
  80114c:	00 
  80114d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801154:	00 
  801155:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  80115c:	e8 17 f0 ff ff       	call   800178 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  801161:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801168:	00 
  801169:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80116d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801171:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801175:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117c:	e8 e0 fa ff ff       	call   800c61 <sys_page_map>
  801181:	85 c0                	test   %eax,%eax
  801183:	79 20                	jns    8011a5 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801185:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801189:	c7 44 24 08 8e 2d 80 	movl   $0x802d8e,0x8(%esp)
  801190:	00 
  801191:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801198:	00 
  801199:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  8011a0:	e8 d3 ef ff ff       	call   800178 <_panic>
  8011a5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  8011ab:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8011b1:	0f 85 6f fe ff ff    	jne    801026 <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  8011b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011be:	00 
  8011bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011c6:	ee 
  8011c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ca:	89 04 24             	mov    %eax,(%esp)
  8011cd:	e8 3b fa ff ff       	call   800c0d <sys_page_alloc>
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	79 20                	jns    8011f6 <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  8011d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011da:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  8011e1:	00 
  8011e2:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  8011e9:	00 
  8011ea:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  8011f1:	e8 82 ef ff ff       	call   800178 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8011f6:	c7 44 24 04 84 25 80 	movl   $0x802584,0x4(%esp)
  8011fd:	00 
  8011fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801201:	89 04 24             	mov    %eax,(%esp)
  801204:	e8 a4 fb ff ff       	call   800dad <sys_env_set_pgfault_upcall>
  801209:	85 c0                	test   %eax,%eax
  80120b:	79 20                	jns    80122d <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  80120d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801211:	c7 44 24 08 54 2d 80 	movl   $0x802d54,0x8(%esp)
  801218:	00 
  801219:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801220:	00 
  801221:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  801228:	e8 4b ef ff ff       	call   800178 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80122d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801234:	00 
  801235:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801238:	89 04 24             	mov    %eax,(%esp)
  80123b:	e8 c7 fa ff ff       	call   800d07 <sys_env_set_status>
  801240:	85 c0                	test   %eax,%eax
  801242:	79 20                	jns    801264 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801244:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801248:	c7 44 24 08 b3 2d 80 	movl   $0x802db3,0x8(%esp)
  80124f:	00 
  801250:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801257:	00 
  801258:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  80125f:	e8 14 ef ff ff       	call   800178 <_panic>

	return envid;
	// panic("fork not implemented");
}
  801264:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801267:	83 c4 3c             	add    $0x3c,%esp
  80126a:	5b                   	pop    %ebx
  80126b:	5e                   	pop    %esi
  80126c:	5f                   	pop    %edi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <sfork>:

// Challenge!
int
sfork(void)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801275:	c7 44 24 08 ca 2d 80 	movl   $0x802dca,0x8(%esp)
  80127c:	00 
  80127d:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801284:	00 
  801285:	c7 04 24 73 2d 80 00 	movl   $0x802d73,(%esp)
  80128c:	e8 e7 ee ff ff       	call   800178 <_panic>
  801291:	00 00                	add    %al,(%eax)
	...

00801294 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801297:	8b 45 08             	mov    0x8(%ebp),%eax
  80129a:	05 00 00 00 30       	add    $0x30000000,%eax
  80129f:	c1 e8 0c             	shr    $0xc,%eax
}
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    

008012a4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	89 04 24             	mov    %eax,(%esp)
  8012b0:	e8 df ff ff ff       	call   801294 <fd2num>
  8012b5:	c1 e0 0c             	shl    $0xc,%eax
  8012b8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012c6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012cb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012cd:	89 c2                	mov    %eax,%edx
  8012cf:	c1 ea 16             	shr    $0x16,%edx
  8012d2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d9:	f6 c2 01             	test   $0x1,%dl
  8012dc:	74 11                	je     8012ef <fd_alloc+0x30>
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	c1 ea 0c             	shr    $0xc,%edx
  8012e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ea:	f6 c2 01             	test   $0x1,%dl
  8012ed:	75 09                	jne    8012f8 <fd_alloc+0x39>
			*fd_store = fd;
  8012ef:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f6:	eb 17                	jmp    80130f <fd_alloc+0x50>
  8012f8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012fd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801302:	75 c7                	jne    8012cb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801304:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80130a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80130f:	5b                   	pop    %ebx
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    

00801312 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801318:	83 f8 1f             	cmp    $0x1f,%eax
  80131b:	77 36                	ja     801353 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80131d:	c1 e0 0c             	shl    $0xc,%eax
  801320:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801325:	89 c2                	mov    %eax,%edx
  801327:	c1 ea 16             	shr    $0x16,%edx
  80132a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801331:	f6 c2 01             	test   $0x1,%dl
  801334:	74 24                	je     80135a <fd_lookup+0x48>
  801336:	89 c2                	mov    %eax,%edx
  801338:	c1 ea 0c             	shr    $0xc,%edx
  80133b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801342:	f6 c2 01             	test   $0x1,%dl
  801345:	74 1a                	je     801361 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801347:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134a:	89 02                	mov    %eax,(%edx)
	return 0;
  80134c:	b8 00 00 00 00       	mov    $0x0,%eax
  801351:	eb 13                	jmp    801366 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801353:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801358:	eb 0c                	jmp    801366 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80135a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135f:	eb 05                	jmp    801366 <fd_lookup+0x54>
  801361:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    

00801368 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	53                   	push   %ebx
  80136c:	83 ec 14             	sub    $0x14,%esp
  80136f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801372:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801375:	ba 00 00 00 00       	mov    $0x0,%edx
  80137a:	eb 0e                	jmp    80138a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80137c:	39 08                	cmp    %ecx,(%eax)
  80137e:	75 09                	jne    801389 <dev_lookup+0x21>
			*dev = devtab[i];
  801380:	89 03                	mov    %eax,(%ebx)
			return 0;
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
  801387:	eb 33                	jmp    8013bc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801389:	42                   	inc    %edx
  80138a:	8b 04 95 60 2e 80 00 	mov    0x802e60(,%edx,4),%eax
  801391:	85 c0                	test   %eax,%eax
  801393:	75 e7                	jne    80137c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801395:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80139a:	8b 40 48             	mov    0x48(%eax),%eax
  80139d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a5:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  8013ac:	e8 bf ee ff ff       	call   800270 <cprintf>
	*dev = 0;
  8013b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013bc:	83 c4 14             	add    $0x14,%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	56                   	push   %esi
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 30             	sub    $0x30,%esp
  8013ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8013cd:	8a 45 0c             	mov    0xc(%ebp),%al
  8013d0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d3:	89 34 24             	mov    %esi,(%esp)
  8013d6:	e8 b9 fe ff ff       	call   801294 <fd2num>
  8013db:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013e2:	89 04 24             	mov    %eax,(%esp)
  8013e5:	e8 28 ff ff ff       	call   801312 <fd_lookup>
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 05                	js     8013f5 <fd_close+0x33>
	    || fd != fd2)
  8013f0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013f3:	74 0d                	je     801402 <fd_close+0x40>
		return (must_exist ? r : 0);
  8013f5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013f9:	75 46                	jne    801441 <fd_close+0x7f>
  8013fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801400:	eb 3f                	jmp    801441 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801402:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801405:	89 44 24 04          	mov    %eax,0x4(%esp)
  801409:	8b 06                	mov    (%esi),%eax
  80140b:	89 04 24             	mov    %eax,(%esp)
  80140e:	e8 55 ff ff ff       	call   801368 <dev_lookup>
  801413:	89 c3                	mov    %eax,%ebx
  801415:	85 c0                	test   %eax,%eax
  801417:	78 18                	js     801431 <fd_close+0x6f>
		if (dev->dev_close)
  801419:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141c:	8b 40 10             	mov    0x10(%eax),%eax
  80141f:	85 c0                	test   %eax,%eax
  801421:	74 09                	je     80142c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801423:	89 34 24             	mov    %esi,(%esp)
  801426:	ff d0                	call   *%eax
  801428:	89 c3                	mov    %eax,%ebx
  80142a:	eb 05                	jmp    801431 <fd_close+0x6f>
		else
			r = 0;
  80142c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801431:	89 74 24 04          	mov    %esi,0x4(%esp)
  801435:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80143c:	e8 73 f8 ff ff       	call   800cb4 <sys_page_unmap>
	return r;
}
  801441:	89 d8                	mov    %ebx,%eax
  801443:	83 c4 30             	add    $0x30,%esp
  801446:	5b                   	pop    %ebx
  801447:	5e                   	pop    %esi
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    

0080144a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801450:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801453:	89 44 24 04          	mov    %eax,0x4(%esp)
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
  80145a:	89 04 24             	mov    %eax,(%esp)
  80145d:	e8 b0 fe ff ff       	call   801312 <fd_lookup>
  801462:	85 c0                	test   %eax,%eax
  801464:	78 13                	js     801479 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801466:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80146d:	00 
  80146e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801471:	89 04 24             	mov    %eax,(%esp)
  801474:	e8 49 ff ff ff       	call   8013c2 <fd_close>
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <close_all>:

void
close_all(void)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	53                   	push   %ebx
  80147f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801482:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801487:	89 1c 24             	mov    %ebx,(%esp)
  80148a:	e8 bb ff ff ff       	call   80144a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80148f:	43                   	inc    %ebx
  801490:	83 fb 20             	cmp    $0x20,%ebx
  801493:	75 f2                	jne    801487 <close_all+0xc>
		close(i);
}
  801495:	83 c4 14             	add    $0x14,%esp
  801498:	5b                   	pop    %ebx
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	57                   	push   %edi
  80149f:	56                   	push   %esi
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 4c             	sub    $0x4c,%esp
  8014a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b1:	89 04 24             	mov    %eax,(%esp)
  8014b4:	e8 59 fe ff ff       	call   801312 <fd_lookup>
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	0f 88 e3 00 00 00    	js     8015a6 <dup+0x10b>
		return r;
	close(newfdnum);
  8014c3:	89 3c 24             	mov    %edi,(%esp)
  8014c6:	e8 7f ff ff ff       	call   80144a <close>

	newfd = INDEX2FD(newfdnum);
  8014cb:	89 fe                	mov    %edi,%esi
  8014cd:	c1 e6 0c             	shl    $0xc,%esi
  8014d0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d9:	89 04 24             	mov    %eax,(%esp)
  8014dc:	e8 c3 fd ff ff       	call   8012a4 <fd2data>
  8014e1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014e3:	89 34 24             	mov    %esi,(%esp)
  8014e6:	e8 b9 fd ff ff       	call   8012a4 <fd2data>
  8014eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ee:	89 d8                	mov    %ebx,%eax
  8014f0:	c1 e8 16             	shr    $0x16,%eax
  8014f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014fa:	a8 01                	test   $0x1,%al
  8014fc:	74 46                	je     801544 <dup+0xa9>
  8014fe:	89 d8                	mov    %ebx,%eax
  801500:	c1 e8 0c             	shr    $0xc,%eax
  801503:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80150a:	f6 c2 01             	test   $0x1,%dl
  80150d:	74 35                	je     801544 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80150f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801516:	25 07 0e 00 00       	and    $0xe07,%eax
  80151b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80151f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801522:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801526:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80152d:	00 
  80152e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801532:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801539:	e8 23 f7 ff ff       	call   800c61 <sys_page_map>
  80153e:	89 c3                	mov    %eax,%ebx
  801540:	85 c0                	test   %eax,%eax
  801542:	78 3b                	js     80157f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801547:	89 c2                	mov    %eax,%edx
  801549:	c1 ea 0c             	shr    $0xc,%edx
  80154c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801553:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801559:	89 54 24 10          	mov    %edx,0x10(%esp)
  80155d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801561:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801568:	00 
  801569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801574:	e8 e8 f6 ff ff       	call   800c61 <sys_page_map>
  801579:	89 c3                	mov    %eax,%ebx
  80157b:	85 c0                	test   %eax,%eax
  80157d:	79 25                	jns    8015a4 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80157f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801583:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80158a:	e8 25 f7 ff ff       	call   800cb4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80158f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801592:	89 44 24 04          	mov    %eax,0x4(%esp)
  801596:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80159d:	e8 12 f7 ff ff       	call   800cb4 <sys_page_unmap>
	return r;
  8015a2:	eb 02                	jmp    8015a6 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015a4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015a6:	89 d8                	mov    %ebx,%eax
  8015a8:	83 c4 4c             	add    $0x4c,%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5e                   	pop    %esi
  8015ad:	5f                   	pop    %edi
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    

008015b0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 24             	sub    $0x24,%esp
  8015b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	89 1c 24             	mov    %ebx,(%esp)
  8015c4:	e8 49 fd ff ff       	call   801312 <fd_lookup>
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 6d                	js     80163a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d7:	8b 00                	mov    (%eax),%eax
  8015d9:	89 04 24             	mov    %eax,(%esp)
  8015dc:	e8 87 fd ff ff       	call   801368 <dev_lookup>
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 55                	js     80163a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e8:	8b 50 08             	mov    0x8(%eax),%edx
  8015eb:	83 e2 03             	and    $0x3,%edx
  8015ee:	83 fa 01             	cmp    $0x1,%edx
  8015f1:	75 23                	jne    801616 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f3:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015f8:	8b 40 48             	mov    0x48(%eax),%eax
  8015fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801603:	c7 04 24 24 2e 80 00 	movl   $0x802e24,(%esp)
  80160a:	e8 61 ec ff ff       	call   800270 <cprintf>
		return -E_INVAL;
  80160f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801614:	eb 24                	jmp    80163a <read+0x8a>
	}
	if (!dev->dev_read)
  801616:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801619:	8b 52 08             	mov    0x8(%edx),%edx
  80161c:	85 d2                	test   %edx,%edx
  80161e:	74 15                	je     801635 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801620:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801623:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801627:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80162e:	89 04 24             	mov    %eax,(%esp)
  801631:	ff d2                	call   *%edx
  801633:	eb 05                	jmp    80163a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801635:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80163a:	83 c4 24             	add    $0x24,%esp
  80163d:	5b                   	pop    %ebx
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	57                   	push   %edi
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
  801646:	83 ec 1c             	sub    $0x1c,%esp
  801649:	8b 7d 08             	mov    0x8(%ebp),%edi
  80164c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801654:	eb 23                	jmp    801679 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801656:	89 f0                	mov    %esi,%eax
  801658:	29 d8                	sub    %ebx,%eax
  80165a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80165e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801661:	01 d8                	add    %ebx,%eax
  801663:	89 44 24 04          	mov    %eax,0x4(%esp)
  801667:	89 3c 24             	mov    %edi,(%esp)
  80166a:	e8 41 ff ff ff       	call   8015b0 <read>
		if (m < 0)
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 10                	js     801683 <readn+0x43>
			return m;
		if (m == 0)
  801673:	85 c0                	test   %eax,%eax
  801675:	74 0a                	je     801681 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801677:	01 c3                	add    %eax,%ebx
  801679:	39 f3                	cmp    %esi,%ebx
  80167b:	72 d9                	jb     801656 <readn+0x16>
  80167d:	89 d8                	mov    %ebx,%eax
  80167f:	eb 02                	jmp    801683 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801681:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801683:	83 c4 1c             	add    $0x1c,%esp
  801686:	5b                   	pop    %ebx
  801687:	5e                   	pop    %esi
  801688:	5f                   	pop    %edi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	83 ec 24             	sub    $0x24,%esp
  801692:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801695:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169c:	89 1c 24             	mov    %ebx,(%esp)
  80169f:	e8 6e fc ff ff       	call   801312 <fd_lookup>
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 68                	js     801710 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b2:	8b 00                	mov    (%eax),%eax
  8016b4:	89 04 24             	mov    %eax,(%esp)
  8016b7:	e8 ac fc ff ff       	call   801368 <dev_lookup>
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 50                	js     801710 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c7:	75 23                	jne    8016ec <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8016ce:	8b 40 48             	mov    0x48(%eax),%eax
  8016d1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d9:	c7 04 24 40 2e 80 00 	movl   $0x802e40,(%esp)
  8016e0:	e8 8b eb ff ff       	call   800270 <cprintf>
		return -E_INVAL;
  8016e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ea:	eb 24                	jmp    801710 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ef:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f2:	85 d2                	test   %edx,%edx
  8016f4:	74 15                	je     80170b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801700:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801704:	89 04 24             	mov    %eax,(%esp)
  801707:	ff d2                	call   *%edx
  801709:	eb 05                	jmp    801710 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80170b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801710:	83 c4 24             	add    $0x24,%esp
  801713:	5b                   	pop    %ebx
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <seek>:

int
seek(int fdnum, off_t offset)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801723:	8b 45 08             	mov    0x8(%ebp),%eax
  801726:	89 04 24             	mov    %eax,(%esp)
  801729:	e8 e4 fb ff ff       	call   801312 <fd_lookup>
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 0e                	js     801740 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801732:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801735:	8b 55 0c             	mov    0xc(%ebp),%edx
  801738:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80173b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	83 ec 24             	sub    $0x24,%esp
  801749:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801753:	89 1c 24             	mov    %ebx,(%esp)
  801756:	e8 b7 fb ff ff       	call   801312 <fd_lookup>
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 61                	js     8017c0 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801762:	89 44 24 04          	mov    %eax,0x4(%esp)
  801766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801769:	8b 00                	mov    (%eax),%eax
  80176b:	89 04 24             	mov    %eax,(%esp)
  80176e:	e8 f5 fb ff ff       	call   801368 <dev_lookup>
  801773:	85 c0                	test   %eax,%eax
  801775:	78 49                	js     8017c0 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177e:	75 23                	jne    8017a3 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801780:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801785:	8b 40 48             	mov    0x48(%eax),%eax
  801788:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80178c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801790:	c7 04 24 00 2e 80 00 	movl   $0x802e00,(%esp)
  801797:	e8 d4 ea ff ff       	call   800270 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80179c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a1:	eb 1d                	jmp    8017c0 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a6:	8b 52 18             	mov    0x18(%edx),%edx
  8017a9:	85 d2                	test   %edx,%edx
  8017ab:	74 0e                	je     8017bb <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017b4:	89 04 24             	mov    %eax,(%esp)
  8017b7:	ff d2                	call   *%edx
  8017b9:	eb 05                	jmp    8017c0 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c0:	83 c4 24             	add    $0x24,%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 24             	sub    $0x24,%esp
  8017cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	89 04 24             	mov    %eax,(%esp)
  8017dd:	e8 30 fb ff ff       	call   801312 <fd_lookup>
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 52                	js     801838 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f0:	8b 00                	mov    (%eax),%eax
  8017f2:	89 04 24             	mov    %eax,(%esp)
  8017f5:	e8 6e fb ff ff       	call   801368 <dev_lookup>
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 3a                	js     801838 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8017fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801801:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801805:	74 2c                	je     801833 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801807:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80180a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801811:	00 00 00 
	stat->st_isdir = 0;
  801814:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80181b:	00 00 00 
	stat->st_dev = dev;
  80181e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801824:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801828:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80182b:	89 14 24             	mov    %edx,(%esp)
  80182e:	ff 50 14             	call   *0x14(%eax)
  801831:	eb 05                	jmp    801838 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801833:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801838:	83 c4 24             	add    $0x24,%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
  801843:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801846:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80184d:	00 
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	89 04 24             	mov    %eax,(%esp)
  801854:	e8 2a 02 00 00       	call   801a83 <open>
  801859:	89 c3                	mov    %eax,%ebx
  80185b:	85 c0                	test   %eax,%eax
  80185d:	78 1b                	js     80187a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80185f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	89 1c 24             	mov    %ebx,(%esp)
  801869:	e8 58 ff ff ff       	call   8017c6 <fstat>
  80186e:	89 c6                	mov    %eax,%esi
	close(fd);
  801870:	89 1c 24             	mov    %ebx,(%esp)
  801873:	e8 d2 fb ff ff       	call   80144a <close>
	return r;
  801878:	89 f3                	mov    %esi,%ebx
}
  80187a:	89 d8                	mov    %ebx,%eax
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	5b                   	pop    %ebx
  801880:	5e                   	pop    %esi
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    
	...

00801884 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	56                   	push   %esi
  801888:	53                   	push   %ebx
  801889:	83 ec 10             	sub    $0x10,%esp
  80188c:	89 c3                	mov    %eax,%ebx
  80188e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801890:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801897:	75 11                	jne    8018aa <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801899:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018a0:	e8 fa 0d 00 00       	call   80269f <ipc_find_env>
  8018a5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018aa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018b1:	00 
  8018b2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018b9:	00 
  8018ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018be:	a1 00 40 80 00       	mov    0x804000,%eax
  8018c3:	89 04 24             	mov    %eax,(%esp)
  8018c6:	e8 51 0d 00 00       	call   80261c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018d2:	00 
  8018d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018de:	e8 c9 0c 00 00       	call   8025ac <ipc_recv>
}
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    

008018ea <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fe:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801903:	ba 00 00 00 00       	mov    $0x0,%edx
  801908:	b8 02 00 00 00       	mov    $0x2,%eax
  80190d:	e8 72 ff ff ff       	call   801884 <fsipc>
}
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	8b 40 0c             	mov    0xc(%eax),%eax
  801920:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801925:	ba 00 00 00 00       	mov    $0x0,%edx
  80192a:	b8 06 00 00 00       	mov    $0x6,%eax
  80192f:	e8 50 ff ff ff       	call   801884 <fsipc>
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	53                   	push   %ebx
  80193a:	83 ec 14             	sub    $0x14,%esp
  80193d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801940:	8b 45 08             	mov    0x8(%ebp),%eax
  801943:	8b 40 0c             	mov    0xc(%eax),%eax
  801946:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80194b:	ba 00 00 00 00       	mov    $0x0,%edx
  801950:	b8 05 00 00 00       	mov    $0x5,%eax
  801955:	e8 2a ff ff ff       	call   801884 <fsipc>
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 2b                	js     801989 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80195e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801965:	00 
  801966:	89 1c 24             	mov    %ebx,(%esp)
  801969:	e8 ad ee ff ff       	call   80081b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80196e:	a1 80 50 80 00       	mov    0x805080,%eax
  801973:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801979:	a1 84 50 80 00       	mov    0x805084,%eax
  80197e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801989:	83 c4 14             	add    $0x14,%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 18             	sub    $0x18,%esp
  801995:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801998:	8b 55 08             	mov    0x8(%ebp),%edx
  80199b:	8b 52 0c             	mov    0xc(%edx),%edx
  80199e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019a4:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8019a9:	89 c2                	mov    %eax,%edx
  8019ab:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019b0:	76 05                	jbe    8019b7 <devfile_write+0x28>
  8019b2:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8019b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8019c9:	e8 30 f0 ff ff       	call   8009fe <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d3:	b8 04 00 00 00       	mov    $0x4,%eax
  8019d8:	e8 a7 fe ff ff       	call   801884 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    

008019df <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 10             	sub    $0x10,%esp
  8019e7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019f5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	b8 03 00 00 00       	mov    $0x3,%eax
  801a05:	e8 7a fe ff ff       	call   801884 <fsipc>
  801a0a:	89 c3                	mov    %eax,%ebx
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	78 6a                	js     801a7a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a10:	39 c6                	cmp    %eax,%esi
  801a12:	73 24                	jae    801a38 <devfile_read+0x59>
  801a14:	c7 44 24 0c 74 2e 80 	movl   $0x802e74,0xc(%esp)
  801a1b:	00 
  801a1c:	c7 44 24 08 7b 2e 80 	movl   $0x802e7b,0x8(%esp)
  801a23:	00 
  801a24:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a2b:	00 
  801a2c:	c7 04 24 90 2e 80 00 	movl   $0x802e90,(%esp)
  801a33:	e8 40 e7 ff ff       	call   800178 <_panic>
	assert(r <= PGSIZE);
  801a38:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a3d:	7e 24                	jle    801a63 <devfile_read+0x84>
  801a3f:	c7 44 24 0c 9b 2e 80 	movl   $0x802e9b,0xc(%esp)
  801a46:	00 
  801a47:	c7 44 24 08 7b 2e 80 	movl   $0x802e7b,0x8(%esp)
  801a4e:	00 
  801a4f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a56:	00 
  801a57:	c7 04 24 90 2e 80 00 	movl   $0x802e90,(%esp)
  801a5e:	e8 15 e7 ff ff       	call   800178 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a67:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a6e:	00 
  801a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a72:	89 04 24             	mov    %eax,(%esp)
  801a75:	e8 1a ef ff ff       	call   800994 <memmove>
	return r;
}
  801a7a:	89 d8                	mov    %ebx,%eax
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	83 ec 20             	sub    $0x20,%esp
  801a8b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a8e:	89 34 24             	mov    %esi,(%esp)
  801a91:	e8 52 ed ff ff       	call   8007e8 <strlen>
  801a96:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a9b:	7f 60                	jg     801afd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa0:	89 04 24             	mov    %eax,(%esp)
  801aa3:	e8 17 f8 ff ff       	call   8012bf <fd_alloc>
  801aa8:	89 c3                	mov    %eax,%ebx
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	78 54                	js     801b02 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aae:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ab2:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ab9:	e8 5d ed ff ff       	call   80081b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  801ace:	e8 b1 fd ff ff       	call   801884 <fsipc>
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	79 15                	jns    801aee <open+0x6b>
		fd_close(fd, 0);
  801ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ae0:	00 
  801ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae4:	89 04 24             	mov    %eax,(%esp)
  801ae7:	e8 d6 f8 ff ff       	call   8013c2 <fd_close>
		return r;
  801aec:	eb 14                	jmp    801b02 <open+0x7f>
	}

	return fd2num(fd);
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	89 04 24             	mov    %eax,(%esp)
  801af4:	e8 9b f7 ff ff       	call   801294 <fd2num>
  801af9:	89 c3                	mov    %eax,%ebx
  801afb:	eb 05                	jmp    801b02 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801afd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b02:	89 d8                	mov    %ebx,%eax
  801b04:	83 c4 20             	add    $0x20,%esp
  801b07:	5b                   	pop    %ebx
  801b08:	5e                   	pop    %esi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b11:	ba 00 00 00 00       	mov    $0x0,%edx
  801b16:	b8 08 00 00 00       	mov    $0x8,%eax
  801b1b:	e8 64 fd ff ff       	call   801884 <fsipc>
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    
	...

00801b24 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b2a:	c7 44 24 04 a7 2e 80 	movl   $0x802ea7,0x4(%esp)
  801b31:	00 
  801b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b35:	89 04 24             	mov    %eax,(%esp)
  801b38:	e8 de ec ff ff       	call   80081b <strcpy>
	return 0;
}
  801b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	53                   	push   %ebx
  801b48:	83 ec 14             	sub    $0x14,%esp
  801b4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b4e:	89 1c 24             	mov    %ebx,(%esp)
  801b51:	e8 8e 0b 00 00       	call   8026e4 <pageref>
  801b56:	83 f8 01             	cmp    $0x1,%eax
  801b59:	75 0d                	jne    801b68 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801b5b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b5e:	89 04 24             	mov    %eax,(%esp)
  801b61:	e8 1f 03 00 00       	call   801e85 <nsipc_close>
  801b66:	eb 05                	jmp    801b6d <devsock_close+0x29>
	else
		return 0;
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6d:	83 c4 14             	add    $0x14,%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b79:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b80:	00 
  801b81:	8b 45 10             	mov    0x10(%ebp),%eax
  801b84:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	8b 40 0c             	mov    0xc(%eax),%eax
  801b95:	89 04 24             	mov    %eax,(%esp)
  801b98:	e8 e3 03 00 00       	call   801f80 <nsipc_send>
}
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ba5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bac:	00 
  801bad:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc1:	89 04 24             	mov    %eax,(%esp)
  801bc4:	e8 37 03 00 00       	call   801f00 <nsipc_recv>
}
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	56                   	push   %esi
  801bcf:	53                   	push   %ebx
  801bd0:	83 ec 20             	sub    $0x20,%esp
  801bd3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd8:	89 04 24             	mov    %eax,(%esp)
  801bdb:	e8 df f6 ff ff       	call   8012bf <fd_alloc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	85 c0                	test   %eax,%eax
  801be4:	78 21                	js     801c07 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801be6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bed:	00 
  801bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfc:	e8 0c f0 ff ff       	call   800c0d <sys_page_alloc>
  801c01:	89 c3                	mov    %eax,%ebx
  801c03:	85 c0                	test   %eax,%eax
  801c05:	79 0a                	jns    801c11 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801c07:	89 34 24             	mov    %esi,(%esp)
  801c0a:	e8 76 02 00 00       	call   801e85 <nsipc_close>
		return r;
  801c0f:	eb 22                	jmp    801c33 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c26:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c29:	89 04 24             	mov    %eax,(%esp)
  801c2c:	e8 63 f6 ff ff       	call   801294 <fd2num>
  801c31:	89 c3                	mov    %eax,%ebx
}
  801c33:	89 d8                	mov    %ebx,%eax
  801c35:	83 c4 20             	add    $0x20,%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    

00801c3c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c42:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c45:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c49:	89 04 24             	mov    %eax,(%esp)
  801c4c:	e8 c1 f6 ff ff       	call   801312 <fd_lookup>
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 17                	js     801c6c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c58:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c5e:	39 10                	cmp    %edx,(%eax)
  801c60:	75 05                	jne    801c67 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c62:	8b 40 0c             	mov    0xc(%eax),%eax
  801c65:	eb 05                	jmp    801c6c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c67:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    

00801c6e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	e8 c0 ff ff ff       	call   801c3c <fd2sockid>
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	78 1f                	js     801c9f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c80:	8b 55 10             	mov    0x10(%ebp),%edx
  801c83:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c87:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c8e:	89 04 24             	mov    %eax,(%esp)
  801c91:	e8 38 01 00 00       	call   801dce <nsipc_accept>
  801c96:	85 c0                	test   %eax,%eax
  801c98:	78 05                	js     801c9f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801c9a:	e8 2c ff ff ff       	call   801bcb <alloc_sockfd>
}
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    

00801ca1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  801caa:	e8 8d ff ff ff       	call   801c3c <fd2sockid>
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	78 16                	js     801cc9 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cb3:	8b 55 10             	mov    0x10(%ebp),%edx
  801cb6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cc1:	89 04 24             	mov    %eax,(%esp)
  801cc4:	e8 5b 01 00 00       	call   801e24 <nsipc_bind>
}
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <shutdown>:

int
shutdown(int s, int how)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd4:	e8 63 ff ff ff       	call   801c3c <fd2sockid>
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	78 0f                	js     801cec <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cdd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce0:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ce4:	89 04 24             	mov    %eax,(%esp)
  801ce7:	e8 77 01 00 00       	call   801e63 <nsipc_shutdown>
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	e8 40 ff ff ff       	call   801c3c <fd2sockid>
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 16                	js     801d16 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801d00:	8b 55 10             	mov    0x10(%ebp),%edx
  801d03:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d0e:	89 04 24             	mov    %eax,(%esp)
  801d11:	e8 89 01 00 00       	call   801e9f <nsipc_connect>
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <listen>:

int
listen(int s, int backlog)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d21:	e8 16 ff ff ff       	call   801c3c <fd2sockid>
  801d26:	85 c0                	test   %eax,%eax
  801d28:	78 0f                	js     801d39 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d31:	89 04 24             	mov    %eax,(%esp)
  801d34:	e8 a5 01 00 00       	call   801ede <nsipc_listen>
}
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d41:	8b 45 10             	mov    0x10(%ebp),%eax
  801d44:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d52:	89 04 24             	mov    %eax,(%esp)
  801d55:	e8 99 02 00 00       	call   801ff3 <nsipc_socket>
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 05                	js     801d63 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801d5e:	e8 68 fe ff ff       	call   801bcb <alloc_sockfd>
}
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    
  801d65:	00 00                	add    %al,(%eax)
	...

00801d68 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	53                   	push   %ebx
  801d6c:	83 ec 14             	sub    $0x14,%esp
  801d6f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d71:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d78:	75 11                	jne    801d8b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d7a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d81:	e8 19 09 00 00       	call   80269f <ipc_find_env>
  801d86:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d8b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d92:	00 
  801d93:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d9a:	00 
  801d9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801da4:	89 04 24             	mov    %eax,(%esp)
  801da7:	e8 70 08 00 00       	call   80261c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801db3:	00 
  801db4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dbb:	00 
  801dbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc3:	e8 e4 07 00 00       	call   8025ac <ipc_recv>
}
  801dc8:	83 c4 14             	add    $0x14,%esp
  801dcb:	5b                   	pop    %ebx
  801dcc:	5d                   	pop    %ebp
  801dcd:	c3                   	ret    

00801dce <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	56                   	push   %esi
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 10             	sub    $0x10,%esp
  801dd6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801de1:	8b 06                	mov    (%esi),%eax
  801de3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801de8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ded:	e8 76 ff ff ff       	call   801d68 <nsipc>
  801df2:	89 c3                	mov    %eax,%ebx
  801df4:	85 c0                	test   %eax,%eax
  801df6:	78 23                	js     801e1b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801df8:	a1 10 60 80 00       	mov    0x806010,%eax
  801dfd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e01:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e08:	00 
  801e09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0c:	89 04 24             	mov    %eax,(%esp)
  801e0f:	e8 80 eb ff ff       	call   800994 <memmove>
		*addrlen = ret->ret_addrlen;
  801e14:	a1 10 60 80 00       	mov    0x806010,%eax
  801e19:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801e1b:	89 d8                	mov    %ebx,%eax
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	5b                   	pop    %ebx
  801e21:	5e                   	pop    %esi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    

00801e24 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	53                   	push   %ebx
  801e28:	83 ec 14             	sub    $0x14,%esp
  801e2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e31:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e36:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e41:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e48:	e8 47 eb ff ff       	call   800994 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e4d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e53:	b8 02 00 00 00       	mov    $0x2,%eax
  801e58:	e8 0b ff ff ff       	call   801d68 <nsipc>
}
  801e5d:	83 c4 14             	add    $0x14,%esp
  801e60:	5b                   	pop    %ebx
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    

00801e63 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e69:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e74:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e79:	b8 03 00 00 00       	mov    $0x3,%eax
  801e7e:	e8 e5 fe ff ff       	call   801d68 <nsipc>
}
  801e83:	c9                   	leave  
  801e84:	c3                   	ret    

00801e85 <nsipc_close>:

int
nsipc_close(int s)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e93:	b8 04 00 00 00       	mov    $0x4,%eax
  801e98:	e8 cb fe ff ff       	call   801d68 <nsipc>
}
  801e9d:	c9                   	leave  
  801e9e:	c3                   	ret    

00801e9f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	53                   	push   %ebx
  801ea3:	83 ec 14             	sub    $0x14,%esp
  801ea6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  801eac:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801eb1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ebc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ec3:	e8 cc ea ff ff       	call   800994 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ec8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ece:	b8 05 00 00 00       	mov    $0x5,%eax
  801ed3:	e8 90 fe ff ff       	call   801d68 <nsipc>
}
  801ed8:	83 c4 14             	add    $0x14,%esp
  801edb:	5b                   	pop    %ebx
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eef:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ef4:	b8 06 00 00 00       	mov    $0x6,%eax
  801ef9:	e8 6a fe ff ff       	call   801d68 <nsipc>
}
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	83 ec 10             	sub    $0x10,%esp
  801f08:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f13:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f19:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f21:	b8 07 00 00 00       	mov    $0x7,%eax
  801f26:	e8 3d fe ff ff       	call   801d68 <nsipc>
  801f2b:	89 c3                	mov    %eax,%ebx
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	78 46                	js     801f77 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801f31:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f36:	7f 04                	jg     801f3c <nsipc_recv+0x3c>
  801f38:	39 c6                	cmp    %eax,%esi
  801f3a:	7d 24                	jge    801f60 <nsipc_recv+0x60>
  801f3c:	c7 44 24 0c b3 2e 80 	movl   $0x802eb3,0xc(%esp)
  801f43:	00 
  801f44:	c7 44 24 08 7b 2e 80 	movl   $0x802e7b,0x8(%esp)
  801f4b:	00 
  801f4c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801f53:	00 
  801f54:	c7 04 24 c8 2e 80 00 	movl   $0x802ec8,(%esp)
  801f5b:	e8 18 e2 ff ff       	call   800178 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f60:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f64:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f6b:	00 
  801f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6f:	89 04 24             	mov    %eax,(%esp)
  801f72:	e8 1d ea ff ff       	call   800994 <memmove>
	}

	return r;
}
  801f77:	89 d8                	mov    %ebx,%eax
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	5b                   	pop    %ebx
  801f7d:	5e                   	pop    %esi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	53                   	push   %ebx
  801f84:	83 ec 14             	sub    $0x14,%esp
  801f87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f92:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f98:	7e 24                	jle    801fbe <nsipc_send+0x3e>
  801f9a:	c7 44 24 0c d4 2e 80 	movl   $0x802ed4,0xc(%esp)
  801fa1:	00 
  801fa2:	c7 44 24 08 7b 2e 80 	movl   $0x802e7b,0x8(%esp)
  801fa9:	00 
  801faa:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801fb1:	00 
  801fb2:	c7 04 24 c8 2e 80 00 	movl   $0x802ec8,(%esp)
  801fb9:	e8 ba e1 ff ff       	call   800178 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc9:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801fd0:	e8 bf e9 ff ff       	call   800994 <memmove>
	nsipcbuf.send.req_size = size;
  801fd5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fdb:	8b 45 14             	mov    0x14(%ebp),%eax
  801fde:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fe3:	b8 08 00 00 00       	mov    $0x8,%eax
  801fe8:	e8 7b fd ff ff       	call   801d68 <nsipc>
}
  801fed:	83 c4 14             	add    $0x14,%esp
  801ff0:	5b                   	pop    %ebx
  801ff1:	5d                   	pop    %ebp
  801ff2:	c3                   	ret    

00801ff3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802001:	8b 45 0c             	mov    0xc(%ebp),%eax
  802004:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802009:	8b 45 10             	mov    0x10(%ebp),%eax
  80200c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802011:	b8 09 00 00 00       	mov    $0x9,%eax
  802016:	e8 4d fd ff ff       	call   801d68 <nsipc>
}
  80201b:	c9                   	leave  
  80201c:	c3                   	ret    
  80201d:	00 00                	add    %al,(%eax)
	...

00802020 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	83 ec 10             	sub    $0x10,%esp
  802028:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80202b:	8b 45 08             	mov    0x8(%ebp),%eax
  80202e:	89 04 24             	mov    %eax,(%esp)
  802031:	e8 6e f2 ff ff       	call   8012a4 <fd2data>
  802036:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802038:	c7 44 24 04 e0 2e 80 	movl   $0x802ee0,0x4(%esp)
  80203f:	00 
  802040:	89 34 24             	mov    %esi,(%esp)
  802043:	e8 d3 e7 ff ff       	call   80081b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802048:	8b 43 04             	mov    0x4(%ebx),%eax
  80204b:	2b 03                	sub    (%ebx),%eax
  80204d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802053:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80205a:	00 00 00 
	stat->st_dev = &devpipe;
  80205d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  802064:	30 80 00 
	return 0;
}
  802067:	b8 00 00 00 00       	mov    $0x0,%eax
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    

00802073 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	53                   	push   %ebx
  802077:	83 ec 14             	sub    $0x14,%esp
  80207a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80207d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802081:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802088:	e8 27 ec ff ff       	call   800cb4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80208d:	89 1c 24             	mov    %ebx,(%esp)
  802090:	e8 0f f2 ff ff       	call   8012a4 <fd2data>
  802095:	89 44 24 04          	mov    %eax,0x4(%esp)
  802099:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a0:	e8 0f ec ff ff       	call   800cb4 <sys_page_unmap>
}
  8020a5:	83 c4 14             	add    $0x14,%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    

008020ab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	57                   	push   %edi
  8020af:	56                   	push   %esi
  8020b0:	53                   	push   %ebx
  8020b1:	83 ec 2c             	sub    $0x2c,%esp
  8020b4:	89 c7                	mov    %eax,%edi
  8020b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020b9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8020be:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020c1:	89 3c 24             	mov    %edi,(%esp)
  8020c4:	e8 1b 06 00 00       	call   8026e4 <pageref>
  8020c9:	89 c6                	mov    %eax,%esi
  8020cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ce:	89 04 24             	mov    %eax,(%esp)
  8020d1:	e8 0e 06 00 00       	call   8026e4 <pageref>
  8020d6:	39 c6                	cmp    %eax,%esi
  8020d8:	0f 94 c0             	sete   %al
  8020db:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8020de:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8020e4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020e7:	39 cb                	cmp    %ecx,%ebx
  8020e9:	75 08                	jne    8020f3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8020eb:	83 c4 2c             	add    $0x2c,%esp
  8020ee:	5b                   	pop    %ebx
  8020ef:	5e                   	pop    %esi
  8020f0:	5f                   	pop    %edi
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8020f3:	83 f8 01             	cmp    $0x1,%eax
  8020f6:	75 c1                	jne    8020b9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020f8:	8b 42 58             	mov    0x58(%edx),%eax
  8020fb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802102:	00 
  802103:	89 44 24 08          	mov    %eax,0x8(%esp)
  802107:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80210b:	c7 04 24 e7 2e 80 00 	movl   $0x802ee7,(%esp)
  802112:	e8 59 e1 ff ff       	call   800270 <cprintf>
  802117:	eb a0                	jmp    8020b9 <_pipeisclosed+0xe>

00802119 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	57                   	push   %edi
  80211d:	56                   	push   %esi
  80211e:	53                   	push   %ebx
  80211f:	83 ec 1c             	sub    $0x1c,%esp
  802122:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802125:	89 34 24             	mov    %esi,(%esp)
  802128:	e8 77 f1 ff ff       	call   8012a4 <fd2data>
  80212d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80212f:	bf 00 00 00 00       	mov    $0x0,%edi
  802134:	eb 3c                	jmp    802172 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802136:	89 da                	mov    %ebx,%edx
  802138:	89 f0                	mov    %esi,%eax
  80213a:	e8 6c ff ff ff       	call   8020ab <_pipeisclosed>
  80213f:	85 c0                	test   %eax,%eax
  802141:	75 38                	jne    80217b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802143:	e8 a6 ea ff ff       	call   800bee <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802148:	8b 43 04             	mov    0x4(%ebx),%eax
  80214b:	8b 13                	mov    (%ebx),%edx
  80214d:	83 c2 20             	add    $0x20,%edx
  802150:	39 d0                	cmp    %edx,%eax
  802152:	73 e2                	jae    802136 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802154:	8b 55 0c             	mov    0xc(%ebp),%edx
  802157:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80215a:	89 c2                	mov    %eax,%edx
  80215c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802162:	79 05                	jns    802169 <devpipe_write+0x50>
  802164:	4a                   	dec    %edx
  802165:	83 ca e0             	or     $0xffffffe0,%edx
  802168:	42                   	inc    %edx
  802169:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80216d:	40                   	inc    %eax
  80216e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802171:	47                   	inc    %edi
  802172:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802175:	75 d1                	jne    802148 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802177:	89 f8                	mov    %edi,%eax
  802179:	eb 05                	jmp    802180 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80217b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    

00802188 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	57                   	push   %edi
  80218c:	56                   	push   %esi
  80218d:	53                   	push   %ebx
  80218e:	83 ec 1c             	sub    $0x1c,%esp
  802191:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802194:	89 3c 24             	mov    %edi,(%esp)
  802197:	e8 08 f1 ff ff       	call   8012a4 <fd2data>
  80219c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80219e:	be 00 00 00 00       	mov    $0x0,%esi
  8021a3:	eb 3a                	jmp    8021df <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021a5:	85 f6                	test   %esi,%esi
  8021a7:	74 04                	je     8021ad <devpipe_read+0x25>
				return i;
  8021a9:	89 f0                	mov    %esi,%eax
  8021ab:	eb 40                	jmp    8021ed <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021ad:	89 da                	mov    %ebx,%edx
  8021af:	89 f8                	mov    %edi,%eax
  8021b1:	e8 f5 fe ff ff       	call   8020ab <_pipeisclosed>
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	75 2e                	jne    8021e8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021ba:	e8 2f ea ff ff       	call   800bee <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021bf:	8b 03                	mov    (%ebx),%eax
  8021c1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021c4:	74 df                	je     8021a5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021c6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8021cb:	79 05                	jns    8021d2 <devpipe_read+0x4a>
  8021cd:	48                   	dec    %eax
  8021ce:	83 c8 e0             	or     $0xffffffe0,%eax
  8021d1:	40                   	inc    %eax
  8021d2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8021d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8021dc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021de:	46                   	inc    %esi
  8021df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021e2:	75 db                	jne    8021bf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021e4:	89 f0                	mov    %esi,%eax
  8021e6:	eb 05                	jmp    8021ed <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021e8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021ed:	83 c4 1c             	add    $0x1c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	57                   	push   %edi
  8021f9:	56                   	push   %esi
  8021fa:	53                   	push   %ebx
  8021fb:	83 ec 3c             	sub    $0x3c,%esp
  8021fe:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802201:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802204:	89 04 24             	mov    %eax,(%esp)
  802207:	e8 b3 f0 ff ff       	call   8012bf <fd_alloc>
  80220c:	89 c3                	mov    %eax,%ebx
  80220e:	85 c0                	test   %eax,%eax
  802210:	0f 88 45 01 00 00    	js     80235b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802216:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80221d:	00 
  80221e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802221:	89 44 24 04          	mov    %eax,0x4(%esp)
  802225:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80222c:	e8 dc e9 ff ff       	call   800c0d <sys_page_alloc>
  802231:	89 c3                	mov    %eax,%ebx
  802233:	85 c0                	test   %eax,%eax
  802235:	0f 88 20 01 00 00    	js     80235b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80223b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80223e:	89 04 24             	mov    %eax,(%esp)
  802241:	e8 79 f0 ff ff       	call   8012bf <fd_alloc>
  802246:	89 c3                	mov    %eax,%ebx
  802248:	85 c0                	test   %eax,%eax
  80224a:	0f 88 f8 00 00 00    	js     802348 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802250:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802257:	00 
  802258:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80225b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802266:	e8 a2 e9 ff ff       	call   800c0d <sys_page_alloc>
  80226b:	89 c3                	mov    %eax,%ebx
  80226d:	85 c0                	test   %eax,%eax
  80226f:	0f 88 d3 00 00 00    	js     802348 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802278:	89 04 24             	mov    %eax,(%esp)
  80227b:	e8 24 f0 ff ff       	call   8012a4 <fd2data>
  802280:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802282:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802289:	00 
  80228a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802295:	e8 73 e9 ff ff       	call   800c0d <sys_page_alloc>
  80229a:	89 c3                	mov    %eax,%ebx
  80229c:	85 c0                	test   %eax,%eax
  80229e:	0f 88 91 00 00 00    	js     802335 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022a7:	89 04 24             	mov    %eax,(%esp)
  8022aa:	e8 f5 ef ff ff       	call   8012a4 <fd2data>
  8022af:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022b6:	00 
  8022b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022c2:	00 
  8022c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ce:	e8 8e e9 ff ff       	call   800c61 <sys_page_map>
  8022d3:	89 c3                	mov    %eax,%ebx
  8022d5:	85 c0                	test   %eax,%eax
  8022d7:	78 4c                	js     802325 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022d9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022e2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022e7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022ee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022f7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022fc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802303:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802306:	89 04 24             	mov    %eax,(%esp)
  802309:	e8 86 ef ff ff       	call   801294 <fd2num>
  80230e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802310:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802313:	89 04 24             	mov    %eax,(%esp)
  802316:	e8 79 ef ff ff       	call   801294 <fd2num>
  80231b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80231e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802323:	eb 36                	jmp    80235b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802325:	89 74 24 04          	mov    %esi,0x4(%esp)
  802329:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802330:	e8 7f e9 ff ff       	call   800cb4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802335:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802343:	e8 6c e9 ff ff       	call   800cb4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80234b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80234f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802356:	e8 59 e9 ff ff       	call   800cb4 <sys_page_unmap>
    err:
	return r;
}
  80235b:	89 d8                	mov    %ebx,%eax
  80235d:	83 c4 3c             	add    $0x3c,%esp
  802360:	5b                   	pop    %ebx
  802361:	5e                   	pop    %esi
  802362:	5f                   	pop    %edi
  802363:	5d                   	pop    %ebp
  802364:	c3                   	ret    

00802365 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802365:	55                   	push   %ebp
  802366:	89 e5                	mov    %esp,%ebp
  802368:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80236b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802372:	8b 45 08             	mov    0x8(%ebp),%eax
  802375:	89 04 24             	mov    %eax,(%esp)
  802378:	e8 95 ef ff ff       	call   801312 <fd_lookup>
  80237d:	85 c0                	test   %eax,%eax
  80237f:	78 15                	js     802396 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802381:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802384:	89 04 24             	mov    %eax,(%esp)
  802387:	e8 18 ef ff ff       	call   8012a4 <fd2data>
	return _pipeisclosed(fd, p);
  80238c:	89 c2                	mov    %eax,%edx
  80238e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802391:	e8 15 fd ff ff       	call   8020ab <_pipeisclosed>
}
  802396:	c9                   	leave  
  802397:	c3                   	ret    

00802398 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802398:	55                   	push   %ebp
  802399:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80239b:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a0:	5d                   	pop    %ebp
  8023a1:	c3                   	ret    

008023a2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8023a8:	c7 44 24 04 ff 2e 80 	movl   $0x802eff,0x4(%esp)
  8023af:	00 
  8023b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b3:	89 04 24             	mov    %eax,(%esp)
  8023b6:	e8 60 e4 ff ff       	call   80081b <strcpy>
	return 0;
}
  8023bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8023c0:	c9                   	leave  
  8023c1:	c3                   	ret    

008023c2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	57                   	push   %edi
  8023c6:	56                   	push   %esi
  8023c7:	53                   	push   %ebx
  8023c8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023ce:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023d3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023d9:	eb 30                	jmp    80240b <devcons_write+0x49>
		m = n - tot;
  8023db:	8b 75 10             	mov    0x10(%ebp),%esi
  8023de:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8023e0:	83 fe 7f             	cmp    $0x7f,%esi
  8023e3:	76 05                	jbe    8023ea <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8023e5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023ea:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023ee:	03 45 0c             	add    0xc(%ebp),%eax
  8023f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023f5:	89 3c 24             	mov    %edi,(%esp)
  8023f8:	e8 97 e5 ff ff       	call   800994 <memmove>
		sys_cputs(buf, m);
  8023fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  802401:	89 3c 24             	mov    %edi,(%esp)
  802404:	e8 37 e7 ff ff       	call   800b40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802409:	01 f3                	add    %esi,%ebx
  80240b:	89 d8                	mov    %ebx,%eax
  80240d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802410:	72 c9                	jb     8023db <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802412:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802418:	5b                   	pop    %ebx
  802419:	5e                   	pop    %esi
  80241a:	5f                   	pop    %edi
  80241b:	5d                   	pop    %ebp
  80241c:	c3                   	ret    

0080241d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80241d:	55                   	push   %ebp
  80241e:	89 e5                	mov    %esp,%ebp
  802420:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802423:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802427:	75 07                	jne    802430 <devcons_read+0x13>
  802429:	eb 25                	jmp    802450 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80242b:	e8 be e7 ff ff       	call   800bee <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802430:	e8 29 e7 ff ff       	call   800b5e <sys_cgetc>
  802435:	85 c0                	test   %eax,%eax
  802437:	74 f2                	je     80242b <devcons_read+0xe>
  802439:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80243b:	85 c0                	test   %eax,%eax
  80243d:	78 1d                	js     80245c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80243f:	83 f8 04             	cmp    $0x4,%eax
  802442:	74 13                	je     802457 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802444:	8b 45 0c             	mov    0xc(%ebp),%eax
  802447:	88 10                	mov    %dl,(%eax)
	return 1;
  802449:	b8 01 00 00 00       	mov    $0x1,%eax
  80244e:	eb 0c                	jmp    80245c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802450:	b8 00 00 00 00       	mov    $0x0,%eax
  802455:	eb 05                	jmp    80245c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802457:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80245c:	c9                   	leave  
  80245d:	c3                   	ret    

0080245e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80245e:	55                   	push   %ebp
  80245f:	89 e5                	mov    %esp,%ebp
  802461:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802464:	8b 45 08             	mov    0x8(%ebp),%eax
  802467:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80246a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802471:	00 
  802472:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802475:	89 04 24             	mov    %eax,(%esp)
  802478:	e8 c3 e6 ff ff       	call   800b40 <sys_cputs>
}
  80247d:	c9                   	leave  
  80247e:	c3                   	ret    

0080247f <getchar>:

int
getchar(void)
{
  80247f:	55                   	push   %ebp
  802480:	89 e5                	mov    %esp,%ebp
  802482:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802485:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80248c:	00 
  80248d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802490:	89 44 24 04          	mov    %eax,0x4(%esp)
  802494:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80249b:	e8 10 f1 ff ff       	call   8015b0 <read>
	if (r < 0)
  8024a0:	85 c0                	test   %eax,%eax
  8024a2:	78 0f                	js     8024b3 <getchar+0x34>
		return r;
	if (r < 1)
  8024a4:	85 c0                	test   %eax,%eax
  8024a6:	7e 06                	jle    8024ae <getchar+0x2f>
		return -E_EOF;
	return c;
  8024a8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024ac:	eb 05                	jmp    8024b3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024ae:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024b3:	c9                   	leave  
  8024b4:	c3                   	ret    

008024b5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024b5:	55                   	push   %ebp
  8024b6:	89 e5                	mov    %esp,%ebp
  8024b8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c5:	89 04 24             	mov    %eax,(%esp)
  8024c8:	e8 45 ee ff ff       	call   801312 <fd_lookup>
  8024cd:	85 c0                	test   %eax,%eax
  8024cf:	78 11                	js     8024e2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024da:	39 10                	cmp    %edx,(%eax)
  8024dc:	0f 94 c0             	sete   %al
  8024df:	0f b6 c0             	movzbl %al,%eax
}
  8024e2:	c9                   	leave  
  8024e3:	c3                   	ret    

008024e4 <opencons>:

int
opencons(void)
{
  8024e4:	55                   	push   %ebp
  8024e5:	89 e5                	mov    %esp,%ebp
  8024e7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ed:	89 04 24             	mov    %eax,(%esp)
  8024f0:	e8 ca ed ff ff       	call   8012bf <fd_alloc>
  8024f5:	85 c0                	test   %eax,%eax
  8024f7:	78 3c                	js     802535 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024f9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802500:	00 
  802501:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802504:	89 44 24 04          	mov    %eax,0x4(%esp)
  802508:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80250f:	e8 f9 e6 ff ff       	call   800c0d <sys_page_alloc>
  802514:	85 c0                	test   %eax,%eax
  802516:	78 1d                	js     802535 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802518:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80251e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802521:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802523:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802526:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80252d:	89 04 24             	mov    %eax,(%esp)
  802530:	e8 5f ed ff ff       	call   801294 <fd2num>
}
  802535:	c9                   	leave  
  802536:	c3                   	ret    
	...

00802538 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802538:	55                   	push   %ebp
  802539:	89 e5                	mov    %esp,%ebp
  80253b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80253e:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802545:	75 30                	jne    802577 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  802547:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80254e:	00 
  80254f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802556:	ee 
  802557:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80255e:	e8 aa e6 ff ff       	call   800c0d <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802563:	c7 44 24 04 84 25 80 	movl   $0x802584,0x4(%esp)
  80256a:	00 
  80256b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802572:	e8 36 e8 ff ff       	call   800dad <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802577:	8b 45 08             	mov    0x8(%ebp),%eax
  80257a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80257f:	c9                   	leave  
  802580:	c3                   	ret    
  802581:	00 00                	add    %al,(%eax)
	...

00802584 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802584:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802585:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80258a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80258c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  80258f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802593:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802597:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  80259a:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  80259c:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  8025a0:	83 c4 08             	add    $0x8,%esp
	popal
  8025a3:	61                   	popa   

	addl $4,%esp 
  8025a4:	83 c4 04             	add    $0x4,%esp
	popfl
  8025a7:	9d                   	popf   

	popl %esp
  8025a8:	5c                   	pop    %esp

	ret
  8025a9:	c3                   	ret    
	...

008025ac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025ac:	55                   	push   %ebp
  8025ad:	89 e5                	mov    %esp,%ebp
  8025af:	56                   	push   %esi
  8025b0:	53                   	push   %ebx
  8025b1:	83 ec 10             	sub    $0x10,%esp
  8025b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8025b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ba:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	74 0a                	je     8025cb <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8025c1:	89 04 24             	mov    %eax,(%esp)
  8025c4:	e8 5a e8 ff ff       	call   800e23 <sys_ipc_recv>
  8025c9:	eb 0c                	jmp    8025d7 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8025cb:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8025d2:	e8 4c e8 ff ff       	call   800e23 <sys_ipc_recv>
	}
	if (r < 0)
  8025d7:	85 c0                	test   %eax,%eax
  8025d9:	79 16                	jns    8025f1 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8025db:	85 db                	test   %ebx,%ebx
  8025dd:	74 06                	je     8025e5 <ipc_recv+0x39>
  8025df:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8025e5:	85 f6                	test   %esi,%esi
  8025e7:	74 2c                	je     802615 <ipc_recv+0x69>
  8025e9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8025ef:	eb 24                	jmp    802615 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8025f1:	85 db                	test   %ebx,%ebx
  8025f3:	74 0a                	je     8025ff <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8025f5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8025fa:	8b 40 74             	mov    0x74(%eax),%eax
  8025fd:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8025ff:	85 f6                	test   %esi,%esi
  802601:	74 0a                	je     80260d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802603:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802608:	8b 40 78             	mov    0x78(%eax),%eax
  80260b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80260d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802612:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802615:	83 c4 10             	add    $0x10,%esp
  802618:	5b                   	pop    %ebx
  802619:	5e                   	pop    %esi
  80261a:	5d                   	pop    %ebp
  80261b:	c3                   	ret    

0080261c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80261c:	55                   	push   %ebp
  80261d:	89 e5                	mov    %esp,%ebp
  80261f:	57                   	push   %edi
  802620:	56                   	push   %esi
  802621:	53                   	push   %ebx
  802622:	83 ec 1c             	sub    $0x1c,%esp
  802625:	8b 75 08             	mov    0x8(%ebp),%esi
  802628:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80262b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80262e:	85 db                	test   %ebx,%ebx
  802630:	74 19                	je     80264b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802632:	8b 45 14             	mov    0x14(%ebp),%eax
  802635:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802639:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80263d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802641:	89 34 24             	mov    %esi,(%esp)
  802644:	e8 b7 e7 ff ff       	call   800e00 <sys_ipc_try_send>
  802649:	eb 1c                	jmp    802667 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80264b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802652:	00 
  802653:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80265a:	ee 
  80265b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80265f:	89 34 24             	mov    %esi,(%esp)
  802662:	e8 99 e7 ff ff       	call   800e00 <sys_ipc_try_send>
		}
		if (r == 0)
  802667:	85 c0                	test   %eax,%eax
  802669:	74 2c                	je     802697 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80266b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80266e:	74 20                	je     802690 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802670:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802674:	c7 44 24 08 0b 2f 80 	movl   $0x802f0b,0x8(%esp)
  80267b:	00 
  80267c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802683:	00 
  802684:	c7 04 24 1e 2f 80 00 	movl   $0x802f1e,(%esp)
  80268b:	e8 e8 da ff ff       	call   800178 <_panic>
		}
		sys_yield();
  802690:	e8 59 e5 ff ff       	call   800bee <sys_yield>
	}
  802695:	eb 97                	jmp    80262e <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802697:	83 c4 1c             	add    $0x1c,%esp
  80269a:	5b                   	pop    %ebx
  80269b:	5e                   	pop    %esi
  80269c:	5f                   	pop    %edi
  80269d:	5d                   	pop    %ebp
  80269e:	c3                   	ret    

0080269f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80269f:	55                   	push   %ebp
  8026a0:	89 e5                	mov    %esp,%ebp
  8026a2:	53                   	push   %ebx
  8026a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8026a6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026ab:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8026b2:	89 c2                	mov    %eax,%edx
  8026b4:	c1 e2 07             	shl    $0x7,%edx
  8026b7:	29 ca                	sub    %ecx,%edx
  8026b9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026bf:	8b 52 50             	mov    0x50(%edx),%edx
  8026c2:	39 da                	cmp    %ebx,%edx
  8026c4:	75 0f                	jne    8026d5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8026c6:	c1 e0 07             	shl    $0x7,%eax
  8026c9:	29 c8                	sub    %ecx,%eax
  8026cb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8026d0:	8b 40 40             	mov    0x40(%eax),%eax
  8026d3:	eb 0c                	jmp    8026e1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026d5:	40                   	inc    %eax
  8026d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026db:	75 ce                	jne    8026ab <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026dd:	66 b8 00 00          	mov    $0x0,%ax
}
  8026e1:	5b                   	pop    %ebx
  8026e2:	5d                   	pop    %ebp
  8026e3:	c3                   	ret    

008026e4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026e4:	55                   	push   %ebp
  8026e5:	89 e5                	mov    %esp,%ebp
  8026e7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026ea:	89 c2                	mov    %eax,%edx
  8026ec:	c1 ea 16             	shr    $0x16,%edx
  8026ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026f6:	f6 c2 01             	test   $0x1,%dl
  8026f9:	74 1e                	je     802719 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026fb:	c1 e8 0c             	shr    $0xc,%eax
  8026fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802705:	a8 01                	test   $0x1,%al
  802707:	74 17                	je     802720 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802709:	c1 e8 0c             	shr    $0xc,%eax
  80270c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802713:	ef 
  802714:	0f b7 c0             	movzwl %ax,%eax
  802717:	eb 0c                	jmp    802725 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802719:	b8 00 00 00 00       	mov    $0x0,%eax
  80271e:	eb 05                	jmp    802725 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802720:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802725:	5d                   	pop    %ebp
  802726:	c3                   	ret    
	...

00802728 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802728:	55                   	push   %ebp
  802729:	57                   	push   %edi
  80272a:	56                   	push   %esi
  80272b:	83 ec 10             	sub    $0x10,%esp
  80272e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802732:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802736:	89 74 24 04          	mov    %esi,0x4(%esp)
  80273a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80273e:	89 cd                	mov    %ecx,%ebp
  802740:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802744:	85 c0                	test   %eax,%eax
  802746:	75 2c                	jne    802774 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802748:	39 f9                	cmp    %edi,%ecx
  80274a:	77 68                	ja     8027b4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80274c:	85 c9                	test   %ecx,%ecx
  80274e:	75 0b                	jne    80275b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802750:	b8 01 00 00 00       	mov    $0x1,%eax
  802755:	31 d2                	xor    %edx,%edx
  802757:	f7 f1                	div    %ecx
  802759:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80275b:	31 d2                	xor    %edx,%edx
  80275d:	89 f8                	mov    %edi,%eax
  80275f:	f7 f1                	div    %ecx
  802761:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802763:	89 f0                	mov    %esi,%eax
  802765:	f7 f1                	div    %ecx
  802767:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802769:	89 f0                	mov    %esi,%eax
  80276b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80276d:	83 c4 10             	add    $0x10,%esp
  802770:	5e                   	pop    %esi
  802771:	5f                   	pop    %edi
  802772:	5d                   	pop    %ebp
  802773:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802774:	39 f8                	cmp    %edi,%eax
  802776:	77 2c                	ja     8027a4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802778:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80277b:	83 f6 1f             	xor    $0x1f,%esi
  80277e:	75 4c                	jne    8027cc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802780:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802782:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802787:	72 0a                	jb     802793 <__udivdi3+0x6b>
  802789:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80278d:	0f 87 ad 00 00 00    	ja     802840 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802793:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027a4:	31 ff                	xor    %edi,%edi
  8027a6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027a8:	89 f0                	mov    %esi,%eax
  8027aa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027ac:	83 c4 10             	add    $0x10,%esp
  8027af:	5e                   	pop    %esi
  8027b0:	5f                   	pop    %edi
  8027b1:	5d                   	pop    %ebp
  8027b2:	c3                   	ret    
  8027b3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027b4:	89 fa                	mov    %edi,%edx
  8027b6:	89 f0                	mov    %esi,%eax
  8027b8:	f7 f1                	div    %ecx
  8027ba:	89 c6                	mov    %eax,%esi
  8027bc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027be:	89 f0                	mov    %esi,%eax
  8027c0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027c2:	83 c4 10             	add    $0x10,%esp
  8027c5:	5e                   	pop    %esi
  8027c6:	5f                   	pop    %edi
  8027c7:	5d                   	pop    %ebp
  8027c8:	c3                   	ret    
  8027c9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027cc:	89 f1                	mov    %esi,%ecx
  8027ce:	d3 e0                	shl    %cl,%eax
  8027d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027d4:	b8 20 00 00 00       	mov    $0x20,%eax
  8027d9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8027db:	89 ea                	mov    %ebp,%edx
  8027dd:	88 c1                	mov    %al,%cl
  8027df:	d3 ea                	shr    %cl,%edx
  8027e1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8027e5:	09 ca                	or     %ecx,%edx
  8027e7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8027eb:	89 f1                	mov    %esi,%ecx
  8027ed:	d3 e5                	shl    %cl,%ebp
  8027ef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8027f3:	89 fd                	mov    %edi,%ebp
  8027f5:	88 c1                	mov    %al,%cl
  8027f7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8027f9:	89 fa                	mov    %edi,%edx
  8027fb:	89 f1                	mov    %esi,%ecx
  8027fd:	d3 e2                	shl    %cl,%edx
  8027ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802803:	88 c1                	mov    %al,%cl
  802805:	d3 ef                	shr    %cl,%edi
  802807:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802809:	89 f8                	mov    %edi,%eax
  80280b:	89 ea                	mov    %ebp,%edx
  80280d:	f7 74 24 08          	divl   0x8(%esp)
  802811:	89 d1                	mov    %edx,%ecx
  802813:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802815:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802819:	39 d1                	cmp    %edx,%ecx
  80281b:	72 17                	jb     802834 <__udivdi3+0x10c>
  80281d:	74 09                	je     802828 <__udivdi3+0x100>
  80281f:	89 fe                	mov    %edi,%esi
  802821:	31 ff                	xor    %edi,%edi
  802823:	e9 41 ff ff ff       	jmp    802769 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802828:	8b 54 24 04          	mov    0x4(%esp),%edx
  80282c:	89 f1                	mov    %esi,%ecx
  80282e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802830:	39 c2                	cmp    %eax,%edx
  802832:	73 eb                	jae    80281f <__udivdi3+0xf7>
		{
		  q0--;
  802834:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802837:	31 ff                	xor    %edi,%edi
  802839:	e9 2b ff ff ff       	jmp    802769 <__udivdi3+0x41>
  80283e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802840:	31 f6                	xor    %esi,%esi
  802842:	e9 22 ff ff ff       	jmp    802769 <__udivdi3+0x41>
	...

00802848 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802848:	55                   	push   %ebp
  802849:	57                   	push   %edi
  80284a:	56                   	push   %esi
  80284b:	83 ec 20             	sub    $0x20,%esp
  80284e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802852:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802856:	89 44 24 14          	mov    %eax,0x14(%esp)
  80285a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80285e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802862:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802866:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802868:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80286a:	85 ed                	test   %ebp,%ebp
  80286c:	75 16                	jne    802884 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80286e:	39 f1                	cmp    %esi,%ecx
  802870:	0f 86 a6 00 00 00    	jbe    80291c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802876:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802878:	89 d0                	mov    %edx,%eax
  80287a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80287c:	83 c4 20             	add    $0x20,%esp
  80287f:	5e                   	pop    %esi
  802880:	5f                   	pop    %edi
  802881:	5d                   	pop    %ebp
  802882:	c3                   	ret    
  802883:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802884:	39 f5                	cmp    %esi,%ebp
  802886:	0f 87 ac 00 00 00    	ja     802938 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80288c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80288f:	83 f0 1f             	xor    $0x1f,%eax
  802892:	89 44 24 10          	mov    %eax,0x10(%esp)
  802896:	0f 84 a8 00 00 00    	je     802944 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80289c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028a0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8028a2:	bf 20 00 00 00       	mov    $0x20,%edi
  8028a7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8028ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028af:	89 f9                	mov    %edi,%ecx
  8028b1:	d3 e8                	shr    %cl,%eax
  8028b3:	09 e8                	or     %ebp,%eax
  8028b5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8028b9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028bd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028c1:	d3 e0                	shl    %cl,%eax
  8028c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028c7:	89 f2                	mov    %esi,%edx
  8028c9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8028cb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028cf:	d3 e0                	shl    %cl,%eax
  8028d1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028d5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028d9:	89 f9                	mov    %edi,%ecx
  8028db:	d3 e8                	shr    %cl,%eax
  8028dd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8028df:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028e1:	89 f2                	mov    %esi,%edx
  8028e3:	f7 74 24 18          	divl   0x18(%esp)
  8028e7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8028e9:	f7 64 24 0c          	mull   0xc(%esp)
  8028ed:	89 c5                	mov    %eax,%ebp
  8028ef:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028f1:	39 d6                	cmp    %edx,%esi
  8028f3:	72 67                	jb     80295c <__umoddi3+0x114>
  8028f5:	74 75                	je     80296c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8028f7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8028fb:	29 e8                	sub    %ebp,%eax
  8028fd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8028ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802903:	d3 e8                	shr    %cl,%eax
  802905:	89 f2                	mov    %esi,%edx
  802907:	89 f9                	mov    %edi,%ecx
  802909:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80290b:	09 d0                	or     %edx,%eax
  80290d:	89 f2                	mov    %esi,%edx
  80290f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802913:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802915:	83 c4 20             	add    $0x20,%esp
  802918:	5e                   	pop    %esi
  802919:	5f                   	pop    %edi
  80291a:	5d                   	pop    %ebp
  80291b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80291c:	85 c9                	test   %ecx,%ecx
  80291e:	75 0b                	jne    80292b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802920:	b8 01 00 00 00       	mov    $0x1,%eax
  802925:	31 d2                	xor    %edx,%edx
  802927:	f7 f1                	div    %ecx
  802929:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80292b:	89 f0                	mov    %esi,%eax
  80292d:	31 d2                	xor    %edx,%edx
  80292f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802931:	89 f8                	mov    %edi,%eax
  802933:	e9 3e ff ff ff       	jmp    802876 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802938:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80293a:	83 c4 20             	add    $0x20,%esp
  80293d:	5e                   	pop    %esi
  80293e:	5f                   	pop    %edi
  80293f:	5d                   	pop    %ebp
  802940:	c3                   	ret    
  802941:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802944:	39 f5                	cmp    %esi,%ebp
  802946:	72 04                	jb     80294c <__umoddi3+0x104>
  802948:	39 f9                	cmp    %edi,%ecx
  80294a:	77 06                	ja     802952 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80294c:	89 f2                	mov    %esi,%edx
  80294e:	29 cf                	sub    %ecx,%edi
  802950:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802952:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802954:	83 c4 20             	add    $0x20,%esp
  802957:	5e                   	pop    %esi
  802958:	5f                   	pop    %edi
  802959:	5d                   	pop    %ebp
  80295a:	c3                   	ret    
  80295b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80295c:	89 d1                	mov    %edx,%ecx
  80295e:	89 c5                	mov    %eax,%ebp
  802960:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802964:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802968:	eb 8d                	jmp    8028f7 <__umoddi3+0xaf>
  80296a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80296c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802970:	72 ea                	jb     80295c <__umoddi3+0x114>
  802972:	89 f1                	mov    %esi,%ecx
  802974:	eb 81                	jmp    8028f7 <__umoddi3+0xaf>
