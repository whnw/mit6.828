
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 97 02 00 00       	call   8002c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800040:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800043:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800046:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80004d:	00 
  80004e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800052:	89 1c 24             	mov    %ebx,(%esp)
  800055:	e8 a6 17 00 00       	call   801800 <readn>
  80005a:	83 f8 04             	cmp    $0x4,%eax
  80005d:	74 30                	je     80008f <primeproc+0x5b>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005f:	85 c0                	test   %eax,%eax
  800061:	0f 9e c2             	setle  %dl
  800064:	0f b6 d2             	movzbl %dl,%edx
  800067:	f7 da                	neg    %edx
  800069:	21 c2                	and    %eax,%edx
  80006b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80006f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800073:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  80007a:	00 
  80007b:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800082:	00 
  800083:	c7 04 24 6f 2b 80 00 	movl   $0x802b6f,(%esp)
  80008a:	e8 a9 02 00 00       	call   800338 <_panic>

	cprintf("%d\n", p);
  80008f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800092:	89 44 24 04          	mov    %eax,0x4(%esp)
  800096:	c7 04 24 81 2b 80 00 	movl   $0x802b81,(%esp)
  80009d:	e8 8e 03 00 00       	call   800430 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  8000a2:	89 3c 24             	mov    %edi,(%esp)
  8000a5:	e8 0b 23 00 00       	call   8023b5 <pipe>
  8000aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	79 20                	jns    8000d1 <primeproc+0x9d>
		panic("pipe: %e", i);
  8000b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b5:	c7 44 24 08 85 2b 80 	movl   $0x802b85,0x8(%esp)
  8000bc:	00 
  8000bd:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c4:	00 
  8000c5:	c7 04 24 6f 2b 80 00 	movl   $0x802b6f,(%esp)
  8000cc:	e8 67 02 00 00       	call   800338 <_panic>
	if ((id = fork()) < 0)
  8000d1:	e8 99 10 00 00       	call   80116f <fork>
  8000d6:	85 c0                	test   %eax,%eax
  8000d8:	79 20                	jns    8000fa <primeproc+0xc6>
		panic("fork: %e", id);
  8000da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000de:	c7 44 24 08 a5 2f 80 	movl   $0x802fa5,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 6f 2b 80 00 	movl   $0x802b6f,(%esp)
  8000f5:	e8 3e 02 00 00       	call   800338 <_panic>
	if (id == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1b                	jne    800119 <primeproc+0xe5>
		close(fd);
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	e8 04 15 00 00       	call   80160a <close>
		close(pfd[1]);
  800106:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 f9 14 00 00       	call   80160a <close>
		fd = pfd[0];
  800111:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800114:	e9 2d ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  800119:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 e6 14 00 00       	call   80160a <close>
	wfd = pfd[1];
  800124:	8b 7d dc             	mov    -0x24(%ebp),%edi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800127:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80012a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800131:	00 
  800132:	89 74 24 04          	mov    %esi,0x4(%esp)
  800136:	89 1c 24             	mov    %ebx,(%esp)
  800139:	e8 c2 16 00 00       	call   801800 <readn>
  80013e:	83 f8 04             	cmp    $0x4,%eax
  800141:	74 3b                	je     80017e <primeproc+0x14a>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800143:	85 c0                	test   %eax,%eax
  800145:	0f 9e c2             	setle  %dl
  800148:	0f b6 d2             	movzbl %dl,%edx
  80014b:	f7 da                	neg    %edx
  80014d:	21 c2                	and    %eax,%edx
  80014f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800153:	89 44 24 14          	mov    %eax,0x14(%esp)
  800157:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 8e 2b 80 	movl   $0x802b8e,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 6f 2b 80 00 	movl   $0x802b6f,(%esp)
  800179:	e8 ba 01 00 00       	call   800338 <_panic>
		if (i%p)
  80017e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800181:	99                   	cltd   
  800182:	f7 7d e0             	idivl  -0x20(%ebp)
  800185:	85 d2                	test   %edx,%edx
  800187:	74 a1                	je     80012a <primeproc+0xf6>
			if ((r=write(wfd, &i, 4)) != 4)
  800189:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800190:	00 
  800191:	89 74 24 04          	mov    %esi,0x4(%esp)
  800195:	89 3c 24             	mov    %edi,(%esp)
  800198:	e8 ae 16 00 00       	call   80184b <write>
  80019d:	83 f8 04             	cmp    $0x4,%eax
  8001a0:	74 88                	je     80012a <primeproc+0xf6>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	0f 9e c2             	setle  %dl
  8001a7:	0f b6 d2             	movzbl %dl,%edx
  8001aa:	f7 da                	neg    %edx
  8001ac:	21 c2                	and    %eax,%edx
  8001ae:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bd:	c7 44 24 08 aa 2b 80 	movl   $0x802baa,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 6f 2b 80 00 	movl   $0x802b6f,(%esp)
  8001d4:	e8 5f 01 00 00       	call   800338 <_panic>

008001d9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 34             	sub    $0x34,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  8001e0:	c7 05 00 40 80 00 c4 	movl   $0x802bc4,0x804000
  8001e7:	2b 80 00 

	if ((i=pipe(p)) < 0)
  8001ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	e8 c0 21 00 00       	call   8023b5 <pipe>
  8001f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	79 20                	jns    80021c <umain+0x43>
		panic("pipe: %e", i);
  8001fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800200:	c7 44 24 08 85 2b 80 	movl   $0x802b85,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 6f 2b 80 00 	movl   $0x802b6f,(%esp)
  800217:	e8 1c 01 00 00       	call   800338 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80021c:	e8 4e 0f 00 00       	call   80116f <fork>
  800221:	85 c0                	test   %eax,%eax
  800223:	79 20                	jns    800245 <umain+0x6c>
		panic("fork: %e", id);
  800225:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800229:	c7 44 24 08 a5 2f 80 	movl   $0x802fa5,0x8(%esp)
  800230:	00 
  800231:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 6f 2b 80 00 	movl   $0x802b6f,(%esp)
  800240:	e8 f3 00 00 00       	call   800338 <_panic>

	if (id == 0) {
  800245:	85 c0                	test   %eax,%eax
  800247:	75 16                	jne    80025f <umain+0x86>
		close(p[1]);
  800249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 b6 13 00 00       	call   80160a <close>
		primeproc(p[0]);
  800254:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 d5 fd ff ff       	call   800034 <primeproc>
	}

	close(p[0]);
  80025f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	e8 a0 13 00 00       	call   80160a <close>

	// feed all the integers through
	for (i=2;; i++)
  80026a:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800271:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800274:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80027b:	00 
  80027c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800280:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 c0 15 00 00       	call   80184b <write>
  80028b:	83 f8 04             	cmp    $0x4,%eax
  80028e:	74 30                	je     8002c0 <umain+0xe7>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800290:	85 c0                	test   %eax,%eax
  800292:	0f 9e c2             	setle  %dl
  800295:	0f b6 d2             	movzbl %dl,%edx
  800298:	f7 da                	neg    %edx
  80029a:	21 c2                	and    %eax,%edx
  80029c:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a4:	c7 44 24 08 cf 2b 80 	movl   $0x802bcf,0x8(%esp)
  8002ab:	00 
  8002ac:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002b3:	00 
  8002b4:	c7 04 24 6f 2b 80 00 	movl   $0x802b6f,(%esp)
  8002bb:	e8 78 00 00 00       	call   800338 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  8002c0:	ff 45 f4             	incl   -0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  8002c3:	eb af                	jmp    800274 <umain+0x9b>
  8002c5:	00 00                	add    %al,(%eax)
	...

008002c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	83 ec 10             	sub    $0x10,%esp
  8002d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002d6:	e8 b4 0a 00 00       	call   800d8f <sys_getenvid>
  8002db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002e7:	c1 e0 07             	shl    $0x7,%eax
  8002ea:	29 d0                	sub    %edx,%eax
  8002ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f1:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f6:	85 f6                	test   %esi,%esi
  8002f8:	7e 07                	jle    800301 <libmain+0x39>
		binaryname = argv[0];
  8002fa:	8b 03                	mov    (%ebx),%eax
  8002fc:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800301:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800305:	89 34 24             	mov    %esi,(%esp)
  800308:	e8 cc fe ff ff       	call   8001d9 <umain>

	// exit gracefully
	exit();
  80030d:	e8 0a 00 00 00       	call   80031c <exit>
}
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    
  800319:	00 00                	add    %al,(%eax)
	...

0080031c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800322:	e8 14 13 00 00       	call   80163b <close_all>
	sys_env_destroy(0);
  800327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80032e:	e8 0a 0a 00 00       	call   800d3d <sys_env_destroy>
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    
  800335:	00 00                	add    %al,(%eax)
	...

00800338 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800343:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800349:	e8 41 0a 00 00       	call   800d8f <sys_getenvid>
  80034e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800351:	89 54 24 10          	mov    %edx,0x10(%esp)
  800355:	8b 55 08             	mov    0x8(%ebp),%edx
  800358:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80035c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800360:	89 44 24 04          	mov    %eax,0x4(%esp)
  800364:	c7 04 24 f4 2b 80 00 	movl   $0x802bf4,(%esp)
  80036b:	e8 c0 00 00 00       	call   800430 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800370:	89 74 24 04          	mov    %esi,0x4(%esp)
  800374:	8b 45 10             	mov    0x10(%ebp),%eax
  800377:	89 04 24             	mov    %eax,(%esp)
  80037a:	e8 50 00 00 00       	call   8003cf <vcprintf>
	cprintf("\n");
  80037f:	c7 04 24 83 2b 80 00 	movl   $0x802b83,(%esp)
  800386:	e8 a5 00 00 00       	call   800430 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038b:	cc                   	int3   
  80038c:	eb fd                	jmp    80038b <_panic+0x53>
	...

00800390 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	53                   	push   %ebx
  800394:	83 ec 14             	sub    $0x14,%esp
  800397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039a:	8b 03                	mov    (%ebx),%eax
  80039c:	8b 55 08             	mov    0x8(%ebp),%edx
  80039f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003a3:	40                   	inc    %eax
  8003a4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ab:	75 19                	jne    8003c6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003ad:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003b4:	00 
  8003b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 40 09 00 00       	call   800d00 <sys_cputs>
		b->idx = 0;
  8003c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003c6:	ff 43 04             	incl   0x4(%ebx)
}
  8003c9:	83 c4 14             	add    $0x14,%esp
  8003cc:	5b                   	pop    %ebx
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003df:	00 00 00 
	b.cnt = 0;
  8003e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800400:	89 44 24 04          	mov    %eax,0x4(%esp)
  800404:	c7 04 24 90 03 80 00 	movl   $0x800390,(%esp)
  80040b:	e8 82 01 00 00       	call   800592 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800410:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800416:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	e8 d8 08 00 00       	call   800d00 <sys_cputs>

	return b.cnt;
}
  800428:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800436:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 87 ff ff ff       	call   8003cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800448:	c9                   	leave  
  800449:	c3                   	ret    
	...

0080044c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	53                   	push   %ebx
  800452:	83 ec 3c             	sub    $0x3c,%esp
  800455:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800458:	89 d7                	mov    %edx,%edi
  80045a:	8b 45 08             	mov    0x8(%ebp),%eax
  80045d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800469:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80046c:	85 c0                	test   %eax,%eax
  80046e:	75 08                	jne    800478 <printnum+0x2c>
  800470:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800473:	39 45 10             	cmp    %eax,0x10(%ebp)
  800476:	77 57                	ja     8004cf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800478:	89 74 24 10          	mov    %esi,0x10(%esp)
  80047c:	4b                   	dec    %ebx
  80047d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800481:	8b 45 10             	mov    0x10(%ebp),%eax
  800484:	89 44 24 08          	mov    %eax,0x8(%esp)
  800488:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80048c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800490:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800497:	00 
  800498:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a5:	e8 3e 24 00 00       	call   8028e8 <__udivdi3>
  8004aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004b2:	89 04 24             	mov    %eax,(%esp)
  8004b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b9:	89 fa                	mov    %edi,%edx
  8004bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004be:	e8 89 ff ff ff       	call   80044c <printnum>
  8004c3:	eb 0f                	jmp    8004d4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c9:	89 34 24             	mov    %esi,(%esp)
  8004cc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004cf:	4b                   	dec    %ebx
  8004d0:	85 db                	test   %ebx,%ebx
  8004d2:	7f f1                	jg     8004c5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ea:	00 
  8004eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ee:	89 04 24             	mov    %eax,(%esp)
  8004f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f8:	e8 0b 25 00 00       	call   802a08 <__umoddi3>
  8004fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800501:	0f be 80 17 2c 80 00 	movsbl 0x802c17(%eax),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80050e:	83 c4 3c             	add    $0x3c,%esp
  800511:	5b                   	pop    %ebx
  800512:	5e                   	pop    %esi
  800513:	5f                   	pop    %edi
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800519:	83 fa 01             	cmp    $0x1,%edx
  80051c:	7e 0e                	jle    80052c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80051e:	8b 10                	mov    (%eax),%edx
  800520:	8d 4a 08             	lea    0x8(%edx),%ecx
  800523:	89 08                	mov    %ecx,(%eax)
  800525:	8b 02                	mov    (%edx),%eax
  800527:	8b 52 04             	mov    0x4(%edx),%edx
  80052a:	eb 22                	jmp    80054e <getuint+0x38>
	else if (lflag)
  80052c:	85 d2                	test   %edx,%edx
  80052e:	74 10                	je     800540 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800530:	8b 10                	mov    (%eax),%edx
  800532:	8d 4a 04             	lea    0x4(%edx),%ecx
  800535:	89 08                	mov    %ecx,(%eax)
  800537:	8b 02                	mov    (%edx),%eax
  800539:	ba 00 00 00 00       	mov    $0x0,%edx
  80053e:	eb 0e                	jmp    80054e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800540:	8b 10                	mov    (%eax),%edx
  800542:	8d 4a 04             	lea    0x4(%edx),%ecx
  800545:	89 08                	mov    %ecx,(%eax)
  800547:	8b 02                	mov    (%edx),%eax
  800549:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800556:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800559:	8b 10                	mov    (%eax),%edx
  80055b:	3b 50 04             	cmp    0x4(%eax),%edx
  80055e:	73 08                	jae    800568 <sprintputch+0x18>
		*b->buf++ = ch;
  800560:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800563:	88 0a                	mov    %cl,(%edx)
  800565:	42                   	inc    %edx
  800566:	89 10                	mov    %edx,(%eax)
}
  800568:	5d                   	pop    %ebp
  800569:	c3                   	ret    

0080056a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800570:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800573:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800577:	8b 45 10             	mov    0x10(%ebp),%eax
  80057a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	8b 45 08             	mov    0x8(%ebp),%eax
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	e8 02 00 00 00       	call   800592 <vprintfmt>
	va_end(ap);
}
  800590:	c9                   	leave  
  800591:	c3                   	ret    

00800592 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800592:	55                   	push   %ebp
  800593:	89 e5                	mov    %esp,%ebp
  800595:	57                   	push   %edi
  800596:	56                   	push   %esi
  800597:	53                   	push   %ebx
  800598:	83 ec 4c             	sub    $0x4c,%esp
  80059b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059e:	8b 75 10             	mov    0x10(%ebp),%esi
  8005a1:	eb 12                	jmp    8005b5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	0f 84 6b 03 00 00    	je     800916 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b5:	0f b6 06             	movzbl (%esi),%eax
  8005b8:	46                   	inc    %esi
  8005b9:	83 f8 25             	cmp    $0x25,%eax
  8005bc:	75 e5                	jne    8005a3 <vprintfmt+0x11>
  8005be:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005c2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005ce:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005da:	eb 26                	jmp    800602 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005df:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005e3:	eb 1d                	jmp    800602 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005e8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005ec:	eb 14                	jmp    800602 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f8:	eb 08                	jmp    800602 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005fa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800602:	0f b6 06             	movzbl (%esi),%eax
  800605:	8d 56 01             	lea    0x1(%esi),%edx
  800608:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80060b:	8a 16                	mov    (%esi),%dl
  80060d:	83 ea 23             	sub    $0x23,%edx
  800610:	80 fa 55             	cmp    $0x55,%dl
  800613:	0f 87 e1 02 00 00    	ja     8008fa <vprintfmt+0x368>
  800619:	0f b6 d2             	movzbl %dl,%edx
  80061c:	ff 24 95 60 2d 80 00 	jmp    *0x802d60(,%edx,4)
  800623:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800626:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80062b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80062e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800632:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800635:	8d 50 d0             	lea    -0x30(%eax),%edx
  800638:	83 fa 09             	cmp    $0x9,%edx
  80063b:	77 2a                	ja     800667 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80063d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80063e:	eb eb                	jmp    80062b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80064e:	eb 17                	jmp    800667 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800650:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800654:	78 98                	js     8005ee <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800659:	eb a7                	jmp    800602 <vprintfmt+0x70>
  80065b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80065e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800665:	eb 9b                	jmp    800602 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800667:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066b:	79 95                	jns    800602 <vprintfmt+0x70>
  80066d:	eb 8b                	jmp    8005fa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80066f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800673:	eb 8d                	jmp    800602 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 04             	lea    0x4(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800682:	8b 00                	mov    (%eax),%eax
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80068d:	e9 23 ff ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	79 02                	jns    8006a3 <vprintfmt+0x111>
  8006a1:	f7 d8                	neg    %eax
  8006a3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a5:	83 f8 10             	cmp    $0x10,%eax
  8006a8:	7f 0b                	jg     8006b5 <vprintfmt+0x123>
  8006aa:	8b 04 85 c0 2e 80 00 	mov    0x802ec0(,%eax,4),%eax
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	75 23                	jne    8006d8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b9:	c7 44 24 08 2f 2c 80 	movl   $0x802c2f,0x8(%esp)
  8006c0:	00 
  8006c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	89 04 24             	mov    %eax,(%esp)
  8006cb:	e8 9a fe ff ff       	call   80056a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d3:	e9 dd fe ff ff       	jmp    8005b5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006dc:	c7 44 24 08 ad 30 80 	movl   $0x8030ad,0x8(%esp)
  8006e3:	00 
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006eb:	89 14 24             	mov    %edx,(%esp)
  8006ee:	e8 77 fe ff ff       	call   80056a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f6:	e9 ba fe ff ff       	jmp    8005b5 <vprintfmt+0x23>
  8006fb:	89 f9                	mov    %edi,%ecx
  8006fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800700:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 04             	lea    0x4(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)
  80070c:	8b 30                	mov    (%eax),%esi
  80070e:	85 f6                	test   %esi,%esi
  800710:	75 05                	jne    800717 <vprintfmt+0x185>
				p = "(null)";
  800712:	be 28 2c 80 00       	mov    $0x802c28,%esi
			if (width > 0 && padc != '-')
  800717:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80071b:	0f 8e 84 00 00 00    	jle    8007a5 <vprintfmt+0x213>
  800721:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800725:	74 7e                	je     8007a5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800727:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80072b:	89 34 24             	mov    %esi,(%esp)
  80072e:	e8 8b 02 00 00       	call   8009be <strnlen>
  800733:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800736:	29 c2                	sub    %eax,%edx
  800738:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80073b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80073f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800742:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800745:	89 de                	mov    %ebx,%esi
  800747:	89 d3                	mov    %edx,%ebx
  800749:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074b:	eb 0b                	jmp    800758 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80074d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800751:	89 3c 24             	mov    %edi,(%esp)
  800754:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800757:	4b                   	dec    %ebx
  800758:	85 db                	test   %ebx,%ebx
  80075a:	7f f1                	jg     80074d <vprintfmt+0x1bb>
  80075c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80075f:	89 f3                	mov    %esi,%ebx
  800761:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800764:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800767:	85 c0                	test   %eax,%eax
  800769:	79 05                	jns    800770 <vprintfmt+0x1de>
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800773:	29 c2                	sub    %eax,%edx
  800775:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800778:	eb 2b                	jmp    8007a5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80077a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80077e:	74 18                	je     800798 <vprintfmt+0x206>
  800780:	8d 50 e0             	lea    -0x20(%eax),%edx
  800783:	83 fa 5e             	cmp    $0x5e,%edx
  800786:	76 10                	jbe    800798 <vprintfmt+0x206>
					putch('?', putdat);
  800788:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
  800796:	eb 0a                	jmp    8007a2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	89 04 24             	mov    %eax,(%esp)
  80079f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a2:	ff 4d e4             	decl   -0x1c(%ebp)
  8007a5:	0f be 06             	movsbl (%esi),%eax
  8007a8:	46                   	inc    %esi
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	74 21                	je     8007ce <vprintfmt+0x23c>
  8007ad:	85 ff                	test   %edi,%edi
  8007af:	78 c9                	js     80077a <vprintfmt+0x1e8>
  8007b1:	4f                   	dec    %edi
  8007b2:	79 c6                	jns    80077a <vprintfmt+0x1e8>
  8007b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b7:	89 de                	mov    %ebx,%esi
  8007b9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007bc:	eb 18                	jmp    8007d6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007cb:	4b                   	dec    %ebx
  8007cc:	eb 08                	jmp    8007d6 <vprintfmt+0x244>
  8007ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d1:	89 de                	mov    %ebx,%esi
  8007d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007d6:	85 db                	test   %ebx,%ebx
  8007d8:	7f e4                	jg     8007be <vprintfmt+0x22c>
  8007da:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007dd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007df:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007e2:	e9 ce fd ff ff       	jmp    8005b5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e7:	83 f9 01             	cmp    $0x1,%ecx
  8007ea:	7e 10                	jle    8007fc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8d 50 08             	lea    0x8(%eax),%edx
  8007f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f5:	8b 30                	mov    (%eax),%esi
  8007f7:	8b 78 04             	mov    0x4(%eax),%edi
  8007fa:	eb 26                	jmp    800822 <vprintfmt+0x290>
	else if (lflag)
  8007fc:	85 c9                	test   %ecx,%ecx
  8007fe:	74 12                	je     800812 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)
  800809:	8b 30                	mov    (%eax),%esi
  80080b:	89 f7                	mov    %esi,%edi
  80080d:	c1 ff 1f             	sar    $0x1f,%edi
  800810:	eb 10                	jmp    800822 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)
  80081b:	8b 30                	mov    (%eax),%esi
  80081d:	89 f7                	mov    %esi,%edi
  80081f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800822:	85 ff                	test   %edi,%edi
  800824:	78 0a                	js     800830 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800826:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082b:	e9 8c 00 00 00       	jmp    8008bc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800834:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80083b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80083e:	f7 de                	neg    %esi
  800840:	83 d7 00             	adc    $0x0,%edi
  800843:	f7 df                	neg    %edi
			}
			base = 10;
  800845:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084a:	eb 70                	jmp    8008bc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084c:	89 ca                	mov    %ecx,%edx
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
  800851:	e8 c0 fc ff ff       	call   800516 <getuint>
  800856:	89 c6                	mov    %eax,%esi
  800858:	89 d7                	mov    %edx,%edi
			base = 10;
  80085a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80085f:	eb 5b                	jmp    8008bc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800861:	89 ca                	mov    %ecx,%edx
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
  800866:	e8 ab fc ff ff       	call   800516 <getuint>
  80086b:	89 c6                	mov    %eax,%esi
  80086d:	89 d7                	mov    %edx,%edi
			base = 8;
  80086f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800874:	eb 46                	jmp    8008bc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800876:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800881:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800884:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800888:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80088f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	8d 50 04             	lea    0x4(%eax),%edx
  800898:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80089b:	8b 30                	mov    (%eax),%esi
  80089d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008a7:	eb 13                	jmp    8008bc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a9:	89 ca                	mov    %ecx,%edx
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ae:	e8 63 fc ff ff       	call   800516 <getuint>
  8008b3:	89 c6                	mov    %eax,%esi
  8008b5:	89 d7                	mov    %edx,%edi
			base = 16;
  8008b7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008bc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008c0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008cf:	89 34 24             	mov    %esi,(%esp)
  8008d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008d6:	89 da                	mov    %ebx,%edx
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	e8 6c fb ff ff       	call   80044c <printnum>
			break;
  8008e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008e3:	e9 cd fc ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ec:	89 04 24             	mov    %eax,(%esp)
  8008ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008f5:	e9 bb fc ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800905:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800908:	eb 01                	jmp    80090b <vprintfmt+0x379>
  80090a:	4e                   	dec    %esi
  80090b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80090f:	75 f9                	jne    80090a <vprintfmt+0x378>
  800911:	e9 9f fc ff ff       	jmp    8005b5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800916:	83 c4 4c             	add    $0x4c,%esp
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 28             	sub    $0x28,%esp
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800931:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800934:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093b:	85 c0                	test   %eax,%eax
  80093d:	74 30                	je     80096f <vsnprintf+0x51>
  80093f:	85 d2                	test   %edx,%edx
  800941:	7e 33                	jle    800976 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800943:	8b 45 14             	mov    0x14(%ebp),%eax
  800946:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80094a:	8b 45 10             	mov    0x10(%ebp),%eax
  80094d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800951:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800954:	89 44 24 04          	mov    %eax,0x4(%esp)
  800958:	c7 04 24 50 05 80 00 	movl   $0x800550,(%esp)
  80095f:	e8 2e fc ff ff       	call   800592 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800964:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800967:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096d:	eb 0c                	jmp    80097b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80096f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800974:	eb 05                	jmp    80097b <vsnprintf+0x5d>
  800976:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800983:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800986:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098a:	8b 45 10             	mov    0x10(%ebp),%eax
  80098d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	89 44 24 04          	mov    %eax,0x4(%esp)
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	89 04 24             	mov    %eax,(%esp)
  80099e:	e8 7b ff ff ff       	call   80091e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    
  8009a5:	00 00                	add    %al,(%eax)
	...

008009a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b3:	eb 01                	jmp    8009b6 <strlen+0xe>
		n++;
  8009b5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ba:	75 f9                	jne    8009b5 <strlen+0xd>
		n++;
	return n;
}
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8009c4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cc:	eb 01                	jmp    8009cf <strnlen+0x11>
		n++;
  8009ce:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cf:	39 d0                	cmp    %edx,%eax
  8009d1:	74 06                	je     8009d9 <strnlen+0x1b>
  8009d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009d7:	75 f5                	jne    8009ce <strnlen+0x10>
		n++;
	return n;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009f0:	42                   	inc    %edx
  8009f1:	84 c9                	test   %cl,%cl
  8009f3:	75 f5                	jne    8009ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	53                   	push   %ebx
  8009fc:	83 ec 08             	sub    $0x8,%esp
  8009ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a02:	89 1c 24             	mov    %ebx,(%esp)
  800a05:	e8 9e ff ff ff       	call   8009a8 <strlen>
	strcpy(dst + len, src);
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a11:	01 d8                	add    %ebx,%eax
  800a13:	89 04 24             	mov    %eax,(%esp)
  800a16:	e8 c0 ff ff ff       	call   8009db <strcpy>
	return dst;
}
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	83 c4 08             	add    $0x8,%esp
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a36:	eb 0c                	jmp    800a44 <strncpy+0x21>
		*dst++ = *src;
  800a38:	8a 1a                	mov    (%edx),%bl
  800a3a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3d:	80 3a 01             	cmpb   $0x1,(%edx)
  800a40:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a43:	41                   	inc    %ecx
  800a44:	39 f1                	cmp    %esi,%ecx
  800a46:	75 f0                	jne    800a38 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	8b 75 08             	mov    0x8(%ebp),%esi
  800a54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a57:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5a:	85 d2                	test   %edx,%edx
  800a5c:	75 0a                	jne    800a68 <strlcpy+0x1c>
  800a5e:	89 f0                	mov    %esi,%eax
  800a60:	eb 1a                	jmp    800a7c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a62:	88 18                	mov    %bl,(%eax)
  800a64:	40                   	inc    %eax
  800a65:	41                   	inc    %ecx
  800a66:	eb 02                	jmp    800a6a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a68:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800a6a:	4a                   	dec    %edx
  800a6b:	74 0a                	je     800a77 <strlcpy+0x2b>
  800a6d:	8a 19                	mov    (%ecx),%bl
  800a6f:	84 db                	test   %bl,%bl
  800a71:	75 ef                	jne    800a62 <strlcpy+0x16>
  800a73:	89 c2                	mov    %eax,%edx
  800a75:	eb 02                	jmp    800a79 <strlcpy+0x2d>
  800a77:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a79:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a7c:	29 f0                	sub    %esi,%eax
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a88:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a8b:	eb 02                	jmp    800a8f <strcmp+0xd>
		p++, q++;
  800a8d:	41                   	inc    %ecx
  800a8e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8f:	8a 01                	mov    (%ecx),%al
  800a91:	84 c0                	test   %al,%al
  800a93:	74 04                	je     800a99 <strcmp+0x17>
  800a95:	3a 02                	cmp    (%edx),%al
  800a97:	74 f4                	je     800a8d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a99:	0f b6 c0             	movzbl %al,%eax
  800a9c:	0f b6 12             	movzbl (%edx),%edx
  800a9f:	29 d0                	sub    %edx,%eax
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	53                   	push   %ebx
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aad:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800ab0:	eb 03                	jmp    800ab5 <strncmp+0x12>
		n--, p++, q++;
  800ab2:	4a                   	dec    %edx
  800ab3:	40                   	inc    %eax
  800ab4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab5:	85 d2                	test   %edx,%edx
  800ab7:	74 14                	je     800acd <strncmp+0x2a>
  800ab9:	8a 18                	mov    (%eax),%bl
  800abb:	84 db                	test   %bl,%bl
  800abd:	74 04                	je     800ac3 <strncmp+0x20>
  800abf:	3a 19                	cmp    (%ecx),%bl
  800ac1:	74 ef                	je     800ab2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac3:	0f b6 00             	movzbl (%eax),%eax
  800ac6:	0f b6 11             	movzbl (%ecx),%edx
  800ac9:	29 d0                	sub    %edx,%eax
  800acb:	eb 05                	jmp    800ad2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ade:	eb 05                	jmp    800ae5 <strchr+0x10>
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	74 0c                	je     800af0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae4:	40                   	inc    %eax
  800ae5:	8a 10                	mov    (%eax),%dl
  800ae7:	84 d2                	test   %dl,%dl
  800ae9:	75 f5                	jne    800ae0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800afb:	eb 05                	jmp    800b02 <strfind+0x10>
		if (*s == c)
  800afd:	38 ca                	cmp    %cl,%dl
  800aff:	74 07                	je     800b08 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b01:	40                   	inc    %eax
  800b02:	8a 10                	mov    (%eax),%dl
  800b04:	84 d2                	test   %dl,%dl
  800b06:	75 f5                	jne    800afd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b19:	85 c9                	test   %ecx,%ecx
  800b1b:	74 30                	je     800b4d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b23:	75 25                	jne    800b4a <memset+0x40>
  800b25:	f6 c1 03             	test   $0x3,%cl
  800b28:	75 20                	jne    800b4a <memset+0x40>
		c &= 0xFF;
  800b2a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	c1 e3 08             	shl    $0x8,%ebx
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	c1 e6 18             	shl    $0x18,%esi
  800b37:	89 d0                	mov    %edx,%eax
  800b39:	c1 e0 10             	shl    $0x10,%eax
  800b3c:	09 f0                	or     %esi,%eax
  800b3e:	09 d0                	or     %edx,%eax
  800b40:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b42:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b45:	fc                   	cld    
  800b46:	f3 ab                	rep stos %eax,%es:(%edi)
  800b48:	eb 03                	jmp    800b4d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4a:	fc                   	cld    
  800b4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b4d:	89 f8                	mov    %edi,%eax
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b62:	39 c6                	cmp    %eax,%esi
  800b64:	73 34                	jae    800b9a <memmove+0x46>
  800b66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b69:	39 d0                	cmp    %edx,%eax
  800b6b:	73 2d                	jae    800b9a <memmove+0x46>
		s += n;
		d += n;
  800b6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b70:	f6 c2 03             	test   $0x3,%dl
  800b73:	75 1b                	jne    800b90 <memmove+0x3c>
  800b75:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7b:	75 13                	jne    800b90 <memmove+0x3c>
  800b7d:	f6 c1 03             	test   $0x3,%cl
  800b80:	75 0e                	jne    800b90 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b82:	83 ef 04             	sub    $0x4,%edi
  800b85:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b88:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b8b:	fd                   	std    
  800b8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8e:	eb 07                	jmp    800b97 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b90:	4f                   	dec    %edi
  800b91:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b94:	fd                   	std    
  800b95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b97:	fc                   	cld    
  800b98:	eb 20                	jmp    800bba <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba0:	75 13                	jne    800bb5 <memmove+0x61>
  800ba2:	a8 03                	test   $0x3,%al
  800ba4:	75 0f                	jne    800bb5 <memmove+0x61>
  800ba6:	f6 c1 03             	test   $0x3,%cl
  800ba9:	75 0a                	jne    800bb5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bab:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bae:	89 c7                	mov    %eax,%edi
  800bb0:	fc                   	cld    
  800bb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb3:	eb 05                	jmp    800bba <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb5:	89 c7                	mov    %eax,%edi
  800bb7:	fc                   	cld    
  800bb8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	89 04 24             	mov    %eax,(%esp)
  800bd8:	e8 77 ff ff ff       	call   800b54 <memmove>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800beb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	eb 16                	jmp    800c0b <memcmp+0x2c>
		if (*s1 != *s2)
  800bf5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800bf8:	42                   	inc    %edx
  800bf9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800bfd:	38 c8                	cmp    %cl,%al
  800bff:	74 0a                	je     800c0b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c01:	0f b6 c0             	movzbl %al,%eax
  800c04:	0f b6 c9             	movzbl %cl,%ecx
  800c07:	29 c8                	sub    %ecx,%eax
  800c09:	eb 09                	jmp    800c14 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0b:	39 da                	cmp    %ebx,%edx
  800c0d:	75 e6                	jne    800bf5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c22:	89 c2                	mov    %eax,%edx
  800c24:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c27:	eb 05                	jmp    800c2e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c29:	38 08                	cmp    %cl,(%eax)
  800c2b:	74 05                	je     800c32 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2d:	40                   	inc    %eax
  800c2e:	39 d0                	cmp    %edx,%eax
  800c30:	72 f7                	jb     800c29 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c40:	eb 01                	jmp    800c43 <strtol+0xf>
		s++;
  800c42:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c43:	8a 02                	mov    (%edx),%al
  800c45:	3c 20                	cmp    $0x20,%al
  800c47:	74 f9                	je     800c42 <strtol+0xe>
  800c49:	3c 09                	cmp    $0x9,%al
  800c4b:	74 f5                	je     800c42 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4d:	3c 2b                	cmp    $0x2b,%al
  800c4f:	75 08                	jne    800c59 <strtol+0x25>
		s++;
  800c51:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c52:	bf 00 00 00 00       	mov    $0x0,%edi
  800c57:	eb 13                	jmp    800c6c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c59:	3c 2d                	cmp    $0x2d,%al
  800c5b:	75 0a                	jne    800c67 <strtol+0x33>
		s++, neg = 1;
  800c5d:	8d 52 01             	lea    0x1(%edx),%edx
  800c60:	bf 01 00 00 00       	mov    $0x1,%edi
  800c65:	eb 05                	jmp    800c6c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6c:	85 db                	test   %ebx,%ebx
  800c6e:	74 05                	je     800c75 <strtol+0x41>
  800c70:	83 fb 10             	cmp    $0x10,%ebx
  800c73:	75 28                	jne    800c9d <strtol+0x69>
  800c75:	8a 02                	mov    (%edx),%al
  800c77:	3c 30                	cmp    $0x30,%al
  800c79:	75 10                	jne    800c8b <strtol+0x57>
  800c7b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c7f:	75 0a                	jne    800c8b <strtol+0x57>
		s += 2, base = 16;
  800c81:	83 c2 02             	add    $0x2,%edx
  800c84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c89:	eb 12                	jmp    800c9d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c8b:	85 db                	test   %ebx,%ebx
  800c8d:	75 0e                	jne    800c9d <strtol+0x69>
  800c8f:	3c 30                	cmp    $0x30,%al
  800c91:	75 05                	jne    800c98 <strtol+0x64>
		s++, base = 8;
  800c93:	42                   	inc    %edx
  800c94:	b3 08                	mov    $0x8,%bl
  800c96:	eb 05                	jmp    800c9d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c98:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca4:	8a 0a                	mov    (%edx),%cl
  800ca6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ca9:	80 fb 09             	cmp    $0x9,%bl
  800cac:	77 08                	ja     800cb6 <strtol+0x82>
			dig = *s - '0';
  800cae:	0f be c9             	movsbl %cl,%ecx
  800cb1:	83 e9 30             	sub    $0x30,%ecx
  800cb4:	eb 1e                	jmp    800cd4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800cb6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cb9:	80 fb 19             	cmp    $0x19,%bl
  800cbc:	77 08                	ja     800cc6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800cbe:	0f be c9             	movsbl %cl,%ecx
  800cc1:	83 e9 57             	sub    $0x57,%ecx
  800cc4:	eb 0e                	jmp    800cd4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cc6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cc9:	80 fb 19             	cmp    $0x19,%bl
  800ccc:	77 12                	ja     800ce0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800cce:	0f be c9             	movsbl %cl,%ecx
  800cd1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cd4:	39 f1                	cmp    %esi,%ecx
  800cd6:	7d 0c                	jge    800ce4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800cd8:	42                   	inc    %edx
  800cd9:	0f af c6             	imul   %esi,%eax
  800cdc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cde:	eb c4                	jmp    800ca4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ce0:	89 c1                	mov    %eax,%ecx
  800ce2:	eb 02                	jmp    800ce6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ce4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ce6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cea:	74 05                	je     800cf1 <strtol+0xbd>
		*endptr = (char *) s;
  800cec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cef:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cf1:	85 ff                	test   %edi,%edi
  800cf3:	74 04                	je     800cf9 <strtol+0xc5>
  800cf5:	89 c8                	mov    %ecx,%eax
  800cf7:	f7 d8                	neg    %eax
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
	...

00800d00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	89 c3                	mov    %eax,%ebx
  800d13:	89 c7                	mov    %eax,%edi
  800d15:	89 c6                	mov    %eax,%esi
  800d17:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	ba 00 00 00 00       	mov    $0x0,%edx
  800d29:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2e:	89 d1                	mov    %edx,%ecx
  800d30:	89 d3                	mov    %edx,%ebx
  800d32:	89 d7                	mov    %edx,%edi
  800d34:	89 d6                	mov    %edx,%esi
  800d36:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 cb                	mov    %ecx,%ebx
  800d55:	89 cf                	mov    %ecx,%edi
  800d57:	89 ce                	mov    %ecx,%esi
  800d59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 28                	jle    800d87 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d63:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 08 23 2f 80 	movl   $0x802f23,0x8(%esp)
  800d72:	00 
  800d73:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7a:	00 
  800d7b:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  800d82:	e8 b1 f5 ff ff       	call   800338 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d87:	83 c4 2c             	add    $0x2c,%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 d3                	mov    %edx,%ebx
  800da3:	89 d7                	mov    %edx,%edi
  800da5:	89 d6                	mov    %edx,%esi
  800da7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_yield>:

void
sys_yield(void)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	ba 00 00 00 00       	mov    $0x0,%edx
  800db9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dbe:	89 d1                	mov    %edx,%ecx
  800dc0:	89 d3                	mov    %edx,%ebx
  800dc2:	89 d7                	mov    %edx,%edi
  800dc4:	89 d6                	mov    %edx,%esi
  800dc6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	be 00 00 00 00       	mov    $0x0,%esi
  800ddb:	b8 04 00 00 00       	mov    $0x4,%eax
  800de0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 f7                	mov    %esi,%edi
  800deb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 28                	jle    800e19 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dfc:	00 
  800dfd:	c7 44 24 08 23 2f 80 	movl   $0x802f23,0x8(%esp)
  800e04:	00 
  800e05:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0c:	00 
  800e0d:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  800e14:	e8 1f f5 ff ff       	call   800338 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e19:	83 c4 2c             	add    $0x2c,%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e2f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7e 28                	jle    800e6c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e48:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e4f:	00 
  800e50:	c7 44 24 08 23 2f 80 	movl   $0x802f23,0x8(%esp)
  800e57:	00 
  800e58:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5f:	00 
  800e60:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  800e67:	e8 cc f4 ff ff       	call   800338 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e6c:	83 c4 2c             	add    $0x2c,%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
  800e7a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e82:	b8 06 00 00 00       	mov    $0x6,%eax
  800e87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	89 df                	mov    %ebx,%edi
  800e8f:	89 de                	mov    %ebx,%esi
  800e91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e93:	85 c0                	test   %eax,%eax
  800e95:	7e 28                	jle    800ebf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ea2:	00 
  800ea3:	c7 44 24 08 23 2f 80 	movl   $0x802f23,0x8(%esp)
  800eaa:	00 
  800eab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb2:	00 
  800eb3:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  800eba:	e8 79 f4 ff ff       	call   800338 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ebf:	83 c4 2c             	add    $0x2c,%esp
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed5:	b8 08 00 00 00       	mov    $0x8,%eax
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 df                	mov    %ebx,%edi
  800ee2:	89 de                	mov    %ebx,%esi
  800ee4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	7e 28                	jle    800f12 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eee:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 08 23 2f 80 	movl   $0x802f23,0x8(%esp)
  800efd:	00 
  800efe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f05:	00 
  800f06:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  800f0d:	e8 26 f4 ff ff       	call   800338 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f12:	83 c4 2c             	add    $0x2c,%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f28:	b8 09 00 00 00       	mov    $0x9,%eax
  800f2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
  800f33:	89 df                	mov    %ebx,%edi
  800f35:	89 de                	mov    %ebx,%esi
  800f37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	7e 28                	jle    800f65 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f41:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f48:	00 
  800f49:	c7 44 24 08 23 2f 80 	movl   $0x802f23,0x8(%esp)
  800f50:	00 
  800f51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f58:	00 
  800f59:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  800f60:	e8 d3 f3 ff ff       	call   800338 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f65:	83 c4 2c             	add    $0x2c,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
  800f86:	89 df                	mov    %ebx,%edi
  800f88:	89 de                	mov    %ebx,%esi
  800f8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	7e 28                	jle    800fb8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f94:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 08 23 2f 80 	movl   $0x802f23,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  800fb3:	e8 80 f3 ff ff       	call   800338 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fb8:	83 c4 2c             	add    $0x2c,%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	be 00 00 00 00       	mov    $0x0,%esi
  800fcb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ff6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff9:	89 cb                	mov    %ecx,%ebx
  800ffb:	89 cf                	mov    %ecx,%edi
  800ffd:	89 ce                	mov    %ecx,%esi
  800fff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801001:	85 c0                	test   %eax,%eax
  801003:	7e 28                	jle    80102d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801005:	89 44 24 10          	mov    %eax,0x10(%esp)
  801009:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801010:	00 
  801011:	c7 44 24 08 23 2f 80 	movl   $0x802f23,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  801028:	e8 0b f3 ff ff       	call   800338 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80102d:	83 c4 2c             	add    $0x2c,%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	57                   	push   %edi
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103b:	ba 00 00 00 00       	mov    $0x0,%edx
  801040:	b8 0e 00 00 00       	mov    $0xe,%eax
  801045:	89 d1                	mov    %edx,%ecx
  801047:	89 d3                	mov    %edx,%ebx
  801049:	89 d7                	mov    %edx,%edi
  80104b:	89 d6                	mov    %edx,%esi
  80104d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105f:	b8 0f 00 00 00       	mov    $0xf,%eax
  801064:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801067:	8b 55 08             	mov    0x8(%ebp),%edx
  80106a:	89 df                	mov    %ebx,%edi
  80106c:	89 de                	mov    %ebx,%esi
  80106e:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801080:	b8 10 00 00 00       	mov    $0x10,%eax
  801085:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801088:	8b 55 08             	mov    0x8(%ebp),%edx
  80108b:	89 df                	mov    %ebx,%edi
  80108d:	89 de                	mov    %ebx,%esi
  80108f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    
	...

00801098 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	53                   	push   %ebx
  80109c:	83 ec 24             	sub    $0x24,%esp
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010a2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  8010a4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010a8:	74 2d                	je     8010d7 <pgfault+0x3f>
  8010aa:	89 d8                	mov    %ebx,%eax
  8010ac:	c1 e8 16             	shr    $0x16,%eax
  8010af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b6:	a8 01                	test   $0x1,%al
  8010b8:	74 1d                	je     8010d7 <pgfault+0x3f>
  8010ba:	89 d8                	mov    %ebx,%eax
  8010bc:	c1 e8 0c             	shr    $0xc,%eax
  8010bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c6:	f6 c2 01             	test   $0x1,%dl
  8010c9:	74 0c                	je     8010d7 <pgfault+0x3f>
  8010cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d2:	f6 c4 08             	test   $0x8,%ah
  8010d5:	75 1c                	jne    8010f3 <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  8010d7:	c7 44 24 08 50 2f 80 	movl   $0x802f50,0x8(%esp)
  8010de:	00 
  8010df:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8010e6:	00 
  8010e7:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  8010ee:	e8 45 f2 ff ff       	call   800338 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  8010f3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  8010f9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801100:	00 
  801101:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801108:	00 
  801109:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801110:	e8 b8 fc ff ff       	call   800dcd <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  801115:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80111c:	00 
  80111d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801121:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801128:	e8 91 fa ff ff       	call   800bbe <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  80112d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801134:	00 
  801135:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801139:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801140:	00 
  801141:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801148:	00 
  801149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801150:	e8 cc fc ff ff       	call   800e21 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  801155:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80115c:	00 
  80115d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801164:	e8 0b fd ff ff       	call   800e74 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  801169:	83 c4 24             	add    $0x24,%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	57                   	push   %edi
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801178:	c7 04 24 98 10 80 00 	movl   $0x801098,(%esp)
  80117f:	e8 74 15 00 00       	call   8026f8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801184:	ba 07 00 00 00       	mov    $0x7,%edx
  801189:	89 d0                	mov    %edx,%eax
  80118b:	cd 30                	int    $0x30
  80118d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801190:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  801192:	85 c0                	test   %eax,%eax
  801194:	79 20                	jns    8011b6 <fork+0x47>
		panic("sys_exofork: %e", envid);
  801196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80119a:	c7 44 24 08 9e 2f 80 	movl   $0x802f9e,0x8(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  8011a9:	00 
  8011aa:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  8011b1:	e8 82 f1 ff ff       	call   800338 <_panic>
	if (envid == 0)
  8011b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011ba:	75 25                	jne    8011e1 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8011bc:	e8 ce fb ff ff       	call   800d8f <sys_getenvid>
  8011c1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011c6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011cd:	c1 e0 07             	shl    $0x7,%eax
  8011d0:	29 d0                	sub    %edx,%eax
  8011d2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011d7:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8011dc:	e9 43 02 00 00       	jmp    801424 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  8011e1:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  8011e6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011ec:	0f 84 85 01 00 00    	je     801377 <fork+0x208>
  8011f2:	89 d8                	mov    %ebx,%eax
  8011f4:	c1 e8 16             	shr    $0x16,%eax
  8011f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011fe:	a8 01                	test   $0x1,%al
  801200:	0f 84 5f 01 00 00    	je     801365 <fork+0x1f6>
  801206:	89 d8                	mov    %ebx,%eax
  801208:	c1 e8 0c             	shr    $0xc,%eax
  80120b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	0f 84 4a 01 00 00    	je     801365 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  80121b:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  80121d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801224:	f6 c6 04             	test   $0x4,%dh
  801227:	74 50                	je     801279 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  801229:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801230:	25 07 0e 00 00       	and    $0xe07,%eax
  801235:	89 44 24 10          	mov    %eax,0x10(%esp)
  801239:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80123d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801241:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801245:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80124c:	e8 d0 fb ff ff       	call   800e21 <sys_page_map>
  801251:	85 c0                	test   %eax,%eax
  801253:	0f 89 0c 01 00 00    	jns    801365 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  801259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125d:	c7 44 24 08 ae 2f 80 	movl   $0x802fae,0x8(%esp)
  801264:	00 
  801265:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  80126c:	00 
  80126d:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  801274:	e8 bf f0 ff ff       	call   800338 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  801279:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801280:	f6 c2 02             	test   $0x2,%dl
  801283:	75 10                	jne    801295 <fork+0x126>
  801285:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128c:	f6 c4 08             	test   $0x8,%ah
  80128f:	0f 84 8c 00 00 00    	je     801321 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  801295:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80129c:	00 
  80129d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012a1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b0:	e8 6c fb ff ff       	call   800e21 <sys_page_map>
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	79 20                	jns    8012d9 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  8012b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012bd:	c7 44 24 08 ae 2f 80 	movl   $0x802fae,0x8(%esp)
  8012c4:	00 
  8012c5:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8012cc:	00 
  8012cd:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  8012d4:	e8 5f f0 ff ff       	call   800338 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  8012d9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012e0:	00 
  8012e1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012ec:	00 
  8012ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f8:	e8 24 fb ff ff       	call   800e21 <sys_page_map>
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	79 64                	jns    801365 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801305:	c7 44 24 08 ae 2f 80 	movl   $0x802fae,0x8(%esp)
  80130c:	00 
  80130d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801314:	00 
  801315:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  80131c:	e8 17 f0 ff ff       	call   800338 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  801321:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801328:	00 
  801329:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80132d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801331:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801335:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80133c:	e8 e0 fa ff ff       	call   800e21 <sys_page_map>
  801341:	85 c0                	test   %eax,%eax
  801343:	79 20                	jns    801365 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801345:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801349:	c7 44 24 08 ae 2f 80 	movl   $0x802fae,0x8(%esp)
  801350:	00 
  801351:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801358:	00 
  801359:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  801360:	e8 d3 ef ff ff       	call   800338 <_panic>
  801365:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  80136b:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801371:	0f 85 6f fe ff ff    	jne    8011e6 <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  801377:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80137e:	00 
  80137f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801386:	ee 
  801387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80138a:	89 04 24             	mov    %eax,(%esp)
  80138d:	e8 3b fa ff ff       	call   800dcd <sys_page_alloc>
  801392:	85 c0                	test   %eax,%eax
  801394:	79 20                	jns    8013b6 <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  801396:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139a:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  8013a1:	00 
  8013a2:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  8013a9:	00 
  8013aa:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  8013b1:	e8 82 ef ff ff       	call   800338 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8013b6:	c7 44 24 04 44 27 80 	movl   $0x802744,0x4(%esp)
  8013bd:	00 
  8013be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c1:	89 04 24             	mov    %eax,(%esp)
  8013c4:	e8 a4 fb ff ff       	call   800f6d <sys_env_set_pgfault_upcall>
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	79 20                	jns    8013ed <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  8013cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d1:	c7 44 24 08 74 2f 80 	movl   $0x802f74,0x8(%esp)
  8013d8:	00 
  8013d9:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  8013e0:	00 
  8013e1:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  8013e8:	e8 4b ef ff ff       	call   800338 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8013ed:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013f4:	00 
  8013f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013f8:	89 04 24             	mov    %eax,(%esp)
  8013fb:	e8 c7 fa ff ff       	call   800ec7 <sys_env_set_status>
  801400:	85 c0                	test   %eax,%eax
  801402:	79 20                	jns    801424 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801404:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801408:	c7 44 24 08 d3 2f 80 	movl   $0x802fd3,0x8(%esp)
  80140f:	00 
  801410:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801417:	00 
  801418:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  80141f:	e8 14 ef ff ff       	call   800338 <_panic>

	return envid;
	// panic("fork not implemented");
}
  801424:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801427:	83 c4 3c             	add    $0x3c,%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5f                   	pop    %edi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <sfork>:

// Challenge!
int
sfork(void)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801435:	c7 44 24 08 ea 2f 80 	movl   $0x802fea,0x8(%esp)
  80143c:	00 
  80143d:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801444:	00 
  801445:	c7 04 24 93 2f 80 00 	movl   $0x802f93,(%esp)
  80144c:	e8 e7 ee ff ff       	call   800338 <_panic>
  801451:	00 00                	add    %al,(%eax)
	...

00801454 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
  80145a:	05 00 00 00 30       	add    $0x30000000,%eax
  80145f:	c1 e8 0c             	shr    $0xc,%eax
}
  801462:	5d                   	pop    %ebp
  801463:	c3                   	ret    

00801464 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	89 04 24             	mov    %eax,(%esp)
  801470:	e8 df ff ff ff       	call   801454 <fd2num>
  801475:	c1 e0 0c             	shl    $0xc,%eax
  801478:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	53                   	push   %ebx
  801483:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801486:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80148b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	c1 ea 16             	shr    $0x16,%edx
  801492:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801499:	f6 c2 01             	test   $0x1,%dl
  80149c:	74 11                	je     8014af <fd_alloc+0x30>
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	c1 ea 0c             	shr    $0xc,%edx
  8014a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014aa:	f6 c2 01             	test   $0x1,%dl
  8014ad:	75 09                	jne    8014b8 <fd_alloc+0x39>
			*fd_store = fd;
  8014af:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b6:	eb 17                	jmp    8014cf <fd_alloc+0x50>
  8014b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014c2:	75 c7                	jne    80148b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014cf:	5b                   	pop    %ebx
  8014d0:	5d                   	pop    %ebp
  8014d1:	c3                   	ret    

008014d2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014d8:	83 f8 1f             	cmp    $0x1f,%eax
  8014db:	77 36                	ja     801513 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014dd:	c1 e0 0c             	shl    $0xc,%eax
  8014e0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014e5:	89 c2                	mov    %eax,%edx
  8014e7:	c1 ea 16             	shr    $0x16,%edx
  8014ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014f1:	f6 c2 01             	test   $0x1,%dl
  8014f4:	74 24                	je     80151a <fd_lookup+0x48>
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	c1 ea 0c             	shr    $0xc,%edx
  8014fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801502:	f6 c2 01             	test   $0x1,%dl
  801505:	74 1a                	je     801521 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801507:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150a:	89 02                	mov    %eax,(%edx)
	return 0;
  80150c:	b8 00 00 00 00       	mov    $0x0,%eax
  801511:	eb 13                	jmp    801526 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801513:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801518:	eb 0c                	jmp    801526 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80151a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151f:	eb 05                	jmp    801526 <fd_lookup+0x54>
  801521:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    

00801528 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	53                   	push   %ebx
  80152c:	83 ec 14             	sub    $0x14,%esp
  80152f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801535:	ba 00 00 00 00       	mov    $0x0,%edx
  80153a:	eb 0e                	jmp    80154a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80153c:	39 08                	cmp    %ecx,(%eax)
  80153e:	75 09                	jne    801549 <dev_lookup+0x21>
			*dev = devtab[i];
  801540:	89 03                	mov    %eax,(%ebx)
			return 0;
  801542:	b8 00 00 00 00       	mov    $0x0,%eax
  801547:	eb 33                	jmp    80157c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801549:	42                   	inc    %edx
  80154a:	8b 04 95 80 30 80 00 	mov    0x803080(,%edx,4),%eax
  801551:	85 c0                	test   %eax,%eax
  801553:	75 e7                	jne    80153c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801555:	a1 08 50 80 00       	mov    0x805008,%eax
  80155a:	8b 40 48             	mov    0x48(%eax),%eax
  80155d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801561:	89 44 24 04          	mov    %eax,0x4(%esp)
  801565:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80156c:	e8 bf ee ff ff       	call   800430 <cprintf>
	*dev = 0;
  801571:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801577:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80157c:	83 c4 14             	add    $0x14,%esp
  80157f:	5b                   	pop    %ebx
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	56                   	push   %esi
  801586:	53                   	push   %ebx
  801587:	83 ec 30             	sub    $0x30,%esp
  80158a:	8b 75 08             	mov    0x8(%ebp),%esi
  80158d:	8a 45 0c             	mov    0xc(%ebp),%al
  801590:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801593:	89 34 24             	mov    %esi,(%esp)
  801596:	e8 b9 fe ff ff       	call   801454 <fd2num>
  80159b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80159e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015a2:	89 04 24             	mov    %eax,(%esp)
  8015a5:	e8 28 ff ff ff       	call   8014d2 <fd_lookup>
  8015aa:	89 c3                	mov    %eax,%ebx
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 05                	js     8015b5 <fd_close+0x33>
	    || fd != fd2)
  8015b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015b3:	74 0d                	je     8015c2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8015b5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015b9:	75 46                	jne    801601 <fd_close+0x7f>
  8015bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c0:	eb 3f                	jmp    801601 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c9:	8b 06                	mov    (%esi),%eax
  8015cb:	89 04 24             	mov    %eax,(%esp)
  8015ce:	e8 55 ff ff ff       	call   801528 <dev_lookup>
  8015d3:	89 c3                	mov    %eax,%ebx
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 18                	js     8015f1 <fd_close+0x6f>
		if (dev->dev_close)
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	8b 40 10             	mov    0x10(%eax),%eax
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	74 09                	je     8015ec <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015e3:	89 34 24             	mov    %esi,(%esp)
  8015e6:	ff d0                	call   *%eax
  8015e8:	89 c3                	mov    %eax,%ebx
  8015ea:	eb 05                	jmp    8015f1 <fd_close+0x6f>
		else
			r = 0;
  8015ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fc:	e8 73 f8 ff ff       	call   800e74 <sys_page_unmap>
	return r;
}
  801601:	89 d8                	mov    %ebx,%eax
  801603:	83 c4 30             	add    $0x30,%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801610:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801613:	89 44 24 04          	mov    %eax,0x4(%esp)
  801617:	8b 45 08             	mov    0x8(%ebp),%eax
  80161a:	89 04 24             	mov    %eax,(%esp)
  80161d:	e8 b0 fe ff ff       	call   8014d2 <fd_lookup>
  801622:	85 c0                	test   %eax,%eax
  801624:	78 13                	js     801639 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801626:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80162d:	00 
  80162e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801631:	89 04 24             	mov    %eax,(%esp)
  801634:	e8 49 ff ff ff       	call   801582 <fd_close>
}
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <close_all>:

void
close_all(void)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	53                   	push   %ebx
  80163f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801642:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801647:	89 1c 24             	mov    %ebx,(%esp)
  80164a:	e8 bb ff ff ff       	call   80160a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80164f:	43                   	inc    %ebx
  801650:	83 fb 20             	cmp    $0x20,%ebx
  801653:	75 f2                	jne    801647 <close_all+0xc>
		close(i);
}
  801655:	83 c4 14             	add    $0x14,%esp
  801658:	5b                   	pop    %ebx
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    

0080165b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	57                   	push   %edi
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	83 ec 4c             	sub    $0x4c,%esp
  801664:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801667:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80166a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166e:	8b 45 08             	mov    0x8(%ebp),%eax
  801671:	89 04 24             	mov    %eax,(%esp)
  801674:	e8 59 fe ff ff       	call   8014d2 <fd_lookup>
  801679:	89 c3                	mov    %eax,%ebx
  80167b:	85 c0                	test   %eax,%eax
  80167d:	0f 88 e3 00 00 00    	js     801766 <dup+0x10b>
		return r;
	close(newfdnum);
  801683:	89 3c 24             	mov    %edi,(%esp)
  801686:	e8 7f ff ff ff       	call   80160a <close>

	newfd = INDEX2FD(newfdnum);
  80168b:	89 fe                	mov    %edi,%esi
  80168d:	c1 e6 0c             	shl    $0xc,%esi
  801690:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801696:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801699:	89 04 24             	mov    %eax,(%esp)
  80169c:	e8 c3 fd ff ff       	call   801464 <fd2data>
  8016a1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016a3:	89 34 24             	mov    %esi,(%esp)
  8016a6:	e8 b9 fd ff ff       	call   801464 <fd2data>
  8016ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ae:	89 d8                	mov    %ebx,%eax
  8016b0:	c1 e8 16             	shr    $0x16,%eax
  8016b3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016ba:	a8 01                	test   $0x1,%al
  8016bc:	74 46                	je     801704 <dup+0xa9>
  8016be:	89 d8                	mov    %ebx,%eax
  8016c0:	c1 e8 0c             	shr    $0xc,%eax
  8016c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ca:	f6 c2 01             	test   $0x1,%dl
  8016cd:	74 35                	je     801704 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8016db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016ed:	00 
  8016ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f9:	e8 23 f7 ff ff       	call   800e21 <sys_page_map>
  8016fe:	89 c3                	mov    %eax,%ebx
  801700:	85 c0                	test   %eax,%eax
  801702:	78 3b                	js     80173f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801704:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801707:	89 c2                	mov    %eax,%edx
  801709:	c1 ea 0c             	shr    $0xc,%edx
  80170c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801713:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801719:	89 54 24 10          	mov    %edx,0x10(%esp)
  80171d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801721:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801728:	00 
  801729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801734:	e8 e8 f6 ff ff       	call   800e21 <sys_page_map>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	79 25                	jns    801764 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80173f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801743:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80174a:	e8 25 f7 ff ff       	call   800e74 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80174f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801752:	89 44 24 04          	mov    %eax,0x4(%esp)
  801756:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80175d:	e8 12 f7 ff ff       	call   800e74 <sys_page_unmap>
	return r;
  801762:	eb 02                	jmp    801766 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801764:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801766:	89 d8                	mov    %ebx,%eax
  801768:	83 c4 4c             	add    $0x4c,%esp
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5f                   	pop    %edi
  80176e:	5d                   	pop    %ebp
  80176f:	c3                   	ret    

00801770 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	53                   	push   %ebx
  801774:	83 ec 24             	sub    $0x24,%esp
  801777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	89 1c 24             	mov    %ebx,(%esp)
  801784:	e8 49 fd ff ff       	call   8014d2 <fd_lookup>
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 6d                	js     8017fa <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801790:	89 44 24 04          	mov    %eax,0x4(%esp)
  801794:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801797:	8b 00                	mov    (%eax),%eax
  801799:	89 04 24             	mov    %eax,(%esp)
  80179c:	e8 87 fd ff ff       	call   801528 <dev_lookup>
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 55                	js     8017fa <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a8:	8b 50 08             	mov    0x8(%eax),%edx
  8017ab:	83 e2 03             	and    $0x3,%edx
  8017ae:	83 fa 01             	cmp    $0x1,%edx
  8017b1:	75 23                	jne    8017d6 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017b3:	a1 08 50 80 00       	mov    0x805008,%eax
  8017b8:	8b 40 48             	mov    0x48(%eax),%eax
  8017bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c3:	c7 04 24 44 30 80 00 	movl   $0x803044,(%esp)
  8017ca:	e8 61 ec ff ff       	call   800430 <cprintf>
		return -E_INVAL;
  8017cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d4:	eb 24                	jmp    8017fa <read+0x8a>
	}
	if (!dev->dev_read)
  8017d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d9:	8b 52 08             	mov    0x8(%edx),%edx
  8017dc:	85 d2                	test   %edx,%edx
  8017de:	74 15                	je     8017f5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ea:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ee:	89 04 24             	mov    %eax,(%esp)
  8017f1:	ff d2                	call   *%edx
  8017f3:	eb 05                	jmp    8017fa <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017fa:	83 c4 24             	add    $0x24,%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	57                   	push   %edi
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	83 ec 1c             	sub    $0x1c,%esp
  801809:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80180f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801814:	eb 23                	jmp    801839 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801816:	89 f0                	mov    %esi,%eax
  801818:	29 d8                	sub    %ebx,%eax
  80181a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80181e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801821:	01 d8                	add    %ebx,%eax
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	89 3c 24             	mov    %edi,(%esp)
  80182a:	e8 41 ff ff ff       	call   801770 <read>
		if (m < 0)
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 10                	js     801843 <readn+0x43>
			return m;
		if (m == 0)
  801833:	85 c0                	test   %eax,%eax
  801835:	74 0a                	je     801841 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801837:	01 c3                	add    %eax,%ebx
  801839:	39 f3                	cmp    %esi,%ebx
  80183b:	72 d9                	jb     801816 <readn+0x16>
  80183d:	89 d8                	mov    %ebx,%eax
  80183f:	eb 02                	jmp    801843 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801841:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801843:	83 c4 1c             	add    $0x1c,%esp
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	5f                   	pop    %edi
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 24             	sub    $0x24,%esp
  801852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185c:	89 1c 24             	mov    %ebx,(%esp)
  80185f:	e8 6e fc ff ff       	call   8014d2 <fd_lookup>
  801864:	85 c0                	test   %eax,%eax
  801866:	78 68                	js     8018d0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801868:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801872:	8b 00                	mov    (%eax),%eax
  801874:	89 04 24             	mov    %eax,(%esp)
  801877:	e8 ac fc ff ff       	call   801528 <dev_lookup>
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 50                	js     8018d0 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801883:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801887:	75 23                	jne    8018ac <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801889:	a1 08 50 80 00       	mov    0x805008,%eax
  80188e:	8b 40 48             	mov    0x48(%eax),%eax
  801891:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801895:	89 44 24 04          	mov    %eax,0x4(%esp)
  801899:	c7 04 24 60 30 80 00 	movl   $0x803060,(%esp)
  8018a0:	e8 8b eb ff ff       	call   800430 <cprintf>
		return -E_INVAL;
  8018a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018aa:	eb 24                	jmp    8018d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018af:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b2:	85 d2                	test   %edx,%edx
  8018b4:	74 15                	je     8018cb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018c4:	89 04 24             	mov    %eax,(%esp)
  8018c7:	ff d2                	call   *%edx
  8018c9:	eb 05                	jmp    8018d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018d0:	83 c4 24             	add    $0x24,%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    

008018d6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018dc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	89 04 24             	mov    %eax,(%esp)
  8018e9:	e8 e4 fb ff ff       	call   8014d2 <fd_lookup>
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 0e                	js     801900 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 24             	sub    $0x24,%esp
  801909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80190c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80190f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801913:	89 1c 24             	mov    %ebx,(%esp)
  801916:	e8 b7 fb ff ff       	call   8014d2 <fd_lookup>
  80191b:	85 c0                	test   %eax,%eax
  80191d:	78 61                	js     801980 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801922:	89 44 24 04          	mov    %eax,0x4(%esp)
  801926:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801929:	8b 00                	mov    (%eax),%eax
  80192b:	89 04 24             	mov    %eax,(%esp)
  80192e:	e8 f5 fb ff ff       	call   801528 <dev_lookup>
  801933:	85 c0                	test   %eax,%eax
  801935:	78 49                	js     801980 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801937:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80193e:	75 23                	jne    801963 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801940:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801945:	8b 40 48             	mov    0x48(%eax),%eax
  801948:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80194c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801950:	c7 04 24 20 30 80 00 	movl   $0x803020,(%esp)
  801957:	e8 d4 ea ff ff       	call   800430 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80195c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801961:	eb 1d                	jmp    801980 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801963:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801966:	8b 52 18             	mov    0x18(%edx),%edx
  801969:	85 d2                	test   %edx,%edx
  80196b:	74 0e                	je     80197b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80196d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801970:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801974:	89 04 24             	mov    %eax,(%esp)
  801977:	ff d2                	call   *%edx
  801979:	eb 05                	jmp    801980 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80197b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801980:	83 c4 24             	add    $0x24,%esp
  801983:	5b                   	pop    %ebx
  801984:	5d                   	pop    %ebp
  801985:	c3                   	ret    

00801986 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	53                   	push   %ebx
  80198a:	83 ec 24             	sub    $0x24,%esp
  80198d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801990:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801993:	89 44 24 04          	mov    %eax,0x4(%esp)
  801997:	8b 45 08             	mov    0x8(%ebp),%eax
  80199a:	89 04 24             	mov    %eax,(%esp)
  80199d:	e8 30 fb ff ff       	call   8014d2 <fd_lookup>
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	78 52                	js     8019f8 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b0:	8b 00                	mov    (%eax),%eax
  8019b2:	89 04 24             	mov    %eax,(%esp)
  8019b5:	e8 6e fb ff ff       	call   801528 <dev_lookup>
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 3a                	js     8019f8 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019c5:	74 2c                	je     8019f3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019c7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019ca:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019d1:	00 00 00 
	stat->st_isdir = 0;
  8019d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019db:	00 00 00 
	stat->st_dev = dev;
  8019de:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019eb:	89 14 24             	mov    %edx,(%esp)
  8019ee:	ff 50 14             	call   *0x14(%eax)
  8019f1:	eb 05                	jmp    8019f8 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019f8:	83 c4 24             	add    $0x24,%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    

008019fe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a0d:	00 
  801a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a11:	89 04 24             	mov    %eax,(%esp)
  801a14:	e8 2a 02 00 00       	call   801c43 <open>
  801a19:	89 c3                	mov    %eax,%ebx
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 1b                	js     801a3a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a26:	89 1c 24             	mov    %ebx,(%esp)
  801a29:	e8 58 ff ff ff       	call   801986 <fstat>
  801a2e:	89 c6                	mov    %eax,%esi
	close(fd);
  801a30:	89 1c 24             	mov    %ebx,(%esp)
  801a33:	e8 d2 fb ff ff       	call   80160a <close>
	return r;
  801a38:	89 f3                	mov    %esi,%ebx
}
  801a3a:	89 d8                	mov    %ebx,%eax
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	5b                   	pop    %ebx
  801a40:	5e                   	pop    %esi
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    
	...

00801a44 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	56                   	push   %esi
  801a48:	53                   	push   %ebx
  801a49:	83 ec 10             	sub    $0x10,%esp
  801a4c:	89 c3                	mov    %eax,%ebx
  801a4e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a50:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a57:	75 11                	jne    801a6a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a60:	e8 fa 0d 00 00       	call   80285f <ipc_find_env>
  801a65:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a6a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a71:	00 
  801a72:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a79:	00 
  801a7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a7e:	a1 00 50 80 00       	mov    0x805000,%eax
  801a83:	89 04 24             	mov    %eax,(%esp)
  801a86:	e8 51 0d 00 00       	call   8027dc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a92:	00 
  801a93:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9e:	e8 c9 0c 00 00       	call   80276c <ipc_recv>
}
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801abb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abe:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac8:	b8 02 00 00 00       	mov    $0x2,%eax
  801acd:	e8 72 ff ff ff       	call   801a44 <fsipc>
}
  801ad2:	c9                   	leave  
  801ad3:	c3                   	ret    

00801ad4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae0:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aea:	b8 06 00 00 00       	mov    $0x6,%eax
  801aef:	e8 50 ff ff ff       	call   801a44 <fsipc>
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	53                   	push   %ebx
  801afa:	83 ec 14             	sub    $0x14,%esp
  801afd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b00:	8b 45 08             	mov    0x8(%ebp),%eax
  801b03:	8b 40 0c             	mov    0xc(%eax),%eax
  801b06:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b10:	b8 05 00 00 00       	mov    $0x5,%eax
  801b15:	e8 2a ff ff ff       	call   801a44 <fsipc>
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 2b                	js     801b49 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b1e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b25:	00 
  801b26:	89 1c 24             	mov    %ebx,(%esp)
  801b29:	e8 ad ee ff ff       	call   8009db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b2e:	a1 80 60 80 00       	mov    0x806080,%eax
  801b33:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b39:	a1 84 60 80 00       	mov    0x806084,%eax
  801b3e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b49:	83 c4 14             	add    $0x14,%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	83 ec 18             	sub    $0x18,%esp
  801b55:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b58:	8b 55 08             	mov    0x8(%ebp),%edx
  801b5b:	8b 52 0c             	mov    0xc(%edx),%edx
  801b5e:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b64:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801b69:	89 c2                	mov    %eax,%edx
  801b6b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b70:	76 05                	jbe    801b77 <devfile_write+0x28>
  801b72:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801b77:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b82:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801b89:	e8 30 f0 ff ff       	call   800bbe <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b93:	b8 04 00 00 00       	mov    $0x4,%eax
  801b98:	e8 a7 fe ff ff       	call   801a44 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 10             	sub    $0x10,%esp
  801ba7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801baa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bad:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bb5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc0:	b8 03 00 00 00       	mov    $0x3,%eax
  801bc5:	e8 7a fe ff ff       	call   801a44 <fsipc>
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	78 6a                	js     801c3a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bd0:	39 c6                	cmp    %eax,%esi
  801bd2:	73 24                	jae    801bf8 <devfile_read+0x59>
  801bd4:	c7 44 24 0c 94 30 80 	movl   $0x803094,0xc(%esp)
  801bdb:	00 
  801bdc:	c7 44 24 08 9b 30 80 	movl   $0x80309b,0x8(%esp)
  801be3:	00 
  801be4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801beb:	00 
  801bec:	c7 04 24 b0 30 80 00 	movl   $0x8030b0,(%esp)
  801bf3:	e8 40 e7 ff ff       	call   800338 <_panic>
	assert(r <= PGSIZE);
  801bf8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bfd:	7e 24                	jle    801c23 <devfile_read+0x84>
  801bff:	c7 44 24 0c bb 30 80 	movl   $0x8030bb,0xc(%esp)
  801c06:	00 
  801c07:	c7 44 24 08 9b 30 80 	movl   $0x80309b,0x8(%esp)
  801c0e:	00 
  801c0f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c16:	00 
  801c17:	c7 04 24 b0 30 80 00 	movl   $0x8030b0,(%esp)
  801c1e:	e8 15 e7 ff ff       	call   800338 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c27:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c2e:	00 
  801c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c32:	89 04 24             	mov    %eax,(%esp)
  801c35:	e8 1a ef ff ff       	call   800b54 <memmove>
	return r;
}
  801c3a:	89 d8                	mov    %ebx,%eax
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	83 ec 20             	sub    $0x20,%esp
  801c4b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c4e:	89 34 24             	mov    %esi,(%esp)
  801c51:	e8 52 ed ff ff       	call   8009a8 <strlen>
  801c56:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c5b:	7f 60                	jg     801cbd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c60:	89 04 24             	mov    %eax,(%esp)
  801c63:	e8 17 f8 ff ff       	call   80147f <fd_alloc>
  801c68:	89 c3                	mov    %eax,%ebx
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	78 54                	js     801cc2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c72:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801c79:	e8 5d ed ff ff       	call   8009db <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c81:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c89:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8e:	e8 b1 fd ff ff       	call   801a44 <fsipc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	85 c0                	test   %eax,%eax
  801c97:	79 15                	jns    801cae <open+0x6b>
		fd_close(fd, 0);
  801c99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ca0:	00 
  801ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca4:	89 04 24             	mov    %eax,(%esp)
  801ca7:	e8 d6 f8 ff ff       	call   801582 <fd_close>
		return r;
  801cac:	eb 14                	jmp    801cc2 <open+0x7f>
	}

	return fd2num(fd);
  801cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb1:	89 04 24             	mov    %eax,(%esp)
  801cb4:	e8 9b f7 ff ff       	call   801454 <fd2num>
  801cb9:	89 c3                	mov    %eax,%ebx
  801cbb:	eb 05                	jmp    801cc2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cbd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801cc2:	89 d8                	mov    %ebx,%eax
  801cc4:	83 c4 20             	add    $0x20,%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd6:	b8 08 00 00 00       	mov    $0x8,%eax
  801cdb:	e8 64 fd ff ff       	call   801a44 <fsipc>
}
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    
	...

00801ce4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801cea:	c7 44 24 04 c7 30 80 	movl   $0x8030c7,0x4(%esp)
  801cf1:	00 
  801cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf5:	89 04 24             	mov    %eax,(%esp)
  801cf8:	e8 de ec ff ff       	call   8009db <strcpy>
	return 0;
}
  801cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  801d02:	c9                   	leave  
  801d03:	c3                   	ret    

00801d04 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	53                   	push   %ebx
  801d08:	83 ec 14             	sub    $0x14,%esp
  801d0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d0e:	89 1c 24             	mov    %ebx,(%esp)
  801d11:	e8 8e 0b 00 00       	call   8028a4 <pageref>
  801d16:	83 f8 01             	cmp    $0x1,%eax
  801d19:	75 0d                	jne    801d28 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801d1b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 1f 03 00 00       	call   802045 <nsipc_close>
  801d26:	eb 05                	jmp    801d2d <devsock_close+0x29>
	else
		return 0;
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d2d:	83 c4 14             	add    $0x14,%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d39:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d40:	00 
  801d41:	8b 45 10             	mov    0x10(%ebp),%eax
  801d44:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d52:	8b 40 0c             	mov    0xc(%eax),%eax
  801d55:	89 04 24             	mov    %eax,(%esp)
  801d58:	e8 e3 03 00 00       	call   802140 <nsipc_send>
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d65:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d6c:	00 
  801d6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801d81:	89 04 24             	mov    %eax,(%esp)
  801d84:	e8 37 03 00 00       	call   8020c0 <nsipc_recv>
}
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	56                   	push   %esi
  801d8f:	53                   	push   %ebx
  801d90:	83 ec 20             	sub    $0x20,%esp
  801d93:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d98:	89 04 24             	mov    %eax,(%esp)
  801d9b:	e8 df f6 ff ff       	call   80147f <fd_alloc>
  801da0:	89 c3                	mov    %eax,%ebx
  801da2:	85 c0                	test   %eax,%eax
  801da4:	78 21                	js     801dc7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801da6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dad:	00 
  801dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbc:	e8 0c f0 ff ff       	call   800dcd <sys_page_alloc>
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	79 0a                	jns    801dd1 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801dc7:	89 34 24             	mov    %esi,(%esp)
  801dca:	e8 76 02 00 00       	call   802045 <nsipc_close>
		return r;
  801dcf:	eb 22                	jmp    801df3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801dd1:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dda:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801de6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801de9:	89 04 24             	mov    %eax,(%esp)
  801dec:	e8 63 f6 ff ff       	call   801454 <fd2num>
  801df1:	89 c3                	mov    %eax,%ebx
}
  801df3:	89 d8                	mov    %ebx,%eax
  801df5:	83 c4 20             	add    $0x20,%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    

00801dfc <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e02:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e05:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e09:	89 04 24             	mov    %eax,(%esp)
  801e0c:	e8 c1 f6 ff ff       	call   8014d2 <fd_lookup>
  801e11:	85 c0                	test   %eax,%eax
  801e13:	78 17                	js     801e2c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e18:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801e1e:	39 10                	cmp    %edx,(%eax)
  801e20:	75 05                	jne    801e27 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e22:	8b 40 0c             	mov    0xc(%eax),%eax
  801e25:	eb 05                	jmp    801e2c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e27:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e34:	8b 45 08             	mov    0x8(%ebp),%eax
  801e37:	e8 c0 ff ff ff       	call   801dfc <fd2sockid>
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 1f                	js     801e5f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e40:	8b 55 10             	mov    0x10(%ebp),%edx
  801e43:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e4e:	89 04 24             	mov    %eax,(%esp)
  801e51:	e8 38 01 00 00       	call   801f8e <nsipc_accept>
  801e56:	85 c0                	test   %eax,%eax
  801e58:	78 05                	js     801e5f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801e5a:	e8 2c ff ff ff       	call   801d8b <alloc_sockfd>
}
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    

00801e61 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e67:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6a:	e8 8d ff ff ff       	call   801dfc <fd2sockid>
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	78 16                	js     801e89 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801e73:	8b 55 10             	mov    0x10(%ebp),%edx
  801e76:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e81:	89 04 24             	mov    %eax,(%esp)
  801e84:	e8 5b 01 00 00       	call   801fe4 <nsipc_bind>
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <shutdown>:

int
shutdown(int s, int how)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e91:	8b 45 08             	mov    0x8(%ebp),%eax
  801e94:	e8 63 ff ff ff       	call   801dfc <fd2sockid>
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 0f                	js     801eac <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ea0:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ea4:	89 04 24             	mov    %eax,(%esp)
  801ea7:	e8 77 01 00 00       	call   802023 <nsipc_shutdown>
}
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	e8 40 ff ff ff       	call   801dfc <fd2sockid>
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 16                	js     801ed6 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801ec0:	8b 55 10             	mov    0x10(%ebp),%edx
  801ec3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ec7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eca:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ece:	89 04 24             	mov    %eax,(%esp)
  801ed1:	e8 89 01 00 00       	call   80205f <nsipc_connect>
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <listen>:

int
listen(int s, int backlog)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ede:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee1:	e8 16 ff ff ff       	call   801dfc <fd2sockid>
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	78 0f                	js     801ef9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801eea:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eed:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ef1:	89 04 24             	mov    %eax,(%esp)
  801ef4:	e8 a5 01 00 00       	call   80209e <nsipc_listen>
}
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f01:	8b 45 10             	mov    0x10(%ebp),%eax
  801f04:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f12:	89 04 24             	mov    %eax,(%esp)
  801f15:	e8 99 02 00 00       	call   8021b3 <nsipc_socket>
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	78 05                	js     801f23 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801f1e:	e8 68 fe ff ff       	call   801d8b <alloc_sockfd>
}
  801f23:	c9                   	leave  
  801f24:	c3                   	ret    
  801f25:	00 00                	add    %al,(%eax)
	...

00801f28 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	53                   	push   %ebx
  801f2c:	83 ec 14             	sub    $0x14,%esp
  801f2f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f31:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f38:	75 11                	jne    801f4b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f3a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f41:	e8 19 09 00 00       	call   80285f <ipc_find_env>
  801f46:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f4b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f52:	00 
  801f53:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801f5a:	00 
  801f5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f5f:	a1 04 50 80 00       	mov    0x805004,%eax
  801f64:	89 04 24             	mov    %eax,(%esp)
  801f67:	e8 70 08 00 00       	call   8027dc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f6c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f73:	00 
  801f74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f7b:	00 
  801f7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f83:	e8 e4 07 00 00       	call   80276c <ipc_recv>
}
  801f88:	83 c4 14             	add    $0x14,%esp
  801f8b:	5b                   	pop    %ebx
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    

00801f8e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	56                   	push   %esi
  801f92:	53                   	push   %ebx
  801f93:	83 ec 10             	sub    $0x10,%esp
  801f96:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f99:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801fa1:	8b 06                	mov    (%esi),%eax
  801fa3:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fa8:	b8 01 00 00 00       	mov    $0x1,%eax
  801fad:	e8 76 ff ff ff       	call   801f28 <nsipc>
  801fb2:	89 c3                	mov    %eax,%ebx
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	78 23                	js     801fdb <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fb8:	a1 10 70 80 00       	mov    0x807010,%eax
  801fbd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fc1:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801fc8:	00 
  801fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcc:	89 04 24             	mov    %eax,(%esp)
  801fcf:	e8 80 eb ff ff       	call   800b54 <memmove>
		*addrlen = ret->ret_addrlen;
  801fd4:	a1 10 70 80 00       	mov    0x807010,%eax
  801fd9:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801fdb:	89 d8                	mov    %ebx,%eax
  801fdd:	83 c4 10             	add    $0x10,%esp
  801fe0:	5b                   	pop    %ebx
  801fe1:	5e                   	pop    %esi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	53                   	push   %ebx
  801fe8:	83 ec 14             	sub    $0x14,%esp
  801feb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff1:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ff6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802001:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802008:	e8 47 eb ff ff       	call   800b54 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80200d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802013:	b8 02 00 00 00       	mov    $0x2,%eax
  802018:	e8 0b ff ff ff       	call   801f28 <nsipc>
}
  80201d:	83 c4 14             	add    $0x14,%esp
  802020:	5b                   	pop    %ebx
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    

00802023 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802031:	8b 45 0c             	mov    0xc(%ebp),%eax
  802034:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802039:	b8 03 00 00 00       	mov    $0x3,%eax
  80203e:	e8 e5 fe ff ff       	call   801f28 <nsipc>
}
  802043:	c9                   	leave  
  802044:	c3                   	ret    

00802045 <nsipc_close>:

int
nsipc_close(int s)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80204b:	8b 45 08             	mov    0x8(%ebp),%eax
  80204e:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802053:	b8 04 00 00 00       	mov    $0x4,%eax
  802058:	e8 cb fe ff ff       	call   801f28 <nsipc>
}
  80205d:	c9                   	leave  
  80205e:	c3                   	ret    

0080205f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	53                   	push   %ebx
  802063:	83 ec 14             	sub    $0x14,%esp
  802066:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802069:	8b 45 08             	mov    0x8(%ebp),%eax
  80206c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802071:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802075:	8b 45 0c             	mov    0xc(%ebp),%eax
  802078:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802083:	e8 cc ea ff ff       	call   800b54 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802088:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80208e:	b8 05 00 00 00       	mov    $0x5,%eax
  802093:	e8 90 fe ff ff       	call   801f28 <nsipc>
}
  802098:	83 c4 14             	add    $0x14,%esp
  80209b:	5b                   	pop    %ebx
  80209c:	5d                   	pop    %ebp
  80209d:	c3                   	ret    

0080209e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020af:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8020b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8020b9:	e8 6a fe ff ff       	call   801f28 <nsipc>
}
  8020be:	c9                   	leave  
  8020bf:	c3                   	ret    

008020c0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	56                   	push   %esi
  8020c4:	53                   	push   %ebx
  8020c5:	83 ec 10             	sub    $0x10,%esp
  8020c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ce:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8020d3:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8020d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8020dc:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8020e1:	b8 07 00 00 00       	mov    $0x7,%eax
  8020e6:	e8 3d fe ff ff       	call   801f28 <nsipc>
  8020eb:	89 c3                	mov    %eax,%ebx
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 46                	js     802137 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8020f1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8020f6:	7f 04                	jg     8020fc <nsipc_recv+0x3c>
  8020f8:	39 c6                	cmp    %eax,%esi
  8020fa:	7d 24                	jge    802120 <nsipc_recv+0x60>
  8020fc:	c7 44 24 0c d3 30 80 	movl   $0x8030d3,0xc(%esp)
  802103:	00 
  802104:	c7 44 24 08 9b 30 80 	movl   $0x80309b,0x8(%esp)
  80210b:	00 
  80210c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802113:	00 
  802114:	c7 04 24 e8 30 80 00 	movl   $0x8030e8,(%esp)
  80211b:	e8 18 e2 ff ff       	call   800338 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802120:	89 44 24 08          	mov    %eax,0x8(%esp)
  802124:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80212b:	00 
  80212c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212f:	89 04 24             	mov    %eax,(%esp)
  802132:	e8 1d ea ff ff       	call   800b54 <memmove>
	}

	return r;
}
  802137:	89 d8                	mov    %ebx,%eax
  802139:	83 c4 10             	add    $0x10,%esp
  80213c:	5b                   	pop    %ebx
  80213d:	5e                   	pop    %esi
  80213e:	5d                   	pop    %ebp
  80213f:	c3                   	ret    

00802140 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	53                   	push   %ebx
  802144:	83 ec 14             	sub    $0x14,%esp
  802147:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80214a:	8b 45 08             	mov    0x8(%ebp),%eax
  80214d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802152:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802158:	7e 24                	jle    80217e <nsipc_send+0x3e>
  80215a:	c7 44 24 0c f4 30 80 	movl   $0x8030f4,0xc(%esp)
  802161:	00 
  802162:	c7 44 24 08 9b 30 80 	movl   $0x80309b,0x8(%esp)
  802169:	00 
  80216a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802171:	00 
  802172:	c7 04 24 e8 30 80 00 	movl   $0x8030e8,(%esp)
  802179:	e8 ba e1 ff ff       	call   800338 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80217e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802182:	8b 45 0c             	mov    0xc(%ebp),%eax
  802185:	89 44 24 04          	mov    %eax,0x4(%esp)
  802189:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802190:	e8 bf e9 ff ff       	call   800b54 <memmove>
	nsipcbuf.send.req_size = size;
  802195:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80219b:	8b 45 14             	mov    0x14(%ebp),%eax
  80219e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021a3:	b8 08 00 00 00       	mov    $0x8,%eax
  8021a8:	e8 7b fd ff ff       	call   801f28 <nsipc>
}
  8021ad:	83 c4 14             	add    $0x14,%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5d                   	pop    %ebp
  8021b2:	c3                   	ret    

008021b3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8021c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c4:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8021c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8021cc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8021d1:	b8 09 00 00 00       	mov    $0x9,%eax
  8021d6:	e8 4d fd ff ff       	call   801f28 <nsipc>
}
  8021db:	c9                   	leave  
  8021dc:	c3                   	ret    
  8021dd:	00 00                	add    %al,(%eax)
	...

008021e0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	56                   	push   %esi
  8021e4:	53                   	push   %ebx
  8021e5:	83 ec 10             	sub    $0x10,%esp
  8021e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ee:	89 04 24             	mov    %eax,(%esp)
  8021f1:	e8 6e f2 ff ff       	call   801464 <fd2data>
  8021f6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8021f8:	c7 44 24 04 00 31 80 	movl   $0x803100,0x4(%esp)
  8021ff:	00 
  802200:	89 34 24             	mov    %esi,(%esp)
  802203:	e8 d3 e7 ff ff       	call   8009db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802208:	8b 43 04             	mov    0x4(%ebx),%eax
  80220b:	2b 03                	sub    (%ebx),%eax
  80220d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802213:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80221a:	00 00 00 
	stat->st_dev = &devpipe;
  80221d:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802224:	40 80 00 
	return 0;
}
  802227:	b8 00 00 00 00       	mov    $0x0,%eax
  80222c:	83 c4 10             	add    $0x10,%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    

00802233 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	53                   	push   %ebx
  802237:	83 ec 14             	sub    $0x14,%esp
  80223a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80223d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802248:	e8 27 ec ff ff       	call   800e74 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80224d:	89 1c 24             	mov    %ebx,(%esp)
  802250:	e8 0f f2 ff ff       	call   801464 <fd2data>
  802255:	89 44 24 04          	mov    %eax,0x4(%esp)
  802259:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802260:	e8 0f ec ff ff       	call   800e74 <sys_page_unmap>
}
  802265:	83 c4 14             	add    $0x14,%esp
  802268:	5b                   	pop    %ebx
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    

0080226b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80226b:	55                   	push   %ebp
  80226c:	89 e5                	mov    %esp,%ebp
  80226e:	57                   	push   %edi
  80226f:	56                   	push   %esi
  802270:	53                   	push   %ebx
  802271:	83 ec 2c             	sub    $0x2c,%esp
  802274:	89 c7                	mov    %eax,%edi
  802276:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802279:	a1 08 50 80 00       	mov    0x805008,%eax
  80227e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802281:	89 3c 24             	mov    %edi,(%esp)
  802284:	e8 1b 06 00 00       	call   8028a4 <pageref>
  802289:	89 c6                	mov    %eax,%esi
  80228b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80228e:	89 04 24             	mov    %eax,(%esp)
  802291:	e8 0e 06 00 00       	call   8028a4 <pageref>
  802296:	39 c6                	cmp    %eax,%esi
  802298:	0f 94 c0             	sete   %al
  80229b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80229e:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8022a4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022a7:	39 cb                	cmp    %ecx,%ebx
  8022a9:	75 08                	jne    8022b3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8022ab:	83 c4 2c             	add    $0x2c,%esp
  8022ae:	5b                   	pop    %ebx
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8022b3:	83 f8 01             	cmp    $0x1,%eax
  8022b6:	75 c1                	jne    802279 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022b8:	8b 42 58             	mov    0x58(%edx),%eax
  8022bb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8022c2:	00 
  8022c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022cb:	c7 04 24 07 31 80 00 	movl   $0x803107,(%esp)
  8022d2:	e8 59 e1 ff ff       	call   800430 <cprintf>
  8022d7:	eb a0                	jmp    802279 <_pipeisclosed+0xe>

008022d9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	57                   	push   %edi
  8022dd:	56                   	push   %esi
  8022de:	53                   	push   %ebx
  8022df:	83 ec 1c             	sub    $0x1c,%esp
  8022e2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022e5:	89 34 24             	mov    %esi,(%esp)
  8022e8:	e8 77 f1 ff ff       	call   801464 <fd2data>
  8022ed:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8022f4:	eb 3c                	jmp    802332 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022f6:	89 da                	mov    %ebx,%edx
  8022f8:	89 f0                	mov    %esi,%eax
  8022fa:	e8 6c ff ff ff       	call   80226b <_pipeisclosed>
  8022ff:	85 c0                	test   %eax,%eax
  802301:	75 38                	jne    80233b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802303:	e8 a6 ea ff ff       	call   800dae <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802308:	8b 43 04             	mov    0x4(%ebx),%eax
  80230b:	8b 13                	mov    (%ebx),%edx
  80230d:	83 c2 20             	add    $0x20,%edx
  802310:	39 d0                	cmp    %edx,%eax
  802312:	73 e2                	jae    8022f6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802314:	8b 55 0c             	mov    0xc(%ebp),%edx
  802317:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80231a:	89 c2                	mov    %eax,%edx
  80231c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802322:	79 05                	jns    802329 <devpipe_write+0x50>
  802324:	4a                   	dec    %edx
  802325:	83 ca e0             	or     $0xffffffe0,%edx
  802328:	42                   	inc    %edx
  802329:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80232d:	40                   	inc    %eax
  80232e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802331:	47                   	inc    %edi
  802332:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802335:	75 d1                	jne    802308 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802337:	89 f8                	mov    %edi,%eax
  802339:	eb 05                	jmp    802340 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80233b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802340:	83 c4 1c             	add    $0x1c,%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    

00802348 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802348:	55                   	push   %ebp
  802349:	89 e5                	mov    %esp,%ebp
  80234b:	57                   	push   %edi
  80234c:	56                   	push   %esi
  80234d:	53                   	push   %ebx
  80234e:	83 ec 1c             	sub    $0x1c,%esp
  802351:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802354:	89 3c 24             	mov    %edi,(%esp)
  802357:	e8 08 f1 ff ff       	call   801464 <fd2data>
  80235c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80235e:	be 00 00 00 00       	mov    $0x0,%esi
  802363:	eb 3a                	jmp    80239f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802365:	85 f6                	test   %esi,%esi
  802367:	74 04                	je     80236d <devpipe_read+0x25>
				return i;
  802369:	89 f0                	mov    %esi,%eax
  80236b:	eb 40                	jmp    8023ad <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80236d:	89 da                	mov    %ebx,%edx
  80236f:	89 f8                	mov    %edi,%eax
  802371:	e8 f5 fe ff ff       	call   80226b <_pipeisclosed>
  802376:	85 c0                	test   %eax,%eax
  802378:	75 2e                	jne    8023a8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80237a:	e8 2f ea ff ff       	call   800dae <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80237f:	8b 03                	mov    (%ebx),%eax
  802381:	3b 43 04             	cmp    0x4(%ebx),%eax
  802384:	74 df                	je     802365 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802386:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80238b:	79 05                	jns    802392 <devpipe_read+0x4a>
  80238d:	48                   	dec    %eax
  80238e:	83 c8 e0             	or     $0xffffffe0,%eax
  802391:	40                   	inc    %eax
  802392:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802396:	8b 55 0c             	mov    0xc(%ebp),%edx
  802399:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80239c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80239e:	46                   	inc    %esi
  80239f:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023a2:	75 db                	jne    80237f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023a4:	89 f0                	mov    %esi,%eax
  8023a6:	eb 05                	jmp    8023ad <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023a8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023ad:	83 c4 1c             	add    $0x1c,%esp
  8023b0:	5b                   	pop    %ebx
  8023b1:	5e                   	pop    %esi
  8023b2:	5f                   	pop    %edi
  8023b3:	5d                   	pop    %ebp
  8023b4:	c3                   	ret    

008023b5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023b5:	55                   	push   %ebp
  8023b6:	89 e5                	mov    %esp,%ebp
  8023b8:	57                   	push   %edi
  8023b9:	56                   	push   %esi
  8023ba:	53                   	push   %ebx
  8023bb:	83 ec 3c             	sub    $0x3c,%esp
  8023be:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023c1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8023c4:	89 04 24             	mov    %eax,(%esp)
  8023c7:	e8 b3 f0 ff ff       	call   80147f <fd_alloc>
  8023cc:	89 c3                	mov    %eax,%ebx
  8023ce:	85 c0                	test   %eax,%eax
  8023d0:	0f 88 45 01 00 00    	js     80251b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023d6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023dd:	00 
  8023de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ec:	e8 dc e9 ff ff       	call   800dcd <sys_page_alloc>
  8023f1:	89 c3                	mov    %eax,%ebx
  8023f3:	85 c0                	test   %eax,%eax
  8023f5:	0f 88 20 01 00 00    	js     80251b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023fb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8023fe:	89 04 24             	mov    %eax,(%esp)
  802401:	e8 79 f0 ff ff       	call   80147f <fd_alloc>
  802406:	89 c3                	mov    %eax,%ebx
  802408:	85 c0                	test   %eax,%eax
  80240a:	0f 88 f8 00 00 00    	js     802508 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802410:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802417:	00 
  802418:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80241b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80241f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802426:	e8 a2 e9 ff ff       	call   800dcd <sys_page_alloc>
  80242b:	89 c3                	mov    %eax,%ebx
  80242d:	85 c0                	test   %eax,%eax
  80242f:	0f 88 d3 00 00 00    	js     802508 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802435:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802438:	89 04 24             	mov    %eax,(%esp)
  80243b:	e8 24 f0 ff ff       	call   801464 <fd2data>
  802440:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802442:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802449:	00 
  80244a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802455:	e8 73 e9 ff ff       	call   800dcd <sys_page_alloc>
  80245a:	89 c3                	mov    %eax,%ebx
  80245c:	85 c0                	test   %eax,%eax
  80245e:	0f 88 91 00 00 00    	js     8024f5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802464:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802467:	89 04 24             	mov    %eax,(%esp)
  80246a:	e8 f5 ef ff ff       	call   801464 <fd2data>
  80246f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802476:	00 
  802477:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80247b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802482:	00 
  802483:	89 74 24 04          	mov    %esi,0x4(%esp)
  802487:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80248e:	e8 8e e9 ff ff       	call   800e21 <sys_page_map>
  802493:	89 c3                	mov    %eax,%ebx
  802495:	85 c0                	test   %eax,%eax
  802497:	78 4c                	js     8024e5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802499:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80249f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024a2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024a7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024ae:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024b7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024c6:	89 04 24             	mov    %eax,(%esp)
  8024c9:	e8 86 ef ff ff       	call   801454 <fd2num>
  8024ce:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8024d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024d3:	89 04 24             	mov    %eax,(%esp)
  8024d6:	e8 79 ef ff ff       	call   801454 <fd2num>
  8024db:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8024de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024e3:	eb 36                	jmp    80251b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8024e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f0:	e8 7f e9 ff ff       	call   800e74 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8024f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802503:	e8 6c e9 ff ff       	call   800e74 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802508:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80250b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80250f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802516:	e8 59 e9 ff ff       	call   800e74 <sys_page_unmap>
    err:
	return r;
}
  80251b:	89 d8                	mov    %ebx,%eax
  80251d:	83 c4 3c             	add    $0x3c,%esp
  802520:	5b                   	pop    %ebx
  802521:	5e                   	pop    %esi
  802522:	5f                   	pop    %edi
  802523:	5d                   	pop    %ebp
  802524:	c3                   	ret    

00802525 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80252b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80252e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802532:	8b 45 08             	mov    0x8(%ebp),%eax
  802535:	89 04 24             	mov    %eax,(%esp)
  802538:	e8 95 ef ff ff       	call   8014d2 <fd_lookup>
  80253d:	85 c0                	test   %eax,%eax
  80253f:	78 15                	js     802556 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802541:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802544:	89 04 24             	mov    %eax,(%esp)
  802547:	e8 18 ef ff ff       	call   801464 <fd2data>
	return _pipeisclosed(fd, p);
  80254c:	89 c2                	mov    %eax,%edx
  80254e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802551:	e8 15 fd ff ff       	call   80226b <_pipeisclosed>
}
  802556:	c9                   	leave  
  802557:	c3                   	ret    

00802558 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802558:	55                   	push   %ebp
  802559:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80255b:	b8 00 00 00 00       	mov    $0x0,%eax
  802560:	5d                   	pop    %ebp
  802561:	c3                   	ret    

00802562 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802562:	55                   	push   %ebp
  802563:	89 e5                	mov    %esp,%ebp
  802565:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802568:	c7 44 24 04 1a 31 80 	movl   $0x80311a,0x4(%esp)
  80256f:	00 
  802570:	8b 45 0c             	mov    0xc(%ebp),%eax
  802573:	89 04 24             	mov    %eax,(%esp)
  802576:	e8 60 e4 ff ff       	call   8009db <strcpy>
	return 0;
}
  80257b:	b8 00 00 00 00       	mov    $0x0,%eax
  802580:	c9                   	leave  
  802581:	c3                   	ret    

00802582 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802582:	55                   	push   %ebp
  802583:	89 e5                	mov    %esp,%ebp
  802585:	57                   	push   %edi
  802586:	56                   	push   %esi
  802587:	53                   	push   %ebx
  802588:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80258e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802593:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802599:	eb 30                	jmp    8025cb <devcons_write+0x49>
		m = n - tot;
  80259b:	8b 75 10             	mov    0x10(%ebp),%esi
  80259e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8025a0:	83 fe 7f             	cmp    $0x7f,%esi
  8025a3:	76 05                	jbe    8025aa <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8025a5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8025aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025ae:	03 45 0c             	add    0xc(%ebp),%eax
  8025b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b5:	89 3c 24             	mov    %edi,(%esp)
  8025b8:	e8 97 e5 ff ff       	call   800b54 <memmove>
		sys_cputs(buf, m);
  8025bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025c1:	89 3c 24             	mov    %edi,(%esp)
  8025c4:	e8 37 e7 ff ff       	call   800d00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025c9:	01 f3                	add    %esi,%ebx
  8025cb:	89 d8                	mov    %ebx,%eax
  8025cd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025d0:	72 c9                	jb     80259b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025d2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8025d8:	5b                   	pop    %ebx
  8025d9:	5e                   	pop    %esi
  8025da:	5f                   	pop    %edi
  8025db:	5d                   	pop    %ebp
  8025dc:	c3                   	ret    

008025dd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025dd:	55                   	push   %ebp
  8025de:	89 e5                	mov    %esp,%ebp
  8025e0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8025e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025e7:	75 07                	jne    8025f0 <devcons_read+0x13>
  8025e9:	eb 25                	jmp    802610 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025eb:	e8 be e7 ff ff       	call   800dae <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025f0:	e8 29 e7 ff ff       	call   800d1e <sys_cgetc>
  8025f5:	85 c0                	test   %eax,%eax
  8025f7:	74 f2                	je     8025eb <devcons_read+0xe>
  8025f9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	78 1d                	js     80261c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025ff:	83 f8 04             	cmp    $0x4,%eax
  802602:	74 13                	je     802617 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802604:	8b 45 0c             	mov    0xc(%ebp),%eax
  802607:	88 10                	mov    %dl,(%eax)
	return 1;
  802609:	b8 01 00 00 00       	mov    $0x1,%eax
  80260e:	eb 0c                	jmp    80261c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802610:	b8 00 00 00 00       	mov    $0x0,%eax
  802615:	eb 05                	jmp    80261c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802617:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80261c:	c9                   	leave  
  80261d:	c3                   	ret    

0080261e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80261e:	55                   	push   %ebp
  80261f:	89 e5                	mov    %esp,%ebp
  802621:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802624:	8b 45 08             	mov    0x8(%ebp),%eax
  802627:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80262a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802631:	00 
  802632:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802635:	89 04 24             	mov    %eax,(%esp)
  802638:	e8 c3 e6 ff ff       	call   800d00 <sys_cputs>
}
  80263d:	c9                   	leave  
  80263e:	c3                   	ret    

0080263f <getchar>:

int
getchar(void)
{
  80263f:	55                   	push   %ebp
  802640:	89 e5                	mov    %esp,%ebp
  802642:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802645:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80264c:	00 
  80264d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802650:	89 44 24 04          	mov    %eax,0x4(%esp)
  802654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80265b:	e8 10 f1 ff ff       	call   801770 <read>
	if (r < 0)
  802660:	85 c0                	test   %eax,%eax
  802662:	78 0f                	js     802673 <getchar+0x34>
		return r;
	if (r < 1)
  802664:	85 c0                	test   %eax,%eax
  802666:	7e 06                	jle    80266e <getchar+0x2f>
		return -E_EOF;
	return c;
  802668:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80266c:	eb 05                	jmp    802673 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80266e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802673:	c9                   	leave  
  802674:	c3                   	ret    

00802675 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802675:	55                   	push   %ebp
  802676:	89 e5                	mov    %esp,%ebp
  802678:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80267b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80267e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802682:	8b 45 08             	mov    0x8(%ebp),%eax
  802685:	89 04 24             	mov    %eax,(%esp)
  802688:	e8 45 ee ff ff       	call   8014d2 <fd_lookup>
  80268d:	85 c0                	test   %eax,%eax
  80268f:	78 11                	js     8026a2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802691:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802694:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80269a:	39 10                	cmp    %edx,(%eax)
  80269c:	0f 94 c0             	sete   %al
  80269f:	0f b6 c0             	movzbl %al,%eax
}
  8026a2:	c9                   	leave  
  8026a3:	c3                   	ret    

008026a4 <opencons>:

int
opencons(void)
{
  8026a4:	55                   	push   %ebp
  8026a5:	89 e5                	mov    %esp,%ebp
  8026a7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026ad:	89 04 24             	mov    %eax,(%esp)
  8026b0:	e8 ca ed ff ff       	call   80147f <fd_alloc>
  8026b5:	85 c0                	test   %eax,%eax
  8026b7:	78 3c                	js     8026f5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026b9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026c0:	00 
  8026c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026cf:	e8 f9 e6 ff ff       	call   800dcd <sys_page_alloc>
  8026d4:	85 c0                	test   %eax,%eax
  8026d6:	78 1d                	js     8026f5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026d8:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8026de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026ed:	89 04 24             	mov    %eax,(%esp)
  8026f0:	e8 5f ed ff ff       	call   801454 <fd2num>
}
  8026f5:	c9                   	leave  
  8026f6:	c3                   	ret    
	...

008026f8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026f8:	55                   	push   %ebp
  8026f9:	89 e5                	mov    %esp,%ebp
  8026fb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026fe:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802705:	75 30                	jne    802737 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  802707:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80270e:	00 
  80270f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802716:	ee 
  802717:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80271e:	e8 aa e6 ff ff       	call   800dcd <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802723:	c7 44 24 04 44 27 80 	movl   $0x802744,0x4(%esp)
  80272a:	00 
  80272b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802732:	e8 36 e8 ff ff       	call   800f6d <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802737:	8b 45 08             	mov    0x8(%ebp),%eax
  80273a:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80273f:	c9                   	leave  
  802740:	c3                   	ret    
  802741:	00 00                	add    %al,(%eax)
	...

00802744 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802744:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802745:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80274a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80274c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  80274f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802753:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802757:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  80275a:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  80275c:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802760:	83 c4 08             	add    $0x8,%esp
	popal
  802763:	61                   	popa   

	addl $4,%esp 
  802764:	83 c4 04             	add    $0x4,%esp
	popfl
  802767:	9d                   	popf   

	popl %esp
  802768:	5c                   	pop    %esp

	ret
  802769:	c3                   	ret    
	...

0080276c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80276c:	55                   	push   %ebp
  80276d:	89 e5                	mov    %esp,%ebp
  80276f:	56                   	push   %esi
  802770:	53                   	push   %ebx
  802771:	83 ec 10             	sub    $0x10,%esp
  802774:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802777:	8b 45 0c             	mov    0xc(%ebp),%eax
  80277a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  80277d:	85 c0                	test   %eax,%eax
  80277f:	74 0a                	je     80278b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802781:	89 04 24             	mov    %eax,(%esp)
  802784:	e8 5a e8 ff ff       	call   800fe3 <sys_ipc_recv>
  802789:	eb 0c                	jmp    802797 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80278b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802792:	e8 4c e8 ff ff       	call   800fe3 <sys_ipc_recv>
	}
	if (r < 0)
  802797:	85 c0                	test   %eax,%eax
  802799:	79 16                	jns    8027b1 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80279b:	85 db                	test   %ebx,%ebx
  80279d:	74 06                	je     8027a5 <ipc_recv+0x39>
  80279f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8027a5:	85 f6                	test   %esi,%esi
  8027a7:	74 2c                	je     8027d5 <ipc_recv+0x69>
  8027a9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8027af:	eb 24                	jmp    8027d5 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8027b1:	85 db                	test   %ebx,%ebx
  8027b3:	74 0a                	je     8027bf <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8027b5:	a1 08 50 80 00       	mov    0x805008,%eax
  8027ba:	8b 40 74             	mov    0x74(%eax),%eax
  8027bd:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8027bf:	85 f6                	test   %esi,%esi
  8027c1:	74 0a                	je     8027cd <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8027c3:	a1 08 50 80 00       	mov    0x805008,%eax
  8027c8:	8b 40 78             	mov    0x78(%eax),%eax
  8027cb:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8027cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8027d2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8027d5:	83 c4 10             	add    $0x10,%esp
  8027d8:	5b                   	pop    %ebx
  8027d9:	5e                   	pop    %esi
  8027da:	5d                   	pop    %ebp
  8027db:	c3                   	ret    

008027dc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027dc:	55                   	push   %ebp
  8027dd:	89 e5                	mov    %esp,%ebp
  8027df:	57                   	push   %edi
  8027e0:	56                   	push   %esi
  8027e1:	53                   	push   %ebx
  8027e2:	83 ec 1c             	sub    $0x1c,%esp
  8027e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8027e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8027ee:	85 db                	test   %ebx,%ebx
  8027f0:	74 19                	je     80280b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8027f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8027f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802801:	89 34 24             	mov    %esi,(%esp)
  802804:	e8 b7 e7 ff ff       	call   800fc0 <sys_ipc_try_send>
  802809:	eb 1c                	jmp    802827 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80280b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802812:	00 
  802813:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80281a:	ee 
  80281b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80281f:	89 34 24             	mov    %esi,(%esp)
  802822:	e8 99 e7 ff ff       	call   800fc0 <sys_ipc_try_send>
		}
		if (r == 0)
  802827:	85 c0                	test   %eax,%eax
  802829:	74 2c                	je     802857 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80282b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80282e:	74 20                	je     802850 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802830:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802834:	c7 44 24 08 26 31 80 	movl   $0x803126,0x8(%esp)
  80283b:	00 
  80283c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802843:	00 
  802844:	c7 04 24 39 31 80 00 	movl   $0x803139,(%esp)
  80284b:	e8 e8 da ff ff       	call   800338 <_panic>
		}
		sys_yield();
  802850:	e8 59 e5 ff ff       	call   800dae <sys_yield>
	}
  802855:	eb 97                	jmp    8027ee <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802857:	83 c4 1c             	add    $0x1c,%esp
  80285a:	5b                   	pop    %ebx
  80285b:	5e                   	pop    %esi
  80285c:	5f                   	pop    %edi
  80285d:	5d                   	pop    %ebp
  80285e:	c3                   	ret    

0080285f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80285f:	55                   	push   %ebp
  802860:	89 e5                	mov    %esp,%ebp
  802862:	53                   	push   %ebx
  802863:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802866:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80286b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802872:	89 c2                	mov    %eax,%edx
  802874:	c1 e2 07             	shl    $0x7,%edx
  802877:	29 ca                	sub    %ecx,%edx
  802879:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80287f:	8b 52 50             	mov    0x50(%edx),%edx
  802882:	39 da                	cmp    %ebx,%edx
  802884:	75 0f                	jne    802895 <ipc_find_env+0x36>
			return envs[i].env_id;
  802886:	c1 e0 07             	shl    $0x7,%eax
  802889:	29 c8                	sub    %ecx,%eax
  80288b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802890:	8b 40 40             	mov    0x40(%eax),%eax
  802893:	eb 0c                	jmp    8028a1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802895:	40                   	inc    %eax
  802896:	3d 00 04 00 00       	cmp    $0x400,%eax
  80289b:	75 ce                	jne    80286b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80289d:	66 b8 00 00          	mov    $0x0,%ax
}
  8028a1:	5b                   	pop    %ebx
  8028a2:	5d                   	pop    %ebp
  8028a3:	c3                   	ret    

008028a4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028a4:	55                   	push   %ebp
  8028a5:	89 e5                	mov    %esp,%ebp
  8028a7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028aa:	89 c2                	mov    %eax,%edx
  8028ac:	c1 ea 16             	shr    $0x16,%edx
  8028af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028b6:	f6 c2 01             	test   $0x1,%dl
  8028b9:	74 1e                	je     8028d9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028bb:	c1 e8 0c             	shr    $0xc,%eax
  8028be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8028c5:	a8 01                	test   $0x1,%al
  8028c7:	74 17                	je     8028e0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028c9:	c1 e8 0c             	shr    $0xc,%eax
  8028cc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8028d3:	ef 
  8028d4:	0f b7 c0             	movzwl %ax,%eax
  8028d7:	eb 0c                	jmp    8028e5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8028d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8028de:	eb 05                	jmp    8028e5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8028e0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8028e5:	5d                   	pop    %ebp
  8028e6:	c3                   	ret    
	...

008028e8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8028e8:	55                   	push   %ebp
  8028e9:	57                   	push   %edi
  8028ea:	56                   	push   %esi
  8028eb:	83 ec 10             	sub    $0x10,%esp
  8028ee:	8b 74 24 20          	mov    0x20(%esp),%esi
  8028f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8028f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028fa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8028fe:	89 cd                	mov    %ecx,%ebp
  802900:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802904:	85 c0                	test   %eax,%eax
  802906:	75 2c                	jne    802934 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802908:	39 f9                	cmp    %edi,%ecx
  80290a:	77 68                	ja     802974 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80290c:	85 c9                	test   %ecx,%ecx
  80290e:	75 0b                	jne    80291b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802910:	b8 01 00 00 00       	mov    $0x1,%eax
  802915:	31 d2                	xor    %edx,%edx
  802917:	f7 f1                	div    %ecx
  802919:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80291b:	31 d2                	xor    %edx,%edx
  80291d:	89 f8                	mov    %edi,%eax
  80291f:	f7 f1                	div    %ecx
  802921:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802923:	89 f0                	mov    %esi,%eax
  802925:	f7 f1                	div    %ecx
  802927:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802929:	89 f0                	mov    %esi,%eax
  80292b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80292d:	83 c4 10             	add    $0x10,%esp
  802930:	5e                   	pop    %esi
  802931:	5f                   	pop    %edi
  802932:	5d                   	pop    %ebp
  802933:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802934:	39 f8                	cmp    %edi,%eax
  802936:	77 2c                	ja     802964 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802938:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80293b:	83 f6 1f             	xor    $0x1f,%esi
  80293e:	75 4c                	jne    80298c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802940:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802942:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802947:	72 0a                	jb     802953 <__udivdi3+0x6b>
  802949:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80294d:	0f 87 ad 00 00 00    	ja     802a00 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802953:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802958:	89 f0                	mov    %esi,%eax
  80295a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80295c:	83 c4 10             	add    $0x10,%esp
  80295f:	5e                   	pop    %esi
  802960:	5f                   	pop    %edi
  802961:	5d                   	pop    %ebp
  802962:	c3                   	ret    
  802963:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802964:	31 ff                	xor    %edi,%edi
  802966:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802968:	89 f0                	mov    %esi,%eax
  80296a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80296c:	83 c4 10             	add    $0x10,%esp
  80296f:	5e                   	pop    %esi
  802970:	5f                   	pop    %edi
  802971:	5d                   	pop    %ebp
  802972:	c3                   	ret    
  802973:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802974:	89 fa                	mov    %edi,%edx
  802976:	89 f0                	mov    %esi,%eax
  802978:	f7 f1                	div    %ecx
  80297a:	89 c6                	mov    %eax,%esi
  80297c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80297e:	89 f0                	mov    %esi,%eax
  802980:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802982:	83 c4 10             	add    $0x10,%esp
  802985:	5e                   	pop    %esi
  802986:	5f                   	pop    %edi
  802987:	5d                   	pop    %ebp
  802988:	c3                   	ret    
  802989:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80298c:	89 f1                	mov    %esi,%ecx
  80298e:	d3 e0                	shl    %cl,%eax
  802990:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802994:	b8 20 00 00 00       	mov    $0x20,%eax
  802999:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80299b:	89 ea                	mov    %ebp,%edx
  80299d:	88 c1                	mov    %al,%cl
  80299f:	d3 ea                	shr    %cl,%edx
  8029a1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8029a5:	09 ca                	or     %ecx,%edx
  8029a7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8029ab:	89 f1                	mov    %esi,%ecx
  8029ad:	d3 e5                	shl    %cl,%ebp
  8029af:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8029b3:	89 fd                	mov    %edi,%ebp
  8029b5:	88 c1                	mov    %al,%cl
  8029b7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8029b9:	89 fa                	mov    %edi,%edx
  8029bb:	89 f1                	mov    %esi,%ecx
  8029bd:	d3 e2                	shl    %cl,%edx
  8029bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029c3:	88 c1                	mov    %al,%cl
  8029c5:	d3 ef                	shr    %cl,%edi
  8029c7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029c9:	89 f8                	mov    %edi,%eax
  8029cb:	89 ea                	mov    %ebp,%edx
  8029cd:	f7 74 24 08          	divl   0x8(%esp)
  8029d1:	89 d1                	mov    %edx,%ecx
  8029d3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8029d5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029d9:	39 d1                	cmp    %edx,%ecx
  8029db:	72 17                	jb     8029f4 <__udivdi3+0x10c>
  8029dd:	74 09                	je     8029e8 <__udivdi3+0x100>
  8029df:	89 fe                	mov    %edi,%esi
  8029e1:	31 ff                	xor    %edi,%edi
  8029e3:	e9 41 ff ff ff       	jmp    802929 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8029e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029ec:	89 f1                	mov    %esi,%ecx
  8029ee:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029f0:	39 c2                	cmp    %eax,%edx
  8029f2:	73 eb                	jae    8029df <__udivdi3+0xf7>
		{
		  q0--;
  8029f4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8029f7:	31 ff                	xor    %edi,%edi
  8029f9:	e9 2b ff ff ff       	jmp    802929 <__udivdi3+0x41>
  8029fe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a00:	31 f6                	xor    %esi,%esi
  802a02:	e9 22 ff ff ff       	jmp    802929 <__udivdi3+0x41>
	...

00802a08 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802a08:	55                   	push   %ebp
  802a09:	57                   	push   %edi
  802a0a:	56                   	push   %esi
  802a0b:	83 ec 20             	sub    $0x20,%esp
  802a0e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a12:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a16:	89 44 24 14          	mov    %eax,0x14(%esp)
  802a1a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802a1e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a22:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802a26:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802a28:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802a2a:	85 ed                	test   %ebp,%ebp
  802a2c:	75 16                	jne    802a44 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802a2e:	39 f1                	cmp    %esi,%ecx
  802a30:	0f 86 a6 00 00 00    	jbe    802adc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a36:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802a38:	89 d0                	mov    %edx,%eax
  802a3a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a3c:	83 c4 20             	add    $0x20,%esp
  802a3f:	5e                   	pop    %esi
  802a40:	5f                   	pop    %edi
  802a41:	5d                   	pop    %ebp
  802a42:	c3                   	ret    
  802a43:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a44:	39 f5                	cmp    %esi,%ebp
  802a46:	0f 87 ac 00 00 00    	ja     802af8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a4c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802a4f:	83 f0 1f             	xor    $0x1f,%eax
  802a52:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a56:	0f 84 a8 00 00 00    	je     802b04 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a5c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a60:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a62:	bf 20 00 00 00       	mov    $0x20,%edi
  802a67:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802a6b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a6f:	89 f9                	mov    %edi,%ecx
  802a71:	d3 e8                	shr    %cl,%eax
  802a73:	09 e8                	or     %ebp,%eax
  802a75:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802a79:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a7d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a81:	d3 e0                	shl    %cl,%eax
  802a83:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a87:	89 f2                	mov    %esi,%edx
  802a89:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802a8b:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a8f:	d3 e0                	shl    %cl,%eax
  802a91:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a95:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a99:	89 f9                	mov    %edi,%ecx
  802a9b:	d3 e8                	shr    %cl,%eax
  802a9d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802a9f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802aa1:	89 f2                	mov    %esi,%edx
  802aa3:	f7 74 24 18          	divl   0x18(%esp)
  802aa7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802aa9:	f7 64 24 0c          	mull   0xc(%esp)
  802aad:	89 c5                	mov    %eax,%ebp
  802aaf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ab1:	39 d6                	cmp    %edx,%esi
  802ab3:	72 67                	jb     802b1c <__umoddi3+0x114>
  802ab5:	74 75                	je     802b2c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802ab7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802abb:	29 e8                	sub    %ebp,%eax
  802abd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802abf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ac3:	d3 e8                	shr    %cl,%eax
  802ac5:	89 f2                	mov    %esi,%edx
  802ac7:	89 f9                	mov    %edi,%ecx
  802ac9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802acb:	09 d0                	or     %edx,%eax
  802acd:	89 f2                	mov    %esi,%edx
  802acf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ad3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ad5:	83 c4 20             	add    $0x20,%esp
  802ad8:	5e                   	pop    %esi
  802ad9:	5f                   	pop    %edi
  802ada:	5d                   	pop    %ebp
  802adb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802adc:	85 c9                	test   %ecx,%ecx
  802ade:	75 0b                	jne    802aeb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802ae0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ae5:	31 d2                	xor    %edx,%edx
  802ae7:	f7 f1                	div    %ecx
  802ae9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802aeb:	89 f0                	mov    %esi,%eax
  802aed:	31 d2                	xor    %edx,%edx
  802aef:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802af1:	89 f8                	mov    %edi,%eax
  802af3:	e9 3e ff ff ff       	jmp    802a36 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802af8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802afa:	83 c4 20             	add    $0x20,%esp
  802afd:	5e                   	pop    %esi
  802afe:	5f                   	pop    %edi
  802aff:	5d                   	pop    %ebp
  802b00:	c3                   	ret    
  802b01:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b04:	39 f5                	cmp    %esi,%ebp
  802b06:	72 04                	jb     802b0c <__umoddi3+0x104>
  802b08:	39 f9                	cmp    %edi,%ecx
  802b0a:	77 06                	ja     802b12 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b0c:	89 f2                	mov    %esi,%edx
  802b0e:	29 cf                	sub    %ecx,%edi
  802b10:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b12:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b14:	83 c4 20             	add    $0x20,%esp
  802b17:	5e                   	pop    %esi
  802b18:	5f                   	pop    %edi
  802b19:	5d                   	pop    %ebp
  802b1a:	c3                   	ret    
  802b1b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802b1c:	89 d1                	mov    %edx,%ecx
  802b1e:	89 c5                	mov    %eax,%ebp
  802b20:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802b24:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802b28:	eb 8d                	jmp    802ab7 <__umoddi3+0xaf>
  802b2a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b2c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802b30:	72 ea                	jb     802b1c <__umoddi3+0x114>
  802b32:	89 f1                	mov    %esi,%ecx
  802b34:	eb 81                	jmp    802ab7 <__umoddi3+0xaf>
