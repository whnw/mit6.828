
obj/user/testtime.debug:     file format elf32-i386


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

00800034 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	unsigned now = sys_time_msec();
  80003e:	e8 32 0e 00 00       	call   800e75 <sys_time_msec>
	unsigned end = now + sec * 1000;

	if ((int)now < 0 && (int)now > -MAXERROR)
  800043:	85 c0                	test   %eax,%eax
  800045:	79 25                	jns    80006c <sleep+0x38>
  800047:	83 f8 f0             	cmp    $0xfffffff0,%eax
  80004a:	7c 20                	jl     80006c <sleep+0x38>
		panic("sys_time_msec: %e", (int)now);
  80004c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800050:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  800057:	00 
  800058:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 72 25 80 00 	movl   $0x802572,(%esp)
  800067:	e8 0c 01 00 00       	call   800178 <_panic>

void
sleep(int sec)
{
	unsigned now = sys_time_msec();
	unsigned end = now + sec * 1000;
  80006c:	8d 14 9b             	lea    (%ebx,%ebx,4),%edx
  80006f:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800072:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800075:	8d 1c d0             	lea    (%eax,%edx,8),%ebx

	if ((int)now < 0 && (int)now > -MAXERROR)
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
  800078:	39 d8                	cmp    %ebx,%eax
  80007a:	76 21                	jbe    80009d <sleep+0x69>
		panic("sleep: wrap");
  80007c:	c7 44 24 08 82 25 80 	movl   $0x802582,0x8(%esp)
  800083:	00 
  800084:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80008b:	00 
  80008c:	c7 04 24 72 25 80 00 	movl   $0x802572,(%esp)
  800093:	e8 e0 00 00 00       	call   800178 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  800098:	e8 51 0b 00 00       	call   800bee <sys_yield>
	if ((int)now < 0 && (int)now > -MAXERROR)
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
		panic("sleep: wrap");

	while (sys_time_msec() < end)
  80009d:	e8 d3 0d 00 00       	call   800e75 <sys_time_msec>
  8000a2:	39 c3                	cmp    %eax,%ebx
  8000a4:	77 f2                	ja     800098 <sleep+0x64>
		sys_yield();
}
  8000a6:	83 c4 14             	add    $0x14,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5d                   	pop    %ebp
  8000ab:	c3                   	ret    

008000ac <umain>:

void
umain(int argc, char **argv)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 14             	sub    $0x14,%esp
  8000b3:	bb 32 00 00 00       	mov    $0x32,%ebx
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();
  8000b8:	e8 31 0b 00 00       	call   800bee <sys_yield>
umain(int argc, char **argv)
{
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
  8000bd:	4b                   	dec    %ebx
  8000be:	75 f8                	jne    8000b8 <umain+0xc>
		sys_yield();

	cprintf("starting count down: ");
  8000c0:	c7 04 24 8e 25 80 00 	movl   $0x80258e,(%esp)
  8000c7:	e8 a4 01 00 00       	call   800270 <cprintf>
	for (i = 5; i >= 0; i--) {
  8000cc:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d5:	c7 04 24 a4 25 80 00 	movl   $0x8025a4,(%esp)
  8000dc:	e8 8f 01 00 00       	call   800270 <cprintf>
		sleep(1);
  8000e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000e8:	e8 47 ff ff ff       	call   800034 <sleep>
	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();

	cprintf("starting count down: ");
	for (i = 5; i >= 0; i--) {
  8000ed:	4b                   	dec    %ebx
  8000ee:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000f1:	75 de                	jne    8000d1 <umain+0x25>
		cprintf("%d ", i);
		sleep(1);
	}
	cprintf("\n");
  8000f3:	c7 04 24 28 2a 80 00 	movl   $0x802a28,(%esp)
  8000fa:	e8 71 01 00 00       	call   800270 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8000ff:	cc                   	int3   
	breakpoint();
}
  800100:	83 c4 14             	add    $0x14,%esp
  800103:	5b                   	pop    %ebx
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
  800131:	a3 08 40 80 00       	mov    %eax,0x804008


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
  800148:	e8 5f ff ff ff       	call   8000ac <umain>

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
  800162:	e8 58 0f 00 00       	call   8010bf <close_all>
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
  8001a4:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  8001ab:	e8 c0 00 00 00       	call   800270 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 50 00 00 00       	call   80020f <vcprintf>
	cprintf("\n");
  8001bf:	c7 04 24 28 2a 80 00 	movl   $0x802a28,(%esp)
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
  8002e5:	e8 0e 20 00 00       	call   8022f8 <__udivdi3>
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
  800338:	e8 db 20 00 00       	call   802418 <__umoddi3>
  80033d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800341:	0f be 80 d7 25 80 00 	movsbl 0x8025d7(%eax),%eax
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
  80045c:	ff 24 95 20 27 80 00 	jmp    *0x802720(,%edx,4)
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
  8004ea:	8b 04 85 80 28 80 00 	mov    0x802880(,%eax,4),%eax
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	75 23                	jne    800518 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f9:	c7 44 24 08 ef 25 80 	movl   $0x8025ef,0x8(%esp)
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
  80051c:	c7 44 24 08 bd 29 80 	movl   $0x8029bd,0x8(%esp)
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
  800552:	be e8 25 80 00       	mov    $0x8025e8,%esi
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
  800bab:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bba:	00 
  800bbb:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
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
  800c3d:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  800c44:	00 
  800c45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4c:	00 
  800c4d:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
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
  800c90:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  800c97:	00 
  800c98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9f:	00 
  800ca0:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
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
  800ce3:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
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
  800d36:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
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
  800d89:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
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
  800ddc:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
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
  800e51:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  800e58:	00 
  800e59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e60:	00 
  800e61:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
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

00800ed8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee3:	c1 e8 0c             	shr    $0xc,%eax
}
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef1:	89 04 24             	mov    %eax,(%esp)
  800ef4:	e8 df ff ff ff       	call   800ed8 <fd2num>
  800ef9:	c1 e0 0c             	shl    $0xc,%eax
  800efc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	53                   	push   %ebx
  800f07:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f0a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f0f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f11:	89 c2                	mov    %eax,%edx
  800f13:	c1 ea 16             	shr    $0x16,%edx
  800f16:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1d:	f6 c2 01             	test   $0x1,%dl
  800f20:	74 11                	je     800f33 <fd_alloc+0x30>
  800f22:	89 c2                	mov    %eax,%edx
  800f24:	c1 ea 0c             	shr    $0xc,%edx
  800f27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2e:	f6 c2 01             	test   $0x1,%dl
  800f31:	75 09                	jne    800f3c <fd_alloc+0x39>
			*fd_store = fd;
  800f33:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3a:	eb 17                	jmp    800f53 <fd_alloc+0x50>
  800f3c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f41:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f46:	75 c7                	jne    800f0f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f48:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f4e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f53:	5b                   	pop    %ebx
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f5c:	83 f8 1f             	cmp    $0x1f,%eax
  800f5f:	77 36                	ja     800f97 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f61:	c1 e0 0c             	shl    $0xc,%eax
  800f64:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f69:	89 c2                	mov    %eax,%edx
  800f6b:	c1 ea 16             	shr    $0x16,%edx
  800f6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f75:	f6 c2 01             	test   $0x1,%dl
  800f78:	74 24                	je     800f9e <fd_lookup+0x48>
  800f7a:	89 c2                	mov    %eax,%edx
  800f7c:	c1 ea 0c             	shr    $0xc,%edx
  800f7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f86:	f6 c2 01             	test   $0x1,%dl
  800f89:	74 1a                	je     800fa5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8e:	89 02                	mov    %eax,(%edx)
	return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
  800f95:	eb 13                	jmp    800faa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9c:	eb 0c                	jmp    800faa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa3:	eb 05                	jmp    800faa <fd_lookup+0x54>
  800fa5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 14             	sub    $0x14,%esp
  800fb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbe:	eb 0e                	jmp    800fce <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fc0:	39 08                	cmp    %ecx,(%eax)
  800fc2:	75 09                	jne    800fcd <dev_lookup+0x21>
			*dev = devtab[i];
  800fc4:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	eb 33                	jmp    801000 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fcd:	42                   	inc    %edx
  800fce:	8b 04 95 90 29 80 00 	mov    0x802990(,%edx,4),%eax
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	75 e7                	jne    800fc0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd9:	a1 08 40 80 00       	mov    0x804008,%eax
  800fde:	8b 40 48             	mov    0x48(%eax),%eax
  800fe1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe9:	c7 04 24 10 29 80 00 	movl   $0x802910,(%esp)
  800ff0:	e8 7b f2 ff ff       	call   800270 <cprintf>
	*dev = 0;
  800ff5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ffb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801000:	83 c4 14             	add    $0x14,%esp
  801003:	5b                   	pop    %ebx
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	83 ec 30             	sub    $0x30,%esp
  80100e:	8b 75 08             	mov    0x8(%ebp),%esi
  801011:	8a 45 0c             	mov    0xc(%ebp),%al
  801014:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801017:	89 34 24             	mov    %esi,(%esp)
  80101a:	e8 b9 fe ff ff       	call   800ed8 <fd2num>
  80101f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801022:	89 54 24 04          	mov    %edx,0x4(%esp)
  801026:	89 04 24             	mov    %eax,(%esp)
  801029:	e8 28 ff ff ff       	call   800f56 <fd_lookup>
  80102e:	89 c3                	mov    %eax,%ebx
  801030:	85 c0                	test   %eax,%eax
  801032:	78 05                	js     801039 <fd_close+0x33>
	    || fd != fd2)
  801034:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801037:	74 0d                	je     801046 <fd_close+0x40>
		return (must_exist ? r : 0);
  801039:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80103d:	75 46                	jne    801085 <fd_close+0x7f>
  80103f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801044:	eb 3f                	jmp    801085 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801046:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104d:	8b 06                	mov    (%esi),%eax
  80104f:	89 04 24             	mov    %eax,(%esp)
  801052:	e8 55 ff ff ff       	call   800fac <dev_lookup>
  801057:	89 c3                	mov    %eax,%ebx
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 18                	js     801075 <fd_close+0x6f>
		if (dev->dev_close)
  80105d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801060:	8b 40 10             	mov    0x10(%eax),%eax
  801063:	85 c0                	test   %eax,%eax
  801065:	74 09                	je     801070 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801067:	89 34 24             	mov    %esi,(%esp)
  80106a:	ff d0                	call   *%eax
  80106c:	89 c3                	mov    %eax,%ebx
  80106e:	eb 05                	jmp    801075 <fd_close+0x6f>
		else
			r = 0;
  801070:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801075:	89 74 24 04          	mov    %esi,0x4(%esp)
  801079:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801080:	e8 2f fc ff ff       	call   800cb4 <sys_page_unmap>
	return r;
}
  801085:	89 d8                	mov    %ebx,%eax
  801087:	83 c4 30             	add    $0x30,%esp
  80108a:	5b                   	pop    %ebx
  80108b:	5e                   	pop    %esi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801094:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	89 04 24             	mov    %eax,(%esp)
  8010a1:	e8 b0 fe ff ff       	call   800f56 <fd_lookup>
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	78 13                	js     8010bd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b1:	00 
  8010b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b5:	89 04 24             	mov    %eax,(%esp)
  8010b8:	e8 49 ff ff ff       	call   801006 <fd_close>
}
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <close_all>:

void
close_all(void)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010cb:	89 1c 24             	mov    %ebx,(%esp)
  8010ce:	e8 bb ff ff ff       	call   80108e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010d3:	43                   	inc    %ebx
  8010d4:	83 fb 20             	cmp    $0x20,%ebx
  8010d7:	75 f2                	jne    8010cb <close_all+0xc>
		close(i);
}
  8010d9:	83 c4 14             	add    $0x14,%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 4c             	sub    $0x4c,%esp
  8010e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f5:	89 04 24             	mov    %eax,(%esp)
  8010f8:	e8 59 fe ff ff       	call   800f56 <fd_lookup>
  8010fd:	89 c3                	mov    %eax,%ebx
  8010ff:	85 c0                	test   %eax,%eax
  801101:	0f 88 e3 00 00 00    	js     8011ea <dup+0x10b>
		return r;
	close(newfdnum);
  801107:	89 3c 24             	mov    %edi,(%esp)
  80110a:	e8 7f ff ff ff       	call   80108e <close>

	newfd = INDEX2FD(newfdnum);
  80110f:	89 fe                	mov    %edi,%esi
  801111:	c1 e6 0c             	shl    $0xc,%esi
  801114:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80111a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111d:	89 04 24             	mov    %eax,(%esp)
  801120:	e8 c3 fd ff ff       	call   800ee8 <fd2data>
  801125:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801127:	89 34 24             	mov    %esi,(%esp)
  80112a:	e8 b9 fd ff ff       	call   800ee8 <fd2data>
  80112f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801132:	89 d8                	mov    %ebx,%eax
  801134:	c1 e8 16             	shr    $0x16,%eax
  801137:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113e:	a8 01                	test   $0x1,%al
  801140:	74 46                	je     801188 <dup+0xa9>
  801142:	89 d8                	mov    %ebx,%eax
  801144:	c1 e8 0c             	shr    $0xc,%eax
  801147:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80114e:	f6 c2 01             	test   $0x1,%dl
  801151:	74 35                	je     801188 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801153:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115a:	25 07 0e 00 00       	and    $0xe07,%eax
  80115f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801163:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801171:	00 
  801172:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117d:	e8 df fa ff ff       	call   800c61 <sys_page_map>
  801182:	89 c3                	mov    %eax,%ebx
  801184:	85 c0                	test   %eax,%eax
  801186:	78 3b                	js     8011c3 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	c1 ea 0c             	shr    $0xc,%edx
  801190:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801197:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80119d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011ac:	00 
  8011ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b8:	e8 a4 fa ff ff       	call   800c61 <sys_page_map>
  8011bd:	89 c3                	mov    %eax,%ebx
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	79 25                	jns    8011e8 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ce:	e8 e1 fa ff ff       	call   800cb4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e1:	e8 ce fa ff ff       	call   800cb4 <sys_page_unmap>
	return r;
  8011e6:	eb 02                	jmp    8011ea <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011e8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011ea:	89 d8                	mov    %ebx,%eax
  8011ec:	83 c4 4c             	add    $0x4c,%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5f                   	pop    %edi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 24             	sub    $0x24,%esp
  8011fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801201:	89 44 24 04          	mov    %eax,0x4(%esp)
  801205:	89 1c 24             	mov    %ebx,(%esp)
  801208:	e8 49 fd ff ff       	call   800f56 <fd_lookup>
  80120d:	85 c0                	test   %eax,%eax
  80120f:	78 6d                	js     80127e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	89 44 24 04          	mov    %eax,0x4(%esp)
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	8b 00                	mov    (%eax),%eax
  80121d:	89 04 24             	mov    %eax,(%esp)
  801220:	e8 87 fd ff ff       	call   800fac <dev_lookup>
  801225:	85 c0                	test   %eax,%eax
  801227:	78 55                	js     80127e <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801229:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122c:	8b 50 08             	mov    0x8(%eax),%edx
  80122f:	83 e2 03             	and    $0x3,%edx
  801232:	83 fa 01             	cmp    $0x1,%edx
  801235:	75 23                	jne    80125a <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801237:	a1 08 40 80 00       	mov    0x804008,%eax
  80123c:	8b 40 48             	mov    0x48(%eax),%eax
  80123f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801243:	89 44 24 04          	mov    %eax,0x4(%esp)
  801247:	c7 04 24 54 29 80 00 	movl   $0x802954,(%esp)
  80124e:	e8 1d f0 ff ff       	call   800270 <cprintf>
		return -E_INVAL;
  801253:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801258:	eb 24                	jmp    80127e <read+0x8a>
	}
	if (!dev->dev_read)
  80125a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125d:	8b 52 08             	mov    0x8(%edx),%edx
  801260:	85 d2                	test   %edx,%edx
  801262:	74 15                	je     801279 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801264:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801267:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80126b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801272:	89 04 24             	mov    %eax,(%esp)
  801275:	ff d2                	call   *%edx
  801277:	eb 05                	jmp    80127e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801279:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80127e:	83 c4 24             	add    $0x24,%esp
  801281:	5b                   	pop    %ebx
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	57                   	push   %edi
  801288:	56                   	push   %esi
  801289:	53                   	push   %ebx
  80128a:	83 ec 1c             	sub    $0x1c,%esp
  80128d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801290:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801293:	bb 00 00 00 00       	mov    $0x0,%ebx
  801298:	eb 23                	jmp    8012bd <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129a:	89 f0                	mov    %esi,%eax
  80129c:	29 d8                	sub    %ebx,%eax
  80129e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a5:	01 d8                	add    %ebx,%eax
  8012a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ab:	89 3c 24             	mov    %edi,(%esp)
  8012ae:	e8 41 ff ff ff       	call   8011f4 <read>
		if (m < 0)
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 10                	js     8012c7 <readn+0x43>
			return m;
		if (m == 0)
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	74 0a                	je     8012c5 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012bb:	01 c3                	add    %eax,%ebx
  8012bd:	39 f3                	cmp    %esi,%ebx
  8012bf:	72 d9                	jb     80129a <readn+0x16>
  8012c1:	89 d8                	mov    %ebx,%eax
  8012c3:	eb 02                	jmp    8012c7 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012c5:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012c7:	83 c4 1c             	add    $0x1c,%esp
  8012ca:	5b                   	pop    %ebx
  8012cb:	5e                   	pop    %esi
  8012cc:	5f                   	pop    %edi
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 24             	sub    $0x24,%esp
  8012d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e0:	89 1c 24             	mov    %ebx,(%esp)
  8012e3:	e8 6e fc ff ff       	call   800f56 <fd_lookup>
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 68                	js     801354 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f6:	8b 00                	mov    (%eax),%eax
  8012f8:	89 04 24             	mov    %eax,(%esp)
  8012fb:	e8 ac fc ff ff       	call   800fac <dev_lookup>
  801300:	85 c0                	test   %eax,%eax
  801302:	78 50                	js     801354 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801304:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801307:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130b:	75 23                	jne    801330 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80130d:	a1 08 40 80 00       	mov    0x804008,%eax
  801312:	8b 40 48             	mov    0x48(%eax),%eax
  801315:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131d:	c7 04 24 70 29 80 00 	movl   $0x802970,(%esp)
  801324:	e8 47 ef ff ff       	call   800270 <cprintf>
		return -E_INVAL;
  801329:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132e:	eb 24                	jmp    801354 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801330:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801333:	8b 52 0c             	mov    0xc(%edx),%edx
  801336:	85 d2                	test   %edx,%edx
  801338:	74 15                	je     80134f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80133a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80133d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801341:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801344:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801348:	89 04 24             	mov    %eax,(%esp)
  80134b:	ff d2                	call   *%edx
  80134d:	eb 05                	jmp    801354 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80134f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801354:	83 c4 24             	add    $0x24,%esp
  801357:	5b                   	pop    %ebx
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <seek>:

int
seek(int fdnum, off_t offset)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801360:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801363:	89 44 24 04          	mov    %eax,0x4(%esp)
  801367:	8b 45 08             	mov    0x8(%ebp),%eax
  80136a:	89 04 24             	mov    %eax,(%esp)
  80136d:	e8 e4 fb ff ff       	call   800f56 <fd_lookup>
  801372:	85 c0                	test   %eax,%eax
  801374:	78 0e                	js     801384 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801376:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801379:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80137f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	53                   	push   %ebx
  80138a:	83 ec 24             	sub    $0x24,%esp
  80138d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801390:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801393:	89 44 24 04          	mov    %eax,0x4(%esp)
  801397:	89 1c 24             	mov    %ebx,(%esp)
  80139a:	e8 b7 fb ff ff       	call   800f56 <fd_lookup>
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 61                	js     801404 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ad:	8b 00                	mov    (%eax),%eax
  8013af:	89 04 24             	mov    %eax,(%esp)
  8013b2:	e8 f5 fb ff ff       	call   800fac <dev_lookup>
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 49                	js     801404 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c2:	75 23                	jne    8013e7 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c9:	8b 40 48             	mov    0x48(%eax),%eax
  8013cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d4:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  8013db:	e8 90 ee ff ff       	call   800270 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e5:	eb 1d                	jmp    801404 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8013e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ea:	8b 52 18             	mov    0x18(%edx),%edx
  8013ed:	85 d2                	test   %edx,%edx
  8013ef:	74 0e                	je     8013ff <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013f8:	89 04 24             	mov    %eax,(%esp)
  8013fb:	ff d2                	call   *%edx
  8013fd:	eb 05                	jmp    801404 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801404:	83 c4 24             	add    $0x24,%esp
  801407:	5b                   	pop    %ebx
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	53                   	push   %ebx
  80140e:	83 ec 24             	sub    $0x24,%esp
  801411:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801414:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141b:	8b 45 08             	mov    0x8(%ebp),%eax
  80141e:	89 04 24             	mov    %eax,(%esp)
  801421:	e8 30 fb ff ff       	call   800f56 <fd_lookup>
  801426:	85 c0                	test   %eax,%eax
  801428:	78 52                	js     80147c <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801434:	8b 00                	mov    (%eax),%eax
  801436:	89 04 24             	mov    %eax,(%esp)
  801439:	e8 6e fb ff ff       	call   800fac <dev_lookup>
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 3a                	js     80147c <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801442:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801445:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801449:	74 2c                	je     801477 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80144b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80144e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801455:	00 00 00 
	stat->st_isdir = 0;
  801458:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80145f:	00 00 00 
	stat->st_dev = dev;
  801462:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801468:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80146c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80146f:	89 14 24             	mov    %edx,(%esp)
  801472:	ff 50 14             	call   *0x14(%eax)
  801475:	eb 05                	jmp    80147c <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801477:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80147c:	83 c4 24             	add    $0x24,%esp
  80147f:	5b                   	pop    %ebx
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	56                   	push   %esi
  801486:	53                   	push   %ebx
  801487:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80148a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801491:	00 
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	89 04 24             	mov    %eax,(%esp)
  801498:	e8 2a 02 00 00       	call   8016c7 <open>
  80149d:	89 c3                	mov    %eax,%ebx
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 1b                	js     8014be <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014aa:	89 1c 24             	mov    %ebx,(%esp)
  8014ad:	e8 58 ff ff ff       	call   80140a <fstat>
  8014b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b4:	89 1c 24             	mov    %ebx,(%esp)
  8014b7:	e8 d2 fb ff ff       	call   80108e <close>
	return r;
  8014bc:	89 f3                	mov    %esi,%ebx
}
  8014be:	89 d8                	mov    %ebx,%eax
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	5b                   	pop    %ebx
  8014c4:	5e                   	pop    %esi
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    
	...

008014c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	56                   	push   %esi
  8014cc:	53                   	push   %ebx
  8014cd:	83 ec 10             	sub    $0x10,%esp
  8014d0:	89 c3                	mov    %eax,%ebx
  8014d2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014d4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014db:	75 11                	jne    8014ee <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014e4:	e8 86 0d 00 00       	call   80226f <ipc_find_env>
  8014e9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014ee:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014f5:	00 
  8014f6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8014fd:	00 
  8014fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801502:	a1 00 40 80 00       	mov    0x804000,%eax
  801507:	89 04 24             	mov    %eax,(%esp)
  80150a:	e8 dd 0c 00 00       	call   8021ec <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80150f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801516:	00 
  801517:	89 74 24 04          	mov    %esi,0x4(%esp)
  80151b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801522:	e8 55 0c 00 00       	call   80217c <ipc_recv>
}
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	5b                   	pop    %ebx
  80152b:	5e                   	pop    %esi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801534:	8b 45 08             	mov    0x8(%ebp),%eax
  801537:	8b 40 0c             	mov    0xc(%eax),%eax
  80153a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80153f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801542:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801547:	ba 00 00 00 00       	mov    $0x0,%edx
  80154c:	b8 02 00 00 00       	mov    $0x2,%eax
  801551:	e8 72 ff ff ff       	call   8014c8 <fsipc>
}
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80155e:	8b 45 08             	mov    0x8(%ebp),%eax
  801561:	8b 40 0c             	mov    0xc(%eax),%eax
  801564:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801569:	ba 00 00 00 00       	mov    $0x0,%edx
  80156e:	b8 06 00 00 00       	mov    $0x6,%eax
  801573:	e8 50 ff ff ff       	call   8014c8 <fsipc>
}
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	83 ec 14             	sub    $0x14,%esp
  801581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801584:	8b 45 08             	mov    0x8(%ebp),%eax
  801587:	8b 40 0c             	mov    0xc(%eax),%eax
  80158a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80158f:	ba 00 00 00 00       	mov    $0x0,%edx
  801594:	b8 05 00 00 00       	mov    $0x5,%eax
  801599:	e8 2a ff ff ff       	call   8014c8 <fsipc>
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 2b                	js     8015cd <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015a2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015a9:	00 
  8015aa:	89 1c 24             	mov    %ebx,(%esp)
  8015ad:	e8 69 f2 ff ff       	call   80081b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8015b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8015c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015cd:	83 c4 14             	add    $0x14,%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5d                   	pop    %ebp
  8015d2:	c3                   	ret    

008015d3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	83 ec 18             	sub    $0x18,%esp
  8015d9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8015df:	8b 52 0c             	mov    0xc(%edx),%edx
  8015e2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015e8:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015f4:	76 05                	jbe    8015fb <devfile_write+0x28>
  8015f6:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8015fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801602:	89 44 24 04          	mov    %eax,0x4(%esp)
  801606:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80160d:	e8 ec f3 ff ff       	call   8009fe <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801612:	ba 00 00 00 00       	mov    $0x0,%edx
  801617:	b8 04 00 00 00       	mov    $0x4,%eax
  80161c:	e8 a7 fe ff ff       	call   8014c8 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	56                   	push   %esi
  801627:	53                   	push   %ebx
  801628:	83 ec 10             	sub    $0x10,%esp
  80162b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80162e:	8b 45 08             	mov    0x8(%ebp),%eax
  801631:	8b 40 0c             	mov    0xc(%eax),%eax
  801634:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801639:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80163f:	ba 00 00 00 00       	mov    $0x0,%edx
  801644:	b8 03 00 00 00       	mov    $0x3,%eax
  801649:	e8 7a fe ff ff       	call   8014c8 <fsipc>
  80164e:	89 c3                	mov    %eax,%ebx
  801650:	85 c0                	test   %eax,%eax
  801652:	78 6a                	js     8016be <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801654:	39 c6                	cmp    %eax,%esi
  801656:	73 24                	jae    80167c <devfile_read+0x59>
  801658:	c7 44 24 0c a4 29 80 	movl   $0x8029a4,0xc(%esp)
  80165f:	00 
  801660:	c7 44 24 08 ab 29 80 	movl   $0x8029ab,0x8(%esp)
  801667:	00 
  801668:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80166f:	00 
  801670:	c7 04 24 c0 29 80 00 	movl   $0x8029c0,(%esp)
  801677:	e8 fc ea ff ff       	call   800178 <_panic>
	assert(r <= PGSIZE);
  80167c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801681:	7e 24                	jle    8016a7 <devfile_read+0x84>
  801683:	c7 44 24 0c cb 29 80 	movl   $0x8029cb,0xc(%esp)
  80168a:	00 
  80168b:	c7 44 24 08 ab 29 80 	movl   $0x8029ab,0x8(%esp)
  801692:	00 
  801693:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80169a:	00 
  80169b:	c7 04 24 c0 29 80 00 	movl   $0x8029c0,(%esp)
  8016a2:	e8 d1 ea ff ff       	call   800178 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ab:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016b2:	00 
  8016b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b6:	89 04 24             	mov    %eax,(%esp)
  8016b9:	e8 d6 f2 ff ff       	call   800994 <memmove>
	return r;
}
  8016be:	89 d8                	mov    %ebx,%eax
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	56                   	push   %esi
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 20             	sub    $0x20,%esp
  8016cf:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016d2:	89 34 24             	mov    %esi,(%esp)
  8016d5:	e8 0e f1 ff ff       	call   8007e8 <strlen>
  8016da:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016df:	7f 60                	jg     801741 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e4:	89 04 24             	mov    %eax,(%esp)
  8016e7:	e8 17 f8 ff ff       	call   800f03 <fd_alloc>
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 54                	js     801746 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016f6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016fd:	e8 19 f1 ff ff       	call   80081b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801702:	8b 45 0c             	mov    0xc(%ebp),%eax
  801705:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80170a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170d:	b8 01 00 00 00       	mov    $0x1,%eax
  801712:	e8 b1 fd ff ff       	call   8014c8 <fsipc>
  801717:	89 c3                	mov    %eax,%ebx
  801719:	85 c0                	test   %eax,%eax
  80171b:	79 15                	jns    801732 <open+0x6b>
		fd_close(fd, 0);
  80171d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801724:	00 
  801725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801728:	89 04 24             	mov    %eax,(%esp)
  80172b:	e8 d6 f8 ff ff       	call   801006 <fd_close>
		return r;
  801730:	eb 14                	jmp    801746 <open+0x7f>
	}

	return fd2num(fd);
  801732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801735:	89 04 24             	mov    %eax,(%esp)
  801738:	e8 9b f7 ff ff       	call   800ed8 <fd2num>
  80173d:	89 c3                	mov    %eax,%ebx
  80173f:	eb 05                	jmp    801746 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801741:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801746:	89 d8                	mov    %ebx,%eax
  801748:	83 c4 20             	add    $0x20,%esp
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801755:	ba 00 00 00 00       	mov    $0x0,%edx
  80175a:	b8 08 00 00 00       	mov    $0x8,%eax
  80175f:	e8 64 fd ff ff       	call   8014c8 <fsipc>
}
  801764:	c9                   	leave  
  801765:	c3                   	ret    
	...

00801768 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  80176e:	c7 44 24 04 d7 29 80 	movl   $0x8029d7,0x4(%esp)
  801775:	00 
  801776:	8b 45 0c             	mov    0xc(%ebp),%eax
  801779:	89 04 24             	mov    %eax,(%esp)
  80177c:	e8 9a f0 ff ff       	call   80081b <strcpy>
	return 0;
}
  801781:	b8 00 00 00 00       	mov    $0x0,%eax
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	83 ec 14             	sub    $0x14,%esp
  80178f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801792:	89 1c 24             	mov    %ebx,(%esp)
  801795:	e8 1a 0b 00 00       	call   8022b4 <pageref>
  80179a:	83 f8 01             	cmp    $0x1,%eax
  80179d:	75 0d                	jne    8017ac <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80179f:	8b 43 0c             	mov    0xc(%ebx),%eax
  8017a2:	89 04 24             	mov    %eax,(%esp)
  8017a5:	e8 1f 03 00 00       	call   801ac9 <nsipc_close>
  8017aa:	eb 05                	jmp    8017b1 <devsock_close+0x29>
	else
		return 0;
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b1:	83 c4 14             	add    $0x14,%esp
  8017b4:	5b                   	pop    %ebx
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017c4:	00 
  8017c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d9:	89 04 24             	mov    %eax,(%esp)
  8017dc:	e8 e3 03 00 00       	call   801bc4 <nsipc_send>
}
  8017e1:	c9                   	leave  
  8017e2:	c3                   	ret    

008017e3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017f0:	00 
  8017f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	8b 40 0c             	mov    0xc(%eax),%eax
  801805:	89 04 24             	mov    %eax,(%esp)
  801808:	e8 37 03 00 00       	call   801b44 <nsipc_recv>
}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	56                   	push   %esi
  801813:	53                   	push   %ebx
  801814:	83 ec 20             	sub    $0x20,%esp
  801817:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181c:	89 04 24             	mov    %eax,(%esp)
  80181f:	e8 df f6 ff ff       	call   800f03 <fd_alloc>
  801824:	89 c3                	mov    %eax,%ebx
  801826:	85 c0                	test   %eax,%eax
  801828:	78 21                	js     80184b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80182a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801831:	00 
  801832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801835:	89 44 24 04          	mov    %eax,0x4(%esp)
  801839:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801840:	e8 c8 f3 ff ff       	call   800c0d <sys_page_alloc>
  801845:	89 c3                	mov    %eax,%ebx
  801847:	85 c0                	test   %eax,%eax
  801849:	79 0a                	jns    801855 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80184b:	89 34 24             	mov    %esi,(%esp)
  80184e:	e8 76 02 00 00       	call   801ac9 <nsipc_close>
		return r;
  801853:	eb 22                	jmp    801877 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801855:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80185b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801860:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801863:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80186a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80186d:	89 04 24             	mov    %eax,(%esp)
  801870:	e8 63 f6 ff ff       	call   800ed8 <fd2num>
  801875:	89 c3                	mov    %eax,%ebx
}
  801877:	89 d8                	mov    %ebx,%eax
  801879:	83 c4 20             	add    $0x20,%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5e                   	pop    %esi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801886:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801889:	89 54 24 04          	mov    %edx,0x4(%esp)
  80188d:	89 04 24             	mov    %eax,(%esp)
  801890:	e8 c1 f6 ff ff       	call   800f56 <fd_lookup>
  801895:	85 c0                	test   %eax,%eax
  801897:	78 17                	js     8018b0 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018a2:	39 10                	cmp    %edx,(%eax)
  8018a4:	75 05                	jne    8018ab <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a9:	eb 05                	jmp    8018b0 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	e8 c0 ff ff ff       	call   801880 <fd2sockid>
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 1f                	js     8018e3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8018c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018d2:	89 04 24             	mov    %eax,(%esp)
  8018d5:	e8 38 01 00 00       	call   801a12 <nsipc_accept>
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 05                	js     8018e3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8018de:	e8 2c ff ff ff       	call   80180f <alloc_sockfd>
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	e8 8d ff ff ff       	call   801880 <fd2sockid>
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 16                	js     80190d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8018f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8018fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801901:	89 54 24 04          	mov    %edx,0x4(%esp)
  801905:	89 04 24             	mov    %eax,(%esp)
  801908:	e8 5b 01 00 00       	call   801a68 <nsipc_bind>
}
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <shutdown>:

int
shutdown(int s, int how)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	e8 63 ff ff ff       	call   801880 <fd2sockid>
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 0f                	js     801930 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801921:	8b 55 0c             	mov    0xc(%ebp),%edx
  801924:	89 54 24 04          	mov    %edx,0x4(%esp)
  801928:	89 04 24             	mov    %eax,(%esp)
  80192b:	e8 77 01 00 00       	call   801aa7 <nsipc_shutdown>
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801938:	8b 45 08             	mov    0x8(%ebp),%eax
  80193b:	e8 40 ff ff ff       	call   801880 <fd2sockid>
  801940:	85 c0                	test   %eax,%eax
  801942:	78 16                	js     80195a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801944:	8b 55 10             	mov    0x10(%ebp),%edx
  801947:	89 54 24 08          	mov    %edx,0x8(%esp)
  80194b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801952:	89 04 24             	mov    %eax,(%esp)
  801955:	e8 89 01 00 00       	call   801ae3 <nsipc_connect>
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <listen>:

int
listen(int s, int backlog)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	e8 16 ff ff ff       	call   801880 <fd2sockid>
  80196a:	85 c0                	test   %eax,%eax
  80196c:	78 0f                	js     80197d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80196e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801971:	89 54 24 04          	mov    %edx,0x4(%esp)
  801975:	89 04 24             	mov    %eax,(%esp)
  801978:	e8 a5 01 00 00       	call   801b22 <nsipc_listen>
}
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801985:	8b 45 10             	mov    0x10(%ebp),%eax
  801988:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801993:	8b 45 08             	mov    0x8(%ebp),%eax
  801996:	89 04 24             	mov    %eax,(%esp)
  801999:	e8 99 02 00 00       	call   801c37 <nsipc_socket>
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 05                	js     8019a7 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8019a2:	e8 68 fe ff ff       	call   80180f <alloc_sockfd>
}
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    
  8019a9:	00 00                	add    %al,(%eax)
	...

008019ac <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	53                   	push   %ebx
  8019b0:	83 ec 14             	sub    $0x14,%esp
  8019b3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019b5:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019bc:	75 11                	jne    8019cf <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019be:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8019c5:	e8 a5 08 00 00       	call   80226f <ipc_find_env>
  8019ca:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019cf:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019d6:	00 
  8019d7:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8019de:	00 
  8019df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8019e8:	89 04 24             	mov    %eax,(%esp)
  8019eb:	e8 fc 07 00 00       	call   8021ec <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f7:	00 
  8019f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ff:	00 
  801a00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a07:	e8 70 07 00 00       	call   80217c <ipc_recv>
}
  801a0c:	83 c4 14             	add    $0x14,%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	56                   	push   %esi
  801a16:	53                   	push   %ebx
  801a17:	83 ec 10             	sub    $0x10,%esp
  801a1a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a20:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a25:	8b 06                	mov    (%esi),%eax
  801a27:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a31:	e8 76 ff ff ff       	call   8019ac <nsipc>
  801a36:	89 c3                	mov    %eax,%ebx
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	78 23                	js     801a5f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a3c:	a1 10 60 80 00       	mov    0x806010,%eax
  801a41:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a45:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a4c:	00 
  801a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a50:	89 04 24             	mov    %eax,(%esp)
  801a53:	e8 3c ef ff ff       	call   800994 <memmove>
		*addrlen = ret->ret_addrlen;
  801a58:	a1 10 60 80 00       	mov    0x806010,%eax
  801a5d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801a5f:	89 d8                	mov    %ebx,%eax
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	53                   	push   %ebx
  801a6c:	83 ec 14             	sub    $0x14,%esp
  801a6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a72:	8b 45 08             	mov    0x8(%ebp),%eax
  801a75:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a7a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a85:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801a8c:	e8 03 ef ff ff       	call   800994 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a91:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a97:	b8 02 00 00 00       	mov    $0x2,%eax
  801a9c:	e8 0b ff ff ff       	call   8019ac <nsipc>
}
  801aa1:	83 c4 14             	add    $0x14,%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801aad:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801abd:	b8 03 00 00 00       	mov    $0x3,%eax
  801ac2:	e8 e5 fe ff ff       	call   8019ac <nsipc>
}
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <nsipc_close>:

int
nsipc_close(int s)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ad7:	b8 04 00 00 00       	mov    $0x4,%eax
  801adc:	e8 cb fe ff ff       	call   8019ac <nsipc>
}
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 14             	sub    $0x14,%esp
  801aea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801aed:	8b 45 08             	mov    0x8(%ebp),%eax
  801af0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801af5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b00:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801b07:	e8 88 ee ff ff       	call   800994 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b0c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b12:	b8 05 00 00 00       	mov    $0x5,%eax
  801b17:	e8 90 fe ff ff       	call   8019ac <nsipc>
}
  801b1c:	83 c4 14             	add    $0x14,%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b33:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b38:	b8 06 00 00 00       	mov    $0x6,%eax
  801b3d:	e8 6a fe ff ff       	call   8019ac <nsipc>
}
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	83 ec 10             	sub    $0x10,%esp
  801b4c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b52:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b57:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b5d:	8b 45 14             	mov    0x14(%ebp),%eax
  801b60:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b65:	b8 07 00 00 00       	mov    $0x7,%eax
  801b6a:	e8 3d fe ff ff       	call   8019ac <nsipc>
  801b6f:	89 c3                	mov    %eax,%ebx
  801b71:	85 c0                	test   %eax,%eax
  801b73:	78 46                	js     801bbb <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801b75:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b7a:	7f 04                	jg     801b80 <nsipc_recv+0x3c>
  801b7c:	39 c6                	cmp    %eax,%esi
  801b7e:	7d 24                	jge    801ba4 <nsipc_recv+0x60>
  801b80:	c7 44 24 0c e3 29 80 	movl   $0x8029e3,0xc(%esp)
  801b87:	00 
  801b88:	c7 44 24 08 ab 29 80 	movl   $0x8029ab,0x8(%esp)
  801b8f:	00 
  801b90:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801b97:	00 
  801b98:	c7 04 24 f8 29 80 00 	movl   $0x8029f8,(%esp)
  801b9f:	e8 d4 e5 ff ff       	call   800178 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ba4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba8:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801baf:	00 
  801bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb3:	89 04 24             	mov    %eax,(%esp)
  801bb6:	e8 d9 ed ff ff       	call   800994 <memmove>
	}

	return r;
}
  801bbb:	89 d8                	mov    %ebx,%eax
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	5b                   	pop    %ebx
  801bc1:	5e                   	pop    %esi
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	53                   	push   %ebx
  801bc8:	83 ec 14             	sub    $0x14,%esp
  801bcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bce:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801bd6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801bdc:	7e 24                	jle    801c02 <nsipc_send+0x3e>
  801bde:	c7 44 24 0c 04 2a 80 	movl   $0x802a04,0xc(%esp)
  801be5:	00 
  801be6:	c7 44 24 08 ab 29 80 	movl   $0x8029ab,0x8(%esp)
  801bed:	00 
  801bee:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801bf5:	00 
  801bf6:	c7 04 24 f8 29 80 00 	movl   $0x8029f8,(%esp)
  801bfd:	e8 76 e5 ff ff       	call   800178 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c02:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801c14:	e8 7b ed ff ff       	call   800994 <memmove>
	nsipcbuf.send.req_size = size;
  801c19:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801c22:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c27:	b8 08 00 00 00       	mov    $0x8,%eax
  801c2c:	e8 7b fd ff ff       	call   8019ac <nsipc>
}
  801c31:	83 c4 14             	add    $0x14,%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c40:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c48:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c50:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c55:	b8 09 00 00 00       	mov    $0x9,%eax
  801c5a:	e8 4d fd ff ff       	call   8019ac <nsipc>
}
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    
  801c61:	00 00                	add    %al,(%eax)
	...

00801c64 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	56                   	push   %esi
  801c68:	53                   	push   %ebx
  801c69:	83 ec 10             	sub    $0x10,%esp
  801c6c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	89 04 24             	mov    %eax,(%esp)
  801c75:	e8 6e f2 ff ff       	call   800ee8 <fd2data>
  801c7a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c7c:	c7 44 24 04 10 2a 80 	movl   $0x802a10,0x4(%esp)
  801c83:	00 
  801c84:	89 34 24             	mov    %esi,(%esp)
  801c87:	e8 8f eb ff ff       	call   80081b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c8c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c8f:	2b 03                	sub    (%ebx),%eax
  801c91:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c97:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c9e:	00 00 00 
	stat->st_dev = &devpipe;
  801ca1:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801ca8:	30 80 00 
	return 0;
}
  801cab:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	53                   	push   %ebx
  801cbb:	83 ec 14             	sub    $0x14,%esp
  801cbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cc1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ccc:	e8 e3 ef ff ff       	call   800cb4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cd1:	89 1c 24             	mov    %ebx,(%esp)
  801cd4:	e8 0f f2 ff ff       	call   800ee8 <fd2data>
  801cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce4:	e8 cb ef ff ff       	call   800cb4 <sys_page_unmap>
}
  801ce9:	83 c4 14             	add    $0x14,%esp
  801cec:	5b                   	pop    %ebx
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    

00801cef <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	57                   	push   %edi
  801cf3:	56                   	push   %esi
  801cf4:	53                   	push   %ebx
  801cf5:	83 ec 2c             	sub    $0x2c,%esp
  801cf8:	89 c7                	mov    %eax,%edi
  801cfa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cfd:	a1 08 40 80 00       	mov    0x804008,%eax
  801d02:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d05:	89 3c 24             	mov    %edi,(%esp)
  801d08:	e8 a7 05 00 00       	call   8022b4 <pageref>
  801d0d:	89 c6                	mov    %eax,%esi
  801d0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d12:	89 04 24             	mov    %eax,(%esp)
  801d15:	e8 9a 05 00 00       	call   8022b4 <pageref>
  801d1a:	39 c6                	cmp    %eax,%esi
  801d1c:	0f 94 c0             	sete   %al
  801d1f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d22:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d28:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d2b:	39 cb                	cmp    %ecx,%ebx
  801d2d:	75 08                	jne    801d37 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d2f:	83 c4 2c             	add    $0x2c,%esp
  801d32:	5b                   	pop    %ebx
  801d33:	5e                   	pop    %esi
  801d34:	5f                   	pop    %edi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d37:	83 f8 01             	cmp    $0x1,%eax
  801d3a:	75 c1                	jne    801cfd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d3c:	8b 42 58             	mov    0x58(%edx),%eax
  801d3f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d46:	00 
  801d47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d4f:	c7 04 24 17 2a 80 00 	movl   $0x802a17,(%esp)
  801d56:	e8 15 e5 ff ff       	call   800270 <cprintf>
  801d5b:	eb a0                	jmp    801cfd <_pipeisclosed+0xe>

00801d5d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	57                   	push   %edi
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	83 ec 1c             	sub    $0x1c,%esp
  801d66:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d69:	89 34 24             	mov    %esi,(%esp)
  801d6c:	e8 77 f1 ff ff       	call   800ee8 <fd2data>
  801d71:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d73:	bf 00 00 00 00       	mov    $0x0,%edi
  801d78:	eb 3c                	jmp    801db6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d7a:	89 da                	mov    %ebx,%edx
  801d7c:	89 f0                	mov    %esi,%eax
  801d7e:	e8 6c ff ff ff       	call   801cef <_pipeisclosed>
  801d83:	85 c0                	test   %eax,%eax
  801d85:	75 38                	jne    801dbf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d87:	e8 62 ee ff ff       	call   800bee <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d8c:	8b 43 04             	mov    0x4(%ebx),%eax
  801d8f:	8b 13                	mov    (%ebx),%edx
  801d91:	83 c2 20             	add    $0x20,%edx
  801d94:	39 d0                	cmp    %edx,%eax
  801d96:	73 e2                	jae    801d7a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d98:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d9e:	89 c2                	mov    %eax,%edx
  801da0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801da6:	79 05                	jns    801dad <devpipe_write+0x50>
  801da8:	4a                   	dec    %edx
  801da9:	83 ca e0             	or     $0xffffffe0,%edx
  801dac:	42                   	inc    %edx
  801dad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801db1:	40                   	inc    %eax
  801db2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db5:	47                   	inc    %edi
  801db6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801db9:	75 d1                	jne    801d8c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dbb:	89 f8                	mov    %edi,%eax
  801dbd:	eb 05                	jmp    801dc4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dc4:	83 c4 1c             	add    $0x1c,%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5e                   	pop    %esi
  801dc9:	5f                   	pop    %edi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    

00801dcc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	57                   	push   %edi
  801dd0:	56                   	push   %esi
  801dd1:	53                   	push   %ebx
  801dd2:	83 ec 1c             	sub    $0x1c,%esp
  801dd5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dd8:	89 3c 24             	mov    %edi,(%esp)
  801ddb:	e8 08 f1 ff ff       	call   800ee8 <fd2data>
  801de0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de2:	be 00 00 00 00       	mov    $0x0,%esi
  801de7:	eb 3a                	jmp    801e23 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801de9:	85 f6                	test   %esi,%esi
  801deb:	74 04                	je     801df1 <devpipe_read+0x25>
				return i;
  801ded:	89 f0                	mov    %esi,%eax
  801def:	eb 40                	jmp    801e31 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801df1:	89 da                	mov    %ebx,%edx
  801df3:	89 f8                	mov    %edi,%eax
  801df5:	e8 f5 fe ff ff       	call   801cef <_pipeisclosed>
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	75 2e                	jne    801e2c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dfe:	e8 eb ed ff ff       	call   800bee <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e03:	8b 03                	mov    (%ebx),%eax
  801e05:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e08:	74 df                	je     801de9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e0a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e0f:	79 05                	jns    801e16 <devpipe_read+0x4a>
  801e11:	48                   	dec    %eax
  801e12:	83 c8 e0             	or     $0xffffffe0,%eax
  801e15:	40                   	inc    %eax
  801e16:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e20:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e22:	46                   	inc    %esi
  801e23:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e26:	75 db                	jne    801e03 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e28:	89 f0                	mov    %esi,%eax
  801e2a:	eb 05                	jmp    801e31 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    

00801e39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	57                   	push   %edi
  801e3d:	56                   	push   %esi
  801e3e:	53                   	push   %ebx
  801e3f:	83 ec 3c             	sub    $0x3c,%esp
  801e42:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e45:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e48:	89 04 24             	mov    %eax,(%esp)
  801e4b:	e8 b3 f0 ff ff       	call   800f03 <fd_alloc>
  801e50:	89 c3                	mov    %eax,%ebx
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 45 01 00 00    	js     801f9f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e61:	00 
  801e62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e70:	e8 98 ed ff ff       	call   800c0d <sys_page_alloc>
  801e75:	89 c3                	mov    %eax,%ebx
  801e77:	85 c0                	test   %eax,%eax
  801e79:	0f 88 20 01 00 00    	js     801f9f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e7f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e82:	89 04 24             	mov    %eax,(%esp)
  801e85:	e8 79 f0 ff ff       	call   800f03 <fd_alloc>
  801e8a:	89 c3                	mov    %eax,%ebx
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	0f 88 f8 00 00 00    	js     801f8c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e94:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e9b:	00 
  801e9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eaa:	e8 5e ed ff ff       	call   800c0d <sys_page_alloc>
  801eaf:	89 c3                	mov    %eax,%ebx
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	0f 88 d3 00 00 00    	js     801f8c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ebc:	89 04 24             	mov    %eax,(%esp)
  801ebf:	e8 24 f0 ff ff       	call   800ee8 <fd2data>
  801ec4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ecd:	00 
  801ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed9:	e8 2f ed ff ff       	call   800c0d <sys_page_alloc>
  801ede:	89 c3                	mov    %eax,%ebx
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	0f 88 91 00 00 00    	js     801f79 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eeb:	89 04 24             	mov    %eax,(%esp)
  801eee:	e8 f5 ef ff ff       	call   800ee8 <fd2data>
  801ef3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801efa:	00 
  801efb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f06:	00 
  801f07:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f12:	e8 4a ed ff ff       	call   800c61 <sys_page_map>
  801f17:	89 c3                	mov    %eax,%ebx
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	78 4c                	js     801f69 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f1d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f26:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f32:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f3b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f40:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f4a:	89 04 24             	mov    %eax,(%esp)
  801f4d:	e8 86 ef ff ff       	call   800ed8 <fd2num>
  801f52:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f57:	89 04 24             	mov    %eax,(%esp)
  801f5a:	e8 79 ef ff ff       	call   800ed8 <fd2num>
  801f5f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f62:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f67:	eb 36                	jmp    801f9f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f69:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f74:	e8 3b ed ff ff       	call   800cb4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f79:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f87:	e8 28 ed ff ff       	call   800cb4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9a:	e8 15 ed ff ff       	call   800cb4 <sys_page_unmap>
    err:
	return r;
}
  801f9f:	89 d8                	mov    %ebx,%eax
  801fa1:	83 c4 3c             	add    $0x3c,%esp
  801fa4:	5b                   	pop    %ebx
  801fa5:	5e                   	pop    %esi
  801fa6:	5f                   	pop    %edi
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb9:	89 04 24             	mov    %eax,(%esp)
  801fbc:	e8 95 ef ff ff       	call   800f56 <fd_lookup>
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	78 15                	js     801fda <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc8:	89 04 24             	mov    %eax,(%esp)
  801fcb:	e8 18 ef ff ff       	call   800ee8 <fd2data>
	return _pipeisclosed(fd, p);
  801fd0:	89 c2                	mov    %eax,%edx
  801fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd5:	e8 15 fd ff ff       	call   801cef <_pipeisclosed>
}
  801fda:	c9                   	leave  
  801fdb:	c3                   	ret    

00801fdc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    

00801fe6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fec:	c7 44 24 04 2f 2a 80 	movl   $0x802a2f,0x4(%esp)
  801ff3:	00 
  801ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff7:	89 04 24             	mov    %eax,(%esp)
  801ffa:	e8 1c e8 ff ff       	call   80081b <strcpy>
	return 0;
}
  801fff:	b8 00 00 00 00       	mov    $0x0,%eax
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	57                   	push   %edi
  80200a:	56                   	push   %esi
  80200b:	53                   	push   %ebx
  80200c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802012:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802017:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80201d:	eb 30                	jmp    80204f <devcons_write+0x49>
		m = n - tot;
  80201f:	8b 75 10             	mov    0x10(%ebp),%esi
  802022:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802024:	83 fe 7f             	cmp    $0x7f,%esi
  802027:	76 05                	jbe    80202e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802029:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80202e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802032:	03 45 0c             	add    0xc(%ebp),%eax
  802035:	89 44 24 04          	mov    %eax,0x4(%esp)
  802039:	89 3c 24             	mov    %edi,(%esp)
  80203c:	e8 53 e9 ff ff       	call   800994 <memmove>
		sys_cputs(buf, m);
  802041:	89 74 24 04          	mov    %esi,0x4(%esp)
  802045:	89 3c 24             	mov    %edi,(%esp)
  802048:	e8 f3 ea ff ff       	call   800b40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80204d:	01 f3                	add    %esi,%ebx
  80204f:	89 d8                	mov    %ebx,%eax
  802051:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802054:	72 c9                	jb     80201f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802056:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80205c:	5b                   	pop    %ebx
  80205d:	5e                   	pop    %esi
  80205e:	5f                   	pop    %edi
  80205f:	5d                   	pop    %ebp
  802060:	c3                   	ret    

00802061 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802067:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80206b:	75 07                	jne    802074 <devcons_read+0x13>
  80206d:	eb 25                	jmp    802094 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80206f:	e8 7a eb ff ff       	call   800bee <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802074:	e8 e5 ea ff ff       	call   800b5e <sys_cgetc>
  802079:	85 c0                	test   %eax,%eax
  80207b:	74 f2                	je     80206f <devcons_read+0xe>
  80207d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80207f:	85 c0                	test   %eax,%eax
  802081:	78 1d                	js     8020a0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802083:	83 f8 04             	cmp    $0x4,%eax
  802086:	74 13                	je     80209b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208b:	88 10                	mov    %dl,(%eax)
	return 1;
  80208d:	b8 01 00 00 00       	mov    $0x1,%eax
  802092:	eb 0c                	jmp    8020a0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802094:	b8 00 00 00 00       	mov    $0x0,%eax
  802099:	eb 05                	jmp    8020a0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80209b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    

008020a2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020ae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020b5:	00 
  8020b6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b9:	89 04 24             	mov    %eax,(%esp)
  8020bc:	e8 7f ea ff ff       	call   800b40 <sys_cputs>
}
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    

008020c3 <getchar>:

int
getchar(void)
{
  8020c3:	55                   	push   %ebp
  8020c4:	89 e5                	mov    %esp,%ebp
  8020c6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020d0:	00 
  8020d1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020df:	e8 10 f1 ff ff       	call   8011f4 <read>
	if (r < 0)
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	78 0f                	js     8020f7 <getchar+0x34>
		return r;
	if (r < 1)
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	7e 06                	jle    8020f2 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020ec:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020f0:	eb 05                	jmp    8020f7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020f2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020f7:	c9                   	leave  
  8020f8:	c3                   	ret    

008020f9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802102:	89 44 24 04          	mov    %eax,0x4(%esp)
  802106:	8b 45 08             	mov    0x8(%ebp),%eax
  802109:	89 04 24             	mov    %eax,(%esp)
  80210c:	e8 45 ee ff ff       	call   800f56 <fd_lookup>
  802111:	85 c0                	test   %eax,%eax
  802113:	78 11                	js     802126 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802115:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802118:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80211e:	39 10                	cmp    %edx,(%eax)
  802120:	0f 94 c0             	sete   %al
  802123:	0f b6 c0             	movzbl %al,%eax
}
  802126:	c9                   	leave  
  802127:	c3                   	ret    

00802128 <opencons>:

int
opencons(void)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80212e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802131:	89 04 24             	mov    %eax,(%esp)
  802134:	e8 ca ed ff ff       	call   800f03 <fd_alloc>
  802139:	85 c0                	test   %eax,%eax
  80213b:	78 3c                	js     802179 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80213d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802144:	00 
  802145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80214c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802153:	e8 b5 ea ff ff       	call   800c0d <sys_page_alloc>
  802158:	85 c0                	test   %eax,%eax
  80215a:	78 1d                	js     802179 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80215c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802165:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802167:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802171:	89 04 24             	mov    %eax,(%esp)
  802174:	e8 5f ed ff ff       	call   800ed8 <fd2num>
}
  802179:	c9                   	leave  
  80217a:	c3                   	ret    
	...

0080217c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	56                   	push   %esi
  802180:	53                   	push   %ebx
  802181:	83 ec 10             	sub    $0x10,%esp
  802184:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80218a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  80218d:	85 c0                	test   %eax,%eax
  80218f:	74 0a                	je     80219b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802191:	89 04 24             	mov    %eax,(%esp)
  802194:	e8 8a ec ff ff       	call   800e23 <sys_ipc_recv>
  802199:	eb 0c                	jmp    8021a7 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80219b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8021a2:	e8 7c ec ff ff       	call   800e23 <sys_ipc_recv>
	}
	if (r < 0)
  8021a7:	85 c0                	test   %eax,%eax
  8021a9:	79 16                	jns    8021c1 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8021ab:	85 db                	test   %ebx,%ebx
  8021ad:	74 06                	je     8021b5 <ipc_recv+0x39>
  8021af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8021b5:	85 f6                	test   %esi,%esi
  8021b7:	74 2c                	je     8021e5 <ipc_recv+0x69>
  8021b9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8021bf:	eb 24                	jmp    8021e5 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8021c1:	85 db                	test   %ebx,%ebx
  8021c3:	74 0a                	je     8021cf <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8021c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8021ca:	8b 40 74             	mov    0x74(%eax),%eax
  8021cd:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8021cf:	85 f6                	test   %esi,%esi
  8021d1:	74 0a                	je     8021dd <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8021d3:	a1 08 40 80 00       	mov    0x804008,%eax
  8021d8:	8b 40 78             	mov    0x78(%eax),%eax
  8021db:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8021dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8021e2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8021e5:	83 c4 10             	add    $0x10,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    

008021ec <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	57                   	push   %edi
  8021f0:	56                   	push   %esi
  8021f1:	53                   	push   %ebx
  8021f2:	83 ec 1c             	sub    $0x1c,%esp
  8021f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8021f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8021fe:	85 db                	test   %ebx,%ebx
  802200:	74 19                	je     80221b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802202:	8b 45 14             	mov    0x14(%ebp),%eax
  802205:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80220d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802211:	89 34 24             	mov    %esi,(%esp)
  802214:	e8 e7 eb ff ff       	call   800e00 <sys_ipc_try_send>
  802219:	eb 1c                	jmp    802237 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80221b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802222:	00 
  802223:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80222a:	ee 
  80222b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80222f:	89 34 24             	mov    %esi,(%esp)
  802232:	e8 c9 eb ff ff       	call   800e00 <sys_ipc_try_send>
		}
		if (r == 0)
  802237:	85 c0                	test   %eax,%eax
  802239:	74 2c                	je     802267 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80223b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80223e:	74 20                	je     802260 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802240:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802244:	c7 44 24 08 3b 2a 80 	movl   $0x802a3b,0x8(%esp)
  80224b:	00 
  80224c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802253:	00 
  802254:	c7 04 24 4e 2a 80 00 	movl   $0x802a4e,(%esp)
  80225b:	e8 18 df ff ff       	call   800178 <_panic>
		}
		sys_yield();
  802260:	e8 89 e9 ff ff       	call   800bee <sys_yield>
	}
  802265:	eb 97                	jmp    8021fe <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802267:	83 c4 1c             	add    $0x1c,%esp
  80226a:	5b                   	pop    %ebx
  80226b:	5e                   	pop    %esi
  80226c:	5f                   	pop    %edi
  80226d:	5d                   	pop    %ebp
  80226e:	c3                   	ret    

0080226f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80226f:	55                   	push   %ebp
  802270:	89 e5                	mov    %esp,%ebp
  802272:	53                   	push   %ebx
  802273:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802276:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80227b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802282:	89 c2                	mov    %eax,%edx
  802284:	c1 e2 07             	shl    $0x7,%edx
  802287:	29 ca                	sub    %ecx,%edx
  802289:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80228f:	8b 52 50             	mov    0x50(%edx),%edx
  802292:	39 da                	cmp    %ebx,%edx
  802294:	75 0f                	jne    8022a5 <ipc_find_env+0x36>
			return envs[i].env_id;
  802296:	c1 e0 07             	shl    $0x7,%eax
  802299:	29 c8                	sub    %ecx,%eax
  80229b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022a0:	8b 40 40             	mov    0x40(%eax),%eax
  8022a3:	eb 0c                	jmp    8022b1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022a5:	40                   	inc    %eax
  8022a6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022ab:	75 ce                	jne    80227b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022ad:	66 b8 00 00          	mov    $0x0,%ax
}
  8022b1:	5b                   	pop    %ebx
  8022b2:	5d                   	pop    %ebp
  8022b3:	c3                   	ret    

008022b4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022ba:	89 c2                	mov    %eax,%edx
  8022bc:	c1 ea 16             	shr    $0x16,%edx
  8022bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022c6:	f6 c2 01             	test   $0x1,%dl
  8022c9:	74 1e                	je     8022e9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022cb:	c1 e8 0c             	shr    $0xc,%eax
  8022ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022d5:	a8 01                	test   $0x1,%al
  8022d7:	74 17                	je     8022f0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022d9:	c1 e8 0c             	shr    $0xc,%eax
  8022dc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022e3:	ef 
  8022e4:	0f b7 c0             	movzwl %ax,%eax
  8022e7:	eb 0c                	jmp    8022f5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ee:	eb 05                	jmp    8022f5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022f0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022f5:	5d                   	pop    %ebp
  8022f6:	c3                   	ret    
	...

008022f8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8022f8:	55                   	push   %ebp
  8022f9:	57                   	push   %edi
  8022fa:	56                   	push   %esi
  8022fb:	83 ec 10             	sub    $0x10,%esp
  8022fe:	8b 74 24 20          	mov    0x20(%esp),%esi
  802302:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802306:	89 74 24 04          	mov    %esi,0x4(%esp)
  80230a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80230e:	89 cd                	mov    %ecx,%ebp
  802310:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802314:	85 c0                	test   %eax,%eax
  802316:	75 2c                	jne    802344 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802318:	39 f9                	cmp    %edi,%ecx
  80231a:	77 68                	ja     802384 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80231c:	85 c9                	test   %ecx,%ecx
  80231e:	75 0b                	jne    80232b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802320:	b8 01 00 00 00       	mov    $0x1,%eax
  802325:	31 d2                	xor    %edx,%edx
  802327:	f7 f1                	div    %ecx
  802329:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	89 f8                	mov    %edi,%eax
  80232f:	f7 f1                	div    %ecx
  802331:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802333:	89 f0                	mov    %esi,%eax
  802335:	f7 f1                	div    %ecx
  802337:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802339:	89 f0                	mov    %esi,%eax
  80233b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80233d:	83 c4 10             	add    $0x10,%esp
  802340:	5e                   	pop    %esi
  802341:	5f                   	pop    %edi
  802342:	5d                   	pop    %ebp
  802343:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802344:	39 f8                	cmp    %edi,%eax
  802346:	77 2c                	ja     802374 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802348:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80234b:	83 f6 1f             	xor    $0x1f,%esi
  80234e:	75 4c                	jne    80239c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802350:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802352:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802357:	72 0a                	jb     802363 <__udivdi3+0x6b>
  802359:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80235d:	0f 87 ad 00 00 00    	ja     802410 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802363:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802368:	89 f0                	mov    %esi,%eax
  80236a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80236c:	83 c4 10             	add    $0x10,%esp
  80236f:	5e                   	pop    %esi
  802370:	5f                   	pop    %edi
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    
  802373:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802374:	31 ff                	xor    %edi,%edi
  802376:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802378:	89 f0                	mov    %esi,%eax
  80237a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	5e                   	pop    %esi
  802380:	5f                   	pop    %edi
  802381:	5d                   	pop    %ebp
  802382:	c3                   	ret    
  802383:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802384:	89 fa                	mov    %edi,%edx
  802386:	89 f0                	mov    %esi,%eax
  802388:	f7 f1                	div    %ecx
  80238a:	89 c6                	mov    %eax,%esi
  80238c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80238e:	89 f0                	mov    %esi,%eax
  802390:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802392:	83 c4 10             	add    $0x10,%esp
  802395:	5e                   	pop    %esi
  802396:	5f                   	pop    %edi
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    
  802399:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80239c:	89 f1                	mov    %esi,%ecx
  80239e:	d3 e0                	shl    %cl,%eax
  8023a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023a4:	b8 20 00 00 00       	mov    $0x20,%eax
  8023a9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8023ab:	89 ea                	mov    %ebp,%edx
  8023ad:	88 c1                	mov    %al,%cl
  8023af:	d3 ea                	shr    %cl,%edx
  8023b1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023b5:	09 ca                	or     %ecx,%edx
  8023b7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8023bb:	89 f1                	mov    %esi,%ecx
  8023bd:	d3 e5                	shl    %cl,%ebp
  8023bf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8023c3:	89 fd                	mov    %edi,%ebp
  8023c5:	88 c1                	mov    %al,%cl
  8023c7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8023c9:	89 fa                	mov    %edi,%edx
  8023cb:	89 f1                	mov    %esi,%ecx
  8023cd:	d3 e2                	shl    %cl,%edx
  8023cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023d3:	88 c1                	mov    %al,%cl
  8023d5:	d3 ef                	shr    %cl,%edi
  8023d7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023d9:	89 f8                	mov    %edi,%eax
  8023db:	89 ea                	mov    %ebp,%edx
  8023dd:	f7 74 24 08          	divl   0x8(%esp)
  8023e1:	89 d1                	mov    %edx,%ecx
  8023e3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8023e5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023e9:	39 d1                	cmp    %edx,%ecx
  8023eb:	72 17                	jb     802404 <__udivdi3+0x10c>
  8023ed:	74 09                	je     8023f8 <__udivdi3+0x100>
  8023ef:	89 fe                	mov    %edi,%esi
  8023f1:	31 ff                	xor    %edi,%edi
  8023f3:	e9 41 ff ff ff       	jmp    802339 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8023f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023fc:	89 f1                	mov    %esi,%ecx
  8023fe:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802400:	39 c2                	cmp    %eax,%edx
  802402:	73 eb                	jae    8023ef <__udivdi3+0xf7>
		{
		  q0--;
  802404:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802407:	31 ff                	xor    %edi,%edi
  802409:	e9 2b ff ff ff       	jmp    802339 <__udivdi3+0x41>
  80240e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802410:	31 f6                	xor    %esi,%esi
  802412:	e9 22 ff ff ff       	jmp    802339 <__udivdi3+0x41>
	...

00802418 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802418:	55                   	push   %ebp
  802419:	57                   	push   %edi
  80241a:	56                   	push   %esi
  80241b:	83 ec 20             	sub    $0x20,%esp
  80241e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802422:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802426:	89 44 24 14          	mov    %eax,0x14(%esp)
  80242a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80242e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802432:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802436:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802438:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80243a:	85 ed                	test   %ebp,%ebp
  80243c:	75 16                	jne    802454 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80243e:	39 f1                	cmp    %esi,%ecx
  802440:	0f 86 a6 00 00 00    	jbe    8024ec <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802446:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802448:	89 d0                	mov    %edx,%eax
  80244a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80244c:	83 c4 20             	add    $0x20,%esp
  80244f:	5e                   	pop    %esi
  802450:	5f                   	pop    %edi
  802451:	5d                   	pop    %ebp
  802452:	c3                   	ret    
  802453:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802454:	39 f5                	cmp    %esi,%ebp
  802456:	0f 87 ac 00 00 00    	ja     802508 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80245c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80245f:	83 f0 1f             	xor    $0x1f,%eax
  802462:	89 44 24 10          	mov    %eax,0x10(%esp)
  802466:	0f 84 a8 00 00 00    	je     802514 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80246c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802470:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802472:	bf 20 00 00 00       	mov    $0x20,%edi
  802477:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80247b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80247f:	89 f9                	mov    %edi,%ecx
  802481:	d3 e8                	shr    %cl,%eax
  802483:	09 e8                	or     %ebp,%eax
  802485:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802489:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80248d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802491:	d3 e0                	shl    %cl,%eax
  802493:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802497:	89 f2                	mov    %esi,%edx
  802499:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80249b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80249f:	d3 e0                	shl    %cl,%eax
  8024a1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8024a5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024a9:	89 f9                	mov    %edi,%ecx
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8024af:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024b1:	89 f2                	mov    %esi,%edx
  8024b3:	f7 74 24 18          	divl   0x18(%esp)
  8024b7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8024b9:	f7 64 24 0c          	mull   0xc(%esp)
  8024bd:	89 c5                	mov    %eax,%ebp
  8024bf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024c1:	39 d6                	cmp    %edx,%esi
  8024c3:	72 67                	jb     80252c <__umoddi3+0x114>
  8024c5:	74 75                	je     80253c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8024c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024cb:	29 e8                	sub    %ebp,%eax
  8024cd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8024cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024d3:	d3 e8                	shr    %cl,%eax
  8024d5:	89 f2                	mov    %esi,%edx
  8024d7:	89 f9                	mov    %edi,%ecx
  8024d9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8024db:	09 d0                	or     %edx,%eax
  8024dd:	89 f2                	mov    %esi,%edx
  8024df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024e3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024e5:	83 c4 20             	add    $0x20,%esp
  8024e8:	5e                   	pop    %esi
  8024e9:	5f                   	pop    %edi
  8024ea:	5d                   	pop    %ebp
  8024eb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024ec:	85 c9                	test   %ecx,%ecx
  8024ee:	75 0b                	jne    8024fb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f5:	31 d2                	xor    %edx,%edx
  8024f7:	f7 f1                	div    %ecx
  8024f9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024fb:	89 f0                	mov    %esi,%eax
  8024fd:	31 d2                	xor    %edx,%edx
  8024ff:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802501:	89 f8                	mov    %edi,%eax
  802503:	e9 3e ff ff ff       	jmp    802446 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802508:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80250a:	83 c4 20             	add    $0x20,%esp
  80250d:	5e                   	pop    %esi
  80250e:	5f                   	pop    %edi
  80250f:	5d                   	pop    %ebp
  802510:	c3                   	ret    
  802511:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802514:	39 f5                	cmp    %esi,%ebp
  802516:	72 04                	jb     80251c <__umoddi3+0x104>
  802518:	39 f9                	cmp    %edi,%ecx
  80251a:	77 06                	ja     802522 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80251c:	89 f2                	mov    %esi,%edx
  80251e:	29 cf                	sub    %ecx,%edi
  802520:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802522:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802524:	83 c4 20             	add    $0x20,%esp
  802527:	5e                   	pop    %esi
  802528:	5f                   	pop    %edi
  802529:	5d                   	pop    %ebp
  80252a:	c3                   	ret    
  80252b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80252c:	89 d1                	mov    %edx,%ecx
  80252e:	89 c5                	mov    %eax,%ebp
  802530:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802534:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802538:	eb 8d                	jmp    8024c7 <__umoddi3+0xaf>
  80253a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80253c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802540:	72 ea                	jb     80252c <__umoddi3+0x114>
  802542:	89 f1                	mov    %esi,%ecx
  802544:	eb 81                	jmp    8024c7 <__umoddi3+0xaf>
