
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 ff 01 00 00       	call   800230 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003c:	c7 04 24 a0 2a 80 00 	movl   $0x802aa0,(%esp)
  800043:	e8 50 03 00 00       	call   800398 <cprintf>
	if ((r = pipe(p)) < 0)
  800048:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80004b:	89 04 24             	mov    %eax,(%esp)
  80004e:	e8 46 24 00 00       	call   802499 <pipe>
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", r);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 b9 2a 80 	movl   $0x802ab9,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 c2 2a 80 00 	movl   $0x802ac2,(%esp)
  800072:	e8 29 02 00 00       	call   8002a0 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800077:	e8 5b 10 00 00       	call   8010d7 <fork>
  80007c:	89 c6                	mov    %eax,%esi
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 45 2f 80 	movl   $0x802f45,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 c2 2a 80 00 	movl   $0x802ac2,(%esp)
  80009d:	e8 fe 01 00 00       	call   8002a0 <_panic>
	if (r == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	75 54                	jne    8000fa <umain+0xc6>
		close(p[1]);
  8000a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a9:	89 04 24             	mov    %eax,(%esp)
  8000ac:	e8 f9 15 00 00       	call   8016aa <close>
  8000b1:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  8000b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 48 25 00 00       	call   802609 <pipeisclosed>
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	74 11                	je     8000d6 <umain+0xa2>
				cprintf("RACE: pipe appears closed\n");
  8000c5:	c7 04 24 d6 2a 80 00 	movl   $0x802ad6,(%esp)
  8000cc:	e8 c7 02 00 00       	call   800398 <cprintf>
				exit();
  8000d1:	e8 ae 01 00 00       	call   800284 <exit>
			}
			sys_yield();
  8000d6:	e8 3b 0c 00 00       	call   800d16 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000db:	4b                   	dec    %ebx
  8000dc:	75 d8                	jne    8000b6 <umain+0x82>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 c2 12 00 00       	call   8013bc <ipc_recv>
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000fe:	c7 04 24 f1 2a 80 00 	movl   $0x802af1,(%esp)
  800105:	e8 8e 02 00 00       	call   800398 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  80010a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800110:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800117:	c1 e6 07             	shl    $0x7,%esi
  80011a:	29 c6                	sub    %eax,%esi
	cprintf("kid is %d\n", kid-envs);
  80011c:	8d 9e 00 00 c0 ee    	lea    -0x11400000(%esi),%ebx
  800122:	c1 fe 02             	sar    $0x2,%esi
  800125:	89 f2                	mov    %esi,%edx
  800127:	c1 e2 05             	shl    $0x5,%edx
  80012a:	89 f0                	mov    %esi,%eax
  80012c:	c1 e0 0a             	shl    $0xa,%eax
  80012f:	01 d0                	add    %edx,%eax
  800131:	01 f0                	add    %esi,%eax
  800133:	89 c2                	mov    %eax,%edx
  800135:	c1 e2 0f             	shl    $0xf,%edx
  800138:	01 d0                	add    %edx,%eax
  80013a:	c1 e0 05             	shl    $0x5,%eax
  80013d:	01 c6                	add    %eax,%esi
  80013f:	f7 de                	neg    %esi
  800141:	89 74 24 04          	mov    %esi,0x4(%esp)
  800145:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  80014c:	e8 47 02 00 00       	call   800398 <cprintf>
	dup(p[0], 10);
  800151:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800158:	00 
  800159:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 97 15 00 00       	call   8016fb <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800164:	eb 13                	jmp    800179 <umain+0x145>
		dup(p[0], 10);
  800166:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  80016d:	00 
  80016e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 82 15 00 00       	call   8016fb <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800179:	8b 43 54             	mov    0x54(%ebx),%eax
  80017c:	83 f8 02             	cmp    $0x2,%eax
  80017f:	74 e5                	je     800166 <umain+0x132>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800181:	c7 04 24 07 2b 80 00 	movl   $0x802b07,(%esp)
  800188:	e8 0b 02 00 00       	call   800398 <cprintf>
	if (pipeisclosed(p[0]))
  80018d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 71 24 00 00       	call   802609 <pipeisclosed>
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 1c                	je     8001b8 <umain+0x184>
		panic("somehow the other end of p[0] got closed!");
  80019c:	c7 44 24 08 60 2b 80 	movl   $0x802b60,0x8(%esp)
  8001a3:	00 
  8001a4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8001ab:	00 
  8001ac:	c7 04 24 c2 2a 80 00 	movl   $0x802ac2,(%esp)
  8001b3:	e8 e8 00 00 00       	call   8002a0 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 a8 13 00 00       	call   801572 <fd_lookup>
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	79 20                	jns    8001ee <umain+0x1ba>
		panic("cannot look up p[0]: %e", r);
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	c7 44 24 08 1d 2b 80 	movl   $0x802b1d,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 c2 2a 80 00 	movl   $0x802ac2,(%esp)
  8001e9:	e8 b2 00 00 00       	call   8002a0 <_panic>
	va = fd2data(fd);
  8001ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 0b 13 00 00       	call   801504 <fd2data>
	if (pageref(va) != 3+1)
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 83 1b 00 00       	call   801d84 <pageref>
  800201:	83 f8 04             	cmp    $0x4,%eax
  800204:	74 0e                	je     800214 <umain+0x1e0>
		cprintf("\nchild detected race\n");
  800206:	c7 04 24 35 2b 80 00 	movl   $0x802b35,(%esp)
  80020d:	e8 86 01 00 00       	call   800398 <cprintf>
  800212:	eb 14                	jmp    800228 <umain+0x1f4>
	else
		cprintf("\nrace didn't happen\n", max);
  800214:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 4b 2b 80 00 	movl   $0x802b4b,(%esp)
  800223:	e8 70 01 00 00       	call   800398 <cprintf>
}
  800228:	83 c4 20             	add    $0x20,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    
	...

00800230 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 10             	sub    $0x10,%esp
  800238:	8b 75 08             	mov    0x8(%ebp),%esi
  80023b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80023e:	e8 b4 0a 00 00       	call   800cf7 <sys_getenvid>
  800243:	25 ff 03 00 00       	and    $0x3ff,%eax
  800248:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80024f:	c1 e0 07             	shl    $0x7,%eax
  800252:	29 d0                	sub    %edx,%eax
  800254:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800259:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025e:	85 f6                	test   %esi,%esi
  800260:	7e 07                	jle    800269 <libmain+0x39>
		binaryname = argv[0];
  800262:	8b 03                	mov    (%ebx),%eax
  800264:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800269:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	e8 bf fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800275:	e8 0a 00 00 00       	call   800284 <exit>
}
  80027a:	83 c4 10             	add    $0x10,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    
  800281:	00 00                	add    %al,(%eax)
	...

00800284 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80028a:	e8 4c 14 00 00       	call   8016db <close_all>
	sys_env_destroy(0);
  80028f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800296:	e8 0a 0a 00 00       	call   800ca5 <sys_env_destroy>
}
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ab:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8002b1:	e8 41 0a 00 00       	call   800cf7 <sys_getenvid>
  8002b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	c7 04 24 94 2b 80 00 	movl   $0x802b94,(%esp)
  8002d3:	e8 c0 00 00 00       	call   800398 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	e8 50 00 00 00       	call   800337 <vcprintf>
	cprintf("\n");
  8002e7:	c7 04 24 b7 2a 80 00 	movl   $0x802ab7,(%esp)
  8002ee:	e8 a5 00 00 00       	call   800398 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002f3:	cc                   	int3   
  8002f4:	eb fd                	jmp    8002f3 <_panic+0x53>
	...

008002f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 14             	sub    $0x14,%esp
  8002ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800302:	8b 03                	mov    (%ebx),%eax
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030b:	40                   	inc    %eax
  80030c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800313:	75 19                	jne    80032e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800315:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80031c:	00 
  80031d:	8d 43 08             	lea    0x8(%ebx),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	e8 40 09 00 00       	call   800c68 <sys_cputs>
		b->idx = 0;
  800328:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80032e:	ff 43 04             	incl   0x4(%ebx)
}
  800331:	83 c4 14             	add    $0x14,%esp
  800334:	5b                   	pop    %ebx
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800340:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800347:	00 00 00 
	b.cnt = 0;
  80034a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800351:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
  800357:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800362:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800368:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036c:	c7 04 24 f8 02 80 00 	movl   $0x8002f8,(%esp)
  800373:	e8 82 01 00 00       	call   8004fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800378:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80037e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800382:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	e8 d8 08 00 00       	call   800c68 <sys_cputs>

	return b.cnt;
}
  800390:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	e8 87 ff ff ff       	call   800337 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    
	...

008003b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 3c             	sub    $0x3c,%esp
  8003bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c0:	89 d7                	mov    %edx,%edi
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	75 08                	jne    8003e0 <printnum+0x2c>
  8003d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003de:	77 57                	ja     800437 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003e4:	4b                   	dec    %ebx
  8003e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003f4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ff:	00 
  800400:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800403:	89 04 24             	mov    %eax,(%esp)
  800406:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040d:	e8 3e 24 00 00       	call   802850 <__udivdi3>
  800412:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800416:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80041a:	89 04 24             	mov    %eax,(%esp)
  80041d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800421:	89 fa                	mov    %edi,%edx
  800423:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800426:	e8 89 ff ff ff       	call   8003b4 <printnum>
  80042b:	eb 0f                	jmp    80043c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80042d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800431:	89 34 24             	mov    %esi,(%esp)
  800434:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800437:	4b                   	dec    %ebx
  800438:	85 db                	test   %ebx,%ebx
  80043a:	7f f1                	jg     80042d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80043c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800440:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800444:	8b 45 10             	mov    0x10(%ebp),%eax
  800447:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800452:	00 
  800453:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800456:	89 04 24             	mov    %eax,(%esp)
  800459:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800460:	e8 0b 25 00 00       	call   802970 <__umoddi3>
  800465:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800469:	0f be 80 b7 2b 80 00 	movsbl 0x802bb7(%eax),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800476:	83 c4 3c             	add    $0x3c,%esp
  800479:	5b                   	pop    %ebx
  80047a:	5e                   	pop    %esi
  80047b:	5f                   	pop    %edi
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800481:	83 fa 01             	cmp    $0x1,%edx
  800484:	7e 0e                	jle    800494 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800486:	8b 10                	mov    (%eax),%edx
  800488:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048b:	89 08                	mov    %ecx,(%eax)
  80048d:	8b 02                	mov    (%edx),%eax
  80048f:	8b 52 04             	mov    0x4(%edx),%edx
  800492:	eb 22                	jmp    8004b6 <getuint+0x38>
	else if (lflag)
  800494:	85 d2                	test   %edx,%edx
  800496:	74 10                	je     8004a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	eb 0e                	jmp    8004b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 02                	mov    (%edx),%eax
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004be:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004c1:	8b 10                	mov    (%eax),%edx
  8004c3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c6:	73 08                	jae    8004d0 <sprintputch+0x18>
		*b->buf++ = ch;
  8004c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cb:	88 0a                	mov    %cl,(%edx)
  8004cd:	42                   	inc    %edx
  8004ce:	89 10                	mov    %edx,(%eax)
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004df:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	e8 02 00 00 00       	call   8004fa <vprintfmt>
	va_end(ap);
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	57                   	push   %edi
  8004fe:	56                   	push   %esi
  8004ff:	53                   	push   %ebx
  800500:	83 ec 4c             	sub    $0x4c,%esp
  800503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800506:	8b 75 10             	mov    0x10(%ebp),%esi
  800509:	eb 12                	jmp    80051d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050b:	85 c0                	test   %eax,%eax
  80050d:	0f 84 6b 03 00 00    	je     80087e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800513:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800517:	89 04 24             	mov    %eax,(%esp)
  80051a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80051d:	0f b6 06             	movzbl (%esi),%eax
  800520:	46                   	inc    %esi
  800521:	83 f8 25             	cmp    $0x25,%eax
  800524:	75 e5                	jne    80050b <vprintfmt+0x11>
  800526:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80052a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800531:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800536:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80053d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800542:	eb 26                	jmp    80056a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800547:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80054b:	eb 1d                	jmp    80056a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800550:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800554:	eb 14                	jmp    80056a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800559:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800560:	eb 08                	jmp    80056a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800562:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800565:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	0f b6 06             	movzbl (%esi),%eax
  80056d:	8d 56 01             	lea    0x1(%esi),%edx
  800570:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800573:	8a 16                	mov    (%esi),%dl
  800575:	83 ea 23             	sub    $0x23,%edx
  800578:	80 fa 55             	cmp    $0x55,%dl
  80057b:	0f 87 e1 02 00 00    	ja     800862 <vprintfmt+0x368>
  800581:	0f b6 d2             	movzbl %dl,%edx
  800584:	ff 24 95 00 2d 80 00 	jmp    *0x802d00(,%edx,4)
  80058b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80058e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800593:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800596:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80059a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80059d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005a0:	83 fa 09             	cmp    $0x9,%edx
  8005a3:	77 2a                	ja     8005cf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a6:	eb eb                	jmp    800593 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b6:	eb 17                	jmp    8005cf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bc:	78 98                	js     800556 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c1:	eb a7                	jmp    80056a <vprintfmt+0x70>
  8005c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005cd:	eb 9b                	jmp    80056a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d3:	79 95                	jns    80056a <vprintfmt+0x70>
  8005d5:	eb 8b                	jmp    800562 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005db:	eb 8d                	jmp    80056a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f5:	e9 23 ff ff ff       	jmp    80051d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	85 c0                	test   %eax,%eax
  800607:	79 02                	jns    80060b <vprintfmt+0x111>
  800609:	f7 d8                	neg    %eax
  80060b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060d:	83 f8 10             	cmp    $0x10,%eax
  800610:	7f 0b                	jg     80061d <vprintfmt+0x123>
  800612:	8b 04 85 60 2e 80 00 	mov    0x802e60(,%eax,4),%eax
  800619:	85 c0                	test   %eax,%eax
  80061b:	75 23                	jne    800640 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80061d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800621:	c7 44 24 08 cf 2b 80 	movl   $0x802bcf,0x8(%esp)
  800628:	00 
  800629:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062d:	8b 45 08             	mov    0x8(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	e8 9a fe ff ff       	call   8004d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80063b:	e9 dd fe ff ff       	jmp    80051d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800640:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800644:	c7 44 24 08 6d 30 80 	movl   $0x80306d,0x8(%esp)
  80064b:	00 
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	8b 55 08             	mov    0x8(%ebp),%edx
  800653:	89 14 24             	mov    %edx,(%esp)
  800656:	e8 77 fe ff ff       	call   8004d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80065e:	e9 ba fe ff ff       	jmp    80051d <vprintfmt+0x23>
  800663:	89 f9                	mov    %edi,%ecx
  800665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800668:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 04             	lea    0x4(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)
  800674:	8b 30                	mov    (%eax),%esi
  800676:	85 f6                	test   %esi,%esi
  800678:	75 05                	jne    80067f <vprintfmt+0x185>
				p = "(null)";
  80067a:	be c8 2b 80 00       	mov    $0x802bc8,%esi
			if (width > 0 && padc != '-')
  80067f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800683:	0f 8e 84 00 00 00    	jle    80070d <vprintfmt+0x213>
  800689:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80068d:	74 7e                	je     80070d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800693:	89 34 24             	mov    %esi,(%esp)
  800696:	e8 8b 02 00 00       	call   800926 <strnlen>
  80069b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80069e:	29 c2                	sub    %eax,%edx
  8006a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006ad:	89 de                	mov    %ebx,%esi
  8006af:	89 d3                	mov    %edx,%ebx
  8006b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b3:	eb 0b                	jmp    8006c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b9:	89 3c 24             	mov    %edi,(%esp)
  8006bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bf:	4b                   	dec    %ebx
  8006c0:	85 db                	test   %ebx,%ebx
  8006c2:	7f f1                	jg     8006b5 <vprintfmt+0x1bb>
  8006c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006c7:	89 f3                	mov    %esi,%ebx
  8006c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	79 05                	jns    8006d8 <vprintfmt+0x1de>
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006db:	29 c2                	sub    %eax,%edx
  8006dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006e0:	eb 2b                	jmp    80070d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e6:	74 18                	je     800700 <vprintfmt+0x206>
  8006e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006eb:	83 fa 5e             	cmp    $0x5e,%edx
  8006ee:	76 10                	jbe    800700 <vprintfmt+0x206>
					putch('?', putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
  8006fe:	eb 0a                	jmp    80070a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070a:	ff 4d e4             	decl   -0x1c(%ebp)
  80070d:	0f be 06             	movsbl (%esi),%eax
  800710:	46                   	inc    %esi
  800711:	85 c0                	test   %eax,%eax
  800713:	74 21                	je     800736 <vprintfmt+0x23c>
  800715:	85 ff                	test   %edi,%edi
  800717:	78 c9                	js     8006e2 <vprintfmt+0x1e8>
  800719:	4f                   	dec    %edi
  80071a:	79 c6                	jns    8006e2 <vprintfmt+0x1e8>
  80071c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071f:	89 de                	mov    %ebx,%esi
  800721:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800724:	eb 18                	jmp    80073e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800731:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800733:	4b                   	dec    %ebx
  800734:	eb 08                	jmp    80073e <vprintfmt+0x244>
  800736:	8b 7d 08             	mov    0x8(%ebp),%edi
  800739:	89 de                	mov    %ebx,%esi
  80073b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80073e:	85 db                	test   %ebx,%ebx
  800740:	7f e4                	jg     800726 <vprintfmt+0x22c>
  800742:	89 7d 08             	mov    %edi,0x8(%ebp)
  800745:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800747:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074a:	e9 ce fd ff ff       	jmp    80051d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074f:	83 f9 01             	cmp    $0x1,%ecx
  800752:	7e 10                	jle    800764 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 08             	lea    0x8(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 30                	mov    (%eax),%esi
  80075f:	8b 78 04             	mov    0x4(%eax),%edi
  800762:	eb 26                	jmp    80078a <vprintfmt+0x290>
	else if (lflag)
  800764:	85 c9                	test   %ecx,%ecx
  800766:	74 12                	je     80077a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 50 04             	lea    0x4(%eax),%edx
  80076e:	89 55 14             	mov    %edx,0x14(%ebp)
  800771:	8b 30                	mov    (%eax),%esi
  800773:	89 f7                	mov    %esi,%edi
  800775:	c1 ff 1f             	sar    $0x1f,%edi
  800778:	eb 10                	jmp    80078a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)
  800783:	8b 30                	mov    (%eax),%esi
  800785:	89 f7                	mov    %esi,%edi
  800787:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80078a:	85 ff                	test   %edi,%edi
  80078c:	78 0a                	js     800798 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80078e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800793:	e9 8c 00 00 00       	jmp    800824 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007a6:	f7 de                	neg    %esi
  8007a8:	83 d7 00             	adc    $0x0,%edi
  8007ab:	f7 df                	neg    %edi
			}
			base = 10;
  8007ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b2:	eb 70                	jmp    800824 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b4:	89 ca                	mov    %ecx,%edx
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 c0 fc ff ff       	call   80047e <getuint>
  8007be:	89 c6                	mov    %eax,%esi
  8007c0:	89 d7                	mov    %edx,%edi
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007c7:	eb 5b                	jmp    800824 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8007c9:	89 ca                	mov    %ecx,%edx
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ce:	e8 ab fc ff ff       	call   80047e <getuint>
  8007d3:	89 c6                	mov    %eax,%esi
  8007d5:	89 d7                	mov    %edx,%edi
			base = 8;
  8007d7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007dc:	eb 46                	jmp    800824 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8007de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800803:	8b 30                	mov    (%eax),%esi
  800805:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80080f:	eb 13                	jmp    800824 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800811:	89 ca                	mov    %ecx,%edx
  800813:	8d 45 14             	lea    0x14(%ebp),%eax
  800816:	e8 63 fc ff ff       	call   80047e <getuint>
  80081b:	89 c6                	mov    %eax,%esi
  80081d:	89 d7                	mov    %edx,%edi
			base = 16;
  80081f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800824:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800828:	89 54 24 10          	mov    %edx,0x10(%esp)
  80082c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80082f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800833:	89 44 24 08          	mov    %eax,0x8(%esp)
  800837:	89 34 24             	mov    %esi,(%esp)
  80083a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80083e:	89 da                	mov    %ebx,%edx
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	e8 6c fb ff ff       	call   8003b4 <printnum>
			break;
  800848:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80084b:	e9 cd fc ff ff       	jmp    80051d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80085d:	e9 bb fc ff ff       	jmp    80051d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800862:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800866:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80086d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800870:	eb 01                	jmp    800873 <vprintfmt+0x379>
  800872:	4e                   	dec    %esi
  800873:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800877:	75 f9                	jne    800872 <vprintfmt+0x378>
  800879:	e9 9f fc ff ff       	jmp    80051d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80087e:	83 c4 4c             	add    $0x4c,%esp
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5f                   	pop    %edi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	83 ec 28             	sub    $0x28,%esp
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800892:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800895:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800899:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a3:	85 c0                	test   %eax,%eax
  8008a5:	74 30                	je     8008d7 <vsnprintf+0x51>
  8008a7:	85 d2                	test   %edx,%edx
  8008a9:	7e 33                	jle    8008de <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c0:	c7 04 24 b8 04 80 00 	movl   $0x8004b8,(%esp)
  8008c7:	e8 2e fc ff ff       	call   8004fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d5:	eb 0c                	jmp    8008e3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008dc:	eb 05                	jmp    8008e3 <vsnprintf+0x5d>
  8008de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	e8 7b ff ff ff       	call   800886 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    
  80090d:	00 00                	add    %al,(%eax)
	...

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 01                	jmp    80091e <strlen+0xe>
		n++;
  80091d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80091e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800922:	75 f9                	jne    80091d <strlen+0xd>
		n++;
	return n;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
  800934:	eb 01                	jmp    800937 <strnlen+0x11>
		n++;
  800936:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800937:	39 d0                	cmp    %edx,%eax
  800939:	74 06                	je     800941 <strnlen+0x1b>
  80093b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80093f:	75 f5                	jne    800936 <strnlen+0x10>
		n++;
	return n;
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
  800952:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800955:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800958:	42                   	inc    %edx
  800959:	84 c9                	test   %cl,%cl
  80095b:	75 f5                	jne    800952 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80095d:	5b                   	pop    %ebx
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	83 ec 08             	sub    $0x8,%esp
  800967:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096a:	89 1c 24             	mov    %ebx,(%esp)
  80096d:	e8 9e ff ff ff       	call   800910 <strlen>
	strcpy(dst + len, src);
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
  800975:	89 54 24 04          	mov    %edx,0x4(%esp)
  800979:	01 d8                	add    %ebx,%eax
  80097b:	89 04 24             	mov    %eax,(%esp)
  80097e:	e8 c0 ff ff ff       	call   800943 <strcpy>
	return dst;
}
  800983:	89 d8                	mov    %ebx,%eax
  800985:	83 c4 08             	add    $0x8,%esp
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 55 0c             	mov    0xc(%ebp),%edx
  800996:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800999:	b9 00 00 00 00       	mov    $0x0,%ecx
  80099e:	eb 0c                	jmp    8009ac <strncpy+0x21>
		*dst++ = *src;
  8009a0:	8a 1a                	mov    (%edx),%bl
  8009a2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a5:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ab:	41                   	inc    %ecx
  8009ac:	39 f1                	cmp    %esi,%ecx
  8009ae:	75 f0                	jne    8009a0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c2:	85 d2                	test   %edx,%edx
  8009c4:	75 0a                	jne    8009d0 <strlcpy+0x1c>
  8009c6:	89 f0                	mov    %esi,%eax
  8009c8:	eb 1a                	jmp    8009e4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ca:	88 18                	mov    %bl,(%eax)
  8009cc:	40                   	inc    %eax
  8009cd:	41                   	inc    %ecx
  8009ce:	eb 02                	jmp    8009d2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009d2:	4a                   	dec    %edx
  8009d3:	74 0a                	je     8009df <strlcpy+0x2b>
  8009d5:	8a 19                	mov    (%ecx),%bl
  8009d7:	84 db                	test   %bl,%bl
  8009d9:	75 ef                	jne    8009ca <strlcpy+0x16>
  8009db:	89 c2                	mov    %eax,%edx
  8009dd:	eb 02                	jmp    8009e1 <strlcpy+0x2d>
  8009df:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009e1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009e4:	29 f0                	sub    %esi,%eax
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f3:	eb 02                	jmp    8009f7 <strcmp+0xd>
		p++, q++;
  8009f5:	41                   	inc    %ecx
  8009f6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f7:	8a 01                	mov    (%ecx),%al
  8009f9:	84 c0                	test   %al,%al
  8009fb:	74 04                	je     800a01 <strcmp+0x17>
  8009fd:	3a 02                	cmp    (%edx),%al
  8009ff:	74 f4                	je     8009f5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a01:	0f b6 c0             	movzbl %al,%eax
  800a04:	0f b6 12             	movzbl (%edx),%edx
  800a07:	29 d0                	sub    %edx,%eax
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a15:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a18:	eb 03                	jmp    800a1d <strncmp+0x12>
		n--, p++, q++;
  800a1a:	4a                   	dec    %edx
  800a1b:	40                   	inc    %eax
  800a1c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a1d:	85 d2                	test   %edx,%edx
  800a1f:	74 14                	je     800a35 <strncmp+0x2a>
  800a21:	8a 18                	mov    (%eax),%bl
  800a23:	84 db                	test   %bl,%bl
  800a25:	74 04                	je     800a2b <strncmp+0x20>
  800a27:	3a 19                	cmp    (%ecx),%bl
  800a29:	74 ef                	je     800a1a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2b:	0f b6 00             	movzbl (%eax),%eax
  800a2e:	0f b6 11             	movzbl (%ecx),%edx
  800a31:	29 d0                	sub    %edx,%eax
  800a33:	eb 05                	jmp    800a3a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a46:	eb 05                	jmp    800a4d <strchr+0x10>
		if (*s == c)
  800a48:	38 ca                	cmp    %cl,%dl
  800a4a:	74 0c                	je     800a58 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4c:	40                   	inc    %eax
  800a4d:	8a 10                	mov    (%eax),%dl
  800a4f:	84 d2                	test   %dl,%dl
  800a51:	75 f5                	jne    800a48 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a63:	eb 05                	jmp    800a6a <strfind+0x10>
		if (*s == c)
  800a65:	38 ca                	cmp    %cl,%dl
  800a67:	74 07                	je     800a70 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a69:	40                   	inc    %eax
  800a6a:	8a 10                	mov    (%eax),%dl
  800a6c:	84 d2                	test   %dl,%dl
  800a6e:	75 f5                	jne    800a65 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	74 30                	je     800ab5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a85:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8b:	75 25                	jne    800ab2 <memset+0x40>
  800a8d:	f6 c1 03             	test   $0x3,%cl
  800a90:	75 20                	jne    800ab2 <memset+0x40>
		c &= 0xFF;
  800a92:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a95:	89 d3                	mov    %edx,%ebx
  800a97:	c1 e3 08             	shl    $0x8,%ebx
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	c1 e6 18             	shl    $0x18,%esi
  800a9f:	89 d0                	mov    %edx,%eax
  800aa1:	c1 e0 10             	shl    $0x10,%eax
  800aa4:	09 f0                	or     %esi,%eax
  800aa6:	09 d0                	or     %edx,%eax
  800aa8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aaa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aad:	fc                   	cld    
  800aae:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab0:	eb 03                	jmp    800ab5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab2:	fc                   	cld    
  800ab3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab5:	89 f8                	mov    %edi,%eax
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aca:	39 c6                	cmp    %eax,%esi
  800acc:	73 34                	jae    800b02 <memmove+0x46>
  800ace:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad1:	39 d0                	cmp    %edx,%eax
  800ad3:	73 2d                	jae    800b02 <memmove+0x46>
		s += n;
		d += n;
  800ad5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad8:	f6 c2 03             	test   $0x3,%dl
  800adb:	75 1b                	jne    800af8 <memmove+0x3c>
  800add:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae3:	75 13                	jne    800af8 <memmove+0x3c>
  800ae5:	f6 c1 03             	test   $0x3,%cl
  800ae8:	75 0e                	jne    800af8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aea:	83 ef 04             	sub    $0x4,%edi
  800aed:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800af3:	fd                   	std    
  800af4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af6:	eb 07                	jmp    800aff <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af8:	4f                   	dec    %edi
  800af9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800afc:	fd                   	std    
  800afd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aff:	fc                   	cld    
  800b00:	eb 20                	jmp    800b22 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b02:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b08:	75 13                	jne    800b1d <memmove+0x61>
  800b0a:	a8 03                	test   $0x3,%al
  800b0c:	75 0f                	jne    800b1d <memmove+0x61>
  800b0e:	f6 c1 03             	test   $0x3,%cl
  800b11:	75 0a                	jne    800b1d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b13:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b16:	89 c7                	mov    %eax,%edi
  800b18:	fc                   	cld    
  800b19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1b:	eb 05                	jmp    800b22 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1d:	89 c7                	mov    %eax,%edi
  800b1f:	fc                   	cld    
  800b20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	89 04 24             	mov    %eax,(%esp)
  800b40:	e8 77 ff ff ff       	call   800abc <memmove>
}
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	eb 16                	jmp    800b73 <memcmp+0x2c>
		if (*s1 != *s2)
  800b5d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b60:	42                   	inc    %edx
  800b61:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b65:	38 c8                	cmp    %cl,%al
  800b67:	74 0a                	je     800b73 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b69:	0f b6 c0             	movzbl %al,%eax
  800b6c:	0f b6 c9             	movzbl %cl,%ecx
  800b6f:	29 c8                	sub    %ecx,%eax
  800b71:	eb 09                	jmp    800b7c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b73:	39 da                	cmp    %ebx,%edx
  800b75:	75 e6                	jne    800b5d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8f:	eb 05                	jmp    800b96 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b91:	38 08                	cmp    %cl,(%eax)
  800b93:	74 05                	je     800b9a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b95:	40                   	inc    %eax
  800b96:	39 d0                	cmp    %edx,%eax
  800b98:	72 f7                	jb     800b91 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba8:	eb 01                	jmp    800bab <strtol+0xf>
		s++;
  800baa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bab:	8a 02                	mov    (%edx),%al
  800bad:	3c 20                	cmp    $0x20,%al
  800baf:	74 f9                	je     800baa <strtol+0xe>
  800bb1:	3c 09                	cmp    $0x9,%al
  800bb3:	74 f5                	je     800baa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bb5:	3c 2b                	cmp    $0x2b,%al
  800bb7:	75 08                	jne    800bc1 <strtol+0x25>
		s++;
  800bb9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bba:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbf:	eb 13                	jmp    800bd4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bc1:	3c 2d                	cmp    $0x2d,%al
  800bc3:	75 0a                	jne    800bcf <strtol+0x33>
		s++, neg = 1;
  800bc5:	8d 52 01             	lea    0x1(%edx),%edx
  800bc8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bcd:	eb 05                	jmp    800bd4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bcf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd4:	85 db                	test   %ebx,%ebx
  800bd6:	74 05                	je     800bdd <strtol+0x41>
  800bd8:	83 fb 10             	cmp    $0x10,%ebx
  800bdb:	75 28                	jne    800c05 <strtol+0x69>
  800bdd:	8a 02                	mov    (%edx),%al
  800bdf:	3c 30                	cmp    $0x30,%al
  800be1:	75 10                	jne    800bf3 <strtol+0x57>
  800be3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800be7:	75 0a                	jne    800bf3 <strtol+0x57>
		s += 2, base = 16;
  800be9:	83 c2 02             	add    $0x2,%edx
  800bec:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bf1:	eb 12                	jmp    800c05 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bf3:	85 db                	test   %ebx,%ebx
  800bf5:	75 0e                	jne    800c05 <strtol+0x69>
  800bf7:	3c 30                	cmp    $0x30,%al
  800bf9:	75 05                	jne    800c00 <strtol+0x64>
		s++, base = 8;
  800bfb:	42                   	inc    %edx
  800bfc:	b3 08                	mov    $0x8,%bl
  800bfe:	eb 05                	jmp    800c05 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c00:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c05:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c0c:	8a 0a                	mov    (%edx),%cl
  800c0e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c11:	80 fb 09             	cmp    $0x9,%bl
  800c14:	77 08                	ja     800c1e <strtol+0x82>
			dig = *s - '0';
  800c16:	0f be c9             	movsbl %cl,%ecx
  800c19:	83 e9 30             	sub    $0x30,%ecx
  800c1c:	eb 1e                	jmp    800c3c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c1e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c21:	80 fb 19             	cmp    $0x19,%bl
  800c24:	77 08                	ja     800c2e <strtol+0x92>
			dig = *s - 'a' + 10;
  800c26:	0f be c9             	movsbl %cl,%ecx
  800c29:	83 e9 57             	sub    $0x57,%ecx
  800c2c:	eb 0e                	jmp    800c3c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c2e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c31:	80 fb 19             	cmp    $0x19,%bl
  800c34:	77 12                	ja     800c48 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c36:	0f be c9             	movsbl %cl,%ecx
  800c39:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c3c:	39 f1                	cmp    %esi,%ecx
  800c3e:	7d 0c                	jge    800c4c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c40:	42                   	inc    %edx
  800c41:	0f af c6             	imul   %esi,%eax
  800c44:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c46:	eb c4                	jmp    800c0c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c48:	89 c1                	mov    %eax,%ecx
  800c4a:	eb 02                	jmp    800c4e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c4c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c52:	74 05                	je     800c59 <strtol+0xbd>
		*endptr = (char *) s;
  800c54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c57:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c59:	85 ff                	test   %edi,%edi
  800c5b:	74 04                	je     800c61 <strtol+0xc5>
  800c5d:	89 c8                	mov    %ecx,%eax
  800c5f:	f7 d8                	neg    %eax
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    
	...

00800c68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 c3                	mov    %eax,%ebx
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	89 c6                	mov    %eax,%esi
  800c7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 01 00 00 00       	mov    $0x1,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 cb                	mov    %ecx,%ebx
  800cbd:	89 cf                	mov    %ecx,%edi
  800cbf:	89 ce                	mov    %ecx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 28                	jle    800cef <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 08 c3 2e 80 	movl   $0x802ec3,0x8(%esp)
  800cda:	00 
  800cdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce2:	00 
  800ce3:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  800cea:	e8 b1 f5 ff ff       	call   8002a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cef:	83 c4 2c             	add    $0x2c,%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 02 00 00 00       	mov    $0x2,%eax
  800d07:	89 d1                	mov    %edx,%ecx
  800d09:	89 d3                	mov    %edx,%ebx
  800d0b:	89 d7                	mov    %edx,%edi
  800d0d:	89 d6                	mov    %edx,%esi
  800d0f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_yield>:

void
sys_yield(void)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d26:	89 d1                	mov    %edx,%ecx
  800d28:	89 d3                	mov    %edx,%ebx
  800d2a:	89 d7                	mov    %edx,%edi
  800d2c:	89 d6                	mov    %edx,%esi
  800d2e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d3e:	be 00 00 00 00       	mov    $0x0,%esi
  800d43:	b8 04 00 00 00       	mov    $0x4,%eax
  800d48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	89 f7                	mov    %esi,%edi
  800d53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 28                	jle    800d81 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d64:	00 
  800d65:	c7 44 24 08 c3 2e 80 	movl   $0x802ec3,0x8(%esp)
  800d6c:	00 
  800d6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d74:	00 
  800d75:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  800d7c:	e8 1f f5 ff ff       	call   8002a0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d81:	83 c4 2c             	add    $0x2c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	b8 05 00 00 00       	mov    $0x5,%eax
  800d97:	8b 75 18             	mov    0x18(%ebp),%esi
  800d9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 28                	jle    800dd4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800db7:	00 
  800db8:	c7 44 24 08 c3 2e 80 	movl   $0x802ec3,0x8(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc7:	00 
  800dc8:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  800dcf:	e8 cc f4 ff ff       	call   8002a0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dd4:	83 c4 2c             	add    $0x2c,%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dea:	b8 06 00 00 00       	mov    $0x6,%eax
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	89 df                	mov    %ebx,%edi
  800df7:	89 de                	mov    %ebx,%esi
  800df9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	7e 28                	jle    800e27 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e03:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 08 c3 2e 80 	movl   $0x802ec3,0x8(%esp)
  800e12:	00 
  800e13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1a:	00 
  800e1b:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  800e22:	e8 79 f4 ff ff       	call   8002a0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e27:	83 c4 2c             	add    $0x2c,%esp
  800e2a:	5b                   	pop    %ebx
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
  800e33:	56                   	push   %esi
  800e34:	53                   	push   %ebx
  800e35:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	89 df                	mov    %ebx,%edi
  800e4a:	89 de                	mov    %ebx,%esi
  800e4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	7e 28                	jle    800e7a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e56:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 08 c3 2e 80 	movl   $0x802ec3,0x8(%esp)
  800e65:	00 
  800e66:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6d:	00 
  800e6e:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  800e75:	e8 26 f4 ff ff       	call   8002a0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e7a:	83 c4 2c             	add    $0x2c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e90:	b8 09 00 00 00       	mov    $0x9,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	89 df                	mov    %ebx,%edi
  800e9d:	89 de                	mov    %ebx,%esi
  800e9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	7e 28                	jle    800ecd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 08 c3 2e 80 	movl   $0x802ec3,0x8(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec0:	00 
  800ec1:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  800ec8:	e8 d3 f3 ff ff       	call   8002a0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ecd:	83 c4 2c             	add    $0x2c,%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	89 df                	mov    %ebx,%edi
  800ef0:	89 de                	mov    %ebx,%esi
  800ef2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	7e 28                	jle    800f20 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f03:	00 
  800f04:	c7 44 24 08 c3 2e 80 	movl   $0x802ec3,0x8(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f13:	00 
  800f14:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  800f1b:	e8 80 f3 ff ff       	call   8002a0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f20:	83 c4 2c             	add    $0x2c,%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	be 00 00 00 00       	mov    $0x0,%esi
  800f33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f61:	89 cb                	mov    %ecx,%ebx
  800f63:	89 cf                	mov    %ecx,%edi
  800f65:	89 ce                	mov    %ecx,%esi
  800f67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 28                	jle    800f95 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f71:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f78:	00 
  800f79:	c7 44 24 08 c3 2e 80 	movl   $0x802ec3,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  800f90:	e8 0b f3 ff ff       	call   8002a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f95:	83 c4 2c             	add    $0x2c,%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fad:	89 d1                	mov    %edx,%ecx
  800faf:	89 d3                	mov    %edx,%ebx
  800fb1:	89 d7                	mov    %edx,%edi
  800fb3:	89 d6                	mov    %edx,%esi
  800fb5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5f                   	pop    %edi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	57                   	push   %edi
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc7:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd2:	89 df                	mov    %ebx,%edi
  800fd4:	89 de                	mov    %ebx,%esi
  800fd6:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe8:	b8 10 00 00 00       	mov    $0x10,%eax
  800fed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff3:	89 df                	mov    %ebx,%edi
  800ff5:	89 de                	mov    %ebx,%esi
  800ff7:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800ff9:	5b                   	pop    %ebx
  800ffa:	5e                   	pop    %esi
  800ffb:	5f                   	pop    %edi
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    
	...

00801000 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	53                   	push   %ebx
  801004:	83 ec 24             	sub    $0x24,%esp
  801007:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80100a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  80100c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801010:	74 2d                	je     80103f <pgfault+0x3f>
  801012:	89 d8                	mov    %ebx,%eax
  801014:	c1 e8 16             	shr    $0x16,%eax
  801017:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101e:	a8 01                	test   $0x1,%al
  801020:	74 1d                	je     80103f <pgfault+0x3f>
  801022:	89 d8                	mov    %ebx,%eax
  801024:	c1 e8 0c             	shr    $0xc,%eax
  801027:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102e:	f6 c2 01             	test   $0x1,%dl
  801031:	74 0c                	je     80103f <pgfault+0x3f>
  801033:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103a:	f6 c4 08             	test   $0x8,%ah
  80103d:	75 1c                	jne    80105b <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  80103f:	c7 44 24 08 f0 2e 80 	movl   $0x802ef0,0x8(%esp)
  801046:	00 
  801047:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80104e:	00 
  80104f:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  801056:	e8 45 f2 ff ff       	call   8002a0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  80105b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  801061:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801078:	e8 b8 fc ff ff       	call   800d35 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  80107d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801084:	00 
  801085:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801089:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801090:	e8 91 fa ff ff       	call   800b26 <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  801095:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80109c:	00 
  80109d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b8:	e8 cc fc ff ff       	call   800d89 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  8010bd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010c4:	00 
  8010c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cc:	e8 0b fd ff ff       	call   800ddc <sys_page_unmap>

	// panic("pgfault not implemented");
}
  8010d1:	83 c4 24             	add    $0x24,%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8010e0:	c7 04 24 00 10 80 00 	movl   $0x801000,(%esp)
  8010e7:	e8 f0 16 00 00       	call   8027dc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010ec:	ba 07 00 00 00       	mov    $0x7,%edx
  8010f1:	89 d0                	mov    %edx,%eax
  8010f3:	cd 30                	int    $0x30
  8010f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010f8:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 20                	jns    80111e <fork+0x47>
		panic("sys_exofork: %e", envid);
  8010fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801102:	c7 44 24 08 3e 2f 80 	movl   $0x802f3e,0x8(%esp)
  801109:	00 
  80110a:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801111:	00 
  801112:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  801119:	e8 82 f1 ff ff       	call   8002a0 <_panic>
	if (envid == 0)
  80111e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801122:	75 25                	jne    801149 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  801124:	e8 ce fb ff ff       	call   800cf7 <sys_getenvid>
  801129:	25 ff 03 00 00       	and    $0x3ff,%eax
  80112e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801135:	c1 e0 07             	shl    $0x7,%eax
  801138:	29 d0                	sub    %edx,%eax
  80113a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80113f:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801144:	e9 43 02 00 00       	jmp    80138c <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  801149:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  80114e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801154:	0f 84 85 01 00 00    	je     8012df <fork+0x208>
  80115a:	89 d8                	mov    %ebx,%eax
  80115c:	c1 e8 16             	shr    $0x16,%eax
  80115f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801166:	a8 01                	test   $0x1,%al
  801168:	0f 84 5f 01 00 00    	je     8012cd <fork+0x1f6>
  80116e:	89 d8                	mov    %ebx,%eax
  801170:	c1 e8 0c             	shr    $0xc,%eax
  801173:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80117a:	f6 c2 01             	test   $0x1,%dl
  80117d:	0f 84 4a 01 00 00    	je     8012cd <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  801183:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  801185:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80118c:	f6 c6 04             	test   $0x4,%dh
  80118f:	74 50                	je     8011e1 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  801191:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801198:	25 07 0e 00 00       	and    $0xe07,%eax
  80119d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011a5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b4:	e8 d0 fb ff ff       	call   800d89 <sys_page_map>
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	0f 89 0c 01 00 00    	jns    8012cd <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  8011c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c5:	c7 44 24 08 4e 2f 80 	movl   $0x802f4e,0x8(%esp)
  8011cc:	00 
  8011cd:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  8011dc:	e8 bf f0 ff ff       	call   8002a0 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  8011e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011e8:	f6 c2 02             	test   $0x2,%dl
  8011eb:	75 10                	jne    8011fd <fork+0x126>
  8011ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011f4:	f6 c4 08             	test   $0x8,%ah
  8011f7:	0f 84 8c 00 00 00    	je     801289 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  8011fd:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801204:	00 
  801205:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801209:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80120d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801211:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801218:	e8 6c fb ff ff       	call   800d89 <sys_page_map>
  80121d:	85 c0                	test   %eax,%eax
  80121f:	79 20                	jns    801241 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801225:	c7 44 24 08 4e 2f 80 	movl   $0x802f4e,0x8(%esp)
  80122c:	00 
  80122d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801234:	00 
  801235:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  80123c:	e8 5f f0 ff ff       	call   8002a0 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801241:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801248:	00 
  801249:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80124d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801254:	00 
  801255:	89 74 24 04          	mov    %esi,0x4(%esp)
  801259:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801260:	e8 24 fb ff ff       	call   800d89 <sys_page_map>
  801265:	85 c0                	test   %eax,%eax
  801267:	79 64                	jns    8012cd <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80126d:	c7 44 24 08 4e 2f 80 	movl   $0x802f4e,0x8(%esp)
  801274:	00 
  801275:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  80127c:	00 
  80127d:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  801284:	e8 17 f0 ff ff       	call   8002a0 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  801289:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801290:	00 
  801291:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801295:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801299:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80129d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a4:	e8 e0 fa ff ff       	call   800d89 <sys_page_map>
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	79 20                	jns    8012cd <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8012ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b1:	c7 44 24 08 4e 2f 80 	movl   $0x802f4e,0x8(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8012c0:	00 
  8012c1:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  8012c8:	e8 d3 ef ff ff       	call   8002a0 <_panic>
  8012cd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  8012d3:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8012d9:	0f 85 6f fe ff ff    	jne    80114e <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  8012df:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012e6:	00 
  8012e7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012ee:	ee 
  8012ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 3b fa ff ff       	call   800d35 <sys_page_alloc>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	79 20                	jns    80131e <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  8012fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801302:	c7 44 24 08 60 2f 80 	movl   $0x802f60,0x8(%esp)
  801309:	00 
  80130a:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801311:	00 
  801312:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  801319:	e8 82 ef ff ff       	call   8002a0 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80131e:	c7 44 24 04 28 28 80 	movl   $0x802828,0x4(%esp)
  801325:	00 
  801326:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801329:	89 04 24             	mov    %eax,(%esp)
  80132c:	e8 a4 fb ff ff       	call   800ed5 <sys_env_set_pgfault_upcall>
  801331:	85 c0                	test   %eax,%eax
  801333:	79 20                	jns    801355 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  801335:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801339:	c7 44 24 08 14 2f 80 	movl   $0x802f14,0x8(%esp)
  801340:	00 
  801341:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801348:	00 
  801349:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  801350:	e8 4b ef ff ff       	call   8002a0 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801355:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80135c:	00 
  80135d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801360:	89 04 24             	mov    %eax,(%esp)
  801363:	e8 c7 fa ff ff       	call   800e2f <sys_env_set_status>
  801368:	85 c0                	test   %eax,%eax
  80136a:	79 20                	jns    80138c <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  80136c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801370:	c7 44 24 08 73 2f 80 	movl   $0x802f73,0x8(%esp)
  801377:	00 
  801378:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80137f:	00 
  801380:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  801387:	e8 14 ef ff ff       	call   8002a0 <_panic>

	return envid;
	// panic("fork not implemented");
}
  80138c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80138f:	83 c4 3c             	add    $0x3c,%esp
  801392:	5b                   	pop    %ebx
  801393:	5e                   	pop    %esi
  801394:	5f                   	pop    %edi
  801395:	5d                   	pop    %ebp
  801396:	c3                   	ret    

00801397 <sfork>:

// Challenge!
int
sfork(void)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80139d:	c7 44 24 08 8a 2f 80 	movl   $0x802f8a,0x8(%esp)
  8013a4:	00 
  8013a5:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8013ac:	00 
  8013ad:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  8013b4:	e8 e7 ee ff ff       	call   8002a0 <_panic>
  8013b9:	00 00                	add    %al,(%eax)
	...

008013bc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 10             	sub    $0x10,%esp
  8013c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ca:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 0a                	je     8013db <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8013d1:	89 04 24             	mov    %eax,(%esp)
  8013d4:	e8 72 fb ff ff       	call   800f4b <sys_ipc_recv>
  8013d9:	eb 0c                	jmp    8013e7 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8013db:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8013e2:	e8 64 fb ff ff       	call   800f4b <sys_ipc_recv>
	}
	if (r < 0)
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	79 16                	jns    801401 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8013eb:	85 db                	test   %ebx,%ebx
  8013ed:	74 06                	je     8013f5 <ipc_recv+0x39>
  8013ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8013f5:	85 f6                	test   %esi,%esi
  8013f7:	74 2c                	je     801425 <ipc_recv+0x69>
  8013f9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8013ff:	eb 24                	jmp    801425 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  801401:	85 db                	test   %ebx,%ebx
  801403:	74 0a                	je     80140f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  801405:	a1 08 50 80 00       	mov    0x805008,%eax
  80140a:	8b 40 74             	mov    0x74(%eax),%eax
  80140d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80140f:	85 f6                	test   %esi,%esi
  801411:	74 0a                	je     80141d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  801413:	a1 08 50 80 00       	mov    0x805008,%eax
  801418:	8b 40 78             	mov    0x78(%eax),%eax
  80141b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80141d:	a1 08 50 80 00       	mov    0x805008,%eax
  801422:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	5b                   	pop    %ebx
  801429:	5e                   	pop    %esi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	57                   	push   %edi
  801430:	56                   	push   %esi
  801431:	53                   	push   %ebx
  801432:	83 ec 1c             	sub    $0x1c,%esp
  801435:	8b 75 08             	mov    0x8(%ebp),%esi
  801438:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80143b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80143e:	85 db                	test   %ebx,%ebx
  801440:	74 19                	je     80145b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  801442:	8b 45 14             	mov    0x14(%ebp),%eax
  801445:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80144d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801451:	89 34 24             	mov    %esi,(%esp)
  801454:	e8 cf fa ff ff       	call   800f28 <sys_ipc_try_send>
  801459:	eb 1c                	jmp    801477 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80145b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801462:	00 
  801463:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80146a:	ee 
  80146b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80146f:	89 34 24             	mov    %esi,(%esp)
  801472:	e8 b1 fa ff ff       	call   800f28 <sys_ipc_try_send>
		}
		if (r == 0)
  801477:	85 c0                	test   %eax,%eax
  801479:	74 2c                	je     8014a7 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80147b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80147e:	74 20                	je     8014a0 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  801480:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801484:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  80148b:	00 
  80148c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801493:	00 
  801494:	c7 04 24 b3 2f 80 00 	movl   $0x802fb3,(%esp)
  80149b:	e8 00 ee ff ff       	call   8002a0 <_panic>
		}
		sys_yield();
  8014a0:	e8 71 f8 ff ff       	call   800d16 <sys_yield>
	}
  8014a5:	eb 97                	jmp    80143e <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8014a7:	83 c4 1c             	add    $0x1c,%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	5f                   	pop    %edi
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    

008014af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	53                   	push   %ebx
  8014b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8014b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014bb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8014c2:	89 c2                	mov    %eax,%edx
  8014c4:	c1 e2 07             	shl    $0x7,%edx
  8014c7:	29 ca                	sub    %ecx,%edx
  8014c9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014cf:	8b 52 50             	mov    0x50(%edx),%edx
  8014d2:	39 da                	cmp    %ebx,%edx
  8014d4:	75 0f                	jne    8014e5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8014d6:	c1 e0 07             	shl    $0x7,%eax
  8014d9:	29 c8                	sub    %ecx,%eax
  8014db:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014e0:	8b 40 40             	mov    0x40(%eax),%eax
  8014e3:	eb 0c                	jmp    8014f1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014e5:	40                   	inc    %eax
  8014e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014eb:	75 ce                	jne    8014bb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014ed:	66 b8 00 00          	mov    $0x0,%ax
}
  8014f1:	5b                   	pop    %ebx
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8014ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80150a:	8b 45 08             	mov    0x8(%ebp),%eax
  80150d:	89 04 24             	mov    %eax,(%esp)
  801510:	e8 df ff ff ff       	call   8014f4 <fd2num>
  801515:	c1 e0 0c             	shl    $0xc,%eax
  801518:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	53                   	push   %ebx
  801523:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801526:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80152b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	c1 ea 16             	shr    $0x16,%edx
  801532:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801539:	f6 c2 01             	test   $0x1,%dl
  80153c:	74 11                	je     80154f <fd_alloc+0x30>
  80153e:	89 c2                	mov    %eax,%edx
  801540:	c1 ea 0c             	shr    $0xc,%edx
  801543:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80154a:	f6 c2 01             	test   $0x1,%dl
  80154d:	75 09                	jne    801558 <fd_alloc+0x39>
			*fd_store = fd;
  80154f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
  801556:	eb 17                	jmp    80156f <fd_alloc+0x50>
  801558:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80155d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801562:	75 c7                	jne    80152b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801564:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80156a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80156f:	5b                   	pop    %ebx
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    

00801572 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801578:	83 f8 1f             	cmp    $0x1f,%eax
  80157b:	77 36                	ja     8015b3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80157d:	c1 e0 0c             	shl    $0xc,%eax
  801580:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801585:	89 c2                	mov    %eax,%edx
  801587:	c1 ea 16             	shr    $0x16,%edx
  80158a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801591:	f6 c2 01             	test   $0x1,%dl
  801594:	74 24                	je     8015ba <fd_lookup+0x48>
  801596:	89 c2                	mov    %eax,%edx
  801598:	c1 ea 0c             	shr    $0xc,%edx
  80159b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015a2:	f6 c2 01             	test   $0x1,%dl
  8015a5:	74 1a                	je     8015c1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015aa:	89 02                	mov    %eax,(%edx)
	return 0;
  8015ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b1:	eb 13                	jmp    8015c6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b8:	eb 0c                	jmp    8015c6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bf:	eb 05                	jmp    8015c6 <fd_lookup+0x54>
  8015c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 14             	sub    $0x14,%esp
  8015cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8015d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015da:	eb 0e                	jmp    8015ea <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8015dc:	39 08                	cmp    %ecx,(%eax)
  8015de:	75 09                	jne    8015e9 <dev_lookup+0x21>
			*dev = devtab[i];
  8015e0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e7:	eb 33                	jmp    80161c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015e9:	42                   	inc    %edx
  8015ea:	8b 04 95 40 30 80 00 	mov    0x803040(,%edx,4),%eax
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	75 e7                	jne    8015dc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015f5:	a1 08 50 80 00       	mov    0x805008,%eax
  8015fa:	8b 40 48             	mov    0x48(%eax),%eax
  8015fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801601:	89 44 24 04          	mov    %eax,0x4(%esp)
  801605:	c7 04 24 c0 2f 80 00 	movl   $0x802fc0,(%esp)
  80160c:	e8 87 ed ff ff       	call   800398 <cprintf>
	*dev = 0;
  801611:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801617:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80161c:	83 c4 14             	add    $0x14,%esp
  80161f:	5b                   	pop    %ebx
  801620:	5d                   	pop    %ebp
  801621:	c3                   	ret    

00801622 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	56                   	push   %esi
  801626:	53                   	push   %ebx
  801627:	83 ec 30             	sub    $0x30,%esp
  80162a:	8b 75 08             	mov    0x8(%ebp),%esi
  80162d:	8a 45 0c             	mov    0xc(%ebp),%al
  801630:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801633:	89 34 24             	mov    %esi,(%esp)
  801636:	e8 b9 fe ff ff       	call   8014f4 <fd2num>
  80163b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80163e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801642:	89 04 24             	mov    %eax,(%esp)
  801645:	e8 28 ff ff ff       	call   801572 <fd_lookup>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 05                	js     801655 <fd_close+0x33>
	    || fd != fd2)
  801650:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801653:	74 0d                	je     801662 <fd_close+0x40>
		return (must_exist ? r : 0);
  801655:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801659:	75 46                	jne    8016a1 <fd_close+0x7f>
  80165b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801660:	eb 3f                	jmp    8016a1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801662:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801665:	89 44 24 04          	mov    %eax,0x4(%esp)
  801669:	8b 06                	mov    (%esi),%eax
  80166b:	89 04 24             	mov    %eax,(%esp)
  80166e:	e8 55 ff ff ff       	call   8015c8 <dev_lookup>
  801673:	89 c3                	mov    %eax,%ebx
  801675:	85 c0                	test   %eax,%eax
  801677:	78 18                	js     801691 <fd_close+0x6f>
		if (dev->dev_close)
  801679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167c:	8b 40 10             	mov    0x10(%eax),%eax
  80167f:	85 c0                	test   %eax,%eax
  801681:	74 09                	je     80168c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801683:	89 34 24             	mov    %esi,(%esp)
  801686:	ff d0                	call   *%eax
  801688:	89 c3                	mov    %eax,%ebx
  80168a:	eb 05                	jmp    801691 <fd_close+0x6f>
		else
			r = 0;
  80168c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801691:	89 74 24 04          	mov    %esi,0x4(%esp)
  801695:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169c:	e8 3b f7 ff ff       	call   800ddc <sys_page_unmap>
	return r;
}
  8016a1:	89 d8                	mov    %ebx,%eax
  8016a3:	83 c4 30             	add    $0x30,%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ba:	89 04 24             	mov    %eax,(%esp)
  8016bd:	e8 b0 fe ff ff       	call   801572 <fd_lookup>
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 13                	js     8016d9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016cd:	00 
  8016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d1:	89 04 24             	mov    %eax,(%esp)
  8016d4:	e8 49 ff ff ff       	call   801622 <fd_close>
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <close_all>:

void
close_all(void)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	53                   	push   %ebx
  8016df:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016e7:	89 1c 24             	mov    %ebx,(%esp)
  8016ea:	e8 bb ff ff ff       	call   8016aa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ef:	43                   	inc    %ebx
  8016f0:	83 fb 20             	cmp    $0x20,%ebx
  8016f3:	75 f2                	jne    8016e7 <close_all+0xc>
		close(i);
}
  8016f5:	83 c4 14             	add    $0x14,%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	57                   	push   %edi
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	83 ec 4c             	sub    $0x4c,%esp
  801704:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801707:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80170a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170e:	8b 45 08             	mov    0x8(%ebp),%eax
  801711:	89 04 24             	mov    %eax,(%esp)
  801714:	e8 59 fe ff ff       	call   801572 <fd_lookup>
  801719:	89 c3                	mov    %eax,%ebx
  80171b:	85 c0                	test   %eax,%eax
  80171d:	0f 88 e3 00 00 00    	js     801806 <dup+0x10b>
		return r;
	close(newfdnum);
  801723:	89 3c 24             	mov    %edi,(%esp)
  801726:	e8 7f ff ff ff       	call   8016aa <close>

	newfd = INDEX2FD(newfdnum);
  80172b:	89 fe                	mov    %edi,%esi
  80172d:	c1 e6 0c             	shl    $0xc,%esi
  801730:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801736:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801739:	89 04 24             	mov    %eax,(%esp)
  80173c:	e8 c3 fd ff ff       	call   801504 <fd2data>
  801741:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801743:	89 34 24             	mov    %esi,(%esp)
  801746:	e8 b9 fd ff ff       	call   801504 <fd2data>
  80174b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80174e:	89 d8                	mov    %ebx,%eax
  801750:	c1 e8 16             	shr    $0x16,%eax
  801753:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80175a:	a8 01                	test   $0x1,%al
  80175c:	74 46                	je     8017a4 <dup+0xa9>
  80175e:	89 d8                	mov    %ebx,%eax
  801760:	c1 e8 0c             	shr    $0xc,%eax
  801763:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80176a:	f6 c2 01             	test   $0x1,%dl
  80176d:	74 35                	je     8017a4 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80176f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801776:	25 07 0e 00 00       	and    $0xe07,%eax
  80177b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80177f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801782:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801786:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80178d:	00 
  80178e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801792:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801799:	e8 eb f5 ff ff       	call   800d89 <sys_page_map>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 3b                	js     8017df <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a7:	89 c2                	mov    %eax,%edx
  8017a9:	c1 ea 0c             	shr    $0xc,%edx
  8017ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017b3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017bd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017c8:	00 
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d4:	e8 b0 f5 ff ff       	call   800d89 <sys_page_map>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	79 25                	jns    801804 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ea:	e8 ed f5 ff ff       	call   800ddc <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fd:	e8 da f5 ff ff       	call   800ddc <sys_page_unmap>
	return r;
  801802:	eb 02                	jmp    801806 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801804:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801806:	89 d8                	mov    %ebx,%eax
  801808:	83 c4 4c             	add    $0x4c,%esp
  80180b:	5b                   	pop    %ebx
  80180c:	5e                   	pop    %esi
  80180d:	5f                   	pop    %edi
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	53                   	push   %ebx
  801814:	83 ec 24             	sub    $0x24,%esp
  801817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	89 1c 24             	mov    %ebx,(%esp)
  801824:	e8 49 fd ff ff       	call   801572 <fd_lookup>
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 6d                	js     80189a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801830:	89 44 24 04          	mov    %eax,0x4(%esp)
  801834:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801837:	8b 00                	mov    (%eax),%eax
  801839:	89 04 24             	mov    %eax,(%esp)
  80183c:	e8 87 fd ff ff       	call   8015c8 <dev_lookup>
  801841:	85 c0                	test   %eax,%eax
  801843:	78 55                	js     80189a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801845:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801848:	8b 50 08             	mov    0x8(%eax),%edx
  80184b:	83 e2 03             	and    $0x3,%edx
  80184e:	83 fa 01             	cmp    $0x1,%edx
  801851:	75 23                	jne    801876 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801853:	a1 08 50 80 00       	mov    0x805008,%eax
  801858:	8b 40 48             	mov    0x48(%eax),%eax
  80185b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	c7 04 24 04 30 80 00 	movl   $0x803004,(%esp)
  80186a:	e8 29 eb ff ff       	call   800398 <cprintf>
		return -E_INVAL;
  80186f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801874:	eb 24                	jmp    80189a <read+0x8a>
	}
	if (!dev->dev_read)
  801876:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801879:	8b 52 08             	mov    0x8(%edx),%edx
  80187c:	85 d2                	test   %edx,%edx
  80187e:	74 15                	je     801895 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801880:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801883:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80188a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80188e:	89 04 24             	mov    %eax,(%esp)
  801891:	ff d2                	call   *%edx
  801893:	eb 05                	jmp    80189a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801895:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80189a:	83 c4 24             	add    $0x24,%esp
  80189d:	5b                   	pop    %ebx
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	57                   	push   %edi
  8018a4:	56                   	push   %esi
  8018a5:	53                   	push   %ebx
  8018a6:	83 ec 1c             	sub    $0x1c,%esp
  8018a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018b4:	eb 23                	jmp    8018d9 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018b6:	89 f0                	mov    %esi,%eax
  8018b8:	29 d8                	sub    %ebx,%eax
  8018ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c1:	01 d8                	add    %ebx,%eax
  8018c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c7:	89 3c 24             	mov    %edi,(%esp)
  8018ca:	e8 41 ff ff ff       	call   801810 <read>
		if (m < 0)
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 10                	js     8018e3 <readn+0x43>
			return m;
		if (m == 0)
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	74 0a                	je     8018e1 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018d7:	01 c3                	add    %eax,%ebx
  8018d9:	39 f3                	cmp    %esi,%ebx
  8018db:	72 d9                	jb     8018b6 <readn+0x16>
  8018dd:	89 d8                	mov    %ebx,%eax
  8018df:	eb 02                	jmp    8018e3 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018e1:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018e3:	83 c4 1c             	add    $0x1c,%esp
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5f                   	pop    %edi
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 24             	sub    $0x24,%esp
  8018f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fc:	89 1c 24             	mov    %ebx,(%esp)
  8018ff:	e8 6e fc ff ff       	call   801572 <fd_lookup>
  801904:	85 c0                	test   %eax,%eax
  801906:	78 68                	js     801970 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801908:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801912:	8b 00                	mov    (%eax),%eax
  801914:	89 04 24             	mov    %eax,(%esp)
  801917:	e8 ac fc ff ff       	call   8015c8 <dev_lookup>
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 50                	js     801970 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801920:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801923:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801927:	75 23                	jne    80194c <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801929:	a1 08 50 80 00       	mov    0x805008,%eax
  80192e:	8b 40 48             	mov    0x48(%eax),%eax
  801931:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801935:	89 44 24 04          	mov    %eax,0x4(%esp)
  801939:	c7 04 24 20 30 80 00 	movl   $0x803020,(%esp)
  801940:	e8 53 ea ff ff       	call   800398 <cprintf>
		return -E_INVAL;
  801945:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80194a:	eb 24                	jmp    801970 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80194c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194f:	8b 52 0c             	mov    0xc(%edx),%edx
  801952:	85 d2                	test   %edx,%edx
  801954:	74 15                	je     80196b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801956:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801959:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80195d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801960:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801964:	89 04 24             	mov    %eax,(%esp)
  801967:	ff d2                	call   *%edx
  801969:	eb 05                	jmp    801970 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80196b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801970:	83 c4 24             	add    $0x24,%esp
  801973:	5b                   	pop    %ebx
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    

00801976 <seek>:

int
seek(int fdnum, off_t offset)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80197f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	89 04 24             	mov    %eax,(%esp)
  801989:	e8 e4 fb ff ff       	call   801572 <fd_lookup>
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 0e                	js     8019a0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801992:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801995:	8b 55 0c             	mov    0xc(%ebp),%edx
  801998:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80199b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 24             	sub    $0x24,%esp
  8019a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b3:	89 1c 24             	mov    %ebx,(%esp)
  8019b6:	e8 b7 fb ff ff       	call   801572 <fd_lookup>
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 61                	js     801a20 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c9:	8b 00                	mov    (%eax),%eax
  8019cb:	89 04 24             	mov    %eax,(%esp)
  8019ce:	e8 f5 fb ff ff       	call   8015c8 <dev_lookup>
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 49                	js     801a20 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019de:	75 23                	jne    801a03 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019e0:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019e5:	8b 40 48             	mov    0x48(%eax),%eax
  8019e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f0:	c7 04 24 e0 2f 80 00 	movl   $0x802fe0,(%esp)
  8019f7:	e8 9c e9 ff ff       	call   800398 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a01:	eb 1d                	jmp    801a20 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801a03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a06:	8b 52 18             	mov    0x18(%edx),%edx
  801a09:	85 d2                	test   %edx,%edx
  801a0b:	74 0e                	je     801a1b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a10:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a14:	89 04 24             	mov    %eax,(%esp)
  801a17:	ff d2                	call   *%edx
  801a19:	eb 05                	jmp    801a20 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a1b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a20:	83 c4 24             	add    $0x24,%esp
  801a23:	5b                   	pop    %ebx
  801a24:	5d                   	pop    %ebp
  801a25:	c3                   	ret    

00801a26 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 24             	sub    $0x24,%esp
  801a2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a30:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a37:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3a:	89 04 24             	mov    %eax,(%esp)
  801a3d:	e8 30 fb ff ff       	call   801572 <fd_lookup>
  801a42:	85 c0                	test   %eax,%eax
  801a44:	78 52                	js     801a98 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a50:	8b 00                	mov    (%eax),%eax
  801a52:	89 04 24             	mov    %eax,(%esp)
  801a55:	e8 6e fb ff ff       	call   8015c8 <dev_lookup>
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 3a                	js     801a98 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a61:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a65:	74 2c                	je     801a93 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a67:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a6a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a71:	00 00 00 
	stat->st_isdir = 0;
  801a74:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a7b:	00 00 00 
	stat->st_dev = dev;
  801a7e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a8b:	89 14 24             	mov    %edx,(%esp)
  801a8e:	ff 50 14             	call   *0x14(%eax)
  801a91:	eb 05                	jmp    801a98 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a93:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a98:	83 c4 24             	add    $0x24,%esp
  801a9b:	5b                   	pop    %ebx
  801a9c:	5d                   	pop    %ebp
  801a9d:	c3                   	ret    

00801a9e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801aa6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aad:	00 
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	89 04 24             	mov    %eax,(%esp)
  801ab4:	e8 2a 02 00 00       	call   801ce3 <open>
  801ab9:	89 c3                	mov    %eax,%ebx
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 1b                	js     801ada <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac6:	89 1c 24             	mov    %ebx,(%esp)
  801ac9:	e8 58 ff ff ff       	call   801a26 <fstat>
  801ace:	89 c6                	mov    %eax,%esi
	close(fd);
  801ad0:	89 1c 24             	mov    %ebx,(%esp)
  801ad3:	e8 d2 fb ff ff       	call   8016aa <close>
	return r;
  801ad8:	89 f3                	mov    %esi,%ebx
}
  801ada:	89 d8                	mov    %ebx,%eax
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	5b                   	pop    %ebx
  801ae0:	5e                   	pop    %esi
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    
	...

00801ae4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 10             	sub    $0x10,%esp
  801aec:	89 c3                	mov    %eax,%ebx
  801aee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801af0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801af7:	75 11                	jne    801b0a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801af9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b00:	e8 aa f9 ff ff       	call   8014af <ipc_find_env>
  801b05:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b0a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b11:	00 
  801b12:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b19:	00 
  801b1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b1e:	a1 00 50 80 00       	mov    0x805000,%eax
  801b23:	89 04 24             	mov    %eax,(%esp)
  801b26:	e8 01 f9 ff ff       	call   80142c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b32:	00 
  801b33:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3e:	e8 79 f8 ff ff       	call   8013bc <ipc_recv>
}
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    

00801b4a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	8b 40 0c             	mov    0xc(%eax),%eax
  801b56:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5e:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b63:	ba 00 00 00 00       	mov    $0x0,%edx
  801b68:	b8 02 00 00 00       	mov    $0x2,%eax
  801b6d:	e8 72 ff ff ff       	call   801ae4 <fsipc>
}
  801b72:	c9                   	leave  
  801b73:	c3                   	ret    

00801b74 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b80:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b85:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8a:	b8 06 00 00 00       	mov    $0x6,%eax
  801b8f:	e8 50 ff ff ff       	call   801ae4 <fsipc>
}
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 14             	sub    $0x14,%esp
  801b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba6:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bab:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb0:	b8 05 00 00 00       	mov    $0x5,%eax
  801bb5:	e8 2a ff ff ff       	call   801ae4 <fsipc>
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	78 2b                	js     801be9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bbe:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bc5:	00 
  801bc6:	89 1c 24             	mov    %ebx,(%esp)
  801bc9:	e8 75 ed ff ff       	call   800943 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bce:	a1 80 60 80 00       	mov    0x806080,%eax
  801bd3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bd9:	a1 84 60 80 00       	mov    0x806084,%eax
  801bde:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801be4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be9:	83 c4 14             	add    $0x14,%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	83 ec 18             	sub    $0x18,%esp
  801bf5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  801bfb:	8b 52 0c             	mov    0xc(%edx),%edx
  801bfe:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801c04:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801c09:	89 c2                	mov    %eax,%edx
  801c0b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c10:	76 05                	jbe    801c17 <devfile_write+0x28>
  801c12:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801c17:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c22:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801c29:	e8 f8 ee ff ff       	call   800b26 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801c2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c33:	b8 04 00 00 00       	mov    $0x4,%eax
  801c38:	e8 a7 fe ff ff       	call   801ae4 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801c3d:	c9                   	leave  
  801c3e:	c3                   	ret    

00801c3f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 10             	sub    $0x10,%esp
  801c47:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c50:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c55:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c60:	b8 03 00 00 00       	mov    $0x3,%eax
  801c65:	e8 7a fe ff ff       	call   801ae4 <fsipc>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 6a                	js     801cda <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c70:	39 c6                	cmp    %eax,%esi
  801c72:	73 24                	jae    801c98 <devfile_read+0x59>
  801c74:	c7 44 24 0c 54 30 80 	movl   $0x803054,0xc(%esp)
  801c7b:	00 
  801c7c:	c7 44 24 08 5b 30 80 	movl   $0x80305b,0x8(%esp)
  801c83:	00 
  801c84:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c8b:	00 
  801c8c:	c7 04 24 70 30 80 00 	movl   $0x803070,(%esp)
  801c93:	e8 08 e6 ff ff       	call   8002a0 <_panic>
	assert(r <= PGSIZE);
  801c98:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c9d:	7e 24                	jle    801cc3 <devfile_read+0x84>
  801c9f:	c7 44 24 0c 7b 30 80 	movl   $0x80307b,0xc(%esp)
  801ca6:	00 
  801ca7:	c7 44 24 08 5b 30 80 	movl   $0x80305b,0x8(%esp)
  801cae:	00 
  801caf:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801cb6:	00 
  801cb7:	c7 04 24 70 30 80 00 	movl   $0x803070,(%esp)
  801cbe:	e8 dd e5 ff ff       	call   8002a0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc7:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cce:	00 
  801ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd2:	89 04 24             	mov    %eax,(%esp)
  801cd5:	e8 e2 ed ff ff       	call   800abc <memmove>
	return r;
}
  801cda:	89 d8                	mov    %ebx,%eax
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 20             	sub    $0x20,%esp
  801ceb:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cee:	89 34 24             	mov    %esi,(%esp)
  801cf1:	e8 1a ec ff ff       	call   800910 <strlen>
  801cf6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cfb:	7f 60                	jg     801d5d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cfd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d00:	89 04 24             	mov    %eax,(%esp)
  801d03:	e8 17 f8 ff ff       	call   80151f <fd_alloc>
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 54                	js     801d62 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d12:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d19:	e8 25 ec ff ff       	call   800943 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d21:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d29:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2e:	e8 b1 fd ff ff       	call   801ae4 <fsipc>
  801d33:	89 c3                	mov    %eax,%ebx
  801d35:	85 c0                	test   %eax,%eax
  801d37:	79 15                	jns    801d4e <open+0x6b>
		fd_close(fd, 0);
  801d39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d40:	00 
  801d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d44:	89 04 24             	mov    %eax,(%esp)
  801d47:	e8 d6 f8 ff ff       	call   801622 <fd_close>
		return r;
  801d4c:	eb 14                	jmp    801d62 <open+0x7f>
	}

	return fd2num(fd);
  801d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d51:	89 04 24             	mov    %eax,(%esp)
  801d54:	e8 9b f7 ff ff       	call   8014f4 <fd2num>
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	eb 05                	jmp    801d62 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d5d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d62:	89 d8                	mov    %ebx,%eax
  801d64:	83 c4 20             	add    $0x20,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d71:	ba 00 00 00 00       	mov    $0x0,%edx
  801d76:	b8 08 00 00 00       	mov    $0x8,%eax
  801d7b:	e8 64 fd ff ff       	call   801ae4 <fsipc>
}
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    
	...

00801d84 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d8a:	89 c2                	mov    %eax,%edx
  801d8c:	c1 ea 16             	shr    $0x16,%edx
  801d8f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d96:	f6 c2 01             	test   $0x1,%dl
  801d99:	74 1e                	je     801db9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d9b:	c1 e8 0c             	shr    $0xc,%eax
  801d9e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801da5:	a8 01                	test   $0x1,%al
  801da7:	74 17                	je     801dc0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801da9:	c1 e8 0c             	shr    $0xc,%eax
  801dac:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801db3:	ef 
  801db4:	0f b7 c0             	movzwl %ax,%eax
  801db7:	eb 0c                	jmp    801dc5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801db9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbe:	eb 05                	jmp    801dc5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801dc0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    
	...

00801dc8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801dce:	c7 44 24 04 87 30 80 	movl   $0x803087,0x4(%esp)
  801dd5:	00 
  801dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd9:	89 04 24             	mov    %eax,(%esp)
  801ddc:	e8 62 eb ff ff       	call   800943 <strcpy>
	return 0;
}
  801de1:	b8 00 00 00 00       	mov    $0x0,%eax
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	53                   	push   %ebx
  801dec:	83 ec 14             	sub    $0x14,%esp
  801def:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801df2:	89 1c 24             	mov    %ebx,(%esp)
  801df5:	e8 8a ff ff ff       	call   801d84 <pageref>
  801dfa:	83 f8 01             	cmp    $0x1,%eax
  801dfd:	75 0d                	jne    801e0c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801dff:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e02:	89 04 24             	mov    %eax,(%esp)
  801e05:	e8 1f 03 00 00       	call   802129 <nsipc_close>
  801e0a:	eb 05                	jmp    801e11 <devsock_close+0x29>
	else
		return 0;
  801e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e11:	83 c4 14             	add    $0x14,%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5d                   	pop    %ebp
  801e16:	c3                   	ret    

00801e17 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e1d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e24:	00 
  801e25:	8b 45 10             	mov    0x10(%ebp),%eax
  801e28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	8b 40 0c             	mov    0xc(%eax),%eax
  801e39:	89 04 24             	mov    %eax,(%esp)
  801e3c:	e8 e3 03 00 00       	call   802224 <nsipc_send>
}
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    

00801e43 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e49:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e50:	00 
  801e51:	8b 45 10             	mov    0x10(%ebp),%eax
  801e54:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e62:	8b 40 0c             	mov    0xc(%eax),%eax
  801e65:	89 04 24             	mov    %eax,(%esp)
  801e68:	e8 37 03 00 00       	call   8021a4 <nsipc_recv>
}
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
  801e74:	83 ec 20             	sub    $0x20,%esp
  801e77:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 9b f6 ff ff       	call   80151f <fd_alloc>
  801e84:	89 c3                	mov    %eax,%ebx
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 21                	js     801eab <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e8a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e91:	00 
  801e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea0:	e8 90 ee ff ff       	call   800d35 <sys_page_alloc>
  801ea5:	89 c3                	mov    %eax,%ebx
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	79 0a                	jns    801eb5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801eab:	89 34 24             	mov    %esi,(%esp)
  801eae:	e8 76 02 00 00       	call   802129 <nsipc_close>
		return r;
  801eb3:	eb 22                	jmp    801ed7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801eb5:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801eca:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ecd:	89 04 24             	mov    %eax,(%esp)
  801ed0:	e8 1f f6 ff ff       	call   8014f4 <fd2num>
  801ed5:	89 c3                	mov    %eax,%ebx
}
  801ed7:	89 d8                	mov    %ebx,%eax
  801ed9:	83 c4 20             	add    $0x20,%esp
  801edc:	5b                   	pop    %ebx
  801edd:	5e                   	pop    %esi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    

00801ee0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ee6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ee9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eed:	89 04 24             	mov    %eax,(%esp)
  801ef0:	e8 7d f6 ff ff       	call   801572 <fd_lookup>
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	78 17                	js     801f10 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efc:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801f02:	39 10                	cmp    %edx,(%eax)
  801f04:	75 05                	jne    801f0b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f06:	8b 40 0c             	mov    0xc(%eax),%eax
  801f09:	eb 05                	jmp    801f10 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f0b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f18:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1b:	e8 c0 ff ff ff       	call   801ee0 <fd2sockid>
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 1f                	js     801f43 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f24:	8b 55 10             	mov    0x10(%ebp),%edx
  801f27:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f32:	89 04 24             	mov    %eax,(%esp)
  801f35:	e8 38 01 00 00       	call   802072 <nsipc_accept>
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	78 05                	js     801f43 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801f3e:	e8 2c ff ff ff       	call   801e6f <alloc_sockfd>
}
  801f43:	c9                   	leave  
  801f44:	c3                   	ret    

00801f45 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4e:	e8 8d ff ff ff       	call   801ee0 <fd2sockid>
  801f53:	85 c0                	test   %eax,%eax
  801f55:	78 16                	js     801f6d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801f57:	8b 55 10             	mov    0x10(%ebp),%edx
  801f5a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f65:	89 04 24             	mov    %eax,(%esp)
  801f68:	e8 5b 01 00 00       	call   8020c8 <nsipc_bind>
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <shutdown>:

int
shutdown(int s, int how)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f75:	8b 45 08             	mov    0x8(%ebp),%eax
  801f78:	e8 63 ff ff ff       	call   801ee0 <fd2sockid>
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	78 0f                	js     801f90 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f81:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f84:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f88:	89 04 24             	mov    %eax,(%esp)
  801f8b:	e8 77 01 00 00       	call   802107 <nsipc_shutdown>
}
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f98:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9b:	e8 40 ff ff ff       	call   801ee0 <fd2sockid>
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 16                	js     801fba <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801fa4:	8b 55 10             	mov    0x10(%ebp),%edx
  801fa7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fab:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fae:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fb2:	89 04 24             	mov    %eax,(%esp)
  801fb5:	e8 89 01 00 00       	call   802143 <nsipc_connect>
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <listen>:

int
listen(int s, int backlog)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc5:	e8 16 ff ff ff       	call   801ee0 <fd2sockid>
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	78 0f                	js     801fdd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801fce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fd5:	89 04 24             	mov    %eax,(%esp)
  801fd8:	e8 a5 01 00 00       	call   802182 <nsipc_listen>
}
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fe5:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff6:	89 04 24             	mov    %eax,(%esp)
  801ff9:	e8 99 02 00 00       	call   802297 <nsipc_socket>
  801ffe:	85 c0                	test   %eax,%eax
  802000:	78 05                	js     802007 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802002:	e8 68 fe ff ff       	call   801e6f <alloc_sockfd>
}
  802007:	c9                   	leave  
  802008:	c3                   	ret    
  802009:	00 00                	add    %al,(%eax)
	...

0080200c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	53                   	push   %ebx
  802010:	83 ec 14             	sub    $0x14,%esp
  802013:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802015:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80201c:	75 11                	jne    80202f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80201e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802025:	e8 85 f4 ff ff       	call   8014af <ipc_find_env>
  80202a:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80202f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802036:	00 
  802037:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  80203e:	00 
  80203f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802043:	a1 04 50 80 00       	mov    0x805004,%eax
  802048:	89 04 24             	mov    %eax,(%esp)
  80204b:	e8 dc f3 ff ff       	call   80142c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802050:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802057:	00 
  802058:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80205f:	00 
  802060:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802067:	e8 50 f3 ff ff       	call   8013bc <ipc_recv>
}
  80206c:	83 c4 14             	add    $0x14,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    

00802072 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	56                   	push   %esi
  802076:	53                   	push   %ebx
  802077:	83 ec 10             	sub    $0x10,%esp
  80207a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80207d:	8b 45 08             	mov    0x8(%ebp),%eax
  802080:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802085:	8b 06                	mov    (%esi),%eax
  802087:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80208c:	b8 01 00 00 00       	mov    $0x1,%eax
  802091:	e8 76 ff ff ff       	call   80200c <nsipc>
  802096:	89 c3                	mov    %eax,%ebx
  802098:	85 c0                	test   %eax,%eax
  80209a:	78 23                	js     8020bf <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80209c:	a1 10 70 80 00       	mov    0x807010,%eax
  8020a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020a5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8020ac:	00 
  8020ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b0:	89 04 24             	mov    %eax,(%esp)
  8020b3:	e8 04 ea ff ff       	call   800abc <memmove>
		*addrlen = ret->ret_addrlen;
  8020b8:	a1 10 70 80 00       	mov    0x807010,%eax
  8020bd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8020bf:	89 d8                	mov    %ebx,%eax
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    

008020c8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	53                   	push   %ebx
  8020cc:	83 ec 14             	sub    $0x14,%esp
  8020cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8020d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8020da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e5:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020ec:	e8 cb e9 ff ff       	call   800abc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8020f1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8020f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8020fc:	e8 0b ff ff ff       	call   80200c <nsipc>
}
  802101:	83 c4 14             	add    $0x14,%esp
  802104:	5b                   	pop    %ebx
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    

00802107 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802107:	55                   	push   %ebp
  802108:	89 e5                	mov    %esp,%ebp
  80210a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80210d:	8b 45 08             	mov    0x8(%ebp),%eax
  802110:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802115:	8b 45 0c             	mov    0xc(%ebp),%eax
  802118:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80211d:	b8 03 00 00 00       	mov    $0x3,%eax
  802122:	e8 e5 fe ff ff       	call   80200c <nsipc>
}
  802127:	c9                   	leave  
  802128:	c3                   	ret    

00802129 <nsipc_close>:

int
nsipc_close(int s)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80212f:	8b 45 08             	mov    0x8(%ebp),%eax
  802132:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802137:	b8 04 00 00 00       	mov    $0x4,%eax
  80213c:	e8 cb fe ff ff       	call   80200c <nsipc>
}
  802141:	c9                   	leave  
  802142:	c3                   	ret    

00802143 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	53                   	push   %ebx
  802147:	83 ec 14             	sub    $0x14,%esp
  80214a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80214d:	8b 45 08             	mov    0x8(%ebp),%eax
  802150:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802155:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802159:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802160:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802167:	e8 50 e9 ff ff       	call   800abc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80216c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802172:	b8 05 00 00 00       	mov    $0x5,%eax
  802177:	e8 90 fe ff ff       	call   80200c <nsipc>
}
  80217c:	83 c4 14             	add    $0x14,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802188:	8b 45 08             	mov    0x8(%ebp),%eax
  80218b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802190:	8b 45 0c             	mov    0xc(%ebp),%eax
  802193:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802198:	b8 06 00 00 00       	mov    $0x6,%eax
  80219d:	e8 6a fe ff ff       	call   80200c <nsipc>
}
  8021a2:	c9                   	leave  
  8021a3:	c3                   	ret    

008021a4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	56                   	push   %esi
  8021a8:	53                   	push   %ebx
  8021a9:	83 ec 10             	sub    $0x10,%esp
  8021ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021af:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8021b7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8021bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8021c0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021c5:	b8 07 00 00 00       	mov    $0x7,%eax
  8021ca:	e8 3d fe ff ff       	call   80200c <nsipc>
  8021cf:	89 c3                	mov    %eax,%ebx
  8021d1:	85 c0                	test   %eax,%eax
  8021d3:	78 46                	js     80221b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8021d5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8021da:	7f 04                	jg     8021e0 <nsipc_recv+0x3c>
  8021dc:	39 c6                	cmp    %eax,%esi
  8021de:	7d 24                	jge    802204 <nsipc_recv+0x60>
  8021e0:	c7 44 24 0c 93 30 80 	movl   $0x803093,0xc(%esp)
  8021e7:	00 
  8021e8:	c7 44 24 08 5b 30 80 	movl   $0x80305b,0x8(%esp)
  8021ef:	00 
  8021f0:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8021f7:	00 
  8021f8:	c7 04 24 a8 30 80 00 	movl   $0x8030a8,(%esp)
  8021ff:	e8 9c e0 ff ff       	call   8002a0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802204:	89 44 24 08          	mov    %eax,0x8(%esp)
  802208:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80220f:	00 
  802210:	8b 45 0c             	mov    0xc(%ebp),%eax
  802213:	89 04 24             	mov    %eax,(%esp)
  802216:	e8 a1 e8 ff ff       	call   800abc <memmove>
	}

	return r;
}
  80221b:	89 d8                	mov    %ebx,%eax
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    

00802224 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	53                   	push   %ebx
  802228:	83 ec 14             	sub    $0x14,%esp
  80222b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80222e:	8b 45 08             	mov    0x8(%ebp),%eax
  802231:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802236:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80223c:	7e 24                	jle    802262 <nsipc_send+0x3e>
  80223e:	c7 44 24 0c b4 30 80 	movl   $0x8030b4,0xc(%esp)
  802245:	00 
  802246:	c7 44 24 08 5b 30 80 	movl   $0x80305b,0x8(%esp)
  80224d:	00 
  80224e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802255:	00 
  802256:	c7 04 24 a8 30 80 00 	movl   $0x8030a8,(%esp)
  80225d:	e8 3e e0 ff ff       	call   8002a0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802262:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802266:	8b 45 0c             	mov    0xc(%ebp),%eax
  802269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80226d:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802274:	e8 43 e8 ff ff       	call   800abc <memmove>
	nsipcbuf.send.req_size = size;
  802279:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80227f:	8b 45 14             	mov    0x14(%ebp),%eax
  802282:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802287:	b8 08 00 00 00       	mov    $0x8,%eax
  80228c:	e8 7b fd ff ff       	call   80200c <nsipc>
}
  802291:	83 c4 14             	add    $0x14,%esp
  802294:	5b                   	pop    %ebx
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    

00802297 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80229d:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8022a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8022ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8022b5:	b8 09 00 00 00       	mov    $0x9,%eax
  8022ba:	e8 4d fd ff ff       	call   80200c <nsipc>
}
  8022bf:	c9                   	leave  
  8022c0:	c3                   	ret    
  8022c1:	00 00                	add    %al,(%eax)
	...

008022c4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	56                   	push   %esi
  8022c8:	53                   	push   %ebx
  8022c9:	83 ec 10             	sub    $0x10,%esp
  8022cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d2:	89 04 24             	mov    %eax,(%esp)
  8022d5:	e8 2a f2 ff ff       	call   801504 <fd2data>
  8022da:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8022dc:	c7 44 24 04 c0 30 80 	movl   $0x8030c0,0x4(%esp)
  8022e3:	00 
  8022e4:	89 34 24             	mov    %esi,(%esp)
  8022e7:	e8 57 e6 ff ff       	call   800943 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022ec:	8b 43 04             	mov    0x4(%ebx),%eax
  8022ef:	2b 03                	sub    (%ebx),%eax
  8022f1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8022f7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8022fe:	00 00 00 
	stat->st_dev = &devpipe;
  802301:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802308:	40 80 00 
	return 0;
}
  80230b:	b8 00 00 00 00       	mov    $0x0,%eax
  802310:	83 c4 10             	add    $0x10,%esp
  802313:	5b                   	pop    %ebx
  802314:	5e                   	pop    %esi
  802315:	5d                   	pop    %ebp
  802316:	c3                   	ret    

00802317 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802317:	55                   	push   %ebp
  802318:	89 e5                	mov    %esp,%ebp
  80231a:	53                   	push   %ebx
  80231b:	83 ec 14             	sub    $0x14,%esp
  80231e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802321:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802325:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80232c:	e8 ab ea ff ff       	call   800ddc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802331:	89 1c 24             	mov    %ebx,(%esp)
  802334:	e8 cb f1 ff ff       	call   801504 <fd2data>
  802339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802344:	e8 93 ea ff ff       	call   800ddc <sys_page_unmap>
}
  802349:	83 c4 14             	add    $0x14,%esp
  80234c:	5b                   	pop    %ebx
  80234d:	5d                   	pop    %ebp
  80234e:	c3                   	ret    

0080234f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	57                   	push   %edi
  802353:	56                   	push   %esi
  802354:	53                   	push   %ebx
  802355:	83 ec 2c             	sub    $0x2c,%esp
  802358:	89 c7                	mov    %eax,%edi
  80235a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80235d:	a1 08 50 80 00       	mov    0x805008,%eax
  802362:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802365:	89 3c 24             	mov    %edi,(%esp)
  802368:	e8 17 fa ff ff       	call   801d84 <pageref>
  80236d:	89 c6                	mov    %eax,%esi
  80236f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802372:	89 04 24             	mov    %eax,(%esp)
  802375:	e8 0a fa ff ff       	call   801d84 <pageref>
  80237a:	39 c6                	cmp    %eax,%esi
  80237c:	0f 94 c0             	sete   %al
  80237f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802382:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802388:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80238b:	39 cb                	cmp    %ecx,%ebx
  80238d:	75 08                	jne    802397 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80238f:	83 c4 2c             	add    $0x2c,%esp
  802392:	5b                   	pop    %ebx
  802393:	5e                   	pop    %esi
  802394:	5f                   	pop    %edi
  802395:	5d                   	pop    %ebp
  802396:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802397:	83 f8 01             	cmp    $0x1,%eax
  80239a:	75 c1                	jne    80235d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80239c:	8b 42 58             	mov    0x58(%edx),%eax
  80239f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8023a6:	00 
  8023a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023af:	c7 04 24 c7 30 80 00 	movl   $0x8030c7,(%esp)
  8023b6:	e8 dd df ff ff       	call   800398 <cprintf>
  8023bb:	eb a0                	jmp    80235d <_pipeisclosed+0xe>

008023bd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023bd:	55                   	push   %ebp
  8023be:	89 e5                	mov    %esp,%ebp
  8023c0:	57                   	push   %edi
  8023c1:	56                   	push   %esi
  8023c2:	53                   	push   %ebx
  8023c3:	83 ec 1c             	sub    $0x1c,%esp
  8023c6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8023c9:	89 34 24             	mov    %esi,(%esp)
  8023cc:	e8 33 f1 ff ff       	call   801504 <fd2data>
  8023d1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8023d8:	eb 3c                	jmp    802416 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8023da:	89 da                	mov    %ebx,%edx
  8023dc:	89 f0                	mov    %esi,%eax
  8023de:	e8 6c ff ff ff       	call   80234f <_pipeisclosed>
  8023e3:	85 c0                	test   %eax,%eax
  8023e5:	75 38                	jne    80241f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8023e7:	e8 2a e9 ff ff       	call   800d16 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8023ec:	8b 43 04             	mov    0x4(%ebx),%eax
  8023ef:	8b 13                	mov    (%ebx),%edx
  8023f1:	83 c2 20             	add    $0x20,%edx
  8023f4:	39 d0                	cmp    %edx,%eax
  8023f6:	73 e2                	jae    8023da <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023fb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8023fe:	89 c2                	mov    %eax,%edx
  802400:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802406:	79 05                	jns    80240d <devpipe_write+0x50>
  802408:	4a                   	dec    %edx
  802409:	83 ca e0             	or     $0xffffffe0,%edx
  80240c:	42                   	inc    %edx
  80240d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802411:	40                   	inc    %eax
  802412:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802415:	47                   	inc    %edi
  802416:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802419:	75 d1                	jne    8023ec <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80241b:	89 f8                	mov    %edi,%eax
  80241d:	eb 05                	jmp    802424 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80241f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802424:	83 c4 1c             	add    $0x1c,%esp
  802427:	5b                   	pop    %ebx
  802428:	5e                   	pop    %esi
  802429:	5f                   	pop    %edi
  80242a:	5d                   	pop    %ebp
  80242b:	c3                   	ret    

0080242c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80242c:	55                   	push   %ebp
  80242d:	89 e5                	mov    %esp,%ebp
  80242f:	57                   	push   %edi
  802430:	56                   	push   %esi
  802431:	53                   	push   %ebx
  802432:	83 ec 1c             	sub    $0x1c,%esp
  802435:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802438:	89 3c 24             	mov    %edi,(%esp)
  80243b:	e8 c4 f0 ff ff       	call   801504 <fd2data>
  802440:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802442:	be 00 00 00 00       	mov    $0x0,%esi
  802447:	eb 3a                	jmp    802483 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802449:	85 f6                	test   %esi,%esi
  80244b:	74 04                	je     802451 <devpipe_read+0x25>
				return i;
  80244d:	89 f0                	mov    %esi,%eax
  80244f:	eb 40                	jmp    802491 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802451:	89 da                	mov    %ebx,%edx
  802453:	89 f8                	mov    %edi,%eax
  802455:	e8 f5 fe ff ff       	call   80234f <_pipeisclosed>
  80245a:	85 c0                	test   %eax,%eax
  80245c:	75 2e                	jne    80248c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80245e:	e8 b3 e8 ff ff       	call   800d16 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802463:	8b 03                	mov    (%ebx),%eax
  802465:	3b 43 04             	cmp    0x4(%ebx),%eax
  802468:	74 df                	je     802449 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80246a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80246f:	79 05                	jns    802476 <devpipe_read+0x4a>
  802471:	48                   	dec    %eax
  802472:	83 c8 e0             	or     $0xffffffe0,%eax
  802475:	40                   	inc    %eax
  802476:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80247a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80247d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802480:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802482:	46                   	inc    %esi
  802483:	3b 75 10             	cmp    0x10(%ebp),%esi
  802486:	75 db                	jne    802463 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802488:	89 f0                	mov    %esi,%eax
  80248a:	eb 05                	jmp    802491 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80248c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802491:	83 c4 1c             	add    $0x1c,%esp
  802494:	5b                   	pop    %ebx
  802495:	5e                   	pop    %esi
  802496:	5f                   	pop    %edi
  802497:	5d                   	pop    %ebp
  802498:	c3                   	ret    

00802499 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802499:	55                   	push   %ebp
  80249a:	89 e5                	mov    %esp,%ebp
  80249c:	57                   	push   %edi
  80249d:	56                   	push   %esi
  80249e:	53                   	push   %ebx
  80249f:	83 ec 3c             	sub    $0x3c,%esp
  8024a2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8024a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8024a8:	89 04 24             	mov    %eax,(%esp)
  8024ab:	e8 6f f0 ff ff       	call   80151f <fd_alloc>
  8024b0:	89 c3                	mov    %eax,%ebx
  8024b2:	85 c0                	test   %eax,%eax
  8024b4:	0f 88 45 01 00 00    	js     8025ff <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024ba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024c1:	00 
  8024c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024d0:	e8 60 e8 ff ff       	call   800d35 <sys_page_alloc>
  8024d5:	89 c3                	mov    %eax,%ebx
  8024d7:	85 c0                	test   %eax,%eax
  8024d9:	0f 88 20 01 00 00    	js     8025ff <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8024df:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8024e2:	89 04 24             	mov    %eax,(%esp)
  8024e5:	e8 35 f0 ff ff       	call   80151f <fd_alloc>
  8024ea:	89 c3                	mov    %eax,%ebx
  8024ec:	85 c0                	test   %eax,%eax
  8024ee:	0f 88 f8 00 00 00    	js     8025ec <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024f4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024fb:	00 
  8024fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802503:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80250a:	e8 26 e8 ff ff       	call   800d35 <sys_page_alloc>
  80250f:	89 c3                	mov    %eax,%ebx
  802511:	85 c0                	test   %eax,%eax
  802513:	0f 88 d3 00 00 00    	js     8025ec <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802519:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80251c:	89 04 24             	mov    %eax,(%esp)
  80251f:	e8 e0 ef ff ff       	call   801504 <fd2data>
  802524:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802526:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80252d:	00 
  80252e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802532:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802539:	e8 f7 e7 ff ff       	call   800d35 <sys_page_alloc>
  80253e:	89 c3                	mov    %eax,%ebx
  802540:	85 c0                	test   %eax,%eax
  802542:	0f 88 91 00 00 00    	js     8025d9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802548:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80254b:	89 04 24             	mov    %eax,(%esp)
  80254e:	e8 b1 ef ff ff       	call   801504 <fd2data>
  802553:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80255a:	00 
  80255b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80255f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802566:	00 
  802567:	89 74 24 04          	mov    %esi,0x4(%esp)
  80256b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802572:	e8 12 e8 ff ff       	call   800d89 <sys_page_map>
  802577:	89 c3                	mov    %eax,%ebx
  802579:	85 c0                	test   %eax,%eax
  80257b:	78 4c                	js     8025c9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80257d:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802586:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80258b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802592:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802598:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80259b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80259d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025a0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8025a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025aa:	89 04 24             	mov    %eax,(%esp)
  8025ad:	e8 42 ef ff ff       	call   8014f4 <fd2num>
  8025b2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8025b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025b7:	89 04 24             	mov    %eax,(%esp)
  8025ba:	e8 35 ef ff ff       	call   8014f4 <fd2num>
  8025bf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8025c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025c7:	eb 36                	jmp    8025ff <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8025c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025d4:	e8 03 e8 ff ff       	call   800ddc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8025d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025e7:	e8 f0 e7 ff ff       	call   800ddc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8025ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025fa:	e8 dd e7 ff ff       	call   800ddc <sys_page_unmap>
    err:
	return r;
}
  8025ff:	89 d8                	mov    %ebx,%eax
  802601:	83 c4 3c             	add    $0x3c,%esp
  802604:	5b                   	pop    %ebx
  802605:	5e                   	pop    %esi
  802606:	5f                   	pop    %edi
  802607:	5d                   	pop    %ebp
  802608:	c3                   	ret    

00802609 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802609:	55                   	push   %ebp
  80260a:	89 e5                	mov    %esp,%ebp
  80260c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80260f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802612:	89 44 24 04          	mov    %eax,0x4(%esp)
  802616:	8b 45 08             	mov    0x8(%ebp),%eax
  802619:	89 04 24             	mov    %eax,(%esp)
  80261c:	e8 51 ef ff ff       	call   801572 <fd_lookup>
  802621:	85 c0                	test   %eax,%eax
  802623:	78 15                	js     80263a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802628:	89 04 24             	mov    %eax,(%esp)
  80262b:	e8 d4 ee ff ff       	call   801504 <fd2data>
	return _pipeisclosed(fd, p);
  802630:	89 c2                	mov    %eax,%edx
  802632:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802635:	e8 15 fd ff ff       	call   80234f <_pipeisclosed>
}
  80263a:	c9                   	leave  
  80263b:	c3                   	ret    

0080263c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80263c:	55                   	push   %ebp
  80263d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80263f:	b8 00 00 00 00       	mov    $0x0,%eax
  802644:	5d                   	pop    %ebp
  802645:	c3                   	ret    

00802646 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802646:	55                   	push   %ebp
  802647:	89 e5                	mov    %esp,%ebp
  802649:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80264c:	c7 44 24 04 df 30 80 	movl   $0x8030df,0x4(%esp)
  802653:	00 
  802654:	8b 45 0c             	mov    0xc(%ebp),%eax
  802657:	89 04 24             	mov    %eax,(%esp)
  80265a:	e8 e4 e2 ff ff       	call   800943 <strcpy>
	return 0;
}
  80265f:	b8 00 00 00 00       	mov    $0x0,%eax
  802664:	c9                   	leave  
  802665:	c3                   	ret    

00802666 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802666:	55                   	push   %ebp
  802667:	89 e5                	mov    %esp,%ebp
  802669:	57                   	push   %edi
  80266a:	56                   	push   %esi
  80266b:	53                   	push   %ebx
  80266c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802672:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802677:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80267d:	eb 30                	jmp    8026af <devcons_write+0x49>
		m = n - tot;
  80267f:	8b 75 10             	mov    0x10(%ebp),%esi
  802682:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802684:	83 fe 7f             	cmp    $0x7f,%esi
  802687:	76 05                	jbe    80268e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802689:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80268e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802692:	03 45 0c             	add    0xc(%ebp),%eax
  802695:	89 44 24 04          	mov    %eax,0x4(%esp)
  802699:	89 3c 24             	mov    %edi,(%esp)
  80269c:	e8 1b e4 ff ff       	call   800abc <memmove>
		sys_cputs(buf, m);
  8026a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a5:	89 3c 24             	mov    %edi,(%esp)
  8026a8:	e8 bb e5 ff ff       	call   800c68 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026ad:	01 f3                	add    %esi,%ebx
  8026af:	89 d8                	mov    %ebx,%eax
  8026b1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8026b4:	72 c9                	jb     80267f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8026b6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8026bc:	5b                   	pop    %ebx
  8026bd:	5e                   	pop    %esi
  8026be:	5f                   	pop    %edi
  8026bf:	5d                   	pop    %ebp
  8026c0:	c3                   	ret    

008026c1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8026c1:	55                   	push   %ebp
  8026c2:	89 e5                	mov    %esp,%ebp
  8026c4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8026c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8026cb:	75 07                	jne    8026d4 <devcons_read+0x13>
  8026cd:	eb 25                	jmp    8026f4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8026cf:	e8 42 e6 ff ff       	call   800d16 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8026d4:	e8 ad e5 ff ff       	call   800c86 <sys_cgetc>
  8026d9:	85 c0                	test   %eax,%eax
  8026db:	74 f2                	je     8026cf <devcons_read+0xe>
  8026dd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8026df:	85 c0                	test   %eax,%eax
  8026e1:	78 1d                	js     802700 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8026e3:	83 f8 04             	cmp    $0x4,%eax
  8026e6:	74 13                	je     8026fb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8026e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026eb:	88 10                	mov    %dl,(%eax)
	return 1;
  8026ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8026f2:	eb 0c                	jmp    802700 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8026f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8026f9:	eb 05                	jmp    802700 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8026fb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802700:	c9                   	leave  
  802701:	c3                   	ret    

00802702 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802702:	55                   	push   %ebp
  802703:	89 e5                	mov    %esp,%ebp
  802705:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802708:	8b 45 08             	mov    0x8(%ebp),%eax
  80270b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80270e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802715:	00 
  802716:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802719:	89 04 24             	mov    %eax,(%esp)
  80271c:	e8 47 e5 ff ff       	call   800c68 <sys_cputs>
}
  802721:	c9                   	leave  
  802722:	c3                   	ret    

00802723 <getchar>:

int
getchar(void)
{
  802723:	55                   	push   %ebp
  802724:	89 e5                	mov    %esp,%ebp
  802726:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802729:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802730:	00 
  802731:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802734:	89 44 24 04          	mov    %eax,0x4(%esp)
  802738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80273f:	e8 cc f0 ff ff       	call   801810 <read>
	if (r < 0)
  802744:	85 c0                	test   %eax,%eax
  802746:	78 0f                	js     802757 <getchar+0x34>
		return r;
	if (r < 1)
  802748:	85 c0                	test   %eax,%eax
  80274a:	7e 06                	jle    802752 <getchar+0x2f>
		return -E_EOF;
	return c;
  80274c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802750:	eb 05                	jmp    802757 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802752:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802757:	c9                   	leave  
  802758:	c3                   	ret    

00802759 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802759:	55                   	push   %ebp
  80275a:	89 e5                	mov    %esp,%ebp
  80275c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80275f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802762:	89 44 24 04          	mov    %eax,0x4(%esp)
  802766:	8b 45 08             	mov    0x8(%ebp),%eax
  802769:	89 04 24             	mov    %eax,(%esp)
  80276c:	e8 01 ee ff ff       	call   801572 <fd_lookup>
  802771:	85 c0                	test   %eax,%eax
  802773:	78 11                	js     802786 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802778:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80277e:	39 10                	cmp    %edx,(%eax)
  802780:	0f 94 c0             	sete   %al
  802783:	0f b6 c0             	movzbl %al,%eax
}
  802786:	c9                   	leave  
  802787:	c3                   	ret    

00802788 <opencons>:

int
opencons(void)
{
  802788:	55                   	push   %ebp
  802789:	89 e5                	mov    %esp,%ebp
  80278b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80278e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802791:	89 04 24             	mov    %eax,(%esp)
  802794:	e8 86 ed ff ff       	call   80151f <fd_alloc>
  802799:	85 c0                	test   %eax,%eax
  80279b:	78 3c                	js     8027d9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80279d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027a4:	00 
  8027a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027b3:	e8 7d e5 ff ff       	call   800d35 <sys_page_alloc>
  8027b8:	85 c0                	test   %eax,%eax
  8027ba:	78 1d                	js     8027d9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8027bc:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8027c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027c5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8027c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8027d1:	89 04 24             	mov    %eax,(%esp)
  8027d4:	e8 1b ed ff ff       	call   8014f4 <fd2num>
}
  8027d9:	c9                   	leave  
  8027da:	c3                   	ret    
	...

008027dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027dc:	55                   	push   %ebp
  8027dd:	89 e5                	mov    %esp,%ebp
  8027df:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8027e2:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8027e9:	75 30                	jne    80281b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8027eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8027f2:	00 
  8027f3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8027fa:	ee 
  8027fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802802:	e8 2e e5 ff ff       	call   800d35 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802807:	c7 44 24 04 28 28 80 	movl   $0x802828,0x4(%esp)
  80280e:	00 
  80280f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802816:	e8 ba e6 ff ff       	call   800ed5 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80281b:	8b 45 08             	mov    0x8(%ebp),%eax
  80281e:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802823:	c9                   	leave  
  802824:	c3                   	ret    
  802825:	00 00                	add    %al,(%eax)
	...

00802828 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802828:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802829:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80282e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802830:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  802833:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802837:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  80283b:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  80283e:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802840:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802844:	83 c4 08             	add    $0x8,%esp
	popal
  802847:	61                   	popa   

	addl $4,%esp 
  802848:	83 c4 04             	add    $0x4,%esp
	popfl
  80284b:	9d                   	popf   

	popl %esp
  80284c:	5c                   	pop    %esp

	ret
  80284d:	c3                   	ret    
	...

00802850 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802850:	55                   	push   %ebp
  802851:	57                   	push   %edi
  802852:	56                   	push   %esi
  802853:	83 ec 10             	sub    $0x10,%esp
  802856:	8b 74 24 20          	mov    0x20(%esp),%esi
  80285a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80285e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802862:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802866:	89 cd                	mov    %ecx,%ebp
  802868:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80286c:	85 c0                	test   %eax,%eax
  80286e:	75 2c                	jne    80289c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802870:	39 f9                	cmp    %edi,%ecx
  802872:	77 68                	ja     8028dc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802874:	85 c9                	test   %ecx,%ecx
  802876:	75 0b                	jne    802883 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802878:	b8 01 00 00 00       	mov    $0x1,%eax
  80287d:	31 d2                	xor    %edx,%edx
  80287f:	f7 f1                	div    %ecx
  802881:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802883:	31 d2                	xor    %edx,%edx
  802885:	89 f8                	mov    %edi,%eax
  802887:	f7 f1                	div    %ecx
  802889:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80288b:	89 f0                	mov    %esi,%eax
  80288d:	f7 f1                	div    %ecx
  80288f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802891:	89 f0                	mov    %esi,%eax
  802893:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802895:	83 c4 10             	add    $0x10,%esp
  802898:	5e                   	pop    %esi
  802899:	5f                   	pop    %edi
  80289a:	5d                   	pop    %ebp
  80289b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80289c:	39 f8                	cmp    %edi,%eax
  80289e:	77 2c                	ja     8028cc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8028a0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8028a3:	83 f6 1f             	xor    $0x1f,%esi
  8028a6:	75 4c                	jne    8028f4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028a8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028aa:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028af:	72 0a                	jb     8028bb <__udivdi3+0x6b>
  8028b1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8028b5:	0f 87 ad 00 00 00    	ja     802968 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028bb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028c0:	89 f0                	mov    %esi,%eax
  8028c2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028c4:	83 c4 10             	add    $0x10,%esp
  8028c7:	5e                   	pop    %esi
  8028c8:	5f                   	pop    %edi
  8028c9:	5d                   	pop    %ebp
  8028ca:	c3                   	ret    
  8028cb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8028cc:	31 ff                	xor    %edi,%edi
  8028ce:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028d0:	89 f0                	mov    %esi,%eax
  8028d2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028d4:	83 c4 10             	add    $0x10,%esp
  8028d7:	5e                   	pop    %esi
  8028d8:	5f                   	pop    %edi
  8028d9:	5d                   	pop    %ebp
  8028da:	c3                   	ret    
  8028db:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028dc:	89 fa                	mov    %edi,%edx
  8028de:	89 f0                	mov    %esi,%eax
  8028e0:	f7 f1                	div    %ecx
  8028e2:	89 c6                	mov    %eax,%esi
  8028e4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028e6:	89 f0                	mov    %esi,%eax
  8028e8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028ea:	83 c4 10             	add    $0x10,%esp
  8028ed:	5e                   	pop    %esi
  8028ee:	5f                   	pop    %edi
  8028ef:	5d                   	pop    %ebp
  8028f0:	c3                   	ret    
  8028f1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8028f4:	89 f1                	mov    %esi,%ecx
  8028f6:	d3 e0                	shl    %cl,%eax
  8028f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8028fc:	b8 20 00 00 00       	mov    $0x20,%eax
  802901:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802903:	89 ea                	mov    %ebp,%edx
  802905:	88 c1                	mov    %al,%cl
  802907:	d3 ea                	shr    %cl,%edx
  802909:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80290d:	09 ca                	or     %ecx,%edx
  80290f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802913:	89 f1                	mov    %esi,%ecx
  802915:	d3 e5                	shl    %cl,%ebp
  802917:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80291b:	89 fd                	mov    %edi,%ebp
  80291d:	88 c1                	mov    %al,%cl
  80291f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802921:	89 fa                	mov    %edi,%edx
  802923:	89 f1                	mov    %esi,%ecx
  802925:	d3 e2                	shl    %cl,%edx
  802927:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80292b:	88 c1                	mov    %al,%cl
  80292d:	d3 ef                	shr    %cl,%edi
  80292f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802931:	89 f8                	mov    %edi,%eax
  802933:	89 ea                	mov    %ebp,%edx
  802935:	f7 74 24 08          	divl   0x8(%esp)
  802939:	89 d1                	mov    %edx,%ecx
  80293b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80293d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802941:	39 d1                	cmp    %edx,%ecx
  802943:	72 17                	jb     80295c <__udivdi3+0x10c>
  802945:	74 09                	je     802950 <__udivdi3+0x100>
  802947:	89 fe                	mov    %edi,%esi
  802949:	31 ff                	xor    %edi,%edi
  80294b:	e9 41 ff ff ff       	jmp    802891 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802950:	8b 54 24 04          	mov    0x4(%esp),%edx
  802954:	89 f1                	mov    %esi,%ecx
  802956:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802958:	39 c2                	cmp    %eax,%edx
  80295a:	73 eb                	jae    802947 <__udivdi3+0xf7>
		{
		  q0--;
  80295c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80295f:	31 ff                	xor    %edi,%edi
  802961:	e9 2b ff ff ff       	jmp    802891 <__udivdi3+0x41>
  802966:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802968:	31 f6                	xor    %esi,%esi
  80296a:	e9 22 ff ff ff       	jmp    802891 <__udivdi3+0x41>
	...

00802970 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802970:	55                   	push   %ebp
  802971:	57                   	push   %edi
  802972:	56                   	push   %esi
  802973:	83 ec 20             	sub    $0x20,%esp
  802976:	8b 44 24 30          	mov    0x30(%esp),%eax
  80297a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80297e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802982:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802986:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80298a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80298e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802990:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802992:	85 ed                	test   %ebp,%ebp
  802994:	75 16                	jne    8029ac <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802996:	39 f1                	cmp    %esi,%ecx
  802998:	0f 86 a6 00 00 00    	jbe    802a44 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80299e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8029a0:	89 d0                	mov    %edx,%eax
  8029a2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029a4:	83 c4 20             	add    $0x20,%esp
  8029a7:	5e                   	pop    %esi
  8029a8:	5f                   	pop    %edi
  8029a9:	5d                   	pop    %ebp
  8029aa:	c3                   	ret    
  8029ab:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029ac:	39 f5                	cmp    %esi,%ebp
  8029ae:	0f 87 ac 00 00 00    	ja     802a60 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8029b4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8029b7:	83 f0 1f             	xor    $0x1f,%eax
  8029ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029be:	0f 84 a8 00 00 00    	je     802a6c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8029c4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029c8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8029ca:	bf 20 00 00 00       	mov    $0x20,%edi
  8029cf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8029d3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029d7:	89 f9                	mov    %edi,%ecx
  8029d9:	d3 e8                	shr    %cl,%eax
  8029db:	09 e8                	or     %ebp,%eax
  8029dd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8029e1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029e5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029e9:	d3 e0                	shl    %cl,%eax
  8029eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8029ef:	89 f2                	mov    %esi,%edx
  8029f1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8029f3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8029f7:	d3 e0                	shl    %cl,%eax
  8029f9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8029fd:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a01:	89 f9                	mov    %edi,%ecx
  802a03:	d3 e8                	shr    %cl,%eax
  802a05:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802a07:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a09:	89 f2                	mov    %esi,%edx
  802a0b:	f7 74 24 18          	divl   0x18(%esp)
  802a0f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802a11:	f7 64 24 0c          	mull   0xc(%esp)
  802a15:	89 c5                	mov    %eax,%ebp
  802a17:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a19:	39 d6                	cmp    %edx,%esi
  802a1b:	72 67                	jb     802a84 <__umoddi3+0x114>
  802a1d:	74 75                	je     802a94 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802a1f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802a23:	29 e8                	sub    %ebp,%eax
  802a25:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802a27:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a2b:	d3 e8                	shr    %cl,%eax
  802a2d:	89 f2                	mov    %esi,%edx
  802a2f:	89 f9                	mov    %edi,%ecx
  802a31:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802a33:	09 d0                	or     %edx,%eax
  802a35:	89 f2                	mov    %esi,%edx
  802a37:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a3b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a3d:	83 c4 20             	add    $0x20,%esp
  802a40:	5e                   	pop    %esi
  802a41:	5f                   	pop    %edi
  802a42:	5d                   	pop    %ebp
  802a43:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802a44:	85 c9                	test   %ecx,%ecx
  802a46:	75 0b                	jne    802a53 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802a48:	b8 01 00 00 00       	mov    $0x1,%eax
  802a4d:	31 d2                	xor    %edx,%edx
  802a4f:	f7 f1                	div    %ecx
  802a51:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802a53:	89 f0                	mov    %esi,%eax
  802a55:	31 d2                	xor    %edx,%edx
  802a57:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a59:	89 f8                	mov    %edi,%eax
  802a5b:	e9 3e ff ff ff       	jmp    80299e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802a60:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a62:	83 c4 20             	add    $0x20,%esp
  802a65:	5e                   	pop    %esi
  802a66:	5f                   	pop    %edi
  802a67:	5d                   	pop    %ebp
  802a68:	c3                   	ret    
  802a69:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a6c:	39 f5                	cmp    %esi,%ebp
  802a6e:	72 04                	jb     802a74 <__umoddi3+0x104>
  802a70:	39 f9                	cmp    %edi,%ecx
  802a72:	77 06                	ja     802a7a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a74:	89 f2                	mov    %esi,%edx
  802a76:	29 cf                	sub    %ecx,%edi
  802a78:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802a7a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a7c:	83 c4 20             	add    $0x20,%esp
  802a7f:	5e                   	pop    %esi
  802a80:	5f                   	pop    %edi
  802a81:	5d                   	pop    %ebp
  802a82:	c3                   	ret    
  802a83:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a84:	89 d1                	mov    %edx,%ecx
  802a86:	89 c5                	mov    %eax,%ebp
  802a88:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802a8c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802a90:	eb 8d                	jmp    802a1f <__umoddi3+0xaf>
  802a92:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a94:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802a98:	72 ea                	jb     802a84 <__umoddi3+0x114>
  802a9a:	89 f1                	mov    %esi,%ecx
  802a9c:	eb 81                	jmp    802a1f <__umoddi3+0xaf>
