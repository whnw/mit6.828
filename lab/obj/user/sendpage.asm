
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 f0 0f 00 00       	call   80102f <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bb 00 00 00    	jne    800105 <umain+0xd1>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 af 12 00 00       	call   801314 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 60 2a 80 00 	movl   $0x802a60,(%esp)
  80007b:	e8 70 02 00 00       	call   8002f0 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 40 80 00       	mov    0x804004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 db 07 00 00       	call   800868 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 40 80 00       	mov    0x804004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 bd 08 00 00       	call   800963 <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  8000b1:	e8 3a 02 00 00       	call   8002f0 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 40 80 00       	mov    0x804000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 a5 07 00 00       	call   800868 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 40 80 00       	mov    0x804000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 a1 09 00 00       	call   800a7e <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 84 12 00 00       	call   801384 <ipc_send>
		return;
  800100:	e9 d6 00 00 00       	jmp    8001db <umain+0x1a7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 08 50 80 00       	mov    0x805008,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011c:	00 
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 68 0b 00 00       	call   800c8d <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 40 80 00       	mov    0x804004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 36 07 00 00       	call   800868 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 40 80 00       	mov    0x804004,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800147:	e8 32 09 00 00       	call   800a7e <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800163:	00 
  800164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 15 12 00 00       	call   801384 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 8a 11 00 00       	call   801314 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 60 2a 80 00 	movl   $0x802a60,(%esp)
  8001a0:	e8 4b 01 00 00       	call   8002f0 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 40 80 00       	mov    0x804000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 b6 06 00 00       	call   800868 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 40 80 00       	mov    0x804000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 98 07 00 00       	call   800963 <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  8001d6:	e8 15 01 00 00       	call   8002f0 <cprintf>
	return;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	00 00                	add    %al,(%eax)
	...

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ee:	e8 5c 0a 00 00       	call   800c4f <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001ff:	c1 e0 07             	shl    $0x7,%eax
  800202:	29 d0                	sub    %edx,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 f6                	test   %esi,%esi
  800210:	7e 07                	jle    800219 <libmain+0x39>
		binaryname = argv[0];
  800212:	8b 03                	mov    (%ebx),%eax
  800214:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  800219:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021d:	89 34 24             	mov    %esi,(%esp)
  800220:	e8 0f fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800225:	e8 0a 00 00 00       	call   800234 <exit>
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5e                   	pop    %esi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
  800231:	00 00                	add    %al,(%eax)
	...

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80023a:	e8 f4 13 00 00       	call   801633 <close_all>
	sys_env_destroy(0);
  80023f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800246:	e8 b2 09 00 00       	call   800bfd <sys_env_destroy>
}
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    
  80024d:	00 00                	add    %al,(%eax)
	...

00800250 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	53                   	push   %ebx
  800254:	83 ec 14             	sub    $0x14,%esp
  800257:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80025a:	8b 03                	mov    (%ebx),%eax
  80025c:	8b 55 08             	mov    0x8(%ebp),%edx
  80025f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800263:	40                   	inc    %eax
  800264:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800266:	3d ff 00 00 00       	cmp    $0xff,%eax
  80026b:	75 19                	jne    800286 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80026d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800274:	00 
  800275:	8d 43 08             	lea    0x8(%ebx),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 40 09 00 00       	call   800bc0 <sys_cputs>
		b->idx = 0;
  800280:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800286:	ff 43 04             	incl   0x4(%ebx)
}
  800289:	83 c4 14             	add    $0x14,%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800298:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80029f:	00 00 00 
	b.cnt = 0;
  8002a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	c7 04 24 50 02 80 00 	movl   $0x800250,(%esp)
  8002cb:	e8 82 01 00 00       	call   800452 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	e8 d8 08 00 00       	call   800bc0 <sys_cputs>

	return b.cnt;
}
  8002e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	e8 87 ff ff ff       	call   80028f <vcprintf>
	va_end(ap);

	return cnt;
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    
	...

0080030c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 3c             	sub    $0x3c,%esp
  800315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800318:	89 d7                	mov    %edx,%edi
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
  800323:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800326:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800329:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80032c:	85 c0                	test   %eax,%eax
  80032e:	75 08                	jne    800338 <printnum+0x2c>
  800330:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800333:	39 45 10             	cmp    %eax,0x10(%ebp)
  800336:	77 57                	ja     80038f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800338:	89 74 24 10          	mov    %esi,0x10(%esp)
  80033c:	4b                   	dec    %ebx
  80033d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80034c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800350:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800357:	00 
  800358:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035b:	89 04 24             	mov    %eax,(%esp)
  80035e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800361:	89 44 24 04          	mov    %eax,0x4(%esp)
  800365:	e8 96 24 00 00       	call   802800 <__udivdi3>
  80036a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80036e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800372:	89 04 24             	mov    %eax,(%esp)
  800375:	89 54 24 04          	mov    %edx,0x4(%esp)
  800379:	89 fa                	mov    %edi,%edx
  80037b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037e:	e8 89 ff ff ff       	call   80030c <printnum>
  800383:	eb 0f                	jmp    800394 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800385:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800389:	89 34 24             	mov    %esi,(%esp)
  80038c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80038f:	4b                   	dec    %ebx
  800390:	85 db                	test   %ebx,%ebx
  800392:	7f f1                	jg     800385 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800394:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800398:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80039c:	8b 45 10             	mov    0x10(%ebp),%eax
  80039f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003aa:	00 
  8003ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b8:	e8 63 25 00 00       	call   802920 <__umoddi3>
  8003bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c1:	0f be 80 0c 2b 80 00 	movsbl 0x802b0c(%eax),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003ce:	83 c4 3c             	add    $0x3c,%esp
  8003d1:	5b                   	pop    %ebx
  8003d2:	5e                   	pop    %esi
  8003d3:	5f                   	pop    %edi
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d9:	83 fa 01             	cmp    $0x1,%edx
  8003dc:	7e 0e                	jle    8003ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ea:	eb 22                	jmp    80040e <getuint+0x38>
	else if (lflag)
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	74 10                	je     800400 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f5:	89 08                	mov    %ecx,(%eax)
  8003f7:	8b 02                	mov    (%edx),%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fe:	eb 0e                	jmp    80040e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 04             	lea    0x4(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800416:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	3b 50 04             	cmp    0x4(%eax),%edx
  80041e:	73 08                	jae    800428 <sprintputch+0x18>
		*b->buf++ = ch;
  800420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800423:	88 0a                	mov    %cl,(%edx)
  800425:	42                   	inc    %edx
  800426:	89 10                	mov    %edx,(%eax)
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800430:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	8b 45 10             	mov    0x10(%ebp),%eax
  80043a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800441:	89 44 24 04          	mov    %eax,0x4(%esp)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 02 00 00 00       	call   800452 <vprintfmt>
	va_end(ap);
}
  800450:	c9                   	leave  
  800451:	c3                   	ret    

00800452 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	57                   	push   %edi
  800456:	56                   	push   %esi
  800457:	53                   	push   %ebx
  800458:	83 ec 4c             	sub    $0x4c,%esp
  80045b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045e:	8b 75 10             	mov    0x10(%ebp),%esi
  800461:	eb 12                	jmp    800475 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800463:	85 c0                	test   %eax,%eax
  800465:	0f 84 6b 03 00 00    	je     8007d6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80046b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800475:	0f b6 06             	movzbl (%esi),%eax
  800478:	46                   	inc    %esi
  800479:	83 f8 25             	cmp    $0x25,%eax
  80047c:	75 e5                	jne    800463 <vprintfmt+0x11>
  80047e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800482:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800489:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80048e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800495:	b9 00 00 00 00       	mov    $0x0,%ecx
  80049a:	eb 26                	jmp    8004c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004a3:	eb 1d                	jmp    8004c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004ac:	eb 14                	jmp    8004c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b8:	eb 08                	jmp    8004c2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ba:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	0f b6 06             	movzbl (%esi),%eax
  8004c5:	8d 56 01             	lea    0x1(%esi),%edx
  8004c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004cb:	8a 16                	mov    (%esi),%dl
  8004cd:	83 ea 23             	sub    $0x23,%edx
  8004d0:	80 fa 55             	cmp    $0x55,%dl
  8004d3:	0f 87 e1 02 00 00    	ja     8007ba <vprintfmt+0x368>
  8004d9:	0f b6 d2             	movzbl %dl,%edx
  8004dc:	ff 24 95 40 2c 80 00 	jmp    *0x802c40(,%edx,4)
  8004e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004e6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004eb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ee:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004f2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004f5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f8:	83 fa 09             	cmp    $0x9,%edx
  8004fb:	77 2a                	ja     800527 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004fd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004fe:	eb eb                	jmp    8004eb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050e:	eb 17                	jmp    800527 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800514:	78 98                	js     8004ae <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800519:	eb a7                	jmp    8004c2 <vprintfmt+0x70>
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800525:	eb 9b                	jmp    8004c2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800527:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052b:	79 95                	jns    8004c2 <vprintfmt+0x70>
  80052d:	eb 8b                	jmp    8004ba <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800533:	eb 8d                	jmp    8004c2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80054d:	e9 23 ff ff ff       	jmp    800475 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	85 c0                	test   %eax,%eax
  80055f:	79 02                	jns    800563 <vprintfmt+0x111>
  800561:	f7 d8                	neg    %eax
  800563:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800565:	83 f8 10             	cmp    $0x10,%eax
  800568:	7f 0b                	jg     800575 <vprintfmt+0x123>
  80056a:	8b 04 85 a0 2d 80 00 	mov    0x802da0(,%eax,4),%eax
  800571:	85 c0                	test   %eax,%eax
  800573:	75 23                	jne    800598 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800575:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800579:	c7 44 24 08 24 2b 80 	movl   $0x802b24,0x8(%esp)
  800580:	00 
  800581:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800585:	8b 45 08             	mov    0x8(%ebp),%eax
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	e8 9a fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800593:	e9 dd fe ff ff       	jmp    800475 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800598:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059c:	c7 44 24 08 a9 2f 80 	movl   $0x802fa9,0x8(%esp)
  8005a3:	00 
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ab:	89 14 24             	mov    %edx,(%esp)
  8005ae:	e8 77 fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b6:	e9 ba fe ff ff       	jmp    800475 <vprintfmt+0x23>
  8005bb:	89 f9                	mov    %edi,%ecx
  8005bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 04             	lea    0x4(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 30                	mov    (%eax),%esi
  8005ce:	85 f6                	test   %esi,%esi
  8005d0:	75 05                	jne    8005d7 <vprintfmt+0x185>
				p = "(null)";
  8005d2:	be 1d 2b 80 00       	mov    $0x802b1d,%esi
			if (width > 0 && padc != '-')
  8005d7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005db:	0f 8e 84 00 00 00    	jle    800665 <vprintfmt+0x213>
  8005e1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005e5:	74 7e                	je     800665 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005eb:	89 34 24             	mov    %esi,(%esp)
  8005ee:	e8 8b 02 00 00       	call   80087e <strnlen>
  8005f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005f6:	29 c2                	sub    %eax,%edx
  8005f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005fb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005ff:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800602:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800605:	89 de                	mov    %ebx,%esi
  800607:	89 d3                	mov    %edx,%ebx
  800609:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060b:	eb 0b                	jmp    800618 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80060d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800611:	89 3c 24             	mov    %edi,(%esp)
  800614:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800617:	4b                   	dec    %ebx
  800618:	85 db                	test   %ebx,%ebx
  80061a:	7f f1                	jg     80060d <vprintfmt+0x1bb>
  80061c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80061f:	89 f3                	mov    %esi,%ebx
  800621:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800627:	85 c0                	test   %eax,%eax
  800629:	79 05                	jns    800630 <vprintfmt+0x1de>
  80062b:	b8 00 00 00 00       	mov    $0x0,%eax
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800633:	29 c2                	sub    %eax,%edx
  800635:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800638:	eb 2b                	jmp    800665 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063e:	74 18                	je     800658 <vprintfmt+0x206>
  800640:	8d 50 e0             	lea    -0x20(%eax),%edx
  800643:	83 fa 5e             	cmp    $0x5e,%edx
  800646:	76 10                	jbe    800658 <vprintfmt+0x206>
					putch('?', putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
  800656:	eb 0a                	jmp    800662 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800662:	ff 4d e4             	decl   -0x1c(%ebp)
  800665:	0f be 06             	movsbl (%esi),%eax
  800668:	46                   	inc    %esi
  800669:	85 c0                	test   %eax,%eax
  80066b:	74 21                	je     80068e <vprintfmt+0x23c>
  80066d:	85 ff                	test   %edi,%edi
  80066f:	78 c9                	js     80063a <vprintfmt+0x1e8>
  800671:	4f                   	dec    %edi
  800672:	79 c6                	jns    80063a <vprintfmt+0x1e8>
  800674:	8b 7d 08             	mov    0x8(%ebp),%edi
  800677:	89 de                	mov    %ebx,%esi
  800679:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80067c:	eb 18                	jmp    800696 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800682:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800689:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068b:	4b                   	dec    %ebx
  80068c:	eb 08                	jmp    800696 <vprintfmt+0x244>
  80068e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800691:	89 de                	mov    %ebx,%esi
  800693:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800696:	85 db                	test   %ebx,%ebx
  800698:	7f e4                	jg     80067e <vprintfmt+0x22c>
  80069a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80069d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a2:	e9 ce fd ff ff       	jmp    800475 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a7:	83 f9 01             	cmp    $0x1,%ecx
  8006aa:	7e 10                	jle    8006bc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 08             	lea    0x8(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	8b 30                	mov    (%eax),%esi
  8006b7:	8b 78 04             	mov    0x4(%eax),%edi
  8006ba:	eb 26                	jmp    8006e2 <vprintfmt+0x290>
	else if (lflag)
  8006bc:	85 c9                	test   %ecx,%ecx
  8006be:	74 12                	je     8006d2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8d 50 04             	lea    0x4(%eax),%edx
  8006c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c9:	8b 30                	mov    (%eax),%esi
  8006cb:	89 f7                	mov    %esi,%edi
  8006cd:	c1 ff 1f             	sar    $0x1f,%edi
  8006d0:	eb 10                	jmp    8006e2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006db:	8b 30                	mov    (%eax),%esi
  8006dd:	89 f7                	mov    %esi,%edi
  8006df:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e2:	85 ff                	test   %edi,%edi
  8006e4:	78 0a                	js     8006f0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006eb:	e9 8c 00 00 00       	jmp    80077c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006fe:	f7 de                	neg    %esi
  800700:	83 d7 00             	adc    $0x0,%edi
  800703:	f7 df                	neg    %edi
			}
			base = 10;
  800705:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070a:	eb 70                	jmp    80077c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070c:	89 ca                	mov    %ecx,%edx
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
  800711:	e8 c0 fc ff ff       	call   8003d6 <getuint>
  800716:	89 c6                	mov    %eax,%esi
  800718:	89 d7                	mov    %edx,%edi
			base = 10;
  80071a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80071f:	eb 5b                	jmp    80077c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800721:	89 ca                	mov    %ecx,%edx
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
  800726:	e8 ab fc ff ff       	call   8003d6 <getuint>
  80072b:	89 c6                	mov    %eax,%esi
  80072d:	89 d7                	mov    %edx,%edi
			base = 8;
  80072f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800734:	eb 46                	jmp    80077c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800736:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8d 50 04             	lea    0x4(%eax),%edx
  800758:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075b:	8b 30                	mov    (%eax),%esi
  80075d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800762:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800767:	eb 13                	jmp    80077c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800769:	89 ca                	mov    %ecx,%edx
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	e8 63 fc ff ff       	call   8003d6 <getuint>
  800773:	89 c6                	mov    %eax,%esi
  800775:	89 d7                	mov    %edx,%edi
			base = 16;
  800777:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800780:	89 54 24 10          	mov    %edx,0x10(%esp)
  800784:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800787:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80078b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078f:	89 34 24             	mov    %esi,(%esp)
  800792:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800796:	89 da                	mov    %ebx,%edx
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	e8 6c fb ff ff       	call   80030c <printnum>
			break;
  8007a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007a3:	e9 cd fc ff ff       	jmp    800475 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ac:	89 04 24             	mov    %eax,(%esp)
  8007af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b5:	e9 bb fc ff ff       	jmp    800475 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c8:	eb 01                	jmp    8007cb <vprintfmt+0x379>
  8007ca:	4e                   	dec    %esi
  8007cb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007cf:	75 f9                	jne    8007ca <vprintfmt+0x378>
  8007d1:	e9 9f fc ff ff       	jmp    800475 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007d6:	83 c4 4c             	add    $0x4c,%esp
  8007d9:	5b                   	pop    %ebx
  8007da:	5e                   	pop    %esi
  8007db:	5f                   	pop    %edi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	83 ec 28             	sub    $0x28,%esp
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fb:	85 c0                	test   %eax,%eax
  8007fd:	74 30                	je     80082f <vsnprintf+0x51>
  8007ff:	85 d2                	test   %edx,%edx
  800801:	7e 33                	jle    800836 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080a:	8b 45 10             	mov    0x10(%ebp),%eax
  80080d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800811:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	c7 04 24 10 04 80 00 	movl   $0x800410,(%esp)
  80081f:	e8 2e fc ff ff       	call   800452 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800824:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800827:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082d:	eb 0c                	jmp    80083b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800834:	eb 05                	jmp    80083b <vsnprintf+0x5d>
  800836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800846:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084a:	8b 45 10             	mov    0x10(%ebp),%eax
  80084d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800851:	8b 45 0c             	mov    0xc(%ebp),%eax
  800854:	89 44 24 04          	mov    %eax,0x4(%esp)
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	89 04 24             	mov    %eax,(%esp)
  80085e:	e8 7b ff ff ff       	call   8007de <vsnprintf>
	va_end(ap);

	return rc;
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    
  800865:	00 00                	add    %al,(%eax)
	...

00800868 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
  800873:	eb 01                	jmp    800876 <strlen+0xe>
		n++;
  800875:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087a:	75 f9                	jne    800875 <strlen+0xd>
		n++;
	return n;
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	eb 01                	jmp    80088f <strnlen+0x11>
		n++;
  80088e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088f:	39 d0                	cmp    %edx,%eax
  800891:	74 06                	je     800899 <strnlen+0x1b>
  800893:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800897:	75 f5                	jne    80088e <strnlen+0x10>
		n++;
	return n;
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008aa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b0:	42                   	inc    %edx
  8008b1:	84 c9                	test   %cl,%cl
  8008b3:	75 f5                	jne    8008aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	83 ec 08             	sub    $0x8,%esp
  8008bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c2:	89 1c 24             	mov    %ebx,(%esp)
  8008c5:	e8 9e ff ff ff       	call   800868 <strlen>
	strcpy(dst + len, src);
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d1:	01 d8                	add    %ebx,%eax
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	e8 c0 ff ff ff       	call   80089b <strcpy>
	return dst;
}
  8008db:	89 d8                	mov    %ebx,%eax
  8008dd:	83 c4 08             	add    $0x8,%esp
  8008e0:	5b                   	pop    %ebx
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f6:	eb 0c                	jmp    800904 <strncpy+0x21>
		*dst++ = *src;
  8008f8:	8a 1a                	mov    (%edx),%bl
  8008fa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008fd:	80 3a 01             	cmpb   $0x1,(%edx)
  800900:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800903:	41                   	inc    %ecx
  800904:	39 f1                	cmp    %esi,%ecx
  800906:	75 f0                	jne    8008f8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	8b 75 08             	mov    0x8(%ebp),%esi
  800914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800917:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091a:	85 d2                	test   %edx,%edx
  80091c:	75 0a                	jne    800928 <strlcpy+0x1c>
  80091e:	89 f0                	mov    %esi,%eax
  800920:	eb 1a                	jmp    80093c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800922:	88 18                	mov    %bl,(%eax)
  800924:	40                   	inc    %eax
  800925:	41                   	inc    %ecx
  800926:	eb 02                	jmp    80092a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800928:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80092a:	4a                   	dec    %edx
  80092b:	74 0a                	je     800937 <strlcpy+0x2b>
  80092d:	8a 19                	mov    (%ecx),%bl
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ef                	jne    800922 <strlcpy+0x16>
  800933:	89 c2                	mov    %eax,%edx
  800935:	eb 02                	jmp    800939 <strlcpy+0x2d>
  800937:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800939:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80093c:	29 f0                	sub    %esi,%eax
}
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094b:	eb 02                	jmp    80094f <strcmp+0xd>
		p++, q++;
  80094d:	41                   	inc    %ecx
  80094e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	8a 01                	mov    (%ecx),%al
  800951:	84 c0                	test   %al,%al
  800953:	74 04                	je     800959 <strcmp+0x17>
  800955:	3a 02                	cmp    (%edx),%al
  800957:	74 f4                	je     80094d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800959:	0f b6 c0             	movzbl %al,%eax
  80095c:	0f b6 12             	movzbl (%edx),%edx
  80095f:	29 d0                	sub    %edx,%eax
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800970:	eb 03                	jmp    800975 <strncmp+0x12>
		n--, p++, q++;
  800972:	4a                   	dec    %edx
  800973:	40                   	inc    %eax
  800974:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800975:	85 d2                	test   %edx,%edx
  800977:	74 14                	je     80098d <strncmp+0x2a>
  800979:	8a 18                	mov    (%eax),%bl
  80097b:	84 db                	test   %bl,%bl
  80097d:	74 04                	je     800983 <strncmp+0x20>
  80097f:	3a 19                	cmp    (%ecx),%bl
  800981:	74 ef                	je     800972 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800983:	0f b6 00             	movzbl (%eax),%eax
  800986:	0f b6 11             	movzbl (%ecx),%edx
  800989:	29 d0                	sub    %edx,%eax
  80098b:	eb 05                	jmp    800992 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800992:	5b                   	pop    %ebx
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80099e:	eb 05                	jmp    8009a5 <strchr+0x10>
		if (*s == c)
  8009a0:	38 ca                	cmp    %cl,%dl
  8009a2:	74 0c                	je     8009b0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a4:	40                   	inc    %eax
  8009a5:	8a 10                	mov    (%eax),%dl
  8009a7:	84 d2                	test   %dl,%dl
  8009a9:	75 f5                	jne    8009a0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009bb:	eb 05                	jmp    8009c2 <strfind+0x10>
		if (*s == c)
  8009bd:	38 ca                	cmp    %cl,%dl
  8009bf:	74 07                	je     8009c8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009c1:	40                   	inc    %eax
  8009c2:	8a 10                	mov    (%eax),%dl
  8009c4:	84 d2                	test   %dl,%dl
  8009c6:	75 f5                	jne    8009bd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d9:	85 c9                	test   %ecx,%ecx
  8009db:	74 30                	je     800a0d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e3:	75 25                	jne    800a0a <memset+0x40>
  8009e5:	f6 c1 03             	test   $0x3,%cl
  8009e8:	75 20                	jne    800a0a <memset+0x40>
		c &= 0xFF;
  8009ea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ed:	89 d3                	mov    %edx,%ebx
  8009ef:	c1 e3 08             	shl    $0x8,%ebx
  8009f2:	89 d6                	mov    %edx,%esi
  8009f4:	c1 e6 18             	shl    $0x18,%esi
  8009f7:	89 d0                	mov    %edx,%eax
  8009f9:	c1 e0 10             	shl    $0x10,%eax
  8009fc:	09 f0                	or     %esi,%eax
  8009fe:	09 d0                	or     %edx,%eax
  800a00:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a02:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a05:	fc                   	cld    
  800a06:	f3 ab                	rep stos %eax,%es:(%edi)
  800a08:	eb 03                	jmp    800a0d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a22:	39 c6                	cmp    %eax,%esi
  800a24:	73 34                	jae    800a5a <memmove+0x46>
  800a26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a29:	39 d0                	cmp    %edx,%eax
  800a2b:	73 2d                	jae    800a5a <memmove+0x46>
		s += n;
		d += n;
  800a2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a30:	f6 c2 03             	test   $0x3,%dl
  800a33:	75 1b                	jne    800a50 <memmove+0x3c>
  800a35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3b:	75 13                	jne    800a50 <memmove+0x3c>
  800a3d:	f6 c1 03             	test   $0x3,%cl
  800a40:	75 0e                	jne    800a50 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a42:	83 ef 04             	sub    $0x4,%edi
  800a45:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a48:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a4b:	fd                   	std    
  800a4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4e:	eb 07                	jmp    800a57 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a50:	4f                   	dec    %edi
  800a51:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a54:	fd                   	std    
  800a55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a57:	fc                   	cld    
  800a58:	eb 20                	jmp    800a7a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a60:	75 13                	jne    800a75 <memmove+0x61>
  800a62:	a8 03                	test   $0x3,%al
  800a64:	75 0f                	jne    800a75 <memmove+0x61>
  800a66:	f6 c1 03             	test   $0x3,%cl
  800a69:	75 0a                	jne    800a75 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a6b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a6e:	89 c7                	mov    %eax,%edi
  800a70:	fc                   	cld    
  800a71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a73:	eb 05                	jmp    800a7a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a75:	89 c7                	mov    %eax,%edi
  800a77:	fc                   	cld    
  800a78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a84:	8b 45 10             	mov    0x10(%ebp),%eax
  800a87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	89 04 24             	mov    %eax,(%esp)
  800a98:	e8 77 ff ff ff       	call   800a14 <memmove>
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aae:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab3:	eb 16                	jmp    800acb <memcmp+0x2c>
		if (*s1 != *s2)
  800ab5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ab8:	42                   	inc    %edx
  800ab9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800abd:	38 c8                	cmp    %cl,%al
  800abf:	74 0a                	je     800acb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ac1:	0f b6 c0             	movzbl %al,%eax
  800ac4:	0f b6 c9             	movzbl %cl,%ecx
  800ac7:	29 c8                	sub    %ecx,%eax
  800ac9:	eb 09                	jmp    800ad4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acb:	39 da                	cmp    %ebx,%edx
  800acd:	75 e6                	jne    800ab5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae2:	89 c2                	mov    %eax,%edx
  800ae4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae7:	eb 05                	jmp    800aee <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae9:	38 08                	cmp    %cl,(%eax)
  800aeb:	74 05                	je     800af2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aed:	40                   	inc    %eax
  800aee:	39 d0                	cmp    %edx,%eax
  800af0:	72 f7                	jb     800ae9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	8b 55 08             	mov    0x8(%ebp),%edx
  800afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b00:	eb 01                	jmp    800b03 <strtol+0xf>
		s++;
  800b02:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b03:	8a 02                	mov    (%edx),%al
  800b05:	3c 20                	cmp    $0x20,%al
  800b07:	74 f9                	je     800b02 <strtol+0xe>
  800b09:	3c 09                	cmp    $0x9,%al
  800b0b:	74 f5                	je     800b02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0d:	3c 2b                	cmp    $0x2b,%al
  800b0f:	75 08                	jne    800b19 <strtol+0x25>
		s++;
  800b11:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b12:	bf 00 00 00 00       	mov    $0x0,%edi
  800b17:	eb 13                	jmp    800b2c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b19:	3c 2d                	cmp    $0x2d,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x33>
		s++, neg = 1;
  800b1d:	8d 52 01             	lea    0x1(%edx),%edx
  800b20:	bf 01 00 00 00       	mov    $0x1,%edi
  800b25:	eb 05                	jmp    800b2c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2c:	85 db                	test   %ebx,%ebx
  800b2e:	74 05                	je     800b35 <strtol+0x41>
  800b30:	83 fb 10             	cmp    $0x10,%ebx
  800b33:	75 28                	jne    800b5d <strtol+0x69>
  800b35:	8a 02                	mov    (%edx),%al
  800b37:	3c 30                	cmp    $0x30,%al
  800b39:	75 10                	jne    800b4b <strtol+0x57>
  800b3b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b3f:	75 0a                	jne    800b4b <strtol+0x57>
		s += 2, base = 16;
  800b41:	83 c2 02             	add    $0x2,%edx
  800b44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b49:	eb 12                	jmp    800b5d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b4b:	85 db                	test   %ebx,%ebx
  800b4d:	75 0e                	jne    800b5d <strtol+0x69>
  800b4f:	3c 30                	cmp    $0x30,%al
  800b51:	75 05                	jne    800b58 <strtol+0x64>
		s++, base = 8;
  800b53:	42                   	inc    %edx
  800b54:	b3 08                	mov    $0x8,%bl
  800b56:	eb 05                	jmp    800b5d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b58:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b62:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b64:	8a 0a                	mov    (%edx),%cl
  800b66:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b69:	80 fb 09             	cmp    $0x9,%bl
  800b6c:	77 08                	ja     800b76 <strtol+0x82>
			dig = *s - '0';
  800b6e:	0f be c9             	movsbl %cl,%ecx
  800b71:	83 e9 30             	sub    $0x30,%ecx
  800b74:	eb 1e                	jmp    800b94 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b76:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b79:	80 fb 19             	cmp    $0x19,%bl
  800b7c:	77 08                	ja     800b86 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b7e:	0f be c9             	movsbl %cl,%ecx
  800b81:	83 e9 57             	sub    $0x57,%ecx
  800b84:	eb 0e                	jmp    800b94 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b86:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b89:	80 fb 19             	cmp    $0x19,%bl
  800b8c:	77 12                	ja     800ba0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b8e:	0f be c9             	movsbl %cl,%ecx
  800b91:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b94:	39 f1                	cmp    %esi,%ecx
  800b96:	7d 0c                	jge    800ba4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b98:	42                   	inc    %edx
  800b99:	0f af c6             	imul   %esi,%eax
  800b9c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b9e:	eb c4                	jmp    800b64 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ba0:	89 c1                	mov    %eax,%ecx
  800ba2:	eb 02                	jmp    800ba6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800baa:	74 05                	je     800bb1 <strtol+0xbd>
		*endptr = (char *) s;
  800bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800baf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bb1:	85 ff                	test   %edi,%edi
  800bb3:	74 04                	je     800bb9 <strtol+0xc5>
  800bb5:	89 c8                	mov    %ecx,%eax
  800bb7:	f7 d8                	neg    %eax
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    
	...

00800bc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	89 c3                	mov    %eax,%ebx
  800bd3:	89 c7                	mov    %eax,%edi
  800bd5:	89 c6                	mov    %eax,%esi
  800bd7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_cgetc>:

int
sys_cgetc(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	89 cb                	mov    %ecx,%ebx
  800c15:	89 cf                	mov    %ecx,%edi
  800c17:	89 ce                	mov    %ecx,%esi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 28                	jle    800c47 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c23:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 08 03 2e 80 	movl   $0x802e03,0x8(%esp)
  800c32:	00 
  800c33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3a:	00 
  800c3b:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  800c42:	e8 a9 1a 00 00       	call   8026f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c47:	83 c4 2c             	add    $0x2c,%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c5f:	89 d1                	mov    %edx,%ecx
  800c61:	89 d3                	mov    %edx,%ebx
  800c63:	89 d7                	mov    %edx,%edi
  800c65:	89 d6                	mov    %edx,%esi
  800c67:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_yield>:

void
sys_yield(void)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	ba 00 00 00 00       	mov    $0x0,%edx
  800c79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	89 d3                	mov    %edx,%ebx
  800c82:	89 d7                	mov    %edx,%edi
  800c84:	89 d6                	mov    %edx,%esi
  800c86:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	be 00 00 00 00       	mov    $0x0,%esi
  800c9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 f7                	mov    %esi,%edi
  800cab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 28                	jle    800cd9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 08 03 2e 80 	movl   $0x802e03,0x8(%esp)
  800cc4:	00 
  800cc5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ccc:	00 
  800ccd:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  800cd4:	e8 17 1a 00 00       	call   8026f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd9:	83 c4 2c             	add    $0x2c,%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800cea:	b8 05 00 00 00       	mov    $0x5,%eax
  800cef:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	7e 28                	jle    800d2c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d08:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d0f:	00 
  800d10:	c7 44 24 08 03 2e 80 	movl   $0x802e03,0x8(%esp)
  800d17:	00 
  800d18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1f:	00 
  800d20:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  800d27:	e8 c4 19 00 00       	call   8026f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d2c:	83 c4 2c             	add    $0x2c,%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d42:	b8 06 00 00 00       	mov    $0x6,%eax
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	89 df                	mov    %ebx,%edi
  800d4f:	89 de                	mov    %ebx,%esi
  800d51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 28                	jle    800d7f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d62:	00 
  800d63:	c7 44 24 08 03 2e 80 	movl   $0x802e03,0x8(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d72:	00 
  800d73:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  800d7a:	e8 71 19 00 00       	call   8026f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d7f:	83 c4 2c             	add    $0x2c,%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d95:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	89 df                	mov    %ebx,%edi
  800da2:	89 de                	mov    %ebx,%esi
  800da4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da6:	85 c0                	test   %eax,%eax
  800da8:	7e 28                	jle    800dd2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800db5:	00 
  800db6:	c7 44 24 08 03 2e 80 	movl   $0x802e03,0x8(%esp)
  800dbd:	00 
  800dbe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc5:	00 
  800dc6:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  800dcd:	e8 1e 19 00 00       	call   8026f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd2:	83 c4 2c             	add    $0x2c,%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 df                	mov    %ebx,%edi
  800df5:	89 de                	mov    %ebx,%esi
  800df7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7e 28                	jle    800e25 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e01:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e08:	00 
  800e09:	c7 44 24 08 03 2e 80 	movl   $0x802e03,0x8(%esp)
  800e10:	00 
  800e11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e18:	00 
  800e19:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  800e20:	e8 cb 18 00 00       	call   8026f0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e25:	83 c4 2c             	add    $0x2c,%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 28                	jle    800e78 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e54:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 08 03 2e 80 	movl   $0x802e03,0x8(%esp)
  800e63:	00 
  800e64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6b:	00 
  800e6c:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  800e73:	e8 78 18 00 00       	call   8026f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e78:	83 c4 2c             	add    $0x2c,%esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e86:	be 00 00 00 00       	mov    $0x0,%esi
  800e8b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e90:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	89 cb                	mov    %ecx,%ebx
  800ebb:	89 cf                	mov    %ecx,%edi
  800ebd:	89 ce                	mov    %ecx,%esi
  800ebf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	7e 28                	jle    800eed <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 08 03 2e 80 	movl   $0x802e03,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  800ee8:	e8 03 18 00 00       	call   8026f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eed:	83 c4 2c             	add    $0x2c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
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
  800efb:	ba 00 00 00 00       	mov    $0x0,%edx
  800f00:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f05:	89 d1                	mov    %edx,%ecx
  800f07:	89 d3                	mov    %edx,%ebx
  800f09:	89 d7                	mov    %edx,%edi
  800f0b:	89 d6                	mov    %edx,%esi
  800f0d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
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
  800f1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f27:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2a:	89 df                	mov    %ebx,%edi
  800f2c:	89 de                	mov    %ebx,%esi
  800f2e:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f40:	b8 10 00 00 00       	mov    $0x10,%eax
  800f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	89 df                	mov    %ebx,%edi
  800f4d:	89 de                	mov    %ebx,%esi
  800f4f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
	...

00800f58 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 24             	sub    $0x24,%esp
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f62:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800f64:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f68:	74 2d                	je     800f97 <pgfault+0x3f>
  800f6a:	89 d8                	mov    %ebx,%eax
  800f6c:	c1 e8 16             	shr    $0x16,%eax
  800f6f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f76:	a8 01                	test   $0x1,%al
  800f78:	74 1d                	je     800f97 <pgfault+0x3f>
  800f7a:	89 d8                	mov    %ebx,%eax
  800f7c:	c1 e8 0c             	shr    $0xc,%eax
  800f7f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f86:	f6 c2 01             	test   $0x1,%dl
  800f89:	74 0c                	je     800f97 <pgfault+0x3f>
  800f8b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f92:	f6 c4 08             	test   $0x8,%ah
  800f95:	75 1c                	jne    800fb3 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  800f97:	c7 44 24 08 30 2e 80 	movl   $0x802e30,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  800fae:	e8 3d 17 00 00       	call   8026f0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  800fb3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800fb9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fd0:	e8 b8 fc ff ff       	call   800c8d <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  800fd5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fdc:	00 
  800fdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fe1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fe8:	e8 91 fa ff ff       	call   800a7e <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  800fed:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ff4:	00 
  800ff5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ff9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801000:	00 
  801001:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801008:	00 
  801009:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801010:	e8 cc fc ff ff       	call   800ce1 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  801015:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80101c:	00 
  80101d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801024:	e8 0b fd ff ff       	call   800d34 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  801029:	83 c4 24             	add    $0x24,%esp
  80102c:	5b                   	pop    %ebx
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
  801035:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801038:	c7 04 24 58 0f 80 00 	movl   $0x800f58,(%esp)
  80103f:	e8 04 17 00 00       	call   802748 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801044:	ba 07 00 00 00       	mov    $0x7,%edx
  801049:	89 d0                	mov    %edx,%eax
  80104b:	cd 30                	int    $0x30
  80104d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801050:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  801052:	85 c0                	test   %eax,%eax
  801054:	79 20                	jns    801076 <fork+0x47>
		panic("sys_exofork: %e", envid);
  801056:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80105a:	c7 44 24 08 7e 2e 80 	movl   $0x802e7e,0x8(%esp)
  801061:	00 
  801062:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801069:	00 
  80106a:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  801071:	e8 7a 16 00 00       	call   8026f0 <_panic>
	if (envid == 0)
  801076:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80107a:	75 25                	jne    8010a1 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80107c:	e8 ce fb ff ff       	call   800c4f <sys_getenvid>
  801081:	25 ff 03 00 00       	and    $0x3ff,%eax
  801086:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80108d:	c1 e0 07             	shl    $0x7,%eax
  801090:	29 d0                	sub    %edx,%eax
  801092:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801097:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80109c:	e9 43 02 00 00       	jmp    8012e4 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  8010a6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010ac:	0f 84 85 01 00 00    	je     801237 <fork+0x208>
  8010b2:	89 d8                	mov    %ebx,%eax
  8010b4:	c1 e8 16             	shr    $0x16,%eax
  8010b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010be:	a8 01                	test   $0x1,%al
  8010c0:	0f 84 5f 01 00 00    	je     801225 <fork+0x1f6>
  8010c6:	89 d8                	mov    %ebx,%eax
  8010c8:	c1 e8 0c             	shr    $0xc,%eax
  8010cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d2:	f6 c2 01             	test   $0x1,%dl
  8010d5:	0f 84 4a 01 00 00    	je     801225 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  8010db:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  8010dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e4:	f6 c6 04             	test   $0x4,%dh
  8010e7:	74 50                	je     801139 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  8010e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010fd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801101:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801105:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80110c:	e8 d0 fb ff ff       	call   800ce1 <sys_page_map>
  801111:	85 c0                	test   %eax,%eax
  801113:	0f 89 0c 01 00 00    	jns    801225 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  801119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111d:	c7 44 24 08 8e 2e 80 	movl   $0x802e8e,0x8(%esp)
  801124:	00 
  801125:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  80112c:	00 
  80112d:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  801134:	e8 b7 15 00 00       	call   8026f0 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  801139:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801140:	f6 c2 02             	test   $0x2,%dl
  801143:	75 10                	jne    801155 <fork+0x126>
  801145:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114c:	f6 c4 08             	test   $0x8,%ah
  80114f:	0f 84 8c 00 00 00    	je     8011e1 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  801155:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80115c:	00 
  80115d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801161:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801165:	89 74 24 04          	mov    %esi,0x4(%esp)
  801169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801170:	e8 6c fb ff ff       	call   800ce1 <sys_page_map>
  801175:	85 c0                	test   %eax,%eax
  801177:	79 20                	jns    801199 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117d:	c7 44 24 08 8e 2e 80 	movl   $0x802e8e,0x8(%esp)
  801184:	00 
  801185:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80118c:	00 
  80118d:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  801194:	e8 57 15 00 00       	call   8026f0 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801199:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011a0:	00 
  8011a1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011ac:	00 
  8011ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b8:	e8 24 fb ff ff       	call   800ce1 <sys_page_map>
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	79 64                	jns    801225 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8011c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c5:	c7 44 24 08 8e 2e 80 	movl   $0x802e8e,0x8(%esp)
  8011cc:	00 
  8011cd:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  8011dc:	e8 0f 15 00 00       	call   8026f0 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  8011e1:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011e8:	00 
  8011e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011ed:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011fc:	e8 e0 fa ff ff       	call   800ce1 <sys_page_map>
  801201:	85 c0                	test   %eax,%eax
  801203:	79 20                	jns    801225 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801205:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801209:	c7 44 24 08 8e 2e 80 	movl   $0x802e8e,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  801220:	e8 cb 14 00 00       	call   8026f0 <_panic>
  801225:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  80122b:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801231:	0f 85 6f fe ff ff    	jne    8010a6 <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  801237:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80123e:	00 
  80123f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801246:	ee 
  801247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80124a:	89 04 24             	mov    %eax,(%esp)
  80124d:	e8 3b fa ff ff       	call   800c8d <sys_page_alloc>
  801252:	85 c0                	test   %eax,%eax
  801254:	79 20                	jns    801276 <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  801256:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125a:	c7 44 24 08 a0 2e 80 	movl   $0x802ea0,0x8(%esp)
  801261:	00 
  801262:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801269:	00 
  80126a:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  801271:	e8 7a 14 00 00       	call   8026f0 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801276:	c7 44 24 04 94 27 80 	movl   $0x802794,0x4(%esp)
  80127d:	00 
  80127e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801281:	89 04 24             	mov    %eax,(%esp)
  801284:	e8 a4 fb ff ff       	call   800e2d <sys_env_set_pgfault_upcall>
  801289:	85 c0                	test   %eax,%eax
  80128b:	79 20                	jns    8012ad <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  80128d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801291:	c7 44 24 08 54 2e 80 	movl   $0x802e54,0x8(%esp)
  801298:	00 
  801299:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  8012a0:	00 
  8012a1:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  8012a8:	e8 43 14 00 00       	call   8026f0 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8012ad:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012b4:	00 
  8012b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b8:	89 04 24             	mov    %eax,(%esp)
  8012bb:	e8 c7 fa ff ff       	call   800d87 <sys_env_set_status>
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	79 20                	jns    8012e4 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  8012c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c8:	c7 44 24 08 b3 2e 80 	movl   $0x802eb3,0x8(%esp)
  8012cf:	00 
  8012d0:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8012d7:	00 
  8012d8:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  8012df:	e8 0c 14 00 00       	call   8026f0 <_panic>

	return envid;
	// panic("fork not implemented");
}
  8012e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e7:	83 c4 3c             	add    $0x3c,%esp
  8012ea:	5b                   	pop    %ebx
  8012eb:	5e                   	pop    %esi
  8012ec:	5f                   	pop    %edi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <sfork>:

// Challenge!
int
sfork(void)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012f5:	c7 44 24 08 ca 2e 80 	movl   $0x802eca,0x8(%esp)
  8012fc:	00 
  8012fd:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801304:	00 
  801305:	c7 04 24 73 2e 80 00 	movl   $0x802e73,(%esp)
  80130c:	e8 df 13 00 00       	call   8026f0 <_panic>
  801311:	00 00                	add    %al,(%eax)
	...

00801314 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	56                   	push   %esi
  801318:	53                   	push   %ebx
  801319:	83 ec 10             	sub    $0x10,%esp
  80131c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80131f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801322:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  801325:	85 c0                	test   %eax,%eax
  801327:	74 0a                	je     801333 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  801329:	89 04 24             	mov    %eax,(%esp)
  80132c:	e8 72 fb ff ff       	call   800ea3 <sys_ipc_recv>
  801331:	eb 0c                	jmp    80133f <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  801333:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80133a:	e8 64 fb ff ff       	call   800ea3 <sys_ipc_recv>
	}
	if (r < 0)
  80133f:	85 c0                	test   %eax,%eax
  801341:	79 16                	jns    801359 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  801343:	85 db                	test   %ebx,%ebx
  801345:	74 06                	je     80134d <ipc_recv+0x39>
  801347:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  80134d:	85 f6                	test   %esi,%esi
  80134f:	74 2c                	je     80137d <ipc_recv+0x69>
  801351:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801357:	eb 24                	jmp    80137d <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  801359:	85 db                	test   %ebx,%ebx
  80135b:	74 0a                	je     801367 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  80135d:	a1 08 50 80 00       	mov    0x805008,%eax
  801362:	8b 40 74             	mov    0x74(%eax),%eax
  801365:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  801367:	85 f6                	test   %esi,%esi
  801369:	74 0a                	je     801375 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80136b:	a1 08 50 80 00       	mov    0x805008,%eax
  801370:	8b 40 78             	mov    0x78(%eax),%eax
  801373:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  801375:	a1 08 50 80 00       	mov    0x805008,%eax
  80137a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	5b                   	pop    %ebx
  801381:	5e                   	pop    %esi
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	57                   	push   %edi
  801388:	56                   	push   %esi
  801389:	53                   	push   %ebx
  80138a:	83 ec 1c             	sub    $0x1c,%esp
  80138d:	8b 75 08             	mov    0x8(%ebp),%esi
  801390:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801393:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  801396:	85 db                	test   %ebx,%ebx
  801398:	74 19                	je     8013b3 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80139a:	8b 45 14             	mov    0x14(%ebp),%eax
  80139d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013a9:	89 34 24             	mov    %esi,(%esp)
  8013ac:	e8 cf fa ff ff       	call   800e80 <sys_ipc_try_send>
  8013b1:	eb 1c                	jmp    8013cf <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8013b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013ba:	00 
  8013bb:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8013c2:	ee 
  8013c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013c7:	89 34 24             	mov    %esi,(%esp)
  8013ca:	e8 b1 fa ff ff       	call   800e80 <sys_ipc_try_send>
		}
		if (r == 0)
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	74 2c                	je     8013ff <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8013d3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013d6:	74 20                	je     8013f8 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8013d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013dc:	c7 44 24 08 e0 2e 80 	movl   $0x802ee0,0x8(%esp)
  8013e3:	00 
  8013e4:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8013eb:	00 
  8013ec:	c7 04 24 f3 2e 80 00 	movl   $0x802ef3,(%esp)
  8013f3:	e8 f8 12 00 00       	call   8026f0 <_panic>
		}
		sys_yield();
  8013f8:	e8 71 f8 ff ff       	call   800c6e <sys_yield>
	}
  8013fd:	eb 97                	jmp    801396 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8013ff:	83 c4 1c             	add    $0x1c,%esp
  801402:	5b                   	pop    %ebx
  801403:	5e                   	pop    %esi
  801404:	5f                   	pop    %edi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80140e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801413:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	c1 e2 07             	shl    $0x7,%edx
  80141f:	29 ca                	sub    %ecx,%edx
  801421:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801427:	8b 52 50             	mov    0x50(%edx),%edx
  80142a:	39 da                	cmp    %ebx,%edx
  80142c:	75 0f                	jne    80143d <ipc_find_env+0x36>
			return envs[i].env_id;
  80142e:	c1 e0 07             	shl    $0x7,%eax
  801431:	29 c8                	sub    %ecx,%eax
  801433:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801438:	8b 40 40             	mov    0x40(%eax),%eax
  80143b:	eb 0c                	jmp    801449 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80143d:	40                   	inc    %eax
  80143e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801443:	75 ce                	jne    801413 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801445:	66 b8 00 00          	mov    $0x0,%ax
}
  801449:	5b                   	pop    %ebx
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80144f:	8b 45 08             	mov    0x8(%ebp),%eax
  801452:	05 00 00 00 30       	add    $0x30000000,%eax
  801457:	c1 e8 0c             	shr    $0xc,%eax
}
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801462:	8b 45 08             	mov    0x8(%ebp),%eax
  801465:	89 04 24             	mov    %eax,(%esp)
  801468:	e8 df ff ff ff       	call   80144c <fd2num>
  80146d:	c1 e0 0c             	shl    $0xc,%eax
  801470:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	53                   	push   %ebx
  80147b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80147e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801483:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801485:	89 c2                	mov    %eax,%edx
  801487:	c1 ea 16             	shr    $0x16,%edx
  80148a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801491:	f6 c2 01             	test   $0x1,%dl
  801494:	74 11                	je     8014a7 <fd_alloc+0x30>
  801496:	89 c2                	mov    %eax,%edx
  801498:	c1 ea 0c             	shr    $0xc,%edx
  80149b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a2:	f6 c2 01             	test   $0x1,%dl
  8014a5:	75 09                	jne    8014b0 <fd_alloc+0x39>
			*fd_store = fd;
  8014a7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ae:	eb 17                	jmp    8014c7 <fd_alloc+0x50>
  8014b0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014ba:	75 c7                	jne    801483 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014c2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014c7:	5b                   	pop    %ebx
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014d0:	83 f8 1f             	cmp    $0x1f,%eax
  8014d3:	77 36                	ja     80150b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014d5:	c1 e0 0c             	shl    $0xc,%eax
  8014d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	c1 ea 16             	shr    $0x16,%edx
  8014e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e9:	f6 c2 01             	test   $0x1,%dl
  8014ec:	74 24                	je     801512 <fd_lookup+0x48>
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	c1 ea 0c             	shr    $0xc,%edx
  8014f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014fa:	f6 c2 01             	test   $0x1,%dl
  8014fd:	74 1a                	je     801519 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801502:	89 02                	mov    %eax,(%edx)
	return 0;
  801504:	b8 00 00 00 00       	mov    $0x0,%eax
  801509:	eb 13                	jmp    80151e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80150b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801510:	eb 0c                	jmp    80151e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801512:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801517:	eb 05                	jmp    80151e <fd_lookup+0x54>
  801519:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	53                   	push   %ebx
  801524:	83 ec 14             	sub    $0x14,%esp
  801527:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80152d:	ba 00 00 00 00       	mov    $0x0,%edx
  801532:	eb 0e                	jmp    801542 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801534:	39 08                	cmp    %ecx,(%eax)
  801536:	75 09                	jne    801541 <dev_lookup+0x21>
			*dev = devtab[i];
  801538:	89 03                	mov    %eax,(%ebx)
			return 0;
  80153a:	b8 00 00 00 00       	mov    $0x0,%eax
  80153f:	eb 33                	jmp    801574 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801541:	42                   	inc    %edx
  801542:	8b 04 95 7c 2f 80 00 	mov    0x802f7c(,%edx,4),%eax
  801549:	85 c0                	test   %eax,%eax
  80154b:	75 e7                	jne    801534 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80154d:	a1 08 50 80 00       	mov    0x805008,%eax
  801552:	8b 40 48             	mov    0x48(%eax),%eax
  801555:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155d:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  801564:	e8 87 ed ff ff       	call   8002f0 <cprintf>
	*dev = 0;
  801569:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80156f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801574:	83 c4 14             	add    $0x14,%esp
  801577:	5b                   	pop    %ebx
  801578:	5d                   	pop    %ebp
  801579:	c3                   	ret    

0080157a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	56                   	push   %esi
  80157e:	53                   	push   %ebx
  80157f:	83 ec 30             	sub    $0x30,%esp
  801582:	8b 75 08             	mov    0x8(%ebp),%esi
  801585:	8a 45 0c             	mov    0xc(%ebp),%al
  801588:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80158b:	89 34 24             	mov    %esi,(%esp)
  80158e:	e8 b9 fe ff ff       	call   80144c <fd2num>
  801593:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801596:	89 54 24 04          	mov    %edx,0x4(%esp)
  80159a:	89 04 24             	mov    %eax,(%esp)
  80159d:	e8 28 ff ff ff       	call   8014ca <fd_lookup>
  8015a2:	89 c3                	mov    %eax,%ebx
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 05                	js     8015ad <fd_close+0x33>
	    || fd != fd2)
  8015a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015ab:	74 0d                	je     8015ba <fd_close+0x40>
		return (must_exist ? r : 0);
  8015ad:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015b1:	75 46                	jne    8015f9 <fd_close+0x7f>
  8015b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b8:	eb 3f                	jmp    8015f9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	8b 06                	mov    (%esi),%eax
  8015c3:	89 04 24             	mov    %eax,(%esp)
  8015c6:	e8 55 ff ff ff       	call   801520 <dev_lookup>
  8015cb:	89 c3                	mov    %eax,%ebx
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 18                	js     8015e9 <fd_close+0x6f>
		if (dev->dev_close)
  8015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d4:	8b 40 10             	mov    0x10(%eax),%eax
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	74 09                	je     8015e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015db:	89 34 24             	mov    %esi,(%esp)
  8015de:	ff d0                	call   *%eax
  8015e0:	89 c3                	mov    %eax,%ebx
  8015e2:	eb 05                	jmp    8015e9 <fd_close+0x6f>
		else
			r = 0;
  8015e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f4:	e8 3b f7 ff ff       	call   800d34 <sys_page_unmap>
	return r;
}
  8015f9:	89 d8                	mov    %ebx,%eax
  8015fb:	83 c4 30             	add    $0x30,%esp
  8015fe:	5b                   	pop    %ebx
  8015ff:	5e                   	pop    %esi
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160f:	8b 45 08             	mov    0x8(%ebp),%eax
  801612:	89 04 24             	mov    %eax,(%esp)
  801615:	e8 b0 fe ff ff       	call   8014ca <fd_lookup>
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 13                	js     801631 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80161e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801625:	00 
  801626:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801629:	89 04 24             	mov    %eax,(%esp)
  80162c:	e8 49 ff ff ff       	call   80157a <fd_close>
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <close_all>:

void
close_all(void)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	53                   	push   %ebx
  801637:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80163f:	89 1c 24             	mov    %ebx,(%esp)
  801642:	e8 bb ff ff ff       	call   801602 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801647:	43                   	inc    %ebx
  801648:	83 fb 20             	cmp    $0x20,%ebx
  80164b:	75 f2                	jne    80163f <close_all+0xc>
		close(i);
}
  80164d:	83 c4 14             	add    $0x14,%esp
  801650:	5b                   	pop    %ebx
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	57                   	push   %edi
  801657:	56                   	push   %esi
  801658:	53                   	push   %ebx
  801659:	83 ec 4c             	sub    $0x4c,%esp
  80165c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80165f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801662:	89 44 24 04          	mov    %eax,0x4(%esp)
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	89 04 24             	mov    %eax,(%esp)
  80166c:	e8 59 fe ff ff       	call   8014ca <fd_lookup>
  801671:	89 c3                	mov    %eax,%ebx
  801673:	85 c0                	test   %eax,%eax
  801675:	0f 88 e3 00 00 00    	js     80175e <dup+0x10b>
		return r;
	close(newfdnum);
  80167b:	89 3c 24             	mov    %edi,(%esp)
  80167e:	e8 7f ff ff ff       	call   801602 <close>

	newfd = INDEX2FD(newfdnum);
  801683:	89 fe                	mov    %edi,%esi
  801685:	c1 e6 0c             	shl    $0xc,%esi
  801688:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80168e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801691:	89 04 24             	mov    %eax,(%esp)
  801694:	e8 c3 fd ff ff       	call   80145c <fd2data>
  801699:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80169b:	89 34 24             	mov    %esi,(%esp)
  80169e:	e8 b9 fd ff ff       	call   80145c <fd2data>
  8016a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	c1 e8 16             	shr    $0x16,%eax
  8016ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b2:	a8 01                	test   $0x1,%al
  8016b4:	74 46                	je     8016fc <dup+0xa9>
  8016b6:	89 d8                	mov    %ebx,%eax
  8016b8:	c1 e8 0c             	shr    $0xc,%eax
  8016bb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c2:	f6 c2 01             	test   $0x1,%dl
  8016c5:	74 35                	je     8016fc <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8016d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016e5:	00 
  8016e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f1:	e8 eb f5 ff ff       	call   800ce1 <sys_page_map>
  8016f6:	89 c3                	mov    %eax,%ebx
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 3b                	js     801737 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ff:	89 c2                	mov    %eax,%edx
  801701:	c1 ea 0c             	shr    $0xc,%edx
  801704:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80170b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801711:	89 54 24 10          	mov    %edx,0x10(%esp)
  801715:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801719:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801720:	00 
  801721:	89 44 24 04          	mov    %eax,0x4(%esp)
  801725:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172c:	e8 b0 f5 ff ff       	call   800ce1 <sys_page_map>
  801731:	89 c3                	mov    %eax,%ebx
  801733:	85 c0                	test   %eax,%eax
  801735:	79 25                	jns    80175c <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801737:	89 74 24 04          	mov    %esi,0x4(%esp)
  80173b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801742:	e8 ed f5 ff ff       	call   800d34 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801747:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80174a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801755:	e8 da f5 ff ff       	call   800d34 <sys_page_unmap>
	return r;
  80175a:	eb 02                	jmp    80175e <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80175c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80175e:	89 d8                	mov    %ebx,%eax
  801760:	83 c4 4c             	add    $0x4c,%esp
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	5f                   	pop    %edi
  801766:	5d                   	pop    %ebp
  801767:	c3                   	ret    

00801768 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	53                   	push   %ebx
  80176c:	83 ec 24             	sub    $0x24,%esp
  80176f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801772:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801775:	89 44 24 04          	mov    %eax,0x4(%esp)
  801779:	89 1c 24             	mov    %ebx,(%esp)
  80177c:	e8 49 fd ff ff       	call   8014ca <fd_lookup>
  801781:	85 c0                	test   %eax,%eax
  801783:	78 6d                	js     8017f2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801785:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178f:	8b 00                	mov    (%eax),%eax
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 87 fd ff ff       	call   801520 <dev_lookup>
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 55                	js     8017f2 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	8b 50 08             	mov    0x8(%eax),%edx
  8017a3:	83 e2 03             	and    $0x3,%edx
  8017a6:	83 fa 01             	cmp    $0x1,%edx
  8017a9:	75 23                	jne    8017ce <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ab:	a1 08 50 80 00       	mov    0x805008,%eax
  8017b0:	8b 40 48             	mov    0x48(%eax),%eax
  8017b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bb:	c7 04 24 41 2f 80 00 	movl   $0x802f41,(%esp)
  8017c2:	e8 29 eb ff ff       	call   8002f0 <cprintf>
		return -E_INVAL;
  8017c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017cc:	eb 24                	jmp    8017f2 <read+0x8a>
	}
	if (!dev->dev_read)
  8017ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d1:	8b 52 08             	mov    0x8(%edx),%edx
  8017d4:	85 d2                	test   %edx,%edx
  8017d6:	74 15                	je     8017ed <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017e6:	89 04 24             	mov    %eax,(%esp)
  8017e9:	ff d2                	call   *%edx
  8017eb:	eb 05                	jmp    8017f2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017f2:	83 c4 24             	add    $0x24,%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	57                   	push   %edi
  8017fc:	56                   	push   %esi
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 1c             	sub    $0x1c,%esp
  801801:	8b 7d 08             	mov    0x8(%ebp),%edi
  801804:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801807:	bb 00 00 00 00       	mov    $0x0,%ebx
  80180c:	eb 23                	jmp    801831 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80180e:	89 f0                	mov    %esi,%eax
  801810:	29 d8                	sub    %ebx,%eax
  801812:	89 44 24 08          	mov    %eax,0x8(%esp)
  801816:	8b 45 0c             	mov    0xc(%ebp),%eax
  801819:	01 d8                	add    %ebx,%eax
  80181b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181f:	89 3c 24             	mov    %edi,(%esp)
  801822:	e8 41 ff ff ff       	call   801768 <read>
		if (m < 0)
  801827:	85 c0                	test   %eax,%eax
  801829:	78 10                	js     80183b <readn+0x43>
			return m;
		if (m == 0)
  80182b:	85 c0                	test   %eax,%eax
  80182d:	74 0a                	je     801839 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80182f:	01 c3                	add    %eax,%ebx
  801831:	39 f3                	cmp    %esi,%ebx
  801833:	72 d9                	jb     80180e <readn+0x16>
  801835:	89 d8                	mov    %ebx,%eax
  801837:	eb 02                	jmp    80183b <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801839:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80183b:	83 c4 1c             	add    $0x1c,%esp
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5f                   	pop    %edi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 24             	sub    $0x24,%esp
  80184a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801850:	89 44 24 04          	mov    %eax,0x4(%esp)
  801854:	89 1c 24             	mov    %ebx,(%esp)
  801857:	e8 6e fc ff ff       	call   8014ca <fd_lookup>
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 68                	js     8018c8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801863:	89 44 24 04          	mov    %eax,0x4(%esp)
  801867:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186a:	8b 00                	mov    (%eax),%eax
  80186c:	89 04 24             	mov    %eax,(%esp)
  80186f:	e8 ac fc ff ff       	call   801520 <dev_lookup>
  801874:	85 c0                	test   %eax,%eax
  801876:	78 50                	js     8018c8 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801878:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80187f:	75 23                	jne    8018a4 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801881:	a1 08 50 80 00       	mov    0x805008,%eax
  801886:	8b 40 48             	mov    0x48(%eax),%eax
  801889:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  801898:	e8 53 ea ff ff       	call   8002f0 <cprintf>
		return -E_INVAL;
  80189d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018a2:	eb 24                	jmp    8018c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8018aa:	85 d2                	test   %edx,%edx
  8018ac:	74 15                	je     8018c3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018bc:	89 04 24             	mov    %eax,(%esp)
  8018bf:	ff d2                	call   *%edx
  8018c1:	eb 05                	jmp    8018c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018c8:	83 c4 24             	add    $0x24,%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5d                   	pop    %ebp
  8018cd:	c3                   	ret    

008018ce <seek>:

int
seek(int fdnum, off_t offset)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018d4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	89 04 24             	mov    %eax,(%esp)
  8018e1:	e8 e4 fb ff ff       	call   8014ca <fd_lookup>
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 0e                	js     8018f8 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 24             	sub    $0x24,%esp
  801901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801904:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190b:	89 1c 24             	mov    %ebx,(%esp)
  80190e:	e8 b7 fb ff ff       	call   8014ca <fd_lookup>
  801913:	85 c0                	test   %eax,%eax
  801915:	78 61                	js     801978 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801921:	8b 00                	mov    (%eax),%eax
  801923:	89 04 24             	mov    %eax,(%esp)
  801926:	e8 f5 fb ff ff       	call   801520 <dev_lookup>
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 49                	js     801978 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80192f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801932:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801936:	75 23                	jne    80195b <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801938:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80193d:	8b 40 48             	mov    0x48(%eax),%eax
  801940:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801944:	89 44 24 04          	mov    %eax,0x4(%esp)
  801948:	c7 04 24 20 2f 80 00 	movl   $0x802f20,(%esp)
  80194f:	e8 9c e9 ff ff       	call   8002f0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801954:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801959:	eb 1d                	jmp    801978 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80195b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80195e:	8b 52 18             	mov    0x18(%edx),%edx
  801961:	85 d2                	test   %edx,%edx
  801963:	74 0e                	je     801973 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801965:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801968:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80196c:	89 04 24             	mov    %eax,(%esp)
  80196f:	ff d2                	call   *%edx
  801971:	eb 05                	jmp    801978 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801973:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801978:	83 c4 24             	add    $0x24,%esp
  80197b:	5b                   	pop    %ebx
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	53                   	push   %ebx
  801982:	83 ec 24             	sub    $0x24,%esp
  801985:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801988:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198f:	8b 45 08             	mov    0x8(%ebp),%eax
  801992:	89 04 24             	mov    %eax,(%esp)
  801995:	e8 30 fb ff ff       	call   8014ca <fd_lookup>
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 52                	js     8019f0 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a8:	8b 00                	mov    (%eax),%eax
  8019aa:	89 04 24             	mov    %eax,(%esp)
  8019ad:	e8 6e fb ff ff       	call   801520 <dev_lookup>
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	78 3a                	js     8019f0 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019bd:	74 2c                	je     8019eb <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019bf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019c2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019c9:	00 00 00 
	stat->st_isdir = 0;
  8019cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d3:	00 00 00 
	stat->st_dev = dev;
  8019d6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019e3:	89 14 24             	mov    %edx,(%esp)
  8019e6:	ff 50 14             	call   *0x14(%eax)
  8019e9:	eb 05                	jmp    8019f0 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019f0:	83 c4 24             	add    $0x24,%esp
  8019f3:	5b                   	pop    %ebx
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	56                   	push   %esi
  8019fa:	53                   	push   %ebx
  8019fb:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a05:	00 
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	89 04 24             	mov    %eax,(%esp)
  801a0c:	e8 2a 02 00 00       	call   801c3b <open>
  801a11:	89 c3                	mov    %eax,%ebx
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 1b                	js     801a32 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1e:	89 1c 24             	mov    %ebx,(%esp)
  801a21:	e8 58 ff ff ff       	call   80197e <fstat>
  801a26:	89 c6                	mov    %eax,%esi
	close(fd);
  801a28:	89 1c 24             	mov    %ebx,(%esp)
  801a2b:	e8 d2 fb ff ff       	call   801602 <close>
	return r;
  801a30:	89 f3                	mov    %esi,%ebx
}
  801a32:	89 d8                	mov    %ebx,%eax
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	5b                   	pop    %ebx
  801a38:	5e                   	pop    %esi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    
	...

00801a3c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	83 ec 10             	sub    $0x10,%esp
  801a44:	89 c3                	mov    %eax,%ebx
  801a46:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a48:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a4f:	75 11                	jne    801a62 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a58:	e8 aa f9 ff ff       	call   801407 <ipc_find_env>
  801a5d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a62:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a69:	00 
  801a6a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a71:	00 
  801a72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a76:	a1 00 50 80 00       	mov    0x805000,%eax
  801a7b:	89 04 24             	mov    %eax,(%esp)
  801a7e:	e8 01 f9 ff ff       	call   801384 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a8a:	00 
  801a8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a96:	e8 79 f8 ff ff       	call   801314 <ipc_recv>
}
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801aab:	8b 40 0c             	mov    0xc(%eax),%eax
  801aae:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab6:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801abb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac0:	b8 02 00 00 00       	mov    $0x2,%eax
  801ac5:	e8 72 ff ff ff       	call   801a3c <fsipc>
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad8:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801add:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae2:	b8 06 00 00 00       	mov    $0x6,%eax
  801ae7:	e8 50 ff ff ff       	call   801a3c <fsipc>
}
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	53                   	push   %ebx
  801af2:	83 ec 14             	sub    $0x14,%esp
  801af5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	8b 40 0c             	mov    0xc(%eax),%eax
  801afe:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b03:	ba 00 00 00 00       	mov    $0x0,%edx
  801b08:	b8 05 00 00 00       	mov    $0x5,%eax
  801b0d:	e8 2a ff ff ff       	call   801a3c <fsipc>
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 2b                	js     801b41 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b16:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b1d:	00 
  801b1e:	89 1c 24             	mov    %ebx,(%esp)
  801b21:	e8 75 ed ff ff       	call   80089b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b26:	a1 80 60 80 00       	mov    0x806080,%eax
  801b2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b31:	a1 84 60 80 00       	mov    0x806084,%eax
  801b36:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b41:	83 c4 14             	add    $0x14,%esp
  801b44:	5b                   	pop    %ebx
  801b45:	5d                   	pop    %ebp
  801b46:	c3                   	ret    

00801b47 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	83 ec 18             	sub    $0x18,%esp
  801b4d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b50:	8b 55 08             	mov    0x8(%ebp),%edx
  801b53:	8b 52 0c             	mov    0xc(%edx),%edx
  801b56:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b5c:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801b61:	89 c2                	mov    %eax,%edx
  801b63:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b68:	76 05                	jbe    801b6f <devfile_write+0x28>
  801b6a:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801b6f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7a:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801b81:	e8 f8 ee ff ff       	call   800a7e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801b86:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8b:	b8 04 00 00 00       	mov    $0x4,%eax
  801b90:	e8 a7 fe ff ff       	call   801a3c <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801b95:	c9                   	leave  
  801b96:	c3                   	ret    

00801b97 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 10             	sub    $0x10,%esp
  801b9f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba8:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bad:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb8:	b8 03 00 00 00       	mov    $0x3,%eax
  801bbd:	e8 7a fe ff ff       	call   801a3c <fsipc>
  801bc2:	89 c3                	mov    %eax,%ebx
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 6a                	js     801c32 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bc8:	39 c6                	cmp    %eax,%esi
  801bca:	73 24                	jae    801bf0 <devfile_read+0x59>
  801bcc:	c7 44 24 0c 90 2f 80 	movl   $0x802f90,0xc(%esp)
  801bd3:	00 
  801bd4:	c7 44 24 08 97 2f 80 	movl   $0x802f97,0x8(%esp)
  801bdb:	00 
  801bdc:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801be3:	00 
  801be4:	c7 04 24 ac 2f 80 00 	movl   $0x802fac,(%esp)
  801beb:	e8 00 0b 00 00       	call   8026f0 <_panic>
	assert(r <= PGSIZE);
  801bf0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bf5:	7e 24                	jle    801c1b <devfile_read+0x84>
  801bf7:	c7 44 24 0c b7 2f 80 	movl   $0x802fb7,0xc(%esp)
  801bfe:	00 
  801bff:	c7 44 24 08 97 2f 80 	movl   $0x802f97,0x8(%esp)
  801c06:	00 
  801c07:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c0e:	00 
  801c0f:	c7 04 24 ac 2f 80 00 	movl   $0x802fac,(%esp)
  801c16:	e8 d5 0a 00 00       	call   8026f0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c1f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c26:	00 
  801c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2a:	89 04 24             	mov    %eax,(%esp)
  801c2d:	e8 e2 ed ff ff       	call   800a14 <memmove>
	return r;
}
  801c32:	89 d8                	mov    %ebx,%eax
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	5b                   	pop    %ebx
  801c38:	5e                   	pop    %esi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	56                   	push   %esi
  801c3f:	53                   	push   %ebx
  801c40:	83 ec 20             	sub    $0x20,%esp
  801c43:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c46:	89 34 24             	mov    %esi,(%esp)
  801c49:	e8 1a ec ff ff       	call   800868 <strlen>
  801c4e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c53:	7f 60                	jg     801cb5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c58:	89 04 24             	mov    %eax,(%esp)
  801c5b:	e8 17 f8 ff ff       	call   801477 <fd_alloc>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	85 c0                	test   %eax,%eax
  801c64:	78 54                	js     801cba <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6a:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801c71:	e8 25 ec ff ff       	call   80089b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c79:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c81:	b8 01 00 00 00       	mov    $0x1,%eax
  801c86:	e8 b1 fd ff ff       	call   801a3c <fsipc>
  801c8b:	89 c3                	mov    %eax,%ebx
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	79 15                	jns    801ca6 <open+0x6b>
		fd_close(fd, 0);
  801c91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c98:	00 
  801c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9c:	89 04 24             	mov    %eax,(%esp)
  801c9f:	e8 d6 f8 ff ff       	call   80157a <fd_close>
		return r;
  801ca4:	eb 14                	jmp    801cba <open+0x7f>
	}

	return fd2num(fd);
  801ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca9:	89 04 24             	mov    %eax,(%esp)
  801cac:	e8 9b f7 ff ff       	call   80144c <fd2num>
  801cb1:	89 c3                	mov    %eax,%ebx
  801cb3:	eb 05                	jmp    801cba <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cb5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801cba:	89 d8                	mov    %ebx,%eax
  801cbc:	83 c4 20             	add    $0x20,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    

00801cc3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cce:	b8 08 00 00 00       	mov    $0x8,%eax
  801cd3:	e8 64 fd ff ff       	call   801a3c <fsipc>
}
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    
	...

00801cdc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ce2:	c7 44 24 04 c3 2f 80 	movl   $0x802fc3,0x4(%esp)
  801ce9:	00 
  801cea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ced:	89 04 24             	mov    %eax,(%esp)
  801cf0:	e8 a6 eb ff ff       	call   80089b <strcpy>
	return 0;
}
  801cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfa:	c9                   	leave  
  801cfb:	c3                   	ret    

00801cfc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	53                   	push   %ebx
  801d00:	83 ec 14             	sub    $0x14,%esp
  801d03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d06:	89 1c 24             	mov    %ebx,(%esp)
  801d09:	e8 ae 0a 00 00       	call   8027bc <pageref>
  801d0e:	83 f8 01             	cmp    $0x1,%eax
  801d11:	75 0d                	jne    801d20 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801d13:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d16:	89 04 24             	mov    %eax,(%esp)
  801d19:	e8 1f 03 00 00       	call   80203d <nsipc_close>
  801d1e:	eb 05                	jmp    801d25 <devsock_close+0x29>
	else
		return 0;
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d25:	83 c4 14             	add    $0x14,%esp
  801d28:	5b                   	pop    %ebx
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d38:	00 
  801d39:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d4d:	89 04 24             	mov    %eax,(%esp)
  801d50:	e8 e3 03 00 00       	call   802138 <nsipc_send>
}
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d5d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d64:	00 
  801d65:	8b 45 10             	mov    0x10(%ebp),%eax
  801d68:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d73:	8b 45 08             	mov    0x8(%ebp),%eax
  801d76:	8b 40 0c             	mov    0xc(%eax),%eax
  801d79:	89 04 24             	mov    %eax,(%esp)
  801d7c:	e8 37 03 00 00       	call   8020b8 <nsipc_recv>
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	83 ec 20             	sub    $0x20,%esp
  801d8b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d90:	89 04 24             	mov    %eax,(%esp)
  801d93:	e8 df f6 ff ff       	call   801477 <fd_alloc>
  801d98:	89 c3                	mov    %eax,%ebx
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 21                	js     801dbf <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d9e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801da5:	00 
  801da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db4:	e8 d4 ee ff ff       	call   800c8d <sys_page_alloc>
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	79 0a                	jns    801dc9 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801dbf:	89 34 24             	mov    %esi,(%esp)
  801dc2:	e8 76 02 00 00       	call   80203d <nsipc_close>
		return r;
  801dc7:	eb 22                	jmp    801deb <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801dc9:	8b 15 28 40 80 00    	mov    0x804028,%edx
  801dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801dde:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801de1:	89 04 24             	mov    %eax,(%esp)
  801de4:	e8 63 f6 ff ff       	call   80144c <fd2num>
  801de9:	89 c3                	mov    %eax,%ebx
}
  801deb:	89 d8                	mov    %ebx,%eax
  801ded:	83 c4 20             	add    $0x20,%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    

00801df4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801dfa:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801dfd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e01:	89 04 24             	mov    %eax,(%esp)
  801e04:	e8 c1 f6 ff ff       	call   8014ca <fd_lookup>
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 17                	js     801e24 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e10:	8b 15 28 40 80 00    	mov    0x804028,%edx
  801e16:	39 10                	cmp    %edx,(%eax)
  801e18:	75 05                	jne    801e1f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e1a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e1d:	eb 05                	jmp    801e24 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e1f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    

00801e26 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2f:	e8 c0 ff ff ff       	call   801df4 <fd2sockid>
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 1f                	js     801e57 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e38:	8b 55 10             	mov    0x10(%ebp),%edx
  801e3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e42:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e46:	89 04 24             	mov    %eax,(%esp)
  801e49:	e8 38 01 00 00       	call   801f86 <nsipc_accept>
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 05                	js     801e57 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801e52:	e8 2c ff ff ff       	call   801d83 <alloc_sockfd>
}
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e62:	e8 8d ff ff ff       	call   801df4 <fd2sockid>
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 16                	js     801e81 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801e6b:	8b 55 10             	mov    0x10(%ebp),%edx
  801e6e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e72:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e75:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e79:	89 04 24             	mov    %eax,(%esp)
  801e7c:	e8 5b 01 00 00       	call   801fdc <nsipc_bind>
}
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    

00801e83 <shutdown>:

int
shutdown(int s, int how)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e89:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8c:	e8 63 ff ff ff       	call   801df4 <fd2sockid>
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 0f                	js     801ea4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e98:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e9c:	89 04 24             	mov    %eax,(%esp)
  801e9f:	e8 77 01 00 00       	call   80201b <nsipc_shutdown>
}
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eac:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaf:	e8 40 ff ff ff       	call   801df4 <fd2sockid>
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	78 16                	js     801ece <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801eb8:	8b 55 10             	mov    0x10(%ebp),%edx
  801ebb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ebf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ec6:	89 04 24             	mov    %eax,(%esp)
  801ec9:	e8 89 01 00 00       	call   802057 <nsipc_connect>
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <listen>:

int
listen(int s, int backlog)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed9:	e8 16 ff ff ff       	call   801df4 <fd2sockid>
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	78 0f                	js     801ef1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ee5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ee9:	89 04 24             	mov    %eax,(%esp)
  801eec:	e8 a5 01 00 00       	call   802096 <nsipc_listen>
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ef9:	8b 45 10             	mov    0x10(%ebp),%eax
  801efc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f07:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0a:	89 04 24             	mov    %eax,(%esp)
  801f0d:	e8 99 02 00 00       	call   8021ab <nsipc_socket>
  801f12:	85 c0                	test   %eax,%eax
  801f14:	78 05                	js     801f1b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801f16:	e8 68 fe ff ff       	call   801d83 <alloc_sockfd>
}
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    
  801f1d:	00 00                	add    %al,(%eax)
	...

00801f20 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	53                   	push   %ebx
  801f24:	83 ec 14             	sub    $0x14,%esp
  801f27:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f29:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f30:	75 11                	jne    801f43 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f32:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f39:	e8 c9 f4 ff ff       	call   801407 <ipc_find_env>
  801f3e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f43:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f4a:	00 
  801f4b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801f52:	00 
  801f53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f57:	a1 04 50 80 00       	mov    0x805004,%eax
  801f5c:	89 04 24             	mov    %eax,(%esp)
  801f5f:	e8 20 f4 ff ff       	call   801384 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f6b:	00 
  801f6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f73:	00 
  801f74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f7b:	e8 94 f3 ff ff       	call   801314 <ipc_recv>
}
  801f80:	83 c4 14             	add    $0x14,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    

00801f86 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	56                   	push   %esi
  801f8a:	53                   	push   %ebx
  801f8b:	83 ec 10             	sub    $0x10,%esp
  801f8e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f91:	8b 45 08             	mov    0x8(%ebp),%eax
  801f94:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f99:	8b 06                	mov    (%esi),%eax
  801f9b:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fa0:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa5:	e8 76 ff ff ff       	call   801f20 <nsipc>
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 23                	js     801fd3 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fb0:	a1 10 70 80 00       	mov    0x807010,%eax
  801fb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fb9:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801fc0:	00 
  801fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc4:	89 04 24             	mov    %eax,(%esp)
  801fc7:	e8 48 ea ff ff       	call   800a14 <memmove>
		*addrlen = ret->ret_addrlen;
  801fcc:	a1 10 70 80 00       	mov    0x807010,%eax
  801fd1:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801fd3:	89 d8                	mov    %ebx,%eax
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    

00801fdc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	53                   	push   %ebx
  801fe0:	83 ec 14             	sub    $0x14,%esp
  801fe3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff9:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802000:	e8 0f ea ff ff       	call   800a14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802005:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80200b:	b8 02 00 00 00       	mov    $0x2,%eax
  802010:	e8 0b ff ff ff       	call   801f20 <nsipc>
}
  802015:	83 c4 14             	add    $0x14,%esp
  802018:	5b                   	pop    %ebx
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802021:	8b 45 08             	mov    0x8(%ebp),%eax
  802024:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802029:	8b 45 0c             	mov    0xc(%ebp),%eax
  80202c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802031:	b8 03 00 00 00       	mov    $0x3,%eax
  802036:	e8 e5 fe ff ff       	call   801f20 <nsipc>
}
  80203b:	c9                   	leave  
  80203c:	c3                   	ret    

0080203d <nsipc_close>:

int
nsipc_close(int s)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802043:	8b 45 08             	mov    0x8(%ebp),%eax
  802046:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80204b:	b8 04 00 00 00       	mov    $0x4,%eax
  802050:	e8 cb fe ff ff       	call   801f20 <nsipc>
}
  802055:	c9                   	leave  
  802056:	c3                   	ret    

00802057 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	53                   	push   %ebx
  80205b:	83 ec 14             	sub    $0x14,%esp
  80205e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802061:	8b 45 08             	mov    0x8(%ebp),%eax
  802064:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80206d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802070:	89 44 24 04          	mov    %eax,0x4(%esp)
  802074:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80207b:	e8 94 e9 ff ff       	call   800a14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802080:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802086:	b8 05 00 00 00       	mov    $0x5,%eax
  80208b:	e8 90 fe ff ff       	call   801f20 <nsipc>
}
  802090:	83 c4 14             	add    $0x14,%esp
  802093:	5b                   	pop    %ebx
  802094:	5d                   	pop    %ebp
  802095:	c3                   	ret    

00802096 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80209c:	8b 45 08             	mov    0x8(%ebp),%eax
  80209f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8020ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8020b1:	e8 6a fe ff ff       	call   801f20 <nsipc>
}
  8020b6:	c9                   	leave  
  8020b7:	c3                   	ret    

008020b8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	56                   	push   %esi
  8020bc:	53                   	push   %ebx
  8020bd:	83 ec 10             	sub    $0x10,%esp
  8020c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8020cb:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8020d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8020d4:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8020d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8020de:	e8 3d fe ff ff       	call   801f20 <nsipc>
  8020e3:	89 c3                	mov    %eax,%ebx
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	78 46                	js     80212f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8020e9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8020ee:	7f 04                	jg     8020f4 <nsipc_recv+0x3c>
  8020f0:	39 c6                	cmp    %eax,%esi
  8020f2:	7d 24                	jge    802118 <nsipc_recv+0x60>
  8020f4:	c7 44 24 0c cf 2f 80 	movl   $0x802fcf,0xc(%esp)
  8020fb:	00 
  8020fc:	c7 44 24 08 97 2f 80 	movl   $0x802f97,0x8(%esp)
  802103:	00 
  802104:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80210b:	00 
  80210c:	c7 04 24 e4 2f 80 00 	movl   $0x802fe4,(%esp)
  802113:	e8 d8 05 00 00       	call   8026f0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802118:	89 44 24 08          	mov    %eax,0x8(%esp)
  80211c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802123:	00 
  802124:	8b 45 0c             	mov    0xc(%ebp),%eax
  802127:	89 04 24             	mov    %eax,(%esp)
  80212a:	e8 e5 e8 ff ff       	call   800a14 <memmove>
	}

	return r;
}
  80212f:	89 d8                	mov    %ebx,%eax
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    

00802138 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	53                   	push   %ebx
  80213c:	83 ec 14             	sub    $0x14,%esp
  80213f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802142:	8b 45 08             	mov    0x8(%ebp),%eax
  802145:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80214a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802150:	7e 24                	jle    802176 <nsipc_send+0x3e>
  802152:	c7 44 24 0c f0 2f 80 	movl   $0x802ff0,0xc(%esp)
  802159:	00 
  80215a:	c7 44 24 08 97 2f 80 	movl   $0x802f97,0x8(%esp)
  802161:	00 
  802162:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802169:	00 
  80216a:	c7 04 24 e4 2f 80 00 	movl   $0x802fe4,(%esp)
  802171:	e8 7a 05 00 00       	call   8026f0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802176:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80217a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802181:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802188:	e8 87 e8 ff ff       	call   800a14 <memmove>
	nsipcbuf.send.req_size = size;
  80218d:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802193:	8b 45 14             	mov    0x14(%ebp),%eax
  802196:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80219b:	b8 08 00 00 00       	mov    $0x8,%eax
  8021a0:	e8 7b fd ff ff       	call   801f20 <nsipc>
}
  8021a5:	83 c4 14             	add    $0x14,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5d                   	pop    %ebp
  8021aa:	c3                   	ret    

008021ab <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8021b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021bc:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8021c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8021c4:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8021c9:	b8 09 00 00 00       	mov    $0x9,%eax
  8021ce:	e8 4d fd ff ff       	call   801f20 <nsipc>
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    
  8021d5:	00 00                	add    %al,(%eax)
	...

008021d8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	56                   	push   %esi
  8021dc:	53                   	push   %ebx
  8021dd:	83 ec 10             	sub    $0x10,%esp
  8021e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e6:	89 04 24             	mov    %eax,(%esp)
  8021e9:	e8 6e f2 ff ff       	call   80145c <fd2data>
  8021ee:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8021f0:	c7 44 24 04 fc 2f 80 	movl   $0x802ffc,0x4(%esp)
  8021f7:	00 
  8021f8:	89 34 24             	mov    %esi,(%esp)
  8021fb:	e8 9b e6 ff ff       	call   80089b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802200:	8b 43 04             	mov    0x4(%ebx),%eax
  802203:	2b 03                	sub    (%ebx),%eax
  802205:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80220b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802212:	00 00 00 
	stat->st_dev = &devpipe;
  802215:	c7 86 88 00 00 00 44 	movl   $0x804044,0x88(%esi)
  80221c:	40 80 00 
	return 0;
}
  80221f:	b8 00 00 00 00       	mov    $0x0,%eax
  802224:	83 c4 10             	add    $0x10,%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    

0080222b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	53                   	push   %ebx
  80222f:	83 ec 14             	sub    $0x14,%esp
  802232:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802235:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802240:	e8 ef ea ff ff       	call   800d34 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802245:	89 1c 24             	mov    %ebx,(%esp)
  802248:	e8 0f f2 ff ff       	call   80145c <fd2data>
  80224d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802251:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802258:	e8 d7 ea ff ff       	call   800d34 <sys_page_unmap>
}
  80225d:	83 c4 14             	add    $0x14,%esp
  802260:	5b                   	pop    %ebx
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    

00802263 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	57                   	push   %edi
  802267:	56                   	push   %esi
  802268:	53                   	push   %ebx
  802269:	83 ec 2c             	sub    $0x2c,%esp
  80226c:	89 c7                	mov    %eax,%edi
  80226e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802271:	a1 08 50 80 00       	mov    0x805008,%eax
  802276:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802279:	89 3c 24             	mov    %edi,(%esp)
  80227c:	e8 3b 05 00 00       	call   8027bc <pageref>
  802281:	89 c6                	mov    %eax,%esi
  802283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802286:	89 04 24             	mov    %eax,(%esp)
  802289:	e8 2e 05 00 00       	call   8027bc <pageref>
  80228e:	39 c6                	cmp    %eax,%esi
  802290:	0f 94 c0             	sete   %al
  802293:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802296:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80229c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80229f:	39 cb                	cmp    %ecx,%ebx
  8022a1:	75 08                	jne    8022ab <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8022a3:	83 c4 2c             	add    $0x2c,%esp
  8022a6:	5b                   	pop    %ebx
  8022a7:	5e                   	pop    %esi
  8022a8:	5f                   	pop    %edi
  8022a9:	5d                   	pop    %ebp
  8022aa:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8022ab:	83 f8 01             	cmp    $0x1,%eax
  8022ae:	75 c1                	jne    802271 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022b0:	8b 42 58             	mov    0x58(%edx),%eax
  8022b3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8022ba:	00 
  8022bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022c3:	c7 04 24 03 30 80 00 	movl   $0x803003,(%esp)
  8022ca:	e8 21 e0 ff ff       	call   8002f0 <cprintf>
  8022cf:	eb a0                	jmp    802271 <_pipeisclosed+0xe>

008022d1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	57                   	push   %edi
  8022d5:	56                   	push   %esi
  8022d6:	53                   	push   %ebx
  8022d7:	83 ec 1c             	sub    $0x1c,%esp
  8022da:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022dd:	89 34 24             	mov    %esi,(%esp)
  8022e0:	e8 77 f1 ff ff       	call   80145c <fd2data>
  8022e5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ec:	eb 3c                	jmp    80232a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022ee:	89 da                	mov    %ebx,%edx
  8022f0:	89 f0                	mov    %esi,%eax
  8022f2:	e8 6c ff ff ff       	call   802263 <_pipeisclosed>
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	75 38                	jne    802333 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022fb:	e8 6e e9 ff ff       	call   800c6e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802300:	8b 43 04             	mov    0x4(%ebx),%eax
  802303:	8b 13                	mov    (%ebx),%edx
  802305:	83 c2 20             	add    $0x20,%edx
  802308:	39 d0                	cmp    %edx,%eax
  80230a:	73 e2                	jae    8022ee <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80230c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802312:	89 c2                	mov    %eax,%edx
  802314:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80231a:	79 05                	jns    802321 <devpipe_write+0x50>
  80231c:	4a                   	dec    %edx
  80231d:	83 ca e0             	or     $0xffffffe0,%edx
  802320:	42                   	inc    %edx
  802321:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802325:	40                   	inc    %eax
  802326:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802329:	47                   	inc    %edi
  80232a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80232d:	75 d1                	jne    802300 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80232f:	89 f8                	mov    %edi,%eax
  802331:	eb 05                	jmp    802338 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802333:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802338:	83 c4 1c             	add    $0x1c,%esp
  80233b:	5b                   	pop    %ebx
  80233c:	5e                   	pop    %esi
  80233d:	5f                   	pop    %edi
  80233e:	5d                   	pop    %ebp
  80233f:	c3                   	ret    

00802340 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	57                   	push   %edi
  802344:	56                   	push   %esi
  802345:	53                   	push   %ebx
  802346:	83 ec 1c             	sub    $0x1c,%esp
  802349:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80234c:	89 3c 24             	mov    %edi,(%esp)
  80234f:	e8 08 f1 ff ff       	call   80145c <fd2data>
  802354:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802356:	be 00 00 00 00       	mov    $0x0,%esi
  80235b:	eb 3a                	jmp    802397 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80235d:	85 f6                	test   %esi,%esi
  80235f:	74 04                	je     802365 <devpipe_read+0x25>
				return i;
  802361:	89 f0                	mov    %esi,%eax
  802363:	eb 40                	jmp    8023a5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802365:	89 da                	mov    %ebx,%edx
  802367:	89 f8                	mov    %edi,%eax
  802369:	e8 f5 fe ff ff       	call   802263 <_pipeisclosed>
  80236e:	85 c0                	test   %eax,%eax
  802370:	75 2e                	jne    8023a0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802372:	e8 f7 e8 ff ff       	call   800c6e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802377:	8b 03                	mov    (%ebx),%eax
  802379:	3b 43 04             	cmp    0x4(%ebx),%eax
  80237c:	74 df                	je     80235d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80237e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802383:	79 05                	jns    80238a <devpipe_read+0x4a>
  802385:	48                   	dec    %eax
  802386:	83 c8 e0             	or     $0xffffffe0,%eax
  802389:	40                   	inc    %eax
  80238a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80238e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802391:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802394:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802396:	46                   	inc    %esi
  802397:	3b 75 10             	cmp    0x10(%ebp),%esi
  80239a:	75 db                	jne    802377 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80239c:	89 f0                	mov    %esi,%eax
  80239e:	eb 05                	jmp    8023a5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023a0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023a5:	83 c4 1c             	add    $0x1c,%esp
  8023a8:	5b                   	pop    %ebx
  8023a9:	5e                   	pop    %esi
  8023aa:	5f                   	pop    %edi
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    

008023ad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023ad:	55                   	push   %ebp
  8023ae:	89 e5                	mov    %esp,%ebp
  8023b0:	57                   	push   %edi
  8023b1:	56                   	push   %esi
  8023b2:	53                   	push   %ebx
  8023b3:	83 ec 3c             	sub    $0x3c,%esp
  8023b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8023bc:	89 04 24             	mov    %eax,(%esp)
  8023bf:	e8 b3 f0 ff ff       	call   801477 <fd_alloc>
  8023c4:	89 c3                	mov    %eax,%ebx
  8023c6:	85 c0                	test   %eax,%eax
  8023c8:	0f 88 45 01 00 00    	js     802513 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ce:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023d5:	00 
  8023d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023e4:	e8 a4 e8 ff ff       	call   800c8d <sys_page_alloc>
  8023e9:	89 c3                	mov    %eax,%ebx
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	0f 88 20 01 00 00    	js     802513 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8023f6:	89 04 24             	mov    %eax,(%esp)
  8023f9:	e8 79 f0 ff ff       	call   801477 <fd_alloc>
  8023fe:	89 c3                	mov    %eax,%ebx
  802400:	85 c0                	test   %eax,%eax
  802402:	0f 88 f8 00 00 00    	js     802500 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802408:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80240f:	00 
  802410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802413:	89 44 24 04          	mov    %eax,0x4(%esp)
  802417:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80241e:	e8 6a e8 ff ff       	call   800c8d <sys_page_alloc>
  802423:	89 c3                	mov    %eax,%ebx
  802425:	85 c0                	test   %eax,%eax
  802427:	0f 88 d3 00 00 00    	js     802500 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80242d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802430:	89 04 24             	mov    %eax,(%esp)
  802433:	e8 24 f0 ff ff       	call   80145c <fd2data>
  802438:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80243a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802441:	00 
  802442:	89 44 24 04          	mov    %eax,0x4(%esp)
  802446:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80244d:	e8 3b e8 ff ff       	call   800c8d <sys_page_alloc>
  802452:	89 c3                	mov    %eax,%ebx
  802454:	85 c0                	test   %eax,%eax
  802456:	0f 88 91 00 00 00    	js     8024ed <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80245c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80245f:	89 04 24             	mov    %eax,(%esp)
  802462:	e8 f5 ef ff ff       	call   80145c <fd2data>
  802467:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80246e:	00 
  80246f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802473:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80247a:	00 
  80247b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80247f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802486:	e8 56 e8 ff ff       	call   800ce1 <sys_page_map>
  80248b:	89 c3                	mov    %eax,%ebx
  80248d:	85 c0                	test   %eax,%eax
  80248f:	78 4c                	js     8024dd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802491:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802497:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80249a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80249c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80249f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024a6:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8024ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024af:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024b4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024be:	89 04 24             	mov    %eax,(%esp)
  8024c1:	e8 86 ef ff ff       	call   80144c <fd2num>
  8024c6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8024c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024cb:	89 04 24             	mov    %eax,(%esp)
  8024ce:	e8 79 ef ff ff       	call   80144c <fd2num>
  8024d3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8024d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024db:	eb 36                	jmp    802513 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8024dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024e8:	e8 47 e8 ff ff       	call   800d34 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8024ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024fb:	e8 34 e8 ff ff       	call   800d34 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802500:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802503:	89 44 24 04          	mov    %eax,0x4(%esp)
  802507:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80250e:	e8 21 e8 ff ff       	call   800d34 <sys_page_unmap>
    err:
	return r;
}
  802513:	89 d8                	mov    %ebx,%eax
  802515:	83 c4 3c             	add    $0x3c,%esp
  802518:	5b                   	pop    %ebx
  802519:	5e                   	pop    %esi
  80251a:	5f                   	pop    %edi
  80251b:	5d                   	pop    %ebp
  80251c:	c3                   	ret    

0080251d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80251d:	55                   	push   %ebp
  80251e:	89 e5                	mov    %esp,%ebp
  802520:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80252a:	8b 45 08             	mov    0x8(%ebp),%eax
  80252d:	89 04 24             	mov    %eax,(%esp)
  802530:	e8 95 ef ff ff       	call   8014ca <fd_lookup>
  802535:	85 c0                	test   %eax,%eax
  802537:	78 15                	js     80254e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802539:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253c:	89 04 24             	mov    %eax,(%esp)
  80253f:	e8 18 ef ff ff       	call   80145c <fd2data>
	return _pipeisclosed(fd, p);
  802544:	89 c2                	mov    %eax,%edx
  802546:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802549:	e8 15 fd ff ff       	call   802263 <_pipeisclosed>
}
  80254e:	c9                   	leave  
  80254f:	c3                   	ret    

00802550 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802553:	b8 00 00 00 00       	mov    $0x0,%eax
  802558:	5d                   	pop    %ebp
  802559:	c3                   	ret    

0080255a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80255a:	55                   	push   %ebp
  80255b:	89 e5                	mov    %esp,%ebp
  80255d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802560:	c7 44 24 04 1b 30 80 	movl   $0x80301b,0x4(%esp)
  802567:	00 
  802568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80256b:	89 04 24             	mov    %eax,(%esp)
  80256e:	e8 28 e3 ff ff       	call   80089b <strcpy>
	return 0;
}
  802573:	b8 00 00 00 00       	mov    $0x0,%eax
  802578:	c9                   	leave  
  802579:	c3                   	ret    

0080257a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80257a:	55                   	push   %ebp
  80257b:	89 e5                	mov    %esp,%ebp
  80257d:	57                   	push   %edi
  80257e:	56                   	push   %esi
  80257f:	53                   	push   %ebx
  802580:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802586:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80258b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802591:	eb 30                	jmp    8025c3 <devcons_write+0x49>
		m = n - tot;
  802593:	8b 75 10             	mov    0x10(%ebp),%esi
  802596:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802598:	83 fe 7f             	cmp    $0x7f,%esi
  80259b:	76 05                	jbe    8025a2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80259d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8025a2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025a6:	03 45 0c             	add    0xc(%ebp),%eax
  8025a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025ad:	89 3c 24             	mov    %edi,(%esp)
  8025b0:	e8 5f e4 ff ff       	call   800a14 <memmove>
		sys_cputs(buf, m);
  8025b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025b9:	89 3c 24             	mov    %edi,(%esp)
  8025bc:	e8 ff e5 ff ff       	call   800bc0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025c1:	01 f3                	add    %esi,%ebx
  8025c3:	89 d8                	mov    %ebx,%eax
  8025c5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025c8:	72 c9                	jb     802593 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025ca:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8025d0:	5b                   	pop    %ebx
  8025d1:	5e                   	pop    %esi
  8025d2:	5f                   	pop    %edi
  8025d3:	5d                   	pop    %ebp
  8025d4:	c3                   	ret    

008025d5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025d5:	55                   	push   %ebp
  8025d6:	89 e5                	mov    %esp,%ebp
  8025d8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8025db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025df:	75 07                	jne    8025e8 <devcons_read+0x13>
  8025e1:	eb 25                	jmp    802608 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025e3:	e8 86 e6 ff ff       	call   800c6e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025e8:	e8 f1 e5 ff ff       	call   800bde <sys_cgetc>
  8025ed:	85 c0                	test   %eax,%eax
  8025ef:	74 f2                	je     8025e3 <devcons_read+0xe>
  8025f1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8025f3:	85 c0                	test   %eax,%eax
  8025f5:	78 1d                	js     802614 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025f7:	83 f8 04             	cmp    $0x4,%eax
  8025fa:	74 13                	je     80260f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8025fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ff:	88 10                	mov    %dl,(%eax)
	return 1;
  802601:	b8 01 00 00 00       	mov    $0x1,%eax
  802606:	eb 0c                	jmp    802614 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802608:	b8 00 00 00 00       	mov    $0x0,%eax
  80260d:	eb 05                	jmp    802614 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80260f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802614:	c9                   	leave  
  802615:	c3                   	ret    

00802616 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802616:	55                   	push   %ebp
  802617:	89 e5                	mov    %esp,%ebp
  802619:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80261c:	8b 45 08             	mov    0x8(%ebp),%eax
  80261f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802622:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802629:	00 
  80262a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80262d:	89 04 24             	mov    %eax,(%esp)
  802630:	e8 8b e5 ff ff       	call   800bc0 <sys_cputs>
}
  802635:	c9                   	leave  
  802636:	c3                   	ret    

00802637 <getchar>:

int
getchar(void)
{
  802637:	55                   	push   %ebp
  802638:	89 e5                	mov    %esp,%ebp
  80263a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80263d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802644:	00 
  802645:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80264c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802653:	e8 10 f1 ff ff       	call   801768 <read>
	if (r < 0)
  802658:	85 c0                	test   %eax,%eax
  80265a:	78 0f                	js     80266b <getchar+0x34>
		return r;
	if (r < 1)
  80265c:	85 c0                	test   %eax,%eax
  80265e:	7e 06                	jle    802666 <getchar+0x2f>
		return -E_EOF;
	return c;
  802660:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802664:	eb 05                	jmp    80266b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802666:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80266b:	c9                   	leave  
  80266c:	c3                   	ret    

0080266d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80266d:	55                   	push   %ebp
  80266e:	89 e5                	mov    %esp,%ebp
  802670:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802673:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802676:	89 44 24 04          	mov    %eax,0x4(%esp)
  80267a:	8b 45 08             	mov    0x8(%ebp),%eax
  80267d:	89 04 24             	mov    %eax,(%esp)
  802680:	e8 45 ee ff ff       	call   8014ca <fd_lookup>
  802685:	85 c0                	test   %eax,%eax
  802687:	78 11                	js     80269a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80268c:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802692:	39 10                	cmp    %edx,(%eax)
  802694:	0f 94 c0             	sete   %al
  802697:	0f b6 c0             	movzbl %al,%eax
}
  80269a:	c9                   	leave  
  80269b:	c3                   	ret    

0080269c <opencons>:

int
opencons(void)
{
  80269c:	55                   	push   %ebp
  80269d:	89 e5                	mov    %esp,%ebp
  80269f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026a5:	89 04 24             	mov    %eax,(%esp)
  8026a8:	e8 ca ed ff ff       	call   801477 <fd_alloc>
  8026ad:	85 c0                	test   %eax,%eax
  8026af:	78 3c                	js     8026ed <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026b1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026b8:	00 
  8026b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026c7:	e8 c1 e5 ff ff       	call   800c8d <sys_page_alloc>
  8026cc:	85 c0                	test   %eax,%eax
  8026ce:	78 1d                	js     8026ed <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026d0:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8026d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026d9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026de:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026e5:	89 04 24             	mov    %eax,(%esp)
  8026e8:	e8 5f ed ff ff       	call   80144c <fd2num>
}
  8026ed:	c9                   	leave  
  8026ee:	c3                   	ret    
	...

008026f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8026f0:	55                   	push   %ebp
  8026f1:	89 e5                	mov    %esp,%ebp
  8026f3:	56                   	push   %esi
  8026f4:	53                   	push   %ebx
  8026f5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8026f8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8026fb:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  802701:	e8 49 e5 ff ff       	call   800c4f <sys_getenvid>
  802706:	8b 55 0c             	mov    0xc(%ebp),%edx
  802709:	89 54 24 10          	mov    %edx,0x10(%esp)
  80270d:	8b 55 08             	mov    0x8(%ebp),%edx
  802710:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802714:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802718:	89 44 24 04          	mov    %eax,0x4(%esp)
  80271c:	c7 04 24 28 30 80 00 	movl   $0x803028,(%esp)
  802723:	e8 c8 db ff ff       	call   8002f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802728:	89 74 24 04          	mov    %esi,0x4(%esp)
  80272c:	8b 45 10             	mov    0x10(%ebp),%eax
  80272f:	89 04 24             	mov    %eax,(%esp)
  802732:	e8 58 db ff ff       	call   80028f <vcprintf>
	cprintf("\n");
  802737:	c7 04 24 14 30 80 00 	movl   $0x803014,(%esp)
  80273e:	e8 ad db ff ff       	call   8002f0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802743:	cc                   	int3   
  802744:	eb fd                	jmp    802743 <_panic+0x53>
	...

00802748 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802748:	55                   	push   %ebp
  802749:	89 e5                	mov    %esp,%ebp
  80274b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80274e:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802755:	75 30                	jne    802787 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  802757:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80275e:	00 
  80275f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802766:	ee 
  802767:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80276e:	e8 1a e5 ff ff       	call   800c8d <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802773:	c7 44 24 04 94 27 80 	movl   $0x802794,0x4(%esp)
  80277a:	00 
  80277b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802782:	e8 a6 e6 ff ff       	call   800e2d <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802787:	8b 45 08             	mov    0x8(%ebp),%eax
  80278a:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80278f:	c9                   	leave  
  802790:	c3                   	ret    
  802791:	00 00                	add    %al,(%eax)
	...

00802794 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802794:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802795:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80279a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80279c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  80279f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  8027a3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  8027a7:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  8027aa:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  8027ac:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  8027b0:	83 c4 08             	add    $0x8,%esp
	popal
  8027b3:	61                   	popa   

	addl $4,%esp 
  8027b4:	83 c4 04             	add    $0x4,%esp
	popfl
  8027b7:	9d                   	popf   

	popl %esp
  8027b8:	5c                   	pop    %esp

	ret
  8027b9:	c3                   	ret    
	...

008027bc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027bc:	55                   	push   %ebp
  8027bd:	89 e5                	mov    %esp,%ebp
  8027bf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027c2:	89 c2                	mov    %eax,%edx
  8027c4:	c1 ea 16             	shr    $0x16,%edx
  8027c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8027ce:	f6 c2 01             	test   $0x1,%dl
  8027d1:	74 1e                	je     8027f1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8027d3:	c1 e8 0c             	shr    $0xc,%eax
  8027d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8027dd:	a8 01                	test   $0x1,%al
  8027df:	74 17                	je     8027f8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027e1:	c1 e8 0c             	shr    $0xc,%eax
  8027e4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8027eb:	ef 
  8027ec:	0f b7 c0             	movzwl %ax,%eax
  8027ef:	eb 0c                	jmp    8027fd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8027f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8027f6:	eb 05                	jmp    8027fd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8027f8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8027fd:	5d                   	pop    %ebp
  8027fe:	c3                   	ret    
	...

00802800 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802800:	55                   	push   %ebp
  802801:	57                   	push   %edi
  802802:	56                   	push   %esi
  802803:	83 ec 10             	sub    $0x10,%esp
  802806:	8b 74 24 20          	mov    0x20(%esp),%esi
  80280a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80280e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802812:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802816:	89 cd                	mov    %ecx,%ebp
  802818:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80281c:	85 c0                	test   %eax,%eax
  80281e:	75 2c                	jne    80284c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802820:	39 f9                	cmp    %edi,%ecx
  802822:	77 68                	ja     80288c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802824:	85 c9                	test   %ecx,%ecx
  802826:	75 0b                	jne    802833 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802828:	b8 01 00 00 00       	mov    $0x1,%eax
  80282d:	31 d2                	xor    %edx,%edx
  80282f:	f7 f1                	div    %ecx
  802831:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802833:	31 d2                	xor    %edx,%edx
  802835:	89 f8                	mov    %edi,%eax
  802837:	f7 f1                	div    %ecx
  802839:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80283b:	89 f0                	mov    %esi,%eax
  80283d:	f7 f1                	div    %ecx
  80283f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802841:	89 f0                	mov    %esi,%eax
  802843:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802845:	83 c4 10             	add    $0x10,%esp
  802848:	5e                   	pop    %esi
  802849:	5f                   	pop    %edi
  80284a:	5d                   	pop    %ebp
  80284b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80284c:	39 f8                	cmp    %edi,%eax
  80284e:	77 2c                	ja     80287c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802850:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802853:	83 f6 1f             	xor    $0x1f,%esi
  802856:	75 4c                	jne    8028a4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802858:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80285a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80285f:	72 0a                	jb     80286b <__udivdi3+0x6b>
  802861:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802865:	0f 87 ad 00 00 00    	ja     802918 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80286b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802870:	89 f0                	mov    %esi,%eax
  802872:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802874:	83 c4 10             	add    $0x10,%esp
  802877:	5e                   	pop    %esi
  802878:	5f                   	pop    %edi
  802879:	5d                   	pop    %ebp
  80287a:	c3                   	ret    
  80287b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80287c:	31 ff                	xor    %edi,%edi
  80287e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802880:	89 f0                	mov    %esi,%eax
  802882:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802884:	83 c4 10             	add    $0x10,%esp
  802887:	5e                   	pop    %esi
  802888:	5f                   	pop    %edi
  802889:	5d                   	pop    %ebp
  80288a:	c3                   	ret    
  80288b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80288c:	89 fa                	mov    %edi,%edx
  80288e:	89 f0                	mov    %esi,%eax
  802890:	f7 f1                	div    %ecx
  802892:	89 c6                	mov    %eax,%esi
  802894:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802896:	89 f0                	mov    %esi,%eax
  802898:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80289a:	83 c4 10             	add    $0x10,%esp
  80289d:	5e                   	pop    %esi
  80289e:	5f                   	pop    %edi
  80289f:	5d                   	pop    %ebp
  8028a0:	c3                   	ret    
  8028a1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8028a4:	89 f1                	mov    %esi,%ecx
  8028a6:	d3 e0                	shl    %cl,%eax
  8028a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8028ac:	b8 20 00 00 00       	mov    $0x20,%eax
  8028b1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8028b3:	89 ea                	mov    %ebp,%edx
  8028b5:	88 c1                	mov    %al,%cl
  8028b7:	d3 ea                	shr    %cl,%edx
  8028b9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8028bd:	09 ca                	or     %ecx,%edx
  8028bf:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8028c3:	89 f1                	mov    %esi,%ecx
  8028c5:	d3 e5                	shl    %cl,%ebp
  8028c7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8028cb:	89 fd                	mov    %edi,%ebp
  8028cd:	88 c1                	mov    %al,%cl
  8028cf:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8028d1:	89 fa                	mov    %edi,%edx
  8028d3:	89 f1                	mov    %esi,%ecx
  8028d5:	d3 e2                	shl    %cl,%edx
  8028d7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8028db:	88 c1                	mov    %al,%cl
  8028dd:	d3 ef                	shr    %cl,%edi
  8028df:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028e1:	89 f8                	mov    %edi,%eax
  8028e3:	89 ea                	mov    %ebp,%edx
  8028e5:	f7 74 24 08          	divl   0x8(%esp)
  8028e9:	89 d1                	mov    %edx,%ecx
  8028eb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8028ed:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028f1:	39 d1                	cmp    %edx,%ecx
  8028f3:	72 17                	jb     80290c <__udivdi3+0x10c>
  8028f5:	74 09                	je     802900 <__udivdi3+0x100>
  8028f7:	89 fe                	mov    %edi,%esi
  8028f9:	31 ff                	xor    %edi,%edi
  8028fb:	e9 41 ff ff ff       	jmp    802841 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802900:	8b 54 24 04          	mov    0x4(%esp),%edx
  802904:	89 f1                	mov    %esi,%ecx
  802906:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802908:	39 c2                	cmp    %eax,%edx
  80290a:	73 eb                	jae    8028f7 <__udivdi3+0xf7>
		{
		  q0--;
  80290c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80290f:	31 ff                	xor    %edi,%edi
  802911:	e9 2b ff ff ff       	jmp    802841 <__udivdi3+0x41>
  802916:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802918:	31 f6                	xor    %esi,%esi
  80291a:	e9 22 ff ff ff       	jmp    802841 <__udivdi3+0x41>
	...

00802920 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802920:	55                   	push   %ebp
  802921:	57                   	push   %edi
  802922:	56                   	push   %esi
  802923:	83 ec 20             	sub    $0x20,%esp
  802926:	8b 44 24 30          	mov    0x30(%esp),%eax
  80292a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80292e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802932:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802936:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80293a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80293e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802940:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802942:	85 ed                	test   %ebp,%ebp
  802944:	75 16                	jne    80295c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802946:	39 f1                	cmp    %esi,%ecx
  802948:	0f 86 a6 00 00 00    	jbe    8029f4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80294e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802950:	89 d0                	mov    %edx,%eax
  802952:	31 d2                	xor    %edx,%edx
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80295c:	39 f5                	cmp    %esi,%ebp
  80295e:	0f 87 ac 00 00 00    	ja     802a10 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802964:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802967:	83 f0 1f             	xor    $0x1f,%eax
  80296a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80296e:	0f 84 a8 00 00 00    	je     802a1c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802974:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802978:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80297a:	bf 20 00 00 00       	mov    $0x20,%edi
  80297f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802983:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802987:	89 f9                	mov    %edi,%ecx
  802989:	d3 e8                	shr    %cl,%eax
  80298b:	09 e8                	or     %ebp,%eax
  80298d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802991:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802995:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802999:	d3 e0                	shl    %cl,%eax
  80299b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80299f:	89 f2                	mov    %esi,%edx
  8029a1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8029a3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8029a7:	d3 e0                	shl    %cl,%eax
  8029a9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8029ad:	8b 44 24 14          	mov    0x14(%esp),%eax
  8029b1:	89 f9                	mov    %edi,%ecx
  8029b3:	d3 e8                	shr    %cl,%eax
  8029b5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8029b7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029b9:	89 f2                	mov    %esi,%edx
  8029bb:	f7 74 24 18          	divl   0x18(%esp)
  8029bf:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8029c1:	f7 64 24 0c          	mull   0xc(%esp)
  8029c5:	89 c5                	mov    %eax,%ebp
  8029c7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029c9:	39 d6                	cmp    %edx,%esi
  8029cb:	72 67                	jb     802a34 <__umoddi3+0x114>
  8029cd:	74 75                	je     802a44 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8029cf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8029d3:	29 e8                	sub    %ebp,%eax
  8029d5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8029d7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029db:	d3 e8                	shr    %cl,%eax
  8029dd:	89 f2                	mov    %esi,%edx
  8029df:	89 f9                	mov    %edi,%ecx
  8029e1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8029e3:	09 d0                	or     %edx,%eax
  8029e5:	89 f2                	mov    %esi,%edx
  8029e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029eb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029ed:	83 c4 20             	add    $0x20,%esp
  8029f0:	5e                   	pop    %esi
  8029f1:	5f                   	pop    %edi
  8029f2:	5d                   	pop    %ebp
  8029f3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8029f4:	85 c9                	test   %ecx,%ecx
  8029f6:	75 0b                	jne    802a03 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8029f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8029fd:	31 d2                	xor    %edx,%edx
  8029ff:	f7 f1                	div    %ecx
  802a01:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802a03:	89 f0                	mov    %esi,%eax
  802a05:	31 d2                	xor    %edx,%edx
  802a07:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a09:	89 f8                	mov    %edi,%eax
  802a0b:	e9 3e ff ff ff       	jmp    80294e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802a10:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a12:	83 c4 20             	add    $0x20,%esp
  802a15:	5e                   	pop    %esi
  802a16:	5f                   	pop    %edi
  802a17:	5d                   	pop    %ebp
  802a18:	c3                   	ret    
  802a19:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a1c:	39 f5                	cmp    %esi,%ebp
  802a1e:	72 04                	jb     802a24 <__umoddi3+0x104>
  802a20:	39 f9                	cmp    %edi,%ecx
  802a22:	77 06                	ja     802a2a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a24:	89 f2                	mov    %esi,%edx
  802a26:	29 cf                	sub    %ecx,%edi
  802a28:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802a2a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a2c:	83 c4 20             	add    $0x20,%esp
  802a2f:	5e                   	pop    %esi
  802a30:	5f                   	pop    %edi
  802a31:	5d                   	pop    %ebp
  802a32:	c3                   	ret    
  802a33:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a34:	89 d1                	mov    %edx,%ecx
  802a36:	89 c5                	mov    %eax,%ebp
  802a38:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802a3c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802a40:	eb 8d                	jmp    8029cf <__umoddi3+0xaf>
  802a42:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a44:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802a48:	72 ea                	jb     802a34 <__umoddi3+0x114>
  802a4a:	89 f1                	mov    %esi,%ecx
  802a4c:	eb 81                	jmp    8029cf <__umoddi3+0xaf>
