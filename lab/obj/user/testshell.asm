
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 03 05 00 00       	call   800534 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
  800046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004d:	89 3c 24             	mov    %edi,(%esp)
  800050:	e8 ed 1a 00 00       	call   801b42 <seek>
	seek(kfd, off);
  800055:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800059:	89 34 24             	mov    %esi,(%esp)
  80005c:	e8 e1 1a 00 00       	call   801b42 <seek>

	cprintf("shell produced incorrect output.\n");
  800061:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  800068:	e8 2f 06 00 00       	call   80069c <cprintf>
	cprintf("expected:\n===\n");
  80006d:	c7 04 24 4b 33 80 00 	movl   $0x80334b,(%esp)
  800074:	e8 23 06 00 00       	call   80069c <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800079:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007c:	eb 0c                	jmp    80008a <wrong+0x56>
		sys_cputs(buf, n);
  80007e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800082:	89 1c 24             	mov    %ebx,(%esp)
  800085:	e8 e2 0e 00 00       	call   800f6c <sys_cputs>
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  80008a:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 3e 19 00 00       	call   8019dc <read>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	7f dc                	jg     80007e <wrong+0x4a>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  8000a2:	c7 04 24 5a 33 80 00 	movl   $0x80335a,(%esp)
  8000a9:	e8 ee 05 00 00       	call   80069c <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ae:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b1:	eb 0c                	jmp    8000bf <wrong+0x8b>
		sys_cputs(buf, n);
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	89 1c 24             	mov    %ebx,(%esp)
  8000ba:	e8 ad 0e 00 00       	call   800f6c <sys_cputs>
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bf:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000c6:	00 
  8000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cb:	89 3c 24             	mov    %edi,(%esp)
  8000ce:	e8 09 19 00 00       	call   8019dc <read>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7f dc                	jg     8000b3 <wrong+0x7f>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000d7:	c7 04 24 55 33 80 00 	movl   $0x803355,(%esp)
  8000de:	e8 b9 05 00 00       	call   80069c <cprintf>
	exit();
  8000e3:	e8 a0 04 00 00       	call   800588 <exit>
}
  8000e8:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 3c             	sub    $0x3c,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800103:	e8 6e 17 00 00       	call   801876 <close>
	close(1);
  800108:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010f:	e8 62 17 00 00       	call   801876 <close>
	opencons();
  800114:	e8 c7 03 00 00       	call   8004e0 <opencons>
	opencons();
  800119:	e8 c2 03 00 00       	call   8004e0 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 68 33 80 00 	movl   $0x803368,(%esp)
  80012d:	e8 7d 1d 00 00       	call   801eaf <open>
  800132:	89 c3                	mov    %eax,%ebx
  800134:	85 c0                	test   %eax,%eax
  800136:	79 20                	jns    800158 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013c:	c7 44 24 08 75 33 80 	movl   $0x803375,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 8b 33 80 00 	movl   $0x80338b,(%esp)
  800153:	e8 4c 04 00 00       	call   8005a4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800158:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 2e 2b 00 00       	call   802c91 <pipe>
  800163:	85 c0                	test   %eax,%eax
  800165:	79 20                	jns    800187 <umain+0x94>
		panic("pipe: %e", wfd);
  800167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016b:	c7 44 24 08 9c 33 80 	movl   $0x80339c,0x8(%esp)
  800172:	00 
  800173:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80017a:	00 
  80017b:	c7 04 24 8b 33 80 00 	movl   $0x80338b,(%esp)
  800182:	e8 1d 04 00 00       	call   8005a4 <_panic>
	wfd = pfds[1];
  800187:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  80018a:	c7 04 24 04 33 80 00 	movl   $0x803304,(%esp)
  800191:	e8 06 05 00 00       	call   80069c <cprintf>
	if ((r = fork()) < 0)
  800196:	e8 40 12 00 00       	call   8013db <fork>
  80019b:	85 c0                	test   %eax,%eax
  80019d:	79 20                	jns    8001bf <umain+0xcc>
		panic("fork: %e", r);
  80019f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a3:	c7 44 24 08 c5 37 80 	movl   $0x8037c5,0x8(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b2:	00 
  8001b3:	c7 04 24 8b 33 80 00 	movl   $0x80338b,(%esp)
  8001ba:	e8 e5 03 00 00       	call   8005a4 <_panic>
	if (r == 0) {
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	0f 85 9f 00 00 00    	jne    800266 <umain+0x173>
		dup(rfd, 0);
  8001c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ce:	00 
  8001cf:	89 1c 24             	mov    %ebx,(%esp)
  8001d2:	e8 f0 16 00 00       	call   8018c7 <dup>
		dup(wfd, 1);
  8001d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001de:	00 
  8001df:	89 34 24             	mov    %esi,(%esp)
  8001e2:	e8 e0 16 00 00       	call   8018c7 <dup>
		close(rfd);
  8001e7:	89 1c 24             	mov    %ebx,(%esp)
  8001ea:	e8 87 16 00 00       	call   801876 <close>
		close(wfd);
  8001ef:	89 34 24             	mov    %esi,(%esp)
  8001f2:	e8 7f 16 00 00       	call   801876 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fe:	00 
  8001ff:	c7 44 24 08 a5 33 80 	movl   $0x8033a5,0x8(%esp)
  800206:	00 
  800207:	c7 44 24 04 72 33 80 	movl   $0x803372,0x4(%esp)
  80020e:	00 
  80020f:	c7 04 24 a8 33 80 00 	movl   $0x8033a8,(%esp)
  800216:	e8 35 23 00 00       	call   802550 <spawnl>
  80021b:	89 c7                	mov    %eax,%edi
  80021d:	85 c0                	test   %eax,%eax
  80021f:	79 20                	jns    800241 <umain+0x14e>
			panic("spawn: %e", r);
  800221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800225:	c7 44 24 08 ac 33 80 	movl   $0x8033ac,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 8b 33 80 00 	movl   $0x80338b,(%esp)
  80023c:	e8 63 03 00 00       	call   8005a4 <_panic>
		close(0);
  800241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800248:	e8 29 16 00 00       	call   801876 <close>
		close(1);
  80024d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800254:	e8 1d 16 00 00       	call   801876 <close>
		wait(r);
  800259:	89 3c 24             	mov    %edi,(%esp)
  80025c:	e8 d3 2b 00 00       	call   802e34 <wait>
		exit();
  800261:	e8 22 03 00 00       	call   800588 <exit>
	}
	close(rfd);
  800266:	89 1c 24             	mov    %ebx,(%esp)
  800269:	e8 08 16 00 00       	call   801876 <close>
	close(wfd);
  80026e:	89 34 24             	mov    %esi,(%esp)
  800271:	e8 00 16 00 00       	call   801876 <close>

	rfd = pfds[0];
  800276:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800279:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 b6 33 80 00 	movl   $0x8033b6,(%esp)
  800288:	e8 22 1c 00 00       	call   801eaf <open>
  80028d:	89 c6                	mov    %eax,%esi
  80028f:	85 c0                	test   %eax,%eax
  800291:	79 20                	jns    8002b3 <umain+0x1c0>
		panic("open testshell.key for reading: %e", kfd);
  800293:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800297:	c7 44 24 08 28 33 80 	movl   $0x803328,0x8(%esp)
  80029e:	00 
  80029f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002a6:	00 
  8002a7:	c7 04 24 8b 33 80 00 	movl   $0x80338b,(%esp)
  8002ae:	e8 f1 02 00 00       	call   8005a4 <_panic>
	}
	close(rfd);
	close(wfd);

	rfd = pfds[0];
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8002b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  8002ba:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		panic("open testshell.key for reading: %e", kfd);

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  8002c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c8:	00 
  8002c9:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	89 3c 24             	mov    %edi,(%esp)
  8002d3:	e8 04 17 00 00       	call   8019dc <read>
  8002d8:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e1:	00 
  8002e2:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	e8 eb 16 00 00       	call   8019dc <read>
		if (n1 < 0)
  8002f1:	85 db                	test   %ebx,%ebx
  8002f3:	79 20                	jns    800315 <umain+0x222>
			panic("reading testshell.out: %e", n1);
  8002f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f9:	c7 44 24 08 c4 33 80 	movl   $0x8033c4,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 8b 33 80 00 	movl   $0x80338b,(%esp)
  800310:	e8 8f 02 00 00       	call   8005a4 <_panic>
		if (n2 < 0)
  800315:	85 c0                	test   %eax,%eax
  800317:	79 20                	jns    800339 <umain+0x246>
			panic("reading testshell.key: %e", n2);
  800319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031d:	c7 44 24 08 de 33 80 	movl   $0x8033de,0x8(%esp)
  800324:	00 
  800325:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  80032c:	00 
  80032d:	c7 04 24 8b 33 80 00 	movl   $0x80338b,(%esp)
  800334:	e8 6b 02 00 00       	call   8005a4 <_panic>
		if (n1 == 0 && n2 == 0)
  800339:	85 db                	test   %ebx,%ebx
  80033b:	75 06                	jne    800343 <umain+0x250>
  80033d:	85 c0                	test   %eax,%eax
  80033f:	75 14                	jne    800355 <umain+0x262>
  800341:	eb 39                	jmp    80037c <umain+0x289>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  800343:	83 fb 01             	cmp    $0x1,%ebx
  800346:	75 0d                	jne    800355 <umain+0x262>
  800348:	83 f8 01             	cmp    $0x1,%eax
  80034b:	75 08                	jne    800355 <umain+0x262>
  80034d:	8a 45 e6             	mov    -0x1a(%ebp),%al
  800350:	38 45 e7             	cmp    %al,-0x19(%ebp)
  800353:	74 13                	je     800368 <umain+0x275>
			wrong(rfd, kfd, nloff);
  800355:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800358:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	89 3c 24             	mov    %edi,(%esp)
  800363:	e8 cc fc ff ff       	call   800034 <wrong>
		if (c1 == '\n')
  800368:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  80036c:	75 06                	jne    800374 <umain+0x281>
			nloff = off+1;
  80036e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800371:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800374:	ff 45 d4             	incl   -0x2c(%ebp)
	}
  800377:	e9 45 ff ff ff       	jmp    8002c1 <umain+0x1ce>
	cprintf("shell ran correctly\n");
  80037c:	c7 04 24 f8 33 80 00 	movl   $0x8033f8,(%esp)
  800383:	e8 14 03 00 00       	call   80069c <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800388:	cc                   	int3   

	breakpoint();
}
  800389:	83 c4 3c             	add    $0x3c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    
  800391:	00 00                	add    %al,(%eax)
	...

00800394 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800397:	b8 00 00 00 00       	mov    $0x0,%eax
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8003a4:	c7 44 24 04 0d 34 80 	movl   $0x80340d,0x4(%esp)
  8003ab:	00 
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	e8 90 08 00 00       	call   800c47 <strcpy>
	return 0;
}
  8003b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003d5:	eb 30                	jmp    800407 <devcons_write+0x49>
		m = n - tot;
  8003d7:	8b 75 10             	mov    0x10(%ebp),%esi
  8003da:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8003dc:	83 fe 7f             	cmp    $0x7f,%esi
  8003df:	76 05                	jbe    8003e6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8003e1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8003e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003ea:	03 45 0c             	add    0xc(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	89 3c 24             	mov    %edi,(%esp)
  8003f4:	e8 c7 09 00 00       	call   800dc0 <memmove>
		sys_cputs(buf, m);
  8003f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fd:	89 3c 24             	mov    %edi,(%esp)
  800400:	e8 67 0b 00 00       	call   800f6c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800405:	01 f3                	add    %esi,%ebx
  800407:	89 d8                	mov    %ebx,%eax
  800409:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80040c:	72 c9                	jb     8003d7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80040e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800414:	5b                   	pop    %ebx
  800415:	5e                   	pop    %esi
  800416:	5f                   	pop    %edi
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80041f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800423:	75 07                	jne    80042c <devcons_read+0x13>
  800425:	eb 25                	jmp    80044c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800427:	e8 ee 0b 00 00       	call   80101a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80042c:	e8 59 0b 00 00       	call   800f8a <sys_cgetc>
  800431:	85 c0                	test   %eax,%eax
  800433:	74 f2                	je     800427 <devcons_read+0xe>
  800435:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800437:	85 c0                	test   %eax,%eax
  800439:	78 1d                	js     800458 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80043b:	83 f8 04             	cmp    $0x4,%eax
  80043e:	74 13                	je     800453 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	88 10                	mov    %dl,(%eax)
	return 1;
  800445:	b8 01 00 00 00       	mov    $0x1,%eax
  80044a:	eb 0c                	jmp    800458 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80044c:	b8 00 00 00 00       	mov    $0x0,%eax
  800451:	eb 05                	jmp    800458 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800458:	c9                   	leave  
  800459:	c3                   	ret    

0080045a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800466:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80046d:	00 
  80046e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 f3 0a 00 00       	call   800f6c <sys_cputs>
}
  800479:	c9                   	leave  
  80047a:	c3                   	ret    

0080047b <getchar>:

int
getchar(void)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800481:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800488:	00 
  800489:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800497:	e8 40 15 00 00       	call   8019dc <read>
	if (r < 0)
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 0f                	js     8004af <getchar+0x34>
		return r;
	if (r < 1)
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	7e 06                	jle    8004aa <getchar+0x2f>
		return -E_EOF;
	return c;
  8004a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8004a8:	eb 05                	jmp    8004af <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8004aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8004af:	c9                   	leave  
  8004b0:	c3                   	ret    

008004b1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	e8 75 12 00 00       	call   80173e <fd_lookup>
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	78 11                	js     8004de <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8004cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8004d6:	39 10                	cmp    %edx,(%eax)
  8004d8:	0f 94 c0             	sete   %al
  8004db:	0f b6 c0             	movzbl %al,%eax
}
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <opencons>:

int
opencons(void)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8004e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 fa 11 00 00       	call   8016eb <fd_alloc>
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	78 3c                	js     800531 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8004f5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8004fc:	00 
  8004fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800500:	89 44 24 04          	mov    %eax,0x4(%esp)
  800504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80050b:	e8 29 0b 00 00       	call   801039 <sys_page_alloc>
  800510:	85 c0                	test   %eax,%eax
  800512:	78 1d                	js     800531 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800514:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80051a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80051d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80051f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800522:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 8f 11 00 00       	call   8016c0 <fd2num>
}
  800531:	c9                   	leave  
  800532:	c3                   	ret    
	...

00800534 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	56                   	push   %esi
  800538:	53                   	push   %ebx
  800539:	83 ec 10             	sub    $0x10,%esp
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800542:	e8 b4 0a 00 00       	call   800ffb <sys_getenvid>
  800547:	25 ff 03 00 00       	and    $0x3ff,%eax
  80054c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800553:	c1 e0 07             	shl    $0x7,%eax
  800556:	29 d0                	sub    %edx,%eax
  800558:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80055d:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800562:	85 f6                	test   %esi,%esi
  800564:	7e 07                	jle    80056d <libmain+0x39>
		binaryname = argv[0];
  800566:	8b 03                	mov    (%ebx),%eax
  800568:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  80056d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 7a fb ff ff       	call   8000f3 <umain>

	// exit gracefully
	exit();
  800579:	e8 0a 00 00 00       	call   800588 <exit>
}
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	5b                   	pop    %ebx
  800582:	5e                   	pop    %esi
  800583:	5d                   	pop    %ebp
  800584:	c3                   	ret    
  800585:	00 00                	add    %al,(%eax)
	...

00800588 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800588:	55                   	push   %ebp
  800589:	89 e5                	mov    %esp,%ebp
  80058b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80058e:	e8 14 13 00 00       	call   8018a7 <close_all>
	sys_env_destroy(0);
  800593:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80059a:	e8 0a 0a 00 00       	call   800fa9 <sys_env_destroy>
}
  80059f:	c9                   	leave  
  8005a0:	c3                   	ret    
  8005a1:	00 00                	add    %al,(%eax)
	...

008005a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	56                   	push   %esi
  8005a8:	53                   	push   %ebx
  8005a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005af:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  8005b5:	e8 41 0a 00 00       	call   800ffb <sys_getenvid>
  8005ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d0:	c7 04 24 24 34 80 00 	movl   $0x803424,(%esp)
  8005d7:	e8 c0 00 00 00       	call   80069c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	e8 50 00 00 00       	call   80063b <vcprintf>
	cprintf("\n");
  8005eb:	c7 04 24 58 33 80 00 	movl   $0x803358,(%esp)
  8005f2:	e8 a5 00 00 00       	call   80069c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005f7:	cc                   	int3   
  8005f8:	eb fd                	jmp    8005f7 <_panic+0x53>
	...

008005fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	53                   	push   %ebx
  800600:	83 ec 14             	sub    $0x14,%esp
  800603:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800606:	8b 03                	mov    (%ebx),%eax
  800608:	8b 55 08             	mov    0x8(%ebp),%edx
  80060b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80060f:	40                   	inc    %eax
  800610:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800612:	3d ff 00 00 00       	cmp    $0xff,%eax
  800617:	75 19                	jne    800632 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800619:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800620:	00 
  800621:	8d 43 08             	lea    0x8(%ebx),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	e8 40 09 00 00       	call   800f6c <sys_cputs>
		b->idx = 0;
  80062c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800632:	ff 43 04             	incl   0x4(%ebx)
}
  800635:	83 c4 14             	add    $0x14,%esp
  800638:	5b                   	pop    %ebx
  800639:	5d                   	pop    %ebp
  80063a:	c3                   	ret    

0080063b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800644:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80064b:	00 00 00 
	b.cnt = 0;
  80064e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800655:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800658:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	89 44 24 08          	mov    %eax,0x8(%esp)
  800666:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80066c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800670:	c7 04 24 fc 05 80 00 	movl   $0x8005fc,(%esp)
  800677:	e8 82 01 00 00       	call   8007fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80067c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800682:	89 44 24 04          	mov    %eax,0x4(%esp)
  800686:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	e8 d8 08 00 00       	call   800f6c <sys_cputs>

	return b.cnt;
}
  800694:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ac:	89 04 24             	mov    %eax,(%esp)
  8006af:	e8 87 ff ff ff       	call   80063b <vcprintf>
	va_end(ap);

	return cnt;
}
  8006b4:	c9                   	leave  
  8006b5:	c3                   	ret    
	...

008006b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 3c             	sub    $0x3c,%esp
  8006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c4:	89 d7                	mov    %edx,%edi
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006d5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	75 08                	jne    8006e4 <printnum+0x2c>
  8006dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006e2:	77 57                	ja     80073b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006e8:	4b                   	dec    %ebx
  8006e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8006f8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8006fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800703:	00 
  800704:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80070d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800711:	e8 7a 29 00 00       	call   803090 <__udivdi3>
  800716:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80071a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071e:	89 04 24             	mov    %eax,(%esp)
  800721:	89 54 24 04          	mov    %edx,0x4(%esp)
  800725:	89 fa                	mov    %edi,%edx
  800727:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80072a:	e8 89 ff ff ff       	call   8006b8 <printnum>
  80072f:	eb 0f                	jmp    800740 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800731:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800735:	89 34 24             	mov    %esi,(%esp)
  800738:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80073b:	4b                   	dec    %ebx
  80073c:	85 db                	test   %ebx,%ebx
  80073e:	7f f1                	jg     800731 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800740:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800744:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800748:	8b 45 10             	mov    0x10(%ebp),%eax
  80074b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800756:	00 
  800757:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80075a:	89 04 24             	mov    %eax,(%esp)
  80075d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	e8 47 2a 00 00       	call   8031b0 <__umoddi3>
  800769:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076d:	0f be 80 47 34 80 00 	movsbl 0x803447(%eax),%eax
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80077a:	83 c4 3c             	add    $0x3c,%esp
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5f                   	pop    %edi
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800785:	83 fa 01             	cmp    $0x1,%edx
  800788:	7e 0e                	jle    800798 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80078a:	8b 10                	mov    (%eax),%edx
  80078c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80078f:	89 08                	mov    %ecx,(%eax)
  800791:	8b 02                	mov    (%edx),%eax
  800793:	8b 52 04             	mov    0x4(%edx),%edx
  800796:	eb 22                	jmp    8007ba <getuint+0x38>
	else if (lflag)
  800798:	85 d2                	test   %edx,%edx
  80079a:	74 10                	je     8007ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80079c:	8b 10                	mov    (%eax),%edx
  80079e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a1:	89 08                	mov    %ecx,(%eax)
  8007a3:	8b 02                	mov    (%edx),%eax
  8007a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007aa:	eb 0e                	jmp    8007ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007ac:	8b 10                	mov    (%eax),%edx
  8007ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b1:	89 08                	mov    %ecx,(%eax)
  8007b3:	8b 02                	mov    (%edx),%eax
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007c5:	8b 10                	mov    (%eax),%edx
  8007c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ca:	73 08                	jae    8007d4 <sprintputch+0x18>
		*b->buf++ = ch;
  8007cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cf:	88 0a                	mov    %cl,(%edx)
  8007d1:	42                   	inc    %edx
  8007d2:	89 10                	mov    %edx,(%eax)
}
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	e8 02 00 00 00       	call   8007fe <vprintfmt>
	va_end(ap);
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	57                   	push   %edi
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	83 ec 4c             	sub    $0x4c,%esp
  800807:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080a:	8b 75 10             	mov    0x10(%ebp),%esi
  80080d:	eb 12                	jmp    800821 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80080f:	85 c0                	test   %eax,%eax
  800811:	0f 84 6b 03 00 00    	je     800b82 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800817:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800821:	0f b6 06             	movzbl (%esi),%eax
  800824:	46                   	inc    %esi
  800825:	83 f8 25             	cmp    $0x25,%eax
  800828:	75 e5                	jne    80080f <vprintfmt+0x11>
  80082a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80082e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800835:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80083a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800841:	b9 00 00 00 00       	mov    $0x0,%ecx
  800846:	eb 26                	jmp    80086e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800848:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80084b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80084f:	eb 1d                	jmp    80086e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800854:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800858:	eb 14                	jmp    80086e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80085d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800864:	eb 08                	jmp    80086e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800866:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800869:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086e:	0f b6 06             	movzbl (%esi),%eax
  800871:	8d 56 01             	lea    0x1(%esi),%edx
  800874:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800877:	8a 16                	mov    (%esi),%dl
  800879:	83 ea 23             	sub    $0x23,%edx
  80087c:	80 fa 55             	cmp    $0x55,%dl
  80087f:	0f 87 e1 02 00 00    	ja     800b66 <vprintfmt+0x368>
  800885:	0f b6 d2             	movzbl %dl,%edx
  800888:	ff 24 95 80 35 80 00 	jmp    *0x803580(,%edx,4)
  80088f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800892:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800897:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80089a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80089e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008a4:	83 fa 09             	cmp    $0x9,%edx
  8008a7:	77 2a                	ja     8008d3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008aa:	eb eb                	jmp    800897 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8d 50 04             	lea    0x4(%eax),%edx
  8008b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ba:	eb 17                	jmp    8008d3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c0:	78 98                	js     80085a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c5:	eb a7                	jmp    80086e <vprintfmt+0x70>
  8008c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008d1:	eb 9b                	jmp    80086e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8008d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d7:	79 95                	jns    80086e <vprintfmt+0x70>
  8008d9:	eb 8b                	jmp    800866 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008db:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008df:	eb 8d                	jmp    80086e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e4:	8d 50 04             	lea    0x4(%eax),%edx
  8008e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ee:	8b 00                	mov    (%eax),%eax
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008f9:	e9 23 ff ff ff       	jmp    800821 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800901:	8d 50 04             	lea    0x4(%eax),%edx
  800904:	89 55 14             	mov    %edx,0x14(%ebp)
  800907:	8b 00                	mov    (%eax),%eax
  800909:	85 c0                	test   %eax,%eax
  80090b:	79 02                	jns    80090f <vprintfmt+0x111>
  80090d:	f7 d8                	neg    %eax
  80090f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800911:	83 f8 10             	cmp    $0x10,%eax
  800914:	7f 0b                	jg     800921 <vprintfmt+0x123>
  800916:	8b 04 85 e0 36 80 00 	mov    0x8036e0(,%eax,4),%eax
  80091d:	85 c0                	test   %eax,%eax
  80091f:	75 23                	jne    800944 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800921:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800925:	c7 44 24 08 5f 34 80 	movl   $0x80345f,0x8(%esp)
  80092c:	00 
  80092d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	89 04 24             	mov    %eax,(%esp)
  800937:	e8 9a fe ff ff       	call   8007d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80093f:	e9 dd fe ff ff       	jmp    800821 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800944:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800948:	c7 44 24 08 c9 38 80 	movl   $0x8038c9,0x8(%esp)
  80094f:	00 
  800950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800954:	8b 55 08             	mov    0x8(%ebp),%edx
  800957:	89 14 24             	mov    %edx,(%esp)
  80095a:	e8 77 fe ff ff       	call   8007d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800962:	e9 ba fe ff ff       	jmp    800821 <vprintfmt+0x23>
  800967:	89 f9                	mov    %edi,%ecx
  800969:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80096c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80096f:	8b 45 14             	mov    0x14(%ebp),%eax
  800972:	8d 50 04             	lea    0x4(%eax),%edx
  800975:	89 55 14             	mov    %edx,0x14(%ebp)
  800978:	8b 30                	mov    (%eax),%esi
  80097a:	85 f6                	test   %esi,%esi
  80097c:	75 05                	jne    800983 <vprintfmt+0x185>
				p = "(null)";
  80097e:	be 58 34 80 00       	mov    $0x803458,%esi
			if (width > 0 && padc != '-')
  800983:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800987:	0f 8e 84 00 00 00    	jle    800a11 <vprintfmt+0x213>
  80098d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800991:	74 7e                	je     800a11 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800993:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800997:	89 34 24             	mov    %esi,(%esp)
  80099a:	e8 8b 02 00 00       	call   800c2a <strnlen>
  80099f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009a2:	29 c2                	sub    %eax,%edx
  8009a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009a7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009ab:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009ae:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009b1:	89 de                	mov    %ebx,%esi
  8009b3:	89 d3                	mov    %edx,%ebx
  8009b5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b7:	eb 0b                	jmp    8009c4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009bd:	89 3c 24             	mov    %edi,(%esp)
  8009c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c3:	4b                   	dec    %ebx
  8009c4:	85 db                	test   %ebx,%ebx
  8009c6:	7f f1                	jg     8009b9 <vprintfmt+0x1bb>
  8009c8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009cb:	89 f3                	mov    %esi,%ebx
  8009cd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8009d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	79 05                	jns    8009dc <vprintfmt+0x1de>
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009df:	29 c2                	sub    %eax,%edx
  8009e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009e4:	eb 2b                	jmp    800a11 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009ea:	74 18                	je     800a04 <vprintfmt+0x206>
  8009ec:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009ef:	83 fa 5e             	cmp    $0x5e,%edx
  8009f2:	76 10                	jbe    800a04 <vprintfmt+0x206>
					putch('?', putdat);
  8009f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009ff:	ff 55 08             	call   *0x8(%ebp)
  800a02:	eb 0a                	jmp    800a0e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0e:	ff 4d e4             	decl   -0x1c(%ebp)
  800a11:	0f be 06             	movsbl (%esi),%eax
  800a14:	46                   	inc    %esi
  800a15:	85 c0                	test   %eax,%eax
  800a17:	74 21                	je     800a3a <vprintfmt+0x23c>
  800a19:	85 ff                	test   %edi,%edi
  800a1b:	78 c9                	js     8009e6 <vprintfmt+0x1e8>
  800a1d:	4f                   	dec    %edi
  800a1e:	79 c6                	jns    8009e6 <vprintfmt+0x1e8>
  800a20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a23:	89 de                	mov    %ebx,%esi
  800a25:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a28:	eb 18                	jmp    800a42 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a35:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a37:	4b                   	dec    %ebx
  800a38:	eb 08                	jmp    800a42 <vprintfmt+0x244>
  800a3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3d:	89 de                	mov    %ebx,%esi
  800a3f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	7f e4                	jg     800a2a <vprintfmt+0x22c>
  800a46:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a49:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a4e:	e9 ce fd ff ff       	jmp    800821 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a53:	83 f9 01             	cmp    $0x1,%ecx
  800a56:	7e 10                	jle    800a68 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a58:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5b:	8d 50 08             	lea    0x8(%eax),%edx
  800a5e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a61:	8b 30                	mov    (%eax),%esi
  800a63:	8b 78 04             	mov    0x4(%eax),%edi
  800a66:	eb 26                	jmp    800a8e <vprintfmt+0x290>
	else if (lflag)
  800a68:	85 c9                	test   %ecx,%ecx
  800a6a:	74 12                	je     800a7e <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6f:	8d 50 04             	lea    0x4(%eax),%edx
  800a72:	89 55 14             	mov    %edx,0x14(%ebp)
  800a75:	8b 30                	mov    (%eax),%esi
  800a77:	89 f7                	mov    %esi,%edi
  800a79:	c1 ff 1f             	sar    $0x1f,%edi
  800a7c:	eb 10                	jmp    800a8e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a81:	8d 50 04             	lea    0x4(%eax),%edx
  800a84:	89 55 14             	mov    %edx,0x14(%ebp)
  800a87:	8b 30                	mov    (%eax),%esi
  800a89:	89 f7                	mov    %esi,%edi
  800a8b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a8e:	85 ff                	test   %edi,%edi
  800a90:	78 0a                	js     800a9c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a97:	e9 8c 00 00 00       	jmp    800b28 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800aa7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aaa:	f7 de                	neg    %esi
  800aac:	83 d7 00             	adc    $0x0,%edi
  800aaf:	f7 df                	neg    %edi
			}
			base = 10;
  800ab1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab6:	eb 70                	jmp    800b28 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ab8:	89 ca                	mov    %ecx,%edx
  800aba:	8d 45 14             	lea    0x14(%ebp),%eax
  800abd:	e8 c0 fc ff ff       	call   800782 <getuint>
  800ac2:	89 c6                	mov    %eax,%esi
  800ac4:	89 d7                	mov    %edx,%edi
			base = 10;
  800ac6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800acb:	eb 5b                	jmp    800b28 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800acd:	89 ca                	mov    %ecx,%edx
  800acf:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad2:	e8 ab fc ff ff       	call   800782 <getuint>
  800ad7:	89 c6                	mov    %eax,%esi
  800ad9:	89 d7                	mov    %edx,%edi
			base = 8;
  800adb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800ae0:	eb 46                	jmp    800b28 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800ae2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800aed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800af0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800afb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800afe:	8b 45 14             	mov    0x14(%ebp),%eax
  800b01:	8d 50 04             	lea    0x4(%eax),%edx
  800b04:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b07:	8b 30                	mov    (%eax),%esi
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b0e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b13:	eb 13                	jmp    800b28 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b15:	89 ca                	mov    %ecx,%edx
  800b17:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1a:	e8 63 fc ff ff       	call   800782 <getuint>
  800b1f:	89 c6                	mov    %eax,%esi
  800b21:	89 d7                	mov    %edx,%edi
			base = 16;
  800b23:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b28:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b2c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b33:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3b:	89 34 24             	mov    %esi,(%esp)
  800b3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b42:	89 da                	mov    %ebx,%edx
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	e8 6c fb ff ff       	call   8006b8 <printnum>
			break;
  800b4c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b4f:	e9 cd fc ff ff       	jmp    800821 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b5e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b61:	e9 bb fc ff ff       	jmp    800821 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b6a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b71:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b74:	eb 01                	jmp    800b77 <vprintfmt+0x379>
  800b76:	4e                   	dec    %esi
  800b77:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b7b:	75 f9                	jne    800b76 <vprintfmt+0x378>
  800b7d:	e9 9f fc ff ff       	jmp    800821 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b82:	83 c4 4c             	add    $0x4c,%esp
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	83 ec 28             	sub    $0x28,%esp
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b99:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b9d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ba0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	74 30                	je     800bdb <vsnprintf+0x51>
  800bab:	85 d2                	test   %edx,%edx
  800bad:	7e 33                	jle    800be2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800baf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bbd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc4:	c7 04 24 bc 07 80 00 	movl   $0x8007bc,(%esp)
  800bcb:	e8 2e fc ff ff       	call   8007fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bd3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd9:	eb 0c                	jmp    800be7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800be0:	eb 05                	jmp    800be7 <vsnprintf+0x5d>
  800be2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bf6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	89 04 24             	mov    %eax,(%esp)
  800c0a:	e8 7b ff ff ff       	call   800b8a <vsnprintf>
	va_end(ap);

	return rc;
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    
  800c11:	00 00                	add    %al,(%eax)
	...

00800c14 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	eb 01                	jmp    800c22 <strlen+0xe>
		n++;
  800c21:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c22:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c26:	75 f9                	jne    800c21 <strlen+0xd>
		n++;
	return n;
}
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c30:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
  800c38:	eb 01                	jmp    800c3b <strnlen+0x11>
		n++;
  800c3a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3b:	39 d0                	cmp    %edx,%eax
  800c3d:	74 06                	je     800c45 <strnlen+0x1b>
  800c3f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c43:	75 f5                	jne    800c3a <strnlen+0x10>
		n++;
	return n;
}
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	53                   	push   %ebx
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c51:	ba 00 00 00 00       	mov    $0x0,%edx
  800c56:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c59:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c5c:	42                   	inc    %edx
  800c5d:	84 c9                	test   %cl,%cl
  800c5f:	75 f5                	jne    800c56 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c61:	5b                   	pop    %ebx
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	53                   	push   %ebx
  800c68:	83 ec 08             	sub    $0x8,%esp
  800c6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c6e:	89 1c 24             	mov    %ebx,(%esp)
  800c71:	e8 9e ff ff ff       	call   800c14 <strlen>
	strcpy(dst + len, src);
  800c76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c79:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c7d:	01 d8                	add    %ebx,%eax
  800c7f:	89 04 24             	mov    %eax,(%esp)
  800c82:	e8 c0 ff ff ff       	call   800c47 <strcpy>
	return dst;
}
  800c87:	89 d8                	mov    %ebx,%eax
  800c89:	83 c4 08             	add    $0x8,%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca2:	eb 0c                	jmp    800cb0 <strncpy+0x21>
		*dst++ = *src;
  800ca4:	8a 1a                	mov    (%edx),%bl
  800ca6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ca9:	80 3a 01             	cmpb   $0x1,(%edx)
  800cac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800caf:	41                   	inc    %ecx
  800cb0:	39 f1                	cmp    %esi,%ecx
  800cb2:	75 f0                	jne    800ca4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cc6:	85 d2                	test   %edx,%edx
  800cc8:	75 0a                	jne    800cd4 <strlcpy+0x1c>
  800cca:	89 f0                	mov    %esi,%eax
  800ccc:	eb 1a                	jmp    800ce8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cce:	88 18                	mov    %bl,(%eax)
  800cd0:	40                   	inc    %eax
  800cd1:	41                   	inc    %ecx
  800cd2:	eb 02                	jmp    800cd6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cd4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800cd6:	4a                   	dec    %edx
  800cd7:	74 0a                	je     800ce3 <strlcpy+0x2b>
  800cd9:	8a 19                	mov    (%ecx),%bl
  800cdb:	84 db                	test   %bl,%bl
  800cdd:	75 ef                	jne    800cce <strlcpy+0x16>
  800cdf:	89 c2                	mov    %eax,%edx
  800ce1:	eb 02                	jmp    800ce5 <strlcpy+0x2d>
  800ce3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ce5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ce8:	29 f0                	sub    %esi,%eax
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cf7:	eb 02                	jmp    800cfb <strcmp+0xd>
		p++, q++;
  800cf9:	41                   	inc    %ecx
  800cfa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cfb:	8a 01                	mov    (%ecx),%al
  800cfd:	84 c0                	test   %al,%al
  800cff:	74 04                	je     800d05 <strcmp+0x17>
  800d01:	3a 02                	cmp    (%edx),%al
  800d03:	74 f4                	je     800cf9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d05:	0f b6 c0             	movzbl %al,%eax
  800d08:	0f b6 12             	movzbl (%edx),%edx
  800d0b:	29 d0                	sub    %edx,%eax
}
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	53                   	push   %ebx
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d1c:	eb 03                	jmp    800d21 <strncmp+0x12>
		n--, p++, q++;
  800d1e:	4a                   	dec    %edx
  800d1f:	40                   	inc    %eax
  800d20:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d21:	85 d2                	test   %edx,%edx
  800d23:	74 14                	je     800d39 <strncmp+0x2a>
  800d25:	8a 18                	mov    (%eax),%bl
  800d27:	84 db                	test   %bl,%bl
  800d29:	74 04                	je     800d2f <strncmp+0x20>
  800d2b:	3a 19                	cmp    (%ecx),%bl
  800d2d:	74 ef                	je     800d1e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d2f:	0f b6 00             	movzbl (%eax),%eax
  800d32:	0f b6 11             	movzbl (%ecx),%edx
  800d35:	29 d0                	sub    %edx,%eax
  800d37:	eb 05                	jmp    800d3e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d39:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
  800d47:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d4a:	eb 05                	jmp    800d51 <strchr+0x10>
		if (*s == c)
  800d4c:	38 ca                	cmp    %cl,%dl
  800d4e:	74 0c                	je     800d5c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d50:	40                   	inc    %eax
  800d51:	8a 10                	mov    (%eax),%dl
  800d53:	84 d2                	test   %dl,%dl
  800d55:	75 f5                	jne    800d4c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d67:	eb 05                	jmp    800d6e <strfind+0x10>
		if (*s == c)
  800d69:	38 ca                	cmp    %cl,%dl
  800d6b:	74 07                	je     800d74 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d6d:	40                   	inc    %eax
  800d6e:	8a 10                	mov    (%eax),%dl
  800d70:	84 d2                	test   %dl,%dl
  800d72:	75 f5                	jne    800d69 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d85:	85 c9                	test   %ecx,%ecx
  800d87:	74 30                	je     800db9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d8f:	75 25                	jne    800db6 <memset+0x40>
  800d91:	f6 c1 03             	test   $0x3,%cl
  800d94:	75 20                	jne    800db6 <memset+0x40>
		c &= 0xFF;
  800d96:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d99:	89 d3                	mov    %edx,%ebx
  800d9b:	c1 e3 08             	shl    $0x8,%ebx
  800d9e:	89 d6                	mov    %edx,%esi
  800da0:	c1 e6 18             	shl    $0x18,%esi
  800da3:	89 d0                	mov    %edx,%eax
  800da5:	c1 e0 10             	shl    $0x10,%eax
  800da8:	09 f0                	or     %esi,%eax
  800daa:	09 d0                	or     %edx,%eax
  800dac:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dae:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800db1:	fc                   	cld    
  800db2:	f3 ab                	rep stos %eax,%es:(%edi)
  800db4:	eb 03                	jmp    800db9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800db6:	fc                   	cld    
  800db7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800db9:	89 f8                	mov    %edi,%eax
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dce:	39 c6                	cmp    %eax,%esi
  800dd0:	73 34                	jae    800e06 <memmove+0x46>
  800dd2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dd5:	39 d0                	cmp    %edx,%eax
  800dd7:	73 2d                	jae    800e06 <memmove+0x46>
		s += n;
		d += n;
  800dd9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ddc:	f6 c2 03             	test   $0x3,%dl
  800ddf:	75 1b                	jne    800dfc <memmove+0x3c>
  800de1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800de7:	75 13                	jne    800dfc <memmove+0x3c>
  800de9:	f6 c1 03             	test   $0x3,%cl
  800dec:	75 0e                	jne    800dfc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800dee:	83 ef 04             	sub    $0x4,%edi
  800df1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800df4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800df7:	fd                   	std    
  800df8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dfa:	eb 07                	jmp    800e03 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800dfc:	4f                   	dec    %edi
  800dfd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e00:	fd                   	std    
  800e01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e03:	fc                   	cld    
  800e04:	eb 20                	jmp    800e26 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e0c:	75 13                	jne    800e21 <memmove+0x61>
  800e0e:	a8 03                	test   $0x3,%al
  800e10:	75 0f                	jne    800e21 <memmove+0x61>
  800e12:	f6 c1 03             	test   $0x3,%cl
  800e15:	75 0a                	jne    800e21 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e17:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e1a:	89 c7                	mov    %eax,%edi
  800e1c:	fc                   	cld    
  800e1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1f:	eb 05                	jmp    800e26 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e21:	89 c7                	mov    %eax,%edi
  800e23:	fc                   	cld    
  800e24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e30:	8b 45 10             	mov    0x10(%ebp),%eax
  800e33:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	89 04 24             	mov    %eax,(%esp)
  800e44:	e8 77 ff ff ff       	call   800dc0 <memmove>
}
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5f:	eb 16                	jmp    800e77 <memcmp+0x2c>
		if (*s1 != *s2)
  800e61:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e64:	42                   	inc    %edx
  800e65:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e69:	38 c8                	cmp    %cl,%al
  800e6b:	74 0a                	je     800e77 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e6d:	0f b6 c0             	movzbl %al,%eax
  800e70:	0f b6 c9             	movzbl %cl,%ecx
  800e73:	29 c8                	sub    %ecx,%eax
  800e75:	eb 09                	jmp    800e80 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e77:	39 da                	cmp    %ebx,%edx
  800e79:	75 e6                	jne    800e61 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e8e:	89 c2                	mov    %eax,%edx
  800e90:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e93:	eb 05                	jmp    800e9a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e95:	38 08                	cmp    %cl,(%eax)
  800e97:	74 05                	je     800e9e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e99:	40                   	inc    %eax
  800e9a:	39 d0                	cmp    %edx,%eax
  800e9c:	72 f7                	jb     800e95 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eac:	eb 01                	jmp    800eaf <strtol+0xf>
		s++;
  800eae:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eaf:	8a 02                	mov    (%edx),%al
  800eb1:	3c 20                	cmp    $0x20,%al
  800eb3:	74 f9                	je     800eae <strtol+0xe>
  800eb5:	3c 09                	cmp    $0x9,%al
  800eb7:	74 f5                	je     800eae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eb9:	3c 2b                	cmp    $0x2b,%al
  800ebb:	75 08                	jne    800ec5 <strtol+0x25>
		s++;
  800ebd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ebe:	bf 00 00 00 00       	mov    $0x0,%edi
  800ec3:	eb 13                	jmp    800ed8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ec5:	3c 2d                	cmp    $0x2d,%al
  800ec7:	75 0a                	jne    800ed3 <strtol+0x33>
		s++, neg = 1;
  800ec9:	8d 52 01             	lea    0x1(%edx),%edx
  800ecc:	bf 01 00 00 00       	mov    $0x1,%edi
  800ed1:	eb 05                	jmp    800ed8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ed8:	85 db                	test   %ebx,%ebx
  800eda:	74 05                	je     800ee1 <strtol+0x41>
  800edc:	83 fb 10             	cmp    $0x10,%ebx
  800edf:	75 28                	jne    800f09 <strtol+0x69>
  800ee1:	8a 02                	mov    (%edx),%al
  800ee3:	3c 30                	cmp    $0x30,%al
  800ee5:	75 10                	jne    800ef7 <strtol+0x57>
  800ee7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eeb:	75 0a                	jne    800ef7 <strtol+0x57>
		s += 2, base = 16;
  800eed:	83 c2 02             	add    $0x2,%edx
  800ef0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ef5:	eb 12                	jmp    800f09 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ef7:	85 db                	test   %ebx,%ebx
  800ef9:	75 0e                	jne    800f09 <strtol+0x69>
  800efb:	3c 30                	cmp    $0x30,%al
  800efd:	75 05                	jne    800f04 <strtol+0x64>
		s++, base = 8;
  800eff:	42                   	inc    %edx
  800f00:	b3 08                	mov    $0x8,%bl
  800f02:	eb 05                	jmp    800f09 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f04:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f10:	8a 0a                	mov    (%edx),%cl
  800f12:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f15:	80 fb 09             	cmp    $0x9,%bl
  800f18:	77 08                	ja     800f22 <strtol+0x82>
			dig = *s - '0';
  800f1a:	0f be c9             	movsbl %cl,%ecx
  800f1d:	83 e9 30             	sub    $0x30,%ecx
  800f20:	eb 1e                	jmp    800f40 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f22:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f25:	80 fb 19             	cmp    $0x19,%bl
  800f28:	77 08                	ja     800f32 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f2a:	0f be c9             	movsbl %cl,%ecx
  800f2d:	83 e9 57             	sub    $0x57,%ecx
  800f30:	eb 0e                	jmp    800f40 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f32:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f35:	80 fb 19             	cmp    $0x19,%bl
  800f38:	77 12                	ja     800f4c <strtol+0xac>
			dig = *s - 'A' + 10;
  800f3a:	0f be c9             	movsbl %cl,%ecx
  800f3d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f40:	39 f1                	cmp    %esi,%ecx
  800f42:	7d 0c                	jge    800f50 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f44:	42                   	inc    %edx
  800f45:	0f af c6             	imul   %esi,%eax
  800f48:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f4a:	eb c4                	jmp    800f10 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f4c:	89 c1                	mov    %eax,%ecx
  800f4e:	eb 02                	jmp    800f52 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f50:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f56:	74 05                	je     800f5d <strtol+0xbd>
		*endptr = (char *) s;
  800f58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f5b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f5d:	85 ff                	test   %edi,%edi
  800f5f:	74 04                	je     800f65 <strtol+0xc5>
  800f61:	89 c8                	mov    %ecx,%eax
  800f63:	f7 d8                	neg    %eax
}
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    
	...

00800f6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
  800f77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7d:	89 c3                	mov    %eax,%ebx
  800f7f:	89 c7                	mov    %eax,%edi
  800f81:	89 c6                	mov    %eax,%esi
  800f83:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f90:	ba 00 00 00 00       	mov    $0x0,%edx
  800f95:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9a:	89 d1                	mov    %edx,%ecx
  800f9c:	89 d3                	mov    %edx,%ebx
  800f9e:	89 d7                	mov    %edx,%edi
  800fa0:	89 d6                	mov    %edx,%esi
  800fa2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	57                   	push   %edi
  800fad:	56                   	push   %esi
  800fae:	53                   	push   %ebx
  800faf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb7:	b8 03 00 00 00       	mov    $0x3,%eax
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	89 cb                	mov    %ecx,%ebx
  800fc1:	89 cf                	mov    %ecx,%edi
  800fc3:	89 ce                	mov    %ecx,%esi
  800fc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	7e 28                	jle    800ff3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fd6:	00 
  800fd7:	c7 44 24 08 43 37 80 	movl   $0x803743,0x8(%esp)
  800fde:	00 
  800fdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe6:	00 
  800fe7:	c7 04 24 60 37 80 00 	movl   $0x803760,(%esp)
  800fee:	e8 b1 f5 ff ff       	call   8005a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ff3:	83 c4 2c             	add    $0x2c,%esp
  800ff6:	5b                   	pop    %ebx
  800ff7:	5e                   	pop    %esi
  800ff8:	5f                   	pop    %edi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	57                   	push   %edi
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801001:	ba 00 00 00 00       	mov    $0x0,%edx
  801006:	b8 02 00 00 00       	mov    $0x2,%eax
  80100b:	89 d1                	mov    %edx,%ecx
  80100d:	89 d3                	mov    %edx,%ebx
  80100f:	89 d7                	mov    %edx,%edi
  801011:	89 d6                	mov    %edx,%esi
  801013:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_yield>:

void
sys_yield(void)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	ba 00 00 00 00       	mov    $0x0,%edx
  801025:	b8 0b 00 00 00       	mov    $0xb,%eax
  80102a:	89 d1                	mov    %edx,%ecx
  80102c:	89 d3                	mov    %edx,%ebx
  80102e:	89 d7                	mov    %edx,%edi
  801030:	89 d6                	mov    %edx,%esi
  801032:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	be 00 00 00 00       	mov    $0x0,%esi
  801047:	b8 04 00 00 00       	mov    $0x4,%eax
  80104c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80104f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801052:	8b 55 08             	mov    0x8(%ebp),%edx
  801055:	89 f7                	mov    %esi,%edi
  801057:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	7e 28                	jle    801085 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801061:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801068:	00 
  801069:	c7 44 24 08 43 37 80 	movl   $0x803743,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 60 37 80 00 	movl   $0x803760,(%esp)
  801080:	e8 1f f5 ff ff       	call   8005a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801085:	83 c4 2c             	add    $0x2c,%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	b8 05 00 00 00       	mov    $0x5,%eax
  80109b:	8b 75 18             	mov    0x18(%ebp),%esi
  80109e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	7e 28                	jle    8010d8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 08 43 37 80 	movl   $0x803743,0x8(%esp)
  8010c3:	00 
  8010c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cb:	00 
  8010cc:	c7 04 24 60 37 80 00 	movl   $0x803760,(%esp)
  8010d3:	e8 cc f4 ff ff       	call   8005a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010d8:	83 c4 2c             	add    $0x2c,%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f9:	89 df                	mov    %ebx,%edi
  8010fb:	89 de                	mov    %ebx,%esi
  8010fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ff:	85 c0                	test   %eax,%eax
  801101:	7e 28                	jle    80112b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801103:	89 44 24 10          	mov    %eax,0x10(%esp)
  801107:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80110e:	00 
  80110f:	c7 44 24 08 43 37 80 	movl   $0x803743,0x8(%esp)
  801116:	00 
  801117:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111e:	00 
  80111f:	c7 04 24 60 37 80 00 	movl   $0x803760,(%esp)
  801126:	e8 79 f4 ff ff       	call   8005a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80112b:	83 c4 2c             	add    $0x2c,%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801141:	b8 08 00 00 00       	mov    $0x8,%eax
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	89 df                	mov    %ebx,%edi
  80114e:	89 de                	mov    %ebx,%esi
  801150:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801152:	85 c0                	test   %eax,%eax
  801154:	7e 28                	jle    80117e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801156:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801161:	00 
  801162:	c7 44 24 08 43 37 80 	movl   $0x803743,0x8(%esp)
  801169:	00 
  80116a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801171:	00 
  801172:	c7 04 24 60 37 80 00 	movl   $0x803760,(%esp)
  801179:	e8 26 f4 ff ff       	call   8005a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80117e:	83 c4 2c             	add    $0x2c,%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	57                   	push   %edi
  80118a:	56                   	push   %esi
  80118b:	53                   	push   %ebx
  80118c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801194:	b8 09 00 00 00       	mov    $0x9,%eax
  801199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119c:	8b 55 08             	mov    0x8(%ebp),%edx
  80119f:	89 df                	mov    %ebx,%edi
  8011a1:	89 de                	mov    %ebx,%esi
  8011a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	7e 28                	jle    8011d1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ad:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011b4:	00 
  8011b5:	c7 44 24 08 43 37 80 	movl   $0x803743,0x8(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c4:	00 
  8011c5:	c7 04 24 60 37 80 00 	movl   $0x803760,(%esp)
  8011cc:	e8 d3 f3 ff ff       	call   8005a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011d1:	83 c4 2c             	add    $0x2c,%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f2:	89 df                	mov    %ebx,%edi
  8011f4:	89 de                	mov    %ebx,%esi
  8011f6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	7e 28                	jle    801224 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801200:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801207:	00 
  801208:	c7 44 24 08 43 37 80 	movl   $0x803743,0x8(%esp)
  80120f:	00 
  801210:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801217:	00 
  801218:	c7 04 24 60 37 80 00 	movl   $0x803760,(%esp)
  80121f:	e8 80 f3 ff ff       	call   8005a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801224:	83 c4 2c             	add    $0x2c,%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801232:	be 00 00 00 00       	mov    $0x0,%esi
  801237:	b8 0c 00 00 00       	mov    $0xc,%eax
  80123c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80123f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801245:	8b 55 08             	mov    0x8(%ebp),%edx
  801248:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80124a:	5b                   	pop    %ebx
  80124b:	5e                   	pop    %esi
  80124c:	5f                   	pop    %edi
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	57                   	push   %edi
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
  801255:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801258:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801262:	8b 55 08             	mov    0x8(%ebp),%edx
  801265:	89 cb                	mov    %ecx,%ebx
  801267:	89 cf                	mov    %ecx,%edi
  801269:	89 ce                	mov    %ecx,%esi
  80126b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80126d:	85 c0                	test   %eax,%eax
  80126f:	7e 28                	jle    801299 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801271:	89 44 24 10          	mov    %eax,0x10(%esp)
  801275:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80127c:	00 
  80127d:	c7 44 24 08 43 37 80 	movl   $0x803743,0x8(%esp)
  801284:	00 
  801285:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80128c:	00 
  80128d:	c7 04 24 60 37 80 00 	movl   $0x803760,(%esp)
  801294:	e8 0b f3 ff ff       	call   8005a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801299:	83 c4 2c             	add    $0x2c,%esp
  80129c:	5b                   	pop    %ebx
  80129d:	5e                   	pop    %esi
  80129e:	5f                   	pop    %edi
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	57                   	push   %edi
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ac:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012b1:	89 d1                	mov    %edx,%ecx
  8012b3:	89 d3                	mov    %edx,%ebx
  8012b5:	89 d7                	mov    %edx,%edi
  8012b7:	89 d6                	mov    %edx,%esi
  8012b9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012bb:	5b                   	pop    %ebx
  8012bc:	5e                   	pop    %esi
  8012bd:	5f                   	pop    %edi
  8012be:	5d                   	pop    %ebp
  8012bf:	c3                   	ret    

008012c0 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	57                   	push   %edi
  8012c4:	56                   	push   %esi
  8012c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012cb:	b8 0f 00 00 00       	mov    $0xf,%eax
  8012d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d6:	89 df                	mov    %ebx,%edi
  8012d8:	89 de                	mov    %ebx,%esi
  8012da:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  8012dc:	5b                   	pop    %ebx
  8012dd:	5e                   	pop    %esi
  8012de:	5f                   	pop    %edi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	57                   	push   %edi
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ec:	b8 10 00 00 00       	mov    $0x10,%eax
  8012f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f7:	89 df                	mov    %ebx,%edi
  8012f9:	89 de                	mov    %ebx,%esi
  8012fb:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    
	...

00801304 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	53                   	push   %ebx
  801308:	83 ec 24             	sub    $0x24,%esp
  80130b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80130e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  801310:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801314:	74 2d                	je     801343 <pgfault+0x3f>
  801316:	89 d8                	mov    %ebx,%eax
  801318:	c1 e8 16             	shr    $0x16,%eax
  80131b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801322:	a8 01                	test   $0x1,%al
  801324:	74 1d                	je     801343 <pgfault+0x3f>
  801326:	89 d8                	mov    %ebx,%eax
  801328:	c1 e8 0c             	shr    $0xc,%eax
  80132b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801332:	f6 c2 01             	test   $0x1,%dl
  801335:	74 0c                	je     801343 <pgfault+0x3f>
  801337:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133e:	f6 c4 08             	test   $0x8,%ah
  801341:	75 1c                	jne    80135f <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  801343:	c7 44 24 08 70 37 80 	movl   $0x803770,0x8(%esp)
  80134a:	00 
  80134b:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801352:	00 
  801353:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  80135a:	e8 45 f2 ff ff       	call   8005a4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  80135f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  801365:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80136c:	00 
  80136d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801374:	00 
  801375:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137c:	e8 b8 fc ff ff       	call   801039 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  801381:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801388:	00 
  801389:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80138d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801394:	e8 91 fa ff ff       	call   800e2a <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  801399:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013a0:	00 
  8013a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013ac:	00 
  8013ad:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013b4:	00 
  8013b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013bc:	e8 cc fc ff ff       	call   80108d <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  8013c1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013c8:	00 
  8013c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d0:	e8 0b fd ff ff       	call   8010e0 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  8013d5:	83 c4 24             	add    $0x24,%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	57                   	push   %edi
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8013e4:	c7 04 24 04 13 80 00 	movl   $0x801304,(%esp)
  8013eb:	e8 b0 1a 00 00       	call   802ea0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8013f0:	ba 07 00 00 00       	mov    $0x7,%edx
  8013f5:	89 d0                	mov    %edx,%eax
  8013f7:	cd 30                	int    $0x30
  8013f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013fc:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8013fe:	85 c0                	test   %eax,%eax
  801400:	79 20                	jns    801422 <fork+0x47>
		panic("sys_exofork: %e", envid);
  801402:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801406:	c7 44 24 08 be 37 80 	movl   $0x8037be,0x8(%esp)
  80140d:	00 
  80140e:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801415:	00 
  801416:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  80141d:	e8 82 f1 ff ff       	call   8005a4 <_panic>
	if (envid == 0)
  801422:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801426:	75 25                	jne    80144d <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  801428:	e8 ce fb ff ff       	call   800ffb <sys_getenvid>
  80142d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801432:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801439:	c1 e0 07             	shl    $0x7,%eax
  80143c:	29 d0                	sub    %edx,%eax
  80143e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801443:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801448:	e9 43 02 00 00       	jmp    801690 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  80144d:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  801452:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801458:	0f 84 85 01 00 00    	je     8015e3 <fork+0x208>
  80145e:	89 d8                	mov    %ebx,%eax
  801460:	c1 e8 16             	shr    $0x16,%eax
  801463:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146a:	a8 01                	test   $0x1,%al
  80146c:	0f 84 5f 01 00 00    	je     8015d1 <fork+0x1f6>
  801472:	89 d8                	mov    %ebx,%eax
  801474:	c1 e8 0c             	shr    $0xc,%eax
  801477:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147e:	f6 c2 01             	test   $0x1,%dl
  801481:	0f 84 4a 01 00 00    	je     8015d1 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  801487:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  801489:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801490:	f6 c6 04             	test   $0x4,%dh
  801493:	74 50                	je     8014e5 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  801495:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149c:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014a9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b8:	e8 d0 fb ff ff       	call   80108d <sys_page_map>
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	0f 89 0c 01 00 00    	jns    8015d1 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  8014c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014c9:	c7 44 24 08 ce 37 80 	movl   $0x8037ce,0x8(%esp)
  8014d0:	00 
  8014d1:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8014d8:	00 
  8014d9:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  8014e0:	e8 bf f0 ff ff       	call   8005a4 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  8014e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014ec:	f6 c2 02             	test   $0x2,%dl
  8014ef:	75 10                	jne    801501 <fork+0x126>
  8014f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f8:	f6 c4 08             	test   $0x8,%ah
  8014fb:	0f 84 8c 00 00 00    	je     80158d <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  801501:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801508:	00 
  801509:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80150d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801511:	89 74 24 04          	mov    %esi,0x4(%esp)
  801515:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151c:	e8 6c fb ff ff       	call   80108d <sys_page_map>
  801521:	85 c0                	test   %eax,%eax
  801523:	79 20                	jns    801545 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801525:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801529:	c7 44 24 08 ce 37 80 	movl   $0x8037ce,0x8(%esp)
  801530:	00 
  801531:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801538:	00 
  801539:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  801540:	e8 5f f0 ff ff       	call   8005a4 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801545:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80154c:	00 
  80154d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801551:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801558:	00 
  801559:	89 74 24 04          	mov    %esi,0x4(%esp)
  80155d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801564:	e8 24 fb ff ff       	call   80108d <sys_page_map>
  801569:	85 c0                	test   %eax,%eax
  80156b:	79 64                	jns    8015d1 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  80156d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801571:	c7 44 24 08 ce 37 80 	movl   $0x8037ce,0x8(%esp)
  801578:	00 
  801579:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801580:	00 
  801581:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  801588:	e8 17 f0 ff ff       	call   8005a4 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  80158d:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801594:	00 
  801595:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801599:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80159d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a8:	e8 e0 fa ff ff       	call   80108d <sys_page_map>
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	79 20                	jns    8015d1 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8015b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b5:	c7 44 24 08 ce 37 80 	movl   $0x8037ce,0x8(%esp)
  8015bc:	00 
  8015bd:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8015c4:	00 
  8015c5:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  8015cc:	e8 d3 ef ff ff       	call   8005a4 <_panic>
  8015d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  8015d7:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8015dd:	0f 85 6f fe ff ff    	jne    801452 <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  8015e3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015ea:	00 
  8015eb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015f2:	ee 
  8015f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f6:	89 04 24             	mov    %eax,(%esp)
  8015f9:	e8 3b fa ff ff       	call   801039 <sys_page_alloc>
  8015fe:	85 c0                	test   %eax,%eax
  801600:	79 20                	jns    801622 <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  801602:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801606:	c7 44 24 08 e0 37 80 	movl   $0x8037e0,0x8(%esp)
  80160d:	00 
  80160e:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801615:	00 
  801616:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  80161d:	e8 82 ef ff ff       	call   8005a4 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801622:	c7 44 24 04 ec 2e 80 	movl   $0x802eec,0x4(%esp)
  801629:	00 
  80162a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80162d:	89 04 24             	mov    %eax,(%esp)
  801630:	e8 a4 fb ff ff       	call   8011d9 <sys_env_set_pgfault_upcall>
  801635:	85 c0                	test   %eax,%eax
  801637:	79 20                	jns    801659 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  801639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80163d:	c7 44 24 08 94 37 80 	movl   $0x803794,0x8(%esp)
  801644:	00 
  801645:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  80164c:	00 
  80164d:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  801654:	e8 4b ef ff ff       	call   8005a4 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801659:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801660:	00 
  801661:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801664:	89 04 24             	mov    %eax,(%esp)
  801667:	e8 c7 fa ff ff       	call   801133 <sys_env_set_status>
  80166c:	85 c0                	test   %eax,%eax
  80166e:	79 20                	jns    801690 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801670:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801674:	c7 44 24 08 f3 37 80 	movl   $0x8037f3,0x8(%esp)
  80167b:	00 
  80167c:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801683:	00 
  801684:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  80168b:	e8 14 ef ff ff       	call   8005a4 <_panic>

	return envid;
	// panic("fork not implemented");
}
  801690:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801693:	83 c4 3c             	add    $0x3c,%esp
  801696:	5b                   	pop    %ebx
  801697:	5e                   	pop    %esi
  801698:	5f                   	pop    %edi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <sfork>:

// Challenge!
int
sfork(void)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016a1:	c7 44 24 08 0a 38 80 	movl   $0x80380a,0x8(%esp)
  8016a8:	00 
  8016a9:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8016b0:	00 
  8016b1:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  8016b8:	e8 e7 ee ff ff       	call   8005a4 <_panic>
  8016bd:	00 00                	add    %al,(%eax)
	...

008016c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8016c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d9:	89 04 24             	mov    %eax,(%esp)
  8016dc:	e8 df ff ff ff       	call   8016c0 <fd2num>
  8016e1:	c1 e0 0c             	shl    $0xc,%eax
  8016e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	53                   	push   %ebx
  8016ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8016f2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016f7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	c1 ea 16             	shr    $0x16,%edx
  8016fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801705:	f6 c2 01             	test   $0x1,%dl
  801708:	74 11                	je     80171b <fd_alloc+0x30>
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	c1 ea 0c             	shr    $0xc,%edx
  80170f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801716:	f6 c2 01             	test   $0x1,%dl
  801719:	75 09                	jne    801724 <fd_alloc+0x39>
			*fd_store = fd;
  80171b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80171d:	b8 00 00 00 00       	mov    $0x0,%eax
  801722:	eb 17                	jmp    80173b <fd_alloc+0x50>
  801724:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801729:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80172e:	75 c7                	jne    8016f7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801730:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801736:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80173b:	5b                   	pop    %ebx
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801744:	83 f8 1f             	cmp    $0x1f,%eax
  801747:	77 36                	ja     80177f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801749:	c1 e0 0c             	shl    $0xc,%eax
  80174c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801751:	89 c2                	mov    %eax,%edx
  801753:	c1 ea 16             	shr    $0x16,%edx
  801756:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80175d:	f6 c2 01             	test   $0x1,%dl
  801760:	74 24                	je     801786 <fd_lookup+0x48>
  801762:	89 c2                	mov    %eax,%edx
  801764:	c1 ea 0c             	shr    $0xc,%edx
  801767:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80176e:	f6 c2 01             	test   $0x1,%dl
  801771:	74 1a                	je     80178d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801773:	8b 55 0c             	mov    0xc(%ebp),%edx
  801776:	89 02                	mov    %eax,(%edx)
	return 0;
  801778:	b8 00 00 00 00       	mov    $0x0,%eax
  80177d:	eb 13                	jmp    801792 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80177f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801784:	eb 0c                	jmp    801792 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80178b:	eb 05                	jmp    801792 <fd_lookup+0x54>
  80178d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	53                   	push   %ebx
  801798:	83 ec 14             	sub    $0x14,%esp
  80179b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8017a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a6:	eb 0e                	jmp    8017b6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8017a8:	39 08                	cmp    %ecx,(%eax)
  8017aa:	75 09                	jne    8017b5 <dev_lookup+0x21>
			*dev = devtab[i];
  8017ac:	89 03                	mov    %eax,(%ebx)
			return 0;
  8017ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b3:	eb 33                	jmp    8017e8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017b5:	42                   	inc    %edx
  8017b6:	8b 04 95 9c 38 80 00 	mov    0x80389c(,%edx,4),%eax
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	75 e7                	jne    8017a8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017c1:	a1 08 50 80 00       	mov    0x805008,%eax
  8017c6:	8b 40 48             	mov    0x48(%eax),%eax
  8017c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d1:	c7 04 24 20 38 80 00 	movl   $0x803820,(%esp)
  8017d8:	e8 bf ee ff ff       	call   80069c <cprintf>
	*dev = 0;
  8017dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8017e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017e8:	83 c4 14             	add    $0x14,%esp
  8017eb:	5b                   	pop    %ebx
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 30             	sub    $0x30,%esp
  8017f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f9:	8a 45 0c             	mov    0xc(%ebp),%al
  8017fc:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017ff:	89 34 24             	mov    %esi,(%esp)
  801802:	e8 b9 fe ff ff       	call   8016c0 <fd2num>
  801807:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80180a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 28 ff ff ff       	call   80173e <fd_lookup>
  801816:	89 c3                	mov    %eax,%ebx
  801818:	85 c0                	test   %eax,%eax
  80181a:	78 05                	js     801821 <fd_close+0x33>
	    || fd != fd2)
  80181c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80181f:	74 0d                	je     80182e <fd_close+0x40>
		return (must_exist ? r : 0);
  801821:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801825:	75 46                	jne    80186d <fd_close+0x7f>
  801827:	bb 00 00 00 00       	mov    $0x0,%ebx
  80182c:	eb 3f                	jmp    80186d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80182e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801831:	89 44 24 04          	mov    %eax,0x4(%esp)
  801835:	8b 06                	mov    (%esi),%eax
  801837:	89 04 24             	mov    %eax,(%esp)
  80183a:	e8 55 ff ff ff       	call   801794 <dev_lookup>
  80183f:	89 c3                	mov    %eax,%ebx
  801841:	85 c0                	test   %eax,%eax
  801843:	78 18                	js     80185d <fd_close+0x6f>
		if (dev->dev_close)
  801845:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801848:	8b 40 10             	mov    0x10(%eax),%eax
  80184b:	85 c0                	test   %eax,%eax
  80184d:	74 09                	je     801858 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80184f:	89 34 24             	mov    %esi,(%esp)
  801852:	ff d0                	call   *%eax
  801854:	89 c3                	mov    %eax,%ebx
  801856:	eb 05                	jmp    80185d <fd_close+0x6f>
		else
			r = 0;
  801858:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80185d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801861:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801868:	e8 73 f8 ff ff       	call   8010e0 <sys_page_unmap>
	return r;
}
  80186d:	89 d8                	mov    %ebx,%eax
  80186f:	83 c4 30             	add    $0x30,%esp
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	89 04 24             	mov    %eax,(%esp)
  801889:	e8 b0 fe ff ff       	call   80173e <fd_lookup>
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 13                	js     8018a5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801892:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801899:	00 
  80189a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189d:	89 04 24             	mov    %eax,(%esp)
  8018a0:	e8 49 ff ff ff       	call   8017ee <fd_close>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <close_all>:

void
close_all(void)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8018ae:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8018b3:	89 1c 24             	mov    %ebx,(%esp)
  8018b6:	e8 bb ff ff ff       	call   801876 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018bb:	43                   	inc    %ebx
  8018bc:	83 fb 20             	cmp    $0x20,%ebx
  8018bf:	75 f2                	jne    8018b3 <close_all+0xc>
		close(i);
}
  8018c1:	83 c4 14             	add    $0x14,%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	57                   	push   %edi
  8018cb:	56                   	push   %esi
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 4c             	sub    $0x4c,%esp
  8018d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	89 04 24             	mov    %eax,(%esp)
  8018e0:	e8 59 fe ff ff       	call   80173e <fd_lookup>
  8018e5:	89 c3                	mov    %eax,%ebx
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	0f 88 e3 00 00 00    	js     8019d2 <dup+0x10b>
		return r;
	close(newfdnum);
  8018ef:	89 3c 24             	mov    %edi,(%esp)
  8018f2:	e8 7f ff ff ff       	call   801876 <close>

	newfd = INDEX2FD(newfdnum);
  8018f7:	89 fe                	mov    %edi,%esi
  8018f9:	c1 e6 0c             	shl    $0xc,%esi
  8018fc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801902:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801905:	89 04 24             	mov    %eax,(%esp)
  801908:	e8 c3 fd ff ff       	call   8016d0 <fd2data>
  80190d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80190f:	89 34 24             	mov    %esi,(%esp)
  801912:	e8 b9 fd ff ff       	call   8016d0 <fd2data>
  801917:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80191a:	89 d8                	mov    %ebx,%eax
  80191c:	c1 e8 16             	shr    $0x16,%eax
  80191f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801926:	a8 01                	test   $0x1,%al
  801928:	74 46                	je     801970 <dup+0xa9>
  80192a:	89 d8                	mov    %ebx,%eax
  80192c:	c1 e8 0c             	shr    $0xc,%eax
  80192f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801936:	f6 c2 01             	test   $0x1,%dl
  801939:	74 35                	je     801970 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80193b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801942:	25 07 0e 00 00       	and    $0xe07,%eax
  801947:	89 44 24 10          	mov    %eax,0x10(%esp)
  80194b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80194e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801952:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801959:	00 
  80195a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80195e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801965:	e8 23 f7 ff ff       	call   80108d <sys_page_map>
  80196a:	89 c3                	mov    %eax,%ebx
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 3b                	js     8019ab <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801973:	89 c2                	mov    %eax,%edx
  801975:	c1 ea 0c             	shr    $0xc,%edx
  801978:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80197f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801985:	89 54 24 10          	mov    %edx,0x10(%esp)
  801989:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80198d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801994:	00 
  801995:	89 44 24 04          	mov    %eax,0x4(%esp)
  801999:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a0:	e8 e8 f6 ff ff       	call   80108d <sys_page_map>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	79 25                	jns    8019d0 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8019ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b6:	e8 25 f7 ff ff       	call   8010e0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8019bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c9:	e8 12 f7 ff ff       	call   8010e0 <sys_page_unmap>
	return r;
  8019ce:	eb 02                	jmp    8019d2 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8019d0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8019d2:	89 d8                	mov    %ebx,%eax
  8019d4:	83 c4 4c             	add    $0x4c,%esp
  8019d7:	5b                   	pop    %ebx
  8019d8:	5e                   	pop    %esi
  8019d9:	5f                   	pop    %edi
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	53                   	push   %ebx
  8019e0:	83 ec 24             	sub    $0x24,%esp
  8019e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ed:	89 1c 24             	mov    %ebx,(%esp)
  8019f0:	e8 49 fd ff ff       	call   80173e <fd_lookup>
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 6d                	js     801a66 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a03:	8b 00                	mov    (%eax),%eax
  801a05:	89 04 24             	mov    %eax,(%esp)
  801a08:	e8 87 fd ff ff       	call   801794 <dev_lookup>
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	78 55                	js     801a66 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a14:	8b 50 08             	mov    0x8(%eax),%edx
  801a17:	83 e2 03             	and    $0x3,%edx
  801a1a:	83 fa 01             	cmp    $0x1,%edx
  801a1d:	75 23                	jne    801a42 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a1f:	a1 08 50 80 00       	mov    0x805008,%eax
  801a24:	8b 40 48             	mov    0x48(%eax),%eax
  801a27:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2f:	c7 04 24 61 38 80 00 	movl   $0x803861,(%esp)
  801a36:	e8 61 ec ff ff       	call   80069c <cprintf>
		return -E_INVAL;
  801a3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a40:	eb 24                	jmp    801a66 <read+0x8a>
	}
	if (!dev->dev_read)
  801a42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a45:	8b 52 08             	mov    0x8(%edx),%edx
  801a48:	85 d2                	test   %edx,%edx
  801a4a:	74 15                	je     801a61 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a4f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a56:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a5a:	89 04 24             	mov    %eax,(%esp)
  801a5d:	ff d2                	call   *%edx
  801a5f:	eb 05                	jmp    801a66 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a61:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801a66:	83 c4 24             	add    $0x24,%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	57                   	push   %edi
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	83 ec 1c             	sub    $0x1c,%esp
  801a75:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a78:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a80:	eb 23                	jmp    801aa5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a82:	89 f0                	mov    %esi,%eax
  801a84:	29 d8                	sub    %ebx,%eax
  801a86:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8d:	01 d8                	add    %ebx,%eax
  801a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a93:	89 3c 24             	mov    %edi,(%esp)
  801a96:	e8 41 ff ff ff       	call   8019dc <read>
		if (m < 0)
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	78 10                	js     801aaf <readn+0x43>
			return m;
		if (m == 0)
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	74 0a                	je     801aad <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801aa3:	01 c3                	add    %eax,%ebx
  801aa5:	39 f3                	cmp    %esi,%ebx
  801aa7:	72 d9                	jb     801a82 <readn+0x16>
  801aa9:	89 d8                	mov    %ebx,%eax
  801aab:	eb 02                	jmp    801aaf <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801aad:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801aaf:	83 c4 1c             	add    $0x1c,%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5f                   	pop    %edi
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	53                   	push   %ebx
  801abb:	83 ec 24             	sub    $0x24,%esp
  801abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ac1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac8:	89 1c 24             	mov    %ebx,(%esp)
  801acb:	e8 6e fc ff ff       	call   80173e <fd_lookup>
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	78 68                	js     801b3c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ade:	8b 00                	mov    (%eax),%eax
  801ae0:	89 04 24             	mov    %eax,(%esp)
  801ae3:	e8 ac fc ff ff       	call   801794 <dev_lookup>
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	78 50                	js     801b3c <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801af3:	75 23                	jne    801b18 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801af5:	a1 08 50 80 00       	mov    0x805008,%eax
  801afa:	8b 40 48             	mov    0x48(%eax),%eax
  801afd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b05:	c7 04 24 7d 38 80 00 	movl   $0x80387d,(%esp)
  801b0c:	e8 8b eb ff ff       	call   80069c <cprintf>
		return -E_INVAL;
  801b11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b16:	eb 24                	jmp    801b3c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b1b:	8b 52 0c             	mov    0xc(%edx),%edx
  801b1e:	85 d2                	test   %edx,%edx
  801b20:	74 15                	je     801b37 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b22:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b25:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b30:	89 04 24             	mov    %eax,(%esp)
  801b33:	ff d2                	call   *%edx
  801b35:	eb 05                	jmp    801b3c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b37:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b3c:	83 c4 24             	add    $0x24,%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b48:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b52:	89 04 24             	mov    %eax,(%esp)
  801b55:	e8 e4 fb ff ff       	call   80173e <fd_lookup>
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	78 0e                	js     801b6c <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b61:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b64:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	83 ec 24             	sub    $0x24,%esp
  801b75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7f:	89 1c 24             	mov    %ebx,(%esp)
  801b82:	e8 b7 fb ff ff       	call   80173e <fd_lookup>
  801b87:	85 c0                	test   %eax,%eax
  801b89:	78 61                	js     801bec <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b95:	8b 00                	mov    (%eax),%eax
  801b97:	89 04 24             	mov    %eax,(%esp)
  801b9a:	e8 f5 fb ff ff       	call   801794 <dev_lookup>
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 49                	js     801bec <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801baa:	75 23                	jne    801bcf <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801bac:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801bb1:	8b 40 48             	mov    0x48(%eax),%eax
  801bb4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbc:	c7 04 24 40 38 80 00 	movl   $0x803840,(%esp)
  801bc3:	e8 d4 ea ff ff       	call   80069c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801bc8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bcd:	eb 1d                	jmp    801bec <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801bcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd2:	8b 52 18             	mov    0x18(%edx),%edx
  801bd5:	85 d2                	test   %edx,%edx
  801bd7:	74 0e                	je     801be7 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bdc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801be0:	89 04 24             	mov    %eax,(%esp)
  801be3:	ff d2                	call   *%edx
  801be5:	eb 05                	jmp    801bec <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801be7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801bec:	83 c4 24             	add    $0x24,%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	53                   	push   %ebx
  801bf6:	83 ec 24             	sub    $0x24,%esp
  801bf9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bfc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c03:	8b 45 08             	mov    0x8(%ebp),%eax
  801c06:	89 04 24             	mov    %eax,(%esp)
  801c09:	e8 30 fb ff ff       	call   80173e <fd_lookup>
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 52                	js     801c64 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1c:	8b 00                	mov    (%eax),%eax
  801c1e:	89 04 24             	mov    %eax,(%esp)
  801c21:	e8 6e fb ff ff       	call   801794 <dev_lookup>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 3a                	js     801c64 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c31:	74 2c                	je     801c5f <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c33:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c36:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c3d:	00 00 00 
	stat->st_isdir = 0;
  801c40:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c47:	00 00 00 
	stat->st_dev = dev;
  801c4a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c54:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c57:	89 14 24             	mov    %edx,(%esp)
  801c5a:	ff 50 14             	call   *0x14(%eax)
  801c5d:	eb 05                	jmp    801c64 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c5f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c64:	83 c4 24             	add    $0x24,%esp
  801c67:	5b                   	pop    %ebx
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	56                   	push   %esi
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c79:	00 
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	89 04 24             	mov    %eax,(%esp)
  801c80:	e8 2a 02 00 00       	call   801eaf <open>
  801c85:	89 c3                	mov    %eax,%ebx
  801c87:	85 c0                	test   %eax,%eax
  801c89:	78 1b                	js     801ca6 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c92:	89 1c 24             	mov    %ebx,(%esp)
  801c95:	e8 58 ff ff ff       	call   801bf2 <fstat>
  801c9a:	89 c6                	mov    %eax,%esi
	close(fd);
  801c9c:	89 1c 24             	mov    %ebx,(%esp)
  801c9f:	e8 d2 fb ff ff       	call   801876 <close>
	return r;
  801ca4:	89 f3                	mov    %esi,%ebx
}
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	83 c4 10             	add    $0x10,%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5e                   	pop    %esi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    
	...

00801cb0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	56                   	push   %esi
  801cb4:	53                   	push   %ebx
  801cb5:	83 ec 10             	sub    $0x10,%esp
  801cb8:	89 c3                	mov    %eax,%ebx
  801cba:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cbc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801cc3:	75 11                	jne    801cd6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cc5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ccc:	e8 36 13 00 00       	call   803007 <ipc_find_env>
  801cd1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cd6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cdd:	00 
  801cde:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ce5:	00 
  801ce6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cea:	a1 00 50 80 00       	mov    0x805000,%eax
  801cef:	89 04 24             	mov    %eax,(%esp)
  801cf2:	e8 8d 12 00 00       	call   802f84 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cf7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cfe:	00 
  801cff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0a:	e8 05 12 00 00       	call   802f14 <ipc_recv>
}
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	5b                   	pop    %ebx
  801d13:	5e                   	pop    %esi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    

00801d16 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d22:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d34:	b8 02 00 00 00       	mov    $0x2,%eax
  801d39:	e8 72 ff ff ff       	call   801cb0 <fsipc>
}
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	8b 40 0c             	mov    0xc(%eax),%eax
  801d4c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801d51:	ba 00 00 00 00       	mov    $0x0,%edx
  801d56:	b8 06 00 00 00       	mov    $0x6,%eax
  801d5b:	e8 50 ff ff ff       	call   801cb0 <fsipc>
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	53                   	push   %ebx
  801d66:	83 ec 14             	sub    $0x14,%esp
  801d69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d72:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d77:	ba 00 00 00 00       	mov    $0x0,%edx
  801d7c:	b8 05 00 00 00       	mov    $0x5,%eax
  801d81:	e8 2a ff ff ff       	call   801cb0 <fsipc>
  801d86:	85 c0                	test   %eax,%eax
  801d88:	78 2b                	js     801db5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d8a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d91:	00 
  801d92:	89 1c 24             	mov    %ebx,(%esp)
  801d95:	e8 ad ee ff ff       	call   800c47 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d9a:	a1 80 60 80 00       	mov    0x806080,%eax
  801d9f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801da5:	a1 84 60 80 00       	mov    0x806084,%eax
  801daa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db5:	83 c4 14             	add    $0x14,%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	83 ec 18             	sub    $0x18,%esp
  801dc1:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  801dc7:	8b 52 0c             	mov    0xc(%edx),%edx
  801dca:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801dd0:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801dd5:	89 c2                	mov    %eax,%edx
  801dd7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ddc:	76 05                	jbe    801de3 <devfile_write+0x28>
  801dde:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801de3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dee:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801df5:	e8 30 f0 ff ff       	call   800e2a <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801dfa:	ba 00 00 00 00       	mov    $0x0,%edx
  801dff:	b8 04 00 00 00       	mov    $0x4,%eax
  801e04:	e8 a7 fe ff ff       	call   801cb0 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    

00801e0b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	56                   	push   %esi
  801e0f:	53                   	push   %ebx
  801e10:	83 ec 10             	sub    $0x10,%esp
  801e13:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	8b 40 0c             	mov    0xc(%eax),%eax
  801e1c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e21:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e27:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2c:	b8 03 00 00 00       	mov    $0x3,%eax
  801e31:	e8 7a fe ff ff       	call   801cb0 <fsipc>
  801e36:	89 c3                	mov    %eax,%ebx
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 6a                	js     801ea6 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e3c:	39 c6                	cmp    %eax,%esi
  801e3e:	73 24                	jae    801e64 <devfile_read+0x59>
  801e40:	c7 44 24 0c b0 38 80 	movl   $0x8038b0,0xc(%esp)
  801e47:	00 
  801e48:	c7 44 24 08 b7 38 80 	movl   $0x8038b7,0x8(%esp)
  801e4f:	00 
  801e50:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e57:	00 
  801e58:	c7 04 24 cc 38 80 00 	movl   $0x8038cc,(%esp)
  801e5f:	e8 40 e7 ff ff       	call   8005a4 <_panic>
	assert(r <= PGSIZE);
  801e64:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e69:	7e 24                	jle    801e8f <devfile_read+0x84>
  801e6b:	c7 44 24 0c d7 38 80 	movl   $0x8038d7,0xc(%esp)
  801e72:	00 
  801e73:	c7 44 24 08 b7 38 80 	movl   $0x8038b7,0x8(%esp)
  801e7a:	00 
  801e7b:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801e82:	00 
  801e83:	c7 04 24 cc 38 80 00 	movl   $0x8038cc,(%esp)
  801e8a:	e8 15 e7 ff ff       	call   8005a4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e93:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e9a:	00 
  801e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9e:	89 04 24             	mov    %eax,(%esp)
  801ea1:	e8 1a ef ff ff       	call   800dc0 <memmove>
	return r;
}
  801ea6:	89 d8                	mov    %ebx,%eax
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	5b                   	pop    %ebx
  801eac:	5e                   	pop    %esi
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 20             	sub    $0x20,%esp
  801eb7:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801eba:	89 34 24             	mov    %esi,(%esp)
  801ebd:	e8 52 ed ff ff       	call   800c14 <strlen>
  801ec2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ec7:	7f 60                	jg     801f29 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecc:	89 04 24             	mov    %eax,(%esp)
  801ecf:	e8 17 f8 ff ff       	call   8016eb <fd_alloc>
  801ed4:	89 c3                	mov    %eax,%ebx
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 54                	js     801f2e <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801eda:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ede:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801ee5:	e8 5d ed ff ff       	call   800c47 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eed:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ef2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ef5:	b8 01 00 00 00       	mov    $0x1,%eax
  801efa:	e8 b1 fd ff ff       	call   801cb0 <fsipc>
  801eff:	89 c3                	mov    %eax,%ebx
  801f01:	85 c0                	test   %eax,%eax
  801f03:	79 15                	jns    801f1a <open+0x6b>
		fd_close(fd, 0);
  801f05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f0c:	00 
  801f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f10:	89 04 24             	mov    %eax,(%esp)
  801f13:	e8 d6 f8 ff ff       	call   8017ee <fd_close>
		return r;
  801f18:	eb 14                	jmp    801f2e <open+0x7f>
	}

	return fd2num(fd);
  801f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1d:	89 04 24             	mov    %eax,(%esp)
  801f20:	e8 9b f7 ff ff       	call   8016c0 <fd2num>
  801f25:	89 c3                	mov    %eax,%ebx
  801f27:	eb 05                	jmp    801f2e <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f29:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f2e:	89 d8                	mov    %ebx,%eax
  801f30:	83 c4 20             	add    $0x20,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f42:	b8 08 00 00 00       	mov    $0x8,%eax
  801f47:	e8 64 fd ff ff       	call   801cb0 <fsipc>
}
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    
	...

00801f50 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	57                   	push   %edi
  801f54:	56                   	push   %esi
  801f55:	53                   	push   %ebx
  801f56:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801f5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f63:	00 
  801f64:	8b 45 08             	mov    0x8(%ebp),%eax
  801f67:	89 04 24             	mov    %eax,(%esp)
  801f6a:	e8 40 ff ff ff       	call   801eaf <open>
  801f6f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801f75:	85 c0                	test   %eax,%eax
  801f77:	0f 88 a9 05 00 00    	js     802526 <spawn+0x5d6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801f7d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801f84:	00 
  801f85:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8f:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 cf fa ff ff       	call   801a6c <readn>
  801f9d:	3d 00 02 00 00       	cmp    $0x200,%eax
  801fa2:	75 0c                	jne    801fb0 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801fa4:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801fab:	45 4c 46 
  801fae:	74 3b                	je     801feb <spawn+0x9b>
		close(fd);
  801fb0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801fb6:	89 04 24             	mov    %eax,(%esp)
  801fb9:	e8 b8 f8 ff ff       	call   801876 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801fbe:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801fc5:	46 
  801fc6:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd0:	c7 04 24 e3 38 80 00 	movl   $0x8038e3,(%esp)
  801fd7:	e8 c0 e6 ff ff       	call   80069c <cprintf>
		return -E_NOT_EXEC;
  801fdc:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  801fe3:	ff ff ff 
  801fe6:	e9 47 05 00 00       	jmp    802532 <spawn+0x5e2>
  801feb:	ba 07 00 00 00       	mov    $0x7,%edx
  801ff0:	89 d0                	mov    %edx,%eax
  801ff2:	cd 30                	int    $0x30
  801ff4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801ffa:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802000:	85 c0                	test   %eax,%eax
  802002:	0f 88 2a 05 00 00    	js     802532 <spawn+0x5e2>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802008:	25 ff 03 00 00       	and    $0x3ff,%eax
  80200d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802014:	c1 e0 07             	shl    $0x7,%eax
  802017:	29 d0                	sub    %edx,%eax
  802019:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  80201f:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802025:	b9 11 00 00 00       	mov    $0x11,%ecx
  80202a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80202c:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802032:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802038:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80203d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802045:	eb 0d                	jmp    802054 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802047:	89 04 24             	mov    %eax,(%esp)
  80204a:	e8 c5 eb ff ff       	call   800c14 <strlen>
  80204f:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802053:	46                   	inc    %esi
  802054:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802056:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80205d:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  802060:	85 c0                	test   %eax,%eax
  802062:	75 e3                	jne    802047 <spawn+0xf7>
  802064:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80206a:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802070:	bf 00 10 40 00       	mov    $0x401000,%edi
  802075:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802077:	89 f8                	mov    %edi,%eax
  802079:	83 e0 fc             	and    $0xfffffffc,%eax
  80207c:	f7 d2                	not    %edx
  80207e:	8d 14 90             	lea    (%eax,%edx,4),%edx
  802081:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802087:	89 d0                	mov    %edx,%eax
  802089:	83 e8 08             	sub    $0x8,%eax
  80208c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802091:	0f 86 ac 04 00 00    	jbe    802543 <spawn+0x5f3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802097:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80209e:	00 
  80209f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8020a6:	00 
  8020a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ae:	e8 86 ef ff ff       	call   801039 <sys_page_alloc>
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	0f 88 8d 04 00 00    	js     802548 <spawn+0x5f8>
  8020bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c0:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8020c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c9:	eb 2e                	jmp    8020f9 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8020cb:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8020d1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8020d7:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8020da:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8020dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e1:	89 3c 24             	mov    %edi,(%esp)
  8020e4:	e8 5e eb ff ff       	call   800c47 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8020e9:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8020ec:	89 04 24             	mov    %eax,(%esp)
  8020ef:	e8 20 eb ff ff       	call   800c14 <strlen>
  8020f4:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8020f8:	43                   	inc    %ebx
  8020f9:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8020ff:	7c ca                	jl     8020cb <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802101:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802107:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80210d:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802114:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80211a:	74 24                	je     802140 <spawn+0x1f0>
  80211c:	c7 44 24 0c 40 39 80 	movl   $0x803940,0xc(%esp)
  802123:	00 
  802124:	c7 44 24 08 b7 38 80 	movl   $0x8038b7,0x8(%esp)
  80212b:	00 
  80212c:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  802133:	00 
  802134:	c7 04 24 fd 38 80 00 	movl   $0x8038fd,(%esp)
  80213b:	e8 64 e4 ff ff       	call   8005a4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802140:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802146:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80214b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802151:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802154:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80215a:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80215d:	89 d0                	mov    %edx,%eax
  80215f:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802164:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80216a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802171:	00 
  802172:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802179:	ee 
  80217a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802180:	89 44 24 08          	mov    %eax,0x8(%esp)
  802184:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80218b:	00 
  80218c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802193:	e8 f5 ee ff ff       	call   80108d <sys_page_map>
  802198:	89 c3                	mov    %eax,%ebx
  80219a:	85 c0                	test   %eax,%eax
  80219c:	78 1a                	js     8021b8 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80219e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021a5:	00 
  8021a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ad:	e8 2e ef ff ff       	call   8010e0 <sys_page_unmap>
  8021b2:	89 c3                	mov    %eax,%ebx
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	79 1f                	jns    8021d7 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8021b8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021bf:	00 
  8021c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c7:	e8 14 ef ff ff       	call   8010e0 <sys_page_unmap>
	return r;
  8021cc:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8021d2:	e9 5b 03 00 00       	jmp    802532 <spawn+0x5e2>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8021d7:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8021dd:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8021e3:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8021e9:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8021f0:	00 00 00 
  8021f3:	e9 bb 01 00 00       	jmp    8023b3 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8021f8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8021fe:	83 38 01             	cmpl   $0x1,(%eax)
  802201:	0f 85 9f 01 00 00    	jne    8023a6 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802207:	89 c2                	mov    %eax,%edx
  802209:	8b 40 18             	mov    0x18(%eax),%eax
  80220c:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  80220f:	83 f8 01             	cmp    $0x1,%eax
  802212:	19 c0                	sbb    %eax,%eax
  802214:	83 e0 fe             	and    $0xfffffffe,%eax
  802217:	83 c0 07             	add    $0x7,%eax
  80221a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802220:	8b 52 04             	mov    0x4(%edx),%edx
  802223:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802229:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80222f:	8b 40 10             	mov    0x10(%eax),%eax
  802232:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802238:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80223e:	8b 52 14             	mov    0x14(%edx),%edx
  802241:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802247:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80224d:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802250:	89 f8                	mov    %edi,%eax
  802252:	25 ff 0f 00 00       	and    $0xfff,%eax
  802257:	74 16                	je     80226f <spawn+0x31f>
		va -= i;
  802259:	29 c7                	sub    %eax,%edi
		memsz += i;
  80225b:	01 c2                	add    %eax,%edx
  80225d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802263:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802269:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80226f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802274:	e9 1f 01 00 00       	jmp    802398 <spawn+0x448>
		if (i >= filesz) {
  802279:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  80227f:	72 2b                	jb     8022ac <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802281:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802287:	89 54 24 08          	mov    %edx,0x8(%esp)
  80228b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80228f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802295:	89 04 24             	mov    %eax,(%esp)
  802298:	e8 9c ed ff ff       	call   801039 <sys_page_alloc>
  80229d:	85 c0                	test   %eax,%eax
  80229f:	0f 89 e7 00 00 00    	jns    80238c <spawn+0x43c>
  8022a5:	89 c6                	mov    %eax,%esi
  8022a7:	e9 56 02 00 00       	jmp    802502 <spawn+0x5b2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8022ac:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022b3:	00 
  8022b4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022bb:	00 
  8022bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c3:	e8 71 ed ff ff       	call   801039 <sys_page_alloc>
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	0f 88 28 02 00 00    	js     8024f8 <spawn+0x5a8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8022d0:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8022d6:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8022d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022dc:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8022e2:	89 04 24             	mov    %eax,(%esp)
  8022e5:	e8 58 f8 ff ff       	call   801b42 <seek>
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	0f 88 0a 02 00 00    	js     8024fc <spawn+0x5ac>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8022f2:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8022f8:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8022fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022ff:	76 05                	jbe    802306 <spawn+0x3b6>
  802301:	b8 00 10 00 00       	mov    $0x1000,%eax
  802306:	89 44 24 08          	mov    %eax,0x8(%esp)
  80230a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802311:	00 
  802312:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802318:	89 04 24             	mov    %eax,(%esp)
  80231b:	e8 4c f7 ff ff       	call   801a6c <readn>
  802320:	85 c0                	test   %eax,%eax
  802322:	0f 88 d8 01 00 00    	js     802500 <spawn+0x5b0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802328:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80232e:	89 54 24 10          	mov    %edx,0x10(%esp)
  802332:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802336:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80233c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802340:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802347:	00 
  802348:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80234f:	e8 39 ed ff ff       	call   80108d <sys_page_map>
  802354:	85 c0                	test   %eax,%eax
  802356:	79 20                	jns    802378 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  802358:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80235c:	c7 44 24 08 09 39 80 	movl   $0x803909,0x8(%esp)
  802363:	00 
  802364:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  80236b:	00 
  80236c:	c7 04 24 fd 38 80 00 	movl   $0x8038fd,(%esp)
  802373:	e8 2c e2 ff ff       	call   8005a4 <_panic>
			sys_page_unmap(0, UTEMP);
  802378:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80237f:	00 
  802380:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802387:	e8 54 ed ff ff       	call   8010e0 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80238c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802392:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802398:	89 de                	mov    %ebx,%esi
  80239a:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  8023a0:	0f 82 d3 fe ff ff    	jb     802279 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8023a6:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  8023ac:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  8023b3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8023ba:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  8023c0:	0f 8c 32 fe ff ff    	jl     8021f8 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8023c6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8023cc:	89 04 24             	mov    %eax,(%esp)
  8023cf:	e8 a2 f4 ff ff       	call   801876 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  8023d4:	be 00 00 00 00       	mov    $0x0,%esi
  8023d9:	eb 0c                	jmp    8023e7 <spawn+0x497>
	{
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  8023db:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8023e1:	0f 84 91 00 00 00    	je     802478 <spawn+0x528>
  8023e7:	89 f0                	mov    %esi,%eax
  8023e9:	c1 e8 16             	shr    $0x16,%eax
  8023ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8023f3:	a8 01                	test   $0x1,%al
  8023f5:	74 6f                	je     802466 <spawn+0x516>
  8023f7:	89 f0                	mov    %esi,%eax
  8023f9:	c1 e8 0c             	shr    $0xc,%eax
  8023fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802403:	f6 c2 01             	test   $0x1,%dl
  802406:	74 5e                	je     802466 <spawn+0x516>
		{
			continue;
		}
		if ((uvpt[PGNUM(addr)] & PTE_SHARE))
  802408:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80240f:	f6 c6 04             	test   $0x4,%dh
  802412:	74 52                	je     802466 <spawn+0x516>
		{
			if ((e = sys_page_map(0, (void *)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  802414:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80241b:	25 07 0e 00 00       	and    $0xe07,%eax
  802420:	89 44 24 10          	mov    %eax,0x10(%esp)
  802424:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802428:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80242e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802432:	89 74 24 04          	mov    %esi,0x4(%esp)
  802436:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80243d:	e8 4b ec ff ff       	call   80108d <sys_page_map>
  802442:	85 c0                	test   %eax,%eax
  802444:	79 20                	jns    802466 <spawn+0x516>
			{
				panic("duppage error: %e", e);
  802446:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80244a:	c7 44 24 08 ce 37 80 	movl   $0x8037ce,0x8(%esp)
  802451:	00 
  802452:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  802459:	00 
  80245a:	c7 04 24 fd 38 80 00 	movl   $0x8038fd,(%esp)
  802461:	e8 3e e1 ff ff       	call   8005a4 <_panic>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  802466:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80246c:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  802472:	0f 85 63 ff ff ff    	jne    8023db <spawn+0x48b>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802478:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80247f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802482:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80248c:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802492:	89 04 24             	mov    %eax,(%esp)
  802495:	e8 ec ec ff ff       	call   801186 <sys_env_set_trapframe>
  80249a:	85 c0                	test   %eax,%eax
  80249c:	79 20                	jns    8024be <spawn+0x56e>
		panic("sys_env_set_trapframe: %e", r);
  80249e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024a2:	c7 44 24 08 26 39 80 	movl   $0x803926,0x8(%esp)
  8024a9:	00 
  8024aa:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8024b1:	00 
  8024b2:	c7 04 24 fd 38 80 00 	movl   $0x8038fd,(%esp)
  8024b9:	e8 e6 e0 ff ff       	call   8005a4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8024be:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8024c5:	00 
  8024c6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8024cc:	89 04 24             	mov    %eax,(%esp)
  8024cf:	e8 5f ec ff ff       	call   801133 <sys_env_set_status>
  8024d4:	85 c0                	test   %eax,%eax
  8024d6:	79 5a                	jns    802532 <spawn+0x5e2>
		panic("sys_env_set_status: %e", r);
  8024d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024dc:	c7 44 24 08 f3 37 80 	movl   $0x8037f3,0x8(%esp)
  8024e3:	00 
  8024e4:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8024eb:	00 
  8024ec:	c7 04 24 fd 38 80 00 	movl   $0x8038fd,(%esp)
  8024f3:	e8 ac e0 ff ff       	call   8005a4 <_panic>
  8024f8:	89 c6                	mov    %eax,%esi
  8024fa:	eb 06                	jmp    802502 <spawn+0x5b2>
  8024fc:	89 c6                	mov    %eax,%esi
  8024fe:	eb 02                	jmp    802502 <spawn+0x5b2>
  802500:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802502:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802508:	89 04 24             	mov    %eax,(%esp)
  80250b:	e8 99 ea ff ff       	call   800fa9 <sys_env_destroy>
	close(fd);
  802510:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802516:	89 04 24             	mov    %eax,(%esp)
  802519:	e8 58 f3 ff ff       	call   801876 <close>
	return r;
  80251e:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  802524:	eb 0c                	jmp    802532 <spawn+0x5e2>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802526:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80252c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802532:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802538:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  80253e:	5b                   	pop    %ebx
  80253f:	5e                   	pop    %esi
  802540:	5f                   	pop    %edi
  802541:	5d                   	pop    %ebp
  802542:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802543:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802548:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  80254e:	eb e2                	jmp    802532 <spawn+0x5e2>

00802550 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	57                   	push   %edi
  802554:	56                   	push   %esi
  802555:	53                   	push   %ebx
  802556:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802559:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80255c:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802561:	eb 03                	jmp    802566 <spawnl+0x16>
		argc++;
  802563:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802564:	89 d0                	mov    %edx,%eax
  802566:	8d 50 04             	lea    0x4(%eax),%edx
  802569:	83 38 00             	cmpl   $0x0,(%eax)
  80256c:	75 f5                	jne    802563 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80256e:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802575:	83 e0 f0             	and    $0xfffffff0,%eax
  802578:	29 c4                	sub    %eax,%esp
  80257a:	8d 7c 24 17          	lea    0x17(%esp),%edi
  80257e:	83 e7 f0             	and    $0xfffffff0,%edi
  802581:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802583:	8b 45 0c             	mov    0xc(%ebp),%eax
  802586:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802588:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  80258f:	00 

	va_start(vl, arg0);
  802590:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802593:	b8 00 00 00 00       	mov    $0x0,%eax
  802598:	eb 09                	jmp    8025a3 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  80259a:	40                   	inc    %eax
  80259b:	8b 1a                	mov    (%edx),%ebx
  80259d:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  8025a0:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8025a3:	39 c8                	cmp    %ecx,%eax
  8025a5:	75 f3                	jne    80259a <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8025a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ae:	89 04 24             	mov    %eax,(%esp)
  8025b1:	e8 9a f9 ff ff       	call   801f50 <spawn>
}
  8025b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025b9:	5b                   	pop    %ebx
  8025ba:	5e                   	pop    %esi
  8025bb:	5f                   	pop    %edi
  8025bc:	5d                   	pop    %ebp
  8025bd:	c3                   	ret    
	...

008025c0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8025c0:	55                   	push   %ebp
  8025c1:	89 e5                	mov    %esp,%ebp
  8025c3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8025c6:	c7 44 24 04 68 39 80 	movl   $0x803968,0x4(%esp)
  8025cd:	00 
  8025ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025d1:	89 04 24             	mov    %eax,(%esp)
  8025d4:	e8 6e e6 ff ff       	call   800c47 <strcpy>
	return 0;
}
  8025d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8025de:	c9                   	leave  
  8025df:	c3                   	ret    

008025e0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8025e0:	55                   	push   %ebp
  8025e1:	89 e5                	mov    %esp,%ebp
  8025e3:	53                   	push   %ebx
  8025e4:	83 ec 14             	sub    $0x14,%esp
  8025e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8025ea:	89 1c 24             	mov    %ebx,(%esp)
  8025ed:	e8 5a 0a 00 00       	call   80304c <pageref>
  8025f2:	83 f8 01             	cmp    $0x1,%eax
  8025f5:	75 0d                	jne    802604 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8025f7:	8b 43 0c             	mov    0xc(%ebx),%eax
  8025fa:	89 04 24             	mov    %eax,(%esp)
  8025fd:	e8 1f 03 00 00       	call   802921 <nsipc_close>
  802602:	eb 05                	jmp    802609 <devsock_close+0x29>
	else
		return 0;
  802604:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802609:	83 c4 14             	add    $0x14,%esp
  80260c:	5b                   	pop    %ebx
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    

0080260f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80260f:	55                   	push   %ebp
  802610:	89 e5                	mov    %esp,%ebp
  802612:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802615:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80261c:	00 
  80261d:	8b 45 10             	mov    0x10(%ebp),%eax
  802620:	89 44 24 08          	mov    %eax,0x8(%esp)
  802624:	8b 45 0c             	mov    0xc(%ebp),%eax
  802627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80262b:	8b 45 08             	mov    0x8(%ebp),%eax
  80262e:	8b 40 0c             	mov    0xc(%eax),%eax
  802631:	89 04 24             	mov    %eax,(%esp)
  802634:	e8 e3 03 00 00       	call   802a1c <nsipc_send>
}
  802639:	c9                   	leave  
  80263a:	c3                   	ret    

0080263b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80263b:	55                   	push   %ebp
  80263c:	89 e5                	mov    %esp,%ebp
  80263e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802641:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802648:	00 
  802649:	8b 45 10             	mov    0x10(%ebp),%eax
  80264c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802650:	8b 45 0c             	mov    0xc(%ebp),%eax
  802653:	89 44 24 04          	mov    %eax,0x4(%esp)
  802657:	8b 45 08             	mov    0x8(%ebp),%eax
  80265a:	8b 40 0c             	mov    0xc(%eax),%eax
  80265d:	89 04 24             	mov    %eax,(%esp)
  802660:	e8 37 03 00 00       	call   80299c <nsipc_recv>
}
  802665:	c9                   	leave  
  802666:	c3                   	ret    

00802667 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802667:	55                   	push   %ebp
  802668:	89 e5                	mov    %esp,%ebp
  80266a:	56                   	push   %esi
  80266b:	53                   	push   %ebx
  80266c:	83 ec 20             	sub    $0x20,%esp
  80266f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802671:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802674:	89 04 24             	mov    %eax,(%esp)
  802677:	e8 6f f0 ff ff       	call   8016eb <fd_alloc>
  80267c:	89 c3                	mov    %eax,%ebx
  80267e:	85 c0                	test   %eax,%eax
  802680:	78 21                	js     8026a3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802682:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802689:	00 
  80268a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80268d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802691:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802698:	e8 9c e9 ff ff       	call   801039 <sys_page_alloc>
  80269d:	89 c3                	mov    %eax,%ebx
  80269f:	85 c0                	test   %eax,%eax
  8026a1:	79 0a                	jns    8026ad <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8026a3:	89 34 24             	mov    %esi,(%esp)
  8026a6:	e8 76 02 00 00       	call   802921 <nsipc_close>
		return r;
  8026ab:	eb 22                	jmp    8026cf <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8026ad:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8026b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026b6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8026b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026bb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8026c2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8026c5:	89 04 24             	mov    %eax,(%esp)
  8026c8:	e8 f3 ef ff ff       	call   8016c0 <fd2num>
  8026cd:	89 c3                	mov    %eax,%ebx
}
  8026cf:	89 d8                	mov    %ebx,%eax
  8026d1:	83 c4 20             	add    $0x20,%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5e                   	pop    %esi
  8026d6:	5d                   	pop    %ebp
  8026d7:	c3                   	ret    

008026d8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8026d8:	55                   	push   %ebp
  8026d9:	89 e5                	mov    %esp,%ebp
  8026db:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8026de:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8026e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026e5:	89 04 24             	mov    %eax,(%esp)
  8026e8:	e8 51 f0 ff ff       	call   80173e <fd_lookup>
  8026ed:	85 c0                	test   %eax,%eax
  8026ef:	78 17                	js     802708 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8026f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8026fa:	39 10                	cmp    %edx,(%eax)
  8026fc:	75 05                	jne    802703 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8026fe:	8b 40 0c             	mov    0xc(%eax),%eax
  802701:	eb 05                	jmp    802708 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802703:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802708:	c9                   	leave  
  802709:	c3                   	ret    

0080270a <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80270a:	55                   	push   %ebp
  80270b:	89 e5                	mov    %esp,%ebp
  80270d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802710:	8b 45 08             	mov    0x8(%ebp),%eax
  802713:	e8 c0 ff ff ff       	call   8026d8 <fd2sockid>
  802718:	85 c0                	test   %eax,%eax
  80271a:	78 1f                	js     80273b <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80271c:	8b 55 10             	mov    0x10(%ebp),%edx
  80271f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802723:	8b 55 0c             	mov    0xc(%ebp),%edx
  802726:	89 54 24 04          	mov    %edx,0x4(%esp)
  80272a:	89 04 24             	mov    %eax,(%esp)
  80272d:	e8 38 01 00 00       	call   80286a <nsipc_accept>
  802732:	85 c0                	test   %eax,%eax
  802734:	78 05                	js     80273b <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802736:	e8 2c ff ff ff       	call   802667 <alloc_sockfd>
}
  80273b:	c9                   	leave  
  80273c:	c3                   	ret    

0080273d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80273d:	55                   	push   %ebp
  80273e:	89 e5                	mov    %esp,%ebp
  802740:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802743:	8b 45 08             	mov    0x8(%ebp),%eax
  802746:	e8 8d ff ff ff       	call   8026d8 <fd2sockid>
  80274b:	85 c0                	test   %eax,%eax
  80274d:	78 16                	js     802765 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80274f:	8b 55 10             	mov    0x10(%ebp),%edx
  802752:	89 54 24 08          	mov    %edx,0x8(%esp)
  802756:	8b 55 0c             	mov    0xc(%ebp),%edx
  802759:	89 54 24 04          	mov    %edx,0x4(%esp)
  80275d:	89 04 24             	mov    %eax,(%esp)
  802760:	e8 5b 01 00 00       	call   8028c0 <nsipc_bind>
}
  802765:	c9                   	leave  
  802766:	c3                   	ret    

00802767 <shutdown>:

int
shutdown(int s, int how)
{
  802767:	55                   	push   %ebp
  802768:	89 e5                	mov    %esp,%ebp
  80276a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80276d:	8b 45 08             	mov    0x8(%ebp),%eax
  802770:	e8 63 ff ff ff       	call   8026d8 <fd2sockid>
  802775:	85 c0                	test   %eax,%eax
  802777:	78 0f                	js     802788 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802779:	8b 55 0c             	mov    0xc(%ebp),%edx
  80277c:	89 54 24 04          	mov    %edx,0x4(%esp)
  802780:	89 04 24             	mov    %eax,(%esp)
  802783:	e8 77 01 00 00       	call   8028ff <nsipc_shutdown>
}
  802788:	c9                   	leave  
  802789:	c3                   	ret    

0080278a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80278a:	55                   	push   %ebp
  80278b:	89 e5                	mov    %esp,%ebp
  80278d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802790:	8b 45 08             	mov    0x8(%ebp),%eax
  802793:	e8 40 ff ff ff       	call   8026d8 <fd2sockid>
  802798:	85 c0                	test   %eax,%eax
  80279a:	78 16                	js     8027b2 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80279c:	8b 55 10             	mov    0x10(%ebp),%edx
  80279f:	89 54 24 08          	mov    %edx,0x8(%esp)
  8027a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027aa:	89 04 24             	mov    %eax,(%esp)
  8027ad:	e8 89 01 00 00       	call   80293b <nsipc_connect>
}
  8027b2:	c9                   	leave  
  8027b3:	c3                   	ret    

008027b4 <listen>:

int
listen(int s, int backlog)
{
  8027b4:	55                   	push   %ebp
  8027b5:	89 e5                	mov    %esp,%ebp
  8027b7:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8027bd:	e8 16 ff ff ff       	call   8026d8 <fd2sockid>
  8027c2:	85 c0                	test   %eax,%eax
  8027c4:	78 0f                	js     8027d5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8027c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027cd:	89 04 24             	mov    %eax,(%esp)
  8027d0:	e8 a5 01 00 00       	call   80297a <nsipc_listen>
}
  8027d5:	c9                   	leave  
  8027d6:	c3                   	ret    

008027d7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8027d7:	55                   	push   %ebp
  8027d8:	89 e5                	mov    %esp,%ebp
  8027da:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8027dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8027e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ee:	89 04 24             	mov    %eax,(%esp)
  8027f1:	e8 99 02 00 00       	call   802a8f <nsipc_socket>
  8027f6:	85 c0                	test   %eax,%eax
  8027f8:	78 05                	js     8027ff <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8027fa:	e8 68 fe ff ff       	call   802667 <alloc_sockfd>
}
  8027ff:	c9                   	leave  
  802800:	c3                   	ret    
  802801:	00 00                	add    %al,(%eax)
	...

00802804 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802804:	55                   	push   %ebp
  802805:	89 e5                	mov    %esp,%ebp
  802807:	53                   	push   %ebx
  802808:	83 ec 14             	sub    $0x14,%esp
  80280b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80280d:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802814:	75 11                	jne    802827 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802816:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80281d:	e8 e5 07 00 00       	call   803007 <ipc_find_env>
  802822:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802827:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80282e:	00 
  80282f:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802836:	00 
  802837:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80283b:	a1 04 50 80 00       	mov    0x805004,%eax
  802840:	89 04 24             	mov    %eax,(%esp)
  802843:	e8 3c 07 00 00       	call   802f84 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802848:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80284f:	00 
  802850:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802857:	00 
  802858:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80285f:	e8 b0 06 00 00       	call   802f14 <ipc_recv>
}
  802864:	83 c4 14             	add    $0x14,%esp
  802867:	5b                   	pop    %ebx
  802868:	5d                   	pop    %ebp
  802869:	c3                   	ret    

0080286a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80286a:	55                   	push   %ebp
  80286b:	89 e5                	mov    %esp,%ebp
  80286d:	56                   	push   %esi
  80286e:	53                   	push   %ebx
  80286f:	83 ec 10             	sub    $0x10,%esp
  802872:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802875:	8b 45 08             	mov    0x8(%ebp),%eax
  802878:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80287d:	8b 06                	mov    (%esi),%eax
  80287f:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802884:	b8 01 00 00 00       	mov    $0x1,%eax
  802889:	e8 76 ff ff ff       	call   802804 <nsipc>
  80288e:	89 c3                	mov    %eax,%ebx
  802890:	85 c0                	test   %eax,%eax
  802892:	78 23                	js     8028b7 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802894:	a1 10 70 80 00       	mov    0x807010,%eax
  802899:	89 44 24 08          	mov    %eax,0x8(%esp)
  80289d:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8028a4:	00 
  8028a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028a8:	89 04 24             	mov    %eax,(%esp)
  8028ab:	e8 10 e5 ff ff       	call   800dc0 <memmove>
		*addrlen = ret->ret_addrlen;
  8028b0:	a1 10 70 80 00       	mov    0x807010,%eax
  8028b5:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8028b7:	89 d8                	mov    %ebx,%eax
  8028b9:	83 c4 10             	add    $0x10,%esp
  8028bc:	5b                   	pop    %ebx
  8028bd:	5e                   	pop    %esi
  8028be:	5d                   	pop    %ebp
  8028bf:	c3                   	ret    

008028c0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8028c0:	55                   	push   %ebp
  8028c1:	89 e5                	mov    %esp,%ebp
  8028c3:	53                   	push   %ebx
  8028c4:	83 ec 14             	sub    $0x14,%esp
  8028c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8028ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8028cd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8028d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028dd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8028e4:	e8 d7 e4 ff ff       	call   800dc0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8028e9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8028ef:	b8 02 00 00 00       	mov    $0x2,%eax
  8028f4:	e8 0b ff ff ff       	call   802804 <nsipc>
}
  8028f9:	83 c4 14             	add    $0x14,%esp
  8028fc:	5b                   	pop    %ebx
  8028fd:	5d                   	pop    %ebp
  8028fe:	c3                   	ret    

008028ff <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8028ff:	55                   	push   %ebp
  802900:	89 e5                	mov    %esp,%ebp
  802902:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802905:	8b 45 08             	mov    0x8(%ebp),%eax
  802908:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80290d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802910:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802915:	b8 03 00 00 00       	mov    $0x3,%eax
  80291a:	e8 e5 fe ff ff       	call   802804 <nsipc>
}
  80291f:	c9                   	leave  
  802920:	c3                   	ret    

00802921 <nsipc_close>:

int
nsipc_close(int s)
{
  802921:	55                   	push   %ebp
  802922:	89 e5                	mov    %esp,%ebp
  802924:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802927:	8b 45 08             	mov    0x8(%ebp),%eax
  80292a:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80292f:	b8 04 00 00 00       	mov    $0x4,%eax
  802934:	e8 cb fe ff ff       	call   802804 <nsipc>
}
  802939:	c9                   	leave  
  80293a:	c3                   	ret    

0080293b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80293b:	55                   	push   %ebp
  80293c:	89 e5                	mov    %esp,%ebp
  80293e:	53                   	push   %ebx
  80293f:	83 ec 14             	sub    $0x14,%esp
  802942:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802945:	8b 45 08             	mov    0x8(%ebp),%eax
  802948:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80294d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802951:	8b 45 0c             	mov    0xc(%ebp),%eax
  802954:	89 44 24 04          	mov    %eax,0x4(%esp)
  802958:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80295f:	e8 5c e4 ff ff       	call   800dc0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802964:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80296a:	b8 05 00 00 00       	mov    $0x5,%eax
  80296f:	e8 90 fe ff ff       	call   802804 <nsipc>
}
  802974:	83 c4 14             	add    $0x14,%esp
  802977:	5b                   	pop    %ebx
  802978:	5d                   	pop    %ebp
  802979:	c3                   	ret    

0080297a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80297a:	55                   	push   %ebp
  80297b:	89 e5                	mov    %esp,%ebp
  80297d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802980:	8b 45 08             	mov    0x8(%ebp),%eax
  802983:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802988:	8b 45 0c             	mov    0xc(%ebp),%eax
  80298b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802990:	b8 06 00 00 00       	mov    $0x6,%eax
  802995:	e8 6a fe ff ff       	call   802804 <nsipc>
}
  80299a:	c9                   	leave  
  80299b:	c3                   	ret    

0080299c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80299c:	55                   	push   %ebp
  80299d:	89 e5                	mov    %esp,%ebp
  80299f:	56                   	push   %esi
  8029a0:	53                   	push   %ebx
  8029a1:	83 ec 10             	sub    $0x10,%esp
  8029a4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8029a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8029aa:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8029af:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8029b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8029b8:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8029bd:	b8 07 00 00 00       	mov    $0x7,%eax
  8029c2:	e8 3d fe ff ff       	call   802804 <nsipc>
  8029c7:	89 c3                	mov    %eax,%ebx
  8029c9:	85 c0                	test   %eax,%eax
  8029cb:	78 46                	js     802a13 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8029cd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8029d2:	7f 04                	jg     8029d8 <nsipc_recv+0x3c>
  8029d4:	39 c6                	cmp    %eax,%esi
  8029d6:	7d 24                	jge    8029fc <nsipc_recv+0x60>
  8029d8:	c7 44 24 0c 74 39 80 	movl   $0x803974,0xc(%esp)
  8029df:	00 
  8029e0:	c7 44 24 08 b7 38 80 	movl   $0x8038b7,0x8(%esp)
  8029e7:	00 
  8029e8:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8029ef:	00 
  8029f0:	c7 04 24 89 39 80 00 	movl   $0x803989,(%esp)
  8029f7:	e8 a8 db ff ff       	call   8005a4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8029fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a00:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802a07:	00 
  802a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a0b:	89 04 24             	mov    %eax,(%esp)
  802a0e:	e8 ad e3 ff ff       	call   800dc0 <memmove>
	}

	return r;
}
  802a13:	89 d8                	mov    %ebx,%eax
  802a15:	83 c4 10             	add    $0x10,%esp
  802a18:	5b                   	pop    %ebx
  802a19:	5e                   	pop    %esi
  802a1a:	5d                   	pop    %ebp
  802a1b:	c3                   	ret    

00802a1c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802a1c:	55                   	push   %ebp
  802a1d:	89 e5                	mov    %esp,%ebp
  802a1f:	53                   	push   %ebx
  802a20:	83 ec 14             	sub    $0x14,%esp
  802a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802a26:	8b 45 08             	mov    0x8(%ebp),%eax
  802a29:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802a2e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802a34:	7e 24                	jle    802a5a <nsipc_send+0x3e>
  802a36:	c7 44 24 0c 95 39 80 	movl   $0x803995,0xc(%esp)
  802a3d:	00 
  802a3e:	c7 44 24 08 b7 38 80 	movl   $0x8038b7,0x8(%esp)
  802a45:	00 
  802a46:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802a4d:	00 
  802a4e:	c7 04 24 89 39 80 00 	movl   $0x803989,(%esp)
  802a55:	e8 4a db ff ff       	call   8005a4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802a5a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a61:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a65:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802a6c:	e8 4f e3 ff ff       	call   800dc0 <memmove>
	nsipcbuf.send.req_size = size;
  802a71:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802a77:	8b 45 14             	mov    0x14(%ebp),%eax
  802a7a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802a7f:	b8 08 00 00 00       	mov    $0x8,%eax
  802a84:	e8 7b fd ff ff       	call   802804 <nsipc>
}
  802a89:	83 c4 14             	add    $0x14,%esp
  802a8c:	5b                   	pop    %ebx
  802a8d:	5d                   	pop    %ebp
  802a8e:	c3                   	ret    

00802a8f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802a8f:	55                   	push   %ebp
  802a90:	89 e5                	mov    %esp,%ebp
  802a92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802a95:	8b 45 08             	mov    0x8(%ebp),%eax
  802a98:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802aa0:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802aa5:	8b 45 10             	mov    0x10(%ebp),%eax
  802aa8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802aad:	b8 09 00 00 00       	mov    $0x9,%eax
  802ab2:	e8 4d fd ff ff       	call   802804 <nsipc>
}
  802ab7:	c9                   	leave  
  802ab8:	c3                   	ret    
  802ab9:	00 00                	add    %al,(%eax)
	...

00802abc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802abc:	55                   	push   %ebp
  802abd:	89 e5                	mov    %esp,%ebp
  802abf:	56                   	push   %esi
  802ac0:	53                   	push   %ebx
  802ac1:	83 ec 10             	sub    $0x10,%esp
  802ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  802aca:	89 04 24             	mov    %eax,(%esp)
  802acd:	e8 fe eb ff ff       	call   8016d0 <fd2data>
  802ad2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802ad4:	c7 44 24 04 a1 39 80 	movl   $0x8039a1,0x4(%esp)
  802adb:	00 
  802adc:	89 34 24             	mov    %esi,(%esp)
  802adf:	e8 63 e1 ff ff       	call   800c47 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ae4:	8b 43 04             	mov    0x4(%ebx),%eax
  802ae7:	2b 03                	sub    (%ebx),%eax
  802ae9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802aef:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802af6:	00 00 00 
	stat->st_dev = &devpipe;
  802af9:	c7 86 88 00 00 00 58 	movl   $0x804058,0x88(%esi)
  802b00:	40 80 00 
	return 0;
}
  802b03:	b8 00 00 00 00       	mov    $0x0,%eax
  802b08:	83 c4 10             	add    $0x10,%esp
  802b0b:	5b                   	pop    %ebx
  802b0c:	5e                   	pop    %esi
  802b0d:	5d                   	pop    %ebp
  802b0e:	c3                   	ret    

00802b0f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b0f:	55                   	push   %ebp
  802b10:	89 e5                	mov    %esp,%ebp
  802b12:	53                   	push   %ebx
  802b13:	83 ec 14             	sub    $0x14,%esp
  802b16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802b1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b24:	e8 b7 e5 ff ff       	call   8010e0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b29:	89 1c 24             	mov    %ebx,(%esp)
  802b2c:	e8 9f eb ff ff       	call   8016d0 <fd2data>
  802b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b3c:	e8 9f e5 ff ff       	call   8010e0 <sys_page_unmap>
}
  802b41:	83 c4 14             	add    $0x14,%esp
  802b44:	5b                   	pop    %ebx
  802b45:	5d                   	pop    %ebp
  802b46:	c3                   	ret    

00802b47 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b47:	55                   	push   %ebp
  802b48:	89 e5                	mov    %esp,%ebp
  802b4a:	57                   	push   %edi
  802b4b:	56                   	push   %esi
  802b4c:	53                   	push   %ebx
  802b4d:	83 ec 2c             	sub    $0x2c,%esp
  802b50:	89 c7                	mov    %eax,%edi
  802b52:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b55:	a1 08 50 80 00       	mov    0x805008,%eax
  802b5a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802b5d:	89 3c 24             	mov    %edi,(%esp)
  802b60:	e8 e7 04 00 00       	call   80304c <pageref>
  802b65:	89 c6                	mov    %eax,%esi
  802b67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b6a:	89 04 24             	mov    %eax,(%esp)
  802b6d:	e8 da 04 00 00       	call   80304c <pageref>
  802b72:	39 c6                	cmp    %eax,%esi
  802b74:	0f 94 c0             	sete   %al
  802b77:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802b7a:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802b80:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b83:	39 cb                	cmp    %ecx,%ebx
  802b85:	75 08                	jne    802b8f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802b87:	83 c4 2c             	add    $0x2c,%esp
  802b8a:	5b                   	pop    %ebx
  802b8b:	5e                   	pop    %esi
  802b8c:	5f                   	pop    %edi
  802b8d:	5d                   	pop    %ebp
  802b8e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802b8f:	83 f8 01             	cmp    $0x1,%eax
  802b92:	75 c1                	jne    802b55 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b94:	8b 42 58             	mov    0x58(%edx),%eax
  802b97:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802b9e:	00 
  802b9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ba3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802ba7:	c7 04 24 a8 39 80 00 	movl   $0x8039a8,(%esp)
  802bae:	e8 e9 da ff ff       	call   80069c <cprintf>
  802bb3:	eb a0                	jmp    802b55 <_pipeisclosed+0xe>

00802bb5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802bb5:	55                   	push   %ebp
  802bb6:	89 e5                	mov    %esp,%ebp
  802bb8:	57                   	push   %edi
  802bb9:	56                   	push   %esi
  802bba:	53                   	push   %ebx
  802bbb:	83 ec 1c             	sub    $0x1c,%esp
  802bbe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802bc1:	89 34 24             	mov    %esi,(%esp)
  802bc4:	e8 07 eb ff ff       	call   8016d0 <fd2data>
  802bc9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bcb:	bf 00 00 00 00       	mov    $0x0,%edi
  802bd0:	eb 3c                	jmp    802c0e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802bd2:	89 da                	mov    %ebx,%edx
  802bd4:	89 f0                	mov    %esi,%eax
  802bd6:	e8 6c ff ff ff       	call   802b47 <_pipeisclosed>
  802bdb:	85 c0                	test   %eax,%eax
  802bdd:	75 38                	jne    802c17 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802bdf:	e8 36 e4 ff ff       	call   80101a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802be4:	8b 43 04             	mov    0x4(%ebx),%eax
  802be7:	8b 13                	mov    (%ebx),%edx
  802be9:	83 c2 20             	add    $0x20,%edx
  802bec:	39 d0                	cmp    %edx,%eax
  802bee:	73 e2                	jae    802bd2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802bf0:	8b 55 0c             	mov    0xc(%ebp),%edx
  802bf3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802bf6:	89 c2                	mov    %eax,%edx
  802bf8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802bfe:	79 05                	jns    802c05 <devpipe_write+0x50>
  802c00:	4a                   	dec    %edx
  802c01:	83 ca e0             	or     $0xffffffe0,%edx
  802c04:	42                   	inc    %edx
  802c05:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c09:	40                   	inc    %eax
  802c0a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c0d:	47                   	inc    %edi
  802c0e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c11:	75 d1                	jne    802be4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c13:	89 f8                	mov    %edi,%eax
  802c15:	eb 05                	jmp    802c1c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c17:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c1c:	83 c4 1c             	add    $0x1c,%esp
  802c1f:	5b                   	pop    %ebx
  802c20:	5e                   	pop    %esi
  802c21:	5f                   	pop    %edi
  802c22:	5d                   	pop    %ebp
  802c23:	c3                   	ret    

00802c24 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c24:	55                   	push   %ebp
  802c25:	89 e5                	mov    %esp,%ebp
  802c27:	57                   	push   %edi
  802c28:	56                   	push   %esi
  802c29:	53                   	push   %ebx
  802c2a:	83 ec 1c             	sub    $0x1c,%esp
  802c2d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c30:	89 3c 24             	mov    %edi,(%esp)
  802c33:	e8 98 ea ff ff       	call   8016d0 <fd2data>
  802c38:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c3a:	be 00 00 00 00       	mov    $0x0,%esi
  802c3f:	eb 3a                	jmp    802c7b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c41:	85 f6                	test   %esi,%esi
  802c43:	74 04                	je     802c49 <devpipe_read+0x25>
				return i;
  802c45:	89 f0                	mov    %esi,%eax
  802c47:	eb 40                	jmp    802c89 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c49:	89 da                	mov    %ebx,%edx
  802c4b:	89 f8                	mov    %edi,%eax
  802c4d:	e8 f5 fe ff ff       	call   802b47 <_pipeisclosed>
  802c52:	85 c0                	test   %eax,%eax
  802c54:	75 2e                	jne    802c84 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c56:	e8 bf e3 ff ff       	call   80101a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c5b:	8b 03                	mov    (%ebx),%eax
  802c5d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802c60:	74 df                	je     802c41 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c62:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802c67:	79 05                	jns    802c6e <devpipe_read+0x4a>
  802c69:	48                   	dec    %eax
  802c6a:	83 c8 e0             	or     $0xffffffe0,%eax
  802c6d:	40                   	inc    %eax
  802c6e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802c72:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c75:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802c78:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c7a:	46                   	inc    %esi
  802c7b:	3b 75 10             	cmp    0x10(%ebp),%esi
  802c7e:	75 db                	jne    802c5b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c80:	89 f0                	mov    %esi,%eax
  802c82:	eb 05                	jmp    802c89 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c84:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c89:	83 c4 1c             	add    $0x1c,%esp
  802c8c:	5b                   	pop    %ebx
  802c8d:	5e                   	pop    %esi
  802c8e:	5f                   	pop    %edi
  802c8f:	5d                   	pop    %ebp
  802c90:	c3                   	ret    

00802c91 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c91:	55                   	push   %ebp
  802c92:	89 e5                	mov    %esp,%ebp
  802c94:	57                   	push   %edi
  802c95:	56                   	push   %esi
  802c96:	53                   	push   %ebx
  802c97:	83 ec 3c             	sub    $0x3c,%esp
  802c9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ca0:	89 04 24             	mov    %eax,(%esp)
  802ca3:	e8 43 ea ff ff       	call   8016eb <fd_alloc>
  802ca8:	89 c3                	mov    %eax,%ebx
  802caa:	85 c0                	test   %eax,%eax
  802cac:	0f 88 45 01 00 00    	js     802df7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802cb9:	00 
  802cba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cc8:	e8 6c e3 ff ff       	call   801039 <sys_page_alloc>
  802ccd:	89 c3                	mov    %eax,%ebx
  802ccf:	85 c0                	test   %eax,%eax
  802cd1:	0f 88 20 01 00 00    	js     802df7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802cd7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802cda:	89 04 24             	mov    %eax,(%esp)
  802cdd:	e8 09 ea ff ff       	call   8016eb <fd_alloc>
  802ce2:	89 c3                	mov    %eax,%ebx
  802ce4:	85 c0                	test   %eax,%eax
  802ce6:	0f 88 f8 00 00 00    	js     802de4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cec:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802cf3:	00 
  802cf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d02:	e8 32 e3 ff ff       	call   801039 <sys_page_alloc>
  802d07:	89 c3                	mov    %eax,%ebx
  802d09:	85 c0                	test   %eax,%eax
  802d0b:	0f 88 d3 00 00 00    	js     802de4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d14:	89 04 24             	mov    %eax,(%esp)
  802d17:	e8 b4 e9 ff ff       	call   8016d0 <fd2data>
  802d1c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d1e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802d25:	00 
  802d26:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d31:	e8 03 e3 ff ff       	call   801039 <sys_page_alloc>
  802d36:	89 c3                	mov    %eax,%ebx
  802d38:	85 c0                	test   %eax,%eax
  802d3a:	0f 88 91 00 00 00    	js     802dd1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d40:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802d43:	89 04 24             	mov    %eax,(%esp)
  802d46:	e8 85 e9 ff ff       	call   8016d0 <fd2data>
  802d4b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802d52:	00 
  802d53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802d5e:	00 
  802d5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d6a:	e8 1e e3 ff ff       	call   80108d <sys_page_map>
  802d6f:	89 c3                	mov    %eax,%ebx
  802d71:	85 c0                	test   %eax,%eax
  802d73:	78 4c                	js     802dc1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d75:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802d7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d7e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802d80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d83:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d8a:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802d90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802d93:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d95:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802d98:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802da2:	89 04 24             	mov    %eax,(%esp)
  802da5:	e8 16 e9 ff ff       	call   8016c0 <fd2num>
  802daa:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802dac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802daf:	89 04 24             	mov    %eax,(%esp)
  802db2:	e8 09 e9 ff ff       	call   8016c0 <fd2num>
  802db7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802dba:	bb 00 00 00 00       	mov    $0x0,%ebx
  802dbf:	eb 36                	jmp    802df7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802dc1:	89 74 24 04          	mov    %esi,0x4(%esp)
  802dc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802dcc:	e8 0f e3 ff ff       	call   8010e0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802dd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ddf:	e8 fc e2 ff ff       	call   8010e0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802de7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802deb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802df2:	e8 e9 e2 ff ff       	call   8010e0 <sys_page_unmap>
    err:
	return r;
}
  802df7:	89 d8                	mov    %ebx,%eax
  802df9:	83 c4 3c             	add    $0x3c,%esp
  802dfc:	5b                   	pop    %ebx
  802dfd:	5e                   	pop    %esi
  802dfe:	5f                   	pop    %edi
  802dff:	5d                   	pop    %ebp
  802e00:	c3                   	ret    

00802e01 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e01:	55                   	push   %ebp
  802e02:	89 e5                	mov    %esp,%ebp
  802e04:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  802e11:	89 04 24             	mov    %eax,(%esp)
  802e14:	e8 25 e9 ff ff       	call   80173e <fd_lookup>
  802e19:	85 c0                	test   %eax,%eax
  802e1b:	78 15                	js     802e32 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e20:	89 04 24             	mov    %eax,(%esp)
  802e23:	e8 a8 e8 ff ff       	call   8016d0 <fd2data>
	return _pipeisclosed(fd, p);
  802e28:	89 c2                	mov    %eax,%edx
  802e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e2d:	e8 15 fd ff ff       	call   802b47 <_pipeisclosed>
}
  802e32:	c9                   	leave  
  802e33:	c3                   	ret    

00802e34 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e34:	55                   	push   %ebp
  802e35:	89 e5                	mov    %esp,%ebp
  802e37:	56                   	push   %esi
  802e38:	53                   	push   %ebx
  802e39:	83 ec 10             	sub    $0x10,%esp
  802e3c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e3f:	85 f6                	test   %esi,%esi
  802e41:	75 24                	jne    802e67 <wait+0x33>
  802e43:	c7 44 24 0c c0 39 80 	movl   $0x8039c0,0xc(%esp)
  802e4a:	00 
  802e4b:	c7 44 24 08 b7 38 80 	movl   $0x8038b7,0x8(%esp)
  802e52:	00 
  802e53:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802e5a:	00 
  802e5b:	c7 04 24 cb 39 80 00 	movl   $0x8039cb,(%esp)
  802e62:	e8 3d d7 ff ff       	call   8005a4 <_panic>
	e = &envs[ENVX(envid)];
  802e67:	89 f3                	mov    %esi,%ebx
  802e69:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802e6f:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  802e76:	c1 e3 07             	shl    $0x7,%ebx
  802e79:	29 c3                	sub    %eax,%ebx
  802e7b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e81:	eb 05                	jmp    802e88 <wait+0x54>
		sys_yield();
  802e83:	e8 92 e1 ff ff       	call   80101a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e88:	8b 43 48             	mov    0x48(%ebx),%eax
  802e8b:	39 f0                	cmp    %esi,%eax
  802e8d:	75 07                	jne    802e96 <wait+0x62>
  802e8f:	8b 43 54             	mov    0x54(%ebx),%eax
  802e92:	85 c0                	test   %eax,%eax
  802e94:	75 ed                	jne    802e83 <wait+0x4f>
		sys_yield();
}
  802e96:	83 c4 10             	add    $0x10,%esp
  802e99:	5b                   	pop    %ebx
  802e9a:	5e                   	pop    %esi
  802e9b:	5d                   	pop    %ebp
  802e9c:	c3                   	ret    
  802e9d:	00 00                	add    %al,(%eax)
	...

00802ea0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ea0:	55                   	push   %ebp
  802ea1:	89 e5                	mov    %esp,%ebp
  802ea3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802ea6:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802ead:	75 30                	jne    802edf <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  802eaf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802eb6:	00 
  802eb7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802ebe:	ee 
  802ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ec6:	e8 6e e1 ff ff       	call   801039 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802ecb:	c7 44 24 04 ec 2e 80 	movl   $0x802eec,0x4(%esp)
  802ed2:	00 
  802ed3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802eda:	e8 fa e2 ff ff       	call   8011d9 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802edf:	8b 45 08             	mov    0x8(%ebp),%eax
  802ee2:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802ee7:	c9                   	leave  
  802ee8:	c3                   	ret    
  802ee9:	00 00                	add    %al,(%eax)
	...

00802eec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802eec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802eed:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802ef2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ef4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  802ef7:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802efb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802eff:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  802f02:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802f04:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802f08:	83 c4 08             	add    $0x8,%esp
	popal
  802f0b:	61                   	popa   

	addl $4,%esp 
  802f0c:	83 c4 04             	add    $0x4,%esp
	popfl
  802f0f:	9d                   	popf   

	popl %esp
  802f10:	5c                   	pop    %esp

	ret
  802f11:	c3                   	ret    
	...

00802f14 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f14:	55                   	push   %ebp
  802f15:	89 e5                	mov    %esp,%ebp
  802f17:	56                   	push   %esi
  802f18:	53                   	push   %ebx
  802f19:	83 ec 10             	sub    $0x10,%esp
  802f1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f22:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802f25:	85 c0                	test   %eax,%eax
  802f27:	74 0a                	je     802f33 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802f29:	89 04 24             	mov    %eax,(%esp)
  802f2c:	e8 1e e3 ff ff       	call   80124f <sys_ipc_recv>
  802f31:	eb 0c                	jmp    802f3f <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802f33:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802f3a:	e8 10 e3 ff ff       	call   80124f <sys_ipc_recv>
	}
	if (r < 0)
  802f3f:	85 c0                	test   %eax,%eax
  802f41:	79 16                	jns    802f59 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802f43:	85 db                	test   %ebx,%ebx
  802f45:	74 06                	je     802f4d <ipc_recv+0x39>
  802f47:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802f4d:	85 f6                	test   %esi,%esi
  802f4f:	74 2c                	je     802f7d <ipc_recv+0x69>
  802f51:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802f57:	eb 24                	jmp    802f7d <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802f59:	85 db                	test   %ebx,%ebx
  802f5b:	74 0a                	je     802f67 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802f5d:	a1 08 50 80 00       	mov    0x805008,%eax
  802f62:	8b 40 74             	mov    0x74(%eax),%eax
  802f65:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802f67:	85 f6                	test   %esi,%esi
  802f69:	74 0a                	je     802f75 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802f6b:	a1 08 50 80 00       	mov    0x805008,%eax
  802f70:	8b 40 78             	mov    0x78(%eax),%eax
  802f73:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802f75:	a1 08 50 80 00       	mov    0x805008,%eax
  802f7a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802f7d:	83 c4 10             	add    $0x10,%esp
  802f80:	5b                   	pop    %ebx
  802f81:	5e                   	pop    %esi
  802f82:	5d                   	pop    %ebp
  802f83:	c3                   	ret    

00802f84 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802f84:	55                   	push   %ebp
  802f85:	89 e5                	mov    %esp,%ebp
  802f87:	57                   	push   %edi
  802f88:	56                   	push   %esi
  802f89:	53                   	push   %ebx
  802f8a:	83 ec 1c             	sub    $0x1c,%esp
  802f8d:	8b 75 08             	mov    0x8(%ebp),%esi
  802f90:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802f93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802f96:	85 db                	test   %ebx,%ebx
  802f98:	74 19                	je     802fb3 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802f9a:	8b 45 14             	mov    0x14(%ebp),%eax
  802f9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802fa1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802fa5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802fa9:	89 34 24             	mov    %esi,(%esp)
  802fac:	e8 7b e2 ff ff       	call   80122c <sys_ipc_try_send>
  802fb1:	eb 1c                	jmp    802fcf <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802fb3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802fba:	00 
  802fbb:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802fc2:	ee 
  802fc3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802fc7:	89 34 24             	mov    %esi,(%esp)
  802fca:	e8 5d e2 ff ff       	call   80122c <sys_ipc_try_send>
		}
		if (r == 0)
  802fcf:	85 c0                	test   %eax,%eax
  802fd1:	74 2c                	je     802fff <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802fd3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802fd6:	74 20                	je     802ff8 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802fd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802fdc:	c7 44 24 08 d6 39 80 	movl   $0x8039d6,0x8(%esp)
  802fe3:	00 
  802fe4:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802feb:	00 
  802fec:	c7 04 24 e9 39 80 00 	movl   $0x8039e9,(%esp)
  802ff3:	e8 ac d5 ff ff       	call   8005a4 <_panic>
		}
		sys_yield();
  802ff8:	e8 1d e0 ff ff       	call   80101a <sys_yield>
	}
  802ffd:	eb 97                	jmp    802f96 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802fff:	83 c4 1c             	add    $0x1c,%esp
  803002:	5b                   	pop    %ebx
  803003:	5e                   	pop    %esi
  803004:	5f                   	pop    %edi
  803005:	5d                   	pop    %ebp
  803006:	c3                   	ret    

00803007 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803007:	55                   	push   %ebp
  803008:	89 e5                	mov    %esp,%ebp
  80300a:	53                   	push   %ebx
  80300b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80300e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803013:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80301a:	89 c2                	mov    %eax,%edx
  80301c:	c1 e2 07             	shl    $0x7,%edx
  80301f:	29 ca                	sub    %ecx,%edx
  803021:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803027:	8b 52 50             	mov    0x50(%edx),%edx
  80302a:	39 da                	cmp    %ebx,%edx
  80302c:	75 0f                	jne    80303d <ipc_find_env+0x36>
			return envs[i].env_id;
  80302e:	c1 e0 07             	shl    $0x7,%eax
  803031:	29 c8                	sub    %ecx,%eax
  803033:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803038:	8b 40 40             	mov    0x40(%eax),%eax
  80303b:	eb 0c                	jmp    803049 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80303d:	40                   	inc    %eax
  80303e:	3d 00 04 00 00       	cmp    $0x400,%eax
  803043:	75 ce                	jne    803013 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803045:	66 b8 00 00          	mov    $0x0,%ax
}
  803049:	5b                   	pop    %ebx
  80304a:	5d                   	pop    %ebp
  80304b:	c3                   	ret    

0080304c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80304c:	55                   	push   %ebp
  80304d:	89 e5                	mov    %esp,%ebp
  80304f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803052:	89 c2                	mov    %eax,%edx
  803054:	c1 ea 16             	shr    $0x16,%edx
  803057:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80305e:	f6 c2 01             	test   $0x1,%dl
  803061:	74 1e                	je     803081 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  803063:	c1 e8 0c             	shr    $0xc,%eax
  803066:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80306d:	a8 01                	test   $0x1,%al
  80306f:	74 17                	je     803088 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803071:	c1 e8 0c             	shr    $0xc,%eax
  803074:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80307b:	ef 
  80307c:	0f b7 c0             	movzwl %ax,%eax
  80307f:	eb 0c                	jmp    80308d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  803081:	b8 00 00 00 00       	mov    $0x0,%eax
  803086:	eb 05                	jmp    80308d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  803088:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80308d:	5d                   	pop    %ebp
  80308e:	c3                   	ret    
	...

00803090 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  803090:	55                   	push   %ebp
  803091:	57                   	push   %edi
  803092:	56                   	push   %esi
  803093:	83 ec 10             	sub    $0x10,%esp
  803096:	8b 74 24 20          	mov    0x20(%esp),%esi
  80309a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80309e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8030a2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8030a6:	89 cd                	mov    %ecx,%ebp
  8030a8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8030ac:	85 c0                	test   %eax,%eax
  8030ae:	75 2c                	jne    8030dc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8030b0:	39 f9                	cmp    %edi,%ecx
  8030b2:	77 68                	ja     80311c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8030b4:	85 c9                	test   %ecx,%ecx
  8030b6:	75 0b                	jne    8030c3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8030b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8030bd:	31 d2                	xor    %edx,%edx
  8030bf:	f7 f1                	div    %ecx
  8030c1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8030c3:	31 d2                	xor    %edx,%edx
  8030c5:	89 f8                	mov    %edi,%eax
  8030c7:	f7 f1                	div    %ecx
  8030c9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8030cb:	89 f0                	mov    %esi,%eax
  8030cd:	f7 f1                	div    %ecx
  8030cf:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8030d1:	89 f0                	mov    %esi,%eax
  8030d3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8030d5:	83 c4 10             	add    $0x10,%esp
  8030d8:	5e                   	pop    %esi
  8030d9:	5f                   	pop    %edi
  8030da:	5d                   	pop    %ebp
  8030db:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8030dc:	39 f8                	cmp    %edi,%eax
  8030de:	77 2c                	ja     80310c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8030e0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8030e3:	83 f6 1f             	xor    $0x1f,%esi
  8030e6:	75 4c                	jne    803134 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8030e8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8030ea:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8030ef:	72 0a                	jb     8030fb <__udivdi3+0x6b>
  8030f1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8030f5:	0f 87 ad 00 00 00    	ja     8031a8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8030fb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803100:	89 f0                	mov    %esi,%eax
  803102:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803104:	83 c4 10             	add    $0x10,%esp
  803107:	5e                   	pop    %esi
  803108:	5f                   	pop    %edi
  803109:	5d                   	pop    %ebp
  80310a:	c3                   	ret    
  80310b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80310c:	31 ff                	xor    %edi,%edi
  80310e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803110:	89 f0                	mov    %esi,%eax
  803112:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803114:	83 c4 10             	add    $0x10,%esp
  803117:	5e                   	pop    %esi
  803118:	5f                   	pop    %edi
  803119:	5d                   	pop    %ebp
  80311a:	c3                   	ret    
  80311b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80311c:	89 fa                	mov    %edi,%edx
  80311e:	89 f0                	mov    %esi,%eax
  803120:	f7 f1                	div    %ecx
  803122:	89 c6                	mov    %eax,%esi
  803124:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803126:	89 f0                	mov    %esi,%eax
  803128:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80312a:	83 c4 10             	add    $0x10,%esp
  80312d:	5e                   	pop    %esi
  80312e:	5f                   	pop    %edi
  80312f:	5d                   	pop    %ebp
  803130:	c3                   	ret    
  803131:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803134:	89 f1                	mov    %esi,%ecx
  803136:	d3 e0                	shl    %cl,%eax
  803138:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80313c:	b8 20 00 00 00       	mov    $0x20,%eax
  803141:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  803143:	89 ea                	mov    %ebp,%edx
  803145:	88 c1                	mov    %al,%cl
  803147:	d3 ea                	shr    %cl,%edx
  803149:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80314d:	09 ca                	or     %ecx,%edx
  80314f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  803153:	89 f1                	mov    %esi,%ecx
  803155:	d3 e5                	shl    %cl,%ebp
  803157:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80315b:	89 fd                	mov    %edi,%ebp
  80315d:	88 c1                	mov    %al,%cl
  80315f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  803161:	89 fa                	mov    %edi,%edx
  803163:	89 f1                	mov    %esi,%ecx
  803165:	d3 e2                	shl    %cl,%edx
  803167:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80316b:	88 c1                	mov    %al,%cl
  80316d:	d3 ef                	shr    %cl,%edi
  80316f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803171:	89 f8                	mov    %edi,%eax
  803173:	89 ea                	mov    %ebp,%edx
  803175:	f7 74 24 08          	divl   0x8(%esp)
  803179:	89 d1                	mov    %edx,%ecx
  80317b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80317d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803181:	39 d1                	cmp    %edx,%ecx
  803183:	72 17                	jb     80319c <__udivdi3+0x10c>
  803185:	74 09                	je     803190 <__udivdi3+0x100>
  803187:	89 fe                	mov    %edi,%esi
  803189:	31 ff                	xor    %edi,%edi
  80318b:	e9 41 ff ff ff       	jmp    8030d1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  803190:	8b 54 24 04          	mov    0x4(%esp),%edx
  803194:	89 f1                	mov    %esi,%ecx
  803196:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803198:	39 c2                	cmp    %eax,%edx
  80319a:	73 eb                	jae    803187 <__udivdi3+0xf7>
		{
		  q0--;
  80319c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80319f:	31 ff                	xor    %edi,%edi
  8031a1:	e9 2b ff ff ff       	jmp    8030d1 <__udivdi3+0x41>
  8031a6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8031a8:	31 f6                	xor    %esi,%esi
  8031aa:	e9 22 ff ff ff       	jmp    8030d1 <__udivdi3+0x41>
	...

008031b0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8031b0:	55                   	push   %ebp
  8031b1:	57                   	push   %edi
  8031b2:	56                   	push   %esi
  8031b3:	83 ec 20             	sub    $0x20,%esp
  8031b6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8031ba:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8031be:	89 44 24 14          	mov    %eax,0x14(%esp)
  8031c2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8031c6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8031ca:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8031ce:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8031d0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8031d2:	85 ed                	test   %ebp,%ebp
  8031d4:	75 16                	jne    8031ec <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8031d6:	39 f1                	cmp    %esi,%ecx
  8031d8:	0f 86 a6 00 00 00    	jbe    803284 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8031de:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8031e0:	89 d0                	mov    %edx,%eax
  8031e2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8031e4:	83 c4 20             	add    $0x20,%esp
  8031e7:	5e                   	pop    %esi
  8031e8:	5f                   	pop    %edi
  8031e9:	5d                   	pop    %ebp
  8031ea:	c3                   	ret    
  8031eb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8031ec:	39 f5                	cmp    %esi,%ebp
  8031ee:	0f 87 ac 00 00 00    	ja     8032a0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8031f4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8031f7:	83 f0 1f             	xor    $0x1f,%eax
  8031fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8031fe:	0f 84 a8 00 00 00    	je     8032ac <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803204:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803208:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80320a:	bf 20 00 00 00       	mov    $0x20,%edi
  80320f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  803213:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803217:	89 f9                	mov    %edi,%ecx
  803219:	d3 e8                	shr    %cl,%eax
  80321b:	09 e8                	or     %ebp,%eax
  80321d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803221:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803225:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803229:	d3 e0                	shl    %cl,%eax
  80322b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80322f:	89 f2                	mov    %esi,%edx
  803231:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  803233:	8b 44 24 14          	mov    0x14(%esp),%eax
  803237:	d3 e0                	shl    %cl,%eax
  803239:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80323d:	8b 44 24 14          	mov    0x14(%esp),%eax
  803241:	89 f9                	mov    %edi,%ecx
  803243:	d3 e8                	shr    %cl,%eax
  803245:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  803247:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803249:	89 f2                	mov    %esi,%edx
  80324b:	f7 74 24 18          	divl   0x18(%esp)
  80324f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803251:	f7 64 24 0c          	mull   0xc(%esp)
  803255:	89 c5                	mov    %eax,%ebp
  803257:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803259:	39 d6                	cmp    %edx,%esi
  80325b:	72 67                	jb     8032c4 <__umoddi3+0x114>
  80325d:	74 75                	je     8032d4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80325f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803263:	29 e8                	sub    %ebp,%eax
  803265:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  803267:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80326b:	d3 e8                	shr    %cl,%eax
  80326d:	89 f2                	mov    %esi,%edx
  80326f:	89 f9                	mov    %edi,%ecx
  803271:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  803273:	09 d0                	or     %edx,%eax
  803275:	89 f2                	mov    %esi,%edx
  803277:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80327b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80327d:	83 c4 20             	add    $0x20,%esp
  803280:	5e                   	pop    %esi
  803281:	5f                   	pop    %edi
  803282:	5d                   	pop    %ebp
  803283:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803284:	85 c9                	test   %ecx,%ecx
  803286:	75 0b                	jne    803293 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803288:	b8 01 00 00 00       	mov    $0x1,%eax
  80328d:	31 d2                	xor    %edx,%edx
  80328f:	f7 f1                	div    %ecx
  803291:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803293:	89 f0                	mov    %esi,%eax
  803295:	31 d2                	xor    %edx,%edx
  803297:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803299:	89 f8                	mov    %edi,%eax
  80329b:	e9 3e ff ff ff       	jmp    8031de <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8032a0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032a2:	83 c4 20             	add    $0x20,%esp
  8032a5:	5e                   	pop    %esi
  8032a6:	5f                   	pop    %edi
  8032a7:	5d                   	pop    %ebp
  8032a8:	c3                   	ret    
  8032a9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8032ac:	39 f5                	cmp    %esi,%ebp
  8032ae:	72 04                	jb     8032b4 <__umoddi3+0x104>
  8032b0:	39 f9                	cmp    %edi,%ecx
  8032b2:	77 06                	ja     8032ba <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8032b4:	89 f2                	mov    %esi,%edx
  8032b6:	29 cf                	sub    %ecx,%edi
  8032b8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8032ba:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032bc:	83 c4 20             	add    $0x20,%esp
  8032bf:	5e                   	pop    %esi
  8032c0:	5f                   	pop    %edi
  8032c1:	5d                   	pop    %ebp
  8032c2:	c3                   	ret    
  8032c3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8032c4:	89 d1                	mov    %edx,%ecx
  8032c6:	89 c5                	mov    %eax,%ebp
  8032c8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8032cc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8032d0:	eb 8d                	jmp    80325f <__umoddi3+0xaf>
  8032d2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8032d4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8032d8:	72 ea                	jb     8032c4 <__umoddi3+0x114>
  8032da:	89 f1                	mov    %esi,%ecx
  8032dc:	eb 81                	jmp    80325f <__umoddi3+0xaf>
