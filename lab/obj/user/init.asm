
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 b3 03 00 00       	call   8003e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800044:	ba 00 00 00 00       	mov    $0x0,%edx
  800049:	eb 0a                	jmp    800055 <sum+0x21>
		tot ^= i * s[i];
  80004b:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004f:	0f af ca             	imul   %edx,%ecx
  800052:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800054:	42                   	inc    %edx
  800055:	39 da                	cmp    %ebx,%edx
  800057:	7c f2                	jl     80004b <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  800059:	5b                   	pop    %ebx
  80005a:	5e                   	pop    %esi
  80005b:	5d                   	pop    %ebp
  80005c:	c3                   	ret    

0080005d <umain>:

void
umain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800069:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006c:	c7 04 24 60 2d 80 00 	movl   $0x802d60,(%esp)
  800073:	e8 d4 04 00 00       	call   80054c <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800078:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <sum>
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 1a                	je     8000ad <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  80009a:	00 
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 28 2e 80 00 	movl   $0x802e28,(%esp)
  8000a6:	e8 a1 04 00 00       	call   80054c <cprintf>
  8000ab:	eb 0c                	jmp    8000b9 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ad:	c7 04 24 6f 2d 80 00 	movl   $0x802d6f,(%esp)
  8000b4:	e8 93 04 00 00       	call   80054c <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000b9:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000c0:	00 
  8000c1:	c7 04 24 20 60 80 00 	movl   $0x806020,(%esp)
  8000c8:	e8 67 ff ff ff       	call   800034 <sum>
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 12                	je     8000e3 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d5:	c7 04 24 64 2e 80 00 	movl   $0x802e64,(%esp)
  8000dc:	e8 6b 04 00 00       	call   80054c <cprintf>
  8000e1:	eb 0c                	jmp    8000ef <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000e3:	c7 04 24 86 2d 80 00 	movl   $0x802d86,(%esp)
  8000ea:	e8 5d 04 00 00       	call   80054c <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ef:	c7 44 24 04 9c 2d 80 	movl   $0x802d9c,0x4(%esp)
  8000f6:	00 
  8000f7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000fd:	89 04 24             	mov    %eax,(%esp)
  800100:	e8 0f 0a 00 00       	call   800b14 <strcat>
	for (i = 0; i < argc; i++) {
  800105:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  80010a:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800110:	eb 30                	jmp    800142 <umain+0xe5>
		strcat(args, " '");
  800112:	c7 44 24 04 a8 2d 80 	movl   $0x802da8,0x4(%esp)
  800119:	00 
  80011a:	89 34 24             	mov    %esi,(%esp)
  80011d:	e8 f2 09 00 00       	call   800b14 <strcat>
		strcat(args, argv[i]);
  800122:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	89 34 24             	mov    %esi,(%esp)
  80012c:	e8 e3 09 00 00       	call   800b14 <strcat>
		strcat(args, "'");
  800131:	c7 44 24 04 a9 2d 80 	movl   $0x802da9,0x4(%esp)
  800138:	00 
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 d3 09 00 00       	call   800b14 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800141:	43                   	inc    %ebx
  800142:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800145:	7c cb                	jl     800112 <umain+0xb5>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800147:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 ab 2d 80 00 	movl   $0x802dab,(%esp)
  800158:	e8 ef 03 00 00       	call   80054c <cprintf>

	cprintf("init: running sh\n");
  80015d:	c7 04 24 af 2d 80 00 	movl   $0x802daf,(%esp)
  800164:	e8 e3 03 00 00       	call   80054c <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800170:	e8 f5 11 00 00       	call   80136a <close>
	if ((r = opencons()) < 0)
  800175:	e8 16 02 00 00       	call   800390 <opencons>
  80017a:	85 c0                	test   %eax,%eax
  80017c:	79 20                	jns    80019e <umain+0x141>
		panic("opencons: %e", r);
  80017e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800182:	c7 44 24 08 c1 2d 80 	movl   $0x802dc1,0x8(%esp)
  800189:	00 
  80018a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800191:	00 
  800192:	c7 04 24 ce 2d 80 00 	movl   $0x802dce,(%esp)
  800199:	e8 b6 02 00 00       	call   800454 <_panic>
	if (r != 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	74 20                	je     8001c2 <umain+0x165>
		panic("first opencons used fd %d", r);
  8001a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a6:	c7 44 24 08 da 2d 80 	movl   $0x802dda,0x8(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001b5:	00 
  8001b6:	c7 04 24 ce 2d 80 00 	movl   $0x802dce,(%esp)
  8001bd:	e8 92 02 00 00       	call   800454 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c9:	00 
  8001ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001d1:	e8 e5 11 00 00       	call   8013bb <dup>
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	79 20                	jns    8001fa <umain+0x19d>
		panic("dup: %e", r);
  8001da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001de:	c7 44 24 08 f4 2d 80 	movl   $0x802df4,0x8(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8001ed:	00 
  8001ee:	c7 04 24 ce 2d 80 00 	movl   $0x802dce,(%esp)
  8001f5:	e8 5a 02 00 00       	call   800454 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001fa:	c7 04 24 fc 2d 80 00 	movl   $0x802dfc,(%esp)
  800201:	e8 46 03 00 00       	call   80054c <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800206:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 10 2e 80 	movl   $0x802e10,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 0f 2e 80 00 	movl   $0x802e0f,(%esp)
  80021d:	e8 22 1e 00 00       	call   802044 <spawnl>
		if (r < 0) {
  800222:	85 c0                	test   %eax,%eax
  800224:	79 12                	jns    800238 <umain+0x1db>
			cprintf("init: spawn sh: %e\n", r);
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	c7 04 24 13 2e 80 00 	movl   $0x802e13,(%esp)
  800231:	e8 16 03 00 00       	call   80054c <cprintf>
			continue;
  800236:	eb c2                	jmp    8001fa <umain+0x19d>
		}
		wait(r);
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 e8 26 00 00       	call   802928 <wait>
  800240:	eb b8                	jmp    8001fa <umain+0x19d>
	...

00800244 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800247:	b8 00 00 00 00       	mov    $0x0,%eax
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800254:	c7 44 24 04 93 2e 80 	movl   $0x802e93,0x4(%esp)
  80025b:	00 
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 90 08 00 00       	call   800af7 <strcpy>
	return 0;
}
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	57                   	push   %edi
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80027f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800285:	eb 30                	jmp    8002b7 <devcons_write+0x49>
		m = n - tot;
  800287:	8b 75 10             	mov    0x10(%ebp),%esi
  80028a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80028c:	83 fe 7f             	cmp    $0x7f,%esi
  80028f:	76 05                	jbe    800296 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800291:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800296:	89 74 24 08          	mov    %esi,0x8(%esp)
  80029a:	03 45 0c             	add    0xc(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	89 3c 24             	mov    %edi,(%esp)
  8002a4:	e8 c7 09 00 00       	call   800c70 <memmove>
		sys_cputs(buf, m);
  8002a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ad:	89 3c 24             	mov    %edi,(%esp)
  8002b0:	e8 67 0b 00 00       	call   800e1c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002b5:	01 f3                	add    %esi,%ebx
  8002b7:	89 d8                	mov    %ebx,%eax
  8002b9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8002bc:	72 c9                	jb     800287 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002be:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8002cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002d3:	75 07                	jne    8002dc <devcons_read+0x13>
  8002d5:	eb 25                	jmp    8002fc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002d7:	e8 ee 0b 00 00       	call   800eca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002dc:	e8 59 0b 00 00       	call   800e3a <sys_cgetc>
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	74 f2                	je     8002d7 <devcons_read+0xe>
  8002e5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	78 1d                	js     800308 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002eb:	83 f8 04             	cmp    $0x4,%eax
  8002ee:	74 13                	je     800303 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	88 10                	mov    %dl,(%eax)
	return 1;
  8002f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8002fa:	eb 0c                	jmp    800308 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8002fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800301:	eb 05                	jmp    800308 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800303:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800316:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80031d:	00 
  80031e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 f3 0a 00 00       	call   800e1c <sys_cputs>
}
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <getchar>:

int
getchar(void)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800331:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800338:	00 
  800339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80033c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800347:	e8 84 11 00 00       	call   8014d0 <read>
	if (r < 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	78 0f                	js     80035f <getchar+0x34>
		return r;
	if (r < 1)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 06                	jle    80035a <getchar+0x2f>
		return -E_EOF;
	return c;
  800354:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800358:	eb 05                	jmp    80035f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80035a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80036a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	e8 b9 0e 00 00       	call   801232 <fd_lookup>
  800379:	85 c0                	test   %eax,%eax
  80037b:	78 11                	js     80038e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80037d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800380:	8b 15 70 57 80 00    	mov    0x805770,%edx
  800386:	39 10                	cmp    %edx,(%eax)
  800388:	0f 94 c0             	sete   %al
  80038b:	0f b6 c0             	movzbl %al,%eax
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <opencons>:

int
opencons(void)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800399:	89 04 24             	mov    %eax,(%esp)
  80039c:	e8 3e 0e 00 00       	call   8011df <fd_alloc>
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	78 3c                	js     8003e1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003a5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003ac:	00 
  8003ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003bb:	e8 29 0b 00 00       	call   800ee9 <sys_page_alloc>
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	78 1d                	js     8003e1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8003c4:	8b 15 70 57 80 00    	mov    0x805770,%edx
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003d9:	89 04 24             	mov    %eax,(%esp)
  8003dc:	e8 d3 0d 00 00       	call   8011b4 <fd2num>
}
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    
	...

008003e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	56                   	push   %esi
  8003e8:	53                   	push   %ebx
  8003e9:	83 ec 10             	sub    $0x10,%esp
  8003ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003f2:	e8 b4 0a 00 00       	call   800eab <sys_getenvid>
  8003f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800403:	c1 e0 07             	shl    $0x7,%eax
  800406:	29 d0                	sub    %edx,%eax
  800408:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80040d:	a3 90 77 80 00       	mov    %eax,0x807790


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800412:	85 f6                	test   %esi,%esi
  800414:	7e 07                	jle    80041d <libmain+0x39>
		binaryname = argv[0];
  800416:	8b 03                	mov    (%ebx),%eax
  800418:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  80041d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800421:	89 34 24             	mov    %esi,(%esp)
  800424:	e8 34 fc ff ff       	call   80005d <umain>

	// exit gracefully
	exit();
  800429:	e8 0a 00 00 00       	call   800438 <exit>
}
  80042e:	83 c4 10             	add    $0x10,%esp
  800431:	5b                   	pop    %ebx
  800432:	5e                   	pop    %esi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    
  800435:	00 00                	add    %al,(%eax)
	...

00800438 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80043e:	e8 58 0f 00 00       	call   80139b <close_all>
	sys_env_destroy(0);
  800443:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80044a:	e8 0a 0a 00 00       	call   800e59 <sys_env_destroy>
}
  80044f:	c9                   	leave  
  800450:	c3                   	ret    
  800451:	00 00                	add    %al,(%eax)
	...

00800454 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	56                   	push   %esi
  800458:	53                   	push   %ebx
  800459:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80045c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045f:	8b 1d 8c 57 80 00    	mov    0x80578c,%ebx
  800465:	e8 41 0a 00 00       	call   800eab <sys_getenvid>
  80046a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800471:	8b 55 08             	mov    0x8(%ebp),%edx
  800474:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800478:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80047c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800480:	c7 04 24 ac 2e 80 00 	movl   $0x802eac,(%esp)
  800487:	e8 c0 00 00 00       	call   80054c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80048c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800490:	8b 45 10             	mov    0x10(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 50 00 00 00       	call   8004eb <vcprintf>
	cprintf("\n");
  80049b:	c7 04 24 d5 33 80 00 	movl   $0x8033d5,(%esp)
  8004a2:	e8 a5 00 00 00       	call   80054c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a7:	cc                   	int3   
  8004a8:	eb fd                	jmp    8004a7 <_panic+0x53>
	...

008004ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 14             	sub    $0x14,%esp
  8004b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b6:	8b 03                	mov    (%ebx),%eax
  8004b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004bf:	40                   	inc    %eax
  8004c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c7:	75 19                	jne    8004e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004d0:	00 
  8004d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 40 09 00 00       	call   800e1c <sys_cputs>
		b->idx = 0;
  8004dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e2:	ff 43 04             	incl   0x4(%ebx)
}
  8004e5:	83 c4 14             	add    $0x14,%esp
  8004e8:	5b                   	pop    %ebx
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fb:	00 00 00 
	b.cnt = 0;
  8004fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800505:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	89 44 24 08          	mov    %eax,0x8(%esp)
  800516:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	c7 04 24 ac 04 80 00 	movl   $0x8004ac,(%esp)
  800527:	e8 82 01 00 00       	call   8006ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	e8 d8 08 00 00       	call   800e1c <sys_cputs>

	return b.cnt;
}
  800544:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800552:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	e8 87 ff ff ff       	call   8004eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800564:	c9                   	leave  
  800565:	c3                   	ret    
	...

00800568 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	57                   	push   %edi
  80056c:	56                   	push   %esi
  80056d:	53                   	push   %ebx
  80056e:	83 ec 3c             	sub    $0x3c,%esp
  800571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800574:	89 d7                	mov    %edx,%edi
  800576:	8b 45 08             	mov    0x8(%ebp),%eax
  800579:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80057c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800582:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800585:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800588:	85 c0                	test   %eax,%eax
  80058a:	75 08                	jne    800594 <printnum+0x2c>
  80058c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80058f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800592:	77 57                	ja     8005eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800594:	89 74 24 10          	mov    %esi,0x10(%esp)
  800598:	4b                   	dec    %ebx
  800599:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80059d:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b3:	00 
  8005b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c1:	e8 4a 25 00 00       	call   802b10 <__udivdi3>
  8005c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d5:	89 fa                	mov    %edi,%edx
  8005d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005da:	e8 89 ff ff ff       	call   800568 <printnum>
  8005df:	eb 0f                	jmp    8005f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e5:	89 34 24             	mov    %esi,(%esp)
  8005e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005eb:	4b                   	dec    %ebx
  8005ec:	85 db                	test   %ebx,%ebx
  8005ee:	7f f1                	jg     8005e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800606:	00 
  800607:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800610:	89 44 24 04          	mov    %eax,0x4(%esp)
  800614:	e8 17 26 00 00       	call   802c30 <__umoddi3>
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	0f be 80 cf 2e 80 00 	movsbl 0x802ecf(%eax),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80062a:	83 c4 3c             	add    $0x3c,%esp
  80062d:	5b                   	pop    %ebx
  80062e:	5e                   	pop    %esi
  80062f:	5f                   	pop    %edi
  800630:	5d                   	pop    %ebp
  800631:	c3                   	ret    

00800632 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800635:	83 fa 01             	cmp    $0x1,%edx
  800638:	7e 0e                	jle    800648 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80063f:	89 08                	mov    %ecx,(%eax)
  800641:	8b 02                	mov    (%edx),%eax
  800643:	8b 52 04             	mov    0x4(%edx),%edx
  800646:	eb 22                	jmp    80066a <getuint+0x38>
	else if (lflag)
  800648:	85 d2                	test   %edx,%edx
  80064a:	74 10                	je     80065c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800651:	89 08                	mov    %ecx,(%eax)
  800653:	8b 02                	mov    (%edx),%eax
  800655:	ba 00 00 00 00       	mov    $0x0,%edx
  80065a:	eb 0e                	jmp    80066a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800661:	89 08                	mov    %ecx,(%eax)
  800663:	8b 02                	mov    (%edx),%eax
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800672:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800675:	8b 10                	mov    (%eax),%edx
  800677:	3b 50 04             	cmp    0x4(%eax),%edx
  80067a:	73 08                	jae    800684 <sprintputch+0x18>
		*b->buf++ = ch;
  80067c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067f:	88 0a                	mov    %cl,(%edx)
  800681:	42                   	inc    %edx
  800682:	89 10                	mov    %edx,(%eax)
}
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80068c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80068f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800693:	8b 45 10             	mov    0x10(%ebp),%eax
  800696:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	e8 02 00 00 00       	call   8006ae <vprintfmt>
	va_end(ap);
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    

008006ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	57                   	push   %edi
  8006b2:	56                   	push   %esi
  8006b3:	53                   	push   %ebx
  8006b4:	83 ec 4c             	sub    $0x4c,%esp
  8006b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8006bd:	eb 12                	jmp    8006d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	0f 84 6b 03 00 00    	je     800a32 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cb:	89 04 24             	mov    %eax,(%esp)
  8006ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d1:	0f b6 06             	movzbl (%esi),%eax
  8006d4:	46                   	inc    %esi
  8006d5:	83 f8 25             	cmp    $0x25,%eax
  8006d8:	75 e5                	jne    8006bf <vprintfmt+0x11>
  8006da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f6:	eb 26                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006ff:	eb 1d                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800701:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800704:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800708:	eb 14                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80070d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800714:	eb 08                	jmp    80071e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800716:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800719:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	0f b6 06             	movzbl (%esi),%eax
  800721:	8d 56 01             	lea    0x1(%esi),%edx
  800724:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800727:	8a 16                	mov    (%esi),%dl
  800729:	83 ea 23             	sub    $0x23,%edx
  80072c:	80 fa 55             	cmp    $0x55,%dl
  80072f:	0f 87 e1 02 00 00    	ja     800a16 <vprintfmt+0x368>
  800735:	0f b6 d2             	movzbl %dl,%edx
  800738:	ff 24 95 20 30 80 00 	jmp    *0x803020(,%edx,4)
  80073f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800742:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800747:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80074a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80074e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800751:	8d 50 d0             	lea    -0x30(%eax),%edx
  800754:	83 fa 09             	cmp    $0x9,%edx
  800757:	77 2a                	ja     800783 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800759:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075a:	eb eb                	jmp    800747 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8d 50 04             	lea    0x4(%eax),%edx
  800762:	89 55 14             	mov    %edx,0x14(%ebp)
  800765:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800767:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80076a:	eb 17                	jmp    800783 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80076c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800770:	78 98                	js     80070a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800775:	eb a7                	jmp    80071e <vprintfmt+0x70>
  800777:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80077a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800781:	eb 9b                	jmp    80071e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800783:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800787:	79 95                	jns    80071e <vprintfmt+0x70>
  800789:	eb 8b                	jmp    800716 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80078b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80078f:	eb 8d                	jmp    80071e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 04             	lea    0x4(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007a9:	e9 23 ff ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	79 02                	jns    8007bf <vprintfmt+0x111>
  8007bd:	f7 d8                	neg    %eax
  8007bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007c1:	83 f8 10             	cmp    $0x10,%eax
  8007c4:	7f 0b                	jg     8007d1 <vprintfmt+0x123>
  8007c6:	8b 04 85 80 31 80 00 	mov    0x803180(,%eax,4),%eax
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	75 23                	jne    8007f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d5:	c7 44 24 08 e7 2e 80 	movl   $0x802ee7,0x8(%esp)
  8007dc:	00 
  8007dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	e8 9a fe ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007ef:	e9 dd fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f8:	c7 44 24 08 b9 32 80 	movl   $0x8032b9,0x8(%esp)
  8007ff:	00 
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
  800807:	89 14 24             	mov    %edx,(%esp)
  80080a:	e8 77 fe ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800812:	e9 ba fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
  800817:	89 f9                	mov    %edi,%ecx
  800819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80081c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	89 55 14             	mov    %edx,0x14(%ebp)
  800828:	8b 30                	mov    (%eax),%esi
  80082a:	85 f6                	test   %esi,%esi
  80082c:	75 05                	jne    800833 <vprintfmt+0x185>
				p = "(null)";
  80082e:	be e0 2e 80 00       	mov    $0x802ee0,%esi
			if (width > 0 && padc != '-')
  800833:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800837:	0f 8e 84 00 00 00    	jle    8008c1 <vprintfmt+0x213>
  80083d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800841:	74 7e                	je     8008c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800843:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800847:	89 34 24             	mov    %esi,(%esp)
  80084a:	e8 8b 02 00 00       	call   800ada <strnlen>
  80084f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800852:	29 c2                	sub    %eax,%edx
  800854:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800857:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80085b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80085e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800861:	89 de                	mov    %ebx,%esi
  800863:	89 d3                	mov    %edx,%ebx
  800865:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800867:	eb 0b                	jmp    800874 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800869:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086d:	89 3c 24             	mov    %edi,(%esp)
  800870:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800873:	4b                   	dec    %ebx
  800874:	85 db                	test   %ebx,%ebx
  800876:	7f f1                	jg     800869 <vprintfmt+0x1bb>
  800878:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80087b:	89 f3                	mov    %esi,%ebx
  80087d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800883:	85 c0                	test   %eax,%eax
  800885:	79 05                	jns    80088c <vprintfmt+0x1de>
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80088f:	29 c2                	sub    %eax,%edx
  800891:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800894:	eb 2b                	jmp    8008c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800896:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80089a:	74 18                	je     8008b4 <vprintfmt+0x206>
  80089c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80089f:	83 fa 5e             	cmp    $0x5e,%edx
  8008a2:	76 10                	jbe    8008b4 <vprintfmt+0x206>
					putch('?', putdat);
  8008a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008af:	ff 55 08             	call   *0x8(%ebp)
  8008b2:	eb 0a                	jmp    8008be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b8:	89 04 24             	mov    %eax,(%esp)
  8008bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008be:	ff 4d e4             	decl   -0x1c(%ebp)
  8008c1:	0f be 06             	movsbl (%esi),%eax
  8008c4:	46                   	inc    %esi
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 21                	je     8008ea <vprintfmt+0x23c>
  8008c9:	85 ff                	test   %edi,%edi
  8008cb:	78 c9                	js     800896 <vprintfmt+0x1e8>
  8008cd:	4f                   	dec    %edi
  8008ce:	79 c6                	jns    800896 <vprintfmt+0x1e8>
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	89 de                	mov    %ebx,%esi
  8008d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008d8:	eb 18                	jmp    8008f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008e7:	4b                   	dec    %ebx
  8008e8:	eb 08                	jmp    8008f2 <vprintfmt+0x244>
  8008ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ed:	89 de                	mov    %ebx,%esi
  8008ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008f2:	85 db                	test   %ebx,%ebx
  8008f4:	7f e4                	jg     8008da <vprintfmt+0x22c>
  8008f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008fe:	e9 ce fd ff ff       	jmp    8006d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800903:	83 f9 01             	cmp    $0x1,%ecx
  800906:	7e 10                	jle    800918 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8d 50 08             	lea    0x8(%eax),%edx
  80090e:	89 55 14             	mov    %edx,0x14(%ebp)
  800911:	8b 30                	mov    (%eax),%esi
  800913:	8b 78 04             	mov    0x4(%eax),%edi
  800916:	eb 26                	jmp    80093e <vprintfmt+0x290>
	else if (lflag)
  800918:	85 c9                	test   %ecx,%ecx
  80091a:	74 12                	je     80092e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8d 50 04             	lea    0x4(%eax),%edx
  800922:	89 55 14             	mov    %edx,0x14(%ebp)
  800925:	8b 30                	mov    (%eax),%esi
  800927:	89 f7                	mov    %esi,%edi
  800929:	c1 ff 1f             	sar    $0x1f,%edi
  80092c:	eb 10                	jmp    80093e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 50 04             	lea    0x4(%eax),%edx
  800934:	89 55 14             	mov    %edx,0x14(%ebp)
  800937:	8b 30                	mov    (%eax),%esi
  800939:	89 f7                	mov    %esi,%edi
  80093b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80093e:	85 ff                	test   %edi,%edi
  800940:	78 0a                	js     80094c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800942:	b8 0a 00 00 00       	mov    $0xa,%eax
  800947:	e9 8c 00 00 00       	jmp    8009d8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80094c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800950:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800957:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80095a:	f7 de                	neg    %esi
  80095c:	83 d7 00             	adc    $0x0,%edi
  80095f:	f7 df                	neg    %edi
			}
			base = 10;
  800961:	b8 0a 00 00 00       	mov    $0xa,%eax
  800966:	eb 70                	jmp    8009d8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800968:	89 ca                	mov    %ecx,%edx
  80096a:	8d 45 14             	lea    0x14(%ebp),%eax
  80096d:	e8 c0 fc ff ff       	call   800632 <getuint>
  800972:	89 c6                	mov    %eax,%esi
  800974:	89 d7                	mov    %edx,%edi
			base = 10;
  800976:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80097b:	eb 5b                	jmp    8009d8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  80097d:	89 ca                	mov    %ecx,%edx
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
  800982:	e8 ab fc ff ff       	call   800632 <getuint>
  800987:	89 c6                	mov    %eax,%esi
  800989:	89 d7                	mov    %edx,%edi
			base = 8;
  80098b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800990:	eb 46                	jmp    8009d8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800992:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800996:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80099d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b1:	8d 50 04             	lea    0x4(%eax),%edx
  8009b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009b7:	8b 30                	mov    (%eax),%esi
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009c3:	eb 13                	jmp    8009d8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c5:	89 ca                	mov    %ecx,%edx
  8009c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ca:	e8 63 fc ff ff       	call   800632 <getuint>
  8009cf:	89 c6                	mov    %eax,%esi
  8009d1:	89 d7                	mov    %edx,%edi
			base = 16;
  8009d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009d8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009eb:	89 34 24             	mov    %esi,(%esp)
  8009ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f2:	89 da                	mov    %ebx,%edx
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	e8 6c fb ff ff       	call   800568 <printnum>
			break;
  8009fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009ff:	e9 cd fc ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a11:	e9 bb fc ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a21:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a24:	eb 01                	jmp    800a27 <vprintfmt+0x379>
  800a26:	4e                   	dec    %esi
  800a27:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a2b:	75 f9                	jne    800a26 <vprintfmt+0x378>
  800a2d:	e9 9f fc ff ff       	jmp    8006d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a32:	83 c4 4c             	add    $0x4c,%esp
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 28             	sub    $0x28,%esp
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a46:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a49:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a4d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a57:	85 c0                	test   %eax,%eax
  800a59:	74 30                	je     800a8b <vsnprintf+0x51>
  800a5b:	85 d2                	test   %edx,%edx
  800a5d:	7e 33                	jle    800a92 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a66:	8b 45 10             	mov    0x10(%ebp),%eax
  800a69:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a74:	c7 04 24 6c 06 80 00 	movl   $0x80066c,(%esp)
  800a7b:	e8 2e fc ff ff       	call   8006ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a83:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a89:	eb 0c                	jmp    800a97 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a90:	eb 05                	jmp    800a97 <vsnprintf+0x5d>
  800a92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a9f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa6:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	89 04 24             	mov    %eax,(%esp)
  800aba:	e8 7b ff ff ff       	call   800a3a <vsnprintf>
	va_end(ap);

	return rc;
}
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    
  800ac1:	00 00                	add    %al,(%eax)
	...

00800ac4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	eb 01                	jmp    800ad2 <strlen+0xe>
		n++;
  800ad1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad6:	75 f9                	jne    800ad1 <strlen+0xd>
		n++;
	return n;
}
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800ae0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae8:	eb 01                	jmp    800aeb <strnlen+0x11>
		n++;
  800aea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aeb:	39 d0                	cmp    %edx,%eax
  800aed:	74 06                	je     800af5 <strnlen+0x1b>
  800aef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800af3:	75 f5                	jne    800aea <strnlen+0x10>
		n++;
	return n;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b09:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b0c:	42                   	inc    %edx
  800b0d:	84 c9                	test   %cl,%cl
  800b0f:	75 f5                	jne    800b06 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b11:	5b                   	pop    %ebx
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	53                   	push   %ebx
  800b18:	83 ec 08             	sub    $0x8,%esp
  800b1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b1e:	89 1c 24             	mov    %ebx,(%esp)
  800b21:	e8 9e ff ff ff       	call   800ac4 <strlen>
	strcpy(dst + len, src);
  800b26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b29:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b2d:	01 d8                	add    %ebx,%eax
  800b2f:	89 04 24             	mov    %eax,(%esp)
  800b32:	e8 c0 ff ff ff       	call   800af7 <strcpy>
	return dst;
}
  800b37:	89 d8                	mov    %ebx,%eax
  800b39:	83 c4 08             	add    $0x8,%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	eb 0c                	jmp    800b60 <strncpy+0x21>
		*dst++ = *src;
  800b54:	8a 1a                	mov    (%edx),%bl
  800b56:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b59:	80 3a 01             	cmpb   $0x1,(%edx)
  800b5c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b5f:	41                   	inc    %ecx
  800b60:	39 f1                	cmp    %esi,%ecx
  800b62:	75 f0                	jne    800b54 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b76:	85 d2                	test   %edx,%edx
  800b78:	75 0a                	jne    800b84 <strlcpy+0x1c>
  800b7a:	89 f0                	mov    %esi,%eax
  800b7c:	eb 1a                	jmp    800b98 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b7e:	88 18                	mov    %bl,(%eax)
  800b80:	40                   	inc    %eax
  800b81:	41                   	inc    %ecx
  800b82:	eb 02                	jmp    800b86 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b84:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b86:	4a                   	dec    %edx
  800b87:	74 0a                	je     800b93 <strlcpy+0x2b>
  800b89:	8a 19                	mov    (%ecx),%bl
  800b8b:	84 db                	test   %bl,%bl
  800b8d:	75 ef                	jne    800b7e <strlcpy+0x16>
  800b8f:	89 c2                	mov    %eax,%edx
  800b91:	eb 02                	jmp    800b95 <strlcpy+0x2d>
  800b93:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b95:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b98:	29 f0                	sub    %esi,%eax
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ba7:	eb 02                	jmp    800bab <strcmp+0xd>
		p++, q++;
  800ba9:	41                   	inc    %ecx
  800baa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bab:	8a 01                	mov    (%ecx),%al
  800bad:	84 c0                	test   %al,%al
  800baf:	74 04                	je     800bb5 <strcmp+0x17>
  800bb1:	3a 02                	cmp    (%edx),%al
  800bb3:	74 f4                	je     800ba9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb5:	0f b6 c0             	movzbl %al,%eax
  800bb8:	0f b6 12             	movzbl (%edx),%edx
  800bbb:	29 d0                	sub    %edx,%eax
}
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bcc:	eb 03                	jmp    800bd1 <strncmp+0x12>
		n--, p++, q++;
  800bce:	4a                   	dec    %edx
  800bcf:	40                   	inc    %eax
  800bd0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bd1:	85 d2                	test   %edx,%edx
  800bd3:	74 14                	je     800be9 <strncmp+0x2a>
  800bd5:	8a 18                	mov    (%eax),%bl
  800bd7:	84 db                	test   %bl,%bl
  800bd9:	74 04                	je     800bdf <strncmp+0x20>
  800bdb:	3a 19                	cmp    (%ecx),%bl
  800bdd:	74 ef                	je     800bce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bdf:	0f b6 00             	movzbl (%eax),%eax
  800be2:	0f b6 11             	movzbl (%ecx),%edx
  800be5:	29 d0                	sub    %edx,%eax
  800be7:	eb 05                	jmp    800bee <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bfa:	eb 05                	jmp    800c01 <strchr+0x10>
		if (*s == c)
  800bfc:	38 ca                	cmp    %cl,%dl
  800bfe:	74 0c                	je     800c0c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c00:	40                   	inc    %eax
  800c01:	8a 10                	mov    (%eax),%dl
  800c03:	84 d2                	test   %dl,%dl
  800c05:	75 f5                	jne    800bfc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c17:	eb 05                	jmp    800c1e <strfind+0x10>
		if (*s == c)
  800c19:	38 ca                	cmp    %cl,%dl
  800c1b:	74 07                	je     800c24 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c1d:	40                   	inc    %eax
  800c1e:	8a 10                	mov    (%eax),%dl
  800c20:	84 d2                	test   %dl,%dl
  800c22:	75 f5                	jne    800c19 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c35:	85 c9                	test   %ecx,%ecx
  800c37:	74 30                	je     800c69 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3f:	75 25                	jne    800c66 <memset+0x40>
  800c41:	f6 c1 03             	test   $0x3,%cl
  800c44:	75 20                	jne    800c66 <memset+0x40>
		c &= 0xFF;
  800c46:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	c1 e3 08             	shl    $0x8,%ebx
  800c4e:	89 d6                	mov    %edx,%esi
  800c50:	c1 e6 18             	shl    $0x18,%esi
  800c53:	89 d0                	mov    %edx,%eax
  800c55:	c1 e0 10             	shl    $0x10,%eax
  800c58:	09 f0                	or     %esi,%eax
  800c5a:	09 d0                	or     %edx,%eax
  800c5c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c5e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c61:	fc                   	cld    
  800c62:	f3 ab                	rep stos %eax,%es:(%edi)
  800c64:	eb 03                	jmp    800c69 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c66:	fc                   	cld    
  800c67:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c69:	89 f8                	mov    %edi,%eax
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c7e:	39 c6                	cmp    %eax,%esi
  800c80:	73 34                	jae    800cb6 <memmove+0x46>
  800c82:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c85:	39 d0                	cmp    %edx,%eax
  800c87:	73 2d                	jae    800cb6 <memmove+0x46>
		s += n;
		d += n;
  800c89:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8c:	f6 c2 03             	test   $0x3,%dl
  800c8f:	75 1b                	jne    800cac <memmove+0x3c>
  800c91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c97:	75 13                	jne    800cac <memmove+0x3c>
  800c99:	f6 c1 03             	test   $0x3,%cl
  800c9c:	75 0e                	jne    800cac <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c9e:	83 ef 04             	sub    $0x4,%edi
  800ca1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ca7:	fd                   	std    
  800ca8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800caa:	eb 07                	jmp    800cb3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cac:	4f                   	dec    %edi
  800cad:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cb0:	fd                   	std    
  800cb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb3:	fc                   	cld    
  800cb4:	eb 20                	jmp    800cd6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cbc:	75 13                	jne    800cd1 <memmove+0x61>
  800cbe:	a8 03                	test   $0x3,%al
  800cc0:	75 0f                	jne    800cd1 <memmove+0x61>
  800cc2:	f6 c1 03             	test   $0x3,%cl
  800cc5:	75 0a                	jne    800cd1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cc7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cca:	89 c7                	mov    %eax,%edi
  800ccc:	fc                   	cld    
  800ccd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccf:	eb 05                	jmp    800cd6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd1:	89 c7                	mov    %eax,%edi
  800cd3:	fc                   	cld    
  800cd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ce0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	89 04 24             	mov    %eax,(%esp)
  800cf4:	e8 77 ff ff ff       	call   800c70 <memmove>
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	eb 16                	jmp    800d27 <memcmp+0x2c>
		if (*s1 != *s2)
  800d11:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d14:	42                   	inc    %edx
  800d15:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d19:	38 c8                	cmp    %cl,%al
  800d1b:	74 0a                	je     800d27 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d1d:	0f b6 c0             	movzbl %al,%eax
  800d20:	0f b6 c9             	movzbl %cl,%ecx
  800d23:	29 c8                	sub    %ecx,%eax
  800d25:	eb 09                	jmp    800d30 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d27:	39 da                	cmp    %ebx,%edx
  800d29:	75 e6                	jne    800d11 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d3e:	89 c2                	mov    %eax,%edx
  800d40:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d43:	eb 05                	jmp    800d4a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d45:	38 08                	cmp    %cl,(%eax)
  800d47:	74 05                	je     800d4e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d49:	40                   	inc    %eax
  800d4a:	39 d0                	cmp    %edx,%eax
  800d4c:	72 f7                	jb     800d45 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5c:	eb 01                	jmp    800d5f <strtol+0xf>
		s++;
  800d5e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5f:	8a 02                	mov    (%edx),%al
  800d61:	3c 20                	cmp    $0x20,%al
  800d63:	74 f9                	je     800d5e <strtol+0xe>
  800d65:	3c 09                	cmp    $0x9,%al
  800d67:	74 f5                	je     800d5e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d69:	3c 2b                	cmp    $0x2b,%al
  800d6b:	75 08                	jne    800d75 <strtol+0x25>
		s++;
  800d6d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d73:	eb 13                	jmp    800d88 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d75:	3c 2d                	cmp    $0x2d,%al
  800d77:	75 0a                	jne    800d83 <strtol+0x33>
		s++, neg = 1;
  800d79:	8d 52 01             	lea    0x1(%edx),%edx
  800d7c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d81:	eb 05                	jmp    800d88 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d88:	85 db                	test   %ebx,%ebx
  800d8a:	74 05                	je     800d91 <strtol+0x41>
  800d8c:	83 fb 10             	cmp    $0x10,%ebx
  800d8f:	75 28                	jne    800db9 <strtol+0x69>
  800d91:	8a 02                	mov    (%edx),%al
  800d93:	3c 30                	cmp    $0x30,%al
  800d95:	75 10                	jne    800da7 <strtol+0x57>
  800d97:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d9b:	75 0a                	jne    800da7 <strtol+0x57>
		s += 2, base = 16;
  800d9d:	83 c2 02             	add    $0x2,%edx
  800da0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800da5:	eb 12                	jmp    800db9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800da7:	85 db                	test   %ebx,%ebx
  800da9:	75 0e                	jne    800db9 <strtol+0x69>
  800dab:	3c 30                	cmp    $0x30,%al
  800dad:	75 05                	jne    800db4 <strtol+0x64>
		s++, base = 8;
  800daf:	42                   	inc    %edx
  800db0:	b3 08                	mov    $0x8,%bl
  800db2:	eb 05                	jmp    800db9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800db4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc0:	8a 0a                	mov    (%edx),%cl
  800dc2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dc5:	80 fb 09             	cmp    $0x9,%bl
  800dc8:	77 08                	ja     800dd2 <strtol+0x82>
			dig = *s - '0';
  800dca:	0f be c9             	movsbl %cl,%ecx
  800dcd:	83 e9 30             	sub    $0x30,%ecx
  800dd0:	eb 1e                	jmp    800df0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800dd2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800dd5:	80 fb 19             	cmp    $0x19,%bl
  800dd8:	77 08                	ja     800de2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800dda:	0f be c9             	movsbl %cl,%ecx
  800ddd:	83 e9 57             	sub    $0x57,%ecx
  800de0:	eb 0e                	jmp    800df0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800de2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800de5:	80 fb 19             	cmp    $0x19,%bl
  800de8:	77 12                	ja     800dfc <strtol+0xac>
			dig = *s - 'A' + 10;
  800dea:	0f be c9             	movsbl %cl,%ecx
  800ded:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800df0:	39 f1                	cmp    %esi,%ecx
  800df2:	7d 0c                	jge    800e00 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800df4:	42                   	inc    %edx
  800df5:	0f af c6             	imul   %esi,%eax
  800df8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dfa:	eb c4                	jmp    800dc0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dfc:	89 c1                	mov    %eax,%ecx
  800dfe:	eb 02                	jmp    800e02 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e00:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e06:	74 05                	je     800e0d <strtol+0xbd>
		*endptr = (char *) s;
  800e08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e0b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e0d:	85 ff                	test   %edi,%edi
  800e0f:	74 04                	je     800e15 <strtol+0xc5>
  800e11:	89 c8                	mov    %ecx,%eax
  800e13:	f7 d8                	neg    %eax
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
	...

00800e1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
  800e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 c3                	mov    %eax,%ebx
  800e2f:	89 c7                	mov    %eax,%edi
  800e31:	89 c6                	mov    %eax,%esi
  800e33:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_cgetc>:

int
sys_cgetc(void)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e40:	ba 00 00 00 00       	mov    $0x0,%edx
  800e45:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4a:	89 d1                	mov    %edx,%ecx
  800e4c:	89 d3                	mov    %edx,%ebx
  800e4e:	89 d7                	mov    %edx,%edi
  800e50:	89 d6                	mov    %edx,%esi
  800e52:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	57                   	push   %edi
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e67:	b8 03 00 00 00       	mov    $0x3,%eax
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 cb                	mov    %ecx,%ebx
  800e71:	89 cf                	mov    %ecx,%edi
  800e73:	89 ce                	mov    %ecx,%esi
  800e75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e77:	85 c0                	test   %eax,%eax
  800e79:	7e 28                	jle    800ea3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e86:	00 
  800e87:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e96:	00 
  800e97:	c7 04 24 00 32 80 00 	movl   $0x803200,(%esp)
  800e9e:	e8 b1 f5 ff ff       	call   800454 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ea3:	83 c4 2c             	add    $0x2c,%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ebb:	89 d1                	mov    %edx,%ecx
  800ebd:	89 d3                	mov    %edx,%ebx
  800ebf:	89 d7                	mov    %edx,%edi
  800ec1:	89 d6                	mov    %edx,%esi
  800ec3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_yield>:

void
sys_yield(void)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eda:	89 d1                	mov    %edx,%ecx
  800edc:	89 d3                	mov    %edx,%ebx
  800ede:	89 d7                	mov    %edx,%edi
  800ee0:	89 d6                	mov    %edx,%esi
  800ee2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef2:	be 00 00 00 00       	mov    $0x0,%esi
  800ef7:	b8 04 00 00 00       	mov    $0x4,%eax
  800efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f02:	8b 55 08             	mov    0x8(%ebp),%edx
  800f05:	89 f7                	mov    %esi,%edi
  800f07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	7e 28                	jle    800f35 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f11:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f18:	00 
  800f19:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  800f20:	00 
  800f21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f28:	00 
  800f29:	c7 04 24 00 32 80 00 	movl   $0x803200,(%esp)
  800f30:	e8 1f f5 ff ff       	call   800454 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f35:	83 c4 2c             	add    $0x2c,%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4b:	8b 75 18             	mov    0x18(%ebp),%esi
  800f4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f57:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	7e 28                	jle    800f88 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f64:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 00 32 80 00 	movl   $0x803200,(%esp)
  800f83:	e8 cc f4 ff ff       	call   800454 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f88:	83 c4 2c             	add    $0x2c,%esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5e                   	pop    %esi
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa9:	89 df                	mov    %ebx,%edi
  800fab:	89 de                	mov    %ebx,%esi
  800fad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	7e 28                	jle    800fdb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  800fc6:	00 
  800fc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fce:	00 
  800fcf:	c7 04 24 00 32 80 00 	movl   $0x803200,(%esp)
  800fd6:	e8 79 f4 ff ff       	call   800454 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fdb:	83 c4 2c             	add    $0x2c,%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800fec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ff6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	89 df                	mov    %ebx,%edi
  800ffe:	89 de                	mov    %ebx,%esi
  801000:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801002:	85 c0                	test   %eax,%eax
  801004:	7e 28                	jle    80102e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801006:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801011:	00 
  801012:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  801019:	00 
  80101a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801021:	00 
  801022:	c7 04 24 00 32 80 00 	movl   $0x803200,(%esp)
  801029:	e8 26 f4 ff ff       	call   800454 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80102e:	83 c4 2c             	add    $0x2c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
  80103c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801044:	b8 09 00 00 00       	mov    $0x9,%eax
  801049:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104c:	8b 55 08             	mov    0x8(%ebp),%edx
  80104f:	89 df                	mov    %ebx,%edi
  801051:	89 de                	mov    %ebx,%esi
  801053:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801055:	85 c0                	test   %eax,%eax
  801057:	7e 28                	jle    801081 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801059:	89 44 24 10          	mov    %eax,0x10(%esp)
  80105d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801064:	00 
  801065:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  80106c:	00 
  80106d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801074:	00 
  801075:	c7 04 24 00 32 80 00 	movl   $0x803200,(%esp)
  80107c:	e8 d3 f3 ff ff       	call   800454 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801081:	83 c4 2c             	add    $0x2c,%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5f                   	pop    %edi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	57                   	push   %edi
  80108d:	56                   	push   %esi
  80108e:	53                   	push   %ebx
  80108f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
  801097:	b8 0a 00 00 00       	mov    $0xa,%eax
  80109c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109f:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a2:	89 df                	mov    %ebx,%edi
  8010a4:	89 de                	mov    %ebx,%esi
  8010a6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	7e 28                	jle    8010d4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010b7:	00 
  8010b8:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c7:	00 
  8010c8:	c7 04 24 00 32 80 00 	movl   $0x803200,(%esp)
  8010cf:	e8 80 f3 ff ff       	call   800454 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d4:	83 c4 2c             	add    $0x2c,%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e2:	be 00 00 00 00       	mov    $0x0,%esi
  8010e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010ec:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801108:	b9 00 00 00 00       	mov    $0x0,%ecx
  80110d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801112:	8b 55 08             	mov    0x8(%ebp),%edx
  801115:	89 cb                	mov    %ecx,%ebx
  801117:	89 cf                	mov    %ecx,%edi
  801119:	89 ce                	mov    %ecx,%esi
  80111b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80111d:	85 c0                	test   %eax,%eax
  80111f:	7e 28                	jle    801149 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801121:	89 44 24 10          	mov    %eax,0x10(%esp)
  801125:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80112c:	00 
  80112d:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  801134:	00 
  801135:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80113c:	00 
  80113d:	c7 04 24 00 32 80 00 	movl   $0x803200,(%esp)
  801144:	e8 0b f3 ff ff       	call   800454 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801149:	83 c4 2c             	add    $0x2c,%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	57                   	push   %edi
  801155:	56                   	push   %esi
  801156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801157:	ba 00 00 00 00       	mov    $0x0,%edx
  80115c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801161:	89 d1                	mov    %edx,%ecx
  801163:	89 d3                	mov    %edx,%ebx
  801165:	89 d7                	mov    %edx,%edi
  801167:	89 d6                	mov    %edx,%esi
  801169:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80116b:	5b                   	pop    %ebx
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801176:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117b:	b8 0f 00 00 00       	mov    $0xf,%eax
  801180:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801183:	8b 55 08             	mov    0x8(%ebp),%edx
  801186:	89 df                	mov    %ebx,%edi
  801188:	89 de                	mov    %ebx,%esi
  80118a:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119c:	b8 10 00 00 00       	mov    $0x10,%eax
  8011a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a7:	89 df                	mov    %ebx,%edi
  8011a9:	89 de                	mov    %ebx,%esi
  8011ab:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    
	...

008011b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	89 04 24             	mov    %eax,(%esp)
  8011d0:	e8 df ff ff ff       	call   8011b4 <fd2num>
  8011d5:	c1 e0 0c             	shl    $0xc,%eax
  8011d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011dd:	c9                   	leave  
  8011de:	c3                   	ret    

008011df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	53                   	push   %ebx
  8011e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011eb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	c1 ea 16             	shr    $0x16,%edx
  8011f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f9:	f6 c2 01             	test   $0x1,%dl
  8011fc:	74 11                	je     80120f <fd_alloc+0x30>
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	c1 ea 0c             	shr    $0xc,%edx
  801203:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120a:	f6 c2 01             	test   $0x1,%dl
  80120d:	75 09                	jne    801218 <fd_alloc+0x39>
			*fd_store = fd;
  80120f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
  801216:	eb 17                	jmp    80122f <fd_alloc+0x50>
  801218:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80121d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801222:	75 c7                	jne    8011eb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801224:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80122a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80122f:	5b                   	pop    %ebx
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801238:	83 f8 1f             	cmp    $0x1f,%eax
  80123b:	77 36                	ja     801273 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123d:	c1 e0 0c             	shl    $0xc,%eax
  801240:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801245:	89 c2                	mov    %eax,%edx
  801247:	c1 ea 16             	shr    $0x16,%edx
  80124a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801251:	f6 c2 01             	test   $0x1,%dl
  801254:	74 24                	je     80127a <fd_lookup+0x48>
  801256:	89 c2                	mov    %eax,%edx
  801258:	c1 ea 0c             	shr    $0xc,%edx
  80125b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801262:	f6 c2 01             	test   $0x1,%dl
  801265:	74 1a                	je     801281 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801267:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126a:	89 02                	mov    %eax,(%edx)
	return 0;
  80126c:	b8 00 00 00 00       	mov    $0x0,%eax
  801271:	eb 13                	jmp    801286 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801278:	eb 0c                	jmp    801286 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127f:	eb 05                	jmp    801286 <fd_lookup+0x54>
  801281:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	53                   	push   %ebx
  80128c:	83 ec 14             	sub    $0x14,%esp
  80128f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801295:	ba 00 00 00 00       	mov    $0x0,%edx
  80129a:	eb 0e                	jmp    8012aa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80129c:	39 08                	cmp    %ecx,(%eax)
  80129e:	75 09                	jne    8012a9 <dev_lookup+0x21>
			*dev = devtab[i];
  8012a0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a7:	eb 33                	jmp    8012dc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a9:	42                   	inc    %edx
  8012aa:	8b 04 95 8c 32 80 00 	mov    0x80328c(,%edx,4),%eax
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	75 e7                	jne    80129c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b5:	a1 90 77 80 00       	mov    0x807790,%eax
  8012ba:	8b 40 48             	mov    0x48(%eax),%eax
  8012bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c5:	c7 04 24 10 32 80 00 	movl   $0x803210,(%esp)
  8012cc:	e8 7b f2 ff ff       	call   80054c <cprintf>
	*dev = 0;
  8012d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012dc:	83 c4 14             	add    $0x14,%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 30             	sub    $0x30,%esp
  8012ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ed:	8a 45 0c             	mov    0xc(%ebp),%al
  8012f0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f3:	89 34 24             	mov    %esi,(%esp)
  8012f6:	e8 b9 fe ff ff       	call   8011b4 <fd2num>
  8012fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801302:	89 04 24             	mov    %eax,(%esp)
  801305:	e8 28 ff ff ff       	call   801232 <fd_lookup>
  80130a:	89 c3                	mov    %eax,%ebx
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 05                	js     801315 <fd_close+0x33>
	    || fd != fd2)
  801310:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801313:	74 0d                	je     801322 <fd_close+0x40>
		return (must_exist ? r : 0);
  801315:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801319:	75 46                	jne    801361 <fd_close+0x7f>
  80131b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801320:	eb 3f                	jmp    801361 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801322:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801325:	89 44 24 04          	mov    %eax,0x4(%esp)
  801329:	8b 06                	mov    (%esi),%eax
  80132b:	89 04 24             	mov    %eax,(%esp)
  80132e:	e8 55 ff ff ff       	call   801288 <dev_lookup>
  801333:	89 c3                	mov    %eax,%ebx
  801335:	85 c0                	test   %eax,%eax
  801337:	78 18                	js     801351 <fd_close+0x6f>
		if (dev->dev_close)
  801339:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133c:	8b 40 10             	mov    0x10(%eax),%eax
  80133f:	85 c0                	test   %eax,%eax
  801341:	74 09                	je     80134c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801343:	89 34 24             	mov    %esi,(%esp)
  801346:	ff d0                	call   *%eax
  801348:	89 c3                	mov    %eax,%ebx
  80134a:	eb 05                	jmp    801351 <fd_close+0x6f>
		else
			r = 0;
  80134c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801351:	89 74 24 04          	mov    %esi,0x4(%esp)
  801355:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80135c:	e8 2f fc ff ff       	call   800f90 <sys_page_unmap>
	return r;
}
  801361:	89 d8                	mov    %ebx,%eax
  801363:	83 c4 30             	add    $0x30,%esp
  801366:	5b                   	pop    %ebx
  801367:	5e                   	pop    %esi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801373:	89 44 24 04          	mov    %eax,0x4(%esp)
  801377:	8b 45 08             	mov    0x8(%ebp),%eax
  80137a:	89 04 24             	mov    %eax,(%esp)
  80137d:	e8 b0 fe ff ff       	call   801232 <fd_lookup>
  801382:	85 c0                	test   %eax,%eax
  801384:	78 13                	js     801399 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801386:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80138d:	00 
  80138e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801391:	89 04 24             	mov    %eax,(%esp)
  801394:	e8 49 ff ff ff       	call   8012e2 <fd_close>
}
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <close_all>:

void
close_all(void)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	53                   	push   %ebx
  80139f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a7:	89 1c 24             	mov    %ebx,(%esp)
  8013aa:	e8 bb ff ff ff       	call   80136a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013af:	43                   	inc    %ebx
  8013b0:	83 fb 20             	cmp    $0x20,%ebx
  8013b3:	75 f2                	jne    8013a7 <close_all+0xc>
		close(i);
}
  8013b5:	83 c4 14             	add    $0x14,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	57                   	push   %edi
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 4c             	sub    $0x4c,%esp
  8013c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	89 04 24             	mov    %eax,(%esp)
  8013d4:	e8 59 fe ff ff       	call   801232 <fd_lookup>
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	0f 88 e3 00 00 00    	js     8014c6 <dup+0x10b>
		return r;
	close(newfdnum);
  8013e3:	89 3c 24             	mov    %edi,(%esp)
  8013e6:	e8 7f ff ff ff       	call   80136a <close>

	newfd = INDEX2FD(newfdnum);
  8013eb:	89 fe                	mov    %edi,%esi
  8013ed:	c1 e6 0c             	shl    $0xc,%esi
  8013f0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013f9:	89 04 24             	mov    %eax,(%esp)
  8013fc:	e8 c3 fd ff ff       	call   8011c4 <fd2data>
  801401:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801403:	89 34 24             	mov    %esi,(%esp)
  801406:	e8 b9 fd ff ff       	call   8011c4 <fd2data>
  80140b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80140e:	89 d8                	mov    %ebx,%eax
  801410:	c1 e8 16             	shr    $0x16,%eax
  801413:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80141a:	a8 01                	test   $0x1,%al
  80141c:	74 46                	je     801464 <dup+0xa9>
  80141e:	89 d8                	mov    %ebx,%eax
  801420:	c1 e8 0c             	shr    $0xc,%eax
  801423:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80142a:	f6 c2 01             	test   $0x1,%dl
  80142d:	74 35                	je     801464 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80142f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801436:	25 07 0e 00 00       	and    $0xe07,%eax
  80143b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80143f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801442:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801446:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80144d:	00 
  80144e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801459:	e8 df fa ff ff       	call   800f3d <sys_page_map>
  80145e:	89 c3                	mov    %eax,%ebx
  801460:	85 c0                	test   %eax,%eax
  801462:	78 3b                	js     80149f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801467:	89 c2                	mov    %eax,%edx
  801469:	c1 ea 0c             	shr    $0xc,%edx
  80146c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801473:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801479:	89 54 24 10          	mov    %edx,0x10(%esp)
  80147d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801481:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801488:	00 
  801489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801494:	e8 a4 fa ff ff       	call   800f3d <sys_page_map>
  801499:	89 c3                	mov    %eax,%ebx
  80149b:	85 c0                	test   %eax,%eax
  80149d:	79 25                	jns    8014c4 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80149f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014aa:	e8 e1 fa ff ff       	call   800f90 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014bd:	e8 ce fa ff ff       	call   800f90 <sys_page_unmap>
	return r;
  8014c2:	eb 02                	jmp    8014c6 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014c4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014c6:	89 d8                	mov    %ebx,%eax
  8014c8:	83 c4 4c             	add    $0x4c,%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 24             	sub    $0x24,%esp
  8014d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e1:	89 1c 24             	mov    %ebx,(%esp)
  8014e4:	e8 49 fd ff ff       	call   801232 <fd_lookup>
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 6d                	js     80155a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f7:	8b 00                	mov    (%eax),%eax
  8014f9:	89 04 24             	mov    %eax,(%esp)
  8014fc:	e8 87 fd ff ff       	call   801288 <dev_lookup>
  801501:	85 c0                	test   %eax,%eax
  801503:	78 55                	js     80155a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801505:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801508:	8b 50 08             	mov    0x8(%eax),%edx
  80150b:	83 e2 03             	and    $0x3,%edx
  80150e:	83 fa 01             	cmp    $0x1,%edx
  801511:	75 23                	jne    801536 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801513:	a1 90 77 80 00       	mov    0x807790,%eax
  801518:	8b 40 48             	mov    0x48(%eax),%eax
  80151b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80151f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801523:	c7 04 24 51 32 80 00 	movl   $0x803251,(%esp)
  80152a:	e8 1d f0 ff ff       	call   80054c <cprintf>
		return -E_INVAL;
  80152f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801534:	eb 24                	jmp    80155a <read+0x8a>
	}
	if (!dev->dev_read)
  801536:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801539:	8b 52 08             	mov    0x8(%edx),%edx
  80153c:	85 d2                	test   %edx,%edx
  80153e:	74 15                	je     801555 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801540:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801543:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801547:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80154e:	89 04 24             	mov    %eax,(%esp)
  801551:	ff d2                	call   *%edx
  801553:	eb 05                	jmp    80155a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801555:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80155a:	83 c4 24             	add    $0x24,%esp
  80155d:	5b                   	pop    %ebx
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    

00801560 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	57                   	push   %edi
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	83 ec 1c             	sub    $0x1c,%esp
  801569:	8b 7d 08             	mov    0x8(%ebp),%edi
  80156c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801574:	eb 23                	jmp    801599 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801576:	89 f0                	mov    %esi,%eax
  801578:	29 d8                	sub    %ebx,%eax
  80157a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80157e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801581:	01 d8                	add    %ebx,%eax
  801583:	89 44 24 04          	mov    %eax,0x4(%esp)
  801587:	89 3c 24             	mov    %edi,(%esp)
  80158a:	e8 41 ff ff ff       	call   8014d0 <read>
		if (m < 0)
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 10                	js     8015a3 <readn+0x43>
			return m;
		if (m == 0)
  801593:	85 c0                	test   %eax,%eax
  801595:	74 0a                	je     8015a1 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801597:	01 c3                	add    %eax,%ebx
  801599:	39 f3                	cmp    %esi,%ebx
  80159b:	72 d9                	jb     801576 <readn+0x16>
  80159d:	89 d8                	mov    %ebx,%eax
  80159f:	eb 02                	jmp    8015a3 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015a1:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015a3:	83 c4 1c             	add    $0x1c,%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
  8015a8:	5f                   	pop    %edi
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    

008015ab <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 24             	sub    $0x24,%esp
  8015b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bc:	89 1c 24             	mov    %ebx,(%esp)
  8015bf:	e8 6e fc ff ff       	call   801232 <fd_lookup>
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 68                	js     801630 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d2:	8b 00                	mov    (%eax),%eax
  8015d4:	89 04 24             	mov    %eax,(%esp)
  8015d7:	e8 ac fc ff ff       	call   801288 <dev_lookup>
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 50                	js     801630 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e7:	75 23                	jne    80160c <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e9:	a1 90 77 80 00       	mov    0x807790,%eax
  8015ee:	8b 40 48             	mov    0x48(%eax),%eax
  8015f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f9:	c7 04 24 6d 32 80 00 	movl   $0x80326d,(%esp)
  801600:	e8 47 ef ff ff       	call   80054c <cprintf>
		return -E_INVAL;
  801605:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80160a:	eb 24                	jmp    801630 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80160c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160f:	8b 52 0c             	mov    0xc(%edx),%edx
  801612:	85 d2                	test   %edx,%edx
  801614:	74 15                	je     80162b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801616:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801619:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80161d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801620:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801624:	89 04 24             	mov    %eax,(%esp)
  801627:	ff d2                	call   *%edx
  801629:	eb 05                	jmp    801630 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80162b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801630:	83 c4 24             	add    $0x24,%esp
  801633:	5b                   	pop    %ebx
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    

00801636 <seek>:

int
seek(int fdnum, off_t offset)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80163c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80163f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801643:	8b 45 08             	mov    0x8(%ebp),%eax
  801646:	89 04 24             	mov    %eax,(%esp)
  801649:	e8 e4 fb ff ff       	call   801232 <fd_lookup>
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 0e                	js     801660 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801652:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801655:	8b 55 0c             	mov    0xc(%ebp),%edx
  801658:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80165b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	53                   	push   %ebx
  801666:	83 ec 24             	sub    $0x24,%esp
  801669:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801673:	89 1c 24             	mov    %ebx,(%esp)
  801676:	e8 b7 fb ff ff       	call   801232 <fd_lookup>
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 61                	js     8016e0 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801682:	89 44 24 04          	mov    %eax,0x4(%esp)
  801686:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801689:	8b 00                	mov    (%eax),%eax
  80168b:	89 04 24             	mov    %eax,(%esp)
  80168e:	e8 f5 fb ff ff       	call   801288 <dev_lookup>
  801693:	85 c0                	test   %eax,%eax
  801695:	78 49                	js     8016e0 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169e:	75 23                	jne    8016c3 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016a0:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a5:	8b 40 48             	mov    0x48(%eax),%eax
  8016a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b0:	c7 04 24 30 32 80 00 	movl   $0x803230,(%esp)
  8016b7:	e8 90 ee ff ff       	call   80054c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c1:	eb 1d                	jmp    8016e0 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c6:	8b 52 18             	mov    0x18(%edx),%edx
  8016c9:	85 d2                	test   %edx,%edx
  8016cb:	74 0e                	je     8016db <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016d4:	89 04 24             	mov    %eax,(%esp)
  8016d7:	ff d2                	call   *%edx
  8016d9:	eb 05                	jmp    8016e0 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016e0:	83 c4 24             	add    $0x24,%esp
  8016e3:	5b                   	pop    %ebx
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 24             	sub    $0x24,%esp
  8016ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fa:	89 04 24             	mov    %eax,(%esp)
  8016fd:	e8 30 fb ff ff       	call   801232 <fd_lookup>
  801702:	85 c0                	test   %eax,%eax
  801704:	78 52                	js     801758 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801710:	8b 00                	mov    (%eax),%eax
  801712:	89 04 24             	mov    %eax,(%esp)
  801715:	e8 6e fb ff ff       	call   801288 <dev_lookup>
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 3a                	js     801758 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80171e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801721:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801725:	74 2c                	je     801753 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801727:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80172a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801731:	00 00 00 
	stat->st_isdir = 0;
  801734:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80173b:	00 00 00 
	stat->st_dev = dev;
  80173e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801748:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80174b:	89 14 24             	mov    %edx,(%esp)
  80174e:	ff 50 14             	call   *0x14(%eax)
  801751:	eb 05                	jmp    801758 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801753:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801758:	83 c4 24             	add    $0x24,%esp
  80175b:	5b                   	pop    %ebx
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	56                   	push   %esi
  801762:	53                   	push   %ebx
  801763:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801766:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80176d:	00 
  80176e:	8b 45 08             	mov    0x8(%ebp),%eax
  801771:	89 04 24             	mov    %eax,(%esp)
  801774:	e8 2a 02 00 00       	call   8019a3 <open>
  801779:	89 c3                	mov    %eax,%ebx
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 1b                	js     80179a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80177f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801782:	89 44 24 04          	mov    %eax,0x4(%esp)
  801786:	89 1c 24             	mov    %ebx,(%esp)
  801789:	e8 58 ff ff ff       	call   8016e6 <fstat>
  80178e:	89 c6                	mov    %eax,%esi
	close(fd);
  801790:	89 1c 24             	mov    %ebx,(%esp)
  801793:	e8 d2 fb ff ff       	call   80136a <close>
	return r;
  801798:	89 f3                	mov    %esi,%ebx
}
  80179a:	89 d8                	mov    %ebx,%eax
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    
	...

008017a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	56                   	push   %esi
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 10             	sub    $0x10,%esp
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017b0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8017b7:	75 11                	jne    8017ca <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017c0:	e8 c2 12 00 00       	call   802a87 <ipc_find_env>
  8017c5:	a3 00 60 80 00       	mov    %eax,0x806000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017d1:	00 
  8017d2:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  8017d9:	00 
  8017da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017de:	a1 00 60 80 00       	mov    0x806000,%eax
  8017e3:	89 04 24             	mov    %eax,(%esp)
  8017e6:	e8 19 12 00 00       	call   802a04 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017f2:	00 
  8017f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fe:	e8 91 11 00 00       	call   802994 <ipc_recv>
}
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	5b                   	pop    %ebx
  801807:	5e                   	pop    %esi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	8b 40 0c             	mov    0xc(%eax),%eax
  801816:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  80181b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181e:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 02 00 00 00       	mov    $0x2,%eax
  80182d:	e8 72 ff ff ff       	call   8017a4 <fsipc>
}
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	8b 40 0c             	mov    0xc(%eax),%eax
  801840:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801845:	ba 00 00 00 00       	mov    $0x0,%edx
  80184a:	b8 06 00 00 00       	mov    $0x6,%eax
  80184f:	e8 50 ff ff ff       	call   8017a4 <fsipc>
}
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	83 ec 14             	sub    $0x14,%esp
  80185d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801860:	8b 45 08             	mov    0x8(%ebp),%eax
  801863:	8b 40 0c             	mov    0xc(%eax),%eax
  801866:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	b8 05 00 00 00       	mov    $0x5,%eax
  801875:	e8 2a ff ff ff       	call   8017a4 <fsipc>
  80187a:	85 c0                	test   %eax,%eax
  80187c:	78 2b                	js     8018a9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80187e:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801885:	00 
  801886:	89 1c 24             	mov    %ebx,(%esp)
  801889:	e8 69 f2 ff ff       	call   800af7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80188e:	a1 80 80 80 00       	mov    0x808080,%eax
  801893:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801899:	a1 84 80 80 00       	mov    0x808084,%eax
  80189e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a9:	83 c4 14             	add    $0x14,%esp
  8018ac:	5b                   	pop    %ebx
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 18             	sub    $0x18,%esp
  8018b5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018bb:	8b 52 0c             	mov    0xc(%edx),%edx
  8018be:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  8018c4:	a3 04 80 80 00       	mov    %eax,0x808004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8018c9:	89 c2                	mov    %eax,%edx
  8018cb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018d0:	76 05                	jbe    8018d7 <devfile_write+0x28>
  8018d2:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8018d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	c7 04 24 08 80 80 00 	movl   $0x808008,(%esp)
  8018e9:	e8 ec f3 ff ff       	call   800cda <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f8:	e8 a7 fe ff ff       	call   8017a4 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	83 ec 10             	sub    $0x10,%esp
  801907:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80190a:	8b 45 08             	mov    0x8(%ebp),%eax
  80190d:	8b 40 0c             	mov    0xc(%eax),%eax
  801910:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801915:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80191b:	ba 00 00 00 00       	mov    $0x0,%edx
  801920:	b8 03 00 00 00       	mov    $0x3,%eax
  801925:	e8 7a fe ff ff       	call   8017a4 <fsipc>
  80192a:	89 c3                	mov    %eax,%ebx
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 6a                	js     80199a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801930:	39 c6                	cmp    %eax,%esi
  801932:	73 24                	jae    801958 <devfile_read+0x59>
  801934:	c7 44 24 0c a0 32 80 	movl   $0x8032a0,0xc(%esp)
  80193b:	00 
  80193c:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  801943:	00 
  801944:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80194b:	00 
  80194c:	c7 04 24 bc 32 80 00 	movl   $0x8032bc,(%esp)
  801953:	e8 fc ea ff ff       	call   800454 <_panic>
	assert(r <= PGSIZE);
  801958:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195d:	7e 24                	jle    801983 <devfile_read+0x84>
  80195f:	c7 44 24 0c c7 32 80 	movl   $0x8032c7,0xc(%esp)
  801966:	00 
  801967:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  80196e:	00 
  80196f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801976:	00 
  801977:	c7 04 24 bc 32 80 00 	movl   $0x8032bc,(%esp)
  80197e:	e8 d1 ea ff ff       	call   800454 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801983:	89 44 24 08          	mov    %eax,0x8(%esp)
  801987:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  80198e:	00 
  80198f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801992:	89 04 24             	mov    %eax,(%esp)
  801995:	e8 d6 f2 ff ff       	call   800c70 <memmove>
	return r;
}
  80199a:	89 d8                	mov    %ebx,%eax
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 20             	sub    $0x20,%esp
  8019ab:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019ae:	89 34 24             	mov    %esi,(%esp)
  8019b1:	e8 0e f1 ff ff       	call   800ac4 <strlen>
  8019b6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019bb:	7f 60                	jg     801a1d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c0:	89 04 24             	mov    %eax,(%esp)
  8019c3:	e8 17 f8 ff ff       	call   8011df <fd_alloc>
  8019c8:	89 c3                	mov    %eax,%ebx
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 54                	js     801a22 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019d2:	c7 04 24 00 80 80 00 	movl   $0x808000,(%esp)
  8019d9:	e8 19 f1 ff ff       	call   800af7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e1:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ee:	e8 b1 fd ff ff       	call   8017a4 <fsipc>
  8019f3:	89 c3                	mov    %eax,%ebx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	79 15                	jns    801a0e <open+0x6b>
		fd_close(fd, 0);
  8019f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a00:	00 
  801a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a04:	89 04 24             	mov    %eax,(%esp)
  801a07:	e8 d6 f8 ff ff       	call   8012e2 <fd_close>
		return r;
  801a0c:	eb 14                	jmp    801a22 <open+0x7f>
	}

	return fd2num(fd);
  801a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a11:	89 04 24             	mov    %eax,(%esp)
  801a14:	e8 9b f7 ff ff       	call   8011b4 <fd2num>
  801a19:	89 c3                	mov    %eax,%ebx
  801a1b:	eb 05                	jmp    801a22 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a1d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a22:	89 d8                	mov    %ebx,%eax
  801a24:	83 c4 20             	add    $0x20,%esp
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3b:	e8 64 fd ff ff       	call   8017a4 <fsipc>
}
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    
	...

00801a44 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	57                   	push   %edi
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a57:	00 
  801a58:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5b:	89 04 24             	mov    %eax,(%esp)
  801a5e:	e8 40 ff ff ff       	call   8019a3 <open>
  801a63:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	0f 88 a9 05 00 00    	js     80201a <spawn+0x5d6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a71:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a78:	00 
  801a79:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a83:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a89:	89 04 24             	mov    %eax,(%esp)
  801a8c:	e8 cf fa ff ff       	call   801560 <readn>
  801a91:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a96:	75 0c                	jne    801aa4 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801a98:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a9f:	45 4c 46 
  801aa2:	74 3b                	je     801adf <spawn+0x9b>
		close(fd);
  801aa4:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	e8 b8 f8 ff ff       	call   80136a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ab2:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801ab9:	46 
  801aba:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac4:	c7 04 24 d3 32 80 00 	movl   $0x8032d3,(%esp)
  801acb:	e8 7c ea ff ff       	call   80054c <cprintf>
		return -E_NOT_EXEC;
  801ad0:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  801ad7:	ff ff ff 
  801ada:	e9 47 05 00 00       	jmp    802026 <spawn+0x5e2>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801adf:	ba 07 00 00 00       	mov    $0x7,%edx
  801ae4:	89 d0                	mov    %edx,%eax
  801ae6:	cd 30                	int    $0x30
  801ae8:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801aee:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801af4:	85 c0                	test   %eax,%eax
  801af6:	0f 88 2a 05 00 00    	js     802026 <spawn+0x5e2>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801afc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b01:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b08:	c1 e0 07             	shl    $0x7,%eax
  801b0b:	29 d0                	sub    %edx,%eax
  801b0d:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801b13:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801b19:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b20:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b26:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b2c:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801b31:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b36:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b39:	eb 0d                	jmp    801b48 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801b3b:	89 04 24             	mov    %eax,(%esp)
  801b3e:	e8 81 ef ff ff       	call   800ac4 <strlen>
  801b43:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b47:	46                   	inc    %esi
  801b48:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b4a:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b51:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801b54:	85 c0                	test   %eax,%eax
  801b56:	75 e3                	jne    801b3b <spawn+0xf7>
  801b58:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801b5e:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b64:	bf 00 10 40 00       	mov    $0x401000,%edi
  801b69:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b6b:	89 f8                	mov    %edi,%eax
  801b6d:	83 e0 fc             	and    $0xfffffffc,%eax
  801b70:	f7 d2                	not    %edx
  801b72:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801b75:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	83 e8 08             	sub    $0x8,%eax
  801b80:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b85:	0f 86 ac 04 00 00    	jbe    802037 <spawn+0x5f3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b8b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b92:	00 
  801b93:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b9a:	00 
  801b9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba2:	e8 42 f3 ff ff       	call   800ee9 <sys_page_alloc>
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	0f 88 8d 04 00 00    	js     80203c <spawn+0x5f8>
  801baf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb4:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801bba:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bbd:	eb 2e                	jmp    801bed <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801bbf:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801bc5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801bcb:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801bce:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd5:	89 3c 24             	mov    %edi,(%esp)
  801bd8:	e8 1a ef ff ff       	call   800af7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801bdd:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801be0:	89 04 24             	mov    %eax,(%esp)
  801be3:	e8 dc ee ff ff       	call   800ac4 <strlen>
  801be8:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801bec:	43                   	inc    %ebx
  801bed:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801bf3:	7c ca                	jl     801bbf <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801bf5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801bfb:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c01:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c08:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c0e:	74 24                	je     801c34 <spawn+0x1f0>
  801c10:	c7 44 24 0c 5c 33 80 	movl   $0x80335c,0xc(%esp)
  801c17:	00 
  801c18:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  801c1f:	00 
  801c20:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801c27:	00 
  801c28:	c7 04 24 ed 32 80 00 	movl   $0x8032ed,(%esp)
  801c2f:	e8 20 e8 ff ff       	call   800454 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c34:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c3a:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c3f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c45:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801c48:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c4e:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c51:	89 d0                	mov    %edx,%eax
  801c53:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801c58:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c5e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c65:	00 
  801c66:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801c6d:	ee 
  801c6e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c74:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c78:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c7f:	00 
  801c80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c87:	e8 b1 f2 ff ff       	call   800f3d <sys_page_map>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 1a                	js     801cac <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c92:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c99:	00 
  801c9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca1:	e8 ea f2 ff ff       	call   800f90 <sys_page_unmap>
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	79 1f                	jns    801ccb <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801cac:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cb3:	00 
  801cb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cbb:	e8 d0 f2 ff ff       	call   800f90 <sys_page_unmap>
	return r;
  801cc0:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801cc6:	e9 5b 03 00 00       	jmp    802026 <spawn+0x5e2>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ccb:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801cd1:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801cd7:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cdd:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801ce4:	00 00 00 
  801ce7:	e9 bb 01 00 00       	jmp    801ea7 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801cec:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cf2:	83 38 01             	cmpl   $0x1,(%eax)
  801cf5:	0f 85 9f 01 00 00    	jne    801e9a <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801cfb:	89 c2                	mov    %eax,%edx
  801cfd:	8b 40 18             	mov    0x18(%eax),%eax
  801d00:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801d03:	83 f8 01             	cmp    $0x1,%eax
  801d06:	19 c0                	sbb    %eax,%eax
  801d08:	83 e0 fe             	and    $0xfffffffe,%eax
  801d0b:	83 c0 07             	add    $0x7,%eax
  801d0e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d14:	8b 52 04             	mov    0x4(%edx),%edx
  801d17:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801d1d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d23:	8b 40 10             	mov    0x10(%eax),%eax
  801d26:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d2c:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801d32:	8b 52 14             	mov    0x14(%edx),%edx
  801d35:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801d3b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d41:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d44:	89 f8                	mov    %edi,%eax
  801d46:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d4b:	74 16                	je     801d63 <spawn+0x31f>
		va -= i;
  801d4d:	29 c7                	sub    %eax,%edi
		memsz += i;
  801d4f:	01 c2                	add    %eax,%edx
  801d51:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801d57:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801d5d:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d68:	e9 1f 01 00 00       	jmp    801e8c <spawn+0x448>
		if (i >= filesz) {
  801d6d:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  801d73:	72 2b                	jb     801da0 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d75:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801d7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d7f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d83:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d89:	89 04 24             	mov    %eax,(%esp)
  801d8c:	e8 58 f1 ff ff       	call   800ee9 <sys_page_alloc>
  801d91:	85 c0                	test   %eax,%eax
  801d93:	0f 89 e7 00 00 00    	jns    801e80 <spawn+0x43c>
  801d99:	89 c6                	mov    %eax,%esi
  801d9b:	e9 56 02 00 00       	jmp    801ff6 <spawn+0x5b2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801da0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801da7:	00 
  801da8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801daf:	00 
  801db0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db7:	e8 2d f1 ff ff       	call   800ee9 <sys_page_alloc>
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	0f 88 28 02 00 00    	js     801fec <spawn+0x5a8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801dc4:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801dca:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801dd6:	89 04 24             	mov    %eax,(%esp)
  801dd9:	e8 58 f8 ff ff       	call   801636 <seek>
  801dde:	85 c0                	test   %eax,%eax
  801de0:	0f 88 0a 02 00 00    	js     801ff0 <spawn+0x5ac>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801de6:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dec:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801dee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801df3:	76 05                	jbe    801dfa <spawn+0x3b6>
  801df5:	b8 00 10 00 00       	mov    $0x1000,%eax
  801dfa:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dfe:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e05:	00 
  801e06:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e0c:	89 04 24             	mov    %eax,(%esp)
  801e0f:	e8 4c f7 ff ff       	call   801560 <readn>
  801e14:	85 c0                	test   %eax,%eax
  801e16:	0f 88 d8 01 00 00    	js     801ff4 <spawn+0x5b0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e1c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801e22:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e26:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e2a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e30:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e34:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e3b:	00 
  801e3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e43:	e8 f5 f0 ff ff       	call   800f3d <sys_page_map>
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	79 20                	jns    801e6c <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801e4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e50:	c7 44 24 08 f9 32 80 	movl   $0x8032f9,0x8(%esp)
  801e57:	00 
  801e58:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801e5f:	00 
  801e60:	c7 04 24 ed 32 80 00 	movl   $0x8032ed,(%esp)
  801e67:	e8 e8 e5 ff ff       	call   800454 <_panic>
			sys_page_unmap(0, UTEMP);
  801e6c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e73:	00 
  801e74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e7b:	e8 10 f1 ff ff       	call   800f90 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e80:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e86:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801e8c:	89 de                	mov    %ebx,%esi
  801e8e:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801e94:	0f 82 d3 fe ff ff    	jb     801d6d <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e9a:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801ea0:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801ea7:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801eae:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801eb4:	0f 8c 32 fe ff ff    	jl     801cec <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801eba:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ec0:	89 04 24             	mov    %eax,(%esp)
  801ec3:	e8 a2 f4 ff ff       	call   80136a <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  801ec8:	be 00 00 00 00       	mov    $0x0,%esi
  801ecd:	eb 0c                	jmp    801edb <spawn+0x497>
	{
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  801ecf:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801ed5:	0f 84 91 00 00 00    	je     801f6c <spawn+0x528>
  801edb:	89 f0                	mov    %esi,%eax
  801edd:	c1 e8 16             	shr    $0x16,%eax
  801ee0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ee7:	a8 01                	test   $0x1,%al
  801ee9:	74 6f                	je     801f5a <spawn+0x516>
  801eeb:	89 f0                	mov    %esi,%eax
  801eed:	c1 e8 0c             	shr    $0xc,%eax
  801ef0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ef7:	f6 c2 01             	test   $0x1,%dl
  801efa:	74 5e                	je     801f5a <spawn+0x516>
		{
			continue;
		}
		if ((uvpt[PGNUM(addr)] & PTE_SHARE))
  801efc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801f03:	f6 c6 04             	test   $0x4,%dh
  801f06:	74 52                	je     801f5a <spawn+0x516>
		{
			if ((e = sys_page_map(0, (void *)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  801f08:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f0f:	25 07 0e 00 00       	and    $0xe07,%eax
  801f14:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f18:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f1c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f31:	e8 07 f0 ff ff       	call   800f3d <sys_page_map>
  801f36:	85 c0                	test   %eax,%eax
  801f38:	79 20                	jns    801f5a <spawn+0x516>
			{
				panic("duppage error: %e", e);
  801f3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3e:	c7 44 24 08 16 33 80 	movl   $0x803316,0x8(%esp)
  801f45:	00 
  801f46:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  801f4d:	00 
  801f4e:	c7 04 24 ed 32 80 00 	movl   $0x8032ed,(%esp)
  801f55:	e8 fa e4 ff ff       	call   800454 <_panic>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  801f5a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f60:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  801f66:	0f 85 63 ff ff ff    	jne    801ecf <spawn+0x48b>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801f6c:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801f73:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f76:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f80:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f86:	89 04 24             	mov    %eax,(%esp)
  801f89:	e8 a8 f0 ff ff       	call   801036 <sys_env_set_trapframe>
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	79 20                	jns    801fb2 <spawn+0x56e>
		panic("sys_env_set_trapframe: %e", r);
  801f92:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f96:	c7 44 24 08 28 33 80 	movl   $0x803328,0x8(%esp)
  801f9d:	00 
  801f9e:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801fa5:	00 
  801fa6:	c7 04 24 ed 32 80 00 	movl   $0x8032ed,(%esp)
  801fad:	e8 a2 e4 ff ff       	call   800454 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801fb2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801fb9:	00 
  801fba:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fc0:	89 04 24             	mov    %eax,(%esp)
  801fc3:	e8 1b f0 ff ff       	call   800fe3 <sys_env_set_status>
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	79 5a                	jns    802026 <spawn+0x5e2>
		panic("sys_env_set_status: %e", r);
  801fcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fd0:	c7 44 24 08 42 33 80 	movl   $0x803342,0x8(%esp)
  801fd7:	00 
  801fd8:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801fdf:	00 
  801fe0:	c7 04 24 ed 32 80 00 	movl   $0x8032ed,(%esp)
  801fe7:	e8 68 e4 ff ff       	call   800454 <_panic>
  801fec:	89 c6                	mov    %eax,%esi
  801fee:	eb 06                	jmp    801ff6 <spawn+0x5b2>
  801ff0:	89 c6                	mov    %eax,%esi
  801ff2:	eb 02                	jmp    801ff6 <spawn+0x5b2>
  801ff4:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801ff6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ffc:	89 04 24             	mov    %eax,(%esp)
  801fff:	e8 55 ee ff ff       	call   800e59 <sys_env_destroy>
	close(fd);
  802004:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80200a:	89 04 24             	mov    %eax,(%esp)
  80200d:	e8 58 f3 ff ff       	call   80136a <close>
	return r;
  802012:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  802018:	eb 0c                	jmp    802026 <spawn+0x5e2>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80201a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802020:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802026:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80202c:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802032:	5b                   	pop    %ebx
  802033:	5e                   	pop    %esi
  802034:	5f                   	pop    %edi
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802037:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  80203c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802042:	eb e2                	jmp    802026 <spawn+0x5e2>

00802044 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	57                   	push   %edi
  802048:	56                   	push   %esi
  802049:	53                   	push   %ebx
  80204a:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  80204d:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802050:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802055:	eb 03                	jmp    80205a <spawnl+0x16>
		argc++;
  802057:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802058:	89 d0                	mov    %edx,%eax
  80205a:	8d 50 04             	lea    0x4(%eax),%edx
  80205d:	83 38 00             	cmpl   $0x0,(%eax)
  802060:	75 f5                	jne    802057 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802062:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802069:	83 e0 f0             	and    $0xfffffff0,%eax
  80206c:	29 c4                	sub    %eax,%esp
  80206e:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802072:	83 e7 f0             	and    $0xfffffff0,%edi
  802075:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802077:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207a:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  80207c:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802083:	00 

	va_start(vl, arg0);
  802084:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
  80208c:	eb 09                	jmp    802097 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  80208e:	40                   	inc    %eax
  80208f:	8b 1a                	mov    (%edx),%ebx
  802091:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802094:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802097:	39 c8                	cmp    %ecx,%eax
  802099:	75 f3                	jne    80208e <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80209b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80209f:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a2:	89 04 24             	mov    %eax,(%esp)
  8020a5:	e8 9a f9 ff ff       	call   801a44 <spawn>
}
  8020aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
	...

008020b4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8020ba:	c7 44 24 04 84 33 80 	movl   $0x803384,0x4(%esp)
  8020c1:	00 
  8020c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c5:	89 04 24             	mov    %eax,(%esp)
  8020c8:	e8 2a ea ff ff       	call   800af7 <strcpy>
	return 0;
}
  8020cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d2:	c9                   	leave  
  8020d3:	c3                   	ret    

008020d4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	53                   	push   %ebx
  8020d8:	83 ec 14             	sub    $0x14,%esp
  8020db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8020de:	89 1c 24             	mov    %ebx,(%esp)
  8020e1:	e8 e6 09 00 00       	call   802acc <pageref>
  8020e6:	83 f8 01             	cmp    $0x1,%eax
  8020e9:	75 0d                	jne    8020f8 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8020eb:	8b 43 0c             	mov    0xc(%ebx),%eax
  8020ee:	89 04 24             	mov    %eax,(%esp)
  8020f1:	e8 1f 03 00 00       	call   802415 <nsipc_close>
  8020f6:	eb 05                	jmp    8020fd <devsock_close+0x29>
	else
		return 0;
  8020f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020fd:	83 c4 14             	add    $0x14,%esp
  802100:	5b                   	pop    %ebx
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    

00802103 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802109:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802110:	00 
  802111:	8b 45 10             	mov    0x10(%ebp),%eax
  802114:	89 44 24 08          	mov    %eax,0x8(%esp)
  802118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80211f:	8b 45 08             	mov    0x8(%ebp),%eax
  802122:	8b 40 0c             	mov    0xc(%eax),%eax
  802125:	89 04 24             	mov    %eax,(%esp)
  802128:	e8 e3 03 00 00       	call   802510 <nsipc_send>
}
  80212d:	c9                   	leave  
  80212e:	c3                   	ret    

0080212f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80212f:	55                   	push   %ebp
  802130:	89 e5                	mov    %esp,%ebp
  802132:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802135:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80213c:	00 
  80213d:	8b 45 10             	mov    0x10(%ebp),%eax
  802140:	89 44 24 08          	mov    %eax,0x8(%esp)
  802144:	8b 45 0c             	mov    0xc(%ebp),%eax
  802147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80214b:	8b 45 08             	mov    0x8(%ebp),%eax
  80214e:	8b 40 0c             	mov    0xc(%eax),%eax
  802151:	89 04 24             	mov    %eax,(%esp)
  802154:	e8 37 03 00 00       	call   802490 <nsipc_recv>
}
  802159:	c9                   	leave  
  80215a:	c3                   	ret    

0080215b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80215b:	55                   	push   %ebp
  80215c:	89 e5                	mov    %esp,%ebp
  80215e:	56                   	push   %esi
  80215f:	53                   	push   %ebx
  802160:	83 ec 20             	sub    $0x20,%esp
  802163:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802165:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802168:	89 04 24             	mov    %eax,(%esp)
  80216b:	e8 6f f0 ff ff       	call   8011df <fd_alloc>
  802170:	89 c3                	mov    %eax,%ebx
  802172:	85 c0                	test   %eax,%eax
  802174:	78 21                	js     802197 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802176:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80217d:	00 
  80217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802181:	89 44 24 04          	mov    %eax,0x4(%esp)
  802185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80218c:	e8 58 ed ff ff       	call   800ee9 <sys_page_alloc>
  802191:	89 c3                	mov    %eax,%ebx
  802193:	85 c0                	test   %eax,%eax
  802195:	79 0a                	jns    8021a1 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  802197:	89 34 24             	mov    %esi,(%esp)
  80219a:	e8 76 02 00 00       	call   802415 <nsipc_close>
		return r;
  80219f:	eb 22                	jmp    8021c3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8021a1:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  8021a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021aa:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8021ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8021b6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8021b9:	89 04 24             	mov    %eax,(%esp)
  8021bc:	e8 f3 ef ff ff       	call   8011b4 <fd2num>
  8021c1:	89 c3                	mov    %eax,%ebx
}
  8021c3:	89 d8                	mov    %ebx,%eax
  8021c5:	83 c4 20             	add    $0x20,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    

008021cc <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8021d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8021d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d9:	89 04 24             	mov    %eax,(%esp)
  8021dc:	e8 51 f0 ff ff       	call   801232 <fd_lookup>
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	78 17                	js     8021fc <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8021e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e8:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  8021ee:	39 10                	cmp    %edx,(%eax)
  8021f0:	75 05                	jne    8021f7 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8021f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8021f5:	eb 05                	jmp    8021fc <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8021f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    

008021fe <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802204:	8b 45 08             	mov    0x8(%ebp),%eax
  802207:	e8 c0 ff ff ff       	call   8021cc <fd2sockid>
  80220c:	85 c0                	test   %eax,%eax
  80220e:	78 1f                	js     80222f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802210:	8b 55 10             	mov    0x10(%ebp),%edx
  802213:	89 54 24 08          	mov    %edx,0x8(%esp)
  802217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80221e:	89 04 24             	mov    %eax,(%esp)
  802221:	e8 38 01 00 00       	call   80235e <nsipc_accept>
  802226:	85 c0                	test   %eax,%eax
  802228:	78 05                	js     80222f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80222a:	e8 2c ff ff ff       	call   80215b <alloc_sockfd>
}
  80222f:	c9                   	leave  
  802230:	c3                   	ret    

00802231 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802237:	8b 45 08             	mov    0x8(%ebp),%eax
  80223a:	e8 8d ff ff ff       	call   8021cc <fd2sockid>
  80223f:	85 c0                	test   %eax,%eax
  802241:	78 16                	js     802259 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802243:	8b 55 10             	mov    0x10(%ebp),%edx
  802246:	89 54 24 08          	mov    %edx,0x8(%esp)
  80224a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80224d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802251:	89 04 24             	mov    %eax,(%esp)
  802254:	e8 5b 01 00 00       	call   8023b4 <nsipc_bind>
}
  802259:	c9                   	leave  
  80225a:	c3                   	ret    

0080225b <shutdown>:

int
shutdown(int s, int how)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802261:	8b 45 08             	mov    0x8(%ebp),%eax
  802264:	e8 63 ff ff ff       	call   8021cc <fd2sockid>
  802269:	85 c0                	test   %eax,%eax
  80226b:	78 0f                	js     80227c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80226d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802270:	89 54 24 04          	mov    %edx,0x4(%esp)
  802274:	89 04 24             	mov    %eax,(%esp)
  802277:	e8 77 01 00 00       	call   8023f3 <nsipc_shutdown>
}
  80227c:	c9                   	leave  
  80227d:	c3                   	ret    

0080227e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802284:	8b 45 08             	mov    0x8(%ebp),%eax
  802287:	e8 40 ff ff ff       	call   8021cc <fd2sockid>
  80228c:	85 c0                	test   %eax,%eax
  80228e:	78 16                	js     8022a6 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802290:	8b 55 10             	mov    0x10(%ebp),%edx
  802293:	89 54 24 08          	mov    %edx,0x8(%esp)
  802297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80229a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80229e:	89 04 24             	mov    %eax,(%esp)
  8022a1:	e8 89 01 00 00       	call   80242f <nsipc_connect>
}
  8022a6:	c9                   	leave  
  8022a7:	c3                   	ret    

008022a8 <listen>:

int
listen(int s, int backlog)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b1:	e8 16 ff ff ff       	call   8021cc <fd2sockid>
  8022b6:	85 c0                	test   %eax,%eax
  8022b8:	78 0f                	js     8022c9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8022ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c1:	89 04 24             	mov    %eax,(%esp)
  8022c4:	e8 a5 01 00 00       	call   80246e <nsipc_listen>
}
  8022c9:	c9                   	leave  
  8022ca:	c3                   	ret    

008022cb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8022d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8022d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022df:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e2:	89 04 24             	mov    %eax,(%esp)
  8022e5:	e8 99 02 00 00       	call   802583 <nsipc_socket>
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	78 05                	js     8022f3 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8022ee:	e8 68 fe ff ff       	call   80215b <alloc_sockfd>
}
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    
  8022f5:	00 00                	add    %al,(%eax)
	...

008022f8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8022f8:	55                   	push   %ebp
  8022f9:	89 e5                	mov    %esp,%ebp
  8022fb:	53                   	push   %ebx
  8022fc:	83 ec 14             	sub    $0x14,%esp
  8022ff:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802301:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  802308:	75 11                	jne    80231b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80230a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802311:	e8 71 07 00 00       	call   802a87 <ipc_find_env>
  802316:	a3 04 60 80 00       	mov    %eax,0x806004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80231b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802322:	00 
  802323:	c7 44 24 08 00 90 80 	movl   $0x809000,0x8(%esp)
  80232a:	00 
  80232b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80232f:	a1 04 60 80 00       	mov    0x806004,%eax
  802334:	89 04 24             	mov    %eax,(%esp)
  802337:	e8 c8 06 00 00       	call   802a04 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80233c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802343:	00 
  802344:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80234b:	00 
  80234c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802353:	e8 3c 06 00 00       	call   802994 <ipc_recv>
}
  802358:	83 c4 14             	add    $0x14,%esp
  80235b:	5b                   	pop    %ebx
  80235c:	5d                   	pop    %ebp
  80235d:	c3                   	ret    

0080235e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80235e:	55                   	push   %ebp
  80235f:	89 e5                	mov    %esp,%ebp
  802361:	56                   	push   %esi
  802362:	53                   	push   %ebx
  802363:	83 ec 10             	sub    $0x10,%esp
  802366:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802369:	8b 45 08             	mov    0x8(%ebp),%eax
  80236c:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802371:	8b 06                	mov    (%esi),%eax
  802373:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802378:	b8 01 00 00 00       	mov    $0x1,%eax
  80237d:	e8 76 ff ff ff       	call   8022f8 <nsipc>
  802382:	89 c3                	mov    %eax,%ebx
  802384:	85 c0                	test   %eax,%eax
  802386:	78 23                	js     8023ab <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802388:	a1 10 90 80 00       	mov    0x809010,%eax
  80238d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802391:	c7 44 24 04 00 90 80 	movl   $0x809000,0x4(%esp)
  802398:	00 
  802399:	8b 45 0c             	mov    0xc(%ebp),%eax
  80239c:	89 04 24             	mov    %eax,(%esp)
  80239f:	e8 cc e8 ff ff       	call   800c70 <memmove>
		*addrlen = ret->ret_addrlen;
  8023a4:	a1 10 90 80 00       	mov    0x809010,%eax
  8023a9:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8023ab:	89 d8                	mov    %ebx,%eax
  8023ad:	83 c4 10             	add    $0x10,%esp
  8023b0:	5b                   	pop    %ebx
  8023b1:	5e                   	pop    %esi
  8023b2:	5d                   	pop    %ebp
  8023b3:	c3                   	ret    

008023b4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023b4:	55                   	push   %ebp
  8023b5:	89 e5                	mov    %esp,%ebp
  8023b7:	53                   	push   %ebx
  8023b8:	83 ec 14             	sub    $0x14,%esp
  8023bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8023be:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c1:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8023c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d1:	c7 04 24 04 90 80 00 	movl   $0x809004,(%esp)
  8023d8:	e8 93 e8 ff ff       	call   800c70 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8023dd:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  8023e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8023e8:	e8 0b ff ff ff       	call   8022f8 <nsipc>
}
  8023ed:	83 c4 14             	add    $0x14,%esp
  8023f0:	5b                   	pop    %ebx
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    

008023f3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8023f3:	55                   	push   %ebp
  8023f4:	89 e5                	mov    %esp,%ebp
  8023f6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8023f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fc:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  802401:	8b 45 0c             	mov    0xc(%ebp),%eax
  802404:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  802409:	b8 03 00 00 00       	mov    $0x3,%eax
  80240e:	e8 e5 fe ff ff       	call   8022f8 <nsipc>
}
  802413:	c9                   	leave  
  802414:	c3                   	ret    

00802415 <nsipc_close>:

int
nsipc_close(int s)
{
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80241b:	8b 45 08             	mov    0x8(%ebp),%eax
  80241e:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  802423:	b8 04 00 00 00       	mov    $0x4,%eax
  802428:	e8 cb fe ff ff       	call   8022f8 <nsipc>
}
  80242d:	c9                   	leave  
  80242e:	c3                   	ret    

0080242f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80242f:	55                   	push   %ebp
  802430:	89 e5                	mov    %esp,%ebp
  802432:	53                   	push   %ebx
  802433:	83 ec 14             	sub    $0x14,%esp
  802436:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802439:	8b 45 08             	mov    0x8(%ebp),%eax
  80243c:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802441:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802445:	8b 45 0c             	mov    0xc(%ebp),%eax
  802448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244c:	c7 04 24 04 90 80 00 	movl   $0x809004,(%esp)
  802453:	e8 18 e8 ff ff       	call   800c70 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802458:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  80245e:	b8 05 00 00 00       	mov    $0x5,%eax
  802463:	e8 90 fe ff ff       	call   8022f8 <nsipc>
}
  802468:	83 c4 14             	add    $0x14,%esp
  80246b:	5b                   	pop    %ebx
  80246c:	5d                   	pop    %ebp
  80246d:	c3                   	ret    

0080246e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80246e:	55                   	push   %ebp
  80246f:	89 e5                	mov    %esp,%ebp
  802471:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802474:	8b 45 08             	mov    0x8(%ebp),%eax
  802477:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  80247c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80247f:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  802484:	b8 06 00 00 00       	mov    $0x6,%eax
  802489:	e8 6a fe ff ff       	call   8022f8 <nsipc>
}
  80248e:	c9                   	leave  
  80248f:	c3                   	ret    

00802490 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	56                   	push   %esi
  802494:	53                   	push   %ebx
  802495:	83 ec 10             	sub    $0x10,%esp
  802498:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80249b:	8b 45 08             	mov    0x8(%ebp),%eax
  80249e:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  8024a3:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  8024a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8024ac:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8024b1:	b8 07 00 00 00       	mov    $0x7,%eax
  8024b6:	e8 3d fe ff ff       	call   8022f8 <nsipc>
  8024bb:	89 c3                	mov    %eax,%ebx
  8024bd:	85 c0                	test   %eax,%eax
  8024bf:	78 46                	js     802507 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8024c1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8024c6:	7f 04                	jg     8024cc <nsipc_recv+0x3c>
  8024c8:	39 c6                	cmp    %eax,%esi
  8024ca:	7d 24                	jge    8024f0 <nsipc_recv+0x60>
  8024cc:	c7 44 24 0c 90 33 80 	movl   $0x803390,0xc(%esp)
  8024d3:	00 
  8024d4:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  8024db:	00 
  8024dc:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8024e3:	00 
  8024e4:	c7 04 24 a5 33 80 00 	movl   $0x8033a5,(%esp)
  8024eb:	e8 64 df ff ff       	call   800454 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8024f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024f4:	c7 44 24 04 00 90 80 	movl   $0x809000,0x4(%esp)
  8024fb:	00 
  8024fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ff:	89 04 24             	mov    %eax,(%esp)
  802502:	e8 69 e7 ff ff       	call   800c70 <memmove>
	}

	return r;
}
  802507:	89 d8                	mov    %ebx,%eax
  802509:	83 c4 10             	add    $0x10,%esp
  80250c:	5b                   	pop    %ebx
  80250d:	5e                   	pop    %esi
  80250e:	5d                   	pop    %ebp
  80250f:	c3                   	ret    

00802510 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	53                   	push   %ebx
  802514:	83 ec 14             	sub    $0x14,%esp
  802517:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80251a:	8b 45 08             	mov    0x8(%ebp),%eax
  80251d:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  802522:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802528:	7e 24                	jle    80254e <nsipc_send+0x3e>
  80252a:	c7 44 24 0c b1 33 80 	movl   $0x8033b1,0xc(%esp)
  802531:	00 
  802532:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  802539:	00 
  80253a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802541:	00 
  802542:	c7 04 24 a5 33 80 00 	movl   $0x8033a5,(%esp)
  802549:	e8 06 df ff ff       	call   800454 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80254e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802552:	8b 45 0c             	mov    0xc(%ebp),%eax
  802555:	89 44 24 04          	mov    %eax,0x4(%esp)
  802559:	c7 04 24 0c 90 80 00 	movl   $0x80900c,(%esp)
  802560:	e8 0b e7 ff ff       	call   800c70 <memmove>
	nsipcbuf.send.req_size = size;
  802565:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  80256b:	8b 45 14             	mov    0x14(%ebp),%eax
  80256e:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  802573:	b8 08 00 00 00       	mov    $0x8,%eax
  802578:	e8 7b fd ff ff       	call   8022f8 <nsipc>
}
  80257d:	83 c4 14             	add    $0x14,%esp
  802580:	5b                   	pop    %ebx
  802581:	5d                   	pop    %ebp
  802582:	c3                   	ret    

00802583 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802583:	55                   	push   %ebp
  802584:	89 e5                	mov    %esp,%ebp
  802586:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802589:	8b 45 08             	mov    0x8(%ebp),%eax
  80258c:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  802591:	8b 45 0c             	mov    0xc(%ebp),%eax
  802594:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  802599:	8b 45 10             	mov    0x10(%ebp),%eax
  80259c:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  8025a1:	b8 09 00 00 00       	mov    $0x9,%eax
  8025a6:	e8 4d fd ff ff       	call   8022f8 <nsipc>
}
  8025ab:	c9                   	leave  
  8025ac:	c3                   	ret    
  8025ad:	00 00                	add    %al,(%eax)
	...

008025b0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8025b0:	55                   	push   %ebp
  8025b1:	89 e5                	mov    %esp,%ebp
  8025b3:	56                   	push   %esi
  8025b4:	53                   	push   %ebx
  8025b5:	83 ec 10             	sub    $0x10,%esp
  8025b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8025bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025be:	89 04 24             	mov    %eax,(%esp)
  8025c1:	e8 fe eb ff ff       	call   8011c4 <fd2data>
  8025c6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8025c8:	c7 44 24 04 bd 33 80 	movl   $0x8033bd,0x4(%esp)
  8025cf:	00 
  8025d0:	89 34 24             	mov    %esi,(%esp)
  8025d3:	e8 1f e5 ff ff       	call   800af7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8025d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8025db:	2b 03                	sub    (%ebx),%eax
  8025dd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8025e3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8025ea:	00 00 00 
	stat->st_dev = &devpipe;
  8025ed:	c7 86 88 00 00 00 c8 	movl   $0x8057c8,0x88(%esi)
  8025f4:	57 80 00 
	return 0;
}
  8025f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8025fc:	83 c4 10             	add    $0x10,%esp
  8025ff:	5b                   	pop    %ebx
  802600:	5e                   	pop    %esi
  802601:	5d                   	pop    %ebp
  802602:	c3                   	ret    

00802603 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802603:	55                   	push   %ebp
  802604:	89 e5                	mov    %esp,%ebp
  802606:	53                   	push   %ebx
  802607:	83 ec 14             	sub    $0x14,%esp
  80260a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80260d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802611:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802618:	e8 73 e9 ff ff       	call   800f90 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80261d:	89 1c 24             	mov    %ebx,(%esp)
  802620:	e8 9f eb ff ff       	call   8011c4 <fd2data>
  802625:	89 44 24 04          	mov    %eax,0x4(%esp)
  802629:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802630:	e8 5b e9 ff ff       	call   800f90 <sys_page_unmap>
}
  802635:	83 c4 14             	add    $0x14,%esp
  802638:	5b                   	pop    %ebx
  802639:	5d                   	pop    %ebp
  80263a:	c3                   	ret    

0080263b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80263b:	55                   	push   %ebp
  80263c:	89 e5                	mov    %esp,%ebp
  80263e:	57                   	push   %edi
  80263f:	56                   	push   %esi
  802640:	53                   	push   %ebx
  802641:	83 ec 2c             	sub    $0x2c,%esp
  802644:	89 c7                	mov    %eax,%edi
  802646:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802649:	a1 90 77 80 00       	mov    0x807790,%eax
  80264e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802651:	89 3c 24             	mov    %edi,(%esp)
  802654:	e8 73 04 00 00       	call   802acc <pageref>
  802659:	89 c6                	mov    %eax,%esi
  80265b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80265e:	89 04 24             	mov    %eax,(%esp)
  802661:	e8 66 04 00 00       	call   802acc <pageref>
  802666:	39 c6                	cmp    %eax,%esi
  802668:	0f 94 c0             	sete   %al
  80266b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80266e:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802674:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802677:	39 cb                	cmp    %ecx,%ebx
  802679:	75 08                	jne    802683 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80267b:	83 c4 2c             	add    $0x2c,%esp
  80267e:	5b                   	pop    %ebx
  80267f:	5e                   	pop    %esi
  802680:	5f                   	pop    %edi
  802681:	5d                   	pop    %ebp
  802682:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802683:	83 f8 01             	cmp    $0x1,%eax
  802686:	75 c1                	jne    802649 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802688:	8b 42 58             	mov    0x58(%edx),%eax
  80268b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802692:	00 
  802693:	89 44 24 08          	mov    %eax,0x8(%esp)
  802697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80269b:	c7 04 24 c4 33 80 00 	movl   $0x8033c4,(%esp)
  8026a2:	e8 a5 de ff ff       	call   80054c <cprintf>
  8026a7:	eb a0                	jmp    802649 <_pipeisclosed+0xe>

008026a9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026a9:	55                   	push   %ebp
  8026aa:	89 e5                	mov    %esp,%ebp
  8026ac:	57                   	push   %edi
  8026ad:	56                   	push   %esi
  8026ae:	53                   	push   %ebx
  8026af:	83 ec 1c             	sub    $0x1c,%esp
  8026b2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8026b5:	89 34 24             	mov    %esi,(%esp)
  8026b8:	e8 07 eb ff ff       	call   8011c4 <fd2data>
  8026bd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8026c4:	eb 3c                	jmp    802702 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8026c6:	89 da                	mov    %ebx,%edx
  8026c8:	89 f0                	mov    %esi,%eax
  8026ca:	e8 6c ff ff ff       	call   80263b <_pipeisclosed>
  8026cf:	85 c0                	test   %eax,%eax
  8026d1:	75 38                	jne    80270b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8026d3:	e8 f2 e7 ff ff       	call   800eca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8026d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8026db:	8b 13                	mov    (%ebx),%edx
  8026dd:	83 c2 20             	add    $0x20,%edx
  8026e0:	39 d0                	cmp    %edx,%eax
  8026e2:	73 e2                	jae    8026c6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8026e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026e7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8026ea:	89 c2                	mov    %eax,%edx
  8026ec:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8026f2:	79 05                	jns    8026f9 <devpipe_write+0x50>
  8026f4:	4a                   	dec    %edx
  8026f5:	83 ca e0             	or     $0xffffffe0,%edx
  8026f8:	42                   	inc    %edx
  8026f9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8026fd:	40                   	inc    %eax
  8026fe:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802701:	47                   	inc    %edi
  802702:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802705:	75 d1                	jne    8026d8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802707:	89 f8                	mov    %edi,%eax
  802709:	eb 05                	jmp    802710 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80270b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802710:	83 c4 1c             	add    $0x1c,%esp
  802713:	5b                   	pop    %ebx
  802714:	5e                   	pop    %esi
  802715:	5f                   	pop    %edi
  802716:	5d                   	pop    %ebp
  802717:	c3                   	ret    

00802718 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802718:	55                   	push   %ebp
  802719:	89 e5                	mov    %esp,%ebp
  80271b:	57                   	push   %edi
  80271c:	56                   	push   %esi
  80271d:	53                   	push   %ebx
  80271e:	83 ec 1c             	sub    $0x1c,%esp
  802721:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802724:	89 3c 24             	mov    %edi,(%esp)
  802727:	e8 98 ea ff ff       	call   8011c4 <fd2data>
  80272c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80272e:	be 00 00 00 00       	mov    $0x0,%esi
  802733:	eb 3a                	jmp    80276f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802735:	85 f6                	test   %esi,%esi
  802737:	74 04                	je     80273d <devpipe_read+0x25>
				return i;
  802739:	89 f0                	mov    %esi,%eax
  80273b:	eb 40                	jmp    80277d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80273d:	89 da                	mov    %ebx,%edx
  80273f:	89 f8                	mov    %edi,%eax
  802741:	e8 f5 fe ff ff       	call   80263b <_pipeisclosed>
  802746:	85 c0                	test   %eax,%eax
  802748:	75 2e                	jne    802778 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80274a:	e8 7b e7 ff ff       	call   800eca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80274f:	8b 03                	mov    (%ebx),%eax
  802751:	3b 43 04             	cmp    0x4(%ebx),%eax
  802754:	74 df                	je     802735 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802756:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80275b:	79 05                	jns    802762 <devpipe_read+0x4a>
  80275d:	48                   	dec    %eax
  80275e:	83 c8 e0             	or     $0xffffffe0,%eax
  802761:	40                   	inc    %eax
  802762:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802766:	8b 55 0c             	mov    0xc(%ebp),%edx
  802769:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80276c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80276e:	46                   	inc    %esi
  80276f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802772:	75 db                	jne    80274f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802774:	89 f0                	mov    %esi,%eax
  802776:	eb 05                	jmp    80277d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802778:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80277d:	83 c4 1c             	add    $0x1c,%esp
  802780:	5b                   	pop    %ebx
  802781:	5e                   	pop    %esi
  802782:	5f                   	pop    %edi
  802783:	5d                   	pop    %ebp
  802784:	c3                   	ret    

00802785 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802785:	55                   	push   %ebp
  802786:	89 e5                	mov    %esp,%ebp
  802788:	57                   	push   %edi
  802789:	56                   	push   %esi
  80278a:	53                   	push   %ebx
  80278b:	83 ec 3c             	sub    $0x3c,%esp
  80278e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802791:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802794:	89 04 24             	mov    %eax,(%esp)
  802797:	e8 43 ea ff ff       	call   8011df <fd_alloc>
  80279c:	89 c3                	mov    %eax,%ebx
  80279e:	85 c0                	test   %eax,%eax
  8027a0:	0f 88 45 01 00 00    	js     8028eb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027a6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027ad:	00 
  8027ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027bc:	e8 28 e7 ff ff       	call   800ee9 <sys_page_alloc>
  8027c1:	89 c3                	mov    %eax,%ebx
  8027c3:	85 c0                	test   %eax,%eax
  8027c5:	0f 88 20 01 00 00    	js     8028eb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8027cb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8027ce:	89 04 24             	mov    %eax,(%esp)
  8027d1:	e8 09 ea ff ff       	call   8011df <fd_alloc>
  8027d6:	89 c3                	mov    %eax,%ebx
  8027d8:	85 c0                	test   %eax,%eax
  8027da:	0f 88 f8 00 00 00    	js     8028d8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027e0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027e7:	00 
  8027e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027f6:	e8 ee e6 ff ff       	call   800ee9 <sys_page_alloc>
  8027fb:	89 c3                	mov    %eax,%ebx
  8027fd:	85 c0                	test   %eax,%eax
  8027ff:	0f 88 d3 00 00 00    	js     8028d8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802805:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802808:	89 04 24             	mov    %eax,(%esp)
  80280b:	e8 b4 e9 ff ff       	call   8011c4 <fd2data>
  802810:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802812:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802819:	00 
  80281a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80281e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802825:	e8 bf e6 ff ff       	call   800ee9 <sys_page_alloc>
  80282a:	89 c3                	mov    %eax,%ebx
  80282c:	85 c0                	test   %eax,%eax
  80282e:	0f 88 91 00 00 00    	js     8028c5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802834:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802837:	89 04 24             	mov    %eax,(%esp)
  80283a:	e8 85 e9 ff ff       	call   8011c4 <fd2data>
  80283f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802846:	00 
  802847:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80284b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802852:	00 
  802853:	89 74 24 04          	mov    %esi,0x4(%esp)
  802857:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80285e:	e8 da e6 ff ff       	call   800f3d <sys_page_map>
  802863:	89 c3                	mov    %eax,%ebx
  802865:	85 c0                	test   %eax,%eax
  802867:	78 4c                	js     8028b5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802869:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  80286f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802872:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802874:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802877:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80287e:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  802884:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802887:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802889:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80288c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802893:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802896:	89 04 24             	mov    %eax,(%esp)
  802899:	e8 16 e9 ff ff       	call   8011b4 <fd2num>
  80289e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8028a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028a3:	89 04 24             	mov    %eax,(%esp)
  8028a6:	e8 09 e9 ff ff       	call   8011b4 <fd2num>
  8028ab:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8028ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028b3:	eb 36                	jmp    8028eb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8028b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028c0:	e8 cb e6 ff ff       	call   800f90 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8028c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028d3:	e8 b8 e6 ff ff       	call   800f90 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8028d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028e6:	e8 a5 e6 ff ff       	call   800f90 <sys_page_unmap>
    err:
	return r;
}
  8028eb:	89 d8                	mov    %ebx,%eax
  8028ed:	83 c4 3c             	add    $0x3c,%esp
  8028f0:	5b                   	pop    %ebx
  8028f1:	5e                   	pop    %esi
  8028f2:	5f                   	pop    %edi
  8028f3:	5d                   	pop    %ebp
  8028f4:	c3                   	ret    

008028f5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8028f5:	55                   	push   %ebp
  8028f6:	89 e5                	mov    %esp,%ebp
  8028f8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8028fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802902:	8b 45 08             	mov    0x8(%ebp),%eax
  802905:	89 04 24             	mov    %eax,(%esp)
  802908:	e8 25 e9 ff ff       	call   801232 <fd_lookup>
  80290d:	85 c0                	test   %eax,%eax
  80290f:	78 15                	js     802926 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802911:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802914:	89 04 24             	mov    %eax,(%esp)
  802917:	e8 a8 e8 ff ff       	call   8011c4 <fd2data>
	return _pipeisclosed(fd, p);
  80291c:	89 c2                	mov    %eax,%edx
  80291e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802921:	e8 15 fd ff ff       	call   80263b <_pipeisclosed>
}
  802926:	c9                   	leave  
  802927:	c3                   	ret    

00802928 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802928:	55                   	push   %ebp
  802929:	89 e5                	mov    %esp,%ebp
  80292b:	56                   	push   %esi
  80292c:	53                   	push   %ebx
  80292d:	83 ec 10             	sub    $0x10,%esp
  802930:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802933:	85 f6                	test   %esi,%esi
  802935:	75 24                	jne    80295b <wait+0x33>
  802937:	c7 44 24 0c dc 33 80 	movl   $0x8033dc,0xc(%esp)
  80293e:	00 
  80293f:	c7 44 24 08 a7 32 80 	movl   $0x8032a7,0x8(%esp)
  802946:	00 
  802947:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80294e:	00 
  80294f:	c7 04 24 e7 33 80 00 	movl   $0x8033e7,(%esp)
  802956:	e8 f9 da ff ff       	call   800454 <_panic>
	e = &envs[ENVX(envid)];
  80295b:	89 f3                	mov    %esi,%ebx
  80295d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802963:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  80296a:	c1 e3 07             	shl    $0x7,%ebx
  80296d:	29 c3                	sub    %eax,%ebx
  80296f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802975:	eb 05                	jmp    80297c <wait+0x54>
		sys_yield();
  802977:	e8 4e e5 ff ff       	call   800eca <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80297c:	8b 43 48             	mov    0x48(%ebx),%eax
  80297f:	39 f0                	cmp    %esi,%eax
  802981:	75 07                	jne    80298a <wait+0x62>
  802983:	8b 43 54             	mov    0x54(%ebx),%eax
  802986:	85 c0                	test   %eax,%eax
  802988:	75 ed                	jne    802977 <wait+0x4f>
		sys_yield();
}
  80298a:	83 c4 10             	add    $0x10,%esp
  80298d:	5b                   	pop    %ebx
  80298e:	5e                   	pop    %esi
  80298f:	5d                   	pop    %ebp
  802990:	c3                   	ret    
  802991:	00 00                	add    %al,(%eax)
	...

00802994 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802994:	55                   	push   %ebp
  802995:	89 e5                	mov    %esp,%ebp
  802997:	56                   	push   %esi
  802998:	53                   	push   %ebx
  802999:	83 ec 10             	sub    $0x10,%esp
  80299c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80299f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029a2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8029a5:	85 c0                	test   %eax,%eax
  8029a7:	74 0a                	je     8029b3 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8029a9:	89 04 24             	mov    %eax,(%esp)
  8029ac:	e8 4e e7 ff ff       	call   8010ff <sys_ipc_recv>
  8029b1:	eb 0c                	jmp    8029bf <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8029b3:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8029ba:	e8 40 e7 ff ff       	call   8010ff <sys_ipc_recv>
	}
	if (r < 0)
  8029bf:	85 c0                	test   %eax,%eax
  8029c1:	79 16                	jns    8029d9 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8029c3:	85 db                	test   %ebx,%ebx
  8029c5:	74 06                	je     8029cd <ipc_recv+0x39>
  8029c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8029cd:	85 f6                	test   %esi,%esi
  8029cf:	74 2c                	je     8029fd <ipc_recv+0x69>
  8029d1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8029d7:	eb 24                	jmp    8029fd <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8029d9:	85 db                	test   %ebx,%ebx
  8029db:	74 0a                	je     8029e7 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8029dd:	a1 90 77 80 00       	mov    0x807790,%eax
  8029e2:	8b 40 74             	mov    0x74(%eax),%eax
  8029e5:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8029e7:	85 f6                	test   %esi,%esi
  8029e9:	74 0a                	je     8029f5 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8029eb:	a1 90 77 80 00       	mov    0x807790,%eax
  8029f0:	8b 40 78             	mov    0x78(%eax),%eax
  8029f3:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8029f5:	a1 90 77 80 00       	mov    0x807790,%eax
  8029fa:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8029fd:	83 c4 10             	add    $0x10,%esp
  802a00:	5b                   	pop    %ebx
  802a01:	5e                   	pop    %esi
  802a02:	5d                   	pop    %ebp
  802a03:	c3                   	ret    

00802a04 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802a04:	55                   	push   %ebp
  802a05:	89 e5                	mov    %esp,%ebp
  802a07:	57                   	push   %edi
  802a08:	56                   	push   %esi
  802a09:	53                   	push   %ebx
  802a0a:	83 ec 1c             	sub    $0x1c,%esp
  802a0d:	8b 75 08             	mov    0x8(%ebp),%esi
  802a10:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802a16:	85 db                	test   %ebx,%ebx
  802a18:	74 19                	je     802a33 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802a1a:	8b 45 14             	mov    0x14(%ebp),%eax
  802a1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a21:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a25:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a29:	89 34 24             	mov    %esi,(%esp)
  802a2c:	e8 ab e6 ff ff       	call   8010dc <sys_ipc_try_send>
  802a31:	eb 1c                	jmp    802a4f <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802a33:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802a3a:	00 
  802a3b:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802a42:	ee 
  802a43:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a47:	89 34 24             	mov    %esi,(%esp)
  802a4a:	e8 8d e6 ff ff       	call   8010dc <sys_ipc_try_send>
		}
		if (r == 0)
  802a4f:	85 c0                	test   %eax,%eax
  802a51:	74 2c                	je     802a7f <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802a53:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a56:	74 20                	je     802a78 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802a58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a5c:	c7 44 24 08 f2 33 80 	movl   $0x8033f2,0x8(%esp)
  802a63:	00 
  802a64:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802a6b:	00 
  802a6c:	c7 04 24 05 34 80 00 	movl   $0x803405,(%esp)
  802a73:	e8 dc d9 ff ff       	call   800454 <_panic>
		}
		sys_yield();
  802a78:	e8 4d e4 ff ff       	call   800eca <sys_yield>
	}
  802a7d:	eb 97                	jmp    802a16 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802a7f:	83 c4 1c             	add    $0x1c,%esp
  802a82:	5b                   	pop    %ebx
  802a83:	5e                   	pop    %esi
  802a84:	5f                   	pop    %edi
  802a85:	5d                   	pop    %ebp
  802a86:	c3                   	ret    

00802a87 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a87:	55                   	push   %ebp
  802a88:	89 e5                	mov    %esp,%ebp
  802a8a:	53                   	push   %ebx
  802a8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802a8e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a93:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802a9a:	89 c2                	mov    %eax,%edx
  802a9c:	c1 e2 07             	shl    $0x7,%edx
  802a9f:	29 ca                	sub    %ecx,%edx
  802aa1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802aa7:	8b 52 50             	mov    0x50(%edx),%edx
  802aaa:	39 da                	cmp    %ebx,%edx
  802aac:	75 0f                	jne    802abd <ipc_find_env+0x36>
			return envs[i].env_id;
  802aae:	c1 e0 07             	shl    $0x7,%eax
  802ab1:	29 c8                	sub    %ecx,%eax
  802ab3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802ab8:	8b 40 40             	mov    0x40(%eax),%eax
  802abb:	eb 0c                	jmp    802ac9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802abd:	40                   	inc    %eax
  802abe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802ac3:	75 ce                	jne    802a93 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802ac5:	66 b8 00 00          	mov    $0x0,%ax
}
  802ac9:	5b                   	pop    %ebx
  802aca:	5d                   	pop    %ebp
  802acb:	c3                   	ret    

00802acc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802acc:	55                   	push   %ebp
  802acd:	89 e5                	mov    %esp,%ebp
  802acf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ad2:	89 c2                	mov    %eax,%edx
  802ad4:	c1 ea 16             	shr    $0x16,%edx
  802ad7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802ade:	f6 c2 01             	test   $0x1,%dl
  802ae1:	74 1e                	je     802b01 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ae3:	c1 e8 0c             	shr    $0xc,%eax
  802ae6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802aed:	a8 01                	test   $0x1,%al
  802aef:	74 17                	je     802b08 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802af1:	c1 e8 0c             	shr    $0xc,%eax
  802af4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802afb:	ef 
  802afc:	0f b7 c0             	movzwl %ax,%eax
  802aff:	eb 0c                	jmp    802b0d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802b01:	b8 00 00 00 00       	mov    $0x0,%eax
  802b06:	eb 05                	jmp    802b0d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802b08:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802b0d:	5d                   	pop    %ebp
  802b0e:	c3                   	ret    
	...

00802b10 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802b10:	55                   	push   %ebp
  802b11:	57                   	push   %edi
  802b12:	56                   	push   %esi
  802b13:	83 ec 10             	sub    $0x10,%esp
  802b16:	8b 74 24 20          	mov    0x20(%esp),%esi
  802b1a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802b1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b22:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802b26:	89 cd                	mov    %ecx,%ebp
  802b28:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802b2c:	85 c0                	test   %eax,%eax
  802b2e:	75 2c                	jne    802b5c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802b30:	39 f9                	cmp    %edi,%ecx
  802b32:	77 68                	ja     802b9c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b34:	85 c9                	test   %ecx,%ecx
  802b36:	75 0b                	jne    802b43 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b38:	b8 01 00 00 00       	mov    $0x1,%eax
  802b3d:	31 d2                	xor    %edx,%edx
  802b3f:	f7 f1                	div    %ecx
  802b41:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802b43:	31 d2                	xor    %edx,%edx
  802b45:	89 f8                	mov    %edi,%eax
  802b47:	f7 f1                	div    %ecx
  802b49:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b4b:	89 f0                	mov    %esi,%eax
  802b4d:	f7 f1                	div    %ecx
  802b4f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b51:	89 f0                	mov    %esi,%eax
  802b53:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b55:	83 c4 10             	add    $0x10,%esp
  802b58:	5e                   	pop    %esi
  802b59:	5f                   	pop    %edi
  802b5a:	5d                   	pop    %ebp
  802b5b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b5c:	39 f8                	cmp    %edi,%eax
  802b5e:	77 2c                	ja     802b8c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802b60:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802b63:	83 f6 1f             	xor    $0x1f,%esi
  802b66:	75 4c                	jne    802bb4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b68:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b6a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b6f:	72 0a                	jb     802b7b <__udivdi3+0x6b>
  802b71:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802b75:	0f 87 ad 00 00 00    	ja     802c28 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b7b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b80:	89 f0                	mov    %esi,%eax
  802b82:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b84:	83 c4 10             	add    $0x10,%esp
  802b87:	5e                   	pop    %esi
  802b88:	5f                   	pop    %edi
  802b89:	5d                   	pop    %ebp
  802b8a:	c3                   	ret    
  802b8b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b8c:	31 ff                	xor    %edi,%edi
  802b8e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b90:	89 f0                	mov    %esi,%eax
  802b92:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b94:	83 c4 10             	add    $0x10,%esp
  802b97:	5e                   	pop    %esi
  802b98:	5f                   	pop    %edi
  802b99:	5d                   	pop    %ebp
  802b9a:	c3                   	ret    
  802b9b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b9c:	89 fa                	mov    %edi,%edx
  802b9e:	89 f0                	mov    %esi,%eax
  802ba0:	f7 f1                	div    %ecx
  802ba2:	89 c6                	mov    %eax,%esi
  802ba4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802ba6:	89 f0                	mov    %esi,%eax
  802ba8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802baa:	83 c4 10             	add    $0x10,%esp
  802bad:	5e                   	pop    %esi
  802bae:	5f                   	pop    %edi
  802baf:	5d                   	pop    %ebp
  802bb0:	c3                   	ret    
  802bb1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802bb4:	89 f1                	mov    %esi,%ecx
  802bb6:	d3 e0                	shl    %cl,%eax
  802bb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802bbc:	b8 20 00 00 00       	mov    $0x20,%eax
  802bc1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802bc3:	89 ea                	mov    %ebp,%edx
  802bc5:	88 c1                	mov    %al,%cl
  802bc7:	d3 ea                	shr    %cl,%edx
  802bc9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802bcd:	09 ca                	or     %ecx,%edx
  802bcf:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802bd3:	89 f1                	mov    %esi,%ecx
  802bd5:	d3 e5                	shl    %cl,%ebp
  802bd7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802bdb:	89 fd                	mov    %edi,%ebp
  802bdd:	88 c1                	mov    %al,%cl
  802bdf:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802be1:	89 fa                	mov    %edi,%edx
  802be3:	89 f1                	mov    %esi,%ecx
  802be5:	d3 e2                	shl    %cl,%edx
  802be7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802beb:	88 c1                	mov    %al,%cl
  802bed:	d3 ef                	shr    %cl,%edi
  802bef:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802bf1:	89 f8                	mov    %edi,%eax
  802bf3:	89 ea                	mov    %ebp,%edx
  802bf5:	f7 74 24 08          	divl   0x8(%esp)
  802bf9:	89 d1                	mov    %edx,%ecx
  802bfb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802bfd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c01:	39 d1                	cmp    %edx,%ecx
  802c03:	72 17                	jb     802c1c <__udivdi3+0x10c>
  802c05:	74 09                	je     802c10 <__udivdi3+0x100>
  802c07:	89 fe                	mov    %edi,%esi
  802c09:	31 ff                	xor    %edi,%edi
  802c0b:	e9 41 ff ff ff       	jmp    802b51 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802c10:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c14:	89 f1                	mov    %esi,%ecx
  802c16:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c18:	39 c2                	cmp    %eax,%edx
  802c1a:	73 eb                	jae    802c07 <__udivdi3+0xf7>
		{
		  q0--;
  802c1c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802c1f:	31 ff                	xor    %edi,%edi
  802c21:	e9 2b ff ff ff       	jmp    802b51 <__udivdi3+0x41>
  802c26:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802c28:	31 f6                	xor    %esi,%esi
  802c2a:	e9 22 ff ff ff       	jmp    802b51 <__udivdi3+0x41>
	...

00802c30 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802c30:	55                   	push   %ebp
  802c31:	57                   	push   %edi
  802c32:	56                   	push   %esi
  802c33:	83 ec 20             	sub    $0x20,%esp
  802c36:	8b 44 24 30          	mov    0x30(%esp),%eax
  802c3a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802c3e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802c42:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802c46:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802c4a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802c4e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802c50:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802c52:	85 ed                	test   %ebp,%ebp
  802c54:	75 16                	jne    802c6c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802c56:	39 f1                	cmp    %esi,%ecx
  802c58:	0f 86 a6 00 00 00    	jbe    802d04 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802c5e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802c60:	89 d0                	mov    %edx,%eax
  802c62:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802c64:	83 c4 20             	add    $0x20,%esp
  802c67:	5e                   	pop    %esi
  802c68:	5f                   	pop    %edi
  802c69:	5d                   	pop    %ebp
  802c6a:	c3                   	ret    
  802c6b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802c6c:	39 f5                	cmp    %esi,%ebp
  802c6e:	0f 87 ac 00 00 00    	ja     802d20 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802c74:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802c77:	83 f0 1f             	xor    $0x1f,%eax
  802c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c7e:	0f 84 a8 00 00 00    	je     802d2c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802c84:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802c88:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802c8a:	bf 20 00 00 00       	mov    $0x20,%edi
  802c8f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802c93:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c97:	89 f9                	mov    %edi,%ecx
  802c99:	d3 e8                	shr    %cl,%eax
  802c9b:	09 e8                	or     %ebp,%eax
  802c9d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802ca1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ca5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ca9:	d3 e0                	shl    %cl,%eax
  802cab:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802caf:	89 f2                	mov    %esi,%edx
  802cb1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802cb3:	8b 44 24 14          	mov    0x14(%esp),%eax
  802cb7:	d3 e0                	shl    %cl,%eax
  802cb9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802cbd:	8b 44 24 14          	mov    0x14(%esp),%eax
  802cc1:	89 f9                	mov    %edi,%ecx
  802cc3:	d3 e8                	shr    %cl,%eax
  802cc5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802cc7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802cc9:	89 f2                	mov    %esi,%edx
  802ccb:	f7 74 24 18          	divl   0x18(%esp)
  802ccf:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802cd1:	f7 64 24 0c          	mull   0xc(%esp)
  802cd5:	89 c5                	mov    %eax,%ebp
  802cd7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802cd9:	39 d6                	cmp    %edx,%esi
  802cdb:	72 67                	jb     802d44 <__umoddi3+0x114>
  802cdd:	74 75                	je     802d54 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802cdf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802ce3:	29 e8                	sub    %ebp,%eax
  802ce5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802ce7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ceb:	d3 e8                	shr    %cl,%eax
  802ced:	89 f2                	mov    %esi,%edx
  802cef:	89 f9                	mov    %edi,%ecx
  802cf1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802cf3:	09 d0                	or     %edx,%eax
  802cf5:	89 f2                	mov    %esi,%edx
  802cf7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802cfb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802cfd:	83 c4 20             	add    $0x20,%esp
  802d00:	5e                   	pop    %esi
  802d01:	5f                   	pop    %edi
  802d02:	5d                   	pop    %ebp
  802d03:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802d04:	85 c9                	test   %ecx,%ecx
  802d06:	75 0b                	jne    802d13 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802d08:	b8 01 00 00 00       	mov    $0x1,%eax
  802d0d:	31 d2                	xor    %edx,%edx
  802d0f:	f7 f1                	div    %ecx
  802d11:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802d13:	89 f0                	mov    %esi,%eax
  802d15:	31 d2                	xor    %edx,%edx
  802d17:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802d19:	89 f8                	mov    %edi,%eax
  802d1b:	e9 3e ff ff ff       	jmp    802c5e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802d20:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802d22:	83 c4 20             	add    $0x20,%esp
  802d25:	5e                   	pop    %esi
  802d26:	5f                   	pop    %edi
  802d27:	5d                   	pop    %ebp
  802d28:	c3                   	ret    
  802d29:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802d2c:	39 f5                	cmp    %esi,%ebp
  802d2e:	72 04                	jb     802d34 <__umoddi3+0x104>
  802d30:	39 f9                	cmp    %edi,%ecx
  802d32:	77 06                	ja     802d3a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802d34:	89 f2                	mov    %esi,%edx
  802d36:	29 cf                	sub    %ecx,%edi
  802d38:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802d3a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802d3c:	83 c4 20             	add    $0x20,%esp
  802d3f:	5e                   	pop    %esi
  802d40:	5f                   	pop    %edi
  802d41:	5d                   	pop    %ebp
  802d42:	c3                   	ret    
  802d43:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802d44:	89 d1                	mov    %edx,%ecx
  802d46:	89 c5                	mov    %eax,%ebp
  802d48:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802d4c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802d50:	eb 8d                	jmp    802cdf <__umoddi3+0xaf>
  802d52:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802d54:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802d58:	72 ea                	jb     802d44 <__umoddi3+0x114>
  802d5a:	89 f1                	mov    %esi,%ecx
  802d5c:	eb 81                	jmp    802cdf <__umoddi3+0xaf>
