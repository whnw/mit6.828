
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: lsfd [-1]\n");
  80003a:	c7 04 24 20 28 80 00 	movl   $0x802820,(%esp)
  800041:	e8 fe 01 00 00       	call   800244 <cprintf>
	exit();
  800046:	e8 3d 01 00 00       	call   800188 <exit>
}
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec cc 00 00 00    	sub    $0xcc,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800063:	8b 45 0c             	mov    0xc(%ebp),%eax
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	8d 45 08             	lea    0x8(%ebp),%eax
  80006d:	89 04 24             	mov    %eax,(%esp)
  800070:	e8 37 0e 00 00       	call   800eac <argstart>
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  800075:	bf 00 00 00 00       	mov    $0x0,%edi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80007a:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  800080:	eb 11                	jmp    800093 <umain+0x46>
		if (i == '1')
  800082:	83 f8 31             	cmp    $0x31,%eax
  800085:	74 07                	je     80008e <umain+0x41>
			usefprint = 1;
		else
			usage();
  800087:	e8 a8 ff ff ff       	call   800034 <usage>
  80008c:	eb 05                	jmp    800093 <umain+0x46>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  80008e:	bf 01 00 00 00       	mov    $0x1,%edi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800093:	89 1c 24             	mov    %ebx,(%esp)
  800096:	e8 4a 0e 00 00       	call   800ee5 <argnext>
  80009b:	85 c0                	test   %eax,%eax
  80009d:	79 e3                	jns    800082 <umain+0x35>
  80009f:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a4:	8d b5 5c ff ff ff    	lea    -0xa4(%ebp),%esi
  8000aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ae:	89 1c 24             	mov    %ebx,(%esp)
  8000b1:	e8 80 14 00 00       	call   801536 <fstat>
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	78 66                	js     800120 <umain+0xd3>
			if (usefprint)
  8000ba:	85 ff                	test   %edi,%edi
  8000bc:	74 36                	je     8000f4 <umain+0xa7>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000c1:	8b 40 04             	mov    0x4(%eax),%eax
  8000c4:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000cb:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000d2:	89 44 24 10          	mov    %eax,0x10(%esp)
					i, st.st_name, st.st_isdir,
  8000d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000de:	c7 44 24 04 34 28 80 	movl   $0x802834,0x4(%esp)
  8000e5:	00 
  8000e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ed:	e8 96 18 00 00       	call   801988 <fprintf>
  8000f2:	eb 2c                	jmp    800120 <umain+0xd3>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000f7:	8b 40 04             	mov    0x4(%eax),%eax
  8000fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800101:	89 44 24 10          	mov    %eax,0x10(%esp)
  800105:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800108:	89 44 24 0c          	mov    %eax,0xc(%esp)
					i, st.st_name, st.st_isdir,
  80010c:	89 74 24 08          	mov    %esi,0x8(%esp)
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  800110:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800114:	c7 04 24 34 28 80 00 	movl   $0x802834,(%esp)
  80011b:	e8 24 01 00 00       	call   800244 <cprintf>
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  800120:	43                   	inc    %ebx
  800121:	83 fb 20             	cmp    $0x20,%ebx
  800124:	75 84                	jne    8000aa <umain+0x5d>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800126:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	83 ec 10             	sub    $0x10,%esp
  80013c:	8b 75 08             	mov    0x8(%ebp),%esi
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800142:	e8 5c 0a 00 00       	call   800ba3 <sys_getenvid>
  800147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800153:	c1 e0 07             	shl    $0x7,%eax
  800156:	29 d0                	sub    %edx,%eax
  800158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015d:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800162:	85 f6                	test   %esi,%esi
  800164:	7e 07                	jle    80016d <libmain+0x39>
		binaryname = argv[0];
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800171:	89 34 24             	mov    %esi,(%esp)
  800174:	e8 d4 fe ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800179:	e8 0a 00 00 00       	call   800188 <exit>
}
  80017e:	83 c4 10             	add    $0x10,%esp
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    
  800185:	00 00                	add    %al,(%eax)
	...

00800188 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80018e:	e8 58 10 00 00       	call   8011eb <close_all>
	sys_env_destroy(0);
  800193:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019a:	e8 b2 09 00 00       	call   800b51 <sys_env_destroy>
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    
  8001a1:	00 00                	add    %al,(%eax)
	...

008001a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 14             	sub    $0x14,%esp
  8001ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ae:	8b 03                	mov    (%ebx),%eax
  8001b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b7:	40                   	inc    %eax
  8001b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bf:	75 19                	jne    8001da <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c8:	00 
  8001c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 40 09 00 00       	call   800b14 <sys_cputs>
		b->idx = 0;
  8001d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001da:	ff 43 04             	incl   0x4(%ebx)
}
  8001dd:	83 c4 14             	add    $0x14,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	8b 45 0c             	mov    0xc(%ebp),%eax
  800203:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 a4 01 80 00 	movl   $0x8001a4,(%esp)
  80021f:	e8 82 01 00 00       	call   8003a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800224:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800234:	89 04 24             	mov    %eax,(%esp)
  800237:	e8 d8 08 00 00       	call   800b14 <sys_cputs>

	return b.cnt;
}
  80023c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	8b 45 08             	mov    0x8(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 87 ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    
	...

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	85 c0                	test   %eax,%eax
  800282:	75 08                	jne    80028c <printnum+0x2c>
  800284:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800287:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028a:	77 57                	ja     8002e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800290:	4b                   	dec    %ebx
  800291:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800295:	8b 45 10             	mov    0x10(%ebp),%eax
  800298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ab:	00 
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	e8 f6 22 00 00       	call   8025b4 <__udivdi3>
  8002be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cd:	89 fa                	mov    %edi,%edx
  8002cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d2:	e8 89 ff ff ff       	call   800260 <printnum>
  8002d7:	eb 0f                	jmp    8002e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002dd:	89 34 24             	mov    %esi,(%esp)
  8002e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e3:	4b                   	dec    %ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f f1                	jg     8002d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fe:	00 
  8002ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030c:	e8 c3 23 00 00       	call   8026d4 <__umoddi3>
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	0f be 80 66 28 80 00 	movsbl 0x802866(%eax),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800322:	83 c4 3c             	add    $0x3c,%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032d:	83 fa 01             	cmp    $0x1,%edx
  800330:	7e 0e                	jle    800340 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 08             	lea    0x8(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	8b 52 04             	mov    0x4(%edx),%edx
  80033e:	eb 22                	jmp    800362 <getuint+0x38>
	else if (lflag)
  800340:	85 d2                	test   %edx,%edx
  800342:	74 10                	je     800354 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	eb 0e                	jmp    800362 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	3b 50 04             	cmp    0x4(%eax),%edx
  800372:	73 08                	jae    80037c <sprintputch+0x18>
		*b->buf++ = ch;
  800374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800377:	88 0a                	mov    %cl,(%edx)
  800379:	42                   	inc    %edx
  80037a:	89 10                	mov    %edx,(%eax)
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800384:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800387:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038b:	8b 45 10             	mov    0x10(%ebp),%eax
  80038e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	e8 02 00 00 00       	call   8003a6 <vprintfmt>
	va_end(ap);
}
  8003a4:	c9                   	leave  
  8003a5:	c3                   	ret    

008003a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	57                   	push   %edi
  8003aa:	56                   	push   %esi
  8003ab:	53                   	push   %ebx
  8003ac:	83 ec 4c             	sub    $0x4c,%esp
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 6b 03 00 00    	je     80072a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	0f b6 06             	movzbl (%esi),%eax
  8003cc:	46                   	inc    %esi
  8003cd:	83 f8 25             	cmp    $0x25,%eax
  8003d0:	75 e5                	jne    8003b7 <vprintfmt+0x11>
  8003d2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ee:	eb 26                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003f7:	eb 1d                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003fc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800400:	eb 14                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800405:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80040c:	eb 08                	jmp    800416 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80040e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800411:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	0f b6 06             	movzbl (%esi),%eax
  800419:	8d 56 01             	lea    0x1(%esi),%edx
  80041c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80041f:	8a 16                	mov    (%esi),%dl
  800421:	83 ea 23             	sub    $0x23,%edx
  800424:	80 fa 55             	cmp    $0x55,%dl
  800427:	0f 87 e1 02 00 00    	ja     80070e <vprintfmt+0x368>
  80042d:	0f b6 d2             	movzbl %dl,%edx
  800430:	ff 24 95 a0 29 80 00 	jmp    *0x8029a0(,%edx,4)
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800442:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800446:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800449:	8d 50 d0             	lea    -0x30(%eax),%edx
  80044c:	83 fa 09             	cmp    $0x9,%edx
  80044f:	77 2a                	ja     80047b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800451:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800452:	eb eb                	jmp    80043f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800462:	eb 17                	jmp    80047b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800464:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800468:	78 98                	js     800402 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046d:	eb a7                	jmp    800416 <vprintfmt+0x70>
  80046f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800472:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800479:	eb 9b                	jmp    800416 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80047b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047f:	79 95                	jns    800416 <vprintfmt+0x70>
  800481:	eb 8b                	jmp    80040e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800483:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800487:	eb 8d                	jmp    800416 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a1:	e9 23 ff ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	79 02                	jns    8004b7 <vprintfmt+0x111>
  8004b5:	f7 d8                	neg    %eax
  8004b7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 f8 10             	cmp    $0x10,%eax
  8004bc:	7f 0b                	jg     8004c9 <vprintfmt+0x123>
  8004be:	8b 04 85 00 2b 80 00 	mov    0x802b00(,%eax,4),%eax
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	75 23                	jne    8004ec <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004cd:	c7 44 24 08 7e 28 80 	movl   $0x80287e,0x8(%esp)
  8004d4:	00 
  8004d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 9a fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e7:	e9 dd fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f0:	c7 44 24 08 39 2c 80 	movl   $0x802c39,0x8(%esp)
  8004f7:	00 
  8004f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ff:	89 14 24             	mov    %edx,(%esp)
  800502:	e8 77 fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050a:	e9 ba fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
  80050f:	89 f9                	mov    %edi,%ecx
  800511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800514:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 30                	mov    (%eax),%esi
  800522:	85 f6                	test   %esi,%esi
  800524:	75 05                	jne    80052b <vprintfmt+0x185>
				p = "(null)";
  800526:	be 77 28 80 00       	mov    $0x802877,%esi
			if (width > 0 && padc != '-')
  80052b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052f:	0f 8e 84 00 00 00    	jle    8005b9 <vprintfmt+0x213>
  800535:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800539:	74 7e                	je     8005b9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053f:	89 34 24             	mov    %esi,(%esp)
  800542:	e8 8b 02 00 00       	call   8007d2 <strnlen>
  800547:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80054a:	29 c2                	sub    %eax,%edx
  80054c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80054f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800553:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800556:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800559:	89 de                	mov    %ebx,%esi
  80055b:	89 d3                	mov    %edx,%ebx
  80055d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	eb 0b                	jmp    80056c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800561:	89 74 24 04          	mov    %esi,0x4(%esp)
  800565:	89 3c 24             	mov    %edi,(%esp)
  800568:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	4b                   	dec    %ebx
  80056c:	85 db                	test   %ebx,%ebx
  80056e:	7f f1                	jg     800561 <vprintfmt+0x1bb>
  800570:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800573:	89 f3                	mov    %esi,%ebx
  800575:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800578:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057b:	85 c0                	test   %eax,%eax
  80057d:	79 05                	jns    800584 <vprintfmt+0x1de>
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800587:	29 c2                	sub    %eax,%edx
  800589:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80058c:	eb 2b                	jmp    8005b9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800592:	74 18                	je     8005ac <vprintfmt+0x206>
  800594:	8d 50 e0             	lea    -0x20(%eax),%edx
  800597:	83 fa 5e             	cmp    $0x5e,%edx
  80059a:	76 10                	jbe    8005ac <vprintfmt+0x206>
					putch('?', putdat);
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
  8005aa:	eb 0a                	jmp    8005b6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b9:	0f be 06             	movsbl (%esi),%eax
  8005bc:	46                   	inc    %esi
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	74 21                	je     8005e2 <vprintfmt+0x23c>
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	78 c9                	js     80058e <vprintfmt+0x1e8>
  8005c5:	4f                   	dec    %edi
  8005c6:	79 c6                	jns    80058e <vprintfmt+0x1e8>
  8005c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cb:	89 de                	mov    %ebx,%esi
  8005cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d0:	eb 18                	jmp    8005ea <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005df:	4b                   	dec    %ebx
  8005e0:	eb 08                	jmp    8005ea <vprintfmt+0x244>
  8005e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ea:	85 db                	test   %ebx,%ebx
  8005ec:	7f e4                	jg     8005d2 <vprintfmt+0x22c>
  8005ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f6:	e9 ce fd ff ff       	jmp    8003c9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fb:	83 f9 01             	cmp    $0x1,%ecx
  8005fe:	7e 10                	jle    800610 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 08             	lea    0x8(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 30                	mov    (%eax),%esi
  80060b:	8b 78 04             	mov    0x4(%eax),%edi
  80060e:	eb 26                	jmp    800636 <vprintfmt+0x290>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	74 12                	je     800626 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	89 f7                	mov    %esi,%edi
  800621:	c1 ff 1f             	sar    $0x1f,%edi
  800624:	eb 10                	jmp    800636 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 30                	mov    (%eax),%esi
  800631:	89 f7                	mov    %esi,%edi
  800633:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800636:	85 ff                	test   %edi,%edi
  800638:	78 0a                	js     800644 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	e9 8c 00 00 00       	jmp    8006d0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800652:	f7 de                	neg    %esi
  800654:	83 d7 00             	adc    $0x0,%edi
  800657:	f7 df                	neg    %edi
			}
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	eb 70                	jmp    8006d0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800660:	89 ca                	mov    %ecx,%edx
  800662:	8d 45 14             	lea    0x14(%ebp),%eax
  800665:	e8 c0 fc ff ff       	call   80032a <getuint>
  80066a:	89 c6                	mov    %eax,%esi
  80066c:	89 d7                	mov    %edx,%edi
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800673:	eb 5b                	jmp    8006d0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800675:	89 ca                	mov    %ecx,%edx
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 ab fc ff ff       	call   80032a <getuint>
  80067f:	89 c6                	mov    %eax,%esi
  800681:	89 d7                	mov    %edx,%edi
			base = 8;
  800683:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800688:	eb 46                	jmp    8006d0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006af:	8b 30                	mov    (%eax),%esi
  8006b1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bb:	eb 13                	jmp    8006d0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bd:	89 ca                	mov    %ecx,%edx
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c2:	e8 63 fc ff ff       	call   80032a <getuint>
  8006c7:	89 c6                	mov    %eax,%esi
  8006c9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e3:	89 34 24             	mov    %esi,(%esp)
  8006e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ea:	89 da                	mov    %ebx,%edx
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	e8 6c fb ff ff       	call   800260 <printnum>
			break;
  8006f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f7:	e9 cd fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800706:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800709:	e9 bb fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800712:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	eb 01                	jmp    80071f <vprintfmt+0x379>
  80071e:	4e                   	dec    %esi
  80071f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800723:	75 f9                	jne    80071e <vprintfmt+0x378>
  800725:	e9 9f fc ff ff       	jmp    8003c9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80072a:	83 c4 4c             	add    $0x4c,%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 28             	sub    $0x28,%esp
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800741:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800745:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800748:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 30                	je     800783 <vsnprintf+0x51>
  800753:	85 d2                	test   %edx,%edx
  800755:	7e 33                	jle    80078a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	8b 45 10             	mov    0x10(%ebp),%eax
  800761:	89 44 24 08          	mov    %eax,0x8(%esp)
  800765:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076c:	c7 04 24 64 03 80 00 	movl   $0x800364,(%esp)
  800773:	e8 2e fc ff ff       	call   8003a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800778:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800781:	eb 0c                	jmp    80078f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800788:	eb 05                	jmp    80078f <vsnprintf+0x5d>
  80078a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079e:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	89 04 24             	mov    %eax,(%esp)
  8007b2:	e8 7b ff ff ff       	call   800732 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    
  8007b9:	00 00                	add    %al,(%eax)
	...

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	eb 01                	jmp    8007ca <strlen+0xe>
		n++;
  8007c9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ce:	75 f9                	jne    8007c9 <strlen+0xd>
		n++;
	return n;
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e0:	eb 01                	jmp    8007e3 <strnlen+0x11>
		n++;
  8007e2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 d0                	cmp    %edx,%eax
  8007e5:	74 06                	je     8007ed <strnlen+0x1b>
  8007e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007eb:	75 f5                	jne    8007e2 <strnlen+0x10>
		n++;
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800801:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800804:	42                   	inc    %edx
  800805:	84 c9                	test   %cl,%cl
  800807:	75 f5                	jne    8007fe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800809:	5b                   	pop    %ebx
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800816:	89 1c 24             	mov    %ebx,(%esp)
  800819:	e8 9e ff ff ff       	call   8007bc <strlen>
	strcpy(dst + len, src);
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800821:	89 54 24 04          	mov    %edx,0x4(%esp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	e8 c0 ff ff ff       	call   8007ef <strcpy>
	return dst;
}
  80082f:	89 d8                	mov    %ebx,%eax
  800831:	83 c4 08             	add    $0x8,%esp
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800842:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084a:	eb 0c                	jmp    800858 <strncpy+0x21>
		*dst++ = *src;
  80084c:	8a 1a                	mov    (%edx),%bl
  80084e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 3a 01             	cmpb   $0x1,(%edx)
  800854:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	41                   	inc    %ecx
  800858:	39 f1                	cmp    %esi,%ecx
  80085a:	75 f0                	jne    80084c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086e:	85 d2                	test   %edx,%edx
  800870:	75 0a                	jne    80087c <strlcpy+0x1c>
  800872:	89 f0                	mov    %esi,%eax
  800874:	eb 1a                	jmp    800890 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800876:	88 18                	mov    %bl,(%eax)
  800878:	40                   	inc    %eax
  800879:	41                   	inc    %ecx
  80087a:	eb 02                	jmp    80087e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80087e:	4a                   	dec    %edx
  80087f:	74 0a                	je     80088b <strlcpy+0x2b>
  800881:	8a 19                	mov    (%ecx),%bl
  800883:	84 db                	test   %bl,%bl
  800885:	75 ef                	jne    800876 <strlcpy+0x16>
  800887:	89 c2                	mov    %eax,%edx
  800889:	eb 02                	jmp    80088d <strlcpy+0x2d>
  80088b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80088d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800890:	29 f0                	sub    %esi,%eax
}
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089f:	eb 02                	jmp    8008a3 <strcmp+0xd>
		p++, q++;
  8008a1:	41                   	inc    %ecx
  8008a2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a3:	8a 01                	mov    (%ecx),%al
  8008a5:	84 c0                	test   %al,%al
  8008a7:	74 04                	je     8008ad <strcmp+0x17>
  8008a9:	3a 02                	cmp    (%edx),%al
  8008ab:	74 f4                	je     8008a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 c0             	movzbl %al,%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008c4:	eb 03                	jmp    8008c9 <strncmp+0x12>
		n--, p++, q++;
  8008c6:	4a                   	dec    %edx
  8008c7:	40                   	inc    %eax
  8008c8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	74 14                	je     8008e1 <strncmp+0x2a>
  8008cd:	8a 18                	mov    (%eax),%bl
  8008cf:	84 db                	test   %bl,%bl
  8008d1:	74 04                	je     8008d7 <strncmp+0x20>
  8008d3:	3a 19                	cmp    (%ecx),%bl
  8008d5:	74 ef                	je     8008c6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 00             	movzbl (%eax),%eax
  8008da:	0f b6 11             	movzbl (%ecx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
  8008df:	eb 05                	jmp    8008e6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f2:	eb 05                	jmp    8008f9 <strchr+0x10>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 0c                	je     800904 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f8:	40                   	inc    %eax
  8008f9:	8a 10                	mov    (%eax),%dl
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	75 f5                	jne    8008f4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090f:	eb 05                	jmp    800916 <strfind+0x10>
		if (*s == c)
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 07                	je     80091c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800915:	40                   	inc    %eax
  800916:	8a 10                	mov    (%eax),%dl
  800918:	84 d2                	test   %dl,%dl
  80091a:	75 f5                	jne    800911 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	57                   	push   %edi
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 7d 08             	mov    0x8(%ebp),%edi
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 30                	je     800961 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 25                	jne    80095e <memset+0x40>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 20                	jne    80095e <memset+0x40>
		c &= 0xFF;
  80093e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800941:	89 d3                	mov    %edx,%ebx
  800943:	c1 e3 08             	shl    $0x8,%ebx
  800946:	89 d6                	mov    %edx,%esi
  800948:	c1 e6 18             	shl    $0x18,%esi
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	c1 e0 10             	shl    $0x10,%eax
  800950:	09 f0                	or     %esi,%eax
  800952:	09 d0                	or     %edx,%eax
  800954:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800956:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800959:	fc                   	cld    
  80095a:	f3 ab                	rep stos %eax,%es:(%edi)
  80095c:	eb 03                	jmp    800961 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095e:	fc                   	cld    
  80095f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800961:	89 f8                	mov    %edi,%eax
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800976:	39 c6                	cmp    %eax,%esi
  800978:	73 34                	jae    8009ae <memmove+0x46>
  80097a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097d:	39 d0                	cmp    %edx,%eax
  80097f:	73 2d                	jae    8009ae <memmove+0x46>
		s += n;
		d += n;
  800981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	f6 c2 03             	test   $0x3,%dl
  800987:	75 1b                	jne    8009a4 <memmove+0x3c>
  800989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098f:	75 13                	jne    8009a4 <memmove+0x3c>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 0e                	jne    8009a4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 07                	jmp    8009ab <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a4:	4f                   	dec    %edi
  8009a5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a8:	fd                   	std    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ab:	fc                   	cld    
  8009ac:	eb 20                	jmp    8009ce <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b4:	75 13                	jne    8009c9 <memmove+0x61>
  8009b6:	a8 03                	test   $0x3,%al
  8009b8:	75 0f                	jne    8009c9 <memmove+0x61>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	89 04 24             	mov    %eax,(%esp)
  8009ec:	e8 77 ff ff ff       	call   800968 <memmove>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	eb 16                	jmp    800a1f <memcmp+0x2c>
		if (*s1 != *s2)
  800a09:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a0c:	42                   	inc    %edx
  800a0d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a11:	38 c8                	cmp    %cl,%al
  800a13:	74 0a                	je     800a1f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a15:	0f b6 c0             	movzbl %al,%eax
  800a18:	0f b6 c9             	movzbl %cl,%ecx
  800a1b:	29 c8                	sub    %ecx,%eax
  800a1d:	eb 09                	jmp    800a28 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	39 da                	cmp    %ebx,%edx
  800a21:	75 e6                	jne    800a09 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5f                   	pop    %edi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a36:	89 c2                	mov    %eax,%edx
  800a38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3b:	eb 05                	jmp    800a42 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3d:	38 08                	cmp    %cl,(%eax)
  800a3f:	74 05                	je     800a46 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a41:	40                   	inc    %eax
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	72 f7                	jb     800a3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a54:	eb 01                	jmp    800a57 <strtol+0xf>
		s++;
  800a56:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a57:	8a 02                	mov    (%edx),%al
  800a59:	3c 20                	cmp    $0x20,%al
  800a5b:	74 f9                	je     800a56 <strtol+0xe>
  800a5d:	3c 09                	cmp    $0x9,%al
  800a5f:	74 f5                	je     800a56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a61:	3c 2b                	cmp    $0x2b,%al
  800a63:	75 08                	jne    800a6d <strtol+0x25>
		s++;
  800a65:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6b:	eb 13                	jmp    800a80 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6d:	3c 2d                	cmp    $0x2d,%al
  800a6f:	75 0a                	jne    800a7b <strtol+0x33>
		s++, neg = 1;
  800a71:	8d 52 01             	lea    0x1(%edx),%edx
  800a74:	bf 01 00 00 00       	mov    $0x1,%edi
  800a79:	eb 05                	jmp    800a80 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	74 05                	je     800a89 <strtol+0x41>
  800a84:	83 fb 10             	cmp    $0x10,%ebx
  800a87:	75 28                	jne    800ab1 <strtol+0x69>
  800a89:	8a 02                	mov    (%edx),%al
  800a8b:	3c 30                	cmp    $0x30,%al
  800a8d:	75 10                	jne    800a9f <strtol+0x57>
  800a8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a93:	75 0a                	jne    800a9f <strtol+0x57>
		s += 2, base = 16;
  800a95:	83 c2 02             	add    $0x2,%edx
  800a98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9d:	eb 12                	jmp    800ab1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a9f:	85 db                	test   %ebx,%ebx
  800aa1:	75 0e                	jne    800ab1 <strtol+0x69>
  800aa3:	3c 30                	cmp    $0x30,%al
  800aa5:	75 05                	jne    800aac <strtol+0x64>
		s++, base = 8;
  800aa7:	42                   	inc    %edx
  800aa8:	b3 08                	mov    $0x8,%bl
  800aaa:	eb 05                	jmp    800ab1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aac:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab8:	8a 0a                	mov    (%edx),%cl
  800aba:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800abd:	80 fb 09             	cmp    $0x9,%bl
  800ac0:	77 08                	ja     800aca <strtol+0x82>
			dig = *s - '0';
  800ac2:	0f be c9             	movsbl %cl,%ecx
  800ac5:	83 e9 30             	sub    $0x30,%ecx
  800ac8:	eb 1e                	jmp    800ae8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aca:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800acd:	80 fb 19             	cmp    $0x19,%bl
  800ad0:	77 08                	ja     800ada <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad2:	0f be c9             	movsbl %cl,%ecx
  800ad5:	83 e9 57             	sub    $0x57,%ecx
  800ad8:	eb 0e                	jmp    800ae8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 12                	ja     800af4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae8:	39 f1                	cmp    %esi,%ecx
  800aea:	7d 0c                	jge    800af8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aec:	42                   	inc    %edx
  800aed:	0f af c6             	imul   %esi,%eax
  800af0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800af2:	eb c4                	jmp    800ab8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af4:	89 c1                	mov    %eax,%ecx
  800af6:	eb 02                	jmp    800afa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800afa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afe:	74 05                	je     800b05 <strtol+0xbd>
		*endptr = (char *) s;
  800b00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b03:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b05:	85 ff                	test   %edi,%edi
  800b07:	74 04                	je     800b0d <strtol+0xc5>
  800b09:	89 c8                	mov    %ecx,%eax
  800b0b:	f7 d8                	neg    %eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    
	...

00800b14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	89 c7                	mov    %eax,%edi
  800b29:	89 c6                	mov    %eax,%esi
  800b2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	89 d1                	mov    %edx,%ecx
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	89 d7                	mov    %edx,%edi
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 cb                	mov    %ecx,%ebx
  800b69:	89 cf                	mov    %ecx,%edi
  800b6b:	89 ce                	mov    %ecx,%esi
  800b6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 28                	jle    800b9b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b7e:	00 
  800b7f:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  800b86:	00 
  800b87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8e:	00 
  800b8f:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800b96:	e8 45 18 00 00       	call   8023e0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9b:	83 c4 2c             	add    $0x2c,%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_yield>:

void
sys_yield(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	be 00 00 00 00       	mov    $0x0,%esi
  800bef:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 f7                	mov    %esi,%edi
  800bff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 28                	jle    800c2d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c09:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c10:	00 
  800c11:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  800c18:	00 
  800c19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c20:	00 
  800c21:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800c28:	e8 b3 17 00 00       	call   8023e0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2d:	83 c4 2c             	add    $0x2c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c43:	8b 75 18             	mov    0x18(%ebp),%esi
  800c46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 28                	jle    800c80 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c63:	00 
  800c64:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  800c6b:	00 
  800c6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c73:	00 
  800c74:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800c7b:	e8 60 17 00 00       	call   8023e0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c80:	83 c4 2c             	add    $0x2c,%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 28                	jle    800cd3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800caf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cb6:	00 
  800cb7:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc6:	00 
  800cc7:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800cce:	e8 0d 17 00 00       	call   8023e0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	83 c4 2c             	add    $0x2c,%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 28                	jle    800d26 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d02:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d09:	00 
  800d0a:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  800d11:	00 
  800d12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d19:	00 
  800d1a:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800d21:	e8 ba 16 00 00       	call   8023e0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d26:	83 c4 2c             	add    $0x2c,%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 df                	mov    %ebx,%edi
  800d49:	89 de                	mov    %ebx,%esi
  800d4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 28                	jle    800d79 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d55:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  800d64:	00 
  800d65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6c:	00 
  800d6d:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800d74:	e8 67 16 00 00       	call   8023e0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d79:	83 c4 2c             	add    $0x2c,%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 df                	mov    %ebx,%edi
  800d9c:	89 de                	mov    %ebx,%esi
  800d9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 28                	jle    800dcc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800daf:	00 
  800db0:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  800db7:	00 
  800db8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbf:	00 
  800dc0:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800dc7:	e8 14 16 00 00       	call   8023e0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dcc:	83 c4 2c             	add    $0x2c,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	be 00 00 00 00       	mov    $0x0,%esi
  800ddf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e05:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	89 cb                	mov    %ecx,%ebx
  800e0f:	89 cf                	mov    %ecx,%edi
  800e11:	89 ce                	mov    %ecx,%esi
  800e13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e15:	85 c0                	test   %eax,%eax
  800e17:	7e 28                	jle    800e41 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e24:	00 
  800e25:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e34:	00 
  800e35:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800e3c:	e8 9f 15 00 00       	call   8023e0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e41:	83 c4 2c             	add    $0x2c,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_time_msec>:

unsigned int
sys_time_msec(void)
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
  800e4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e54:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e59:	89 d1                	mov    %edx,%ecx
  800e5b:	89 d3                	mov    %edx,%ebx
  800e5d:	89 d7                	mov    %edx,%edi
  800e5f:	89 d6                	mov    %edx,%esi
  800e61:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e94:	b8 10 00 00 00       	mov    $0x10,%eax
  800e99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 df                	mov    %ebx,%edi
  800ea1:	89 de                	mov    %ebx,%esi
  800ea3:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    
	...

00800eac <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800eb8:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800eba:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800ebd:	83 3a 01             	cmpl   $0x1,(%edx)
  800ec0:	7e 0b                	jle    800ecd <argstart+0x21>
  800ec2:	85 c9                	test   %ecx,%ecx
  800ec4:	75 0e                	jne    800ed4 <argstart+0x28>
  800ec6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecb:	eb 0c                	jmp    800ed9 <argstart+0x2d>
  800ecd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed2:	eb 05                	jmp    800ed9 <argstart+0x2d>
  800ed4:	ba 31 28 80 00       	mov    $0x802831,%edx
  800ed9:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800edc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <argnext>:

int
argnext(struct Argstate *args)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 14             	sub    $0x14,%esp
  800eec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800eef:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800ef6:	8b 43 08             	mov    0x8(%ebx),%eax
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	74 6c                	je     800f69 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  800efd:	80 38 00             	cmpb   $0x0,(%eax)
  800f00:	75 4d                	jne    800f4f <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800f02:	8b 0b                	mov    (%ebx),%ecx
  800f04:	83 39 01             	cmpl   $0x1,(%ecx)
  800f07:	74 52                	je     800f5b <argnext+0x76>
		    || args->argv[1][0] != '-'
  800f09:	8b 53 04             	mov    0x4(%ebx),%edx
  800f0c:	8b 42 04             	mov    0x4(%edx),%eax
  800f0f:	80 38 2d             	cmpb   $0x2d,(%eax)
  800f12:	75 47                	jne    800f5b <argnext+0x76>
		    || args->argv[1][1] == '\0')
  800f14:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f18:	74 41                	je     800f5b <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800f1a:	40                   	inc    %eax
  800f1b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f1e:	8b 01                	mov    (%ecx),%eax
  800f20:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800f27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f2b:	8d 42 08             	lea    0x8(%edx),%eax
  800f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f32:	83 c2 04             	add    $0x4,%edx
  800f35:	89 14 24             	mov    %edx,(%esp)
  800f38:	e8 2b fa ff ff       	call   800968 <memmove>
		(*args->argc)--;
  800f3d:	8b 03                	mov    (%ebx),%eax
  800f3f:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800f41:	8b 43 08             	mov    0x8(%ebx),%eax
  800f44:	80 38 2d             	cmpb   $0x2d,(%eax)
  800f47:	75 06                	jne    800f4f <argnext+0x6a>
  800f49:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f4d:	74 0c                	je     800f5b <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800f4f:	8b 53 08             	mov    0x8(%ebx),%edx
  800f52:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800f55:	42                   	inc    %edx
  800f56:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800f59:	eb 13                	jmp    800f6e <argnext+0x89>

    endofargs:
	args->curarg = 0;
  800f5b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800f67:	eb 05                	jmp    800f6e <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800f69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800f6e:	83 c4 14             	add    $0x14,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	53                   	push   %ebx
  800f78:	83 ec 14             	sub    $0x14,%esp
  800f7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f7e:	8b 43 08             	mov    0x8(%ebx),%eax
  800f81:	85 c0                	test   %eax,%eax
  800f83:	74 59                	je     800fde <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  800f85:	80 38 00             	cmpb   $0x0,(%eax)
  800f88:	74 0c                	je     800f96 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800f8a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f8d:	c7 43 08 31 28 80 00 	movl   $0x802831,0x8(%ebx)
  800f94:	eb 43                	jmp    800fd9 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  800f96:	8b 03                	mov    (%ebx),%eax
  800f98:	83 38 01             	cmpl   $0x1,(%eax)
  800f9b:	7e 2e                	jle    800fcb <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  800f9d:	8b 53 04             	mov    0x4(%ebx),%edx
  800fa0:	8b 4a 04             	mov    0x4(%edx),%ecx
  800fa3:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800fa6:	8b 00                	mov    (%eax),%eax
  800fa8:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800faf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb3:	8d 42 08             	lea    0x8(%edx),%eax
  800fb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fba:	83 c2 04             	add    $0x4,%edx
  800fbd:	89 14 24             	mov    %edx,(%esp)
  800fc0:	e8 a3 f9 ff ff       	call   800968 <memmove>
		(*args->argc)--;
  800fc5:	8b 03                	mov    (%ebx),%eax
  800fc7:	ff 08                	decl   (%eax)
  800fc9:	eb 0e                	jmp    800fd9 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  800fcb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800fd2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800fd9:	8b 43 0c             	mov    0xc(%ebx),%eax
  800fdc:	eb 05                	jmp    800fe3 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800fde:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800fe3:	83 c4 14             	add    $0x14,%esp
  800fe6:	5b                   	pop    %ebx
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 18             	sub    $0x18,%esp
  800fef:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800ff2:	8b 42 0c             	mov    0xc(%edx),%eax
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	75 08                	jne    801001 <argvalue+0x18>
  800ff9:	89 14 24             	mov    %edx,(%esp)
  800ffc:	e8 73 ff ff ff       	call   800f74 <argnextvalue>
}
  801001:	c9                   	leave  
  801002:	c3                   	ret    
	...

00801004 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801007:	8b 45 08             	mov    0x8(%ebp),%eax
  80100a:	05 00 00 00 30       	add    $0x30000000,%eax
  80100f:	c1 e8 0c             	shr    $0xc,%eax
}
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80101a:	8b 45 08             	mov    0x8(%ebp),%eax
  80101d:	89 04 24             	mov    %eax,(%esp)
  801020:	e8 df ff ff ff       	call   801004 <fd2num>
  801025:	c1 e0 0c             	shl    $0xc,%eax
  801028:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	53                   	push   %ebx
  801033:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801036:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80103b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80103d:	89 c2                	mov    %eax,%edx
  80103f:	c1 ea 16             	shr    $0x16,%edx
  801042:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801049:	f6 c2 01             	test   $0x1,%dl
  80104c:	74 11                	je     80105f <fd_alloc+0x30>
  80104e:	89 c2                	mov    %eax,%edx
  801050:	c1 ea 0c             	shr    $0xc,%edx
  801053:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80105a:	f6 c2 01             	test   $0x1,%dl
  80105d:	75 09                	jne    801068 <fd_alloc+0x39>
			*fd_store = fd;
  80105f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801061:	b8 00 00 00 00       	mov    $0x0,%eax
  801066:	eb 17                	jmp    80107f <fd_alloc+0x50>
  801068:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80106d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801072:	75 c7                	jne    80103b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801074:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80107a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80107f:	5b                   	pop    %ebx
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801088:	83 f8 1f             	cmp    $0x1f,%eax
  80108b:	77 36                	ja     8010c3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80108d:	c1 e0 0c             	shl    $0xc,%eax
  801090:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801095:	89 c2                	mov    %eax,%edx
  801097:	c1 ea 16             	shr    $0x16,%edx
  80109a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a1:	f6 c2 01             	test   $0x1,%dl
  8010a4:	74 24                	je     8010ca <fd_lookup+0x48>
  8010a6:	89 c2                	mov    %eax,%edx
  8010a8:	c1 ea 0c             	shr    $0xc,%edx
  8010ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b2:	f6 c2 01             	test   $0x1,%dl
  8010b5:	74 1a                	je     8010d1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ba:	89 02                	mov    %eax,(%edx)
	return 0;
  8010bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c1:	eb 13                	jmp    8010d6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c8:	eb 0c                	jmp    8010d6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010cf:	eb 05                	jmp    8010d6 <fd_lookup+0x54>
  8010d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	53                   	push   %ebx
  8010dc:	83 ec 14             	sub    $0x14,%esp
  8010df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8010e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ea:	eb 0e                	jmp    8010fa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8010ec:	39 08                	cmp    %ecx,(%eax)
  8010ee:	75 09                	jne    8010f9 <dev_lookup+0x21>
			*dev = devtab[i];
  8010f0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8010f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f7:	eb 33                	jmp    80112c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010f9:	42                   	inc    %edx
  8010fa:	8b 04 95 0c 2c 80 00 	mov    0x802c0c(,%edx,4),%eax
  801101:	85 c0                	test   %eax,%eax
  801103:	75 e7                	jne    8010ec <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801105:	a1 08 40 80 00       	mov    0x804008,%eax
  80110a:	8b 40 48             	mov    0x48(%eax),%eax
  80110d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801111:	89 44 24 04          	mov    %eax,0x4(%esp)
  801115:	c7 04 24 90 2b 80 00 	movl   $0x802b90,(%esp)
  80111c:	e8 23 f1 ff ff       	call   800244 <cprintf>
	*dev = 0;
  801121:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801127:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80112c:	83 c4 14             	add    $0x14,%esp
  80112f:	5b                   	pop    %ebx
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
  801137:	83 ec 30             	sub    $0x30,%esp
  80113a:	8b 75 08             	mov    0x8(%ebp),%esi
  80113d:	8a 45 0c             	mov    0xc(%ebp),%al
  801140:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801143:	89 34 24             	mov    %esi,(%esp)
  801146:	e8 b9 fe ff ff       	call   801004 <fd2num>
  80114b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80114e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801152:	89 04 24             	mov    %eax,(%esp)
  801155:	e8 28 ff ff ff       	call   801082 <fd_lookup>
  80115a:	89 c3                	mov    %eax,%ebx
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 05                	js     801165 <fd_close+0x33>
	    || fd != fd2)
  801160:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801163:	74 0d                	je     801172 <fd_close+0x40>
		return (must_exist ? r : 0);
  801165:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801169:	75 46                	jne    8011b1 <fd_close+0x7f>
  80116b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801170:	eb 3f                	jmp    8011b1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801172:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801175:	89 44 24 04          	mov    %eax,0x4(%esp)
  801179:	8b 06                	mov    (%esi),%eax
  80117b:	89 04 24             	mov    %eax,(%esp)
  80117e:	e8 55 ff ff ff       	call   8010d8 <dev_lookup>
  801183:	89 c3                	mov    %eax,%ebx
  801185:	85 c0                	test   %eax,%eax
  801187:	78 18                	js     8011a1 <fd_close+0x6f>
		if (dev->dev_close)
  801189:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118c:	8b 40 10             	mov    0x10(%eax),%eax
  80118f:	85 c0                	test   %eax,%eax
  801191:	74 09                	je     80119c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801193:	89 34 24             	mov    %esi,(%esp)
  801196:	ff d0                	call   *%eax
  801198:	89 c3                	mov    %eax,%ebx
  80119a:	eb 05                	jmp    8011a1 <fd_close+0x6f>
		else
			r = 0;
  80119c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ac:	e8 d7 fa ff ff       	call   800c88 <sys_page_unmap>
	return r;
}
  8011b1:	89 d8                	mov    %ebx,%eax
  8011b3:	83 c4 30             	add    $0x30,%esp
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	89 04 24             	mov    %eax,(%esp)
  8011cd:	e8 b0 fe ff ff       	call   801082 <fd_lookup>
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 13                	js     8011e9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8011d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011dd:	00 
  8011de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e1:	89 04 24             	mov    %eax,(%esp)
  8011e4:	e8 49 ff ff ff       	call   801132 <fd_close>
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <close_all>:

void
close_all(void)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011f7:	89 1c 24             	mov    %ebx,(%esp)
  8011fa:	e8 bb ff ff ff       	call   8011ba <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011ff:	43                   	inc    %ebx
  801200:	83 fb 20             	cmp    $0x20,%ebx
  801203:	75 f2                	jne    8011f7 <close_all+0xc>
		close(i);
}
  801205:	83 c4 14             	add    $0x14,%esp
  801208:	5b                   	pop    %ebx
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	57                   	push   %edi
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
  801211:	83 ec 4c             	sub    $0x4c,%esp
  801214:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801217:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80121a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121e:	8b 45 08             	mov    0x8(%ebp),%eax
  801221:	89 04 24             	mov    %eax,(%esp)
  801224:	e8 59 fe ff ff       	call   801082 <fd_lookup>
  801229:	89 c3                	mov    %eax,%ebx
  80122b:	85 c0                	test   %eax,%eax
  80122d:	0f 88 e3 00 00 00    	js     801316 <dup+0x10b>
		return r;
	close(newfdnum);
  801233:	89 3c 24             	mov    %edi,(%esp)
  801236:	e8 7f ff ff ff       	call   8011ba <close>

	newfd = INDEX2FD(newfdnum);
  80123b:	89 fe                	mov    %edi,%esi
  80123d:	c1 e6 0c             	shl    $0xc,%esi
  801240:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801246:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801249:	89 04 24             	mov    %eax,(%esp)
  80124c:	e8 c3 fd ff ff       	call   801014 <fd2data>
  801251:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801253:	89 34 24             	mov    %esi,(%esp)
  801256:	e8 b9 fd ff ff       	call   801014 <fd2data>
  80125b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80125e:	89 d8                	mov    %ebx,%eax
  801260:	c1 e8 16             	shr    $0x16,%eax
  801263:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80126a:	a8 01                	test   $0x1,%al
  80126c:	74 46                	je     8012b4 <dup+0xa9>
  80126e:	89 d8                	mov    %ebx,%eax
  801270:	c1 e8 0c             	shr    $0xc,%eax
  801273:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80127a:	f6 c2 01             	test   $0x1,%dl
  80127d:	74 35                	je     8012b4 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80127f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801286:	25 07 0e 00 00       	and    $0xe07,%eax
  80128b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80128f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801292:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801296:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80129d:	00 
  80129e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a9:	e8 87 f9 ff ff       	call   800c35 <sys_page_map>
  8012ae:	89 c3                	mov    %eax,%ebx
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 3b                	js     8012ef <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	c1 ea 0c             	shr    $0xc,%edx
  8012bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012d8:	00 
  8012d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e4:	e8 4c f9 ff ff       	call   800c35 <sys_page_map>
  8012e9:	89 c3                	mov    %eax,%ebx
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	79 25                	jns    801314 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012fa:	e8 89 f9 ff ff       	call   800c88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801302:	89 44 24 04          	mov    %eax,0x4(%esp)
  801306:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80130d:	e8 76 f9 ff ff       	call   800c88 <sys_page_unmap>
	return r;
  801312:	eb 02                	jmp    801316 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801314:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801316:	89 d8                	mov    %ebx,%eax
  801318:	83 c4 4c             	add    $0x4c,%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5f                   	pop    %edi
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	53                   	push   %ebx
  801324:	83 ec 24             	sub    $0x24,%esp
  801327:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801331:	89 1c 24             	mov    %ebx,(%esp)
  801334:	e8 49 fd ff ff       	call   801082 <fd_lookup>
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 6d                	js     8013aa <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801340:	89 44 24 04          	mov    %eax,0x4(%esp)
  801344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801347:	8b 00                	mov    (%eax),%eax
  801349:	89 04 24             	mov    %eax,(%esp)
  80134c:	e8 87 fd ff ff       	call   8010d8 <dev_lookup>
  801351:	85 c0                	test   %eax,%eax
  801353:	78 55                	js     8013aa <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801355:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801358:	8b 50 08             	mov    0x8(%eax),%edx
  80135b:	83 e2 03             	and    $0x3,%edx
  80135e:	83 fa 01             	cmp    $0x1,%edx
  801361:	75 23                	jne    801386 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801363:	a1 08 40 80 00       	mov    0x804008,%eax
  801368:	8b 40 48             	mov    0x48(%eax),%eax
  80136b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80136f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801373:	c7 04 24 d1 2b 80 00 	movl   $0x802bd1,(%esp)
  80137a:	e8 c5 ee ff ff       	call   800244 <cprintf>
		return -E_INVAL;
  80137f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801384:	eb 24                	jmp    8013aa <read+0x8a>
	}
	if (!dev->dev_read)
  801386:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801389:	8b 52 08             	mov    0x8(%edx),%edx
  80138c:	85 d2                	test   %edx,%edx
  80138e:	74 15                	je     8013a5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801390:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801393:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801397:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80139e:	89 04 24             	mov    %eax,(%esp)
  8013a1:	ff d2                	call   *%edx
  8013a3:	eb 05                	jmp    8013aa <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013aa:	83 c4 24             	add    $0x24,%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	57                   	push   %edi
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 1c             	sub    $0x1c,%esp
  8013b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013bc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c4:	eb 23                	jmp    8013e9 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013c6:	89 f0                	mov    %esi,%eax
  8013c8:	29 d8                	sub    %ebx,%eax
  8013ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d1:	01 d8                	add    %ebx,%eax
  8013d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d7:	89 3c 24             	mov    %edi,(%esp)
  8013da:	e8 41 ff ff ff       	call   801320 <read>
		if (m < 0)
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 10                	js     8013f3 <readn+0x43>
			return m;
		if (m == 0)
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	74 0a                	je     8013f1 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e7:	01 c3                	add    %eax,%ebx
  8013e9:	39 f3                	cmp    %esi,%ebx
  8013eb:	72 d9                	jb     8013c6 <readn+0x16>
  8013ed:	89 d8                	mov    %ebx,%eax
  8013ef:	eb 02                	jmp    8013f3 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8013f1:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8013f3:	83 c4 1c             	add    $0x1c,%esp
  8013f6:	5b                   	pop    %ebx
  8013f7:	5e                   	pop    %esi
  8013f8:	5f                   	pop    %edi
  8013f9:	5d                   	pop    %ebp
  8013fa:	c3                   	ret    

008013fb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 24             	sub    $0x24,%esp
  801402:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801405:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140c:	89 1c 24             	mov    %ebx,(%esp)
  80140f:	e8 6e fc ff ff       	call   801082 <fd_lookup>
  801414:	85 c0                	test   %eax,%eax
  801416:	78 68                	js     801480 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801418:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801422:	8b 00                	mov    (%eax),%eax
  801424:	89 04 24             	mov    %eax,(%esp)
  801427:	e8 ac fc ff ff       	call   8010d8 <dev_lookup>
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 50                	js     801480 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801430:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801433:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801437:	75 23                	jne    80145c <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801439:	a1 08 40 80 00       	mov    0x804008,%eax
  80143e:	8b 40 48             	mov    0x48(%eax),%eax
  801441:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801445:	89 44 24 04          	mov    %eax,0x4(%esp)
  801449:	c7 04 24 ed 2b 80 00 	movl   $0x802bed,(%esp)
  801450:	e8 ef ed ff ff       	call   800244 <cprintf>
		return -E_INVAL;
  801455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145a:	eb 24                	jmp    801480 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80145c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80145f:	8b 52 0c             	mov    0xc(%edx),%edx
  801462:	85 d2                	test   %edx,%edx
  801464:	74 15                	je     80147b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801466:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801469:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80146d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801470:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801474:	89 04 24             	mov    %eax,(%esp)
  801477:	ff d2                	call   *%edx
  801479:	eb 05                	jmp    801480 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80147b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801480:	83 c4 24             	add    $0x24,%esp
  801483:	5b                   	pop    %ebx
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <seek>:

int
seek(int fdnum, off_t offset)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80148c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80148f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	89 04 24             	mov    %eax,(%esp)
  801499:	e8 e4 fb ff ff       	call   801082 <fd_lookup>
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 0e                	js     8014b0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 24             	sub    $0x24,%esp
  8014b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c3:	89 1c 24             	mov    %ebx,(%esp)
  8014c6:	e8 b7 fb ff ff       	call   801082 <fd_lookup>
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 61                	js     801530 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d9:	8b 00                	mov    (%eax),%eax
  8014db:	89 04 24             	mov    %eax,(%esp)
  8014de:	e8 f5 fb ff ff       	call   8010d8 <dev_lookup>
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 49                	js     801530 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ee:	75 23                	jne    801513 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014f0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014f5:	8b 40 48             	mov    0x48(%eax),%eax
  8014f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801500:	c7 04 24 b0 2b 80 00 	movl   $0x802bb0,(%esp)
  801507:	e8 38 ed ff ff       	call   800244 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80150c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801511:	eb 1d                	jmp    801530 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801513:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801516:	8b 52 18             	mov    0x18(%edx),%edx
  801519:	85 d2                	test   %edx,%edx
  80151b:	74 0e                	je     80152b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80151d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801520:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801524:	89 04 24             	mov    %eax,(%esp)
  801527:	ff d2                	call   *%edx
  801529:	eb 05                	jmp    801530 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80152b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801530:	83 c4 24             	add    $0x24,%esp
  801533:	5b                   	pop    %ebx
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    

00801536 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	53                   	push   %ebx
  80153a:	83 ec 24             	sub    $0x24,%esp
  80153d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801540:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801543:	89 44 24 04          	mov    %eax,0x4(%esp)
  801547:	8b 45 08             	mov    0x8(%ebp),%eax
  80154a:	89 04 24             	mov    %eax,(%esp)
  80154d:	e8 30 fb ff ff       	call   801082 <fd_lookup>
  801552:	85 c0                	test   %eax,%eax
  801554:	78 52                	js     8015a8 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801556:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801560:	8b 00                	mov    (%eax),%eax
  801562:	89 04 24             	mov    %eax,(%esp)
  801565:	e8 6e fb ff ff       	call   8010d8 <dev_lookup>
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 3a                	js     8015a8 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80156e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801571:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801575:	74 2c                	je     8015a3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801577:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80157a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801581:	00 00 00 
	stat->st_isdir = 0;
  801584:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80158b:	00 00 00 
	stat->st_dev = dev;
  80158e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801594:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801598:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80159b:	89 14 24             	mov    %edx,(%esp)
  80159e:	ff 50 14             	call   *0x14(%eax)
  8015a1:	eb 05                	jmp    8015a8 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015a8:	83 c4 24             	add    $0x24,%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    

008015ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	56                   	push   %esi
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015bd:	00 
  8015be:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c1:	89 04 24             	mov    %eax,(%esp)
  8015c4:	e8 2a 02 00 00       	call   8017f3 <open>
  8015c9:	89 c3                	mov    %eax,%ebx
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 1b                	js     8015ea <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8015cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d6:	89 1c 24             	mov    %ebx,(%esp)
  8015d9:	e8 58 ff ff ff       	call   801536 <fstat>
  8015de:	89 c6                	mov    %eax,%esi
	close(fd);
  8015e0:	89 1c 24             	mov    %ebx,(%esp)
  8015e3:	e8 d2 fb ff ff       	call   8011ba <close>
	return r;
  8015e8:	89 f3                	mov    %esi,%ebx
}
  8015ea:	89 d8                	mov    %ebx,%eax
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5d                   	pop    %ebp
  8015f2:	c3                   	ret    
	...

008015f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 10             	sub    $0x10,%esp
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801600:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801607:	75 11                	jne    80161a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801609:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801610:	e8 16 0f 00 00       	call   80252b <ipc_find_env>
  801615:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80161a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801621:	00 
  801622:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801629:	00 
  80162a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80162e:	a1 00 40 80 00       	mov    0x804000,%eax
  801633:	89 04 24             	mov    %eax,(%esp)
  801636:	e8 6d 0e 00 00       	call   8024a8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801642:	00 
  801643:	89 74 24 04          	mov    %esi,0x4(%esp)
  801647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164e:	e8 e5 0d 00 00       	call   802438 <ipc_recv>
}
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	5b                   	pop    %ebx
  801657:	5e                   	pop    %esi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801660:	8b 45 08             	mov    0x8(%ebp),%eax
  801663:	8b 40 0c             	mov    0xc(%eax),%eax
  801666:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80166b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801673:	ba 00 00 00 00       	mov    $0x0,%edx
  801678:	b8 02 00 00 00       	mov    $0x2,%eax
  80167d:	e8 72 ff ff ff       	call   8015f4 <fsipc>
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80168a:	8b 45 08             	mov    0x8(%ebp),%eax
  80168d:	8b 40 0c             	mov    0xc(%eax),%eax
  801690:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801695:	ba 00 00 00 00       	mov    $0x0,%edx
  80169a:	b8 06 00 00 00       	mov    $0x6,%eax
  80169f:	e8 50 ff ff ff       	call   8015f4 <fsipc>
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 14             	sub    $0x14,%esp
  8016ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016c5:	e8 2a ff ff ff       	call   8015f4 <fsipc>
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	78 2b                	js     8016f9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ce:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016d5:	00 
  8016d6:	89 1c 24             	mov    %ebx,(%esp)
  8016d9:	e8 11 f1 ff ff       	call   8007ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016de:	a1 80 50 80 00       	mov    0x805080,%eax
  8016e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f9:	83 c4 14             	add    $0x14,%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 18             	sub    $0x18,%esp
  801705:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801708:	8b 55 08             	mov    0x8(%ebp),%edx
  80170b:	8b 52 0c             	mov    0xc(%edx),%edx
  80170e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801714:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801719:	89 c2                	mov    %eax,%edx
  80171b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801720:	76 05                	jbe    801727 <devfile_write+0x28>
  801722:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801727:	89 54 24 08          	mov    %edx,0x8(%esp)
  80172b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80172e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801732:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801739:	e8 94 f2 ff ff       	call   8009d2 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80173e:	ba 00 00 00 00       	mov    $0x0,%edx
  801743:	b8 04 00 00 00       	mov    $0x4,%eax
  801748:	e8 a7 fe ff ff       	call   8015f4 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
  801754:	83 ec 10             	sub    $0x10,%esp
  801757:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80175a:	8b 45 08             	mov    0x8(%ebp),%eax
  80175d:	8b 40 0c             	mov    0xc(%eax),%eax
  801760:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801765:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80176b:	ba 00 00 00 00       	mov    $0x0,%edx
  801770:	b8 03 00 00 00       	mov    $0x3,%eax
  801775:	e8 7a fe ff ff       	call   8015f4 <fsipc>
  80177a:	89 c3                	mov    %eax,%ebx
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 6a                	js     8017ea <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801780:	39 c6                	cmp    %eax,%esi
  801782:	73 24                	jae    8017a8 <devfile_read+0x59>
  801784:	c7 44 24 0c 20 2c 80 	movl   $0x802c20,0xc(%esp)
  80178b:	00 
  80178c:	c7 44 24 08 27 2c 80 	movl   $0x802c27,0x8(%esp)
  801793:	00 
  801794:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80179b:	00 
  80179c:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  8017a3:	e8 38 0c 00 00       	call   8023e0 <_panic>
	assert(r <= PGSIZE);
  8017a8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ad:	7e 24                	jle    8017d3 <devfile_read+0x84>
  8017af:	c7 44 24 0c 47 2c 80 	movl   $0x802c47,0xc(%esp)
  8017b6:	00 
  8017b7:	c7 44 24 08 27 2c 80 	movl   $0x802c27,0x8(%esp)
  8017be:	00 
  8017bf:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017c6:	00 
  8017c7:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  8017ce:	e8 0d 0c 00 00       	call   8023e0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017de:	00 
  8017df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e2:	89 04 24             	mov    %eax,(%esp)
  8017e5:	e8 7e f1 ff ff       	call   800968 <memmove>
	return r;
}
  8017ea:	89 d8                	mov    %ebx,%eax
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 20             	sub    $0x20,%esp
  8017fb:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017fe:	89 34 24             	mov    %esi,(%esp)
  801801:	e8 b6 ef ff ff       	call   8007bc <strlen>
  801806:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80180b:	7f 60                	jg     80186d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80180d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801810:	89 04 24             	mov    %eax,(%esp)
  801813:	e8 17 f8 ff ff       	call   80102f <fd_alloc>
  801818:	89 c3                	mov    %eax,%ebx
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 54                	js     801872 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80181e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801822:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801829:	e8 c1 ef ff ff       	call   8007ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  80182e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801831:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801836:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801839:	b8 01 00 00 00       	mov    $0x1,%eax
  80183e:	e8 b1 fd ff ff       	call   8015f4 <fsipc>
  801843:	89 c3                	mov    %eax,%ebx
  801845:	85 c0                	test   %eax,%eax
  801847:	79 15                	jns    80185e <open+0x6b>
		fd_close(fd, 0);
  801849:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801850:	00 
  801851:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801854:	89 04 24             	mov    %eax,(%esp)
  801857:	e8 d6 f8 ff ff       	call   801132 <fd_close>
		return r;
  80185c:	eb 14                	jmp    801872 <open+0x7f>
	}

	return fd2num(fd);
  80185e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801861:	89 04 24             	mov    %eax,(%esp)
  801864:	e8 9b f7 ff ff       	call   801004 <fd2num>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	eb 05                	jmp    801872 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80186d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801872:	89 d8                	mov    %ebx,%eax
  801874:	83 c4 20             	add    $0x20,%esp
  801877:	5b                   	pop    %ebx
  801878:	5e                   	pop    %esi
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801881:	ba 00 00 00 00       	mov    $0x0,%edx
  801886:	b8 08 00 00 00       	mov    $0x8,%eax
  80188b:	e8 64 fd ff ff       	call   8015f4 <fsipc>
}
  801890:	c9                   	leave  
  801891:	c3                   	ret    
	...

00801894 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	53                   	push   %ebx
  801898:	83 ec 14             	sub    $0x14,%esp
  80189b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80189d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018a1:	7e 32                	jle    8018d5 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018a3:	8b 40 04             	mov    0x4(%eax),%eax
  8018a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018aa:	8d 43 10             	lea    0x10(%ebx),%eax
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	8b 03                	mov    (%ebx),%eax
  8018b3:	89 04 24             	mov    %eax,(%esp)
  8018b6:	e8 40 fb ff ff       	call   8013fb <write>
		if (result > 0)
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	7e 03                	jle    8018c2 <writebuf+0x2e>
			b->result += result;
  8018bf:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018c2:	39 43 04             	cmp    %eax,0x4(%ebx)
  8018c5:	74 0e                	je     8018d5 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8018c7:	89 c2                	mov    %eax,%edx
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	7e 05                	jle    8018d2 <writebuf+0x3e>
  8018cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d2:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8018d5:	83 c4 14             	add    $0x14,%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <putch>:

static void
putch(int ch, void *thunk)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 04             	sub    $0x4,%esp
  8018e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018e5:	8b 43 04             	mov    0x4(%ebx),%eax
  8018e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018eb:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8018ef:	40                   	inc    %eax
  8018f0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8018f3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018f8:	75 0e                	jne    801908 <putch+0x2d>
		writebuf(b);
  8018fa:	89 d8                	mov    %ebx,%eax
  8018fc:	e8 93 ff ff ff       	call   801894 <writebuf>
		b->idx = 0;
  801901:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801908:	83 c4 04             	add    $0x4,%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801920:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801927:	00 00 00 
	b.result = 0;
  80192a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801931:	00 00 00 
	b.error = 1;
  801934:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80193b:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80193e:	8b 45 10             	mov    0x10(%ebp),%eax
  801941:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801945:	8b 45 0c             	mov    0xc(%ebp),%eax
  801948:	89 44 24 08          	mov    %eax,0x8(%esp)
  80194c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801952:	89 44 24 04          	mov    %eax,0x4(%esp)
  801956:	c7 04 24 db 18 80 00 	movl   $0x8018db,(%esp)
  80195d:	e8 44 ea ff ff       	call   8003a6 <vprintfmt>
	if (b.idx > 0)
  801962:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801969:	7e 0b                	jle    801976 <vfprintf+0x68>
		writebuf(&b);
  80196b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801971:	e8 1e ff ff ff       	call   801894 <writebuf>

	return (b.result ? b.result : b.error);
  801976:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80197c:	85 c0                	test   %eax,%eax
  80197e:	75 06                	jne    801986 <vfprintf+0x78>
  801980:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80198e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801991:	89 44 24 08          	mov    %eax,0x8(%esp)
  801995:	8b 45 0c             	mov    0xc(%ebp),%eax
  801998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199c:	8b 45 08             	mov    0x8(%ebp),%eax
  80199f:	89 04 24             	mov    %eax,(%esp)
  8019a2:	e8 67 ff ff ff       	call   80190e <vfprintf>
	va_end(ap);

	return cnt;
}
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <printf>:

int
printf(const char *fmt, ...)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019c4:	e8 45 ff ff ff       	call   80190e <vfprintf>
	va_end(ap);

	return cnt;
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    
	...

008019cc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8019d2:	c7 44 24 04 53 2c 80 	movl   $0x802c53,0x4(%esp)
  8019d9:	00 
  8019da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dd:	89 04 24             	mov    %eax,(%esp)
  8019e0:	e8 0a ee ff ff       	call   8007ef <strcpy>
	return 0;
}
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 14             	sub    $0x14,%esp
  8019f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019f6:	89 1c 24             	mov    %ebx,(%esp)
  8019f9:	e8 72 0b 00 00       	call   802570 <pageref>
  8019fe:	83 f8 01             	cmp    $0x1,%eax
  801a01:	75 0d                	jne    801a10 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801a03:	8b 43 0c             	mov    0xc(%ebx),%eax
  801a06:	89 04 24             	mov    %eax,(%esp)
  801a09:	e8 1f 03 00 00       	call   801d2d <nsipc_close>
  801a0e:	eb 05                	jmp    801a15 <devsock_close+0x29>
	else
		return 0;
  801a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a15:	83 c4 14             	add    $0x14,%esp
  801a18:	5b                   	pop    %ebx
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a21:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a28:	00 
  801a29:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a37:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3d:	89 04 24             	mov    %eax,(%esp)
  801a40:	e8 e3 03 00 00       	call   801e28 <nsipc_send>
}
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a4d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a54:	00 
  801a55:	8b 45 10             	mov    0x10(%ebp),%eax
  801a58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a63:	8b 45 08             	mov    0x8(%ebp),%eax
  801a66:	8b 40 0c             	mov    0xc(%eax),%eax
  801a69:	89 04 24             	mov    %eax,(%esp)
  801a6c:	e8 37 03 00 00       	call   801da8 <nsipc_recv>
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	56                   	push   %esi
  801a77:	53                   	push   %ebx
  801a78:	83 ec 20             	sub    $0x20,%esp
  801a7b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a80:	89 04 24             	mov    %eax,(%esp)
  801a83:	e8 a7 f5 ff ff       	call   80102f <fd_alloc>
  801a88:	89 c3                	mov    %eax,%ebx
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	78 21                	js     801aaf <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a8e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a95:	00 
  801a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aa4:	e8 38 f1 ff ff       	call   800be1 <sys_page_alloc>
  801aa9:	89 c3                	mov    %eax,%ebx
  801aab:	85 c0                	test   %eax,%eax
  801aad:	79 0a                	jns    801ab9 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801aaf:	89 34 24             	mov    %esi,(%esp)
  801ab2:	e8 76 02 00 00       	call   801d2d <nsipc_close>
		return r;
  801ab7:	eb 22                	jmp    801adb <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ab9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ace:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ad1:	89 04 24             	mov    %eax,(%esp)
  801ad4:	e8 2b f5 ff ff       	call   801004 <fd2num>
  801ad9:	89 c3                	mov    %eax,%ebx
}
  801adb:	89 d8                	mov    %ebx,%eax
  801add:	83 c4 20             	add    $0x20,%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aea:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aed:	89 54 24 04          	mov    %edx,0x4(%esp)
  801af1:	89 04 24             	mov    %eax,(%esp)
  801af4:	e8 89 f5 ff ff       	call   801082 <fd_lookup>
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 17                	js     801b14 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b06:	39 10                	cmp    %edx,(%eax)
  801b08:	75 05                	jne    801b0f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0d:	eb 05                	jmp    801b14 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b0f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	e8 c0 ff ff ff       	call   801ae4 <fd2sockid>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 1f                	js     801b47 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b28:	8b 55 10             	mov    0x10(%ebp),%edx
  801b2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b32:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b36:	89 04 24             	mov    %eax,(%esp)
  801b39:	e8 38 01 00 00       	call   801c76 <nsipc_accept>
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 05                	js     801b47 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801b42:	e8 2c ff ff ff       	call   801a73 <alloc_sockfd>
}
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b52:	e8 8d ff ff ff       	call   801ae4 <fd2sockid>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 16                	js     801b71 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801b5b:	8b 55 10             	mov    0x10(%ebp),%edx
  801b5e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b65:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b69:	89 04 24             	mov    %eax,(%esp)
  801b6c:	e8 5b 01 00 00       	call   801ccc <nsipc_bind>
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <shutdown>:

int
shutdown(int s, int how)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b79:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7c:	e8 63 ff ff ff       	call   801ae4 <fd2sockid>
  801b81:	85 c0                	test   %eax,%eax
  801b83:	78 0f                	js     801b94 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b85:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b88:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b8c:	89 04 24             	mov    %eax,(%esp)
  801b8f:	e8 77 01 00 00       	call   801d0b <nsipc_shutdown>
}
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	e8 40 ff ff ff       	call   801ae4 <fd2sockid>
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 16                	js     801bbe <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801ba8:	8b 55 10             	mov    0x10(%ebp),%edx
  801bab:	89 54 24 08          	mov    %edx,0x8(%esp)
  801baf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bb6:	89 04 24             	mov    %eax,(%esp)
  801bb9:	e8 89 01 00 00       	call   801d47 <nsipc_connect>
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <listen>:

int
listen(int s, int backlog)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc9:	e8 16 ff ff ff       	call   801ae4 <fd2sockid>
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 0f                	js     801be1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bd9:	89 04 24             	mov    %eax,(%esp)
  801bdc:	e8 a5 01 00 00       	call   801d86 <nsipc_listen>
}
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801be9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfa:	89 04 24             	mov    %eax,(%esp)
  801bfd:	e8 99 02 00 00       	call   801e9b <nsipc_socket>
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 05                	js     801c0b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c06:	e8 68 fe ff ff       	call   801a73 <alloc_sockfd>
}
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    
  801c0d:	00 00                	add    %al,(%eax)
	...

00801c10 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	53                   	push   %ebx
  801c14:	83 ec 14             	sub    $0x14,%esp
  801c17:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c19:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c20:	75 11                	jne    801c33 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c22:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c29:	e8 fd 08 00 00       	call   80252b <ipc_find_env>
  801c2e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c33:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c3a:	00 
  801c3b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c42:	00 
  801c43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c47:	a1 04 40 80 00       	mov    0x804004,%eax
  801c4c:	89 04 24             	mov    %eax,(%esp)
  801c4f:	e8 54 08 00 00       	call   8024a8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c54:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c5b:	00 
  801c5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c63:	00 
  801c64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c6b:	e8 c8 07 00 00       	call   802438 <ipc_recv>
}
  801c70:	83 c4 14             	add    $0x14,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    

00801c76 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 10             	sub    $0x10,%esp
  801c7e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c89:	8b 06                	mov    (%esi),%eax
  801c8b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c90:	b8 01 00 00 00       	mov    $0x1,%eax
  801c95:	e8 76 ff ff ff       	call   801c10 <nsipc>
  801c9a:	89 c3                	mov    %eax,%ebx
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 23                	js     801cc3 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ca0:	a1 10 60 80 00       	mov    0x806010,%eax
  801ca5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca9:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cb0:	00 
  801cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb4:	89 04 24             	mov    %eax,(%esp)
  801cb7:	e8 ac ec ff ff       	call   800968 <memmove>
		*addrlen = ret->ret_addrlen;
  801cbc:	a1 10 60 80 00       	mov    0x806010,%eax
  801cc1:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801cc3:	89 d8                	mov    %ebx,%eax
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5e                   	pop    %esi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	53                   	push   %ebx
  801cd0:	83 ec 14             	sub    $0x14,%esp
  801cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce9:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801cf0:	e8 73 ec ff ff       	call   800968 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cf5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cfb:	b8 02 00 00 00       	mov    $0x2,%eax
  801d00:	e8 0b ff ff ff       	call   801c10 <nsipc>
}
  801d05:	83 c4 14             	add    $0x14,%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d11:	8b 45 08             	mov    0x8(%ebp),%eax
  801d14:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d21:	b8 03 00 00 00       	mov    $0x3,%eax
  801d26:	e8 e5 fe ff ff       	call   801c10 <nsipc>
}
  801d2b:	c9                   	leave  
  801d2c:	c3                   	ret    

00801d2d <nsipc_close>:

int
nsipc_close(int s)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d33:	8b 45 08             	mov    0x8(%ebp),%eax
  801d36:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d3b:	b8 04 00 00 00       	mov    $0x4,%eax
  801d40:	e8 cb fe ff ff       	call   801c10 <nsipc>
}
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	53                   	push   %ebx
  801d4b:	83 ec 14             	sub    $0x14,%esp
  801d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d51:	8b 45 08             	mov    0x8(%ebp),%eax
  801d54:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d64:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801d6b:	e8 f8 eb ff ff       	call   800968 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d70:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d76:	b8 05 00 00 00       	mov    $0x5,%eax
  801d7b:	e8 90 fe ff ff       	call   801c10 <nsipc>
}
  801d80:	83 c4 14             	add    $0x14,%esp
  801d83:	5b                   	pop    %ebx
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d97:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d9c:	b8 06 00 00 00       	mov    $0x6,%eax
  801da1:	e8 6a fe ff ff       	call   801c10 <nsipc>
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	56                   	push   %esi
  801dac:	53                   	push   %ebx
  801dad:	83 ec 10             	sub    $0x10,%esp
  801db0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801db3:	8b 45 08             	mov    0x8(%ebp),%eax
  801db6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dbb:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dc1:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc4:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dc9:	b8 07 00 00 00       	mov    $0x7,%eax
  801dce:	e8 3d fe ff ff       	call   801c10 <nsipc>
  801dd3:	89 c3                	mov    %eax,%ebx
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	78 46                	js     801e1f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801dd9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dde:	7f 04                	jg     801de4 <nsipc_recv+0x3c>
  801de0:	39 c6                	cmp    %eax,%esi
  801de2:	7d 24                	jge    801e08 <nsipc_recv+0x60>
  801de4:	c7 44 24 0c 5f 2c 80 	movl   $0x802c5f,0xc(%esp)
  801deb:	00 
  801dec:	c7 44 24 08 27 2c 80 	movl   $0x802c27,0x8(%esp)
  801df3:	00 
  801df4:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801dfb:	00 
  801dfc:	c7 04 24 74 2c 80 00 	movl   $0x802c74,(%esp)
  801e03:	e8 d8 05 00 00       	call   8023e0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e08:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e0c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e13:	00 
  801e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e17:	89 04 24             	mov    %eax,(%esp)
  801e1a:	e8 49 eb ff ff       	call   800968 <memmove>
	}

	return r;
}
  801e1f:	89 d8                	mov    %ebx,%eax
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5d                   	pop    %ebp
  801e27:	c3                   	ret    

00801e28 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	53                   	push   %ebx
  801e2c:	83 ec 14             	sub    $0x14,%esp
  801e2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e3a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e40:	7e 24                	jle    801e66 <nsipc_send+0x3e>
  801e42:	c7 44 24 0c 80 2c 80 	movl   $0x802c80,0xc(%esp)
  801e49:	00 
  801e4a:	c7 44 24 08 27 2c 80 	movl   $0x802c27,0x8(%esp)
  801e51:	00 
  801e52:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801e59:	00 
  801e5a:	c7 04 24 74 2c 80 00 	movl   $0x802c74,(%esp)
  801e61:	e8 7a 05 00 00       	call   8023e0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e66:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e71:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e78:	e8 eb ea ff ff       	call   800968 <memmove>
	nsipcbuf.send.req_size = size;
  801e7d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e83:	8b 45 14             	mov    0x14(%ebp),%eax
  801e86:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e8b:	b8 08 00 00 00       	mov    $0x8,%eax
  801e90:	e8 7b fd ff ff       	call   801c10 <nsipc>
}
  801e95:	83 c4 14             	add    $0x14,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eac:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801eb1:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801eb9:	b8 09 00 00 00       	mov    $0x9,%eax
  801ebe:	e8 4d fd ff ff       	call   801c10 <nsipc>
}
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    
  801ec5:	00 00                	add    %al,(%eax)
	...

00801ec8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	56                   	push   %esi
  801ecc:	53                   	push   %ebx
  801ecd:	83 ec 10             	sub    $0x10,%esp
  801ed0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed6:	89 04 24             	mov    %eax,(%esp)
  801ed9:	e8 36 f1 ff ff       	call   801014 <fd2data>
  801ede:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ee0:	c7 44 24 04 8c 2c 80 	movl   $0x802c8c,0x4(%esp)
  801ee7:	00 
  801ee8:	89 34 24             	mov    %esi,(%esp)
  801eeb:	e8 ff e8 ff ff       	call   8007ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ef0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ef3:	2b 03                	sub    (%ebx),%eax
  801ef5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801efb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f02:	00 00 00 
	stat->st_dev = &devpipe;
  801f05:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801f0c:	30 80 00 
	return 0;
}
  801f0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	5b                   	pop    %ebx
  801f18:	5e                   	pop    %esi
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    

00801f1b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	53                   	push   %ebx
  801f1f:	83 ec 14             	sub    $0x14,%esp
  801f22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f30:	e8 53 ed ff ff       	call   800c88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f35:	89 1c 24             	mov    %ebx,(%esp)
  801f38:	e8 d7 f0 ff ff       	call   801014 <fd2data>
  801f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f48:	e8 3b ed ff ff       	call   800c88 <sys_page_unmap>
}
  801f4d:	83 c4 14             	add    $0x14,%esp
  801f50:	5b                   	pop    %ebx
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	57                   	push   %edi
  801f57:	56                   	push   %esi
  801f58:	53                   	push   %ebx
  801f59:	83 ec 2c             	sub    $0x2c,%esp
  801f5c:	89 c7                	mov    %eax,%edi
  801f5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f61:	a1 08 40 80 00       	mov    0x804008,%eax
  801f66:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f69:	89 3c 24             	mov    %edi,(%esp)
  801f6c:	e8 ff 05 00 00       	call   802570 <pageref>
  801f71:	89 c6                	mov    %eax,%esi
  801f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f76:	89 04 24             	mov    %eax,(%esp)
  801f79:	e8 f2 05 00 00       	call   802570 <pageref>
  801f7e:	39 c6                	cmp    %eax,%esi
  801f80:	0f 94 c0             	sete   %al
  801f83:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f86:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f8c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f8f:	39 cb                	cmp    %ecx,%ebx
  801f91:	75 08                	jne    801f9b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f93:	83 c4 2c             	add    $0x2c,%esp
  801f96:	5b                   	pop    %ebx
  801f97:	5e                   	pop    %esi
  801f98:	5f                   	pop    %edi
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f9b:	83 f8 01             	cmp    $0x1,%eax
  801f9e:	75 c1                	jne    801f61 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fa0:	8b 42 58             	mov    0x58(%edx),%eax
  801fa3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801faa:	00 
  801fab:	89 44 24 08          	mov    %eax,0x8(%esp)
  801faf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fb3:	c7 04 24 93 2c 80 00 	movl   $0x802c93,(%esp)
  801fba:	e8 85 e2 ff ff       	call   800244 <cprintf>
  801fbf:	eb a0                	jmp    801f61 <_pipeisclosed+0xe>

00801fc1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	57                   	push   %edi
  801fc5:	56                   	push   %esi
  801fc6:	53                   	push   %ebx
  801fc7:	83 ec 1c             	sub    $0x1c,%esp
  801fca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fcd:	89 34 24             	mov    %esi,(%esp)
  801fd0:	e8 3f f0 ff ff       	call   801014 <fd2data>
  801fd5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd7:	bf 00 00 00 00       	mov    $0x0,%edi
  801fdc:	eb 3c                	jmp    80201a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fde:	89 da                	mov    %ebx,%edx
  801fe0:	89 f0                	mov    %esi,%eax
  801fe2:	e8 6c ff ff ff       	call   801f53 <_pipeisclosed>
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	75 38                	jne    802023 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801feb:	e8 d2 eb ff ff       	call   800bc2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ff0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ff3:	8b 13                	mov    (%ebx),%edx
  801ff5:	83 c2 20             	add    $0x20,%edx
  801ff8:	39 d0                	cmp    %edx,%eax
  801ffa:	73 e2                	jae    801fde <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ffc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fff:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802002:	89 c2                	mov    %eax,%edx
  802004:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80200a:	79 05                	jns    802011 <devpipe_write+0x50>
  80200c:	4a                   	dec    %edx
  80200d:	83 ca e0             	or     $0xffffffe0,%edx
  802010:	42                   	inc    %edx
  802011:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802015:	40                   	inc    %eax
  802016:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802019:	47                   	inc    %edi
  80201a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80201d:	75 d1                	jne    801ff0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80201f:	89 f8                	mov    %edi,%eax
  802021:	eb 05                	jmp    802028 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802023:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802028:	83 c4 1c             	add    $0x1c,%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5e                   	pop    %esi
  80202d:	5f                   	pop    %edi
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    

00802030 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	57                   	push   %edi
  802034:	56                   	push   %esi
  802035:	53                   	push   %ebx
  802036:	83 ec 1c             	sub    $0x1c,%esp
  802039:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80203c:	89 3c 24             	mov    %edi,(%esp)
  80203f:	e8 d0 ef ff ff       	call   801014 <fd2data>
  802044:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802046:	be 00 00 00 00       	mov    $0x0,%esi
  80204b:	eb 3a                	jmp    802087 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80204d:	85 f6                	test   %esi,%esi
  80204f:	74 04                	je     802055 <devpipe_read+0x25>
				return i;
  802051:	89 f0                	mov    %esi,%eax
  802053:	eb 40                	jmp    802095 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802055:	89 da                	mov    %ebx,%edx
  802057:	89 f8                	mov    %edi,%eax
  802059:	e8 f5 fe ff ff       	call   801f53 <_pipeisclosed>
  80205e:	85 c0                	test   %eax,%eax
  802060:	75 2e                	jne    802090 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802062:	e8 5b eb ff ff       	call   800bc2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802067:	8b 03                	mov    (%ebx),%eax
  802069:	3b 43 04             	cmp    0x4(%ebx),%eax
  80206c:	74 df                	je     80204d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80206e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802073:	79 05                	jns    80207a <devpipe_read+0x4a>
  802075:	48                   	dec    %eax
  802076:	83 c8 e0             	or     $0xffffffe0,%eax
  802079:	40                   	inc    %eax
  80207a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80207e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802081:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802084:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802086:	46                   	inc    %esi
  802087:	3b 75 10             	cmp    0x10(%ebp),%esi
  80208a:	75 db                	jne    802067 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80208c:	89 f0                	mov    %esi,%eax
  80208e:	eb 05                	jmp    802095 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802090:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802095:	83 c4 1c             	add    $0x1c,%esp
  802098:	5b                   	pop    %ebx
  802099:	5e                   	pop    %esi
  80209a:	5f                   	pop    %edi
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    

0080209d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	57                   	push   %edi
  8020a1:	56                   	push   %esi
  8020a2:	53                   	push   %ebx
  8020a3:	83 ec 3c             	sub    $0x3c,%esp
  8020a6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8020ac:	89 04 24             	mov    %eax,(%esp)
  8020af:	e8 7b ef ff ff       	call   80102f <fd_alloc>
  8020b4:	89 c3                	mov    %eax,%ebx
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	0f 88 45 01 00 00    	js     802203 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020be:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020c5:	00 
  8020c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d4:	e8 08 eb ff ff       	call   800be1 <sys_page_alloc>
  8020d9:	89 c3                	mov    %eax,%ebx
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	0f 88 20 01 00 00    	js     802203 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8020e6:	89 04 24             	mov    %eax,(%esp)
  8020e9:	e8 41 ef ff ff       	call   80102f <fd_alloc>
  8020ee:	89 c3                	mov    %eax,%ebx
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	0f 88 f8 00 00 00    	js     8021f0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020ff:	00 
  802100:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802103:	89 44 24 04          	mov    %eax,0x4(%esp)
  802107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210e:	e8 ce ea ff ff       	call   800be1 <sys_page_alloc>
  802113:	89 c3                	mov    %eax,%ebx
  802115:	85 c0                	test   %eax,%eax
  802117:	0f 88 d3 00 00 00    	js     8021f0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80211d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802120:	89 04 24             	mov    %eax,(%esp)
  802123:	e8 ec ee ff ff       	call   801014 <fd2data>
  802128:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802131:	00 
  802132:	89 44 24 04          	mov    %eax,0x4(%esp)
  802136:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80213d:	e8 9f ea ff ff       	call   800be1 <sys_page_alloc>
  802142:	89 c3                	mov    %eax,%ebx
  802144:	85 c0                	test   %eax,%eax
  802146:	0f 88 91 00 00 00    	js     8021dd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80214f:	89 04 24             	mov    %eax,(%esp)
  802152:	e8 bd ee ff ff       	call   801014 <fd2data>
  802157:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80215e:	00 
  80215f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802163:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80216a:	00 
  80216b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802176:	e8 ba ea ff ff       	call   800c35 <sys_page_map>
  80217b:	89 c3                	mov    %eax,%ebx
  80217d:	85 c0                	test   %eax,%eax
  80217f:	78 4c                	js     8021cd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802181:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802187:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80218a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80218c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80218f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802196:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80219c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80219f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021a4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ae:	89 04 24             	mov    %eax,(%esp)
  8021b1:	e8 4e ee ff ff       	call   801004 <fd2num>
  8021b6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8021b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021bb:	89 04 24             	mov    %eax,(%esp)
  8021be:	e8 41 ee ff ff       	call   801004 <fd2num>
  8021c3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8021c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021cb:	eb 36                	jmp    802203 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8021cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d8:	e8 ab ea ff ff       	call   800c88 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8021dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021eb:	e8 98 ea ff ff       	call   800c88 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8021f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021fe:	e8 85 ea ff ff       	call   800c88 <sys_page_unmap>
    err:
	return r;
}
  802203:	89 d8                	mov    %ebx,%eax
  802205:	83 c4 3c             	add    $0x3c,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    

0080220d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80221a:	8b 45 08             	mov    0x8(%ebp),%eax
  80221d:	89 04 24             	mov    %eax,(%esp)
  802220:	e8 5d ee ff ff       	call   801082 <fd_lookup>
  802225:	85 c0                	test   %eax,%eax
  802227:	78 15                	js     80223e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802229:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222c:	89 04 24             	mov    %eax,(%esp)
  80222f:	e8 e0 ed ff ff       	call   801014 <fd2data>
	return _pipeisclosed(fd, p);
  802234:	89 c2                	mov    %eax,%edx
  802236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802239:	e8 15 fd ff ff       	call   801f53 <_pipeisclosed>
}
  80223e:	c9                   	leave  
  80223f:	c3                   	ret    

00802240 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802243:	b8 00 00 00 00       	mov    $0x0,%eax
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802250:	c7 44 24 04 ab 2c 80 	movl   $0x802cab,0x4(%esp)
  802257:	00 
  802258:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225b:	89 04 24             	mov    %eax,(%esp)
  80225e:	e8 8c e5 ff ff       	call   8007ef <strcpy>
	return 0;
}
  802263:	b8 00 00 00 00       	mov    $0x0,%eax
  802268:	c9                   	leave  
  802269:	c3                   	ret    

0080226a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	57                   	push   %edi
  80226e:	56                   	push   %esi
  80226f:	53                   	push   %ebx
  802270:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802276:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80227b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802281:	eb 30                	jmp    8022b3 <devcons_write+0x49>
		m = n - tot;
  802283:	8b 75 10             	mov    0x10(%ebp),%esi
  802286:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802288:	83 fe 7f             	cmp    $0x7f,%esi
  80228b:	76 05                	jbe    802292 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80228d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802292:	89 74 24 08          	mov    %esi,0x8(%esp)
  802296:	03 45 0c             	add    0xc(%ebp),%eax
  802299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80229d:	89 3c 24             	mov    %edi,(%esp)
  8022a0:	e8 c3 e6 ff ff       	call   800968 <memmove>
		sys_cputs(buf, m);
  8022a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a9:	89 3c 24             	mov    %edi,(%esp)
  8022ac:	e8 63 e8 ff ff       	call   800b14 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022b1:	01 f3                	add    %esi,%ebx
  8022b3:	89 d8                	mov    %ebx,%eax
  8022b5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022b8:	72 c9                	jb     802283 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022ba:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8022cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022cf:	75 07                	jne    8022d8 <devcons_read+0x13>
  8022d1:	eb 25                	jmp    8022f8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022d3:	e8 ea e8 ff ff       	call   800bc2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022d8:	e8 55 e8 ff ff       	call   800b32 <sys_cgetc>
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	74 f2                	je     8022d3 <devcons_read+0xe>
  8022e1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8022e3:	85 c0                	test   %eax,%eax
  8022e5:	78 1d                	js     802304 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022e7:	83 f8 04             	cmp    $0x4,%eax
  8022ea:	74 13                	je     8022ff <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8022ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ef:	88 10                	mov    %dl,(%eax)
	return 1;
  8022f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f6:	eb 0c                	jmp    802304 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8022f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8022fd:	eb 05                	jmp    802304 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802304:	c9                   	leave  
  802305:	c3                   	ret    

00802306 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80230c:	8b 45 08             	mov    0x8(%ebp),%eax
  80230f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802312:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802319:	00 
  80231a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80231d:	89 04 24             	mov    %eax,(%esp)
  802320:	e8 ef e7 ff ff       	call   800b14 <sys_cputs>
}
  802325:	c9                   	leave  
  802326:	c3                   	ret    

00802327 <getchar>:

int
getchar(void)
{
  802327:	55                   	push   %ebp
  802328:	89 e5                	mov    %esp,%ebp
  80232a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80232d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802334:	00 
  802335:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802343:	e8 d8 ef ff ff       	call   801320 <read>
	if (r < 0)
  802348:	85 c0                	test   %eax,%eax
  80234a:	78 0f                	js     80235b <getchar+0x34>
		return r;
	if (r < 1)
  80234c:	85 c0                	test   %eax,%eax
  80234e:	7e 06                	jle    802356 <getchar+0x2f>
		return -E_EOF;
	return c;
  802350:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802354:	eb 05                	jmp    80235b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802356:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80235b:	c9                   	leave  
  80235c:	c3                   	ret    

0080235d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80235d:	55                   	push   %ebp
  80235e:	89 e5                	mov    %esp,%ebp
  802360:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802363:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802366:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236a:	8b 45 08             	mov    0x8(%ebp),%eax
  80236d:	89 04 24             	mov    %eax,(%esp)
  802370:	e8 0d ed ff ff       	call   801082 <fd_lookup>
  802375:	85 c0                	test   %eax,%eax
  802377:	78 11                	js     80238a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802379:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802382:	39 10                	cmp    %edx,(%eax)
  802384:	0f 94 c0             	sete   %al
  802387:	0f b6 c0             	movzbl %al,%eax
}
  80238a:	c9                   	leave  
  80238b:	c3                   	ret    

0080238c <opencons>:

int
opencons(void)
{
  80238c:	55                   	push   %ebp
  80238d:	89 e5                	mov    %esp,%ebp
  80238f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802392:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802395:	89 04 24             	mov    %eax,(%esp)
  802398:	e8 92 ec ff ff       	call   80102f <fd_alloc>
  80239d:	85 c0                	test   %eax,%eax
  80239f:	78 3c                	js     8023dd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023a1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023a8:	00 
  8023a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b7:	e8 25 e8 ff ff       	call   800be1 <sys_page_alloc>
  8023bc:	85 c0                	test   %eax,%eax
  8023be:	78 1d                	js     8023dd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023c0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023d5:	89 04 24             	mov    %eax,(%esp)
  8023d8:	e8 27 ec ff ff       	call   801004 <fd2num>
}
  8023dd:	c9                   	leave  
  8023de:	c3                   	ret    
	...

008023e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8023e0:	55                   	push   %ebp
  8023e1:	89 e5                	mov    %esp,%ebp
  8023e3:	56                   	push   %esi
  8023e4:	53                   	push   %ebx
  8023e5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8023e8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8023eb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8023f1:	e8 ad e7 ff ff       	call   800ba3 <sys_getenvid>
  8023f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8023fd:	8b 55 08             	mov    0x8(%ebp),%edx
  802400:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802404:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80240c:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  802413:	e8 2c de ff ff       	call   800244 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802418:	89 74 24 04          	mov    %esi,0x4(%esp)
  80241c:	8b 45 10             	mov    0x10(%ebp),%eax
  80241f:	89 04 24             	mov    %eax,(%esp)
  802422:	e8 bc dd ff ff       	call   8001e3 <vcprintf>
	cprintf("\n");
  802427:	c7 04 24 30 28 80 00 	movl   $0x802830,(%esp)
  80242e:	e8 11 de ff ff       	call   800244 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802433:	cc                   	int3   
  802434:	eb fd                	jmp    802433 <_panic+0x53>
	...

00802438 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	56                   	push   %esi
  80243c:	53                   	push   %ebx
  80243d:	83 ec 10             	sub    $0x10,%esp
  802440:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802443:	8b 45 0c             	mov    0xc(%ebp),%eax
  802446:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802449:	85 c0                	test   %eax,%eax
  80244b:	74 0a                	je     802457 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  80244d:	89 04 24             	mov    %eax,(%esp)
  802450:	e8 a2 e9 ff ff       	call   800df7 <sys_ipc_recv>
  802455:	eb 0c                	jmp    802463 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802457:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80245e:	e8 94 e9 ff ff       	call   800df7 <sys_ipc_recv>
	}
	if (r < 0)
  802463:	85 c0                	test   %eax,%eax
  802465:	79 16                	jns    80247d <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802467:	85 db                	test   %ebx,%ebx
  802469:	74 06                	je     802471 <ipc_recv+0x39>
  80246b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802471:	85 f6                	test   %esi,%esi
  802473:	74 2c                	je     8024a1 <ipc_recv+0x69>
  802475:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80247b:	eb 24                	jmp    8024a1 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  80247d:	85 db                	test   %ebx,%ebx
  80247f:	74 0a                	je     80248b <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802481:	a1 08 40 80 00       	mov    0x804008,%eax
  802486:	8b 40 74             	mov    0x74(%eax),%eax
  802489:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80248b:	85 f6                	test   %esi,%esi
  80248d:	74 0a                	je     802499 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80248f:	a1 08 40 80 00       	mov    0x804008,%eax
  802494:	8b 40 78             	mov    0x78(%eax),%eax
  802497:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802499:	a1 08 40 80 00       	mov    0x804008,%eax
  80249e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8024a1:	83 c4 10             	add    $0x10,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    

008024a8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024a8:	55                   	push   %ebp
  8024a9:	89 e5                	mov    %esp,%ebp
  8024ab:	57                   	push   %edi
  8024ac:	56                   	push   %esi
  8024ad:	53                   	push   %ebx
  8024ae:	83 ec 1c             	sub    $0x1c,%esp
  8024b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8024ba:	85 db                	test   %ebx,%ebx
  8024bc:	74 19                	je     8024d7 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8024be:	8b 45 14             	mov    0x14(%ebp),%eax
  8024c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024cd:	89 34 24             	mov    %esi,(%esp)
  8024d0:	e8 ff e8 ff ff       	call   800dd4 <sys_ipc_try_send>
  8024d5:	eb 1c                	jmp    8024f3 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8024d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8024de:	00 
  8024df:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8024e6:	ee 
  8024e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024eb:	89 34 24             	mov    %esi,(%esp)
  8024ee:	e8 e1 e8 ff ff       	call   800dd4 <sys_ipc_try_send>
		}
		if (r == 0)
  8024f3:	85 c0                	test   %eax,%eax
  8024f5:	74 2c                	je     802523 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8024f7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024fa:	74 20                	je     80251c <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8024fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802500:	c7 44 24 08 dc 2c 80 	movl   $0x802cdc,0x8(%esp)
  802507:	00 
  802508:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80250f:	00 
  802510:	c7 04 24 ef 2c 80 00 	movl   $0x802cef,(%esp)
  802517:	e8 c4 fe ff ff       	call   8023e0 <_panic>
		}
		sys_yield();
  80251c:	e8 a1 e6 ff ff       	call   800bc2 <sys_yield>
	}
  802521:	eb 97                	jmp    8024ba <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802523:	83 c4 1c             	add    $0x1c,%esp
  802526:	5b                   	pop    %ebx
  802527:	5e                   	pop    %esi
  802528:	5f                   	pop    %edi
  802529:	5d                   	pop    %ebp
  80252a:	c3                   	ret    

0080252b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80252b:	55                   	push   %ebp
  80252c:	89 e5                	mov    %esp,%ebp
  80252e:	53                   	push   %ebx
  80252f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802532:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802537:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80253e:	89 c2                	mov    %eax,%edx
  802540:	c1 e2 07             	shl    $0x7,%edx
  802543:	29 ca                	sub    %ecx,%edx
  802545:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80254b:	8b 52 50             	mov    0x50(%edx),%edx
  80254e:	39 da                	cmp    %ebx,%edx
  802550:	75 0f                	jne    802561 <ipc_find_env+0x36>
			return envs[i].env_id;
  802552:	c1 e0 07             	shl    $0x7,%eax
  802555:	29 c8                	sub    %ecx,%eax
  802557:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80255c:	8b 40 40             	mov    0x40(%eax),%eax
  80255f:	eb 0c                	jmp    80256d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802561:	40                   	inc    %eax
  802562:	3d 00 04 00 00       	cmp    $0x400,%eax
  802567:	75 ce                	jne    802537 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802569:	66 b8 00 00          	mov    $0x0,%ax
}
  80256d:	5b                   	pop    %ebx
  80256e:	5d                   	pop    %ebp
  80256f:	c3                   	ret    

00802570 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802570:	55                   	push   %ebp
  802571:	89 e5                	mov    %esp,%ebp
  802573:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802576:	89 c2                	mov    %eax,%edx
  802578:	c1 ea 16             	shr    $0x16,%edx
  80257b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802582:	f6 c2 01             	test   $0x1,%dl
  802585:	74 1e                	je     8025a5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802587:	c1 e8 0c             	shr    $0xc,%eax
  80258a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802591:	a8 01                	test   $0x1,%al
  802593:	74 17                	je     8025ac <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802595:	c1 e8 0c             	shr    $0xc,%eax
  802598:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80259f:	ef 
  8025a0:	0f b7 c0             	movzwl %ax,%eax
  8025a3:	eb 0c                	jmp    8025b1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8025a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8025aa:	eb 05                	jmp    8025b1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8025ac:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8025b1:	5d                   	pop    %ebp
  8025b2:	c3                   	ret    
	...

008025b4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8025b4:	55                   	push   %ebp
  8025b5:	57                   	push   %edi
  8025b6:	56                   	push   %esi
  8025b7:	83 ec 10             	sub    $0x10,%esp
  8025ba:	8b 74 24 20          	mov    0x20(%esp),%esi
  8025be:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025c6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8025ca:	89 cd                	mov    %ecx,%ebp
  8025cc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025d0:	85 c0                	test   %eax,%eax
  8025d2:	75 2c                	jne    802600 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8025d4:	39 f9                	cmp    %edi,%ecx
  8025d6:	77 68                	ja     802640 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025d8:	85 c9                	test   %ecx,%ecx
  8025da:	75 0b                	jne    8025e7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e1:	31 d2                	xor    %edx,%edx
  8025e3:	f7 f1                	div    %ecx
  8025e5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025e7:	31 d2                	xor    %edx,%edx
  8025e9:	89 f8                	mov    %edi,%eax
  8025eb:	f7 f1                	div    %ecx
  8025ed:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025ef:	89 f0                	mov    %esi,%eax
  8025f1:	f7 f1                	div    %ecx
  8025f3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025f5:	89 f0                	mov    %esi,%eax
  8025f7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025f9:	83 c4 10             	add    $0x10,%esp
  8025fc:	5e                   	pop    %esi
  8025fd:	5f                   	pop    %edi
  8025fe:	5d                   	pop    %ebp
  8025ff:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802600:	39 f8                	cmp    %edi,%eax
  802602:	77 2c                	ja     802630 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802604:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802607:	83 f6 1f             	xor    $0x1f,%esi
  80260a:	75 4c                	jne    802658 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80260c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80260e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802613:	72 0a                	jb     80261f <__udivdi3+0x6b>
  802615:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802619:	0f 87 ad 00 00 00    	ja     8026cc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80261f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802624:	89 f0                	mov    %esi,%eax
  802626:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802628:	83 c4 10             	add    $0x10,%esp
  80262b:	5e                   	pop    %esi
  80262c:	5f                   	pop    %edi
  80262d:	5d                   	pop    %ebp
  80262e:	c3                   	ret    
  80262f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802630:	31 ff                	xor    %edi,%edi
  802632:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802634:	89 f0                	mov    %esi,%eax
  802636:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802638:	83 c4 10             	add    $0x10,%esp
  80263b:	5e                   	pop    %esi
  80263c:	5f                   	pop    %edi
  80263d:	5d                   	pop    %ebp
  80263e:	c3                   	ret    
  80263f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802640:	89 fa                	mov    %edi,%edx
  802642:	89 f0                	mov    %esi,%eax
  802644:	f7 f1                	div    %ecx
  802646:	89 c6                	mov    %eax,%esi
  802648:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80264a:	89 f0                	mov    %esi,%eax
  80264c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80264e:	83 c4 10             	add    $0x10,%esp
  802651:	5e                   	pop    %esi
  802652:	5f                   	pop    %edi
  802653:	5d                   	pop    %ebp
  802654:	c3                   	ret    
  802655:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802658:	89 f1                	mov    %esi,%ecx
  80265a:	d3 e0                	shl    %cl,%eax
  80265c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802660:	b8 20 00 00 00       	mov    $0x20,%eax
  802665:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802667:	89 ea                	mov    %ebp,%edx
  802669:	88 c1                	mov    %al,%cl
  80266b:	d3 ea                	shr    %cl,%edx
  80266d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802671:	09 ca                	or     %ecx,%edx
  802673:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802677:	89 f1                	mov    %esi,%ecx
  802679:	d3 e5                	shl    %cl,%ebp
  80267b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80267f:	89 fd                	mov    %edi,%ebp
  802681:	88 c1                	mov    %al,%cl
  802683:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802685:	89 fa                	mov    %edi,%edx
  802687:	89 f1                	mov    %esi,%ecx
  802689:	d3 e2                	shl    %cl,%edx
  80268b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80268f:	88 c1                	mov    %al,%cl
  802691:	d3 ef                	shr    %cl,%edi
  802693:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802695:	89 f8                	mov    %edi,%eax
  802697:	89 ea                	mov    %ebp,%edx
  802699:	f7 74 24 08          	divl   0x8(%esp)
  80269d:	89 d1                	mov    %edx,%ecx
  80269f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8026a1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026a5:	39 d1                	cmp    %edx,%ecx
  8026a7:	72 17                	jb     8026c0 <__udivdi3+0x10c>
  8026a9:	74 09                	je     8026b4 <__udivdi3+0x100>
  8026ab:	89 fe                	mov    %edi,%esi
  8026ad:	31 ff                	xor    %edi,%edi
  8026af:	e9 41 ff ff ff       	jmp    8025f5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8026b4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026b8:	89 f1                	mov    %esi,%ecx
  8026ba:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026bc:	39 c2                	cmp    %eax,%edx
  8026be:	73 eb                	jae    8026ab <__udivdi3+0xf7>
		{
		  q0--;
  8026c0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026c3:	31 ff                	xor    %edi,%edi
  8026c5:	e9 2b ff ff ff       	jmp    8025f5 <__udivdi3+0x41>
  8026ca:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026cc:	31 f6                	xor    %esi,%esi
  8026ce:	e9 22 ff ff ff       	jmp    8025f5 <__udivdi3+0x41>
	...

008026d4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8026d4:	55                   	push   %ebp
  8026d5:	57                   	push   %edi
  8026d6:	56                   	push   %esi
  8026d7:	83 ec 20             	sub    $0x20,%esp
  8026da:	8b 44 24 30          	mov    0x30(%esp),%eax
  8026de:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026e2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8026e6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8026ea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026ee:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8026f2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8026f4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026f6:	85 ed                	test   %ebp,%ebp
  8026f8:	75 16                	jne    802710 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8026fa:	39 f1                	cmp    %esi,%ecx
  8026fc:	0f 86 a6 00 00 00    	jbe    8027a8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802702:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802704:	89 d0                	mov    %edx,%eax
  802706:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802708:	83 c4 20             	add    $0x20,%esp
  80270b:	5e                   	pop    %esi
  80270c:	5f                   	pop    %edi
  80270d:	5d                   	pop    %ebp
  80270e:	c3                   	ret    
  80270f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802710:	39 f5                	cmp    %esi,%ebp
  802712:	0f 87 ac 00 00 00    	ja     8027c4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802718:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80271b:	83 f0 1f             	xor    $0x1f,%eax
  80271e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802722:	0f 84 a8 00 00 00    	je     8027d0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802728:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80272c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80272e:	bf 20 00 00 00       	mov    $0x20,%edi
  802733:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802737:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80273b:	89 f9                	mov    %edi,%ecx
  80273d:	d3 e8                	shr    %cl,%eax
  80273f:	09 e8                	or     %ebp,%eax
  802741:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802745:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802749:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80274d:	d3 e0                	shl    %cl,%eax
  80274f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802753:	89 f2                	mov    %esi,%edx
  802755:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802757:	8b 44 24 14          	mov    0x14(%esp),%eax
  80275b:	d3 e0                	shl    %cl,%eax
  80275d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802761:	8b 44 24 14          	mov    0x14(%esp),%eax
  802765:	89 f9                	mov    %edi,%ecx
  802767:	d3 e8                	shr    %cl,%eax
  802769:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80276b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80276d:	89 f2                	mov    %esi,%edx
  80276f:	f7 74 24 18          	divl   0x18(%esp)
  802773:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802775:	f7 64 24 0c          	mull   0xc(%esp)
  802779:	89 c5                	mov    %eax,%ebp
  80277b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80277d:	39 d6                	cmp    %edx,%esi
  80277f:	72 67                	jb     8027e8 <__umoddi3+0x114>
  802781:	74 75                	je     8027f8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802783:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802787:	29 e8                	sub    %ebp,%eax
  802789:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80278b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80278f:	d3 e8                	shr    %cl,%eax
  802791:	89 f2                	mov    %esi,%edx
  802793:	89 f9                	mov    %edi,%ecx
  802795:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802797:	09 d0                	or     %edx,%eax
  802799:	89 f2                	mov    %esi,%edx
  80279b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80279f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027a1:	83 c4 20             	add    $0x20,%esp
  8027a4:	5e                   	pop    %esi
  8027a5:	5f                   	pop    %edi
  8027a6:	5d                   	pop    %ebp
  8027a7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8027a8:	85 c9                	test   %ecx,%ecx
  8027aa:	75 0b                	jne    8027b7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8027ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b1:	31 d2                	xor    %edx,%edx
  8027b3:	f7 f1                	div    %ecx
  8027b5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8027b7:	89 f0                	mov    %esi,%eax
  8027b9:	31 d2                	xor    %edx,%edx
  8027bb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027bd:	89 f8                	mov    %edi,%eax
  8027bf:	e9 3e ff ff ff       	jmp    802702 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8027c4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027c6:	83 c4 20             	add    $0x20,%esp
  8027c9:	5e                   	pop    %esi
  8027ca:	5f                   	pop    %edi
  8027cb:	5d                   	pop    %ebp
  8027cc:	c3                   	ret    
  8027cd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027d0:	39 f5                	cmp    %esi,%ebp
  8027d2:	72 04                	jb     8027d8 <__umoddi3+0x104>
  8027d4:	39 f9                	cmp    %edi,%ecx
  8027d6:	77 06                	ja     8027de <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027d8:	89 f2                	mov    %esi,%edx
  8027da:	29 cf                	sub    %ecx,%edi
  8027dc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8027de:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027e0:	83 c4 20             	add    $0x20,%esp
  8027e3:	5e                   	pop    %esi
  8027e4:	5f                   	pop    %edi
  8027e5:	5d                   	pop    %ebp
  8027e6:	c3                   	ret    
  8027e7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027e8:	89 d1                	mov    %edx,%ecx
  8027ea:	89 c5                	mov    %eax,%ebp
  8027ec:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8027f0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8027f4:	eb 8d                	jmp    802783 <__umoddi3+0xaf>
  8027f6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027f8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8027fc:	72 ea                	jb     8027e8 <__umoddi3+0x114>
  8027fe:	89 f1                	mov    %esi,%ecx
  802800:	eb 81                	jmp    802783 <__umoddi3+0xaf>
