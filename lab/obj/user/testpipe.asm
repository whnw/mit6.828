
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 e7 02 00 00       	call   800318 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 c4 80             	add    $0xffffff80,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003c:	c7 05 04 40 80 00 00 	movl   $0x802c00,0x804004
  800043:	2c 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 b4 23 00 00       	call   802405 <pipe>
  800051:	89 c6                	mov    %eax,%esi
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", i);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 0c 2c 80 	movl   $0x802c0c,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 15 2c 80 00 	movl   $0x802c15,(%esp)
  800072:	e8 11 03 00 00       	call   800388 <_panic>

	if ((pid = fork()) < 0)
  800077:	e8 43 11 00 00       	call   8011bf <fork>
  80007c:	89 c3                	mov    %eax,%ebx
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", i);
  800082:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800086:	c7 44 24 08 05 31 80 	movl   $0x803105,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 15 2c 80 00 	movl   $0x802c15,(%esp)
  80009d:	e8 e6 02 00 00       	call   800388 <_panic>

	if (pid == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 85 d5 00 00 00    	jne    80017f <umain+0x14b>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000aa:	a1 08 50 80 00       	mov    0x805008,%eax
  8000af:	8b 40 48             	mov    0x48(%eax),%eax
  8000b2:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 25 2c 80 00 	movl   $0x802c25,(%esp)
  8000c4:	e8 b7 03 00 00       	call   800480 <cprintf>
		close(p[1]);
  8000c9:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000cc:	89 04 24             	mov    %eax,(%esp)
  8000cf:	e8 86 15 00 00       	call   80165a <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d4:	a1 08 50 80 00       	mov    0x805008,%eax
  8000d9:	8b 40 48             	mov    0x48(%eax),%eax
  8000dc:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e7:	c7 04 24 42 2c 80 00 	movl   $0x802c42,(%esp)
  8000ee:	e8 8d 03 00 00       	call   800480 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f3:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000fa:	00 
  8000fb:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800105:	89 04 24             	mov    %eax,(%esp)
  800108:	e8 43 17 00 00       	call   801850 <readn>
  80010d:	89 c6                	mov    %eax,%esi
		if (i < 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	79 20                	jns    800133 <umain+0xff>
			panic("read: %e", i);
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 15 2c 80 00 	movl   $0x802c15,(%esp)
  80012e:	e8 55 02 00 00       	call   800388 <_panic>
		buf[i] = 0;
  800133:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800138:	a1 00 40 80 00       	mov    0x804000,%eax
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 86 09 00 00       	call   800ad2 <strcmp>
  80014c:	85 c0                	test   %eax,%eax
  80014e:	75 0e                	jne    80015e <umain+0x12a>
			cprintf("\npipe read closed properly\n");
  800150:	c7 04 24 68 2c 80 00 	movl   $0x802c68,(%esp)
  800157:	e8 24 03 00 00       	call   800480 <cprintf>
  80015c:	eb 17                	jmp    800175 <umain+0x141>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80015e:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	89 74 24 04          	mov    %esi,0x4(%esp)
  800169:	c7 04 24 84 2c 80 00 	movl   $0x802c84,(%esp)
  800170:	e8 0b 03 00 00       	call   800480 <cprintf>
		exit();
  800175:	e8 f2 01 00 00       	call   80036c <exit>
  80017a:	e9 ac 00 00 00       	jmp    80022b <umain+0x1f7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80017f:	a1 08 50 80 00       	mov    0x805008,%eax
  800184:	8b 40 48             	mov    0x48(%eax),%eax
  800187:	8b 55 8c             	mov    -0x74(%ebp),%edx
  80018a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 25 2c 80 00 	movl   $0x802c25,(%esp)
  800199:	e8 e2 02 00 00       	call   800480 <cprintf>
		close(p[0]);
  80019e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 b1 14 00 00       	call   80165a <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001a9:	a1 08 50 80 00       	mov    0x805008,%eax
  8001ae:	8b 40 48             	mov    0x48(%eax),%eax
  8001b1:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 97 2c 80 00 	movl   $0x802c97,(%esp)
  8001c3:	e8 b8 02 00 00       	call   800480 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001c8:	a1 00 40 80 00       	mov    0x804000,%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 23 08 00 00       	call   8009f8 <strlen>
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	a1 00 40 80 00       	mov    0x804000,%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 ae 16 00 00       	call   80189b <write>
  8001ed:	89 c6                	mov    %eax,%esi
  8001ef:	a1 00 40 80 00       	mov    0x804000,%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 fc 07 00 00       	call   8009f8 <strlen>
  8001fc:	39 c6                	cmp    %eax,%esi
  8001fe:	74 20                	je     800220 <umain+0x1ec>
			panic("write: %e", i);
  800200:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800204:	c7 44 24 08 b4 2c 80 	movl   $0x802cb4,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 15 2c 80 00 	movl   $0x802c15,(%esp)
  80021b:	e8 68 01 00 00       	call   800388 <_panic>
		close(p[1]);
  800220:	8b 45 90             	mov    -0x70(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	e8 2f 14 00 00       	call   80165a <close>
	}
	wait(pid);
  80022b:	89 1c 24             	mov    %ebx,(%esp)
  80022e:	e8 75 23 00 00       	call   8025a8 <wait>

	binaryname = "pipewriteeof";
  800233:	c7 05 04 40 80 00 be 	movl   $0x802cbe,0x804004
  80023a:	2c 80 00 
	if ((i = pipe(p)) < 0)
  80023d:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 bd 21 00 00       	call   802405 <pipe>
  800248:	89 c6                	mov    %eax,%esi
  80024a:	85 c0                	test   %eax,%eax
  80024c:	79 20                	jns    80026e <umain+0x23a>
		panic("pipe: %e", i);
  80024e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800252:	c7 44 24 08 0c 2c 80 	movl   $0x802c0c,0x8(%esp)
  800259:	00 
  80025a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800261:	00 
  800262:	c7 04 24 15 2c 80 00 	movl   $0x802c15,(%esp)
  800269:	e8 1a 01 00 00       	call   800388 <_panic>

	if ((pid = fork()) < 0)
  80026e:	e8 4c 0f 00 00       	call   8011bf <fork>
  800273:	89 c3                	mov    %eax,%ebx
  800275:	85 c0                	test   %eax,%eax
  800277:	79 20                	jns    800299 <umain+0x265>
		panic("fork: %e", i);
  800279:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027d:	c7 44 24 08 05 31 80 	movl   $0x803105,0x8(%esp)
  800284:	00 
  800285:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80028c:	00 
  80028d:	c7 04 24 15 2c 80 00 	movl   $0x802c15,(%esp)
  800294:	e8 ef 00 00 00       	call   800388 <_panic>

	if (pid == 0) {
  800299:	85 c0                	test   %eax,%eax
  80029b:	75 48                	jne    8002e5 <umain+0x2b1>
		close(p[0]);
  80029d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 b2 13 00 00       	call   80165a <close>
		while (1) {
			cprintf(".");
  8002a8:	c7 04 24 cb 2c 80 00 	movl   $0x802ccb,(%esp)
  8002af:	e8 cc 01 00 00       	call   800480 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002bb:	00 
  8002bc:	c7 44 24 04 cd 2c 80 	movl   $0x802ccd,0x4(%esp)
  8002c3:	00 
  8002c4:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 cc 15 00 00       	call   80189b <write>
  8002cf:	83 f8 01             	cmp    $0x1,%eax
  8002d2:	74 d4                	je     8002a8 <umain+0x274>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002d4:	c7 04 24 cf 2c 80 00 	movl   $0x802ccf,(%esp)
  8002db:	e8 a0 01 00 00       	call   800480 <cprintf>
		exit();
  8002e0:	e8 87 00 00 00       	call   80036c <exit>
	}
	close(p[0]);
  8002e5:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 6a 13 00 00       	call   80165a <close>
	close(p[1]);
  8002f0:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 5f 13 00 00       	call   80165a <close>
	wait(pid);
  8002fb:	89 1c 24             	mov    %ebx,(%esp)
  8002fe:	e8 a5 22 00 00       	call   8025a8 <wait>

	cprintf("pipe tests passed\n");
  800303:	c7 04 24 ec 2c 80 00 	movl   $0x802cec,(%esp)
  80030a:	e8 71 01 00 00       	call   800480 <cprintf>
}
  80030f:	83 ec 80             	sub    $0xffffff80,%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    
	...

00800318 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
  80031d:	83 ec 10             	sub    $0x10,%esp
  800320:	8b 75 08             	mov    0x8(%ebp),%esi
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800326:	e8 b4 0a 00 00       	call   800ddf <sys_getenvid>
  80032b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800330:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800337:	c1 e0 07             	shl    $0x7,%eax
  80033a:	29 d0                	sub    %edx,%eax
  80033c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800341:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800346:	85 f6                	test   %esi,%esi
  800348:	7e 07                	jle    800351 <libmain+0x39>
		binaryname = argv[0];
  80034a:	8b 03                	mov    (%ebx),%eax
  80034c:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800351:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800355:	89 34 24             	mov    %esi,(%esp)
  800358:	e8 d7 fc ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80035d:	e8 0a 00 00 00       	call   80036c <exit>
}
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    
  800369:	00 00                	add    %al,(%eax)
	...

0080036c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800372:	e8 14 13 00 00       	call   80168b <close_all>
	sys_env_destroy(0);
  800377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80037e:	e8 0a 0a 00 00       	call   800d8d <sys_env_destroy>
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    
  800385:	00 00                	add    %al,(%eax)
	...

00800388 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800393:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  800399:	e8 41 0a 00 00       	call   800ddf <sys_getenvid>
  80039e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 50 2d 80 00 	movl   $0x802d50,(%esp)
  8003bb:	e8 c0 00 00 00       	call   800480 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	e8 50 00 00 00       	call   80041f <vcprintf>
	cprintf("\n");
  8003cf:	c7 04 24 40 2c 80 00 	movl   $0x802c40,(%esp)
  8003d6:	e8 a5 00 00 00       	call   800480 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003db:	cc                   	int3   
  8003dc:	eb fd                	jmp    8003db <_panic+0x53>
	...

008003e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 14             	sub    $0x14,%esp
  8003e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ea:	8b 03                	mov    (%ebx),%eax
  8003ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003f3:	40                   	inc    %eax
  8003f4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003fb:	75 19                	jne    800416 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003fd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800404:	00 
  800405:	8d 43 08             	lea    0x8(%ebx),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 40 09 00 00       	call   800d50 <sys_cputs>
		b->idx = 0;
  800410:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800416:	ff 43 04             	incl   0x4(%ebx)
}
  800419:	83 c4 14             	add    $0x14,%esp
  80041c:	5b                   	pop    %ebx
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800428:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042f:	00 00 00 
	b.cnt = 0;
  800432:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800439:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800443:	8b 45 08             	mov    0x8(%ebp),%eax
  800446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800450:	89 44 24 04          	mov    %eax,0x4(%esp)
  800454:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  80045b:	e8 82 01 00 00       	call   8005e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800460:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 d8 08 00 00       	call   800d50 <sys_cputs>

	return b.cnt;
}
  800478:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800486:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8b 45 08             	mov    0x8(%ebp),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	e8 87 ff ff ff       	call   80041f <vcprintf>
	va_end(ap);

	return cnt;
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    
	...

0080049c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 3c             	sub    $0x3c,%esp
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	89 d7                	mov    %edx,%edi
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	75 08                	jne    8004c8 <printnum+0x2c>
  8004c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004c6:	77 57                	ja     80051f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004cc:	4b                   	dec    %ebx
  8004cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004dc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004e7:	00 
  8004e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	e8 aa 24 00 00       	call   8029a4 <__udivdi3>
  8004fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800502:	89 04 24             	mov    %eax,(%esp)
  800505:	89 54 24 04          	mov    %edx,0x4(%esp)
  800509:	89 fa                	mov    %edi,%edx
  80050b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050e:	e8 89 ff ff ff       	call   80049c <printnum>
  800513:	eb 0f                	jmp    800524 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	89 34 24             	mov    %esi,(%esp)
  80051c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80051f:	4b                   	dec    %ebx
  800520:	85 db                	test   %ebx,%ebx
  800522:	7f f1                	jg     800515 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800524:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800528:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80052c:	8b 45 10             	mov    0x10(%ebp),%eax
  80052f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800533:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053a:	00 
  80053b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800544:	89 44 24 04          	mov    %eax,0x4(%esp)
  800548:	e8 77 25 00 00       	call   802ac4 <__umoddi3>
  80054d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800551:	0f be 80 73 2d 80 00 	movsbl 0x802d73(%eax),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80055e:	83 c4 3c             	add    $0x3c,%esp
  800561:	5b                   	pop    %ebx
  800562:	5e                   	pop    %esi
  800563:	5f                   	pop    %edi
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800569:	83 fa 01             	cmp    $0x1,%edx
  80056c:	7e 0e                	jle    80057c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80056e:	8b 10                	mov    (%eax),%edx
  800570:	8d 4a 08             	lea    0x8(%edx),%ecx
  800573:	89 08                	mov    %ecx,(%eax)
  800575:	8b 02                	mov    (%edx),%eax
  800577:	8b 52 04             	mov    0x4(%edx),%edx
  80057a:	eb 22                	jmp    80059e <getuint+0x38>
	else if (lflag)
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 10                	je     800590 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800580:	8b 10                	mov    (%eax),%edx
  800582:	8d 4a 04             	lea    0x4(%edx),%ecx
  800585:	89 08                	mov    %ecx,(%eax)
  800587:	8b 02                	mov    (%edx),%eax
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	eb 0e                	jmp    80059e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    

008005a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ae:	73 08                	jae    8005b8 <sprintputch+0x18>
		*b->buf++ = ch;
  8005b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005b3:	88 0a                	mov    %cl,(%edx)
  8005b5:	42                   	inc    %edx
  8005b6:	89 10                	mov    %edx,(%eax)
}
  8005b8:	5d                   	pop    %ebp
  8005b9:	c3                   	ret    

008005ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
  8005bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	e8 02 00 00 00       	call   8005e2 <vprintfmt>
	va_end(ap);
}
  8005e0:	c9                   	leave  
  8005e1:	c3                   	ret    

008005e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	57                   	push   %edi
  8005e6:	56                   	push   %esi
  8005e7:	53                   	push   %ebx
  8005e8:	83 ec 4c             	sub    $0x4c,%esp
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f1:	eb 12                	jmp    800605 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	0f 84 6b 03 00 00    	je     800966 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800605:	0f b6 06             	movzbl (%esi),%eax
  800608:	46                   	inc    %esi
  800609:	83 f8 25             	cmp    $0x25,%eax
  80060c:	75 e5                	jne    8005f3 <vprintfmt+0x11>
  80060e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800612:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800619:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80061e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062a:	eb 26                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80062f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800633:	eb 1d                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800638:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80063c:	eb 14                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800641:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800648:	eb 08                	jmp    800652 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80064a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80064d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	0f b6 06             	movzbl (%esi),%eax
  800655:	8d 56 01             	lea    0x1(%esi),%edx
  800658:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80065b:	8a 16                	mov    (%esi),%dl
  80065d:	83 ea 23             	sub    $0x23,%edx
  800660:	80 fa 55             	cmp    $0x55,%dl
  800663:	0f 87 e1 02 00 00    	ja     80094a <vprintfmt+0x368>
  800669:	0f b6 d2             	movzbl %dl,%edx
  80066c:	ff 24 95 c0 2e 80 00 	jmp    *0x802ec0(,%edx,4)
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80067b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80067e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800682:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800685:	8d 50 d0             	lea    -0x30(%eax),%edx
  800688:	83 fa 09             	cmp    $0x9,%edx
  80068b:	77 2a                	ja     8006b7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80068d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80068e:	eb eb                	jmp    80067b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80069e:	eb 17                	jmp    8006b7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a4:	78 98                	js     80063e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a9:	eb a7                	jmp    800652 <vprintfmt+0x70>
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006ae:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006b5:	eb 9b                	jmp    800652 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bb:	79 95                	jns    800652 <vprintfmt+0x70>
  8006bd:	eb 8b                	jmp    80064a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006bf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006c3:	eb 8d                	jmp    800652 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 04             	lea    0x4(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006dd:	e9 23 ff ff ff       	jmp    800605 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 04             	lea    0x4(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	79 02                	jns    8006f3 <vprintfmt+0x111>
  8006f1:	f7 d8                	neg    %eax
  8006f3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f5:	83 f8 10             	cmp    $0x10,%eax
  8006f8:	7f 0b                	jg     800705 <vprintfmt+0x123>
  8006fa:	8b 04 85 20 30 80 00 	mov    0x803020(,%eax,4),%eax
  800701:	85 c0                	test   %eax,%eax
  800703:	75 23                	jne    800728 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800705:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800709:	c7 44 24 08 8b 2d 80 	movl   $0x802d8b,0x8(%esp)
  800710:	00 
  800711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	89 04 24             	mov    %eax,(%esp)
  80071b:	e8 9a fe ff ff       	call   8005ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800720:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800723:	e9 dd fe ff ff       	jmp    800605 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800728:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072c:	c7 44 24 08 0d 32 80 	movl   $0x80320d,0x8(%esp)
  800733:	00 
  800734:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
  80073b:	89 14 24             	mov    %edx,(%esp)
  80073e:	e8 77 fe ff ff       	call   8005ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800746:	e9 ba fe ff ff       	jmp    800605 <vprintfmt+0x23>
  80074b:	89 f9                	mov    %edi,%ecx
  80074d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800750:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 50 04             	lea    0x4(%eax),%edx
  800759:	89 55 14             	mov    %edx,0x14(%ebp)
  80075c:	8b 30                	mov    (%eax),%esi
  80075e:	85 f6                	test   %esi,%esi
  800760:	75 05                	jne    800767 <vprintfmt+0x185>
				p = "(null)";
  800762:	be 84 2d 80 00       	mov    $0x802d84,%esi
			if (width > 0 && padc != '-')
  800767:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80076b:	0f 8e 84 00 00 00    	jle    8007f5 <vprintfmt+0x213>
  800771:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800775:	74 7e                	je     8007f5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800777:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077b:	89 34 24             	mov    %esi,(%esp)
  80077e:	e8 8b 02 00 00       	call   800a0e <strnlen>
  800783:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800786:	29 c2                	sub    %eax,%edx
  800788:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80078b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80078f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800792:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800795:	89 de                	mov    %ebx,%esi
  800797:	89 d3                	mov    %edx,%ebx
  800799:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079b:	eb 0b                	jmp    8007a8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80079d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a1:	89 3c 24             	mov    %edi,(%esp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a7:	4b                   	dec    %ebx
  8007a8:	85 db                	test   %ebx,%ebx
  8007aa:	7f f1                	jg     80079d <vprintfmt+0x1bb>
  8007ac:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007af:	89 f3                	mov    %esi,%ebx
  8007b1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	79 05                	jns    8007c0 <vprintfmt+0x1de>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c3:	29 c2                	sub    %eax,%edx
  8007c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007c8:	eb 2b                	jmp    8007f5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ce:	74 18                	je     8007e8 <vprintfmt+0x206>
  8007d0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007d3:	83 fa 5e             	cmp    $0x5e,%edx
  8007d6:	76 10                	jbe    8007e8 <vprintfmt+0x206>
					putch('?', putdat);
  8007d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
  8007e6:	eb 0a                	jmp    8007f2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	89 04 24             	mov    %eax,(%esp)
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f2:	ff 4d e4             	decl   -0x1c(%ebp)
  8007f5:	0f be 06             	movsbl (%esi),%eax
  8007f8:	46                   	inc    %esi
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	74 21                	je     80081e <vprintfmt+0x23c>
  8007fd:	85 ff                	test   %edi,%edi
  8007ff:	78 c9                	js     8007ca <vprintfmt+0x1e8>
  800801:	4f                   	dec    %edi
  800802:	79 c6                	jns    8007ca <vprintfmt+0x1e8>
  800804:	8b 7d 08             	mov    0x8(%ebp),%edi
  800807:	89 de                	mov    %ebx,%esi
  800809:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80080c:	eb 18                	jmp    800826 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80080e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800812:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800819:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80081b:	4b                   	dec    %ebx
  80081c:	eb 08                	jmp    800826 <vprintfmt+0x244>
  80081e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800821:	89 de                	mov    %ebx,%esi
  800823:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800826:	85 db                	test   %ebx,%ebx
  800828:	7f e4                	jg     80080e <vprintfmt+0x22c>
  80082a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80082d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800832:	e9 ce fd ff ff       	jmp    800605 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800837:	83 f9 01             	cmp    $0x1,%ecx
  80083a:	7e 10                	jle    80084c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 08             	lea    0x8(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 30                	mov    (%eax),%esi
  800847:	8b 78 04             	mov    0x4(%eax),%edi
  80084a:	eb 26                	jmp    800872 <vprintfmt+0x290>
	else if (lflag)
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	74 12                	je     800862 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 30                	mov    (%eax),%esi
  80085b:	89 f7                	mov    %esi,%edi
  80085d:	c1 ff 1f             	sar    $0x1f,%edi
  800860:	eb 10                	jmp    800872 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8d 50 04             	lea    0x4(%eax),%edx
  800868:	89 55 14             	mov    %edx,0x14(%ebp)
  80086b:	8b 30                	mov    (%eax),%esi
  80086d:	89 f7                	mov    %esi,%edi
  80086f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800872:	85 ff                	test   %edi,%edi
  800874:	78 0a                	js     800880 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800876:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087b:	e9 8c 00 00 00       	jmp    80090c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80088e:	f7 de                	neg    %esi
  800890:	83 d7 00             	adc    $0x0,%edi
  800893:	f7 df                	neg    %edi
			}
			base = 10;
  800895:	b8 0a 00 00 00       	mov    $0xa,%eax
  80089a:	eb 70                	jmp    80090c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80089c:	89 ca                	mov    %ecx,%edx
  80089e:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a1:	e8 c0 fc ff ff       	call   800566 <getuint>
  8008a6:	89 c6                	mov    %eax,%esi
  8008a8:	89 d7                	mov    %edx,%edi
			base = 10;
  8008aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008af:	eb 5b                	jmp    80090c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8008b1:	89 ca                	mov    %ecx,%edx
  8008b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b6:	e8 ab fc ff ff       	call   800566 <getuint>
  8008bb:	89 c6                	mov    %eax,%esi
  8008bd:	89 d7                	mov    %edx,%edi
			base = 8;
  8008bf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008c4:	eb 46                	jmp    80090c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8008c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ca:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008df:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8d 50 04             	lea    0x4(%eax),%edx
  8008e8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008eb:	8b 30                	mov    (%eax),%esi
  8008ed:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008f2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008f7:	eb 13                	jmp    80090c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f9:	89 ca                	mov    %ecx,%edx
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fe:	e8 63 fc ff ff       	call   800566 <getuint>
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d7                	mov    %edx,%edi
			base = 16;
  800907:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80090c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800910:	89 54 24 10          	mov    %edx,0x10(%esp)
  800914:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800917:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80091b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091f:	89 34 24             	mov    %esi,(%esp)
  800922:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800926:	89 da                	mov    %ebx,%edx
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	e8 6c fb ff ff       	call   80049c <printnum>
			break;
  800930:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800933:	e9 cd fc ff ff       	jmp    800605 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800938:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80093c:	89 04 24             	mov    %eax,(%esp)
  80093f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800942:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800945:	e9 bb fc ff ff       	jmp    800605 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80094a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800955:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800958:	eb 01                	jmp    80095b <vprintfmt+0x379>
  80095a:	4e                   	dec    %esi
  80095b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80095f:	75 f9                	jne    80095a <vprintfmt+0x378>
  800961:	e9 9f fc ff ff       	jmp    800605 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800966:	83 c4 4c             	add    $0x4c,%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 28             	sub    $0x28,%esp
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80097d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800981:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800984:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80098b:	85 c0                	test   %eax,%eax
  80098d:	74 30                	je     8009bf <vsnprintf+0x51>
  80098f:	85 d2                	test   %edx,%edx
  800991:	7e 33                	jle    8009c6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099a:	8b 45 10             	mov    0x10(%ebp),%eax
  80099d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a8:	c7 04 24 a0 05 80 00 	movl   $0x8005a0,(%esp)
  8009af:	e8 2e fc ff ff       	call   8005e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009bd:	eb 0c                	jmp    8009cb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c4:	eb 05                	jmp    8009cb <vsnprintf+0x5d>
  8009c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009da:	8b 45 10             	mov    0x10(%ebp),%eax
  8009dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	89 04 24             	mov    %eax,(%esp)
  8009ee:	e8 7b ff ff ff       	call   80096e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    
  8009f5:	00 00                	add    %al,(%eax)
	...

008009f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800a03:	eb 01                	jmp    800a06 <strlen+0xe>
		n++;
  800a05:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a06:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0a:	75 f9                	jne    800a05 <strlen+0xd>
		n++;
	return n;
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a14:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	eb 01                	jmp    800a1f <strnlen+0x11>
		n++;
  800a1e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	74 06                	je     800a29 <strnlen+0x1b>
  800a23:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a27:	75 f5                	jne    800a1e <strnlen+0x10>
		n++;
	return n;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a35:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a3d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a40:	42                   	inc    %edx
  800a41:	84 c9                	test   %cl,%cl
  800a43:	75 f5                	jne    800a3a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a45:	5b                   	pop    %ebx
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	53                   	push   %ebx
  800a4c:	83 ec 08             	sub    $0x8,%esp
  800a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a52:	89 1c 24             	mov    %ebx,(%esp)
  800a55:	e8 9e ff ff ff       	call   8009f8 <strlen>
	strcpy(dst + len, src);
  800a5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a61:	01 d8                	add    %ebx,%eax
  800a63:	89 04 24             	mov    %eax,(%esp)
  800a66:	e8 c0 ff ff ff       	call   800a2b <strcpy>
	return dst;
}
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	83 c4 08             	add    $0x8,%esp
  800a70:	5b                   	pop    %ebx
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a86:	eb 0c                	jmp    800a94 <strncpy+0x21>
		*dst++ = *src;
  800a88:	8a 1a                	mov    (%edx),%bl
  800a8a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8d:	80 3a 01             	cmpb   $0x1,(%edx)
  800a90:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a93:	41                   	inc    %ecx
  800a94:	39 f1                	cmp    %esi,%ecx
  800a96:	75 f0                	jne    800a88 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aaa:	85 d2                	test   %edx,%edx
  800aac:	75 0a                	jne    800ab8 <strlcpy+0x1c>
  800aae:	89 f0                	mov    %esi,%eax
  800ab0:	eb 1a                	jmp    800acc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab2:	88 18                	mov    %bl,(%eax)
  800ab4:	40                   	inc    %eax
  800ab5:	41                   	inc    %ecx
  800ab6:	eb 02                	jmp    800aba <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800aba:	4a                   	dec    %edx
  800abb:	74 0a                	je     800ac7 <strlcpy+0x2b>
  800abd:	8a 19                	mov    (%ecx),%bl
  800abf:	84 db                	test   %bl,%bl
  800ac1:	75 ef                	jne    800ab2 <strlcpy+0x16>
  800ac3:	89 c2                	mov    %eax,%edx
  800ac5:	eb 02                	jmp    800ac9 <strlcpy+0x2d>
  800ac7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ac9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800acc:	29 f0                	sub    %esi,%eax
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800adb:	eb 02                	jmp    800adf <strcmp+0xd>
		p++, q++;
  800add:	41                   	inc    %ecx
  800ade:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800adf:	8a 01                	mov    (%ecx),%al
  800ae1:	84 c0                	test   %al,%al
  800ae3:	74 04                	je     800ae9 <strcmp+0x17>
  800ae5:	3a 02                	cmp    (%edx),%al
  800ae7:	74 f4                	je     800add <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae9:	0f b6 c0             	movzbl %al,%eax
  800aec:	0f b6 12             	movzbl (%edx),%edx
  800aef:	29 d0                	sub    %edx,%eax
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	53                   	push   %ebx
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b00:	eb 03                	jmp    800b05 <strncmp+0x12>
		n--, p++, q++;
  800b02:	4a                   	dec    %edx
  800b03:	40                   	inc    %eax
  800b04:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b05:	85 d2                	test   %edx,%edx
  800b07:	74 14                	je     800b1d <strncmp+0x2a>
  800b09:	8a 18                	mov    (%eax),%bl
  800b0b:	84 db                	test   %bl,%bl
  800b0d:	74 04                	je     800b13 <strncmp+0x20>
  800b0f:	3a 19                	cmp    (%ecx),%bl
  800b11:	74 ef                	je     800b02 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b13:	0f b6 00             	movzbl (%eax),%eax
  800b16:	0f b6 11             	movzbl (%ecx),%edx
  800b19:	29 d0                	sub    %edx,%eax
  800b1b:	eb 05                	jmp    800b22 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b2e:	eb 05                	jmp    800b35 <strchr+0x10>
		if (*s == c)
  800b30:	38 ca                	cmp    %cl,%dl
  800b32:	74 0c                	je     800b40 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b34:	40                   	inc    %eax
  800b35:	8a 10                	mov    (%eax),%dl
  800b37:	84 d2                	test   %dl,%dl
  800b39:	75 f5                	jne    800b30 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b4b:	eb 05                	jmp    800b52 <strfind+0x10>
		if (*s == c)
  800b4d:	38 ca                	cmp    %cl,%dl
  800b4f:	74 07                	je     800b58 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b51:	40                   	inc    %eax
  800b52:	8a 10                	mov    (%eax),%dl
  800b54:	84 d2                	test   %dl,%dl
  800b56:	75 f5                	jne    800b4d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b69:	85 c9                	test   %ecx,%ecx
  800b6b:	74 30                	je     800b9d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b73:	75 25                	jne    800b9a <memset+0x40>
  800b75:	f6 c1 03             	test   $0x3,%cl
  800b78:	75 20                	jne    800b9a <memset+0x40>
		c &= 0xFF;
  800b7a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b7d:	89 d3                	mov    %edx,%ebx
  800b7f:	c1 e3 08             	shl    $0x8,%ebx
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	c1 e6 18             	shl    $0x18,%esi
  800b87:	89 d0                	mov    %edx,%eax
  800b89:	c1 e0 10             	shl    $0x10,%eax
  800b8c:	09 f0                	or     %esi,%eax
  800b8e:	09 d0                	or     %edx,%eax
  800b90:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b92:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b95:	fc                   	cld    
  800b96:	f3 ab                	rep stos %eax,%es:(%edi)
  800b98:	eb 03                	jmp    800b9d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b9a:	fc                   	cld    
  800b9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b9d:	89 f8                	mov    %edi,%eax
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800baf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb2:	39 c6                	cmp    %eax,%esi
  800bb4:	73 34                	jae    800bea <memmove+0x46>
  800bb6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb9:	39 d0                	cmp    %edx,%eax
  800bbb:	73 2d                	jae    800bea <memmove+0x46>
		s += n;
		d += n;
  800bbd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc0:	f6 c2 03             	test   $0x3,%dl
  800bc3:	75 1b                	jne    800be0 <memmove+0x3c>
  800bc5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bcb:	75 13                	jne    800be0 <memmove+0x3c>
  800bcd:	f6 c1 03             	test   $0x3,%cl
  800bd0:	75 0e                	jne    800be0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd2:	83 ef 04             	sub    $0x4,%edi
  800bd5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bdb:	fd                   	std    
  800bdc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bde:	eb 07                	jmp    800be7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be0:	4f                   	dec    %edi
  800be1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be4:	fd                   	std    
  800be5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800be7:	fc                   	cld    
  800be8:	eb 20                	jmp    800c0a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf0:	75 13                	jne    800c05 <memmove+0x61>
  800bf2:	a8 03                	test   $0x3,%al
  800bf4:	75 0f                	jne    800c05 <memmove+0x61>
  800bf6:	f6 c1 03             	test   $0x3,%cl
  800bf9:	75 0a                	jne    800c05 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bfb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bfe:	89 c7                	mov    %eax,%edi
  800c00:	fc                   	cld    
  800c01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c03:	eb 05                	jmp    800c0a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c05:	89 c7                	mov    %eax,%edi
  800c07:	fc                   	cld    
  800c08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c14:	8b 45 10             	mov    0x10(%ebp),%eax
  800c17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c22:	8b 45 08             	mov    0x8(%ebp),%eax
  800c25:	89 04 24             	mov    %eax,(%esp)
  800c28:	e8 77 ff ff ff       	call   800ba4 <memmove>
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	eb 16                	jmp    800c5b <memcmp+0x2c>
		if (*s1 != *s2)
  800c45:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c48:	42                   	inc    %edx
  800c49:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c4d:	38 c8                	cmp    %cl,%al
  800c4f:	74 0a                	je     800c5b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c51:	0f b6 c0             	movzbl %al,%eax
  800c54:	0f b6 c9             	movzbl %cl,%ecx
  800c57:	29 c8                	sub    %ecx,%eax
  800c59:	eb 09                	jmp    800c64 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5b:	39 da                	cmp    %ebx,%edx
  800c5d:	75 e6                	jne    800c45 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c72:	89 c2                	mov    %eax,%edx
  800c74:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c77:	eb 05                	jmp    800c7e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c79:	38 08                	cmp    %cl,(%eax)
  800c7b:	74 05                	je     800c82 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7d:	40                   	inc    %eax
  800c7e:	39 d0                	cmp    %edx,%eax
  800c80:	72 f7                	jb     800c79 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c90:	eb 01                	jmp    800c93 <strtol+0xf>
		s++;
  800c92:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c93:	8a 02                	mov    (%edx),%al
  800c95:	3c 20                	cmp    $0x20,%al
  800c97:	74 f9                	je     800c92 <strtol+0xe>
  800c99:	3c 09                	cmp    $0x9,%al
  800c9b:	74 f5                	je     800c92 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c9d:	3c 2b                	cmp    $0x2b,%al
  800c9f:	75 08                	jne    800ca9 <strtol+0x25>
		s++;
  800ca1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca7:	eb 13                	jmp    800cbc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ca9:	3c 2d                	cmp    $0x2d,%al
  800cab:	75 0a                	jne    800cb7 <strtol+0x33>
		s++, neg = 1;
  800cad:	8d 52 01             	lea    0x1(%edx),%edx
  800cb0:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb5:	eb 05                	jmp    800cbc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbc:	85 db                	test   %ebx,%ebx
  800cbe:	74 05                	je     800cc5 <strtol+0x41>
  800cc0:	83 fb 10             	cmp    $0x10,%ebx
  800cc3:	75 28                	jne    800ced <strtol+0x69>
  800cc5:	8a 02                	mov    (%edx),%al
  800cc7:	3c 30                	cmp    $0x30,%al
  800cc9:	75 10                	jne    800cdb <strtol+0x57>
  800ccb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ccf:	75 0a                	jne    800cdb <strtol+0x57>
		s += 2, base = 16;
  800cd1:	83 c2 02             	add    $0x2,%edx
  800cd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd9:	eb 12                	jmp    800ced <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cdb:	85 db                	test   %ebx,%ebx
  800cdd:	75 0e                	jne    800ced <strtol+0x69>
  800cdf:	3c 30                	cmp    $0x30,%al
  800ce1:	75 05                	jne    800ce8 <strtol+0x64>
		s++, base = 8;
  800ce3:	42                   	inc    %edx
  800ce4:	b3 08                	mov    $0x8,%bl
  800ce6:	eb 05                	jmp    800ced <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ce8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf4:	8a 0a                	mov    (%edx),%cl
  800cf6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf9:	80 fb 09             	cmp    $0x9,%bl
  800cfc:	77 08                	ja     800d06 <strtol+0x82>
			dig = *s - '0';
  800cfe:	0f be c9             	movsbl %cl,%ecx
  800d01:	83 e9 30             	sub    $0x30,%ecx
  800d04:	eb 1e                	jmp    800d24 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d06:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d09:	80 fb 19             	cmp    $0x19,%bl
  800d0c:	77 08                	ja     800d16 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d0e:	0f be c9             	movsbl %cl,%ecx
  800d11:	83 e9 57             	sub    $0x57,%ecx
  800d14:	eb 0e                	jmp    800d24 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d16:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d19:	80 fb 19             	cmp    $0x19,%bl
  800d1c:	77 12                	ja     800d30 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d1e:	0f be c9             	movsbl %cl,%ecx
  800d21:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d24:	39 f1                	cmp    %esi,%ecx
  800d26:	7d 0c                	jge    800d34 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d28:	42                   	inc    %edx
  800d29:	0f af c6             	imul   %esi,%eax
  800d2c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d2e:	eb c4                	jmp    800cf4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d30:	89 c1                	mov    %eax,%ecx
  800d32:	eb 02                	jmp    800d36 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d34:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d3a:	74 05                	je     800d41 <strtol+0xbd>
		*endptr = (char *) s;
  800d3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d3f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d41:	85 ff                	test   %edi,%edi
  800d43:	74 04                	je     800d49 <strtol+0xc5>
  800d45:	89 c8                	mov    %ecx,%eax
  800d47:	f7 d8                	neg    %eax
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    
	...

00800d50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 c3                	mov    %eax,%ebx
  800d63:	89 c7                	mov    %eax,%edi
  800d65:	89 c6                	mov    %eax,%esi
  800d67:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	ba 00 00 00 00       	mov    $0x0,%edx
  800d79:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7e:	89 d1                	mov    %edx,%ecx
  800d80:	89 d3                	mov    %edx,%ebx
  800d82:	89 d7                	mov    %edx,%edi
  800d84:	89 d6                	mov    %edx,%esi
  800d86:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 cb                	mov    %ecx,%ebx
  800da5:	89 cf                	mov    %ecx,%edi
  800da7:	89 ce                	mov    %ecx,%esi
  800da9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 28                	jle    800dd7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dba:	00 
  800dbb:	c7 44 24 08 83 30 80 	movl   $0x803083,0x8(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dca:	00 
  800dcb:	c7 04 24 a0 30 80 00 	movl   $0x8030a0,(%esp)
  800dd2:	e8 b1 f5 ff ff       	call   800388 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dd7:	83 c4 2c             	add    $0x2c,%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dea:	b8 02 00 00 00       	mov    $0x2,%eax
  800def:	89 d1                	mov    %edx,%ecx
  800df1:	89 d3                	mov    %edx,%ebx
  800df3:	89 d7                	mov    %edx,%edi
  800df5:	89 d6                	mov    %edx,%esi
  800df7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <sys_yield>:

void
sys_yield(void)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e04:	ba 00 00 00 00       	mov    $0x0,%edx
  800e09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e0e:	89 d1                	mov    %edx,%ecx
  800e10:	89 d3                	mov    %edx,%ebx
  800e12:	89 d7                	mov    %edx,%edi
  800e14:	89 d6                	mov    %edx,%esi
  800e16:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	57                   	push   %edi
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	be 00 00 00 00       	mov    $0x0,%esi
  800e2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800e30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 f7                	mov    %esi,%edi
  800e3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	7e 28                	jle    800e69 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e45:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 08 83 30 80 	movl   $0x803083,0x8(%esp)
  800e54:	00 
  800e55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5c:	00 
  800e5d:	c7 04 24 a0 30 80 00 	movl   $0x8030a0,(%esp)
  800e64:	e8 1f f5 ff ff       	call   800388 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e69:	83 c4 2c             	add    $0x2c,%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
  800e77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e7f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e90:	85 c0                	test   %eax,%eax
  800e92:	7e 28                	jle    800ebc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e98:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 08 83 30 80 	movl   $0x803083,0x8(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eaf:	00 
  800eb0:	c7 04 24 a0 30 80 00 	movl   $0x8030a0,(%esp)
  800eb7:	e8 cc f4 ff ff       	call   800388 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ebc:	83 c4 2c             	add    $0x2c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
  800eca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 df                	mov    %ebx,%edi
  800edf:	89 de                	mov    %ebx,%esi
  800ee1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 28                	jle    800f0f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eeb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 08 83 30 80 	movl   $0x803083,0x8(%esp)
  800efa:	00 
  800efb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f02:	00 
  800f03:	c7 04 24 a0 30 80 00 	movl   $0x8030a0,(%esp)
  800f0a:	e8 79 f4 ff ff       	call   800388 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f0f:	83 c4 2c             	add    $0x2c,%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f25:	b8 08 00 00 00       	mov    $0x8,%eax
  800f2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	89 df                	mov    %ebx,%edi
  800f32:	89 de                	mov    %ebx,%esi
  800f34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f36:	85 c0                	test   %eax,%eax
  800f38:	7e 28                	jle    800f62 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f45:	00 
  800f46:	c7 44 24 08 83 30 80 	movl   $0x803083,0x8(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f55:	00 
  800f56:	c7 04 24 a0 30 80 00 	movl   $0x8030a0,(%esp)
  800f5d:	e8 26 f4 ff ff       	call   800388 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f62:	83 c4 2c             	add    $0x2c,%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f78:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 df                	mov    %ebx,%edi
  800f85:	89 de                	mov    %ebx,%esi
  800f87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 28                	jle    800fb5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f91:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f98:	00 
  800f99:	c7 44 24 08 83 30 80 	movl   $0x803083,0x8(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa8:	00 
  800fa9:	c7 04 24 a0 30 80 00 	movl   $0x8030a0,(%esp)
  800fb0:	e8 d3 f3 ff ff       	call   800388 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fb5:	83 c4 2c             	add    $0x2c,%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	57                   	push   %edi
  800fc1:	56                   	push   %esi
  800fc2:	53                   	push   %ebx
  800fc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	89 df                	mov    %ebx,%edi
  800fd8:	89 de                	mov    %ebx,%esi
  800fda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7e 28                	jle    801008 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 83 30 80 	movl   $0x803083,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 a0 30 80 00 	movl   $0x8030a0,(%esp)
  801003:	e8 80 f3 ff ff       	call   800388 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801008:	83 c4 2c             	add    $0x2c,%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801016:	be 00 00 00 00       	mov    $0x0,%esi
  80101b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801020:	8b 7d 14             	mov    0x14(%ebp),%edi
  801023:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801026:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801029:	8b 55 08             	mov    0x8(%ebp),%edx
  80102c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801041:	b8 0d 00 00 00       	mov    $0xd,%eax
  801046:	8b 55 08             	mov    0x8(%ebp),%edx
  801049:	89 cb                	mov    %ecx,%ebx
  80104b:	89 cf                	mov    %ecx,%edi
  80104d:	89 ce                	mov    %ecx,%esi
  80104f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801051:	85 c0                	test   %eax,%eax
  801053:	7e 28                	jle    80107d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801055:	89 44 24 10          	mov    %eax,0x10(%esp)
  801059:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801060:	00 
  801061:	c7 44 24 08 83 30 80 	movl   $0x803083,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 a0 30 80 00 	movl   $0x8030a0,(%esp)
  801078:	e8 0b f3 ff ff       	call   800388 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80107d:	83 c4 2c             	add    $0x2c,%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108b:	ba 00 00 00 00       	mov    $0x0,%edx
  801090:	b8 0e 00 00 00       	mov    $0xe,%eax
  801095:	89 d1                	mov    %edx,%ecx
  801097:	89 d3                	mov    %edx,%ebx
  801099:	89 d7                	mov    %edx,%edi
  80109b:	89 d6                	mov    %edx,%esi
  80109d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80109f:	5b                   	pop    %ebx
  8010a0:	5e                   	pop    %esi
  8010a1:	5f                   	pop    %edi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010af:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ba:	89 df                	mov    %ebx,%edi
  8010bc:	89 de                	mov    %ebx,%esi
  8010be:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5f                   	pop    %edi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d0:	b8 10 00 00 00       	mov    $0x10,%eax
  8010d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010db:	89 df                	mov    %ebx,%edi
  8010dd:	89 de                	mov    %ebx,%esi
  8010df:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
	...

008010e8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 24             	sub    $0x24,%esp
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010f2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  8010f4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010f8:	74 2d                	je     801127 <pgfault+0x3f>
  8010fa:	89 d8                	mov    %ebx,%eax
  8010fc:	c1 e8 16             	shr    $0x16,%eax
  8010ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801106:	a8 01                	test   $0x1,%al
  801108:	74 1d                	je     801127 <pgfault+0x3f>
  80110a:	89 d8                	mov    %ebx,%eax
  80110c:	c1 e8 0c             	shr    $0xc,%eax
  80110f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801116:	f6 c2 01             	test   $0x1,%dl
  801119:	74 0c                	je     801127 <pgfault+0x3f>
  80111b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801122:	f6 c4 08             	test   $0x8,%ah
  801125:	75 1c                	jne    801143 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  801127:	c7 44 24 08 b0 30 80 	movl   $0x8030b0,0x8(%esp)
  80112e:	00 
  80112f:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  80113e:	e8 45 f2 ff ff       	call   800388 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  801143:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  801149:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801160:	e8 b8 fc ff ff       	call   800e1d <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  801165:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80116c:	00 
  80116d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801171:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801178:	e8 91 fa ff ff       	call   800c0e <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  80117d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801184:	00 
  801185:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801189:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801190:	00 
  801191:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801198:	00 
  801199:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a0:	e8 cc fc ff ff       	call   800e71 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  8011a5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011ac:	00 
  8011ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b4:	e8 0b fd ff ff       	call   800ec4 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  8011b9:	83 c4 24             	add    $0x24,%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	57                   	push   %edi
  8011c3:	56                   	push   %esi
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8011c8:	c7 04 24 e8 10 80 00 	movl   $0x8010e8,(%esp)
  8011cf:	e8 e0 15 00 00       	call   8027b4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8011d4:	ba 07 00 00 00       	mov    $0x7,%edx
  8011d9:	89 d0                	mov    %edx,%eax
  8011db:	cd 30                	int    $0x30
  8011dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011e0:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	79 20                	jns    801206 <fork+0x47>
		panic("sys_exofork: %e", envid);
  8011e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ea:	c7 44 24 08 fe 30 80 	movl   $0x8030fe,0x8(%esp)
  8011f1:	00 
  8011f2:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  8011f9:	00 
  8011fa:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  801201:	e8 82 f1 ff ff       	call   800388 <_panic>
	if (envid == 0)
  801206:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80120a:	75 25                	jne    801231 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80120c:	e8 ce fb ff ff       	call   800ddf <sys_getenvid>
  801211:	25 ff 03 00 00       	and    $0x3ff,%eax
  801216:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80121d:	c1 e0 07             	shl    $0x7,%eax
  801220:	29 d0                	sub    %edx,%eax
  801222:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801227:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80122c:	e9 43 02 00 00       	jmp    801474 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  801231:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  801236:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80123c:	0f 84 85 01 00 00    	je     8013c7 <fork+0x208>
  801242:	89 d8                	mov    %ebx,%eax
  801244:	c1 e8 16             	shr    $0x16,%eax
  801247:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80124e:	a8 01                	test   $0x1,%al
  801250:	0f 84 5f 01 00 00    	je     8013b5 <fork+0x1f6>
  801256:	89 d8                	mov    %ebx,%eax
  801258:	c1 e8 0c             	shr    $0xc,%eax
  80125b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801262:	f6 c2 01             	test   $0x1,%dl
  801265:	0f 84 4a 01 00 00    	je     8013b5 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  80126b:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  80126d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801274:	f6 c6 04             	test   $0x4,%dh
  801277:	74 50                	je     8012c9 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  801279:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801280:	25 07 0e 00 00       	and    $0xe07,%eax
  801285:	89 44 24 10          	mov    %eax,0x10(%esp)
  801289:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80128d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801291:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801295:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80129c:	e8 d0 fb ff ff       	call   800e71 <sys_page_map>
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	0f 89 0c 01 00 00    	jns    8013b5 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  8012a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ad:	c7 44 24 08 0e 31 80 	movl   $0x80310e,0x8(%esp)
  8012b4:	00 
  8012b5:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8012bc:	00 
  8012bd:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  8012c4:	e8 bf f0 ff ff       	call   800388 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  8012c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d0:	f6 c2 02             	test   $0x2,%dl
  8012d3:	75 10                	jne    8012e5 <fork+0x126>
  8012d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012dc:	f6 c4 08             	test   $0x8,%ah
  8012df:	0f 84 8c 00 00 00    	je     801371 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  8012e5:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012ec:	00 
  8012ed:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012f1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801300:	e8 6c fb ff ff       	call   800e71 <sys_page_map>
  801305:	85 c0                	test   %eax,%eax
  801307:	79 20                	jns    801329 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801309:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130d:	c7 44 24 08 0e 31 80 	movl   $0x80310e,0x8(%esp)
  801314:	00 
  801315:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80131c:	00 
  80131d:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  801324:	e8 5f f0 ff ff       	call   800388 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801329:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801330:	00 
  801331:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801335:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80133c:	00 
  80133d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801341:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801348:	e8 24 fb ff ff       	call   800e71 <sys_page_map>
  80134d:	85 c0                	test   %eax,%eax
  80134f:	79 64                	jns    8013b5 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801351:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801355:	c7 44 24 08 0e 31 80 	movl   $0x80310e,0x8(%esp)
  80135c:	00 
  80135d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801364:	00 
  801365:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  80136c:	e8 17 f0 ff ff       	call   800388 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  801371:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801378:	00 
  801379:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80137d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801381:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801385:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80138c:	e8 e0 fa ff ff       	call   800e71 <sys_page_map>
  801391:	85 c0                	test   %eax,%eax
  801393:	79 20                	jns    8013b5 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801395:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801399:	c7 44 24 08 0e 31 80 	movl   $0x80310e,0x8(%esp)
  8013a0:	00 
  8013a1:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8013a8:	00 
  8013a9:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  8013b0:	e8 d3 ef ff ff       	call   800388 <_panic>
  8013b5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  8013bb:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8013c1:	0f 85 6f fe ff ff    	jne    801236 <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  8013c7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013ce:	00 
  8013cf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013d6:	ee 
  8013d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013da:	89 04 24             	mov    %eax,(%esp)
  8013dd:	e8 3b fa ff ff       	call   800e1d <sys_page_alloc>
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	79 20                	jns    801406 <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  8013e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ea:	c7 44 24 08 20 31 80 	movl   $0x803120,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  801401:	e8 82 ef ff ff       	call   800388 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801406:	c7 44 24 04 00 28 80 	movl   $0x802800,0x4(%esp)
  80140d:	00 
  80140e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801411:	89 04 24             	mov    %eax,(%esp)
  801414:	e8 a4 fb ff ff       	call   800fbd <sys_env_set_pgfault_upcall>
  801419:	85 c0                	test   %eax,%eax
  80141b:	79 20                	jns    80143d <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  80141d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801421:	c7 44 24 08 d4 30 80 	movl   $0x8030d4,0x8(%esp)
  801428:	00 
  801429:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801430:	00 
  801431:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  801438:	e8 4b ef ff ff       	call   800388 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80143d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801444:	00 
  801445:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801448:	89 04 24             	mov    %eax,(%esp)
  80144b:	e8 c7 fa ff ff       	call   800f17 <sys_env_set_status>
  801450:	85 c0                	test   %eax,%eax
  801452:	79 20                	jns    801474 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801454:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801458:	c7 44 24 08 33 31 80 	movl   $0x803133,0x8(%esp)
  80145f:	00 
  801460:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801467:	00 
  801468:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  80146f:	e8 14 ef ff ff       	call   800388 <_panic>

	return envid;
	// panic("fork not implemented");
}
  801474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801477:	83 c4 3c             	add    $0x3c,%esp
  80147a:	5b                   	pop    %ebx
  80147b:	5e                   	pop    %esi
  80147c:	5f                   	pop    %edi
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    

0080147f <sfork>:

// Challenge!
int
sfork(void)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801485:	c7 44 24 08 4a 31 80 	movl   $0x80314a,0x8(%esp)
  80148c:	00 
  80148d:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801494:	00 
  801495:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  80149c:	e8 e7 ee ff ff       	call   800388 <_panic>
  8014a1:	00 00                	add    %al,(%eax)
	...

008014a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8014af:	c1 e8 0c             	shr    $0xc,%eax
}
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    

008014b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bd:	89 04 24             	mov    %eax,(%esp)
  8014c0:	e8 df ff ff ff       	call   8014a4 <fd2num>
  8014c5:	c1 e0 0c             	shl    $0xc,%eax
  8014c8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	53                   	push   %ebx
  8014d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014d6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014db:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	c1 ea 16             	shr    $0x16,%edx
  8014e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e9:	f6 c2 01             	test   $0x1,%dl
  8014ec:	74 11                	je     8014ff <fd_alloc+0x30>
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	c1 ea 0c             	shr    $0xc,%edx
  8014f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014fa:	f6 c2 01             	test   $0x1,%dl
  8014fd:	75 09                	jne    801508 <fd_alloc+0x39>
			*fd_store = fd;
  8014ff:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801501:	b8 00 00 00 00       	mov    $0x0,%eax
  801506:	eb 17                	jmp    80151f <fd_alloc+0x50>
  801508:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80150d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801512:	75 c7                	jne    8014db <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801514:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80151a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80151f:	5b                   	pop    %ebx
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801528:	83 f8 1f             	cmp    $0x1f,%eax
  80152b:	77 36                	ja     801563 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80152d:	c1 e0 0c             	shl    $0xc,%eax
  801530:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801535:	89 c2                	mov    %eax,%edx
  801537:	c1 ea 16             	shr    $0x16,%edx
  80153a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801541:	f6 c2 01             	test   $0x1,%dl
  801544:	74 24                	je     80156a <fd_lookup+0x48>
  801546:	89 c2                	mov    %eax,%edx
  801548:	c1 ea 0c             	shr    $0xc,%edx
  80154b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801552:	f6 c2 01             	test   $0x1,%dl
  801555:	74 1a                	je     801571 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801557:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155a:	89 02                	mov    %eax,(%edx)
	return 0;
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
  801561:	eb 13                	jmp    801576 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801563:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801568:	eb 0c                	jmp    801576 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80156a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156f:	eb 05                	jmp    801576 <fd_lookup+0x54>
  801571:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801576:	5d                   	pop    %ebp
  801577:	c3                   	ret    

00801578 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 14             	sub    $0x14,%esp
  80157f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801585:	ba 00 00 00 00       	mov    $0x0,%edx
  80158a:	eb 0e                	jmp    80159a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80158c:	39 08                	cmp    %ecx,(%eax)
  80158e:	75 09                	jne    801599 <dev_lookup+0x21>
			*dev = devtab[i];
  801590:	89 03                	mov    %eax,(%ebx)
			return 0;
  801592:	b8 00 00 00 00       	mov    $0x0,%eax
  801597:	eb 33                	jmp    8015cc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801599:	42                   	inc    %edx
  80159a:	8b 04 95 e0 31 80 00 	mov    0x8031e0(,%edx,4),%eax
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	75 e7                	jne    80158c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015a5:	a1 08 50 80 00       	mov    0x805008,%eax
  8015aa:	8b 40 48             	mov    0x48(%eax),%eax
  8015ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b5:	c7 04 24 60 31 80 00 	movl   $0x803160,(%esp)
  8015bc:	e8 bf ee ff ff       	call   800480 <cprintf>
	*dev = 0;
  8015c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015cc:	83 c4 14             	add    $0x14,%esp
  8015cf:	5b                   	pop    %ebx
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    

008015d2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 30             	sub    $0x30,%esp
  8015da:	8b 75 08             	mov    0x8(%ebp),%esi
  8015dd:	8a 45 0c             	mov    0xc(%ebp),%al
  8015e0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015e3:	89 34 24             	mov    %esi,(%esp)
  8015e6:	e8 b9 fe ff ff       	call   8014a4 <fd2num>
  8015eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 28 ff ff ff       	call   801522 <fd_lookup>
  8015fa:	89 c3                	mov    %eax,%ebx
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 05                	js     801605 <fd_close+0x33>
	    || fd != fd2)
  801600:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801603:	74 0d                	je     801612 <fd_close+0x40>
		return (must_exist ? r : 0);
  801605:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801609:	75 46                	jne    801651 <fd_close+0x7f>
  80160b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801610:	eb 3f                	jmp    801651 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801612:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801615:	89 44 24 04          	mov    %eax,0x4(%esp)
  801619:	8b 06                	mov    (%esi),%eax
  80161b:	89 04 24             	mov    %eax,(%esp)
  80161e:	e8 55 ff ff ff       	call   801578 <dev_lookup>
  801623:	89 c3                	mov    %eax,%ebx
  801625:	85 c0                	test   %eax,%eax
  801627:	78 18                	js     801641 <fd_close+0x6f>
		if (dev->dev_close)
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	8b 40 10             	mov    0x10(%eax),%eax
  80162f:	85 c0                	test   %eax,%eax
  801631:	74 09                	je     80163c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801633:	89 34 24             	mov    %esi,(%esp)
  801636:	ff d0                	call   *%eax
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	eb 05                	jmp    801641 <fd_close+0x6f>
		else
			r = 0;
  80163c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801641:	89 74 24 04          	mov    %esi,0x4(%esp)
  801645:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164c:	e8 73 f8 ff ff       	call   800ec4 <sys_page_unmap>
	return r;
}
  801651:	89 d8                	mov    %ebx,%eax
  801653:	83 c4 30             	add    $0x30,%esp
  801656:	5b                   	pop    %ebx
  801657:	5e                   	pop    %esi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801663:	89 44 24 04          	mov    %eax,0x4(%esp)
  801667:	8b 45 08             	mov    0x8(%ebp),%eax
  80166a:	89 04 24             	mov    %eax,(%esp)
  80166d:	e8 b0 fe ff ff       	call   801522 <fd_lookup>
  801672:	85 c0                	test   %eax,%eax
  801674:	78 13                	js     801689 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801676:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80167d:	00 
  80167e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801681:	89 04 24             	mov    %eax,(%esp)
  801684:	e8 49 ff ff ff       	call   8015d2 <fd_close>
}
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <close_all>:

void
close_all(void)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801692:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801697:	89 1c 24             	mov    %ebx,(%esp)
  80169a:	e8 bb ff ff ff       	call   80165a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80169f:	43                   	inc    %ebx
  8016a0:	83 fb 20             	cmp    $0x20,%ebx
  8016a3:	75 f2                	jne    801697 <close_all+0xc>
		close(i);
}
  8016a5:	83 c4 14             	add    $0x14,%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	57                   	push   %edi
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 4c             	sub    $0x4c,%esp
  8016b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016be:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c1:	89 04 24             	mov    %eax,(%esp)
  8016c4:	e8 59 fe ff ff       	call   801522 <fd_lookup>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	0f 88 e3 00 00 00    	js     8017b6 <dup+0x10b>
		return r;
	close(newfdnum);
  8016d3:	89 3c 24             	mov    %edi,(%esp)
  8016d6:	e8 7f ff ff ff       	call   80165a <close>

	newfd = INDEX2FD(newfdnum);
  8016db:	89 fe                	mov    %edi,%esi
  8016dd:	c1 e6 0c             	shl    $0xc,%esi
  8016e0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8016e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e9:	89 04 24             	mov    %eax,(%esp)
  8016ec:	e8 c3 fd ff ff       	call   8014b4 <fd2data>
  8016f1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016f3:	89 34 24             	mov    %esi,(%esp)
  8016f6:	e8 b9 fd ff ff       	call   8014b4 <fd2data>
  8016fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016fe:	89 d8                	mov    %ebx,%eax
  801700:	c1 e8 16             	shr    $0x16,%eax
  801703:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80170a:	a8 01                	test   $0x1,%al
  80170c:	74 46                	je     801754 <dup+0xa9>
  80170e:	89 d8                	mov    %ebx,%eax
  801710:	c1 e8 0c             	shr    $0xc,%eax
  801713:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80171a:	f6 c2 01             	test   $0x1,%dl
  80171d:	74 35                	je     801754 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80171f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801726:	25 07 0e 00 00       	and    $0xe07,%eax
  80172b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80172f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801732:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801736:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80173d:	00 
  80173e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801742:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801749:	e8 23 f7 ff ff       	call   800e71 <sys_page_map>
  80174e:	89 c3                	mov    %eax,%ebx
  801750:	85 c0                	test   %eax,%eax
  801752:	78 3b                	js     80178f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801754:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801757:	89 c2                	mov    %eax,%edx
  801759:	c1 ea 0c             	shr    $0xc,%edx
  80175c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801763:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801769:	89 54 24 10          	mov    %edx,0x10(%esp)
  80176d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801771:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801778:	00 
  801779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801784:	e8 e8 f6 ff ff       	call   800e71 <sys_page_map>
  801789:	89 c3                	mov    %eax,%ebx
  80178b:	85 c0                	test   %eax,%eax
  80178d:	79 25                	jns    8017b4 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80178f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801793:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179a:	e8 25 f7 ff ff       	call   800ec4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80179f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ad:	e8 12 f7 ff ff       	call   800ec4 <sys_page_unmap>
	return r;
  8017b2:	eb 02                	jmp    8017b6 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017b4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017b6:	89 d8                	mov    %ebx,%eax
  8017b8:	83 c4 4c             	add    $0x4c,%esp
  8017bb:	5b                   	pop    %ebx
  8017bc:	5e                   	pop    %esi
  8017bd:	5f                   	pop    %edi
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 24             	sub    $0x24,%esp
  8017c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d1:	89 1c 24             	mov    %ebx,(%esp)
  8017d4:	e8 49 fd ff ff       	call   801522 <fd_lookup>
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 6d                	js     80184a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e7:	8b 00                	mov    (%eax),%eax
  8017e9:	89 04 24             	mov    %eax,(%esp)
  8017ec:	e8 87 fd ff ff       	call   801578 <dev_lookup>
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 55                	js     80184a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f8:	8b 50 08             	mov    0x8(%eax),%edx
  8017fb:	83 e2 03             	and    $0x3,%edx
  8017fe:	83 fa 01             	cmp    $0x1,%edx
  801801:	75 23                	jne    801826 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801803:	a1 08 50 80 00       	mov    0x805008,%eax
  801808:	8b 40 48             	mov    0x48(%eax),%eax
  80180b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80180f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801813:	c7 04 24 a4 31 80 00 	movl   $0x8031a4,(%esp)
  80181a:	e8 61 ec ff ff       	call   800480 <cprintf>
		return -E_INVAL;
  80181f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801824:	eb 24                	jmp    80184a <read+0x8a>
	}
	if (!dev->dev_read)
  801826:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801829:	8b 52 08             	mov    0x8(%edx),%edx
  80182c:	85 d2                	test   %edx,%edx
  80182e:	74 15                	je     801845 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801830:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801833:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80183e:	89 04 24             	mov    %eax,(%esp)
  801841:	ff d2                	call   *%edx
  801843:	eb 05                	jmp    80184a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801845:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80184a:	83 c4 24             	add    $0x24,%esp
  80184d:	5b                   	pop    %ebx
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	57                   	push   %edi
  801854:	56                   	push   %esi
  801855:	53                   	push   %ebx
  801856:	83 ec 1c             	sub    $0x1c,%esp
  801859:	8b 7d 08             	mov    0x8(%ebp),%edi
  80185c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80185f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801864:	eb 23                	jmp    801889 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801866:	89 f0                	mov    %esi,%eax
  801868:	29 d8                	sub    %ebx,%eax
  80186a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80186e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801871:	01 d8                	add    %ebx,%eax
  801873:	89 44 24 04          	mov    %eax,0x4(%esp)
  801877:	89 3c 24             	mov    %edi,(%esp)
  80187a:	e8 41 ff ff ff       	call   8017c0 <read>
		if (m < 0)
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 10                	js     801893 <readn+0x43>
			return m;
		if (m == 0)
  801883:	85 c0                	test   %eax,%eax
  801885:	74 0a                	je     801891 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801887:	01 c3                	add    %eax,%ebx
  801889:	39 f3                	cmp    %esi,%ebx
  80188b:	72 d9                	jb     801866 <readn+0x16>
  80188d:	89 d8                	mov    %ebx,%eax
  80188f:	eb 02                	jmp    801893 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801891:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801893:	83 c4 1c             	add    $0x1c,%esp
  801896:	5b                   	pop    %ebx
  801897:	5e                   	pop    %esi
  801898:	5f                   	pop    %edi
  801899:	5d                   	pop    %ebp
  80189a:	c3                   	ret    

0080189b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	53                   	push   %ebx
  80189f:	83 ec 24             	sub    $0x24,%esp
  8018a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ac:	89 1c 24             	mov    %ebx,(%esp)
  8018af:	e8 6e fc ff ff       	call   801522 <fd_lookup>
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 68                	js     801920 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c2:	8b 00                	mov    (%eax),%eax
  8018c4:	89 04 24             	mov    %eax,(%esp)
  8018c7:	e8 ac fc ff ff       	call   801578 <dev_lookup>
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 50                	js     801920 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018d7:	75 23                	jne    8018fc <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018d9:	a1 08 50 80 00       	mov    0x805008,%eax
  8018de:	8b 40 48             	mov    0x48(%eax),%eax
  8018e1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e9:	c7 04 24 c0 31 80 00 	movl   $0x8031c0,(%esp)
  8018f0:	e8 8b eb ff ff       	call   800480 <cprintf>
		return -E_INVAL;
  8018f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018fa:	eb 24                	jmp    801920 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801902:	85 d2                	test   %edx,%edx
  801904:	74 15                	je     80191b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801906:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801909:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80190d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801910:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801914:	89 04 24             	mov    %eax,(%esp)
  801917:	ff d2                	call   *%edx
  801919:	eb 05                	jmp    801920 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80191b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801920:	83 c4 24             	add    $0x24,%esp
  801923:	5b                   	pop    %ebx
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <seek>:

int
seek(int fdnum, off_t offset)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80192c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80192f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	89 04 24             	mov    %eax,(%esp)
  801939:	e8 e4 fb ff ff       	call   801522 <fd_lookup>
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 0e                	js     801950 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801942:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801945:	8b 55 0c             	mov    0xc(%ebp),%edx
  801948:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	53                   	push   %ebx
  801956:	83 ec 24             	sub    $0x24,%esp
  801959:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801963:	89 1c 24             	mov    %ebx,(%esp)
  801966:	e8 b7 fb ff ff       	call   801522 <fd_lookup>
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 61                	js     8019d0 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801972:	89 44 24 04          	mov    %eax,0x4(%esp)
  801976:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801979:	8b 00                	mov    (%eax),%eax
  80197b:	89 04 24             	mov    %eax,(%esp)
  80197e:	e8 f5 fb ff ff       	call   801578 <dev_lookup>
  801983:	85 c0                	test   %eax,%eax
  801985:	78 49                	js     8019d0 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80198e:	75 23                	jne    8019b3 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801990:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801995:	8b 40 48             	mov    0x48(%eax),%eax
  801998:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80199c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a0:	c7 04 24 80 31 80 00 	movl   $0x803180,(%esp)
  8019a7:	e8 d4 ea ff ff       	call   800480 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019b1:	eb 1d                	jmp    8019d0 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8019b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b6:	8b 52 18             	mov    0x18(%edx),%edx
  8019b9:	85 d2                	test   %edx,%edx
  8019bb:	74 0e                	je     8019cb <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019c4:	89 04 24             	mov    %eax,(%esp)
  8019c7:	ff d2                	call   *%edx
  8019c9:	eb 05                	jmp    8019d0 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019d0:	83 c4 24             	add    $0x24,%esp
  8019d3:	5b                   	pop    %ebx
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 24             	sub    $0x24,%esp
  8019dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ea:	89 04 24             	mov    %eax,(%esp)
  8019ed:	e8 30 fb ff ff       	call   801522 <fd_lookup>
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 52                	js     801a48 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a00:	8b 00                	mov    (%eax),%eax
  801a02:	89 04 24             	mov    %eax,(%esp)
  801a05:	e8 6e fb ff ff       	call   801578 <dev_lookup>
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 3a                	js     801a48 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a11:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a15:	74 2c                	je     801a43 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a17:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a1a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a21:	00 00 00 
	stat->st_isdir = 0;
  801a24:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a2b:	00 00 00 
	stat->st_dev = dev;
  801a2e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a34:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a3b:	89 14 24             	mov    %edx,(%esp)
  801a3e:	ff 50 14             	call   *0x14(%eax)
  801a41:	eb 05                	jmp    801a48 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a43:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a48:	83 c4 24             	add    $0x24,%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    

00801a4e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	56                   	push   %esi
  801a52:	53                   	push   %ebx
  801a53:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a5d:	00 
  801a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a61:	89 04 24             	mov    %eax,(%esp)
  801a64:	e8 2a 02 00 00       	call   801c93 <open>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 1b                	js     801a8a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a76:	89 1c 24             	mov    %ebx,(%esp)
  801a79:	e8 58 ff ff ff       	call   8019d6 <fstat>
  801a7e:	89 c6                	mov    %eax,%esi
	close(fd);
  801a80:	89 1c 24             	mov    %ebx,(%esp)
  801a83:	e8 d2 fb ff ff       	call   80165a <close>
	return r;
  801a88:	89 f3                	mov    %esi,%ebx
}
  801a8a:	89 d8                	mov    %ebx,%eax
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    
	...

00801a94 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
  801a99:	83 ec 10             	sub    $0x10,%esp
  801a9c:	89 c3                	mov    %eax,%ebx
  801a9e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801aa0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801aa7:	75 11                	jne    801aba <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ab0:	e8 66 0e 00 00       	call   80291b <ipc_find_env>
  801ab5:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aba:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ac1:	00 
  801ac2:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ac9:	00 
  801aca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ace:	a1 00 50 80 00       	mov    0x805000,%eax
  801ad3:	89 04 24             	mov    %eax,(%esp)
  801ad6:	e8 bd 0d 00 00       	call   802898 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801adb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ae2:	00 
  801ae3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aee:	e8 35 0d 00 00       	call   802828 <ipc_recv>
}
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b00:	8b 45 08             	mov    0x8(%ebp),%eax
  801b03:	8b 40 0c             	mov    0xc(%eax),%eax
  801b06:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0e:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b13:	ba 00 00 00 00       	mov    $0x0,%edx
  801b18:	b8 02 00 00 00       	mov    $0x2,%eax
  801b1d:	e8 72 ff ff ff       	call   801a94 <fsipc>
}
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b30:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b35:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3a:	b8 06 00 00 00       	mov    $0x6,%eax
  801b3f:	e8 50 ff ff ff       	call   801a94 <fsipc>
}
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 14             	sub    $0x14,%esp
  801b4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	8b 40 0c             	mov    0xc(%eax),%eax
  801b56:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b60:	b8 05 00 00 00       	mov    $0x5,%eax
  801b65:	e8 2a ff ff ff       	call   801a94 <fsipc>
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	78 2b                	js     801b99 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b6e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b75:	00 
  801b76:	89 1c 24             	mov    %ebx,(%esp)
  801b79:	e8 ad ee ff ff       	call   800a2b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b7e:	a1 80 60 80 00       	mov    0x806080,%eax
  801b83:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b89:	a1 84 60 80 00       	mov    0x806084,%eax
  801b8e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b99:	83 c4 14             	add    $0x14,%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 18             	sub    $0x18,%esp
  801ba5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  801bab:	8b 52 0c             	mov    0xc(%edx),%edx
  801bae:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bb4:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801bb9:	89 c2                	mov    %eax,%edx
  801bbb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bc0:	76 05                	jbe    801bc7 <devfile_write+0x28>
  801bc2:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801bc7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd2:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801bd9:	e8 30 f0 ff ff       	call   800c0e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801bde:	ba 00 00 00 00       	mov    $0x0,%edx
  801be3:	b8 04 00 00 00       	mov    $0x4,%eax
  801be8:	e8 a7 fe ff ff       	call   801a94 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801bed:	c9                   	leave  
  801bee:	c3                   	ret    

00801bef <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 10             	sub    $0x10,%esp
  801bf7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	8b 40 0c             	mov    0xc(%eax),%eax
  801c00:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c05:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c10:	b8 03 00 00 00       	mov    $0x3,%eax
  801c15:	e8 7a fe ff ff       	call   801a94 <fsipc>
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	78 6a                	js     801c8a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c20:	39 c6                	cmp    %eax,%esi
  801c22:	73 24                	jae    801c48 <devfile_read+0x59>
  801c24:	c7 44 24 0c f4 31 80 	movl   $0x8031f4,0xc(%esp)
  801c2b:	00 
  801c2c:	c7 44 24 08 fb 31 80 	movl   $0x8031fb,0x8(%esp)
  801c33:	00 
  801c34:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c3b:	00 
  801c3c:	c7 04 24 10 32 80 00 	movl   $0x803210,(%esp)
  801c43:	e8 40 e7 ff ff       	call   800388 <_panic>
	assert(r <= PGSIZE);
  801c48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c4d:	7e 24                	jle    801c73 <devfile_read+0x84>
  801c4f:	c7 44 24 0c 1b 32 80 	movl   $0x80321b,0xc(%esp)
  801c56:	00 
  801c57:	c7 44 24 08 fb 31 80 	movl   $0x8031fb,0x8(%esp)
  801c5e:	00 
  801c5f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c66:	00 
  801c67:	c7 04 24 10 32 80 00 	movl   $0x803210,(%esp)
  801c6e:	e8 15 e7 ff ff       	call   800388 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c73:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c77:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c7e:	00 
  801c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c82:	89 04 24             	mov    %eax,(%esp)
  801c85:	e8 1a ef ff ff       	call   800ba4 <memmove>
	return r;
}
  801c8a:	89 d8                	mov    %ebx,%eax
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	83 ec 20             	sub    $0x20,%esp
  801c9b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c9e:	89 34 24             	mov    %esi,(%esp)
  801ca1:	e8 52 ed ff ff       	call   8009f8 <strlen>
  801ca6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cab:	7f 60                	jg     801d0d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb0:	89 04 24             	mov    %eax,(%esp)
  801cb3:	e8 17 f8 ff ff       	call   8014cf <fd_alloc>
  801cb8:	89 c3                	mov    %eax,%ebx
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	78 54                	js     801d12 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cbe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc2:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801cc9:	e8 5d ed ff ff       	call   800a2b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd1:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cde:	e8 b1 fd ff ff       	call   801a94 <fsipc>
  801ce3:	89 c3                	mov    %eax,%ebx
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	79 15                	jns    801cfe <open+0x6b>
		fd_close(fd, 0);
  801ce9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cf0:	00 
  801cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf4:	89 04 24             	mov    %eax,(%esp)
  801cf7:	e8 d6 f8 ff ff       	call   8015d2 <fd_close>
		return r;
  801cfc:	eb 14                	jmp    801d12 <open+0x7f>
	}

	return fd2num(fd);
  801cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d01:	89 04 24             	mov    %eax,(%esp)
  801d04:	e8 9b f7 ff ff       	call   8014a4 <fd2num>
  801d09:	89 c3                	mov    %eax,%ebx
  801d0b:	eb 05                	jmp    801d12 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d0d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d12:	89 d8                	mov    %ebx,%eax
  801d14:	83 c4 20             	add    $0x20,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d21:	ba 00 00 00 00       	mov    $0x0,%edx
  801d26:	b8 08 00 00 00       	mov    $0x8,%eax
  801d2b:	e8 64 fd ff ff       	call   801a94 <fsipc>
}
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    
	...

00801d34 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d3a:	c7 44 24 04 27 32 80 	movl   $0x803227,0x4(%esp)
  801d41:	00 
  801d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d45:	89 04 24             	mov    %eax,(%esp)
  801d48:	e8 de ec ff ff       	call   800a2b <strcpy>
	return 0;
}
  801d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	53                   	push   %ebx
  801d58:	83 ec 14             	sub    $0x14,%esp
  801d5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d5e:	89 1c 24             	mov    %ebx,(%esp)
  801d61:	e8 fa 0b 00 00       	call   802960 <pageref>
  801d66:	83 f8 01             	cmp    $0x1,%eax
  801d69:	75 0d                	jne    801d78 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801d6b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 1f 03 00 00       	call   802095 <nsipc_close>
  801d76:	eb 05                	jmp    801d7d <devsock_close+0x29>
	else
		return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d7d:	83 c4 14             	add    $0x14,%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d89:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d90:	00 
  801d91:	8b 45 10             	mov    0x10(%ebp),%eax
  801d94:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801da2:	8b 40 0c             	mov    0xc(%eax),%eax
  801da5:	89 04 24             	mov    %eax,(%esp)
  801da8:	e8 e3 03 00 00       	call   802190 <nsipc_send>
}
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801db5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dbc:	00 
  801dbd:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dce:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd1:	89 04 24             	mov    %eax,(%esp)
  801dd4:	e8 37 03 00 00       	call   802110 <nsipc_recv>
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	56                   	push   %esi
  801ddf:	53                   	push   %ebx
  801de0:	83 ec 20             	sub    $0x20,%esp
  801de3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801de5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de8:	89 04 24             	mov    %eax,(%esp)
  801deb:	e8 df f6 ff ff       	call   8014cf <fd_alloc>
  801df0:	89 c3                	mov    %eax,%ebx
  801df2:	85 c0                	test   %eax,%eax
  801df4:	78 21                	js     801e17 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801df6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dfd:	00 
  801dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0c:	e8 0c f0 ff ff       	call   800e1d <sys_page_alloc>
  801e11:	89 c3                	mov    %eax,%ebx
  801e13:	85 c0                	test   %eax,%eax
  801e15:	79 0a                	jns    801e21 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801e17:	89 34 24             	mov    %esi,(%esp)
  801e1a:	e8 76 02 00 00       	call   802095 <nsipc_close>
		return r;
  801e1f:	eb 22                	jmp    801e43 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e21:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e36:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e39:	89 04 24             	mov    %eax,(%esp)
  801e3c:	e8 63 f6 ff ff       	call   8014a4 <fd2num>
  801e41:	89 c3                	mov    %eax,%ebx
}
  801e43:	89 d8                	mov    %ebx,%eax
  801e45:	83 c4 20             	add    $0x20,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e55:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e59:	89 04 24             	mov    %eax,(%esp)
  801e5c:	e8 c1 f6 ff ff       	call   801522 <fd_lookup>
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 17                	js     801e7c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e68:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801e6e:	39 10                	cmp    %edx,(%eax)
  801e70:	75 05                	jne    801e77 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e72:	8b 40 0c             	mov    0xc(%eax),%eax
  801e75:	eb 05                	jmp    801e7c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e77:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e84:	8b 45 08             	mov    0x8(%ebp),%eax
  801e87:	e8 c0 ff ff ff       	call   801e4c <fd2sockid>
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 1f                	js     801eaf <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e90:	8b 55 10             	mov    0x10(%ebp),%edx
  801e93:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e9e:	89 04 24             	mov    %eax,(%esp)
  801ea1:	e8 38 01 00 00       	call   801fde <nsipc_accept>
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	78 05                	js     801eaf <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801eaa:	e8 2c ff ff ff       	call   801ddb <alloc_sockfd>
}
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eba:	e8 8d ff ff ff       	call   801e4c <fd2sockid>
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 16                	js     801ed9 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801ec3:	8b 55 10             	mov    0x10(%ebp),%edx
  801ec6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801eca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ecd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ed1:	89 04 24             	mov    %eax,(%esp)
  801ed4:	e8 5b 01 00 00       	call   802034 <nsipc_bind>
}
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <shutdown>:

int
shutdown(int s, int how)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee4:	e8 63 ff ff ff       	call   801e4c <fd2sockid>
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	78 0f                	js     801efc <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801eed:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef0:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ef4:	89 04 24             	mov    %eax,(%esp)
  801ef7:	e8 77 01 00 00       	call   802073 <nsipc_shutdown>
}
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	e8 40 ff ff ff       	call   801e4c <fd2sockid>
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 16                	js     801f26 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801f10:	8b 55 10             	mov    0x10(%ebp),%edx
  801f13:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f1e:	89 04 24             	mov    %eax,(%esp)
  801f21:	e8 89 01 00 00       	call   8020af <nsipc_connect>
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <listen>:

int
listen(int s, int backlog)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f31:	e8 16 ff ff ff       	call   801e4c <fd2sockid>
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 0f                	js     801f49 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	e8 a5 01 00 00       	call   8020ee <nsipc_listen>
}
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    

00801f4b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f51:	8b 45 10             	mov    0x10(%ebp),%eax
  801f54:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f62:	89 04 24             	mov    %eax,(%esp)
  801f65:	e8 99 02 00 00       	call   802203 <nsipc_socket>
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	78 05                	js     801f73 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801f6e:	e8 68 fe ff ff       	call   801ddb <alloc_sockfd>
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    
  801f75:	00 00                	add    %al,(%eax)
	...

00801f78 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	53                   	push   %ebx
  801f7c:	83 ec 14             	sub    $0x14,%esp
  801f7f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f81:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f88:	75 11                	jne    801f9b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f8a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f91:	e8 85 09 00 00       	call   80291b <ipc_find_env>
  801f96:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f9b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801fa2:	00 
  801fa3:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801faa:	00 
  801fab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801faf:	a1 04 50 80 00       	mov    0x805004,%eax
  801fb4:	89 04 24             	mov    %eax,(%esp)
  801fb7:	e8 dc 08 00 00       	call   802898 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fbc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fc3:	00 
  801fc4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fcb:	00 
  801fcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd3:	e8 50 08 00 00       	call   802828 <ipc_recv>
}
  801fd8:	83 c4 14             	add    $0x14,%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	83 ec 10             	sub    $0x10,%esp
  801fe6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fec:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ff1:	8b 06                	mov    (%esi),%eax
  801ff3:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ff8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffd:	e8 76 ff ff ff       	call   801f78 <nsipc>
  802002:	89 c3                	mov    %eax,%ebx
  802004:	85 c0                	test   %eax,%eax
  802006:	78 23                	js     80202b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802008:	a1 10 70 80 00       	mov    0x807010,%eax
  80200d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802011:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802018:	00 
  802019:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201c:	89 04 24             	mov    %eax,(%esp)
  80201f:	e8 80 eb ff ff       	call   800ba4 <memmove>
		*addrlen = ret->ret_addrlen;
  802024:	a1 10 70 80 00       	mov    0x807010,%eax
  802029:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  80202b:	89 d8                	mov    %ebx,%eax
  80202d:	83 c4 10             	add    $0x10,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	53                   	push   %ebx
  802038:	83 ec 14             	sub    $0x14,%esp
  80203b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80203e:	8b 45 08             	mov    0x8(%ebp),%eax
  802041:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802046:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802051:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802058:	e8 47 eb ff ff       	call   800ba4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80205d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802063:	b8 02 00 00 00       	mov    $0x2,%eax
  802068:	e8 0b ff ff ff       	call   801f78 <nsipc>
}
  80206d:	83 c4 14             	add    $0x14,%esp
  802070:	5b                   	pop    %ebx
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    

00802073 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802079:	8b 45 08             	mov    0x8(%ebp),%eax
  80207c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802081:	8b 45 0c             	mov    0xc(%ebp),%eax
  802084:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802089:	b8 03 00 00 00       	mov    $0x3,%eax
  80208e:	e8 e5 fe ff ff       	call   801f78 <nsipc>
}
  802093:	c9                   	leave  
  802094:	c3                   	ret    

00802095 <nsipc_close>:

int
nsipc_close(int s)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
  80209e:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8020a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8020a8:	e8 cb fe ff ff       	call   801f78 <nsipc>
}
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	53                   	push   %ebx
  8020b3:	83 ec 14             	sub    $0x14,%esp
  8020b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cc:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020d3:	e8 cc ea ff ff       	call   800ba4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020d8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8020de:	b8 05 00 00 00       	mov    $0x5,%eax
  8020e3:	e8 90 fe ff ff       	call   801f78 <nsipc>
}
  8020e8:	83 c4 14             	add    $0x14,%esp
  8020eb:	5b                   	pop    %ebx
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ff:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802104:	b8 06 00 00 00       	mov    $0x6,%eax
  802109:	e8 6a fe ff ff       	call   801f78 <nsipc>
}
  80210e:	c9                   	leave  
  80210f:	c3                   	ret    

00802110 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	56                   	push   %esi
  802114:	53                   	push   %ebx
  802115:	83 ec 10             	sub    $0x10,%esp
  802118:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80211b:	8b 45 08             	mov    0x8(%ebp),%eax
  80211e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802123:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802129:	8b 45 14             	mov    0x14(%ebp),%eax
  80212c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802131:	b8 07 00 00 00       	mov    $0x7,%eax
  802136:	e8 3d fe ff ff       	call   801f78 <nsipc>
  80213b:	89 c3                	mov    %eax,%ebx
  80213d:	85 c0                	test   %eax,%eax
  80213f:	78 46                	js     802187 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802141:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802146:	7f 04                	jg     80214c <nsipc_recv+0x3c>
  802148:	39 c6                	cmp    %eax,%esi
  80214a:	7d 24                	jge    802170 <nsipc_recv+0x60>
  80214c:	c7 44 24 0c 33 32 80 	movl   $0x803233,0xc(%esp)
  802153:	00 
  802154:	c7 44 24 08 fb 31 80 	movl   $0x8031fb,0x8(%esp)
  80215b:	00 
  80215c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802163:	00 
  802164:	c7 04 24 48 32 80 00 	movl   $0x803248,(%esp)
  80216b:	e8 18 e2 ff ff       	call   800388 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802170:	89 44 24 08          	mov    %eax,0x8(%esp)
  802174:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80217b:	00 
  80217c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217f:	89 04 24             	mov    %eax,(%esp)
  802182:	e8 1d ea ff ff       	call   800ba4 <memmove>
	}

	return r;
}
  802187:	89 d8                	mov    %ebx,%eax
  802189:	83 c4 10             	add    $0x10,%esp
  80218c:	5b                   	pop    %ebx
  80218d:	5e                   	pop    %esi
  80218e:	5d                   	pop    %ebp
  80218f:	c3                   	ret    

00802190 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	53                   	push   %ebx
  802194:	83 ec 14             	sub    $0x14,%esp
  802197:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80219a:	8b 45 08             	mov    0x8(%ebp),%eax
  80219d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021a2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021a8:	7e 24                	jle    8021ce <nsipc_send+0x3e>
  8021aa:	c7 44 24 0c 54 32 80 	movl   $0x803254,0xc(%esp)
  8021b1:	00 
  8021b2:	c7 44 24 08 fb 31 80 	movl   $0x8031fb,0x8(%esp)
  8021b9:	00 
  8021ba:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8021c1:	00 
  8021c2:	c7 04 24 48 32 80 00 	movl   $0x803248,(%esp)
  8021c9:	e8 ba e1 ff ff       	call   800388 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d9:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8021e0:	e8 bf e9 ff ff       	call   800ba4 <memmove>
	nsipcbuf.send.req_size = size;
  8021e5:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8021eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8021ee:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8021f8:	e8 7b fd ff ff       	call   801f78 <nsipc>
}
  8021fd:	83 c4 14             	add    $0x14,%esp
  802200:	5b                   	pop    %ebx
  802201:	5d                   	pop    %ebp
  802202:	c3                   	ret    

00802203 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802203:	55                   	push   %ebp
  802204:	89 e5                	mov    %esp,%ebp
  802206:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802209:	8b 45 08             	mov    0x8(%ebp),%eax
  80220c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802211:	8b 45 0c             	mov    0xc(%ebp),%eax
  802214:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802219:	8b 45 10             	mov    0x10(%ebp),%eax
  80221c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802221:	b8 09 00 00 00       	mov    $0x9,%eax
  802226:	e8 4d fd ff ff       	call   801f78 <nsipc>
}
  80222b:	c9                   	leave  
  80222c:	c3                   	ret    
  80222d:	00 00                	add    %al,(%eax)
	...

00802230 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	56                   	push   %esi
  802234:	53                   	push   %ebx
  802235:	83 ec 10             	sub    $0x10,%esp
  802238:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80223b:	8b 45 08             	mov    0x8(%ebp),%eax
  80223e:	89 04 24             	mov    %eax,(%esp)
  802241:	e8 6e f2 ff ff       	call   8014b4 <fd2data>
  802246:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802248:	c7 44 24 04 60 32 80 	movl   $0x803260,0x4(%esp)
  80224f:	00 
  802250:	89 34 24             	mov    %esi,(%esp)
  802253:	e8 d3 e7 ff ff       	call   800a2b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802258:	8b 43 04             	mov    0x4(%ebx),%eax
  80225b:	2b 03                	sub    (%ebx),%eax
  80225d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802263:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80226a:	00 00 00 
	stat->st_dev = &devpipe;
  80226d:	c7 86 88 00 00 00 40 	movl   $0x804040,0x88(%esi)
  802274:	40 80 00 
	return 0;
}
  802277:	b8 00 00 00 00       	mov    $0x0,%eax
  80227c:	83 c4 10             	add    $0x10,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    

00802283 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	53                   	push   %ebx
  802287:	83 ec 14             	sub    $0x14,%esp
  80228a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80228d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802298:	e8 27 ec ff ff       	call   800ec4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80229d:	89 1c 24             	mov    %ebx,(%esp)
  8022a0:	e8 0f f2 ff ff       	call   8014b4 <fd2data>
  8022a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b0:	e8 0f ec ff ff       	call   800ec4 <sys_page_unmap>
}
  8022b5:	83 c4 14             	add    $0x14,%esp
  8022b8:	5b                   	pop    %ebx
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    

008022bb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	57                   	push   %edi
  8022bf:	56                   	push   %esi
  8022c0:	53                   	push   %ebx
  8022c1:	83 ec 2c             	sub    $0x2c,%esp
  8022c4:	89 c7                	mov    %eax,%edi
  8022c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022c9:	a1 08 50 80 00       	mov    0x805008,%eax
  8022ce:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8022d1:	89 3c 24             	mov    %edi,(%esp)
  8022d4:	e8 87 06 00 00       	call   802960 <pageref>
  8022d9:	89 c6                	mov    %eax,%esi
  8022db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022de:	89 04 24             	mov    %eax,(%esp)
  8022e1:	e8 7a 06 00 00       	call   802960 <pageref>
  8022e6:	39 c6                	cmp    %eax,%esi
  8022e8:	0f 94 c0             	sete   %al
  8022eb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8022ee:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8022f4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022f7:	39 cb                	cmp    %ecx,%ebx
  8022f9:	75 08                	jne    802303 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8022fb:	83 c4 2c             	add    $0x2c,%esp
  8022fe:	5b                   	pop    %ebx
  8022ff:	5e                   	pop    %esi
  802300:	5f                   	pop    %edi
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802303:	83 f8 01             	cmp    $0x1,%eax
  802306:	75 c1                	jne    8022c9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802308:	8b 42 58             	mov    0x58(%edx),%eax
  80230b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802312:	00 
  802313:	89 44 24 08          	mov    %eax,0x8(%esp)
  802317:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80231b:	c7 04 24 67 32 80 00 	movl   $0x803267,(%esp)
  802322:	e8 59 e1 ff ff       	call   800480 <cprintf>
  802327:	eb a0                	jmp    8022c9 <_pipeisclosed+0xe>

00802329 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	57                   	push   %edi
  80232d:	56                   	push   %esi
  80232e:	53                   	push   %ebx
  80232f:	83 ec 1c             	sub    $0x1c,%esp
  802332:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802335:	89 34 24             	mov    %esi,(%esp)
  802338:	e8 77 f1 ff ff       	call   8014b4 <fd2data>
  80233d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80233f:	bf 00 00 00 00       	mov    $0x0,%edi
  802344:	eb 3c                	jmp    802382 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802346:	89 da                	mov    %ebx,%edx
  802348:	89 f0                	mov    %esi,%eax
  80234a:	e8 6c ff ff ff       	call   8022bb <_pipeisclosed>
  80234f:	85 c0                	test   %eax,%eax
  802351:	75 38                	jne    80238b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802353:	e8 a6 ea ff ff       	call   800dfe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802358:	8b 43 04             	mov    0x4(%ebx),%eax
  80235b:	8b 13                	mov    (%ebx),%edx
  80235d:	83 c2 20             	add    $0x20,%edx
  802360:	39 d0                	cmp    %edx,%eax
  802362:	73 e2                	jae    802346 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802364:	8b 55 0c             	mov    0xc(%ebp),%edx
  802367:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80236a:	89 c2                	mov    %eax,%edx
  80236c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802372:	79 05                	jns    802379 <devpipe_write+0x50>
  802374:	4a                   	dec    %edx
  802375:	83 ca e0             	or     $0xffffffe0,%edx
  802378:	42                   	inc    %edx
  802379:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80237d:	40                   	inc    %eax
  80237e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802381:	47                   	inc    %edi
  802382:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802385:	75 d1                	jne    802358 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802387:	89 f8                	mov    %edi,%eax
  802389:	eb 05                	jmp    802390 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80238b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802390:	83 c4 1c             	add    $0x1c,%esp
  802393:	5b                   	pop    %ebx
  802394:	5e                   	pop    %esi
  802395:	5f                   	pop    %edi
  802396:	5d                   	pop    %ebp
  802397:	c3                   	ret    

00802398 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802398:	55                   	push   %ebp
  802399:	89 e5                	mov    %esp,%ebp
  80239b:	57                   	push   %edi
  80239c:	56                   	push   %esi
  80239d:	53                   	push   %ebx
  80239e:	83 ec 1c             	sub    $0x1c,%esp
  8023a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023a4:	89 3c 24             	mov    %edi,(%esp)
  8023a7:	e8 08 f1 ff ff       	call   8014b4 <fd2data>
  8023ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ae:	be 00 00 00 00       	mov    $0x0,%esi
  8023b3:	eb 3a                	jmp    8023ef <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023b5:	85 f6                	test   %esi,%esi
  8023b7:	74 04                	je     8023bd <devpipe_read+0x25>
				return i;
  8023b9:	89 f0                	mov    %esi,%eax
  8023bb:	eb 40                	jmp    8023fd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023bd:	89 da                	mov    %ebx,%edx
  8023bf:	89 f8                	mov    %edi,%eax
  8023c1:	e8 f5 fe ff ff       	call   8022bb <_pipeisclosed>
  8023c6:	85 c0                	test   %eax,%eax
  8023c8:	75 2e                	jne    8023f8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023ca:	e8 2f ea ff ff       	call   800dfe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023cf:	8b 03                	mov    (%ebx),%eax
  8023d1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023d4:	74 df                	je     8023b5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023d6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8023db:	79 05                	jns    8023e2 <devpipe_read+0x4a>
  8023dd:	48                   	dec    %eax
  8023de:	83 c8 e0             	or     $0xffffffe0,%eax
  8023e1:	40                   	inc    %eax
  8023e2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8023e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023e9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8023ec:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ee:	46                   	inc    %esi
  8023ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023f2:	75 db                	jne    8023cf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023f4:	89 f0                	mov    %esi,%eax
  8023f6:	eb 05                	jmp    8023fd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023f8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023fd:	83 c4 1c             	add    $0x1c,%esp
  802400:	5b                   	pop    %ebx
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    

00802405 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802405:	55                   	push   %ebp
  802406:	89 e5                	mov    %esp,%ebp
  802408:	57                   	push   %edi
  802409:	56                   	push   %esi
  80240a:	53                   	push   %ebx
  80240b:	83 ec 3c             	sub    $0x3c,%esp
  80240e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802411:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802414:	89 04 24             	mov    %eax,(%esp)
  802417:	e8 b3 f0 ff ff       	call   8014cf <fd_alloc>
  80241c:	89 c3                	mov    %eax,%ebx
  80241e:	85 c0                	test   %eax,%eax
  802420:	0f 88 45 01 00 00    	js     80256b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802426:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80242d:	00 
  80242e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802431:	89 44 24 04          	mov    %eax,0x4(%esp)
  802435:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80243c:	e8 dc e9 ff ff       	call   800e1d <sys_page_alloc>
  802441:	89 c3                	mov    %eax,%ebx
  802443:	85 c0                	test   %eax,%eax
  802445:	0f 88 20 01 00 00    	js     80256b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80244b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80244e:	89 04 24             	mov    %eax,(%esp)
  802451:	e8 79 f0 ff ff       	call   8014cf <fd_alloc>
  802456:	89 c3                	mov    %eax,%ebx
  802458:	85 c0                	test   %eax,%eax
  80245a:	0f 88 f8 00 00 00    	js     802558 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802460:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802467:	00 
  802468:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80246b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80246f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802476:	e8 a2 e9 ff ff       	call   800e1d <sys_page_alloc>
  80247b:	89 c3                	mov    %eax,%ebx
  80247d:	85 c0                	test   %eax,%eax
  80247f:	0f 88 d3 00 00 00    	js     802558 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802488:	89 04 24             	mov    %eax,(%esp)
  80248b:	e8 24 f0 ff ff       	call   8014b4 <fd2data>
  802490:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802492:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802499:	00 
  80249a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a5:	e8 73 e9 ff ff       	call   800e1d <sys_page_alloc>
  8024aa:	89 c3                	mov    %eax,%ebx
  8024ac:	85 c0                	test   %eax,%eax
  8024ae:	0f 88 91 00 00 00    	js     802545 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024b7:	89 04 24             	mov    %eax,(%esp)
  8024ba:	e8 f5 ef ff ff       	call   8014b4 <fd2data>
  8024bf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8024c6:	00 
  8024c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024d2:	00 
  8024d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024de:	e8 8e e9 ff ff       	call   800e71 <sys_page_map>
  8024e3:	89 c3                	mov    %eax,%ebx
  8024e5:	85 c0                	test   %eax,%eax
  8024e7:	78 4c                	js     802535 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024e9:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8024ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024f2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024fe:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802504:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802507:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802509:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80250c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802516:	89 04 24             	mov    %eax,(%esp)
  802519:	e8 86 ef ff ff       	call   8014a4 <fd2num>
  80251e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802520:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802523:	89 04 24             	mov    %eax,(%esp)
  802526:	e8 79 ef ff ff       	call   8014a4 <fd2num>
  80252b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80252e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802533:	eb 36                	jmp    80256b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802535:	89 74 24 04          	mov    %esi,0x4(%esp)
  802539:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802540:	e8 7f e9 ff ff       	call   800ec4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802545:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80254c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802553:	e8 6c e9 ff ff       	call   800ec4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80255b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80255f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802566:	e8 59 e9 ff ff       	call   800ec4 <sys_page_unmap>
    err:
	return r;
}
  80256b:	89 d8                	mov    %ebx,%eax
  80256d:	83 c4 3c             	add    $0x3c,%esp
  802570:	5b                   	pop    %ebx
  802571:	5e                   	pop    %esi
  802572:	5f                   	pop    %edi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    

00802575 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80257b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80257e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802582:	8b 45 08             	mov    0x8(%ebp),%eax
  802585:	89 04 24             	mov    %eax,(%esp)
  802588:	e8 95 ef ff ff       	call   801522 <fd_lookup>
  80258d:	85 c0                	test   %eax,%eax
  80258f:	78 15                	js     8025a6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802591:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802594:	89 04 24             	mov    %eax,(%esp)
  802597:	e8 18 ef ff ff       	call   8014b4 <fd2data>
	return _pipeisclosed(fd, p);
  80259c:	89 c2                	mov    %eax,%edx
  80259e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a1:	e8 15 fd ff ff       	call   8022bb <_pipeisclosed>
}
  8025a6:	c9                   	leave  
  8025a7:	c3                   	ret    

008025a8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8025a8:	55                   	push   %ebp
  8025a9:	89 e5                	mov    %esp,%ebp
  8025ab:	56                   	push   %esi
  8025ac:	53                   	push   %ebx
  8025ad:	83 ec 10             	sub    $0x10,%esp
  8025b0:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8025b3:	85 f6                	test   %esi,%esi
  8025b5:	75 24                	jne    8025db <wait+0x33>
  8025b7:	c7 44 24 0c 7f 32 80 	movl   $0x80327f,0xc(%esp)
  8025be:	00 
  8025bf:	c7 44 24 08 fb 31 80 	movl   $0x8031fb,0x8(%esp)
  8025c6:	00 
  8025c7:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8025ce:	00 
  8025cf:	c7 04 24 8a 32 80 00 	movl   $0x80328a,(%esp)
  8025d6:	e8 ad dd ff ff       	call   800388 <_panic>
	e = &envs[ENVX(envid)];
  8025db:	89 f3                	mov    %esi,%ebx
  8025dd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8025e3:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  8025ea:	c1 e3 07             	shl    $0x7,%ebx
  8025ed:	29 c3                	sub    %eax,%ebx
  8025ef:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025f5:	eb 05                	jmp    8025fc <wait+0x54>
		sys_yield();
  8025f7:	e8 02 e8 ff ff       	call   800dfe <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025fc:	8b 43 48             	mov    0x48(%ebx),%eax
  8025ff:	39 f0                	cmp    %esi,%eax
  802601:	75 07                	jne    80260a <wait+0x62>
  802603:	8b 43 54             	mov    0x54(%ebx),%eax
  802606:	85 c0                	test   %eax,%eax
  802608:	75 ed                	jne    8025f7 <wait+0x4f>
		sys_yield();
}
  80260a:	83 c4 10             	add    $0x10,%esp
  80260d:	5b                   	pop    %ebx
  80260e:	5e                   	pop    %esi
  80260f:	5d                   	pop    %ebp
  802610:	c3                   	ret    
  802611:	00 00                	add    %al,(%eax)
	...

00802614 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802614:	55                   	push   %ebp
  802615:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802617:	b8 00 00 00 00       	mov    $0x0,%eax
  80261c:	5d                   	pop    %ebp
  80261d:	c3                   	ret    

0080261e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80261e:	55                   	push   %ebp
  80261f:	89 e5                	mov    %esp,%ebp
  802621:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802624:	c7 44 24 04 95 32 80 	movl   $0x803295,0x4(%esp)
  80262b:	00 
  80262c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80262f:	89 04 24             	mov    %eax,(%esp)
  802632:	e8 f4 e3 ff ff       	call   800a2b <strcpy>
	return 0;
}
  802637:	b8 00 00 00 00       	mov    $0x0,%eax
  80263c:	c9                   	leave  
  80263d:	c3                   	ret    

0080263e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80263e:	55                   	push   %ebp
  80263f:	89 e5                	mov    %esp,%ebp
  802641:	57                   	push   %edi
  802642:	56                   	push   %esi
  802643:	53                   	push   %ebx
  802644:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80264a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80264f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802655:	eb 30                	jmp    802687 <devcons_write+0x49>
		m = n - tot;
  802657:	8b 75 10             	mov    0x10(%ebp),%esi
  80265a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80265c:	83 fe 7f             	cmp    $0x7f,%esi
  80265f:	76 05                	jbe    802666 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802661:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802666:	89 74 24 08          	mov    %esi,0x8(%esp)
  80266a:	03 45 0c             	add    0xc(%ebp),%eax
  80266d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802671:	89 3c 24             	mov    %edi,(%esp)
  802674:	e8 2b e5 ff ff       	call   800ba4 <memmove>
		sys_cputs(buf, m);
  802679:	89 74 24 04          	mov    %esi,0x4(%esp)
  80267d:	89 3c 24             	mov    %edi,(%esp)
  802680:	e8 cb e6 ff ff       	call   800d50 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802685:	01 f3                	add    %esi,%ebx
  802687:	89 d8                	mov    %ebx,%eax
  802689:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80268c:	72 c9                	jb     802657 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80268e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802694:	5b                   	pop    %ebx
  802695:	5e                   	pop    %esi
  802696:	5f                   	pop    %edi
  802697:	5d                   	pop    %ebp
  802698:	c3                   	ret    

00802699 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802699:	55                   	push   %ebp
  80269a:	89 e5                	mov    %esp,%ebp
  80269c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80269f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8026a3:	75 07                	jne    8026ac <devcons_read+0x13>
  8026a5:	eb 25                	jmp    8026cc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8026a7:	e8 52 e7 ff ff       	call   800dfe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8026ac:	e8 bd e6 ff ff       	call   800d6e <sys_cgetc>
  8026b1:	85 c0                	test   %eax,%eax
  8026b3:	74 f2                	je     8026a7 <devcons_read+0xe>
  8026b5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8026b7:	85 c0                	test   %eax,%eax
  8026b9:	78 1d                	js     8026d8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8026bb:	83 f8 04             	cmp    $0x4,%eax
  8026be:	74 13                	je     8026d3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8026c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026c3:	88 10                	mov    %dl,(%eax)
	return 1;
  8026c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ca:	eb 0c                	jmp    8026d8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8026cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8026d1:	eb 05                	jmp    8026d8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8026d3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8026d8:	c9                   	leave  
  8026d9:	c3                   	ret    

008026da <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8026da:	55                   	push   %ebp
  8026db:	89 e5                	mov    %esp,%ebp
  8026dd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8026e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8026e3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8026e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8026ed:	00 
  8026ee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026f1:	89 04 24             	mov    %eax,(%esp)
  8026f4:	e8 57 e6 ff ff       	call   800d50 <sys_cputs>
}
  8026f9:	c9                   	leave  
  8026fa:	c3                   	ret    

008026fb <getchar>:

int
getchar(void)
{
  8026fb:	55                   	push   %ebp
  8026fc:	89 e5                	mov    %esp,%ebp
  8026fe:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802701:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802708:	00 
  802709:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80270c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802710:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802717:	e8 a4 f0 ff ff       	call   8017c0 <read>
	if (r < 0)
  80271c:	85 c0                	test   %eax,%eax
  80271e:	78 0f                	js     80272f <getchar+0x34>
		return r;
	if (r < 1)
  802720:	85 c0                	test   %eax,%eax
  802722:	7e 06                	jle    80272a <getchar+0x2f>
		return -E_EOF;
	return c;
  802724:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802728:	eb 05                	jmp    80272f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80272a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80272f:	c9                   	leave  
  802730:	c3                   	ret    

00802731 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802731:	55                   	push   %ebp
  802732:	89 e5                	mov    %esp,%ebp
  802734:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802737:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80273a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80273e:	8b 45 08             	mov    0x8(%ebp),%eax
  802741:	89 04 24             	mov    %eax,(%esp)
  802744:	e8 d9 ed ff ff       	call   801522 <fd_lookup>
  802749:	85 c0                	test   %eax,%eax
  80274b:	78 11                	js     80275e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80274d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802750:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802756:	39 10                	cmp    %edx,(%eax)
  802758:	0f 94 c0             	sete   %al
  80275b:	0f b6 c0             	movzbl %al,%eax
}
  80275e:	c9                   	leave  
  80275f:	c3                   	ret    

00802760 <opencons>:

int
opencons(void)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802769:	89 04 24             	mov    %eax,(%esp)
  80276c:	e8 5e ed ff ff       	call   8014cf <fd_alloc>
  802771:	85 c0                	test   %eax,%eax
  802773:	78 3c                	js     8027b1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802775:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80277c:	00 
  80277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802780:	89 44 24 04          	mov    %eax,0x4(%esp)
  802784:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80278b:	e8 8d e6 ff ff       	call   800e1d <sys_page_alloc>
  802790:	85 c0                	test   %eax,%eax
  802792:	78 1d                	js     8027b1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802794:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80279a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80279d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80279f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027a2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8027a9:	89 04 24             	mov    %eax,(%esp)
  8027ac:	e8 f3 ec ff ff       	call   8014a4 <fd2num>
}
  8027b1:	c9                   	leave  
  8027b2:	c3                   	ret    
	...

008027b4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027b4:	55                   	push   %ebp
  8027b5:	89 e5                	mov    %esp,%ebp
  8027b7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8027ba:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8027c1:	75 30                	jne    8027f3 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8027c3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8027ca:	00 
  8027cb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8027d2:	ee 
  8027d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027da:	e8 3e e6 ff ff       	call   800e1d <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8027df:	c7 44 24 04 00 28 80 	movl   $0x802800,0x4(%esp)
  8027e6:	00 
  8027e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027ee:	e8 ca e7 ff ff       	call   800fbd <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8027f6:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8027fb:	c9                   	leave  
  8027fc:	c3                   	ret    
  8027fd:	00 00                	add    %al,(%eax)
	...

00802800 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802800:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802801:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802806:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802808:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  80280b:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  80280f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802813:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  802816:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802818:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  80281c:	83 c4 08             	add    $0x8,%esp
	popal
  80281f:	61                   	popa   

	addl $4,%esp 
  802820:	83 c4 04             	add    $0x4,%esp
	popfl
  802823:	9d                   	popf   

	popl %esp
  802824:	5c                   	pop    %esp

	ret
  802825:	c3                   	ret    
	...

00802828 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802828:	55                   	push   %ebp
  802829:	89 e5                	mov    %esp,%ebp
  80282b:	56                   	push   %esi
  80282c:	53                   	push   %ebx
  80282d:	83 ec 10             	sub    $0x10,%esp
  802830:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802833:	8b 45 0c             	mov    0xc(%ebp),%eax
  802836:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802839:	85 c0                	test   %eax,%eax
  80283b:	74 0a                	je     802847 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  80283d:	89 04 24             	mov    %eax,(%esp)
  802840:	e8 ee e7 ff ff       	call   801033 <sys_ipc_recv>
  802845:	eb 0c                	jmp    802853 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802847:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80284e:	e8 e0 e7 ff ff       	call   801033 <sys_ipc_recv>
	}
	if (r < 0)
  802853:	85 c0                	test   %eax,%eax
  802855:	79 16                	jns    80286d <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802857:	85 db                	test   %ebx,%ebx
  802859:	74 06                	je     802861 <ipc_recv+0x39>
  80285b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802861:	85 f6                	test   %esi,%esi
  802863:	74 2c                	je     802891 <ipc_recv+0x69>
  802865:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80286b:	eb 24                	jmp    802891 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  80286d:	85 db                	test   %ebx,%ebx
  80286f:	74 0a                	je     80287b <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802871:	a1 08 50 80 00       	mov    0x805008,%eax
  802876:	8b 40 74             	mov    0x74(%eax),%eax
  802879:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80287b:	85 f6                	test   %esi,%esi
  80287d:	74 0a                	je     802889 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80287f:	a1 08 50 80 00       	mov    0x805008,%eax
  802884:	8b 40 78             	mov    0x78(%eax),%eax
  802887:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802889:	a1 08 50 80 00       	mov    0x805008,%eax
  80288e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802891:	83 c4 10             	add    $0x10,%esp
  802894:	5b                   	pop    %ebx
  802895:	5e                   	pop    %esi
  802896:	5d                   	pop    %ebp
  802897:	c3                   	ret    

00802898 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802898:	55                   	push   %ebp
  802899:	89 e5                	mov    %esp,%ebp
  80289b:	57                   	push   %edi
  80289c:	56                   	push   %esi
  80289d:	53                   	push   %ebx
  80289e:	83 ec 1c             	sub    $0x1c,%esp
  8028a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8028a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8028a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8028aa:	85 db                	test   %ebx,%ebx
  8028ac:	74 19                	je     8028c7 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8028ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8028b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028b5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028bd:	89 34 24             	mov    %esi,(%esp)
  8028c0:	e8 4b e7 ff ff       	call   801010 <sys_ipc_try_send>
  8028c5:	eb 1c                	jmp    8028e3 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8028c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8028ce:	00 
  8028cf:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8028d6:	ee 
  8028d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028db:	89 34 24             	mov    %esi,(%esp)
  8028de:	e8 2d e7 ff ff       	call   801010 <sys_ipc_try_send>
		}
		if (r == 0)
  8028e3:	85 c0                	test   %eax,%eax
  8028e5:	74 2c                	je     802913 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8028e7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028ea:	74 20                	je     80290c <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8028ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028f0:	c7 44 24 08 a1 32 80 	movl   $0x8032a1,0x8(%esp)
  8028f7:	00 
  8028f8:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8028ff:	00 
  802900:	c7 04 24 b4 32 80 00 	movl   $0x8032b4,(%esp)
  802907:	e8 7c da ff ff       	call   800388 <_panic>
		}
		sys_yield();
  80290c:	e8 ed e4 ff ff       	call   800dfe <sys_yield>
	}
  802911:	eb 97                	jmp    8028aa <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802913:	83 c4 1c             	add    $0x1c,%esp
  802916:	5b                   	pop    %ebx
  802917:	5e                   	pop    %esi
  802918:	5f                   	pop    %edi
  802919:	5d                   	pop    %ebp
  80291a:	c3                   	ret    

0080291b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80291b:	55                   	push   %ebp
  80291c:	89 e5                	mov    %esp,%ebp
  80291e:	53                   	push   %ebx
  80291f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802922:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802927:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80292e:	89 c2                	mov    %eax,%edx
  802930:	c1 e2 07             	shl    $0x7,%edx
  802933:	29 ca                	sub    %ecx,%edx
  802935:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80293b:	8b 52 50             	mov    0x50(%edx),%edx
  80293e:	39 da                	cmp    %ebx,%edx
  802940:	75 0f                	jne    802951 <ipc_find_env+0x36>
			return envs[i].env_id;
  802942:	c1 e0 07             	shl    $0x7,%eax
  802945:	29 c8                	sub    %ecx,%eax
  802947:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80294c:	8b 40 40             	mov    0x40(%eax),%eax
  80294f:	eb 0c                	jmp    80295d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802951:	40                   	inc    %eax
  802952:	3d 00 04 00 00       	cmp    $0x400,%eax
  802957:	75 ce                	jne    802927 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802959:	66 b8 00 00          	mov    $0x0,%ax
}
  80295d:	5b                   	pop    %ebx
  80295e:	5d                   	pop    %ebp
  80295f:	c3                   	ret    

00802960 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802960:	55                   	push   %ebp
  802961:	89 e5                	mov    %esp,%ebp
  802963:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802966:	89 c2                	mov    %eax,%edx
  802968:	c1 ea 16             	shr    $0x16,%edx
  80296b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802972:	f6 c2 01             	test   $0x1,%dl
  802975:	74 1e                	je     802995 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802977:	c1 e8 0c             	shr    $0xc,%eax
  80297a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802981:	a8 01                	test   $0x1,%al
  802983:	74 17                	je     80299c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802985:	c1 e8 0c             	shr    $0xc,%eax
  802988:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80298f:	ef 
  802990:	0f b7 c0             	movzwl %ax,%eax
  802993:	eb 0c                	jmp    8029a1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802995:	b8 00 00 00 00       	mov    $0x0,%eax
  80299a:	eb 05                	jmp    8029a1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80299c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8029a1:	5d                   	pop    %ebp
  8029a2:	c3                   	ret    
	...

008029a4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8029a4:	55                   	push   %ebp
  8029a5:	57                   	push   %edi
  8029a6:	56                   	push   %esi
  8029a7:	83 ec 10             	sub    $0x10,%esp
  8029aa:	8b 74 24 20          	mov    0x20(%esp),%esi
  8029ae:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8029b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029b6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8029ba:	89 cd                	mov    %ecx,%ebp
  8029bc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8029c0:	85 c0                	test   %eax,%eax
  8029c2:	75 2c                	jne    8029f0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8029c4:	39 f9                	cmp    %edi,%ecx
  8029c6:	77 68                	ja     802a30 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8029c8:	85 c9                	test   %ecx,%ecx
  8029ca:	75 0b                	jne    8029d7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8029cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8029d1:	31 d2                	xor    %edx,%edx
  8029d3:	f7 f1                	div    %ecx
  8029d5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8029d7:	31 d2                	xor    %edx,%edx
  8029d9:	89 f8                	mov    %edi,%eax
  8029db:	f7 f1                	div    %ecx
  8029dd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029df:	89 f0                	mov    %esi,%eax
  8029e1:	f7 f1                	div    %ecx
  8029e3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029e5:	89 f0                	mov    %esi,%eax
  8029e7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029e9:	83 c4 10             	add    $0x10,%esp
  8029ec:	5e                   	pop    %esi
  8029ed:	5f                   	pop    %edi
  8029ee:	5d                   	pop    %ebp
  8029ef:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029f0:	39 f8                	cmp    %edi,%eax
  8029f2:	77 2c                	ja     802a20 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8029f4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8029f7:	83 f6 1f             	xor    $0x1f,%esi
  8029fa:	75 4c                	jne    802a48 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029fc:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029fe:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a03:	72 0a                	jb     802a0f <__udivdi3+0x6b>
  802a05:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802a09:	0f 87 ad 00 00 00    	ja     802abc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a0f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a14:	89 f0                	mov    %esi,%eax
  802a16:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a18:	83 c4 10             	add    $0x10,%esp
  802a1b:	5e                   	pop    %esi
  802a1c:	5f                   	pop    %edi
  802a1d:	5d                   	pop    %ebp
  802a1e:	c3                   	ret    
  802a1f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a20:	31 ff                	xor    %edi,%edi
  802a22:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a24:	89 f0                	mov    %esi,%eax
  802a26:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a28:	83 c4 10             	add    $0x10,%esp
  802a2b:	5e                   	pop    %esi
  802a2c:	5f                   	pop    %edi
  802a2d:	5d                   	pop    %ebp
  802a2e:	c3                   	ret    
  802a2f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a30:	89 fa                	mov    %edi,%edx
  802a32:	89 f0                	mov    %esi,%eax
  802a34:	f7 f1                	div    %ecx
  802a36:	89 c6                	mov    %eax,%esi
  802a38:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a3a:	89 f0                	mov    %esi,%eax
  802a3c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a3e:	83 c4 10             	add    $0x10,%esp
  802a41:	5e                   	pop    %esi
  802a42:	5f                   	pop    %edi
  802a43:	5d                   	pop    %ebp
  802a44:	c3                   	ret    
  802a45:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a48:	89 f1                	mov    %esi,%ecx
  802a4a:	d3 e0                	shl    %cl,%eax
  802a4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a50:	b8 20 00 00 00       	mov    $0x20,%eax
  802a55:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802a57:	89 ea                	mov    %ebp,%edx
  802a59:	88 c1                	mov    %al,%cl
  802a5b:	d3 ea                	shr    %cl,%edx
  802a5d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802a61:	09 ca                	or     %ecx,%edx
  802a63:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802a67:	89 f1                	mov    %esi,%ecx
  802a69:	d3 e5                	shl    %cl,%ebp
  802a6b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802a6f:	89 fd                	mov    %edi,%ebp
  802a71:	88 c1                	mov    %al,%cl
  802a73:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802a75:	89 fa                	mov    %edi,%edx
  802a77:	89 f1                	mov    %esi,%ecx
  802a79:	d3 e2                	shl    %cl,%edx
  802a7b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a7f:	88 c1                	mov    %al,%cl
  802a81:	d3 ef                	shr    %cl,%edi
  802a83:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a85:	89 f8                	mov    %edi,%eax
  802a87:	89 ea                	mov    %ebp,%edx
  802a89:	f7 74 24 08          	divl   0x8(%esp)
  802a8d:	89 d1                	mov    %edx,%ecx
  802a8f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802a91:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a95:	39 d1                	cmp    %edx,%ecx
  802a97:	72 17                	jb     802ab0 <__udivdi3+0x10c>
  802a99:	74 09                	je     802aa4 <__udivdi3+0x100>
  802a9b:	89 fe                	mov    %edi,%esi
  802a9d:	31 ff                	xor    %edi,%edi
  802a9f:	e9 41 ff ff ff       	jmp    8029e5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802aa4:	8b 54 24 04          	mov    0x4(%esp),%edx
  802aa8:	89 f1                	mov    %esi,%ecx
  802aaa:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802aac:	39 c2                	cmp    %eax,%edx
  802aae:	73 eb                	jae    802a9b <__udivdi3+0xf7>
		{
		  q0--;
  802ab0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802ab3:	31 ff                	xor    %edi,%edi
  802ab5:	e9 2b ff ff ff       	jmp    8029e5 <__udivdi3+0x41>
  802aba:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802abc:	31 f6                	xor    %esi,%esi
  802abe:	e9 22 ff ff ff       	jmp    8029e5 <__udivdi3+0x41>
	...

00802ac4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802ac4:	55                   	push   %ebp
  802ac5:	57                   	push   %edi
  802ac6:	56                   	push   %esi
  802ac7:	83 ec 20             	sub    $0x20,%esp
  802aca:	8b 44 24 30          	mov    0x30(%esp),%eax
  802ace:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802ad2:	89 44 24 14          	mov    %eax,0x14(%esp)
  802ad6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802ada:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802ade:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802ae2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802ae4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802ae6:	85 ed                	test   %ebp,%ebp
  802ae8:	75 16                	jne    802b00 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802aea:	39 f1                	cmp    %esi,%ecx
  802aec:	0f 86 a6 00 00 00    	jbe    802b98 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802af2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802af4:	89 d0                	mov    %edx,%eax
  802af6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802af8:	83 c4 20             	add    $0x20,%esp
  802afb:	5e                   	pop    %esi
  802afc:	5f                   	pop    %edi
  802afd:	5d                   	pop    %ebp
  802afe:	c3                   	ret    
  802aff:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b00:	39 f5                	cmp    %esi,%ebp
  802b02:	0f 87 ac 00 00 00    	ja     802bb4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802b08:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802b0b:	83 f0 1f             	xor    $0x1f,%eax
  802b0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b12:	0f 84 a8 00 00 00    	je     802bc0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802b18:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b1c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802b1e:	bf 20 00 00 00       	mov    $0x20,%edi
  802b23:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802b27:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b2b:	89 f9                	mov    %edi,%ecx
  802b2d:	d3 e8                	shr    %cl,%eax
  802b2f:	09 e8                	or     %ebp,%eax
  802b31:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802b35:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b39:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b3d:	d3 e0                	shl    %cl,%eax
  802b3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b43:	89 f2                	mov    %esi,%edx
  802b45:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802b47:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b4b:	d3 e0                	shl    %cl,%eax
  802b4d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b51:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b55:	89 f9                	mov    %edi,%ecx
  802b57:	d3 e8                	shr    %cl,%eax
  802b59:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802b5b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802b5d:	89 f2                	mov    %esi,%edx
  802b5f:	f7 74 24 18          	divl   0x18(%esp)
  802b63:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802b65:	f7 64 24 0c          	mull   0xc(%esp)
  802b69:	89 c5                	mov    %eax,%ebp
  802b6b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b6d:	39 d6                	cmp    %edx,%esi
  802b6f:	72 67                	jb     802bd8 <__umoddi3+0x114>
  802b71:	74 75                	je     802be8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802b73:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802b77:	29 e8                	sub    %ebp,%eax
  802b79:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802b7b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b7f:	d3 e8                	shr    %cl,%eax
  802b81:	89 f2                	mov    %esi,%edx
  802b83:	89 f9                	mov    %edi,%ecx
  802b85:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802b87:	09 d0                	or     %edx,%eax
  802b89:	89 f2                	mov    %esi,%edx
  802b8b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b8f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b91:	83 c4 20             	add    $0x20,%esp
  802b94:	5e                   	pop    %esi
  802b95:	5f                   	pop    %edi
  802b96:	5d                   	pop    %ebp
  802b97:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b98:	85 c9                	test   %ecx,%ecx
  802b9a:	75 0b                	jne    802ba7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b9c:	b8 01 00 00 00       	mov    $0x1,%eax
  802ba1:	31 d2                	xor    %edx,%edx
  802ba3:	f7 f1                	div    %ecx
  802ba5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802ba7:	89 f0                	mov    %esi,%eax
  802ba9:	31 d2                	xor    %edx,%edx
  802bab:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802bad:	89 f8                	mov    %edi,%eax
  802baf:	e9 3e ff ff ff       	jmp    802af2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802bb4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bb6:	83 c4 20             	add    $0x20,%esp
  802bb9:	5e                   	pop    %esi
  802bba:	5f                   	pop    %edi
  802bbb:	5d                   	pop    %ebp
  802bbc:	c3                   	ret    
  802bbd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802bc0:	39 f5                	cmp    %esi,%ebp
  802bc2:	72 04                	jb     802bc8 <__umoddi3+0x104>
  802bc4:	39 f9                	cmp    %edi,%ecx
  802bc6:	77 06                	ja     802bce <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802bc8:	89 f2                	mov    %esi,%edx
  802bca:	29 cf                	sub    %ecx,%edi
  802bcc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802bce:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bd0:	83 c4 20             	add    $0x20,%esp
  802bd3:	5e                   	pop    %esi
  802bd4:	5f                   	pop    %edi
  802bd5:	5d                   	pop    %ebp
  802bd6:	c3                   	ret    
  802bd7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802bd8:	89 d1                	mov    %edx,%ecx
  802bda:	89 c5                	mov    %eax,%ebp
  802bdc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802be0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802be4:	eb 8d                	jmp    802b73 <__umoddi3+0xaf>
  802be6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802be8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802bec:	72 ea                	jb     802bd8 <__umoddi3+0x114>
  802bee:	89 f1                	mov    %esi,%ecx
  802bf0:	eb 81                	jmp    802b73 <__umoddi3+0xaf>
